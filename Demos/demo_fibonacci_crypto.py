#!/usr/bin/env python3
"""
Fibonacci Number Theory & Cryptographic Security Demo

Demonstrates:
- Fibonacci GCD identity: gcd(F(m), F(n)) = F(gcd(m,n))
- Fibonacci compositeness test
- ECDSA signature verification
- Nonce reuse vulnerability
"""

import math
from functools import lru_cache

# ─── Fibonacci Functions ────────────────────────────────────────
@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """Fibonacci number F(n)"""
    if n <= 0: return 0
    if n == 1: return 1
    return fib(n-1) + fib(n-2)

def gcd(a: int, b: int) -> int:
    """Greatest common divisor"""
    while b:
        a, b = b, a % b
    return a

def is_prime(n: int) -> bool:
    """Simple primality test"""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

# ─── Demo 1: Fibonacci GCD Identity ────────────────────────────
print("=" * 60)
print("Demo 1: gcd(F(m), F(n)) = F(gcd(m,n))")
print("  (Formally verified as fib_gcd_identity)")
print("=" * 60)
print(f"{'m':>4} {'n':>4} {'gcd(m,n)':>8} {'F(m)':>10} {'F(n)':>10} {'gcd(F(m),F(n))':>16} {'F(gcd)':>10} {'match':>6}")
print("-" * 70)
for m in [6, 8, 10, 12, 15, 20, 21, 24, 30]:
    for n in [4, 9, 14, 18, 25]:
        g = gcd(m, n)
        fm, fn, fg = fib(m), fib(n), fib(g)
        gcd_fibs = gcd(fm, fn)
        match = gcd_fibs == fg
        print(f"{m:>4} {n:>4} {g:>8} {fm:>10} {fn:>10} {gcd_fibs:>16} {fg:>10} {'✓' if match else '✗':>6}")

# ─── Demo 2: Fibonacci Divisibility ────────────────────────────
print("\n" + "=" * 60)
print("Demo 2: m | n ⟹ F(m) | F(n)")
print("  (Formally verified as fib_dvd_chain)")
print("=" * 60)
print(f"{'m':>4} {'n':>4} {'m|n':>5} {'F(m)':>10} {'F(n)':>10} {'F(m)|F(n)':>10}")
print("-" * 45)
for m in [3, 4, 5, 6, 7]:
    for k in [2, 3, 4, 5]:
        n = m * k
        fm, fn = fib(m), fib(n)
        divides = fn % fm == 0
        print(f"{m:>4} {n:>4} {'yes':>5} {fm:>10} {fn:>10} {'✓' if divides else '✗':>10}")

# ─── Demo 3: Fibonacci Bounds ──────────────────────────────────
print("\n" + "=" * 60)
print("Demo 3: Fibonacci Bounds")
print("  n ≤ F(n) for n ≥ 6  (fib_linear_lower)")
print("  F(n) ≤ 2^n           (fib_exp_bound)")
print("=" * 60)
print(f"{'n':>4} {'F(n)':>12} {'n ≤ F(n)':>10} {'F(n) ≤ 2^n':>14} {'2^n':>12}")
print("-" * 54)
for n in range(1, 25):
    fn = fib(n)
    pow2 = 2**n
    lower = "✓" if n <= fn else ("n/a" if n < 6 else "✗")
    upper = "✓" if fn <= pow2 else "✗"
    print(f"{n:>4} {fn:>12} {lower:>10} {upper:>14} {pow2:>12}")

# ─── Demo 4: Fibonacci Compositeness Test ──────────────────────
print("\n" + "=" * 60)
print("Demo 4: Fibonacci Compositeness Test")
print("  If F(n)² mod n ≠ 1 mod n and n ∉ {2,5}, then n is composite")
print("  (Formally verified as fib_composite_test)")
print("=" * 60)
print(f"{'n':>4} {'F(n)':>10} {'F(n)² mod n':>14} {'1 mod n':>8} {'prime?':>8} {'test result':>14}")
print("-" * 62)
for n in range(3, 40):
    if n == 5:
        continue
    fn = fib(n)
    fib_sq_mod = (fn * fn) % n
    one_mod = 1 % n
    prime = is_prime(n)
    if fib_sq_mod != one_mod:
        test = "composite ✓" if not prime else "false alarm"
    else:
        test = "passes" if prime else "pseudoprime!"
    print(f"{n:>4} {fn:>10} {fib_sq_mod:>14} {one_mod:>8} {'yes' if prime else 'no':>8} {test:>14}")

