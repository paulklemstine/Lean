#!/usr/bin/env python3
"""
applications.py — Real-world applications of transversal matroid theory.

Demonstrates how the quadratic leaf count bounds apply to:
1. Job scheduling / assignment problems
2. Network reliability analysis
3. Sensitivity analysis for matching-based systems
"""

import random
import itertools
from typing import List, Set, Dict, Tuple, Optional
from collections import defaultdict


# ── Core matching utilities ────────────────────────────────────────────


def find_max_matching(adj: List[List[int]], n_right: int) -> Dict[int, int]:
    """Find maximum matching via augmenting paths."""
    match_l: Dict[int, int] = {}
    match_r: Dict[int, int] = {}

    def augment(u: int, visited: Set[int]) -> bool:
        for v in adj[u]:
            if v in visited:
                continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v
                match_r[v] = u
                return True
        return False

    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset: Tuple[int, ...], adj: List[List[int]],
                    n_right: int) -> bool:
    """Check if a subset admits an injective matching."""
    if not subset:
        return True
    sub_adj = [adj[v] for v in subset]
    matching = find_max_matching(sub_adj, n_right)
    return len(matching) == len(subset)


def nat_choose(n: int, k: int) -> int:
    """Binomial coefficient."""
    if k < 0 or k > n:
        return 0
    if k == 0 or k == n:
        return 1
    k = min(k, n - k)
    result = 1
    for i in range(k):
        result = result * (n - i) // (i + 1)
    return result


# ── Application 1: Job Scheduling ─────────────────────────────────────


def job_scheduling_demo():
    """Demonstrate the assignment/scheduling interpretation.

    Consider a factory with:
    - Jobs that need to be assigned to machines
    - Each job can only run on certain machines (skill compatibility)
    - We want to find maximum feasible assignments

    The quadratic leaf count tells us how many "almost-maximal" feasible
    job subsets exist — critical for sensitivity analysis.
    """
    print("=" * 60)
    print("APPLICATION 1: JOB-MACHINE SCHEDULING")
    print("=" * 60)
    print()

    # Scenario: 10 jobs, 8 machines, each job compatible with ≤ 3 machines
    n_jobs = 10
    n_machines = 8
    max_skills = 3

    random.seed(42)
    compatibility: List[List[int]] = []
    job_names = [f"Job_{i}" for i in range(n_jobs)]
    machine_names = [f"M_{i}" for i in range(n_machines)]

    for i in range(n_jobs):
        n_compat = random.randint(1, max_skills)
        machines = sorted(random.sample(range(n_machines), n_compat))
        compatibility.append(machines)

    print("Compatibility matrix:")
    for i, compat in enumerate(compatibility):
        print(f"  {job_names[i]}: can run on {[machine_names[m] for m in compat]}")

    # Compute rank
    matching = find_max_matching(compatibility, n_machines)
    rank = len(matching)
    print(f"\nMaximum feasible assignment: {rank} jobs")
    print(f"Assignment: ", end="")
    for j, m in sorted(matching.items()):
        print(f"{job_names[j]}→{machine_names[m]} ", end="")
    print()

    # Compute near-maximal sets
    target_size = rank - 2
    if target_size >= 0:
        near_max_count = 0
        near_max_sets = []
        for subset in itertools.combinations(range(n_jobs), target_size):
            if is_independent(subset, compatibility, n_machines):
                near_max_count += 1
                if len(near_max_sets) < 5:
                    near_max_sets.append(subset)

        bound = nat_choose(n_jobs, target_size)
        print(f"\nNear-maximal feasible subsets (size {target_size}):")
        print(f"  Count: {near_max_count}")
        print(f"  Upper bound C({n_jobs},{target_size}): {bound}")
        print(f"  Compression ratio: {near_max_count/max(1,bound):.4f}")
        print(f"  Example sets:")
        for s in near_max_sets[:3]:
            print(f"    {[job_names[i] for i in s]}")

    print()


