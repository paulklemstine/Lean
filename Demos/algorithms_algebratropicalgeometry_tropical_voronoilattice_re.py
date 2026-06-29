#!/usr/bin/env python3
"""
Algorithms for Tropical Voronoi Decoder Duality

Implements the core algorithms from the research paper:
1. Decoder cell computation
2. Essential subfamily extraction
3. Partition realization
4. Certified reconstruction
5. Tropical span membership test
"""

import numpy as np
from typing import List, Dict, Set, Tuple, Optional, FrozenSet
from dataclasses import dataclass


@dataclass
class DecoderComplex:
    """A tropical Voronoi decoder complex."""
    profiles: np.ndarray
    cells: Dict[int, Set[int]]
    cell_complex: Set[FrozenSet[int]]
    is_essential: bool
    is_separated: bool
    has_disjoint_cells: bool


class TropicalDecoderAlgebra:
    """
    Implements tropical (min-plus) decoder algebra on finite types.

    The tropical semiring operations are:
    - Addition (⊕): pointwise minimum
    - Scalar multiplication (⊗): constant shift
    """

    @staticmethod
    def tropical_add(f: np.ndarray, g: np.ndarray) -> np.ndarray:
        """Tropical addition: pointwise minimum."""
        return np.minimum(f, g)

    @staticmethod
    def tropical_smul(c: int, f: np.ndarray) -> np.ndarray:
        """Tropical scalar multiplication: shift by constant c."""
        return c + f

    @staticmethod
    def compute_decoder_cell(f: np.ndarray, family: np.ndarray) -> Set[int]:
        """
        Compute the decoder cell of profile f relative to family.

        cell(f, G) = {x | f(x) <= g(x) for all g in G}

        Complexity: O(|G| * |X|)
        """
        n_points = len(f)
        cell = set()
        for x in range(n_points):
            if all(f[x] <= family[j, x] for j in range(len(family))):
                cell.add(x)
        return cell

    @staticmethod
    def compute_all_cells(profiles: np.ndarray) -> Dict[int, Set[int]]:
        """
        Compute all decoder cells for a profile family.

        Complexity: O(|G|^2 * |X|)
        """
        n_profiles = len(profiles)
        cells = {}
        for i in range(n_profiles):
            cells[i] = TropicalDecoderAlgebra.compute_decoder_cell(
                profiles[i], profiles
            )
        return cells

    @staticmethod
    def compute_cell_complex(profiles: np.ndarray) -> Set[FrozenSet[int]]:
        """
        Compute the cell complex: set of all nonempty decoder cells.

        Complexity: O(|G|^2 * |X|)
        """
        cells = TropicalDecoderAlgebra.compute_all_cells(profiles)
        return {frozenset(cell) for cell in cells.values() if cell}

    @staticmethod
    def check_essential(profiles: np.ndarray) -> bool:
        """
        Check if a profile family is essential.

        A family is essential if every profile has a nonempty decoder cell.

        Complexity: O(|G|^2 * |X|)
        """
        cells = TropicalDecoderAlgebra.compute_all_cells(profiles)
        return all(len(cell) > 0 for cell in cells.values())

    @staticmethod
    def check_separated(profiles: np.ndarray) -> bool:
        """
        Check if distinct profiles have distinct decoder cells.

        Complexity: O(|G|^2 * |X|)
        """
        cells = TropicalDecoderAlgebra.compute_all_cells(profiles)
        cell_sets = [frozenset(c) for c in cells.values()]
        return len(cell_sets) == len(set(cell_sets))

    @staticmethod
    def check_disjoint(profiles: np.ndarray) -> bool:
        """
        Check if decoder cells are pairwise disjoint.

        Complexity: O(|G|^2 * |X|)
        """
        cells = TropicalDecoderAlgebra.compute_all_cells(profiles)
        n = len(cells)
        for i in range(n):
            for j in range(i + 1, n):
                if cells[i] & cells[j]:
                    return False
        return True

    @staticmethod
    def extract_essential(profiles: np.ndarray) -> Tuple[np.ndarray, List[int]]:
        """
        Extract the essential subfamily.

        Returns profiles with nonempty cells and their indices.

        Complexity: O(|G|^2 * |X|)
        """
        cells = TropicalDecoderAlgebra.compute_all_cells(profiles)
        essential_idx = [i for i, cell in cells.items() if cell]
        return profiles[essential_idx], essential_idx

    @staticmethod
    def realize_partition(
        parts: List[Set[int]], n_points: int
    ) -> np.ndarray:
        """
        Realize a partition as decoder cells using indicator profiles.

        f_i(x) = 0 if x in parts[i], else 1

        This construction matches the formal proof of realization_from_partition.

        Complexity: O(|parts| * |X|)
        """
        n_parts = len(parts)
        profiles = np.ones((n_parts, n_points), dtype=int)
        for i, part in enumerate(parts):
            for x in part:
                profiles[i, x] = 0
        return profiles

    @staticmethod
    def certified_generator_count(
        cell_complex: Set[FrozenSet[int]]
    ) -> int:
        """
        Certified reconstruction: the minimum generator count
        equals the cell complex size.

        By the minimality theorem (minimal_generators_eq_essential_cells),
        |G| = |V(G)| for any essential family with disjoint cells.

        Complexity: O(1) given cell complex
        """
        return len(cell_complex)

    @staticmethod
    def build_decoder_complex(profiles: np.ndarray) -> DecoderComplex:
        """
        Build a complete decoder complex with all certified properties.

        Complexity: O(|G|^2 * |X|)
        """
        alg = TropicalDecoderAlgebra
        cells = alg.compute_all_cells(profiles)
        cc = {frozenset(c) for c in cells.values() if c}

        return DecoderComplex(
            profiles=profiles,
            cells=cells,
            cell_complex=cc,
            is_essential=all(len(c) > 0 for c in cells.values()),
            is_separated=len([frozenset(c) for c in cells.values()]) ==
                         len(set(frozenset(c) for c in cells.values())),
            has_disjoint_cells=alg.check_disjoint(profiles),
        )

    @staticmethod
    def in_tropical_span(
        h: np.ndarray, family: np.ndarray
    ) -> bool:
        """
        Check if profile h is in the tropical span of family.

        h is in trop_span(G) if for each x, there exist g in G and c in N
        such that h(x) = c + g(x).

        Complexity: O(|G| * |X|)
        """
        n_points = len(h)
        for x in range(n_points):
            found = False
            for j in range(len(family)):
                if h[x] >= family[j, x]:
                    # c = h(x) - family[j, x] >= 0
                    found = True
                    break
            if not found:
                return False
        return True

    @staticmethod
    def tropical_equiv(f: np.ndarray, g: np.ndarray) -> Optional[int]:
        """
        Check if two profiles are tropically equivalent (differ by constant).

        Returns the shift constant c if g = f + c, else None.

        Complexity: O(|X|)
        """
        if len(f) == 0:
            return 0
        c = int(g[0]) - int(f[0])
        if all(int(g[x]) - int(f[x]) == c for x in range(len(f))):
            return c
        return None


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    alg = TropicalDecoderAlgebra()

    # Three-site example from the paper
    profiles = np.array([
        [0, 1, 2, 3, 4, 5],
        [5, 4, 3, 2, 1, 0],
        [3, 2, 1, 1, 2, 3],
    ])

    dc = alg.build_decoder_complex(profiles)

    print("Three-Site Decoder Complex")
    print(f"  Essential: {dc.is_essential}")
    print(f"  Separated: {dc.is_separated}")
    print(f"  Disjoint cells: {dc.has_disjoint_cells}")
    print(f"  Cell complex: {[sorted(c) for c in dc.cell_complex]}")
    print(f"  Certified generator count: "
          f"{alg.certified_generator_count(dc.cell_complex)}")

    # Realization from partition
    partition = [{0, 1}, {2, 3}, {4, 5}]
    realized = alg.realize_partition(partition, 6)
    dc2 = alg.build_decoder_complex(realized)

    print(f"\nRealized partition {[sorted(p) for p in partition]}:")
    print(f"  Essential: {dc2.is_essential}")
    print(f"  Cells: {[sorted(c) for c in dc2.cell_complex]}")

    # Tropical equivalence
    f1 = np.array([1, 2, 3, 4, 5])
    f2 = np.array([4, 5, 6, 7, 8])
    f3 = np.array([1, 2, 4, 4, 5])

    c12 = alg.tropical_equiv(f1, f2)
    c13 = alg.tropical_equiv(f1, f3)
    print(f"\nTropical equivalence:")
    print(f"  [1,2,3,4,5] ~ [4,5,6,7,8]? shift = {c12}")
    print(f"  [1,2,3,4,5] ~ [1,2,4,4,5]? shift = {c13}")
