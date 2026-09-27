import os
import sys
import json
import time
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
import urllib.request
import urllib.parse
from pathlib import Path

# --- Configuration & State ---
CONF_FILE = ".conf"
STATE_FILE = ".telezip_state.json"

def load_config():
    if not os.path.exists(CONF_FILE):
        print("Error: .conf file not found. Please run the setup wizard first.")
        sys.exit(1)
    
    conf = {"api_url": "http://127.0.0.1:8081"}
    with open(CONF_FILE, 'r') as f:
        for line in f:
            parts = line.strip().split(' ', 1)
            if len(parts) == 2:
                conf[parts[0]] = parts[1].strip()
    return conf

def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    return {"uploaded": []}

def save_state(state):
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f)

# --- Feature 6 & 8: Zipping with Password & Exclusions ---
def zip_folder(folder_path, output_dir, password=None, exclusions=None):
    folder_name = os.path.basename(folder_path)
    zip_path = os.path.join(output_dir, f"{folder_name}.zip")
    
    print(f"📦 Zipping {folder_name}...")
    
    # We use the system zip command to support encryption easily
    cmd = ["zip", "-r"]
    if password:
        cmd.extend(["-P", password])
        
    cmd.append(zip_path)
    cmd.append(".")
    
    if exclusions:
        cmd.append("-x")
        for exc in exclusions:
            cmd.append(f"*{exc}*")
            
    try:
        subprocess.run(cmd, cwd=folder_path, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return zip_path
    except Exception as e:
        print(f"❌ Failed to zip {folder_name}: {e}")
        return None

# --- Feature 7, 9 & 4: Uploading with Captions & Cleanup ---
def upload_file(zip_path, conf, state, delete_after):
    if zip_path in state["uploaded"]:
        print(f"⏩ Skipping {os.path.basename(zip_path)} (Already uploaded)")
        return True

    file_size_mb = os.path.getsize(zip_path) / (1024 * 1024)
    filename = os.path.basename(zip_path)
    print(f"🚀 Uploading {filename} ({file_size_mb:.2f} MB)...")

    url = f"{conf['api_url']}/bot{conf['bot_token']}/sendDocument"
    caption = f"📁 Folder: {filename}\n💾 Size: {file_size_mb:.2f} MB\n⚡ Powered by TeleZip AIO"
    
    # Using curl for the upload to handle large files stably without complex Python multipart libs
    cmd = [
        "curl", "-s", "-w", "\n%{http_code}", "-X", "POST", url,
        "-F", f"chat_id={conf['chat_id']}",
        "-F", f"document=@{zip_path}",
        "-F", f"caption={caption}"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    lines = result.stdout.strip().split('\n')
    http_code = lines[-1] if lines else "0"
    
    if http_code == "200":
        print(f"✅ Success: {filename}")
        state["uploaded"].append(zip_path)
        save_state(state)
        
        # Feature 4: Auto-cleanup
        if delete_after:
            os.remove(zip_path)
            print(f"🗑️ Deleted local file: {filename}")
        return True
    else:
        print(f"❌ Failed: {filename} (HTTP {http_code})")
        return False

def send_summary(conf, total, size_mb, time_taken):
    print("📢 Sending final summary notification...")
    text = f"✅ *TeleZip AIO Backup Complete!*\n\n📦 Files Uploaded: {total}\n💾 Total Size: {size_mb:.2f} MB\n⏱️ Time Taken: {time_taken:.2f} seconds."
    url = f"{conf['api_url']}/bot{conf['bot_token']}/sendMessage"
    
    data = urllib.parse.urlencode({"chat_id": conf['chat_id'], "text": text, "parse_mode": "Markdown"}).encode()
    req = urllib.request.Request(url, data=data)
    try:
        urllib.request.urlopen(req)
    except Exception as e:
        print(f"Failed to send summary: {e}")

# --- Main AIO Logic ---
def main():
    print("==================================================")
    print("🚀 TeleZip AIO (All-In-One) Master Script")
    print("==================================================")
    
    conf = load_config()
    state = load_state()
    
    parent_dir = input("Enter the parent folder to backup: ").strip()
    if not os.path.isdir(parent_dir):
        print("❌ Invalid directory.")
        sys.exit(1)
        
    parent_name = os.path.basename(os.path.normpath(parent_dir))
    output_dir = os.path.join(parent_dir, f"{parent_name}-zip")
    os.makedirs(output_dir, exist_ok=True)
    
    # Options
    use_password = input("🔒 Do you want to encrypt the zips with a password? (y/N): ").lower() == 'y'
    password = input("Enter password: ") if use_password else None
    
    del_choice = input("🗑️ Do you want to automatically DELETE local zip files after successful upload? (y/N): ").lower()
    delete_after = del_choice == 'y'
    
    exc_choice = input("🚫 Enter any folders to exclude (comma separated, e.g., node_modules,.git) or press Enter to skip: ").strip()
    exclusions = [x.strip() for x in exc_choice.split(",")] if exc_choice else None
    
    # Collect folders
    subfolders = [os.path.join(parent_dir, d) for d in os.listdir(parent_dir) 
                  if os.path.isdir(os.path.join(parent_dir, d)) and d != f"{parent_name}-zip"]
    
    if not subfolders:
        print("No subfolders found.")
        sys.exit(0)
        
    start_time = time.time()
    
    # Feature 2: Parallel Zipping
    print(f"\n🔄 Zipping {len(subfolders)} folders in parallel...")
    zip_paths = []
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = [executor.submit(zip_folder, f, output_dir, password, exclusions) for f in subfolders]
        for future in as_completed(futures):
            res = future.result()
            if res:
                zip_paths.append(res)
                
    # Feature 9: Parallel Uploading
    print(f"\n🚀 Uploading {len(zip_paths)} files in parallel...")
    success_count = 0
    total_size_uploaded = 0
    
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = [executor.submit(upload_file, zp, conf, state, delete_after) for zp in zip_paths]
        for future, zp in zip(as_completed(futures), zip_paths):
            if future.result():
                success_count += 1
                total_size_uploaded += os.path.getsize(zp)
                
    # Feature 8: Summary Notification
    total_mb = total_size_uploaded / (1024 * 1024)
    time_taken = time.time() - start_time
    send_summary(conf, success_count, total_mb, time_taken)
    
    print("\n==================================================")
    print(f"🎉 All Done! Successfully backed up {success_count} folders.")
    print("==================================================")

if __name__ == "__main__":
    main()
