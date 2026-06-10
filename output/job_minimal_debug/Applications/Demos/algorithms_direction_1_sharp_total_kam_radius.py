#!/usr/bin/env python3
"""
Algorithms for Sharp KAM Threshold Theory
==========================================

Implements the verified algorithms from the research:
1. Resonance margin computation (finite adversarial radius)
2. Diophantine witness construction
3. Sign perturbation construction
4. Universal threshold certification
"""

from typing import List, Tuple, Optional
from itertools import product
import math


def enumerate_integer_modes(K: int, d: int = 2) -> List[Tuple[int, ...]]:
    """Enumerate all nonzero integer vectors k in Z^d with ||k||_1 <= K.
    
    Complexity: O((2K+1)^d) candidates, O(d) per filter.
    For d=2: O(K^2) modes.
    
    Args:
        K: Maximum L1 norm bound
        d: Dimension
    
    Returns:
        List of integer tuples representing admissible modes
    
    Example:
        >>> len(enumerate_integer_modes(3, 2))
        24
    """
    ranges = [range(-K, K + 1)] * d
    modes = []
    for k in product(*ranges):
        norm = sum(abs(ki) for ki in k)
        if 0 < norm <= K:
            modes.append(k)
    return modes


def lattice_inner_product(k: Tuple[int, ...], omega: Tuple[float, ...]) -> float:
    """Compute the lattice inner product k · ω = Σ k_i · ω_i.
    
    Args:
        k: Integer mode vector
        omega: Frequency vector
    
    Returns:
        The inner product as a float
    """
    return sum(ki * oi for ki, oi in zip(k, omega))


def l1_norm(k: Tuple[int, ...]) -> int:
    """Compute the L1 norm ||k||_1 = Σ |k_i|."""
    return sum(abs(ki) for ki in k)


def sup_norm(x: Tuple[float, ...]) -> float:
    """Compute the sup (infinity) norm ||x||_∞ = max |x_i|."""
    return max(abs(xi) for xi in x)


def compute_resonance_margin(K: int, omega: Tuple[float, ...]) -> Tuple[float, Optional[Tuple[int, ...]]]:
    """Compute the resonance margin (adversarial radius) for frequency ω at scale K.
    
    The resonance margin is:
        r_K(ω) = min_{0 < ||k||_1 ≤ K} |k · ω| / ||k||_1
    
    This is the exact ℓ∞-distance from ω to the nearest resonance hyperplane
    among all admissible modes.
    
    Complexity: O(K^d · d) where d = len(omega)
    
    Args:
        K: Scale parameter (maximum L1 norm)
        omega: Frequency vector
    
    Returns:
        (margin, critical_mode): The margin value and the mode achieving it
    
    Example:
        >>> margin, mode = compute_resonance_margin(5, (5.0, -1.0))
        >>> abs(margin - 0.2) < 1e-10
        True
    """
    modes = enumerate_integer_modes(K, len(omega))
    if not modes:
        return float('inf'), None
    
    best_ratio = float('inf')
    best_mode = None
    
    for k in modes:
        inner = abs(lattice_inner_product(k, omega))
        norm = l1_norm(k)
        ratio = inner / norm
        if ratio < best_ratio:
            best_ratio = ratio
            best_mode = k
    
    return best_ratio, best_mode


def construct_diophantine_witness(K: int, C: float) -> Tuple[float, ...]:
    """Construct a (K, C)-Diophantine frequency in dimension 2.
    
    Uses the verified construction ω = (K·C, -C).
    
    Theorem (diophantine_witness): For K ≥ 1 and C > 0, the frequency
    ω = (K·C, -C) satisfies |k·ω| ≥ C for all nonzero k with ||k||_1 ≤ K.
    
    Proof sketch: k·ω = C·(k₀·K - k₁). If k₀·K = k₁ then
    |k₀|·(K+1) ≤ ||k||_1 ≤ K, forcing k₀ = 0 and k₁ = 0.
    So |k₀·K - k₁| ≥ 1, giving |k·ω| ≥ C.
    
    Args:
        K: Scale parameter
        C: Diophantine constant
    
    Returns:
        Frequency vector ω = (K·C, -C)
    
    Example:
        >>> omega = construct_diophantine_witness(5, 1.0)
        >>> omega
        (5.0, -1.0)
    """
    return (float(K) * C, -C)


