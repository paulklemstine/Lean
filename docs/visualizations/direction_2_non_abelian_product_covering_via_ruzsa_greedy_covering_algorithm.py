"""
Algorithms for non-abelian product covering analysis.

Implements the covering number computation, approximate subgroup detection,
and product set analysis for finite groups.
"""
from typing import Set, Tuple, List, Dict, Callable
from itertools import product as cart_product


def greedy_cover(A: Set, H: Set, mul_fn: Callable, inv_fn: Callable,
                 identity) -> Tuple[int, Set]:
    """
    Compute a covering of A by left translates of H using a greedy algorithm.
    
    Returns (C, T) where T is the set of translates and C = |T|.
    
    Algorithm: Repeatedly pick the translate covering the most uncovered elements.
    Time: O(|A|² · |H|)
    Space: O(|A| + |H|)
    """
    uncovered = set(A)
    T = set()
    
    while uncovered:
        a = next(iter(uncovered))
        best_t = None
        best_covered = set()
        
        for h in H:
            t = mul_fn(a, inv_fn(h))
            coset = {mul_fn(t, h2) for h2 in H}
            covered = uncovered & coset
            if len(covered) > len(best_covered):
                best_covered = covered
                best_t = t
        
        if best_t is None or not best_covered:
            break
        
        T.add(best_t)
        uncovered -= best_covered
    
    return len(T), T


def compute_doubling_constant(H: Set, mul_fn: Callable, inv_fn: Callable,
                               identity) -> Tuple[int, Set]:
    """
    Compute the minimal K such that H is a K-approximate subgroup.
    
    Returns (K, X) where H·H ⊆ X·H and |X| = K.
    Uses greedy set cover on H·H.
    
    Time: O(|H|³)
    """
    HH = {mul_fn(a, b) for a in H for b in H}
    K, X = greedy_cover(HH, H, mul_fn, inv_fn, identity)
    return K, X


def product_set(A: Set, B: Set, mul_fn: Callable) -> Set:
    """Compute A · B = {a·b : a ∈ A, b ∈ B}."""
    return {mul_fn(a, b) for a in A for b in B}


def is_approx_subgroup(H: Set, K: int, mul_fn: Callable, inv_fn: Callable,
                        identity) -> bool:
    """Check if H is a K-approximate subgroup."""
    if identity not in H:
        return False
    if not all(inv_fn(h) in H for h in H):
        return False
    actual_K, _ = compute_doubling_constant(H, mul_fn, inv_fn, identity)
    return actual_K <= K


def conjugation_index(H: Set, g, mul_fn: Callable, inv_fn: Callable) -> int:
    """
    Compute [H : H ∩ gHg⁻¹], the conjugation index.
    
    This measures how much g "distorts" H under conjugation.
    Returns |H| / |H ∩ g⁻¹Hg| (as integer, rounding up).
    """
    g_inv = inv_fn(g)
    conjugate_H = {mul_fn(g_inv, mul_fn(h, g)) for h in H}
    intersection = H & conjugate_H
    if not intersection:
        return len(H)
    return (len(H) + len(intersection) - 1) // len(intersection)


def analyze_covering(G_elems: list, A: Set, H: Set, mul_fn: Callable,
                      inv_fn: Callable, identity) -> Dict:
    """
    Complete covering analysis for a pair (A, H).
    
    Returns a dictionary with:
    - K: approximate subgroup constant
    - C: covering number of A by H
    - C_AA: covering number of A·A by H
    - bound_C2K: C²·K (commutative bound)
    - max_conj_index: maximum conjugation index
    - violation: whether any bound is violated
    """
    K, X = compute_doubling_constant(H, mul_fn, inv_fn, identity)
    C, T = greedy_cover(A, H, mul_fn, inv_fn, identity)
    
    AA = product_set(A, A, mul_fn)
    C_AA, T_AA = greedy_cover(AA, H, mul_fn, inv_fn, identity)
    
    # Compute max conjugation index
    max_L = 1
    for t in T:
        L = conjugation_index(H, t, mul_fn, inv_fn)
        max_L = max(max_L, L)
    
    bound_C2K = C**2 * K
    bound_C2K3 = C**2 * K**3
    bound_C2KL = C**2 * K * max_L
    
    return {
        'K': K, 'C': C, 'C_AA': C_AA,
        'A_size': len(A), 'H_size': len(H), 'AA_size': len(AA),
        'bound_C2K': bound_C2K,
        'bound_C2K3': bound_C2K3,
        'bound_C2KL': bound_C2KL,
        'max_conj_index': max_L,
        'violates_C2K': C_AA > bound_C2K,
        'violates_C2K3': C_AA > bound_C2K3,
        'violates_C2KL': C_AA > bound_C2KL,
    }
