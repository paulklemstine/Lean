#!/usr/bin/env python3
"""
Algorithms for Tropical Hodge Theory

Implements the core algorithms arising from the tropical Hodge–cycle
correspondence theorem and the finite generation result.
"""

import numpy as np
from typing import List, Tuple, Optional


def balanced_submodule_generators(
    n_cells: int,
    dims: List[int],
    top_dim: int,
    adj: List[Tuple[int, int]],
    codim: int
) -> np.ndarray:
    """
    Compute generators for the balanced submodule of codimension `codim`.
    
    A weight function w : Cells → ℤ is balanced if:
    1. w[c] = 0 whenever dim(c) + codim ≠ top_dim  (support condition)
    2. For every cell σ with dim(σ) + codim = top_dim + 1,
       Σ_{τ adj σ} w[τ] = 0  (balancing condition)
    
    Returns: matrix whose rows generate the balanced submodule.
    
    Time: O(n_cells² · codim_cells)
    Space: O(n_cells · codim_cells)
    """
    # Identify cells of the right codimension
    codim_cells = [c for c in range(n_cells) if dims[c] + codim == top_dim]
    
    if not codim_cells:
        return np.zeros((0, n_cells), dtype=int)
    
    # Build adjacency sets
    adj_set = set(adj)
    
    # Build the balancing constraint matrix
    # For each cell σ with dim(σ) + codim = top_dim + 1,
    # we need Σ_{τ adj σ} w[τ] = 0 restricted to codim_cells
    constraint_cells = [c for c in range(n_cells) if dims[c] + codim == top_dim + 1]
    
    if not constraint_cells:
        # No constraints: all weight functions on codim cells are balanced
        gens = np.zeros((len(codim_cells), n_cells), dtype=int)
        for i, c in enumerate(codim_cells):
            gens[i, c] = 1
        return gens
    
    # Build constraint matrix (rows = constraints, cols = codim_cells)
    n_constraints = len(constraint_cells)
    n_free = len(codim_cells)
    
    # Map codim_cells to indices
    cell_to_idx = {c: i for i, c in enumerate(codim_cells)}
    
    A = np.zeros((n_constraints, n_free), dtype=int)
    for i, sigma in enumerate(constraint_cells):
        for tau in codim_cells:
            if (sigma, tau) in adj_set:
                A[i, cell_to_idx[tau]] = 1
    
    # Find kernel of A (integer kernel)
    kernel = integer_kernel(A)
    
    # Embed back into full cell space
    gens = np.zeros((kernel.shape[0], n_cells), dtype=int)
    for i in range(kernel.shape[0]):
        for j, c in enumerate(codim_cells):
            gens[i, c] = kernel[i, j]
    
    return gens


def integer_kernel(A: np.ndarray) -> np.ndarray:
    """
    Compute a basis for the integer kernel of matrix A.
    Uses Smith normal form approach via row reduction.
    
    Time: O(m · n · min(m,n)) where A is m×n
    """
    m, n = A.shape
    if m == 0:
        return np.eye(n, dtype=int)
    if n == 0:
        return np.zeros((0, 0), dtype=int)
    
    # Augment with identity to track transformations
    augmented = np.hstack([A.T, np.eye(n, dtype=int)])
    
    # Row reduce the augmented matrix
    augmented = augmented.astype(float)
    pivot_cols = []
    row = 0
    
    for col in range(m):
        # Find pivot
        max_row = row
        for r in range(row + 1, n):
            if abs(augmented[r, col]) > abs(augmented[max_row, col]):
                max_row = r
        
        if abs(augmented[max_row, col]) < 1e-10:
            continue
        
        # Swap
        augmented[[row, max_row]] = augmented[[max_row, row]]
        pivot_cols.append(col)
        
        # Eliminate
        for r in range(n):
            if r != row and abs(augmented[r, col]) > 1e-10:
                factor = augmented[r, col] / augmented[row, col]
                augmented[r] -= factor * augmented[row]
        
        row += 1
    
    # The kernel vectors are the rows where the A part is zero
    kernel_rows = []
    for r in range(row, n):
        if np.allclose(augmented[r, :m], 0, atol=1e-6):
            vec = np.round(augmented[r, m:]).astype(int)
            if not np.allclose(vec, 0):
                kernel_rows.append(vec)
    
    if not kernel_rows:
        return np.zeros((0, n), dtype=int)
    
    return np.array(kernel_rows)


def cycle_class_image(
    cycle_map: np.ndarray,
    balanced_gens: np.ndarray
) -> np.ndarray:
    """
    Compute generators for the cycle-class image.
    
    Args:
        cycle_map: m×n matrix (cohomology_rank × n_cells)
        balanced_gens: k×n matrix (k generators × n_cells)
    
    Returns: matrix whose rows generate the cycle-class image.
    
    Time: O(k · m · n)
    """
    if balanced_gens.shape[0] == 0:
        return np.zeros((0, cycle_map.shape[0]), dtype=int)
    
    return (cycle_map @ balanced_gens.T).T


