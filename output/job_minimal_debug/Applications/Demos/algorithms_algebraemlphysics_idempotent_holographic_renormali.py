"""
Algorithms for Idempotent Holographic Renormalization.

Implements the core algorithms from the formal framework:
- RG flow computation (closure-RG iteration to canonical fixed points)
- Boundary profile computation
- Certified fixed-point reconstruction from boundary data

All algorithms operate on finite posets with closure operators and
monotone scale endomorphisms.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import (
    Callable, Dict, FrozenSet, Generic, Hashable, List, Optional,
    Set, Tuple, TypeVar,
)

T = TypeVar("T", bound=Hashable)
A = TypeVar("A", bound=Hashable)


@dataclass
class IdemHoloRGData(Generic[T, A]):
    """An idempotent holographic RG system.

    Parameters
    ----------
    elements : set of T
        The finite carrier set C.
    cl : Callable[[T], T]
        Closure operator (extensive, monotone, idempotent).
    R : Callable[[T], T]
        Monotone scale (RG) endomorphism.
    boundary : list of Callable[[T], A]
        Finite family of boundary observables.
    le : Callable[[T, T], bool]
        Preorder on C (optional, for verification).
    """

    elements: Set[T]
    cl: Callable[[T], T]
    R: Callable[[T], T]
    boundary: List[Callable[[T], A]]
    le: Callable[[T, T], bool] = field(default=lambda x, y: True)

    def rg_step(self, x: T) -> T:
        """One RG step: apply R then close."""
        return self.cl(self.R(x))

    def rg_iterate(self, x: T, n: int) -> T:
        """Apply rgStep n times."""
        y = x
        for _ in range(n):
            y = self.rg_step(y)
        return y

    def is_closed(self, x: T) -> bool:
        """Check if x is a fixed point of the closure operator."""
        return self.cl(x) == x

    def is_rg_fixed(self, x: T) -> bool:
        """Check if x is a fixed point of rgStep."""
        return self.rg_step(x) == x

    def compute_canonical_fixed(self, x: T, max_iter: int = 1000) -> Tuple[T, int]:
        """Compute the canonical fixed point of x by iterating rgStep.

        Returns (fixed_point, stabilization_index).

        Complexity: O(|C|) iterations worst case.
        """
        y = x
        seen: Dict[T, int] = {x: 0}
        for i in range(1, max_iter + 1):
            y = self.rg_step(y)
            if y in seen:
                # Found stabilization: y = rgStep^i(x) = rgStep^{seen[y]}(x)
                # If y == previous iterate, we have a genuine fixed point
                return y, i
            seen[y] = i
        raise RuntimeError(f"Did not stabilize in {max_iter} iterations")

    def boundary_profile(self, x: T) -> Tuple[A, ...]:
        """Compute the boundary profile of x: tuple of observable values."""
        return tuple(b(x) for b in self.boundary)

    def boundary_flow_signature(
        self, x: T, max_depth: int = 20
    ) -> List[Tuple[A, ...]]:
        """Compute the boundary flow signature up to a given depth.

        Returns a list of profiles at each RG scale.
        """
        sig = []
        y = x
        for _ in range(max_depth):
            sig.append(self.boundary_profile(y))
            y = self.rg_step(y)
        return sig

    def find_all_fixed_points(self) -> List[T]:
        """Find all closed RG-fixed points by exhaustive search."""
        return [x for x in self.elements if self.is_closed(x) and self.is_rg_fixed(x)]

    def reconstruct_fixed_point(
        self, profile: Tuple[A, ...]
    ) -> Optional[T]:
        """Reconstruct the unique closed RG-fixed point with a given profile.

        This is Algorithm 3 from the paper: search all elements for a
        closed RG-fixed point matching the boundary profile.

        Returns None if no match is found (profile not realizable).
        """
        for x in self.elements:
            if self.is_closed(x) and self.is_rg_fixed(x):
                if self.boundary_profile(x) == profile:
                    return x
        return None

    def verify_separation(self) -> bool:
        """Verify the boundary separation hypothesis:
        distinct closed RG-fixed points have distinct boundary profiles."""
        fps = self.find_all_fixed_points()
        profiles = [self.boundary_profile(fp) for fp in fps]
        return len(profiles) == len(set(profiles))

    def verify_stabilization(self, max_iter: int = 1000) -> bool:
        """Verify that all elements stabilize under rgStep."""
        for x in self.elements:
            try:
                fp, _ = self.compute_canonical_fixed(x, max_iter)
                if not self.is_rg_fixed(fp):
                    return False
            except RuntimeError:
                return False
        return True

    def verify_closure_axioms(self) -> Dict[str, bool]:
        """Verify the closure operator axioms on all elements."""
        results = {}

        # Extensivity: x ≤ cl(x)
        results["extensive"] = all(
            self.le(x, self.cl(x)) for x in self.elements
        )

        # Idempotency: cl(cl(x)) = cl(x)
        results["idempotent"] = all(
            self.cl(self.cl(x)) == self.cl(x) for x in self.elements
        )

        # R compatibility: cl(R(x)) = cl(R(cl(x)))
        results["R_compatible"] = all(
            self.cl(self.R(x)) == self.cl(self.R(self.cl(x)))
            for x in self.elements
        )

        return results

    def compute_rg_classes(self) -> Dict[T, T]:
        """Compute the canonical fixed-point class of every element.

        Returns a dict mapping each element to its canonical fixed point.
        """
        classes: Dict[T, T] = {}
        for x in self.elements:
            fp, _ = self.compute_canonical_fixed(x)
            classes[x] = fp
        return classes

    def boundary_equivalence_classes(self) -> Dict[Tuple, List[T]]:
        """Group elements by their eventual boundary profile
        (the profile of their canonical fixed point)."""
        classes: Dict[Tuple, List[T]] = {}
        for x in self.elements:
            fp, _ = self.compute_canonical_fixed(x)
            profile = self.boundary_profile(fp)
            classes.setdefault(profile, []).append(x)
        return classes


def build_lattice_example() -> IdemHoloRGData[int, int]:
    """Build a concrete example: a 12-element distributive lattice.

    The lattice is the divisor lattice of 12 = {1, 2, 3, 4, 6, 12}
    extended with a few extra elements.
    """
    # Use divisors of 60 as a richer example
    import math

    elements = {d for d in range(1, 61) if 60 % d == 0}
    # elements = {1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60}

    def cl(x: int) -> int:
        """Closure: round up to next multiple of 2 in the divisor lattice."""
        # Take lcm with 2 (capped at 60)
        v = math.lcm(x, 2)
        return v if v in elements else 60

    def R(x: int) -> int:
        """Scale map: multiply by 3 mod the lattice."""
        v = math.lcm(x, 3)
        return v if v in elements else 60

    def le(x: int, y: int) -> bool:
        return y % x == 0

    boundary = [
        lambda x: x % 4,   # observe mod 4
        lambda x: x % 5,   # observe mod 5
        lambda x: 1 if x >= 10 else 0,  # size threshold
    ]

    return IdemHoloRGData(
        elements=elements,
        cl=cl,
        R=R,
        boundary=boundary,
        le=le,
    )


def build_tropical_graph_example() -> IdemHoloRGData[Tuple[float, ...], float]:
    """Build a tropical shortest-path example.

    6 vertices, max-plus semiring distances.
    """
    INF = float("-inf")
    n = 4

    # Adjacency matrix (max-plus: edge weights, -inf for no edge)
    W = [
        [0, 3, INF, INF],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [4, INF, INF, 0],
    ]

    def max_plus_vec(v: Tuple[float, ...]) -> Tuple[float, ...]:
        """One step of max-plus matrix-vector multiply (Bellman–Ford)."""
        result = []
        for i in range(n):
            val = max(W[i][j] + v[j] for j in range(n))
            result.append(val)
        return tuple(result)

    # Closure: take componentwise max with 0 (extensive)
    def cl(v: Tuple[float, ...]) -> Tuple[float, ...]:
        return tuple(max(vi, 0) for vi in v)

    def R(v: Tuple[float, ...]) -> Tuple[float, ...]:
        return max_plus_vec(v)

    def le(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> bool:
        return all(a <= b for a, b in zip(v1, v2))

    # Generate a finite subset of states by iterating from basis vectors
    states: Set[Tuple[float, ...]] = set()
    for i in range(n):
        basis = tuple(0 if j == i else INF for j in range(n))
        x = basis
        for _ in range(n * 3):
            x = cl(R(x))
            states.add(x)
        states.add(basis)

    # Also add cl of each basis
    for i in range(n):
        basis = tuple(0 if j == i else INF for j in range(n))
        states.add(cl(basis))

    # Boundary observables: project to specific coordinates
    boundary = [
        lambda v: v[0],  # distance to vertex 0
        lambda v: v[1],  # distance to vertex 1
    ]

    return IdemHoloRGData(
        elements=states,
        cl=cl,
        R=R,
        boundary=boundary,
        le=le,
    )


if __name__ == "__main__":
    print("=" * 60)
    print("Idempotent Holographic Renormalization — Algorithms Demo")
    print("=" * 60)

    # Example 1: Lattice
    print("\n--- Lattice Example (divisors of 60) ---")
    D = build_lattice_example()
    print(f"Elements: {sorted(D.elements)}")
    print(f"Closure axioms: {D.verify_closure_axioms()}")

    fps = D.find_all_fixed_points()
    print(f"Closed RG-fixed points: {sorted(fps)}")
    print(f"Separation holds: {D.verify_separation()}")
    print(f"Stabilization holds: {D.verify_stabilization()}")

    classes = D.compute_rg_classes()
    print(f"\nRG classes (element → canonical fixed point):")
    for x in sorted(D.elements):
        print(f"  {x:3d} → {classes[x]:3d}  (profile: {D.boundary_profile(classes[x])})")

    # Reconstruction demo
    print(f"\nReconstruction demo:")
    for fp in sorted(fps):
        profile = D.boundary_profile(fp)
        reconstructed = D.reconstruct_fixed_point(profile)
        status = "✓" if reconstructed == fp else "✗"
        print(f"  profile {profile} → reconstructed {reconstructed} {status}")

    # Example 2: Tropical graph
    print("\n--- Tropical Graph Example ---")
    D2 = build_tropical_graph_example()
    print(f"Number of states: {len(D2.elements)}")

    fps2 = D2.find_all_fixed_points()
    print(f"Closed RG-fixed points: {len(fps2)}")
    for fp in fps2:
        print(f"  {fp} → profile {D2.boundary_profile(fp)}")
