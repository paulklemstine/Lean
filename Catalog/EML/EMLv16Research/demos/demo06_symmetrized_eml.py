"""
Demo 6: Symmetrized EML Lower Bound
S(a,b) = (a - ln(b)) + (b - ln(a)) = a + b - ln(a) - ln(b) ≥ 2,
with equality iff a = b = 1.
"""
import numpy as np
import matplotlib.pyplot as plt

def symmetrized_eml(a, b):
    return a + b - np.log(a) - np.log(b)

a = np.linspace(0.1, 5, 300)
b = np.linspace(0.1, 5, 300)
A, B = np.meshgrid(a, b)
S = symmetrized_eml(A, B)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Contour plot
ax = axes[0]
levels = [2, 2.5, 3, 4, 5, 6, 8, 10]
cs = ax.contourf(A, B, S, levels=50, cmap='YlOrRd')
ax.contour(A, B, S, levels=[2], colors='black', linewidths=3)
ax.plot(1, 1, 'w*', markersize=15, markeredgecolor='black', label='Minimum (1,1), S=2')
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.set_title('Symmetrized EML: S(a,b) = a+b-ln(a)-ln(b)')
ax.legend(fontsize=10)
fig.colorbar(cs, ax=ax)
ax.grid(True, alpha=0.3)

# Right: Cross-sections
ax = axes[1]
a_range = np.linspace(0.1, 5, 500)
for b_val in [0.5, 1, 2, 3]:
    ax.plot(a_range, symmetrized_eml(a_range, b_val), linewidth=2, label=f'b = {b_val}')
ax.axhline(y=2, color='k', linestyle='--', linewidth=1, label='S = 2 (minimum)')
ax.set_xlabel('a')
ax.set_ylabel('S(a, b)')
ax.set_title('Cross-sections of Symmetrized EML')
ax.legend()
ax.set_ylim(0, 12)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('symmetrized_eml.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved symmetrized_eml.png")
