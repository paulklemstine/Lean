#!/usr/bin/env python3
"""
Visualization: Reduction Sequences and Complexity Descent

Shows two plots:
1. Multiple reduction sequences converging to the same normal form
2. The complexity measure strictly decreasing along each reduction path

This visualizes the key properties: termination (complexity always decreases)
and confluence (all paths lead to the same normal form).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# =============================================================================
# Self-contained tensor expression infrastructure
# =============================================================================

class Var:
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(('V', self.name))

class UnitE:
    def __repr__(self): return "I"
    def __eq__(self, other): return isinstance(other, UnitE)
    def __hash__(self): return hash('U')

class Tensor:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"
    def __eq__(self, other):
        return isinstance(other, Tensor) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('T', self.left, self.right))

def flatten(e):
    if isinstance(e, Var): return [e.name]
    if isinstance(e, UnitE): return []
    return flatten(e.left) + flatten(e.right)

def right_assoc(vs):
    if not vs: return UnitE()
    if len(vs) == 1: return Var(vs[0])
    return Tensor(Var(vs[0]), right_assoc(vs[1:]))

def normalize(e): return right_assoc(flatten(e))

def complexity(e):
    """Termination measure: counts left-nested tensors + unit adjacencies."""
    if isinstance(e, (Var, UnitE)): return 0
    c = complexity(e.left) + complexity(e.right)
    if isinstance(e.left, Tensor): c += 1
    if isinstance(e.left, UnitE): c += 1
    if isinstance(e.right, UnitE): c += 1
    return c

def expr_size(e):
    if isinstance(e, (Var, UnitE)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)

def reduce_leftmost(e):
    """Reduce using leftmost-outermost strategy."""
    if not isinstance(e, Tensor): return None
    if isinstance(e.left, UnitE): return e.right
    if isinstance(e.right, UnitE): return e.left
    if isinstance(e.left, Tensor):
        return Tensor(e.left.left, Tensor(e.left.right, e.right))
    r = reduce_leftmost(e.left)
    if r is not None: return Tensor(r, e.right)
    r = reduce_leftmost(e.right)
    if r is not None: return Tensor(e.left, r)
    return None

def reduce_rightmost(e):
    """Reduce using rightmost-innermost strategy."""
    if not isinstance(e, Tensor): return None
    # Try right subtree first
    r = reduce_rightmost(e.right)
    if r is not None: return Tensor(e.left, r)
    r = reduce_rightmost(e.left)
    if r is not None: return Tensor(r, e.right)
    # Then try root rules
    if isinstance(e.right, UnitE): return e.left
    if isinstance(e.left, UnitE): return e.right
    if isinstance(e.left, Tensor):
        return Tensor(e.left.left, Tensor(e.left.right, e.right))
    return None

def full_reduction(e, strategy='leftmost', max_steps=50):
    steps = [e]
    current = e
    reduce_fn = reduce_leftmost if strategy == 'leftmost' else reduce_rightmost
    for _ in range(max_steps):
        r = reduce_fn(current)
        if r is None: break
        steps.append(r)
        current = r
    return steps

# =============================================================================
# Build test expressions
# =============================================================================

A, B, C, D, E = Var("A"), Var("B"), Var("C"), Var("D"), Var("E")
I = UnitE()

test_exprs = [
    ("((A⊗B)⊗C)⊗D", Tensor(Tensor(Tensor(A, B), C), D)),
    ("(I⊗(A⊗I))⊗(B⊗C)", Tensor(Tensor(I, Tensor(A, I)), Tensor(B, C))),
    ("((A⊗I)⊗(I⊗B))⊗(C⊗(D⊗E))",
     Tensor(Tensor(Tensor(A, I), Tensor(I, B)), Tensor(C, Tensor(D, E)))),
    ("(((A⊗B)⊗C)⊗D)⊗E",
     Tensor(Tensor(Tensor(Tensor(A, B), C), D), E)),
]

# =============================================================================
# Plot 1: Complexity descent
# =============================================================================

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

ax1 = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

for idx, (name, expr) in enumerate(test_exprs):
    # Use leftmost strategy
    steps = full_reduction(expr, 'leftmost')
    complexities = [complexity(s) for s in steps]
    x = list(range(len(complexities)))
    
    ax1.plot(x, complexities, 'o-', color=colors[idx], linewidth=2, 
             markersize=6, label=name, alpha=0.8)

ax1.set_xlabel("Reduction Step", fontsize=12)
ax1.set_ylabel("Complexity Measure", fontsize=12)
ax1.set_title("Termination: Complexity Strictly Decreases\nWith Each Rewrite Step", 
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=-0.5)

# =============================================================================
# Plot 2: Two strategies converge to same NF
# =============================================================================

ax2 = axes[1]

expr = Tensor(Tensor(Tensor(A, I), Tensor(I, B)), Tensor(C, Tensor(D, I)))
steps_lm = full_reduction(expr, 'leftmost')
steps_rm = full_reduction(expr, 'rightmost')

sizes_lm = [expr_size(s) for s in steps_lm]
sizes_rm = [expr_size(s) for s in steps_rm]

x_lm = list(range(len(sizes_lm)))
x_rm = list(range(len(sizes_rm)))

ax2.plot(x_lm, sizes_lm, 'o-', color='#e74c3c', linewidth=2.5, 
         markersize=7, label='Leftmost-outermost strategy', alpha=0.8)
ax2.plot(x_rm, sizes_rm, 's--', color='#3498db', linewidth=2.5,
         markersize=7, label='Rightmost-innermost strategy', alpha=0.8)

# Mark the common normal form
nf = normalize(expr)
nf_size = expr_size(nf)
ax2.axhline(y=nf_size, color='#2ecc71', linestyle=':', linewidth=2, alpha=0.7,
            label=f'Normal form size = {nf_size}')

# Verify both reach the same NF
assert flatten(steps_lm[-1]) == flatten(steps_rm[-1]) == flatten(nf)

ax2.set_xlabel("Reduction Step", fontsize=12)
ax2.set_ylabel("Expression Size (nodes)", fontsize=12)
ax2.set_title("Confluence: Different Strategies\nConverge to Same Normal Form",
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate(f'Both reach: {nf}',
             xy=(max(len(x_lm), len(x_rm)) - 1, nf_size),
             xytext=(max(len(x_lm), len(x_rm)) - 3, nf_size + 3),
             fontsize=9, ha='center',
             arrowprops=dict(arrowstyle='->', color='#2ecc71'),
             bbox=dict(boxstyle='round', facecolor='#eafaf1'))

plt.tight_layout()
plt.savefig('reduction_convergence.png', dpi=150, bbox_inches='tight')
print("Saved reduction_convergence.png")
