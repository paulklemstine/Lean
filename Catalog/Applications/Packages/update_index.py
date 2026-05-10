import os
import glob
import re

def update_index():
    # Find all html files in the directory except index.html
    html_files = [f for f in glob.glob("*.html") if f != "index.html"]
    
    # Format them as a Javascript array
    files_js = ",\n        ".join(f'"{f}"' for f in html_files)
    
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

if __name__ == "__main__":
    update_index()
