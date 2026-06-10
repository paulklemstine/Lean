#!/usr/bin/env python3
"""
Tropical Protocol Trees — Algorithms and Visualizations

Implements core algorithms from the research paper with
visualization support for tree structures and theorem properties.
"""

import math
import random
import base64
import io
from typing import Optional
from dataclasses import dataclass

INF = float('inf')


@dataclass
class TropProtocolTree:
    """Tropical protocol tree with edge costs and leaf values."""
    leaf_value: Optional[float] = None
    children: Optional[list] = None

    @staticmethod
    def leaf(v): return TropProtocolTree(leaf_value=v)

    @staticmethod
    def node(cs): return TropProtocolTree(children=cs)

    def is_leaf(self): return self.children is None


# ============================================================
# Core Algorithms
# ============================================================

def evaluate(T: TropProtocolTree) -> float:
    """
    Algorithm: EVALUATE — Tropical protocol evaluation

    Computes the min-plus optimal value by recursive aggregation.

    Time: O(n) where n = number of nodes
    Space: O(d) stack depth where d = tree depth

    Pseudocode:
        EVALUATE(T):
            if T is leaf(a): return a
            return min_{(c,S) in children(T)} (c + EVALUATE(S))
    """
    if T.is_leaf():
        return T.leaf_value
    if not T.children:
        return INF
    return min(c + evaluate(child) for c, child in T.children)


def enumerate_paths(T: TropProtocolTree, prefix_cost=0):
    """
    Algorithm: ENUMERATE_PATHS — List all root-to-leaf paths with costs

    Yields (total_cost, path) for each root-to-leaf path.

    Time: O(n * L) where L = number of leaves
    Space: O(d) for recursion stack

    Pseudocode:
        ENUMERATE_PATHS(T, acc=0):
            if T is leaf(a): yield (acc + a, [])
            for (c, S) in children(T):
                for (cost, path) in ENUMERATE_PATHS(S, acc + c):
                    yield (cost, [c] ++ path)
    """
    if T.is_leaf():
        yield (prefix_cost + T.leaf_value, [])
        return
    for i, (c, child) in enumerate(T.children or []):
        for cost, path in enumerate_paths(child, prefix_cost + c):
            yield (cost, [c] + path)


def find_optimal_path(T: TropProtocolTree):
    """
    Algorithm: FIND_OPTIMAL — Find the optimal (minimum cost) path

    Returns (optimal_cost, optimal_path_edges)

    Time: O(n)
    Space: O(d)
    """
    best_cost = INF
    best_path = []
    for cost, path in enumerate_paths(T):
        if cost < best_cost:
            best_cost = cost
            best_path = path
    return best_cost, best_path


def verify_optimality(T: TropProtocolTree, claimed_value: float) -> dict:
    """
    Algorithm: VERIFY — Verify a claimed optimal value

    Returns a verification certificate with:
    - 'valid': bool — whether the claim is correct
    - 'witness': path achieving the claimed value (if exists)
    - 'all_ge': whether all paths have cost >= claimed value

    Time: O(n)
    """
    witness = None
    all_ge = True
    for cost, path in enumerate_paths(T):
        if cost == claimed_value and witness is None:
            witness = path
        if cost < claimed_value:
            all_ge = False
    return {
        'valid': witness is not None and all_ge,
        'witness': witness,
        'all_ge': all_ge,
        'has_witness': witness is not None,
    }


def tree_to_dag(T: TropProtocolTree):
    """
    Algorithm: TREE_TO_DAG — Convert protocol tree to weighted DAG

    Creates a directed acyclic graph representation with:
    - vertices: node IDs
    - edges: (src, dst, weight) triples
    - source: root node ID
    - sink: virtual sink node

    The shortest path from source to sink equals the tree's value.

    Time: O(n)
    """
    vertices = []
    edges = []
    counter = [0]

    def build(node):
        node_id = counter[0]
        counter[0] += 1
        vertices.append(node_id)

        if node.is_leaf():
            return node_id, node.leaf_value
        child_info = []
        for c, child in (node.children or []):
            child_id, leaf_cost = build(child)
            edges.append((node_id, child_id, c))
            child_info.append((child_id, leaf_cost))
        return node_id, None

    root_id, _ = build(T)
    sink_id = counter[0]
    vertices.append(sink_id)

    # Connect leaves to sink
    def connect_leaves(node, node_id_counter):
        nid = node_id_counter[0]
        node_id_counter[0] += 1
        if node.is_leaf():
            if node.leaf_value != INF:
                edges.append((nid, sink_id, int(node.leaf_value)))
            return
        for c, child in (node.children or []):
            connect_leaves(child, node_id_counter)

    connect_leaves(T, [0])

    return {
        'vertices': vertices,
        'edges': edges,
        'source': root_id,
        'sink': sink_id,
    }


