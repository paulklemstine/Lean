from typing import Callable, TypeVar

L = TypeVar("L")
M = TypeVar("M")


def verify_iso(
    succ1: Callable[[L], list[L]],
    succ2: Callable[[M], list[M]],
    phi: Callable[[L], M],
    root1: L,
    root2: M,
    reachable: list[L],
) -> bool:
    """Certify a generating-tree isomorphism by checking the local hypotheses.

    Returns True iff phi(root1) == root2 and, for every label a in `reachable`,
    the intertwining identity  succ2(phi(a)) == [phi(x) for x in succ1(a)]
    holds. By the refined-equinumerosity theorem, a True result guarantees that
    counts and every phi-compatible statistic agree at all depths.
    """
    if phi(root1) != root2:
        return False
    for a in reachable:
        if succ2(phi(a)) != [phi(x) for x in succ1(a)]:
            return False
    return True
