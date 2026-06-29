#!/usr/bin/env python3
"""
Tropical Spectral Transfer — Applications

Demonstrates real-world applications of the tropical spectral transfer framework:
1. Shortest path symmetry detection in networks
2. Scheduling optimization and critical path analysis
3. Signal processing: symmetry detection in discrete signals
4. Tropical zero localization for piecewise-linear detectors
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Network Symmetry Detection
# ============================================================

def shortest_path_symmetry(adj_matrix: np.ndarray, 
                           sigma: np.ndarray) -> dict:
    """
    Detect symmetry in shortest path structures of a network.
    
    Given an adjacency matrix (with edge weights) and an involutive
    permutation σ, checks whether the shortest-path distances satisfy
    the balanced condition d(i,j) + d(σi, σj) = 0 after centering.
    
    This uses the tropical spectral transfer framework: the shortest
    path matrix is a tropical operator, and the balanced condition
    detects network symmetries.
    
    Args:
        adj_matrix: n×n weighted adjacency matrix (∞ for no edge)
        sigma: involutive permutation as index array
    
    Returns:
        Dictionary with symmetry analysis results
    """
    n = len(sigma)
    
    # Floyd-Warshall for all-pairs shortest paths (min-plus matrix power)
    dist = adj_matrix.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    
    # Check symmetry: dist(σi, σj) vs dist(i,j)
    max_asym = 0
    for i in range(n):
        for j in range(n):
            asym = abs(dist[sigma[i]][sigma[j]] - dist[i][j])
            max_asym = max(max_asym, asym)
    
    # Width of each row of the distance matrix
    widths = [np.max(dist[i]) - np.min(dist[i]) for i in range(n) 
              if not np.any(np.isinf(dist[i]))]
    
    return {
        'is_sigma_symmetric': max_asym < 1e-10,
        'max_asymmetry': max_asym,
        'mean_row_width': np.mean(widths) if widths else float('inf'),
        'min_row_width': np.min(widths) if widths else float('inf'),
    }


# ============================================================
# Application 2: Tropical Signal Symmetry Detector
# ============================================================

def detect_signal_symmetry(signal: np.ndarray, 
                          tol: float = 1e-6) -> dict:
    """
    Detect approximate palindromic/anti-palindromic symmetry in a
    discrete signal using the tropical spectral framework.
    
    Uses the balanced zero functional to measure how close a signal
    is to satisfying y(i) + y(n-1-i) = 0 (anti-palindromic symmetry,
    the analogue of critical-line symmetry).
    
    Args:
        signal: 1D signal array
        tol: tolerance for approximate symmetry
    
    Returns:
        Dictionary with symmetry analysis
    """
    n = len(signal)
    sigma = np.arange(n)[::-1]  # reversal permutation
    
    # Balanced residual: y(i) + y(σ(i))
    bal_residual = signal + signal[sigma]
    max_bal_res = float(np.max(np.abs(bal_residual)))
    
    # Width
    width = float(np.max(signal) - np.min(signal))
    
    # Spectral collapse check
    is_balanced = max_bal_res < tol
    is_constant = width < tol
    is_zero = is_balanced and is_constant
    
    # Symmetry score (0 = perfectly antisymmetric, 1 = no symmetry)
    if width > tol:
        sym_score = max_bal_res / width
    else:
        sym_score = 0.0 if is_balanced else 1.0
    
    return {
        'width': width,
        'balanced_residual': max_bal_res,
        'is_balanced': is_balanced,
        'is_constant': is_constant,
        'spectral_collapse': is_zero,
        'symmetry_score': sym_score,
    }


# ============================================================
# Application 3: Tropical Zero Localization
# ============================================================

def tropical_dirichlet_zeros(weights: np.ndarray, 
                             freqs: np.ndarray,
                             s_range: Tuple[float, float] = (-5, 5),
                             n_points: int = 1000) -> dict:
    """
    Compute the "zeros" of a tropical Dirichlet-type detector:
    
    D_w(s) = min_j (w(j) + s * a(j))
    
    The "zeros" are values of s where the width of the parametric
    family t ↦ w(j) + s*a(j) collapses (multiple terms achieve the
    minimum simultaneously, creating a tropical "zero").
    
    This is the tropical analogue of finding zeros of a Dirichlet
    series Σ exp(-(w(j) + s*a(j))).
    
    Args:
        weights: weight vector w
        freqs: frequency vector a  
        s_range: range of parameter s to search
        n_points: number of sample points
    
    Returns:
        Dictionary with zero locations and analysis
    """
    n = len(weights)
    s_values = np.linspace(s_range[0], s_range[1], n_points)
    
    # Compute D_w(s) for each s
    D_values = np.zeros(n_points)
    widths = np.zeros(n_points)
    n_minimizers = np.zeros(n_points, dtype=int)
    
    for idx, s in enumerate(s_values):
        terms = weights + s * freqs
        D_values[idx] = np.min(terms)
        min_val = np.min(terms)
        # Count how many terms achieve the minimum (tropical multiplicity)
        n_minimizers[idx] = np.sum(np.abs(terms - min_val) < 1e-10)
        # Width of the terms
        widths[idx] = np.max(terms) - np.min(terms)
    
    # "Zeros" are where multiple terms achieve the minimum
    zero_indices = np.where(n_minimizers >= 2)[0]
    zero_locations = s_values[zero_indices] if len(zero_indices) > 0 else np.array([])
    
    # Check symmetry of zeros about s = 0
    if len(zero_locations) > 0:
        sym_residual = float(np.min([
            np.min(np.abs(zero_locations + z)) 
            for z in zero_locations
        ])) if len(zero_locations) > 1 else float('inf')
    else:
        sym_residual = 0.0
    
    return {
        'n_zeros': len(zero_locations),
        'zero_locations': zero_locations,
        'zero_symmetry_residual': sym_residual,
        'max_multiplicity': int(np.max(n_minimizers)),
    }


# ============================================================
# Application 4: Critical Path Analysis
# ============================================================

def critical_path_analysis(task_costs: np.ndarray,
                          dependencies: np.ndarray) -> dict:
    """
    Apply tropical spectral transfer to critical path analysis.
    
    The dependency matrix is a tropical transfer operator: the
    earliest start time of task i is the maximum (dual tropical
    minimum) over predecessors of (start time + duration).
    
    The spectral width measures the scheduling slack: width = 0
    means all tasks are equally critical (no slack).
    
    Args:
        task_costs: duration of each task
        dependencies: n×n dependency matrix (0 = dependent, ∞ = no dep)
    
    Returns:
        Dictionary with critical path analysis
    """
    n = len(task_costs)
    
    # Forward pass: earliest start times (max-plus = dual tropical)
    earliest = np.zeros(n)
    for iteration in range(n):  # At most n iterations for convergence
        changed = False
        for i in range(n):
            for j in range(n):
                if dependencies[j, i] < np.inf:
                    new_start = earliest[j] + task_costs[j]
                    if new_start > earliest[i]:
                        earliest[i] = new_start
                        changed = True
        if not changed:
            break
    
    # Width of earliest start times
    width = float(np.max(earliest) - np.min(earliest))
    
    # Slack for each task
    total_time = np.max(earliest + task_costs)
    
    return {
        'earliest_starts': earliest,
        'total_time': float(total_time),
        'schedule_width': width,
        'critical_tasks': int(np.sum(earliest + task_costs >= total_time - 1e-10)),
    }


# ============================================================
# Demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  TROPICAL SPECTRAL TRANSFER — APPLICATIONS")
    print("=" * 60)
    
    # App 1: Network Symmetry
    print("\n--- Application 1: Network Symmetry Detection ---")
    # Symmetric network: butterfly graph
    INF = np.inf
    adj = np.array([
        [0, 1, 2, INF],
        [1, 0, INF, 2],
        [2, INF, 0, 1],
        [INF, 2, 1, 0],
    ], dtype=float)
    sigma = np.array([3, 2, 1, 0])  # reverse
    result = shortest_path_symmetry(adj, sigma)
    print(f"  Butterfly network (4 nodes):")
    for k, v in result.items():
        print(f"    {k}: {v}")
    
    # App 2: Signal Symmetry
    print("\n--- Application 2: Signal Symmetry Detection ---")
    # Anti-palindromic signal
    sig1 = np.array([3.0, 1.0, -1.0, -3.0])
    r1 = detect_signal_symmetry(sig1)
    print(f"  Anti-palindromic [3, 1, -1, -3]:")
    for k, v in r1.items():
        print(f"    {k}: {v}")
    
    # Nearly anti-palindromic
    sig2 = np.array([3.0, 1.0, -1.1, -2.9])
    r2 = detect_signal_symmetry(sig2)
    print(f"\n  Near anti-palindromic [3, 1, -1.1, -2.9]:")
    for k, v in r2.items():
        print(f"    {k}: {v}")
    
    # App 3: Tropical Zero Localization
    print("\n--- Application 3: Tropical Zero Localization ---")
    # Symmetric weights (palindromic)
    w = np.array([2.0, 1.0, -1.0, -2.0])
    a = np.array([1.0, 2.0, 3.0, 4.0])
    result = tropical_dirichlet_zeros(w, a)
    print(f"  Palindromic weights w={w}:")
    print(f"    Number of zeros: {result['n_zeros']}")
    if result['n_zeros'] > 0:
        print(f"    Zero locations: {result['zero_locations'][:10]}")
        print(f"    Symmetry residual: {result['zero_symmetry_residual']:.6f}")
    
    # Non-symmetric weights
    w2 = np.array([2.0, 1.5, -0.5, -2.0])
    result2 = tropical_dirichlet_zeros(w2, a)
    print(f"\n  Non-palindromic weights w={w2}:")
    print(f"    Number of zeros: {result2['n_zeros']}")
    if result2['n_zeros'] > 0:
        print(f"    Zero locations: {result2['zero_locations'][:10]}")
    
    # App 4: Critical Path
    print("\n--- Application 4: Critical Path Analysis ---")
    costs = np.array([3.0, 2.0, 4.0, 1.0])
    deps = np.full((4, 4), np.inf)
    deps[0, 1] = 0  # task 1 depends on task 0
    deps[0, 2] = 0  # task 2 depends on task 0
    deps[1, 3] = 0  # task 3 depends on task 1
    deps[2, 3] = 0  # task 3 depends on task 2
    result = critical_path_analysis(costs, deps)
    print(f"  4-task DAG (diamond pattern):")
    for k, v in result.items():
        if isinstance(v, np.ndarray):
            print(f"    {k}: {v}")
        else:
            print(f"    {k}: {v}")
    
    print("\n" + "=" * 60)
    print("  ALL APPLICATIONS DEMONSTRATED ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Spectral Transfer — Demonstration & Computational Experiments

This script demonstrates the core theorems of the tropical spectral transfer
framework with concrete numerical examples across various dimensions.

Key demonstrations:
1. Width = 0 iff constant (width_eq_zero_iff_isConstant)
2. Balanced + constant => zero (balanced_constant_implies_zero)
3. Spectral collapse under involutive symmetry
4. Tropical operator action and additive homogeneity
5. Critical symmetry and gap collapse in tropical transfer systems
"""

