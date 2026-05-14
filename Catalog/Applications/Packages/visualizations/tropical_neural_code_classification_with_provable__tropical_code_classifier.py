#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Algorithms

Implements the core algorithms for tropical code classification:
1. TropicalCodeClassifier — certified binary/multiclass classifier
2. DominancePartition — finite combinatorial quotient computation
3. CoboundaryMarginEstimator — margin transfer from local certificates
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple, Set

# ═══════════════════════════════════════════════════════════
# Algorithm 1: Tropical Code Classifier
# ═══════════════════════════════════════════════════════════

@dataclass
class TropicalCodeClassifier:
    """
    Certified binary or multiclass classifier using tropical geometry.

    Given codebooks for each class, classifies inputs by comparing
    tropical generator scores (max over generators of min coordinatewise gap).

    Complexity:
    - Training: O(K * |C_k| * n) where K = number of classes
    - Prediction: O(K * max|C_k| * n) per input
    - Certification: O(K^2 * max|C_k|^2 * n) for pairwise margins

    Attributes:
        codebooks: Dict mapping labels to arrays of shape (num_generators, n)
        margins: Pairwise separation margins (computed lazily)
    """
    codebooks: Dict[str, np.ndarray] = field(default_factory=dict)
    margins: Dict[Tuple[str, str], float] = field(default_factory=dict)

    def add_class(self, label: str, generators: np.ndarray):
        """Add a class with its codebook of generators.

        Args:
            label: Class name
            generators: Array of shape (num_generators, n)
        """
        self.codebooks[label] = np.array(generators)
        self.margins.clear()  # invalidate cached margins

    def _coord_gap(self, x: np.ndarray, s: np.ndarray) -> float:
        """min_i (x_i - s_i)"""
        return float(np.min(x - s))

    def score(self, x: np.ndarray, label: str) -> float:
        """Tropical generator score of x against class `label`.

        score(x, label) = max_{s in C_label} min_i (x_i - s_i)
        """
        C = self.codebooks[label]
        if len(C) == 0:
            return 0.0
        return float(max(self._coord_gap(x, s) for s in C))

    def predict(self, x: np.ndarray) -> str:
        """Classify x by argmax of tropical scores.

        Returns:
            Label of the class with highest tropical score.
        """
        return max(self.codebooks.keys(), key=lambda l: self.score(x, l))

    def predict_with_scores(self, x: np.ndarray) -> Dict[str, float]:
        """Return all class scores for input x."""
        return {label: self.score(x, label) for label in self.codebooks}

    def pairwise_margin(self, label_a: str, label_b: str) -> float:
        """Compute separation margin between two classes.

        margin(A, B) = min_{a in A, b in B} max_i (a_i - b_i)

        A positive margin guarantees classification robustness.
        """
        key = (label_a, label_b)
        if key not in self.margins:
            A, B = self.codebooks[label_a], self.codebooks[label_b]
            margin = float('inf')
            for a in A:
                for b in B:
                    margin = min(margin, float(np.max(a - b)))
            self.margins[key] = margin
        return self.margins[key]

    def certified_radius(self, x: np.ndarray) -> Tuple[str, float]:
        """Compute the certified classification with perturbation radius.

        Returns:
            (predicted_label, certified_radius) where classification is
            guaranteed correct for all perturbations of L∞ size < radius.
        """
        scores = self.predict_with_scores(x)
        sorted_labels = sorted(scores.keys(), key=lambda l: scores[l], reverse=True)
        best = sorted_labels[0]
        if len(sorted_labels) < 2:
            return best, float('inf')
        second_best = sorted_labels[1]
        gap = scores[best] - scores[second_best]
        return best, gap / 2

    def minimum_separation(self) -> float:
        """Minimum pairwise separation margin across all class pairs."""
        labels = list(self.codebooks.keys())
        min_margin = float('inf')
        for i in range(len(labels)):
            for j in range(i + 1, len(labels)):
                m = self.pairwise_margin(labels[i], labels[j])
                min_margin = min(min_margin, m)
        return min_margin


# ═══════════════════════════════════════════════════════════
# Algorithm 2: Dominance Pattern Partition
# ═══════════════════════════════════════════════════════════

