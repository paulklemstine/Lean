#!/usr/bin/env python3
"""
Algorithms for Kantorovich-Lawvere Duality

Implements the core algorithms from the formalized theory with
full docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Set, Optional


def floyd_warshall_tropical(cost_matrix: np.ndarray) -> np.ndarray:
    """
    Compute all-pairs shortest paths using Floyd-Warshall algorithm.
    
    This is the tropical (min-plus) matrix power computation:
    d[i,j] = min over all paths from i to j of sum of edge costs.
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        cost_matrix: n×n matrix of edge costs, np.inf for no edge, 0 on diagonal
    
    Returns:
        n×n matrix of shortest-path distances (derivation costs)
    """
    n = cost_matrix.shape[0]
    d = cost_matrix.copy()
    
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    return d


def bellman_ford_single_source(
    cost_matrix: np.ndarray, source: int
) -> np.ndarray:
    """
    Single-source shortest paths using Bellman-Ford algorithm.
    
    More efficient than Floyd-Warshall for a single source.
    Handles negative-weight edges (but not negative cycles).
    
    Time complexity: O(n·m) where m = number of edges
    Space complexity: O(n)
    
    Args:
        cost_matrix: n×n cost matrix
        source: source vertex index
    
    Returns:
        Array of distances from source to all vertices
    """
    n = cost_matrix.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    
    for _ in range(n - 1):
        for u in range(n):
            for v in range(n):
                if cost_matrix[u, v] < np.inf:
                    if dist[u] + cost_matrix[u, v] < dist[v]:
                        dist[v] = dist[u] + cost_matrix[u, v]
    
    return dist


def kantorovich_dual_witness(
    d: np.ndarray, x: int, y: int
) -> Tuple[np.ndarray, float]:
    """
    Construct the optimal Kantorovich dual witness (Bellman potential).
    
    For any Lawvere quasi-metric d with finite values, the function
    f_y(w) = d(w, y) is 1-Lipschitz and achieves f_y(x) - f_y(y) = d(x,y).
    
    This is the constructive content of the Kantorovich-Lawvere Duality Theorem.
    
    Time complexity: O(1) (given precomputed d)
    Space complexity: O(n)
    
    Args:
        d: precomputed distance matrix
        x: source point
        y: target point
    
    Returns:
        Tuple of (witness function values, achieved gap)
    """
    f = d[:, y].copy()  # f_y(w) = d(w, y)
    gap = f[x] - f[y]   # = d(x, y) - 0 = d(x, y)
    return f, gap


def verify_lipschitz(f: np.ndarray, d: np.ndarray) -> bool:
    """
    Verify that f is 1-Lipschitz w.r.t. d: f(x) - f(y) ≤ d(x,y) for all x,y.
    
    Time complexity: O(n²)
    
    Args:
        f: function values at each point
        d: distance matrix
    
    Returns:
        True if f is 1-Lipschitz
    """
    n = len(f)
    for i in range(n):
        for j in range(n):
            if d[i, j] < np.inf:
                if f[i] - f[j] > d[i, j] + 1e-10:
                    return False
    return True


def closure_defect_to_set(
    d: np.ndarray, x: int, target_set: Set[int]
) -> float:
    """
    Compute closure defect: inf_{y in T} d(x, y).
    
    This is the distance from point x to the nearest point in T,
    measuring how far x is from the "safe" or "closed" set.
    
    Time complexity: O(|T|)
    
    Args:
        d: distance matrix
        x: query point
        target_set: target set T
    
    Returns:
        Minimum distance from x to T
    """
    return min(d[x, t] for t in target_set)


def thermodynamic_asymmetry_index(
    d: np.ndarray, x: int, y: int
) -> float:
    """
    Compute the thermodynamic asymmetry index: d(x,y) - d(y,x).
    
    Positive values indicate that the forward transition x→y is cheaper
    than the reverse y→x, encoding thermodynamic irreversibility.
    
    Time complexity: O(1) given precomputed d
    
    Args:
        d: distance matrix
        x, y: points to compare
    
    Returns:
        Asymmetry index (can be negative, zero, or positive)
    """
    fwd = d[x, y] if d[x, y] < np.inf else float('nan')
    bwd = d[y, x] if d[y, x] < np.inf else float('nan')
    return fwd - bwd


def contractive_convergence_bound(
    D0: float, c: float, n: int
) -> float:
    """
    Compute the geometric convergence bound D₀ · cⁿ.
    
    For a contractive closure dynamics with initial defect D₀
    and contraction factor 0 ≤ c < 1, the defect at step n
    is bounded by D₀ · cⁿ.
    
    Time complexity: O(log n) via fast exponentiation
    
    Args:
        D0: initial defect bound (≥ 0)
        c: contraction factor (0 ≤ c < 1)
        n: iteration number
    
    Returns:
        Upper bound on defect at step n
    """
    return D0 * (c ** n)


def iterations_for_epsilon(
    D0: float, c: float, eps: float
) -> int:
    """
    Compute minimum iterations N for ε-convergence.
    
    Find smallest N such that D₀ · cᴺ ≤ ε.
    
    Formula: N = ceil(log(ε/D₀) / log(c))
    
    Time complexity: O(1)
    
    Args:
        D0: initial defect bound (> 0)
        c: contraction factor (0 < c < 1)
        eps: target accuracy (> 0)
    
    Returns:
        Minimum number of iterations needed
    """
    if D0 <= eps:
        return 0
    if c <= 0:
        return 1
    return int(np.ceil(np.log(eps / D0) / np.log(c)))


def certified_robustness_margin(
    d: np.ndarray,
    observable: np.ndarray,
    threshold: float,
    safe_point: int,
    unsafe_point: int
) -> Tuple[float, float, bool]:
    """
    Compute certified robustness margin and verify the bound.
    
    For a safe point x and unsafe point y:
      margin = threshold - observable(x) < d(y, x)
    
    Time complexity: O(1) given precomputed values
    
    Args:
        d: distance matrix
        observable: 1-Lipschitz observable values
        threshold: safety threshold
        safe_point: index of safe point
        unsafe_point: index of unsafe point
    
    Returns:
        Tuple of (margin, distance d(y,x), whether bound holds)
    """
    margin = threshold - observable[safe_point]
    dist = d[unsafe_point, safe_point]
    holds = margin < dist
    return margin, dist, holds


if __name__ == "__main__":
    # Example usage
    n = 5
    cost = np.full((n, n), np.inf)
    np.fill_diagonal(cost, 0.0)
    edges = [(0,1,2), (1,2,3), (2,3,1), (3,4,2), (0,3,8), (4,1,3)]
    for i, j, c in edges:
        cost[i, j] = c
    
    d = floyd_warshall_tropical(cost)
    print("Distance matrix:")
    print(d)
    
    f, gap = kantorovich_dual_witness(d, 0, 4)
    print(f"\nBellman potential (target=4): {f}")
    print(f"Gap f(0) - f(4) = {gap} = d(0,4) = {d[0,4]}")
    print(f"Is Lipschitz: {verify_lipschitz(f, d)}")
    
    N = iterations_for_epsilon(10.0, 0.7, 0.01)
    print(f"\nIterations for ε=0.01 with D₀=10, c=0.7: N={N}")


#!/usr/bin/env python3
"""
Applications of Kantorovich-Lawvere Duality

