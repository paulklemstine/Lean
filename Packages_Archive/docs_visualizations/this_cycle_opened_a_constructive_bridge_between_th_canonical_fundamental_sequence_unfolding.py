from __future__ import annotations
from typing import List, Tuple

Ordinal = Tuple  # tuple of (exponent_ordinal, coefficient) pairs; () is 0


def is_successor(o: Ordinal) -> bool:
    return len(o) > 0 and len(o[-1][0]) == 0


def predecessor(o: Ordinal) -> Ordinal:
    terms = list(o)
    e, c = terms[-1]
    terms[-1] = (e, c - 1) if c > 1 else None
    return tuple(t for t in terms if t is not None)


def fundamental_sequence(o: Ordinal, n: int) -> Ordinal:
    """The n-th element of the canonical fundamental sequence of a LIMIT ordinal
    below epsilon-0: strictly below o, increasing in n, with supremum o."""
    head: List = list(o[:-1])
    e, c = o[-1]
    if is_successor(e):
        e_pred = predecessor(e)
        tail = [(e, c - 1)] if c > 1 else []
        if n > 0:
            tail.append((e_pred, n))
        return tuple(head + tail)
    e_seq = fundamental_sequence(e, n)
    tail = [(e, c - 1)] if c > 1 else []
    tail.append((e_seq, 1))
    return tuple(head + tail)
