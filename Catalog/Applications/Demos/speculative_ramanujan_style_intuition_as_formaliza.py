#!/usr/bin/env python3
"""
Ramanujan Oracle Demo: Numerical Illustrations of Oracle Non-Computability

Demonstrates the key theorems from the Ramanujan Oracle framework:
1. Oracle space cardinality gap (3^N vs 2^N)
2. Cantor diagonal construction
3. Abstention advantage
4. Oracle jump hierarchy
"""

import random
import math
from typing import Callable, List, Tuple


# === Oracle Types ===

class OracleResponse:
    AFFIRM = "affirm"
    DENY = "deny"
    ABSTAIN = "abstain"


Oracle = Callable[[int], str]
TruthAssignment = Callable[[int], bool]


def oracle_correct_on(response: str, truth: bool) -> bool:
    """Check if an oracle response is correct for a given truth value."""
    if response == OracleResponse.AFFIRM and truth:
        return True
    if response == OracleResponse.DENY and not truth:
        return True
    return False


def accuracy_count(oracle: Oracle, truth: TruthAssignment, domain: range) -> int:
    """Count correct predictions on a domain."""
    return sum(1 for s in domain for _ in [None]
               if oracle_correct_on(oracle(s), truth(s)))


# === Demo 1: Oracle Space Cardinality Gap ===

def demo_cardinality_gap():
    """Show that 3^N >> 2^N for growing N."""
    print("=" * 60)
    print("DEMO 1: Oracle Space Cardinality Gap")
    print("=" * 60)
    print(f"{'N':>5} {'2^N (truths)':>15} {'3^N (oracles)':>15} {'ratio (3/2)^N':>15}")
    print("-" * 55)
    for N in [1, 2, 5, 10, 20, 50, 100]:
        truths = 2**N
        oracles = 3**N
        ratio = (3/2)**N
        print(f"{N:>5} {truths:>15} {oracles:>15} {ratio:>15.2f}")
    print()
    print("Key insight: The ratio grows exponentially. For N=100,")
    print(f"there are (3/2)^100 ≈ {(1.5)**100:.2e} times more oracles than truths.")
    print()


# === Demo 2: Cantor Diagonal Construction ===

def demo_cantor_diagonal():
    """Demonstrate the diagonal argument defeating a family of oracles."""
    print("=" * 60)
    print("DEMO 2: Cantor-Ramanujan Diagonalization")
    print("=" * 60)
    
    N = 10
    
    # Create a family of oracles
    def make_oracle(seed: int) -> Oracle:
        rng = random.Random(seed)
        responses = [random.choice([OracleResponse.AFFIRM, OracleResponse.DENY,
                                     OracleResponse.ABSTAIN]) for _ in range(N)]
        return lambda s: responses[s % len(responses)]
    
    family = [make_oracle(i) for i in range(N)]
    
    # Construct diagonal-defeating truth assignment
    def diagonal_defeater(n: int) -> bool:
        response = family[n % len(family)](n)
        if response == OracleResponse.AFFIRM:
            return False  # Defeat affirm with false
        else:
            return True   # Defeat deny/abstain with true
    
    print(f"Family of {N} oracles on {N} statements:")
    print()
    print("Oracle responses on diagonal:")
    for n in range(N):
        resp = family[n](n)
        g_val = diagonal_defeater(n)
        correct = oracle_correct_on(resp, g_val)
        print(f"  Oracle {n} on stmt {n}: {resp:>8} | truth: {str(g_val):>5} | correct: {correct}")
    
    print()
    print(f"Result: The diagonal truth assignment defeats ALL {N} oracles.")
    print("Each oracle is wrong on at least one statement (its diagonal).")
    print()


# === Demo 3: Abstention Advantage ===

def demo_abstention():
    """Show the exponential advantage of strategic abstention."""
    print("=" * 60)
    print("DEMO 3: Abstention Exponential Advantage")
    print("=" * 60)
    
    N = 20
    print(f"For {N} statements:")
    print(f"{'k (abstentions)':>20} {'compatible truths (2^k)':>25} {'fraction of 2^{N}':>20}")
    print("-" * 70)
    for k in [0, 1, 2, 5, 10, 15, 20]:
        compatible = 2**k
        fraction = compatible / 2**N
        print(f"{k:>20} {compatible:>25} {fraction:>20.8f}")
    
    print()
    print("Key insight: Abstaining on half the statements (k=10) makes the oracle")
    print("compatible with 1024 truth assignments instead of just 1.")
    print("Ramanujan's strategy of 'not guessing when uncertain' is optimal.")
    print()


# === Demo 4: Oracle Jump Hierarchy ===

def demo_jump_hierarchy():
    """Show the oracle jump hierarchy never collapses."""
    print("=" * 60)
    print("DEMO 4: Oracle Jump Hierarchy")
    print("=" * 60)
    
    # Start with a simple oracle
    base_responses = [OracleResponse.AFFIRM, OracleResponse.DENY, 
                      OracleResponse.ABSTAIN, OracleResponse.AFFIRM,
                      OracleResponse.DENY]
    
    def oracle_jump(responses):
        """Compute the jump of an oracle."""
        jumped = []
        for r in responses:
            if r == OracleResponse.AFFIRM:
                jumped.append(OracleResponse.DENY)
            elif r == OracleResponse.DENY:
                jumped.append(OracleResponse.AFFIRM)
            else:  # ABSTAIN
                jumped.append(OracleResponse.AFFIRM)
        return jumped
    
    current = base_responses
    print(f"{'Level':>6} | Responses")
    print("-" * 50)
    for level in range(6):
        print(f"{level:>6} | {[r[:3] for r in current]}")
        current = oracle_jump(current)
    
    print()
    print("Key insight: Each jump level disagrees with the previous on")
    print("every non-abstention input. The hierarchy never collapses.")
    print("After the first jump, all levels are binary (no abstentions).")
    print()


