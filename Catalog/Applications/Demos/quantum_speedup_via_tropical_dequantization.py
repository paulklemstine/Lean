#!/usr/bin/env python3
"""
Tropical Dequantization — Real-World Applications

Demonstrates how tropical dequantization applies to practical problems:
1. Network routing (shortest paths)
2. Sequence alignment (bioinformatics)
3. Portfolio optimization (finance)
4. Energy minimization (physics/ML)
"""

import numpy as np
from typing import List, Tuple, Optional


# ============================================================================
# Application 1: Network Routing via Tropical DP
# ============================================================================

def network_routing_demo():
    """Demonstrate tropical DP for network routing.

    Models a data center network where we want to find the minimum-latency
    path from source to destination. This is exactly the tropical Bellman
    recursion applied to network optimization.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing via Tropical DP")
    print("=" * 60)
    print()

    # Network topology (latencies in ms)
    nodes = ["Source", "Router-A", "Router-B", "Router-C", "Router-D", "Dest"]
    n = len(nodes)
    INF = float('inf')

    # Latency matrix
    latency = np.full((n, n), INF)
    edges = [
        (0, 1, 2),   # Source → Router-A: 2ms
        (0, 2, 5),   # Source → Router-B: 5ms
        (1, 2, 1),   # Router-A → Router-B: 1ms
        (1, 3, 4),   # Router-A → Router-C: 4ms
        (2, 3, 2),   # Router-B → Router-C: 2ms
        (2, 4, 3),   # Router-B → Router-D: 3ms
        (3, 5, 1),   # Router-C → Dest: 1ms
        (4, 5, 2),   # Router-D → Dest: 2ms
    ]
    for i, j, w in edges:
        latency[i, j] = w

    # Tropical shortest path (Floyd-Warshall = tropical matrix closure)
    D = latency.copy()
    np.fill_diagonal(D, 0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])

    print("Network topology:")
    for i, j, w in edges:
        print(f"  {nodes[i]:>10} --{w}ms--> {nodes[j]}")
    print()

    min_latency = D[0, 5]
    print(f"Minimum latency (Source → Dest): {min_latency}ms")

    # Reconstruct path
    # Using Bellman-style backtracking
    path = [0]
    current = 0
    while current != 5:
        best_next = -1
        best_cost = INF
        for j in range(n):
            if latency[current, j] + D[j, 5] < best_cost:
                best_cost = latency[current, j] + D[j, 5]
                best_next = j
        path.append(best_next)
        current = best_next

    print(f"Optimal path: {' → '.join(nodes[i] for i in path)}")
    print()
    print("The tropical Bellman recursion finds this path in O(|E| + |V|) time,")
    print("the same complexity as quantum-inspired path-sum computation.")
    print()


# ============================================================================
# Application 2: Sequence Alignment (Bioinformatics)
# ============================================================================

def sequence_alignment_demo():
    """Demonstrate tropical DP for DNA sequence alignment.

    The Needleman-Wunsch algorithm for sequence alignment is exactly
    a tropical Bellman recursion: we minimize the edit distance (sum of
    penalties) over all possible alignments (paths through the DP table).
    """
    print("=" * 60)
    print("APPLICATION 2: Sequence Alignment (Tropical DP)")
    print("=" * 60)
    print()

    seq1 = "ACGTACGT"
    seq2 = "ACGTCGT"
    gap_penalty = 1
    mismatch_penalty = 1

    m, n = len(seq1), len(seq2)
    # DP table: tropical value at each (i,j) = min edit cost to align seq1[:i] with seq2[:j]
    dp = np.zeros((m + 1, n + 1))
    for i in range(m + 1):
        dp[i, 0] = i * gap_penalty
    for j in range(n + 1):
        dp[0, j] = j * gap_penalty

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            match_cost = dp[i-1, j-1] + (0 if seq1[i-1] == seq2[j-1] else mismatch_penalty)
            gap1_cost = dp[i-1, j] + gap_penalty
            gap2_cost = dp[i, j-1] + gap_penalty
            dp[i, j] = min(match_cost, gap1_cost, gap2_cost)  # Tropical min!

    print(f"Sequence 1: {seq1}")
    print(f"Sequence 2: {seq2}")
    print(f"Edit distance: {int(dp[m, n])}")
    print()
    print("The Needleman-Wunsch algorithm IS a tropical Bellman recursion:")
    print("  - States = (i, j) positions in the DP table")
    print("  - Transitions = match/mismatch/gap operations")
    print("  - Weights = penalties (0 for match, 1 for mismatch/gap)")
    print("  - Value = min-cost alignment = tropical path cost")
    print()
    print(f"Complexity: O({m} × {n}) = O({m*n}) = edge_count + states")
    print()


# ============================================================================
# Application 3: Portfolio Optimization (Finance)
# ============================================================================

def portfolio_optimization_demo():
    """Demonstrate tropical optimization for worst-case portfolio analysis.

    In robust portfolio optimization, we minimize the worst-case loss
    across scenarios. This is a tropical (min-max) computation: for each
    portfolio, compute the maximum loss; then take the portfolio minimizing
    this maximum. The inner max is tropical in the "max-plus" semiring.
    """
    print("=" * 60)
    print("APPLICATION 3: Robust Portfolio Optimization")
    print("=" * 60)
    print()

    np.random.seed(42)
    n_assets = 4
    n_scenarios = 5
    asset_names = ["Stocks", "Bonds", "Gold", "Crypto"]

    # Loss matrix: loss[scenario, asset] = loss in that scenario
    losses = np.array([
        [-5, 2, 1, -10],   # Bull market
        [8, -1, 3, 15],    # Bear market
        [2, 1, -3, 5],     # Inflation
        [-2, 5, 2, 20],    # Rate hike
        [3, 0, -1, -5],    # Stable
    ], dtype=float)

    print("Loss matrix (% loss per scenario):")
    print(f"  {'Scenario':<12} " + " ".join(f"{a:>8}" for a in asset_names))
    for i in range(n_scenarios):
        print(f"  Scenario {i+1:<3} " + " ".join(f"{losses[i,j]:>8.1f}" for j in range(n_assets)))
    print()

    # For equal-weight portfolios of each asset:
    # Worst-case loss = max over scenarios of loss
    worst_case = np.max(losses, axis=0)  # Max over scenarios for each asset

    # Best asset = min over assets of worst-case loss (minimax)
    best_asset = np.argmin(worst_case)

    print("Worst-case loss per asset (max over scenarios):")
    for j in range(n_assets):
        marker = " ← BEST" if j == best_asset else ""
        print(f"  {asset_names[j]:<8}: {worst_case[j]:.1f}%{marker}")

    print()
    print(f"Minimax optimal: {asset_names[best_asset]} (worst-case: {worst_case[best_asset]:.1f}%)")
    print()
    print("This minimax computation is tropical: we take max (tropical sum")
    print("in max-plus) over scenarios, then min (tropical aggregation) over assets.")
    print()


# ============================================================================
# Application 4: Energy Minimization with Temperature Annealing
# ============================================================================

def energy_minimization_demo():
    """Demonstrate the transition from Gibbs sampling to tropical optimization.

    Shows how increasing β (decreasing temperature) makes Gibbs sampling
    concentrate on the minimum-energy configuration, converging to the
    tropical limit.
    """
    print("=" * 60)
    print("APPLICATION 4: Energy Minimization (Tropical Limit)")
    print("=" * 60)
    print()

    np.random.seed(42)
    n = 50

    # Energy landscape with multiple local minima
    x = np.linspace(0, 10, n)
    energies = np.sin(x) * np.cos(0.5 * x) + 0.1 * x

    min_idx = np.argmin(energies)
    min_E = energies[min_idx]

    print(f"Energy landscape: {n} states")
    print(f"Global minimum: E[{min_idx}] = {min_E:.4f}")
    print()

    betas = [0.1, 1, 5, 10, 50, 100]
    print(f"{'β':>6} {'softmin':>10} {'P(ground)':>10} {'min(E)':>10} {'gap':>10}")
    print("-" * 50)

    rng = np.random.default_rng(42)
    for beta in betas:
        # Softmin
        shifted = -beta * energies
        max_shifted = np.max(shifted)
        log_sum = max_shifted + np.log(np.sum(np.exp(shifted - max_shifted)))
        sm = -(1/beta) * log_sum

        # Gibbs sampling
        log_weights = -beta * energies
        log_weights -= np.max(log_weights)
        weights = np.exp(log_weights)
        probs = weights / np.sum(weights)
        p_ground = probs[min_idx]

        gap = min_E - sm

        print(f"{beta:>6.1f} {sm:>10.4f} {p_ground:>10.4f} {min_E:>10.4f} {gap:>10.6f}")

    print()
    print("As β → ∞:")
    print("  - softmin → min(E) (tropical limit)")
    print("  - P(ground state) → 1 (concentration)")
    print("  - Gibbs sampling → deterministic optimization")
    print()
    print("This is the zero-temperature bridge: quantum-inspired sampling")
    print("becomes tropical optimization in the β → ∞ limit.")
    print()


if __name__ == "__main__":
    network_routing_demo()
    sequence_alignment_demo()
    portfolio_optimization_demo()
    energy_minimization_demo()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Dequantization — Concrete Demonstrations

This module demonstrates the key theorems from the tropical dequantization
framework with concrete numerical examples, making the mathematics tangible.
"""

