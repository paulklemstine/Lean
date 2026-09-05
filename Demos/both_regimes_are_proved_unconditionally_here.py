"""
Numerical demonstration of the two-regime 2-torsion law for the quadratic twist
family  E_{a,d} : y^2 = x^3 - a d^2 x  over F_p, and of the regime-independent
summed 3-division count for the j = 0 family  C_b : y^2 = x^3 + b.

Results demonstrated
--------------------
1.  Local two-regime count.
        #E_c(F_p)[2] = 4  if c is a nonzero square mod p,
                     = 2  if c is a non-square mod p.

2.  Twist invariance.  a*d^2 is a square iff a is; hence the whole twist family
    lies in a single regime.

3.  Summed two-regime law.
        Sigma_a(p) = sum_{d != 0} #E_{a,d}(F_p)[2]
                   = 4(p-1)  if a is a square mod p, else 2(p-1).

4.  Reciprocity criteria.
        a =  3 : split  <=>  p = 1, 11 (mod 12)
        a =  2 : split  <=>  p = 1,  7 (mod 8)
        a = -1 : split  <=>  p = 1      (mod 4)

5.  Klein four structure: in the split regime the four 2-torsion points are
        O, (0,0), (s,0), (-s,0)   with s^2 = c,
    and every one of them satisfies P + P = O  (exponent two), so the group is
    Z/2 x Z/2 and 4 divides #E_c(F_p) by Lagrange.

6.  Regime-independent 3-division count.
        sum_{b != 0} #{x in F_p : 3x^4 + 12bx = 0} = 2(p-1)
    for every prime p != 2, 3, although the individual terms are constantly 2
    when p = 2 (mod 3) and jump between 1 and 4 when p = 1 (mod 3).

Everything below is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from typing import Dict, List, Optional, Tuple

Point = Optional[Tuple[int, int]]  # None is the point at infinity O


# ---------------------------------------------------------------------------
# Basic finite-field utilities
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for small n)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def primes_up_to(limit: int) -> List[int]:
    """All primes p with 2 <= p <= limit, by a simple sieve."""
    sieve = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) in {-1, 0, 1}, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def is_square_mod(a: int, p: int) -> bool:
    """True iff a is a square in F_p (0 counts as a square)."""
    return legendre_symbol(a, p) >= 0


def sqrt_mod(a: int, p: int) -> Optional[int]:
    """A square root of a mod p, or None if a is a non-residue (Tonelli-Shanks)."""
    a %= p
    if a == 0:
        return 0
    if legendre_symbol(a, p) == -1:
        return None
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    # Tonelli-Shanks
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while legendre_symbol(z, p) != -1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(a, q, p), pow(a, (q + 1) // 2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = (t2 * t2) % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c = i, (b * b) % p
        t, r = (t * c) % p, (r * b) % p
    return r


# ---------------------------------------------------------------------------
# The curve  E_c : y^2 = x^3 - c x  over F_p
# ---------------------------------------------------------------------------

def curve_points(c: int, p: int) -> List[Point]:
    """All F_p-points of y^2 = x^3 - c x, including the point at infinity."""
    squares: Dict[int, List[int]] = {}
    for y in range(p):
        squares.setdefault((y * y) % p, []).append(y)
    pts: List[Point] = [None]
    for x in range(p):
        rhs = (x * x % p * x - c * x) % p
        for y in squares.get(rhs, []):
            pts.append((x, y))
    return pts


def two_torsion_points(c: int, p: int) -> List[Point]:
    """The 2-torsion subgroup of E_c(F_p): O together with the (x, 0)."""
    pts: List[Point] = [None]
    for x in range(p):
        if (x * x % p * x - c * x) % p == 0:
            pts.append((x, 0))
    return pts


def card_two_torsion(c: int, p: int) -> int:
    """|E_c(F_p)[2]| computed by brute force."""
    return len(two_torsion_points(c, p))


def predicted_card_two_torsion(c: int, p: int) -> int:
    """The theoretical value: 4 if c is a nonzero square, else 2."""
    if c % p == 0:
        raise ValueError("c must be nonzero mod p")
    return 4 if is_square_mod(c, p) else 2


def summed_two_torsion(a: int, p: int) -> int:
    """Sigma_a(p) = sum over d in F_p^x of |E_{a d^2}(F_p)[2]|."""
    return sum(card_two_torsion(a * d * d % p, p) for d in range(1, p))


def predicted_summed_two_torsion(a: int, p: int) -> int:
    """The theoretical value of Sigma_a(p): 4(p-1) if a is a square, else 2(p-1)."""
    return (4 if is_square_mod(a, p) else 2) * (p - 1)


# ---------------------------------------------------------------------------
# The 3-division polynomial of  C_b : y^2 = x^3 + b
# ---------------------------------------------------------------------------

def psi3_root_count(b: int, p: int) -> int:
    """#{x in F_p : 3x^4 + 12 b x = 0}, by direct evaluation."""
    return sum(1 for x in range(p) if (3 * pow(x, 4, p) + 12 * b * x) % p == 0)


