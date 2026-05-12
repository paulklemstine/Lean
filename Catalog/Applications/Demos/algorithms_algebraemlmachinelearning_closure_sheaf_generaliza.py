#!/usr/bin/env python3
"""
Algorithms for Closure-Sheaf Generalization

Implements the core computational algorithms from the research paper:
1. Tropical extension functional computation
2. Greedy cover refinement for active learning
3. Closure nerve construction
4. Generalization bound certification
"""

from typing import Callable, Dict, FrozenSet, List, Set, Tuple, Optional
import numpy as np
from dataclasses import dataclass


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class ClosureSpace:
    """A finite closure space on {0, ..., n-1}."""
    n: int
    cl: Callable[[FrozenSet[int]], FrozenSet[int]]

    def is_closed(self, s: FrozenSet[int]) -> bool:
        return self.cl(s) == s

    def closure(self, s: FrozenSet[int]) -> FrozenSet[int]:
        return self.cl(s)


@dataclass
class LocalSection:
    """A local section (predictor) on a patch."""
    domain: FrozenSet[int]
    values: Dict[int, float]


@dataclass
class Cover:
    """A finite cover of a space."""
    patches: List[FrozenSet[int]]

    @property
    def num_patches(self) -> int:
        return len(self.patches)

    def overlap(self, i: int, j: int) -> FrozenSet[int]:
        return self.patches[i] & self.patches[j]

    def nerve_depth(self) -> int:
        """Maximum number of patches containing any single point."""
        if not self.patches:
            return 0
        all_points = set()
        for p in self.patches:
            all_points |= p
        max_depth = 0
        for x in all_points:
            depth = sum(1 for p in self.patches if x in p)
            max_depth = max(max_depth, depth)
        return max_depth


# =============================================================================
# Algorithm 1: Tropical Extension Functional
# =============================================================================

def compute_defect(s1: Dict[int, float], s2: Dict[int, float],
                   domain: FrozenSet[int]) -> float:
    """
    Compute the max-absolute-difference defect between two sections on a domain.

    Time complexity: O(|domain|)
    Space complexity: O(1)

    Args:
        s1, s2: Sections as dictionaries mapping points to values.
        domain: The domain on which to compare.

    Returns:
        max_{x in domain} |s1(x) - s2(x)|, or 0 if domain is empty.
    """
    if not domain:
        return 0.0
    return max(
        (abs(s1.get(x, 0.0) - s2.get(x, 0.0)) for x in domain),
        default=0.0
    )


def compute_tropical_extension_functional(
    cover: Cover,
    local_sections: List[LocalSection],
    global_section: Dict[int, float]
) -> float:
    """
    Compute E(g) = max_i defect(res(g, U_i), s_i).

    This is the tropical (sup-based) extension functional from Theorem 2.

    Time complexity: O(k * max|U_i|) where k = number of patches
    Space complexity: O(max|U_i|)

    Args:
        cover: The cover {U_1, ..., U_k}.
        local_sections: Local sections s_i on each U_i.
        global_section: A global section g on the universe.

    Returns:
        The tropical extension functional value E(g).
    """
    result = 0.0
    for i, (patch, local) in enumerate(zip(cover.patches, local_sections)):
        # Restrict global section to patch
        restricted = {x: global_section.get(x, 0.0) for x in patch}
        d = compute_defect(restricted, local.values, patch)
        result = max(result, d)
    return result


# =============================================================================
# Algorithm 2: Overlap Defect Matrix
# =============================================================================

def compute_overlap_defect_matrix(
    cover: Cover,
    local_sections: List[LocalSection]
) -> np.ndarray:
    """
    Compute the matrix of pairwise overlap defects.

    overlapDefect[i,j] = defect(res(s_i, U_i∩U_j), res(s_j, U_i∩U_j))

    Time complexity: O(k^2 * max|U_i|)
    Space complexity: O(k^2)

    Args:
        cover: The cover.
        local_sections: Local sections.

    Returns:
        k × k matrix of overlap defects.
    """
    k = cover.num_patches
    defects = np.zeros((k, k))
    for i in range(k):
        for j in range(i + 1, k):
            overlap = cover.overlap(i, j)
            if overlap:
                d = compute_defect(
                    local_sections[i].values,
                    local_sections[j].values,
                    overlap
                )
                defects[i, j] = d
                defects[j, i] = d
    return defects


