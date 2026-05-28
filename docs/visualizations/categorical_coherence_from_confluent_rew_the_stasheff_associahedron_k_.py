#!/usr/bin/env python3
"""
Visualization: The Associahedron and Confluent Normalization

Visualizes all parenthesizations of a 4-element tensor product as nodes
in the Stasheff associahedron (K₄), with edges representing single
associativity steps. Shows how all paths converge to the unique
right-associated normal form.

This illustrates the core theorem: the monoidal rewrite system is confluent,
so all parenthesizations of the same sequence normalize to the same canonical form.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# =============================================================================
# Tensor Expression AST (self-contained)
# =============================================================================

class Var:
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(('V', self.name))

class Unit:
    def __repr__(self): return "I"
    def __eq__(self, other): return isinstance(other, Unit)
    def __hash__(self): return hash('U')

class Tensor:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"
    def __eq__(self, other):
        return isinstance(other, Tensor) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('T', self.left, self.right))

def flatten(e):
    if isinstance(e, Var): return [e.name]
    if isinstance(e, Unit): return []
    return flatten(e.left) + flatten(e.right)

def right_assoc(vs):
    if not vs: return Unit()
    if len(vs) == 1: return Var(vs[0])
    return Tensor(Var(vs[0]), right_assoc(vs[1:]))

def normalize(e): return right_assoc(flatten(e))

def is_normal_form(e):
    return e == normalize(e)

def try_reduce(e):
    """Return list of (result, rule) for all possible one-step reductions."""
    results = []
    if isinstance(e, Tensor):
        if isinstance(e.left, Unit):
            results.append((e.right, "unitL"))
        if isinstance(e.right, Unit):
            results.append((e.left, "unitR"))
        if isinstance(e.left, Tensor):
            r = Tensor(e.left.left, Tensor(e.left.right, e.right))
            results.append((r, "assoc"))
        for (rl, rule) in try_reduce(e.left):
            results.append((Tensor(rl, e.right), f"L:{rule}"))
        for (rr, rule) in try_reduce(e.right):
            results.append((Tensor(e.left, rr), f"R:{rule}"))
    return results

# =============================================================================
# Enumerate all binary trees on 4 leaves (Catalan number C₃ = 5)
# =============================================================================

A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")

parenthesizations = [
    Tensor(Tensor(Tensor(A, B), C), D),      # ((A⊗B)⊗C)⊗D
    Tensor(Tensor(A, Tensor(B, C)), D),       # (A⊗(B⊗C))⊗D
    Tensor(Tensor(A, B), Tensor(C, D)),       # (A⊗B)⊗(C⊗D)
    Tensor(A, Tensor(Tensor(B, C), D)),       # A⊗((B⊗C)⊗D)
    Tensor(A, Tensor(B, Tensor(C, D))),       # A⊗(B⊗(C⊗D)) ← NF
]

labels = [
    "((A⊗B)⊗C)⊗D",
    "(A⊗(B⊗C))⊗D",
    "(A⊗B)⊗(C⊗D)",
    "A⊗((B⊗C)⊗D)",
    "A⊗(B⊗(C⊗D))\n[Normal Form]",
]

# =============================================================================
# Build adjacency (which pairs are connected by one assoc step)
# =============================================================================

def are_one_step(e1, e2):
    """Check if e2 is reachable from e1 in one associativity step."""
    for (r, _) in try_reduce(e1):
        if r == e2:
            return True
    return False

edges = []
for i in range(len(parenthesizations)):
    for j in range(len(parenthesizations)):
        if i != j and are_one_step(parenthesizations[i], parenthesizations[j]):
            edges.append((i, j))

# =============================================================================
# Layout: Pentagon (Stasheff associahedron K₄)
# =============================================================================

# The K₄ associahedron is a pentagon
angles = [np.pi/2 + 2*np.pi*k/5 for k in range(5)]
# Reorder to match the natural adjacency
# Standard pentagon ordering: 0-1-2-3-4
pos = {}
radius = 2.5
for i in range(5):
    pos[i] = (radius * np.cos(angles[i]), radius * np.sin(angles[i]))

# =============================================================================
# Draw
# =============================================================================

fig, ax = plt.subplots(1, 1, figsize=(10, 10))
ax.set_aspect('equal')

# Draw edges
for (i, j) in edges:
    x1, y1 = pos[i]
    x2, y2 = pos[j]
    # Color: green if pointing toward NF (index 4), gray otherwise
    color = '#2ecc71' if j == 4 else '#bdc3c7'
    width = 2.5 if j == 4 else 1.0
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=width,
                               connectionstyle='arc3,rad=0.1'))

# Draw nodes
for i in range(5):
    x, y = pos[i]
    is_nf = (i == 4)
    color = '#27ae60' if is_nf else '#3498db'
    size = 1800 if is_nf else 1200
    ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='white', linewidth=2)
    
    # Label
    offset_y = -0.6 if y < 0 else 0.6
    va = 'top' if y >= 0 else 'bottom'
    if i == 4:
        offset_y = 0.8
        va = 'bottom'
    ax.text(x, y + offset_y, labels[i], ha='center', va=va,
            fontsize=9, fontweight='bold' if is_nf else 'normal',
            color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

# Title and annotations
ax.set_title("The Stasheff Associahedron K₄\nConfluent Normalization of Tensor Expressions",
             fontsize=14, fontweight='bold', pad=20)
ax.text(0, -3.8,
        "Green arrows: reduction toward the unique normal form\n"
        "All paths converge — this is confluence = coherence",
        ha='center', fontsize=10, style='italic', color='#7f8c8d')

# Legend
nf_patch = mpatches.Patch(color='#27ae60', label='Normal form (canonical)')
expr_patch = mpatches.Patch(color='#3498db', label='Non-canonical expression')
ax.legend(handles=[nf_patch, expr_patch], loc='lower right', fontsize=10)

ax.set_xlim(-4, 4)
ax.set_ylim(-4.5, 4)
ax.axis('off')

plt.tight_layout()
plt.savefig('associahedron.png', dpi=150, bbox_inches='tight')
print("Saved associahedron.png")
