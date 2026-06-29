#!/usr/bin/env python3
"""
Demo: Spectral Contraction Analysis of Collatz Dynamics

Demonstrates the key results:
1. The fundamental inequality log(3) < 2·log(2)
2. Parity word analysis for specific orbits
3. Segment-wise contraction verification
4. Spectral energy analysis
5. Batch verification of the density conjecture
"""
import math
from algorithms import (
    collatz_orbit, parity_word, ones_density, contraction_exponent,
    critical_density, ParityVector, segment_orbit, spectral_energy,
    verify_segment_conjecture, batch_verify_conjecture, spectral_profile
)


def demo_fundamental_inequality():
    """Demonstrate the fundamental inequality log(3) < 2·log(2)."""
    print("=" * 60)
    print("§1. THE FUNDAMENTAL INEQUALITY")
    print("=" * 60)

    log2 = math.log(2)
    log3 = math.log(3)
    rho_star = log2 / log3

    print(f"  log(2) = {log2:.10f}")
    print(f"  log(3) = {log3:.10f}")
    print(f"  2·log(2) = {2*log2:.10f}")
    print(f"  log(3) < 2·log(2)? {log3 < 2*log2}  (gap = {2*log2 - log3:.10f})")
    print(f"  ρ* = log(2)/log(3) = {rho_star:.10f}")
    print(f"  1/2 < ρ* < 1? {0.5 < rho_star < 1}")
    print()
    print("  Interpretation: Even if half of all Collatz steps are odd")
    print("  (ones-density = 0.5), the orbit still contracts, because")
    print("  0.5 < 0.6309 = ρ*.")
    print()


def demo_orbit_analysis():
    """Analyze specific Collatz orbits."""
    print("=" * 60)
    print("§2. ORBIT ANALYSIS")
    print("=" * 60)

    test_values = [7, 27, 97, 231, 871, 6171, 77031]
    rho_star = critical_density()

    for n in test_values:
        orbit = collatz_orbit(n)
        word = parity_word(n)
        k = len(word)
        j = sum(word)
        rho = ones_density(word)
        xi = contraction_exponent(j, k)

        print(f"\n  n = {n}:")
        print(f"    Orbit length: {len(orbit)} steps ({k} transitions)")
        print(f"    Odd steps (j): {j}, Even steps: {k - j}")
        print(f"    Density ρ = j/k = {rho:.6f}")
        print(f"    Critical ρ* = {rho_star:.6f}")
        print(f"    Gap: ρ* - ρ = {rho_star - rho:.6f}")
        print(f"    Contraction ξ = k·log(2) - j·log(3) = {xi:.4f}")
        print(f"    Net factor 2^k/3^j ≈ {2**k / 3**j:.2e}")
        print(f"    Contracts? {xi > 0}")

    print()


def demo_segment_analysis():
    """Demonstrate segment-wise contraction analysis."""
    print("=" * 60)
    print("§3. SEGMENT-WISE ANALYSIS")
    print("=" * 60)

    n = 27  # Famous orbit with 111 steps
    word = parity_word(n)
    segment_size = 20

    segments = segment_orbit(word, segment_size)
    rho_star = critical_density()

    print(f"\n  Orbit of n={n} (length {len(word)}), segments of size {segment_size}:")
    print(f"  {'Seg':>4} {'Len':>4} {'Ones':>5} {'Density':>8} {'ξ':>8} {'Status':>10}")
    print(f"  {'---':>4} {'---':>4} {'----':>5} {'-------':>8} {'---':>8} {'------':>10}")

    total_xi = 0
    for i, seg in enumerate(segments):
        status = "✓ OK" if seg.density < rho_star else "✗ HIGH"
        print(f"  {i+1:>4} {seg.length:>4} {seg.ones:>5} {seg.density:>8.4f} {seg.contraction:>8.4f} {status:>10}")
        total_xi += seg.contraction

    print(f"\n  Total contraction exponent (sum): {total_xi:.4f}")
    print(f"  Direct computation: {contraction_exponent(sum(word), len(word)):.4f}")
    print(f"  Additivity verified: {abs(total_xi - contraction_exponent(sum(word), len(word))) < 1e-10}")
    print()


