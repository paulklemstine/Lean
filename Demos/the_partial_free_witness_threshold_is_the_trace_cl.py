"""
The Partial Free-Witness Threshold for Semiprimes
=================================================

Numerical demonstration of the results on the divisor power sum

    sigma_k(N) = sum_{d | N} d^k ,   sigma_k(p*q) = (1 + p^k)(1 + q^k),

for a semiprime N = p*q with p != q prime.

Results demonstrated
--------------------
1.  Trace identity and exact recovery at order 2:
        t = sqrt(sigma_2(N) + 2N - N^2 - 1) = p + q,
        p, q = (t -/+ sqrt(t^2 - 4N)) / 2.
2.  Separation principle: for a*b = c*d, the witnesses agree mod m iff
        m | (a^k + b^k) - (c^k + d^k).
3.  Sharp threshold theorem: sigma_k(N) mod m determines the factorisation
    of N = p*q iff m does not divide the witness gap G_k = (p^k-1)(q^k-1).
4.  Refutation of the conjectured law m* = 5(p+q): the fixed modulus 7 works
    for arbitrarily large primes p == q == 2 (mod 7).
5.  Universal lower bound m* >= 5 (since 24 | p^2 - 1 for p > 3) and the
    exact-five theorem: m* = 5 iff p, q are not +-1 mod 5.
6.  Order 1: the witness gap is Euler's totient, G_1 = phi(N).
7.  Counting bound: omega(G_k) <= log2(G_k), so only O(log N) prime moduli
    can ever fail.

Self-contained: standard library only.  Run with `python3 demo.py`.
"""

from __future__ import annotations

import math
from typing import Dict, Iterator, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Basic arithmetic utilities
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin primality test for 64-bit-ish integers."""
    if n < 2:
        return False
    small_primes: List[int] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes:
        if n % p == 0:
            return n == p
    d: int = n - 1
    r: int = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small_primes:
        x: int = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than `n`."""
    m: int = n + 1
    while not is_prime(m):
        m += 1
    return m


def next_prime_in_class(lower: int, residue: int, modulus: int) -> int:
    """Smallest prime > `lower` congruent to `residue` modulo `modulus`.

    Existence is guaranteed by Dirichlet's theorem when
    gcd(residue, modulus) = 1.
    """
    m: int = lower + 1
    while m % modulus != residue % modulus:
        m += 1
    while not is_prime(m):
        m += modulus
    return m


