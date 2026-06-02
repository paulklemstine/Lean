#!/usr/bin/env python3
"""
Prime Gap Crossword: Demonstration Script

Demonstrates the key results from the prime gap crossword analysis:
1. Prime residue classes and gap constraints
2. Sieve-based admissibility
3. Forcing patterns
4. Conditional gap probabilities
"""

from algorithms import (
    primes_up_to, prime_gaps, admissible_residues, admissible_next_gaps,
    is_forcing, find_forcing_patterns, gap_pattern_statistics,
    conditional_gap_probabilities, forcing_fraction, is_prime
)


def demo_prime_residues():
    """Demonstrate prime residue classes mod 6 and mod 30."""
    print("=" * 60)
    print("DEMO 1: Prime Residue Classes")
    print("=" * 60)

    primes = primes_up_to(100)
    print(f"\nPrimes up to 100: {primes}")

    print("\nPrimes > 3 mod 6:")
    for p in primes:
        if p > 3:
            print(f"  {p} ≡ {p % 6} (mod 6)", end="")
            if p % 6 not in [1, 5]:
                print(" *** VIOLATION ***")
            else:
                print()

    print("\nPrimes > 5 mod 30:")
    valid_residues = {1, 7, 11, 13, 17, 19, 23, 29}
    for p in primes:
        if p > 5:
            r = p % 30
            assert r in valid_residues, f"{p} mod 30 = {r} not in valid set!"
    print(f"  All primes > 5 have residue mod 30 in {sorted(valid_residues)} ✓")


