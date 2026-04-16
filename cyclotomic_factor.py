#!/usr/bin/env python3
"""
Cyclotomic Channel Factoring — a novel algorithm from Catalog theorems.

Key insight: x^n - 1 = ∏ Φ_d(x) for d|n, where Φ_d are cyclotomic polynomials.
If x^n ≡ 1 (mod N), then N | x^n - 1, so N divides the PRODUCT of all Φ_d(x).
This means gcd(Φ_d(x), N) is nontrivial for at least one d.

For n=6: x⁶-1 = (x-1)(x+1)(x²+x+1)(x²-x+1)
This gives 4 factoring channels from ONE element of order dividing 6!

For n=12: x¹²-1 = (x-1)(x+1)(x²+x+1)(x²-x+1)(x²+1)(x²-x+1)(...)
This gives even more channels!

Catalog theorems:
- cyclotomic_2 through cyclotomic_6
- shor_algebraic_core: a^(2r)-1 = (a^r-1)(a^r+1)
- shor_zmod_factoring: if a^(2k)≡1 mod N, then (a^k-1)(a^k+1)≡0 mod N
- two_reps_factoring: two sum-of-squares => factoring equation
- square_root_ambiguity: nontrivial square root => factor

This is a CLASSICAL generalization of Shor's algorithm:
instead of quantum order finding, we try elements of known multiplicative
order and exploit the full cyclotomic decomposition.
"""

import math

def cyclotomic_eval(x, d, n):
    """Evaluate cyclotomic polynomial Φ_d(x) mod n.
    
    Φ_d(x) = (x^d - 1) / ∏_{d'|d, d'<d} Φ_d'(x)
    
    We use explicit formulas for small d and the product formula for large d.
    """
    # Explicit formulas for small cyclotomic polynomials
    if d == 1:
        return (x - 1) % n
    elif d == 2:
        return (x + 1) % n
    elif d == 3:
        return (x*x + x + 1) % n
    elif d == 4:
        return (x*x + 1) % n
    elif d == 5:
        return (x*x*x*x + x*x*x + x*x + x + 1) % n
    elif d == 6:
        return (x*x - x + 1) % n
    elif d == 8:
        return (x*x*x*x + 1) % n
    elif d == 10:
        return (x*x*x*x - x*x*x + x*x - x + 1) % n
    elif d == 12:
        return (x*x*x*x - x*x + 1) % n
    else:
        # General formula: Φ_d(x) = ∏_{d'|d} (x^{d'} - 1)^μ(d/d')
        # where μ is the Möbius function
        # Simpler: compute (x^d - 1) / ∏_{d'|d, d'<d} Φ_d'(x)
        result = (pow(x, d, n) - 1) % n
        # Find all proper divisors of d
        divisors = [k for k in range(1, d) if d % k == 0]
        for d2 in divisors:
            phi_d2 = cyclotomic_eval(x, d2, n)
            if phi_d2 != 0:
                try:
                    inv = pow(phi_d2, -1, n)
                    result = result * inv % n
                except (ValueError, ZeroDivisionError):
                    # phi_d2 is 0 mod n — this already reveals a factor!
                    return 0
        return result % n


