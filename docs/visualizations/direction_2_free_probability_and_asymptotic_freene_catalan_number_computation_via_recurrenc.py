#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for the Noncrossing Bridge

Implements the moment-cumulant formula for computing Kesten-McKay moments
via noncrossing partition enumeration. These algorithms are the computational
counterparts of the formally verified Lean theorems.

Algorithms:
1. Catalan number computation via the recurrence (matches catalanCompute in Lean)
2. Kesten-McKay moment computation via free cumulants
3. Noncrossing partition enumeration
4. Spectral bound computation from moment estimates
"""

from math import comb, sqrt
from typing import List, Tuple, Dict, Optional
from functools import lru_cache


# ============================================================
# Algorithm 1: Catalan Numbers via Recurrence
# ============================================================
# Pseudocode:
#   CATALAN(n):
#     if n = 0: return 1
#     return Σ_{i=0}^{n-1} CATALAN(i) · CATALAN(n-1-i)
#
# Time complexity: O(n²) with memoization
# Space complexity: O(n)
# ============================================================

@lru_cache(maxsize=None)
def catalan(n: int) -> int:
    """Compute the n-th Catalan number via the defining recurrence.
    
    This matches the formally verified `catalanCompute` in Lean 4,
    proved equal to the standard Catalan number by `catalanCompute_eq_catalan`.
    
    C_0 = 1
    C_{n+1} = Σ_{i=0}^{n} C_i · C_{n-i}
    
    Args:
        n: Non-negative integer index.
    
    Returns:
        The n-th Catalan number.
    
    Examples:
        >>> [catalan(i) for i in range(8)]
        [1, 1, 2, 5, 14, 42, 132, 429]
    """
    if n < 0:
        raise ValueError(f"Catalan number undefined for negative index {n}")
    if n == 0:
        return 1
    return sum(catalan(i) * catalan(n - 1 - i) for i in range(n))


def catalan_closed_form(n: int) -> int:
    """Compute C_n via the closed form C(2n,n)/(n+1).
    
    Equivalent to the recurrence by `catalan_unique_recurrence`.
    """
    return comb(2 * n, n) // (n + 1)


# ============================================================
# Algorithm 2: Kesten-McKay Moment Computation
# ============================================================
# Pseudocode:
#   KM_MOMENT(d, k):
#     if k = 0: return 1
#     return CATALAN(k) · d · (d-1)^{k-1}
#
# Time complexity: O(k) (after Catalan memoization)
# Space complexity: O(1)
# ============================================================

def kesten_mckay_moment(d: int, k: int) -> float:
    """Compute the 2k-th moment of the Kesten-McKay distribution.
    
    For the d-regular tree, μ_{2k} = C_k · d · (d-1)^{k-1}.
    
    This matches the formally verified `momentKestenMcKay` in Lean 4.
    Odd moments vanish by symmetry (`momentKestenMcKay_odd`).
    
    The formula arises from the moment-cumulant formula:
    μ_{2k} = Σ_{π ∈ NC₂(2k)} ∏_{B ∈ π} κ_{|B|}
    where only κ₂ = d is nonzero, giving C_k · d^k in the centered case.
    
    Args:
        d: Degree of the regular tree (d ≥ 2).
        k: Half the moment index (μ_{2k}).
    
    Returns:
        The 2k-th moment μ_{2k}.
    
    Examples:
        >>> kesten_mckay_moment(4, 0)  # μ_0 = 1
        1.0
        >>> kesten_mckay_moment(4, 1)  # μ_2 = d = 4
        4.0
    """
    if k == 0:
        return 1.0
    return float(catalan(k) * d * (d - 1) ** (k - 1))


def kesten_mckay_spectral_radius(d: int) -> float:
    """Compute the spectral radius of the Kesten-McKay distribution.
    
    The support of KM_d is [-2√(d-1), 2√(d-1)], so the spectral
    radius is 2√(d-1). This is the Alon-Boppana bound.
    
    The moment bound μ_{2k} ≤ (4(d-1))^k · d (proven as
    `momentKestenMcKay_bound`) implies this via:
    ρ = lim_{k→∞} μ_{2k}^{1/(2k)} = 2√(d-1).
    """
    return 2 * sqrt(d - 1)


# ============================================================
# Algorithm 3: Noncrossing Partition Enumeration
# ============================================================
# Pseudocode:
#   NC_ENUMERATE(n):
#     if n = 0: return [{}]  (single empty partition)
#     result = []
#     for each way to pair element 0 with element 2j-1:
#       for π₁ ∈ NC_ENUMERATE(j-1):  (inner partitions)
#         for π₂ ∈ NC_ENUMERATE(n-j):  (outer partitions)
#           result.append(merge(π₁, π₂, {0, 2j-1}))
#     return result
#
# Time complexity: O(C_n · n) (generating all C_n partitions)
# Space complexity: O(C_n · n)
# ============================================================

def enumerate_noncrossing_partitions(n: int) -> List[List[frozenset]]:
    """Enumerate all noncrossing partitions of {0, ..., n-1}.
    
    Uses the recursive decomposition: a noncrossing partition of {0,...,n-1}
    is determined by the block B containing 0. If B = {0, j₁, j₂, ...},
    the elements between consecutive members of B form independent
    noncrossing sub-partitions.
    
    This decomposition is the same one that proves |NC(n)| = C_n,
    formalized in `catalan_unique_recurrence`.
    
    Args:
        n: Size of the ground set.
    
    Returns:
        List of all noncrossing partitions, each as a list of frozensets.
    """
    if n == 0:
        return [[]]
    if n == 1:
        return [[frozenset({0})]]
    
    result = []
    
    def _enumerate(elements: list) -> List[List[frozenset]]:
        """Enumerate NC partitions of the given sorted elements."""
        m = len(elements)
        if m == 0:
            return [[]]
        if m == 1:
            return [[frozenset({elements[0]})]]
        
        first = elements[0]
        partitions = []
        
        # The block containing 'first' also contains elements[k] for some k
        # Elements between first and elements[k] form an inner partition
        # Elements after elements[k] form an outer partition
        for k in range(m):
            if k == 0:
                # first is alone in its block
                for rest_part in _enumerate(elements[1:]):
                    partitions.append([frozenset({first})] + rest_part)
            else:
                inner_elems = elements[1:k]
                outer_elems = elements[k+1:]
                block = frozenset({first, elements[k]})
                
                for inner_part in _enumerate(inner_elems):
                    for outer_part in _enumerate(outer_elems):
                        # But we need to handle multi-element blocks too
                        # For simplicity, only consider pair partitions here
                        partitions.append([block] + inner_part + outer_part)
        
        return partitions
    
    # Simple approach: generate all set partitions and filter for noncrossing
    return _enumerate_all_nc(n)


def _enumerate_all_nc(n: int) -> List[List[frozenset]]:
    """Enumerate NC partitions by generating all partitions and filtering."""
    elements = list(range(n))
    
    def _all_partitions(elems):
        if not elems:
            yield []
            return
        first = elems[0]
        rest = elems[1:]
        for partition in _all_partitions(rest):
            # Add first to each existing block
            for i in range(len(partition)):
                new_part = [b.copy() for b in partition]
                new_part[i] = new_part[i] | {first}
                yield new_part
            # Start new block
            yield [{first}] + partition
    
    def _is_noncrossing(partition):
        blocks = [sorted(b) for b in partition]
        for i, b1 in enumerate(blocks):
            for j, b2 in enumerate(blocks):
                if i >= j:
                    continue
                for a in b1:
                    for c in b1:
                        if a >= c:
                            continue
                        for b in b2:
                            for d in b2:
                                if b >= d:
                                    continue
                                if a < b < c < d:
                                    return False
        return True
    
    result = []
    for part in _all_partitions(elements):
        frozen = [frozenset(b) for b in part]
        if _is_noncrossing(frozen):
            result.append(frozen)
    return result


# ============================================================
# Algorithm 4: Free Cumulant Extraction
# ============================================================

def free_cumulants_from_moments(moments: List[float], max_order: int) -> List[float]:
    """Extract free cumulants from moments via Möbius inversion on NC.
    
    Uses the moment-cumulant formula:
    μ_n = Σ_{π ∈ NC(n)} ∏_{B ∈ π} κ_{|B|}
    
    Inverted to get κ_n from μ_1, ..., μ_n.
    
    This is the computational form of the moment-cumulant inversion
    that underpins `semicircle_moment_cumulant`.
    
    Args:
        moments: List of moments [μ_1, μ_2, ..., μ_N].
        max_order: Maximum cumulant order to extract.
    
    Returns:
        List of free cumulants [κ_1, κ_2, ..., κ_max_order].
    """
    kappas = [0.0] * (max_order + 1)
    
    # κ_1 = μ_1
    if len(moments) >= 1:
        kappas[1] = moments[0]
    
    # κ_2 = μ_2 - μ_1²  (from NC(2) = {{1,2}, {1},{2}})
    if len(moments) >= 2:
        kappas[2] = moments[1] - moments[0] ** 2
    
    # Higher orders require full NC enumeration
    for n in range(3, min(max_order + 1, len(moments) + 1)):
        # μ_n = κ_n + (lower order contributions from NC(n))
        nc_partitions = _enumerate_all_nc(n)
        lower_contrib = 0.0
        for part in nc_partitions:
            if len(part) == 1 and len(list(part[0])) == n:
                continue  # Skip the single-block partition (gives κ_n)
            prod = 1.0
            for block in part:
                block_size = len(block)
                if block_size <= max_order and block_size < n:
                    prod *= kappas[block_size]
                else:
                    prod = 0.0
                    break
            lower_contrib += prod
        kappas[n] = moments[n - 1] - lower_contrib
    
    return kappas[1:]


# ============================================================
# Algorithm 5: Spectral Moment Bound
# ============================================================

def spectral_moment_bound(d: int, k: int) -> float:
    """Upper bound on μ_{2k} from the Catalan-based estimate.
    
    Uses the formally proven bound: μ_{2k} ≤ (4(d-1))^k · d
    (theorem `momentKestenMcKay_bound`).
    
    This gives the spectral radius bound ρ ≤ 2√(d-1),
    which is the Alon-Boppana bound for d-regular graphs.
    """
    return (4.0 * (d - 1)) ** k * d


# ============================================================
# Examples
# ============================================================

if __name__ == "__main__":
    print("=== Catalan Numbers ===")
    for n in range(10):
        c1 = catalan(n)
        c2 = catalan_closed_form(n)
        assert c1 == c2
        print(f"C_{n} = {c1}")
    
    print("\n=== Kesten-McKay Moments (d=4) ===")
    for k in range(6):
        mu = kesten_mckay_moment(4, k)
        bound = spectral_moment_bound(4, k)
        print(f"μ_{2*k:2d} = {mu:12.0f}  (bound: {bound:12.0f})")
    
    print(f"\nSpectral radius (d=4): {kesten_mckay_spectral_radius(4):.6f}")
    
    print("\n=== Noncrossing Partitions ===")
    for n in range(6):
        nc = _enumerate_all_nc(n)
        print(f"|NC({n})| = {len(nc)} = C_{n} = {catalan(n)}")
    
    print("\n=== Free Cumulant Extraction ===")
    # For the Kesten-McKay distribution with d=4:
    # μ_{2k} = C_k · 4^k (centered), so moments are [0, 4, 0, 32, 0, 256, ...]
    # The centered moments for the semicircle with κ_2 = 4:
    # μ_1 = 0, μ_2 = 4, μ_3 = 0, μ_4 = 2·16 = 32, ...
    moments = [0, 4, 0, 2 * 16, 0, 5 * 64]
    kappas = free_cumulants_from_moments(moments, 6)
    print(f"Extracted cumulants: κ = {kappas}")
    print(f"Expected: κ_1=0, κ_2=4, κ_n=0 for n≥3")
