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
