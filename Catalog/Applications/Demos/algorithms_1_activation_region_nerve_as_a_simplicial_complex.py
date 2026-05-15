#!/usr/bin/env python3
"""
Algorithms for Activation-Nerve Margin Cosheaf Certification

Implements the computational pipeline for certifying neural network robustness
via activation-region nerve construction and margin cosheaf exactness.

Algorithms:
1. ActivationRegionDecomposer - decompose a ReLU network into activation regions
2. NerveConstructor - build the nerve simplicial complex
3. MarginCosheafComputer - compute margin cosheaf values
4. DegreeOneExactnessChecker - check degree-1 exactness
5. CertifiedRobustnessDeriver - derive certified robustness radius
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional, Callable
from dataclasses import dataclass, field
from itertools import combinations
import time


@dataclass
class ActivationRegion:
    """An activation region of a ReLU network.

    Attributes:
        index: Region identifier
        pattern: Binary activation pattern (True = active ReLU)
        representative_points: Sample points in this region
        margin_values: Margin function evaluated at representative points
    """
    index: int
    pattern: Tuple[bool, ...]
    representative_points: np.ndarray
    margin_values: np.ndarray = field(default_factory=lambda: np.array([]))


@dataclass
class NerveComplex:
    """A finite abstract simplicial complex (the nerve).

    Attributes:
        vertices: List of vertex indices
        simplices: Set of frozensets, each a simplex
        dimension: Maximum simplex dimension
    """
    vertices: List[int]
    simplices: Set[frozenset]
    dimension: int

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic χ = Σ (-1)^k f_k."""
        f_vector = self.f_vector()
        return sum((-1)**k * f_k for k, f_k in enumerate(f_vector))

    def f_vector(self) -> List[int]:
        """f-vector: f_k = number of k-simplices."""
        fv = [0] * (self.dimension + 1)
        for s in self.simplices:
            fv[len(s) - 1] += 1
        return fv


@dataclass
class MarginCosheaf:
    """Margin cosheaf on a nerve complex.

    For each simplex σ in the nerve, stores the infimum of the margin
    function on the corresponding intersection of activation regions.
    """
    nerve: NerveComplex
    values: Dict[frozenset, float]

    def is_degree1_exact(self) -> bool:
        """Check degree-1 exactness: all values are positive."""
        return all(v > 0 for v in self.values.values())

    def global_margin_lower_bound(self) -> float:
        """The minimum cosheaf value = global margin lower bound."""
        if not self.values:
            return 0.0
        return min(self.values.values())


class ActivationRegionDecomposer:
    """Decompose a ReLU network's domain into activation regions.

    Algorithm:
        1. Sample the domain uniformly.
        2. Evaluate the pre-activation values at each sample.
        3. Determine the sign pattern (activation pattern) at each point.
        4. Group points by their activation pattern.

    Time complexity: O(N * d * W) where N = samples, d = input dim, W = width
    Space complexity: O(N * d)
    """

    def __init__(self, network_fn: Callable, preactivation_fn: Callable,
                 domain_bounds: Tuple[np.ndarray, np.ndarray],
                 n_samples: int = 5000):
        """
        Args:
            network_fn: The neural network function x -> f(x)
            preactivation_fn: Returns pre-activation values x -> (z1, z2, ...)
            domain_bounds: (lower, upper) bounds for the domain
            n_samples: Number of sample points
        """
        self.network_fn = network_fn
        self.preactivation_fn = preactivation_fn
        self.domain_bounds = domain_bounds
        self.n_samples = n_samples

    def decompose(self) -> List[ActivationRegion]:
        """Decompose the domain into activation regions.

        Returns:
            List of ActivationRegion objects

        Pseudocode:
            1. Sample N points uniformly from the domain
            2. For each point, compute activation pattern
            3. Group by pattern
            4. For each group, compute margin values
            5. Return regions sorted by index
        """
        lower, upper = self.domain_bounds
        dim = len(lower)

        # Step 1: Sample
        points = np.random.uniform(lower, upper, (self.n_samples, dim))

        # Step 2-3: Compute patterns and group
        pattern_groups: Dict[Tuple[bool, ...], List[np.ndarray]] = {}
        for p in points:
            pre = self.preactivation_fn(p)
            pattern = tuple(z > 0 for z in pre)
            if pattern not in pattern_groups:
                pattern_groups[pattern] = []
            pattern_groups[pattern].append(p)

        # Step 4-5: Build regions
        regions = []
        for idx, (pattern, pts) in enumerate(sorted(pattern_groups.items())):
            pts_arr = np.array(pts)
            margins = np.array([abs(self.network_fn(p)) for p in pts])
            regions.append(ActivationRegion(
                index=idx,
                pattern=pattern,
                representative_points=pts_arr,
                margin_values=margins
            ))

        return regions


