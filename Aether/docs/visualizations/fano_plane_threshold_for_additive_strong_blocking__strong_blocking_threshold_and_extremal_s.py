from itertools import combinations
from typing import FrozenSet, List, Set, Tuple

Point = int
Line = FrozenSet[Point]
POINTS: List[Point] = list(range(7))


def fano_line(i: Point) -> Line:
    """Line i = {i, i+1, i+3} (mod 7)."""
    return frozenset((i % 7, (i + 1) % 7, (i + 3) % 7))


def all_lines() -> List[Line]:
    return [fano_line(i) for i in POINTS]


def is_strong_blocking(s: Set[Point]) -> bool:
    """Algorithm A: test that S meets every line in >= 2 points."""
    return all(len(line & s) >= 2 for line in all_lines())


def threshold_and_extremal() -> Tuple[int, List[FrozenSet[Point]]]:
    """Algorithms B and C: minimum size and the extremal sets attaining it.

    Returns (minimum_size, list_of_minimum_sets).
    """
    best_size = 8
    extremal: List[FrozenSet[Point]] = []
    for r in range(8):
        sets_r = [frozenset(c) for c in combinations(POINTS, r)
                  if is_strong_blocking(set(c))]
        if sets_r and r < best_size:
            best_size = r
            extremal = sets_r
            break
    return best_size, extremal


if __name__ == "__main__":
    size, sets = threshold_and_extremal()
    print("minimum strong-blocking size:", size)
    print("number of extremal sets:", len(sets))
    for s in sets:
        print("  Z/7Z minus", (set(POINTS) - s), "=", sorted(s))
