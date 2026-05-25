#!/usr/bin/env python3
"""
algorithms.py — Certified Subgroup Pair Pressure Computation

Implements algorithms for computing the subgroup pair pressure,
free energy, and entropy-energy decomposition for finite group
subgroup families.

All algorithms correspond to formally verified definitions in
SubgroupPressure.lean.

application keywords: random generation, permutation groups, wreath products,
subgroup sieve, phase transitions, partition function, free energy
"""

import math
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class SubgroupData:
    """Data for a single subgroup in a covering family."""
    name: str
    index: int  # [G : H]
    order: int  # |H|


@dataclass 
class PressureResult:
    """Result of a pressure computation."""
    pressure: float
    free_energy: float
    num_subgroups: int
    entropy: float     # log(num_subgroups)
    min_energy: float  # 2 * log(min_index)
    effective_phi: float  # entropy - min_energy
    individual_terms: List[float]
    upper_bound: float  # |F| / D^2
    lower_bound: float  # |F| / d^2


def compute_pressure(
    subgroups: List[SubgroupData],
    group_order: Optional[int] = None
) -> PressureResult:
    """
    Compute the subgroup pair pressure and associated thermodynamic quantities.
    
    Implements the formally verified definition:
        pressure(G, F) = ∑_{H ∈ F} [G : H]^{-2}
    
    Args:
        subgroups: List of SubgroupData with index information
        group_order: Order of the ambient group (optional, for validation)
    
    Returns:
        PressureResult with all computed quantities
    
    Time complexity: O(|F|)
    Space complexity: O(|F|)
    """
    if not subgroups:
        return PressureResult(
            pressure=0.0, free_energy=float('inf'),
            num_subgroups=0, entropy=0.0, min_energy=0.0,
            effective_phi=float('-inf'),
            individual_terms=[], upper_bound=0.0, lower_bound=0.0
        )
    
    indices = [s.index for s in subgroups if s.index > 0]
    n = len(indices)
    
    # Compute individual terms [G:H]^{-2}
    terms = [1.0 / (idx ** 2) for idx in indices]
    
    # Pressure = sum of terms
    pressure = sum(terms)
    
    # Free energy F = -log(pressure)
    fe = -math.log(pressure) if pressure > 0 else float('inf')
    
    # Entropy = log(|F|)
    entropy = math.log(n) if n > 0 else 0.0
    
    # Min/max index for bounds
    min_idx = min(indices)
    max_idx = max(indices)
    
    # Min energy = 2 * log(min_index)
    min_energy = 2 * math.log(min_idx)
    
    # Effective free energy Φ = entropy - min_energy
    phi = entropy - min_energy
    
    # Theorem-certified bounds:
    # Upper bound: pressure ≤ |F| / D^2 where D = min index
    upper = n / (min_idx ** 2)
    
    # Lower bound: pressure ≥ |F| / d^2 where d = max index
    lower = n / (max_idx ** 2)
    
    return PressureResult(
        pressure=pressure,
        free_energy=fe,
        num_subgroups=n,
        entropy=entropy,
        min_energy=min_energy,
        effective_phi=phi,
        individual_terms=terms,
        upper_bound=upper,
        lower_bound=lower
    )


def compute_product_pressure(
    result_G: PressureResult,
    result_K: PressureResult
) -> PressureResult:
    """
    Compute pressure for a product family using the factorization theorem.
    
    Implements the formally verified identity:
        pressure(G × K, F × E) = pressure(G, F) · pressure(K, E)
    
    This is O(1) given precomputed pressures, vs O(|F|·|E|) naively.
    
    Args:
        result_G: Pressure result for the first factor
        result_K: Pressure result for the second factor
    
    Returns:
        PressureResult for the product family
    """
    prod_pressure = result_G.pressure * result_K.pressure
    prod_fe = result_G.free_energy + result_K.free_energy  # Additivity!
    
    n_prod = result_G.num_subgroups * result_K.num_subgroups
    
    return PressureResult(
        pressure=prod_pressure,
        free_energy=prod_fe,
        num_subgroups=n_prod,
        entropy=result_G.entropy + result_K.entropy,
        min_energy=result_G.min_energy + result_K.min_energy,
        effective_phi=result_G.effective_phi + result_K.effective_phi,
        individual_terms=[],  # Too many to list for products
        upper_bound=result_G.upper_bound * result_K.upper_bound,
        lower_bound=result_G.lower_bound * result_K.lower_bound
    )


