# Visualization 2: The Cake Polynomial
#
# Visualizes cake polynomials for different stratifications,
# showing how evaluation at t=-1 gives the Euler-cake characteristic
# and evaluation at t=1 gives the total layer mass.

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def cake_poly_eval(layers, t):
    """Evaluate the cake polynomial at t."""
    return sum(d * t**i for i, d in enumerate(layers))

def enumerate_stratifications(n, k):
    if k > n or k < 0:
        return []
    if k == 0:
        return [[0]] if n == 0 else []
    result = []
    for combo in combinations(range(1, n), k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(layers)
    return result

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Cake Polynomials: Algebraic Invariants of Stratified Objects",
             fontsize=15, fontweight='bold')

# ─── Plot 1: Cake polynomials for n=5, k=3 ───
ax1 = axes[0]
t_vals = np.linspace(-1.5, 2.0, 200)
strats = enumerate_stratifications(5, 3)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(strats)))

for idx, s in enumerate(strats):
    y_vals = [cake_poly_eval(s, t) for t in t_vals]
    label = str(s)
    ax1.plot(t_vals, y_vals, color=colors[idx], linewidth=1.5, label=label)

# Mark special points
for s in strats:
    euler = cake_poly_eval(s, -1)
    mass = cake_poly_eval(s, 1)
    ax1.plot(-1, euler, 'ro', markersize=5, zorder=5)
    ax1.plot(1, mass, 'bs', markersize=5, zorder=5)

ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.axvline(x=-1, color='red', linewidth=0.5, linestyle=':', alpha=0.5)
ax1.axvline(x=1, color='blue', linewidth=0.5, linestyle=':', alpha=0.5)
ax1.set_xlabel('t', fontsize=12)
ax1.set_ylabel('P(t)', fontsize=12)
ax1.set_title('Cake Polynomials (n=5, k=3)', fontsize=12)
ax1.legend(fontsize=7, loc='upper left')
ax1.annotate('P(-1) = χ_cake', xy=(-1, 0), xytext=(-1.4, -10),
             fontsize=9, color='red', arrowprops=dict(arrowstyle='->', color='red'))
ax1.annotate('P(1) = mass', xy=(1, 0), xytext=(1.2, -8),
             fontsize=9, color='blue', arrowprops=dict(arrowstyle='->', color='blue'))

# ─── Plot 2: Euler-cake vs total mass scatter ───
ax2 = axes[1]
all_euler = []
all_mass = []
all_n = []

for n in range(3, 8):
    for k in range(1, n + 1):
        strats_nk = enumerate_stratifications(n, k)
        for s in strats_nk:
            euler = sum((-1)**i * d for i, d in enumerate(s))
            mass = sum(s)
            all_euler.append(euler)
            all_mass.append(mass)
            all_n.append(n)

scatter = ax2.scatter(all_euler, all_mass, c=all_n, cmap='plasma',
                       s=30, alpha=0.7, edgecolors='black', linewidth=0.3)
plt.colorbar(scatter, ax=ax2, label='Dimension n')
ax2.set_xlabel('Euler-cake characteristic χ', fontsize=12)
ax2.set_ylabel('Total layer mass', fontsize=12)
ax2.set_title('χ_cake vs Mass\n(all strats, n=3..7)', fontsize=12)
ax2.grid(True, alpha=0.3)

# ─── Plot 3: Stratification count C(n-1, k-1) ───
ax3 = axes[2]
from math import comb
n_vals = range(1, 11)
for k in [1, 2, 3, 4, 5]:
    counts = [comb(n - 1, k - 1) if k <= n else 0 for n in n_vals]
    ax3.plot(list(n_vals), counts, 'o-', linewidth=2, markersize=6,
             label=f'k = {k}')

ax3.set_xlabel('Dimension n', fontsize=12)
ax3.set_ylabel('Number of stratifications', fontsize=12)
ax3.set_title('Stratification Count C(n−1, k−1)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_yscale('log')

plt.tight_layout()
plt.savefig('cake_polynomial_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cake_polynomial_analysis.png")
