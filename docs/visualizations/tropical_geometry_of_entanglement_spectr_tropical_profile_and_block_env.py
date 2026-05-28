"""
Visualization 1: Tropical Profile and Block Envelope

Visualizes the core concept of tropical entanglement geometry:
the tropical profile log(e_k) is a discrete concave potential,
and for block spectra it is bounded by the piecewise-linear
tropical envelope. The slopes cluster into plateaus corresponding
to spectral bands, with transitions at gap locations.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log


def elementary_symmetric_polynomials(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks):
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


def multi_block_envelope(blocks):
    N = sum(m for _, m in blocks)
    env = np.zeros(N + 1)
    for k in range(1, N + 1):
        rem = k
        val = 0.0
        for w, m in blocks:
            alloc = min(rem, m)
            if alloc > 0 and w > 0:
                val += log(w) * alloc
            rem -= alloc
            if rem == 0:
                break
        env[k] = val
    return env


# Setup
blocks = [(8.0, 5), (3.0, 4), (1.0, 4)]
spectrum = block_spectrum(blocks)
N = len(spectrum)

e = elementary_symmetric_polynomials(spectrum)
profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])
slopes = np.diff(profile)
envelope = multi_block_envelope(blocks)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Tropical profile vs envelope
ax = axes[0]
ks = np.arange(N + 1)
ax.plot(ks, profile, 'b-o', markersize=4, label=r'$\log e_k(\lambda)$ (tropical profile)', linewidth=2)
ax.plot(ks, envelope, 'r--s', markersize=4, label=r'$F(k)$ (block envelope)', linewidth=2)
ax.fill_between(ks, envelope, profile, alpha=0.15, color='blue')
ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel('Value', fontsize=13)
ax.set_title('Tropical Profile vs Block Envelope', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Slope profile with plateau lines
ax = axes[1]
slope_ks = np.arange(N)
ax.plot(slope_ks, slopes, 'g-o', markersize=4, linewidth=2, label='Discrete slopes')

# Draw expected plateaus
cumul = 0
colors = ['red', 'orange', 'purple']
for idx, (w, mult) in enumerate(blocks):
    lw = log(w) if w > 0 else 0
    ax.axhline(y=lw, color=colors[idx], linestyle='--', alpha=0.6,
               label=f'$\\log({w})={lw:.2f}$')
    ax.axvline(x=cumul, color='gray', linestyle=':', alpha=0.4)
    cumul += mult

ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel('Slope', fontsize=13)
ax.set_title('Slope Plateaus (Gap = Corner)', fontsize=13)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)

# Panel 3: Newton defect
ax = axes[2]
defects = []
for k in range(1, N):
    d = e[k]**2 - e[k-1]*e[k+1]
    defects.append(d)

ax.bar(range(1, N), defects, color='steelblue', alpha=0.7, edgecolor='navy')
ax.axhline(y=0, color='red', linestyle='-', linewidth=1)
ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel(r'$e_k^2 - e_{k-1} e_{k+1}$', fontsize=13)
ax.set_title("Newton's Inequality Defect (≥ 0)", fontsize=13)
ax.grid(True, alpha=0.3)

plt.suptitle('Tropical Geometry of Entanglement Spectra\n'
             f'Block spectrum: {blocks}', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('tropical_profile.png', dpi=150, bbox_inches='tight')
print("Saved tropical_profile.png")
