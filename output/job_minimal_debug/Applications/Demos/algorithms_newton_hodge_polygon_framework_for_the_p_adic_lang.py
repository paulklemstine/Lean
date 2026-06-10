#!/usr/bin/env python3
"""
Newton-Hodge Polygon Algorithms

Type-hinted implementations of the core algorithms in the Newton-Hodge
polygon framework for 2-dimensional filtered φ-modules.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class FilteredPhiModule:
    """A 2-dimensional filtered φ-module with Hodge-Tate weights and Newton slopes."""
    w1: float  # First Hodge-Tate weight (w₁ ≤ w₂)
    w2: float  # Second Hodge-Tate weight
    s1: float  # First Newton slope (s₁ ≤ s₂)
    s2: float  # Second Newton slope

    def __post_init__(self) -> None:
        assert self.w1 <= self.w2, f"Hodge weights must be ordered: {self.w1} > {self.w2}"
        assert self.s1 <= self.s2, f"Newton slopes must be ordered: {self.s1} > {self.s2}"


def monodromy_defect(M: FilteredPhiModule) -> float:
    """Compute the monodromy defect δ = s₁ - w₁.

    The defect measures how far the module is from being ordinary.
    δ = 0 ↔ ordinary, δ = (w₂-w₁)/2 ↔ supersingular.
    """
    return M.s1 - M.w1


def hodge_spectral_gap(M: FilteredPhiModule) -> float:
    """Compute the spectral gap w₂ - w₁ of the Hodge filtration."""
    return M.w2 - M.w1


def is_weakly_admissible(M: FilteredPhiModule, tol: float = 1e-10) -> bool:
    """Check the weak admissibility condition.

    A 2-dim filtered φ-module is weakly admissible iff:
    1. w₁ ≤ s₁ (Newton above Hodge at midpoint)
    2. s₁ + s₂ = w₁ + w₂ (endpoint matching)
    """
    return (M.w1 <= M.s1 + tol and
            abs((M.s1 + M.s2) - (M.w1 + M.w2)) < tol)


def classify_module(M: FilteredPhiModule, tol: float = 1e-10) -> str:
    """Classify a weakly admissible module as ordinary, supersingular, or intermediate.

    Returns:
        'ordinary' if δ = 0
        'supersingular' if δ = (w₂-w₁)/2 (i.e., s₁ = s₂)
        'intermediate' otherwise
        'not_admissible' if not weakly admissible
    """
    if not is_weakly_admissible(M, tol):
        return "not_admissible"
    delta = monodromy_defect(M)
    max_delta = hodge_spectral_gap(M) / 2.0
    if abs(delta) < tol:
        return "ordinary"
    elif abs(delta - max_delta) < tol:
        return "supersingular"
    else:
        return "intermediate"


def newton_polygon(M: FilteredPhiModule, x: int) -> float:
    """Evaluate the Newton polygon NP(x) at x ∈ {0, 1, 2}.

    NP(0) = 0, NP(1) = s₁, NP(2) = s₁ + s₂.
    """
    if x == 0:
        return 0.0
    elif x == 1:
        return M.s1
    else:
        return M.s1 + M.s2


def hodge_polygon(M: FilteredPhiModule, x: int) -> float:
    """Evaluate the Hodge polygon HP(x) at x ∈ {0, 1, 2}.

    HP(0) = 0, HP(1) = w₁, HP(2) = w₁ + w₂.
    """
    if x == 0:
        return 0.0
    elif x == 1:
        return M.w1
    else:
        return M.w1 + M.w2


def slope_discriminant(M: FilteredPhiModule) -> float:
    """Compute the slope discriminant Δ = (s₁ - s₂)².

    Δ = 0 ↔ supersingular
    Δ = (w₂ - w₁)² ↔ ordinary
    """
    return (M.s1 - M.s2) ** 2


def tropical_distance(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """Compute the tropical L∞ distance between two slope pairs."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def enumerate_admissible_modules(
    w1: float, w2: float, n_steps: int = 100
) -> List[FilteredPhiModule]:
    """Enumerate weakly admissible modules by sampling the defect parameter.

    The admissibility polytope is parameterized by δ ∈ [0, (w₂-w₁)/2]:
        s₁ = w₁ + δ, s₂ = w₂ - δ

    Args:
        w1: First Hodge-Tate weight
        w2: Second Hodge-Tate weight
        n_steps: Number of sample points

    Returns:
        List of weakly admissible FilteredPhiModule instances
    """
    assert w1 <= w2, "Hodge weights must be ordered"
    max_delta = (w2 - w1) / 2.0
    modules = []
    for i in range(n_steps + 1):
        delta = max_delta * i / n_steps
        s1 = w1 + delta
        s2 = w2 - delta
        modules.append(FilteredPhiModule(w1=w1, w2=w2, s1=s1, s2=s2))
    return modules


def defect_spectrum(
    w1: float, w2: float, n_steps: int = 100
) -> List[Tuple[float, float, float, str]]:
    """Compute the spectrum of (δ, s₁, s₂, classification) over all admissible modules.

    Returns list of (delta, s1, s2, classification) tuples.
    """
    modules = enumerate_admissible_modules(w1, w2, n_steps)
    return [
        (monodromy_defect(M), M.s1, M.s2, classify_module(M))
        for M in modules
    ]


def newton_hodge_gap(M: FilteredPhiModule, x: int) -> float:
    """Compute NP(x) - HP(x), the gap between Newton and Hodge polygons.

    For weakly admissible modules, this is ≥ 0 at all vertices and = 0
    at the endpoints x=0 and x=2.
    """
    return newton_polygon(M, x) - hodge_polygon(M, x)


if __name__ == "__main__":
    # Quick test
    M = FilteredPhiModule(w1=0, w2=11, s1=3, s2=8)
    print(f"Module: {M}")
    print(f"Admissible: {is_weakly_admissible(M)}")
    print(f"Defect: {monodromy_defect(M)}")
    print(f"Classification: {classify_module(M)}")
    print(f"Discriminant: {slope_discriminant(M)}")

    # Spectrum
    print("\nDefect spectrum for weights (0, 11):")
    spec = defect_spectrum(0, 11, 10)
    for delta, s1, s2, cls in spec:
        print(f"  δ={delta:5.2f}  s₁={s1:5.2f}  s₂={s2:5.2f}  {cls}")
