#!/usr/bin/env python3
"""
Algorithms for the Bourgain–Gamburd Machine on Berggren Dynamics

Implements:
1. Multiplicative energy computation
2. Spectral contraction iteration
3. Product set growth measurement
4. Berggren generator reduction mod q
5. L² flattening detection
"""

import numpy as np
from typing import List, Tuple, Set, Callable, Optional
from collections import Counter


# ============================================================
# Algorithm 1: Multiplicative Energy
# ============================================================

def multiplicative_energy(
    A: List[int],
    group_op: Callable[[int, int], int]
) -> int:
    """
    Compute the multiplicative energy E(A) of a subset A in a finite group.

    E(A) = |{(a,b,c,d) ∈ A⁴ : op(a,b) = op(c,d)}|

    Equivalently, E(A) = Σ_g r_A(g)² where r_A(g) = |{(a,b) ∈ A² : op(a,b) = g}|.

    Time complexity: O(|A|² log |A|) using the representation function.
    Space complexity: O(|A|²).

    Args:
        A: List of group elements
        group_op: Binary group operation

    Returns:
        Multiplicative energy E(A)
    """
    # Build representation function
    rep = Counter()
    for a in A:
        for b in A:
            rep[group_op(a, b)] += 1

    # E(A) = sum of r(g)²
    return sum(r * r for r in rep.values())


def representation_function(
    A: List[int],
    group_op: Callable[[int, int], int]
) -> Counter:
    """
    Compute the representation function r_A(g) = |{(a,b) ∈ A² : op(a,b) = g}|.

    Time complexity: O(|A|²).

    Args:
        A: List of group elements
        group_op: Binary group operation

    Returns:
        Counter mapping g → r_A(g)
    """
    rep = Counter()
    for a in A:
        for b in A:
            rep[group_op(a, b)] += 1
    return rep


# ============================================================
# Algorithm 2: Product Set Growth
# ============================================================

def product_set(
    A: List[int],
    group_op: Callable[[int, int], int]
) -> Set[int]:
    """
    Compute the product set A·A = {op(a,b) : a,b ∈ A}.

    Time complexity: O(|A|²).
    Space complexity: O(|A·A|).

    Args:
        A: List of group elements
        group_op: Binary group operation

    Returns:
        Set of products
    """
    return {group_op(a, b) for a in A for b in A}


def triple_product_set(
    A: List[int],
    group_op: Callable[[int, int], int]
) -> Set[int]:
    """
    Compute the triple product A·A·A = {op(op(a,b),c) : a,b,c ∈ A}.

    Time complexity: O(|A|³).
    Space complexity: O(|A·A·A|).
    """
    AA = product_set(A, group_op)
    return {group_op(x, c) for x in AA for c in A}


def doubling_constant(
    A: List[int],
    group_op: Callable[[int, int], int]
) -> float:
    """
    Compute the doubling constant K = |A·A|/|A|.

    A set has small doubling if K is bounded.
    A subgroup satisfies K = 1.

    Args:
        A: List of group elements
        group_op: Binary group operation

    Returns:
        Doubling constant K
    """
    AA = product_set(A, group_op)
    return len(AA) / len(A)


# ============================================================
# Algorithm 3: Spectral Contraction
# ============================================================

def sibling_transition_matrix(n: int = 3) -> np.ndarray:
    """
    Construct the K_n random walk transition matrix.

    T(i,j) = 1/(n-1) if i ≠ j, 0 if i = j.

    For the Berggren tree, n=3, giving eigenvalue -1/2
    on the mean-zero subspace.

    Args:
        n: Number of vertices (default 3 for Berggren)

    Returns:
        n×n transition matrix
    """
    T = np.ones((n, n)) / (n - 1)
    np.fill_diagonal(T, 0)
    return T


def spectral_contraction(
    T: np.ndarray,
    f: np.ndarray,
    k: int
) -> List[float]:
    """
    Compute the L² norm squared of T^k f for k = 0, 1, ..., k.

    This demonstrates the spectral contraction: for mean-zero f,
    ‖T^k f‖₂² = ρ^k · ‖f‖₂² where ρ = (1/(n-1))².

    Args:
        T: Transition matrix
        f: Initial function (should be mean-zero for contraction)
        k: Number of iterations

    Returns:
        List of ‖T^i f‖₂² for i = 0, ..., k
    """
    norms = []
    current = f.copy().astype(float)
    for i in range(k + 1):
        norms.append(float(np.sum(current ** 2)))
        current = T @ current
    return norms


def verify_spectral_gap(
    T: np.ndarray,
    num_trials: int = 100,
    k_max: int = 20
) -> Tuple[float, float]:
    """
    Empirically verify the spectral gap of a transition matrix.

    Generates random mean-zero vectors and measures the contraction rate.

    Args:
        T: Transition matrix
        num_trials: Number of random trials
        k_max: Maximum iteration count

    Returns:
        (estimated_rho, theoretical_rho) where rho is the l² contraction rate
    """
    n = T.shape[0]
    ratios = []

    for _ in range(num_trials):
        f = np.random.randn(n)
        f -= f.mean()  # project to mean-zero
        if np.sum(f**2) < 1e-10:
            continue

        Tf = T @ f
        ratio = np.sum(Tf**2) / np.sum(f**2)
        ratios.append(ratio)

    estimated = np.mean(ratios)
    theoretical = 1.0 / (n - 1) ** 2

    return estimated, theoretical


