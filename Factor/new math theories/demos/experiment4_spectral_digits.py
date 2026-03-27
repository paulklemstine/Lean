"""
Experiment 4: Spectral Theory of Digit Sum Functions
=====================================================

We treat the digit sum function s_b(n) in base b as a signal and
perform discrete Fourier analysis. 

KEY INNOVATION: We define a "cross-base resonance" — the correlation
between digit sums in different bases. We hypothesize that certain
base pairs (b1, b2) exhibit anomalous correlations connected to 
the algebraic relationship between b1 and b2.

SECONDARY INNOVATION: We define the "digit entropy" H_b(n) as the
Shannon entropy of the digit distribution of n in base b, and study
how H_b(n) relates to number-theoretic properties.
"""

import math
from collections import Counter
import json

def digit_sum(n, base=10):
    """Sum of digits of n in given base."""
    if n == 0:
        return 0
    s = 0
    while n > 0:
        s += n % base
        n //= base
    return s

def digits(n, base=10):
    """Return list of digits of n in given base."""
    if n == 0:
        return [0]
    d = []
    while n > 0:
        d.append(n % base)
        n //= base
    return d

def digit_entropy(n, base=10):
    """Shannon entropy of digit distribution of n in given base."""
    if n <= 0:
        return 0
    d = digits(n, base)
    counts = Counter(d)
    total = len(d)
    entropy = 0
    for count in counts.values():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)
    return entropy

# === EXPERIMENT 4A: Cross-base digit sum correlations ===
print("=" * 60)
print("EXPERIMENT 4A: Cross-Base Digit Sum Correlations")
print("=" * 60)

N = 50000
bases = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16]

# Compute digit sums
digit_sums = {}
for b in bases:
    digit_sums[b] = [digit_sum(n, b) for n in range(1, N + 1)]

# Compute correlations between all pairs
import statistics

def correlation(x, y):
    """Pearson correlation between two sequences."""
    n = len(x)
    mx, my = sum(x)/n, sum(y)/n
    sx = math.sqrt(sum((xi - mx)**2 for xi in x) / n)
    sy = math.sqrt(sum((yi - my)**2 for yi in y) / n)
    if sx == 0 or sy == 0:
        return 0
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y)) / (n * sx * sy)

print(f"\nPearson correlations between digit sums in different bases (n=1..{N}):")
print(f"{'':>5}", end='')
for b2 in bases:
    print(f"{b2:>6}", end='')
print()

corr_matrix = {}
for b1 in bases:
    print(f"{b1:>4}:", end='')
    for b2 in bases:
        c = correlation(digit_sums[b1], digit_sums[b2])
        corr_matrix[(b1, b2)] = c
        print(f"{c:>6.3f}", end='')
    print()

# Highlight interesting pairs
print("\nMost correlated non-trivial pairs (excluding b1=b2):")
pairs = []
for i, b1 in enumerate(bases):
    for b2 in bases[i+1:]:
        pairs.append((corr_matrix[(b1, b2)], b1, b2))
pairs.sort(reverse=True)
for c, b1, b2 in pairs[:10]:
    relationship = ""
    if b2 == b1**2:
        relationship = f" ({b2} = {b1}²)"
    elif b1 * b2 in [b**2 for b in range(2, 20)]:
        relationship = f" (product is perfect square)"
    elif math.gcd(b1, b2) > 1:
        relationship = f" (gcd = {math.gcd(b1, b2)})"
    print(f"  bases ({b1}, {b2}): r = {c:.6f}{relationship}")

# === EXPERIMENT 4B: Digit entropy and primality ===
print("\n" + "=" * 60)
print("EXPERIMENT 4B: Digit Entropy and Primality")
print("=" * 60)

def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

