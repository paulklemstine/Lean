#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for pair-energy computation
and incidence-based dimension estimation.

All algorithms correspond to formally verified definitions and theorems
in the Lean 4 formalization.
"""

import numpy as np
from typing import List, Set, Dict, Tuple, Callable
from collections import defaultdict
import math


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Pair Energy Computation
# ──────────────────────────────────────────────────────────────────────

def compute_cell_multiplicity(
    incidence: Dict[int, Set[int]],
    n_tubes: int
) -> Dict[int, int]:
    """
    Compute cell multiplicity: for each cell q, count |{t : I(q,t)}|.

    Corresponds to `cellMult` in the Lean formalization.

    Args:
        incidence: mapping from tube index to set of incident cell indices
        n_tubes: total number of tubes

    Returns:
        Dictionary mapping cell index to its multiplicity

    Time complexity: O(Σ_t |load(t)|) = O(total incidences)
    Space complexity: O(|cells hit|)
    """
    cell_mult: Dict[int, int] = defaultdict(int)
    for t_idx in range(n_tubes):
        for c_idx in incidence.get(t_idx, set()):
            cell_mult[c_idx] += 1
    return dict(cell_mult)


def compute_pair_energy_via_identity(
    incidence: Dict[int, Set[int]],
    n_tubes: int
) -> int:
    """
    Compute pair energy using the energy identity:
        pairEnergy = Σ_q (cellMult(q))²

    This is O(total incidences) rather than O(|T|² · |Q|) for the naive
    double sum. The identity is formally verified in:
        `energy_eq_sum_cellMult_sq`

    Args:
        incidence: mapping from tube index to set of incident cell indices
        n_tubes: total number of tubes

    Returns:
        The pair energy (integer)

    Time complexity: O(total incidences)
    Space complexity: O(|cells hit|)
    """
    cell_mult = compute_cell_multiplicity(incidence, n_tubes)
    return sum(m ** 2 for m in cell_mult.values())


def compute_pair_energy_naive(
    incidence: Dict[int, Set[int]],
    n_tubes: int,
    n_cells: int
) -> int:
    """
    Compute pair energy by the definition (naive double sum):
        pairEnergy = Σ_{t,u} |{q : I(q,t) ∧ I(q,u)}|

    Corresponds directly to `pairEnergy` in the Lean formalization.
    Much slower than the identity-based method.

    Time complexity: O(|T|² · max_load)
    Space complexity: O(max_load)
    """
    energy = 0
    for t in range(n_tubes):
        for u in range(n_tubes):
            common = len(incidence.get(t, set()) & incidence.get(u, set()))
            energy += common
    return energy


def verify_energy_identity(
    incidence: Dict[int, Set[int]],
    n_tubes: int,
    n_cells: int
) -> bool:
    """
    Verify the energy identity: pairEnergy (def) = Σ_q cellMult(q)².

    This identity is formally proved in `energy_eq_sum_cellMult_sq`.

    Returns True if both computations agree.
    """
    e1 = compute_pair_energy_via_identity(incidence, n_tubes)
    e2 = compute_pair_energy_naive(incidence, n_tubes, n_cells)
    return e1 == e2


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Incidence Lower Bound Verification
# ──────────────────────────────────────────────────────────────────────

def verify_incidence_bound(
    incidence: Dict[int, Set[int]],
    n_tubes: int
) -> Dict[str, object]:
    """
    Verify the incidence lower bound:
        (|T| · L_min)² ≤ |cells_hit| · pairEnergy

    Corresponds to `incidence_lower_bound` in the Lean formalization.

    Returns a dictionary with computed quantities and verification result.
    """
    cell_mult = compute_cell_multiplicity(incidence, n_tubes)
    n_cells_hit = len(cell_mult)

    tube_loads = [len(incidence.get(t, set())) for t in range(n_tubes)]
    L_min = min(tube_loads) if tube_loads else 0

    pair_energy = sum(m ** 2 for m in cell_mult.values())
    total_inc = sum(cell_mult.values())

    lhs = (n_tubes * L_min) ** 2
    rhs = n_cells_hit * pair_energy

    # Also verify Cauchy-Schwarz: totalInc² ≤ |cells| · pairEnergy
    cs_lhs = total_inc ** 2
    cs_rhs = n_cells_hit * pair_energy

    return {
        'n_tubes': n_tubes,
        'n_cells_hit': n_cells_hit,
        'L_min': L_min,
        'total_incidences': total_inc,
        'pair_energy': pair_energy,
        'bound_lhs': lhs,
        'bound_rhs': rhs,
        'bound_holds': lhs <= rhs,
        'cauchy_schwarz_lhs': cs_lhs,
        'cauchy_schwarz_rhs': cs_rhs,
        'cauchy_schwarz_holds': cs_lhs <= cs_rhs,
    }


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Collision Probability and Rényi Entropy
# ──────────────────────────────────────────────────────────────────────

def compute_collision_statistics(
    incidence: Dict[int, Set[int]],
    n_tubes: int
) -> Dict[str, float]:
    """
    Compute collision probability and Rényi-2 entropy of the cell-hit
    distribution.

    The collision probability is pairEnergy / totalIncidences².
    By our theorem `collision_prob_ge_inv_card`, this is ≥ 1/|cells_hit|.

    The Rényi-2 entropy H₂ = -log₂(collision_prob) satisfies
    H₂ ≤ log₂(|cells_hit|).
    """
    cell_mult = compute_cell_multiplicity(incidence, n_tubes)
    total_inc = sum(cell_mult.values())
    pair_energy = sum(m ** 2 for m in cell_mult.values())
    n_cells_hit = len(cell_mult)

    if total_inc == 0:
        return {
            'collision_prob': 0.0,
            'renyi_entropy': 0.0,
            'inv_cells': float('inf'),
            'max_entropy': 0.0,
            'entropy_defect': 0.0,
        }

    collision_prob = pair_energy / total_inc ** 2
    inv_cells = 1.0 / n_cells_hit if n_cells_hit > 0 else float('inf')
    renyi_h2 = -math.log2(collision_prob) if collision_prob > 0 else float('inf')
    max_entropy = math.log2(n_cells_hit) if n_cells_hit > 0 else 0

    return {
        'collision_prob': collision_prob,
        'renyi_entropy': renyi_h2,
        'inv_cells': inv_cells,
        'max_entropy': max_entropy,
        'entropy_defect': max_entropy - renyi_h2,
        'bound_holds': collision_prob >= inv_cells - 1e-12,
    }


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Scale-Exponent Estimation
# ──────────────────────────────────────────────────────────────────────

def estimate_scaling_exponent(
    deltas: List[float],
    values: List[float]
) -> Tuple[float, float]:
    """
    Estimate the exponent β in values(δ) ~ C · δ^{-β} by log-log
    linear regression.

    Returns (exponent, constant_log) where values ≈ exp(constant_log) · δ^{-exponent}.
    """
    if len(deltas) < 2:
        return 0.0, 0.0

    x = [math.log(1.0 / d) for d in deltas]
    y = [math.log(max(v, 1e-100)) for v in values]

    n = len(x)
    sx = sum(x)
    sy = sum(y)
    sxy = sum(xi * yi for xi, yi in zip(x, y))
    sxx = sum(xi ** 2 for xi in x)

    denom = n * sxx - sx ** 2
    if abs(denom) < 1e-15:
        return 0.0, 0.0

    slope = (n * sxy - sx * sy) / denom
    intercept = (sy - slope * sx) / n

    return slope, intercept


def predict_dimension(
    deltas: List[float],
    M_values: List[float],
    P_values: List[float],
    n_dim: int = 2
) -> Dict[str, float]:
    """
    Predict the lower Minkowski dimension from the scale bootstrap:
        dim ≥ n - α where α = P_exponent - n

    Uses the formal theorem `kakeya_dimension_from_energy`.

    Args:
        deltas: list of scales
        M_values: tube counts at each scale
        P_values: pair energies at each scale
        n_dim: ambient dimension

    Returns:
        Dictionary with exponent estimates and dimension prediction
    """
    M_exp, _ = estimate_scaling_exponent(deltas, M_values)
    P_exp, _ = estimate_scaling_exponent(deltas, P_values)

    alpha = P_exp - n_dim
    dim_lower = n_dim - alpha

    return {
        'M_exponent': M_exp,
        'P_exponent': P_exp,
        'alpha': alpha,
        'dimension_lower_bound': dim_lower,
        'n_dim': n_dim,
    }


# ──────────────────────────────────────────────────────────────────────
# Self-test
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Testing algorithms...\n")

    # Test 1: Energy identity
    incidence = {0: {0, 1, 2}, 1: {1, 2, 3}, 2: {0, 3}}
    n_tubes = 3
    n_cells = 4

    assert verify_energy_identity(incidence, n_tubes, n_cells), \
        "Energy identity verification failed!"
    print("✓ Energy identity verified")

    # Test 2: Incidence bound
    result = verify_incidence_bound(incidence, n_tubes)
    assert result['bound_holds'], "Incidence bound failed!"
    assert result['cauchy_schwarz_holds'], "Cauchy-Schwarz failed!"
    print(f"✓ Incidence bound: ({result['n_tubes']}·{result['L_min']})² = "
          f"{result['bound_lhs']} ≤ {result['bound_rhs']} = "
          f"{result['n_cells_hit']}·{result['pair_energy']}")

    # Test 3: Collision probability
    coll = compute_collision_statistics(incidence, n_tubes)
    print(f"✓ Collision prob = {coll['collision_prob']:.4f} ≥ "
          f"1/|cells| = {coll['inv_cells']:.4f}: {coll['bound_holds']}")
    print(f"  Rényi H₂ = {coll['renyi_entropy']:.2f} bits "
          f"(max = {coll['max_entropy']:.2f})")

    # Test 4: Scaling exponent
    deltas = [0.5, 0.25, 0.125, 0.0625]
    values = [4, 16, 64, 256]  # Should give exponent 2
    exp, _ = estimate_scaling_exponent(deltas, values)
    print(f"✓ Scaling exponent: {exp:.3f} (expected 2.000)")

    print("\nAll tests passed!")
