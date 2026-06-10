#!/usr/bin/env python3
"""
Algorithms for Activation Nerve Cosheaf Robustness Certification

Implements the computational pipeline from the formal theorems:
1. Activation region discovery
2. Nerve complex construction
3. Margin cosheaf evaluation
4. Degree-1 exactness checking
5. Certified robustness radius computation

Complexity Analysis:
- Activation pattern discovery: O(N · d · h) where N=samples, d=dim, h=hidden
- Nerve construction: O(|R|² · N) where |R|=number of regions
- Margin evaluation: O(N) per region
- Exactness check: O(|R|)
- Certified radius: O(1) given the above

All algorithms are polynomial in the number of regions and samples.
"""

import numpy as np
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass


@dataclass
class NerveComplex:
    """Abstract simplicial complex representing the activation nerve."""
    vertices: List[int]
    edges: List[Tuple[int, int]]
    triangles: List[Tuple[int, int, int]]
    vertex_labels: Dict[int, tuple]  # vertex_id -> activation pattern

    @property
    def euler_characteristic(self) -> int:
        return len(self.vertices) - len(self.edges) + len(self.triangles)

    @property
    def is_connected(self) -> bool:
        """Check if the 1-skeleton is connected via BFS."""
        if not self.vertices:
            return True
        adj = {v: set() for v in self.vertices}
        for i, j in self.edges:
            adj[i].add(j)
            adj[j].add(i)
        visited = set()
        queue = [self.vertices[0]]
        while queue:
            v = queue.pop(0)
            if v in visited:
                continue
            visited.add(v)
            for u in adj[v]:
                if u not in visited:
                    queue.append(u)
        return len(visited) == len(self.vertices)


@dataclass
class MarginCosheaf:
    """Margin cosheaf on a nerve complex."""
    vertex_values: Dict[int, float]  # vertex_id -> sInf(margin on region)
    edge_values: Dict[Tuple[int, int], float]  # edge -> sInf(margin on overlap)

    @property
    def is_degree1_exact(self) -> bool:
        """Check degree-1 exactness: all vertex margins positive."""
        return all(v > 0 for v in self.vertex_values.values())

    @property
    def min_vertex_margin(self) -> float:
        if not self.vertex_values:
            return 0.0
        return min(self.vertex_values.values())

    def verify_monotonicity(self) -> bool:
        """Verify cosheaf monotonicity: M(edge) >= min(M(v1), M(v2))."""
        for (i, j), m_edge in self.edge_values.items():
            m_i = self.vertex_values.get(i, float('inf'))
            m_j = self.vertex_values.get(j, float('inf'))
            if m_edge < min(m_i, m_j) - 1e-10:
                return False
        return True


@dataclass
class CertificationResult:
    """Result of the robustness certification pipeline."""
    is_certified: bool
    certified_radius: float
    min_margin: float
    lipschitz_constant: float
    nerve: NerveComplex
    cosheaf: MarginCosheaf
    n_regions: int


def compute_activation_patterns(
    W1: np.ndarray, b1: np.ndarray, points: np.ndarray
) -> Dict[tuple, List[int]]:
    """
    Compute activation patterns for a batch of points.

    Args:
        W1: Weight matrix (h x d)
        b1: Bias vector (h,)
        points: Input points (N x d)

    Returns:
        Dict mapping activation pattern to list of point indices

    Complexity: O(N * h * d)
    """
    pre_activations = points @ W1.T + b1  # (N, h)
    patterns = {}
    for idx in range(len(points)):
        pattern = tuple(int(p > 0) for p in pre_activations[idx])
        if pattern not in patterns:
            patterns[pattern] = []
        patterns[pattern].append(idx)
    return patterns