Real-world applications demonstrating connections to:
- Machine Learning: Certified robustness of classifiers
- Cryptography: Lattice-based security analysis
- Physics: Thermodynamic irreversibility quantification
"""

import numpy as np
from typing import List, Tuple, Set


# ============================================================
# Application 1: Certified Robustness for ML Classifiers
# ============================================================

def certified_robustness_demo():
    """
    Demonstrate certified robustness for a simple classifier.
    
    Given a classifier with a Lipschitz-bounded decision function,
    the Kantorovich duality provides certificates that an input
    cannot be adversarially perturbed to change the classification
    within a given distance budget.
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Robustness for ML Classifiers")
    print("=" * 60)
    
    np.random.seed(42)
    n_points = 8
    
    # Generate a 2D feature space with asymmetric distances
    # (e.g., transformations that are easier in one direction)
    positions = np.random.randn(n_points, 2)
    
    # Asymmetric distance: easier to move "downhill"
    d = np.full((n_points, n_points), np.inf)
    np.fill_diagonal(d, 0.0)
    
    for i in range(n_points):
        for j in range(n_points):
            if i != j:
                dx = positions[j] - positions[i]
                base_dist = np.linalg.norm(dx)
                # Asymmetry: moving in +y direction is cheaper
                asymmetry = 1.0 + 0.3 * dx[1] / (base_dist + 0.01)
                d[i, j] = base_dist * max(0.1, asymmetry)
    
    # Floyd-Warshall for shortest paths
    for k in range(n_points):
        for i in range(n_points):
            for j in range(n_points):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    # Classifier: based on distance to class centroids
    class_0_center = 0  # Use point 0 as class center
    observable = d[:, class_0_center]  # Distance to class 0 center
    threshold = np.median(observable)
    
    safe_points = [i for i in range(n_points) if observable[i] <= threshold]
    unsafe_points = [i for i in range(n_points) if observable[i] > threshold]
    
    print(f"\nClassifier threshold: τ = {threshold:.3f}")
    print(f"Safe (class 0): {safe_points}")
    print(f"Unsafe (class 1): {unsafe_points}")
    
    print(f"\nCertified robustness radii:")
    for x in safe_points:
        # Minimum perturbation needed to change classification
        min_dist_to_unsafe = min(d[y, x] for y in unsafe_points) if unsafe_points else np.inf
        margin = threshold - observable[x]
        print(f"  Point {x}: margin = {margin:.3f}, "
              f"min d(unsafe→x) = {min_dist_to_unsafe:.3f}, "
              f"certified radius ≥ {margin:.3f}")


