#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Algorithms

Complete implementations of the algorithms from the tropical neural
coding theory framework, with docstrings, type hints, and complexity analysis.
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Optional


class TropicalNeuralCode:
    """
    A tropical neural code: a finite set of firing-rate vectors with
    stimulus labels, equipped with tropical geometric classification.
    
    The code stores:
    - X: an (n, d) array of codewords (firing patterns across d neurons)
    - labels: an (n,) array of stimulus class labels
    
    It computes tropical class margins, global margins, classification
    capacity, and performs certified tropical classification.
    
    Time complexity of construction: O(n)
    Space complexity: O(n * d)
    """
    
    def __init__(self, X: np.ndarray, labels: np.ndarray):
        """
        Initialize a tropical neural code.
        
        Args:
            X: (n, d) array of codeword vectors
            labels: (n,) array of integer labels
        """
        assert X.ndim == 2, "X must be 2D"
        assert len(labels) == len(X), "labels must have same length as X"
        self.X = X.astype(float)
        self.labels = np.asarray(labels)
        self.n, self.d = X.shape
        self.unique_labels = np.unique(labels)
        self.n_classes = len(self.unique_labels)
        self._class_indices: Dict[int, np.ndarray] = {
            k: np.where(labels == k)[0] for k in self.unique_labels
        }
    
    def class_code(self, k: int) -> np.ndarray:
        """
        Return the codewords belonging to class k.
        
        Time: O(1) (precomputed indices)
        """
        return self.X[self._class_indices[k]]
    
    def pairwise_tropical_margin(self, k1: int, k2: int) -> float:
        """
        Compute the tropical class margin between classes k1 and k2.
        
        margin(k1, k2) = min_{a in C(k1)} min_{b in C(k2)} max_i (a_i - b_i)
        
        Time: O(|C(k1)| * |C(k2)| * d)
        Space: O(1) beyond input
        
        Args:
            k1: first class label
            k2: second class label
        
        Returns:
            The tropical class margin (float).
        """
        A = self.class_code(k1)
        B = self.class_code(k2)
        if len(A) == 0 or len(B) == 0:
            return 0.0
        # Vectorized: for each (a, b) pair, compute max_i(a_i - b_i)
        # Shape: (|A|, |B|, d) -> (|A|, |B|) -> scalar
        diffs = A[:, np.newaxis, :] - B[np.newaxis, :, :]  # (nA, nB, d)
        max_gaps = np.max(diffs, axis=2)  # (nA, nB)
        return float(np.min(max_gaps))
    
    def global_margin(self) -> float:
        """
        Compute the global tropical margin: minimum over all distinct
        class pairs of the pairwise tropical margin.
        
        Time: O(K^2 * n^2 * d / K^2) = O(n^2 * d) where K = number of classes
        Space: O(max_class_size * d)
        
        Returns:
            The global tropical margin (float).
        """
        if self.n_classes < 2:
            return 0.0
        return min(
            self.pairwise_tropical_margin(k1, k2)
            for k1, k2 in combinations(self.unique_labels, 2)
        )
    
    def classification_capacity(self) -> int:
        """
        The classification capacity: number of distinct realizable labels.
        
        Time: O(1) (precomputed)
        """
        return self.n_classes
    
    def capacity_bound(self) -> Tuple[int, int]:
        """
        Return (capacity, code_size) witnessing capacity <= code_size.
        
        Time: O(1)
        """
        return self.n_classes, self.n
    
    def classify(self, x: np.ndarray) -> Tuple[int, float]:
        """
        Classify observation x using tropical nearest-prototype scoring.
        
        The tropical score of x against class k is:
            score(x, k) = min_{a in C(k)} max_i (a_i - x_i)
        
        Returns the label k minimizing score(x, k) and the margin
        (gap to the second-best class).
        
        Time: O(n * d)
        Space: O(K)
        
        Args:
            x: (d,) observation vector
        
        Returns:
            (predicted_label, margin) where margin > 0 means certified.
        """
        scores = {}
        for k in self.unique_labels:
            ck = self.class_code(k)
            scores[k] = min(float(np.max(a - x)) for a in ck)
        
        sorted_scores = sorted(scores.items(), key=lambda p: p[1])
        best_label = sorted_scores[0][0]
        margin = sorted_scores[1][1] - sorted_scores[0][1] if len(sorted_scores) > 1 else float('inf')
        return int(best_label), margin
    
    def margin_matrix(self) -> np.ndarray:
        """
        Compute the full K x K matrix of pairwise tropical margins.
        
        M[i,j] = tropical_class_margin(C(labels[i]), C(labels[j]))
        Diagonal entries are 0.
        
        Time: O(K^2 * max_class_size^2 * d)
        Space: O(K^2)
        
        Returns:
            (K, K) array of pairwise margins.
        """
        K = self.n_classes
        M = np.zeros((K, K))
        for i, k1 in enumerate(self.unique_labels):
            for j, k2 in enumerate(self.unique_labels):
                if i != j:
                    M[i, j] = self.pairwise_tropical_margin(k1, k2)
        return M
    
    def is_certifiably_separated(self) -> bool:
        """
        Check whether all class pairs have positive tropical margin.
        
        Time: O(n^2 * d) worst case, but short-circuits on first failure.
        """
        for k1, k2 in combinations(self.unique_labels, 2):
            if self.pairwise_tropical_margin(k1, k2) <= 0:
                return False
        return True
    
    def separating_coordinates(self, k1: int, k2: int) -> List[int]:
        """
        Find coordinates that contribute to separation between classes.
        
        A coordinate i is 'separating' if for some pair (a, b) with
        a in C(k1), b in C(k2), the gap a_i - b_i equals the max gap.
        
        Time: O(|C(k1)| * |C(k2)| * d)
        
        Returns:
            List of coordinate indices that witness separation.
        """
        A = self.class_code(k1)
        B = self.class_code(k2)
        sep_coords = set()
        for a in A:
            for b in B:
                gaps = a - b
                max_gap = np.max(gaps)
                for i in range(self.d):
                    if gaps[i] == max_gap:
                        sep_coords.add(i)
        return sorted(sep_coords)


