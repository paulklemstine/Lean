#!/usr/bin/env python3
"""
Prime Gap Crossword: Demonstration of Gap Transition Theory

Demonstrates the key findings:
1. Prime gap sequences and their mod-6 state transitions
2. Forcing patterns in the mod-30 sieve
3. Hardy-Littlewood prediction vs. empirical gap distribution
4. Bertrand gap bound verification
"""

from sympy import isprime, nextprime, primerange
from collections import Counter, defaultdict
import math


def prime_gaps(limit: int) -> list[tuple[int, int, int]]:
    """Return list of (p, q, gap) for consecutive primes up to limit."""
    primes = list(primerange(2, limit))
    return [(primes[i], primes[i+1], primes[i+1] - primes[i])
            for i in range(len(primes) - 1)]


def mod6_state(p: int) -> int:
    """Return the mod-6 state of a prime > 3: 1 or 5."""
    assert p > 3 and isprime(p)
    return p % 6


def verify_bertrand_bound(limit: int) -> None:
    """Verify that gap < p for all consecutive primes up to limit."""
    print(f"\n=== Bertrand Gap Bound Verification (up to {limit:,}) ===")
    gaps = prime_gaps(limit)
    violations = [(p, q, g) for p, q, g in gaps if g >= p]
    # The only "violation" is (2, 3, 1) where gap = 1 < 2, so none
    print(f"Checked {len(gaps):,} consecutive prime pairs")
    print(f"Violations of gap < p: {len(violations)}")
    if violations:
        for p, q, g in violations[:5]:
            print(f"  p={p}, q={q}, gap={g}")
    
    # Show the largest gap/prime ratio
    ratios = [(g/p, p, q, g) for p, q, g in gaps if p > 2]
    ratios.sort(reverse=True)
    print(f"\nLargest gap/prime ratios:")
    for ratio, p, q, g in ratios[:10]:
        print(f"  p={p:>8}, gap={g:>4}, ratio={ratio:.6f}")


def mod6_transition_analysis(limit: int) -> None:
    """Analyze mod-6 state transitions in prime gap sequences."""
    print(f"\n=== Mod-6 State Transition Analysis (up to {limit:,}) ===")
    
    transitions = Counter()  # (from_state, to_state) -> count
    gap_by_transition = defaultdict(list)  # (from_state, to_state) -> gaps
    
    primes = list(primerange(7, limit))  # Start from 7 to ensure > 3
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i+1]
        s1, s2 = p % 6, q % 6
        gap = q - p
        transitions[(s1, s2)] += 1
        if len(gap_by_transition[(s1, s2)]) < 20:
            gap_by_transition[(s1, s2)].append(gap)
    
    print("\nTransition counts:")
    for (s1, s2), count in sorted(transitions.items()):
        pct = 100 * count / sum(transitions.values())
        print(f"  {s1} -> {s2}: {count:>8} ({pct:.1f}%)")
        gaps = gap_by_transition[(s1, s2)]
        print(f"    Example gaps: {gaps[:10]}")
    
    # Verify: 1->3, 5->3, etc. never occur (would mean non-unit mod 6)
    print("\nForbidden transitions (to non-unit states):")
    for s1 in [1, 5]:
        for s2 in [0, 2, 3, 4]:
            if transitions.get((s1, s2), 0) > 0:
                print(f"  VIOLATION: {s1} -> {s2}")
            else:
                print(f"  ✓ {s1} -> {s2}: 0 (correctly forbidden)")


def forcing_pattern_analysis(limit: int) -> None:
    """Find forcing patterns in prime gap sequences."""
    print(f"\n=== Forcing Pattern Analysis (up to {limit:,}) ===")
    
    gaps = [g for _, _, g in prime_gaps(limit)]
    
    # Check if gap pattern [2] forces next gap
    patterns_to_check = {
        (2,): "After gap 2",
        (4,): "After gap 4",
        (2, 4): "After gaps [2, 4]",
        (4, 2): "After gaps [4, 2]",
        (6, 4, 2): "After gaps [6, 4, 2]",
        (2, 4, 2): "After gaps [2, 4, 2]",
    }
    
    for pattern, desc in patterns_to_check.items():
        k = len(pattern)
        next_gaps = Counter()
        for i in range(len(gaps) - k):
            if tuple(gaps[i:i+k]) == pattern:
                next_gaps[gaps[i+k]] += 1
        
        if next_gaps:
            total = sum(next_gaps.values())
            most_common = next_gaps.most_common(1)[0]
            forcing_prob = most_common[1] / total
            print(f"\n{desc} (pattern {list(pattern)}):")
            print(f"  Occurrences: {total}")
            print(f"  Most likely next gap: {most_common[0]} "
                  f"(prob={forcing_prob:.4f})")
            print(f"  Distribution: {dict(next_gaps.most_common(5))}")


