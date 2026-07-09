import matplotlib.pyplot as plt
from math import comb
from typing import List

def turan_graph_edges(n: int, r: int) -> int:
    sizes: List[int] = [n // r + (1 if i < n % r else 0) for i in range(r)]
    return comb(n, 2) - sum(comb(s, 2) for s in sizes)

rs = list(range(2, 11))
density = [1 - 1 / r for r in rs]
n = 120
achieved = [turan_graph_edges(n, r) / (n * n / 2) for r in rs]
plt.figure(figsize=(8, 5))
plt.plot(rs, density, 'o-', label='Turan factor (1 - 1/r)')
plt.plot(rs, achieved, 's--', label=f'e(T({n},r)) / (n^2/2)')
plt.axhline(0.5, color='gray', ls=':', label='Mantel level 1/2 (r=2)')
plt.xlabel('r (forbidding K_{r+1})')
plt.ylabel('edge density / (n^2/2)')
plt.title('Turan density bound and balanced-graph tightness')
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('turan_density.png', dpi=150)
print('saved turan_density.png')
