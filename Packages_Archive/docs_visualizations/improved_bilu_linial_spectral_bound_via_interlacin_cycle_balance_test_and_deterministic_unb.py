from __future__ import annotations
from typing import Dict, List, Sequence, Tuple

Edge = Tuple[int, int]


def cycle_sign_product(signs: Dict[Edge, int], cycle: Sequence[int]) -> int:
    """
    Product of edge signs along a closed cycle given as a vertex sequence
    v_0, v_1, ..., v_{L-1} (the closing edge v_{L-1}-v_0 is included).
    A cycle is balanced iff the product is +1, unbalanced iff -1.
    """
    prod = 1
    L = len(cycle)
    for t in range(L):
        u, v = cycle[t], cycle[(t + 1) % L]
        s = signs.get((u, v), signs.get((v, u)))
        if s is None:
            raise KeyError(f"missing sign for edge ({u},{v})")
        prod *= s
    return prod


def is_balanced(signs: Dict[Edge, int], cycle: Sequence[int]) -> bool:
    """True iff the cycle is balanced (sign product +1)."""
    return cycle_sign_product(signs, cycle) == 1


def unbalance_cycle(signs: Dict[Edge, int], cycle: Sequence[int]) -> Dict[Edge, int]:
    """
    Return a new signing that makes the given cycle unbalanced by flipping the
    sign of exactly one of its edges (the closing edge). If the cycle is already
    unbalanced the signing is returned unchanged.
    """
    new = dict(signs)
    if is_balanced(new, cycle):
        u, v = cycle[-1], cycle[0]
        key = (u, v) if (u, v) in new else (v, u)
        new[key] = -new[key]
    return new


if __name__ == "__main__":
    edges: Dict[Edge, int] = {(0, 1): 1, (1, 2): 1, (2, 3): 1, (3, 0): -1}
    cyc = [0, 1, 2, 3]
    print("sign product =", cycle_sign_product(edges, cyc), "-> balanced:", is_balanced(edges, cyc))
