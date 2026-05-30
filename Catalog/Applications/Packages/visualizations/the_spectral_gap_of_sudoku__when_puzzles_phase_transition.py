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
