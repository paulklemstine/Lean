"""
algorithms.py — Tropical Shadow Entropy: Core Algorithms

Implements the shadow operator, shadow profile computation, entropy calculation,
and concavity testing for finite lattice supports in ℕ^n.
"""

from __future__ import annotations
import itertools
from typing import List, Tuple, Set, Optional
import math


def total_mass(v: Tuple[int, ...]) -> int:
    """Total mass (sum of coordinates) of a lattice vector."""
    return sum(v)


def kth_shadow(S: Set[Tuple[int, ...]], k: int, n: int) -> Set[Tuple[int, ...]]:
    """
    Compute the k-th shadow of a finite set S ⊆ ℕ^n.
    
    β ∈ Shadow_k(S) iff ∃ α ∈ S with β ≤ α componentwise
    and total_mass(α - β) = k.
    
    Args:
        S: Set of lattice points (tuples of non-negative integers)
        k: Shadow step parameter
        n: Ambient dimension
    
    Returns:
        The k-th shadow as a set of tuples
    
    Complexity: O(|S| * C(n+k-1, n-1)) per element — generates all
    multi-indices of mass k and checks feasibility.
    """
    if not S:
        return set()
    
    shadow = set()
    # For each α in S, find all β ≤ α with total_mass(α - β) = k
    for alpha in S:
        # Generate all multi-indices τ with total_mass(τ) = k and τ ≤ α
        for tau in _multiindices_of_mass(k, alpha):
            beta = tuple(alpha[i] - tau[i] for i in range(n))
            shadow.add(beta)
    return shadow