def dag_shortest_path(dag: dict) -> float:
    """Compute shortest path in a DAG from source to sink."""
    dist = {v: INF for v in dag['vertices']}
    dist[dag['source']] = 0

    # Topological order (by ID since we assign IDs in DFS order)
    for src, dst, weight in sorted(dag['edges'], key=lambda e: e[0]):
        if dist[src] + weight < dist[dst]:
            dist[dst] = dist[src] + weight

    return dist[dag['sink']]


# ============================================================
# Tropical Matrix Multiplication
# ============================================================

def tropical_matmul(A, B):
    """
    Min-plus matrix multiplication.

    (A ⊗ B)[i][j] = min_k (A[i][k] + B[k][j])

    Time: O(n³)
    """
    n = len(A)
    m = len(B[0]) if B else 0
    p = len(B)
    C = [[INF] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for k in range(p):
                C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C


def tropical_matpow(M, k):
    """
    Min-plus matrix power M^k.

    M^k represents k-step shortest paths.

    Time: O(n³ · k) (naive) or O(n³ · log k) with repeated squaring
    """
    n = len(M)
    # Identity: M^0 = diagonal 0, off-diagonal INF
    result = [[0 if i == j else INF for j in range(n)] for i in range(n)]
    base = [row[:] for row in M]
    while k > 0:
        if k % 2 == 1:
            result = tropical_matmul(result, base)
        base = tropical_matmul(base, base)
        k //= 2
    return result


# ============================================================
# Visualization
# ============================================================

def generate_tree_svg(T: TropProtocolTree, width=600, height=400) -> str:
    """Generate SVG visualization of a tropical protocol tree."""
    svg_elements = []

    def layout(node, x, y, x_span, level=0):
        """Assign positions to nodes."""
        positions = []
        node_pos = (x, y)
        positions.append(('node', x, y, node))

        if node.is_leaf():
            return positions

        n_children = len(node.children) if node.children else 0
        if n_children == 0:
            return positions

        child_y = y + 80
        child_width = x_span / n_children
        for i, (cost, child) in enumerate(node.children):
            child_x = x - x_span/2 + child_width * (i + 0.5)
            positions.append(('edge', x, y, child_x, child_y, cost))
            positions.extend(layout(child, child_x, child_y, child_width * 0.8, level + 1))

        return positions

    elements = layout(T, width/2, 40, width * 0.8)

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">\n'
    svg += '<rect width="100%" height="100%" fill="#fafafa"/>\n'

    # Draw edges first
    for elem in elements:
        if elem[0] == 'edge':
            _, x1, y1, x2, y2, cost = elem
            svg += f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="#666" stroke-width="2"/>\n'
            mx, my = (x1+x2)/2 - 10, (y1+y2)/2 - 5
            svg += f'<text x="{mx:.1f}" y="{my:.1f}" font-size="12" fill="#c00" font-weight="bold">c={cost}</text>\n'

    # Draw nodes
    for elem in elements:
        if elem[0] == 'node':
            _, x, y, node = elem
            if node.is_leaf():
                v = '∞' if node.leaf_value == INF else str(int(node.leaf_value))
                svg += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="18" fill="#4CAF50" stroke="#333" stroke-width="2"/>\n'
                svg += f'<text x="{x:.1f}" y="{y+5:.1f}" text-anchor="middle" font-size="13" fill="white" font-weight="bold">{v}</text>\n'
            else:
                svg += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="18" fill="#2196F3" stroke="#333" stroke-width="2"/>\n'
                v = evaluate(node)
                v_str = '∞' if v == INF else str(int(v))
                svg += f'<text x="{x:.1f}" y="{y+5:.1f}" text-anchor="middle" font-size="11" fill="white" font-weight="bold">{v_str}</text>\n'

    svg += '</svg>'
    return svg


def generate_depth_bound_chart(max_b=5, max_d=6) -> str:
    """Generate SVG chart showing depth bound b^d vs actual leaves."""
    width, height = 600, 400
    margin = 60
    plot_w = width - 2 * margin
    plot_h = height - 2 * margin

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}">\n'
    svg += '<rect width="100%" height="100%" fill="white"/>\n'

    # Title
    svg += f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">Depth Bound: numLeaves ≤ b^depth</text>\n'

    # Axes
    svg += f'<line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" stroke="black" stroke-width="2"/>\n'
    svg += f'<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" stroke="black" stroke-width="2"/>\n'

    # Labels
    svg += f'<text x="{width/2}" y="{height-10}" text-anchor="middle" font-size="12">Depth</text>\n'
    svg += f'<text x="15" y="{height/2}" text-anchor="middle" font-size="12" transform="rotate(-90,15,{height/2})">Leaves / Bound</text>\n'

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    max_val = max(b ** max_d for b in range(2, max_b + 1))

    for bi, b in enumerate(range(2, max_b + 1)):
        color = colors[bi % len(colors)]
        points = []
        for d in range(max_d + 1):
            x = margin + d / max_d * plot_w
            val = b ** d
            y = height - margin - (math.log(val + 1) / math.log(max_val + 1)) * plot_h
            points.append(f"{x:.1f},{y:.1f}")

        svg += f'<polyline points="{" ".join(points)}" fill="none" stroke="{color}" stroke-width="2"/>\n'
        last_x, last_y = points[-1].split(',')
        svg += f'<text x="{float(last_x)+5}" y="{float(last_y)}" font-size="11" fill="{color}">b={b}</text>\n'

    # Depth labels
    for d in range(max_d + 1):
        x = margin + d / max_d * plot_w
        svg += f'<text x="{x:.1f}" y="{height-margin+15}" text-anchor="middle" font-size="10">{d}</text>\n'

    svg += '</svg>'
    return svg


