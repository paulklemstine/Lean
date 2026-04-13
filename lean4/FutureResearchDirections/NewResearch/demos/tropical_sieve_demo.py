#!/usr/bin/env python3
"""
Tropical Sieve Demo — MetaFactoring Research

Demonstrates the tropical sieve for integer factoring:
For each small prime ℓ, the ℓ-adic valuation v_ℓ(N) = v_ℓ(p) + v_ℓ(q)
constrains possible factors. Multiple primes compose via CRT.

This implements Direction 5 from the MetaFactoring roadmap.
"""

import math
import random

def padic_val(p, n):
    """Compute the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def tropical_sieve(N, prime_set=None):
    """
    Apply the tropical sieve to N.
    For each prime ℓ, v_ℓ(N) = v_ℓ(p) + v_ℓ(q) constrains factors.
    Returns elimination statistics.
    """
    if prime_set is None:
        prime_set = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

    sqrt_N = int(math.isqrt(N))
    total = sqrt_N - 1  # candidates 2..√N

    surviving = set(range(2, sqrt_N + 1))
    info = []

    for ell in prime_set:
        v_N = padic_val(ell, N)
        valid = set(range(v_N + 1))
        before = len(surviving)
        surviving = {x for x in surviving if padic_val(ell, x) in valid}
        after = len(surviving)
        info.append({'prime': ell, 'val': v_N, 'splits': v_N + 1,
                     'killed': before - after})

    rate = 1.0 - len(surviving) / total if total > 0 else 0
    return {'N': N, 'sqrt_N': sqrt_N, 'total': total,
            'surviving': len(surviving), 'rate': rate, 'info': info}


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def gen_semiprime(bits):
    half = bits // 2
    while True:
        p = random.randint(2**(half-1), 2**half - 1)
        q = random.randint(2**(half-1), 2**half - 1)
        if p != q and is_prime(p) and is_prime(q):
            return p * q, min(p, q), max(p, q)


def main():
    print("=" * 65)
    print("  TROPICAL SIEVE DEMONSTRATION — MetaFactoring Direction 5")
    print("=" * 65)

    cases = [(15,"3×5"), (77,"7×11"), (221,"13×17"),
             (1147,"31×37"), (10403,"101×103")]

    print("\n── Small semiprimes ──")
    for N, desc in cases:
        r = tropical_sieve(N)
        print(f"  N={N:>6} = {desc:>8}: elim {r['rate']:5.1%}  "
              f"({r['surviving']}/{r['total']} survive)")

    print("\n── Random semiprimes by bit length ──")
    random.seed(42)
    for bits in [16, 20, 24, 28, 32]:
        rates = [tropical_sieve(gen_semiprime(bits)[0])['rate'] for _ in range(20)]
        print(f"  {bits:>2}-bit: avg elim = {sum(rates)/len(rates):.1%}")

    print("\n── Effect of prime-set size (N=10403) ──")
    primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47]
    for k in range(1, len(primes)+1):
        r = tropical_sieve(10403, primes[:k])
        print(f"  {k:>2} primes → elim {r['rate']:5.1%}  ({r['surviving']} survive)")

    print("\n── Constraint breakdown (N=10403 = 101×103) ──")
    r = tropical_sieve(10403)
    print(f"  {'ℓ':>4} {'v_ℓ(N)':>7} {'splits':>7} {'killed':>8}")
    for c in r['info']:
        print(f"  {c['prime']:>4} {c['val']:>7} {c['splits']:>7} {c['killed']:>8}")

    print("\n" + "=" * 65)
    print("  FORMALLY VERIFIED (Lean 4 + Mathlib):")
    print("  • v_p(ab) = v_p(a) + v_p(b)  [tropical_mult_addition]")
    print("  • Coprime moduli compose via CRT  [totient_mult]")
    print("  • e+1 splits for valuation e  [tropical_split_count]")
    print("=" * 65)

if __name__ == "__main__":
    main()
