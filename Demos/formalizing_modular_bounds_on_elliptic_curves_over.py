"""
Modular bounds and exact moments for short Weierstrass curves over prime fields.
================================================================================

This self-contained script demonstrates, by direct computation over small prime
fields F_p, every result of the accompanying paper:

  (1)  The counting formula        #E(F_p) = p + 1 + S(a,b),
       where S(a,b) = sum_x chi(x^3 + a x + b) and chi is the Legendre symbol.
  (2)  The trace identity          a(a,b) = p + 1 - #E(F_p) = -S(a,b).
  (3)  The 2-torsion parity criterion: for a nonsingular curve, #E(F_p) is even
       iff the cubic x^3 + a x + b has a root in F_p.
  (4)  The 0/1/3 root dichotomy: a nonsingular short Weierstrass cubic never has
       exactly two roots in F_p.
  (5)  Supersingular family I:  p = 2 mod 3  =>  y^2 = x^3 + b has exactly p+1
       points for every b (so 3 | #E).
  (6)  Supersingular family II: p = 3 mod 4  =>  y^2 = x^3 + a x has exactly p+1
       points for every a (so 4 | #E).
  (7)  Quadratic twisting negates the trace:  #E + #E^d = 2p + 2.
  (8)  First moment:   sum_{a,b} a(a,b) = 0.
  (9)  Second moment:  sum_{a,b} a(a,b)^2 = p^3 - p^2   (exact).
 (10)  Vertical moments:
         a = 0:  sum_b a(0,b)^2 = p (p-1) (1 + chi(-3)),
         a != 0: sum_b a(a,b)^2 = p^2 - p (1 + chi(-3) + chi(-a/3)).
 (11)  The cubic/quadratic bridge: x |-> x^3 is a bijection of F_p iff chi(-3) = -1
       iff p = 2 mod 3 (supplementary reciprocity for -3).
 (12)  Chebyshev bound ("Hasse on average"):
         K * #{(a,b) : a(a,b)^2 >= K} <= p^3 - p^2,
       and the exhaustive verification of the Hasse bound a(a,b)^2 <= 4p.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# Basic finite-field utilities over F_p (p an odd prime)
# ----------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def legendre(c: int, p: int) -> int:
    """The quadratic character chi(c) in {-1, 0, 1} of c modulo the odd prime p."""
    c %= p
    if c == 0:
        return 0
    return 1 if pow(c, (p - 1) // 2, p) == 1 else -1


def inv(c: int, p: int) -> int:
    """Multiplicative inverse of c modulo p (c not divisible by p)."""
    return pow(c, p - 2, p)


def w_rhs(a: int, b: int, x: int, p: int) -> int:
    """The right-hand side x^3 + a x + b of the short Weierstrass equation."""
    return (x * x % p * x + a * x + b) % p


def disc(a: int, b: int, p: int) -> int:
    """The discriminant quantity 4a^3 + 27b^2 of the cubic x^3 + a x + b."""
    return (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p


# ----------------------------------------------------------------------------
# Point counting
# ----------------------------------------------------------------------------


def char_sum(a: int, b: int, p: int) -> int:
    """The character sum S(a,b) = sum_{x in F_p} chi(x^3 + a x + b)."""
    return sum(legendre(w_rhs(a, b, x, p), p) for x in range(p))


def card_points_brute(a: int, b: int, p: int) -> int:
    """Number of projective points of y^2 = x^3 + a x + b: affine solutions plus infinity."""
    total = 1
    for x in range(p):
        r = w_rhs(a, b, x, p)
        for y in range(p):
            if y * y % p == r:
                total += 1
    return total


def card_points_formula(a: int, b: int, p: int) -> int:
    """Point count via the counting formula #E = p + 1 + S(a,b)."""
    return p + 1 + char_sum(a, b, p)


def frob_trace(a: int, b: int, p: int) -> int:
    """The trace of Frobenius a(a,b) = p + 1 - #E(F_p)."""
    return p + 1 - card_points_brute(a, b, p)


def root_set(a: int, b: int, p: int) -> List[int]:
    """Roots in F_p of the cubic x^3 + a x + b (the x-coordinates of 2-torsion)."""
    return [x for x in range(p) if w_rhs(a, b, x, p) == 0]


def collisions(a: int, p: int) -> int:
    """#{(x,y) in F_p^2 : x^3 + a x = y^3 + a y}, the collision count of the family."""
    buckets: Dict[int, int] = {}
    for x in range(p):
        v = (x * x % p * x + a * x) % p
        buckets[v] = buckets.get(v, 0) + 1
    return sum(m * m for m in buckets.values())


