#!/usr/bin/env python3
"""
Applications of Exchange-Certified Optimization

Demonstrates real-world applications of the exchange constant theory:
1. Portfolio selection with certified near-optimality
2. Task assignment with quality guarantees
3. Sensor placement with coverage bounds
"""

import itertools
import random
from typing import Dict, FrozenSet, List

# ============================================================
# Application 1: Portfolio Selection
# ============================================================

def portfolio_selection():
    """Select r assets from n candidates to maximize a portfolio score.

    The portfolio score is non-additive (includes interaction terms),
    so exact optimality is not guaranteed by greedy. But the exchange
    constant certifies how far from optimal we can be.
    """
    print("=" * 60)
    print("APPLICATION 1: Portfolio Selection with Certified Bounds")
    print("=" * 60)

    n = 8  # Number of candidate assets
    r = 3  # Number to select

    # Asset returns
    returns = {i: random.uniform(0.02, 0.15) for i in range(n)}

    # Synergy matrix (interaction bonuses)
    synergy = {}
    for i in range(n):
        for j in range(i + 1, n):
            synergy[(i, j)] = random.uniform(-0.01, 0.03)

    def portfolio_score(B: FrozenSet[int]) -> float:
        """Portfolio score = sum of returns + sum of synergies."""
        total = sum(returns[i] for i in B)
        for i in B:
            for j in B:
                if i < j and (i, j) in synergy:
                    total += synergy[(i, j)]
        return total

    # Compute exchange constant
    bases = [frozenset(s) for s in itertools.combinations(range(n), r)]

    K = 0.0
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                min_gap = float('inf')
                for y in B2 - B1:
                    B1_new = (B1 - {x}) | {y}
                    B2_new = (B2 - {y}) | {x}
                    gap = portfolio_score(B1) + portfolio_score(B2) - \
                          portfolio_score(B1_new) - portfolio_score(B2_new)
                    min_gap = min(min_gap, gap)
                if min_gap != float('inf'):
                    K = max(K, min_gap)
    K = max(K, 0.0)

    # Local search
    start = frozenset(random.sample(range(n), r))
    current = start
    while True:
        best_val = portfolio_score(current)
        best_next = None
        for x in current:
            for y in frozenset(range(n)) - current:
                nb = (current - {x}) | {y}
                if portfolio_score(nb) > best_val:
                    best_val = portfolio_score(nb)
                    best_next = nb
        if best_next is None:
            break
        current = best_next

    # Global optimum
    best_global = max(bases, key=portfolio_score)
    global_val = portfolio_score(best_global)
    local_val = portfolio_score(current)

    print(f"\nAssets: {n} candidates, select {r}")
    print(f"Exchange constant K = {K:.6f}")
    print(f"\nLocal search result: {set(current)}")
    print(f"  Score: {local_val:.6f}")
    print(f"Global optimum: {set(best_global)}")
    print(f"  Score: {global_val:.6f}")
    print(f"\nActual gap: {global_val - local_val:.6f}")
    print(f"Certified bound: K * rank = {K * r:.6f}")
    gap_ok = global_val - local_val <= K * r + 1e-10
    print(f"Bound satisfied: {'✓' if gap_ok else '✗'}")
    print(f"\nInterpretation: The local search portfolio is guaranteed to be")
    print(f"within {K * r:.4f} of the best possible portfolio score.")


# ============================================================
# Application 2: Task Assignment
# ============================================================

