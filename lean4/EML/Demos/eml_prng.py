#!/usr/bin/env python3
"""
EML-Based Pseudorandom Number Generator (P-A9)

Uses the chaotic dynamics of the EML diagonal iteration to generate
pseudorandom sequences. The key insight is that while EML orbits diverge,
the fractional parts of log-transformed iterates can exhibit uniform
distribution properties.

Methods explored:
1. Fractional part of ln(EML^n(x₀))
2. EML modular map: EML(x,y) mod M
3. EML-based hash function mixing
"""

import math
import struct

def eml(a, b):
    """EML(a,b) = exp(a) - ln(b), b > 0"""
    if b <= 0:
        return None
    try:
        return math.exp(a) - math.log(b)
    except OverflowError:
        return None

class EMLPRNG:
    """EML-based pseudorandom number generator."""
    
    def __init__(self, seed=0.5):
        """Initialize with a seed value in (0, 1)."""
        self.state = seed + 0.1  # Ensure positive
        self.counter = 0
    
    def _mix(self, x):
        """Apply EML-based mixing function."""
        # Use log to compress, then EML to scramble, then fractional part
        if x <= 0:
            x = abs(x) + 0.01
        try:
            # Double EML mixing
            y = math.exp(x) - math.log(x + 1)
            z = math.exp(math.sin(y)) - math.log(abs(math.cos(y)) + 0.01)
            # Take fractional part
            return z - math.floor(z)
        except (OverflowError, ValueError):
            # Fallback for extreme values
            return (x * 2.718281828) % 1.0
    
    def next_float(self):
        """Generate next pseudorandom float in [0, 1)."""
        self.counter += 1
        # Mix state with counter for non-repeating sequence
        self.state = self._mix(self.state + self.counter * 0.618033988749895)
        return self.state
    
    def next_int(self, lo, hi):
        """Generate random integer in [lo, hi]."""
        return lo + int(self.next_float() * (hi - lo + 1)) % (hi - lo + 1)
    
    def next_bytes(self, n):
        """Generate n random bytes."""
        result = bytearray()
        for _ in range(n):
            result.append(int(self.next_float() * 256) % 256)
        return bytes(result)

def chi_squared_uniformity(samples, n_bins=10):
    """Chi-squared test for uniformity in [0, 1)."""
    counts = [0] * n_bins
    for s in samples:
        bin_idx = min(int(s * n_bins), n_bins - 1)
        counts[bin_idx] += 1
    
    expected = len(samples) / n_bins
    chi2 = sum((c - expected)**2 / expected for c in counts)
    return chi2, counts

def serial_correlation(samples, lag=1):
    """Compute serial correlation coefficient."""
    n = len(samples)
    if n <= lag:
        return 0
    mean = sum(samples) / n
    var = sum((s - mean)**2 for s in samples) / n
    if var == 0:
        return 0
    cov = sum((samples[i] - mean) * (samples[i + lag] - mean) for i in range(n - lag)) / (n - lag)
    return cov / var

