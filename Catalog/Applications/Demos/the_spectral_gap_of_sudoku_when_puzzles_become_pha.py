#!/usr/bin/env python3
"""
Applications of Sudoku Spectral Gap Theory

Real-world applications of spectral gap analysis in constraint satisfaction:
1. Puzzle difficulty estimation
2. Random puzzle generation with controlled difficulty
3. Solution uniqueness detection
"""

import numpy as np
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass


@dataclass
class PuzzleDifficultyReport:
    """Report on the difficulty of a constraint satisfaction puzzle."""
    num_clues: int
    num_solutions: int
    spectral_gap: float
    estimated_mixing_time: float
    difficulty_class: str
    phase: str


def latin_square_solver(n: int, clues: Dict[Tuple[int, int], int] = None) -> List[np.ndarray]:
    """Enumerate all Latin squares of size n satisfying given clues."""
    if clues is None:
        clues = {}
    solutions = []

    def is_valid(grid, row, col, val):
        if val in grid[row, :col]:
            return False
        for r in range(row):
            if grid[r, col] == val:
                return False
        return True

    def solve(grid, pos):
        if pos == n * n:
            solutions.append(grid.copy())
            return
        row, col = pos // n, pos % n
        if (row, col) in clues:
            val = clues[(row, col)]
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
            return
        for val in range(1, n + 1):
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0

    grid = np.zeros((n, n), dtype=int)
    solve(grid, 0)
    return solutions


def estimate_puzzle_difficulty(n: int, clues: Dict[Tuple[int, int], int]) -> PuzzleDifficultyReport:
    """Estimate the difficulty of a puzzle from its spectral gap.

    The spectral gap of the swap Markov chain determines how hard it is
    to explore the solution space. A small gap means the solutions are
    hard to navigate between (hard puzzle), while a large gap means
    solutions flow freely (easy puzzle).

    Args:
        n: Grid size
        clues: Given clue positions and values

    Returns:
        Difficulty report
    """
    solutions = latin_square_solver(n, clues)
    num_solutions = len(solutions)
    density = len(clues) / (n * n)

    if num_solutions <= 1:
        return PuzzleDifficultyReport(
            num_clues=len(clues),
            num_solutions=num_solutions,
            spectral_gap=0.0,
            estimated_mixing_time=0.0,
            difficulty_class="determined" if num_solutions == 1 else "infeasible",
            phase="overconstrained"
        )

    # Build swap graph
    m = len(solutions)
    adj = np.zeros((m, m))
    for i in range(m):
        for j in range(i + 1, m):
            diff = solutions[i] != solutions[j]
            if np.sum(diff) == 2:
                positions = np.argwhere(diff)
                if positions[0][0] == positions[1][0]:
                    adj[i][j] = 1
                    adj[j][i] = 1

    # Stochastic matrix
    P = np.zeros((m, m))
    for i in range(m):
        degree = np.sum(adj[i])
        if degree > 0:
            P[i] = adj[i] / degree
        else:
            P[i, i] = 1.0

    # Spectral gap
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    gap = max(float(1.0 - eigenvalues[1]), 0.0)

    epsilon = 0.25
    mixing_time = (1.0 / gap) * (np.log(m) + np.log(4.0)) if gap > 1e-10 else float('inf')

    # Difficulty classification
    if gap > 0.3:
        difficulty = "easy"
    elif gap > 0.1:
        difficulty = "medium"
    elif gap > 0.01:
        difficulty = "hard"
    else:
        difficulty = "extreme"

    if density < 17 / 81:
        phase = "underconstrained"
    elif density < 30 / 81:
        phase = "critical"
    else:
        phase = "overconstrained"

    return PuzzleDifficultyReport(
        num_clues=len(clues),
        num_solutions=num_solutions,
        spectral_gap=gap,
        estimated_mixing_time=mixing_time,
        difficulty_class=difficulty,
        phase=phase
    )


