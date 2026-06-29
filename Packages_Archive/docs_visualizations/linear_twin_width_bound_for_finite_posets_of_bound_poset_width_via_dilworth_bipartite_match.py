from typing import Callable, Dict, List, Sequence

Leq = Callable[[int, int], bool]


def width_via_dilworth(leq: Leq, elements: Sequence[int]) -> int:
    """
    Width (largest antichain) in polynomial time via Dilworth:
    width = |P| - (maximum matching of the bipartite graph with edges a < b).
    The pigeonhole bound antichain_card_le_chains is the easy converse:
    any antichain meets each chain at most once, so |A| <= (#chains).
    """
    elems: List[int] = list(elements)
    adj: Dict[int, List[int]] = {
        a: [b for b in elems if a != b and leq(a, b)] for a in elems
    }
    match_right: Dict[int, int] = {}

    def augment(a: int, seen: set) -> bool:
        for b in adj[a]:
            if b in seen:
                continue
            seen.add(b)
            if b not in match_right or augment(match_right[b], seen):
                match_right[b] = a
                return True
        return False

    matching = sum(1 for a in elems if augment(a, set()))
    return len(elems) - matching
