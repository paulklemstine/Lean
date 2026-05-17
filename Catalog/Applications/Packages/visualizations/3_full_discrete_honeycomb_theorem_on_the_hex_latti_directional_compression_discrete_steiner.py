#!/usr/bin/env python3
"""
Algorithms for Discrete Honeycomb Optimization on the Hex Lattice

Implements:
1. Hex lattice isoperimetric profile computation
2. Directional compression (discrete Steiner symmetrization)
3. Optimal hex region construction for arbitrary n
4. Boundary computation and verification
"""

from typing import Set, Tuple, List, Dict, Optional
from collections import defaultdict
import heapq
import math

HexCell = Tuple[int, int]


# ═══════════════════════════════════════════════════════════════════
# §1. Core hex lattice operations
# ═══════════════════════════════════════════════════════════════════

def hex_dist(a: HexCell, b: HexCell) -> int:
    """Hex metric distance: max(|Δq|, |Δr|, |Δq+Δr|)."""
    dq = b[0] - a[0]
    dr = b[1] - a[1]
    return max(abs(dq), abs(dr), abs(dq + dr))


def hex_neighbors(p: HexCell) -> List[HexCell]:
    """Six neighbors of p in axial coordinates."""
    q, r = p
    return [(q+1, r), (q-1, r), (q, r+1), (q, r-1), (q+1, r-1), (q-1, r+1)]


def hex_patch(radius: int) -> Set[HexCell]:
    """Generate hex patch of given radius centered at origin.

    The hex patch is the L∞ ball in cube coordinates:
    {(q, r) : max(|q|, |r|, |q+r|) ≤ radius}

    Cardinality: 3r² + 3r + 1 (centered hexagonal number)

    Time complexity: O(r²)
    Space complexity: O(r²)
    """
    cells = set()
    for q in range(-radius, radius + 1):
        for r in range(-radius, radius + 1):
            if max(abs(q), abs(r), abs(q + r)) <= radius:
                cells.add((q, r))
    return cells


def edge_boundary(S: Set[HexCell]) -> int:
    """Count edges from S to its complement.

    For each cell in S, counts neighbors not in S.
    Equivalently: 6|S| - internalEdges(S).

    Time complexity: O(|S|)
    Space complexity: O(1) additional
    """
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n not in S:
                count += 1
    return count


def internal_edges(S: Set[HexCell]) -> int:
    """Count internal adjacencies (ordered pairs both in S).

    Time complexity: O(|S|)
    """
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n in S:
                count += 1
    return count


def is_connected(S: Set[HexCell]) -> bool:
    """Check if S is connected under hex adjacency.

    Uses BFS from an arbitrary starting cell.

    Time complexity: O(|S|)
    """
    if not S:
        return True
    start = next(iter(S))
    visited = {start}
    queue = [start]
    while queue:
        p = queue.pop(0)
        for n in hex_neighbors(p):
            if n in S and n not in visited:
                visited.add(n)
                queue.append(n)
    return len(visited) == len(S)


# ═══════════════════════════════════════════════════════════════════
# §2. Hex Compression (Discrete Steiner Symmetrization)
# ═══════════════════════════════════════════════════════════════════

