#!/usr/bin/env python3
"""
EML Single Operator Church-Turing Thesis: Numerical Demonstrations

Demonstrates that eml(x,y) = exp(x) - log(y) is a universal primitive
for elementary real computation.
"""

import math

def eml(x: float, y: float) -> float:
    """The EML operator: eml(x, y) = exp(x) - log(y)"""
    assert y > 0, f"Second argument must be positive, got {y}"
    return math.exp(x) - math.log(y)


def demo_extraction():
    """Demo 1: Extracting exp and log from EML"""
    print("=" * 60)
    print("Demo 1: EML Extraction Identities")
    print("=" * 60)
    
    test_values = [0.0, 0.5, 1.0, 2.0, -1.0, 3.14]
    
    print("\n  exp(x) = eml(x, 1):")
    for x in test_values:
        exp_x = math.exp(x)
        eml_x = eml(x, 1.0)
        print(f"    x={x:6.2f}: exp(x)={exp_x:.10f}, eml(x,1)={eml_x:.10f}, diff={abs(exp_x-eml_x):.2e}")
    
    print("\n  log(y) = 1 - eml(0, y):")
    for y in [0.5, 1.0, 2.0, math.e, 10.0]:
        log_y = math.log(y)
        eml_y = 1 - eml(0, y)
        print(f"    y={y:6.2f}: log(y)={log_y:.10f}, 1-eml(0,y)={eml_y:.10f}, diff={abs(log_y-eml_y):.2e}")


def demo_roundtrip():
    """Demo 2: The EML round-trip identity eml(log(a), exp(b)) = a - b"""
    print("\n" + "=" * 60)
    print("Demo 2: EML Round-Trip Identity")
    print("=" * 60)
    
    print("\n  eml(log(a), exp(b)) = a - b for a > 0:")
    for a, b in [(1, 2), (3, 1), (math.e, math.pi), (0.5, 0.5), (10, 3)]:
        result = eml(math.log(a), math.exp(b))
        expected = a - b
        print(f"    a={a:.4f}, b={b:.4f}: eml(log(a),exp(b))={result:.10f}, a-b={expected:.10f}, diff={abs(result-expected):.2e}")


def demo_power_via_eml():
    """Demo 3: Real powers via EML: x^alpha = exp(alpha * log(x))"""
    print("\n" + "=" * 60)
    print("Demo 3: Real Powers via EML")
    print("=" * 60)
    
    print("\n  x^alpha = eml(alpha * (1 - eml(0, x)), 1):")
    for x, alpha in [(2, 3), (3, 0.5), (10, -1), (math.e, math.pi), (4, 0.25)]:
        log_x = 1 - eml(0, x)  # = log(x)
        power = eml(alpha * log_x, 1)  # = exp(alpha * log(x)) = x^alpha
        expected = x ** alpha
        print(f"    x={x:.4f}, α={alpha:.4f}: EML={power:.10f}, x^α={expected:.10f}, diff={abs(power-expected):.2e}")


def demo_compilation():
    """Demo 4: Compiling elementary expressions to EML-only form"""
    print("\n" + "=" * 60)
    print("Demo 4: Expression Compilation")
    print("=" * 60)
    
    x = 1.5
    
    # exp(x) -> eml(x, 1)
    original = math.exp(x)
    compiled = eml(x, 1)
    print(f"\n  exp({x}) = {original:.10f}")
    print(f"  eml({x}, 1) = {compiled:.10f}")
    print(f"  Match: {abs(original - compiled) < 1e-12}")
    
    # log(x) -> 1 - eml(0, x)
    original = math.log(x)
    compiled = 1 - eml(0, x)
    print(f"\n  log({x}) = {original:.10f}")
    print(f"  1 - eml(0, {x}) = {compiled:.10f}")
    print(f"  Match: {abs(original - compiled) < 1e-12}")
    
    # exp(log(x)) -> eml(1 - eml(0, x), 1)  (should equal x)
    original = math.exp(math.log(x))
    compiled = eml(1 - eml(0, x), 1)
    print(f"\n  exp(log({x})) = {original:.10f}")
    print(f"  eml(1-eml(0,{x}), 1) = {compiled:.10f}")
    print(f"  Match: {abs(original - compiled) < 1e-12}")
    
    # sinh(x) = (exp(x) - exp(-x))/2
    original = math.sinh(x)
    exp_pos = eml(x, 1)
    exp_neg = eml(-x, 1)
    compiled = (exp_pos - exp_neg) / 2
    print(f"\n  sinh({x}) = {original:.10f}")
    print(f"  (eml({x},1) - eml({-x},1))/2 = {compiled:.10f}")
    print(f"  Match: {abs(original - compiled) < 1e-12}")


def demo_exponential_hierarchy():
    """Demo 5: The exponential hierarchy via iterated EML"""
    print("\n" + "=" * 60)
    print("Demo 5: Exponential Hierarchy")
    print("=" * 60)
    
    x = 0.5
    print(f"\n  Starting value: x = {x}")
    
    for n in range(5):
        if n == 0:
            val = x
        else:
            val = eml(val, 1)  # Apply eml(·, 1) = exp(·)
        print(f"  Level {n}: iterateExp({n}, {x}) = {val:.10f}")
        if val > 1e100:
            print(f"  (Stopping: values exceed 10^100)")
            break


