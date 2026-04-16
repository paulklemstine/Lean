#!/usr/bin/env python3
"""
Cunningham Chain Explorer — Interactive Demo

Explores Cunningham chains of both kinds:
  First kind: p → 2p+1 → 2(2p+1)+1 → ...
  Second kind: p → 2p-1 → 2(2p-1)-1 → ...

Includes mod 3 cycle analysis (formally verified in v15-v16):
  First kind: 0→1, 1→0, 2→2 (mod 3)
  Chains through residue 2 can be long; hitting residue 1 terminates.

Based on theorems formally verified in Lean 4 (v15-v16).
"""

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


def cunningham_chain_first_kind(start):
    """Generate a first-kind Cunningham chain starting at 'start'."""
    chain = []
    p = start
    while is_prime(p):
        chain.append(p)
        p = 2 * p + 1
    return chain


def cunningham_chain_second_kind(start):
    """Generate a second-kind Cunningham chain starting at 'start'."""
    chain = []
    p = start
    while is_prime(p):
        chain.append(p)
        p = 2 * p - 1
    return chain


def main():
    print("=" * 70)
    print("  CUNNINGHAM CHAIN EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    # 1. Mod 3 cycle analysis
    print(f"\n📊 Mod 3 Cycle Analysis (First Kind: p → 2p+1):")
    print("-" * 50)
    for r in range(3):
        next_r = (2 * r + 1) % 3
        print(f"  {r} mod 3 → {next_r} mod 3")
    print(f"\n  Key insight: Residue 2 maps to itself (self-sustaining)")
    print(f"  Residues 0 and 1 alternate → hitting 0 means next is divisible by 3")

    # 2. First-kind chains
    print(f"\n{'='*50}")
    print(f"🔗 FIRST-KIND CUNNINGHAM CHAINS (p → 2p+1)")
    print(f"{'='*50}")

    # Find all chains of length ≥ 3 starting below 10000
    long_chains = []
    for p in range(2, 10000):
        if is_prime(p):
            chain = cunningham_chain_first_kind(p)
            if len(chain) >= 3:
                long_chains.append(chain)

    # Show by length
    max_len = max(len(c) for c in long_chains) if long_chains else 0
    for length in range(max_len, 2, -1):
        chains_of_len = [c for c in long_chains if len(c) == length]
        if chains_of_len:
            print(f"\n  Length {length}: {len(chains_of_len)} chain(s)")
            for chain in chains_of_len[:3]:
                mod3 = [p % 3 for p in chain]
                print(f"    {' → '.join(str(p) for p in chain)}")
                print(f"    mod 3: {' → '.join(str(r) for r in mod3)}")

    # 3. Second-kind chains
    print(f"\n{'='*50}")
    print(f"🔗 SECOND-KIND CUNNINGHAM CHAINS (p → 2p-1)")
    print(f"{'='*50}")

    long_chains_2 = []
    for p in range(2, 10000):
        if is_prime(p):
            chain = cunningham_chain_second_kind(p)
            if len(chain) >= 3:
                long_chains_2.append(chain)

    max_len_2 = max(len(c) for c in long_chains_2) if long_chains_2 else 0
    for length in range(max_len_2, 2, -1):
        chains_of_len = [c for c in long_chains_2 if len(c) == length]
        if chains_of_len:
            print(f"\n  Length {length}: {len(chains_of_len)} chain(s)")
            for chain in chains_of_len[:3]:
                print(f"    {' → '.join(str(p) for p in chain)}")

    # 4. Mod 3 analysis for second kind
    print(f"\n📊 Mod 3 Cycle Analysis (Second Kind: p → 2p-1):")
    print("-" * 50)
    for r in range(3):
        next_r = (2 * r - 1) % 3
        print(f"  {r} mod 3 → {next_r} mod 3")
    print(f"\n  Cycle: 0 → 2 → 0 → 2 → ... (alternating)")
    print(f"  Residue 1 maps to 1 (self-sustaining)")

    # 5. Sophie Germain connection
    print(f"\n{'='*50}")
    print(f"🔗 SOPHIE GERMAIN PRIME CONNECTION")
    print(f"{'='*50}")
    print(f"  Sophie Germain primes are the START of length-2 first-kind chains.")
    print(f"  p > 3 is SG ⟹ p ≡ 2 (mod 3) [Formally proved in v15]")

    sg_primes = []
    for p in range(2, 1000):
        if is_prime(p) and is_prime(2 * p + 1):
            sg_primes.append(p)

    print(f"\n  Sophie Germain primes < 1000: {len(sg_primes)}")
    print(f"  {sg_primes}")
    print(f"\n  Mod 3 residues:")
    for p in sg_primes:
        if p > 3:
            assert p % 3 == 2, f"SG prime {p} is not ≡ 2 (mod 3)!"
    print(f"  All SG primes > 3 are ≡ 2 (mod 3) ✓")

    # 6. Safe prime connection
    print(f"\n  Safe primes (q = 2p+1) > 7 satisfy q ≡ 11 (mod 12):")
    safe_primes = [2 * p + 1 for p in sg_primes if 2 * p + 1 > 7]
    all_mod12 = all(q % 12 == 11 for q in safe_primes)
    print(f"  {safe_primes}")
    print(f"  All ≡ 11 (mod 12): {'✓' if all_mod12 else '✗'}")

    # 7. Statistics
    print(f"\n{'='*50}")
    print(f"📊 CHAIN LENGTH STATISTICS (starting primes < 10000)")
    print(f"{'='*50}")

    first_kind_lengths = {}
    second_kind_lengths = {}
    for p in range(2, 10000):
        if is_prime(p):
            l1 = len(cunningham_chain_first_kind(p))
            l2 = len(cunningham_chain_second_kind(p))
            first_kind_lengths[l1] = first_kind_lengths.get(l1, 0) + 1
            second_kind_lengths[l2] = second_kind_lengths.get(l2, 0) + 1

    print(f"\n  First-kind chain lengths:")
    for l in sorted(first_kind_lengths.keys(), reverse=True):
        if l >= 1:
            print(f"    Length {l}: {first_kind_lengths[l]} chains")

    print(f"\n  Second-kind chain lengths:")
    for l in sorted(second_kind_lengths.keys(), reverse=True):
        if l >= 1:
            print(f"    Length {l}: {second_kind_lengths[l]} chains")


if __name__ == "__main__":
    main()
