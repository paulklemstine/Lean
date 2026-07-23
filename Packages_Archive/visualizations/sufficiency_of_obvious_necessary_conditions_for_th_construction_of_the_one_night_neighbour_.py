from typing import Dict, List, Set, Tuple

Seat = Tuple

def build_night_graph(m: List[int], s: int) -> Tuple[Set[frozenset], Dict[Seat, Seat]]:
    """Return (edge set of G, partner involution) for profile (s; m)."""
    edges: Set[frozenset] = set()
    partner: Dict[Seat, Seat] = {}
    for i, mi in enumerate(m):
        n2 = 2 * mi
        for a in range(n2):
            v = ("R", i, a)
            edges.add(frozenset({v, ("R", i, (a + 1) % n2)}))
            edges.add(frozenset({v, ("R", i, (a + mi) % n2)}))
            partner[v] = ("R", i, (a + mi) % n2)
    for p in range(s):
        edges.add(frozenset({("S", p, 0), ("S", p, 1)}))
        partner[("S", p, 0)] = ("S", p, 1)
        partner[("S", p, 1)] = ("S", p, 0)
    return edges, partner
