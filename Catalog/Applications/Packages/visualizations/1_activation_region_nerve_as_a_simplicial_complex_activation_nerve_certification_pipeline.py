#!/usr/bin/env python3
"""
Algorithms for Activation-Nerve Certification of Neural Networks

Implements the computational pipeline from the theoretical framework:
1. Activation region decomposition of ReLU networks
2. Nerve complex construction from region overlaps
3. Margin cosheaf computation
4. Degree-1 exactness verification
5. Certified robustness radius computation

Each algorithm includes complexity analysis and docstrings.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from itertools import combinations
from math import comb


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Activation Region Enumeration
# ──────────────────────────────────────────────────────────────────

class ActivationRegion:
    """
    An activation region of a ReLU network, defined by a sign pattern.
    
    Each ReLU neuron is either active (+1) or inactive (0). The sign pattern
    σ ∈ {0, 1}^n determines which neurons are active, and the region R_σ
    is the set of inputs where exactly these neurons are active.
    
    Attributes:
        pattern: tuple of 0/1 values indicating neuron activation
        weight_matrix: W such that on this region, f(x) = Wx + b
        bias: b in the affine expression
    """
    
    def __init__(self, pattern: Tuple[int, ...], 
                 weight_matrix: np.ndarray, bias: np.ndarray):
        self.pattern = pattern
        self.weight_matrix = weight_matrix
        self.bias = bias
    
    def __repr__(self):
        return f"ActivationRegion(pattern={self.pattern})"


def enumerate_activation_regions(
    weights: List[np.ndarray], 
    biases: List[np.ndarray],
    domain_points: np.ndarray
) -> List[ActivationRegion]:
    """
    Enumerate activation regions of a ReLU network by sampling.
    
    Given a ReLU network with layer weights and biases, sample points
    from the domain and record the sign patterns of all preactivations.
    Each unique sign pattern defines an activation region.
    
    Algorithm:
        1. For each sample point x, compute preactivations at each layer
        2. Record the sign pattern σ(x) = (sign(z_1), ..., sign(z_n))
        3. Group points by sign pattern
        4. For each pattern, compute the affine function on that region
    
    Complexity: O(N · L · max_width²) where N = #samples, L = #layers
    
    Args:
        weights: list of weight matrices [W1, W2, ..., WL]
        biases: list of bias vectors [b1, b2, ..., bL]
        domain_points: array of shape (N, d) of sample points
    
    Returns:
        List of ActivationRegion objects (one per observed sign pattern)
    """
    patterns_seen: Dict[tuple, List[int]] = {}
    
    for idx, x in enumerate(domain_points):
        # Forward pass recording sign patterns
        pattern = []
        h = x.copy()
        for W, b in zip(weights[:-1], biases[:-1]):
            z = W @ h + b  # preactivation
            signs = tuple((z > 0).astype(int))
            pattern.extend(signs)
            h = np.maximum(0, z)  # ReLU
        
        pattern_key = tuple(pattern)
        if pattern_key not in patterns_seen:
            patterns_seen[pattern_key] = []
        patterns_seen[pattern_key].append(idx)
    
    # Build activation regions
    regions = []
    for pattern, indices in patterns_seen.items():
        # Compute the effective affine map on this region
        # On region σ, f(x) = W_eff · x + b_eff where W_eff = product of
        # (diag(σ_l) · W_l) and b_eff accumulates the biases
        W_eff = np.eye(weights[0].shape[1])
        b_eff = np.zeros(weights[-1].shape[0])
        
        offset = 0
        for l, (W, b) in enumerate(zip(weights, biases)):
            if l < len(weights) - 1:
                n_neurons = W.shape[0]
                signs = np.array(pattern[offset:offset + n_neurons])
                offset += n_neurons
                D = np.diag(signs.astype(float))
                W_eff = D @ W @ W_eff if l == 0 else D @ W @ W_eff
                b_eff = D @ (W @ b_eff + b) if l > 0 else D @ b
            else:
                W_eff = W @ W_eff
                b_eff = W @ b_eff + b
        
        regions.append(ActivationRegion(pattern, W_eff, b_eff))
    
    return regions


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Nerve Complex Construction
# ──────────────────────────────────────────────────────────────────

class NerveComplex:
    """
    The nerve complex of a finite cover.
    
    Vertices correspond to cover elements (activation regions).
    A simplex σ = {i_1, ..., i_k} is in the nerve iff
    R_{i_1} ∩ ... ∩ R_{i_k} ≠ ∅.
    
    Stored as a list of simplices (frozensets of vertex indices).
    """
    
    def __init__(self, vertices: List[int], simplices: List[frozenset]):
        self.vertices = vertices
        self.simplices = simplices
        self._edges = [s for s in simplices if len(s) == 2]
        self._triangles = [s for s in simplices if len(s) == 3]
    
    @property
    def edges(self) -> List[frozenset]:
        return self._edges
    
    @property
    def triangles(self) -> List[frozenset]:
        return self._triangles
    
    @property
    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic χ = V - E + F - ..."""
        chi = 0
        for s in self.simplices:
            k = len(s)  # k-1 dimensional simplex
            chi += (-1) ** (k - 1)
        return chi
    
    def __repr__(self):
        return (f"NerveComplex(vertices={len(self.vertices)}, "
                f"edges={len(self.edges)}, triangles={len(self.triangles)})")


