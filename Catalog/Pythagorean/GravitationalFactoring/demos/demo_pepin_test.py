#!/usr/bin/env python3
"""
Pépin's Test & Fermat Primality Explorer — Interactive Demo

Explores Pépin's primality test for Fermat numbers:
  F_n is prime ⟺ 3^((F_n - 1)/2) ≡ -1 (mod F_n)

Also covers:
  - The power-of-2 characterization: 2^n+1 prime ⟹ n = 2^k
  - Fermat number factorizations
  - Euler's factorization of F_5

Based on theorems formally verified in Lean 4 (v15-v16).
"""

def fermat(n):
    return (1 << (1 << n)) + 1

def is_prime_naive(n):
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


def pepin_test(n):
    """Apply Pépin's test to F_n. Returns (result, 3^((F_n-1)/2) mod F_n)."""
    fn = fermat(n)
    exponent = (fn - 1) // 2
    result = pow(3, exponent, fn)
    return result == fn - 1, result


def factorize_small(n, limit=10**7):
    """Factorize n using trial division up to limit."""
    factors = []
    d = 2
    while d * d <= n and d <= limit:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def main():
    print("=" * 70)
    print("  PÉPIN'S TEST & FERMAT PRIMALITY EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    # 1. Pépin's test for F_0 through F_8
    print(f"\n📊 Pépin's Test: F_n prime ⟺ 3^((F_n-1)/2) ≡ -1 (mod F_n)")
    print("-" * 60)
    print(f"  Note: Pépin's test applies for n ≥ 1.")
    print(f"  For n = 0, F_0 = 3 is trivially prime.\n")

    for n in range(9):
        fn = fermat(n)
        digits = len(str(fn))
        if n == 0:
            print(f"  F_{n} = {fn} — PRIME (trivial) ✓")
            continue

        if digits <= 15:
            is_pepin, residue = pepin_test(n)
            prime_status = "PRIME" if is_pepin else "COMPOSITE"
            print(f"  F_{n} = {fn:>12} — Pépin: 3^{(fn-1)//2} mod {fn} = {residue}"
                  f" {'= F_n - 1 ✓' if is_pepin else '≠ F_n - 1 ✗'} → {prime_status}")
        else:
            try:
                is_pepin, residue = pepin_test(n)
                prime_status = "PRIME" if is_pepin else "COMPOSITE"
                print(f"  F_{n} ({digits} digits) — Pépin: {'PASS ✓' if is_pepin else 'FAIL ✗'}"
                      f" → {prime_status}")
            except Exception as e:
                print(f"  F_{n} ({digits} digits) — computation too large")

    # 2. Pépin's test verified in Lean
    print(f"\n📐 Lean 4 Verification (v16):")
    print("-" * 60)
    print(f"  pepin_test_F1: 3^2 mod 5 = 4 = 5-1       ✓ (formally proved)")
    print(f"  pepin_test_F2: 3^8 mod 17 = 16 = 17-1     ✓ (formally proved)")
    print(f"  pepin_test_F3: 3^128 mod 257 = 256 = 257-1 ✓ (formally proved)")
    print(f"  pepin_test_F4: 3^32768 mod 65537 = 65536   ✓ (formally proved)")

    # 3. Power-of-2 characterization
    print(f"\n⚡ Power-of-2 Characterization (proved in v15):")
    print("  If 2^n + 1 is prime and n > 0, then n = 2^k.")
    print("-" * 60)
    print(f"\n  Proof sketch:")
    print(f"  If n has an odd factor d > 1, write n = d·m.")
    print(f"  Then x^d + 1 = (x+1)(x^(d-1) - x^(d-2) + ... + 1) for odd d.")
    print(f"  So (2^m + 1) | (2^n + 1) = (2^m)^d + 1.")
    print(f"  Since 1 < 2^m + 1 < 2^n + 1, this gives a nontrivial factor. ✗")
    print(f"\n  Consequence: Fermat primes must have the form F_k = 2^(2^k) + 1.")

    # 4. Known Fermat primes
    print(f"\n🌟 Known Fermat Primes:")
    print("-" * 60)
    fermat_primes = [(0, 3), (1, 5), (2, 17), (3, 257), (4, 65537)]
    for k, fn in fermat_primes:
        print(f"  F_{k} = 2^(2^{k}) + 1 = {fn} — PRIME ✓")
    print(f"\n  No other Fermat primes are known!")
    print(f"  F_5 through F_32 have all been shown composite.")
    print(f"  It is an open question whether there are finitely many Fermat primes.")

    # 5. F_5 factorization (Euler's discovery)
    print(f"\n🔍 Euler's Factorization of F_5:")
    print("-" * 60)
    f5 = fermat(5)
    print(f"  F_5 = 2^32 + 1 = {f5}")
    print(f"  = 641 × 6700417")
    print(f"  Verification: 641 × 6700417 = {641 * 6700417} {'✓' if 641 * 6700417 == f5 else '✗'}")
    print(f"\n  Divisor form k·2^(n+2) + 1:")
    print(f"    641 = 5·128 + 1 = 5·2^7 + 1  (k=5, n+2=7) ✓")
    print(f"    6700417 = 52347·128 + 1 = 52347·2^7 + 1  (k=52347, n+2=7) ✓")

    # 6. Fermat number growth
    print(f"\n📈 Fermat Number Growth (doubly exponential):")
    print("-" * 60)
    for n in range(13):
        fn = fermat(n)
        digits = len(str(fn))
        bits = fn.bit_length()
        print(f"  F_{n:>2}: {bits:>12} bits, {digits:>12} digits")

    print(f"\n  F_n has 2^n + 1 bits — doubly exponential growth!")
    print(f"  Testing F_33 requires working with numbers of ~8.6 billion digits.")


if __name__ == "__main__":
    main()