def generate_puzzle_with_difficulty(n: int, target_difficulty: str = "medium",
                                    max_attempts: int = 100) -> Optional[Dict[Tuple[int, int], int]]:
    """Generate a puzzle with a target difficulty level.

    Uses the spectral gap to control difficulty:
    - easy: gap > 0.3 (many solutions, fast mixing)
    - medium: 0.1 < gap ≤ 0.3
    - hard: 0.01 < gap ≤ 0.1
    - extreme: gap ≤ 0.01

    Args:
        n: Grid size
        target_difficulty: Target difficulty level
        max_attempts: Maximum number of random attempts

    Returns:
        Clue dictionary or None if no puzzle found
    """
    all_solutions = latin_square_solver(n)
    if not all_solutions:
        return None

    answer = all_solutions[np.random.randint(len(all_solutions))]

    gap_ranges = {
        "easy": (0.3, 1.0),
        "medium": (0.1, 0.3),
        "hard": (0.01, 0.1),
        "extreme": (0.0, 0.01)
    }

    low, high = gap_ranges.get(target_difficulty, (0.1, 0.3))

    for _ in range(max_attempts):
        # Random number of clues
        num_clues = np.random.randint(1, n * n)
        positions = np.random.choice(n * n, size=num_clues, replace=False)

        clues = {}
        for pos in positions:
            r, c = pos // n, pos % n
            clues[(r, c)] = int(answer[r, c])

        report = estimate_puzzle_difficulty(n, clues)
        if low <= report.spectral_gap <= high and report.num_solutions > 1:
            return clues

    return None


def demonstrate_applications():
    """Demonstrate real-world applications."""
    print("=" * 70)
    print("APPLICATION 1: Puzzle Difficulty Estimation")
    print("=" * 70)
    print()

    n = 3
    # Easy puzzle: few clues
    easy_clues = {(0, 0): 1}
    report = estimate_puzzle_difficulty(n, easy_clues)
    print(f"Puzzle with {report.num_clues} clue(s):")
    print(f"  Solutions: {report.num_solutions}")
    print(f"  Spectral gap: {report.spectral_gap:.4f}")
    print(f"  Mixing time: {report.estimated_mixing_time:.1f}")
    print(f"  Difficulty: {report.difficulty_class}")
    print(f"  Phase: {report.phase}")
    print()

    # Harder puzzle: more clues
    hard_clues = {(0, 0): 1, (0, 1): 2, (1, 0): 3, (1, 1): 1, (2, 0): 2}
    report = estimate_puzzle_difficulty(n, hard_clues)
    print(f"Puzzle with {report.num_clues} clue(s):")
    print(f"  Solutions: {report.num_solutions}")
    print(f"  Spectral gap: {report.spectral_gap:.4f}")
    print(f"  Mixing time: {report.estimated_mixing_time:.1f}")
    print(f"  Difficulty: {report.difficulty_class}")
    print(f"  Phase: {report.phase}")
    print()

    # Determined puzzle
    det_clues = {(0, 0): 1, (0, 1): 2, (0, 2): 3,
                 (1, 0): 2, (1, 1): 3, (1, 2): 1}
    report = estimate_puzzle_difficulty(n, det_clues)
    print(f"Puzzle with {report.num_clues} clue(s):")
    print(f"  Solutions: {report.num_solutions}")
    print(f"  Spectral gap: {report.spectral_gap:.4f}")
    print(f"  Difficulty: {report.difficulty_class}")
    print(f"  Phase: {report.phase}")
    print()

    print("=" * 70)
    print("APPLICATION 2: Solution Uniqueness Detection")
    print("=" * 70)
    print()

    print("A spectral gap of 0 with 1 solution means the puzzle is uniquely determined.")
    print("This connects to the famous result that 17 is the minimum number of")
    print("clues for a unique Sudoku solution.")
    print()

    for k in range(0, n * n + 1):
        clues = {}
        answer = latin_square_solver(n)[0]
        for pos in range(k):
            r, c = pos // n, pos % n
            clues[(r, c)] = int(answer[r, c])
        solutions = latin_square_solver(n, clues)
        unique = "✓ UNIQUE" if len(solutions) == 1 else f"  {len(solutions)} solutions"
        print(f"  {k} clues: {unique}")

    print()
    print("=" * 70)
    print("APPLICATION 3: Random Puzzle Generation")
    print("=" * 70)
    print()

    np.random.seed(42)
    for difficulty in ["easy", "medium", "hard"]:
        clues = generate_puzzle_with_difficulty(n, difficulty)
        if clues:
            report = estimate_puzzle_difficulty(n, clues)
            print(f"Generated {difficulty} puzzle ({report.num_clues} clues):")
            print(f"  Gap: {report.spectral_gap:.4f}, Solutions: {report.num_solutions}")
        else:
            print(f"Could not generate {difficulty} puzzle")


