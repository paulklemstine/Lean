from typing import List, TypeVar, Callable

G = TypeVar("G")


def monodromy(t: List[G], mul: Callable[[G, G], G], one: G) -> G:
    """
    Total monodromy of a multiplicative figure over an arbitrary abelian
    group described by its product `mul` and identity `one`.

    Works uniformly for the reals (mul = *, one = 1) and for Z/2 written
    multiplicatively; runs in O(n) group operations.
    """
    acc = one
    for x in t:
        acc = mul(acc, x)
    return acc


def is_realizable(t: List[G], mul: Callable[[G, G], G], one: G,
                  eq: Callable[[G, G], bool]) -> bool:
    """Realizable iff the total monodromy is the group identity."""
    return eq(monodromy(t, mul, one), one)
