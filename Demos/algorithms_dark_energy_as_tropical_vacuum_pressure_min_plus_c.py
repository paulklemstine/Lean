#!/usr/bin/env python3
"""
Algorithms for Tropical Vacuum Energy

Implements the algorithmic content of the tropical vacuum energy framework:
- Tropical vacuum energy computation
- Incremental update (insertion stability)
- Gap rigidity certification
- Zero-temperature convergence estimation
- Tropical renormalization group (coarse-graining)
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass


@dataclass
class VacuumState:
    """State of the tropical vacuum energy computation.

    Attributes:
        energy: Current tropical vacuum energy (minimum action).
        minimizer: Index of the minimizing diagram.
        actions: List of all diagram actions.
        gap: Spectral gap (difference between smallest and second-smallest action).
    """
    energy: float
    minimizer: int
    actions: list[float]
    gap: float

    @staticmethod
    def from_actions(actions: list[float]) -> "VacuumState":
        """Compute the tropical vacuum state from a list of actions.

        Time complexity: O(n)
        Space complexity: O(1) auxiliary
        """
        if not actions:
            raise ValueError("Need at least one action")

        sorted_unique = sorted(set(actions))
        min_val = sorted_unique[0]
        gap = sorted_unique[1] - min_val if len(sorted_unique) > 1 else float('inf')
        min_idx = actions.index(min_val)

        return VacuumState(
            energy=min_val,
            minimizer=min_idx,
            actions=list(actions),
            gap=gap
        )


def incremental_insert(state: VacuumState, new_action: float) -> VacuumState:
    """Insert a new diagram and update the vacuum state.

    Implements Theorem 5 (insertion stability): if new_action >= state.energy,
    the vacuum energy is unchanged.

    Time complexity: O(1) for the decision, O(n) for gap recomputation.

    Args:
        state: Current vacuum state.
        new_action: Action of the new diagram.

    Returns:
        Updated VacuumState.
    """
    new_actions = state.actions + [new_action]
    new_idx = len(state.actions)  # Index of new diagram

    if new_action < state.energy:
        # New minimizer found
        new_gap = state.energy - new_action
        return VacuumState(
            energy=new_action,
            minimizer=new_idx,
            actions=new_actions,
            gap=new_gap
        )
    elif new_action == state.energy:
        # Degenerate: gap unchanged, minimizer unchanged
        return VacuumState(
            energy=state.energy,
            minimizer=state.minimizer,
            actions=new_actions,
            gap=state.gap if state.gap > 0 else 0.0
        )
    else:
        # Theorem 5: vacuum energy unchanged
        new_gap = min(state.gap, new_action - state.energy)
        return VacuumState(
            energy=state.energy,
            minimizer=state.minimizer,
            actions=new_actions,
            gap=new_gap
        )


def certify_robustness(state: VacuumState) -> dict:
    """Certify the robustness of the current vacuum sector.

    Uses the gap rigidity theorem (Theorem 6) to compute the maximum
    perturbation under which the vacuum sector is guaranteed stable.

    Returns:
        Dictionary with robustness certificate.
    """
    return {
        "vacuum_energy": state.energy,
        "minimizer_index": state.minimizer,
        "spectral_gap": state.gap,
        "robustness_radius": state.gap / 2 if state.gap < float('inf') else float('inf'),
        "is_unique_minimizer": state.gap > 0,
        "certificate": (
            f"Perturbations with ||ε||_∞ < {state.gap/2:.6f} "
            f"cannot change the vacuum sector."
            if state.gap > 0 and state.gap < float('inf')
            else "Unique minimizer with infinite gap (singleton set)."
            if state.gap == float('inf')
            else "Degenerate minimizer: vacuum sector is not unique."
        )
    }


def free_energy(actions: list[float], beta: float) -> float:
    """Compute the free energy F(β) = -1/β · log(Σ exp(-β·S_i)).

    Uses the log-sum-exp trick for numerical stability.

    Args:
        actions: List of diagram actions.
        beta: Inverse temperature parameter.

    Returns:
        Free energy value.
    """
    arr = np.array(actions)
    shifted = -beta * arr
    max_val = np.max(shifted)
    log_sum = max_val + np.log(np.sum(np.exp(shifted - max_val)))
    return -log_sum / beta


def convergence_rate(actions: list[float], beta: float) -> dict:
    """Estimate the convergence rate of F(β) to the tropical vacuum energy.

    The theoretical bound is |F(β) - min S| ≤ log(|s|) / β.

    Returns:
        Dictionary with convergence information.
    """
    min_action = min(actions)
    f_beta = free_energy(actions, beta)
    actual_error = abs(f_beta - min_action)
    theoretical_bound = np.log(len(actions)) / beta

    return {
        "beta": beta,
        "free_energy": f_beta,
        "tropical_energy": min_action,
        "actual_error": actual_error,
        "theoretical_bound": theoretical_bound,
        "bound_is_tight": actual_error <= theoretical_bound
    }


def tropical_renormalization_group(
    actions: list[float],
    partition: list[list[int]]
) -> tuple[list[float], float]:
    """Perform tropical renormalization group coarse-graining.

    Given a partition of diagram indices into blocks, compute the
    coarse-grained actions (min within each block) and verify that
    the vacuum energy is preserved.

    Args:
        actions: Original list of diagram actions.
        partition: List of lists of indices, forming a partition of range(len(actions)).

    Returns:
        (coarse_grained_actions, vacuum_energy)
    """
    coarse = [min(actions[i] for i in block) for block in partition]
    original_vac = min(actions)
    coarse_vac = min(coarse)

    assert np.isclose(original_vac, coarse_vac), \
        f"RG invariance violated: {original_vac} != {coarse_vac}"

    return coarse, coarse_vac


# ── Example usage ──

if __name__ == "__main__":
    print("=== Tropical Vacuum Energy Algorithms ===\n")

    # Build state incrementally
    print("--- Incremental Construction ---")
    state = VacuumState.from_actions([5.0])
    print(f"Initial: E_vac = {state.energy}")

    for action in [3.0, 8.0, 1.0, 1e60, 1e120]:
        state = incremental_insert(state, action)
        print(f"  Insert {action:.1e}: E_vac = {state.energy}, gap = {state.gap}")

    # Robustness certificate
    print("\n--- Robustness Certificate ---")
    cert = certify_robustness(state)
    for k, v in cert.items():
        print(f"  {k}: {v}")

    # Convergence
    print("\n--- Zero-Temperature Convergence ---")
    test_actions = [1.0, 3.0, 5.0, 7.0, 9.0]
    for beta in [1.0, 10.0, 100.0, 1000.0]:
        info = convergence_rate(test_actions, beta)
        print(f"  β={beta:7.1f}: error={info['actual_error']:.2e}, "
              f"bound={info['theoretical_bound']:.2e}, "
              f"tight={info['bound_is_tight']}")

    # Tropical RG
    print("\n--- Tropical Renormalization Group ---")
    actions = [5.0, 2.0, 8.0, 1.0, 7.0, 3.0]
    partition = [[0, 1], [2, 3], [4, 5]]
    coarse, vac = tropical_renormalization_group(actions, partition)
    print(f"  Original actions: {actions}")
    print(f"  Partition: {partition}")
    print(f"  Coarse-grained: {coarse}")
    print(f"  Vacuum energy preserved: {vac}")
