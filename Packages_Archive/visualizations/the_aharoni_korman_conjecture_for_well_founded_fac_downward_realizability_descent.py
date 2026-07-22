from typing import Dict, List, Optional, Set, Tuple

Element = str
Relation = Set[Tuple[Element, Element]]

def realize_below(ground: List[Element], less: Relation,
                  hts: Dict[Element, int], w: Element,
                  alpha: int) -> Optional[Element]:
    """Given alpha <= height(w), descend from w to some u <= w with height(u)=alpha."""
    if alpha > hts[w]:
        return None
    cur = w
    while hts[cur] != alpha:
        cur = next(b for b in ground if (b, cur) in less and hts[b] >= alpha)
    return cur