def construct_sign_perturbation(k: Tuple[int, ...], omega: Tuple[float, ...]) -> Tuple[float, ...]:
    """Construct the sign perturbation achieving exact resonance at mode k.
    
    The perturbation is:
        δ_i = -(k·ω / ||k||_1) · sign(k_i)
    
    This satisfies:
    1. ||δ||_∞ = |k·ω| / ||k||_1  (the resonance margin at mode k)
    2. k·(ω + δ) = 0  (exact resonance)
    
    The construction exploits ℓ¹/ℓ∞ duality: the sign vector of k
    is the dual extremizer that achieves equality in |k·δ| ≤ ||k||_1 · ||δ||_∞.
    
    Args:
        k: Integer mode vector (nonzero)
        omega: Frequency vector
    
    Returns:
        Perturbation vector δ
    
    Example:
        >>> k = (1, 4)
        >>> omega = (5.0, -1.0)
        >>> delta = construct_sign_perturbation(k, omega)
        >>> abs(lattice_inner_product(k, tuple(o+d for o,d in zip(omega, delta)))) < 1e-10
        True
    """
    inner = lattice_inner_product(k, omega)
    norm = l1_norm(k)
    
    delta = []
    for ki in k:
        if ki > 0:
            delta.append(-inner / norm)
        elif ki < 0:
            delta.append(inner / norm)
        else:
            delta.append(0.0)
    
    return tuple(delta)


def certify_safety(K: int, C: float, omega: Tuple[float, ...], 
                    budget: float) -> Tuple[bool, Optional[str]]:
    """Certify that perturbation budget is safe for (K,C)-Diophantine frequency.
    
    Uses the sharp threshold theorem:
    - If budget < C/K: SAFE (universal guarantee)
    - If budget ≥ C/K: check instance-specific margin
    
    Args:
        K: Scale parameter
        C: Diophantine constant
        omega: Frequency vector
        budget: Maximum perturbation budget (sup norm)
    
    Returns:
        (is_safe, reason): Safety certification with explanation
    
    Example:
        >>> omega = construct_diophantine_witness(5, 1.0)
        >>> certify_safety(5, 1.0, omega, 0.1)
        (True, 'Universal safety: budget 0.100 < C/K = 0.200')
    """
    critical = C / K
    
    if budget < critical:
        return True, f"Universal safety: budget {budget:.3f} < C/K = {critical:.3f}"
    
    margin, mode = compute_resonance_margin(K, omega)
    
    if budget < margin:
        return True, (f"Instance-specific safety: budget {budget:.3f} < margin {margin:.3f} "
                      f"(universal threshold C/K = {critical:.3f})")
    else:
        return False, (f"UNSAFE: budget {budget:.3f} ≥ margin {margin:.3f} "
                       f"(critical mode {mode})")


def find_critical_scaling(omega: Tuple[float, ...], K_range: range) -> List[Tuple[int, float, Tuple[int, ...]]]:
    """Study the scaling of the resonance margin r_K(ω) as K grows.
    
    For badly approximable frequencies (e.g., golden ratio), 
    K · r_K(ω) is expected to converge to a constant.
    
    Args:
        omega: Frequency vector
        K_range: Range of K values to scan
    
    Returns:
        List of (K, margin, critical_mode) tuples
    """
    results = []
    for K in K_range:
        margin, mode = compute_resonance_margin(K, omega)
        results.append((K, margin, mode))
    return results


if __name__ == "__main__":
    # Quick demonstration
    print("=== Algorithm Demonstration ===\n")
    
    K, C = 5, 1.0
    omega = construct_diophantine_witness(K, C)
    print(f"Diophantine witness: ω = {omega}")
    
    margin, mode = compute_resonance_margin(K, omega)
    print(f"Resonance margin: {margin:.6f}")
    print(f"Critical mode: {mode}")
    print(f"Critical budget C/K: {C/K:.6f}")
    
    delta = construct_sign_perturbation(mode, omega)
    print(f"\nSign perturbation: δ = ({delta[0]:.4f}, {delta[1]:.4f})")
    print(f"||δ||∞ = {sup_norm(delta):.6f}")
    
    residual = lattice_inner_product(mode, tuple(o+d for o,d in zip(omega, delta)))
    print(f"k·(ω+δ) = {residual:.2e}")
    
    print("\n--- Safety Certification ---")
    for budget in [0.1, 0.15, 0.2, 0.25, 0.5]:
        safe, reason = certify_safety(K, C, omega, budget)
        print(f"  B={budget:.2f}: {'✓' if safe else '✗'} {reason}")