def summed_psi3_root_count(p: int) -> int:
    """sum over b in F_p^x of the number of roots of the 3-division polynomial."""
    return sum(psi3_root_count(b, p) for b in range(1, p))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_local_dichotomy(p: int = 13) -> None:
    print(f"\n[1] Local two-regime count for  y^2 = x^3 - c x  over F_{p}")
    print("    c   square?   |E_c[2]|   predicted   2-torsion points")
    for c in range(1, p):
        pts = two_torsion_points(c, p)
        shown = ", ".join("O" if q is None else f"({q[0]},{q[1]})" for q in pts)
        sq = "yes" if is_square_mod(c, p) else "no "
        pred = predicted_card_two_torsion(c, p)
        flag = "OK" if len(pts) == pred else "MISMATCH"
        print(f"   {c:2d}     {sq}        {len(pts)}          {pred}      {shown}   {flag}")


def demo_twist_invariance(p: int = 17, a: int = 3) -> None:
    print(f"\n[2] Twist invariance over F_{p} with a = {a}: "
          f"a is a {'square' if is_square_mod(a, p) else 'non-square'}")
    row = []
    for d in range(1, p):
        c = a * d * d % p
        row.append(f"d={d}: c={c:2d} -> |E[2]|={card_two_torsion(c, p)}")
    for i in range(0, len(row), 4):
        print("    " + " | ".join(row[i:i + 4]))
    counts = {card_two_torsion(a * d * d % p, p) for d in range(1, p)}
    print(f"    distinct 2-torsion orders across the family: {sorted(counts)}"
          "   (a single value: the family is uniform)")


def demo_summed_law(a: int = 3, limit: int = 60) -> None:
    print(f"\n[3] Summed two-regime law for a = {a}")
    print("      p   p mod 12   regime      Sigma_a(p)   predicted   4|(#E)?")
    for p in primes_up_to(limit):
        if p in (2, 3):
            continue
        actual = summed_two_torsion(a, p)
        pred = predicted_summed_two_torsion(a, p)
        regime = "split    " if is_square_mod(a, p) else "non-split"
        total = len(curve_points(a % p, p))
        div4 = "yes" if total % 4 == 0 else "no "
        flag = "OK" if actual == pred else "MISMATCH"
        print(f"    {p:3d}      {p % 12:2d}      {regime}   {actual:6d}      "
              f"{pred:6d}     {div4}   {flag}")


def demo_reciprocity_criteria(limit: int = 120) -> None:
    print("\n[4] Reciprocity criteria: congruence predicts the regime exactly")
    print("      p   3 sq?  p%12 in {1,11}?   2 sq?  p%8 in {1,7}?   -1 sq?  p%4=1?")
    for p in primes_up_to(limit):
        if p in (2, 3):
            continue
        s3, c3 = is_square_mod(3, p), p % 12 in (1, 11)
        s2, c2 = is_square_mod(2, p), p % 8 in (1, 7)
        sm, cm = is_square_mod(p - 1, p), p % 4 == 1
        ok = "OK" if (s3 == c3 and s2 == c2 and sm == cm) else "MISMATCH"
        print(f"    {p:3d}    {str(s3):5s}      {str(c3):5s}       "
              f"{str(s2):5s}     {str(c2):5s}       {str(sm):5s}   {str(cm):5s}  {ok}")


