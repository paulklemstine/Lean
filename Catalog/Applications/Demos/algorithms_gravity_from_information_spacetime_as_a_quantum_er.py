#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for quantum error-correcting code analysis
in the holographic gravity framework.
"""

from typing import List, Tuple, Dict, Set, Optional, FrozenSet
import math


def validate_qecc(n: int, k: int, d: int) -> Dict[str, bool]:
    """
    Validate a quantum error-correcting code [[n, k, d]].

    Returns a dictionary of satisfied/violated constraints:
    - 'k_le_n': k ≤ n
    - 'd_ge_1': d ≥ 1
    - 'singleton': 2d + k ≤ n + 2
    - 'bpt': kd² ≤ n (BPT bound)
    - 'is_mds': 2d + k = n + 2 (MDS condition)
    """
    return {
        'k_le_n': k <= n,
        'd_ge_1': d >= 1,
        'singleton': 2 * d + k <= n + 2,
        'bpt': k * d ** 2 <= n,
        'is_mds': 2 * d + k == n + 2,
    }


def singleton_deficit(n: int, k: int, d: int) -> int:
    """Compute the Singleton deficit Δ = (n + 2) - (2d + k)."""
    return max(0, (n + 2) - (2 * d + k))


def entropy(n: int, k: int) -> int:
    """Entanglement entropy S = n - k."""
    return n - k


def erasure_threshold(n: int, d: int) -> int:
    """
    Minimum region size for bulk reconstruction.
    Returns the threshold s₀ such that reconstruction ↔ s ≥ s₀.
    """
    return n - d + 1


def reconstruction_phase_diagram(n: int, k: int, d: int) -> List[Dict]:
    """
    Compute the full reconstruction phase diagram for a code [[n, k, d]].
    For each region size s, determines if reconstruction is possible
    and if the complement can reconstruct.
    """
    threshold = erasure_threshold(n, d)
    results = []
    for s in range(n + 1):
        rec = s >= threshold
        comp_rec = (n - s) >= threshold
        results.append({
            'size': s,
            'reconstructs': rec,
            'complement_reconstructs': comp_rec,
            'no_cloning_satisfied': not (rec and comp_rec) if k >= 1 else True,
        })
    return results


def concatenate_codes(
    n1: int, k1: int, d1: int,
    n2: int, k2: int, d2: int,
) -> Tuple[int, int, int]:
    """Concatenate two codes: [[n₁n₂, k₁k₂, d₁d₂]]."""
    return n1 * n2, k1 * k2, d1 * d2


def toric_code_params(L: int) -> Tuple[int, int, int]:
    """Toric code parameters for grid size L: [[2L², 2, L]]."""
    return 2 * L ** 2, 2, L


def happy_code_params(level: int) -> Tuple[int, int, int]:
    """HaPPY code parameters at level L: [[5(L+1), L+1, 3]]."""
    return 5 * (level + 1), level + 1, 3


def weighted_singleton_bound(weights: List[int], k: int, d: int) -> bool:
    """
    Check the weighted Singleton bound: Σwᵢ - k ≥ 2(d-1).
    All weights must be ≥ 1.
    """
    total_weight = sum(weights)
    return total_weight - k >= 2 * (d - 1)


def syndrome_defect(
    S: Dict[FrozenSet[int], float],
    X: FrozenSet[int],
    Y: FrozenSet[int],
) -> float:
    """
    Compute the syndrome defect for a submodular entropy function S.
    defect(X, Y) = S(X) + S(Y) - S(X∩Y) - S(X∪Y)
    """
    return S[X] + S[Y] - S[X & Y] - S[X | Y]


def holographic_mutual_info(sA: int, sB: int, sAB: int) -> int:
    """Mutual information I(A:B) = S(A) + S(B) - S(A∪B)."""
    return sA + sB - sAB


def bekenstein_hawking_entropy(
    area: float,
    G: float = 1.0,
) -> float:
    """Bekenstein-Hawking entropy S = A/(4G)."""
    return area / (4 * G)


def planck_discretization(
    area: float,
    geodesic_dist: float,
    planck_length: float = 1.0,
    G: float = 0.25,
) -> Dict[str, float]:
    """
    Compute the holographic code parameters from continuous geometry.

    Returns:
    - n: number of Planck areas = A/ℓ_P²
    - k: Bekenstein entropy = A/(4G)
    - d: code distance = L/(2ℓ_P)
    - singleton_satisfied: whether 2d + k ≤ n + 2
    """
    n = area / planck_length ** 2
    k = area / (4 * G)
    d = geodesic_dist / (2 * planck_length)

    return {
        'n': n,
        'k': k,
        'd': d,
        'singleton_satisfied': 2 * d + k <= n + 2,
        'deficit': max(0, n + 2 - 2 * d - k),
    }


def code_family_analysis(
    family_name: str,
    params_fn,
    L_range: range,
) -> List[Dict]:
    """
    Analyze a code family across a range of parameters.
    Returns detailed analysis for each family member.
    """
    results = []
    for L in L_range:
        n, k, d = params_fn(L)
        delta = singleton_deficit(n, k, d)
        S = entropy(n, k)
        threshold = erasure_threshold(n, d)
        bpt = k * d ** 2
        results.append({
            'L': L,
            'n': n, 'k': k, 'd': d,
            'entropy': S,
            'deficit': delta,
            'threshold': threshold,
            'bpt_ratio': bpt / n if n > 0 else 0,
            'is_mds': delta == 0,
            'bpt_saturated': bpt == n,
        })
    return results


if __name__ == "__main__":
    # Example usage
    print("Toric code family analysis:")
    results = code_family_analysis("Toric", toric_code_params, range(1, 6))
    for r in results:
        print(f"  L={r['L']}: [[{r['n']},{r['k']},{r['d']}]], "
              f"S={r['entropy']}, Δ={r['deficit']}, BPT={r['bpt_saturated']}")

    print("\nHaPPY code family analysis:")
    results = code_family_analysis("HaPPY", happy_code_params, range(0, 5))
    for r in results:
        print(f"  L={r['L']}: [[{r['n']},{r['k']},{r['d']}]], "
              f"S={r['entropy']}, Δ={r['deficit']}, MDS={r['is_mds']}")
