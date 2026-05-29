"""
Applications: Emotional Diversity in Social Networks

Real-world applications of chromatic polynomial theory to social network analysis.
"""

import random
import math
from typing import List, Tuple, Dict, Set


# ─── Self-contained graph utilities ──────────────────────────────────────

def make_graph(n: int, edges: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    """Create adjacency dict from edge list."""
    adj = {i: set() for i in range(n)}
    for u, v in edges:
        if u != v:
            adj[u].add(v)
            adj[v].add(u)
    return adj


def greedy_coloring(n: int, adj: Dict[int, Set[int]]) -> List[int]:
    """Greedy graph coloring. Returns color assignment."""
    coloring = [-1] * n
    for v in range(n):
        used = {coloring[u] for u in adj[v] if coloring[u] >= 0}
        color = 0
        while color in used:
            color += 1
        coloring[v] = color
    return coloring


def chromatic_poly_deletion_contraction(n: int, edges: List[Tuple[int, int]], k: int) -> int:
    """Compute χ(G, k) via deletion-contraction (for small graphs)."""
    if not edges:
        return k ** n
    u, v = edges[0]
    rest = edges[1:]
    # Deletion
    del_count = chromatic_poly_deletion_contraction(n, rest, k)
    # Contraction: merge v into u
    new_edges = set()
    for a, b in rest:
        a2 = u if a == v else (a - 1 if a > v else a)
        b2 = u if b == v else (b - 1 if b > v else b)
        if a2 != b2:
            new_edges.add((min(a2, b2), max(a2, b2)))
    con_count = chromatic_poly_deletion_contraction(n - 1, list(new_edges), k)
    return del_count - con_count


def max_degree(n: int, adj: Dict[int, Set[int]]) -> int:
    return max(len(adj[v]) for v in range(n)) if n > 0 else 0


# ─── Application 1: Classroom Emotion Assignment ────────────────────────

def classroom_application():
    """
    Application: Assigning emotional roles in a classroom activity.
    
    Problem: A teacher wants to assign emotions to students for a role-playing
    exercise. Friends should not share the same emotion to maximize empathy.
    The friendship graph determines the constraints.
    """
    print("=" * 60)
    print("APPLICATION 1: Classroom Emotion Assignment")
    print("=" * 60)
    print()

    # Small classroom: 8 students with friendship edges
    n = 8
    friendships = [
        (0, 1), (0, 2), (1, 2), (1, 3),
        (2, 4), (3, 4), (3, 5), (4, 5),
        (5, 6), (6, 7), (5, 7)
    ]
    adj = make_graph(n, friendships)

    emotions = ["Happiness", "Sadness", "Anger", "Fear", "Disgust", "Surprise"]
    coloring = greedy_coloring(n, adj)
    num_needed = max(coloring) + 1
    delta = max_degree(n, adj)

    print(f"Classroom: {n} students, {len(friendships)} friendship pairs")
    print(f"Max friendships per student (Δ): {delta}")
    print(f"Greedy coloring bound (Δ+1): {delta + 1}")
    print(f"Colors needed by greedy: {num_needed}")
    print(f"Emotional chromatic number: {max(num_needed, 3)}")
    print()
    print("Emotion assignment:")
    for i in range(n):
        emotion = emotions[coloring[i]] if coloring[i] < len(emotions) else f"Emotion_{coloring[i]+1}"
        friends = sorted(adj[i])
        print(f"  Student {i} → {emotion:>10}  (friends: {friends})")

    # Verify no conflicts
    conflicts = 0
    for u, v in friendships:
        if coloring[u] == coloring[v]:
            conflicts += 1
    print(f"\nConflicts: {conflicts} (should be 0)")

    # Count colorings with k=6
    if n <= 10:
        count = chromatic_poly_deletion_contraction(n, friendships, 6)
        diversity = count / (6 ** n)
        print(f"χ(G, 6) = {count} valid 6-emotion assignments")
        print(f"Emotional diversity = {diversity:.6f}")


# ─── Application 2: Social Network Emotion Diversity ────────────────────

def social_network_application():
    """
    Application: Measuring emotional diversity in synthetic social networks.
    
    Generate random social networks (Erdős-Rényi model) and compute
    emotional diversity metrics.
    """
    print()
    print("=" * 60)
    print("APPLICATION 2: Social Network Emotional Diversity")
    print("=" * 60)
    print()

    random.seed(42)

    print(f"{'Network':>15} | {'|V|':>4} | {'|E|':>4} | {'Δ':>3} | {'χ_E':>4} | {'Diversity':>10}")
    print("-" * 60)

    for trial in range(8):
        n = random.randint(5, 12)
        p = random.uniform(0.15, 0.5)
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    edges.append((i, j))

        adj = make_graph(n, edges)
        delta = max_degree(n, adj)
        coloring = greedy_coloring(n, adj)
        num_colors = max(coloring) + 1 if coloring else 0
        ecn = max(num_colors, 3)

        if n <= 10 and len(edges) <= 20:
            count = chromatic_poly_deletion_contraction(n, edges, 6)
            div = count / (6 ** n) if n > 0 else 1.0
        else:
            div = float('nan')

        name = f"G({n},{len(edges)})"
        print(f"{name:>15} | {n:>4} | {len(edges):>4} | {delta:>3} | {ecn:>4} | {div:>10.6f}")


# ─── Application 3: Team Emotion Balance ────────────────────────────────

def team_balance_application():
    """
    Application: Balancing emotions in project teams.
    
    Given a conflict graph (people who disagree), assign emotional
    perspectives to maximize diversity while respecting conflicts.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Team Emotion Balance")
    print("=" * 60)
    print()

    # 6 team members, conflict pairs
    n = 6
    conflicts = [(0, 1), (0, 3), (1, 2), (2, 3), (3, 4), (4, 5)]
    adj = make_graph(n, conflicts)

    roles = ["Optimist", "Analyst", "Devil's Advocate",
             "Empath", "Strategist", "Visionary"]

    coloring = greedy_coloring(n, adj)
    print(f"Team: {n} members, {len(conflicts)} conflict pairs")
    print()
    print("Role assignment (no conflicting pair shares a role):")
    for i in range(n):
        role = roles[coloring[i]] if coloring[i] < len(roles) else f"Role_{coloring[i]+1}"
        opponents = sorted(adj[i])
        print(f"  Member {i} → {role:>20}  (conflicts with: {opponents})")

    count = chromatic_poly_deletion_contraction(n, conflicts, 6)
    print(f"\nTotal valid 6-role assignments: {count}")
    print(f"Diversity index: {count / (6**n):.6f}")


# ─── Application 4: The Six Emotions Theorem in Practice ────────────────

def six_emotions_theorem_demo():
    """
    Demonstrates the Six Emotions Theorem: any network with max degree ≤ 5
    always admits a valid 6-emotion assignment.
    """
    print()
    print("=" * 60)
    print("APPLICATION 4: The Six Emotions Theorem")
    print("=" * 60)
    print()
    print("Theorem: If every person has ≤ 5 friends, then 6 emotions suffice.")
    print()

    random.seed(123)

    # Generate sparse networks and verify
    successes = 0
    total = 20
    for trial in range(total):
        n = random.randint(10, 30)
        edges = []
        adj = make_graph(n, [])
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < 3.0 / n and len(adj[i]) < 5 and len(adj[j]) < 5:
                    edges.append((i, j))
                    adj[i].add(j)
                    adj[j].add(i)

        coloring = greedy_coloring(n, adj)
        num_colors = max(coloring) + 1 if coloring else 0
        delta = max_degree(n, adj)

        if delta <= 5 and num_colors <= 6:
            successes += 1

    print(f"Generated {total} random sparse networks (Δ ≤ 5)")
    print(f"All colored with ≤ 6 emotions: {successes}/{total}")
    print(f"Theorem guarantee: 100% (proven formally)")


if __name__ == "__main__":
    classroom_application()
    social_network_application()
    team_balance_application()
    six_emotions_theorem_demo()


"""
Demo: Graph Coloring with Emotions — The Chromatic Polynomial Meets Psychology

Demonstrates the core theorems about chromatic polynomials and emotional
chromatic numbers with concrete numerical examples.
"""

import itertools
from math import factorial, comb, perm


def chromatic_count_complete(n: int, k: int) -> int:
    """Number of proper k-colorings of K_n = k^(n) (falling factorial)."""
    if k < n:
        return 0
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_count_cycle(n: int, k: int) -> int:
    """Number of proper k-colorings of cycle C_n.
    Formula: (k-1)^n + (-1)^n * (k-1)
    """
    if n < 3:
        raise ValueError("Cycle requires n >= 3")
    return (k - 1) ** n + ((-1) ** n) * (k - 1)


def chromatic_count_path(n: int, k: int) -> int:
    """Number of proper k-colorings of path P_n.
    Formula: k * (k-1)^(n-1)
    """
    if n < 1:
        return 1
    return k * (k - 1) ** (n - 1)


def chromatic_count_empty(n: int, k: int) -> int:
    """Number of proper k-colorings of empty graph on n vertices = k^n."""
    return k ** n


def emotional_chromatic_number_complete(n: int) -> int:
    """Emotional chromatic number of K_n = max(n, 3)."""
    return max(n, 3)


def emotional_diversity(chromatic_count: int, k: int, n: int) -> float:
    """Emotional diversity = χ(G, k) / k^n."""
    if k == 0:
        return 0.0
    return chromatic_count / (k ** n)


def brute_force_chromatic_count(adj_matrix: list, k: int) -> int:
    """Brute-force count proper k-colorings of a graph given by adjacency matrix."""
    n = len(adj_matrix)
    count = 0
    for coloring in itertools.product(range(k), repeat=n):
        valid = True
        for i in range(n):
            for j in range(i + 1, n):
                if adj_matrix[i][j] and coloring[i] == coloring[j]:
                    valid = False
                    break
            if not valid:
                break
        if valid:
            count += 1
    return count


# ─── Demo 1: Complete Graph Chromatic Polynomial ────────────────────────
print("=" * 60)
print("DEMO 1: Complete Graph K_n Chromatic Polynomial")
print("=" * 60)
print()
print("Theorem: χ(K_n, k) = k(k-1)(k-2)...(k-n+1) = k^(n)")
print()

for n in range(1, 7):
    row = f"K_{n}: "
    for k in range(1, 8):
        row += f"χ({k})={chromatic_count_complete(n, k):>5}  "
    print(row)

print()
print("Verification with brute force for K_4:")
K4 = [[0, 1, 1, 1],
      [1, 0, 1, 1],
      [1, 1, 0, 1],
      [1, 1, 1, 0]]
for k in range(1, 6):
    bf = brute_force_chromatic_count(K4, k)
    formula = chromatic_count_complete(4, k)
    print(f"  χ(K_4, {k}): brute_force={bf}, formula={formula}, match={bf == formula}")

# ─── Demo 2: Emotional Chromatic Number ─────────────────────────────────
print()
print("=" * 60)
print("DEMO 2: Emotional Chromatic Number χ_E(K_n)")
print("=" * 60)
print()
print("Definition: χ_E(G) = min{k ≥ 3 : G is k-colorable}")
print()

for n in range(1, 10):
    ecn = emotional_chromatic_number_complete(n)
    print(f"  χ_E(K_{n}) = max({n}, 3) = {ecn}")

# ─── Demo 3: Emotional Diversity ────────────────────────────────────────
print()
print("=" * 60)
print("DEMO 3: Emotional Diversity Index")
print("=" * 60)
print()
print("Diversity = χ(G, k) / k^n  (fraction of valid assignments)")
print()

k = 6  # Ekman's 6 basic emotions
print(f"With k={k} emotions (Ekman's basic emotions):")
print()
for n in range(1, 8):
    cc = chromatic_count_complete(n, k)
    div = emotional_diversity(cc, k, n)
    print(f"  K_{n}: χ(K_{n}, {k}) = {cc:>7}, diversity = {div:.4f}")

print()
print("Empty graph (no constraints):")
for n in range(1, 8):
    cc = chromatic_count_empty(n, k)
    div = emotional_diversity(cc, k, n)
    print(f"  E_{n}: χ(E_{n}, {k}) = {cc:>7}, diversity = {div:.4f}")

# ─── Demo 4: Cycle Graphs ───────────────────────────────────────────────
print()
print("=" * 60)
print("DEMO 4: Cycle Graph Chromatic Polynomial")
print("=" * 60)
print()
print("Formula: χ(C_n, k) = (k-1)^n + (-1)^n(k-1)")
print()

for n in range(3, 10):
    parity = "even" if n % 2 == 0 else "odd"
    row = f"C_{n} ({parity:>4}): "
    for k in range(2, 8):
        row += f"χ({k})={chromatic_count_cycle(n, k):>5}  "
    print(row)

# ─── Demo 5: Conjecture Test ────────────────────────────────────────────
print()
print("=" * 60)
print("DEMO 5: Conjecture — χ(G, 3) ≥ 3 for connected G, |V| ≥ 3")
print("=" * 60)
print()

# Test on all small connected graphs (complete, cycle, path, star)
test_cases = [
    ("K_3", [[0,1,1],[1,0,1],[1,1,0]]),
    ("K_4", [[0,1,1,1],[1,0,1,1],[1,1,0,1],[1,1,1,0]]),
    ("P_3", [[0,1,0],[1,0,1],[0,1,0]]),
    ("P_4", [[0,1,0,0],[1,0,1,0],[0,1,0,1],[0,0,1,0]]),
    ("C_4", [[0,1,0,1],[1,0,1,0],[0,1,0,1],[1,0,1,0]]),
    ("C_5", [[0,1,0,0,1],[1,0,1,0,0],[0,1,0,1,0],[0,0,1,0,1],[1,0,0,1,0]]),
    ("Star_4", [[0,1,1,1],[1,0,0,0],[1,0,0,0],[1,0,0,0]]),
]

for name, adj in test_cases:
    count = brute_force_chromatic_count(adj, 3)
    print(f"  χ({name}, 3) = {count:>4}  ≥ 3? {count >= 3}")

# ─── Demo 6: Information-Theoretic Interpretation ────────────────────────
print()
print("=" * 60)
print("DEMO 6: Information-Theoretic Channel Capacity")
print("=" * 60)
print()

import math

k = 6
print(f"Emotional channel with {k} emotions:")
print(f"{'Graph':>8} | {'Colorings':>10} | {'log2(χ)':>8} | {'bits/vertex':>12}")
print("-" * 50)

for n in range(2, 8):
    cc = chromatic_count_complete(n, k)
    if cc > 0:
        log2 = math.log2(cc)
        bpv = log2 / n
    else:
        log2 = float('-inf')
        bpv = 0
    print(f"K_{n:>5} | {cc:>10} | {log2:>8.2f} | {bpv:>12.4f}")

print()
print("Unconstrained (no graph):")
for n in range(2, 8):
    cc = k ** n
    log2 = math.log2(cc)
    bpv = log2 / n
    print(f"E_{n:>5} | {cc:>10} | {log2:>8.2f} | {bpv:>12.4f}")

print()
print("The complete graph reduces per-vertex capacity as n grows,")
print("showing that dense social networks constrain emotional diversity.")


"""
Visualization: Chromatic Polynomial Landscape

Plots the chromatic polynomial χ(G, k) as a function of k for several
graph families (complete, cycle, path, empty), revealing how graph
structure constrains the number of valid emotion assignments.
"""

import matplotlib.pyplot as plt
import numpy as np

def falling_factorial(k, n):
    """k^(n) = k(k-1)...(k-n+1)"""
    result = 1
    for i in range(n):
        result *= max(k - i, 0)
    return result

def chi_complete(n, k):
    return falling_factorial(k, n)

def chi_cycle(n, k):
    if n < 3:
        return 0
    return (k - 1)**n + ((-1)**n) * (k - 1)

def chi_path(n, k):
    if n < 1:
        return 1
    return k * (k - 1)**(n - 1)

def chi_empty(n, k):
    return k**n

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

k_vals = np.arange(1, 9)

# Plot 1: Complete graphs
ax = axes[0, 0]
for n in [2, 3, 4, 5, 6]:
    y = [chi_complete(n, k) for k in k_vals]
    ax.plot(k_vals, y, 'o-', label=f'$K_{{{n}}}$', linewidth=2, markersize=6)
ax.set_xlabel('Number of colors k', fontsize=12)
ax.set_ylabel('χ(G, k)', fontsize=12)
ax.set_title('Complete Graphs: χ(K_n, k) = k⁽ⁿ⁾', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.set_ylim(0.5, 50000)
ax.grid(True, alpha=0.3)
ax.axvline(x=6, color='red', linestyle='--', alpha=0.5, label='k=6 (Ekman)')

# Plot 2: Cycle graphs
ax = axes[0, 1]
for n in [3, 4, 5, 6, 7, 8]:
    y = [chi_cycle(n, k) for k in k_vals]
    parity = "even" if n % 2 == 0 else "odd"
    ax.plot(k_vals, y, 'o-', label=f'$C_{{{n}}}$ ({parity})', linewidth=2, markersize=6)
ax.set_xlabel('Number of colors k', fontsize=12)
ax.set_ylabel('χ(G, k)', fontsize=12)
ax.set_title('Cycle Graphs: χ(C_n, k) = (k-1)ⁿ + (-1)ⁿ(k-1)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 3: Emotional diversity comparison
ax = axes[1, 0]
n = 5
for graph_name, chi_func in [('Empty $E_5$', chi_empty),
                               ('Path $P_5$', chi_path),
                               ('Cycle $C_5$', chi_cycle),
                               ('Complete $K_5$', chi_complete)]:
    diversity = []
    for k in range(1, 9):
        c = chi_func(n, k)
        d = c / (k**n) if k > 0 else 0
        diversity.append(d)
    ax.plot(range(1, 9), diversity, 's-', label=graph_name, linewidth=2, markersize=7)
ax.set_xlabel('Number of emotions k', fontsize=12)
ax.set_ylabel('Emotional Diversity D(G, k)', fontsize=12)
ax.set_title('Emotional Diversity: χ(G,k)/k^n for n=5 vertices', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(-0.05, 1.05)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.grid(True, alpha=0.3)

# Plot 4: Channel capacity comparison
ax = axes[1, 1]
k = 6
n_vals = range(2, 9)
for graph_name, chi_func in [('Empty', chi_empty),
                               ('Path', chi_path),
                               ('Cycle', chi_cycle),
                               ('Complete', chi_complete)]:
    capacity = []
    for n in n_vals:
        c = chi_func(n, k)
        if c > 0:
            cap = np.log2(c) / n
        else:
            cap = 0
        capacity.append(cap)
    ax.plot(list(n_vals), capacity, 'D-', label=graph_name, linewidth=2, markersize=6)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Bits per vertex', fontsize=12)
ax.set_title(f'Information Capacity with k={k} Emotions', fontsize=13)
ax.legend(fontsize=10)
ax.axhline(y=np.log2(6), color='gray', linestyle=':', alpha=0.5, label='Max (log₂6)')
ax.grid(True, alpha=0.3)

plt.suptitle('Chromatic Polynomial Landscape: Graph Structure Constrains Emotional Diversity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('chromatic_landscape.png', dpi=150, bbox_inches='tight')
print("Saved chromatic_landscape.png")


"""
Visualization: Emotional Diversity Heatmap

Shows the emotional diversity index D(K_n, k) = k^(n) / k^n as a heatmap,
revealing how the interaction between group size and emotion count
determines the fraction of valid emotion assignments.
"""

import matplotlib.pyplot as plt
import numpy as np

def falling_factorial(k, n):
    """k^(n) = k(k-1)...(k-n+1)"""
    result = 1.0
    for i in range(n):
        result *= max(k - i, 0)
    return result

n_max = 10
k_max = 12

diversity = np.zeros((n_max, k_max))

for n in range(1, n_max + 1):
    for k in range(1, k_max + 1):
        ff = falling_factorial(k, n)
        total = k ** n
        diversity[n - 1, k - 1] = ff / total if total > 0 else 0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap of diversity
im = ax1.imshow(diversity, aspect='auto', cmap='RdYlGn', origin='lower',
                vmin=0, vmax=1, interpolation='nearest')
ax1.set_xlabel('Number of emotions k', fontsize=13)
ax1.set_ylabel('Group size n (complete graph K_n)', fontsize=13)
ax1.set_title('Emotional Diversity of Complete Groups\nD(K_n, k) = k⁽ⁿ⁾/kⁿ', fontsize=14)
ax1.set_xticks(range(k_max))
ax1.set_xticklabels(range(1, k_max + 1))
ax1.set_yticks(range(n_max))
ax1.set_yticklabels(range(1, n_max + 1))

# Annotate cells
for n in range(n_max):
    for k in range(k_max):
        val = diversity[n, k]
        color = 'white' if val < 0.3 or val > 0.85 else 'black'
        ax1.text(k, n, f'{val:.2f}', ha='center', va='center',
                 fontsize=7, color=color, fontweight='bold')

plt.colorbar(im, ax=ax1, label='Emotional Diversity Index', shrink=0.8)

# Mark the k=6 column (Ekman's emotions)
ax1.axvline(x=4.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.axvline(x=5.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.text(5, n_max - 0.3, 'k=6\n(Ekman)', ha='center', va='top',
         color='red', fontsize=9, fontweight='bold')

# Plot 2: Diversity curves
for n in [2, 3, 4, 5, 6, 8, 10]:
    k_range = np.arange(1, k_max + 1)
    div = [falling_factorial(k, n) / (k ** n) if k > 0 else 0 for k in k_range]
    ax2.plot(k_range, div, 'o-', label=f'n={n}', linewidth=2, markersize=5)

ax2.set_xlabel('Number of emotions k', fontsize=13)
ax2.set_ylabel('Emotional Diversity D(K_n, k)', fontsize=13)
ax2.set_title('Diversity vs. Emotion Count\nfor Complete Social Groups', fontsize=14)
ax2.legend(title='Group size', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)
ax2.axvline(x=6, color='red', linestyle='--', alpha=0.5)
ax2.text(6.2, 0.95, 'Ekman\'s 6', color='red', fontsize=10)
ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.3)

plt.tight_layout()
plt.savefig('diversity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved diversity_heatmap.png")


"""
Visualization: Greedy Coloring in Action

Illustrates the greedy coloring algorithm on a small social network,
showing step-by-step how emotions are assigned and how the degree
bound guarantees success with Δ+1 emotions.
"""

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

# Define a small social network
n = 8
edges = [(0,1), (0,2), (1,2), (1,3), (2,4), (3,4), (3,5), (4,5), (5,6), (6,7), (5,7)]
adj = {i: set() for i in range(n)}
for u, v in edges:
    adj[u].add(v)
    adj[v].add(u)

# Positions for visualization (circular layout)
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
positions = {i: (1.5*np.cos(a), 1.5*np.sin(a)) for i, a in enumerate(angles)}

# Greedy coloring
def greedy_step_by_step(n, adj):
    coloring = [-1] * n
    steps = []
    for v in range(n):
        used = {coloring[u] for u in adj[v] if coloring[u] >= 0}
        color = 0
        while color in used:
            color += 1
        coloring[v] = color
        steps.append((v, color, set(used), coloring[:]))
    return steps

steps = greedy_step_by_step(n, adj)

# Color palette (emotions)
emotion_colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD']
emotion_names = ['Happiness', 'Sadness', 'Anger', 'Fear', 'Disgust', 'Surprise']

fig, axes = plt.subplots(2, 4, figsize=(20, 10))
axes = axes.flatten()

for step_idx, (v, color, used, current_coloring) in enumerate(steps):
    ax = axes[step_idx]

    # Draw edges
    for u1, v1 in edges:
        x = [positions[u1][0], positions[v1][0]]
        y = [positions[u1][1], positions[v1][1]]
        ax.plot(x, y, 'gray', linewidth=1, alpha=0.4, zorder=1)

    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        c = current_coloring[i]
        if c >= 0:
            fc = emotion_colors[c]
            alpha = 1.0
        else:
            fc = 'lightgray'
            alpha = 0.5

        if i == v:
            # Highlight current vertex
            circle = plt.Circle((x, y), 0.22, facecolor=fc, edgecolor='black',
                                linewidth=3, zorder=3, alpha=alpha)
        else:
            circle = plt.Circle((x, y), 0.18, facecolor=fc, edgecolor='gray',
                                linewidth=1.5, zorder=2, alpha=alpha)
        ax.add_patch(circle)
        ax.text(x, y, str(i), ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=4)

    # Title
    forbidden = ', '.join(emotion_names[c] for c in sorted(used) if c < len(emotion_names))
    assigned = emotion_names[color] if color < len(emotion_names) else f'Color {color}'
    ax.set_title(f'Step {step_idx+1}: Vertex {v}\n'
                 f'Forbidden: {{{forbidden}}}\n'
                 f'Assigned: {assigned}',
                 fontsize=9, fontweight='bold')

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.axis('off')

# Add legend
legend_patches = [mpatches.Patch(facecolor=emotion_colors[i], edgecolor='gray',
                                  label=emotion_names[i])
                  for i in range(min(max(s[1] for s in steps) + 1, len(emotion_names)))]
legend_patches.append(mpatches.Patch(facecolor='lightgray', edgecolor='gray',
                                      label='Uncolored'))

fig.legend(handles=legend_patches, loc='lower center', ncol=len(legend_patches),
           fontsize=11, frameon=True, fancybox=True, shadow=True)

max_deg = max(len(adj[v]) for v in range(n))
num_colors = max(s[1] for s in steps) + 1

plt.suptitle(f'Greedy Coloring Algorithm on Social Network\n'
             f'Δ = {max_deg}, Colors used = {num_colors} ≤ Δ+1 = {max_deg+1} '
             f'(Formally proved: colorable_of_degree_le)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('greedy_coloring.png', dpi=150, bbox_inches='tight')
print("Saved greedy_coloring.png")
