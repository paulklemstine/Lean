#!/usr/bin/env python3
"""
Demo: Spectral Contraction Analysis of Collatz Parity Words

Demonstrates the key results from the Lean formalization:
1. The fundamental inequality log(3) < 2*log(2)
2. Density-contraction biconditional
3. Spectral energy analysis
4. Tropical certificates
"""

import math

# Critical density threshold
CRITICAL_DENSITY = math.log(2) / math.log(3)
CRITICAL_SPECTRAL_ENERGY = CRITICAL_DENSITY ** 2


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, (3n+1)/2 if odd."""
    if n % 2 == 0:
        return n // 2
    else:
        return (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the Collatz orbit of n."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(orbit: list[int]) -> list[int]:
    """Extract the parity word from an orbit."""
    return [x % 2 for x in orbit[:-1]]  # Exclude the final 1


def contraction_exponent(k: int, s: int) -> float:
    """Compute the contraction exponent ξ(k, s) = k·log(2) - s·log(3)."""
    return k * math.log(2) - s * math.log(3)


def ones_density(word: list[int]) -> float:
    """Compute the ones-density of a binary word."""
    if len(word) == 0:
        return 0.0
    return sum(word) / len(word)


def dc_spectral_energy(word: list[int]) -> float:
    """Compute the DC spectral energy (squared ones-density)."""
    return ones_density(word) ** 2


def analyze_orbit(n: int) -> dict:
    """Full spectral contraction analysis of a Collatz orbit."""
    orbit = collatz_orbit(n)
    word = parity_word(orbit)
    k = len(word)
    s = sum(word)
    d = ones_density(word)
    xi = contraction_exponent(k, s)
    e_dc = dc_spectral_energy(word)

    return {
        "n": n,
        "orbit_length": len(orbit),
        "word_length": k,
        "ones_count": s,
        "ones_density": d,
        "critical_density": CRITICAL_DENSITY,
        "contraction_exponent": xi,
        "dc_spectral_energy": e_dc,
        "critical_spectral_energy": CRITICAL_SPECTRAL_ENERGY,
        "contracts": xi > 0,
        "multiplicative_factor": 3**s / 2**k if k < 1000 else math.exp(-xi),
        "drift_per_step": xi / k if k > 0 else 0,
    }


def tropical_certificate(k: int, s: int, precision: int = 6) -> dict | None:
    """Construct a tropical contraction certificate."""
    d = s / k
    # Round up to rational bound
    q = math.ceil(d * 10**precision) / 10**precision
    if q < CRITICAL_DENSITY:
        return {
            "word_length": k,
            "ones_count": s,
            "density": d,
            "rational_bound": q,
            "critical_density": CRITICAL_DENSITY,
            "certified": True,
        }
    return None


def main():
    print("=" * 70)
    print("SPECTRAL CONTRACTION ANALYSIS OF COLLATZ PARITY WORDS")
    print("=" * 70)

    # Demo 1: The fundamental inequality
    print("\n--- Fundamental Inequality ---")
    print(f"log(3) = {math.log(3):.6f}")
    print(f"2·log(2) = {2*math.log(2):.6f}")
    print(f"log(3) < 2·log(2): {math.log(3) < 2*math.log(2)}")
    print(f"Critical density ρ* = log(2)/log(3) = {CRITICAL_DENSITY:.6f}")
    print(f"ρ* > 1/2: {CRITICAL_DENSITY > 0.5}")
    print(f"ρ* < 1: {CRITICAL_DENSITY < 1}")

    # Demo 2: Analyze specific orbits
    print("\n--- Orbit Analysis ---")
    test_values = [7, 27, 97, 871, 6171, 77031, 837799]
    for n in test_values:
        result = analyze_orbit(n)
        status = "✓ CONTRACTS" if result["contracts"] else "✗ EXPANDS"
        print(f"n={n:>8}: k={result['word_length']:>4}, s={result['ones_count']:>4}, "
              f"d={result['ones_density']:.4f}, ξ={result['contraction_exponent']:>8.3f} {status}")

    # Demo 3: Half-density contraction
    print("\n--- Half-Density Contraction ---")
    for k in [10, 100, 1000]:
        xi = contraction_exponent(2 * k, k)
        print(f"k={k:>5}: ξ(2k, k) = {xi:.6f} > 0: {xi > 0}")

    # Demo 4: Spectral energy analysis
    print("\n--- DC Spectral Energy ---")
    print(f"Critical spectral energy = {CRITICAL_SPECTRAL_ENERGY:.6f}")
    for n in [27, 871, 6171]:
        result = analyze_orbit(n)
        below = result["dc_spectral_energy"] < CRITICAL_SPECTRAL_ENERGY
        print(f"n={n}: E_DC = {result['dc_spectral_energy']:.6f}, "
              f"E_DC < E* = {below}, contracts = {result['contracts']}")

    # Demo 5: Tropical certificates
    print("\n--- Tropical Certificates ---")
    for n in [27, 871, 6171, 837799]:
        result = analyze_orbit(n)
        cert = tropical_certificate(result["word_length"], result["ones_count"])
        if cert:
            print(f"n={n}: Certificate issued. d={cert['density']:.6f} ≤ q={cert['rational_bound']:.6f} < ρ*={cert['critical_density']:.6f}")
        else:
            print(f"n={n}: Certificate FAILED (density too high)")

    # Demo 6: Additivity of contraction exponent
    print("\n--- Contraction Additivity ---")
    k1, s1, k2, s2 = 100, 40, 100, 45
    xi1 = contraction_exponent(k1, s1)
    xi2 = contraction_exponent(k2, s2)
    xi_sum = contraction_exponent(k1 + k2, s1 + s2)
    print(f"ξ({k1},{s1}) = {xi1:.4f}")
    print(f"ξ({k2},{s2}) = {xi2:.4f}")
    print(f"ξ({k1}+{k2},{s1}+{s2}) = {xi_sum:.4f}")
    print(f"Sum = {xi1+xi2:.4f}")
    print(f"Additive: {abs(xi_sum - (xi1+xi2)) < 1e-10}")

    # Demo 7: Drift per step
    print("\n--- Drift Analysis ---")
    print(f"Positive drift at half density: log(2) - (1/2)·log(3) = {math.log(2) - 0.5*math.log(3):.6f}")
    print(f"Stopping bound constant C = {1/(math.log(2) - 0.5*math.log(3)):.4f}")
    for n in [27, 871, 6171, 837799]:
        result = analyze_orbit(n)
        predicted = 1 / (math.log(2) - 0.5 * math.log(3)) * math.log(n)
        actual = result["word_length"]
        print(f"n={n}: predicted ≤ {predicted:.1f}, actual = {actual}, "
              f"ratio = {actual/predicted:.3f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Full DFT Spectrum of Collatz Parity Words"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def full_dft(word: list[int]) -> list[float]:
    """Compute |ŵ(ω)|² for all frequencies."""
    k = len(word)
    w = np.array(word, dtype=float)
    energies = []
    for omega in range(k):
        basis = np.exp(-2j * np.pi * omega * np.arange(k) / k) / k
        coeff = np.abs(np.dot(w, basis))**2
        energies.append(float(coeff))
    return energies


CRITICAL_DENSITY = math.log(2) / math.log(3)
CRITICAL_ENERGY = CRITICAL_DENSITY ** 2

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

test_cases = [(27, 'steelblue'), (871, 'darkorange'), (6171, 'forestgreen'), (837799, 'purple')]

for idx, (n, color) in enumerate(test_cases):
    ax = axes[idx // 2, idx % 2]
    orbit = collatz_orbit(n)
    word = [x % 2 for x in orbit[:-1]]
    k = len(word)

    # Use numpy FFT for efficiency
    w = np.array(word, dtype=float)
    fft = np.fft.fft(w) / k
    energies = np.abs(fft)**2

    ax.semilogy(range(k), energies, '.', color=color, markersize=2, alpha=0.5)
    ax.axhline(y=CRITICAL_ENERGY, color='red', linestyle='--', linewidth=1, label=f'E* = {CRITICAL_ENERGY:.4f}')
    ax.axhline(y=energies[0], color='black', linestyle='-', linewidth=1, label=f'E_DC = {energies[0]:.4f}')

    # Highlight DC component
    ax.plot(0, energies[0], 'o', color='red', markersize=8, zorder=5)

    d = sum(word) / k
    ax.set_xlabel('Frequency ω')
    ax.set_ylabel('|ŵ(ω)|² (log scale)')
    ax.set_title(f'n={n} (k={k}, d={d:.4f})')
    ax.legend(fontsize=8)

plt.suptitle('Full DFT Spectrum of Collatz Parity Words\nDC component (red dot) determines contraction',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('dft_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: dft_spectrum.png")


#!/usr/bin/env python3
"""Visualization: Random Walk Interpretation of Collatz Contraction"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


