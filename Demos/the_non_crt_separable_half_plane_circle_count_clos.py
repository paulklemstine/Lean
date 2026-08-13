"""
demo.py — The non-separable half-plane count on the modular circle.

Self-contained numerical demonstration of the results in the accompanying
article and paper.  No third-party dependencies; every helper is inlined.

Objects.  For a modulus N >= 1 put

    Circle(N) = { (x, y) in [0,N)^2 : x^2 + y^2 == 1 (mod N) },
    C(N)      = |Circle(N)|                          (the circle count),
    H(N)      = #{ (x,y) in Circle(N) : 2(x+y) < N } (the half-plane count),
    high(N)   = #{ (x,y) in Circle(N) : 2(x+y) > 3N },
    S(N)      = #{ u in [0,N) : u^2 == 1 (mod N) },
    R(N)      = #{ u in [0,N) : u^2 == 1 (mod N), 2u < N },
    D(N)      = #{ x in [0,N) : 2x^2 == 1 (mod N), 4x < N }.

Demonstrated facts.

    (1) C is multiplicative and C(N) = prod_p p^{v_p(N)-1} (p - chi_p(-1))
        for odd N, where chi_p(-1) = +1 if p == 1 (mod 4) and -1 otherwise.
    (2) H(N) = high(N) + 2 R(N)         for N >= 2      (reflection identity).
    (3) 2 R(N) = S(N)                   for N >= 3, and S is multiplicative.
    (4) 4 high(N) <= C(N), sharp: 8 high(9) = 16 > 12 = C(9).
    (5) H(N) == D(N) (mod 2)            (parity is diagonal-local).
    (6) H is NOT multiplicative: H(35) = 6 while H(5)H(7) = 4.
    (7) The deviation eps(N) = H(N) - C(N)/8 is factor-sensitive but of size
        O(sqrt N): it is a genuine but noise-floor-scale signal.
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# Enumeration primitives.  Cost Theta(N) using the "square roots" trick:
# bucket residues by x^2 mod N, then match 1 - x^2.
# --------------------------------------------------------------------------

def circle_points(N: int) -> List[Tuple[int, int]]:
    """All (x, y) in [0,N)^2 with x^2 + y^2 == 1 (mod N).  Theta(N) time."""
    if N == 1:
        return [(0, 0)]
    roots: Dict[int, List[int]] = {}
    for y in range(N):
        roots.setdefault((y * y) % N, []).append(y)
    pts: List[Tuple[int, int]] = []
    for x in range(N):
        target = (1 - x * x) % N
        for y in roots.get(target, ()):
            pts.append((x, y))
    return pts


def circle_count(N: int) -> int:
    """C(N), by enumeration."""
    return len(circle_points(N))


def half_plane_count(N: int) -> int:
    """H(N) = #{(x,y) on the circle : 2(x+y) < N}."""
    return sum(1 for x, y in circle_points(N) if 2 * (x + y) < N)


def high_count(N: int) -> int:
    """high(N) = #{(x,y) on the circle : 2(x+y) > 3N}."""
    return sum(1 for x, y in circle_points(N) if 3 * N < 2 * (x + y))


def sqrt_one_count(N: int) -> int:
    """S(N) = number of square roots of 1 modulo N."""
    return sum(1 for u in range(N) if (u * u) % N == 1 % N)


def unit_root_count(N: int) -> int:
    """R(N) = number of square roots of 1 modulo N below N/2."""
    return sum(1 for u in range(N) if 2 * u < N and (u * u) % N == 1 % N)


def diag_count(N: int) -> int:
    """D(N) = #{x : 2x^2 == 1 (mod N), 4x < N}."""
    return sum(1 for x in range(N) if 4 * x < N and (2 * x * x) % N == 1 % N)


# --------------------------------------------------------------------------
# The separable closed form.
# --------------------------------------------------------------------------

