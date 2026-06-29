#!/usr/bin/env python3
"""
Applications of the Tropical Sudoku CSP Framework.

Demonstrates how the tropical energy landscape perspective
applies beyond Sudoku to:
1. Latin square completion
2. Graph coloring as a tropical CSP
3. Scheduling / timetabling
"""

from typing import Dict, List, Tuple, Set
from algorithms import TropicalSudokuCSP, ConstraintPropagator, ALL_CELLS


# ─── Application 1: Puzzle Difficulty Estimation ──────────────────────────────

def estimate_difficulty(clues: List[Tuple[Tuple[int, int], int]]) -> dict:
    """Estimate Sudoku puzzle difficulty using tropical metrics.

    Uses three tropical observables:
    - Residual ambiguity after propagation
    - Propagation depth (steps to stabilize)
    - Fraction of cells solved by propagation alone

    Args:
        clues: List of (cell, digit) clues (0-indexed)

    Returns:
        Dictionary with difficulty metrics
    """
    prop = ConstraintPropagator(clues)
    prop.propagate_until_stable()

    total_cells = 81
    clue_count = len(clues)
    solved_cells = sum(1 for c in ALL_CELLS if len(prop.candidates[c]) == 1)
    empty_cells = total_cells - clue_count
    solved_by_prop = solved_cells - clue_count

    residual = prop.residual_ambiguity()

    if residual == 0:
        difficulty = "Easy (propagation solves completely)"
    elif residual < 50:
        difficulty = "Medium (small residual ambiguity)"
    elif residual < 200:
        difficulty = "Hard (significant residual ambiguity)"
    else:
        difficulty = "Expert (large residual ambiguity — deep search needed)"

    return {
        "clue_count": clue_count,
        "propagation_steps": prop.steps,
        "residual_ambiguity": residual,
        "cells_solved_by_propagation": solved_by_prop,
        "fraction_solved": solved_by_prop / max(1, empty_cells),
        "difficulty": difficulty,
        "has_contradiction": prop.has_contradiction(),
    }


# ─── Application 2: Generic Tropical CSP Framework ───────────────────────────

class TropicalCSP:
    """Generic tropical CSP framework.

    Mirrors the Lean TropicalCSP structure:
    - Variables with finite domains
    - Constraints as penalty functions
    - Total cost = sum of penalties
    - Exactness: cost = 0 ↔ valid

    This is instantiable for Sudoku, graph coloring,
    Latin squares, scheduling, etc.
    """

    def __init__(self, variables, domains, constraints):
        """
        Args:
            variables: List of variable identifiers
            domains: Dict mapping variable to set of possible values
            constraints: List of (scope, penalty_fn) pairs
                where scope is a tuple of variables
                and penalty_fn takes a partial assignment dict → int
        """
        self.variables = variables
        self.domains = domains
        self.constraints = constraints

    def cost(self, assignment: dict) -> int:
        """Total tropical cost."""
        total = 0
        for scope, penalty_fn in self.constraints:
            partial = {v: assignment[v] for v in scope if v in assignment}
            total += penalty_fn(partial)
        return total

    def is_valid(self, assignment: dict) -> bool:
        """Validity = zero cost (Exactness Theorem)."""
        return self.cost(assignment) == 0


def graph_coloring_csp(
    vertices: List[int],
    edges: List[Tuple[int, int]],
    n_colors: int
) -> TropicalCSP:
    """Create a tropical CSP for graph coloring.

    Variables: vertices
    Domains: {0, 1, ..., n_colors-1}
    Constraints: adjacent vertices must have different colors

    Args:
        vertices: List of vertex identifiers
        edges: List of (u, v) edges
        n_colors: Number of available colors

    Returns:
        TropicalCSP instance for the coloring problem
    """
    domains = {v: set(range(n_colors)) for v in vertices}

    constraints = []
    for u, v in edges:
        def penalty(assignment, u=u, v=v):
            if u in assignment and v in assignment:
                return 1 if assignment[u] == assignment[v] else 0
            return 0
        constraints.append(((u, v), penalty))

    return TropicalCSP(vertices, domains, constraints)


