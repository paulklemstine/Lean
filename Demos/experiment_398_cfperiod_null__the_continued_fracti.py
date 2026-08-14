#!/usr/bin/env python3
"""
Numerical companion to
"The Continued-Fraction Period of sqrt(N) as a Symmetric Channel:
 Structure Without Leverage".

Everything is self-contained: pure standard library, exact integer arithmetic,
type hints throughout.  Running `python3 demo.py` reproduces, numerically,
every quantitative claim of the paper:

  1. the PQa state machine and its four integral invariants;
  2. the exact Pell value  h^2 - N q^2 = +- d  at *every* convergent;
  3. period-end units, and the negative-Pell / period-parity dichotomy;
  4. the split-root factoring exit (and its ~3/4 firing rate);
  5. prime-power immunity: sqrt(p^k) can never split p^k;
  6. cheap-window nullity for N = m^2 + 1 and N = m^2 + 2;
  7. sparsity of small-denominator units;
  8. the de-confounding theorem: max partial quotient == 2*isqrt(N), and the
     collapse of the raw correlation after residualizing on isqrt(N);
  9. cost: Fibonacci growth of denominators, and median period / sqrt(N).
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd, isqrt
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------
# 1. The PQa state machine
# --------------------------------------------------------------------------


@dataclass(frozen=True)
class CFState:
    """A state (m, d, h_prev, h, q_prev, q) of the continued fraction of sqrt(N).

    The current complete quotient is (sqrt(N) + m)/d, and h_prev/q_prev, h/q
    are the two most recent convergents.
    """

    m: int
    d: int
    hp: int
    h: int
    qp: int
    q: int


INIT: CFState = CFState(m=0, d=1, hp=0, h=1, qp=1, q=0)


def step(n: int, s: CFState, a: int) -> CFState:
    """One PQa step with an arbitrary integer partial quotient `a`."""
    m_new: int = s.d * a - s.m
    d_new: int = (n - m_new * m_new) // s.d
    return CFState(
        m=m_new,
        d=d_new,
        hp=s.h,
        h=a * s.h + s.hp,
        qp=s.q,
        q=a * s.q + s.qp,
    )


def cf_next(n: int, s: CFState) -> CFState:
    """One step of the *actual* continued fraction of sqrt(n)."""
    a: int = (isqrt(n) + s.m) // s.d
    return step(n, s, a)


def cf_states(n: int) -> Iterator[Tuple[int, CFState, int]]:
    """Yield (k, state after k steps, partial quotient used at step k)."""
    s: CFState = INIT
    k: int = 0
    while True:
        a: int = (isqrt(n) + s.m) // s.d
        s = step(n, s, a)
        k += 1
        yield k, s, a


def invariants_hold(n: int, s: CFState) -> bool:
    """Check the four conserved quantities of the machine."""
    return (
        s.d != 0
        and (n - s.m * s.m) % s.d == 0
        and n * s.q == s.h * s.m + s.hp * s.d
        and s.q * s.m + s.qp * s.d == s.h
        and (s.h * s.qp - s.hp * s.q) ** 2 == 1
    )


def is_square(n: int) -> bool:
    r: int = isqrt(n)
    return r * r == n


# --------------------------------------------------------------------------
# 2. Period, fundamental unit, statistics
# --------------------------------------------------------------------------


@dataclass(frozen=True)
class PeriodData:
    """Everything the channel outputs for a single non-square N."""

    n: int
    period: int
    x: int  # period-end convergent numerator  h_l
    y: int  # period-end convergent denominator q_l
    norm: int  # x^2 - N y^2, equal to +1 or -1
    quotients: Tuple[int, ...]
    a0: int  # isqrt(N), the "size coordinate"


def period_data(n: int, max_steps: int = 2_000_000) -> PeriodData:
    """Run the machine until d returns to 1: that is the end of the period."""
    if is_square(n):
        raise ValueError(f"{n} is a perfect square")
    qs: List[int] = []
    for k, s, a in cf_states(n):
        qs.append(a)
        if s.d == 1:
            # The period's quotient sequence is a_1, ..., a_l; the terminal
            # quotient a_l = 2*isqrt(N) is the one consumed by the *next* step.
            a_last: int = (isqrt(n) + s.m) // s.d
            return PeriodData(
                n=n,
                period=k,
                x=s.h,
                y=s.q,
                norm=s.h * s.h - n * s.q * s.q,
                quotients=tuple(qs[1:] + [a_last]),
                a0=isqrt(n),
            )
        if k >= max_steps:
            raise RuntimeError(f"period of sqrt({n}) exceeds {max_steps} steps")
    raise RuntimeError("unreachable")


# --------------------------------------------------------------------------
# 3. The split-root factoring exit
# --------------------------------------------------------------------------


def split_root_factor(n: int, x: int) -> Optional[int]:
    """If x is a *split* square root of 1 mod n, return a proper factor."""
    if (x * x - 1) % n != 0:
        return None
    if (x - 1) % n == 0 or (x + 1) % n == 0:
        return None
    g: int = gcd(x - 1, n)
    return g if 1 < g < n else None


def channel_factor(n: int) -> Optional[int]:
    """Attempt to factor n through the continued-fraction channel.

    Cost: one full period (norm +1) or two (norm -1, where the unit is squared
    to reach norm +1).  This is Theta(sqrt(N)) work in general.
    """
    pd: PeriodData = period_data(n)
    x, y = pd.x, pd.y
    if pd.norm == -1:
        # (x + y sqrt N)^2 has norm +1
        x, y = x * x + n * y * y, 2 * x * y
    return split_root_factor(n, x % n)


# --------------------------------------------------------------------------
# 4. Small helpers
# --------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    sieve: List[bool] = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for p in range(2, isqrt(limit) + 1):
        if sieve[p]:
            for t in range(p * p, limit + 1, p):
                sieve[t] = False
    return [i for i, ok in enumerate(sieve) if ok]


def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    n: int = len(xs)
    if n < 2:
        return float("nan")
    mx: float = sum(xs) / n
    my: float = sum(ys) / n
    sxy: float = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sxx: float = sum((x - mx) ** 2 for x in xs)
    syy: float = sum((y - my) ** 2 for y in ys)
    if sxx <= 0 or syy <= 0:
        return float("nan")
    return sxy / (sxx * syy) ** 0.5


def residualize(ys: Sequence[float], xs: Sequence[float]) -> List[float]:
    """Least-squares residuals of ys after regressing on xs (with intercept)."""
    n: int = len(xs)
    mx: float = sum(xs) / n
    my: float = sum(ys) / n
    sxx: float = sum((x - mx) ** 2 for x in xs)
    if sxx <= 0:
        return [y - my for y in ys]
    beta: float = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / sxx
    return [y - (my + beta * (x - mx)) for x, y in zip(xs, ys)]


def median(vals: Sequence[float]) -> float:
    v: List[float] = sorted(vals)
    n: int = len(v)
    return v[n // 2] if n % 2 else 0.5 * (v[n // 2 - 1] + v[n // 2])


def banner(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


# --------------------------------------------------------------------------
# Demo 1: invariants and the exact Pell value
# --------------------------------------------------------------------------


def demo_invariants() -> None:
    banner("1. The four invariants and the exact Pell value  h^2 - N q^2 = +- d")
    for n in (13, 21, 61, 1009):
        ok_inv: bool = True
        ok_pell: bool = True
        for k, s, _a in cf_states(n):
            ok_inv &= invariants_hold(n, s)
            ok_pell &= (s.h * s.h - n * s.q * s.q) == s.d * (s.h * s.qp - s.hp * s.q)
            if k >= 60:
                break
        print(f"  N = {n:5d}:  invariants hold for 60 steps: {ok_inv};  "
              f"h^2 - N q^2 = +-d exactly: {ok_pell}")

    print("\n  Trace for N = 21  (period 6):")
    print(f"    {'k':>2} {'a':>3} {'m':>3} {'d':>3} {'h':>6} {'q':>4} "
          f"{'h^2-Nq^2':>9}")
    for k, s, a in cf_states(21):
        print(f"    {k:2d} {a:3d} {s.m:3d} {s.d:3d} {s.h:6d} {s.q:4d} "
              f"{s.h * s.h - 21 * s.q * s.q:9d}")
        if k >= 7:
            break


# --------------------------------------------------------------------------
# Demo 2: periods, units, and the negative-Pell dichotomy
# --------------------------------------------------------------------------


def demo_periods_and_units() -> None:
    banner("2. Periods, fundamental units, and the negative-Pell dichotomy")
    print("  N :  l  unit (x, y)                       x^2 - N y^2")
    for n in range(2, 41):
        if is_square(n):
            continue
        pd = period_data(n)
        if n <= 31:
            print(f"  {n:3d}: {pd.period:2d}  ({pd.x}, {pd.y})"
                  .ljust(42) + f"{pd.norm:+d}")

    odd_period = [n for n in range(2, 200) if not is_square(n)
                  and period_data(n).period % 2 == 1]
    neg_pell = [n for n in range(2, 200) if not is_square(n)
                and period_data(n).norm == -1]
    print(f"\n  odd period  <=>  norm -1 (negative Pell soluble): "
          f"{odd_period == neg_pell}")
    print(f"  such N below 200: {neg_pell[:14]} ...")

    bad = [n for n in neg_pell
           if any(p % 4 == 3 for p in prime_factors(n))]
    print(f"  any of them with a prime factor = 3 mod 4?  {bad}  (must be empty)")


def prime_factors(n: int) -> List[int]:
    fs: List[int] = []
    d: int = 2
    while d * d <= n:
        while n % d == 0:
            fs.append(d)
            n //= d
        d += 1
    if n > 1:
        fs.append(n)
    return fs


# --------------------------------------------------------------------------
# Demo 3: the split-root exit
# --------------------------------------------------------------------------


def demo_split_root() -> None:
    banner("3. The split-root exit: when the period-end unit factors N")
    for n in (21, 33, 65, 91, 143):
        pd = period_data(n)
        f = channel_factor(n)
        print(f"  N = {n:4d} = {'*'.join(map(str, prime_factors(n))):9s} "
              f"l = {pd.period:3d}  unit ({pd.x}, {pd.y}) norm {pd.norm:+d}  "
              f"-> factor {f}")

    semis: List[int] = []
    primes = primes_up_to(120)
    for i, p in enumerate(primes[1:], start=1):  # skip 2: odd semiprimes only
        for q in primes[i + 1:]:
            n = p * q
            if 15 <= n <= 4000 and not is_square(n):
                semis.append(n)
    semis = sorted(set(semis))
    hits = sum(1 for n in semis if channel_factor(n) is not None)
    print(f"\n  odd semiprimes tested: {len(semis)};  channel found a factor "
          f"in {hits} ({hits / len(semis):.3f}) -- compare the conjectured 3/4")


# --------------------------------------------------------------------------
# Demo 4: prime-power immunity
# --------------------------------------------------------------------------


def demo_prime_power_immunity() -> None:
    banner("4. Prime-power immunity: sqrt(p^k) can never split p^k")
    cases: List[int] = [3 ** 3, 5 ** 3, 7 ** 3, 11 ** 3, 3 ** 5, 13 ** 3]
    for n in cases:
        pd = period_data(n)
        x = pd.x
        if pd.norm == -1:
            x = x * x + n * pd.y * pd.y
        x %= n
        trivial: bool = (x - 1) % n == 0 or (x + 1) % n == 0
        print(f"  N = {n:6d}  l = {pd.period:3d}  unit x mod N = {x:6d}  "
              f"x = +-1 mod N: {trivial}   factor found: {channel_factor(n)}")
    print("\n  Every square root of 1 mod an odd prime power is +-1, so the")
    print("  exit is structurally absent -- no amount of computation helps.")


# --------------------------------------------------------------------------
# Demo 5: cheap-window nullity and sparsity
# --------------------------------------------------------------------------


def demo_cheap_window() -> None:
    banner("5. Cheap-period windows N = m^2 + 1 (l = 1) and N = m^2 + 2 (l = 2)")
    print("  N = m^2 + 1, m even (N odd):  unit m + sqrt(N), norm -1")
    for m in (8, 12, 20, 24, 30):
        n = m * m + 1
        pd = period_data(n)
        gs = (gcd(m, n), gcd(m - 1, n), gcd(m + 1, n))
        print(f"    m = {m:3d}  N = {n:6d} = "
              f"{'*'.join(map(str, prime_factors(n))):12s} l = {pd.period} "
              f"gcds {gs}  -> nothing")

    print("\n  N = m^2 + 2, m odd:  unit x = m^2 + 1, norm +1, but x = -1 mod N")
    for m in (5, 7, 9, 11, 13):
        n = m * m + 2
        x = m * m + 1
        print(f"    m = {m:3d}  N = {n:6d}  x = {x:6d}  "
              f"gcd(x-1, N) = {gcd(x - 1, n)}  x + 1 = N: {x + 1 == n}")

    print("\n  Sparsity: #{N <= X : N y^2 + 1 is a square}  vs bound "
          "isqrt(X y^2 + 1) + 1")
    for y in (1, 2, 3, 5):
        for X in (10_000, 100_000):
            cnt = sum(1 for n in range(X + 1) if is_square(n * y * y + 1))
            print(f"    y = {y}, X = {X:7d}:  count = {cnt:5d}   "
                  f"bound = {isqrt(X * y * y + 1) + 1:7d}")


# --------------------------------------------------------------------------
# Demo 6: de-confounding
# --------------------------------------------------------------------------


def demo_deconfounding() -> None:
    banner("6. De-confounding: max partial quotient IS the size coordinate")
    tested: int = 0
    equal: int = 0
    for n in range(2, 3000):
        if is_square(n):
            continue
        pd = period_data(n)
        tested += 1
        equal += int(max(pd.quotients) == 2 * pd.a0)
    print(f"  max_k a_k == 2*isqrt(N) on {equal}/{tested} non-squares below 3000")

    # A sweep in which the factor spread grows with the size of N -- exactly
    # the situation of the original raw pass.
    small = [p for p in primes_up_to(60) if p > 2]
    large = [q for q in primes_up_to(3000) if q > 200]
    data: List[Tuple[int, int, int]] = []
    for p in small:
        for q in large[::7]:
            n = p * q
            if not is_square(n):
                data.append((n, p, q))
    data.sort()
    data = data[::max(1, len(data) // 300)]

    spread = [float(q - p) for _n, p, q in data]
    a0s = [float(isqrt(n)) for n, _p, _q in data]
    pds = [period_data(n) for n, _p, _q in data]
    maxq = [float(max(pd.quotients)) for pd in pds]
    lens = [float(pd.period) for pd in pds]

    print(f"\n  sample size: {len(data)} semiprimes N = p*q, p < 60 < 200 < q")
    print(f"  raw   corr(max partial quotient, spread) = {pearson(maxq, spread):+.4f}")
    print(f"        corr(isqrt(N),             spread) = {pearson(a0s, spread):+.4f}")
    print(f"        corr(max partial quotient, isqrt N) = "
          f"{pearson(maxq, a0s):+.4f}   <-- the confound")
    rq = residualize(maxq, a0s)
    rl = residualize(lens, a0s)
    rs = residualize(spread, a0s)
    resid_scale = max(abs(v) for v in rq)
    print(f"  after residualizing on isqrt(N):  max |residual of max q| = "
          f"{resid_scale:.3e}  (identically zero: max q is a function of isqrt N)")
    print(f"  partial corr(period | isqrt N, spread | isqrt N) = "
          f"{pearson(rl, rs):+.4f}")
    print("  The raw signal is entirely the size coordinate; nothing survives.")


# --------------------------------------------------------------------------
# Demo 7: cost
# --------------------------------------------------------------------------


def demo_cost() -> None:
    banner("7. Cost: Fibonacci growth of the witness, and period ~ 0.4 sqrt(N)")
    n = 1009
    print(f"  N = {n}:  q_k vs Fibonacci F_k")
    for k, s, _a in cf_states(n):
        print(f"    k = {k:2d}   q = {s.q:10d}   F_{k} = {fib(k):10d}   "
              f"q >= F: {s.q >= fib(k)}")
        if k >= 12:
            break

    ratios: List[float] = []
    for n in range(1000, 4000):
        if is_square(n):
            continue
        pd = period_data(n)
        ratios.append(pd.period / n ** 0.5)
    print(f"\n  median period / sqrt(N) over 1000 <= N < 4000: "
          f"{median(ratios):.3f}   (the reference sweep reports 0.406;"
          f" the ratio drifts up slowly with N)")
    print(f"  max    period / sqrt(N): {max(ratios):.3f}")
    print("  => walking a period costs ~sqrt(N) steps: exponential in log N.")


def main() -> None:
    print(__doc__)
    demo_invariants()
    demo_periods_and_units()
    demo_split_root()
    demo_prime_power_immunity()
    demo_cheap_window()
    demo_deconfounding()
    demo_cost()
    banner("Verdict")
    print("  The channel carries the fundamental unit of Z[sqrt(N)] exactly,")
    print("  and a single congruence bit about the prime factors (all = 1 mod 4")
    print("  iff the period is odd).  Its one factoring exit needs a full")
    print("  period (~0.4 sqrt(N) steps), is absent on prime powers, and is")
    print("  degenerate on the density-zero cheap-period families.")
    print("  Structure: real.  Leverage: zero.")


if __name__ == "__main__":
    main()
