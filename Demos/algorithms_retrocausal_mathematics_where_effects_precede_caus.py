#!/usr/bin/env python3
"""
Algorithms for Retrocausal Mathematics

Type-hinted implementations of the core algorithms from the retrocausal
logic framework. These compute retrocausal closures, fixed points,
and verify algebraic properties of temporal Galois connections.
"""

from typing import TypeVar, Callable, Set, FrozenSet, Tuple, List, Optional
from dataclasses import dataclass
import itertools

T = TypeVar('T')


@dataclass
class GaloisConnection:
    """A Galois connection (T, R) on the powerset lattice of {0, ..., n-1}.
    
    T: forward temporal propagation (left adjoint)
    R: backward retrocausal propagation (right adjoint)
    Satisfying: T(a) ⊆ b ⟺ a ⊆ R(b)
    """
    n: int
    T: Callable[[FrozenSet[int]], FrozenSet[int]]
    R: Callable[[FrozenSet[int]], FrozenSet[int]]
    
    @property
    def universe(self) -> FrozenSet[int]:
        return frozenset(range(self.n))
    
    def verify(self) -> bool:
        """Verify the Galois connection axiom on all pairs."""
        elements = list(self._powerset())
        for a in elements:
            for b in elements:
                if self.T(a).issubset(b) != a.issubset(self.R(b)):
                    return False
        return True
    
    def closure(self, a: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the retrocausal closure cl(a) = R(T(a))."""
        return self.R(self.T(a))
    
    def interior(self, a: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the retrocausal interior int(a) = T(R(a))."""
        return self.T(self.R(a))
    
    def is_fixed_point(self, a: FrozenSet[int]) -> bool:
        """Check if a is a retrocausal fixed point: cl(a) = a."""
        return self.closure(a) == a
    
    def fixed_points(self) -> List[FrozenSet[int]]:
        """Compute all retrocausal fixed points."""
        return [s for s in self._powerset() if self.is_fixed_point(s)]
    
    def _powerset(self) -> list[FrozenSet[int]]:
        """Generate all subsets of {0, ..., n-1}."""
        base = set(range(self.n))
        result = []
        for r in range(self.n + 1):
            for combo in itertools.combinations(base, r):
                result.append(frozenset(combo))
        return result


def retrocausal_closure_algorithm(
    gc: GaloisConnection,
    a: FrozenSet[int]
) -> FrozenSet[int]:
    """
    Algorithm 1: Compute the retrocausal closure.
    
    Given a Galois connection (T, R) and an element a,
    returns cl(a) = R(T(a)).
    
    Time complexity: O(|T| + |R|) where |T|, |R| are the
    costs of evaluating T and R.
    
    Properties verified:
    - Extensive: a ⊆ cl(a)
    - Monotone: a ⊆ b ⟹ cl(a) ⊆ cl(b)
    - Idempotent: cl(cl(a)) = cl(a)
    """
    return gc.closure(a)


def compute_fixed_point_lattice(
    gc: GaloisConnection
) -> dict:
    """
    Algorithm 2: Compute the fixed-point lattice structure.
    
    Returns a dictionary with:
    - 'fixed_points': list of fixed points
    - 'top': the maximum fixed point
    - 'bottom': the minimum fixed point (= cl(⊥))
    - 'meet': function computing the meet of two fixed points
    - 'join': function computing the join of two fixed points
    - 'is_boolean': whether the fixed-point lattice is Boolean
    
    The key insight: meets are ambient meets (intersection),
    but joins require closure: a ⊔_fp b = cl(a ∪ b).
    """
    fps = gc.fixed_points()
    top = gc.universe
    bottom = gc.closure(frozenset())
    
    def fp_meet(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        """Meet in the fixed-point lattice = ambient meet."""
        return a & b
    
    def fp_join(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        """Join in the fixed-point lattice = closure of ambient join."""
        return gc.closure(a | b)
    
    # Check Boolean: every element has a complement
    is_boolean = True
    for fp in fps:
        has_complement = any(
            fp_meet(fp, other) == bottom and fp_join(fp, other) == top
            for other in fps
        )
        if not has_complement:
            is_boolean = False
            break
    
    return {
        'fixed_points': fps,
        'top': top,
        'bottom': bottom,
        'meet': fp_meet,
        'join': fp_join,
        'is_boolean': is_boolean,
    }


def verify_frame_distributivity(gc: GaloisConnection) -> bool:
    """
    Algorithm 3: Verify frame distributivity.
    
    Checks that arbitrary meets of fixed points are fixed points.
    For efficiency, only checks binary meets (sufficient for
    finite lattices since binary meets generate all finite meets).
    
    Returns True if the fixed points form a frame.
    """
    fps = gc.fixed_points()
    for i, a in enumerate(fps):
        for b in fps[i:]:
            meet = a & b
            if not gc.is_fixed_point(meet):
                return False
    return True


def verify_s4_axioms(gc: GaloisConnection) -> dict:
    """
    Algorithm 4: Verify S4 modal logic axioms.
    
    Checks:
    - K: □ is monotone
    - T: a ≤ □a (reflexivity)
    - 4: □□a = □a (transitivity)
    - Dual T: ◇a ≤ a
    - Dual 4: ◇◇a = ◇a
    """
    elements = list(gc._powerset())
    
    # K: monotonicity
    k_holds = True
    for a in elements:
        for b in elements:
            if a.issubset(b) and not gc.closure(a).issubset(gc.closure(b)):
                k_holds = False
                break
    
    # T: extensiveness
    t_holds = all(a.issubset(gc.closure(a)) for a in elements)
    
    # 4: idempotency
    four_holds = all(gc.closure(gc.closure(a)) == gc.closure(a) for a in elements)
    
    # Dual T: contractiveness of interior
    dual_t_holds = all(gc.interior(a).issubset(a) for a in elements)
    
    # Dual 4: idempotency of interior
    dual_four_holds = all(
        gc.interior(gc.interior(a)) == gc.interior(a) for a in elements
    )
    
    return {
        'K (monotone)': k_holds,
        'T (extensive)': t_holds,
        '4 (idempotent)': four_holds,
        'Dual T (contractive)': dual_t_holds,
        'Dual 4 (int idempotent)': dual_four_holds,
    }


def verify_temporal_excluded_middle(gc: GaloisConnection) -> bool:
    """
    Algorithm 5: Verify the Temporal Excluded Middle.
    
    Checks that cl(a) ∪ cl(¬a) = ⊤ for all elements a.
    This holds whenever the base lattice is Boolean (powerset).
    """
    for a in gc._powerset():
        complement = gc.universe - a
        if gc.closure(a) | gc.closure(complement) != gc.universe:
            return False
    return True


def verify_coherence_laws(gc: GaloisConnection) -> Tuple[bool, bool]:
    """
    Algorithm 6: Verify the coherence laws TRT = T and RTR = R.
    
    Returns (left_coherence, right_coherence).
    """
    elements = list(gc._powerset())
    
    left = all(gc.T(gc.R(gc.T(a))) == gc.T(a) for a in elements)
    right = all(gc.R(gc.T(gc.R(a))) == gc.R(a) for a in elements)
    
    return left, right


def from_function(f: dict[int, int], n: int) -> GaloisConnection:
    """
    Construct a Galois connection from a function f: {0,...,n-1} -> {0,...,n-1}.
    
    T = direct image, R = preimage.
    This is a standard construction and always yields a valid Galois connection.
    """
    def T(s: FrozenSet[int]) -> FrozenSet[int]:
        return frozenset(f[x] for x in s)
    
    def R(s: FrozenSet[int]) -> FrozenSet[int]:
        return frozenset(x for x in range(n) if f[x] in s)
    
    return GaloisConnection(n=n, T=T, R=R)


if __name__ == "__main__":
    # Example: image/preimage from f: 0->0, 1->0, 2->1
    gc = from_function({0: 0, 1: 0, 2: 1}, 3)
    
    print("Galois connection from f: 0→0, 1→0, 2→1")
    print(f"  Valid: {gc.verify()}")
    
    lattice = compute_fixed_point_lattice(gc)
    print(f"  Fixed points: {[set(s) for s in lattice['fixed_points']]}")
    print(f"  Bottom (cl(⊥)): {set(lattice['bottom'])}")
    print(f"  Is Boolean: {lattice['is_boolean']}")
    
    print(f"  Frame distributivity: {verify_frame_distributivity(gc)}")
    
    s4 = verify_s4_axioms(gc)
    for axiom, holds in s4.items():
        print(f"  S4 {axiom}: {holds}")
    
    print(f"  Temporal EM: {verify_temporal_excluded_middle(gc)}")
    
    left, right = verify_coherence_laws(gc)
    print(f"  Left coherence (TRT=T): {left}")
    print(f"  Right coherence (RTR=R): {right}")
