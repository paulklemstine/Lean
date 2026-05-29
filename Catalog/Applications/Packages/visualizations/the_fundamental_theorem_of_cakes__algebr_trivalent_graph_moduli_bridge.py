# Visualization 3: The Trivalent Graph-Moduli Bridge
#
# Visualizes the deep connection between trivalent graphs on
# genus-g surfaces and the moduli dimension formula 3g-3.
# Shows how graph combinatorics encode moduli space structure.

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Trivalent Graph ↔ Moduli Space Bridge",
             fontsize=15, fontweight='bold')

# ─── Plot 1: The Bridge Diagram ───
ax1 = axes[0]
g_vals = np.arange(2, 12)
E_vals = 3 * (g_vals - 1)
V_vals = 2 * (g_vals - 1)
moduli_vals = 3 * g_vals - 3

ax1.fill_between(g_vals, 0, E_vals, alpha=0.15, color='blue',
                  label='E = 3(g−1)')
ax1.plot(g_vals, E_vals, 'bo-', linewidth=2.5, markersize=8, 
         label='Trivalent edges E')
ax1.plot(g_vals, moduli_vals, 'r^--', linewidth=2.5, markersize=10,
         label='moduliDim(g) = 3g−3', alpha=0.8)

# Highlight that they're equal
for g in g_vals:
    E = 3 * (g - 1)
    ax1.annotate('', xy=(g, E), xytext=(g, E + 2),
                 arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

ax1.set_xlabel('Genus g', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title('E = moduliDim(g): Perfect Match', fontsize=12)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.text(8, 5, 'E ≡ 3g−3', fontsize=14, color='green',
         fontweight='bold', fontstyle='italic')

# ─── Plot 2: Euler Formula Components ───
ax2 = axes[1]
F_vals = np.ones_like(g_vals)  # Single face
euler_lhs = V_vals - E_vals + F_vals
euler_rhs = 2 - 2 * g_vals

width = 0.35
x = np.arange(len(g_vals))
bars1 = ax2.bar(x - width/2, euler_lhs, width, label='V − E + F',
                 color='steelblue', edgecolor='black', linewidth=0.5)
bars2 = ax2.bar(x + width/2, euler_rhs, width, label='2 − 2g',
                 color='coral', edgecolor='black', linewidth=0.5)

ax2.set_xlabel('Genus g', fontsize=12)
ax2.set_ylabel('Euler characteristic', fontsize=12)
ax2.set_title("Euler's Formula: V − E + F = 2 − 2g", fontsize=12)
ax2.set_xticks(x)
ax2.set_xticklabels([str(g) for g in g_vals])
ax2.legend(fontsize=10)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.grid(True, alpha=0.3, axis='y')

# ─── Plot 3: Flavor Class Growth ───
ax3 = axes[2]
n_max_vals = range(1, 11)
for g_max in [1, 2, 3, 5]:
    k_max = 3
    counts = [(n + 1) * (k_max + 1) * (g_max + 1) for n in n_max_vals]
    ax3.plot(list(n_max_vals), counts, 'o-', linewidth=2, markersize=6,
             label=f'g≤{g_max}, k≤{k_max}')

ax3.set_xlabel('Max dimension n', fontsize=12)
ax3.set_ylabel('Flavor classes', fontsize=12)
ax3.set_title('Flavor Isomorphism Classes\n(n+1)(k+1)(g+1)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trivalent_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trivalent_bridge.png")
