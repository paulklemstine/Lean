#!/usr/bin/env python3
"""
EML Differential Algebra Demo

Demonstrates the EML Derivation Calculus: symbolic differentiation,
derivation towers, expression size growth, and semantic evaluation.
"""

import math
from typing import Union

# --- Expression AST ---

class Expr:
    """Base class for EML expressions."""
    pass

class Cnst(Expr):
    def __init__(self, c: float):
        self.c = c
    def __repr__(self):
        return f"{self.c}"

class Var(Expr):
    def __repr__(self):
        return "x"

class Add(Expr):
    def __init__(self, e1: Expr, e2: Expr):
        self.e1, self.e2 = e1, e2
    def __repr__(self):
        return f"({self.e1} + {self.e2})"

class Mul(Expr):
    def __init__(self, e1: Expr, e2: Expr):
        self.e1, self.e2 = e1, e2
    def __repr__(self):
        return f"({self.e1} * {self.e2})"

class Neg(Expr):
    def __init__(self, e: Expr):
        self.e = e
    def __repr__(self):
        return f"(-{self.e})"

class Inv(Expr):
    def __init__(self, e: Expr):
        self.e = e
    def __repr__(self):
        return f"(1/{self.e})"

class Eexp(Expr):
    def __init__(self, e: Expr):
        self.e = e
    def __repr__(self):
        return f"exp({self.e})"

class Elog(Expr):
    def __init__(self, e: Expr):
        self.e = e
    def __repr__(self):
        return f"log({self.e})"

# --- Evaluation ---

def evaluate(e: Expr, x: float) -> float:
    """Evaluate an EML expression at x."""
    if isinstance(e, Cnst): return e.c
    if isinstance(e, Var): return x
    if isinstance(e, Add): return evaluate(e.e1, x) + evaluate(e.e2, x)
    if isinstance(e, Mul): return evaluate(e.e1, x) * evaluate(e.e2, x)
    if isinstance(e, Neg): return -evaluate(e.e, x)
    if isinstance(e, Inv): return 1.0 / evaluate(e.e, x)
    if isinstance(e, Eexp): return math.exp(evaluate(e.e, x))
    if isinstance(e, Elog): return math.log(evaluate(e.e, x))
    raise ValueError(f"Unknown expression: {e}")

# --- Symbolic Differentiation ---

def sdiff(e: Expr) -> Expr:
    """Symbolically differentiate an EML expression."""
    if isinstance(e, Cnst): return Cnst(0)
    if isinstance(e, Var): return Cnst(1)
    if isinstance(e, Add): return Add(sdiff(e.e1), sdiff(e.e2))
    if isinstance(e, Mul): return Add(Mul(sdiff(e.e1), e.e2), Mul(e.e1, sdiff(e.e2)))
    if isinstance(e, Neg): return Neg(sdiff(e.e))
    if isinstance(e, Inv): return Neg(Mul(sdiff(e.e), Mul(Inv(e.e), Inv(e.e))))
    if isinstance(e, Eexp): return Mul(sdiff(e.e), Eexp(e.e))
    if isinstance(e, Elog): return Mul(sdiff(e.e), Inv(e.e))
    raise ValueError(f"Unknown expression: {e}")

# --- Expression Size ---

def size(e: Expr) -> int:
    """Count nodes in an expression tree."""
    if isinstance(e, (Cnst, Var)): return 1
    if isinstance(e, (Add, Mul)): return 1 + size(e.e1) + size(e.e2)
    if isinstance(e, (Neg, Inv, Eexp, Elog)): return 1 + size(e.e)
    raise ValueError(f"Unknown expression: {e}")

# --- Derivation Tower ---

def derivation_tower(e: Expr, n: int) -> list[Expr]:
    """Compute the first n elements of the derivation tower."""
    tower = [e]
    for _ in range(n):
        tower.append(sdiff(tower[-1]))
    return tower

# === DEMOS ===

print("=" * 60)
print("EML Differential Algebra Demo")
print("=" * 60)

# Demo 1: Basic symbolic differentiation
print("\n--- Demo 1: Symbolic Differentiation ---")
x_squared = Mul(Var(), Var())
print(f"Expression: {x_squared}")
print(f"Derivative: {sdiff(x_squared)}")
print(f"d/dx[x²] at x=3: {evaluate(sdiff(x_squared), 3.0)} (expected: 6.0)")

# Demo 2: Exponential fixed point
print("\n--- Demo 2: Exponential Fixed Point ---")
exp_x = Eexp(Var())
print(f"Expression: {exp_x}")
for n in range(5):
    tower_n = derivation_tower(exp_x, n)[-1]
    val = evaluate(tower_n, 1.0)
    print(f"  iterSdiff({n}, exp(x)) at x=1: {val:.6f} (exp(1) = {math.e:.6f})")

# Demo 3: Expression size growth
print("\n--- Demo 3: Expression Size Growth (Derivation Tower) ---")
for base_name, base_expr in [("exp(x)", Eexp(Var())),
                                ("x²", Mul(Var(), Var())),
                                ("log(x)", Elog(Var()))]:
    print(f"\n  {base_name}:")
    tower = derivation_tower(base_expr, 6)
    for i, e in enumerate(tower):
        print(f"    n={i}: size={size(e)}")

# Demo 4: The logarithm obstruction
print("\n--- Demo 4: Why Reciprocal is Needed ---")
log_x = Elog(Var())
d_log = sdiff(log_x)
print(f"d/dx[log(x)] = {d_log}")
print(f"This contains Inv (reciprocal) — NOT in the basic EML class!")
print(f"Evaluation at x=2: {evaluate(d_log, 2.0)} (expected: 0.5)")

