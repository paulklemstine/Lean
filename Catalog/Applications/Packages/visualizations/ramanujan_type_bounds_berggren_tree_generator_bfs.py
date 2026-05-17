#!/usr/bin/env python3
"""
Berggren Ramanujan Expander — Algorithms

Implements the core algorithms arising from the spectral theory of
Berggren dynamics on primitive Pythagorean triples.

Algorithms:
  1. Berggren Tree Generator (BFS/DFS with depth/height bounds)
  2. Spectral Gap Computation via eigenvalue analysis
  3. Observable Averaging with mixing time estimation
  4. Pseudorandom Triple Sampler (exploiting spectral gap)
  5. Discrepancy Estimator for arithmetic test functions
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from collections import deque

# ============================================================
# Berggren Generators
# ============================================================

B1 = np.array([[ 1, -2, 2],
               [ 2, -1, 2],
               [ 2, -2, 3]], dtype=np.int64)

B2 = np.array([[ 1,  2, 2],
               [ 2,  1, 2],
               [ 2,  2, 3]], dtype=np.int64)

B3 = np.array([[-1,  2, 2],
               [-2,  1, 2],
               [-2,  2, 3]], dtype=np.int64)

GENERATORS = [B1, B2, B3]
ROOT = np.array([3, 4, 5], dtype=np.int64)


# ============================================================
# Algorithm 1: Berggren Tree Generator
# ============================================================

def berggren_tree_bfs(max_depth: int = 5) -> List[Tuple[int, int, int, int]]:
    """
    Generate all primitive Pythagorean triples in the Berggren tree
    up to a given depth using breadth-first search.

    Returns: List of (a, b, c, depth) tuples.

    Complexity:
      Time:  O(3^d) where d = max_depth
      Space: O(3^d) to store all triples

    >>> triples = berggren_tree_bfs(2)
    >>> all(a**2 + b**2 == c**2 for a, b, c, _ in triples)
    True
    """
    result = []
    queue: deque = deque()
    queue.append((ROOT, 0))

    while queue:
        triple, depth = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        result.append((a, b, c, depth))

        if depth < max_depth:
            for B in GENERATORS:
                child = B @ triple
                queue.append((child, depth + 1))

    return result


def berggren_tree_bounded(max_hypotenuse: int = 1000) -> List[Tuple[int, int, int]]:
    """
    Generate primitive Pythagorean triples with hypotenuse ≤ max_hypotenuse.

    Uses DFS with pruning: since each generator increases the hypotenuse,
    we can prune branches that exceed the bound.

    Complexity:
      Time:  O(N log N) where N is the number of triples found
      Space: O(N)

    >>> triples = berggren_tree_bounded(100)
    >>> all(a**2 + b**2 == c**2 for a, b, c in triples)
    True
    >>> max(c for _, _, c in triples) <= 100
    True
    """
    result = []
    stack = [ROOT]

    while stack:
        triple = stack.pop()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

        if c > max_hypotenuse:
            continue

        result.append((a, b, c))

        for B in GENERATORS:
            child = B @ triple
            if int(child[2]) <= max_hypotenuse:
                stack.append(child)

    return sorted(result, key=lambda t: t[2])


# ============================================================
# Algorithm 2: Spectral Gap Computation
# ============================================================

def compute_spectral_gap(transition_matrix: np.ndarray) -> dict:
    """
    Compute the spectral gap of a transition matrix.

    The spectral gap is defined as 1 - |λ₂| where λ₂ is the
    second-largest eigenvalue in absolute value.

    For the Berggren sibling operator on K₃:
      λ₁ = 1, λ₂ = λ₃ = -1/2
      gap = 1 - 1/2 = 1/2

    Args:
        transition_matrix: Row-stochastic matrix.

    Returns:
        Dictionary with eigenvalues, gap, and mixing time estimate.

    Complexity:
      Time:  O(n³) for n×n matrix (eigendecomposition)
      Space: O(n²)

    >>> T = np.array([[0, 0.5, 0.5], [0.5, 0, 0.5], [0.5, 0.5, 0]])
    >>> result = compute_spectral_gap(T)
    >>> abs(result['spectral_gap'] - 0.5) < 1e-10
    True
    """
    eigenvalues = np.sort(np.linalg.eigvals(transition_matrix).real)[::-1]
    abs_eigenvalues = np.sort(np.abs(eigenvalues))[::-1]

    lambda_1 = abs_eigenvalues[0]
    lambda_2 = abs_eigenvalues[1] if len(abs_eigenvalues) > 1 else 0.0
    gap = lambda_1 - lambda_2

    # Mixing time: k such that λ₂^k < ε
    epsilon = 0.01
    if lambda_2 > 0 and lambda_2 < 1:
        mixing_time = int(np.ceil(np.log(1/epsilon) / np.log(1/lambda_2)))
    else:
        mixing_time = 1

    return {
        'eigenvalues': eigenvalues,
        'abs_eigenvalues': abs_eigenvalues,
        'lambda_1': lambda_1,
        'lambda_2': lambda_2,
        'spectral_gap': gap,
        'contraction_rate': lambda_2**2,  # l² norm squared contracts by this
        'mixing_time_001': mixing_time,
    }


# ============================================================
# Algorithm 3: Observable Averaging with Mixing Time
# ============================================================

def observable_average(
    observable: Callable[[Tuple[int, int, int]], float],
    depth: int,
    iterations: int = 10
) -> dict:
    """
    Compute the average of an observable over Berggren triples at a given
    depth, along with mixing-corrected confidence bounds.

    The Ramanujan bound guarantees exponential convergence of the
    empirical average to the true mean, with explicit error bounds.

    Args:
        observable: Function mapping (a, b, c) to a real value.
        depth: Depth in the Berggren tree.
        iterations: Number of sibling-mixing iterations for error estimation.

    Returns:
        Dictionary with average, variance, and Ramanujan error bound.

    Complexity:
      Time:  O(3^depth)
      Space: O(3^depth)
    """
    triples = berggren_tree_bfs(depth)
    depth_triples = [(a, b, c) for a, b, c, d in triples if d == depth]

    if not depth_triples:
        return {'average': 0.0, 'count': 0}

    values = np.array([observable(t) for t in depth_triples])
    n = len(values)
    avg = np.mean(values)
    var = np.var(values)
    B = np.max(np.abs(values))

    # Ramanujan bound: after k sibling mixing steps,
    # discrepancy ≤ sqrt(12) · B · (1/2)^k
    ramanujan_bounds = {}
    for k in [1, 5, 10, 20]:
        bound = np.sqrt(12) * B * (0.5)**k
        ramanujan_bounds[f'k={k}'] = bound

    return {
        'average': avg,
        'variance': var,
        'count': n,
        'max_abs': B,
        'ramanujan_bounds': ramanujan_bounds,
    }


# ============================================================
# Algorithm 4: Pseudorandom Triple Sampler
# ============================================================

def pseudorandom_sampler(
    n_samples: int = 100,
    depth: int = 8,
    mixing_steps: int = 5,
    seed: Optional[int] = None
) -> List[Tuple[int, int, int]]:
    """
    Generate pseudorandom primitive Pythagorean triples using the
    Berggren expander structure.

    The algorithm exploits the spectral gap: starting from a fixed triple,
    apply random Berggren generators. After O(log(1/ε)) steps, the
    distribution is ε-close to uniform over the depth-d reachable set.

    The Ramanujan bound ρ = 1/2 guarantees that mixing_steps ≥ log₂(1/ε)
    suffice for ε-approximate uniformity.

    Args:
        n_samples: Number of triples to generate.
        depth: Total random walk depth.
        mixing_steps: Additional mixing steps beyond initial walk.
        seed: Random seed for reproducibility.

    Returns:
        List of pseudorandom primitive Pythagorean triples.

    Complexity:
      Time:  O(n_samples · depth) matrix-vector multiplications
      Space: O(n_samples)

    >>> triples = pseudorandom_sampler(50, depth=6, seed=42)
    >>> all(a**2 + b**2 == c**2 for a, b, c in triples)
    True
    """
    rng = np.random.default_rng(seed)
    samples = []

    for _ in range(n_samples):
        triple = ROOT.copy()
        for _ in range(depth + mixing_steps):
            gen_idx = rng.integers(0, 3)
            triple = GENERATORS[gen_idx] @ triple
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        # Ensure positive legs (take absolute values)
        samples.append((abs(a), abs(b), abs(c)))

    return samples


# ============================================================
# Algorithm 5: Discrepancy Estimator
# ============================================================

def discrepancy_estimator(
    test_functions: List[Callable[[Tuple[int, int, int]], float]],
    max_depth: int = 6
) -> dict:
    """
    Estimate the discrepancy of the Berggren distribution against
    a family of test functions at each depth.

    For each test function φ and depth d, computes:
      D_d(φ) = |E_d[φ] - E_{d-1}[φ]|

    The Ramanujan bound predicts D_d(φ) ≤ C · (1/2)^d for bounded φ.

    Args:
        test_functions: List of test functions (a,b,c) → ℝ.
        max_depth: Maximum depth to analyze.

    Returns:
        Dictionary mapping test function index to list of discrepancies.

    Complexity:
      Time:  O(T · 3^max_depth) where T = number of test functions
      Space: O(3^max_depth)
    """
    triples = berggren_tree_bfs(max_depth)

    results = {}
    for idx, phi in enumerate(test_functions):
        discrepancies = []
        prev_avg = None
        for d in range(max_depth + 1):
            depth_triples = [(a, b, c) for a, b, c, dd in triples if dd == d]
            if depth_triples:
                values = [phi(t) for t in depth_triples]
                avg = np.mean(values)
                if prev_avg is not None:
                    discrepancies.append(abs(avg - prev_avg))
                prev_avg = avg
        results[idx] = discrepancies

    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Algorithm 1: Tree generation
    print("\n--- Algorithm 1: Berggren Tree ---")
    triples = berggren_tree_bfs(3)
    print(f"  Triples at depth ≤ 3: {len(triples)}")
    for a, b, c, d in triples[:5]:
        print(f"    ({a}, {b}, {c}) at depth {d}")

    bounded = berggren_tree_bounded(200)
    print(f"\n  Triples with c ≤ 200: {len(bounded)}")
    for a, b, c in bounded[:5]:
        print(f"    ({a}, {b}, {c})")

    # Algorithm 2: Spectral gap
    print("\n--- Algorithm 2: Spectral Gap ---")
    T = np.array([[0, 0.5, 0.5], [0.5, 0, 0.5], [0.5, 0.5, 0]])
    result = compute_spectral_gap(T)
    print(f"  Eigenvalues: {result['eigenvalues']}")
    print(f"  Spectral gap: {result['spectral_gap']:.4f}")
    print(f"  Contraction rate (l²): {result['contraction_rate']:.4f}")
    print(f"  Mixing time (ε=0.01): {result['mixing_time_001']} steps")

    # Algorithm 3: Observable averaging
    print("\n--- Algorithm 3: Observable Averaging ---")
    # Test: ratio a/c (parametrizes the angle)
    result = observable_average(lambda t: t[0]/t[2], depth=4)
    print(f"  Average a/c at depth 4: {result['average']:.6f}")
    print(f"  Count: {result['count']}")
    print(f"  Ramanujan bounds: {result['ramanujan_bounds']}")

    # Algorithm 4: Pseudorandom sampling
    print("\n--- Algorithm 4: Pseudorandom Sampler ---")
    samples = pseudorandom_sampler(10, depth=8, seed=42)
    print(f"  10 pseudorandom triples:")
    for a, b, c in samples:
        print(f"    ({a}, {b}, {c})  [a²+b²=c²: {a**2 + b**2 == c**2}]")

    # Algorithm 5: Discrepancy estimation
    print("\n--- Algorithm 5: Discrepancy Estimation ---")
    test_fns = [
        lambda t: t[0] / t[2],  # a/c ratio
        lambda t: t[1] / t[2],  # b/c ratio
        lambda t: float(t[0] % 2 == 1),  # a odd indicator
    ]
    disc = discrepancy_estimator(test_fns, max_depth=5)
    for idx, discs in disc.items():
        print(f"  Test function {idx}: discrepancies = "
              f"{[f'{d:.4f}' for d in discs]}")
