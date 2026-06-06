#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Core Algorithms

Type-hinted implementations of the key algorithms for computing anti-gravity
properties of theorem dependency graphs.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass, field


@dataclass
class GravitationalDerivationSystem:
    """A Gravitational Derivation System: a DAG with proof-effort annotations.

    Attributes:
        vertices: Set of theorem identifiers
        dependencies: Dict mapping each vertex to its direct dependents
        proof_effort: Dict mapping each vertex to its proof complexity measure
    """
    vertices: Set[int]
    dependencies: Dict[int, Set[int]]
    proof_effort: Dict[int, int]

    def __post_init__(self) -> None:
        for v in self.vertices:
            assert self.proof_effort.get(v, 0) > 0, f"Effort must be positive for vertex {v}"
            if v not in self.dependencies:
                self.dependencies[v] = set()

    @property
    def n(self) -> int:
        """Number of theorems in the system."""
        return len(self.vertices)

    def direct_weight(self, v: int) -> int:
        """Number of direct dependents of theorem v."""
        return len(self.dependencies.get(v, set()))

    def total_direct_weight(self) -> int:
        """Sum of all direct weights = number of dependency edges."""
        return sum(self.direct_weight(v) for v in self.vertices)

    def total_effort(self) -> int:
        """Sum of all proof efforts."""
        return sum(self.proof_effort[v] for v in self.vertices)

    def is_anti_gravitational(self, v: int) -> bool:
        """Check if theorem v is anti-gravitational (weight > effort)."""
        return self.direct_weight(v) > self.proof_effort[v]

    def is_k_anti_gravitational(self, v: int, k: int) -> bool:
        """Check if theorem v is k-anti-gravitational (weight > k * effort)."""
        return self.direct_weight(v) > k * self.proof_effort[v]

    def anti_gravity_set(self) -> Set[int]:
        """Return the set of all anti-gravitational theorems."""
        return {v for v in self.vertices if self.is_anti_gravitational(v)}

    def k_anti_gravity_set(self, k: int) -> Set[int]:
        """Return the set of all k-anti-gravitational theorems."""
        return {v for v in self.vertices if self.is_k_anti_gravitational(v, k)}

    def anti_gravity_fraction(self) -> float:
        """Fraction of theorems that are anti-gravitational."""
        if self.n == 0:
            return 0.0
        return len(self.anti_gravity_set()) / self.n

    def gravitational_spectrum(self) -> List[int]:
        """The gravitational spectrum: sorted list of all weights."""
        return sorted([self.direct_weight(v) for v in self.vertices], reverse=True)

    def max_weight(self) -> int:
        """Maximum direct weight across all theorems."""
        if not self.vertices:
            return 0
        return max(self.direct_weight(v) for v in self.vertices)

    def min_effort(self) -> int:
        """Minimum proof effort across all theorems."""
        if not self.vertices:
            return 0
        return min(self.proof_effort[v] for v in self.vertices)

    def surplus(self) -> int:
        """Weight surplus: total_weight - total_effort."""
        return self.total_direct_weight() - self.total_effort()

    def has_surplus(self) -> bool:
        """Whether the system has positive surplus (guarantees anti-gravity)."""
        return self.surplus() > 0


def find_anti_gravity_witness(gds: GravitationalDerivationSystem) -> Optional[int]:
    """Find an anti-gravitational node if one exists.

    Algorithm: Anti-Gravity Pigeonhole (constructive version)
    Complexity: O(n) where n = number of vertices

    Returns the first anti-gravitational node found, or None.
    By the pigeonhole theorem, if total_effort < total_weight, this always succeeds.
    """
    for v in gds.vertices:
        if gds.is_anti_gravitational(v):
            return v
    return None


