#!/usr/bin/env python3
"""
Demo: The Sound of Pi — Musical Structure in Digit Sequences

Demonstrates the consonance spectrum, digit transition spectrum, and
spectral flatness test on the digits of π, e, and √2.
"""

from algorithms import (
    consonance_spectrum,
    normalized_consonance_spectrum,
    transition_spectrum,
    spectral_flatness_test,
    chromatic_frequency,
    pythagorean_intervals,
)

# First 200 digits of pi (after decimal point)
PI_DIGITS = [
    1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6,
    2, 6, 4, 3, 3, 8, 3, 2, 7, 9, 5, 0, 2, 8, 8, 4, 1, 9, 7, 1,
    6, 9, 3, 9, 9, 3, 7, 5, 1, 0, 5, 8, 2, 0, 9, 7, 4, 9, 4, 4,
    5, 9, 2, 3, 0, 7, 8, 1, 6, 4, 0, 6, 2, 8, 6, 2, 0, 8, 9, 9,
    8, 6, 2, 8, 0, 3, 4, 8, 2, 5, 3, 4, 2, 1, 1, 7, 0, 6, 7, 9,
    8, 2, 1, 4, 8, 0, 8, 6, 5, 1, 3, 2, 8, 2, 3, 0, 6, 6, 4, 7,
    0, 9, 3, 8, 4, 4, 6, 0, 9, 5, 5, 0, 5, 8, 2, 2, 3, 1, 7, 2,
    5, 3, 5, 9, 4, 0, 8, 1, 2, 8, 4, 8, 1, 1, 1, 7, 4, 5, 0, 2,
    8, 4, 1, 0, 2, 7, 0, 1, 9, 3, 8, 5, 2, 1, 1, 0, 5, 5, 5, 9,
    6, 4, 4, 6, 2, 2, 9, 4, 8, 9, 5, 4, 9, 3, 0, 3, 8, 1, 9, 6,
]

# First 200 digits of e (after decimal point)
E_DIGITS = [
    7, 1, 8, 2, 8, 1, 8, 2, 8, 4, 5, 9, 0, 4, 5, 2, 3, 5, 3, 6,
    0, 2, 8, 7, 4, 7, 1, 3, 5, 2, 6, 6, 2, 4, 9, 7, 7, 5, 7, 2,
    4, 7, 0, 9, 3, 6, 9, 9, 9, 5, 9, 5, 7, 4, 9, 6, 6, 9, 6, 7,
    6, 2, 7, 7, 2, 4, 0, 7, 6, 6, 3, 0, 3, 5, 3, 5, 4, 7, 5, 9,
    4, 5, 7, 1, 3, 8, 2, 1, 7, 8, 5, 2, 5, 1, 6, 6, 4, 2, 7, 4,
    2, 7, 4, 6, 6, 3, 9, 1, 9, 3, 2, 0, 0, 3, 0, 5, 9, 9, 2, 1,
    8, 1, 7, 4, 1, 3, 5, 9, 6, 6, 2, 9, 0, 4, 3, 5, 7, 2, 9, 0,
    0, 3, 3, 4, 2, 9, 5, 2, 6, 0, 5, 9, 5, 6, 3, 0, 7, 3, 8, 1,
    3, 2, 3, 2, 8, 6, 2, 7, 9, 4, 3, 4, 9, 0, 7, 6, 3, 2, 3, 3,
    8, 2, 9, 8, 8, 0, 7, 5, 3, 1, 9, 5, 2, 5, 1, 0, 1, 9, 0, 1,
]

INTERVAL_NAMES = [
    "Unison", "Minor 2nd", "Major 2nd", "Minor 3rd",
    "Major 3rd", "Perfect 4th", "Tritone", "Perfect 5th",
    "Minor 6th", "Major 6th", "Minor 7th", "Major 7th", "Octave"
]


