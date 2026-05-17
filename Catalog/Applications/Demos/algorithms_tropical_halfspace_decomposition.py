"""
Algorithms for Tropical Chebyshev Radius Computation

Implements the exact certified robustness radius for tropical affine classifiers
using the min-pairwise-boundary-distance formula.
"""

import numpy as np
from typing import Tuple, Optional, List, Dict
from dataclasses import dataclass


@dataclass
class CertificationResult:
    """Result of certified robustness computation."""
    predicted_class: int
    radius: float
    nearest_competitor: int
    boundary_distances: Dict[int, float]
    scores: np.ndarray
    is_strict_interior: bool


class TropicalAffineClassifier:
    """
    A tropical affine classifier: score_i(x) = a_i + W_i · x.

    Attributes:
        a: Bias vector of shape (m,)
        W: Weight matrix of shape (m, n)
        m: Number of classes
        n: Input dimension
    """

    def __init__(self, a: np.ndarray, W: np.ndarray):
        assert a.ndim == 1 and W.ndim == 2
        assert a.shape[0] == W.shape[0]
        self.a = a.astype(float)
        self.W = W.astype(float)
        self.m, self.n = W.shape

    def score(self, x: np.ndarray) -> np.ndarray:
        """Compute all class scores at point x."""
        return self.a + self.W @ x

    def predict(self, x: np.ndarray) -> int:
        """Return the predicted class (argmax of scores)."""
        return int(np.argmax(self.score(x)))

    def margin_diff(self, i: int, j: int, x: np.ndarray) -> float:
        """Compute score_i(x) - score_j(x)."""
        return float((self.a[i] - self.a[j]) + (self.W[i] - self.W[j]) @ x)

    def row_diff_norm(self, i: int, j: int) -> float:
        """Compute ‖W_i - W_j‖₂."""
        return float(np.linalg.norm(self.W[i] - self.W[j]))

    def boundary_distance(self, i: int, j: int, x0: np.ndarray) -> float:
        """
        Compute the Euclidean distance from x0 to the decision boundary
        between classes i and j.

        Returns infinity if W_i = W_j (parallel hyperplanes).
        """
        norm = self.row_diff_norm(i, j)
        if norm < 1e-15:
            return float('inf')
        return self.margin_diff(i, j, x0) / norm

    def chebyshev_radius(self, x0: np.ndarray) -> CertificationResult:
        """
        Compute the exact Chebyshev radius (certified robustness radius) at x0.

        This implements the main theorem:
            r = min_{j ≠ i} marginDiff(i, j, x0) / ‖W_i - W_j‖

        where i is the predicted class.

        Algorithm:
            1. Compute scores and find predicted class i
            2. For each competitor j ≠ i, compute boundary distance
            3. Return the minimum

        Time complexity: O(m * n) where m = classes, n = dimensions
        Space complexity: O(m + n)
        """
        scores = self.score(x0)
        i = int(np.argmax(scores))

        boundary_dists = {}
        min_dist = float('inf')
        min_j = -1

        for j in range(self.m):
            if j == i:
                continue
            d = self.boundary_distance(i, j, x0)
            boundary_dists[j] = d
            if d < min_dist:
                min_dist = d
                min_j = j

        return CertificationResult(
            predicted_class=i,
            radius=min_dist,
            nearest_competitor=min_j,
            boundary_distances=boundary_dists,
            scores=scores,
            is_strict_interior=all(d > 0 for d in boundary_dists.values())
        )

    def sharpness_witness(self, x0: np.ndarray, epsilon: float = 0.01) -> np.ndarray:
        """
        Construct a point at distance r + epsilon from x0 that leaves the margin cell.

        This is the constructive part of the sharpness theorem.
        """
        cert = self.chebyshev_radius(x0)
        i = cert.predicted_class
        j_star = cert.nearest_competitor
        r = cert.radius

        w = self.W[i] - self.W[j_star]
        v = w / np.linalg.norm(w)  # unit normal direction

        # Move in the negative normal direction by r + epsilon
        return x0 - (r + epsilon) * v

    def certify_batch(self, X: np.ndarray) -> List[CertificationResult]:
        """Certify robustness for a batch of points."""
        return [self.chebyshev_radius(x) for x in X]


def find_chebyshev_center(classifier: TropicalAffineClassifier,
                          target_class: int,
                          x_init: Optional[np.ndarray] = None,
                          max_iter: int = 1000,
                          lr: float = 0.01) -> Tuple[np.ndarray, float]:
    """
    Find the approximate Chebyshev center of a margin cell.

    The Chebyshev center is the point maximizing the certified radius.
    This uses gradient ascent on the minimum margin / norm ratio.

    Args:
        classifier: The tropical affine classifier
        target_class: Which class's margin cell to optimize over
        x_init: Starting point (default: origin)
        max_iter: Maximum iterations
        lr: Learning rate

    Returns:
        (center, radius): The approximate Chebyshev center and its radius
    """
    n = classifier.n
    x = x_init.copy() if x_init is not None else np.zeros(n)

    best_x = x.copy()
    best_r = -float('inf')

    for iteration in range(max_iter):
        scores = classifier.score(x)
        if np.argmax(scores) != target_class:
            # Outside the margin cell, project back
            x = best_x.copy()
            lr *= 0.5
            continue

        # Find the active (nearest) boundary
        min_dist = float('inf')
        min_j = -1
        for j in range(classifier.m):
            if j == target_class:
                continue
            d = classifier.boundary_distance(target_class, j, x)
            if d < min_dist:
                min_dist = d
                min_j = j

        if min_dist > best_r:
            best_r = min_dist
            best_x = x.copy()

        # Gradient: move away from nearest boundary
        w = classifier.W[target_class] - classifier.W[min_j]
        grad = w / np.linalg.norm(w)
        x = x + lr * grad

    return best_x, best_r


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("Tropical Chebyshev Radius Algorithm Demo")
    print("=" * 50)

    # Create a classifier
    np.random.seed(42)
    a = np.array([0.0, -1.0, -0.5, -0.3])
    W = np.array([
        [1.0, 0.5, 0.2],
        [0.3, 1.2, -0.1],
        [-0.5, 0.8, 0.9],
        [0.7, -0.3, 0.6]
    ])

    clf = TropicalAffineClassifier(a, W)
    x0 = np.array([1.0, 0.5, 0.3])

    # Certify
    result = clf.chebyshev_radius(x0)
    print(f"\nPoint: {x0}")
    print(f"Predicted class: {result.predicted_class}")
    print(f"Chebyshev radius: {result.radius:.6f}")
    print(f"Nearest competitor: {result.nearest_competitor}")
    print(f"Strict interior: {result.is_strict_interior}")
    print(f"\nBoundary distances:")
    for j, d in sorted(result.boundary_distances.items()):
        print(f"  Class {j}: {d:.6f}")

    # Sharpness witness
    witness = clf.sharpness_witness(x0, epsilon=0.001)
    scores_witness = clf.score(witness)
    print(f"\nSharpness witness: {witness}")
    print(f"Scores at witness: {scores_witness}")
    print(f"Argmax at witness: {np.argmax(scores_witness)} (should differ from {result.predicted_class})")

    # Find Chebyshev center
    center, max_radius = find_chebyshev_center(clf, result.predicted_class, x_init=x0)
    print(f"\nApproximate Chebyshev center: {center}")
    print(f"Maximum radius: {max_radius:.6f}")
