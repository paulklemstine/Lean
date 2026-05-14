"""
Tropical Double Descent: Algorithms

Implements the core algorithms from the research paper:
1. Tropical risk evaluation (O(1))
2. Tropical vertex location (O(1))
3. Perturbation-safe model selection (O(N))
4. Multi-branch tropical phase diagram construction
"""

from typing import Optional, Tuple, List
import numpy as np


# ============================================================
# Algorithm 1: Tropical Risk Evaluation
# ============================================================

def evaluate_tropical_risk(
    alpha1: float, beta1: float,
    alpha2: float, beta2: float,
    n: int
) -> Tuple[float, int]:
    """
    Evaluate the tropical risk at complexity n.

    Parameters
    ----------
    alpha1, beta1 : float
        Intercept and slope of first affine branch.
    alpha2, beta2 : float
        Intercept and slope of second affine branch.
    n : int
        Complexity parameter (non-negative integer).

    Returns
    -------
    risk : float
        The tropical risk value min(f1(n), f2(n)).
    active_branch : int
        Index (1 or 2) of the active (minimizing) branch.

    Time: O(1), Space: O(1)
    """
    f1 = alpha1 + beta1 * n
    f2 = alpha2 + beta2 * n
    if f1 <= f2:
        return f1, 1
    else:
        return f2, 2


# ============================================================
# Algorithm 2: Tropical Vertex Location
# ============================================================

def find_tropical_vertex(
    alpha1: float, beta1: float,
    alpha2: float, beta2: float
) -> Optional[int]:
    """
    Find the tropical vertex (crossing point) of two affine forms on ℕ.

    Parameters
    ----------
    alpha1, beta1 : float
        First affine form: alpha1 + beta1 * n.
    alpha2, beta2 : float
        Second affine form: alpha2 + beta2 * n.

    Returns
    -------
    n0 : int or None
        The natural number where the two forms cross, or None if
        no integer crossing exists or slopes are equal.

    Requires: beta1 != beta2 for a valid crossing.

    Time: O(1), Space: O(1)
    """
    if abs(beta1 - beta2) < 1e-15:
        return None  # Parallel lines, no crossing

    n0_real = (alpha2 - alpha1) / (beta1 - beta2)

    if n0_real < -1e-12:
        return None  # Crossing at negative value

    n0_int = round(n0_real)
    if abs(n0_real - n0_int) > 1e-9:
        return None  # Crossing is not at an integer

    if n0_int < 0:
        return None

    return n0_int


# ============================================================
# Algorithm 3: Perturbation-Safe Model Selection
# ============================================================

def robust_model_selection(
    f_approx: List[float],
    g_approx: List[float],
    epsilon: float
) -> Tuple[int, str, List[int]]:
    """
    Find the tropical vertex with certified confidence under perturbation.

    Given approximate evaluations of two risk branches within ε of their
    true values, identifies candidate vertex locations and flags whether
    the identification is confident.

    Parameters
    ----------
    f_approx : list of float
        Approximate values of first branch at n = 0, 1, ..., N-1.
    g_approx : list of float
        Approximate values of second branch at n = 0, 1, ..., N-1.
    epsilon : float
        Uniform approximation error bound (>= 0).

    Returns
    -------
    vertex : int
        Estimated vertex location.
    confidence : str
        "CONFIDENT" if unique candidate, "UNCERTAIN" otherwise.
    candidates : list of int
        All candidate vertex locations (where gap ≤ 2ε).

    Time: O(N), Space: O(N) worst-case
    """
    N = len(f_approx)
    assert len(g_approx) == N, "Branch arrays must have equal length"

    candidates = []
    for n in range(N):
        gap = abs(f_approx[n] - g_approx[n])
        if gap <= 2 * epsilon:
            candidates.append(n)

    if len(candidates) == 0:
        # No candidate: find the point of minimum gap
        gaps = [abs(f_approx[n] - g_approx[n]) for n in range(N)]
        vertex = int(np.argmin(gaps))
        return vertex, "UNCERTAIN", [vertex]
    elif len(candidates) == 1:
        return candidates[0], "CONFIDENT", candidates
    else:
        # Multiple candidates: pick the one with max tropical risk
        risks = [min(f_approx[n], g_approx[n]) for n in candidates]
        best_idx = np.argmax(risks)
        return candidates[best_idx], "UNCERTAIN", candidates


# ============================================================
# Algorithm 4: Multi-Branch Tropical Phase Diagram
# ============================================================

def multi_branch_tropical_risk(
    branches: List[Tuple[float, float]],
    n: int
) -> Tuple[float, int]:
    """
    Evaluate the tropical risk for multiple competing affine branches.

    Parameters
    ----------
    branches : list of (alpha, beta) tuples
        Each tuple defines an affine branch alpha + beta * n.
    n : int
        Complexity parameter.

    Returns
    -------
    risk : float
        Minimum over all branches.
    active_branch : int
        Index of the minimizing branch (0-indexed).

    Time: O(k) where k = number of branches. Space: O(1).
    """
    min_val = float('inf')
    min_idx = 0
    for i, (alpha, beta) in enumerate(branches):
        val = alpha + beta * n
        if val < min_val:
            min_val = val
            min_idx = i
    return min_val, min_idx


