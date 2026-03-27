"""
Experiment 3: Topological Structure of Collatz Orbits
=====================================================

We construct a graph/network from Collatz orbits and analyze its
topological properties using tools from network science.

KEY INNOVATION: We define a "Collatz distance" between integers
based on how quickly their orbits merge, and use this to construct
a metric space. We then analyze the resulting geometry.

HYPOTHESIS: The Collatz distance metric has fractal dimension
strictly between 1 and 2, revealing a hidden geometric structure.
"""

import math
from collections import defaultdict, Counter
import json

def collatz_orbit(n, max_steps=1000):
    """Return the Collatz orbit starting from n."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
        orbit.append(n)
    return orbit

def collatz_stopping_time(n, max_steps=1000):
    """Steps to reach 1."""
    steps = 0
    while n != 1 and steps < max_steps:
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
        steps += 1
    return steps

def collatz_merge_distance(a, b, max_steps=500):
    """
    Define Collatz distance: minimum total steps for orbits of a and b
    to reach a common value.
    """
    orbit_a = set()
    orbit_b = set()
    
    val_a, val_b = a, b
    steps_a, steps_b = {a: 0}, {b: 0}
    
    for step in range(max_steps):
        # Advance orbit a
        if val_a != 1:
            if val_a % 2 == 0:
                val_a = val_a // 2
            else:
                val_a = 3 * val_a + 1
            steps_a[val_a] = step + 1
        
        # Advance orbit b
        if val_b != 1:
            if val_b % 2 == 0:
                val_b = val_b // 2
            else:
                val_b = 3 * val_b + 1
            steps_b[val_b] = step + 1
        
        # Check for merge
        for v in steps_a:
            if v in steps_b:
                return steps_a[v] + steps_b[v]
    
    return max_steps * 2  # Didn't merge within limit

# === EXPERIMENT 3A: Stopping time distribution ===
print("=" * 60)
print("EXPERIMENT 3A: Collatz Stopping Time Distribution")
print("=" * 60)

N = 10000
stopping_times = [collatz_stopping_time(n) for n in range(1, N + 1)]

import statistics
print(f"For n in [1, {N}]:")
print(f"  Mean stopping time: {statistics.mean(stopping_times):.2f}")
print(f"  Median stopping time: {statistics.median(stopping_times):.2f}")
print(f"  Max stopping time: {max(stopping_times)} (at n={stopping_times.index(max(stopping_times))+1})")

# Histogram
bins = list(range(0, max(stopping_times) + 20, 20))
hist = [0] * len(bins)
for st in stopping_times:
    idx = st // 20
    if idx < len(hist):
        hist[idx] += 1

print("\nStopping time histogram:")
for i in range(min(15, len(bins))):
    bar = '#' * (hist[i] * 40 // max(max(hist), 1))
    print(f"  [{bins[i]:4d}-{bins[i]+19:4d}]: {hist[i]:5d} {bar}")

# === EXPERIMENT 3B: Collatz distance metric ===
print("\n" + "=" * 60)
print("EXPERIMENT 3B: Collatz Distance Metric Properties")
print("=" * 60)

# Compute pairwise distances for small set
sample = list(range(1, 101))
n_sample = len(sample)

# Compute distance matrix (symmetric)
dist_matrix = {}
for i in range(n_sample):
    for j in range(i + 1, n_sample):
        d = collatz_merge_distance(sample[i], sample[j])
        dist_matrix[(i, j)] = d
        dist_matrix[(j, i)] = d

# Check triangle inequality violations
violations = 0
total_triples = 0
for i in range(min(50, n_sample)):
    for j in range(i + 1, min(50, n_sample)):
        for k in range(j + 1, min(50, n_sample)):
            total_triples += 1
            dij = dist_matrix.get((i, j), 0)
            djk = dist_matrix.get((j, k), 0)
            dik = dist_matrix.get((i, k), 0)
            if dij > djk + dik or djk > dij + dik or dik > dij + djk:
                violations += 1

print(f"Triangle inequality check on {total_triples} triples:")
print(f"  Violations: {violations} ({100*violations/max(total_triples,1):.2f}%)")
print(f"  → {'Valid metric!' if violations == 0 else 'NOT a metric (ultrametric?)'}")

# === EXPERIMENT 3C: Fractal dimension via box counting ===
print("\n" + "=" * 60)
print("EXPERIMENT 3C: Fractal Dimension of Collatz Stopping Time Graph")
print("=" * 60)

def box_counting_dimension(points, scales):
    """Estimate fractal dimension via box counting."""
    results = []
    for scale in scales:
        boxes = set()
        for x, y in points:
            box_x = int(x / scale)
            box_y = int(y / scale)
            boxes.add((box_x, box_y))
        results.append((scale, len(boxes)))
    return results

# Points: (n, stopping_time(n))
points = [(n, collatz_stopping_time(n)) for n in range(1, 5001)]

scales = [1, 2, 4, 8, 16, 32, 64, 128, 256]
box_results = box_counting_dimension(points, scales)

print(f"Box counting results:")
print(f"  {'Scale':>8} {'Boxes':>8} {'log(1/s)':>10} {'log(N)':>10}")
for s, n_boxes in box_results:
    print(f"  {s:>8} {n_boxes:>8} {math.log(1/s) if s > 0 else 0:>10.4f} {math.log(n_boxes):>10.4f}")

# Estimate dimension from log-log slope
if len(box_results) > 2:
    x_vals = [math.log(1/s) for s, _ in box_results if s > 1]
    y_vals = [math.log(n) for s, n in box_results if s > 1]
    
    if len(x_vals) > 1:
        n = len(x_vals)
        mean_x = sum(x_vals) / n
        mean_y = sum(y_vals) / n
        num = sum((x - mean_x) * (y - mean_y) for x, y in zip(x_vals, y_vals))
        den = sum((x - mean_x)**2 for x in x_vals)
        slope = num / den if den != 0 else 0
        print(f"\nEstimated fractal dimension: {slope:.4f}")
        print(f"(1.0 = line, 2.0 = area-filling)")

# === EXPERIMENT 3D: Orbit tree structure ===
print("\n" + "=" * 60)
print("EXPERIMENT 3D: Collatz Orbit Tree — Branching Statistics")
print("=" * 60)

# Build the reverse Collatz tree: for each n, what maps TO n?
# n comes from 2n (always) and from (n-1)/3 (if n ≡ 1 mod 3 and (n-1)/3 is odd)
reverse_tree = defaultdict(list)
for n in range(1, 10001):
    # 2n always maps to n
    reverse_tree[n].append(2 * n)
    # (n-1)/3 maps to n if n ≡ 1 mod 3 and result is odd and > 0
    if n % 3 == 1:
        pred = (n - 1) // 3
        if pred > 0 and pred % 2 == 1:
            reverse_tree[n].append(pred)

# Analyze branching
branching = Counter()
for n in range(1, 10001):
    children_in_range = [c for c in reverse_tree[n] if c <= 20000]
    branching[len(children_in_range)] += 1

print("Branching factor distribution:")
for b, count in sorted(branching.items()):
    print(f"  {b} children: {count} nodes")

# === EXPERIMENT 3E: Residue class structure of stopping times ===
print("\n" + "=" * 60)
print("EXPERIMENT 3E: Stopping Times by Residue Class")
print("=" * 60)

for mod in [3, 4, 6, 8, 12]:
    residue_means = {}
    for r in range(mod):
        vals = [stopping_times[n-1] for n in range(max(1, r), N + 1, mod) if n >= 1]
        if vals:
            residue_means[r] = statistics.mean(vals)
    
    print(f"\nMean stopping time by residue mod {mod}:")
    for r in sorted(residue_means):
        bar = '#' * int(residue_means[r] / 2)
        print(f"  n ≡ {r:2d} (mod {mod}): {residue_means[r]:.2f} {bar}")

# Save results
results = {
    "stopping_time_stats": {
        "mean": statistics.mean(stopping_times),
        "median": statistics.median(stopping_times),
        "max": max(stopping_times),
    },
    "triangle_inequality": {
        "violations": violations,
        "total_triples": total_triples
    },
    "branching_distribution": dict(branching),
}

with open('/workspace/request-project/figures/experiment3_results.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\n✓ Results saved to figures/experiment3_results.json")
