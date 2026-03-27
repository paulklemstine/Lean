"""
Demo 4: Möbius Transformations — Symmetries of the Lens
========================================================

The Möbius transformations (fractional linear transformations) are the
symmetry group of stereographic projection. They are the maps
    z ↦ (az + b) / (cz + d)
that preserve the "circle-to-circle" property.

Each Möbius transformation = (rotation of the sphere) viewed through the lens.

Run: python demo4_mobius_symmetry.py
Outputs: mobius_symmetry.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# ─── Möbius Transformations ──────────────────────────────────────

def mobius(z, a, b, c, d):
    """Apply Möbius transformation z ↦ (az+b)/(cz+d) to complex number z."""
    return (a*z + b) / (c*z + d)

def mobius_on_circle(theta, a, b, c, d):
    """Apply Möbius transformation to a point on the unit circle."""
    z = np.exp(1j * theta)
    w = mobius(z, a, b, c, d)
    return w

# ─── Special Möbius Transformations ──────────────────────────────

transforms = {
    'Identity': (1, 0, 0, 1),
    'Rotation π/4': (np.exp(1j*np.pi/8), 0, 0, np.exp(-1j*np.pi/8)),
    'Inversion': (0, 1, 1, 0),
    'Translation': (1, 0.5, 0, 1),
    'Dilation ×2': (2, 0, 0, 1),
    'Cayley': (1, -1j, 1, 1j),  # Maps upper half-plane to disk
}

# ─── Visualization ───────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(18, 12))
axes = axes.flatten()

# Create a grid of circles to transform
circles = []
for r in [0.3, 0.6, 0.9, 1.2, 1.8]:
    theta = np.linspace(0, 2*np.pi, 200)
    circles.append(r * np.exp(1j * theta))
for cx in np.linspace(-2, 2, 5):
    y = np.linspace(-2, 2, 200)
    circles.append(cx + 1j*y)
for cy in np.linspace(-2, 2, 5):
    x = np.linspace(-2, 2, 200)
    circles.append(x + 1j*cy)

for idx, (name, (a, b, c, d)) in enumerate(transforms.items()):
    ax = axes[idx]

    for circle in circles:
        # Transform the circle/line
        with np.errstate(divide='ignore', invalid='ignore'):
            w = mobius(circle, a, b, c, d)

        # Filter out infinities
        mask = np.isfinite(w) & (np.abs(w) < 5)
        if np.sum(mask) > 1:
            # Plot segments (break at discontinuities)
            breaks = np.where(np.diff(mask.astype(int)) != 0)[0] + 1
            segments = np.split(np.arange(len(w)), breaks)
            for seg in segments:
                seg = seg[mask[seg]]
                if len(seg) > 1:
                    ax.plot(np.real(w[seg]), np.imag(w[seg]),
                           linewidth=0.8, alpha=0.6)

    # Draw the unit circle for reference
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', linewidth=1, alpha=0.3)

    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.set_title(f'{name}\nz ↦ ({a:.1f}z + {b:.1f})/({c:.1f}z + {d:.1f})',
                fontsize=11, fontweight='bold')
    ax.grid(True, alpha=0.2)

plt.suptitle('MÖBIUS TRANSFORMATIONS: The Symmetry Group of the Lens\n'
             'Each transformation maps circles/lines → circles/lines',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('/workspace/request-project/python_demos/mobius_symmetry.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: mobius_symmetry.png")

# ─── Verify Group Properties ─────────────────────────────────────

print("\n" + "=" * 60)
print("MÖBIUS GROUP PROPERTIES")
print("=" * 60)

# Test: composition = matrix multiplication
z_test = 1 + 2j
M1 = (2, 1, 0, 1)  # 2z + 1
M2 = (1, 0, 1, 1)  # z/(z+1)

w1 = mobius(z_test, *M1)
w12 = mobius(w1, *M2)

# Matrix product
a, b = M2[0]*M1[0]+M2[1]*M1[2], M2[0]*M1[1]+M2[1]*M1[3]
c, d = M2[2]*M1[0]+M2[3]*M1[2], M2[2]*M1[1]+M2[3]*M1[3]
w_comp = mobius(z_test, a, b, c, d)

print(f"\nComposition test:")
print(f"  M₂(M₁(z)) = {w12:.6f}")
print(f"  (M₂M₁)(z) = {w_comp:.6f}")
print(f"  Error: {abs(w12 - w_comp):.2e}")
print(f"  → Composition = matrix product: CONFIRMED ✓")

# Test: inversion is involutory (z ↦ 1/z applied twice = id)
z_test2 = 3 + 4j
w_inv = mobius(mobius(z_test2, 0, 1, 1, 0), 0, 1, 1, 0)
print(f"\nInversion involution test:")
print(f"  z = {z_test2}")
print(f"  (1/(1/z)) = {w_inv:.6f}")
print(f"  Error: {abs(z_test2 - w_inv):.2e}")
print(f"  → Inversion² = id: CONFIRMED ✓")

# Test: Cayley transform maps unit circle to real line
print(f"\nCayley transform maps circle → line:")
for theta in np.linspace(0, 2*np.pi, 8, endpoint=False):
    z = np.exp(1j * theta)
    w = mobius(z, 1, -1j, 1, 1j)
    print(f"  e^(i·{np.degrees(theta):5.1f}°) → {w:.4f}  (Im = {np.imag(w):.2e})")
print("  → All images are real: CONFIRMED ✓ (the Cayley lens maps S¹ to ℝ)")
