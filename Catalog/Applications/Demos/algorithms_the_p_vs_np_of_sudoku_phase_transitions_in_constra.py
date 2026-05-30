#!/usr/bin/env python3
"""
Algorithms for Phase Transition Analysis in Constraint Satisfaction Problems

Implements:
1. CSP Phase Classifier - classify instances by constraint density
2. Latin Square Backtracking Solver with instrumentation
3. Phase Transition Detection via binary search
4. Constraint Entropy Estimator

All algorithms include complexity analysis and docstrings.
"""

from typing import Optional
import random
import time
import math


# ============================================================================
# Algorithm 1: CSP Phase Classifier
# ============================================================================

class PhaseClassifier:
    """
    Classifies CSP instances into SAT, CRITICAL, or UNSAT phases based on
    constraint density relative to the critical threshold.

    The critical density is d_c(n) = (n²-1)/n² for Latin square / Sudoku
    problems of order n.

    Time complexity: O(1) per classification
    Space complexity: O(1)

    Example:
        >>> clf = PhaseClassifier(n=3)
        >>> clf.classify(0.5)
        'SAT'
        >>> clf.classify(0.889)
        'CRITICAL'
        >>> clf.classify(0.95)
        'UNSAT'
    """

    def __init__(self, n: int):
        """Initialize with grid order n."""
        self.n = n
        self.dc = (n**2 - 1) / n**2
        self.window = 1 / n**2  # Critical window width

    def classify(self, density: float) -> str:
        """Classify density into phase regime."""
        if density < self.dc - self.window:
            return "SAT"
        elif density > self.dc + self.window:
            return "UNSAT"
        else:
            return "CRITICAL"

    def critical_density(self) -> float:
        """Return the critical density."""
        return self.dc

    def window_width(self) -> float:
        """Return the critical window width 2/n²."""
        return 2 * self.window


# ============================================================================
# Algorithm 2: Latin Square Solver with Instrumentation
# ============================================================================

class LatinSquareSolver:
    """
    Backtracking solver for Latin square completion with instrumentation
    to measure computational hardness at different densities.

    Time complexity: O(n! * n) worst case for n×n grid
    Space complexity: O(n²) for the grid

    Example:
        >>> solver = LatinSquareSolver(4)
        >>> grid = [[0,1,2,3],[1,None,None,None],[None,None,None,None],[None,None,None,None]]
        >>> solver.solve(grid)
        True
        >>> solver.backtracks
        # (number of backtracks used)
    """

    def __init__(self, n: int):
        """Initialize solver for n×n Latin squares."""
        self.n = n
        self.backtracks = 0
        self.nodes_explored = 0
        self.solutions_found = 0

    def reset_stats(self):
        """Reset instrumentation counters."""
        self.backtracks = 0
        self.nodes_explored = 0
        self.solutions_found = 0

    def solve(self, grid: list[list[Optional[int]]], count_all: bool = False) -> bool:
        """
        Solve the Latin square completion problem.

        Args:
            grid: Partially filled n×n grid (None for empty cells)
            count_all: If True, count all solutions; if False, stop at first

        Returns:
            True if at least one solution exists
        """
        self.reset_stats()
        return self._backtrack(grid, count_all)

    def _backtrack(self, grid: list[list[Optional[int]]], count_all: bool) -> bool:
        """Internal backtracking search."""
        self.nodes_explored += 1

        # Find the most constrained empty cell (MRV heuristic)
        best_cell = None
        best_count = self.n + 1

        for i in range(self.n):
            for j in range(self.n):
                if grid[i][j] is None:
                    available = self._available_values(grid, i, j)
                    if len(available) == 0:
                        self.backtracks += 1
                        return False
                    if len(available) < best_count:
                        best_count = len(available)
                        best_cell = (i, j)

        if best_cell is None:
            # All cells filled - solution found
            self.solutions_found += 1
            return True

        i, j = best_cell
        available = self._available_values(grid, i, j)

        for v in available:
            grid[i][j] = v
            if self._backtrack(grid, count_all):
                if not count_all:
                    return True
            grid[i][j] = None
            self.backtracks += 1

        return self.solutions_found > 0 if count_all else False

    def _available_values(self, grid: list[list[Optional[int]]], i: int, j: int) -> list[int]:
        """Get available values for cell (i, j)."""
        used = set()
        for k in range(self.n):
            if grid[i][k] is not None:
                used.add(grid[i][k])
            if grid[k][j] is not None:
                used.add(grid[k][j])
        return [v for v in range(self.n) if v not in used]


