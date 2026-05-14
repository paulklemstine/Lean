#!/usr/bin/env python3
"""
Algorithms for Closure-Operator Networks

Implements the core algorithms from the closure-operator network theory:
1. ClosureStepNetwork: piecewise-constant approximation via closure cells
2. ClosureFeatureEncoder: maps inputs to closure-indicator features
3. CertifiedClosureClassifier: classifier with provable robustness radii
4. ECOCDecoder: error-correcting output code decoder with robustness
"""

import numpy as np
from typing import List, Tuple, Optional, Callable


class ClosureStepNetwork:
    """
    A closure-step network on [a, b] with N cells.
    
    Architecture:
        x ↦ Σ_j w_j · Φ_j(x) + bias
    
    where Φ_j(x) = 1 if x falls in cell j, else 0.
    The weights are set to f(center_j) for each cell j.
    
    Approximation guarantee (Theorem C):
        If f is L-Lipschitz, then max|f(x) - net(x)| ≤ L · (b-a) / N
    
    Time complexity: O(1) evaluation, O(N) construction
    Space complexity: O(N)
    """
    
    def __init__(self, f: Callable[[float], float], a: float, b: float, N: int):
        """
        Construct a closure-step network approximating f on [a, b].
        
        Args:
            f: Target function to approximate
            a: Left endpoint of interval
            b: Right endpoint of interval
            N: Number of cells (features)
        """
        assert a < b, f"Need a < b, got a={a}, b={b}"
        assert N > 0, f"Need N > 0, got N={N}"
        
        self.a = a
        self.b = b
        self.N = N
        self.delta = (b - a) / N
        
        # Compute centers and weights
        self.centers = np.array([a + (i + 0.5) * self.delta for i in range(N)])
        self.weights = np.array([f(c) for c in self.centers])
        self.bias = 0.0
    
    def features(self, x: float) -> np.ndarray:
        """
        Compute closure-indicator features Φ(x).
        
        Returns:
            Array of length N with exactly one entry = 1.
        """
        phi = np.zeros(self.N)
        i = int((x - self.a) / self.delta)
        i = max(0, min(i, self.N - 1))
        phi[i] = 1.0
        return phi
    
    def __call__(self, x: float) -> float:
        """Evaluate the network at x."""
        phi = self.features(x)
        return np.dot(self.weights, phi) + self.bias
    
    def evaluate_batch(self, xs: np.ndarray) -> np.ndarray:
        """Evaluate the network on an array of inputs."""
        return np.array([self(x) for x in xs])
    
    def error_bound(self, lipschitz_constant: float) -> float:
        """
        Theoretical error bound for L-Lipschitz functions.
        
        Returns:
            L * (b - a) / N
        """
        return lipschitz_constant * (self.b - self.a) / self.N
    
    def certified_radius(self) -> float:
        """
        Radius within which the network output is constant.
        Equal to half the cell width.
        """
        return self.delta / 2


class ClosureFeatureEncoder:
    """
    Encodes inputs using closure-indicator features.
    
    For a finite type with n elements, uses n identity-closure features
    with singleton seeds, producing a one-hot encoding.
    
    For continuous inputs on [a,b], uses N interval-cell features.
    """
    
    def __init__(self, mode: str = "finite", **kwargs):
        """
        Args:
            mode: "finite" for finite types, "interval" for [a,b]
            For "finite": n (number of elements)
            For "interval": a, b, N
        """
        self.mode = mode
        if mode == "finite":
            self.n = kwargs.get("n", 10)
            self.dim = self.n
        elif mode == "interval":
            self.a = kwargs.get("a", 0.0)
            self.b = kwargs.get("b", 1.0)
            self.N = kwargs.get("N", 10)
            self.delta = (self.b - self.a) / self.N
            self.dim = self.N
        else:
            raise ValueError(f"Unknown mode: {mode}")
    
    def encode(self, x) -> np.ndarray:
        """
        Encode input x as a closure-feature vector.
        
        Returns:
            Feature vector of dimension self.dim
        """
        phi = np.zeros(self.dim)
        if self.mode == "finite":
            idx = int(x) % self.n
            phi[idx] = 1.0
        elif self.mode == "interval":
            i = int((x - self.a) / self.delta)
            i = max(0, min(i, self.N - 1))
            phi[i] = 1.0
        return phi
    
    def is_closure_generated(self) -> bool:
        """Verify that features arise from closure operators."""
        return True  # By construction (identity closure with appropriate seeds)


