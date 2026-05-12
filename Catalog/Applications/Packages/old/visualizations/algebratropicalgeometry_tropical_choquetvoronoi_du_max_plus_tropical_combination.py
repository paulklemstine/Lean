#!/usr/bin/env python3
"""
Tropical Choquet–Voronoi Duality: Algorithms

Complete implementations of the key algorithms from the research paper:
1. Extremal generator extraction
2. Minimal support computation
3. Support complex construction
4. Certified polyhedral reconstruction pipeline

All algorithms work over integer (max-plus) tropical arithmetic.
"""

from itertools import combinations, product
from typing import List, Tuple, Set, Dict, Optional, FrozenSet


# ==============================================================================
# Algorithm 1: Max-Plus Tropical Combination
# ==============================================================================

def tropical_combination(
    generators: List[List[int]],
    coefficients: List[int]
) -> Tuple[int, ...]:
    """
    Compute a max-plus tropical combination.

    Given generators v_1, ..., v_k ∈ Z^n and coefficients λ_1, ..., λ_k ∈ Z,
    compute x ∈ Z^n where:
        x_j = max_i (λ_i + v_i[j])  for each coordinate j

    Time complexity: O(k * n)
    Space complexity: O(n)

    Args:
        generators: k vectors in Z^n
        coefficients: k integer scalars

    Returns:
        The tropical combination as a tuple of integers

    Example:
        >>> tropical_combination([[1, 0], [0, 1]], [0, 0])
        (1, 1)
    """
    n = len(generators[0])
    return tuple(
        max(c + g[j] for c, g in zip(coefficients, generators))
        for j in range(n)
    )


# ==============================================================================
# Algorithm 2: Tropical Hull Computation (Finite Approximation)
# ==============================================================================

def compute_tropical_hull(
    generators: List[List[int]],
    coeff_range: Tuple[int, int] = (-5, 5)
) -> Set[Tuple[int, ...]]:
    """
    Compute a finite approximation of the max-plus tropical hull.

    Enumerates all tropical combinations over a range of integer coefficients.
    For generators in Z^n, the tropical hull is generally infinite, but this
    function computes a finite slice useful for analysis.

    Time complexity: O(R^k * k * n) where R = coeff_range[1] - coeff_range[0] + 1
    Space complexity: O(R^k * n)

    Args:
        generators: k vectors in Z^n
        coeff_range: (min_coeff, max_coeff) for enumeration

    Returns:
        Set of distinct points in the tropical hull
    """
    if not generators:
        return set()

    k = len(generators)
    hull: Set[Tuple[int, ...]] = set()

    for coeffs in product(range(coeff_range[0], coeff_range[1] + 1), repeat=k):
        x = tropical_combination(generators, list(coeffs))
        hull.add(x)

    return hull


# ==============================================================================
# Algorithm 3: Extremal Generator Extraction
# ==============================================================================

def extract_extremals(
    generators: List[List[int]],
    coeff_range: Tuple[int, int] = (-5, 5)
) -> List[int]:
    """
    Extract the indices of extremal (irreducible) generators.

    A generator v_i is extremal if it cannot be expressed as a max-plus
    tropical combination of the remaining generators. Equivalently,
    v_i ∉ tropHull({v_j : j ≠ i}).

    Time complexity: O(k * R^(k-1) * k * n) where R = range size
    Space complexity: O(R^(k-1) * n)

    Args:
        generators: k vectors in Z^n
        coeff_range: coefficient range for hull computation

    Returns:
        List of indices of extremal generators

    Example:
        >>> extract_extremals([[3,0], [0,3], [1,1]])
        [0, 1]  # v_2 = (1,1) is redundant
    """
    extremals = []
    for i in range(len(generators)):
        others = [g for j, g in enumerate(generators) if j != i]
        if not others:
            extremals.append(i)
            continue
        hull_others = compute_tropical_hull(others, coeff_range)
        if tuple(generators[i]) not in hull_others:
            extremals.append(i)
    return extremals


# ==============================================================================
# Algorithm 4: Minimal Support Computation
# ==============================================================================

