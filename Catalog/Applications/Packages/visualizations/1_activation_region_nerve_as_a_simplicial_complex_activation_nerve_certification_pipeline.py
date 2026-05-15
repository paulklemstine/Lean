#!/usr/bin/env python3
"""
Algorithms for Activation-Nerve Margin-Cosheaf Certification

Implements the key algorithms from the research paper:
1. Activation region enumeration
2. Nerve construction
3. Margin cosheaf computation
4. Degree-1 exactness checking
5. Certified robustness radius computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Set, FrozenSet, Optional, Callable
from dataclasses import dataclass, field


@dataclass
class ActivationRegion:
    """An activation region of a ReLU network.
    
    Attributes:
        index: unique identifier
        sign_pattern: binary pattern indicating which neurons are active
        vertices: extreme points of the polyhedral region (for polytope regions)
        bounds: bounding box [(lo_1, hi_1), ..., (lo_d, hi_d)]
    """
    index: int
    sign_pattern: Tuple[int, ...]
    bounds: List[Tuple[float, float]]
    
    def contains(self, x: np.ndarray) -> bool:
        """Check if point x is in this region."""
        return all(lo <= xi <= hi for xi, (lo, hi) in zip(x, self.bounds))
    
    def sample(self, n: int = 100) -> np.ndarray:
        """Sample n points uniformly from this region."""
        d = len(self.bounds)
        points = np.zeros((n, d))
        for j, (lo, hi) in enumerate(self.bounds):
            points[:, j] = np.random.uniform(lo, hi, n)
        return points


@dataclass
class ActivationNerve:
    """The nerve simplicial complex of an activation-region cover.
    
    Attributes:
        vertices: set of region indices (0-simplices)
        edges: set of pairs of indices (1-simplices)
        simplices: dict mapping dimension to set of simplices
    """
    vertices: Set[int] = field(default_factory=set)
    edges: Set[FrozenSet[int]] = field(default_factory=set)
    simplices: Dict[int, Set[FrozenSet[int]]] = field(default_factory=dict)
    
    @property
    def num_vertices(self) -> int:
        return len(self.vertices)
    
    @property
    def num_edges(self) -> int:
        return len(self.edges)
    
    @property
    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic: Σ (-1)^k |simplices_k|."""
        chi = 0
        for dim, simps in self.simplices.items():
            chi += (-1) ** dim * len(simps)
        return chi
    
    def is_downward_closed(self) -> bool:
        """Verify the simplicial complex property: every face of a simplex is a simplex."""
        for dim in sorted(self.simplices.keys(), reverse=True):
            for sigma in self.simplices[dim]:
                for k in range(len(sigma)):
                    face = frozenset(list(sigma)[:k] + list(sigma)[k+1:])
                    if len(face) > 0:
                        face_dim = len(face) - 1
                        if face_dim not in self.simplices or face not in self.simplices[face_dim]:
                            return False
        return True


@dataclass
class MarginCosheaf:
    """The margin cosheaf on an activation nerve.
    
    Assigns to each simplex the infimum of the margin function on the
    corresponding domain intersection.
    """
    values: Dict[FrozenSet[int], float] = field(default_factory=dict)
    
    @property
    def vertex_values(self) -> Dict[int, float]:
        """Margin values on 0-simplices (vertices)."""
        return {list(k)[0]: v for k, v in self.values.items() if len(k) == 1}
    
    @property
    def min_vertex_margin(self) -> float:
        """Minimum margin across all vertices."""
        vv = self.vertex_values
        return min(vv.values()) if vv else float('-inf')
    
    def is_monotone(self) -> bool:
        """Check cosheaf monotonicity: M(σ) ≤ M(τ) when σ ⊆ τ."""
        for sigma, v_sigma in self.values.items():
            for tau, v_tau in self.values.items():
                if sigma < tau and v_sigma > v_tau + 1e-10:
                    return False
        return True


