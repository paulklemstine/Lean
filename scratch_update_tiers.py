import json, glob, os

changed = 0
for f in glob.glob('Packages/*.json'):
    if f.endswith('lineage.json') or f.endswith('package_index.js') or f.endswith('future_directions.json'):
        continue
    with open(f, 'r') as file:
        try:
            data = json.load(file)
        except:
            continue
            
    if 'quality_score' in data:
        qs = data['quality_score']
        old_tier = data.get('quality_tier')
        new_tier = 'gold' if qs >= 0.90 else ('silver' if qs >= 0.70 else 'bronze')
        if old_tier != new_tier:
            data['quality_tier'] = new_tier
            with open(f, 'w') as file:
                json.dump(data, file, indent=4)
            changed += 1

print(f'Updated {changed} packages.')
