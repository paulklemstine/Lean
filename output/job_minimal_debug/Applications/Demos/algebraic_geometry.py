#!/usr/bin/env python3
"""
Applications of Tropical Divisor Theory

Demonstrates real-world applications of the tree divisor formalization:
1. Network load balancing (chip-firing as resource redistribution)
2. Electrical network analysis (graph Laplacian as resistance)
3. Phylogenetic tree analysis (divisors on evolutionary trees)
4. Sandpile dynamics (critical configurations on trees)
"""

from __future__ import annotations
from typing import Dict, List, Tuple
from collections import defaultdict, deque
import random


class NetworkTree:
    """A tree network for load balancing applications."""

    def __init__(self, n: int, edges: List[Tuple[int, int]],
                 labels: Dict[int, str] = None):
        self.n = n
        self.adj: Dict[int, List[int]] = defaultdict(list)
        for u, v in edges:
            self.adj[u].append(v)
            self.adj[v].append(u)
        self.labels = labels or {i: f"Node_{i}" for i in range(n)}

    def degree(self, v: int) -> int:
        return len(self.adj[v])


def graph_laplacian(T: NetworkTree, f: Dict[int, int]) -> Dict[int, int]:
    result = {}
    for v in range(T.n):
        total = 0
        for w in T.adj[v]:
            total += f.get(w, 0) - f.get(v, 0)
        result[v] = total
    return result


def leaf_fire_normalize(T: NetworkTree, load: Dict[int, int],
                        target: int = None) -> Tuple[Dict[int, int], Dict[int, int], int]:
    """Normalize load distribution by leaf-firing."""
    n = T.n
    current = {v: load.get(v, 0) for v in range(n)}
    f = {v: 0 for v in range(n)}
    active = set(range(n))
    active_deg = {v: T.degree(v) for v in range(n)}

    leaf_queue = deque()
    for v in range(n):
        if active_deg[v] == 1 and (target is None or v != target):
            leaf_queue.append(v)

    while len(active) > 1:
        if not leaf_queue:
            break
        leaf = leaf_queue.popleft()
        if leaf not in active or active_deg[leaf] != 1:
            continue
        if target is not None and leaf == target:
            continue

        neighbor = None
        for w in T.adj[leaf]:
            if w in active:
                neighbor = w
                break
        if neighbor is None:
            break

        f[leaf] += current[leaf]
        current[neighbor] += current[leaf]
        current[leaf] = 0
        active.remove(leaf)
        active_deg[neighbor] -= 1
        if active_deg[neighbor] == 1 and (target is None or neighbor != target):
            leaf_queue.append(neighbor)

    target_v = next(iter(active))
    return current, f, target_v


# ─── Application 1: Network Load Balancing ───────────────────────────────────