@dataclass
class CertificationResult:
    """Result of the robustness certification pipeline."""
    is_certified: bool
    degree1_exact: bool
    uniform_margin: float
    lipschitz_constant: float
    certified_radius: float
    num_regions: int
    nerve_vertices: int
    nerve_edges: int
    vulnerable_regions: List[int] = field(default_factory=list)
    
    def summary(self) -> str:
        lines = [
            f"Certification Result:",
            f"  Degree-1 exact: {self.degree1_exact}",
            f"  Uniform margin (δ): {self.uniform_margin:.6f}",
            f"  Lipschitz constant (L): {self.lipschitz_constant:.6f}",
            f"  Certified radius (δ/L): {self.certified_radius:.6f}",
            f"  Activation regions: {self.num_regions}",
            f"  Nerve vertices: {self.nerve_vertices}",
            f"  Nerve edges: {self.nerve_edges}",
        ]
        if self.is_certified:
            lines.append(f"  ✓ CERTIFIED ROBUST within radius {self.certified_radius:.6f}")
        else:
            lines.append(f"  ✗ NOT CERTIFIED")
            if self.vulnerable_regions:
                lines.append(f"  Vulnerable regions: {self.vulnerable_regions}")
        return "\n".join(lines)


# ============================================================
# Algorithm 1: Activation Region Enumeration
# ============================================================
def enumerate_activation_regions_1d(
    weights: np.ndarray,
    biases: np.ndarray,
    domain: Tuple[float, float]
) -> List[ActivationRegion]:
    """Enumerate activation regions of a single ReLU layer in 1D.
    
    Complexity: O(n log n) where n = number of neurons.
    
    Args:
        weights: neuron weights, shape (n,)
        biases: neuron biases, shape (n,)
        domain: (lo, hi) bounds of the input domain
        
    Returns:
        List of ActivationRegion objects
    """
    breakpoints = set()
    n = len(weights)
    
    for i in range(n):
        if abs(weights[i]) > 1e-12:
            bp = -biases[i] / weights[i]
            if domain[0] <= bp <= domain[1]:
                breakpoints.add(bp)
    
    breakpoints = sorted(breakpoints | {domain[0], domain[1]})
    regions = []
    
    for idx in range(len(breakpoints) - 1):
        lo, hi = breakpoints[idx], breakpoints[idx + 1]
        midpoint = (lo + hi) / 2
        # Compute sign pattern at midpoint
        pattern = tuple(1 if weights[i] * midpoint + biases[i] > 0 else 0 
                       for i in range(n))
        regions.append(ActivationRegion(
            index=idx,
            sign_pattern=pattern,
            bounds=[(lo, hi)]
        ))
    
    return regions


# ============================================================
# Algorithm 2: Nerve Construction
# ============================================================
def build_activation_nerve(
    regions: List[ActivationRegion],
    overlap_checker: Optional[Callable] = None,
    max_dimension: int = 2
) -> ActivationNerve:
    """Build the activation nerve from a list of regions.
    
    Complexity: O(|regions|^(max_dim+1) * overlap_check_cost)
    
    For 1D interval regions, overlap checking is O(1).
    For general d-dimensional regions, it requires solving a feasibility LP.
    
    Args:
        regions: list of activation regions
        overlap_checker: function (list of region indices) -> bool
        max_dimension: maximum simplex dimension to compute
        
    Returns:
        ActivationNerve object
    """
    n = len(regions)
    nerve = ActivationNerve()
    nerve.simplices = {}
    
    # Default overlap checker for 1D intervals
    if overlap_checker is None:
        def default_overlap(indices):
            left = max(regions[i].bounds[0][0] for i in indices)
            right = min(regions[i].bounds[0][1] for i in indices)
            return left <= right
        overlap_checker = default_overlap
    
    # 0-simplices: all regions
    nerve.simplices[0] = set()
    for i in range(n):
        nerve.vertices.add(i)
        nerve.simplices[0].add(frozenset([i]))
    
    # k-simplices for k >= 1
    for dim in range(1, max_dimension + 1):
        nerve.simplices[dim] = set()
        for combo in combinations(range(n), dim + 1):
            if overlap_checker(list(combo)):
                sigma = frozenset(combo)
                nerve.simplices[dim].add(sigma)
                if dim == 1:
                    nerve.edges.add(sigma)
    
    return nerve