def nonsquare(p: int) -> int:
    """A fixed quadratic nonresidue modulo p."""
    for d in range(2, p):
        if legendre(d, p) == -1:
            return d
    raise ValueError("no nonresidue found")


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_counting_formula(primes: List[int]) -> None:
    print("=" * 78)
    print("(1)-(2)  Counting formula  #E = p + 1 + S(a,b)   and   a(a,b) = -S(a,b)")
    print("=" * 78)
    for p in primes:
        ok = all(
            card_points_brute(a, b, p) == card_points_formula(a, b, p)
            and frob_trace(a, b, p) == -char_sum(a, b, p)
            for a in range(p)
            for b in range(p)
        )
        print(f"  p = {p:3d}:  all {p * p:5d} curves satisfy both identities: {ok}")
    print()
    p = 7
    print("  Sample table for p = 7  (a, b, #E, a_p, S):")
    for a in range(3):
        for b in range(3):
            print(
                f"    a={a} b={b}  #E={card_points_brute(a, b, p):3d} "
                f"a_p={frob_trace(a, b, p):3d}  S={char_sum(a, b, p):3d}"
            )
    print()


def demo_parity_and_roots(primes: List[int]) -> None:
    print("=" * 78)
    print("(3)-(4)  2-torsion parity criterion and the 0/1/3 root dichotomy")
    print("=" * 78)
    for p in primes:
        parity_ok = True
        dichotomy_ok = True
        counts = {0: 0, 1: 0, 3: 0}
        for a in range(p):
            for b in range(p):
                if disc(a, b, p) == 0:
                    continue
                r = len(root_set(a, b, p))
                if r not in (0, 1, 3):
                    dichotomy_ok = False
                else:
                    counts[r] += 1
                if (card_points_brute(a, b, p) % 2 == 0) != (r > 0):
                    parity_ok = False
        print(
            f"  p = {p:3d}:  parity criterion holds: {parity_ok};  "
            f"root counts only 0/1/3: {dichotomy_ok}  "
            f"(#0={counts[0]}, #1={counts[1]}, #3={counts[3]})"
        )
    print()
    print("  Sharpness: the SINGULAR curve y^2 = x^3 + 2x + 2 = (x-1)^2 (x+2) over F_5")
    p, a, b = 5, 2, 2
    print(
        f"    disc = {disc(a, b, p)},  roots = {root_set(a, b, p)} "
        f"(exactly two!),  #E = {card_points_brute(a, b, p)} (odd)"
    )
    print("    => the nonsingularity hypothesis cannot be dropped.")
    print()


def demo_supersingular(primes: List[int]) -> None:
    print("=" * 78)
    print("(5)-(6)  The two supersingular families")
    print("=" * 78)
    for p in primes:
        if p % 3 == 2:
            ok = all(card_points_brute(0, b, p) == p + 1 for b in range(p))
            print(f"  p = {p:3d} = 2 mod 3:  y^2 = x^3 + b has exactly p+1 = {p + 1} points: {ok}"
                  f"   (so 3 | #E: {(p + 1) % 3 == 0})")
        if p % 4 == 3:
            ok = all(card_points_brute(a, 0, p) == p + 1 for a in range(p))
            print(f"  p = {p:3d} = 3 mod 4:  y^2 = x^3 + ax has exactly p+1 = {p + 1} points: {ok}"
                  f"   (so 4 | #E: {(p + 1) % 4 == 0})")
    p = 13
    print(f"  Contrast p = 13 (= 1 mod 3, = 1 mod 4): "
          f"#E(y^2=x^3+1) = {card_points_brute(0, 1, p)}, "
          f"#E(y^2=x^3+2) = {card_points_brute(0, 2, p)}  -- genuinely varying.")
    print()


def demo_twist(primes: List[int]) -> None:
    print("=" * 78)
    print("(7)  Quadratic twisting negates the trace:  #E + #E^d = 2p + 2")
    print("=" * 78)
    for p in primes:
        d = nonsquare(p)
        ok = all(
            card_points_brute(a, b, p)
            + card_points_brute(a * d * d % p, b * pow(d, 3, p) % p, p)
            == 2 * p + 2
            for a in range(p)
            for b in range(p)
        )
        print(f"  p = {p:3d} (nonresidue d = {d}):  identity holds for all curves: {ok}")
    p, d = 5, 2
    print(
        f"  Example p = 5, d = 2:  #E(y^2=x^3+x+1) = {card_points_brute(1, 1, p)}, "
        f"twist = {card_points_brute(1 * 4 % p, 1 * 8 % p, p)}, "
        f"sum = {card_points_brute(1, 1, p) + card_points_brute(4 % p, 8 % p, p)} = 2*5+2"
    )
    print()


def demo_moments(primes: List[int]) -> None:
    print("=" * 78)
    print("(8)-(9)  First moment 0 and exact second moment p^3 - p^2")
    print("=" * 78)
    for p in primes:
        m1 = sum(frob_trace(a, b, p) for a in range(p) for b in range(p))
        m2 = sum(frob_trace(a, b, p) ** 2 for a in range(p) for b in range(p))
        print(
            f"  p = {p:3d}:  sum a(a,b) = {m1:4d} (expected 0);   "
            f"sum a(a,b)^2 = {m2:8d}  vs  p^3-p^2 = {p ** 3 - p ** 2:8d}   "
            f"{'MATCH' if m2 == p ** 3 - p ** 2 else 'MISMATCH'}"
        )
    print()


