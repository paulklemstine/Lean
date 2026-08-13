"""
Numerical demonstration of the cycle-index fingerprint of a semiprime.

For N = p*q and a base b coprime to N, the cycle-index fingerprint is

    F(c) = gcd(b^c - 1, N).

This script verifies, on concrete numbers, every result of the accompanying
paper:

  1. Structure theorem      F(c) = p^[d_p | c] * q^[d_q | c].
  2. Order seal             F(c) = 1 for 0 < c < d* = min(d_p, d_q),
                            and F(d*) is a proper nontrivial factor of N
                            whenever d_p != d_q.
  3. Valuation spectrum     sum_{c|d} mu(d/c) v_p(F(c)) = [d_p = d],
                            and its window sum = [d_p <= D].
  4. Four-atom spectrum     M_d = [d=1] + (p-1)[d_p=d] + (q-1)[d_q=d]
                                  + phi(N)[n=d],  n = lcm(d_p, d_q).
  5. Starvation             on families with min(d_p,d_q) > D the truncated
                            fingerprint window is constant, hence carries
                            exactly zero information about (p+q) mod l,
                            in the exact counting sense; and the property
                            fails as soon as the window reaches the order
                            scale.
  6. Burnside orbit count   #Fix(b^k) = F(k), and
                            C*n = n + (p-1)(n/d_p) + (q-1)(n/d_q) + phi(N);
                            in the balanced case d_p = d_q = d,
                            C*d = d + N - 1 (no leak).
  7. Exponent invariance    a constant-factor speedup leaves log T / log T'
                            tending to 1; a power speedup moves it to theta.

No third-party dependencies are required.
"""

from __future__ import annotations

import math
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Instance = Tuple[int, int, int]  # (p, q, b)


# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
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