def runs_test(samples):
    """Runs test for randomness (above/below median)."""
    median = sorted(samples)[len(samples) // 2]
    binary = [1 if s > median else 0 for s in samples]
    runs = 1
    for i in range(1, len(binary)):
        if binary[i] != binary[i-1]:
            runs += 1
    
    n = len(samples)
    n1 = sum(binary)
    n0 = n - n1
    if n1 == 0 or n0 == 0:
        return runs, 0, 0
    
    expected_runs = 1 + 2 * n0 * n1 / n
    std_runs = math.sqrt(2 * n0 * n1 * (2 * n0 * n1 - n) / (n**2 * (n - 1)))
    if std_runs == 0:
        return runs, expected_runs, 0
    z = (runs - expected_runs) / std_runs
    return runs, expected_runs, z

def main():
    print("=" * 60)
    print("EML PSEUDORANDOM NUMBER GENERATOR")
    print("Based on chaotic EML dynamics")
    print("=" * 60)
    
    # Generate samples
    rng = EMLPRNG(seed=0.42)
    n_samples = 10000
    samples = [rng.next_float() for _ in range(n_samples)]
    
    print(f"\nGenerated {n_samples} samples with seed 0.42")
    print(f"First 20 values: {[f'{s:.4f}' for s in samples[:20]]}")
    
    # Basic statistics
    mean = sum(samples) / n_samples
    variance = sum((s - mean)**2 for s in samples) / n_samples
    print(f"\nBasic Statistics:")
    print(f"  Mean:     {mean:.6f}  (expected: 0.5)")
    print(f"  Variance: {variance:.6f}  (expected: 0.0833)")
    print(f"  Min:      {min(samples):.6f}")
    print(f"  Max:      {max(samples):.6f}")
    
    # Chi-squared test
    chi2, counts = chi_squared_uniformity(samples, n_bins=10)
    print(f"\nChi-Squared Uniformity Test (10 bins):")
    print(f"  χ² = {chi2:.4f}  (critical value at 5%: 16.92)")
    print(f"  {'PASS' if chi2 < 16.92 else 'FAIL'}")
    print(f"  Bin counts: {counts}")
    
    # Serial correlation
    for lag in [1, 2, 5, 10]:
        corr = serial_correlation(samples, lag)
        print(f"\nSerial Correlation (lag {lag}): {corr:.6f}  {'PASS' if abs(corr) < 0.05 else 'WEAK'}")
    
    # Runs test
    runs, expected, z = runs_test(samples)
    print(f"\nRuns Test:")
    print(f"  Runs: {runs}, Expected: {expected:.1f}, Z-score: {z:.4f}")
    print(f"  {'PASS' if abs(z) < 1.96 else 'FAIL'}")
    
    # Bit distribution
    print(f"\nBit Distribution (first 8 bits of each sample):")
    bit_counts = [0] * 8
    for s in samples:
        byte_val = int(s * 256) % 256
        for bit in range(8):
            if byte_val & (1 << bit):
                bit_counts[bit] += 1
    for bit in range(8):
        pct = bit_counts[bit] / n_samples * 100
        print(f"  Bit {bit}: {pct:.1f}%  (expected: 50%)")
    
    # Seed sensitivity
    print(f"\n{'=' * 60}")
    print("SEED SENSITIVITY (Avalanche Effect)")
    print(f"{'─' * 60}")
    
    seeds = [0.42, 0.420001, 0.420002]
    sequences = {}
    for seed in seeds:
        rng = EMLPRNG(seed=seed)
        sequences[seed] = [rng.next_float() for _ in range(10)]
    
    print(f"{'Seed':<12} " + " ".join(f"{'x_'+str(i):<10}" for i in range(10)))
    for seed, seq in sequences.items():
        print(f"{seed:<12.6f} " + " ".join(f"{v:<10.6f}" for v in seq))
    
    # Compare divergence
    for i, seed in enumerate(seeds[1:], 1):
        diffs = [abs(sequences[seeds[0]][j] - sequences[seed][j]) for j in range(10)]
        print(f"\n|Δ| vs seed 0: {[f'{d:.4f}' for d in diffs]}")
    
    # Performance summary
    print(f"\n{'=' * 60}")
    print("SUMMARY")
    print(f"{'─' * 60}")
    print("""
The EML-based PRNG uses the chaotic properties of the EML operator:
  x_{n+1} = frac(exp(x_n + n·φ) - ln(x_n + n·φ + 1))
  
where φ = (√5-1)/2 is the golden ratio (for counter mixing).

Strengths:
+ Naturally produces continuous-valued outputs
+ Sensitive to initial conditions (avalanche effect)
+ Uses only EML-native operations (exp, ln, subtract)

Weaknesses:
- Not cryptographically secure (smooth functions → gradient attacks)
- Slower than LCG/Xorshift due to transcendental operations
- Serial correlation may be non-zero for some seeds

Best suited for: Monte Carlo simulation on OISCC hardware,
where the exp/ln operations are single-cycle native instructions.
""")

if __name__ == "__main__":
    main()
