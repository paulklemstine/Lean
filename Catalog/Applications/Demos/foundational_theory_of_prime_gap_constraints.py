#!/usr/bin/env python3
"""
Prime Gap Automaton: Demonstration of Modular Constraint Theory

This demo illustrates how the mod-6 and mod-30 automata constrain
prime gap sequences, and tests the Gap AP Bound Conjecture.
"""

from algorithms import (
    ResidueTransitionSystem, primes_up_to, analyze_gap_sequence,
    find_longest_gap_runs, mod6_state
)


def demo_mod6_automaton():
    """Demonstrate the mod-6 automaton on the first 20 primes."""
    print("=" * 60)
    print("DEMO 1: Mod-6 Automaton on Consecutive Primes")
    print("=" * 60)

    primes = primes_up_to(100)
    print(f"\nPrimes up to 100: {primes}")
    print(f"\n{'Prime':>6} {'Mod 6':>6} {'State':>6} {'Gap':>5} {'Gap%6':>6}")
    print("-" * 35)

    for i, p in enumerate(primes):
        state = mod6_state(p) if p > 3 else "—"
        gap = primes[i+1] - p if i < len(primes) - 1 else "—"
        gap_mod6 = gap % 6 if isinstance(gap, int) else "—"
        print(f"{p:>6} {p % 6:>6} {state:>6} {gap!s:>5} {gap_mod6!s:>6}")


def demo_forbidden_patterns():
    """Demonstrate forbidden patterns in prime gap sequences."""
    print("\n" + "=" * 60)
    print("DEMO 2: Forbidden Pattern Verification")
    print("=" * 60)

    primes = primes_up_to(10000)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

    # Check [2,2] forbidden
    consecutive_22 = sum(1 for i in range(len(gaps)-1)
                        if gaps[i] == 2 and gaps[i+1] == 2
                        and primes[i] > 3)
    print(f"\nConsecutive [2,2] for p > 3: {consecutive_22} (should be 0)")

    # Check [4,4] forbidden
    consecutive_44 = sum(1 for i in range(len(gaps)-1)
                        if gaps[i] == 4 and gaps[i+1] == 4
                        and primes[i] > 3)
    print(f"Consecutive [4,4] for p > 3: {consecutive_44} (should be 0)")

    # Check [2,4,2,4,2] forbidden for p > 5
    consecutive_24242 = 0
    for i in range(len(gaps)-4):
        if (gaps[i] == 2 and gaps[i+1] == 4 and gaps[i+2] == 2
            and gaps[i+3] == 4 and gaps[i+4] == 2 and primes[i] > 5):
            consecutive_24242 += 1
    print(f"Pattern [2,4,2,4,2] for p > 5: {consecutive_24242} (should be 0)")

    # Show [2,4,2] IS allowed
    examples_242 = []
    for i in range(len(gaps)-2):
        if gaps[i] == 2 and gaps[i+1] == 4 and gaps[i+2] == 2:
            examples_242.append(primes[i])
    print(f"\nPattern [2,4,2] occurrences: {len(examples_242)}")
    print(f"Examples: {examples_242[:10]}")
    print("  (This pattern IS allowed — e.g., 11,13,17,19)")


def demo_twin_prime_isolation():
    """Demonstrate twin prime isolation theorem."""
    print("\n" + "=" * 60)
    print("DEMO 3: Twin Prime Isolation")
    print("=" * 60)

    primes = primes_up_to(1000)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

    print(f"\n{'Twin pair':>15} {'Prev gap':>10} {'Next gap':>10} {'Isolated?':>10}")
    print("-" * 50)

    for i in range(1, len(gaps)-1):
        if gaps[i] == 2 and primes[i] > 3:
            prev_gap = gaps[i-1]
            next_gap = gaps[i+1]
            isolated = prev_gap >= 4 and next_gap >= 4
            print(f"({primes[i]:>4}, {primes[i+1]:>4}) {prev_gap:>10} {next_gap:>10} {'✓' if isolated else '✗':>10}")