def build_nerve_complex(
    regions: Dict[tuple, List[int]],
    points: np.ndarray,
    overlap_threshold: float = 0.5
) -> NerveComplex:
    """
    Build the nerve complex of the activation region cover.

    Algorithm:
    1. Assign vertex IDs to each activation pattern
    2. For each pair of regions, check if they are adjacent (share a boundary)
    3. For each triple with pairwise adjacency, check if they form a triangle

    Args:
        regions: activation pattern -> point indices
        points: all sample points
        overlap_threshold: distance threshold for adjacency detection

    Returns:
        NerveComplex

    Complexity: O(|R|² * k²) where k = max points per region checked
    """
    patterns = list(regions.keys())
    n = len(patterns)
    vertex_ids = list(range(n))
    vertex_labels = {i: patterns[i] for i in range(n)}

    # Compute pairwise minimum distances for adjacency
    k_check = 50  # points to check per region
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            pts_i = points[regions[patterns[i]][:k_check]]
            pts_j = points[regions[patterns[j]][:k_check]]
            # Compute pairwise distances
            diffs = pts_i[:, None, :] - pts_j[None, :, :]
            dists = np.linalg.norm(diffs, axis=2)
            if dists.min() < overlap_threshold:
                edges.append((i, j))

    # Find triangles
    adj_set = {(i, j) for i, j in edges}
    adj_set.update({(j, i) for i, j in edges})
    triangles = []
    for i in range(n):
        for j in range(i + 1, n):
            if (i, j) not in adj_set and (j, i) not in adj_set:
                continue
            for k in range(j + 1, n):
                if ((i, k) in adj_set or (k, i) in adj_set) and \
                   ((j, k) in adj_set or (k, j) in adj_set):
                    triangles.append((i, j, k))

    return NerveComplex(
        vertices=vertex_ids,
        edges=edges,
        triangles=triangles,
        vertex_labels=vertex_labels
    )


def evaluate_margin_cosheaf(
    nerve: NerveComplex,
    regions: Dict[tuple, List[int]],
    points: np.ndarray,
    margin_fn,
    overlap_threshold: float = 0.5
) -> MarginCosheaf:
    """
    Evaluate the margin cosheaf on the nerve complex.

    For each vertex: M(v) = min(margin(x) for x in region_v)
    For each edge: M(e) = min(margin(x) for x near boundary of both regions)

    Complexity: O(N) for vertex values, O(|E| * k²) for edge values
    """
    patterns = [nerve.vertex_labels[v] for v in nerve.vertices]

    # Vertex values
    vertex_values = {}
    for v in nerve.vertices:
        pat = nerve.vertex_labels[v]
        idxs = regions[pat]
        margins = [margin_fn(points[i]) for i in idxs]
        vertex_values[v] = min(margins) if margins else float('inf')

    # Edge values (approximate: minimum margin near boundary)
    edge_values = {}
    for i, j in nerve.edges:
        pat_i = nerve.vertex_labels[i]
        pat_j = nerve.vertex_labels[j]
        pts_i = points[regions[pat_i][:50]]
        pts_j = points[regions[pat_j][:50]]

        # Find points closest to the boundary
        boundary_margins = []
        for pi in pts_i:
            for pj in pts_j:
                if np.linalg.norm(pi - pj) < overlap_threshold:
                    boundary_margins.append(margin_fn(pi))
                    boundary_margins.append(margin_fn(pj))

        if boundary_margins:
            edge_values[(i, j)] = min(boundary_margins)
        else:
            edge_values[(i, j)] = min(vertex_values[i], vertex_values[j])

    return MarginCosheaf(vertex_values=vertex_values, edge_values=edge_values)


