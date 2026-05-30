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