if __name__ == "__main__":
    demonstrate_applications()


#!/usr/bin/env python3
"""
Sudoku Spectral Gap: Interactive Demonstration

Demonstrates the core theorems about spectral gaps and phase transitions
in constraint satisfaction problems, using small Sudoku-like grids.
"""

import numpy as np
from typing import List, Tuple, Optional

def generate_latin_square_solutions(n: int) -> List[np.ndarray]:
    """Generate all valid Latin squares of size n (for small n).

    A Latin square is an n×n grid where each row and column contains
    each symbol exactly once. This is the constraint structure underlying Sudoku.

    Args:
        n: Size of the Latin square

    Returns:
        List of all valid n×n Latin squares as numpy arrays
    """
    solutions = []

    def is_valid(grid, row, col, val):
        # Check row
        if val in grid[row, :col]:
            return False
        # Check column
        for r in range(row):
            if grid[r, col] == val:
                return False
        return True

    def solve(grid, pos):
        if pos == n * n:
            solutions.append(grid.copy())
            return
        row, col = pos // n, pos % n
        for val in range(1, n + 1):
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0

    grid = np.zeros((n, n), dtype=int)
    solve(grid, 0)
    return solutions


def build_swap_transition_matrix(solutions: List[np.ndarray], n: int) -> np.ndarray:
    """Build the transition matrix for the swap Markov chain.

    Two solutions are connected if one can be obtained from the other
    by swapping two entries in the same row (that maintain validity).

    Args:
        solutions: List of valid Latin squares
        n: Size of each Latin square

    Returns:
        Transition matrix as numpy array
    """
    m = len(solutions)
    if m == 0:
        return np.array([[]])

    # Check if two solutions differ by exactly one swap
    adj = np.zeros((m, m))
    for i in range(m):
        for j in range(i + 1, m):
            diff = solutions[i] != solutions[j]
            diff_count = np.sum(diff)
            if diff_count == 2:
                # Check if the two differing cells are in the same row
                diff_positions = np.argwhere(diff)
                if diff_positions[0][0] == diff_positions[1][0]:
                    adj[i][j] = 1
                    adj[j][i] = 1

    # Build stochastic matrix
    P = np.zeros((m, m))
    for i in range(m):
        degree = np.sum(adj[i])
        if degree > 0:
            for j in range(m):
                if adj[i][j] > 0:
                    P[i][j] = 1.0 / degree
        else:
            P[i][i] = 1.0  # Absorbing state

    return P


def compute_spectral_gap(P: np.ndarray) -> float:
    """Compute the spectral gap of a stochastic matrix.

    The spectral gap is 1 - |λ₂| where λ₂ is the second largest
    eigenvalue by absolute value.

    Args:
        P: Stochastic matrix

    Returns:
        Spectral gap value
    """
    if P.size == 0 or P.shape[0] <= 1:
        return 0.0

    eigenvalues = np.linalg.eigvals(P)
    eigenvalues = np.sort(np.abs(eigenvalues))[::-1]

    if len(eigenvalues) < 2:
        return 0.0

    return float(1.0 - eigenvalues[1])


def mixing_time_bound(gap: float, epsilon: float, n: int) -> float:
    """Compute the mixing time bound from the spectral gap.

    T_mix(ε) ≤ (1/γ) · (ln(n) + ln(1/ε))

    Args:
        gap: Spectral gap value
        epsilon: Target distance from stationarity
        n: Number of states

    Returns:
        Upper bound on mixing time
    """
    if gap <= 0 or n <= 0 or epsilon <= 0:
        return float('inf')
    return (1.0 / gap) * (np.log(n) + np.log(1.0 / epsilon))


def add_clue(solutions: List[np.ndarray], row: int, col: int, val: int) -> List[np.ndarray]:
    """Filter solutions that match a given clue.

    Args:
        solutions: Current list of valid solutions
        row: Row of the clue
        col: Column of the clue
        val: Value of the clue

    Returns:
        Filtered list of solutions matching the clue
    """
    return [s for s in solutions if s[row, col] == val]


