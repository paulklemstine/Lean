#!/usr/bin/env python3
"""
EML Category: Numerical Demonstrations

Demonstrates the key constructions of the EML category:
- EML primitive eml(x,y) = exp(x) - log(y)
- Composition of EML maps
- Pairing (product structure)
- Currying (parameter specialization)
- Iterated exponentials and depth hierarchy
- Log-affine maps and their affine logarithmic coordinates
"""

import numpy as np
from typing import Callable, Tuple, List

# ============================================================
# Core EML operations
# ============================================================

def eml(x: float, y: float) -> float:
    """The EML primitive: eml(x,y) = exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

def scalar_eml_coord(i: int) -> Callable:
    """Coordinate projection x_i"""
    return lambda x: x[i]

def scalar_eml_const(c: float) -> Callable:
    return lambda x: c

def scalar_eml_add(f: Callable, g: Callable) -> Callable:
    return lambda x: f(x) + g(x)

def scalar_eml_mul(f: Callable, g: Callable) -> Callable:
    return lambda x: f(x) * g(x)

def scalar_eml_exp(f: Callable) -> Callable:
    return lambda x: np.exp(f(x))

def scalar_eml_log(f: Callable) -> Callable:
    return lambda x: np.log(f(x))

# ============================================================
# Demo 1: EML primitive values
# ============================================================
print("=" * 60)
print("DEMO 1: EML Primitive eml(x,y) = exp(x) - log(y)")
print("=" * 60)
test_pairs = [(0, 1), (1, 1), (0, np.e), (1, np.e), (2, 3)]
for x, y in test_pairs:
    print(f"  eml({x:.2f}, {y:.4f}) = {eml(x, y):.6f}")

# ============================================================
# Demo 2: Composition closure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Composition of EML Maps")
print("=" * 60)

# f: R^2 -> R^2 defined by f(x) = (exp(x0), x0 + x1)
f = lambda x: np.array([np.exp(x[0]), x[0] + x[1]])

# g: R^2 -> R^1 defined by g(y) = log(y0) * y1
g = lambda y: np.array([np.log(y[0]) * y[1]])

# Composition g ∘ f: R^2 -> R^1
# g(f(x)) = log(exp(x0)) * (x0 + x1) = x0 * (x0 + x1)
gf = lambda x: g(f(x))

x_test = np.array([2.0, 3.0])
print(f"  f({x_test}) = {f(x_test)}")
print(f"  g(f({x_test})) = {gf(x_test)}")
print(f"  Direct: x0*(x0+x1) = {x_test[0] * (x_test[0] + x_test[1])}")

# ============================================================
# Demo 3: Pairing (Product Structure)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Pairing — Product Structure of EMLCat")
print("=" * 60)

# f: R^2 -> R^1, g: R^2 -> R^1
f1 = lambda x: np.array([np.exp(x[0])])
g1 = lambda x: np.array([np.log(np.abs(x[1]) + 1)])

# Pairing (f, g): R^2 -> R^2
pair = lambda x: np.concatenate([f1(x), g1(x)])

x_test = np.array([1.0, 2.0])
print(f"  f({x_test}) = {f1(x_test)}")
print(f"  g({x_test}) = {g1(x_test)}")
print(f"  (f,g)({x_test}) = {pair(x_test)}")

# ============================================================
# Demo 4: Currying (Parameter Specialization)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Currying — Parameter Specialization")
print("=" * 60)

# F: R^(2+1) -> R^1, F(theta, x) = exp(theta_0 * x) + theta_1
F = lambda v: np.array([np.exp(v[0] * v[2]) + v[1]])

# Fix theta = (0.5, 3.0)
theta = np.array([0.5, 3.0])

# Curried: f_theta(x) = exp(0.5 * x) + 3
f_theta = lambda x: F(np.concatenate([theta, x]))

for x_val in [0.0, 1.0, 2.0, 3.0]:
    x_arr = np.array([x_val])
    print(f"  f_theta({x_val}) = {f_theta(x_arr)[0]:.4f}"
          f"  [= exp(0.5*{x_val}) + 3 = {np.exp(0.5*x_val) + 3:.4f}]")

# ============================================================
# Demo 5: Iterated Exponentials — Depth Hierarchy
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Iterated Exponentials — Depth Hierarchy")
print("=" * 60)

def iter_exp(k: int, x: float) -> float:
    """k-fold iterated exponential: exp(exp(...exp(x)...))"""
    result = x
    for _ in range(k):
        result = np.exp(result)
    return result

x0 = 0.1
print(f"  x = {x0}")
for k in range(6):
    val = iter_exp(k, x0)
    if val < 1e15:
        print(f"  exp^[{k}](x) = {val:.6f}  (depth={k}, nodes={k+1})")
    else:
        print(f"  exp^[{k}](x) = {val:.2e}  (depth={k}, nodes={k+1})")

print("\n  Key insight: depth grows linearly while values grow tetrationally.")
print("  The tree exp(exp(...exp(x)...)) with k layers has:")
print("    depth  = k     (each exp adds 1 to depth)")
print("    nodes  = k + 1 (k exp nodes + 1 coord node)")
print("  This is OPTIMAL: you can't compute the k-fold exp at depth < k.")

# ============================================================
# Demo 6: Log-Affine Maps
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Log-Affine Maps and the Log Functor")
print("=" * 60)

def log_affine(w: np.ndarray, c: float) -> Callable:
    """Log-affine map: f(x) = exp(sum_i w_i * log(x_i) + c)"""
    return lambda x: np.exp(np.sum(w * np.log(x)) + c)

# Example: f(x) = x_0^2 * x_1^0.5 * e^1 (w = [2, 0.5], c = 1)
w1 = np.array([2.0, 0.5])
c1 = 1.0
f_la = log_affine(w1, c1)

# Another: g(x) = x_0^(-1) * x_1^3 * e^0 (w = [-1, 3], c = 0)
w2 = np.array([-1.0, 3.0])
c2 = 0.0
g_la = log_affine(w2, c2)

# Product: (fg)(x) should be log-affine with w = w1+w2, c = c1+c2
w_prod = w1 + w2
c_prod = c1 + c2
fg_la = log_affine(w_prod, c_prod)

x_test = np.array([2.0, 3.0])
print(f"  x = {x_test}")
print(f"  f(x) = exp(2*log(2) + 0.5*log(3) + 1) = {f_la(x_test):.6f}")
print(f"  g(x) = exp(-log(2) + 3*log(3))        = {g_la(x_test):.6f}")
print(f"  f(x)*g(x) = {f_la(x_test) * g_la(x_test):.6f}")
print(f"  (fg)(x) via merged weights             = {fg_la(x_test):.6f}")
print(f"  Match: {np.isclose(f_la(x_test) * g_la(x_test), fg_la(x_test))}")

print("\n  Log-affine -> affine in log coordinates:")
print(f"  log(f(x)) = {np.log(f_la(x_test)):.6f}")
print(f"  sum(w*log(x))+c = {np.sum(w1 * np.log(x_test)) + c1:.6f}")
print(f"  Match: {np.isclose(np.log(f_la(x_test)), np.sum(w1 * np.log(x_test)) + c1)}")

# ============================================================
# Demo 7: EML Category Summary
# ============================================================
print("\n" + "=" * 60)
print("SUMMARY: EMLCat Category Structure")
print("=" * 60)
print("""
  Objects:  Natural numbers n (representing R^n)
  Morphisms: EML-computable maps R^n -> R^m
  
  Identity:    id_n : R^n -> R^n                     ✓ Proved
  Composition: g ∘ f : R^n -> R^k if f,g EML         ✓ Proved
  Associativity: h ∘ (g ∘ f) = (h ∘ g) ∘ f          ✓ Proved (definitional)
  Terminal:    !_n : R^n -> R^0                       ✓ Proved
  Products:    (f,g) : R^n -> R^(m+k)                ✓ Proved
  Projections: π_1, π_2                              ✓ Proved
  Diagonal:    Δ : R^n -> R^(n+n)                    ✓ Proved
  Swap:        σ : R^(m+k) -> R^(k+m)               ✓ Proved
  Currying:    f(θ,·) : R^n -> R^m for fixed θ       ✓ Proved
  
  NOT Cartesian closed: exponential [R^n, R^m] does not exist
  (EML maps have unbounded complexity, cannot be finitely parameterized)
  
  Depth hierarchy: exp^[k] has depth exactly k        ✓ Proved
  Size-depth inequality: depth < nodeCount             ✓ Proved
