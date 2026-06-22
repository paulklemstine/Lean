from typing import Callable, Dict, Hashable, Sequence

def canonical_weak_inverse(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> Callable[[Hashable], Hashable]:
    """Build the canonical weak inverse (analogue of Lean `Function.invFun f`).

    For each output value y produced by f, store the first input mapping to y.
    The returned g satisfies f(g(f(x))) = f(x) for every x, witnessing
    `exists_weakInverse` / `not_infoTheoreticOneWay`. Time O(|domain|),
    space O(|Im f|), lookup O(1).
    """
    if len(domain) == 0:
        raise ValueError("domain must be nonempty")
    table: Dict[Hashable, Hashable] = {}
    for x in domain:
        y = f(x)
        if y not in table:
            table[y] = x
    default: Hashable = domain[0]
    return lambda y: table.get(y, default)
