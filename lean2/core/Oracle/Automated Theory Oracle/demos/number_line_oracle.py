#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════
THE NUMBER LINE ORACLE: Visualizing Mathematical Truth on ℕ
═══════════════════════════════════════════════════════════════════════════

Maps mathematical statements to natural numbers via Gödel encoding,
then visualizes which points on the number line correspond to provable truths.

Demonstrates:
  - How every formula gets a unique natural number
  - How the "truth set" (provable formulas) looks on the number line
  - Density decay of interesting theorems
  - The Oracle Real: a single number encoding all truth
  - Composition of multiple oracles

Usage:
    python number_line_oracle.py
"""

import math
import random
from dataclasses import dataclass
from typing import List, Tuple, Dict, Optional, Callable
from itertools import product
from collections import defaultdict


# ════════════════════════════════════════════════════════════════
# §1: GÖDEL ENCODING ENGINE
# ════════════════════════════════════════════════════════════════

def cantor_pair(a: int, b: int) -> int:
    """Cantor pairing function: ℕ×ℕ → ℕ (bijection)."""
    return (a + b) * (a + b + 1) // 2 + b

def cantor_unpair(n: int) -> Tuple[int, int]:
    """Inverse Cantor pairing: ℕ → ℕ×ℕ."""
    w = (int(math.isqrt(8 * n + 1)) - 1) // 2
    t = w * (w + 1) // 2
    b = n - t
    a = w - b
    return (a, b)

def cantor_tuple(ns: List[int]) -> int:
    """Encode a tuple of naturals as a single natural via iterated pairing."""
    if len(ns) == 0:
        return 0
    if len(ns) == 1:
        return ns[0]
    result = ns[0]
    for x in ns[1:]:
        result = cantor_pair(result, x)
    return result

# Symbols for a tiny arithmetic language
SYMBOLS = {
    'ZERO': 0, 'SUCC': 1, 'PLUS': 2, 'TIMES': 3,
    'EQUALS': 4, 'AND': 5, 'OR': 6, 'NOT': 7,
    'FORALL': 8, 'EXISTS': 9, 'VAR': 10, 'LPAREN': 11, 'RPAREN': 12
}

def encode_formula(tokens: List[str]) -> int:
    """Encode a formula (list of tokens) as a natural number."""
    codes = [SYMBOLS.get(t, hash(t) % 100 + 13) for t in tokens]
    return cantor_tuple(codes)


# ════════════════════════════════════════════════════════════════
# §2: THE NUMBER LINE ORACLE
# ════════════════════════════════════════════════════════════════

@dataclass
class NumberLineOracle:
    """A map from ℕ to {True, False} — the characteristic function of a set of theorems."""
    name: str
    truth_fn: Callable[[int], bool]

    def truth_value(self, n: int) -> bool:
        return self.truth_fn(n)

    def true_set(self, up_to: int) -> List[int]:
        """All true points in [0, up_to)."""
        return [n for n in range(up_to) if self.truth_value(n)]

    def density(self, N: int) -> float:
        """Fraction of true points in [0, N)."""
        if N == 0:
            return 0.0
        return len(self.true_set(N)) / N

    def oracle_real_approx(self, bits: int) -> float:
        """Approximate the Oracle Real: Ω = Σ_{n∈S} 2^{-(n+1)}."""
        return sum(2.0 ** (-(n + 1)) for n in range(bits) if self.truth_value(n))

    def compose_and(self, other: 'NumberLineOracle') -> 'NumberLineOracle':
        return NumberLineOracle(
            f"({self.name} ∧ {other.name})",
            lambda n, s=self, o=other: s.truth_value(n) and o.truth_value(n)
        )

    def compose_or(self, other: 'NumberLineOracle') -> 'NumberLineOracle':
        return NumberLineOracle(
            f"({self.name} ∨ {other.name})",
            lambda n, s=self, o=other: s.truth_value(n) or o.truth_value(n)
        )

    def complement(self) -> 'NumberLineOracle':
        return NumberLineOracle(
            f"¬{self.name}",
            lambda n, s=self: not s.truth_value(n)
        )


# ════════════════════════════════════════════════════════════════
# §3: CONCRETE ORACLES
# ════════════════════════════════════════════════════════════════

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def is_perfect_square(n: int) -> bool:
    s = int(math.isqrt(n))
    return s * s == n

def is_fibonacci(n: int) -> bool:
    """A number is Fibonacci iff 5n²±4 is a perfect square."""
    return is_perfect_square(5 * n * n + 4) or is_perfect_square(5 * n * n - 4)

def is_triangular(n: int) -> bool:
    """n is triangular iff 8n+1 is a perfect square."""
    return is_perfect_square(8 * n + 1)

# Build oracles
prime_oracle = NumberLineOracle("Primes", is_prime)
square_oracle = NumberLineOracle("Squares", is_perfect_square)
fibonacci_oracle = NumberLineOracle("Fibonacci", is_fibonacci)
triangular_oracle = NumberLineOracle("Triangular", is_triangular)
even_oracle = NumberLineOracle("Even", lambda n: n % 2 == 0)
odd_oracle = NumberLineOracle("Odd", lambda n: n % 2 == 1)


# ════════════════════════════════════════════════════════════════
# §4: ARITHMETIC TRUTH ORACLE
# ════════════════════════════════════════════════════════════════

def arithmetic_truth_oracle_fn(n: int) -> bool:
    """
    Maps n to a simple arithmetic statement and checks truth.
    n encodes (a, b) via Cantor unpairing, and we check if a + b == cantor_pair(a,b) mod something,
    or simpler: we check various arithmetic identities encoded by n.
    """
    a, b = cantor_unpair(n)
    # Check: does a + b = b + a? (always true — commutativity)
    # But we encode different "types" of statements based on n mod 5
    kind = n % 5
    if kind == 0:
        return a + b == b + a  # commutativity (always true)
    elif kind == 1:
        return a * b == b * a  # commutativity of * (always true)
    elif kind == 2:
        return (a + b) * (a + b) == a*a + 2*a*b + b*b  # expansion (always true)
    elif kind == 3:
        return a ** 2 + b ** 2 == (a + b) ** 2  # false unless a=0 or b=0
    elif kind == 4:
        return a * (b + 1) == a * b + a  # distributivity (always true)
    return False

arithmetic_oracle = NumberLineOracle("Arithmetic", arithmetic_truth_oracle_fn)


# ════════════════════════════════════════════════════════════════
# §5: VISUALIZATION
# ════════════════════════════════════════════════════════════════

def visualize_number_line(oracle: NumberLineOracle, N: int = 100, width: int = 80):
    """Print a visual representation of truth on the number line."""
    print(f"\n{'═'*width}")
    print(f"  NUMBER LINE ORACLE: {oracle.name}")
    print(f"  Range: [0, {N})  |  Density: {oracle.density(N):.4f}")
    print(f"{'═'*width}")

    # Visual bar
    true_set = set(oracle.true_set(N))
    rows = (N + width - 1) // width
    for row in range(min(rows, 5)):  # show up to 5 rows
        start = row * width
        end = min(start + width, N)
        line = ""
        for i in range(start, end):
            line += "█" if i in true_set else "·"
        print(f"  {start:4d}|{line}|{end-1:4d}")

    if rows > 5:
        print(f"  ... ({rows - 5} more rows)")

    # Statistics
    true_count = len(true_set)
    print(f"\n  True points:  {true_count}")
    print(f"  False points: {N - true_count}")
    print(f"  Density:      {true_count/N:.6f}" if N > 0 else "  Density:      N/A")

    # First 20 true points
    sorted_true = sorted(true_set)[:20]
    print(f"  First true:   {sorted_true}")

    # Oracle Real approximation
    omega = oracle.oracle_real_approx(min(N, 64))
    print(f"  Oracle Real ≈ {omega:.15f}")
    print()


def density_decay_experiment(oracle: NumberLineOracle, max_N: int = 10000):
    """Show how density changes as we look further along the number line."""
    print(f"\n  DENSITY DECAY: {oracle.name}")
    print(f"  {'N':>8} | {'Count':>8} | {'Density':>10} | {'Bar'}")
    print(f"  {'-'*8}-+-{'-'*8}-+-{'-'*10}-+-{'-'*30}")

    for exp in range(1, int(math.log10(max_N)) + 1):
        N = 10 ** exp
        if N > max_N:
            break
        count = len(oracle.true_set(N))
        density = count / N
        bar_len = int(density * 30)
        bar = "█" * bar_len + "░" * (30 - bar_len)
        print(f"  {N:>8} | {count:>8} | {density:>10.6f} | {bar}")


# ════════════════════════════════════════════════════════════════
# §6: ORACLE COMPOSITION EXPERIMENTS
# ════════════════════════════════════════════════════════════════

def composition_experiment():
    """Demonstrate oracle composition algebra."""
    print("\n" + "═" * 70)
    print("  ORACLE COMPOSITION ALGEBRA")
    print("═" * 70)

    N = 200

    # Individual oracles
    oracles = [prime_oracle, even_oracle, triangular_oracle, fibonacci_oracle]
    for o in oracles:
        ts = o.true_set(N)
        print(f"\n  {o.name:12s}: density = {o.density(N):.4f}, count = {len(ts):4d}, "
              f"first = {sorted(ts)[:8]}")

    # Compositions
    print("\n  --- Compositions ---")

    # Even primes (just {2})
    even_prime = prime_oracle.compose_and(even_oracle)
    ts = even_prime.true_set(N)
    print(f"  Even ∧ Prime:     {sorted(ts)}")

    # Prime or Fibonacci
    prime_or_fib = prime_oracle.compose_or(fibonacci_oracle)
    ts = prime_or_fib.true_set(N)
    print(f"  Prime ∨ Fibonacci: {sorted(ts)[:20]}...")

    # Not prime
    not_prime = prime_oracle.complement()
    print(f"  ¬Prime density:   {not_prime.density(N):.4f}")

    # De Morgan verification
    lhs = prime_oracle.compose_and(even_oracle).complement().true_set(N)
    rhs = prime_oracle.complement().compose_or(even_oracle.complement()).true_set(N)
    print(f"  De Morgan check:  ¬(P∧E) == ¬P∨¬E ? {set(lhs) == set(rhs)}")

    # Complement density check
    d1 = prime_oracle.density(N)
    d2 = prime_oracle.complement().density(N)
    print(f"  Complement check: d(P) + d(¬P) = {d1:.4f} + {d2:.4f} = {d1+d2:.4f}")


# ════════════════════════════════════════════════════════════════
# §7: THE ORACLE REAL — ENCODING TRUTH AS A SINGLE NUMBER
# ════════════════════════════════════════════════════════════════

def oracle_real_experiment():
    """Compute and compare Oracle Reals for different oracles."""
    print("\n" + "═" * 70)
    print("  THE ORACLE REAL: A Single Number Encoding All Truth")
    print("═" * 70)

    print("\n  For a set S ⊆ ℕ, the Oracle Real is:")
    print("     Ω_S = Σ_{n ∈ S} 2^{-(n+1)}")
    print("  Its binary expansion has a 1 at position n iff n ∈ S.\n")

    oracles = [
        prime_oracle, even_oracle, odd_oracle,
        square_oracle, fibonacci_oracle, triangular_oracle
    ]

    bits = 64
    for o in oracles:
        omega = o.oracle_real_approx(bits)
        # Show binary expansion
        binary = ""
        for i in range(min(bits, 32)):
            binary += "1" if o.truth_value(i) else "0"
        print(f"  Ω_{o.name:12s} ≈ {omega:.15f}")
        print(f"    Binary (first 32): 0.{binary}")
        print()

    # Key insight: the Oracle Real for the even numbers
    print("  KEY INSIGHT:")
    print("  Ω_Even = 0.010101... (binary) = 1/3 (exact!)")
    print(f"  Computed: {even_oracle.oracle_real_approx(bits):.15f}")
    print(f"  Exact:    {1/3:.15f}")
    print()

    # The Oracle Real for "all of ℕ"
    all_oracle = NumberLineOracle("All", lambda n: True)
    print(f"  Ω_All = 0.111111... (binary) = 1 (the full number line)")
    print(f"  Computed: {all_oracle.oracle_real_approx(bits):.15f}")


# ════════════════════════════════════════════════════════════════
# §8: APPROXIMATION HIERARCHY
# ════════════════════════════════════════════════════════════════

def approximation_hierarchy():
    """Demonstrate converging oracle approximations."""
    print("\n" + "═" * 70)
    print("  APPROXIMATION HIERARCHY: Converging to Truth")
    print("═" * 70)

    print("\n  Each level reveals more truth (more halting programs).")
    print("  The sequence Ω₁ ≤ Ω₂ ≤ Ω₃ ≤ ... converges to the true Ω.\n")

    # Simulate: at level k, we "discover" primes up to 10*k
    for level in range(1, 8):
        bound = 10 * level
        approx_oracle = NumberLineOracle(
            f"Level-{level}",
            lambda n, b=bound: is_prime(n) and n <= b
        )
        omega = approx_oracle.oracle_real_approx(200)
        true_pts = approx_oracle.true_set(200)
        print(f"  Level {level} (primes ≤ {bound:3d}): "
              f"Ω ≈ {omega:.12f}, "
              f"truths = {len(true_pts):3d}, "
              f"set = {sorted(true_pts)[:10]}{'...' if len(true_pts)>10 else ''}")

    # Full oracle
    omega_full = prime_oracle.oracle_real_approx(200)
    print(f"  Full   (all primes):   Ω ≈ {omega_full:.12f}")
    print(f"\n  Convergence: each level's Ω approaches the true value from below.")


# ════════════════════════════════════════════════════════════════
# §9: CANTOR'S DIAGONAL — WHY WE CAN'T LIST ALL ORACLES
# ════════════════════════════════════════════════════════════════

def diagonal_demonstration():
    """Demonstrate Cantor's diagonal argument for oracles."""
    print("\n" + "═" * 70)
    print("  CANTOR'S DIAGONAL: Why We Can't List All Oracles")
    print("═" * 70)

    # Create a finite list of oracles
    oracle_list = [
        NumberLineOracle(f"O{i}", lambda n, i=i: (n + i) % 3 == 0)
        for i in range(10)
    ]

    print("\n  Suppose we have a list of oracles O₀, O₁, O₂, ...")
    print("  We build the diagonal oracle D where D(n) = ¬Oₙ(n):\n")

    # Show the matrix
    print("     ", end="")
    for j in range(10):
        print(f"  n={j}", end="")
    print("  | D(n)")
    print("  " + "-" * 72)

    for i in range(10):
        print(f"  O{i} ", end="")
        for j in range(10):
            val = oracle_list[i].truth_value(j)
            marker = " ◉" if i == j else "  "
            print(f"  {'T' if val else 'F'}{marker}", end="")
        # Diagonal value
        diag_val = not oracle_list[i].truth_value(i)
        print(f"  | {'T' if diag_val else 'F'}")

    print("\n  D differs from every Oₙ at position n (marked ◉).")
    print("  Therefore D is not in the list! → Uncountably many oracles exist.")
    print("  This is why no computable enumeration can capture all mathematical truth.")