# =============================================================================
# Algorithm 3: Certified Generalization Bound
# =============================================================================

def compute_certified_bound(
    empirical_err: float,
    overlap_defects: np.ndarray,
    nerve_depth: int,
    nerve_depth_weight: float = 0.01
) -> Tuple[float, Dict[str, float]]:
    """
    Compute the certified generalization bound from Theorem 3.

    generalizationErr ≤ empiricalErr ⊔ (nerveDepth ⊔ max_overlapDefect)

    Time complexity: O(k^2)
    Space complexity: O(1)

    Args:
        empirical_err: Empirical training error.
        overlap_defects: k × k matrix of overlap defects.
        nerve_depth: Maximum overlap multiplicity.
        nerve_depth_weight: Weight for nerve depth contribution.

    Returns:
        Tuple of (bound_value, decomposition_dict).
    """
    max_overlap = float(overlap_defects.max()) if overlap_defects.size > 0 else 0.0
    nerve_contrib = nerve_depth * nerve_depth_weight
    extension_norm = max(nerve_contrib, max_overlap)
    bound = max(empirical_err, extension_norm)

    decomposition = {
        "empirical_error": empirical_err,
        "max_overlap_defect": max_overlap,
        "nerve_depth": nerve_depth,
        "nerve_depth_contribution": nerve_contrib,
        "extension_norm": extension_norm,
        "certified_bound": bound,
    }
    return bound, decomposition


# =============================================================================
# Algorithm 4: Gluing (Section Assembly)
# =============================================================================

def glue_sections(
    cover: Cover,
    local_sections: List[LocalSection]
) -> Optional[Dict[int, float]]:
    """
    Attempt to glue compatible local sections into a global section.

    First checks pairwise compatibility, then assembles the global section
    by taking values from local sections (which must agree on overlaps).

    Time complexity: O(k^2 * max|U_i| + k * max|U_i|)
    Space complexity: O(n) where n = |⋃ U_i|

    Args:
        cover: The cover.
        local_sections: Local sections.

    Returns:
        The global section if compatible, None otherwise.
    """
    k = cover.num_patches

    # Check pairwise compatibility
    for i in range(k):
        for j in range(i + 1, k):
            overlap = cover.overlap(i, j)
            if overlap:
                d = compute_defect(
                    local_sections[i].values,
                    local_sections[j].values,
                    overlap
                )
                if d > 1e-12:
                    return None  # Incompatible

    # Assemble global section
    global_section: Dict[int, float] = {}
    for local in local_sections:
        for x, v in local.values.items():
            if x in global_section:
                # Should agree (verified above)
                assert abs(global_section[x] - v) < 1e-10
            else:
                global_section[x] = v

    return global_section


# =============================================================================
# Algorithm 5: Greedy Cover Refinement for Active Learning
# =============================================================================

def greedy_cover_refinement(
    cover: Cover,
    local_sections: List[LocalSection],
    true_function: Callable[[int], float],
    budget: int = 10
) -> Tuple[Cover, List[LocalSection], List[float]]:
    """
    Active learning by greedy cover refinement.

    At each step, find the pair (i,j) with maximum overlap defect,
    query the true function at the point of maximum disagreement,
    and update the local sections to reduce the defect.

    Time complexity: O(B * k^2 * max|U_i|) per refinement step
    Space complexity: O(k^2 + n)

    Args:
        cover: Initial cover.
        local_sections: Initial local sections.
        true_function: Oracle providing true values at query points.
        budget: Number of queries allowed.

    Returns:
        Tuple of (refined_cover, refined_sections, history_of_max_defects).
    """
    history = []
    current_cover = Cover(list(cover.patches))
    current_sections = list(local_sections)

    for step in range(budget):
        defect_matrix = compute_overlap_defect_matrix(current_cover, current_sections)
        max_defect = float(defect_matrix.max())
        history.append(max_defect)

        if max_defect < 1e-12:
            break  # Perfect compatibility achieved

        # Find worst overlap
        idx = np.unravel_index(np.argmax(defect_matrix), defect_matrix.shape)
        i, j = int(idx[0]), int(idx[1])
        overlap = current_cover.overlap(i, j)

        if not overlap:
            break

        # Find point of maximum disagreement in the overlap
        worst_point = max(
            overlap,
            key=lambda x: abs(
                current_sections[i].values.get(x, 0.0) -
                current_sections[j].values.get(x, 0.0)
            )
        )

        # Query true value
        true_val = true_function(worst_point)

        # Update local sections with true value
        current_sections[i].values[worst_point] = true_val
        current_sections[j].values[worst_point] = true_val

    # Final defect
    defect_matrix = compute_overlap_defect_matrix(current_cover, current_sections)
    history.append(float(defect_matrix.max()))

    return current_cover, current_sections, history


