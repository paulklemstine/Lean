#!/usr/bin/env python3
"""
algorithms.py — Self-Avoiding Walk Algorithms

Type-hinted implementations of key SAW algorithms:
1. Exact enumeration via backtracking
2. Pivot algorithm (MCMC for sampling long SAWs)
3. Connective constant estimation
4. Bridge decomposition
"""

from typing import List, Tuple, Set, Optional, Dict
import math
import random


Point = Tuple[int, int]
Walk = List[Point]
DIRECTIONS_Z2: List[Point] = [(1, 0), (-1, 0), (0, 1), (0, -1)]


def enumerate_saws_z2(n: int) -> List[Walk]:
    """
    Enumerate all self-avoiding walks of length n on Z² starting from origin.

    Time complexity: O(c_n) where c_n ~ μ^n, μ ≈ 2.638
    Space complexity: O(n) for the recursion stack

    Args:
        n: Walk length

    Returns:
        List of all SAWs as lists of (x, y) coordinates
    """
    if n == 0:
        return [[(0, 0)]]

    result: List[Walk] = []

    def _backtrack(path: Walk, visited: Set[Point]) -> None:
        if len(path) == n + 1:
            result.append(list(path))
            return
        x, y = path[-1]
        for dx, dy in DIRECTIONS_Z2:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                path.append((nx, ny))
                _backtrack(path, visited)
                path.pop()
                visited.discard((nx, ny))

    _backtrack([(0, 0)], {(0, 0)})
    return result


def count_saws_z2(n: int) -> int:
    """Count c_n = number of SAWs of length n on Z² from origin."""
    return len(enumerate_saws_z2(n))


def pivot_algorithm(
    n: int,
    num_steps: int = 10000,
    seed: Optional[int] = None
) -> List[Walk]:
    """
    Pivot algorithm for sampling self-avoiding walks.

    The pivot algorithm (Lal 1969, Madras-Sokal 1988) is an MCMC method
    that samples SAWs nearly uniformly. At each step:
    1. Choose a random pivot point on the current walk
    2. Apply a random lattice symmetry to the portion after the pivot
    3. Accept if the result is still self-avoiding

    The mixing time is O(n^{1+ε}) for any ε > 0 (Madras-Sokal).

    Args:
        n: Walk length
        num_steps: Number of MCMC steps
        seed: Random seed for reproducibility

    Returns:
        List of sampled walks (one per accepted step)
    """
    if seed is not None:
        random.seed(seed)

    # Start with straight walk along x-axis
    current: Walk = [(i, 0) for i in range(n + 1)]
    samples: List[Walk] = []

    # Lattice symmetries of Z²: rotations and reflections
    symmetries = [
        lambda p, c: (c[0] + (p[0] - c[0]), c[1] + (p[1] - c[1])),   # identity
        lambda p, c: (c[0] - (p[1] - c[1]), c[1] + (p[0] - c[0])),   # 90° CCW
        lambda p, c: (c[0] - (p[0] - c[0]), c[1] - (p[1] - c[1])),   # 180°
        lambda p, c: (c[0] + (p[1] - c[1]), c[1] - (p[0] - c[0])),   # 90° CW
        lambda p, c: (c[0] - (p[0] - c[0]), c[1] + (p[1] - c[1])),   # reflect x
        lambda p, c: (c[0] + (p[0] - c[0]), c[1] - (p[1] - c[1])),   # reflect y
        lambda p, c: (c[0] + (p[1] - c[1]), c[1] + (p[0] - c[0])),   # reflect diag
        lambda p, c: (c[0] - (p[1] - c[1]), c[1] - (p[0] - c[0])),   # reflect anti-diag
    ]

    for _ in range(num_steps):
        # Choose random pivot point (not the first point)
        pivot_idx = random.randint(1, n)
        pivot = current[pivot_idx]

        # Choose random symmetry (not identity)
        sym = random.choice(symmetries[1:])

        # Apply symmetry to tail
        new_tail = [sym(current[j], pivot) for j in range(pivot_idx, n + 1)]

        # Check self-avoidance
        head_set = set(current[:pivot_idx])
        tail_set = set(new_tail)

        if len(tail_set) == len(new_tail) and head_set.isdisjoint(tail_set):
            current = current[:pivot_idx] + new_tail
            samples.append(list(current))

    return samples