def demo_vertical_moments(primes: List[int]) -> None:
    print("=" * 78)
    print("(10)  Exact vertical second moments (fixed a, summed over b)")
    print("=" * 78)
    for p in primes:
        chi3 = legendre(-3, p)
        lhs = sum(frob_trace(0, b, p) ** 2 for b in range(p))
        rhs = p * (p - 1) * (1 + chi3)
        status = "MATCH" if lhs == rhs else "MISMATCH"
        print(f"  p = {p:3d}:  a = 0:  sum_b a(0,b)^2 = {lhs:7d}  "
              f"vs  p(p-1)(1+chi(-3)) = {rhs:7d}   [chi(-3) = {chi3:2d}]  {status}")
        bad = []
        for a in range(1, p):
            lhs_a = sum(frob_trace(a, b, p) ** 2 for b in range(p))
            arg = (-a) * inv(3, p) % p
            rhs_a = p * p - p * (1 + chi3 + legendre(arg, p))
            if lhs_a != rhs_a:
                bad.append(a)
        print(f"            a != 0: formula p^2 - p(1 + chi(-3) + chi(-a/3)) "
              f"holds for all {p - 1} values of a: {not bad}")
    print()


def demo_bridge(primes: List[int]) -> None:
    print("=" * 78)
    print("(11)  Cubing is bijective  <=>  chi(-3) = -1  <=>  p = 2 mod 3")
    print("=" * 78)
    for p in primes:
        cubes = {pow(x, 3, p) for x in range(p)}
        bij = len(cubes) == p
        chi3 = legendre(-3, p)
        print(
            f"  p = {p:3d}:  cubing bijective = {str(bij):5s} | chi(-3) = {chi3:2d} | "
            f"p mod 3 = {p % 3} | collisions(0) = {collisions(0, p):4d} "
            f"vs 2p-1+(p-1)chi(-3) = {2 * p - 1 + (p - 1) * chi3:4d}"
        )
    print()


def demo_hasse_and_chebyshev(primes: List[int]) -> None:
    print("=" * 78)
    print("(12)  Hasse bound (exhaustive) and the Chebyshev consequence")
    print("=" * 78)
    for p in primes:
        traces = [frob_trace(a, b, p) for a in range(p) for b in range(p)]
        hasse_ok = all(t * t <= 4 * p for t in traces)
        mx = max(t * t for t in traces)
        print(f"  p = {p:3d}:  a(a,b)^2 <= 4p for all {p * p} curves: {hasse_ok}   "
              f"(max a^2 = {mx}, 4p = {4 * p}, p-1 = {p - 1})")
    print()
    print("  Chebyshev:  K * #{(a,b) : a^2 >= K}  <=  p^3 - p^2")
    for p in primes:
        traces = [frob_trace(a, b, p) for a in range(p) for b in range(p)]
        for K in (1, p, 2 * p, 4 * p):
            n = sum(1 for t in traces if t * t >= K)
            print(f"    p = {p:3d}, K = {K:3d}:  K*count = {K * n:7d}  <=  "
                  f"p^3-p^2 = {p ** 3 - p ** 2:7d}   {'OK' if K * n <= p ** 3 - p ** 2 else 'FAIL'}")
    print()


def demo_trace_histogram(p: int) -> None:
    print("=" * 78)
    print(f"(bonus)  Distribution of the trace of Frobenius over all curves mod p = {p}")
    print("=" * 78)
    hist: Dict[int, int] = {}
    for a in range(p):
        for b in range(p):
            t = frob_trace(a, b, p)
            hist[t] = hist.get(t, 0) + 1
    lo, hi = min(hist), max(hist)
    total = sum(hist.values())
    mean = sum(t * c for t, c in hist.items()) / total
    var = sum(t * t * c for t, c in hist.items()) / total
    for t in range(lo, hi + 1):
        c = hist.get(t, 0)
        print(f"   a = {t:4d} | {'#' * c} ({c})")
    print(f"  total curves = {total}, mean = {mean:.4f}, "
          f"mean square = {var:.4f}  (predicted p - 1 = {p - 1})")
    print()


def main() -> None:
    primes: List[int] = [5, 7, 11, 13]
    demo_counting_formula(primes)
    demo_parity_and_roots(primes)
    demo_supersingular(primes)
    demo_twist(primes)
    demo_moments(primes + [17, 19])
    demo_vertical_moments(primes)
    demo_bridge([5, 7, 11, 13, 17, 19, 23])
    demo_hasse_and_chebyshev(primes)
    demo_trace_histogram(11)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
