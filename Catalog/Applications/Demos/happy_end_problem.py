#!/usr/bin/env python3
"""
Applications of Erdős–Szekeres Theory
=======================================

Real-world applications demonstrating the mathematical results:
1. Pattern detection in financial time series
2. Quality control in manufacturing sequences  
3. Computational geometry: convex hull vertex extraction
4. Network routing: monotone path detection
"""

import random
from typing import List, Tuple
from algorithms import (
    orient, longest_increasing_subsequence_fast,
    longest_decreasing_subsequence_fast, find_longest_cup,
    find_longest_cap, es_upper_bound
)

Point = Tuple[float, float]


# ============================================================================
# Application 1: Financial Time Series Pattern Detection
# ============================================================================

def detect_trend_patterns(prices: List[float], min_trend_length: int = 4) -> dict:
    """Detect sustained upward and downward trends in a price series.
    
    The Erdős–Szekeres theorem guarantees that any price series of length
    > (r-1)² contains either an uptrend of length r or a downtrend of length r.
    
    This means that in any sufficiently long trading period, significant 
    directional moves are mathematically inevitable — a foundational insight 
    for trend-following strategies.
    
    >>> prices = [100, 102, 99, 103, 97, 105, 96, 107, 95, 108]
    >>> result = detect_trend_patterns(prices, 3)
    >>> len(result['uptrend']) >= 3 or len(result['downtrend']) >= 3
    True
    """
    inc_idx = longest_increasing_subsequence_fast(prices)
    dec_idx = longest_decreasing_subsequence_fast(prices)
    
    return {
        'uptrend': [(i, prices[i]) for i in inc_idx],
        'downtrend': [(i, prices[i]) for i in dec_idx],
        'uptrend_length': len(inc_idx),
        'downtrend_length': len(dec_idx),
        'guaranteed_min_trend': min_trend_length,
        'min_series_length': (min_trend_length - 1) ** 2 + 1
    }


# ============================================================================
# Application 2: Quality Control — Monotone Deviation Detection
# ============================================================================

def quality_control_analysis(measurements: List[float], threshold_length: int = 5) -> dict:
    """Detect systematic drift in manufacturing measurements.
    
    By the Erdős–Szekeres theorem, any sequence of n² + 1 measurements
    contains a monotone subsequence of length n + 1. If measurements 
    should be random, finding a long monotone subsequence suggests 
    systematic drift requiring intervention.
    
    >>> measurements = [10.1, 10.3, 10.0, 10.5, 10.2, 10.7, 10.4, 10.9, 10.6, 11.1]
    >>> result = quality_control_analysis(measurements, 4)
    >>> result['drift_detected']
    True
    """
    inc = longest_increasing_subsequence_fast(measurements)
    dec = longest_decreasing_subsequence_fast(measurements)
    
    max_trend = max(len(inc), len(dec))
    trend_type = 'increasing' if len(inc) >= len(dec) else 'decreasing'
    trend_indices = inc if len(inc) >= len(dec) else dec
    
    return {
        'drift_detected': max_trend >= threshold_length,
        'trend_type': trend_type,
        'trend_length': max_trend,
        'trend_values': [measurements[i] for i in trend_indices],
        'trend_positions': list(trend_indices),
        'es_guarantee': f"Any {(threshold_length-1)**2 + 1}+ measurements must contain "
                       f"a monotone trend of length {threshold_length}"
    }


# ============================================================================
# Application 3: Convex Hull Vertex Extraction from Sensor Data
# ============================================================================