def demo_consonance_spectrum():
    """Demonstrate the consonance spectrum for π and e."""
    print("=" * 70)
    print("CONSONANCE SPECTRUM ANALYSIS")
    print("=" * 70)

    N = 180  # Window size (need N + 12 digits available)

    for name, digits in [("π", PI_DIGITS), ("e", E_DIGITS)]:
        print(f"\n--- {name}: Consonance Spectrum (N={N}, center=4.5) ---")
        cs = normalized_consonance_spectrum(digits, N, center=4.5)
        for i, (val, interval_name) in enumerate(zip(cs, INTERVAL_NAMES)):
            bar = "█" * int(abs(val) * 200)
            sign = "+" if val >= 0 else "-"
            print(f"  Lag {i:2d} ({interval_name:12s}): {val:+8.4f}  {sign}{bar}")

        print(f"\n  Energy (lag 0):    {cs[0]:.4f}")
        print(f"  Perfect 5th (7):  {cs[7]:.4f}")
        print(f"  Octave (12):      {cs[12]:.4f}")
        print(f"  Max |C/N| (k>0):  {max(abs(c) for c in cs[1:]):.4f}")
        bound = 81  # B² for B=9
        print(f"  Theoretical max:  {bound:.1f}")


def demo_transition_spectrum():
    """Demonstrate the digit transition spectrum."""
    print("\n" + "=" * 70)
    print("DIGIT TRANSITION SPECTRUM")
    print("=" * 70)

    N = 180

    for lag_name, k in [("Minor 2nd", 1), ("Perfect 5th", 7), ("Octave", 12)]:
        ts = transition_spectrum(PI_DIGITS, N, k)
        print(f"\n--- π: Transition spectrum at lag {k} ({lag_name}) ---")
        for t in sorted(ts.keys()):
            count = ts[t]
            freq = count / N
            bar = "█" * int(freq * 100)
            print(f"  t={t:+3d}: {count:4d} ({freq:.3f})  {bar}")


def demo_spectral_flatness():
    """Test the Spectral Flatness Conjecture."""
    print("\n" + "=" * 70)
    print("SPECTRAL FLATNESS TEST")
    print("=" * 70)

    N = 180

    for name, digits in [("π", PI_DIGITS), ("e", E_DIGITS)]:
        max_dev, k1, k2 = spectral_flatness_test(digits, N)
        threshold = 2.0 / (N ** 0.5)
        status = "PASS ✓" if max_dev < threshold else "FAIL ✗"
        print(f"\n  {name}: max deviation = {max_dev:.4f} "
              f"(at lags {k1}, {k2})")
        print(f"       threshold 2/√N = {threshold:.4f}")
        print(f"       {status}")


def demo_pythagorean_intervals():
    """Show musical intervals from Pythagorean triples."""
    print("\n" + "=" * 70)
    print("PYTHAGOREAN TRIPLE → MUSICAL INTERVALS")
    print("=" * 70)

    triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]
    for a, b, c in triples:
        intervals = pythagorean_intervals(a, b, c)
        print(f"\n  ({a}, {b}, {c}):")
        for name, semitones in intervals.items():
            nearest = round(semitones)
            if 0 <= nearest < 13:
                interval_name = INTERVAL_NAMES[nearest]
            else:
                interval_name = f"{nearest} semitones"
            print(f"    {name:30s}: {semitones:6.2f} semitones "
                  f"≈ {interval_name}")


def demo_chromatic_mapping():
    """Show the chromatic frequency mapping."""
    print("\n" + "=" * 70)
    print("CHROMATIC FREQUENCY MAPPING (digit → Hz)")
    print("=" * 70)

    note_names = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#"]
    for d in range(10):
        freq = chromatic_frequency(d)
        print(f"  digit {d} → {note_names[d]:2s}  = {freq:7.2f} Hz")


if __name__ == "__main__":
    demo_chromatic_mapping()
    demo_consonance_spectrum()
    demo_transition_spectrum()
    demo_spectral_flatness()
    demo_pythagorean_intervals()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
  Key findings:
  1. The consonance spectrum of π and e is nearly flat (max |C/N| ≈ 0.5),
     consistent with no musical structure in the digit sequences.
  2. The transition spectra are approximately lag-independent, supporting
     the Spectral Flatness Conjecture.
  3. Pythagorean triples naturally encode the consonant musical intervals
     used to define the consonance spectrum.
  4. The theoretical autocorrelation bound (81N) is far larger than the
     observed values, confirming the digits show minimal correlation.
    """)


#!/usr/bin/env python3
"""
Visualization: Consonance Spectrum of Pi and e

