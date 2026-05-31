import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

ns = list(range(2, 12))
genera = [(n-1)*(n-2)//2 for n in ns]
canon_degrees = [n*(n-3) for n in ns]

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

ax = axes[0]
ax.bar(ns, genera, color='steelblue', alpha=0.8, edgecolor='navy')
ax.set_xlabel('n'); ax.set_ylabel('Genus g(K_n)')
ax.set_title('Genus of Complete Graph K_n: g = (n-1)(n-2)/2')
for n, g in zip(ns, genera):
    if g > 0: ax.text(n, g + 0.5, str(g), ha='center', fontsize=9)

ax = axes[1]
ax.plot(ns, canon_degrees, 'ro-', markersize=8, label='deg(K_G) = n(n-3)')
ax.plot(ns, [2*g - 2 for g in genera], 'b^--', markersize=8, label='2g - 2')
ax.set_xlabel('n'); ax.set_ylabel('Degree')
ax.set_title('deg(K_G) = 2g - 2'); ax.legend(); ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('genus_canonical.png', dpi=150, bbox_inches='tight')
plt.close()
print('Saved genus_canonical.png')