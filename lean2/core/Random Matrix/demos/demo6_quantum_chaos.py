#!/usr/bin/env python3
"""
Demo 6: Quantum Chaos — The BGS Conjecture
=============================================
Demonstrates the Bohigas-Giannoni-Schmit conjecture: quantum systems
whose classical dynamics is chaotic have energy levels with random
matrix statistics, while integrable systems show Poisson statistics.

Run: python demo6_quantum_chaos.py
Outputs: quantum_chaos.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

def stadium_billiard_matrix(N):
    """
    Approximate Hamiltonian for a quantum stadium billiard (chaotic).
    Uses a random matrix from GOE as proxy for the chaotic case.
    (True stadium billiard computation requires PDE solving.)
    """
    A = np.random.randn(N, N)
    H = (A + A.T) / np.sqrt(2 * N)
    return np.linalg.eigvalsh(H)

def rectangular_billiard(n_max, aspect_ratio=1.0):
    """
    Energy levels of a rectangular billiard (integrable).
    E_{m,n} = π²(m²/a² + n²/b²), m,n = 1,2,3,...
    """
    energies = []
    for m in range(1, n_max+1):
        for n in range(1, n_max+1):
            E = np.pi**2 * (m**2 + n**2 / aspect_ratio**2)
            energies.append(E)
    return np.sort(energies)

def harmonic_oscillator_2d(n_max):
    """
    Energy levels of 2D harmonic oscillator (integrable).
    E_{n1,n2} = n1 + n2 + 1, n1,n2 = 0,1,2,...
    High degeneracy → Poisson-like statistics.
    """
    energies = []
    for n1 in range(n_max):
        for n2 in range(n_max):
            E = n1 + n2 + 1
            energies.append(E)
    return np.sort(energies)

def sinai_billiard_proxy(N):
    """
    Proxy for Sinai billiard (chaotic): rectangular billiard with a 
    random perturbation to break integrability.
    """
    # Start with rectangular billiard
    H_0 = np.diag(np.sort(np.random.uniform(0, N, N)))
    # Add random perturbation (break integrability)
    V = np.random.randn(N, N) * 0.3 / np.sqrt(N)
    V = (V + V.T) / 2
    H = H_0 + V
    return np.linalg.eigvalsh(H)

def unfold_and_spacings(energies, bulk_fraction=0.5):
    """Unfold energy levels and compute nearest-neighbor spacings."""
    n = len(energies)
    # Take bulk levels
    start = int(n * (1 - bulk_fraction) / 2)
    end = int(n * (1 + bulk_fraction) / 2)
    bulk = energies[start:end]
    spacings = np.diff(bulk)
    mean_s = np.mean(spacings)
    if mean_s > 0:
        return spacings / mean_s
    return spacings

# ─── Wigner surmise ───
s = np.linspace(0, 4, 500)
wigner_GOE = (np.pi * s / 2) * np.exp(-np.pi * s**2 / 4)
poisson = np.exp(-s)

# ─── Generate data ───
N = 300
n_samples = 500

print("Computing chaotic system spacings (GOE proxy)...")
chaotic_spacings = []
for _ in range(n_samples):
    eigs = stadium_billiard_matrix(N)
    sp = unfold_and_spacings(eigs)
    chaotic_spacings.extend(sp)
chaotic_spacings = np.array(chaotic_spacings)

print("Computing integrable system spacings (rectangular billiard)...")
integrable_spacings = []
for aspect in np.random.uniform(0.9, 1.1, n_samples):
    eigs = rectangular_billiard(50, aspect)
    sp = unfold_and_spacings(eigs)
    integrable_spacings.extend(sp)
integrable_spacings = np.array(integrable_spacings)

print("Computing mixed system spacings...")
mixed_spacings = []
for _ in range(n_samples):
    eigs = sinai_billiard_proxy(N)
    sp = unfold_and_spacings(eigs)
    mixed_spacings.extend(sp)
mixed_spacings = np.array(mixed_spacings)

# ─── Figure ───
fig = plt.figure(figsize=(18, 12))
fig.suptitle("Quantum Chaos and the BGS Conjecture\n"
             "Chaotic quantum systems → GOE statistics; Integrable systems → Poisson statistics",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(2, 3, hspace=0.4, wspace=0.3)

# Panel 1: Integrable system
ax1 = fig.add_subplot(gs[0, 0])
ax1.hist(integrable_spacings, bins=60, density=True, alpha=0.6,
         color='#2ecc71', edgecolor='white', linewidth=0.5,
         label='Rectangular billiard')
ax1.plot(s, poisson, 'k-', linewidth=2.5, label='Poisson P(s)=e⁻ˢ')
ax1.plot(s, wigner_GOE, 'r--', linewidth=1.5, alpha=0.5, label='GOE Wigner')
ax1.set_xlabel('Normalized spacing s', fontsize=10)
ax1.set_ylabel('P(s)', fontsize=10)
ax1.set_title('INTEGRABLE: Rectangular Billiard\n(Level clustering, no repulsion)',
              fontsize=11, fontweight='bold', color='#2ecc71')
ax1.legend(fontsize=9)
ax1.set_xlim(0, 4)
ax1.set_ylim(0, 1.2)

# Panel 2: Chaotic system
ax2 = fig.add_subplot(gs[0, 1])
ax2.hist(chaotic_spacings, bins=60, density=True, alpha=0.6,
         color='#e74c3c', edgecolor='white', linewidth=0.5,
         label='Stadium billiard (proxy)')
ax2.plot(s, wigner_GOE, 'k-', linewidth=2.5, label='GOE Wigner surmise')
ax2.plot(s, poisson, 'g--', linewidth=1.5, alpha=0.5, label='Poisson')
ax2.set_xlabel('Normalized spacing s', fontsize=10)
ax2.set_ylabel('P(s)', fontsize=10)
ax2.set_title('CHAOTIC: Stadium Billiard\n(Level repulsion, GOE statistics)',
              fontsize=11, fontweight='bold', color='#e74c3c')
ax2.legend(fontsize=9)
ax2.set_xlim(0, 4)
ax2.set_ylim(0, 1.2)

# Panel 3: Mixed system
ax3 = fig.add_subplot(gs[0, 2])
ax3.hist(mixed_spacings, bins=60, density=True, alpha=0.6,
         color='#9b59b6', edgecolor='white', linewidth=0.5,
         label='Perturbed integrable')
ax3.plot(s, wigner_GOE, 'r-', linewidth=2, alpha=0.7, label='GOE')
ax3.plot(s, poisson, 'g-', linewidth=2, alpha=0.7, label='Poisson')
ax3.set_xlabel('Normalized spacing s', fontsize=10)
ax3.set_ylabel('P(s)', fontsize=10)
ax3.set_title('MIXED: Perturbed Integrable\n(Transition between regimes)',
              fontsize=11, fontweight='bold', color='#9b59b6')
ax3.legend(fontsize=9)
ax3.set_xlim(0, 4)
ax3.set_ylim(0, 1.2)

# Panel 4: Energy level diagrams
ax4 = fig.add_subplot(gs[1, 0])
# Show actual energy levels side by side
rect_eigs = rectangular_billiard(15)[:50]
rect_eigs = (rect_eigs - rect_eigs.min()) / (rect_eigs.max() - rect_eigs.min())

goe_eigs = np.sort(stadium_billiard_matrix(50))
goe_eigs = (goe_eigs - goe_eigs.min()) / (goe_eigs.max() - goe_eigs.min())

for i, e in enumerate(rect_eigs):
    ax4.plot([0, 0.45], [e, e], color='#2ecc71', linewidth=1, alpha=0.7)
for i, e in enumerate(goe_eigs):
    ax4.plot([0.55, 1], [e, e], color='#e74c3c', linewidth=1, alpha=0.7)

ax4.axvline(x=0.5, color='gray', linewidth=0.5)
ax4.text(0.22, 1.05, 'Integrable\n(clustered)', transform=ax4.transAxes,
         ha='center', fontsize=10, fontweight='bold', color='#2ecc71')
ax4.text(0.78, 1.05, 'Chaotic\n(repelling)', transform=ax4.transAxes,
         ha='center', fontsize=10, fontweight='bold', color='#e74c3c')
ax4.set_ylabel('Normalized Energy', fontsize=10)
ax4.set_title('Energy Level Comparison', fontsize=11, fontweight='bold')
ax4.set_xticks([])

# Panel 5: Level spacing ratio (modern diagnostic)
ax5 = fig.add_subplot(gs[1, 1])
def spacing_ratios(eigs):
    """Compute r_n = min(s_n, s_{n+1}) / max(s_n, s_{n+1})."""
    spacings = np.diff(eigs)
    spacings = spacings[spacings > 0]
    ratios = []
    for i in range(len(spacings)-1):
        r = min(spacings[i], spacings[i+1]) / max(spacings[i], spacings[i+1])
        ratios.append(r)
    return np.array(ratios)

# GOE ratio distribution
goe_ratios = []
for _ in range(n_samples):
    eigs = stadium_billiard_matrix(N)
    goe_ratios.extend(spacing_ratios(eigs))
goe_ratios = np.array(goe_ratios)

# Poisson ratio distribution
poisson_ratios = []
for _ in range(n_samples):
    eigs = np.sort(np.random.uniform(0, N, N))
    poisson_ratios.extend(spacing_ratios(eigs))
poisson_ratios = np.array(poisson_ratios)

r_range = np.linspace(0, 1, 100)
# Theoretical: GOE → <r> ≈ 0.5307, Poisson → <r> ≈ 0.3863
p_poisson_r = 2 / (1 + r_range)**2  # Exact for Poisson
p_goe_r = (27/4) * (r_range + r_range**2) / (1 + r_range + r_range**2)**(5/2)  # GOE surmise

ax5.hist(poisson_ratios, bins=50, density=True, alpha=0.5, color='#2ecc71',
         edgecolor='white', linewidth=0.5, label='Poisson')
ax5.hist(goe_ratios, bins=50, density=True, alpha=0.5, color='#e74c3c',
         edgecolor='white', linewidth=0.5, label='GOE')
ax5.plot(r_range, p_poisson_r, 'g-', linewidth=2)
ax5.plot(r_range, p_goe_r, 'r-', linewidth=2)
ax5.set_xlabel('Spacing ratio r = min(sₙ,sₙ₊₁)/max(sₙ,sₙ₊₁)', fontsize=9)
ax5.set_ylabel('P(r)', fontsize=10)
ax5.set_title('Spacing Ratio Distribution\n(No unfolding needed!)',
              fontsize=11, fontweight='bold')
ax5.legend(fontsize=10)
ax5.set_xlim(0, 1)

# Panel 6: The BGS conjecture statement
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')
bgs_text = (
    "THE BGS CONJECTURE\n"
    "(Bohigas, Giannoni, Schmit, 1984)\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "If a quantum system's classical\n"
    "dynamics is CHAOTIC, then its\n"
    "energy level statistics follow\n"
    "RANDOM MATRIX THEORY.\n\n"
    "• Chaotic → GOE/GUE/GSE\n"
    "  (eigenvalue repulsion)\n\n"
    "• Integrable → Poisson\n"
    "  (no repulsion, levels cluster)\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "Physical intuition:\n"
    "In chaotic systems, wave functions\n"
    "spread ergodically → all levels\n"
    "interact → universal repulsion.\n\n"
    "In integrable systems, conserved\n"
    "quantities separate levels into\n"
    "independent sequences → no repulsion."
)
ax6.text(0.5, 0.5, bgs_text, transform=ax6.transAxes,
         fontsize=9.5, ha='center', va='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.8', facecolor='#fff5f5',
                   edgecolor='#e74c3c', linewidth=2, alpha=0.95))

fig.text(0.5, 0.01,
         "Eigenvalue repulsion is the fingerprint of quantum chaos — "
         "it distinguishes chaotic from integrable quantum systems.\n"
         "The same Vandermonde mechanism operates: chaos → ergodic eigenstates → "
         "effective random matrix behavior → Coulomb repulsion.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('quantum_chaos.png', dpi=150, bbox_inches='tight')
print("Saved: quantum_chaos.png")
plt.close()
