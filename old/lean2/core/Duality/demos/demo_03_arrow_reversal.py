#!/usr/bin/env python3
"""
Demo 3 — Arrow Reversal: Ring Homs ↔ Continuous Maps
=====================================================
φ : ℤ → ℤ/nℤ  (quotient map)  induces  Spec(ℤ/nℤ) ↪ Spec(ℤ)  (inclusion).

Arrows REVERSE direction — the heart of contravariance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
fig.patch.set_facecolor("#0d1117")

# --- Left: Algebra side ---
ax1.set_facecolor("#0d1117")
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 6)

# ℤ box
rect1 = mpatches.FancyBboxPatch((1, 2), 3, 2, boxstyle="round,pad=0.3",
                                  facecolor='#1F6FEB', edgecolor='#58A6FF', lw=2)
ax1.add_patch(rect1)
ax1.text(2.5, 3, "ℤ", fontsize=24, ha='center', va='center', color='white',
         fontweight='bold')

# ℤ/6ℤ box
rect2 = mpatches.FancyBboxPatch((6, 2), 3, 2, boxstyle="round,pad=0.3",
                                  facecolor='#1F6FEB', edgecolor='#58A6FF', lw=2)
ax1.add_patch(rect2)
ax1.text(7.5, 3, "ℤ/6ℤ", fontsize=24, ha='center', va='center', color='white',
         fontweight='bold')

# Arrow ℤ → ℤ/6ℤ
ax1.annotate('', xy=(6, 3), xytext=(4, 3),
             arrowprops=dict(arrowstyle='->', color='#3FB950', lw=3))
ax1.text(5, 3.5, "φ", fontsize=16, ha='center', color='#3FB950', fontweight='bold')

ax1.set_title("ALGEBRA: Ring Homomorphism φ : ℤ → ℤ/6ℤ",
              fontsize=14, color='white', pad=15)
ax1.axis('off')

# --- Right: Geometry side ---
ax2.set_facecolor("#0d1117")
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 6)

# Spec(ℤ) with primes
specZ_primes = ['(0)', '(2)', '(3)', '(5)', '(7)', '(11)']
specZ_x = np.linspace(1.5, 8.5, len(specZ_primes))
for x, p in zip(specZ_x, specZ_primes):
    ax2.plot(x, 4.2, 'o', color='#58A6FF', markersize=14, zorder=5)
    ax2.text(x, 4.7, p, fontsize=9, ha='center', color='#C9D1D9')
ax2.text(5, 5.3, "Spec(ℤ)", fontsize=14, ha='center', color='#58A6FF',
         fontweight='bold')

# Spec(ℤ/6ℤ) with primes — only (2) and (3)
spec6_labels = ['(2̄)', '(3̄)']
spec6_x = [4, 6]
for x, p in zip(spec6_x, spec6_labels):
    ax2.plot(x, 1.5, 'o', color='#DA3633', markersize=14, zorder=5)
    ax2.text(x, 1.0, p, fontsize=10, ha='center', color='#C9D1D9')
ax2.text(5, 0.3, "Spec(ℤ/6ℤ)", fontsize=14, ha='center', color='#DA3633',
         fontweight='bold')

# Arrows Spec(ℤ/6ℤ) → Spec(ℤ)  (reverse direction!)
ax2.annotate('', xy=(specZ_x[1], 4.0), xytext=(4, 1.7),
             arrowprops=dict(arrowstyle='->', color='#F0883E', lw=2.5))
ax2.annotate('', xy=(specZ_x[2], 4.0), xytext=(6, 1.7),
             arrowprops=dict(arrowstyle='->', color='#F0883E', lw=2.5))

ax2.text(2.2, 2.8, "Spec(φ)", fontsize=14, color='#F0883E', fontweight='bold',
         rotation=60)

ax2.set_title("GEOMETRY: Spec(φ) : Spec(ℤ/6ℤ) → Spec(ℤ)  ← reversed!",
              fontsize=14, color='white', pad=15)
ax2.axis('off')

fig.suptitle("Row 3: Continuous Maps ↔ Ring Homomorphisms — Arrows Reverse!",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_03_arrow_reversal.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_03_arrow_reversal.png")
