#!/usr/bin/env python3
"""
Prime Gap Automaton — Demonstration

Demonstrates the 2-state mod-6 automaton governing prime gap sequences,
verifying the theoretical predictions against actual prime gap data.
"""

from sympy import isprime, nextprime


def prime_state(p: int) -> int:
    """Return the automaton state: 0 if p ≡ 1 (mod 6), 1 if p ≡ 5 (mod 6)."""
    return 0 if p % 6 == 1 else 1


def verify_mod6_constraint(limit: int = 10000) -> None:
    """Verify that all prime gaps satisfy the mod-6 constraint theorem."""
    p = 5  # Start from first prime > 3
    violations = 0
    total = 0
    state_transitions = {(0, 0): 0, (0, 4): 0, (1, 0): 0, (1, 2): 0}

    while p < limit:
        q = nextprime(p)
        gap = q - p
        state = prime_state(p)
        gap_mod6 = gap % 6

        total += 1

        # Check constraint
        if state == 0:  # p ≡ 1 mod 6
            if gap_mod6 not in (0, 4):
                violations += 1
                print(f"VIOLATION: p={p}, gap={gap}, gap%6={gap_mod6}")
        else:  # p ≡ 5 mod 6
            if gap_mod6 not in (0, 2):
                violations += 1
                print(f"VIOLATION: p={p}, gap={gap}, gap%6={gap_mod6}")

        key = (state, gap_mod6)
        if key in state_transitions:
            state_transitions[key] += 1

        p = q

    print(f"\n=== Mod-6 Gap Constraint Verification up to {limit} ===")
    print(f"Total gaps checked: {total}")
    print(f"Violations: {violations}")
    print(f"\nTransition counts:")
    for (s, g), count in sorted(state_transitions.items()):
        state_name = "1 mod 6" if s == 0 else "5 mod 6"
        print(f"  State {state_name}, gap ≡ {g} mod 6: {count} ({100*count/total:.1f}%)")


def verify_twin_prime_state_rule(limit: int = 10000) -> None:
    """Verify that twin primes (gap=2) always start from state 5 (p ≡ 5 mod 6)."""
    p = 5
    twin_count = 0
    twin_from_state5 = 0

    while p < limit:
        q = nextprime(p)
        if q - p == 2:
            twin_count += 1
            if p % 6 == 5:
                twin_from_state5 += 1
            else:
                print(f"Twin prime at p={p} NOT from state 5! p%6={p%6}")
        p = q

    print(f"\n=== Twin Prime State Rule up to {limit} ===")
    print(f"Twin prime pairs: {twin_count}")
    print(f"From state 5: {twin_from_state5} ({100*twin_from_state5/max(twin_count,1):.1f}%)")


def verify_gap4_state_rule(limit: int = 10000) -> None:
    """Verify that cousin primes (gap=4) always start from state 1 (p ≡ 1 mod 6)."""
    p = 5
    cousin_count = 0
    cousin_from_state1 = 0

    while p < limit:
        q = nextprime(p)
        if q - p == 4:
            cousin_count += 1
            if p % 6 == 1:
                cousin_from_state1 += 1
            else:
                print(f"Cousin prime at p={p} NOT from state 1! p%6={p%6}")
        p = q

    print(f"\n=== Cousin Prime (gap=4) State Rule up to {limit} ===")
    print(f"Cousin prime pairs: {cousin_count}")
    print(f"From state 1: {cousin_from_state1} ({100*cousin_from_state1/max(cousin_count,1):.1f}%)")


