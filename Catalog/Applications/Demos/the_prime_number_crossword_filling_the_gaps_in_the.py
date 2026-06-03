#!/usr/bin/env python3
"""
Prime Gap Crossword: Demonstrations and Numerical Experiments

Demonstrates the key results from the prime gap crossword theory:
1. Mod-6 gap grammar verification
2. Primorial automaton mod-30 analysis
3. Forcing pattern search
4. Gap distribution statistics
"""

from sympy import isprime, nextprime, primerange
from collections import Counter, defaultdict
import math


def prime_gaps(limit: int) -> list[tuple[int, int, int]]:
    """Generate (p, q, gap) for consecutive primes up to limit."""
    primes = list(primerange(2, limit))
    return [(primes[i], primes[i+1], primes[i+1] - primes[i])
            for i in range(len(primes) - 1)]


def demo_no_prime_triplet():
    """Verify: no p > 3 has p, p+2, p+4 all prime."""
    print("=" * 60)
    print("DEMO 1: No Prime Triplet Theorem")
    print("=" * 60)
    print("Checking all p up to 10^6: can p, p+2, p+4 all be prime for p > 3?")
    
    for p in range(5, 1_000_001):
        if isprime(p) and isprime(p + 2) and isprime(p + 4):
            print(f"  COUNTEREXAMPLE FOUND: {p}, {p+2}, {p+4}")
            return
    
    print("  No counterexample found (as expected).")
    print("  The only prime triplet {p, p+2, p+4} is {3, 5, 7}.\n")


def demo_mod6_grammar():
    """Verify the mod-6 gap grammar."""
    print("=" * 60)
    print("DEMO 2: Mod-6 Gap Grammar")
    print("=" * 60)
    
    gaps = prime_gaps(1_000_000)
    # Skip first gap (2→3) and gaps involving 3
    large_gaps = [(p, q, g) for p, q, g in gaps if p > 3]
    
    mod6_counts = Counter()
    state_transition = defaultdict(Counter)
    
    for p, q, g in large_gaps:
        mod6_counts[g % 6] += 1
        state_transition[p % 6][q % 6] += 1
    
    print("Gap mod 6 distribution (primes > 3):")
    for r in sorted(mod6_counts.keys()):
        print(f"  gap ≡ {r} (mod 6): {mod6_counts[r]} occurrences")
    
    print("\nVerification: only residues 0, 2, 4 appear:", 
          set(mod6_counts.keys()) <= {0, 2, 4})
    
    print("\nState transitions (p%6 → q%6):")
    for s1 in [1, 5]:
        for s2 in [1, 5]:
            print(f"  {s1} → {s2}: {state_transition[s1][s2]} times")
    print()


def demo_primorial_automaton():
    """Analyze the mod-30 primorial automaton."""
    print("=" * 60)
    print("DEMO 3: Primorial Automaton (mod 30)")
    print("=" * 60)
    
    admissible = {1, 7, 11, 13, 17, 19, 23, 29}
    print(f"Admissible residues mod 30: {sorted(admissible)}")
    print(f"Count: {len(admissible)} = φ(30)")
    
    # Compute admissible gaps from each state
    print("\nAdmissible gaps (mod 30) from each state:")
    for r in sorted(admissible):
        gaps = [g for g in range(1, 31) if (r + g) % 30 in admissible]
        print(f"  State {r:2d}: gaps = {gaps} ({len(gaps)} options)")
    
    # Verify all primes > 5 land in admissible residues
    violations = 0
    for p in primerange(7, 100_000):
        if p % 30 not in admissible:
            violations += 1
    print(f"\nPrimes 7..100000 violating mod-30 admissibility: {violations}")
    
    # Actual gap distribution mod 30
    gaps = prime_gaps(100_000)
    large_gaps = [(p, q, g) for p, q, g in gaps if p > 5]
    mod30_gaps = Counter(g % 30 for _, _, g in large_gaps)
    print(f"\nGap mod 30 distribution (first 10000 gaps, primes > 5):")
    for r in sorted(mod30_gaps.keys()):
        print(f"  gap ≡ {r:2d} (mod 30): {mod30_gaps[r]:5d}")
    print()


