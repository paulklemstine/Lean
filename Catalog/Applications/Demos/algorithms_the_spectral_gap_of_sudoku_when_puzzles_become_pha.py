#!/usr/bin/env python3
"""
Algorithms for Spectral Gap Analysis of Constraint Satisfaction Problems
========================================================================

Type-hinted implementations of the core algorithms from the
Constraint Spectral Landscape framework.
"""

from dataclasses import dataclass
from typing import Callable, Optional, List, Tuple
from enum import Enum
import math


class PhaseRegime(Enum):
    """Classification of constraint density regimes."""
    SUBCRITICAL = "subcritical"     # Many solutions, fast mixing
    CRITICAL = "critical"           # Phase transition, slow mixing
    SUPERCRITICAL = "supercritical" # Unique/no solution, frozen


@dataclass
class SpectralLandscape:
    """
    A spectral landscape: gap function satisfying:
    - gap_fn(d) >= 0 for all d
    - gap_fn is antitone (non-increasing)
    - gap_fn(0) > 0
    - gap_fn(1) = 0
    """
    gap_fn: Callable[[float], float]
    
    def gap(self, d: float) -> float:
        """Evaluate the spectral gap at density d."""
        return max(0.0, self.gap_fn(d))
    
    def critical_density(self, tol: float = 1e-10) -> float:
        """Compute critical density: sup{d | gap(d) > 0} via binary search."""
        lo, hi = 0.0, 1.0
        for _ in range(100):
            mid = (lo + hi) / 2
            if self.gap(mid) > tol:
                lo = mid
            else:
                hi = mid
        return (lo + hi) / 2
    
    def is_valid(self, n_samples: int = 1000) -> bool:
        """Verify landscape axioms numerically."""
        ds = [i / n_samples for i in range(n_samples + 1)]
        # Non-negativity
        for d in ds:
            if self.gap_fn(d) < -1e-10:
                return False
        # Antitonicity
        for i in range(len(ds) - 1):
            if self.gap_fn(ds[i+1]) > self.gap_fn(ds[i]) + 1e-10:
                return False
        # Positive at zero
        if self.gap_fn(0) <= 0:
            return False
        # Zero at one
        if abs(self.gap_fn(1)) > 1e-10:
            return False
        return True
    
    def refines(self, other: 'SpectralLandscape', n_samples: int = 1000) -> bool:
        """Check if self refines other: gap_self(d) <= gap_other(d) for all d."""
        ds = [i / n_samples for i in range(n_samples + 1)]
        return all(self.gap(d) <= other.gap(d) + 1e-10 for d in ds)


@dataclass
class MixingProfile:
    """Mixing profile: landscape + state space parameters."""
    landscape: SpectralLandscape
    state_space_size: int
    tolerance: float
    
    def mixing_time(self, d: float) -> float:
        """Compute mixing time bound at density d."""
        gap = self.landscape.gap(d)
        if gap <= 0:
            return float('inf')
        log_factor = math.log(self.state_space_size) + math.log(1 / self.tolerance)
        return (1 / gap) * log_factor


@dataclass
class GapEntropyPair:
    """Joint gap-entropy data at a specific density."""
    density: float
    gap: float
    log_solutions: float
    
    @property
    def mixing_rate(self) -> float:
        """Information mixing rate: gap * log(solutions)."""
        return self.gap * self.log_solutions
    
    def verify_bound(self) -> bool:
        """Verify mixing_rate <= log_solutions."""
        return self.mixing_rate <= self.log_solutions + 1e-10


# === Core Algorithms ===

def find_critical_density(
    gap_fn: Callable[[float], float],
    tol: float = 1e-12
) -> float:
    """
    Algorithm 1: Binary Search for Critical Density
    
    Find d_c = sup{d : gap(d) > 0} using binary search.
    
    Pseudocode:
        lo, hi = 0, 1
        while hi - lo > tol:
            mid = (lo + hi) / 2
            if gap(mid) > 0: lo = mid
            else: hi = mid
        return (lo + hi) / 2
    """
    lo, hi = 0.0, 1.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if gap_fn(mid) > tol:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def compute_phase_diagram(
    gap_fn: Callable[[float], float],
    critical_density: float,
    frozen_density: float,
    n_points: int = 100
) -> List[Tuple[float, float, PhaseRegime]]:
    """
    Algorithm 2: Phase Diagram Computation
    
    Compute (density, gap, phase) triples across the density range.
    
    Pseudocode:
        for d in linspace(0, 1, n):
            gap = gap_fn(d)
            phase = classify(d, d_c, d_f)
            yield (d, gap, phase)
    """
    results: List[Tuple[float, float, PhaseRegime]] = []
    for i in range(n_points + 1):
        d = i / n_points
        gap = max(0.0, gap_fn(d))
        if d < critical_density:
            phase = PhaseRegime.SUBCRITICAL
        elif d < frozen_density:
            phase = PhaseRegime.CRITICAL
        else:
            phase = PhaseRegime.SUPERCRITICAL
        results.append((d, gap, phase))
    return results


