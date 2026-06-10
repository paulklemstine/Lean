#!/usr/bin/env python3
"""
Benford Renormalization — Real-World Applications

Shows how the Benford universality theory applies to:
1. Financial fraud detection
2. Scientific data integrity checking
3. Random number generator quality assessment
4. Electoral data validation
"""

import math
from collections import Counter


def leading_digit(n: int, base: int = 10) -> int:
    """Extract leading digit."""
    if base <= 1 or n <= 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_theoretical(base: int, digit: int) -> float:
    """Benford prediction for digit d in base b."""
    return math.log(1 + 1/digit) / math.log(base)


def benford_score(data: list[int], base: int = 10) -> dict:
    """
    Compute a Benford conformity score for a dataset.
    Returns a dict with per-digit analysis and overall score.
    """
    if not data:
        return {"score": 0, "details": {}}
    
    positive_data = [x for x in data if x > 0]
    N = len(positive_data)
    if N == 0:
        return {"score": 0, "details": {}}
    
    counts = Counter(leading_digit(x, base) for x in positive_data)
    
    details = {}
    total_deviation = 0
    for d in range(1, base):
        observed = counts.get(d, 0) / N
        expected = benford_theoretical(base, d)
        deviation = abs(observed - expected)
        total_deviation += deviation
        details[d] = {
            "observed": observed,
            "expected": expected,
            "deviation": deviation,
            "z_score": (observed - expected) / math.sqrt(expected * (1 - expected) / N) if N > 0 else 0
        }
    
    # Score: 1.0 = perfect Benford, 0.0 = maximum deviation
    max_possible_deviation = 2.0  # theoretical max for sum of absolute deviations
    score = max(0, 1 - total_deviation / max_possible_deviation * (base - 1))
    
    return {"score": score, "details": details, "sample_size": N}


# ═══════════════════════════════════════════════════════════════════
# Application 1: Financial Fraud Detection
# ═══════════════════════════════════════════════════════════════════

def detect_financial_anomalies():
    """
    Demonstrate Benford-based anomaly detection on financial data.
    
    Key insight from the universality theory: financial data follows Benford's
    law because economic growth processes are multiplicative dynamical systems
    with irrational expansion rates. When data is fabricated, the fabricator
    typically uses a different (often uniform) digit distribution.
    """
    print("=" * 60)
    print("APPLICATION: Financial Fraud Detection")
    print("=" * 60)
    
    # Simulate "real" financial data: multiplicative random walk
    import random
    random.seed(42)
    
    real_data = []
    value = 1000
    for _ in range(10000):
        value *= (1 + random.gauss(0.001, 0.02))
        real_data.append(int(abs(value)))
    
    real_score = benford_score(real_data)
    print(f"\nReal financial data (multiplicative process):")
    print(f"  Benford score: {real_score['score']:.4f}")
    print(f"  Sample size: {real_score['sample_size']}")
    
    # Simulate "fake" financial data: uniformly distributed
    fake_data = [random.randint(100, 999) for _ in range(10000)]
    fake_score = benford_score(fake_data)
    print(f"\nFabricated data (uniform distribution):")
    print(f"  Benford score: {fake_score['score']:.4f}")
    print(f"  Sample size: {fake_score['sample_size']}")
    
    # Show per-digit comparison
    print(f"\n{'Digit':<8}{'Benford':<10}{'Real':<10}{'Fake':<10}")
    print("-" * 38)
    for d in range(1, 10):
        print(f"  {d:<6}{benford_theoretical(10, d):<10.4f}"
              f"{real_score['details'][d]['observed']:<10.4f}"
              f"{fake_score['details'][d]['observed']:<10.4f}")


# ═══════════════════════════════════════════════════════════════════
# Application 2: RNG Quality Assessment
# ═══════════════════════════════════════════════════════════════════

