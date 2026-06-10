#!/usr/bin/env python3
"""
EML Stone-Weierstrass Demo: Demonstrating the Monomial Depth Theorem
and EML approximation of continuous functions.
"""

import numpy as np

# =============================================================
# EML Term Language (Python implementation)
# =============================================================

class EMLTerm:
    """Abstract base for EML terms."""
    pass

class Const(EMLTerm):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return f"{self.c}"

class Var(EMLTerm):
    def eval(self, x: float) -> float:
        return x
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class Exp(EMLTerm):
    def __init__(self, t: EMLTerm):
        self.t = t
    def eval(self, x: float) -> float:
        return np.exp(self.t.eval(x))
    def depth(self) -> int:
        return self.t.depth() + 1
    def size(self) -> int:
        return self.t.size() + 1
    def __repr__(self):
        return f"exp({self.t})"

class Log(EMLTerm):
    def __init__(self, t: EMLTerm):
        self.t = t
    def eval(self, x: float) -> float:
        return np.log(self.t.eval(x))
    def depth(self) -> int:
        return self.t.depth() + 1
    def size(self) -> int:
        return self.t.size() + 1
    def __repr__(self):
        return f"log({self.t})"

class Add(EMLTerm):
    def __init__(self, s: EMLTerm, t: EMLTerm):
        self.s, self.t = s, t
    def eval(self, x: float) -> float:
        return self.s.eval(x) + self.t.eval(x)
    def depth(self) -> int:
        return max(self.s.depth(), self.t.depth()) + 1
    def size(self) -> int:
        return self.s.size() + self.t.size() + 1
    def __repr__(self):
        return f"({self.s} + {self.t})"

class Mul(EMLTerm):
    def __init__(self, s: EMLTerm, t: EMLTerm):
        self.s, self.t = s, t
    def eval(self, x: float) -> float:
        return self.s.eval(x) * self.t.eval(x)
    def depth(self) -> int:
        return max(self.s.depth(), self.t.depth()) + 1
    def size(self) -> int:
        return self.s.size() + self.t.size() + 1
    def __repr__(self):
        return f"({self.s} * {self.t})"


def monomial_term(n: int) -> EMLTerm:
    """Construct the EML term for x^n = exp(n * log(x)) at depth 3."""
    return Exp(Mul(Const(float(n)), Log(Var())))


# =============================================================
# Demo 1: Monomial Depth Theorem
# =============================================================
print("=" * 60)
print("DEMO 1: Monomial Depth Theorem")
print("=" * 60)
print()
print("The EML term exp(n * log(x)) evaluates to x^n")
print("with depth exactly 3, independent of n.")
print()

x_test = 2.5
for n in [1, 2, 5, 10, 100, 500]:
    term = monomial_term(n)
    eml_val = term.eval(x_test)
    true_val = x_test ** n
    rel_error = abs(eml_val - true_val) / max(abs(true_val), 1e-300)
    print(f"  n={n:4d}: depth={term.depth()}, size={term.size()}, "
          f"x^n = {true_val:.6e}, EML = {eml_val:.6e}, "
          f"rel_error = {rel_error:.2e}")

print()
print("Key insight: depth is always 3, size is always 5,")
print("regardless of the exponent n.")


# =============================================================
# Demo 2: Depth non-uniqueness
# =============================================================
print()
print("=" * 60)
print("DEMO 2: Depth Non-Uniqueness")
print("=" * 60)
print()
print("The identity function has two EML representations:")
print("  var        (depth 0)")
print("  log(exp(x)) (depth 2)")
print()

id_var = Var()
id_logexp = Log(Exp(Var()))

for x in [0.5, 1.0, 2.0, np.pi, -1.0]:
    v1 = id_var.eval(x)
    v2 = id_logexp.eval(x)
    print(f"  x={x:8.4f}: var(x) = {v1:.10f}, log(exp(x)) = {v2:.10f}, "
          f"diff = {abs(v1 - v2):.2e}")


# =============================================================
# Demo 3: EML Approximation of sin(x)
# =============================================================
print()
print("=" * 60)
print("DEMO 3: EML Approximation of sin(x) on [0.1, 3]")
print("=" * 60)
print()
print("Using Taylor series: sin(x) ≈ x - x³/6 + x⁵/120 - x⁷/5040")
print("Each monomial x^k = exp(k * log(x)) has EML depth 3.")
print()


def taylor_sin_eml(N: int) -> EMLTerm:
    """Build EML term for Taylor approximation of sin(x) with N terms."""
    # sin(x) = sum_{k=0}^{N-1} (-1)^k * x^(2k+1) / (2k+1)!
    import math
    terms = []
    for k in range(N):
        coeff = (-1)**k / math.factorial(2*k + 1)
        # coeff * x^(2k+1) = coeff * exp((2k+1) * log(x))
        term = Mul(Const(coeff), monomial_term(2*k + 1))
        terms.append(term)
    # Sum them up in a binary tree
    while len(terms) > 1:
        new_terms = []
        for i in range(0, len(terms), 2):
            if i + 1 < len(terms):
                new_terms.append(Add(terms[i], terms[i+1]))
            else:
                new_terms.append(terms[i])
        terms = new_terms
    return terms[0]


