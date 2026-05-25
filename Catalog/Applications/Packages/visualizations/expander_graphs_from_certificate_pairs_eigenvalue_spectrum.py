#!/usr/bin/env python3
"""
Visualization: Eigenvalue Spectrum of Certified Cayley Graphs

Visualizes the eigenvalue distribution of the normalized adjacency operator
for Cayley graphs constructed from certified matrix pairs in GL₂(𝔽_q).
The spectral gap (distance from 1 to the second eigenvalue) is highlighted.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import certificate_expansion_pipeline

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

for ax_idx, q in enumerate([3, 5]):
    ax = axes[ax_idx]
    results = certificate_expansion_pipeline(q, max_pairs=1)

    if not results:
        ax.text(0.5, 0.5, f'No certified pair found for q={q}',
                ha='center', va='center', transform=ax.transAxes)
        continue

    r = results[0]
    eigenvalues = np.array(r['eigenvalues'])
    gap = r['spectral_gap']

    # Histogram of eigenvalues
    ax.hist(eigenvalues, bins=50, color='steelblue', alpha=0.7,
            edgecolor='navy', linewidth=0.5)

    # Mark the trivial eigenvalue at 1
    ax.axvline(x=1.0, color='red', linewidth=2, linestyle='--',
               label=f'λ₁ = 1 (trivial)')

    # Mark the second eigenvalue
    second_ev = eigenvalues[1] if len(eigenvalues) >= 2 else 0
    ax.axvline(x=second_ev, color='green', linewidth=2, linestyle='-.',
               label=f'λ₂ = {second_ev:.4f}')

    # Shade the spectral gap
    ax.axvspan(second_ev, 1.0, alpha=0.15, color='green',
               label=f'Spectral gap = {gap:.4f}')

    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Spectrum of Cayley Graph on GL₂(𝔽_{q})\n'
                 f'|G| = {r["gl2_order"]}, degree = {r["degree"]}',
                 fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

plt.suptitle('Eigenvalue Spectra of Certificate-Based Cayley Graphs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_spectrum.png")
