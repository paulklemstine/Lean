from typing import Callable, FrozenSet, List, Set

Pairing = Callable[[int, int], int]


def left_orthogonal(S: List[int], H: Set[int], pairing: Pairing) -> FrozenSet[int]:
    """H^perp = { s in S : <s, b> = 0 for all b in H }."""
    return frozenset(s for s in S if all(pairing(s, b) == 0 for b in H))


def right_orthogonal(B: List[int], T: Set[int], pairing: Pairing) -> FrozenSet[int]:
    """T^perp = { b in B : <s, b> = 0 for all s in T }."""
    return frozenset(b for b in B if all(pairing(s, b) == 0 for s in T))


def closure(S: List[int], B: List[int], H: Set[int], pairing: Pairing) -> FrozenSet[int]:
    """cl_B(H) = (H^perp)^perp, the smallest closed family containing H."""
    return right_orthogonal(B, set(left_orthogonal(S, H, pairing)), pairing)
