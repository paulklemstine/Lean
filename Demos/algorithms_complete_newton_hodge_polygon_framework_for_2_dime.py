#!/usr/bin/env python3
"""
Newton-Hodge Polygon Framework: Core Algorithms

Type-hinted implementations of the key algorithms for computing
monodromy defects, classifying filtered φ-modules, and navigating
the admissibility space.
"""

from dataclasses import dataclass
from enum import Enum
from typing import List, Tuple, Optional


class DefectClass(Enum):
    """Classification of a filtered φ-module by its defect."""
    ORDINARY = "ordinary"
    GENERIC = "generic"
    SUPERSINGULAR = "supersingular"


@dataclass(frozen=True)
class FilteredPhiModule2:
    """A 2-dimensional filtered φ-module.

    Attributes:
        w1, w2: Hodge-Tate weights (w1 ≤ w2)
        s1, s2: Newton slopes (s1 ≤ s2, s1 + s2 = w1 + w2)
    """
    w1: float
    w2: float
    s1: float
    s2: float

    def __post_init__(self):
        assert self.w1 <= self.w2 + 1e-12, f"Hodge ordering: {self.w1} > {self.w2}"
        assert self.s1 <= self.s2 + 1e-12, f"Newton ordering: {self.s1} > {self.s2}"
        assert abs(self.s1 + self.s2 - self.w1 - self.w2) < 1e-10, \
            f"Endpoint: {self.s1}+{self.s2} ≠ {self.w1}+{self.w2}"

    @property
    def defect(self) -> float:
        """Monodromy defect δ = s₁ - w₁."""
        return self.s1 - self.w1

    @property
    def hodge_gap(self) -> float:
        """Hodge gap γ = w₂ - w₁."""
        return self.w2 - self.w1

    @property
    def newton_spread(self) -> float:
        """Newton spread σ = s₂ - s₁."""
        return self.s2 - self.s1

    @property
    def normalized_defect(self) -> float:
        """Normalized defect δ/γ ∈ [0, 1/2]."""
        if self.hodge_gap < 1e-15:
            return 0.0
        return self.defect / self.hodge_gap

    def hodge_polygon(self, x: float) -> float:
        """Evaluate Hodge polygon at x ∈ [0, 2]."""
        if x <= 1:
            return self.w1 * x
        return self.w1 + self.w2 * (x - 1)

    def newton_polygon(self, x: float) -> float:
        """Evaluate Newton polygon at x ∈ [0, 2]."""
        if x <= 1:
            return self.s1 * x
        return self.s1 + self.s2 * (x - 1)

    def polygon_gap(self, x: float) -> float:
        """Polygon gap G(x) = N(x) - H(x)."""
        return self.newton_polygon(x) - self.hodge_polygon(x)

    @property
    def is_weakly_admissible(self) -> bool:
        """Check weak admissibility (δ ≥ 0)."""
        return self.defect >= -1e-12

    @property
    def classification(self) -> DefectClass:
        """Classify by defect."""
        d = self.defect
        g = self.hodge_gap
        if abs(d) < 1e-12:
            return DefectClass.ORDINARY
        if abs(d - g / 2) < 1e-12:
            return DefectClass.SUPERSINGULAR
        return DefectClass.GENERIC


# ============================================================
# Algorithm 1: Reconstruct Newton slopes from defect
# ============================================================

def reconstruct_from_defect(
    w1: float, w2: float, delta: float
) -> FilteredPhiModule2:
    """
    Given Hodge weights and defect, reconstruct the full module.

    Algorithm:
        s₁ = w₁ + δ
        s₂ = w₂ - δ  (by defect symmetry)

    Preconditions: 0 ≤ δ ≤ (w₂ - w₁)/2
    """
    s1 = w1 + delta
    s2 = w2 - delta
    return FilteredPhiModule2(w1, w2, s1, s2)


# ============================================================
# Algorithm 2: Enumerate all integer-defect modules
# ============================================================

def enumerate_integer_modules(
    w1: int, w2: int
) -> List[FilteredPhiModule2]:
    """
    Enumerate all weakly admissible modules with integer Newton slopes.

    There are exactly ⌊(w₂ - w₁)/2⌋ + 1 such modules.
    """
    gamma = w2 - w1
    modules = []
    for delta_2 in range(gamma + 1):  # delta_2 = 2*delta
        if delta_2 % 2 != (gamma % 2) and delta_2 % 2 != 0:
            # For integer slopes, we need delta to give integer s1, s2
            # s1 = w1 + delta, s2 = w2 - delta
            # Both integer iff delta is integer
            continue
        if delta_2 > gamma:
            break
        delta = delta_2 / 2
        if delta != int(delta):
            continue
        delta = int(delta)
        modules.append(reconstruct_from_defect(w1, w2, delta))
    return modules


# ============================================================
# Algorithm 3: Tropical distance matrix
# ============================================================

def tropical_distance(m1: FilteredPhiModule2, m2: FilteredPhiModule2) -> float:
    """Tropical distance |δ₁ - δ₂|."""
    return abs(m1.defect - m2.defect)


def tropical_distance_matrix(
    modules: List[FilteredPhiModule2]
) -> List[List[float]]:
    """Compute the pairwise tropical distance matrix."""
    n = len(modules)
    matrix = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            matrix[i][j] = tropical_distance(modules[i], modules[j])
    return matrix


# ============================================================
# Algorithm 4: Defect interpolation path
# ============================================================

def defect_path(
    w1: float, w2: float, n_steps: int = 100
) -> List[Tuple[float, FilteredPhiModule2]]:
    """
    Generate a path through the admissibility space from
    ordinary (δ=0) to supersingular (δ=γ/2).

    Returns list of (delta, module) pairs.
    """
    gamma = w2 - w1
    max_delta = gamma / 2
    path = []
    for i in range(n_steps + 1):
        delta = max_delta * i / n_steps
        m = reconstruct_from_defect(w1, w2, delta)
        path.append((delta, m))
    return path


# ============================================================
# Algorithm 5: Polygon area computation
# ============================================================

def polygon_gap_area(m: FilteredPhiModule2, n_points: int = 1000) -> float:
    """
    Compute the area between Newton and Hodge polygons
    by trapezoidal integration.

    Should equal the defect δ (by our tent area theorem).
    """
    dx = 2.0 / n_points
    area = 0.0
    for i in range(n_points):
        x0 = i * dx
        x1 = (i + 1) * dx
        g0 = m.polygon_gap(x0)
        g1 = m.polygon_gap(x1)
        area += (g0 + g1) * dx / 2
    return area


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Reconstruction
    print("1. Reconstruct from defect:")
    for delta in [0, 1, 2, 3]:
        m = reconstruct_from_defect(0, 6, delta)
        print(f"   δ={delta}: s=({m.s1}, {m.s2}), class={m.classification.value}")

    # Enumeration
    print("\n2. Integer modules for w=(0,6):")
    mods = enumerate_integer_modules(0, 6)
    for m in mods:
        print(f"   s=({m.s1}, {m.s2}), δ={m.defect}, class={m.classification.value}")

    # Distance matrix
    print("\n3. Tropical distance matrix:")
    mat = tropical_distance_matrix(mods)
    for row in mat:
        print("   " + "  ".join(f"{v:.0f}" for v in row))

    # Gap area verification
    print("\n4. Polygon gap area (should equal δ):")
    for delta in [0.5, 1.0, 1.5, 2.0, 2.5]:
        m = reconstruct_from_defect(0, 6, delta)
        area = polygon_gap_area(m)
        print(f"   δ={delta:.1f}, computed area={area:.6f}, error={abs(area-delta):.2e}")
