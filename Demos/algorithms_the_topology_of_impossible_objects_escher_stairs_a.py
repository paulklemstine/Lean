#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of impossible figure algorithms.

Implements the core algorithms from the formal theory:
1. Monodromy computation
2. Realizability testing via monodromy
3. Height function construction (when realizable)
4. Obstruction degree classification
5. Orientation holonomy computation
6. Wedge sum realizability analysis
7. Rational approximation of impossible figures
"""

from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from fractions import Fraction
import math


@dataclass
class CycleWeights:
    """Weight function on edges of an n-cycle graph."""
    weights: List[float]

    @property
    def n(self) -> int:
        return len(self.weights)

    def monodromy(self) -> float:
        """Compute the monodromy (sum of weights around the cycle).

        Theorem: monodromy = 0 iff the figure is realizable.
        """
        return sum(self.weights)

    def is_realizable(self, tol: float = 1e-12) -> bool:
        """Test realizability: a figure is realizable iff monodromy = 0."""
        return abs(self.monodromy()) < tol

    def obstruction_degree(self) -> int:
        """Compute the obstruction degree ∈ {-1, 0, +1}.

        +1: ascending impossibility (Escher ascending)
        -1: descending impossibility (Escher descending)
         0: realizable (consistent height function exists)
        """
        m = self.monodromy()
        if m > 1e-12:
            return 1
        elif m < -1e-12:
            return -1
        return 0

    def rotate(self, k: int) -> 'CycleWeights':
        """Cyclically rotate the weights by k positions.

        Theorem: monodromy is invariant under rotation.
        """
        n = self.n
        if n == 0:
            return CycleWeights([])
        rotated = [self.weights[(i + k) % n] for i in range(n)]
        return CycleWeights(rotated)

    def construct_height(self) -> Optional[List[float]]:
        """Construct the height function h: Fin n → ℝ if realizable.

        Uses the constructive proof: h(i) = Σ_{j < i} w(j).
        Returns None if not realizable.
        """
        if not self.is_realizable():
            return None
        heights = [0.0]
        for i in range(self.n):
            heights.append(heights[-1] + self.weights[i])
        return heights[:-1]  # Return only h(0), ..., h(n-1)

    def scale(self, c: float) -> 'CycleWeights':
        """Scale weights by constant c.

        Theorem: monodromy(c·w) = c · monodromy(w).
        """
        return CycleWeights([c * w for w in self.weights])

    def negate(self) -> 'CycleWeights':
        """Negate all weights.

        Theorem: obstruction_degree(-w) = -obstruction_degree(w).
        """
        return CycleWeights([-w for w in self.weights])


@dataclass
class WedgeCocycle:
    """Two cycles sharing a vertex (wedge sum), with independent weights."""
    cycle1: CycleWeights
    cycle2: CycleWeights

    def monodromy_vector(self) -> Tuple[float, float]:
        """The monodromy vector in ℝ².

        Theorem: The wedge is realizable iff both components are zero.
        """
        return (self.cycle1.monodromy(), self.cycle2.monodromy())

    def is_realizable(self) -> bool:
        """A wedge cocycle is realizable iff both monodromies vanish."""
        m1, m2 = self.monodromy_vector()
        return abs(m1) < 1e-12 and abs(m2) < 1e-12


@dataclass
class OrientationCocycle:
    """Orientation signs (±1) on edges of an n-cycle."""
    signs: List[int]

    def __post_init__(self):
        assert all(s in (1, -1) for s in self.signs), "Signs must be ±1"

    def holonomy(self) -> int:
        """Compute orientation holonomy (product of signs).

        Theorem: holonomy ∈ {-1, +1}.
        """
        result = 1
        for s in self.signs:
            result *= s
        return result

    def is_orientable(self) -> bool:
        """Orientable iff holonomy = +1."""
        return self.holonomy() == 1

    def is_non_orientable(self) -> bool:
        """Non-orientable iff holonomy = -1.

        Theorem: non-orientable iff odd number of -1 signs.
        """
        return self.holonomy() == -1

    def reversal_count(self) -> int:
        """Count the number of orientation-reversing edges."""
        return sum(1 for s in self.signs if s == -1)

    def double_cover(self) -> 'OrientationCocycle':
        """Construct the orientation double cover (all signs +1).

        Theorem: The double cover is always orientable.
        """
        return OrientationCocycle([1] * (2 * len(self.signs)))


def penrose_polygon(k: int, delta: float = 1.0) -> CycleWeights:
    """Construct a Penrose k-gon with uniform weights.

    Theorem: monodromy = k·δ ≠ 0, so the figure is impossible for δ ≠ 0.
    """
    return CycleWeights([delta] * k)


def rational_approximation(
    weights: CycleWeights,
    epsilon: float
) -> Tuple[List[Fraction], float]:
    """Approximate an impossible figure with rational weights.

    Returns (rational_weights, monodromy_error).

    Theorem: For any ε > 0, there exists a rational weight function
    with monodromy within ε of the original.
    """
    rational_weights = []
    for w in weights.weights:
        # Find closest rational with denominator ≤ 1/epsilon
        frac = Fraction(w).limit_denominator(int(1 / epsilon) + 1)
        rational_weights.append(frac)

    original_mono = weights.monodromy()
    rational_mono = float(sum(rational_weights))
    error = abs(original_mono - rational_mono)

    return rational_weights, error


def classify_impossible_figures(
    n: int,
    samples: int = 1000
) -> Dict[int, int]:
    """Sample random weight functions and classify by obstruction degree.

    Returns count of {-1: descending, 0: realizable, +1: ascending}.
    """
    import random
    counts = {-1: 0, 0: 0, 1: 0}
    for _ in range(samples):
        weights = CycleWeights([random.gauss(0, 1) for _ in range(n)])
        deg = weights.obstruction_degree()
        counts[deg] += 1
    return counts


# ─── Algorithm: Monodromy Computation ───

def compute_monodromy(weights: List[float]) -> float:
    """
    Algorithm: Monodromy Computation

    Input: Weight function w: {0, ..., n-1} → ℝ
    Output: Monodromy m = Σᵢ w(i)

    Pseudocode:
      m ← 0
      for i ← 0 to n-1:
        m ← m + w(i)
      return m

    Complexity: O(n) time, O(1) space
    Correctness: By definition of monodromy as ∑ᵢ w(i)
    """
    return sum(weights)


def test_realizability(weights: List[float]) -> Tuple[bool, Optional[List[float]]]:
    """
    Algorithm: Realizability Test and Height Construction

    Input: Weight function w: {0, ..., n-1} → ℝ
    Output: (is_realizable, height_function_or_None)

    Pseudocode:
      m ← monodromy(w)
      if |m| > ε:
        return (False, None)
      h(0) ← 0
      for i ← 1 to n-1:
        h(i) ← h(i-1) + w(i-1)
      return (True, h)

    Complexity: O(n) time, O(n) space
    Correctness: By the monodromy classification theorem
    """
    cw = CycleWeights(weights)
    if not cw.is_realizable():
        return (False, None)
    heights = cw.construct_height()
    return (True, heights)


if __name__ == "__main__":
    # Quick self-test
    pt = penrose_polygon(3, 1.0)
    assert not pt.is_realizable()
    assert pt.monodromy() == 3.0
    assert pt.obstruction_degree() == 1

    realizable = CycleWeights([1.0, -1.0])
    assert realizable.is_realizable()
    assert realizable.construct_height() == [0.0, 1.0]

    mobius = OrientationCocycle([1, 1, -1])
    assert mobius.is_non_orientable()
    assert mobius.double_cover().is_orientable()

    print("All self-tests passed.")
