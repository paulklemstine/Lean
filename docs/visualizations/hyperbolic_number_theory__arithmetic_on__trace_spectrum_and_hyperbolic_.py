"""
Visualization 2: Trace Spectrum and Hyperbolic Primes
======================================================
Visualizes the classification of SL₂(ℤ) elements by trace,
the growth of hyperbolic trace counts, and the identification
of "prime" traces that correspond to primitive geodesics.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def chebyshev_trace(t, n):
    """Compute tr(Aⁿ) where tr(A) = t."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


def is_prime_trace(t, max_power=15):
    """Check if trace t is primitive (not a proper power)."""
    if abs(t) <= 2:
        return False
    for t0 in range(-abs(t) + 1, abs(t)):
        for n in range(2, max_power + 1):
            if chebyshev_trace(t0, n) == t:
                return False
    return True


def count_sl2z_by_norm(max_norm):
    """Count SL₂(ℤ) elements by trace for entry norm ≤ max_norm."""
    trace_counts = defaultdict(int)
    for a in range(-max_norm, max_norm + 1):
        for b in range(-max_norm, max_norm + 1):
            for c in range(-max_norm, max_norm + 1):
                for d in range(-max_norm, max_norm + 1):
                    if a * d - b * c == 1:
                        trace_counts[a + d] += 1
    return dict(trace_counts)


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Trace classification
ax = axes[0, 0]
ax.set_title("Trace Classification of SL₂(ℤ)\n(Elliptic / Parabolic / Hyperbolic)", fontsize=12)

traces = range(-10, 11)
colors = []
for t in traces:
    if abs(t) < 2:
        colors.append('#2196F3')  # Elliptic: blue
    elif abs(t) == 2:
        colors.append('#FF9800')  # Parabolic: orange
    else:
        colors.append('#E91E63')  # Hyperbolic: red

ax.bar(traces, [1] * len(traces), color=colors, edgecolor='white', linewidth=0.5)
ax.set_xlabel('Trace value t')
ax.set_ylabel('')
ax.set_yticks([])

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2196F3', label='Elliptic (|t| < 2)'),
    Patch(facecolor='#FF9800', label='Parabolic (|t| = 2)'),
    Patch(facecolor='#E91E63', label='Hyperbolic (|t| > 2)')
]
ax.legend(handles=legend_elements, fontsize=10)

# Panel 2: Hyperbolic trace count growth
ax = axes[0, 1]
ax.set_title("Hyperbolic Trace Count Growth\n# of hyperbolic traces with |t| ≤ T", fontsize=12)

T_values = range(3, 51)
counts = [2 * (T - 2) for T in T_values]
ax.plot(T_values, counts, 'b-', linewidth=2, label='2(T−2)')
ax.plot(T_values, list(T_values), 'r--', linewidth=1, label='T (linear reference)')
ax.fill_between(T_values, counts, alpha=0.1, color='blue')
ax.set_xlabel('Trace bound T')
ax.set_ylabel('Count')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Prime traces
ax = axes[1, 0]
ax.set_title("Prime vs Composite Traces\n(Prime = primitive hyperbolic element)", fontsize=12)

max_t = 30
prime_traces = []
composite_traces = []
for t in range(3, max_t + 1):
    if is_prime_trace(t):
        prime_traces.append(t)
    else:
        composite_traces.append(t)

ax.bar(prime_traces, [1] * len(prime_traces), color='#4CAF50', label=f'Prime ({len(prime_traces)})',
       edgecolor='white')
ax.bar(composite_traces, [1] * len(composite_traces), color='#9E9E9E',
       label=f'Composite ({len(composite_traces)})', edgecolor='white')
ax.set_xlabel('Trace value t')
ax.set_ylabel('')
ax.set_yticks([])
ax.legend(fontsize=10)

# Panel 4: SL₂(ℤ) trace distribution
ax = axes[1, 1]
ax.set_title("SL₂(ℤ) Element Count by Trace\n(entry norm ≤ 5)", fontsize=12)

trace_dist = count_sl2z_by_norm(5)
traces_sorted = sorted(trace_dist.keys())
counts_sorted = [trace_dist[t] for t in traces_sorted]

bar_colors = []
for t in traces_sorted:
    if abs(t) < 2:
        bar_colors.append('#2196F3')
    elif abs(t) == 2:
        bar_colors.append('#FF9800')
    else:
        bar_colors.append('#E91E63')

ax.bar(traces_sorted, counts_sorted, color=bar_colors, edgecolor='white', linewidth=0.5)
ax.set_xlabel('Trace value t')
ax.set_ylabel('Number of SL₂(ℤ) elements')
ax.set_yscale('log')
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_trace_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_trace_spectrum.png")
