#!/usr/bin/env python3
"""
algorithms.py — Algorithms for pseudofinite dimension computation.

Implements the computational methods for:
1. Computing pseudofinite dimension of definable sets
2. Finding minimal coset covers (greedy and exact)
3. Verifying the coset cover bound
4. Computing stabilizer chains
5. Shannon entropy computation and correspondence verification

All algorithms include complexity analysis in docstrings.
"""

import math
from typing import Callable, Optional
from itertools import product as cartesian_product


def pseudofinite_dimension(
    card_A: int,
    card_G: int,
) -> float:
    """
    Compute the pseudofinite dimension dim(A) = log|A| / log|G|.
    
    This is the fundamental invariant: the normalized log-cardinality
    of a definable set A in a finite group G.
    
    Args:
        card_A: Cardinality of the set A
        card_G: Cardinality of the ambient group G
    
    Returns:
        dim(A) ∈ [0, 1] when A ⊆ G
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Example:
        >>> pseudofinite_dimension(4, 16)  # |A|=4 in G of size 16
        0.5
        >>> pseudofinite_dimension(1, 100)  # singleton
        0.0
        >>> pseudofinite_dimension(100, 100)  # full group
        1.0
    """
    if card_G <= 1 or card_A <= 0:
        return 0.0
    return math.log(card_A) / math.log(card_G)


def greedy_coset_cover(
    G_elements: list,
    A: set,
    H: set,
    group_op: Callable,
) -> tuple[list, int]:
    """
    Find an approximate minimal coset cover of A by left cosets of H.
    
    Uses a greedy set-cover algorithm: at each step, pick the coset
    gH that covers the most uncovered elements of A.
    
    This is a ln(|A|)-approximation to the optimal cover.
    
    Args:
        G_elements: List of all elements of G
        A: The set to cover
        H: The subgroup (or subset) whose cosets we use
        group_op: The group operation (a, b) -> a * b
    
    Returns:
        (T, C) where T is the list of coset representatives and C = |T|
    
    Time complexity: O(|G| · |H| · C) where C is the cover size
    Space complexity: O(|G| + |A| + |H|)
    
    Example:
        >>> # Z/6Z, A = {0,1,2,3}, H = {0,3}
        >>> G = list(range(6))
        >>> greedy_coset_cover(G, {0,1,2,3}, {0,3}, lambda a,b: (a+b)%6)
        ([0, 1], 2)
    """
    uncovered = set(A)
    T = []
    
    while uncovered:
        best_t = None
        best_covered = set()
        
        for t in G_elements:
            coset = {group_op(t, h) for h in H}
            covered = uncovered & coset
            if len(covered) > len(best_covered):
                best_t = t
                best_covered = covered
        
        if best_t is None or not best_covered:
            break
        
        T.append(best_t)
        uncovered -= best_covered
    
    return T, len(T)


def exact_min_coset_cover(
    G_elements: list,
    A: set,
    H: set,
    group_op: Callable,
) -> tuple[list, int]:
    """
    Find the minimum coset cover of A by left cosets of H.
    
    Brute-force search over all possible cover sizes.
    
    Args:
        G_elements: List of all elements of G
        A: The set to cover
        H: The subgroup whose cosets we use
        group_op: The group operation
    
    Returns:
        (T, C) where T is an optimal cover and C = |T|
    
    Time complexity: O(|G|^C · |H|) where C is the optimal cover size
    Space complexity: O(|G| + |A| + |H|)
    """
    # Precompute all cosets
    cosets = {}
    for t in G_elements:
        coset = frozenset(group_op(t, h) for h in H)
        if coset not in cosets.values():
            cosets[t] = coset
    
    # Try covers of increasing size
    from itertools import combinations
    
    coset_list = list(cosets.items())
    
    for size in range(1, len(coset_list) + 1):
        for combo in combinations(coset_list, size):
            union = set()
            for _, coset in combo:
                union |= coset
            if A <= union:
                return [t for t, _ in combo], size
    
    return list(cosets.keys()), len(cosets)


