"""Visualization: the degree-parity gap in the cleared Riccati identity.

For y'' = f*y with deg f = d, a rational Riccati solution v = p/q forces the
cleared identity p'q - pq' + p^2 = f q^2. Fix deg q = m and plot, as a
function of deg p = n, the degree of the dominant left-hand term max(2n, n+m-1)
against the right-hand degree d + 2m, for d odd (Airy-like) vs d even.
The curves can only cross at even d, visually explaining the obstruction.
"""
import matplotlib.pyplot as plt

def plot_parity_gap(m: int = 3, n_max: int = 8) -> None:
    ns = list(range(0, n_max + 1))
    lhs = [max(2 * n, n + m - 1) for n in ns]
    rhs_odd = [1 + 2 * m for _ in ns]   # d = 1 (Airy)
    rhs_even = [2 + 2 * m for _ in ns]  # d = 2
    plt.figure(figsize=(8, 5))
    plt.plot(ns, lhs, 'o-', label='deg LHS = max(2n, n+m-1)')
    plt.plot(ns, rhs_odd, 's--', label='deg RHS, d=1 (odd, Airy)')
    plt.plot(ns, rhs_even, '^--', label='deg RHS, d=2 (even)')
    plt.xlabel('deg p = n  (deg q = m = %d fixed)' % m)
    plt.ylabel('polynomial degree')
    plt.title('Kovacic degree-parity obstruction')
    plt.legend(); plt.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig('parity_gap.png', dpi=150)
    print('wrote parity_gap.png')

if __name__ == '__main__':
    plot_parity_gap()
