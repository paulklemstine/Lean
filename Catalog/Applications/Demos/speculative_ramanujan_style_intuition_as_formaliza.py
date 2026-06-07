#!/usr/bin/env python3
"""
Ramanujan Oracle Framework — Demonstration Script

Demonstrates the key concepts from the Ramanujan Oracle theory:
1. Oracle space counting (3^N for N statements)
2. Simulated oracle accuracy evaluation
3. Cofinite agreement detection
4. Oracle hierarchy visualization
"""

import random
import math
from typing import Callable, Dict, List, Optional, Tuple

# ── Oracle Response Type ──────────────────────────────────────────────────
class OracleResponse:
    TRUE = "true"
    FALSE = "false"
    UNKNOWN = "unknown"

# ── Demo 1: Oracle Space Counting ─────────────────────────────────────────
def demo_counting_bound():
    """Demonstrate that the oracle space grows as 3^N."""
    print("=" * 60)
    print("DEMO 1: Oracle Space Counting Bound")
    print("=" * 60)
    print()
    print("For N statements with 3-valued responses,")
    print("the number of possible oracles is exactly 3^N:")
    print()
    for N in range(1, 16):
        count = 3 ** N
        log_count = N * math.log2(3)
        print(f"  N = {N:2d}: 3^N = {count:>12,d}  (log2 = {log_count:.1f} bits)")
    print()
    print("Key insight: This grows faster than 2^N (binary functions),")
    print("and vastly exceeds the countably many computable oracles.")
    print()

# ── Demo 2: Oracle Accuracy Evaluation ────────────────────────────────────
def evaluate_oracle(
    predict: Callable[[int], str],
    truth: Callable[[int], bool],
    N: int
) -> Dict[str, float]:
    """Evaluate a prediction oracle's accuracy on N statements."""
    correct = wrong = abstain = 0
    for n in range(N):
        prediction = predict(n)
        is_true = truth(n)
        if prediction == OracleResponse.UNKNOWN:
            abstain += 1
        elif (prediction == OracleResponse.TRUE) == is_true:
            correct += 1
        else:
            wrong += 1
    total_definite = correct + wrong
    accuracy = correct / total_definite if total_definite > 0 else 1.0
    coverage = total_definite / N if N > 0 else 0.0
    return {
        "accuracy": accuracy,
        "coverage": coverage,
        "correct": correct,
        "wrong": wrong,
        "abstain": abstain,
        "is_sound": wrong == 0
    }

def demo_oracle_accuracy():
    """Demonstrate oracle evaluation with different prediction strategies."""
    print("=" * 60)
    print("DEMO 2: Oracle Accuracy Evaluation")
    print("=" * 60)
    print()

    # Truth set: primes up to N
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    N = 100

    # Oracle 1: Always says unknown (trivially sound, zero coverage)
    def oracle_abstain(n: int) -> str:
        return OracleResponse.UNKNOWN

    # Oracle 2: Always says true (not sound for composites)
    def oracle_always_true(n: int) -> str:
        return OracleResponse.TRUE

    # Oracle 3: Correct on small primes, unknown on large (sound, partial coverage)
    def oracle_small_primes(n: int) -> str:
        if n < 20:
            return OracleResponse.TRUE if is_prime(n) else OracleResponse.FALSE
        return OracleResponse.UNKNOWN

    # Oracle 4: Perfect oracle (sound and complete)
    def oracle_perfect(n: int) -> str:
        return OracleResponse.TRUE if is_prime(n) else OracleResponse.FALSE

    # Oracle 5: "Ramanujan-like" — mostly correct, with rare unknown
    def oracle_ramanujan(n: int) -> str:
        if n > 90:  # abstain on "hard" cases
            return OracleResponse.UNKNOWN
        return OracleResponse.TRUE if is_prime(n) else OracleResponse.FALSE

    oracles = [
        ("Always Unknown", oracle_abstain),
        ("Always True", oracle_always_true),
        ("Small Primes Only", oracle_small_primes),
        ("Perfect Oracle", oracle_perfect),
        ("Ramanujan-like", oracle_ramanujan),
    ]

    print(f"Truth set: primes among {{0, ..., {N-1}}}")
    print(f"Number of primes: {sum(1 for n in range(N) if is_prime(n))}")
    print()

    for name, oracle in oracles:
        result = evaluate_oracle(oracle, is_prime, N)
        sound_str = "✓ SOUND" if result["is_sound"] else "✗ NOT SOUND"
        print(f"  {name:20s}: accuracy={result['accuracy']:.2%}, "
              f"coverage={result['coverage']:.2%}, "
              f"correct={result['correct']:3d}, wrong={result['wrong']:3d}, "
              f"abstain={result['abstain']:3d}  [{sound_str}]")
    print()