# Demo 5: Chain rule verification
print("\n--- Demo 5: Chain Rule for exp(x²) ---")
exp_x2 = Eexp(Mul(Var(), Var()))
d_exp_x2 = sdiff(exp_x2)
print(f"d/dx[exp(x²)] = {d_exp_x2}")
x_val = 1.0
symbolic_val = evaluate(d_exp_x2, x_val)
exact_val = 2 * x_val * math.exp(x_val ** 2)
print(f"At x={x_val}: symbolic={symbolic_val:.6f}, exact={exact_val:.6f}")

# Demo 6: Polynomial termination
print("\n--- Demo 6: Polynomial Termination ---")
x3 = Mul(Var(), Mul(Var(), Var()))
print(f"Expression: x³")
tower = derivation_tower(x3, 5)
for i, e in enumerate(tower):
    val = evaluate(e, 2.0)
    print(f"  d^{i}/dx^{i}[x³] at x=2: {val}")

# Demo 7: Size bound verification
print("\n--- Demo 7: Quadratic Size Bound Verification ---")
test_exprs = [
    ("x", Var()),
    ("exp(x)", Eexp(Var())),
    ("x²", Mul(Var(), Var())),
    ("1/x", Inv(Var())),
    ("exp(exp(x))", Eexp(Eexp(Var()))),
]
print(f"{'Expression':<20} {'size(e)':<10} {'size(sdiff)':<12} {'3*size²':<10} {'OK?':<5}")
for name, expr in test_exprs:
    s = size(expr)
    ds = size(sdiff(expr))
    bound = 3 * s * s
    ok = ds <= bound
    print(f"{name:<20} {s:<10} {ds:<12} {bound:<10} {'✓' if ok else '✗':<5}")

print("\n" + "=" * 60)
print("All demos complete.")


#!/usr/bin/env python3
"""
Visualization: Derivation Tower Size Growth

Shows how expression size grows under iterated symbolic differentiation
for different expression types (polynomial, exponential, logarithmic).
"""

import matplotlib.pyplot as plt
import math

def sdiff_size_growth(base_size: int, expr_type: str, n_steps: int) -> list[int]:
    """Simulate size growth for different expression classes."""
    from algorithms import (Var, Mul, Eexp, Elog, Inv,
                           derivation_tower, expr_size)
    
    if expr_type == "polynomial":
        e = Mul(Var(), Var())  # x²
    elif expr_type == "exponential":
        e = Eexp(Var())  # exp(x)
    elif expr_type == "logarithmic":
        e = Elog(Var())  # log(x)
    elif expr_type == "reciprocal":
        e = Inv(Var())  # 1/x
    else:
        raise ValueError(f"Unknown type: {expr_type}")
    
    tower = derivation_tower(e, n_steps)
    return [expr_size(t) for t in tower]

# Compute tower sizes
n_steps = 8
types = {
    "x² (polynomial)": "polynomial",
    "exp(x) (exponential)": "exponential",
    "log(x) (logarithmic)": "logarithmic",
    "1/x (reciprocal)": "reciprocal",
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for label, etype in types.items():
    try:
        sizes = sdiff_size_growth(0, etype, n_steps)
        ax1.plot(range(len(sizes)), sizes, 'o-', label=label, linewidth=2, markersize=6)
        # Log scale
        log_sizes = [math.log2(s) if s > 0 else 0 for s in sizes]
        ax2.plot(range(len(log_sizes)), log_sizes, 'o-', label=label, linewidth=2, markersize=6)
    except RecursionError:
        print(f"Recursion limit for {label} at step {n_steps}")

ax1.set_xlabel("Differentiation Step n", fontsize=12)
ax1.set_ylabel("Expression Size (nodes)", fontsize=12)
ax1.set_title("Derivation Tower: Expression Size Growth", fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax2.set_xlabel("Differentiation Step n", fontsize=12)
ax2.set_ylabel("log₂(Expression Size)", fontsize=12)
ax2.set_title("Derivation Tower: Log-Scale Size Growth", fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("tower_growth.png", dpi=150, bbox_inches='tight')
print("Saved tower_growth.png")
plt.close()

# Second visualization: Semantic vs Syntactic behavior for exp
fig2, (ax3, ax4) = plt.subplots(1, 2, figsize=(14, 6))

from algorithms import Eexp, Var, derivation_tower, evaluate, expr_size

exp_x = Eexp(Var())
tower = derivation_tower(exp_x, 6)

# Semantic values at x=1
x_val = 1.0
semantic_vals = [evaluate(t, x_val) for t in tower]
syntactic_sizes = [expr_size(t) for t in tower]

ax3.bar(range(len(semantic_vals)), semantic_vals, color='steelblue', alpha=0.8)
ax3.axhline(y=math.e, color='red', linestyle='--', linewidth=2, label=f'exp(1) = {math.e:.4f}')
ax3.set_xlabel("Differentiation Step n", fontsize=12)
ax3.set_ylabel("Evaluation at x=1", fontsize=12)
ax3.set_title("Semantic Values: Constant at exp(1)", fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, axis='y')

ax4.bar(range(len(syntactic_sizes)), syntactic_sizes, color='coral', alpha=0.8)
ax4.set_xlabel("Differentiation Step n", fontsize=12)
ax4.set_ylabel("Expression Size (nodes)", fontsize=12)
ax4.set_title("Syntactic Size: Exponential Growth", fontsize=14)
ax4.grid(True, alpha=0.3, axis='y')

fig2.suptitle("exp(x) Derivation Tower: Constant Semantics, Explosive Syntax", fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig("exp_tower_contrast.png", dpi=150, bbox_inches='tight')
print("Saved exp_tower_contrast.png")
plt.close()
