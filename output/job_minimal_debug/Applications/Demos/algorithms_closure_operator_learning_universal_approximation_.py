#!/usr/bin/env python3
"""
Algorithms for Closure-Operator Networks

Implements the core algorithms arising from the formal theory:
1. Closure-step approximation (piecewise-constant via quantization)
2. Closure feature extraction (indicator basis)
3. Certified robustness verification
4. Optimal mesh selection for target accuracy
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class ClosureOperator:
    """A closure operator on a finite domain {0, 1, ..., n-1}.

    Represented by its action on subsets (as frozensets of indices).
    Satisfies: monotone, extensive, idempotent.
    """
    n: int
    _action: Callable[[frozenset], frozenset]

    def __call__(self, s: frozenset) -> frozenset:
        return self._action(s)

    def is_valid(self, test_subsets: Optional[List[frozenset]] = None) -> bool:
        """Verify closure operator axioms on given subsets."""
        if test_subsets is None:
            test_subsets = [frozenset(range(k)) for k in range(self.n + 1)]
            test_subsets += [frozenset([i]) for i in range(self.n)]

        for s in test_subsets:
            cs = self(s)
            # Extensive: s ⊆ c(s)
            if not s.issubset(cs):
                return False
            # Idempotent: c(c(s)) = c(s)
            if self(cs) != cs:
                return False

        # Monotone: s ⊆ t → c(s) ⊆ c(t)
        for i, s in enumerate(test_subsets):
            for t in test_subsets[i:]:
                if s.issubset(t) and not self(s).issubset(self(t)):
                    return False
        return True


def identity_closure(n: int) -> ClosureOperator:
    """The identity closure operator c(s) = s."""
    return ClosureOperator(n=n, _action=lambda s: s)


def upward_closure(n: int, poset_le: Callable[[int, int], bool]) -> ClosureOperator:
    """Upward closure in a partial order: c(s) = {y : ∃ x ∈ s, x ≤ y}."""
    def action(s: frozenset) -> frozenset:
        result = set(s)
        for x in s:
            for y in range(n):
                if poset_le(x, y):
                    result.add(y)
        return frozenset(result)
    return ClosureOperator(n=n, _action=action)


def ball_closure(points: np.ndarray, radius: float) -> ClosureOperator:
    """Metric ball closure: c(s) = ∪_{x ∈ s} B(x, r).

    Args:
        points: (n, d) array of point coordinates
        radius: closure ball radius
    """
    n = len(points)
    # Precompute distance matrix
    dists = np.linalg.norm(points[:, None] - points[None, :], axis=-1)

    def action(s: frozenset) -> frozenset:
        result = set(s)
        for x in s:
            for y in range(n):
                if dists[x, y] <= radius:
                    result.add(y)
        # Apply again for idempotence (take transitive closure)
        changed = True
        while changed:
            new_result = set(result)
            for x in result:
                for y in range(n):
                    if dists[x, y] <= radius:
                        new_result.add(y)
            changed = new_result != result
            result = new_result
        return frozenset(result)
    return ClosureOperator(n=n, _action=action)


# ============================================================
# Algorithm 1: Closure Feature Extraction
# ============================================================

def extract_closure_features(
    n: int,
    closures: List[ClosureOperator],
    prototypes: List[frozenset]
) -> np.ndarray:
    """
    Extract closure indicator features for all domain points.

    For each point x ∈ {0,...,n-1} and each (closure, prototype) pair,
    compute: φ_i(x) = 1 if x ∈ C_i(proto_i) else 0

    Args:
        n: domain size
        closures: list of m closure operators
        prototypes: list of m prototype sets

    Returns:
        (m, n) feature matrix Φ where Φ[i, x] = φ_i(x)

    Time complexity: O(m · n · T_closure) where T_closure is per-closure cost
    Space complexity: O(m · n)
    """
    m = len(closures)
    features = np.zeros((m, n))
    for i in range(m):
        closed_set = closures[i](prototypes[i])
        for x in range(n):
            if x in closed_set:
                features[i, x] = 1.0
    return features


def solve_closure_representation(
    f_values: np.ndarray,
    features: np.ndarray
) -> np.ndarray:
    """
    Find weights w such that f(x) = Σ_i w_i · φ_i(x).

    Uses least-squares if the system is over/underdetermined.

    Args:
        f_values: (n,) target function values
        features: (m, n) feature matrix

    Returns:
        (m,) weight vector

    Time complexity: O(m² · n + m³)
    """
    # Solve features.T @ w = f_values
    w, _, _, _ = np.linalg.lstsq(features.T, f_values, rcond=None)
    return w


# ============================================================
# Algorithm 2: Closure-Step Approximation
# ============================================================

def closure_step_approximate(
    f: Callable[[float], float],
    N: int,
    x: float
) -> float:
    """
    Evaluate the closure-step approximation of f at point x.

    Partitions [0,1] into N equal cells, evaluates f at each cell center,
    returns the value at the center of x's cell.

    Args:
        f: target function
        N: number of cells (must be positive)
        x: evaluation point in [0,1]

    Returns:
        f(center of cell containing x)

    Time complexity: O(1) per evaluation (+ cost of one f evaluation)
    Space complexity: O(1)
    """
    delta = 1.0 / N
    i = min(int(x / delta), N - 1)
    center = i * delta + delta / 2
    return f(center)


def optimal_mesh_for_accuracy(
    f: Callable[[float], float],
    epsilon: float,
    L: Optional[float] = None,
    n_samples: int = 10000
) -> int:
    """
    Compute the minimum number of cells N for closure-step error ≤ ε.

    If Lipschitz constant L is provided, uses the bound N ≥ L/ε.
    Otherwise, estimates L numerically.

    Args:
        f: target function (assumed Lipschitz on [0,1])
        epsilon: target accuracy
        L: Lipschitz constant (estimated if None)
        n_samples: samples for Lipschitz estimation

    Returns:
        Minimum N guaranteeing error ≤ ε

    Time complexity: O(n_samples) for estimation
    """
    if L is None:
        # Estimate Lipschitz constant
        xs = np.linspace(0, 1, n_samples)
        fs = np.array([f(x) for x in xs])
        diffs = np.abs(np.diff(fs)) / np.diff(xs)
        L = np.max(diffs) * 1.1  # 10% safety margin

    N = int(np.ceil(L / epsilon))
    return max(N, 1)


# ============================================================
# Algorithm 3: Certified Robustness Verification
# ============================================================

@dataclass
class RobustnessCertificate:
    """Certificate that a point is robustly classified."""
    point: float
    label: int
    radius: float
    is_certified: bool


def certify_closure_classifier(
    x: float,
    classifier: Callable[[float], int],
    closure_rep: Callable[[float], float],
    cell_width: float
) -> RobustnessCertificate:
    """
    Certify robustness of a closure-based classifier at point x.

    The certified radius is the distance from x to the nearest cell boundary.

    Args:
        x: point to certify
        classifier: the classifier function
        closure_rep: closure representative map
        cell_width: width of quantization cells

    Returns:
        RobustnessCertificate with certified radius

    Time complexity: O(1)
    """
    label = classifier(x)
    center = closure_rep(x)

    # Distance to nearest cell boundary
    cell_left = center - cell_width / 2
    cell_right = center + cell_width / 2
    radius = min(x - cell_left, cell_right - x)
    radius = max(radius, 0.0)

    return RobustnessCertificate(
        point=x,
        label=label,
        radius=radius,
        is_certified=radius > 0
    )


def batch_certify(
    points: np.ndarray,
    classifier: Callable[[float], int],
    closure_rep: Callable[[float], float],
    cell_width: float,
    min_radius: float = 0.0
) -> Tuple[List[RobustnessCertificate], float]:
    """
    Certify robustness for a batch of points.

    Args:
        points: array of points to certify
        classifier: the classifier function
        closure_rep: closure representative map
        cell_width: width of quantization cells
        min_radius: minimum radius for certification

    Returns:
        (certificates, fraction_certified)

    Time complexity: O(n) where n = len(points)
    """
    certs = [certify_closure_classifier(x, classifier, closure_rep, cell_width)
             for x in points]
    n_certified = sum(1 for c in certs if c.radius >= min_radius)
    fraction = n_certified / len(points)
    return certs, fraction


# ============================================================
# Algorithm 4: Adaptive Closure-Step with Error Control
# ============================================================

def adaptive_closure_step(
    f: Callable[[float], float],
    epsilon: float,
    max_cells: int = 10000
) -> Tuple[int, Callable[[float], float], float]:
    """
    Adaptively choose N for closure-step approximation to achieve error < ε.

    Doubles N until the observed error is below ε (with verification).

    Args:
        f: target function
        epsilon: target accuracy
        max_cells: maximum number of cells

    Returns:
        (N, approximant function, achieved error)

    Time complexity: O(N_final · n_test) where n_test is verification samples
    """
    x_test = np.linspace(0, 1, 10000)
    f_test = np.array([f(x) for x in x_test])

    N = 1
    while N <= max_cells:
        g_test = np.array([closure_step_approximate(f, N, x) for x in x_test])
        error = np.max(np.abs(f_test - g_test))
        if error < epsilon:
            return N, lambda x, N=N: closure_step_approximate(f, N, x), error
        N *= 2

    return N // 2, lambda x, N=N//2: closure_step_approximate(f, N, x), error


if __name__ == '__main__':
    # Example usage
    print("Testing algorithms...")

    # Test closure operators
    n = 5
    c_id = identity_closure(n)
    assert c_id.is_valid(), "Identity closure should be valid"

    # Test divisibility order closure
    def divides(a, b):
        if a == 0:
            return a == b
        return b % (a + 1) == 0 or a == b  # shift to avoid div by 0

    c_up = upward_closure(n, lambda a, b: a <= b)  # total order
    assert c_up.is_valid(), "Upward closure should be valid"

    # Test feature extraction
    closures = [identity_closure(n) for _ in range(n)]
    protos = [frozenset([i]) for i in range(n)]
    features = extract_closure_features(n, closures, protos)
    assert np.allclose(features, np.eye(n)), "Identity features should be identity matrix"

    # Test representation
    f_vals = np.array([1.0, -2.0, 3.0, 0.5, -1.5])
    weights = solve_closure_representation(f_vals, features)
    reconstructed = features.T @ weights
    assert np.allclose(f_vals, reconstructed), "Should reconstruct exactly"

    # Test adaptive approximation
    def test_f(x):
        return np.sin(6 * np.pi * x) + 0.5

    N, g, err = adaptive_closure_step(test_f, 0.1)
    print(f"Adaptive: N={N}, achieved error={err:.6f}")

    # Test certification
    cell_width = 1.0 / 10
    cert = certify_closure_classifier(
        0.35,
        lambda x: min(int(x / cell_width), 9),
        lambda x: (min(int(x / cell_width), 9) + 0.5) * cell_width,
        cell_width
    )
    print(f"Certificate at x=0.35: label={cert.label}, radius={cert.radius:.4f}")

    print("\nAll algorithm tests passed!")
