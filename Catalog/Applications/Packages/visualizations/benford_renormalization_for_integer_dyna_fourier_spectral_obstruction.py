"""
Visualization: Fourier Spectral Obstruction Analysis

Plots the magnitude of Fourier modes |c_m| = |N^{-1} Σ exp(2πi·m·frac(log_b(u_k)))|
for several sequences. Benford sequences have decaying Fourier modes
(spectral flatness), while obstructed sequences show persistent peaks
(rational resonance).

This visualization makes the spectral obstruction theory concrete:
the dichotomy between Benford and non-Benford behavior is visible
as the presence or absence of spectral peaks.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def frac_log(x, base=10):
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(base)
    return v - math.floor(v)


def fourier_magnitudes(data, base=10, max_m=30):
    """Compute |c_m| for m = 1, ..., max_m."""
    N = len(data)
    if N == 0:
        return []
    mags = []
    for m in range(1, max_m + 1):
        total = sum(
            complex(math.cos(2 * math.pi * m * frac_log(x, base)),
                    math.sin(2 * math.pi * m * frac_log(x, base)))
            for x in data if x >= 1
        )
        mags.append(abs(total / N))
    return mags


# Generate sequences
pow2 = [2**k for k in range(1, 2001)]
pow3 = [3**k for k in range(1, 1001)]
pow10 = [10**k for k in range(1, 201)]
pow100 = [100**k for k in range(1, 101)]

fib = [1, 1]
for _ in range(2000):
    fib.append(fib[-1] + fib[-2])
fibonacci = fib[10:]

# 3^k * 2^k = 6^k (rational in base 10? No, log10(6) is irrational)
pow6 = [6**k for k in range(1, 501)]

max_m = 25
datasets = [
    ('Powers of 2 (Benford)', pow2, '#27ae60'),
    ('Powers of 3 (Benford)', pow3, '#2980b9'),
    ('Fibonacci (Benford)', fibonacci[:1000], '#8e44ad'),
    ('Powers of 6 (Benford)', pow6, '#e67e22'),
    ('Powers of 10 (Obstructed)', pow10, '#c0392b'),
    ('Powers of 100 (Obstructed)', pow100, '#e74c3c'),
]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
axes_flat = axes.flatten()

for idx, (title, data, color) in enumerate(datasets):
    ax = axes_flat[idx]
    mags = fourier_magnitudes(data, 10, max_m)
    modes = list(range(1, max_m + 1))

    ax.bar(modes, mags, color=color, alpha=0.8, edgecolor='white', linewidth=0.5)
    ax.axhline(y=0.1, color='gray', linewidth=1, linestyle='--', alpha=0.5)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Fourier mode m')
    ax.set_ylabel('|cₘ|')
    ax.set_ylim(0, 1.05)

    # Highlight obstruction threshold
    max_mag = max(mags) if mags else 0
    if max_mag > 0.5:
        ax.text(max_m * 0.6, 0.9, '⚠ OBSTRUCTION',
                fontsize=9, color='red', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    else:
        ax.text(max_m * 0.6, 0.9, '✓ Flat spectrum',
                fontsize=9, color='green', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='honeydew', alpha=0.8))

fig.suptitle('Fourier Spectral Analysis: Detecting Rational Obstruction',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_fourier_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_fourier_spectrum.png")
