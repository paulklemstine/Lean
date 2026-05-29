"""
Visualization: Spectral Obstruction and Lorentzian Signature

Shows the geometric meaning of Lorentzian signature for 2×2 matrices:
- The quadratic form Q(v) = a*v₁² + 2b*v₁*v₂ + c*v₂² defines a conic
- Lorentzian signature ≡ at most one positive eigenvalue ≡ the conic
  has a hyperbolic or degenerate shape
- Positive definite ≡ two positive eigenvalues ≡ the conic is elliptic
  → NOT Lorentzian (pos_def_not_lorentzian theorem)

Also illustrates the reversed Cauchy-Schwarz inequality for Lorentzian forms.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def quadratic_form_2d(a, b, c, v1, v2):
    """Q(v) = a*v1^2 + 2*b*v1*v2 + c*v2^2."""
    return a * v1**2 + 2 * b * v1 * v2 + c * v2**2


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ── Panel 1: Positive definite (NOT Lorentzian) ──
ax = axes[0]
v = np.linspace(-2, 2, 400)
V1, V2 = np.meshgrid(v, v)
a, b, c = 2.0, 0.5, 2.0  # det = 4 - 0.25 = 3.75 > 0
Q = quadratic_form_2d(a, b, c, V1, V2)

contour = ax.contourf(V1, V2, Q, levels=20, cmap='RdYlBu_r', alpha=0.8)
ax.contour(V1, V2, Q, levels=[0], colors='black', linewidths=2)
ax.set_title('Positive Definite\n(NOT Lorentzian)', fontsize=13, fontweight='bold')
ax.set_xlabel('v₁')
ax.set_ylabel('v₂')
ax.set_aspect('equal')
ax.text(0.05, 0.95, f'a={a}, b={b}, c={c}\ndet={a*c-b**2:.2f} > 0\nQ > 0 everywhere',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
plt.colorbar(contour, ax=ax, shrink=0.8, label='Q(v)')

# ── Panel 2: Lorentzian signature (Minkowski) ──
ax = axes[1]
a, b, c = 1.0, 0.0, -1.0  # det = -1 < 0, eigenvalues 1, -1
Q = quadratic_form_2d(a, b, c, V1, V2)

contour = ax.contourf(V1, V2, Q, levels=np.linspace(-3, 3, 25),
                      cmap='RdYlBu_r', alpha=0.8)
ax.contour(V1, V2, Q, levels=[0], colors='black', linewidths=2)

# Show vectors in the positive cone
x = np.array([1.5, 0.5])  # Q(x) = 1.5² - 0.5² = 2 > 0
y = np.array([1.8, 0.3])  # Q(y) = 1.8² - 0.3² > 0
ax.annotate('', xy=x, xytext=[0, 0],
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax.annotate('', xy=y, xytext=[0, 0],
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.text(x[0]+0.1, x[1]+0.1, 'x', color='blue', fontsize=12, fontweight='bold')
ax.text(y[0]+0.1, y[1]+0.1, 'y', color='green', fontsize=12, fontweight='bold')

ax.set_title('Lorentzian Signature\n(Minkowski metric)', fontsize=13, fontweight='bold')
ax.set_xlabel('v₁')
ax.set_ylabel('v₂')
ax.set_aspect('equal')
ax.text(0.05, 0.95, f'a={a}, b={b}, c={c}\ndet={a*c-b**2:.0f} < 0\nQ > 0 in light cone',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
plt.colorbar(contour, ax=ax, shrink=0.8, label='Q(v)')

# ── Panel 3: Phase diagram of signature types ──
ax = axes[2]
a_vals = np.linspace(-2, 3, 200)
c_vals = np.linspace(-2, 3, 200)
A_grid, C_grid = np.meshgrid(a_vals, c_vals)

# For b = 0: det = a*c, eigenvalues = a, c
# Lorentzian iff at most one positive eigenvalue
n_positive = (A_grid > 0).astype(int) + (C_grid > 0).astype(int)

colors = np.zeros((*A_grid.shape, 3))
# Both negative (0 positive): blue
colors[n_positive == 0] = [0.2, 0.4, 0.8]
# Exactly one positive (Lorentzian): green
colors[n_positive == 1] = [0.2, 0.7, 0.3]
# Both positive (NOT Lorentzian): red
colors[n_positive == 2] = [0.8, 0.2, 0.2]

ax.imshow(colors, extent=[a_vals[0], a_vals[-1], c_vals[0], c_vals[-1]],
          origin='lower', aspect='auto')

ax.axhline(y=0, color='black', linewidth=0.5, alpha=0.5)
ax.axvline(x=0, color='black', linewidth=0.5, alpha=0.5)

# Labels
ax.text(1.5, 1.5, 'NOT\nLorentzian\n(pos. def.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(-1, 1.5, 'Lorentzian\n(1 pos. eig.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(1.5, -1, 'Lorentzian\n(1 pos. eig.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(-1, -1, 'Neg. semi-def.\n(0 pos. eig.)',
        fontsize=9, ha='center', color='white', fontweight='bold')

ax.set_xlabel('Eigenvalue λ₁ (= a for diagonal)', fontsize=11)
ax.set_ylabel('Eigenvalue λ₂ (= c for diagonal)', fontsize=11)
ax.set_title('Signature Phase Diagram\n(diagonal matrices, b=0)', fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_obstruction.png")
