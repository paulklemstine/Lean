import matplotlib.pyplot as plt
from fractions import Fraction
from itertools import combinations, product


def random_dist_matrix(n, seed):
    state = seed
    def nxt():
        nonlocal state
        state = (1103515245 * state + 12345) % (1 << 31)
        return state
    d = [[Fraction(0)] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            v = Fraction(nxt() % 1000, 100)
            d[i][j] = d[j][i] = v
    return d


def diam(d, sigma):
    return max([Fraction(0)] + [d[x][y] for x in sigma for y in sigma])


def simplex_sup(d1, d2, n):
    faces = [frozenset(c) for k in range(n+1) for c in combinations(range(n), k)]
    return max(abs(diam(d1, s) - diam(d2, s)) for s in faces)


def edge_sup(d1, d2, n):
    return max(abs(d1[x][y] - d2[x][y]) for x, y in product(range(n), repeat=2))


ns = list(range(2, 11))
simplex_cost = [2 ** n for n in ns]
edge_cost = [n * n for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.semilogy(ns, simplex_cost, 'o-', label='simplex search  2^n')
ax1.semilogy(ns, edge_cost, 's-', label='edge search  n^2')
ax1.set_xlabel('number of points n'); ax1.set_ylabel('search-space size (log)')
ax1.set_title('Exponential -> Quadratic collapse'); ax1.legend(); ax1.grid(True, which='both', alpha=0.3)

vals_s, vals_e = [], []
for t in range(40):
    n = 5
    d1 = random_dist_matrix(n, 10 + 2*t); d2 = random_dist_matrix(n, 11 + 2*t)
    vals_s.append(float(simplex_sup(d1, d2, n)))
    vals_e.append(float(edge_sup(d1, d2, n)))
ax2.scatter(vals_s, vals_e, alpha=0.7)
lim = max(vals_s + vals_e) * 1.05
ax2.plot([0, lim], [0, lim], 'r--', label='y = x (exact agreement)')
ax2.set_xlabel('simplex-sup distance'); ax2.set_ylabel('edge-sup distance')
ax2.set_title('Edge-realization: identical exact values'); ax2.legend(); ax2.grid(True, alpha=0.3)

plt.tight_layout(); plt.savefig('collapse.png', dpi=150); print('wrote collapse.png')
