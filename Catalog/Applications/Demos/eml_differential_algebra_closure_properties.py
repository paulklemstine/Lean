#!/usr/bin/env python3
"""
EML Differential Algebra — Numerical Demonstrations

Demonstrates the key results of the EML differential algebra:
1. EML subsumes exp and log
2. The EML chain rule
3. Depth hierarchy examples
4. Integration obstruction witness
"""

import math


def eml(x: float, y: float) -> float:
    """The EML operator: eml(x, y) = exp(x) - log(y)."""
    if y <= 0:
        raise ValueError(f"eml undefined for y={y} <= 0")
    return math.exp(x) - math.log(y)


def eml_deriv_x(x: float, y: float) -> float:
    """Partial derivative of eml w.r.t. x: ∂eml/∂x = exp(x)."""
    return math.exp(x)


def eml_deriv_y(x: float, y: float) -> float:
    """Partial derivative of eml w.r.t. y: ∂eml/∂y = -1/y."""
    return -1.0 / y


def eml_chain_rule(f_val: float, g_val: float, f_prime: float, g_prime: float) -> float:
    """
    Full chain rule for eml(f(t), g(t)):
    d/dt[eml(f(t), g(t))] = f'·exp(f) - g'/g
    """
    return f_prime * math.exp(f_val) - g_prime / g_val


def numerical_derivative(func, t: float, h: float = 1e-8) -> float:
    """Central difference numerical derivative."""
    return (func(t + h) - func(t - h)) / (2 * h)


print("=" * 70)
print("EML DIFFERENTIAL ALGEBRA — NUMERICAL DEMONSTRATIONS")
print("=" * 70)

# Demo 1: EML subsumes exp and log
print("\n--- Demo 1: EML Subsumes exp and log ---")
for x in [0, 1, 2, -1, 0.5]:
    exp_x = math.exp(x)
    eml_x_1 = eml(x, 1)
    print(f"  exp({x:6.2f}) = {exp_x:.6f},  eml({x}, 1) = {eml_x_1:.6f},  match: {abs(exp_x - eml_x_1) < 1e-10}")

print()
for y in [0.5, 1, 2, math.e, 10]:
    log_y = math.log(y)
    recover = 1 - eml(0, y)
    print(f"  log({y:6.2f}) = {log_y:.6f},  1 - eml(0, {y}) = {recover:.6f},  match: {abs(log_y - recover) < 1e-10}")

# Demo 2: EML Chain Rule verification
print("\n--- Demo 2: EML Full Chain Rule ---")
print("  Testing d/dt[eml(t, exp(t))] = exp(t) - 1")
for t in [0, 0.5, 1, 2, -1]:
    F = lambda s: eml(s, math.exp(s))
    analytic = math.exp(t) - 1
    numerical = numerical_derivative(F, t)
    chain = eml_chain_rule(t, math.exp(t), 1, math.exp(t))
    print(f"  t={t:5.1f}: analytic={analytic:10.6f}, chain_rule={chain:10.6f}, numerical={numerical:10.6f}")

print("\n  Testing d/dt[eml(t², 1)] = 2t·exp(t²)")
for t in [0, 0.5, 1, -1, 2]:
    F = lambda s: eml(s**2, 1)
    analytic = 2 * t * math.exp(t**2)
    numerical = numerical_derivative(F, t)
    print(f"  t={t:5.1f}: analytic={analytic:10.6f}, numerical={numerical:10.6f}, error={abs(analytic-numerical):.2e}")

# Demo 3: Diagonal EML derivatives
print("\n--- Demo 3: Diagonal emlDiag(z) = exp(z) - log(z) ---")
print("  First derivative: exp(z) - 1/z")
print("  Second derivative: exp(z) + 1/z²")
for z in [0.5, 1, 2, 3]:
    d = lambda w: math.exp(w) - math.log(w)
    d1_analytic = math.exp(z) - 1/z
    d1_numerical = numerical_derivative(d, z)
    d2_func = lambda w: math.exp(w) - 1/w
    d2_analytic = math.exp(z) + 1/z**2
    d2_numerical = numerical_derivative(d2_func, z)
    print(f"  z={z:.1f}: d'={d1_analytic:10.4f} (num={d1_numerical:10.4f}), "
          f"d''={d2_analytic:10.4f} (num={d2_numerical:10.4f})")

# Demo 4: Depth hierarchy
print("\n--- Demo 4: EML Depth Hierarchy ---")
print("  Depth 0: x² (polynomial)")
print("  Depth 1: exp(x), log(x)")
print("  Depth 2: exp(exp(x)), log(log(x))")
print("  Depth 3: exp(exp(exp(x)))")
x_test = 1.0
print(f"\n  At x = {x_test}:")
print(f"    Depth 0: x²        = {x_test**2:.6f}")
print(f"    Depth 1: exp(x)    = {math.exp(x_test):.6f}")
print(f"    Depth 1: log(x)    = {math.log(x_test):.6f}")
print(f"    Depth 2: exp(eˣ)   = {math.exp(math.exp(x_test)):.6f}")
print(f"    Depth 3: exp(exp(eˣ)) = {math.exp(math.exp(math.exp(x_test))):.6f}")

print("\n  Derivatives preserve depth:")
print(f"    d/dx[exp(x)]      = exp(x) = {math.exp(x_test):.6f} (depth 1)")
print(f"    d/dx[exp(eˣ)]     = eˣ·exp(eˣ) = {math.exp(x_test)*math.exp(math.exp(x_test)):.6f} (depth 2)")
print(f"    d/dx[log(x)]      = 1/x = {1/x_test:.6f} (depth 0, decreased!)")

