#!/usr/bin/env python3
"""
Spectral Analysis of the Collatz Map — Demonstration Script

Computes the Fourier transform of Collatz parity words and demonstrates
the spectral gap phenomenon numerically.
"""
import math

def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the Collatz orbit of n until it reaches 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit

def parity_word(orbit: list[int]) -> list[int]:
    """Extract the parity word (0=even, 1=odd) from an orbit."""
    return [x % 2 for x in orbit]

def odd_step_count(pw: list[int]) -> int:
    """Count odd steps in a parity word."""
    return sum(pw)

def parity_density(pw: list[int]) -> float:
    """Fraction of odd steps."""
    return sum(pw) / len(pw) if pw else 0.0

def spectral_cos_sum(pw: list[int], omega: float) -> float:
    """Cosine component of the spectral sum."""
    return sum(pw[k] * math.cos(2 * math.pi * omega * k) for k in range(len(pw)))

def spectral_sin_sum(pw: list[int], omega: float) -> float:
    """Sine component of the spectral sum."""
    return sum(pw[k] * math.sin(2 * math.pi * omega * k) for k in range(len(pw)))

def spectral_energy(pw: list[int], omega: float) -> float:
    """Squared modulus of the spectral sum at frequency omega."""
    c = spectral_cos_sum(pw, omega)
    s = spectral_sin_sum(pw, omega)
    return c * c + s * s

def contraction_exponent(j: int, k: int) -> float:
    """The contraction exponent delta = k*log(2) - j*log(3)."""
    return k * math.log(2) - j * math.log(3)

CRITICAL_DENSITY = math.log(2) / math.log(3)  # ≈ 0.6309