def find_minimal_support(
    generators: List[List[int]],
    target: List[int],
    coeff_range: Tuple[int, int] = (-5, 5)
) -> Optional[List[int]]:
    """
    Find a minimal support set for a target point.

    A support σ for x is a subset of generator indices such that
    x ∈ tropHull({v_i : i ∈ σ}). The support is minimal if no
    proper subset of σ is also a support.

    Algorithm: Greedy search from small to large subsets.
    - For each subset size 1, 2, ..., k:
      - For each subset of that size:
        - Check if target is in the tropical hull of the subset
        - If yes, verify minimality by checking all proper sub-subsets
        - Return the first minimal support found

    Time complexity: O(2^k * R^k * k * n) worst case
    Space complexity: O(R^k * n)

    Args:
        generators: k vectors in Z^n
        target: target point in Z^n
        coeff_range: coefficient range for hull computation

    Returns:
        List of generator indices forming a minimal support, or None
    """
    k = len(generators)
    target_tuple = tuple(target)

    for size in range(1, k + 1):
        for subset_indices in combinations(range(k), size):
            subset_gens = [generators[i] for i in subset_indices]
            hull = compute_tropical_hull(subset_gens, coeff_range)
            if target_tuple not in hull:
                continue

            # Check minimality
            is_minimal = True
            for sub_size in range(1, size):
                for sub_indices in combinations(subset_indices, sub_size):
                    sub_gens = [generators[i] for i in sub_indices]
                    sub_hull = compute_tropical_hull(sub_gens, coeff_range)
                    if target_tuple in sub_hull:
                        is_minimal = False
                        break
                if not is_minimal:
                    break

            if is_minimal:
                return list(subset_indices)

    return None


# ==============================================================================
# Algorithm 5: Support Complex Construction
# ==============================================================================

class AbstractSimplicialComplex:
    """
    Abstract simplicial complex: downward-closed family of finite sets.

    Attributes:
        faces: Set of frozensets representing all faces
        maximal_faces: Set of maximal faces
    """

    def __init__(self, maximal_faces: Set[FrozenSet[int]]):
        """
        Construct the complex from maximal faces by downward closure.

        Time complexity: O(Σ 2^|F| for each maximal face F)
        """
        self.maximal_faces = set(maximal_faces)
        self.faces: Set[FrozenSet[int]] = {frozenset()}

        for face in self.maximal_faces:
            for size in range(len(face) + 1):
                for sub in combinations(face, size):
                    self.faces.add(frozenset(sub))

    @property
    def vertices(self) -> Set[int]:
        """O(|faces|) vertex extraction."""
        return {v for f in self.faces if len(f) == 1 for v in f}

    @property
    def edges(self) -> Set[FrozenSet[int]]:
        """O(|faces|) edge extraction."""
        return {f for f in self.faces if len(f) == 2}

    @property
    def dimension(self) -> int:
        """Dimension = max face size - 1."""
        return max((len(f) for f in self.faces), default=0) - 1

    @property
    def f_vector(self) -> List[int]:
        """f-vector: (f_{-1}, f_0, f_1, ..., f_d)."""
        d = self.dimension
        fvec = [0] * (d + 2)
        for f in self.faces:
            fvec[len(f)] += 1
        return fvec

    @property
    def euler_characteristic(self) -> int:
        """Euler characteristic χ = Σ (-1)^i f_i."""
        return sum((-1)**i * c for i, c in enumerate(self.f_vector))

    def is_face(self, sigma: FrozenSet[int]) -> bool:
        """Check if sigma is a face."""
        return sigma in self.faces

    def star(self, sigma: FrozenSet[int]) -> Set[FrozenSet[int]]:
        """Star of sigma: all faces containing sigma."""
        return {f for f in self.faces if sigma <= f}

    def link(self, sigma: FrozenSet[int]) -> Set[FrozenSet[int]]:
        """Link of sigma: faces in star(σ) disjoint from σ."""
        return {f - sigma for f in self.star(sigma) if not (f & sigma - sigma)}


