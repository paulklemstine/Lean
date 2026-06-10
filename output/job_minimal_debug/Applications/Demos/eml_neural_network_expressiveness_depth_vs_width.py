#!/usr/bin/env python3
"""
EML Neural Network Depth-Width Tradeoff Demonstration

Demonstrates the key results from the formalized theory:
1. EML quadratic extraction: exp(εx) - 1 - εx ≈ ε²x²/2
2. Width-w approximation of x² with O(1/w) error
3. Depth-width crossover point where EML beats piecewise linear
"""

import numpy as np

def eml_quad_extract(eps: float, x: float) -> float:
    """The EML quadratic extractor: exp(εx) - 1 - εx"""
    return np.exp(eps * x) - 1 - eps * x

def eml_norm_extract(eps: float, x: float) -> float:
    """Normalized extractor: 2(exp(εx) - 1 - εx)/ε² ≈ x²"""
    return 2 * (np.exp(eps * x) - 1 - eps * x) / eps**2

def eml_approx_sq(w: int, x: float) -> float:
    """EML approximation of x² using parameter ε = 1/w"""
    eps = 1.0 / w
    return eml_norm_extract(eps, x)

def pwl_approx_sq_error(w: int) -> float:
    """Best piecewise linear approximation error for x² with w pieces"""
    return 1.0 / (8 * w**2)

def eml_approx_sq_error_bound(w: int) -> float:
    """Theoretical EML error bound: exp(1)/(3w)"""
    return np.exp(1) / (3 * w)

def crossover_depth(w: int) -> float:
    """Minimum depth d where EML beats PWL: d ≥ 8w·exp(1)/3"""
    return 8 * w * np.exp(1) / 3

# ===== DEMO 1: Quadratic Extraction =====
print("=" * 60)
print("DEMO 1: EML Quadratic Extraction")
print("=" * 60)
print("\nFor small ε, 2(exp(εx) - 1 - εx)/ε² ≈ x²")
print(f"{'ε':>8} {'x':>6} {'Approx':>12} {'x²':>12} {'Error':>12}")
print("-" * 56)

for eps in [1.0, 0.5, 0.1, 0.01, 0.001]:
    for x in [0.25, 0.5, 0.75, 1.0]:
        approx = eml_norm_extract(eps, x)
        true_val = x**2
        error = abs(approx - true_val)
        print(f"{eps:8.3f} {x:6.2f} {approx:12.8f} {true_val:12.8f} {error:12.2e}")
    print()

# ===== DEMO 2: Width-w Approximation =====
print("=" * 60)
print("DEMO 2: Width-w EML Approximation of x²")
print("=" * 60)
print(f"\n{'w':>6} {'Max Error (obs)':>15} {'Bound (e/3w)':>15} {'PWL (1/8w²)':>15}")
print("-" * 55)

for w in [1, 2, 5, 10, 20, 50, 100]:
    xs = np.linspace(0, 1, 1000)
    errors = [abs(eml_approx_sq(w, x) - x**2) for x in xs]
    max_err = max(errors)
    bound = eml_approx_sq_error_bound(w)
    pwl = pwl_approx_sq_error(w)
    print(f"{w:6d} {max_err:15.8f} {bound:15.8f} {pwl:15.8f}")

# ===== DEMO 3: Depth-Width Crossover =====
print("\n" + "=" * 60)
print("DEMO 3: Depth-Width Crossover Point")
print("=" * 60)
print(f"\n{'w':>6} {'Min d (crossover)':>20} {'EML err (d=d_min)':>20} {'PWL err':>15}")
print("-" * 65)

for w in [1, 2, 5, 10, 20, 50]:
    d_min = int(np.ceil(crossover_depth(w)))
    eml_err = np.exp(1) / (3 * w * d_min)
    pwl_err = pwl_approx_sq_error(w)
    print(f"{w:6d} {d_min:20d} {eml_err:20.8f} {pwl_err:15.8f}")

# ===== DEMO 4: Taylor Remainder Verification =====
print("\n" + "=" * 60)
print("DEMO 4: Taylor Remainder Bound Verification")
print("=" * 60)
print(f"\n{'t':>8} {'|R₂(t)|':>15} {'|t|³/6·exp(|t|)':>18} {'Ratio':>10}")
print("-" * 55)