import numpy as np
from typing import List, Dict, Tuple, Optional, Callable


def demo_tropical_distributivity():
    """Demonstrate the fundamental tropical distributive law:
    a + min(b, c) = min(a + b, a + c)
    """
    print("=" * 60)
    print("DEMO 1: Tropical Distributive Law")
    print("=" * 60)
    print()
    print("The tropical semiring replaces (×, +) with (+, min).")
    print("Key property: a + min(b, c) = min(a + b, a + c)")
    print()

    test_cases = [
        (3, 5, 7),
        (0, 10, 20),
        (100, 1, 1),
        (42, 17, 99),
    ]

    for a, b, c in test_cases:
        lhs = a + min(b, c)
        rhs = min(a + b, a + c)
        print(f"  a={a}, b={b}, c={c}: "
              f"{a} + min({b},{c}) = {lhs}, "
              f"min({a}+{b}, {a}+{c}) = {rhs} "
              f"{'✓' if lhs == rhs else '✗'}")

    print()
    print("This law is the algebraic engine of dynamic programming.")
    print("It ensures optimal substructure: the best path through a")
    print("junction equals the junction cost plus the best continuation.")
    print()


def demo_bellman_recursion():
    """Demonstrate the Bellman tropical value recursion on a small DAG."""
    print("=" * 60)
    print("DEMO 2: Bellman Tropical Value Recursion")
    print("=" * 60)
    print()

    # Define a small DAG:
    #   0 --3--> 1 --2--> 3(acc)
    #   0 --1--> 2 --5--> 3(acc)
    #   2 --1--> 4(acc)
    states = [0, 1, 2, 3, 4]
    next_fn = {
        0: [1, 2],
        1: [3],
        2: [3, 4],
        3: [],
        4: [],
    }
    weights = {
        (0, 1): 3, (0, 2): 1,
        (1, 3): 2,
        (2, 3): 5, (2, 4): 1,
    }
    accepting = {3, 4}

    INF = float('inf')

    def tropical_value(depth: int, state: int) -> float:
        if state in accepting:
            return 0
        if depth == 0:
            return INF
        successors = next_fn.get(state, [])
        if not successors:
            return INF
        return min(weights.get((state, t), INF) + tropical_value(depth - 1, t)
                   for t in successors)

    print("DAG structure:")
    print("  0 --3--> 1 --2--> 3(accept)")
    print("  0 --1--> 2 --5--> 3(accept)")
    print("               --1--> 4(accept)")
    print()
    print("Tropical value recursion from state 0:")
    print()

    for d in range(5):
        v = tropical_value(d, 0)
        v_str = "∞" if v == INF else str(int(v))
        print(f"  depth {d}: value = {v_str}")

    print()
    print("Optimal path: 0 --1--> 2 --1--> 4, cost = 2")
    print("This matches the stabilized value at depth ≥ 2.")
    print()

    # Verify monotonicity
    values = [tropical_value(d, 0) for d in range(5)]
    mono = all(values[i+1] <= values[i] for i in range(4))
    print(f"Monotonicity (value(d+1) ≤ value(d)): {'✓' if mono else '✗'}")
    print()


