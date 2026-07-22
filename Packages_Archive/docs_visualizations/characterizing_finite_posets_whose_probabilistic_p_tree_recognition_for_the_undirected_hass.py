from typing import Dict, Hashable, List, Set, Tuple
Element = Hashable

def hasse_is_tree(
    elements: List[Element], covers: List[Tuple[Element, Element]]
) -> bool:
    """A Hasse graph is a tree iff it is connected and acyclic.

    Using the identity  (edges == vertices - components)  characterizes forests;
    a tree is a forest with exactly one component.
    """
    adj: Dict[Element, Set[Element]] = {e: set() for e in elements}
    for a, b in covers:
        adj[a].add(b)
        adj[b].add(a)
    seen: Set[Element] = set()
    comps = 0
    for s in elements:
        if s in seen:
            continue
        comps += 1
        stack = [s]
        seen.add(s)
        while stack:
            u = stack.pop()
            for v in adj[u]:
                if v not in seen:
                    seen.add(v)
                    stack.append(v)
    n = len(elements)
    e = len(covers)
    connected = comps == 1
    acyclic = e == n - comps
    return connected and acyclic