def generate_visualizations():
    """Generate all visualizations and return as dict."""
    # Example tree
    T = TropProtocolTree.node([
        (1, TropProtocolTree.leaf(5)),
        (2, TropProtocolTree.node([
            (0, TropProtocolTree.leaf(3)),
            (1, TropProtocolTree.leaf(1)),
        ])),
        (3, TropProtocolTree.leaf(4)),
    ])

    tree_svg = generate_tree_svg(T, width=600, height=300)
    chart_svg = generate_depth_bound_chart()

    return {
        'tree': tree_svg,
        'depth_chart': chart_svg,
    }


if __name__ == '__main__':
    # Demo: tree to DAG conversion
    T = TropProtocolTree.node([
        (1, TropProtocolTree.leaf(5)),
        (2, TropProtocolTree.leaf(1)),
        (3, TropProtocolTree.leaf(4)),
    ])

    print("Tree value:", evaluate(T))
    dag = tree_to_dag(T)
    print("DAG shortest path:", dag_shortest_path(dag))
    print("Match:", evaluate(T) == dag_shortest_path(dag))

    # Optimal path
    cost, path = find_optimal_path(T)
    print(f"Optimal cost: {cost}, path edges: {path}")

    # Verification certificate
    cert = verify_optimality(T, 3.0)
    print(f"Verification: {cert}")

    # Tropical matrix power demo
    print("\nTropical matrix multiplication demo:")
    M = [
        [0, 2, INF],
        [INF, 0, 1],
        [3, INF, 0],
    ]
    M2 = tropical_matpow(M, 2)
    print("M² =", M2)
    M3 = tropical_matpow(M, 3)
    print("M³ =", M3)

    # Generate visualizations
    vizs = generate_visualizations()
    for name, svg in vizs.items():
        filename = f'{name}_visualization.svg'
        with open(filename, 'w') as f:
            f.write(svg)
        print(f"Saved {filename}")