def demo_softmin_convergence():
    """Demonstrate the softmin sandwich bounds and convergence."""
    print("=" * 60)
    print("DEMO 3: Softmin Convergence (Zero-Temperature Limit)")
    print("=" * 60)
    print()

    # Energy landscape
    np.random.seed(42)
    n = 20
    energies = np.random.uniform(0, 10, n)
    min_E = np.min(energies)

    print(f"Energy landscape: {n} states with energies in [0, 10]")
    print(f"True minimum energy: {min_E:.6f}")
    print(f"log(n) = {np.log(n):.4f}")
    print()

    print(f"{'β':>8} {'softmin(β)':>12} {'min(E)':>10} {'gap':>10} {'log(n)/β':>10} {'bound ok?':>10}")
    print("-" * 62)

    betas = [0.1, 0.5, 1, 2, 5, 10, 50, 100, 500, 1000]
    for beta in betas:
        log_sum_exp = np.log(np.sum(np.exp(-beta * energies)))
        softmin = -(1/beta) * log_sum_exp
        gap = min_E - softmin
        bound = np.log(n) / beta
        ok = -1e-10 <= gap <= bound + 1e-10

        print(f"{beta:>8.1f} {softmin:>12.6f} {min_E:>10.6f} {gap:>10.6f} {bound:>10.6f} {'✓' if ok else '✗':>10}")

    print()
    print("The sandwich theorem guarantees:")
    print("  min(E) - log(n)/β ≤ softmin(β) ≤ min(E)")
    print("As β → ∞, softmin → min(E) (tropical limit).")
    print()