def demo_composition():
    """Demonstrate the composition algebra of parity vectors."""
    print("=" * 60)
    print("§4. COMPOSITION ALGEBRA")
    print("=" * 60)

    v1 = ParityVector(10, 3)   # density 0.3
    v2 = ParityVector(10, 5)   # density 0.5
    v3 = ParityVector(10, 6)   # density 0.6

    print(f"\n  v1 = {v1}")
    print(f"  v2 = {v2}")
    print(f"  v3 = {v3}")

    c12 = v1.compose(v2)
    print(f"\n  v1 ++ v2 = {c12}")
    print(f"  ξ(v1) + ξ(v2) = {v1.contraction + v2.contraction:.4f}")
    print(f"  ξ(v1++v2) = {c12.contraction:.4f}")
    print(f"  Additivity: {abs(v1.contraction + v2.contraction - c12.contraction) < 1e-10}")

    c123 = c12.compose(v3)
    print(f"\n  v1 ++ v2 ++ v3 = {c123}")
    print(f"  Sum of ξ = {v1.contraction + v2.contraction + v3.contraction:.4f}")
    print(f"  Additivity: {abs(sum(v.contraction for v in [v1, v2, v3]) - c123.contraction) < 1e-10}")

    print(f"\n  Key insight: contraction is closed under composition of")
    print(f"  contracting segments (both v1 and v2 contract, so v1++v2 contracts).")
    print()


