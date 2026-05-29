#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Prime Gap Crossword framework.

Demonstrates how modular sieve constraints predict and constrain prime gap patterns.

Applications:
1. Prime constellation verification
2. Gap pattern prediction engine
3. Admissibility testing for Goldbach-type problems
"""

from math import prod
from typing import List, Set, Dict, Tuple, Optional


# ── Self-contained core algorithms ──────────────────────────────────────

def sieve_primes(limit: int) -> List[int]:
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos


def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior


def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    inter = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in inter:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True


def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))


def admissible_residues(S: Set[int], gaps: List[int]) -> List[int]:
    M = prod(S) if S else 1
    return [a for a in range(M) if is_admissible_at(S, gaps, a)]


def next_gaps(S: Set[int], word: List[int], max_gap: int = 30) -> Set[int]:
    return {g for g in range(1, max_gap + 1) if admissible_over(S, word + [g])}


# ── Application 1: Prime Constellation Verification ─────────────────────

def verify_constellation(offsets: List[int], sieve_depth: int = 7) -> Dict:
    """
    Verify if a prime constellation pattern is admissible under sieve constraints.

    A prime constellation (like twin primes [0,2] or prime triplets [0,2,6])
    is admissible if there exist infinitely many integers n such that
    n+offset is not divisible by any small prime, for all offsets.

    Args:
        offsets: List of offsets defining the constellation (starting from 0).
        sieve_depth: Check primes up to this value.

    Returns:
        Dictionary with admissibility results for increasing sieve sets.
    """
    primes = sieve_primes(sieve_depth)
    gaps = [offsets[i + 1] - offsets[i] for i in range(len(offsets) - 1)]

    results = {}
    for k in range(1, len(primes) + 1):
        S = set(primes[:k])
        is_adm = admissible_over(S, gaps)
        residues = admissible_residues(S, gaps)
        M = prod(S)
        results[tuple(sorted(S))] = {
            "admissible": is_adm,
            "residues": residues,
            "modulus": M,
            "density": len(residues) / M if M > 0 else 0,
        }
    return results


# ── Application 2: Gap Pattern Prediction Engine ─────────────────────────

def predict_next_gap(observed_gaps: List[int],
                     sieve_sets: Optional[List[Set[int]]] = None,
                     max_gap: int = 30) -> Dict:
    """
    Given a sequence of observed prime gaps, predict the next gap
    using sieve constraints of increasing strength.

    Args:
        observed_gaps: List of consecutive prime gaps observed.
        sieve_sets: List of sieve sets to try (default: increasing primes).
        max_gap: Maximum gap to consider.

    Returns:
        Predictions from each sieve level.
    """
    if sieve_sets is None:
        sieve_sets = [
            {2, 3},
            {2, 3, 5},
            {2, 3, 5, 7},
            {2, 3, 5, 7, 11},
        ]

    predictions = {}
    for S in sieve_sets:
        label = "{" + ",".join(str(q) for q in sorted(S)) + "}"
        if not admissible_over(S, observed_gaps):
            predictions[label] = {"status": "inadmissible", "gaps": set()}
            continue

        ng = next_gaps(S, observed_gaps, max_gap)
        forced = len(ng) == 1
        predictions[label] = {
            "status": "forcing" if forced else "ambiguous",
            "gaps": sorted(ng),
            "forced_gap": ng.pop() if forced else None,
        }

    return predictions


# ── Application 3: Constellation Density Estimation ──────────────────────

def constellation_sieve_density(offsets: List[int],
                                max_prime: int = 30) -> List[Tuple[int, float]]:
    """
    Compute the sieve-theoretic density of a prime constellation
    as the sieve depth increases.

    This implements a simplified version of the Hardy-Littlewood
    singular series computation via direct residue counting.

    Args:
        offsets: Constellation offsets.
        max_prime: Maximum sieve prime.

    Returns:
        List of (sieve_depth, density) pairs.
    """
    primes = sieve_primes(max_prime)
    gaps = [offsets[i + 1] - offsets[i] for i in range(len(offsets) - 1)]

    densities = []
    S: Set[int] = set()
    for p in primes:
        S.add(p)
        M = prod(S)
        residues = admissible_residues(S, gaps)
        k = len(offsets)

        # Normalized density: compare to random model
        # Random model: each position independently has prob (M - sum(1/q)) / M of avoiding S
        coprime_count = sum(1 for r in range(M) if all(r % q != 0 for q in S))
        random_density = (coprime_count / M) ** k if M > 0 else 1
        actual_density = len(residues) / M if M > 0 else 1

        ratio = actual_density / random_density if random_density > 0 else float('inf')
        densities.append((p, ratio))

    return densities


# ── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("   APPLICATIONS OF THE PRIME GAP CROSSWORD FRAMEWORK")
    print("=" * 70)

    # Application 1: Verify well-known constellations
    print("\n─── Application 1: Prime Constellation Verification ───\n")

    constellations = {
        "Twin primes": [0, 2],
        "Prime triplet (0,2,6)": [0, 2, 6],
        "Prime triplet (0,4,6)": [0, 4, 6],
        "Prime quadruplet": [0, 2, 6, 8],
        "Sexy primes": [0, 6],
        "INADMISSIBLE triplet (0,2,4)": [0, 2, 4],
    }

    for name, offsets in constellations.items():
        results = verify_constellation(offsets, sieve_depth=11)
        is_adm = all(r["admissible"] for r in results.values())
        status = "✓ ADMISSIBLE" if is_adm else "✗ INADMISSIBLE"
        print(f"  {name}: {offsets} — {status}")

        # Show where it fails
        if not is_adm:
            for S_tuple, r in results.items():
                if not r["admissible"]:
                    print(f"    Fails at S = {set(S_tuple)}")
                    break

    # Application 2: Prediction engine
    print("\n─── Application 2: Gap Pattern Prediction ───\n")

    test_sequences = [
        [2, 4, 2],
        [6, 4, 2],
        [2, 6],
        [10],
    ]

    for seq in test_sequences:
        print(f"  Observed gaps: {seq}")
        preds = predict_next_gap(seq)
        for label, pred in preds.items():
            if pred["status"] == "forcing":
                print(f"    {label}: FORCED → {pred['forced_gap']}")
            elif pred["status"] == "ambiguous":
                print(f"    {label}: possible → {pred['gaps']}")
            else:
                print(f"    {label}: inadmissible")
        print()

    # Application 3: Density analysis
    print("─── Application 3: Constellation Density (Singular Series Ratio) ───\n")

    for name, offsets in [("Twin primes", [0, 2]),
                          ("Prime quadruplet", [0, 2, 6, 8])]:
        densities = constellation_sieve_density(offsets, max_prime=20)
        print(f"  {name}: {offsets}")
        for p, ratio in densities:
            print(f"    After sieving by primes ≤ {p}: density ratio = {ratio:.4f}")
        print()


#!/usr/bin/env python3
"""
demo.py — Interactive exploration of the Prime Gap Crossword.