def demo_tropical_search():
    """Demonstrate tropical search finding the minimum marked index."""
    print("=" * 60)
    print("DEMO 4: Tropical Search")
    print("=" * 60)
    print()

    n = 20
    np.random.seed(123)
    # Random predicate: mark ~30% of elements
    marked = np.random.random(n) < 0.3
    marked[7] = True  # Ensure at least one marked

    print(f"Search space: Fin({n})")
    print(f"Marked elements: {[i for i in range(n) if marked[i]]}")
    print()

    # Tropical search: take min over marked indices
    marked_indices = [i for i in range(n) if marked[i]]
    result = min(marked_indices)

    print(f"Tropical search value: {result}")
    print(f"Is marked: {marked[result]}")
    print(f"Is minimal: {all(result <= j for j in marked_indices)}")
    print()

    # Demonstrate the tropical interference principle
    mid = n // 2
    left = [i for i in marked_indices if i < mid]
    right = [i for i in marked_indices if i >= mid]

    if left and right:
        min_left = min(left)
        min_right = min(right)
        min_union = min(min_left, min_right)
        print("Tropical interference principle:")
        print(f"  Left half minimum:  {min_left}")
        print(f"  Right half minimum: {min_right}")
        print(f"  min(left, right):   {min_union}")
        print(f"  Global minimum:     {result}")
        print(f"  Equal: {'✓' if min_union == result else '✗'}")
    print()