LOG2 = math.log(2)
LOG3 = math.log(3)
EVEN_STEP = LOG2           # +log(2) ≈ +0.693
ODD_STEP = -(LOG3 - LOG2)  # -(log(3)-log(2)) ≈ -0.405

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Random walk for n=27
ax = axes[0, 0]
orbit = collatz_orbit(27)
walk = [0.0]
for x in orbit[:-1]:
    step = ODD_STEP if x % 2 == 1 else EVEN_STEP
    walk.append(walk[-1] + step)
ax.plot(walk, color='steelblue', linewidth=1)
ax.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax.fill_between(range(len(walk)), walk, alpha=0.2, color='steelblue')
ax.set_xlabel('Step')
ax.set_ylabel('Cumulative contraction')
ax.set_title(f'Random Walk for n=27 (k={len(orbit)-1})')

# Plot 2: Random walk for n=871
ax = axes[0, 1]
orbit = collatz_orbit(871)
walk = [0.0]
for x in orbit[:-1]:
    step = ODD_STEP if x % 2 == 1 else EVEN_STEP
    walk.append(walk[-1] + step)
ax.plot(walk, color='darkorange', linewidth=1)
ax.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax.fill_between(range(len(walk)), walk, alpha=0.2, color='darkorange')
ax.set_xlabel('Step')
ax.set_ylabel('Cumulative contraction')
ax.set_title(f'Random Walk for n=871 (k={len(orbit)-1})')

