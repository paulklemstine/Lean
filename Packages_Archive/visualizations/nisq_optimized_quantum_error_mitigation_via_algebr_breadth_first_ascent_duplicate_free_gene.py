from typing import Dict, List, Tuple

Pair = Tuple[int, int]
Triple = Tuple[int, int, int]


def param_map(branch: str, m: int, n: int) -> Pair:
    if branch == "A":
        return (2 * m - n, m)
    if branch == "B":
        return (2 * m + n, m)
    return (m + 2 * n, n)               # C


def euclid_triple(m: int, n: int) -> Triple:
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def enumerate_tree(max_depth: int) -> Dict[Triple, str]:
    """Breadth-first ascent: all primitive triples of depth <= max_depth, no duplicates."""
    found: Dict[Triple, str] = {euclid_triple(2, 1): ""}
    frontier: List[Tuple[Pair, str]] = [((2, 1), "")]
    for _ in range(max_depth):
        nxt: List[Tuple[Pair, str]] = []
        for (m, n), word in frontier:
            for br in ("A", "B", "C"):
                mm, nn = param_map(br, m, n)
                found[euclid_triple(mm, nn)] = word + br
                nxt.append(((mm, nn), word + br))
        frontier = nxt
    return found