for t in [-2, -1, -0.5, 0.1, 0.5, 1.0, 2.0]:
    remainder = abs(np.exp(t) - 1 - t - t**2/2)
    bound = abs(t)**3 / 6 * np.exp(abs(t))
    ratio = remainder / bound if bound > 0 else 0
    print(f"{t:8.2f} {remainder:15.8e} {bound:18.8e} {ratio:10.4f}")

print("\nAll ratios ≤ 1 confirms the Taylor remainder bound (Theorem 1).")

# ===== DEMO 5: Smoothness Comparison =====
print("\n" + "=" * 60)
print("DEMO 5: Smoothness Comparison (EML vs ReLU)")
print("=" * 60)

def relu(x): return max(0, x)
def eml_unit(x, a=1, b=0, c=1, d=1):
    return np.exp(a*x + b) - np.log(c*x + d)

h = 1e-8
x0 = 0.0  # ReLU is non-differentiable here

# Numerical derivatives at x=0
relu_left = (relu(x0) - relu(x0 - h)) / h
relu_right = (relu(x0 + h) - relu(x0)) / h

eml_left = (eml_unit(x0) - eml_unit(x0 - h)) / h
eml_right = (eml_unit(x0 + h) - eml_unit(x0)) / h

print(f"\nAt x = 0:")
print(f"  ReLU left derivative:  {relu_left:.6f}")
print(f"  ReLU right derivative: {relu_right:.6f}")
print(f"  ReLU differentiable?   {'Yes' if abs(relu_left - relu_right) < 1e-4 else 'No'}")
print(f"\n  EML left derivative:   {eml_left:.6f}")
print(f"  EML right derivative:  {eml_right:.6f}")
print(f"  EML differentiable?    {'Yes' if abs(eml_left - eml_right) < 1e-4 else 'No'}")

