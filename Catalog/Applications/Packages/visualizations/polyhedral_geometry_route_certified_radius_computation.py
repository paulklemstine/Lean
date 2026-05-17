#!/usr/bin/env python3
"""
Algorithms for Tropical Polyhedral Robustness Certification

Implements the core algorithms from the research:
1. Certified radius computation for tropical/ReLU classifiers
2. Active facet identification
3. Boundary distance computation
4. Multi-class robustness verification
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class AffineForm:
    """An affine form ℓ(x) = a · x + b on ℝⁿ."""
    a: np.ndarray  # normal vector
    b: float       # bias

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate ℓ(x) = a · x + b."""
        return float(np.dot(self.a, x) + self.b)


@dataclass
class TropicalClassifier:
    """A tropical (max-affine) classifier f(x) = max_i ℓ_i(x).

    The classifier assigns to each input x the class k that maximizes
    the affine score ℓ_k(x) = a_k · x + b_k.

    Attributes:
        forms: List of affine forms, one per class.

    Complexity:
        - classify: O(n · |ι|) where n = dim, |ι| = number of classes
        - certified_radius: O(n · |ι|)
        - active_facet: O(n · |ι|)
    """

    forms: List[AffineForm]

    @property
    def n_classes(self) -> int:
        return len(self.forms)

    @property
    def dim(self) -> int:
        return len(self.forms[0].a)

    def scores(self, x: np.ndarray) -> np.ndarray:
        """Compute all affine scores at x.

        Time complexity: O(n · |ι|)
        """
        return np.array([f.evaluate(x) for f in self.forms])

    def classify(self, x: np.ndarray) -> int:
        """Return the winning class index.

        Time complexity: O(n · |ι|)
        """
        return int(np.argmax(self.scores(x)))

    def margin(self, x: np.ndarray, k: int) -> float:
        """Compute the raw margin: min_{j≠k} (ℓ_k(x) - ℓ_j(x)).

        Time complexity: O(n · |ι|)
        """
        s = self.scores(x)
        gaps = [s[k] - s[j] for j in range(self.n_classes) if j != k]
        return min(gaps) if gaps else float('inf')

    def normalized_margin(self, x: np.ndarray, k: int, j: int) -> float:
        """Compute the normalized margin for class k vs competitor j:
        (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖.

        This equals the distance from x to the tie hyperplane ℓ_k = ℓ_j.

        Time complexity: O(n)
        """
        gap = self.forms[k].evaluate(x) - self.forms[j].evaluate(x)
        normal_diff = self.forms[k].a - self.forms[j].a
        norm = np.linalg.norm(normal_diff)
        if norm < 1e-15:
            return float('inf') if gap >= 0 else float('-inf')
        return gap / norm

    def certified_radius(self, x: np.ndarray, k: Optional[int] = None) -> float:
        """Compute the certified robustness radius at x for class k.

        If k is None, uses the current winning class.

        The certified radius is:
            r(x) = min_{j≠k} (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖

        Any perturbation y with ‖y - x‖ < r(x) is guaranteed to have
        the same classification as x.

        Time complexity: O(n · |ι|)
        Space complexity: O(|ι|)

        Returns:
            float: The certified radius. Positive iff k strictly wins at x.
        """
        if k is None:
            k = self.classify(x)
        margins = []
        for j in range(self.n_classes):
            if j != k:
                margins.append(self.normalized_margin(x, k, j))
        return min(margins) if margins else float('inf')

    def active_facet(self, x: np.ndarray, k: Optional[int] = None) -> Tuple[int, float]:
        """Identify the active (nearest) facet of the tropical cell.

        The active facet corresponds to the competitor class j* that minimizes
        the normalized margin, i.e., the nearest tie hyperplane.

        Time complexity: O(n · |ι|)

        Returns:
            (j*, dist): The competitor index and the distance to its tie hyperplane.
        """
        if k is None:
            k = self.classify(x)
        best_j = -1
        best_dist = float('inf')
        for j in range(self.n_classes):
            if j != k:
                d = self.normalized_margin(x, k, j)
                if d < best_dist:
                    best_dist = d
                    best_j = j
        return best_j, best_dist

    def nearest_boundary_point(self, x: np.ndarray, k: Optional[int] = None) -> np.ndarray:
        """Compute the nearest point on the tropical cell boundary.

        Projects x onto the nearest tie hyperplane ℓ_k = ℓ_{j*}.

        Time complexity: O(n · |ι|)
        """
        if k is None:
            k = self.classify(x)
        j, _ = self.active_facet(x, k)

        # Project onto hyperplane ⟨a_k - a_j, y⟩ = b_j - b_k
        u = self.forms[k].a - self.forms[j].a
        c = self.forms[j].b - self.forms[k].b
        inner_ux = np.dot(u, x)
        t = (c - inner_ux) / np.dot(u, u)
        return x + t * u

    def lipschitz_certificate(self, x: np.ndarray, k: Optional[int] = None) -> float:
        """Compute the global Lipschitz robustness certificate.

        Uses the formula: margin / (2 * K) where K = max_{i≠j} ‖a_i - a_j‖.

        This is the baseline certificate that our polyhedral certificate improves upon.

        Time complexity: O(n · |ι|²)
        """
        if k is None:
            k = self.classify(x)
        K = max(
            np.linalg.norm(self.forms[i].a - self.forms[j].a)
            for i in range(self.n_classes)
            for j in range(self.n_classes)
            if i != j
        )
        margin = self.margin(x, k)
        return margin / (2 * K) if K > 0 else float('inf')

    def verify_robustness(self, x: np.ndarray, epsilon: float,
                          n_samples: int = 10000) -> Dict:
        """Empirically verify robustness within an ε-ball.

        Time complexity: O(n_samples · n · |ι|)

        Returns:
            Dict with verification results.
        """
        k = self.classify(x)
        r = self.certified_radius(x, k)

        violations = 0
        for _ in range(n_samples):
            direction = np.random.randn(self.dim)
            direction /= np.linalg.norm(direction)
            delta = direction * epsilon
            y = x + delta
            if self.classify(y) != k:
                violations += 1

        return {
            'point': x,
            'class': k,
            'certified_radius': r,
            'test_epsilon': epsilon,
            'n_samples': n_samples,
            'violations': violations,
            'certified': epsilon <= r,
            'empirical_robust': violations == 0,
        }