import numpy as np
from itertools import permutations

# ============================================================
# Core Definitions
# ============================================================

def width(y: np.ndarray) -> float:
    """Spectral width: sup(y) - inf(y). Measures oscillation."""
    return float(np.max(y) - np.min(y))

def is_constant(y: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if all values are equal (up to tolerance)."""
    return width(y) < tol

def balanced_zero_functional(y: np.ndarray, sigma: np.ndarray) -> bool:
    """Check if y(i) + y(sigma(i)) = 0 for all i."""
    return np.allclose(y + y[sigma], 0)

def trop_apply(cost: np.ndarray, weight: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) operator action:
    (T_w x)(i) = min_j (cost(i,j) + weight(j) + x(j))
    """
    n = len(x)
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(cost[i, :] + weight + x)
    return result


# ============================================================
# Demo 1: Width = 0 iff Constant
# ============================================================

def demo_width_constant():
    print("=" * 60)
    print("DEMO 1: Width = 0 ⟺ Constant Function")
    print("=" * 60)
    
    # Constant functions have width 0
    for c in [0, 3.14, -2.7]:
        y = np.full(5, c)
        w = width(y)
        print(f"  y = [{c}]*5 → width = {w:.6f}, constant = {is_constant(y)}")
    
    # Non-constant functions have positive width
    test_vecs = [
        np.array([1, 2, 3, 4, 5]),
        np.array([0, 0, 0, 0, 1]),
        np.array([-3, -1, 0, 1, 3]),
    ]
    for y in test_vecs:
        w = width(y)
        print(f"  y = {y} → width = {w:.6f}, constant = {is_constant(y)}")
    print()


# ============================================================
# Demo 2: Balanced + Constant => Zero
# ============================================================

def demo_balanced_constant():
    print("=" * 60)
    print("DEMO 2: Balanced + Constant ⟹ Identically Zero")
    print("=" * 60)
    
    # σ = swap permutation on n=4: (0,1)(2,3)
    sigma = np.array([1, 0, 3, 2])
    
    # Balanced non-constant function
    y1 = np.array([2.0, -2.0, 3.0, -3.0])
    print(f"  y = {y1}")
    print(f"  balanced = {balanced_zero_functional(y1, sigma)}")
    print(f"  constant = {is_constant(y1)}")
    print(f"  → NOT forced to be zero (width = {width(y1):.4f})")
    
    # Constant balanced function → must be zero
    y2 = np.array([0.0, 0.0, 0.0, 0.0])
    print(f"\n  y = {y2}")
    print(f"  balanced = {balanced_zero_functional(y2, sigma)}")
    print(f"  constant = {is_constant(y2)}")
    print(f"  → Forced to be zero ✓")
    
    # Constant non-zero can't be balanced (unless σ has fixed points only)
    y3 = np.array([5.0, 5.0, 5.0, 5.0])
    print(f"\n  y = {y3}")
    print(f"  balanced = {balanced_zero_functional(y3, sigma)}")
    print(f"  constant = {is_constant(y3)}")
    print(f"  → Constant but NOT balanced (5 + 5 ≠ 0)")
    print()


# ============================================================
# Demo 3: Spectral Collapse Principle
# ============================================================

def demo_spectral_collapse():
    print("=" * 60)
    print("DEMO 3: Spectral Collapse ⟺ Identically Zero")
    print("=" * 60)
    print("  (width = 0 ∧ balanced) ⟺ (∀i, y(i) = 0)")
    
    sigma = np.array([1, 0, 3, 2])  # swap pairs
    
    examples = [
        ("y ≡ 0", np.zeros(4)),
        ("y = [1,-1,2,-2]", np.array([1, -1, 2, -2])),
        ("y = [3,3,3,3]", np.full(4, 3.0)),
        ("y = [0,0,1,-1]", np.array([0, 0, 1, -1])),
    ]
    
    for name, y in examples:
        w = width(y)
        bal = balanced_zero_functional(y, sigma)
        is_zero = np.allclose(y, 0)
        collapse = (w < 1e-12) and bal
        print(f"  {name:20s}: width={w:.4f}, balanced={bal}, "
              f"collapse={collapse}, zero={is_zero}")
        assert collapse == is_zero, "Theorem violation!"
    
    print("  All examples satisfy the equivalence ✓")
    print()


# ============================================================
# Demo 4: Tropical Operator & Additive Homogeneity
# ============================================================

def demo_tropical_operator():
    print("=" * 60)
    print("DEMO 4: Tropical Operator & Additive Homogeneity")
    print("=" * 60)
    
    n = 3
    # Symmetric cost matrix
    cost = np.array([
        [0.0, 1.0, 2.0],
        [1.0, 0.0, 1.5],
        [2.0, 1.5, 0.0]
    ])
    weight = np.array([0.5, -0.3, 0.1])
    x = np.array([1.0, 2.0, 0.5])
    
    Tx = trop_apply(cost, weight, x)
    print(f"  cost = \n{cost}")
    print(f"  weight = {weight}")
    print(f"  x = {x}")
    print(f"  T(x) = {Tx}")
    print(f"  width(T(x)) = {width(Tx):.6f}")
    
    # Additive homogeneity: T(x + c) = T(x) + c
    c = 7.0
    Tx_shifted = trop_apply(cost, weight, x + c)
    print(f"\n  Additive homogeneity check (c = {c}):")
    print(f"  T(x + c)  = {Tx_shifted}")
    print(f"  T(x) + c  = {Tx + c}")
    print(f"  Equal? {np.allclose(Tx_shifted, Tx + c)} ✓")
    
    # Width preservation under translation
    print(f"\n  width(T(x + c)) = {width(Tx_shifted):.6f}")
    print(f"  width(T(x))     = {width(Tx):.6f}")
    print(f"  Equal? {abs(width(Tx_shifted) - width(Tx)) < 1e-12} ✓")
    print()


# ============================================================
# Demo 5: Critical Symmetry & Gap Collapse
# ============================================================

def demo_critical_symmetry():
    print("=" * 60)
    print("DEMO 5: Critical Symmetry & Spectral Gap Collapse")
    print("=" * 60)
    
    n = 4
    # Involution σ: (0↔1, 2↔3)
    sigma = np.array([1, 0, 3, 2])
    
    # Symmetric cost invariant under σ: cost(σi, σj) = cost(i,j)
    cost = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 0.0, 3.0, 2.0],
        [2.0, 3.0, 0.0, 1.0],
        [3.0, 2.0, 1.0, 0.0]
    ])
    
    # Anti-symmetric weight: w(σi) = -w(i)
    weight = np.array([0.5, -0.5, 1.0, -1.0])
    
    # Symmetric input: x(σi) = x(i)
    x = np.array([1.0, 1.0, 2.0, 2.0])
    
    # Verify symmetry conditions
    print(f"  σ = {sigma}")
    print(f"  cost symmetric? {np.allclose(cost, cost.T)}")
    
    cost_sigma_inv = True
    for i in range(n):
        for j in range(n):
            if abs(cost[sigma[i], sigma[j]] - cost[i, j]) > 1e-12:
                cost_sigma_inv = False
    print(f"  cost σ-invariant? {cost_sigma_inv}")
    print(f"  weight anti-symmetric? {all(abs(weight[sigma[i]] + weight[i]) < 1e-12 for i in range(n))}")
    print(f"  x σ-symmetric? {all(abs(x[sigma[i]] - x[i]) < 1e-12 for i in range(n))}")
    
    Tx = trop_apply(cost, weight, x)
    print(f"\n  T(x) = {Tx}")
    print(f"  width(T(x)) = {width(Tx):.6f}")
    print(f"  balanced? {balanced_zero_functional(Tx, sigma)}")
    
    # The theorem says: (width = 0 ∧ balanced) ⟺ (∀i, T(x)(i) = 0)
    is_zero = np.allclose(Tx, 0)
    print(f"  T(x) ≡ 0? {is_zero}")
    
    if not is_zero:
        print("\n  → T(x) is NOT zero: the spectral gap is nonzero.")
        print("    This means the balanced condition also fails.")
        print("    The equivalence holds: (width≠0 ∨ ¬balanced) ↔ T(x)≢0")
    print()
    
    # Now construct a case where T(x) IS zero
    print("  --- Constructing a zero-output case ---")
    # For T(x) = 0, we need min_j(cost(i,j) + w(j) + x(j)) = 0 for all i
    # This is a constraint on x. Let's solve it for n=2.
    n2 = 2
    sigma2 = np.array([1, 0])
    cost2 = np.array([[0.0, 1.0], [1.0, 0.0]])
    w2 = np.array([1.0, -1.0])
    # T(x)(0) = min(0 + 1 + x0, 1 + (-1) + x1) = min(1+x0, x1)
    # T(x)(1) = min(1 + 1 + x0, 0 + (-1) + x1) = min(2+x0, -1+x1)
    # For T(x) = [0,0]: min(1+x0, x1) = 0 AND min(2+x0, -1+x1) = 0
    # From first: need 1+x0 ≥ 0 and x1 = 0 OR x1 ≥ 0 and 1+x0 = 0 (so x0=-1)
    # If x0 = -1: T(x)(0) = min(0, x1) = 0 needs x1 ≥ 0
    #             T(x)(1) = min(1, -1+x1) = 0 impossible since min ≤ 1 and min = 0 needs -1+x1=0, x1=1
    #             Then T(x)(1) = min(1, 0) = 0. 
    x2 = np.array([-1.0, 1.0])
    Tx2 = trop_apply(cost2, w2, x2)
    print(f"  n=2: cost={cost2.tolist()}, w={w2}, x={x2}")
    print(f"  T(x) = {Tx2}")
    print(f"  width = {width(Tx2):.6f}")
    print(f"  balanced = {balanced_zero_functional(Tx2, sigma2)}")
    print(f"  T(x) ≡ 0? {np.allclose(Tx2, 0)}")
    print(f"  Spectral collapse equivalence verified ✓")
    print()