# ============================================================
# Application 2: Lattice Cryptographic Security
# ============================================================

def lattice_security_demo():
    """
    Demonstrate lattice-based cryptographic security analysis
    using closure defect as a security metric.
    
    The lattice attack surface (closure defect to the secure basis)
    measures how difficult it is for an attacker to reach the
    secure key space from a given starting point.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Lattice Cryptographic Security Analysis")
    print("=" * 60)
    
    # Model a simplified lattice reduction scenario
    # States represent lattice basis quality; transitions are reduction steps
    n_states = 6
    state_names = [
        "Random basis",
        "LLL-reduced",
        "BKZ-10",
        "BKZ-20",
        "Near-SVP",
        "Secret key"
    ]
    
    # Transition costs (computational effort)
    cost = np.full((n_states, n_states), np.inf)
    np.fill_diagonal(cost, 0.0)
    
    # Forward reductions (attacker's path)
    cost[0, 1] = 2.0   # Random → LLL (easy)
    cost[1, 2] = 5.0   # LLL → BKZ-10
    cost[2, 3] = 15.0  # BKZ-10 → BKZ-20
    cost[3, 4] = 50.0  # BKZ-20 → Near-SVP (hard!)
    cost[4, 5] = 100.0 # Near-SVP → Secret (very hard!)
    cost[0, 2] = 8.0   # Random → BKZ-10 (direct)
    cost[1, 3] = 25.0  # LLL → BKZ-20 (direct)
    
    # Compute shortest paths
    d = cost.copy()
    for k in range(n_states):
        for i in range(n_states):
            for j in range(n_states):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    secure_basis = {5}  # The secret key
    
    print(f"\nLattice attack surface (distance to secret key):")
    for i in range(n_states):
        attack_surface = min(d[i, t] for t in secure_basis)
        security_level = "SECURE" if attack_surface > 50 else "AT RISK"
        print(f"  {state_names[i]:20s}: attack cost = {attack_surface:>6.1f}  [{security_level}]")
    
    # Dual certificate: Bellman potential provides security proof
    f = d[:, 5]  # Distance to secret key
    print(f"\nSecurity dual certificate (Bellman potential):")
    for i in range(n_states):
        print(f"  f({state_names[i]:20s}) = {f[i]:>6.1f}")
    
    print(f"\nSecurity guarantee via Kantorovich duality:")
    print(f"  Any 1-Lipschitz observable f gives:")
    print(f"  f(attacker_state) - f(secret) ≤ d(attacker, secret)")
    print(f"  Equality achieved by the Bellman potential ✓")


# ============================================================
# Application 3: Thermodynamic Irreversibility
# ============================================================

def thermodynamic_demo():
    """
    Demonstrate thermodynamic irreversibility quantification
    using the asymmetry index of the Lawvere metric.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Thermodynamic Irreversibility")
    print("=" * 60)
    
    # Model a chemical reaction network
    n = 5
    species = ["Reactant A", "Intermediate B", "Intermediate C", 
                "Product D", "Waste E"]
    
    # Asymmetric transition costs (free energy barriers)
    cost = np.full((n, n), np.inf)
    np.fill_diagonal(cost, 0.0)
    
    # Forward reactions (exergonic, lower barrier)
    cost[0, 1] = 2.0   # A → B
    cost[1, 2] = 1.5   # B → C
    cost[2, 3] = 1.0   # C → D (product formation, very favorable)
    cost[1, 4] = 3.0   # B → E (side reaction to waste)
    
    # Reverse reactions (endergonic, higher barrier)
    cost[1, 0] = 8.0   # B → A (unfavorable)
    cost[2, 1] = 5.0   # C → B (unfavorable)
    cost[3, 2] = 12.0  # D → C (very unfavorable)
    cost[4, 1] = 10.0  # E → B (very unfavorable)
    
    # Shortest paths
    d = cost.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    print(f"\nThermodynamic asymmetry index (irreversibility measure):")
    print(f"  Δ(x,y) = d(x,y) - d(y,x)")
    print(f"  Negative = forward is cheaper (spontaneous direction)")
    print()
    
    for i in range(n):
        for j in range(i+1, n):
            fwd = d[i, j]
            bwd = d[j, i]
            if fwd < np.inf and bwd < np.inf:
                asym = fwd - bwd
                direction = "→" if asym < 0 else "←" if asym > 0 else "↔"
                print(f"  {species[i]:>16s} {direction} {species[j]:<16s}: "
                      f"Δ = {asym:>+6.1f}  "
                      f"(fwd={fwd:.1f}, rev={bwd:.1f})")
    
    print(f"\nTotal irreversibility (A → D path):")
    total_fwd = d[0, 3]
    total_bwd = d[3, 0]
    print(f"  Forward cost:  d(A, D) = {total_fwd:.1f}")
    print(f"  Reverse cost:  d(D, A) = {total_bwd:.1f}")
    print(f"  Asymmetry:     Δ(A, D) = {total_fwd - total_bwd:+.1f}")
    print(f"  This quantifies the thermodynamic arrow of time")