def divisors(n: int) -> List[int]:
    """Sorted list of positive divisors of n >= 1."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def moebius(n: int) -> int:
    """The Moebius function mu(n) for n >= 1."""
    if n == 1:
        return 1
    result = 1
    m = n
    f = 2
    while f * f <= m:
        if m % f == 0:
            m //= f
            if m % f == 0:
                return 0
            result = -result
        f += 1
    if m > 1:
        result = -result
    return result


def multiplicative_order(b: int, m: int) -> int:
    """Least k > 0 with b^k = 1 (mod m); requires gcd(b, m) = 1 and m > 1."""
    if math.gcd(b, m) != 1:
        raise ValueError("base must be coprime to the modulus")
    k, value = 1, b % m
    while value != 1:
        value = (value * b) % m
        k += 1
    return k


def p_adic_valuation(n: int, p: int) -> int:
    """Exponent of the prime p in n >= 1."""
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


# ----------------------------------------------------------------------------
# The fingerprint and its spectra
# ----------------------------------------------------------------------------

def fingerprint(b: int, N: int, c: int) -> int:
    """F(c) = gcd(b^c - 1, N), computed with modular exponentiation."""
    return math.gcd((pow(b, c, N) - 1) % N, N)


def raw_mobius_coefficient(b: int, N: int, d: int) -> int:
    """M_d = sum_{c | d} mu(d/c) F(c); computable from N and b alone."""
    return sum(moebius(d // c) * fingerprint(b, N, c) for c in divisors(d))


def valuation_mobius_coefficient(b: int, N: int, p: int, d: int) -> int:
    """M^{(p)}_d = sum_{c | d} mu(d/c) v_p(F(c)); uses knowledge of p."""
    return sum(
        moebius(d // c) * p_adic_valuation(fingerprint(b, N, c), p)
        for c in divisors(d)
    )


def window(b: int, N: int, D: int) -> Tuple[int, ...]:
    """The truncated fingerprint (F(1), ..., F(D))."""
    return tuple(fingerprint(b, N, c) for c in range(1, D + 1))


# ----------------------------------------------------------------------------
# Counting independence (exact zero information)
# ----------------------------------------------------------------------------

def zero_info(
    omega: Sequence[Instance],
    statistic: Callable[[Instance], object],
    secret: Callable[[Instance], object],
) -> bool:
    """
    Exact counting independence:
        #{T = t, S = s} * #Omega == #{T = t} * #{S = s}   for all t, s.
    Equivalently, the empirical joint law of (T, S) is a product law:
    mutual information exactly zero.
    """
    n = len(omega)
    t_values = [statistic(w) for w in omega]
    s_values = [secret(w) for w in omega]
    for t in set(t_values):
        for s in set(s_values):
            joint = sum(1 for a, c in zip(t_values, s_values) if a == t and c == s)
            marg_t = t_values.count(t)
            marg_s = s_values.count(s)
            if joint * n != marg_t * marg_s:
                return False
    return True


def empirical_mutual_information(
    omega: Sequence[Instance],
    statistic: Callable[[Instance], object],
    secret: Callable[[Instance], object],
) -> float:
    """Mutual information in bits of (T, S) under the uniform law on Omega."""
    n = len(omega)
    joint: Dict[Tuple[object, object], int] = {}
    t_marg: Dict[object, int] = {}
    s_marg: Dict[object, int] = {}
    for w in omega:
        t, s = statistic(w), secret(w)
        joint[(t, s)] = joint.get((t, s), 0) + 1
        t_marg[t] = t_marg.get(t, 0) + 1
        s_marg[s] = s_marg.get(s, 0) + 1
    total = 0.0
    for (t, s), c in joint.items():
        pj = c / n
        total += pj * math.log2(pj / ((t_marg[t] / n) * (s_marg[s] / n)))
    return total


# ----------------------------------------------------------------------------
# Burnside side
# ----------------------------------------------------------------------------

def fixed_point_count(b: int, N: int, k: int) -> int:
    """Brute-force count of x in Z/N with b^k * x = x (mod N)."""
    a = pow(b, k, N)
    return sum(1 for x in range(N) if (a * x - x) % N == 0)


def orbit_count_bruteforce(b: int, N: int) -> int:
    """Number of orbits of <b> acting on Z/N by multiplication."""
    seen = [False] * N
    orbits = 0
    for x in range(N):
        if seen[x]:
            continue
        orbits += 1
        y = x
        while not seen[y]:
            seen[y] = True
            y = (y * b) % N
    return orbits


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_structure_and_seal() -> None:
    print("=" * 72)
    print("1-2.  Structure theorem and the order seal")
    print("=" * 72)
    for (p, q, b) in [(11, 13, 2), (31, 37, 5), (101, 103, 7), (1009, 1013, 3)]:
        N = p * q
        dp, dq = multiplicative_order(b, p), multiplicative_order(b, q)
        dstar, n = min(dp, dq), math.lcm(dp, dq)
        ok = all(
            fingerprint(b, N, c) == (p if c % dp == 0 else 1) * (q if c % dq == 0 else 1)
            for c in range(0, 4 * n + 1)
        )
        sealed = all(fingerprint(b, N, c) == 1 for c in range(1, dstar))
        entry = fingerprint(b, N, dstar)
        print(f"  N = {p}*{q} = {N},  b = {b}:  d_p = {dp}, d_q = {dq}, "
              f"d* = {dstar}, n = {n}")
        print(f"     structure theorem holds on [0, 4n]      : {ok}")
        print(f"     F(c) = 1 for all 0 < c < d*             : {sealed}")
        print(f"     F(d*) = {entry}  -> proper factor of N  : "
              f"{1 < entry < N and N % entry == 0}")
    print()


def demo_spectra() -> None:
    print("=" * 72)
    print("3-4.  Valuation spectrum and the four-atom raw spectrum")
    print("=" * 72)
    p, q, b = 11, 13, 2
    N = p * q
    dp, dq = multiplicative_order(b, p), multiplicative_order(b, q)
    n, phi = math.lcm(dp, dq), (p - 1) * (q - 1)
    print(f"  N = {N} = {p}*{q}, b = {b}: d_p = {dp}, d_q = {dq}, n = {n}, "
          f"phi(N) = {phi}")
    print("\n   d | F(d) | M^(p)_d | predicted | M_d   | predicted")
    print("  ---+------+---------+-----------+-------+----------")
    for d in range(1, n + 3):
        mval = valuation_mobius_coefficient(b, N, p, d)
        mraw = raw_mobius_coefficient(b, N, d)
        pred_val = 1 if dp == d else 0
        pred_raw = ((1 if d == 1 else 0) + (p - 1) * (1 if dp == d else 0)
                    + (q - 1) * (1 if dq == d else 0) + phi * (1 if n == d else 0))
        flag = "  <-- atom" if mraw != 0 else ""
        print(f"  {d:2d} | {fingerprint(b, N, d):4d} | {mval:7d} | {pred_val:9d} "
              f"| {mraw:5d} | {pred_raw:8d}{flag}")
    assert all(valuation_mobius_coefficient(b, N, p, d) == (1 if dp == d else 0)
               for d in range(1, 4 * n))
    assert all(raw_mobius_coefficient(b, N, d) ==
               ((1 if d == 1 else 0) + (p - 1) * (1 if dp == d else 0)
                + (q - 1) * (1 if dq == d else 0) + phi * (1 if n == d else 0))
               for d in range(1, 4 * n))
    print("\n  Both spectral identities verified for all 1 <= d < 4n.")
    for D in [1, min(dp, dq) - 1, dp, n]:
        s = sum(valuation_mobius_coefficient(b, N, p, d) for d in range(1, D + 1))
        print(f"    window sum over 1..{D:3d} = {s}   (predicted [d_p <= D] = "
              f"{1 if dp <= D else 0})")
    print()


def demo_starvation() -> None:
    print("=" * 72)
    print("5.  Starvation: exact zero information below the order scale")
    print("=" * 72)
    D, ell, b = 4, 3, 2
    small_primes = [p for p in primes_up_to(400) if p != 2]
    omega: List[Instance] = []
    for p, q in product(small_primes, repeat=2):
        if p >= q:
            continue
        if min(multiplicative_order(b, p), multiplicative_order(b, q)) > D:
            omega.append((p, q, b))
    print(f"  Family Omega: all (p, q, 2) with 2 < p < q < 400 and "
          f"min(d_p, d_q) > D = {D}")
    print(f"  |Omega| = {len(omega)} instances")

    def stat(inst: Instance) -> Tuple[int, ...]:
        p, q, bb = inst
        return window(bb, p * q, D)

    def secret(inst: Instance) -> int:
        p, q, _ = inst
        return (p + q) % ell

    print(f"  distinct fingerprint windows observed : "
          f"{len(set(stat(w) for w in omega))}  (constant => 1)")
    print(f"  distinct secret values (p+q) mod {ell}    : "
          f"{len(set(secret(w) for w in omega))}")
    print(f"  exact counting independence           : {zero_info(omega, stat, secret)}")
    print(f"  empirical mutual information (bits)   : "
          f"{empirical_mutual_information(omega, stat, secret):.6f}")

    # Post-processing cannot help (data-processing lemma).
    def post(inst: Instance) -> int:
        return hash(stat(inst)) % 7

    print(f"  after arbitrary post-processing       : {zero_info(omega, post, secret)}")

    # Sharpness: at the order scale, independence fails immediately.
    sharp: List[Instance] = [(3, 5, 2), (3, 7, 2)]
    print("\n  Sharpness witness: Omega' = {(3,5,2), (3,7,2)}, D = 4, l = 3")
    for inst in sharp:
        p, q, bb = inst
        print(f"     (p,q,b) = {inst}: window = {window(bb, p * q, 4)}, "
              f"(p+q) mod 3 = {(p + q) % 3}")
    print(f"     exact counting independence        : "
          f"{zero_info(sharp, stat, secret)}   (fails, as predicted)")
    print(f"     empirical mutual information (bits): "
          f"{empirical_mutual_information(sharp, stat, secret):.6f}")
    print()


def demo_burnside() -> None:
    print("=" * 72)
    print("6.  Burnside: fixed points, the orbit count, and the balanced seal")
    print("=" * 72)
    for (p, q, b) in [(11, 13, 2), (7, 11, 3), (5, 13, 2), (7, 13, 2)]:
        N = p * q
        dp, dq = multiplicative_order(b, p), multiplicative_order(b, q)
        n, phi = math.lcm(dp, dq), (p - 1) * (q - 1)
        fixed_ok = all(fixed_point_count(b, N, k) == fingerprint(b, N, k)
                       for k in range(0, n))
        C = orbit_count_bruteforce(b, N)
        rhs = n + (p - 1) * (n // dp) + (q - 1) * (n // dq) + phi
        print(f"  N = {p}*{q} = {N}, b = {b}: d_p = {dp}, d_q = {dq}, n = {n}")
        print(f"     #Fix(b^k) = F(k) for all k < n : {fixed_ok}")
        print(f"     orbit count C = {C};  C*n = {C * n}, identity RHS = {rhs}  "
              f"-> {C * n == rhs}")
        if dp == dq:
            print(f"     balanced case: C*d = {C * dp} and d + N - 1 = "
                  f"{dp + N - 1}  -> {C * dp == dp + N - 1}  (no leak)")
        else:
            A, B = n // dp - 1, n // dq - 1
            lhs = A * p + B * q
            rhs2 = C * n - n + n // dp + n // dq - N - 1
            print(f"     affine hint: ({A})*p + ({B})*q = {lhs} = {rhs2}  "
                  f"-> {lhs == rhs2}  (nonzero coefficients => factoring oracle)")
    print()


def demo_exponent_invariance() -> None:
    print("=" * 72)
    print("7.  A constant factor is not an asymptotic gain")
    print("=" * 72)

    def log_baseline(n: int) -> float:
        """A rho-like baseline: T'(n) = exp(sqrt(n)), returned as log T'(n)."""
        return math.sqrt(n)

    C = 1.95
    theta = 0.9
    print("     n |  log(C*T')/log(T')  |  log(T'^theta)/log(T')   [C = 1.95, "
          "theta = 0.9]")
    print("  -----+---------------------+------------------------")
    for n in [10, 100, 1_000, 10_000, 1_000_000, 10 ** 10]:
        log_t = log_baseline(n)
        const_ratio = (math.log(C) + log_t) / log_t
        power_ratio = theta * log_t / log_t
        print(f"  {n:>10} |     {const_ratio:.9f}     |      {power_ratio:.9f}")
    print("\n  Constant-factor ratio -> 1 (no exponent gain); "
          "power ratio == theta (real gain).")
    print()


def main() -> None:
    print()
    print("#" * 72)
    print("#  The cycle-index fingerprint F(c) = gcd(b^c - 1, N) of a semiprime")
    print("#" * 72)
    print()
    demo_structure_and_seal()
    demo_spectra()
    demo_starvation()
    demo_burnside()
    demo_exponent_invariance()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
