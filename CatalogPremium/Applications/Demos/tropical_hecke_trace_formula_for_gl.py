#!/usr/bin/env python3
"""
Tropical Trace Formula for 2×2 Matrices — Interactive Demo

Demonstrates the formally verified tropical trace formula:
    maxCycleMean(M) = tr⊕(M²) / 2

This is the 2×2 specialization of the Cycle-Time Theorem from max-plus algebra,
which we prove in Lean 4 as the tropical analogue of the Arthur–Selberg trace formula.

Usage:
    python tropical_trace_demo.py
"""

import numpy as np
from fractions import Fraction

# ─────────────────────────────────────────────────────────
# Max-Plus Algebra Engine
# ─────────────────────────────────────────────────────────

def trop_mat_mul(M, N):
    """Tropical matrix multiplication for 2×2 matrices."""
    n = 2
    result = [[None]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            result[i][j] = max(M[i][k] + N[k][j] for k in range(n))
    return result

def trop_trace(M):
    """Tropical trace: max of diagonal entries."""
    return max(M[i][i] for i in range(len(M)))

def trop_det(M):
    """Tropical determinant: max-weight perfect matching (2×2 assignment problem)."""
    return max(M[0][0] + M[1][1], M[0][1] + M[1][0])

def max_cycle_mean(M):
    """Maximum cycle mean for a 2×2 weighted digraph.

    Cycles:
    - Length 1: loops at vertex 1 (weight a₁₁) and vertex 2 (weight a₂₂)
    - Length 2: cycle 1→2→1 with mean (a₁₂ + a₂₁) / 2
    """
    return max(M[0][0], M[1][1], (M[0][1] + M[1][0]) / 2)

def trop_eigenvalue_witness(M):
    """Find a tropical eigenvector for the max cycle mean.

    Returns (eigenvalue, x1, x2) such that:
        max(a₁₁ + x₁, a₁₂ + x₂) = λ + x₁
        max(a₂₁ + x₁, a₂₂ + x₂) = λ + x₂
    """
    a, b, c, d = M[0][0], M[0][1], M[1][0], M[1][1]
    ev = max_cycle_mean(M)

    if ev == a and a >= d and a >= (b + c) / 2:
        return ev, 0, c - a
    elif ev == d and d >= a and d >= (b + c) / 2:
        return ev, b - d, 0
    else:  # ev = (b + c) / 2
        return ev, 0, (c - b) / 2

def verify_eigenvalue(M, ev, x1, x2, tol=1e-12):
    """Verify the tropical eigenvalue equation."""
    a, b, c, d = M[0][0], M[0][1], M[1][0], M[1][1]
    eq1_lhs = max(a + x1, b + x2)
    eq1_rhs = ev + x1
    eq2_lhs = max(c + x1, d + x2)
    eq2_rhs = ev + x2
    return abs(eq1_lhs - eq1_rhs) < tol and abs(eq2_lhs - eq2_rhs) < tol

# ─────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────

def demo_trace_formula():
    """Demonstrate the tropical trace formula on several examples."""
    print("=" * 70)
    print("  TROPICAL TRACE FORMULA FOR 2×2 MATRICES")
    print("  maxCycleMean(M) = tr⊕(M²) / 2")
    print("=" * 70)

    examples = [
        ("Diagonal-dominant", [[3, 1], [2, 4]]),
        ("Off-diagonal dominant", [[0, 5], [5, 0]]),
        ("Symmetric", [[2, 3], [3, 2]]),
        ("Asymmetric", [[1, 7], [2, 3]]),
        ("Identity-like", [[0, -10], [-10, 0]]),
        ("Large off-diagonal", [[-5, 100], [100, -5]]),
    ]

    for name, M in examples:
        M2 = trop_mat_mul(M, M)
        mcm = max_cycle_mean(M)
        tr_M2_half = trop_trace(M2) / 2
        td = trop_det(M)
        tr_M = trop_trace(M)

        ev, x1, x2 = trop_eigenvalue_witness(M)
        is_valid = verify_eigenvalue(M, ev, x1, x2)

        print(f"\n{'─' * 50}")
        print(f"  {name}: M = {M}")
        print(f"  Tropical trace:     tr⊕(M) = max({M[0][0]}, {M[1][1]}) = {tr_M}")
        print(f"  Tropical det:       tdet(M) = max({M[0][0]}+{M[1][1]}, {M[0][1]}+{M[1][0]}) = {td}")
        print(f"  M² (tropical) = {M2}")
        print(f"  tr⊕(M²) = {trop_trace(M2)}")
        print(f"  tr⊕(M²) / 2 = {tr_M2_half}")
        print(f"  maxCycleMean(M) = max({M[0][0]}, {M[1][1]}, ({M[0][1]}+{M[1][0]})/2) = {mcm}")
        print(f"  ✅ TRACE FORMULA: {mcm} = {tr_M2_half}  {'✓' if abs(mcm - tr_M2_half) < 1e-12 else '✗'}")
        print(f"  Tropical eigenvalue: λ = {ev}, eigenvector: ({x1}, {x2}), valid: {'✓' if is_valid else '✗'}")

    print(f"\n{'=' * 70}")


def demo_assignment_problem():
    """Show the connection between tropical determinant and the assignment problem."""
    print("\n" + "=" * 70)
    print("  TROPICAL DETERMINANT = ASSIGNMENT PROBLEM")
    print("=" * 70)

    costs = [[8, 5], [3, 7]]
    print(f"\n  Job assignment profit matrix:")
    print(f"    Worker 1: Job A={costs[0][0]}, Job B={costs[0][1]}")
    print(f"    Worker 2: Job A={costs[1][0]}, Job B={costs[1][1]}")

    id_match = costs[0][0] + costs[1][1]
    swap_match = costs[0][1] + costs[1][0]

    print(f"\n  Assignment 1 (W1→A, W2→B): profit = {costs[0][0]} + {costs[1][1]} = {id_match}")
    print(f"  Assignment 2 (W1→B, W2→A): profit = {costs[0][1]} + {costs[1][0]} = {swap_match}")
    print(f"\n  Tropical determinant = max({id_match}, {swap_match}) = {trop_det(costs)}")
    print(f"  Optimal assignment profit = {max(id_match, swap_match)}")
    print(f"  ✅ tdet = optimal assignment: {'✓' if trop_det(costs) == max(id_match, swap_match) else '✗'}")


def demo_spectral_geometric():
    """Demonstrate the spectral = geometric equivalence."""
    print("\n" + "=" * 70)
    print("  SPECTRAL-GEOMETRIC EQUIVALENCE")
    print("  max(tr⊕(M)/1, tr⊕(M²)/2) = maxCycleMean(M)")
    print("=" * 70)

    M = [[1, 6], [4, 2]]
    M2 = trop_mat_mul(M, M)

    spectral_k1 = trop_trace(M) / 1
    spectral_k2 = trop_trace(M2) / 2

    geometric = max_cycle_mean(M)
    spectral = max(spectral_k1, spectral_k2)

    print(f"\n  M = {M}")
    print(f"\n  SPECTRAL SIDE (tropical power traces):")
    print(f"    k=1: tr⊕(M^1)/1 = {trop_trace(M)}/1 = {spectral_k1}")
    print(f"    k=2: tr⊕(M^2)/2 = {trop_trace(M2)}/2 = {spectral_k2}")
    print(f"    Spectral max = max({spectral_k1}, {spectral_k2}) = {spectral}")

    print(f"\n  GEOMETRIC SIDE (cycle means):")
    print(f"    1-cycle at vertex 1: mean = {M[0][0]}")
    print(f"    1-cycle at vertex 2: mean = {M[1][1]}")
    print(f"    2-cycle (1→2→1):     mean = ({M[0][1]}+{M[1][0]})/2 = {(M[0][1]+M[1][0])/2}")
    print(f"    Geometric max = {geometric}")

    print(f"\n  ✅ SPECTRAL = GEOMETRIC: {spectral} = {geometric}  "
          f"{'✓' if abs(spectral - geometric) < 1e-12 else '✗'}")


def demo_random_verification():
    """Verify the trace formula on many random matrices."""
    print("\n" + "=" * 70)
    print("  RANDOM VERIFICATION (1000 matrices)")
    print("=" * 70)

    np.random.seed(42)
    n_tests = 1000
    n_pass = 0

    for _ in range(n_tests):
        entries = np.random.uniform(-10, 10, 4)
        M = [[entries[0], entries[1]], [entries[2], entries[3]]]
        M2 = trop_mat_mul(M, M)

        mcm = max_cycle_mean(M)
        tr_formula = trop_trace(M2) / 2

        if abs(mcm - tr_formula) < 1e-10:
            n_pass += 1

        ev, x1, x2 = trop_eigenvalue_witness(M)
        assert verify_eigenvalue(M, ev, x1, x2), f"Eigenvalue verification failed for {M}"

    print(f"\n  Trace formula verified: {n_pass}/{n_tests} ({'✓ ALL PASS' if n_pass == n_tests else '✗ FAILURES'})")
    print(f"  Eigenvalue existence verified: {n_tests}/{n_tests} ✓")


def demo_bruhat_tits_analogy():
    """Explain the analogy to the Bruhat-Tits tree and p-adic groups."""
    print("\n" + "=" * 70)
    print("  ANALOGY: TROPICAL GRAPHS ↔ BRUHAT-TITS TREE")
    print("=" * 70)
    print("""
  In the theory of p-adic groups (like GL₂(ℚₚ)), the Bruhat-Tits tree
  is a fundamental combinatorial object encoding the structure of the group.

  Our tropical trace formula provides a precise analogy:

  ┌───────────────────────────┬────────────────────────────────┐
  │  CLASSICAL (p-adic)       │  TROPICAL (max-plus)           │
  ├───────────────────────────┼────────────────────────────────┤
  │  GL₂(ℚₚ)                 │  2×2 max-plus matrices         │
  │  Bruhat-Tits tree         │  Weighted directed graph       │
  │  Conjugacy classes        │  Directed cycles               │
  │  Orbital integrals        │  Cycle means                   │
  │  Hecke operators          │  Tropical matrix powers        │
  │  Spectral decomposition   │  Tropical eigenvalues          │
  │  Arthur-Selberg trace     │  Tropical trace formula        │
  │  formula                  │  (Cycle-Time Theorem)          │
  │  Satake isomorphism       │  Max-plus spectral theory      │
  └───────────────────────────┴────────────────────────────────┘

  The key identity in both settings:

    GEOMETRIC SIDE = SPECTRAL SIDE

  Classical:  Σ_γ O_γ(f) = Σ_π tr π(f) · μ(π)
  Tropical:   max_γ (cycle mean of γ) = tr⊕(M²) / 2
  """)


if __name__ == "__main__":
    demo_trace_formula()
    demo_assignment_problem()
    demo_spectral_geometric()
    demo_random_verification()
    demo_bruhat_tits_analogy()

    print("\n" + "=" * 70)
    print("  All demonstrations complete.")
    print("  The tropical trace formula is verified both formally (Lean 4)")
    print("  and computationally (Python) across 1000+ random examples.")
    print("=" * 70)
