#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof Compression

Implements the core algorithms from the research paper:
1. Certified proof compression with contraction certificate
2. Minimal separating observer family construction
3. Compression height computation
4. Operadic realization depth analysis
"""

from typing import List, Dict, Set, Tuple, Callable, Optional
import math


def certified_compression(
    x: object,
    compress: Callable,
    dist: Callable,
    q: float,
    epsilon: float,
    max_iter: int = 1000
) -> Tuple[object, float, int]:
    """
    Certified Proof Compression Algorithm.

    Given a proof state x, a compression operator C, an ultrametric distance d,
    a contraction constant q < 1, and a tolerance ε > 0, compute the compressed
    state C^N(x) together with a certified bound on the compression error.

    By iterate_contraction_step:
        d(C^N(x), C^(N+1)(x)) ≤ q^N · d(x, C(x))

    Stopping criterion: q^N · d(x, C(x)) ≤ ε

    Args:
        x: Initial proof state
        compress: Compression operator C
        dist: Ultrametric distance function d
        q: Contraction constant (0 ≤ q < 1)
        epsilon: Desired tolerance
        max_iter: Maximum iterations

    Returns:
        (compressed_state, certificate_bound, iterations)
        where certificate_bound ≤ ε guarantees d(result, C(result)) ≤ certificate_bound

    Complexity: O(N) applications of C, where N = ⌈log(ε/d(x,Cx)) / log(q)⌉
    """
    assert 0 <= q < 1, f"Contraction constant must be in [0,1), got {q}"
    assert epsilon > 0, f"Tolerance must be positive, got {epsilon}"

    cx = compress(x)
    d_initial = dist(x, cx)

    if d_initial == 0:
        return x, 0.0, 0

    # Compute required iterations: q^N · d_initial ≤ ε
    # N ≥ log(ε / d_initial) / log(q)
    if q == 0:
        N_required = 1
    else:
        N_required = math.ceil(math.log(epsilon / d_initial) / math.log(q))
        N_required = max(1, N_required)

    N_required = min(N_required, max_iter)

    current = x
    for _ in range(N_required):
        current = compress(current)

    certificate = q ** N_required * d_initial
    return current, certificate, N_required


def minimal_separating_observers(
    fixed_points: List[object],
    candidate_observers: List[Callable],
    equality_check: Callable = lambda a, b: a == b
) -> List[Callable]:
    """
    Minimal Separating Observer Family Construction.

    Given a finite set of fixed points and candidate observer functions,
    greedily select a minimal subset that separates all distinct pairs.

    By observer_separation_reconstruction, a finite subfamily always suffices.

    Args:
        fixed_points: List of fixed points of C
        candidate_observers: List of observer functions α → β
        equality_check: How to check equality of observer outputs

    Returns:
        Minimal list of observers separating all fixed points

    Complexity: O(|F|² · |candidates|) in the worst case
    """
    n = len(fixed_points)
    unseparated: Set[Tuple[int, int]] = set()
    for i in range(n):
        for j in range(i + 1, n):
            unseparated.add((i, j))

    selected = []

    while unseparated:
        # Greedily pick the observer that separates the most pairs
        best_obs = None
        best_separated = set()

        for obs in candidate_observers:
            separated_by_obs = set()
            for (i, j) in unseparated:
                if not equality_check(obs(fixed_points[i]), obs(fixed_points[j])):
                    separated_by_obs.add((i, j))
            if len(separated_by_obs) > len(best_separated):
                best_obs = obs
                best_separated = separated_by_obs

        if best_obs is None:
            break  # No observer can separate remaining pairs

        selected.append(best_obs)
        unseparated -= best_separated

    return selected


def compression_height(
    points: List[object],
    compress: Callable,
    max_height: Optional[int] = None
) -> int:
    """
    Compute the compression height: minimum n such that C^n = C^(n+1) pointwise.

    By compression_eventually_stabilizes, this is finite for finite types
    with ultrametric contraction.

    Args:
        points: All elements of the finite type
        compress: Compression operator
        max_height: Upper bound on search (defaults to |points|)

    Returns:
        Compression height n

    Complexity: O(|points| · n) applications of C
    """
    if max_height is None:
        max_height = len(points)

    for n in range(max_height + 1):
        stabilized = True
        for x in points:
            cn = x
            for _ in range(n):
                cn = compress(cn)
            cn1 = compress(cn)
            if cn != cn1:
                stabilized = False
                break
        if stabilized:
            return n

    return max_height


def analyze_operadic_depth(
    points: List[object],
    compress: Callable,
    dist: Callable,
    q: float
) -> Dict:
    """
    Analyze the operadic realization depth of a compression system.

    Returns a dictionary with:
    - compression_height: minimum stabilization iterations
    - fixed_points: list of fixed points
    - fixed_point_count: number of distinct compression classes
    - contraction_constant: q
    - certified_bound_at_height: q^h · max_distance

    Args:
        points: All elements of the type
        compress: Compression operator
        dist: Ultrametric distance
        q: Contraction constant

    Returns:
        Analysis dictionary
    """
    height = compression_height(points, compress)
    fps = [x for x in points if compress(x) == x]

    max_dist = 0
    for x in points:
        d = dist(x, compress(x))
        max_dist = max(max_dist, d)

    return {
        'compression_height': height,
        'fixed_points': fps,
        'fixed_point_count': len(fps),
        'contraction_constant': q,
        'max_initial_distance': max_dist,
        'certified_bound_at_height': q ** height * max_dist,
        'operadic_depth_bound': len(points),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    # Example: 5-point system with discrete ultrametric
    points = ['a', 'b', 'c', 'd', 'r']
    compress_map = {'a': 'r', 'b': 'r', 'c': 'r', 'd': 'r', 'r': 'r'}

    def compress(x):
        return compress_map[x]

    def dist(x, y):
        return 0.0 if x == y else 8.0

    print("=== Certified Compression ===")
    result, cert, iters = certified_compression('a', compress, dist, 0.5, 1.0)
    print(f"  Input: 'a', Output: '{result}', Certificate: {cert:.4f}, Iterations: {iters}")

    print("\n=== Compression Height ===")
    h = compression_height(points, compress)
    print(f"  Height: {h}")

    print("\n=== Operadic Depth Analysis ===")
    analysis = analyze_operadic_depth(points, compress, dist, 0.5)
    for k, v in analysis.items():
        print(f"  {k}: {v}")

    print("\n=== Observer Separation ===")
    fps = [x for x in points if compress(x) == x]
    # Use identity as candidate observer
    observers = minimal_separating_observers(
        fps,
        [lambda x, i=i: (x == points[i]) for i in range(len(points))]
    )
    print(f"  Fixed points: {fps}")
    print(f"  Observers needed: {len(observers)}")
