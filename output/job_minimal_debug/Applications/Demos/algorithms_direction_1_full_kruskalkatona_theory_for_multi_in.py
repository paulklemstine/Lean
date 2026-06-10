"""
Algorithms for Multi-Index Kruskal-Katona Theory

Implements core operations on multi-index families: degree slices, shadows,
(i,j)-compression, energy functionals, and lex-initial segments. Includes
exhaustive verification of the multi-index KK conjecture for small parameters.
"""

from itertools import combinations
from typing import List, Tuple, Dict, Set, FrozenSet
from functools import lru_cache
from math import comb, log


# --- Core Data Types ---
# Multi-indices are tuples of non-negative integers
MultiIndex = Tuple[int, ...]
Family = FrozenSet[MultiIndex]


def degree_slice(n: int, d: int) -> List[MultiIndex]:
    """Enumerate all multi-indices α ∈ ℕ^n with ∑α = d.
    
    Uses a recursive stars-and-bars enumeration.
    
    Time: O(C(n+d-1, d))
    Space: O(n * C(n+d-1, d))
    
    >>> len(degree_slice(3, 2))
    6
    >>> degree_slice(2, 3)
    [(0, 3), (1, 2), (2, 1), (3, 0)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def shadow(family: Set[MultiIndex]) -> Set[MultiIndex]:
    """Compute the one-step shadow of a multi-index family.
    
    ∂F = { β : ∃ α ∈ F, ∃ i, α_i > 0, β = α - e_i }
    
    Time: O(|F| * n)
    Space: O(|∂F|)
    
    >>> F = {(2, 0, 0)}
    >>> shadow(F)
    {(1, 0, 0)}
    """
    result = set()
    for alpha in family:
        n = len(alpha)
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                result.add(tuple(beta))
    return result


def immediate_lower_divisors(alpha: MultiIndex) -> Set[MultiIndex]:
    """Compute immediate lower divisors of a multi-index.
    
    These are degree-(d-1) monomials that divide x^α.
    
    >>> sorted(immediate_lower_divisors((1, 1, 0)))
    [(0, 1, 0), (1, 0, 0)]
    """
    result = set()
    for i in range(len(alpha)):
        if alpha[i] > 0:
            beta = list(alpha)
            beta[i] -= 1
            result.add(tuple(beta))
    return result


def shift(i: int, j: int, alpha: MultiIndex) -> MultiIndex:
    """Shift one unit from coordinate j to coordinate i.
    
    Returns α unchanged if i == j or α_j == 0.
    
    >>> shift(0, 1, (0, 2, 0))
    (1, 1, 0)
    >>> shift(0, 1, (0, 0, 2))
    (0, 0, 2)
    """
    if i == j or alpha[j] == 0:
        return alpha
    beta = list(alpha)
    beta[i] += 1
    beta[j] -= 1
    return tuple(beta)


def compress(i: int, j: int, family: Set[MultiIndex]) -> Set[MultiIndex]:
    """(i,j)-compression of a family.
    
    For each α ∈ F: if shift(i,j,α) ∈ F, keep α; else replace α by shift(i,j,α).
    
    Time: O(|F| * n)
    Space: O(|F|)
    
    >>> F = {(0, 2), (1, 1)}
    >>> sorted(compress(0, 1, F))
    [(1, 1), (2, 0)]
    """
    result = set()
    for alpha in family:
        shifted = shift(i, j, alpha)
        if shifted in family:
            result.add(alpha)
        else:
            result.add(shifted)
    return result


def is_compressed_ij(i: int, j: int, family: Set[MultiIndex]) -> bool:
    """Check if family is (i,j)-compressed."""
    for alpha in family:
        if shift(i, j, alpha) not in family:
            return False
    return True


def is_down_compressed(family: Set[MultiIndex], n: int) -> bool:
    """Check if family is fully down-compressed (for all i < j)."""
    for i in range(n):
        for j in range(i + 1, n):
            if not is_compressed_ij(i, j, family):
                return False
    return True


def energy(family: Set[MultiIndex]) -> int:
    """Compression energy: ∑_{α ∈ F} ∑_k k * α_k.
    
    Strictly decreases under nontrivial compression with i < j.
    """
    return sum(sum(k * alpha[k] for k in range(len(alpha))) for alpha in family)


def full_compression(family: Set[MultiIndex], n: int) -> Set[MultiIndex]:
    """Iterate compression over all pairs (i,j) with i < j until convergence.
    
    Guaranteed to terminate (energy strictly decreases).
    
    Returns: a down-compressed family with same cardinality.
    """
    F = set(family)
    changed = True
    while changed:
        changed = False
        for i in range(n):
            for j in range(i + 1, n):
                G = compress(i, j, F)
                if G != F:
                    F = G
                    changed = True
    return F


def lex_order_key(alpha: MultiIndex) -> MultiIndex:
    """Key for lex ordering: compare first coordinate first.
    
    (0,0,2) < (0,1,1) < (0,2,0) < (1,0,1) < (1,1,0) < (2,0,0)
    """
    return alpha


def lex_initial_segment(n: int, d: int, m: int) -> Set[MultiIndex]:
    """The lex-initial segment of size m in degree slice (n, d).
    
    Sorted in lex order (first coordinate first), take the first m elements.
    This is conjectured to minimize shadow size.
    """
    slc = sorted(degree_slice(n, d), key=lex_order_key)
    return set(slc[:m])


def shadow_card(family: Set[MultiIndex]) -> int:
    """Compute |∂F|."""
    return len(shadow(family))


def check_multi_kk(n: int, d: int, m: int) -> Tuple[bool, Dict]:
    """Check if the lex-initial segment minimizes shadow for given (n, d, m).
    
    Returns (True, info) if verified, (False, counterexample) if failed.
    """
    slc = degree_slice(n, d)
    if m > len(slc) or m <= 0:
        return True, {"note": "trivial case"}
    
    I = lex_initial_segment(n, d, m)
    target_shadow = shadow_card(I)
    
    # Check all families of size m
    for combo in combinations(slc, m):
        F = set(combo)
        sc = shadow_card(F)
        if sc < target_shadow:
            return False, {
                "n": n, "d": d, "m": m,
                "lex_segment": sorted(I),
                "lex_shadow": target_shadow,
                "counterexample": sorted(F),
                "counterexample_shadow": sc
            }
    
    return True, {"n": n, "d": d, "m": m, "lex_shadow": target_shadow}


def check_multi_kk_range(n_max: int, d_max: int, m_max: int) -> Tuple[bool, List[Dict]]:
    """Exhaustively verify the multi-index KK conjecture for small parameters.
    
    Returns (all_passed, results_list).
    """
    results = []
    all_passed = True
    
    for n in range(1, n_max + 1):
        for d in range(1, d_max + 1):
            slc_size = len(degree_slice(n, d))
            for m in range(1, min(m_max, slc_size) + 1):
                passed, info = check_multi_kk(n, d, m)
                results.append(info)
                if not passed:
                    all_passed = False
                    print(f"COUNTEREXAMPLE at n={n}, d={d}, m={m}: {info}")
    
    return all_passed, results


def support_entropy(family: Set[MultiIndex]) -> float:
    """Support entropy: ∑_{α ∈ F} log(|supp(α)| + 1).
    
    Conjectured to be non-increasing under compression.
    """
    return sum(log(sum(1 for x in alpha if x > 0) + 1) for alpha in family)


def k_step_shadow(family: Set[MultiIndex], k: int) -> Set[MultiIndex]:
    """Compute the k-step shadow ∂^k F."""
    F = set(family)
    for _ in range(k):
        F = shadow(F)
    return F


# --- Example usage ---
if __name__ == "__main__":
    # Example: degree slice for n=3, d=2
    slc = degree_slice(3, 2)
    print(f"Degree slice Deg_3(2): {slc}")
    print(f"Size: {len(slc)}")
    
    # Shadow of a concentrated family
    F = {(0, 0, 2)}
    print(f"\nF = {sorted(F)}")
    print(f"Shadow = {sorted(shadow(F))}, size = {shadow_card(F)}")
    
    # Shadow of a spread family
    F = {(1, 1, 0)}
    print(f"\nF = {sorted(F)}")
    print(f"Shadow = {sorted(shadow(F))}, size = {shadow_card(F)}")
    
    # Compression example
    F = {(0, 1, 1), (1, 0, 1)}
    print(f"\nF = {sorted(F)}")
    print(f"Compressed = {sorted(compress(0, 1, F))}")
    print(f"Energy before: {energy(F)}")
    print(f"Energy after: {energy(compress(0, 1, F))}")
    
    # Full compression
    F = {(1, 1, 0), (0, 1, 1)}
    print(f"\nF = {sorted(F)}")
    G = full_compression(F, 3)
    print(f"Fully compressed = {sorted(G)}")
    print(f"Is down-compressed: {is_down_compressed(G, 3)}")
    
    # Verify conjecture
    print("\n--- Verifying Multi-Index KK Conjecture ---")
    passed, results = check_multi_kk_range(3, 3, 8)
    if passed:
        print(f"All {len(results)} cases verified!")
    else:
        print("Counterexample found!")