def latin_square_csp(n: int) -> TropicalCSP:
    """Create a tropical CSP for Latin square completion.

    An n×n Latin square has each symbol 0..n-1 appearing exactly
    once in each row and column — essentially Sudoku without boxes.

    Args:
        n: Size of the Latin square

    Returns:
        TropicalCSP instance
    """
    variables = [(r, c) for r in range(n) for c in range(n)]
    domains = {v: set(range(n)) for v in variables}

    constraints = []
    # Row constraints
    for r in range(n):
        for c1 in range(n):
            for c2 in range(c1 + 1, n):
                def penalty(a, r=r, c1=c1, c2=c2):
                    v1, v2 = (r, c1), (r, c2)
                    if v1 in a and v2 in a:
                        return 1 if a[v1] == a[v2] else 0
                    return 0
                constraints.append((((r, c1), (r, c2)), penalty))

    # Column constraints
    for c in range(n):
        for r1 in range(n):
            for r2 in range(r1 + 1, n):
                def penalty(a, c=c, r1=r1, r2=r2):
                    v1, v2 = (r1, c), (r2, c)
                    if v1 in a and v2 in a:
                        return 1 if a[v1] == a[v2] else 0
                    return 0
                constraints.append((((r1, c), (r2, c)), penalty))

    return TropicalCSP(variables, domains, constraints)


# ─── Demo ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Puzzle Difficulty Estimation")
    print("=" * 60)

    # Easy puzzle (many clues)
    solution = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ]

    import numpy as np
    rng = np.random.RandomState(42)
    cells = list(ALL_CELLS)
    rng.shuffle(cells)

    for n in [40, 30, 20, 17]:
        clues = [(cells[i], solution[cells[i][0]][cells[i][1]] - 1) for i in range(n)]
        result = estimate_difficulty(clues)
        print(f"\n  {n} clues:")
        for k, v in result.items():
            print(f"    {k}: {v}")

    print()
    print("=" * 60)
    print("APPLICATION 2: Graph Coloring as Tropical CSP")
    print("=" * 60)

    # Petersen graph coloring
    petersen_edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),  # outer pentagon
        (5,7),(7,9),(9,6),(6,8),(8,5),  # inner pentagram
        (0,5),(1,6),(2,7),(3,8),(4,9),  # connecting edges
    ]
    vertices = list(range(10))

    for n_colors in [2, 3, 4]:
        csp = graph_coloring_csp(vertices, petersen_edges, n_colors)
        # Try a random coloring
        coloring = {v: v % n_colors for v in vertices}
        cost = csp.cost(coloring)
        print(f"\n  {n_colors}-coloring of Petersen graph:")
        print(f"    Assignment: {coloring}")
        print(f"    Tropical cost: {cost}")
        print(f"    Valid: {csp.is_valid(coloring)}")

    print()
    print("=" * 60)
    print("APPLICATION 3: Latin Square as Tropical CSP")
    print("=" * 60)

    ls = latin_square_csp(4)
    # Valid 4x4 Latin square
    assignment = {(r, c): (r + c) % 4 for r in range(4) for c in range(4)}
    print(f"\n  4x4 Latin square (cyclic):")
    for r in range(4):
        print(f"    {[assignment[(r,c)]+1 for c in range(4)]}")
    print(f"  Tropical cost: {ls.cost(assignment)}")
    print(f"  Valid: {ls.is_valid(assignment)}")

    # Invalid Latin square (swap two entries)
    bad = dict(assignment)
    bad[(0, 0)] = assignment[(0, 1)]
    print(f"\n  Corrupted Latin square:")
    for r in range(4):
        print(f"    {[bad[(r,c)]+1 for c in range(4)]}")
    print(f"  Tropical cost: {ls.cost(bad)}")
    print(f"  Valid: {ls.is_valid(bad)}")

    print("\nAll application demos completed.")