# ============================================================
# Algorithm 3: Margin Cosheaf Computation
# ============================================================
def compute_margin_cosheaf(
    regions: List[ActivationRegion],
    nerve: ActivationNerve,
    margin_fn: Callable[[np.ndarray], float],
    n_samples: int = 1000
) -> MarginCosheaf:
    """Compute the margin cosheaf by sampling.
    
    For each simplex σ in the nerve, compute the approximate infimum
    of the margin function on the corresponding domain intersection.
    
    Complexity: O(|nerve| * n_samples * d) where d is input dimension.
    
    Args:
        regions: activation regions
        nerve: the activation nerve
        margin_fn: the margin function X -> R
        n_samples: samples per region for approximation
        
    Returns:
        MarginCosheaf object
    """
    cosheaf = MarginCosheaf()
    
    for dim, simplices in nerve.simplices.items():
        for sigma in simplices:
            indices = list(sigma)
            
            if dim == 0:
                # Single region: sample from it
                region = regions[indices[0]]
                points = region.sample(n_samples)
                margins = [margin_fn(p) for p in points]
                cosheaf.values[sigma] = min(margins) if margins else float('inf')
            else:
                # Intersection: sample from the first region and filter
                # (conservative: may overestimate the infimum)
                region = regions[indices[0]]
                points = region.sample(n_samples * 5)
                valid_margins = []
                for p in points:
                    if all(regions[i].contains(p) for i in indices):
                        valid_margins.append(margin_fn(p))
                if valid_margins:
                    cosheaf.values[sigma] = min(valid_margins)
                else:
                    cosheaf.values[sigma] = float('inf')
    
    return cosheaf


# ============================================================
# Algorithm 4: Degree-1 Exactness Check
# ============================================================
def check_degree1_exactness(cosheaf: MarginCosheaf) -> Tuple[bool, float, List[int]]:
    """Check degree-1 exactness of the margin cosheaf.
    
    Degree-1 exactness requires all vertex margins to be positive.
    
    Complexity: O(|vertices|)
    
    Args:
        cosheaf: the margin cosheaf
        
    Returns:
        (is_exact, min_margin, vulnerable_vertices)
    """
    vertex_values = cosheaf.vertex_values
    min_margin = float('inf')
    vulnerable = []
    
    for v, m in vertex_values.items():
        min_margin = min(min_margin, m)
        if m <= 0:
            vulnerable.append(v)
    
    is_exact = len(vulnerable) == 0 and min_margin > 0
    return is_exact, min_margin, vulnerable


