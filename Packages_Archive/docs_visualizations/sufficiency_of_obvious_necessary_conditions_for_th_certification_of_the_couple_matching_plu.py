from typing import Dict, List, Set, Tuple

Seat = Tuple

def verify_decomposition(edges: Set[frozenset], partner: Dict[Seat, Seat],
                         m: List[int]) -> bool:
    """Check partner is a fixed-point-free involution and that removing the
    couple edges leaves exactly disjoint cycles of lengths 2*m_i."""
    if any(partner[partner[v]] != v or partner[v] == v for v in partner):
        return False
    couples = {frozenset({v, partner[v]}) for v in partner}
    if not couples <= edges:
        return False
    non_couple = edges - couples
    adj: Dict[Seat, Set[Seat]] = {v: set() for v in partner}
    for e in non_couple:
        u, w = tuple(e)
        adj[u].add(w); adj[w].add(u)
    seen: Set[Seat] = set(); lengths: List[int] = []
    for v in partner:
        if v in seen or not adj[v]:
            continue
        comp, stack = 0, [v]
        while stack:
            x = stack.pop()
            if x in seen:
                continue
            seen.add(x); comp += 1; stack.extend(adj[x])
        lengths.append(comp)
    return sorted(lengths) == sorted(2 * mi for mi in m)