def shannon_entropy(counts: List[int]) -> float:
    """Compute Shannon entropy of a distribution given by counts.

    Args:
        counts: List of counts for each outcome

    Returns:
        Shannon entropy in nats
    """
    total = sum(counts)
    if total == 0:
        return 0.0
    probs = [c / total for c in counts if c > 0]
    return -sum(p * np.log(p) for p in probs)


def demonstrate_phase_transition():
    """Demonstrate the spectral gap phase transition for 3×3 Latin squares."""
    print("=" * 70)
    print("SUDOKU SPECTRAL GAP: PHASE TRANSITION DEMONSTRATION")
    print("=" * 70)
    print()

    n = 3
    print(f"Working with {n}×{n} Latin squares (simplified Sudoku)")
    print()

    # Generate all solutions
    solutions = generate_latin_square_solutions(n)
    print(f"Total valid {n}×{n} Latin squares: {len(solutions)}")
    print()

    # Show the phase transition by adding clues one at a time
    print("Phase Transition Analysis:")
    print("-" * 60)
    print(f"{'Clues':>6} {'Density':>8} {'Solutions':>10} {'Spec Gap':>10} {'Mix Time':>10} {'Phase':>15}")
    print("-" * 60)

    current_solutions = solutions
    clues = []
    epsilon = 0.25

    # Predefined clue sequence
    clue_sequence = [(0, 0, 1), (0, 1, 2), (0, 2, 3), (1, 0, 2), (1, 1, 3),
                     (1, 2, 1), (2, 0, 3), (2, 1, 1), (2, 2, 2)]

    for step in range(len(clue_sequence) + 1):
        density = step / (n * n)
        num_solutions = len(current_solutions)

        if num_solutions > 1:
            P = build_swap_transition_matrix(current_solutions, n)
            gap = compute_spectral_gap(P)
            mt = mixing_time_bound(gap, epsilon, num_solutions)
        elif num_solutions == 1:
            gap = 0.0
            mt = 0.0
        else:
            gap = 0.0
            mt = float('inf')

        # Classify phase
        if density < 17 / 81:
            phase = "underconstrained"
        elif density < 30 / 81:
            phase = "critical"
        else:
            phase = "overconstrained"

        mt_str = f"{mt:.2f}" if mt < float('inf') else "∞"
        print(f"{step:>6} {density:>8.3f} {num_solutions:>10} {gap:>10.4f} {mt_str:>10} {phase:>15}")

        if step < len(clue_sequence):
            r, c, v = clue_sequence[step]
            current_solutions = add_clue(current_solutions, r, c, v)

    print()

    # Demonstrate theorem: solution set monotonicity
    print("=" * 70)
    print("THEOREM DEMONSTRATION: Solution Set Monotonicity")
    print("=" * 70)
    print()
    print("Theorem: Adding constraints can only shrink the solution set.")
    print()

    current = solutions
    for i, (r, c, v) in enumerate(clue_sequence[:4]):
        filtered = add_clue(current, r, c, v)
        print(f"  After clue {i+1} (row={r}, col={c}, val={v}): "
              f"{len(current)} → {len(filtered)} solutions  "
              f"({'✓' if len(filtered) <= len(current) else '✗'} monotone)")
        current = filtered

    print()

    # Demonstrate theorem: contraction decreasing
    print("=" * 70)
    print("THEOREM DEMONSTRATION: Exponential L2 Contraction")
    print("=" * 70)
    print()

    gap_val = 0.3
    print(f"With spectral gap γ = {gap_val}:")
    print(f"  Contraction factor (1-γ) = {1 - gap_val}")
    print()
    for t in range(0, 11, 2):
        contraction = (1 - gap_val) ** t
        print(f"  After {t:>3} steps: (1-γ)^t = {contraction:.6f}")

    print()

    # Demonstrate theorem: entropy bounds
    print("=" * 70)
    print("THEOREM DEMONSTRATION: Shannon Entropy Bounds")
    print("=" * 70)
    print()

    for n_states in [2, 4, 8, 16]:
        uniform = [1] * n_states
        H = shannon_entropy(uniform)
        print(f"  n = {n_states:>3}: H(uniform) = {H:.4f}, log(n) = {np.log(n_states):.4f}  "
              f"({'✓' if H <= np.log(n_states) + 1e-10 else '✗'} H ≤ log(n))")

    # Deterministic distribution
    det = [1, 0, 0, 0]
    H_det = shannon_entropy(det)
    print(f"  Deterministic: H = {H_det:.4f} {'✓' if abs(H_det) < 1e-10 else '✗'} (= 0)")

    print()
    print("=" * 70)
    print("CONJECTURE: Sudoku Spectral Gap Phase Transition")
    print("=" * 70)
    print()
    print("The spectral gap of the swap Markov chain undergoes a phase transition")
    print("at the critical density d_c = 17/81 ≈ 0.210.")
    print()
    print("Testable prediction: For 4×4 Shidoku, the analogous transition occurs")
    print("at 4/16 = 0.25 clue density.")
    print()
    print("To falsify: compute spectral gaps for all Shidoku puzzles with")
    print("k = 0, 1, ..., 16 clues and check if the gap peaks near k=0")
    print("and vanishes near k=4.")