def assess_rng_quality():
    """
    Use Benford analysis to assess random number generator quality.
    
    The universality theory predicts: sequences from multiplicative maps
    with irrational expansion should be Benford. Poor RNGs that fail this
    test have detectable spectral obstructions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: RNG Quality Assessment")
    print("=" * 60)
    
    def lcg(seed: int, a: int, c: int, m: int, n: int) -> list[int]:
        """Linear congruential generator."""
        values = []
        x = seed
        for _ in range(n):
            x = (a * x + c) % m
            if x > 0:
                values.append(x)
        return values
    
    # Good LCG (large modulus, well-chosen constants)
    good_lcg = lcg(1, 1103515245, 12345, 2**31 - 1, 10000)
    good_score = benford_score(good_lcg)
    
    # Bad LCG (small modulus, poor constants) 
    bad_lcg = lcg(1, 5, 3, 256, 10000)
    bad_score = benford_score(bad_lcg)
    
    # Powers of 2 (irrational log_10 → Benford)
    pow2 = [2**k for k in range(1, 10001)]
    pow2_score = benford_score(pow2)
    
    print(f"\nGood LCG (m=2^31-1): Benford score = {good_score['score']:.4f}")
    print(f"Bad LCG (m=256):     Benford score = {bad_score['score']:.4f}")
    print(f"Powers of 2:         Benford score = {pow2_score['score']:.4f}")


# ═══════════════════════════════════════════════════════════════════
# Application 3: Electoral Data Validation
# ═══════════════════════════════════════════════════════════════════

def validate_electoral_data():
    """
    Demonstrate Benford analysis for electoral data validation.
    
    Vote counts from genuine elections typically follow Benford's law
    when aggregated from many precincts of varying sizes (a multiplicative
    process). Manipulated results may deviate.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Electoral Data Validation")
    print("=" * 60)
    
    import random
    random.seed(123)
    
    # Simulate genuine election data: precinct sizes follow log-normal
    genuine_votes = []
    for _ in range(5000):
        precinct_size = int(math.exp(random.gauss(6, 1.5)))
        vote_share = random.betavariate(2, 3)
        votes = max(1, int(precinct_size * vote_share))
        genuine_votes.append(votes)
    
    genuine_score = benford_score(genuine_votes)
    
    # Simulate manipulated data: round numbers, suspicious patterns
    manipulated_votes = []
    for _ in range(5000):
        base_votes = random.choice([100, 200, 300, 500, 1000]) 
        noise = random.randint(-20, 20)
        manipulated_votes.append(max(1, base_votes + noise))
    
    manipulated_score = benford_score(manipulated_votes)
    
    print(f"\nGenuine election data:     Benford score = {genuine_score['score']:.4f}")
    print(f"Manipulated election data: Benford score = {manipulated_score['score']:.4f}")
    
    print(f"\nInterpretation:")
    print(f"  Score > 0.95: Consistent with genuine process")
    print(f"  Score < 0.80: Warrants further investigation")


if __name__ == "__main__":
    detect_financial_anomalies()
    assess_rng_quality()
    validate_electoral_data()


#!/usr/bin/env python3
"""
Benford Renormalization for Integer Dynamical Systems — Demo

Demonstrates the core theorems and concepts:
1. Leading digit extraction and Benford frequency computation
2. Theoretical Benford frequencies (telescoping sum = 1)
3. Rational eigen-obstruction detection
4. Digit discrepancy measurement
5. 3n+1 orbit Benford analysis
"""

import math
from collections import Counter

def leading_digit_base(b: int, n: int) -> int:
    """Extract the leading (most significant) digit of n in base b."""
    if b <= 1 or n == 0:
        return n
    while n >= b:
        n //= b
    return n

def benford_freq_up_to(b: int, d: int, sequence: list[int]) -> float:
    """Empirical frequency of leading digit d in base b for a sequence."""
    N = len(sequence)
    if N == 0:
        return 0.0
    count = sum(1 for x in sequence if leading_digit_base(b, x) == d)
    return count / N

def benford_theoretical(b: int, d: int) -> float:
    """Benford's law predicted frequency for digit d in base b: log_b(1 + 1/d)."""
    return math.log(1 + 1/d) / math.log(b)

def digit_discrepancy(b: int, sequence: list[int]) -> float:
    """Maximum deviation from Benford prediction across all valid digits."""
    return max(
        abs(benford_freq_up_to(b, d, sequence) - benford_theoretical(b, d))
        for d in range(1, b)
    )