Demonstrates the core phenomena:
1. Enumerates prime gaps from actual primes
2. Searches for forcing patterns in finite sieve models
3. Compares sieve predictions against empirical prime data
4. Interactive mode: enter a gap word, get sieve-predicted next gaps

Usage:
    python demo.py           # Full demo
    python demo.py --interactive  # Interactive mode
"""

import sys
from math import prod
from itertools import product as cartesian_product
from typing import List, Set, Dict, Tuple, Optional


# ── Sieve of Eratosthenes ──────────────────────────────────────────────
def sieve_primes(limit: int) -> List[int]:
    """Generate all primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


# ── Core crossword algorithms (self-contained) ─────────────────────────

def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos


def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior


def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    interior = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in interior:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True


def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))


def next_gaps(S: Set[int], word: List[int], max_gap: int = 30) -> Set[int]:
    return {g for g in range(1, max_gap + 1)
            if admissible_over(S, word + [g])}


def is_forcing(S: Set[int], word: List[int], max_gap: int = 30) -> Optional[int]:
    gaps = next_gaps(S, word, max_gap)
    return gaps.pop() if len(gaps) == 1 else None


def find_forcing_patterns(S: Set[int], max_word_len: int = 3,
                          max_gap: int = 20) -> List[Tuple[List[int], int]]:
    even_gaps = list(range(2, max_gap + 1, 2))
    patterns = []
    for length in range(1, max_word_len + 1):
        for wt in cartesian_product(even_gaps, repeat=length):
            w = list(wt)
            if not admissible_over(S, w):
                continue
            forced = is_forcing(S, w, max_gap)
            if forced is not None:
                patterns.append((w, forced))
    return patterns


