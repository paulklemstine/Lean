"""
Numerical demonstrations for:

    Envelope bounds for the Dickman function, an unconditional L[1/2] cost
    floor, and the exact second-moment structure of the quadratic-sieve pool.

Everything here is self-contained: no third-party imports, no external data.
Running `python3 demo.py` prints five demonstrations.

    1. Numerical integration of the Dickman delay equation, checked against the
       closed form rho(u) = 1 - log u on (1, 2].
    2. The leading-term surrogate L(u) = exp(-u (log u + log log u - 1)) versus
       the true rho(u): the ~12x overshoot at u = 3, persisting through u = 6.
    3. The rigorous envelope bounds: contraction step, factorial tail
       rho(u) <= 1/floor(u)!, and the shape bound rho(u) <= (e/n)^n.
    4. The unconditional sub-exponential cost floor
       exp(b)/rho(L/b) >= exp(2 sqrt(L log 2) - 2 log 2), verified over a grid
       of b, together with the sharpened Legendre-transform floor
       sqrt(2 L log L) - sqrt(L).
    5. The exact moment identities for the quadratic-sieve hit pattern
       h_p(a) = #{x mod p : x^2 = a}:
           sum_a (h_p(a) - 1)^2   = p - 1        (zero lag)
           sum_a h_p(a) h_p(a+c)  = p - 1        (every nonzero lag c)
           A(0) - A(c)            = p            (the dichotomy)
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# 1. The Dickman function by numerical integration of the delay equation
# ----------------------------------------------------------------------------


def dickman_table(u_max: float = 8.0, steps_per_unit: int = 2000) -> List[float]:
    """Integrate the delay equation u * rho'(u) = -rho(u-1), rho == 1 on [0,1].

    The scheme is the trapezoidal rule applied to the equivalent integral form

        rho(u + h) = rho(u) - (h/2) * ( rho(u-1)/u + rho(u+h-1)/(u+h) ),

    which is second order and, unlike explicit Euler, stays positive deep into
    the tail.  Because the delay is exactly 1 and 1/h is an integer, both
    delayed values always sit on the grid.

    Complexity: O(u_max * steps_per_unit) time and memory.
    """
    h: float = 1.0 / steps_per_unit
    n_total: int = int(round(u_max * steps_per_unit))
    rho: List[float] = [0.0] * (n_total + 1)
    for k in range(min(steps_per_unit, n_total) + 1):
        rho[k] = 1.0
    for k in range(steps_per_unit, n_total):
        u: float = k * h
        term: float = 0.5 * h * (
            rho[k - steps_per_unit] / u + rho[k + 1 - steps_per_unit] / (u + h)
        )
        rho[k + 1] = max(rho[k] - term, 0.0)
    return rho


def dickman_rho(u: float, table: List[float], steps_per_unit: int = 2000) -> float:
    """Evaluate the tabulated Dickman function by linear interpolation."""
    if u <= 1.0:
        return 1.0
    x: float = u * steps_per_unit
    k: int = int(math.floor(x))
    if k + 1 >= len(table):
        return table[-1]
    frac: float = x - k
    return table[k] * (1.0 - frac) + table[k + 1] * frac


# ----------------------------------------------------------------------------
# 2. The leading-term surrogate
# ----------------------------------------------------------------------------


def dickman_lead(u: float) -> float:
    """L(u) = exp(-u (log u + log log u - 1)), the folklore leading term."""
    return math.exp(-u * (math.log(u) + math.log(math.log(u)) - 1.0))


# ----------------------------------------------------------------------------
# 3. The rigorous envelope bounds
# ----------------------------------------------------------------------------


def factorial_tail_bound(u: float) -> float:
    """rho(u) <= 1 / floor(u)!  for every Dickman majorant and every u >= 0."""
    return 1.0 / math.factorial(int(math.floor(u)))


def shape_bound(u: float) -> float:
    """rho(u) <= (e/n)^n = exp(-n (log n - 1)) with n = floor(u), for u >= 1."""
    n: int = int(math.floor(u))
    if n < 1:
        return 1.0
    return math.exp(-n * (math.log(n) - 1.0))


# ----------------------------------------------------------------------------
# 4. The cost floor
# ----------------------------------------------------------------------------


def cost_exponent_two_pow(big_l: float, b: float) -> float:
    """b + (L/b - 2) log 2: the cost exponent bounded via n! >= 2^(n-1)."""
    return b + (big_l / b - 2.0) * math.log(2.0)


def cost_floor_two_pow(big_l: float) -> float:
    """2 sqrt(L log 2) - 2 log 2: the unconditional floor for the above."""
    return 2.0 * math.sqrt(big_l * math.log(2.0)) - 2.0 * math.log(2.0)


def cost_exponent_stirling(big_l: float, b: float) -> float:
    """b + u (log u - 1) with u = L/b: the sharper model cost exponent."""
    u: float = big_l / b
    return b + u * (math.log(u) - 1.0)


def cost_floor_legendre(big_l: float, ell: float) -> float:
    """2 sqrt(ell * L) - exp(ell): one closed-form floor per ell >= 0."""
    return 2.0 * math.sqrt(ell * big_l) - math.exp(ell)


def cost_floor_sqrt_log(big_l: float) -> float:
    """sqrt(2 L log L) - sqrt(L): the choice ell = (log L)/2."""
    return math.sqrt(2.0 * big_l * math.log(big_l)) - math.sqrt(big_l)


# ----------------------------------------------------------------------------
# 5. The quadratic-sieve hit pattern
# ----------------------------------------------------------------------------


def hit_pattern(p: int) -> List[int]:
    """h_p(a) = #{x in Z/p : x^2 = a}, as a list indexed by a = 0 .. p-1."""
    h: List[int] = [0] * p
    for x in range(p):
        h[(x * x) % p] += 1
    return h


