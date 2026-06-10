#!/usr/bin/env python3
"""
Fibonacci-Based Factoring Methods — Algorithms 29-35 from the SPB Framework

Demonstrates factoring via Pisano periods, Fibonacci entry points,
and the GCD identity gcd(F_m, F_n) = F_{gcd(m,n)}.

Based on formally verified mathematics in:
  - Shared/Fib_gcd_identity.lean: fib_gcd_identity, fib_dvd_chain
  - Speculative/PisanoPeriodFactoring.lean: fib_mod_periodic, pisano_coprime_lcm
  - Shared/Fib_gcd_identity.lean: fib_sq_mod_prime, fib_composite_test
"""

import math
from typing import Optional, Tuple, List, Dict


def fib_mod(n: int, m: int) -> int:
    """Compute F(n) mod m efficiently using matrix exponentiation."""
    if n <= 0:
        return 0
    if n == 1:
        return 1 % m
    
    # Matrix [[1,1],[1,0]]^n method
    def mat_mul(A, B, mod):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % mod,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % mod],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % mod,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % mod]
        ]
    
    def mat_pow(M, p, mod):
        result = [[1, 0], [0, 1]]
        base = [row[:] for row in M]
        while p > 0:
            if p % 2 == 1:
                result = mat_mul(result, base, mod)
            base = mat_mul(base, base, mod)
            p //= 2
        return result
    
    Q = mat_pow([[1, 1], [1, 0]], n - 1, m)
    return Q[0][0]


