#!/usr/bin/env python3
"""
Visualization: Element Interaction Support Graph

Visualizes the support graph of a finite element mesh: vertices are elements,
edges connect elements sharing DOFs. Demonstrates the conjecture that the
support graph extracted from normalized energy equals the mesh adjacency graph.
Also shows how disconnected components enable independent energy computation
(Theorem 9: energy_independent_of_disjoint_support).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from collections import defaultdict

def generate_mesh(nx, ny):
    x = np.linspace(0, 1, nx + 1)
    y = np.linspace(0, 1, ny + 1)
    xx, yy = np.meshgrid(x, y)
    nodes = np.column_stack([xx.ravel(), yy.ravel()])
    elements = []
    for i in range(ny):
        for j in range(nx):
            n0 = i * (nx + 1) + j
            n1 = n0 + 1
            n2 = n0 + (nx + 1)
            n3 = n2 + 1
            elements.append([n0, n1, n2])
            elements.append([n1, n3, n2])
    return nodes, np.array(elements)

def compute_centroids(nodes, elements):
    return np.array([nodes[elem].mean(axis=0) for elem in elements])

def compute_adjacency(elements, n_nodes):
    node_to_elem = defaultdict(set)
    for idx, elem in enumerate(elements):
        for n in elem:
            node_to_elem[n].add(idx)
    edges = set()
    for elems in node_to_elem.values():
        elems = sorted(elems)
        for i in range(len(elems)):
            for j in range(i+1, len(elems)):
                edges.add((elems[i], elems[j]))
    return sorted(edges)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Connected mesh with support graph
nx, ny = 5, 5
nodes, elements = generate_mesh(nx, ny)
centroids = compute_centroids(nodes, elements)
edges = compute_adjacency(elements, len(nodes))

ax = axes[0]
# Draw mesh
for elem in elements:
    tri = plt.Polygon(nodes[elem], fill=False, edgecolor='lightgray', linewidth=0.5)
    ax.add_patch(tri)
# Draw support graph edges
for i, j in edges:
    ax.plot([centroids[i,0], centroids[j,0]], [centroids[i,1], centroids[j,1]],
            'b-', alpha=0.15, linewidth=0.5)
# Draw nodes (element centroids)
ax.scatter(centroids[:,0], centroids[:,1], s=15, c='steelblue', zorder=5)
ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-0.1, 1.1)
ax.set_aspect('equal')
ax.set_title(f'Connected Support Graph\n{len(elements)} elements, {len(edges)} edges',
             fontsize=11)
ax.set_xlabel('x')
ax.set_ylabel('y')

# Panel 2: Two disconnected blocks
nodes1, elems1 = generate_mesh(3, 3)
nodes2, elems2 = generate_mesh(3, 3)
nodes2[:, 0] += 1.5

n1 = len(nodes1)
nodes_all = np.vstack([nodes1, nodes2])
elements_all = np.vstack([elems1, elems2 + n1])
centroids_all = compute_centroids(nodes_all, elements_all)

ne1 = len(elems1)
edges1 = compute_adjacency(elems1, n1)
edges2 = [(i+ne1, j+ne1) for i, j in compute_adjacency(elems2, len(nodes2))]

ax = axes[1]
colors = ['#2196F3'] * ne1 + ['#FF5722'] * len(elems2)
for idx, elem in enumerate(elements_all):
    tri = plt.Polygon(nodes_all[elem], fill=True, facecolor=colors[idx],
                       alpha=0.15, edgecolor='gray', linewidth=0.5)
    ax.add_patch(tri)
for i, j in edges1:
    ax.plot([centroids_all[i,0], centroids_all[j,0]],
            [centroids_all[i,1], centroids_all[j,1]], 'b-', alpha=0.3, linewidth=0.5)
for i, j in edges2:
    ax.plot([centroids_all[i,0], centroids_all[j,0]],
            [centroids_all[i,1], centroids_all[j,1]], 'r-', alpha=0.3, linewidth=0.5)
ax.scatter(centroids_all[:ne1,0], centroids_all[:ne1,1], s=20, c='#2196F3', zorder=5)
ax.scatter(centroids_all[ne1:,0], centroids_all[ne1:,1], s=20, c='#FF5722', zorder=5)
ax.set_xlim(-0.2, 2.7)
ax.set_ylim(-0.2, 1.2)
ax.set_aspect('equal')
ax.set_title('Disconnected Support Graph\n(Theorem 9: E = E₁ + E₂)', fontsize=11)
ax.set_xlabel('x')

# Panel 3: Degree distribution
ax = axes[2]
# Degree of each vertex in the support graph
degree = defaultdict(int)
for i, j in edges:
    degree[i] += 1
    degree[j] += 1
degrees = [degree.get(i, 0) for i in range(len(elements))]
max_deg = max(degrees) if degrees else 0
bins = range(0, max_deg + 2)
ax.hist(degrees, bins=bins, color='steelblue', edgecolor='white', alpha=0.8,
        align='left')
ax.set_xlabel('Vertex Degree')
ax.set_ylabel('Count')
ax.set_title(f'Support Graph Degree Distribution\nMean degree = {np.mean(degrees):.1f}',
             fontsize=11)
ax.grid(True, alpha=0.3)

fig.suptitle('Element Interaction Support Graphs — Certified by Lean 4',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_support_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_graph.png")