def coboundary_margin_bound(
    local_margins: np.ndarray,
    lipschitz_constants: np.ndarray,
    gauge_corrections: np.ndarray
) -> float:
    """
    Compute the global adjusted margin from coboundary conditions.
    
    Given local margin certificates m_i, Lipschitz constants L_i,
    and gauge corrections b_i satisfying L_i * |b_i| <= m_i,
    the global adjusted margin is:
    
        δ = min_i (m_i - L_i * |b_i|) / L_i
    
    This is the tropical margin lower bound derived from coboundary
    consistency of local robustness witnesses.
    
    Algorithm:
        1. Compute adjusted margins: (m_i - L_i * |b_i|) / L_i
        2. Return the minimum.
    
    Time: O(n) where n = number of local regions
    Space: O(n)
    
    Args:
        local_margins: (n,) array of local margin certificates m_i >= 0
        lipschitz_constants: (n,) array of Lipschitz constants L_i > 0
        gauge_corrections: (n,) array of gauge corrections b_i
    
    Returns:
        The global adjusted margin δ >= 0.
    """
    adjusted = (local_margins - lipschitz_constants * np.abs(gauge_corrections)) / lipschitz_constants
    return float(np.min(adjusted))


def tropical_decision_regions(
    code: TropicalNeuralCode,
    grid_points: np.ndarray
) -> np.ndarray:
    """
    Compute tropical decision region assignments for a grid of points.
    
    For each point in grid_points, determine which class has the
    lowest tropical score (nearest in tropical metric).
    
    Time: O(|grid| * n * d)
    Space: O(|grid|)
    
    Args:
        code: a TropicalNeuralCode instance
        grid_points: (m, d) array of points to classify
    
    Returns:
        (m,) array of predicted labels.
    """
    predictions = np.empty(len(grid_points), dtype=int)
    for idx, x in enumerate(grid_points):
        predictions[idx] = code.classify(x)[0]
    return predictions


# ==========================================================================
# Example usage
# ==========================================================================
if __name__ == "__main__":
    print("Tropical Neural Code — Algorithm Demonstrations")
    print("=" * 60)
    
    # Create a sample code
    X = np.array([
        [10, 1, 3], [9, 2, 3],      # class 0
        [1, 10, 3], [2, 9, 4],      # class 1
        [3, 3, 10], [4, 2, 9],      # class 2
    ], dtype=float)
    labels = np.array([0, 0, 1, 1, 2, 2])
    
    code = TropicalNeuralCode(X, labels)
    
    print(f"\nCode: {code.n} codewords, {code.d} neurons, {code.n_classes} classes")
    print(f"Classification capacity: {code.classification_capacity()}")
    cap, size = code.capacity_bound()
    print(f"Capacity bound: {cap} ≤ {size}")
    print(f"Global tropical margin: {code.global_margin():.4f}")
    print(f"Certifiably separated: {code.is_certifiably_separated()}")
    
    print(f"\nMargin matrix:")
    M = code.margin_matrix()
    for i, k in enumerate(code.unique_labels):
        row = " ".join(f"{M[i,j]:8.2f}" for j in range(code.n_classes))
        print(f"  class {k}: {row}")
    
    # Classify test points
    test_points = np.array([
        [8, 2, 3],
        [2, 8, 3],
        [3, 3, 8],
        [5, 5, 5],
    ])
    print(f"\nClassification of test points:")
    for x in test_points:
        label, margin = code.classify(x)
        cert = "certified" if margin > 0 else "uncertain"
        print(f"  {x} -> class {label} (margin={margin:.2f}, {cert})")
    
    # Coboundary margin bound
    print(f"\nCoboundary margin bound example:")
    m = np.array([2.0, 3.0, 1.5])
    L = np.array([1.0, 1.0, 1.0])
    b = np.array([0.5, 1.0, 0.3])
    delta = coboundary_margin_bound(m, L, b)
    print(f"  Local margins: {m}")
    print(f"  Lipschitz constants: {L}")
    print(f"  Gauge corrections: {b}")
    print(f"  Global adjusted margin δ = {delta:.4f}")
    
    # Separating coordinates
    print(f"\nSeparating coordinates:")
    for k1, k2 in combinations(range(3), 2):
        coords = code.separating_coordinates(k1, k2)
        print(f"  Classes {k1} vs {k2}: neurons {coords}")
    
    print(f"\nAll algorithm demonstrations completed.")
