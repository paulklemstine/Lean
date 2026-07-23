from typing import Callable, FrozenSet, List, Set, Tuple

Pairing = Callable[[int, int], int]


def left_orthogonal(S: List[int], H: Set[int], pairing: Pairing) -> FrozenSet[int]:
    return frozenset(s for s in S if all(pairing(s, b) == 0 for b in H))


def right_orthogonal(B: List[int], T: Set[int], pairing: Pairing) -> FrozenSet[int]:
    return frozenset(b for b in B if all(pairing(s, b) == 0 for s in T))


def closure(S: List[int], B: List[int], H: Set[int], pairing: Pairing) -> FrozenSet[int]:
    return right_orthogonal(B, set(left_orthogonal(S, H, pairing)), pairing)


def certify_equal_obstruction(
    S: List[int],
    B: List[int],
    pairing: Pairing,
    Hdesc: Set[int],
    Hunr: Set[int],
) -> Tuple[bool, str]:
    """
    Certify Hunr^perp = Hdesc^perp WITHOUT comparing the two orthogonals directly,
    by verifying the sandwich  Hdesc <= Hunr <= cl_B(Hdesc)  and invoking the
    sandwich comparison theorem.
    """
    clD = set(closure(S, B, Hdesc, pairing))
    if not Hdesc <= Hunr:
        return False, "descent classes are not contained in unramified classes"
    if not Hunr <= clD:
        return False, "unramified classes escape the closure of the descent classes"
    return True, "sandwich holds: Hunr^perp = Hdesc^perp by the comparison theorem"
