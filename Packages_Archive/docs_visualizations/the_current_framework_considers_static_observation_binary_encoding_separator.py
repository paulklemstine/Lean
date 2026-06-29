from typing import Callable, List, Set, Tuple

Predicate = Callable[[int], bool]


def bit_extraction_system(n: int) -> List[Predicate]:
    """Predicate i asks whether bit i of the state is set."""
    return [(lambda i: (lambda a: bool((a >> i) & 1)))(i) for i in range(n)]


def profile(preds: List[Predicate], state: int) -> Tuple[bool, ...]:
    return tuple(p(state) for p in preds)


def separates_all(n: int) -> bool:
    """True iff the bit-extraction system separates every element of Fin(2**n)."""
    preds = bit_extraction_system(n)
    profiles: Set[Tuple[bool, ...]] = {profile(preds, s) for s in range(2 ** n)}
    return len(profiles) == 2 ** n
