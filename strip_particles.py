import re

with open('Packages/js/knowledge-graph.js', 'r') as f:
    code = f.read()

# 1. Remove constants and arrays
code = re.sub(r' *const MAX_EXPLOSIONS = \d+;\n', '', code)
code = re.sub(r' *const MAX_FLAME_PARTICLES = \d+;\n', '', code)
code = re.sub(r' *const MAX_SPARKS_PER_EXPLOSION = \d+;\n', '', code)
code = re.sub(r' *const explosions = \[\];[^\n]*\n', '', code)
code = re.sub(r' *const flameParticles = \[\];[^\n]*\n', '', code)

# 2. Remove circle penetration explosion
pattern = r'if \(dist < circle\.r && explosions\.length < MAX_EXPLOSIONS\) \{.*?explosions\.push\(\{[^\}]*\}\);\s*\}'
code = re.sub(pattern, '', code, flags=re.DOTALL)

# 3. Remove elastic collision explosion
pattern = r'if \(!isConnected && explosions\.length < MAX_EXPLOSIONS\) \{.*?explosions\.push\(\{[^\}]*\}\);\s*\}'
code = re.sub(pattern, '', code, flags=re.DOTALL)

# 4. Remove flameParticles spawn
pattern = r'// Spawn flame particles.*?if \(flameParticles\.length < MAX_FLAME_PARTICLES.*?\}\s*\}'
code = re.sub(pattern, '', code, flags=re.DOTALL)

# 5. Remove update loop for explosions and flameParticles
pattern = r'// ─── Update explosions ───.*?// ─── Render ───'
code = re.sub(pattern, '// ─── Render ───', code, flags=re.DOTALL)

# 6. Remove render loops for flameParticles and explosions
pattern = r'// ─── Particle Effects ───.*?// ─── Mini-map ───'
code = re.sub(pattern, '// ─── Mini-map ───', code, flags=re.DOTALL)

with open('Packages/js/knowledge-graph.js', 'w') as f:
    f.write(code)

with open('docs/js/knowledge-graph.js', 'w') as f:
    f.write(code)

