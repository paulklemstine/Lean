from typing import Callable, List, Sequence

Leq = Callable[[int, int], bool]


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if leq(c, x):
        return "Above"
    if leq(x, c):
        return "Below"
    return "Incomp"


def transition_count(seq: Sequence[str]) -> int:
    """Changes between consecutive principal types; <= 2 by posType_mono + incomp_ord_convex."""
    principal: List[str] = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(principal) - 1) if principal[i] != principal[i + 1])


def neighbourhood_type_count(leq: Leq, x: int,
                             cover: Sequence[Sequence[int]]) -> int:
    """
    Distinct red neighbourhood types of x under a chain cover:
    (sum of per-chain transitions) + 1 self/diagonal boundary.
    Theorem nbhdTypeCount_le: result <= 2*len(cover) + 1.
    """
    total = sum(transition_count([pos_type(leq, x, c) for c in ch]) for ch in cover)
    return total + 1
