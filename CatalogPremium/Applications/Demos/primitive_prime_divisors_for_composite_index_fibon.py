"""
Carmichael's Primitive Prime Divisor Theorem for Fibonacci Numbers
=================================================================

This demo illustrates Carmichael's 1913 theorem: for every n ≥ 13,
the Fibonacci number F(n) has at least one "primitive" prime divisor —
a prime that divides F(n) but does not divide F(k) for any 0 < k < n.

We demonstrate the theorem with concrete numerical examples, compute
primitive prime divisors, and visualize the growth of the primitive part.
"""

import math
from functools import lru_cache
from collections import defaultdict
import sys

# ─── Fibonacci computation ───────────────────────────────────────────

@lru_cache(maxsize=None)
def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

# ─── Entry point (rank of apparition) ───────────────────────────────

def entry_point(p):
    """Compute z(p): the smallest k > 0 with p | F(k)."""
    if p <= 1:
        return 0
    a, b = 0, 1
    for k in range(1, p * p + 2):  # z(p) | p^2 - 1
        a, b = b, (a + b) % p
        if b == 0:
            return k
    return 0  # should not happen for primes

# ─── Prime factorization ────────────────────────────────────────────

def prime_factors(n):
    """Return a list of (prime, exponent) pairs."""
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            n //= d
            exp += 1
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors

def proper_divisors(n):
    """Return sorted list of proper divisors of n (excluding n itself)."""
    divs = []
    for d in range(1, n):
        if n % d == 0:
            divs.append(d)
    return divs

# ─── Primitive part computation ──────────────────────────────────────

def strip_all(r, m):
    """Strip all factors of m from r (make coprime)."""
    while True:
        g = math.gcd(r, m)
        if g <= 1:
            return r
        r //= g

def prim_part(n):
    """Compute the primitive part of F(n)."""
    fn = fib(n)
    for d in proper_divisors(n):
        fn = strip_all(fn, fib(d))
    return fn

def find_primitive_primes(n):
    """Find all primitive prime divisors of F(n)."""
    pp = prim_part(n)
    return prime_factors(pp)

# ─── Demo: Primitive prime divisors for small n ──────────────────────

def demo_small_n():
    print("=" * 70)
    print("PRIMITIVE PRIME DIVISORS OF FIBONACCI NUMBERS")
    print("=" * 70)
    print()
    print("For each composite n, we show F(n), its primitive part, and")
    print("the primitive prime divisors (primes dividing F(n) but no F(k), k<n).")
    print()

    exceptions = {1, 2, 6, 12}  # Known exceptions (no primitive prime divisor)

    for n in range(1, 51):
        fn = fib(n)
        pp = prim_part(n)
        prim_primes = find_primitive_primes(n)
        is_prime_n = all(n % d != 0 for d in range(2, int(n**0.5) + 1)) and n > 1

        status = ""
        if n in exceptions:
            status = " ← EXCEPTION (no primitive prime)"
        elif n >= 13 and not is_prime_n and pp <= 1:
            status = " ← VIOLATION (should not happen!)"

        if n <= 30 or pp == 1 or n in [42, 48, 50]:
            prim_str = ", ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in prim_primes) if prim_primes else "none"
            print(f"  n={n:3d}: F(n) = {fn if fn < 10**12 else f'{fn:.6e}'}, "
                  f"primPart = {pp if pp < 10**9 else f'{pp:.4e}'}, "
                  f"primitive primes: {prim_str}{status}")

    print()
    print("Carmichael's theorem: For n ≥ 13, F(n) ALWAYS has a primitive prime.")
    print("The only exceptions are n ∈ {1, 2, 6, 12}.")

# ─── Demo: Entry points and the Fibonacci LTE ───────────────────────

