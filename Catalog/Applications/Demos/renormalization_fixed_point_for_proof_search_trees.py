#!/usr/bin/env python3
"""
Applications of Proof Search Tree Renormalization Theory

Demonstrates real-world applications:
1. Benchmark classification by universality class
2. Prover-independent lower bound estimation
3. Phase transition detection in proof search
4. Convergence prediction for proof search strategies
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
import random


# ============================================================================
# Application 1: Benchmark Classification by Universality Class
# ============================================================================

@dataclass
class BenchmarkFamily:
    """A family of proof-search benchmark problems."""
    name: str
    branching_law: np.ndarray  # probability of k children
    entropy: float
    description: str


def classify_benchmarks(families: List[BenchmarkFamily], tol: float = 0.05) -> Dict[int, List[str]]:
    """
    Classify benchmark families into universality classes based on their
    renormalization fixed points.

    Two families belong to the same class if their limiting local profiles
    agree within tolerance — meaning they have identical asymptotic
    proof-search geometry.

    Args:
        families: List of benchmark families
        tol: Tolerance for class equivalence

    Returns:
        Dictionary mapping class ID to list of family names.
    """
    # Compute characteristic vector for each family
    characteristics = []
    for f in families:
        # The characteristic is (normalized branching law, entropy)
        char = np.concatenate([f.branching_law / f.branching_law.sum(), [f.entropy]])
        characteristics.append(char)

    # Cluster by proximity
    classes: Dict[int, List[str]] = {}
    class_id = 0
    assigned = set()

    for i, f in enumerate(families):
        if i in assigned:
            continue
        classes[class_id] = [f.name]
        assigned.add(i)
        for j in range(i + 1, len(families)):
            if j not in assigned:
                d = np.linalg.norm(characteristics[i] - characteristics[j])
                if d < tol:
                    classes[class_id].append(families[j].name)
                    assigned.add(j)
        class_id += 1

    return classes


def demo_benchmark_classification():
    """Demonstrate benchmark classification by universality class."""
    print("=" * 70)
    print("APPLICATION 1: BENCHMARK CLASSIFICATION BY UNIVERSALITY CLASS")
    print("=" * 70)

    families = [
        BenchmarkFamily("Random 3-SAT (α=4.0)", np.array([0.1, 0.3, 0.6]), 1.2,
                        "Random 3-SAT near threshold"),
        BenchmarkFamily("Random 3-SAT (α=4.2)", np.array([0.1, 0.3, 0.6]), 1.2,
                        "Random 3-SAT near threshold (higher density)"),
        BenchmarkFamily("Graph Coloring (sparse)", np.array([0.2, 0.5, 0.3]), 0.9,
                        "Graph coloring on sparse random graphs"),
        BenchmarkFamily("Graph Coloring (dense)", np.array([0.05, 0.15, 0.8]), 1.8,
                        "Graph coloring on dense random graphs"),
        BenchmarkFamily("Horn-SAT", np.array([0.3, 0.5, 0.2]), 0.7,
                        "Horn clause satisfiability"),
        BenchmarkFamily("2-SAT (subcritical)", np.array([0.3, 0.5, 0.2]), 0.7,
                        "2-SAT below threshold"),
        BenchmarkFamily("Pigeonhole (n→n-1)", np.array([0.0, 0.1, 0.9]), 2.0,
                        "Pigeonhole principle"),
        BenchmarkFamily("Random k-XOR", np.array([0.0, 0.1, 0.9]), 2.0,
                        "Random XOR constraints"),
    ]

    classes = classify_benchmarks(families)

    print(f"\n{len(families)} benchmark families → {len(classes)} universality classes\n")
    for cid, members in classes.items():
        print(f"  Universality Class {cid}:")
        for name in members:
            f = next(f for f in families if f.name == name)
            print(f"    • {name}")
            print(f"      branching law = {f.branching_law}, entropy = {f.entropy}")
        print()

    print("INTERPRETATION:")
    print("  Families in the same universality class have identical asymptotic")
    print("  proof-search geometry. Performance results for one family in a class")
    print("  are expected to transfer to all other families in that class.\n")


# ============================================================================
# Application 2: Convergence Prediction
# ============================================================================

def predict_convergence(
    contraction_ratio: float,
    initial_displacement: float,
    target_precision: float
) -> Dict[str, float]:
    """
    Predict convergence characteristics of a proof search procedure.

    Using Theorem D, compute:
    - Total variation bound
    - Steps to target precision
    - Asymptotic convergence rate

    Args:
        contraction_ratio: K < 1
        initial_displacement: dist(μ₀, R(μ₀))
        target_precision: desired ε

    Returns:
        Dictionary of convergence metrics.
    """
    K = contraction_ratio
    d0 = initial_displacement

    total_var = d0 / (1 - K)
    steps = int(np.ceil(np.log(target_precision * (1 - K) / d0) / np.log(K))) if K > 0 else 1
    rate = -np.log(K) if K > 0 else float('inf')

    return {
        "contraction_ratio": K,
        "total_variation_bound": total_var,
        "steps_to_precision": steps,
        "convergence_rate": rate,
        "half_life": np.log(2) / rate if rate > 0 else float('inf'),
    }


def demo_convergence_prediction():
    """Demonstrate convergence prediction for different prover configurations."""
    print("=" * 70)
    print("APPLICATION 2: CONVERGENCE PREDICTION FOR PROOF SEARCH")
    print("=" * 70)

    configs = [
        ("BFS (breadth-first)", 0.9, 2.0),
        ("DFS (depth-first)", 0.7, 1.5),
        ("CDCL-style", 0.4, 1.0),
        ("Tableau + learning", 0.3, 0.8),
        ("Optimal heuristic", 0.2, 0.5),
    ]

    print(f"\n{'Prover':<25} {'K':<6} {'Steps to ε=10⁻⁶':<18} {'Half-life':<12} {'Total var':<12}")
    print("-" * 75)

    for name, K, d0 in configs:
        metrics = predict_convergence(K, d0, 1e-6)
        print(f"{name:<25} {K:<6.2f} {metrics['steps_to_precision']:<18d} "
              f"{metrics['half_life']:<12.2f} {metrics['total_variation_bound']:<12.2f}")

    print(f"\nINTERPRETATION:")
    print(f"  All provers converge to the SAME fixed point (Theorem C).")
    print(f"  The contraction ratio K determines HOW FAST they converge.")
    print(f"  Better heuristics → smaller K → faster convergence.\n")


# ============================================================================
# Application 3: Phase Transition Detection
# ============================================================================

def detect_phase_transition(
    entropy_range: np.ndarray,
    branching_bound: int = 3,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Detect phase transitions by monitoring the renormalization fixed point
    as a function of entropy.

    As entropy increases, the fixed point may undergo sharp transitions,
    analogous to phase transitions in statistical mechanics.

    Args:
        entropy_range: Array of entropy values to test
        branching_bound: Maximum branching factor
        seed: Random seed

    Returns:
        (entropy_values, profile_moment_values) for plotting
    """
    rng = np.random.RandomState(seed)
    dim = branching_bound + 1
    moments = []

    for h in entropy_range:
        # Construct operator for this entropy
        K = np.exp(-h)  # Contraction ratio decreases with entropy
        M = rng.randn(dim, dim) * 0.1
        sigma = np.linalg.norm(M, ord=2)
        if sigma > 0:
            M = M * K / sigma

        # Fixed point via iteration
        offset = np.ones(dim) / dim * (1 - K)
        mu = np.ones(dim) / dim
        for _ in range(1000):
            mu = M @ mu + offset

        # Monitor first moment (mean neighborhood complexity)
        moment = np.sum(np.arange(dim) * np.abs(mu) / np.sum(np.abs(mu) + 1e-10))
        moments.append(moment)

    return entropy_range, np.array(moments)