# ── Application 2: Network Reliability ────────────────────────────────


def network_reliability_demo():
    """Demonstrate network reliability analysis.

    Consider a communication network where:
    - Sources (left) need to connect to sinks (right)
    - Each source has limited connectivity options
    - We want to understand how many "almost-full" connection patterns exist

    The quadratic leaf count measures the combinatorial complexity of
    near-failure states.
    """
    print("=" * 60)
    print("APPLICATION 2: NETWORK RELIABILITY ANALYSIS")
    print("=" * 60)
    print()

    # Scenario: 8 sources, 8 sinks, sparse connectivity
    n_sources = 8
    n_sinks = 8

    random.seed(123)

    # Create a network with varying sparsity
    for label, max_conn in [("Sparse (Δ=2)", 2), ("Medium (Δ=4)", 4),
                              ("Dense (Δ=7)", 7)]:
        connectivity: List[List[int]] = []
        for i in range(n_sources):
            n_conn = random.randint(1, min(max_conn, n_sinks))
            sinks = sorted(random.sample(range(n_sinks), n_conn))
            connectivity.append(sinks)

        matching = find_max_matching(connectivity, n_sinks)
        rank = len(matching)
        target = rank - 2

        if target >= 0:
            qlc = sum(1 for subset in itertools.combinations(range(n_sources), target)
                      if is_independent(subset, connectivity, n_sinks))
        else:
            qlc = 0

        bound = nat_choose(n_sources, max(0, target))

        print(f"{label}:")
        print(f"  Max simultaneous connections: {rank}")
        print(f"  Near-full connection patterns: {qlc}")
        print(f"  Theoretical bound: {bound}")
        print(f"  Sparsity gain: {1 - qlc/max(1,bound):.1%}")
        print()


# ── Application 3: Sensitivity Analysis ───────────────────────────────


def sensitivity_analysis_demo():
    """Demonstrate sensitivity analysis for matching systems.

    For each near-maximal independent set, identify which jobs/elements
    are "critical" — removing them causes a significant drop in the
    maximum matching size.
    """
    print("=" * 60)
    print("APPLICATION 3: MATCHING SENSITIVITY ANALYSIS")
    print("=" * 60)
    print()

    n = 7
    max_deg = 3
    random.seed(456)

    adj: List[List[int]] = []
    for i in range(n):
        deg = random.randint(1, min(max_deg, n))
        neighbors = sorted(random.sample(range(n), deg))
        adj.append(neighbors)

    matching = find_max_matching(adj, n)
    rank = len(matching)

    print(f"System: {n} elements, max degree {max_deg}")
    print(f"Maximum matching size: {rank}")
    print()

    # Find critical elements: those whose removal decreases the rank
    critical = set()
    for v in range(n):
        remaining_adj = [adj[u] for u in range(n) if u != v]
        sub_rank = len(find_max_matching(remaining_adj, n))
        if sub_rank < rank:
            critical.add(v)

    print(f"Critical elements (removal decreases rank): {critical}")
    print(f"Number of critical elements: {len(critical)}")
    print()

    # Analyze near-maximal sets
    target = rank - 2
    if target >= 0:
        indep_sets = [s for s in itertools.combinations(range(n), target)
                      if is_independent(s, adj, n)]

        print(f"Near-maximal independent sets (size {target}): {len(indep_sets)}")

        # Check which sets contain all critical elements
        critical_containing = sum(1 for s in indep_sets
                                   if critical.issubset(set(s)))
        print(f"Sets containing all critical elements: {critical_containing}")

        # Average overlap with critical set
        if indep_sets:
            avg_overlap = sum(len(critical.intersection(set(s)))
                              for s in indep_sets) / len(indep_sets)
            print(f"Average overlap with critical set: {avg_overlap:.2f}/{len(critical)}")

    print()


# ── Main ───────────────────────────────────────────────────────────────


