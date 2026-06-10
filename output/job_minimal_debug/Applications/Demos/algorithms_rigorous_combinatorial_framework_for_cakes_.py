"""
Cake Moduli: Algorithms for Stratified Surface Combinatorics

Implements the core computations for cakes (stratified surfaces):
- Moduli dimension formulas
- Euler characteristic computation
- Handle and boundary gluing operations
- Tropical moduli for metric graphs
- Geometric classification
"""

from dataclasses import dataclass
from typing import Literal, List, Tuple
from enum import Enum


class GeomType(Enum):
    SPHERICAL = "spherical"   # χ > 0
    FLAT = "flat"             # χ = 0
    HYPERBOLIC = "hyperbolic" # χ < 0


@dataclass(frozen=True)
class Cake:
    """A stratified surface with genus, boundary, marked points, and layers."""
    genus: int
    boundary: int
    marked: int
    layers: int

    def __post_init__(self) -> None:
        assert self.genus >= 0, "Genus must be non-negative"
        assert self.boundary >= 0, "Boundary count must be non-negative"
        assert self.marked >= 0, "Marked point count must be non-negative"
        assert self.layers >= 1, "Must have at least one layer"

    def euler_char(self) -> int:
        """Euler characteristic: χ = 2 - 2g - b."""
        return 2 - 2 * self.genus - self.boundary

    def moduli_dim(self) -> int:
        """Moduli dimension: 6g - 6 + 2n + 3b."""
        return 6 * self.genus - 6 + 2 * self.marked + 3 * self.boundary

    def complexity(self) -> int:
        """Complexity measure: 2g + b + n."""
        return 2 * self.genus + self.boundary + self.marked

    def geom_type(self) -> GeomType:
        """Geometric classification by Euler characteristic sign."""
        chi = self.euler_char()
        if chi > 0:
            return GeomType.SPHERICAL
        elif chi == 0:
            return GeomType.FLAT
        else:
            return GeomType.HYPERBOLIC

    def handle_glue(self, other: 'Cake') -> 'Cake':
        """Handle glue two cakes: connects by a tube, adding a handle.

        Requires both surfaces to have at least one boundary component.
        Result: g = g₁+g₂+1, b = b₁+b₂-2, n = n₁+n₂, k = k₁+k₂
        """
        assert self.boundary >= 1, "First cake needs boundary for gluing"
        assert other.boundary >= 1, "Second cake needs boundary for gluing"
        return Cake(
            genus=self.genus + other.genus + 1,
            boundary=self.boundary + other.boundary - 2,
            marked=self.marked + other.marked,
            layers=self.layers + other.layers
        )

    def boundary_glue(self, other: 'Cake') -> 'Cake':
        """Boundary glue two cakes: identifies boundary circles, no handle.

        Requires both surfaces to have at least one boundary component.
        Result: g = g₁+g₂, b = b₁+b₂-2, n = n₁+n₂, k = k₁+k₂
        """
        assert self.boundary >= 1, "First cake needs boundary for gluing"
        assert other.boundary >= 1, "Second cake needs boundary for gluing"
        return Cake(
            genus=self.genus + other.genus,
            boundary=self.boundary + other.boundary - 2,
            marked=self.marked + other.marked,
            layers=self.layers + other.layers
        )


# Standard cakes
DISK = Cake(genus=0, boundary=1, marked=0, layers=1)
PANTS = Cake(genus=0, boundary=3, marked=0, layers=1)
PUNCTURED_TORUS = Cake(genus=1, boundary=1, marked=0, layers=1)
ANNULUS = Cake(genus=0, boundary=2, marked=0, layers=1)


def verify_superadditivity(c1: Cake, c2: Cake) -> Tuple[bool, int]:
    """Verify that dim(c1 ⊕ c2) = dim(c1) + dim(c2) + 6.

    Returns (is_verified, surplus) where surplus should always be 6.
    """
    glued = c1.handle_glue(c2)
    surplus = glued.moduli_dim() - c1.moduli_dim() - c2.moduli_dim()
    return surplus == 6, surplus


def verify_moduli_euler_bridge(c: Cake) -> bool:
    """Verify that dim = -3χ + 2n."""
    return c.moduli_dim() == -3 * c.euler_char() + 2 * c.marked


def iterated_handle_glue(cakes: List[Cake]) -> Cake:
    """Sequentially handle-glue a list of cakes (left to right).

    The moduli dimension should be sum(dim(Cᵢ)) + 6*(n-1) where n = len(cakes).
    """
    assert len(cakes) >= 1, "Need at least one cake"
    result = cakes[0]
    for c in cakes[1:]:
        result = result.handle_glue(c)
    return result


@dataclass(frozen=True)
class TropicalCake:
    """A tropical cake (metric graph) with edge/vertex/leaf data."""
    edge_count: int
    leaves: int
    interior_vertices: int
    depth: int

    def betti(self) -> int:
        """First Betti number: β₁ = e - ℓ - v + 1."""
        return self.edge_count - self.leaves - self.interior_vertices + 1

    def trop_moduli_dim(self) -> int:
        """Tropical moduli dimension: e - ℓ (internal edge count)."""
        return self.edge_count - self.leaves

    def is_trivalent(self) -> bool:
        """Check if the graph is trivalent (2e = 3v + ℓ)."""
        return 2 * self.edge_count == 3 * self.interior_vertices + self.leaves

    def verify_tropical_formula(self) -> bool:
        """For trivalent graphs: dim_trop = 3β₁ - 3 + ℓ."""
        if not self.is_trivalent():
            return False
        return self.trop_moduli_dim() == 3 * self.betti() - 3 + self.leaves


def build_gluing_tower(n: int, base: Cake = DISK) -> List[Tuple[Cake, int]]:
    """Build a tower of n handle gluings from (n+1) copies of base.

    Returns list of (cake, moduli_dim) at each stage.
    """
    stages: List[Tuple[Cake, int]] = [(base, base.moduli_dim())]
    current = base
    for i in range(n):
        current = current.handle_glue(base)
        stages.append((current, current.moduli_dim()))
    return stages


def classify_surface(g: int, b: int, n: int) -> dict:
    """Complete classification of a surface by its invariants."""
    c = Cake(genus=g, boundary=b, marked=n, layers=1)
    return {
        "genus": g,
        "boundary": b,
        "marked": n,
        "euler_char": c.euler_char(),
        "moduli_dim": c.moduli_dim(),
        "complexity": c.complexity(),
        "geom_type": c.geom_type().value,
        "moduli_euler_bridge": verify_moduli_euler_bridge(c),
    }
