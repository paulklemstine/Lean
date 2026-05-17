#!/usr/bin/env python3
"""
Algorithms for Hexagonal Lattice Isoperimetry
==============================================

Implements the core algorithms from the quantitative honeycomb rigidity
research: hex lattice operations, compression operators, rigidity
certification, and isoperimetric profile computation.
"""

from typing import Set, Tuple, List, Dict, Optional
from collections import defaultdict
import heapq

HexCell = Tuple[int, int]

# Six hex directions in axial coordinates
HEX_DIRECTIONS: List[HexCell] = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]

# Three principal compression directions
COMPRESSION_DIRECTIONS: List[HexCell] = [(1, 0), (0, 1), (1, -1)]


class HexLattice:
    """Core hexagonal lattice operations."""

    @staticmethod
    def hex_dist(a: HexCell, b: HexCell) -> int:
        """Compute hex metric distance: max(|dq|, |dr|, |dq+dr|).

        Args:
            a: First hex cell (q, r)
            b: Second hex cell (q, r)

        Returns:
            Non-negative integer distance

        Examples:
            >>> HexLattice.hex_dist((0,0), (1,0))
            1
            >>> HexLattice.hex_dist((0,0), (2,1))
            3
        """
        dq = b[0] - a[0]
        dr = b[1] - a[1]
        return max(abs(dq), abs(dr), abs(dq + dr))

    @staticmethod
    def neighbors(p: HexCell) -> List[HexCell]:
        """Return the 6 neighbors of a hex cell.

        Args:
            p: A hex cell (q, r)

        Returns:
            List of 6 neighboring cells
        """
        return [(p[0] + d[0], p[1] + d[1]) for d in HEX_DIRECTIONS]

    @staticmethod
    def hex_patch(r: int) -> Set[HexCell]:
        """Generate the hexagonal patch of radius r centered at origin.

        The hex patch contains all cells within hex distance r of (0,0).
        Its cardinality is 3r² + 3r + 1 (centered hexagonal number).
        Its edge boundary is 12r + 6 (optimal).

        Args:
            r: Non-negative integer radius

        Returns:
            Set of hex cells forming the patch

        Examples:
            >>> len(HexLattice.hex_patch(0))
            1
            >>> len(HexLattice.hex_patch(1))
            7
            >>> len(HexLattice.hex_patch(2))
            19
        """
        cells = set()
        for q in range(-r, r + 1):
            for s in range(-r, r + 1):
                if HexLattice.hex_dist((0, 0), (q, s)) <= r:
                    cells.add((q, s))
        return cells

    @staticmethod
    def hex_number(r: int) -> int:
        """Centered hexagonal number: 3r² + 3r + 1."""
        return 3 * r * r + 3 * r + 1

    @staticmethod
    def opt_boundary(r: int) -> int:
        """Optimal boundary for hex-number cardinality: 12r + 6."""
        return 12 * r + 6


class BoundaryAnalysis:
    """Edge boundary computation and analysis."""

    @staticmethod
    def edge_boundary(S: Set[HexCell]) -> int:
        """Count directed edges from S to its complement.

        Time complexity: O(|S|)

        Args:
            S: Finite set of hex cells

        Returns:
            Number of boundary edges
        """
        count = 0
        for p in S:
            for n in HexLattice.neighbors(p):
                if n not in S:
                    count += 1
        return count

    @staticmethod
    def internal_edges(S: Set[HexCell]) -> int:
        """Count directed edges with both endpoints in S.

        Time complexity: O(|S|)
        """
        count = 0
        for p in S:
            for n in HexLattice.neighbors(p):
                if n in S:
                    count += 1
        return count

    @staticmethod
    def directional_boundary(S: Set[HexCell], d: HexCell) -> int:
        """Count boundary edges in direction d.

        Args:
            S: Finite set of hex cells
            d: Direction vector (one of the 6 hex directions)

        Returns:
            Number of cells p in S such that p+d is not in S
        """
        return sum(1 for p in S if (p[0] + d[0], p[1] + d[1]) not in S)

    @staticmethod
    def boundary_decomposition(S: Set[HexCell]) -> Dict[HexCell, int]:
        """Decompose edge boundary by direction.

        Returns dict mapping each direction to its boundary contribution.
        """
        return {d: BoundaryAnalysis.directional_boundary(S, d) for d in HEX_DIRECTIONS}