@dataclass
class DominancePartition:
    """
    Computes the finite dominance pattern partition of input space.

    For each input x and generator s, the dominance signature records
    the coordinatewise ordering of gaps x_i - s_i. This induces a finite
    partition of ℝ^n with at most (n!)^|C| cells.

    Complexity:
    - Signature computation: O(|C| * n^2) per input
    - Partition enumeration: O(N * |C| * n^2) for N sample points
    """
    codebook: np.ndarray  # shape (num_generators, n)

    def signature(self, x: np.ndarray) -> tuple:
        """Compute the dominance signature of x.

        For each generator s, records the ordering of coordinates
        by gap x_i - s_i. Returns a hashable tuple.
        """
        sigs = []
        for s in self.codebook:
            gaps = x - s
            # Record pairwise ordering
            n = len(x)
            ordering = tuple(
                int(gaps[i] >= gaps[j])
                for i in range(n) for j in range(n)
            )
            sigs.append(ordering)
        return tuple(sigs)

    def partition_samples(self, points: np.ndarray) -> Dict[int, List[int]]:
        """Partition sample points by dominance signature.

        Args:
            points: Array of shape (num_points, n)

        Returns:
            Dict mapping cell_id to list of point indices.
        """
        sig_to_id: Dict[tuple, int] = {}
        partition: Dict[int, List[int]] = {}

        for idx, x in enumerate(points):
            sig = self.signature(x)
            if sig not in sig_to_id:
                sig_to_id[sig] = len(sig_to_id)
            cell_id = sig_to_id[sig]
            if cell_id not in partition:
                partition[cell_id] = []
            partition[cell_id].append(idx)

        return partition

    def count_cells(self, points: np.ndarray) -> int:
        """Count the number of distinct dominance cells observed."""
        return len(self.partition_samples(points))

    def classification_capacity(self, points: np.ndarray) -> int:
        """Upper bound on classification capacity from observed cells."""
        return self.count_cells(points)


# ═══════════════════════════════════════════════════════════
# Algorithm 3: Coboundary Margin Estimator
# ═══════════════════════════════════════════════════════════

@dataclass
class CoboundaryMarginEstimator:
    """
    Estimates the global adjusted margin from local margin certificates
    and coboundary gauge corrections.

    Given:
    - m[i]: local margin at region i
    - L[i]: Lipschitz constant at region i
    - b[i]: gauge correction (coboundary primitive) at region i

    Computes:
    - adjusted_margin[i] = (m[i] - L[i] * |b[i]|) / L[i]
    - global_margin = min_i adjusted_margin[i]

    Complexity: O(K) where K = number of regions.
    """
    margins: np.ndarray      # local margins m[i]
    lipschitz: np.ndarray     # Lipschitz constants L[i]
    gauge: np.ndarray         # gauge corrections b[i]

    def check_coboundary_condition(self) -> bool:
        """Check if L[i] * |b[i]| <= m[i] for all i."""
        return bool(np.all(self.lipschitz * np.abs(self.gauge) <= self.margins))

    def adjusted_margins(self) -> np.ndarray:
        """Compute adjusted margins for each region."""
        return (self.margins - self.lipschitz * np.abs(self.gauge)) / self.lipschitz

    def global_margin(self) -> float:
        """Compute the global adjusted margin (minimum of local)."""
        return float(np.min(self.adjusted_margins()))

    def critical_region(self) -> int:
        """Return the index of the region with smallest adjusted margin."""
        return int(np.argmin(self.adjusted_margins()))

    def summary(self) -> str:
        """Human-readable summary of the margin analysis."""
        adj = self.adjusted_margins()
        lines = [
            f"Coboundary Margin Analysis ({len(self.margins)} regions)",
            "-" * 50,
        ]
        for i in range(len(self.margins)):
            lines.append(
                f"  Region {i}: m={self.margins[i]:.3f}, L={self.lipschitz[i]:.3f}, "
                f"|b|={abs(self.gauge[i]):.3f}, adj={adj[i]:.4f}"
            )
        lines.append(f"\nCoboundary condition: {'✓' if self.check_coboundary_condition() else '✗'}")
        lines.append(f"Global margin δ = {self.global_margin():.4f}")
        lines.append(f"Critical region: {self.critical_region()}")
        return "\n".join(lines)


# ═══════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("Tropical Code Classifier — Example")
    print("=" * 60)

    clf = TropicalCodeClassifier()
    clf.add_class("cat", np.array([[5, 3, 1], [4.5, 3.5, 1.5]]))
    clf.add_class("dog", np.array([[1, 2, 4], [1.5, 1.5, 3.5]]))

    test_points = [
        np.array([4.8, 3.2, 1.2]),
        np.array([1.2, 1.8, 3.8]),
        np.array([3.0, 2.5, 2.5]),
    ]

    for x in test_points:
        label, radius = clf.certified_radius(x)
        scores = clf.predict_with_scores(x)
        print(f"\nx = {x}")
        print(f"  Scores: {scores}")
        print(f"  Prediction: {label} (certified radius: {radius:.3f})")

    print(f"\nMinimum separation: {clf.minimum_separation():.3f}")

    print("\n" + "=" * 60)
    print("Dominance Partition — Example")
    print("=" * 60)

    C = np.array([[1.0, 3.0], [3.0, 1.0], [2.0, 2.0]])
    dp = DominancePartition(C)

    np.random.seed(42)
    points = np.random.uniform(-5, 8, (5000, 2))
    n_cells = dp.count_cells(points)
    print(f"\nCodebook: {len(C)} generators in R^2")
    print(f"Observed dominance cells (5000 samples): {n_cells}")
    print(f"Classification capacity bound: {n_cells}")

    print("\n" + "=" * 60)
    print("Coboundary Margin Estimator — Example")
    print("=" * 60)

    estimator = CoboundaryMarginEstimator(
        margins=np.array([1.0, 0.8, 1.2]),
        lipschitz=np.array([2.0, 1.5, 2.5]),
        gauge=np.array([0.1, 0.2, 0.15])
    )
    print(f"\n{estimator.summary()}")
