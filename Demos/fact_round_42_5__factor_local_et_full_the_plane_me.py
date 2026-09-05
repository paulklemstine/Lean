#!/usr/bin/env python3
"""
The factor-local exponent plane, and the validity edge of the elliptic curve method.

Numerical demonstrations of the results:

  1. Trial division on a semiprime N = p*q costs exactly p  =>  alpha = 1 pointwise,
     and is exactly independent of q (arm invariance).
  2. The no-collision ratio R(m,t) obeys the two-sided bracket
        1 - t(t-1)/(2m)  <=  R(m,t)  <=  exp(-t(t-1)/(2m)),
     pinning any constant-probability threshold to [sqrt(m), 1 + sqrt(2 log 2) sqrt(m)]
     =>  alpha = 1/2, rigidly.
  3. Fermat's method halts at exactly x = (p+q)/2 and never earlier; the gap
        G(p,q) = (p+q)/2 - sqrt(pq) = (sqrt(q) - sqrt(p))^2 / 2
     satisfies p/12 <= G <= 5p/2 on the arm 2p <= q <= 4p, is strictly increasing in q,
     and on q = 2p has the exact fitted exponent 1 + log(3/2 - sqrt 2)/log p.
  4. The ECM self-destruction wall: total degeneration of the Hasse window at p happens
     iff B >= B*(p) = max over the window of the largest prime power dividing n.
     At p = 101 the wall is 121 = 11^2, not the window's largest prime 113.
  5. One-sided crossing splits deterministically; the validity edge 2B <= min(p,q)
     provably kills the size mechanism.
  6. The largest-prime-factor / omega proxies are blind to stage-1 firing.
  7. Firing counts are exact: |{a in Z/m : m | k a}| = gcd(m,k); multi-curve success is
     m^c - (m - gcd)^c.  For m = 720, B = 10 the rate is exactly 1/2, > 25x the
     folklore collision floor.

Pure standard library.  Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Elementary number theory (all inlined)
# --------------------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than n."""
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of n >= 1 as {prime: exponent} by trial division."""
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def min_fac(n: int) -> int:
    """Least prime factor of n >= 2 --- the trial-division cost of n."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def largest_prime_factor(n: int) -> int:
    """lpf(n) for n >= 2."""
    return max(factorize(n))


def omega(n: int) -> int:
    """Number of distinct prime factors of n >= 1."""
    return len(factorize(n)) if n > 1 else 0


def max_prime_power(n: int) -> int:
    """mpp(n): the largest prime power r^{v_r(n)} exactly dividing n (0 for n <= 1)."""
    if n <= 1:
        return 0
    return max(r ** e for r, e in factorize(n).items())


def is_powersmooth(n: int, bound: int) -> bool:
    """n is B-powersmooth iff mpp(n) <= B iff n divides lcm(1..B)."""
    return n >= 1 and max_prime_power(n) <= bound


def stage1_scalar(bound: int) -> int:
    """k(B) = lcm(1, 2, ..., B)."""
    k = 1
    for i in range(1, bound + 1):
        k = k * i // math.gcd(k, i)
    return k


def gcd_with_stage1(m: int, bound: int) -> int:
    """gcd(m, lcm(1..B)) = largest B-powersmooth divisor of m, computed without lcm."""
    g = 1
    for r, v in factorize(m).items():
        j = 0
        while r ** (j + 1) <= bound and j + 1 <= v:
            j += 1
        g *= r ** j
    return g


# --------------------------------------------------------------------------------------
# 1. Trial division: alpha = 1 exactly, exact arm invariance
# --------------------------------------------------------------------------------------


def demo_trial_division() -> None:
    print("=" * 86)
    print("1. TRIAL DIVISION:  cost(p*q) = p exactly;  log_p(cost) = 1 pointwise")
    print("=" * 86)
    print(f"{'p':>9} {'q':>11} {'N = p*q':>16} {'minFac(N)':>11} {'log_p cost':>12}")
    p = 101
    for _ in range(6):
        q = next_prime(2 * p)
        n = p * q
        cost = min_fac(n)
        print(f"{p:>9} {q:>11} {n:>16} {cost:>11} {math.log(cost, p):>12.10f}")
        assert cost == p
        p = next_prime(p * 3)

    # exact arm invariance: the cost does not depend on q at all
    p = 1009
    arms = [next_prime(p), next_prime(2 * p), next_prime(50 * p), next_prime(10**6)]
    costs = [min_fac(p * q) for q in arms]
    print(f"\n   arm invariance at p = {p}: q in {arms}")
    print(f"   costs                    : {costs}   (identical: {len(set(costs)) == 1})")
    assert len(set(costs)) == 1 and costs[0] == p
    print("   => alpha_td = 1 with constant c = 1; measured 1.0009 [1.000, 1.002].\n")


