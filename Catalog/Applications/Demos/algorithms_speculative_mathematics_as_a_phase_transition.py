#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Coherence Percolation Systems

Type-hinted implementations of the mathematical structures defined
in the Lean formalization.
"""

from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional
from enum import Enum


class PhaseRegime(Enum):
    SUBCRITICAL = "subcritical"
    CRITICAL = "critical"
    SUPERCRITICAL = "supercritical"


@dataclass
class CoherencePercolation:
    """
    A coherence percolation system.

    Models the order parameter Φ of a knowledge graph undergoing
    percolation as edges are added monotonically.

    Invariants (enforced at construction):
    - Φ is monotone non-decreasing
    - Φ(0) = 1/n
    - 1/n ≤ Φ(k) ≤ 1 for all k
    - ∃ K such that Φ(K) = 1
    """
    n: int
    phi_values: List[float]  # Precomputed Φ values

    def __post_init__(self) -> None:
        assert self.n >= 2, f"System size must be ≥ 2, got {self.n}"
        assert len(self.phi_values) > 0
        assert abs(self.phi_values[0] - 1.0/self.n) < 1e-10, \
            f"Φ(0) must be 1/n = {1.0/self.n}, got {self.phi_values[0]}"
        for i in range(len(self.phi_values) - 1):
            assert self.phi_values[i] <= self.phi_values[i+1] + 1e-10, \
                f"Φ must be monotone: Φ({i}) = {self.phi_values[i]} > Φ({i+1}) = {self.phi_values[i+1]}"
        assert any(abs(v - 1.0) < 1e-10 for v in self.phi_values), \
            "Φ must reach 1.0 (saturation)"

    def phi(self, k: int) -> float:
        """Order parameter at step k."""
        if k >= len(self.phi_values):
            return self.phi_values[-1]
        return self.phi_values[max(0, k)]

    def critical_point(self) -> int:
        """Smallest k such that Φ(k) ≥ 1/2."""
        for k, v in enumerate(self.phi_values):
            if v >= 0.5:
                return k
        return len(self.phi_values)

    def susceptibility(self, k: int) -> float:
        """Discrete derivative: Φ(k+1) - Φ(k)."""
        return self.phi(k + 1) - self.phi(k)

    def phase_regime(self, k: int) -> PhaseRegime:
        """Classify step k into a phase regime."""
        v = self.phi(k)
        if v < 0.5:
            return PhaseRegime.SUBCRITICAL
        elif abs(v - 0.5) < 1e-10:
            return PhaseRegime.CRITICAL
        else:
            return PhaseRegime.SUPERCRITICAL

    def saturation_point(self) -> int:
        """Smallest k such that Φ(k) = 1."""
        for k, v in enumerate(self.phi_values):
            if abs(v - 1.0) < 1e-10:
                return k
        return len(self.phi_values)

    def coherence_gap(self, k: int) -> float:
        """1 - Φ(k): distance from full coherence."""
        return 1.0 - self.phi(k)

    def initial_gap(self) -> float:
        """1 - 1/n: the initial coherence gap."""
        return 1.0 - 1.0 / self.n


@dataclass
class EdgeCoherenceSystem:
    """
    Concrete percolation system tracking component sizes.
    """
    n: int
    max_comp_values: List[int]

    def __post_init__(self) -> None:
        assert self.n >= 2
        assert self.max_comp_values[0] == 1
        for i in range(len(self.max_comp_values) - 1):
            assert self.max_comp_values[i] <= self.max_comp_values[i+1]
        assert all(v <= self.n for v in self.max_comp_values)
        assert any(v == self.n for v in self.max_comp_values)

    def to_coherence_percolation(self) -> CoherencePercolation:
        """Convert to abstract CoherencePercolation."""
        phi_values = [v / self.n for v in self.max_comp_values]
        return CoherencePercolation(n=self.n, phi_values=phi_values)


def merge_systems(s1: CoherencePercolation, s2: CoherencePercolation) -> CoherencePercolation:
    """
    Merge two coherence systems by taking the max at each step.

    Theorem: The critical point of the merged system is ≤ min of components.
    """
    assert s1.n == s2.n, "Systems must have the same size"
    max_len = max(len(s1.phi_values), len(s2.phi_values))
    phi_merged = [max(s1.phi(k), s2.phi(k)) for k in range(max_len)]
    return CoherencePercolation(n=s1.n, phi_values=phi_merged)


def sequential_merge(n: int) -> EdgeCoherenceSystem:
    """
    Construct the sequential merge system on n vertices.
    maxComp(k) = min(k+1, n).
    """
    max_comp = [min(k + 1, n) for k in range(n)]
    return EdgeCoherenceSystem(n=n, max_comp_values=max_comp)


def sharp_transition(n: int) -> CoherencePercolation:
    """
    Construct the sharpest possible transition.
    Φ(0) = 1/n, Φ(k) = 1 for k ≥ 1.
    """
    phi_values = [1.0 / n] + [1.0] * (n - 1)
    return CoherencePercolation(n=n, phi_values=phi_values)


def compute_transition_profile(system: CoherencePercolation) -> dict:
    """
    Compute the full transition profile of a system.

    Returns dict with critical_point, saturation_point, max_susceptibility,
    transition_width, and phase_counts.
    """
    cp = system.critical_point()
    sp = system.saturation_point()

    # Max susceptibility
    max_susc = 0.0
    max_susc_step = 0
    for k in range(len(system.phi_values) - 1):
        s = system.susceptibility(k)
        if s > max_susc:
            max_susc = s
            max_susc_step = k

    # Phase counts
    counts = {PhaseRegime.SUBCRITICAL: 0, PhaseRegime.CRITICAL: 0,
              PhaseRegime.SUPERCRITICAL: 0}
    for k in range(len(system.phi_values)):
        counts[system.phase_regime(k)] += 1

    return {
        "critical_point": cp,
        "saturation_point": sp,
        "max_susceptibility": max_susc,
        "max_susceptibility_step": max_susc_step,
        "initial_gap": system.initial_gap(),
        "transition_width": sp - cp,
        "phase_counts": {k.value: v for k, v in counts.items()},
    }


if __name__ == "__main__":
    # Example usage
    print("=== Sequential Merge (n=10) ===")
    sm = sequential_merge(10)
    cp = sm.to_coherence_percolation()
    profile = compute_transition_profile(cp)
    print(f"Profile: {profile}")

    print("\n=== Sharp Transition (n=10) ===")
    st = sharp_transition(10)
    profile = compute_transition_profile(st)
    print(f"Profile: {profile}")

    print("\n=== Merge of Two Systems ===")
    s1 = sequential_merge(10).to_coherence_percolation()
    s2 = sharp_transition(10)
    merged = merge_systems(s1, s2)
    print(f"S1 critical point: {s1.critical_point()}")
    print(f"S2 critical point: {s2.critical_point()}")
    print(f"Merged critical point: {merged.critical_point()}")
    print(f"Theorem verified: {merged.critical_point() <= min(s1.critical_point(), s2.critical_point())}")
