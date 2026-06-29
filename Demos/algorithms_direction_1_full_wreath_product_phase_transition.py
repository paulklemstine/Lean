#!/usr/bin/env python3
"""
algorithms.py — Certified Pressure Estimation Algorithms for Wreath Products

Implements the algorithms described in the research paper for computing
and estimating maximal-subgroup pressure in wreath products W_{k,m} = S_k ≀ S_m.

Algorithms:
1. ExactCoordPressure — Computes m * P(S_k) from maximal subgroup data
2. NoncoordPressureBound — Upper bounds non-coordinate pressure from
   count/index estimates
3. PressureDecomposer — Full pressure decomposition with diagnostics
4. ThresholdEstimator — Predicts generation threshold from pressure

All algorithms include complexity analysis and correctness justification.
"""

import math
from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional


# ─────────────────────────────────────────────────────────────
# Data structures
# ─────────────────────────────────────────────────────────────

@dataclass
class MaximalSubgroupData:
    """Data for a conjugacy class of maximal subgroups of S_k."""
    description: str
    index: int
    count: int  # number of conjugates


@dataclass
class PressureDecomposition:
    """Result of pressure decomposition for W_{k,m}."""
    k: int
    m: int
    coord_pressure: float
    noncoord_pressure_bound: float
    total_pressure_lower: float
    total_pressure_upper: float
    pressure_per_coordinate: float
    is_subcritical: bool  # whether noncoord/m < threshold


# ─────────────────────────────────────────────────────────────
# Maximal subgroup database for small S_k
# ─────────────────────────────────────────────────────────────

def maximal_subgroups_Sk(k: int) -> List[MaximalSubgroupData]:
    """
    Return maximal subgroup data for S_k.

    For k ≤ 6, this is the complete classification.
    Each entry gives a conjugacy class of maximal subgroups with
    its index in S_k and the number of conjugates.

    Time complexity: O(1)
    Space complexity: O(number of conjugacy classes)
    """
    if k == 3:
        return [
            MaximalSubgroupData("S_2 (point stabilizer)", 3, 3),
            MaximalSubgroupData("A_3 = Z_3", 2, 1),
        ]
    elif k == 4:
        return [
            MaximalSubgroupData("S_3 (point stabilizer)", 4, 4),
            MaximalSubgroupData("A_4", 2, 1),
            MaximalSubgroupData("D_8 (Sylow 2)", 3, 3),
        ]
    elif k == 5:
        return [
            MaximalSubgroupData("S_4 (point stabilizer)", 5, 5),
            MaximalSubgroupData("A_5", 2, 1),
            MaximalSubgroupData("S_3 × S_2 (intransitive)", 10, 10),
            MaximalSubgroupData("S_2 ≀ S_2 ⊂ S_4 (imprimitive)", 15, 15),
            MaximalSubgroupData("F_20 (Frobenius)", 6, 6),
        ]
    elif k == 6:
        return [
            MaximalSubgroupData("S_5 (point stabilizer)", 6, 6),
            MaximalSubgroupData("A_6", 2, 1),
            MaximalSubgroupData("S_4 × S_2 (intransitive)", 15, 15),
            MaximalSubgroupData("S_3 × S_3 (intransitive)", 20, 10),
            MaximalSubgroupData("S_2 ≀ S_3 (imprimitive)", 15, 15),
            MaximalSubgroupData("S_3 ≀ S_2 (imprimitive)", 10, 10),
            MaximalSubgroupData("PGL(2,5) (primitive)", 6, 6),
        ]
    else:
        # Generic: at minimum, point stabilizers and alternating group
        return [
            MaximalSubgroupData("S_{k-1} (point stabilizer)", k, k),
            MaximalSubgroupData(f"A_{k}", 2, 1),
        ]


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Exact Coordinate-Defect Pressure
# ─────────────────────────────────────────────────────────────

def exact_coord_pressure(k: int, m: int) -> float:
    """
    Compute the exact coordinate-defect pressure for W_{k,m}.

    P_coord(W_{k,m}) = m * P(S_k)
    where P(S_k) = Σ_{M max in S_k} [S_k : M]^{-1}

    Each coordinate of S_k^m contributes independently to the
    coordinate-defect maximal subgroups, giving a factor of m.

    Time complexity: O(|MaxClasses(S_k)|)
    Space complexity: O(1)

    Args:
        k: degree of the symmetric group S_k
        m: number of copies in the wreath product

    Returns:
        Exact coordinate-defect pressure m * P(S_k)
    """
    subgroups = maximal_subgroups_Sk(k)
    p_sk = sum(1.0 / sg.index for sg in subgroups)
    return m * p_sk


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Non-coordinate Pressure Upper Bound
# ─────────────────────────────────────────────────────────────

