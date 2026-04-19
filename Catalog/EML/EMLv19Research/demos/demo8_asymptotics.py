"""
Demo 8: EML Asymptotics and Bimonotonicity

V19 proves:
- eml(x, y) → -log(y) as x → -∞
- eml(x, y) → -∞ as y → +∞
- eml is strictly increasing in x AND strictly decreasing in y (bimonotone)
"""

import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Asymptotics in x
ax = axes[0]
x = np.linspace(-10, 3, 500)
for y_val in [0.5, 1, 2, 5]:
    ax.plot(x, eml(x, y_val), label=f'y = {y_val}')
    ax.axhline(y=-np.log(y_val), linestyle='--', alpha=0.3,
               color=ax.get_lines()[-1].get_color())
ax.set_xlabel('x')
ax.set_ylabel('eml(x, y)')
ax.set_title('x → -∞: eml → -log(y)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Asymptotics in y
ax = axes[1]
y = np.linspace(0.01, 100, 500)
for x_val in [-1, 0, 1, 2]:
    ax.plot(y, eml(x_val, y), label=f'x = {x_val}')
ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax.set_xlabel('y')
ax.set_ylabel('eml(x, y)')
ax.set_title('y → +∞: eml → -∞')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Bimonotonicity visualization
ax = axes[2]
x = np.linspace(-1, 2, 100)
y = np.linspace(0.5, 5, 100)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)
c = ax.contourf(X, Y, Z, levels=20, cmap='RdYlGn_r')
plt.colorbar(c, ax=ax)
# Draw arrows showing increasing x and decreasing y both increase eml
ax.annotate('', xy=(1.5, 1), xytext=(0.5, 1),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax.annotate('', xy=(1, 0.8), xytext=(1, 3),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax.text(1, 0.6, '↑x → ↑eml', color='blue', fontsize=10, ha='center')
ax.text(0.3, 2, '↓y → ↑eml', color='red', fontsize=10, ha='center', rotation=90)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Bimonotonicity: ↑x, ↓y → ↑eml')

plt.suptitle('V19: EML Asymptotics & Bimonotonicity', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo8_asymptotics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 8 saved: demo8_asymptotics.png")