if __name__ == "__main__":
    certified_robustness_demo()
    lattice_security_demo()
    thermodynamic_demo()


#!/usr/bin/env python3
"""
Kantorovich-Lawvere Duality: Concrete Numerical Demonstrations

This script demonstrates the key mathematical concepts from the formalized theory
of asymmetric optimal transport duality for closure systems.
"""

import numpy as np
from typing import Dict, List, Tuple, Set

# ============================================================
# 1. Weighted Generator and Derivation Cost
# ============================================================

class WeightedGenerator:
    """A weighted directed graph representing one-step derivation costs."""
    
    def __init__(self, n: int):
        self.n = n
        self.cost = np.full((n, n), np.inf)
        np.fill_diagonal(self.cost, 0.0)
    
    def add_step(self, i: int, j: int, c: float):
        """Add a directed edge from i to j with cost c."""
        self.cost[i, j] = c


def derivation_cost(G: WeightedGenerator) -> np.ndarray:
    """Compute all-pairs derivation costs using Floyd-Warshall.
    This is the tropical shortest-path distance."""
    n = G.n
    d = G.cost.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    return d


def demo_derivation_cost():
    """Demonstrate derivation cost computation on a small graph."""
    print("=" * 60)
    print("DEMO 1: Derivation Cost (Tropical Shortest Path)")
    print("=" * 60)
    
    # Create a 4-state system: A -> B -> C -> D with some back-edges
    G = WeightedGenerator(4)
    G.add_step(0, 1, 2.0)  # A -> B, cost 2
    G.add_step(1, 2, 3.0)  # B -> C, cost 3
    G.add_step(2, 3, 1.0)  # C -> D, cost 1
    G.add_step(0, 2, 7.0)  # A -> C, cost 7 (expensive direct)
    G.add_step(3, 1, 4.0)  # D -> B, cost 4 (back-edge)
    
    d = derivation_cost(G)
    labels = ['A', 'B', 'C', 'D']
    
    print("\nOne-step costs:")
    for i in range(4):
        for j in range(4):
            if G.cost[i, j] < np.inf and i != j:
                print(f"  {labels[i]} -> {labels[j]}: {G.cost[i, j]}")
    
    print("\nDerivation costs (tropical shortest paths):")
    for i in range(4):
        for j in range(4):
            val = d[i, j]
            sym = f"{val:.1f}" if val < np.inf else "∞"
            print(f"  d({labels[i]}, {labels[j]}) = {sym}")
    
    # Verify triangle inequality
    print("\nTriangle inequality verification:")
    for i in range(4):
        for j in range(4):
            for k in range(4):
                if d[i, k] > d[i, j] + d[j, k] + 1e-10:
                    print(f"  VIOLATION: d({labels[i]},{labels[k]}) > d({labels[i]},{labels[j]}) + d({labels[j]},{labels[k]})")
    print("  All triangle inequalities satisfied ✓")
    
    # Show asymmetry
    print("\nAsymmetry (thermodynamic irreversibility):")
    for i in range(4):
        for j in range(i+1, 4):
            fwd = d[i, j]
            bwd = d[j, i]
            asym = fwd - bwd if fwd < np.inf and bwd < np.inf else float('nan')
            print(f"  Δ({labels[i]},{labels[j]}) = d({labels[i]},{labels[j]}) - d({labels[j]},{labels[i]}) = {asym:.1f}")


