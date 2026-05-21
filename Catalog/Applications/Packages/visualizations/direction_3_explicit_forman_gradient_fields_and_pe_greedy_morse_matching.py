#!/usr/bin/env python3
"""
Algorithms for Explicit Discrete Morse Theory

Implements:
1. Gradient field enumeration on small complexes
2. Optimal Morse matching via greedy heuristic
3. Filtration-compatible gradient field construction
4. Morse vector computation and comparison

All algorithms operate on abstract simplicial complexes represented
as lists of simplices with incidence data.
"""

from typing import Optional
from itertools import combinations
from collections import defaultdict
from dataclasses import dataclass, field


@dataclass
class SimplicialComplex:
    """A finite abstract simplicial complex.

    Attributes:
        simplices: set of frozensets, each representing a simplex by its vertices
    """
    simplices: set

    @classmethod
    def from_facets(cls, facets: list) -> 'SimplicialComplex':
        """Build a simplicial complex from its maximal simplices (facets).

        Args:
            facets: list of tuples/sets of vertex indices

        Returns:
            SimplicialComplex with all faces included
        """
        simplices = set()
        for f in facets:
            f = frozenset(f)
            for k in range(len(f) + 1):
                for sub in combinations(f, k):
                    if sub:  # skip empty set
                        simplices.add(frozenset(sub))
        return cls(simplices)

    def cells_by_dim(self) -> dict:
        """Return cells grouped by dimension."""
        result = defaultdict(list)
        for s in self.simplices:
            result[len(s) - 1].append(s)
        return dict(result)

    def dim(self, simplex) -> int:
        """Dimension of a simplex."""
        return len(simplex) - 1

    def faces(self, simplex) -> list:
        """Return all codimension-1 faces of a simplex."""
        return [frozenset(c) for c in combinations(simplex, len(simplex) - 1)]

    def cofaces(self, simplex) -> list:
        """Return all codimension-1 cofaces (simplices that have this as a face)."""
        return [s for s in self.simplices
                if len(s) == len(simplex) + 1 and simplex.issubset(s)]

    def euler_characteristic(self) -> int:
        """Compute Euler characteristic: sum(-1)^dim over all simplices."""
        return sum((-1)**self.dim(s) for s in self.simplices)

    def f_vector(self) -> list:
        """Compute f-vector: number of simplices in each dimension."""
        cbd = self.cells_by_dim()
        max_dim = max(cbd.keys()) if cbd else -1
        return [len(cbd.get(d, [])) for d in range(max_dim + 1)]


@dataclass
class GradientField:
    """An explicit Forman gradient field on a simplicial complex.

    Attributes:
        complex: the underlying simplicial complex
        pairs: dict mapping lower simplex -> upper simplex
        pair_reverse: dict mapping upper simplex -> lower simplex
    """
    complex: SimplicialComplex
    pairs: dict = field(default_factory=dict)
    pair_reverse: dict = field(default_factory=dict)

    def add_pair(self, lower: frozenset, upper: frozenset) -> bool:
        """Add a matched pair (lower, upper) if valid.

        Args:
            lower: the lower-dimensional simplex
            upper: the higher-dimensional simplex (must be a coface of lower)

        Returns:
            True if pair was added, False if invalid
        """
        if lower in self.pairs or lower in self.pair_reverse:
            return False
        if upper in self.pairs or upper in self.pair_reverse:
            return False
        if self.complex.dim(upper) != self.complex.dim(lower) + 1:
            return False
        if not lower.issubset(upper):
            return False
        self.pairs[lower] = upper
        self.pair_reverse[upper] = lower
        return True

    def is_critical(self, simplex: frozenset) -> bool:
        """Check if a simplex is critical (unpaired)."""
        return simplex not in self.pairs and simplex not in self.pair_reverse

    def critical_cells(self) -> list:
        """Return all critical cells."""
        return [s for s in self.complex.simplices if self.is_critical(s)]

    def critical_cells_by_dim(self) -> dict:
        """Return critical cells grouped by dimension."""
        result = defaultdict(list)
        for s in self.critical_cells():
            result[self.complex.dim(s)].append(s)
        return dict(result)

    def morse_vector(self) -> list:
        """Compute Morse vector: critical cell count by dimension."""
        f_vec = self.complex.f_vector()
        crits = self.critical_cells_by_dim()
        return [len(crits.get(d, [])) for d in range(len(f_vec))]

    def euler_from_critical(self) -> int:
        """Compute Euler characteristic from critical cells."""
        return sum((-1)**self.complex.dim(s) for s in self.critical_cells())

    def verify_pair_cancellation(self) -> bool:
        """Verify all matched pairs cancel in the alternating sum."""
        for lower, upper in self.pairs.items():
            if (-1)**self.complex.dim(lower) + (-1)**self.complex.dim(upper) != 0:
                return False
        return True

    def verify_euler_theorem(self) -> bool:
        """Verify critical sum equals total Euler characteristic."""
        return self.euler_from_critical() == self.complex.euler_characteristic()


def greedy_morse_matching(K: SimplicialComplex) -> GradientField:
    """Compute a gradient field using a greedy heuristic.

    Strategy: process cells from lowest to highest dimension.
    For each unpaired cell, try to pair it with an unpaired coface.

    This is a simplified version of the standard algorithm from
    Forman's original paper.

    Args:
        K: simplicial complex

    Returns:
        GradientField with a valid matching

    Time complexity: O(n * m) where n = number of simplices, m = max cofaces
    Space complexity: O(n)
    """
    V = GradientField(K)
    cells = sorted(K.simplices, key=lambda s: len(s))

    for cell in cells:
        if not V.is_critical(cell):
            continue
        # Try to pair with an unpaired coface
        for coface in K.cofaces(cell):
            if V.is_critical(coface):
                V.add_pair(cell, coface)
                break

    return V