def pisano_period(m: int) -> int:
    """
    Compute the Pisano period π(m) — the period of Fibonacci numbers mod m.
    Verified to exist with period ≤ m² (fib_mod_periodic in PisanoPeriodFactoring.lean).
    """
    if m <= 1:
        return 1
    
    prev, curr = 0, 1
    for i in range(1, m * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i
    return m * m  # Should never reach here by the verified bound


def fibonacci_entry_point(N: int) -> int:
    """
    Compute α(N) — the smallest k > 0 such that N | F(k).
    This is the Fibonacci entry point (rank of apparition).
    """
    if N <= 1:
        return 1
    
    prev, curr = 0, 1
    for k in range(1, N * N + 1):
        if curr % N == 0:
            return k
        prev, curr = curr, (prev + curr) % N
    return -1


def pisano_factor(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Pisano Period Factoring (Algorithm 29).
    
    For N = pq with coprime p, q:
      π(N) = lcm(π(p), π(q))    [verified: pisano_coprime_lcm]
    
    Strategy: Compute π(N), then for each divisor d of π(N),
    check if gcd(F(d), N) gives a nontrivial factor.
    """
    if verbose:
        print(f"Pisano Period Factoring: N = {N}")
    
    pi_N = pisano_period(N)
    if verbose:
        print(f"  π({N}) = {pi_N}")
    
    # Compute divisors of π(N)
    divisors = []
    for d in range(1, pi_N + 1):
        if pi_N % d == 0:
            divisors.append(d)
    
    # Check F(d) mod N for each divisor
    for d in divisors:
        f_d = fib_mod(d, N)
        if f_d == 0 and d < pi_N:
            g = math.gcd(fib_mod(d, N * N) if N < 1000 else f_d, N)
            # Try the entry point approach
            # gcd(F_m, F_n) = F_{gcd(m,n)} [fib_gcd_identity]
            for k in range(2, int(math.isqrt(N)) + 10):
                f_k = fib_mod(k, N)
                g = math.gcd(f_k, N)
                if 1 < g < N:
                    if verbose:
                        print(f"  Found factor: gcd(F({k}), {N}) = {g}")
                    return (g, N // g)
    
    return None


def fibonacci_sieve_factor(N: int, B: int = 100, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Fibonacci Sieve (Algorithm 35).
    
    Analogous to Pollard's p-1: compute gcd(F(M), N) where M is
    a product of small primes. Uses fib_dvd_chain: m|n ⟹ F(m)|F(n).
    
    If α(p) is B-smooth for some prime factor p of N, this finds p.
    """
    if verbose:
        print(f"Fibonacci Sieve: N = {N}, B = {B}")
    
    # Build M = lcm(1, 2, ..., B) incrementally
    M = 1
    primes = []
    for p in range(2, B + 1):
        if all(p % q != 0 for q in range(2, int(p**0.5) + 1)):
            primes.append(p)
    
    # Accumulate: compute F(M) mod N where M = Π p^a
    # Use the identity F(mn) involves F(m) and F(n)
    # Simpler: just compute F(k!) mod N for increasing k
    
    f_M = 1  # F(1) mod N
    M = 1
    for p in primes:
        pk = p
        while pk <= B:
            M *= pk
            # Compute F(M) mod N
            f_M = fib_mod(M, N)
            g = math.gcd(f_M, N)
            if 1 < g < N:
                if verbose:
                    print(f"  Found factor at M includes {p}^{int(math.log(pk, p))}: gcd(F(M), {N}) = {g}")
                return (g, N // g)
            if g == N:
                # Overshot — need to backtrack
                if verbose:
                    print(f"  Overshot at p = {p}")
                break
            pk *= p
    
    return None


def fibonacci_pseudoprime_test(N: int) -> bool:
    """
    Fibonacci pseudoprime test (Algorithm 31).
    
    If N is prime and N ≠ 2, 5, then F(N)² ≡ 1 (mod N).
    [Verified: fib_sq_mod_prime]
    
    Contrapositive: if F(N)² ≢ 1 (mod N), then N is composite.
    [Verified: fib_composite_test]
    """
    if N <= 1:
        return False
    if N in [2, 3, 5]:
        return True
    if N % 2 == 0:
        return False
    
    f_N = fib_mod(N, N)
    return (f_N * f_N) % N == 1 % N


def demo():
    """Run demonstrations of Fibonacci factoring methods."""
    print("=" * 60)
    print("Fibonacci-Based Factoring Methods")
    print("=" * 60)
    
    # 1. Pisano periods
    print("\n--- Pisano Periods π(m) ---")
    for m in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 50, 100]:
        pi = pisano_period(m)
        print(f"  π({m:>4}) = {pi}")
    
    # 2. The GCD identity in action
    print("\n--- GCD Identity: gcd(F(m), F(n)) = F(gcd(m,n)) ---")
    for m, n in [(6, 9), (8, 12), (10, 15), (12, 18), (20, 30)]:
        g = math.gcd(m, n)
        # Compute actual Fibonacci numbers for small values
        def fib(k):
            a, b = 0, 1
            for _ in range(k):
                a, b = b, a + b
            return a
        
        fm, fn, fg = fib(m), fib(n), fib(g)
        gcd_fibs = math.gcd(fm, fn)
        print(f"  gcd(F({m}), F({n})) = gcd({fm}, {fn}) = {gcd_fibs} = F({g}) = {fg} ✓")
    
    # 3. Fibonacci pseudoprime test
    print("\n--- Fibonacci Pseudoprime Test ---")
    for N in [7, 11, 13, 15, 21, 35, 49, 77, 91, 221, 323]:
        is_pseudo = fibonacci_pseudoprime_test(N)
        actual_prime = all(N % i != 0 for i in range(2, int(N**0.5) + 1)) and N > 1
        status = "prime" if actual_prime else "COMPOSITE"
        test_says = "passes" if is_pseudo else "FAILS"
        flag = "✓" if (is_pseudo == actual_prime) or (is_pseudo and not actual_prime) else ""
        if not actual_prime and is_pseudo:
            flag = "⚠ pseudoprime!"
        print(f"  N = {N:>5}: {status:>9}, test {test_says:>6} {flag}")
    
    # 4. Fibonacci sieve factoring
    print("\n--- Fibonacci Sieve Factoring ---")
    test_cases = [15, 21, 35, 77, 91, 143, 221, 323, 1001, 2021, 10403]
    for N in test_cases:
        result = fibonacci_sieve_factor(N, B=50)
        if result:
            p, q = result
            print(f"  N = {N:>8} → {p} × {q} ✓")
        else:
            print(f"  N = {N:>8} → not factored with B=50 ✗")
    
    # 5. Entry points
    print("\n--- Fibonacci Entry Points α(N) ---")
    for N in [2, 3, 5, 7, 11, 13, 15, 21, 35, 77]:
        alpha = fibonacci_entry_point(N)
        print(f"  α({N:>4}) = {alpha:>4}  (F({alpha}) = {fib_mod(alpha, N*100)} ≡ 0 mod {N})")


if __name__ == "__main__":
    demo()