def zero_lag_dispersion(p: int) -> int:
    """sum_a (h_p(a) - 1)^2.  The theorem says this equals p - 1."""
    h: List[int] = hit_pattern(p)
    return sum((v - 1) ** 2 for v in h)


def autocorrelation(p: int, c: int) -> int:
    """A(c) = sum_a h_p(a) h_p(a + c)."""
    h: List[int] = hit_pattern(p)
    return sum(h[a] * h[(a + c) % p] for a in range(p))


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d: int = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


# ----------------------------------------------------------------------------
# Empirical smoothness of x^2 - N (the toy-scale experiment, reproduced)
# ----------------------------------------------------------------------------


def is_smooth(v: int, bound: int) -> bool:
    """Strip all prime factors <= bound by trial division; smooth iff cofactor 1."""
    if v <= 0:
        return False
    d: int = 2
    while d <= bound and v > 1:
        while v % d == 0:
            v //= d
        d += 1 if d == 2 else 2
    return v == 1


def smoothness_sample(
    n_target: int, bound: int, samples: int, seed: int = 12345
) -> Tuple[int, float, float]:
    """Sample x uniformly in [ceil(sqrt N), 2 ceil(sqrt N)], test x^2 - N.

    IMPORTANT: the depth u is computed from the *actual* value v = x^2 - N, not
    from N.  Computing u at N-scale while sampling from a narrow window
    mis-assigns every bin -- the diagnostic is empirical densities above the
    prediction, which is impossible under a correct null.

    Returns (hits, mean depth u of the sampled values, empirical density).
    """
    state: int = seed
    root: int = math.isqrt(n_target) + 1
    hits: int = 0
    u_total: float = 0.0
    log_b: float = math.log(bound)
    for _ in range(samples):
        state = (1103515245 * state + 12345) % (1 << 31)
        x: int = root + state % root
        v: int = x * x - n_target
        u_total += math.log(v) / log_b
        if is_smooth(v, bound):
            hits += 1
    return hits, u_total / samples, hits / samples


# ----------------------------------------------------------------------------
# Drivers
# ----------------------------------------------------------------------------