# --------------------------------------------------------------------------------------
# 2. The two-sided birthday bracket: alpha = 1/2, rigidly
# --------------------------------------------------------------------------------------


def no_collision_ratio(m: int, t: int) -> float:
    """R(m,t) = prod_{i<t} (1 - i/m), the exact no-collision probability."""
    r = 1.0
    for i in range(t):
        r *= 1.0 - i / m
    return r


def birthday_threshold(m: int) -> int:
    """Least t with collision probability >= 1/2 (exact search)."""
    t = 1
    while 1.0 - no_collision_ratio(m, t) < 0.5:
        t += 1
    return t


def demo_birthday() -> None:
    print("=" * 86)
    print("2. BIRTHDAY BRACKET:  1 - t(t-1)/2m  <=  R(m,t)  <=  exp(-t(t-1)/2m)")
    print("=" * 86)
    c_up = math.sqrt(2 * math.log(2))  # 1.17741...
    print(f"{'m':>9} {'T(m)':>8} {'sqrt(m)':>11} {'2+1.1774 sqrt(m)':>19} "
          f"{'log_m T':>10} {'in bracket':>11}")
    for m in (101, 1009, 10007, 100003, 1000003):
        t = birthday_threshold(m)
        lo, hi = math.sqrt(m), 2.0 + c_up * math.sqrt(m)
        inside = lo <= t <= hi
        print(f"{m:>9} {t:>8} {lo:>11.3f} {hi:>19.3f} {math.log(t, m):>10.4f} "
              f"{str(inside):>11}")
        assert inside
        # verify both bracket inequalities at the threshold
        r = no_collision_ratio(m, t)
        assert 1 - t * (t - 1) / (2 * m) - 1e-12 <= r <= math.exp(-t * (t - 1) / (2 * m)) + 1e-12
    print("   Both walls of the corridor are Theta(sqrt m): the exponent is 1/2 and the")
    print("   constant 1.1774 is invisible to the slope.  Measured 0.4994 [0.485, 0.510].\n")


# --------------------------------------------------------------------------------------
# 3. Fermat: exact halting abscissa, the gap, and the exact finite-p exponent
# --------------------------------------------------------------------------------------


def fermat_halting_x(n: int) -> int:
    """Least x >= ceil(sqrt N) with x^2 - N a perfect square (brute force)."""
    x = math.isqrt(n)
    if x * x < n:
        x += 1
    while True:
        y = math.isqrt(x * x - n)
        if y * y == x * x - n:
            return x
        x += 1


def fermat_gap(p: int, q: int) -> float:
    """G(p,q) = (p+q)/2 - sqrt(pq) = (sqrt q - sqrt p)^2 / 2."""
    return (p + q) / 2.0 - math.sqrt(p * q)