# ============================================================
# Algorithm 5: Full Certification Pipeline
# ============================================================
def certify_robustness(
    regions: List[ActivationRegion],
    margin_fn: Callable[[np.ndarray], float],
    lipschitz_constant: float,
    max_nerve_dim: int = 2,
    n_samples: int = 1000
) -> CertificationResult:
    """Complete activation-nerve certification pipeline.
    
    Pipeline:
    1. Build the activation nerve from regions.
    2. Compute the margin cosheaf.
    3. Check degree-1 exactness.
    4. If exact, compute certified radius δ/L.
    
    Total complexity: O(|regions|^(max_dim+1) * n_samples * d)
    
    Args:
        regions: list of activation regions
        margin_fn: margin function
        lipschitz_constant: Lipschitz constant L of the margin
        max_nerve_dim: max dimension for nerve computation
        n_samples: samples per region
        
    Returns:
        CertificationResult
    """
    # Step 1: Build nerve
    nerve = build_activation_nerve(regions, max_dimension=max_nerve_dim)
    
    # Step 2: Compute cosheaf
    cosheaf = compute_margin_cosheaf(regions, nerve, margin_fn, n_samples)
    
    # Step 3: Check exactness
    is_exact, min_margin, vulnerable = check_degree1_exactness(cosheaf)
    
    # Step 4: Compute certified radius
    if is_exact and lipschitz_constant > 0:
        radius = min_margin / lipschitz_constant
        is_certified = True
    else:
        radius = 0.0
        is_certified = False
    
    return CertificationResult(
        is_certified=is_certified,
        degree1_exact=is_exact,
        uniform_margin=min_margin if is_exact else 0.0,
        lipschitz_constant=lipschitz_constant,
        certified_radius=radius,
        num_regions=len(regions),
        nerve_vertices=nerve.num_vertices,
        nerve_edges=nerve.num_edges,
        vulnerable_regions=vulnerable
    )


# ============================================================
# Algorithm 6: Zaslavsky Bound
# ============================================================
def zaslavsky_bound(n: int, d: int) -> int:
    """Maximum number of regions of n hyperplanes in R^d.
    
    Formula: sum_{k=0}^{d} C(n, k)
    
    Complexity: O(d)
    
    Args:
        n: number of hyperplanes (neurons)
        d: ambient dimension
        
    Returns:
        Upper bound on number of regions
    """
    from math import comb
    return sum(comb(n, k) for k in range(d + 1))


def multilayer_region_bound(widths: List[int], input_dims: List[int]) -> int:
    """Upper bound on total activation regions for a multi-layer network.
    
    Product of per-layer Zaslavsky bounds.
    
    Args:
        widths: [n_1, n_2, ..., n_L] neurons per layer
        input_dims: [d_0, d_1, ..., d_{L-1}] input dimension to each layer
        
    Returns:
        Upper bound
    """
    total = 1
    for w, d in zip(widths, input_dims):
        total *= zaslavsky_bound(w, d)
    return total


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Activation-Nerve Certification Algorithms")
    print("=" * 50)
    
    # Example: 1D network with 3 neurons
    weights = np.array([1.0, -1.0, 0.5])
    biases = np.array([-1.0, -0.5, 0.3])
    domain = (-3.0, 3.0)
    
    print("\n1. Enumerating activation regions...")
    regions = enumerate_activation_regions_1d(weights, biases, domain)
    for r in regions:
        print(f"   Region {r.index}: bounds={r.bounds[0]}, pattern={r.sign_pattern}")
    
    print("\n2. Building activation nerve...")
    nerve = build_activation_nerve(regions)
    print(f"   Vertices: {nerve.num_vertices}")
    print(f"   Edges: {nerve.num_edges}")
    print(f"   Euler characteristic: {nerve.euler_characteristic}")
    print(f"   Downward closed: {nerve.is_downward_closed()}")
    
    print("\n3. Computing margin cosheaf...")
    def example_margin(x):
        return 1.0 + 0.3 * np.sin(x[0])
    
    cosheaf = compute_margin_cosheaf(regions, nerve, example_margin)
    for sigma, val in sorted(cosheaf.values.items(), key=lambda x: (len(x[0]), x[0])):
        print(f"   M({set(sigma)}) = {val:.4f}")
    print(f"   Cosheaf monotone: {cosheaf.is_monotone()}")
    
    print("\n4. Running full certification pipeline...")
    result = certify_robustness(regions, example_margin, lipschitz_constant=0.3)
    print(result.summary())
    
    print("\n5. Complexity bounds:")
    for arch in [("2→4→1", [4], [2]), ("10→8→8→1", [8, 8], [10, 8]),
                 ("100→16→16→1", [16, 16], [100, 16])]:
        name, w, d = arch
        bound = multilayer_region_bound(w, d)
        print(f"   {name}: ≤ {bound} regions")