def analyze_gap_patterns(limit: int = 100000) -> None:
    """Analyze consecutive gap patterns and their mod-6 structure."""
    p = 5
    gaps = []

    while p < limit:
        q = nextprime(p)
        gaps.append(q - p)
        p = q

    # Count gap pairs (g1, g2) and verify mod-6 constraints
    pair_counts: dict[tuple[int, int], int] = {}
    for i in range(len(gaps) - 1):
        pair = (gaps[i], gaps[i+1])
        pair_counts[pair] = pair_counts.get(pair, 0) + 1

    print(f"\n=== Gap Pair Analysis up to {limit} ===")
    print(f"Total consecutive gap pairs: {len(gaps)-1}")

    # Top 15 most common pairs
    sorted_pairs = sorted(pair_counts.items(), key=lambda x: -x[1])
    print("\nTop 15 most common consecutive gap pairs:")
    for (g1, g2), count in sorted_pairs[:15]:
        mod6_pair = (g1 % 6, g2 % 6)
        print(f"  [{g1}, {g2}] (mod 6: {mod6_pair}): {count}")

    # Verify [2, 2] never appears for primes > 3
    if (2, 2) in pair_counts:
        print(f"\nWARNING: [2,2] appeared {pair_counts[(2,2)]} times!")
    else:
        print("\n✓ Confirmed: [2, 2] never appears (no prime triplet theorem)")


def mod30_automaton_demo(limit: int = 100000) -> None:
    """Demonstrate the 8-state mod-30 automaton."""
    p = 7  # First prime > 5
    admissible = {1, 7, 11, 13, 17, 19, 23, 29}
    state_counts: dict[int, int] = {}
    transition_counts: dict[tuple[int, int], int] = {}
    total = 0

    while p < limit:
        q = nextprime(p)
        r_p = p % 30
        r_q = q % 30
        gap_mod30 = (q - p) % 30

        assert r_p in admissible, f"p={p}, r={r_p} not admissible!"
        assert r_q in admissible, f"q={q}, r={r_q} not admissible!"

        state_counts[r_p] = state_counts.get(r_p, 0) + 1
        transition_counts[(r_p, gap_mod30)] = transition_counts.get((r_p, gap_mod30), 0) + 1
        total += 1
        p = q

    print(f"\n=== Mod-30 Automaton Analysis up to {limit} ===")
    print(f"\nState distribution (prime residues mod 30):")
    for s in sorted(admissible):
        count = state_counts.get(s, 0)
        print(f"  State {s:2d}: {count:5d} ({100*count/total:.1f}%)")

    print(f"\nEach state allows exactly 8 gap values mod 30 (out of 30)")
    print(f"This gives an admissibility rate of 8/30 ≈ 26.7%")


if __name__ == "__main__":
    verify_mod6_constraint(100000)
    verify_twin_prime_state_rule(100000)
    verify_gap4_state_rule(100000)
    analyze_gap_patterns(100000)
    mod30_automaton_demo(100000)


