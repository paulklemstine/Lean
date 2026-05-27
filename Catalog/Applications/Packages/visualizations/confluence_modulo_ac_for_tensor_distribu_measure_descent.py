#!/usr/bin/env python3
"""
Visualization: distPotential measure descent during normalization.

Shows how the polynomial interpretation strictly decreases at each rewrite step,
proving termination of the tensor distributivity rewrite system.

Uses matplotlib to produce a static plot saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

# ─── Inline all needed types and functions ───

class Expr:
    pass

class ScalVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, ScalVar) and self.name == o.name
    def __hash__(self): return hash(('SV', self.name))

class VecVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, VecVar) and self.name == o.name
    def __hash__(self): return hash(('VV', self.name))

class MatVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, MatVar) and self.name == o.name
    def __hash__(self): return hash(('MV', self.name))

class ScalAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}+{self.right})"
    def __eq__(self, o): return isinstance(o, ScalAdd) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('SA', self.left, self.right))

class ScalMul(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}*{self.right})"
    def __eq__(self, o): return isinstance(o, ScalMul) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('SM', self.left, self.right))

class VecAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊕{self.right})"
    def __eq__(self, o): return isinstance(o, VecAdd) and self.left == o.left and self.right == o.right

class MatAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊞{self.right})"
    def __eq__(self, o): return isinstance(o, MatAdd) and self.left == o.left and self.right == o.right

class SmulVec(Expr):
    def __init__(self, s, v): self.scalar, self.vector = s, v
    def __repr__(self): return f"({self.scalar}•{self.vector})"
    def __eq__(self, o): return isinstance(o, SmulVec) and self.scalar == o.scalar and self.vector == o.vector

class SmulMat(Expr):
    def __init__(self, s, m): self.scalar, self.matrix = s, m
    def __repr__(self): return f"({self.scalar}⊙{self.matrix})"
    def __eq__(self, o): return isinstance(o, SmulMat) and self.scalar == o.scalar and self.matrix == o.matrix

class MulVec(Expr):
    def __init__(self, m, v): self.matrix, self.vector = m, v
    def __repr__(self): return f"({self.matrix}·{self.vector})"
    def __eq__(self, o): return isinstance(o, MulVec) and self.matrix == o.matrix and self.vector == o.vector

class Dot(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"⟨{self.left},{self.right}⟩"
    def __eq__(self, o): return isinstance(o, Dot) and self.left == o.left and self.right == o.right


def dist_potential(t):
    if isinstance(t, (ScalVar, VecVar, MatVar)): return 3
    if isinstance(t, (ScalAdd, VecAdd, MatAdd)):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    if isinstance(t, ScalMul):
        return dist_potential(t.left) * dist_potential(t.right)
    if isinstance(t, SmulVec):
        return dist_potential(t.scalar) * dist_potential(t.vector) + 1
    if isinstance(t, SmulMat):
        return dist_potential(t.scalar) * dist_potential(t.matrix) + 1
    if isinstance(t, MulVec):
        return dist_potential(t.matrix) * dist_potential(t.vector)
    if isinstance(t, Dot):
        return dist_potential(t.left) * dist_potential(t.right)
    return 0

def root_norm_step(t):
    if isinstance(t, MulVec):
        if isinstance(t.vector, VecAdd):
            return VecAdd(MulVec(t.matrix, t.vector.left), MulVec(t.matrix, t.vector.right))
        if isinstance(t.matrix, MatAdd):
            return VecAdd(MulVec(t.matrix.left, t.vector), MulVec(t.matrix.right, t.vector))
        if isinstance(t.matrix, SmulMat):
            return SmulVec(t.matrix.scalar, MulVec(t.matrix.matrix, t.vector))
    if isinstance(t, SmulVec) and isinstance(t.vector, VecAdd):
        return VecAdd(SmulVec(t.scalar, t.vector.left), SmulVec(t.scalar, t.vector.right))
    if isinstance(t, SmulMat) and isinstance(t.matrix, MatAdd):
        return MatAdd(SmulMat(t.scalar, t.matrix.left), SmulMat(t.scalar, t.matrix.right))
    if isinstance(t, Dot):
        if isinstance(t.left, VecAdd):
            return ScalAdd(Dot(t.left.left, t.right), Dot(t.left.right, t.right))
        if isinstance(t.right, VecAdd):
            return ScalAdd(Dot(t.left, t.right.left), Dot(t.left, t.right.right))
        if isinstance(t.left, SmulVec):
            return ScalMul(t.left.scalar, Dot(t.left.vector, t.right))
    if isinstance(t, ScalMul) and isinstance(t.right, ScalAdd):
        return ScalAdd(ScalMul(t.left, t.right.left), ScalMul(t.left, t.right.right))
    return t

# ─── Build test cases and collect measure data ───

a, b = ScalVar("a"), ScalVar("b")
v, w, x = VecVar("v"), VecVar("w"), VecVar("x")
A, B = MatVar("A"), MatVar("B")

test_cases = {
    "A·(v⊕w)": MulVec(A, VecAdd(v, w)),
    "(A⊞B)·v": MulVec(MatAdd(A, B), v),
    "(a⊙A)·v": MulVec(SmulMat(a, A), v),
    "⟨v⊕w, x⟩": Dot(VecAdd(v, w), x),
    "⟨a•v, w⟩": Dot(SmulVec(a, v), w),
    "a*(b+⟨v,w⟩)": ScalMul(a, ScalAdd(b, Dot(v, w))),
}

fig, axes = plt.subplots(2, 3, figsize=(14, 8))
fig.suptitle("Polynomial Interpretation Measure: Strict Descent Under Rewriting",
             fontsize=14, fontweight='bold')

for idx, (name, term) in enumerate(test_cases.items()):
    ax = axes[idx // 3][idx % 3]
    measures = [dist_potential(term)]
    labels = [str(term)[:30]]
    current = term
    for _ in range(20):
        next_t = root_norm_step(current)
        if next_t == current:
            break
        current = next_t
        measures.append(dist_potential(current))
        labels.append(str(current)[:30])

    steps = list(range(len(measures)))
    ax.bar(steps, measures, color=['#2196F3' if i == 0 else '#4CAF50' if i == len(measures)-1 else '#FF9800'
                                    for i in range(len(measures))],
           edgecolor='black', linewidth=0.5)
    ax.set_title(name, fontsize=11)
    ax.set_xlabel("Rewrite Step")
    ax.set_ylabel("distPotential")
    ax.set_xticks(steps)

    # Annotate decrease
    for i in range(len(measures) - 1):
        delta = measures[i] - measures[i+1]
        ax.annotate(f"−{delta}", xy=(i + 0.5, (measures[i] + measures[i+1]) / 2),
                   fontsize=8, color='red', ha='center')

plt.tight_layout()
plt.savefig("viz_measure_descent.png", dpi=150, bbox_inches='tight')
print("Saved viz_measure_descent.png")
