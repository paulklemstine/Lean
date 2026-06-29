"""
Incongruity Resolution Theory — Algorithms
============================================
Implements core algorithms from the research paper.
"""

import math
from typing import List, Tuple, Callable, Optional


def euclidean_distance(a: List[float], b: List[float]) -> float:
    """Euclidean distance between two vectors."""
    return math.sqrt(sum((ai - bi)**2 for ai, bi in zip(a, b)))


class IncongruityTriple:
    """A triple (setup, expectation, punchline) in a metric space.
    
    Attributes:
        setup: The setup point
        expectation: The expected resolution  
        punchline: The actual resolution (twist)
        dist_fn: The metric function
    """
    
    def __init__(self, setup, expectation, punchline,
                 dist_fn: Callable = lambda a, b: abs(a - b)):
        self.setup = setup
        self.expectation = expectation
        self.punchline = punchline
        self.dist_fn = dist_fn
    
    @property
    def surprise(self) -> float:
        """Distance from expectation to punchline."""
        return self.dist_fn(self.expectation, self.punchline)
    
    @property
    def tension(self) -> float:
        """Distance from setup to expectation."""
        return self.dist_fn(self.setup, self.expectation)
    
    @property
    def arc(self) -> float:
        """Distance from setup to punchline."""
        return self.dist_fn(self.setup, self.punchline)
    
    @property
    def defect(self) -> float:
        """Triangle defect: tension + surprise - arc >= 0."""
        return self.tension + self.surprise - self.arc
    
    @property
    def comedy_ratio(self) -> float:
        """Surprise / arc. Measures humor efficiency."""
        return self.surprise / self.arc if self.arc > 1e-15 else 0.0
    
    def __repr__(self):
        return (f"IncongruityTriple(s={self.setup}, e={self.expectation}, "
                f"p={self.punchline}, surprise={self.surprise:.4f}, "
                f"defect={self.defect:.4f}, ratio={self.comedy_ratio:.4f})")


def comedy_polytope_membership(a: float, b: float, c: float) -> bool:
    """Check if (a, b, c) is in the Comedy Polytope.
    
    A triple (tension, surprise, arc) is valid iff all three
    triangle inequalities hold and all values are nonneg.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        a: tension value
        b: surprise value
        c: arc value
    
    Returns:
        True if (a, b, c) is in the comedy polytope
    """
    return (a >= 0 and b >= 0 and c >= 0 and
            a + b >= c and a + c >= b and b + c >= a)


def tropical_aggregate(values: List[float]) -> float:
    """Tropical (max-plus) aggregation of comedy values.
    
    In the tropical semiring (R ∪ {-∞}, max, +), aggregation
    is simply the maximum.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        values: List of comedy values
    
    Returns:
        The tropical sum (maximum) of the values
    """
    if not values:
        return float('-inf')
    return max(values)


def tropical_product(a: float, b: float) -> float:
    """Tropical product (conventional addition).
    
    In the max-plus semiring, "multiplication" is addition.
    """
    return a + b


def comedy_chain_leverage(points: list, dist_fn: Callable) -> Tuple[float, float, float]:
    """Compute the leverage ratio of a comedy chain.
    
    Given a chain of points (joke sequence), computes:
    - Total path length (sum of consecutive distances)
    - Endpoint distance 
    - Leverage ratio (path / endpoint)
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        points: Ordered sequence of points
        dist_fn: Distance function
    
    Returns:
        (path_length, endpoint_distance, leverage_ratio)
    """
    if len(points) < 2:
        return (0.0, 0.0, 1.0)
    
    path_length = sum(dist_fn(points[i], points[i+1]) for i in range(len(points)-1))
    endpoint_dist = dist_fn(points[0], points[-1])
    ratio = path_length / endpoint_dist if endpoint_dist > 1e-15 else float('inf')
    
    return (path_length, endpoint_dist, ratio)


