"""
Categorical Physics: Algorithms

Type-hinted implementations of the core algorithms from the categorical
physics framework.
"""

from typing import Set, Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum, auto


class TheoryType(Enum):
    """Physical theory types in the shadow hierarchy."""
    TQFT = auto()     # Topological quantum field theory
    CFT = auto()      # Conformal field theory
    STRING = auto()   # String theory
    GRAVITY = auto()  # Gravitational theory


@dataclass
class OracleLevel:
    """Computability level in the oracle hierarchy."""
    sigma_level: int  # Σ^n completeness
    pi_level: int     # Π^n completeness
    
    @property
    def is_computable(self) -> bool:
        return self.sigma_level == 0


@dataclass
class DualizableTower:
    """Algebraic skeleton of a (k,∞)-category with duals.
    
    Attributes:
        stable_level: Level at which the tower stabilizes
        nontrivial_levels: Set of levels with nontrivial object types
    """
    stable_level: int
    nontrivial_levels: Set[int]
    
    def is_two_infinity(self) -> bool:
        """Check if the tower is (2,∞)-shaped."""
        return self.stable_level == 2
    
    def spectrum(self) -> Set[TheoryType]:
        """Compute the theory spectrum of this tower."""
        spec = set()
        if 0 in self.nontrivial_levels:
            spec.add(TheoryType.TQFT)
        if 1 in self.nontrivial_levels:
            spec |= {TheoryType.CFT, TheoryType.STRING}
        if 2 in self.nontrivial_levels:
            spec.add(TheoryType.GRAVITY)
        return spec