def demo_1_dickman() -> List[float]:
    print("=" * 78)
    print("1. The Dickman function by numerical integration")
    print("=" * 78)
    table: List[float] = dickman_table()
    print("   closed-form check on (1,2]:  rho(u) = 1 - log u")
    print(f"   {'u':>6} {'integrated':>14} {'1 - log u':>14} {'abs err':>12}")
    for u in (1.25, 1.5, 1.75, 2.0):
        num: float = dickman_rho(u, table)
        exact: float = 1.0 - math.log(u)
        print(f"   {u:6.2f} {num:14.8f} {exact:14.8f} {abs(num - exact):12.2e}")
    print()
    print("   tabulated values past the closed form:")
    print(f"   {'u':>6} {'rho(u)':>16}")
    for u in (2.5, 3.0, 3.5, 4.0, 5.0, 6.0, 8.0):
        print(f"   {u:6.2f} {dickman_rho(u, table):16.9f}")
    print()
    return table


def demo_2_overshoot(table: List[float]) -> None:
    print("=" * 78)
    print("2. The leading-term surrogate overshoots (finding 1)")
    print("=" * 78)
    print(f"   {'u':>6} {'rho(u)':>14} {'L(u)':>14} {'L/rho':>10}")
    for u in (3.0, 3.5, 4.0, 5.0, 6.0):
        r: float = dickman_rho(u, table)
        lead: float = dickman_lead(u)
        ratio: str = f"{lead / r:10.2f}" if r > 0.0 else "       n/a"
        print(f"   {u:6.2f} {r:14.9f} {lead:14.9f} {ratio}")
    print()
    print("   Certified statement (proved for every Dickman majorant):")
    r3_bound: float = (1.0 - math.log(2.0)) / 3.0
    r4_bound: float = (1.0 - math.log(2.0)) / 12.0
    print(f"     rho(3) <= (1 - log 2)/3  = {r3_bound:.6f}   (true {dickman_rho(3.0, table):.6f})")
    print(f"     L(3)                     = {dickman_lead(3.0):.6f} > 5 * {r3_bound:.6f}"
          f" = {5 * r3_bound:.6f}  -> {dickman_lead(3.0) > 5 * r3_bound}")
    print(f"     rho(4) <= (1 - log 2)/12 = {r4_bound:.6f}   (true {dickman_rho(4.0, table):.6f})")
    print(f"     L(4)                     = {dickman_lead(4.0):.6f} > {r4_bound:.6f}"
          f"  -> {dickman_lead(4.0) > r4_bound}")
    print()


def demo_3_envelope(table: List[float]) -> None:
    print("=" * 78)
    print("3. The envelope bounds: factorial tail and u^{-u} shape")
    print("=" * 78)
    print(f"   {'u':>6} {'rho(u)':>14} {'1/floor(u)!':>14} {'(e/n)^n':>14} {'both hold':>11}")
    for u in (1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 7.5):
        r: float = dickman_rho(u, table)
        fb: float = factorial_tail_bound(u)
        sb: float = shape_bound(u)
        print(f"   {u:6.2f} {r:14.9f} {fb:14.9f} {sb:14.9f} "
              f"{str(r <= fb + 1e-12 and r <= sb + 1e-12):>11}")
    print()
    print("   contraction step  rho(u) <= rho(u-1)/u  checked numerically:")
    ok: bool = True
    for k in range(20, 80):
        u = k / 10.0
        if dickman_rho(u, table) > dickman_rho(u - 1.0, table) / u + 1e-9:
            ok = False
    print(f"     holds on the grid u = 2.0 .. 7.9 : {ok}")
    print()


def demo_4_cost_floor() -> None:
    print("=" * 78)
    print("4. The unconditional sub-exponential cost floor")
    print("=" * 78)
    for big_l in (25.0, 100.0, 400.0, 1600.0):
        floor_2: float = cost_floor_two_pow(big_l)
        floor_s: float = cost_floor_sqrt_log(big_l)
        best_2: float = min(cost_exponent_two_pow(big_l, b / 10.0)
                            for b in range(1, int(100 * math.sqrt(big_l))))
        best_s: float = min(cost_exponent_stirling(big_l, b / 10.0)
                            for b in range(1, int(100 * math.sqrt(big_l))))
        print(f"   L = {big_l:8.1f}")
        print(f"     2 sqrt(L log 2) - 2 log 2      = {floor_2:10.4f}"
              f"   attained min of b + (L/b - 2) log 2 = {best_2:10.4f}"
              f"   ok={best_2 >= floor_2 - 1e-9}")
        print(f"     sqrt(2 L log L) - sqrt(L)      = {floor_s:10.4f}"
              f"   attained min of b + u(log u - 1)    = {best_s:10.4f}"
              f"   ok={best_s >= floor_s - 1e-9}")
    print()
    print("   the Legendre family 2 sqrt(ell L) - e^ell at L = 400, one floor per ell:")
    print(f"   {'ell':>8} {'floor':>12}")
    for ell in (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, math.log(400.0) / 2.0):
        print(f"   {ell:8.4f} {cost_floor_legendre(400.0, ell):12.4f}")
    print(f"   (the last row is ell = (log L)/2, giving sqrt(2 L log L) - sqrt L)")
    print()


