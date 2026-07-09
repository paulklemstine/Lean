import matplotlib.pyplot as plt
from itertools import product

verts = [0, 1, 2, 3]
edges = [(u, v) for u in verts for v in verts if u < v]
m = len(edges)
fractions = []
for code in product(range(3), repeat=4):
    c = {v: code[v] for v in verts}
    catches = sum(1 for (u, v) in edges if c[u] == c[v])
    fractions.append(catches / m)
plt.figure(figsize=(9, 4))
plt.bar(range(len(fractions)), sorted(fractions), color='#3b82f6')
plt.axhline(1 / m, color='red', linestyle='--', label='1/|E| = 1/6')
plt.xlabel('colouring index (sorted)')
plt.ylabel('fraction of catching edges')
plt.title('Soundness gap over all 81 colourings of K4')
plt.legend()
plt.tight_layout()
plt.savefig('soundness_gap_K4.png', dpi=150)
print('saved soundness_gap_K4.png')