def verify_coset_cover_bound(
    card_A: int,
    card_H: int,
    C: int,
    card_G: int,
) -> dict:
    """
    Verify the coset cover dimension bound:
        dim(A) ≤ dim(H) + log(C) / log|G|
    
    This is equivalent to the cardinality bound |A| ≤ C · |H|.
    
    Args:
        card_A: |A|
        card_H: |H|
        C: Number of cosets in the cover
        card_G: |G|
    
    Returns:
        Dictionary with dimensions, bound value, and verification status
    
    Time complexity: O(1)
    
    Example:
        >>> verify_coset_cover_bound(10, 5, 2, 100)
        {'dim_A': 0.5, 'dim_H': 0.349..., 'bound': 0.5, 'verified': True}
    """
    dim_A = pseudofinite_dimension(card_A, card_G)
    dim_H = pseudofinite_dimension(card_H, card_G)
    
    if card_G <= 1:
        return {"dim_A": 0, "dim_H": 0, "log_C_norm": 0, "bound": 0, 
                "verified": True, "card_bound": True}
    
    log_C_norm = math.log(max(1, C)) / math.log(card_G)
    bound = dim_H + log_C_norm
    
    return {
        "dim_A": dim_A,
        "dim_H": dim_H,
        "log_C_norm": log_C_norm,
        "bound": bound,
        "verified": dim_A <= bound + 1e-10,
        "card_bound": card_A <= C * card_H,
    }


def compute_stabilizer(
    G_elements: list,
    A: set,
    group_op: Callable,
    group_inv: Callable,
) -> set:
    """
    Compute the stabilizer Stab(A) = {g ∈ G : gA ⊆ A·A}.
    
    Args:
        G_elements: All elements of G
        A: The definable set
        group_op: Group operation
        group_inv: Group inverse
    
    Returns:
        The stabilizer set
    
    Time complexity: O(|G| · |A|²)
    Space complexity: O(|A|² + |G|)
    """
    # Compute A·A = {a₁·a₂ : a₁, a₂ ∈ A}
    AA = {group_op(a1, a2) for a1 in A for a2 in A}
    
    stab = set()
    for g in G_elements:
        # Check if gA ⊆ A·A
        gA = {group_op(g, a) for a in A}
        if gA <= AA:
            stab.add(g)
    
    return stab


def stabilizer_chain(
    G_elements: list,
    A: set,
    group_op: Callable,
    group_inv: Callable,
    card_G: int,
    max_steps: int = 20,
) -> list[dict]:
    """
    Compute the stabilizer descent chain.
    
    Starting from A₀ = A, iteratively compute:
        A_{k+1} = Stab(A_k) = {g ∈ G : g·A_k ⊆ A_k·A_k}
    
    The chain terminates when the stabilizer equals A or is trivial.
    The key theorem: dim(A_{k+1}) < dim(A_k) when A_k is a proper
    approximate subgroup.
    
    Args:
        G_elements: All elements of G
        A: Initial definable set
        group_op: Group operation
        group_inv: Group inverse
        card_G: |G|
        max_steps: Maximum number of descent steps
    
    Returns:
        List of dicts with step info (dimension, cardinality, etc.)
    
    Time complexity: O(max_steps · |G| · |A|²)
    """
    chain = []
    current = A
    
    for step in range(max_steps):
        dim = pseudofinite_dimension(len(current), card_G)
        chain.append({
            "step": step,
            "card": len(current),
            "dim": dim,
            "set": current.copy(),
        })
        
        if len(current) <= 1:
            break
        
        stab = compute_stabilizer(G_elements, current, group_op, group_inv)
        
        if stab == current or len(stab) >= len(current):
            # Stabilizer didn't decrease - A is already a subgroup
            chain.append({
                "step": step + 1,
                "card": len(stab),
                "dim": pseudofinite_dimension(len(stab), card_G),
                "set": stab,
                "note": "stabilized (A is a subgroup)",
            })
            break
        
        current = stab
    
    return chain


