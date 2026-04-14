#!/usr/bin/env python3
"""
Quadratic Sieve Factoring Demo

Demonstrates the quadratic sieve algorithm, connecting to our formally
verified results on quadratic residues and smooth numbers.

Formally verified foundations:
- fermat_difference_of_squares: N = x² - y² = (x-y)(x+y)
- qr_mul_qr: Product of QRs is QR
- smooth_mul: Products of smooth numbers are smooth
"""

import math
from collections import defaultdict

def is_prime(n):
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def primes_up_to(B):
    """Sieve of Eratosthenes."""
    sieve = [True] * (B + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(math.sqrt(B)) + 1):
        if sieve[i]:
            for j in range(i*i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]

def legendre_symbol(a, p):
    """Compute the Legendre symbol (a/p)."""
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result == 1 else -1

def tonelli_shanks(n, p):
    """Find x such that x² ≡ n (mod p)."""
    if legendre_symbol(n, p) != 1:
        return None
    if p % 4 == 3:
        return pow(n, (p + 1) // 4, p)
    # Tonelli-Shanks
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while legendre_symbol(z, p) != -1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(n, q, p), pow(n, (q + 1) // 2, p)
    while t != 1:
        i = 1
        temp = (t * t) % p
        while temp != 1:
            temp = (temp * temp) % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c, t, r = i, (b * b) % p, (t * b * b) % p, (r * b) % p
    return r

def factor_over_base(n, factor_base):
    """Try to factor n over the factor base. Returns exponent vector or None."""
    if n == 0:
        return None
    sign = 0
    if n < 0:
        n = -n
        sign = 1
    exponents = [sign]
    for p in factor_base:
        e = 0
        while n % p == 0:
            n //= p
            e += 1
        exponents.append(e)
    if n == 1:
        return exponents
    return None

def gcd(a, b):
    """Greatest common divisor."""
    while b:
        a, b = b, a % b
    return a

def quadratic_sieve_demo(N, verbose=True):
    """
    Simplified quadratic sieve for demonstration.

    Key idea (formally verified as fermat_difference_of_squares):
    Find x, y such that x² ≡ y² (mod N) but x ≢ ±y (mod N).
    Then gcd(x-y, N) gives a nontrivial factor.
    """
    if verbose:
        print(f"\n{'='*60}")
        print(f"QUADRATIC SIEVE: N = {N}")
        print(f"{'='*60}")

    # Step 1: Choose smoothness bound B
    B = max(10, int(math.exp(0.5 * math.sqrt(math.log(N) * math.log(math.log(N))))))
    if verbose:
        print(f"  Smoothness bound B = {B}")

    # Step 2: Build factor base (primes p ≤ B with (N/p) = 1)
    all_primes = primes_up_to(B)
    factor_base = [p for p in all_primes if legendre_symbol(N % p, p) >= 0]
    if verbose:
        print(f"  Factor base: {factor_base[:20]}{'...' if len(factor_base) > 20 else ''}")
        print(f"  Factor base size: {len(factor_base)}")

    # Step 3: Sieving - find smooth values of Q(x) = (x + ⌈√N⌉)² - N
    sqrt_N = math.isqrt(N)
    relations = []
    sieve_range = max(1000, B * 10)

    for x in range(-sieve_range, sieve_range + 1):
        a = sqrt_N + x
        if a <= 0:
            continue
        Q = a * a - N
        vec = factor_over_base(Q, factor_base)
        if vec is not None:
            relations.append((a, Q, vec))
            if len(relations) > len(factor_base) + 5:
                break

    if verbose:
        print(f"  Found {len(relations)} smooth relations")
        for i, (a, Q, vec) in enumerate(relations[:5]):
            print(f"    ({a})² - N = {Q}, exponents = {vec[:8]}...")

    # Step 4: Linear algebra over GF(2) to find dependencies
    if len(relations) <= 1:
        if verbose:
            print("  Not enough relations found")
        return None

    # Simple: try all pairs
    for i in range(len(relations)):
        for j in range(i + 1, len(relations)):
            a1, Q1, v1 = relations[i]
            a2, Q2, v2 = relations[j]

            # Check if exponent vectors sum to even
            combined = [(v1[k] + v2[k]) % 2 for k in range(len(v1))]
            if all(c == 0 for c in combined):
                x = (a1 * a2) % N
                # y² = Q1 * Q2, compute y
                product = Q1 * Q2
                if product < 0:
                    continue
                y = math.isqrt(product)
                if y * y != product:
                    continue

                g = gcd(abs(x - y), N)
                if 1 < g < N:
                    if verbose:
                        print(f"\n  SUCCESS! Found factor via dependency:")
                        print(f"    x = {a1} × {a2} mod N = {x}")
                        print(f"    y = √({Q1} × {Q2}) = {y}")
                        print(f"    gcd(x-y, N) = gcd({abs(x-y)}, {N}) = {g}")
                        print(f"    N = {g} × {N // g}")
                    return g

    if verbose:
        print("  No nontrivial factor found in this attempt")
    return None

def demo_fermat_method(N):
    """
    Fermat's factoring method (formally verified foundation).

    Uses the identity N = x² - y² = (x-y)(x+y).
    """
    print(f"\n{'='*60}")
    print(f"FERMAT'S FACTORING METHOD: N = {N}")
    print(f"{'='*60}")

    x = math.isqrt(N)
    if x * x == N:
        print(f"  N is a perfect square: {x}²")
        return x

    x += 1
    iterations = 0
    max_iter = 10000

    while iterations < max_iter:
        y_sq = x * x - N
        y = math.isqrt(y_sq)
        if y * y == y_sq:
            a, b = x - y, x + y
            print(f"  Found: {N} = {x}² - {y}² = {a} × {b}")
            print(f"  Iterations: {iterations + 1}")
            return a
        x += 1
        iterations += 1

    print(f"  No factorization found in {max_iter} iterations")
    return None

def demo_legendre_symbols():
    """Demonstrate Legendre symbol computation for factoring."""
    print(f"\n{'='*60}")
    print("LEGENDRE SYMBOL ANALYSIS FOR FACTORING")
    print(f"{'='*60}")

    N = 8051  # = 83 × 97
    print(f"\nN = {N} = 83 × 97")
    print(f"\nLegendre symbols (N/p) for small primes:")

    primes = primes_up_to(50)
    for p in primes:
        ls = legendre_symbol(N % p, p)
        symbol = "+" if ls == 1 else ("-" if ls == -1 else "0")
        factor_info = ""
        if ls == 0:
            factor_info = f" ← p={p} divides N!" if N % p == 0 else ""
        print(f"  (N/{p:2d}) = {symbol:>2s}{factor_info}")

    print(f"\nFactor base (primes with (N/p) ≥ 0): "
          f"{[p for p in primes if legendre_symbol(N % p, p) >= 0]}")

def demo_smooth_numbers():
    """Demonstrate smooth number theory."""
    print(f"\n{'='*60}")
    print("SMOOTH NUMBER DISTRIBUTION")
    print(f"{'='*60}")

    for B in [5, 10, 20, 50]:
        count = 0
        total = 1000
        for n in range(2, total + 1):
            m = n
            is_smooth = True
            for p in primes_up_to(B):
                while m % p == 0:
                    m //= p
            if m == 1:
                count += 1
        density = count / total
        print(f"  {B:3d}-smooth numbers up to {total}: {count} ({density:.1%})")

if __name__ == "__main__":
    # Fermat's method demos
    demo_fermat_method(5959)    # = 59 × 101
    demo_fermat_method(10403)   # = 101 × 103

    # Quadratic sieve demos
    quadratic_sieve_demo(15)
    quadratic_sieve_demo(1073)
    quadratic_sieve_demo(5959)

    # Legendre symbol analysis
    demo_legendre_symbols()

    # Smooth number distribution
    demo_smooth_numbers()