""")

if __name__ == "__main__":
    pass


#!/usr/bin/env python3
"""Visualization: EML Depth Hierarchy — Iterated Exponentials"""
import matplotlib.pyplot as plt
import numpy as np

def iter_exp(k, x):
    result = x
    for _ in range(k):
        result = np.exp(np.clip(result, -100, 50))
    return result

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Growth rates of iterated exponentials
ax1 = axes[0]
x = np.linspace(-2, 2, 500)
for k in range(5):
    y = np.array([iter_exp(k, xi) for xi in x])
    y = np.clip(y, -10, 100)
    ax1.plot(x, y, label=f'exp^[{k}](x)', linewidth=2)
ax1.set_ylim(-5, 50)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('Iterated Exponentials: exp^[k](x)', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.axvline(x=0, color='black', linewidth=0.5)

# Panel 2: Depth vs Node Count
ax2 = axes[1]
ks = list(range(8))
depths = ks  # depth = k
nodes = [k + 1 for k in ks]  # nodes = k + 1
ax2.bar([k - 0.2 for k in ks], depths, 0.35, label='Depth', color='steelblue', alpha=0.8)
ax2.bar([k + 0.2 for k in ks], nodes, 0.35, label='Node Count', color='coral', alpha=0.8)
ax2.set_xlabel('k (number of exp layers)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('iterExpTree\': Depth = k, Nodes = k+1', fontsize=14)
ax2.legend(fontsize=11)
ax2.set_xticks(ks)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_depth_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_depth_hierarchy.png")


#!/usr/bin/env python3
"""Visualization: Log-Affine Maps and the Log Functor"""
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: A log-affine function in original coordinates
ax1 = axes[0]
x = np.linspace(0.1, 5, 200)
# f(x) = exp(2*log(x) + 1) = e * x^2
f = np.exp(2 * np.log(x) + 1)
ax1.plot(x, f, 'b-', linewidth=2, label=r'$f(x) = e \cdot x^2$')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('Log-Affine Map (Original Coords)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Same function in log coordinates
ax2 = axes[1]
log_x = np.log(x)
log_f = np.log(f)
ax2.plot(log_x, log_f, 'r-', linewidth=2, label=r'$\log f(x) = 2\log x + 1$')
# Show it's linear
ax2.plot(log_x, 2 * log_x + 1, 'k--', linewidth=1, alpha=0.5, label='Affine: 2t + 1')
ax2.set_xlabel('log(x)', fontsize=12)
ax2.set_ylabel('log(f(x))', fontsize=12)
ax2.set_title('Log-Affine → Affine (Log Coords)', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Panel 3: Multiplicative closure
ax3 = axes[2]
# f(x) = e * x^2, g(x) = x^(-0.5)
f_vals = np.exp(2 * np.log(x) + 1)
g_vals = np.exp(-0.5 * np.log(x))
fg_vals = f_vals * g_vals
fg_direct = np.exp((2 - 0.5) * np.log(x) + 1)

ax3.plot(x, f_vals, 'b-', linewidth=2, label=r'$f = e \cdot x^2$', alpha=0.7)
ax3.plot(x, g_vals, 'g-', linewidth=2, label=r'$g = x^{-1/2}$', alpha=0.7)
ax3.plot(x, fg_vals, 'r-', linewidth=2.5, label=r'$f \cdot g = e \cdot x^{3/2}$')
ax3.plot(x, fg_direct, 'k--', linewidth=1, alpha=0.4, label='Via merged weights')
ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('value', fontsize=12)
ax3.set_title('Multiplicative Closure', fontsize=13)
ax3.set_ylim(0, 30)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_log_affine.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_log_affine.png")