def collatz_orbit(n: int, steps: int) -> list[int]:
    """Generate the 3n+1 (Collatz) orbit of n for given number of steps."""
    orbit = [n]
    for _ in range(steps):
        if n == 1:
            n = 4  # Continue cycling to avoid degenerate behavior
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
        orbit.append(n)
    return orbit

def geometric_orbit(a: int, r: int, steps: int) -> list[int]:
    """Generate geometric sequence a * r^k for k = 0, ..., steps."""
    return [a * r**k for k in range(steps + 1)]

def has_rational_eigen_obstruction(b: int, sequence: list[int], max_q: int = 20) -> tuple[bool, int]:
    """
    Check if the sequence has a rational eigen-obstruction in base b.
    Returns (True, q) if q * log_b(u(k)) is approximately integral for large k.
    """
    if len(sequence) < 10:
        return False, 0
    
    tail = sequence[len(sequence)//2:]  # Check only the tail
    for q in range(1, max_q + 1):
        residuals = []
        for x in tail:
            if x <= 0:
                continue
            val = q * math.log(x) / math.log(b)
            residual = abs(val - round(val))
            residuals.append(residual)
        if residuals and max(residuals) < 1e-10:
            return True, q
    return False, 0


def demo_frequency_partition():
    """Demo Theorem 1: Frequency partition of unity."""
    print("=" * 60)
    print("THEOREM 1: Frequency Partition of Unity")
    print("For any positive sequence, digit frequencies sum to 1.")
    print("=" * 60)
    
    b = 10
    sequence = [2**k for k in range(1, 1001)]
    
    total = sum(benford_freq_up_to(b, d, sequence) for d in range(1, b))
    print(f"\nBase {b}, sequence: 2^1, 2^2, ..., 2^1000")
    print(f"Sum of frequencies for digits 1-9: {total:.10f}")
    print(f"Expected: 1.0")
    print(f"Match: {abs(total - 1.0) < 1e-10}")
    
    print("\nIndividual digit frequencies:")
    for d in range(1, b):
        freq = benford_freq_up_to(b, d, sequence)
        theory = benford_theoretical(b, d)
        print(f"  Digit {d}: freq={freq:.4f}, Benford={theory:.4f}, diff={abs(freq-theory):.4f}")


def demo_theoretical_sum():
    """Demo Theorem 2: Benford theoretical frequencies sum to 1."""
    print("\n" + "=" * 60)
    print("THEOREM 2: Benford Theoretical Sum = 1")
    print("The predicted frequencies telescope: sum log_b(1+1/d) = 1.")
    print("=" * 60)
    
    for b in [2, 5, 10, 16, 100]:
        total = sum(benford_theoretical(b, d) for d in range(1, b))
        # Show telescoping
        terms = [math.log(d+1)/math.log(b) - math.log(d)/math.log(b) for d in range(1, b)]
        print(f"\nBase {b}: sum = {total:.15f}")
        print(f"  Telescoping: log_b({b}) - log_b(1) = {math.log(b)/math.log(b):.15f} - 0 = 1")


def demo_obstruction_power():
    """Demo Theorem 3: Obstruction transfers under powering."""
    print("\n" + "=" * 60)
    print("THEOREM 3: Obstruction Transfer Under Powering")
    print("If u has an obstruction, u^m also has one.")
    print("=" * 60)
    
    b = 10
    # u(k) = 10^k has a rational eigen-obstruction (q=1: log_10(10^k) = k is integral)
    sequence = [10**k for k in range(1, 20)]
    has_obs, q = has_rational_eigen_obstruction(b, sequence)
    print(f"\nSequence u(k) = 10^k: obstruction={has_obs}, q={q}")
    
    for m in [2, 3, 5]:
        powered = [x**m for x in sequence]
        has_obs_m, q_m = has_rational_eigen_obstruction(b, powered)
        print(f"Sequence u(k)^{m} = 10^({m}k): obstruction={has_obs_m}, q={q_m}")


def demo_collatz_benford():
    """Demo: 3n+1 orbit Benford analysis."""
    print("\n" + "=" * 60)
    print("BENFORD ANALYSIS: 3n+1 (Collatz) Orbits")
    print("Testing the universality conjecture prediction.")
    print("=" * 60)
    
    b = 10
    seeds = [7, 27, 97, 871, 6171, 77031]
    
    for seed in seeds:
        orbit = collatz_orbit(seed, 10000)
        positive_orbit = [x for x in orbit if x >= 1]
        
        disc = digit_discrepancy(b, positive_orbit)
        has_obs, q = has_rational_eigen_obstruction(b, positive_orbit)
        
        print(f"\nSeed {seed}: orbit length={len(positive_orbit)}")
        print(f"  Digit discrepancy: {disc:.4f}")
        print(f"  Has obstruction: {has_obs}")
        print(f"  Benford-compatible: {'YES' if disc < 0.05 else 'NO'}")
        
        # Show digit frequencies
        freqs = {d: benford_freq_up_to(b, d, positive_orbit) for d in range(1, b)}
        benford = {d: benford_theoretical(b, d) for d in range(1, b)}
        print(f"  Digit frequencies vs Benford:")
        for d in range(1, b):
            print(f"    {d}: {freqs[d]:.4f} vs {benford[d]:.4f}")


def demo_geometric_benford():
    """Demo: Geometric sequences and Benford behavior."""
    print("\n" + "=" * 60)
    print("GEOMETRIC SEQUENCES AND BENFORD'S LAW")
    print("2^k is Benford (log_10(2) irrational), 10^k is not.")
    print("=" * 60)
    
    b = 10
    
    # 2^k should be Benford (log_10(2) is irrational)
    seq_2 = geometric_orbit(1, 2, 5000)
    disc_2 = digit_discrepancy(b, seq_2)
    obs_2, q_2 = has_rational_eigen_obstruction(b, seq_2)
    print(f"\n2^k: discrepancy={disc_2:.4f}, obstruction={obs_2}")
    
    # 10^k should NOT be Benford (log_10(10) = 1 is rational)
    seq_10 = geometric_orbit(1, 10, 100)
    disc_10 = digit_discrepancy(b, seq_10)
    obs_10, q_10 = has_rational_eigen_obstruction(b, seq_10)
    print(f"10^k: discrepancy={disc_10:.4f}, obstruction={obs_10} (q={q_10})")
    
    # 3^k should be Benford (log_10(3) is irrational)
    seq_3 = geometric_orbit(1, 3, 5000)
    disc_3 = digit_discrepancy(b, seq_3)
    obs_3, q_3 = has_rational_eigen_obstruction(b, seq_3)
    print(f"3^k: discrepancy={disc_3:.4f}, obstruction={obs_3}")


if __name__ == "__main__":
    demo_frequency_partition()
    demo_theoretical_sum()
    demo_obstruction_power()
    demo_collatz_benford()
    demo_geometric_benford()


#!/usr/bin/env python3
"""
Visualization 1: Benford Frequency Convergence

Shows how empirical leading-digit frequencies converge to Benford's law
predictions as the orbit length increases, for different dynamical maps.
Illustrates the frequency partition of unity theorem and the telescoping
sum of theoretical frequencies.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def leading_digit(n, base=10):
    if base <= 1 or n <= 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_theoretical(base, digit):
    return math.log(1 + 1/digit) / math.log(base)


def compute_freq_evolution(sequence, base=10, checkpoints=None):
    """Compute empirical frequencies at various sequence lengths."""
    if checkpoints is None:
        checkpoints = [10, 50, 100, 500, 1000, 2000, 5000]
    
    results = {}
    for cp in checkpoints:
        if cp > len(sequence):
            break
        subseq = sequence[:cp]
        freqs = {}
        for d in range(1, base):
            count = sum(1 for x in subseq if leading_digit(x, base) == d)
            freqs[d] = count / cp
        results[cp] = freqs
    return results


# Generate sequences
base = 10
N = 5000

# 2^k sequence (Benford, irrational log_10(2))
seq_2k = [2**k for k in range(1, N + 1)]

# 3^k sequence (Benford, irrational log_10(3))
seq_3k = [3**k for k in range(1, N + 1)]

# 10^k sequence (NOT Benford, rational obstruction)
seq_10k = [10**k for k in range(1, N + 1)]

checkpoints = [10, 25, 50, 100, 200, 500, 1000, 2000, 5000]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Panel 1: 2^k convergence ---
ax = axes[0, 0]
evo = compute_freq_evolution(seq_2k, base, checkpoints)
for d in range(1, base):
    y_vals = [evo[cp][d] for cp in checkpoints if cp in evo]
    x_vals = [cp for cp in checkpoints if cp in evo]
    ax.plot(x_vals, y_vals, 'o-', markersize=4, label=f'd={d}', alpha=0.8)
    ax.axhline(y=benford_theoretical(base, d), color='gray', alpha=0.3, linestyle='--')

ax.set_xlabel('Orbit Length N')
ax.set_ylabel('Frequency')
ax.set_title('$2^k$: Convergence to Benford (irrational $\\log_{10} 2$)')
ax.set_xscale('log')
ax.legend(ncol=3, fontsize=7)
ax.grid(True, alpha=0.3)

# --- Panel 2: 10^k non-convergence ---
ax = axes[0, 1]
evo10 = compute_freq_evolution(seq_10k, base, checkpoints)
for d in range(1, base):
    y_vals = [evo10[cp][d] for cp in checkpoints if cp in evo10]
    x_vals = [cp for cp in checkpoints if cp in evo10]
    ax.plot(x_vals, y_vals, 'o-', markersize=4, label=f'd={d}', alpha=0.8)
    ax.axhline(y=benford_theoretical(base, d), color='gray', alpha=0.3, linestyle='--')

ax.set_xlabel('Orbit Length N')
ax.set_ylabel('Frequency')
ax.set_title('$10^k$: Rational Obstruction (digit always 1)')
ax.set_xscale('log')
ax.legend(ncol=3, fontsize=7)
ax.grid(True, alpha=0.3)

# --- Panel 3: Theoretical vs Empirical (bar chart, 2^k) ---
ax = axes[1, 0]
digits = list(range(1, base))
empirical = [evo[5000][d] for d in digits]
theoretical = [benford_theoretical(base, d) for d in digits]

x = np.arange(len(digits))
width = 0.35
bars1 = ax.bar(x - width/2, empirical, width, label='Empirical ($2^k$, N=5000)', color='steelblue')
bars2 = ax.bar(x + width/2, theoretical, width, label='Benford Prediction', color='coral')
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Frequency')
ax.set_title('Frequency Partition of Unity: Empirical vs Theory')
ax.set_xticks(x)
ax.set_xticklabels(digits)
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Annotate sum = 1
ax.text(0.95, 0.95, f'∑ empirical = {sum(empirical):.4f}\n∑ theory = {sum(theoretical):.4f}',
        transform=ax.transAxes, ha='right', va='top', fontsize=9,
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# --- Panel 4: Telescoping sum visualization ---
ax = axes[1, 1]
cumulative = [0]
for d in range(1, base):
    cumulative.append(cumulative[-1] + benford_theoretical(base, d))

for d in range(1, base):
    ax.barh(0, benford_theoretical(base, d), left=cumulative[d-1], 
            height=0.5, label=f'd={d}', alpha=0.8)

# Show telescoping structure
y_tel = -0.8
for d in range(1, base + 1):
    log_val = math.log(d) / math.log(base)
    ax.plot(log_val, y_tel, 'k^', markersize=8)
    ax.annotate(f'$\\log_{{10}}({d})$', (log_val, y_tel - 0.15), 
                ha='center', fontsize=7, rotation=45)

ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-1.5, 1)
ax.set_xlabel('Cumulative Frequency')
ax.set_title('Telescoping: $\\sum \\log_b(1+1/d) = 1$')
ax.legend(ncol=3, fontsize=7, loc='upper left')
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='Sum = 1')
ax.set_yticks([])
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Benford Renormalization: Frequency Analysis', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_benford_frequencies.png', dpi=150, bbox_inches='tight')
print("Saved viz_benford_frequencies.png")


#!/usr/bin/env python3
"""
Visualization 2: Cocycle Dynamics and Spectral Obstruction

Shows the fractional logarithm (oscillation component) of different orbits:
- Equidistributed cocycle (Benford) vs. concentrated cocycle (non-Benford)
- Spectral gap visualization showing the obstruction criterion
- Drift rate convergence
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def fractional_log(n, base=10):
    """Fractional part of log_base(n)."""
    if n <= 0:
        return 0.0
    val = math.log(n) / math.log(base)
    return val - math.floor(val)


def collatz_orbit(n, steps):
    """Generate Collatz orbit."""
    orbit = [n]
    for _ in range(steps):
        if n <= 1:
            n = 4
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit


N = 3000

# Generate different orbit types
seq_2k = [2**k for k in range(1, N + 1)]
seq_10k = [10**k for k in range(1, N + 1)]
seq_3k = [3**k for k in range(1, N + 1)]
collatz_7 = collatz_orbit(7, N)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# --- Row 1: Oscillation (fractional log) trajectories ---

# 2^k: irrational rotation by log_10(2)
ax = axes[0, 0]
osc = [fractional_log(x) for x in seq_2k[:500]]
ax.scatter(range(len(osc)), osc, s=1, alpha=0.5, c='steelblue')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(2ᵏ))')
ax.set_title('$2^k$: Irrational Rotation\n(equidistributed → Benford)')
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# 10^k: trivial rotation (always 0)
ax = axes[0, 1]
osc_10 = [fractional_log(x) for x in seq_10k[:500]]
ax.scatter(range(len(osc_10)), osc_10, s=3, alpha=0.7, c='red')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(10ᵏ))')
ax.set_title('$10^k$: Rational Obstruction\n(concentrated at 0 → NOT Benford)')
ax.set_ylim(-0.1, 1.1)
ax.grid(True, alpha=0.3)