def demo_klein_four(p: int = 13, c: int = 3) -> None:
    print(f"\n[5] Klein four structure of E_{c}(F_{p})[2]")
    s = sqrt_mod(c, p)
    if s is None:
        print(f"    {c} is a non-square mod {p}: the 2-torsion is "
              f"{{O, (0,0)}} of order 2.")
        return
    pts = two_torsion_points(c, p)
    print(f"    sqrt({c}) mod {p} = {s};  predicted points: "
          f"O, (0,0), ({s},0), ({(-s) % p},0)")
    print(f"    brute-force points: "
          + ", ".join("O" if q is None else f"({q[0]},{q[1]})" for q in pts))
    print(f"    order = {len(pts)}; every element is its own inverse "
          "(y = -y since y = 0), so the group has exponent 2 and is Z/2 x Z/2.")
    total = len(curve_points(c, p))
    print(f"    #E(F_{p}) = {total};  4 divides it: {total % 4 == 0}  (Lagrange)")


def demo_psi3_collapse(limit: int = 40) -> None:
    print("\n[6] Regime-independence of the summed 3-division count")
    print("      p   p mod 3   local counts (b = 1..p-1)                 sum   2(p-1)")
    for p in primes_up_to(limit):
        if p in (2, 3):
            continue
        locals_ = [psi3_root_count(b, p) for b in range(1, p)]
        total = sum(locals_)
        shown = "".join(str(v) for v in locals_)
        if len(shown) > 38:
            shown = shown[:35] + "..."
        flag = "OK" if total == 2 * (p - 1) else "MISMATCH"
        print(f"    {p:3d}      {p % 3}      {shown:40s} {total:4d}   "
              f"{2 * (p - 1):4d}  {flag}")
    print("    Note: constant 2 when p = 2 (mod 3); values 1 and 4 when p = 1 (mod 3);")
    print("    the sum is 2(p-1) in both cases.")


def demo_psi3_bijection(p: int = 13) -> None:
    print(f"\n[7] The fibre-counting bijection behind the collapse, over F_{p}")
    print("    Each nonzero x determines exactly one b with x^3 = -4b, namely b = -x^3/4.")
    inv4 = pow(4, p - 2, p)
    seen: Dict[int, List[int]] = {}
    for x in range(1, p):
        b = (-pow(x, 3, p) * inv4) % p
        assert pow(x, 3, p) == (-4 * b) % p
        seen.setdefault(b, []).append(x)
    print(f"    number of pairs (b, x) with b != 0 and x^3 = -4b : "
          f"{sum(len(v) for v in seen.values())} = p - 1 = {p - 1}")
    print("    fibres over b (only the nonempty ones):")
    for b in sorted(seen):
        print(f"        b = {b:2d} : x in {seen[b]}")
    print("    Summing the fibre sizes counts the domain F_p^x, so the total is p-1")
    print("    no matter how unevenly the fibres are distributed. Adding the root x = 0,")
    print(f"    once for each of the p-1 values of b, gives 2(p-1) = {2 * (p - 1)}.")


def main() -> None:
    print("=" * 78)
    print("TWO REGIMES FOR THE 2-TORSION OF A QUADRATIC TWIST FAMILY")
    print("and the collapse of the summed 3-division count")
    print("=" * 78)
    demo_local_dichotomy(13)
    demo_twist_invariance(17, 3)
    demo_summed_law(3, 60)
    demo_reciprocity_criteria(120)
    demo_klein_four(13, 3)
    demo_klein_four(17, 3)
    demo_psi3_collapse(40)
    demo_psi3_bijection(13)
    print("\nAll checks completed.")


if __name__ == "__main__":
    main()