def compute_anti_gravity_profile(
    gds: GravitationalDerivationSystem
) -> Dict[str, object]:
    """Compute a comprehensive anti-gravity profile of the system.

    Returns a dictionary with:
    - n: number of theorems
    - total_weight: sum of all weights
    - total_effort: sum of all efforts
    - surplus: weight - effort
    - ag_count: number of anti-gravity nodes
    - ag_fraction: fraction of anti-gravity nodes
    - max_weight: maximum weight
    - min_effort: minimum effort
    - spectrum: sorted weight distribution
    - max_k: highest k for which k-anti-gravity nodes exist
    """
    spectrum = gds.gravitational_spectrum()
    max_w = gds.max_weight()
    min_e = gds.min_effort()

    # Find maximum k
    max_k = 0
    if min_e > 0 and max_w > 0:
        max_k = max_w // min_e - (0 if max_w % min_e > 0 else 1)
        # Verify
        while max_k > 0 and not gds.k_anti_gravity_set(max_k):
            max_k -= 1

    return {
        "n": gds.n,
        "total_weight": gds.total_direct_weight(),
        "total_effort": gds.total_effort(),
        "surplus": gds.surplus(),
        "ag_count": len(gds.anti_gravity_set()),
        "ag_fraction": gds.anti_gravity_fraction(),
        "max_weight": max_w,
        "min_effort": min_e,
        "spectrum": spectrum,
        "max_k": max_k,
        "has_surplus": gds.has_surplus(),
    }


def verify_pigeonhole_theorem(gds: GravitationalDerivationSystem) -> bool:
    """Verify the Anti-Gravity Pigeonhole Theorem on a concrete instance.

    Returns True if the theorem's prediction holds:
    total_effort < total_weight => anti_gravity_set is nonempty.
    """
    if gds.total_effort() < gds.total_direct_weight():
        return len(gds.anti_gravity_set()) > 0
    return True  # Theorem makes no claim when there's no surplus


def verify_weight_monotonicity(
    gds1: GravitationalDerivationSystem,
    gds2: GravitationalDerivationSystem,
) -> bool:
    """Verify weight monotonicity: if gds1.deps ⊆ gds2.deps, then weights increase.

    Both systems must have the same vertex set.
    """
    assert gds1.vertices == gds2.vertices
    for v in gds1.vertices:
        if not gds1.dependencies[v].issubset(gds2.dependencies[v]):
            return True  # Precondition not met, theorem doesn't apply
        if gds1.direct_weight(v) > gds2.direct_weight(v):
            return False
    return True


def verify_effort_scaling(
    gds: GravitationalDerivationSystem, k: int
) -> bool:
    """Verify that scaling efforts by k ≥ 1 shrinks the anti-gravity set."""
    if k < 1:
        return True

    scaled = GravitationalDerivationSystem(
        vertices=gds.vertices,
        dependencies={v: set(deps) for v, deps in gds.dependencies.items()},
        proof_effort={v: k * e for v, e in gds.proof_effort.items()},
    )

    return scaled.anti_gravity_set().issubset(gds.anti_gravity_set())


if __name__ == "__main__":
    # Example: a small dependency graph
    vertices = {0, 1, 2, 3, 4}
    deps = {
        0: {1, 2, 3, 4},  # Theorem 0 is a foundation (high weight)
        1: {3, 4},
        2: {4},
        3: set(),
        4: set(),
    }
    efforts = {0: 1, 1: 2, 2: 3, 3: 1, 4: 1}

    gds = GravitationalDerivationSystem(vertices, deps, efforts)
    profile = compute_anti_gravity_profile(gds)

    print("Anti-Gravity Profile:")
    for key, value in profile.items():
        if key != "spectrum":
            print(f"  {key}: {value}")
    print(f"  spectrum: {profile['spectrum']}")

    print(f"\nPigeonhole theorem verified: {verify_pigeonhole_theorem(gds)}")

    witness = find_anti_gravity_witness(gds)
    if witness is not None:
        print(f"Anti-gravity witness: theorem {witness} "
              f"(weight={gds.direct_weight(witness)}, effort={gds.proof_effort[witness]})")
