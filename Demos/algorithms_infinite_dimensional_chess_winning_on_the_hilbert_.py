#!/usr/bin/env python3
"""
Infinite Chess Algorithms: Type-hinted implementations of key algorithms
for the Hilbert Board theory.
"""

from typing import Set, Tuple, Optional, List, Dict
from dataclasses import dataclass


Pos = Tuple[int, int]


def cheb_dist(p: Pos, q: Pos) -> int:
    """Chebyshev (L∞) distance between two board positions.

    This equals the minimum number of king moves between them.
    Time: O(1). Space: O(1).
    """
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


@dataclass
class ThreatSignature:
    """A threat signature describes the shape of squares threatened by a piece type."""
    offsets: Set[Pos]

    def __post_init__(self) -> None:
        assert (0, 0) not in self.offsets, "Piece cannot threaten its own square"

    @property
    def reach(self) -> int:
        """Maximum Chebyshev distance of any offset from origin."""
        return max(cheb_dist((0, 0), d) for d in self.offsets) if self.offsets else 0


# Standard piece signatures
KNIGHT_SIG = ThreatSignature(offsets={
    (-2, -1), (-2, 1), (-1, -2), (-1, 2),
    (1, -2), (1, 2), (2, -1), (2, 1)
})

KING_SIG = ThreatSignature(offsets={
    (-1, -1), (-1, 0), (-1, 1), (0, -1),
    (0, 1), (1, -1), (1, 0), (1, 1)
})


def threatened_by(sig: ThreatSignature, pos: Pos) -> Set[Pos]:
    """Squares threatened by a piece with given signature at position pos.

    Time: O(|offsets|). Space: O(|offsets|).
    """
    return {(pos[0] + d[0], pos[1] + d[1]) for d in sig.offsets}


def total_threats(sig: ThreatSignature, pieces: Set[Pos]) -> Set[Pos]:
    """Union of all threats from a set of pieces with the same signature.

    Time: O(|pieces| × |offsets|). Space: O(|pieces| × |offsets|).
    """
    result: Set[Pos] = set()
    for p in pieces:
        result |= threatened_by(sig, p)
    return result


@dataclass
class ThreatBarrier:
    """A threat barrier on the infinite board ℤ×ℤ."""
    pieces: Set[Pos]
    signature: ThreatSignature
    king: Pos

    def __post_init__(self) -> None:
        assert self.king not in self.pieces

    @property
    def threats(self) -> Set[Pos]:
        return total_threats(self.signature, self.pieces)

    @property
    def threat_bound(self) -> int:
        """Upper bound on total threat count."""
        return len(self.pieces) * len(self.signature.offsets)


def top_edge(center: Pos, r: int) -> List[Pos]:
    """Top edge of Chebyshev sphere at radius r.

    Returns 2r+1 points, all at Chebyshev distance r from center (for r ≥ 1).
    Time: O(r). Space: O(r).
    """
    return [(x, center[1] + r)
            for x in range(center[0] - r, center[0] + r + 1)]


def chebyshev_sphere(center: Pos, r: int) -> List[Pos]:
    """All points at Chebyshev distance exactly r from center.

    Returns 8r points for r ≥ 1, 1 point for r = 0.
    Time: O(r). Space: O(r).
    """
    if r == 0:
        return [center]
    result = []
    cx, cy = center
    # Top and bottom edges
    for x in range(cx - r, cx + r + 1):
        result.append((x, cy + r))
        result.append((x, cy - r))
    # Left and right edges (excluding corners)
    for y in range(cy - r + 1, cy + r):
        result.append((cx - r, y))
        result.append((cx + r, y))
    return result


