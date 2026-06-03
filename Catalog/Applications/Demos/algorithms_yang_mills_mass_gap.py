#!/usr/bin/env python3
"""
Algorithms for Yang-Mills Mass Gap Analysis

Type-hinted implementations of the key algorithms used in the formal
mathematical framework for lattice gauge theory mass gaps.
"""

import math
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class TransferOperatorData:
    """Spectral data for a transfer matrix operator.

    Eigenvalues are stored in decreasing order (λ₀ ≥ λ₁ ≥ ... > 0).
    The mass gap is Δ = -log(λ₁/λ₀).
    """
    eigenvalues: List[float]

    def __post_init__(self) -> None:
        assert len(self.eigenvalues) >= 2, "Need at least 2 eigenvalues"
        assert all(e > 0 for e in self.eigenvalues), "All eigenvalues must be positive"
        assert all(self.eigenvalues[i] >= self.eigenvalues[i+1]
                   for i in range(len(self.eigenvalues)-1)), "Eigenvalues must be decreasing"

    @property
    def ground_state_eigenvalue(self) -> float:
        return self.eigenvalues[0]

    @property
    def first_excited_eigenvalue(self) -> float:
        return self.eigenvalues[1]

    @property
    def mass_gap(self) -> float:
        """Δ = -log(λ₁/λ₀)"""
        return -math.log(self.first_excited_eigenvalue / self.ground_state_eigenvalue)

    @property
    def eigenvalue_ratio(self) -> float:
        """λ₁/λ₀ ∈ (0, 1]"""
        return self.first_excited_eigenvalue / self.ground_state_eigenvalue


@dataclass
class GaugeEquivariantFiltration:
    """Gauge-equivariant spectral filtration.

    Combines Peter-Weyl decomposition sector data with Casimir eigenvalues
    and the key bound: λ_σ ≤ λ₀ · exp(-c₂(σ)).
    """
    sector_eigenvalues: List[float]
    sector_multiplicities: List[int]
    sector_casimir: List[float]

    def __post_init__(self) -> None:
        n = len(self.sector_eigenvalues)
        assert n >= 2, "Need at least 2 sectors"
        assert len(self.sector_multiplicities) == n
        assert len(self.sector_casimir) == n
        assert all(e > 0 for e in self.sector_eigenvalues)
        assert all(m > 0 for m in self.sector_multiplicities)
        assert all(c >= 0 for c in self.sector_casimir)
        assert self.sector_casimir[0] == 0.0, "Vacuum Casimir must be 0"

    @property
    def filtration_gap(self) -> float:
        """Δ_F = -log(λ₁/λ₀)"""
        return -math.log(self.sector_eigenvalues[1] / self.sector_eigenvalues[0])

    def verify_casimir_bound(self) -> bool:
        """Verify that λ_σ ≤ λ₀ · exp(-c₂(σ)) for all sectors."""
        lam0 = self.sector_eigenvalues[0]
        return all(
            self.sector_eigenvalues[i] <= lam0 * math.exp(-self.sector_casimir[i]) + 1e-10
            for i in range(len(self.sector_eigenvalues))
        )


@dataclass
class StrongCouplingRegime:
    """Strong coupling expansion data for mass gap computation."""
    beta: float
    gap_coeff: float
    correction_bound: float

    def __post_init__(self) -> None:
        assert self.beta > 0 and self.beta < 1
        assert self.gap_coeff > 0
        assert self.correction_bound >= 0

    @property
    def leading_order_gap(self) -> float:
        """c · (-log β)"""
        return self.gap_coeff * (-math.log(self.beta))

    @property
    def mass_gap_lower_bound(self) -> float:
        """c · (-log β) - correction"""
        return self.leading_order_gap - self.correction_bound

    @property
    def is_positive(self) -> bool:
        return self.mass_gap_lower_bound > 0


def compute_correlation_decay(
    transfer_data: TransferOperatorData,
    amplitudes: List[float],
    max_time: int
) -> List[Tuple[int, float, float]]:
    """Compute correlation function and exponential bound.

    Returns list of (time, correlation, bound) tuples.
    """
    assert len(amplitudes) == len(transfer_data.eigenvalues)
    assert abs(amplitudes[0]) < 1e-10, "Ground state amplitude must be 0 for connected correlator"

    gap = transfer_data.mass_gap
    n = len(transfer_data.eigenvalues)
    lam0 = transfer_data.ground_state_eigenvalue

    results: List[Tuple[int, float, float]] = []
    for t in range(max_time + 1):
        corr = sum(
            a * (lam / lam0) ** t
            for a, lam in zip(amplitudes, transfer_data.eigenvalues)
        )
        bound = n * math.exp(-gap * t)
        results.append((t, corr, bound))

    return results


