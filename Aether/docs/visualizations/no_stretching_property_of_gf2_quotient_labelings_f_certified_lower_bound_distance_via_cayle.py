from collections import deque
from typing import Dict, List, Tuple

Vec = Tuple[int, ...]


def xor(a: Vec, b: Vec) -> Vec:
    """Coordinate-wise XOR of two GF(2) vectors."""
    return tuple((x ^ y) for x, y in zip(a, b))


def cayley_distance(
    a: Vec, b: Vec, generators: List[Vec]
) -> int:
    """
    Shortest-word distance in the Cayley graph of an elementary abelian
    2-group on `generators`: the minimum number of generators (with
    repetition) summing to a - b = a XOR b. BFS from the difference to 0.
    Returns a certified lower bound on the true graph distance d_G(u, v).
    """
    target = xor(a, b)
    zero = tuple(0 for _ in target)
    if target == zero:
        return 0
    seen = {target}
    frontier = deque([(target, 0)])
    while frontier:
        cur, d = frontier.popleft()
        for g in generators:
            nxt = xor(cur, g)
            if nxt == zero:
                return d + 1
            if nxt not in seen:
                seen.add(nxt)
                frontier.append((nxt, d + 1))
    raise ValueError("unreachable: generators do not span the difference")
