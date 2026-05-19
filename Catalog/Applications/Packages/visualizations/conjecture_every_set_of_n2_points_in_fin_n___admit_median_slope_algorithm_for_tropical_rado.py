"""
Tropical Radon Partition — Algorithms

Implements the median-slope algorithm for finding tropical Radon partitions
in ℚ^n and related tropical convexity computations.
"""

from typing import List, Tuple, Optional, Set
from itertools import combinations
import heapq


def tropical_combination(points: List[List[float]],
                          weights: List[float]) -> List[float]:
    """Compute a tropical (min-plus) convex combination.

    z[k] = min_i (weights[i] + points[i][k])

    Args:
        points: m points in ℚ^n (list of lists).
        weights: m scalar weights.

    Returns:
        The tropical combination z ∈ ℚ^n.

    Time: O(m·n)
    Space: O(n)
    """
    m = len(points)
    n = len(points[0])
    z = [float('inf')] * n
    for k in range(n):
        for i in range(m):
            val = weights[i] + points[i][k]
            if val < z[k]:
                z[k] = val
    return z


def tropical_hull_membership_singleton(z: List[float],
                                        s: List[float]) -> Optional[float]:
    """Check if z is in tropConvHull({s}).

    tropConvHull({s}) = {s + c·1 : c ∈ ℚ}. So z ∈ hull iff z - s is constant.

    Returns the constant c if z is in the hull, else None.

    Time: O(n)
    """
    n = len(z)
    if n == 0:
        return 0.0
    c = z[0] - s[0]
    for k in range(1, n):
        if abs((z[k] - s[k]) - c) > 1e-12:
            return None
    return c


def median_slope_partition(points: List[List[float]],
                            coord0: int = 0,
                            coord1: int = 1) -> dict:
    """Median-slope algorithm for tropical Radon partition projection.

    Given m ≥ 3 points in ℚ^n and two coordinate indices, finds a
    Radon partition that works for those two coordinates.

    Algorithm:
    1. Compute slopes α_i = p_i[coord1] - p_i[coord0].
    2. Sort by α to get π(0), ..., π(m-1).
    3. Set i_med = π(1), j_lo = π(0), j_hi = π(2).
    4. Return A = {i_med}, B = {j_lo, j_hi}.

    Time: O(m log m + n)
    Space: O(m)

    Returns:
        Dictionary with partition info.
    """
    m = len(points)
    assert m >= 3, "Need at least 3 points"

    # Compute slopes
    slopes = [(points[i][coord1] - points[i][coord0], i) for i in range(m)]
    slopes.sort()

    i_lo = slopes[0][1]
    i_med = slopes[1][1]
    i_hi = slopes[2][1]

    alpha_lo = slopes[0][0]
    alpha_med = slopes[1][0]
    alpha_hi = slopes[2][0]

    # Compute weights for B = {i_hi, i_lo}
    w_hi = points[i_med][coord0] - points[i_hi][coord0]
    w_lo = points[i_med][coord1] - points[i_lo][coord1]

    # Witness
    z = points[i_med][:]

    # Verify at the two coordinates
    z0_check = min(w_hi + points[i_hi][coord0], w_lo + points[i_lo][coord0])
    z1_check = min(w_hi + points[i_hi][coord1], w_lo + points[i_lo][coord1])

    return {
        'A': [i_med],
        'B': [i_hi, i_lo],
        'z': z,
        'weights_A': [0.0],
        'weights_B': [w_hi, w_lo],
        'verified_coords': [coord0, coord1],
        'coord0_ok': abs(z0_check - z[coord0]) < 1e-10,
        'coord1_ok': abs(z1_check - z[coord1]) < 1e-10,
    }


