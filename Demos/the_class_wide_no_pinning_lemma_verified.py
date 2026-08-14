"""
The Class-Wide No-Pinning Lemma — numerical demonstrations
==========================================================

This self-contained script demonstrates, by explicit computation, the results of
the paper "No Polynomial-Time Congruence Battery Can Pin a Prime Factor".

Setting.  Fix a modulus L (an even number).  An *observable of modulus L* is any
function f of a natural number N whose value depends only on N mod L (for odd
N).  The concrete "battery" of level B consists of

    residues     N -> N mod m          for 1 <= m <= B
    Jacobi       N -> (a | N)          for 1 <= a <= B
    gcds         N -> gcd(N, c)        for 1 <= c <= B

and every one of these is an observable of modulus L_B = 4 * lcm(1, ..., B).

The theorems demonstrated here:

  1. Compensating-partner lemma.  For a target N0 and a candidate prime p, both
     coprime to L, there are infinitely many primes q with p*q = N0 (mod L).
     Hence the entire battery reads identically on p*q and on N0.

  2. Exact pinned set.  A prime candidate p is eliminated by modulus-L data if
     and only if p divides L; at level B those are exactly the primes <= B
     (together with 2), at most log_2(L) of them.

  3. Sealing bound.  A modulus-L battery that eliminates k prime candidates must
     satisfy 2^k <= L.  Eliminating all primes below X (except the two true
     factors of a semiprime) forces L >= 2^(pi(X) - 2).

  4. Barrier 1 (polynomial gcds).  For every integer polynomial f,
     gcd(f(N), N) = gcd(f(0), N).  In particular gcd(N + k, N) = gcd(k, N).

  5. Perfect uniformity.  In any finite group G, every element u has exactly
     |G| ordered factorisations u = x*y.  For G = (Z/L)^* this is phi(L):
     observing a product reveals nothing about an individual factor class.

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory helpers
# ----------------------------------------------------------------------------


def lcm_up_to(bound: int) -> int:
    """lcm(1, 2, ..., bound)."""
    value = 1
    for m in range(1, bound + 1):
        value = value * m // gcd(value, m)
    return value


def mod_level(bound: int) -> int:
    """The modulus of the level-B battery: 4 * lcm(1, ..., B).

    The factor 4 accommodates the conductor of the Jacobi symbols.
    """
    return 4 * lcm_up_to(bound)


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    small_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small_primes:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small_primes:
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_below(limit: int) -> List[int]:
    """All primes strictly below `limit`, by sieve of Eratosthenes."""
    if limit <= 2:
        return []
    sieve = bytearray([1]) * limit
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i * i : limit : i] = bytearray(len(range(i * i, limit, i)))
    return [i for i in range(limit) if sieve[i]]


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires odd positive n")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


# ----------------------------------------------------------------------------
# The level-B battery
# ----------------------------------------------------------------------------


def battery_readout(n: int, bound: int) -> Tuple[int, ...]:
    """The full level-B readout of N: residues, Jacobi symbols, gcds.

    Entry layout: (N mod 1, ..., N mod B, (1|N), ..., (B|N),
                   gcd(N,1), ..., gcd(N,B)).
    Every entry is computable in time polynomial in log N.
    """
    residues = tuple(n % m for m in range(1, bound + 1))
    jacobis = tuple(jacobi(a, n) for a in range(1, bound + 1))
    gcds = tuple(gcd(n, c) for c in range(1, bound + 1))
    return residues + jacobis + gcds


def compensating_partner(target: int, candidate: int, modulus: int) -> int:
    """The smallest prime q with candidate * q = target (mod modulus).

    Existence for infinitely many q is Dirichlet's theorem applied to the unit
    class target * candidate^{-1} mod modulus.
    """
    if gcd(candidate, modulus) != 1:
        raise ValueError("candidate must be coprime to the modulus (else it is pinned)")
    inverse = pow(candidate, -1, modulus)
    residue = (target * inverse) % modulus
    q = residue if residue > 1 else residue + modulus
    while not is_prime(q):
        q += modulus
    return q


# ----------------------------------------------------------------------------
# Demonstration 1 — the compensating-partner lemma at level B = 12
# ----------------------------------------------------------------------------


def demo_compensating_partners() -> None:
    bound = 12
    modulus = mod_level(bound)
    target = 221  # = 13 * 17
    print("=" * 74)
    print("1.  COMPENSATING PARTNERS  (level B = 12)")
    print("=" * 74)
    print(f"modulus L = 4 * lcm(1..{bound}) = {modulus}")
    print(f"target    N0 = {target} = 13 * 17,  gcd(N0, L) = {gcd(target, modulus)}")
    print()
    reference = battery_readout(target, bound)
    print(f"{'candidate p':>12} {'partner q':>12} {'N = p*q':>14} "
          f"{'N mod L':>9}  battery agrees")
    print("-" * 74)
    survivors, pinned = 0, []
    for p in primes_below(80):
        if modulus % p == 0:
            pinned.append(p)
            continue
        q = compensating_partner(target, p, modulus)
        n = p * q
        agree = battery_readout(n, bound) == reference
        survivors += 1
        print(f"{p:>12} {q:>12} {n:>14} {n % modulus:>9}  {agree}")
        assert agree, "battery must not distinguish N from N0"
    print("-" * 74)
    print(f"candidates surviving the whole battery: {survivors}/{survivors}")
    print(f"pinned primes below 80 (exactly the primes dividing L): {pinned}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 2 — the pinned set is the primes dividing L
# ----------------------------------------------------------------------------


def demo_pinned_set() -> None:
    print("=" * 74)
    print("2.  THE PINNED SET  =  primes dividing L  =  primes <= B (and 2)")
    print("=" * 74)
    print(f"{'B':>4} {'L = 4 lcm(1..B)':>18} {'pinned primes':>28} "
          f"{'#pinned':>8} {'log2 L':>7}")
    print("-" * 74)
    for bound in (2, 3, 5, 8, 12, 20, 30):
        modulus = mod_level(bound)
        pinned = [p for p in primes_below(bound + 1) if modulus % p == 0]
        if 2 not in pinned:
            pinned = [2] + pinned
        log2 = modulus.bit_length() - 1
        print(f"{bound:>4} {modulus:>18} {str(pinned):>28} "
              f"{len(pinned):>8} {log2:>7}")
    print("-" * 74)
    # Density of pinned candidates among all prime candidates below 500.
    bound, limit = 12, 500
    modulus = mod_level(bound)
    candidates = primes_below(limit)
    pinned = [p for p in candidates if modulus % p == 0]
    print(f"at B = {bound}: {len(pinned)} pinned out of {len(candidates)} primes "
          f"below {limit}  ->  {100 * len(pinned) / len(candidates):.1f}%")
    print("as the search range grows the pinned fraction tends to 0.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3 — the sealing bound
# ----------------------------------------------------------------------------


def demo_sealing_bound() -> None:
    print("=" * 74)
    print("3.  SEALING BOUND:  excluding k candidates forces  2^k <= L")
    print("=" * 74)
    print("A battery that eliminates every prime candidate below X, other than")
    print("the two true factors, must have modulus L >= 2^(pi(X) - 2).")
    print()
    print(f"{'X':>12} {'pi(X)':>10} {'required bits of L':>22}")
    print("-" * 74)
    for exponent in range(3, 13):
        x = 10**exponent
        # pi(X) by the logarithmic-integral-free crude estimate x / (ln x - 1).
        from math import log

        pi_x = x / (log(x) - 1)
        print(f"{'10^' + str(exponent):>12} {pi_x:>10.3e} {pi_x - 2:>22.3e}")
    print("-" * 74)
    print("A factoring search on an n-bit semiprime needs X ~ 2^(n/2), so the")
    print("modulus would need ~ 2^(n/2)/n bits: exponentially far from poly(n).")
    print()


# ----------------------------------------------------------------------------
# Demonstration 4 — barrier 1: polynomial gcds
# ----------------------------------------------------------------------------


def poly_eval(coeffs: Sequence[int], x: int) -> int:
    """Evaluate sum_i coeffs[i] * x^i by Horner's rule."""
    value = 0
    for c in reversed(coeffs):
        value = value * x + c
    return value


