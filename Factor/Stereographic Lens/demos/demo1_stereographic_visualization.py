"""
Demo 1: Stereographic Projection — The Idempotent Lens
=======================================================

Visualizes stereographic projection from the unit circle S¹ to ℝ,
and its inverse. Demonstrates the round-trip (idempotent lens) property.

Run: python demo1_stereographic_visualization.py
Outputs: stereographic_lens.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec

# ─── Core Functions ───────────────────────────────────────────────

def stereographic(x, y):
    """σ: S¹ \ {N} → ℝ. Maps (x, y) on the unit circle to t = x/(1-y)."""
    return x / (1 - y)

def stereographic_inv(t):
    """σ⁻¹: ℝ → S¹ \ {N}. Maps t to (2t/(t²+1), (t²-1)/(t²+1))."""
    denom = t**2 + 1
    return 2*t / denom, (t**2 - 1) / denom

def conformal_factor(y):
    """The conformal (magnification) factor: 2/(1-y)."""
    return 2.0 / (1.0 - y)

# ─── Verify the Idempotent Lens Property ─────────────────────────

print("=" * 60)
print("IDEMPOTENT LENS VERIFICATION")
print("=" * 60)

# Test round-trip: σ(σ⁻¹(t)) = t
test_values = [-5, -2, -1, -0.5, 0, 0.5, 1, 2, 5, 100]
print("\nRound-trip σ ∘ σ⁻¹ = id:")
for t in test_values:
    x, y = stereographic_inv(t)
    t_back = stereographic(x, y)
    print(f"  t = {t:8.2f} → (x,y) = ({x:.4f}, {y:.4f}) → t' = {t_back:.4f}  "
          f"[error = {abs(t - t_back):.2e}]")

# Test round-trip: σ⁻¹(σ(x,y)) = (x,y)
print("\nRound-trip σ⁻¹ ∘ σ = id:")
angles = np.linspace(-np.pi + 0.1, np.pi - 0.1, 8)
for theta in angles:
    x, y = np.cos(theta), np.sin(theta)
    if abs(y - 1) < 0.01:
        continue
    t = stereographic(x, y)
    x2, y2 = stereographic_inv(t)
    err = np.sqrt((x - x2)**2 + (y - y2)**2)
    print(f"  θ = {np.degrees(theta):6.1f}° → t = {t:8.4f} → (x',y') = ({x2:.4f}, {y2:.4f})  "
          f"[error = {err:.2e}]")

# Verify idempotency: L(L(p)) = L(p) where L = σ⁻¹ ∘ σ
print("\nIdempotency L² = L (should all be 0):")
for theta in angles:
    x, y = np.cos(theta), np.sin(theta)
    if abs(y - 1) < 0.01:
        continue
    # Apply L once
    t1 = stereographic(x, y)
    x1, y1 = stereographic_inv(t1)
    # Apply L again
    t2 = stereographic(x1, y1)
    x2, y2 = stereographic_inv(t2)
    err = np.sqrt((x1 - x2)**2 + (y1 - y2)**2)
    print(f"  θ = {np.degrees(theta):6.1f}°: ‖L²(p) - L(p)‖ = {err:.2e}")

# ─── Visualization ───────────────────────────────────────────────

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.3)

# --- Panel 1: The Projection Geometry ---
ax1 = fig.add_subplot(gs[0, 0])
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=2, label='Unit circle S¹')
ax1.plot(0, 1, 'ro', markersize=10, zorder=5, label='North pole N (∞)')

# Show projection rays
sample_angles = np.linspace(-2.5, 2.5, 9)
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(sample_angles)))
for i, a in enumerate(sample_angles):
    x, y = np.cos(a), np.sin(a)
    t = stereographic(x, y)
    if abs(t) < 10:
        ax1.plot([0, t], [1, 0], '--', color=colors[i], alpha=0.5, linewidth=1)
        ax1.plot(x, y, 'o', color=colors[i], markersize=6, zorder=5)
        ax1.plot(t, 0, 's', color=colors[i], markersize=6, zorder=5)

ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.axvline(x=0, color='gray', linewidth=0.5)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Stereographic Projection: S¹ → ℝ', fontsize=14, fontweight='bold')
ax1.legend(loc='lower right', fontsize=9)
ax1.set_xlabel('x / t')
ax1.set_ylabel('y')

# --- Panel 2: Conformal Factor ---
ax2 = fig.add_subplot(gs[0, 1])
y_vals = np.linspace(-1, 0.95, 200)
cf = conformal_factor(y_vals)
ax2.plot(y_vals, cf, 'r-', linewidth=2)
ax2.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='Factor = 1 (south pole)')
ax2.axhline(y=2, color='orange', linestyle='--', alpha=0.5, label='Factor = 2 (equator)')
ax2.axvline(x=-1, color='green', linestyle=':', alpha=0.3)
ax2.axvline(x=0, color='orange', linestyle=':', alpha=0.3)
ax2.fill_between(y_vals, cf, alpha=0.1, color='red')
ax2.set_xlabel('y-coordinate on circle', fontsize=12)
ax2.set_ylabel('Conformal factor 2/(1-y)', fontsize=12)
ax2.set_title('The Magnification of the Lens', fontsize=14, fontweight='bold')
ax2.set_ylim(0, 10)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: The Lens as Bijection ---
ax3 = fig.add_subplot(gs[1, 0])
t_range = np.linspace(-5, 5, 500)
x_inv, y_inv = stereographic_inv(t_range)

ax3.plot(t_range, x_inv, 'b-', linewidth=2, label='x(t) = 2t/(t²+1)')
ax3.plot(t_range, y_inv, 'r-', linewidth=2, label='y(t) = (t²-1)/(t²+1)')
ax3.axhline(y=0, color='gray', linewidth=0.5)
ax3.axhline(y=1, color='gray', linewidth=0.5, linestyle=':')
ax3.axhline(y=-1, color='gray', linewidth=0.5, linestyle=':')
ax3.set_xlabel('t ∈ ℝ (the "real" coordinate)', fontsize=12)
ax3.set_ylabel('Circle coordinates', fontsize=12)
ax3.set_title('σ⁻¹: Reality → Ideas\n(Inverse Stereographic)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Energy-Momentum Analogy ---
ax4 = fig.add_subplot(gs[1, 1])

# Show the "dual" nature: the circle has position (x) and momentum (y) aspects
theta_vals = np.linspace(-np.pi, np.pi, 200)
x_circle = np.cos(theta_vals)
y_circle = np.sin(theta_vals)

# Color by conformal factor (momentum)
cf_vals = np.array([conformal_factor(y) if y < 0.99 else 10 for y in y_circle])
cf_vals = np.clip(cf_vals, 0, 10)

scatter = ax4.scatter(x_circle, y_circle, c=cf_vals, cmap='coolwarm',
                      s=10, zorder=3)
plt.colorbar(scatter, ax=ax4, label='Conformal factor (magnification)')

# Mark fixed points
ax4.plot(1, 0, 'k*', markersize=15, zorder=5, label='Fixed point (+1, 0)')
ax4.plot(-1, 0, 'k*', markersize=15, zorder=5, label='Fixed point (−1, 0)')
ax4.plot(0, 1, 'ro', markersize=10, zorder=5, label='North pole (∞)')
ax4.plot(0, -1, 'go', markersize=10, zorder=5, label='South pole (neutral)')

ax4.set_aspect('equal')
ax4.set_title('The Lens: Position-Momentum Duality\non the Circle', fontsize=14, fontweight='bold')
ax4.legend(loc='lower right', fontsize=8)
ax4.grid(True, alpha=0.3)

plt.suptitle('THE IDEMPOTENT LENS: Stereographic Projection\n'
             '"The lens that turns reality into ideas"',
             fontsize=16, fontweight='bold', y=1.02)

plt.savefig('/workspace/request-project/python_demos/stereographic_lens.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("\n✓ Saved: stereographic_lens.png")