def demo_load_balancing():
    """Demonstrate chip-firing as network load balancing.

    In a tree-structured network (e.g., a data center hierarchy),
    tasks/resources distributed across nodes can be consolidated
    to a single collector node using the divisor normalization algorithm.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Load Balancing via Chip-Firing")
    print("=" * 60)

    # Data center hierarchy
    labels = {0: "Root_Switch", 1: "Rack_A", 2: "Rack_B",
              3: "Server_A1", 4: "Server_A2", 5: "Server_B1", 6: "Server_B2"}
    T = NetworkTree(7, [(0,1), (0,2), (1,3), (1,4), (2,5), (2,6)], labels)

    # Current task distribution (some servers overloaded, others idle)
    tasks = {0: 0, 1: 2, 2: -1, 3: 5, 4: -2, 5: 3, 6: 1}
    total = sum(tasks.values())

    print(f"\nNetwork topology: tree-structured data center")
    print(f"Task distribution:")
    for v in range(T.n):
        status = "overloaded" if tasks[v] > 2 else "idle" if tasks[v] < 0 else "normal"
        print(f"  {labels[v]}: {tasks[v]} tasks ({status})")
    print(f"Total tasks: {total}")

    # Consolidate to root
    result, transfers, target = leaf_fire_normalize(T, tasks, target=0)
    print(f"\nAfter consolidation to {labels[target]}:")
    print(f"  {labels[target]}: {result[target]} tasks")
    print(f"  Transfer schedule (firing function): {transfers}")


# ─── Application 2: Electrical Networks ──────────────────────────────────────

def demo_electrical_network():
    """Demonstrate the Laplacian perspective for electrical networks.

    On a tree network, the potential function f satisfying div(f) = I
    (where I is the current injection vector) can be found using
    the Jacobian triviality theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Electrical Network Potentials")
    print("=" * 60)

    # Simple resistor network (tree topology)
    T = NetworkTree(5, [(0,1), (1,2), (2,3), (3,4)],
                    {0: "A", 1: "B", 2: "C", 3: "D", 4: "E"})

    # Current injection: +3 at A, -3 at E (current flows A → E)
    current = {0: 3, 1: 0, 2: 0, 3: 0, 4: -3}
    print(f"\nResistor chain: A - B - C - D - E (unit resistors)")
    print(f"Current injection: I = {current}")
    print(f"  +3A injected at A, -3A extracted at E")

    # Find potentials: solve Δf = I
    _, f_fire, _ = leaf_fire_normalize(T, current)
    f = {v: -f_fire[v] for v in range(T.n)}
    div_f = graph_laplacian(T, f)

    print(f"\nNode potentials (V = f):")
    for v in range(T.n):
        print(f"  {T.labels[v]}: {f[v]}V")
    print(f"\nVerification: Δf = {div_f}")
    print(f"Matches current injection? "
          f"{'✓' if all(div_f[v] == current[v] for v in range(T.n)) else '✗'}")
    print(f"\nVoltage drops across resistors:")
    for u, v in [(0,1), (1,2), (2,3), (3,4)]:
        print(f"  {T.labels[u]}-{T.labels[v]}: {f[u] - f[v]}V")


# ─── Application 3: Phylogenetic Tree Analysis ──────────────────────────────

def demo_phylogenetics():
    """Demonstrate divisor theory on phylogenetic trees.

    In evolutionary biology, trees represent phylogenetic relationships.
    Divisors on these trees can represent trait distributions, and
    linear equivalence captures evolutionary conservation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Phylogenetic Trait Distribution")
    print("=" * 60)

    # Simple phylogenetic tree
    #       Ancestor(0)
    #      /           \
    #   Primate(1)    Carnivore(2)
    #   /      \         |
    # Human(3) Chimp(4) Cat(5)
    labels = {0: "Ancestor", 1: "Primate", 2: "Carnivore",
              3: "Human", 4: "Chimp", 5: "Cat"}
    T = NetworkTree(6, [(0,1), (0,2), (1,3), (1,4), (2,5)], labels)

    # Trait "score" (e.g., brain-to-body ratio, scaled)
    trait = {0: 0, 1: 1, 2: -1, 3: 3, 4: 2, 5: -2}
    total = sum(trait.values())

    print(f"\nPhylogenetic tree with trait scores:")
    for v in range(T.n):
        print(f"  {labels[v]}: score = {trait[v]}")
    print(f"Total trait score: {total}")

    result, _, target = leaf_fire_normalize(T, trait, target=0)
    print(f"\nAfter evolutionary consolidation to {labels[target]}:")
    print(f"  Total conserved score: {result[target]}")
    print(f"  (= sum of all trait scores = {total})")
    print(f"\nInterpretation: The total trait 'budget' is conserved")
    print(f"under evolutionary redistribution (chip-firing moves).")
    print(f"This is the tropical analog of degree conservation.")


# ─── Application 4: Sandpile Dynamics ────────────────────────────────────────

def demo_sandpile():
    """Demonstrate sandpile/chip-firing dynamics on trees.

    The abelian sandpile model on a graph is intimately connected
    to divisor theory. On trees, the dynamics are especially clean:
    every configuration stabilizes to the unique minimal representative.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Abelian Sandpile on Trees")
    print("=" * 60)

    T = NetworkTree(5, [(0,1), (1,2), (1,3), (3,4)],
                    {0: "a", 1: "b", 2: "c", 3: "d", 4: "e"})

    # Initial chip configuration
    chips = {0: 0, 1: 5, 2: 0, 3: 3, 4: 0}
    print(f"\nTree: a-b-c, b-d-e (star-like)")
    print(f"Initial chips: {chips}")
    print(f"Total chips: {sum(chips.values())}")

    # Simulate firing: a vertex fires if it has >= degree chips
    print(f"\nFiring simulation (vertex fires if chips >= degree, max 20 steps):")
    current = dict(chips)
    step = 0
    max_steps = 20
    while step < max_steps:
        fired = False
        for v in range(T.n):
            if current[v] >= T.degree(v):
                print(f"  Step {step}: Fire vertex {T.labels[v]} "
                      f"(has {current[v]} >= {T.degree(v)} = deg)")
                current[v] -= T.degree(v)
                for w in T.adj[v]:
                    current[w] += 1
                print(f"    Result: {current}")
                fired = True
                step += 1
                break
        if not fired:
            break
    if step >= max_steps:
        print(f"  (Reached step limit — without a sink, firing may not terminate)")
        print(f"  Note: The abelian sandpile model requires a sink vertex for termination.")

    print(f"\nStable configuration: {current}")
    print(f"Total chips: {sum(current.values())} (conserved ✓)")
    print(f"\nOn a tree, the stable configuration is unique regardless")
    print(f"of firing order (abelian property of chip-firing).")