# ── Demo 3: Cofinite Agreement ────────────────────────────────────────────
def cofinite_agree(f: Callable[[int], bool], g: Callable[[int], bool],
                   N: int) -> Tuple[bool, int, List[int]]:
    """Check if f and g agree on all but finitely many inputs up to N."""
    disagreements = [n for n in range(N) if f(n) != g(n)]
    return len(disagreements) < N // 10, len(disagreements), disagreements[:10]

def demo_cofinite_agreement():
    """Demonstrate the cofinite agreement concept."""
    print("=" * 60)
    print("DEMO 3: Cofinite Agreement — Finite Perturbation")
    print("=" * 60)
    print()

    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    # Perturb the primality function at a few points
    perturbation_points = {4, 9, 25, 49}  # squares, not prime

    def perturbed_prime(n: int) -> bool:
        if n in perturbation_points:
            return True  # wrong on these points
        return is_prime(n)

    N = 1000
    _, num_disagree, examples = cofinite_agree(is_prime, perturbed_prime, N)

    print(f"Original function: is_prime")
    print(f"Perturbed function: is_prime with {len(perturbation_points)} flipped values")
    print(f"Disagreements in [0, {N}): {num_disagree}")
    print(f"Disagreement points: {examples}")
    print()
    print("Theorem (Cofinite Stability):")
    print("  If is_prime were non-computable, then perturbed_prime")
    print("  would ALSO be non-computable — finitely many corrections")
    print("  cannot bridge the computability gap.")
    print()

# ── Demo 4: Oracle Hierarchy ──────────────────────────────────────────────
def demo_oracle_hierarchy():
    """Demonstrate the strict oracle hierarchy."""
    print("=" * 60)
    print("DEMO 4: Strict Oracle Hierarchy")
    print("=" * 60)
    print()

    # Simulate hierarchy levels with increasingly powerful decidability
    # Level 0: Can decide divisibility properties
    # Level 1: Can decide primality
    # Level 2: Can decide Goldbach-type properties
    # Level 3: Can decide partition-type properties

    levels = {
        0: "Divisibility (n mod k = 0)",
        1: "Primality (is n prime?)",
        2: "Goldbach-type (is n a sum of two primes?)",
        3: "Partition-type (partition function properties)",
    }

    # Simulate decidable sets at each level (simplified)
    def level_set(level: int, N: int) -> set:
        """Statements decidable at this level."""
        s = set()
        if level >= 0:
            # Level 0: even/odd classification
            s.update(range(0, N, 2))
        if level >= 1:
            # Level 1: add primes
            for n in range(2, N):
                if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
                    s.add(n)
        if level >= 2:
            # Level 2: add numbers that are sums of two primes
            primes = {p for p in range(2, N) if all(p % i != 0 for i in range(2, max(2, int(p**0.5) + 1)))}
            for p1 in primes:
                for p2 in primes:
                    if p1 + p2 < N:
                        s.add(p1 + p2)
        if level >= 3:
            # Level 3: add all remaining
            s.update(range(N))
        return s

    N = 100
    print("Simulated oracle hierarchy on [0, 100):")
    print()
    prev_size = 0
    for lvl in range(4):
        s = level_set(lvl, N)
        new_elements = len(s) - prev_size
        print(f"  Level {lvl} ({levels[lvl]}): "
              f"|L_{lvl}| = {len(s):3d}, new elements = {new_elements:3d}")
        prev_size = len(s)

    print()
    print("Strict Hierarchy Theorem: L_0 ⊊ L_1 ⊊ L_2 ⊊ L_3 ⊊ ...")
    print("Each level decides statements inaccessible to lower levels.")
    print()

# ── Demo 5: Proof-Prediction Duality ─────────────────────────────────────
def demo_duality():
    """Demonstrate the proof-prediction duality."""
    print("=" * 60)
    print("DEMO 5: Proof-Prediction Duality")
    print("=" * 60)
    print()

    print("Comparison of proof-side and prediction-side counting bounds:")
    print()
    print(f"  {'N':>3s}  {'Proofs (2^N)':>14s}  {'Oracles (3^N)':>14s}  {'Ratio':>8s}")
    print(f"  {'─'*3}  {'─'*14}  {'─'*14}  {'─'*8}")

    for N in [1, 2, 5, 10, 15, 20, 25, 30]:
        proofs = 2 ** N
        oracles = 3 ** N
        ratio = oracles / proofs
        print(f"  {N:3d}  {proofs:14,d}  {oracles:14,d}  {ratio:8.2f}")

    print()
    print("The oracle space grows faster than the proof space (3 > 2),")
    print("reflecting the additional 'unknown' response option.")
    print("Both are governed by exponential counting in the alphabet size.")
    print()

# ── Main ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   RAMANUJAN ORACLE FRAMEWORK — DEMONSTRATION SUITE     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_counting_bound()
    demo_oracle_accuracy()
    demo_cofinite_agreement()
    demo_oracle_hierarchy()
    demo_duality()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Oracle Space Growth vs Computable Functions