def demo_gap_ap_conjecture():
    """Test the Gap AP Bound Conjecture for small gap values."""
    print("\n" + "=" * 60)
    print("DEMO 4: Gap AP Bound Conjecture Testing")
    print("=" * 60)

    limit = 10_000_000
    print(f"\nSearching among primes up to {limit:,}...")

    for g in [2, 4, 6, 8, 10, 12]:
        run_len, starts = find_longest_gap_runs(limit, g)
        conj_bound = g // 2 + 1
        print(f"\n  Gap = {g}: max consecutive run = {run_len}")
        print(f"    Conjectured bound: ≤ {conj_bound}")
        print(f"    Status: {'✓ within bound' if run_len <= conj_bound else '✗ EXCEEDS bound'}")
        if starts:
            print(f"    Example starting at p = {starts[0]}")


def demo_state_statistics():
    """Show state distribution and transition statistics."""
    print("\n" + "=" * 60)
    print("DEMO 5: Mod-6 State Statistics")
    print("=" * 60)

    primes = primes_up_to(100000)
    stats = analyze_gap_sequence(primes)

    print(f"\nPrimes analyzed: {stats['num_primes']:,}")
    print(f"Total gaps: {stats['num_gaps']:,}")
    print(f"\nGap residues mod 6:")
    for r in sorted(stats['gap_residues_mod6'].keys()):
        count = stats['gap_residues_mod6'][r]
        pct = 100 * count / stats['num_gaps']
        print(f"  ≡ {r} mod 6: {count:>6} ({pct:.1f}%)")

    print(f"\nState transitions:")
    for (s, t), count in sorted(stats['transitions'].items()):
        pct = 100 * count / sum(stats['transitions'].values())
        print(f"  {s:>4} → {t:>4}: {count:>6} ({pct:.1f}%)")

    print(f"\nSpecial gap counts:")
    print(f"  Twin primes (gap 2):   {stats['twin_prime_count']:>6}")
    print(f"  Cousin primes (gap 4): {stats['cousin_prime_count']:>6}")
    print(f"  Sexy primes (gap 6):   {stats['sexy_prime_count']:>6}")


def demo_rts_comparison():
    """Compare RTS at different primorial levels."""
    print("\n" + "=" * 60)
    print("DEMO 6: RTS Comparison Across Primorial Levels")
    print("=" * 60)

    for primes_list, name in [([2,3], "mod-6"), ([2,3,5], "mod-30"),
                               ([2,3,5,7], "mod-210")]:
        rts = ResidueTransitionSystem.from_primorial(primes_list)
        density = len(rts.states) / rts.modulus

        print(f"\n{name} (modulus = {rts.modulus}):")
        print(f"  States: {len(rts.states)} = φ({rts.modulus})")
        print(f"  Density: {density:.4f}")
        print(f"  Avg admissible gaps per state: {sum(len(rts.admissible_gaps(s)) for s in rts.states) / len(rts.states):.1f}")

        # Count total transitions
        tm = rts.transition_matrix()
        print(f"  Total (state, state) transitions: {len(tm)}")


if __name__ == "__main__":
    demo_mod6_automaton()
    demo_forbidden_patterns()
    demo_twin_prime_isolation()
    demo_state_statistics()
    demo_rts_comparison()
    demo_gap_ap_conjecture()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of the Mod-6 Prime Gap Automaton and gap statistics.
