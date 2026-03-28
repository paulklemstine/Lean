#!/usr/bin/env python3
"""
Dream 4: Composition Creates Power
=====================================
Demonstrates that combining incomparable oracles always yields
strict power gains.

We simulate pairs of oracles with different knowledge and show that
their union is always strictly more powerful than either alone.
"""

import random
from itertools import combinations

def create_specialized_oracle(universe_size, specialty_range, coverage=0.8, noise=0.1, seed=0):
    """Create an oracle that's strong in one area and weak elsewhere."""
    random.seed(seed)
    truths = set()

    for s in range(universe_size):
        if specialty_range[0] <= s < specialty_range[1]:
            # Strong in specialty area
            if random.random() < coverage:
                truths.add(s)
        else:
            # Weak elsewhere
            if random.random() < noise:
                truths.add(s)

    return frozenset(truths)


def are_incomparable(O1, O2):
    """Check if neither oracle subsumes the other."""
    return not O1.issubset(O2) and not O2.issubset(O1)


def run_experiment():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║        DREAM 4: COMPOSITION CREATES POWER                   ║")
    print("║  'Combining oracles yields strict power gains'               ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    universe_size = 500
    random.seed(42)

    # Create specialized oracles for different domains
    domains = {
        "Number Theory": (0, 100),
        "Algebra":       (80, 200),
        "Topology":      (180, 300),
        "Analysis":      (280, 400),
        "Combinatorics": (380, 500),
    }

    oracles = {}
    for i, (name, range_) in enumerate(domains.items()):
        oracles[name] = create_specialized_oracle(universe_size, range_, seed=i*7+1)

    # Show individual oracle coverage
    print("\n--- Individual Oracle Coverage ---\n")
    print(f"{'Oracle':<20} {'|Truths|':<12} {'Coverage %':<12}")
    print("=" * 45)
    for name, oracle in oracles.items():
        pct = len(oracle) / universe_size * 100
        print(f"{name:<20} {len(oracle):<12} {pct:<12.1f}")

    # Check incomparability
    print("\n--- Incomparability Check ---\n")
    names = list(oracles.keys())
    for i, j in combinations(range(len(names)), 2):
        n1, n2 = names[i], names[j]
        O1, O2 = oracles[n1], oracles[n2]
        incomp = are_incomparable(O1, O2)
        only_1 = len(O1 - O2)
        only_2 = len(O2 - O1)
        print(f"  {n1} vs {n2}: {'Incomparable ✓' if incomp else 'Comparable ✗'} "
              f"(only in 1st: {only_1}, only in 2nd: {only_2})")

    # Demonstrate strict power gain for all pairs
    print("\n--- Composition Power Gains ---\n")
    print(f"{'Pair':<35} {'|O1|':<8} {'|O2|':<8} {'|O1∪O2|':<10} {'Gain over O1':<14} {'Gain over O2':<14}")
    print("=" * 90)

    for i, j in combinations(range(len(names)), 2):
        n1, n2 = names[i], names[j]
        O1, O2 = oracles[n1], oracles[n2]
        composed = O1 | O2
        gain1 = len(composed) - len(O1)
        gain2 = len(composed) - len(O2)
        pair_name = f"{n1} + {n2}"
        if len(pair_name) > 33:
            pair_name = pair_name[:30] + "..."
        print(f"{pair_name:<35} {len(O1):<8} {len(O2):<8} {len(composed):<10} "
              f"+{gain1:<13} +{gain2:<13}")

    # Verify algebraic properties
    print("\n--- Algebraic Properties ---\n")

    O1 = oracles["Number Theory"]
    O2 = oracles["Algebra"]
    O3 = oracles["Topology"]

    # Commutativity
    comm = (O1 | O2) == (O2 | O1)
    print(f"  Commutativity:  O1 ∪ O2 == O2 ∪ O1? {comm} ✓" if comm else f"  ✗ FAILED")

    # Associativity
    assoc = (O1 | (O2 | O3)) == ((O1 | O2) | O3)
    print(f"  Associativity:  (O1 ∪ O2) ∪ O3 == O1 ∪ (O2 ∪ O3)? {assoc} ✓" if assoc else f"  ✗ FAILED")

    # Idempotency
    idem = (O1 | O1) == O1
    print(f"  Idempotency:    O1 ∪ O1 == O1? {idem} ✓" if idem else f"  ✗ FAILED")

    # Progressive composition
    print("\n--- Progressive Composition ---\n")
    print(f"{'Step':<5} {'Added Oracle':<20} {'|Combined|':<12} {'New Truths':<12} {'Coverage %':<12}")
    print("=" * 65)

    combined = frozenset()
    for i, (name, oracle) in enumerate(oracles.items()):
        new_combined = combined | oracle
        new_truths = len(new_combined) - len(combined)
        pct = len(new_combined) / universe_size * 100
        print(f"{i+1:<5} {name:<20} {len(new_combined):<12} +{new_truths:<11} {pct:<12.1f}")
        combined = new_combined

    print("\n" + "=" * 60)
    print("CONCLUSION: Dream 4 confirmed — composition of incomparable")
    print("oracles always yields strict power gains. The Lean proof")
    print("guarantees: O₁ ⊂ O₁∪O₂ and O₂ ⊂ O₁∪O₂ when incomparable.")
    print("=" * 60)


if __name__ == "__main__":
    run_experiment()