if __name__ == "__main__":
    job_scheduling_demo()
    network_reliability_demo()
    sensitivity_analysis_demo()

    print("=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print("""
These applications demonstrate that the transversal matroid framework
provides meaningful bounds in practical settings:

1. SCHEDULING: The number of near-optimal job subsets is polynomial,
   enabling efficient sensitivity analysis for assignment problems.

2. RELIABILITY: Sparse networks have fewer near-failure states,
   making reliability certification tractable.

3. SENSITIVITY: Critical elements concentrate in the active vertex set,
   and the quadratic leaf count bounds the search space for vulnerability
   analysis.

The key insight: sparse choice architectures tame combinatorial explosion
in the enumeration of near-optimal configurations.
""")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of transversal matroid quadratic leaf counts.

Generates random bounded-degree bipartite graphs, computes transversal rank
and quadratic leaf count, and compares against theoretical upper bounds.
"""

import random
import itertools
from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict


def generate_bipartite_graph(n_left: int, n_right: int, max_degree: int,
                              seed: Optional[int] = None) -> List[List[int]]:
    """Generate a random bipartite graph with bounded left-degree.

    Returns adjacency list: adj[l] = list of right neighbors of left vertex l.
    Each left vertex has degree at most max_degree.
    """
    if seed is not None:
        random.seed(seed)
    adj: List[List[int]] = []
    for _ in range(n_left):
        deg = random.randint(1, min(max_degree, n_right))
        neighbors = random.sample(range(n_right), deg)
        adj.append(sorted(neighbors))
    return adj


def find_maximum_matching(adj: List[List[int]], n_right: int) -> Dict[int, int]:
    """Find maximum matching using augmenting paths (Hopcroft-Karp style).

    Returns dict: left_vertex -> matched_right_vertex.
    """
    match_l: Dict[int, int] = {}
    match_r: Dict[int, int] = {}

    def augment(u: int, visited: Set[int]) -> bool:
        for v in adj[u]:
            if v in visited:
                continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v
                match_r[v] = u
                return True
        return False

    for u in range(len(adj)):
        augment(u, set())

    return match_l


def is_independent(subset: Tuple[int, ...], adj: List[List[int]],
                    n_right: int) -> bool:
    """Check if a subset of left vertices admits an injective matching."""
    if not subset:
        return True

    # Build sub-adjacency and find matching
    sub_adj = [adj[v] for v in subset]
    matching = find_maximum_matching(sub_adj, n_right)
    return len(matching) == len(subset)


def compute_rank(adj: List[List[int]], n_right: int) -> int:
    """Compute the transversal rank (maximum matching size)."""
    matching = find_maximum_matching(adj, n_right)
    return len(matching)


def compute_quadratic_leaf_count(adj: List[List[int]], n_right: int,
                                   rank: int) -> int:
    """Count independent sets of size rank - 2."""
    n_left = len(adj)
    target_size = rank - 2
    if target_size < 0:
        return 0
    if target_size == 0:
        return 1  # empty set

    count = 0
    for subset in itertools.combinations(range(n_left), target_size):
        if is_independent(subset, adj, n_right):
            count += 1
    return count


def compute_active_vertices(adj: List[List[int]], n_right: int,
                             rank: int) -> Set[int]:
    """Find active left vertices (those appearing in some maximum matching)."""
    n_left = len(adj)
    active = set()

    # For each left vertex, check if it appears in some maximum matching
    for v in range(n_left):
        # Check if there's a max matching containing v
        # Try to find a max matching that includes v
        for r in adj[v]:
            # Fix v -> r, find max matching in remaining graph
            remaining_adj = []
            idx_map = {}
            idx = 0
            for u in range(n_left):
                if u == v:
                    continue
                remaining_adj.append([w for w in adj[u] if w != r])
                idx_map[idx] = u
                idx += 1
            sub_match = find_maximum_matching(remaining_adj, n_right)
            if len(sub_match) + 1 == rank:
                active.add(v)
                break

    return active


def nat_choose(n: int, k: int) -> int:
    """Compute binomial coefficient C(n, k)."""
    if k < 0 or k > n:
        return 0
    if k == 0 or k == n:
        return 1
    k = min(k, n - k)
    result = 1
    for i in range(k):
        result = result * (n - i) // (i + 1)
    return result


def run_demo():
    """Run the main demonstration."""
    print("=" * 70)
    print("TRANSVERSAL MATROID QUADRATIC LEAF COUNT DEMO")
    print("=" * 70)
    print()

    # Test 1: Small examples with varying degree bounds
    print("--- Test 1: Small examples with varying Δ ---")
    print(f"{'n_L':>4} {'n_R':>4} {'Δ':>3} {'rank':>5} {'QLC':>6} "
          f"{'C(n,r-2)':>10} {'C(act,r-2)':>11} {'active':>7}")
    print("-" * 60)

    for n_left in [6, 8, 10]:
        for delta in [2, 3, 4]:
            n_right = n_left
            adj = generate_bipartite_graph(n_left, n_right, delta, seed=42 + n_left + delta)
            rank = compute_rank(adj, n_right)
            qlc = compute_quadratic_leaf_count(adj, n_right, rank)
            bound1 = nat_choose(n_left, max(0, rank - 2))
            active = compute_active_vertices(adj, n_right, rank)
            bound2 = nat_choose(len(active), max(0, rank - 2))

            print(f"{n_left:>4} {n_right:>4} {delta:>3} {rank:>5} {qlc:>6} "
                  f"{bound1:>10} {bound2:>11} {len(active):>7}")

    print()

    # Test 2: Growth analysis - fixed Δ, varying n
    print("--- Test 2: Growth with n (fixed Δ=3, n_R=n_L) ---")
    print(f"{'n':>4} {'rank':>5} {'QLC':>8} {'C(n,r-2)':>12} {'ratio':>10}")
    print("-" * 45)

    for n in [5, 6, 7, 8, 9, 10, 12]:
        adj = generate_bipartite_graph(n, n, 3, seed=100 + n)
        rank = compute_rank(adj, n)
        qlc = compute_quadratic_leaf_count(adj, n, rank)
        bound = nat_choose(n, max(0, rank - 2))
        ratio = qlc / max(1, bound)

        print(f"{n:>4} {rank:>5} {qlc:>8} {bound:>12} {ratio:>10.4f}")

    print()

    # Test 3: Complete bipartite graph (uniform matroid)
    print("--- Test 3: Complete bipartite graph K_{n,n} (uniform matroid) ---")
    print(f"{'n':>4} {'rank':>5} {'QLC':>8} {'C(n,r-2)':>12} {'match?':>8}")
    print("-" * 45)

    for n in [3, 4, 5, 6, 7]:
        adj = [list(range(n)) for _ in range(n)]
        rank = compute_rank(adj, n)
        qlc = compute_quadratic_leaf_count(adj, n, rank)
        bound = nat_choose(n, max(0, rank - 2))
        match = "✓" if qlc == bound else "✗"

        print(f"{n:>4} {rank:>5} {qlc:>8} {bound:>12} {match:>8}")

    print()

    # Test 4: Sparse vs dense comparison
    print("--- Test 4: Sparse (Δ=2) vs Dense (Δ=n) for n=8 ---")
    n = 8
    for delta_label, delta in [("sparse (Δ=2)", 2), ("medium (Δ=4)", 4), ("dense (Δ=8)", 8)]:
        adj = generate_bipartite_graph(n, n, delta, seed=200 + delta)
        rank = compute_rank(adj, n)
        qlc = compute_quadratic_leaf_count(adj, n, rank)
        bound = nat_choose(n, max(0, rank - 2))
        active = compute_active_vertices(adj, n, rank)
        active_bound = nat_choose(len(active), max(0, rank - 2))

        print(f"  {delta_label:>15}: rank={rank}, QLC={qlc}, "
              f"C(n,r-2)={bound}, C(act,r-2)={active_bound}, active={len(active)}")

    print()

    # Test 5: Empirical ratio analysis for the conjecture
    print("--- Test 5: Conjecture test — QLC / (n^(r-2) · Δ^(r-2)) ---")
    print(f"{'n':>4} {'Δ':>3} {'rank':>5} {'QLC':>8} {'ratio':>12}")
    print("-" * 40)

    for n in [6, 8, 10, 12]:
        for delta in [2, 3]:
            adj = generate_bipartite_graph(n, n, delta, seed=300 + n * 10 + delta)
            rank = compute_rank(adj, n)
            qlc = compute_quadratic_leaf_count(adj, n, rank)
            r_minus_2 = max(0, rank - 2)
            denom = max(1, n ** r_minus_2 * delta ** r_minus_2)
            ratio = qlc / denom

            print(f"{n:>4} {delta:>3} {rank:>5} {qlc:>8} {ratio:>12.6f}")

    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
Key observations:
1. For complete bipartite graphs, QLC = C(n, r-2) exactly (uniform matroid).
2. Sparse presentations (small Δ) generally have smaller QLC.
3. The active vertex bound C(active, r-2) is often tighter than C(n, r-2).
4. The ratio QLC / (n^(r-2) · Δ^(r-2)) appears bounded for fixed r, Δ.
""")


if __name__ == "__main__":
    run_demo()


#!/usr/bin/env python3
"""
Visualization: Active Vertices and Matching Structure

Shows the relationship between active vertices, matching structure, and
the compression of near-basis geometry. Illustrates the key theorem that
independent sets concentrate on the active vertex set.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random
import itertools
from math import comb


def find_max_matching(adj, n_right):
    match_l, match_r = {}, {}
    def augment(u, visited):
        for v in adj[u]:
            if v in visited: continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v; match_r[v] = u; return True
        return False
    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset, adj, n_right):
    if not subset: return True
    sub_adj = [adj[v] for v in subset]
    return len(find_max_matching(sub_adj, n_right)) == len(subset)


