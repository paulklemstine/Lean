import os
import glob
import json
import time

def update_index():
    # We must be in the Catalog/Applications/Packages directory
    original_dir = os.getcwd()
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    json_files = [f for f in glob.glob("*.json") if f not in ("index.json", "package.json")]
    
    package_index = []
    package_db = {}
    
    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
            
            # Use file modified time as date if not provided
            date_str = data.get("date", time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(os.path.getmtime(f))))
            
            # Add to index
            package_index.append({
                "filename": f,
                "title": data.get("title", "Untitled Research"),
                "domain": data.get("domain", "General"),
                "date": date_str
            })
            
            # Add to DB
            package_db[f] = data
            
        except Exception as e:
            print(f"Error processing {f}: {e}")

    # Sort index by date descending
    package_index.sort(key=lambda x: x["date"], reverse=True)

    # We output a .js file to bypass local file:// CORS restrictions
    js_content = f"""// AUTO-GENERATED FILE. DO NOT EDIT.
// This file bundles all JSON packages so they can be loaded from file:// without CORS issues.

window.PACKAGE_INDEX = {json.dumps(package_index, indent=2)};

window.PACKAGE_DB = {json.dumps(package_db, indent=2)};
"""
    
    with open("packages_db.js", "w", encoding="utf-8") as out:
        out.write(js_content)
        
    print(f"Successfully bundled {len(json_files)} packages into packages_db.js")
    os.chdir(original_dir)

if __name__ == "__main__":
    update_index()
