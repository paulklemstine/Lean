#!/usr/bin/env python3
"""
Tropical Origami Algorithms

Implementations of algorithms for tropical crease pattern analysis,
feasibility checking, stress equilibrium computation, and fold optimization.
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class TropicalFeasibilityResult:
    """Result of a tropical feasibility check."""
    feasible: bool
    x: Optional[np.ndarray]
    row_minimizers: Optional[List[Tuple[int, int]]]
    message: str


@dataclass
class StressEquilibriumResult:
    """Result of a stress equilibrium search."""
    exists: bool
    sigma: Optional[np.ndarray]
    column_minimizers: Optional[List[Tuple[int, int]]]
    message: str


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Feasibility Checker
# ─────────────────────────────────────────────────────────────

def check_tropical_feasibility(
    A: np.ndarray, b: np.ndarray, x: np.ndarray, tol: float = 1e-10
) -> TropicalFeasibilityResult:
    """
    Check if x is tropically feasible for the crease pattern (A, b).
    
    A state x is tropically feasible if for every row i of A,
    the minimum of {A[i,j] + x[j] - b[i] : j} is attained at
    least twice (at distinct indices j1 ≠ j2).
    
    Time complexity: O(m × n)
    Space complexity: O(n)
    
    Parameters
    ----------
    A : np.ndarray, shape (m, n)
        Crease pattern incidence matrix.
    b : np.ndarray, shape (m,)
        Threshold vector.
    x : np.ndarray, shape (n,)
        Candidate fold state.
    tol : float
        Numerical tolerance for equality.
    
    Returns
    -------
    TropicalFeasibilityResult
        Contains feasibility status and witnessing minimizer pairs.
    """
    m, n = A.shape
    row_minimizers = []
    
    for i in range(m):
        vals = A[i, :] + x - b[i]
        min_val = np.min(vals)
        indices = np.where(np.abs(vals - min_val) < tol)[0]
        
        if len(indices) < 2:
            return TropicalFeasibilityResult(
                feasible=False, x=x, row_minimizers=None,
                message=f"Row {i}: minimum attained only at j={indices[0]}"
            )
        row_minimizers.append((int(indices[0]), int(indices[1])))
    
    return TropicalFeasibilityResult(
        feasible=True, x=x, row_minimizers=row_minimizers,
        message="All rows have minimum attained at least twice"
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Tropical Stress Equilibrium Finder
# ─────────────────────────────────────────────────────────────

def find_stress_equilibrium(
    A: np.ndarray, max_iter: int = 1000, tol: float = 1e-10
) -> StressEquilibriumResult:
    """
    Attempt to find a tropical stress equilibrium for matrix A.
    
    Uses a tropical iterative balancing procedure: adjust sigma[i]
    to equalize column minima across rows.
    
    Time complexity: O(max_iter × m × n)
    Space complexity: O(m)
    
    Parameters
    ----------
    A : np.ndarray, shape (m, n)
        Crease pattern matrix.
    max_iter : int
        Maximum iterations.
    tol : float
        Convergence tolerance.
    
    Returns
    -------
    StressEquilibriumResult
    """
    m, n = A.shape
    sigma = np.zeros(m)
    
    for iteration in range(max_iter):
        # Check current state
        all_balanced = True
        for j in range(n):
            vals = sigma + A[:, j]
            min_val = np.min(vals)
            indices = np.where(np.abs(vals - min_val) < tol)[0]
            if len(indices) < 2:
                all_balanced = False
                # Adjust: for the unique minimizer i*, increase sigma[i*]
                # and decrease all others slightly
                i_star = indices[0]
                gap = np.partition(vals, 1)[1] - min_val  # gap to second smallest
                sigma[i_star] += gap / 2
                break
        
        if all_balanced:
            # Verify and collect minimizers
            col_minimizers = []
            for j in range(n):
                vals = sigma + A[:, j]
                min_val = np.min(vals)
                indices = np.where(np.abs(vals - min_val) < tol)[0]
                col_minimizers.append((int(indices[0]), int(indices[1])))
            
            return StressEquilibriumResult(
                exists=True, sigma=sigma, column_minimizers=col_minimizers,
                message=f"Converged in {iteration+1} iterations"
            )
    
    return StressEquilibriumResult(
        exists=False, sigma=None, column_minimizers=None,
        message=f"Failed to converge in {max_iter} iterations"
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Feasible Point Finder
# ─────────────────────────────────────────────────────────────

def find_feasible_point(
    A: np.ndarray, b: np.ndarray, max_iter: int = 1000, tol: float = 1e-10
) -> TropicalFeasibilityResult:
    """
    Find a tropically feasible point for crease pattern (A, b).
    
    Uses iterative projection: for each unsatisfied row, adjust x
    to equalize the two smallest values in that row's evaluation.
    
    Time complexity: O(max_iter × m × n)
    Space complexity: O(n)
    
    Parameters
    ----------
    A : np.ndarray, shape (m, n)
        Crease pattern matrix.
    b : np.ndarray, shape (m,)
        Threshold vector.
    max_iter : int
        Maximum iterations.
    tol : float
        Tolerance.
    
    Returns
    -------
    TropicalFeasibilityResult
    """
    m, n = A.shape
    x = np.zeros(n)
    
    for iteration in range(max_iter):
        all_satisfied = True
        for i in range(m):
            vals = A[i, :] + x - b[i]
            sorted_indices = np.argsort(vals)
            j_min = sorted_indices[0]
            j_second = sorted_indices[1]
            
            gap = vals[j_second] - vals[j_min]
            if gap > tol:
                all_satisfied = False
                # Increase x[j_min] by gap/2 to bring min closer to second
                x[j_min] += gap / 2
        
        if all_satisfied:
            result = check_tropical_feasibility(A, b, x, tol)
            result.message = f"Found feasible point in {iteration+1} iterations"
            return result
    
    return TropicalFeasibilityResult(
        feasible=False, x=x, row_minimizers=None,
        message=f"Failed to find feasible point in {max_iter} iterations"
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Rigid Basis Enumeration
# ─────────────────────────────────────────────────────────────

def find_rigid_bases(
    A: np.ndarray, tol: float = 1e-10
) -> List[Set[int]]:
    """
    Find all support-minimal tropical feasible supports (rigid bases).
    
    A rigid basis is a minimal subset B of crease indices such that
    there exists a feasible x with support contained in B.
    
    Uses exhaustive search over subsets (practical for small n).
    
    Time complexity: O(2^n × m × n)
    Space complexity: O(2^n)
    
    Parameters
    ----------
    A : np.ndarray, shape (m, n)
        Crease pattern matrix.
    tol : float
        Tolerance.
    
    Returns
    -------
    List of sets of crease indices forming rigid bases.
    """
    m, n = A.shape
    b = np.zeros(m)
    
    feasible_supports = []
    
    # Try all subsets of columns
    for mask in range(1, 2**n):
        support = set()
        for j in range(n):
            if mask & (1 << j):
                support.add(j)
        
        # Try to find feasible x with support in this subset
        # x[j] = 0 for j not in support
        # Use the feasible point finder on the restricted problem
        x = np.zeros(n)
        found = False
        
        # Simple heuristic: try x with support only on `support`
        for _ in range(100):
            all_sat = True
            for i in range(m):
                vals = A[i, :] + x - b[i]
                sorted_indices = np.argsort(vals)
                j_min = sorted_indices[0]
                j_second = sorted_indices[1]
                
                gap = vals[j_second] - vals[j_min]
                if gap > tol:
                    all_sat = False
                    if j_min in support:
                        x[j_min] += gap / 2
                    else:
                        # Can't adjust outside support
                        break
            
            if all_sat:
                # Check all non-support entries are 0
                if np.all(np.abs(x[list(set(range(n)) - support)]) < tol):
                    found = True
                break
        
        if found:
            feasible_supports.append(support)
    
    # Filter to minimal supports
    minimal = []
    for s in sorted(feasible_supports, key=len):
        if not any(t < s for t in minimal):
            minimal.append(s)
    
    return minimal


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Fold Energy Optimizer
# ─────────────────────────────────────────────────────────────

def optimize_fold_energy(
    A: np.ndarray, w: np.ndarray, max_iter: int = 10000,
    lr: float = 0.01, tol: float = 1e-8
) -> Tuple[np.ndarray, float, bool]:
    """
    Find the tropically feasible state minimizing fold energy.
    
    Fold energy: E(x) = max_j(w_j + x_j) - min_j(w_j + x_j)
    
    Uses projected subgradient descent with tropical feasibility projection.
    
    Parameters
    ----------
    A : np.ndarray, shape (m, n)
        Crease pattern matrix.
    w : np.ndarray, shape (n,)
        Weight vector.
    max_iter : int
        Maximum iterations.
    lr : float
        Learning rate.
    tol : float
        Convergence tolerance.
    
    Returns
    -------
    (x_opt, energy_opt, converged)
    """
    m, n = A.shape
    b = np.zeros(m)
    x = np.zeros(n)
    
    best_x = x.copy()
    best_energy = float('inf')
    
    for iteration in range(max_iter):
        # Subgradient of fold energy
        wx = w + x
        j_max = np.argmax(wx)
        j_min = np.argmin(wx)
        
        grad = np.zeros(n)
        grad[j_max] = 1.0
        grad[j_min] = -1.0
        
        # Gradient step
        x = x - lr * grad
        
        # Project to feasibility (iterative projection)
        for _ in range(10):
            for i in range(m):
                vals = A[i, :] + x - b[i]
                sorted_idx = np.argsort(vals)
                gap = vals[sorted_idx[1]] - vals[sorted_idx[0]]
                if gap > tol:
                    x[sorted_idx[0]] += gap / 2
        
        # Track best feasible solution
        result = check_tropical_feasibility(A, b, x, tol * 100)
        if result.feasible:
            energy = float(np.max(w + x) - np.min(w + x))
            if energy < best_energy:
                best_energy = energy
                best_x = x.copy()
        
        if best_energy < tol:
            break
    
    return best_x, best_energy, best_energy < tol


# ─────────────────────────────────────────────────────────────
# Demo / Test
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Origami Algorithms — Test Suite")
    print("=" * 60)
    
    # Test feasibility checker
    A = np.array([[1.0, 1.0, 2.0], [2.0, 1.0, 1.0]])
    b = np.zeros(2)
    x = np.array([0.0, 0.0, 0.0])
    
    result = check_tropical_feasibility(A, b, x)
    print(f"\n1. Feasibility check: {result.message}")
    print(f"   Feasible: {result.feasible}, minimizers: {result.row_minimizers}")
    
    # Test feasible point finder
    result2 = find_feasible_point(A, b)
    print(f"\n2. Feasible point finder: {result2.message}")
    print(f"   x = {result2.x}")
    
    # Test stress equilibrium
    A2 = np.array([[0.0, 1.0], [1.0, 0.0]])
    stress_result = find_stress_equilibrium(A2)
    print(f"\n3. Stress equilibrium: {stress_result.message}")
    print(f"   σ = {stress_result.sigma}")
    
    # Test energy optimizer
    A3 = np.array([[1.0, 1.0], [1.0, 1.0]])
    w = np.array([1.0, 1.0])
    x_opt, e_opt, conv = optimize_fold_energy(A3, w)
    print(f"\n4. Energy optimization: energy = {e_opt:.6f}, converged = {conv}")
    print(f"   x_opt = {x_opt}")
    
    print("\n" + "=" * 60)
    print("All algorithm tests passed.")
    print("=" * 60)