def demo_path_competition():
    """Demonstrate how tropical 'interference' works as path competition."""
    print("=" * 60)
    print("DEMO 5: Path Competition (Tropical Interference)")
    print("=" * 60)
    print()

    print("Consider a branching computation with 8 paths:")
    print()

    paths = [
        ("A→B→C→D (accept)", [3, 2, 1]),
        ("A→B→C→E (reject)", [3, 2, 4]),
        ("A→B→F→G (accept)", [3, 5, 2]),
        ("A→B→F→H (accept)", [3, 5, 3]),
        ("A→I→J→K (accept)", [1, 4, 2]),
        ("A→I→J→L (reject)", [1, 4, 5]),
        ("A→I→M→N (accept)", [1, 1, 1]),
        ("A→I→M→O (accept)", [1, 1, 8]),
    ]

    accepting_paths = [(name, costs) for name, costs in paths
                       if "accept" in name]

    print(f"  {'Path':<25} {'Costs':<15} {'Total':<8} {'Status'}")
    print(f"  {'-'*25} {'-'*15} {'-'*8} {'-'*10}")

    for name, costs in paths:
        total = sum(costs)
        status = "accept" if "accept" in name else "REJECT"
        cost_str = " + ".join(str(c) for c in costs)
        print(f"  {name:<25} {cost_str:<15} {total:<8} {status}")

    print()

    # Tropical computation: min over accepting paths
    accept_costs = [sum(costs) for name, costs in accepting_paths]
    winner_idx = np.argmin(accept_costs)
    winner_name = accepting_paths[winner_idx][0]

    print(f"Tropical value (min over accepting paths): {min(accept_costs)}")
    print(f"Winning path: {winner_name}")
    print()
    print("The 'interference' is the competition: 6 accepting paths")
    print("compete, and the minimum-cost path wins. This is the")
    print("tropical analogue of quantum amplitude interference.")
    print()

    # Show bottom-up computation
    print("Bottom-up Bellman computation:")
    print()

    # Level 2 (from B and I)
    # B's subtree: min(3+2+1, 3+5+2, 3+5+3) considering only accepting
    b_value = min(2+1, 5+2, 5+3)  # from B
    i_value = min(4+2, 1+1, 1+8)  # from I (accepting only)
    a_value = min(3 + b_value, 1 + i_value)

    print(f"  value(B) = min(2+1, 5+2, 5+3) = {b_value}")
    print(f"  value(I) = min(4+2, 1+1, 1+8) = {i_value}")
    print(f"  value(A) = min(3+{b_value}, 1+{i_value}) = {a_value}")
    print()
    print("The distributive law ensures this bottom-up computation")
    print("gives the same result as exhaustive enumeration.")
    print()


if __name__ == "__main__":
    demo_tropical_distributivity()
    demo_bellman_recursion()
    demo_softmin_convergence()
    demo_tropical_search()
    demo_path_competition()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import base64
import io
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Generate base64 images
from visualizations import (
    plot_softmin_convergence,
    plot_bellman_monotonicity,
    plot_gibbs_concentration,
    plot_softmin_gap,
    plot_tropical_search,
)

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean files
lean_core = read_file('Tropical/Dequantization/Core.lean')
lean_softmin = read_file('Tropical/Dequantization/Softmin.lean')
lean_search = read_file('Tropical/Dequantization/Search.lean')
lean_proofs = f"-- Core.lean\n{lean_core}\n\n-- Softmin.lean\n{lean_softmin}\n\n-- Search.lean\n{lean_search}"

# Generate visualizations
print("Generating visualizations for JSON...")
viz_softmin = plot_softmin_convergence()
viz_bellman = plot_bellman_monotonicity()
viz_gibbs = plot_gibbs_concentration()
viz_gap = plot_softmin_gap()
viz_search = plot_tropical_search()

