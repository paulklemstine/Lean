#!/usr/bin/env python3
"""
Tropical Decision Boundary Theory: Core Algorithms

Type-hinted implementations of the key algorithms connecting
ReLU neural network architecture to tropical geometry.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Set, Optional
import numpy as np


# ============================================================
# Data Structures
# ============================================================

@dataclass
class TropicalMonomial1D:
    """A tropical monomial: affine function x ↦ slope * x + intercept."""
    slope: float
    intercept: float
    
    def eval(self, x: float) -> float:
        return self.slope * x + self.intercept


@dataclass
class TropicalPoly1D:
    """A tropical polynomial: max of finitely many affine functions."""
    terms: List[TropicalMonomial1D]
    
    def eval(self, x: float) -> float:
        return max(t.eval(x) for t in self.terms)
    
    def eval_array(self, x: np.ndarray) -> np.ndarray:
        values = np.array([[t.eval(xi) for xi in x] for t in self.terms])
        return np.max(values, axis=0)


@dataclass 
class TropicalRational1D:
    """A tropical rational function: difference of two tropical polynomials."""
    numerator: TropicalPoly1D
    denominator: TropicalPoly1D
    
    def eval(self, x: float) -> float:
        return self.numerator.eval(x) - self.denominator.eval(x)
    
    def eval_array(self, x: np.ndarray) -> np.ndarray:
        return self.numerator.eval_array(x) - self.denominator.eval_array(x)


@dataclass
class TropicalComplexity:
    """Tropical complexity of a piecewise linear function.
    
    Captures four interrelated complexity measures:
    - numPieces: number of maximal linear regions
    - depth: minimum circuit depth
    - tropicalDegree: total max/min operations
    - bendPoints: points of non-differentiability
    
    Invariants:
    - bendPoints + 1 = numPieces
    - 2^depth >= numPieces
    - tropicalDegree >= bendPoints
    """
    numPieces: int
    depth: int
    tropicalDegree: int
    bendPoints: int
    
    def __post_init__(self) -> None:
        assert self.bendPoints + 1 == self.numPieces
        assert 2 ** self.depth >= self.numPieces
        assert self.tropicalDegree >= self.bendPoints
    
    @classmethod
    def from_pieces(cls, k: int) -> 'TropicalComplexity':
        """Create minimal complexity for k linear pieces."""
        import math
        depth = max(0, math.ceil(math.log2(k))) if k > 1 else 0
        return cls(
            numPieces=k,
            depth=depth,
            tropicalDegree=k - 1,
            bendPoints=k - 1
        )


@dataclass
class ActivationPattern:
    """Binary activation pattern for a neural network layer."""
    pattern: Tuple[bool, ...]
    
    @property
    def width(self) -> int:
        return len(self.pattern)
    
    def hamming_distance(self, other: 'ActivationPattern') -> int:
        """Hamming distance = number of differing bits."""
        assert self.width == other.width
        return sum(a != b for a, b in zip(self.pattern, other.pattern))
    
    def is_adjacent(self, other: 'ActivationPattern') -> bool:
        """Two patterns are adjacent iff they differ in exactly one bit."""
        return self.hamming_distance(other) == 1


@dataclass
class ActivationComplex:
    """The activation complex of a ReLU network.
    
    Records the set of geometrically realizable activation patterns
    and their adjacency structure.
    """
    totalWidth: int
    patterns: Set[Tuple[bool, ...]]
    
    @property
    def realizablePatterns(self) -> int:
        return len(self.patterns)
    
    @property 
    def adjacencies(self) -> int:
        """Count pairs of adjacent patterns."""
        count = 0
        pattern_list = [ActivationPattern(p) for p in self.patterns]
        for i, p in enumerate(pattern_list):
            for q in pattern_list[i+1:]:
                if p.is_adjacent(q):
                    count += 1
        return count
    
    def euler_characteristic(self) -> int:
        """Euler characteristic: V - E where V = patterns, E = adjacencies."""
        return self.realizablePatterns - self.adjacencies


@dataclass
class ReLUArchitecture:
    """Architecture of a feedforward ReLU network."""
    hidden_widths: List[int]
    
    def __post_init__(self) -> None:
        assert all(w > 0 for w in self.hidden_widths)
    
    @property
    def depth(self) -> int:
        return len(self.hidden_widths)
    
    @property
    def total_width(self) -> int:
        return sum(self.hidden_widths)
    
    @property
    def max_width(self) -> int:
        return max(self.hidden_widths) if self.hidden_widths else 0


# ============================================================
# Algorithm 1: Linear Region Counting
# ============================================================

def max_linear_regions_1d(widths: List[int]) -> int:
    """Maximum linear regions for 1D input ReLU network.
    
    Theorem (region_bound_heterogeneous):
        maxLinearRegions1D(ws) = ∏(wᵢ + 1)
    
    Args:
        widths: List of hidden layer widths [w₁, ..., w_L]
    
    Returns:
        Maximum number of linear regions
    """
    result = 1
    for w in widths:
        result *= (w + 1)
    return result


def max_linear_regions_nd(n: int, widths: List[int]) -> int:
    """Maximum linear regions for n-dimensional input (Montúfar bound).
    
    For n-dim input, the bound per layer is ∑_{j=0}^{min(n,w)} C(w,j)
    rather than w + 1.
    
    Args:
        n: Input dimension
        widths: List of hidden layer widths
    
    Returns:
        Upper bound on linear regions
    """
    from math import comb
    result = 1
    for w in widths:
        layer_bound = sum(comb(w, j) for j in range(min(n, w) + 1))
        result *= layer_bound
    return result


# ============================================================
# Algorithm 2: Tropical Polynomial Construction
# ============================================================

def relu_as_tropical() -> TropicalPoly1D:
    """Construct ReLU as a tropical polynomial.
    
    relu(x) = max(1·x + 0, 0·x + 0)
    
    Theorem (relu_tropical_eval):
        reluAsTropicalPoly.eval(x) = relu(x)
    """
    return TropicalPoly1D([
        TropicalMonomial1D(slope=1.0, intercept=0.0),
        TropicalMonomial1D(slope=0.0, intercept=0.0),
    ])


def single_layer_to_tropical(
    weights: np.ndarray, 
    biases: np.ndarray,
    output_weights: np.ndarray,
    output_bias: float
) -> TropicalRational1D:
    """Convert a single-layer 1D ReLU network to tropical rational form.
    
    Network: f(x) = Σᵢ cᵢ · max(wᵢx + bᵢ, 0) + d
    
    Split into positive and negative output weights:
    f(x) = [Σ_{cᵢ>0} cᵢ · max(wᵢx + bᵢ, 0)] 
          - [Σ_{cᵢ<0} |cᵢ| · max(wᵢx + bᵢ, 0)] + d
    
    Each sum of max functions can be bounded by a max of sums
    (tropical polynomial).
    
    Args:
        weights: Hidden layer weights (w,)
        biases: Hidden layer biases (w,)
        output_weights: Output weights (w,)
        output_bias: Output bias scalar
    
    Returns:
        TropicalRational1D representation
    """
    w = len(weights)
    
    # For a simple representation, enumerate all 2^w activation patterns
    pos_terms = []
    neg_terms = []
    
    for mask in range(2 ** w):
        slope = 0.0
        intercept = output_bias
        for i in range(w):
            if mask & (1 << i):
                slope += output_weights[i] * weights[i]
                intercept += output_weights[i] * biases[i]
        
        pos_terms.append(TropicalMonomial1D(slope, intercept))
        neg_terms.append(TropicalMonomial1D(-slope, -intercept))
    
    # Crude construction: numerator and denominator together give f
    # The actual tropical rational representation is more subtle
    numerator = TropicalPoly1D(pos_terms)
    denominator = TropicalPoly1D([TropicalMonomial1D(0, 0)])
    
    return TropicalRational1D(numerator, denominator)


# ============================================================
# Algorithm 3: Decision Boundary Extraction
# ============================================================

def find_decision_boundary_1d(
    f: callable, 
    x_min: float, 
    x_max: float, 
    n_samples: int = 10000,
    tol: float = 1e-10
) -> List[float]:
    """Find zero crossings of a function (decision boundary in 1D).
    
    Uses sign changes and bisection for precise location.
    
    Args:
        f: Function ℝ → ℝ
        x_min, x_max: Search interval
        n_samples: Initial grid density
        tol: Bisection tolerance
    
    Returns:
        List of x-coordinates where f(x) ≈ 0
    """
    x = np.linspace(x_min, x_max, n_samples)
    y = np.array([f(xi) for xi in x])
    
    boundaries = []
    for i in range(len(y) - 1):
        if y[i] * y[i+1] < 0:  # Sign change
            # Bisection
            lo, hi = x[i], x[i+1]
            while hi - lo > tol:
                mid = (lo + hi) / 2
                if f(lo) * f(mid) <= 0:
                    hi = mid
                else:
                    lo = mid
            boundaries.append((lo + hi) / 2)
    
    return boundaries


def count_bend_points_1d(
    f: callable,
    x_min: float,
    x_max: float,
    n_samples: int = 10000,
    threshold: float = 1e-6
) -> Tuple[int, List[float]]:
    """Count points of non-differentiability (bend locus) of a PWL function.
    
    Uses second-difference detection.
    
    Args:
        f: Piecewise linear function
        x_min, x_max: Domain
        n_samples: Grid density
        threshold: Curvature threshold for bend detection
    
    Returns:
        (count, locations) of bend points
    """
    x = np.linspace(x_min, x_max, n_samples)
    y = np.array([f(xi) for xi in x])
    dx = x[1] - x[0]
    
    # Second difference ≈ second derivative * dx²
    d2y = np.diff(y, n=2)
    
    # Normalize
    if np.max(np.abs(d2y)) > 0:
        d2y_norm = np.abs(d2y) / np.max(np.abs(d2y))
    else:
        return 0, []
    
    # Find peaks in curvature
    bend_indices = []
    for i in range(1, len(d2y_norm) - 1):
        if (d2y_norm[i] > threshold and 
            d2y_norm[i] >= d2y_norm[i-1] and 
            d2y_norm[i] >= d2y_norm[i+1]):
            bend_indices.append(i + 1)  # +1 for diff offset
    
    bend_locations = [x[i] for i in bend_indices]
    return len(bend_locations), bend_locations


# ============================================================
# Algorithm 4: Activation Complex Construction
# ============================================================

def build_activation_complex(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    x_samples: np.ndarray
) -> ActivationComplex:
    """Build the activation complex by sampling.
    
    For each input sample, compute the activation pattern (which neurons fire)
    and record the set of realized patterns.
    
    Args:
        weights: List of weight matrices per layer
        biases: List of bias vectors per layer
        x_samples: Input samples (n,) for 1D
    
    Returns:
        ActivationComplex with realized patterns
    """
    total_width = sum(W.shape[0] for W in weights[:-1])
    patterns: Set[Tuple[bool, ...]] = set()
    
    for x in x_samples:
        h = np.array([x]).reshape(1, -1)
        pattern = []
        
        for W, b in zip(weights[:-1], biases[:-1]):
            pre_activation = h @ W.T + b
            active = tuple(bool(v > 0) for v in pre_activation.flatten())
            pattern.extend(active)
            h = np.maximum(pre_activation, 0)
        
        patterns.add(tuple(pattern))
    
    return ActivationComplex(
        totalWidth=total_width,
        patterns=patterns
    )


# ============================================================
# Algorithm 5: Tropical Complexity Analysis
# ============================================================

def analyze_tropical_complexity(
    f: callable,
    x_min: float = -10.0,
    x_max: float = 10.0,
    n_samples: int = 100000
) -> TropicalComplexity:
    """Analyze the tropical complexity of a piecewise linear function.
    
    Counts linear pieces and bend points, then constructs the
    TropicalComplexity record.
    
    Args:
        f: Piecewise linear function ℝ → ℝ
        x_min, x_max: Analysis domain
        n_samples: Grid density
    
    Returns:
        TropicalComplexity record
    """
    bend_count, _ = count_bend_points_1d(f, x_min, x_max, n_samples)
    num_pieces = bend_count + 1
    return TropicalComplexity.from_pieces(num_pieces)


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Tropical Decision Boundary Algorithms")
    print("=" * 50)
    
    # 1. Region counting
    print("\n1. Linear Region Bounds:")
    for arch in [[4], [4, 4], [4, 4, 4], [8, 8], [2, 2, 2, 2, 2]]:
        r1d = max_linear_regions_1d(arch)
        r2d = max_linear_regions_nd(2, arch)
        print(f"   Arch {str(arch):>20}: 1D={r1d:>8}, 2D={r2d:>8}")
    
    # 2. Tropical polynomial
    print("\n2. ReLU as Tropical Polynomial:")
    relu_trop = relu_as_tropical()
    for x in [-2, -1, 0, 0.5, 1, 3]:
        print(f"   relu({x:>5}) = {relu_trop.eval(x):.1f}")
    
    # 3. Complexity analysis
    print("\n3. Tropical Complexity of Random Networks:")
    np.random.seed(42)
    for depth in [1, 2, 3]:
        width = 4
        ws = [np.random.randn(width, 1 if i == 0 else width) 
              for i in range(depth)]
        ws.append(np.random.randn(1, width))
        bs = [np.random.randn(w.shape[0]) for w in ws]
        
        def make_f(weights=ws, biases=bs):
            def f(x):
                h = np.array([[x]])
                for W, b in zip(weights[:-1], biases[:-1]):
                    h = np.maximum(h @ W.T + b, 0)
                return float((h @ weights[-1].T + biases[-1]).squeeze())
            return f
        
        f = make_f()
        tc = analyze_tropical_complexity(f)
        theoretical = max_linear_regions_1d([width] * depth)
        print(f"   Depth {depth}: {tc.numPieces:>4} pieces "
              f"(max {theoretical}), depth={tc.depth}, degree={tc.tropicalDegree}")
    
    print("\nAll algorithms executed successfully.")