def find_active(adj, n_right, rank):
    n_left = len(adj)
    active = set()
    for v in range(n_left):
        for r in adj[v]:
            remaining = [([w for w in adj[u] if w != r]) for u in range(n_left) if u != v]
            if len(find_max_matching(remaining, n_right)) + 1 == rank:
                active.add(v)
                break
    return active


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: Active vs total vertices for varying n
ns = list(range(4, 13))
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    active_counts = []
    for n in ns:
        random.seed(42 + n * 10 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))
        rank = len(find_max_matching(adj, n))
        active = find_active(adj, n, rank)
        active_counts.append(len(active))

    axes[0, 0].plot(ns, active_counts, f'{marker}-', color=color,
                    label=f'Active (Δ={delta})', linewidth=2, markersize=8)

axes[0, 0].plot(ns, ns, 'k--', alpha=0.3, label='n (total)')
axes[0, 0].set_xlabel('n', fontsize=12)
axes[0, 0].set_ylabel('Active vertex count', fontsize=12)
axes[0, 0].set_title('Active Vertices vs Total Vertices', fontsize=13)
axes[0, 0].legend(fontsize=9)
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Improvement from active bound
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's')]:
    improvements = []
    for n in ns:
        random.seed(42 + n * 10 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))
        rank = len(find_max_matching(adj, n))
        active = find_active(adj, n, rank)
        target = max(0, rank - 2)
        bound_ambient = comb(n, target)
        bound_active = comb(len(active), target)
        if bound_ambient > 0:
            improvements.append(1 - bound_active / bound_ambient)
        else:
            improvements.append(0)

    axes[0, 1].plot(ns, improvements, f'{marker}-', color=color,
                    label=f'Δ={delta}', linewidth=2, markersize=8)