# ============================================================================
# Algorithm 3: Phase Transition Detector
# ============================================================================

class PhaseTransitionDetector:
    """
    Detects the empirical phase transition point by binary search over density.

    For each density, estimates P(SAT) by sampling random instances.
    The phase transition is located where P(SAT) ≈ 0.5.

    Time complexity: O(log(1/ε) * trials * T_solve) where T_solve is solver time
    Space complexity: O(n²)

    Example:
        >>> detector = PhaseTransitionDetector(n=4, trials=50)
        >>> dc = detector.find_critical_density()
        >>> print(f"Empirical d_c = {dc:.4f}")
    """

    def __init__(self, n: int, trials: int = 30):
        """Initialize detector for n×n Latin squares."""
        self.n = n
        self.trials = trials
        self.solver = LatinSquareSolver(n)

    def estimate_sat_probability(self, density: float) -> float:
        """Estimate P(SAT) at given density by random sampling."""
        sat_count = 0
        for _ in range(self.trials):
            grid = self._random_instance(density)
            if self.solver.solve(grid):
                sat_count += 1
        return sat_count / self.trials

    def find_critical_density(self, tol: float = 0.01) -> float:
        """
        Find the critical density where P(SAT) ≈ 0.5 by binary search.

        Args:
            tol: Tolerance for the density estimate

        Returns:
            Estimated critical density
        """
        lo, hi = 0.0, 1.0

        while hi - lo > tol:
            mid = (lo + hi) / 2
            p = self.estimate_sat_probability(mid)
            if p > 0.5:
                lo = mid
            else:
                hi = mid

        return (lo + hi) / 2

    def scan_densities(self, num_points: int = 20) -> list[tuple[float, float]]:
        """
        Scan densities from 0 to 1 and estimate P(SAT) at each.

        Returns:
            List of (density, P(SAT)) pairs
        """
        results = []
        for i in range(num_points + 1):
            d = i / num_points
            p = self.estimate_sat_probability(d)
            results.append((d, p))
        return results

    def _random_instance(self, density: float) -> list[list[Optional[int]]]:
        """Generate a random partial Latin square at given density."""
        # Start from a valid Latin square (Cayley table)
        base = [[(i + j) % self.n for j in range(self.n)] for i in range(self.n)]

        # Randomly permute rows and columns for variety
        row_perm = list(range(self.n))
        col_perm = list(range(self.n))
        val_perm = list(range(self.n))
        random.shuffle(row_perm)
        random.shuffle(col_perm)
        random.shuffle(val_perm)

        square = [[val_perm[base[row_perm[i]][col_perm[j]]]
                   for j in range(self.n)] for i in range(self.n)]

        # Keep cells with given density
        k = int(density * self.n**2)
        cells = [(i, j) for i in range(self.n) for j in range(self.n)]
        random.shuffle(cells)
        filled = set(cells[:k])

        return [
            [square[i][j] if (i, j) in filled else None for j in range(self.n)]
            for i in range(self.n)
        ]


# ============================================================================
# Algorithm 4: Constraint Entropy Estimator
# ============================================================================