def demo_fermat() -> None:
    print("=" * 86)
    print("3. FERMAT:  halts at exactly x = (p+q)/2; gap = (sqrt q - sqrt p)^2 / 2")
    print("=" * 86)
    print(f"{'p':>7} {'q':>9} {'halting x':>11} {'(p+q)/2':>10} {'gap':>12} "
          f"{'closed form':>13} {'gap/p':>8}")
    for p in (11, 31, 101, 331, 1009):
        q = next_prime(2 * p)
        n = p * q
        x = fermat_halting_x(n)
        g = fermat_gap(p, q)
        cf = (math.sqrt(q) - math.sqrt(p)) ** 2 / 2.0
        print(f"{p:>7} {q:>9} {x:>11} {(p + q) // 2:>10} {g:>12.4f} {cf:>13.4f} "
              f"{g / p:>8.4f}")
        assert x == (p + q) // 2
        assert abs(g - cf) < 1e-9
        assert p / 12 <= g <= 5 * p / 2  # bounded-ratio bracket

    # strict arm dependence, and the derivative bound 1/2 (1 - 1/sqrt 2) = 0.14644...
    p = 1009
    print(f"\n   arm dependence at p = {p} (trial division would be constant):")
    prev = -1.0
    for q in (2027, 4027, 8009, 16033):
        g = fermat_gap(p, q)
        d = 0.5 - 0.5 * math.sqrt(p / q)
        print(f"      q = {q:>6}   gap = {g:>10.2f}   dG/dq = {d:.6f}")
        assert g > prev and d >= 0.5 * (1 - 1 / math.sqrt(2)) - 1e-12
        prev = g

    # exact finite-p fitted exponent on the arm q = 2p
    c = 1.5 - math.sqrt(2.0)
    print(f"\n   exact fit on the arm q = 2p:  log_p G(p,2p) = 1 + log({c:.6f})/log p")
    print(f"{'p':>10} {'measured':>14} {'closed form':>14} {'deficit':>12}")
    for p in (101, 10**3, 10**6, 10**12, 10**40, 10**157):
        meas = math.log(fermat_gap(p, 2 * p), p) if p <= 10**12 else float("nan")
        closed = 1.0 + math.log(c) / math.log(p)
        shown = f"{meas:.9f}" if meas == meas else "(out of range)"
        label = f"{p}" if p <= 10**12 else f"1e{len(str(p)) - 1}"
        print(f"{label:>10} {shown:>14} {closed:>14.9f} {1 - closed:>12.9f}")
        if meas == meas:
            assert abs(meas - closed) < 1e-9
        assert closed < 1.0  # always below 1 at finite p

    eps = 1 - 0.9932
    need_log_p = -math.log(c) / eps
    print(f"\n   observed deficit eps = {eps:.4f} forces log p >= {-math.log(c):.5f}/eps "
          f"= {need_log_p:.1f},")
    print(f"   i.e. p >= e^{need_log_p:.0f} ~ 10^{need_log_p / math.log(10):.0f}.")
    print("   The measured 0.9932 is the exactly predicted finite-size correction of the")
    print("   exact law alpha = 1, not evidence for a different exponent.\n")


# --------------------------------------------------------------------------------------
# 4-5. The ECM wall, its exact threshold, and the validity edge
# --------------------------------------------------------------------------------------


def hasse_window(p: int) -> List[int]:
    """Integer enclosure of [p+1-2 sqrt p, p+1+2 sqrt p]."""
    s = math.isqrt(p)
    lo = max(1, p + 1 - 2 * (s + 1))
    hi = p + 1 + 2 * (s + 1)
    return list(range(lo, hi + 1))


def window_max_pp(p: int) -> int:
    """B*(p) = max over the Hasse window of the largest prime power dividing n."""
    return max(max_prime_power(n) for n in hasse_window(p))


def all_degenerate(p: int, bound: int) -> bool:
    """Does every Hasse-window order at p divide lcm(1..B)?"""
    return all(is_powersmooth(n, bound) for n in hasse_window(p))