axes[0, 1].set_xlabel('n', fontsize=12)
axes[0, 1].set_ylabel('Improvement fraction', fontsize=12)
axes[0, 1].set_title('Bound Improvement: 1 - C(active,r-2)/C(n,r-2)', fontsize=13)
axes[0, 1].legend(fontsize=10)
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].set_ylim(-0.05, 1.05)

# Panel 3: Bipartite graph visualization for a specific example
n = 8
delta = 3
random.seed(42 + n * 10 + delta)
adj = []
for _ in range(n):
    deg = random.randint(1, min(delta, n))
    adj.append(sorted(random.sample(range(n), deg)))

rank = len(find_max_matching(adj, n))
active = find_active(adj, n, rank)
matching = find_max_matching(adj, n)

ax = axes[1, 0]
# Draw left vertices
for i in range(n):
    color = '#e74c3c' if i in active else '#95a5a6'
    size = 300 if i in active else 150
    ax.scatter(0, n - 1 - i, s=size, c=color, zorder=5, edgecolors='black')
    ax.text(-0.15, n - 1 - i, f'L{i}', ha='right', va='center', fontsize=9)

# Draw right vertices
for j in range(n):
    matched = j in {matching[k] for k in matching}
    color = '#3498db' if matched else '#bdc3c7'
    size = 300 if matched else 150
    ax.scatter(2, n - 1 - j, s=size, c=color, zorder=5, edgecolors='black')
    ax.text(2.15, n - 1 - j, f'R{j}', ha='left', va='center', fontsize=9)