def find_escape_square(threats: Set[Pos], king: Pos) -> Pos:
    """Find the nearest safe square using the Fundamental Escape Inequality.

    Guaranteed to find a safe square at Chebyshev distance ≤ |threats|//2 + 1.
    Time: O(|threats|). Space: O(1).

    Algorithm:
    1. Set r = |threats| // 2 + 1
    2. Scan the top edge at radius r
    3. Return the first point not in threats

    By the Fundamental Escape Inequality, 2r+1 > |threats|,
    so at least one top edge point must be safe.
    """
    r = len(threats) // 2 + 1
    for sq in top_edge(king, r):
        if sq not in threats:
            return sq
    raise RuntimeError("Fundamental Escape Inequality violated!")


def find_directional_escape(threats: Set[Pos], king: Pos
                            ) -> Tuple[str, int]:
    """Find a diagonal escape direction and safe threshold.

    Returns (direction_name, N) such that ray(king, dir, n) ∉ threats for all n ≥ N.
    Time: O(|threats| × max_dist). Space: O(1).
    """
    directions = {
        'NE': lambda n: (king[0] + n, king[1] + n),
        'NW': lambda n: (king[0] - n, king[1] + n),
        'SE': lambda n: (king[0] + n, king[1] - n),
        'SW': lambda n: (king[0] - n, king[1] - n),
    }

    max_dist = max((abs(t[0] - king[0]) + abs(t[1] - king[1])
                    for t in threats), default=0) + 1

    for name, ray_fn in directions.items():
        last_hit = -1
        for n in range(max_dist + 1):
            if ray_fn(n) in threats:
                last_hit = n
        if last_hit < max_dist:
            return name, last_hit + 1

    return 'NE', max_dist + 1


def barrier_completeness_radius(barrier: ThreatBarrier) -> int:
    """Find the maximum radius at which the barrier is complete.

    Returns 0 if no radius is complete.
    Time: O(T² × r²) where T = threat bound, r = max possible radius.
    """
    threats = barrier.threats
    max_r = (len(threats) - 1) // 2 if threats else 0
    max_complete = 0

    for r in range(1, max_r + 1):
        sphere = chebyshev_sphere(barrier.king, r)
        if all(sq in threats for sq in sphere):
            max_complete = r
        else:
            break  # Once incomplete, stay incomplete for larger r (heuristic)

    return max_complete


def game_value(n: int) -> int:
    """Compute the ordinal game value of position n in the barrier peeling game.

    The barrier peeling game has moves: n+1 → n.
    Game value at position n equals n (the ordinal).

    Time: O(n). Space: O(n) due to recursion.
    """
    if n == 0:
        return 0
    return game_value(n - 1) + 1


def analyze_configuration(pieces: Set[Pos],
                          sig: ThreatSignature,
                          king: Pos) -> Dict:
    """Comprehensive analysis of a chess configuration on the Hilbert Board.

    Returns a dictionary with:
    - threat_count: number of threatened squares
    - escape_square: nearest safe square
    - escape_distance: Chebyshev distance to escape square
    - escape_bound: theoretical escape speed bound
    - escape_direction: direction and threshold for directional escape
    """
    threats = total_threats(sig, pieces)
    escape = find_escape_square(threats, king)

    return {
        'threat_count': len(threats),
        'threat_bound': len(pieces) * len(sig.offsets),
        'escape_square': escape,
        'escape_distance': cheb_dist(king, escape),
        'escape_bound': len(threats) // 2 + 1,
        'escape_direction': find_directional_escape(threats, king),
    }


if __name__ == "__main__":
    # Example: 5 knights vs lone king
    knights = {(3, 1), (-2, 4), (5, -1), (-3, -3), (1, 7)}
    king = (0, 0)

    result = analyze_configuration(knights, KNIGHT_SIG, king)

    print("Configuration Analysis:")
    print(f"  Knights: {knights}")
    print(f"  King: {king}")
    print(f"  Threat count: {result['threat_count']}")
    print(f"  Threat bound: {result['threat_bound']}")
    print(f"  Escape square: {result['escape_square']}")
    print(f"  Escape distance: {result['escape_distance']}")
    print(f"  Escape bound: {result['escape_bound']}")
    print(f"  Escape direction: {result['escape_direction']}")