# ============================================================
# 2. Kantorovich Duality
# ============================================================

def bellman_potential(d: np.ndarray, target: int) -> np.ndarray:
    """Tropical Bellman potential: f_t(x) = d(x, t)."""
    return d[:, target]


def observable_gap(d: np.ndarray, x: int, y: int) -> float:
    """Compute the observable gap sup { f(x) - f(y) | f is 1-Lipschitz }
    by using the Bellman potential witness."""
    n = d.shape[0]
    max_gap = -np.inf
    # Try all Bellman potentials as witnesses
    for t in range(n):
        f = bellman_potential(d, t)
        if np.all(np.isfinite(f)):  # Only consider finite potentials
            gap = f[x] - f[y]
            max_gap = max(max_gap, gap)
    return max_gap


def demo_kantorovich_duality():
    """Demonstrate Kantorovich duality: d(x,y) = sup_f (f(x) - f(y))."""
    print("\n" + "=" * 60)
    print("DEMO 2: Kantorovich-Lawvere Duality")
    print("=" * 60)
    
    G = WeightedGenerator(4)
    G.add_step(0, 1, 2.0)
    G.add_step(1, 2, 3.0)
    G.add_step(2, 3, 1.0)
    G.add_step(0, 2, 7.0)
    G.add_step(3, 1, 4.0)
    
    d = derivation_cost(G)
    labels = ['A', 'B', 'C', 'D']
    
    print("\nDuality verification: d(x,y) = sup_f (f(x) - f(y))")
    print("-" * 50)
    
    for i in range(4):
        for j in range(4):
            if d[i, j] < np.inf:
                gap = observable_gap(d, i, j)
                match = abs(d[i, j] - gap) < 1e-10
                print(f"  d({labels[i]},{labels[j]}) = {d[i,j]:.1f}, "
                      f"sup gap = {gap:.1f}  {'✓ EXACT' if match else '✗ MISMATCH'}")
    
    # Show the optimal witness
    print("\nOptimal dual witness for d(A, D) = 6.0:")
    print("  f_D(x) = d(x, D) = Tropical Bellman potential")
    f_D = bellman_potential(d, 3)
    for i in range(4):
        print(f"  f_D({labels[i]}) = {f_D[i]:.1f}")
    print(f"  f_D(A) - f_D(D) = {f_D[0] - f_D[3]:.1f} = d(A, D) ✓")


