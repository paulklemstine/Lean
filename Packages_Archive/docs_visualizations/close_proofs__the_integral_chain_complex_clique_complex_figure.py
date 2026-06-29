"""Visualization: clique complex of a small graph and its Euler characteristic.

Renders a graph, highlights its maximal cliques (filled simplices), and prints
the reduced Euler characteristic as the alternating clique count. Requires
matplotlib. Saves the figure to `clique_complex.png`.
"""
from itertools import combinations
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math


def is_clique(combo, edges):
    return all(frozenset((a, b)) in edges for a, b in combinations(combo, 2))


def cliques_of_size(verts, edges, k):
    return [c for c in combinations(verts, k) if is_clique(c, edges)]


def euler_characteristic(verts, edges):
    chi = 0
    dim = 1
    while True:
        cs = cliques_of_size(verts, edges, dim + 1)
        if not cs and dim > len(verts):
            break
        chi += (-1) ** dim * len(cs)
        dim += 1
        if dim > len(verts):
            break
    return chi


def main():
    verts = [1, 2, 3, 4, 5]
    edge_list = [(1, 2), (2, 3), (1, 3), (3, 4), (4, 5), (3, 5)]
    edges = {frozenset(e) for e in edge_list}

    # Circular layout.
    pos = {v: (math.cos(2 * math.pi * i / len(verts)),
               math.sin(2 * math.pi * i / len(verts)))
           for i, v in enumerate(verts)}

    fig, ax = plt.subplots(figsize=(6, 6))

    # Fill 2-simplices (triangles = 3-cliques).
    for tri in cliques_of_size(verts, edges, 3):
        poly = patches.Polygon([pos[v] for v in tri], closed=True,
                               alpha=0.3, color="tab:orange")
        ax.add_patch(poly)

    # Draw edges (1-simplices).
    for e in edge_list:
        x = [pos[e[0]][0], pos[e[1]][0]]
        y = [pos[e[0]][1], pos[e[1]][1]]
        ax.plot(x, y, color="tab:blue", lw=2, zorder=2)

    # Draw vertices (0-simplices).
    for v in verts:
        ax.plot(*pos[v], "o", color="black", markersize=14, zorder=3)
        ax.annotate(str(v), pos[v], color="white", ha="center", va="center",
                    fontsize=10, zorder=4)

    chi = euler_characteristic(verts, edges)
    n_v = len(verts)
    n_e = len(cliques_of_size(verts, edges, 2))
    n_t = len(cliques_of_size(verts, edges, 3))
    ax.set_title(f"Clique complex  Δ(G)\\n"
                 f"vertices={n_v}, edges={n_e}, triangles={n_t}\\n"
                 f"reduced χ = {n_v} - {n_e} + {n_t} = {chi}")
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("clique_complex.png", dpi=150)
    print("saved clique_complex.png ; reduced euler characteristic =", chi)


if __name__ == "__main__":
    main()
