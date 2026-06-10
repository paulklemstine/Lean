#!/usr/bin/env python3
"""
Quantum Surreal Numbers: Core Algorithms

Type-hinted implementations of the key algorithms from the quantum surreal
number framework, including probability computation, measurement, and
scale decomposition analysis.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class QState:
    """A normalized quantum state over a finite basis."""
    amplitudes: List[float]

    def __post_init__(self) -> None:
        norm_sq = sum(a**2 for a in self.amplitudes)
        if abs(norm_sq - 1.0) > 1e-10:
            norm = math.sqrt(norm_sq)
            self.amplitudes = [a / norm for a in self.amplitudes]

    @property
    def dim(self) -> int:
        return len(self.amplitudes)

    def probability(self, i: int) -> float:
        """Born rule probability for basis state i."""
        return self.amplitudes[i] ** 2


@dataclass
class ScaleDecomp:
    """A scale decomposition partitioning basis states into sectors."""
    is_observable: List[bool]

    @property
    def obs_indices(self) -> List[int]:
        return [i for i, obs in enumerate(self.is_observable) if obs]

    @property
    def inf_indices(self) -> List[int]:
        return [i for i, obs in enumerate(self.is_observable) if not obs]


@dataclass
class BoolProjection:
    """A Boolean projection operator."""
    keep: List[bool]

    def complement(self) -> 'BoolProjection':
        return BoolProjection(keep=[not k for k in self.keep])

    def apply(self, state: QState) -> List[float]:
        return [
            state.amplitudes[i] if self.keep[i] else 0.0
            for i in range(state.dim)
        ]


def observable_probability(state: QState, decomp: ScaleDecomp) -> float:
    """
    Compute the observable probability: sum of |α_i|² for observable i.

    This is the "standard part" of the total probability — what a
    macroscopic observer actually measures.

    Time: O(n), Space: O(1)
    """
    return sum(
        state.amplitudes[i] ** 2
        for i in decomp.obs_indices
    )


def infinitesimal_probability(state: QState, decomp: ScaleDecomp) -> float:
    """
    Compute the infinitesimal probability: sum of |α_i|² for infinitesimal i.

    This is the "dark probability" — quantum probability hiding in
    unobservable modes.

    Time: O(n), Space: O(1)
    """
    return sum(
        state.amplitudes[i] ** 2
        for i in decomp.inf_indices
    )


def probability_defect(state: QState, decomp: ScaleDecomp) -> float:
    """
    Compute the probability defect: δ = 1 - P_obs.

    By the conservation theorem, δ = P_inf.

    Time: O(n), Space: O(1)
    """
    return 1.0 - observable_probability(state, decomp)


def verify_conservation(state: QState, decomp: ScaleDecomp,
                        tol: float = 1e-10) -> bool:
    """
    Verify the probability conservation theorem: P_obs + P_inf = 1.

    Returns True if conservation holds within tolerance.

    Time: O(n), Space: O(1)
    """
    p_obs = observable_probability(state, decomp)
    p_inf = infinitesimal_probability(state, decomp)
    return abs(p_obs + p_inf - 1.0) < tol


def measurement_probability(proj: BoolProjection, state: QState) -> float:
    """
    Compute the Born-rule probability of a measurement outcome.

    Time: O(n), Space: O(n)
    """
    projected = proj.apply(state)
    return sum(a**2 for a in projected)


def post_measurement_state(proj: BoolProjection, state: QState) -> Optional[QState]:
    """
    Compute the post-measurement state after projection and renormalization.

    Returns None if the measurement has zero probability (impossible outcome).

    Time: O(n), Space: O(n)
    """
    projected = proj.apply(state)
    norm_sq = sum(a**2 for a in projected)
    if norm_sq < 1e-15:
        return None
    norm = math.sqrt(norm_sq)
    return QState(amplitudes=[a / norm for a in projected])


def inner_product(state1: QState, state2: QState) -> float:
    """
    Compute the inner product of two quantum states.

    Time: O(n), Space: O(1)
    """
    return sum(
        state1.amplitudes[i] * state2.amplitudes[i]
        for i in range(state1.dim)
    )


def observable_inner_product(state1: QState, state2: QState,
                              decomp: ScaleDecomp) -> float:
    """
    Compute the inner product restricted to the observable sector.

    Time: O(|obsSet|), Space: O(1)
    """
    return sum(
        state1.amplitudes[i] * state2.amplitudes[i]
        for i in decomp.obs_indices
    )


def verify_cauchy_schwarz(state1: QState, state2: QState,
                           decomp: ScaleDecomp,
                           tol: float = 1e-10) -> bool:
    """
    Verify the observable Cauchy-Schwarz inequality:
    ⟨ψ|φ⟩²_obs ≤ P_obs(ψ) · P_obs(φ)

    Time: O(n), Space: O(1)
    """
    ip = observable_inner_product(state1, state2, decomp)
    p1 = observable_probability(state1, decomp)
    p2 = observable_probability(state2, decomp)
    return ip**2 <= p1 * p2 + tol


def classify_state(state: QState, decomp: ScaleDecomp) -> dict:
    """
    Classify a quantum state's relationship to a scale decomposition.

    Returns a dictionary with:
    - observable_prob: P_obs
    - infinitesimal_prob: P_inf
    - defect: δ
    - is_fully_observable: whether δ = 0
    - dark_ratio: fraction of probability in infinitesimal sector

    Time: O(n), Space: O(1)
    """
    p_obs = observable_probability(state, decomp)
    p_inf = infinitesimal_probability(state, decomp)
    defect = 1.0 - p_obs

    return {
        'observable_prob': p_obs,
        'infinitesimal_prob': p_inf,
        'defect': defect,
        'is_fully_observable': abs(defect) < 1e-10,
        'dark_ratio': p_inf if p_inf > 1e-15 else 0.0,
    }


def graded_decomposition(state: QState,
                          scales: List[int]) -> List[Tuple[int, float]]:
    """
    Compute a multi-layer (tropical valuation) decomposition of probability.

    Given integer scale assignments for each basis state, compute the
    total probability at each scale level.

    Args:
        state: A quantum state
        scales: Integer scale for each basis element (0 = observable,
                positive = increasingly infinitesimal)

    Returns:
        List of (scale, probability) pairs, sorted by scale.

    Time: O(n log n), Space: O(k) where k = number of distinct scales
    """
    layer_probs: dict[int, float] = {}
    for i, s in enumerate(scales):
        prob = state.amplitudes[i] ** 2
        layer_probs[s] = layer_probs.get(s, 0.0) + prob

    return sorted(layer_probs.items())


if __name__ == '__main__':
    # Quick self-test
    psi = QState(amplitudes=[1.0, 1.0, 0.5])
    decomp = ScaleDecomp(is_observable=[True, True, False])

    info = classify_state(psi, decomp)
    print("State classification:", info)
    print("Conservation holds:", verify_conservation(psi, decomp))

    # Graded decomposition
    psi2 = QState(amplitudes=[1.0, 1.0, 0.5, 0.3, 0.1])
    layers = graded_decomposition(psi2, [0, 0, 1, 1, 2])
    print("\nGraded decomposition:")
    for scale, prob in layers:
        print(f"  Scale {scale}: probability = {prob:.6f}")
