#!/usr/bin/env python3
"""
Berggren Descent Factoring — from Catalog theorems.

Key Catalog theorems:
- divisor_pair_to_triple: d*e=N² → N²+((e-d)/2)²=((e+d)/2)²
- two_triples_factor: two triples with leg N → factoring equation  
- canonical_prime_triple: for odd p: p²+((p²-1)/2)²=((p²+1)/2)²
- B1_parent_recovery: Berggren tree is INVERTIBLE
- gaussian_composition: product of triples via Gaussian integer multiplication

The Berggren tree generates ALL primitive Pythagorean triples.
Starting from (3,4,5), each node has 3 children from matrices B1, B2, B3.
The tree is invertible — we can go from any child back to its parent.

For factoring N: find two triples with leg N via Berggren descent.
If T1=(N,b1,c1) and T2=(N,b2,c2), then gcd(c1-b1-(c2-b2), N) may give a factor.

This is equivalent to finding two representations of N² as a sum of two squares,
which the Catalog's two_square_reps_give_factor and two_triples_factor formalize.
"""

import math
import gmpy2

def berggren_children(a, b, c):
    """Generate the three children of (a,b,c) in the Berggren tree."""
    # B1
    a1 = a - 2*b + 2*c
    b1 = 2*a - b + 2*c
    c1 = 2*a - 2*b + 3*c
    # B2
    a2 = a + 2*b + 2*c
    b2 = 2*a + b + 2*c
    c2 = 2*a + 2*b + 3*c
    # B3
    a3 = -a + 2*b + 2*c
    b3 = -2*a + b + 2*c
    c3 = -2*a + 2*b + 3*c
    return [(a1,b1,c1), (a2,b2,c2), (a3,b3,c3)]

def berggren_parent(a, b, c, which):
    """Recover parent from child using inverse of Berggren matrix.
    From Catalog: B1_parent_recovery
    """
    if which == 1:
        # Inverse of B1
        pa = a + 2*b - 2*c
        pb = -2*a - b + 2*c
        pc = -2*a - 2*b + 3*c
    elif which == 2:
        # Inverse of B2
        pa = -a + 2*b + 2*c
        pb = -2*a + b + 2*c
        pc = -2*a + 2*b + 3*c
    elif which == 3:
        # Inverse of B3
        pa = a - 2*b + 2*c
        pb = 2*a - b + 2*c
        pc = 2*a - 2*b + 3*c
    else:
        return None
    return (pa, pb, pc)

def find_triple_with_leg(N, max_depth=30):
    """Find a Pythagorean triple with leg N using Berggren descent.
    
    If N is odd: canonical triple is (N, (N²-1)/2, (N²+1)/2)
    If N is even: N/2 is odd, scale triple for N/2
    
    Returns list of (N, b, c) triples with leg N.
    """
    if N < 1: return []
    
    triples = []
    
    if N % 2 == 1:
        # Odd N: use canonical triple
        b = (N*N - 1) // 2
        c = (N*N + 1) // 2
        triples.append((N, b, c))
        
        # Generate more triples via Berggren tree
        # Scale for the Berggren tree uses primitive triples
        stack = [(N, b, c)]
        depth = 0
        while stack and depth < max_depth and len(triples) < 5:
            new_stack = []
            for (a0, b0, c0) in stack:
                for child in berggren_children(a0, b0, c0):
                    ca, cb, cc = child
                    if ca > 0 and cb > 0 and cc > 0:
                        if ca == N or cb == N:
                            triples.append((a0, b0, c0) if ca == N else (cb, ca, cc) if cb == N else child)
                        new_stack.append(child)
            stack = new_stack[:10]  # limit breadth
            depth += 1
    else:
        # Even N: need N/2 method
        half = N // 2
        if half % 2 == 1:
            b = (half*half - 1) // 2
            c = (half*half + 1) // 2
            # Scale: (2*half, 2*b, 2*c) = (N, 2*b, 2*c)
            triples.append((N, 2*b, 2*c))
    
    return triples

