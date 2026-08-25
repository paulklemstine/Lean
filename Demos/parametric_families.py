#!/usr/bin/env python3
"""
Sums of three cubes: the Vieta barrier and the cube-digit principle.
===================================================================

Numerical demonstration of the results of the accompanying paper.

Contents
--------
1.  The Vieta identity  a^3 + b^3 + (-a-b)^3 = -3ab(a+b), its six-fold symmetry
    orbit, and the residual collision  V(1,5) = V(2,3) = -90  inside the
    fundamental domain 1 <= a <= b.
2.  The divisor bound for multiplicity:  #{(a,b) >= 1 : 3ab(a+b) = v} <= d(v).
3.  The Vieta ceiling: every Vieta value is divisible by 6, so the Vieta
    counting function is sandwiched  floor(sqrt(N/6)) <= #Vieta(N) <= floor(N/6);
    empirically it grows like  0.53 * N^(2/3).
4.  The cube-digit (greedy) principle:  r < 3z^2+3z+1  ==>  z^3+r determines
    (z, r);  and the greedy peel that inverts the three-scale box map.
5.  The three-scale box  1<=x<=t^4, t^6<=y<2t^6, 2t^9<=z<3t^9: verification of
    the gap conditions, of injectivity, of the value bound 36 t^27, and of the
    counting theorem  t^19 <= #P(36 t^27)  with exponent 19/27 ~ 0.7037.
6.  The escape family: roots  6u+1, 6v+1, 6w+1  produce values = 3 (mod 6),
    hence never Vieta values;  136 t^19  of them below  10^8 t^27.
7.  The greedy cube tower: exponent  1 - (2/3)^s  for s positive cubes.

Everything is self-contained: standard library only, full type hints.
Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Dict, Iterator, List, Set, Tuple

# ----------------------------------------------------------------------------
# Section 0. Small integer utilities
# ----------------------------------------------------------------------------


def integer_cube_root(n: int) -> int:
    """Return floor(n ** (1/3)) for n >= 0, exactly, by Newton iteration."""
    if n < 0:
        raise ValueError("integer_cube_root expects a nonnegative integer")
    if n < 2:
        return n
    z = 1 << ((n.bit_length() + 2) // 3)
    while True:
        w = (2 * z + n // (z * z)) // 3
        if w >= z:
            break
        z = w
    while (z + 1) ** 3 <= n:
        z += 1
    while z**3 > n:
        z -= 1
    return z


def divisor_count(n: int) -> int:
    """Number of positive divisors of n >= 1 by trial division."""
    if n < 1:
        raise ValueError("divisor_count expects a positive integer")
    count, d = 0, 1
    while d * d <= n:
        if n % d == 0:
            count += 2 if d * d != n else 1
        d += 1
    return count


def cube_gap(z: int) -> int:
    """(z+1)^3 - z^3 = 3z^2 + 3z + 1: the local gap between consecutive cubes."""
    return 3 * z * z + 3 * z + 1


# ----------------------------------------------------------------------------
# Section 1. The Vieta identity and its symmetries
# ----------------------------------------------------------------------------


def vieta_value(a: int, b: int) -> int:
    """V(a,b) = -3ab(a+b) = a^3 + b^3 + (-a-b)^3."""
    return -3 * a * b * (a + b)


def vieta_orbit(a: int, b: int) -> List[Tuple[int, int]]:
    """The S_3-orbit of (a,b) acting on the three roots {a, b, -a-b}."""
    c = -a - b
    return [(a, b), (b, a), (a, c), (c, a), (b, c), (c, b)]


def demo_identity_and_symmetry() -> None:
    print("=" * 78)
    print("1.  THE VIETA IDENTITY AND ITS SIX-FOLD SYMMETRY")
    print("=" * 78)
    for a, b in [(1, 2), (2, 5), (3, 7), (-4, 9)]:
        lhs = a**3 + b**3 + (-a - b) ** 3
        rhs = vieta_value(a, b)
        print(f"  a={a:3d}, b={b:3d}:  ({a})^3 + ({b})^3 + ({-a-b})^3 = {lhs:8d} "
              f"= -3ab(a+b) = {rhs:8d}   [{'OK' if lhs == rhs else 'FAIL'}]")

    a, b = 4, 9
    orbit = vieta_orbit(a, b)
    values = {vieta_value(p, q) for p, q in orbit}
    print(f"\n  Orbit of (a,b)=({a},{b}) on roots {{{a}, {b}, {-a-b}}}:")
    print(f"    pairs  = {orbit}")
    print(f"    values = {values}   (all six pairs share one value: "
          f"{'OK' if len(values) == 1 else 'FAIL'})")
    print(f"    distinct pairs: {len(set(orbit))} of 6")

    print("\n  Residual collision INSIDE the fundamental domain 1 <= a <= b:")
    print(f"    V(1,5) = {vieta_value(1,5)},  V(2,3) = {vieta_value(2,3)}")
    print(f"    1^3 + 5^3 + (-6)^3 = {1**3 + 5**3 + (-6)**3}")
    print(f"    2^3 + 3^3 + (-5)^3 = {2**3 + 3**3 + (-5)**3}")
    print("    => no ordering restriction alone can make the value map injective.")

    print("\n  Cube-scaled spine (m,b) -> 3 m^3 b(b+1) also collides:")
    print(f"    3*1^3*15*16 = {3*1**3*15*16},   3*2^3*5*6 = {3*2**3*5*6}")


# ----------------------------------------------------------------------------
# Section 2. Multiplicity is bounded by the divisor function
# ----------------------------------------------------------------------------


def vieta_preimages(v: int) -> List[Tuple[int, int]]:
    """All (a,b) with a,b >= 1 and 3ab(a+b) = v (uses a | v and monotonicity)."""
    if v <= 0 or v % 3 != 0:
        return []
    out: List[Tuple[int, int]] = []
    a = 1
    while 3 * a * 1 * (a + 1) <= v:
        if v % a == 0:
            # solve 3 a b (a+b) = v for b by bisection (strictly increasing in b)
            lo, hi = 1, 1
            while 3 * a * hi * (a + hi) < v:
                hi *= 2
            while lo <= hi:
                mid = (lo + hi) // 2
                val = 3 * a * mid * (a + mid)
                if val == v:
                    out.append((a, mid))
                    break
                if val < v:
                    lo = mid + 1
                else:
                    hi = mid - 1
        a += 1
    return out


def demo_divisor_bound(limit: int = 20000) -> None:
    print()
    print("=" * 78)
    print("2.  MULTIPLICITY OF A VIETA VALUE IS AT MOST ITS DIVISOR COUNT")
    print("=" * 78)
    worst: List[Tuple[int, int, int]] = []
    for v in range(6, limit + 1, 6):
        pre = vieta_preimages(v)
        if len(pre) >= 2:
            worst.append((v, len(pre), divisor_count(v)))
    worst.sort(key=lambda r: (-r[1], r[0]))
    print(f"  scanning v <= {limit}; values with multiplicity >= 2 (top 8):")
    print(f"    {'v':>8} {'#preimages':>11} {'d(v)':>6}   bound holds")
    for v, mult, dv in worst[:8]:
        print(f"    {v:>8} {mult:>11} {dv:>6}   {'yes' if mult <= dv else 'NO'}")
    ok = all(m <= d for _, m, d in worst)
    print(f"  divisor bound  #preimages <= d(v)  holds for all scanned v: {ok}")
    print(f"  values with >= 2 representations below {limit}: {len(worst)}")


# ----------------------------------------------------------------------------
# Section 3. The Vieta ceiling and the empirical exponent 2/3
# ----------------------------------------------------------------------------


def vieta_values_up_to(n_max: int) -> Set[int]:
    """All positive integers <= n_max of the form 3ab(a+b) with a,b >= 1."""
    out: Set[int] = set()
    a = 1
    while 3 * a * 1 * (a + 1) <= n_max:
        b = 1
        while True:
            v = 3 * a * b * (a + b)
            if v > n_max:
                break
            out.add(v)
            b += 1
        a += 1
    return out


def demo_vieta_counting(n_max: int = 2_000_000) -> None:
    print()
    print("=" * 78)
    print("3.  THE VIETA CEILING AND THE SANDWICH")
    print("=" * 78)
    print("  Every Vieta value is divisible by 6 (3 | -3ab(a+b), and ab(a+b) is even).")
    bad = [(a, b) for a in range(-12, 13) for b in range(-12, 13)
           if vieta_value(a, b) % 6 != 0]
    print(f"  counterexamples with |a|,|b| <= 12: {len(bad)}  (expected 0)")

    print(f"\n  {'N':>10} {'lower sqrt(N/6)':>16} {'#Vieta(N)':>11} "
          f"{'ceiling N/6':>12} {'#/N^(2/3)':>10}")
    n = 2000
    while n <= n_max:
        vals = vieta_values_up_to(n)
        lower = int((n // 6) ** 0.5)
        ratio = len(vals) / n ** (2 / 3)
        print(f"  {n:>10} {lower:>16} {len(vals):>11} {n//6:>12} {ratio:>10.4f}")
        n *= 4
    print("\n  The normalised count #Vieta(N)/N^(2/3) drifts slowly upward towards")
    print("  its empirical limit ~ 0.53 (the drift is the usual divisor-type")
    print("  secondary term).  It lies far above the certified lower bound")
    print("  sqrt(N/6) ~ 0.41 N^(1/2) and far below the ceiling N/6.")


# ----------------------------------------------------------------------------
# Section 4. The cube-digit principle
# ----------------------------------------------------------------------------


def cube_digit_recover(n: int) -> Tuple[int, int]:
    """Given n = z^3 + r with r < 3z^2+3z+1, return (z, r): z = floor(n^(1/3))."""
    z = integer_cube_root(n)
    return z, n - z**3


def greedy_peel_three(n: int) -> Tuple[int, int, int]:
    """Invert the cube-digit map: recover (x,y,z) from n = x^3+y^3+z^3."""
    z, rest = cube_digit_recover(n)
    y, rest2 = cube_digit_recover(rest)
    x = integer_cube_root(rest2)
    return x, y, z


def demo_cube_digit_principle() -> None:
    print()
    print("=" * 78)
    print("4.  THE CUBE-DIGIT (GREEDY) PRINCIPLE")
    print("=" * 78)
    print("  If r < (z+1)^3 - z^3 = 3z^2+3z+1, then z^3 + r determines z and r.")
    print(f"  {'z':>6} {'gap 3z^2+3z+1':>15} {'r':>8} {'n=z^3+r':>12} "
          f"{'recovered (z,r)':>18}")
    for z, r in [(3, 12), (10, 330), (10, 331), (50, 7000), (123, 45000)]:
        n = z**3 + r
        got = cube_digit_recover(n)
        flag = "" if r < cube_gap(z) else "   (r >= gap: recovery may differ!)"
        print(f"  {z:>6} {cube_gap(z):>15} {r:>8} {n:>12} {str(got):>18}{flag}")
    print("\n  The first four rows satisfy r < gap and are recovered exactly;")
    print("  the row with r = 331 = gap(10) is exactly the failure boundary:")
    print(f"    10^3 + 331 = {10**3+331} = 11^3 + 0, so the digits are ambiguous.")


# ----------------------------------------------------------------------------
# Section 5. The three-scale box and the exponent 19/27
# ----------------------------------------------------------------------------


def box_points(t: int) -> Iterator[Tuple[int, int, int]]:
    """The box  1 <= x <= t^4,  t^6 <= y < 2t^6,  2t^9 <= z < 3t^9."""
    for x in range(1, t**4 + 1):
        for y in range(t**6, 2 * t**6):
            for z in range(2 * t**9, 3 * t**9):
                yield (x, y, z)


def check_box(t: int) -> Dict[str, object]:
    """Verify cardinality t^19, both gap conditions, value bound, injectivity."""
    pts = list(box_points(t))
    seen: Dict[int, Tuple[int, int, int]] = {}
    gaps_ok = True
    bound_ok = True
    peel_ok = True
    for (x, y, z) in pts:
        if not (x**3 < cube_gap(y)):
            gaps_ok = False
        if not (x**3 + y**3 < cube_gap(z)):
            gaps_ok = False
        n = x**3 + y**3 + z**3
        if n > 36 * t**27:
            bound_ok = False
        if greedy_peel_three(n) != (x, y, z):
            peel_ok = False
        seen.setdefault(n, (x, y, z))
    return {
        "t": t,
        "points": len(pts),
        "t^19": t**19,
        "distinct_values": len(seen),
        "injective": len(seen) == len(pts),
        "gap_conditions": gaps_ok,
        "value_bound_36t27": bound_ok,
        "greedy_peel_inverts": peel_ok,
        "max_value": max(seen) if seen else 0,
        "36t^27": 36 * t**27,
    }


def demo_three_scale_box() -> None:
    print()
    print("=" * 78)
    print("5.  THE THREE-SCALE BOX AND THE EXPONENT 19/27")
    print("=" * 78)
    for t in (1, 2):
        r = check_box(t)
        print(f"\n  t = {t}:  box = [1,{t**4}] x [{t**6},{2*t**6}) x "
              f"[{2*t**9},{3*t**9})")
        print(f"    points            : {r['points']}   (t^19 = {r['t^19']})")
        print(f"    distinct values   : {r['distinct_values']}")
        print(f"    injective         : {r['injective']}")
        print(f"    gap conditions    : {r['gap_conditions']}")
        print(f"    values <= 36 t^27 : {r['value_bound_36t27']}  "
              f"(max {r['max_value']} <= {r['36t^27']})")
        print(f"    greedy peel inverts the map: {r['greedy_peel_inverts']}")

    print("\n  Asymptotic form: with N = 36 t^27 the box certifies t^19 integers,")
    print("  i.e. an exponent 19/27 = 0.703703...  Comparison with the barrier:")
    print(f"    {'t':>4} {'N = 36 t^27':>24} {'t^19':>22} {'100*sqrt(N)':>22}")
    for t in (2, 3, 4, 6, 10):
        n = 36 * t**27
        print(f"    {t:>4} {n:>24} {t**19:>22} {100*int(n**0.5):>22}")
    print("  From t = 4 on, t^19 exceeds 100*sqrt(N): the square-root barrier is")
    print("  passed, and any fixed multiple of sqrt(N) is eventually dominated.")

    print("\n  Certified lower bound for arbitrary N (N >= 36):")
    print(f"    {'N':>22} {'(N/(36*2^27))^(19/27)':>26}")
    for n in (10**6, 10**9, 10**12, 10**18):
        print(f"    {n:>22} {(n / (36 * 2**27)) ** (19 / 27):>26.3f}")


# ----------------------------------------------------------------------------
# Section 6. The escape family: sums of three cubes that Vieta cannot reach
# ----------------------------------------------------------------------------


def escape_points(t: int) -> Iterator[Tuple[int, int, int]]:
    """The residue-restricted box  1<=u<=t^4, 4t^6<=v<8t^6, 34t^9<=w<68t^9."""
    for u in range(1, t**4 + 1):
        for v in range(4 * t**6, 8 * t**6):
            for w in range(34 * t**9, 68 * t**9):
                yield (u, v, w)


def escape_value(u: int, v: int, w: int) -> int:
    """(6u+1)^3 + (6v+1)^3 + (6w+1)^3: all three roots are 1 mod 6."""
    return (6 * u + 1) ** 3 + (6 * v + 1) ** 3 + (6 * w + 1) ** 3


def demo_escape_family(t: int = 1) -> None:
    print()
    print("=" * 78)
    print("6.  ESCAPING THE VIETA FAMILY")
    print("=" * 78)
    pts = list(escape_points(t))
    vals = [escape_value(*p) for p in pts]
    distinct = len(set(vals))
    bound = 10**8 * t**27
    print(f"  t = {t}: box size {len(pts)} (predicted 136 t^19 = {136 * t**19})")
    print(f"  distinct values      : {distinct}  (injective: {distinct == len(pts)})")
    print(f"  all values <= 10^8 t^27 = {bound}: {max(vals) <= bound}"
          f"   (max = {max(vals)})")
    residues = {v % 6 for v in vals}
    print(f"  residues mod 6       : {residues}  (must be {{3}}: never a multiple of 6)")
    print("  Since every Vieta value is divisible by 6, none of these integers is")
    print("  a Vieta value for ANY pair (a,b) -- yet each is a sum of three")
    print("  positive cubes.  Sample of five:")
    for p, v in list(zip(pts, vals))[:5]:
        u, vv, w = p
        print(f"    ({6*u+1})^3 + ({6*vv+1})^3 + ({6*w+1})^3 = {v}"
              f"   ({v} mod 6 = {v % 6})")

    print("\n  Cross-check against a brute-force Vieta search for those samples:")
    for v in vals[:5]:
        print(f"    {v}: Vieta preimages found = {len(vieta_preimages(v))}"
              f"   (divisible by 6: {v % 6 == 0})")


# ----------------------------------------------------------------------------
# Section 7. The greedy cube tower
# ----------------------------------------------------------------------------


def tower_const(s: int) -> int:
    """C_0 = 1,  C_{s+1} = 8 C_s^3 + C_s."""
    c = 1
    for _ in range(s):
        c = 8 * c**3 + c
    return c


def tower_exponent(s: int) -> float:
    """(3^s - 2^s)/3^s = 1 - (2/3)^s."""
    return (3**s - 2**s) / 3**s


def greedy_tower_set(s: int, t: int) -> Set[int]:
    """Constructive version of the tower: the set S of the induction."""
    if s == 0:
        return {0}
    prev = greedy_tower_set(s - 1, t * t)
    z0 = tower_const(s - 1) * t ** (3 ** (s - 1))
    return {z**3 + m for z in range(z0, 2 * z0) for m in prev}


def demo_tower() -> None:
    print()
    print("=" * 78)
    print("7.  THE GREEDY CUBE TOWER:  EXPONENT 1 - (2/3)^s")
    print("=" * 78)
    print(f"  {'s':>3} {'C_s (digits)':>14} {'3^s - 2^s':>10} {'3^s':>6} "
          f"{'exponent':>10}")
    for s in range(0, 9):
        c = tower_const(s)
        c_str = str(c) if c < 10**8 else f"~10^{len(str(c)) - 1}"
        print(f"  {s:>3} {c_str:>14} {3**s - 2**s:>10} {3**s:>6} "
              f"{tower_exponent(s):>10.6f}")
    print("  s = 2: 5/9 = 0.5556,  s = 3: 19/27 = 0.7037,  s = 4: 65/81 = 0.8025;")
    print("  the exponents increase to 1, each cube recovering two thirds of the")
    print("  remaining deficit.")

    print("\n  Constructive check of the induction (s = 1,2 at t = 2; s = 3 at t = 1):")
    for s, t in ((1, 2), (2, 2), (3, 1)):
        S = greedy_tower_set(s, t)
        predicted = t ** (3**s - 2**s)
        bound = tower_const(s) * t ** (3**s)
        print(f"    s={s}: |S| = {len(S):>8}  >= t^(3^s-2^s) = {predicted:<8} "
              f"{'OK' if len(S) >= predicted else 'FAIL'};  "
              f"max = {max(S)} < C_s t^(3^s) = {bound}  "
              f"{'OK' if max(S) < bound else 'FAIL'}")


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------


def main() -> None:
    print("SUMS OF THREE CUBES: THE VIETA BARRIER AND THE CUBE-DIGIT PRINCIPLE")
    demo_identity_and_symmetry()
    demo_divisor_bound()
    demo_vieta_counting()
    demo_cube_digit_principle()
    demo_three_scale_box()
    demo_escape_family()
    demo_tower()
    print()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  * Vieta values: divisible by 6, six-fold symmetric, with divisor-type")
    print("    residual collisions; certified count floor(sqrt(N/6)), ceiling N/6,")
    print("    empirical truth ~ 0.53 N^(2/3).")
    print("  * Cube-digit box: injective by construction, giving")
    print("    (N/(36*2^27))^(19/27) integers <= N that are sums of three positive")
    print("    cubes -- strictly beyond the square-root barrier.")
    print("  * Residue-restricted box: ~ N^(19/27) such integers that are NOT")
    print("    Vieta values at all.")
    print("  * Tower of s cubes: exponent 1 - (2/3)^s, increasing to 1.")


if __name__ == "__main__":
    main()