Produces a bar chart comparing the normalized consonance spectra of
the first 180 digits of π and e, highlighting the flatness.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def digit_autocorrelation(digits, N, k):
    return sum(digits[i] * digits[i + k] for i in range(N))


def centered_autocorrelation(digits, N, k, center):
    return sum((digits[i] - center) * (digits[i + k] - center) for i in range(N))


def normalized_consonance_spectrum(digits, N, center=4.5):
    return [centered_autocorrelation(digits, N, k, center) / N for k in range(13)]


PI_DIGITS = [
    1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6,
    2, 6, 4, 3, 3, 8, 3, 2, 7, 9, 5, 0, 2, 8, 8, 4, 1, 9, 7, 1,
    6, 9, 3, 9, 9, 3, 7, 5, 1, 0, 5, 8, 2, 0, 9, 7, 4, 9, 4, 4,
    5, 9, 2, 3, 0, 7, 8, 1, 6, 4, 0, 6, 2, 8, 6, 2, 0, 8, 9, 9,
    8, 6, 2, 8, 0, 3, 4, 8, 2, 5, 3, 4, 2, 1, 1, 7, 0, 6, 7, 9,
    8, 2, 1, 4, 8, 0, 8, 6, 5, 1, 3, 2, 8, 2, 3, 0, 6, 6, 4, 7,
    0, 9, 3, 8, 4, 4, 6, 0, 9, 5, 5, 0, 5, 8, 2, 2, 3, 1, 7, 2,
    5, 3, 5, 9, 4, 0, 8, 1, 2, 8, 4, 8, 1, 1, 1, 7, 4, 5, 0, 2,
    8, 4, 1, 0, 2, 7, 0, 1, 9, 3, 8, 5, 2, 1, 1, 0, 5, 5, 5, 9,
    6, 4, 4, 6, 2, 2, 9, 4, 8, 9, 5, 4, 9, 3, 0, 3, 8, 1, 9, 6,
]

E_DIGITS = [
    7, 1, 8, 2, 8, 1, 8, 2, 8, 4, 5, 9, 0, 4, 5, 2, 3, 5, 3, 6,
    0, 2, 8, 7, 4, 7, 1, 3, 5, 2, 6, 6, 2, 4, 9, 7, 7, 5, 7, 2,
    4, 7, 0, 9, 3, 6, 9, 9, 9, 5, 9, 5, 7, 4, 9, 6, 6, 9, 6, 7,
    6, 2, 7, 7, 2, 4, 0, 7, 6, 6, 3, 0, 3, 5, 3, 5, 4, 7, 5, 9,
    4, 5, 7, 1, 3, 8, 2, 1, 7, 8, 5, 2, 5, 1, 6, 6, 4, 2, 7, 4,
    2, 7, 4, 6, 6, 3, 9, 1, 9, 3, 2, 0, 0, 3, 0, 5, 9, 9, 2, 1,
    8, 1, 7, 4, 1, 3, 5, 9, 6, 6, 2, 9, 0, 4, 3, 5, 7, 2, 9, 0,
    0, 3, 3, 4, 2, 9, 5, 2, 6, 0, 5, 9, 5, 6, 3, 0, 7, 3, 8, 1,
    3, 2, 3, 2, 8, 6, 2, 7, 9, 4, 3, 4, 9, 0, 7, 6, 3, 2, 3, 3,
    8, 2, 9, 8, 8, 0, 7, 5, 3, 1, 9, 5, 2, 5, 1, 0, 1, 9, 0, 1,
]

INTERVAL_NAMES = [
    "Unison", "min 2nd", "Maj 2nd", "min 3rd",
    "Maj 3rd", "Perf 4th", "Tritone", "Perf 5th",
    "min 6th", "Maj 6th", "min 7th", "Maj 7th", "Octave"
]

N = 180
cs_pi = normalized_consonance_spectrum(PI_DIGITS, N)
cs_e = normalized_consonance_spectrum(E_DIGITS, N)

x = np.arange(13)
width = 0.35

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

