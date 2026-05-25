#!/usr/bin/env python3
"""
Visualization: β-Reduction Graph

Visualizes the directed graph of β-reductions from a given lambda term,
showing all possible reduction paths and how they converge (Church-Rosser).
This illustrates the confluence property central to higher-order completion.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque

# Inline term definitions to be self-contained
class Term:
    pass

class Var(Term):
    def __init__(self, index):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"
    def __eq__(self, other):
        return isinstance(other, Var) and self.index == other.index
    def __hash__(self):
        return hash(("V", self.index))

class App(Term):
    def __init__(self, fun, arg):
        self.fun = fun
        self.arg = arg
    def __repr__(self):
        f = repr(self.fun)
        a = repr(self.arg)
        return f"({f} {a})"
    def __eq__(self, other):
        return isinstance(other, App) and self.fun == other.fun and self.arg == other.arg
    def __hash__(self):
        return hash(("A", self.fun, self.arg))

class Lam(Term):
    def __init__(self, body):
        self.body = body
    def __repr__(self):
        return f"(λ.{self.body})"
    def __eq__(self, other):
        return isinstance(other, Lam) and self.body == other.body
    def __hash__(self):
        return hash(("L", self.body))

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1) + 1

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    if isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    if isinstance(t, Lam): return Lam(rename(lift_ren(rho), t.body))

def lift_subst(sigma):
    def f(n):
        if n == 0: return Var(0)
        return rename(lambda x: x+1, sigma(n-1))
    return f

def subst(t, sigma):
    if isinstance(t, Var): return sigma(t.index)
    if isinstance(t, App): return App(subst(t.fun, sigma), subst(t.arg, sigma))
    if isinstance(t, Lam): return Lam(subst(t.body, lift_subst(sigma)))

def single_subst(s):
    return lambda n: s if n == 0 else Var(n-1)

def beta_contract(body, arg):
    return subst(body, single_subst(arg))

def all_reducts(t):
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(beta_contract(t.fun.body, t.arg))
        for r in all_reducts(t.fun):
            results.append(App(r, t.arg))
        for r in all_reducts(t.arg):
            results.append(App(t.fun, r))
    elif isinstance(t, Lam):
        for r in all_reducts(t.body):
            results.append(Lam(r))
    return results

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def build_reduction_graph(start, max_nodes=30):
    """BFS to build the reduction graph."""
    graph = {}
    queue = deque([start])
    visited = set()
    visited.add(start)
    labels = {start: repr(start)}

    while queue and len(visited) < max_nodes:
        t = queue.popleft()
        reducts = all_reducts(t)
        graph[t] = reducts
        for r in reducts:
            if r not in visited:
                visited.add(r)
                queue.append(r)
                labels[r] = repr(r)

    return graph, labels

def layout_graph(graph, start):
    """Simple layered layout by BFS depth."""
    levels = {}
    queue = deque([(start, 0)])
    visited = {start}
    levels[start] = 0

    while queue:
        t, depth = queue.popleft()
        for r in graph.get(t, []):
            if r not in visited:
                visited.add(r)
                levels[r] = depth + 1
                queue.append((r, depth + 1))

    # Arrange nodes by level
    by_level = {}
    for node, level in levels.items():
        by_level.setdefault(level, []).append(node)

    positions = {}
    max_level = max(by_level.keys()) if by_level else 0
    for level, nodes in by_level.items():
        for i, node in enumerate(nodes):
            x = (i - (len(nodes) - 1) / 2) * 3.5
            y = -level * 2
            positions[node] = (x, y)

    return positions

# Build graph for a sample term
# (λx.x x)(λx.x x) — the omega combinator (divergent)
# Let's use something that converges instead:
# (λf.λx. f(f x)) (λy.y) — apply twice the identity
start = App(Lam(Lam(App(Var(1), App(Var(1), Var(0))))), Lam(Var(0)))

graph, labels = build_reduction_graph(start, max_nodes=20)
positions = layout_graph(graph, start)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(14, 8))
fig.suptitle("β-Reduction Graph: Confluence in Action", fontsize=16, fontweight='bold')

# Draw edges
for source, targets in graph.items():
    if source in positions:
        sx, sy = positions[source]
        for target in targets:
            if target in positions:
                tx, ty = positions[target]
                ax.annotate("",
                    xy=(tx, ty), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle="->", color="#4477AA",
                                   lw=1.5, connectionstyle="arc3,rad=0.1"))

# Draw nodes
for node, (x, y) in positions.items():
    is_normal = len(all_reducts(node)) == 0
    is_start = node == start

    if is_start:
        color = '#EE6677'
        edge_color = '#CC3311'
    elif is_normal:
        color = '#228833'
        edge_color = '#117722'
    else:
        color = '#CCBB44'
        edge_color = '#999922'

    label = repr(node)
    if len(label) > 25:
        label = label[:22] + "..."

    bbox = dict(boxstyle="round,pad=0.3", facecolor=color,
                edgecolor=edge_color, alpha=0.85)
    ax.text(x, y, label, ha='center', va='center',
            fontsize=7, fontfamily='monospace', bbox=bbox)

# Legend
start_patch = mpatches.Patch(color='#EE6677', label='Start term')
inter_patch = mpatches.Patch(color='#CCBB44', label='Intermediate')
normal_patch = mpatches.Patch(color='#228833', label='Normal form')
ax.legend(handles=[start_patch, inter_patch, normal_patch],
          loc='upper right', fontsize=10)

ax.set_xlim(-8, 8)
ax.set_ylim(min(y for _, y in positions.values()) - 1.5,
            max(y for _, y in positions.values()) + 1.5)
ax.axis('off')
ax.set_title("All reduction paths converge to the same normal form\n(Church-Rosser theorem)",
             fontsize=11, style='italic', pad=10)

plt.tight_layout()
plt.savefig("rewrite_graph.png", dpi=150, bbox_inches='tight')
print("Saved rewrite_graph.png")
