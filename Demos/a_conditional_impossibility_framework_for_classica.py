"""
demo.py -- Numerical demonstrations for
"A Conditional-Impossibility Framework for Classical Integer Factoring".

Self-contained: standard library only (math, cmath, random, fractions, typing).
Run with:  python3 demo.py

The demonstrations mirror, numerically, the theorems of the paper:

  1. Congruence of squares: the reduction is unconditional and free, and for a
     semiprime any nontrivial divisor is one of the two prime factors.
  2. Order finding: an even multiplicative order with a nondegenerate half-power
     yields a factor by one gcd.
  3. The asymptotic ladder: L[alpha,c] is superpolynomial (beats every x^d) and
     subexponential (crushed by every exp(eps*x)); exp(b*x) is not
     subexponential.
  4. Multiplicative trade-off: k*exp(x^(1/k)) is a sharp lower bound for
     sum_i exp(y_i) subject to prod_i y_i = x, attained at the balanced point.
  5. Boundary of the trade-off barrier: at arity k = ceil(log x) the optimum
     drops to O(log x).
  6. Collision blindness: the arithmetic trajectory yields gcd 1 for the first
     min(p,q) steps.
  7. Fourier sample bound K >= r: with K < r samples, two distinct period-r
     signals are indistinguishable; an explicit colliding pair is constructed.
  8. Conditional impossibility, numerically: the ratio barrier/cost for a
     polynomial cost profile diverges.
"""

from __future__ import annotations

import cmath
import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 0. Small utilities
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    """Print a section banner."""
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def is_probable_prime(n: int, rounds: int = 24) -> bool:
    """Miller-Rabin probabilistic primality test."""
    if n < 2:
        return False
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for _ in range(rounds):
        a = random.randrange(2, n - 1)
        y = pow(a, d, n)
        if y in (1, n - 1):
            continue
        for _ in range(s - 1):
            y = (y * y) % n
            if y == n - 1:
                break
        else:
            return False
    return True


def random_prime(bits: int, rng: random.Random) -> int:
    """Return a random probable prime with the given bit length."""
    while True:
        candidate = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_probable_prime(candidate):
            return candidate


# ----------------------------------------------------------------------------
# 1. Congruence of squares (Theorem: the structural core)
# ----------------------------------------------------------------------------


def nontrivial_divisor(n: int, d: int) -> bool:
    """Return True iff d is a divisor of n strictly between 1 and n."""
    return n % d == 0 and 1 < d < n


def congruence_of_squares(n: int, x: int, y: int) -> Optional[int]:
    """Given x^2 = y^2 (mod n) with x != +-y (mod n), return a nontrivial divisor.

    Implements the reduction:  n | (x-y)(x+y),  n does not divide x-y or x+y
    ==> gcd(x-y, n) is a nontrivial divisor of n.
    Returns None if the hypotheses fail.
    """
    if (x * x - y * y) % n != 0:
        return None
    if (x - y) % n == 0 or (x + y) % n == 0:
        return None
    d = math.gcd(x - y, n)
    return d if nontrivial_divisor(n, d) else None


def demo_congruence_of_squares() -> None:
    banner("1. Congruence of squares: the reduction is free and complete")

    # A worked example: 1649 = 17 * 97.  We use 80^2 = 6400 = 3*1649 + 1453,
    # and search a genuine congruence directly.
    n = 1649
    found: List[Tuple[int, int, int]] = []
    for x in range(2, n):
        for y in range(1, x):
            if (x * x - y * y) % n == 0 and (x - y) % n != 0 and (x + y) % n != 0:
                d = math.gcd(x - y, n)
                if nontrivial_divisor(n, d):
                    found.append((x, y, d))
                    break
        if len(found) >= 3:
            break
    print(f"N = {n} = 17 * 97")
    for (x, y, d) in found:
        print(
            f"  x = {x:4d}, y = {y:4d}:  x^2 - y^2 = {x*x - y*y:8d} "
            f"= {(x*x - y*y)//n} * N,  gcd(x-y, N) = {d}"
        )
    print("  Every nontrivial divisor of a semiprime is one of its two primes.")

    # The exceptional case:  x = -y  makes the conclusion fail.
    print()
    print("Sharpness: the hypothesis x != -y (mod N) cannot be dropped.")
    print("  N = 15, x = 4, y = 11:  15 | (4-11)(4+11) = -105,")
    print(f"  but gcd(4-11, 15) = {math.gcd(4 - 11, 15)} is trivial (4 = -11 mod 15).")


