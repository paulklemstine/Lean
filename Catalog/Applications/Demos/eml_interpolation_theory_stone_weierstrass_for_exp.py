#!/usr/bin/env python3
"""
EML Interpolation Theory: Demonstrations

This script demonstrates key results from the EML Stone-Weierstrass theory:
1. EML expression evaluation and complexity measures
2. Separation of points via log
3. Polynomial vs. EML approximation of power functions
4. Iterated exponential growth hierarchy
5. Exp-log cancellation and normal forms
"""

import math
from dataclasses import dataclass
from typing import Union


# === EML Expression Tree ===

@dataclass
class Const:
    value: float

@dataclass
class Proj:
    pass

@dataclass
class Exp:
    child: 'EMLExpr'

@dataclass
class Log:
    child: 'EMLExpr'

@dataclass
class Add:
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass
class Mul:
    left: 'EMLExpr'
    right: 'EMLExpr'

EMLExpr = Union[Const, Proj, Exp, Log, Add, Mul]


def eval_eml(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at x."""
    if isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Proj):
        return x
    elif isinstance(expr, Exp):
        v = eval_eml(expr.child, x)
        return math.exp(min(v, 700))  # prevent overflow
    elif isinstance(expr, Log):
        v = eval_eml(expr.child, x)
        return math.log(v) if v > 0 else 0.0
    elif isinstance(expr, Add):
        return eval_eml(expr.left, x) + eval_eml(expr.right, x)
    elif isinstance(expr, Mul):
        return eval_eml(expr.left, x) * eval_eml(expr.right, x)
    raise TypeError(f"Unknown expression type: {type(expr)}")


def depth(expr: EMLExpr) -> int:
    """Compute the depth of an EML expression."""
    if isinstance(expr, (Const, Proj)):
        return 0
    elif isinstance(expr, (Exp, Log)):
        return depth(expr.child) + 1
    elif isinstance(expr, (Add, Mul)):
        return max(depth(expr.left), depth(expr.right)) + 1
    raise TypeError


def size(expr: EMLExpr) -> int:
    """Compute the size of an EML expression."""
    if isinstance(expr, (Const, Proj)):
        return 1
    elif isinstance(expr, (Exp, Log)):
        return size(expr.child) + 1
    elif isinstance(expr, (Add, Mul)):
        return size(expr.left) + size(expr.right) + 1
    raise TypeError


def pretty(expr: EMLExpr) -> str:
    """Pretty-print an EML expression."""
    if isinstance(expr, Const):
        return f"{expr.value:.4g}"
    elif isinstance(expr, Proj):
        return "x"
    elif isinstance(expr, Exp):
        return f"exp({pretty(expr.child)})"
    elif isinstance(expr, Log):
        return f"log({pretty(expr.child)})"
    elif isinstance(expr, Add):
        return f"({pretty(expr.left)} + {pretty(expr.right)})"
    elif isinstance(expr, Mul):
        return f"({pretty(expr.left)} * {pretty(expr.right)})"
    raise TypeError


# === Demo 1: EML Expression Basics ===

print("=" * 60)
print("DEMO 1: EML Expression Basics")
print("=" * 60)

# x^2 via EML: exp(2 * log(x))
x_squared = Exp(Mul(Const(2), Log(Proj())))
print(f"\nExpression: {pretty(x_squared)}")
print(f"Depth: {depth(x_squared)}, Size: {size(x_squared)}")

for x in [1.0, 2.0, 3.0, math.pi]:
    result = eval_eml(x_squared, x)
    expected = x ** 2
    print(f"  x={x:.4f}: EML={result:.6f}, x²={expected:.6f}, error={abs(result-expected):.2e}")

# sqrt(x) via EML: exp(0.5 * log(x))
sqrt_x = Exp(Mul(Const(0.5), Log(Proj())))
print(f"\nExpression: {pretty(sqrt_x)}")
print(f"Depth: {depth(sqrt_x)}, Size: {size(sqrt_x)}")

for x in [1.0, 4.0, 9.0, 2.0]:
    result = eval_eml(sqrt_x, x)
    expected = math.sqrt(x)
    print(f"  x={x:.4f}: EML={result:.6f}, √x={expected:.6f}, error={abs(result-expected):.2e}")


# === Demo 2: Separation of Points ===

print("\n" + "=" * 60)
print("DEMO 2: Separation of Points")
print("=" * 60)

log_expr = Log(Proj())
pairs = [(1.0, 2.0), (1.0, math.e), (0.5, 1.5), (3.0, 3.001)]

for x, y in pairs:
    fx = eval_eml(log_expr, x)
    fy = eval_eml(log_expr, y)
    print(f"  x={x:.4f}, y={y:.4f}: log(x)={fx:.6f}, log(y)={fy:.6f}, "
          f"separated={'YES' if abs(fx - fy) > 1e-15 else 'NO'}")


# === Demo 3: Polynomial vs EML for Power Functions ===

print("\n" + "=" * 60)
print("DEMO 3: Polynomial vs EML for x^(1/3)")
print("=" * 60)

# EML: exp(1/3 * log(x)) — EXACT for x > 0
cbrt_eml = Exp(Mul(Const(1/3), Log(Proj())))

# Taylor polynomial for x^(1/3) around x=1 (up to degree n)
def taylor_cbrt(x: float, n: int) -> float:
    """Taylor expansion of x^(1/3) around x=1, degree n."""
    result = 1.0
    coeff = 1.0
    dx = x - 1
    for k in range(1, n + 1):
        coeff *= (1/3 - k + 1) / k
        result += coeff * dx ** k
    return result

test_points = [0.5, 1.0, 2.0, 5.0, 10.0]
print(f"\n{'x':>8} | {'EML (exact)':>12} | {'Taylor-5':>12} | {'Taylor-10':>12} | {'Taylor-20':>12} | {'True':>12}")
print("-" * 75)

for x in test_points:
    eml_val = eval_eml(cbrt_eml, x)
    t5 = taylor_cbrt(x, 5)
    t10 = taylor_cbrt(x, 10)
    t20 = taylor_cbrt(x, 20)
    true_val = x ** (1/3)
    print(f"{x:8.2f} | {eml_val:12.8f} | {t5:12.8f} | {t10:12.8f} | {t20:12.8f} | {true_val:12.8f}")

print("\nEML expression size: 5 (constant)")
print("Taylor polynomial sizes: 6, 11, 21 (growing)")
print("EML error: 0 (machine precision)")


# === Demo 4: Iterated Exponential Growth ===

print("\n" + "=" * 60)
print("DEMO 4: Iterated Exponential Growth Hierarchy")
print("=" * 60)

def iter_exp(n: int) -> EMLExpr:
    """Build the n-fold iterated exponential."""
    if n == 0:
        return Proj()
    return Exp(iter_exp(n - 1))

x = 1.0
print(f"\nValues of exp^n({x}) for n = 0, 1, 2, 3, 4:")
for n in range(5):
    expr = iter_exp(n)
    val = eval_eml(expr, x)
    print(f"  n={n}: depth={depth(expr)}, size={size(expr)}, "
          f"exp^{n}({x}) = {val:.6e}")
print("\nNote: Each level grows STRICTLY faster (Theorem: iterExp_strictly_increasing)")


# === Demo 5: Exp-Log Cancellation ===

print("\n" + "=" * 60)
print("DEMO 5: Exp-Log Cancellation Paradox")
print("=" * 60)

identity_via_cancel = Exp(Log(Proj()))  # exp(log(x)) = x for x > 0
plain_proj = Proj()

print(f"\nExpression 1 (identity): {pretty(plain_proj)}")
print(f"  Depth: {depth(plain_proj)}, Size: {size(plain_proj)}")

print(f"\nExpression 2 (exp∘log): {pretty(identity_via_cancel)}")
print(f"  Depth: {depth(identity_via_cancel)}, Size: {size(identity_via_cancel)}")

print(f"\nBoth compute the same function on x > 0:")
for x in [0.5, 1.0, 2.0, math.pi, 100.0]:
    v1 = eval_eml(plain_proj, x)
    v2 = eval_eml(identity_via_cancel, x)
    print(f"  x={x:.4f}: proj={v1:.6f}, exp(log(x))={v2:.6f}, match={'YES' if abs(v1-v2) < 1e-12 else 'NO'}")

print(f"\nSize 1 vs Size 3 — same function! Size is NOT a faithful complexity measure.")


# === Demo 6: EML Substitution (Composition) ===

print("\n" + "=" * 60)
print("DEMO 6: EML Substitution Algebra")
print("=" * 60)

def subst(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
    """Substitute e2 for Proj in e1."""
    if isinstance(e1, Const):
        return e1
    elif isinstance(e1, Proj):
        return e2
    elif isinstance(e1, Exp):
        return Exp(subst(e1.child, e2))
    elif isinstance(e1, Log):
        return Log(subst(e1.child, e2))
    elif isinstance(e1, Add):
        return Add(subst(e1.left, e2), subst(e1.right, e2))
    elif isinstance(e1, Mul):
        return Mul(subst(e1.left, e2), subst(e1.right, e2))
    raise TypeError

# exp(exp(x)) = exp ∘ exp
exp_of_exp = subst(Exp(Proj()), Exp(Proj()))
print(f"\nexp ∘ exp = {pretty(exp_of_exp)}")
print(f"Depth: {depth(exp_of_exp)}, Size: {size(exp_of_exp)}")

# x^2 ∘ exp = exp(x)^2 = exp(2x)
sq_of_exp = subst(x_squared, Exp(Proj()))
print(f"\nx² ∘ exp = {pretty(sq_of_exp)}")
print(f"Depth: {depth(sq_of_exp)}, Size: {size(sq_of_exp)}")
for x in [0, 1, 2]:
    print(f"  x={x}: result={eval_eml(sq_of_exp, float(x)):.6f}, exp(2x)={math.exp(2*x):.6f}")

print(f"\nDepth additivity: depth(e1∘e2) ≤ depth(e1) + depth(e2)")
e1 = Exp(Mul(Const(2), Proj()))  # exp(2x), depth=2
e2 = Log(Add(Proj(), Const(1)))   # log(x+1), depth=2
composed = subst(e1, e2)
print(f"  e1 = {pretty(e1)}, depth={depth(e1)}")
print(f"  e2 = {pretty(e2)}, depth={depth(e2)}")
print(f"  e1∘e2 = {pretty(composed)}, depth={depth(composed)}")
print(f"  Bound: {depth(e1)} + {depth(e2)} = {depth(e1)+depth(e2)} ≥ {depth(composed)} ✓")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy

Shows the growth rates of iterated exponentials exp^n(x) for n=0,1,2,3,
demonstrating strict growth separation between depth levels.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def iter_exp_eval(n: int, x: np.ndarray) -> np.ndarray:
    """Evaluate n-fold iterated exponential, clipping to avoid overflow."""
    result = x.copy()
    for _ in range(n):
        result = np.exp(np.clip(result, -100, 50))
    return result


x = np.linspace(-2, 2, 500)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: actual values (clipped)
ax = axes[0]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
for n in range(5):
    y = iter_exp_eval(n, x)
    y_clipped = np.clip(y, -10, 100)
    ax.plot(x, y_clipped, color=colors[n], linewidth=2,
            label=f'exp^{n}(x), depth={n}')
ax.set_ylim(-5, 100)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('exp^n(x)', fontsize=12)
ax.set_title('Iterated Exponential Growth', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: log scale to show separation
ax = axes[1]
x_pos = np.linspace(0.01, 1.5, 500)
for n in range(5):
    y = iter_exp_eval(n, x_pos)
    ax.semilogy(x_pos, y, color=colors[n], linewidth=2,
                label=f'exp^{n}(x)')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('exp^n(x) (log scale)', fontsize=12)
ax.set_title('Growth Separation (log scale)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('depth_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved depth_hierarchy.png")


#!/usr/bin/env python3
"""
Visualization: EML vs Polynomial Approximation of Power Functions

Shows that EML expressions (exp(r*log(x))) compute x^r exactly while
Taylor polynomials diverge away from the expansion point.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eval_taylor_cbrt(x: np.ndarray, degree: int) -> np.ndarray:
    """Taylor expansion of x^(1/3) around x=1, given degree."""
    result = np.ones_like(x, dtype=float)
    coeff = 1.0
    dx = x - 1.0
    for k in range(1, degree + 1):
        coeff *= (1.0/3.0 - k + 1) / k
        result = result + coeff * dx ** k
    return result


def eval_eml_cbrt(x: np.ndarray) -> np.ndarray:
    """EML expression exp(1/3 * log(x)) = x^(1/3), exact."""
    return np.exp((1.0/3.0) * np.log(x))


x = np.linspace(0.1, 5.0, 500)
true_vals = x ** (1.0/3.0)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: function values
ax = axes[0]
ax.plot(x, true_vals, 'k-', linewidth=2, label='True x^{1/3}')
ax.plot(x, eval_eml_cbrt(x), 'r--', linewidth=2, label='EML (exact, size=5)')
for deg, color in [(3, 'blue'), (5, 'green'), (10, 'orange')]:
    y_taylor = eval_taylor_cbrt(x, deg)
    y_taylor = np.clip(y_taylor, -5, 5)
    ax.plot(x, y_taylor, color=color, alpha=0.7, label=f'Taylor deg {deg}')
ax.set_ylim(-1, 3)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('f(x)', fontsize=12)
ax.set_title('EML vs Taylor Approximation of x^{1/3}', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right panel: error
ax = axes[1]
eml_error = np.abs(eval_eml_cbrt(x) - true_vals)
ax.semilogy(x, eml_error + 1e-16, 'r-', linewidth=2, label='EML error (machine ε)')
for deg, color in [(3, 'blue'), (5, 'green'), (10, 'orange')]:
    y_taylor = eval_taylor_cbrt(x, deg)
    taylor_error = np.abs(y_taylor - true_vals)
    ax.semilogy(x, taylor_error + 1e-16, color=color, alpha=0.7, label=f'Taylor deg {deg} error')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('|error|', fontsize=12)
ax.set_title('Approximation Error (log scale)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
print("Saved eml_approximation.png")
