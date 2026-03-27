"""
Experiment 2: The Hidden Geometry of Prime Gaps
================================================

We embed prime gaps into geometric spaces and analyze their structure.

KEY IDEA: Take consecutive prime gaps g_1, g_2, g_3, ... and form
vectors (g_i, g_{i+1}) in R^2 (and higher). What does the point cloud
look like? We analyze:
  1. The "prime gap attractor" — the 2D point cloud of consecutive gaps
  2. Autocorrelation structure of prime gaps
  3. A novel "curvature of primes" — treating primes as a curve p(n)
     and computing discrete curvature

HYPOTHESIS: The gap-pair distribution has non-trivial clustering
that reveals hidden structure beyond the Hardy-Littlewood conjectures.
"""

import math
import json
from collections import Counter, defaultdict

def sieve_primes(limit):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

primes = sieve_primes(2_000_000)
gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

print("=" * 60)
print("EXPERIMENT 2A: Prime Gap Pair Distribution")
print("=" * 60)

# Form (g_i, g_{i+1}) pairs
gap_pairs = [(gaps[i], gaps[i+1]) for i in range(len(gaps) - 1)]
pair_counts = Counter(gap_pairs)

print(f"Number of primes: {len(primes)}")
print(f"Number of gap pairs: {len(gap_pairs)}")
print(f"Distinct gap pairs: {len(pair_counts)}")
print("\nMost common gap pairs:")
for pair, count in pair_counts.most_common(20):
    print(f"  {pair}: {count} ({100*count/len(gap_pairs):.2f}%)")

# === EXPERIMENT 2B: Gap autocorrelation ===
print("\n" + "=" * 60)
print("EXPERIMENT 2B: Prime Gap Autocorrelation")
print("=" * 60)

import statistics
gap_mean = statistics.mean(gaps[:100000])
gap_var = statistics.variance(gaps[:100000])

def autocorrelation(seq, lag, n=100000):
    """Compute autocorrelation at given lag."""
    seq = seq[:n]
    mean = sum(seq) / len(seq)
    var = sum((x - mean)**2 for x in seq) / len(seq)
    if var == 0:
        return 0
    cov = sum((seq[i] - mean) * (seq[i + lag] - mean) 
              for i in range(len(seq) - lag)) / (len(seq) - lag)
    return cov / var

print("Autocorrelation of prime gaps:")
for lag in range(1, 21):
    ac = autocorrelation(gaps, lag)
    bar = '#' * int(abs(ac) * 100)
    sign = '+' if ac > 0 else '-'
    print(f"  lag {lag:3d}: {ac:+.6f} {sign}{bar}")

# === EXPERIMENT 2C: Discrete Curvature of Primes ===
print("\n" + "=" * 60)
print("EXPERIMENT 2C: Discrete Curvature of the Prime Sequence")
print("=" * 60)

def discrete_curvature(seq, i):
    """
    Discrete curvature at index i using Menger curvature:
    The curvature of the circle through three consecutive points.
    Points are (i-1, seq[i-1]), (i, seq[i]), (i+1, seq[i+1]).
    """
    if i < 1 or i >= len(seq) - 1:
        return 0
    x1, y1 = i - 1, seq[i - 1]
    x2, y2 = i, seq[i]
    x3, y3 = i + 1, seq[i + 1]
    
    # Area of triangle * 2
    area2 = abs((x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1))
    
    # Side lengths
    d12 = math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
    d23 = math.sqrt((x3 - x2)**2 + (y3 - y2)**2)
    d13 = math.sqrt((x3 - x1)**2 + (y3 - y1)**2)
    
    denom = d12 * d23 * d13
    if denom == 0:
        return 0
    return area2 / denom

# Compute curvatures for first 10000 primes
curvatures = [discrete_curvature(primes, i) for i in range(1, min(10001, len(primes) - 1))]

print(f"Mean curvature: {statistics.mean(curvatures):.8f}")
print(f"Median curvature: {statistics.median(curvatures):.8f}")
print(f"Max curvature: {max(curvatures):.8f}")
print(f"Min curvature: {min(curvatures):.8f}")

# Where are the high-curvature points?
indexed_curv = [(c, i+1) for i, c in enumerate(curvatures)]
indexed_curv.sort(reverse=True)
print("\nHighest curvature points (index, prime, curvature):")
for c, idx in indexed_curv[:10]:
    print(f"  p_{idx} = {primes[idx]}, gap_before={primes[idx]-primes[idx-1]}, "
          f"gap_after={primes[idx+1]-primes[idx]}, curvature={c:.8f}")

# === EXPERIMENT 2D: Curvature vs log(p) scaling ===
print("\n" + "=" * 60)
print("EXPERIMENT 2D: Curvature Scaling Law")
print("=" * 60)

# Hypothesis: mean curvature in a window scales as 1/log(p)^alpha
window_size = 500
window_results = []
for start in range(0, min(len(curvatures) - window_size, 50000), window_size):
    window = curvatures[start:start + window_size]
    mean_c = statistics.mean(window)
    mid_prime = primes[start + window_size // 2]
    window_results.append((mid_prime, mean_c))

print("Mean curvature vs. prime magnitude:")
print(f"  {'Prime range':>15} {'Mean curvature':>15} {'log(p)*curv':>15}")
for p, c in window_results[::max(1, len(window_results)//15)]:
    print(f"  {p:>15,} {c:>15.8f} {math.log(p)*c:>15.8f}")

# === EXPERIMENT 2E: Gap triple patterns — a new statistic ===
print("\n" + "=" * 60)
print("EXPERIMENT 2E: Gap Triple Signatures")
print("=" * 60)

def gap_signature(g1, g2, g3):
    """Classify a triple of gaps by their relative sizes."""
    vals = [g1, g2, g3]
    if vals[0] < vals[1] < vals[2]:
        return "ascending"
    elif vals[0] > vals[1] > vals[2]:
        return "descending"
    elif vals[1] > vals[0] and vals[1] > vals[2]:
        return "peak"
    elif vals[1] < vals[0] and vals[1] < vals[2]:
        return "valley"
    else:
        return "flat/mixed"

triple_sigs = Counter()
for i in range(len(gaps) - 2):
    sig = gap_signature(gaps[i], gaps[i+1], gaps[i+2])
    triple_sigs[sig] += 1

total = sum(triple_sigs.values())
print("Gap triple signature distribution:")
for sig, count in triple_sigs.most_common():
    print(f"  {sig:>12}: {count:>8} ({100*count/total:.2f}%)")

# For random iid, we'd expect: each of the 6 orderings equally likely
# peak and valley each = 2/6, ascending = 1/6, descending = 1/6
print(f"\n  Expected if random: peak~33.3%, valley~33.3%, asc~16.7%, desc~16.7%")

# Save results
results = {
    "top_gap_pairs": pair_counts.most_common(20),
    "autocorrelations": {lag: autocorrelation(gaps, lag) for lag in range(1, 21)},
    "curvature_stats": {
        "mean": statistics.mean(curvatures),
        "median": statistics.median(curvatures),
    },
    "triple_signatures": dict(triple_sigs),
}

with open('/workspace/request-project/figures/experiment2_results.json', 'w') as f:
    json.dump(results, f, indent=2, default=str)

print("\n✓ Results saved to figures/experiment2_results.json")
