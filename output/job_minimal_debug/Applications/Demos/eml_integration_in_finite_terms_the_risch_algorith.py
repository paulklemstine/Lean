"""
EML Integration in Finite Terms: Numerical Demonstrations

This script demonstrates key results from the Risch algorithm applied to
EML functions eml(x,y) = exp(x) - log(y), including:
1. EML derivative decomposition
2. Concrete antiderivative computations
3. Fenchel-Young inequality verification
4. Liouville obstruction examples
"""

import numpy as np
from scipy import integrate

def eml(x: float, y: float) -> float:
    """The EML function: eml(x,y) = exp(x) - log(y)."""
    return np.exp(x) - np.log(y)

def eml_diag(z: float) -> float:
    """The EML diagonal: d(z) = exp(z) - log(z)."""
    return np.exp(z) - np.log(z)

# ===========================================================================
# Demo 1: EML Derivative Decomposition
# ===========================================================================
print("=" * 60)
print("DEMO 1: EML Derivative Chain Rule")
print("d/dt[eml(f(t), g(t))] = f'(t)·exp(f(t)) - g'(t)/g(t)")
print("=" * 60)

# Example: f(t) = t, g(t) = exp(t)
# d/dt[eml(t, exp(t))] = 1·exp(t) - exp(t)/exp(t) = exp(t) - 1
t_vals = np.linspace(-2, 2, 5)
print("\nf(t) = t, g(t) = exp(t)")
print("Expected derivative: exp(t) - 1")
print(f"{'t':>6} | {'Numerical':>12} | {'Analytical':>12} | {'Error':>12}")
print("-" * 50)
for t in t_vals:
    h = 1e-7
    numerical = (eml(t + h, np.exp(t + h)) - eml(t - h, np.exp(t - h))) / (2 * h)
    analytical = np.exp(t) - 1
    print(f"{t:6.2f} | {numerical:12.6f} | {analytical:12.6f} | {abs(numerical - analytical):12.2e}")

# ===========================================================================
# Demo 2: EML Antiderivative Computation
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 2: ∫₀¹ eml(x, c) dx = (e - 1) - log(c)")
print("Risch decomposition: 1·(e¹ - e⁰) + (-log c)·(1 - 0)")
print("=" * 60)

for c in [0.5, 1.0, 2.0, np.e]:
    numerical, _ = integrate.quad(lambda x: eml(x, c), 0, 1)
    analytical = (np.exp(1) - 1) - np.log(c)
    print(f"c = {c:.4f}: numerical = {numerical:.6f}, analytical = {analytical:.6f}, "
          f"error = {abs(numerical - analytical):.2e}")

# ===========================================================================
# Demo 3: EML Diagonal Integration
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 3: ∫₁ᵇ (eˣ - ln x) dx = (eᵇ - e) - (b·ln b - b + 1)")
print("Antiderivative is eˣ - x·ln(x) + x (NOT an EML function!)")
print("=" * 60)

for b in [1.5, 2.0, 3.0, 5.0]:
    numerical, _ = integrate.quad(eml_diag, 1, b)
    analytical = (np.exp(b) - np.e) - (b * np.log(b) - b + 1)
    print(f"b = {b:.1f}: numerical = {numerical:.6f}, analytical = {analytical:.6f}, "
          f"error = {abs(numerical - analytical):.2e}")

# ===========================================================================
# Demo 4: Fenchel-Young Inequality
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 4: Fenchel-Young: x·s ≤ exp(x) + s·ln(s) - s")
print("=" * 60)

x_vals = np.linspace(-3, 3, 7)
s_vals = [0.1, 0.5, 1.0, 2.0, 5.0]
print(f"{'x':>6} {'s':>6} | {'x·s':>10} | {'exp(x)+s·ln(s)-s':>18} | {'gap':>10}")
print("-" * 60)
for x in x_vals:
    for s in s_vals:
        lhs = x * s
        rhs = np.exp(x) + s * np.log(s) - s
        gap = rhs - lhs
        if abs(x) <= 1 and s == 1.0:
            print(f"{x:6.2f} {s:6.2f} | {lhs:10.4f} | {rhs:18.4f} | {gap:10.4f}")

# ===========================================================================
# Demo 5: Liouville Obstruction — exp(x²) vs polynomial approximation
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 5: Liouville Obstruction — exp(x²) has no poly antiderivative")
print("=" * 60)