def divisors(n: int) -> List[int]:
    """All positive divisors of `n`, ascending.  Trial division, O(sqrt n)."""
    out: List[int] = []
    i: int = 1
    while i * i <= n:
        if n % i == 0:
            out.append(i)
            if i != n // i:
                out.append(n // i)
        i += 1
    return sorted(out)


def sigma_k(n: int, k: int) -> int:
    """Divisor power sum sigma_k(n) = sum over d | n of d^k (by enumeration)."""
    return sum(d ** k for d in divisors(n))


def prime_factors(n: int) -> Dict[int, int]:
    """Prime factorisation of `n` as an exponent dictionary."""
    out: Dict[int, int] = {}
    d: int = 2
    m: int = n
    while d * d <= m:
        while m % d == 0:
            out[d] = out.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        out[m] = out.get(m, 0) + 1
    return out


# ---------------------------------------------------------------------------
# The free witness and its gap
# ---------------------------------------------------------------------------


def witness(k: int, a: int, b: int) -> int:
    """W_k(a,b) = (1 + a^k)(1 + b^k): the order-k witness of N = a*b."""
    return (1 + a ** k) * (1 + b ** k)


def gap(k: int, p: int, q: int) -> int:
    """The witness gap G_k(p,q) = (p^k - 1)(q^k - 1)."""
    return (p ** k - 1) * (q ** k - 1)


def determines(k: int, m: int, p: int, q: int) -> bool:
    """True iff sigma_k(pq) mod m pins down the factorisation.

    Sharp threshold theorem: this holds iff m does not divide G_k(p,q).
    """
    return gap(k, p, q) % m != 0


def determines_by_enumeration(k: int, m: int, p: int, q: int) -> bool:
    """Brute-force check of determination by scanning all factor pairs."""
    n: int = p * q
    target: int = witness(k, p, q) % m
    for a in divisors(n):
        b: int = n // a
        if {a, b} == {p, q}:
            continue
        if witness(k, a, b) % m == target:
            return False
    return True


def least_determining_modulus(k: int, p: int, q: int) -> int:
    """m*_k(p,q): the least non-divisor of the witness gap."""
    g: int = gap(k, p, q)
    m: int = 1
    while g % m == 0:
        m += 1
    return m


# ---------------------------------------------------------------------------
# Exact recovery at order 2
# ---------------------------------------------------------------------------


def extracted_trace(n: int, w: int) -> int:
    """T(N,w) = isqrt(w + 2N - N^2 - 1); equals p+q when w = sigma_2(N)."""
    radicand: int = w + 2 * n - n * n - 1
    if radicand < 0:
        raise ValueError("negative radicand: w is not a valid order-2 witness")
    return math.isqrt(radicand)


def recover_factors(n: int, w: int) -> Optional[Tuple[int, int]]:
    """Recover (p, q) from N and the full witness w = sigma_2(N)."""
    radicand: int = w + 2 * n - n * n - 1
    if radicand < 0:
        return None
    t: int = math.isqrt(radicand)
    if t * t != radicand:
        return None
    s: int = t * t - 4 * n
    if s < 0:
        return None
    d: int = math.isqrt(s)
    if d * d != s or (t - d) % 2 != 0:
        return None
    return ((t - d) // 2, (t + d) // 2)


def euler_totient_semiprime(p: int, q: int) -> int:
    """phi(pq) = (p-1)(q-1) for distinct primes p, q."""
    return (p - 1) * (q - 1)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

BAR: str = "=" * 74


def semiprimes(count: int, start: int = 5) -> Iterator[Tuple[int, int]]:
    """Yield `count` semiprime factor pairs (p, q) with p < q, p, q > start."""
    produced: int = 0
    p: int = next_prime(start)
    while produced < count:
        q: int = next_prime(p)
        yield (p, q)
        produced += 1
        p = q


def demo_recovery() -> None:
    print(BAR)
    print("1. EXACT RECOVERY FROM THE FULL ORDER-2 WITNESS")
    print(BAR)
    print("   t = sqrt(sigma_2(N) + 2N - N^2 - 1) = p + q, then")
    print("   p, q = (t -/+ sqrt(t^2 - 4N)) / 2.\n")
    print(f"{'N':>12} {'sigma_2(N)':>22} {'t=p+q':>8} {'recovered':>16}  ok")
    for p, q in semiprimes(8, start=5):
        n: int = p * q
        w: int = sigma_k(n, 2)
        t: int = extracted_trace(n, w)
        rec: Optional[Tuple[int, int]] = recover_factors(n, w)
        ok: bool = rec == (p, q) and t == p + q
        print(f"{n:>12} {w:>22} {t:>8} {str(rec):>16}  {ok}")
    # A larger instance, to stress the algebra rather than the search.
    p, q = 1_000_003, 1_000_033
    n = p * q
    w = witness(2, p, q)  # = sigma_2(N), by the multiplicativity formula
    print("\n   Large instance (recovery is O(log^2 N) once the witness is known):")
    print(f"     N          = {n}")
    print(f"     sigma_2(N) = {w}")
    print(f"     recovered  = {recover_factors(n, w)}   (true: ({p}, {q}))")


def demo_separation() -> None:
    print("\n" + BAR)
    print("2. SEPARATION PRINCIPLE AND THE WITNESS GAP")
    print(BAR)
    print("   For a*b = c*d:  W_k(a,b) = W_k(c,d) mod m  <=>  m | (a^k+b^k)-(c^k+d^k)")
    print("   For a semiprime the only competitor is 1 * N, with gap")
    print("   G_k = W_k(1,N) - W_k(p,q) = (p^k - 1)(q^k - 1).\n")
    for p, q in [(11, 17), (13, 19), (101, 103)]:
        n: int = p * q
        for k in (1, 2, 3):
            lhs: int = witness(k, 1, n) - witness(k, p, q)
            rhs: int = gap(k, p, q)
            powsum: int = (1 ** k + n ** k) - (p ** k + q ** k)
            print(
                f"   p={p:<4} q={q:<4} k={k}:  "
                f"W_k(1,N)-W_k(p,q) = {lhs:<22} = G_k = {rhs:<22} "
                f"= powsum diff {powsum}"
            )
        print()


def demo_threshold() -> None:
    print(BAR)
    print("3. SHARP THRESHOLD THEOREM  (mod m determines  <=>  m does not divide G_k)")
    print(BAR)
    print("   Brute-force enumeration of all factor pairs agrees with the criterion.\n")
    agree: int = 0
    total: int = 0
    for p, q in [(11, 17), (13, 19), (23, 29), (31, 37), (41, 43)]:
        row: List[str] = []
        for m in range(2, 14):
            crit: bool = determines(2, m, p, q)
            brute: bool = determines_by_enumeration(2, m, p, q)
            total += 1
            agree += int(crit == brute)
            row.append(f"{m}:{'Y' if crit else '.'}")
        print(f"   p={p:<4} q={q:<4} G_2={gap(2,p,q):<12} " + " ".join(row))
    print(f"\n   criterion vs. brute force: {agree}/{total} agreements")


def demo_refutation() -> None:
    print("\n" + BAR)
    print("4. REFUTATION OF THE CONJECTURED LAW  m* = 5(p+q)")
    print(BAR)
    print("   The fixed modulus 7 works whenever p = q = 2 (mod 7), since then")
    print("   G_2 = (4-1)(4-1) = 9 = 2 (mod 7) is nonzero.  Dirichlet supplies")
    print("   such primes above every bound.\n")
    print(f"{'p':>12} {'q':>12} {'p+q':>14} {'5(p+q) claim':>15} {'m*':>5} {'7 works':>9}")
    bound: int = 10
    for _ in range(7):
        p: int = next_prime_in_class(bound, 2, 7)
        q: int = next_prime_in_class(p, 2, 7)
        mstar: int = least_determining_modulus(2, p, q)
        print(
            f"{p:>12} {q:>12} {p+q:>14} {5*(p+q):>15} {mstar:>5} "
            f"{str(determines(2, 7, p, q)):>9}"
        )
        bound = p * 6
    print("\n   The claimed threshold grows without bound; the true one stays <= 7.")


def demo_five() -> None:
    print("\n" + BAR)
    print("5. UNIVERSAL LOWER BOUND m* >= 5, AND THE EXACT-FIVE LOCUS")
    print(BAR)
    print("   24 | p^2 - 1 for every prime p > 3, hence 24 | G_2 and every m <= 4 fails.")
    print("   m* = 5 exactly when neither p nor q is +-1 mod 5.\n")
    checked: int = 0
    for p, q in semiprimes(200, start=5):
        assert (p * p - 1) % 24 == 0, (p,)
        for m in range(1, 5):
            assert not determines(2, m, p, q)
        pred: bool = (p % 5 not in (1, 4)) and (q % 5 not in (1, 4))
        assert determines(2, 5, p, q) == pred
        checked += 1
    print(f"   verified on {checked} consecutive-prime semiprimes: "
          "no m <= 4 ever determines,")
    print("   and m = 5 determines exactly on the predicted congruence locus.\n")
    print("   Histogram of the least determining modulus m* (order 2), "
          "1000 semiprimes:")
    hist: Dict[int, int] = {}
    for p, q in semiprimes(1000, start=5):
        mstar: int = least_determining_modulus(2, p, q)
        hist[mstar] = hist.get(mstar, 0) + 1
    for m in sorted(hist):
        pct: float = 100.0 * hist[m] / 1000.0
        print(f"     m* = {m:<3} {hist[m]:>5}  ({pct:5.1f}%)  " + "#" * int(pct / 2))
    print("   Note: the distribution is supported on a few small constants -- ")
    print("   there is no growth with p + q.")


def demo_totient() -> None:
    print("\n" + BAR)
    print("6. ORDER 1: THE GAP IS EULER'S TOTIENT (THE RSA TRAPDOOR)")
    print(BAR)
    print("   G_1(p,q) = (p-1)(q-1) = phi(N), so sigma_1(N) mod m determines the")
    print("   factorisation iff m does not divide phi(N).\n")
    for p, q in [(11, 17), (61, 53), (101, 103), (1009, 1013)]:
        n: int = p * q
        g1: int = gap(1, p, q)
        phi: int = euler_totient_semiprime(p, q)
        mstar: int = least_determining_modulus(1, p, q)
        print(
            f"   N = {n:<10} phi(N) = {phi:<10} G_1 = {g1:<10} "
            f"equal: {g1 == phi}   m*_1 = {mstar}"
        )
    print("\n   sigma_1(N) = N + 1 + t and phi(N) = N + 1 - t with t = p + q:")
    print("   both are faces of the same trace coordinate.")


def demo_counting() -> None:
    print("\n" + BAR)
    print("7. COUNTING BOUND: omega(G_k) <= log2(G_k)")
    print(BAR)
    print("   At most log2(G_2) < 2 log2(N) prime moduli can fail, so any family")
    print("   of more than that many distinct primes contains a working modulus.\n")
    print(f"{'N':>14} {'G_2':>22} {'omega(G_2)':>11} {'log2 G_2':>10} "
          f"{'2 log2 N':>9} {'m*':>4}")
    for p, q in [(11, 17), (101, 103), (1009, 1013), (10007, 10009),
                 (100003, 100019)]:
        n: int = p * q
        g: int = gap(2, p, q)
        omega: int = len(prime_factors(g))
        print(
            f"{n:>14} {g:>22} {omega:>11} {math.floor(math.log2(g)):>10} "
            f"{2*math.floor(math.log2(n)):>9} "
            f"{least_determining_modulus(2, p, q):>4}"
        )
    print("\n   The number of failing prime moduli grows only logarithmically,")
    print("   while sigma_2(N) itself has ~2 log2(N) bits.")


def demo_information_vs_computation() -> None:
    print("\n" + BAR)
    print("8. INFORMATION IS NOT COMPUTATION")
    print(BAR)
    p, q = 1000003, 1000033
    n: int = p * q
    m: int = least_determining_modulus(2, p, q)
    w_mod: int = witness(2, p, q) % m
    bits: float = math.log2(m)
    print(f"   N = {n} ({n.bit_length()} bits)")
    print(f"   sigma_2(N) has {witness(2,p,q).bit_length()} bits;")
    print(f"   but the residue sigma_2(N) mod {m} = {w_mod}"
          f" ({bits:.2f} bits) already")
    print("   determines the factorisation uniquely among all factor pairs of N.")
    consistent: List[Tuple[int, int]] = [
        (a, n // a) for a in divisors(n)
        if witness(2, a, n // a) % m == w_mod
    ]
    print(f"   factor pairs consistent with that residue: {consistent}")
    print("\n   Yet obtaining that residue requires evaluating a sum over the")
    print("   divisors of N -- the aggregation barrier.  Reduction mod m shrinks")
    print("   the summands, never the index set.  Hence: no factoring shortcut,")
    print("   but a sharper target for any hardness proof, which must now rule")
    print("   out cheap computation of arbitrarily partial values.")


def main() -> None:
    print("\nTHE PARTIAL FREE-WITNESS THRESHOLD FOR SEMIPRIMES")
    print("Numerical demonstration\n")
    demo_recovery()
    demo_separation()
    demo_threshold()
    demo_refutation()
    demo_five()
    demo_totient()
    demo_counting()
    demo_information_vs_computation()
    print("\n" + BAR)
    print("All demonstrations completed.")
    print(BAR + "\n")


if __name__ == "__main__":
    main()