def gap_mod6_rhythm(limit: int) -> None:
    """Verify the gap rhythm theorem: after gap 2, next gap >= 4."""
    print(f"\n=== Gap Rhythm Theorem Verification (up to {limit:,}) ===")
    
    gaps = [g for _, _, g in prime_gaps(limit)]
    
    # Find all gap-2 occurrences and check next gap
    violations = 0
    total = 0
    next_gap_dist = Counter()
    
    for i in range(1, len(gaps) - 1):  # Skip first gap (2->3)
        if gaps[i] == 2:
            total += 1
            next_gap_dist[gaps[i+1]] += 1
            if gaps[i+1] < 4:
                violations += 1
    
    print(f"Twin prime gaps found: {total}")
    print(f"Violations of next gap >= 4: {violations}")
    print(f"Distribution of gap after twin prime:")
    for g, c in sorted(next_gap_dist.items())[:10]:
        print(f"  gap={g}: {c} ({100*c/total:.1f}%)")


def gap_distribution_vs_hardy_littlewood(limit: int) -> None:
    """Compare empirical gap distribution with Hardy-Littlewood prediction."""
    print(f"\n=== Gap Distribution vs Hardy-Littlewood (up to {limit:,}) ===")
    
    C2 = 0.6601618  # Twin prime constant
    
    gaps_data = prime_gaps(limit)
    gap_counts = Counter(g for _, _, g in gaps_data)
    N = len(gaps_data)
    avg_log_p = sum(math.log(p) for p, _, _ in gaps_data) / N
    
    print(f"Total prime pairs: {N}")
    print(f"Average log(p): {avg_log_p:.2f}")
    print(f"\n{'Gap':>5} {'Count':>8} {'Empirical':>10} {'H-L Pred':>10} {'Ratio':>8}")
    print("-" * 50)
    
    for g in sorted(gap_counts.keys())[:15]:
        if g == 0 or g % 2 == 1:
            continue
        empirical = gap_counts[g] / N
        # Simplified Hardy-Littlewood: P(gap=g) ≈ C₂ · S(g) / log(p)
        # where S(g) accounts for prime divisors of g
        S_g = 2.0
        for q in range(3, g + 1):
            if isprime(q) and g % q == 0:
                S_g *= (q - 1) / (q - 2)
        hl_pred = 2 * C2 * S_g / (g * avg_log_p)
        ratio = empirical / hl_pred if hl_pred > 0 else float('inf')
        print(f"{g:>5} {gap_counts[g]:>8} {empirical:>10.6f} {hl_pred:>10.6f} {ratio:>8.3f}")


