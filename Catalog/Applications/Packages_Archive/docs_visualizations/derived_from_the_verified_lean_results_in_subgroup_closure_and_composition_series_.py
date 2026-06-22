from itertools import permutations
from typing import FrozenSet, List, Sequence, Tuple

Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(q)))

def identity(n: int) -> Perm:
    return tuple(range(n))

def closure(generators: Sequence[Perm], n: int) -> FrozenSet[Perm]:
    elems = {identity(n)}; frontier = [identity(n)]
    gens = list(generators) or [identity(n)]
    while frontier:
        x = frontier.pop()
        for g in gens:
            y = compose(g, x)
            if y not in elems:
                elems.add(y); frontier.append(y)
    return frozenset(elems)

def factor_orders(flag: List[FrozenSet[Perm]]) -> List[int]:
    return [len(flag[i + 1]) // len(flag[i]) for i in range(len(flag) - 1)]
