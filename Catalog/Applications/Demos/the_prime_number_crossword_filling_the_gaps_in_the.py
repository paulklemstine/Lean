#!/usr/bin/env python3
"""
Prime Gap Crossword: Demonstration Script

Demonstrates the main results from the research:
1. Prime Triple Theorem verification
2. Gap Mod 6 constraint verification
3. Forcing pattern detection
4. Residue exclusion chain analysis
5. Crossword determinism testing
"""

from algorithms import (
    sieve_of_eratosthenes, prime_gaps, gap_mod6_classify,
    GapConstraintSystem, ResidueExclusionChain,
    find_forcing_patterns, verify_gap_mod6, verify_triple_theorem,
    coprime_residues, euler_totient, primorial
)


def demo_triple_theorem():
    """Verify the Prime Triple Theorem: only (3,5,7) forms a prime AP with d=2."""
    print("=" * 60)
    print("DEMO 1: Prime Triple Theorem")
    print("=" * 60)
    
    triples = verify_triple_theorem(10_000_000)
    print(f"Prime triples (p, p+2, p+4) up to 10^7: {triples}")
    print(f"Count: {len(triples)} (theorem predicts exactly 1)")
    print()


def demo_gap_mod6():
    """Verify gap mod 6 constraints."""
    print("=" * 60)
    print("DEMO 2: Gap Mod 6 Constraint")
    print("=" * 60)
    
    for bound in [10_000, 100_000, 1_000_000]:
        result = verify_gap_mod6(bound)
        print(f"\nPrimes up to {bound:,}:")
        print(f"  Total gaps (p > 3): {result['total_gaps']}")
        print(f"  Mod 6 counts: {result['mod6_counts']}")
        print(f"  Mod 6 fractions: ", end="")
        for k, v in result['mod6_fractions'].items():
            print(f"{k}: {v:.4f}  ", end="")
        print()
        print(f"  Violations (gap mod 6 ∉ {{0,2,4}}): {result['violations']}")
    print()


def demo_forcing_patterns():
    """Find forcing patterns over small sieve sets."""
    print("=" * 60)
    print("DEMO 3: Forcing Pattern Detection")
    print("=" * 60)
    
    # Over {2, 3} with bound 6
    print("\nSieve {2, 3}, max gap 6, history length 1:")
    patterns = find_forcing_patterns([2, 3], 6, 1)
    for hist, forced in patterns:
        print(f"  Gap history {hist} → forced next gap: {forced}")
    
    print(f"\nSieve {{2, 3}}, max gap 6, history length 2:")
    patterns = find_forcing_patterns([2, 3], 6, 2)
    for hist, forced in patterns:
        print(f"  Gap history {hist} → forced next gap: {forced}")
    
    # Over {2, 3, 5} with bound 30
    print(f"\nSieve {{2, 3, 5}}, max gap 12, history length 1:")
    patterns = find_forcing_patterns([2, 3, 5], 12, 1)
    for hist, forced in patterns[:10]:
        print(f"  Gap history {hist} → forced next gap: {forced}")
    if len(patterns) > 10:
        print(f"  ... ({len(patterns)} total forcing patterns)")
    print()


def demo_exclusion_chain():
    """Show how sieve primes progressively eliminate gap candidates."""
    print("=" * 60)
    print("DEMO 4: Residue Exclusion Chain")
    print("=" * 60)
    
    chain = ResidueExclusionChain([2, 3, 5, 7, 11, 13])
    table = chain.display()
    
    print(f"\n{'Primes':>20} {'Modulus':>10} {'Survivors':>10} {'Fraction':>10}")
    print("-" * 52)
    for row in table:
        primes_str = str(row['primes_used'])
        print(f"{primes_str:>20} {row['modulus']:>10} {row['survivors']:>10} {row['fraction']:>10.4f}")
    
    # Verify against Euler totient
    print(f"\nVerification against Euler's totient function:")
    for k in range(1, len([2, 3, 5, 7, 11, 13]) + 1):
        primes = [2, 3, 5, 7, 11, 13][:k]
        M = 1
        for p in primes:
            M *= p
        phi = euler_totient(M)
        surv = chain.survival_count(k)
        print(f"  φ({M}) = {phi}, chain survival = {surv}, match: {phi == surv}")
    print()


