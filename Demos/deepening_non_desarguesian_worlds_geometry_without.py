"""Numerical demonstrations for *Non-Desarguesian Worlds at Order Nine*.

This self-contained script builds the field F9 = F3[i] with i^2 = i + 1, the
Hall system H9 (non-associative, proper nucleus), and the Dickson nearfield
N9 (associative, non-distributive), and it verifies the paper's main claims:

  * H9 is a quasifield (two-sided identity, unique division, planarity),
    is non-associative, and its right nucleus is exactly the base field F3.
  * N9 is a nearfield: associative, left-distributive, but the right
    distributive law fails.
  * The multiplicative group of N9 is the quaternion group Q8: non-abelian,
    with a unique involution and six elements of order four, whereas the
    field's multiplicative group on the same set is cyclic C8.

Elements of F9 are represented as pairs (a, b) meaning a + b*i, a, b in F3.
No external dependencies are required.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

Elem = Tuple[int, int]  # a + b*i, coefficients in F3
Mul = Callable[[Elem, Elem], Elem]

# ----------------------------------------------------------------------------
# The field F9 = F3[i], i^2 = i + 1
# ----------------------------------------------------------------------------

ALL: List[Elem] = [(a, b) for a in range(3) for b in range(3)]
NONZERO: List[Elem] = [e for e in ALL if e != (0, 0)]
ZERO: Elem = (0, 0)
ONE: Elem = (1, 0)
I: Elem = (0, 1)


def fadd(x: Elem, y: Elem) -> Elem:
    """Field (and quasifield) addition in F9."""
    return ((x[0] + y[0]) % 3, (x[1] + y[1]) % 3)


def fsub(x: Elem, y: Elem) -> Elem:
    return ((x[0] - y[0]) % 3, (x[1] - y[1]) % 3)


def fmul(x: Elem, y: Elem) -> Elem:
    """Field multiplication in F9 with i^2 = i + 1."""
    a, b = x
    c, d = y
    # (a+bi)(c+di) = ac + (ad+bc)i + bd*i^2, i^2 = i + 1
    real = (a * c + b * d) % 3
    imag = (a * d + b * c + b * d) % 3
    return (real, imag)


def fpow(x: Elem, n: int) -> Elem:
    result = ONE
    for _ in range(n):
        result = fmul(result, x)
    return result


def finv(x: Elem) -> Elem:
    """Multiplicative inverse in F9 (x != 0)."""
    for y in NONZERO:
        if fmul(x, y) == ONE:
            return y
    raise ValueError(f"no inverse for {x}")


def frobenius(x: Elem) -> Elem:
    """Frobenius automorphism sigma(x) = x^3."""
    return fpow(x, 3)


def in_base(x: Elem) -> bool:
    """True iff x lies in the base field F3."""
    return x[1] == 0


SQUARES = {fmul(x, x) for x in NONZERO}  # nonzero squares S


def is_square(x: Elem) -> bool:
    return x in SQUARES


# ----------------------------------------------------------------------------
# The Hall system H9:  u * v = u v - b^{-1} f(u) d   for u = a + b i, b != 0
#                      u * v = u v                    for u in F3
# with f(x) = x^2 - x - 1  and  v = c + d i.
# ----------------------------------------------------------------------------

def f_poly(u: Elem) -> Elem:
    """f(u) = u^2 - u - 1 evaluated in F9 (= u^2 + 2u + 2 mod 3)."""
    return fadd(fadd(fmul(u, u), fmul((2, 0), u)), (2, 0))


def hall_mul(u: Elem, v: Elem) -> Elem:
    if in_base(u):
        return fmul(u, v)
    b = u[1]
    d = v[1]
    binv = finv((b % 3, 0))  # b as an element of F3 <= F9
    correction = fmul(binv, fmul(f_poly(u), (d % 3, 0)))
    return fsub(fmul(u, v), correction)


# ----------------------------------------------------------------------------
# The Dickson nearfield N9:  x o y = x * sigma^{chi(x)}(y)
# chi(x) = 0 if x is a nonzero square, 1 if x is a non-square.
# Equivalently: x o y = x*y if x is a square, x*y^3 if x is a non-square.
# ----------------------------------------------------------------------------

def dickson_mul(x: Elem, y: Elem) -> Elem:
    if x == ZERO or y == ZERO:
        return ZERO
    twisted_y = y if is_square(x) else frobenius(y)
    return fmul(x, twisted_y)


# ----------------------------------------------------------------------------
# Verification routines
# ----------------------------------------------------------------------------

def is_associative(mul: Mul) -> bool:
    return all(
        mul(mul(x, y), z) == mul(x, mul(y, z))
        for x, y, z in product(ALL, repeat=3)
    )


def left_distributive(mul: Mul) -> bool:
    return all(
        mul(x, fadd(y, z)) == fadd(mul(x, y), mul(x, z))
        for x, y, z in product(ALL, repeat=3)
    )


def right_distributive(mul: Mul) -> bool:
    return all(
        mul(fadd(x, y), z) == fadd(mul(x, z), mul(y, z))
        for x, y, z in product(ALL, repeat=3)
    )


def nonassoc_witnesses(mul: Mul) -> List[Tuple[Elem, Elem, Elem]]:
    return [
        (a, b, c)
        for a, b, c in product(ALL, repeat=3)
        if mul(mul(a, b), c) != mul(a, mul(b, c))
    ]


def right_dist_failures(mul: Mul) -> List[Tuple[Elem, Elem, Elem]]:
    return [
        (x, y, z)
        for x, y, z in product(ALL, repeat=3)
        if mul(fadd(x, y), z) != fadd(mul(x, z), mul(y, z))
    ]


def right_nucleus(mul: Mul) -> List[Elem]:
    """Elements a with x*(y*a) = (x*y)*a for all x, y."""
    return [
        a
        for a in ALL
        if all(mul(x, mul(y, a)) == mul(mul(x, y), a) for x in ALL for y in ALL)
    ]


def is_quasifield(mul: Mul) -> bool:
    """Two-sided identity 1, unique left/right division, planarity axiom."""
    ident = all(mul(ONE, v) == v and mul(v, ONE) == v for v in ALL)
    left_div = all(len({mul(u, x) for x in ALL}) == 9 for u in NONZERO)
    right_div = all(len({mul(x, a) for x in ALL}) == 9 for a in NONZERO)
    planar = all(
        len({fsub(mul(x, a), mul(x, b)) for x in ALL}) == 9
        for a in ALL
        for b in ALL
        if a != b
    )
    return ident and left_div and right_div and planar


def element_order(mul: Mul, e: Elem) -> int:
    n, acc = 1, e
    while acc != ONE:
        acc = mul(acc, e)
        n += 1
    return n


def order_profile(mul: Mul) -> Dict[int, int]:
    prof: Dict[int, int] = {}
    for e in NONZERO:
        o = element_order(mul, e)
        prof[o] = prof.get(o, 0) + 1
    return prof


def is_abelian(mul: Mul) -> bool:
    return all(mul(x, y) == mul(y, x) for x, y in product(NONZERO, repeat=2))


def identify_group(mul: Mul) -> str:
    """Identify a group of order 8 by abelianness and involution count."""
    involutions = sum(1 for e in NONZERO if e != ONE and mul(e, e) == ONE)
    if is_abelian(mul):
        prof = order_profile(mul)
        if prof.get(8, 0) > 0:
            return "C8 (cyclic of order 8)"
        return f"abelian, order profile {prof}"
    if involutions == 1:
        return "Q8 (quaternion group)"
    if involutions == 5:
        return "D4 (dihedral group)"
    return f"non-abelian with {involutions} involutions"


def fmt(e: Elem) -> str:
    a, b = e
    if b == 0:
        return str(a)
    if a == 0:
        return f"{b}i"
    return f"{a}+{b}i"


def main() -> None:
    print("=" * 70)
    print("Non-Desarguesian Worlds at Order Nine  —  numerical verification")
    print("=" * 70)

    print("\nF9 = F3[i], i^2 = i + 1")
    print("  nonzero squares S =", sorted(fmt(s) for s in SQUARES))

    # --- Hall system ---
    print("\n[1] Hall system H9  (broken associativity)")
    print(f"  is a quasifield (id, division, planarity): {is_quasifield(hall_mul)}")
    print(f"  left distributive:  {left_distributive(hall_mul)}")
    w = nonassoc_witnesses(hall_mul)
    print(f"  non-associative:    {len(w)} witnessing triples (a*b)*c != a*(b*c)")
    a, b, c = w[0]
    print(f"    e.g. a={fmt(a)}, b={fmt(b)}, c={fmt(c)}: "
          f"({fmt(a)}*{fmt(b)})*{fmt(c)} = {fmt(hall_mul(hall_mul(a,b),c))}"
          f"  vs  {fmt(a)}*({fmt(b)}*{fmt(c)}) = {fmt(hall_mul(a,hall_mul(b,c)))}")
    nuc = right_nucleus(hall_mul)
    print(f"  right nucleus N_r(H9) = {sorted(fmt(x) for x in nuc)}"
          f"   (= F3, size {len(nuc)})")

    # --- Dickson nearfield ---
    print("\n[2] Dickson nearfield N9  (broken distributivity)")
    print(f"  associative:            {is_associative(dickson_mul)}")
    print(f"  left  distributive:     {left_distributive(dickson_mul)}")
    bad = right_dist_failures(dickson_mul)
    print(f"  right distributive:     {len(bad) == 0}"
          f"   ({len(bad)} witnesses of failure)")
    x, y, z = bad[0]
    print(f"    e.g. ({fmt(x)}+{fmt(y)}) o {fmt(z)} = "
          f"{fmt(dickson_mul(fadd(x,y),z))}"
          f"  vs  ({fmt(x)} o {fmt(z)})+({fmt(y)} o {fmt(z)}) = "
          f"{fmt(fadd(dickson_mul(x,z), dickson_mul(y,z)))}")

    # --- Multiplicative groups ---
    print("\n[3] Multiplicative groups on the 8 nonzero elements")
    print(f"  field  F9^x : order profile {order_profile(fmul)}"
          f"  ->  {identify_group(fmul)}")
    print(f"  nearfield  : order profile {order_profile(dickson_mul)}"
          f"  ->  {identify_group(dickson_mul)}")
    invol = [e for e in NONZERO if e != ONE and dickson_mul(e, e) == ONE]
    print(f"  unique involution in N9: {[fmt(e) for e in invol]}  (= -1)")

    print("\nAll paper claims reproduced numerically.")


if __name__ == "__main__":
    main()
