#!/usr/bin/env python3
"""
Visualization: Deletion-Contraction Recursion Tree

Shows the recursive structure of the support-Tutte polynomial computation,
illustrating how deletion and contraction decompose a support into smaller
pieces. Each node shows the support and its polynomial value.

This visualizes the core mathematical idea: a universal recursion scheme
that assigns polynomial invariants to discrete convex structures.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# ===== Inline all needed functions =====

def poly_add(p, q):
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul_x(p):
    return {k + 1: v for k, v in p.items()}

def poly_str(p):
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"

def support_str(S):
    if len(S) == 0:
        return "∅"
    return "{" + ", ".join(str(m) for m in sorted(S)) + "}"

def support_tutte_tree(S, n, depth=0):
    """Compute T(S) and return the recursion tree."""
    zero = tuple(0 for _ in range(n))
    
    if len(S) == 0:
        return {'S': S, 'T': {0: 1}, 'type': 'empty', 'children': []}
    
    if S == frozenset({zero}):
        return {'S': S, 'T': {0: 1}, 'type': 'zero', 'children': []}
    
    for i in range(n):
        has_zero = any(m[i] == 0 for m in S)
        has_pos = any(m[i] > 0 for m in S)
        if has_zero and has_pos:
            del_S = frozenset(m for m in S if m[i] == 0)
            contracted = set()
            for m in S:
                if m[i] > 0:
                    new_m = list(m)
                    new_m[i] -= 1
                    contracted.add(tuple(new_m))
            con_S = frozenset(contracted)
            
            left = support_tutte_tree(del_S, n, depth + 1)
            right = support_tutte_tree(con_S, n, depth + 1)
            T = poly_add(left['T'], right['T'])
            
            return {
                'S': S, 'T': T, 'type': 'ordinary',
                'coord': i,
                'children': [left, right]
            }
    
    for i in range(n):
        if all(m[i] > 0 for m in S):
            contracted = set()
            for m in S:
                new_m = list(m)
                new_m[i] -= 1
                contracted.add(tuple(new_m))
            con_S = frozenset(contracted)
            
            child = support_tutte_tree(con_S, n, depth + 1)
            T = poly_mul_x(child['T'])
            
            return {
                'S': S, 'T': T, 'type': 'loop',
                'coord': i,
                'children': [child]
            }
    
    return {'S': S, 'T': {0: 1}, 'type': 'fallback', 'children': []}


def draw_tree(ax, node, x, y, dx, dy, level=0):
    """Draw the recursion tree on a matplotlib axis."""
    # Node colors
    colors = {
        'empty': '#e8e8e8',
        'zero': '#d4edda', 
        'ordinary': '#cce5ff',
        'loop': '#fff3cd',
        'fallback': '#e8e8e8'
    }
    
    color = colors.get(node['type'], '#ffffff')
    
    # Draw node box
    box_w, box_h = 2.0, 0.9
    rect = patches.FancyBboxPatch(
        (x - box_w/2, y - box_h/2), box_w, box_h,
        boxstyle="round,pad=0.1", facecolor=color,
        edgecolor='black', linewidth=1.2
    )
    ax.add_patch(rect)
    
    # Node text
    s_str = support_str(node['S'])
    t_str = poly_str(node['T'])
    if len(s_str) > 25:
        s_str = s_str[:22] + "..."
    
    ax.text(x, y + 0.15, s_str, ha='center', va='center', fontsize=6, fontweight='bold')
    ax.text(x, y - 0.2, f"T = {t_str}", ha='center', va='center', fontsize=6, color='navy')
    
    # Label for operation type
    if node['type'] == 'ordinary':
        ax.text(x, y + 0.35, f"ord(i={node['coord']})", ha='center', va='center',
                fontsize=5, color='gray')
    elif node['type'] == 'loop':
        ax.text(x, y + 0.35, f"loop(i={node['coord']})", ha='center', va='center',
                fontsize=5, color='orange')
    
    # Draw children
    children = node['children']
    if len(children) == 2:
        labels = ['del', 'con']
        for idx, (child, label) in enumerate(zip(children, labels)):
            cx = x + (idx - 0.5) * dx
            cy = y + dy
            ax.plot([x, cx], [y - box_h/2, cy + box_h/2], 
                    'k-', linewidth=0.8)
            ax.text((x + cx)/2, (y - box_h/2 + cy + box_h/2)/2 + 0.15,
                    label, fontsize=6, color='red', ha='center')
            draw_tree(ax, child, cx, cy, dx * 0.5, dy, level + 1)
    elif len(children) == 1:
        cx, cy = x, y + dy
        ax.plot([x, cx], [y - box_h/2, cy + box_h/2], 
                'k-', linewidth=0.8)
        ax.text(x + 0.15, (y - box_h/2 + cy + box_h/2)/2 + 0.15,
                '×X', fontsize=7, color='orange', ha='center', fontweight='bold')
        draw_tree(ax, children[0], cx, cy, dx * 0.7, dy, level + 1)


# ===== Create visualization =====

# Example: S = {(0,0), (1,0), (0,1)} — basis indicators of U_{1,2}
S = frozenset({(0, 0), (1, 0), (0, 1)})
tree = support_tutte_tree(S, 2)

fig, ax = plt.subplots(1, 1, figsize=(14, 8))
ax.set_xlim(-8, 8)
ax.set_ylim(-7, 1.5)
ax.set_aspect('equal')
ax.axis('off')

ax.set_title(
    'Deletion-Contraction Recursion Tree\n'
    f'Support: {support_str(S)} → T(S) = {poly_str(tree["T"])}',
    fontsize=13, fontweight='bold', pad=15
)

draw_tree(ax, tree, 0, 0.5, 4, -2.2)

# Legend
legend_items = [
    ('Ordinary (del + con)', '#cce5ff'),
    ('Loop (× X)', '#fff3cd'),
    ('Base case', '#d4edda'),
]
for idx, (label, color) in enumerate(legend_items):
    rect = patches.Rectangle((4.5, -5.5 + idx * 0.6), 0.4, 0.35,
                             facecolor=color, edgecolor='black')
    ax.add_patch(rect)
    ax.text(5.1, -5.5 + idx * 0.6 + 0.17, label, fontsize=8, va='center')

plt.tight_layout()
plt.savefig('recursion_tree.png', dpi=150, bbox_inches='tight')
print("Saved recursion tree visualization")
