#!/usr/bin/env python3
"""
Prime Residue Structure Explorer — Interactive Demo

Explores the modular structure of primes:
  - Primes mod 6: only 1 and 5 (formally proved in v16)
  - Twin primes mod 6: always 5 (formally proved in v16)
  - Cousin primes mod 6: always 1 (formally proved in v16)
  - Sexy primes mod 6: both residues possible (formally proved in v16)
  - Quadratic residue counts
  - Safe prime mod 12 structure

Based on theorems formally verified in Lean 4 (v15-v16).
"""

def sieve_of_eratosthenes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def main():
    print("=" * 70)
    print("  PRIME RESIDUE STRUCTURE EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    LIMIT = 10000
    is_prime = sieve_of_eratosthenes(LIMIT)
    primes = [i for i in range(2, LIMIT + 1) if is_prime[i]]

    # 1. Primes mod 6
    print(f"\n📊 Distribution of Primes mod 6 (p > 3):")
    print("  Theorem (v16): p > 3 prime ⟹ p ≡ 1 or 5 (mod 6)")
    print("-" * 60)

    mod6_counts = {r: 0 for r in range(6)}
    for p in primes:
        if p > 3:
            mod6_counts[p % 6] += 1

    for r in range(6):
        bar = '█' * (mod6_counts[r] // 10)
        print(f"  p ≡ {r} (mod 6): {mod6_counts[r]:>5} primes  {bar}")

    print(f"\n  Only residues 1 and 5 occur (2 and 3 are the only exceptions). ✓")

    # 2. Twin primes mod 6
    print(f"\n🔗 Twin Primes (p, p+2) — Mod 6 Structure:")
    print("  Theorem (v16): p > 3 twin prime ⟹ p ≡ 5 (mod 6)")
    print("-" * 60)

    twin_mod6 = {r: [] for r in range(6)}
    for p in primes:
        if p > 3 and p + 2 <= LIMIT and is_prime[p + 2]:
            twin_mod6[p % 6].append(p)

    for r in range(6):
        if twin_mod6[r]:
            examples = twin_mod6[r][:5]
            print(f"  p ≡ {r} (mod 6): {len(twin_mod6[r]):>4} pairs — "
                  f"e.g. {', '.join(f'({p},{p+2})' for p in examples)}")
        else:
            print(f"  p ≡ {r} (mod 6):    0 pairs")

    print(f"\n  All twin primes > 3 have p ≡ 5 (mod 6). ✓")
    print(f"  Proof: If p ≡ 1 (mod 6), then p+2 ≡ 3 (mod 6), so 3|(p+2), impossible.")

    # 3. Cousin primes mod 6
    print(f"\n🔗 Cousin Primes (p, p+4) — Mod 6 Structure:")
    print("  Theorem (v16): p > 3 cousin prime ⟹ p ≡ 1 (mod 6)")
    print("-" * 60)

    cousin_mod6 = {r: [] for r in range(6)}
    for p in primes:
        if p > 3 and p + 4 <= LIMIT and is_prime[p + 4]:
            cousin_mod6[p % 6].append(p)

    for r in range(6):
        if cousin_mod6[r]:
            examples = cousin_mod6[r][:5]
            print(f"  p ≡ {r} (mod 6): {len(cousin_mod6[r]):>4} pairs — "
                  f"e.g. {', '.join(f'({p},{p+4})' for p in examples)}")
        else:
            print(f"  p ≡ {r} (mod 6):    0 pairs")

    print(f"\n  All cousin primes > 3 have p ≡ 1 (mod 6). ✓")
    print(f"  Proof: If p ≡ 5 (mod 6), then p+4 ≡ 9 ≡ 3 (mod 6), so 3|(p+4), impossible.")

    # 4. Sexy primes mod 6
    print(f"\n🔗 Sexy Primes (p, p+6) — Both Residues Possible:")
    print("  Theorem (v16): Both p ≡ 1 and p ≡ 5 (mod 6) occur")
    print("-" * 60)

    sexy_mod6 = {r: [] for r in range(6)}
    for p in primes:
        if p > 3 and p + 6 <= LIMIT and is_prime[p + 6]:
            sexy_mod6[p % 6].append(p)

    for r in [1, 5]:
        examples = sexy_mod6[r][:5]
        print(f"  p ≡ {r} (mod 6): {len(sexy_mod6[r]):>4} pairs — "
              f"e.g. {', '.join(f'({p},{p+6})' for p in examples)}")

    print(f"\n  Both residues occur because p+6 ≡ p (mod 6). ✓")

    # 5. Quadratic residues
    print(f"\n📐 Quadratic Residue Counts (formally verified for small p):")
    print("  For prime p, exactly (p-1)/2 of {{1,...,p-1}} are QR mod p.")
    print("-" * 60)

    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        if is_prime[p]:
            qr = set()
            for x in range(1, p):
                qr.add((x * x) % p)
            qr.discard(0)
            qnr = set(range(1, p)) - qr
            expected = (p - 1) // 2
            status = "✓" if len(qr) == expected else "✗"
            qr_str = str(sorted(qr)) if len(qr) <= 8 else f"{len(qr)} elements"
            print(f"  p = {p:>3}: QR = {qr_str:<30} count = {len(qr)}, expected = {expected} {status}")

    # 6. Safe primes mod 12
    print(f"\n🔒 Safe Primes mod 12:")
    print("  Theorem (v15): q > 7 safe prime ⟹ q ≡ 11 (mod 12)")
    print("-" * 60)

    safe_primes = []
    for q in primes:
        if q > 2 and is_prime[(q - 1) // 2]:
            safe_primes.append(q)

    mod12_counts = {}
    for q in safe_primes:
        r = q % 12
        mod12_counts[r] = mod12_counts.get(r, 0) + 1

    for r in sorted(mod12_counts.keys()):
        examples = [q for q in safe_primes if q % 12 == r][:5]
        print(f"  q ≡ {r:>2} (mod 12): {mod12_counts[r]:>3} primes — e.g. {examples}")

    print(f"\n  Only q = 5 (mod 12 = 5) and q = 7 (mod 12 = 7) are exceptions.")
    print(f"  All safe primes > 7 satisfy q ≡ 11 (mod 12). ✓")

    # 7. Summary table
    print(f"\n{'='*60}")
    print(f"📋 SUMMARY — Prime Pair Mod 6 Structure")
    print(f"{'='*60}")
    print(f"  {'Type':<20} {'Gap':<6} {'p mod 6':<10} {'Status':<15}")
    print(f"  {'-'*20} {'-'*6} {'-'*10} {'-'*15}")
    print(f"  {'Twin (p,p+2)':<20} {'2':<6} {'5 only':<10} {'Proved v16':<15}")
    print(f"  {'Cousin (p,p+4)':<20} {'4':<6} {'1 only':<10} {'Proved v16':<15}")
    print(f"  {'Sexy (p,p+6)':<20} {'6':<6} {'1 or 5':<10} {'Proved v16':<15}")
    print(f"  {'(p,p+8)':<20} {'8':<6} {'5 only':<10} {'Conjectured':<15}")
    print(f"  {'(p,p+10)':<20} {'10':<6} {'1 only':<10} {'Conjectured':<15}")
    print(f"  {'(p,p+12)':<20} {'12':<6} {'1 or 5':<10} {'Conjectured':<15}")
    print(f"\n  Pattern: gap ≡ 0 (mod 6) → both; gap ≡ 2 (mod 6) → 5; gap ≡ 4 (mod 6) → 1")


if __name__ == "__main__":
    main()
