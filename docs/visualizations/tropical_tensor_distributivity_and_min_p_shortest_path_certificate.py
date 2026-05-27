"""
Visualization: Shortest Path Certificate via Tropical Normal Form

This script shows how the tropical normal form of a graph expression
produces a visual certificate for shortest paths: each TNF monomial
corresponds to a candidate path, and the minimum gives the shortest.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math

# ============================================================
# Inline implementations (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index):
        self.index = index

class TMin(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right

class TPlus(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, float('inf'))
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    return float('inf')


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    return expr


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def atom_list(expr):
    if isinstance(expr, Atom): return [expr.index]
    if isinstance(expr, TPlus):
        return atom_list(expr.left) + atom_list(expr.right)
    return []


def encode_edge(n, i, j):
    return i * n + j

def decode_edge(n, idx):
    return idx // n, idx % n


# ============================================================
# Graph Setup
# ============================================================

n = 4
cities = ["A", "B", "C", "D"]
positions = {0: (0, 1), 1: (2, 2), 2: (2, 0), 3: (4, 1)}

# Edge weights
edges = {
    (0, 1): 3,
    (0, 2): 6,
    (1, 2): 2,
    (1, 3): 4,
    (2, 3): 1,
}

# Build environment
weights = [[float('inf')] * n for _ in range(n)]
for (i, j), w in edges.items():
    weights[i][j] = w

env = {}
for i in range(n):
    for j in range(n):
        env[encode_edge(n, i, j)] = weights[i][j]

# Build two-hop expression for A -> D
two_hop = None
for k in range(n):
    path = TPlus(Atom(encode_edge(n, 0, k)), Atom(encode_edge(n, k, 3)))
    two_hop = path if two_hop is None else TMin(two_hop, path)

nf = normalize(two_hop)
monomials = extract_monomials(nf)

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Graph with edges
ax = axes[0]
ax.set_xlim(-0.5, 5)
ax.set_ylim(-0.5, 3)
ax.set_aspect('equal')
ax.set_title('Weighted Directed Graph', fontsize=14)

# Draw edges
for (i, j), w in edges.items():
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    dx, dy = x2 - x1, y2 - y1
    ax.annotate('', xy=(x2 - 0.15*dx/max(abs(dx)+0.01, abs(dy)+0.01),
                        y2 - 0.15*dy/max(abs(dx)+0.01, abs(dy)+0.01)),
                xytext=(x1 + 0.15*dx/max(abs(dx)+0.01, abs(dy)+0.01),
                        y1 + 0.15*dy/max(abs(dx)+0.01, abs(dy)+0.01)),
                arrowprops=dict(arrowstyle='->', color='#555', lw=2))
    mid_x = (x1 + x2) / 2 + 0.15
    mid_y = (y1 + y2) / 2 + 0.15
    ax.text(mid_x, mid_y, str(w), fontsize=12, fontweight='bold',
            color='#D32F2F', ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white', edgecolor='#D32F2F', alpha=0.8))

# Draw vertices
for i, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.3, color='#1976D2', zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, cities[i], fontsize=14, fontweight='bold', color='white',
            ha='center', va='center', zorder=6)

ax.axis('off')

# Panel 2: TNF Certificate
ax2 = axes[1]
ax2.set_title('Tropical Normal Form Certificate (A→D)', fontsize=14)
ax2.set_xlim(0, 10)
ax2.set_ylim(0, len(monomials) + 2)
ax2.axis('off')

# Header
ax2.text(5, len(monomials) + 1.5, 'TNF = min(monomial₁, monomial₂, ...)',
         fontsize=12, ha='center', fontweight='bold', style='italic')

# Show each monomial
min_val = eval_z(nf, env)

for idx, m in enumerate(monomials):
    y = len(monomials) - idx
    atoms = atom_list(m)
    val = eval_z(m, env)

    # Decode path
    edges_in_path = []
    for a in atoms:
        src, dst = decode_edge(n, a)
        edges_in_path.append(f"{cities[src]}→{cities[dst]}({env[a]:.0f})")

    path_str = " + ".join(edges_in_path)
    is_optimal = (val == min_val and val != float('inf'))

    color = '#43A047' if is_optimal else '#757575'
    weight = 'bold' if is_optimal else 'normal'
    marker = '★' if is_optimal else '○'

    ax2.text(0.5, y, marker, fontsize=14, va='center', color=color)
    ax2.text(1.5, y, path_str, fontsize=10, va='center', color=color,
             fontweight=weight, family='monospace')

    val_str = f"= {val:.0f}" if val != float('inf') else "= ∞"
    ax2.text(8.5, y, val_str, fontsize=11, va='center', color=color,
             fontweight=weight)

# Bottom annotation
ax2.text(5, 0.3, f'Shortest 2-hop path weight: {min_val:.0f}',
         fontsize=13, ha='center', fontweight='bold', color='#1B5E20',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#43A047'))

plt.tight_layout()
plt.savefig('viz_shortest_path_certificate.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_shortest_path_certificate.png")
