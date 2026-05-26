#!/usr/bin/env python3
"""
Transfer Pipeline Visualization

Illustrates the three-stage transfer from Lorentzian geometry to algorithmic
mixing: Lorentzian margin → Residual gap → Spectral gap → Mixing time.

Shows how each transfer stage preserves quantitative bounds with explicit
universal constants.

This script is fully self-contained and does not import from local modules.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def lorentzian_margin(delta: float) -> float:
    """Simulated Lorentzian margin as function of perturbation."""
    return max(0, 1.0 - delta)


def residual_gap(lor_margin: float) -> float:
    """Residual gap from Lorentzian margin via transfer theorem."""
    # Transfer: r_gap ≥ c * lor_margin (with c ≈ 0.5)
    return 0.5 * lor_margin


def spectral_gap_from_residual(r_gap: float) -> float:
    """Spectral gap from residual gap via Poincaré inequality."""
    # Transfer: s_gap ≥ r_gap / (r_gap + 1)
    return r_gap / (r_gap + 1) if r_gap > 0 else 0.0


def mixing_time(s_gap: float, n: int) -> float:
    """Mixing time from spectral gap."""
    if s_gap <= 0:
        return float('inf')
    return np.log(n) / s_gap


# ============================================================
# Create multi-panel visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

deltas = np.linspace(0, 1.5, 200)
n = 10

# Stage 1: Perturbation → Lorentzian margin
ax1 = axes[0, 0]
lor_margins = [lorentzian_margin(d) for d in deltas]
ax1.plot(deltas, lor_margins, '-', color='#1565C0', linewidth=2.5)
ax1.fill_between(deltas, lor_margins, alpha=0.15, color='#1565C0')
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.7, linewidth=1)
ax1.axvline(x=1.0, color='red', linestyle=':', alpha=0.5,
            label='Critical threshold')
ax1.set_xlabel('Perturbation δ', fontsize=12)
ax1.set_ylabel('Lorentzian Margin', fontsize=12)
ax1.set_title('Stage 1: Geometry\nLorentzian Margin vs Perturbation', fontsize=13)
ax1.legend()
ax1.grid(True, alpha=0.3)
ax1.annotate('Lorentzian\nregion', xy=(0.3, 0.7), fontsize=11,
             color='#1565C0', fontweight='bold')
ax1.annotate('Non-Lorentzian\nregion', xy=(1.1, 0.3), fontsize=11,
             color='red', fontweight='bold')

# Stage 2: Lorentzian margin → Residual gap
ax2 = axes[0, 1]
r_gaps = [residual_gap(m) for m in lor_margins]
ax2.plot(lor_margins, r_gaps, '-', color='#E65100', linewidth=2.5)
ax2.plot([0, 1], [0, 0.5], '--', color='gray', alpha=0.5,
         label='Transfer bound: rg ≥ 0.5·m')
ax2.set_xlabel('Lorentzian Margin', fontsize=12)
ax2.set_ylabel('Residual Gap', fontsize=12)
ax2.set_title('Stage 2: Geometry → Analysis\nResidual Gap Transfer', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

# Stage 3: Residual gap → Spectral gap
ax3 = axes[1, 0]
r_range = np.linspace(0, 0.6, 200)
s_gaps = [spectral_gap_from_residual(r) for r in r_range]
ax3.plot(r_range, s_gaps, '-', color='#2E7D32', linewidth=2.5)
ax3.plot(r_range, r_range, ':', color='gray', alpha=0.5,
         label='sg = rg (upper bound)')
ax3.fill_between(r_range, s_gaps, r_range, alpha=0.1, color='#2E7D32')
ax3.set_xlabel('Residual Gap', fontsize=12)
ax3.set_ylabel('Spectral Gap', fontsize=12)
ax3.set_title('Stage 3: Analysis → Algorithms\nSpectral Gap Transfer', fontsize=13)
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.annotate('sg ≥ rg/(rg+1)', xy=(0.3, 0.15), fontsize=11,
             color='#2E7D32', fontweight='bold')

# Stage 4: Full pipeline — perturbation to mixing time
ax4 = axes[1, 1]
mixing_times = []
for d in deltas:
    m = lorentzian_margin(d)
    rg = residual_gap(m)
    sg = spectral_gap_from_residual(rg)
    mt = mixing_time(sg, n)
    mixing_times.append(min(mt, 1000))  # Cap for visualization

ax4.semilogy(deltas, mixing_times, '-', color='#6A1B9A', linewidth=2.5)
ax4.axvline(x=1.0, color='red', linestyle=':', alpha=0.7,
            label='Phase transition')
ax4.axhline(y=100, color='green', linestyle='--', alpha=0.5,
            label='Polynomial threshold')
ax4.set_xlabel('Perturbation δ', fontsize=12)
ax4.set_ylabel('Mixing Time (log scale)', fontsize=12)
ax4.set_title('Full Pipeline: Geometry → Mixing Time', fontsize=13)
ax4.legend()
ax4.grid(True, alpha=0.3)
ax4.set_ylim([1, 1100])

# Annotate phases
ax4.annotate('Polynomial\nmixing', xy=(0.3, 10), fontsize=11,
             color='#2E7D32', fontweight='bold')
ax4.annotate('Exponential\nslowdown', xy=(1.15, 500), fontsize=11,
             color='red', fontweight='bold')

plt.suptitle('The Transfer Pipeline: From Geometry to Algorithms',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('transfer_pipeline.png', dpi=150, bbox_inches='tight')
print("Saved transfer_pipeline.png")