def mixing_time_landscape(
    gap_fn: Callable[[float], float],
    n_states: int,
    epsilon: float,
    n_points: int = 100
) -> List[Tuple[float, float]]:
    """
    Algorithm 3: Mixing Time Landscape
    
    Compute mixing time as a function of density.
    
    Pseudocode:
        C = log(n) + log(1/eps)
        for d in linspace(0, 1, n_points):
            gap = gap_fn(d)
            t_mix = C / gap if gap > 0 else infinity
            yield (d, t_mix)
    """
    C = math.log(n_states) + math.log(1 / epsilon)
    results: List[Tuple[float, float]] = []
    for i in range(n_points + 1):
        d = i / n_points
        gap = max(0.0, gap_fn(d))
        t_mix = C / gap if gap > 1e-15 else float('inf')
        results.append((d, t_mix))
    return results


def verify_ivt(
    gap_fn: Callable[[float], float],
    n_targets: int = 50
) -> List[Tuple[float, float, float]]:
    """
    Algorithm 4: IVT Verification
    
    For each target value y in [0, gap(0)], find d with gap(d) ≈ y.
    
    Pseudocode:
        gap0 = gap_fn(0)
        for y in linspace(0, gap0, n):
            d = binary_search(gap_fn, y)
            error = |gap_fn(d) - y|
            yield (y, d, error)
    """
    gap0 = gap_fn(0)
    results: List[Tuple[float, float, float]] = []
    for i in range(n_targets + 1):
        y = i * gap0 / n_targets
        # Binary search: gap is decreasing
        lo, hi = 0.0, 1.0
        for _ in range(100):
            mid = (lo + hi) / 2
            if gap_fn(mid) > y:
                lo = mid
            else:
                hi = mid
        d_found = (lo + hi) / 2
        error = abs(gap_fn(d_found) - y)
        results.append((y, d_found, error))
    return results


def spectral_refinement_chain(
    landscapes: List[SpectralLandscape]
) -> List[Tuple[int, int, bool]]:
    """
    Algorithm 5: Refinement Chain Verification
    
    Verify that a sequence of landscapes forms a refinement chain.
    
    Pseudocode:
        for i, j in pairs:
            is_refinement = all(L[j].gap(d) <= L[i].gap(d) for d)
            yield (i, j, is_refinement)
    """
    results: List[Tuple[int, int, bool]] = []
    for i in range(len(landscapes)):
        for j in range(i + 1, len(landscapes)):
            is_ref = landscapes[j].refines(landscapes[i])
            results.append((i, j, is_ref))
    return results


# === Factory Functions for Common Landscapes ===

def sudoku_landscape(alpha: float = 2.0) -> SpectralLandscape:
    """Create a Sudoku spectral landscape with power-law decay."""
    df = 30 / 81  # frozen density
    return SpectralLandscape(
        gap_fn=lambda d: max(0.0, (1 - d / df) ** alpha) if d < df else 0.0
    )

def latin_square_landscape(n: int) -> SpectralLandscape:
    """Create a Latin square spectral landscape for n×n grids."""
    df = 1 - 1 / n  # approximate frozen density
    return SpectralLandscape(
        gap_fn=lambda d, _df=df: max(0.0, (1 - d / _df) ** 2) if d < _df else 0.0
    )

def random_ksat_landscape(k: int = 3) -> SpectralLandscape:
    """Create a random k-SAT spectral landscape."""
    # Critical density for k-SAT: approximately 2^k * ln(2) - (1 + ln(2))/2
    dc = 2**k * math.log(2) - (1 + math.log(2)) / 2
    # Normalized to [0,1]
    dc_norm = min(dc / (10 * dc), 0.9)
    return SpectralLandscape(
        gap_fn=lambda d, _dc=dc_norm: max(0.0, 1 - (d / _dc) ** 2) if d < _dc else 0.0
    )


if __name__ == "__main__":
    # Quick demo
    L = sudoku_landscape()
    print(f"Sudoku landscape valid: {L.is_valid()}")
    print(f"Critical density: {L.critical_density():.6f}")
    print(f"Expected: {30/81:.6f}")
    
    profile = MixingProfile(L, state_space_size=int(6.67e21), tolerance=0.01)
    print(f"\nMixing time at d=0: {profile.mixing_time(0):.1f}")
    print(f"Mixing time at d=0.2: {profile.mixing_time(0.2):.1f}")
    print(f"Mixing time at d=0.35: {profile.mixing_time(0.35):.1f}")
    print(f"Mixing time at d=0.37: {profile.mixing_time(0.37)}")