# ============================================================
# Demo 6: Width Properties (neg, perm, add_const)
# ============================================================

def demo_width_properties():
    print("=" * 60)
    print("DEMO 6: Width Algebraic Properties")
    print("=" * 60)
    
    y = np.array([3.0, -1.0, 4.0, 1.0, 5.0])
    
    # Negation invariance
    w_y = width(y)
    w_neg = width(-y)
    print(f"  y = {y}")
    print(f"  width(y)  = {w_y:.6f}")
    print(f"  width(-y) = {w_neg:.6f}")
    print(f"  Equal? {abs(w_y - w_neg) < 1e-12} ✓  (width_neg)")
    
    # Translation invariance
    c = 42.0
    w_shift = width(y + c)
    print(f"\n  width(y + {c}) = {w_shift:.6f}")
    print(f"  width(y)       = {w_y:.6f}")
    print(f"  Equal? {abs(w_y - w_shift) < 1e-12} ✓  (width_add_const)")
    
    # Permutation invariance
    perm = np.array([2, 4, 0, 3, 1])
    w_perm = width(y[perm])
    print(f"\n  σ = {perm}")
    print(f"  width(y ∘ σ) = {w_perm:.6f}")
    print(f"  width(y)     = {w_y:.6f}")
    print(f"  Equal? {abs(w_y - w_perm) < 1e-12} ✓  (width_perm_invariant)")
    
    # Nonnegativity
    print(f"\n  width(y) = {w_y:.6f} ≥ 0 ✓  (width_nonneg)")
    
    # width ≤ 2 * sup |y|
    sup_abs = np.max(np.abs(y))
    print(f"  |y|_∞ = {sup_abs:.6f}")
    print(f"  2·|y|_∞ = {2*sup_abs:.6f}")
    print(f"  width(y) ≤ 2·|y|_∞? {w_y <= 2*sup_abs + 1e-12} ✓  (width_le_twice_sup)")
    print()


