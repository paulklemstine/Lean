"""
Visualization 3: Binary Entropy and the Spectral Bridge

Shows the binary entropy function h(alpha) and how it connects to
the spectral-entropy bridge. The non-negativity of binary entropy
is a special case of our general Shannon entropy non-negativity theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Binary entropy function
alpha = np.linspace(0.001, 0.999, 1000)
h_alpha = -(alpha * np.log(alpha) + (1 - alpha) * np.log(1 - alpha))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Binary entropy
ax = axes[0]
ax.plot(alpha, h_alpha, 'b-', linewidth=2.5)
ax.fill_between(alpha, 0, h_alpha, alpha=0.15, color='blue')
ax.axhline(y=np.log(2), color='red', linestyle='--',
           label=f'log(2) = {np.log(2):.3f}')
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.set_xlabel('α', fontsize=13)
ax.set_ylabel('h(α)', fontsize=13)
ax.set_title('Binary Entropy h(α) ≥ 0', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: The function x * log(x) (always ≤ 0 on [0,1])
ax = axes[1]
x = np.linspace(0.001, 1.0, 1000)
y = x * np.log(x)
ax.plot(x, y, 'r-', linewidth=2.5)
ax.fill_between(x, y, 0, alpha=0.15, color='red')
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.axvline(x=1/np.e, color='green', linestyle=':', linewidth=1.5,
           label=f'Minimum at x = 1/e ≈ {1/np.e:.3f}')
ax.scatter([1/np.e], [-1/np.e], color='green', s=80, zorder=5)
ax.set_xlabel('p', fontsize=13)
ax.set_ylabel('p · log(p)', fontsize=13)
ax.set_title('p · log(p) ≤ 0 on [0, 1]', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: log(x) ≤ x - 1 (key inequality)
ax = axes[2]
x = np.linspace(0.01, 4, 500)
ax.plot(x, np.log(x), 'b-', linewidth=2.5, label='log(x)')
ax.plot(x, x - 1, 'r--', linewidth=2, label='x - 1')
ax.fill_between(x, np.log(x), x - 1, alpha=0.15, color='orange',
                label='Gap: (x-1) - log(x) ≥ 0')
ax.scatter([1], [0], color='black', s=80, zorder=5)
ax.annotate('Tangent at x=1', (1, 0), xytext=(1.5, -1),
            arrowprops=dict(arrowstyle='->', color='black'),
            fontsize=11)
ax.set_xlabel('x', fontsize=13)
ax.set_ylabel('y', fontsize=13)
ax.set_title('log(x) ≤ x - 1 (Gibbs inequality engine)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 4)
ax.set_ylim(-3, 3)
ax.grid(True, alpha=0.3)

plt.suptitle('Key Inequalities of the Spectral-Entropy Bridge',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_binary_entropy.png', dpi=150, bbox_inches='tight')
print("Saved viz_binary_entropy.png")