def demo_spectral_energy():
    """Demonstrate spectral energy analysis."""
    print("=" * 60)
    print("§5. SPECTRAL ENERGY ANALYSIS")
    print("=" * 60)

    n = 27
    word = parity_word(n)
    k = len(word)
    j = sum(word)

    dc_energy = spectral_energy(word, 0)
    rho_star = critical_density()
    threshold_sq = (rho_star * k) ** 2

    print(f"\n  Orbit of n={n}, length k={k}, odd steps j={j}")
    print(f"  DC energy |Ŵ(0)|² = j² = {j**2} (exact: {dc_energy:.2f})")
    print(f"  Threshold (ρ*·k)² = {threshold_sq:.2f}")
    print(f"  DC < threshold? {dc_energy < threshold_sq}")
    print(f"  Equivalent to: density {j/k:.4f} < ρ* = {rho_star:.4f}? {j/k < rho_star}")

    # Sample some non-DC frequencies
    print(f"\n  Spectral profile (selected frequencies):")
    print(f"  {'ω':>8} {'Energy':>12} {'Ratio to DC':>12}")
    for omega in [0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        e = spectral_energy(word, omega)
        ratio = e / dc_energy if dc_energy > 0 else 0
        print(f"  {omega:>8.2f} {e:>12.2f} {ratio:>12.4f}")
    print()


def demo_batch_verification():
    """Batch-verify the density conjecture."""
    print("=" * 60)
    print("§6. BATCH VERIFICATION OF DENSITY CONJECTURE")
    print("=" * 60)

    for seg_size in [20, 50, 100]:
        result = batch_verify_conjecture(n_max=5000, segment_size=seg_size)
        print(f"\n  Segment size = {seg_size}:")
        print(f"    Tested: n = 2 to {result['total'] + 1}")
        print(f"    Passed: {result['passed']}/{result['total']} ({result['pass_rate']*100:.1f}%)")
        print(f"    Max segment density: {result['max_density']:.6f}")
        print(f"    Critical threshold:  {result['critical_density']:.6f}")
        print(f"    Safety margin:       {result['margin']:.6f}")
        print(f"    Worst starting n:    {result['worst_n']}")

    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  SPECTRAL CONTRACTION THEORY FOR COLLATZ DYNAMICS       ║")
    print("║  Computational Demonstrations                           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_fundamental_inequality()
    demo_orbit_analysis()
    demo_segment_analysis()
    demo_composition()
    demo_spectral_energy()
    demo_batch_verification()

    print("Demo complete.")


#!/usr/bin/env python3
"""
Visualization: Segment-wise Contraction Exponent Along a Collatz Orbit

Shows how the contraction exponent accumulates along segments of a
Collatz orbit, demonstrating the additivity theorem.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1

def parity_word(n, max_steps=10000):
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return [x % 2 for x in orbit[:-1]]

def contraction_exponent(j, k):
    return k * math.log(2) - j * math.log(3)

def critical_density():
    return math.log(2) / math.log(3)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Cumulative Contraction Exponent Along Collatz Orbits',
             fontsize=16, fontweight='bold')

test_values = [27, 97, 871, 77031]

for ax, n in zip(axes.flat, test_values):
    word = parity_word(n)
    k_total = len(word)

    # Cumulative contraction exponent
    cumulative_xi = []
    j_cum = 0
    for i, w in enumerate(word):
        j_cum += w
        xi = contraction_exponent(j_cum, i + 1)
        cumulative_xi.append(xi)

    steps = list(range(1, k_total + 1))

    ax.plot(steps, cumulative_xi, 'b-', linewidth=1.0, alpha=0.8,
            label='Cumulative ξ(k)')
    ax.axhline(y=0, color='red', linestyle='--', linewidth=1.0,
               label='ξ = 0 (break-even)')
    ax.fill_between(steps, 0, cumulative_xi,
                     where=[x > 0 for x in cumulative_xi],
                     alpha=0.15, color='green', label='Contracting')
    ax.fill_between(steps, 0, cumulative_xi,
                     where=[x <= 0 for x in cumulative_xi],
                     alpha=0.15, color='red', label='Expanding')

    final_xi = cumulative_xi[-1] if cumulative_xi else 0
    rho = sum(word) / len(word) if word else 0
    ax.set_title(f'n = {n} (ρ={rho:.4f}, ξ_final={final_xi:.1f})', fontsize=12)
    ax.set_xlabel('Step k')
    ax.set_ylabel('Cumulative ξ(k)')
    ax.legend(fontsize=8, loc='upper left')

plt.tight_layout()
plt.savefig('contraction_accumulation.png', dpi=150, bbox_inches='tight')
print("Saved contraction_accumulation.png")


#!/usr/bin/env python3
"""
Visualization: Parity Density Distribution Across Collatz Orbits

Plots the distribution of ones-density values for Collatz orbits,
showing that all densities fall below the critical threshold.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1

def parity_word(n, max_steps=10000):
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return [x % 2 for x in orbit[:-1]]

def ones_density(word):
    return sum(word) / len(word) if word else 0.0

def critical_density():
    return math.log(2) / math.log(3)


# Compute densities for n = 2 to 10000
densities = []
lengths = []
for n in range(2, 10001):
    word = parity_word(n)
    if word:
        densities.append(ones_density(word))
        lengths.append(len(word))

rho_star = critical_density()

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Parity Density Analysis of Collatz Orbits (n = 2 to 10,000)',
             fontsize=14, fontweight='bold')

# Histogram of densities
ax1.hist(densities, bins=80, color='steelblue', alpha=0.8, edgecolor='white')
ax1.axvline(x=rho_star, color='red', linestyle='--', linewidth=2,
            label=f'ρ* = log(2)/log(3) ≈ {rho_star:.4f}')
ax1.axvline(x=0.5, color='green', linestyle=':', linewidth=1.5,
            label='ρ = 0.5 (half density)')
ax1.set_xlabel('Ones-density ρ = j/k', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title('Distribution of Orbit Densities', fontsize=13)
ax1.legend(fontsize=10)

# Scatter: density vs orbit length
ax2.scatter(lengths, densities, s=1, alpha=0.3, c='steelblue')
ax2.axhline(y=rho_star, color='red', linestyle='--', linewidth=2,
            label=f'ρ* ≈ {rho_star:.4f}')
ax2.axhline(y=0.5, color='green', linestyle=':', linewidth=1.5,
            label='ρ = 0.5')
ax2.set_xlabel('Orbit Length k', fontsize=12)
ax2.set_ylabel('Ones-density ρ', fontsize=12)
ax2.set_title('Density vs. Orbit Length', fontsize=13)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('density_distribution.png', dpi=150, bbox_inches='tight')
print("Saved density_distribution.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Energy Profile of Collatz Parity Words

Plots the spectral energy |Ŵ(ω)|² across frequencies for several
starting values, highlighting the DC component and critical threshold.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1

def parity_word(n, max_steps=10000):
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return [x % 2 for x in orbit[:-1]]

def spectral_energy(word, omega):
    cos_sum = sum(w * math.cos(2 * math.pi * omega * k) for k, w in enumerate(word))
    sin_sum = sum(w * math.sin(2 * math.pi * omega * k) for k, w in enumerate(word))
    return cos_sum ** 2 + sin_sum ** 2

def critical_density():
    return math.log(2) / math.log(3)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Spectral Energy Profiles of Collatz Parity Words', fontsize=16, fontweight='bold')

test_values = [27, 97, 871, 6171]
rho_star = critical_density()

for ax, n in zip(axes.flat, test_values):
    word = parity_word(n)
    k = len(word)
    j = sum(word)

    freqs = np.linspace(0, 0.5, 200)
    energies = [spectral_energy(word, f) for f in freqs]

    threshold = (rho_star * k) ** 2

    ax.plot(freqs, energies, 'b-', linewidth=0.8, alpha=0.8)
    ax.axhline(y=threshold, color='r', linestyle='--', linewidth=1.5,
               label=f'Threshold (ρ*·k)² = {threshold:.0f}')
    ax.plot(0, j**2, 'ro', markersize=8, label=f'DC = j² = {j**2}')

    ax.set_title(f'n = {n} (k={k}, j={j}, ρ={j/k:.4f})', fontsize=12)
    ax.set_xlabel('Frequency ω')
    ax.set_ylabel('Spectral Energy |Ŵ(ω)|²')
    ax.legend(fontsize=9)
    ax.set_xlim(0, 0.5)

plt.tight_layout()
plt.savefig('spectral_profiles.png', dpi=150, bbox_inches='tight')
print("Saved spectral_profiles.png")