# ── Empirical analysis ──────────────────────────────────────────────────

def prime_gaps(limit: int) -> List[int]:
    primes = sieve_primes(limit)
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def empirical_next_gap(gaps_data: List[int], word: List[int]) -> Dict[int, int]:
    dist: Dict[int, int] = {}
    wlen = len(word)
    for i in range(len(gaps_data) - wlen):
        if gaps_data[i:i + wlen] == word:
            ng = gaps_data[i + wlen]
            dist[ng] = dist.get(ng, 0) + 1
    return dist


# ── Main Demo ───────────────────────────────────────────────────────────

def run_demo():
    print("=" * 70)
    print("   PRIME GAP CROSSWORD — Demonstration")
    print("   Modular sieve constraints as gap-pattern grammar rules")
    print("=" * 70)

    # 1. Generate prime gaps
    LIMIT = 1_000_000
    print(f"\n1. Generating prime gaps up to {LIMIT:,}...")
    gaps_data = prime_gaps(LIMIT)
    # Skip first gap (3-2=1) since we focus on gaps ≥ 2
    gaps_data = gaps_data[1:]  # start from gap between 5 and 3 = 2
    print(f"   {len(gaps_data):,} gaps computed (all even after the first).")
    print(f"   First 20 gaps: {gaps_data[:20]}")

    # 2. Search for forcing patterns
    print("\n" + "=" * 70)
    print("2. FORCING PATTERN SEARCH")
    print("   A 'forcing pattern' is a gap word where the next gap is")
    print("   uniquely determined by modular sieve constraints.")
    print("=" * 70)

    sieve_sets = [
        ({2, 3}, "S = {2, 3}, M = 6"),
        ({2, 3, 5}, "S = {2, 3, 5}, M = 30"),
        ({2, 3, 5, 7}, "S = {2, 3, 5, 7}, M = 210"),
    ]

    all_forcing: List[Tuple[Set[int], List[int], int]] = []

    for S, label in sieve_sets:
        print(f"\n   {label}")
        print(f"   {'─' * 50}")
        patterns = find_forcing_patterns(S, max_word_len=3, max_gap=20)
        for w, g in patterns:
            all_forcing.append((S, w, g))
            marker = "★" if len(w) <= 2 else " "
            print(f"   {marker} {w} → {g}")
        if not patterns:
            print(f"     (no forcing patterns found)")
        print(f"   Total: {len(patterns)} forcing patterns")

    # 3. Compare sieve predictions vs empirical data
    print("\n" + "=" * 70)
    print("3. SIEVE PREDICTIONS vs EMPIRICAL PRIME DATA")
    print("   For each forcing pattern, compare the sieve-forced next gap")
    print("   against the actual distribution of next gaps in prime data.")
    print("=" * 70)

    print(f"\n   {'Word':<16} {'Sieve':<8} {'Primes S':<12} {'Empirical top-3':<35} {'Agreement'}")
    print(f"   {'─'*16} {'─'*8} {'─'*12} {'─'*35} {'─'*10}")

    for S, w, forced_g in all_forcing[:25]:
        emp = empirical_next_gap(gaps_data, w)
        total = sum(emp.values())
        if total == 0:
            continue

        # Sort by frequency
        sorted_emp = sorted(emp.items(), key=lambda x: -x[1])
        top3 = sorted_emp[:3]
        top3_str = ", ".join(f"{g}:{c}" for g, c in top3)

        # Agreement: fraction of times the forced gap actually occurs
        agreement = emp.get(forced_g, 0) / total if total > 0 else 0
        agree_str = f"{agreement:.1%}"

        S_str = "{" + ",".join(str(q) for q in sorted(S)) + "}"
        w_str = str(w)
        print(f"   {w_str:<16} {forced_g:<8} {S_str:<12} {top3_str:<35} {agree_str}")

    # 4. Ambiguity decay analysis
    print("\n" + "=" * 70)
    print("4. AMBIGUITY DECAY ANALYSIS")
    print("   Fraction of admissible words with >1 admissible next gap,")
    print("   as a function of word length. Tests the exponential decay conjecture.")
    print("=" * 70)

    for S, label in sieve_sets[:2]:
        M = prod(S)
        print(f"\n   {label}")
        even_gaps = list(range(2, 14, 2))  # Smaller range for speed
        for length in range(1, 5):
            total = 0
            ambiguous = 0
            for wt in cartesian_product(even_gaps, repeat=length):
                w = list(wt)
                if not admissible_over(S, w):
                    continue
                total += 1
                ng = next_gaps(S, w, 14)
                if len(ng) > 1:
                    ambiguous += 1
            ratio = ambiguous / total if total > 0 else 0
            print(f"     Length {length}: {total} admissible, "
                  f"{ambiguous} ambiguous ({ratio:.1%})")

    # 5. State transition graph
    print("\n" + "=" * 70)
    print("5. STATE TRANSITION GRAPH (mod 6, S = {2,3})")
    print("   Vertices = coprime residues mod 6, edges = admissible gaps")
    print("=" * 70)

    S = {2, 3}
    M = 6
    coprime = [r for r in range(M) if all(r % q != 0 for q in S)]
    print(f"\n   Coprime residues mod 6: {coprime}")
    for a in coprime:
        transitions = []
        for g in range(2, 14, 2):
            if admissible_over(S, [g]) and is_admissible_at(S, [g], a):
                b = (a + g) % M
                transitions.append(f"--{g}-> {b}")
        print(f"   {a}: {', '.join(transitions)}")