def find_radon_partition(points: List[List[float]]) -> Optional[dict]:
    """Find a tropical Radon partition for points in ℚ^n.

    Strategy:
    1. If n = 0: trivial (all points equal).
    2. If n = 1: any two nonempty disjoint sets work.
    3. If n = 2: use median_slope_partition.
    4. If n ≥ 3: try all pairs of coordinates with median slope.
       Check if the resulting z also works at other coordinates.
       Falls back to brute-force search over small partitions.

    Time: O(m^2 · n) expected for small m.
    Space: O(m · n)
    """
    m = len(points)
    n = len(points[0]) if m > 0 else 0

    if m < 2:
        return None

    # Case n = 0: unique point
    if n == 0:
        return {'A': [0], 'B': [1], 'z': [], 'weights_A': [0], 'weights_B': [0]}

    # Case n = 1: hull of any nonempty set = all of ℚ^1
    if n == 1:
        return {
            'A': [0], 'B': [1],
            'z': [points[0][0]],
            'weights_A': [0],
            'weights_B': [points[0][0] - points[1][0]],
        }

    # Check for tropically equivalent pairs first
    for i, j in combinations(range(m), 2):
        diff = [points[i][k] - points[j][k] for k in range(n)]
        if all(abs(diff[k] - diff[0]) < 1e-12 for k in range(n)):
            return {
                'A': [i], 'B': [j],
                'z': points[i][:],
                'weights_A': [0],
                'weights_B': [diff[0]],
            }

    # For n ≥ 2: try median slope on all coordinate pairs
    if m >= 3:
        for c0, c1 in combinations(range(n), 2):
            result = median_slope_partition(points, c0, c1)
            A, B = result['A'], result['B']
            z = result['z']
            wB = result['weights_B']

            # Check if the partition works for ALL coordinates
            z_B = tropical_combination(
                [points[B[0]], points[B[1]]], wB)

            if all(abs(z[k] - z_B[k]) < 1e-10 for k in range(n)):
                result['verified_all'] = True
                return result

    # Brute-force: try all possible A, B with |A|=1
    for i0 in range(m):
        others = [j for j in range(m) if j != i0]
        z = points[i0]

        # Try all subsets B of others with |B| >= 1
        for size in range(1, len(others) + 1):
            for B_tuple in combinations(others, size):
                B = list(B_tuple)
                # Find weights for B: w_j = max_k(z[k] - p_j[k])
                weights = [max(z[k] - points[j][k] for k in range(n))
                           for j in B]
                z_check = tropical_combination([points[j] for j in B], weights)
                if all(abs(z[k] - z_check[k]) < 1e-10 for k in range(n)):
                    return {
                        'A': [i0], 'B': B,
                        'z': z[:],
                        'weights_A': [0.0],
                        'weights_B': weights,
                        'verified_all': True,
                    }

    return None  # Should not happen for m >= n+2 points


def tropical_segment_sample(p1: List[float], p2: List[float],
                             num_samples: int = 20) -> List[List[float]]:
    """Sample points from the tropical segment between p1 and p2.

    The tropical segment consists of all z[k] = min(δ + p1[k], p2[k])
    for δ ∈ ℚ, shifted by arbitrary constants.

    Returns representative points (with shift c = 0).
    """
    n = len(p1)
    # Compute critical δ values: where δ + p1[k] = p2[k]
    critical = sorted(set(p2[k] - p1[k] for k in range(n)))

    samples = []
    # Sample around critical values
    deltas = []
    if critical:
        lo = critical[0] - 2
        hi = critical[-1] + 2
        deltas = [lo + (hi - lo) * t / (num_samples - 1)
                  for t in range(num_samples)]
    else:
        deltas = [float(t) for t in range(-5, 6)]

    for delta in deltas:
        z = [min(delta + p1[k], p2[k]) for k in range(n)]
        samples.append(z)

    return samples


if __name__ == "__main__":
    # Example usage
    print("Tropical Radon Partition Algorithm")
    print("=" * 50)

    # 4 points in ℚ²
    pts = [[0, 0], [3, 1], [1, 4], [2, 2]]
    result = find_radon_partition(pts)
    if result:
        print(f"Points: {pts}")
        print(f"Partition: A={result['A']}, B={result['B']}")
        print(f"Witness: z={result['z']}")
        print(f"Weights B: {result['weights_B']}")

    print()

    # 5 points in ℚ³
    pts3 = [[0,0,0], [1,0,2], [0,1,3], [2,1,0], [1,2,1]]
    result3 = find_radon_partition(pts3)
    if result3:
        print(f"5 points in ℚ³: {pts3}")
        print(f"Partition: A={result3['A']}, B={result3['B']}")
        print(f"Witness: z={result3['z']}")