def triple_factor(N, max_triples=10):
    """Factor N using two Pythagorean triples with leg N.
    
    Catalog: two_triples_factor
    If T1=(N,b1,c1) and T2=(N,b2,c2), then:
    (c1-b1)(c1+b1) = (c2-b2)(c2+b2) = N²
    
    Since gcd(c1-b1, N) and gcd(c2-b2, N) may differ, checking all combinations
    may reveal a factor.
    """
    if N < 2: return None
    if N % 2 == 0: return (2, N//2)
    
    triples = find_triple_with_leg(N, max_depth=15)
    
    if len(triples) < 2:
        return None
    
    # For each pair of triples, try to extract a factor
    for i in range(len(triples)):
        for j in range(i+1, min(len(triples), max_triples)):
            _, b1, c1 = triples[i]
            _, b2, c2 = triples[j]
            
            if b1 == b2:
                continue
            
            # From two_triples_factor: (c1-b1)(c1+b1) = (c2-b2)(c2+b2) = N²
            # So N² = (c1-b1)(c1+b1)
            # Let d1 = c1-b1, d2 = c2-b2
            # d1 * (2c1-d1) = N² = d2 * (2c2-d2)
            # gcd(d1-d2, N) or gcd(d1+d2, N) may give a factor
            
            d1 = c1 - b1
            d2 = c2 - b2
            
            g = math.gcd(abs(d1 - d2), N)
            if 1 < g < N:
                return (min(g, N//g), max(g, N//g))
            
            g = math.gcd(abs(d1 + d2), N)
            if 1 < g < N:
                return (min(g, N//g), max(g, N//g))
    
    # Direct approach: compute gcd(c-b, N) for each triple
    for _, b, c in triples:
        d = c - b
        g = math.gcd(d, N)
        if 1 < g < N:
            return (min(g, N//g), max(g, N//g))
    
    return None


def gaussian_factor(N, max_attempts=1000):
    """Factor N via Gaussian integer composition.
    
    Catalog: gaussian_composition
    (a₁a₂-b₁b₂)² + (a₁b₂+b₁a₂)² = (c₁c₂)²
    
    If we can reduce N² = a²+b² in two different ways:
    N² = (a+bi)(a-bi), and N² = (c+di)(c-di)
    Then gcd(a±c, N) may give a factor.
    """
    if N < 2: return None
    if N % 2 == 0: return (2, N//2)
    
    # Find representations of N² as sum of two squares
    N2 = N * N
    reps = []
    
    # Method 1: N² + 0² = N²
    # Method 2: Use the canonical triple
    if N % 2 == 1:
        b = (N*N - 1) // 2
        c = (N*N + 1) // 2
        # c² - b² = N², so N² + b² = c²
        # This means c² ≡ b² (mod N), so gcd(c-b, N) or gcd(c+b, N) may factor N
        g = math.gcd(c - b, N)  # This is always gcd(N²-1)/2+something, likely = 1 for semiprimes
        if 1 < g < N:
            return (min(g, N//g), max(g, N//g))
        g = math.gcd(c + b, N)  # c + b = N², so gcd(N², N) = N (trivial)
        # Actually c+b = N², so this is always trivial
    
    # Method 3: Search for small b where N² + b² = c² (i.e., c² - b² = N²)
    # This means (c-b)(c+b) = N², which requires factoring N²
    # Not helpful unless we can find a different representation
    
    # Method 4: Find two DIFFERENT sum-of-two-squares reps of N
    # This only works for primes ≡ 1 mod 4, which are rare for random semiprimes
    
    return None


if __name__ == "__main__":
    import time, random, sys
    sys.path.insert(0, '.')
    import factor_autoresearch as fa
    
    print("=== Berggren Descent Factoring ===\n")
    
    # Test: numbers where we KNOW there are Pythagorean triples
    # Odd numbers always have the canonical triple
    for N in [15, 21, 35, 77, 91, 221]:
        t0 = time.perf_counter()
        r = triple_factor(N)
        t1 = time.perf_counter()
        ms = (t1-t0)*1000
        if r:
            print(f"N={N}: FOUND {r} in {ms:.1f}ms")
        else:
            print(f"N={N}: no factor in {ms:.1f}ms")
    
    print("\n=== Random semiprime test ===\n")
    
    for bits in [40, 56, 64]:
        random.seed(42)
        p = fa.make_prime(bits//2+1)
        q = fa.make_prime(bits-bits//2+1)
        n = p * q
        t0 = time.perf_counter()
        r = triple_factor(n)
        t1 = time.perf_counter()
        ms = (t1-t0)*1000
        if r and r[0]*r[1] == n:
            print(f"{bits}b: FOUND {r} in {ms:.1f}ms")
        else:
            # How many triples did we find?
            triples = find_triple_with_leg(n, 15)
            print(f"{bits}b: FAIL ({len(triples)} triples found) in {ms:.1f}ms")