Standalone script using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
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
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def plot_gap_automaton_and_stats():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Prime Gap Automaton Theory', fontsize=16, fontweight='bold')

    # Panel 1: Mod-6 automaton diagram
    ax = axes[0, 0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Mod-6 Automaton', fontsize=13)
    ax.axis('off')

    # Draw states
    circle1 = plt.Circle((-0.8, 0), 0.4, fill=False, linewidth=2, color='#2196F3')
    circle5 = plt.Circle((0.8, 0), 0.4, fill=False, linewidth=2, color='#F44336')
    ax.add_patch(circle1)
    ax.add_patch(circle5)
    ax.text(-0.8, 0, 'State 1\n(p≡1)', ha='center', va='center', fontsize=10, color='#2196F3', fontweight='bold')
    ax.text(0.8, 0, 'State 5\n(p≡5)', ha='center', va='center', fontsize=10, color='#F44336', fontweight='bold')

    # Self-loops
    ax.annotate('', xy=(-0.8, 0.45), xytext=(-0.4, 0.8),
                arrowprops=dict(arrowstyle='->', color='#2196F3', lw=1.5, connectionstyle='arc3,rad=-0.5'))
    ax.text(-1.1, 0.85, 'gap≡0', fontsize=9, color='#2196F3')

    ax.annotate('', xy=(0.8, 0.45), xytext=(1.2, 0.8),
                arrowprops=dict(arrowstyle='->', color='#F44336', lw=1.5, connectionstyle='arc3,rad=0.5'))
    ax.text(0.95, 0.85, 'gap≡0', fontsize=9, color='#F44336')

    # Cross transitions
    ax.annotate('', xy=(0.4, 0.1), xytext=(-0.4, 0.1),
                arrowprops=dict(arrowstyle='->', color='#9C27B0', lw=2))
    ax.text(0, 0.25, 'gap≡4', fontsize=9, color='#9C27B0', ha='center')

    ax.annotate('', xy=(-0.4, -0.1), xytext=(0.4, -0.1),
                arrowprops=dict(arrowstyle='->', color='#FF9800', lw=2))
    ax.text(0, -0.35, 'gap≡2', fontsize=9, color='#FF9800', ha='center')

    ax.text(0, -1.2, '(all residues mod 6)', fontsize=9, ha='center', style='italic', color='gray')

    # Panel 2: Gap distribution mod 6
    ax = axes[0, 1]
    primes = primes_up_to(100000)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1) if primes[i] > 3]
    gap_mod6 = [g % 6 for g in gaps]

    counts = [gap_mod6.count(r) for r in range(6)]
    colors = ['#4CAF50' if r in [0, 2, 4] else '#BDBDBD' for r in range(6)]
    bars = ax.bar(range(6), counts, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('Gap mod 6', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title(f'Gap Residues mod 6 (primes to {100000:,})', fontsize=13)
    ax.set_xticks(range(6))
    # Mark forbidden residues
    for i in [1, 3, 5]:
        bars[i].set_hatch('///')
        bars[i].set_edgecolor('red')
    ax.legend(['Admissible', 'Forbidden (count=0)'], fontsize=9, loc='upper right')

    # Panel 3: Twin prime isolation
    ax = axes[1, 0]
    twin_indices = [i for i in range(len(primes)-1) if primes[i+1] - primes[i] == 2 and primes[i] > 5]
    before_gaps = []
    after_gaps = []
    for idx in twin_indices:
        if idx > 0:
            before_gaps.append(primes[idx] - primes[idx-1])
        if idx + 1 < len(primes) - 1:
            after_gaps.append(primes[idx+2] - primes[idx+1])

    gap_values = sorted(set(before_gaps + after_gaps))[:15]
    before_counts = [before_gaps.count(g) for g in gap_values]
    after_counts = [after_gaps.count(g) for g in gap_values]

    x = np.arange(len(gap_values))
    width = 0.35
    ax.bar(x - width/2, before_counts, width, label='Gap before twin', color='#2196F3', alpha=0.8)
    ax.bar(x + width/2, after_counts, width, label='Gap after twin', color='#F44336', alpha=0.8)
    ax.set_xlabel('Gap value', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title('Twin Prime Isolation: Adjacent Gaps', fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(gap_values)
    ax.axvline(x=gap_values.index(4) - 0.5 if 4 in gap_values else -1,
               color='green', linestyle='--', alpha=0.5, label='Min gap = 4')
    ax.legend(fontsize=9)

    # Panel 4: Longest gap runs
    ax = axes[1, 1]
    limit = 1000000
    p = primes_up_to(limit)
    g = [p[i+1] - p[i] for i in range(len(p) - 1)]

    gap_test_values = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
    max_runs = []
    for gv in gap_test_values:
        max_run = 0
        current_run = 0
        for gi in g:
            if gi == gv:
                current_run += 1
                max_run = max(max_run, current_run)
            else:
                current_run = 0
        max_runs.append(max_run)

    conj_bounds = [gv // 2 + 1 for gv in gap_test_values]

    ax.bar(range(len(gap_test_values)), max_runs, color='#4CAF50', alpha=0.8, label='Observed max run')
    ax.plot(range(len(gap_test_values)), conj_bounds, 'r--o', label='Conjectured bound g/2+1', markersize=5)
    ax.set_xlabel('Gap value g', fontsize=11)
    ax.set_ylabel('Max consecutive run', fontsize=11)
    ax.set_title(f'Gap AP Bound (primes to {limit:,})', fontsize=13)
    ax.set_xticks(range(len(gap_test_values)))
    ax.set_xticklabels(gap_test_values)
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('prime_gap_automaton.png', dpi=150, bbox_inches='tight')
    print("Saved: prime_gap_automaton.png")


if __name__ == '__main__':
    plot_gap_automaton_and_stats()
