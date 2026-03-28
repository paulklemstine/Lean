#!/usr/bin/env python3
"""
Demo 2: Integer-Pole Stereographic Projection

Visualizes:
1. The (n,m)-chart map T_{n,m}(z) = (nz + m)/(z + 1)
2. How different pole assignments distort the coordinate grid
3. The crystallization lattice for different (n,m) pairs
4. The transition map between charts

Run: python3 demo_integer_poles.py
Output: integer_poles.png, transition_maps.png, crystallization.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# --- Core Functions ---

def T_nm(z, n, m):
    """Integer-pole chart map: T_{n,m}(z) = (nz + m) / (z + 1)."""
    return (n * z + m) / (z + 1)

def T_nm_inv(w, n, m):
    """Inverse: T_{n,m}^{-1}(w) = (w - m) / (n - w)."""
    return (w - m) / (n - w)

def transition_map(w, n1, m1, n2, m2):
    """Transition from (n1,m1)-chart to (n2,m2)-chart."""
    scale = (n2 - m2) / (n1 - m1)
    shift = (m2 * n1 - n2 * m1) / (n1 - m1)
    return scale * w + shift

def inv_stereo(t):
    """Inverse stereographic projection: ℝ → S¹."""
    x = 2 * t / (1 + t**2)
    y = (1 - t**2) / (1 + t**2)
    return x, y

# --- Figure 1: Integer Pole Charts ---

fig = plt.figure(figsize=(18, 14))
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

charts = [
    (0, 0, "Standard (∞, 0)"),
    (1, 0, "Chart (1, 0)"),
    (0, 1, "Chart (0, 1)"),
    (2, 3, "Chart (2, 3)"),
    (5, -5, "Chart (5, -5)"),
    (7, 3, "Chart (7, 3)"),
]

z_vals = np.linspace(-10, 10, 1000)

for idx, (n, m, title) in enumerate(charts):
    ax = fig.add_subplot(gs[idx // 3, idx % 3])

    if n == 0 and m == 0:
        # Standard chart: just plot identity
        w_vals = z_vals.copy()
        ax.plot(z_vals, w_vals, 'b-', linewidth=2)
        ax.axhline(y=0, color='green', linestyle='--', alpha=0.7, label='South Pole → 0')
        ax.set_ylabel('w = z', fontsize=10)
    else:
        # Compute T_{n,m}(z), avoiding the pole at z = -1
        mask = np.abs(z_vals + 1) > 0.1
        z_safe = z_vals[mask]
        w_vals = T_nm(z_safe, n, m)

        # Clip for visualization
        w_clip = np.clip(w_vals, -20, 20)
        ax.plot(z_safe, w_clip, 'b-', linewidth=2)

        ax.axhline(y=n, color='red', linestyle='--', alpha=0.7, label=f'N Pole → {n}')
        ax.axhline(y=m, color='green', linestyle='--', alpha=0.7, label=f'S Pole → {m}')
        if n != m:
            ax.axhline(y=(n+m)/2, color='purple', linestyle=':', alpha=0.7, label=f'Equator → {(n+m)/2}')
        ax.set_ylabel(f'w = T({n},{m})(z)', fontsize=10)

    # Mark integer inputs
    for k in range(-5, 6):
        if n == 0 and m == 0:
            w_k = k
        elif abs(k + 1) > 0.01:
            w_k = T_nm(k, n, m)
        else:
            continue
        if abs(w_k) < 20:
            ax.plot(k, w_k, 'ko', markersize=5, zorder=5)

    ax.axvline(x=-1, color='gray', linestyle=':', alpha=0.5, label='Pole (z=-1)')
    ax.set_xlabel('z (standard coord)', fontsize=10)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-6, 6)
    ax.set_ylim(-15, 15)
    ax.legend(fontsize=7, loc='upper left')
    ax.grid(True, alpha=0.3)

plt.suptitle('Integer-Pole Stereographic Charts: T(n,m)(z) = (nz + m)/(z + 1)',
             fontsize=16, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/demos/integer_poles.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved integer_poles.png")

# --- Figure 2: Transition Maps Between Charts ---

fig2 = plt.figure(figsize=(16, 12))
gs2 = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

transitions = [
    ((0, 1), (2, 3), "Universe(0,1) → Universe(2,3)"),
    ((1, 0), (5, -5), "Universe(1,0) → Universe(5,-5)"),
    ((3, 7), (7, 3), "Universe(3,7) → Universe(7,3) [DUAL]"),
    ((1, -1), (10, -10), "Universe(1,-1) → Universe(10,-10)"),
]

for idx, ((n1, m1), (n2, m2), title) in enumerate(transitions):
    ax = fig2.add_subplot(gs2[idx // 2, idx % 2])

    w1_vals = np.linspace(-10, 10, 500)
    w2_vals = transition_map(w1_vals, n1, m1, n2, m2)

    scale = (n2 - m2) / (n1 - m1)
    shift = (m2 * n1 - n2 * m1) / (n1 - m1)

    ax.plot(w1_vals, w2_vals, 'b-', linewidth=2,
            label=f'w₂ = {scale:.2f}·w₁ + {shift:.2f}')
    ax.plot([-10, 10], [-10, 10], 'k--', alpha=0.3, label='Identity')

    # Mark integer-to-integer mappings
    for k in range(-8, 9):
        w2 = transition_map(k, n1, m1, n2, m2)
        if abs(w2) < 15:
            color = 'red' if abs(w2 - round(w2)) < 0.01 else 'gray'
            ax.plot(k, w2, 'o', color=color, markersize=6, zorder=5)
            if abs(w2 - round(w2)) < 0.01 and abs(k) <= 5:
                ax.annotate(f'{k}→{int(round(w2))}', (k, w2), fontsize=7,
                           xytext=(5, 5), textcoords='offset points')

    # Highlight self-dual point if it exists
    if abs(scale - 1) > 1e-10:
        fixed = shift / (1 - scale)
        if abs(fixed) < 10:
            ax.plot(fixed, fixed, 'g*', markersize=15, label=f'Fixed point = {fixed:.2f}', zorder=6)

    ax.set_xlabel(f'w₁ in Universe({n1},{m1})', fontsize=10)
    ax.set_ylabel(f'w₂ in Universe({n2},{m2})', fontsize=10)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-10, 10)
    ax.set_ylim(-15, 15)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Transition Maps Between Integer-Pole Universes\n(All are affine: w₂ = λ·w₁ + τ)',
             fontsize=14, fontweight='bold', y=0.99)
plt.savefig('/workspace/request-project/demos/transition_maps.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved transition_maps.png")

# --- Figure 3: Crystallization Patterns ---

fig3 = plt.figure(figsize=(16, 12))
gs3 = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

crystal_charts = [
    (1, 0, "Crystal Lattice (1, 0)"),
    (2, 3, "Crystal Lattice (2, 3)"),
    (7, 3, "Crystal Lattice (7, 3)"),
    (5, -5, "Crystal Lattice (5, -5)"),
]

theta = np.linspace(0, 2*np.pi, 200)

for idx, (n, m, title) in enumerate(crystal_charts):
    ax = fig3.add_subplot(gs3[idx // 2, idx % 2])
    ax.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=1.5, alpha=0.5)

    # Compute crystal points: w_k = (nk + m)/(k + 1) for k ∈ ℤ
    crystal_points = []
    for k in range(-20, 21):
        if k == -1:
            continue  # pole
        w_k = (n * k + m) / (k + 1)
        crystal_points.append((k, w_k))

    # Map crystal points to the circle via inverse stereo
    for k, w_k in crystal_points:
        # Use standard inverse stereo on w_k (treating as real parameter)
        cx, cy = inv_stereo(w_k)
        size = max(3, 12 - abs(k) * 0.5)
        alpha = max(0.3, 1.0 - abs(k) * 0.04)
        color = plt.cm.coolwarm(0.5 + k / 40)
        ax.plot(cx, cy, 'o', color=color, markersize=size, alpha=alpha, zorder=5)
        if abs(k) <= 3 and k != -1:
            ax.annotate(f'k={k}\nw={w_k:.1f}', (cx*1.2, cy*1.2), fontsize=6,
                       ha='center', va='center')

    # Mark poles
    ax.plot(0, 1, 'rs', markersize=12, label=f'S Pole (m={m})', zorder=6)
    ax.plot(0, -1, 'r^', markersize=12, label=f'N Pole (n={n})', zorder=6)

    ax.set_xlim(-1.7, 1.7)
    ax.set_ylim(-1.7, 1.7)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

plt.suptitle('Crystallization: Integer Parameters Map to Discrete Lattice on S¹',
             fontsize=14, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/demos/crystallization.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved crystallization.png")
