#!/usr/bin/env python3
"""
Algorithms for Self-Referential Type Theory

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import TypeVar, Callable, Generic, Optional
from dataclasses import dataclass
import math

T = TypeVar('T')


@dataclass
class ReflectionSystem(Generic[T]):
    """A reflection system: a monotone inflationary operator on a complete lattice."""
    phi: Callable[[T], T]
    bottom: T
    le: Callable[[T, T], bool]  # partial order

    def reflection_hierarchy(self, n: int) -> list[T]:
        """Compute levels 0..n of the reflection hierarchy.

        Algorithm:
            level[0] = ⊥
            level[k+1] = Φ(level[k])

        Returns the full hierarchy as a list.
        """
        levels = [self.bottom]
        for _ in range(n):
            levels.append(self.phi(levels[-1]))
        return levels

    def approximate_lfp(self, max_iter: int = 1000, tol: float = 1e-12) -> tuple[T, int]:
        """Approximate the least fixed point by iterating Φ from ⊥.

        Returns (approximate_lfp, number_of_iterations).
        Stops when |Φ(x) - x| < tol (for numeric types).
        """
        x = self.bottom
        for i in range(max_iter):
            y = self.phi(x)
            try:
                if abs(y - x) < tol:  # type: ignore
                    return y, i + 1
            except TypeError:
                if y == x:
                    return y, i + 1
            x = y
        return x, max_iter

    def is_fixed_point(self, x: T, tol: float = 1e-12) -> bool:
        """Check if x is a fixed point of Φ."""
        y = self.phi(x)
        try:
            return abs(y - x) < tol  # type: ignore
        except TypeError:
            return y == x

    def is_godelian(self, lfp: T, gfp: T) -> bool:
        """Check if the system is Gödelian (lfp < gfp)."""
        return self.le(lfp, gfp) and lfp != gfp


@dataclass
class TypeUniverse(Generic[T]):
    """A type universe with coding function."""
    extension: Callable[[T], set[T]]
    universe: set[T]

    def diagonal(self) -> set[T]:
        """Compute the diagonal set: {a | a ∉ extension(a)}.

        Algorithm: iterate over universe, test self-membership.

        This set is provably not representable by any code (Theorem 6).
        """
        return {a for a in self.universe if a not in self.extension(a)}

    def codiagonal(self) -> set[T]:
        """Compute the codiagonal set: {a | a ∈ extension(a)}.

        The complement of the diagonal in the universe.
        """
        return {a for a in self.universe if a in self.extension(a)}

    def verify_partition(self) -> bool:
        """Verify the self-membership partition theorem (Theorem 17).

        Returns True iff diagonal ∪ codiagonal = universe and
        diagonal ∩ codiagonal = ∅.
        """
        d = self.diagonal()
        cd = self.codiagonal()
        return d | cd == self.universe and len(d & cd) == 0

    def is_representable(self, S: set[T]) -> Optional[T]:
        """Check if a set S is representable; return the code if so."""
        for a in self.universe:
            if self.extension(a) == S:
                return a
        return None


@dataclass
class InvariantStructure(Generic[T]):
    """An invariant structure: a collection of subsets closed under intersection."""
    carrier: list[frozenset[T]]
    universe: frozenset[T]

    def closure(self, S: frozenset[T]) -> frozenset[T]:
        """Compute the closure of S: intersection of all carrier members ⊇ S.

        Algorithm:
            cl(S) = ⋂{T ∈ carrier | S ⊆ T}

        Time complexity: O(|carrier| × |universe|)
        """
        containing = [C for C in self.carrier if S <= C]
        if not containing:
            return self.universe
        result = containing[0]
        for C in containing[1:]:
            result = result & C
        return result

    def is_closed(self, S: frozenset[T]) -> bool:
        """Check if S is a fixed point of the closure (S ∈ carrier)."""
        return self.closure(S) == S

    def verify_fixedpoint_characterization(self) -> bool:
        """Verify Theorem 16: {S | cl(S) = S} = carrier.

        Enumerates all subsets (exponential in |universe|).
        """
        # Generate all subsets
        elems = list(self.universe)
        n = len(elems)
        fixed_points = set()
        for mask in range(2**n):
            S = frozenset(elems[i] for i in range(n) if (mask >> i) & 1)
            if self.is_closed(S):
                fixed_points.add(S)
        return fixed_points == set(self.carrier)


def hierarchy_convergence_rate(phi: Callable[[float], float],
                               fixed_point: float,
                               levels: int = 50) -> list[float]:
    """Measure convergence rate of the reflection hierarchy to the fixed point.

    Returns list of |level(n) - lfp| for n = 0, ..., levels.
    """
    errors = []
    x = 0.0
    for _ in range(levels + 1):
        errors.append(abs(x - fixed_point))
        x = phi(x)
    return errors


# Example usage
if __name__ == "__main__":
    # Example 1: Golden ratio as lfp
    R = ReflectionSystem(
        phi=lambda x: math.sqrt(x + 1),
        bottom=0.0,
        le=lambda a, b: a <= b
    )

    lfp, iters = R.approximate_lfp()
    golden = (1 + math.sqrt(5)) / 2
    print(f"LFP of sqrt(x+1): {lfp:.10f} (golden ratio: {golden:.10f})")
    print(f"Converged in {iters} iterations")

    # Example 2: Diagonal
    ext_map = {0: {1, 2}, 1: {0, 1}, 2: {2}, 3: {0, 3}, 4: {1, 4}}
    U = TypeUniverse(
        extension=lambda a: ext_map.get(a, set()),
        universe={0, 1, 2, 3, 4}
    )
    print(f"\nDiagonal: {sorted(U.diagonal())}")
    print(f"Partition valid: {U.verify_partition()}")

    # Example 3: Invariant structure
    IS = InvariantStructure(
        carrier=[frozenset(), frozenset({0}), frozenset({0,1}), frozenset({0,1,2})],
        universe=frozenset({0, 1, 2})
    )
    print(f"\nClosure of {{1}}: {set(IS.closure(frozenset({1})))}")
    print(f"Fixed point characterization valid: {IS.verify_fixedpoint_characterization()}")