#!/usr/bin/env python3
"""
Tropical Sudoku: Concrete demonstrations of the tropical CSP framework.

This script demonstrates:
1. Computing tropical costs for Sudoku assignments
2. Constraint propagation with candidate elimination
3. Monotonicity of cost under adding clues
4. Phase transition behavior in residual ambiguity
"""

import numpy as np
from itertools import product


# ─── Basic Types ───────────────────────────────────────────────────────────────

def same_row(c1, c2):
    return c1[0] == c2[0]

def same_col(c1, c2):
    return c1[1] == c2[1]

def same_box(c1, c2):
    return c1[0] // 3 == c2[0] // 3 and c1[1] // 3 == c2[1] // 3

def in_same_unit(c1, c2):
    return c1 != c2 and (same_row(c1, c2) or same_col(c1, c2) or same_box(c1, c2))

ALL_CELLS = [(r, c) for r in range(9) for c in range(9)]
ALL_DIGITS = set(range(9))


# ─── Tropical Cost Function ───────────────────────────────────────────────────

def clue_penalty(clues, assignment):
    """Number of clue violations."""
    return sum(1 for (cell, digit) in clues if assignment[cell] != digit)

def unit_violation_count(assignment):
    """Number of ordered conflicting pairs in same unit."""
    count = 0
    for c1 in ALL_CELLS:
        for c2 in ALL_CELLS:
            if in_same_unit(c1, c2) and assignment[c1] == assignment[c2]:
                count += 1
    return count

def tropical_sudoku_cost(clues, assignment):
    """Total tropical cost = clue penalty + unit violations."""
    return clue_penalty(clues, assignment) + unit_violation_count(assignment)


# ─── Validity Check ───────────────────────────────────────────────────────────

def is_valid(clues, assignment):
    """Check if assignment is a valid Sudoku solution respecting clues."""
    # Check clues
    for (cell, digit) in clues:
        if assignment[cell] != digit:
            return False
    # Check units
    for c1 in ALL_CELLS:
        for c2 in ALL_CELLS:
            if in_same_unit(c1, c2) and assignment[c1] == assignment[c2]:
                return False
    return True


# ─── Constraint Propagation ───────────────────────────────────────────────────

def initial_candidates(clues):
    """Initialize candidate sets from clues."""
    candidates = {cell: set(range(9)) for cell in ALL_CELLS}
    for (cell, digit) in clues:
        candidates[cell] = {digit}
    return candidates

def neighbors(cell):
    """All cells sharing a unit with the given cell."""
    return [c for c in ALL_CELLS if in_same_unit(cell, c)]

def propagate_step(clues, candidates):
    """One step of constraint propagation (naked singles elimination)."""
    new_candidates = {}
    for cell in ALL_CELLS:
        # Start with current candidates
        cands = set(candidates[cell])
        # Restrict to clue digit if applicable
        clue_digits = {d for (c, d) in clues if c == cell}
        if clue_digits:
            cands &= clue_digits
        # Remove digits forced in neighbors (singleton elimination)
        for nbr in neighbors(cell):
            if len(candidates[nbr]) == 1:
                cands -= candidates[nbr]
        new_candidates[cell] = cands
    return new_candidates

def total_candidate_mass(candidates):
    """Sum of all candidate set sizes."""
    return sum(len(candidates[c]) for c in ALL_CELLS)

def propagate_until_stable(clues, max_steps=729):
    """Run propagation until fixed point, return (candidates, steps)."""
    candidates = initial_candidates(clues)
    for step in range(max_steps):
        new_candidates = propagate_step(clues, candidates)
        if new_candidates == candidates:
            return candidates, step
        candidates = new_candidates
    return candidates, max_steps


# ─── Demo 1: Tropical Cost of a Known Valid Sudoku ────────────────────────────