if __name__ == "__main__":
    demonstrate_phase_transition()


"""
L2 Contraction Visualization: Exponential Convergence from Spectral Gap

Visualizes the proven theorem that the L2 distance to stationarity decays
exponentially as (1-γ)^t, where γ is the spectral gap. Shows how different
gap values lead to dramatically different convergence rates — the mathematical
essence of why puzzle difficulty varies with constraint density.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Contraction curves for different gaps
gaps = [0.05, 0.1, 0.2, 0.4, 0.6, 0.8]
steps = np.arange(0, 30)

for gap in gaps:
    contraction = (1 - gap) ** steps
    ax1.plot(steps, contraction, linewidth=2.5, label=f'γ = {gap}')

ax1.set_xlabel('Number of Steps (t)', fontsize=13)
ax1.set_ylabel('Contraction Factor (1-γ)^t', fontsize=13)
ax1.set_title('Exponential L2 Contraction\n(Proved: contraction_decreasing)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0.25, color='gray', linestyle=':', alpha=0.7, label='ε = 0.25')

# Add annotation
ax1.annotate('Mixing time threshold\n(ε = 0.25)', xy=(15, 0.25),
            fontsize=10, ha='center', va='bottom',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

# Right: Mixing time vs spectral gap
gap_values = np.linspace(0.01, 1.0, 200)
n_states = 100
epsilon = 0.25

mixing_times = (1.0 / gap_values) * (np.log(n_states) + np.log(1.0 / epsilon))

ax2.plot(gap_values, mixing_times, linewidth=3, color='#e74c3c')
ax2.fill_between(gap_values, mixing_times, alpha=0.1, color='#e74c3c')
ax2.set_xlabel('Spectral Gap (γ)', fontsize=13)
ax2.set_ylabel('Mixing Time Bound', fontsize=13)
ax2.set_title(f'Mixing Time vs Spectral Gap\n(n={n_states}, ε={epsilon})', fontsize=14, fontweight='bold')
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Mark critical density region
ax2.axvspan(0.0, 0.1, alpha=0.15, color='red', label='Critical region\n(slow mixing)')
ax2.axvspan(0.3, 1.0, alpha=0.15, color='green', label='Fast mixing\nregion')
ax2.legend(fontsize=11, loc='upper right')

# Add the divergence annotation
ax2.annotate('T_mix → ∞ as γ → 0\n(Proved: mixing_time_diverges_at_zero_gap)',
            xy=(0.03, mixing_times[5]),
            fontsize=9, ha='left',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

plt.suptitle('Spectral Gap Controls Mixing: From Theory to Phase Transitions',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('contraction.png', dpi=150, bbox_inches='tight')
print("Saved contraction.png")


"""
Entropy and Solution Space Visualization

Visualizes the connection between Shannon entropy, solution count, and
constraint density. The key insight: as constraints increase, the entropy
of the solution distribution decreases from log(n) (uniform over many solutions)
to 0 (deterministic, unique solution). This entropy collapse corresponds to
the spectral gap phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt


def latin_square_solver(n, clues=None):
    if clues is None:
        clues = {}
    solutions = []
    def is_valid(grid, row, col, val):
        if val in grid[row, :col]:
            return False
        for r in range(row):
            if grid[r, col] == val:
                return False
        return True
    def solve(grid, pos):
        if pos == n * n:
            solutions.append(grid.copy())
            return
        row, col = pos // n, pos % n
        if (row, col) in clues:
            val = clues[(row, col)]
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
            return
        for val in range(1, n + 1):
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
    grid = np.zeros((n, n), dtype=int)
    solve(grid, 0)
    return solutions


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Shannon entropy properties (proved theorems)
ax1 = axes[0]
n_vals = np.arange(2, 51)
log_n = np.log(n_vals)

ax1.plot(n_vals, log_n, 'b-', linewidth=2.5, label='log(n) upper bound')
ax1.fill_between(n_vals, 0, log_n, alpha=0.1, color='blue')
ax1.plot([1], [0], 'ro', markersize=12, zorder=5, label='Deterministic (H=0)')
ax1.set_xlabel('Number of States (n)', fontsize=12)
ax1.set_ylabel('Shannon Entropy (nats)', fontsize=12)
ax1.set_title('Entropy Bounds\n(Proved: shannonEntropy_nonneg,\nshannonEntropy_zero_of_deterministic)',
              fontsize=11, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-0.2, 4.2)
