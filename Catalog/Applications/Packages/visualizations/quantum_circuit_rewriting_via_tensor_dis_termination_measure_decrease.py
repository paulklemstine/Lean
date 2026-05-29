"""
Visualization: Polynomial Interpretation Termination Measure

This script visualizes how the polynomial interpretation (polyInterp)
decreases with each normalization step, proving termination of the
distributive rewrite system for quantum circuits.

It shows the "penalized addition" trick: by assigning add nodes a
cost of a + b + 1 instead of a + b, distributing multiplication
over addition strictly decreases the total measure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"; CNOT = "CNOT"

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


# --- Build test expressions ---
H = Gate(QGate.H)
T = Gate(QGate.T)
I = Ident()

test_cases = [
    ("(H+T) ⊗ (H+T)", Par(Add(H, T), Add(H, T))),
    ("H ⊗ (T+H)", Par(H, Add(T, H))),
    ("(H+T) ⊗ ((H+T) ⊗ H)", Par(Add(H, T), Par(Add(H, T), H))),
    ("H ; (T+H)", Seq(H, Add(T, H))),
    ("((H+T)⊗I) ⊗ (H+T)", Par(Par(Add(H, T), I), Add(H, T))),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left plot: step-by-step measure decrease
ax = axes[0]
colors = plt.cm.Set2(np.linspace(0, 1, len(test_cases)))

for idx, (name, expr) in enumerate(test_cases):
    measures = [poly_interp(expr)]
    e = expr
    for _ in range(20):
        e_new = norm_step_deep(e)
        if e_new == e:
            break
        e = e_new
        measures.append(poly_interp(e))
    
    steps = list(range(len(measures)))
    ax.plot(steps, measures, 'o-', color=colors[idx], label=name, 
            markersize=8, linewidth=2)

ax.set_xlabel('Normalization Step', fontsize=12)
ax.set_ylabel('polyInterp (Termination Measure)', fontsize=12)
ax.set_title('Strict Decrease of Polynomial Interpretation', fontsize=13)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)

# Right plot: comparison of standard vs penalized interpretation
ax = axes[1]

# Show why standard ring interpretation gives equality
# but penalized interpretation gives strict decrease
n_values = range(2, 12)
standard = []  # (a+b) * c with standard add
penalized_lhs = []  # (a+b+1) * c
penalized_rhs = []  # a*c + b*c + 1

a, b = 2, 2  # atoms
for c in n_values:
    standard.append((a + b) * c)
    penalized_lhs.append((a + b + 1) * c)
    penalized_rhs.append(a * c + b * c + 1)

ax.plot(list(n_values), standard, 's--', color='gray', label='Standard: (a+b)·c', 
        markersize=6, linewidth=1.5)
ax.plot(list(n_values), penalized_lhs, 'o-', color='red', 
        label='Penalized LHS: (a+b+1)·c', markersize=7, linewidth=2)
ax.plot(list(n_values), penalized_rhs, '^-', color='blue', 
        label='Penalized RHS: a·c + b·c + 1', markersize=7, linewidth=2)

# Fill the gap showing strict decrease
ax.fill_between(list(n_values), penalized_rhs, penalized_lhs, 
                alpha=0.2, color='green', label='Strict decrease gap')

ax.set_xlabel('c (factor size)', fontsize=12)
ax.set_ylabel('Measure value', fontsize=12)
ax.set_title('The "+1 Penalty" Trick for Termination\n(a=b=2: atom values)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_termination.png', dpi=150, bbox_inches='tight')
print("Saved viz_termination.png")