class FiberAnalysis:
    """Horizontal fiber structure and gap counting."""

    @staticmethod
    def get_fibers(S: Set[HexCell]) -> Dict[int, List[int]]:
        """Group cells by second coordinate into horizontal fibers.

        Returns dict mapping y-coordinate to sorted list of x-coordinates.
        """
        fibers: Dict[int, List[int]] = defaultdict(list)
        for q, r in S:
            fibers[r].append(q)
        for key in fibers:
            fibers[key].sort()
        return dict(fibers)

    @staticmethod
    def fiber_gaps(fiber: List[int]) -> int:
        """Count gaps in a sorted fiber (missing positions between min and max).

        A fiber [1, 3, 4] has 1 gap (position 2).
        A fiber [1, 2, 3] has 0 gaps.

        Args:
            fiber: Sorted list of integers

        Returns:
            Number of missing positions
        """
        if len(fiber) <= 1:
            return 0
        return (fiber[-1] - fiber[0] + 1) - len(fiber)

    @staticmethod
    def total_fiber_gaps(S: Set[HexCell]) -> int:
        """Total number of horizontal fiber gaps in S."""
        fibers = FiberAnalysis.get_fibers(S)
        return sum(FiberAnalysis.fiber_gaps(f) for f in fibers.values())

    @staticmethod
    def is_horizontally_convex(S: Set[HexCell]) -> bool:
        """Check if every horizontal fiber is an interval (no gaps)."""
        return FiberAnalysis.total_fiber_gaps(S) == 0


class CompressionOperator:
    """Directional compression operators for hex lattice sets."""

    @staticmethod
    def horizontal_compress(S: Set[HexCell]) -> Set[HexCell]:
        """Compress S horizontally: replace each fiber with a left-aligned interval.

        This preserves cardinality and does not increase edge boundary.

        Time complexity: O(|S| log |S|)

        Args:
            S: Finite set of hex cells

        Returns:
            Compressed set with convex horizontal fibers
        """
        fibers = FiberAnalysis.get_fibers(S)
        result = set()
        for y, qs in fibers.items():
            lo = min(qs)
            for i in range(len(qs)):
                result.add((lo + i, y))
        return result

    @staticmethod
    def center_compress(S: Set[HexCell]) -> Set[HexCell]:
        """Compress S so that each fiber is centered around its mean.

        This often gives better symmetric-difference bounds than left-aligning.

        Args:
            S: Finite set of hex cells

        Returns:
            Compressed set with centered fibers
        """
        fibers = FiberAnalysis.get_fibers(S)
        result = set()
        for y, qs in fibers.items():
            mean = sum(qs) // len(qs)
            half = len(qs) // 2
            start = mean - half
            for i in range(len(qs)):
                result.add((start + i, y))
        return result

    @staticmethod
    def cells_moved(S: Set[HexCell], S_compressed: Set[HexCell]) -> int:
        """Count cells that changed position during compression."""
        return len(S.symmetric_difference(S_compressed))


class RigidityCertifier:
    """Certify near-optimality and compute rigidity bounds."""

    @staticmethod
    def find_best_translate(
        S: Set[HexCell], r: int
    ) -> Tuple[HexCell, int]:
        """Find the translation v minimizing |S △ (hexPatch(r) + v)|.

        Tries centering the hex patch at each point of S.

        Time complexity: O(|S|² · r)

        Args:
            S: Finite set of hex cells
            r: Hex patch radius

        Returns:
            Tuple of (best translation vector, minimum symmetric difference)
        """
        patch = HexLattice.hex_patch(r)
        best_v: HexCell = (0, 0)
        best_diff = len(S) + len(patch)

        for p in S:
            translated = {(c[0] + p[0], c[1] + p[1]) for c in patch}
            diff = len(S.symmetric_difference(translated))
            if diff < best_diff:
                best_diff = diff
                best_v = p

        return best_v, best_diff

    @staticmethod
    def check_rigidity(
        S: Set[HexCell], r: int, delta: int, C: int = 9
    ) -> Dict:
        """Check the quantitative rigidity bound for a given set.

        Verifies whether |S △ (hexPatch(r) + v)| ≤ C · δ.

        Args:
            S: Finite set of hex cells
            r: Expected hex patch radius
            delta: Boundary excess bound
            C: Universal constant (default 9)

        Returns:
            Dictionary with certification results
        """
        card = len(S)
        expected_card = HexLattice.hex_number(r)
        bdy = BoundaryAnalysis.edge_boundary(S)
        opt_bdy = HexLattice.opt_boundary(r)
        excess = bdy - opt_bdy

        v, symm_diff = RigidityCertifier.find_best_translate(S, r)

        return {
            "cardinality_match": card == expected_card,
            "boundary": bdy,
            "optimal_boundary": opt_bdy,
            "boundary_excess": excess,
            "best_translate": v,
            "symmetric_difference": symm_diff,
            "bound": C * delta,
            "rigidity_holds": symm_diff <= C * delta,
            "effective_constant": symm_diff / max(delta, 1),
        }


