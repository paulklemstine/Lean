"""
Visualization: Arithmetic Persistence Barcodes

Visualizes the persistence module data for elliptic curves over finite fields.
Shows how power sum sequences create "barcodes" that distinguish non-isogenous curves.
"""

import numpy as np
import matplotlib.pyplot as plt

def power_sum_seq(eigenvalues, r):
    return sum(alpha ** r for alpha in eigenvalues)

def get_eigenvalues(p, trace):
    disc = trace**2 - 4*p
    alpha = (trace + np.sqrt(complex(disc))) / 2
    beta = (trace - np.sqrt(complex(disc))) / 2
    return alpha, beta

# Setup
p = 7
traces = [0, 1, -1, 2, -2, 3]
max_r = 15
colors = plt.cm.Set2(np.linspace(0, 1, len(traces)))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Raw power sums
ax1 = axes[0, 0]
for i, t in enumerate(traces):
    alpha, beta = get_eigenvalues(p, t)
    sums = [abs(power_sum_seq([alpha, beta], r)) for r in range(max_r + 1)]
    ax1.semilogy(range(max_r + 1), [s + 1 for s in sums], '-o', color=colors[i],
                 markersize=4, label=f'trace={t}')
ax1.set_xlabel('Extension degree r')
ax1.set_ylabel('|s_r| + 1  (log scale)')
ax1.set_title('Power Sum Magnitudes')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Point counts
ax2 = axes[0, 1]
for i, t in enumerate(traces):
    alpha, beta = get_eigenvalues(p, t)
    counts = [round((p**r + 1 - alpha**r - beta**r).real) for r in range(1, max_r + 1)]
    ax2.semilogy(range(1, max_r + 1), counts, '-s', color=colors[i],
                 markersize=4, label=f'trace={t}')
ax2.semilogy(range(1, max_r + 1), [p**r for r in range(1, max_r + 1)],
             'k--', alpha=0.5, label='q^r')
ax2.set_xlabel('Extension degree r')
ax2.set_ylabel('#E(F_{q^r})  (log scale)')
ax2.set_title('Point Counts Over Extensions')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Persistence barcode
ax3 = axes[1, 0]
# Show which extension degrees separate each pair of curves
for i, t1 in enumerate(traces):
    alpha1, beta1 = get_eigenvalues(p, t1)
    for j, t2 in enumerate(traces):
        if j <= i:
            continue
        alpha2, beta2 = get_eigenvalues(p, t2)
        sep_degrees = []
        for r in range(1, max_r + 1):
            s1 = round(power_sum_seq([alpha1, beta1], r).real)
            s2 = round(power_sum_seq([alpha2, beta2], r).real)
            if s1 != s2:
                sep_degrees.append(r)

        y_pos = i * len(traces) + j - (i + 1) * (i + 2) // 2 + len(traces) - 1
        if sep_degrees:
            ax3.barh(y_pos, max(sep_degrees) - min(sep_degrees) + 1,
                     left=min(sep_degrees) - 0.5, height=0.6,
                     color=colors[i], alpha=0.7)
            ax3.plot(sep_degrees, [y_pos]*len(sep_degrees), '|', 
                     color='black', markersize=10)
        ax3.text(-0.5, y_pos, f'({t1},{t2})', ha='right', va='center', fontsize=7)

ax3.set_xlabel('Extension degree r')
ax3.set_ylabel('Curve pair (trace₁, trace₂)')
ax3.set_title('Separation Barcode')
ax3.grid(True, alpha=0.3, axis='x')

# Panel 4: Newton polygon (tropical slopes)
ax4 = axes[1, 1]
# For the polynomial t^2 - at + p, the Newton polygon at various primes
primes_to_check = [2, 3, 5, 7]
bar_width = 0.15
for k, prime in enumerate(primes_to_check):
    for i, t in enumerate(traces[:4]):
        # Coefficients of char poly: t^2 - trace*t + p
        coeffs = [1, -t, p]
        def padic_val(n, pp):
            if n == 0: return 3  # cap at 3 for display
            v = 0
            n = abs(n)
            while n % pp == 0:
                v += 1
                n //= pp
            return v
        vals = [padic_val(c, prime) for c in coeffs]
        x_pos = i + k * bar_width - (len(primes_to_check) - 1) * bar_width / 2
        ax4.bar(x_pos, max(vals), width=bar_width, color=colors[k], alpha=0.7,
                label=f'p={prime}' if i == 0 else '')

ax4.set_xticks(range(len(traces[:4])))
ax4.set_xticklabels([f'tr={t}' for t in traces[:4]])
ax4.set_ylabel('Max p-adic valuation')
ax4.set_title('Tropical Slopes (Newton Polygon Heights)')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3, axis='y')

plt.suptitle('Arithmetic Persistence Modules for Elliptic Curves over F₇',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('persistence_barcode.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved persistence_barcode.png")