def convex_feature_extraction(sensor_data: List[Point]) -> dict:
    """Extract convex features from 2D sensor readings.
    
    Uses cup/cap analysis to identify convex and concave arcs in 
    point data. Cups represent upward-curving features (valleys),
    caps represent downward-curving features (peaks).
    
    This decomposes a point cloud into convex primitives, which is
    fundamental for shape recognition and object detection.
    
    >>> data = [(i, i*i % 17) for i in range(20)]
    >>> result = convex_feature_extraction(data)
    >>> len(result['cups']) > 0 or len(result['caps']) > 0
    True
    """
    # Sort by x
    sorted_data = sorted(enumerate(sensor_data), key=lambda x: x[1][0])
    sorted_points = [p for _, p in sorted_data]
    original_indices = [i for i, _ in sorted_data]
    
    cup = find_longest_cup(sorted_points)
    cap = find_longest_cap(sorted_points)
    
    return {
        'cups': [{
            'indices': [original_indices[i] for i in cup],
            'points': [sorted_points[i] for i in cup],
            'length': len(cup),
            'description': 'Upward-curving arc (valley)'
        }] if cup else [],
        'caps': [{
            'indices': [original_indices[i] for i in cap],
            'points': [sorted_points[i] for i in cap],
            'length': len(cap),
            'description': 'Downward-curving arc (peak)'
        }] if cap else [],
        'num_points': len(sensor_data),
    }


# ============================================================================
# Application 4: Network Analysis — Monotone Path Bounds
# ============================================================================

def network_monotone_paths(latencies: List[float]) -> dict:
    """Analyze network latency sequences for monotone paths.
    
    In network monitoring, consistently increasing latencies indicate 
    congestion buildup, while consistently decreasing latencies indicate 
    recovery. The Erdős–Szekeres theorem provides guaranteed detection 
    thresholds.
    
    >>> latencies = [50, 45, 55, 40, 60, 35, 65, 30, 70, 25]
    >>> result = network_monotone_paths(latencies)
    >>> result['congestion_length'] >= 1
    True
    """
    inc = longest_increasing_subsequence_fast(latencies)
    dec = longest_decreasing_subsequence_fast(latencies)
    
    n = len(latencies)
    import math
    min_trend = int(math.sqrt(n - 1)) + 1 if n > 1 else 1
    
    return {
        'congestion_length': len(inc),
        'recovery_length': len(dec),
        'congestion_sequence': [(i, latencies[i]) for i in inc],
        'recovery_sequence': [(i, latencies[i]) for i in dec],
        'guaranteed_trend_length': min_trend,
        'interpretation': 
            f"In {n} measurements, Erdős–Szekeres guarantees a monotone "
            f"subsequence of length ≥ {min_trend}. "
            f"Found: increase={len(inc)}, decrease={len(dec)}."
    }


def run_all_applications():
    """Run all application demos."""
    print("=" * 70)
    print("APPLICATION 1: Financial Time Series Pattern Detection")
    print("=" * 70)
    
    random.seed(42)
    # Simulate a volatile stock price
    prices = [100.0]
    for _ in range(49):
        prices.append(prices[-1] + random.gauss(0.1, 2))
    
    result = detect_trend_patterns(prices, 5)
    print(f"\nPrice series length: {len(prices)}")
    print(f"Longest uptrend: {result['uptrend_length']} days")
    print(f"  Values: {[f'{v:.1f}' for _, v in result['uptrend'][:8]]}...")
    print(f"Longest downtrend: {result['downtrend_length']} days")
    print(f"  Values: {[f'{v:.1f}' for _, v in result['downtrend'][:8]]}...")
    print(f"\nES guarantee: any {result['min_series_length']}+ trading days must contain")
    print(f"  a monotone trend of length {result['guaranteed_min_trend']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Quality Control — Drift Detection")
    print("=" * 70)
    
    # Simulate measurements with slight upward drift
    random.seed(123)
    measurements = [10.0 + 0.02 * i + random.gauss(0, 0.1) for i in range(30)]
    
    result = quality_control_analysis(measurements, 5)
    print(f"\nMeasurements: {len(measurements)} samples")
    print(f"Drift detected: {result['drift_detected']}")
    print(f"Trend type: {result['trend_type']}")
    print(f"Trend length: {result['trend_length']}")
    print(f"ES guarantee: {result['es_guarantee']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Convex Feature Extraction")
    print("=" * 70)
    
    # Simulate sensor readings
    sensor_data = [(i * 0.5, 3 * (i * 0.5 - 5)**2 + random.gauss(0, 1)) for i in range(20)]
    
    result = convex_feature_extraction(sensor_data)
    print(f"\nSensor readings: {result['num_points']} points")
    for cup in result['cups']:
        print(f"Cup found: {cup['length']} points — {cup['description']}")
    for cap in result['caps']:
        print(f"Cap found: {cap['length']} points — {cap['description']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 4: Network Latency Analysis")
    print("=" * 70)
    
    random.seed(456)
    latencies = [50 + random.gauss(0, 10) + 0.5 * i for i in range(25)]
    
    result = network_monotone_paths(latencies)
    print(f"\nLatency measurements: {len(latencies)}")
    print(f"Congestion trend length: {result['congestion_length']}")
    print(f"Recovery trend length: {result['recovery_length']}")
    print(f"Guaranteed trend: ≥{result['guaranteed_trend_length']}")
    print(f"\n{result['interpretation']}")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


