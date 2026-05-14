#!/usr/bin/env python3
"""
Algorithms for Tropical Grokking Detection

Implements the core algorithms from the tropical grokking framework:
1. Tropical polynomial evaluation and active set computation
2. Corner-locus crossing detection
3. Degeneracy index (order parameter) computation
4. Grokking onset prediction via tropical order parameter monitoring

All algorithms have explicit complexity analysis and type hints.
"""

import numpy as np
from typing import List, Tuple, FrozenSet, Optional
from dataclasses import dataclass


@dataclass
class AffineForm:
    """An affine form w·x + b on R^n.

    Attributes:
        w: Weight vector (linear coefficients)
        b: Bias (constant term)
    """
    w: np.ndarray
    b: float

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine form at x.

        Time complexity: O(n) where n = dim(x)
        """
        return float(np.dot(self.w, x) + self.b)


@dataclass
class TropicalPolynomial:
    """A tropical polynomial: minimum of finitely many affine forms.

    This represents a piecewise-linear convex function, which is the
    fundamental building block of ReLU neural network score functions
    under tropicalization.

    Attributes:
        forms: List of affine forms whose minimum defines the polynomial
    """
    forms: List[AffineForm]

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the tropical polynomial at x.

        Returns min_i (w_i · x + b_i).

        Time complexity: O(m·n) where m = |forms|, n = dim(x)
        """
        return min(f.eval(x) for f in self.forms)

    def active_set(self, x: np.ndarray, tol: float = 1e-10) -> FrozenSet[int]:
        """Compute the active set: indices of forms achieving the minimum.

        Time complexity: O(m·n)
        Space complexity: O(m)

        Args:
            x: Point in parameter space
            tol: Numerical tolerance for equality

        Returns:
            Frozenset of indices of active affine forms
        """
        val = self.eval(x)
        return frozenset(
            i for i, f in enumerate(self.forms)
            if abs(f.eval(x) - val) < tol
        )

    def is_corner_crossing(self, x1: np.ndarray, x2: np.ndarray,
                           tol: float = 1e-10) -> bool:
        """Detect whether the active set changes between x1 and x2.

        A corner crossing indicates that the trajectory has moved from one
        tropical cell to another, which is the geometric signature of a
        phase transition.

        Time complexity: O(m·n)

        Args:
            x1, x2: Two points in parameter space
            tol: Numerical tolerance

        Returns:
            True if the active sets differ (corner crossing detected)
        """
        return self.active_set(x1, tol) != self.active_set(x2, tol)


@dataclass
class TropicalClassifier:
    """A tropical classifier: class scores given by tropical polynomials.

    Each class j has a score function score_j(x) = min_i (w_{j,i} · x + b_{j,i}),
    and the predicted class is argmin_j score_j(x).

    Attributes:
        class_scores: List of tropical polynomials, one per class
    """
    class_scores: List[TropicalPolynomial]

    @property
    def num_classes(self) -> int:
        return len(self.class_scores)

    def scores(self, x: np.ndarray) -> List[float]:
        """Compute all class scores at x.

        Time complexity: O(k·m·n) where k = classes, m = forms/class, n = dim
        """
        return [tp.eval(x) for tp in self.class_scores]

    def predict(self, x: np.ndarray) -> int:
        """Predict the class (argmin of scores).

        Time complexity: O(k·m·n)
        """
        s = self.scores(x)
        return int(np.argmin(s))

    def margin(self, x: np.ndarray, y_true: int) -> float:
        """Compute the decision margin for true class y_true.

        margin(x) = min_{j ≠ y} (score_j(x) - score_y(x))

        Positive margin means correct classification.
        Larger margin means more robust to perturbations.

        Time complexity: O(k·m·n)

        Args:
            x: Point in parameter space
            y_true: Index of the true class

        Returns:
            Decision margin (positive = correct prediction)
        """
        s = self.scores(x)
        return min(s[j] - s[y_true]
                   for j in range(self.num_classes) if j != y_true)

    def degeneracy_index(self, x: np.ndarray, y_true: int,
                         delta: float) -> int:
        """Compute the degeneracy index (tropical order parameter).

        Counts how many competing classes have score within delta of the
        true class. High degeneracy = near decision boundary for multiple classes.

        Φ(x) = |{j ≠ y : score_j(x) - score_y(x) ≤ δ}|

        Time complexity: O(k·m·n)
        Space complexity: O(1)

        Args:
            x: Point in parameter space
            y_true: Index of the true class
            delta: Threshold for "near boundary"

        Returns:
            Number of classes within delta of the decision boundary
        """
        s = self.scores(x)
        return sum(1 for j in range(self.num_classes)
                   if j != y_true and s[j] - s[y_true] <= delta)


