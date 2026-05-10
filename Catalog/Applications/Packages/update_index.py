import os
import glob
import re
import subprocess

def get_creation_date(filepath):
    # Try to get the first commit date using git
    try:
        result = subprocess.run(
            ['git', 'log', '--format=%ai', '--reverse', '--', filepath],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        dates = result.stdout.strip().split('\n')
        if dates and dates[0]:
            return dates[0]
    except subprocess.CalledProcessError:
        pass

    # Fallback to file creation/modification time if not in git
    import time
    return time.strftime('%Y-%m-%d %H:%M:%S %z', time.localtime(os.path.getctime(filepath)))

def update_index():
    # Find all html files in the directory except index.html
    # We must be in the Catalog/Applications/Packages directory for this to work correctly
    # with glob and git
    original_dir = os.getcwd()
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    html_files = [f for f in glob.glob("*.html") if f != "index.html"]
    
    # Format them as a Javascript array of objects
    file_objects = []
    for f in html_files:
        date = get_creation_date(f)
        file_objects.append(f'{{ filename: "{f}", date: "{date}" }}')

    files_js = ",\n        ".join(file_objects)
    
    # Read current index.html
    with open("index.html", "r", encoding="utf-8") as f:
        content = f.read()
        
    # Replace the JS files array using Regex
    pattern = r'(const files = \[).*?(\];)'
    replacement = f'\\1\n        {files_js}\n    \\2'
    
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    # Save the updated index.html
    with open("index.html", "w", encoding="utf-8") as f:
        f.write(new_content)
        
    print(f"Successfully updated index.html with {len(html_files)} files.")
    os.chdir(original_dir)

if __name__ == "__main__":
    update_index()