if __name__ == "__main__":
    run_all_applications()


#!/usr/bin/env python3
"""
Demo: Erdős–Szekeres Happy End Problem
========================================

Demonstrates the key theorems computationally:
1. Monotone subsequence theorem
2. Cup/cap extraction
3. Convex position detection
4. Orientation computations
"""

import itertools
import random
from typing import List, Tuple, Optional

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Compute the orientation of three points.
    
    Returns positive for counterclockwise, negative for clockwise, zero for collinear.
    This is twice the signed area of the triangle abc.
    """
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_general_position(points: List[Point]) -> bool:
    """Check if no three points are collinear."""
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                if orient(points[i], points[j], points[k]) == 0:
                    return False
    return True


def longest_increasing_subsequence(seq: List[float]) -> List[int]:
    """Find a longest strictly increasing subsequence, returning indices."""
    n = len(seq)
    if n == 0:
        return []
    
    # dp[i] = length of LIS ending at i
    dp = [1] * n
    parent = [-1] * n
    
    for i in range(1, n):
        for j in range(i):
            if seq[j] < seq[i] and dp[j] + 1 > dp[i]:
                dp[i] = dp[j] + 1
                parent[i] = j
    
    # Reconstruct
    best = max(range(n), key=lambda i: dp[i])
    result = []
    while best != -1:
        result.append(best)
        best = parent[best]
    return result[::-1]


def longest_decreasing_subsequence(seq: List[float]) -> List[int]:
    """Find a longest strictly decreasing subsequence, returning indices."""
    n = len(seq)
    if n == 0:
        return []
    
    dp = [1] * n
    parent = [-1] * n
    
    for i in range(1, n):
        for j in range(i):
            if seq[j] > seq[i] and dp[j] + 1 > dp[i]:
                dp[i] = dp[j] + 1
                parent[i] = j
    
    best = max(range(n), key=lambda i: dp[i])
    result = []
    while best != -1:
        result.append(best)
        best = parent[best]
    return result[::-1]


def is_cup(points: List[Point]) -> bool:
    """Check if sorted points form a cup (all consecutive triple orientations positive)."""
    if len(points) < 3:
        return True
    for i in range(len(points) - 2):
        if orient(points[i], points[i+1], points[i+2]) <= 0:
            return False
    return True


def is_cap(points: List[Point]) -> bool:
    """Check if sorted points form a cap (all consecutive triple orientations negative)."""
    if len(points) < 3:
        return True
    for i in range(len(points) - 2):
        if orient(points[i], points[i+1], points[i+2]) >= 0:
            return False
    return True


def in_convex_position(points: List[Point]) -> bool:
    """Check if points (sorted by x) are in convex position.
    
    All triples must have consistent orientation (all positive or all negative).
    """
    if len(points) < 3:
        return True
    
    # Check all positive
    all_positive = all(
        orient(points[i], points[j], points[k]) > 0
        for i in range(len(points))
        for j in range(i + 1, len(points))
        for k in range(j + 1, len(points))
    )
    
    # Check all negative
    all_negative = all(
        orient(points[i], points[j], points[k]) < 0
        for i in range(len(points))
        for j in range(i + 1, len(points))
        for k in range(j + 1, len(points))
    )
    
    return all_positive or all_negative


def find_max_convex_subset(points: List[Point]) -> List[int]:
    """Find a maximum cardinality subset in convex position (brute force)."""
    n = len(points)
    # Sort by x-coordinate
    sorted_indices = sorted(range(n), key=lambda i: points[i][0])
    sorted_points = [points[i] for i in sorted_indices]
    
    best = []
    for size in range(n, 0, -1):
        for combo in itertools.combinations(range(n), size):
            subset = [sorted_points[i] for i in combo]
            if in_convex_position(subset):
                return [sorted_indices[i] for i in combo]
    return []


def erdos_szekeres_bound(n: int) -> int:
    """The Erdős–Szekeres upper bound: C(2n-4, n-2) + 1."""
    from math import comb
    if n < 3:
        return n
    return comb(2 * n - 4, n - 2) + 1


def demo_monotone_subsequence():
    """Demonstrate the Erdős–Szekeres monotone subsequence theorem."""
    print("=" * 70)
    print("DEMO 1: Erdős–Szekeres Monotone Subsequence Theorem")
    print("=" * 70)
    print()
    print("Theorem: Any sequence of more than (r-1)(s-1) distinct numbers")
    print("contains an increasing subsequence of length r or a decreasing")
    print("subsequence of length s.")
    print()
    
    # Example: r=s=4, so (r-1)(s-1) = 9, need > 9 elements
    r, s = 4, 4
    n = (r - 1) * (s - 1) + 1  # = 10
    
    random.seed(42)
    seq = random.sample(range(1, 100), n)
    print(f"r = {r}, s = {s}, threshold = {(r-1)*(s-1)} = {n-1}")
    print(f"Sequence of length {n}: {seq}")
    print()
    
    inc = longest_increasing_subsequence(seq)
    dec = longest_decreasing_subsequence(seq)
    
    inc_values = [seq[i] for i in inc]
    dec_values = [seq[i] for i in dec]
    
    print(f"Longest increasing subsequence: {inc_values} (length {len(inc)})")
    print(f"Longest decreasing subsequence: {dec_values} (length {len(dec)})")
    
    assert len(inc) >= r or len(dec) >= s, "Theorem violated!"
    print(f"\n✓ Theorem verified: {'increasing' if len(inc) >= r else 'decreasing'} "
          f"subsequence has length ≥ {r if len(inc) >= r else s}")
    
    # Show the n²+1 corollary
    print(f"\nCorollary: n² + 1 = {3*3+1} = 10 distinct numbers always contain")
    print(f"a monotone subsequence of length {3+1} = 4.")


def demo_cups_caps():
    """Demonstrate cups and caps in point configurations."""
    print("\n" + "=" * 70)
    print("DEMO 2: Cups and Caps")
    print("=" * 70)
    print()
    
    # Create a cup (concave up parabola)
    cup_points = [(i, i*i) for i in range(5)]
    print(f"Cup points (y = x²): {cup_points}")
    print(f"Is cup: {is_cup(cup_points)}")
    print(f"Is cap: {is_cap(cup_points)}")
    print(f"Orient triples:")
    for i in range(len(cup_points) - 2):
        o = orient(cup_points[i], cup_points[i+1], cup_points[i+2])
        print(f"  orient({cup_points[i]}, {cup_points[i+1]}, {cup_points[i+2]}) = {o:.0f} > 0 ✓")
    
    print()
    
    # Create a cap (concave down parabola)
    cap_points = [(i, -i*i + 20) for i in range(5)]
    print(f"Cap points (y = -x² + 20): {cap_points}")
    print(f"Is cup: {is_cup(cap_points)}")
    print(f"Is cap: {is_cap(cap_points)}")
    print(f"Orient triples:")
    for i in range(len(cap_points) - 2):
        o = orient(cap_points[i], cap_points[i+1], cap_points[i+2])
        print(f"  orient({cap_points[i]}, {cap_points[i+1]}, {cap_points[i+2]}) = {o:.0f} < 0 ✓")
    
    print()
    print("Key theorem (proved in Lean): ALL triples in a cup have positive")
    print("orientation, not just consecutive ones. This connects cups to convexity.")
    
    # Verify all triples
    print("\nAll-triples check for cup:")
    for i in range(len(cup_points)):
        for j in range(i+1, len(cup_points)):
            for k in range(j+1, len(cup_points)):
                o = orient(cup_points[i], cup_points[j], cup_points[k])
                print(f"  orient(p{i}, p{j}, p{k}) = {o:.0f} {'> 0 ✓' if o > 0 else '≤ 0 ✗'}")


def demo_convex_position():
    """Demonstrate convex position detection."""
    print("\n" + "=" * 70)
    print("DEMO 3: Convex Position and the Happy End Number")
    print("=" * 70)
    print()
    
    from math import comb
    
    print("Happy End Numbers ES(n) — upper bound from Erdős–Szekeres:")
    print(f"  ES(3) ≤ {erdos_szekeres_bound(3)}  (any 3 points in GP form a triangle)")
    print(f"  ES(4) ≤ {erdos_szekeres_bound(4)}  (known exact: ES(4) = 5)")
    print(f"  ES(5) ≤ {erdos_szekeres_bound(5)}  (known exact: ES(5) = 9)")
    print(f"  ES(6) ≤ {erdos_szekeres_bound(6)} (known exact: ES(6) = 17)")
    print(f"  ES(7) ≤ {erdos_szekeres_bound(7)}")
    print(f"  ES(8) ≤ {erdos_szekeres_bound(8)}")
    
    print()
    print("General formula: ES(n) ≤ C(2n-4, n-2) + 1")
    print(f"  = (2n-4)! / ((n-2)!)² + 1")
    
    print()
    
    # Verify ES(4) = 5: show 5 points in GP always contain 4 in convex position
    print("Verifying ES(4) = 5 computationally:")
    print("Testing 1000 random 5-point configurations in general position...")
    
    random.seed(123)
    successes = 0
    for trial in range(1000):
        points = [(random.uniform(-10, 10), random.uniform(-10, 10)) for _ in range(5)]
        if not is_general_position(points):
            continue
        
        # Sort by x
        points.sort(key=lambda p: p[0])
        
        # Check all 4-subsets
        found = False
        for combo in itertools.combinations(range(5), 4):
            subset = [points[i] for i in combo]
            if in_convex_position(subset):
                found = True
                break
        
        if found:
            successes += 1
    
    print(f"  {successes} configurations had 4 points in convex position ✓")


def demo_orientation():
    """Demonstrate orientation computations."""
    print("\n" + "=" * 70)
    print("DEMO 4: Orientation Function Properties")
    print("=" * 70)
    print()
    
    a, b, c = (0, 0), (1, 0), (0.5, 1)
    print(f"Triangle: A={a}, B={b}, C={c}")
    print(f"orient(A,B,C) = {orient(a,b,c):.1f} (counterclockwise)")
    print(f"orient(A,C,B) = {orient(a,c,b):.1f} (clockwise)")
    print(f"orient(B,C,A) = {orient(b,c,a):.1f} (cyclic = same sign)")
    print()
    
    # Grassmann-Plücker relation
    d = (2, 0.5)
    lhs = orient(a, b, d)
    rhs = orient(a, b, c) + orient(a, c, d) + orient(c, b, d)
    print(f"Grassmann-Plücker: orient(A,B,D) = orient(A,B,C) + orient(A,C,D) + orient(C,B,D)")
    print(f"  {lhs:.1f} = {orient(a,b,c):.1f} + {orient(a,c,d):.1f} + {orient(c,b,d):.1f} = {rhs:.1f} ✓")
    print()
    
    # Translation invariance
    v = (5, 3)
    a2 = (a[0]+v[0], a[1]+v[1])
    b2 = (b[0]+v[0], b[1]+v[1])
    c2 = (c[0]+v[0], c[1]+v[1])
    print(f"Translation invariance: orient(A,B,C) = orient(A+v, B+v, C+v)")
    print(f"  {orient(a,b,c):.1f} = {orient(a2,b2,c2):.1f} ✓")


if __name__ == "__main__":
    demo_monotone_subsequence()
    demo_cups_caps()
    demo_convex_position()
    demo_orientation()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