def demo_entry_points():
    print()
    print("=" * 70)
    print("ENTRY POINTS AND THE LIFTING-THE-EXPONENT LEMMA")
    print("=" * 70)
    print()
    print("The entry point z(p) of a prime p is the smallest k > 0")
    print("with p | F(k). Carmichael's theorem says z(p) = n for")
    print("at least one prime p dividing F(n), for each n ≥ 13.")
    print()

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 89, 97, 101, 137]:
        z = entry_point(p)
        print(f"  z({p:4d}) = {z:5d}   (F({z}) = {fib(z)} ≡ 0 mod {p})")

    print()
    print("The Fibonacci LTE: for odd prime q ≠ 5 with q | F(m):")
    print("  v_q(F(m·k)) = v_q(F(m)) + v_q(k)")
    print()

    # Demonstrate LTE for q=3, m=4 (since F(4)=3)
    q, m = 3, 4
    print(f"Example: q={q}, m={m}, z({q})={entry_point(q)}")
    for k in [1, 2, 3, 4, 5, 6, 9, 12]:
        fmk = fib(m * k)
        v_q_fmk = 0
        temp = fmk
        while temp % q == 0:
            v_q_fmk += 1
            temp //= q
        v_q_fm = 0
        temp = fib(m)
        while temp % q == 0:
            v_q_fm += 1
            temp //= q
        v_q_k = 0
        temp = k
        while temp % q == 0:
            v_q_k += 1
            temp //= q
        print(f"  k={k:3d}: v_{q}(F({m}·{k})) = v_{q}(F({m*k})) = {v_q_fmk} "
              f"= {v_q_fm} + {v_q_k} = v_{q}(F({m})) + v_{q}({k})")

# ─── Demo: Growth of primitive part ──────────────────────────────────

def demo_growth():
    print()
    print("=" * 70)
    print("GROWTH OF THE PRIMITIVE PART")
    print("=" * 70)
    print()
    print("The primitive part Ψ_n ≈ φ^{φ(n)} grows exponentially.")
    print("For composite n, log₂(primPart(n)) is shown:")
    print()

    phi = (1 + 5**0.5) / 2

    for n in range(14, 101):
        is_prime = all(n % d != 0 for d in range(2, int(n**0.5) + 1))
        if is_prime:
            continue
        pp = prim_part(n)
        if pp > 1:
            log2_pp = math.log2(pp)
            euler_phi = n
            for p, _ in prime_factors(n):
                euler_phi = euler_phi * (p - 1) // p
            expected = euler_phi * math.log2(phi)
            bar = "█" * max(1, int(log2_pp / 3))
            print(f"  n={n:3d}: log₂(Ψ_n) = {log2_pp:8.1f} "
                  f"(≈ φ(n)·log₂(φ) = {expected:6.1f})  {bar}")

# ─── Demo: Cryptographic application ────────────────────────────────

def demo_crypto():
    print()
    print("=" * 70)
    print("APPLICATION: FIBONACCI PSEUDOPRIMES AND PRIMALITY TESTING")
    print("=" * 70)
    print()
    print("Carmichael's theorem guarantees that for n ≥ 13, F(n) always has")
    print("a 'new' prime factor. This is used in:")
    print("  1. Fibonacci-based pseudoprime tests")
    print("  2. Elliptic curve factorization (ECM) with Fibonacci curves")
    print("  3. Proving irrationality of certain constants")
    print()

    print("Fibonacci pseudoprime test: n is a Fibonacci pseudoprime if")
    print("F(n) ≡ (n/5) mod n, where (n/5) is the Legendre symbol.")
    print()

    composites = [n for n in range(4, 200) if not all(n % d != 0 for d in range(2, int(n**0.5) + 1))][:20]
    for n in composites:
        fn_mod_n = fib(n) % n
        legendre = pow(5, (n - 1) // 2, n) if n > 2 else 0
        is_pseudo = (fn_mod_n == legendre % n or fn_mod_n == (n - legendre) % n)
        print(f"  n={n:4d}: F(n) mod n = {fn_mod_n:4d}, "
              f"pseudo = {'YES' if is_pseudo else 'no'}")

# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_small_n()
    demo_entry_points()
    demo_growth()
    demo_crypto()

    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("Carmichael's theorem (1913) states that for every n ≥ 13,")
    print("the Fibonacci number F(n) has at least one primitive prime")
    print("divisor — a prime p such that p | F(n) but p ∤ F(k) for")
    print("all 0 < k < n.")
    print()
    print("Our Lean 4 formalization proves this theorem by:")
    print("  • Computational verification for 13 ≤ n ≤ 10000 (native_decide)")
    print("  • The Fibonacci Lifting-the-Exponent Lemma for the infinite tail")
    print("  • Entry-point theory via Nat.fib_gcd")
    print()
    print("The formalization is in Catalog/Shared/CarmichaelProof.lean")
