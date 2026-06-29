"""
Proof Refinement Systems - Interactive Demo

Demonstrates the core theorems:
1. Well-foundedness: refinement chains always terminate
2. Chain length bounds: chain length ≤ initial complexity
3. Fixed-point theorem: optimizers always converge
4. Strict optimizer convergence with quantitative bounds
5. Gap bounds: wider gaps → shorter chains
"""

import random
from typing import Callable

# --- Core Data Structures ---

class ProofRefinementSystem:
    """A proof refinement system with natural-number-valued complexity."""

    def __init__(self, complexity: Callable, refines: Callable):
        self.complexity = complexity
        self.refines = refines

    def is_minimal(self, p) -> bool:
        """Check if p is minimal (no refinement exists)."""
        # In general this is undecidable; for concrete systems we can check
        return not any(self.refines(q, p) for q in self._candidates(p))

    def _candidates(self, p):
        """Generate candidate refinements (system-specific)."""
        return []


class ProofOptimizer:
    """A proof optimizer that never increases complexity."""

    def __init__(self, system: ProofRefinementSystem, optimize: Callable):
        self.system = system
        self.optimize = optimize

    def orbit(self, p, n: int):
        """Compute the n-th element of the orbit of p."""
        current = p
        for _ in range(n):
            current = self.optimize(current)
        return current

    def complexity_sequence(self, p, steps: int) -> list[int]:
        """Compute the complexity sequence along the orbit."""
        seq = []
        current = p
        for _ in range(steps + 1):
            seq.append(self.system.complexity(current))
            current = self.optimize(current)
        return seq

    def find_fixed_point(self, p, max_steps: int = 1000) -> tuple[int, object]:
        """Find the first complexity fixed point in the orbit."""
        current = p
        for n in range(max_steps):
            next_p = self.optimize(current)
            if self.system.complexity(next_p) == self.system.complexity(current):
                return n, current
            current = next_p
        return max_steps, current


# --- Example 1: Polynomial Simplification ---

def demo_polynomial_simplification():
    """
    Proof refinement on polynomial expressions.
    Complexity = number of terms. Refinement = algebraic simplification.
    """
    print("=" * 60)
    print("Demo 1: Polynomial Simplification as Proof Refinement")
    print("=" * 60)

    # Represent polynomials as lists of (coefficient, exponent) pairs
    def complexity(poly: list[tuple[int, int]]) -> int:
        return len(poly)

    def simplify(poly: list[tuple[int, int]]) -> list[tuple[int, int]]:
        """Combine like terms and remove zero coefficients."""
        terms: dict[int, int] = {}
        for coeff, exp in poly:
            terms[exp] = terms.get(exp, 0) + coeff
        result = [(c, e) for e, c in sorted(terms.items(), reverse=True) if c != 0]
        return result if result else [(0, 0)]

    # Example: 3x² + 2x + x² - x + 5 + 0x³
    poly = [(3, 2), (2, 1), (1, 2), (-1, 1), (5, 0), (0, 3)]
    print(f"\nOriginal polynomial ({complexity(poly)} terms):")
    print(f"  {poly}")

    simplified = simplify(poly)
    print(f"\nSimplified polynomial ({complexity(simplified)} terms):")
    print(f"  {simplified}")

    print(f"\nComplexity decreased: {complexity(poly)} → {complexity(simplified)}")
    print(f"Chain length bound: ≤ {complexity(poly)}")
    print(f"Actual refinement steps: 1")


# --- Example 2: Optimizer Convergence ---