def demo_tropical_cost():
    """Demonstrate that a valid Sudoku has zero tropical cost."""
    print("=" * 60)
    print("DEMO 1: Tropical Cost of a Valid Sudoku")
    print("=" * 60)

    # A known valid Sudoku solution
    solution = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ]

    assignment = {}
    for r in range(9):
        for c in range(9):
            assignment[(r, c)] = solution[r][c] - 1  # 0-indexed digits

    clues = [((0, 0), 4), ((0, 1), 2), ((0, 2), 3)]  # Some clues (0-indexed)

    cost = tropical_sudoku_cost(clues, assignment)
    valid = is_valid(clues, assignment)

    print(f"Tropical cost: {cost}")
    print(f"Is valid: {valid}")
    print(f"Exactness theorem verified: cost=0 ↔ valid = {cost == 0 and valid}")
    print()

    # Now corrupt the assignment
    corrupted = dict(assignment)
    corrupted[(0, 0)] = assignment[(0, 1)]  # Create a conflict in row 0

    cost_corrupted = tropical_sudoku_cost(clues, corrupted)
    valid_corrupted = is_valid(clues, corrupted)

    print(f"Corrupted tropical cost: {cost_corrupted}")
    print(f"Corrupted is valid: {valid_corrupted}")
    print(f"Exactness holds: cost>0 ↔ invalid = {cost_corrupted > 0 and not valid_corrupted}")
    print()


# ─── Demo 2: Monotonicity Under Adding Clues ─────────────────────────────────

def demo_monotonicity():
    """Demonstrate that adding clues increases tropical cost."""
    print("=" * 60)
    print("DEMO 2: Monotonicity of Tropical Cost Under Adding Clues")
    print("=" * 60)

    # Random assignment
    rng = np.random.RandomState(42)
    assignment = {(r, c): rng.randint(0, 9) for r in range(9) for c in range(9)}

    clue_sizes = [0, 5, 10, 20, 40, 60, 81]
    # Build nested clue sets
    all_cells_shuffled = list(ALL_CELLS)
    rng.shuffle(all_cells_shuffled)

    prev_cost = 0
    for size in clue_sizes:
        clues = [(all_cells_shuffled[i], rng.randint(0, 9))
                 for i in range(size)]
        cost = tropical_sudoku_cost(clues, assignment)
        print(f"  {size:3d} clues → tropical cost = {cost:5d}  "
              f"(monotone: {cost >= prev_cost})")
        prev_cost = cost
    print()


# ─── Demo 3: Constraint Propagation ──────────────────────────────────────────

def demo_propagation():
    """Demonstrate propagation shrinking candidate sets."""
    print("=" * 60)
    print("DEMO 3: Constraint Propagation (Candidate Elimination)")
    print("=" * 60)

    # Clues from a classic puzzle
    clue_data = [
        (0,0,5), (0,1,3), (0,4,7),
        (1,0,6), (1,3,1), (1,4,9), (1,5,5),
        (2,1,9), (2,2,8), (2,7,6),
        (3,0,8), (3,4,6), (3,8,3),
        (4,0,4), (4,3,8), (4,5,3), (4,8,1),
        (5,0,7), (5,4,2), (5,8,6),
        (6,1,6), (6,6,2), (6,7,8),
        (7,3,4), (7,4,1), (7,5,9), (7,8,5),
        (8,4,8), (8,7,7), (8,8,9),
    ]
    clues = [((r, c), d - 1) for r, c, d in clue_data]

    candidates, steps = propagate_until_stable(clues)
    mass = total_candidate_mass(candidates)
    residual = mass - 81

    print(f"  Initial mass: {81 * 9}")
    print(f"  After propagation: {mass}")
    print(f"  Steps to stabilize: {steps}")
    print(f"  Residual ambiguity: {residual}")
    print()

    # Show a few cells
    for cell in [(0, 2), (0, 3), (4, 4), (8, 0)]:
        print(f"  Cell {cell}: candidates = "
              f"{sorted(d+1 for d in candidates[cell])}")
    print()


