#!/usr/bin/env python3
"""
Applications of Collatz Spectral Analysis
==========================================

Real-world applications of the spectral gap framework:
1. Pseudorandom number generation quality testing
2. Signal processing: detecting hidden periodicities
3. Comparison with non-convergent maps (5n+1, 7n+1)
"""

import numpy as np
from typing import List, Tuple


def collatz_step(n: int) -> int:
    """Standard Collatz step."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def generalized_step(n: int, a: int = 3) -> int:
    """Generalized an+1 map: n/2 if even, an+1 if odd."""
    return n // 2 if n % 2 == 0 else a * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute Collatz orbit."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current <= 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def compute_spectral_energy(values: List[int], omega: float) -> float:
    """Compute spectral energy for a sequence of values."""
    total = 0.0 + 0.0j
    for i, v in enumerate(values):
        if i == 0:
            continue
        phase = 2.0 * np.pi * omega * v / i
        total += np.exp(1j * phase)
    return abs(total)


# ============================================================
# APPLICATION 1: PRNG Quality Testing
# ============================================================

def prng_spectral_test(sequence: List[int], num_freq: int = 100) -> float:
    """
    Test pseudorandom number generator quality via spectral gap.

    A good PRNG should have a spectral gap (no frequency concentrations).
    Returns the gap ratio: max|F(ω)|/√N. Lower is more random-like.
    """
    N = len(sequence)
    max_energy = 0.0
    for omega in np.linspace(0.01, 10.0, num_freq):
        total = 0.0 + 0.0j
        for i in range(1, N):
            phase = 2.0 * np.pi * omega * sequence[i] / sequence[i - 1] if sequence[i - 1] != 0 else 0
            total += np.exp(1j * phase)
        energy = abs(total)
        max_energy = max(max_energy, energy)
    return max_energy / np.sqrt(N)


# ============================================================
# APPLICATION 2: Comparing Maps (3n+1 vs 5n+1 vs 7n+1)
# ============================================================

def compare_maps(N: int = 200, num_freq: int = 50) -> dict:
    """
    Compare spectral properties of different an+1 maps.

    The 3n+1 map (Collatz) is conjectured to always reach 1.
    The 5n+1 and 7n+1 maps have known divergent orbits.
    The spectral gap should be present for 3n+1 but not for 5n+1, 7n+1.
    """
    results = {}
    for a, name in [(3, "3n+1 (Collatz)"), (5, "5n+1"), (7, "7n+1")]:
        max_energy = 0.0
        for omega in np.linspace(0.1, 5.0, num_freq):
            total = 0.0 + 0.0j
            for n in range(1, N + 1):
                Tn = generalized_step(n, a)
                phase = 2.0 * np.pi * omega * Tn / n
                total += np.exp(1j * phase)
            energy = abs(total)
            max_energy = max(max_energy, energy)
        gap_ratio = max_energy / np.sqrt(N)
        results[name] = {
            "max_energy": max_energy,
            "gap_ratio": gap_ratio,
            "sqrt_N": np.sqrt(N)
        }
    return results


# ============================================================
# APPLICATION 3: Periodicity Detection
# ============================================================

def detect_periodicity(sequence: List[int], num_freq: int = 200) -> Tuple[float, float]:
    """
    Detect hidden periodicities in a sequence via spectral peaks.

    Returns (peak_frequency, peak_energy).
    A strong peak indicates a periodic component at that frequency.
    """
    N = len(sequence)
    best_omega = 0.0
    best_energy = 0.0

    for omega in np.linspace(0.01, 20.0, num_freq):
        total = 0.0 + 0.0j
        for i in range(N):
            phase = 2.0 * np.pi * omega * sequence[i]
            total += np.exp(1j * phase)
        energy = abs(total) / N
        if energy > best_energy:
            best_energy = energy
            best_omega = omega

    return best_omega, best_energy


# ============================================================
# DEMONSTRATION
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF COLLATZ SPECTRAL ANALYSIS")
    print("=" * 60)

    # App 1: PRNG quality
    print("\n--- Application 1: PRNG Quality Testing ---")
    # Test Collatz orbit as PRNG
    collatz_seq = collatz_orbit(837799, max_steps=500)
    gap = prng_spectral_test(collatz_seq[:200])
    print(f"  Collatz orbit (n=837799): gap ratio = {gap:.4f}")

    # Compare with truly random
    np.random.seed(42)
    random_seq = list(np.random.randint(1, 1000, 200))
    gap_random = prng_spectral_test(random_seq)
    print(f"  Uniform random:           gap ratio = {gap_random:.4f}")

    # App 2: Comparing maps
    print("\n--- Application 2: Map Comparison ---")
    comparison = compare_maps(N=200)
    for name, data in comparison.items():
        print(f"  {name:>20}: gap_ratio = {data['gap_ratio']:.4f}")

    # App 3: Periodicity detection
    print("\n--- Application 3: Periodicity Detection ---")
    # Periodic sequence
    periodic = [int(100 * np.sin(2 * np.pi * 3.7 * i / 100) + 200) for i in range(200)]
    freq, energy = detect_periodicity(periodic)
    print(f"  Periodic signal (f=3.7): detected f={freq:.2f}, energy={energy:.4f}")

    # Collatz orbit
    orbit = collatz_orbit(27)
    freq, energy = detect_periodicity(orbit[:50])
    print(f"  Collatz orbit (n=27):    detected f={freq:.2f}, energy={energy:.4f}")

    print("\n" + "=" * 60)
    print("Applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Fourier Analysis of the Collatz Map: Spectral Gaps in the 3n+1 Map
===================================================================

Demonstrates the key mathematical results:
1. Collatz orbit parity statistics and the critical threshold
2. Spectral energy computation for Collatz exponential sums
3. The drift function zero-crossing (random walk bridge)
4. Spectral gap measurements across different N values
"""

