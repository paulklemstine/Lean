"""
Demo 5: σ-EML Bijectivity and Inverse

V19 proves σ-EML is bijective:
- Injective (from strict monotonicity)
- Surjective (from continuity + limits at ±∞)

This means σ-EML has a well-defined inverse function σ⁻¹.
The inverse has interesting properties as a "compression" function.
"""

import numpy as np
from scipy.optimize import brentq
import matplotlib.pyplot as plt

def sigma_eml(x):
    return np.exp(x) - np.log(1 + np.exp(-x))

def sigma_eml_inv(y, tol=1e-12):
    """Numerically compute σ-EML inverse."""
    # Find x such that σ(x) = y
    # For large y: x ≈ log(y), for small y: x ≈ y
    lo = min(y - 10, -100)
    hi = max(y + 10, 100)
    return brentq(lambda x: sigma_eml(x) - y, lo, hi, xtol=tol)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: σ-EML and its inverse
ax = axes[0]
x = np.linspace(-3, 3, 500)
y = sigma_eml(x)
ax.plot(x, y, 'b-', linewidth=2, label='σ-EML(x)')
ax.plot(y, x, 'r-', linewidth=2, label='σ⁻¹-EML(y)')
ax.plot(x, x, 'k--', alpha=0.3, label='y = x')
ax.set_xlabel('x / y')
ax.set_ylabel('σ(x) / σ⁻¹(y)')
ax.set_title('σ-EML and Its Inverse')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_xlim(-3, 6)
ax.set_ylim(-3, 6)

# Plot 2: Derivative of σ-EML (always positive → bijective)
ax = axes[1]
deriv = np.exp(x) + np.exp(-x) / (1 + np.exp(-x))
ax.plot(x, deriv, 'b-', linewidth=2, label="σ'(x) = eˣ + e⁻ˣ/(1+e⁻ˣ)")
ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax.axhline(y=1, color='r', linestyle='--', alpha=0.3, label='y = 1')
ax.fill_between(x, 0, deriv, alpha=0.1, color='green')
ax.set_xlabel('x')
ax.set_ylabel("σ'(x)")
ax.set_title("Derivative Always > 0 (Injective)")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Limits demonstrating surjectivity
ax = axes[2]
x_wide = np.linspace(-10, 5, 1000)
y_wide = sigma_eml(x_wide)
ax.plot(x_wide, y_wide, 'b-', linewidth=2)
ax.annotate('→ +∞', xy=(4.5, sigma_eml(4.5)), fontsize=12, color='red',
            arrowprops=dict(arrowstyle='->', color='red'),
            xytext=(3, sigma_eml(4.5)+20))
ax.annotate('→ -∞', xy=(-9, sigma_eml(-9)), fontsize=12, color='red',
            arrowprops=dict(arrowstyle='->', color='red'),
            xytext=(-7, sigma_eml(-9)+5))
ax.set_xlabel('x')
ax.set_ylabel('σ(x)')
ax.set_title('Surjective: Range = ℝ')
ax.grid(True, alpha=0.3)

plt.suptitle('V19: σ-EML is Bijective (ℝ → ℝ)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo5_sigma_eml_inverse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 5 saved: demo5_sigma_eml_inverse.png")