ax1.grid(True, alpha=0.3)
ax1.annotate('0 ≤ H(p) ≤ log(n)', xy=(25, 2), fontsize=14,
            ha='center', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

# Panel 2: Entropy vs constraint density for 3×3 Latin squares
ax2 = axes[1]
n = 3
all_solutions = latin_square_solver(n)
answer = all_solutions[0]

clue_counts = []
entropies = []
solution_counts = []

for k in range(n * n + 1):
    clues = {}
    for pos in range(k):
        r, c = pos // n, pos % n
        clues[(r, c)] = int(answer[r, c])
    solutions = latin_square_solver(n, clues) if k > 0 else all_solutions
    num_sol = len(solutions)
    if num_sol > 0:
        # Uniform entropy over solutions
        H = np.log(num_sol) if num_sol > 1 else 0.0
    else:
        H = 0.0
    clue_counts.append(k)
    entropies.append(H)
    solution_counts.append(num_sol)

colors = ['#2ecc71' if k/(n*n) < 17/81 else '#e74c3c' if k/(n*n) < 30/81 else '#3498db'
          for k in clue_counts]
ax2.bar(clue_counts, entropies, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Number of Clues', fontsize=12)
ax2.set_ylabel('log(|Solutions|)', fontsize=12)
ax2.set_title(f'{n}×{n} Latin Squares:\nEntropy Collapse', fontsize=12, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Cross-domain connection — entropy production rate
ax3 = axes[2]
gap_vals = np.linspace(0.01, 1.0, 100)
# Log-Sobolev constant ≤ 2γ (proved in entropy_contraction_from_log_sobolev)
ls_upper = 2 * gap_vals
entropy_rate = 2 * ls_upper  # Entropy production rate bound

ax3.plot(gap_vals, gap_vals, 'g-', linewidth=2.5, label='Spectral gap γ')
ax3.plot(gap_vals, ls_upper, 'r--', linewidth=2.5, label='Log-Sobolev bound (2γ)')
ax3.plot(gap_vals, entropy_rate, 'b:', linewidth=2.5, label='Entropy production (4γ)')
ax3.fill_between(gap_vals, gap_vals, ls_upper, alpha=0.1, color='orange')
ax3.set_xlabel('Spectral Gap (γ)', fontsize=12)
ax3.set_ylabel('Constant Value', fontsize=12)
ax3.set_title('Cross-Domain Bridge:\nSpectral Gap → Entropy Production\n'
              '(Proved: entropy_contraction_from_log_sobolev)',
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Information Theory Meets Spectral Theory in Constraint Satisfaction',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entropy_visualization.png', dpi=150, bbox_inches='tight')
print("Saved entropy_visualization.png")


"""
Phase Transition Visualization: Spectral Gap vs. Constraint Density

Visualizes the core conjecture: the spectral gap of the swap Markov chain
on Latin square solutions undergoes a phase transition as the number of
constraints (clues) increases. The three phases — underconstrained (fast mixing),
critical (slow mixing), and overconstrained (frozen) — are shown with distinct colors.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Dict, Tuple


def latin_square_solver(n, clues=None):
    if clues is None:
        clues = {}
    solutions = []
    def is_valid(grid, row, col, val):
        if val in grid[row, :col]:
            return False
        for r in range(row):
            if grid[r, col] == val:
                return False
        return True
    def solve(grid, pos):
        if pos == n * n:
            solutions.append(grid.copy())
            return
        row, col = pos // n, pos % n
        if (row, col) in clues:
            val = clues[(row, col)]
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
            return
        for val in range(1, n + 1):
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
    grid = np.zeros((n, n), dtype=int)
    solve(grid, 0)
    return solutions


def compute_gap_for_solutions(solutions):
    m = len(solutions)
    if m <= 1:
        return 0.0
    n = solutions[0].shape[0]
    adj = np.zeros((m, m))
    for i in range(m):
        for j in range(i + 1, m):
            diff = solutions[i] != solutions[j]
            if np.sum(diff) == 2:
                positions = np.argwhere(diff)
                if positions[0][0] == positions[1][0]:
                    adj[i][j] = 1
                    adj[j][i] = 1
    P = np.zeros((m, m))
    for i in range(m):
        degree = np.sum(adj[i])
        if degree > 0:
            P[i] = adj[i] / degree
        else:
            P[i, i] = 1.0
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    return max(float(1.0 - eigenvalues[1]), 0.0) if len(eigenvalues) >= 2 else 0.0


def analyze_phase_transition(n):
    all_solutions = latin_square_solver(n)
    answer = all_solutions[0] if all_solutions else None
    results = []

    for k in range(n * n + 1):
        clues = {}
        if answer is not None:
            for pos in range(k):
                r, c = pos // n, pos % n
                clues[(r, c)] = int(answer[r, c])

        solutions = latin_square_solver(n, clues) if k > 0 else all_solutions
        gap = compute_gap_for_solutions(solutions)
        density = k / (n * n)
        results.append((k, density, len(solutions), gap))

    return results


# Generate data
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, n in enumerate([3, 4]):
    results = analyze_phase_transition(n)

    clues = [r[0] for r in results]
    densities = [r[1] for r in results]
    num_solutions = [r[2] for r in results]
    gaps = [r[3] for r in results]

    # Colors by phase
    colors = []
    for d in densities:
        if d < 17/81:
            colors.append('#2ecc71')  # Green: underconstrained
        elif d < 30/81:
            colors.append('#e74c3c')  # Red: critical
        else:
            colors.append('#3498db')  # Blue: overconstrained

    # Spectral gap plot
    ax1 = axes[0][idx]
    ax1.bar(clues, gaps, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax1.axvline(x=17/81 * n*n, color='red', linestyle='--', linewidth=2, label=f'd_c = 17/81')
    ax1.axvline(x=30/81 * n*n, color='blue', linestyle='--', linewidth=2, label=f'd_f = 30/81')
    ax1.set_xlabel('Number of Clues', fontsize=12)
    ax1.set_ylabel('Spectral Gap γ', fontsize=12)
    ax1.set_title(f'{n}×{n} Latin Squares: Spectral Gap', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)

    # Solution count plot
    ax2 = axes[1][idx]
    ax2.bar(clues, num_solutions, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax2.axvline(x=17/81 * n*n, color='red', linestyle='--', linewidth=2, label=f'd_c = 17/81')
    ax2.axvline(x=30/81 * n*n, color='blue', linestyle='--', linewidth=2, label=f'd_f = 30/81')
    ax2.set_xlabel('Number of Clues', fontsize=12)
    ax2.set_ylabel('Number of Solutions', fontsize=12)
    ax2.set_title(f'{n}×{n} Latin Squares: Solution Count', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    if max(num_solutions) > 100:
        ax2.set_yscale('log')

plt.suptitle('Phase Transition in Constraint Satisfaction\n'
             'Green = Underconstrained | Red = Critical | Blue = Overconstrained',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