for base in [2, 3, 10]:
    prime_entropies = []
    composite_entropies = []
    
    for n in range(100, 10000):
        ent = digit_entropy(n, base)
        if is_prime(n):
            prime_entropies.append(ent)
        else:
            composite_entropies.append(ent)
    
    print(f"\nBase {base}:")
    print(f"  Primes:     mean entropy = {statistics.mean(prime_entropies):.6f}, "
          f"std = {statistics.stdev(prime_entropies):.6f}")
    print(f"  Composites: mean entropy = {statistics.mean(composite_entropies):.6f}, "
          f"std = {statistics.stdev(composite_entropies):.6f}")
    diff = statistics.mean(prime_entropies) - statistics.mean(composite_entropies)
    print(f"  Difference: {diff:+.6f} ({'primes higher' if diff > 0 else 'composites higher'})")

# === EXPERIMENT 4C: Fourier spectrum of digit sum function ===
print("\n" + "=" * 60)
print("EXPERIMENT 4C: Fourier Spectrum of Digit Sum Function")
print("=" * 60)

def simple_dft(signal, n_freq=100):
    """Compute DFT magnitudes for first n_freq frequencies."""
    N = len(signal)
    magnitudes = []
    for k in range(1, n_freq + 1):
        real_part = sum(signal[n] * math.cos(2 * math.pi * k * n / N) for n in range(N))
        imag_part = sum(signal[n] * math.sin(2 * math.pi * k * n / N) for n in range(N))
        magnitudes.append(math.sqrt(real_part**2 + imag_part**2) / N)
    return magnitudes

# DFT of digit sum in base 10
signal = [digit_sum(n, 10) for n in range(1, 5001)]
spectrum = simple_dft(signal, n_freq=50)

print("Fourier spectrum of s_10(n) — top frequencies by magnitude:")
indexed_spectrum = [(mag, k+1) for k, mag in enumerate(spectrum)]
indexed_spectrum.sort(reverse=True)
for mag, freq in indexed_spectrum[:15]:
    period = 5000 / freq
    print(f"  freq={freq:4d} (period ≈ {period:8.1f}): magnitude = {mag:.6f}")

# === EXPERIMENT 4D: The "Digital Root Attractor" ===
print("\n" + "=" * 60)
print("EXPERIMENT 4D: Digital Root Dynamics in Multiple Bases")
print("=" * 60)

def digital_root(n, base=10):
    """Iterate digit sum until single digit."""
    while n >= base:
        n = digit_sum(n, base)
    return n

# Distribution of digital roots
for base in [2, 3, 7, 10, 12]:
    roots = Counter(digital_root(n, base) for n in range(1, 100001))
    total = sum(roots.values())
    print(f"\nBase {base} digital root distribution:")
    for r in sorted(roots.keys()):
        pct = 100 * roots[r] / total
        bar = '#' * int(pct)
        print(f"  root {r:2d}: {pct:6.2f}% {bar}")

# === EXPERIMENT 4E: Novel statistic — "Digit Variance Spectrum" ===
print("\n" + "=" * 60)
print("EXPERIMENT 4E: Digit Variance Spectrum (NEW)")
print("=" * 60)

def digit_variance(n, base=10):
    """Variance of digits of n in given base."""
    d = digits(n, base)
    if len(d) <= 1:
        return 0
    mean_d = sum(d) / len(d)
    return sum((x - mean_d)**2 for x in d) / len(d)

# How does digit variance grow with n?
for base in [2, 10]:
    print(f"\nBase {base} — Mean digit variance by magnitude:")
    for exp in range(2, 7):
        low = base**exp
        high = min(base**(exp+1), 500000)
        if low >= high:
            break
        variances = [digit_variance(n, base) for n in range(low, min(high, low + 5000))]
        print(f"  {base}^{exp} to {base}^{exp+1}: mean var = {statistics.mean(variances):.4f}, "
              f"num_digits = {exp+1}")

# Save results
results = {
    "cross_base_top_correlations": [(c, b1, b2) for c, b1, b2 in pairs[:10]],
}

with open('/workspace/request-project/figures/experiment4_results.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\n✓ Results saved to figures/experiment4_results.json")
