#!/usr/bin/env python3
"""
Modular Periodicity of the Ghost Matrix M

Explores the order of the ghost matrix M in GL(3, F_p) for various primes p,
and verifies the quadratic residue classification.
"""

import numpy as np
from math import gcd

def matrix_mod(M, p):
    """Reduce matrix entries mod p."""
    return [[x % p for x in row] for row in M]

def mat_mul_mod(A, B, p):
    """Multiply two 3x3 matrices mod p."""
    n = len(A)
    C = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            s = 0
            for k in range(n):
                s += A[i][k] * B[k][j]
            C[i][j] = s % p
    return C

def mat_eq(A, B, p):
    """Check if two matrices are equal mod p."""
    for i in range(len(A)):
        for j in range(len(A)):
            if A[i][j] % p != B[i][j] % p:
                return False
    return True

def identity_mod(p):
    """3x3 identity matrix mod p."""
    return [[1 if i==j else 0 for j in range(3)] for i in range(3)]

def mat_pow_mod(M, n, p):
    """Matrix power mod p using repeated squaring."""
    if n == 0:
        return identity_mod(p)
    result = identity_mod(p)
    base = [row[:] for row in M]
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_mod(result, base, p)
        base = mat_mul_mod(base, base, p)
        n //= 2
    return result

def find_order(M, p):
    """Find the order of M in GL(3, F_p)."""
    I = identity_mod(p)
    M_mod = matrix_mod(M, p)
    power = [row[:] for row in M_mod]
    for k in range(1, p*p*p + 1):
        if mat_eq(power, I, p):
            return k
        power = mat_mul_mod(power, M_mod, p)
    return None

def is_qr(a, p):
    """Check if a is a quadratic residue mod p using Euler's criterion."""
    if a % p == 0:
        return True
    return pow(a, (p-1)//2, p) == 1

# Ghost matrix M = B₂⁻¹
M = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]

print("=" * 70)
print("MODULAR PERIODICITY OF THE GHOST MATRIX")
print("=" * 70)

print("\n--- Order of M in GL(3, F_p) ---\n")
print(f"{'Prime p':>8} {'Order':>8} {'p²−1':>10} {'Divides?':>10} {'32 QR?':>8} {'p mod 8':>8}")
print("-" * 62)

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
results = []

for p in primes:
    order = find_order(M, p)
    p2m1 = p*p - 1
    divides = "✓" if p2m1 % order == 0 else "✗"
    qr32 = "Yes" if is_qr(32, p) else "No"
    pmod8 = p % 8
    print(f"{p:>8} {order:>8} {p2m1:>10} {divides:>10} {qr32:>8} {pmod8:>8}")
    results.append((p, order, p2m1, qr32, pmod8))

print("\n--- Quadratic Residue Classification ---\n")
print("Theory: 32 = 2⁵ is QR mod p iff 2 is QR mod p iff p ≡ ±1 (mod 8)")
print("When QR: eigenvalues in F_p, order divides p−1")
print("When non-QR: eigenvalues in F_{p²}\\F_p, order divides p+1\n")

for p, order, _, qr, pmod8 in results:
    if p == 2:
        continue
    if qr == "Yes":
        divides_pm1 = "✓" if (p-1) % order == 0 else "✗"
        print(f"  p={p}: QR, p≡{pmod8} (mod 8), order={order}, divides p−1={p-1}? {divides_pm1}")
    else:
        divides_pp1 = "✓" if (p+1) % order == 0 else "✗"
        print(f"  p={p}: non-QR, p≡{pmod8} (mod 8), order={order}, divides p+1={p+1}? {divides_pp1}")

print("\n--- Extended Analysis (primes up to 100) ---\n")
extended_primes = [p for p in range(53, 101) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
print(f"{'Prime p':>8} {'Order':>8} {'p²−1':>10} {'32 QR?':>8} {'Classification':>20}")
print("-" * 58)
for p in extended_primes:
    order = find_order(M, p)
    p2m1 = p*p - 1
    qr = "Yes" if is_qr(32, p) else "No"
    if qr == "Yes":
        cls = f"div p-1={p-1}? {'✓' if (p-1)%order==0 else '✗'}"
    else:
        cls = f"div p+1={p+1}? {'✓' if (p+1)%order==0 else '✗'}"
    print(f"{p:>8} {order:>8} {p2m1:>10} {qr:>8} {cls:>20}")

print("\n--- Key Finding ---")
print("The order of M mod p ALWAYS divides p²−1.")
print("The quadratic residue of 32 mod p determines the splitting pattern.")
print("This is consistent with M acting on a 2D eigenspace whose")
print("eigenvalues lie in F_{p²} (or F_p when 32 is a QR mod p).")