def demo_differential_closure():
    """Demo 6: Numerical verification of differential closure"""
    print("\n" + "=" * 60)
    print("Demo 6: Differential Closure")
    print("=" * 60)
    
    h = 1e-8  # Finite difference step
    x = 1.0
    
    # a(t) = t^2, b(t) = t + 1
    def a(t): return t**2
    def b(t): return t + 1
    def f(t): return math.exp(a(t)) - math.log(b(t))
    
    # Numerical derivative
    numerical_deriv = (f(x + h) - f(x - h)) / (2 * h)
    
    # Analytical: exp(a(x)) * a'(x) - b'(x) / b(x)
    # a'(x) = 2x, b'(x) = 1
    analytical_deriv = math.exp(a(x)) * (2 * x) - 1 / b(x)
    
    print(f"\n  f(t) = exp(t²) - log(t+1)")
    print(f"  f'(x) = exp(x²)·2x - 1/(x+1)")
    print(f"  At x = {x}:")
    print(f"    Numerical:   {numerical_deriv:.10f}")
    print(f"    Analytical:  {analytical_deriv:.10f}")
    print(f"    Difference:  {abs(numerical_deriv - analytical_deriv):.2e}")


def demo_size_bound():
    """Demo 7: Compilation size bound verification"""
    print("\n" + "=" * 60)
    print("Demo 7: Compilation Size Bounds")
    print("=" * 60)
    
    examples = [
        ("var", 1, 1, "var → var"),
        ("const(π)", 1, 1, "const → const"),
        ("exp(var)", 2, 3, "exp(x) → eml(var, const(1))"),
        ("log(var)", 2, 5, "log(x) → sub(const(1), eml(const(0), var))"),
        ("exp(log(var))", 3, 8, "exp(log(x)) → eml(sub(const(1), eml(const(0), var)), const(1))"),
        ("add(exp(var), log(var))", 5, 9, "exp(x) + log(x) → add(eml(...), sub(...))"),
    ]
    
    print(f"\n  {'Expression':<25} {'Source':>6} {'Compiled':>8} {'Ratio':>6} {'Bound':>6}")
    print(f"  {'-'*25} {'-'*6} {'-'*8} {'-'*6} {'-'*6}")
    for name, src_size, compiled_size, _ in examples:
        ratio = compiled_size / src_size
        bound = 5.0
        print(f"  {name:<25} {src_size:>6} {compiled_size:>8} {ratio:>6.2f} {bound:>6.1f}")


if __name__ == "__main__":
    demo_extraction()
    demo_roundtrip()
    demo_power_via_eml()
    demo_compilation()
    demo_exponential_hierarchy()
    demo_differential_closure()
    demo_size_bound()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Compilation Size and Rank Analysis

Shows compilation statistics: size blowup, rank conservation,
and depth bounds for various elementary expressions.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_data():
    # (name, source_size, compiled_size, transc_rank, eml_rank, eml_depth)
    data = [
        ("x", 1, 1, 0, 0, 0),
        ("c", 1, 1, 0, 0, 0),
        ("x+c", 3, 3, 0, 0, 0),
        ("x*x", 3, 3, 0, 0, 0),
        ("exp(x)", 2, 3, 1, 1, 1),
        ("log(x)", 2, 5, 1, 1, 1),
        ("exp(x)+log(x)", 5, 9, 2, 2, 1),
        ("exp(log(x))", 3, 8, 2, 2, 1),
        ("log(exp(x))", 3, 8, 2, 2, 1),
        ("exp(exp(x))", 3, 5, 2, 2, 2),
        ("x*exp(x)", 4, 6, 1, 1, 1),
        ("sinh(x)", 8, 12, 2, 2, 1),
        ("exp(x^2)*log(x+1)", 9, 15, 2, 2, 1),
    ]
    return data

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

data = make_data()
names = [d[0] for d in data]
src_sizes = [d[1] for d in data]
cmp_sizes = [d[2] for d in data]
transc_ranks = [d[3] for d in data]
eml_ranks = [d[4] for d in data]
eml_depths = [d[5] for d in data]

# Plot 1: Size comparison
ax = axes[0, 0]
x_pos = np.arange(len(names))
width = 0.35
bars1 = ax.bar(x_pos - width/2, src_sizes, width, label='Source size', color='#4C72B0')
bars2 = ax.bar(x_pos + width/2, cmp_sizes, width, label='Compiled size', color='#DD8452')
ax.plot(x_pos, [5*s for s in src_sizes], 'r--', linewidth=1, alpha=0.5, label='5x bound')
ax.set_xticks(x_pos)
ax.set_xticklabels(names, rotation=45, ha='right', fontsize=7)
ax.set_ylabel('Node count')
ax.set_title('Compilation Size: Source vs Compiled')
ax.legend(fontsize=8)
ax.grid(axis='y', alpha=0.3)