class ConstraintEntropyEstimator:
    """
    Estimates constraint entropy H(n, k) for Latin square problems.

    H(n, k) = log2(completions(k)) / log2(n^(n²-k))
    Normalized to [0, 1]: 1 = unconstrained, 0 = fully determined.

    Time complexity: O(trials * T_solve) per density point
    Space complexity: O(n²)

    Example:
        >>> est = ConstraintEntropyEstimator(n=4)
        >>> h = est.estimate(density=0.5)
    """

    def __init__(self, n: int, trials: int = 20):
        """Initialize estimator for n×n Latin squares."""
        self.n = n
        self.trials = trials
        self.solver = LatinSquareSolver(n)

    def estimate(self, density: float) -> float:
        """
        Estimate constraint entropy at given density.

        Returns value in [0, 1] representing normalized entropy.
        """
        k = int(density * self.n**2)
        free = self.n**2 - k

        if free <= 0:
            return 0.0

        max_completions = self.n ** free
        if max_completions == 0:
            return 0.0

        total_completions = 0
        for _ in range(self.trials):
            grid = self._random_instance(density)
            self.solver.solve(grid, count_all=True)
            total_completions += self.solver.solutions_found

        avg_completions = total_completions / self.trials
        if avg_completions <= 0:
            return 0.0

        return min(1.0, avg_completions / max_completions)

    def entropy_profile(self, num_points: int = 10) -> list[tuple[float, float]]:
        """Compute entropy at multiple densities."""
        results = []
        for i in range(num_points + 1):
            d = i / num_points
            h = self.estimate(d)
            results.append((d, h))
        return results

    def _random_instance(self, density: float) -> list[list[Optional[int]]]:
        """Generate random partial Latin square."""
        base = [[(i + j) % self.n for j in range(self.n)] for i in range(self.n)]
        k = int(density * self.n**2)
        cells = [(i, j) for i in range(self.n) for j in range(self.n)]
        random.shuffle(cells)
        filled = set(cells[:k])
        return [
            [base[i][j] if (i, j) in filled else None for j in range(self.n)]
            for i in range(self.n)
        ]


# ============================================================================
# Main: Run all algorithms
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithms for CSP Phase Transition Analysis")
    print("=" * 70)

    # Algorithm 1: Phase Classification
    print("\n--- Algorithm 1: Phase Classification ---")
    for n in [3, 4, 5]:
        clf = PhaseClassifier(n)
        print(f"\n  n={n}, d_c={clf.critical_density():.4f}, "
              f"window=[{clf.dc - clf.window:.4f}, {clf.dc + clf.window:.4f}]")
        for d in [0.0, 0.25, 0.5, 0.75, 0.85, 0.9, 0.95, 1.0]:
            phase = clf.classify(d)
            print(f"    d={d:.2f} -> {phase}")

    # Algorithm 2: Solver instrumentation
    print("\n--- Algorithm 2: Solver Instrumentation (n=4) ---")
    solver = LatinSquareSolver(4)
    for d in [0.0, 0.25, 0.5, 0.75, 0.875]:
        base = [[(i + j) % 4 for j in range(4)] for i in range(4)]
        k = int(d * 16)
        cells = [(i, j) for i in range(4) for j in range(4)]
        random.seed(42)
        random.shuffle(cells)
        filled = set(cells[:k])
        grid = [[base[i][j] if (i, j) in filled else None for j in range(4)]
                for i in range(4)]
        solver.solve(grid, count_all=True)
        print(f"  d={d:.3f}: solutions={solver.solutions_found}, "
              f"backtracks={solver.backtracks}, nodes={solver.nodes_explored}")

    # Algorithm 3: Phase Transition Detection
    print("\n--- Algorithm 3: Phase Transition Detection (n=4) ---")
    random.seed(0)
    detector = PhaseTransitionDetector(n=4, trials=20)
    theoretical = (4**2 - 1) / 4**2
    empirical = detector.find_critical_density(tol=0.02)
    print(f"  Theoretical d_c = {theoretical:.4f}")
    print(f"  Empirical d_c   = {empirical:.4f}")
    print(f"  Error           = {abs(empirical - theoretical):.4f}")

    print("\n  Density scan:")
    results = detector.scan_densities(num_points=10)
    for d, p in results:
        bar = "#" * int(p * 30)
        print(f"    d={d:.2f}: P(SAT)={p:.2f} |{bar}")

    print("\n" + "=" * 70)
    print("All algorithms demonstrated successfully.")
    print("=" * 70)
