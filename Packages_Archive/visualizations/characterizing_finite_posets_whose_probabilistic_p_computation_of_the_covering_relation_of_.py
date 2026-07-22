from typing import Callable, Hashable, List
Element = Hashable

def covering_relation(
    elements: List[Element], leq: Callable[[Element, Element], bool]
) -> List[tuple]:
    """Return all covering pairs (x, y) with x <| y (y covers x)."""
    def lt(a: Element, b: Element) -> bool:
        return leq(a, b) and a != b
    covers: List[tuple] = []
    for x in elements:
        for y in elements:
            if not lt(x, y):
                continue
            if not any(lt(x, z) and lt(z, y) for z in elements):
                covers.append((x, y))
    return covers