@dataclass
class DefectTowerData:
    """Data for a defect tower in dimension d."""
    dimension: int
    defect_counts: List[int]  # Number of defects at each codimension
    self_dual_counts: List[int]  # Self-dual defects at each codimension
    
    def duality_sectors(self) -> List[int]:
        """Compute independent duality sectors at each codimension."""
        sectors = []
        for n, sd in zip(self.defect_counts, self.self_dual_counts):
            non_sd = n - sd
            sectors.append(sd + non_sd // 2)
        return sectors


@dataclass 
class DimensionalLadder:
    """A sequence of theories connected by compactification."""
    dimensions: List[int]
    
    @property
    def height(self) -> int:
        return len(self.dimensions) - 1
    
    def is_strictly_increasing(self) -> bool:
        return all(a < b for a, b in zip(self.dimensions, self.dimensions[1:]))
    
    def oracle_profile(self) -> List[OracleLevel]:
        return [compute_oracle_level(d) for d in self.dimensions]
    
    def first_noncomputable(self) -> Optional[int]:
        """Index of first noncomputable rung, or None."""
        for i, d in enumerate(self.dimensions):
            if compute_oracle_level(d).sigma_level > 0:
                return i
        return None


# ═══════════════════════════════════════════════════════════════
#  Core Algorithms
# ═══════════════════════════════════════════════════════════════

def compute_oracle_level(d: int) -> OracleLevel:
    """Compute oracle level for TQFT in dimension d.
    
    Algorithm: σ_d = π_d = max(0, d - 3)
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    The oracle level captures the computational complexity of
    classifying d-manifolds: for d ≤ 3, the classification is
    algorithmic; for d ≥ 4, it requires oracles of increasing
    strength due to the undecidability of the word problem for
    finitely presented groups (Markov, 1958).
    """
    level = max(0, d - 3)
    return OracleLevel(sigma_level=level, pi_level=level)


def compute_min_stable_level(theories: Set[TheoryType]) -> int:
    """Compute minimum categorical stable level for a set of theories.
    
    Implements the (2,∞)-necessity theorem and generalizations:
    - TQFT alone needs level ≥ 1
    - String/CFT needs level ≥ 2  
    - Gravity needs level ≥ 3
    
    Time complexity: O(|theories|)
    """
    level = 0
    if TheoryType.TQFT in theories:
        level = max(level, 1)
    if TheoryType.CFT in theories or TheoryType.STRING in theories:
        level = max(level, 2)
    if TheoryType.GRAVITY in theories:
        level = max(level, 3)
    return level


def compute_shadow_set(stable_level: int) -> Set[TheoryType]:
    """Compute maximal shadow set for given stable level.
    
    Time complexity: O(1)
    """
    shadows: Set[TheoryType] = set()
    if stable_level >= 1:
        shadows.add(TheoryType.TQFT)
    if stable_level >= 2:
        shadows |= {TheoryType.CFT, TheoryType.STRING}
    if stable_level >= 3:
        shadows.add(TheoryType.GRAVITY)
    return shadows


def is_computable_theory(max_dim: int) -> bool:
    """Test whether a theory is computable.
    
    A theory is computable iff it only concerns dimensions ≤ 3.
    
    Time complexity: O(1)
    """
    return max_dim <= 3


def compute_duality_sector_bound(n: int) -> int:
    """Compute upper bound on independent duality sectors.
    
    With n objects under involutive duality:
    - Self-dual objects contribute 1 each
    - Non-self-dual pairs contribute 1 each
    - Bound: ⌈n/2⌉ = (n + 1) // 2
    
    Time complexity: O(1)
    """
    return (n + 1) // 2


def analyze_dimensional_ladder(dims: List[int]) -> Dict:
    """Full analysis of a dimensional ladder.
    
    Returns dictionary with computability profile, oracle levels,
    and identification of the computability cliff.
    
    Time complexity: O(|dims|)
    """
    ladder = DimensionalLadder(dims)
    profile = ladder.oracle_profile()
    
    return {
        "height": ladder.height,
        "is_valid": ladder.is_strictly_increasing(),
        "oracle_levels": [o.sigma_level for o in profile],
        "is_fully_computable": all(o.is_computable for o in profile),
        "first_noncomputable_rung": ladder.first_noncomputable(),
        "max_oracle_level": max(o.sigma_level for o in profile),
        "computable_fraction": sum(1 for o in profile if o.is_computable) / len(profile),
    }


def verify_necessity_theorem(
    shadows: Set[TheoryType],
    stable_level: int
) -> Tuple[bool, str]:
    """Verify the (2,∞)-necessity theorem for given parameters.
    
    Returns (is_consistent, explanation).
    """
    min_level = compute_min_stable_level(shadows)
    if stable_level >= min_level:
        return True, f"Consistent: stable level {stable_level} ≥ minimum {min_level}"
    else:
        return False, (
            f"INCONSISTENT: stable level {stable_level} < minimum {min_level}. "
            f"The (2,∞)-necessity theorem forbids this configuration."
        )


def build_defect_tower(
    dimension: int,
    defects_per_codim: Optional[List[int]] = None
) -> DefectTowerData:
    """Build a defect tower with specified defect counts.
    
    If defects_per_codim is None, uses a default pattern:
    bulk has 1 defect, then decreasing.
    """
    if defects_per_codim is None:
        defects_per_codim = [max(1, 2**(dimension - k)) for k in range(dimension + 1)]
    
    # Self-dual defects: at most ceil(n/2) can be self-dual
    self_dual = [(n + 1) // 2 for n in defects_per_codim]
    
    return DefectTowerData(
        dimension=dimension,
        defect_counts=defects_per_codim,
        self_dual_counts=self_dual,
    )


# ═══════════════════════════════════════════════════════════════
#  Entry Point
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Example: verify the necessity theorem
    shadows = {TheoryType.TQFT, TheoryType.STRING}
    for sl in range(5):
        ok, msg = verify_necessity_theorem(shadows, sl)
        print(f"  stable_level={sl}: {msg}")
    
    print()
    
    # Example: analyze a ladder
    ladder_dims = list(range(8))
    analysis = analyze_dimensional_ladder(ladder_dims)
    print(f"Ladder {ladder_dims}:")
    for k, v in analysis.items():
        print(f"  {k}: {v}")