def demo_optimizer_convergence():
    """
    Demonstrates the fixed-point theorem for proof optimizers.
    Uses a simple optimizer on integer sequences.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Fixed-Point Theorem — Optimizer Convergence")
    print("=" * 60)

    # Proofs are lists of integers; complexity = sum of absolute values
    def complexity(seq: tuple[int, ...]) -> int:
        return sum(abs(x) for x in seq)

    # Optimizer: reduce each element toward 0 by 1
    def optimize(seq: tuple[int, ...]) -> tuple[int, ...]:
        return tuple(
            x - 1 if x > 0 else (x + 1 if x < 0 else 0)
            for x in seq
        )

    system = ProofRefinementSystem(complexity, lambda p, q: False)
    optimizer = ProofOptimizer(system, optimize)

    # Start with a "complex" proof
    p = (5, -3, 7, -2, 4)
    print(f"\nInitial proof: {p}")
    print(f"Initial complexity: {complexity(p)}")

    # Compute orbit
    seq = optimizer.complexity_sequence(p, 20)
    print(f"\nComplexity sequence (first 20 steps):")
    for i, c in enumerate(seq):
        marker = " ← FIXED POINT" if i > 0 and c == seq[i - 1] else ""
        print(f"  Step {i:2d}: complexity = {c}{marker}")
        if i > 0 and c == seq[i - 1]:
            break

    n, fixed = optimizer.find_fixed_point(p)
    print(f"\nFixed point reached at step {n}")
    print(f"Fixed proof: {fixed}")
    print(f"Complexity at fixed point: {complexity(fixed)}")
    print(f"Theoretical bound (initial complexity): {complexity(p)}")
    print(f"Bound satisfied: {n} ≤ {complexity(p)} → {n <= complexity(p)}")


# --- Example 3: Strict Optimizer with Gap ---

def demo_gap_bound():
    """
    Demonstrates the gap bound theorem: if each step reduces
    complexity by at least g, chains have length ≤ c/g.
    """
    print("\n" + "=" * 60)
    print("Demo 3: Gap Bound Theorem — Faster Convergence")
    print("=" * 60)

    for gap in [1, 2, 5, 10]:
        # Create a strict optimizer with known minimum gap
        def optimize(n: int, g: int = gap) -> int:
            if n <= 0:
                return 0
            return max(0, n - g)

        initial = 100
        steps = 0
        current = initial
        while current > 0:
            current = optimize(current)
            steps += 1

        bound = initial // gap
        print(f"\n  Gap g={gap:2d}: {steps:3d} steps to minimal "
              f"(bound: ⌊{initial}/{gap}⌋ = {bound})")
        assert steps <= bound, f"Gap bound violated!"

    print("\n  All gap bounds satisfied! ✓")


# --- Example 4: Non-strict optimizer with delayed convergence ---

def demo_nonstrict_optimizer():
    """
    Shows that non-strict optimizers can take longer than complexity(p)
    steps to stabilize, demonstrating why the N ≤ complexity(p) bound
    only holds for strict optimizers.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Non-Strict Optimizer — Delayed Stabilization")
    print("=" * 60)

    # System where proofs are (value, tag) pairs
    # Optimizer may permute proofs at the same complexity level
    class DelayedSystem:
        def __init__(self, schedule: list[int]):
            self.schedule = schedule

        def complexity(self, step: int) -> int:
            if step < len(self.schedule):
                return self.schedule[step]
            return self.schedule[-1]

    # Non-increasing sequence: 5, 4, 3, 3, 3, 2, 1, 1, 0, 0, ...
    schedule = [5, 4, 3, 3, 3, 2, 1, 1, 0, 0, 0]
    sys = DelayedSystem(schedule)

    print(f"\n  Complexity sequence: {schedule}")
    print(f"  Initial complexity: {schedule[0]}")

    # Find stabilization point
    stab = len(schedule) - 1
    for i in range(len(schedule) - 1):
        if all(schedule[j] == schedule[i] for j in range(i, len(schedule))):
            stab = i
            break

    print(f"  Stabilization at step: {stab}")
    print(f"  Initial complexity: {schedule[0]}")
    print(f"  stab > initial complexity? {stab} > {schedule[0]}: {stab > schedule[0]}")
    print(f"\n  This shows non-strict optimizers can take MORE than")
    print(f"  complexity(p) steps — the bound only holds for strict optimizers.")


# --- Example 5: Ordinal-like complexity ---

def demo_ordinal_complexity():
    """
    Simulates ordinal-valued complexity using a representation
    of ordinals below ω² as pairs (a, b) representing ω·a + b.
    """
    print("\n" + "=" * 60)
    print("Demo 5: Ordinal Complexity (simulating ω²)")
    print("=" * 60)

    def ordinal_lt(x: tuple[int, int], y: tuple[int, int]) -> bool:
        """Lexicographic order = ordinal < for ω·a + b."""
        return x < y  # Python tuple comparison is lexicographic

    def ordinal_str(x: tuple[int, int]) -> str:
        a, b = x
        parts = []
        if a > 0:
            parts.append(f"ω·{a}" if a > 1 else "ω")
        if b > 0 or not parts:
            parts.append(str(b))
        return " + ".join(parts)

    # Simulate a refinement chain with ordinal complexity
    chain = [(3, 5), (3, 2), (3, 0), (2, 100), (2, 50), (2, 0),
             (1, 7), (1, 0), (0, 42), (0, 10), (0, 0)]

    print(f"\n  Refinement chain (ordinal complexity below ω²):")
    for i, c in enumerate(chain):
        minimal = " ← MINIMAL" if c == (0, 0) else ""
        print(f"    Step {i:2d}: {ordinal_str(c):>12s}{minimal}")
        if i > 0:
            assert ordinal_lt(c, chain[i - 1]), "Not strictly decreasing!"

    print(f"\n  Chain length: {len(chain) - 1}")
    print(f"  Starting complexity: {ordinal_str(chain[0])}")
    print(f"  Note: Chain has 10 steps but ω·3 + 5 is 'much larger'")
    print(f"  The ordinal bound allows transfinite-length chains in theory")