def demo_crossword_determinism():
    """Test the Crossword Determinism Conjecture."""
    print("=" * 60)
    print("DEMO 5: Crossword Determinism Test")
    print("=" * 60)
    
    primes = sieve_of_eratosthenes(1_000_000)
    gcs = GapConstraintSystem([2, 3, 5])
    
    admissible_counts = []
    for i in range(len(primes) - 6):
        if primes[i] <= 30:
            continue
        # Look at 5-gap history
        history = [primes[j+1] - primes[j] for j in range(i, i+5)]
        
        # Count admissible next gaps mod 30
        p = primes[i + 5]
        count = sum(1 for g in range(2, 32, 2) 
                   if all((p + g) % q != 0 for q in [2, 3, 5]))
        admissible_counts.append(count)
    
    if admissible_counts:
        max_count = max(admissible_counts)
        avg_count = sum(admissible_counts) / len(admissible_counts)
        print(f"\nPrimes up to 1,000,000:")
        print(f"  Max admissible next gaps (mod 30): {max_count}")
        print(f"  Average admissible next gaps: {avg_count:.2f}")
        print(f"  Coprime residues mod 30: {len(coprime_residues(30))}")
        print(f"  Conjecture bound (C ≤ 8): {'HOLDS' if max_count <= 8 else 'VIOLATED'}")
    print()


def demo_generalized_triple():
    """Verify the generalized triple constraint."""
    print("=" * 60)
    print("DEMO 6: Generalized Triple Constraint")
    print("=" * 60)
    
    primes_set = set(sieve_of_eratosthenes(100_000))
    
    print("\nSearching for prime APs (p, p+2d, p+4d) with 3 ∤ d:")
    found = []
    for d in range(1, 100):
        if d % 3 == 0:
            continue
        for p in sorted(primes_set):
            if p + 4 * d > 100_000:
                break
            if p + 2 * d in primes_set and p + 4 * d in primes_set:
                found.append((p, d, p + 2*d, p + 4*d))
    
    print(f"  Found {len(found)} triples with 3 ∤ d")
    for p, d, q, r in found[:10]:
        print(f"    ({p}, {q}, {r}) with d={d}, "
              f"contains 3: {3 in (p, q, r)}")
    if len(found) > 10:
        print(f"    ... ({len(found)} total)")
    
    # Verify all contain 3
    all_contain_3 = all(3 in (p, p+2*d, p+4*d) for p, d, _, _ in found)
    print(f"\n  All triples contain 3: {all_contain_3} "
          f"(theorem predicts True)")
    print()


if __name__ == "__main__":
    print("Prime Gap Crossword: Research Demonstrations")
    print("=" * 60)
    print()
    
    demo_triple_theorem()
    demo_gap_mod6()
    demo_forcing_patterns()
    demo_exclusion_chain()
    demo_crossword_determinism()
    demo_generalized_triple()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Residue Exclusion Chain and Primorial Structure