def estimate_connective_constant(
    max_n: int = 12,
    method: str = "exact"
) -> Dict[str, float]:
    """
    Estimate the connective constant μ of Z².

    Uses exact enumeration for small n to compute c_n^{1/n}.
    By Fekete's lemma, this sequence converges to μ.

    Returns:
        Dictionary with estimates and bounds
    """
    counts = {}
    for k in range(max_n + 1):
        counts[k] = count_saws_z2(k)

    estimates = {k: counts[k] ** (1.0 / k) for k in range(1, max_n + 1)}

    # infimum of log(c_n)/n gives log(μ)
    log_estimates = {k: math.log(counts[k]) / k for k in range(1, max_n + 1)}
    log_mu_inf = min(log_estimates.values())

    return {
        "counts": counts,
        "mu_estimates": estimates,
        "log_mu_inf": log_mu_inf,
        "mu_lower": math.exp(log_mu_inf),
        "best_estimate": estimates[max_n],
    }


def bridge_decomposition(walk: Walk) -> List[Walk]:
    """
    Decompose a SAW into bridges.

    A bridge is a maximal segment where intermediate x-coordinates
    are strictly between the endpoint x-coordinates.

    This decomposition is key to Hammersley-Welsh bounds on μ.

    Args:
        walk: A self-avoiding walk

    Returns:
        List of bridges (sub-walks)
    """
    if len(walk) <= 1:
        return [walk]

    bridges: List[Walk] = []
    current_start = 0
    max_x = walk[0][0]

    for i in range(1, len(walk)):
        if walk[i][0] >= max_x:
            # Potential bridge boundary
            bridges.append(walk[current_start:i + 1])
            current_start = i
            max_x = walk[i][0]

    if current_start < len(walk) - 1:
        bridges.append(walk[current_start:])

    return bridges


def nienhuis_constant_properties() -> Dict[str, float]:
    """
    Properties of the Nienhuis constant μ_hex = √(2+√2).

    Returns dictionary of algebraic properties.
    """
    mu = math.sqrt(2 + math.sqrt(2))
    return {
        "mu": mu,
        "mu_squared": mu ** 2,
        "two_plus_sqrt2": 2 + math.sqrt(2),
        "mu_fourth": mu ** 4,
        "algebraic_identity": mu**4 - 4*mu**2 + 2,  # should be ≈ 0
        "critical_fugacity": 1 / mu,
        "minimal_polynomial_coeffs": [1, 0, -4, 0, 2],  # x⁴ - 4x² + 2
    }


def verify_submultiplicativity(max_n: int = 8) -> bool:
    """Verify c_{m+n} ≤ c_m · c_n for all m+n ≤ max_n."""
    counts = {k: count_saws_z2(k) for k in range(max_n + 1)}
    for m in range(max_n + 1):
        for n in range(max_n + 1 - m):
            if counts[m + n] > counts[m] * counts[n]:
                return False
    return True


if __name__ == "__main__":
    # Quick demonstration
    result = estimate_connective_constant(10)
    print("Connective constant estimates:")
    for k, mu_k in sorted(result["mu_estimates"].items()):
        print(f"  c_{k}^(1/{k}) = {mu_k:.8f}")
    print(f"  Best lower bound: {result['mu_lower']:.8f}")

    print(f"\nNienhuis properties:")
    props = nienhuis_constant_properties()
    for key, val in props.items():
        print(f"  {key}: {val}")

    print(f"\nSubmultiplicativity verified: {verify_submultiplicativity(8)}")