def detect_grokking_onset(
    trajectory: List[np.ndarray],
    classifier: TropicalClassifier,
    y_true: int,
    delta: float,
    margin_threshold: float = 0.05
) -> Optional[int]:
    """Detect grokking onset using the tropical order parameter.

    Algorithm:
    1. Compute degeneracy index Φ(θ_t) along the trajectory
    2. Find the first time t where Φ drops strictly
    3. Verify that a margin jump occurs at or after this time

    Time complexity: O(T·k·m·n) where T = trajectory length
    Space complexity: O(T)

    Args:
        trajectory: List of parameter vectors θ_0, θ_1, ..., θ_{T-1}
        classifier: The tropical classifier
        y_true: True class index
        delta: Degeneracy threshold
        margin_threshold: Minimum margin jump to count as grokking

    Returns:
        Time step of grokking onset, or None if not detected
    """
    T = len(trajectory)
    if T < 2:
        return None

    # Phase 1: Compute order parameter along trajectory
    degeneracies = [classifier.degeneracy_index(trajectory[t], y_true, delta)
                    for t in range(T)]

    # Phase 2: Find first strict drop in degeneracy
    onset_candidate = None
    for t in range(T - 1):
        if degeneracies[t + 1] < degeneracies[t]:
            onset_candidate = t
            break

    if onset_candidate is None:
        return None

    # Phase 3: Verify margin jump
    margins = [classifier.margin(trajectory[t], y_true) for t in range(T)]
    for t in range(onset_candidate, T - 1):
        if margins[t + 1] - margins[t] > margin_threshold:
            return t

    return onset_candidate


def detect_corner_crossings(
    trajectory: List[np.ndarray],
    poly: TropicalPolynomial,
    tol: float = 1e-10
) -> List[int]:
    """Find all corner-locus crossings along a trajectory.

    Time complexity: O(T·m·n)
    Space complexity: O(T)

    Args:
        trajectory: List of parameter vectors
        poly: Tropical polynomial whose active sets to monitor
        tol: Numerical tolerance

    Returns:
        List of time steps where corner crossings occur
    """
    crossings = []
    for t in range(len(trajectory) - 1):
        if poly.is_corner_crossing(trajectory[t], trajectory[t + 1], tol):
            crossings.append(t)
    return crossings


def compute_tropical_metrics(
    trajectory: List[np.ndarray],
    classifier: TropicalClassifier,
    y_true: int,
    delta: float
) -> dict:
    """Compute all tropical grokking metrics along a trajectory.

    Returns a dictionary with:
    - margins: List of decision margins
    - degeneracies: List of degeneracy indices
    - active_sets: List of active sets for the true class score
    - corner_crossings: Time steps of corner crossings
    - grokking_onset: Detected grokking onset time (or None)

    Time complexity: O(T·k·m·n)

    Args:
        trajectory: Training trajectory
        classifier: Tropical classifier
        y_true: True class
        delta: Degeneracy threshold

    Returns:
        Dictionary of metrics
    """
    T = len(trajectory)
    true_poly = classifier.class_scores[y_true]

    margins = [classifier.margin(trajectory[t], y_true) for t in range(T)]
    degeneracies = [classifier.degeneracy_index(trajectory[t], y_true, delta)
                    for t in range(T)]
    active_sets_list = [true_poly.active_set(trajectory[t]) for t in range(T)]
    crossings = detect_corner_crossings(trajectory, true_poly)
    onset = detect_grokking_onset(trajectory, classifier, y_true, delta)

    return {
        'margins': margins,
        'degeneracies': degeneracies,
        'active_sets': active_sets_list,
        'corner_crossings': crossings,
        'grokking_onset': onset,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    print("Tropical Grokking Detection Algorithms")
    print("=" * 50)

    # Create a simple 2-class classifier in R^3
    class0 = TropicalPolynomial([
        AffineForm(np.array([1.0, 0.5, 0.2]), -1.0),
        AffineForm(np.array([0.3, 1.0, 0.4]), -0.5),
    ])
    class1 = TropicalPolynomial([
        AffineForm(np.array([0.8, 0.3, 0.5]), -0.8),
        AffineForm(np.array([0.2, 0.7, 0.9]), -0.3),
    ])
    classifier = TropicalClassifier([class0, class1])

    # Generate a trajectory
    T = 40
    trajectory = []
    for t in range(T):
        if t < 25:
            theta = np.array([0.5 + 0.02*t, 0.3 + 0.01*t, 0.1 + 0.005*t])
        else:
            theta = np.array([1.0 + 0.05*(t-25), 0.55 + 0.03*(t-25),
                              0.225 + 0.02*(t-25)])
        trajectory.append(theta)

    # Compute metrics
    metrics = compute_tropical_metrics(trajectory, classifier, y_true=0, delta=0.2)

    print(f"\nTrajectory length: {T}")
    print(f"Corner crossings at: {metrics['corner_crossings']}")
    print(f"Grokking onset at: {metrics['grokking_onset']}")
    print(f"Margin range: [{min(metrics['margins']):.4f}, "
          f"{max(metrics['margins']):.4f}]")
    print(f"Degeneracy range: [{min(metrics['degeneracies'])}, "
          f"{max(metrics['degeneracies'])}]")