# ============================================================
# Algorithm 4: Berggren Mod q
# ============================================================

def berggren_generators_mod_q(q: int) -> List[np.ndarray]:
    """
    Compute the Berggren generators B₁, B₂, B₃ reduced modulo q.

    Args:
        q: Modulus (should be ≥ 2)

    Returns:
        List of three 3×3 matrices over Z/qZ
    """
    B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
    B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
    B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

    return [B % q for B in [B1, B2, B3]]


def berggren_orbit_mod_q(
    q: int,
    depth: int = 5
) -> Set[Tuple[int, ...]]:
    """
    Compute the Berggren semigroup orbit of (3,4,5) mod q up to given depth.

    This generates all primitive Pythagorean triples mod q reachable
    from the root in at most `depth` steps.

    Args:
        q: Modulus
        depth: Maximum tree depth

    Returns:
        Set of triples (a,b,c) mod q
    """
    gens = berggren_generators_mod_q(q)
    root = np.array([3, 4, 5], dtype=int) % q

    visited = {tuple(root)}
    frontier = [root]

    for _ in range(depth):
        new_frontier = []
        for v in frontier:
            for B in gens:
                child = tuple((B @ v) % q)
                if child not in visited:
                    visited.add(child)
                    new_frontier.append(np.array(child, dtype=int))
        frontier = new_frontier

    return visited


def count_orbit_growth(q: int, max_depth: int = 10) -> List[int]:
    """
    Count cumulative orbit size at each depth for Berggren mod q.

    Args:
        q: Modulus
        max_depth: Maximum depth to explore

    Returns:
        List of cumulative orbit sizes at each depth
    """
    gens = berggren_generators_mod_q(q)
    root = np.array([3, 4, 5], dtype=int) % q

    visited = {tuple(root)}
    frontier = [root]
    sizes = [1]

    for d in range(max_depth):
        new_frontier = []
        for v in frontier:
            for B in gens:
                child = tuple((B @ v) % q)
                if child not in visited:
                    visited.add(child)
                    new_frontier.append(np.array(child, dtype=int))
        frontier = new_frontier
        sizes.append(len(visited))

    return sizes


# ============================================================
# Algorithm 5: Energy–Expansion Tradeoff Analysis
# ============================================================

def energy_expansion_tradeoff(
    group_size: int,
    group_op: Callable[[int, int], int],
    min_subset_size: int = 2,
    max_subset_size: Optional[int] = None
) -> List[Tuple[int, int, int, float]]:
    """
    Analyze the energy–expansion tradeoff for all arithmetic progressions
    in a cyclic group.

    For each subset size, compute E(A), |A+A|, and the ratio |A|⁴/(E(A)·|A+A|).
    The Cauchy–Schwarz bound guarantees this ratio ≤ 1.

    Args:
        group_size: Size of the cyclic group Z/nZ
        group_op: Group operation (addition mod n)
        min_subset_size: Minimum subset size to test
        max_subset_size: Maximum subset size (default: group_size - 1)

    Returns:
        List of (|A|, E(A), |A+A|, ratio) tuples
    """
    if max_subset_size is None:
        max_subset_size = group_size - 1

    results = []
    for size in range(min_subset_size, max_subset_size + 1):
        A = list(range(size))
        E = multiplicative_energy(A, group_op)
        AA = product_set(A, group_op)
        ratio = size**4 / (E * len(AA)) if E > 0 else 0
        results.append((size, E, len(AA), ratio))

    return results


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Bourgain–Gamburd Machine: Algorithm Suite")
    print("=" * 50)

    # Demo 1: Energy computation
    print("\n1. Multiplicative Energy in Z/17Z")
    op17 = lambda a, b: (a + b) % 17
    for A in [[0,1,2,3], [0,4,8,12], [0,1,2,3,4,5,6,7]]:
        E = multiplicative_energy(A, op17)
        AA = product_set(A, op17)
        K = doubling_constant(A, op17)
        print(f"   A={A}: E={E}, |AA|={len(AA)}, K={K:.2f}")

    # Demo 2: Spectral contraction
    print("\n2. Spectral Contraction Verification")
    T3 = sibling_transition_matrix(3)
    est, theo = verify_spectral_gap(T3)
    print(f"   Estimated ρ = {est:.6f}, Theoretical ρ = {theo:.6f}")

    # Demo 3: Berggren orbits
    print("\n3. Berggren Orbit Growth mod q")
    for q in [5, 7, 11, 13, 17]:
        sizes = count_orbit_growth(q, max_depth=8)
        print(f"   q={q:2d}: orbit sizes = {sizes}")

    # Demo 4: Energy-expansion tradeoff
    print("\n4. Energy-Expansion Tradeoff in Z/13Z")
    results = energy_expansion_tradeoff(13, lambda a, b: (a+b)%13, 2, 11)
    for size, E, AA, ratio in results:
        print(f"   |A|={size:2d}: E={E:5d}, |A+A|={AA:2d}, "
              f"|A|⁴/(E·|A+A|)={ratio:.4f} ≤ 1")

    print("\nAll algorithms executed successfully.")
