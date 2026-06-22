from typing import Dict, Iterable, List, Set, Tuple


def gravitational_weights(
    vertices: Iterable[str],
    edges: Iterable[Tuple[str, str]],
) -> Dict[str, int]:
    """weight[b] = number of theorems transitively depending on b."""
    verts: List[str] = list(vertices)
    succ: Dict[str, Set[str]] = {v: set() for v in verts}
    for a, b in edges:
        succ[a].add(b)

    reach: Dict[str, Set[str]] = {}
    for start in verts:
        seen: Set[str] = set()
        stack: List[str] = list(succ[start])
        while stack:
            cur = stack.pop()
            if cur in seen:
                continue
            seen.add(cur)
            stack.extend(succ[cur])
        reach[start] = seen

    return {b: sum(1 for a in verts if b in reach[a]) for b in verts}