def build_nerve_complex(
    regions: List[ActivationRegion],
    domain_points: np.ndarray,
    region_membership: np.ndarray,
    max_simplex_dim: int = 3
) -> NerveComplex:
    """
    Build the nerve complex from activation region data.
    
    Algorithm:
        1. For each point, determine which regions contain it
        2. For each subset of regions of size ≤ max_simplex_dim + 1,
           check if there exists a point in all of them
        3. Include the subset as a simplex if so
    
    Complexity: O(N · R + R^{max_dim+1}) where R = #regions, N = #points
    
    Args:
        regions: list of activation regions
        domain_points: sample points from the domain
        region_membership: boolean array (N, R) where entry [i,j] = True
            iff point i is in region j
        max_simplex_dim: maximum simplex dimension to compute
    
    Returns:
        NerveComplex object
    """
    n_regions = len(regions)
    vertices = list(range(n_regions))
    simplices = []
    
    # Vertices (singletons)
    for i in range(n_regions):
        if region_membership[:, i].any():
            simplices.append(frozenset([i]))
    
    # Higher simplices
    for dim in range(2, min(max_simplex_dim + 2, n_regions + 1)):
        for combo in combinations(range(n_regions), dim):
            # Check if intersection is nonempty
            mask = np.all(region_membership[:, list(combo)], axis=1)
            if mask.any():
                simplices.append(frozenset(combo))
    
    return NerveComplex(vertices, simplices)


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Margin Cosheaf Computation
# ──────────────────────────────────────────────────────────────────

class MarginCosheaf:
    """
    The margin cosheaf on a nerve complex.
    
    Assigns to each simplex σ the infimum of the margin function
    on the intersection ∩_{i ∈ σ} R_i ∩ K.
    """
    
    def __init__(self, nerve: NerveComplex, 
                 simplex_margins: Dict[frozenset, float]):
        self.nerve = nerve
        self.values = simplex_margins
    
    def vertex_value(self, i: int) -> float:
        return self.values.get(frozenset([i]), float('inf'))
    
    def edge_value(self, i: int, j: int) -> float:
        return self.values.get(frozenset([i, j]), float('inf'))
    
    def is_degree1_exact(self) -> Tuple[bool, Optional[str]]:
        """
        Check degree-1 exactness of the margin cosheaf.
        
        Degree-1 exactness requires:
        1. All vertex values are positive
        2. All edge values are positive
        
        Returns:
            (is_exact, reason_if_not)
        """
        for s in self.nerve.simplices:
            if len(s) == 1:
                v = list(s)[0]
                if self.values[s] <= 0:
                    return False, f"Vertex {v} has non-positive margin {self.values[s]:.6f}"
            elif len(s) == 2:
                if self.values[s] <= 0:
                    return False, f"Edge {s} has non-positive margin {self.values[s]:.6f}"
        return True, None
    
    def global_margin_bound(self) -> float:
        """
        Compute the global margin lower bound from vertex data.
        
        If degree-1 exact, this is min over all vertex margins.
        """
        vertex_margins = [self.values[s] for s in self.nerve.simplices if len(s) == 1]
        return min(vertex_margins) if vertex_margins else 0.0


