from __future__ import annotations
from typing import List, Optional, Tuple

CNF = List[Tuple[int, int]]  # (exponent, coefficient), exponents descending


def coeff_of(a: CNF, e: int) -> int:
    for (ee, cc) in a:
        if ee == e:
            return cc
    return 0


def below(a: CNF, e: int) -> CNF:
    return [(ee, cc) for (ee, cc) in a if ee < e]


def ordinal_sup(samples: List[CNF]) -> Optional[CNF]:
    """Exact supremum (limit) of a monotone increasing family of ordinals below
    omega^omega, inferred from finitely many samples. Returns None to denote the
    top ordinal omega^omega.

    Recursion on the leading exponent:
      * leading exponent grows across the tail   -> omega^omega (None);
      * coefficient of the stable leading exp grows -> omega^(e+1);
      * leading term fixed                        -> peel it off and recurse.
    """
    seq: List[CNF] = []
    for s in samples:
        if not seq or seq[-1] != s:
            seq.append(s)
    if not seq:
        return []
    if len(seq) == 1:
        return seq[0]
    a, b = seq[-2], seq[-1]
    ea = a[0][0] if a else -1
    eb = b[0][0] if b else -1
    if eb > ea:
        return None  # omega^omega
    e = eb
    if coeff_of(b, e) > coeff_of(a, e):
        return [(e + 1, 1)]
    c = coeff_of(b, e)
    tail = ordinal_sup([below(s, e) for s in seq])
    if tail is None:
        return None
    # head = omega^e * c ; prepend it to the recursively-computed remainder.
    return [(e, c)] + tail
