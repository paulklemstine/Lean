from typing import FrozenSet, Set

Face = FrozenSet[int]
Complex = Set[Face]


def involution_certificate(coned: Complex, v: int) -> bool:
    """Verify the toggle F |-> F XOR {v} is a fixed-point-free, sign-reversing
    involution on the cone -- a summation-free witness that reducedEuler = 0.
    """
    av = frozenset({v})
    for F in coned:
        G = F ^ av                       # toggle apex membership
        if G not in coned:
            return False                 # ι maps the cone to itself
        if (F ^ av) ^ av != F:
            return False                 # ι is an involution
        if (-1) ** (len(G) + 1) != -((-1) ** (len(F) + 1)):
            return False                 # ι reverses sign
    return True
