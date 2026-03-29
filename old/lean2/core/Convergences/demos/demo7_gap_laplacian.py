#!/usr/bin/env python3
"""
Demo 7: Gap Laplacian Spectral Theory (Direction B1)

The gaps (n, n+1) between natural number "addresses" in ℝ can be equipped
with a Laplacian operator. The eigenvalues encode the "mass spectrum" of
states interpolating between discrete addresses.

This demo computes and visualizes:
1. Eigenfunctions of the gap Laplacian (particle in a box)
2. The universal π² ground state energy
3. Prime gap Laplacian with non-trivial spectrum
4. The holographic encoding (discrete boundary → continuous bulk)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from sympy import isprime
import matplotlib
matplotlib.use('Agg')

def solve_gap_laplacian(gap_length, n_modes=5, n_points=200):
    """
    Solve the Dirichlet Laplacian on an interval of given length.
    Returns eigenvalues and eigenfunctions.
    """
    x = np.linspace(0, gap_length, n_points)
    eigenvalues = [(k * np.pi / gap_length)**2 for k in range(1, n_modes + 1)]
    eigenfunctions = [np.sqrt(2/gap_length) * np.sin(k * np.pi * x / gap_length)
                      for k in range(1, n_modes + 1)]
    return x, eigenvalues, eigenfunctions

# ─── Figure 1: Multi-panel Gap Laplacian ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Eigenfunctions in a unit gap
ax1 = fig.add_subplot(gs[0, 0])
x, eigenvalues, eigenfunctions = solve_gap_laplacian(1.0, n_modes=5)

colors = ['#2196F3', '#E91E63', '#4CAF50', '#FF9800', '#9C27B0']
for k, (ef, ev, color) in enumerate(zip(eigenfunctions, eigenvalues, colors)):
    offset = k * 2.5
    ax1.plot(x, ef + offset, '-', color=color, linewidth=2,
             label=f'k={k+1}, λ={(k+1)**2}π²')
    ax1.axhline(y=offset, color=color, linestyle=':', alpha=0.3)
    ax1.fill_between(x, offset, ef + offset, alpha=0.1, color=color)

ax1.set_xlabel('Position in gap (0 to 1)', fontsize=12)
ax1.set_ylabel('Eigenfunction (offset for clarity)', fontsize=12)
ax1.set_title('Gap Laplacian Eigenfunctions\n(particle in a box)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)

# Panel 2: Spectrum comparison (uniform vs prime gaps)
ax2 = fig.add_subplot(gs[0, 1])

# Uniform gaps: all length 1
uniform_eigenvalues = [(k*np.pi)**2 for k in range(1, 20)]

# Prime gaps
primes = [p for p in range(2, 200) if isprime(p)]
prime_gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]

# Ground state eigenvalue for each prime gap
prime_ground_states = [(np.pi / g)**2 for g in prime_gaps]

ax2.stem(range(1, 20), uniform_eigenvalues[:19], linefmt='-b', markerfmt='ob',
         basefmt='', label='Uniform gaps (π²k²)')
ax2.stem([i + 0.3 for i in range(len(prime_ground_states[:19]))],
         prime_ground_states[:19], linefmt='-r', markerfmt='sr',
         basefmt='', label='Prime gaps (π²/g²)')
ax2.set_xlabel('Gap index', fontsize=12)
ax2.set_ylabel('Ground state eigenvalue λ₁', fontsize=12)
ax2.set_title('Ground State Spectrum\nUniform vs. Prime Gaps',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Panel 3: Cumulative mass profile
ax3 = fig.add_subplot(gs[1, 0])

# Uniform gaps: sum of ground states = N × π²
N_values = np.arange(1, 51)
uniform_mass = N_values * np.pi**2
# Quadratic fit
quadratic_mass = 0.5 * np.pi**2 * N_values * (N_values + 1) / N_values  # simplified

# Prime gaps cumulative mass
prime_cumulative = np.cumsum(prime_ground_states[:50])

ax3.plot(N_values, uniform_mass, '-', color='#2196F3', linewidth=2.5,
         label='Uniform: Nπ² (linear)')
ax3.plot(range(1, len(prime_cumulative)+1), prime_cumulative, '-',
         color='#E91E63', linewidth=2.5, label='Prime gaps (irregular)')
ax3.set_xlabel('Number of gaps summed', fontsize=12)
ax3.set_ylabel('Cumulative ground state mass', fontsize=12)
ax3.set_title('Cumulative Mass Profile\n(sum of ground state energies)',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# Panel 4: Holographic encoding visualization
ax4 = fig.add_subplot(gs[1, 1])

# Show discrete addresses (ℕ) and continuous gaps (ℝ)
addresses = np.arange(0, 8)
for n in addresses:
    ax4.axvline(x=n, color='#2196F3', linewidth=3, alpha=0.8)
    ax4.text(n, 1.05, f'{n}', ha='center', fontsize=12, color='#2196F3',
             fontweight='bold')

# Fill gaps with continuous color gradient
for n in range(7):
    x_gap = np.linspace(n, n+1, 100)
    y_gap = np.sin(np.pi * (x_gap - n))  # ground state eigenfunction
    ax4.fill_between(x_gap, 0, y_gap, alpha=0.3,
                     color=plt.cm.Spectral(n/7))
    ax4.plot(x_gap, y_gap, '-', color=plt.cm.Spectral(n/7), linewidth=1.5)

ax4.set_xlabel('ℝ (continuous)', fontsize=12)
ax4.set_ylabel('Ground state amplitude', fontsize=12)
ax4.set_title('Holographic Encoding\nDiscrete ℕ boundary → Continuous ℝ bulk',
              fontsize=13, fontweight='bold')
ax4.set_ylim(-0.1, 1.3)

# Annotations
ax4.annotate('Boundary\n(discrete, countable)',
             xy=(3, 1.05), xytext=(3, 1.25),
             fontsize=10, ha='center', color='#2196F3',
             arrowprops=dict(arrowstyle='->', color='#2196F3'))
ax4.annotate('Bulk\n(continuous, uncountable)',
             xy=(3.5, 0.5), xytext=(5.5, 0.8),
             fontsize=10, ha='center', color='gray',
             arrowprops=dict(arrowstyle='->', color='gray'))

ax4.grid(True, alpha=0.2)

fig.suptitle('Direction B1: Spectral Theory of the Gap Laplacian',
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig10_gap_laplacian.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 10 saved: fig10_gap_laplacian.png")
