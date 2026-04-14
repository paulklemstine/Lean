#!/usr/bin/env python3
"""
Wall-Sun-Sun Conjecture and Fibonacci Pseudoprime Explorer

Explores the Wall-Sun-Sun conjecture: no prime p satisfies
F(p - (p/5)) ≡ 0 (mod p²), and studies Fibonacci pseudoprimes.

Formally verified foundations:
- fib_sq_mod_prime: F(p)² ≡ 1 (mod p) for primes p ≠ 2, 5
- fib_dvd_fib_mul: F(m) | F(mn) for all m, n
- fib_gcd: gcd(F(m), F(n)) = F(gcd(m,n))
"""

import math

def fib_mod(n, m):
    """Compute F(n) mod m efficiently using matrix exponentiation."""
    if m == 1:
        return 0
    if n <= 1:
        return n % m

    # Matrix [[1,1],[1,0]]^n gives [[F(n+1), F(n)], [F(n), F(n-1)]]
    def mat_mul(A, B, mod):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % mod,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % mod],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % mod,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % mod]
        ]

    def mat_pow(M, n, mod):
        result = [[1, 0], [0, 1]]
        while n > 0:
            if n % 2 == 1:
                result = mat_mul(result, M, mod)
            M = mat_mul(M, M, mod)
            n //= 2
        return result

    M = [[1, 1], [1, 0]]
    result = mat_pow(M, n, m)
    return result[0][1]