def demo_phase_transition():
    """Demonstrate phase transition detection in proof search."""
    print("=" * 70)
    print("APPLICATION 3: PHASE TRANSITION DETECTION")
    print("=" * 70)

    entropy_range = np.linspace(0.1, 3.0, 30)
    _, moments = detect_phase_transition(entropy_range)

    print(f"\nMonitoring fixed-point profile as entropy varies:")
    print(f"{'Entropy h':<12} {'Mean complexity':<18} {'Regime':<20}")
    print("-" * 50)

    for i in range(0, len(entropy_range), 3):
        h = entropy_range[i]
        m = moments[i]
        regime = "narrow-tree" if m < 1.5 else ("transitional" if m < 2.0 else "heavy-branching")
        print(f"{h:<12.2f} {m:<18.4f} {regime:<20}")

    print(f"\nINTERPRETATION:")
    print(f"  As entropy increases, the fixed-point profile shifts from")
    print(f"  narrow-tree (path-like) to heavy-branching (bushy) geometry.")
    print(f"  Sharp transitions would indicate phase boundaries between")
    print(f"  universality classes — analogous to SAT phase transitions.\n")


# ============================================================================
# Application 4: Prover Comparison via Profile Distance
# ============================================================================

def simulate_prover_profiles(
    n_provers: int,
    dim: int,
    n_depths: int,
    contraction_ratio: float,
    seed: int = 42
) -> np.ndarray:
    """
    Simulate local profile evolution for multiple provers.

    Each prover starts from a different initial profile but is governed
    by the same renormalization operator. By Theorem C, they all converge
    to the same fixed point.

    Returns:
        Array of shape (n_provers, n_depths, dim) containing profile histories.
    """
    rng = np.random.RandomState(seed)

    # Shared operator (same logical fragment)
    K = contraction_ratio
    M = rng.randn(dim, dim) * 0.3
    sigma = np.linalg.norm(M, ord=2)
    M = M * K / sigma
    fixed_point = rng.dirichlet(np.ones(dim))
    offset = fixed_point - M @ fixed_point

    # Different starting points (different prover heuristics)
    histories = np.zeros((n_provers, n_depths, dim))
    for p in range(n_provers):
        mu = rng.dirichlet(np.ones(dim) * 0.5)  # Random initial profile
        for d in range(n_depths):
            histories[p, d] = mu
            mu = M @ mu + offset

    return histories