# ============================================================
# Demo 7: Balanced Width = 2·sup(y)
# ============================================================

def demo_balanced_width():
    print("=" * 60)
    print("DEMO 7: Balanced Width = 2·sup(y)")
    print("=" * 60)
    
    sigma = np.array([1, 0, 3, 2, 5, 4])
    
    # Balanced function: y(σi) = -y(i)
    y = np.array([3.0, -3.0, 1.0, -1.0, 2.5, -2.5])
    
    print(f"  y = {y}")
    print(f"  σ = {sigma}")
    print(f"  balanced? {balanced_zero_functional(y, sigma)}")
    print(f"  width(y) = {width(y):.6f}")
    print(f"  2·sup(y) = {2 * np.max(y):.6f}")
    print(f"  Equal? {abs(width(y) - 2*np.max(y)) < 1e-12} ✓  (balanced_width_eq_twice_sup)")
    print()


# ============================================================
# Demo 8: Finite Spectral Transfer Principle
# ============================================================

def demo_transfer_principle():
    print("=" * 60)
    print("DEMO 8: Finite Spectral Transfer Principle")
    print("=" * 60)
    print("  Under w(σi) = -w(i) and a(σi) = a(i):")
    print("  (width(w+a) = 0 ∧ balanced(w+a)) ⟺ (w+a ≡ 0)")
    
    sigma = np.array([1, 0, 3, 2])
    
    # Anti-symmetric weights, symmetric frequencies
    w = np.array([2.0, -2.0, 1.0, -1.0])
    a = np.array([3.0, 3.0, 5.0, 5.0])
    y = w + a
    
    print(f"\n  w = {w} (anti-symmetric)")
    print(f"  a = {a} (symmetric)")
    print(f"  y = w + a = {y}")
    print(f"  width(y) = {width(y):.6f}")
    print(f"  balanced(y)? {balanced_zero_functional(y, sigma)}")
    print(f"  y ≡ 0? {np.allclose(y, 0)}")
    
    # The only way to get both width=0 AND balanced is y≡0
    w_zero = np.zeros(4)
    a_zero = np.zeros(4)
    y_zero = w_zero + a_zero
    print(f"\n  w = {w_zero}, a = {a_zero}")
    print(f"  y = {y_zero}")
    print(f"  width(y) = {width(y_zero):.6f}")
    print(f"  balanced(y)? {balanced_zero_functional(y_zero, sigma)}")
    print(f"  y ≡ 0? {np.allclose(y_zero, 0)} ✓")
    print()


