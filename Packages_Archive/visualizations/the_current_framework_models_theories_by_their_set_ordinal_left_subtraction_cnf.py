"""Algorithm A: ordinal left-subtraction in Cantor normal form (CNF).

Ordinals below omega^omega are stored as tuples of (exponent, coefficient)
terms with strictly decreasing natural exponents and positive coefficients.
Left-subtraction computes the unique c with b + c = a when b <= a (else 0),
matching Mathlib's Ordinal.sub. Linear in the number of CNF terms.
"""
from __future__ import annotations
from typing import List, Tuple

Term = Tuple[int, int]          # (exponent, coefficient)
CNF = Tuple[Term, ...]          # decreasing exponents, positive coefficients


def ord_lt(a: CNF, b: CNF) -> bool:
    """Strict ordinal order = lexicographic order on the term sequence."""
    return list(a) < list(b)


def ord_sub(a: CNF, b: CNF) -> CNF:
    """Ordinal left-subtraction: unique c with b + c = a (0 if a <= b)."""
    if not ord_lt(b, a):          # a <= b
        return ()
    al: List[Term] = list(a)
    bl: List[Term] = list(b)
    i = 0
    while i < len(bl):
        ea, ca = al[i]
        eb, cb = bl[i]
        if ea > eb:               # b absorbed by a larger leading power of omega
            return tuple(al[i:])
        # ea == eb (ea < eb impossible since b <= a)
        if ca > cb:
            return tuple([(ea, ca - cb)] + al[i + 1:])
        i += 1                    # equal terms cancel; advance
    return tuple(al[i:])


if __name__ == "__main__":
    w = ((1, 1),)                 # omega
    w1 = ((1, 1), (0, 1))         # omega + 1
    one = ((0, 1),)
    print("(w+1) - w =", ord_sub(w1, w))     # -> ((0, 1),) = 1
    print("(w+1) - 0 =", ord_sub(w1, ()))    # -> omega + 1
    print("w - 0     =", ord_sub(w, ()))     # -> omega
    print("1 - w     =", ord_sub(one, w))    # -> () = 0
