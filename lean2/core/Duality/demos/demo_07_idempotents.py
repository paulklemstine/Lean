#!/usr/bin/env python3
"""
Demo 7 — Connected Components ↔ Idempotents
============================================
e² = e decomposes the ring:  A ≅ eA × (1-e)A.
This corresponds to a clopen partition of Spec(A).

Example: ℤ/6ℤ ≅ ℤ/2ℤ × ℤ/3ℤ — the spectrum has two connected components.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
fig.patch.set_facecolor("#0d1117")

# --- Left: Connected spectrum (no nontrivial idempotents) ---
ax1.set_facecolor("#0d1117")
primes_Z = ['(0)', '(2)', '(3)', '(5)', '(7)']
xs = np.linspace(1, 5, len(primes_Z))
for x, p in zip(xs, primes_Z):
    ax1.plot(x, 1.5, 'o', color='#3FB950', markersize=20, zorder=5)
    ax1.text(x, 0.9, p, fontsize=11, ha='center', color='#C9D1D9')

# Connecting line to show connectedness
ax1.plot(xs, [1.5] * len(xs), '-', color='#3FB95066', lw=8, zorder=3)

ax1.set_title("Spec(ℤ) — Connected\nOnly trivial idempotents: 0, 1",
              fontsize=13, color='white', pad=12)
ax1.set_xlim(0, 6)
ax1.set_ylim(0, 3)
ax1.axis('off')

# --- Right: Disconnected spectrum (nontrivial idempotent) ---
ax2.set_facecolor("#0d1117")

# Component 1: Spec(ℤ/2ℤ)
ax2.plot(2, 1.5, 'o', color='#DA3633', markersize=20, zorder=5)
ax2.text(2, 0.9, '(2̄)', fontsize=11, ha='center', color='#C9D1D9')
rect1 = mpatches.FancyBboxPatch((1.2, 0.6), 1.6, 1.6,
                                  boxstyle="round,pad=0.2",
                                  facecolor='#DA363322', edgecolor='#DA3633', lw=2)
ax2.add_patch(rect1)
ax2.text(2, 2.5, "Spec(ℤ/2ℤ)", fontsize=10, ha='center', color='#DA3633')

# Component 2: Spec(ℤ/3ℤ)
ax2.plot(5, 1.5, 'o', color='#A371F7', markersize=20, zorder=5)
ax2.text(5, 0.9, '(3̄)', fontsize=11, ha='center', color='#C9D1D9')
rect2 = mpatches.FancyBboxPatch((4.2, 0.6), 1.6, 1.6,
                                  boxstyle="round,pad=0.2",
                                  facecolor='#A371F722', edgecolor='#A371F7', lw=2)
ax2.add_patch(rect2)
ax2.text(5, 2.5, "Spec(ℤ/3ℤ)", fontsize=10, ha='center', color='#A371F7')

# Gap between components
ax2.text(3.5, 1.5, "⊔", fontsize=24, ha='center', va='center', color='#FFD700')

ax2.set_title("Spec(ℤ/6ℤ) ≅ Spec(ℤ/2ℤ) ⊔ Spec(ℤ/3ℤ)\n"
              "Idempotent e: e² = e, e ∉ {0,1}",
              fontsize=13, color='white', pad=12)
ax2.set_xlim(0, 7)
ax2.set_ylim(0, 3)
ax2.axis('off')

fig.suptitle("Row 7: Connected Components ↔ Idempotents",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_07_idempotents.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_07_idempotents.png")
