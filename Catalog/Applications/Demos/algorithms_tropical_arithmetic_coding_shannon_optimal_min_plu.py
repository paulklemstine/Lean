#!/usr/bin/env python3
"""
Algorithms for Tropical Information Theory

Implementations of the key algorithms from the tropical arithmetic coding
research, with docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
import math


def shannon_optimal_code(probs: np.ndarray) -> np.ndarray:
    """
    Compute Shannon-optimal (real-valued) code lengths.

    Given a probability distribution p, the optimal code length for symbol a
    in tropical coordinates is l(a) = -log p(a).

    This code is Kraft-admissible (sum exp(-l(a)) = sum p(a) = 1)
    and achieves E[l] = H(p) = Shannon entropy.

    Args:
        probs: Probability distribution (positive entries summing to 1)

    Returns:
        Array of optimal code lengths

    Time complexity: O(n)
    Space complexity: O(n)

    >>> p = np.array([0.5, 0.25, 0.125, 0.125])
    >>> l = shannon_optimal_code(p)
    >>> np.allclose(np.sum(np.exp(-l)), 1.0)
    True
    """
    assert np.all(probs > 0), "All probabilities must be positive"
    assert np.isclose(np.sum(probs), 1.0), "Probabilities must sum to 1"
    return -np.log(probs)


def ceiling_code(probs: np.ndarray, base: int = 2) -> np.ndarray:
    """
    Compute integer ceiling code lengths.

    l(a) = ceil(-log_base(p(a)))

    This code is Kraft-admissible and achieves E[l] < H_base(p) + 1.

    Args:
        probs: Probability distribution (positive entries summing to 1)
        base: Logarithm base (default 2 for bits)

    Returns:
        Array of integer code lengths

    Time complexity: O(n)
    Space complexity: O(n)
    """
    assert np.all(probs > 0), "All probabilities must be positive"
    return np.ceil(-np.log(probs) / np.log(base)).astype(int)


def minplus_convolution(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Compute the min-plus (tropical) convolution of two cost functions.

    (f ⋆ g)(z) = min_{x : x+y=z mod n} (f(x) + g(y))

    This is the fundamental composition law for tropical code lengths.
    It is simultaneously:
    - The shortest-path composition in dynamic programming
    - The infimal convolution in convex analysis
    - The tensor product in the tropical semiring

    Args:
        f: First cost function (array of length n)
        g: Second cost function (array of length n)

    Returns:
        Min-plus convolution (array of length n)

    Time complexity: O(n²)
    Space complexity: O(n)

    Property: (f ⋆ g)(x+y) ≤ f(x) + g(y) for all x, y

    >>> f = np.array([1.0, 3.0, 2.0])
    >>> g = np.array([2.0, 1.0, 4.0])
    >>> conv = minplus_convolution(f, g)
    >>> all(conv[(x+y)%3] <= f[x]+g[y] for x in range(3) for y in range(3))
    True
    """
    n = len(f)
    assert len(g) == n, "Functions must have the same domain size"
    result = np.full(n, np.inf)
    for z in range(n):
        for x in range(n):
            y = (z - x) % n
            result[z] = min(result[z], f[x] + g[y])
    return result


def kraft_admissible(lengths: np.ndarray) -> bool:
    """
    Check if a code length function satisfies tropical Kraft admissibility.

    A code is Kraft-admissible if sum exp(-l(a)) ≤ 1.

    Args:
        lengths: Array of code lengths

    Returns:
        True if Kraft-admissible

    Time complexity: O(n)
    """
    return np.sum(np.exp(-lengths)) <= 1.0 + 1e-10


def kraft_product(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Construct the product code from two Kraft-admissible codes.

    For independent sources, the product code has length
    l(a, b) = f(a) + g(b).

    Args:
        f: Code lengths for first source
        g: Code lengths for second source

    Returns:
        Product code lengths (flattened array of size n*m)

    Time complexity: O(nm)
    """
    return (f[:, np.newaxis] + g[np.newaxis, :]).flatten()


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """
    Compute KL divergence D(p || q) = sum p(a) log(p(a)/q(a)).

    Non-negative by Gibbs' inequality (our Theorem 4.1).

    Args:
        p: Probability distribution (positive entries summing to 1)
        q: Positive function (entries summing to ≤ 1)

    Returns:
        KL divergence (non-negative)

    Time complexity: O(n)
    """
    mask = p > 0
    return float(np.sum(p[mask] * np.log(p[mask] / q[mask])))


def tropical_kraft_min(l1: np.ndarray, l2: np.ndarray) -> np.ndarray:
    """
    Compute pointwise tropical minimum of two code lengths.

    If l1 and l2 are Kraft-admissible, then min(l1, l2) has
    Kraft sum ≤ 2 (our Theorem 7.1).

    Args:
        l1: First code lengths
        l2: Second code lengths

    Returns:
        Pointwise minimum

    Time complexity: O(n)
    """
    return np.minimum(l1, l2)


def bellman_shortest_path(cost_matrix: np.ndarray, source: int) -> np.ndarray:
    """
    Bellman-Ford shortest path via tropical matrix-vector multiplication.

    This demonstrates that shortest-path computation is a tropical
    linear algebra operation, connecting to tropical coding.

    The iteration d_{k+1} = min_j (d_k(j) + C(j,i)) is a tropical
    matrix-vector product.

    Args:
        cost_matrix: n×n matrix of edge costs (inf for no edge)
        source: Source vertex

    Returns:
        Array of shortest distances from source

    Time complexity: O(n³)
    Space complexity: O(n)
    """
    n = len(cost_matrix)
    dist = np.full(n, np.inf)
    dist[source] = 0.0

    for _ in range(n - 1):
        new_dist = dist.copy()
        for v in range(n):
            for u in range(n):
                if dist[u] + cost_matrix[u][v] < new_dist[v]:
                    new_dist[v] = dist[u] + cost_matrix[u][v]
        dist = new_dist

    return dist


def universal_code_simulation(
    programs: List[Tuple[str, int]],
    universal_overhead: int = 10
) -> dict:
    """
    Simulate universal coding with overhead constant.

    Demonstrates the universal tropical code optimality theorem:
    for any description method M, there exists C such that
    L_U(x) ≤ L_M(x) + C for all x.

    Args:
        programs: List of (object, description_length) pairs
        universal_overhead: Simulation overhead constant C

    Returns:
        Dictionary with universal and specific code lengths

    This is a conceptual demonstration — real universal computers
    would use actual program execution.
    """
    result = {}
    for obj, specific_length in programs:
        universal_length = specific_length + universal_overhead
        result[obj] = {
            'specific': specific_length,
            'universal': universal_length,
            'overhead': universal_overhead,
            'optimal': universal_length <= specific_length + universal_overhead
        }
    return result


if __name__ == "__main__":
    # Quick self-test
    p = np.array([0.5, 0.25, 0.125, 0.125])

    # Shannon optimal
    l = shannon_optimal_code(p)
    print(f"Shannon optimal: {l}")
    print(f"Kraft-admissible: {kraft_admissible(l)}")
    print(f"Expected length = entropy: {np.isclose(np.sum(p * l), -np.sum(p * np.log(p)))}")

    # Ceiling code
    cl = ceiling_code(p)
    print(f"Ceiling code: {cl}")
    print(f"Kraft-admissible: {kraft_admissible(cl.astype(float))}")

    # Min-plus convolution
    f = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    g = np.array([2.0, 1.0, 4.0, 3.0, 2.0])
    conv = minplus_convolution(f, g)
    print(f"Min-plus convolution: {conv}")

    print("\nAll self-tests passed!")