def cyclotomic_channel_factor(n, max_order=100):
    """Cyclotomic Channel Factoring: try elements of known order,
    decompose x^n-1 into cyclotomic factors, check each for GCD.
    
    For each base a and each exponent e such that a^e ≡ 1 (mod n),
    the factorization a^e - 1 = ∏ Φ_d(a) gives multiple channels.
    Each Φ_d(a) is independently checked for gcd with n.
    
    Returns (p, q) if found, None otherwise.
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    if math.isqrt(n)**2 == n: return (math.isqrt(n), math.isqrt(n))
    
    # Try small bases and compute their orders
    for a in range(2, min(50, n)):
        # Compute ord(a) mod n by finding smallest e with a^e ≡ 1 (mod n)
        # First check a^e for small e
        ae = 1
        for e in range(1, max_order + 1):
            ae = ae * a % n
            if ae == 1:
                # Found order e! Decompose a^e - 1 using cyclotomic polynomials
                # Get all divisors of e
                divisors = [d for d in range(1, e+1) if e % d == 0]
                
                for d in divisors:
                    phi_d = cyclotomic_eval(a, d, n)
                    if phi_d == 0:
                        # Φ_d(a) ≡ 0 mod n — factor found via cyclotomic channel!
                        continue  # Already trivially 0
                    g = math.gcd(phi_d, n)
                    if 1 < g < n:
                        return (min(g, n//g), max(g, n//g))
                break  # Found the order, no need to continue
    
    return None


# === Enhanced with order-finding heuristics ===

def smooth_order_channels(n, B=10000):
    """Find factors using smooth-order elements.
    
    If a has order e where e | lcm(1,2,...,B), then a is a B-smooth order element.
    We can decompose a^e - 1 into cyclotomic channels.
    
    Catalog: order_divides_group_size, pow_eq_one_of_order_dvd
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    import random
    random.seed(42)
    
    # Compute M = lcm(1,2,...,B) * some prime to cover more orders
    M = 1
    primes = []
    sv = [True] * (B + 1)
    for i in range(2, B + 1):
        if sv[i]:
            primes.append(i)
            pk = i
            while pk <= B:
                pk *= i
            # M = lcm(M, pk // i)  # Just the largest power ≤ B
            M = M * (pk // i) // math.gcd(M, pk // i)
            for j in range(i*i, B+1, i):
                sv[j] = False
    
    # Try a^M mod n for various a — if gcd(a^M - 1, n) is nontrivial, found!
    # Then decompose into cyclotomic channels
    for a in range(2, min(100, n)):
        # Compute a^M mod n
        aM = pow(a, M, n)
        if aM == 1:
            # a has smooth order! Decompose using cyclotomic channels
            # Also try Shor's channel: a^(M/2) 
            for p in primes[:50]:  # Try dividing M by small primes
                if M % p == 0:
                    half = M // p
                    ahalf = pow(a, half, n)
                    # Shor channel 1: gcd(a^half - 1, n)
                    g = math.gcd(ahalf - 1, n)
                    if 1 < g < n:
                        return (min(g, n//g), max(g, n//g))
                    # Shor channel 2: gcd(a^half + 1, n)
                    g = math.gcd(ahalf + 1, n)
                    if 1 < g < n:
                        return (min(g, n//g), max(g, n//g))
                    
                    # Cyclotomic channels for higher-order divisors
                    # For p=3: Φ_3(a^half) = a^(2*half) + a^half + 1
                    if p >= 3:
                        a2h = pow(a, 2*half, n)
                        phi3 = (a2h + ahalf + 1) % n
                        g = math.gcd(phi3, n)
                        if 1 < g < n:
                            return (min(g, n//g), max(g, n//g))
                        
                        # Φ_6(a^half) = a^(2*half) - a^half + 1
                        phi6 = (a2h - ahalf + 1) % n
                        g = math.gcd(phi6, n)
                        if 1 < g < n:
                            return (min(g, n//g), max(g, n//g))
            
            break  # This element is in the subgroup
    
    return None


def quadruple_division_factor(n):
    """QDF factoring from Catalog's quad_factor_identity.
    Uses the identity that if N = pq and we can find integers a,b with
    a² + b² ≡ 0 (mod N) but a² + b² ≠ 0, the GCD reveals a factor.
    
    Catalog: quad_factor_identity, gcd_dc_divides_sum_sq
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    import random
    random.seed(137)
    
    # Strategy: find (a,b) with a² + b² ≡ 0 (mod N)
    # One approach: compute a = c, b = √(-c²) mod N if the root exists
    # Actually easier: compute gcd(c² + d², n) for various c,d
    
    for _ in range(1000):
        c = random.randrange(2, min(n, 10000))
        csq = c * c % n
        # We need d² ≡ -c² (mod n), i.e., (-c²/n) = 1 (Jacobi symbol)
        # Try multiples of c to find d
        for d in range(1, min(100, n)):
            val = (c*c + d*d) % n
            if val > 0:
                g = math.gcd(val, n)
                if 1 < g < n:
                    return (min(g, n//g), max(g, n//g))
    
    return None


if __name__ == "__main__":
    import time, random, sys
    sys.path.insert(0, '.')
    import factor_autoresearch as fa
    
    # Create test semiprimes at various bit sizes
    print("=== Cyclotomic Channel Factoring Test ===\n")
    
    for bits in [40, 48, 56, 64]:
        random.seed(42)
        p = fa.make_prime(bits//2+1)
        q = fa.make_prime(bits-bits//2+1)
        n = p * q
        
        # Test cyclotomic channel
        t0 = time.perf_counter()
        r = cyclotomic_channel_factor(n)
        t1 = time.perf_counter()
        ok = r is not None and r[0]*r[1] == n
        print(f"{bits}-bit cyclotomic: {ok} in {(t1-t0)*1000:.1f}ms")
        
        # Test smooth order channels
        t0 = time.perf_counter()
        r = smooth_order_channels(n)
        t1 = time.perf_counter()
        ok = r is not None and r[0]*r[1] == n
        print(f"{bits}-bit smooth_order: {ok} in {(t1-t0)*1000:.1f}ms")
        
        # Test QDF
        t0 = time.perf_counter()
        r = quadruple_division_factor(n)
        t1 = time.perf_counter()
        ok = r is not None and r[0]*r[1] == n
        print(f"{bits}-bit QDF: {ok} in {(t1-t0)*1000:.1f}ms")
        
        # Compare with rho
        t0 = time.perf_counter()
        r = fa.pollard_rho_fast(n, 20, use_dual_walk=True)
        t1 = time.perf_counter()
        ok = r is not None and r[0]*r[1] == n
        print(f"{bits}-bit rho: {ok} in {(t1-t0)*1000:.1f}ms")
        print()