# =============================================================================
# Algorithm 6: Closure Nerve Construction
# =============================================================================

def compute_nerve(cover: Cover) -> List[Tuple[int, ...]]:
    """
    Compute the nerve of a cover: the simplicial complex whose simplices
    are subsets J of indices such that ⋂_{j∈J} U_j ≠ ∅.

    Time complexity: O(2^k * k * max|U_i|) worst case
    Space complexity: O(2^k) for storing simplices

    Args:
        cover: The cover.

    Returns:
        List of simplices (as tuples of indices), ordered by dimension.
    """
    k = cover.num_patches
    simplices = []

    # Generate all non-empty subsets of {0, ..., k-1}
    for mask in range(1, 1 << k):
        indices = tuple(i for i in range(k) if mask & (1 << i))
        # Compute intersection
        intersection = cover.patches[indices[0]]
        for idx in indices[1:]:
            intersection = intersection & cover.patches[idx]
        if intersection:  # Non-empty intersection
            simplices.append(indices)

    # Sort by dimension (number of vertices)
    simplices.sort(key=len)
    return simplices


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    print("Closure-Sheaf Generalization: Algorithm Demonstrations")
    print("=" * 60)

    # Setup
    n = 8
    cover = Cover([
        frozenset({0, 1, 2, 3}),
        frozenset({2, 3, 4, 5}),
        frozenset({4, 5, 6, 7}),
    ])

    # Compatible local sections (quadratic)
    sections = [
        LocalSection(cover.patches[0], {x: float(x**2) for x in cover.patches[0]}),
        LocalSection(cover.patches[1], {x: float(x**2) for x in cover.patches[1]}),
        LocalSection(cover.patches[2], {x: float(x**2) for x in cover.patches[2]}),
    ]

    # Algorithm 1: Tropical functional
    global_sec = {x: float(x**2) for x in range(n)}
    E = compute_tropical_extension_functional(cover, sections, global_sec)
    print(f"\n1. Tropical extension functional E(g) = {E} (should be 0)")

    # Algorithm 2: Overlap defects
    defects = compute_overlap_defect_matrix(cover, sections)
    print(f"\n2. Overlap defect matrix:\n{defects}")

    # Algorithm 3: Certified bound
    bound, decomp = compute_certified_bound(0.05, defects, cover.nerve_depth())
    print(f"\n3. Certified bound: {bound:.4f}")
    for k, v in decomp.items():
        print(f"   {k}: {v}")

    # Algorithm 4: Gluing
    glued = glue_sections(cover, sections)
    print(f"\n4. Glued section: {glued}")

    # Algorithm 5: Active learning with incompatible sections
    bad_sections = [
        LocalSection(cover.patches[0], {x: float(x**2) for x in cover.patches[0]}),
        LocalSection(cover.patches[1], {x: float(x**2 + 0.5) for x in cover.patches[1]}),
        LocalSection(cover.patches[2], {x: float(x**2) for x in cover.patches[2]}),
    ]
    _, _, history = greedy_cover_refinement(
        cover, bad_sections, lambda x: float(x**2), budget=5
    )
    print(f"\n5. Active learning defect history: {[f'{h:.4f}' for h in history]}")

    # Algorithm 6: Nerve
    nerve = compute_nerve(cover)
    print(f"\n6. Nerve simplices: {nerve}")
    print(f"   Nerve depth: {cover.nerve_depth()}")

    print("\nAll algorithms completed successfully!")
