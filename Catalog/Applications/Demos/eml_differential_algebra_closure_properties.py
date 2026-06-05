#!/usr/bin/env python3
"""
EML Differential Algebra — Numerical Demonstrations

Demonstrates the key results:
1. Self-referential differentiation: d/dx eml(x,y) = eml(x,1)
2. Syntactic differentiation closure: sdiff maps EMLTerm to EMLTerm
3. Wronskian computation and linear independence
4. The integration barrier: exp(-x^2) vs its antiderivative
"""

import math
from typing import Callable


def eml(x: float, y: float) -> float:
    """The EML primitive: eml(x, y) = exp(x) - log(y)"""
    if y <= 0:
        raise ValueError(f"eml undefined for y={y} <= 0")
    return math.exp(x) - math.log(y)


def numerical_derivative(f: Callable[[float], float], x: float, h: float = 1e-8) -> float:
    """Central difference numerical derivative."""
    return (f(x + h) - f(x - h)) / (2 * h)


# =============================================================================
# Demo 1: Self-Referential Differentiation
# =============================================================================

print("=" * 60)
print("Demo 1: Self-Referential Differentiation")
print("  d/dx eml(x, y) = exp(x) = eml(x, 1)")
print("=" * 60)

test_points = [(0, 1), (1, 2), (2, 0.5), (-1, 3), (0.5, 1.5)]

for x, y in test_points:
    # Numerical derivative of eml(·, y) at x
    f = lambda t, y=y: eml(t, y)
    num_deriv = numerical_derivative(f, x)
    
    # Analytic: should equal exp(x) = eml(x, 1)
    analytic = eml(x, 1)
    
    print(f"  x={x:5.1f}, y={y:4.1f}: "
          f"d/dx eml = {num_deriv:10.6f}, "
          f"eml(x,1) = {analytic:10.6f}, "
          f"error = {abs(num_deriv - analytic):8.2e}")

print()

# =============================================================================
# Demo 2: EML Generates Exp and Log
# =============================================================================

print("=" * 60)
print("Demo 2: EML Generates the Elementary Transcendentals")
print("=" * 60)

for x in [0.5, 1.0, 2.0, math.e]:
    exp_x = math.exp(x)
    eml_x_1 = eml(x, 1)
    print(f"  exp({x:.2f}) = {exp_x:.6f}, eml({x:.2f}, 1) = {eml_x_1:.6f}")

print()

for y in [0.5, 1.0, 2.0, math.e]:
    log_y = math.log(y)
    one_minus_eml = 1 - eml(0, y)
    print(f"  log({y:.2f}) = {log_y:.6f}, 1 - eml(0, {y:.2f}) = {one_minus_eml:.6f}")

print()

# =============================================================================
# Demo 3: The Reciprocal Trick
# =============================================================================

print("=" * 60)
print("Demo 3: Reciprocal via EML: 1/x = exp(-log(x))")
print("=" * 60)

for x in [0.5, 1.0, 2.0, 3.0, math.pi]:
    inv_x = 1.0 / x
    eml_inv = math.exp(-math.log(x))
    print(f"  1/{x:.4f} = {inv_x:.6f}, exp(-log({x:.4f})) = {eml_inv:.6f}")

print()

# =============================================================================
# Demo 4: Wronskian of exp and log
# =============================================================================

print("=" * 60)
print("Demo 4: Wronskian W(exp, log)(x) = exp(x)/x - exp(x)*log(x)")
print("=" * 60)

def wronskian_exp_log(x: float) -> float:
    """W(exp, log)(x) = exp(x) * deriv(log)(x) - deriv(exp)(x) * log(x)"""
    return math.exp(x) / x - math.exp(x) * math.log(x)

for x in [0.5, 1.0, 1.5, 1.76, 2.0, math.e]:
    w = wronskian_exp_log(x)
    print(f"  W(exp, log)({x:.2f}) = {w:10.6f}"
          + (" <-- close to zero!" if abs(w) < 0.01 else ""))

print(f"\n  W(exp, log)(1) = {wronskian_exp_log(1):.6f} = e = {math.e:.6f}")
print("  This proves exp and log are linearly independent!")

print()

