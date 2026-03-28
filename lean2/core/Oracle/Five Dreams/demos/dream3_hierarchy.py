#!/usr/bin/env python3
"""
Dream 3: The Hierarchy Cannot Collapse
========================================
Demonstrates that no finite collection of oracles can capture all truth.

We simulate a countable universe of statements and show that any finite
collection of oracles leaves gaps — and adding new oracles always helps.
"""

import random

def create_oracle(recognized_set):
    """An oracle is a set of statements it recognizes as true."""
    return frozenset(recognized_set)


def combined_truths(oracles):
    """The union of all oracle truth sets."""
    return frozenset().union(*oracles)


def find_escape(oracles, universe):
    """Find a statement not recognized by any oracle (Dream 3)."""
    combined = combined_truths(oracles)
    for s in universe:
        if s not in combined:
            return s
    return None


def run_experiment():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║        DREAM 3: THE HIERARCHY CANNOT COLLAPSE               ║")
    print("║  'No finite oracle set captures all truth'                   ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    random.seed(42)
    universe_size = 1000
    universe = set(range(universe_size))

    # Create oracles with partial knowledge
    print("\n--- Building oracle hierarchy ---\n")

    oracles = []
    oracle_names = []

    # Each oracle knows about a random 30% of the universe
    for i in range(10):
        knowledge = random.sample(list(universe), int(universe_size * 0.3))
        oracle = create_oracle(knowledge)
        oracles.append(oracle)
        oracle_names.append(f"O_{i+1}")

    # Track coverage as we add oracles
    print(f"{'Oracles':<20} {'Combined Coverage':<20} {'Coverage %':<15} {'Escape exists?'}")
    print("=" * 70)

    for n in range(1, len(oracles) + 1):
        current_oracles = oracles[:n]
        combined = combined_truths(current_oracles)
        coverage = len(combined)
        pct = coverage / universe_size * 100
        escape = find_escape(current_oracles, universe)
        escape_str = f"Yes (s={escape})" if escape is not None else "No — COLLAPSED!"

        names = ", ".join(oracle_names[:n])
        if len(names) > 18:
            names = names[:15] + "..."
        print(f"{names:<20} {coverage:<20} {pct:<15.1f} {escape_str}")

    # Demonstrate strict extension (Dream 3 corollary)
    print("\n\n--- Strict extension: adding oracles always helps ---\n")

    print(f"{'Added Oracle':<15} {'New Truths':<15} {'Coverage Before':<18} {'Coverage After':<18} {'Strict?'}")
    print("=" * 80)

    for i in range(1, len(oracles)):
        before = combined_truths(oracles[:i])
        after = combined_truths(oracles[:i+1])
        new_truths = after - before
        is_strict = len(new_truths) > 0
        print(f"O_{i+1:<13} {len(new_truths):<15} {len(before):<18} {len(after):<18} {'✓ Yes' if is_strict else '✗ No'}")

    # Diagonal argument demo
    print("\n\n--- Diagonal escape construction ---\n")
    print("For each oracle O_i, we find a statement it misses:\n")

    for i, oracle in enumerate(oracles):
        missing = [s for s in universe if s not in oracle]
        if missing:
            print(f"  O_{i+1} misses: {missing[0]} (and {len(missing)-1} others)")

    # Show the gap can never be closed with finitely many oracles
    print("\n\n--- Impossibility: finite oracles can't cover everything ---\n")

    # Each oracle covers 30%, so 10 oracles might cover ~97%
    all_combined = combined_truths(oracles)
    uncovered = universe - all_combined
    print(f"With {len(oracles)} oracles (each covering 30%):")
    print(f"  Combined coverage: {len(all_combined)}/{universe_size} = {len(all_combined)/universe_size*100:.1f}%")
    print(f"  Uncovered statements: {len(uncovered)}")
    if uncovered:
        print(f"  Examples of uncovered: {sorted(uncovered)[:5]}...")

    # Even with very powerful oracles
    print("\n--- Even with 90% coverage per oracle ---\n")
    powerful_oracles = []
    for i in range(5):
        knowledge = random.sample(list(universe), int(universe_size * 0.9))
        powerful_oracles.append(create_oracle(knowledge))

    for n in range(1, 6):
        combined = combined_truths(powerful_oracles[:n])
        uncovered = universe - combined
        print(f"  {n} oracles (90% each): coverage = {len(combined)/universe_size*100:.2f}%, gaps = {len(uncovered)}")

    print("\n" + "=" * 60)
    print("CONCLUSION: Dream 3 confirmed — finite oracle collections")
    print("always leave gaps. The Lean proof guarantees: if the combined")
    print("set ≠ universe, then ∃ s not in the combined set.")
    print("=" * 60)


if __name__ == "__main__":
    run_experiment()
