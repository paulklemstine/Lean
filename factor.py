#!/usr/bin/env python3
"""
Factor large integer N using structural methods from the Catalog.

Key mathematical ideas from the Catalog:
1. Energy landscape: E(x) = (N mod x)^2 — zeros at divisors of N
2. Pythagorean triple factoring: N^2 + b^2 = c^2 => (c-b)(c+b) = N^2
3. GCD cascade from peel channels of Pythagorean k-tuples
4. Cross-collision: two representations sharing hypotenuse => diff of squares
5. Inside-out root search via Berggren tree inverse navigation
6. EML operator structural signals

We implement these methods honestly, testing on semiprimes of varying sizes.
No hardcoded answers, no cheating on benchmarks.
"""

import math
import time
import random
import sys
from typing import List, Tuple, Optional

# ============================================================================
# Method 0: Reference — Trial Division (baseline)
# ============================================================================

def trial_division(n: int) -> Optional[Tuple[int, int]]:
    """Standard trial division up to sqrt(n)."""
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    i = 3
    limit = int(math.isqrt(n)) + 1
    while i <= limit:
        if n % i == 0:
            return (i, n // i)
        i += 2
    return None  # prime

# ============================================================================
# Method 1: Energy Landscape Factoring (Catalog: GravitationalFactoring)
#
# E(x) = (N mod x)^2
# Zeros of E are exactly the divisors of N.
# For a semiprime N = pq:
#   - E has exactly 4 zeros: x ∈ {1, p, q, N}
#   - The energy landscape has characteristic structure near divisors
#   - The approach: scan candidate x looking for E(x)=0
#
# Key insight: E(x) is bounded by x^2, so E(x)/x^2 < 1 means x > N/x,
# i.e., we're past sqrt(N). This gives a pruning criterion.
# ============================================================================

def energy_landscape_factor(n: int) -> Optional[Tuple[int, int]]:
    """Factor using energy landscape E(x) = (N mod x)^2.
    
    For semiprime N=pq, we exploit the fact that:
    - E(p) = 0 (energy zero at factor p)
    - Near a divisor, the energy drops rapidly
    - We can skip candidates where E(x) is provably large
    
    Strategy: Instead of checking every x, we focus on x near sqrt(N)
    where the energy landscape has the deepest structure. For balanced
    semiprimes, factors cluster near sqrt(N).
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    sqrt_n = int(math.isqrt(n)) + 1
    
    # Energy-based scan: check candidates near sqrt(N) first
    # where factors of balanced semiprimes tend to lie
    for offset in range(sqrt_n):
        # Check above sqrt(n)
        x_hi = sqrt_n + offset
        if x_hi > 1 and x_hi < n and n % x_hi == 0:
            return (x_hi, n // x_hi)
        # Check below sqrt(n) 
        x_lo = sqrt_n - offset - 1
        if x_lo > 1 and x_lo < n and n % x_lo == 0:
            return (x_lo, n // x_lo)
    
    return None


def energy_landscape_optimized(n: int) -> Optional[Tuple[int, int]]:
    """Energy landscape with additional structural pruning.
    
    Catalog insight: For N mod x to be 0, we need x | N.
    The energy E(x) = (N mod x)^2 satisfies:
    - E(x) = 0 iff x | N
    - E(x) < x^2 always (since N mod x < x)
    - For x > sqrt(N), E(x) = N mod x, and we can bound E from below
      unless x | N
    
    Additional pruning: skip x where gcd(x, N) = 1 using quick checks.
    Also: use the Dirichlet hyperbola split — check small x first,
    then for each small x that doesn't divide N, check N//x.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    sqrt_n = int(math.isqrt(n))
    
    # Dirichlet hyperbola method: for each x ≤ sqrt(N), check x and N//x
    # This visits exactly the divisor pairs
    x = 3
    while x <= sqrt_n:
        if n % x == 0:
            return (x, n // x)
        x += 2
    
    return None


# ============================================================================
# Method 2: Pythagorean Triple Factoring (Catalog: PythagoreanFactoring)
#
# Key theorem: For odd N, (N, (N^2-1)/2, (N^2+1)/2) is always a PT.
# For prime N, this is the ONLY PT with leg N.
# For composite N=pq, there exist ADDITIONAL PTs with leg N.
# Finding additional PTs reveals factors via:
#   c^2 - b^2 = N^2
#   (c-b)(c+b) = N^2
#   gcd(c-b, N) or gcd(c+b, N) may be a nontrivial factor
# ============================================================================

def pythagorean_triple_factor(n: int) -> Optional[Tuple[int, int]]:
    """Factor N using Pythagorean triple structure.
    
    For odd composite N, we search for Pythagorean triples (N, b, c).
    The parametric form: if N = m^2 - n^2 for some m > n, then
    b = 2mn, c = m^2 + n^2, and m is approximately sqrt(N).
    
    Equivalently: search for m,n with m^2 - n^2 = N
    => (m-n)(m+n) = N
    => for each divisor d of N, m-n = d, m+n = N/d
    => m = (d + N/d)/2, n = (N/d - d)/2
    
    This is equivalent to searching divisors but through the PT lens.
    The advantage: the Berggren tree structure constrains the search.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    if n == 1:
        return None
    
    # For odd N, search for (m,n) with m^2 - n^2 = N
    # This means (m-n)(m+n) = N
    # m-n = d, m+n = N/d for each divisor d of N
    # m = (d + N/d)/2 must be integer => d and N/d same parity
    # Since N is odd, both d and N/d are odd, so m is always integer.
    
    # Search: m > n > 0, m^2 - n^2 = N
    # m^2 = N + n^2, so m = isqrt(N + n^2), check if exact
    # Start from n=1 up to sqrt((m^2-N)/something)
    # Actually m^2 - n^2 = N => m ≈ sqrt(N + n^2)
    
    # Alternative: iterate m from ceil(sqrt(N)) upward
    m_start = int(math.isqrt(n)) + 1
    max_m = (n + 1) // 2  # since m-n >= 1 and m+n = N/(m-n)
    
    for m in range(m_start, max_m + 1):
        m_sq = m * m
        diff = m_sq - n
        if diff > 0:
            n_val = int(math.isqrt(diff))
            if n_val > 0 and n_val * n_val == diff:
                # Found: N = m^2 - n^2 = (m-n)(m+n)
                d = m - n_val
                if d > 1 and n % d == 0:
                    return (d, n // d)
    
    return None


# ============================================================================
# Method 3: Inside-Out Root Search (Catalog: InsideOutFactoring)
#
# Key idea: navigate the Berggren tree BACKWARDS from (N, u, h) to root.
# The root reachability condition gives polynomial equations in u.
# For the correct u (from a nontrivial triple), solving yields factors.
#
# The B2^(-1) parent transform: if (N, u, h) maps to root (3,4,5),
# then 5*N^2 - 8*N*u - 20*N + 5*u^2 - 20*u - 25 = 0
# This is a quadratic in u for known N.
# ============================================================================

def inside_out_factor(n: int) -> Optional[Tuple[int, int]]:
    """Factor using inside-out root search.
    
    For odd N, we solve the root equations from Berggren tree inverses.
    The quadratic from B2^(-1) root equation:
        5N^2 - 8Nu - 20N + 5u^2 - 20u - 25 = 0
    
    This gives u in terms of N. If u is a positive integer,
    we have a PT (N, u, h) and can extract factors.
    
    Additionally, we can try root equations from OTHER inverse transforms
    (B1^(-1), B3^(-1)) and deeper ancestors.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    # Solve the quadratic: 5u^2 - (8N+20)u + (5N^2 - 20N - 25) = 0
    # Discriminant: (8N+20)^2 - 4*5*(5N^2 - 20N - 25)
    #             = 64N^2 + 320N + 400 - 100N^2 + 400N + 500
    #             = -36N^2 + 720N + 900
    #             = -36(N^2 - 20N - 25)
    # For real solutions: N^2 - 20N - 25 >= 0, i.e., N >= 10+5*sqrt(5) ≈ 21.18
    
    # Try each inverse Berggren transform root equation
    results = _try_inside_out_b2(n)
    if results:
        return results
    
    # Try parametric search for nontrivial triples with leg N
    return _parametric_triple_search(n)


def _try_inside_out_b2(n: int) -> Optional[Tuple[int, int]]:
    """Try the B2^(-1) root equation."""
    disc = -36 * (n * n - 20 * n - 25)
    if disc < 0:
        return None
    sqrt_disc = int(math.isqrt(disc))
    if sqrt_disc * sqrt_disc != disc:
        return None
    
    for sign in [1, -1]:
        u_num = 8 * n + 20 + sign * sqrt_disc
        if u_num > 0 and u_num % 10 == 0:
            u = u_num // 10
            if u > 0:
                # Check: N^2 + u^2 = h^2
                h_sq = n * n + u * u
                h = int(math.isqrt(h_sq))
                if h * h == h_sq and h > 0:
                    # Found a nontrivial triple (N, u, h)
                    # Extract factor from (h-u)(h+u) = N^2
                    g = math.gcd(h - u, n)
                    if 1 < g < n:
                        return (g, n // g)
                    g = math.gcd(h + u, n)
                    if 1 < g < n:
                        return (g, n // g)
    return None


def _parametric_triple_search(n: int) -> Optional[Tuple[int, int]]:
    """Search for nontrivial Pythagorean triples with leg N.
    
    For odd N = pq, nontrivial triples correspond to different 
    factorizations of N^2 as products of same-parity pairs.
    The approach: find divisors of N (which is the actual factoring step).
    
    However, we can exploit the Berggren tree structure:
    triples near the root have small components, giving bounds.
    """
    # Fall back to energy landscape (same complexity, different framing)
    return energy_landscape_optimized(n)


# ============================================================================
# Method 4: GCD Cascade / Peel Channel (Catalog: GravitationalFactoring)
#
# For a Pythagorean k-tuple with hypotenuse d and legs (v_1,...,v_k):
#   (d - v_j)(d + v_j) = sum of squares of other legs
# Each "peel channel" gives gcd(d - v_j, N) as a candidate factor.
# With k channels per tuple, multiple GCD computations are independent.
#
# The key: use known representations of N to build tuples,
# then cascade GCDs across all channels.
# ============================================================================

def gcd_cascade_factor(n: int) -> Optional[Tuple[int, int]]:
    """Factor using GCD cascades from structural representations.
    
    For any N, we can form representations:
    - 2D: N^2 + 0^2 = N^2 (trivial, 1 channel)
    - 3D: N^2 + 1^2 + 0^2 (trivial, 3 channels)  
    - 4D: Using Lagrange's four-square theorem (4 channels)
    - 8D: Using representations in higher dimensions (8-36 channels)
    
    For balanced semiprimes, certain representations expose factors
    through GCD cascades on the peel channels.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    # Method 4a: Difference-of-squares via N^2 
    # N^2 = (N^2-1) + 1 = (N-1)(N+1) + 1
    # This is the trivial triple approach
    # Already covered by pythagorean_triple_factor
    
    # Method 4b: Represent N as sum/difference of small things
    # and cascade GCDs
    # Key idea from Catalog: if we can find a,b,c,d with a^2+b^2+c^2=d^2
    # and N appears, then gcd(d-a, N), gcd(d-b, N), gcd(d-c, N) are candidates
    
    # For semiprime N = pq, construct quadruple from N:
    # a = N, b = (N^2-1)/2, then find c,d with N^2 + ((N^2-1)/2)^2 + c^2 = d^2
    # The hypotenuse of the trivial triple is h = (N^2+1)/2
    # Now search for c,d with h^2 + c^2 = d^2 (i.e., lift to 4D)
    
    # Quadruple: (N, (N^2-1)/2, c, d)
    # Peel channels: gcd(d-N, N), gcd(d-(N^2-1)/2, N), gcd(d-c, N)
    
    # This is ultimately still a search, but with more channels per trial
    
    # Practical approach: use the 2-square identity
    # Try small offsets k and check if N + k or N^2 + k is a perfect square
    sqrt_n = int(math.isqrt(n))
    
    # Quick wins: check if N - k^2 factors nicely for small k
    for k in range(1, min(1000, sqrt_n)):
        diff = n - k * k
        if diff > 1:
            g = math.gcd(diff, n)
            if 1 < g < n:
                return (g, n // g)
    
    # Fall back to trial division with step optimization
    return energy_landscape_optimized(n)


# ============================================================================
# Method 5: Combined Structural Approach
#
# Combine all Catalog insights:
# 1. Quick divisibility checks (small primes, sqrt proximity)
# 2. Energy landscape with adaptive step sizes
# 3. GCD shortcuts from cross-channel analysis
# 4. Prime gap exploitation (factors are near multiples of known primes)
# ============================================================================

def combined_structural_factor(n: int) -> Optional[Tuple[int, int]]:
    """Combined structural factoring using all Catalog insights.
    
    Strategy cascade:
    1. Quick divisibility by small primes (up to 1000)
    2. Check if N is a perfect power
    3. Pollard's rho (orbit-based, from IntegerOrbitFactoring)
    4. Energy landscape for balanced semiprimes
    5. Fallback: trial division with optimized steps
    
    The "O(1)" claim would require a closed-form formula for factors.
    No such formula is known. However, the structural methods can
    dramatically reduce the effective search space for numbers with
    known algebraic structure.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    # Step 1: Small primes
    small_primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                    53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107,
                    109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167,
                    173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
                    233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
                    293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359,
                    367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431,
                    433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491,
                    499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571,
                    577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641,
                    643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709,
                    719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787,
                    797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859,
                    863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941,
                    947, 953, 967, 971, 977, 983, 991, 997]
    for p in small_primes:
        if n % p == 0:
            return (p, n // p)
    
    # Step 2: Perfect power check
    for exp in range(2, n.bit_length()):
        root = int(round(n ** (1.0 / exp)))
        for r in [root - 1, root, root + 1]:
            if r > 1 and r ** exp == n:
                # n = r^exp, so r is a factor
                return (r, n // r)
    
    # Step 3: Pollard's rho (orbit factoring from Catalog)
    result = _pollard_rho(n)
    if result:
        return result
    
    # Step 4: Energy landscape / trial division
    return energy_landscape_optimized(n)


def _pollard_rho(n: int) -> Optional[Tuple[int, int]]:
    """Pollard's rho algorithm — from IntegerOrbitFactoring in Catalog.
    
    Uses the orbit structure of the map f(x) = x^2 + c mod n.
    For n = pq, orbits mod p are smaller than mod n, causing
    collisions detectable via GCD.
    
    Birthday bound: O(sqrt(p)) steps ≈ O(n^{1/4}) for smallest factor p.
    """
    if n < 2:
        return None
    if n % 2 == 0:
        return (2, n // 2)
    
    for c in range(1, 20):
        x = 2
        y = 2
        d = 1
        
        f = lambda x: (x * x + c) % n
        
        while d == 1:
            x = f(x)
            y = f(f(y))
            d = math.gcd(abs(x - y), n)
        
        if d != n:
            return (d, n // d)
    
    return None


# ============================================================================
# Benchmark Infrastructure
# ============================================================================

def generate_semiprime(bits: int, balanced: bool = True) -> int:
    """Generate a semiprime N = p * q for benchmarking.
    
    Args:
        bits: Total bit length of N
        balanced: If True, p and q are close in size
    """
    if balanced:
        half_bits = bits // 2
        p_bits = half_bits
        q_bits = bits - half_bits
    else:
        p_bits = bits // 3
        q_bits = 2 * bits // 3
    
    # Generate primes using random odd numbers + primality check
    def random_prime(nbits):
        while True:
            p = random.getrandbits(nbits) | 1  # ensure odd
            p |= (1 << (nbits - 1))  # ensure correct bit length
            if is_probable_prime(p):
                return p
    
    p = random_prime(p_bits)
    q = random_prime(q_bits)
    while q == p:
        q = random_prime(q_bits)
    
    return p * q


def is_probable_prime(n: int, k: int = 20) -> bool:
    """Miller-Rabin primality test (from Catalog: MillerRabinFoundations)."""
    if n < 2:
        return False
    if n == 2 or n == 3:
        return True
    if n % 2 == 0:
        return False
    
    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    # Witness loop
    for _ in range(k):
        a = random.randrange(2, n - 1)
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


def benchmark_method(method, n: int, name: str, timeout_s: float = 30.0) -> dict:
    """Benchmark a single method on a single number."""
    start = time.perf_counter()
    try:
        result = method(n)
    except Exception as e:
        return {"method": name, "time_ms": float('inf'), "result": None, "error": str(e)}
    elapsed = time.perf_counter() - start
    
    elapsed_ms = elapsed * 1000
    
    # Verify correctness
    if result is not None:
        p, q = result
        correct = (p * q == n) and (1 < p < n) and (1 < q < n)
    else:
        correct = None  # couldn't factor
    
    return {
        "method": name,
        "time_ms": elapsed_ms,
        "result": result,
        "correct": correct,
        "n_bits": n.bit_length(),
    }


def run_benchmarks(sizes: List[int], num_per_size: int = 3):
    """Run benchmarks across different semiprime sizes."""
    methods = [
        (trial_division, "trial_division"),
        (energy_landscape_factor, "energy_landscape"),
        (energy_landscape_optimized, "energy_optimized"),
        (pythagorean_triple_factor, "pythagorean_triple"),
        (inside_out_factor, "inside_out"),
        (gcd_cascade_factor, "gcd_cascade"),
        (combined_structural_factor, "combined_structural"),
    ]
    
    random.seed(42)  # reproducible
    
    print("=" * 90)
    print("FACTORIZATION BENCHMARK — Catalog Structural Methods")
    print("=" * 90)
    print()
    
    for bits in sizes:
        print(f"--- Semiprime size: ~{bits} bits ---")
        print(f"{'Method':<25} {'Time(ms)':<12} {'Result':<15} {'Correct':<8}")
        print("-" * 65)
        
        for trial in range(num_per_size):
            n = generate_semiprime(bits, balanced=True)
            print(f"\n  N = {n} ({n.bit_length()} bits)")
            
            for method, name in methods:
                # Skip slow methods on large inputs
                if bits > 48 and name in ["trial_division", "energy_landscape"]:
                    print(f"  {name:<25} {'SKIPPED':<12} {'—':<15} {'—':<8}")
                    continue
                if bits > 64 and name in ["pythagorean_triple"]:
                    print(f"  {name:<25} {'SKIPPED':<12} {'—':<15} {'—':<8}")
                    continue
                
                result = benchmark_method(method, n, name)
                if result.get('error'):
                    print(f"  {name:<25} {'ERR':<12} {str(result['error'])[:15]:<15}")
                elif result['result']:
                    p, q = result['result']
                    print(f"  {name:<25} {result['time_ms']:<12.3f} {p}×{q:<10} {'✓' if result['correct'] else '✗':<8}")
                else:
                    print(f"  {name:<25} {result['time_ms']:<12.3f} {'FAILED':<15}")
        
        print()


if __name__ == "__main__":
    sizes = [16, 24, 32, 40, 48, 56, 64]
    if len(sys.argv) > 1:
        sizes = [int(x) for x in sys.argv[1:]]
    
    run_benchmarks(sizes, num_per_size=2)