xs = np.linspace(0.1, 3.0, 100)

for N in [2, 3, 4, 5]:
    term = taylor_sin_eml(N)
    errors = [abs(term.eval(x) - np.sin(x)) for x in xs]
    max_err = max(errors)
    print(f"  {N} Taylor terms: depth={term.depth()}, size={term.size()}, "
          f"max_error={max_err:.6e}")

print()
print("As N increases, the approximation improves while depth grows")
print("only logarithmically (O(log N) for the binary addition tree).")


# =============================================================
# Demo 4: EML vs Polynomial depth comparison
# =============================================================
print()
print("=" * 60)
print("DEMO 4: Depth Comparison — EML vs Arithmetic Circuits")
print("=" * 60)
print()
print("Computing x^n: arithmetic circuits need depth Θ(log n),")
print("EML circuits need depth 3.")
print()

for n in [2, 4, 8, 16, 32, 64, 128, 256, 1024]:
    arith_depth = int(np.ceil(np.log2(n))) if n > 1 else 1
    eml_depth = 3
    compression = arith_depth / eml_depth
    print(f"  n={n:4d}: arithmetic depth ≥ {arith_depth:2d}, "
          f"EML depth = {eml_depth}, "
          f"compression ratio = {compression:.1f}x")

print()
print("The compression ratio grows as O(log n / 3),")
print("demonstrating exponential depth advantage of EML.")


#!/usr/bin/env python3
"""
Visualization: EML Monomial Depth Theorem and Approximation.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml_monomial_eval(n, x):
    """Evaluate exp(n * log(x)) = x^n for x > 0."""
    return np.exp(n * np.log(x))

# ---- Figure 1: Monomial depth compression ----
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: EML vs true monomials
ax = axes[0]
xs = np.linspace(0.5, 2.0, 200)
for n in [1, 2, 5, 10, 20]:
    ax.plot(xs, eml_monomial_eval(n, xs), label=f'x^{n} (depth 3)')
ax.set_xlabel('x')
ax.set_ylabel('x^n')
ax.set_title('Monomials via EML (all depth 3)')
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Depth comparison
ax = axes[1]
ns = np.arange(1, 65)
arith_depth = np.ceil(np.log2(ns + 1)).astype(int)
eml_depth = np.full_like(ns, 3)
ax.bar(ns - 0.2, arith_depth, width=0.4, label='Arithmetic depth', alpha=0.7)
ax.bar(ns + 0.2, eml_depth, width=0.4, label='EML depth', alpha=0.7)
ax.set_xlabel('Monomial degree n')
ax.set_ylabel('Circuit depth')
ax.set_title('Depth: Arithmetic vs EML')
ax.legend()
ax.set_xlim(0, 33)
ax.grid(True, alpha=0.3)

# Panel 3: Approximation of sin(x) by EML Taylor terms
ax = axes[2]
xs = np.linspace(0.1, 3.0, 200)
ax.plot(xs, np.sin(xs), 'k-', linewidth=2, label='sin(x)')

from math import factorial

for N in [1, 2, 3, 4]:
    approx = np.zeros_like(xs)
    for k in range(N):
        coeff = (-1)**k / factorial(2*k + 1)
        approx += coeff * eml_monomial_eval(2*k + 1, xs)
    ax.plot(xs, approx, '--', label=f'{N}-term EML Taylor', alpha=0.7)

ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('EML Approximation of sin(x)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(-1.5, 2.5)

plt.tight_layout()
plt.savefig('eml_visualization.png', dpi=150, bbox_inches='tight')
print("Saved eml_visualization.png")

# ---- Figure 2: Depth filtration ----
fig2, ax2 = plt.subplots(1, 1, figsize=(10, 6))

# Show what functions are available at each depth level
xs = np.linspace(0.5, 2.5, 200)
depth_colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

# Depth 0: constants and identity
ax2.fill_between(xs, 0, xs, alpha=0.15, color=depth_colors[0])
ax2.plot(xs, xs, color=depth_colors[0], label='Depth 0: x (identity)')
ax2.axhline(y=1, color=depth_colors[0], linestyle=':', alpha=0.5, label='Depth 0: const(1)')

# Depth 1: exp(x), log(x)
ax2.plot(xs, np.exp(xs), color=depth_colors[1], label='Depth 1: exp(x)')
ax2.plot(xs, np.log(xs), color=depth_colors[1], linestyle='--', label='Depth 1: log(x)')

# Depth 2: exp(exp(x)), exp(x)+log(x)
ax2.plot(xs, np.exp(xs) + np.log(xs), color=depth_colors[2],
         label='Depth 2: exp(x)+log(x)')

# Depth 3: x^n for various n
for n in [2, 5]:
    ax2.plot(xs, xs**n, color=depth_colors[3], alpha=0.6,
             label=f'Depth 3: x^{n}' if n == 2 else f'          x^{n}')

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('f(x)', fontsize=12)
ax2.set_title('EML Depth Filtration: Functions at Each Depth Level', fontsize=14)
ax2.legend(loc='upper left', fontsize=9)
ax2.set_ylim(-2, 15)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_depth_filtration.png', dpi=150, bbox_inches='tight')
print("Saved eml_depth_filtration.png")