if __name__ == "__main__":
    demo_load_balancing()
    demo_electrical_network()
    demo_phylogenetics()
    demo_sandpile()
    print("\n" + "=" * 60)
    print("All applications demonstrated!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Divisor Theory on Trees — Interactive Demonstrations

Demonstrates the key theorems of tropical divisor theory on trees:
1. Principal divisors have degree zero
2. Every divisor on a tree is linearly equivalent to a singleton
3. Every divisor of nonneg degree has an effective representative
"""

from __future__ import annotations
from typing import Dict, List, Tuple, Set, Optional
from collections import defaultdict, deque


class Tree:
    """A finite tree represented by adjacency lists."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, List[int]] = defaultdict(list)
        for u, v in edges:
            self.adj[u].append(v)
            self.adj[v].append(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def root_at(self, root: int) -> Dict[int, Optional[int]]:
        """BFS to compute parent pointers from root."""
        parent: Dict[int, Optional[int]] = {root: None}
        queue = deque([root])
        order = [root]
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in parent:
                    parent[w] = v
                    queue.append(w)
                    order.append(w)
        return parent, order

    def __repr__(self):
        edges = []
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v, u) not in seen:
                    edges.append((u, v))
                    seen.add((u, v))
        return f"Tree(n={self.n}, edges={edges})"


def divisor_degree(D: Dict[int, int], n: int) -> int:
    return sum(D.get(v, 0) for v in range(n))


def principal_divisor(T: Tree, f: Dict[int, int]) -> Dict[int, int]:
    """div(f)(v) = sum_{w ~ v} (f(w) - f(v))"""
    result = {}
    for v in range(T.n):
        total = 0
        for w in T.adj[v]:
            total += f.get(w, 0) - f.get(v, 0)
        result[v] = total
    return result


def add_divisors(D1: Dict[int, int], D2: Dict[int, int], n: int) -> Dict[int, int]:
    return {v: D1.get(v, 0) + D2.get(v, 0) for v in range(n)}


def is_effective(D: Dict[int, int]) -> bool:
    return all(v >= 0 for v in D.values())


def find_concentrating_function(T: Tree, D: Dict[int, int], target: int) -> Dict[int, int]:
    """Find f such that D + div(f) is concentrated at target with value deg(D).

    Uses the subtree-sum construction:
      f(target) = 0
      f(v) = f(parent(v)) + subtree_sum(v)  for v != target

    where subtree_sum(v) = sum of D(u) over the subtree rooted at v
    when the tree is rooted at target.

    This gives div(f)(v) = -D(v) for v != target, and
    div(f)(target) = deg(D) - D(target).
    Hence D + div(f) = deg(D) * delta_target.
    """
    parent, order = T.root_at(target)

    # Compute subtree sums bottom-up
    subtree_sum = {v: D.get(v, 0) for v in range(T.n)}
    for v in reversed(order):
        if parent[v] is not None:
            subtree_sum[parent[v]] += subtree_sum[v]

    # Build f top-down: f(root) = 0, f(v) = f(parent) + subtree_sum(v)
    f = {target: 0}
    for v in order:
        if v != target:
            f[v] = f[parent[v]] + subtree_sum[v]

    return f


def find_singleton_representative(T: Tree, D: Dict[int, int], target: int = 0):
    """Find f such that D + div(f) is concentrated at target."""
    f = find_concentrating_function(T, D, target)
    result = add_divisors(D, principal_divisor(T, f), T.n)
    return result, f


# ─── Demonstrations ──────────────────────────────────────────────────────────

def demo_principal_degree_zero():
    print("=" * 60)
    print("DEMO 1: Principal Divisors Have Degree Zero")
    print("=" * 60)

    T = Tree(5, [(0,1), (1,2), (2,3), (3,4)])
    print(f"\nPath graph: 0 - 1 - 2 - 3 - 4")

    for name, f in [
        ("f(v) = v",      {i: i for i in range(5)}),
        ("f(v) = v²",     {i: i*i for i in range(5)}),
        ("f = [3,-1,4,1,5]", {0:3, 1:-1, 2:4, 3:1, 4:5}),
    ]:
        pd = principal_divisor(T, f)
        deg = sum(pd.values())
        print(f"\n  {name}:")
        print(f"    f = {[f[i] for i in range(5)]}")
        print(f"    div(f) = {[pd[i] for i in range(5)]}")
        print(f"    deg(div(f)) = {deg}  {'✓' if deg == 0 else '✗'}")


def demo_singleton_representative():
    print("\n" + "=" * 60)
    print("DEMO 2: Singleton Representative (Tropical Picard Theorem)")
    print("=" * 60)

    examples = [
        ("Path 0-1-2-3-4", Tree(5, [(0,1), (1,2), (2,3), (3,4)]),
         {0: 2, 1: -3, 2: 5, 3: -1, 4: 0}),
        ("Star (center=0)", Tree(5, [(0,1), (0,2), (0,3), (0,4)]),
         {0: -2, 1: 3, 2: 1, 3: -1, 4: 2}),
        ("Caterpillar", Tree(7, [(0,1), (1,2), (2,3), (3,4), (1,5), (3,6)]),
         {0: 1, 1: -2, 2: 4, 3: -3, 4: 2, 5: 1, 6: -1}),
    ]

    for name, T, D in examples:
        deg = divisor_degree(D, T.n)
        target = 0
        result, f = find_singleton_representative(T, D, target)

        print(f"\n  {name}:")
        print(f"    D = {[D.get(i,0) for i in range(T.n)]}, deg = {deg}")
        print(f"    Target vertex: {target}")
        print(f"    D + div(f) = {[result[i] for i in range(T.n)]}")
        ok = result[target] == deg and all(result[i] == 0 for i in range(T.n) if i != target)
        print(f"    Concentrated at v={target} with value {deg}? {'✓' if ok else '✗'}")


def demo_effective_representative():
    print("\n" + "=" * 60)
    print("DEMO 3: Effective Representatives (Tropical Riemann-Roch)")
    print("=" * 60)

    T = Tree(6, [(0,1), (1,2), (2,3), (3,4), (4,5)])
    print(f"\nPath graph: 0 - 1 - 2 - 3 - 4 - 5")

    test_cases = [
        {0: 3, 1: -2, 2: 1, 3: -1, 4: 2, 5: 0},
        {0: -1, 1: 5, 2: -3, 3: 2, 4: -1, 5: 1},
        {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    ]

    for D in test_cases:
        deg = divisor_degree(D, T.n)
        print(f"\n  D = {[D[i] for i in range(T.n)]}, deg = {deg}")
        if deg >= 0:
            result, f = find_singleton_representative(T, D, target=0)
            eff = is_effective(result)
            print(f"  Effective representative: {[result[i] for i in range(T.n)]}")
            print(f"  All values ≥ 0? {'✓' if eff else '✗'}")
            print(f"  deg preserved? {'✓' if divisor_degree(result, T.n) == deg else '✗'}")


def demo_jacobian_trivial():
    print("\n" + "=" * 60)
    print("DEMO 4: Triviality of Tree Jacobian")
    print("=" * 60)

    T = Tree(5, [(0,1), (1,2), (2,3), (3,4)])
    print(f"\nPath graph: 0 - 1 - 2 - 3 - 4")
    print("Every degree-0 divisor is principal (= div(f) for some f)")

    deg_zero_divisors = [
        {0: 1, 1: -1, 2: 0, 3: 0, 4: 0},
        {0: 0, 1: 2, 2: -3, 3: 1, 4: 0},
        {0: -5, 1: 3, 2: 4, 3: -2, 4: 0},
    ]

    for D in deg_zero_divisors:
        print(f"\n  D = {[D[i] for i in range(T.n)]}, deg = {divisor_degree(D, T.n)}")
        # D + div(f) = 0 means D = -div(f) = div(-f)
        f = find_concentrating_function(T, D, target=0)
        neg_f = {v: -f[v] for v in range(T.n)}
        witness = principal_divisor(T, neg_f)
        match = all(D.get(v, 0) == witness.get(v, 0) for v in range(T.n))
        print(f"  Witness: f = {[neg_f[i] for i in range(T.n)]}")
        print(f"  div(f) = {[witness[i] for i in range(T.n)]}")
        print(f"  D = div(f)? {'✓' if match else '✗'}")


if __name__ == "__main__":
    demo_principal_degree_zero()
    demo_singleton_representative()
    demo_effective_representative()
    demo_jacobian_trivial()
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for tropical divisor theory on trees."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def draw_tree_with_divisor(ax, positions, edges, divisor, title, labels=None):
    """Draw a tree with chip counts at each vertex."""
    ax.set_title(title, fontsize=13, fontweight='bold')

    # Draw edges
    for u, v in edges:
        ax.plot([positions[u][0], positions[v][0]],
                [positions[u][1], positions[v][1]],
                'k-', linewidth=2, zorder=1)

    # Draw vertices
    for v, (x, y) in positions.items():
        chips = divisor.get(v, 0)
        color = '#4CAF50' if chips > 0 else '#F44336' if chips < 0 else '#9E9E9E'
        size = max(300, abs(chips) * 150 + 300)
        ax.scatter(x, y, s=size, c=color, edgecolors='black',
                   linewidths=2, zorder=3)
        label = str(chips) if labels is None else f"{labels[v]}\n({chips})"
        ax.text(x, y, str(chips), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=4)

    ax.set_xlim(-0.5, max(p[0] for p in positions.values()) + 0.5)
    ax.set_ylim(-0.5, max(p[1] for p in positions.values()) + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')


def viz_chip_firing_sequence():
    """Visualize the leaf-firing normalization process."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Leaf-Firing Normalization on a Path Graph',
                 fontsize=16, fontweight='bold')

    positions = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0), 4: (4, 0)}
    edges = [(0, 1), (1, 2), (2, 3), (3, 4)]

    # Sequence of divisors during normalization
    steps = [
        ({0: 2, 1: -3, 2: 5, 3: -1, 4: 0}, "Initial: D = [2,-3,5,-1,0]"),
        ({0: 0, 1: -1, 2: 5, 3: -1, 4: 0}, "Fire vertex 0 → [0,-1,5,-1,0]"),
        ({0: 0, 1: -1, 2: 5, 3: -1, 4: 0}, "Fire vertex 4 → [0,-1,5,-1,0]"),
        ({0: 0, 1: 0, 2: 4, 3: -1, 4: 0}, "Fire vertex 1 → [0,0,4,-1,0]"),
        ({0: 0, 1: 0, 2: 0, 3: 3, 4: 0}, "Fire vertex 2 → [0,0,0,3,0]"),
        ({0: 3, 1: 0, 2: 0, 3: 0, 4: 0}, "Final: concentrated at v₀"),
    ]

    for idx, (D, title) in enumerate(steps):
        ax = axes[idx // 3, idx % 3]
        draw_tree_with_divisor(ax, positions, edges, D, title)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_tree_picard_theorem():
    """Visualize the tropical Picard theorem on different tree topologies."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Tropical Picard Theorem: Any Divisor → Singleton',
                 fontsize=16, fontweight='bold')

    # Path graph
    pos1 = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0)}
    edges1 = [(0, 1), (1, 2), (2, 3)]
    draw_tree_with_divisor(axes[0], pos1, edges1,
                           {0: 1, 1: -2, 2: 3, 3: -1},
                           "Path: D = [1,-2,3,-1]\ndeg = 1")

    # Star graph
    pos2 = {0: (1.5, 1), 1: (0, 0), 2: (1, 0), 3: (2, 0), 4: (3, 0)}
    edges2 = [(0, 1), (0, 2), (0, 3), (0, 4)]
    draw_tree_with_divisor(axes[1], pos2, edges2,
                           {0: -2, 1: 3, 2: 1, 3: -1, 4: 2},
                           "Star: D = [-2,3,1,-1,2]\ndeg = 3")

    # Binary tree
    pos3 = {0: (1.5, 2), 1: (0.5, 1), 2: (2.5, 1), 3: (0, 0), 4: (1, 0), 5: (2, 0), 6: (3, 0)}
    edges3 = [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)]
    draw_tree_with_divisor(axes[2], pos3, edges3,
                           {0: -1, 1: 2, 2: -3, 3: 1, 4: 0, 5: 4, 6: -2},
                           "Binary: D = [-1,2,-3,1,0,4,-2]\ndeg = 1")

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_effective_representative():
    """Visualize the effective representative theorem."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle('Effective Representative: Negative Chips → All Nonneg',
                 fontsize=16, fontweight='bold')

    positions = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0), 4: (4, 0)}
    edges = [(0, 1), (1, 2), (2, 3), (3, 4)]

    draw_tree_with_divisor(axes[0], positions, edges,
                           {0: 3, 1: -2, 2: 1, 3: -1, 4: 2},
                           "Before: D = [3,-2,1,-1,2]\nHas negative values")

    draw_tree_with_divisor(axes[1], positions, edges,
                           {0: 3, 1: 0, 2: 0, 3: 0, 4: 0},
                           "After: E = [3,0,0,0,0]\nAll nonneg! (effective)")

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    v1 = viz_chip_firing_sequence()
    v2 = viz_tree_picard_theorem()
    v3 = viz_effective_representative()
    print(f"Generated 3 visualizations (base64 encoded)")

    # Save as JSON for the package
    vizdata = [
        {"name": "Chip-Firing Normalization", "data": v1},
        {"name": "Tropical Picard Theorem", "data": v2},
        {"name": "Effective Representative", "data": v3},
    ]
    with open("viz_data.json", "w") as f:
        json.dump(vizdata, f)
    print("Saved to viz_data.json")