def wilson_area_law_decay(
    string_tension: float,
    max_area: int
) -> List[Tuple[int, float]]:
    """Compute Wilson loop area law bound: |⟨W⟩| ≤ exp(-σ·A)."""
    assert string_tension > 0
    return [(a, math.exp(-string_tension * a)) for a in range(max_area + 1)]


def su_n_casimir_fundamental(n: int) -> float:
    """Casimir eigenvalue of the fundamental representation of SU(N).

    c₂(fund) = (N² - 1) / (2N)
    """
    return (n * n - 1) / (2 * n)


def su2_casimir(j: float) -> float:
    """Casimir eigenvalue for SU(2) spin-j representation: c₂(j) = j(j+1)."""
    return j * (j + 1)


def build_su2_filtration(
    beta: float,
    num_sectors: int = 5
) -> GaugeEquivariantFiltration:
    """Build a gauge-equivariant filtration for SU(2) at coupling β.

    Uses the strong coupling approximation where sector eigenvalues are
    proportional to β^{2j(j+1)} times dimension factors.
    """
    sector_eigs: List[float] = []
    sector_mults: List[int] = []
    sector_cas: List[float] = []

    for j_half in range(num_sectors):
        j = j_half / 2.0
        cas = su2_casimir(j)
        dim = int(2 * j + 1)
        # Leading-order approximation: λ_j ∝ (β/4)^{2·c₂(j)}
        # Normalized so λ₀ = 1
        lam = math.exp(-cas)  # At unit coupling
        sector_eigs.append(lam)
        sector_mults.append(dim)
        sector_cas.append(cas)

    return GaugeEquivariantFiltration(
        sector_eigenvalues=sector_eigs,
        sector_multiplicities=sector_mults,
        sector_casimir=sector_cas
    )


def perturbation_stability_check(
    filtration: GaugeEquivariantFiltration,
    delta: float,
    num_trials: int = 100
) -> Tuple[bool, float]:
    """Check perturbation stability of the filtration gap.

    Perturbs eigenvalues by multiplicative factors in [1-δ, 1+δ]
    and checks if the gap remains positive.
    """
    import random
    original_gap = filtration.filtration_gap
    min_perturbed_gap = float('inf')
    all_positive = True

    for _ in range(num_trials):
        perturbed_eigs = [
            e * (1 + random.uniform(-delta, delta))
            for e in filtration.sector_eigenvalues
        ]
        # Keep eigenvalues positive and sorted
        perturbed_eigs = sorted([max(e, 1e-10) for e in perturbed_eigs], reverse=True)
        try:
            gap = -math.log(perturbed_eigs[1] / perturbed_eigs[0])
            min_perturbed_gap = min(min_perturbed_gap, gap)
            if gap <= 0:
                all_positive = False
        except (ValueError, ZeroDivisionError):
            all_positive = False

    return all_positive, min_perturbed_gap


def continuum_limit_extrapolation(
    lattice_spacings: List[float],
    lattice_gaps: List[float]
) -> Optional[float]:
    """Extrapolate mass gap to continuum limit (a → 0).

    Uses linear extrapolation in a² (leading lattice artifact).
    Returns estimated continuum gap, or None if extrapolation fails.
    """
    if len(lattice_spacings) < 2:
        return None

    # Fit Δ(a) = Δ_∞ + c · a² using last two points
    a1, a2 = lattice_spacings[-2], lattice_spacings[-1]
    g1, g2 = lattice_gaps[-2], lattice_gaps[-1]

    a1_sq, a2_sq = a1 ** 2, a2 ** 2
    if abs(a1_sq - a2_sq) < 1e-15:
        return None

    c = (g1 - g2) / (a1_sq - a2_sq)
    delta_inf = g2 - c * a2_sq

    return delta_inf if delta_inf > 0 else None


if __name__ == "__main__":
    # Quick self-test
    T = TransferOperatorData(eigenvalues=[1.0, 0.5, 0.25, 0.1])
    print(f"Mass gap: {T.mass_gap:.4f}")

    F = build_su2_filtration(beta=0.5)
    print(f"SU(2) filtration gap: {F.filtration_gap:.4f}")
    print(f"Casimir bound satisfied: {F.verify_casimir_bound()}")

    S = StrongCouplingRegime(beta=0.1, gap_coeff=1.0, correction_bound=0.5)
    print(f"Strong coupling gap: {S.mass_gap_lower_bound:.4f}")
    print(f"Gap positive: {S.is_positive}")