def mean_absolute_deviation(data: List[float]) -> float:
    """Compute the Mean Absolute Deviation (MAD) from the mean.
    
    MAD = (1/n) ∑ |xᵢ - μ|
    
    Time complexity: O(n)
    Space complexity: O(1)
    """
    n = len(data)
    if n == 0:
        return 0.0
    mu = sum(data) / n
    return sum(abs(x - mu) for x in data) / n


def root_mean_square_deviation(data: List[float]) -> float:
    """Compute the Root Mean Square deviation (standard deviation).
    
    σ = √((1/n) ∑ (xᵢ - μ)²)
    
    Time complexity: O(n)
    Space complexity: O(1)
    """
    n = len(data)
    if n == 0:
        return 0.0
    mu = sum(data) / n
    return math.sqrt(sum((x - mu)**2 for x in data) / n)


def optimal_comedy_triple(points: list, dist_fn: Callable) -> Optional[IncongruityTriple]:
    """Find the triple maximizing comedy ratio among given points.
    
    Exhaustive search over all ordered triples.
    
    Time complexity: O(n³)
    Space complexity: O(1)
    
    Args:
        points: List of points in the metric space
        dist_fn: Distance function
    
    Returns:
        The triple with maximum comedy ratio, or None
    """
    best = None
    best_ratio = -1.0
    
    for s in points:
        for e in points:
            for p in points:
                j = IncongruityTriple(s, e, p, dist_fn)
                if j.arc > 1e-10 and j.comedy_ratio > best_ratio:
                    best_ratio = j.comedy_ratio
                    best = j
    
    return best


def verify_tropical_cauchy_schwarz(a1: float, a2: float, 
                                    b1: float, b2: float) -> bool:
    """Verify the tropical Cauchy-Schwarz inequality.
    
    max(a₁+b₁, a₂+b₂) ≤ max(a₁,a₂) + max(b₁,b₂)
    
    Returns True if the inequality holds.
    """
    lhs = max(a1 + b1, a2 + b2)
    rhs = max(a1, a2) + max(b1, b2)
    return lhs <= rhs + 1e-15  # tolerance for floating point


def comedy_polytope_vertices() -> List[Tuple[float, float, float]]:
    """Return the vertices/rays of the comedy polytope (a convex cone).
    
    The comedy polytope is the intersection of:
    - a, b, c >= 0
    - a + b >= c, a + c >= b, b + c >= a
    
    As a cone, its extreme rays are:
    - (1, 0, 1), (0, 1, 1), (1, 1, 0) — degenerate triangles
    """
    return [(1, 0, 1), (0, 1, 1), (1, 1, 0)]


if __name__ == "__main__":
    # Example usage
    print("=== Incongruity Resolution Theory — Algorithm Demos ===\n")
    
    # Create a joke triple
    j = IncongruityTriple(0, 5, 12)
    print(f"Joke triple: {j}")
    print(f"  In comedy polytope: {comedy_polytope_membership(j.tension, j.surprise, j.arc)}")
    
    # Comedy chain
    points = [0, 3, 1, 7, 2, 10]
    path, endpt, leverage = comedy_chain_leverage(points, lambda a, b: abs(a-b))
    print(f"\nComedy chain {points}:")
    print(f"  Path length: {path}, Endpoint dist: {endpt}, Leverage: {leverage:.2f}x")
    
    # MAD vs RMS (surprise-entropy duality)
    data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
    mad = mean_absolute_deviation(data)
    rms = root_mean_square_deviation(data)
    print(f"\nSurprise-Entropy Duality for {data}:")
    print(f"  MAD = {mad:.4f} <= σ = {rms:.4f}: {mad <= rms + 1e-10}")
    
    # Tropical aggregation
    comedy_values = [3.2, 7.1, 2.5, 8.3, 1.0]
    print(f"\nTropical aggregation of {comedy_values}:")
    print(f"  max (tropical sum) = {tropical_aggregate(comedy_values)}")
    
    # Find optimal triple
    pts = list(range(0, 20, 3))
    best = optimal_comedy_triple(pts, lambda a, b: abs(a-b))
    if best:
        print(f"\nOptimal comedy triple from {pts}: {best}")
