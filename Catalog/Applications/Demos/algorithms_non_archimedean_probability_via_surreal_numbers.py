#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Finitely Additive Probability

Implements the core algorithms from the research paper:
1. Construction of grid uniform probabilities
2. Computation of non-Archimedean-style expectations
3. Refinement coherence checking
4. Infinitesimal scheme construction and verification
"""

from fractions import Fraction
from typing import Callable, Dict, FrozenSet, List, Optional, Tuple
import math


class NAProbability:
    """A finitely additive probability on a finite set with values in ℚ.

    This implements the NAProbability structure from the Lean formalization:
    - mass : Finset α → K (here subsets of {0,...,n} → Fraction)
    - empty_mass : mass(∅) = 0
    - add_mass : mass(S ∪ T) = mass(S) + mass(T) for disjoint S, T
    - total_mass : mass(universe) = 1
    - nonneg_mass : mass(S) ≥ 0

    Time complexity: O(|S|) per mass query, O(n) for expectation.
    Space complexity: O(n) for storing the universe.
    """

    def __init__(self, n: int, point_masses: Dict[int, Fraction]):
        """Initialize with universe {0, ..., n} and point masses.

        Args:
            n: Universe is {0, ..., n}
            point_masses: Maps each point to its mass. Must sum to 1.

        Raises:
            ValueError: If masses don't satisfy axioms.
        """
        self.n = n
        self.universe = set(range(n + 1))
        self.point_masses = dict(point_masses)

        # Verify axioms
        total = sum(self.point_masses.values())
        if total != Fraction(1):
            raise ValueError(f"Total mass is {total}, not 1")
        for k, v in self.point_masses.items():
            if v < 0:
                raise ValueError(f"Negative mass {v} at point {k}")
            if k < 0 or k > n:
                raise ValueError(f"Point {k} not in universe {{0,...,{n}}}")

    def mass(self, subset: set) -> Fraction:
        """Compute the mass of a subset.

        By finite additivity, mass(S) = Σ_{i ∈ S} mass({i}).

        Time: O(|subset|)
        """
        return sum(self.point_masses.get(i, Fraction(0)) for i in subset)

    def expectation(self, X: Callable[[int], Fraction]) -> Fraction:
        """Compute E[X] = Σ_i X(i) * mass({i}).

        Time: O(n)
        """
        return sum(X(i) * self.point_masses[i] for i in self.universe)

    def verify_axioms(self) -> bool:
        """Verify all NAProbability axioms hold.

        Time: O(n)
        """
        # empty_mass
        if self.mass(set()) != Fraction(0):
            return False
        # total_mass
        if self.mass(self.universe) != Fraction(1):
            return False
        # nonneg_mass (only check singletons; extends by additivity)
        for i in self.universe:
            if self.point_masses[i] < 0:
                return False
        return True


def grid_uniform_prob(n: int) -> NAProbability:
    """Construct the uniform probability on {0, ..., n}.

    Each singleton has mass 1/(n+1). This is the gridUniformProb
    from the Lean formalization.

    Time: O(n)  Space: O(n)

    Args:
        n: Grid parameter. Universe is {0, ..., n} with n+1 points.

    Returns:
        NAProbability with uniform masses.
    """
    N = n + 1
    mass = Fraction(1, N)
    return NAProbability(n, {i: mass for i in range(N)})


def na_expectation(P: NAProbability, X: Callable[[int], Fraction]) -> Fraction:
    """Compute expectation of X under probability P.

    E[X] = Σ_{a ∈ α} X(a) · P.mass({a})

    This matches NAExpectation from the Lean formalization.

    Time: O(n) where n = |universe|
    """
    return P.expectation(X)


def refine_observable(
    n: int, k: int, X: Callable[[int], Fraction]
) -> Callable[[int], Fraction]:
    """Lift observable from Fin(n+1) to Fin(k*(n+1)) by block embedding.

    Point j in the fine grid maps to coarse point j // k.
    This matches refineObservable from the Lean formalization.

    Time: O(1) per evaluation
    """
    def refined(j: int) -> Fraction:
        return X(j // k)
    return refined


def check_refinement_invariance(
    n: int, k: int, X: Callable[[int], Fraction]
) -> Tuple[bool, Fraction, Fraction]:
    """Check that refinement preserves expectation.

    Verifies: E_coarse[X] = E_fine[refine(X)]

    This is the computational test for Theorem 3 (refinement_expectation_invariant).

    Time: O(k * n)

    Returns:
        (invariant, coarse_expectation, fine_expectation)
    """
    coarse_P = grid_uniform_prob(n)
    coarse_E = na_expectation(coarse_P, X)

    fine_n = k * (n + 1) - 1
    fine_P = grid_uniform_prob(fine_n)
    refined_X = refine_observable(n, k, X)
    fine_E = na_expectation(fine_P, refined_X)

    return (coarse_E == fine_E, coarse_E, fine_E)


class InfinitesimalScheme:
    """A sequence of grid probabilities whose point masses tend to zero.

    This implements the InfinitesimalScheme structure from the Lean formalization.
    Each level n gives a probability on Fin(n+1) with point mass 1/(n+1).

    The scheme is the formal precursor to hyperfinite counting measure
    and surreal-valued probability.
    """

    def __init__(self, max_level: int = 100):
        """Initialize the scheme up to a given refinement level.

        Args:
            max_level: Maximum grid level to precompute.
        """
        self.max_level = max_level
        self._probs: Dict[int, NAProbability] = {}

    def probability(self, n: int) -> NAProbability:
        """Get the probability at level n.

        Time: O(n) on first call, O(1) thereafter.
        """
        if n not in self._probs:
            self._probs[n] = grid_uniform_prob(n)
        return self._probs[n]

    def point_mass(self, n: int) -> Fraction:
        """Point mass at level n: 1/(n+1).

        Time: O(1)
        """
        return Fraction(1, n + 1)

    def verify_tends_to_zero(self, levels: Optional[List[int]] = None) -> List[Tuple[int, float]]:
        """Verify that point masses tend to zero.

        Returns list of (level, point_mass) pairs showing convergence.
        """
        if levels is None:
            levels = [2**k - 1 for k in range(1, 20)]
        return [(n, float(self.point_mass(n))) for n in levels]

    def expectation_at_level(
        self, n: int, X_family: Callable[[int, int], Fraction]
    ) -> Fraction:
        """Compute expectation at level n for a family of observables.

        X_family(n, i) gives the observable value at level n, point i.

        Time: O(n)
        """
        P = self.probability(n)
        return na_expectation(P, lambda i: X_family(n, i))


def archimedean_obstruction(epsilon: float) -> Tuple[int, float]:
    """Find N such that N*ε > 1, demonstrating the impossibility theorem.

    For any ε > 0, the Archimedean property guarantees such N exists.

    Time: O(1)

    Args:
        epsilon: The putative equal positive mass.

    Returns:
        (N, N*epsilon) where N*epsilon > 1.
    """
    N = math.ceil(1 / epsilon) + 1
    return (N, N * epsilon)


# =============================================================================
# Example usage
# =============================================================================
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Grid uniform probability
    P = grid_uniform_prob(4)
    print(f"Grid Fin(5): axioms valid = {P.verify_axioms()}")
    print(f"  Singleton mass = {P.point_masses[0]}")
    print(f"  Mass of {{0,1,2}} = {P.mass({0,1,2})}")
    print()

    # 2. Affine expectation
    a, b = Fraction(2), Fraction(1)
    X = lambda i: a * Fraction(i, 4) + b
    E = na_expectation(P, X)
    print(f"E[2x+1] on Fin(5) = {E} (expected {a/2 + b})")
    print()

    # 3. Refinement invariance
    X_square = lambda i: Fraction(i * i)
    ok, coarse, fine = check_refinement_invariance(4, 3, X_square)
    print(f"Refinement (n=4, k=3, X=i²): invariant={ok}")
    print(f"  Coarse E = {coarse}, Fine E = {fine}")
    print()

    # 4. Infinitesimal scheme
    scheme = InfinitesimalScheme()
    convergence = scheme.verify_tends_to_zero([0, 9, 99, 999, 9999])
    print("Infinitesimal scheme point masses:")
    for n, m in convergence:
        print(f"  Level {n:>5}: mass = {m:.8f}")
    print()

    # 5. Archimedean obstruction
    N, mass = archimedean_obstruction(0.001)
    print(f"Archimedean obstruction: ε=0.001 → N={N}, N*ε={mass:.3f} > 1")