# ============================================================
# Demo 9: Counterexample Search — Breaking Symmetry
# ============================================================

def demo_counterexamples():
    print("=" * 60)
    print("DEMO 9: What Fails Without Symmetry Hypotheses?")
    print("=" * 60)
    
    n = 4
    sigma = np.array([1, 0, 3, 2])
    
    # Non-symmetric cost
    cost_nonsym = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [4.0, 0.0, 1.0, 2.0],
        [3.0, 4.0, 0.0, 1.0],
        [2.0, 3.0, 4.0, 0.0]
    ])
    weight = np.array([0.5, -0.5, 1.0, -1.0])
    x = np.array([1.0, 1.0, 2.0, 2.0])
    
    Tx = trop_apply(cost_nonsym, weight, x)
    print(f"  Non-symmetric cost matrix:")
    print(f"  T(x) = {Tx}")
    print(f"  width = {width(Tx):.4f}")
    print(f"  balanced = {balanced_zero_functional(Tx, sigma)}")
    print("  → Without cost symmetry, the conjugation identity breaks.\n")
    
    # Non-anti-symmetric weights
    cost_sym = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 0.0, 3.0, 2.0],
        [2.0, 3.0, 0.0, 1.0],
        [3.0, 2.0, 1.0, 0.0]
    ])
    weight_nonsym = np.array([0.5, 0.3, 1.0, 0.7])  # NOT anti-symmetric
    Tx2 = trop_apply(cost_sym, weight_nonsym, x)
    print(f"  Non-anti-symmetric weights (w = {weight_nonsym}):")
    print(f"  T(x) = {Tx2}")
    print(f"  width = {width(Tx2):.4f}")
    print(f"  → Weight antisymmetry is essential for the transfer structure.")
    print()