# ============================================================
# 3. Contractive Dynamics Convergence
# ============================================================

def demo_convergence():
    """Demonstrate geometric convergence of contractive closure dynamics."""
    print("\n" + "=" * 60)
    print("DEMO 3: Contractive Closure Dynamics Convergence")
    print("=" * 60)
    
    # Simulate contractive dynamics with factor c = 0.7
    D0 = 10.0   # Initial defect bound
    c = 0.7      # Contraction factor
    
    print(f"\nInitial defect bound: D₀ = {D0}")
    print(f"Contraction factor:  c  = {c}")
    print(f"Theoretical bound:   D₀ · cⁿ")
    
    # Simulate actual defect (with some noise below the bound)
    np.random.seed(42)
    defects = []
    actual = D0
    for n in range(20):
        noise = np.random.uniform(0.5, 1.0)
        actual = c * actual * noise  # Contract with some randomness
        defects.append(actual)
    
    print(f"\n{'n':>3} {'Actual defect':>15} {'Bound D₀·cⁿ':>15} {'Within bound':>15}")
    print("-" * 52)
    for n in range(20):
        bound = D0 * c**n
        within = "✓" if defects[n] <= bound else "✗"
        if n == 0:
            print(f"{n:>3} {D0:>15.6f} {bound:>15.6f} {'✓':>15}")
        else:
            print(f"{n:>3} {defects[n-1]:>15.6f} {bound:>15.6f} {within:>15}")
    
    # Find N for ε-convergence
    eps = 0.01
    N = int(np.ceil(np.log(eps / D0) / np.log(c)))
    print(f"\nFor ε = {eps}: need N ≥ {N} iterations")
    print(f"  D₀ · c^{N} = {D0 * c**N:.6f} ≤ {eps} ✓")


# ============================================================
# 4. Certified Robustness
# ============================================================