def demo_three_prime_span():
    """Verify the three-prime span theorem."""
    print("=" * 60)
    print("DEMO 4: Three-Prime Span Theorem")
    print("=" * 60)
    
    primes = list(primerange(5, 1_000_000))
    min_span = float('inf')
    min_triple = None
    span_counts = Counter()
    
    for i in range(len(primes) - 2):
        span = primes[i+2] - primes[i]
        span_counts[span] += 1
        if span < min_span:
            min_span = span
            min_triple = (primes[i], primes[i+1], primes[i+2])
    
    print(f"Minimum span among consecutive prime triples > 3: {min_span}")
    print(f"Achieved by: {min_triple}")
    print(f"\nSpan distribution (first 10 values):")
    for span in sorted(span_counts.keys())[:10]:
        print(f"  span = {span:3d}: {span_counts[span]:6d} triples")
    
    assert min_span >= 6, "THREE-PRIME SPAN THEOREM VIOLATED!"
    print(f"\n✓ Theorem verified: all spans ≥ 6\n")


def demo_twin_prime_forcing():
    """Verify that after twin primes, the next gap ≥ 4."""
    print("=" * 60)
    print("DEMO 5: Twin Prime Forcing Rule")
    print("=" * 60)
    
    gaps = prime_gaps(10_000_000)
    twin_next_gaps = []
    
    for i in range(len(gaps) - 1):
        p, q, g1 = gaps[i]
        _, r, g2 = gaps[i + 1]
        if g1 == 2 and p > 3:
            twin_next_gaps.append(g2)
    
    if twin_next_gaps:
        min_next = min(twin_next_gaps)
        next_counter = Counter(twin_next_gaps)
        print(f"Twin primes found (p > 3): {len(twin_next_gaps)}")
        print(f"Minimum next gap after twin pair: {min_next}")
        print(f"\nNext gap distribution after twin primes:")
        for g in sorted(next_counter.keys())[:8]:
            print(f"  gap = {g:3d}: {next_counter[g]:6d} times")
        
        assert min_next >= 4, "TWIN PRIME FORCING RULE VIOLATED!"
        print(f"\n✓ Theorem verified: all next gaps ≥ 4\n")


def demo_forcing_patterns():
    """Search for forcing patterns in the mod-30 automaton."""
    print("=" * 60)
    print("DEMO 6: Forcing Pattern Search (mod 30)")
    print("=" * 60)
    
    admissible = {1, 7, 11, 13, 17, 19, 23, 29}
    
    def admissible_next_gaps(state: int, bound: int) -> list[int]:
        """Find admissible even gaps from state within bound."""
        return [g for g in range(2, bound + 1, 2) 
                if (state + g) % 30 in admissible]
    
    forcing_count = 0
    print(f"Searching for forcing patterns (bound B = 6)...")
    
    for start_state in sorted(admissible):
        for g1 in range(2, 31, 2):
            s1 = (start_state + g1) % 30
            if s1 not in admissible:
                continue
            for g2 in range(2, 31, 2):
                s2 = (s1 + g2) % 30
                if s2 not in admissible:
                    continue
                next_gaps = admissible_next_gaps(s2, 6)
                if len(next_gaps) == 1:
                    if forcing_count < 5:
                        print(f"  State {start_state} → [{g1}, {g2}] → "
                              f"state {s2}: forced gap = {next_gaps[0]}")
                    forcing_count += 1
    
    print(f"\nTotal forcing patterns found (depth 2, bound 6): {forcing_count}")
    print()


if __name__ == "__main__":
    demo_no_prime_triplet()
    demo_mod6_grammar()
    demo_primorial_automaton()
    demo_three_prime_span()
    demo_twin_prime_forcing()
    demo_forcing_patterns()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Prime Gap Mod-6 Grammar State Machine

Creates a visualization of the two-state Markov chain governing
prime gap residues modulo 6.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from sympy import primerange
from collections import Counter


def compute_transition_probs(limit: int = 1_000_000) -> dict:
    """Compute empirical transition probabilities for the mod-6 state machine."""
    primes = list(primerange(5, limit))
    transitions = Counter()
    state_counts = Counter()
    
    for i in range(len(primes) - 1):
        s1 = primes[i] % 6
        s2 = primes[i+1] % 6
        transitions[(s1, s2)] += 1
        state_counts[s1] += 1
    
    probs = {}
    for (s1, s2), count in transitions.items():
        probs[(s1, s2)] = count / state_counts[s1]
    
    return probs


