#!/usr/bin/env python3
"""
Visualization: Deletion-Contraction Recursion Tree

Shows the recursion tree structure for the support-Tutte evaluation
on a concrete example, illustrating how loop/coloop/ordinary elements
produce different branching patterns.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

class GroundSupport:
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e]==0), self.ground-{e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        return GroundSupport(frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                            for m in self.supp if m[e]==mc), self.ground-{e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e]>0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp})==1

def build_tree(S, depth=0, pos_x=0, width=4):
    """Build recursion tree as list of (node_info, children)."""
    if not S.ground:
        return {'x': pos_x, 'y': -depth, 'label': f'1\n|s|={len(S.supp)}',
                'type': 'base', 'children': []}

    e = min(S.ground)
    S_del = S.delete(e)
    S_con = S.contract(e)

    if S.is_loop(e):
        etype = 'loop'
        label = f'e={e}\nLOOP\n|s|={len(S.supp)}'
    elif S.is_coloop(e):
        etype = 'coloop'
        label = f'e={e}\nCOLOOP\n|s|={len(S.supp)}'
    else:
        etype = 'ordinary'
        label = f'e={e}\nORD\n|s|={len(S.supp)}'

    child_width = width / 2.5
    left = build_tree(S_del, depth+1, pos_x - width/2, child_width)
    right = build_tree(S_con, depth+1, pos_x + width/2, child_width)

    return {'x': pos_x, 'y': -depth, 'label': label, 'type': etype,
            'children': [left, right]}


def draw_tree(ax, node, parent=None):
    colors = {'loop': '#e74c3c', 'coloop': '#3498db', 'ordinary': '#2ecc71', 'base': '#95a5a6'}
    color = colors.get(node['type'], '#95a5a6')

    if parent:
        ax.plot([parent[0], node['x']], [parent[1], node['y']], 'k-', alpha=0.4, linewidth=1)

    circle = plt.Circle((node['x'], node['y']), 0.35, color=color, alpha=0.8, zorder=5)
    ax.add_patch(circle)
    ax.text(node['x'], node['y'], node['label'], ha='center', va='center',
            fontsize=6, fontweight='bold', zorder=6)

    for child in node['children']:
        draw_tree(ax, child, (node['x'], node['y']))


# Build trees for different supports
fig, axes = plt.subplots(1, 3, figsize=(18, 8))
fig.suptitle('Deletion-Contraction Recursion Trees', fontsize=14, fontweight='bold')

supports = [
    ("U(1,3): {(1,0,0),(0,1,0),(0,0,1)}",
     GroundSupport(frozenset({(1,0,0),(0,1,0),(0,0,1)}), frozenset({0,1,2}))),
    ("{(1,1,0),(0,1,1)}",
     GroundSupport(frozenset({(1,1,0),(0,1,1)}), frozenset({0,1,2}))),
    ("{(1,1,1)}",
     GroundSupport(frozenset({(1,1,1)}), frozenset({0,1,2}))),
]

for idx, (name, S) in enumerate(supports):
    ax = axes[idx]
    tree = build_tree(S, width=3)
    draw_tree(ax, tree)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-4.5, 0.8)
    ax.set_aspect('equal')
    ax.set_title(name, fontsize=10, fontweight='bold')
    ax.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', label='Loop (y·delete)'),
    mpatches.Patch(facecolor='#3498db', label='Coloop (x·contract)'),
    mpatches.Patch(facecolor='#2ecc71', label='Ordinary (u·del + v·con)'),
    mpatches.Patch(facecolor='#95a5a6', label='Base case (= 1)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout()
plt.savefig('activity_tree.png', dpi=150, bbox_inches='tight')
print("Saved activity_tree.png")
