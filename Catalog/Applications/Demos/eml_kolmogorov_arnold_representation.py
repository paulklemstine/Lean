#!/usr/bin/env python3
"""
EML Spectral Algebra: Numerical Demonstrations
===============================================

Demonstrates the key results of the EML Spectral Algebra theory:
1. Monomial EML-KA decomposition correctness
2. Polynomial reconstruction via EML-KA
3. AM-GM inequality through EML encoding
4. LogSumExp bounds
5. Fenchel-Young inequality verification
"""

import math
import numpy as np

def eml_op_exp(x): return math.exp(x)
def eml_op_log(x): return math.log(x)
def eml_op_affine(a, b, x): return a * x + b

def eval_chain(chain, x):
    """Evaluate an EML chain (list of ops applied left-to-right, head=outermost)."""
    result = x
    for op in reversed(chain):
        if op[0] == 'exp':
            result = math.exp(result)
        elif op[0] == 'log':
            result = math.log(result)
        elif op[0] == 'affine':
            result = op[1] * result + op[2]
    return result

def emlka_eval(phi1_chains, phi2_chains, Phi_chains, x, y):
    """Evaluate an EML-KA decomposition at (x, y)."""
    total = 0.0
    Q = len(phi1_chains)
    for q in range(Q):
        inner = eval_chain(phi1_chains[q], x) + eval_chain(phi2_chains[q], y)
        total += eval_chain(Phi_chains[q], inner)
    return total


print("=" * 70)
print("EML SPECTRAL ALGEBRA — NUMERICAL DEMONSTRATIONS")
print("=" * 70)

# Demo 1: Multiplication x*y = exp(log(x) + log(y))
print("\n§1. Multiplication via EML-KA (1 term)")
print("-" * 50)
mul_phi1 = [[('log',)]]
mul_phi2 = [[('log',)]]
mul_Phi  = [[('exp',)]]

