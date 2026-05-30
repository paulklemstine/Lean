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
