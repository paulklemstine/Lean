#!/usr/bin/env python3
"""
Algorithms for Tropical Balanced Consciousness Theory

Implements the core computational procedures arising from the formal theory:
1. Balanced state detection and computation
2. Interval collapse detection
3. Alternating min/max iteration
4. Higher-dimensional balanced region computation
"""

import numpy as np
from typing import Optional, Tuple, List


# ============================================================
# Algorithm 1: Balanced State Computation (Scalar)
# ============================================================

def compute_balanced_state(a: float) -> float:
    """
    Compute the unique balanced conscious state for threshold a.

    By Theorem 2 (balanced_conscious_unique), the unique x satisfying
    min(a, x) = x ∧ max(a, x) = x is x = a.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: The tropical threshold parameter.

    Returns:
        The unique balanced conscious state, which equals a.

    Example:
        >>> compute_balanced_state(3.14)
        3.14
    """
    return a


def verify_balanced(a: float, x: float, tol: float = 1e-12) -> bool:
    """
    Verify whether x is a balanced conscious state for threshold a.

    Checks both conditions: min(a, x) ≈ x and max(a, x) ≈ x.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: The tropical threshold.
        x: The candidate state.
        tol: Numerical tolerance for floating-point comparison.

    Returns:
        True if x is balanced conscious for threshold a.

    Example:
        >>> verify_balanced(5.0, 5.0)
        True
        >>> verify_balanced(5.0, 3.0)
        False
    """
    return abs(min(a, x) - x) < tol and abs(max(a, x) - x) < tol


# ============================================================
# Algorithm 2: Interval Balanced Region (Scalar)
# ============================================================

def balanced_interval(l: float, u: float) -> Optional[Tuple[float, float]]:
    """
    Compute the balanced region for interval constraints [l, u].

    By Theorem 4 (balanced_interval_characterization), the set
    {x : max(l,x) = x ∧ min(u,x) = x} equals [l, u] when l ≤ u,
    and is empty when l > u.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        l: Lower bound (optimistic threshold).
        u: Upper bound (pessimistic threshold).

    Returns:
        Tuple (l, u) if l ≤ u (the balanced interval), None if l > u (empty).

    Example:
        >>> balanced_interval(1.0, 5.0)
        (1.0, 5.0)
        >>> balanced_interval(5.0, 1.0) is None
        True
    """
    if l <= u:
        return (l, u)
    return None


def is_collapse(l: float, u: float, tol: float = 1e-12) -> bool:
    """
    Check if the interval collapses, i.e., there is a unique balanced state.

    By Theorem 4 (balanced_unique_iff_collapse), ∃! x balanced ↔ l = u.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        l: Lower bound.
        u: Upper bound.
        tol: Numerical tolerance.

    Returns:
        True if l ≈ u (unique balanced state exists).

    Example:
        >>> is_collapse(3.0, 3.0)
        True
        >>> is_collapse(3.0, 5.0)
        False
    """
    return abs(l - u) < tol


# ============================================================
# Algorithm 3: Alternating Min/Max Iteration
# ============================================================

def alternating_iteration(
    l: float, u: float, x0: float, n_steps: int = 10
) -> List[float]:
    """
    Run alternating min/max iteration starting from x0.

    The iteration alternates:
      x_{2k+1} = min(u, x_{2k})    (pessimistic step)
      x_{2k+2} = max(l, x_{2k+1})  (optimistic step)

    When l ≤ u, this converges to clamp(x0, l, u) in at most 2 steps.
    When l > u, the sequence oscillates between l and u.

    Time complexity: O(n_steps)
    Space complexity: O(n_steps)

    Args:
        l: Lower bound (optimistic threshold).
        u: Upper bound (pessimistic threshold).
        x0: Initial state.
        n_steps: Number of iteration steps.

    Returns:
        List of states [x0, x1, x2, ...].

    Example:
        >>> alternating_iteration(1.0, 5.0, 10.0, 4)
        [10.0, 5.0, 5.0, 5.0, 5.0]
    """
    trajectory = [x0]
    x = x0
    for i in range(n_steps):
        if i % 2 == 0:
            x = min(u, x)  # pessimistic step
        else:
            x = max(l, x)  # optimistic step
        trajectory.append(x)
    return trajectory


# ============================================================
# Algorithm 4: Higher-Dimensional Balanced Region
# ============================================================

def balanced_region_nd(
    l: np.ndarray, u: np.ndarray
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Compute the balanced region for componentwise interval constraints in ℝⁿ.

    The balanced set is the box [l, u] = ∏ᵢ [lᵢ, uᵢ] when l ≤ u componentwise,
    and empty otherwise.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        l: Lower bound vector.
        u: Upper bound vector.

    Returns:
        Tuple (l, u) if l ≤ u componentwise, None otherwise.

    Example:
        >>> balanced_region_nd(np.array([1, 2]), np.array([3, 4]))
        (array([1, 2]), array([3, 4]))
    """
    if np.all(l <= u):
        return (l.copy(), u.copy())
    return None


def sample_balanced_states(
    l: np.ndarray, u: np.ndarray, n_samples: int = 100
) -> Optional[np.ndarray]:
    """
    Sample uniformly from the balanced region [l, u] in ℝⁿ.

    Args:
        l: Lower bound vector.
        u: Upper bound vector.
        n_samples: Number of samples.

    Returns:
        Array of shape (n_samples, n) of balanced states, or None if empty.
    """
    if not np.all(l <= u):
        return None
    n = len(l)
    samples = np.random.uniform(l, u, size=(n_samples, n))
    return samples


def tropical_dual_state(a: float, x: float) -> Tuple[float, float]:
    """
    Compute the Maslov-dual state under tropical negation.

    By Theorem 3 (balanced_conscious_duality), if (a, x) is a balanced pair,
    then (-a, -x) is balanced with min/max exchanged.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: Threshold.
        x: State.

    Returns:
        The dual pair (-a, -x).

    Example:
        >>> tropical_dual_state(3.0, 3.0)
        (-3.0, -3.0)
    """
    return (-a, -x)


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1
    print("1. Balanced State Computation")
    for a in [0, 1, -5, 3.14, 100]:
        x = compute_balanced_state(a)
        print(f"   threshold={a:>7.2f} → balanced state={x:>7.2f}, "
              f"verified={verify_balanced(a, x)}")

    # Algorithm 2
    print("\n2. Interval Balanced Region")
    for l, u in [(1, 5), (3, 3), (-2, 2), (5, 1)]:
        result = balanced_interval(l, u)
        collapse = is_collapse(l, u)
        print(f"   [{l}, {u}] → region={result}, collapse={collapse}")

    # Algorithm 3
    print("\n3. Alternating Iteration")
    for l, u, x0 in [(1, 5, 10), (1, 5, -3), (3, 3, 7), (5, 1, 3)]:
        traj = alternating_iteration(l, u, x0, 6)
        print(f"   [{l},{u}], x0={x0}: {' → '.join(f'{x:.1f}' for x in traj)}")

    # Algorithm 4
    print("\n4. Higher-Dimensional Balanced Region")
    l = np.array([1.0, 2.0, 3.0])
    u = np.array([4.0, 5.0, 6.0])
    result = balanced_region_nd(l, u)
    if result is not None:
        print(f"   l={l}, u={u}")
        print(f"   Region: [{result[0]}, {result[1]}]")
        samples = sample_balanced_states(l, u, 5)
        if samples is not None:
            print(f"   Sample balanced states:")
            for s in samples:
                print(f"     {s}")