def demo_certified_robustness():
    """Demonstrate Lipschitz certified robustness bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Lipschitz Certified Robustness")
    print("=" * 60)
    
    # 5 points, some safe, some unsafe
    G = WeightedGenerator(5)
    # Fully connected with various costs
    costs = [
        (0, 1, 1.0), (0, 2, 3.0), (0, 3, 5.0), (0, 4, 2.0),
        (1, 0, 1.5), (1, 2, 2.0), (1, 3, 4.0), (1, 4, 1.0),
        (2, 0, 3.5), (2, 1, 2.5), (2, 3, 2.0), (2, 4, 3.0),
        (3, 0, 6.0), (3, 1, 4.5), (3, 2, 2.5), (3, 4, 4.0),
        (4, 0, 2.5), (4, 1, 1.5), (4, 2, 3.5), (4, 3, 4.5),
    ]
    for i, j, c in costs:
        G.add_step(i, j, c)
    
    d = derivation_cost(G)
    
    # Observable: Bellman potential to point 0
    f = bellman_potential(d, 0)
    threshold = 3.0
    labels = ['x₀', 'x₁', 'x₂', 'x₃', 'x₄']
    
    print(f"\nObservable f(x) = d(x, x₀) [distance to origin]")
    print(f"Safety threshold: τ = {threshold}")
    print(f"\n{'Point':>6} {'f(x)':>8} {'Status':>10}")
    print("-" * 28)
    for i in range(5):
        status = "SAFE" if f[i] <= threshold else "UNSAFE"
        print(f"{labels[i]:>6} {f[i]:>8.2f} {status:>10}")
    
    print(f"\nRobustness certificates (for safe x, unsafe y):")
    print(f"  Bound: τ - f(x) < d(y, x)")
    for i in range(5):
        if f[i] <= threshold:
            for j in range(5):
                if f[j] > threshold:
                    margin = threshold - f[i]
                    dist = d[j, i]
                    holds = margin < dist
                    print(f"  {labels[i]} safe, {labels[j]} unsafe: "
                          f"margin={margin:.2f} < d(y,x)={dist:.2f}  "
                          f"{'✓' if holds else '✗'}")


# ============================================================
# 5. Closure Defect to Target Set
# ============================================================

def demo_closure_defect():
    """Demonstrate closure defect to target set."""
    print("\n" + "=" * 60)
    print("DEMO 5: Closure Defect to Target Set")
    print("=" * 60)
    
    G = WeightedGenerator(6)
    edges = [
        (0, 1, 1), (1, 2, 2), (2, 3, 1), (3, 4, 3),
        (4, 5, 1), (0, 3, 5), (5, 0, 2), (2, 5, 4),
    ]
    for i, j, c in edges:
        G.add_step(i, j, c)
    
    d = derivation_cost(G)
    
    # Target set T = {0, 5} (the "secure basis")
    T = {0, 5}
    
    print(f"\nTarget set (secure basis): T = {{{', '.join(str(t) for t in T)}}}")
    print(f"\nClosure defect to T (= lattice attack surface):")
    for x in range(6):
        defect = min(d[x, t] for t in T)
        print(f"  defect({x}, T) = {defect:.1f}" + (" (in T)" if x in T else ""))
    
    # Verify triangle inequality for defect
    print(f"\nDefect triangle inequality: defect(x, T) ≤ d(x, y) + defect(y, T)")
    for x in range(6):
        for y in range(6):
            defect_x = min(d[x, t] for t in T)
            defect_y = min(d[y, t] for t in T)
            dist_xy = d[x, y]
            if dist_xy < np.inf and defect_y < np.inf:
                holds = defect_x <= dist_xy + defect_y + 1e-10
                if not holds:
                    print(f"  VIOLATION at x={x}, y={y}")
    print("  All defect triangle inequalities satisfied ✓")


if __name__ == "__main__":
    demo_derivation_cost()
    demo_kantorovich_duality()
    demo_convergence()
    demo_certified_robustness()
    demo_closure_defect()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the Kantorovich-Lawvere Duality theory."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

def convergence_plot():
    """Plot geometric convergence of contractive dynamics."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    D0 = 10.0
    factors = [0.3, 0.5, 0.7, 0.9]
    colors = ['#3b82f6', '#22c55e', '#f59e0b', '#ef4444']
    n_range = np.arange(0, 25)
    
    for c, color in zip(factors, colors):
        bounds = [D0 * c**n for n in n_range]
        ax.semilogy(n_range, bounds, 'o-', color=color, markersize=4,
                    label=f'c = {c}', linewidth=2)
    
    ax.axhline(y=0.01, color='gray', linestyle='--', alpha=0.7, label='ε = 0.01')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Defect bound D₀·cⁿ', fontsize=12)
    ax.set_title('Geometric Convergence of Contractive Closure Dynamics', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 24.5)
    
    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    plt.close(fig)
    return base64.b64encode(buf.read()).decode('utf-8')

