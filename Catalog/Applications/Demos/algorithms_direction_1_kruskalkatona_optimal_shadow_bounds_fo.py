"""
Algorithms for Kruskal-Katona Shadow Analysis of Circuit Supports.

Implements core algorithms for computing shadows, Minkowski sums, KK bounds,
and permanent support analysis.
"""

from itertools import permutations, combinations
from math import comb, factorial
from typing import Dict, List, Set, Tuple


# --- Type aliases ---
ExponentVector = Tuple[int, ...]
Family = Set[ExponentVector]


def one_shadow(S: Family, n: int) -> Family:
    """
    Compute the one-step shadow of a family S ⊆ ℕ^n.

    The one-shadow consists of all vectors obtainable from some α ∈ S
    by decrementing exactly one positive coordinate by 1.

    Args:
        S: A finite set of exponent vectors (tuples of non-negative ints).
        n: The dimension (number of coordinates).

    Returns:
        The one-shadow family.

    Time: O(|S| * n)
    Space: O(|S| * n) for the result set

    Example:
        >>> one_shadow({(2, 1, 0)}, 3)
        {(1, 1, 0), (2, 0, 0)}
    """
    shadow: Family = set()
    for alpha in S:
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def support_mul(A: Family, B: Family) -> Family:
    """
    Compute the Minkowski sum (support multiplication) of two families.

    For supports A and B, supportMul(A, B) = {a + b : a ∈ A, b ∈ B},
    where addition is pointwise on exponent vectors.

    This models the support of f * g in the absence of cancellation.

    Args:
        A: First family of exponent vectors.
        B: Second family of exponent vectors.

    Returns:
        The Minkowski sum family.

    Time: O(|A| * |B| * n)
    Space: O(|A| * |B|) for the result set

    Example:
        >>> support_mul({(1, 0)}, {(0, 1)})
        {(1, 1)}
    """
    result: Family = set()
    for a in A:
        for b in B:
            result.add(tuple(ai + bi for ai, bi in zip(a, b)))
    return result


def total_deg(alpha: ExponentVector) -> int:
    """Total degree of an exponent vector."""
    return sum(alpha)


def kk_lower_bound_squarefree(n: int, d: int, m: int) -> int:
    """
    Classical Kruskal-Katona lower bound for the shadow of m many d-subsets
    of an n-element ground set.

    For squarefree families of degree d with m elements, the minimum shadow
    size is achieved by the initial segment of the colex order.

    This implements an approximation using the cascading representation.
    For exact KK, we would need the full colex cascade decomposition.

    For uniform families (d-subsets), the KK theorem says the minimum shadow
    is achieved by taking the first m elements in colex order. We compute
    this using the cascade representation.

    Args:
        n: Number of variables.
        d: Degree (= size of each subset).
        m: Number of elements in the family.

    Returns:
        Lower bound on the shadow size.

    Time: O(n * d)
    Space: O(d) for the cascade representation
    """
    if d == 0 or m == 0:
        return 0
    if d > n:
        return 0

    # Cascade decomposition: m = C(a_d, d) + C(a_{d-1}, d-1) + ... + C(a_1, 1)
    # Shadow = C(a_d, d-1) + C(a_{d-1}, d-2) + ... + C(a_1, 0)
    cascade = _cascade_decomposition(m, d)
    shadow = sum(comb(a, k - 1) for a, k in cascade)
    return shadow


def _cascade_decomposition(m: int, d: int) -> List[Tuple[int, int]]:
    """
    Compute the d-cascade decomposition of m.

    Every non-negative integer m has a unique representation:
    m = C(a_d, d) + C(a_{d-1}, d-1) + ... + C(a_1, 1)
    where a_d > a_{d-1} > ... > a_1 ≥ 0.

    Args:
        m: The number to decompose.
        d: The top level of the cascade.

    Returns:
        List of (a_k, k) pairs in the cascade.
    """
    result = []
    remaining = m
    for k in range(d, 0, -1):
        # Find largest a such that C(a, k) ≤ remaining
        a = k - 1  # Start from minimum possible
        while comb(a + 1, k) <= remaining:
            a += 1
        if comb(a, k) > 0:
            result.append((a, k))
            remaining -= comb(a, k)
        if remaining == 0:
            break
    return result