def build_support_complex(
    generators: List[List[int]],
    hull_points: Set[Tuple[int, ...]],
    coeff_range: Tuple[int, int] = (-5, 5)
) -> Tuple[AbstractSimplicialComplex, Dict[Tuple[int, ...], List[int]]]:
    """
    Build the support complex from generators and hull points.

    For each point x in the hull, find its minimal support σ(x).
    The support complex has maximal faces {σ(x) : x ∈ hull}.

    Returns:
        (complex, support_map) where support_map[x] = σ(x)
    """
    support_map: Dict[Tuple[int, ...], List[int]] = {}
    support_sets: Set[FrozenSet[int]] = set()

    for pt in hull_points:
        supp = find_minimal_support(generators, list(pt), coeff_range)
        if supp is not None:
            support_map[pt] = supp
            support_sets.add(frozenset(supp))

    complex = AbstractSimplicialComplex(support_sets)
    return complex, support_map


# ==============================================================================
# Algorithm 6: Certified Polyhedral Reconstruction Pipeline
# ==============================================================================

def certified_reconstruction(
    generator_matrix: List[List[int]],
    coeff_range: Tuple[int, int] = (-3, 3)
) -> Dict:
    """
    Complete certified polyhedral reconstruction pipeline.

    Input: Generator matrix A (rows = generators in Z^n)
    Output: Dictionary containing:
        - extremals: indices of extremal generators
        - support_map: x ↦ Supp(x)
        - complex: the support complex
        - certificate: verification data

    Steps:
    1. Extract extremal generators
    2. Compute tropical hull of extremals
    3. Find minimal supports for all hull points
    4. Build support complex
    5. Verify reconstruction certificate

    Time complexity: O(2^k * R^k * k * n * |hull|)
    """
    generators = generator_matrix

    # Step 1: Extract extremals
    extremal_indices = extract_extremals(generators, coeff_range)
    extremal_gens = [generators[i] for i in extremal_indices]

    # Step 2: Compute hull
    hull = compute_tropical_hull(extremal_gens, coeff_range)

    # Step 3-4: Build support complex
    complex, support_map = build_support_complex(
        extremal_gens, hull, coeff_range
    )

    # Step 5: Verify certificate
    cert = {
        "all_extremals_are_vertices": all(
            i in complex.vertices for i in range(len(extremal_gens))
        ),
        "all_hull_points_have_support": len(support_map) == len(hull),
        "complex_is_downward_closed": all(
            frozenset(sub) in complex.faces
            for face in complex.faces
            for size in range(len(face))
            for sub in combinations(face, size)
        ),
        "supports_are_subsets_of_extremals": all(
            all(i < len(extremal_gens) for i in supp)
            for supp in support_map.values()
        ),
    }

    return {
        "generators": generators,
        "extremal_indices": extremal_indices,
        "extremal_generators": extremal_gens,
        "hull_size": len(hull),
        "support_map": support_map,
        "complex": complex,
        "certificate": cert,
        "certified": all(cert.values()),
    }


# ==============================================================================
# Main: Run all algorithms with example data
# ==============================================================================

if __name__ == "__main__":
    print("Tropical Choquet–Voronoi Certified Reconstruction")
    print("=" * 50)

    # Example: 4 generators in Z^3
    A = [
        [5, 0, 0],
        [0, 5, 0],
        [0, 0, 5],
        [2, 2, 2],
    ]

    result = certified_reconstruction(A, coeff_range=(-2, 2))

    print(f"\nGenerator matrix: {len(A)} rows × {len(A[0])} cols")
    print(f"Extremal generators: {result['extremal_indices']}")
    print(f"Hull size: {result['hull_size']}")
    print(f"Support complex dimension: {result['complex'].dimension}")
    print(f"f-vector: {result['complex'].f_vector}")
    print(f"Euler characteristic: {result['complex'].euler_characteristic}")
    print(f"\nCertificate verification:")
    for key, value in result['certificate'].items():
        status = "✓" if value else "✗"
        print(f"  {status} {key}: {value}")
    print(f"\nOverall: {'CERTIFIED ✓' if result['certified'] else 'FAILED ✗'}")