# Plot 3: Step size comparison
ax = axes[1, 0]
steps = ['+log(2)\n(even step)', '−(log(3)−log(2))\n(odd step)']
values = [EVEN_STEP, -ODD_STEP]
colors = ['forestgreen', 'crimson']
bars = ax.bar(steps, values, color=colors, alpha=0.8, edgecolor='black')
ax.set_ylabel('Magnitude')
ax.set_title('Step Contributions (|even| > |odd|)')
for bar, val in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.01,
            f'{val:.4f}', ha='center', va='bottom', fontweight='bold')

# Plot 4: Drift per step vs density
ax = axes[1, 1]
densities = np.linspace(0, 1, 200)
drifts = LOG2 - densities * LOG3
ax.plot(densities, drifts, color='steelblue', linewidth=2)
ax.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax.axvline(x=math.log(2)/math.log(3), color='red', linestyle='--', linewidth=1, label=f'ρ* = {math.log(2)/math.log(3):.4f}')
ax.axvline(x=0.5, color='green', linestyle=':', linewidth=1, label='d = 0.5')
ax.fill_between(densities, drifts, where=drifts > 0, alpha=0.2, color='forestgreen', label='Contraction')
ax.fill_between(densities, drifts, where=drifts < 0, alpha=0.2, color='crimson', label='Expansion')
ax.set_xlabel('Ones-density d')
ax.set_ylabel('Drift per step')
ax.set_title('Drift = log(2) − d·log(3)')
ax.legend()

