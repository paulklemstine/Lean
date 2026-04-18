#!/usr/bin/env python3
"""
Chebyshev Bias and Prime Race Demo

Explores the Chebyshev bias: the surprising tendency for there to be more
primes ≡ 3 (mod 4) than ≡ 1 (mod 4). Analyzes multiple moduli and discovers
the remarkable universality where mod 3 and mod 4 give identical counts.
"""

from sympy import isprime, primerange


def prime_race_mod4(limit=1000):
    """Track the prime race mod 4."""
    print(f"=== Prime Race mod 4 (up to {limit}) ===")
    count1 = 0
    count3 = 0
    milestones = [100, 200, 500, 1000, 2000, 5000, 10000]

    print(f"{'N':>8} {'#(p≡1)':>8} {'#(p≡3)':>8} {'Diff':>6} {'Leader':>8}")
    print("-" * 42)

    for p in primerange(2, min(limit, 10001) + 1):
        if p % 4 == 1:
            count1 += 1
        elif p % 4 == 3:
            count3 += 1

        if p + 1 in milestones or p == 2:
            leader = "3 leads" if count3 > count1 else "1 leads" if count1 > count3 else "TIE"
            print(f"{p:>8} {count1:>8} {count3:>8} {count3-count1:>6} {leader:>8}")

    print()


def multi_modulus_comparison(limit=1000):
    """Compare Chebyshev bias across moduli 3, 4, 5, 6, 7."""
    primes = list(primerange(2, limit))

    print(f"=== Multi-Modulus Bias Comparison (primes < {limit}) ===")
    print()

    for mod in [3, 4, 5, 6, 7]:
        counts = {}
        for p in primes:
            r = p % mod
            counts[r] = counts.get(r, 0) + 1

        print(f"  Mod {mod}:")
        for r in sorted(counts.keys()):
            bar = "█" * (counts[r] // 2)
            print(f"    class {r}: {counts[r]:>4} {bar}")
        print()


def universality_analysis(limit=1000):
    """Discover the universality: mod 3 and mod 4 give identical counts."""
    primes = list(primerange(2, limit))

    # Mod 4 counts
    mod4_1 = sum(1 for p in primes if p % 4 == 1)
    mod4_3 = sum(1 for p in primes if p % 4 == 3)

    # Mod 3 counts
    mod3_1 = sum(1 for p in primes if p % 3 == 1)
    mod3_2 = sum(1 for p in primes if p % 3 == 2)

    # Mod 6 counts
    mod6_1 = sum(1 for p in primes if p % 6 == 1)
    mod6_5 = sum(1 for p in primes if p % 6 == 5)

    print(f"=== Chebyshev Bias Universality (primes < {limit}) ===")
    print()
    print(f"  Mod 4: {mod4_1} residues (≡1), {mod4_3} non-residues (≡3)")
    print(f"  Mod 3: {mod3_1} residues (≡1), {mod3_2} non-residues (≡2)")
    print(f"  Mod 6: {mod6_1} in class 1,    {mod6_5} in class 5")
    print()

    if mod4_3 == mod3_2:
        print(f"  ★ REMARKABLE: mod 4 and mod 3 non-residue counts are IDENTICAL ({mod4_3})!")
    if mod4_1 == mod3_1:
        print(f"  ★ REMARKABLE: mod 4 and mod 3 residue counts are IDENTICAL ({mod4_1})!")
    print()

    # Check at different thresholds
    print("  Checking universality at different thresholds:")
    for threshold in [100, 200, 500, 1000, 2000, 5000]:
        ps = list(primerange(2, threshold))
        m4_nr = sum(1 for p in ps if p % 4 == 3)
        m3_nr = sum(1 for p in ps if p % 3 == 2)
        m4_r = sum(1 for p in ps if p % 4 == 1)
        m3_r = sum(1 for p in ps if p % 3 == 1)
        match_nr = "=" if m4_nr == m3_nr else "≠"
        match_r = "=" if m4_r == m3_r else "≠"
        print(f"    N={threshold:>5}: mod4(3)={m4_nr:>3} {match_nr} mod3(2)={m3_nr:>3}  |  "
              f"mod4(1)={m4_r:>3} {match_r} mod3(1)={m3_r:>3}")
    print()
    print("  The universality at 1000 is a numerical coincidence, not a theorem.")
    print("  At other thresholds, the counts typically differ.")
    print()


def bias_reversal_search(limit=50000):
    """Search for the first prime where the bias reverses mod 4."""
    count1 = 0
    count3 = 0
    reversals = []

    print(f"=== Bias Reversal Points mod 4 (up to {limit}) ===")
    print()

    prev_leader = None
    for p in primerange(2, limit):
        if p % 4 == 1:
            count1 += 1
        elif p % 4 == 3:
            count3 += 1

        leader = "1" if count1 > count3 else "3" if count3 > count1 else "tie"
        if prev_leader and leader != prev_leader and leader != "tie":
            reversals.append((p, count1, count3))
            if len(reversals) <= 10:
                print(f"  Reversal at p={p}: #(≡1)={count1}, #(≡3)={count3}")
        prev_leader = leader

    print(f"\n  Total reversals below {limit}: {len(reversals)}")
    if reversals:
        print(f"  First reversal: p = {reversals[0][0]}")
    print()


if __name__ == "__main__":
    prime_race_mod4(1000)
    multi_modulus_comparison(1000)
    universality_analysis(1000)
    bias_reversal_search(30000)