def find_all_tropical_vertices(
    branches: List[Tuple[float, float]],
    n_max: int
) -> List[Tuple[int, int, int]]:
    """
    Find all tropical vertices (branch switching points) for multi-branch risk.

    Parameters
    ----------
    branches : list of (alpha, beta) tuples
        Each tuple defines an affine branch.
    n_max : int
        Maximum complexity to search.

    Returns
    -------
    vertices : list of (n, branch_before, branch_after)
        Each vertex records the complexity and the two branches involved.

    Time: O(n_max * k), Space: O(n_max)
    """
    vertices = []
    prev_branch = multi_branch_tropical_risk(branches, 0)[1]

    for n in range(1, n_max + 1):
        _, curr_branch = multi_branch_tropical_risk(branches, n)
        if curr_branch != prev_branch:
            vertices.append((n, prev_branch, curr_branch))
        prev_branch = curr_branch

    return vertices


# ============================================================
# Algorithm 5: Discrete Tropical Derivative
# ============================================================

def tropical_derivative(
    alpha1: float, beta1: float,
    alpha2: float, beta2: float,
    n_range: range
) -> List[float]:
    """
    Compute the discrete tropical derivative Δf(n) = f(n+1) - f(n).

    For a tropical risk R(n) = min(f₁(n), f₂(n)) with crossing at n₀:
    - Δf(n) = β₁ for n < n₀ (positive if β₁ > 0)
    - Δf(n) = β₂ for n ≥ n₀ (negative if β₂ < 0)

    Parameters
    ----------
    alpha1, beta1, alpha2, beta2 : float
        Affine branch parameters.
    n_range : range
        Range of n values to compute derivative.

    Returns
    -------
    derivatives : list of float
        Δf(n) for each n in n_range (excluding the last element).
    """
    derivatives = []
    for n in n_range:
        r_n = min(alpha1 + beta1 * n, alpha2 + beta2 * n)
        r_n1 = min(alpha1 + beta1 * (n + 1), alpha2 + beta2 * (n + 1))
        derivatives.append(r_n1 - r_n)
    return derivatives


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Algorithm 1
    print("\n--- Algorithm 1: Tropical Risk Evaluation ---")
    risk, branch = evaluate_tropical_risk(-3.0, 0.4, 5.0, -0.4, 8)
    print(f"  At n=8: risk={risk:.2f}, active branch={branch}")
    risk, branch = evaluate_tropical_risk(-3.0, 0.4, 5.0, -0.4, 12)
    print(f"  At n=12: risk={risk:.2f}, active branch={branch}")

    # Algorithm 2
    print("\n--- Algorithm 2: Tropical Vertex Location ---")
    n0 = find_tropical_vertex(-3.0, 0.4, 5.0, -0.4)
    print(f"  Vertex for f₁=-3+0.4n, f₂=5-0.4n: n₀={n0}")
    n0 = find_tropical_vertex(0.0, 1.0, 10.0, -1.0)
    print(f"  Vertex for f₁=0+1·n, f₂=10-1·n: n₀={n0}")
    n0 = find_tropical_vertex(0.0, 1.0, 1.0, -1.0)
    print(f"  Vertex for f₁=0+1·n, f₂=1-1·n: n₀={n0} (non-integer crossing)")

    # Algorithm 3
    print("\n--- Algorithm 3: Robust Model Selection ---")
    np.random.seed(42)
    N = 30
    eps = 0.1
    f_true = [-3.0 + 0.4 * n for n in range(N)]
    g_true = [5.0 - 0.4 * n for n in range(N)]
    f_noisy = [f + np.random.uniform(-eps, eps) for f in f_true]
    g_noisy = [g + np.random.uniform(-eps, eps) for g in g_true]
    vertex, conf, cands = robust_model_selection(f_noisy, g_noisy, eps)
    print(f"  Vertex={vertex}, confidence={conf}, candidates={cands}")

    # Algorithm 4
    print("\n--- Algorithm 4: Multi-Branch Phase Diagram ---")
    branches = [
        (-5.0, 0.6),   # Branch 0: steep increase
        (3.0, 0.1),    # Branch 1: gentle increase
        (8.0, -0.3),   # Branch 2: gentle decrease
        (15.0, -0.8),  # Branch 3: steep decrease
    ]
    vertices = find_all_tropical_vertices(branches, 30)
    print(f"  Branches: {branches}")
    print(f"  Vertices (transitions): {vertices}")

    # Algorithm 5
    print("\n--- Algorithm 5: Discrete Tropical Derivative ---")
    derivs = tropical_derivative(-3.0, 0.4, 5.0, -0.4, range(20))
    print(f"  Δf for f₁=-3+0.4n, f₂=5-0.4n:")
    for n, d in enumerate(derivs):
        sign = "+" if d > 0 else "-" if d < 0 else "0"
        print(f"    n={n:2d}: Δf = {d:+.2f} ({sign})")