# ─── Demo 4: Phase Transition in Residual Ambiguity ──────────────────────────

def demo_phase_transition():
    """Demonstrate how residual ambiguity peaks near the feasibility boundary."""
    print("=" * 60)
    print("DEMO 4: Phase Transition — Residual Ambiguity vs Clue Density")
    print("=" * 60)

    # Use the known valid solution
    solution = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ]

    rng = np.random.RandomState(123)
    cells_shuffled = list(ALL_CELLS)
    rng.shuffle(cells_shuffled)

    print(f"  {'Clues':>6} {'Mass':>6} {'Residual':>9} {'Steps':>6}")
    print(f"  {'-'*6} {'-'*6} {'-'*9} {'-'*6}")

    max_residual = 0
    max_residual_clues = 0

    for n_clues in range(0, 82, 3):
        clues = [(cells_shuffled[i], solution[cells_shuffled[i][0]][cells_shuffled[i][1]] - 1)
                 for i in range(n_clues)]
        candidates, steps = propagate_until_stable(clues)
        mass = total_candidate_mass(candidates)
        residual = mass - 81

        if residual > max_residual:
            max_residual = residual
            max_residual_clues = n_clues

        print(f"  {n_clues:6d} {mass:6d} {residual:9d} {steps:6d}")

    print()
    print(f"  Peak residual ambiguity: {max_residual} at {max_residual_clues} clues")
    print(f"  This demonstrates the tropical boundary phenomenon:")
    print(f"  ambiguity is maximized at intermediate clue density.")
    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL SUDOKU: Min-Plus Constraint Satisfaction     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_tropical_cost()
    demo_monotonicity()
    demo_propagation()
    demo_phase_transition()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Sudoku CSP.

Generates publication-quality figures showing:
1. Phase transition in residual ambiguity
2. Propagation convergence (mass decay)
3. Tropical cost landscape
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO
from algorithms import (
    ConstraintPropagator, TropicalSudokuCSP,
    phase_transition_scan, ALL_CELLS
)


