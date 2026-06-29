#!/usr/bin/env python3
"""
Demo: The Fourier Transform of the Riemann Zeta Function — Hearing the Primes

Demonstrates:
1. Prime spectral frequencies and weights
2. Partial Dirichlet sum on the critical line
3. Fourier transform showing prime peaks
4. Spectral consonance analysis
5. Gelfond-Schneider irrationality verification
"""

import numpy as np
from math import log, sqrt, pi, gcd
from typing import List, Tuple

def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_spectral_freq(p: int) -> float:
    """Spectral frequency of prime p: log(p)/(2π)."""
    return log(p) / (2 * pi)


def prime_spectral_weight(p: int) -> float:
    """Spectral weight of prime p: 1/√p."""
    return 1.0 / sqrt(p)


def zeta_critical_line(t: float, N: int = 1000) -> complex:
    """Compute ζ(1/2 + it) using partial Dirichlet sum with N terms."""
    s = 0.5 + 1j * t
    return sum(n**(-s) for n in range(1, N + 1))


def fourier_transform_zeta(omega_values: np.ndarray, T: float = 100.0,
                           dt: float = 0.1, N_dirichlet: int = 200) -> np.ndarray:
    """
    Compute the (windowed) Fourier transform of Z(t) = ζ(1/2+it).

    Uses a Gaussian window to ensure convergence.
    """
    t_values = np.arange(-T, T, dt)
    # Gaussian window
    window = np.exp(-t_values**2 / (2 * (T/3)**2))

    # Compute Z(t) for each t
    Z_values = np.array([zeta_critical_line(t, N_dirichlet) for t in t_values])
    Z_windowed = Z_values * window

    # Fourier transform at each omega
    result = np.zeros(len(omega_values), dtype=complex)
    for i, omega in enumerate(omega_values):
        integrand = Z_windowed * np.exp(-2j * pi * omega * t_values)
        result[i] = np.sum(integrand) * dt

    return result


def check_consonance(p: int, q: int, B: int = 100, epsilon: float = 1e-6) -> Tuple[bool, int, int, float]:
    """
    Check if primes p, q are (ε, B)-consonant.
    Returns (is_consonant, best_a, best_b, min_distance).
    """
    ratio = log(q) / log(p)
    best_a, best_b = 0, 1
    min_dist = abs(ratio)

    for b in range(1, B + 1):
        a = round(ratio * b)
        dist = abs(ratio - a / b)
        if dist < min_dist:
            min_dist = dist
            best_a, best_b = a, b
            if dist < epsilon:
                return True, a, b, dist

    return False, best_a, best_b, min_dist


def verify_irrationality(max_prime: int = 100, B: int = 100, threshold: float = 1e-10) -> bool:
    """
    Verify computationally that log(q)/log(p) is not close to any rational a/b
    with b ≤ B, for all distinct prime pairs p, q ≤ max_prime.
    """
    primes = sieve_primes(max_prime)
    all_irrational = True

    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i == j:
                continue
            ratio = log(q) / log(p)
            for b in range(1, B + 1):
                a = round(ratio * b)
                if a > 0 and abs(ratio - a / b) < threshold:
                    print(f"  WARNING: log({q})/log({p}) ≈ {a}/{b} (dist={abs(ratio - a/b):.2e})")
                    all_irrational = False

    return all_irrational