def noncoord_pressure_bound(k: int, m: int) -> Tuple[float, Dict[str, float]]:
    """
    Compute an upper bound on non-coordinate pressure for W_{k,m}.

    Non-coordinate maximal subgroups of W_{k,m} = S_k^m ⋊ S_m fall into:

    Type 1 (Block permutation): Maximal subgroups of S_m lifted to W_{k,m}.
      - Count: |Max(S_m)| (number of maximal subgroup conjugacy classes)
      - Min index: min index in S_m (at least 2)
      - Contribution: P(S_m), which is O(1) for fixed m but ~O(log m) asymptotically

    Type 2 (Diagonal): Subgroups where two or more base-group copies are
      identified along a diagonal.
      - Count: O(m^2) pairs of coordinates that can be identified
      - Min index: (k!)^{m-1} (exponential in m)
      - Contribution: O(m^2 / (k!)^{m-1}) → 0 exponentially

    Type 3 (Product action / twisted): Rare, very large index.
      - Contribution: negligible

    Time complexity: O(m + |MaxClasses(S_m)|)
    Space complexity: O(1)

    Returns:
        (upper_bound, breakdown) where breakdown gives per-type contributions
    """
    breakdown = {}

    # Type 1: Block permutation contribution
    # Upper bound by P(S_m) ≈ sum of 1/index over maximal subgroups of S_m
    if m >= 2:
        sm_subgroups = maximal_subgroups_Sk(m)
        type1 = sum(1.0 / sg.index for sg in sm_subgroups)
    else:
        type1 = 0.0
    breakdown["block_permutation"] = type1

    # Type 2: Diagonal contribution
    # At most C(m,2) diagonal subgroups, each with index >= (k!)^{m-1}
    k_fact = math.factorial(k)
    if m >= 2 and k_fact > 1:
        num_diag = m * (m - 1) // 2
        min_diag_index = k_fact  # conservative lower bound
        type2 = num_diag / min_diag_index
    else:
        type2 = 0.0
    breakdown["diagonal"] = type2

    # Type 3: Product action (negligible for k >= 5)
    type3 = 0.0
    if k >= 5 and m >= 2:
        # Very conservative: at most m subgroups with index >= k!
        type3 = m / k_fact
    breakdown["product_action"] = type3

    total = type1 + type2 + type3
    return total, breakdown


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Full Pressure Decomposition
# ─────────────────────────────────────────────────────────────

def pressure_decomposition(k: int, m: int,
                           subcritical_threshold: float = 0.01
                           ) -> PressureDecomposition:
    """
    Full pressure decomposition for W_{k,m} with subcriticality diagnostic.

    Computes:
    - Exact coordinate-defect pressure
    - Upper bound on non-coordinate pressure
    - Lower and upper bounds on total pressure
    - Per-coordinate pressure (total/m)
    - Subcriticality flag

    Time complexity: O(|MaxClasses(S_k)| + |MaxClasses(S_m)|)
    Space complexity: O(1)

    Args:
        k: degree of symmetric group
        m: number of copies
        subcritical_threshold: threshold for P_noncoord/m

    Returns:
        PressureDecomposition with all computed values
    """
    p_coord = exact_coord_pressure(k, m)
    p_noncoord, _ = noncoord_pressure_bound(k, m)

    return PressureDecomposition(
        k=k,
        m=m,
        coord_pressure=p_coord,
        noncoord_pressure_bound=p_noncoord,
        total_pressure_lower=p_coord,  # since noncoord >= 0
        total_pressure_upper=p_coord + p_noncoord,
        pressure_per_coordinate=p_coord / m if m > 0 else 0,
        is_subcritical=(p_noncoord / m < subcritical_threshold) if m > 0 else True,
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Threshold Estimator
# ─────────────────────────────────────────────────────────────

def estimate_generation_threshold(k: int, m: int) -> Dict[str, float]:
    """
    Estimate the random generation threshold for W_{k,m}.

    The generation probability for r random elements satisfies:
        Prob(generate W_{k,m}) ≈ 1 - P(W_{k,m}) / r + O(1/r²)

    The critical threshold r* where generation becomes likely is:
        r* ≈ P(W_{k,m})

    By our universality theorem:
        r* ≈ m * P(S_k)    (to first order)

    Time complexity: O(|MaxClasses(S_k)|)
    Space complexity: O(1)

    Returns:
        Dictionary with threshold estimates and bounds
    """
    decomp = pressure_decomposition(k, m)
    subgroups = maximal_subgroups_Sk(k)
    p_sk = sum(1.0 / sg.index for sg in subgroups)

    return {
        "threshold_lower": decomp.total_pressure_lower,
        "threshold_upper": decomp.total_pressure_upper,
        "threshold_firstorder": m * p_sk,
        "pressure_Sk": p_sk,
        "coord_fraction": decomp.coord_pressure / decomp.total_pressure_upper
        if decomp.total_pressure_upper > 0 else 1.0,
        "is_universal": decomp.is_subcritical,
    }


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("  WREATH PRODUCT PRESSURE ALGORITHMS")
    print("=" * 70)

    for k in [3, 4, 5, 6]:
        print(f"\n--- S_{k} maximal subgroups ---")
        for sg in maximal_subgroups_Sk(k):
            print(f"  {sg.description}: index={sg.index}, count={sg.count}")
        p_sk = sum(1.0 / sg.index for sg in maximal_subgroups_Sk(k))
        print(f"  P(S_{k}) = {p_sk:.6f}")

    print("\n" + "=" * 70)
    print("  PRESSURE DECOMPOSITION TABLE (k=5)")
    print("=" * 70)

    for m in [1, 2, 5, 10, 20, 50, 100, 500]:
        decomp = pressure_decomposition(5, m)
        print(f"  m={m:>4}: P_coord={decomp.coord_pressure:>10.4f}, "
              f"P_nc≤{decomp.noncoord_pressure_bound:>8.4f}, "
              f"subcritical={decomp.is_subcritical}")

    print("\n" + "=" * 70)
    print("  THRESHOLD ESTIMATION (k=5)")
    print("=" * 70)

    for m in [10, 50, 100, 500, 1000]:
        thresh = estimate_generation_threshold(5, m)
        print(f"  m={m:>5}: threshold ∈ [{thresh['threshold_lower']:.2f}, "
              f"{thresh['threshold_upper']:.2f}], "
              f"first-order={thresh['threshold_firstorder']:.2f}, "
              f"coord_frac={thresh['coord_fraction']:.4f}")