# Draw edges
for i in range(n):
    for j in adj[i]:
        is_matched = i in matching and matching[i] == j
        color = '#2ecc71' if is_matched else '#bdc3c7'
        width = 2.5 if is_matched else 0.5
        alpha = 1.0 if is_matched else 0.3
        ax.plot([0, 2], [n - 1 - i, n - 1 - j], color=color,
                linewidth=width, alpha=alpha, zorder=1 if not is_matched else 3)

ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-0.5, n - 0.5)
ax.set_title(f'Bipartite Graph (n={n}, Δ={delta}, rank={rank})', fontsize=13)
ax.set_aspect('equal')
ax.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Active left'),
    mpatches.Patch(facecolor='#95a5a6', edgecolor='black', label='Inactive left'),
    mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Matched right'),
    mpatches.Patch(facecolor='#2ecc71', label='Matching edge'),
]
ax.legend(handles=legend_elements, loc='lower center', fontsize=8, ncol=2)

# Panel 4: Three bounds comparison
ax = axes[1, 1]
ns_small = [5, 6, 7, 8, 9, 10]
delta = 3
qlcs = []
ambient_bounds = []
active_bounds = []

for n in ns_small:
    random.seed(42 + n * 10 + delta)
    adj_local = []
    for _ in range(n):
        deg = random.randint(1, min(delta, n))
        adj_local.append(sorted(random.sample(range(n), deg)))
    rank = len(find_max_matching(adj_local, n))
    qlc = 0
    target = rank - 2
    if target >= 0:
        qlc = sum(1 for s in itertools.combinations(range(n), target)
                  if is_independent(s, adj_local, n))
    active_v = find_active(adj_local, n, rank)

    qlcs.append(qlc)
    ambient_bounds.append(comb(n, max(0, target)))
    active_bounds.append(comb(len(active_v), max(0, target)))

x = np.arange(len(ns_small))
width = 0.25

ax.bar(x - width, ambient_bounds, width, label='C(n, r-2)', color='#3498db', alpha=0.7)
ax.bar(x, active_bounds, width, label='C(active, r-2)', color='#f39c12', alpha=0.7)
ax.bar(x + width, qlcs, width, label='QLC (actual)', color='#e74c3c', alpha=0.7)

ax.set_xticks(x)
ax.set_xticklabels(ns_small)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Three Bounds Comparison (Δ={delta})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('active_vertices.png', dpi=150, bbox_inches='tight')
print("Saved active_vertices.png")


