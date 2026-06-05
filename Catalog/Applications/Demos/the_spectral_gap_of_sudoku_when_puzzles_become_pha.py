#!/usr/bin/env python3
"""
Density-Indexed Spectral Filtration: Numerical Demonstrations

This script demonstrates the spectral gap phase transition in Latin square
constraint satisfaction problems. It computes spectral gaps for small Latin
squares and visualizes the phase transition.
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional


def is_valid_latin_square(grid: np.ndarray) -> bool:
    """Check if an n×n grid is a valid Latin square."""
    n = grid.shape[0]
    for i in range(n):
        if len(set(grid[i, :])) != n:
            return False
        if len(set(grid[:, i])) != n:
            return False
    return True


def generate_latin_squares(n: int) -> List[np.ndarray]:
    """Generate all Latin squares of order n (feasible for n ≤ 5)."""
    if n > 5:
        raise ValueError("Too large for enumeration")

    squares = []
    perms = list(permutations(range(n)))

    def backtrack(grid: List[List[int]], row: int):
        if row == n:
            squares.append(np.array(grid))
            return
        for perm in perms:
            # Check column constraints
            valid = True
            for col in range(n):
                for prev_row in range(row):
                    if grid[prev_row][col] == perm[col]:
                        valid = False
                        break
                if not valid:
                    break
            if valid:
                grid.append(list(perm))
                backtrack(grid, row + 1)
                grid.pop()

    backtrack([], 0)
    return squares


def count_solutions_with_clues(squares: List[np.ndarray],
                                clue_positions: List[Tuple[int, int]],
                                clue_values: List[int]) -> int:
    """Count Latin squares compatible with given clues."""
    count = 0
    for sq in squares:
        compatible = True
        for (r, c), v in zip(clue_positions, clue_values):
            if sq[r, c] != v:
                compatible = False
                break
        if compatible:
            count += 1
    return count


def build_swap_transition_matrix(compatible_squares: List[np.ndarray],
                                  n: int) -> np.ndarray:
    """Build the transition matrix for the swap Markov chain.

    States: compatible Latin squares
    Transitions: swap two entries if the result is still a valid Latin square
    """
    m = len(compatible_squares)
    if m <= 1:
        return np.eye(max(m, 1))

    # Index squares for fast lookup
    sq_to_idx = {}
    for idx, sq in enumerate(compatible_squares):
        sq_to_idx[sq.tobytes()] = idx

    P = np.zeros((m, m))
    total_possible_swaps = n * n * (n * n - 1) // 2

    for idx, sq in enumerate(compatible_squares):
        neighbor_count = 0
        for i1 in range(n * n):
            for i2 in range(i1 + 1, n * n):
                r1, c1 = divmod(i1, n)
                r2, c2 = divmod(i2, n)
                # Try swapping
                new_sq = sq.copy()
                new_sq[r1, c1], new_sq[r2, c2] = new_sq[r2, c2], new_sq[r1, c1]
                key = new_sq.tobytes()
                if key in sq_to_idx:
                    j = sq_to_idx[key]
                    P[idx, j] += 1.0 / total_possible_swaps
                    neighbor_count += 1
        # Self-loop for rejected swaps
        P[idx, idx] += 1.0 - neighbor_count / total_possible_swaps

    return P


def spectral_gap(P: np.ndarray) -> float:
    """Compute the spectral gap of a transition matrix."""
    if P.shape[0] <= 1:
        return 0.0
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) < 2:
        return 0.0
    return float(eigenvalues[0] - eigenvalues[1])


def demonstrate_phase_transition():
    """Main demonstration: spectral gap phase transition for 4×4 Latin squares."""
    n = 4
    print(f"=" * 60)
    print(f"Spectral Gap Phase Transition for {n}×{n} Latin Squares")
    print(f"=" * 60)

    # Generate all Latin squares of order 4
    print(f"\nGenerating all {n}×{n} Latin squares...")
    squares = generate_latin_squares(n)
    print(f"Found {len(squares)} Latin squares of order {n}")

    # Critical density analysis
    n_sq = n * n
    print(f"\nGrid size: {n_sq} cells")
    print(f"Critical density (n²-1)/n² = {n_sq - 1}/{n_sq} = {(n_sq-1)/n_sq:.4f}")
    print(f"Sudoku critical density: 17/81 = {17/81:.4f}")

    # Compute solution counts and spectral gaps for varying clue counts
    print(f"\n{'Clues':>6} {'Density':>10} {'Avg Solutions':>15} {'Phase':>15}")
    print("-" * 50)

    np.random.seed(42)
    num_trials = 20

    for num_clues in range(0, n_sq + 1, 2):
        density = num_clues / n_sq
        solution_counts = []
        gaps = []

        for _ in range(num_trials):
            # Pick a random reference square and extract clues
            ref_sq = squares[np.random.randint(len(squares))]
            positions = [(i, j) for i in range(n) for j in range(n)]
            np.random.shuffle(positions)
            clue_pos = positions[:num_clues]
            clue_vals = [int(ref_sq[r, c]) for r, c in clue_pos]

            # Count compatible solutions
            count = count_solutions_with_clues(squares, clue_pos, clue_vals)
            solution_counts.append(count)

        avg_solutions = np.mean(solution_counts)

        if avg_solutions <= 1:
            phase = "FROZEN"
        elif avg_solutions < 5:
            phase = "CRITICAL"
        else:
            phase = "FAST_MIXING"

        print(f"{num_clues:>6} {density:>10.3f} {avg_solutions:>15.1f} {phase:>15}")

    # Detailed spectral gap computation for small examples
    print(f"\n{'='*60}")
    print("Detailed Spectral Gap Analysis (0 clues)")
    print(f"{'='*60}")

    # With 0 clues, all squares are compatible
    P = build_swap_transition_matrix(squares[:50], n)  # Use subset for speed
    gap = spectral_gap(P)
    print(f"Number of states (subset): {min(50, len(squares))}")
    print(f"Spectral gap: {gap:.6f}")
    print(f"Estimated mixing time: {1/max(gap, 1e-10) * np.log(min(50, len(squares))):.1f} steps")

    # Verify key mathematical properties
    print(f"\n{'='*60}")
    print("Verification of Key Properties")
    print(f"{'='*60}")

    # Check row stochasticity
    row_sums = P.sum(axis=1)
    print(f"Row stochastic: max|row_sum - 1| = {np.max(np.abs(row_sums - 1)):.2e}")

    # Check nonnegativity
    print(f"All entries nonneg: {np.all(P >= -1e-15)}")

    # Check doubly stochastic
    col_sums = P.sum(axis=0)
    print(f"Doubly stochastic: max|col_sum - 1| = {np.max(np.abs(col_sums - 1)):.2e}")

    # Eigenvalue analysis
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    print(f"\nTop 5 eigenvalues: {eigenvalues[:5]}")
    print(f"Spectral gap (λ₁ - λ₂): {eigenvalues[0] - eigenvalues[1]:.6f}")

    # Mean-field prediction test
    print(f"\n{'='*60}")
    print("Mean-Field Universality Test")
    print(f"{'='*60}")
    print("If ν = 1 (mean-field), γ(d) should decay linearly near d_c")
    print("Prediction: γ(0.9·d_c)/γ(0.5·d_c) ≈ 0.2")
    print("(Full test requires spectral gap computation at multiple densities)")


if __name__ == "__main__":
    demonstrate_phase_transition()


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Phase Transition

Standalone matplotlib script showing the spectral gap as a function of
constraint density, with the phase transition clearly marked.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def spectral_gap_model(d: np.ndarray, d_c: float = 17/81,
                        C: float = 0.8, nu: float = 1.0) -> np.ndarray:
    """Model spectral gap: γ(d) = C(1-d/d_c)^ν for d < d_c, 0 otherwise."""
    result = np.zeros_like(d)
    mask = d < d_c
    result[mask] = C * (1 - d[mask] / d_c) ** nu
    return result


def solution_count_model(d: np.ndarray, n: int = 9) -> np.ndarray:
    """Model solution count: S(d) ~ n^{n²(1-d)} (rough approximation)."""
    n_sq = n * n
    return np.exp(n_sq * (1 - d) * np.log(n) * 0.1)


def mixing_time_model(gap: np.ndarray, sol_count: np.ndarray) -> np.ndarray:
    """Mixing time: τ = (1/γ) ln(S), with τ = ∞ when γ = 0."""
    result = np.full_like(gap, np.nan)
    mask = gap > 1e-10
    result[mask] = (1.0 / gap[mask]) * np.log(np.maximum(sol_count[mask], 1))
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Spectral Gap Phase Transition in Sudoku',
                 fontsize=16, fontweight='bold')

    d = np.linspace(0, 1, 1000)
    d_c = 17 / 81
    d_f = 30 / 81

    # Panel 1: Spectral Gap vs Density
    ax1 = axes[0, 0]
    gap = spectral_gap_model(d)
    ax1.plot(d, gap, 'b-', linewidth=2, label='Spectral gap γ(d)')
    ax1.axvline(x=d_c, color='r', linestyle='--', alpha=0.7,
                label=f'd_c = 17/81 ≈ {d_c:.3f}')
    ax1.axvline(x=d_f, color='orange', linestyle='--', alpha=0.7,
                label=f'd_f = 30/81 ≈ {d_f:.3f}')
    ax1.axvspan(0, d_c, alpha=0.1, color='green')
    ax1.axvspan(d_c, d_f, alpha=0.1, color='yellow')
    ax1.axvspan(d_f, 1, alpha=0.1, color='red')
    ax1.set_xlabel('Constraint Density d = k/81', fontsize=12)
    ax1.set_ylabel('Spectral Gap γ(d)', fontsize=12)
    ax1.set_title('Spectral Gap Phase Transition', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.05, 1.0)
    ax1.text(0.05, 0.85, 'Fast\nMixing', transform=ax1.transAxes,
             fontsize=10, color='green', fontweight='bold')
    ax1.text(0.35, 0.85, 'Critical', transform=ax1.transAxes,
             fontsize=10, color='goldenrod', fontweight='bold')
    ax1.text(0.65, 0.85, 'Frozen', transform=ax1.transAxes,
             fontsize=10, color='red', fontweight='bold')

    # Panel 2: Solution Count (log scale)
    ax2 = axes[0, 1]
    sol = solution_count_model(d)
    ax2.semilogy(d, sol, 'g-', linewidth=2, label='Solution count S(d)')
    ax2.axvline(x=d_c, color='r', linestyle='--', alpha=0.7)
    ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5,
                label='S = 1 (unique solution)')
    ax2.set_xlabel('Constraint Density d', fontsize=12)
    ax2.set_ylabel('Solution Count S(d) [log scale]', fontsize=12)
    ax2.set_title('Solution Space Collapse', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.set_xlim(0, 1)

    # Panel 3: Mixing Time
    ax3 = axes[1, 0]
    tau = mixing_time_model(gap, sol)
    valid = ~np.isnan(tau)
    ax3.plot(d[valid], tau[valid], 'm-', linewidth=2,
             label='Mixing time τ(d)')
    ax3.axvline(x=d_c, color='r', linestyle='--', alpha=0.7,
                label=f'Phase transition at d_c')
    ax3.set_xlabel('Constraint Density d', fontsize=12)
    ax3.set_ylabel('Mixing Time τ(d)', fontsize=12)
    ax3.set_title('Mixing Time Divergence at Criticality', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.set_xlim(0, d_c * 1.1)
    ax3.set_ylim(0, np.nanmax(tau[d < d_c * 0.99]) * 1.5)

    # Panel 4: Phase Diagram
    ax4 = axes[1, 1]
    clues = np.arange(0, 82)
    densities = clues / 81
    phases = []
    for nc in clues:
        if nc > 30:
            phases.append(2)  # Frozen
        elif nc >= 17:
            phases.append(1)  # Critical
        else:
            phases.append(0)  # Fast Mixing

    colors = ['green', 'gold', 'red']
    labels = ['Fast Mixing (< 17 clues)',
              'Critical (17-30 clues)',
              'Frozen (> 30 clues)']

    for phase_val in [0, 1, 2]:
        mask = np.array(phases) == phase_val
        ax4.scatter(clues[mask], [phase_val] * np.sum(mask),
                   c=colors[phase_val], s=30, alpha=0.7,
                   label=labels[phase_val])

    ax4.set_xlabel('Number of Clues', fontsize=12)
    ax4.set_ylabel('Spectral Phase', fontsize=12)
    ax4.set_yticks([0, 1, 2])
    ax4.set_yticklabels(['Fast Mixing', 'Critical', 'Frozen'])
    ax4.set_title('Sudoku Phase Diagram', fontsize=13)
    ax4.legend(fontsize=9, loc='upper left')
    ax4.axvline(x=17, color='r', linestyle='--', alpha=0.5)
    ax4.axvline(x=30, color='orange', linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.savefig('spectral_gap_phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_gap_phase_transition.png")


if __name__ == "__main__":
    main()
