#!/usr/bin/env python3
"""
Visualization: Proof Refinement Tree

Shows the tree structure of a proof sketch before and after normalization,
with nodes colored by type. Demonstrates how refinement strips away
redundant and duplicate wrappers while preserving the essential structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass


# ── Self-contained proof sketch types ────────────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

@dataclass
class ProofSketch: pass
@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel
@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch
@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch
@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch
@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch
@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch

def step_once(p):
    if isinstance(p, Redundant): return p.inner
    if isinstance(p, Duplicate): return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant): return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom): return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s: return Trans(s, p.right)
        s = step_once(p.right)
        return Trans(p.left, s) if s else None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s: return Cases(s, p.right)
        s = step_once(p.right)
        return Cases(p.left, s) if s else None
    return None

def normalize(p):
    while True:
        nxt = step_once(p)
        if nxt is None: return p
        p = nxt

def score(p):
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 2 + score(p.sub) + 1
    if isinstance(p, (Trans, Cases)): return 1 + score(p.left) + score(p.right) + 1 + max(
        _depth(p.left), _depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 2 + score(p.inner)

def _depth(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + _depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(_depth(p.left), _depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + _depth(p.inner)


# ── Tree layout algorithm ────────────────────────────────────

NODE_COLORS = {
    'Axiom': '#2ecc71',
    'Lemma': '#3498db',
    'Trans': '#f39c12',
    'Cases': '#9b59b6',
    'Redundant': '#e74c3c',
    'Duplicate': '#e67e22',
}

def node_type(p):
    return type(p).__name__

def node_label(p):
    if isinstance(p, Axiom): return f"Ax\n{p.label.name[:6]}"
    if isinstance(p, Lemma): return f"Lem\n{p.label.name[:6]}"
    if isinstance(p, Trans): return "Trans"
    if isinstance(p, Cases): return "Cases"
    if isinstance(p, Redundant): return "Redun."
    if isinstance(p, Duplicate): return "Dupl."
    return "?"

def children(p):
    if isinstance(p, Axiom): return []
    if isinstance(p, Lemma): return [p.sub]
    if isinstance(p, (Trans, Cases)): return [p.left, p.right]
    if isinstance(p, (Redundant, Duplicate)): return [p.inner]
    return []

def layout_tree(p, x=0, y=0, dx=1.0, positions=None, edges=None, node_id=None):
    """Compute positions for tree nodes."""
    if positions is None: positions = {}
    if edges is None: edges = []
    if node_id is None: node_id = [0]

    my_id = node_id[0]
    node_id[0] += 1
    positions[my_id] = (x, y, p)

    kids = children(p)
    if not kids:
        return positions, edges

    n = len(kids)
    start_x = x - dx * (n - 1) / 2
    for i, child in enumerate(kids):
        child_id = node_id[0]
        edges.append((my_id, child_id))
        layout_tree(child, start_x + i * dx, y - 1.2, dx * 0.5,
                     positions, edges, node_id)

    return positions, edges


def draw_tree(ax, p, title=""):
    """Draw a proof sketch tree on the given axes."""
    positions, edges = layout_tree(p)

    # Draw edges
    for parent_id, child_id in edges:
        px, py, _ = positions[parent_id]
        cx, cy, _ = positions[child_id]
        ax.plot([px, cx], [py, cy], 'k-', linewidth=1.5, alpha=0.4)

    # Draw nodes
    for nid, (x, y, node) in positions.items():
        nt = node_type(node)
        color = NODE_COLORS.get(nt, '#bdc3c7')
        circle = plt.Circle((x, y), 0.35, color=color, ec='black',
                             linewidth=1.5, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, node_label(node), ha='center', va='center',
                fontsize=7, fontweight='bold', zorder=4)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


# ── Create visualization ─────────────────────────────────────

# Example proof sketch
original = Redundant(Duplicate(
    Lemma(TheoremLabel.IrrationalSqrt2,
        Trans(
            Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
            Duplicate(Axiom(TheoremLabel.DvdTrans))
        ))))

normalized = normalize(original)

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

draw_tree(axes[0], original, "Before Refinement\n(bloated, score=16)")
axes[0].set_xlim(-3, 3)
axes[0].set_ylim(-6.5, 1)

draw_tree(axes[1], normalized, "After Refinement\n(normal form, score=7)")
axes[1].set_xlim(-3, 3)
axes[1].set_ylim(-6.5, 1)

# Add arrow between panels
fig.patches.append(mpatches.FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    color='#c0392b', linewidth=3))

fig.text(0.5, 0.55, 'Normalize', ha='center', fontsize=14,
         fontweight='bold', color='#c0392b', transform=fig.transFigure)

# Legend
legend_patches = [mpatches.Patch(color=c, label=n)
                  for n, c in NODE_COLORS.items()]
fig.legend(handles=legend_patches, loc='lower center', ncol=6,
           fontsize=10, framealpha=0.9)

plt.suptitle('Proof Tree Simplification via Refinement Dynamics',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_refinement_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_refinement_tree.png")