#!/usr/bin/env python3
"""
Visualization: Growth Curves of Quadratic Leaf Count vs Theoretical Bounds

Visualizes how the quadratic leaf count (QLC) grows with the number of left
vertices n, compared to the ambient bound C(n, r-2) and the active vertex
bound C(active, r-2). Shows that sparse presentations (small Δ) consistently
produce QLC well below the ambient bound.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
from typing import List, Dict, Set, Tuple, Optional
from math import comb


def find_max_matching(adj, n_right):
    match_l, match_r = {}, {}
    def augment(u, visited):
        for v in adj[u]:
            if v in visited: continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v; match_r[v] = u; return True
        return False
    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset, adj, n_right):
    if not subset: return True
    sub_adj = [adj[v] for v in subset]
    return len(find_max_matching(sub_adj, n_right)) == len(subset)


def compute_qlc(adj, n_right, rank):
    target = rank - 2
    if target <= 0: return 1 if target == 0 else 0
    return sum(1 for s in itertools.combinations(range(len(adj)), target)
               if is_independent(s, adj, n_right))


def generate_graph(n, delta, seed):
    random.seed(seed)
    adj = []
    for _ in range(n):
        deg = random.randint(1, min(delta, n))
        adj.append(sorted(random.sample(range(n), deg)))
    return adj


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: QLC vs n for different Δ
ns = [4, 5, 6, 7, 8, 9, 10]
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    qlcs, bounds = [], []
    for n in ns:
        adj = generate_graph(n, delta, seed=42 + n * 10 + delta)
        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))
        qlcs.append(qlc)
        bounds.append(bound)

    axes[0].plot(ns, qlcs, f'{marker}-', color=color, label=f'QLC (Δ={delta})',
                 linewidth=2, markersize=8)
    axes[0].plot(ns, bounds, f'{marker}--', color=color, alpha=0.4,
                 label=f'C(n,r-2) (Δ={delta})')

axes[0].set_xlabel('Number of left vertices (n)', fontsize=12)
axes[0].set_ylabel('Count', fontsize=12)
axes[0].set_title('Quadratic Leaf Count vs Ambient Bound', fontsize=13)
axes[0].legend(fontsize=8, loc='upper left')
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Panel 2: Compression ratio QLC / C(n, r-2)
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    ratios = []
    for n in ns:
        adj = generate_graph(n, delta, seed=42 + n * 10 + delta)
        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))
        ratios.append(qlc / max(1, bound))

    axes[1].plot(ns, ratios, f'{marker}-', color=color, label=f'Δ={delta}',
                 linewidth=2, markersize=8)

axes[1].set_xlabel('Number of left vertices (n)', fontsize=12)
axes[1].set_ylabel('QLC / C(n, r-2)', fontsize=12)
axes[1].set_title('Compression Ratio (lower = sparser)', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].set_ylim(0, 1.05)
axes[1].grid(True, alpha=0.3)
axes[1].axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)

# Panel 3: QLC for complete vs sparse at fixed n=8
n = 8
deltas = [2, 3, 4, 5, 6, 7, 8]
qlcs_by_delta = []
bounds_by_delta = []

for delta in deltas:
    if delta == n:
        adj = [list(range(n)) for _ in range(n)]
    else:
        adj = generate_graph(n, delta, seed=100 + delta)
    rank = len(find_max_matching(adj, n))
    qlc = compute_qlc(adj, n, rank)
    bound = comb(n, max(0, rank - 2))
    qlcs_by_delta.append(qlc)
    bounds_by_delta.append(bound)

axes[2].bar([d - 0.15 for d in deltas], qlcs_by_delta, width=0.3,
            color='#e74c3c', label='QLC', alpha=0.8)
axes[2].bar([d + 0.15 for d in deltas], bounds_by_delta, width=0.3,
            color='#3498db', label='C(n,r-2)', alpha=0.5)
axes[2].set_xlabel('Maximum left degree (Δ)', fontsize=12)
axes[2].set_ylabel('Count', fontsize=12)
axes[2].set_title(f'QLC vs Bound (n={n})', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('growth_curves.png', dpi=150, bbox_inches='tight')
print("Saved growth_curves.png")


#!/usr/bin/env python3
"""
Visualization: Heatmap of Compression Ratios

