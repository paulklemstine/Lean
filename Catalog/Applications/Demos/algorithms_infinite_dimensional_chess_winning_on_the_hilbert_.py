#!/usr/bin/env python3
"""
Algorithms for Infinite Chess on the Hilbert Board
===================================================
Type-hinted implementations of key algorithms from the formalization.
"""

from typing import List, Tuple, Set, Optional, Dict
import itertools


# Type aliases
Position = Tuple[int, ...]


def chebyshev_distance(p: Position, q: Position) -> int:
    """
    Compute the Chebyshev (L∞) distance between two positions.

    The Chebyshev distance equals the minimum number of king moves
    between two positions on the d-dimensional board.

    Args:
        p: First position (d-tuple of integers)
        q: Second position (d-tuple of integers)

    Returns:
        The maximum absolute coordinate difference.
    """
    assert len(p) == len(q), "Positions must have same dimension"
    if len(p) == 0:
        return 0
    return max(abs(pi - qi) for pi, qi in zip(p, q))


def is_king_adjacent(p: Position, q: Position) -> bool:
    """
    Check if two positions are king-adjacent.

    Two positions are king-adjacent if they are distinct and differ
    by at most 1 in each coordinate.

    Args:
        p: First position
        q: Second position

    Returns:
        True if p and q are king-adjacent.
    """
    return p != q and chebyshev_distance(p, q) <= 1


def knight_attacks(src: Position, d: int) -> Set[Position]:
    """
    Compute all positions attacked by a generalized d-dimensional knight.

    A knight moves by ±1 in one coordinate and ±2 in another,
    keeping all other coordinates unchanged.

    Args:
        src: Knight's position
        d: Board dimension

    Returns:
        Set of attacked positions.

    Algorithm:
        For each pair (i, j) of distinct coordinates:
            For each sign combination (±1, ±2):
                Create target by modifying coordinates i and j
    """
    attacks: Set[Position] = set()
    for i in range(d):
        for j in range(d):
            if i == j:
                continue
            for di in [1, -1]:
                for dj in [2, -2]:
                    tgt = list(src)
                    tgt[i] += di
                    tgt[j] += dj
                    attacks.add(tuple(tgt))
    return attacks


def rook_attacks_in_ball(src: Position, d: int, radius: int) -> Set[Position]:
    """
    Compute rook attacks within a Chebyshev ball.

    A rook attacks along coordinate axes. Since the full attack set
    is infinite, we restrict to a finite ball.

    Args:
        src: Rook's position
        d: Board dimension
        radius: Chebyshev radius of the ball

    Returns:
        Set of attacked positions within the ball.
    """
    attacks: Set[Position] = set()
    for i in range(d):
        for delta in range(-radius, radius + 1):
            if delta == 0:
                continue
            tgt = list(src)
            tgt[i] += delta
            if chebyshev_distance(tuple(tgt), src) <= radius:
                attacks.add(tuple(tgt))
    return attacks


def bishop_color(pos: Position) -> int:
    """
    Compute the color of a square: parity of coordinate sum.

    A bishop can only attack squares of the same color.
    This partitions the board into two independent components.

    Args:
        pos: Board position

    Returns:
        0 or 1 (the color class)
    """
    return sum(pos) % 2


def find_safe_square(
    attack_sets: List[Set[Position]],
    d: int,
    max_radius: int = 50
) -> Optional[Position]:
    """
    Find the nearest safe square to the origin.

    Searches outward from the origin in concentric Chebyshev shells
    until a position not in any attack set is found.

    Args:
        attack_sets: List of sets of attacked positions
        d: Board dimension
        max_radius: Maximum search radius

    Returns:
        The nearest safe position, or None if not found within max_radius.

    Algorithm:
        For r = 0, 1, 2, ..., max_radius:
            For each position p at Chebyshev distance r from origin:
                If p is not attacked by any piece:
                    Return p
        Return None
    """
    all_attacked = set()
    for s in attack_sets:
        all_attacked |= s

    for r in range(max_radius + 1):
        for pos in itertools.product(range(-r, r + 1), repeat=d):
            if max(abs(c) for c in pos) == r or r == 0:
                p = tuple(pos)
                if p not in all_attacked:
                    return p
    return None


def escape_radius(
    pieces: List[Position],
    attack_fn,
    d: int,
    king_pos: Position,
    max_radius: int = 20
) -> int:
    """
    Compute the escape radius: minimum Chebyshev distance from the king
    to the nearest safe square.

    Args:
        pieces: List of attacking piece positions
        attack_fn: Function mapping (piece_position, dimension) -> set of attacks
        d: Board dimension
        king_pos: Current king position
        max_radius: Maximum search radius

    Returns:
        The escape radius, or max_radius + 1 if no safe square found.

    Algorithm:
        1. Compute the union of all attack sets
        2. Search outward from king_pos in Chebyshev shells
        3. Return distance to first safe square
    """
    all_attacked: Set[Position] = set()
    for piece in pieces:
        all_attacked |= attack_fn(piece, d)

    for r in range(max_radius + 1):
        for pos in itertools.product(range(-r, r + 1), repeat=d):
            if max(abs(c) for c in pos) == r or r == 0:
                candidate = tuple(king_pos[i] + pos[i] for i in range(d))
                if candidate not in all_attacked:
                    return r
    return max_radius + 1


def coordinate_avoidance_strategy(
    rooks: List[Position],
    d: int
) -> Optional[Position]:
    """
    Find a safe position from rooks using the coordinate avoidance strategy.

    For each coordinate axis, choose a value not used by any rook.
    This guarantees safety when d ≥ 2.

    Args:
        rooks: List of rook positions
        d: Board dimension (must be ≥ 2)

    Returns:
        A safe position, or None if d < 2.

    Algorithm:
        For each coordinate i:
            Find z_i not in {rook[i] for rook in rooks}
        Return (z_0, z_1, ..., z_{d-1})
    """
    if d < 2:
        return None

    safe_coords: List[int] = []
    for i in range(d):
        used = {r[i] for r in rooks}
        z = 0
        while z in used:
            z += 1
        safe_coords.append(z)
    return tuple(safe_coords)


if __name__ == "__main__":
    # Test all algorithms
    print("Testing Chebyshev distance:")
    print(f"  d((0,0), (3,4)) = {chebyshev_distance((0, 0), (3, 4))}")
    print(f"  d((0,0,0), (1,2,3)) = {chebyshev_distance((0, 0, 0), (1, 2, 3))}")

    print("\nTesting knight attacks:")
    for d in [2, 3, 4]:
        origin = tuple([0] * d)
        attacks = knight_attacks(origin, d)
        print(f"  d={d}: knight at origin attacks {len(attacks)} squares")

    print("\nTesting coordinate avoidance:")
    rooks = [(0, 0), (1, 1), (2, 2)]
    safe = coordinate_avoidance_strategy(rooks, 2)
    print(f"  Rooks at {rooks}, safe position: {safe}")

    print("\nTesting escape radius:")
    for d in [2, 3, 4]:
        origin = tuple([0] * d)
        r = escape_radius([origin], knight_attacks, d, origin)
        print(f"  d={d}: escape radius from knight at origin = {r}")