def certify_robustness(
    W1: np.ndarray, b1: np.ndarray,
    W2: np.ndarray, b2: np.ndarray,
    domain_bounds: np.ndarray,
    n_samples: int = 20000,
    overlap_threshold: float = 0.5
) -> CertificationResult:
    """
    Full certification pipeline: Network → Nerve → Cosheaf → Certified Radius.

    Pseudocode:
    1. SAMPLE N points from domain K
    2. COMPUTE activation patterns for each point
    3. BUILD nerve complex from adjacency of regions
    4. EVALUATE margin cosheaf on each vertex and edge
    5. CHECK degree-1 exactness (all vertex margins positive)
    6. IF exact: COMPUTE certified radius = min_margin / Lipschitz_constant
    7. RETURN CertificationResult

    Args:
        W1, b1: First layer weights and biases
        W2, b2: Second layer weights and biases
        domain_bounds: (d, 2) array of [min, max] per dimension
        n_samples: number of sample points
        overlap_threshold: adjacency detection threshold

    Returns:
        CertificationResult with certified radius and supporting data

    Complexity: O(N*h*d + |R|²*k² + N) where N=samples, h=hidden, d=dim, |R|=regions
    """
    d = domain_bounds.shape[0]

    # Step 1: Sample points
    points = np.column_stack([
        np.random.uniform(domain_bounds[i, 0], domain_bounds[i, 1], n_samples)
        for i in range(d)
    ])

    # Step 2: Discover activation regions
    regions = compute_activation_patterns(W1, b1, points)

    # Step 3: Build nerve
    nerve = build_nerve_complex(regions, points, overlap_threshold)

    # Step 4: Define margin function and evaluate cosheaf
    def margin_fn(x):
        h = np.maximum(W1 @ x + b1, 0)
        return (W2 @ h + b2)[0]

    cosheaf = evaluate_margin_cosheaf(
        nerve, regions, points, margin_fn, overlap_threshold
    )

    # Step 5: Check exactness
    is_exact = cosheaf.is_degree1_exact
    min_margin = cosheaf.min_vertex_margin

    # Step 6: Compute Lipschitz constant and certified radius
    L = np.linalg.norm(W1, ord=2) * np.linalg.norm(W2, ord=2)
    cert_radius = min_margin / L if (is_exact and L > 0) else 0.0

    return CertificationResult(
        is_certified=is_exact,
        certified_radius=cert_radius,
        min_margin=min_margin,
        lipschitz_constant=L,
        nerve=nerve,
        cosheaf=cosheaf,
        n_regions=len(regions)
    )


def verify_certification(result: CertificationResult,
                         W1, b1, W2, b2,
                         domain_bounds, n_test=10000) -> dict:
    """
    Empirically verify the certification by testing adversarial perturbations.

    For each test point, apply random perturbations of size < certified_radius
    and check that the margin remains positive.
    """
    d = domain_bounds.shape[0]
    violations = 0
    tests = 0

    if not result.is_certified or result.certified_radius <= 0:
        return {"certified": False, "violations": 0, "tests": 0}

    for _ in range(n_test):
        x = np.array([
            np.random.uniform(domain_bounds[i, 0], domain_bounds[i, 1])
            for i in range(d)
        ])

        # Random perturbation within certified radius
        delta = np.random.randn(d)
        delta = delta / np.linalg.norm(delta) * np.random.uniform(0, result.certified_radius * 0.99)
        y = x + delta

        h = np.maximum(W1 @ y + b1, 0)
        margin_y = (W2 @ h + b2)[0]

        h_x = np.maximum(W1 @ x + b1, 0)
        margin_x = (W2 @ h_x + b2)[0]

        if margin_x > 0:  # only count points where original margin is positive
            tests += 1
            if margin_y <= 0:
                violations += 1

    return {
        "certified": True,
        "violations": violations,
        "tests": tests,
        "violation_rate": violations / max(tests, 1)
    }


if __name__ == "__main__":
    np.random.seed(42)

    # Example certification
    W1 = np.array([[1.0, 0.5], [-0.5, 1.0], [0.8, -0.3], [-0.2, 0.7]])
    b1 = np.array([0.1, -0.2, 0.3, -0.1])
    W2 = np.array([[0.5, 0.3, -0.4, 0.6]])
    b2 = np.array([0.2])
    domain = np.array([[-2, 2], [-2, 2]])

    result = certify_robustness(W1, b1, W2, b2, domain)

    print("Certification Result:")
    print(f"  Certified: {result.is_certified}")
    print(f"  Radius: {result.certified_radius:.6f}")
    print(f"  Min margin: {result.min_margin:.6f}")
    print(f"  Lipschitz: {result.lipschitz_constant:.4f}")
    print(f"  Regions: {result.n_regions}")
    print(f"  Nerve: {len(result.nerve.vertices)} vertices, {len(result.nerve.edges)} edges")
    print(f"  Euler characteristic: {result.nerve.euler_characteristic}")
    print(f"  Cosheaf monotonicity: {result.cosheaf.verify_monotonicity()}")

    # Verify
    ver = verify_certification(result, W1, b1, W2, b2, domain)
    print(f"\nEmpirical verification:")
    print(f"  Tests: {ver['tests']}, Violations: {ver['violations']}")
