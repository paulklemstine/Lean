#!/usr/bin/env python3
"""
Wilson's Theorem & Primality Explorer — Interactive Demo

Demonstrates Wilson's theorem: p is prime ⟺ (p-1)! ≡ -1 (mod p).
Also explores:
  - Wilson quotient W(p) = ((p-1)! + 1) / p
  - Wilson primes (W(p) ≡ 0 (mod p))
  - Comparison with other primality tests

Based on theorems formally verified in Lean 4 (v16).
"""

import math

def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def main():
    print("=" * 70)
    print("  WILSON'S THEOREM & PRIMALITY EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    # 1. Wilson's theorem verification
    print(f"\n📊 Wilson's Theorem: p prime ⟺ (p-1)! ≡ -1 (mod p)")
    print("-" * 60)
    print(f"  {'n':>5} | {'(n-1)! mod n':>15} | {'n-1':>6} | {'Prime?':>7} | {'Wilson?':>8}")
    print(f"  {'-'*5}-+-{'-'*15}-+-{'-'*6}-+-{'-'*7}-+-{'-'*8}")

    for n in range(2, 25):
        fact_mod = math.factorial(n - 1) % n
        is_p = is_prime(n)
        wilson_holds = (fact_mod == n - 1)
        status = "✓" if wilson_holds == is_p else "✗"
        print(f"  {n:>5} | {fact_mod:>15} | {n-1:>6} | {'YES' if is_p else 'no':>7} | {status:>8}")

    # 2. Wilson quotient
    print(f"\n📐 Wilson Quotient W(p) = ((p-1)! + 1) / p:")
    print("-" * 60)
    print(f"  {'p':>5} | {'W(p)':>20} | {'W(p) mod p':>10} | {'Wilson prime?':>13}")

    wilson_primes = []
    for p in range(2, 50):
        if is_prime(p):
            w = (math.factorial(p - 1) + 1) // p
            w_mod_p = w % p
            is_wilson = (w_mod_p == 0)
            if is_wilson:
                wilson_primes.append(p)
            w_str = str(w) if len(str(w)) <= 20 else f"({len(str(w))} digits)"
            print(f"  {p:>5} | {w_str:>20} | {w_mod_p:>10} | {'YES ★' if is_wilson else '':>13}")

    print(f"\n  Wilson primes found: {wilson_primes}")
    print(f"  (Known Wilson primes: 5, 13, 563)")

    # 3. Wilson's theorem as primality test — complexity
    print(f"\n⚡ Wilson's Test vs Trial Division:")
    print("-" * 60)
    print(f"  Wilson's test: compute (n-1)! mod n — O(n) multiplications")
    print(f"  Trial division: check divisors up to √n — O(√n) divisions")
    print(f"  Miller-Rabin: O(k log²n log n) — much faster, probabilistic")
    print(f"\n  Wilson's test is theoretically elegant but computationally expensive!")

    # 4. Composite numbers and Wilson
    print(f"\n📊 What happens for composites?")
    print("-" * 60)
    for n in [4, 6, 8, 9, 10, 12, 15, 21, 25, 100]:
        fact_mod = math.factorial(n - 1) % n
        print(f"  (n-1)! mod n for n = {n:>3}: {fact_mod:>5}"
              f"  {'(= 0 since n is a perfect square or n > 4 composite)' if fact_mod == 0 else ''}")

    print(f"\n  Note: For composite n > 4, (n-1)! ≡ 0 (mod n)")
    print(f"  This is because n's factors all appear in (n-1)!.")
    print(f"  Special case: 4! = 24 ≡ 0 (mod 4), but just barely.")

    # 5. Connection to Korselt and Carmichael
    print(f"\n🔗 Connection to Carmichael Numbers:")
    print("-" * 60)
    print(f"  Carmichael numbers satisfy a^(n-1) ≡ 1 (mod n) for all gcd(a,n)=1")
    print(f"  but NOT (n-1)! ≡ -1 (mod n) (Wilson fails for composites)")
    print(f"\n  Verified Carmichael numbers:")
    carmichaels = [561, 1105, 1729]
    for n in carmichaels:
        fact_mod = math.factorial(n - 1) % n
        # Check Carmichael property for base 2
        fermat_mod = pow(2, n - 1, n)
        print(f"    n = {n}: (n-1)! mod n = {fact_mod} (not {n-1}), "
              f"but 2^(n-1) mod n = {fermat_mod}")


if __name__ == "__main__":
    main()
