import math
import numpy as np
import matplotlib.pyplot as plt

def expected_edges(n, p):     return math.comb(n, 2) * p
def expected_triangles(n, p): return math.comb(n, 3) * p ** 3
def expected_isolated(n, p):  return n * (1.0 - p) ** (n - 1)

def main() -> None:
    n = 1000
    ps = np.logspace(-4, -0.5, 400)
    edges = [expected_edges(n, p) for p in ps]
    tris = [expected_triangles(n, p) for p in ps]
    iso = [expected_isolated(n, p) for p in ps]
    fig, ax = plt.subplots(figsize=(9, 6))
    ax.loglog(ps, edges, label='E[#edges] = C(n,2)p')
    ax.loglog(ps, tris, label='E[#triangles] = C(n,3)p^3')
    ax.loglog(ps, iso, label='E[#isolated] = n(1-p)^(n-1)')
    ax.axvline(1.0 / n, color='gray', ls='--', label='p = 1/n (giant)')
    ax.axvline(math.log(n) / n, color='black', ls=':',
               label='p = ln(n)/n (connectivity)')
    ax.set_xlabel('edge probability p')
    ax.set_ylabel('expected count')
    ax.set_title(f'Erdos-Renyi first moments and thresholds (n={n})')
    ax.legend()
    ax.grid(True, which='both', alpha=0.3)
    plt.tight_layout()
    plt.savefig('threshold_landscape.png', dpi=150)
    print('wrote threshold_landscape.png')

if __name__ == '__main__':
    main()