plt.suptitle('Random Walk Interpretation of Collatz Contraction', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('random_walk_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: random_walk_analysis.png")


#!/usr/bin/env python3
"""Visualization: DC Spectral Energy vs Critical Threshold for Collatz Orbits"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(orbit: list[int]) -> list[int]:
    return [x % 2 for x in orbit[:-1]]


def ones_density_val(word: list[int]) -> float:
    return sum(word) / len(word) if word else 0.0


CRITICAL_DENSITY = math.log(2) / math.log(3)
CRITICAL_ENERGY = CRITICAL_DENSITY ** 2

# Analyze many starting values
ns = list(range(3, 10001, 2))  # Odd numbers 3 to 9999
densities = []
energies = []
lengths = []

for n in ns:
    orbit = collatz_orbit(n)
    word = parity_word(orbit)
    d = ones_density_val(word)
    densities.append(d)
    energies.append(d**2)
    lengths.append(len(word))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Ones density vs starting value
ax = axes[0, 0]
ax.scatter(ns, densities, s=1, alpha=0.5, c='steelblue')
ax.axhline(y=CRITICAL_DENSITY, color='red', linestyle='--', linewidth=2, label=f'ρ* = {CRITICAL_DENSITY:.4f}')
ax.axhline(y=0.5, color='green', linestyle=':', linewidth=1, label='d = 0.5')
ax.set_xlabel('Starting value n')
ax.set_ylabel('Ones-density d(k,s)')
ax.set_title('Parity Word Ones-Density')
ax.legend()
ax.set_ylim(0.3, 0.7)

# Plot 2: DC spectral energy
ax = axes[0, 1]
ax.scatter(ns, energies, s=1, alpha=0.5, c='darkorange')
ax.axhline(y=CRITICAL_ENERGY, color='red', linestyle='--', linewidth=2, label=f'E* = {CRITICAL_ENERGY:.4f}')
ax.set_xlabel('Starting value n')
ax.set_ylabel('DC Spectral Energy')
ax.set_title('DC Spectral Energy E_DC = d²')
ax.legend()

# Plot 3: Density histogram
ax = axes[1, 0]
ax.hist(densities, bins=100, color='steelblue', alpha=0.7, edgecolor='navy')
ax.axvline(x=CRITICAL_DENSITY, color='red', linestyle='--', linewidth=2, label=f'ρ* = {CRITICAL_DENSITY:.4f}')
ax.axvline(x=0.5, color='green', linestyle=':', linewidth=1, label='d = 0.5')
ax.set_xlabel('Ones-density')
ax.set_ylabel('Count')
ax.set_title('Distribution of Ones-Densities')
ax.legend()

# Plot 4: Contraction exponent vs orbit length
contraction_exps = [l * math.log(2) - s * math.log(3)
                    for l, s, d in zip(lengths, [int(d * l) for d, l in zip(densities, lengths)], densities)]
# Recompute properly
contraction_exps = []
for n in ns:
    orbit = collatz_orbit(n)
    word = parity_word(orbit)
    k = len(word)
    s = sum(word)
    contraction_exps.append(k * math.log(2) - s * math.log(3))

ax = axes[1, 1]
ax.scatter(lengths, contraction_exps, s=1, alpha=0.5, c='forestgreen')
ax.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax.set_xlabel('Orbit length k')
ax.set_ylabel('Contraction exponent ξ(k,s)')
ax.set_title('Contraction Exponent vs Orbit Length')

plt.suptitle('Spectral Contraction Analysis of Collatz Orbits (n = 3 to 9999, odd)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('spectral_energy_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_energy_analysis.png")
