from typing import Callable, Iterable, List, Tuple

Vec = Tuple[int, ...]

def minimal_elements(points: Iterable[Vec],
                     leq: Callable[[Vec, Vec], bool]) -> List[Vec]:
    """Return Min(points): the antichain of minimal elements under `leq`."""
    pts: List[Vec] = list(dict.fromkeys(points))
    result: List[Vec] = []
    for x in pts:
        if not any(y != x and leq(y, x) for y in pts):
            result.append(x)
    return sorted(result)