def main():
    LIMIT = 10_000_000
    
    print("=" * 60)
    print("PRIME GAP CROSSWORD: Transition Theory Demonstration")
    print("=" * 60)
    
    verify_bertrand_bound(LIMIT)
    mod6_transition_analysis(LIMIT)
    gap_mod6_rhythm(LIMIT)
    forcing_pattern_analysis(LIMIT)
    gap_distribution_vs_hardy_littlewood(LIMIT)
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Forcing Patterns in the Prime Gap Automaton
Shows how certain gap sequences uniquely determine the next gap
via modular sieve constraints.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def sieve(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def compute_conditional_probs(limit, context_length=1):
    """Compute P(next_gap | previous gaps)."""
    primes = sieve(limit)
    gaps = [primes[i+1] - primes[i] for i in range(1, len(primes) - 1)]  # skip 2->3
    
    conditional = {}
    for i in range(context_length, len(gaps)):
        context = tuple(gaps[i-context_length:i])
        next_gap = gaps[i]
        if context not in conditional:
            conditional[context] = {}
        conditional[context][next_gap] = conditional[context].get(next_gap, 0) + 1
    
    # Normalize
    probs = {}
    for ctx, counts in conditional.items():
        total = sum(counts.values())
        probs[ctx] = {g: c/total for g, c in counts.items()}
    
    return probs


def main():
    LIMIT = 5_000_000
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Forcing Patterns in Prime Gap Sequences', fontsize=16, fontweight='bold')
    
    # Compute conditional probabilities
    probs1 = compute_conditional_probs(LIMIT, 1)
    probs2 = compute_conditional_probs(LIMIT, 2)
    
    # Top-left: P(next_gap | prev_gap = 2)
    ax = axes[0, 0]
    ctx = (2,)
    if ctx in probs1:
        dist = probs1[ctx]
        gaps_sorted = sorted(dist.keys())[:15]
        vals = [dist.get(g, 0) for g in gaps_sorted]
        colors = ['red' if g < 4 else 'steelblue' for g in gaps_sorted]
        ax.bar(range(len(gaps_sorted)), vals, color=colors)
        ax.set_xticks(range(len(gaps_sorted)))
        ax.set_xticklabels(gaps_sorted, fontsize=8)
        ax.set_xlabel('Next gap')
        ax.set_ylabel('Probability')
        ax.set_title('P(next gap | prev gap = 2)\nNote: gap=2 is impossible (no triplets!)', fontsize=10)
        ax.axvline(x=gaps_sorted.index(4) if 4 in gaps_sorted else -1,
                   color='green', linestyle='--', alpha=0.5, label='Most likely: 4')
        ax.legend(fontsize=8)
    
    # Top-right: P(next_gap | prev_gap = 4)
    ax = axes[0, 1]
    ctx = (4,)
    if ctx in probs1:
        dist = probs1[ctx]
        gaps_sorted = sorted(dist.keys())[:15]
        vals = [dist.get(g, 0) for g in gaps_sorted]
        ax.bar(range(len(gaps_sorted)), vals, color='coral')
        ax.set_xticks(range(len(gaps_sorted)))
        ax.set_xticklabels(gaps_sorted, fontsize=8)
        ax.set_xlabel('Next gap')
        ax.set_ylabel('Probability')
        ax.set_title('P(next gap | prev gap = 4)', fontsize=10)
    
    # Bottom-left: Entropy of next gap given prev gap
    ax = axes[1, 0]
    prev_gaps = sorted([ctx[0] for ctx in probs1.keys() if len(ctx) == 1])[:20]
    entropies = []
    for g in prev_gaps:
        ctx = (g,)
        if ctx in probs1:
            dist = probs1[ctx]
            entropy = -sum(p * np.log2(p) for p in dist.values() if p > 0)
            entropies.append(entropy)
        else:
            entropies.append(0)
    
    ax.bar(range(len(prev_gaps)), entropies, color='teal', alpha=0.8)
    ax.set_xticks(range(len(prev_gaps)))
    ax.set_xticklabels(prev_gaps, fontsize=8)
    ax.set_xlabel('Previous gap')
    ax.set_ylabel('Shannon entropy (bits)')
    ax.set_title('Predictability: lower entropy = more forcing', fontsize=10)
    
    # Mark the most forcing patterns
    min_idx = np.argmin(entropies)
    ax.bar(min_idx, entropies[min_idx], color='red', alpha=0.8)
    ax.annotate(f'Most forcing:\ngap={prev_gaps[min_idx]}',
               xy=(min_idx, entropies[min_idx]),
               xytext=(min_idx + 2, entropies[min_idx] + 0.5),
               arrowprops=dict(arrowstyle='->', color='red'),
               fontsize=9, color='red')
    
    # Bottom-right: 2-context forcing
    ax = axes[1, 1]
    # Find the most forcing 2-contexts
    forcing_scores = []
    for ctx, dist in probs2.items():
        total_count = sum(v * len(list(probs2.keys())) for v in dist.values())
        max_prob = max(dist.values())
        entropy = -sum(p * np.log2(p) for p in dist.values() if p > 0)
        n_samples = sum(1 for v in dist.values())
        if sum(dist.values()) > 0.001:  # enough data
            forcing_scores.append((ctx, max_prob, entropy))
    
    forcing_scores.sort(key=lambda x: x[2])  # sort by entropy (ascending)
    
    top_n = min(15, len(forcing_scores))
    contexts = [str(list(f[0])) for f in forcing_scores[:top_n]]
    max_probs = [f[1] for f in forcing_scores[:top_n]]
    ents = [f[2] for f in forcing_scores[:top_n]]
    
    colors = ['red' if mp > 0.5 else 'steelblue' for mp in max_probs]
    ax.barh(range(top_n), ents, color=colors, alpha=0.8)
    ax.set_yticks(range(top_n))
    ax.set_yticklabels(contexts, fontsize=7)
    ax.set_xlabel('Shannon entropy (bits)')
    ax.set_title('Most Forcing 2-Gap Contexts\n(red = dominant next gap > 50%)', fontsize=10)
    ax.invert_yaxis()
    
    plt.tight_layout()
    plt.savefig('viz_forcing_patterns.png', dpi=150, bbox_inches='tight')
    print("Saved viz_forcing_patterns.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Gap Distribution vs Hardy-Littlewood Prediction
"""

import matplotlib.pyplot as plt
import numpy as np
from math import log, gcd


def sieve(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def is_prime_simple(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def singular_series(g):
    if g == 0 or g % 2 != 0:
        return 0.0
    C2 = 0.6601618158468
    result = 2.0 * C2
    n = g
    p = 3
    while p * p <= n:
        if n % p == 0:
            result *= (p - 1) / (p - 2)
            while n % p == 0:
                n //= p
        p += 2
    if n > 2:
        result *= (n - 1) / (n - 2)
    return result


def main():
    LIMIT = 2_000_000
    primes = sieve(LIMIT)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    
    # Count gap frequencies
    gap_counts = {}
    for g in gaps:
        gap_counts[g] = gap_counts.get(g, 0) + 1
    
    N = len(gaps)
    avg_log_p = sum(log(primes[i]) for i in range(N)) / N
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Top-left: Gap distribution
    ax = axes[0, 0]
    even_gaps = sorted([g for g in gap_counts if g % 2 == 0 and g <= 40])
    empirical = [gap_counts.get(g, 0) / N for g in even_gaps]
    predicted = [singular_series(g) / (g * avg_log_p) for g in even_gaps]
    
    x = np.arange(len(even_gaps))
    width = 0.35
    ax.bar(x - width/2, empirical, width, label='Empirical', color='steelblue', alpha=0.8)
    ax.bar(x + width/2, predicted, width, label='Hardy-Littlewood', color='coral', alpha=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels(even_gaps, fontsize=8)
    ax.set_xlabel('Gap size')
    ax.set_ylabel('Frequency')
    ax.set_title(f'Gap Distribution (primes up to {LIMIT:,})', fontweight='bold')
    ax.legend()
    
    # Top-right: Ratio of empirical to predicted
    ax2 = axes[0, 1]
    ratios = [e / p if p > 0 else 0 for e, p in zip(empirical, predicted)]
    ax2.bar(x, ratios, color='seagreen', alpha=0.8)
    ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Perfect agreement')
    ax2.set_xticks(x)
    ax2.set_xticklabels(even_gaps, fontsize=8)
    ax2.set_xlabel('Gap size')
    ax2.set_ylabel('Empirical / Predicted')
    ax2.set_title('Agreement with Hardy-Littlewood', fontweight='bold')
    ax2.legend()
    ax2.set_ylim(0.5, 1.5)
    
    # Bottom-left: Gap/prime ratio over primes
    ax3 = axes[1, 0]
    sample_indices = list(range(0, len(gaps), max(1, len(gaps) // 2000)))
    sample_primes = [primes[i] for i in sample_indices]
    sample_ratios = [gaps[i] / primes[i] for i in sample_indices]
    
    ax3.scatter(sample_primes, sample_ratios, s=1, alpha=0.3, color='navy')
    ax3.set_xlabel('Prime p')
    ax3.set_ylabel('Gap / p')
    ax3.set_title('Bertrand Bound: gap(n) < p(n)', fontweight='bold')
    ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Bertrand bound')
    ax3.legend()
    ax3.set_ylim(0, 0.5)
    
    # Bottom-right: Consecutive gap pairs colored by mod-6 transition
    ax4 = axes[1, 1]
    colors_map = {(1,1): 'green', (1,5): 'red', (5,1): 'blue', (5,5): 'purple'}
    primes_gt3 = [p for p in primes if p > 3]
    
    for i in range(min(3000, len(primes_gt3) - 2)):
        p = primes_gt3[i]
        g1 = primes_gt3[i+1] - p
        g2 = primes_gt3[i+2] - primes_gt3[i+1]
        s1, s2 = p % 6, primes_gt3[i+1] % 6
        color = colors_map.get((s1, s2), 'gray')
        ax4.scatter(g1, g2, s=2, alpha=0.4, color=color)
    
    ax4.set_xlabel('Gap g(n)')
    ax4.set_ylabel('Gap g(n+1)')
    ax4.set_title('Consecutive Gap Pairs (colored by mod-6 transition)', fontweight='bold')
    
    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green', label='1→1', markersize=8),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red', label='1→5', markersize=8),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='blue', label='5→1', markersize=8),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='purple', label='5→5', markersize=8),
    ]
    ax4.legend(handles=legend_elements, title='Mod-6', fontsize=8)
    
    plt.tight_layout()
    plt.savefig('viz_gap_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved viz_gap_distribution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Gap Mod-6 Transition Diagram
Shows the state machine governing prime gap transitions mod 6.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from math import gcd


def sieve(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def compute_transitions(limit):
    primes = [p for p in sieve(limit) if p > 3]
    transitions = {}
    for i in range(len(primes) - 1):
        s1 = primes[i] % 6
        s2 = primes[i+1] % 6
        gap = primes[i+1] - primes[i]
        key = (s1, s2)
        transitions[key] = transitions.get(key, 0) + 1
    return transitions


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: State transition diagram
    ax = axes[0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Mod-6 Prime Gap State Machine', fontsize=14, fontweight='bold')
    
    # Draw states
    state_pos = {1: (-0.8, 0), 5: (0.8, 0)}
    for state, (x, y) in state_pos.items():
        circle = plt.Circle((x, y), 0.3, fill=True, facecolor='lightblue',
                           edgecolor='navy', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, f'p≡{state}\n(mod 6)', ha='center', va='center',
               fontsize=11, fontweight='bold')
    
    # Draw transitions with arrows
    # 1 -> 5: gap ≡ 4 mod 6
    ax.annotate('', xy=(0.5, 0.15), xytext=(-0.5, 0.15),
               arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(0, 0.35, 'gap ≡ 4 (mod 6)', ha='center', fontsize=9, color='red')
    
    # 5 -> 1: gap ≡ 2 mod 6
    ax.annotate('', xy=(-0.5, -0.15), xytext=(0.5, -0.15),
               arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.text(0, -0.35, 'gap ≡ 2 (mod 6)', ha='center', fontsize=9, color='blue')
    
    # 1 -> 1: gap ≡ 0 mod 6 (self-loop)
    arc1 = patches.FancyArrowPatch((-0.95, 0.25), (-0.65, 0.25),
                                    connectionstyle="arc3,rad=-1.2",
                                    arrowstyle='->', color='green', lw=2)
    ax.add_patch(arc1)
    ax.text(-1.5, 0.7, 'gap ≡ 0\n(mod 6)', ha='center', fontsize=9, color='green')
    
    # 5 -> 5: gap ≡ 0 mod 6 (self-loop)
    arc2 = patches.FancyArrowPatch((0.95, 0.25), (0.65, 0.25),
                                    connectionstyle="arc3,rad=1.2",
                                    arrowstyle='->', color='purple', lw=2)
    ax.add_patch(arc2)
    ax.text(1.5, 0.7, 'gap ≡ 0\n(mod 6)', ha='center', fontsize=9, color='purple')
    
    ax.text(0, -1.2, 'Every prime > 3 is in exactly one state.\n'
           'The gap determines the transition uniquely.',
           ha='center', fontsize=9, style='italic')
    
    # Right: Empirical transition frequencies
    ax2 = axes[1]
    transitions = compute_transitions(1_000_000)
    total = sum(transitions.values())
    
    labels = ['1→1\n(gap≡0)', '1→5\n(gap≡4)', '5→1\n(gap≡2)', '5→5\n(gap≡0)']
    keys = [(1,1), (1,5), (5,1), (5,5)]
    counts = [transitions.get(k, 0) for k in keys]
    pcts = [100 * c / total for c in counts]
    colors = ['green', 'red', 'blue', 'purple']
    
    bars = ax2.bar(range(4), pcts, color=colors, alpha=0.7, edgecolor='black')
    ax2.set_xticks(range(4))
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_ylabel('Frequency (%)', fontsize=12)
    ax2.set_title('Empirical Transition Frequencies\n(primes up to 1,000,000)',
                 fontsize=14, fontweight='bold')
    
    for bar, pct in zip(bars, pcts):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                f'{pct:.1f}%', ha='center', fontsize=11, fontweight='bold')
    
    ax2.set_ylim(0, max(pcts) * 1.15)
    
    plt.tight_layout()
    plt.savefig('viz_gap_transitions.png', dpi=150, bbox_inches='tight')
    print("Saved viz_gap_transitions.png")


if __name__ == "__main__":
    main()