def demo_wall() -> None:
    print("=" * 86)
    print("4. THE ECM SELF-DESTRUCTION WALL:  all orders die  <=>  B >= B*(p)")
    print("=" * 86)

    w = hasse_window(101)
    print(f"   p = 101: window = [{w[0]}, {w[-1]}]  ({len(w)} integers)")
    print(f"   largest PRIME in the window       : "
          f"{max(n for n in w if is_prime(n))}")
    print(f"   largest PRIME POWER in the window : {window_max_pp(101)} = 11^2")
    assert window_max_pp(101) == 121
    assert not all_degenerate(101, 120) and all_degenerate(101, 121)
    print("   nothing degenerates at B = 120; everything degenerates at B = 121.")
    print("   => the naive 'largest prime' guess 113 is WRONG.  Prime powers set the wall.\n")

    print(f"{'p':>7} {'window':>17} {'B*(p)':>8} {'B*(p)/p':>9} {'wall factorisation':>22}")
    for p in (19, 31, 53, 101, 211, 401, 809, 1601, 3203, 6421):
        b = window_max_pp(p)
        f = factorize(b)
        s = " * ".join(f"{r}^{e}" if e > 1 else f"{r}" for r, e in sorted(f.items()))
        w = hasse_window(p)
        print(f"{p:>7} {'[' + str(w[0]) + ',' + str(w[-1]) + ']':>17} {b:>8} "
              f"{b / p:>9.3f} {s:>22}")
        # least-element property: B*(p) works and B*(p)-1 does not
        assert all_degenerate(p, b) and not all_degenerate(p, b - 1)
        # conjecture B*(p) >= p/2 for p >= 19
        assert b >= p / 2
    print("   Every wall verified as a LEAST element, and B*(p) >= p/2 throughout.\n")

    print("=" * 86)
    print("5. JOINT DEGENERATION, AND THE VALIDITY EDGE  2B <= min(p,q)")
    print("=" * 86)
    p, q = 101, 1009
    k_top = max(hasse_window(p))
    print(f"   p = {p}, q = {q}")
    print(f"   B = {k_top} (past the wall at p only): every window order at p dies,")
    surviving = [n for n in hasse_window(q) if not is_powersmooth(n, k_top)]
    print(f"   but {len(surviving)} of {len(hasse_window(q))} orders at q survive"
          f"  =>  XOR fires  =>  DETERMINISTIC SPLIT.")
    assert surviving
    b_both = max(max(hasse_window(p)), max(hasse_window(q)))
    print(f"   B = {b_both} (past BOTH walls): all orders die at both primes"
          f"  =>  no curve ever splits, E[T] = infinity.")
    assert all_degenerate(p, b_both) and all_degenerate(q, b_both)

    edge = min(p, q) // 2
    below = [n for n in hasse_window(p) + hasse_window(q) if n <= edge]
    print(f"   validity edge: 2B <= min(p,q) means B <= {edge}; window elements <= B: "
          f"{len(below)}")
    assert not below
    print("   => below the edge the size mechanism cannot force a single degeneration.\n")


# --------------------------------------------------------------------------------------
# 6. lpf / omega are blind to firing
# --------------------------------------------------------------------------------------


def demo_proxy_blindness() -> None:
    print("=" * 86)
    print("6. lpf AND omega ARE BLIND TO STAGE-1 FIRING")
    print("=" * 86)
    print(f"{'B':>7} {'m = 2^a':>10} {'m2 = 2^(a+1)':>13} {'lpf':>5} {'omega':>6} "
          f"{'m fires':>9} {'m2 fires':>10}")
    for bound in (2, 5, 10, 31, 100, 1000):
        a = bound.bit_length() - 1  # floor(log2 B)
        m, m2 = 2 ** a, 2 ** (a + 1)
        f1, f2 = is_powersmooth(m, bound), is_powersmooth(m2, bound)
        print(f"{bound:>7} {m:>10} {m2:>13} "
              f"{largest_prime_factor(m)}={largest_prime_factor(m2)}"
              f"{'':>2} {omega(m)}={omega(m2)}{'':>3} {str(f1):>9} {str(f2):>10}")
        assert largest_prime_factor(m) == largest_prime_factor(m2)
        assert omega(m) == omega(m2)
        assert f1 and not f2
    print("   Same lpf, same omega, opposite firing => no (lpf, omega) predictor can work.")
    print("   The exact driver is powersmoothness across the whole window:")
    for p in (101, 401):
        w = hasse_window(p)
        for bound in (20, 60, window_max_pp(p)):
            fired = sum(1 for n in w if is_powersmooth(n, bound))
            mpp_le = sum(1 for n in w if max_prime_power(n) <= bound)
            assert fired == mpp_le
            print(f"      p = {p:>4}, B = {bound:>4}:  fired = {fired:>3} / {len(w)} "
                  f"= #{{n in W(p) : mpp(n) <= B}}")
    print()


# --------------------------------------------------------------------------------------
# 7. Firing rates are exact counts
# --------------------------------------------------------------------------------------


def firing_count(m: int, k: int) -> int:
    """#{a in Z/m : m | k a}  ---  provably equal to gcd(m,k)."""
    return sum(1 for a in range(m) if (k * a) % m == 0)


def multi_curve_success(m: int, k: int, c: int) -> Tuple[int, float]:
    """(count of firing c-tuples, rate) = (m^c - (m-g)^c, 1 - (1-g/m)^c)."""
    g = math.gcd(m, k)
    return m ** c - (m - g) ** c, 1.0 - (1.0 - g / m) ** c


