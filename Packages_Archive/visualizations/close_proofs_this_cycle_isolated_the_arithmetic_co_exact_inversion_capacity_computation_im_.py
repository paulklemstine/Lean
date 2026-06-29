from typing import Callable, Hashable, Sequence

def exact_inversion_capacity(domain: Sequence[Hashable],
                             f: Callable[[Hashable], Hashable]) -> int:
    """Return |Im f|: the max inputs any inverter recovers exactly (Thm 5.2/5.3)."""
    return len({f(x) for x in domain})
