"""
Experiment 1: The Arithmetic Derivative and Its Dynamics
========================================================

The arithmetic derivative n' is defined by:
  - p' = 1 for prime p
  - (ab)' = a'b + ab'  (Leibniz rule)
  - 0' = 0, 1' = 0

We explore the ITERATED arithmetic derivative: what happens when you
repeatedly differentiate a number? Do orbits converge, diverge, or cycle?

NEW HYPOTHESIS: There exists a "derivative fixed point" structure —
numbers n where n' = n. We'll search for them and analyze near-misses.
We also hypothesize that the ratio n'/n has a fractal distribution.
"""

import math
from collections import Counter, defaultdict
import json

def factorize(n):
    """Return prime factorization as list of (prime, exponent) pairs."""
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            exp += 1
            n //= d
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors

def arithmetic_derivative(n):
    """Compute the arithmetic derivative of n."""
    if n <= 1:
        return 0
    factors = factorize(n)
    # n'/n = sum(e_i / p_i) for n = prod(p_i^e_i)
    # So n' = n * sum(e_i / p_i)
    result = 0
    for p, e in factors:
        result += n * e // p  # This is exact since p divides p^e which divides n
    return result

def iterate_derivative(n, max_steps=100, max_val=10**15):
    """Iterate the arithmetic derivative, returning the orbit."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        current = arithmetic_derivative(current)
        if current > max_val:
            orbit.append(float('inf'))
            break
        orbit.append(current)
        if current <= 1:
            break
    return orbit

# === EXPERIMENT 1A: Search for fixed points n' = n ===
print("=" * 60)
print("EXPERIMENT 1A: Fixed Points of Arithmetic Derivative (n' = n)")
print("=" * 60)
fixed_points = []
near_misses = []  # |n' - n| / n < 0.01

for n in range(2, 100000):
    nd = arithmetic_derivative(n)
    if nd == n:
        fixed_points.append(n)
    elif n > 10 and abs(nd - n) / n < 0.01:
        near_misses.append((n, nd, abs(nd - n) / n))

print(f"Fixed points found (n' = n): {fixed_points[:20]}")
print(f"Number of near-misses (|n'-n|/n < 0.01): {len(near_misses)}")
if near_misses:
    print("Sample near-misses (n, n', ratio):")
    for nm in sorted(near_misses, key=lambda x: x[2])[:15]:
        print(f"  n={nm[0]}, n'={nm[1]}, |n'-n|/n = {nm[2]:.6f}, factorization={factorize(nm[0])}")

# === EXPERIMENT 1B: Orbit classification ===
print("\n" + "=" * 60)
print("EXPERIMENT 1B: Orbit Classification")
print("=" * 60)

orbit_types = Counter()
interesting_orbits = []

for n in range(2, 10000):
    orbit = iterate_derivative(n, max_steps=50)
    if orbit[-1] == float('inf'):
        orbit_types['divergent'] += 1
    elif orbit[-1] == 0:
        orbit_types['to_zero'] += 1
    elif len(orbit) > 2 and orbit[-1] == orbit[-2]:
        orbit_types['fixed_point'] += 1
    else:
        orbit_types['other'] += 1
        if len(orbit) > 5:
            interesting_orbits.append((n, orbit))

print(f"Orbit classification for n in [2, 10000):")
for otype, count in orbit_types.most_common():
    print(f"  {otype}: {count}")

if interesting_orbits:
    print(f"\nLong non-divergent orbits (showing first 10):")
    for n, orb in interesting_orbits[:10]:
        print(f"  n={n}: {orb[:8]}{'...' if len(orb) > 8 else ''} (length {len(orb)})")

# === EXPERIMENT 1C: The derivative ratio landscape ===
print("\n" + "=" * 60)
print("EXPERIMENT 1C: Derivative Ratio n'/n Landscape")
print("=" * 60)

ratios = []
for n in range(2, 50000):
    nd = arithmetic_derivative(n)
    ratios.append(nd / n)

# Analyze distribution
import statistics
print(f"Mean ratio: {statistics.mean(ratios):.4f}")
print(f"Median ratio: {statistics.median(ratios):.4f}")
print(f"Stdev ratio: {statistics.stdev(ratios):.4f}")

# Histogram
bins = [0, 0.5, 1, 1.5, 2, 3, 4, 5, 10, 20, 50, 100]
hist = [0] * (len(bins))
for r in ratios:
    placed = False
    for i in range(len(bins) - 1):
        if bins[i] <= r < bins[i+1]:
            hist[i] += 1
            placed = True
            break
    if not placed:
        hist[-1] += 1

print("\nRatio distribution:")
for i in range(len(bins) - 1):
    bar = '#' * (hist[i] * 50 // max(hist))
    print(f"  [{bins[i]:5.1f}, {bins[i+1]:5.1f}): {hist[i]:6d} {bar}")
print(f"  [{bins[-1]:5.1f},   inf): {hist[-1]:6d}")

# === EXPERIMENT 1D: NEW DISCOVERY — "Smooth" numbers have predictable derivatives ===
print("\n" + "=" * 60)
print("EXPERIMENT 1D: Derivative of k-smooth numbers")
print("=" * 60)

def is_k_smooth(n, k):
    """Check if all prime factors of n are <= k."""
    factors = factorize(n)
    return all(p <= k for p, _ in factors)

for k in [2, 3, 5, 7, 11]:
    smooth_nums = [n for n in range(2, 5000) if is_k_smooth(n, k)]
    if smooth_nums:
        smooth_ratios = [arithmetic_derivative(n) / n for n in smooth_nums]
        print(f"  {k}-smooth numbers: count={len(smooth_nums)}, "
              f"mean ratio={statistics.mean(smooth_ratios):.4f}, "
              f"max ratio={max(smooth_ratios):.4f}")

# Save results for paper
results = {
    "fixed_points": fixed_points,
    "near_miss_count": len(near_misses),
    "orbit_classification": dict(orbit_types),
    "ratio_stats": {
        "mean": statistics.mean(ratios),
        "median": statistics.median(ratios),
        "stdev": statistics.stdev(ratios)
    }
}

with open('/workspace/request-project/figures/experiment1_results.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\n✓ Results saved to figures/experiment1_results.json")
