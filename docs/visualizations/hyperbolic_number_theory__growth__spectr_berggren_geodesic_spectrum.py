#!/usr/bin/env python3
"""
Visualization: Berggren Trace Classification and Geodesic Length Spectrum

Shows the cross-domain bridge between Pythagorean triples and hyperbolic geometry:
1. Left panel: Trace recurrence for M₂ powers with classification regions
2. Right panel: Geodesic length spectrum showing translation lengths
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# --- Trace computation ---
def trace_sequence(t0, n):
    traces = [2, t0]
    for _ in range(2, n + 1):
        traces.append(t0 * traces[-1] - traces[-2])
    return traces[1:]

def translation_length(trace):
    t = abs(trace)
    if t <= 2:
        return 0.0
    return 2 * np.arccosh(t / 2)

# --- Panel 1: Berggren Classification ---
generators = {
    'M₁': {'trace': 1, 'color': '#2196F3', 'type': 'Elliptic'},
    'M₃': {'trace': 2, 'color': '#FF9800', 'type': 'Parabolic'},
    'M₂': {'trace': 3, 'color': '#E53935', 'type': 'Hyperbolic'},
}

# Background regions
ax1.axhspan(-2, 2, alpha=0.08, color='#2196F3', label='Elliptic region (|tr| < 2)')
ax1.axhspan(2, 50, alpha=0.08, color='#E53935', label='Hyperbolic region (|tr| > 2)')
ax1.axhline(y=2, color='#FF9800', linestyle='--', linewidth=1.5, alpha=0.7)
ax1.axhline(y=-2, color='#FF9800', linestyle='--', linewidth=1.5, alpha=0.7)

# Plot Berggren generators
for name, info in generators.items():
    ax1.plot(0, info['trace'], 'o', color=info['color'], markersize=15, zorder=5)
    ax1.annotate(f"{name}\ntr = {info['trace']}\n({info['type']})", 
                xy=(0, info['trace']), fontsize=10, fontweight='bold',
                xytext=(0.3, info['trace']), ha='left', va='center',
                color=info['color'],
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', 
                         edgecolor=info['color'], alpha=0.9))

# Trace recurrence for M₂ powers
traces_m2 = trace_sequence(3, 6)
powers = list(range(1, 7))
ax1.plot(powers, traces_m2, 's-', color='#E53935', markersize=8, linewidth=2,
         label='tr(M₂ⁿ)', zorder=4)

for i, tr in enumerate(traces_m2):
    ax1.annotate(f'{tr}', xy=(i+1, tr), fontsize=8, ha='center', va='bottom',
                xytext=(0, 8), textcoords='offset points', color='#E53935')

ax1.set_xlabel('Power n', fontsize=13)
ax1.set_ylabel('Trace', fontsize=13)
ax1.set_title('SL₂(ℤ) Trace Classification\nof Berggren Generators', fontsize=14, fontweight='bold')
ax1.set_xlim(-0.5, 6.5)
ax1.set_ylim(-5, max(traces_m2) * 1.15)
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Geodesic Length Spectrum ---
traces_long = trace_sequence(3, 10)
lengths = [translation_length(t) for t in traces_long]
powers_long = list(range(1, 11))

bars = ax2.bar(powers_long, lengths, color='#7B1FA2', alpha=0.8, edgecolor='#4A148C', linewidth=1.5)

# Annotate each bar
for i, (length, trace) in enumerate(zip(lengths, traces_long)):
    ax2.annotate(f'ℓ = {length:.2f}\ntr = {trace}', 
                xy=(i+1, length), fontsize=8, ha='center', va='bottom',
                xytext=(0, 3), textcoords='offset points', color='#4A148C')

# Reference: linear growth rate
linear_fit = np.polyfit(powers_long, lengths, 1)
x_fit = np.linspace(0.5, 10.5, 100)
ax2.plot(x_fit, np.polyval(linear_fit, x_fit), '--', color='#FF9800', linewidth=2,
         alpha=0.7, label=f'Linear fit: ℓ ≈ {linear_fit[0]:.2f}n + {linear_fit[1]:.2f}')

ax2.set_xlabel('Power n (M₂ⁿ)', fontsize=13)
ax2.set_ylabel('Translation Length ℓ(M₂ⁿ)', fontsize=13)
ax2.set_title('Geodesic Length Spectrum\nfrom Berggren M₂ Powers', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xlim(0.3, 10.7)

plt.tight_layout()
plt.savefig('viz_geodesics.png', dpi=150, bbox_inches='tight')
print("Saved viz_geodesics.png")
