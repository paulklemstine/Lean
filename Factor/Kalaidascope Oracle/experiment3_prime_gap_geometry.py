"""
EXPERIMENT 3: Prime Gap Geometry & The Gap Ratio Spiral
=======================================================
Novel idea: Plot consecutive prime gap RATIOS g(n+1)/g(n) in polar coordinates.
Discover: Do gap ratios cluster around specific values? Is there hidden angular structure?

Also: "Prime Gap Persistence" - how long do gap sizes persist?
"""
import math
from collections import Counter

def sieve(limit):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

primes = sieve(1000000)
gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]

print("=" * 80)
print("EXPERIMENT 3: PRIME GAP GEOMETRY")
print("=" * 80)
print()

# Gap ratio analysis
print("DISCOVERY 1: Consecutive gap ratios g(n+1)/g(n)")
gap_ratios = [gaps[i+1]/gaps[i] for i in range(len(gaps)-1) if gaps[i] > 0]

# Histogram of gap ratios
print(f"\nTotal gap ratios computed: {len(gap_ratios)}")
print(f"Mean ratio: {sum(gap_ratios)/len(gap_ratios):.6f}")
print(f"Median ratio: {sorted(gap_ratios)[len(gap_ratios)//2]:.6f}")

# What fraction of ratios are exactly integers?
integer_ratios = sum(1 for r in gap_ratios if abs(r - round(r)) < 0.001)
print(f"Ratios that are approximately integer: {integer_ratios} ({100*integer_ratios/len(gap_ratios):.1f}%)")

# Distribution of integer gap ratios
int_ratio_counts = Counter()
for r in gap_ratios:
    if abs(r - round(r)) < 0.001:
        int_ratio_counts[round(r)] += 1
print("\nInteger ratio distribution:")
for k, v in sorted(int_ratio_counts.items()):
    if v > 10:
        print(f"  Ratio ≈ {k}: {v} occurrences")

# DISCOVERY 2: Gap persistence (how many consecutive equal gaps?)
print("\n\nDISCOVERY 2: Gap Persistence Sequences")
print("How many consecutive equal gaps occur?")
persistence_lengths = []
current_gap = gaps[0]
current_run = 1
for i in range(1, len(gaps)):
    if gaps[i] == current_gap:
        current_run += 1
    else:
        persistence_lengths.append((current_run, current_gap))
        current_gap = gaps[i]
        current_run = 1
persistence_lengths.append((current_run, current_gap))

# Find longest runs
persistence_lengths.sort(reverse=True)
print("Longest runs of consecutive equal gaps:")
for run_len, gap_val in persistence_lengths[:15]:
    print(f"  {run_len} consecutive gaps of size {gap_val}")

# DISCOVERY 3: "Prime Gap Triangles"
# Form triangles from consecutive triples of gaps (g_n, g_{n+1}, g_{n+2})
# Check triangle inequality and classify
print("\n\nDISCOVERY 3: Prime Gap Triangles")
print("Can consecutive gap triples form triangles?")
triangle_count = 0
non_triangle_count = 0
equilateral_count = 0
isoceles_count = 0
right_triangle_count = 0

for i in range(len(gaps) - 2):
    a, b, c = sorted([gaps[i], gaps[i+1], gaps[i+2]])
    if a + b > c:  # triangle inequality
        triangle_count += 1
        if a == b == c:
            equilateral_count += 1
        elif a == b or b == c:
            isoceles_count += 1
        # Check approximate right triangle
        if abs(a*a + b*b - c*c) <= 1:
            right_triangle_count += 1
    else:
        non_triangle_count += 1

total = triangle_count + non_triangle_count
print(f"  Triples forming triangles: {triangle_count} ({100*triangle_count/total:.1f}%)")
print(f"  Non-triangle triples: {non_triangle_count} ({100*non_triangle_count/total:.1f}%)")
print(f"  Equilateral: {equilateral_count}")
print(f"  Isoceles: {isoceles_count}")
print(f"  Right triangles: {right_triangle_count}")

# DISCOVERY 4: Gap Autocorrelation  
print("\n\nDISCOVERY 4: Gap Autocorrelation")
mean_gap = sum(gaps) / len(gaps)
var_gap = sum((g - mean_gap)**2 for g in gaps) / len(gaps)
print(f"Mean gap: {mean_gap:.4f}")
print(f"Gap variance: {var_gap:.4f}")

for lag in [1, 2, 3, 4, 5, 6, 10, 15, 30]:
    corr = sum((gaps[i] - mean_gap) * (gaps[i+lag] - mean_gap) for i in range(len(gaps)-lag))
    corr /= (len(gaps) - lag) * var_gap
    print(f"  Autocorrelation at lag {lag:>3}: {corr:>8.5f}")

# DISCOVERY 5: Modular gap patterns
print("\n\nDISCOVERY 5: Prime gaps mod 6 distribution")
gap_mod6 = Counter(g % 6 for g in gaps)
total_gaps = len(gaps)
for r in range(6):
    count = gap_mod6.get(r, 0)
    print(f"  Gaps ≡ {r} (mod 6): {count} ({100*count/total_gaps:.1f}%)")

print("\n\nDISCOVERY 6: Gaps that are prime vs composite")
prime_set = set(primes)
prime_gaps = sum(1 for g in gaps if g in prime_set)
composite_gaps = sum(1 for g in gaps if g > 1 and g not in prime_set)
print(f"  Gaps that are prime: {prime_gaps} ({100*prime_gaps/len(gaps):.1f}%)")
print(f"  Gaps that are composite: {composite_gaps} ({100*composite_gaps/len(gaps):.1f}%)")
print(f"  Gaps = 1: {gaps.count(1)}")
print(f"  Most common gap sizes:")
for gap_val, count in Counter(gaps).most_common(10):
    print(f"    Gap {gap_val}: {count} times")