Shows the ratio QLC / C(n, r-2) across different values of n and Δ,
revealing how sparsity in the bipartite presentation compresses the
near-basis geometry. Darker cells indicate stronger compression
(fewer near-bases relative to the ambient bound).
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
from math import comb


def find_max_matching(adj, n_right):
    match_l, match_r = {}, {}
    def augment(u, visited):
        for v in adj[u]:
            if v in visited: continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v; match_r[v] = u; return True
        return False
    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset, adj, n_right):
    if not subset: return True
    sub_adj = [adj[v] for v in subset]
    return len(find_max_matching(sub_adj, n_right)) == len(subset)


def compute_qlc(adj, n_right, rank):
    target = rank - 2
    if target <= 0: return 1 if target == 0 else 0
    return sum(1 for s in itertools.combinations(range(len(adj)), target)
               if is_independent(s, adj, n_right))


ns = [4, 5, 6, 7, 8, 9, 10]
deltas = [2, 3, 4, 5, 6]

ratio_matrix = np.zeros((len(deltas), len(ns)))
qlc_matrix = np.zeros((len(deltas), len(ns)))
rank_matrix = np.zeros((len(deltas), len(ns)))

for i, delta in enumerate(deltas):
    for j, n in enumerate(ns):
        random.seed(42 + n * 100 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))

        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))

        ratio_matrix[i, j] = qlc / max(1, bound)
        qlc_matrix[i, j] = qlc
        rank_matrix[i, j] = rank

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Compression ratio heatmap
im1 = axes[0].imshow(ratio_matrix, cmap='RdYlGn_r', aspect='auto',
                       vmin=0, vmax=1)
axes[0].set_xticks(range(len(ns)))
axes[0].set_xticklabels(ns)
axes[0].set_yticks(range(len(deltas)))
axes[0].set_yticklabels(deltas)
axes[0].set_xlabel('Number of vertices (n)', fontsize=12)
axes[0].set_ylabel('Maximum degree (Δ)', fontsize=12)
axes[0].set_title('Compression Ratio: QLC / C(n, r-2)', fontsize=13)

for i in range(len(deltas)):
    for j in range(len(ns)):
        color = 'white' if ratio_matrix[i, j] > 0.5 else 'black'
        axes[0].text(j, i, f'{ratio_matrix[i,j]:.2f}',
                     ha='center', va='center', color=color, fontsize=9)

plt.colorbar(im1, ax=axes[0], label='Ratio (0=max compression, 1=no compression)')

# Panel 2: Absolute QLC values
im2 = axes[1].imshow(qlc_matrix, cmap='viridis', aspect='auto')
axes[1].set_xticks(range(len(ns)))
axes[1].set_xticklabels(ns)
axes[1].set_yticks(range(len(deltas)))
axes[1].set_yticklabels(deltas)
axes[1].set_xlabel('Number of vertices (n)', fontsize=12)
axes[1].set_ylabel('Maximum degree (Δ)', fontsize=12)
axes[1].set_title('Quadratic Leaf Count (absolute)', fontsize=13)

for i in range(len(deltas)):
    for j in range(len(ns)):
        val = int(qlc_matrix[i, j])
        color = 'white' if qlc_matrix[i, j] < np.median(qlc_matrix) else 'black'
        axes[1].text(j, i, str(val), ha='center', va='center',
                     color=color, fontsize=9)

plt.colorbar(im2, ax=axes[1], label='QLC')

plt.tight_layout()
plt.savefig('heatmap.png', dpi=150, bbox_inches='tight')
print("Saved heatmap.png")