Shows the exponential growth of the oracle space (3^N) compared to
linear/polynomial growth of computable function enumeration.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_oracle_space_growth():
    """Plot oracle space size vs number of statements."""
    N = np.arange(1, 31)
    oracle_3 = 3.0 ** N  # 3-valued oracles
    oracle_2 = 2.0 ** N  # binary oracles
    computable = N * np.log2(N + 1) * 100  # rough upper bound on enumerable programs

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: log scale
    ax1.semilogy(N, oracle_3, 'r-o', label='3-valued oracles (3^N)', markersize=4, linewidth=2)
    ax1.semilogy(N, oracle_2, 'b-s', label='Binary oracles (2^N)', markersize=4, linewidth=2)
    ax1.semilogy(N, computable, 'g--', label='Computable bound (≈ N log N)', linewidth=2)
    ax1.set_xlabel('Number of statements N', fontsize=12)
    ax1.set_ylabel('Number of possible oracles (log scale)', fontsize=12)
    ax1.set_title('Oracle Space Growth', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(1, 30)

    # Right: ratio
    ratio = oracle_3 / oracle_2
    ax2.plot(N, ratio, 'purple', linewidth=2, marker='D', markersize=4)
    ax2.set_xlabel('Number of statements N', fontsize=12)
    ax2.set_ylabel('Ratio: 3-valued / binary oracles', fontsize=12)
    ax2.set_title('Three-valued vs Binary Oracle Ratio (1.5^N)', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(1, 30)

    # Add annotation
    ax1.annotate('Non-computable\nregion', xy=(20, 3**20), fontsize=11,
                ha='center', color='red', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('oracle_space_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_space_growth.png")

def plot_hierarchy():
    """Plot the oracle hierarchy levels."""
    fig, ax = plt.subplots(figsize=(10, 7))

    levels = 6
    N = 100

    # Simulated level set sizes (monotonically increasing, strictly)
    level_sizes = [10, 25, 45, 65, 82, 95]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, levels))

    bars = ax.barh(range(levels), level_sizes, color=colors, edgecolor='black', linewidth=1.2)

    # Add "new elements" annotations
    for i in range(levels):
        new = level_sizes[i] - (level_sizes[i-1] if i > 0 else 0)
        ax.annotate(f'+{new} new', xy=(level_sizes[i] + 1, i),
                   fontsize=10, va='center', color='darkred', fontweight='bold')

    ax.set_yticks(range(levels))
    ax.set_yticklabels([f'Level {i} (Σ⁰_{i})' for i in range(levels)], fontsize=11)
    ax.set_xlabel('Number of decidable statements', fontsize=12)
    ax.set_title('Strict Oracle Hierarchy\nEach level decides strictly more statements',
                fontsize=14, fontweight='bold')
    ax.set_xlim(0, 110)
    ax.grid(True, axis='x', alpha=0.3)

    # Add strictness arrows
    for i in range(levels - 1):
        ax.annotate('', xy=(level_sizes[i+1], i+0.6), xytext=(level_sizes[i], i+0.4),
                   arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy.png")

def plot_cofinite_stability():
    """Visualize the cofinite stability theorem."""
    fig, ax = plt.subplots(figsize=(12, 5))

    N = 200
    np.random.seed(42)

    # Simulate a "non-computable" function (random-looking)
    truth = np.array([1 if i in {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,
                                   73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,
                                   151,157,163,167,173,179,181,191,193,197,199} else 0
                      for i in range(N)])

    # Finite perturbation (flip 5 values)
    perturbed = truth.copy()
    flip_points = [4, 9, 15, 50, 100]
    for p in flip_points:
        perturbed[p] = 1 - perturbed[p]

    x = np.arange(N)

    ax.step(x, truth * 1.05, 'b-', alpha=0.7, linewidth=1, label='Original function f')
    ax.step(x, perturbed * 0.95, 'r--', alpha=0.7, linewidth=1, label='Perturbed function g')

    # Mark disagreement points
    for p in flip_points:
        ax.axvline(x=p, color='orange', alpha=0.5, linewidth=2)
        ax.plot(p, truth[p], 'bo', markersize=8)
        ax.plot(p, perturbed[p], 'rs', markersize=8)

    ax.set_xlabel('Input n', fontsize=12)
    ax.set_ylabel('Function value', fontsize=12)
    ax.set_title('Cofinite Stability: Finite perturbation preserves non-computability\n'
                '(Orange lines mark the 5 disagreement points)',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_ylim(-0.2, 1.4)
    ax.set_xlim(0, N)

    plt.tight_layout()
    plt.savefig('cofinite_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cofinite_stability.png")


if __name__ == "__main__":
    plot_oracle_space_growth()
    plot_hierarchy()
    plot_cofinite_stability()
    print("All visualizations generated.")