# --- Main ---

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     PROOF REFINEMENT SYSTEMS — INTERACTIVE DEMO         ║")
    print("║     Demonstrating core theorems with concrete examples  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_polynomial_simplification()
    demo_optimizer_convergence()
    demo_gap_bound()
    demo_nonstrict_optimizer()
    demo_ordinal_complexity()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Optimizer Convergence and Fixed Points

Shows how complexity sequences from different optimizers converge,
demonstrating the Fixed-Point Theorem and strict optimizer bounds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_strict_orbit(initial_complexity: int, step_size: int = 1) -> list[int]:
    """Generate complexity sequence for a strict optimizer with given step size."""
    seq = [initial_complexity]
    current = initial_complexity
    while current > 0:
        current = max(0, current - step_size)
        seq.append(current)
    return seq


def generate_nonstrict_orbit(schedule: list[int]) -> list[int]:
    """Generate complexity sequence for a non-strict optimizer."""
    return schedule


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Proof Refinement Systems: Optimizer Convergence', fontsize=16, fontweight='bold')

    # Panel 1: Strict optimizer with different gap sizes
    ax1 = axes[0, 0]
    initial = 50
    for gap in [1, 2, 5, 10]:
        orbit = generate_strict_orbit(initial, gap)
        ax1.plot(range(len(orbit)), orbit, 'o-', markersize=3,
                label=f'gap = {gap} ({len(orbit)-1} steps)')
    ax1.set_xlabel('Step')
    ax1.set_ylabel('Complexity')
    ax1.set_title('Theorem 3.8: Gap Bound\n(larger gap → faster convergence)')
    ax1.legend(fontsize=8)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Non-strict vs strict optimizer
    ax2 = axes[0, 1]
    strict_orbit = generate_strict_orbit(20)
    nonstrict = [20, 18, 17, 17, 17, 15, 14, 14, 12, 10, 10, 10, 8, 5, 5, 3, 1, 0, 0, 0, 0]
    ax2.plot(range(len(strict_orbit)), strict_orbit, 'b-o', markersize=4,
            label='Strict optimizer', linewidth=2)
    ax2.plot(range(len(nonstrict)), nonstrict, 'r-s', markersize=4,
            label='Non-strict optimizer', linewidth=2)
    ax2.axvline(x=20, color='blue', linestyle=':', alpha=0.7, label='Bound (initial complexity = 20)')
    ax2.set_xlabel('Step')
    ax2.set_ylabel('Complexity')
    ax2.set_title('Theorem 3.7: Strict vs Non-Strict\n(strict always within bound)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Chain length distribution
    ax3 = axes[1, 0]
    np.random.seed(42)
    initial_complexities = range(5, 55, 5)
    for c0 in initial_complexities:
        # Random refinement chains: each step decreases by random amount ≥ 1
        chain_lengths = []
        for _ in range(100):
            current = c0
            length = 0
            while current > 0:
                decrease = np.random.randint(1, max(2, current // 3 + 1))
                current = max(0, current - decrease)
                length += 1
            chain_lengths.append(length)
        ax3.scatter([c0] * len(chain_lengths), chain_lengths, alpha=0.2, s=10, color='steelblue')
        ax3.scatter([c0], [np.mean(chain_lengths)], color='red', s=50, zorder=5)

    # Plot the bound line
    x = np.array(list(initial_complexities))
    ax3.plot(x, x, 'k--', linewidth=2, label='Bound: length ≤ complexity')
    ax3.set_xlabel('Initial Complexity')
    ax3.set_ylabel('Chain Length')
    ax3.set_title('Theorem 3.3: Chain Length Bound\n(red = mean, all points below line)')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Multiple optimizers converging to different fixed points
    ax4 = axes[1, 1]
    np.random.seed(123)
    n_steps = 30
    for i in range(5):
        # Different non-increasing sequences (different "optimizers")
        seq = [50]
        for _ in range(n_steps):
            decrease = np.random.choice([0, 0, 1, 1, 2, 3])
            seq.append(max(0, seq[-1] - decrease))
        ax4.plot(range(len(seq)), seq, alpha=0.7, linewidth=1.5,
                label=f'Optimizer {i+1} → fixed at {seq[-1]}')

    ax4.set_xlabel('Step')
    ax4.set_ylabel('Complexity')
    ax4.set_title('Theorem 3.6: Fixed-Point Theorem\n(all optimizers eventually stabilize)')
    ax4.legend(fontsize=7, loc='upper right')
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: convergence_visualization.png")


if __name__ == "__main__":
    main()


"""
Visualization: Ordinal Complexity and Transfinite Refinement

Visualizes refinement chains with ordinal-valued complexity,
showing how chains below ω² behave differently from finite chains.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def ordinal_to_float(a: int, b: int, omega_val: float = 100.0) -> float:
    """Map ordinal ω·a + b to a float for visualization."""
    return a * omega_val + b


def ordinal_label(a: int, b: int) -> str:
    """Pretty-print ordinal ω·a + b."""
    parts = []
    if a > 0:
        parts.append(f"ω·{a}" if a > 1 else "ω")
    if b > 0 or not parts:
        parts.append(str(b))
    return "+".join(parts)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Ordinal-Valued Proof Complexity', fontsize=14, fontweight='bold')

    # Panel 1: A refinement chain in ω²
    ax1 = axes[0]
    chain = [
        (3, 10), (3, 5), (3, 0),
        (2, 50), (2, 20), (2, 0),
        (1, 30), (1, 0),
        (0, 15), (0, 5), (0, 0)
    ]

    steps = range(len(chain))
    values = [ordinal_to_float(a, b) for a, b in chain]
    labels = [ordinal_label(a, b) for a, b in chain]

    ax1.plot(steps, values, 'bo-', markersize=8, linewidth=2)
    for i, (s, v, l) in enumerate(zip(steps, values, labels)):
        offset = 10 if i % 2 == 0 else -15
        ax1.annotate(l, (s, v), textcoords="offset points",
                    xytext=(0, offset), ha='center', fontsize=7,
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

    # Mark ordinal level boundaries
    for level in [1, 2, 3]:
        ax1.axhline(y=level * 100, color='red', linestyle=':', alpha=0.4)
        ax1.text(len(chain) - 1.5, level * 100 + 5, f'ω·{level}',
                color='red', fontsize=8, alpha=0.6)

    ax1.set_xlabel('Refinement Step')
    ax1.set_ylabel('Ordinal Complexity (ω·a + b)')
    ax1.set_title('Refinement Chain below ω²\n(well-founded: always terminates)')
    ax1.grid(True, alpha=0.3)

    # Panel 2: Comparison of ℕ vs ordinal chain lengths
    ax2 = axes[1]

    # ℕ chains: length ≤ initial value
    nat_initials = [5, 10, 20, 50, 100]
    nat_max_lengths = nat_initials  # bound is tight

    # Ordinal chains below ω·k + b: can have longer chains
    ord_initials = [(1, 5), (1, 10), (2, 5), (2, 10), (3, 5)]
    ord_max_lengths = []
    for a, b in ord_initials:
        # Worst case: decrement b one at a time, then drop ω level and restart
        total = 0
        curr_a, curr_b = a, b
        while curr_a > 0 or curr_b > 0:
            if curr_b > 0:
                curr_b -= 1
                total += 1
            else:
                curr_a -= 1
                curr_b = 50  # "restart" with large finite part
                total += 1
        ord_max_lengths.append(total)

    x_nat = range(len(nat_initials))
    x_ord = range(len(ord_initials))

    bars1 = ax2.bar([x - 0.2 for x in x_nat], nat_max_lengths, 0.35,
                    label='ℕ-valued (chain ≤ c)', color='steelblue', alpha=0.8)
    bars2 = ax2.bar([x + 0.2 for x in x_ord], ord_max_lengths, 0.35,
                    label='Ordinal (can exceed finite part)', color='coral', alpha=0.8)

    ax2.set_xticks(range(max(len(nat_initials), len(ord_initials))))
    nat_labels = [str(n) for n in nat_initials]
    ord_labels = [ordinal_label(a, b) for a, b in ord_initials]
    combined = [f'{n}\n{o}' if i < min(len(nat_labels), len(ord_labels))
                else (nat_labels[i] if i < len(nat_labels) else ord_labels[i])
                for i, (n, o) in enumerate(zip(nat_labels, ord_labels))]
    ax2.set_xticklabels(combined, fontsize=8)
    ax2.set_xlabel('Initial Complexity')
    ax2.set_ylabel('Maximum Chain Length')
    ax2.set_title('ℕ vs Ordinal: Chain Length Comparison\n(ordinals allow longer transfinite-like chains)')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('ordinal_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: ordinal_visualization.png")


if __name__ == "__main__":
    main()