def demo_twin_prime_residue():
    """Demonstrate that twin primes > 3 satisfy p ≡ 5 (mod 6)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Twin Prime Residue Constraint")
    print("=" * 60)

    primes = primes_up_to(1000)
    twin_primes = [(p, p + 2) for p in primes if is_prime(p + 2) and p > 3]
    print(f"\nTwin prime pairs (p, p+2) with p > 3 up to 1000:")
    for p, q in twin_primes:
        print(f"  ({p}, {q}): p ≡ {p % 6} (mod 6)")
        assert p % 6 == 5, f"Twin prime {p} not ≡ 5 mod 6!"
    print(f"\n  All {len(twin_primes)} twin prime pairs satisfy p ≡ 5 (mod 6) ✓")


def demo_sieve_admissibility():
    """Demonstrate sieve-based admissibility analysis."""
    print("\n" + "=" * 60)
    print("DEMO 3: Sieve Admissibility Analysis")
    print("=" * 60)

    S = {2, 3}
    M = 6  # primorial of {2,3}

    print(f"\nSieve S = {S}, primorial M = {M}")

    # Test various gap words
    test_words = [[2], [4], [6], [2, 4], [4, 2], [2, 4, 2], [6, 4, 2]]
    for w in test_words:
        residues = admissible_residues(S, w, M)
        print(f"\n  Gap word {w}:")
        print(f"    Admissible residues mod {M}: {residues}")
        print(f"    Count: {len(residues)}")


def demo_forcing_patterns():
    """Demonstrate forcing pattern detection."""
    print("\n" + "=" * 60)
    print("DEMO 4: Forcing Patterns")
    print("=" * 60)

    S = {2, 3}
    B = 6
    M = 6

    print(f"\nSieve S = {S}, gap bound B = {B}")

    # Check specific patterns
    test_words = [[2], [4], [6], [2, 4], [4, 2], [2, 4, 2]]
    for w in test_words:
        forced, g = is_forcing(S, w, B, M)
        next_gaps = admissible_next_gaps(S, w, B, M)
        if forced:
            print(f"\n  Word {w}: FORCING → next gap = {g}")
        else:
            print(f"\n  Word {w}: not forcing, admissible next gaps = {next_gaps}")

    print(f"\n  Finding all forcing patterns up to length 3...")
    patterns = find_forcing_patterns(S, B, 3, M)
    print(f"  Found {len(patterns)} forcing patterns:")
    for w, g in patterns[:20]:
        print(f"    {w} → {g}")


def demo_gap_statistics():
    """Demonstrate gap pattern statistics."""
    print("\n" + "=" * 60)
    print("DEMO 5: Gap Pattern Statistics")
    print("=" * 60)

    limit = 100000
    print(f"\nPrime gap patterns up to {limit}:")

    # Gap frequency
    gaps = prime_gaps(limit)
    gap_counts = {}
    for g in gaps:
        gap_counts[g] = gap_counts.get(g, 0) + 1

    print("\n  Gap frequency distribution:")
    for g in sorted(gap_counts.keys())[:15]:
        bar = "█" * (gap_counts[g] // 20)
        print(f"    gap {g:3d}: {gap_counts[g]:5d} {bar}")

    # Consecutive gap sum ≥ 4
    violations = 0
    for i in range(1, len(gaps) - 1):  # skip gap at index 0 (gap=1 between 2,3)
        if gaps[i] + gaps[i + 1] < 4:
            violations += 1
    print(f"\n  Consecutive gap sum < 4 violations (after gap 1): {violations}")


def demo_conditional_probabilities():
    """Demonstrate conditional gap probabilities."""
    print("\n" + "=" * 60)
    print("DEMO 6: Conditional Gap Probabilities")
    print("=" * 60)

    limit = 1000000
    print(f"\nConditional P(next gap | previous gap) up to {limit}:")

    probs = conditional_gap_probabilities(limit, context_length=1)
    for context in sorted(probs.keys())[:8]:
        print(f"\n  After gap {context[0]}:")
        for g, p in sorted(probs[context].items())[:5]:
            bar = "▓" * int(p * 40)
            print(f"    P(next={g:3d}) = {p:.4f} {bar}")


def demo_forcing_density():
    """Demonstrate forcing fraction computation."""
    print("\n" + "=" * 60)
    print("DEMO 7: Forcing Density")
    print("=" * 60)

    S = {2, 3}
    B = 6

    for length in range(1, 5):
        frac = forcing_fraction(S, B, length)
        print(f"\n  Sieve {S}, B={B}, max_length={length}: "
              f"forcing fraction = {frac:.4f}")


if __name__ == "__main__":
    demo_prime_residues()
    demo_twin_prime_residue()
    demo_sieve_admissibility()
    demo_forcing_patterns()
    demo_gap_statistics()
    demo_conditional_probabilities()
    demo_forcing_density()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: Forcing Patterns and Automaton States
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from functools import reduce


def admissible_at(S, gaps, a):
    positions = [0]
    for g in gaps:
        positions.append(positions[-1] + g)
    interior = set()
    for i in range(len(positions) - 1):
        for j in range(positions[i] + 1, positions[i + 1]):
            interior.add(j)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in interior:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True


def admissible_residues(S, gaps, M):
    return [a for a in range(M) if admissible_at(S, gaps, a)]


def admissible_next_gaps(S, w, B, M):
    return [g for g in range(1, B + 1)
            if len(admissible_residues(S, w + [g], M)) > 0]


def main():
    S = {2, 3}
    M = 6
    B = 6

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Admissible residue count as words grow
    ax = axes[0]
    words_to_check = [
        [], [2], [4], [6],
        [2, 4], [4, 2], [6, 2],
        [2, 4, 2], [4, 2, 4], [6, 2, 6],
    ]
    labels = [str(w) if w else '[]' for w in words_to_check]
    counts = [len(admissible_residues(S, w, M)) for w in words_to_check]
    colors = ['green' if c == 1 else 'steelblue' if c > 0 else 'red' for c in counts]
    ax.barh(range(len(labels)), counts, color=colors, alpha=0.8)
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.set_xlabel('# Admissible Residues mod 6')
    ax.set_title('Admissible Residue Count\n(green = forcing)')

    # Plot 2: Next-gap branching factor
    ax = axes[1]
    test_words = [
        [2], [4], [6],
        [2, 4], [4, 2], [6, 2], [2, 6],
        [2, 4, 2], [4, 2, 4],
    ]
    labels2 = [str(w) for w in test_words]
    branch_factors = [len(admissible_next_gaps(S, w, B, M)) for w in test_words]
    colors2 = ['green' if b == 1 else 'orange' if b == 2 else 'red' for b in branch_factors]
    ax.barh(range(len(labels2)), branch_factors, color=colors2, alpha=0.8)
    ax.set_yticks(range(len(labels2)))
    ax.set_yticklabels(labels2, fontsize=8)
    ax.set_xlabel('# Admissible Next Gaps')
    ax.set_title('Branching Factor\n(green = forcing, 1 choice)')

    # Plot 3: Gap automaton state diagram for {2,3} sieve
    ax = axes[2]
    # States are residues mod 6: {1, 5} are valid start states
    # Draw transitions
    valid_states = [1, 5]
    gap_values = [2, 4, 6]

    ax.set_xlim(-2, 4)
    ax.set_ylim(-2, 4)

    # Draw states
    for i, s in enumerate(valid_states):
        circle = plt.Circle((i * 2.5, 1.5), 0.5, fill=False,
                           edgecolor='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(i * 2.5, 1.5, str(s), ha='center', va='center', fontsize=16)

    # Draw transitions
    transitions = {
        (1, 2): 5, (1, 4): 1, (1, 6): 5,  # wait, (1+2)%6=3, not valid
        (5, 2): 1, (5, 4): 5, (5, 6): 1,  # wait, (5+2)%6=1, valid
    }
    # Actually: from state r, gap g leads to (r+g)%6 if it's in {1,5}
    actual_transitions = {}
    for r in valid_states:
        for g in gap_values:
            target = (r + g) % 6
            if target in valid_states:
                actual_transitions[(r, g)] = target

    ax.text(1.25, -0.5, 'Gap Automaton States\nmod 6, sieve {2,3}',
            ha='center', va='center', fontsize=10)

    for (r, g), t in actual_transitions.items():
        r_idx = valid_states.index(r)
        t_idx = valid_states.index(t)
        if r_idx == t_idx:
            # Self-loop
            ax.annotate('', xy=(r_idx * 2.5, 2.1), xytext=(r_idx * 2.5 + 0.3, 2.5),
                       arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
            ax.text(r_idx * 2.5, 2.7, f'g={g}', ha='center', fontsize=8, color='blue')
        else:
            offset = 0.15 * (gap_values.index(g) - 1)
            ax.annotate('', xy=(t_idx * 2.5 - 0.5, 1.5 + offset),
                       xytext=(r_idx * 2.5 + 0.5, 1.5 + offset),
                       arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
            mid_x = (r_idx + t_idx) * 2.5 / 2
            ax.text(mid_x, 1.5 + offset + 0.25, f'g={g}', ha='center',
                   fontsize=8, color='blue')

    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Gap Automaton\nValid: 1↔5 mod 6')

    plt.tight_layout()
    plt.savefig('forcing_patterns.png', dpi=150, bbox_inches='tight')
    print("Saved: forcing_patterns.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Prime Gap Distribution and Residue Analysis
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n):
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def main():
    limit = 100000
    primes = primes_up_to(limit)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Gap distribution
    ax = axes[0, 0]
    gap_vals = sorted(set(gaps))[:20]
    counts = [gaps.count(g) for g in gap_vals]
    ax.bar(gap_vals, counts, color='steelblue', alpha=0.8)
    ax.set_xlabel('Gap size')
    ax.set_ylabel('Frequency')
    ax.set_title(f'Prime Gap Distribution (primes up to {limit})')

    # Plot 2: Gap vs prime index
    ax = axes[0, 1]
    indices = range(len(gaps))
    ax.scatter(indices, gaps, s=0.5, alpha=0.3, c='darkblue')
    ax.set_xlabel('Prime index')
    ax.set_ylabel('Gap size')
    ax.set_title('Prime Gaps vs Index')

    # Plot 3: Gaps mod 6
    ax = axes[1, 0]
    gaps_gt3 = [g for g, p in zip(gaps[1:], primes[1:]) if p > 3]
    mod6_counts = [0] * 6
    for g in gaps_gt3:
        mod6_counts[g % 6] += 1
    ax.bar(range(6), mod6_counts, color=['crimson' if i % 2 == 1 else 'steelblue' for i in range(6)])
    ax.set_xlabel('Gap mod 6')
    ax.set_ylabel('Frequency')
    ax.set_title('Prime Gaps mod 6 (for primes > 3)')
    ax.set_xticks(range(6))

    # Plot 4: Consecutive gap pairs
    ax = axes[1, 1]
    if len(gaps) > 1:
        x = gaps[1:-1]
        y = gaps[2:]
        ax.scatter(x, y, s=1, alpha=0.2, c='darkgreen')
        ax.set_xlabel('Gap g(n)')
        ax.set_ylabel('Gap g(n+1)')
        ax.set_title('Consecutive Gap Pairs')
        ax.axhline(y=2, color='red', linestyle='--', alpha=0.3)
        ax.axvline(x=2, color='red', linestyle='--', alpha=0.3)

    plt.tight_layout()
    plt.savefig('prime_gap_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: prime_gap_analysis.png")


if __name__ == "__main__":
    main()