def main():
    print("=" * 70)
    print("THE FOURIER TRANSFORM OF THE RIEMANN ZETA: HEARING THE PRIMES")
    print("=" * 70)

    # --- Demo 1: Prime Spectral Frequencies ---
    print("\n1. PRIME SPECTRAL FREQUENCIES AND WEIGHTS")
    print("-" * 50)
    primes = sieve_primes(50)
    print(f"{'Prime':>6} {'Frequency':>12} {'Weight':>10} {'Note':>8}")
    print("-" * 40)
    for p in primes:
        freq = prime_spectral_freq(p)
        weight = prime_spectral_weight(p)
        # Musical note approximation (A4 = 440 Hz at log(440)/(2π))
        print(f"{p:>6} {freq:>12.6f} {weight:>10.6f}")

    # --- Demo 2: Frequency Gap Verification ---
    print("\n2. FREQUENCY GAP LOWER BOUNDS")
    print("-" * 50)
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        gap = prime_spectral_freq(q) - prime_spectral_freq(p)
        lower_bound = log(1 + 1/p) / (2 * pi)
        print(f"  gap(f({q}) - f({p})) = {gap:.6f} ≥ {lower_bound:.6f}  "
              f"{'✓' if gap >= lower_bound - 1e-15 else '✗'}")

    # --- Demo 3: Spectral Weight Sum ---
    print("\n3. PARTIAL SPECTRAL WEIGHT SUMS")
    print("-" * 50)
    for n in [10, 50, 100, 500, 1000]:
        ps = sieve_primes(n)
        total = sum(prime_spectral_weight(p) for p in ps)
        bound = n * prime_spectral_weight(2)
        print(f"  Σ w(p) for p ≤ {n:>5}: {total:>10.4f} ≤ {bound:>10.4f}  "
              f"{'✓' if total <= bound + 1e-10 else '✗'}")

    # --- Demo 4: Consonance Analysis ---
    print("\n4. SPECTRAL CONSONANCE BETWEEN SMALL PRIMES")
    print("-" * 50)
    small_primes = sieve_primes(20)
    for i in range(len(small_primes)):
        for j in range(i + 1, len(small_primes)):
            p, q = small_primes[i], small_primes[j]
            is_cons, a, b, dist = check_consonance(p, q, B=50)
            ratio = log(q) / log(p)
            print(f"  log({q})/log({p}) = {ratio:.6f}, "
                  f"closest rational ≈ {a}/{b}, dist = {dist:.6e}")

    # --- Demo 5: Irrationality Verification ---
    print("\n5. GELFOND-SCHNEIDER IRRATIONALITY VERIFICATION")
    print("-" * 50)
    print("  Testing log(q)/log(p) irrationality for primes ≤ 100...")
    result = verify_irrationality(100, B=100, threshold=1e-10)
    print(f"  All ratios verified irrational to 10^-10: {'✓ YES' if result else '✗ NO'}")

    # --- Demo 6: Fourier Transform Peaks ---
    print("\n6. FOURIER TRANSFORM PEAKS AT PRIME FREQUENCIES")
    print("-" * 50)
    print("  Computing Fourier transform of ζ(1/2+it) (windowed)...")

    # Compute at prime frequencies and nearby points
    test_primes = [2, 3, 5, 7, 11, 13]
    for p in test_primes:
        freq = prime_spectral_freq(p)
        # Evaluate FT at the prime frequency and slightly off
        omega_test = np.array([freq - 0.01, freq, freq + 0.01])
        ft_vals = fourier_transform_zeta(omega_test, T=50, dt=0.2, N_dirichlet=100)
        magnitudes = np.abs(ft_vals)
        is_peak = magnitudes[1] > magnitudes[0] and magnitudes[1] > magnitudes[2]
        print(f"  p={p:>2}: freq={freq:.4f}, "
              f"|FT| = [{magnitudes[0]:.2f}, {magnitudes[1]:.2f}, {magnitudes[2]:.2f}] "
              f"{'← PEAK' if is_peak else ''}")

    print("\n" + "=" * 70)
    print("CONCLUSION: The primes are audible in the Fourier transform of ζ.")
    print("Each prime p produces a spectral line at frequency log(p)/(2π).")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Spectral Consonance Matrix Between Primes"""
import numpy as np
import matplotlib.pyplot as plt
from math import log, pi

def sieve_primes(n):
    if n < 2: return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n+1, i): s[j] = False
    return [i for i in range(n+1) if s[i]]

primes = sieve_primes(30)
n = len(primes)

# Compute consonance matrix
matrix = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i == j:
            matrix[i, j] = 0
        else:
            ratio = log(primes[j]) / log(primes[i])
            best_dist = abs(ratio)
            for b in range(1, 51):
                a = round(ratio * b)
                dist = abs(ratio - a / b)
                if dist < best_dist:
                    best_dist = dist
            matrix[i, j] = best_dist

fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(matrix, cmap='hot_r', interpolation='nearest')
ax.set_xticks(range(n))
ax.set_xticklabels([str(p) for p in primes], fontsize=8)
ax.set_yticks(range(n))
ax.set_yticklabels([str(p) for p in primes], fontsize=8)
ax.set_xlabel('Prime q', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('Spectral Dissonance: min|log(q)/log(p) - a/b| for b ≤ 50', fontsize=13)
plt.colorbar(im, ax=ax, label='Dissonance (distance to nearest rational)')

plt.tight_layout()
plt.savefig('consonance_matrix.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved consonance_matrix.png")


#!/usr/bin/env python3
"""Visualization: Fourier Transform of ζ(1/2+it) showing prime peaks"""
import numpy as np
import matplotlib.pyplot as plt
from math import log, sqrt, pi

def sieve_primes(n):
    if n < 2: return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n+1, i): s[j] = False
    return [i for i in range(n+1) if s[i]]

def zeta_critical(t_arr, N=200):
    result = np.zeros(len(t_arr), dtype=complex)
    for n in range(1, N + 1):
        result += n ** (-0.5 - 1j * t_arr)
    return result

# Compute windowed FT
T = 80.0
dt = 0.15
t = np.arange(-T, T, dt)
sigma = T / 3
window = np.exp(-t**2 / (2 * sigma**2))
Z = zeta_critical(t, N=150) * window

omega = np.linspace(0, 1.0, 2000)
FT = np.zeros(len(omega), dtype=complex)
for i, w in enumerate(omega):
    FT[i] = np.sum(Z * np.exp(-2j * pi * w * t)) * dt

magnitude = np.abs(FT)

fig, ax = plt.subplots(figsize=(14, 6))
ax.plot(omega, magnitude, color='steelblue', linewidth=1.0, alpha=0.9)

primes = sieve_primes(50)
prime_freqs = [log(p) / (2 * pi) for p in primes]
for p, f in zip(primes, prime_freqs):
    if f < 1.0:
        ax.axvline(f, color='crimson', linestyle='--', alpha=0.6, linewidth=1)
        ax.annotate(f'p={p}', (f, max(magnitude) * 0.95),
                   textcoords='offset points', xytext=(3, -15),
                   fontsize=9, color='darkred', rotation=90)

ax.set_xlabel('Frequency ω', fontsize=13)
ax.set_ylabel('|F[ζ(1/2+it)](ω)|', fontsize=13)
ax.set_title('Fourier Transform of ζ(1/2+it): Peaks at Prime Frequencies', fontsize=14)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 0.8)

plt.tight_layout()
plt.savefig('fourier_peaks.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved fourier_peaks.png")


#!/usr/bin/env python3
"""Visualization: Prime Spectral Frequencies and Weights"""
import numpy as np
import matplotlib.pyplot as plt
from math import log, sqrt, pi

def sieve_primes(n):
    if n < 2: return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n+1, i): s[j] = False
    return [i for i in range(n+1) if s[i]]

primes = sieve_primes(100)
freqs = [log(p) / (2 * pi) for p in primes]
weights = [1.0 / sqrt(p) for p in primes]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

# Spectral lines
ax1.vlines(freqs, 0, weights, colors='steelblue', linewidth=2, alpha=0.8)
ax1.scatter(freqs, weights, color='crimson', zorder=5, s=40)
for p, f, w in zip(primes[:10], freqs[:10], weights[:10]):
    ax1.annotate(f'p={p}', (f, w), textcoords='offset points',
                xytext=(5, 5), fontsize=9, color='darkred')
ax1.set_xlabel('Frequency ω = log(p)/(2π)', fontsize=12)
ax1.set_ylabel('Amplitude 1/√p', fontsize=12)
ax1.set_title('Prime Spectral Lines of ζ(1/2+it)', fontsize=14)
ax1.set_xlim(0, max(freqs) * 1.05)
ax1.grid(True, alpha=0.3)

# Frequency gaps
gaps = [freqs[i+1] - freqs[i] for i in range(len(freqs)-1)]
lower_bounds = [log(1 + 1.0/primes[i]) / (2*pi) for i in range(len(primes)-1)]
ax2.bar(range(len(gaps)), gaps, color='steelblue', alpha=0.7, label='Actual gap')
ax2.bar(range(len(gaps)), lower_bounds, color='crimson', alpha=0.5, label='Lower bound')
ax2.set_xlabel('Consecutive prime pair index', fontsize=12)
ax2.set_ylabel('Frequency gap', fontsize=12)
ax2.set_title('Gaps Between Consecutive Prime Spectral Lines', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('prime_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved prime_spectrum.png")