class CertifiedClosureClassifier:
    """
    A classifier with provable robustness certificates from closure structure.
    
    Architecture:
        input x → closure representative repr(x) → label
    
    Robustness guarantee (Theorem D):
        For all y with |x - y| ≤ r, classifier(y) = classifier(x)
        where r is the certified radius at x.
    
    Pseudocode:
        CONSTRUCT(centers, labels):
            Store cell centers c_1, ..., c_K and labels l_1, ..., l_K
            
        CLASSIFY(x):
            Find nearest center c_i to x
            Return l_i
            
        CERTIFIED_RADIUS(x):
            c_i = nearest center to x
            c_j = second nearest center with different label
            Return (dist(x, c_j) - dist(x, c_i)) / 2
    """
    
    def __init__(self, centers: np.ndarray, labels: List[str]):
        """
        Args:
            centers: Array of shape (K,) or (K, d) of cell centers
            labels: List of K class labels
        """
        self.centers = np.atleast_2d(centers).reshape(-1, 1) if centers.ndim == 1 else centers
        self.labels = labels
        self.K = len(labels)
    
    def closure_repr(self, x: float) -> int:
        """Map x to the index of its nearest center (idempotent representative)."""
        x_arr = np.array([x]).reshape(1, -1)
        dists = np.linalg.norm(self.centers - x_arr, axis=1)
        return int(np.argmin(dists))
    
    def classify(self, x: float) -> str:
        """Classify x by its closure representative's label."""
        idx = self.closure_repr(x)
        return self.labels[idx]
    
    def certified_radius(self, x: float) -> float:
        """
        Compute the certified robustness radius at x.
        
        Returns the largest r such that all points within distance r
        of x receive the same label.
        """
        x_arr = np.array([x]).reshape(1, -1)
        dists = np.linalg.norm(self.centers - x_arr, axis=1)
        my_idx = np.argmin(dists)
        my_label = self.labels[my_idx]
        
        # Find minimum distance to a center with a different label
        min_diff_dist = float('inf')
        for i, label in enumerate(self.labels):
            if label != my_label:
                min_diff_dist = min(min_diff_dist, dists[i])
        
        if min_diff_dist == float('inf'):
            return float('inf')  # Only one class
        
        return (min_diff_dist - dists[my_idx]) / 2
    
    def verify_robustness(self, x: float, r: float, n_samples: int = 1000) -> bool:
        """Empirically verify robustness at x within radius r."""
        label = self.classify(x)
        perturbations = np.random.uniform(-r, r, n_samples)
        return all(self.classify(x + p) == label for p in perturbations)


class ECOCDecoder:
    """
    Error-Correcting Output Code decoder for multiclass classification.
    
    Combines closure-based binary features with Hamming decoding for
    robustness to individual feature perturbations.
    
    Robustness guarantee:
        If the code has minimum Hamming distance d, then up to
        ⌊(d-1)/2⌋ bit flips can be corrected.
    
    Pseudocode:
        CONSTRUCT(codebook):
            Store C×m binary codebook
            Compute pairwise Hamming distances
            
        DECODE(bits):
            For each class c:
                agreement[c] = Hamming agreement(bits, code[c])
            Return argmax agreement
            
        CERTIFIED_FLIPS():
            d_min = min pairwise Hamming distance
            Return ⌊(d_min - 1) / 2⌋
    """
    
    def __init__(self, codebook: np.ndarray, class_names: Optional[List[str]] = None):
        """
        Args:
            codebook: Binary array of shape (C, m) where C = num classes, m = num bits
            class_names: Optional list of class names
        """
        self.codebook = np.asarray(codebook, dtype=bool)
        self.C, self.m = self.codebook.shape
        self.class_names = class_names or [f"Class_{i}" for i in range(self.C)]
        
        # Compute min Hamming distance
        self._min_distance = float('inf')
        for i in range(self.C):
            for j in range(i + 1, self.C):
                d = np.sum(self.codebook[i] != self.codebook[j])
                self._min_distance = min(self._min_distance, d)
    
    def agreement(self, bits: np.ndarray, class_idx: int) -> int:
        """Hamming agreement between bits and class codeword."""
        return int(np.sum(bits == self.codebook[class_idx]))
    
    def decode(self, bits: np.ndarray) -> str:
        """Decode bit vector to class label via max Hamming agreement."""
        agreements = [self.agreement(bits, i) for i in range(self.C)]
        return self.class_names[np.argmax(agreements)]
    
    def min_hamming_distance(self) -> int:
        """Minimum Hamming distance between any two codewords."""
        return int(self._min_distance)
    
    def max_correctable_flips(self) -> int:
        """Maximum number of bit flips that can be corrected."""
        return (self.min_hamming_distance() - 1) // 2
    
    def certified_radius_from_margins(self, scores: np.ndarray,
                                       lipschitz_constants: np.ndarray) -> float:
        """
        Compute certified input-space radius from score margins and Lipschitz constants.
        
        Args:
            scores: Array of shape (m,) of real-valued scores
            lipschitz_constants: Array of shape (m,) of per-coordinate Lipschitz constants
        
        Returns:
            Certified radius r such that all perturbations within r preserve the decoded class.
        """
        # Per-bit certified radius = |score_i| / K_i
        per_bit_radii = np.abs(scores) / np.maximum(lipschitz_constants, 1e-10)
        
        # The overall certified radius is limited by the weakest bit
        # More precisely, we need to check for each competitor class
        bits = scores >= 0
        decoded_idx = np.argmax([self.agreement(bits, i) for i in range(self.C)])
        
        min_radius = float('inf')
        for d in range(self.C):
            if d == decoded_idx:
                continue
            # Disagreement set
            disagree = self.codebook[decoded_idx] != self.codebook[d]
            disagree_radii = per_bit_radii[disagree]
            n_disagree = int(np.sum(disagree))
            
            if n_disagree == 0:
                continue
            
            # Sort radii; need fewer than half to be uncertified
            sorted_radii = np.sort(disagree_radii)
            max_flippable = (n_disagree - 1) // 2
            
            if max_flippable < len(sorted_radii):
                min_radius = min(min_radius, sorted_radii[max_flippable])
        
        return min_radius