def shannon_entropy(probabilities: list[float]) -> float:
    """
    Compute Shannon entropy H = -Σ p_i log(p_i).
    
    Args:
        probabilities: List of probabilities (should sum to 1)
    
    Returns:
        Shannon entropy in nats
    
    Time complexity: O(n) where n = len(probabilities)
    """
    return -sum(p * math.log(p) for p in probabilities if p > 0)


def uniform_entropy(n: int) -> float:
    """
    Shannon entropy of uniform distribution on n elements.
    H(U_n) = log(n)
    
    Time complexity: O(1)
    """
    return math.log(n) if n > 0 else 0.0


def verify_entropy_dimension_correspondence(
    card_A: int,
    card_G: int,
) -> dict:
    """
    Verify the dimension-entropy correspondence:
        dim(A) = H(U_A) / log|G|
    
    where U_A is the uniform distribution on A.
    
    Args:
        card_A: |A|
        card_G: |G|
    
    Returns:
        Dictionary with dimension, entropy, and verification
    
    Time complexity: O(1)
    """
    dim = pseudofinite_dimension(card_A, card_G)
    H_A = uniform_entropy(card_A)
    log_G = math.log(card_G) if card_G > 1 else 1.0
    normalized = H_A / log_G
    
    return {
        "dimension": dim,
        "shannon_entropy": H_A,
        "log_G": log_G,
        "normalized_entropy": normalized,
        "correspondence_holds": abs(dim - normalized) < 1e-12,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Pseudofinite Dimension Algorithms ===\n")
    
    # Example 1: Basic dimension computation
    print("1. Basic dimension computation:")
    for card_A, card_G in [(4, 16), (8, 64), (1, 100), (100, 100)]:
        dim = pseudofinite_dimension(card_A, card_G)
        print(f"   |A|={card_A}, |G|={card_G} → dim(A) = {dim:.6f}")
    
    # Example 2: Coset cover in Z/12Z
    print("\n2. Coset cover in Z/12Z:")
    p = 12
    G = list(range(p))
    op = lambda a, b: (a + b) % p
    inv_op = lambda a: (-a) % p
    
    A = {0, 1, 2, 3, 4, 5}
    H = {0, 4, 8}  # subgroup of order 3
    
    T, C = greedy_coset_cover(G, A, H, op)
    print(f"   A = {sorted(A)}, H = {sorted(H)}")
    print(f"   Cover: T = {T}, C = {C}")
    result = verify_coset_cover_bound(len(A), len(H), C, p)
    print(f"   dim(A) = {result['dim_A']:.4f}, bound = {result['bound']:.4f}, verified = {result['verified']}")
    
    # Example 3: Stabilizer chain in Z/7Z
    print("\n3. Stabilizer chain in Z/7Z:")
    p = 7
    G = list(range(p))
    op = lambda a, b: (a + b) % p
    inv_op = lambda a: (-a) % p
    
    A = {0, 1, 2, 6}  # symmetric set containing identity
    chain = stabilizer_chain(G, A, op, inv_op, p)
    for entry in chain:
        note = entry.get("note", "")
        print(f"   Step {entry['step']}: |A| = {entry['card']}, "
              f"dim = {entry['dim']:.4f} {note}")
    
    # Example 4: Entropy correspondence
    print("\n4. Entropy-dimension correspondence:")
    for card_A, card_G in [(5, 23), (10, 101), (50, 997)]:
        result = verify_entropy_dimension_correspondence(card_A, card_G)
        print(f"   |A|={card_A}, |G|={card_G}: "
              f"dim={result['dimension']:.6f}, H/log|G|={result['normalized_entropy']:.6f}, "
              f"match={result['correspondence_holds']}")
