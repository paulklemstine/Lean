"""
Visualization 2: Newton Functional Graphs over Finite Fields

This script visualizes the Newton functional graph of a polynomial over Z/pZ.
Each point in the finite field is a vertex; arrows show where the Newton map
sends each point. Fixed points (= roots, by Theorem 1) are highlighted.
The basin-depth coloring shows the filtration used for persistence.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


# ─── Self-contained implementations ────────────────────────────────────────

def poly_eval(coeffs, x, p):
    result, power = 0, 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result

def poly_derivative(coeffs):
    if len(coeffs) <= 1:
        return [0]
    return [i * coeffs[i] for i in range(1, len(coeffs))]

def newton_step(coeffs, x, p):
    deriv = poly_derivative(coeffs)
    fx = poly_eval(coeffs, x, p)
    fpx = poly_eval(deriv, x, p)
    if fpx % p == 0:
        return None
    return (x - fx * pow(fpx, p - 2, p)) % p

def basin_depths(coeffs, p, max_depth=20):
    graph = {x: newton_step(coeffs, x, p) for x in range(p)}
    depth = {x: 0 for x in range(p) if graph[x] is not None and graph[x] == x}
    for d in range(1, max_depth + 1):
        for x in range(p):
            if x not in depth:
                y = graph[x]
                if y is not None and y in depth and depth[y] == d - 1:
                    depth[x] = d
    return graph, depth


# ─── Plot Newton graph for a small prime ────────────────────────────────────

def plot_newton_graph(coeffs, p, poly_name, ax):
    """Plot the Newton functional graph as a circular layout."""
    graph, depth = basin_depths(coeffs, p)

    # Circular layout
    angles = np.linspace(0, 2 * np.pi, p, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)

    # Color by depth
    max_d = max(depth.values()) if depth else 0
    cmap = plt.cm.viridis

    # Draw edges
    for x in range(p):
        y = graph[x]
        if y is not None and y != x:
            dx = x_pos[y] - x_pos[x]
            dy = y_pos[y] - y_pos[x]
            ax.annotate("", xy=(x_pos[y], y_pos[y]),
                        xytext=(x_pos[x], y_pos[x]),
                        arrowprops=dict(arrowstyle="->", color='gray',
                                        alpha=0.3, lw=0.8,
                                        connectionstyle="arc3,rad=0.15"))

    # Draw vertices
    for x in range(p):
        d = depth.get(x, -1)
        if d == 0:  # Root (fixed point)
            color = '#FF1744'
            size = 200
            marker = '*'
            zorder = 10
        elif d > 0:
            color = cmap(d / max(max_d, 1))
            size = 80
            marker = 'o'
            zorder = 5
        else:  # Singular or unreached
            color = '#BDBDBD'
            size = 40
            marker = 'x'
            zorder = 3

        ax.scatter(x_pos[x], y_pos[x], c=[color], s=size, marker=marker,
                   zorder=zorder, edgecolors='black', linewidths=0.5)

        # Label vertices
        label_r = 1.15
        ax.text(label_r * x_pos[x], label_r * y_pos[x], str(x),
                fontsize=6, ha='center', va='center', alpha=0.7)

    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.set_title(f"{poly_name} mod {p}", fontsize=10)
    ax.axis('off')

    # Count roots
    roots = [x for x in range(p) if depth.get(x) == 0]
    ax.text(0, -1.35, f"Roots: {roots}", fontsize=8, ha='center',
            style='italic', color='#FF1744')


# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Newton Functional Graphs over Finite Fields\n"
             "★ = roots (Newton fixed points, depth 0), "
             "colored = basin depth, × = singular/unreached",
             fontsize=13, fontweight='bold')

test_cases = [
    ([-1, 0, 1], 11, "$x^2 - 1$"),
    ([-2, 0, 0, 1], 13, "$x^3 - 2$"),
    ([0, -1, 0, 1], 11, "$x^3 - x$"),
    ([-1, -1, 0, 0, 0, 1], 13, "$x^5 - x - 1$"),
    ([1, 0, -1, 0, 1], 13, "$x^4 - x^2 + 1$"),
    ([-1, -3, 0, 1], 13, "$x^3 - 3x - 1$"),
]

for idx, (coeffs, p, name) in enumerate(test_cases):
    ax = axes[idx // 3][idx % 3]
    plot_newton_graph(coeffs, p, name, ax)

plt.tight_layout()
plt.savefig("viz_newton_graph.png", dpi=150, bbox_inches='tight')
print("Saved: viz_newton_graph.png")