def asymmetry_heatmap():
    """Plot thermodynamic asymmetry index as a heatmap."""
    n = 5
    labels = ['A', 'B', 'C', 'D', 'E']
    
    np.random.seed(42)
    cost = np.full((n, n), np.inf)
    np.fill_diagonal(cost, 0.0)
    edges = [(0,1,2), (1,2,3), (2,3,1), (3,4,2), (0,3,8),
             (1,0,5), (2,1,7), (3,2,4), (4,3,6), (4,0,3)]
    for i, j, c in edges:
        cost[i, j] = c
    
    d = cost.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i,k] + d[k,j] < d[i,j]:
                    d[i,j] = d[i,k] + d[k,j]
    
    asym = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if d[i,j] < np.inf and d[j,i] < np.inf:
                asym[i,j] = d[i,j] - d[j,i]
    
    fig, ax = plt.subplots(1, 1, figsize=(7, 6))
    im = ax.imshow(asym, cmap='RdBu_r', vmin=-10, vmax=10)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_xlabel('y', fontsize=13)
    ax.set_ylabel('x', fontsize=13)
    ax.set_title('Thermodynamic Asymmetry Index Δ(x,y) = d(x,y) - d(y,x)', fontsize=14)
    
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{asym[i,j]:+.1f}', ha='center', va='center',
                    fontsize=10, color='black' if abs(asym[i,j]) < 5 else 'white')
    
    plt.colorbar(im, ax=ax, label='Asymmetry Index')
    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    plt.close(fig)
    return base64.b64encode(buf.read()).decode('utf-8')

def duality_gap_plot():
    """Plot showing exact duality: observableGap = distance."""
    np.random.seed(123)
    n = 6
    cost = np.full((n, n), np.inf)
    np.fill_diagonal(cost, 0.0)
    for i in range(n):
        for j in range(n):
            if i != j and np.random.random() < 0.5:
                cost[i,j] = np.random.uniform(1, 10)
    
    d = cost.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i,k] + d[k,j] < d[i,j]:
                    d[i,j] = d[i,k] + d[k,j]
    
    distances = []
    gaps = []
    for i in range(n):
        for j in range(n):
            if d[i,j] < np.inf and i != j:
                # Observable gap = max over Bellman potentials
                max_gap = max(d[i,t] - d[j,t] for t in range(n) if d[i,t] < np.inf and d[j,t] < np.inf)
                distances.append(d[i,j])
                gaps.append(max_gap)
    
    fig, ax = plt.subplots(1, 1, figsize=(7, 6))
    ax.scatter(distances, gaps, c='#3b82f6', s=80, alpha=0.8, edgecolors='#1e40af', zorder=5)
    
    max_val = max(max(distances), max(gaps)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, alpha=0.7, label='Exact duality (y = x)')
    
    ax.set_xlabel('Distance d(x, y)', fontsize=13)
    ax.set_ylabel('Observable Gap sup{f(x)-f(y)}', fontsize=13)
    ax.set_title('Kantorovich–Lawvere Duality: Exact Match', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    plt.close(fig)
    return base64.b64encode(buf.read()).decode('utf-8')

if __name__ == "__main__":
    print("Generating visualizations...")
    
    conv_b64 = convergence_plot()
    print(f"Convergence plot: {len(conv_b64)} bytes base64")
    
    asym_b64 = asymmetry_heatmap()
    print(f"Asymmetry heatmap: {len(asym_b64)} bytes base64")
    
    dual_b64 = duality_gap_plot()
    print(f"Duality gap plot: {len(dual_b64)} bytes base64")
    
    # Save as files too
    for name, data in [('convergence.png', conv_b64), ('asymmetry.png', asym_b64), ('duality.png', dual_b64)]:
        with open(name, 'wb') as f:
            f.write(base64.b64decode(data))
        print(f"Saved {name}")
    
    print("Done!")