def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorisation, returning {prime: exponent}."""
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def circle_count_closed(N: int) -> int:
    """C(N) for odd N from the factorisation: prod p^{v-1}(p - chi_p(-1)).

    Cost O(number of prime factors) once N is factored -- no enumeration.
    """
    if N % 2 == 0:
        raise ValueError("closed form stated for odd N only")
    out = 1
    for p, v in factorize(N).items():
        local = p - 1 if p % 4 == 1 else p + 1
        out *= p ** (v - 1) * local
    return out


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_closed_form(limit: int = 400) -> None:
    print("=" * 74)
    print("(1)  C is multiplicative and given in closed form for odd N")
    print("=" * 74)
    bad = [N for N in range(1, limit, 2) if circle_count(N) != circle_count_closed(N)]
    print(f"  odd N < {limit}: closed form matches enumeration everywhere: {not bad}")
    for N in (15, 21, 35, 105, 9, 27, 25, 225):
        f = factorize(N)
        pieces = " * ".join(
            f"{p}^{v-1}*({p}{'-' if p % 4 == 1 else '+'}1)" for p, v in sorted(f.items())
        )
        print(f"  N = {N:5d} = {'*'.join(f'{p}^{v}' for p, v in sorted(f.items())):10s}"
              f"  C(N) = {circle_count(N):6d}   = {pieces}")
    print()


def demo_reflection(limit: int = 120) -> None:
    print("=" * 74)
    print("(2,3)  Reflection identity  H = high + 2R,  and  2R = S")
    print("=" * 74)
    print("     N     C(N)   H(N)  high(N)   R(N)   S(N)   H-high-2R   2R-S")
    for N in (15, 16, 17, 20, 21, 24, 25, 28, 33, 35, 77, 91):
        C, H = circle_count(N), half_plane_count(N)
        hi, R, S = high_count(N), unit_root_count(N), sqrt_one_count(N)
        print(f"  {N:4d}  {C:6d}  {H:5d}  {hi:6d}  {R:5d}  {S:5d}"
              f"    {H - hi - 2 * R:6d}  {2 * R - S:5d}")
    ok_refl = all(half_plane_count(N) == high_count(N) + 2 * unit_root_count(N)
                  for N in range(2, limit))
    ok_roots = all(2 * unit_root_count(N) == sqrt_one_count(N) for N in range(3, limit))
    print(f"  reflection identity holds for all 2 <= N < {limit}: {ok_refl}")
    print(f"  2R = S holds for all 3 <= N < {limit}:               {ok_roots}")
    print()


def demo_quadrant_bound(limit: int = 200) -> None:
    print("=" * 74)
    print("(4)  Quadrant bound  4*high(N) <= C(N),  and its sharpness")
    print("=" * 74)
    ok = all(4 * high_count(N) <= circle_count(N) for N in range(1, limit))
    print(f"  4*high(N) <= C(N) for all N < {limit}: {ok}")
    worst = max(range(3, limit), key=lambda N: high_count(N) / max(circle_count(N), 1))
    print(f"  extremal ratio at N = {worst}: "
          f"high = {high_count(worst)}, C = {circle_count(worst)}, "
          f"ratio = {high_count(worst) / circle_count(worst):.4f}")
    print(f"  sharpness at N = 9: 8*high(9) = {8 * high_count(9)} > C(9) = {circle_count(9)}"
          "  -> the constant 4 cannot be replaced by 8")
    print()


def demo_parity(limit: int = 200) -> None:
    print("=" * 74)
    print("(5)  Parity is diagonal-local:  H(N) == D(N) (mod 2)")
    print("=" * 74)
    ok = all(half_plane_count(N) % 2 == diag_count(N) % 2 for N in range(1, limit))
    print(f"  congruence verified for all N < {limit}: {ok}")
    odd_N = [N for N in range(3, 80) if half_plane_count(N) % 2 == 1]
    print(f"  moduli N < 80 with H(N) odd: {odd_N}")
    for N in odd_N[:6]:
        wit = [x for x in range(N) if 4 * x < N and (2 * x * x) % N == 1 % N]
        print(f"    N = {N:3d}: H = {half_plane_count(N):3d}, D = {diag_count(N)}, "
              f"diagonal witnesses x with 2x^2 == 1: {wit}")
    print()


def demo_non_separability() -> None:
    print("=" * 74)
    print("(6)  H is NOT a product of local factors")
    print("=" * 74)
    for (p, q) in ((5, 7), (3, 11), (3, 7), (7, 11), (5, 13)):
        N = p * q
        print(f"  N = {N:4d} = {p}*{q}:  C(N) = {circle_count(N):5d} "
              f"= C({p})C({q}) = {circle_count(p) * circle_count(q):5d}   |   "
              f"H(N) = {half_plane_count(N):4d}  vs  H({p})H({q}) = "
              f"{half_plane_count(p) * half_plane_count(q):4d}")
    print("  -> the circle count separates over the factorisation; the cut does not.")
    print()


def demo_blum_recovery() -> None:
    print("=" * 74)
    print("     Aside: for p == q == 3 (mod 4), C(pq) = pq + p + q + 1")
    print("=" * 74)
    for (p, q) in ((3, 7), (3, 11), (7, 11), (11, 19), (19, 23)):
        N, C = p * q, circle_count(p * q)
        s = C - N - 1
        disc = s * s - 4 * N
        r = math.isqrt(disc)
        print(f"  N = {N:5d}: C(N) = {C:6d}, p+q = C-N-1 = {s:4d}, "
              f"recovered factors = ({(s - r) // 2}, {(s + r) // 2})")
    print("  The obstruction is purely computational: evaluating C(N) by")
    print("  enumeration costs Theta(N) steps, i.e. exponential in log N.")
    print()


def semiprimes_in_band(lo: int, hi: int) -> List[Tuple[int, int, int]]:
    """All odd semiprimes N = p*q with p < q and lo <= N <= hi."""
    out: List[Tuple[int, int, int]] = []
    for N in range(lo | 1, hi + 1, 2):
        f = factorize(N)
        if sorted(f.values()) == [1, 1]:
            p, q = sorted(f)
            out.append((N, p, q))
    return out


def demo_deviation(lo: int = 56800, hi: int = 57200, show: int = 12) -> None:
    print("=" * 74)
    print("(7)  eps(N) = H(N) - C(N)/8 : real factor-dependence, sqrt-size")
    print("=" * 74)
    print("      N        p*q         C(N)      C/8      H(N)     eps   eps/sqrt(N)")
    band = semiprimes_in_band(lo, hi)
    for N, p, q in band[:show]:
        C, H = circle_count_closed(N), half_plane_count(N)
        eps = H - C / 8
        print(f"  {N:6d}  {p:5d}*{q:5d}  {C:8d}  {C/8:9.1f}  {H:6d}  {eps:7.1f}"
              f"    {eps/math.sqrt(N):+.3f}")
    if band:
        eps_vals = [half_plane_count(N) - circle_count_closed(N) / 8 for N, _, _ in band]
        spread = max(eps_vals) - min(eps_vals)
        Nmid = band[len(band) // 2][0]
        width = 100 * (band[-1][0] - band[0][0]) / Nmid
        print(f"  band width in N: {width:.2f}%   |   spread of eps: {spread:.1f}"
              f"   ({spread/math.sqrt(Nmid):.2f} * sqrt(N))")
        print(f"  relative to the dominant term C/8 ~ {circle_count_closed(Nmid)/8:.0f}"
              f" that spread is only {100*spread/(circle_count_closed(Nmid)/8):.2f}%:")
        print("  the factor-dependence is real, but it lives at the sqrt(N) floor.")
    print()


def demo_density(limit: int = 3000) -> None:
    print("=" * 74)
    print("     Density check: 8H(N)/C(N) -> 1 for odd squarefree N")
    print("=" * 74)
    print("      range of N        mean 8H/C     max |8H - C| / sqrt(N)")
    for a, b in ((100, 400), (400, 1000), (1000, limit)):
        ratios, worst = [], 0.0
        for N in range(a | 1, b, 2):
            f = factorize(N)
            if any(v > 1 for v in f.values()):
                continue
            C, H = circle_count_closed(N), half_plane_count(N)
            ratios.append(8 * H / C)
            worst = max(worst, abs(8 * H - C) / math.sqrt(N))
        print(f"   [{a:5d}, {b:5d})       {sum(ratios)/len(ratios):.6f}        {worst:8.2f}")
    print("  The mean sits at 1 and the deviation stays O(sqrt N) -- consistent")
    print("  with square-root cancellation in the underlying exponential sums.")
    print()


def main() -> None:
    print()
    print("  THE NON-SEPARABLE HALF-PLANE COUNT ON THE MODULAR CIRCLE")
    print()
    demo_closed_form()
    demo_reflection()
    demo_quadrant_bound()
    demo_parity()
    demo_non_separability()
    demo_blum_recovery()
    demo_deviation()
    demo_density()


if __name__ == "__main__":
    main()
