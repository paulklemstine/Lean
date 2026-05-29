"""
Overlap Degree Spectrum — Distribution of Overlap Complexity

Visualizes how overlap degree varies across all connected graphs of
a given size, showing the distribution from the fully disjoint regime
(degree 0) to the maximally overlapping regime.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque, Counter
from itertools import combinations
from typing import List, Set, Dict, FrozenSet, Tuple


# ============================================================
# Self-contained implementations
# ============================================================

class SupportFamily:
    def __init__(self, supports):
        self.supports = list(supports)
        self.n = len(supports)


class SimpleGraph:
    def __init__(self, n, edges):
        self.n = n
        self.adj = defaultdict(set)
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def is_connected(self):
        if self.n == 0:
            return True
        visited = set()
        queue = deque([0])
        visited.add(0)
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def overlap_degree(family):
    count = 0
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            count += 1
    return count


def overlap_class_count(family):
    adj = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    count = 0
    for start in range(family.n):
        if start in visited:
            continue
        count += 1
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
    return count


def find_cycles(adj_S, vertices):
    visited = set()
    parent = {}
    cycles = []
    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in adj_S[v]:
            if w == p:
                continue
            if w in visited:
                cycle = [w]
                curr = v
                while curr != w:
                    cycle.append(curr)
                    curr = parent[curr]
                cycles.append(cycle)
            else:
                dfs(w, v)
    for v in vertices:
        if v not in visited:
            dfs(v, -1)
    return cycles


def cycle_support_family(G, S):
    vertices = sorted(S)
    adj_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_S[u].add(v)
    cycles = find_cycles(adj_S, vertices)
    return SupportFamily([frozenset(c) for c in cycles])


def generate_connected_graphs(n):
    if n <= 1:
        return [SimpleGraph(max(n, 1), [])]
    all_edges = list(combinations(range(n), 2))
    m = len(all_edges)
    graphs = []
    for mask in range(1, 1 << m):
        edges = [all_edges[i] for i in range(m) if mask & (1 << i)]
        G = SimpleGraph(n, edges)
        if G.is_connected():
            graphs.append(G)
    return graphs


# ============================================================
# Visualization
# ============================================================

def visualize_degree_spectrum():
    """Create a multi-panel visualization of overlap degree statistics."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Overlap Degree Spectrum Across Graph Families',
                 fontsize=16, fontweight='bold')

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']

    # Collect data for n = 3, 4, 5, 6
    all_data = {}
    for n in [3, 4, 5, 6]:
        graphs = generate_connected_graphs(n)
        degrees = []
        class_counts = []
        num_cycles_list = []

        for G in graphs:
            for q in range(n):
                S = set(range(n)) - {q}
                F = cycle_support_family(G, S)
                if F.n > 0:
                    degrees.append(overlap_degree(F))
                    class_counts.append(overlap_class_count(F))
                    num_cycles_list.append(F.n)

        all_data[n] = {
            'degrees': degrees,
            'class_counts': class_counts,
            'num_cycles': num_cycles_list,
            'num_graphs': len(graphs),
        }

    # ---- Panel 1: Overlap Degree Distribution ----
    ax1 = axes[0, 0]
    ax1.set_title('Overlap Degree Distribution', fontweight='bold')

    for idx, n in enumerate([3, 4, 5, 6]):
        if all_data[n]['degrees']:
            counts = Counter(all_data[n]['degrees'])
            max_deg = max(counts.keys()) if counts else 0
            xs = list(range(max_deg + 1))
            ys = [counts.get(x, 0) for x in xs]
            ax1.bar([x + idx * 0.2 - 0.3 for x in xs], ys, width=0.18,
                   label=f'n={n}', color=colors[idx], alpha=0.8)

    ax1.set_xlabel('Overlap Degree')
    ax1.set_ylabel('Count')
    ax1.legend(fontsize=9)
    ax1.grid(axis='y', alpha=0.3)

    # ---- Panel 2: Class Count Distribution ----
    ax2 = axes[0, 1]
    ax2.set_title('Overlap Class Count Distribution', fontweight='bold')

    for idx, n in enumerate([3, 4, 5, 6]):
        if all_data[n]['class_counts']:
            counts = Counter(all_data[n]['class_counts'])
            max_cc = max(counts.keys()) if counts else 0
            xs = list(range(1, max_cc + 1))
            ys = [counts.get(x, 0) for x in xs]
            ax2.bar([x + idx * 0.2 - 0.3 for x in xs], ys, width=0.18,
                   label=f'n={n}', color=colors[idx], alpha=0.8)

    ax2.set_xlabel('Number of Overlap Classes')
    ax2.set_ylabel('Count')
    ax2.legend(fontsize=9)
    ax2.grid(axis='y', alpha=0.3)

    # ---- Panel 3: Degree vs Class Count Scatter ----
    ax3 = axes[1, 0]
    ax3.set_title('Overlap Degree vs Class Count', fontweight='bold')

    for idx, n in enumerate([4, 5, 6]):
        if all_data[n]['degrees']:
            ax3.scatter(all_data[n]['degrees'], all_data[n]['class_counts'],
                       alpha=0.4, s=20, color=colors[idx + 1], label=f'n={n}')

    ax3.set_xlabel('Overlap Degree')
    ax3.set_ylabel('Overlap Class Count')
    ax3.legend(fontsize=9)
    ax3.grid(alpha=0.3)

    # ---- Panel 4: Summary Statistics ----
    ax4 = axes[1, 1]
    ax4.set_title('Summary Statistics', fontweight='bold')
    ax4.axis('off')

    rows = ['n', 'Graphs', 'Instances', 'Mean Degree', 'Max Degree',
            'Mean Classes']
    cell_data = []
    for n in [3, 4, 5, 6]:
        d = all_data[n]
        if d['degrees']:
            cell_data.append([
                str(n),
                str(d['num_graphs']),
                str(len(d['degrees'])),
                f"{np.mean(d['degrees']):.2f}",
                str(max(d['degrees'])),
                f"{np.mean(d['class_counts']):.2f}",
            ])
        else:
            cell_data.append([str(n), str(d['num_graphs']), '0',
                            '-', '-', '-'])

    table = ax4.table(cellText=list(zip(*cell_data)),
                     rowLabels=rows,
                     colLabels=[f'n={n}' for n in [3, 4, 5, 6]],
                     cellLoc='center',
                     loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 1.4)

    # Color header row
    for j in range(4):
        table[0, j].set_facecolor(colors[j])
        table[0, j].set_text_props(color='white', fontweight='bold')

    plt.tight_layout()
    plt.savefig('overlap_degree_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: overlap_degree_spectrum.png")


if __name__ == "__main__":
    visualize_degree_spectrum()
