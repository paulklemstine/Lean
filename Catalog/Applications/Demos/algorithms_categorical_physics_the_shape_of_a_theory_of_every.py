#!/usr/bin/env python3
"""
Categorical Physics: Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


# ============================================================
# Core Types
# ============================================================

class TheoryType(Enum):
    """Physical theory types in the shadow hierarchy."""
    TQFT = auto()      # Topological QFT (level 0)
    CFT = auto()        # Conformal field theory (level 1)
    String = auto()     # String theory (level 1)
    Gravity = auto()    # Gravitational theory (level 2)


@dataclass(frozen=True)
class OracleLevel:
    """Oracle level in the arithmetical hierarchy."""
    sigma_level: int
    pi_level: int

    def __post_init__(self) -> None:
        assert self.pi_level <= self.sigma_level + 1
        assert self.sigma_level <= self.pi_level + 1

    @property
    def is_computable(self) -> bool:
        return self.sigma_level == 0 and self.pi_level == 0


@dataclass
class DualizableTower:
    """
    A dualizable tower: infinite sequence of object types
    with involutive duality, stabilizing above some level.
    """
    obj_sizes: List[int]
    stable_level: int
    _dual_fixed_points: Optional[List[int]] = field(default=None, repr=False)

    def obj_count(self, level: int) -> int:
        """Number of objects at a given level."""
        if level >= self.stable_level:
            return 1  # subsingleton in stable range
        if level < len(self.obj_sizes):
            return self.obj_sizes[level]
        return 1

    def is_subsingleton(self, level: int) -> bool:
        """Whether the level has at most one object."""
        return self.obj_count(level) <= 1

    def is_two_infinity(self) -> bool:
        """Whether the tower is (2,∞)-shaped."""
        return self.stable_level == 2

    def essential_dim(self) -> int:
        """The essential dimension = stable level."""
        return self.stable_level

    def duality_orbit_count(self, level: int) -> int:
        """Number of duality orbits at a level (Z/2 action)."""
        n = self.obj_count(level)
        return (n + 1) // 2  # ceil(n/2) for involution


# ============================================================
# Algorithm 1: TQFT Oracle Level
# ============================================================

def tqft_oracle_level(d: int) -> OracleLevel:
    """
    Compute the oracle level of TQFTs in dimension d.

    - d ≤ 3: computable (level 0)
    - d = 4: undecidable (level 1, from Markov's theorem)
    - d ≥ 5: higher oracle levels

    Returns: OracleLevel with sigma and pi levels.

    Time: O(1)
    Space: O(1)
    """
    if d <= 3:
        return OracleLevel(sigma_level=0, pi_level=0)
    else:
        level = d - 3
        return OracleLevel(sigma_level=level, pi_level=level)


# ============================================================
# Algorithm 2: Theory Spectrum
# ============================================================

# Required categorical levels for each theory type
REQUIRED_LEVEL: Dict[TheoryType, int] = {
    TheoryType.TQFT: 0,
    TheoryType.CFT: 1,
    TheoryType.String: 1,
    TheoryType.Gravity: 2,
}


def theory_spectrum(tower: DualizableTower) -> Set[TheoryType]:
    """
    Compute the theory spectrum of a dualizable tower.

    A theory type t is in the spectrum iff the tower has
    non-trivial structure at the required categorical level.

    Time: O(|TheoryType|) = O(1)
    """
    return {
        t for t in TheoryType
        if not tower.is_subsingleton(REQUIRED_LEVEL[t])
    }


# ============================================================
# Algorithm 3: Minimum Stability Level
# ============================================================

def min_stable_level(theories: Set[TheoryType]) -> int:
    """
    Compute the minimum stable level for a tower supporting
    all given theory types.

    This is max(required_level(t) + 1) over t in theories.

    Time: O(|theories|)
    """
    if not theories:
        return 0
    return max(REQUIRED_LEVEL[t] + 1 for t in theories)


# ============================================================
# Algorithm 4: Computability Classification
# ============================================================

def is_computable_theory(max_dim: int) -> bool:
    """
    Check if a theory covering dimensions 0..max_dim is computable.

    Equivalent to max_dim ≤ 3 (computability threshold theorem).

    Time: O(1) [using the proven threshold]
    """
    return max_dim <= 3


def computability_threshold() -> int:
    """
    Return the computability threshold dimension.

    Any theory covering dimensions beyond this threshold
    contains non-computable information.

    Returns: 3
    """
    return 3


# ============================================================
# Algorithm 5: Tower Validator
# ============================================================

def validate_tower(tower: DualizableTower) -> List[str]:
    """
    Validate consistency of a dualizable tower.

    Checks:
    1. All obj_sizes are positive
    2. Levels above stable_level are subsingleton
    3. Duality orbit counts are consistent

    Returns: list of validation errors (empty if valid)
    """
    errors: List[str] = []

    for i, size in enumerate(tower.obj_sizes):
        if size <= 0:
            errors.append(f"Level {i}: obj_size must be positive, got {size}")

    for i in range(tower.stable_level, len(tower.obj_sizes)):
        if tower.obj_sizes[i] > 1:
            errors.append(
                f"Level {i}: must be subsingleton (≤1 object) "
                f"above stable_level={tower.stable_level}, got {tower.obj_sizes[i]}"
            )

    for i in range(len(tower.obj_sizes)):
        orbits = tower.duality_orbit_count(i)
        size = tower.obj_count(i)
        if orbits > size:
            errors.append(
                f"Level {i}: orbit count {orbits} exceeds object count {size}"
            )

    return errors


# ============================================================
# Algorithm 6: Shadow Extraction
# ============================================================

@dataclass
class ShadowExtraction:
    """Extract a shadow (truncated theory) from a tower."""
    source: DualizableTower
    theory_type: TheoryType
    visible_levels: int

    @staticmethod
    def create(source: DualizableTower, theory_type: TheoryType) -> 'ShadowExtraction':
        """Create a shadow extraction with correct visible levels."""
        visible = {
            TheoryType.TQFT: 1,
            TheoryType.CFT: 2,
            TheoryType.String: 2,
            TheoryType.Gravity: 3,
        }[theory_type]
        return ShadowExtraction(source=source, theory_type=theory_type,
                                visible_levels=visible)

    def truncated_tower(self) -> DualizableTower:
        """The tower truncated to visible levels."""
        truncated_sizes = [
            self.source.obj_count(i) if i < self.visible_levels else 1
            for i in range(max(len(self.source.obj_sizes), self.visible_levels))
        ]
        return DualizableTower(
            obj_sizes=truncated_sizes,
            stable_level=min(self.source.stable_level, self.visible_levels)
        )


# ============================================================
# Algorithm 7: Two-Infinity Necessity Check
# ============================================================

def check_two_infinity_necessity(
    shadows: Set[TheoryType],
    stable_level: int
) -> Tuple[bool, Optional[str]]:
    """
    Check the (2,∞)-necessity theorem: if shadows include both
    TQFT and String, stable_level must be >= 2.

    Returns: (is_valid, reason_if_invalid)
    """
    if TheoryType.TQFT in shadows and TheoryType.String in shadows:
        if stable_level < 2:
            if stable_level == 0:
                return False, "TQFT requires non-trivial level 0, but stable_level=0 makes it trivial"
            else:
                return False, "String requires non-trivial level 1, but stable_level=1 makes it trivial"
    return True, None


# ============================================================
# Algorithm 8: Dimension Gap Check
# ============================================================

def check_dimension_gap(
    stable_level: int,
    spectrum: Set[TheoryType]
) -> Tuple[bool, Optional[str]]:
    """
    Check the dimension gap theorem: stable_level=1 cannot
    support both TQFT and Gravity.

    Returns: (has_gap, explanation)
    """
    if stable_level == 1:
        if TheoryType.TQFT in spectrum and TheoryType.Gravity in spectrum:
            return True, (
                "Dimension gap detected: stable_level=1 forces Obj(2) to be "
                "subsingleton, blocking Gravity. TQFT and Gravity cannot coexist."
            )
    return False, None


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test oracle levels
    assert tqft_oracle_level(3).is_computable
    assert not tqft_oracle_level(4).is_computable
    assert tqft_oracle_level(4).sigma_level == 1
    assert tqft_oracle_level(7).sigma_level == 4

    # Test theory spectrum
    t = DualizableTower([2, 2, 1], 2)
    spec = theory_spectrum(t)
    assert TheoryType.TQFT in spec
    assert TheoryType.String in spec
    assert TheoryType.Gravity not in spec

    # Test minimum stability
    assert min_stable_level({TheoryType.TQFT, TheoryType.String}) == 2
    assert min_stable_level({TheoryType.Gravity}) == 3

    # Test computability
    assert is_computable_theory(3)
    assert not is_computable_theory(4)

    # Test validation
    valid_tower = DualizableTower([3, 2, 1], 2)
    assert validate_tower(valid_tower) == []

    invalid_tower = DualizableTower([3, 2, 3], 2)
    assert len(validate_tower(invalid_tower)) > 0

    # Test two-infinity necessity
    ok, _ = check_two_infinity_necessity({TheoryType.TQFT, TheoryType.String}, 2)
    assert ok
    ok, reason = check_two_infinity_necessity({TheoryType.TQFT, TheoryType.String}, 1)
    assert not ok

    print("All self-tests passed!")
