from typing import Callable, Hashable, List
Element = Hashable

def is_rb_shaped(
    elements: List[Element], leq: Callable[[Element, Element], bool]
) -> bool:
    """Decide RB-shape: a least element AND a tree Hasse graph."""
    def lt(a: Element, b: Element) -> bool:
        return leq(a, b) and a != b

    # (1) least element
    has_least = any(all(leq(b, x) for x in elements) for b in elements)
    if not has_least:
        return False

    # (2) covering relation
    covers = []
    for x in elements:
        for y in elements:
            if lt(x, y) and not any(lt(x, z) and lt(z, y) for z in elements):
                covers.append((x, y))

    # (3) tree test (connected + acyclic via edges == vertices - components)
    adj = {e: set() for e in elements}
    for a, b in covers:
        adj[a].add(b); adj[b].add(a)
    seen, comps = set(), 0
    for s in elements:
        if s in seen:
            continue
        comps += 1
        stack, _ = [s], seen.add(s)
        while stack:
            u = stack.pop()
            for v in adj[u]:
                if v not in seen:
                    seen.add(v); stack.append(v)
    n, e = len(elements), len(covers)
    return comps == 1 and e == n - comps
