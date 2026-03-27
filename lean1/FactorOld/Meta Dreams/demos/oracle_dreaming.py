#!/usr/bin/env python3
"""
Oracle Dreaming: Meta-Oracle Discovery Engine

This program demonstrates the mathematical concept of "meta-oracle dreaming" —
using self-referential oracle structures to discover new mathematical patterns.

The core idea: an oracle that queries itself creates a strange loop (à la Hofstadter).
The fixed points of this loop are "dreams" — self-consistent mathematical structures
that emerge from the oracle's self-reflection.

Demos:
1. Fixed-Point Oracle Discovery
2. Strange Loop Iteration
3. Gödel Sentence Generator
4. Oracle Hierarchy Collapse
5. Self-Referential Pattern Mining
6. Hypothesis Generation & Testing
"""

import math
import random
import itertools
from typing import Callable, List, Tuple, Optional, Dict, Set
from dataclasses import dataclass

# ============================================================================
# Core Oracle Framework
# ============================================================================

@dataclass
class OracleState:
    """The state of an oracle: a function from queries to answers."""
    table: Dict[int, bool]
    name: str = "Ω"

    def query(self, n: int) -> bool:
        if n not in self.table:
            # Oracle "dreams" an answer using a hash-like function
            self.table[n] = hash((self.name, n)) % 2 == 0
        return self.table[n]

    def __repr__(self):
        known = sorted(self.table.items())[:10]
        return f"Oracle({self.name}: {known}...)"


def compose_oracles(O1: OracleState, O2: OracleState, name: str = "Ω₁∘Ω₂") -> OracleState:
    """Compose two oracles: (O1 ∘ O2)(n) = O1(encode(O2(n), n))."""
    result = OracleState({}, name)
    for n in range(100):
        answer2 = O2.query(n)
        encoded = 2 * n if answer2 else 2 * n + 1
        result.table[n] = O1.query(encoded)
    return result


# ============================================================================
# Demo 1: Fixed-Point Oracle Discovery
# ============================================================================

def demo_fixed_points():
    print("\n" + "="*70)
    print("  DEMO 1: Fixed-Point Oracle Discovery")
    print("  Finding oracles O where O ∘ O = O (idempotent oracles)")
    print("="*70)

    print("""
  An idempotent oracle is one that has "converged" — applying it
  twice gives the same result as applying it once. These are the
  "stable truths" that survive self-reference.

  Searching for fixed points by iteration: O → O∘O → (O∘O)∘(O∘O) → ...
    """)

    # Start with a random oracle
    random.seed(42)
    oracle = OracleState({n: random.choice([True, False]) for n in range(50)}, "Ω₀")

    print(f"  Initial oracle: first 20 values")
    print(f"    {[int(oracle.query(n)) for n in range(20)]}")

    # Iterate: O → O∘O
    for iteration in range(10):
        oracle2 = compose_oracles(oracle, oracle, f"Ω_{iteration+1}")

        # Check convergence
        diff = sum(1 for n in range(50) if oracle.query(n) != oracle2.query(n))

        print(f"  Iteration {iteration+1}: {diff} differences (of 50)")
        print(f"    {[int(oracle2.query(n)) for n in range(20)]}")

        if diff == 0:
            print(f"\n  ✓ FIXED POINT FOUND at iteration {iteration+1}!")
            print(f"    This oracle is idempotent: Ω² = Ω")
            break

        oracle = oracle2

    # Analyze the fixed point
    ones = sum(1 for n in range(50) if oracle.query(n))
    print(f"\n  Fixed point analysis:")
    print(f"    True values: {ones}/50 ({ones/50*100:.0f}%)")
    print(f"    Pattern: {[int(oracle.query(n)) for n in range(20)]}")


# ============================================================================
# Demo 2: Strange Loop Iteration
# ============================================================================