def demo_polynomial_gcd() -> None:
    print("=" * 74)
    print("4.  BARRIER 1:  gcd(f(N), N) = gcd(f(0), N)  for every polynomial f")
    print("=" * 74)
    coeffs = [12, 5, 0, 7]  # f(x) = 7x^3 + 5x + 12, constant term 12
    print("f(x) = 7x^3 + 5x + 12,   f(0) = 12")
    print()
    print(f"{'N':>8} {'gcd(f(N), N)':>16} {'gcd(12, N)':>14} {'equal':>7}")
    print("-" * 74)
    for n in (1000, 1074, 1296, 221, 110880, 999983):
        left, right = gcd(poly_eval(coeffs, n), n), gcd(12, n)
        print(f"{n:>8} {left:>16} {right:>14} {str(left == right):>7}")
        assert left == right
    print("-" * 74)
    print("Special case k-shift:  gcd(N + k, N) = gcd(k, N)")
    for n, k in ((221, 4), (110880, 7), (1000003, 30)):
        assert gcd(n + k, n) == gcd(k, n)
        print(f"  gcd({n} + {k}, {n}) = {gcd(n + k, n)} = gcd({k}, {n})")
    print("A gcd probe against a polynomial value is a function of N alone.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 5 — perfect uniformity of the product map
# ----------------------------------------------------------------------------


def unit_group(modulus: int) -> List[int]:
    """The units of Z/modulus."""
    return [x for x in range(modulus) if gcd(x, modulus) == 1]


def factorisation_counts(modulus: int) -> Dict[int, int]:
    """For each unit u, the number of ordered pairs (x, y) of units with xy = u."""
    units = unit_group(modulus)
    counts = {u: 0 for u in units}
    for x in units:
        for y in units:
            counts[(x * y) % modulus] += 1
    return counts


def demo_uniformity() -> None:
    print("=" * 74)
    print("5.  PERFECT UNIFORMITY:  every product value has exactly phi(L)")
    print("    ordered factorisations — observing N mod L leaks nothing")
    print("=" * 74)
    print(f"{'L':>6} {'phi(L)':>8} {'distinct counts':>20} {'all equal phi(L)':>18}")
    print("-" * 74)
    for modulus in (8, 12, 24, 40, 60, 120):
        counts = factorisation_counts(modulus)
        distinct = sorted(set(counts.values()))
        phi = euler_phi(modulus)
        print(f"{modulus:>6} {phi:>8} {str(distinct):>20} "
              f"{str(distinct == [phi]):>18}")
        assert distinct == [phi]
    print("-" * 74)
    print("Consequence: the conditional distribution of the factor class given")
    print("the observed product class is uniform on the whole unit group.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 6 — indistinguishable semiprimes with no common factor
# ----------------------------------------------------------------------------


def demo_two_coprime_semiprimes() -> None:
    print("=" * 74)
    print("6.  NO FACTORING FROM CONGRUENCE DATA")
    print("=" * 74)
    print("Two coprime semiprimes in the same class mod L are indistinguishable")
    print("to every modulus-L observable, so no decoding of the readout can name")
    print("a nontrivial divisor of both.")
    print()
    bound = 12
    modulus = mod_level(bound)
    p1, q1 = 13, 17
    n1 = p1 * q1
    p2 = 19
    q2 = compensating_partner(n1, p2, modulus)
    n2 = p2 * q2
    print(f"L  = {modulus}")
    print(f"N1 = {p1} * {q1} = {n1}")
    print(f"N2 = {p2} * {q2} = {n2}")
    print(f"N1 mod L = {n1 % modulus},  N2 mod L = {n2 % modulus}")
    print(f"gcd(N1, N2) = {gcd(n1, n2)}   (coprime: no common nontrivial divisor)")
    print(f"identical battery readouts: {battery_readout(n1, bound) == battery_readout(n2, bound)}")
    assert gcd(n1, n2) == 1
    assert battery_readout(n1, bound) == battery_readout(n2, bound)
    print()
    print("Any rule that maps the readout to a nontrivial divisor would output")
    print("the same number for N1 and N2, hence a common divisor > 1 of two")
    print("coprime integers — impossible.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 7 — the ambiguity survives at cryptographic size
# ----------------------------------------------------------------------------


def demo_large_scale() -> None:
    print("=" * 74)
    print("7.  THE AMBIGUITY PERSISTS AT CRYPTOGRAPHIC SIZE")
    print("=" * 74)
    bound = 30
    modulus = mod_level(bound)
    # A 128-bit-ish semiprime target built from two large primes.
    p0 = 1000000000000000003
    while not is_prime(p0):
        p0 += 2
    q0 = 2000000000000000011
    while not is_prime(q0):
        q0 += 2
    target = p0 * q0
    print(f"B = {bound},  L = 4*lcm(1..{bound}) has {modulus.bit_length()} bits")
    print(f"target N0 = {p0} * {q0}")
    print(f"          = {target}   ({target.bit_length()} bits)")
    print()
    print("Alternative factor candidates, each with a compensating partner:")
    print(f"{'candidate p':>22} {'bits of q':>10} {'bits of p*q':>12} {'agrees':>8}")
    print("-" * 74)
    reference = battery_readout(target, bound)
    candidate = 10**18 + 9
    found = 0
    while found < 5:
        if is_prime(candidate) and gcd(candidate, modulus) == 1:
            q = compensating_partner(target, candidate, modulus)
            n = candidate * q
            agrees = battery_readout(n, bound) == reference
            print(f"{candidate:>22} {q.bit_length():>10} {n.bit_length():>12} "
                  f"{str(agrees):>8}")
            assert agrees
            found += 1
        candidate += 2
    print("-" * 74)
    print("Every large prime is a live candidate: the readout of a poly(log N)")
    print("congruence battery is compatible with all of them.")
    print()


def main() -> None:
    demo_compensating_partners()
    demo_pinned_set()
    demo_sealing_bound()
    demo_polynomial_gcd()
    demo_uniformity()
    demo_two_coprime_semiprimes()
    demo_large_scale()
    print("=" * 74)
    print("All assertions passed: every demonstration confirms the theorems.")
    print("=" * 74)


if __name__ == "__main__":
    main()
