"""
Arithmetic on the Möbius Band: numerical demonstrations.

This self-contained script demonstrates, by direct computation:

  PART 1 -- The Möbius band M = (R x R)/((0,y) ~ (1,-y)).
    * the value map val(x, y) = y * (2x - 1) descends to M          [CONFIRMED]
    * the twist point [(0,-1)] = [(1,1)]                            [CONFIRMED]
    * coordinatewise + and * do NOT descend to M                    [REFUTED]
    * val(emb n) = sign(n): the embedding forgets the magnitude     [REFUTED]
    * emb is injective; [emb 1] != [emb -1]; image is unbounded     [REFUTED]
    * (1,0) = (0,0) in M, so the "zero divisor" witness collapses   [REFUTED]

  PART 2 -- The twist ring ZM = Z[t]/(t^2 - 1), realised as
            {(u,v) in Z^2 : u = v mod 2} via a + b t -> (a+b, a-b).
    * t^2 = 1, t is a unit, unit group = {1,-1,t,-t} = (Z/2)^2
    * norm N(a+bt) = a^2 - b^2 is multiplicative and detects units
    * zero divisors are exactly the elements of norm 0 (a = +-b)
    * no element has norm +-2; 2 is irreducible; every odd n splits
    * 6 = 2 (2+t)(2-t), -6 = (-1) 2 (2+t)(2-t), 0 = (1+t)(1-t)
    * no nontrivial idempotents, so ZM is not isomorphic to Z x Z

  PART 3 -- Sections of the Möbius line bundle: antiperiodic functions
            f(x+1) = -f(x).
    * the Z/2 grading:  odd*odd = even, even*odd = odd, even*even = even
    * holonomy f(x+n) = (-1)^n f(x), matching t^n in the twist ring
    * every continuous section has a zero in every window [a, a+1]
      (located numerically by bisection)

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Iterable, List, Sequence, Tuple

Point = Tuple[float, float]

EPS = 1e-12


# ----------------------------------------------------------------------------
# PART 1: the Möbius band
# ----------------------------------------------------------------------------


def moeb_related(p: Point, q: Point) -> bool:
    """True iff p ~ q in the Möbius band ((0,y) ~ (1,-y), else identity)."""
    if abs(p[0] - q[0]) < EPS and abs(p[1] - q[1]) < EPS:
        return True
    if abs(p[0]) < EPS and abs(q[0] - 1.0) < EPS and abs(q[1] + p[1]) < EPS:
        return True
    if abs(p[0] - 1.0) < EPS and abs(q[0]) < EPS and abs(q[1] + p[1]) < EPS:
        return True
    return False


def val(p: Point) -> float:
    """The proposed value of a point of the band: val(x, y) = y (2x - 1)."""
    x, y = p
    return y * (2.0 * x - 1.0)


def emb(n: int) -> Point:
    """The proposed embedding of Z: n -> (1/2 + 1/(2n), |n|).  emb(0) := (1/2, 0)."""
    if n == 0:
        return (0.5, 0.0)
    return (0.5 + 1.0 / (2.0 * n), float(abs(n)))


def sign(n: int) -> int:
    return (n > 0) - (n < 0)


def part1_moebius_band() -> None:
    print("=" * 78)
    print("PART 1 -- The Möbius band  M = (R x R)/((0,y) ~ (1,-y))")
    print("=" * 78)

    print("\n[1a] CONFIRMED: the value map val(x,y) = y(2x-1) descends to M.")
    for y in (-3.0, -1.0, 0.0, 0.5, 2.0, 7.25):
        p, q = (0.0, y), (1.0, -y)
        assert moeb_related(p, q)
        assert abs(val(p) - val(q)) < EPS
        print(f"     (0,{y:>5}) ~ (1,{-y:>5})   val = {val(p):>7.3f} = {val(q):>7.3f}")
    print("     -> the two sign reversals (twist and 2x-1) cancel exactly.")

    print("\n[1b] CONFIRMED: the twist point  [(0,-1)] = [(1,1)].")
    print(f"     related? {moeb_related((0.0, -1.0), (1.0, 1.0))}")

    print("\n[1c] REFUTED: coordinatewise addition does NOT descend.")
    p, q = (0.0, 1.0), (1.0, -1.0)
    print(f"     seam identity: [(0,1)] = [(1,-1)]?  {moeb_related(p, q)}")
    sp = (p[0] + p[0], p[1] + p[1])
    sq = (q[0] + q[0], q[1] + q[1])
    print(f"     (0,1)+(0,1)  = {sp}")
    print(f"     (1,-1)+(1,-1)= {sq}")
    print(f"     related?  {moeb_related(sp, sq)}   -> addition is ill defined on M")
    assert not moeb_related(sp, sq)

    print("\n[1d] REFUTED: coordinatewise multiplication does NOT descend.")
    mp = (p[0] * p[0], p[1] * p[1])
    mq = (q[0] * q[0], q[1] * q[1])
    print(f"     (0,1)*(0,1)  = {mp}")
    print(f"     (1,-1)*(1,-1)= {mq}")
    print(f"     related?  {moeb_related(mp, mq)}   -> multiplication is ill defined")
    assert not moeb_related(mp, mq)

    print("\n[1e] REFUTED: val(emb n) = sign(n); the magnitude is forgotten.")
    print("       n   emb(n)                      val(emb n)   sign(n)")
    for n in (-7, -3, -2, -1, 0, 1, 2, 3, 7, 100):
        e = emb(n)
        v = val(e)
        assert abs(v - sign(n)) < 1e-9
        print(f"     {n:>4}   ({e[0]:>8.5f}, {e[1]:>6.1f})   {v:>10.6f}   {sign(n):>6}")
    print("     -> val(emb 2) = val(emb 3): the system cannot tell 2 from 3.")

    print("\n[1f] REFUTED: 1 and -1 are NOT identified; emb is injective; image unbounded.")
    print(f"     emb( 1) = {emb(1)}     emb(-1) = {emb(-1)}")
    print(f"     related?  {moeb_related(emb(1), emb(-1))}  (seam needs OPPOSITE fibres)")
    assert not moeb_related(emb(1), emb(-1))
    pts = [emb(n) for n in range(-40, 41)]
    collisions = sum(
        1
        for i in range(len(pts))
        for j in range(i + 1, len(pts))
        if moeb_related(pts[i], pts[j])
    )
    print(f"     collisions among emb(-40..40): {collisions}  -> injective, no compactification")
    print(f"     sup-norm of emb(n) for n = 10, 100, 1000: "
          f"{max(abs(v) for v in emb(10))}, {max(abs(v) for v in emb(100))}, "
          f"{max(abs(v) for v in emb(1000))}   -> unbounded")

    print("\n[1g] REFUTED: the proposed zero-divisor witness collapses.")
    print(f"     (1,0)*(0,1) = {(1.0 * 0.0, 0.0 * 1.0)}")
    print(f"     but [(1,0)] = [(0,0)]?  {moeb_related((1.0, 0.0), (0.0, 0.0))}"
          "   (because -0 = 0)")
    in_image = any(moeb_related((1.0, 0.0), emb(n)) for n in range(-500, 501))
    print(f"     is (1,0) a Möbius integer?  {in_image}")
    assert moeb_related((1.0, 0.0), (0.0, 0.0)) and not in_image


# ----------------------------------------------------------------------------
# PART 2: the twist ring Z[t]/(t^2 - 1)
# ----------------------------------------------------------------------------


@dataclass(frozen=True)
class ZM:
    """The element a + b t of the twist ring Z[t]/(t^2 - 1)."""

    a: int
    b: int

    # --- ring operations -----------------------------------------------
    def __add__(self, other: "ZM") -> "ZM":
        return ZM(self.a + other.a, self.b + other.b)

    def __sub__(self, other: "ZM") -> "ZM":
        return ZM(self.a - other.a, self.b - other.b)

    def __neg__(self) -> "ZM":
        return ZM(-self.a, -self.b)

    def __mul__(self, other: "ZM") -> "ZM":
        return ZM(
            self.a * other.a + self.b * other.b,
            self.a * other.b + self.b * other.a,
        )

    # --- character coordinates (a+b, a-b) ------------------------------
    def chars(self) -> Tuple[int, int]:
        return (self.a + self.b, self.a - self.b)

    def norm(self) -> int:
        """N(a + b t) = a^2 - b^2 = (a+b)(a-b), the product of the two characters."""
        u, v = self.chars()
        return u * v

    def is_zero(self) -> bool:
        return self.a == 0 and self.b == 0

    def is_unit(self) -> bool:
        return self.norm() in (1, -1)

    def is_zero_divisor(self) -> bool:
        """Nonzero z with z w = 0 for some w != 0; equivalently N(z) = 0."""
        return self.norm() == 0

    def __str__(self) -> str:
        if self.b == 0:
            return f"{self.a}"
        if self.a == 0:
            return "t" if self.b == 1 else ("-t" if self.b == -1 else f"{self.b}t")
        sgn = "+" if self.b > 0 else "-"
        mag = abs(self.b)
        tail = "t" if mag == 1 else f"{mag}t"
        return f"({self.a} {sgn} {tail})"


ZERO = ZM(0, 0)
ONE = ZM(1, 0)
TW = ZM(0, 1)  # the twist t


def zm_product(factors: Sequence[ZM]) -> ZM:
    out = ONE
    for f in factors:
        out = out * f
    return out


def is_prime_int(n: int) -> bool:
    n = abs(n)
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    k = 3
    while k * k <= n:
        if n % k == 0:
            return False
        k += 2
    return True


def is_irreducible(z: ZM, search: int = 30) -> bool:
    """Decide irreducibility for small z by exhaustive search over small factors.

    Certified fast paths: |N(z)| prime  => irreducible (a factorisation would split
    a prime norm); N(z) = 4 => irreducible (norm +-2 is impossible).
    """
    if z.is_zero() or z.is_unit():
        return False
    n = z.norm()
    if is_prime_int(n):
        return True
    if abs(n) == 4:
        return True
    for a in range(-search, search + 1):
        for b in range(-search, search + 1):
            x = ZM(a, b)
            if x.is_unit() or x.is_zero():
                continue
            for c in range(-search, search + 1):
                for d in range(-search, search + 1):
                    y = ZM(c, d)
                    if y.is_unit() or y.is_zero():
                        continue
                    if x * y == z:
                        return False
    return True


def factor_integer_in_twist_ring(n: int) -> Tuple[ZM, List[ZM]]:
    """Factor the rational integer n in Z[t]/(t^2-1).

    Returns (unit, [irreducible factors]) with unit * prod(factors) = n.
    Zero is special: 0 = (1+t)(1-t), a nontrivial factorisation of zero.
    """
    if n == 0:
        return ONE, [ZM(1, 1), ZM(1, -1)]
    unit = ONE if n > 0 else ZM(-1, 0)
    m = abs(n)
    if m == 1:
        return ZM(n, 0), []
    factors: List[ZM] = []
    while m % 2 == 0:
        factors.append(ZM(2, 0))  # 2 is irreducible: N(2) = 4, and norm +-2 is impossible
        m //= 2
    p = 3
    while p * p <= m:
        while m % p == 0:
            k = (p - 1) // 2  # p = 2k + 1
            factors.append(ZM(k + 1, k))  # norm = p
            factors.append(ZM(k + 1, -k))  # norm = p
            m //= p
        p += 2
    if m > 1:
        k = (m - 1) // 2
        factors.append(ZM(k + 1, k))
        factors.append(ZM(k + 1, -k))
    return unit, factors


def part2_twist_ring() -> None:
    print("\n" + "=" * 78)
    print("PART 2 -- The twist ring  ZM = Z[t]/(t^2 - 1)")
    print("=" * 78)

    print("\n[2a] t^2 = 1, t is a unit of order 2, and the unit group is {1,-1,t,-t}.")
    print(f"     t*t = {TW * TW}     t == 1? {TW == ONE}    t == -1? {TW == -ONE}")
    units = [ZM(a, b) for a in range(-4, 5) for b in range(-4, 5) if ZM(a, b).is_unit()]
    print(f"     units with |a|,|b| <= 4:  {{{', '.join(str(u) for u in units)}}}")
    print("     -> the twist is a UNIT, hence never a prime. Orientation is a grading.")

    print("\n[2b] The norm N(a+bt) = a^2 - b^2 is multiplicative.")
    samples = [ZM(2, 1), ZM(3, -2), ZM(5, 4), ZM(1, 1), ZM(-7, 3)]
    for x in samples:
        for y in samples:
            assert (x * y).norm() == x.norm() * y.norm()
    print(f"     checked on all {len(samples)**2} products of "
          f"{', '.join(str(s) for s in samples)}   -- all consistent")

    print("\n[2c] Zero divisors are exactly the elements of norm 0, i.e. a = +-b.")
    print(f"     (1+t)(1-t) = {ZM(1,1) * ZM(1,-1)}   with 1+t != 0 and 1-t != 0")
    zds = [ZM(a, b) for a in range(-3, 4) for b in range(-3, 4)
           if not ZM(a, b).is_zero() and ZM(a, b).is_zero_divisor()]
    print(f"     nonzero zero divisors with |a|,|b| <= 3: "
          f"{', '.join(str(z) for z in zds)}")
    for z in zds:
        w = ZM(1, 1) if z.chars()[0] == 0 else ZM(1, -1)
        assert (z * w).is_zero()
    print("     -> annihilators: 1+t kills the chi_+ = 0 line, 1-t the chi_- = 0 line.")

    print("\n[2d] No element has norm +-2  (parity obstruction: u = v mod 2).")
    bad = [ZM(a, b) for a in range(-60, 61) for b in range(-60, 61)
           if abs(ZM(a, b).norm()) == 2]
    print(f"     elements with |N| = 2 and |a|,|b| <= 60:  {len(bad)}")
    assert not bad
    print("     -> hence 2 (norm 4) is IRREDUCIBLE in the twist ring.")

    print("\n[2e] Every odd integer splits:  2k+1 = ((k+1)+kt)((k+1)-kt).")
    for k in range(1, 8):
        n = 2 * k + 1
        x, y = ZM(k + 1, k), ZM(k + 1, -k)
        assert (x * y) == ZM(n, 0)
        tag = "irreducible" if is_prime_int(n) else "composite norm"
        print(f"     {n:>3} = {str(x):>10} * {str(y):>10}   N = {x.norm():>3}, {y.norm():>3}"
              f"   ({tag})")

    print("\n[2f] Classification: n in Z is irreducible in ZM  <=>  n = +-2.")
    print("       n   irreducible?")
    for n in (-4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6):
        flag = is_irreducible(ZM(n, 0), search=8)
        expect = n in (2, -2)
        assert flag == expect, (n, flag, expect)
        print(f"     {n:>3}   {str(flag):>5}   (expected {expect})")

    print("\n[2g] The conjecture's factorisation test, answered.")
    for n in (6, -6, 0):
        unit, facs = factor_integer_in_twist_ring(n)
        prod = unit * zm_product(facs)
        pieces = ([] if unit == ONE else [str(unit)]) + [str(f) for f in facs]
        rendered = " * ".join(pieces)
        assert prod == ZM(n, 0)
        print(f"     {n:>3} = {rendered}"
              f"    ({len(facs)} irreducible factor(s), unit {unit})")
    print("     -> 6 has THREE irreducible factors 2*(2+t)*(2-t), not two;")
    print("        -6 is the same product times the UNIT -1;")
    print("        0 = (1+t)(1-t) factors nontrivially -- impossible in Z.")

    print("\n[2h] The twist is not the sign:  6t is neither 6 nor -6.")
    six_t = TW * ZM(6, 0)
    print(f"     6t = {six_t}   chars {six_t.chars()};   "
          f"6 chars {ZM(6,0).chars()};   -6 chars {ZM(-6,0).chars()}")
    assert six_t != ZM(6, 0) and six_t != ZM(-6, 0)

    print("\n[2i] No nontrivial idempotents, so ZM is NOT isomorphic to Z x Z.")
    idem = [ZM(a, b) for a in range(-10, 11) for b in range(-10, 11)
            if ZM(a, b) * ZM(a, b) == ZM(a, b)]
    print(f"     solutions of e^2 = e with |a|,|b| <= 10: "
          f"{', '.join(str(e) for e in idem)}")
    assert {(e.a, e.b) for e in idem} == {(0, 0), (1, 0)}
    print("     (Z x Z has the idempotent (1,0); parity u = v mod 2 forbids it here.)")
    print("     Over Q the idempotents (1 +- t)/2 exist -- the obstruction is exactly 2.")

    print("\n[2j] Holonomy:  t^n = 1  <=>  n even.")
    powers = []
    cur = ONE
    for n in range(7):
        powers.append(f"t^{n} = {cur}")
        cur = cur * TW
    print("     " + ";  ".join(powers))


# ----------------------------------------------------------------------------
# PART 3: sections of the Möbius line bundle
# ----------------------------------------------------------------------------


def is_antiperiodic(f: Callable[[float], float], samples: Iterable[float]) -> bool:
    return all(abs(f(x + 1.0) + f(x)) < 1e-9 for x in samples)


def is_periodic(f: Callable[[float], float], samples: Iterable[float]) -> bool:
    return all(abs(f(x + 1.0) - f(x)) < 1e-9 for x in samples)


def bisect_zero(f: Callable[[float], float], a: float, steps: int = 60) -> float:
    """Locate a zero of a continuous antiperiodic f in [a, a+1] by bisection.

    Terminates because f(a+1) = -f(a), so the endpoint values always straddle 0.
    """
    lo, hi = a, a + 1.0
    flo, fhi = f(lo), f(hi)
    if abs(flo) < 1e-15:
        return lo
    if abs(fhi) < 1e-15:
        return hi
    for _ in range(steps):
        mid = 0.5 * (lo + hi)
        fmid = f(mid)
        if fmid == 0.0:
            return mid
        if (flo < 0.0) != (fmid < 0.0):
            hi, fhi = mid, fmid
        else:
            lo, flo = mid, fmid
    return 0.5 * (lo + hi)


def part3_sections() -> None:
    print("\n" + "=" * 78)
    print("PART 3 -- Sections of the Möbius line bundle:  f(x+1) = -f(x)")
    print("=" * 78)

    grid = [0.0, 0.13, 0.37, 0.5, 0.71, 0.99, 1.4, -0.6, 2.718]

    f = lambda x: math.cos(math.pi * x)                       # antiperiodic (odd)
    g = lambda x: math.sin(math.pi * x)                       # antiperiodic (odd)
    h = lambda x: 2.0 + math.cos(2.0 * math.pi * x)           # periodic (even)

    print("\n[3a] The Z/2 grading: odd*odd = even, even*odd = odd, even*even = even.")
    print(f"     f(x) = cos(pi x)          antiperiodic? {is_antiperiodic(f, grid)}")
    print(f"     g(x) = sin(pi x)          antiperiodic? {is_antiperiodic(g, grid)}")
    print(f"     h(x) = 2 + cos(2pi x)     periodic?     {is_periodic(h, grid)}")
    fg = lambda x: f(x) * g(x)
    hf = lambda x: h(x) * f(x)
    hh = lambda x: h(x) * h(x)
    print(f"     f*g periodic?     {is_periodic(fg, grid)}     (odd * odd = even)")
    print(f"     h*f antiperiodic? {is_antiperiodic(hf, grid)}     (even * odd = odd)")
    print(f"     h*h periodic?     {is_periodic(hh, grid)}     (even * even = even)")
    ff = lambda x: f(x) * f(x)
    print(f"     f*f antiperiodic? {is_antiperiodic(ff, grid)}    "
          "-> the odd part is NOT a ring")
    assert is_periodic(fg, grid) and is_antiperiodic(hf, grid) and not is_antiperiodic(ff, grid)

    print("\n[3b] Holonomy  f(x+n) = (-1)^n f(x), computed by t^n in the twist ring.")
    x0 = 0.234
    print("       n   f(x0+n)      (-1)^n f(x0)   t^n     match")
    tn = ONE
    for n in range(6):
        lhs = f(x0 + n)
        rhs = ((-1.0) ** n) * f(x0)
        assert abs(lhs - rhs) < 1e-12
        print(f"     {n:>3}   {lhs:>9.6f}   {rhs:>12.6f}   {str(tn):>4}    "
              f"{'yes' if (tn == ONE) == (n % 2 == 0) else 'no'}")
        tn = tn * TW

    print("\n[3c] Every continuous section vanishes in EVERY window [a, a+1].")
    wobbly = lambda x: (math.cos(math.pi * x) + 0.4 * math.cos(3.0 * math.pi * x)
                        + 0.25 * math.sin(5.0 * math.pi * x))
    print(f"     test section w(x) = cos(pi x) + 0.4 cos(3 pi x) + 0.25 sin(5 pi x) "
          f"-- antiperiodic? {is_antiperiodic(wobbly, grid)}")
    print("       window        located zero      w(zero)")
    for a in (-2.0, -0.5, 0.0, 0.7, 1.0, 3.3):
        z = bisect_zero(wobbly, a)
        assert a - 1e-9 <= z <= a + 1.0 + 1e-9 and abs(wobbly(z)) < 1e-9
        print(f"     [{a:>5.2f},{a+1:>5.2f}]   {z:>12.8f}   {wobbly(z):>12.2e}")
    print("     -> no nowhere-vanishing section exists: the bundle is nontrivial,")
    print("        and no antiperiodic function is invertible. All units are even.")

    print("\n[3d] Counting: [0, n] contains at least n zeros (one per unit window).")
    for n in (1, 3, 5, 8):
        zeros = [bisect_zero(wobbly, float(k)) for k in range(n)]
        assert all(abs(wobbly(z)) < 1e-9 for z in zeros)
        print(f"     n = {n}:  {len(zeros)} zeros found, e.g. "
              f"{', '.join(f'{z:.4f}' for z in zeros[:4])}"
              f"{' ...' if n > 4 else ''}")


def main() -> None:
    part1_moebius_band()
    part2_twist_ring()
    part3_sections()
    print("\n" + "=" * 78)
    print("All computations completed and all assertions passed.")
    print("Summary: the value map descends and the twist point is real; the induced")
    print("ring, the identification of +-1, the compactification, and the proposed")
    print("zero divisors all fail. The surviving structure is the twist ring")
    print("Z[t]/(t^2-1), where orientation is a UNIT of order two -- a grading,")
    print("not a prime -- with 6 = 2(2+t)(2-t), -6 = (-1)*2(2+t)(2-t), 0 = (1+t)(1-t).")
    print("=" * 78)


if __name__ == "__main__":
    main()