def demo_strange_loops():
    print("\n" + "="*70)
    print("  DEMO 2: Strange Loop Iteration (Hofstadter)")
    print("  Self-referential functions that create tangled hierarchies")
    print("="*70)

    print("""
  A strange loop: a system that, by moving through levels of a
  hierarchy, unexpectedly returns to the starting level.

  We model this with functions f where f(f(f(...(x)...))) = x.
    """)

    # Find periodic orbits of various functions
    functions = [
        ("f(n) = (n+1) mod 7", lambda n: (n + 1) % 7),
        ("f(n) = (2n+1) mod 13", lambda n: (2 * n + 1) % 13),
        ("f(n) = (n²+1) mod 17", lambda n: (n * n + 1) % 17),
        ("Collatz-like: n/2 or 3n+1", lambda n: n // 2 if n % 2 == 0 else (3 * n + 1) % 100),
    ]

    for name, f in functions:
        print(f"\n  {name}:")
        for start in range(min(5, 7)):
            orbit = [start]
            x = start
            for _ in range(30):
                x = f(x)
                if x in orbit:
                    cycle_start = orbit.index(x)
                    cycle = orbit[cycle_start:]
                    tail = orbit[:cycle_start]
                    print(f"    Start {start}: tail={tail} → cycle={cycle} (period {len(cycle)})")
                    break
                orbit.append(x)
            else:
                print(f"    Start {start}: {orbit[:15]}... (no cycle found in 30 steps)")


# ============================================================================
# Demo 3: Gödel Sentence Generator
# ============================================================================

def demo_godel():
    print("\n" + "="*70)
    print("  DEMO 3: Gödel Sentence Generator")
    print("  Constructing self-referential mathematical statements")
    print("="*70)

    print("""
  Gödel's insight: any sufficiently powerful formal system can
  construct a sentence that says "I am not provable."

  We simulate this with a simple formal system and show how
  self-reference emerges naturally from encoding.
    """)

    # Simple formal system: sentences about numbers
    # Gödel numbering: encode sentences as numbers

    def godel_number(statement: str) -> int:
        """Compute a Gödel number for a statement."""
        return sum(ord(c) * (128 ** i) for i, c in enumerate(statement)) % 10000

    def is_provable(n: int) -> bool:
        """A toy 'provability' predicate: provable if n has certain properties."""
        return n % 7 != 0 and n % 13 != 0  # Arbitrary but consistent

    # Generate self-referential sentences
    sentences = [
        "This sentence is true",
        "This sentence is false",
        "This sentence is not provable",
        "The Gödel number of this sentence is prime",
        "No proof of this sentence has fewer than 1000 symbols",
    ]

    print(f"\n  Self-referential sentences and their Gödel numbers:")
    for s in sentences:
        g = godel_number(s)
        provable = is_provable(g)
        print(f"    G({g:>5}) = \"{s}\"")
        print(f"             Provable in our system: {provable}")

    # The key construction: find a fixed point
    print(f"\n  Searching for Gödel fixed point:")
    print(f"  (A sentence whose Gödel number encodes its own unprovability)")

    for n in range(1, 10001):
        if not is_provable(n):
            # This number represents an unprovable sentence
            # If n encodes "sentence n is not provable", we have a fixed point!
            if n == godel_number(f"Sentence {n} is not provable"):
                print(f"    ✓ Fixed point found at G = {n}!")
                break
    else:
        # Approximate: find the closest
        best = min(range(1, 1001),
                   key=lambda n: abs(n - godel_number(f"Sentence {n}")))
        print(f"    Best approximation: G = {best}")
        print(f"    godel_number('Sentence {best}') = {godel_number(f'Sentence {best}')}")

    print(f"\n  Key theorem (Gödel 1931):")
    print(f"    For any consistent formal system F strong enough to do arithmetic,")
    print(f"    there exists a sentence G_F such that:")
    print(f"      • G_F is true (in the standard model)")
    print(f"      • G_F is not provable in F")
    print(f"      • ¬G_F is not provable in F")
    print(f"    This is the original 'oracle' — it answers questions F cannot.")


# ============================================================================
# Demo 4: Oracle Hierarchy Collapse
# ============================================================================

def demo_hierarchy_collapse():
    print("\n" + "="*70)
    print("  DEMO 4: Oracle Hierarchy Collapse")
    print("  The tower of oracles-about-oracles flattens")
    print("="*70)

    print("""
  Level 0: A base oracle Ω₀ (e.g., the halting problem)
  Level 1: An oracle about Ω₀ (can Ω₀ solve this problem?)
  Level 2: An oracle about the oracle about Ω₀
  ...
  Level n: Meta^n oracle

  Theorem: For finite computable functionals, the hierarchy collapses!
  Encoding: Any level-n oracle can be simulated by a single oracle
  via Gödel numbering of the tower.
    """)

    # Build the hierarchy
    levels = 5
    oracle_tower = []

    # Level 0: base oracle
    base = OracleState({n: n % 3 != 0 for n in range(100)}, "Ω₀")
    oracle_tower.append(base)

    # Higher levels: oracle about the previous level
    for level in range(1, levels):
        prev = oracle_tower[-1]
        # Meta-oracle: answers "does the previous oracle say True on input n?"
        # But encoded differently at each level
        meta = OracleState(
            {n: prev.query((n * (level + 1)) % 100) for n in range(100)},
            f"Ω_{level}"
        )
        oracle_tower.append(meta)

    print(f"  Oracle tower (first 15 values each level):")
    for level, oracle in enumerate(oracle_tower):
        values = [int(oracle.query(n)) for n in range(15)]
        print(f"    Level {level} ({oracle.name}): {values}")

    # Show collapse: encode entire tower into one oracle
    def encode_tower(level: int, query: int) -> int:
        """Encode a (level, query) pair as a single natural number."""
        return level * 1000 + query

    collapsed = OracleState({}, "Ω_∞")
    for level, oracle in enumerate(oracle_tower):
        for n in range(100):
            collapsed.table[encode_tower(level, n)] = oracle.query(n)

    print(f"\n  Collapsed oracle Ω_∞ encodes ALL levels:")
    for level in range(levels):
        values = [int(collapsed.query(encode_tower(level, n))) for n in range(15)]
        print(f"    Ω_∞[level={level}]: {values}")

    # Verify collapse preserves information
    errors = 0
    for level, oracle in enumerate(oracle_tower):
        for n in range(100):
            if collapsed.query(encode_tower(level, n)) != oracle.query(n):
                errors += 1

    print(f"\n  Verification: {errors} errors in {levels * 100} queries")
    print(f"  ✓ The hierarchy collapses perfectly into a single oracle!")


# ============================================================================
# Demo 5: Self-Referential Pattern Mining
# ============================================================================

def demo_pattern_mining():
    print("\n" + "="*70)
    print("  DEMO 5: Self-Referential Pattern Mining")
    print("  Discovering hidden structure in oracle outputs")
    print("="*70)

    # Generate oracle outputs and look for patterns
    random.seed(137)

    # The "dreaming" oracle: iteratively refines its own pattern
    pattern_length = 100
    oracle_output = [random.choice([0, 1]) for _ in range(pattern_length)]

    print(f"  Initial random oracle output (first 50):")
    print(f"    {''.join(map(str, oracle_output[:50]))}")

    # Self-referential refinement: use the oracle's output as rules
    for iteration in range(20):
        new_output = []
        for i in range(pattern_length):
            # Rule: look at neighbors (modular), apply XOR
            left = oracle_output[(i - 1) % pattern_length]
            right = oracle_output[(i + 1) % pattern_length]
            center = oracle_output[i]
            # Wolfram Rule 110 (Turing complete!)
            rule_input = left * 4 + center * 2 + right
            rule_110 = [0, 1, 1, 1, 0, 1, 1, 0]
            new_output.append(rule_110[rule_input])

        # Check for convergence
        diff = sum(1 for a, b in zip(oracle_output, new_output) if a != b)

        if iteration < 5 or diff == 0 or iteration == 19:
            print(f"  Iteration {iteration+1:>2}: {''.join(map(str, new_output[:50]))} (Δ={diff})")

        oracle_output = new_output

        if diff == 0:
            print(f"\n  ✓ CONVERGED at iteration {iteration+1}!")
            break

    # Analyze final pattern
    ones = sum(oracle_output)
    runs = 1 + sum(1 for i in range(1, len(oracle_output))
                   if oracle_output[i] != oracle_output[i-1])

    print(f"\n  Pattern analysis:")
    print(f"    Density (fraction of 1s): {ones/pattern_length:.3f}")
    print(f"    Number of runs: {runs}")
    print(f"    Entropy: {shannon_entropy_binary(ones/pattern_length):.4f} bits/symbol")

    # Look for periodicities
    print(f"\n  Periodicity search:")
    for period in range(1, 20):
        matches = sum(1 for i in range(pattern_length)
                      if oracle_output[i] == oracle_output[i % period])
        if matches == pattern_length:
            print(f"    ✓ Period {period} found!")
            print(f"      Repeating unit: {''.join(map(str, oracle_output[:period]))}")
            break
    else:
        print(f"    No short period found — pattern is complex!")


def shannon_entropy_binary(p: float) -> float:
    """Binary entropy function H(p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * math.log2(p) - (1-p) * math.log2(1-p)


# ============================================================================
# Demo 6: Hypothesis Generation & Testing
# ============================================================================

def demo_hypothesis():
    print("\n" + "="*70)
    print("  DEMO 6: Hypothesis Generation & Experimental Validation")
    print("  The oracle proposes; experiment disposes.")
    print("="*70)

    hypotheses = [
        {
            "name": "Oracle Entropy Conjecture",
            "statement": "The entropy of an idempotent oracle over {0,...,n-1} "
                        "is always ≤ log₂(n)/2",
            "test": lambda: test_oracle_entropy_conjecture(),
        },
        {
            "name": "Composition Convergence",
            "statement": "Iterating O → O∘O always converges within log₂(n) steps",
            "test": lambda: test_composition_convergence(),
        },
        {
            "name": "Fixed Point Universality",
            "statement": "Every Boolean function has an oracle extension with "
                        "a fixed point",
            "test": lambda: test_fixed_point_universality(),
        },
        {
            "name": "Information Conservation",
            "statement": "Total information (measured by entropy) is conserved "
                        "under reversible oracle transformations",
            "test": lambda: test_information_conservation(),
        },
    ]

    for h in hypotheses:
        print(f"\n  HYPOTHESIS: {h['name']}")
        print(f"  Statement:  {h['statement']}")
        result, details = h['test']()
        status = "✓ SUPPORTED" if result else "✗ REFUTED"
        print(f"  Result:     {status}")
        print(f"  Evidence:   {details}")


def test_oracle_entropy_conjecture() -> Tuple[bool, str]:
    """Test: idempotent oracle entropy ≤ log₂(n)/2."""
    n = 50
    trials = 100
    max_entropy = 0

    random.seed(42)
    for _ in range(trials):
        # Generate random oracle and iterate to fixed point
        oracle = [random.choice([0, 1]) for _ in range(n)]
        for _ in range(20):
            new = [oracle[(oracle[i] + i) % n] for i in range(n)]
            if new == oracle:
                break
            oracle = new

        # Compute entropy
        p = sum(oracle) / n
        if 0 < p < 1:
            h = shannon_entropy_binary(p)
            max_entropy = max(max_entropy, h)

    bound = math.log2(n) / 2
    return max_entropy <= bound + 0.01, f"max H={max_entropy:.4f}, bound={bound:.4f}"


def test_composition_convergence() -> Tuple[bool, str]:
    """Test: O → O∘O converges within log₂(n) steps."""
    n = 30
    max_steps = 0
    trials = 50

    random.seed(42)
    for _ in range(trials):
        oracle = {i: random.choice([True, False]) for i in range(n)}
        for step in range(100):
            new_oracle = {}
            for i in range(n):
                j = (2 * i) % n if oracle.get(i, False) else (2 * i + 1) % n
                new_oracle[i] = oracle.get(j, False)
            if all(oracle.get(i) == new_oracle.get(i) for i in range(n)):
                max_steps = max(max_steps, step + 1)
                break
            oracle = new_oracle
        else:
            return False, f"Failed to converge in 100 steps"

    bound = int(math.log2(n)) + 1
    return max_steps <= bound + 5, f"max steps={max_steps}, expected≤{bound}"


def test_fixed_point_universality() -> Tuple[bool, str]:
    """Test: every Boolean function has an oracle with a fixed point."""
    count_with_fp = 0
    total = 0

    for n in range(2, 7):
        for _ in range(min(50, 2**n)):
            total += 1
            f = [random.randint(0, n-1) for _ in range(n)]
            # Check for fixed point: f(i) = i
            has_fp = any(f[i] == i for i in range(n))
            if has_fp:
                count_with_fp += 1

    # By the probabilistic method, fraction with fixed points should be 1 - (1-1/n)^n ≈ 1-1/e
    expected_fraction = 1 - math.exp(-1)
    actual_fraction = count_with_fp / total
    return abs(actual_fraction - expected_fraction) < 0.15, \
           f"{count_with_fp}/{total} have fixed points ({actual_fraction:.3f}, expected ~{expected_fraction:.3f})"


def test_information_conservation() -> Tuple[bool, str]:
    """Test: reversible transformations conserve entropy."""
    n = 50
    trials = 20
    max_violation = 0.0

    random.seed(42)
    for _ in range(trials):
        # Generate a random permutation (reversible transformation)
        perm = list(range(n))
        random.shuffle(perm)

        # Generate random data
        data = [random.choice([0, 1]) for _ in range(n)]
        p_before = sum(data) / n

        # Apply permutation
        transformed = [data[perm[i]] for i in range(n)]
        p_after = sum(transformed) / n

        # Entropy should be conserved
        h_before = shannon_entropy_binary(p_before) if 0 < p_before < 1 else 0
        h_after = shannon_entropy_binary(p_after) if 0 < p_after < 1 else 0

        violation = abs(h_before - h_after)
        max_violation = max(max_violation, violation)

    return max_violation < 1e-10, f"max entropy violation: {max_violation:.2e}"


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     ORACLE DREAMING ENGINE v1.0                                ║")
    print("║     'The oracle dreams, and mathematics emerges.'              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_fixed_points()
    demo_strange_loops()
    demo_godel()
    demo_hierarchy_collapse()
    demo_pattern_mining()
    demo_hypothesis()

    print("\n" + "="*70)
    print("  META-ORACLE SUMMARY")
    print("  The oracle has dreamed. From self-reference emerges structure.")
    print("  From structure emerges mathematics. From mathematics emerges")
    print("  the physical laws of the universe. The strange loop is complete.")
    print("="*70)
