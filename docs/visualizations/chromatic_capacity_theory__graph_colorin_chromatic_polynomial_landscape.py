"""
Visualization: Chromatic Polynomial Landscape

Visualizes the chromatic polynomial P(K_n, k) = k^{(n)} as a function of k
for various values of n, showing the falling factorial structure and the
sharp threshold at k = n where colorability begins.
"""

import numpy as np
import matplotlib.pyplot as plt


def desc_factorial(k: int, n: int) -> int:
    """Compute falling factorial k^{(n)} = k(k-1)...(k-n+1)."""
    result = 1
    for i in range(n):
        result *= max(0, k - i)
    return result


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Chromatic polynomial P(K_n, k) vs k
ax1 = axes[0]
k_values = np.arange(0, 12)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
labels = ['$K_1$', '$K_2$', '$K_3$', '$K_4$', '$K_5$']

for n in range(1, 6):
    p_values = [desc_factorial(int(k), n) for k in k_values]
    ax1.plot(k_values, p_values, 'o-', color=colors[n-1], label=labels[n-1],
             linewidth=2, markersize=6)
    # Mark the threshold where colorings become possible
    ax1.axvline(x=n, color=colors[n-1], linestyle=':', alpha=0.3)

ax1.set_xlabel('Number of colors $k$', fontsize=13)
ax1.set_ylabel('Number of proper colorings $P(K_n, k)$', fontsize=13)
ax1.set_title('Chromatic Polynomial of Complete Graphs', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_ylim(-50, 2500)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(12))

# Right panel: Chromatic capacity C(K_n, k) = ln(P(K_n,k))/n
ax2 = axes[1]
k_fine = np.arange(1, 21)

for n in range(1, 6):
    cap_values = []
    for k in k_fine:
        df = desc_factorial(int(k), n)
        if df > 0 and n > 0:
            cap_values.append(np.log(df) / n)
        else:
            cap_values.append(np.nan)
    ax2.plot(k_fine, cap_values, 'o-', color=colors[n-1], label=labels[n-1],
             linewidth=2, markersize=4)

# Add the theoretical maximum ln(k)
k_cont = np.linspace(1, 20, 100)
ax2.plot(k_cont, np.log(k_cont), 'k--', linewidth=1.5, alpha=0.5, label='$\\ln(k)$ (max)')

ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Chromatic capacity $C(K_n, k)$ (nats)', fontsize=13)
ax2.set_title('Chromatic Capacity: Information per Vertex', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('chromatic_polynomial_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: chromatic_polynomial_landscape.png")