def interactive_mode():
    """Interactive mode: enter gap words, get sieve predictions."""
    print("\n" + "=" * 70)
    print("   INTERACTIVE PRIME GAP CROSSWORD")
    print("   Enter a gap word (comma-separated even numbers)")
    print("   and a sieve set to see admissible next gaps.")
    print("   Type 'quit' to exit.")
    print("=" * 70)

    default_sieves = {
        "23": {2, 3},
        "235": {2, 3, 5},
        "2357": {2, 3, 5, 7},
    }

    while True:
        try:
            word_input = input("\n   Gap word (e.g., '2,4,6'): ").strip()
            if word_input.lower() in ('quit', 'exit', 'q'):
                break

            word = [int(x.strip()) for x in word_input.split(',')]

            sieve_input = input("   Sieve primes (e.g., '2,3,5' or press Enter for all): ").strip()
            if not sieve_input:
                sieves_to_check = list(default_sieves.values())
            else:
                sieves_to_check = [{int(x.strip()) for x in sieve_input.split(',')}]

            for S in sieves_to_check:
                S_str = "{" + ",".join(str(q) for q in sorted(S)) + "}"
                if not admissible_over(S, word):
                    print(f"   {S_str}: word is NOT admissible")
                    continue
                ng = next_gaps(S, word, 30)
                forced = is_forcing(S, word, 30)
                if forced is not None:
                    print(f"   {S_str}: FORCING → {forced}")
                else:
                    print(f"   {S_str}: next gaps = {sorted(ng)}")

            # Also show empirical data
            gaps_data = prime_gaps(1_000_000)[1:]
            emp = empirical_next_gap(gaps_data, word)
            if emp:
                total = sum(emp.values())
                sorted_emp = sorted(emp.items(), key=lambda x: -x[1])[:5]
                print(f"   Empirical (primes up to 1M): {total} occurrences")
                for g, c in sorted_emp:
                    print(f"     gap {g}: {c} ({c/total:.1%})")
            else:
                print(f"   Empirical: pattern not found in primes up to 1M")

        except (ValueError, KeyboardInterrupt):
            print("\n   (invalid input or interrupted)")
            break

    print("\n   Goodbye!")