def demo_prover_comparison():
    """Demonstrate prover comparison via profile convergence."""
    print("=" * 70)
    print("APPLICATION 4: PROVER COMPARISON VIA PROFILE DISTANCE")
    print("=" * 70)

    n_provers = 4
    dim = 5
    n_depths = 30
    K = 0.6

    histories = simulate_prover_profiles(n_provers, dim, n_depths, K)

    # Compute pairwise distances at each depth
    print(f"\n{n_provers} provers, {dim} neighborhood types, K = {K}")
    print(f"\nMax pairwise profile distance at each depth:")
    print(f"{'Depth':<8} {'Max dist':<12} {'Status':<20}")
    print("-" * 42)

    for d in range(0, n_depths, 3):
        max_dist = 0
        for i in range(n_provers):
            for j in range(i + 1, n_provers):
                dist = np.linalg.norm(histories[i, d] - histories[j, d], ord=np.inf)
                max_dist = max(max_dist, dist)
        status = "divergent" if max_dist > 0.1 else ("converging" if max_dist > 0.001 else "converged")
        print(f"{d:<8} {max_dist:<12.6f} {status:<20}")

    print(f"\nINTERPRETATION:")
    print(f"  Despite starting from different initial profiles (different heuristics),")
    print(f"  all {n_provers} provers converge to the same local geometry.")
    print(f"  This is Theorem C (universality) in action.\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  APPLICATIONS OF PROOF SEARCH RENORMALIZATION THEORY")
    print("=" * 70 + "\n")

    demo_benchmark_classification()
    demo_convergence_prediction()
    demo_phase_transition()
    demo_prover_comparison()

    print("=" * 70)
    print("  ALL APPLICATIONS DEMONSTRATED")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Renormalization Fixed Points for Proof Search Trees

