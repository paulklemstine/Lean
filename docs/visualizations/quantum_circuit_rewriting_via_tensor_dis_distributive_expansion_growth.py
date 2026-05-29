"""
Visualization: Expression Growth Under Distributive Expansion

This script visualizes how the number of summands (terms) in the
distributive normal form grows as expressions become more complex.
It demonstrates the combinatorial structure underlying quantum
parallelism: each tensor product of sums multiplies the number of paths.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"

def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))

def normalize(e):
    for _ in range(poly_interp(e)):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e

def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]

def expr_size(e):
    if isinstance(e, (Gate, Ident)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)


# --- Build test families ---
H = Gate(QGate.H)
T = Gate(QGate.T)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 1. Iterated tensor products of (H+T)
# (H+T)^⊗n has 2^n summands
ax = axes[0]
ns = list(range(1, 8))
summand_counts = []
sizes_orig = []
sizes_nf = []

for n in ns:
    e = Add(H, T)
    for _ in range(n - 1):
        e = Par(e, Add(H, T))
    nf = normalize(e)
    sc = len(collect_summands(nf))
    summand_counts.append(sc)
    sizes_orig.append(expr_size(e))
    sizes_nf.append(expr_size(nf))

ax.semilogy(ns, summand_counts, 'o-', color='blue', linewidth=2, 
            markersize=8, label='# summands')
ax.semilogy(ns, [2**n for n in ns], 's--', color='red', linewidth=1.5, 
            markersize=6, alpha=0.7, label='$2^n$ (predicted)')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('Number of summands (log scale)', fontsize=12)
ax.set_title('Summands in (H+T)$^{⊗n}$', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# 2. Size growth
ax = axes[1]
ax.plot(ns, sizes_orig, 'o-', color='green', linewidth=2, markersize=8, 
        label='Original size')
ax.plot(ns, sizes_nf, 's-', color='purple', linewidth=2, markersize=8, 
        label='Normal form size')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('AST node count', fontsize=12)
ax.set_title('Expression Size Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# 3. polyInterp values
ax = axes[2]
pi_values = []
for n in ns:
    e = Add(H, T)
    for _ in range(n - 1):
        e = Par(e, Add(H, T))
    pi_values.append(poly_interp(e))

ax.semilogy(ns, pi_values, 'D-', color='orange', linewidth=2, markersize=8,
            label='polyInterp')
# Theoretical: (2+2+1)^n = 5^n
ax.semilogy(ns, [5**n for n in ns], 'v--', color='gray', linewidth=1.5,
            markersize=6, alpha=0.7, label='$5^n$ (theoretical)')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('polyInterp value (log scale)', fontsize=12)
ax.set_title('Termination Measure Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Distributive Expansion: Quantum Parallelism as Combinatorial Growth\n'
             '"Each ⊗ of sums multiplies the number of computational paths"',
             fontsize=14, fontweight='bold', y=1.03)
plt.tight_layout()
plt.savefig('viz_expansion.png', dpi=150, bbox_inches='tight')
print("Saved viz_expansion.png")
