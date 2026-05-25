#!/usr/bin/env python3
"""
Visualization: Mixing Time Convergence

Shows how the random walk on the certified Cayley graph converges to the
uniform distribution. Plots the L² distance from uniform as a function
of the number of steps, demonstrating exponential decay governed by the
spectral gap.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import MatrixGroup, CertificateVerifier, CayleyGraph, SpectralAnalyzer

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

for ax_idx, q in enumerate([3, 5]):
    ax = axes[ax_idx]

    mg = MatrixGroup(q)
    cv = CertificateVerifier(q)
    gl2 = mg.enumerate_gl2()
    n = len(gl2)

    # Find a certified pair
    singers = [A for A in gl2 if cv.is_singer_like(A)]
    prim_dets = [A for A in gl2 if cv.is_primitive_det(A)]

    g, h = None, None
    for sg in singers:
        for pd in prim_dets:
            if cv.generates_group(sg, pd, gl2):
                g, h = sg, pd
                break
        if g is not None:
            break

    if g is None:
        ax.text(0.5, 0.5, f'No pair found for q={q}',
                ha='center', va='center', transform=ax.transAxes)
        continue

    gi, hi = mg.inv(g), mg.inv(h)
    generators = [g, gi, h, hi]
    cayley = CayleyGraph(gl2, generators, mg)
    spectral = SpectralAnalyzer(cayley)
    gap = spectral.spectral_gap()

    # Compute walk distribution at each time step
    M = cayley.normalized_adjacency
    uniform = np.ones(n) / n

    # Start from identity
    identity_idx = {mg.to_tuple(A): i for i, A in enumerate(gl2)}
    p = np.zeros(n)
    p[identity_idx[mg.to_tuple(mg.identity())]] = 1.0

    max_steps = 40
    l2_distances = []

    for t in range(max_steps):
        diff = p - uniform
        l2_dist = np.sqrt(np.sum(diff ** 2))
        l2_distances.append(l2_dist)
        p = M.T @ p  # One step of the walk

    steps = range(max_steps)

    # Plot actual L² distance
    ax.semilogy(steps, l2_distances, 'b-o', markersize=3,
                label='Actual L² distance', linewidth=1.5)

    # Plot theoretical bound
    if gap > 0:
        alpha = 1 - gap
        theoretical = [l2_distances[0] * alpha ** t for t in steps]
        ax.semilogy(steps, theoretical, 'r--', linewidth=1.5,
                    label=f'Bound: (1-gap)^t, gap={gap:.4f}')

    ax.set_xlabel('Steps', fontsize=12)
    ax.set_ylabel('L² distance from uniform', fontsize=12)
    ax.set_title(f'Mixing on Cayley(GL₂(𝔽_{q}), S)\n'
                 f'|G| = {n}, gap = {gap:.4f}',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-8)

plt.suptitle('Exponential Mixing of Random Walks on Certified Cayley Graphs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mixing_time.png', dpi=150, bbox_inches='tight')
print("Saved: mixing_time.png")
