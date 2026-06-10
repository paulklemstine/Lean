import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, factorial

def zaslavsky(m, n):
    return sum(comb(m, k) for k in range(n + 1))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, n in enumerate([2, 4, 6]):
    ax = axes[idx]
    ms = list(range(1, 25))
    z_vals = [zaslavsky(m, n) for m in ms]
    poly_vals = [(m + 1) ** n for m in ms]
    exp_vals = [2 ** m for m in ms]
    asymp_vals = [m**n / factorial(n) for m in ms]

    ax.semilogy(ms, z_vals, 'b-o', markersize=4, label=f'Z(m, {n})')
    ax.semilogy(ms, poly_vals, 'r--', alpha=0.7, label=f'(m+1)^{n}')
    ax.semilogy(ms, exp_vals, 'g:', alpha=0.7, label=f'2^m')
    ax.semilogy(ms, asymp_vals, 'k-.', alpha=0.5, label=f'm^{n}/{n}!')
    ax.axvline(x=n, color='gray', linestyle=':', alpha=0.5)
    ax.text(n, ax.get_ylim()[0], f'm={n}', ha='center', va='bottom', fontsize=8)
    ax.set_xlabel('m (hyperplanes)')
    ax.set_ylabel('Region count')
    ax.set_title(f'n = {n} dimensions')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Zaslavsky Function Z(m,n) and Its Bounds', fontsize=14)
plt.tight_layout()
plt.savefig('zaslavsky_bounds.png', dpi=150, bbox_inches='tight')
print('Saved zaslavsky_bounds.png')