# === Demo 5: Accuracy vs Programs ===

def demo_accuracy_vs_programs():
    """Show the ratio of computable oracles to all oracles."""
    print("=" * 60)
    print("DEMO 5: Computable Oracle Ratio (Proof-Oracle Bridge)")
    print("=" * 60)
    
    b = 2  # binary alphabet
    print(f"Alphabet size b = {b}")
    print(f"{'n':>5} {'programs b^n':>15} {'oracles 3^(b^n)':>25} {'ratio':>15}")
    print("-" * 65)
    for n in range(1, 11):
        programs = b**n
        oracles = 3**(b**n)
        ratio = programs / oracles if oracles > 0 else 0
        if oracles < 10**20:
            print(f"{n:>5} {programs:>15} {oracles:>25} {ratio:>15.2e}")
        else:
            print(f"{n:>5} {programs:>15} {'(huge)':>25} {'~0':>15}")
    
    print()
    print("Key insight: The ratio b^n / 3^(b^n) collapses super-exponentially.")
    print("For n=10, there are 1024 programs but 3^1024 ≈ 10^488 oracles.")
    print("Computable oracles are vanishingly rare.")
    print()


# === Main ===

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    RAMANUJAN ORACLE: Non-Computability Demonstrations   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_cardinality_gap()
    demo_cantor_diagonal()
    demo_abstention()
    demo_jump_hierarchy()
    demo_accuracy_vs_programs()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
These demonstrations illustrate five formally verified theorems:

1. Oracle Surplus: The oracle space (3^N) exponentially exceeds
   the truth space (2^N), so most oracles are "wrong" about most truths.

2. Cantor-Ramanujan Diagonalization: No countable family of oracles
   covers all truth assignments. The diagonal always escapes.

3. Abstention Advantage: Strategic "I don't know" responses provide
   an exponential advantage in robustness — 2^k compatible truths.

4. Jump Hierarchy: Each oracle jump level strictly extends the previous.
   The hierarchy never collapses, mirroring the arithmetic hierarchy.

5. Proof-Oracle Bridge: Computable oracles are super-exponentially
   rare among all oracles: b^n / 3^(b^n) → 0.
""")


#!/usr/bin/env python3
"""
Visualization: Oracle Space Cardinality Gap

Shows the exponential gap between oracle space (3^N) and truth space (2^N),
demonstrating why most oracles are non-computable.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_cardinality_gap():
    """Plot the cardinality gap between oracles and truth assignments."""
    N_values = np.arange(1, 25)
    truth_space = 2.0 ** N_values
    oracle_space = 3.0 ** N_values
    ratio = (1.5) ** N_values

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Log-scale comparison
    ax1 = axes[0]
    ax1.semilogy(N_values, truth_space, 'b-o', label='Truth space (2^N)', markersize=4)
    ax1.semilogy(N_values, oracle_space, 'r-s', label='Oracle space (3^N)', markersize=4)
    ax1.fill_between(N_values, truth_space, oracle_space, alpha=0.2, color='red',
                     label='Non-computable gap')
    ax1.set_xlabel('N (number of statements)')
    ax1.set_ylabel('Size (log scale)')
    ax1.set_title('Oracle vs Truth Space Cardinality')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio growth
    ax2 = axes[1]
    ax2.plot(N_values, ratio, 'g-^', markersize=4)
    ax2.set_xlabel('N (number of statements)')
    ax2.set_ylabel('Ratio (3/2)^N')
    ax2.set_title('Oracle Surplus Ratio')
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=1, color='k', linestyle='--', alpha=0.3)

    # Plot 3: Abstention advantage
    ax3 = axes[2]
    k_values = np.arange(0, 21)
    coverage = 2.0 ** k_values
    ax3.bar(k_values, coverage, color='teal', alpha=0.7)
    ax3.set_xlabel('k (number of abstentions)')
    ax3.set_ylabel('Compatible truth assignments (2^k)')
    ax3.set_title('Abstention Exponential Advantage')
    ax3.set_yscale('log')
    ax3.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('oracle_gap_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_gap_visualization.png")


def plot_computable_ratio():
    """Plot the vanishing ratio of computable oracles."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n_values = list(range(1, 9))
    b = 2
    log_programs = [n * np.log10(b) for n in n_values]
    log_oracles = [b**n * np.log10(3) for n in n_values]

    ax.bar(np.array(n_values) - 0.2, log_programs, 0.35, label='log₁₀(programs) = n·log₁₀(b)',
           color='steelblue', alpha=0.8)
    ax.bar(np.array(n_values) + 0.2, log_oracles, 0.35, label='log₁₀(oracles) = b^n·log₁₀(3)',
           color='coral', alpha=0.8)
    ax.set_xlabel('n (program length)')
    ax.set_ylabel('log₁₀(count)')
    ax.set_title('Programs vs Oracles: Super-Exponential Gap (b=2)')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')
    ax.set_xticks(n_values)

    plt.tight_layout()
    plt.savefig('computable_ratio_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: computable_ratio_visualization.png")


if __name__ == "__main__":
    plot_cardinality_gap()
    plot_computable_ratio()