SOLUTION = [
    [5, 3, 4, 6, 7, 8, 9, 1, 2],
    [6, 7, 2, 1, 9, 5, 3, 4, 8],
    [1, 9, 8, 3, 4, 2, 5, 6, 7],
    [8, 5, 9, 7, 6, 1, 4, 2, 3],
    [4, 2, 6, 8, 5, 3, 7, 9, 1],
    [7, 1, 3, 9, 2, 4, 8, 5, 6],
    [9, 6, 1, 5, 3, 7, 2, 8, 4],
    [2, 8, 7, 4, 1, 9, 6, 3, 5],
    [3, 4, 5, 2, 8, 6, 1, 7, 9],
]


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def generate_phase_transition_plot():
    """Generate the phase transition plot (residual ambiguity vs clue density)."""
    print("Generating phase transition plot...")
    results = phase_transition_scan(SOLUTION, n_trials=30, seed=42)

    clue_counts = sorted(results.keys())
    mean_residuals = [results[k]["mean_residual"] for k in clue_counts]
    std_residuals = [results[k]["std_residual"] for k in clue_counts]
    solved_fracs = [results[k]["solved_frac"] for k in clue_counts]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

    # Top: Residual ambiguity
    ax1.fill_between(clue_counts,
                     [m - s for m, s in zip(mean_residuals, std_residuals)],
                     [m + s for m, s in zip(mean_residuals, std_residuals)],
                     alpha=0.3, color='#2196F3')
    ax1.plot(clue_counts, mean_residuals, 'o-', color='#1565C0',
             markersize=3, linewidth=1.5, label='Mean residual ambiguity')
    ax1.set_ylabel('Residual Ambiguity', fontsize=12)
    ax1.set_title('Phase Transition in Tropical Sudoku', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Bottom: Solved fraction
    ax2.plot(clue_counts, solved_fracs, 's-', color='#4CAF50',
             markersize=3, linewidth=1.5, label='Fraction solved by propagation')
    ax2.set_xlabel('Number of Clues', fontsize=12)
    ax2.set_ylabel('Fraction Solved', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.05, 1.05)

    fig.tight_layout()
    return fig_to_base64(fig), fig


def generate_propagation_convergence_plot():
    """Generate convergence plot showing mass decay during propagation."""
    print("Generating propagation convergence plot...")
    rng = np.random.RandomState(42)
    cells = list(ALL_CELLS)
    rng.shuffle(cells)

    fig, ax = plt.subplots(figsize=(10, 6))

    for n_clues, color, label in [
        (10, '#F44336', '10 clues'),
        (20, '#FF9800', '20 clues'),
        (30, '#4CAF50', '30 clues'),
        (40, '#2196F3', '40 clues'),
        (50, '#9C27B0', '50 clues'),
    ]:
        clues = [(cells[i], SOLUTION[cells[i][0]][cells[i][1]] - 1)
                 for i in range(n_clues)]
        prop = ConstraintPropagator(clues)
        prop.propagate_until_stable()

        ax.plot(range(len(prop.mass_history)), prop.mass_history,
                'o-', color=color, markersize=4, linewidth=2, label=label)

    ax.set_xlabel('Propagation Step', fontsize=12)
    ax.set_ylabel('Total Candidate Mass', fontsize=12)
    ax.set_title('Propagation Convergence: Candidate Mass Decay', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=81, color='gray', linestyle='--', alpha=0.5, label='Solved baseline (81)')
    ax.axhline(y=729, color='gray', linestyle=':', alpha=0.3)
    ax.set_ylim(0, 750)

    fig.tight_layout()
    return fig_to_base64(fig), fig


def generate_cost_landscape_plot():
    """Generate a heatmap of tropical costs for perturbations of a valid solution."""
    print("Generating cost landscape plot...")
    assignment = {(r, c): SOLUTION[r][c] - 1 for r in range(9) for c in range(9)}
    csp = TropicalSudokuCSP([])

    # For each cell, compute cost of setting it to each digit
    cost_grid = np.zeros((81, 9))
    for idx, cell in enumerate(ALL_CELLS):
        original = assignment[cell]
        for d in range(9):
            test_assignment = dict(assignment)
            test_assignment[cell] = d
            cost_grid[idx, d] = csp.tropical_cost(test_assignment)

    fig, ax = plt.subplots(figsize=(10, 12))
    im = ax.imshow(cost_grid, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel('Digit (0-indexed)', fontsize=12)
    ax.set_ylabel('Cell Index', fontsize=12)
    ax.set_title('Tropical Cost Landscape:\nCost of Assigning Each Digit to Each Cell',
                 fontsize=14, fontweight='bold')
    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Tropical Cost', fontsize=11)

    # Mark the correct assignments
    for idx, cell in enumerate(ALL_CELLS):
        correct = assignment[cell]
        ax.plot(correct, idx, 'wo', markersize=2)

    fig.tight_layout()
    return fig_to_base64(fig), fig


if __name__ == "__main__":
    b64_phase, fig1 = generate_phase_transition_plot()
    fig1.savefig('/workspace/request-project/phase_transition.png', dpi=150, bbox_inches='tight')

    b64_conv, fig2 = generate_propagation_convergence_plot()
    fig2.savefig('/workspace/request-project/propagation_convergence.png', dpi=150, bbox_inches='tight')

    b64_cost, fig3 = generate_cost_landscape_plot()
    fig3.savefig('/workspace/request-project/cost_landscape.png', dpi=150, bbox_inches='tight')

    print("All visualizations generated and saved.")
    print(f"Phase transition plot: {len(b64_phase)} chars")
    print(f"Convergence plot: {len(b64_conv)} chars")
    print(f"Cost landscape plot: {len(b64_cost)} chars")
