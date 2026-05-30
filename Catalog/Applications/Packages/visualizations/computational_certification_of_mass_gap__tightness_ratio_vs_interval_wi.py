#!/usr/bin/env python3
"""
Visualization: Tightness Ratio vs Interval Width

Shows how the quality of certified mass gap bounds degrades as the
interval arithmetic precision decreases. The tightness ratio (lower/upper
bound) measures certification quality — 1.0 means perfectly tight.

This illustrates the key theorem: tightness_ratio_in_unit_interval.
"""

import numpy as np
import matplotlib.pyplot as plt

# True eigenvalues
ev_true = 1.0
exc_true = 0.1
true_gap = np.log(ev_true / exc_true)

# Vary interval width from 0.1% to 40%
widths = np.linspace(0.001, 0.39, 200)
tightness = []
gap_lower = []
gap_upper = []

for w in widths:
    ev_lo = ev_true * (1 - w)
    ev_hi = ev_true * (1 + w)
    exc_lo = exc_true * (1 - w)
    exc_hi = exc_true * (1 + w)

    if exc_hi < ev_lo and exc_lo > 0:
        gl = np.log(ev_lo / exc_hi)
        gu = np.log(ev_hi / exc_lo)
        tightness.append(gl / gu)
        gap_lower.append(gl)
        gap_upper.append(gu)
    else:
        tightness.append(np.nan)
        gap_lower.append(np.nan)
        gap_upper.append(np.nan)

widths_pct = widths * 100
tightness = np.array(tightness)
gap_lower = np.array(gap_lower)
gap_upper = np.array(gap_upper)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Tightness ratio
ax1.plot(widths_pct, tightness, 'b-', linewidth=2)
ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Perfect tightness')
ax1.set_xlabel('Interval width (%)', fontsize=12)
ax1.set_ylabel('Tightness ratio', fontsize=12)
ax1.set_title('Certification Quality vs Precision', fontsize=14)
ax1.set_ylim(0, 1.05)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Gap bounds
ax2.fill_between(widths_pct, gap_lower, gap_upper, alpha=0.3, color='blue', label='Certified interval')
ax2.axhline(y=true_gap, color='red', linestyle='--', linewidth=2, label=f'True gap = {true_gap:.3f}')
ax2.set_xlabel('Interval width (%)', fontsize=12)
ax2.set_ylabel('Mass gap', fontsize=12)
ax2.set_title('Certified Gap Bounds', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tightness.png', dpi=150, bbox_inches='tight')
print("Saved viz_tightness.png")
