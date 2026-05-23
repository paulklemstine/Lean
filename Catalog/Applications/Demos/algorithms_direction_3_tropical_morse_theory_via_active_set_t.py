"""
Tropical Morse Theory: Algorithms for Active-Set Transition Analysis

This module implements algorithms for enumerating pair-critical values,
computing active-set complexes, and analyzing birth events in tropical
sublevel filtrations of max-affine families.

Key algorithms:
- Pair-critical value enumeration via equality locus scanning
- Active-set complex computation at arbitrary thresholds
- Birth event detection and Morse-theoretic analysis
- Equality hyperplane arrangement computation
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from dataclasses import dataclass


@dataclass
class TropicalAffineFamily:
    """A finite family of affine forms f_i(x) = a_i · x + b_i.

    Attributes:
        lin: Coefficient matrix of shape (k, n), where k is the number
             of forms and n is the ambient dimension.
        bias: Bias vector of length k.
    """
    lin: np.ndarray   # shape (k, n)
    bias: np.ndarray  # shape (k,)

    @property
    def k(self) -> int:
        return self.lin.shape[0]

    @property
    def n(self) -> int:
        return self.lin.shape[1]

    def eval(self, i: int, x: np.ndarray) -> float:
        """Evaluate the i-th affine form at point x."""
        return float(self.lin[i] @ x + self.bias[i])

    def eval_all(self, x: np.ndarray) -> np.ndarray:
        """Evaluate all affine forms at point x."""
        return self.lin @ x + self.bias

    def trop_max(self, x: np.ndarray) -> float:
        """Compute the tropical max-envelope at x."""
        return float(np.max(self.eval_all(x)))

    def active_set(self, x: np.ndarray, tol: float = 1e-10) -> FrozenSet[int]:
        """Compute the active set at x (indices achieving the max)."""
        vals = self.eval_all(x)
        m = np.max(vals)
        return frozenset(i for i in range(self.k) if abs(vals[i] - m) < tol)

    def in_sublevel(self, x: np.ndarray, c: float, tol: float = 1e-10) -> bool:
        """Check if x is in the sublevel set at threshold c."""
        return self.trop_max(x) <= c + tol


def random_tropical_family(n: int, k: int, seed: Optional[int] = None) -> TropicalAffineFamily:
    """Generate a random tropical affine family.

    Args:
        n: Ambient dimension.
        k: Number of affine forms.
        seed: Random seed for reproducibility.

    Returns:
        A random TropicalAffineFamily with coefficients in [-1, 1].
    """
    rng = np.random.RandomState(seed)
    lin = rng.randn(k, n)
    bias = rng.randn(k)
    return TropicalAffineFamily(lin=lin, bias=bias)


def solve_pair_equality(F: TropicalAffineFamily, i: int, j: int) -> Optional[Tuple[np.ndarray, float]]:
    """Solve the pair equality f_i(x) = f_j(x) = c with all f_l(x) ≤ c.

    For a pair (i, j), we seek x such that:
      1. f_i(x) = f_j(x)  (equality constraint)
      2. f_l(x) ≤ f_i(x) for all l  (dominance constraint)
      3. c = f_i(x)  (threshold value)

    In dimension n, equation (1) gives an (n-1)-dimensional affine subspace.
    We find a point on this subspace that satisfies (2) via linear programming.

    Returns:
        (x, c) if a feasible solution exists, None otherwise.
    """
    n = F.n
    k = F.k

    # Equality constraint: (a_i - a_j) · x + (b_i - b_j) = 0
    diff_lin = F.lin[i] - F.lin[j]
    diff_bias = F.bias[i] - F.bias[j]

    if n == 1:
        # Direct solve in 1D
        if abs(diff_lin[0]) < 1e-12:
            if abs(diff_bias) < 1e-12:
                # Forms are identical, any x works — not a genuine critical event
                return None
            else:
                return None  # No solution
        x_val = -diff_bias / diff_lin[0]
        x = np.array([x_val])
        c = F.eval(i, x)
        # Check all forms ≤ c
        if all(F.eval(l, x) <= c + 1e-10 for l in range(k)):
            return (x, c)
        return None

    elif n == 2:
        # In 2D, equality constraint gives a line
        # Parameterize the line and find feasible point
        a_diff = diff_lin
        b_diff = diff_bias

        if np.linalg.norm(a_diff) < 1e-12:
            if abs(b_diff) < 1e-12:
                return None  # Identical forms
            else:
                return None  # No solution

        # Find a particular solution and direction
        # a_diff · x = -b_diff
        # Use least-norm solution
        x0 = -b_diff * a_diff / (np.dot(a_diff, a_diff))
        # Direction along the line
        d = np.array([-a_diff[1], a_diff[0]])
        d = d / np.linalg.norm(d)

        # x = x0 + t * d
        # f_l(x) = a_l · (x0 + t*d) + b_l = (a_l · x0 + b_l) + t * (a_l · d)
        # f_i(x) = (a_i · x0 + b_i) + t * (a_i · d)
        # We need f_l(x) ≤ f_i(x) for all l, i.e.,
        # (a_l - a_i) · x0 + (b_l - b_i) + t * (a_l - a_i) · d ≤ 0

        c_i_base = F.lin[i] @ x0 + F.bias[i]
        c_i_slope = F.lin[i] @ d

        # Find feasible t range
        t_min, t_max = -1e10, 1e10

        for l in range(k):
            if l == i:
                continue
            c_l_base = F.lin[l] @ x0 + F.bias[l]
            c_l_slope = F.lin[l] @ d
            # Need c_l_base + t*c_l_slope ≤ c_i_base + t*c_i_slope
            # (c_l_slope - c_i_slope) * t ≤ c_i_base - c_l_base
            slope_diff = c_l_slope - c_i_slope
            base_diff = c_i_base - c_l_base

            if abs(slope_diff) < 1e-12:
                if base_diff < -1e-10:
                    return None  # Infeasible
            elif slope_diff > 0:
                t_max = min(t_max, base_diff / slope_diff)
            else:
                t_min = max(t_min, base_diff / slope_diff)

        if t_min > t_max + 1e-10:
            return None  # Infeasible

        t_opt = (t_min + t_max) / 2 if t_max < 1e9 and t_min > -1e9 else \
                t_max - 1 if t_max < 1e9 else \
                t_min + 1 if t_min > -1e9 else 0

        x = x0 + t_opt * d
        c = F.eval(i, x)
        return (x, c)

    else:
        # General dimension: use scipy if available
        try:
            from scipy.optimize import linprog

            # Minimize c = f_i(x) subject to:
            # f_i(x) = f_j(x)  =>  (a_i - a_j)·x = -(b_i - b_j)
            # f_l(x) ≤ f_i(x)  =>  (a_l - a_i)·x ≤ b_i - b_l  for all l ≠ i
            c_obj = np.concatenate([F.lin[i], [1]])  # minimize f_i(x) + slack

            # Inequality constraints
            A_ub = []
            b_ub = []
            for l in range(k):
                if l == i:
                    continue
                row = np.zeros(n + 1)
                row[:n] = F.lin[l] - F.lin[i]
                A_ub.append(row)
                b_ub.append(F.bias[i] - F.bias[l])

            # Equality constraint
            A_eq = np.zeros((1, n + 1))
            A_eq[0, :n] = F.lin[i] - F.lin[j]
            b_eq = [F.bias[j] - F.bias[i]]

            result = linprog(c_obj[:n], A_ub=np.array(A_ub)[:, :n] if A_ub else None,
                           b_ub=b_ub if b_ub else None,
                           A_eq=A_eq[:, :n], b_eq=b_eq,
                           bounds=[(None, None)] * n)
            if result.success:
                x = result.x
                c = F.eval(i, x)
                return (x, c)
        except ImportError:
            pass
        return None


def enumerate_pair_criticals(F: TropicalAffineFamily) -> List[Tuple[int, int, np.ndarray, float]]:
    """Enumerate all candidate pair-critical values.

    Scans all unordered pairs (i, j) of affine forms and solves
    the pair-equality event constraint for each.

    Returns:
        List of (i, j, x, c) tuples representing pair-critical events.

    Time complexity: O(k² · T_solve) where T_solve is the cost of
    solving one pair-equality LP (polynomial in n and k).
    Space complexity: O(k²) for storing candidate events.
    """
    criticals = []
    for i, j in combinations(range(F.k), 2):
        result = solve_pair_equality(F, i, j)
        if result is not None:
            x, c = result
            criticals.append((i, j, x, c))
    return criticals


def compute_active_set_complex(
    F: TropicalAffineFamily,
    c: float,
    num_samples: int = 1000,
    tol: float = 1e-8
) -> Set[FrozenSet[int]]:
    """Compute the active-set complex at threshold c via sampling.

    Samples random points in the sublevel set and collects all subsets
    of realized active sets, forming the simplicial complex.

    Args:
        F: The tropical affine family.
        c: Threshold value.
        num_samples: Number of random sample points.
        tol: Tolerance for active set detection.

    Returns:
        Set of frozensets representing faces of the active-set complex.
    """
    complex_faces: Set[FrozenSet[int]] = set()

    # Sample points in the sublevel set
    for _ in range(num_samples):
        x = np.random.randn(F.n) * 2
        # Project into sublevel by scaling if needed
        tm = F.trop_max(x)
        if tm > c:
            # Scale toward origin
            if abs(tm) > 1e-12:
                scale = (c - np.min(F.bias)) / (tm - np.min(F.bias)) if tm > np.min(F.bias) else 0.5
                x = x * max(0, min(1, scale))

        if F.in_sublevel(x, c, tol):
            aset = F.active_set(x, tol)
            # Add all subsets (downward closure)
            for r in range(len(aset) + 1):
                for subset in combinations(sorted(aset), r):
                    complex_faces.add(frozenset(subset))

    # Also try boundary points near critical values
    criticals = enumerate_pair_criticals(F)
    for _, _, x, cv in criticals:
        if cv <= c + tol:
            aset = F.active_set(x, tol)
            for r in range(len(aset) + 1):
                for subset in combinations(sorted(aset), r):
                    complex_faces.add(frozenset(subset))

    return complex_faces


def detect_births(
    F: TropicalAffineFamily,
    thresholds: Optional[List[float]] = None,
    num_samples: int = 500
) -> List[Tuple[float, Set[FrozenSet[int]]]]:
    """Detect birth events in the active-set filtration.

    Computes the active-set complex at each threshold and identifies
    new faces (births) at each step.

    Args:
        F: The tropical affine family.
        thresholds: List of thresholds to scan. If None, uses pair-critical values.
        num_samples: Samples per threshold for complex computation.

    Returns:
        List of (threshold, new_faces) pairs.
    """
    if thresholds is None:
        criticals = enumerate_pair_criticals(F)
        crit_values = sorted(set(cv for _, _, _, cv in criticals))
        if not crit_values:
            return []
        # Add points slightly below and above each critical value
        eps = 1e-6
        thresholds = []
        for cv in crit_values:
            thresholds.extend([cv - eps, cv, cv + eps])
        thresholds = sorted(set(thresholds))

    births = []
    prev_complex: Set[FrozenSet[int]] = set()

    for c in thresholds:
        curr_complex = compute_active_set_complex(F, c, num_samples)
        new_faces = curr_complex - prev_complex
        if new_faces:
            births.append((c, new_faces))
        prev_complex = curr_complex

    return births


def compute_equality_hyperplanes(F: TropicalAffineFamily) -> List[Dict]:
    """Compute the equality hyperplane arrangement.

    For each pair (i, j), the equality hyperplane is
    {x | f_i(x) = f_j(x)} = {x | (a_i - a_j) · x = b_j - b_i}.

    Returns:
        List of dicts with keys: 'pair', 'normal', 'offset'.
    """
    hyperplanes = []
    for i, j in combinations(range(F.k), 2):
        normal = F.lin[i] - F.lin[j]
        offset = F.bias[j] - F.bias[i]
        hyperplanes.append({
            'pair': (i, j),
            'normal': normal,
            'offset': offset
        })
    return hyperplanes


def euler_characteristic_proxy(complex_faces: Set[FrozenSet[int]]) -> int:
    """Compute the Euler characteristic of an abstract simplicial complex.

    χ = Σ_m (-1)^m · |{faces of cardinality m+1}|

    Args:
        complex_faces: Set of frozensets representing the simplicial complex.

    Returns:
        The Euler characteristic (integer).
    """
    chi = 0
    for face in complex_faces:
        if len(face) > 0:  # Skip empty set
            chi += (-1) ** (len(face) - 1)
    return chi


def morse_birth_count(births: List[Tuple[float, Set[FrozenSet[int]]]]) -> Dict[int, int]:
    """Count births by dimension.

    Args:
        births: Output of detect_births.

    Returns:
        Dict mapping dimension m to number of m-cells born.
    """
    counts: Dict[int, int] = {}
    for _, new_faces in births:
        for face in new_faces:
            dim = len(face) - 1
            if dim >= 0:
                counts[dim] = counts.get(dim, 0) + 1
    return counts


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)
    F = random_tropical_family(n=2, k=4)
    print(f"Tropical family: n={F.n}, k={F.k}")
    print(f"Coefficients:\n{F.lin}")
    print(f"Biases: {F.bias}")

    criticals = enumerate_pair_criticals(F)
    print(f"\nPair-critical values ({len(criticals)} found):")
    for i, j, x, c in criticals:
        print(f"  Pair ({i},{j}): c = {c:.4f}, x = {x}")

    print(f"\nBound: k*(k-1)/2 = {F.k * (F.k - 1) // 2}")
    print(f"Actual critical values: {len(criticals)}")
    assert len(criticals) <= F.k * (F.k - 1) // 2, "Bound violated!"

    hyperplanes = compute_equality_hyperplanes(F)
    print(f"\nEquality hyperplanes: {len(hyperplanes)}")

    births = detect_births(F)
    print(f"\nBirth events: {len(births)}")
    for c, new_faces in births:
        maximal = [f for f in new_faces if not any(f < g for g in new_faces)]
        print(f"  c = {c:.4f}: {len(new_faces)} new faces, maximal: {[set(f) for f in maximal]}")

    birth_counts = morse_birth_count(births)
    print(f"\nBirth counts by dimension: {birth_counts}")