def main():
    print("=" * 70)
    print("SPECTRAL ANALYSIS OF THE COLLATZ MAP")
    print("=" * 70)

    # Demo 1: Parity density for small values
    print("\n--- Demo 1: Parity Density vs Critical Threshold ---")
    print(f"Critical threshold: log(2)/log(3) = {CRITICAL_DENSITY:.6f}")
    print(f"{'n':>8} {'steps':>6} {'odd':>5} {'density':>8} {'delta':>8} {'contracts':>10}")
    for n in [3, 7, 27, 97, 231, 703, 871, 6171, 77031, 837799]:
        orbit = collatz_orbit(n)
        pw = parity_word(orbit)
        k = len(pw)
        j = odd_step_count(pw)
        d = parity_density(pw)
        delta = contraction_exponent(j, k)
        contracts = "YES" if delta > 0 else "NO"
        print(f"{n:>8} {k:>6} {j:>5} {d:>8.4f} {delta:>8.2f} {contracts:>10}")

    # Demo 2: Spectral energy at various frequencies for n=27
    print("\n--- Demo 2: Spectral Energy of Collatz(27) ---")
    orbit_27 = collatz_orbit(27)
    pw_27 = parity_word(orbit_27)
    k = len(pw_27)
    j = odd_step_count(pw_27)
    print(f"Orbit length: {k}, Odd steps: {j}, Density: {j/k:.4f}")
    print(f"{'omega':>10} {'energy':>12} {'bound (j^2)':>12} {'ratio':>8}")
    for omega_num in range(0, 11):
        omega = omega_num / 10.0
        e = spectral_energy(pw_27, omega)
        bound = j * j
        ratio = e / bound if bound > 0 else 0
        print(f"{omega:>10.1f} {e:>12.2f} {bound:>12} {ratio:>8.4f}")

    # Demo 3: Verify spectral gap conjecture for n up to 10000
    print("\n--- Demo 3: Spectral Gap Conjecture Test (n ≤ 10000) ---")
    max_density = 0.0
    max_n = 1
    violations = 0
    for n in range(2, 10001):
        orbit = collatz_orbit(n)
        if orbit[-1] != 1:
            violations += 1
            continue
        pw = parity_word(orbit)
        d = parity_density(pw)
        if d > max_density:
            max_density = d
            max_n = n

    print(f"Maximum parity density: {max_density:.6f} (at n={max_n})")
    print(f"Critical threshold:     {CRITICAL_DENSITY:.6f}")
    print(f"Gap:                    {CRITICAL_DENSITY - max_density:.6f}")
    print(f"Violations of Collatz:  {violations}")
    print(f"Conjecture holds for all n ≤ 10000: {max_density < CRITICAL_DENSITY}")

    # Demo 4: Compare with 5n+1 map
    print("\n--- Demo 4: Comparison with 5n+1 Map ---")
    def five_step(n):
        return n // 2 if n % 2 == 0 else 5 * n + 1

    print("5n+1 map: checking for divergence (first 20 odd numbers)")
    for n in range(1, 41, 2):
        val = n
        for _ in range(1000):
            val = five_step(val)
            if val == 1:
                break
        reached = "→ 1" if val == 1 else f"→ {val} (diverges/cycles)"
        print(f"  5n+1 orbit of {n:>3}: {reached}")

    # Demo 5: Contraction exponent improvement from even vs odd steps
    print("\n--- Demo 5: Even Step Advantage ---")
    print(f"log(3) = {math.log(3):.6f}")
    print(f"2*log(2) = {2*math.log(2):.6f}")
    print(f"log(3) < 2*log(2): {math.log(3) < 2*math.log(2)} (proven in Lean)")
    print(f"Each even step adds log(2) = {math.log(2):.6f} to contraction exponent")
    print(f"Each odd step subtracts log(3)-log(2) = {math.log(3)-math.log(2):.6f}")
    print(f"Break-even ratio: log(2)/log(3) = {CRITICAL_DENSITY:.6f}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Parity Density Distribution

Shows the distribution of parity densities across Collatz orbits,
demonstrating that all densities fall below the critical threshold.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    current = n
    while current != 1 and len(orbit) < max_steps:
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_density(orbit: list[int]) -> float:
    return sum(x % 2 for x in orbit) / len(orbit)


def main():
    CRITICAL = math.log(2) / math.log(3)
    N_MAX = 5000

    densities = []
    for n in range(2, N_MAX + 1):
        orbit = collatz_orbit(n)
        if orbit[-1] == 1:
            densities.append(parity_density(orbit))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Parity Density of Collatz Orbits vs Critical Threshold', fontsize=14, fontweight='bold')

    # Histogram
    ax1.hist(densities, bins=80, color='steelblue', alpha=0.8, edgecolor='black', linewidth=0.3)
    ax1.axvline(x=CRITICAL, color='red', linestyle='--', linewidth=2,
                label=f'Critical: log(2)/log(3) ≈ {CRITICAL:.4f}')
    ax1.set_xlabel('Parity Density j/k')
    ax1.set_ylabel('Count')
    ax1.set_title(f'Distribution of Parity Densities (n = 2..{N_MAX})')
    ax1.legend()

    # Scatter plot
    ns = list(range(2, N_MAX + 1))
    ax2.scatter(ns, densities, s=1, alpha=0.5, color='steelblue')
    ax2.axhline(y=CRITICAL, color='red', linestyle='--', linewidth=2,
                label=f'Critical threshold ≈ {CRITICAL:.4f}')
    ax2.set_xlabel('Starting value n')
    ax2.set_ylabel('Parity Density j/k')
    ax2.set_title(f'Parity Density vs Starting Value')
    ax2.legend()
    ax2.set_ylim(0.3, 0.7)

    plt.tight_layout()
    plt.savefig('parity_density.png', dpi=150, bbox_inches='tight')
    print("Saved: parity_density.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Profile of Collatz Parity Words

Generates a plot showing the spectral energy at different frequencies
for several Collatz orbits, demonstrating the spectral gap phenomenon.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    orbit = [n]
    current = n
    while current != 1 and len(orbit) < max_steps:
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_word(orbit: list[int]) -> list[int]:
    return [x % 2 for x in orbit]


def spectral_energy(pw: list[int], omega: float) -> float:
    c = sum(pw[k] * math.cos(2 * math.pi * omega * k) for k in range(len(pw)))
    s = sum(pw[k] * math.sin(2 * math.pi * omega * k) for k in range(len(pw)))
    return c * c + s * s


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Spectral Energy Profile of Collatz Parity Words', fontsize=16, fontweight='bold')

    test_values = [27, 97, 871, 6171]
    omegas = np.linspace(0.01, 0.99, 200)

    for idx, n in enumerate(test_values):
        ax = axes[idx // 2][idx % 2]
        orbit = collatz_orbit(n)
        pw = parity_word(orbit)
        k = len(pw)
        j = sum(pw)
        density = j / k

        energies = [spectral_energy(pw, w) for w in omegas]
        dc_energy = j * j

        ax.plot(omegas, energies, 'b-', linewidth=0.8, alpha=0.8)
        ax.axhline(y=dc_energy, color='r', linestyle='--', alpha=0.5,
                   label=f'DC energy = j² = {dc_energy}')
        ax.axhline(y=k, color='g', linestyle=':', alpha=0.5,
                   label=f'√K bound = {k}')
        ax.set_xlabel('Frequency ω')
        ax.set_ylabel('Spectral Energy |F(ω)|²')
        ax.set_title(f'n = {n} (k={k}, j={j}, ρ={density:.4f})')
        ax.legend(fontsize=8)
        ax.set_xlim(0, 1)

    plt.tight_layout()
    plt.savefig('spectral_profile.png', dpi=150, bbox_inches='tight')
    print("Saved: spectral_profile.png")


if __name__ == "__main__":
    main()
