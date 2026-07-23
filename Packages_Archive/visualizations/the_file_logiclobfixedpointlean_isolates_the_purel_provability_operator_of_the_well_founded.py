from typing import FrozenSet

Prop = FrozenSet[int]


def box(s: Prop, n: int) -> Prop:
    """Provability operator of the frame (N, <): n proves S iff every m < n is in S."""
    return frozenset(k for k in range(n) if all(m in s for m in range(k)))


def loeb_fixed_point(a: Prop, n: int) -> Prop:
    """Compute box(box A => A); equals box A by the de Jongh-Sambin theorem."""
    universe = frozenset(range(n))
    box_a = box(a, n)
    himp = (universe - box_a) | a          # box A => A  (Boolean implication)
    return box(himp, n)