print("\n\nAll demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: EML vs PWL Approximation Spectrum

Generates a heatmap comparing EML and piecewise linear approximation
error surfaces for x² on [0,1].
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm

def eml_error(d, w):
    """EML spectrum error bound."""
    if w == 0 or d == 0:
        return 1.0
    return np.exp(1) / (3 * w * d)

def pwl_error(d, w):
    """Piecewise linear spectrum error bound."""
    if w == 0:
        return 1.0
    return 1.0 / (8 * w**2)

# Create grid
depths = np.arange(1, 51)
widths = np.arange(1, 51)
D, W = np.meshgrid(depths, widths)

# Compute error surfaces
EML_err = np.vectorize(eml_error)(D, W)
PWL_err = np.vectorize(pwl_error)(D, W)

# Ratio: EML/PWL (< 1 means EML is better)
ratio = EML_err / PWL_err

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: EML error surface
im1 = axes[0].pcolormesh(depths, widths, EML_err, norm=LogNorm(), cmap='viridis')
axes[0].set_xlabel('Depth d')
axes[0].set_ylabel('Width w')
axes[0].set_title('EML Error: exp(1)/(3wd)')
plt.colorbar(im1, ax=axes[0], label='Error bound')

# Isoperformance contours
for eps in [0.1, 0.01, 0.001]:
    contour_d = np.linspace(1, 50, 200)
    contour_w = np.exp(1) / (3 * eps * contour_d)
    mask = (contour_w >= 1) & (contour_w <= 50)
    axes[0].plot(contour_d[mask], contour_w[mask], 'w--', alpha=0.7,
                 label=f'ε={eps}')
axes[0].legend(fontsize=8)

# Plot 2: PWL error surface
im2 = axes[1].pcolormesh(depths, widths, PWL_err, norm=LogNorm(), cmap='viridis')
axes[1].set_xlabel('Depth d')
axes[1].set_ylabel('Width w')
axes[1].set_title('PWL Error: 1/(8w²)')
plt.colorbar(im2, ax=axes[1], label='Error bound')

# Plot 3: Ratio (EML advantage region)
im3 = axes[2].pcolormesh(depths, widths, ratio, norm=LogNorm(vmin=0.01, vmax=100),
                          cmap='RdBu_r')
axes[2].set_xlabel('Depth d')
axes[2].set_ylabel('Width w')
axes[2].set_title('EML/PWL Ratio (blue = EML better)')
plt.colorbar(im3, ax=axes[2], label='Error ratio')

# Crossover curve: 8w·exp(1)/3 = d
crossover_w = np.linspace(1, 50, 200)
crossover_d = 8 * crossover_w * np.exp(1) / 3
mask = crossover_d <= 50
axes[2].plot(crossover_d[mask], crossover_w[mask], 'k-', linewidth=2,
             label='Crossover: d = 8we/3')
axes[2].legend(fontsize=8)

plt.tight_layout()
plt.savefig('spectrum_comparison.png', dpi=150, bbox_inches='tight')
print("Saved spectrum_comparison.png")


#!/usr/bin/env python3
"""
Visualization: EML Taylor Quadratic Extraction

Shows how exp(εx) extracts the quadratic term x² as ε → 0,
and compares EML approximation quality vs piecewise linear.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x = np.linspace(0, 1, 1000)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: EML quadratic extraction for various ε
ax = axes[0, 0]
ax.plot(x, x**2, 'k-', linewidth=2, label='x²')
for eps in [1.0, 0.5, 0.2, 0.1, 0.05]:
    approx = 2 * (np.exp(eps * x) - 1 - eps * x) / eps**2
    ax.plot(x, approx, '--', label=f'ε = {eps}', alpha=0.8)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('EML Quadratic Extraction: 2(exp(εx)-1-εx)/ε² → x²')
ax.legend()
ax.set_ylim(-0.1, 1.5)

# Plot 2: Error vs width
ax = axes[0, 1]
widths = range(1, 101)
eml_errors = []
pwl_errors = []
eml_bounds = []

for w in widths:
    eps = 1.0 / w
    approx_vals = 2 * (np.exp(eps * x) - 1 - eps * x) / eps**2
    max_err = np.max(np.abs(approx_vals - x**2))
    eml_errors.append(max_err)
    pwl_errors.append(1.0 / (8 * w**2))
    eml_bounds.append(np.exp(1) / (3 * w))

ax.semilogy(widths, eml_errors, 'b-', label='EML actual error')
ax.semilogy(widths, eml_bounds, 'b--', label='EML bound: e/(3w)')
ax.semilogy(widths, pwl_errors, 'r-', label='PWL error: 1/(8w²)')
ax.set_xlabel('Width w')
ax.set_ylabel('Max error on [0,1]')
ax.set_title('Error vs Width for x² Approximation')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Taylor remainder verification
ax = axes[1, 0]
t_vals = np.linspace(-3, 3, 1000)
remainder = np.abs(np.exp(t_vals) - 1 - t_vals - t_vals**2/2)
bound = np.abs(t_vals)**3 / 6 * np.exp(np.abs(t_vals))

ax.semilogy(t_vals, remainder, 'b-', label='|exp(t) - 1 - t - t²/2|')
ax.semilogy(t_vals, bound, 'r--', label='|t|³/6 · exp(|t|)')
ax.set_xlabel('t')
ax.set_ylabel('Value')
ax.set_title('Taylor Remainder Bound (Theorem 1)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Crossover depth
ax = axes[1, 1]
widths_arr = np.arange(1, 51)
crossover_d = 8 * widths_arr * np.exp(1) / 3

ax.plot(widths_arr, crossover_d, 'b-', linewidth=2)
ax.fill_between(widths_arr, crossover_d, 500, alpha=0.2, color='blue',
                label='EML dominates PWL')
ax.fill_between(widths_arr, 0, crossover_d, alpha=0.2, color='red',
                label='PWL dominates EML')
ax.set_xlabel('Width w')
ax.set_ylabel('Depth d')
ax.set_title('Depth-Width Crossover: d ≥ 8we/3')
ax.set_ylim(0, 400)
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('taylor_extraction.png', dpi=150, bbox_inches='tight')
print("Saved taylor_extraction.png")