def compute_block_defect_pressure(
    k: int, m: int,
    subgroups_of_Sk: List[SubgroupData]
) -> PressureResult:
    """
    Compute coordinate-defect pressure for S_k^m.
    
    For the base group G = S_k^m of the wreath product S_k ≀ S_m,
    coordinate-defect subgroups have the form
        H_{j,M} = {g ∈ G : π_j(g) ∈ M}
    with [G : H_{j,M}] = [S_k : M].
    
    The total pressure is:
        m · ∑_{M ∈ F} [S_k : M]^{-2}
    
    This is the formal content of the block-defect pressure theorem:
    pressure scales linearly in m (the block count).
    
    Args:
        k: Size of each block (S_k)
        m: Number of blocks
        subgroups_of_Sk: Subgroup family of S_k
    
    Returns:
        PressureResult for the block-defect family
    """
    sk_result = compute_pressure(subgroups_of_Sk)
    
    # Block defect pressure = m * pressure(S_k)
    block_pressure = m * sk_result.pressure
    
    # Free energy: F = -log(m * p) = -log(m) - log(p)
    if block_pressure > 0:
        block_fe = -math.log(block_pressure)
    else:
        block_fe = float('inf')
    
    total_subgroups = m * sk_result.num_subgroups
    
    return PressureResult(
        pressure=block_pressure,
        free_energy=block_fe,
        num_subgroups=total_subgroups,
        entropy=math.log(total_subgroups) if total_subgroups > 0 else 0.0,
        min_energy=sk_result.min_energy,
        effective_phi=math.log(total_subgroups) - sk_result.min_energy if total_subgroups > 0 else float('-inf'),
        individual_terms=sk_result.individual_terms * m,
        upper_bound=sk_result.upper_bound * m,
        lower_bound=sk_result.lower_bound * m
    )


def maximal_subgroups_Sn(n: int) -> List[SubgroupData]:
    """
    Compute key maximal subgroups of S_n with their indices.
    
    Returns subgroups with known indices:
    - A_n (alternating, index 2)
    - S_k × S_{n-k} (intransitive, index C(n,k))
    - S_k ≀ S_{n/k} (imprimitive)
    """
    subgroups = []
    
    # Alternating subgroup
    if n >= 2:
        subgroups.append(SubgroupData(
            name=f"A_{n}",
            index=2,
            order=math.factorial(n) // 2
        ))
    
    # Intransitive maximal subgroups
    for k in range(1, n // 2 + 1):
        idx = math.comb(n, k)
        subgroups.append(SubgroupData(
            name=f"S_{k}×S_{n-k}",
            index=idx,
            order=math.factorial(k) * math.factorial(n - k)
        ))
    
    # Imprimitive subgroups
    for k in range(2, n):
        if n % k == 0:
            m = n // k
            idx = math.factorial(n) // (math.factorial(k) ** m * math.factorial(m))
            if idx > 1:
                subgroups.append(SubgroupData(
                    name=f"S_{k}≀S_{m}",
                    index=idx,
                    order=math.factorial(k) ** m * math.factorial(m)
                ))
    
    return subgroups


def phase_transition_analysis(
    k_range: range,
    m_range: range
) -> Dict[Tuple[int, int], PressureResult]:
    """
    Analyze the phase transition landscape for S_k^m families.
    
    For each (k, m) pair, computes the block-defect pressure and
    identifies the phase transition boundary where pressure ≈ 1.
    
    Args:
        k_range: Range of k values
        m_range: Range of m values
    
    Returns:
        Dictionary mapping (k, m) to PressureResult
    """
    results = {}
    
    for k in k_range:
        subs = maximal_subgroups_Sn(k)
        for m in m_range:
            result = compute_block_defect_pressure(k, m, subs)
            results[(k, m)] = result
    
    return results


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Subgroup Pair Pressure Algorithm Demo ===\n")
    
    # Example 1: S_5 maximal subgroups
    subs = maximal_subgroups_Sn(5)
    result = compute_pressure(subs)
    
    print("S_5 maximal subgroup pressure:")
    print(f"  Subgroups: {[s.name for s in subs]}")
    print(f"  Indices: {[s.index for s in subs]}")
    print(f"  Pressure: {result.pressure:.6f}")
    print(f"  Free energy: {result.free_energy:.4f}")
    print(f"  Effective Φ: {result.effective_phi:.4f}")
    print(f"  Upper bound: {result.upper_bound:.6f}")
    print(f"  Lower bound: {result.lower_bound:.6f}")
    print()
    
    # Example 2: Product factorization
    subs3 = maximal_subgroups_Sn(3)
    subs4 = maximal_subgroups_Sn(4)
    r3 = compute_pressure(subs3)
    r4 = compute_pressure(subs4)
    r_prod = compute_product_pressure(r3, r4)
    
    print("Product factorization: S_3 × S_4")
    print(f"  pressure(S_3) = {r3.pressure:.6f}")
    print(f"  pressure(S_4) = {r4.pressure:.6f}")
    print(f"  pressure(S_3 × S_4) = {r_prod.pressure:.6f}")
    print(f"  product = {r3.pressure * r4.pressure:.6f}")
    print(f"  F(S_3) + F(S_4) = {r3.free_energy + r4.free_energy:.4f}")
    print(f"  F(S_3 × S_4) = {r_prod.free_energy:.4f}")
    print()
    
    # Example 3: Phase transition for S_2^m
    print("Phase transition for S_2^m (varying m):")
    subs2 = maximal_subgroups_Sn(2)
    for m in [1, 2, 4, 8, 16, 32]:
        r = compute_block_defect_pressure(2, m, subs2)
        print(f"  m={m:>3}: pressure={r.pressure:.4f}, "
              f"F={r.free_energy:.4f}, Φ={r.effective_phi:.4f}")