test_pairs = [(2, 3), (0.5, 4), (1.7, 2.3), (100, 0.01)]
for x, y in test_pairs:
    result = emlka_eval(mul_phi1, mul_phi2, mul_Phi, x, y)
    exact = x * y
    print(f"  x={x}, y={y}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

# Demo 2: Monomial x^a * y^b = exp(a*log(x) + b*log(y))
print("\n§2. Monomial x^2 * y^3 via EML-KA (1 term)")
print("-" * 50)
a, b = 2, 3
mono_phi1 = [[('affine', a, 0), ('log',)]]
mono_phi2 = [[('affine', b, 0), ('log',)]]
mono_Phi  = [[('exp',)]]

for x, y in [(1, 1), (2, 3), (0.5, 2), (1.5, 0.7)]:
    result = emlka_eval(mono_phi1, mono_phi2, mono_Phi, x, y)
    exact = x**a * y**b
    print(f"  x={x}, y={y}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

# Demo 3: Polynomial p(x,y) = 3x^2*y + 2x*y^2 - x*y via EML-KA (3 terms)
print("\n§3. Polynomial 3x²y + 2xy² - xy via EML-KA (3 terms)")
print("-" * 50)
poly_phi1 = [
    [('affine', 2, 0), ('log',)],  # 2*log(x)
    [('affine', 1, 0), ('log',)],  # log(x)
    [('affine', 1, 0), ('log',)],  # log(x)
]
poly_phi2 = [
    [('affine', 1, 0), ('log',)],  # log(y)
    [('affine', 2, 0), ('log',)],  # 2*log(y)
    [('affine', 1, 0), ('log',)],  # log(y)
]
poly_Phi = [
    [('affine', 3, 0), ('exp',)],   # 3*exp(·)
    [('affine', 2, 0), ('exp',)],   # 2*exp(·)
    [('affine', -1, 0), ('exp',)],  # -1*exp(·)
]

for x, y in [(1, 1), (2, 3), (1.5, 2), (0.5, 3)]:
    result = emlka_eval(poly_phi1, poly_phi2, poly_Phi, x, y)
    exact = 3*x**2*y + 2*x*y**2 - x*y
    print(f"  x={x}, y={y}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

# Demo 4: AM-GM via EML spectral perspective
print("\n§4. AM-GM via EML: exp((log x + log y)/2) ≤ (x+y)/2")
print("-" * 50)
for x, y in [(1, 4), (2, 8), (0.5, 2), (3, 3), (1, 100)]:
    geom = math.exp((math.log(x) + math.log(y)) / 2)
    arith = (x + y) / 2
    gap = arith - geom
    print(f"  x={x}, y={y}: GM = {geom:.6f}, AM = {arith:.6f}, "
          f"gap = {gap:.6f} (≥ 0: {gap >= -1e-10})")

# Demo 5: Geometric mean has complexity 1
print("\n§5. Geometric Mean √(xy) via EML-KA (1 term)")
print("-" * 50)
gm_phi1 = [[('affine', 0.5, 0), ('log',)]]
gm_phi2 = [[('affine', 0.5, 0), ('log',)]]
gm_Phi  = [[('exp',)]]

for x, y in [(4, 9), (1, 16), (2, 8), (3, 12)]:
    result = emlka_eval(gm_phi1, gm_phi2, gm_Phi, x, y)
    exact = math.sqrt(x * y)
    print(f"  x={x}, y={y}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

# Demo 6: LogSumExp bounds
print("\n§6. LogSumExp bounds: x ≤ LSE(x,y) ≤ max(x,y) + log(2)")
print("-" * 50)
for x, y in [(0, 0), (1, 2), (-1, 3), (10, -5), (5, 5)]:
    lse = math.log(math.exp(x) + math.exp(y))
    lb = x
    ub = max(x, y) + math.log(2)
    print(f"  x={x}, y={y}: lb={lb:.4f} ≤ LSE={lse:.4f} ≤ ub={ub:.4f} "
          f"(valid: {lb <= lse + 1e-10 and lse <= ub + 1e-10})")

# Demo 7: Fenchel-Young inequality
print("\n§7. Fenchel-Young: x·s ≤ exp(x) + s·log(s) - s for s > 0")
print("-" * 50)
for x, s in [(0, 1), (1, 1), (2, 0.5), (-1, 3), (0, math.e)]:
    lhs = x * s
    rhs = math.exp(x) + s * math.log(s) - s
    gap = rhs - lhs
    print(f"  x={x:.2f}, s={s:.4f}: lhs = {lhs:.6f}, rhs = {rhs:.6f}, "
          f"gap = {gap:.6f} (≥ 0: {gap >= -1e-10})")

# Demo 8: n-variable monomial
print("\n§8. n-Variable Monomial: x₁² · x₂³ · x₃ via EML-KA (1 term)")
print("-" * 50)
n = 3
exponents = [2, 3, 1]
xs_list = [[2, 3, 4], [1.5, 2, 0.5], [1, 1, 1], [0.5, 0.5, 0.5]]
for xs in xs_list:
    # exp(Σ aᵢ · log(xᵢ))
    inner_sum = sum(exponents[i] * math.log(xs[i]) for i in range(n))
    result = math.exp(inner_sum)
    exact = 1.0
    for i in range(n):
        exact *= xs[i] ** exponents[i]
    print(f"  xs={xs}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

# Demo 9: Complexity spectrum
print("\n§9. EML-KA Complexity Spectrum")
print("-" * 50)
print("  Complexity 1: multiplication, division, all monomials, geometric mean")
print("  Complexity 2: addition, subtraction")
print("  Complexity M: polynomials with M monomials")
print("  Complexity Q₁+Q₂: sum of C_{Q₁} and C_{Q₂} functions")
print("  Key insight: multiplication (C₁) is SIMPLER than addition (C₂) in EML-KA!")

# Demo 10: Division x/y = exp(log(x) - log(y))
print("\n§10. Division via EML-KA (1 term)")
print("-" * 50)
div_phi1 = [[('log',)]]
div_phi2 = [[('affine', -1, 0), ('log',)]]
div_Phi  = [[('exp',)]]

for x, y in [(6, 3), (10, 4), (1, 7), (100, 3)]:
    result = emlka_eval(div_phi1, div_phi2, div_Phi, x, y)
    exact = x / y
    print(f"  x={x}, y={y}: EML-KA = {result:.10f}, exact = {exact:.10f}, "
          f"error = {abs(result - exact):.2e}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: EML-KA Spectral Complexity Landscape
====================================================

Visualizes the EML-KA complexity of various function classes,
showing how the spectral algebra stratifies bivariate functions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def eval_mul_emlka(x, y):
    return np.exp(np.log(x) + np.log(y))

def eval_monomial_emlka(x, y, a, b):
    return np.exp(a * np.log(x) + b * np.log(y))

def eval_poly_emlka(x, y, coeffs, exps_a, exps_b):
    total = np.zeros_like(x)
    for c, a, b in zip(coeffs, exps_a, exps_b):
        total += c * np.exp(a * np.log(x) + b * np.log(y))
    return total

# Figure 1: Complexity Landscape
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('EML-KA Spectral Algebra: Complexity Landscape on (0,∞)²',
             fontsize=14, fontweight='bold')

x = np.linspace(0.1, 3, 100)
y = np.linspace(0.1, 3, 100)
X, Y = np.meshgrid(x, y)

# C₁: multiplication
Z1 = eval_mul_emlka(X, Y)
axes[0, 0].contourf(X, Y, Z1, levels=20, cmap='viridis')
axes[0, 0].set_title('C₁: x·y (1 term)', fontsize=11)
axes[0, 0].set_xlabel('x'); axes[0, 0].set_ylabel('y')

# C₁: x²y³
Z2 = eval_monomial_emlka(X, Y, 2, 3)
axes[0, 1].contourf(X, Y, Z2, levels=20, cmap='plasma')
axes[0, 1].set_title('C₁: x²y³ (1 term)', fontsize=11)
axes[0, 1].set_xlabel('x'); axes[0, 1].set_ylabel('y')

# C₁: geometric mean
Z3 = np.sqrt(X * Y)
axes[0, 2].contourf(X, Y, Z3, levels=20, cmap='inferno')
axes[0, 2].set_title('C₁: √(xy) (1 term)', fontsize=11)
axes[0, 2].set_xlabel('x'); axes[0, 2].set_ylabel('y')

# C₂: addition
Z4 = X + Y
axes[1, 0].contourf(X, Y, Z4, levels=20, cmap='coolwarm')
axes[1, 0].set_title('C₂: x + y (2 terms)', fontsize=11)
axes[1, 0].set_xlabel('x'); axes[1, 0].set_ylabel('y')

# C₃: polynomial with 3 monomials
Z5 = eval_poly_emlka(X, Y, [3, 2, -1], [2, 1, 1], [1, 2, 1])
axes[1, 1].contourf(X, Y, Z5, levels=20, cmap='RdYlBu_r')
axes[1, 1].set_title('C₃: 3x²y + 2xy² − xy', fontsize=11)
axes[1, 1].set_xlabel('x'); axes[1, 1].set_ylabel('y')

# Complexity spectrum diagram
ax = axes[1, 2]
ax.set_xlim(0, 6); ax.set_ylim(0, 5)
colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']
labels = ['C₁', 'C₂', 'C₃', 'C₄', 'C₅']
functions = [
    ['x·y', 'x/y', 'x²y³', '√(xy)'],
    ['x+y', 'x−y'],
    ['3x²y+2xy²−xy'],
    ['polynomial (4 terms)'],
    ['polynomial (5 terms)']
]

for i in range(5):
    rect = mpatches.FancyBboxPatch((0.3, 4.2 - i*0.9), 5.2, 0.7,
                                    boxstyle="round,pad=0.1",
                                    facecolor=colors[i], alpha=0.3,
                                    edgecolor=colors[i], linewidth=2)
    ax.add_patch(rect)
    ax.text(0.5, 4.55 - i*0.9, f'{labels[i]}:', fontsize=10, fontweight='bold',
            color=colors[i])
    ax.text(1.3, 4.55 - i*0.9, ', '.join(functions[i]), fontsize=9)

ax.set_title('EML-KA Complexity Spectrum', fontsize=11)
ax.axis('off')

plt.tight_layout()
plt.savefig('/workspace/request-project/spectral_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

# Figure 2: AM-GM via EML
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('AM-GM Inequality via EML Spectral Perspective', fontsize=13, fontweight='bold')

y_vals = np.linspace(0.1, 5, 200)
x_fixed = 2.0

gm = np.exp((np.log(x_fixed) + np.log(y_vals)) / 2)
am = (x_fixed + y_vals) / 2

ax1.plot(y_vals, am, 'b-', linewidth=2, label='AM = (x+y)/2 [C₂]')
ax1.plot(y_vals, gm, 'r-', linewidth=2, label='GM = exp((log x+log y)/2) [C₁]')
ax1.fill_between(y_vals, gm, am, alpha=0.2, color='green', label='AM−GM gap')
ax1.axvline(x=x_fixed, color='gray', linestyle='--', alpha=0.5, label=f'x = y = {x_fixed}')
ax1.set_xlabel('y (with x = 2 fixed)')
ax1.set_ylabel('Mean value')
ax1.set_title('AM ≥ GM: Higher complexity ≥ Lower complexity')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Fenchel-Young gap
x_range = np.linspace(-2, 3, 200)
s_vals = [0.5, 1.0, 2.0, np.e]
for s in s_vals:
    gap = np.exp(x_range) + s * np.log(s) - s - x_range * s
    ax2.plot(x_range, gap, linewidth=2, label=f's = {s:.2f}')
    ax2.axvline(x=np.log(s), color='gray', linestyle=':', alpha=0.3)

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('x')
ax2.set_ylabel('Fenchel-Young gap')
ax2.set_title('Fenchel-Young: exp(x) + s·log(s) − s − x·s ≥ 0')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.5, 10)

plt.tight_layout()
plt.savefig('/workspace/request-project/am_gm_fenchel.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualizations saved: spectral_landscape.png, am_gm_fenchel.png")