def demo_5_hit_pattern() -> None:
    print("=" * 78)
    print("5. Exact moments of the quadratic-sieve hit pattern")
    print("=" * 78)
    primes: List[int] = [p for p in range(3, 60) if is_prime(p)]
    print(f"   {'p':>5} {'sum h':>7} {'sum (h-1)^2':>12} {'p-1':>6} {'sum h^2':>9}"
          f" {'2p-1':>6} {'disp':>8}")
    for p in primes:
        h: List[int] = hit_pattern(p)
        s1: int = sum(h)
        s2: int = zero_lag_dispersion(p)
        sq: int = sum(v * v for v in h)
        print(f"   {p:5d} {s1:7d} {s2:12d} {p - 1:6d} {sq:9d} {2 * p - 1:6d}"
              f" {s2 / p:8.4f}")
    print()
    print("   pair correlation A(c) = sum_a h(a) h(a+c) at every nonzero lag:")
    for p in (7, 11, 13, 17, 19, 23):
        values: Dict[int, int] = {c: autocorrelation(p, c) for c in range(1, p)}
        distinct = sorted(set(values.values()))
        a0: int = autocorrelation(p, 0)
        print(f"     p = {p:3d}:  A(0) = {a0:4d},  A(c) for c != 0 in {distinct}"
              f",  A(0) - A(c) = {a0 - distinct[0]:3d}  (= p: {a0 - distinct[0] == p})")
    print()
    print("   dispersion 1 - 1/p never falls below 1/2 and increases to 1:")
    for p in (3, 11, 101, 1009):
        if is_prime(p):
            print(f"     p = {p:5d}:  (1/p) sum (h-1)^2 = {zero_lag_dispersion(p) / p:.6f}"
                  f"   1 - 1/p = {1 - 1 / p:.6f}")
    print()


def demo_6_toy_experiment(table: List[float]) -> None:
    print("=" * 78)
    print("6. The toy-scale smoothness experiment, reproduced (the null)")
    print("=" * 78)
    print(f"   {'N':>12} {'B':>6} {'n':>6} {'mean u':>8} {'empirical':>11}"
          f" {'rho(u)':>10} {'ratio':>8}")
    cells: List[Tuple[int, int, int]] = [
        (10_007 * 10_009, 200, 400),
        (10_007 * 10_009, 500, 400),
        (100_003 * 100_019, 500, 300),
        (100_003 * 100_019, 1500, 300),
        (1_000_003 * 1_000_033, 1500, 200),
        (1_000_003 * 1_000_033, 4000, 200),
    ]
    for n_target, bound, samples in cells:
        hits, u_mean, dens = smoothness_sample(n_target, bound, samples)
        pred: float = dickman_rho(u_mean, table)
        ratio: str = f"{dens / pred:8.2f}" if pred > 0 and dens > 0 else "     n/a"
        print(f"   {n_target:12d} {bound:6d} {samples:6d} {u_mean:8.2f} {dens:11.4f}"
              f" {pred:10.5f} {ratio}")
    print()
    print("   The ratios scatter non-monotonically and the per-bin standard error is")
    print("   of the same order as the estimate: at this scale the fourth stratum")
    print("   cannot be measured.  What can be proved is the floor of demo 4 and the")
    print("   exact hit-pattern identities of demo 5.")
    print()


def main() -> None:
    table = demo_1_dickman()
    demo_2_overshoot(table)
    demo_3_envelope(table)
    demo_4_cost_floor()
    demo_5_hit_pattern()
    demo_6_toy_experiment(table)


if __name__ == "__main__":
    main()
