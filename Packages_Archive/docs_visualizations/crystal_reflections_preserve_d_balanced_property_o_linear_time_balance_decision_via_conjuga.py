from typing import List, Iterator, Tuple


def conjugate(lam: List[int]) -> List[int]:
    """Return the transpose (conjugate) partition lambda'."""
    if not lam:
        return []
    return [sum(1 for p in lam if p > j) for j in range(lam[0])]


def cells(lam: List[int]) -> Iterator[Tuple[int, int]]:
    for i, part in enumerate(lam):
        for j in range(part):
            yield i, j


def is_d_balanced(lam: List[int], d: int, e: int) -> bool:
    """True iff every cell with e | hook has d | arm."""
    conj = conjugate(lam)
    for i, j in cells(lam):
        arm = lam[i] - (j + 1)
        leg = conj[j] - (i + 1)
        hook = arm + leg + 1
        if hook % e == 0 and arm % d != 0:
            return False
    return True


def is_leg_d_balanced(lam: List[int], d: int, e: int) -> bool:
    """True iff every cell with e | hook has d | leg."""
    conj = conjugate(lam)
    for i, j in cells(lam):
        arm = lam[i] - (j + 1)
        leg = conj[j] - (i + 1)
        hook = arm + leg + 1
        if hook % e == 0 and leg % d != 0:
            return False
    return True