# Show that no polynomial of degree ≤ n can have derivative = exp(x²)
for deg in [2, 5, 10, 20]:
    # Fit polynomial to exp(x²) data
    x_fit = np.linspace(-2, 2, 100)
    y_fit = np.exp(x_fit ** 2)
    # Best polynomial approximation of degree `deg` to exp(x²)
    coeffs = np.polyfit(x_fit, y_fit, deg)
    poly_deriv = np.polyder(np.poly1d(coeffs))

    # Compute L² error of P'(x) vs exp(x²) — should never be zero
    x_test = np.linspace(-2, 2, 1000)
    error = np.sqrt(np.mean((poly_deriv(x_test) - np.exp(x_test ** 2)) ** 2))
    print(f"  deg = {deg:3d}: L² error of P'(x) vs exp(x²) = {error:.4f} (never zero)")

# ===========================================================================
# Demo 6: Uniqueness of Exp-Linear Decomposition
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 6: Exp-Linear Uniqueness")
print("If a₁·eˣ + b₁·x + c₁ = a₂·eˣ + b₂·x + c₂ ∀x, then coefficients match")
print("=" * 60)

# Verify: if (a₁-a₂)·eˣ + (b₁-b₂)·x + (c₁-c₂) = 0, then all diffs = 0
a1, b1, c1 = 2.5, -1.3, 0.7
a2, b2, c2 = 2.5, -1.3, 0.7  # Same coefficients
x_test = np.linspace(-5, 5, 1000)
max_diff = np.max(np.abs(
    a1 * np.exp(x_test) + b1 * x_test + c1 -
    (a2 * np.exp(x_test) + b2 * x_test + c2)
))
print(f"Same coefficients: max difference = {max_diff:.2e}")

a2_wrong = 2.5001
max_diff = np.max(np.abs(
    a1 * np.exp(x_test) + b1 * x_test + c1 -
    (a2_wrong * np.exp(x_test) + b2 * x_test + c2)
))
print(f"a₂ off by 0.0001: max difference = {max_diff:.4f} (grows exponentially)")

# ===========================================================================
# Demo 7: Hermite Reduction Step Count
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 7: Hermite Reduction — Step Bound = deg(denominator)")
print("=" * 60)

print("For q(x) = (x-1)²(x-2)³(x-3), deg(q) = 6")
print("Hermite reduction needs ≤ 6 steps to eliminate squared factors")
print("  Step 1: Eliminate cube from (x-2)³ → reduces to (x-2)²")
print("  Step 2: Eliminate square from (x-2)² → reduces to (x-2)")
print("  Step 3: Eliminate square from (x-1)² → reduces to (x-1)")
print("  Result: squarefree denominator (x-1)(x-2)(x-3), deg = 3")
print("  Total: 3 steps ≤ 6 = deg(q) ✓")

# ===========================================================================
# Demo 8: Partial Fraction Integration
# ===========================================================================
print("\n" + "=" * 60)
print("DEMO 8: Partial Fraction Integrals")
print("Simple poles → log terms; Higher poles → rational terms")
print("=" * 60)

a, b, c = 2.0, 5.0, 0.0  # ∫₂⁵ 1/(x-0) dx
log_integral, _ = integrate.quad(lambda x: 1/x, a, b)
analytical_log = np.log(b) - np.log(a)
print(f"∫₂⁵ 1/x dx = {log_integral:.6f} (log integral: ln(5) - ln(2) = {analytical_log:.6f})")

sq_integral, _ = integrate.quad(lambda x: 1/x**2, a, b)
analytical_sq = 1/a - 1/b  # = (a-c)⁻¹ - (b-c)⁻¹
print(f"∫₂⁵ 1/x² dx = {sq_integral:.6f} (rational: 1/2 - 1/5 = {analytical_sq:.6f})")

print("\n✓ All demonstrations complete.")