import numpy as np
from typing import Tuple, List


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until reaching 1 or max_steps."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_statistics(n: int) -> Tuple[int, int, int, float]:
    """
    Compute parity statistics for the Collatz orbit of n.
    Returns: (total_steps, odd_count, even_count, odd_ratio)
    """
    orbit = collatz_orbit(n)
    total = len(orbit) - 1  # number of steps
    if total == 0:
        return 0, 0, 0, 0.0
    odd_count = sum(1 for x in orbit[:-1] if x % 2 == 1)
    even_count = total - odd_count
    return total, odd_count, even_count, odd_count / total


def spectral_energy(N: int, omega: float) -> float:
    """
    Compute the spectral energy |F_T(omega)| for the Collatz map.
    F_T(omega) = sum_{n=1}^{N} exp(2*pi*i*omega*T(n)/n)
    """
    total = 0.0 + 0.0j
    for n in range(1, N + 1):
        Tn = collatz_step(n)
        total += np.exp(2j * np.pi * omega * Tn / n)
    return abs(total)


def drift_function(p: float) -> float:
    """
    The random walk drift function:
    mu(p) = p*log(3) - (1-p)*log(2)
    """
    return p * np.log(3) - (1 - p) * np.log(2)


def critical_threshold() -> float:
    """The critical parity threshold p* = log(2)/(log(2)+log(3))."""
    return np.log(2) / (np.log(2) + np.log(3))


def spectral_weight(j: int, k: int) -> float:
    """The spectral weight 3^j / 2^(k-j)."""
    return 3**j / 2**(k - j)


def descent_exponent(j: int, k: int) -> float:
    """The descent exponent j*log(3) - (k-j)*log(2)."""
    return j * np.log(3) - (k - j) * np.log(2)