if __name__ == "__main__":
    if "--interactive" in sys.argv:
        interactive_mode()
    else:
        run_demo()
        print("\n\n   Run with --interactive for interactive mode.\n")


#!/usr/bin/env python3
"""
Visualization: Ambiguity Decay in Prime Gap Crosswords

Plots how the fraction of "ambiguous" gap words (those with more than one
admissible next gap) changes as word length increases, for different sieve sets.

This tests the conjecture that ambiguity decays exponentially with word length:
longer patterns increasingly constrain the next gap, eventually forcing it.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod
from itertools import product as cartesian_product
from typing import List, Set

# ── Self-contained core algorithms ──────────────────────────────────────

def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos

def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior

def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    inter = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in inter:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True

def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))

def next_gaps(S: Set[int], word: List[int], max_gap: int = 14) -> Set[int]:
    return {g for g in range(1, max_gap + 1) if admissible_over(S, word + [g])}

# ── Compute ambiguity data ──────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

sieve_configs = [
    ({2, 3, 5}, "{2,3,5}", '#e74c3c'),
    ({2, 3, 5, 7}, "{2,3,5,7}", '#3498db'),
]

max_len = 5
max_gap_val = 12
even_gaps = list(range(2, max_gap_val + 1, 2))

for S, label, color in sieve_configs:
    lengths = []
    ambiguity_ratios = []
    total_admissible_counts = []
    forcing_counts = []

    for length in range(1, max_len + 1):
        total = 0
        ambiguous = 0
        forcing = 0

        for wt in cartesian_product(even_gaps, repeat=length):
            w = list(wt)
            if not admissible_over(S, w):
                continue
            total += 1
            ng = next_gaps(S, w, max_gap_val)
            if len(ng) > 1:
                ambiguous += 1
            elif len(ng) == 1:
                forcing += 1

        ratio = ambiguous / total if total > 0 else 0
        lengths.append(length)
        ambiguity_ratios.append(ratio)
        total_admissible_counts.append(total)
        forcing_counts.append(forcing)

    # Plot 1: Ambiguity ratio
    ax1.plot(lengths, ambiguity_ratios, 'o-', color=color, label=label,
             linewidth=2, markersize=8)

    # Plot 2: Counts
    ax2.plot(lengths, total_admissible_counts, 's--', color=color,
             label=f'{label} admissible', linewidth=1.5, markersize=6)
    ax2.plot(lengths, forcing_counts, 'o-', color=color,
             label=f'{label} forcing', linewidth=2, markersize=8)

# Customize Plot 1
ax1.set_xlabel('Gap word length', fontsize=12)
ax1.set_ylabel('Fraction with >1 admissible next gap', fontsize=12)
ax1.set_title('Ambiguity Decay with Word Length', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.set_xticks(range(1, max_len + 1))
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5)

# Add annotation
ax1.annotate('Full forcing\n(all patterns determined)',
             xy=(4, 0), xytext=(3, 0.3),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=9, ha='center', color='gray')

# Customize Plot 2
ax2.set_xlabel('Gap word length', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Admissible vs Forcing Patterns', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_xticks(range(1, max_len + 1))
ax2.grid(True, alpha=0.3)

fig.suptitle('Prime Gap Crossword: How Longer Patterns Reduce Ambiguity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ambiguity_decay.png', dpi=150, bbox_inches='tight')
print("Saved ambiguity_decay.png")


#!/usr/bin/env python3
"""
Visualization: Forcing Pattern Heatmap