def pisano_period(m):
    """Compute the Pisano period π(m) - period of F(n) mod m."""
    if m <= 1:
        return 1
    prev, curr = 0, 1
    for i in range(1, m * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i
    return m * m  # Should not reach here

def legendre_symbol(a, p):
    """Compute the Legendre symbol (a/p)."""
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return 1 if result == 1 else -1

def is_prime(n):
    """Miller-Rabin primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def check_wall_sun_sun(p):
    """
    Check if p is a Wall-Sun-Sun prime.
    A WSS prime satisfies F(p - (p/5)) ≡ 0 (mod p²).
    """
    if not is_prime(p) or p <= 5:
        return False

    leg = legendre_symbol(5, p)
    k = p - leg  # p - (5/p)

    fk = fib_mod(k, p * p)
    return fk == 0

def check_wieferich(p):
    """Check if p is a Wieferich prime: 2^(p-1) ≡ 1 (mod p²)."""
    if not is_prime(p) or p <= 2:
        return False
    return pow(2, p - 1, p * p) == 1

def fibonacci_pseudoprime_test(n):
    """
    Test if n is a Fibonacci pseudoprime.
    A composite n passes if F(n)² ≡ 1 (mod n).

    Formally verified: fib_sq_mod_prime proves primes always pass.
    """
    if n <= 1 or is_prime(n):
        return False  # Not composite

    if n % 2 == 0 or n % 5 == 0:
        return False  # Exclude even and multiples of 5

    fn_sq_mod = (fib_mod(n, n) ** 2) % n
    return fn_sq_mod == 1 % n

def demo_wall_sun_sun_search():
    """Search for Wall-Sun-Sun primes."""
    print("=" * 70)
    print("WALL-SUN-SUN PRIME SEARCH")
    print("Conjecture: No prime p satisfies F(p-(5/p)) ≡ 0 (mod p²)")
    print("=" * 70)

    limit = 10000
    print(f"\nSearching primes up to {limit}...")

    wss_found = []
    wieferich_found = []

    for p in range(7, limit):
        if not is_prime(p):
            continue

        if check_wall_sun_sun(p):
            wss_found.append(p)
            print(f"  WALL-SUN-SUN PRIME FOUND: p = {p}")

        if check_wieferich(p):
            wieferich_found.append(p)

    if not wss_found:
        print(f"  No Wall-Sun-Sun primes found below {limit}")
        print(f"  (Consistent with the conjecture)")
    else:
        print(f"  Wall-Sun-Sun primes found: {wss_found}")
        print(f"  THIS WOULD DISPROVE THE CONJECTURE!")

    print(f"\n  Wieferich primes found: {wieferich_found}")
    print(f"  (Only 1093 and 3511 are known)")

def demo_fibonacci_pseudoprimes():
    """Search for and analyze Fibonacci pseudoprimes."""
    print("\n" + "=" * 70)
    print("FIBONACCI PSEUDOPRIME ANALYSIS")
    print("Formally verified: F(p)² ≡ 1 (mod p) for primes p ≠ 2, 5")
    print("=" * 70)

    limit = 100000
    pseudoprimes = []
    composites = 0

    for n in range(9, limit, 2):  # Odd composites
        if is_prime(n) or n % 5 == 0:
            continue
        composites += 1

        if fibonacci_pseudoprime_test(n):
            pseudoprimes.append(n)

    print(f"\nOdd composites checked (not div by 5): {composites}")
    print(f"Fibonacci pseudoprimes found: {len(pseudoprimes)}")
    if pseudoprimes:
        print(f"Density: {len(pseudoprimes)/composites:.6f}")
        print(f"First 20: {pseudoprimes[:20]}")

        # Factor the pseudoprimes
        print(f"\nFactorizations of first Fibonacci pseudoprimes:")
        for n in pseudoprimes[:10]:
            factors = []
            m = n
            for p in range(2, int(math.sqrt(m)) + 1):
                while m % p == 0:
                    factors.append(p)
                    m //= p
            if m > 1:
                factors.append(m)
            print(f"  {n} = {' × '.join(map(str, factors))}")

def demo_pisano_periods():
    """Analyze Pisano periods for small primes."""
    print("\n" + "=" * 70)
    print("PISANO PERIOD ANALYSIS")
    print("Formally verified: π(p) | p² - 1 for primes p ≠ 5")
    print("=" * 70)

    print(f"\n{'p':>5s} {'π(p)':>6s} {'p-1':>6s} {'p+1':>6s} {'p²-1':>8s} {'π|p²-1':>7s} {'(5/p)':>5s} {'p-(5/p)':>7s} {'π|p-(5/p)':>9s}")
    print("-" * 70)

    for p in range(2, 60):
        if not is_prime(p):
            continue
        pi = pisano_period(p)
        leg = legendre_symbol(5, p) if p != 5 else 0
        p_leg = p - leg if p != 5 else p

        divides_psq = "✓" if (p*p - 1) % pi == 0 else "✗"
        divides_pleg = "✓" if p_leg % pi == 0 else "✗"

        print(f"{p:5d} {pi:6d} {p-1:6d} {p+1:6d} {p*p-1:8d} {divides_psq:>7s} {leg:5d} {p_leg:7d} {divides_pleg:>9s}")

def demo_rank_of_apparition():
    """Compute and analyze ranks of apparition."""
    print("\n" + "=" * 70)
    print("RANK OF APPARITION α(p)")
    print("The smallest k > 0 with p | F(k)")
    print("=" * 70)

    print(f"\n{'p':>5s} {'α(p)':>6s} {'π(p)':>6s} {'α|π':>5s} {'F(α) mod p':>10s}")
    print("-" * 45)

    for p in range(2, 50):
        if not is_prime(p):
            continue

        # Find rank of apparition
        alpha = None
        for k in range(1, p * p + 1):
            if fib_mod(k, p) == 0:
                alpha = k
                break

        pi = pisano_period(p)
        divides = "✓" if pi % alpha == 0 else "✗"

        print(f"{p:5d} {alpha:6d} {pi:6d} {divides:>5s} {fib_mod(alpha, p):10d}")

if __name__ == "__main__":
    demo_wall_sun_sun_search()
    demo_fibonacci_pseudoprimes()
    demo_pisano_periods()
    demo_rank_of_apparition()