#!/usr/bin/env python3
"""
Visualization: Prime Gap Automaton State Transitions

Plots the distribution of prime gap values by automaton state,
showing that gaps ≡ 2 mod 6 only come from state 5 and gaps ≡ 4 mod 6
only come from state 1.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
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


def next_prime(n: int) -> int:
    if n < 2:
        return 2
    candidate = n + 1
    if candidate == 2:
        return 2
    if candidate % 2 == 0:
        candidate += 1
    while not is_prime(candidate):
        candidate += 2
    return candidate


def generate_prime_gaps(limit: int):
    """Generate (prime, gap, state) triples."""
    p = 5
    data = []
    while p < limit:
        q = next_prime(p)
        gap = q - p
        state = 0 if p % 6 == 1 else 1
        data.append((p, gap, state))
        p = q
    return data


def plot_gap_distribution_by_state():
    """Plot gap distribution separated by automaton state."""
    data = generate_prime_gaps(50000)

    gaps_state0 = [g for _, g, s in data if s == 0]
    gaps_state1 = [g for _, g, s in data if s == 1]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6), sharey=True)

    max_gap = max(max(gaps_state0), max(gaps_state1))
    bins = np.arange(0, min(max_gap + 2, 42), 2)

    axes[0].hist(gaps_state0, bins=bins, color='steelblue', edgecolor='black',
                 alpha=0.8, label='Admissible: g ≡ 0,4 mod 6')
    axes[0].set_title('State 0: p ≡ 1 (mod 6)', fontsize=14)
    axes[0].set_xlabel('Gap size', fontsize=12)
    axes[0].set_ylabel('Frequency', fontsize=12)

    # Highlight admissible vs inadmissible
    for b in bins[:-1]:
        if b > 0 and b % 6 not in (0, 4):
            axes[0].axvspan(b - 0.5, b + 1.5, alpha=0.15, color='red')

    axes[1].hist(gaps_state1, bins=bins, color='coral', edgecolor='black',
                 alpha=0.8, label='Admissible: g ≡ 0,2 mod 6')
    axes[1].set_title('State 1: p ≡ 5 (mod 6)', fontsize=14)
    axes[1].set_xlabel('Gap size', fontsize=12)

    for b in bins[:-1]:
        if b > 0 and b % 6 not in (0, 2):
            axes[1].axvspan(b - 0.5, b + 1.5, alpha=0.15, color='red')

    fig.suptitle('Prime Gap Distribution by Automaton State (primes < 50,000)',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('gap_distribution_by_state.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gap_distribution_by_state.png")


def plot_state_sequence():
    """Plot the automaton state sequence showing the alternation pattern."""
    data = generate_prime_gaps(2000)

    primes = [d[0] for d in data[:100]]
    states = [d[2] for d in data[:100]]
    gaps = [d[1] for d in data[:100]]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 8))

    # State sequence
    colors = ['steelblue' if s == 0 else 'coral' for s in states]
    ax1.bar(range(len(states)), [1]*len(states), color=colors, width=1.0)
    ax1.set_ylabel('State', fontsize=12)
    ax1.set_yticks([0.5])
    ax1.set_yticklabels([''])
    ax1.set_title('Automaton State Sequence (blue=state 0, red=state 1)', fontsize=14)

    # Gap sequence colored by mod-6 residue
    gap_colors = []
    for g in gaps:
        m = g % 6
        if m == 0:
            gap_colors.append('green')
        elif m == 2:
            gap_colors.append('coral')
        elif m == 4:
            gap_colors.append('steelblue')
        else:
            gap_colors.append('gray')

    ax2.bar(range(len(gaps)), gaps, color=gap_colors, width=0.8, edgecolor='black',
            linewidth=0.3)
    ax2.set_xlabel('Prime index (from p=5)', fontsize=12)
    ax2.set_ylabel('Gap size', fontsize=12)
    ax2.set_title('Gap sizes (green=≡0, blue=≡4, red=≡2 mod 6)', fontsize=14)

    plt.tight_layout()
    plt.savefig('state_sequence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: state_sequence.png")


def plot_mod30_heatmap():
    """Plot the mod-30 transition heatmap."""
    data = generate_prime_gaps(100000)

    # Filter primes > 5
    data = [(p, g, s) for p, g, s in data if p > 5]

    admissible = sorted([1, 7, 11, 13, 17, 19, 23, 29])
    matrix = np.zeros((8, 30))

    for p, g, _ in data:
        r = p % 30
        if r in admissible:
            i = admissible.index(r)
            g_mod30 = g % 30
            matrix[i][g_mod30] += 1

    fig, ax = plt.subplots(figsize=(16, 6))
    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')

    ax.set_yticks(range(8))
    ax.set_yticklabels(admissible)
    ax.set_ylabel('Source state (p mod 30)', fontsize=12)
    ax.set_xlabel('Gap mod 30', fontsize=12)
    ax.set_title('Mod-30 Automaton: Transition Frequency Heatmap', fontsize=14)

    plt.colorbar(im, label='Count')
    plt.tight_layout()
    plt.savefig('mod30_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: mod30_heatmap.png")


if __name__ == "__main__":
    plot_gap_distribution_by_state()
    plot_state_sequence()
    plot_mod30_heatmap()