# ─── Demo 5: Pisano Periods ────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 5: Pisano Periods π(n)")
print("  Period of Fibonacci sequence mod n")
print("=" * 60)

def pisano_period(n: int) -> int:
    """Compute the Pisano period π(n)"""
    if n == 1: return 1
    prev, curr = 0, 1
    for i in range(1, 6 * n + 1):
        prev, curr = curr, (prev + curr) % n
        if prev == 0 and curr == 1:
            return i
    return -1

print(f"{'n':>4} {'π(n)':>6} {'F(0..π(n)-1) mod n'}")
print("-" * 60)
for n in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 100]:
    period = pisano_period(n)
    seq = [fib(i) % n for i in range(min(period, 20))]
    seq_str = str(seq) if period <= 20 else str(seq) + "..."
    print(f"{n:>4} {period:>6} {seq_str}")

# ─── Demo 6: ECDSA Simulation ──────────────────────────────────
print("\n" + "=" * 60)
print("Demo 6: ECDSA Signature Verification")
print("  (Formally verified: ecdsa_completeness, ecdsa_nonce_reuse)")
print("=" * 60)

# Simplified ECDSA over a small prime field (for demonstration)
p = 23  # Small prime for demo
n = 29  # Group order (simplified)

def mod_inv(a, m):
    """Modular inverse via extended Euclidean algorithm"""
    g, x, _ = extended_gcd(a % m, m)
    if g != 1:
        return None
    return x % m

def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x

# Key generation
d = 7  # Private key
# Public key Q = d·G (simplified as d itself for demo)
Q = d

# Signing
def ecdsa_sign(z, d, k, n):
    """ECDSA signing: s = k⁻¹(z + r·d) mod n"""
    r = k % n  # Simplified: R = k·G, r = x-coordinate mod n
    if r == 0: return None
    k_inv = mod_inv(k, n)
    if k_inv is None: return None
    s = (k_inv * (z + r * d)) % n
    if s == 0: return None
    return (r, s)

# Verification
def ecdsa_verify(z, r, s, Q, n):
    """ECDSA verification"""
    s_inv = mod_inv(s, n)
    if s_inv is None: return False
    u1 = (z * s_inv) % n
    u2 = (r * s_inv) % n
    # Simplified verification: check r ≡ u1 + u2·Q mod n
    R = (u1 + u2 * Q) % n
    return R == r

print("\nKey generation:")
print(f"  Private key d = {d}")
print(f"  Public key Q = {Q}")
print(f"  Group order n = {n}")

# Sign a message
z = 15  # Message hash
k = 11  # Random nonce
sig = ecdsa_sign(z, d, k, n)
print(f"\nSigning message z = {z} with nonce k = {k}:")
print(f"  Signature (r, s) = {sig}")

# Verify
if sig:
    r, s = sig
    valid = ecdsa_verify(z, r, s, Q, n)
    print(f"  Verification: {'✓ valid' if valid else '✗ invalid'}")
    print(f"  (Formally verified: valid signatures always verify)")

# Nonce reuse attack
print("\n--- Nonce Reuse Vulnerability (formally verified) ---")
z1, z2 = 15, 22  # Two different messages
k_shared = 11  # Same nonce (vulnerability!)
sig1 = ecdsa_sign(z1, d, k_shared, n)
sig2 = ecdsa_sign(z2, d, k_shared, n)

if sig1 and sig2:
    r1, s1 = sig1
    r2, s2 = sig2
    print(f"  Message 1: z={z1}, sig=({r1}, {s1})")
    print(f"  Message 2: z={z2}, sig=({r2}, {s2})")
    print(f"  Same r value: {'✓ VULNERABLE' if r1 == r2 else 'different nonces'}")

    if r1 == r2:
        # Recover nonce: k = (z1 - z2) / (s1 - s2) mod n
        k_recovered = ((z1 - z2) * mod_inv((s1 - s2) % n, n)) % n
        # Recover private key: d = r⁻¹(k·s - z) mod n
        d_recovered = (mod_inv(r1, n) * (k_recovered * s1 - z1)) % n
        print(f"  Recovered nonce k = {k_recovered} (actual: {k_shared}) {'✓' if k_recovered == k_shared else '✗'}")
        print(f"  Recovered private key d = {d_recovered} (actual: {d}) {'✓' if d_recovered == d else '✗'}")
        print(f"  ⚠️  Private key EXPOSED by nonce reuse!")

print("\n" + "=" * 60)
print("All Fibonacci and cryptography demos completed!")
print("=" * 60)