package = {
    "title": "Tropical Dequantization of Path-Sum Algorithms",
    "domain": "Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Dequantization Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Bellman Value Recursion",
            "pseudocode": """Algorithm: TropicalBellmanValue(bp, depth, state)
Input: Branching program bp, depth bound d, start state s
Output: Minimum-cost accepting path value

1. If state is accepting: return 0
2. If depth = 0: return ∞
3. value ← ∞
4. For each successor t of state:
     cost ← w(state, t) + TropicalBellmanValue(bp, depth-1, t)
     value ← min(value, cost)
5. Return value

Complexity: O(|E| + |V|) with memoization""",
            "code": algorithms_code
        },
        {
            "name": "Softmin Computation",
            "pseudocode": """Algorithm: Softmin(E, β)
Input: Energy function E over n states, inverse temperature β > 0
Output: -(1/β) · log(Σ exp(-β · E(x)))

1. Compute shifted = -β · E(x) for all x
2. max_val ← max(shifted)  [for numerical stability]
3. log_sum ← max_val + log(Σ exp(shifted - max_val))
4. Return -(1/β) · log_sum

Complexity: O(n)
Guarantee: min(E) - log(n)/β ≤ softmin ≤ min(E)""",
            "code": "# See algorithms.py softmin() function"
        },
        {
            "name": "Tropical Search (Divide and Conquer)",
            "pseudocode": """Algorithm: TropicalSearch(predicate, lo, hi)
Input: Boolean predicate f, search range [lo, hi)
Output: Minimum index i in [lo,hi) with f(i) = true

1. If lo ≥ hi: return None
2. If hi - lo = 1: return lo if f(lo) else None
3. mid ← (lo + hi) / 2
4. left ← TropicalSearch(f, lo, mid)
5. right ← TropicalSearch(f, mid, hi)
6. Return min(left, right)  [tropical interference]

Complexity: O(hi - lo) work, O(log(hi - lo)) depth""",
            "code": "# See algorithms.py tropical_search_divide_conquer() function"
        }
    ],
    "visualizations": [
        {"name": "Softmin Convergence to Minimum", "data": viz_softmin},
        {"name": "Bellman Recursion Monotonicity", "data": viz_bellman},
        {"name": "Gibbs Distribution Concentration", "data": viz_gibbs},
        {"name": "Softmin Gap Analysis", "data": viz_gap},
        {"name": "Tropical Search Visualization", "data": viz_search},
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Tropical Dequantization — Visualizations

Generates publication-quality figures for the research paper and article.
All figures are saved as PNG files and also returned as base64 data URIs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io
from typing import List, Tuple


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_softmin_convergence() -> str:
    """Plot softmin convergence to the minimum as β → ∞."""
    np.random.seed(42)
    n = 20
    energies = np.random.uniform(0.5, 5, n)
    min_E = np.min(energies)

    betas = np.logspace(-1, 3, 200)
    softmins = []
    upper_bounds = []
    lower_bounds = []

    for beta in betas:
        shifted = -beta * energies
        max_s = np.max(shifted)
        log_sum = max_s + np.log(np.sum(np.exp(shifted - max_s)))
        sm = -(1/beta) * log_sum
        softmins.append(sm)
        upper_bounds.append(min_E)
        lower_bounds.append(min_E - np.log(n) / beta)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    ax.semilogx(betas, softmins, 'b-', linewidth=2, label='softmin(β)', zorder=3)
    ax.semilogx(betas, upper_bounds, 'r--', linewidth=1.5, label='min(E) (upper bound)')
    ax.semilogx(betas, lower_bounds, 'g--', linewidth=1.5, label='min(E) − log(n)/β (lower bound)')

    ax.fill_between(betas, lower_bounds, upper_bounds, alpha=0.1, color='gray',
                     label='Sandwich region')

    ax.set_xlabel('Inverse temperature β', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Softmin Convergence to Minimum (Tropical Limit)', fontsize=16)
    ax.legend(fontsize=12, loc='lower right')
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Tropical limit\n(β → ∞)',
                xy=(800, min_E), xytext=(100, min_E + 1.5),
                fontsize=12, ha='center',
                arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    fig.savefig('/workspace/request-project/softmin_convergence.png',
                dpi=150, bbox_inches='tight')

    return fig_to_base64(fig)


def plot_bellman_monotonicity() -> str:
    """Plot the monotonicity of tropical values with depth."""

    # DAG: branching tree with 3 levels
    # State 0 → {1,2}, 1 → {3,4}, 2 → {5,6}, 3→{7}, 4→{7}, 5→{7}, 6→{7}
    # Weights: random in [1, 10]
    np.random.seed(42)
    next_fn = {0: [1,2], 1: [3,4], 2: [5,6], 3: [7], 4: [7], 5: [7], 6: [7], 7: []}
    weights = {}
    for s, succs in next_fn.items():
        for t in succs:
            weights[(s,t)] = np.random.randint(1, 10)
    accepting = {7}

    INF = float('inf')

    def trop_val(d, s, memo={}):
        if (d, s) in memo:
            return memo[(d, s)]
        if s in accepting:
            memo[(d, s)] = 0
            return 0
        if d == 0:
            memo[(d, s)] = INF
            return INF
        succs = next_fn.get(s, [])
        if not succs:
            memo[(d, s)] = INF
            return INF
        v = min(weights[(s, t)] + trop_val(d-1, t, memo) for t in succs)
        memo[(d, s)] = v
        return v

    depths = list(range(8))
    values = {}
    for s in range(8):
        values[s] = []
        for d in depths:
            v = trop_val(d, s, {})
            values[s].append(v if v != INF else None)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    colors = plt.cm.tab10(np.linspace(0, 1, 8))
    for s in [0, 1, 2, 3, 4, 5, 6]:
        vals = values[s]
        # Replace None with NaN for plotting
        plot_vals = [v if v is not None else np.nan for v in vals]
        if any(v is not None for v in vals):
            ax.plot(depths, plot_vals, 'o-', color=colors[s], linewidth=2,
                    markersize=8, label=f'State {s}')

    ax.set_xlabel('Depth d', fontsize=14)
    ax.set_ylabel('Tropical Value', fontsize=14)
    ax.set_title('Bellman Recursion: Value Monotonicity', fontsize=16)
    ax.legend(fontsize=10, loc='upper right', ncol=2)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(depths)

    fig.savefig('/workspace/request-project/bellman_monotonicity.png',
                dpi=150, bbox_inches='tight')

    return fig_to_base64(fig)


def plot_gibbs_concentration() -> str:
    """Plot Gibbs distribution concentration as β → ∞."""
    np.random.seed(42)
    n = 10
    energies = np.sort(np.random.uniform(0, 5, n))

    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    betas = [0.1, 0.5, 1, 5, 20, 100]

    for ax, beta in zip(axes.flat, betas):
        log_w = -beta * energies
        log_w -= np.max(log_w)
        w = np.exp(log_w)
        probs = w / np.sum(w)

        bars = ax.bar(range(n), probs, color='steelblue', alpha=0.8)
        bars[0].set_color('crimson')  # Highlight ground state

        ax.set_title(f'β = {beta}', fontsize=14, fontweight='bold')
        ax.set_xlabel('State (sorted by energy)', fontsize=10)
        ax.set_ylabel('Probability', fontsize=10)
        ax.set_ylim(0, 1.05)
        ax.set_xticks(range(n))

    fig.suptitle('Gibbs Distribution → Tropical Limit (β → ∞)', fontsize=18, y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/gibbs_concentration.png',
                dpi=150, bbox_inches='tight')

    return fig_to_base64(fig)


def plot_softmin_gap() -> str:
    """Plot the softmin gap (min - softmin) and its bound."""
    np.random.seed(42)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: gap vs beta for different n
    ax = axes[0]
    for n in [5, 20, 100, 500]:
        energies = np.random.uniform(0, 10, n)
        min_E = np.min(energies)
        betas = np.logspace(-0.5, 3, 100)
        gaps = []
        bounds = []
        for beta in betas:
            shifted = -beta * energies
            max_s = np.max(shifted)
            log_sum = max_s + np.log(np.sum(np.exp(shifted - max_s)))
            sm = -(1/beta) * log_sum
            gaps.append(min_E - sm)
            bounds.append(np.log(n) / beta)
        ax.loglog(betas, gaps, '-', linewidth=2, label=f'gap (n={n})')
        ax.loglog(betas, bounds, '--', linewidth=1, alpha=0.5, label=f'log({n})/β')

    ax.set_xlabel('Inverse temperature β', fontsize=13)
    ax.set_ylabel('Gap = min(E) − softmin(β)', fontsize=13)
    ax.set_title('Softmin Gap Decay', fontsize=15)
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)

    # Right: gap/bound ratio
    ax = axes[1]
    for n in [5, 20, 100, 500]:
        energies = np.random.uniform(0, 10, n)
        min_E = np.min(energies)
        betas = np.logspace(0, 3, 100)
        ratios = []
        for beta in betas:
            shifted = -beta * energies
            max_s = np.max(shifted)
            log_sum = max_s + np.log(np.sum(np.exp(shifted - max_s)))
            sm = -(1/beta) * log_sum
            gap = min_E - sm
            bound = np.log(n) / beta
            ratios.append(gap / bound if bound > 1e-15 else 0)
        ax.semilogx(betas, ratios, '-', linewidth=2, label=f'n={n}')

    ax.set_xlabel('Inverse temperature β', fontsize=13)
    ax.set_ylabel('gap / (log(n)/β)', fontsize=13)
    ax.set_title('Tightness of Softmin Bound', fontsize=15)
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1, color='red', linestyle=':', alpha=0.5, label='bound = 1')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()

    fig.savefig('/workspace/request-project/softmin_gap.png',
                dpi=150, bbox_inches='tight')

    return fig_to_base64(fig)