def task_assignment():
    """Assign r workers to tasks from n candidates.

    Workers have individual skill levels, but also team compatibility
    scores (non-additive). Exchange constant certifies assignment quality.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Task Assignment with Quality Guarantee")
    print("=" * 60)

    n = 7
    r = 3

    # Individual skills
    skills = {i: random.uniform(50, 100) for i in range(n)}

    # Team compatibility (positive = good chemistry)
    compat = {}
    for i in range(n):
        for j in range(i + 1, n):
            compat[(i, j)] = random.uniform(-5, 15)

    def team_score(B: FrozenSet[int]) -> float:
        total = sum(skills[i] for i in B)
        for i in B:
            for j in B:
                if i < j:
                    total += compat.get((i, j), 0)
        return total

    bases = [frozenset(s) for s in itertools.combinations(range(n), r)]

    # Exchange constant
    K = 0.0
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                min_gap = float('inf')
                for y in B2 - B1:
                    B1n = (B1 - {x}) | {y}
                    B2n = (B2 - {y}) | {x}
                    gap = team_score(B1) + team_score(B2) - team_score(B1n) - team_score(B2n)
                    min_gap = min(min_gap, gap)
                if min_gap != float('inf'):
                    K = max(K, min_gap)
    K = max(K, 0.0)

    # Find local optimum
    current = frozenset(random.sample(range(n), r))
    while True:
        best_val = team_score(current)
        best_next = None
        for x in current:
            for y in frozenset(range(n)) - current:
                nb = (current - {x}) | {y}
                if team_score(nb) > best_val:
                    best_val = team_score(nb)
                    best_next = nb
        if best_next is None:
            break
        current = best_next

    best_global = max(bases, key=team_score)

    print(f"\nWorkers: {n}, Team size: {r}")
    print(f"Exchange constant K = {K:.2f}")
    print(f"\nLocal search team: {set(current)}")
    print(f"  Score: {team_score(current):.2f}")
    print(f"Optimal team: {set(best_global)}")
    print(f"  Score: {team_score(best_global):.2f}")
    print(f"\nCertified bound: within {K * r:.2f} of optimal")


# ============================================================
# Application 3: Exchange Constant Analysis
# ============================================================

def exchange_constant_analysis():
    """Analyze how exchange constants vary with problem structure."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Exchange Constant Scaling Analysis")
    print("=" * 60)

    print("\nHow does K scale with ground set size n and rank r?")
    print()

    for n in [4, 5, 6, 7]:
        for r in [2, 3]:
            if r >= n:
                continue

            bases = [frozenset(s) for s in itertools.combinations(range(n), r)]
            wt = {i: random.uniform(1, 10) for i in range(n)}

            def w_quad(B, wt=wt):
                return sum(wt[i] for i in B) ** 2

            K = 0.0
            for B1 in bases:
                for B2 in bases:
                    for x in B1 - B2:
                        min_gap = float('inf')
                        for y in B2 - B1:
                            B1n = (B1 - {x}) | {y}
                            B2n = (B2 - {y}) | {x}
                            gap = w_quad(B1) + w_quad(B2) - w_quad(B1n) - w_quad(B2n)
                            min_gap = min(min_gap, gap)
                        if min_gap != float('inf'):
                            K = max(K, min_gap)
            K = max(K, 0.0)

            print(f"n={n}, r={r}: K = {K:8.3f}, #bases = {len(bases):4d}, "
                  f"K/r = {K/r:6.3f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(123)
    portfolio_selection()
    task_assignment()
    exchange_constant_analysis()


#!/usr/bin/env python3
"""
Demo: Exchange Constants and Certified Optimization

This script demonstrates the core theorems from the exchange-certified
approximation theory by:
1. Generating random weighted matroid-like instances (uniform matroid bases)
2. Computing exchange-local optima via local search
3. Computing exact global optima by exhaustive enumeration
4. Estimating the exchange constant K
5. Testing whether the certified bound holds
6. Searching for counterexamples to the conjecture

The key theorem being tested:
    For any exchange-local maximum B and any feasible Y:
        w(Y) ≤ w(B) + K * |Y \ B|
    where K is the valuated exchange constant.
"""

import itertools
import random
import math
from typing import List, Tuple, Set, Dict, Optional

# ============================================================
# Core data structures
# ============================================================

class ExchangeFamily:
    """A base exchange family (uniform matroid) on ground set {0, ..., n-1}
    with bases of cardinality r."""

    def __init__(self, n: int, r: int):
        self.n = n
        self.r = r
        self.ground = set(range(n))
        # All r-element subsets are bases (uniform matroid)
        self.bases = [frozenset(s) for s in itertools.combinations(range(n), r)]

    def is_feasible(self, B: frozenset) -> bool:
        return len(B) == self.r and B.issubset(self.ground)

    def exchange_neighbors(self, B: frozenset) -> List[frozenset]:
        """All single-swap exchange neighbors of B."""
        neighbors = []
        for x in B:
            for y in self.ground - B:
                B_new = (B - {x}) | {y}
                if self.is_feasible(B_new):
                    neighbors.append(frozenset(B_new))
        return neighbors


def sdiff_card(B1: frozenset, B2: frozenset) -> int:
    """Symmetric difference cardinality (one side): |B1 \ B2|."""
    return len(B1 - B2)


# ============================================================
# Weight functions
# ============================================================

def additive_weight(wt: Dict[int, float], B: frozenset) -> float:
    """Additive weight: w(B) = sum of wt[x] for x in B."""
    return sum(wt[x] for x in B)


def quadratic_weight(wt: Dict[int, float], B: frozenset) -> float:
    """Quadratic (non-additive) weight: w(B) = (sum wt[x])^2."""
    return sum(wt[x] for x in B) ** 2


def max_weight(wt: Dict[int, float], B: frozenset) -> float:
    """Max-element weight: w(B) = max wt[x] for x in B."""
    return max(wt[x] for x in B)


# ============================================================
# Optimization algorithms
# ============================================================

def exchange_local_search(family: ExchangeFamily, w, start: frozenset) -> frozenset:
    """Greedy exchange ascent: repeatedly swap to improve w until stuck."""
    current = start
    improved = True
    while improved:
        improved = False
        best_val = w(current)
        best_neighbor = current
        for neighbor in family.exchange_neighbors(current):
            val = w(neighbor)
            if val > best_val:
                best_val = val
                best_neighbor = neighbor
                improved = True
        current = best_neighbor
    return current


def global_optimum(family: ExchangeFamily, w) -> Tuple[frozenset, float]:
    """Find global optimum by exhaustive search."""
    best = None
    best_val = -float('inf')
    for B in family.bases:
        val = w(B)
        if val > best_val:
            best_val = val
            best = B
    return best, best_val


def is_exchange_local_max(family: ExchangeFamily, w, B: frozenset) -> bool:
    """Check if B is an exchange-local maximum of w."""
    w_B = w(B)
    for neighbor in family.exchange_neighbors(B):
        if w(neighbor) > w_B:
            return False
    return True


# ============================================================
# Exchange constant computation
# ============================================================

def compute_exchange_constant(family: ExchangeFamily, w) -> float:
    """Compute the valuated exchange constant K.

    K = max over all pairs (B1, B2) of feasible sets, over all x in B1\\B2,
    of the minimum over y in B2\\B1 of:
        w(B1) + w(B2) - w(insert y (B1\\x)) - w(insert x (B2\\y))

    This is the maximum violation of the exact valuated exchange axiom.
    """
    K = 0.0
    for B1 in family.bases:
        for B2 in family.bases:
            for x in B1 - B2:
                best_gap = float('inf')
                for y in B2 - B1:
                    B1_swap = (B1 - {x}) | {y}
                    B2_swap = (B2 - {y}) | {x}
                    gap = w(B1) + w(B2) - w(B1_swap) - w(B2_swap)
                    best_gap = min(best_gap, gap)
                if best_gap != float('inf'):
                    K = max(K, best_gap)
    return K


def verify_gap_bound(family: ExchangeFamily, w, K: float) -> Tuple[bool, Optional[dict]]:
    """Verify that for every exchange-local max B and every feasible Y:
        w(Y) ≤ w(B) + K * |Y \\ B|

    Returns (True, None) if the bound holds, or (False, counterexample) if not.
    """
    for B in family.bases:
        if not is_exchange_local_max(family, w, B):
            continue
        w_B = w(B)
        for Y in family.bases:
            w_Y = w(Y)
            d = sdiff_card(Y, B)
            bound = w_B + K * d
            if w_Y > bound + 1e-10:  # numerical tolerance
                return False, {
                    'B': B, 'Y': Y, 'w_B': w_B, 'w_Y': w_Y,
                    'K': K, 'distance': d, 'bound': bound,
                    'violation': w_Y - bound
                }
    return True, None


# ============================================================
# Demo 1: Additive weights (K = 0, exact optimality)
# ============================================================

def demo_additive():
    print("=" * 70)
    print("DEMO 1: Additive Weights (Exact Optimality, K = 0)")
    print("=" * 70)

    n, r = 6, 3
    family = ExchangeFamily(n, r)
    wt = {i: random.uniform(1, 10) for i in range(n)}
    w = lambda B: additive_weight(wt, B)

    print(f"Ground set: {{0, ..., {n-1}}}, rank: {r}")
    print(f"Element weights: {', '.join(f'{i}: {wt[i]:.2f}' for i in range(n))}")
    print(f"Number of bases: {len(family.bases)}")

    # Compute exchange constant
    K = compute_exchange_constant(family, w)
    print(f"\nExchange constant K = {K:.6f}")
    assert abs(K) < 1e-10, "Additive weights should have K = 0!"
    print("✓ Confirmed: K = 0 for additive weights (exact valuated exchange)")

    # Find local and global optima
    start = frozenset(random.sample(range(n), r))
    local_opt = exchange_local_search(family, w, start)
    global_opt, global_val = global_optimum(family, w)

    print(f"\nLocal optimum: {set(local_opt)}, w = {w(local_opt):.4f}")
    print(f"Global optimum: {set(global_opt)}, w = {global_val:.4f}")
    print(f"Gap: {global_val - w(local_opt):.6f}")

    if abs(w(local_opt) - global_val) < 1e-10:
        print("✓ Local optimum IS global optimum (as guaranteed by K = 0 theorem)")
    else:
        print("✗ UNEXPECTED: Local optimum differs from global optimum")

    # Verify gap bound
    verified, counter = verify_gap_bound(family, w, K)
    print(f"\nGap bound verification: {'✓ PASSED' if verified else '✗ FAILED'}")
    if counter:
        print(f"  Counterexample: {counter}")


# ============================================================
# Demo 2: Non-additive weights (K > 0, approximate optimality)
# ============================================================

def demo_quadratic():
    print("\n" + "=" * 70)
    print("DEMO 2: Quadratic Weights (Approximate Optimality, K > 0)")
    print("=" * 70)

    n, r = 5, 2
    family = ExchangeFamily(n, r)
    wt = {i: random.uniform(1, 5) for i in range(n)}
    w = lambda B: quadratic_weight(wt, B)

    print(f"Ground set: {{0, ..., {n-1}}}, rank: {r}")
    print(f"Element weights: {', '.join(f'{i}: {wt[i]:.2f}' for i in range(n))}")
    print(f"Weight function: w(B) = (Σ wt(x))²  (non-additive)")

    K = compute_exchange_constant(family, w)
    print(f"\nExchange constant K = {K:.4f}")

    # Find all local optima
    local_optima = []
    for B in family.bases:
        if is_exchange_local_max(family, w, B):
            local_optima.append(B)

    global_opt, global_val = global_optimum(family, w)

    print(f"\nNumber of exchange-local maxima: {len(local_optima)}")
    for B in local_optima:
        gap = global_val - w(B)
        d = sdiff_card(global_opt, B)
        bound = K * d
        print(f"  B = {str(set(B)):20s}, w(B) = {w(B):8.2f}, "
              f"gap = {gap:6.2f}, K*d = {bound:6.2f}, "
              f"{'✓' if gap <= bound + 1e-10 else '✗'}")

    print(f"\nGlobal optimum: {set(global_opt)}, w = {global_val:.2f}")

    verified, counter = verify_gap_bound(family, w, K)
    print(f"Gap bound verification: {'✓ PASSED' if verified else '✗ FAILED'}")


# ============================================================
# Demo 3: Conjecture testing on random instances
# ============================================================

def demo_conjecture_testing():
    print("\n" + "=" * 70)
    print("DEMO 3: Conjecture Testing — Sharp Exchange Approximation")
    print("=" * 70)

    print("\nConjecture: For every exchange-local max B,")
    print("  w(Y) ≤ w(B) + K * rank  for all feasible Y")
    print("\nThis is a stronger bound than K * |Y \\ B| since |Y \\ B| ≤ rank.")
    print()

    num_instances = 100
    num_passed = 0
    worst_ratio = 0.0

    for trial in range(num_instances):
        n = random.randint(4, 7)
        r = random.randint(2, min(n - 1, 4))
        family = ExchangeFamily(n, r)

        # Random non-additive weight
        wt = {i: random.uniform(0.5, 5) for i in range(n)}
        weight_type = random.choice(['quadratic', 'max', 'mixed'])
        if weight_type == 'quadratic':
            w = lambda B, wt=wt: quadratic_weight(wt, B)
        elif weight_type == 'max':
            w = lambda B, wt=wt: max_weight(wt, B)
        else:
            alpha = random.uniform(0.3, 0.7)
            w = lambda B, wt=wt, a=alpha: (
                a * additive_weight(wt, B) + (1 - a) * quadratic_weight(wt, B)
            )

        K = compute_exchange_constant(family, w)
        _, global_val = global_optimum(family, w)

        passed = True
        for B in family.bases:
            if not is_exchange_local_max(family, w, B):
                continue
            gap = global_val - w(B)
            conj_bound = K * r
            if gap > conj_bound + 1e-10:
                passed = False
            if conj_bound > 0:
                worst_ratio = max(worst_ratio, gap / conj_bound)

        if passed:
            num_passed += 1

    print(f"Tested {num_instances} random instances")
    print(f"Conjecture held: {num_passed}/{num_instances} "
          f"({100*num_passed/num_instances:.1f}%)")
    print(f"Worst gap/bound ratio: {worst_ratio:.4f}")
    if num_passed == num_instances:
        print("✓ No counterexample found!")
    else:
        print(f"✗ {num_instances - num_passed} counterexample(s) found")


# ============================================================
# Demo 4: Exchange descent visualization
# ============================================================

def demo_exchange_descent():
    print("\n" + "=" * 70)
    print("DEMO 4: Exchange Descent Algorithm Trace")
    print("=" * 70)

    n, r = 6, 3
    family = ExchangeFamily(n, r)
    wt = {i: i + 1.0 for i in range(n)}  # weights 1, 2, ..., 6
    w = lambda B: additive_weight(wt, B)

    # Start from worst basis
    start = frozenset(range(r))  # {0, 1, 2}
    print(f"Weight function: w(B) = Σ wt(x), with wt(i) = i + 1")
    print(f"Starting basis: {set(start)}, w = {w(start):.1f}")

    current = start
    step = 0
    while True:
        best_neighbor = None
        best_val = w(current)
        for neighbor in family.exchange_neighbors(current):
            val = w(neighbor)
            if val > best_val:
                best_val = val
                best_neighbor = neighbor

        if best_neighbor is None:
            break

        step += 1
        print(f"  Step {step}: {set(current)} → {set(best_neighbor)}, "
              f"w: {w(current):.1f} → {w(best_neighbor):.1f} "
              f"(+{w(best_neighbor) - w(current):.1f})")
        current = best_neighbor

    print(f"\nTerminated at: {set(current)}, w = {w(current):.1f}")
    _, global_val = global_optimum(family, w)
    print(f"Global optimum: w = {global_val:.1f}")
    print(f"Steps taken: {step}")
    print(f"Maximum possible: {len(family.bases)} bases in family")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    print("Exchange Constants and Certified Optimization — Demo")
    print("=" * 70)
    print()

    demo_additive()
    demo_quadratic()
    demo_conjecture_testing()
    demo_exchange_descent()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Exchange Landscape and Certified Bounds

Visualizes the exchange graph of a small matroid, showing:
- All bases as nodes, colored by weight
- Exchange edges connecting bases that differ by one swap
- Exchange-local maxima highlighted
- Certified approximation bounds as annotations

This visualization makes tangible how the exchange constant K
controls the "roughness" of the optimization landscape.
"""

import itertools
import random
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable


def compute_exchange_graph(n, r, weight_fn):
    """Compute the exchange graph: nodes = bases, edges = single swaps."""
    bases = [frozenset(s) for s in itertools.combinations(range(n), r)]
    weights = {B: weight_fn(B) for B in bases}

    edges = []
    for i, B1 in enumerate(bases):
        for j, B2 in enumerate(bases):
            if i < j and len(B1 - B2) == 1:  # single swap
                edges.append((i, j))

    # Find local maxima
    local_maxima = set()
    for i, B in enumerate(bases):
        is_max = True
        for j, B2 in enumerate(bases):
            if (min(i,j), max(i,j)) in [(e[0],e[1]) for e in edges] or \
               (min(j,i), max(j,i)) in [(e[0],e[1]) for e in edges]:
                if i != j and len(B - B2) == 1 and weights[B2] > weights[B]:
                    is_max = False
                    break
        if is_max:
            local_maxima.add(i)

    return bases, weights, edges, local_maxima


def compute_exchange_constant(bases, weight_fn):
    """Compute K for the given bases and weight function."""
    K = 0.0
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                min_gap = float('inf')
                for y in B2 - B1:
                    B1n = (B1 - {x}) | {y}
                    B2n = (B2 - {y}) | {x}
                    gap = weight_fn(B1) + weight_fn(B2) - weight_fn(B1n) - weight_fn(B2n)
                    min_gap = min(min_gap, gap)
                if min_gap != float('inf'):
                    K = max(K, min_gap)
    return max(K, 0.0)


def spring_layout(n_nodes, edges, iterations=200):
    """Simple spring layout for graph visualization."""
    pos = np.random.RandomState(42).randn(n_nodes, 2)

    for _ in range(iterations):
        # Repulsive forces
        forces = np.zeros_like(pos)
        for i in range(n_nodes):
            for j in range(n_nodes):
                if i != j:
                    diff = pos[i] - pos[j]
                    dist = max(np.linalg.norm(diff), 0.01)
                    forces[i] += diff / (dist ** 2) * 0.5

        # Attractive forces along edges
        for i, j in edges:
            diff = pos[j] - pos[i]
            dist = np.linalg.norm(diff)
            forces[i] += diff * dist * 0.01
            forces[j] -= diff * dist * 0.01

        pos += forces * 0.05
        # Center
        pos -= pos.mean(axis=0)

    return pos


def make_figure():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    random.seed(42)
    n, r = 5, 2

    wt = {0: 1.0, 1: 3.0, 2: 5.0, 3: 7.0, 4: 9.0}

    # Panel 1: Additive weight (K = 0)
    def w_add(B):
        return sum(wt[x] for x in B)

    bases, weights, edges, local_max = compute_exchange_graph(n, r, w_add)
    K_add = compute_exchange_constant(bases, w_add)
    pos = spring_layout(len(bases), edges)

    w_vals = [weights[B] for B in bases]
    norm = Normalize(vmin=min(w_vals), vmax=max(w_vals))
    cmap = plt.cm.YlOrRd

    ax = axes[0]
    ax.set_title(f'Additive Weight (K = {K_add:.1f})\nLocal opt = Global opt', fontsize=13, fontweight='bold')

    for i, j in edges:
        ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                'gray', alpha=0.3, linewidth=1)

    for i, B in enumerate(bases):
        color = cmap(norm(weights[B]))
        size = 400 if i in local_max else 200
        marker = '*' if i in local_max else 'o'
        edgecolor = 'red' if i in local_max else 'black'
        lw = 3 if i in local_max else 1
        ax.scatter(pos[i, 0], pos[i, 1], c=[color], s=size,
                   marker=marker, edgecolors=edgecolor, linewidth=lw, zorder=5)
        label = '{' + ','.join(str(x) for x in sorted(B)) + '}'
        ax.annotate(f'{label}\n{weights[B]:.0f}', (pos[i, 0], pos[i, 1]),
                    textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=7)

    ax.set_xlim(pos[:, 0].min() - 0.5, pos[:, 0].max() + 0.5)
    ax.set_ylim(pos[:, 1].min() - 0.8, pos[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Quadratic weight (K > 0)
    def w_quad(B):
        return sum(wt[x] for x in B) ** 2

    bases2, weights2, edges2, local_max2 = compute_exchange_graph(n, r, w_quad)
    K_quad = compute_exchange_constant(bases2, w_quad)
    pos2 = spring_layout(len(bases2), edges2)

    w_vals2 = [weights2[B] for B in bases2]
    norm2 = Normalize(vmin=min(w_vals2), vmax=max(w_vals2))

    ax = axes[1]
    ax.set_title(f'Quadratic Weight (K = {K_quad:.1f})\nCertified bound: gap ≤ K × distance', fontsize=13, fontweight='bold')

    for i, j in edges2:
        ax.plot([pos2[i, 0], pos2[j, 0]], [pos2[i, 1], pos2[j, 1]],
                'gray', alpha=0.3, linewidth=1)

    for i, B in enumerate(bases2):
        color = cmap(norm2(weights2[B]))
        size = 400 if i in local_max2 else 200
        marker = '*' if i in local_max2 else 'o'
        edgecolor = 'red' if i in local_max2 else 'black'
        lw = 3 if i in local_max2 else 1
        ax.scatter(pos2[i, 0], pos2[i, 1], c=[color], s=size,
                   marker=marker, edgecolors=edgecolor, linewidth=lw, zorder=5)
        label = '{' + ','.join(str(x) for x in sorted(B)) + '}'
        ax.annotate(f'{label}\n{weights2[B]:.0f}', (pos2[i, 0], pos2[i, 1]),
                    textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=7)

    ax.set_xlim(pos2[:, 0].min() - 0.5, pos2[:, 0].max() + 0.5)
    ax.set_ylim(pos2[:, 1].min() - 0.8, pos2[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    star = mpatches.Patch(color='red', label='Exchange-local maximum (★)')
    circle = mpatches.Patch(color='gray', label='Other bases (○)')
    fig.legend(handles=[star, circle], loc='lower center', ncol=2,
              fontsize=11, frameon=False)

    fig.suptitle('Exchange Landscape: How K Controls Optimization Quality',
                fontsize=15, fontweight='bold', y=0.98)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('viz_exchange_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_exchange_landscape.png")


if __name__ == "__main__":
    make_figure()