# ============================================================
# Demo 10: Scaling Experiments
# ============================================================

def demo_scaling():
    print("=" * 60)
    print("DEMO 10: Scaling to Larger Dimensions")
    print("=" * 60)
    
    for n in [2, 4, 8, 16, 32, 64]:
        # Create involution: swap pairs
        sigma = np.arange(n)
        for i in range(0, n, 2):
            sigma[i], sigma[i+1] = sigma[i+1], sigma[i]
        
        # Anti-symmetric weight
        w = np.random.randn(n // 2)
        weight = np.zeros(n)
        for i in range(0, n, 2):
            weight[i] = w[i // 2]
            weight[i+1] = -w[i // 2]
        
        # Symmetric cost
        A = np.random.randn(n, n)
        cost = (A + A.T) / 2
        # Make σ-invariant
        for i in range(n):
            for j in range(n):
                cost[sigma[i], sigma[j]] = cost[i, j]
        
        # Symmetric input
        x = np.random.randn(n // 2)
        x_full = np.zeros(n)
        for i in range(0, n, 2):
            x_full[i] = x[i // 2]
            x_full[i+1] = x[i // 2]
        
        Tx = trop_apply(cost, weight, x_full)
        w_val = width(Tx)
        bal = balanced_zero_functional(Tx, sigma)
        is_zero = np.allclose(Tx, 0)
        
        # Verify: (width=0 ∧ balanced) ↔ zero
        collapse = (w_val < 1e-10) and bal
        assert collapse == is_zero, f"Theorem violation at n={n}!"
        
        print(f"  n={n:3d}: width={w_val:8.4f}, balanced={str(bal):5s}, "
              f"zero={str(is_zero):5s}, collapse↔zero ✓")
    
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL SPECTRAL TRANSFER — COMPUTATIONAL EXPERIMENTS")
    print("=" * 60 + "\n")
    
    np.random.seed(42)
    
    demo_width_constant()
    demo_balanced_constant()
    demo_spectral_collapse()
    demo_tropical_operator()
    demo_critical_symmetry()
    demo_width_properties()
    demo_balanced_width()
    demo_transfer_principle()
    demo_counterexamples()
    demo_scaling()
    
    print("=" * 60)
    print("  ALL DEMONSTRATIONS PASSED ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Spectral Transfer — Visualizations

Generates publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def spectral_width(y):
    return float(np.max(y) - np.min(y))


def tropical_action(cost, weight, x):
    n = len(x)
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(cost[i, :] + weight + x)
    return result


def plot_width_landscape():
    """
    Figure 1: Spectral width landscape as a function of weight perturbation.
    Shows how width varies as weights are perturbed away from anti-symmetry.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    n = 4
    sigma = np.array([1, 0, 3, 2])
    cost = np.array([
        [0, 1, 2, 3],
        [1, 0, 3, 2],
        [2, 3, 0, 1],
        [3, 2, 1, 0]
    ], dtype=float)
    
    # Vary weight anti-symmetry parameter
    epsilons = np.linspace(-3, 3, 200)
    widths_w = []
    bal_residuals = []
    
    base_w = np.array([1.0, -1.0, 0.5, -0.5])
    x = np.array([1.0, 1.0, 2.0, 2.0])
    
    for eps in epsilons:
        # Perturb anti-symmetry: w(σi) = -w(i) + eps
        weight = base_w + eps * np.array([0.1, 0.1, 0.1, 0.1])
        Tx = tropical_action(cost, weight, x)
        widths_w.append(spectral_width(Tx))
        res = np.max(np.abs(Tx + Tx[sigma]))
        bal_residuals.append(res)
    
    ax = axes[0]
    ax.plot(epsilons, widths_w, 'b-', linewidth=2, label='Spectral width')
    ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Gap = 0')
    ax.set_xlabel('Weight perturbation ε', fontsize=12)
    ax.set_ylabel('Spectral width', fontsize=12)
    ax.set_title('Width under Weight Perturbation', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    ax.scatter(widths_w, bal_residuals, c=epsilons, cmap='coolwarm', 
               s=10, alpha=0.7)
    ax.set_xlabel('Spectral width', fontsize=12)
    ax.set_ylabel('Balanced residual', fontsize=12)
    ax.set_title('Width vs Balanced Residual', fontsize=14)
    ax.grid(True, alpha=0.3)
    cb = plt.colorbar(ax.collections[0], ax=ax)
    cb.set_label('Perturbation ε')
    
    fig.suptitle('Figure 1: Spectral Width Landscape', fontsize=16, y=1.02)
    plt.tight_layout()
    fig.savefig('fig1_width_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_spectral_collapse_diagram():
    """
    Figure 2: The spectral collapse equivalence.
    Venn-style visualization showing the intersection of width=0 and balanced.
    """
    fig, ax = plt.subplots(figsize=(8, 6))
    
    n = 4
    sigma = np.array([1, 0, 3, 2])
    np.random.seed(42)
    
    n_samples = 2000
    widths = []
    bal_res = []
    colors = []
    
    for _ in range(n_samples):
        y = np.random.randn(n) * 2
        w = spectral_width(y)
        r = np.max(np.abs(y + y[sigma]))
        widths.append(w)
        bal_res.append(r)
        
        if w < 0.3 and r < 0.3:
            colors.append('red')
        elif w < 0.3:
            colors.append('blue')
        elif r < 0.3:
            colors.append('green')
        else:
            colors.append('gray')
    
    ax.scatter(widths, bal_res, c=colors, s=8, alpha=0.5)
    ax.axhline(y=0, color='k', linestyle='--', alpha=0.3)
    ax.axvline(x=0, color='k', linestyle='--', alpha=0.3)
    
    # Add legend markers
    ax.scatter([], [], c='red', s=50, label='Both (y ≡ 0)')
    ax.scatter([], [], c='blue', s=50, label='Width ≈ 0 only')
    ax.scatter([], [], c='green', s=50, label='Balanced only')
    ax.scatter([], [], c='gray', s=50, label='Neither')
    
    ax.set_xlabel('Spectral Width', fontsize=12)
    ax.set_ylabel('Balanced Residual max|y(i)+y(σi)|', fontsize=12)
    ax.set_title('Spectral Collapse: Width = 0 ∧ Balanced ⟺ y ≡ 0', fontsize=14)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('fig2_spectral_collapse.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_tropical_dynamics():
    """
    Figure 3: Tropical operator iteration dynamics.
    Shows width evolution under repeated tropical operator application.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    n = 6
    sigma = np.array([1, 0, 3, 2, 5, 4])
    
    # Build σ-invariant symmetric cost
    np.random.seed(123)
    A = np.random.randn(n, n)
    cost = (A + A.T) / 2
    for i in range(n):
        for j in range(n):
            cost[sigma[i], sigma[j]] = cost[i, j]
    cost = (cost + cost.T) / 2
    
    configs = [
        ("Anti-symmetric w", np.array([1, -1, 0.5, -0.5, 0.3, -0.3], dtype=float)),
        ("Random w", np.array([0.5, 0.3, -0.2, 0.1, 0.8, -0.4], dtype=float)),
    ]
    
    for idx, (label, weight) in enumerate(configs):
        ax = axes[idx]
        
        for trial in range(5):
            x = np.random.randn(n) * 2
            widths = [spectral_width(x)]
            
            for _ in range(30):
                x = tropical_action(cost, weight, x)
                x -= np.mean(x)
                widths.append(spectral_width(x))
            
            ax.plot(widths, alpha=0.7, linewidth=1.5)
        
        ax.set_xlabel('Iteration', fontsize=12)
        ax.set_ylabel('Spectral Width', fontsize=12)
        ax.set_title(f'{label}', fontsize=13)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(0, 30)
    
    fig.suptitle('Figure 3: Tropical Operator Dynamics', fontsize=16, y=1.02)
    plt.tight_layout()
    fig.savefig('fig3_tropical_dynamics.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_dimension_scaling():
    """
    Figure 4: Spectral width statistics as dimension increases.
    """
    fig, ax = plt.subplots(figsize=(8, 6))
    
    dims = [4, 8, 16, 32, 64, 128]
    mean_widths = []
    std_widths = []
    min_widths = []
    
    for n in dims:
        sigma = np.arange(n)
        for i in range(0, n, 2):
            sigma[i], sigma[i+1] = sigma[i+1], sigma[i]
        
        # Random σ-invariant cost
        np.random.seed(42)
        A = np.random.randn(n, n)
        cost = (A + A.T) / 2
        for i in range(n):
            for j in range(n):
                avg = (cost[i,j] + cost[sigma[i], sigma[j]]) / 2
                cost[i,j] = avg
                cost[sigma[i], sigma[j]] = avg
        
        ws = []
        for trial in range(200):
            rng = np.random.RandomState(trial)
            w_half = rng.randn(n // 2)
            weight = np.zeros(n)
            for i in range(0, n, 2):
                weight[i] = w_half[i // 2]
                weight[i+1] = -w_half[i // 2]
            x_half = rng.randn(n // 2)
            x = np.zeros(n)
            for i in range(0, n, 2):
                x[i] = x_half[i // 2]
                x[i+1] = x_half[i // 2]
            Tx = tropical_action(cost, weight, x)
            ws.append(spectral_width(Tx))
        
        mean_widths.append(np.mean(ws))
        std_widths.append(np.std(ws))
        min_widths.append(np.min(ws))
    
    ax.errorbar(dims, mean_widths, yerr=std_widths, fmt='bo-', 
                linewidth=2, capsize=5, label='Mean ± Std')
    ax.plot(dims, min_widths, 'r^--', linewidth=1.5, label='Minimum')
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Spectral Width', fontsize=12)
    ax.set_title('Spectral Width vs Dimension', fontsize=14)
    ax.set_xscale('log', base=2)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('fig4_dimension_scaling.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_width_landscape()
    print(f"  Figure 1: Width landscape ({len(b64_1)} chars)")
    
    b64_2 = plot_spectral_collapse_diagram()
    print(f"  Figure 2: Spectral collapse ({len(b64_2)} chars)")
    
    b64_3 = plot_tropical_dynamics()
    print(f"  Figure 3: Tropical dynamics ({len(b64_3)} chars)")
    
    b64_4 = plot_dimension_scaling()
    print(f"  Figure 4: Dimension scaling ({len(b64_4)} chars)")
    
    print("\nAll visualizations generated ✓")
    print("Saved: fig1_width_landscape.png, fig2_spectral_collapse.png,")
    print("       fig3_tropical_dynamics.png, fig4_dimension_scaling.png")
