import re

with open('Packages/js/knowledge-graph.js', 'r') as f:
    code = f.read()

# Remove remaining flameParticles and explosions drawing logic
pattern = r'            flameParticles\.forEach\(p => \{.*?\}\);\s*// ─── Explosion shockwave rings ───\s*explosions\.forEach\(e => \{.*?\}\);\s*// ─── Explosion sparks ───\s*explosions\.forEach\(e => \{.*?\}\);\s*// ─── Explosion flash overlay ───\s*explosions\.forEach\(e => \{.*?\}\);\s*'

code = re.sub(pattern, '', code, flags=re.DOTALL)

with open('Packages/js/knowledge-graph.js', 'w') as f:
    f.write(code)

with open('docs/js/knowledge-graph.js', 'w') as f:
    f.write(code)