class IsoperimetricProfile:
    """Compute the isoperimetric profile of the hex lattice."""

    @staticmethod
    def compute_profile(max_n: int) -> Dict[int, int]:
        """Compute the minimum edge boundary for each cardinality up to max_n.

        Uses BFS from the origin, greedily adding cells that minimize boundary.
        This gives an upper bound on the isoperimetric profile.

        Args:
            max_n: Maximum cardinality to compute

        Returns:
            Dictionary mapping cardinality to minimum boundary found
        """
        # Start with empty set, grow by BFS
        profile: Dict[int, int] = {0: 0}
        S: Set[HexCell] = set()

        # Priority queue: (boundary_increase, cell)
        candidates = [(6, (0, 0))]  # Adding the origin gives boundary 6
        visited = {(0, 0)}

        while len(S) < max_n and candidates:
            _, cell = heapq.heappop(candidates)

            if cell in S:
                continue

            S.add(cell)
            profile[len(S)] = BoundaryAnalysis.edge_boundary(S)

            # Add new candidates
            for n in HexLattice.neighbors(cell):
                if n not in visited:
                    visited.add(n)
                    # Estimate boundary increase
                    internal = sum(1 for nn in HexLattice.neighbors(n) if nn in S)
                    increase = 6 - 2 * internal
                    heapq.heappush(candidates, (increase, n))

        return profile


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Hexagonal Lattice Isoperimetry Algorithms")
    print("=" * 50)

    # Demonstrate hex patch properties
    for r in range(6):
        patch = HexLattice.hex_patch(r)
        bdy = BoundaryAnalysis.edge_boundary(patch)
        print(f"  r={r}: |hexPatch|={len(patch):4d}, boundary={bdy:3d}, "
              f"formula: {HexLattice.hex_number(r):4d}, {HexLattice.opt_boundary(r):3d}")

    print()

    # Demonstrate rigidity certification
    r = 3
    patch = HexLattice.hex_patch(r)
    print(f"Rigidity certification for r={r}:")
    result = RigidityCertifier.check_rigidity(patch, r, delta=0)
    print(f"  Perfect patch: symmDiff={result['symmetric_difference']}, "
          f"rigidity_holds={result['rigidity_holds']}")

    # Demonstrate compression
    print(f"\nCompression demo:")
    S = patch.copy()
    # Create a perturbation: remove one cell, add another
    cells = list(S)
    boundary_cell = None
    for p in cells:
        for n in HexLattice.neighbors(p):
            if n not in S:
                boundary_cell = p
                ext_cell = n
                break
        if boundary_cell:
            break

    if boundary_cell and ext_cell:
        S_perturbed = (S - {boundary_cell}) | {ext_cell}
        S_compressed = CompressionOperator.horizontal_compress(S_perturbed)

        bdy_orig = BoundaryAnalysis.edge_boundary(patch)
        bdy_perturbed = BoundaryAnalysis.edge_boundary(S_perturbed)
        bdy_compressed = BoundaryAnalysis.edge_boundary(S_compressed)

        print(f"  Original boundary: {bdy_orig}")
        print(f"  Perturbed boundary: {bdy_perturbed}")
        print(f"  Compressed boundary: {bdy_compressed}")
        print(f"  Fiber gaps (perturbed): {FiberAnalysis.total_fiber_gaps(S_perturbed)}")
        print(f"  Fiber gaps (compressed): {FiberAnalysis.total_fiber_gaps(S_compressed)}")

    # Isoperimetric profile
    print(f"\nIsoperimetric profile (first 40 values):")
    profile = IsoperimetricProfile.compute_profile(40)
    for n in range(1, min(41, len(profile) + 1)):
        if n in profile:
            is_hex = any(HexLattice.hex_number(r) == n for r in range(10))
            marker = " *" if is_hex else ""
            print(f"  n={n:3d}: min_boundary≤{profile[n]:3d}{marker}")