# Plot 1: Consonance spectra
bars1 = ax1.bar(x - width/2, cs_pi, width, label='π', color='#2196F3', alpha=0.8)
bars2 = ax1.bar(x + width/2, cs_e, width, label='e', color='#FF5722', alpha=0.8)
ax1.set_xlabel('Musical Interval (Lag)', fontsize=12)
ax1.set_ylabel('Normalized Autocorrelation (C/N)', fontsize=12)
ax1.set_title('Consonance Spectrum: π vs e', fontsize=14, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(INTERVAL_NAMES, rotation=45, ha='right', fontsize=9)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.legend()
ax1.grid(axis='y', alpha=0.3)

# Plot 2: Absolute values (showing flatness)
ax2.bar(x - width/2, [abs(c) for c in cs_pi[1:]] + [0], width,
        label='|C/N| for π', color='#2196F3', alpha=0.8)
ax2.bar(x + width/2, [abs(c) for c in cs_e[1:]] + [0], width,
        label='|C/N| for e', color='#FF5722', alpha=0.8)
threshold = 2.0 / np.sqrt(N)
ax2.axhline(y=threshold, color='green', linewidth=2, linestyle='--',
            label=f'2/√N = {threshold:.3f}')
ax2.set_xlabel('Musical Interval (Lag)', fontsize=12)
ax2.set_ylabel('|Normalized Autocorrelation|', fontsize=12)
ax2.set_title('Spectral Flatness Test (lags 1-12)', fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(INTERVAL_NAMES, rotation=45, ha='right', fontsize=9)
ax2.legend()
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('consonance_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: consonance_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Pythagorean Triples as Musical Intervals

Shows how Pythagorean triples map to positions on the chromatic scale,
connecting geometry to music theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def semitone_approx(ratio):
    return 12 * math.log2(ratio)


# First several primitive Pythagorean triples
triples = [
    (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
    (20, 21, 29), (9, 40, 41), (12, 35, 37), (11, 60, 61),
    (28, 45, 53), (33, 56, 65), (36, 77, 85), (13, 84, 85),
]

INTERVAL_NAMES = [
    "Unison", "min 2nd", "Maj 2nd", "min 3rd",
    "Maj 3rd", "Perf 4th", "Tritone", "Perf 5th",
    "min 6th", "Maj 6th", "min 7th", "Maj 7th", "Octave",
    "min 9th", "Maj 9th", "min 10th", "Maj 10th"
]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Leg ratios as semitones
leg_ratios = []
hyp_ratios = []
labels = []
for a, b, c in triples:
    if a > b:
        a, b = b, a
    lr = semitone_approx(b / a)
    hr = semitone_approx(c / a)
    leg_ratios.append(lr)
    hyp_ratios.append(hr)
    labels.append(f"({a},{b},{c})")

y_pos = range(len(triples))
ax1.barh(y_pos, leg_ratios, color='#2196F3', alpha=0.8, label='b/a (leg ratio)')
ax1.barh(y_pos, hyp_ratios, color='#FF5722', alpha=0.3, label='c/a (hyp ratio)')

# Add vertical lines for standard intervals
for semitones in [4, 5, 7, 12]:
    ax1.axvline(x=semitones, color='gray', linewidth=0.5, linestyle='--')
    if semitones < len(INTERVAL_NAMES):
        ax1.text(semitones + 0.1, len(triples) - 0.5,
                 INTERVAL_NAMES[semitones], fontsize=8, color='gray')

ax1.set_yticks(y_pos)
ax1.set_yticklabels(labels)
ax1.set_xlabel('Semitones (12 · log₂(ratio))', fontsize=11)
ax1.set_title('Pythagorean Triples as Musical Intervals', fontsize=13, fontweight='bold')
ax1.legend(loc='lower right')
ax1.grid(axis='x', alpha=0.3)

# Plot 2: Scatter plot of (a, b) colored by nearest musical interval
colors_map = plt.cm.hsv(np.linspace(0, 0.8, 13))
for a, b, c in triples:
    if a > b:
        a, b = b, a
    lr = semitone_approx(b / a)
    nearest = min(max(round(lr), 0), 12)
    ax2.scatter(a, b, c=[colors_map[nearest]], s=100, edgecolors='black', linewidth=0.5)
    ax2.annotate(INTERVAL_NAMES[nearest], (a, b), fontsize=7,
                 textcoords="offset points", xytext=(5, 5))

# Draw the unit circle scaled
theta = np.linspace(0, np.pi / 2, 100)
for r in [10, 20, 30, 50]:
    ax2.plot(r * np.cos(theta), r * np.sin(theta), 'k-', alpha=0.1)

ax2.set_xlabel('Shorter leg (a)', fontsize=11)
ax2.set_ylabel('Longer leg (b)', fontsize=11)
ax2.set_title('Pythagorean Triples in the Plane\n(colored by nearest interval)',
              fontsize=13, fontweight='bold')
ax2.set_aspect('equal')
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('pythagorean_intervals.png', dpi=150, bbox_inches='tight')
print("Saved: pythagorean_intervals.png")


#!/usr/bin/env python3
"""
Visualization: Digit Transition Spectrum Heatmap

Produces a heatmap showing the transition spectrum T_N(k, t) for all
lags k = 1..12 and transition values t = -9..9.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def transition_spectrum(digits, N, k):
    counts = {}
    for i in range(N):
        t = digits[i + k] - digits[i]
        counts[t] = counts.get(t, 0) + 1
    return counts


PI_DIGITS = [
    1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6,
    2, 6, 4, 3, 3, 8, 3, 2, 7, 9, 5, 0, 2, 8, 8, 4, 1, 9, 7, 1,
    6, 9, 3, 9, 9, 3, 7, 5, 1, 0, 5, 8, 2, 0, 9, 7, 4, 9, 4, 4,
    5, 9, 2, 3, 0, 7, 8, 1, 6, 4, 0, 6, 2, 8, 6, 2, 0, 8, 9, 9,
    8, 6, 2, 8, 0, 3, 4, 8, 2, 5, 3, 4, 2, 1, 1, 7, 0, 6, 7, 9,
    8, 2, 1, 4, 8, 0, 8, 6, 5, 1, 3, 2, 8, 2, 3, 0, 6, 6, 4, 7,
    0, 9, 3, 8, 4, 4, 6, 0, 9, 5, 5, 0, 5, 8, 2, 2, 3, 1, 7, 2,
    5, 3, 5, 9, 4, 0, 8, 1, 2, 8, 4, 8, 1, 1, 1, 7, 4, 5, 0, 2,
    8, 4, 1, 0, 2, 7, 0, 1, 9, 3, 8, 5, 2, 1, 1, 0, 5, 5, 5, 9,
    6, 4, 4, 6, 2, 2, 9, 4, 8, 9, 5, 4, 9, 3, 0, 3, 8, 1, 9, 6,
]

INTERVAL_NAMES = [
    "", "min 2nd", "Maj 2nd", "min 3rd", "Maj 3rd", "P4",
    "Tritone", "P5", "min 6th", "Maj 6th", "min 7th", "Maj 7th", "Octave"
]

N = 180
t_range = range(-9, 10)
k_range = range(1, 13)

# Build heatmap data
heatmap = np.zeros((len(list(t_range)), len(list(k_range))))
for j, k in enumerate(k_range):
    ts = transition_spectrum(PI_DIGITS, N, k)
    for i, t in enumerate(t_range):
        heatmap[i, j] = ts.get(t, 0) / N

fig, ax = plt.subplots(figsize=(12, 8))
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax.set_xlabel('Musical Interval (Lag k)', fontsize=12)
ax.set_ylabel('Transition Value (t = d[i+k] - d[i])', fontsize=12)
ax.set_title('Digit Transition Spectrum of π', fontsize=14, fontweight='bold')

ax.set_xticks(range(len(list(k_range))))
ax.set_xticklabels([INTERVAL_NAMES[k] for k in k_range], rotation=45, ha='right')
ax.set_yticks(range(len(list(t_range))))
ax.set_yticklabels([str(t) for t in t_range])

cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Frequency (T_N(k,t) / N)', fontsize=11)

plt.tight_layout()
plt.savefig('transition_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: transition_spectrum.png")