def compute_margin_cosheaf(
    nerve: NerveComplex,
    margin_values: np.ndarray,
    region_membership: np.ndarray
) -> MarginCosheaf:
    """
    Compute the margin cosheaf on a nerve complex.
    
    Algorithm:
        For each simplex σ in the nerve:
            M(σ) = min { margin(x) : x ∈ ∩_{i ∈ σ} R_i }
    
    Complexity: O(|simplices| · N)
    
    Args:
        nerve: the nerve complex
        margin_values: array of margin values at sample points
        region_membership: boolean (N, R) membership matrix
    
    Returns:
        MarginCosheaf object
    """
    simplex_margins = {}
    
    for simplex in nerve.simplices:
        indices = list(simplex)
        mask = np.all(region_membership[:, indices], axis=1)
        if mask.any():
            simplex_margins[simplex] = float(margin_values[mask].min())
        else:
            simplex_margins[simplex] = float('inf')
    
    return MarginCosheaf(nerve, simplex_margins)


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Certified Robustness Radius
# ──────────────────────────────────────────────────────────────────

def certified_robustness_radius(
    cosheaf: MarginCosheaf,
    lipschitz_constant: float
) -> Tuple[float, Dict]:
    """
    Compute the certified robustness radius from the margin cosheaf.
    
    Algorithm (the certification pipeline):
        1. Check degree-1 exactness
        2. If exact, compute global margin δ = min vertex margins
        3. Certified radius r = δ / L
    
    Complexity: O(|simplices|)
    
    Args:
        cosheaf: the margin cosheaf on the activation nerve
        lipschitz_constant: Lipschitz constant L of the margin function
    
    Returns:
        (radius, details_dict)
    """
    is_exact, reason = cosheaf.is_degree1_exact()
    
    details = {
        'degree1_exact': is_exact,
        'reason_if_not_exact': reason,
        'lipschitz_constant': lipschitz_constant,
    }
    
    if not is_exact:
        details['global_margin'] = None
        details['certified_radius'] = 0.0
        return 0.0, details
    
    delta = cosheaf.global_margin_bound()
    details['global_margin'] = delta
    
    if delta <= 0 or lipschitz_constant <= 0:
        details['certified_radius'] = 0.0
        return 0.0, details
    
    r = delta / lipschitz_constant
    details['certified_radius'] = r
    
    return r, details


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Region Count Bound (Zaslavsky)
# ──────────────────────────────────────────────────────────────────

def max_regions_single_layer(n: int, d: int) -> int:
    """
    Maximum number of activation regions for a single ReLU layer.
    
    Zaslavsky's theorem: n hyperplanes in ℝ^d create at most
    ∑_{k=0}^{d} C(n, k) regions.
    
    Complexity: O(d)
    
    Args:
        n: number of neurons (hyperplanes)
        d: input dimension
    
    Returns:
        Upper bound on number of regions
    """
    return sum(comb(n, k) for k in range(d + 1))


def max_regions_multilayer(widths: List[int], d: int) -> int:
    """
    Maximum number of activation regions for a multi-layer ReLU network.
    
    For L layers with widths w_1, ..., w_L, the bound is
    ∏_{l=1}^{L} (∑_{k=0}^{d} C(w_l, k))
    
    Complexity: O(L · d)
    
    Args:
        widths: list of layer widths
        d: input dimension
    
    Returns:
        Upper bound on total number of regions
    """
    result = 1
    for w in widths:
        result *= max_regions_single_layer(w, d)
    return result


# ──────────────────────────────────────────────────────────────────
# Full Pipeline
# ──────────────────────────────────────────────────────────────────