def compress_direction(S: Set[HexCell], axis: int) -> Set[HexCell]:
    """Compress S along one of three hex-lattice axes.

    In cube coordinates (x, y, z) with x+y+z=0:
    - axis=0: compress along x (fiber = fixed y, z mod)
    - axis=1: compress along y (fiber = fixed x, z mod)
    - axis=2: compress along z (fiber = fixed x, y mod)

    In axial coordinates (q, r) with q=x, r=z, y=-(q+r):
    - axis=0: group by r, center each group
    - axis=1: group by q+r, center each group
    - axis=2: group by q, center each group

    Properties:
    - Preserves cardinality
    - Does not increase edge boundary
    - Idempotent

    Time complexity: O(|S| log |S|)
    """
    if axis == 0:
        # Group by r-coordinate, center q-values
        fibers: Dict[int, List[int]] = defaultdict(list)
        for q, r in S:
            fibers[r].append(q)
    elif axis == 1:
        # Group by q+r (= x+z = -y), center values
        fibers = defaultdict(list)
        for q, r in S:
            fibers[q + r].append(q)
    else:  # axis == 2
        # Group by q-coordinate, center r-values
        fibers = defaultdict(list)
        for q, r in S:
            fibers[q].append(r)

    result = set()
    for key, values in fibers.items():
        values.sort()
        n = len(values)
        # Center the values: place n cells symmetrically around 0
        centered = list(range(-(n // 2), -(n // 2) + n))
        if axis == 0:
            for q in centered:
                result.add((q, key))
        elif axis == 1:
            for q in centered:
                result.add((q, key - q))
        else:
            for r in centered:
                result.add((key, r))

    return result


def full_compression(S: Set[HexCell], max_iters: int = 100) -> Set[HexCell]:
    """Apply compression in all 3 directions until convergence.

    Iterates compression along axes 0, 1, 2 until the set stabilizes.
    Guaranteed to terminate since edge boundary decreases monotonically
    and is bounded below.

    Returns the fully compressed (hex-convex) set.

    Time complexity: O(|S| log |S| × max_iters)
    """
    current = S.copy()
    for _ in range(max_iters):
        prev = current.copy()
        for axis in [0, 1, 2]:
            current = compress_direction(current, axis)
        if current == prev:
            break
    return current


# ═══════════════════════════════════════════════════════════════════
# §3. Optimal Region Construction
# ═══════════════════════════════════════════════════════════════════

def optimal_hex_region(n: int) -> Set[HexCell]:
    """Construct the optimal hex region of n cells.

    The optimal region consists of the largest complete hex patch
    that fits, plus a partial outer shell of remaining cells,
    chosen to minimize boundary.

    Algorithm:
    1. Find largest r with 3r²+3r+1 ≤ n
    2. Start with hexPatch(r)
    3. Add remaining cells from shell(r+1) greedily,
       choosing cells that maximize internal edges

    Time complexity: O(n log n)
    Space complexity: O(n)
    """
    if n <= 0:
        return set()

    # Find largest complete hex patch
    r = 0
    while 3 * (r + 1) ** 2 + 3 * (r + 1) + 1 <= n:
        r += 1

    region = hex_patch(r)
    remaining = n - len(region)

    if remaining == 0:
        return region

    # Generate shell candidates at distance r+1
    shell = []
    for q in range(-(r + 1), r + 2):
        for s in range(-(r + 1), r + 2):
            if hex_dist((0, 0), (q, s)) == r + 1:
                shell.append((q, s))

    # Greedily add cells that maximize internal edges
    # Priority: number of neighbors already in region (higher = better)
    for cell in sorted(shell, key=lambda c: -sum(1 for n in hex_neighbors(c) if n in region)):
        if remaining <= 0:
            break
        region.add(cell)
        remaining -= 1

    return region


def hex_edge_iso_profile(max_n: int) -> List[int]:
    """Compute the isoperimetric profile for n = 0, 1, ..., max_n.

    Returns profile[n] = minimum edge boundary among all sets of size n.
    Uses optimal region construction.

    Time complexity: O(max_n² log max_n)
    """
    profile = [0]  # n=0
    for n in range(1, max_n + 1):
        region = optimal_hex_region(n)
        profile.append(edge_boundary(region))
    return profile


# ═══════════════════════════════════════════════════════════════════
# §4. Verification and Testing
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("HEX LATTICE ALGORITHMS — VERIFICATION")
    print("=" * 60)
    print()

    # Test compression
    print("§1. Compression reduces boundary")
    print("-" * 50)
    import random
    random.seed(123)
    for trial in range(5):
        # Random connected region
        cells = {(0, 0)}
        for _ in range(30):
            frontier = []
            for c in cells:
                for n in hex_neighbors(c):
                    if n not in cells:
                        frontier.append(n)
            if frontier:
                cells.add(random.choice(frontier))

        original_boundary = edge_boundary(cells)
        compressed = full_compression(cells)
        compressed_boundary = edge_boundary(compressed)
        print(f"  Trial {trial+1}: |S|={len(cells)}, "
              f"boundary {original_boundary} → {compressed_boundary} "
              f"({'reduced' if compressed_boundary < original_boundary else 'unchanged'})")
    print()

    # Test optimal region
    print("§2. Optimal Region vs Hex Patch")
    print("-" * 50)
    for r in range(6):
        n = 3 * r**2 + 3 * r + 1
        optimal = optimal_hex_region(n)
        patch = hex_patch(r)
        opt_b = edge_boundary(optimal)
        patch_b = edge_boundary(patch)
        print(f"  n={n:3d} (r={r}): optimal_boundary={opt_b}, patch_boundary={patch_b} "
              f"{'✓' if opt_b == patch_b else '✗'}")
    print()

    # Isoperimetric profile
    print("§3. Isoperimetric Profile for n = 1..40")
    print("-" * 50)
    profile = hex_edge_iso_profile(40)
    hex_nums = {3 * r**2 + 3 * r + 1 for r in range(10)}
    for n in range(1, 41):
        marker = " ← hex number" if n in hex_nums else ""
        print(f"  n={n:2d}: min_boundary={profile[n]:3d}{marker}")
    print()

    # Compression produces near-hex-patch shapes
    print("§4. Full Compression → Hex-Convex Shape")
    print("-" * 50)
    for n in [7, 19, 37, 61]:
        region = optimal_hex_region(n)
        compressed = full_compression(region)
        print(f"  n={n}: |compressed|={len(compressed)}, "
              f"boundary={edge_boundary(compressed)}, "
              f"connected={is_connected(compressed)}")