def plot_tropical_search() -> str:
    """Visualize tropical search as min-plus aggregation."""
    np.random.seed(42)
    n = 32
    marked = np.zeros(n, dtype=bool)
    marked_indices = [3, 7, 12, 15, 21, 28]
    marked[marked_indices] = True

    fig, axes = plt.subplots(2, 1, figsize=(14, 8))

    # Top: the search space with marked elements
    ax = axes[0]
    colors = ['crimson' if m else 'lightgray' for m in marked]
    ax.bar(range(n), [1]*n, color=colors, edgecolor='gray', linewidth=0.5)
    ax.set_xlabel('Index', fontsize=13)
    ax.set_title('Search Space: Marked Elements (red)', fontsize=15)
    ax.set_yticks([])

    # Highlight minimum
    min_marked = min(marked_indices)
    ax.annotate(f'Tropical search\nresult: {min_marked}',
                xy=(min_marked, 1), xytext=(min_marked + 5, 1.3),
                fontsize=12, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='black', lw=2))

    # Bottom: divide and conquer visualization
    ax = axes[1]
    mid = n // 2
    left_marked = [i for i in marked_indices if i < mid]
    right_marked = [i for i in marked_indices if i >= mid]

    colors_dc = []
    for i in range(n):
        if i == min_marked:
            colors_dc.append('gold')
        elif marked[i] and i < mid:
            colors_dc.append('steelblue')
        elif marked[i]:
            colors_dc.append('darkorange')
        elif i < mid:
            colors_dc.append('lightblue')
        else:
            colors_dc.append('moccasin')

    ax.bar(range(n), [1]*n, color=colors_dc, edgecolor='gray', linewidth=0.5)
    ax.axvline(x=mid - 0.5, color='black', linewidth=2, linestyle='--')

    ax.annotate(f'Left min: {min(left_marked)}',
                xy=(min(left_marked), 0.5), xytext=(2, 0.3),
                fontsize=11, arrowprops=dict(arrowstyle='->', lw=1.5))
    ax.annotate(f'Right min: {min(right_marked)}',
                xy=(min(right_marked), 0.5), xytext=(22, 0.3),
                fontsize=11, arrowprops=dict(arrowstyle='->', lw=1.5))
    ax.annotate(f'Global min = min({min(left_marked)}, {min(right_marked)}) = {min_marked}',
                xy=(mid, 1.3), fontsize=13, fontweight='bold', ha='center')

    ax.set_xlabel('Index', fontsize=13)
    ax.set_title('Tropical Interference: min(left, right) = global optimum', fontsize=15)
    ax.set_yticks([])

    plt.tight_layout()

    fig.savefig('/workspace/request-project/tropical_search.png',
                dpi=150, bbox_inches='tight')

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_softmin = plot_softmin_convergence()
    print(f"  softmin_convergence.png ({len(b64_softmin)} chars)")

    b64_bellman = plot_bellman_monotonicity()
    print(f"  bellman_monotonicity.png ({len(b64_bellman)} chars)")

    b64_gibbs = plot_gibbs_concentration()
    print(f"  gibbs_concentration.png ({len(b64_gibbs)} chars)")

    b64_gap = plot_softmin_gap()
    print(f"  softmin_gap.png ({len(b64_gap)} chars)")

    b64_search = plot_tropical_search()
    print(f"  tropical_search.png ({len(b64_search)} chars)")

    print("\nAll visualizations generated successfully.")
    print("\nBase64 data URIs available for JSON embedding.")
