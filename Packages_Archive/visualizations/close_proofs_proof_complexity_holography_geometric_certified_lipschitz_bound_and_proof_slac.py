from collections import deque
from typing import Callable, Dict, List, Optional, Hashable, Tuple

Atom = Hashable
Theory = Dict[Atom, List[Atom]]


def _min_len(axioms: Theory, a: Atom, b: Atom) -> Optional[int]:
    if a == b:
        return 0
    dist = {a: 0}
    q = deque([a])
    while q:
        x = q.popleft()
        for y in axioms.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                if y == b:
                    return dist[y]
                q.append(y)
    return None


def _shortest(axioms: Theory, a: Atom, b: Atom) -> Optional[List[Atom]]:
    if a == b:
        return [a]
    prev: Dict[Atom, Atom] = {}
    dist = {a: 0}
    q = deque([a])
    while q:
        x = q.popleft()
        for y in axioms.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                prev[y] = x
                if y == b:
                    path = [y]
                    while path[-1] != a:
                        path.append(prev[path[-1]])
                    return list(reversed(path))
                q.append(y)
    return None


def certified_lipschitz_bound(
    src: Theory, tgt: Theory, a: Atom, b: Atom,
    vmap: Callable[[Atom], Atom],
    stretch: int,
    realize: Callable[[Atom, Atom], List[Atom]],
) -> Tuple[int, int, int, int]:
    """Algorithm C: certify minDerivLen_translate_le (Theorem 5.1).

    Returns (source_dist m, predicted_bound L*m, actual_target_dist, slack).
    Asserts actual_target_dist <= L*m, the Lipschitz guarantee."""
    m = _min_len(src, a, b)
    assert m is not None, "b must be derivable from a in the source"
    path = _shortest(src, a, b)
    tpath: List[Atom] = [vmap(path[0])]
    for x, y in zip(path, path[1:]):
        tpath.extend(realize(x, y)[1:])
    translated_len = len(tpath) - 1
    actual = _min_len(tgt, vmap(a), vmap(b))
    bound = stretch * m
    assert actual is not None and actual <= bound and translated_len <= bound
    return m, bound, actual, bound - actual
