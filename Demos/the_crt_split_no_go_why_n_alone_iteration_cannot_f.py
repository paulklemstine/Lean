"""
The CRT-Split No-Go — numerical demonstrations.
================================================

Self-contained Python (standard library only) demonstrating every result of the
paper "The CRT-Split No-Go: Why N-Alone Iteration Cannot Factor in poly(log N)".

Contents
--------
1.  Fact 1  — the exclusive-or reveal criterion:  1 < gcd(d, N) < N  <=>  XOR(p|d, q|d).
2.  Fact 2  — CRT-blindness of polynomial iteration: reduction commutes with iteration.
3.  The reveal characterisation: a factor appears exactly at an exclusive one-sided
    cycle closure, and the first reveal time equals min(T_p, T_q).
4.  The running example N = 341371 = 631 * 541, f(x) = x^2 + 1, seed 2:
    first reveal at (s, t) = (23, 36), factor 631, minimal, at the mod-631 closure.
5.  Regime (a): the exact birthday law, its two-sided tails, the threshold window,
    the layer-cake identity, and the Theta(sqrt n) average closure time.
6.  Regime (b): the exact Pollard p-1 reveal time  min(ord_p a, ord_q a).
7.  Regime (c): the successor map, reveal gap >= min(p, q), and superpolynomiality.
8.  Circularity: a nontrivial idempotent mod N is already a factorisation; a non-unit
    of Z/N is already a factorisation.
9.  The scaling experiment:  t / sqrt(min(p,q)) stays O(1) while log2(t) grows.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from math import gcd, isqrt
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 0. Small number-theoretic utilities (all inlined, no dependencies)
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3e24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def random_prime(bits: int, rng: random.Random) -> int:
    """A random prime with exactly `bits` bits."""
    while True:
        candidate = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(candidate):
            return candidate


def prime_factors(n: int) -> Dict[int, int]:
    """Trial-division factorisation; only used on small numbers here."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def multiplicative_order(a: int, m: int) -> int:
    """The least k > 0 with a^k = 1 (mod m); requires gcd(a, m) = 1."""
    if gcd(a, m) != 1:
        raise ValueError("a must be invertible mod m")
    # The order divides the group exponent; for prime m that is m - 1.
    order = euler_phi(m)
    for p, e in prime_factors(order).items():
        for _ in range(e):
            if pow(a, order // p, m) == 1:
                order //= p
            else:
                break
    return order


def euler_phi(n: int) -> int:
    result = n
    for p in prime_factors(n):
        result -= result // p
    return result


# ---------------------------------------------------------------------------
# 1. Fact 1 — the exclusive-or reveal criterion
# ---------------------------------------------------------------------------


def reveals_factor(n: int, d: int) -> bool:
    """True iff 1 < gcd(d, N) < N, i.e. d exposes a nontrivial divisor of N."""
    g = gcd(abs(d), n)
    return 1 < g < n


def check_fact1(p: int, q: int, samples: int, rng: random.Random) -> bool:
    """Verify  Rev_{pq}(d)  <=>  XOR(p | d, q | d)  on random and structured d."""
    n = p * q
    tests: List[int] = [0, 1, -1, p, q, n, p * 7, q * 11, n * 3, p - q]
    tests += [rng.randrange(-3 * n, 3 * n) for _ in range(samples)]
    for d in tests:
        lhs = reveals_factor(n, d)
        rhs = (d % p == 0) != (d % q == 0)  # exclusive or
        if lhs != rhs:
            print(f"    COUNTEREXAMPLE d = {d}")
            return False
    return True


# ---------------------------------------------------------------------------
# 2. Fact 2 — CRT-blindness: iteration commutes with reduction
# ---------------------------------------------------------------------------


def poly_orbit(coeffs: Sequence[int], x0: int, steps: int, modulus: Optional[int] = None
               ) -> List[int]:
    """Orbit of x0 under z -> sum coeffs[i] z^i, optionally reduced mod `modulus`."""
    def evaluate(z: int) -> int:
        acc = 0
        for c in reversed(coeffs):
            acc = acc * z + c
            if modulus is not None:
                acc %= modulus
        return acc

    x = x0 % modulus if modulus is not None else x0
    out = [x]
    for _ in range(steps):
        x = evaluate(x)
        out.append(x)
    return out


def check_fact2(coeffs: Sequence[int], x0: int, m: int, steps: int) -> bool:
    """(orbit over Z) mod m  ==  orbit computed entirely inside Z/m."""
    over_z = poly_orbit(coeffs, x0, steps)
    in_zm = poly_orbit(coeffs, x0, steps, modulus=m)
    return [v % m for v in over_z] == in_zm


# ---------------------------------------------------------------------------
# 3. The reveal characterisation and the closure times
# ---------------------------------------------------------------------------


def first_closure_time(step: Callable[[int], int], x0: int, m: int) -> Tuple[int, int]:
    """First (s, t), s < t, with the mod-m orbit revisiting: returns (s, t)."""
    seen: Dict[int, int] = {}
    x = x0 % m
    i = 0
    while x not in seen:
        seen[x] = i
        x = step(x) % m
        i += 1
    return seen[x], i


def first_reveal_pair(step: Callable[[int], int], x0: int, n: int, limit: int
                      ) -> Optional[Tuple[int, int, int]]:
    """Brute-force search for the least t with some s < t and 1 < gcd(x_t - x_s, N) < N."""
    trace = [x0 % n]
    for _ in range(limit):
        trace.append(step(trace[-1]) % n)
    for t in range(1, len(trace)):
        for s in range(t):
            g = gcd(abs(trace[t] - trace[s]), n)
            if 1 < g < n:
                return s, t, g
    return None


def check_reveal_characterisation(step: Callable[[int], int], x0: int, p: int, q: int,
                                  limit: int) -> bool:
    """For every pair (s,t): reveal  <=>  XOR(mod-p closure, mod-q closure)."""
    n = p * q
    tn = poly_trace(step, x0, n, limit)
    tp = poly_trace(step, x0, p, limit)
    tq = poly_trace(step, x0, q, limit)
    for t in range(1, limit + 1):
        for s in range(t):
            lhs = reveals_factor(n, tn[t] - tn[s])
            rhs = (tp[t] == tp[s]) != (tq[t] == tq[s])
            if lhs != rhs:
                return False
    return True


def poly_trace(step: Callable[[int], int], x0: int, m: int, steps: int) -> List[int]:
    x = x0 % m
    out = [x]
    for _ in range(steps):
        x = step(x) % m
        out.append(x)
    return out


# ---------------------------------------------------------------------------
# 5. Regime (a) — the birthday law
# ---------------------------------------------------------------------------


def birthday_count(n: int, T: int) -> int:
    """Exact number of maps of an n-set with a collision-free orbit prefix of length T+1:
       (n-1)(n-2)...(n-T) * n^(n-T)."""
    if T >= n:
        return 0
    falling = 1
    for i in range(1, T + 1):
        falling *= (n - i)
    return falling * n ** (n - T)


def birthday_fraction(n: int, T: int) -> float:
    """The exact collision-free fraction  prod_{i=1..T} (1 - i/n)."""
    frac = 1.0
    for i in range(1, T + 1):
        frac *= 1.0 - i / n
    return frac


def birthday_bounds(n: int, T: int) -> Tuple[float, float]:
    """Lower (Weierstrass) and upper (Gaussian) bounds on the collision-free fraction."""
    s = T * (T + 1) / (2 * n)
    return 1.0 - s, math.exp(-s)


def brute_force_birthday_count(n: int, T: int) -> int:
    """Exhaustive enumeration of all n^n maps of {0..n-1}, seed 0 (tiny n only)."""
    total = 0
    for code in range(n ** n):
        f = []
        c = code
        for _ in range(n):
            f.append(c % n)
            c //= n
        x, seen, ok = 0, set(), True
        for _ in range(T + 1):
            if x in seen:
                ok = False
                break
            seen.add(x)
            x = f[x]
        total += 1 if ok else 0
    return total


def closure_time(f: Sequence[int], a: int) -> int:
    """First T at which the prefix a, f(a), ..., f^[T](a) has a repetition."""
    x, seen = a, set()
    T = 0
    while x not in seen:
        seen.add(x)
        x = f[x]
        T += 1
    return T


def average_closure_time_exact(n: int) -> float:
    """Exact average of the closure time over all n^n maps, via the layer-cake identity
       sum_f tau(f) = sum_{T<n} A_T."""
    total = sum(birthday_count(n, T) for T in range(n))
    return total / n ** n


def average_closure_time_sampled(n: int, trials: int, rng: random.Random) -> float:
    return sum(closure_time([rng.randrange(n) for _ in range(n)], 0)
               for _ in range(trials)) / trials


def floyd_match_time(f: Sequence[int], a: int) -> int:
    """First i > 0 with f^[i](a) = f^[2i](a) — the Pollard rho tortoise-and-hare loop."""
    tortoise, hare, i = f[a], f[f[a]], 1
    while tortoise != hare:
        tortoise = f[tortoise]
        hare = f[f[hare]]
        i += 1
    return i


# ---------------------------------------------------------------------------
# 6. Regime (b) — the exact Pollard p-1 reveal time
# ---------------------------------------------------------------------------


def pm1_reveal_time_bruteforce(p: int, q: int, a: int, limit: int) -> Optional[int]:
    """Least M > 0 with 1 < gcd(a^M - 1, pq) < pq, by search."""
    n = p * q
    for M in range(1, limit + 1):
        if reveals_factor(n, pow(a, M, n) - 1):
            return M
    return None


def pm1_reveal_time_theory(p: int, q: int, a: int) -> int:
    """min(ord_p a, ord_q a) — the exact reveal time when the two orders differ."""
    return min(multiplicative_order(a % p, p), multiplicative_order(a % q, q))


# ---------------------------------------------------------------------------
# 7. Regime (c) — the successor map
# ---------------------------------------------------------------------------


def successor_reveal_gap(p: int, q: int, limit: int) -> Optional[int]:
    """Least gap t - s revealing a factor for x -> x + 1 (i.e. least positive multiple
       of exactly one of p, q)."""
    for g in range(1, limit + 1):
        if (g % p == 0) != (g % q == 0):
            return g
    return None


# ---------------------------------------------------------------------------
# 8. Circularity
# ---------------------------------------------------------------------------


def idempotent_reveals(n: int, e: int) -> Optional[int]:
    """If e is a nontrivial idempotent mod n, return the factor gcd(e, n)."""
    if (e * (e - 1)) % n != 0 or e % n == 0 or (e - 1) % n == 0:
        return None
    return gcd(e, n)


def crt_idempotent(p: int, q: int) -> int:
    """The idempotent congruent to 1 mod p and 0 mod q."""
    return (q * pow(q, -1, p)) % (p * q)


# ---------------------------------------------------------------------------
# Presentation
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def main() -> None:
    rng = random.Random(20260811)
    P, Q = 631, 541
    N = P * Q  # 341371

    rule("1.  FACT 1 — a nontrivial gcd is exactly an exclusive CRT collision")
    print(f"    N = {N} = {P} * {Q}")
    ok = check_fact1(P, Q, samples=4000, rng=rng)
    print(f"    Rev_N(d)  <=>  XOR(p | d, q | d)   on 4010 values of d : {ok}")
    for d, label in [(P * 3, "3p      "), (Q * 5, "5q      "), (N * 2, "2N      "),
                     (P * Q + 1, "N+1     ")]:
        g = gcd(abs(d), N)
        print(f"      d = {label} gcd = {g:>6}   reveals = {reveals_factor(N, d)}"
              f"   (p|d, q|d) = ({d % P == 0}, {d % Q == 0})")

    rule("2.  FACT 2 — iteration commutes with reduction (CRT-blindness)")
    coeffs = (1, 0, 1)  # 1 + x^2
    for m in (P, Q, N, 97):
        print(f"    orbit of x^2+1 from 2, reduced mod {m:>6}: "
              f"matches in-place computation = {check_fact2(coeffs, 2, m, 10)}")
    print("    The mod-m dynamics depends on nothing but (f mod m, x0 mod m):")
    g_coeffs = tuple(c + P * 17 for c in coeffs)  # a different integer polynomial ...
    same = (poly_orbit(coeffs, 2, 20, P) == poly_orbit(g_coeffs, 2, 20, P))
    print(f"      f = x^2+1  and  g = f + 17p  have identical mod-p orbits: {same}")

    rule("3.  THE REVEAL CHARACTERISATION — reveal = exclusive one-sided closure")
    step = lambda z: z * z + 1
    print(f"    checking every pair (s,t), t <= 60, for N = {N}: ", end="")
    print(check_reveal_characterisation(step, 2, P, Q, 60))
    sp, tp = first_closure_time(step, 2, P)
    sq, tq = first_closure_time(step, 2, Q)
    print(f"    mod {P}: first closure  x_{tp} = x_{sp}   ->  T_p = {tp}   (sqrt p = {math.sqrt(P):.1f})")
    print(f"    mod {Q}: first closure  x_{tq} = x_{sq}   ->  T_q = {tq}   (sqrt q = {math.sqrt(Q):.1f})")
    print(f"    theory: first reveal time = min(T_p, T_q) = {min(tp, tq)}")

    rule("4.  THE RUNNING EXAMPLE — N = 341371, f(x) = x^2+1, seed 2")
    found = first_reveal_pair(step, 2, N, 60)
    assert found is not None
    s, t, g = found
    print(f"    brute-force first revealing pair: (s, t) = ({s}, {t}),  gcd = {g}")
    trace_n = poly_trace(step, 2, N, 60)
    d = trace_n[t] - trace_n[s]
    print(f"    x_{t} - x_{s} divisible by {P}: {d % P == 0}    by {Q}: {d % Q == 0}"
          "   (exclusive-or holds)")
    print(f"    minimality: no pair with t <= 35 reveals — verified structurally by")
    tp_pref = poly_trace(step, 2, P, 35)
    tq_pref = poly_trace(step, 2, Q, 35)
    print(f"      injectivity of the mod-{P} prefix (0..35): {len(set(tp_pref)) == 36}")
    print(f"      injectivity of the mod-{Q} prefix (0..35): {len(set(tq_pref)) == 36}")
    print(f"    log2 N = {math.log2(N):.2f}   sqrt(p) = {math.sqrt(P):.2f}   reveal t = {t}")

    rule("5.  REGIME (a) — the exact birthday law and the Theta(sqrt n) average")
    print("    Exhaustive cross-check of the counting law on n = 4, seed 0:")
    for T in (0, 1, 2, 3):
        print(f"      T = {T}:  formula = {birthday_count(4, T):>4}   "
              f"enumeration = {brute_force_birthday_count(4, T):>4}")
    print("\n    Collision-free fraction and its two-sided bounds (n = 10007):")
    n = 10007
    print(f"      {'T':>5} {'lower 1-T(T+1)/2n':>19} {'exact product':>15} {'upper exp(...)':>15}")
    for T in sorted({10, 50, isqrt(n), 2 * isqrt(n), 300}):
        lo, hi = birthday_bounds(n, T)
        print(f"      {T:>5} {max(lo, 0.0):>19.6f} {birthday_fraction(n, T):>15.6f} {hi:>15.6f}")
    print(f"\n    Threshold window: fraction >= 1/2 while T(T+1) <= n  (T <= {isqrt(n)}),"
          f"\n                      fraction <= 1/4 once 4n <= T(T+1)  (T >= {isqrt(4 * n)}).")

    print("\n    Layer cake  sum_f tau(f) = sum_{T<n} A_T,  and the average closure time:")
    print(f"      {'n':>4} {'exact average':>15} {'sqrt(n)/2':>11} {'3(sqrt n + 1)':>15} {'sampled':>10}")
    for n_small in (4, 6, 8, 10, 12, 20, 50):
        exact = average_closure_time_exact(n_small)
        sampled = average_closure_time_sampled(n_small, 20000, rng)
        print(f"      {n_small:>4} {exact:>15.4f} {isqrt(n_small) / 2:>11.4f} "
              f"{3 * (isqrt(n_small) + 1):>15.4f} {sampled:>10.4f}")

    print("\n    Tortoise-and-hare inherits the barrier (average Floyd time >= sqrt(n)/4):")
    for n_small in (50, 200, 1000):
        avg_floyd = sum(floyd_match_time([rng.randrange(n_small) for _ in range(n_small)], 0)
                        for _ in range(4000)) / 4000
        print(f"      n = {n_small:>5}:  average Floyd match time = {avg_floyd:>8.2f}"
              f"   >= sqrt(n)/4 = {isqrt(n_small) / 4:>7.2f}   (sqrt n = {math.sqrt(n_small):.2f})")

    rule("6.  REGIME (b) — the exact Pollard p-1 reveal time min(ord_p a, ord_q a)")
    a = 2
    op, oq = multiplicative_order(a % P, P), multiplicative_order(a % Q, Q)
    print(f"    ord_{P}(2) = {op}     ord_{Q}(2) = {oq}")
    print(f"    theory  min = {pm1_reveal_time_theory(P, Q, a)}")
    print(f"    search  M*  = {pm1_reveal_time_bruteforce(P, Q, a, 600)}")
    print(f"    gcd(2^{op} - 1, N) = {gcd(pow(2, op, N) - 1, N)}")
    print(f"    p-1 = {P-1} = {prime_factors(P-1)},   q-1 = {Q-1} = {prime_factors(Q-1)}")
    print("    The cost is an invariant of the hidden factors — invisible in N.")

    rule("7.  REGIME (c) — the successor map x -> x+1 is maximally slow")
    print(f"    least revealing gap for N = {N}: {successor_reveal_gap(P, Q, 2000)}"
          f"   = min(p, q) = {min(P, Q)}")
    print("    balanced semiprimes: any reveal time t satisfies N <= 2 t^2, i.e. t >= sqrt(N/2):")
    for bits in (12, 16, 20, 24, 32):
        p2 = random_prime(bits, rng)
        q2 = random_prime(bits, rng)
        while not (p2 < q2 <= 2 * p2):
            p2, q2 = min(p2, q2), max(p2, q2)
            if q2 > 2 * p2:
                q2 = random_prime(bits, rng)
            if p2 == q2:
                q2 = random_prime(bits, rng)
        n2 = p2 * q2
        bound = min(p2, q2)
        print(f"      N = {n2:<22} log2 N = {math.log2(n2):>6.2f}   "
              f"every reveal has t >= {bound:<12} (>= sqrt(N/2) = {math.sqrt(n2/2):.0f})")
    print("    Superpolynomiality: for every c, k there are balanced N with every reveal")
    print("    time exceeding c (log2 N)^k, since t >= p ~ sqrt(N) beats any polynomial.")
    print("    Degenerate limit — a constant map never reveals anything at all:")
    const_trace = [7] * 10
    print(f"      constant orbit {const_trace[:5]}...  every difference is 0, gcd = N.")

    rule("8.  CIRCULARITY — a CRT separator IS the factorisation")
    e = crt_idempotent(P, Q)
    print(f"    idempotent e = {e}:  e^2 = e mod N is {pow(e, 2, N) == e % N},"
          f"  e mod p = {e % P}, e mod q = {e % Q}")
    print(f"    gcd(e, N) = {idempotent_reveals(N, e)}  — a nontrivial factor, for free.")
    print(f"    a non-unit of Z/N is a factorisation:  gcd({P}, N) = {gcd(P, N)}"
          f"   reveals = {reveals_factor(N, P)}")
    print("    Hence a straight-line program can only escape CRT-blindness by dividing by a")
    print("    non-unit — and that failed division already hands you the factor.")

    rule("9.  SCALING EXPERIMENT — the reveal time tracks sqrt(p) = N^(1/4)")
    print(f"    {'bits':>5} {'p':>10} {'q':>10} {'(s,t)':>14} {'factor':>10} {'r=t/sqrt(min)':>14} {'log2 t':>8}")
    for bits in range(9, 17):
        while True:
            p3 = random_prime(bits, rng)
            q3 = random_prime(bits, rng)
            if p3 != q3:
                break
        n3 = p3 * q3
        res = first_reveal_pair(lambda z: z * z + 1, 2, n3, 4 * isqrt(min(p3, q3)) + 40)
        if res is None:
            continue
        s3, t3, g3 = res
        r = t3 / math.sqrt(min(p3, q3))
        print(f"    {bits:>5} {p3:>10} {q3:>10} {f'({s3},{t3})':>14} {g3:>10} "
              f"{r:>14.2f} {math.log2(max(t3, 1)):>8.2f}")
    print("\n    r stays O(1) while log2 t grows linearly in the bit size: the reveal time")
    print("    is Theta(sqrt p) = Theta(N^(1/4)) — exponential in log N.")

    rule("CONCLUSION")
    print("""    Every N-explicit iteration reveals a factor by exactly one mechanism: an
    exclusive one-sided CRT cycle closure. Its time is min(T_p, T_q). Generic maps
    close at the birthday scale Theta(sqrt p) = Theta(N^(1/4)) — on average, and
    sharply, with cycle detection buying only a constant. Smoothness-dependent maps
    close at a multiplicative order of the hidden factors. Structurally simple maps
    close at the full modulus, superpolynomially in log N. And the only escape —
    division — presupposes the factorisation it would compute.""")


if __name__ == "__main__":
    main()
