import matplotlib.pyplot as plt
from itertools import combinations

S = [6, 10, 21, 35]
pairs = list(combinations(S, 2))
products = sorted({a * b for a, b in pairs})
prod_count = {}
for a, b in pairs:
    prod_count[a * b] = prod_count.get(a * b, 0) + 1

fig, ax = plt.subplots(figsize=(8, 6))
ypair = {p: i for i, p in enumerate(pairs)}
yprod = {q: i for i, q in enumerate(products)}
for (a, b) in pairs:
    q = a * b
    color = 'crimson' if prod_count[q] > 1 else 'lightgray'
    lw = 2.5 if prod_count[q] > 1 else 0.8
    ax.plot([0, 1], [ypair[(a, b)], yprod[q]], color=color, lw=lw)
for (a, b), y in ypair.items():
    ax.text(-0.05, y, f'{a}x{b}', ha='right', va='center')
for q, y in yprod.items():
    weight = 'bold' if prod_count[q] > 1 else 'normal'
    ax.text(1.05, y, str(q), ha='left', va='center', fontweight=weight)
ax.set_title('Collision lattice: 6x35 = 10x21 = 210')
ax.axis('off')
plt.tight_layout()
plt.savefig('collision_lattice.png', dpi=150)
print('saved collision_lattice.png')
