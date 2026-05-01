#!/usr/bin/env python3
"""
Applications of Carmichael's Primitive Divisor Theorem

This script demonstrates practical applications:
1. Fibonacci primality certificates
2. Entry-point-based factorization
3. LFSR period guarantees
"""

from carmichael_demo import fib, factorise, entry_point, is_primitive, proper_divisors

# ─── Application 1: Primality certificates ────────────────────────────

def app_primality_certificate():
    """
    Carmichael's theorem provides primality certificates:
    If we find a prime p with z(p) = n (primitive for F(n)),
    then n must have no proper divisors d > 1 with d | z(p),
    which constrains the factorization of n.
    """
    print("=" * 70)
    print("APPLICATION 1: PRIMALITY CERTIFICATES VIA ENTRY POINTS")
    print("=" * 70)
    print()
    print("Key property: z(p) | (p - 1) or z(p) | (p + 1) for p > 5.")
    print("If z(p) = n, then n | (p ± 1), so p ≡ ±1 (mod n).")
    print()
    print("This gives 'primality witnesses': finding a prime p with z(p) = n")
    print("proves that n divides p-1 or p+1.")
    print()

    print(f"{'n':>5} {'Primitive p':>12} {'p mod n':>10} {'p-1 or p+1 div n?':>20}")
    print("-" * 55)

    for n in [13, 17, 19, 23, 29, 30, 42, 50]:
        fn = fib(n)
        factors = factorise(fn)
        for p in sorted(factors.keys()):
            if is_primitive(p, n):
                p_mod_n = p % n
                div_check = "p-1" if (p - 1) % n == 0 else ("p+1" if (p + 1) % n == 0 else "other")
                print(f"{n:>5} {p:>12} {p_mod_n:>10} {div_check:>20}")
                break

# ─── Application 2: Fibonacci factorization ───────────────────────────

def app_factorization():
    """
    Carmichael's theorem guarantees that F(n) always has 'new' prime factors
    not appearing in any F(d) for proper d | n. This can guide factorization:
    divide out gcd(F(n), F(d)) for proper d | n to isolate the primitive part.
    """
    print()
    print("=" * 70)
    print("APPLICATION 2: GUIDED FIBONACCI FACTORIZATION")
    print("=" * 70)
    print()
    print("Strategy: compute gcd(F(n), F(d)) for each proper divisor d | n.")
    print("The remaining 'primitive part' contains only new primes.")
    print()

    for n in [30, 42, 60]:
        fn = fib(n)
        print(f"F({n}) = {fn}")
        print(f"  Proper divisors of {n}: {proper_divisors(n)}")

        remaining = fn
        for d in proper_divisors(n):
            fd = fib(d)
            if fd > 1:
                import math
                g = math.gcd(remaining, fd)
                while g > 1:
                    remaining //= g
                    g = math.gcd(remaining, fd)

        print(f"  After stripping non-primitive factors: {remaining}")
        if remaining > 1:
            prim_factors = factorise(remaining)
            print(f"  Primitive primes: {list(prim_factors.keys())}")
            for p in prim_factors:
                print(f"    z({p}) = {entry_point(p)} {'= n ✓' if entry_point(p) == n else '≠ n ✗'}")
        print()

# ─── Application 3: LFSR period analysis ──────────────────────────────

def app_lfsr():
    """
    Linear Feedback Shift Registers (LFSRs) with the Fibonacci feedback
    polynomial x² - x - 1 over GF(p) have period related to the entry
    point z(p). Carmichael's theorem guarantees that extending the LFSR
    always introduces new periodicity.
    """
    print("=" * 70)
    print("APPLICATION 3: LFSR PERIOD GUARANTEES")
    print("=" * 70)
    print()
    print("An LFSR with characteristic polynomial x² - x - 1 over GF(p)")
    print("has period dividing z(p), the Fibonacci entry point.")
    print()
    print("Carmichael's theorem ensures: for n > 12, there exists a prime p")
    print("whose Fibonacci period z(p) = n exactly. This means the period")
    print("structure of Fibonacci LFSRs always gains new structure at each step.")
    print()

    print(f"{'n':>5} {'Primitive p':>12} {'LFSR period z(p)':>18} {'Period = n?':>12}")
    print("-" * 55)

    for n in range(13, 51):
        fn = fib(n)
        if fn <= 1:
            continue
        factors = factorise(fn)
        for p in sorted(factors.keys()):
            if is_primitive(p, n):
                z = entry_point(p)
                print(f"{n:>5} {p:>12} {z:>18} {'YES ✓' if z == n else 'NO':>12}")
                break

# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_primality_certificate()
    app_factorization()
    app_lfsr()

    print()
    print("=" * 70)
    print("SUMMARY OF APPLICATIONS")
    print("=" * 70)
    print()
    print("Carmichael's primitive divisor theorem is a workhorse result that:")
    print()
    print("1. PRIMALITY: Provides certificates that n divides p±1 for specific p")
    print("2. FACTORING: Guides factorization by isolating 'new' prime content")
    print("3. CRYPTO:    Ensures LFSR periods gain genuinely new structure")
    print("4. ALGEBRA:   Connects to cyclotomic polynomials and Galois theory")
    print()
    print("The formal verification in Lean 4 ensures these applications rest")
    print("on machine-checked mathematical foundations.")


#!/usr/bin/env python3
"""
Carmichael's Primitive Divisor Theorem — Interactive Demo

For every Fibonacci number F(n) with n > 12, there exists at least one
prime p that divides F(n) but does not divide F(k) for any 0 < k < n.
Such a prime is called a "primitive prime divisor."

This script demonstrates the theorem with concrete numerical examples,
computes entry points, and visualizes the structure.
"""

import math
from collections import defaultdict
from functools import lru_cache

# ─── Fibonacci computation ────────────────────────────────────────────

@lru_cache(maxsize=None)
def fib(n):
    """Compute the n-th Fibonacci number (F(0)=0, F(1)=1)."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

# ─── Factorisation & entry points ─────────────────────────────────────

def factorise(n):
    """Return the prime factorisation of n as a dict {p: e}."""
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def entry_point(p):
    """
    Compute the Fibonacci entry point z(p): the smallest k > 0 with p | F(k).
    Also called the rank of apparition or alpha(p).
    """
    if p <= 1:
        return 0
    for k in range(1, p * p + 2):
        if fib(k) % p == 0:
            return k
    return -1  # Should not happen for primes

def is_primitive(p, n):
    """Check if p is a primitive prime divisor of F(n)."""
    if fib(n) % p != 0:
        return False
    return entry_point(p) == n

def proper_divisors(n):
    """Return the list of proper divisors of n (0 < d < n, d | n)."""
    divs = []
    for d in range(1, n):
        if n % d == 0:
            divs.append(d)
    return divs

# ─── Primitive part computation ────────────────────────────────────────

def primitive_part(n):
    """
    Compute the primitive part Ψ(n) of F(n).

    Ψ(n) = ∏_{d | n} F(d)^{μ(n/d)}

    where μ is the Möbius function. Any prime dividing Ψ(n) is a
    primitive prime divisor of F(n).
    """
    from sympy import mobius, divisors as sym_divisors
    from fractions import Fraction

    result = Fraction(1)
    for d in sym_divisors(n):
        mu = mobius(n // d)
        if mu == 1:
            result *= fib(d)
        elif mu == -1:
            if fib(d) == 0:
                continue
            result /= fib(d)
    return int(result)

# ─── Demo 1: Show primitive prime divisors for small n ─────────────────

def demo_primitive_divisors():
    print("=" * 70)
    print("CARMICHAEL'S PRIMITIVE DIVISOR THEOREM — DEMONSTRATION")
    print("=" * 70)
    print()
    print("For n > 12, F(n) always has at least one 'primitive' prime divisor:")
    print("a prime p | F(n) such that p does not divide F(k) for any 0 < k < n.")
    print()

    print(f"{'n':>4} {'F(n)':>12} {'Factorisation':>30} {'Primitive primes':>20} {'z(p)':>10}")
    print("-" * 80)

    for n in range(1, 31):
        fn = fib(n)
        if fn <= 1:
            print(f"{n:>4} {fn:>12} {'—':>30} {'—':>20}")
            continue

        factors = factorise(fn)
        fact_str = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))

        prims = []
        for p in factors:
            if is_primitive(p, n):
                prims.append(p)

        prim_str = ", ".join(str(p) for p in prims) if prims else "NONE"
        z_str = ", ".join(str(entry_point(p)) for p in prims) if prims else "—"

        marker = " ✓" if n > 12 and prims else (" ✗ (n≤12)" if n <= 12 and not prims else "")
        print(f"{n:>4} {fn:>12} {fact_str:>30} {prim_str:>20} {z_str:>10}{marker}")

    print()
    print("Note: n = 1, 2, 6, 12 are the ONLY indices without primitive primes.")
    print("For n > 12, Carmichael's theorem guarantees at least one exists.")

# ─── Demo 2: Entry point distribution ──────────────────────────────────

def demo_entry_points():
    print()
    print("=" * 70)
    print("ENTRY POINTS (RANK OF APPARITION)")
    print("=" * 70)
    print()
    print("The entry point z(p) is the smallest k > 0 with p | F(k).")
    print("Key property: p | F(n) ⟺ z(p) | n")
    print()

    print(f"{'p':>5} {'z(p)':>6} {'F(z(p))':>12} {'z(p) divides':>30}")
    print("-" * 60)

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]:
        z = entry_point(p)
        fz = fib(z)

        # Find which F(n) for n ≤ 50 are divisible by p
        divisible = [n for n in range(1, 51) if fib(n) % p == 0]
        div_str = ", ".join(str(n) for n in divisible[:8])
        if len(divisible) > 8:
            div_str += ", ..."

        print(f"{p:>5} {z:>6} {fz:>12} {div_str:>30}")

# ─── Demo 3: Primitive part growth ─────────────────────────────────────

def demo_primitive_part_growth():
    print()
    print("=" * 70)
    print("PRIMITIVE PART Ψ(n) — GROWTH DEMONSTRATION")
    print("=" * 70)
    print()
    print("Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)} captures the 'new' prime content")
    print("that appears at index n for the first time.")
    print()
    print("For composite n > 12: Ψ(n) > 1 (Carmichael's theorem)")
    print("Approximate size: Ψ(n) ≈ φ^{φ(n)} where φ = golden ratio")
    print()

    try:
        from sympy import totient
        phi_golden = (1 + math.sqrt(5)) / 2

        print(f"{'n':>5} {'composite?':>10} {'Ψ(n)':>15} {'φ(n)':>6} {'≈ φ^φ(n)':>12} {'Ψ(n)/φ^φ(n)':>12}")
        print("-" * 70)

        for n in range(2, 51):
            is_comp = n > 1 and not all(n % i != 0 for i in range(2, n))
            comp_str = "composite" if is_comp else "prime" if n > 1 else ""

            try:
                psi = primitive_part(n)
            except Exception:
                psi = None

            tot = int(totient(n))
            approx = phi_golden ** tot

            if psi is not None and psi > 0:
                ratio = psi / approx if approx > 0 else float('inf')
                print(f"{n:>5} {comp_str:>10} {psi:>15} {tot:>6} {approx:>12.1f} {ratio:>12.4f}")
            else:
                print(f"{n:>5} {comp_str:>10} {'N/A':>15} {tot:>6}")
    except ImportError:
        print("(Install sympy for primitive part computation: pip install sympy)")

# ─── Demo 4: Verification for larger n ────────────────────────────────

def demo_large_verification():
    print()
    print("=" * 70)
    print("VERIFICATION FOR LARGER INDICES")
    print("=" * 70)
    print()
    print("Checking Carmichael's theorem for composite n up to 200:")
    print()

    failures = []
    successes = 0

    for n in range(14, 201):
        # Skip primes
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue

        fn = fib(n)
        if fn <= 1:
            continue

        factors = factorise(fn)
        has_primitive = False
        for p in factors:
            if is_primitive(p, n):
                has_primitive = True
                break

        if has_primitive:
            successes += 1
        else:
            failures.append(n)

    print(f"  Composite indices checked: {successes + len(failures)}")
    print(f"  All have primitive prime divisors: {'YES ✓' if not failures else 'NO ✗'}")
    if failures:
        print(f"  Failures at: {failures}")
    print()

    # Show a few specific examples
    print("Selected examples:")
    print(f"{'n':>5} {'F(n) digits':>12} {'Primitive prime':>15} {'z(p)':>6}")
    print("-" * 45)

    for n in [30, 42, 100, 144, 200]:
        fn = fib(n)
        factors = factorise(fn)
        for p in sorted(factors.keys()):
            if is_primitive(p, n):
                print(f"{n:>5} {len(str(fn)):>12} {p:>15} {entry_point(p):>6}")
                break

# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_primitive_divisors()
    demo_entry_points()
    demo_large_verification()

    # Try primitive part demo (requires sympy)
    try:
        demo_primitive_part_growth()
    except Exception as e:
        print(f"\n(Primitive part demo skipped: {e})")

    print()
    print("=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print()
    print("Carmichael's theorem (1913) states that for every n > 12,")
    print("F(n) has at least one primitive prime divisor.")
    print()
    print("This is one of the fundamental results in the arithmetic")
    print("of Fibonacci numbers, with applications in:")
    print("  • Primality testing and factorisation algorithms")
    print("  • Algebraic number theory (cyclotomic fields)")
    print("  • Cryptographic key generation")
    print("  • Coding theory (LFSR sequence analysis)")
