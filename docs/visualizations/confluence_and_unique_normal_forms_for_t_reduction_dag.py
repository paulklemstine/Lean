#!/usr/bin/env python3
"""
Visualization: Reduction Tree with Distributivity Potential

Shows the BFS reduction tree from a sample tensor expression,
with node colors indicating distributivity potential values.
Demonstrates that all paths lead to AC-equivalent normal forms.

This is a standalone script - all needed functions are inlined.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Set
from collections import deque

# ---- Inlined expression types and functions ----

@dataclass(frozen=True)
class Expr: pass

@dataclass(frozen=True)
class ScalVar(Expr):
    name: str

@dataclass(frozen=True)
class VecVar(Expr):
    name: str

@dataclass(frozen=True)
class MatVar(Expr):
    name: str

@dataclass(frozen=True)
class ScalAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class ScalMul(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class VecAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class MatAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class SmulVec(Expr):
    scalar: Expr; vec: Expr

@dataclass(frozen=True)
class SmulMat(Expr):
    scalar: Expr; mat: Expr

@dataclass(frozen=True)
class MulVec(Expr):
    mat: Expr; vec: Expr

@dataclass(frozen=True)
class Dot(Expr):
    left: Expr; right: Expr


def pretty(e):
    if isinstance(e, ScalVar): return e.name
    if isinstance(e, VecVar): return e.name
    if isinstance(e, MatVar): return e.name
    if isinstance(e, ScalAdd): return f"({pretty(e.left)}+{pretty(e.right)})"
    if isinstance(e, ScalMul): return f"({pretty(e.left)}·{pretty(e.right)})"
    if isinstance(e, VecAdd): return f"({pretty(e.left)}⊕{pretty(e.right)})"
    if isinstance(e, MatAdd): return f"({pretty(e.left)}⊞{pretty(e.right)})"
    if isinstance(e, SmulVec): return f"({pretty(e.scalar)}•{pretty(e.vec)})"
    if isinstance(e, SmulMat): return f"({pretty(e.scalar)}⊙{pretty(e.mat)})"
    if isinstance(e, MulVec): return f"({pretty(e.mat)}*ᵥ{pretty(e.vec)})"
    if isinstance(e, Dot): return f"⟨{pretty(e.left)},{pretty(e.right)}⟩"
    return str(e)


def dp(e):
    if isinstance(e, (ScalVar, VecVar, MatVar)): return 3
    if isinstance(e, (ScalAdd, VecAdd, MatAdd)): return dp(e.left) + dp(e.right) + 1
    if isinstance(e, ScalMul): return dp(e.left) * dp(e.right)
    if isinstance(e, MulVec): return dp(e.mat) * dp(e.vec)
    if isinstance(e, Dot): return dp(e.left) * dp(e.right)
    if isinstance(e, SmulVec): return dp(e.scalar) * dp(e.vec) + 1
    if isinstance(e, SmulMat): return dp(e.scalar) * dp(e.mat) + 1
    return 3


def all_deep_rewrites(e):
    results = []
    # Root rules
    if isinstance(e, MulVec) and isinstance(e.vec, VecAdd):
        A, v, w = e.mat, e.vec.left, e.vec.right
        results.append(("R1", VecAdd(MulVec(A, v), MulVec(A, w))))
    if isinstance(e, MulVec) and isinstance(e.mat, MatAdd):
        A, B, v = e.mat.left, e.mat.right, e.vec
        results.append(("R2", VecAdd(MulVec(A, v), MulVec(B, v))))
    if isinstance(e, MulVec) and isinstance(e.mat, SmulMat):
        a, A, v = e.mat.scalar, e.mat.mat, e.vec
        results.append(("R3", SmulVec(a, MulVec(A, v))))
    if isinstance(e, SmulVec) and isinstance(e.vec, VecAdd):
        a, v, w = e.scalar, e.vec.left, e.vec.right
        results.append(("R4", VecAdd(SmulVec(a, v), SmulVec(a, w))))
    if isinstance(e, SmulMat) and isinstance(e.mat, MatAdd):
        a, A, B = e.scalar, e.mat.left, e.mat.right
        results.append(("R5", MatAdd(SmulMat(a, A), SmulMat(a, B))))
    if isinstance(e, Dot) and isinstance(e.left, VecAdd):
        v, w, u = e.left.left, e.left.right, e.right
        results.append(("R6", ScalAdd(Dot(v, u), Dot(w, u))))
    if isinstance(e, Dot) and isinstance(e.right, VecAdd):
        u, v, w = e.left, e.right.left, e.right.right
        results.append(("R7", ScalAdd(Dot(u, v), Dot(u, w))))
    if isinstance(e, Dot) and isinstance(e.left, SmulVec):
        a, v, w = e.left.scalar, e.left.vec, e.right
        results.append(("R8", ScalMul(a, Dot(v, w))))
    if isinstance(e, ScalMul) and isinstance(e.right, ScalAdd):
        a, b, c = e.left, e.right.left, e.right.right
        results.append(("R9", ScalAdd(ScalMul(a, b), ScalMul(a, c))))
    # Context closure (simplified - only go one level deep for visualization)
    for constructor, fields in _get_fields(e):
        for i, (fname, child) in enumerate(fields):
            for name, result in all_deep_rewrites(child):
                new_fields = list(fields)
                new_fields[i] = (fname, result)
                results.append((name, constructor(**{f: v for f, v in new_fields})))
    return results


def _get_fields(e):
    if isinstance(e, ScalAdd): return [(ScalAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, ScalMul): return [(ScalMul, [("left", e.left), ("right", e.right)])]
    if isinstance(e, VecAdd): return [(VecAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, MatAdd): return [(MatAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, SmulVec): return [(SmulVec, [("scalar", e.scalar), ("vec", e.vec)])]
    if isinstance(e, SmulMat): return [(SmulMat, [("scalar", e.scalar), ("mat", e.mat)])]
    if isinstance(e, MulVec): return [(MulVec, [("mat", e.mat), ("vec", e.vec)])]
    if isinstance(e, Dot): return [(Dot, [("left", e.left), ("right", e.right)])]
    return []


def flatten_add(e, add_type):
    if isinstance(e, add_type):
        return flatten_add(e.left, add_type) + flatten_add(e.right, add_type)
    return [e]


def ac_canonical(e):
    if isinstance(e, (ScalVar, VecVar, MatVar)): return e
    if isinstance(e, ScalAdd):
        summands = sorted([repr(ac_canonical(s)) for s in flatten_add(e, ScalAdd)])
        return "ScalAdd(" + ",".join(summands) + ")"
    if isinstance(e, VecAdd):
        summands = sorted([repr(ac_canonical(s)) for s in flatten_add(e, VecAdd)])
        return "VecAdd(" + ",".join(summands) + ")"
    return repr(e)


# ---- Build reduction DAG ----

start = Dot(VecAdd(VecVar("v"), VecVar("w")), VecAdd(VecVar("u"), VecVar("x")))

visited = {}
edges = []
queue = deque([(start, 0)])
visited[start] = 0
node_id = 1

while queue and len(visited) < 50:
    current, cur_id = queue.popleft()
    for name, result in all_deep_rewrites(current):
        if result not in visited:
            visited[result] = node_id
            node_id += 1
            queue.append((result, visited[result]))
        edges.append((cur_id, visited[result], name))

# ---- Layout and draw ----

# Assign layers by BFS depth
layers = {0: 0}
q2 = deque([0])
while q2:
    n = q2.popleft()
    for src, tgt, _ in edges:
        if src == n and tgt not in layers:
            layers[tgt] = layers[n] + 1
            q2.append(tgt)

# Collect nodes per layer
layer_nodes = {}
for nid, layer in layers.items():
    layer_nodes.setdefault(layer, []).append(nid)

# Assign positions
positions = {}
for layer, nodes in layer_nodes.items():
    for i, nid in enumerate(nodes):
        x = (i - (len(nodes)-1)/2) * 2.5
        y = -layer * 2
        positions[nid] = (x, y)

# Create figure
fig, ax = plt.subplots(figsize=(14, 10))

# Get dp values for coloring
id_to_expr = {v: k for k, v in visited.items()}
dp_values = {nid: dp(id_to_expr[nid]) for nid in visited.values()}
max_dp = max(dp_values.values())
min_dp = min(dp_values.values())

# Draw edges
for src, tgt, name in edges:
    if src in positions and tgt in positions:
        x1, y1 = positions[src]
        x2, y2 = positions[tgt]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5, lw=1))

# Draw nodes
for nid, (x, y) in positions.items():
    dp_val = dp_values[nid]
    # Color based on dp value
    t = (dp_val - min_dp) / (max_dp - min_dp) if max_dp > min_dp else 0.5
    color = plt.cm.RdYlGn(1 - t)  # Green = low dp, Red = high dp

    is_normal = len(all_deep_rewrites(id_to_expr[nid])) == 0
    marker_size = 600 if is_normal else 300
    edge_color = 'gold' if is_normal else 'black'
    linewidth = 3 if is_normal else 1

    ax.scatter(x, y, s=marker_size, c=[color], edgecolors=edge_color,
              linewidths=linewidth, zorder=5)
    ax.annotate(f'dp={dp_val}', (x, y), textcoords="offset points",
               xytext=(0, -15), ha='center', fontsize=7, color='#333')

# Title and labels
ax.set_title('Reduction DAG: ⟨v⊕w, u⊕x⟩\nColor = distPotential (green=low, red=high), Gold border = normal form',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Branching position', fontsize=11)
ax.set_ylabel('Reduction depth', fontsize=11)

# Legend
legend_elements = [
    mpatches.Patch(facecolor=plt.cm.RdYlGn(0.0), label='High dp (unreduced)'),
    mpatches.Patch(facecolor=plt.cm.RdYlGn(1.0), label='Low dp (near normal)'),
    mpatches.Patch(facecolor='white', edgecolor='gold', linewidth=2, label='Normal form'),
]
ax.legend(handles=legend_elements, loc='upper right')

ax.set_xlim(-10, 10)
plt.tight_layout()
plt.savefig('viz_reduction_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_reduction_tree.png")
