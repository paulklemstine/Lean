#!/usr/bin/env python3
"""
Algorithms for Tropical Scaling Law Analysis

Implements:
1. RegimeClassifier: Identify which scaling regime dominates at any point
2. CornerLocator: Find exact phase-transition boundaries
3. ParetoFrontier: Compute optimal resource allocation under compute constraints
4. TropicalRegression: Fit tropical (piecewise-affine) models to scaling data
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class ScalingParams:
    """Parameters for a 3-regime tropical scaling law.

    The loss in log-coordinates is:
        T(x,y,z) = min(A + a*x, B + b*y, C + c*z)
    where x = log(N), y = log(D), z = log(C).
    """
    a: float  # slope for parameter (N) term
    b: float  # slope for data (D) term
    c: float  # slope for compute (C) term
    A: float  # intercept for N term
    B: float  # intercept for D term
    C: float  # intercept for C term


class TropicalScalingLoss:
    """Evaluates the tropical scaling loss and classifies regimes.

    Time complexity: O(1) per evaluation, O(n) for n points.
    Space complexity: O(1).
    """

    def __init__(self, params: ScalingParams):
        self.params = params

    def evaluate(self, x: float, y: float, z: float) -> float:
        """Evaluate T(x,y,z) = min(A + a*x, B + b*y, C + c*z).

        Args:
            x: log-parameters (log N)
            y: log-data (log D)
            z: log-compute (log C)

        Returns:
            The tropical scaling loss value.
        """
        p = self.params
        return min(p.A + p.a * x, min(p.B + p.b * y, p.C + p.c * z))

    def evaluate_batch(self, points: np.ndarray) -> np.ndarray:
        """Evaluate the loss at multiple points.

        Args:
            points: Array of shape (n, 3) with columns [x, y, z].

        Returns:
            Array of shape (n,) with loss values.
        """
        p = self.params
        f_n = p.A + p.a * points[:, 0]
        f_d = p.B + p.b * points[:, 1]
        f_c = p.C + p.c * points[:, 2]
        return np.minimum(f_n, np.minimum(f_d, f_c))

    def terms(self, x: float, y: float, z: float) -> Tuple[float, float, float]:
        """Return the three affine terms (f_N, f_D, f_C)."""
        p = self.params
        return (p.A + p.a * x, p.B + p.b * y, p.C + p.c * z)


class RegimeClassifier:
    """Classify points into scaling regimes.

    Algorithm:
        1. Compute all three affine terms.
        2. Check pairwise equalities (within tolerance).
        3. If ties exist, classify as corner; otherwise, classify by strict minimum.

    Time: O(1) per point.
    Space: O(1).
    """

    def __init__(self, params: ScalingParams, tol: float = 1e-12):
        self.loss = TropicalScalingLoss(params)
        self.tol = tol

    def classify(self, x: float, y: float, z: float) -> str:
        """Classify a single point.

        Returns one of:
            'N_STRICT', 'D_STRICT', 'C_STRICT' (strict dominance),
            'CORNER_ND', 'CORNER_NC', 'CORNER_DC' (pairwise tie),
            'CORNER_NDC' (triple tie).
        """
        f_n, f_d, f_c = self.loss.terms(x, y, z)
        nd_eq = abs(f_n - f_d) < self.tol
        nc_eq = abs(f_n - f_c) < self.tol
        dc_eq = abs(f_d - f_c) < self.tol

        if nd_eq and nc_eq:
            return 'CORNER_NDC'

        m = min(f_n, f_d, f_c)
        if nd_eq and abs(f_n - m) < self.tol:
            return 'CORNER_ND'
        if nc_eq and abs(f_n - m) < self.tol:
            return 'CORNER_NC'
        if dc_eq and abs(f_d - m) < self.tol:
            return 'CORNER_DC'

        if abs(f_n - m) < self.tol:
            return 'N_STRICT'
        elif abs(f_d - m) < self.tol:
            return 'D_STRICT'
        else:
            return 'C_STRICT'

    def classify_batch(self, points: np.ndarray) -> List[str]:
        """Classify multiple points."""
        return [self.classify(p[0], p[1], p[2]) for p in points]


class CornerLocator:
    """Locate phase-transition boundaries (corner loci).

    The corner locus consists of hyperplanes where two affine terms are equal
    and jointly minimal. For the 3-regime case:
        - N-D boundary: A + a*x = B + b*y, both ≤ C + c*z
        - N-C boundary: A + a*x = C + c*z, both ≤ B + b*y
        - D-C boundary: B + b*y = C + c*z, both ≤ A + a*x

    Algorithm:
        For each pair, solve the equality constraint for one variable
        in terms of the others, then check the dominance condition.

    Time: O(n) where n is the number of grid points for boundary sampling.
    Space: O(n) for storing boundary points.
    """

    def __init__(self, params: ScalingParams):
        self.params = params

    def nd_boundary_z_fixed(self, z: float,
                             x_range: Tuple[float, float] = (-10, 30)
                             ) -> Optional[Tuple[float, float]]:
        """Find the N-D boundary point for a fixed z.

        On the N-D boundary: A + a*x = B + b*y
        => y = (A + a*x - B) / b  (if b != 0)

        Returns (x, y) such that the dominance condition holds, or None.
        """
        p = self.params
        if abs(p.b) < 1e-15:
            return None

        # Sample x values and find where dominance condition holds
        for x in np.linspace(x_range[0], x_range[1], 1000):
            y = (p.A + p.a * x - p.B) / p.b
            f_n = p.A + p.a * x
            f_c = p.C + p.c * z
            if f_n <= f_c + 1e-10:
                return (x, y)
        return None

    def find_all_corners_2d(self, z: float,
                             x_range: Tuple[float, float] = (-10, 30),
                             n_points: int = 1000
                             ) -> Dict[str, List[Tuple[float, float]]]:
        """Find corner locus curves in the (x, y) plane for fixed z.

        Returns dict mapping boundary name to list of (x, y) points.
        """
        p = self.params
        boundaries: Dict[str, List[Tuple[float, float]]] = {
            'ND': [], 'NC': [], 'DC': []
        }

        for x in np.linspace(x_range[0], x_range[1], n_points):
            # N-D: A + a*x = B + b*y => y = (A + a*x - B) / b
            if abs(p.b) > 1e-15:
                y_nd = (p.A + p.a * x - p.B) / p.b
                f_tie = p.A + p.a * x
                f_c = p.C + p.c * z
                if f_tie <= f_c + 1e-10:
                    boundaries['ND'].append((x, y_nd))

            # N-C: A + a*x = C + c*z => This is a vertical line in (x,y)
            # A + a*x = C + c*z => x = (C + c*z - A) / a
            # Only one x value works; check if this x is in range
            if abs(p.a) > 1e-15:
                x_nc = (p.C + p.c * z - p.A) / p.a
                if abs(x - x_nc) < (x_range[1] - x_range[0]) / n_points:
                    # Any y works as long as dominance holds
                    f_tie = p.A + p.a * x_nc
                    f_d = p.B + p.b * x  # using x as proxy for y
                    # Actually, for NC boundary, we need f_tie <= B + b*y
                    # => y >= (f_tie - B) / b
                    y_min = (f_tie - p.B) / p.b if abs(p.b) > 1e-15 else float('-inf')
                    boundaries['NC'].append((x_nc, max(x, y_min)))

        # D-C: B + b*y = C + c*z => y = (C + c*z - B) / b
        if abs(p.b) > 1e-15:
            y_dc = (p.C + p.c * z - p.B) / p.b
            for x in np.linspace(x_range[0], x_range[1], n_points):
                f_tie = p.B + p.b * y_dc
                f_n = p.A + p.a * x
                if f_tie <= f_n + 1e-10:
                    boundaries['DC'].append((x, y_dc))

        return boundaries

    def triple_point(self, ) -> Optional[Tuple[float, float, float]]:
        """Find the triple point where all three regimes meet.

        Solves: A + a*x = B + b*y = C + c*z
        This is a 2-equation system in 3 unknowns (1D solution set).
        Returns one representative point (with z=0), or None if degenerate.
        """
        p = self.params
        # A + a*x = B + b*y and A + a*x = C + c*z
        # With z=0: x = (C - A) / a, y = (A + a*x - B) / b
        if abs(p.a) < 1e-15 or abs(p.b) < 1e-15:
            return None

        z = 0.0
        x = (p.C + p.c * z - p.A) / p.a
        y = (p.A + p.a * x - p.B) / p.b
        return (x, y, z)


class ParetoFrontier:
    """Compute Pareto-optimal resource allocations.

    Given a capability threshold τ and cost function α*x + β*y + γ*z,
    find the minimum-cost point satisfying T(x,y,z) ≤ τ.

    Algorithm:
        1. For each regime, the feasibility set is a half-space.
        2. The optimal point in each regime is found by constrained
           linear optimization (vertex of the feasible polytope).
        3. The global optimum is the minimum across regimes.

    Time: O(1) (closed-form per regime).
    Space: O(1).
    """

    def __init__(self, params: ScalingParams):
        self.params = params

    def optimal_in_regime(self, regime: str, tau: float,
                           cost_weights: Tuple[float, float, float] = (1, 1, 1)
                           ) -> Optional[Tuple[float, float, float, float]]:
        """Find optimal point within a single regime.

        Args:
            regime: 'N', 'D', or 'C'
            tau: capability threshold
            cost_weights: (α, β, γ) for cost = α*x + β*y + γ*z

        Returns:
            (x, y, z, cost) or None if infeasible.
        """
        p = self.params
        alpha, beta, gamma = cost_weights

        if regime == 'N':
            # Need A + a*x ≤ τ => x ≥ (τ - A) / a (if a < 0) or x ≤ (τ-A)/a (if a > 0)
            if abs(p.a) < 1e-15:
                return None
            x = (tau - p.A) / p.a
            # y, z can be anything (minimize cost)
            # Set y = z = 0 for minimum cost (assuming positive weights)
            y, z = 0.0, 0.0
            cost = alpha * x + beta * y + gamma * z
            return (x, y, z, cost)
        elif regime == 'D':
            if abs(p.b) < 1e-15:
                return None
            y = (tau - p.B) / p.b
            x, z = 0.0, 0.0
            cost = alpha * x + beta * y + gamma * z
            return (x, y, z, cost)
        elif regime == 'C':
            if abs(p.c) < 1e-15:
                return None
            z = (tau - p.C) / p.c
            x, y = 0.0, 0.0
            cost = alpha * x + beta * y + gamma * z
            return (x, y, z, cost)
        return None

    def find_optimal(self, tau: float,
                      cost_weights: Tuple[float, float, float] = (1, 1, 1)
                      ) -> Tuple[str, float, float, float, float]:
        """Find the globally optimal resource allocation.

        Returns:
            (regime, x, y, z, cost) for the optimal allocation.
        """
        best = None
        for regime in ['N', 'D', 'C']:
            result = self.optimal_in_regime(regime, tau, cost_weights)
            if result is not None:
                x, y, z, cost = result
                if best is None or cost < best[4]:
                    best = (regime, x, y, z, cost)
        return best


class TropicalRegression:
    """Fit a tropical (piecewise-affine) scaling law to data.

    Given observations (x_i, y_i, z_i, L_i), fit parameters
    (a, b, c, A, B, C) such that
        T(x,y,z) = min(A + a*x, B + b*y, C + c*z) ≈ L

    Algorithm (alternating minimization):
        1. Fix regime assignments; fit affine parameters by least squares.
        2. Fix parameters; reassign regimes by minimum selection.
        3. Repeat until convergence.

    Time: O(n * k * max_iter) where n = data points, k = 3 regimes.
    Space: O(n).
    """

    def __init__(self, max_iter: int = 100, tol: float = 1e-8):
        self.max_iter = max_iter
        self.tol = tol

    def fit(self, X: np.ndarray, L: np.ndarray) -> ScalingParams:
        """Fit tropical scaling parameters.

        Args:
            X: Array of shape (n, 3) with columns [x, y, z].
            L: Array of shape (n,) with loss observations.

        Returns:
            Fitted ScalingParams.
        """
        n = len(L)

        # Initialize with simple linear regression on each coordinate
        a_hat = np.polyfit(X[:, 0], L, 1)
        b_hat = np.polyfit(X[:, 1], L, 1)
        c_hat = np.polyfit(X[:, 2], L, 1)

        params = ScalingParams(
            a=a_hat[0], b=b_hat[0], c=c_hat[0],
            A=a_hat[1], B=b_hat[1], C=c_hat[1]
        )

        prev_loss = float('inf')

        for iteration in range(self.max_iter):
            # Step 1: Assign regimes
            f_n = params.A + params.a * X[:, 0]
            f_d = params.B + params.b * X[:, 1]
            f_c = params.C + params.c * X[:, 2]

            assignments = np.argmin(np.column_stack([f_n, f_d, f_c]), axis=1)

            # Step 2: Fit affine parameters per regime
            for regime in range(3):
                mask = assignments == regime
                if mask.sum() < 2:
                    continue

                col = regime  # x for N, y for D, z for C
                coeffs = np.polyfit(X[mask, col], L[mask], 1)

                if regime == 0:
                    params.a, params.A = coeffs[0], coeffs[1]
                elif regime == 1:
                    params.b, params.B = coeffs[0], coeffs[1]
                else:
                    params.c, params.C = coeffs[0], coeffs[1]

            # Check convergence
            loss_fn = TropicalScalingLoss(params)
            predicted = loss_fn.evaluate_batch(X)
            total_loss = np.mean((predicted - L) ** 2)

            if abs(prev_loss - total_loss) < self.tol:
                break
            prev_loss = total_loss

        return params


def demo_algorithms():
    """Run all algorithm demonstrations."""
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Setup
    params = ScalingParams(a=-0.34, b=-0.28, c=-0.15, A=1.0, B=2.0, C=3.0)

    # 1. Regime Classification
    print("\n--- Regime Classifier ---")
    classifier = RegimeClassifier(params)
    test_points = [(20, 5, 5), (5, 20, 5), (5, 5, 20), (10, 10, 10)]
    for x, y, z in test_points:
        print(f"  ({x}, {y}, {z}): {classifier.classify(x, y, z)}")

    # 2. Corner Location
    print("\n--- Corner Locator ---")
    locator = CornerLocator(params)
    tp = locator.triple_point()
    if tp:
        print(f"  Triple point: ({tp[0]:.4f}, {tp[1]:.4f}, {tp[2]:.4f})")
        loss = TropicalScalingLoss(params)
        terms = loss.terms(*tp)
        print(f"  Terms at triple point: f_N={terms[0]:.4f}, f_D={terms[1]:.4f}, f_C={terms[2]:.4f}")

    # 3. Pareto Frontier
    print("\n--- Pareto Frontier ---")
    pareto = ParetoFrontier(params)
    for tau in [-1.0, -2.0, -3.0]:
        result = pareto.find_optimal(tau)
        if result:
            regime, x, y, z, cost = result
            print(f"  τ={tau}: Optimal regime={regime}, cost={cost:.2f}, "
                  f"point=({x:.2f}, {y:.2f}, {z:.2f})")

    # 4. Tropical Regression
    print("\n--- Tropical Regression ---")
    np.random.seed(42)
    true_params = ScalingParams(a=-0.3, b=-0.25, c=-0.1, A=1.0, B=1.5, C=2.0)
    true_loss = TropicalScalingLoss(true_params)

    X = np.random.uniform(0, 20, (200, 3))
    L = true_loss.evaluate_batch(X) + np.random.randn(200) * 0.05

    regressor = TropicalRegression()
    fitted = regressor.fit(X, L)
    print(f"  True:   a={true_params.a:.3f}, b={true_params.b:.3f}, c={true_params.c:.3f}")
    print(f"  Fitted: a={fitted.a:.3f}, b={fitted.b:.3f}, c={fitted.c:.3f}")
    print(f"  True:   A={true_params.A:.3f}, B={true_params.B:.3f}, C={true_params.C:.3f}")
    print(f"  Fitted: A={fitted.A:.3f}, B={fitted.B:.3f}, C={fitted.C:.3f}")


if __name__ == "__main__":
    demo_algorithms()