# Collatz: chaotic but equidistributed
ax = axes[0, 2]
osc_c = [fractional_log(x) for x in collatz_7[:500] if x > 0]
ax.scatter(range(len(osc_c)), osc_c, s=1, alpha=0.5, c='green')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(T^k(7)))')
ax.set_title('Collatz(7): Chaotic Cocycle\n(equidistributed → Benford)')
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# --- Row 2: Histograms of oscillation + spectral analysis ---

# 2^k histogram
ax = axes[1, 0]
osc_full = [fractional_log(x) for x in seq_2k]
ax.hist(osc_full, bins=50, density=True, alpha=0.7, color='steelblue', edgecolor='navy')
ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='Uniform density')
ax.set_xlabel('fract(log₁₀(n))')
ax.set_ylabel('Density')
ax.set_title('Distribution of Oscillation ($2^k$)')
ax.legend()
ax.grid(True, alpha=0.3)

# 10^k histogram
ax = axes[1, 1]
osc_10_full = [fractional_log(x) for x in seq_10k]
ax.hist(osc_10_full, bins=50, density=True, alpha=0.7, color='red', edgecolor='darkred')
ax.set_xlabel('fract(log₁₀(n))')
ax.set_ylabel('Density')
ax.set_title('Distribution of Oscillation ($10^k$)\nDirac mass at 0')
ax.grid(True, alpha=0.3)