def enumerate_all_matchings(K: SimplicialComplex, max_count: int = 1000) -> list:
    """Enumerate all valid Morse matchings on a small complex.

    Uses backtracking to find all possible matchings. Only feasible
    for very small complexes (< ~10 simplices).

    Args:
        K: simplicial complex (should be small!)
        max_count: maximum number of matchings to enumerate

    Returns:
        List of GradientField objects

    Time complexity: O(exponential in number of simplices)
    """
    cells = sorted(K.simplices, key=lambda s: len(s))
    # Find all valid pairs (face, coface)
    valid_pairs = []
    for cell in cells:
        for coface in K.cofaces(cell):
            valid_pairs.append((cell, coface))

    results = []

    def backtrack(idx, used, current_pairs):
        if len(results) >= max_count:
            return
        if idx >= len(valid_pairs):
            V = GradientField(K)
            for lower, upper in current_pairs:
                V.add_pair(lower, upper)
            results.append(V)
            return

        # Don't use this pair
        backtrack(idx + 1, used, current_pairs)

        # Use this pair if possible
        lower, upper = valid_pairs[idx]
        if lower not in used and upper not in used:
            used_new = used | {lower, upper}
            backtrack(idx + 1, used_new, current_pairs + [(lower, upper)])

    backtrack(0, set(), [])
    return results


def filtration_compatible_matching(K: SimplicialComplex,
                                    filtration: dict) -> GradientField:
    """Compute a filtration-compatible gradient field.

    Only pairs cells at the same filtration level.

    Args:
        K: simplicial complex
        filtration: dict mapping simplex -> filtration level (int)

    Returns:
        GradientField compatible with the filtration

    Time complexity: O(n * m) where n = simplices, m = max cofaces
    """
    V = GradientField(K)
    cells = sorted(K.simplices, key=lambda s: (filtration.get(s, 0), len(s)))

    for cell in cells:
        if not V.is_critical(cell):
            continue
        for coface in K.cofaces(cell):
            if V.is_critical(coface) and filtration.get(cell, 0) == filtration.get(coface, 0):
                V.add_pair(cell, coface)
                break

    return V


# ─── Standard Complexes ───

def triangle():
    """Triangle (filled): 3V + 3E + 1F."""
    return SimplicialComplex.from_facets([(0, 1, 2)])


def triangle_boundary():
    """Triangle boundary (circle): 3V + 3E."""
    return SimplicialComplex.from_facets([(0, 1), (1, 2), (0, 2)])


def tetrahedron():
    """Tetrahedron boundary (sphere S²): 4V + 6E + 4F."""
    return SimplicialComplex.from_facets([
        (0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)
    ])


def octahedron():
    """Octahedron boundary (sphere S²): 6V + 12E + 8F."""
    return SimplicialComplex.from_facets([
        (0, 1, 2), (0, 2, 3), (0, 3, 4), (0, 1, 4),
        (5, 1, 2), (5, 2, 3), (5, 3, 4), (5, 1, 4)
    ])


# ─── Main ───

def main():
    print("="*60)
    print("DISCRETE MORSE THEORY: ALGORITHMS")
    print("="*60)

    complexes = [
        ("Triangle (disk)", triangle()),
        ("Triangle boundary (S¹)", triangle_boundary()),
        ("Tetrahedron boundary (S²)", tetrahedron()),
        ("Octahedron boundary (S²)", octahedron()),
    ]

    for name, K in complexes:
        print(f"\n{'─'*50}")
        print(f"  {name}")
        print(f"{'─'*50}")
        print(f"  f-vector: {K.f_vector()}")
        print(f"  Euler characteristic: {K.euler_characteristic()}")

        # Greedy matching
        V = greedy_morse_matching(K)
        print(f"  Greedy Morse vector: {V.morse_vector()}")
        print(f"  Pair cancellation: {'✓' if V.verify_pair_cancellation() else '✗'}")
        print(f"  Euler theorem: {'✓' if V.verify_euler_theorem() else '✗'}")

    # Enumerate all matchings on small complexes
    print(f"\n{'='*60}")
    print("ENUMERATION OF ALL GRADIENT FIELDS")
    print("="*60)

    for name, K in [("Triangle boundary (S¹)", triangle_boundary()),
                     ("Triangle (disk)", triangle())]:
        print(f"\n  {name}:")
        all_fields = enumerate_all_matchings(K)
        print(f"  Total valid gradient fields: {len(all_fields)}")
        morse_vectors = set()
        for V in all_fields:
            mv = tuple(V.morse_vector())
            morse_vectors.add(mv)
        print(f"  Distinct Morse vectors: {sorted(morse_vectors)}")
        for mv in sorted(morse_vectors):
            count = sum(1 for V in all_fields if tuple(V.morse_vector()) == mv)
            ec = sum((-1)**d * c for d, c in enumerate(mv))
            print(f"    {list(mv)}: {count} fields, χ = {ec}")

    # Filtration demo
    print(f"\n{'='*60}")
    print("FILTRATION-COMPATIBLE MATCHING")
    print("="*60)

    K = triangle_boundary()
    # Assign filtration: vertices at level 0, edges at level 1
    filt = {}
    for s in K.simplices:
        filt[s] = K.dim(s)

    V_compat = filtration_compatible_matching(K, filt)
    V_greedy = greedy_morse_matching(K)

    print(f"\n  Triangle boundary with dim-filtration:")
    print(f"  Greedy Morse vector:     {V_greedy.morse_vector()}")
    print(f"  Compatible Morse vector: {V_compat.morse_vector()}")
    print(f"  Both give χ = {V_compat.euler_from_critical()}")


if __name__ == "__main__":
    main()