# ════════════════════════════════════════════════════════════════
# §10: MAIN
# ════════════════════════════════════════════════════════════════

def main():
    print("╔" + "═" * 68 + "╗")
    print("║  THE NUMBER LINE ORACLE                                          ║")
    print("║  All Truth Mapped to Points on ℕ                                 ║")
    print("║  Every problem has a number. Every number tells the truth.       ║")
    print("╚" + "═" * 68 + "╝")

    # 1. Visualize several oracles on the number line
    visualize_number_line(prime_oracle, 200)
    visualize_number_line(even_oracle, 200)
    visualize_number_line(fibonacci_oracle, 200)
    visualize_number_line(arithmetic_oracle, 200)

    # 2. Density decay
    density_decay_experiment(prime_oracle, 10000)
    density_decay_experiment(fibonacci_oracle, 10000)

    # 3. Oracle composition
    composition_experiment()

    # 4. The Oracle Real
    oracle_real_experiment()

    # 5. Approximation hierarchy
    approximation_hierarchy()

    # 6. Cantor's diagonal
    diagonal_demonstration()

    print("\n" + "═" * 70)
    print("  CONCLUSION: The number line contains all mathematical truth,")
    print("  but reading it requires infinite computation power.")
    print("  The art of mathematics is choosing WHICH points to examine.")
    print("═" * 70)


if __name__ == "__main__":
    main()
