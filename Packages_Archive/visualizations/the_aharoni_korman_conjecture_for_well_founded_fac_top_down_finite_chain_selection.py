from typing import Dict, FrozenSet, List, Set, Tuple

Element = str
Relation = Set[Tuple[Element, Element]]

def chain_hitting_levels(ground: List[Element], less: Relation,
                         hts: Dict[Element, int],
                         levels: Dict[int, FrozenSet[Element]],
                         targets: List[int]) -> List[Element]:
    """Top-down construction of a single chain meeting every non-empty target level."""
    wanted = sorted({a for a in targets if a in levels}, reverse=True)
    if not wanted:
        return []
    chain = [next(iter(levels[wanted[0]]))]
    for alpha in wanted[1:]:
        cur = chain[-1]
        while hts[cur] != alpha:
            cur = next(b for b in ground if (b, cur) in less and hts[b] >= alpha)
        chain.append(cur)
    return chain