def plot_state_machine():
    """Plot the mod-6 prime gap state machine with transition probabilities."""
    probs = compute_transition_probs()
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left: State machine diagram
    ax = axes[0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Mod-6 Prime Gap State Machine', fontsize=14, fontweight='bold')
    
    # Draw states
    circle1 = plt.Circle((-0.8, 0), 0.4, fill=True, facecolor='#3498db',
                         edgecolor='black', linewidth=2, alpha=0.8)
    circle2 = plt.Circle((0.8, 0), 0.4, fill=True, facecolor='#e74c3c',
                         edgecolor='black', linewidth=2, alpha=0.8)
    ax.add_patch(circle1)
    ax.add_patch(circle2)
    ax.text(-0.8, 0, 'State 1\np ≡ 1\n(mod 6)', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')
    ax.text(0.8, 0, 'State 5\np ≡ 5\n(mod 6)', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')
    
    # Self-loops
    arc1 = patches.FancyArrowPatch((-0.8, 0.4), (-0.8, 0.42),
                                    connectionstyle="arc3,rad=-2.5",
                                    arrowstyle='->', mutation_scale=15,
                                    color='#3498db', linewidth=2)
    ax.annotate('', xy=(-1.1, 0.35), xytext=(-0.5, 0.35),
                arrowprops=dict(arrowstyle='->', color='#3498db', lw=2,
                               connectionstyle='arc3,rad=-1.5'))
    ax.text(-0.8, 0.85, f'gap ≡ 0 (mod 6)\n{probs.get((1,1), 0):.1%}',
            ha='center', va='center', fontsize=9, color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#d5e8f0'))
    
    ax.annotate('', xy=(1.1, 0.35), xytext=(0.5, 0.35),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2,
                               connectionstyle='arc3,rad=-1.5'))
    ax.text(0.8, 0.85, f'gap ≡ 0 (mod 6)\n{probs.get((5,5), 0):.1%}',
            ha='center', va='center', fontsize=9, color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f5d5d5'))
    
    # Cross transitions
    ax.annotate('', xy=(0.35, 0.15), xytext=(-0.35, 0.15),
                arrowprops=dict(arrowstyle='->', color='#2ecc71', lw=2.5))
    ax.text(0, 0.35, f'gap ≡ 4 (mod 6)\n{probs.get((1,5), 0):.1%}',
            ha='center', va='center', fontsize=9, color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#d5f0d5'))
    
    ax.annotate('', xy=(-0.35, -0.15), xytext=(0.35, -0.15),
                arrowprops=dict(arrowstyle='->', color='#f39c12', lw=2.5))
    ax.text(0, -0.35, f'gap ≡ 2 (mod 6)\n{probs.get((5,1), 0):.1%}',
            ha='center', va='center', fontsize=9, color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0e8d5'))
    
    # Right: Gap distribution by mod-6 class
    ax2 = axes[1]
    primes = list(primerange(5, 100_000))
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    
    mod6_classes = {0: [], 2: [], 4: []}
    for g in gaps:
        r = g % 6
        if r in mod6_classes:
            mod6_classes[r].append(g)
    
    colors = ['#3498db', '#f39c12', '#2ecc71']
    labels = ['gap ≡ 0 (mod 6)', 'gap ≡ 2 (mod 6)', 'gap ≡ 4 (mod 6)']
    
    gap_range = range(2, 41, 2)
    gap_counts_by_class = {}
    for r, c, label in zip([0, 2, 4], colors, labels):
        counts = Counter(mod6_classes[r])
        values = [counts.get(g, 0) for g in gap_range]
        ax2.bar([g + (r/6 - 0.33)*0.6 for g in gap_range], values,
                width=0.6, color=c, alpha=0.7, label=label)
    
    ax2.set_xlabel('Gap Size', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Gap Distribution by Mod-6 Class\n(primes 5 to 100,000)',
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_xticks(list(gap_range))
    
    plt.tight_layout()
    plt.savefig('viz_gap_grammar.png', dpi=150, bbox_inches='tight')
    print("Saved viz_gap_grammar.png")


if __name__ == "__main__":
    plot_state_machine()


#!/usr/bin/env python3
"""
Visualization: Primorial Automaton Mod-30 Transition Heatmap

Creates a heatmap showing which gap values are admissible from each
state in the mod-30 primorial automaton.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def compute_admissible_residues(modulus: int) -> list[int]:
    """Compute all residues coprime to modulus."""
    return sorted(r for r in range(modulus) if gcd(r, modulus) == 1)


def build_admissibility_matrix(modulus: int, max_gap: int) -> tuple:
    """Build the admissibility matrix for the primorial automaton.
    
    Returns (matrix, states, gaps) where matrix[i][j] = 1 if gap j
    is admissible from state i.
    """
    states = compute_admissible_residues(modulus)
    gaps = list(range(2, max_gap + 1, 2))
    
    matrix = np.zeros((len(states), len(gaps)))
    for i, s in enumerate(states):
        for j, g in enumerate(gaps):
            if gcd((s + g) % modulus, modulus) == 1:
                matrix[i][j] = 1
    
    return matrix, states, gaps


def plot_heatmap():
    """Create the admissibility heatmap."""
    fig, axes = plt.subplots(1, 2, figsize=(18, 6))
    
    # Mod-30 automaton
    matrix30, states30, gaps30 = build_admissibility_matrix(30, 60)
    
    ax = axes[0]
    im = ax.imshow(matrix30, cmap='RdYlGn', aspect='auto', interpolation='nearest')
    ax.set_yticks(range(len(states30)))
    ax.set_yticklabels([str(s) for s in states30])
    ax.set_xticks(range(len(gaps30)))
    ax.set_xticklabels([str(g) for g in gaps30], rotation=45, fontsize=7)
    ax.set_ylabel('State (residue mod 30)', fontsize=12)
    ax.set_xlabel('Gap value', fontsize=12)
    ax.set_title('Mod-30 Primorial Automaton\nGreen = admissible, Red = forbidden',
                fontsize=13, fontweight='bold')
    
    # Add admissible count per state
    for i in range(len(states30)):
        count = int(matrix30[i].sum())
        ax.text(len(gaps30) + 0.5, i, f'{count}', va='center', fontsize=9,
                fontweight='bold', color='#2c3e50')
    
    # Admissibility fraction plot
    ax2 = axes[1]
    primorials = [6, 30, 210]
    labels = ['mod 6\n(2,3)', 'mod 30\n(2,3,5)', 'mod 210\n(2,3,5,7)']
    
    fractions = []
    for m in primorials:
        states = compute_admissible_residues(m)
        total_even_gaps = m // 2  # Even gaps in one period
        avg_admissible = 0
        for s in states:
            admissible = sum(1 for g in range(2, m + 1, 2)
                           if gcd((s + g) % m, m) == 1)
            avg_admissible += admissible
        avg_admissible /= len(states)
        fractions.append(avg_admissible / total_even_gaps)
    
    euler_products = []
    for m, primes_list in [(6, [2, 3]), (30, [2, 3, 5]), (210, [2, 3, 5, 7])]:
        prod = 1.0
        for p in primes_list:
            prod *= (1 - 1/p)
        euler_products.append(prod)
    
    x = range(len(primorials))
    width = 0.35
    bars1 = ax2.bar([xi - width/2 for xi in x], fractions, width,
                    label='Admissible fraction', color='#3498db', alpha=0.8)
    bars2 = ax2.bar([xi + width/2 for xi in x], euler_products, width,
                    label='Euler product ∏(1-1/p)', color='#e74c3c', alpha=0.8)
    
    ax2.set_xticks(list(x))
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_ylabel('Fraction', fontsize=12)
    ax2.set_title('Sieve Rejection Rate\nvs. Euler Product Prediction',
                 fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 0.7)
    
    for bar in bars1:
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                f'{bar.get_height():.3f}', ha='center', fontsize=9)
    for bar in bars2:
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                f'{bar.get_height():.3f}', ha='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('viz_primorial_automaton.png', dpi=150, bbox_inches='tight')
    print("Saved viz_primorial_automaton.png")


if __name__ == "__main__":
    plot_heatmap()