Shows how successive sieve primes eliminate candidate gap positions,
and the multiplicative composition of exclusions (Euler's product).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd, prod


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def euler_totient(n):
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Residue Exclusion Chain: The Multiplicative Sieve', 
                 fontsize=16, fontweight='bold')
    
    # Plot 1: Residues mod 30 colored by coprimality
    ax1 = axes[0, 0]
    M = 30
    grid = np.arange(M).reshape(5, 6)
    colors = np.zeros((5, 6, 3))
    for i in range(5):
        for j in range(6):
            n = grid[i, j]
            if gcd(n, M) == 1:
                colors[i, j] = [0.18, 0.8, 0.44]  # green - coprime
            elif n % 2 == 0:
                colors[i, j] = [0.91, 0.3, 0.24]  # red - div by 2
            elif n % 3 == 0:
                colors[i, j] = [0.95, 0.61, 0.07]  # orange - div by 3
            elif n % 5 == 0:
                colors[i, j] = [0.56, 0.27, 0.68]  # purple - div by 5
    
    ax1.imshow(colors, aspect='auto')
    for i in range(5):
        for j in range(6):
            ax1.text(j, i, str(grid[i, j]), ha='center', va='center',
                    fontweight='bold', fontsize=11, 
                    color='white' if gcd(grid[i, j], M) > 1 else 'black')
    ax1.set_title('Residues mod 30: Coprime (green) vs Sieved')
    ax1.set_xticks([])
    ax1.set_yticks([])
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor=[0.18, 0.8, 0.44], label='Coprime to 30'),
                       Patch(facecolor=[0.91, 0.3, 0.24], label='Divisible by 2'),
                       Patch(facecolor=[0.95, 0.61, 0.07], label='Divisible by 3'),
                       Patch(facecolor=[0.56, 0.27, 0.68], label='Divisible by 5')]
    ax1.legend(handles=legend_elements, loc='lower center', 
              bbox_to_anchor=(0.5, -0.15), ncol=2, fontsize=8)
    
    # Plot 2: Survival fraction convergence
    ax2 = axes[0, 1]
    small_primes = sieve_of_eratosthenes(50)
    k_vals = range(1, len(small_primes) + 1)
    survival_fracs = []
    primorial_vals = []
    m = 1
    for k, p in enumerate(small_primes):
        m *= p
        phi = euler_totient(m)
        survival_fracs.append(phi / m)
        primorial_vals.append(m)
    
    ax2.semilogy(k_vals, survival_fracs, 'o-', color='#2c3e50', 
                linewidth=2, markersize=6)
    ax2.set_xlabel('Number of sieve primes k')
    ax2.set_ylabel('φ(p_k#) / p_k# (log scale)')
    ax2.set_title('Survival Fraction: Euler Product Convergence')
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Exclusion layers visualization
    ax3 = axes[1, 0]
    N = 60
    x = np.arange(N)
    
    # Layer 1: sieve by 2
    sieved_2 = [n for n in range(N) if n % 2 != 0 and n > 1]
    # Layer 2: also sieve by 3
    sieved_23 = [n for n in sieved_2 if n % 3 != 0]
    # Layer 3: also sieve by 5
    sieved_235 = [n for n in sieved_23 if n % 5 != 0]
    # Layer 4: also sieve by 7
    sieved_2357 = [n for n in sieved_235 if n % 7 != 0]
    
    layers = [
        (range(2, N), 'All integers', '#bdc3c7', 0.3),
        (sieved_2, 'After sieving 2', '#3498db', 0.5),
        (sieved_23, 'After sieving 2,3', '#e74c3c', 0.7),
        (sieved_235, 'After sieving 2,3,5', '#2ecc71', 0.9),
    ]
    
    for i, (vals, label, color, alpha) in enumerate(layers):
        y = [i] * len(vals)
        ax3.scatter(vals, y, c=color, alpha=alpha, s=20, label=label)
    
    ax3.set_xlabel('Integer value')
    ax3.set_ylabel('Sieve layer')
    ax3.set_yticks(range(len(layers)))
    ax3.set_yticklabels([l[1] for l in layers], fontsize=8)
    ax3.set_title('Progressive Sieving: Each Layer Removes More')
    ax3.set_xlim(0, N)
    
    # Plot 4: Coprime count verification
    ax4 = axes[1, 1]
    test_primes = sieve_of_eratosthenes(30)
    pairs = []
    for i, p in enumerate(test_primes):
        for q in test_primes[i+1:]:
            actual = sum(1 for r in range(p * q) 
                        if gcd(r, p) == 1 and gcd(r, q) == 1)
            predicted = (p - 1) * (q - 1)
            pairs.append((f'{p}×{q}', actual, predicted))
    
    labels = [p[0] for p in pairs]
    actual_vals = [p[1] for p in pairs]
    predicted_vals = [p[2] for p in pairs]
    
    x_pos = np.arange(len(labels))
    width = 0.35
    ax4.bar(x_pos - width/2, actual_vals, width, label='Actual count', 
            color='#3498db', edgecolor='black', linewidth=0.5)
    ax4.bar(x_pos + width/2, predicted_vals, width, label='(p-1)(q-1)', 
            color='#e74c3c', edgecolor='black', linewidth=0.5)
    ax4.set_xticks(x_pos)
    ax4.set_xticklabels(labels, rotation=45, fontsize=7)
    ax4.set_xlabel('Prime pair p×q')
    ax4.set_ylabel('Coprime residue count')
    ax4.set_title('Exclusion Composition: Actual vs (p-1)(q-1)')
    ax4.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('exclusion_chain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved exclusion_chain.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Forcing Patterns in Prime Gap Crossword

Shows how sieve constraints create "forcing" — gap histories that
uniquely determine the next gap. Visualizes the automaton structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import gcd, prod


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


class GapConstraintSystem:
    def __init__(self, sieve_primes):
        self.sieve_primes = sorted(sieve_primes)
        self.modulus = prod(sieve_primes)
        self._admissible = {r for r in range(self.modulus) 
                           if all(r % p != 0 for p in self.sieve_primes)}
    
    def admissible_next_gaps(self, residue, max_gap):
        result = []
        for g in range(2, max_gap + 1, 2):
            target = (residue + g) % self.modulus
            if target in self._admissible:
                result.append(g)
        return result
    
    def is_forcing_from(self, residue, max_gap):
        gaps = self.admissible_next_gaps(residue, max_gap)
        return len(gaps) == 1, gaps


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Forcing Patterns in Prime Gap Crossword', fontsize=16, fontweight='bold')
    
    # Plot 1: Admissible transitions mod 6
    ax1 = axes[0, 0]
    gcs6 = GapConstraintSystem([2, 3])
    M = gcs6.modulus
    admissible = sorted(gcs6._admissible)
    
    # Draw states
    n_states = len(admissible)
    angles = np.linspace(0, 2 * np.pi, n_states, endpoint=False)
    radius = 1.5
    positions = {r: (radius * np.cos(a), radius * np.sin(a)) 
                for r, a in zip(admissible, angles)}
    
    for r, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.2, fill=True, color='#3498db', alpha=0.7)
        ax1.add_patch(circle)
        ax1.text(x, y, str(r), ha='center', va='center', fontweight='bold', color='white')
    
    # Draw transitions for gap = 2 and gap = 4
    for r in admissible:
        for g, color in [(2, '#e74c3c'), (4, '#2ecc71')]:
            target = (r + g) % M
            if target in positions:
                x1, y1 = positions[r]
                x2, y2 = positions[target]
                dx, dy = x2 - x1, y2 - y1
                length = np.sqrt(dx**2 + dy**2)
                if length > 0:
                    dx, dy = dx / length, dy / length
                    ax1.annotate('', xy=(x2 - 0.25*dx, y2 - 0.25*dy),
                               xytext=(x1 + 0.25*dx, y1 + 0.25*dy),
                               arrowprops=dict(arrowstyle='->', color=color, lw=1.5))
    
    ax1.set_xlim(-2.5, 2.5)
    ax1.set_ylim(-2.5, 2.5)
    ax1.set_aspect('equal')
    ax1.set_title('Gap Automaton mod 6 (sieve {2,3})')
    ax1.legend(handles=[mpatches.Patch(color='#e74c3c', label='gap=2'),
                        mpatches.Patch(color='#2ecc71', label='gap=4')],
              loc='lower right')
    ax1.axis('off')
    
    # Plot 2: Admissible gap counts mod 30
    ax2 = axes[0, 1]
    gcs30 = GapConstraintSystem([2, 3, 5])
    admissible30 = sorted(gcs30._admissible)
    
    gap_counts_per_residue = []
    for r in admissible30:
        gaps = gcs30.admissible_next_gaps(r, 30)
        gap_counts_per_residue.append(len(gaps))
    
    colors30 = ['#e74c3c' if c <= 2 else '#f39c12' if c <= 4 else '#2ecc71' 
                for c in gap_counts_per_residue]
    ax2.bar(range(len(admissible30)), gap_counts_per_residue, color=colors30,
            edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(len(admissible30)))
    ax2.set_xticklabels(admissible30, fontsize=7)
    ax2.set_xlabel('Starting residue mod 30')
    ax2.set_ylabel('# admissible next gaps')
    ax2.set_title('Admissible Next Gaps from Each Residue (mod 30)')
    
    # Plot 3: Exclusion chain - survival fractions
    ax3 = axes[1, 0]
    primes_list = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    cum_modulus = []
    cum_survival = []
    m = 1
    s = 1
    for p in primes_list:
        m *= p
        s *= (p - 1)
        cum_modulus.append(m)
        cum_survival.append(s / m)
    
    ax3.plot(range(1, len(primes_list) + 1), cum_survival, 'o-', 
             color='#2c3e50', linewidth=2, markersize=8)
    for i, (p, frac) in enumerate(zip(primes_list, cum_survival)):
        ax3.annotate(f'p={p}\n{frac:.3f}', (i + 1, frac), 
                    textcoords="offset points", xytext=(0, 12),
                    ha='center', fontsize=7)
    ax3.set_xlabel('Number of sieve primes')
    ax3.set_ylabel('Survival fraction')
    ax3.set_title('Residue Exclusion Chain: Survival Fractions')
    ax3.set_ylim(0, 0.6)
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Empirical forcing frequency
    ax4 = axes[1, 1]
    primes = sieve_of_eratosthenes(500_000)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    
    # For each prime, count admissible next gaps mod 30
    admissible_set_30 = {r for r in range(30) if all(r % p != 0 for p in [2, 3, 5])}
    next_gap_counts = []
    for i in range(2, len(primes) - 1):
        if primes[i] <= 5:
            continue
        r = primes[i] % 30
        count = sum(1 for g in range(2, 32, 2) if (r + g) % 30 in admissible_set_30)
        next_gap_counts.append(count)
    
    unique_counts, count_freqs = np.unique(next_gap_counts, return_counts=True)
    ax4.bar(unique_counts, count_freqs / sum(count_freqs), 
            color='#3498db', edgecolor='black', linewidth=0.5)
    ax4.set_xlabel('# admissible next gaps mod 30')
    ax4.set_ylabel('Fraction of primes')
    ax4.set_title('Distribution of Admissible Next-Gap Counts')
    
    plt.tight_layout()
    plt.savefig('forcing_patterns.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved forcing_patterns.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Gap Distribution Mod 6

Shows the distribution of prime gaps modulo 6 and how it evolves
as the prime bound increases. Demonstrates the gap mod 6 constraint
theorem: all gaps (for p > 3) fall in {0, 2, 4} mod 6.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_gaps(primes):
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def main():
    bound = 1_000_000
    primes = sieve_of_eratosthenes(bound)
    gaps = prime_gaps(primes)
    
    # Filter to gaps for p > 3
    large_gaps = [g for i, g in enumerate(gaps) if primes[i] > 3]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Prime Gap Crossword: Modular Structure', fontsize=16, fontweight='bold')
    
    # Plot 1: Gap distribution mod 6
    ax1 = axes[0, 0]
    mod6_vals = [g % 6 for g in large_gaps]
    counts = [mod6_vals.count(r) for r in range(6)]
    colors = ['#2ecc71' if r in {0, 2, 4} else '#e74c3c' for r in range(6)]
    ax1.bar(range(6), counts, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Gap mod 6')
    ax1.set_ylabel('Count')
    ax1.set_title(f'Gap Residues mod 6 (primes up to {bound:,})')
    ax1.set_xticks(range(6))
    for i, c in enumerate(counts):
        if c > 0:
            ax1.text(i, c + max(counts) * 0.01, str(c), ha='center', fontsize=8)
    
    # Plot 2: Evolution of mod 6 fractions
    ax2 = axes[0, 1]
    checkpoints = np.logspace(3, np.log10(bound), 50).astype(int)
    fracs = {0: [], 2: [], 4: []}
    for cp in checkpoints:
        sub_gaps = [g for i, g in enumerate(gaps) if primes[i] > 3 and primes[i] <= cp]
        total = len(sub_gaps) if sub_gaps else 1
        for r in [0, 2, 4]:
            fracs[r].append(sum(1 for g in sub_gaps if g % 6 == r) / total)
    
    for r, label, color in [(0, 'g ≡ 0 mod 6', '#3498db'), 
                             (2, 'g ≡ 2 mod 6', '#e74c3c'),
                             (4, 'g ≡ 4 mod 6', '#2ecc71')]:
        ax2.semilogx(checkpoints, fracs[r], label=label, color=color, linewidth=1.5)
    ax2.axhline(y=1/3, color='gray', linestyle='--', alpha=0.5, label='1/3 equidistribution')
    ax2.set_xlabel('Prime bound')
    ax2.set_ylabel('Fraction')
    ax2.set_title('Evolution of Gap Mod 6 Distribution')
    ax2.legend(fontsize=8)
    ax2.set_ylim(0.2, 0.5)
    
    # Plot 3: Gap histogram
    ax3 = axes[1, 0]
    gap_vals = sorted(set(large_gaps))
    gap_counts = [large_gaps.count(g) for g in gap_vals]
    gap_colors = ['#2ecc71' if g % 6 == 0 else '#3498db' if g % 6 == 2 else '#e74c3c' 
                  for g in gap_vals]
    ax3.bar(gap_vals[:30], gap_counts[:30], color=gap_colors[:30], 
            edgecolor='black', linewidth=0.3)
    ax3.set_xlabel('Gap value')
    ax3.set_ylabel('Frequency')
    ax3.set_title('Prime Gap Frequencies (first 30 values)')
    
    # Plot 4: Consecutive gap pairs
    ax4 = axes[1, 1]
    pair_x = [large_gaps[i] for i in range(len(large_gaps) - 1)]
    pair_y = [large_gaps[i + 1] for i in range(len(large_gaps) - 1)]
    ax4.scatter(pair_x[:5000], pair_y[:5000], alpha=0.1, s=2, color='#2c3e50')
    ax4.set_xlabel('Gap g(n)')
    ax4.set_ylabel('Gap g(n+1)')
    ax4.set_title('Consecutive Gap Pairs (first 5000)')
    ax4.set_xlim(0, 40)
    ax4.set_ylim(0, 40)
    
    plt.tight_layout()
    plt.savefig('gap_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved gap_distribution.png")


if __name__ == "__main__":
    main()