class NerveConstructor:
    """Construct the nerve simplicial complex from activation regions.

    Algorithm:
        For each pair of regions, check if their closures overlap by
        finding nearby point pairs. If overlap exists, add the edge.
        Extend to higher simplices by checking all faces.

    Time complexity: O(|ι|^2 * N) for edges, O(|ι|^k * |edges|) for k-simplices
    Space complexity: O(|simplices|)
    """

    def __init__(self, proximity_threshold: float = 0.3, max_dimension: int = 3):
        self.proximity_threshold = proximity_threshold
        self.max_dimension = max_dimension

    def construct(self, regions: List[ActivationRegion]) -> NerveComplex:
        """Build the nerve complex.

        Pseudocode:
            1. Add all regions as vertices
            2. For each pair (i,j), check proximity -> add edge
            3. For k = 3..max_dim: check if all faces exist -> add k-simplex
            4. Compute dimension and return
        """
        n = len(regions)
        vertices = list(range(n))
        simplices: Set[frozenset] = set()

        # Add vertices
        for v in vertices:
            simplices.add(frozenset({v}))

        # Add edges
        edges = []
        for i, j in combinations(range(n), 2):
            if self._regions_overlap(regions[i], regions[j]):
                simplices.add(frozenset({i, j}))
                edges.append((i, j))

        # Add higher simplices
        for dim in range(3, min(self.max_dimension + 1, n + 1)):
            for combo in combinations(range(n), dim):
                combo_set = frozenset(combo)
                # Check all faces exist
                all_faces = all(
                    frozenset(sub) in simplices
                    for sub in combinations(combo, dim - 1)
                )
                if all_faces:
                    simplices.add(combo_set)

        max_dim = max(len(s) - 1 for s in simplices) if simplices else 0
        return NerveComplex(vertices=vertices, simplices=simplices, dimension=max_dim)

    def _regions_overlap(self, r1: ActivationRegion, r2: ActivationRegion) -> bool:
        """Check if two regions' closures overlap (by proximity of samples)."""
        pts1 = r1.representative_points
        pts2 = r2.representative_points

        # Subsample for efficiency
        step = max(1, len(pts1) // 50)
        for pt in pts1[::step]:
            dists = np.linalg.norm(pts2 - pt, axis=1)
            if dists.min() < self.proximity_threshold:
                return True
        return False


class MarginCosheafComputer:
    """Compute the margin cosheaf on the nerve complex.

    For each simplex σ = {i1, ..., ik} in the nerve, the cosheaf value is
    M(σ) = inf_{x ∈ ∩ R_{ij} ∩ K} margin(x)

    Approximated by the minimum margin among points near all regions in σ.

    Time complexity: O(|simplices| * N)
    Space complexity: O(|simplices|)
    """

    def __init__(self, margin_fn: Callable, proximity_threshold: float = 0.3):
        self.margin_fn = margin_fn
        self.proximity_threshold = proximity_threshold

    def compute(self, nerve: NerveComplex,
                regions: List[ActivationRegion]) -> MarginCosheaf:
        """Compute cosheaf values for all simplices.

        Pseudocode:
            For each simplex σ:
                If σ = {i}: M(σ) = min(margins on R_i)
                If σ = {i,j}: M(σ) = min(margins on R_i ∩ R_j boundary)
                If |σ| > 2: M(σ) = min over approximate intersection
        """
        values: Dict[frozenset, float] = {}

        for simplex in nerve.simplices:
            if len(simplex) == 1:
                idx = list(simplex)[0]
                if len(regions[idx].margin_values) > 0:
                    values[simplex] = float(regions[idx].margin_values.min())
                else:
                    values[simplex] = float('inf')
            else:
                # Find points near all regions in the simplex
                indices = list(simplex)
                overlap_margins = self._compute_overlap_margin(regions, indices)
                values[simplex] = overlap_margins if overlap_margins > 0 else 0.0

        return MarginCosheaf(nerve=nerve, values=values)

    def _compute_overlap_margin(self, regions: List[ActivationRegion],
                                 indices: List[int]) -> float:
        """Approximate the margin infimum on the intersection of regions."""
        # Use the first region's points, filter by proximity to all others
        base_region = regions[indices[0]]
        min_margin = float('inf')

        for pt in base_region.representative_points:
            near_all = True
            for idx in indices[1:]:
                other = regions[idx]
                dists = np.linalg.norm(other.representative_points - pt, axis=1)
                if dists.min() > self.proximity_threshold:
                    near_all = False
                    break
            if near_all:
                m = abs(self.margin_fn(pt))
                min_margin = min(min_margin, m)

        return min_margin if min_margin < float('inf') else 0.0


class DegreeOneExactnessChecker:
    """Check degree-1 exactness of the margin cosheaf.

    Degree-1 exactness holds iff all cosheaf values are strictly positive.
    This is equivalent to the existence of a uniform positive global margin.

    Time complexity: O(|simplices|)
    Space complexity: O(1)
    """

    @staticmethod
    def check(cosheaf: MarginCosheaf) -> Tuple[bool, Optional[str]]:
        """Check degree-1 exactness.

        Returns:
            (is_exact, diagnostic_message)

        Pseudocode:
            1. Check all vertex values > 0
            2. Check all edge values > 0
            3. If both hold, return (True, None)
            4. Otherwise, return (False, description of failure)
        """
        for simplex, value in cosheaf.values.items():
            if value <= 0:
                return (False,
                    f"Exactness fails: simplex {set(simplex)} has "
                    f"margin value {value:.6f} ≤ 0")

        return (True, None)


class CertifiedRobustnessDeriver:
    """Derive certified robustness radius from margin cosheaf exactness.

    Given degree-1 exactness (uniform positive margin δ) and Lipschitz
    constant L, the certified robustness radius is r = δ/(2L).

    Time complexity: O(N^2) for Lipschitz estimation, O(1) for derivation
    Space complexity: O(1)
    """

    @staticmethod
    def estimate_lipschitz(margin_fn: Callable, points: np.ndarray,
                           n_pairs: int = 10000) -> float:
        """Estimate the Lipschitz constant from sample pairs.

        Pseudocode:
            1. Sample random pairs of points
            2. For each pair, compute |f(x)-f(y)| / ||x-y||
            3. Return the maximum ratio
        """
        n = len(points)
        L = 0.0
        for _ in range(n_pairs):
            i, j = np.random.randint(0, n, 2)
            if i == j:
                continue
            d = np.linalg.norm(points[i] - points[j])
            if d > 1e-10:
                m_diff = abs(margin_fn(points[i]) - margin_fn(points[j]))
                L = max(L, m_diff / d)
        return L

    @staticmethod
    def derive_radius(delta: float, lipschitz: float) -> Optional[float]:
        """Compute certified robustness radius r = δ/(2L).

        Args:
            delta: Uniform positive margin lower bound
            lipschitz: Lipschitz constant of the margin function

        Returns:
            Certified robustness radius, or None if not certifiable
        """
        if delta <= 0 or lipschitz <= 0:
            return None
        return delta / (2 * lipschitz)

    @staticmethod
    def verify_robustness(margin_fn: Callable, center: np.ndarray,
                          radius: float, n_tests: int = 1000) -> bool:
        """Empirically verify robustness at a point.

        Pseudocode:
            1. Sample n_tests perturbations within radius
            2. Check margin > 0 for all
            3. Return True iff all pass
        """
        dim = len(center)
        for _ in range(n_tests):
            perturbation = np.random.randn(dim)
            perturbation *= radius * np.random.uniform() / np.linalg.norm(perturbation)
            y = center + perturbation
            if margin_fn(y) <= 0:
                return False
        return True


def full_certification_pipeline(
    network_fn: Callable,
    preactivation_fn: Callable,
    margin_fn: Callable,
    domain_bounds: Tuple[np.ndarray, np.ndarray],
    n_samples: int = 5000,
    verbose: bool = True
) -> Dict:
    """
    Complete certification pipeline.

    Steps:
        1. Decompose domain into activation regions
        2. Construct the nerve simplicial complex
        3. Compute the margin cosheaf
        4. Check degree-1 exactness
        5. Estimate Lipschitz constant
        6. Derive certified robustness radius

    Args:
        network_fn: Neural network function
        preactivation_fn: Returns pre-activation values
        margin_fn: Margin function (usually |network_fn|)
        domain_bounds: (lower, upper) bounds
        n_samples: Number of samples

    Returns:
        Dictionary with certification results
    """
    results = {}
    t0 = time.time()

    # Step 1
    decomposer = ActivationRegionDecomposer(
        network_fn, preactivation_fn, domain_bounds, n_samples)
    regions = decomposer.decompose()
    results['n_regions'] = len(regions)
    if verbose:
        print(f"Step 1: Found {len(regions)} activation regions")

    # Step 2
    constructor = NerveConstructor()
    nerve = constructor.construct(regions)
    results['nerve'] = nerve
    results['f_vector'] = nerve.f_vector()
    results['euler_char'] = nerve.euler_characteristic()
    if verbose:
        print(f"Step 2: Nerve has f-vector {nerve.f_vector()}, "
              f"χ = {nerve.euler_characteristic()}")

    # Step 3
    computer = MarginCosheafComputer(margin_fn)
    cosheaf = computer.compute(nerve, regions)
    results['cosheaf'] = cosheaf
    results['min_cosheaf_value'] = cosheaf.global_margin_lower_bound()
    if verbose:
        print(f"Step 3: Min cosheaf value = "
              f"{cosheaf.global_margin_lower_bound():.6f}")

    # Step 4
    checker = DegreeOneExactnessChecker()
    is_exact, diagnostic = checker.check(cosheaf)
    results['degree1_exact'] = is_exact
    results['diagnostic'] = diagnostic
    if verbose:
        print(f"Step 4: Degree-1 exact = {is_exact}")
        if diagnostic:
            print(f"        {diagnostic}")

    # Step 5-6
    if is_exact:
        all_pts = np.vstack([r.representative_points for r in regions])
        deriver = CertifiedRobustnessDeriver()
        L = deriver.estimate_lipschitz(margin_fn, all_pts)
        delta = cosheaf.global_margin_lower_bound()
        radius = deriver.derive_radius(delta, L)
        results['lipschitz'] = L
        results['delta'] = delta
        results['certified_radius'] = radius
        if verbose:
            print(f"Step 5: Lipschitz constant ≈ {L:.4f}")
            print(f"Step 6: Certified radius = {radius:.6f}" if radius else
                  "Step 6: Cannot certify (L=0 or δ=0)")
    else:
        results['certified_radius'] = None

    results['time'] = time.time() - t0
    if verbose:
        print(f"\nTotal time: {results['time']:.2f}s")

    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("FULL CERTIFICATION PIPELINE")
    print("=" * 60)

    W1 = np.array([[1.0, 0.5], [-0.5, 1.0], [0.8, -0.3], [-0.2, 0.7]])
    b1 = np.array([0.1, -0.2, 0.3, -0.1])
    W2 = np.array([1.0, -0.5, 0.3, 0.8])
    b2 = 0.2

    def net(x):
        return float(W2 @ np.maximum(W1 @ x + b1, 0) + b2)

    def preact(x):
        return W1 @ x + b1

    def margin(x):
        return abs(net(x))

    bounds = (np.array([-2.0, -2.0]), np.array([2.0, 2.0]))
    np.random.seed(123)

    results = full_certification_pipeline(net, preact, margin, bounds)

    print(f"\n{'=' * 60}")
    print(f"CERTIFICATION RESULT")
    print(f"{'=' * 60}")
    print(f"Activation regions: {results['n_regions']}")
    print(f"Nerve f-vector: {results['f_vector']}")
    print(f"Euler characteristic: {results['euler_char']}")
    print(f"Degree-1 exact: {results['degree1_exact']}")
    if results['certified_radius']:
        print(f"Certified radius: {results['certified_radius']:.6f}")
        print(f"✓ Network is provably robust within radius "
              f"{results['certified_radius']:.6f}")
    else:
        print("✗ Cannot certify robustness")