# =============================================================================
# Demo 5: Iterated Differentiation
# =============================================================================

print("=" * 60)
print("Demo 5: n-th Derivative of exp is exp (fixed point)")
print("=" * 60)

def iterated_numerical_deriv(f: Callable, x: float, n: int) -> float:
    """Compute the n-th numerical derivative."""
    if n == 0:
        return f(x)
    g = lambda t: numerical_derivative(f, t, h=1e-4)
    return iterated_numerical_deriv(g, x, n - 1)

x_test = 1.5
for n in range(6):
    nth_deriv = iterated_numerical_deriv(math.exp, x_test, n)
    exact = math.exp(x_test)
    print(f"  d^{n}/dx^{n} exp({x_test}) = {nth_deriv:10.6f}, "
          f"exp({x_test}) = {exact:10.6f}, "
          f"error = {abs(nth_deriv - exact):8.2e}")

print()

# =============================================================================
# Demo 6: The Integration Barrier
# =============================================================================

print("=" * 60)
print("Demo 6: The Integration Barrier")
print("  exp(-x^2) is EML but its integral (erf) is NOT")
print("=" * 60)

# exp(-x^2) is clearly EML: compose exp with -x^2
# But erf(x) = (2/sqrt(pi)) * integral_0^x exp(-t^2) dt
# is NOT elementary (Liouville's theorem)

# Numerical integration to show what erf looks like
def trapezoidal_erf(x: float, n: int = 1000) -> float:
    """Numerical approximation of erf(x)."""
    if x == 0:
        return 0
    h = x / n
    s = math.exp(0) + math.exp(-x * x)
    for i in range(1, n):
        t = i * h
        s += 2 * math.exp(-t * t)
    return (2 / math.sqrt(math.pi)) * s * h / 2

