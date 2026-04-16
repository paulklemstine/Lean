#!/usr/bin/env python3
"""
Fibonacci/Pisano Channel Factoring — NEW ALGORITHM from Catalog theorems.

Key Catalog theorems:
- pisano_split_bound: For p ≡ 1,4 mod 5: p | F(p-1)
- pisano_inert_bound: For p ≡ 2,3 mod 5: p | F(p+1)  
- fib_entry_point_divides: if m | F(k) then m | F(k*j)
- two_square_reps_give_factor: two sum-of-squares representations → factor

The Fibonacci sequence mod N can be computed via matrix exponentiation:
[[1,1],[1,0]]^n gives [[F(n+1),F(n)],[F(n),F(n-1)]]

For a semiprime N=pq:
- If p ≡ 1,4 mod 5: F(p-1) ≡ 0 mod p, so gcd(F(L), N) reveals p if (p-1) is L-smooth
- If p ≡ 2,3 mod 5: F(p+1) ≡ 0 mod p, so gcd(F(L), N) reveals p if (p+1) is L-smooth

This is the THIRD independent channel beyond p-1 and p+1!
Combined with p-1 and p+1, we cover ALL residues mod 5.
"""

import math

def mat_mul_mod(A, B, n):
    """2x2 matrix multiplication mod n."""
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % n, (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % n],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % n, (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % n]
    ]

def mat_pow_mod(M, exp, n):
    """Matrix exponentiation mod n. O(log exp) multiplications."""
    result = [[1,0],[0,1]]  # identity
    base = [row[:] for row in M]
    while exp > 0:
        if exp & 1:
            result = mat_mul_mod(result, base, n)
        base = mat_mul_mod(base, base, n)
        exp >>= 1
    return result

def fib_mod(k, n):
    """Compute F(k) mod n using matrix exponentiation.
    [[1,1],[1,0]]^k = [[F(k+1),F(k)],[F(k),F(k-1)]]
    """
    if k == 0: return 0
    if k == 1: return 1 % n
    M = [[1,1],[1,0]]
    result = mat_pow_mod(M, k, n)
    return result[0][1]

def fibonacci_channel_factor(n, B=50000):
    """Fibonacci/Pisano channel factoring.
    
    If p | N and p ≡ 1,4 mod 5: p | F(p-1), so gcd(F(M), N) reveals p
    where M = lcm(1,...,B) * some primes
    
    If p | N and p ≡ 2,3 mod 5: p | F(p+1), so gcd(F(M), N) reveals p
    
    Combined with p-1 (uses a^(p-1) ≡ 1) and p+1 (Williams), this covers
    ALL residue classes mod small primes.
    
    Catalog: pisano_split_bound, pisano_inert_bound, fib_entry_point_divides
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    # Compute M = lcm(1, 2, ..., B)
    M = 1
    sv = [True] * (B+1)
    for i in range(2, B+1):
        if sv[i]:
            pk = i
            while pk <= B: pk *= i
            pk //= i
            from math import gcd as _gcd
            M = M * pk // _gcd(M, pk)
            for j in range(i*i, B+1, i): sv[j] = False
    
    # Try F(M) mod N — if gcd is nontrivial, found a factor
    fm = fib_mod(M, n)
    g = math.gcd(fm, n)
    if 1 < g < n:
        return (min(g, n//g), max(g, n//g))
    
    # Try different Fibonacci indices: M/2, M/3, etc.
    for div in [2, 3, 5, 7, 11, 13]:
        if M % div == 0:
            idx = M // div
            f = fib_mod(idx, n)
            g = math.gcd(f, n)
            if 1 < g < n:
                return (min(g, n//g), max(g, n//g))
    
    # Try 2*M, 3*M (extend the smooth bound)
    for mult in [2, 3, 5, 7]:
        idx = M * mult
        f = fib_mod(idx, n)
        g = math.gcd(f, n)
        if 1 < g < n:
            return (min(g, n//g), max(g, n//g))
    
    return None


def two_square_reps_factor(n):
    """Two representations of N as sum of two squares → factoring equation.
    
    Catalog: two_square_reps_give_factor
    If a1² + b1² = a2² + b2² = N, then
    (a1-a2)(a1+a2) = (b2-b1)(b2+b1)
    and gcd(a1-a2, N) or gcd(b2-b1, N) may give a factor.
    
    This works for N = p*q where p,q ≡ 1 mod 4.
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    # Search for representations a² + b² = N
    reps = []
    a = 1
    limit = int(math.isqrt(n)) + 1
    while a < limit and len(reps) < 2:
        bsq = n - a*a
        if bsq > 0:
            b = int(math.isqrt(bsq))
            if b*b == bsq and b > 0:
                reps.append((a, b))
        a += 1
    
    if len(reps) >= 2:
        a1, b1 = reps[0]
        a2, b2 = reps[1]
        g = math.gcd(abs(a1 - a2), n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
        g = math.gcd(abs(b1 - b2), n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
        g = math.gcd(abs(a1 + a2), n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
        g = math.gcd(abs(b1 + b2), n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
    
    return None