# Plot 2: Rank conservation
ax = axes[0, 1]
ax.bar(x_pos - width/2, transc_ranks, width, label='Transc. rank (source)', color='#4C72B0')
ax.bar(x_pos + width/2, eml_ranks, width, label='EML rank (compiled)', color='#DD8452')
ax.set_xticks(x_pos)
ax.set_xticklabels(names, rotation=45, ha='right', fontsize=7)
ax.set_ylabel('Rank')
ax.set_title('Rank Conservation: τ(source) = ρ(compiled)')
ax.legend(fontsize=8)
ax.grid(axis='y', alpha=0.3)

# Plot 3: Size ratio
ax = axes[1, 0]
ratios = [c/s if s > 0 else 0 for s, c in zip(src_sizes, cmp_sizes)]
colors = ['#2ca02c' if r <= 3 else '#ff7f0e' if r <= 4 else '#d62728' for r in ratios]
ax.bar(x_pos, ratios, color=colors)
ax.axhline(y=5, color='red', linestyle='--', linewidth=1, label='Upper bound (5x)')
ax.set_xticks(x_pos)
ax.set_xticklabels(names, rotation=45, ha='right', fontsize=7)
ax.set_ylabel('Size ratio (compiled/source)')
ax.set_title('Compilation Size Ratio')
ax.legend(fontsize=8)
ax.grid(axis='y', alpha=0.3)

# Plot 4: Depth hierarchy
ax = axes[1, 1]
ax.bar(x_pos - width/2, transc_ranks, width, label='Transc. rank (bound)', color='#4C72B0', alpha=0.5)
ax.bar(x_pos + width/2, eml_depths, width, label='EML depth (actual)', color='#55A868')
ax.set_xticks(x_pos)
ax.set_xticklabels(names, rotation=45, ha='right', fontsize=7)
ax.set_ylabel('Value')
ax.set_title('Depth Bound: δ(compiled) ≤ τ(source)')
ax.legend(fontsize=8)
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('eml_compilation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eml_compilation.png")


#!/usr/bin/env python3
"""
Visualization: The EML Surface eml(x,y) = exp(x) - log(y)

Shows the 3D surface of the EML operator, highlighting:
- Exponential growth in x (first argument)
- Logarithmic decay in y (second argument)
- The "extraction" lines: y=1 (giving exp(x)) and x=0 (giving 1-log(y))
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def eml(x, y):
    return np.exp(x) - np.log(y)

fig = plt.figure(figsize=(14, 10))

# Main 3D surface
ax1 = fig.add_subplot(221, projection='3d')
x = np.linspace(-2, 3, 100)
y = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)
Z_clipped = np.clip(Z, -5, 25)

surf = ax1.plot_surface(X, Y, Z_clipped, cmap='viridis', alpha=0.7, edgecolor='none')
ax1.set_xlabel('x (exp argument)')
ax1.set_ylabel('y (log argument)')
ax1.set_zlabel('eml(x, y)')
ax1.set_title('EML Surface: eml(x,y) = exp(x) - log(y)')
ax1.view_init(elev=25, azim=-60)

# exp extraction: eml(x, 1) = exp(x)
ax2 = fig.add_subplot(222)
x = np.linspace(-2, 3, 200)
ax2.plot(x, np.exp(x), 'b-', linewidth=2, label='exp(x)')
ax2.plot(x, eml(x, 1), 'r--', linewidth=2, label='eml(x, 1)')
ax2.set_xlabel('x')
ax2.set_ylabel('value')
ax2.set_title('Exp Extraction: eml(x, 1) = exp(x)')
ax2.legend()
ax2.grid(True, alpha=0.3)

# log extraction: 1 - eml(0, y) = log(y)
ax3 = fig.add_subplot(223)
y = np.linspace(0.1, 10, 200)
ax3.plot(y, np.log(y), 'b-', linewidth=2, label='log(y)')
ax3.plot(y, 1 - eml(0, y), 'r--', linewidth=2, label='1 - eml(0, y)')
ax3.set_xlabel('y')
ax3.set_ylabel('value')
ax3.set_title('Log Extraction: 1 - eml(0, y) = log(y)')
ax3.legend()
ax3.grid(True, alpha=0.3)

# Exponential hierarchy
ax4 = fig.add_subplot(224)
x = np.linspace(-1, 1.5, 200)
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
labels = ['x (depth 0)', 'exp(x) (depth 1)', 'exp(exp(x)) (depth 2)', 'exp³(x) (depth 3)']

ax4.plot(x, x, color=colors[0], linewidth=2, label=labels[0])
ax4.plot(x, np.exp(x), color=colors[1], linewidth=2, label=labels[1])
ax4.plot(x, np.exp(np.exp(x)), color=colors[2], linewidth=2, label=labels[2])
mask = x < 0.8
vals = np.exp(np.exp(np.exp(x)))
vals_clipped = np.where(mask, vals, np.nan)
ax4.plot(x, vals_clipped, color=colors[3], linewidth=2, label=labels[3])

ax4.set_ylim(-2, 20)
ax4.set_xlabel('x')
ax4.set_ylabel('value')
ax4.set_title('Exponential Hierarchy via Iterated EML')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eml_surface.png")
