"""
Visualization: Derivative Tree Explosion

Shows how the derivative tree for Lorentzian recognition grows:
- For fixed degree, the tree has polynomially many leaves
- For unbounded degree, the tree explodes exponentially
- Binary branches (Boolean assignments) embed into the tree

Produces a bar chart comparing certificate sizes across regimes.
"""
import math
import matplotlib.pyplot as plt
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """C(d+n-1, n-1)"""
    if n <= 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# ── Panel 1: Upper vs lower bounds ──
ax = axes[0, 0]
degrees = list(range(3, 18))
n_fixed = 5

exact = [multiindex_count(n_fixed, d - 2) for d in degrees]
upper = [n_fixed ** (d - 2) for d in degrees]
lower = [d - 1 for d in degrees]

ax.semilogy(degrees, exact, 'bo-', markersize=5, label=f'Exact (n={n_fixed})')
ax.semilogy(degrees, upper, 'r^--', markersize=4, alpha=0.7, label=f'Upper: n^(d-2)={n_fixed}^(d-2)')
ax.semilogy(degrees, lower, 'gs--', markersize=4, alpha=0.7, label='Lower: d-1')
ax.set_xlabel('Degree (d)', fontsize=12)
ax.set_ylabel('Certificate size (log scale)', fontsize=12)
ax.set_title('Fixed n=5: Polynomial Growth', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 2: Exponential regime (d = n) ──
ax = axes[0, 1]
n_vals = list(range(3, 20))

exact_dn = [multiindex_count(n, n - 2) for n in n_vals]
exp_lower = [2 ** (n - 2) for n in n_vals]
poly_upper = [n ** (n - 2) for n in n_vals]

ax.semilogy(n_vals, exact_dn, 'bo-', markersize=5, label='Exact (d=n)')
ax.semilogy(n_vals, exp_lower, 'r^--', markersize=4, alpha=0.7, label='Lower: 2^(n-2)')
ax.semilogy(n_vals, poly_upper, 'gs--', markersize=4, alpha=0.7, label='Upper: n^(n-2)')
ax.set_xlabel('n = d (variables = degree)', fontsize=12)
ax.set_ylabel('Certificate size (log scale)', fontsize=12)
ax.set_title('Unbounded Degree: Exponential Growth', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Binary branch embedding ──
ax = axes[1, 0]
n_vals2 = list(range(1, 16))
binary = [2 ** n for n in n_vals2]
multi = [multiindex_count(n + 1, n) for n in n_vals2]

x_pos = np.arange(len(n_vals2))
width = 0.35
bars1 = ax.bar(x_pos - width/2, binary, width, label='2^n (binary branches)',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x_pos + width/2, multi, width, label='|multiIndexSet(n+1, n)|',
               color='coral', alpha=0.8)

ax.set_yscale('log')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count (log scale)', fontsize=12)
ax.set_title('Branch Embedding: 2^n ≤ multiIndexCount(n+1, n)',
             fontsize=12, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(n_vals2)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# ── Panel 4: Ratio analysis ──
ax = axes[1, 1]
ratios_dn = []
d_for_ratio = list(range(4, 22))
for d in d_for_ratio:
    n = d + 1
    exact_val = multiindex_count(n, d - 2)
    lower_val = 2 ** (d - 2)
    if lower_val > 0:
        ratios_dn.append(exact_val / lower_val)
    else:
        ratios_dn.append(1)

ax.plot(d_for_ratio, ratios_dn, 'mo-', markersize=5)
ax.axhline(y=1, color='red', linewidth=1, linestyle='--', alpha=0.5, label='ratio = 1')
ax.set_xlabel('Degree d (with n = d+1)', fontsize=12)
ax.set_ylabel('Exact / Lower bound ratio', fontsize=12)
ax.set_title('How Tight is the Exponential Lower Bound?',
             fontsize=13, fontweight='bold')
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Derivative Tree Explosion in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('derivative_tree.png', dpi=150, bbox_inches='tight')
print("Saved: derivative_tree.png")
