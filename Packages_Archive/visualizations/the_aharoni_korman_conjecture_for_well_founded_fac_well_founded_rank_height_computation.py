from typing import Dict, List, Set, Tuple

Element = str
Relation = Set[Tuple[Element, Element]]

def height(ground: List[Element], less: Relation) -> Dict[Element, int]:
    """Well-founded rank: height(x) = sup{ height(y)+1 : y < x } (0 if minimal)."""
    memo: Dict[Element, int] = {}
    def h(x: Element) -> int:
        if x in memo:
            return memo[x]
        below = [y for y in ground if (y, x) in less]
        memo[x] = 0 if not below else max(h(y) + 1 for y in below)
        return memo[x]
    return {x: h(x) for x in ground}