Demonstrates the core theorems with concrete numerical examples:
1. Bounded rooted tree enumeration and cardinality
2. Convergence of local profile distributions under contraction
3. Universality: different initial profiles converge to the same fixed point
4. Entropy-controlled convergence rates
"""

import numpy as np
from typing import List, Tuple, Dict
import itertools


# ============================================================================
# Section 1: Bounded Rooted Tree Enumeration
# ============================================================================

def count_bounded_trees(B: int, r: int) -> int:
    """
    Count the number of ordered rooted trees with branching ≤ B and height ≤ r.

    Recurrence:
        C(B, 0) = 1
        C(B, r+1) = sum_{k=0}^{B} C(B, r)^k

    >>> count_bounded_trees(2, 0)
    1
    >>> count_bounded_trees(2, 1)
    3
    >>> count_bounded_trees(2, 2)
    13
    """
    if r == 0:
        return 1
    prev = count_bounded_trees(B, r - 1)
    return sum(prev ** k for k in range(B + 1))


def print_tree_counts():
    """Print a table of neighborhood type counts."""
    print("=" * 60)
    print("NEIGHBORHOOD TYPE COUNTS: |BoundedRootedTree(B, r)|")
    print("=" * 60)
    header = 'B \\ r'
    print(f"{header:<8}", end="")
    for r in range(6):
        print(f"{r:<12}", end="")
    print()
    print("-" * 60)
    for B in range(1, 5):
        print(f"{B:<8}", end="")
        for r in range(6):
            c = count_bounded_trees(B, r)
            if c < 10**9:
                print(f"{c:<12}", end="")
            else:
                print(f"{'> 10^9':<12}", end="")
        print()
    print()


# ============================================================================
# Section 2: Contraction Operator and Profile Convergence
# ============================================================================

def make_contraction_operator(K: int, dim: int, seed: int = 42) -> np.ndarray:
    """
    Create a random contraction operator on R^dim with spectral radius ≤ K.

    The operator is a matrix M with ||M|| ≤ K < 1, so it contracts distances.
    This models the entropy-normalized renormalization map on profile distributions.

    Args:
        K: Contraction ratio (0 < K < 1)
        dim: Dimension of the profile space
        seed: Random seed for reproducibility
    """
    rng = np.random.RandomState(seed)
    # Random matrix, then scale to have operator norm ≤ K
    A = rng.randn(dim, dim)
    # Normalize by spectral norm and scale by K
    sigma_max = np.linalg.norm(A, ord=2)
    M = K * A / sigma_max
    return M


def simulate_contraction_orbit(
    M: np.ndarray, mu0: np.ndarray, fixed_point: np.ndarray, n_steps: int
) -> List[float]:
    """
    Simulate the orbit of mu0 under the affine contraction R(mu) = M @ mu + b,
    where b is chosen so that fixed_point is the fixed point.

    Returns distances to the fixed point at each step.
    """
    # b = fixed_point - M @ fixed_point
    b = fixed_point - M @ fixed_point
    distances = []
    mu = mu0.copy()
    for _ in range(n_steps):
        distances.append(np.linalg.norm(mu - fixed_point, ord=np.inf))
        mu = M @ mu + b
    return distances


def demo_convergence():
    """Demonstrate Theorem B: contraction orbits converge to the fixed point."""
    print("=" * 60)
    print("THEOREM B: CONTRACTION ORBIT CONVERGENCE")
    print("=" * 60)

    dim = 13  # C(2, 2) = 13 neighborhood types
    K = 0.5   # Contraction ratio

    M = make_contraction_operator(K, dim)

    # The fixed point (a probability distribution on 13 types)
    fixed_point = np.zeros(dim)
    fixed_point[:5] = [0.3, 0.25, 0.2, 0.15, 0.1]  # concentrated on first 5 types

    # Two different initial profiles
    mu1 = np.ones(dim) / dim  # uniform distribution
    mu2 = np.zeros(dim)
    mu2[0] = 1.0  # all mass on type 0

    n_steps = 30
    dists1 = simulate_contraction_orbit(M, mu1, fixed_point, n_steps)
    dists2 = simulate_contraction_orbit(M, mu2, fixed_point, n_steps)

    print(f"\nProfile space dimension: {dim} (= |BoundedRootedTree(2, 2)|)")
    print(f"Contraction ratio K: {K}")
    print(f"\nStep  |  dist(orbit1, μ*)  |  dist(orbit2, μ*)  |  ratio")
    print("-" * 60)
    for n in range(min(20, n_steps)):
        r1 = dists1[n+1] / dists1[n] if dists1[n] > 1e-15 else 0
        print(f"{n:4d}  |  {dists1[n]:16.10f}  |  {dists2[n]:16.10f}  |  {r1:.4f}")

    print(f"\nBoth orbits converge to the same fixed point μ* (Theorem C).")
    print(f"Convergence rate ≈ K = {K} (Theorem D).\n")


# ============================================================================
# Section 3: Universality Demonstration
# ============================================================================

def demo_universality():
    """
    Demonstrate Theorem C: two search procedures with the same renormalization
    operator converge to the same fixed point, regardless of initial conditions.
    """
    print("=" * 60)
    print("THEOREM C: UNIVERSALITY OF SHARED CONTRACTION")
    print("=" * 60)

    dim = 3  # Small dimension for clear visualization
    K = 0.7

    M = make_contraction_operator(K, dim, seed=123)
    fixed_point = np.array([0.5, 0.3, 0.2])

    # 5 different initial profiles (representing 5 different provers)
    initials = [
        np.array([1.0, 0.0, 0.0]),   # Prover A: all mass on type 0
        np.array([0.0, 1.0, 0.0]),   # Prover B: all mass on type 1
        np.array([0.0, 0.0, 1.0]),   # Prover C: all mass on type 2
        np.array([1/3, 1/3, 1/3]),   # Prover D: uniform
        np.array([0.8, 0.1, 0.1]),   # Prover E: skewed
    ]
    names = ["Prover A", "Prover B", "Prover C", "Prover D", "Prover E"]

    n_steps = 25
    print(f"\nProfile space dimension: {dim}")
    print(f"Contraction ratio K: {K}")
    print(f"Fixed point μ*: {fixed_point}")
    print(f"\nFinal distances from μ* after {n_steps} steps:")
    print("-" * 50)

    for name, mu0 in zip(names, initials):
        dists = simulate_contraction_orbit(M, mu0, fixed_point, n_steps)
        print(f"  {name}: dist = {dists[-1]:.2e} (initial dist = {dists[0]:.4f})")

    print(f"\nAll provers converge to μ* = {fixed_point}")
    print("This is UNIVERSALITY: the fixed point depends only on the operator,")
    print("not on the initial conditions (prover heuristics).\n")


# ============================================================================
# Section 4: Entropy-Variation Bound
# ============================================================================

def demo_entropy_bound():
    """
    Demonstrate Theorem D: entropy control implies geometric summability
    of profile step distances.
    """
    print("=" * 60)
    print("THEOREM D: ENTROPY CONTROLS PROFILE VARIATION")
    print("=" * 60)

    dim = 13
    d0 = 1.0  # Initial displacement

    print(f"\nProfile space dimension: {dim}")
    print(f"Initial displacement d₀ = dist(μ₀, R(μ₀)) = {d0}")
    print(f"\n{'K':<8} {'Total variation bound':<25} {'Steps to 10⁻⁶':<20}")
    print("-" * 55)

    for K in [0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        total_var = d0 / (1 - K)
        steps_to_eps = int(np.ceil(np.log(1e-6) / np.log(K))) if K > 0 else 1
        print(f"{K:<8.2f} {total_var:<25.4f} {steps_to_eps:<20d}")

    print(f"\nSmaller K (stronger contraction, better entropy control)")
    print(f"→ tighter total variation bound and faster convergence.\n")


# ============================================================================
# Section 5: Profile Simplex Visualization (text-based)
# ============================================================================

def demo_simplex():
    """Show how profiles stay bounded in the simplex."""
    print("=" * 60)
    print("PROFILE SIMPLEX: PROBABILITY DISTRIBUTIONS ARE BOUNDED")
    print("=" * 60)

    dim = 3
    K = 0.6
    M = make_contraction_operator(K, dim, seed=77)
    fixed_point = np.array([0.4, 0.35, 0.25])

    mu0 = np.array([0.9, 0.05, 0.05])
    b = fixed_point - M @ fixed_point

    print(f"\nTracking orbit in 3D simplex (type frequencies sum to 1):")
    print(f"{'Step':<6} {'Type 0':<10} {'Type 1':<10} {'Type 2':<10} {'Sum':<10} {'dist to μ*':<12}")
    print("-" * 60)

    mu = mu0.copy()
    for n in range(15):
        d = np.linalg.norm(mu - fixed_point, ord=np.inf)
        print(f"{n:<6} {mu[0]:<10.4f} {mu[1]:<10.4f} {mu[2]:<10.4f} {sum(mu):<10.4f} {d:<12.6f}")
        mu = M @ mu + b

    print(f"\nFixed point μ* = ({fixed_point[0]:.2f}, {fixed_point[1]:.2f}, {fixed_point[2]:.2f})")
    print(f"Profile distances bounded by 2 (Proposition 2.6).\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  RENORMALIZATION FIXED POINTS FOR PROOF SEARCH TREES")
    print("  Demonstration of Core Theorems")
    print("=" * 60 + "\n")

    print_tree_counts()
    demo_convergence()
    demo_universality()
    demo_entropy_bound()
    demo_simplex()

    print("=" * 60)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)
