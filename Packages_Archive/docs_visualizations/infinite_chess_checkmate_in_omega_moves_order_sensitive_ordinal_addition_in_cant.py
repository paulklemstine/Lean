from __future__ import annotations
from typing import List, Tuple

# Ordinals below omega^omega in Cantor normal form: strictly-descending
# lists of (exponent, coefficient) pairs.
CNF = List[Tuple[int, int]]


def ordinal_add(a: CNF, b: CNF) -> CNF:
    """Ordinal addition a + b (order-sensitive) for ordinals < omega^omega.

    Rule: in a + b, every term of a whose exponent is strictly below the leading
    exponent of b is absorbed; a term of a equal to b's leading exponent merges
    its coefficient additively.
    """
    if not b:
        return list(a)
    if not a:
        return list(b)
    lead_b_exp = b[0][0]
    kept = [(e, c) for (e, c) in a if e > lead_b_exp]
    same = [c for (e, c) in a if e == lead_b_exp]
    result: CNF = list(kept)
    if same:
        result.append((lead_b_exp, same[0] + b[0][1]))
        result.extend(b[1:])
    else:
        result.extend(b)
    return result


def ordinal_mul_nat(a: CNF, k: int) -> CNF:
    """Right multiplication of an ordinal by a natural number: a * k."""
    out: CNF = []
    for _ in range(k):
        out = ordinal_add(out, a)
    return out