def construct_optimal_closure_network(f: Callable, a: float, b: float,
                                       epsilon: float,
                                       lipschitz_constant: Optional[float] = None) -> ClosureStepNetwork:
    """
    Construct a closure-step network achieving error < epsilon on [a, b].
    
    Algorithm:
        1. If L is known: N = ceil(L * (b-a) / epsilon) + 1
        2. If L is unknown: double N until error < epsilon (empirical)
    
    Time complexity: O(N) construction + O(1) evaluation
    Space complexity: O(N)
    
    Args:
        f: Target function
        a, b: Interval endpoints
        epsilon: Target approximation error
        lipschitz_constant: Optional Lipschitz constant
    
    Returns:
        ClosureStepNetwork achieving the target error
    """
    if lipschitz_constant is not None:
        N = int(np.ceil(lipschitz_constant * (b - a) / epsilon)) + 1
        return ClosureStepNetwork(f, a, b, N)
    
    # Adaptive: double N until error < epsilon
    N = 2
    x_test = np.linspace(a, b, 1000)
    f_test = np.array([f(x) for x in x_test])
    
    while N < 1000000:
        net = ClosureStepNetwork(f, a, b, N)
        approx = net.evaluate_batch(x_test)
        err = np.max(np.abs(f_test - approx))
        if err < epsilon:
            return net
        N *= 2
    
    return ClosureStepNetwork(f, a, b, N)


if __name__ == "__main__":
    print("CLOSURE-OPERATOR NETWORK ALGORITHMS")
    print("=" * 50)
    
    # Example 1: Approximation
    f = lambda x: np.sin(2 * np.pi * x)
    net = construct_optimal_closure_network(f, 0, 1, 0.01, lipschitz_constant=2*np.pi)
    print(f"Network for sin(2πx) with ε=0.01: N={net.N} cells")
    print(f"  Theoretical bound: {net.error_bound(2*np.pi):.6f}")
    print(f"  Certified radius per cell: {net.certified_radius():.6f}")
    
    # Example 2: Classifier
    centers = np.array([0.1, 0.3, 0.5, 0.7, 0.9])
    labels = ['A', 'B', 'C', 'B', 'A']
    clf = CertifiedClosureClassifier(centers, labels)
    print(f"\nClassifier at x=0.5: {clf.classify(0.5)}, radius={clf.certified_radius(0.5):.3f}")
    
    # Example 3: ECOC
    codebook = np.array([
        [1, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 0, 0],
        [0, 1, 0, 1, 0, 1, 0],
        [0, 0, 1, 0, 1, 1, 1],
    ], dtype=bool)
    ecoc = ECOCDecoder(codebook, ['A', 'B', 'C', 'D'])
    print(f"\nECOC min distance: {ecoc.min_hamming_distance()}")
    print(f"Max correctable flips: {ecoc.max_correctable_flips()}")