def batch_certify(classifier: TropicalClassifier,
                  points: np.ndarray) -> np.ndarray:
    """Compute certified radii for a batch of points.

    Algorithm:
        For each point x_i:
            1. Classify x_i → k_i
            2. For each j ≠ k_i, compute normalized margin
            3. Take minimum → r_i

    Time complexity: O(N · n · |ι|) where N = number of points
    Space complexity: O(N)

    Args:
        classifier: TropicalClassifier instance
        points: (N, n) array of input points

    Returns:
        (N,) array of certified radii
    """
    radii = np.zeros(len(points))
    for i, x in enumerate(points):
        k = classifier.classify(x)
        radii[i] = classifier.certified_radius(x, k)
    return radii


def construct_from_relu_layer(W: np.ndarray, bias: np.ndarray) -> TropicalClassifier:
    """Construct a tropical classifier from a single ReLU layer.

    A single linear layer followed by comparison gives a tropical classifier
    where the affine forms are the rows of the weight matrix.

    Args:
        W: (|ι|, n) weight matrix
        bias: (|ι|,) bias vector

    Returns:
        TropicalClassifier
    """
    forms = [AffineForm(a=W[i], b=float(bias[i])) for i in range(len(W))]
    return TropicalClassifier(forms=forms)


# Example usage
if __name__ == "__main__":
    # Create a 3-class classifier in ℝ²
    classifier = TropicalClassifier(forms=[
        AffineForm(a=np.array([2.0, 1.0]), b=0.0),
        AffineForm(a=np.array([-1.0, 2.0]), b=1.0),
        AffineForm(a=np.array([0.0, -1.0]), b=3.0),
    ])

    x = np.array([2.0, 0.5])
    k = classifier.classify(x)
    r = classifier.certified_radius(x, k)
    j_star, d_star = classifier.active_facet(x, k)
    r_lip = classifier.lipschitz_certificate(x, k)

    print(f"Classifier: 3 classes in ℝ²")
    print(f"Point x = {x}")
    print(f"Winning class: {k}")
    print(f"Certified radius (polyhedral): {r:.4f}")
    print(f"Certified radius (Lipschitz):  {r_lip:.4f}")
    print(f"Improvement: {r/r_lip:.2f}×")
    print(f"Active facet: class {j_star} at distance {d_star:.4f}")
    print(f"Nearest boundary point: {classifier.nearest_boundary_point(x, k)}")

    # Batch certification
    np.random.seed(42)
    points = np.random.randn(100, 2) * 2
    radii = batch_certify(classifier, points)
    print(f"\nBatch certification of 100 random points:")
    print(f"  Mean certified radius: {np.mean(radii):.4f}")
    print(f"  Min certified radius:  {np.min(radii):.4f}")
    print(f"  Max certified radius:  {np.max(radii):.4f}")