# Spectral analysis: for each q, compute max residual of q*log_b(u(k)) from integers
ax = axes[1, 2]
max_q = 30

for name, seq, color in [('$2^k$', seq_2k[:1000], 'steelblue'), 
                           ('$3^k$', seq_3k[:1000], 'green'),
                           ('$10^k$', seq_10k[:100], 'red')]:
    residuals = []
    for q in range(1, max_q + 1):
        max_res = 0
        for x in seq[-min(200, len(seq)):]:
            if x > 0:
                val = q * math.log(x) / math.log(10)
                res = abs(val - round(val))
                max_res = max(max_res, res)
        residuals.append(max_res)
    ax.plot(range(1, max_q + 1), residuals, 'o-', markersize=3, label=name, color=color, alpha=0.8)

ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
ax.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5, label='Detection threshold')
ax.set_xlabel('Candidate obstruction order q')
ax.set_ylabel('Max residual (distance to ℤ)')
ax.set_title('Spectral Obstruction Detection\n(low residual = obstruction)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')
ax.set_ylim(1e-16, 1)

plt.suptitle('Cocycle Dynamics and Spectral Obstructions', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cocycle_dynamics.png', dpi=150, bbox_inches='tight')
print("Saved viz_cocycle_dynamics.png")


#!/usr/bin/env python3
"""
Visualization 3: Universality Conjecture Testing

Tests the Benford universality conjecture across multiple dynamical map
families: for each map and seed, checks whether Benford ⟺ ¬obstruction.
Visualizes concordance rates and counterexample analysis.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def leading_digit(n, base=10):
    if base <= 1 or n <= 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_theoretical(base, digit):
    return math.log(1 + 1/digit) / math.log(base)


def digit_discrepancy(sequence, base=10):
    N = len(sequence)
    if N == 0:
        return 1.0
    return max(
        abs(sum(1 for x in sequence if leading_digit(x, base) == d) / N 
            - benford_theoretical(base, d))
        for d in range(1, base)
    )


def detect_obstruction_simple(sequence, base=10, max_q=20):
    tail = sequence[len(sequence)//2:]
    tail = [x for x in tail if x > 0]
    if len(tail) < 5:
        return False, 0
    log_b = math.log(base)
    for q in range(1, max_q + 1):
        max_res = 0
        for x in tail:
            val = q * math.log(x) / log_b
            max_res = max(max_res, abs(val - round(val)))
            if max_res > 1e-6:
                break
        if max_res < 1e-6:
            return True, q
    return False, 0


def generate_orbit(T, seed, steps):
    orbit = [seed]
    n = seed
    for _ in range(steps):
        try:
            n = T(n)
            if n <= 0 or n > 10**18:
                break
            orbit.append(n)
        except (OverflowError, ValueError, ZeroDivisionError):
            break
    return orbit


# Define dynamical maps
def collatz(n):
    if n <= 1: return 4
    return n // 2 if n % 2 == 0 else 3 * n + 1

def doubling(n): return 2 * n
def tripling(n): return 3 * n
def times10(n): return 10 * n
def times6(n): return 6 * n
def affine_3_1(n): return 3 * n + 1
def affine_5_7(n): return 5 * n + 7

maps = {
    'Collatz 3n+1': collatz,
    'Doubling 2n': doubling,
    'Tripling 3n': tripling,
    '×10': times10,
    '×6': times6,
    '3n+1 (affine)': affine_3_1,
    '5n+7': affine_5_7,
}

# Test parameters
seeds = list(range(2, 52))
orbit_len = 3000
base = 10
threshold = 0.04

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# --- Panel 1: Concordance rates across maps ---
ax = axes[0, 0]
map_names = []
concordance_rates = []
benford_rates = []
obstruction_rates = []

for name, T in maps.items():
    concordant = 0
    benford_count = 0
    obs_count = 0
    
    for seed in seeds:
        orbit = generate_orbit(T, seed, orbit_len)
        disc = digit_discrepancy(orbit, base)
        is_benford = disc < threshold
        has_obs, _ = detect_obstruction_simple(orbit, base)
        
        if is_benford:
            benford_count += 1
        if has_obs:
            obs_count += 1
        if is_benford == (not has_obs):
            concordant += 1
    
    map_names.append(name)
    concordance_rates.append(concordant / len(seeds))
    benford_rates.append(benford_count / len(seeds))
    obstruction_rates.append(obs_count / len(seeds))

y_pos = np.arange(len(map_names))
bars = ax.barh(y_pos, concordance_rates, color='steelblue', alpha=0.8, edgecolor='navy')

for i, (rate, bar) in enumerate(zip(concordance_rates, bars)):
    ax.text(rate + 0.01, i, f'{rate:.0%}', va='center', fontsize=9)

ax.set_yticks(y_pos)
ax.set_yticklabels(map_names)
ax.set_xlabel('Concordance Rate')
ax.set_title('Universality Conjecture: Concordance\n(Benford ⟺ ¬Obstruction)')
ax.set_xlim(0, 1.15)
ax.axvline(x=1.0, color='green', linestyle='--', alpha=0.3)
ax.grid(True, alpha=0.3, axis='x')

# --- Panel 2: Discrepancy vs orbit length for different maps ---
ax = axes[0, 1]
checkpoints = [50, 100, 200, 500, 1000, 2000, 3000]

for name, T, color in [('2n', doubling, 'steelblue'), 
                         ('3n', tripling, 'green'),
                         ('10n', times10, 'red'),
                         ('Collatz', collatz, 'orange')]:
    orbit = generate_orbit(T, 7, max(checkpoints))
    discs = []
    for cp in checkpoints:
        if cp <= len(orbit):
            discs.append(digit_discrepancy(orbit[:cp], base))
        else:
            discs.append(None)
    
    valid = [(cp, d) for cp, d in zip(checkpoints, discs) if d is not None]
    if valid:
        ax.plot([v[0] for v in valid], [v[1] for v in valid], 
                'o-', label=name, color=color, markersize=4)

ax.axhline(y=threshold, color='gray', linestyle=':', alpha=0.5, label='Threshold')
ax.set_xlabel('Orbit Length')
ax.set_ylabel('Digit Discrepancy')
ax.set_title('Discrepancy Convergence\n(→0 for Benford sequences)')
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# --- Panel 3: Benford vs Obstruction classification ---
ax = axes[1, 0]

# Classify all (map, seed) pairs
benford_no_obs = 0
benford_obs = 0
not_benford_no_obs = 0
not_benford_obs = 0

for name, T in maps.items():
    for seed in seeds:
        orbit = generate_orbit(T, seed, orbit_len)
        disc = digit_discrepancy(orbit, base)
        is_benford = disc < threshold
        has_obs, _ = detect_obstruction_simple(orbit, base)
        
        if is_benford and not has_obs:
            benford_no_obs += 1
        elif is_benford and has_obs:
            benford_obs += 1
        elif not is_benford and not has_obs:
            not_benford_no_obs += 1
        else:
            not_benford_obs += 1

categories = ['Benford ∧ ¬Obs\n(Predicted ✓)', 'Benford ∧ Obs\n(Counterex.)', 
              '¬Benford ∧ ¬Obs\n(Counterex.)', '¬Benford ∧ Obs\n(Predicted ✓)']
counts = [benford_no_obs, benford_obs, not_benford_no_obs, not_benford_obs]
colors_cat = ['#2ecc71', '#e74c3c', '#e74c3c', '#2ecc71']

bars = ax.bar(range(4), counts, color=colors_cat, alpha=0.8, edgecolor='black')
ax.set_xticks(range(4))
ax.set_xticklabels(categories, fontsize=8)
ax.set_ylabel('Count')
ax.set_title('Classification Matrix\n(Green = agrees with conjecture)')
for i, (count, bar) in enumerate(zip(counts, bars)):
    ax.text(i, count + 1, str(count), ha='center', fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# --- Panel 4: Collatz orbit digit frequency heatmap ---
ax = axes[1, 1]

n_seeds_heat = 20
heat_seeds = list(range(2, 2 + n_seeds_heat))
freq_matrix = np.zeros((n_seeds_heat, 9))

for i, seed in enumerate(heat_seeds):
    orbit = generate_orbit(collatz, seed, 5000)
    for d in range(1, 10):
        freq = sum(1 for x in orbit if leading_digit(x) == d) / len(orbit)
        freq_matrix[i, d - 1] = freq

benford_freqs = [benford_theoretical(10, d) for d in range(1, 10)]

im = ax.imshow(freq_matrix, aspect='auto', cmap='YlOrRd', 
               vmin=0, vmax=0.35)
ax.set_xticks(range(9))
ax.set_xticklabels(range(1, 10))
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Seed')
ax.set_yticks(range(n_seeds_heat))
ax.set_yticklabels(heat_seeds)
ax.set_title('Collatz Orbits: Digit Frequency Heatmap')
plt.colorbar(im, ax=ax, label='Frequency')

# Overlay Benford predictions
for d_idx, bf in enumerate(benford_freqs):
    ax.axvline(x=d_idx, color='white', alpha=0.1, linewidth=0.5)

plt.suptitle('Benford Universality Conjecture: Computational Evidence', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_universality_test.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality_test.png")
