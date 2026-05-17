#!/usr/bin/env python3
"""
algorithms.py — Certified Robustness via Tropical Polyhedral Geometry

Implements algorithms for computing exact polyhedral robustness certificates
for piecewise-affine (ReLU/tropical) classifiers.

Key Algorithms:
1. PolyhedralCertifier — computes certified radius from affine score data
2. TropicalCellDecomposer — identifies active cell and facet structure
3. BoundaryDistanceComputer — exact distance to cell boundary
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Optional, Tuple
import time


@dataclass
class RobustnessCertificate:
    """A certified robustness certificate for a tropical classifier."""
    point: np.ndarray
    predicted_class: int
    certified_radius: float
    active_facet: Optional[int]  # competitor achieving the minimum
    margin: float  # raw score gap to nearest competitor
    normalized_margins: dict  # {competitor: gap / ||normal||}
    lipschitz_radius: float  # baseline Lipschitz certificate for comparison


@dataclass
class TropicalCell:
    """Representation of a tropical cell as a polyhedron."""
    index: int
    normals: List[np.ndarray]  # a_k - a_j for each competitor j
    offsets: List[float]       # b_k - b_j for each competitor j
    competitors: List[int]     # indices of competitors
    
    def contains(self, x: np.ndarray) -> bool:
        """Check membership: all halfspace constraints satisfied."""
        return all(np.dot(n, x) >= o - 1e-12 
                   for n, o in zip(self.normals, self.offsets))
    
    def is_strictly_interior(self, x: np.ndarray) -> bool:
        """Check strict interior: all constraints strictly satisfied."""
        return all(np.dot(n, x) > o + 1e-12 
                   for n, o in zip(self.normals, self.offsets))


class PolyhedralCertifier:
    """
    Computes polyhedral robustness certificates for tropical classifiers.
    
    Given affine score functions ℓ_i(x) = ⟪a_i, x⟫ + b_i, computes the
    exact certified radius at any point using the normalized margin formula:
    
        r(x) = min_{j ≠ k} (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖
    
    Time complexity: O(n_classes * n_features) per point
    Space complexity: O(n_classes * n_features) for weight storage
    
    This is provably at least as sharp as the global Lipschitz certificate
    r_lip(x) = margin(x) / (2K), and often significantly sharper.
    """
    
    def __init__(self, weights: np.ndarray, biases: np.ndarray):
        """
        Args:
            weights: (n_classes, n_features) array of weight vectors a_i
            biases: (n_classes,) array of bias terms b_i
        """
        self.weights = np.asarray(weights, dtype=np.float64)
        self.biases = np.asarray(biases, dtype=np.float64)
        self.n_classes = weights.shape[0]
        self.n_features = weights.shape[1]
        
        # Precompute pairwise normal vectors and their norms
        self._normal_norms = np.zeros((self.n_classes, self.n_classes))
        for i in range(self.n_classes):
            for j in range(self.n_classes):
                if i != j:
                    self._normal_norms[i, j] = np.linalg.norm(
                        self.weights[i] - self.weights[j])
        
        # Global Lipschitz constant
        self._K = max(np.linalg.norm(self.weights[i]) 
                      for i in range(self.n_classes))
    
    def scores(self, x: np.ndarray) -> np.ndarray:
        """Compute all affine scores at x."""
        return self.weights @ x + self.biases
    
    def predict(self, x: np.ndarray) -> int:
        """Return predicted class (argmax of scores)."""
        return int(np.argmax(self.scores(x)))
    
    def certify(self, x: np.ndarray) -> RobustnessCertificate:
        """
        Compute the full robustness certificate at point x.
        
        Returns a RobustnessCertificate with the polyhedral certified radius,
        the active facet (nearest competitor), and comparison with Lipschitz.
        
        Complexity: O(n_classes * n_features)
        """
        s = self.scores(x)
        k = int(np.argmax(s))
        
        min_normalized_margin = float('inf')
        active_facet = None
        raw_margin = float('inf')
        normalized_margins = {}
        
        for j in range(self.n_classes):
            if j == k:
                continue
            gap = s[k] - s[j]
            raw_margin = min(raw_margin, gap)
            
            norm_diff = self._normal_norms[k, j]
            if norm_diff < 1e-15:
                if gap < -1e-12:
                    return RobustnessCertificate(
                        point=x.copy(), predicted_class=k,
                        certified_radius=0.0, active_facet=j,
                        margin=gap, normalized_margins={},
                        lipschitz_radius=0.0)
                continue
            
            nm = gap / norm_diff
            normalized_margins[j] = nm
            if nm < min_normalized_margin:
                min_normalized_margin = nm
                active_facet = j
        
        lip_radius = raw_margin / (2 * self._K) if self._K > 0 else float('inf')
        
        return RobustnessCertificate(
            point=x.copy(),
            predicted_class=k,
            certified_radius=max(0, min_normalized_margin),
            active_facet=active_facet,
            margin=raw_margin,
            normalized_margins=normalized_margins,
            lipschitz_radius=lip_radius
        )
    
    def get_cell(self, k: int) -> TropicalCell:
        """Return the TropicalCell object for class k."""
        normals = []
        offsets = []
        competitors = []
        for j in range(self.n_classes):
            if j == k:
                continue
            normals.append(self.weights[k] - self.weights[j])
            offsets.append(self.biases[k] - self.biases[j])
            competitors.append(j)
        return TropicalCell(k, normals, offsets, competitors)
    
    def batch_certify(self, X: np.ndarray) -> List[RobustnessCertificate]:
        """
        Certify a batch of points.
        
        Complexity: O(n_points * n_classes * n_features)
        """
        return [self.certify(X[i]) for i in range(X.shape[0])]


class BoundaryDistanceComputer:
    """
    Computes exact distances to tropical cell boundaries.
    
    For each competitor j ≠ k, the tie hyperplane {y | ℓ_j(y) = ℓ_k(y)}
    has exact distance formula:
    
        d_j(x) = |ℓ_k(x) - ℓ_j(x)| / ‖a_k - a_j‖
    
    The distance to the full boundary is min_j d_j(x).
    """
    
    def __init__(self, certifier: PolyhedralCertifier):
        self.certifier = certifier
    
    def facet_distances(self, x: np.ndarray, k: int) -> dict:
        """
        Compute distance from x to each facet of cell C_k.
        
        Returns: dict mapping competitor index j to distance d_j(x)
        """
        s = self.certifier.scores(x)
        distances = {}
        for j in range(self.certifier.n_classes):
            if j == k:
                continue
            gap = abs(s[k] - s[j])
            norm_diff = self.certifier._normal_norms[k, j]
            if norm_diff > 1e-15:
                distances[j] = gap / norm_diff
        return distances
    
    def nearest_boundary_point(self, x: np.ndarray, k: int, j: int) -> np.ndarray:
        """
        Project x onto the tie hyperplane ℓ_k = ℓ_j.
        
        The projection is: x - ((ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖²) * (a_k - a_j)
        """
        s = self.certifier.scores(x)
        normal = self.certifier.weights[k] - self.certifier.weights[j]
        gap = (s[k] - s[j])
        norm_sq = np.dot(normal, normal)
        if norm_sq < 1e-30:
            return x.copy()
        return x - (gap / norm_sq) * normal


def benchmark_certification(n_features_list: List[int], 
                             n_classes: int = 10,
                             n_points: int = 100) -> dict:
    """
    Benchmark certification time vs. dimension.
    
    Returns timing data for plotting.
    """
    results = {'dimensions': [], 'times': [], 'avg_radius': [], 'avg_improvement': []}
    
    for n_feat in n_features_list:
        np.random.seed(42)
        W = np.random.randn(n_classes, n_feat)
        b = np.random.randn(n_classes)
        cert = PolyhedralCertifier(W, b)
        
        X = np.random.randn(n_points, n_feat) * 0.5
        
        start = time.time()
        certs = cert.batch_certify(X)
        elapsed = time.time() - start
        
        radii = [c.certified_radius for c in certs]
        improvements = [c.certified_radius / c.lipschitz_radius 
                       for c in certs if c.lipschitz_radius > 0]
        
        results['dimensions'].append(n_feat)
        results['times'].append(elapsed)
        results['avg_radius'].append(np.mean(radii))
        results['avg_improvement'].append(np.mean(improvements) if improvements else 1.0)
    
    return results


if __name__ == "__main__":
    print("=" * 70)
    print("POLYHEDRAL CERTIFIER — Algorithm Demo")
    print("=" * 70)
    
    # 3-class classifier in ℝ²
    W = np.array([[2.0, 1.0], [-1.0, 3.0], [0.0, -2.0]])
    b = np.array([0.0, 1.0, 5.0])
    
    certifier = PolyhedralCertifier(W, b)
    bdc = BoundaryDistanceComputer(certifier)
    
    x = np.array([1.0, 2.0])
    cert = certifier.certify(x)
    
    print(f"\nPoint: {x}")
    print(f"Predicted class: {cert.predicted_class}")
    print(f"Certified radius: {cert.certified_radius:.6f}")
    print(f"Active facet (nearest competitor): class {cert.active_facet}")
    print(f"Raw margin: {cert.margin:.4f}")
    print(f"Lipschitz radius: {cert.lipschitz_radius:.6f}")
    print(f"Improvement: {cert.certified_radius / cert.lipschitz_radius:.2f}x")
    
    print(f"\nFacet distances:")
    distances = bdc.facet_distances(x, cert.predicted_class)
    for j, d in sorted(distances.items()):
        print(f"  d(x, facet_{j}) = {d:.6f}")
    
    if cert.active_facet is not None:
        proj = bdc.nearest_boundary_point(x, cert.predicted_class, cert.active_facet)
        print(f"\nNearest boundary point (on facet {cert.active_facet}): {proj}")
        print(f"Verification: ‖x - proj‖ = {np.linalg.norm(x - proj):.6f}")
    
    # Benchmark
    print("\n" + "=" * 70)
    print("BENCHMARK: Certification time vs. dimension")
    print("=" * 70)
    
    dims = [2, 5, 10, 20, 50, 100, 200, 500]
    results = benchmark_certification(dims)
    
    print(f"{'Dim':>6s} | {'Time (ms)':>10s} | {'Avg Radius':>10s} | {'Improvement':>11s}")
    print("-" * 50)
    for i, d in enumerate(results['dimensions']):
        print(f"{d:>6d} | {results['times'][i]*1000:>10.2f} | "
              f"{results['avg_radius'][i]:>10.6f} | "
              f"{results['avg_improvement'][i]:>10.2f}x")