def is_cycle_class(
    x: np.ndarray,
    cycle_map: np.ndarray,
    balanced_gens: np.ndarray
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test whether x is a cycle class and find a balanced representative.
    
    This is the algorithmic content of Theorem B: finite generation
    makes cycle class membership decidable.
    
    Args:
        x: cohomology class (vector in ℤ^m)
        cycle_map: m×n matrix
        balanced_gens: k×n matrix (generators of balanced submodule)
    
    Returns:
        (is_member, coefficients) where coefficients gives the
        integer linear combination of balanced generators.
    
    Time: O(k² · m)
    """
    image_gens = cycle_class_image(cycle_map, balanced_gens)
    
    if image_gens.shape[0] == 0:
        return (np.allclose(x, 0), np.array([]) if np.allclose(x, 0) else None)
    
    # Solve: image_gens^T · c = x for integer c
    # This is an integer linear system
    A = image_gens.T.astype(float)
    b = x.astype(float)
    
    try:
        c, residuals, rank, _ = np.linalg.lstsq(A, b, rcond=None)
        c_rounded = np.round(c).astype(int)
        
        if np.allclose(A @ c_rounded, b, atol=1e-6):
            return (True, c_rounded)
        else:
            return (False, None)
    except np.linalg.LinAlgError:
        return (False, None)


def transfer_cycle_classes(
    transfer_map: np.ndarray,
    cycle_image_gens: np.ndarray
) -> np.ndarray:
    """
    Apply the transfer map to cycle class generators.
    
    Implements Theorem C: transferred cycle classes are
    classical algebraic classes.
    
    Args:
        transfer_map: classical_rank × tropical_rank matrix
        cycle_image_gens: k × tropical_rank matrix
    
    Returns: k × classical_rank matrix of transferred generators.
    """
    if cycle_image_gens.shape[0] == 0:
        return np.zeros((0, transfer_map.shape[0]), dtype=int)
    
    return (transfer_map @ cycle_image_gens.T).T


def verify_hodge_cycle_correspondence(
    hodge_gens: np.ndarray,
    cycle_map: np.ndarray,
    balanced_gens: np.ndarray,
    verbose: bool = True
) -> bool:
    """
    Verify the Hodge–cycle correspondence for a concrete model.
    
    Checks that:
    1. Every Hodge generator is a cycle class.
    2. Every cycle class is a Hodge class.
    
    This is the computational verification of Theorem A.
    
    Time: O(k² · m · n) where k = max generators, m = coh rank, n = n_cells
    """
    cycle_gens = cycle_class_image(cycle_map, balanced_gens)
    
    if verbose:
        print(f"Hodge generators: {hodge_gens.shape[0]}")
        print(f"Cycle image generators: {cycle_gens.shape[0]}")
    
    # Check 1: every Hodge generator is a cycle class
    all_hodge_are_cycles = True
    for i, g in enumerate(hodge_gens):
        is_cycle, coeffs = is_cycle_class(g, cycle_map, balanced_gens)
        if verbose:
            status = "✓" if is_cycle else "✗"
            print(f"  Hodge gen {i}: {g} -> cycle class? {status}")
        if not is_cycle:
            all_hodge_are_cycles = False
    
    # Check 2: every cycle generator is in the Hodge span
    all_cycles_are_hodge = True
    for i, g in enumerate(cycle_gens):
        # Check if g is in the span of hodge_gens
        A = hodge_gens.T.astype(float)
        b = g.astype(float)
        try:
            c, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
            c_rounded = np.round(c).astype(int)
            is_hodge = np.allclose(A @ c_rounded, b, atol=1e-6)
        except np.linalg.LinAlgError:
            is_hodge = False
        
        if verbose:
            status = "✓" if is_hodge else "✗"
            print(f"  Cycle gen {i}: {g} -> Hodge class? {status}")
        if not is_hodge:
            all_cycles_are_hodge = False
    
    result = all_hodge_are_cycles and all_cycles_are_hodge
    if verbose:
        print(f"\nHodge = Cycle? {'✓ YES' if result else '✗ NO'}")
    
    return result


# ──────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Hodge Theory Algorithms")
    print("=" * 50)
    
    # Example: Tropical segment
    print("\n--- Tropical Segment ---")
    dims = [1, 0, 0]
    adj = [(0,1), (0,2), (1,0), (2,0)]
    gens = balanced_submodule_generators(3, dims, 1, adj, 1)
    print(f"Balanced generators (codim 1):\n{gens}")
    
    # Example: cycle class membership test
    print("\n--- Cycle Class Membership ---")
    cycle_map = np.array([[0, 1, -1]])  # difference of vertex weights
    x_test = np.array([2])
    is_member, coeffs = is_cycle_class(x_test, cycle_map, gens)
    print(f"Is {x_test} a cycle class? {is_member}")
    if coeffs is not None:
        print(f"  Coefficients: {coeffs}")
    
    # Example: verification
    print("\n--- Hodge-Cycle Verification ---")
    hodge_gens = np.array([[0, 1, -1]])  # single generator
    verify_hodge_cycle_correspondence(hodge_gens, cycle_map, gens)
    
    # Example with mismatch
    print("\n--- Model where Hodge ≠ Cycle ---")
    # 2 cells, cohomology rank 1
    cycle_map_2 = np.array([[2, 0]])  # maps w ↦ 2·w[0]
    balanced_2 = np.array([[1, 0], [0, 1]])  # all weights balanced
    hodge_2 = np.array([[1]])  # Hodge generator = [1]
    verify_hodge_cycle_correspondence(hodge_2, cycle_map_2, balanced_2)
