#!/usr/bin/env python3
"""
Visualization: Rewrite Graph for a Critical Pair Term

Shows the complete rewrite graph from a term with multiple reduction paths,
illustrating how all paths converge to AC-equivalent normal forms.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import deque

# ─── Inline: Minimal expression types and rewrite rules ───

class E:
    """Base expression."""
    pass

class V(E):
    def __init__(self, n): self.n = n
    def __repr__(self): return self.n
    def __eq__(self, o): return isinstance(o, V) and self.n == o.n
    def __hash__(self): return hash(('V', self.n))

class M(E):
    def __init__(self, n): self.n = n
    def __repr__(self): return self.n
    def __eq__(self, o): return isinstance(o, M) and self.n == o.n
    def __hash__(self): return hash(('M', self.n))

class VA(E):  # vecAdd
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}⊕{self.r})"
    def __eq__(self, o): return isinstance(o, VA) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(('VA', self.l, self.r))

class MA(E):  # matAdd
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}⊞{self.r})"
    def __eq__(self, o): return isinstance(o, MA) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(('MA', self.l, self.r))

class MV(E):  # mulVec
    def __init__(self, m, v): self.m, self.v = m, v
    def __repr__(self): return f"{self.m}·{self.v}"
    def __eq__(self, o): return isinstance(o, MV) and self.m == o.m and self.v == o.v
    def __hash__(self): return hash(('MV', self.m, self.v))

def rewrites(t):
    """All one-step deep rewrites."""
    results = []
    # R1
    if isinstance(t, MV) and isinstance(t.v, VA):
        results.append(("R1", VA(MV(t.m, t.v.l), MV(t.m, t.v.r))))
    # R2
    if isinstance(t, MV) and isinstance(t.m, MA):
        results.append(("R2", VA(MV(t.m.l, t.v), MV(t.m.r, t.v))))
    # Congruence
    if isinstance(t, VA):
        for n, l in rewrites(t.l): results.append((n, VA(l, t.r)))
        for n, r in rewrites(t.r): results.append((n, VA(t.l, r)))
    if isinstance(t, MV):
        for n, m in rewrites(t.m): results.append((n, MV(m, t.v)))
        for n, v in rewrites(t.v): results.append((n, MV(t.m, v)))
    return results

def flatten_va(t):
    if isinstance(t, VA):
        return flatten_va(t.l) + flatten_va(t.r)
    return [repr(t)]

def canon(t):
    if isinstance(t, VA):
        parts = flatten_va(t)
        return "VA(" + ",".join(sorted(parts)) + ")"
    return repr(t)

# ─── Build rewrite graph ───
A, B = M("A"), M("B")
v, w = V("v"), V("w")
start = MV(MA(A, B), VA(v, w))

graph = {}  # node_id -> set of (edge_label, target_id)
node_labels = {}  # node_id -> display string
node_canon = {}  # node_id -> canonical form
queue = deque([start])
visited = set()

while queue:
    t = queue.popleft()
    tid = repr(t)
    if tid in visited:
        continue
    visited.add(tid)
    node_labels[tid] = tid
    node_canon[tid] = canon(t)
    graph[tid] = set()
    for rule, next_t in rewrites(t):
        nid = repr(next_t)
        graph[tid].add((rule, nid))
        if nid not in visited:
            queue.append(next_t)
            node_labels[nid] = nid
            node_canon[nid] = canon(next_t)
            if nid not in graph:
                graph[nid] = set()

# ─── Layout: manual layered layout ───
nodes = list(graph.keys())
# Compute levels by BFS from start
levels = {repr(start): 0}
q = deque([repr(start)])
while q:
    n = q.popleft()
    for _, target in graph.get(n, set()):
        if target not in levels:
            levels[target] = levels[n] + 1
            q.append(target)

max_level = max(levels.values()) if levels else 0
level_nodes = {}
for n, l in levels.items():
    level_nodes.setdefault(l, []).append(n)

positions = {}
for l, nds in level_nodes.items():
    for i, n in enumerate(nds):
        x = (i - (len(nds)-1)/2) * 3.5
        y = -l * 1.8
        positions[n] = (x, y)

# ─── Draw ───
fig, ax = plt.subplots(figsize=(12, 8))
ax.set_aspect('equal')
ax.axis('off')
ax.set_title("Rewrite Graph: (A⊞B)·(v⊕w)\nAll paths converge to AC-equivalent normal forms",
             fontsize=13, fontweight='bold')

# Draw edges
for src, edges in graph.items():
    if src not in positions:
        continue
    sx, sy = positions[src]
    for rule, dst in edges:
        if dst not in positions:
            continue
        dx, dy = positions[dst]
        color = '#2196F3' if 'R1' in rule else '#FF5722'
        ax.annotate('', xy=(dx, dy+0.3), xytext=(sx, sy-0.3),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5,
                                   connectionstyle='arc3,rad=0.05'))
        mx, my = (sx+dx)/2, (sy+dy)/2
        ax.text(mx+0.15, my, rule, fontsize=7, color=color, fontweight='bold')

# Draw nodes
normal_canon = set()
for n in nodes:
    if not graph.get(n):
        normal_canon.add(node_canon.get(n, ''))

for n, (x, y) in positions.items():
    is_normal = not graph.get(n)
    is_start = (n == repr(start))
    color = '#FFF9C4' if is_start else ('#C8E6C9' if is_normal else '#E3F2FD')
    edge_color = '#F57F17' if is_start else ('#2E7D32' if is_normal else '#1565C0')
    bbox = dict(boxstyle='round,pad=0.3', facecolor=color,
                edgecolor=edge_color, linewidth=2 if is_start else 1.5)
    label = node_labels[n]
    if len(label) > 30:
        label = label[:28] + "..."
    ax.text(x, y, label, ha='center', va='center', fontsize=7, bbox=bbox)

# Legend
ax.text(0, -max_level*1.8 - 1.2,
        f"Normal forms: {len(normal_canon)} distinct canonical form(s) modulo AC",
        ha='center', fontsize=11, fontweight='bold',
        color='#2E7D32' if len(normal_canon) == 1 else '#C62828')

plt.tight_layout()
plt.savefig('viz_rewrite_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_rewrite_graph.png")
