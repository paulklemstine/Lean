"""
demo.py - Numerical demonstrations for:

  "An Intersection-Form Classification Pipeline via Direct Sums of
   Binary Self-Dual Codes"

Everything is self-contained: binary vectors are tuples of 0/1 ints, a code is a
frozenset of such tuples. We demonstrate, by direct computation:

  * weight additivity            wt(a || b) = wt(a) + wt(b)
  * inner-product block diagonal <a||b, c||d> = <a,c> + <b,d>
  * cardinality multiplicativity |C (+) D| = |C| * |D|
  * closure of double-evenness   under (+)
  * closure of self-duality      under (+)         <-- headline
  * Gleason length theorem        via |C| = (1+i)^n
  * the headline application      Hamming (+) Hamming (mod-2 shadow of E8 (+) E8)

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
from itertools import product
from typing import Dict, FrozenSet, Tuple

Vector = Tuple[int, ...]
Code = FrozenSet[Vector]


# ---------------------------------------------------------------------------
# Core binary-code primitives
# ---------------------------------------------------------------------------
def wt(v: Vector) -> int:
    """Hamming weight: number of nonzero coordinates."""
    return sum(1 for x in v if x == 1)


def ip(x: Vector, y: Vector) -> int:
    """Binary inner product in Z/2: parity of the overlap."""
    return sum(a * b for a, b in zip(x, y)) % 2


def concat(a: Vector, b: Vector) -> Vector:
    """Coordinate concatenation a || b."""
    return a + b


def left_part(z: Vector, m: int) -> Vector:
    """First m coordinates of z."""
    return z[:m]


def right_part(z: Vector, m: int) -> Vector:
    """Coordinates of z after the first m."""
    return z[m:]


def is_doubly_even(v: Vector) -> bool:
    """A vector is doubly even when 4 | wt(v)."""
    return wt(v) % 4 == 0


def code_is_doubly_even(C: Code) -> bool:
    return all(is_doubly_even(v) for v in C)


def code_is_self_dual(C: Code, n: int) -> bool:
    """C is self-dual iff for every x in F_2^n,
    (x in C) <-> (x orthogonal to all of C)."""
    for x in product((0, 1), repeat=n):
        orth = all(ip(x, y) == 0 for y in C)
        if (x in C) != orth:
            return False
    return True


def direct_sum(C: Code, D: Code) -> Code:
    """C (+) D = { a || b : a in C, b in D }."""
    return frozenset(concat(a, b) for a in C for b in D)


def weight_enumerator(C: Code) -> Dict[int, int]:
    """Map weight -> number of codewords of that weight."""
    enum: Dict[int, int] = {}
    for v in C:
        enum[wt(v)] = enum.get(wt(v), 0) + 1
    return dict(sorted(enum.items()))


# ---------------------------------------------------------------------------
# The extended Hamming [8,4,4] code (mod-2 shadow of E8)
# ---------------------------------------------------------------------------
HAMMING_GEN = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def build_hamming() -> Code:
    """All 2^4 = 16 linear combinations of the generator rows."""
    words = set()
    for coeffs in product((0, 1), repeat=4):
        acc = (0,) * 8
        for c, g in zip(coeffs, HAMMING_GEN):
            if c:
                acc = tuple((a + b) % 2 for a, b in zip(acc, g))
        words.add(acc)
    return frozenset(words)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_weight_and_ip(C: Code, D: Code, m: int, n: int) -> None:
    print("=" * 70)
    print("Weight additivity and inner-product block-diagonality")
    print("=" * 70)
    ok_wt, ok_ip = True, True
    for a, c in product(C, C):
        for b, d in product(D, D):
            ab, cd = concat(a, b), concat(c, d)
            if wt(ab) != wt(a) + wt(b):
                ok_wt = False
            if ip(ab, cd) != (ip(a, c) + ip(b, d)) % 2:
                ok_ip = False
    print(f"  wt(a||b) = wt(a)+wt(b)             : {ok_wt}")
    print(f"  <a||b,c||d> = <a,c>+<b,d> (mod 2)  : {ok_ip}")


def demo_cardinality(C: Code, D: Code) -> None:
    print("=" * 70)
    print("Cardinality multiplicativity  |C (+) D| = |C| * |D|")
    print("=" * 70)
    CD = direct_sum(C, D)
    print(f"  |C| = {len(C)},  |D| = {len(D)}")
    print(f"  |C (+) D| = {len(CD)}   (predicted {len(C) * len(D)})")
    assert len(CD) == len(C) * len(D)


def demo_closure(C: Code, D: Code, m: int, n: int) -> None:
    print("=" * 70)
    print("Closure of double-evenness and self-duality under (+)")
    print("=" * 70)
    CD = direct_sum(C, D)
    print(f"  C  doubly even / self-dual : "
          f"{code_is_doubly_even(C)} / {code_is_self_dual(C, m)}")
    print(f"  D  doubly even / self-dual : "
          f"{code_is_doubly_even(D)} / {code_is_self_dual(D, n)}")
    print(f"  C (+) D doubly even        : {code_is_doubly_even(CD)}")
    print(f"  C (+) D self-dual          : {code_is_self_dual(CD, m + n)}")


def demo_gleason(C: Code, n: int) -> None:
    print("=" * 70)
    print("Gleason master identity  |C| = (1 + i)^n  and  8 | n")
    print("=" * 70)
    lhs = complex(len(C), 0)
    rhs = (1 + 1j) ** n
    print(f"  |C|        = {lhs}")
    print(f"  (1 + i)^{n:<2} = {rhs}")
    print(f"  identity holds (within 1e-9) : {abs(lhs - rhs) < 1e-9}")
    print(f"  length n = {n},  8 | n       : {n % 8 == 0}")
    # show the spiral: only multiples of 8 land on the positive real axis
    print("  powers (1+i)^r for r=0..8 (only r=0 is positive real):")
    for r in range(9):
        z = (1 + 1j) ** r
        tag = "  <-- positive real" if (abs(z.imag) < 1e-9 and z.real > 0) else ""
        print(f"    r={r}: {z:.3g}{tag}")


def demo_headline() -> None:
    print("#" * 70)
    print("# HEADLINE:  Hamming (+) Hamming   = mod-2 shadow of  E8 (+) E8")
    print("#" * 70)
    H = build_hamming()
    print(f"\nExtended Hamming [8,4,4]:")
    print(f"  |H| = {len(H)}")
    print(f"  weight enumerator = {weight_enumerator(H)}   (i.e. 1 + 14x^4 + x^8)")
    print(f"  doubly even / self-dual = "
          f"{code_is_doubly_even(H)} / {code_is_self_dual(H, 8)}")

    H16 = direct_sum(H, H)
    print(f"\nHamming16 = H (+) H:")
    print(f"  number of codewords = {len(H16)}   (predicted 16*16 = 256)")
    print(f"  doubly even         = {code_is_doubly_even(H16)}")
    print(f"  self-dual           = {code_is_self_dual(H16, 16)}")
    print(f"  length 16 divisible by 8 = {16 % 8 == 0}")
    print(f"  weight enumerator   = {weight_enumerator(H16)}")
    print(f"    (predicted (1+14x^4+x^8)^2 = "
          f"1 + 28x^4 + 198x^8 + 28x^12 + x^16)")

    # Verify Gleason master identity on both
    demo_gleason(H, 8)
    print()
    demo_gleason(H16, 16)


def main() -> None:
    # Smallest nontrivial doubly-even self-dual code: the repetition pair {00, 11}?
    # That is self-dual of length 2 but NOT doubly even (wt 11 = 2). The smallest
    # doubly-even self-dual code is the Hamming [8,4,4]. So we demonstrate the
    # generic closure laws directly on Hamming, then on Hamming (+) Hamming.
    H = build_hamming()
    demo_weight_and_ip(H, H, 8, 8)
    demo_cardinality(H, H)
    demo_closure(H, H, 8, 8)
    print()
    demo_headline()


if __name__ == "__main__":
    main()
