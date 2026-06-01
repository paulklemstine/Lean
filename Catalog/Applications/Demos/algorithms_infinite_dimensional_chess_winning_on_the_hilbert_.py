"""
Algorithms for Infinite Chess: The Hilbert Board

Type-hinted implementations of escape analysis algorithms
for chess on the infinite board ℤ × ℤ.
"""

from typing import List, Tuple, Set, Optional
from collections import deque

Pos = Tuple[int, int]


def chebyshev_dist(p: Pos, q: Pos) -> int:
    """Chebyshev (L∞) distance between two board positions.

    This equals the minimum number of king moves between p and q.

    >>> chebyshev_dist((0, 0), (3, 5))
    5
    >>> chebyshev_dist((1, 1), (1, 1))
    0
    """
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p: Pos) -> List[Pos]:
    """Return the 8 king-adjacent positions.

    >>> sorted(king_neighbors((0, 0)))
    [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    """
    x, y = p
    return [(x + dx, y + dy) for dx in [-1, 0, 1] for dy in [-1, 0, 1]
            if (dx, dy) != (0, 0)]


def knight_targets(p: Pos) -> List[Pos]:
    """Return the 8 squares attacked by a knight at position p.

    >>> len(knight_targets((0, 0)))
    8
    >>> (1, 2) in knight_targets((0, 0))
    True
    """
    x, y = p
    offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2),
               (1, -2), (1, 2), (2, -1), (2, 1)]
    return [(x + dx, y + dy) for dx, dy in offsets]


def attacked_set(knights: List[Pos]) -> Set[Pos]:
    """Compute the set of all squares attacked by the given knights.

    >>> attacked = attacked_set([(0, 0)])
    >>> len(attacked)
    8
    >>> (1, 2) in attacked
    True
    """
    result: Set[Pos] = set()
    for k in knights:
        result.update(knight_targets(k))
    return result


def is_safe(pos: Pos, attack_set: Set[Pos]) -> bool:
    """Check if a position is safe (not attacked)."""
    return pos not in attack_set


def escape_radius(king: Pos, knights: List[Pos]) -> int:
    """Compute the escape radius for a king against knights.

    The escape radius is the maximum Chebyshev distance from the king
    to any attacked square, plus 1. Beyond this radius, safety is guaranteed.

    >>> escape_radius((0, 0), [(3, 3)])
    6
    """
    attacks = attacked_set(knights)
    if not attacks:
        return 0
    max_dist = max(chebyshev_dist(king, a) for a in attacks)
    return max_dist + 1


def find_nearest_safe(king: Pos, knights: List[Pos]) -> Tuple[Pos, int]:
    """Find the nearest safe square using BFS.

    Returns (safe_position, distance).

    >>> pos, dist = find_nearest_safe((0, 0), [])
    >>> dist
    0
    """
    attacks = attacked_set(knights)
    if king not in attacks:
        return king, 0

    visited: Set[Pos] = set()
    queue: deque[Tuple[Pos, int]] = deque([(king, 0)])
    visited.add(king)

    while queue:
        pos, dist = queue.popleft()
        if pos not in attacks:
            return pos, dist
        for neighbor in king_neighbors(pos):
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, dist + 1))

    # This should never happen on an infinite board
    raise RuntimeError("No safe square found (impossible on infinite board)")


def construct_king_path(p: Pos, q: Pos) -> List[Pos]:
    """Construct an optimal king path from p to q.

    The path has length chebyshev_dist(p, q) + 1 (including both endpoints).
    Moves diagonally when possible, then straight.

    >>> construct_king_path((0, 0), (3, 1))
    [(0, 0), (1, 1), (2, 1), (3, 1)]
    """
    path = [p]
    current = list(p)
    target = list(q)

    while current != target:
        for i in range(2):
            if current[i] < target[i]:
                current[i] += 1
            elif current[i] > target[i]:
                current[i] -= 1
        path.append(tuple(current))

    return path


