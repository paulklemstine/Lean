from typing import Callable, Dict, Hashable, Sequence

def inv_fun(domain: Sequence[Hashable],
            f: Callable[[Hashable], Hashable]) -> Callable[[Hashable], Hashable]:
    """Canonical weak inverter invFun f (lookup table, first writer wins)."""
    if not domain:
        raise ValueError("domain must be nonempty")
    table: Dict[Hashable, Hashable] = {}
    for x in domain:
        y = f(x)
        if y not in table:
            table[y] = x
    default = domain[0]
    return lambda y: table.get(y, default)