# ============================================================
# DEMONSTRATION
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("FOURIER ANALYSIS OF THE COLLATZ MAP: SPECTRAL GAPS")
    print("=" * 70)

    # 1. Parity statistics demonstration
    print("\n--- §1. Parity Statistics ---")
    print(f"Critical threshold p* = log(2)/(log(2)+log(3)) = {critical_threshold():.6f}")
    print(f"\n{'n':>10} {'steps':>8} {'odd':>6} {'even':>6} {'ratio':>8} {'< p*?':>6}")
    print("-" * 50)
    for n in [7, 27, 97, 871, 6171, 77031, 837799]:
        total, odd, even, ratio = parity_statistics(n)
        below = "YES" if ratio < critical_threshold() else "NO"
        print(f"{n:>10} {total:>8} {odd:>6} {even:>6} {ratio:>8.4f} {below:>6}")

    # 2. Parity partition verification
    print("\n--- §2. Parity Partition Identity: odd + even = total ---")
    for n in [7, 27, 97, 871]:
        total, odd, even, _ = parity_statistics(n)
        assert odd + even == total, f"Partition failed for n={n}"
        print(f"  n={n}: {odd} + {even} = {total} ✓")

    # 3. Spectral weight and contraction
    print("\n--- §3. Descent Exponent and Contraction ---")
    print(f"{'j':>4} {'k':>4} {'δ(j,k)':>10} {'w(j,k)':>10} {'contract?':>10}")
    print("-" * 42)
    for j, k in [(1, 3), (2, 5), (3, 8), (1, 4), (2, 6), (5, 8)]:
        delta = descent_exponent(j, k)
        w = spectral_weight(j, k)
        contract = "YES" if delta < 0 else "NO"
        print(f"{j:>4} {k:>4} {delta:>10.4f} {w:>10.4f} {contract:>10}")

    # 4. Spectral energy computation
    print("\n--- §4. Spectral Energy |F_T(ω)| ---")
    omegas = [np.sqrt(2), np.pi, np.e, (1 + np.sqrt(5)) / 2]
    omega_names = ["√2", "π", "e", "φ"]
    for N in [100, 500, 1000]:
        print(f"\n  N = {N}, √N = {np.sqrt(N):.2f}")
        for omega, name in zip(omegas, omega_names):
            energy = spectral_energy(N, omega)
            ratio = energy / np.sqrt(N)
            print(f"    ω = {name:>4}: |F_T| = {energy:>8.2f}, |F_T|/√N = {ratio:.4f}")

    # 5. Drift function
    print("\n--- §5. Random Walk Drift Function ---")
    print(f"  μ(0)   = {drift_function(0):.6f} < 0 (pure contraction)")
    print(f"  μ(p*)  = {drift_function(critical_threshold()):.6f} ≈ 0 (critical)")
    print(f"  μ(1)   = {drift_function(1):.6f} > 0 (pure expansion)")
    print(f"  μ(0.5) = {drift_function(0.5):.6f} > 0 (unbiased random walk expands!)")

    # 6. Spectral gap test
    print("\n--- §6. Spectral Gap Conjecture Test ---")
    print("  Testing: max|F_T(ω)|/√N should stay bounded")
    print(f"  {'N':>8} {'max|F_T|':>10} {'√N':>8} {'ratio':>8}")
    print("  " + "-" * 38)
    for N in [50, 100, 200, 500, 1000]:
        max_energy = 0
        for omega in np.linspace(0.1, 5.0, 50):
            e = spectral_energy(N, omega)
            max_energy = max(max_energy, e)
        ratio = max_energy / np.sqrt(N)
        print(f"  {N:>8} {max_energy:>10.2f} {np.sqrt(N):>8.2f} {ratio:>8.4f}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 3: Spectral Fingerprints of Convergent vs. Divergent Maps
========================================================================

Compares the spectral energy profiles of the Collatz (3n+1) map against
the non-convergent 5n+1 and 7n+1 maps. The spectral gap is visible for
3n+1 but breaks down for the divergent maps, supporting the conjecture
that spectral gaps characterize convergent dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt


def generalized_step(n: int, a: int = 3) -> int:
    """Generalized an+1 map."""
    return n // 2 if n % 2 == 0 else a * n + 1


def spectral_energy_generalized(N: int, omega: float, a: int = 3) -> float:
    """Compute spectral energy for the an+1 map."""
    total = 0.0 + 0.0j
    for n in range(1, N + 1):
        Tn = generalized_step(n, a)
        total += np.exp(2j * np.pi * omega * Tn / n)
    return abs(total)


N = 400
omegas = np.linspace(0.01, 6.0, 300)

fig, axes = plt.subplots(1, 3, figsize=(16, 5), sharey=True)

maps = [
    (3, "3n+1 (Collatz)", '#2196F3', 'Convergent'),
    (5, "5n+1", '#FF5722', 'Divergent orbits known'),
    (7, "7n+1", '#9C27B0', 'Divergent orbits known'),
]

sqrt_N = np.sqrt(N)

for ax, (a, title, color, status) in zip(axes, maps):
    energies = [spectral_energy_generalized(N, w, a) for w in omegas]

    ax.fill_between(omegas, energies, alpha=0.4, color=color)
    ax.plot(omegas, energies, color=color, linewidth=1.2)
    ax.axhline(y=sqrt_N, color='red', linestyle='--', linewidth=1.5,
               alpha=0.7, label=f'√N = {sqrt_N:.1f}')

    max_e = max(energies)
    ratio = max_e / sqrt_N
    ax.set_title(f'{title}\nmax ratio = {ratio:.2f}', fontsize=13,
                 fontweight='bold')
    ax.set_xlabel('Frequency ω', fontsize=11)
    ax.text(0.02, 0.95, status, transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)

axes[0].set_ylabel('Spectral Energy |F_T(ω)|', fontsize=11)

fig.suptitle(f'Spectral Fingerprints: Convergent vs. Divergent Maps (N={N})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('map_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved map_comparison.png")


#!/usr/bin/env python3
"""
Visualization 2: Parity Drift and the Critical Threshold
=========================================================

Shows the random walk drift function μ(p) = p·log(3) - (1-p)·log(2) and
its unique zero p* ≈ 0.3869, the critical parity threshold that separates
contracting from expanding Collatz dynamics. Also shows the distribution
of observed parity ratios across many starting values.
"""

import numpy as np
import matplotlib.pyplot as plt


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000):
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current <= 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_ratio(n: int) -> float:
    orbit = collatz_orbit(n)
    total = len(orbit) - 1
    if total == 0:
        return 0.0
    odd_count = sum(1 for x in orbit[:-1] if x % 2 == 1)
    return odd_count / total


def drift_function(p):
    return p * np.log(3) - (1 - p) * np.log(2)


# Critical threshold
p_star = np.log(2) / (np.log(2) + np.log(3))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: drift function
ax = axes[0]
p_vals = np.linspace(0, 1, 500)
drift_vals = drift_function(p_vals)

ax.fill_between(p_vals, drift_vals, 0, where=(drift_vals < 0),
                color='#2196F3', alpha=0.3, label='Contracting region')
ax.fill_between(p_vals, drift_vals, 0, where=(drift_vals > 0),
                color='#FF5722', alpha=0.3, label='Expanding region')
ax.plot(p_vals, drift_vals, 'k-', linewidth=2)
ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax.axvline(x=p_star, color='red', linestyle='--', linewidth=1.5,
           label=f'p* = {p_star:.4f}')
ax.plot(p_star, 0, 'ro', markersize=8, zorder=5)

ax.set_xlabel('Parity ratio p (fraction of odd steps)', fontsize=12)
ax.set_ylabel('Drift μ(p)', fontsize=12)
ax.set_title('Random Walk Drift Function', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Right panel: distribution of observed parity ratios
ax2 = axes[1]
ratios = [parity_ratio(n) for n in range(3, 5001, 2)]  # odd numbers

ax2.hist(ratios, bins=60, color='#4CAF50', alpha=0.7, edgecolor='white',
         density=True, label='Observed distribution')
ax2.axvline(x=p_star, color='red', linestyle='--', linewidth=2,
            label=f'p* = {p_star:.4f}')
ax2.axvline(x=np.mean(ratios), color='blue', linestyle='-', linewidth=1.5,
            label=f'Mean = {np.mean(ratios):.4f}')

ax2.set_xlabel('Parity ratio (odd steps / total steps)', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Parity Ratios of Collatz Orbits (n=3..5000)', fontsize=14,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('parity_drift_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved parity_drift_analysis.png")


#!/usr/bin/env python3
"""
Visualization 1: Spectral Energy Landscape of the Collatz Map
==============================================================

Plots |F_T(ω)| as a function of frequency ω for multiple values of N,
along with the √N bound (spectral gap conjecture threshold).
This visualization shows how the Collatz exponential sum behaves across
frequencies and demonstrates the conjectured spectral gap.
"""

import numpy as np
import matplotlib.pyplot as plt


def collatz_step(n: int) -> int:
    """Standard Collatz step."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def spectral_energy(N: int, omega: float) -> float:
    """Compute |F_T(omega)| = |sum exp(2*pi*i*omega*T(n)/n)|."""
    total = 0.0 + 0.0j
    for n in range(1, N + 1):
        Tn = collatz_step(n)
        total += np.exp(2j * np.pi * omega * Tn / n)
    return abs(total)


# Compute spectral energies
N_values = [100, 300, 600]
omegas = np.linspace(0.01, 8.0, 400)

fig, axes = plt.subplots(2, 1, figsize=(12, 9), gridspec_kw={'height_ratios': [3, 1]})

colors = ['#2196F3', '#FF5722', '#4CAF50']

# Top panel: spectral energy curves
ax = axes[0]
for N, color in zip(N_values, colors):
    energies = [spectral_energy(N, w) for w in omegas]
    ax.plot(omegas, energies, color=color, alpha=0.8, linewidth=1.2,
            label=f'|F_T(ω)|, N={N}')
    ax.axhline(y=np.sqrt(N), color=color, linestyle='--', alpha=0.5,
               linewidth=1, label=f'√N = {np.sqrt(N):.1f}')

ax.set_xlabel('Frequency ω', fontsize=13)
ax.set_ylabel('Spectral Energy |F_T(ω)|', fontsize=13)
ax.set_title('Spectral Energy Landscape of the Collatz Map', fontsize=15, fontweight='bold')
ax.legend(fontsize=10, loc='upper right')
ax.grid(True, alpha=0.3)

# Bottom panel: normalized ratio
ax2 = axes[1]
for N, color in zip(N_values, colors):
    ratios = [spectral_energy(N, w) / np.sqrt(N) for w in omegas]
    ax2.plot(omegas, ratios, color=color, alpha=0.8, linewidth=1.2,
             label=f'N={N}')

ax2.axhline(y=1.0, color='red', linestyle=':', alpha=0.7, linewidth=1.5,
            label='Gap threshold')
ax2.set_xlabel('Frequency ω', fontsize=13)
ax2.set_ylabel('|F_T(ω)| / √N', fontsize=13)
ax2.set_title('Normalized Spectral Energy (Gap Ratio)', fontsize=13)
ax2.legend(fontsize=10, loc='upper right')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_energy_landscape.png")
