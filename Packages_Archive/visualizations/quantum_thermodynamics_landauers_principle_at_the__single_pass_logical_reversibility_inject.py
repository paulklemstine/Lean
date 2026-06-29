from typing import Callable, Hashable, Sequence

def is_reversible(f: Callable[[Hashable], Hashable],
                  domain: Sequence[Hashable]) -> bool:
    """True iff f is injective on `domain` (logically reversible)."""
    seen: set = set()
    for x in domain:
        y = f(x)
        if y in seen:
            return False
        seen.add(y)
    return True