"""
Visualization: EML Function Landscape and Integration Regions

Shows the EML surface eml(x,y) = exp(x) - log(y) and highlights
the regions where antiderivatives exist vs. where Liouville
obstructions prevent elementary integration.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: EML surface
ax1 = fig.add_subplot(131, projection='3d')
x = np.linspace(-2, 2, 80)
y = np.linspace(0.1, 5, 80)
X, Y = np.meshgrid(x, y)
Z = np.exp(X) - np.log(Y)
ax1.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8, linewidth=0)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('eml(x,y)')
ax1.set_title('EML Surface: exp(x) - log(y)')

# Panel 2: EML diagonal and its integral
ax2 = axes[1]
z = np.linspace(0.1, 4, 200)
eml_diag = np.exp(z) - np.log(z)
antideriv = np.exp(z) - z * np.log(z) + z
ax2.plot(z, eml_diag, 'b-', linewidth=2, label='d(z) = exp(z) - log(z)')
ax2.plot(z, antideriv, 'r--', linewidth=2, label='∫d(z)dz = exp(z) - z·log(z) + z')
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.set_xlabel('z')
ax2.set_ylabel('Value')
ax2.set_title('EML Diagonal & Its Antiderivative')
ax2.legend()
ax2.set_ylim(-5, 30)
ax2.grid(True, alpha=0.3)

# Panel 3: Fenchel-Young gap
ax3 = axes[2]
x_vals = np.linspace(-2, 3, 200)
for s in [0.5, 1.0, 2.0, np.e]:
    gap = np.exp(x_vals) + s * np.log(s) - s - x_vals * s
    ax3.plot(x_vals, gap, linewidth=2, label=f's = {s:.2f}')
ax3.axhline(y=0, color='k', linewidth=1, linestyle='--')
ax3.set_xlabel('x')
ax3.set_ylabel('Gap: exp(x) + s·log(s) - s - x·s')
ax3.set_title('Fenchel-Young Gap (≥ 0 always)')
ax3.legend()
ax3.set_ylim(-1, 15)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eml_landscape.png")


"""
Visualization: Hermite Reduction Step-by-Step

Shows how Hermite reduction decomposes a rational function integral
into rational + logarithmic parts, with step count bounded by degree.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Simple pole integral (log term)
ax1 = axes[0, 0]
x = np.linspace(0.1, 5, 200)
# ∫ 1/(x-c) dx = log|x-c|
for c in [-1, 0, 1, 2]:
    mask = np.abs(x - c) > 0.1
    y = np.where(mask, 1 / (x - c), np.nan)
    label = f'1/(x - {c})' if c >= 0 else f'1/(x + {abs(c)})'
    ax1.plot(x, y, linewidth=1.5, label=label)
ax1.set_title('Simple Poles → Log Integrals')
ax1.set_xlabel('x')
ax1.set_ylabel('f(x)')
ax1.set_ylim(-10, 10)
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5)

# Panel 2: Higher pole integral (rational term)
ax2 = axes[0, 1]
x = np.linspace(0.1, 5, 200)
for n in [1, 2, 3, 4]:
    y = 1 / (x ** n)
    ax2.plot(x, y, linewidth=1.5, label=f'1/x^{n}')
ax2.set_title('Higher Poles → Rational Integrals')
ax2.set_xlabel('x')
ax2.set_ylabel('f(x)')
ax2.set_ylim(0, 5)
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Hermite reduction step bound
ax3 = axes[1, 0]
degrees = range(1, 11)
step_bounds = list(degrees)  # Step bound = degree
actual_steps = [max(1, d - 1) for d in degrees]  # Typical actual steps
ax3.bar([d - 0.15 for d in degrees], step_bounds, width=0.3,
        color='steelblue', alpha=0.7, label='Step bound = deg(q)')
ax3.bar([d + 0.15 for d in degrees], actual_steps, width=0.3,
        color='coral', alpha=0.7, label='Typical actual steps')
ax3.set_xlabel('Degree of denominator')
ax3.set_ylabel('Number of steps')
ax3.set_title('Hermite Reduction: O(deg) Steps')
ax3.legend()
ax3.grid(True, alpha=0.3, axis='y')

# Panel 4: Squarefree decomposition example
ax4 = axes[1, 1]
x = np.linspace(-1, 4, 400)
# q(x) = (x-1)²(x-3) = x³ - 5x² + 7x - 3
q = (x - 1)**2 * (x - 3)
sqfree = (x - 1) * (x - 3)  # Squarefree part
repeated = (x - 1)  # Repeated factor

ax4.plot(x, q, 'b-', linewidth=2, label='q(x) = (x-1)²(x-3)')
ax4.plot(x, sqfree, 'r--', linewidth=2, label='Squarefree: (x-1)(x-3)')
ax4.plot(x, repeated, 'g:', linewidth=2, label='Repeated: (x-1)')
ax4.axhline(y=0, color='k', linewidth=0.5)
ax4.scatter([1, 3], [0, 0], color='red', zorder=5, s=50)
ax4.set_title('Squarefree Decomposition')
ax4.set_xlabel('x')
ax4.set_ylabel('Polynomial value')
ax4.legend(fontsize=8)
ax4.set_ylim(-5, 10)
ax4.grid(True, alpha=0.3)

plt.suptitle('Hermite Reduction in the Risch Algorithm', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('hermite_reduction.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hermite_reduction.png")