def _multiindices_of_mass(k: int, bound: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    """
    Generate all multi-indices τ with total_mass(τ) = k and τ_i ≤ bound_i.
    
    Uses recursive generation with pruning.
    """
    n = len(bound)
    if n == 0:
        return [()] if k == 0 else []
    
    results = []
    _gen_multiindex(k, bound, 0, n, [], results)
    return results


def _gen_multiindex(remaining: int, bound: Tuple[int, ...], idx: int, n: int,
                    current: list, results: list):
    if idx == n - 1:
        if remaining <= bound[idx]:
            results.append(tuple(current + [remaining]))
        return
    for v in range(min(remaining, bound[idx]) + 1):
        current.append(v)
        _gen_multiindex(remaining - v, bound, idx + 1, n, current, results)
        current.pop()


def shadow_card(S: Set[Tuple[int, ...]], k: int, n: int) -> int:
    """Cardinality of the k-th shadow."""
    return len(kth_shadow(S, k, n))


def support_max_deg(S: Set[Tuple[int, ...]]) -> int:
    """Maximum total mass in a support set."""
    if not S:
        return 0
    return max(total_mass(v) for v in S)


def shadow_entropy_pos(S: Set[Tuple[int, ...]], k: int, n: int) -> float:
    """
    Tropical shadow entropy with +1 convention:
    H_S(k) = log(|Shadow_k(S)| + 1)
    """
    card = shadow_card(S, k, n)
    return math.log(card + 1)


def shadow_entropy_drop(S: Set[Tuple[int, ...]], k: int, n: int) -> float:
    """Entropy drop: H(k+1) - H(k)."""
    return shadow_entropy_pos(S, k + 1, n) - shadow_entropy_pos(S, k, n)


def compute_shadow_profile(S: Set[Tuple[int, ...]], n: int) -> List[int]:
    """
    Compute the full shadow cardinality profile [|Sh_0(S)|, |Sh_1(S)|, ..., |Sh_D(S)|]
    where D = support_max_deg(S).
    
    Args:
        S: Finite support set
        n: Ambient dimension
    
    Returns:
        List of shadow cardinalities from k=0 to k=D
    
    Complexity: O(D * |S| * max_multiindices_per_step)
    """
    D = support_max_deg(S)
    return [shadow_card(S, k, n) for k in range(D + 1)]


def compute_entropy_profile(S: Set[Tuple[int, ...]], n: int) -> List[float]:
    """Compute [H_S(0), H_S(1), ..., H_S(D)]."""
    profile = compute_shadow_profile(S, n)
    return [math.log(c + 1) for c in profile]


def compute_entropy_drops(S: Set[Tuple[int, ...]], n: int) -> List[float]:
    """Compute [ΔH_S(0), ΔH_S(1), ..., ΔH_S(D-1)]."""
    entropy = compute_entropy_profile(S, n)
    return [entropy[k + 1] - entropy[k] for k in range(len(entropy) - 1)]


def test_log_concavity(profile: List[int]) -> Tuple[bool, Optional[int]]:
    """
    Test whether a cardinality profile is log-concave:
    profile[k+1]^2 >= profile[k] * profile[k+2] for all valid k.
    
    Returns:
        (is_log_concave, first_violation_index or None)
    """
    for k in range(len(profile) - 2):
        if profile[k + 1] ** 2 < profile[k] * profile[k + 2]:
            return False, k
    return True, None


def test_entropy_concavity(entropy: List[float], tol: float = 1e-10) -> Tuple[bool, Optional[int]]:
    """
    Test discrete concavity of entropy profile:
    2*H(k+1) >= H(k) + H(k+2)
    
    Returns:
        (is_concave, first_violation_index or None)
    """
    for k in range(len(entropy) - 2):
        if 2 * entropy[k + 1] < entropy[k] + entropy[k + 2] - tol:
            return False, k
    return True, None


def is_downward_closed(S: Set[Tuple[int, ...]], n: int) -> bool:
    """Check if S is downward-closed (an order ideal)."""
    for v in S:
        # Check all vectors ≤ v
        ranges = [range(v[i] + 1) for i in range(n)]
        for w in itertools.product(*ranges):
            if w not in S:
                return False
    return True


# --- Support Generators ---

def simplex_support(n: int, d: int) -> Set[Tuple[int, ...]]:
    """
    Generate the simplex support: {v ∈ ℕ^n | total_mass(v) ≤ d}.
    These are monomials of total degree ≤ d.
    """
    result = set()
    _gen_simplex(n, d, 0, [], result)
    return result


def _gen_simplex(n: int, remaining: int, idx: int, current: list, result: set):
    if idx == n:
        result.add(tuple(current))
        return
    for v in range(remaining + 1):
        current.append(v)
        _gen_simplex(n, remaining - v, idx + 1, current, result)
        current.pop()


def box_support(bounds: Tuple[int, ...]) -> Set[Tuple[int, ...]]:
    """
    Generate the box support: {v ∈ ℕ^n | v_i ≤ bounds_i for all i}.
    """
    ranges = [range(b + 1) for b in bounds]
    return set(itertools.product(*ranges))


def cross_polytope_support(n: int, d: int) -> Set[Tuple[int, ...]]:
    """
    Generate a cross-polytope-like support:
    {v ∈ ℕ^n | max(v_i) ≤ d}, downward-closed.
    This is actually a box with all bounds equal to d.
    """
    return box_support(tuple(d for _ in range(n)))


def degree_layer_card(S: Set[Tuple[int, ...]], t: int) -> int:
    """Number of elements with total mass exactly t."""
    return sum(1 for v in S if total_mass(v) == t)


def degree_layer_profile(S: Set[Tuple[int, ...]]) -> List[int]:
    """Compute [L_S(0), L_S(1), ..., L_S(D)]."""
    D = support_max_deg(S)
    return [degree_layer_card(S, t) for t in range(D + 1)]


if __name__ == "__main__":
    # Example: simplex in ℕ^2 with degree ≤ 3
    n, d = 2, 3
    S = simplex_support(n, d)
    print(f"Simplex support (n={n}, d={d}): {len(S)} elements")
    print(f"Downward-closed: {is_downward_closed(S, n)}")
    
    profile = compute_shadow_profile(S, n)
    print(f"Shadow profile: {profile}")
    
    entropy = compute_entropy_profile(S, n)
    print(f"Entropy profile: {[f'{e:.3f}' for e in entropy]}")
    
    drops = compute_entropy_drops(S, n)
    print(f"Entropy drops:   {[f'{d:.3f}' for d in drops]}")
    
    lc, idx = test_log_concavity(profile)
    print(f"Log-concave: {lc}" + (f" (violation at k={idx})" if idx is not None else ""))
    
    ec, idx = test_entropy_concavity(entropy)
    print(f"Entropy concave: {ec}" + (f" (violation at k={idx})" if idx is not None else ""))