Visualizes which gap word prefixes are "forcing" (uniquely determine the next gap)
under different sieve sets. Each cell shows whether a length-2 gap word [g1, g2]
is forcing, ambiguous, or inadmissible under the sieve S = {2, 3, 5}.

The heatmap reveals the structure of the "prime crossword grammar" — which
local patterns leave no choice for the next move.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod
from typing import List, Set

# ── Self-contained core algorithms ──────────────────────────────────────

def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos

def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior

def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    inter = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in inter:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True

def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))

def next_gaps(S: Set[int], word: List[int], max_gap: int = 20) -> Set[int]:
    return {g for g in range(1, max_gap + 1) if admissible_over(S, word + [g])}

# ── Build heatmap data ──────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

sieve_configs = [
    ({2, 3}, "S = {2, 3}, M = 6"),
    ({2, 3, 5}, "S = {2, 3, 5}, M = 30"),
    ({2, 3, 5, 7}, "S = {2, 3, 5, 7}, M = 210"),
]

even_gaps = list(range(2, 16, 2))  # [2, 4, 6, 8, 10, 12, 14]
n = len(even_gaps)

for ax_idx, (S, title) in enumerate(sieve_configs):
    data = np.full((n, n), np.nan)

    for i, g1 in enumerate(even_gaps):
        for j, g2 in enumerate(even_gaps):
            word = [g1, g2]
            if not admissible_over(S, word):
                data[i, j] = -1  # inadmissible
            else:
                ng = next_gaps(S, word, 20)
                if len(ng) == 1:
                    data[i, j] = 1  # forcing
                elif len(ng) > 1:
                    data[i, j] = 0  # ambiguous

    # Custom colormap: gray=inadmissible, yellow=ambiguous, green=forcing
    from matplotlib.colors import ListedColormap, BoundaryNorm
    cmap = ListedColormap(['#cccccc', '#ffdd57', '#48c774'])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = BoundaryNorm(bounds, cmap.N)

    im = axes[ax_idx].imshow(data, cmap=cmap, norm=norm,
                              origin='lower', aspect='equal')
    axes[ax_idx].set_xticks(range(n))
    axes[ax_idx].set_xticklabels(even_gaps)
    axes[ax_idx].set_yticks(range(n))
    axes[ax_idx].set_yticklabels(even_gaps)
    axes[ax_idx].set_xlabel('Second gap (g₂)')
    axes[ax_idx].set_ylabel('First gap (g₁)')
    axes[ax_idx].set_title(title, fontsize=11)

    # Annotate forcing cells
    for i in range(n):
        for j in range(n):
            if data[i, j] == 1:
                word = [even_gaps[i], even_gaps[j]]
                ng = next_gaps(S, word, 20)
                forced = ng.pop()
                axes[ax_idx].text(j, i, f'→{forced}', ha='center', va='center',
                                   fontsize=7, fontweight='bold', color='#1a1a1a')
            elif data[i, j] == 0:
                word = [even_gaps[i], even_gaps[j]]
                ng = sorted(next_gaps(S, word, 20))
                label = ','.join(str(g) for g in ng[:3])
                if len(ng) > 3:
                    label += '…'
                axes[ax_idx].text(j, i, label, ha='center', va='center',
                                   fontsize=5, color='#555')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#48c774', label='Forcing (unique next gap)'),
    Patch(facecolor='#ffdd57', label='Ambiguous (multiple next gaps)'),
    Patch(facecolor='#cccccc', label='Inadmissible'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           fontsize=10, frameon=False, bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Prime Gap Crossword: Forcing Patterns for Length-2 Words',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('forcing_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved forcing_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Sieve Residue Structure

Visualizes the modular "chessboard" of admissible residues mod M for
different sieve sets. Shows how the coprime residues (valid starting
positions for prime candidates) form a structured pattern on the
discrete torus Z/MZ.

The visualization reveals the geometric structure underlying the
prime gap crossword: admissible positions form a sparse, periodic
lattice in modular arithmetic.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod, gcd
from typing import Set

# ── Build residue grid visualization ────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

configs = [
    ({2, 3}, "S = {2,3}, M = 6", axes[0, 0]),
    ({2, 3, 5}, "S = {2,3,5}, M = 30", axes[0, 1]),
    ({2, 3, 5, 7}, "S = {2,3,5,7}, M = 210", axes[1, 0]),
]

for S, title, ax in configs:
    M = prod(S)

    # Determine which residues are coprime to M
    coprime = np.array([1 if all(r % q != 0 for q in S) else 0 for r in range(M)])

    # Reshape into a 2D grid for visualization
    cols = max(6, int(np.sqrt(M)))
    while M % cols != 0 and cols > 1:
        cols -= 1
    rows = M // cols

    grid = coprime.reshape(rows, cols)

    # Color: coprime residues = green, sieved = gray
    cmap = plt.cm.colors.ListedColormap(['#e8e8e8', '#48c774'])
    ax.imshow(grid, cmap=cmap, aspect='equal', origin='lower')

    ax.set_title(f"{title}\n{sum(coprime)} coprime residues out of {M}",
                 fontsize=11)
    ax.set_xlabel(f'Residue mod {cols}')
    ax.set_ylabel(f'Block ({cols} per row)')

    # Density annotation
    density = sum(coprime) / M
    euler_product = prod((1 - 1/q) for q in S)
    ax.text(0.02, 0.98, f'Density: {density:.3f}\nEuler: {euler_product:.3f}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Fourth panel: Gap transition diagram for S = {2, 3}
ax4 = axes[1, 1]
S = {2, 3}
M = 6
coprime_residues = [r for r in range(M) if all(r % q != 0 for q in S)]

# Draw circular layout of coprime residues mod 6
n_res = len(coprime_residues)
theta = np.linspace(0, 2 * np.pi, M, endpoint=False)
radius = 1.5

# Draw all residues as small dots
for r in range(M):
    x, y = radius * np.cos(theta[r]), radius * np.sin(theta[r])
    is_cop = r in coprime_residues
    color = '#48c774' if is_cop else '#cccccc'
    size = 800 if is_cop else 200
    ax4.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1)
    ax4.annotate(str(r), (x, y), fontsize=12 if is_cop else 8,
                ha='center', va='center', fontweight='bold' if is_cop else 'normal')

# Draw admissible gap transitions
gap_colors = {2: '#e74c3c', 4: '#3498db', 6: '#f39c12'}
for a in coprime_residues:
    for g in [2, 4, 6]:
        b = (a + g) % M
        if b in coprime_residues:
            # Check if interior is covered
            all_interior_hit = True
            for u in range(1, g):
                if not any((a + u) % q == 0 for q in S):
                    all_interior_hit = False
                    break
            if all_interior_hit:
                xa, ya = radius * np.cos(theta[a]), radius * np.sin(theta[a])
                xb, yb = radius * np.cos(theta[b]), radius * np.sin(theta[b])
                ax4.annotate('', xy=(xb, yb), xytext=(xa, ya),
                            arrowprops=dict(arrowstyle='->', color=gap_colors.get(g, 'gray'),
                                          lw=2, connectionstyle='arc3,rad=0.3'))

ax4.set_xlim(-2.5, 2.5)
ax4.set_ylim(-2.5, 2.5)
ax4.set_aspect('equal')
ax4.set_title('Gap Transition Graph (S = {2,3}, mod 6)\nGreen = coprime residues',
              fontsize=11)
ax4.axis('off')

# Add gap color legend
from matplotlib.lines import Line2D
legend_lines = [Line2D([0], [0], color=c, lw=2, label=f'gap {g}')
                for g, c in sorted(gap_colors.items())]
ax4.legend(handles=legend_lines, loc='lower right', fontsize=9)

fig.suptitle('Prime Gap Crossword: Modular Sieve Structure',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('sieve_residues.png', dpi=150, bbox_inches='tight')
print("Saved sieve_residues.png")