def full_certification_pipeline(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    domain_bounds: Tuple[np.ndarray, np.ndarray],
    margin_fn,
    lipschitz_constant: float,
    n_samples: int = 10000,
    max_simplex_dim: int = 2
) -> Dict:
    """
    Full certification pipeline: network → regions → nerve → cosheaf → radius.
    
    Pseudocode:
        1. Sample N points from domain K
        2. Forward pass to determine activation patterns
        3. Build activation regions from unique patterns
        4. Construct nerve complex from region overlaps
        5. Compute margin cosheaf values
        6. Check degree-1 exactness
        7. If exact, compute certified radius r = δ/L
    
    Complexity: O(N · L · w² + R^{dim+1} · N) total
    
    Args:
        weights, biases: network parameters
        domain_bounds: (lower, upper) bounds defining K = [lower, upper]
        margin_fn: function computing margin at each point
        lipschitz_constant: L
        n_samples: number of sample points
        max_simplex_dim: maximum simplex dimension
    
    Returns:
        Dictionary with full certification results
    """
    lower, upper = domain_bounds
    d = len(lower)
    
    # Step 1: Sample domain
    points = np.random.uniform(lower, upper, (n_samples, d))
    
    # Step 2-3: Enumerate activation regions
    regions = enumerate_activation_regions(weights, biases, points)
    
    # Build membership matrix
    n_regions = len(regions)
    membership = np.zeros((n_samples, n_regions), dtype=bool)
    
    # Re-compute memberships
    patterns_to_idx = {}
    for idx, r in enumerate(regions):
        patterns_to_idx[r.pattern] = idx
    
    for i, x in enumerate(points):
        pattern = []
        h = x.copy()
        for W, b in zip(weights[:-1], biases[:-1]):
            z = W @ h + b
            signs = tuple((z > 0).astype(int))
            pattern.extend(signs)
            h = np.maximum(0, z)
        
        key = tuple(pattern)
        if key in patterns_to_idx:
            membership[i, patterns_to_idx[key]] = True
    
    # Step 4: Build nerve
    nerve = build_nerve_complex(regions, points, membership, max_simplex_dim)
    
    # Step 5: Compute margins
    margins = np.array([margin_fn(x) for x in points])
    cosheaf = compute_margin_cosheaf(nerve, margins, membership)
    
    # Step 6-7: Certify
    radius, details = certified_robustness_radius(cosheaf, lipschitz_constant)
    
    # Region count bounds
    layer_widths = [W.shape[0] for W in weights[:-1]]
    theoretical_max = max_regions_multilayer(layer_widths, d) if layer_widths else 1
    
    return {
        'n_regions_observed': n_regions,
        'n_regions_theoretical_max': theoretical_max,
        'nerve': nerve,
        'cosheaf': cosheaf,
        'certified_radius': radius,
        'details': details,
        'euler_characteristic': nerve.euler_characteristic,
    }


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("Activation-Nerve Certification Algorithms")
    print("=" * 50)
    
    # Simple 1D network: 2 hidden neurons
    W1 = np.array([[1.0], [-1.0]])
    b1 = np.array([0.5, 0.5])
    W2 = np.array([[1.0, 1.0]])
    b2 = np.array([0.3])
    
    weights = [W1, W2]
    biases = [b1, b2]
    
    def margin_fn(x):
        h = np.maximum(0, W1 @ x + b1)
        return float((W2 @ h + b2)[0])
    
    result = full_certification_pipeline(
        weights, biases,
        domain_bounds=(np.array([-2.0]), np.array([2.0])),
        margin_fn=margin_fn,
        lipschitz_constant=2.0,
        n_samples=5000
    )
    
    print(f"\nResults:")
    print(f"  Observed regions: {result['n_regions_observed']}")
    print(f"  Max theoretical regions: {result['n_regions_theoretical_max']}")
    print(f"  Nerve: {result['nerve']}")
    print(f"  Euler characteristic: {result['euler_characteristic']}")
    print(f"  Degree-1 exact: {result['details']['degree1_exact']}")
    print(f"  Global margin: {result['details'].get('global_margin', 'N/A')}")
    print(f"  Certified radius: {result['certified_radius']:.6f}")
    
    # Region count table
    print(f"\nRegion count bounds (Zaslavsky):")
    print(f"  {'Neurons':>8} {'Dim':>5} {'Max regions':>12}")
    for d in [2, 5, 10]:
        for n in [8, 16, 32, 64]:
            print(f"  {n:>8} {d:>5} {max_regions_single_layer(n, d):>12}")