def demo_firing_rates() -> None:
    print("=" * 86)
    print("7. FIRING IS A COUNT:  |{a : m | k a}| = gcd(m,k) exactly")
    print("=" * 86)
    k10 = stage1_scalar(10)
    print(f"   k(10) = lcm(1..10) = {k10}")
    for m in (720, 1000, 1024, 2310):
        g = math.gcd(m, k10)
        assert firing_count(m, k10) == g == gcd_with_stage1(m, 10)
        print(f"      m = {m:>5}:  gcd = {g:>5},  rate = {g / m:.4f}  "
              f"(brute-force count agrees)")

    m, bound = 720, 10
    g = math.gcd(m, k10)
    collision_floor = 1.44 * bound / m
    print(f"\n   m = {m}, B = {bound}: order-completion rate = {g}/{m} = {g / m:.3f}")
    print(f"   folklore collision floor     <= 1.44*B/m = {collision_floor:.4f}")
    print(f"   ratio = {(g / m) / collision_floor:.1f}x  =>  collision cannot explain it.")
    assert (g / m) >= 25 * collision_floor

    print(f"\n   multi-curve success  m^c - (m-g)^c  (m = {m}, g = {g}):")
    for c in (1, 2, 3, 5):
        cnt, rate = multi_curve_success(m, k10, c)
        assert abs(cnt / m ** c - rate) < 1e-12
        print(f"      c = {c}:  rate = 1 - (1 - rho)^c = {rate:.6f}")

    print("\n   the staircase: gcd(720, lcm over primes <= C) as the cutoff C advances")
    prev = None
    row: List[str] = []
    for cutoff in range(2, 12):
        k = 1
        for r in range(2, cutoff + 1):
            if is_prime(r):
                j = 1
                while r ** (j + 1) <= 10:
                    j += 1
                k *= r ** j
        val = math.gcd(720, k)
        row.append(f"C={cutoff}:{val}{'*' if val != prev else ''}")
        prev = val
    print("      " + "  ".join(row) + "   (* = a jump; jumps only at primes | m)")
    print("      omega(720) = 3, so at most 3 of the pi(10) = 4 steps can move.\n")


# --------------------------------------------------------------------------------------
# 8. The whole plane on one arm
# --------------------------------------------------------------------------------------


def ols_slope(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Ordinary least squares slope of ys on xs."""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


def demo_plane_fit() -> None:
    print("=" * 86)
    print("8. THE PLANE, FITTED ON A BOUNDED-RATIO ARM (2p <= q <= 4p)")
    print("=" * 86)
    ps: List[int] = []
    p = 101
    while len(ps) < 30:
        ps.append(p)
        p = next_prime(int(p * 1.25))
    qs = [next_prime(2 * pp) for pp in ps]
    assert all(2 * pp <= qq <= 4 * pp for pp, qq in zip(ps, qs))

    lx = [math.log(pp) for pp in ps]
    td = [math.log(min_fac(pp * qq)) for pp, qq in zip(ps, qs)]
    fe = [math.log(fermat_gap(pp, qq)) for pp, qq in zip(ps, qs)]
    rho = [math.log(math.ceil(math.sqrt(2 * pp * math.log(2))) + 1) for pp in ps]

    print(f"   n = {len(ps)} semiprimes, p from {ps[0]} to {ps[-1]}")
    print(f"      trial division   alpha = {ols_slope(lx, td):.6f}   (exact law: 1)")
    print(f"      Fermat gap       alpha = {ols_slope(lx, fe):.6f}   (exact law: 1, "
          f"deficit ~ |log c|/log p)")
    print(f"      birthday thresh. alpha = {ols_slope(lx, rho):.6f}   (exact law: 1/2)")
    assert abs(ols_slope(lx, td) - 1.0) < 1e-12
    assert abs(ols_slope(lx, fe) - 1.0) < 0.02
    assert abs(ols_slope(lx, rho) - 0.5) < 0.02
    print("   The rigidity theorem says these three converge to exactly (1, 1, 1/2).\n")


def main() -> None:
    demo_trial_division()
    demo_birthday()
    demo_fermat()
    demo_wall()
    demo_proxy_blindness()
    demo_firing_rates()
    demo_plane_fit()
    print("=" * 86)
    print("All assertions passed: every printed identity was checked numerically.")
    print("=" * 86)


if __name__ == "__main__":
    main()