def rook_attack_lines(rooks: List[Pos]) -> Tuple[Set[int], Set[int]]:
    """Return the set of rows and columns controlled by rooks.

    >>> rows, cols = rook_attack_lines([(1, 2), (3, 4)])
    >>> sorted(rows)
    [2, 4]
    >>> sorted(cols)
    [1, 3]
    """
    rows = {r[1] for r in rooks}
    cols = {r[0] for r in rooks}
    return rows, cols


def find_rook_safe(rooks: List[Pos]) -> Pos:
    """Find a position safe from all rooks.

    >>> pos = find_rook_safe([(1, 2), (3, 4)])
    >>> pos[0] not in {1, 3} and pos[1] not in {2, 4}
    True
    """
    rows, cols = rook_attack_lines(rooks)
    x = 0
    while x in cols:
        x += 1
    y = 0
    while y in rows:
        y += 1
    return (x, y)


def square_color(p: Pos) -> int:
    """Return the color of a square (0 or 1).

    >>> square_color((0, 0))
    0
    >>> square_color((1, 0))
    1
    """
    return (p[0] + p[1]) % 2


def verify_knight_escape_conjecture(max_knights: int = 6,
                                     search_radius: int = 5,
                                     escape_bound: int = 3) -> bool:
    """Test the knight escape bound conjecture.

    For up to max_knights knights placed within search_radius of the origin,
    verify that the king at (0,0) can always find a safe square within
    escape_bound moves.

    Note: Full enumeration is combinatorially explosive for large parameters.
    This tests a random sample.

    Returns True if no counterexample found.
    """
    import random
    king = (0, 0)
    positions = [(x, y) for x in range(-search_radius, search_radius + 1)
                 for y in range(-search_radius, search_radius + 1)
                 if (x, y) != king]

    neighborhood = set()
    for dx in range(-escape_bound, escape_bound + 1):
        for dy in range(-escape_bound, escape_bound + 1):
            neighborhood.add((dx, dy))

    num_tests = 10000
    for _ in range(num_tests):
        n = random.randint(1, max_knights)
        knights = random.sample(positions, min(n, len(positions)))
        attacks = attacked_set(knights)
        safe_nearby = [q for q in neighborhood if q not in attacks]
        if not safe_nearby:
            print(f"COUNTEREXAMPLE FOUND: knights = {knights}")
            return False
    return True


class EscapeConfig:
    """Escape configuration for analysis of king safety.

    Packages together king position, attacker positions, and attack relation
    with computed escape analysis.
    """

    def __init__(self, king: Pos, attackers: List[Pos],
                 attack_fn=knight_targets):
        self.king = king
        self.attackers = attackers
        self.attack_fn = attack_fn
        self._attacked: Optional[Set[Pos]] = None

    @property
    def attacked_squares(self) -> Set[Pos]:
        if self._attacked is None:
            self._attacked = set()
            for a in self.attackers:
                self._attacked.update(self.attack_fn(a))
        return self._attacked

    @property
    def escape_radius(self) -> int:
        attacks = self.attacked_squares
        if not attacks:
            return 0
        return max(chebyshev_dist(self.king, a) for a in attacks) + 1

    def find_escape(self) -> Tuple[Pos, List[Pos]]:
        """Find nearest safe square and path to it."""
        safe_pos, _ = find_nearest_safe(self.king, self.attackers)
        path = construct_king_path(self.king, safe_pos)
        return safe_pos, path

    def summary(self) -> str:
        attacks = self.attacked_squares
        safe_pos, path = self.find_escape()
        return (
            f"King at {self.king}, {len(self.attackers)} attackers\n"
            f"Attacked squares: {len(attacks)}\n"
            f"Escape radius: {self.escape_radius}\n"
            f"Nearest safe square: {safe_pos} (distance {chebyshev_dist(self.king, safe_pos)})\n"
            f"Escape path length: {len(path) - 1} moves"
        )


if __name__ == "__main__":
    import doctest
    doctest.testmod()