def perm_exponent_vec(m: int, sigma: Tuple[int, ...]) -> ExponentVector:
    """
    Generate the exponent vector for a permutation on an m × m matrix.

    For permutation σ, the exponent vector α ∈ ℕ^(m²) has α[i*m + σ(i)] = 1
    and all other entries 0. This encodes the monomial ∏ᵢ x_{i,σ(i)}.

    Args:
        m: Matrix dimension.
        sigma: Permutation as a tuple (σ(0), σ(1), ..., σ(m-1)).

    Returns:
        Exponent vector of length m².
    """
    vec = [0] * (m * m)
    for i in range(m):
        vec[i * m + sigma[i]] = 1
    return tuple(vec)


def perm_support(m: int) -> Family:
    """
    Generate the permanent support for m × m matrices.

    The support of the permanent polynomial consists of all permutation
    matrices, encoded as squarefree exponent vectors.

    Args:
        m: Matrix dimension.

    Returns:
        Set of exponent vectors, one per permutation.

    Time: O(m! * m)
    Space: O(m! * m²)

    Example:
        >>> len(perm_support(3))  # 3! = 6 permutations
        6
    """
    family: Family = set()
    indices = list(range(m))
    for perm in permutations(indices):
        family.add(perm_exponent_vec(m, perm))
    return family


def shadow_gap(S: Family, n: int, d: int) -> int:
    """
    Compute the shadow gap: |Sh₁(S)| - KK_min(n, d, |S|).

    This measures how much the actual shadow exceeds the Kruskal-Katona
    minimum. A large shadow gap indicates the family is far from extremal.

    Args:
        S: Family of exponent vectors.
        n: Number of variables.
        d: Degree of the family.

    Returns:
        The shadow gap (non-negative for qualifying families).
    """
    sh = one_shadow(S, n)
    kk = kk_lower_bound_squarefree(n, d, len(S))
    return len(sh) - kk


def analyze_permanent_support(m: int) -> Dict:
    """
    Complete analysis of permanent support for m × m matrices.

    Computes support size, shadow size, KK lower bound, shadow gap,
    and the inflation ratio.

    Args:
        m: Matrix dimension.

    Returns:
        Dictionary with all computed statistics.
    """
    n = m * m  # Number of variables
    d = m      # Degree (each permutation matrix has exactly m ones)

    S = perm_support(m)
    sh = one_shadow(S, n)
    kk = kk_lower_bound_squarefree(n, d, len(S))

    result = {
        'matrix_size': m,
        'num_variables': n,
        'degree': d,
        'support_size': len(S),  # = m!
        'shadow_size': len(sh),
        'kk_lower_bound': kk,
        'shadow_gap': len(sh) - kk,
        'inflation_ratio': len(sh) / kk if kk > 0 else float('inf'),
        'expected_support_size': factorial(m),
    }
    return result


def circuit_shadow_bound(circuit_type: str, n: int,
                          left_size: int = 0, right_size: int = 0,
                          left_bound: int = 0, right_bound: int = 0) -> int:
    """
    Compute the recursive shadow bound for a support circuit.

    Args:
        circuit_type: One of 'atom', 'add', 'mul'.
        n: Number of variables.
        left_size: |eval(left child)| for mul gates.
        right_size: |eval(right child)| for mul gates.
        left_bound: Shadow bound of left child.
        right_bound: Shadow bound of right child.

    Returns:
        Upper bound on shadow size.
    """
    if circuit_type == 'atom':
        return n
    elif circuit_type == 'add':
        return left_bound + right_bound
    elif circuit_type == 'mul':
        return n * left_size * right_size
    else:
        raise ValueError(f"Unknown circuit type: {circuit_type}")


if __name__ == '__main__':
    # Quick self-test
    S = {(2, 1, 0), (1, 0, 1)}
    sh = one_shadow(S, 3)
    print(f"S = {S}")
    print(f"oneShadow(S) = {sh}")
    print(f"|S| = {len(S)}, |Sh(S)| = {len(sh)}")
    print()

    for m in range(2, 6):
        result = analyze_permanent_support(m)
        print(f"Permanent m={m}: support={result['support_size']}, "
              f"shadow={result['shadow_size']}, KK={result['kk_lower_bound']}, "
              f"gap={result['shadow_gap']}, ratio={result['inflation_ratio']:.3f}")