print("  x    | exp(-x^2) [EML]  | erf(x) [NOT EML]")
print("  -----+------------------+------------------")
for x in [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
    gaussian = math.exp(-x * x)
    erf_val = trapezoidal_erf(x)
    print(f"  {x:4.1f} | {gaussian:16.10f} | {erf_val:16.10f}")

print()
print("  exp(-x^2) can be written as eml(-x^2, 1)")
print("  but erf(x) = (2/sqrt(pi)) * integral of exp(-t^2) is NOT elementary")
print("  This is Liouville's theorem (1835): integration can escape EML!")

print()

# =============================================================================
# Demo 7: Total Derivative Chain Rule
# =============================================================================

print("=" * 60)
print("Demo 7: Total Derivative of eml(g(x), h(x))")
print("  d/dx eml(g(x), h(x)) = exp(g(x))*g'(x) - h'(x)/h(x)")
print("=" * 60)

# Example: g(x) = x^2, h(x) = x + 1
# d/dx eml(x^2, x+1) = exp(x^2)*2x - 1/(x+1)

def f_composed(x: float) -> float:
    return eml(x * x, x + 1)

for x in [0.0, 0.5, 1.0, 1.5, 2.0]:
    num = numerical_derivative(f_composed, x)
    analytic = math.exp(x * x) * 2 * x - 1 / (x + 1)
    print(f"  x={x:.1f}: numerical={num:12.6f}, analytic={analytic:12.6f}, "
          f"error={abs(num - analytic):8.2e}")

print()
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: EML Self-Referential Differentiation

Plots the EML function and its derivatives, showing the self-referential
property: d/dx eml(x, y) = eml(x, 1) = exp(x).
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml(x, y):
    """eml(x, y) = exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

x = np.linspace(-2, 3, 500)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: eml(x, y) for various y
ax = axes[0]
for y_val in [0.5, 1.0, 2.0, 5.0]:
    ax.plot(x, eml(x, y_val), label=f'eml(x, {y_val})', linewidth=2)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('eml(x, y)', fontsize=12)
ax.set_title('EML Primitive for Various y', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-5, 25)

# Panel 2: Self-referential property
ax = axes[1]
y_val = 2.0
ax.plot(x, eml(x, y_val), label=f'eml(x, {y_val})', linewidth=2.5, color='blue')
ax.plot(x, np.exp(x), label='d/dx eml(x, y) = exp(x)', linewidth=2.5, 
        color='red', linestyle='--')
ax.plot(x, eml(x, 1), label='eml(x, 1) = exp(x)', linewidth=2, 
        color='green', linestyle=':')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Self-Referential Derivative\nd/dx eml(x,y) = eml(x,1)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-5, 25)

# Panel 3: Wronskian
x_pos = np.linspace(0.1, 4, 500)
wronskian = np.exp(x_pos) / x_pos - np.exp(x_pos) * np.log(x_pos)
ax = axes[2]
ax.plot(x_pos, wronskian, linewidth=2.5, color='purple')
ax.axhline(y=0, color='black', linewidth=0.5)
ax.axvline(x=1, color='gray', linewidth=0.5, linestyle='--')
ax.plot(1, np.e, 'ro', markersize=8, label=f'W(1) = e ≈ {np.e:.3f}')
# Find approximate zero
zero_idx = np.argmin(np.abs(wronskian))
ax.plot(x_pos[zero_idx], wronskian[zero_idx], 'g^', markersize=8, 
        label=f'Zero at x ≈ {x_pos[zero_idx]:.2f}')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('W(exp, log)(x)', fontsize=12)
ax.set_title('Wronskian of exp and log', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_derivatives.png', dpi=150, bbox_inches='tight')
print("Saved: eml_derivatives.png")


#!/usr/bin/env python3
"""
Visualization: Expression Swell Under Iterated Differentiation

Shows how the size of EML terms grows exponentially under repeated
syntactic differentiation, visualizing the computational barrier.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Compute expression sizes by simulation

class EMLTerm:
    def size(self):
        raise NotImplementedError
    def sdiff(self):
        raise NotImplementedError

class Var(EMLTerm):
    def size(self): return 1
    def sdiff(self): return Cst()

class Cst(EMLTerm):
    def size(self): return 1
    def sdiff(self): return Cst()

class Add(EMLTerm):
    def __init__(self, a, b): self.a, self.b = a, b
    def size(self): return 1 + self.a.size() + self.b.size()
    def sdiff(self): return Add(self.a.sdiff(), self.b.sdiff())

class Neg(EMLTerm):
    def __init__(self, t): self.t = t
    def size(self): return 1 + self.t.size()
    def sdiff(self): return Neg(self.t.sdiff())

class Mul(EMLTerm):
    def __init__(self, a, b): self.a, self.b = a, b
    def size(self): return 1 + self.a.size() + self.b.size()
    def sdiff(self): return Add(Mul(self.a.sdiff(), self.b), Mul(self.a, self.b.sdiff()))

class Inv(EMLTerm):
    def __init__(self, t): self.t = t
    def size(self): return 1 + self.t.size()
    def sdiff(self): return Neg(Mul(Inv(Mul(self.t, self.t)), self.t.sdiff()))

class Comp(EMLTerm):
    def __init__(self, a, b): self.a, self.b = a, b
    def size(self): return 1 + self.a.size() + self.b.size()
    def sdiff(self): return Mul(Comp(self.a.sdiff(), self.b), self.b.sdiff())

class ExpT(EMLTerm):
    def size(self): return 1
    def sdiff(self): return ExpT()

class LogT(EMLTerm):
    def size(self): return 1
    def sdiff(self): return Inv(Var())

# Compute swell for different starting terms
terms = {
    'x·x (product)': Mul(Var(), Var()),
    'exp(x²)': Comp(ExpT(), Mul(Var(), Var())),
    'log(x)': LogT(),
    'exp(x)': ExpT(),
    '1/x': Inv(Var()),
}

max_n = 7
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for name, term in terms.items():
    sizes = [term.size()]
    current = term
    for _ in range(max_n):
        current = current.sdiff()
        sizes.append(current.size())
    
    ns = list(range(len(sizes)))
    ax1.plot(ns, sizes, 'o-', label=name, linewidth=2, markersize=6)
    ax2.semilogy(ns, sizes, 'o-', label=name, linewidth=2, markersize=6)

ax1.set_xlabel('Differentiation Order n', fontsize=12)
ax1.set_ylabel('Expression Size (nodes)', fontsize=12)
ax1.set_title('Expression Swell: Linear Scale', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

ax2.set_xlabel('Differentiation Order n', fontsize=12)
ax2.set_ylabel('Expression Size (log scale)', fontsize=12)
ax2.set_title('Expression Swell: Log Scale\n(Exponential growth = straight line)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add reference line for 3^n growth
ns_ref = np.arange(max_n + 1)
ax2.plot(ns_ref, 3**ns_ref, 'k--', alpha=0.4, linewidth=1, label='3ⁿ reference')
ax2.legend(fontsize=9)

plt.tight_layout()
plt.savefig('expression_swell.png', dpi=150, bbox_inches='tight')
print("Saved: expression_swell.png")


#!/usr/bin/env python3
"""
Visualization: The Integration Barrier

Shows exp(-x^2) (EML-representable) vs its integral erf(x) (NOT elementary).
Demonstrates the fundamental asymmetry: differentiation preserves EML,
but integration can escape it.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy import special

x = np.linspace(-3, 3, 1000)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: The Gaussian (EML)
ax = axes[0, 0]
gaussian = np.exp(-x**2)
ax.plot(x, gaussian, linewidth=2.5, color='blue')
ax.fill_between(x, 0, gaussian, alpha=0.15, color='blue')
ax.set_title('exp(-x²) — IN the EML class\neml(-x², 1) = exp(-x²)', fontsize=12)
ax.set_xlabel('x', fontsize=11)
ax.set_ylabel('y', fontsize=11)
ax.grid(True, alpha=0.3)
ax.text(0.05, 0.95, 'EML: comp(exp, neg(mul(var, var)))',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.5))

# Panel 2: The Error Function (NOT EML)
ax = axes[0, 1]
erf = special.erf(x)
ax.plot(x, erf, linewidth=2.5, color='red')
ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
ax.axhline(y=-1, color='gray', linewidth=0.5, linestyle='--')
ax.set_title('erf(x) = (2/√π)∫₀ˣ exp(-t²)dt\nNOT in the EML class (Liouville 1835)', fontsize=12)
ax.set_xlabel('x', fontsize=11)
ax.set_ylabel('y', fontsize=11)
ax.grid(True, alpha=0.3)
ax.text(0.05, 0.95, 'No finite EML expression\ncan represent erf(x)',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

# Panel 3: Differentiation preserves EML
ax = axes[1, 0]
# d/dx exp(-x^2) = -2x * exp(-x^2)
deriv_gaussian = -2 * x * np.exp(-x**2)
ax.plot(x, gaussian, linewidth=2, color='blue', label='exp(-x²) [EML]')
ax.plot(x, deriv_gaussian, linewidth=2, color='green', linestyle='--', 
        label='d/dx exp(-x²) = -2x·exp(-x²) [EML]')
ax.set_title('Differentiation PRESERVES EML\n(derivative of EML is EML)', fontsize=12)
ax.set_xlabel('x', fontsize=11)
ax.set_ylabel('y', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: The asymmetry diagram
ax = axes[1, 1]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_aspect('equal')

# EML class circle
circle1 = plt.Circle((5, 5), 3, fill=False, linewidth=2.5, color='blue')
ax.add_patch(circle1)
ax.text(5, 5, 'EML\nClass', ha='center', va='center', fontsize=14, 
        fontweight='bold', color='blue')

# Differentiation arrow (stays inside)
ax.annotate('', xy=(5, 7.5), xytext=(6.5, 3.5),
            arrowprops=dict(arrowstyle='->', color='green', lw=2.5))
ax.text(7, 5.5, 'd/dx\n(stays in)', fontsize=10, color='green', fontweight='bold')

# Integration arrow (escapes)
ax.annotate('', xy=(9, 5), xytext=(7.5, 5),
            arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
ax.text(8.5, 6, '∫ dx\n(can escape!)', fontsize=10, color='red', fontweight='bold')

# erf outside
ax.text(9, 4, 'erf', fontsize=12, color='red', fontstyle='italic',
        ha='center', va='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

ax.set_title('The Fundamental Asymmetry\nof Calculus', fontsize=13)
ax.axis('off')

plt.tight_layout()
plt.savefig('integration_barrier.png', dpi=150, bbox_inches='tight')
print("Saved: integration_barrier.png")
