#!/usr/bin/env python3
"""
Prime Mod 6 Structure and Gap-Residue Theorem Demo

Explores the beautiful mod 6 structure of primes and prime pairs:
- All primes > 3 are ≡ 1 or 5 (mod 6)
- Twin primes (gap 2): p ≡ 5 (mod 6)
- Cousin primes (gap 4): p ≡ 1 (mod 6)
- Sexy primes (gap 6): both residues possible
- General gap-residue theorem: gap mod 6 determines the forced residue
"""

from sympy import isprime, primerange


def prime_mod6_structure(limit=1000):
    """Show distribution of primes mod 6."""
    primes = list(primerange(5, limit))
    mod1 = [p for p in primes if p % 6 == 1]
    mod5 = [p for p in primes if p % 6 == 5]

    print(f"=== Primes mod 6 below {limit} ===")
    print(f"  p ≡ 1 (mod 6): {len(mod1)} primes")
    print(f"  p ≡ 5 (mod 6): {len(mod5)} primes")
    print(f"  First few ≡ 1: {mod1[:10]}")
    print(f"  First few ≡ 5: {mod5[:10]}")
    print(f"  Bias: class 5 leads by {len(mod5) - len(mod1)}")
    print()


def twin_cousin_sexy_analysis(limit=1000):
    """Analyze mod 6 residues of twin, cousin, and sexy primes."""
    primes = set(primerange(2, limit + 10))

    twin_pairs = [(p, p + 2) for p in primerange(5, limit) if p + 2 in primes]
    cousin_pairs = [(p, p + 4) for p in primerange(5, limit) if p + 4 in primes]
    sexy_pairs = [(p, p + 6) for p in primerange(5, limit) if p + 6 in primes]

    print(f"=== Twin Primes (gap 2) below {limit} ===")
    twin_residues = [p % 6 for p, _ in twin_pairs]
    print(f"  Count: {len(twin_pairs)}")
    print(f"  p ≡ 1 (mod 6): {twin_residues.count(1)}")
    print(f"  p ≡ 5 (mod 6): {twin_residues.count(5)}")
    print(f"  THEOREM: All have p ≡ 5 (mod 6) ✓" if all(r == 5 for r in twin_residues) else "  UNEXPECTED!")
    print(f"  Examples: {twin_pairs[:5]}")
    print()

    print(f"=== Cousin Primes (gap 4) below {limit} ===")
    cousin_residues = [p % 6 for p, _ in cousin_pairs]
    print(f"  Count: {len(cousin_pairs)}")
    print(f"  p ≡ 1 (mod 6): {cousin_residues.count(1)}")
    print(f"  p ≡ 5 (mod 6): {cousin_residues.count(5)}")
    print(f"  THEOREM: All have p ≡ 1 (mod 6) ✓" if all(r == 1 for r in cousin_residues) else "  UNEXPECTED!")
    print(f"  Examples: {cousin_pairs[:5]}")
    print()

    print(f"=== Sexy Primes (gap 6) below {limit} ===")
    sexy_residues = [p % 6 for p, _ in sexy_pairs]
    print(f"  Count: {len(sexy_pairs)}")
    print(f"  p ≡ 1 (mod 6): {sexy_residues.count(1)}")
    print(f"  p ≡ 5 (mod 6): {sexy_residues.count(5)}")
    print(f"  THEOREM: Both residues possible ✓" if 1 in sexy_residues and 5 in sexy_residues else "  UNEXPECTED!")
    print()


def gap_residue_theorem(limit=10000):
    """Verify the general gap-residue theorem for all even gaps up to 30."""
    primes = set(primerange(2, limit + 50))

    print(f"=== Gap-Residue Theorem (primes > 3 up to {limit}) ===")
    print(f"{'Gap':>5} {'g%6':>4} {'Pred. res':>10} {'#res=1':>7} {'#res=5':>7} {'Verified':>10}")
    print("-" * 55)

    for gap in range(2, 32, 2):
        pairs = [(p, p + gap) for p in primerange(5, limit) if p + gap in primes]
        if not pairs:
            continue
        res1 = sum(1 for p, _ in pairs if p % 6 == 1)
        res5 = sum(1 for p, _ in pairs if p % 6 == 5)

        gmod6 = gap % 6
        if gmod6 == 2:
            predicted = "5 only"
            verified = "✓" if res1 == 0 else "✗"
        elif gmod6 == 4:
            predicted = "1 only"
            verified = "✓" if res5 == 0 else "✗"
        elif gmod6 == 0:
            predicted = "both"
            verified = "✓" if res1 > 0 and res5 > 0 else "~"
        else:
            predicted = "???"
            verified = "?"

        print(f"{gap:>5} {gmod6:>4} {predicted:>10} {res1:>7} {res5:>7} {verified:>10}")

    print()
    print("Pattern: gap ≡ 2 (mod 6) → p ≡ 5 (mod 6)")
    print("         gap ≡ 4 (mod 6) → p ≡ 1 (mod 6)")
    print("         gap ≡ 0 (mod 6) → both possible")
    print()


def complementarity_visualization():
    """Visualize the twin-cousin complementarity."""
    print("=== Twin-Cousin Complementarity ===")
    print()
    print("Prime pairs (p, p+g) with p > 3:")
    print()
    print("  p ≡ 1 (mod 6)    p ≡ 5 (mod 6)")
    print("  ─────────────    ─────────────")
    print("  p+2 ≡ 3 (mod 6)  p+2 ≡ 1 (mod 6)  ← gap 2 (twin)")
    print("  3 | (p+2) ✗       OK ✓")
    print()
    print("  p+4 ≡ 5 (mod 6)  p+4 ≡ 3 (mod 6)  ← gap 4 (cousin)")
    print("  OK ✓               3 | (p+4) ✗")
    print()
    print("  p+6 ≡ 1 (mod 6)  p+6 ≡ 5 (mod 6)  ← gap 6 (sexy)")
    print("  OK ✓               OK ✓")
    print()
    print("The duality: twin primes force residue 5, cousin primes force residue 1.")
    print("They are complementary views of the same mod 6 constraint!")
    print()


if __name__ == "__main__":
    prime_mod6_structure()
    twin_cousin_sexy_analysis()
    gap_residue_theorem()
    complementarity_visualization()