# ----------------------------------------------------------------------------
# 2. Order finding (the classical post-processing of period finding)
# ----------------------------------------------------------------------------


def trial_factorization(m: int) -> Dict[int, int]:
    """Prime factorization of m by trial division (m assumed modest in size)."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def order_dividing(a: int, n: int, multiple: int) -> int:
    """Multiplicative order of a mod n, given a known multiple of that order.

    Standard reduction: start from the multiple and divide out each prime power
    as long as the residual exponent still annihilates a.  Cost is
    O(log(multiple)) modular exponentiations.
    """
    order = multiple
    for prime, exponent in trial_factorization(multiple).items():
        for _ in range(exponent):
            if order % prime == 0 and pow(a, order // prime, n) == 1:
                order //= prime
            else:
                break
    return order


def multiplicative_order(a: int, n: int) -> Optional[int]:
    """Return the multiplicative order of a modulo n, or None if gcd(a,n) != 1.

    Uses the Carmichael-style reduction against a known multiple of the order
    when one is cheap to obtain; otherwise falls back to iteration.
    """
    if math.gcd(a, n) != 1:
        return None
    order, value = 1, a % n
    while value != 1:
        value = (value * a) % n
        order += 1
        if order > n:
            return None
    return order


def factor_via_order(n: int, a: int) -> Optional[int]:
    """Factor n from the multiplicative order of a, when the order is usable.

    Requires the order r to be even and a^(r/2) != -1 (mod n).  Then
    n | (a^(r/2) - 1)(a^(r/2) + 1) and gcd(a^(r/2) - 1, n) splits n.
    """
    r = multiplicative_order(a, n)
    if r is None or r % 2 != 0:
        return None
    s = r // 2
    h = pow(a, s, n)
    if (h - 1) % n == 0 or (h + 1) % n == 0:
        return None
    d = math.gcd(h - 1, n)
    return d if nontrivial_divisor(n, d) else None


def demo_order_finding() -> None:
    banner("2. Order finding: an even order with nondegenerate half-power splits N")
    n = 8051  # = 83 * 97
    successes, attempts = 0, 0
    print(f"N = {n} = 83 * 97")
    for a in range(2, 60):
        if math.gcd(a, n) != 1:
            continue
        attempts += 1
        r = multiplicative_order(a, n)
        d = factor_via_order(n, a)
        if d is not None:
            successes += 1
            if successes <= 5:
                print(
                    f"  a = {a:3d}:  order r = {r:5d} (even), "
                    f"gcd(a^(r/2) - 1, N) = {d:3d}  -> factor found"
                )
    print(
        f"  {successes} of {attempts} bases in [2,60) yielded a factor "
        f"({100.0*successes/attempts:.1f}%)."
    )
    print("  Once the period is known, the split costs exactly one gcd.")


# ----------------------------------------------------------------------------
# 3. The asymptotic ladder
# ----------------------------------------------------------------------------


def L_function(alpha: float, c: float, x: float) -> float:
    """L[alpha, c](x) = exp(c * x^alpha * (log x)^(1-alpha)) with x = log N."""
    return math.exp(c * (x ** alpha) * (math.log(x) ** (1.0 - alpha)))


def log_L(alpha: float, c: float, x: float) -> float:
    """log of L[alpha, c](x), for numerically safe comparisons."""
    return c * (x ** alpha) * (math.log(x) ** (1.0 - alpha))


def demo_ladder() -> None:
    banner("3. The asymptotic ladder: L[alpha,c] is superpolynomial and subexponential")

    alpha, c = 1.0 / 3.0, 1.0
    print("Superpolynomiality: log( L[1/3,1](x) / x^d )  ->  +infinity for every d.")
    print(f"{'x':>10} | {'d = 2':>12} | {'d = 5':>12} | {'d = 20':>12}")
    print("-" * 56)
    for x in [1e2, 1e3, 1e4, 1e6, 1e9, 1e12, 1e20]:
        row = [log_L(alpha, c, x) - d * math.log(x) for d in (2.0, 5.0, 20.0)]
        print(f"{x:10.0e} | {row[0]:12.2f} | {row[1]:12.2f} | {row[2]:12.2f}")
    print("  All columns diverge to +infinity: the barrier outgrows every polynomial.")

    print()
    print("Subexponentiality: log( L[1/3,1](x) / exp(eps*x) )  ->  -infinity, all eps>0.")
    print(f"{'x':>10} | {'eps = 1':>14} | {'eps = 0.01':>14} | {'eps = 1e-6':>14}")
    print("-" * 62)
    for x in [1e2, 1e4, 1e6, 1e9, 1e12, 1e20]:
        row = [log_L(alpha, c, x) - eps * x for eps in (1.0, 0.01, 1e-6)]
        print(f"{x:10.0e} | {row[0]:14.2f} | {row[1]:14.2f} | {row[2]:14.2f}")
    print("  All columns diverge to -infinity: every genuine exponential wins.")

    print()
    print("By contrast exp(x/4) is NOT subexponential: test eps = 1/8.")
    print(f"{'x':>10} | {'log( exp(x/4) / exp(x/8) )':>28}")
    print("-" * 42)
    for x in [1e1, 1e2, 1e3, 1e4]:
        print(f"{x:10.0e} | {x / 4.0 - x / 8.0:28.2f}")
    print("  Diverges to +infinity: the randomness barrier sits a whole rung higher.")


# ----------------------------------------------------------------------------
# 4. The multiplicative trade-off barrier (AM-GM)
# ----------------------------------------------------------------------------


def tradeoff_cost(budgets: Sequence[float]) -> float:
    """Total cost sum_i exp(y_i) of a multi-stage strategy."""
    return sum(math.exp(y) for y in budgets)


def tradeoff_lower_bound(k: int, x: float) -> float:
    """The AM-GM lower bound k * exp(x^(1/k)) for a k-way trade-off."""
    return k * math.exp(x ** (1.0 / k))


def random_feasible_budgets(k: int, x: float, rng: random.Random) -> List[float]:
    """Random positive y_1..y_k with prod_i y_i = x exactly (up to float error)."""
    raw = [math.exp(rng.uniform(-1.5, 1.5)) for _ in range(k)]
    scale = (x / math.prod(raw)) ** (1.0 / k)
    return [scale * v for v in raw]


def demo_tradeoff() -> None:
    banner("4. Multiplicative trade-off: k*exp(x^(1/k)) is a sharp lower bound")

    rng = random.Random(20260811)
    x = 500.0
    print(f"Constraint: y_1 * ... * y_k = x = {x}.  Cost = sum_i exp(y_i).")
    print(f"{'k':>3} | {'bound k*e^(x^(1/k))':>22} | {'balanced cost':>16} "
          f"| {'min over 20000 random feasible':>32}")
    print("-" * 84)
    for k in (1, 2, 3, 4, 5):
        bound = tradeoff_lower_bound(k, x)
        balanced = tradeoff_cost([x ** (1.0 / k)] * k)
        best = min(
            tradeoff_cost(random_feasible_budgets(k, x, rng)) for _ in range(20000)
        )
        print(f"{k:3d} | {bound:22.6e} | {balanced:16.6e} | {best:32.6e}")
    print("  The random minimum never dips below the bound, and the balanced")
    print("  point attains it exactly: the exponent 1/k is a balance point,")
    print("  not a design parameter.")


def demo_tradeoff_boundary() -> None:
    banner("5. Boundary of the trade-off barrier: unbounded arity collapses it")
    print("At arity k = ceil(log x) the optimal cost drops to O(log x).")
    print(f"{'x':>12} | {'k = ceil(log x)':>16} | {'k*exp(x^(1/k))':>18} "
          f"| {'e^e*(log x + 1)':>18}")
    print("-" * 74)
    for x in [1e2, 1e3, 1e6, 1e12, 1e30, 1e100]:
        k = max(1, math.ceil(math.log(x)))
        lhs = k * math.exp(x ** (1.0 / k))
        rhs = math.exp(math.e) * (math.log(x) + 1.0)
        print(f"{x:12.0e} | {k:16d} | {lhs:18.4f} | {rhs:18.4f}")
    print("  The left column stays logarithmic: the barrier is a theorem about")
    print("  BOUNDED arity, and it says so.")


# ----------------------------------------------------------------------------
# 6. Collision blindness (the worst-case randomness barrier)
# ----------------------------------------------------------------------------


def arithmetic_trajectory_gcds(p: int, q: int, steps: int) -> int:
    """Count distinct pairs (i,j), i<j<steps, with gcd(i-j, p*q) > 1."""
    n = p * q
    hits = 0
    for i in range(steps):
        for j in range(i):
            if math.gcd(i - j, n) > 1:
                hits += 1
    return hits


def rho_style_steps(n: int, seed: int = 2, max_steps: int = 10 ** 6) -> Optional[int]:
    """Floyd-cycle Pollard rho; return the number of steps to a nontrivial factor."""
    def f(v: int) -> int:
        return (v * v + 1) % n

    tortoise, hare = seed, seed
    for step in range(1, max_steps + 1):
        tortoise = f(tortoise)
        hare = f(f(hare))
        d = math.gcd(abs(tortoise - hare), n)
        if 1 < d < n:
            return step
        if d == n:
            return None
    return None


def demo_collision_barrier() -> None:
    banner("6. Collision blindness: the arithmetic trajectory sees nothing")

    p, q = 101, 103
    n = p * q
    k = min(p, q)
    hits = arithmetic_trajectory_gcds(p, q, k)
    print(f"N = {p} * {q} = {n},  min(p,q) = {k}")
    print(f"  Pairs (i,j) with 0 <= j < i < {k} yielding gcd(i-j, N) > 1: {hits}")
    print("  Exactly zero: every difference has absolute value < min(p,q),")
    print("  so neither p nor q can divide it.  The worst-case provable wall")
    print("  for collision methods is min(p,q) ~ sqrt(N), NOT N^(1/4).")

    print()
    print("For contrast, a pseudorandom trajectory does hit the birthday regime:")
    print(f"{'N = p*q':>14} | {'N^(1/4)':>10} | {'rho steps (x^2+1)':>18}")
    print("-" * 48)
    for (a, b) in [(101, 103), (211, 223), (1009, 1013), (10007, 10009)]:
        m = a * b
        steps = rho_style_steps(m)
        shown = str(steps) if steps is not None else "restart needed"
        print(f"{m:14d} | {m ** 0.25:10.2f} | {shown:>18}")
    print("  The N^(1/4) figure is an average-case birthday phenomenon.")


# ----------------------------------------------------------------------------
# 7. The Fourier sample bound K >= r
# ----------------------------------------------------------------------------


def dft(signal: Sequence[complex]) -> List[complex]:
    """Discrete Fourier transform of a signal on Z/rZ (naive O(r^2))."""
    r = len(signal)
    out: List[complex] = []
    for freq in range(r):
        acc = 0j
        for t, value in enumerate(signal):
            acc += value * cmath.exp(-2j * cmath.pi * freq * t / r)
        out.append(acc)
    return out


def indistinguishable_pair(
    r: int, frequencies: Sequence[int]
) -> Tuple[List[complex], List[complex]]:
    """Construct two distinct period-r signals with equal DFT at the given
    frequencies.  Requires len(frequencies) < r.

    Construction: pick a frequency w not in the sampled set; the pure harmonic
    e_w(t) = exp(2*pi*i*w*t/r) has DFT supported exactly on {w}, so v and
    v + e_w agree at every sampled frequency yet differ as signals.
    """
    sampled = set(f % r for f in frequencies)
    unsampled = [w for w in range(r) if w not in sampled]
    if not unsampled:
        raise ValueError("frequency family already covers all of Z/rZ")
    w = unsampled[0]
    v = [0j] * r
    e_w = [cmath.exp(2j * cmath.pi * w * t / r) for t in range(r)]
    return v, e_w


def demo_fourier_bound() -> None:
    banner("7. The Fourier sample bound: fewer than r samples cannot determine")

    r = 12
    frequencies = [0, 1, 2, 3, 5, 8]  # K = 6 < r = 12
    v, w = indistinguishable_pair(r, frequencies)
    Fv, Fw = dft(v), dft(w)

    print(f"Period r = {r};  K = {len(frequencies)} sampled frequencies "
          f"{frequencies}  (K < r).")
    max_gap = max(abs(Fv[f] - Fw[f]) for f in frequencies)
    signal_gap = max(abs(a - b) for a, b in zip(v, w))
    print(f"  max |DFT(v)(f) - DFT(w)(f)| over sampled f : {max_gap:.3e}")
    print(f"  max |v(t) - w(t)| over all t               : {signal_gap:.3e}")
    print("  Identical readings, genuinely different signals: no choice of")
    print("  K < r frequencies can be determining.  Hence K >= r.")

    print()
    print("Sharpness: sampling ALL r frequencies does determine the signal.")
    unequal = 0
    rng = random.Random(7)
    for _ in range(200):
        a = [complex(rng.uniform(-1, 1), rng.uniform(-1, 1)) for _ in range(r)]
        b = [complex(rng.uniform(-1, 1), rng.uniform(-1, 1)) for _ in range(r)]
        if max(abs(u - t) for u, t in zip(dft(a), dft(b))) < 1e-9:
            unequal += 1
    print(f"  Random distinct pairs with identical FULL transform: {unequal} / 200")
    print("  (Zero, as the transform is a linear isomorphism.)")

    print()
    print("Dimension count, tabulated:")
    print(f"{'r':>5} | {'K':>5} | {'kernel dim >= r-K':>18} | {'determining?':>14}")
    print("-" * 52)
    for (rr, kk) in [(12, 6), (12, 11), (12, 12), (1000, 999), (1000, 1000)]:
        print(f"{rr:5d} | {kk:5d} | {max(0, rr-kk):18d} "
              f"| {'yes' if kk >= rr else 'no':>14}")


# ----------------------------------------------------------------------------
# 8. Conditional impossibility, numerically
# ----------------------------------------------------------------------------


def barrier_cost_log(resource: str, x: float) -> float:
    """log of the classified barrier for a resource, at bit-size x = log N."""
    if resource == "randomness":
        return 0.25 * x
    if resource in ("smoothness", "analog"):
        return log_L(1.0 / 3.0, 1.0, x)
    if resource == "iteration":
        return log_L(0.5, math.sqrt(2.0), x / 2.0)
    raise ValueError(f"unknown resource: {resource}")


def demo_conditional_impossibility() -> None:
    banner("8. Conditional impossibility: barrier / cost diverges for any polynomial")

    resources = ["randomness", "smoothness", "iteration", "analog"]
    degree = 6.0  # a generous polynomial cost profile C(x) = x^6
    print(f"Hypothetical polynomial cost profile C(x) = x^{degree:.0f}.")
    print("Table entries are log10( barrier(x) / C(x) ).")
    header = f"{'x = log N':>12} | " + " | ".join(f"{r:>12}" for r in resources)
    print(header)
    print("-" * len(header))
    for x in [1e2, 1e3, 1e4, 1e6, 1e9, 1e12]:
        log_cost = degree * math.log(x)
        cells = [
            (barrier_cost_log(r, x) - log_cost) / math.log(10.0) for r in resources
        ]
        print(f"{x:12.0e} | " + " | ".join(f"{v:12.3e}" for v in cells))
    print("  Every column diverges: a polynomial-time algorithm would beat every")
    print("  classified barrier by an UNBOUNDED factor, hence is limited by none")
    print("  of them -- so the resource it exploits is outside the catalogue.")

    print()
    print("Non-vacuity: both sides of the conditional are inhabited.")
    print("  cost(x) = L[1/3,1](x)  -> uses a classified resource, not polynomial.")
    print("  cost(x) = x^2          -> polynomial, uses no classified resource.")


# ----------------------------------------------------------------------------
# 9. A closing end-to-end illustration
# ----------------------------------------------------------------------------


def demo_end_to_end() -> None:
    banner("9. End to end: produce a congruence of squares, then split N for free")
    rng = random.Random(31415)
    p = random_prime(16, rng)
    q = random_prime(16, rng)
    while q == p:
        q = random_prime(16, rng)
    n = p * q
    lam = (p - 1) * (q - 1) // math.gcd(p - 1, q - 1)  # lcm(p-1, q-1)
    print(f"Secret primes p = {p}, q = {q};  public N = {n}")

    # Produce the congruence via order finding (the "expensive" half is finding r).
    attempts = 0
    for a in range(2, 500):
        if math.gcd(a, n) != 1:
            continue
        attempts += 1
        # The order is computed here from a known multiple, using the secret
        # primes; in practice, PRODUCING this period is precisely the hard step.
        r = order_dividing(a, n, lam)
        if r % 2 != 0:
            continue
        s = r // 2
        h = pow(a, s, n)
        if (h - 1) % n == 0 or (h + 1) % n == 0:
            continue
        d = math.gcd(h - 1, n)
        if nontrivial_divisor(n, d):
            print(f"  base a = {a}, order r = {r}, half-power a^(r/2) mod N = {h}")
            print(f"  gcd(a^(r/2) - 1, N) = {d},  cofactor = {n // d}")
            print(f"  recovered factorization: {d} * {n // d} = {d * (n // d)}")
            print(f"  (matches the secret primes: {sorted((p, q))})")
            break
    print("  Exploiting the relation cost ONE gcd.  Producing it cost everything.")


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------


def main() -> None:
    print("Numerical demonstrations for the conditional-impossibility framework")
    print("for classical integer factoring.")
    demo_congruence_of_squares()
    demo_order_finding()
    demo_ladder()
    demo_tradeoff()
    demo_tradeoff_boundary()
    demo_collision_barrier()
    demo_fourier_bound()
    demo_conditional_impossibility()
    demo_end_to_end()
    banner("Summary")
    print("  * The congruence-of-squares reduction is unconditional and free.")
    print("  * L[alpha,c] is superpolynomial (0<alpha<=1) and subexponential")
    print("    (0<alpha<1): a rung strictly between polynomial and exponential.")
    print("  * The sieve exponent 1/k is an AM-GM balance point, forced by a")
    print("    multiplicative constraint -- and the barrier holds only at")
    print("    bounded arity.")
    print("  * Collision methods are provably blind for min(p,q) ~ sqrt(N) steps.")
    print("  * Determining a period-r signal by Fourier samples needs K >= r.")
    print("  * Hence: a polynomial-time classical factoring algorithm would have")
    print("    to exploit a resource outside {randomness, smoothness, iteration,")
    print("    analog}.  That is a conditional, not a hardness proof.")


if __name__ == "__main__":
    main()