# Demo 5: Integration obstruction
print("\n--- Demo 5: Integration Obstruction ---")
print("  exp(exp(x)) is EML-expressible (depth 2)")
print("  But ∫exp(exp(x))dx has NO elementary antiderivative!")
print("\n  Numerical evidence (no closed form):")
from functools import reduce
total = 0
h = 0.001
for i in range(1000):
    t = i * h
    total += math.exp(math.exp(t)) * h
print(f"    ∫₀¹ exp(exp(x)) dx ≈ {total:.6f}")
print(f"    (Compare: this cannot be expressed using exp, log, and algebra)")

# Demo 6: eml(log(x), x) = x - log(x)
print("\n--- Demo 6: Identity eml(log(x), x) = x - log(x) ---")
for x in [0.5, 1, math.e, 5, 10]:
    lhs = eml(math.log(x), x)
    rhs = x - math.log(x)
    print(f"  x={x:6.2f}: eml(log(x), x) = {lhs:.6f}, x - log(x) = {rhs:.6f}, match: {abs(lhs-rhs) < 1e-10}")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("Key result: EML differential algebra is closed under differentiation")
print("but NOT closed under integration.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Depth Preservation under Differentiation

Shows that differentiating EML functions preserves transcendence depth.
Compares original functions and their derivatives at each depth level.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_depth_examples():
    """Generate functions and their derivatives at each depth level."""
    x = np.linspace(0.1, 3, 300)
    
    examples = {
        'Depth 0': [
            ('x²', x**2, "d/dx[x²] = 2x", 2*x),
            ('3x+1', 3*x+1, "d/dx[3x+1] = 3", np.full_like(x, 3)),
        ],
        'Depth 1': [
            ('exp(x)', np.exp(x), "d/dx[exp(x)] = exp(x)", np.exp(x)),
            ('log(x)', np.log(x), "d/dx[log(x)] = 1/x", 1/x),
            ('eml(x,x)', np.exp(x)-np.log(x), "d/dx = exp(x)-1/x", np.exp(x)-1/x),
        ],
        'Depth 2': [
            ('exp(eˣ)', np.exp(np.exp(x)), "d/dx = eˣ·exp(eˣ)", np.exp(x)*np.exp(np.exp(x))),
            ('log(log(x))', np.log(np.log(x)), "d/dx = 1/(x·log(x))", 1/(x*np.log(x))),
        ],
    }
    return x, examples

x, examples = make_depth_examples()

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, (depth_name, funcs) in enumerate(examples.items()):
    ax = axes[idx]
    colors = plt.cm.tab10(np.linspace(0, 1, 2*len(funcs)))
    
    for i, (name, vals, dname, dvals) in enumerate(funcs):
        # Clip for visualization
        vals_clip = np.clip(vals, -10, 50)
        dvals_clip = np.clip(dvals, -10, 50)
        
        ax.plot(x, vals_clip, color=colors[2*i], linewidth=2, label=name)
        ax.plot(x, dvals_clip, color=colors[2*i+1], linewidth=1.5, 
                linestyle='--', label=dname)
    
    ax.set_title(f'{depth_name}', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=7, loc='upper left')
    ax.set_ylim(-5, 30)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='black', linewidth=0.5)

fig.suptitle('EML Depth Preservation: Derivatives Stay at Same Depth', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('eml_depth_preservation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eml_depth_preservation.png")


#!/usr/bin/env python3
"""
Visualization: EML Function Surface and Derivative Vector Field

Shows the eml(x, y) = exp(x) - log(y) surface with its gradient field,
illustrating the partial derivatives ∂eml/∂x = exp(x) and ∂eml/∂y = -1/y.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def eml(x, y):
    return np.exp(x) - np.log(y)

def eml_dx(x, y):
    return np.exp(x)

def eml_dy(x, y):
    return -1.0 / y

# Surface plot
fig = plt.figure(figsize=(14, 5))

# Panel 1: EML surface
ax1 = fig.add_subplot(131, projection='3d')
x = np.linspace(-2, 2, 50)
y = np.linspace(0.1, 5, 50)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)
ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8, edgecolor='none')
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('eml(x,y)')
ax1.set_title('eml(x,y) = exp(x) - log(y)')

# Panel 2: Gradient field
ax2 = fig.add_subplot(132)
x2 = np.linspace(-2, 2, 15)
y2 = np.linspace(0.3, 5, 15)
X2, Y2 = np.meshgrid(x2, y2)
U = eml_dx(X2, Y2)
V = eml_dy(X2, Y2)
magnitude = np.sqrt(U**2 + V**2)
ax2.quiver(X2, Y2, U/magnitude, V/magnitude, magnitude, cmap='coolwarm')
ax2.set_xlabel('x')
ax2.set_ylabel('y')
ax2.set_title('∇eml = (exp(x), -1/y)')
ax2.set_aspect('equal')

# Panel 3: Depth hierarchy - derivatives
ax3 = fig.add_subplot(133)
x3 = np.linspace(-1, 2, 200)

# depth 0: polynomial
ax3.plot(x3, x3**2, label='depth 0: x²', linewidth=2)
# depth 1: exp
ax3.plot(x3, np.exp(x3), label='depth 1: exp(x)', linewidth=2)
# depth 1 derivative (stays depth 1)
ax3.plot(x3, np.exp(x3), label="d/dx[exp(x)] = exp(x)", linewidth=2, linestyle='--')
# depth 1: log derivative (drops to depth 0)
x3pos = x3[x3 > 0.1]
ax3.plot(x3pos, 1.0/x3pos, label="d/dx[log(x)] = 1/x (depth 0!)", linewidth=2, linestyle=':')

ax3.set_xlabel('x')
ax3.set_ylabel('f(x)')
ax3.set_title('Depth Hierarchy')
ax3.legend(fontsize=8)
ax3.set_ylim(-2, 10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_differential_algebra.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eml_differential_algebra.png")
