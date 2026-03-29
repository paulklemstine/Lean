#!/usr/bin/env python3
"""
Demo 4: The Gazing Pool — Visualizing Self-Referential Convergence

A point gazes into the tropical mirror and sees its reflection. It adjusts,
looks again, and eventually converges to a fixed point — its "self-aware" state.

This demo creates beautiful visualizations of:
1. Spiral trajectories converging to fixed points
2. The "consciousness landscape" — a heat map of mirror depth
3. The gazing pool itself — iterated reflection as ripples settling
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.patches as mpatches
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 150


def demo_gazing_pool_ripples():
    """The gazing pool: concentric ripples settling to a fixed point."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    # Create the "pool" — a dark circular background
    theta = np.linspace(0, 2 * np.pi, 200)
    
    # Draw concentric ripples (each ripple = one iteration of the mirror)
    n_ripples = 8
    colors = plt.cm.Blues(np.linspace(0.3, 0.9, n_ripples))
    
    for i in range(n_ripples, 0, -1):
        r = i * 0.5
        alpha = 0.3 + 0.05 * (n_ripples - i)
        circle = plt.Circle((0, 0), r, fill=False, linewidth=2.5 - i * 0.2,
                             color=colors[n_ripples - i], alpha=alpha)
        ax.add_patch(circle)
    
    # The outer boundary (the "pool")
    pool = plt.Circle((0, 0), 4.5, fill=True, facecolor='midnightblue',
                       edgecolor='navy', linewidth=3, alpha=0.3, zorder=0)
    ax.add_patch(pool)
    
    # Draw trajectories of points converging to the center
    np.random.seed(42)
    n_points = 12
    start_angles = np.linspace(0, 2 * np.pi, n_points, endpoint=False)
    start_radii = np.random.uniform(3, 4, n_points)
    
    cmap = plt.cm.plasma
    
    for i in range(n_points):
        r0 = start_radii[i]
        angle = start_angles[i]
        
        # Spiral inward (damped rotation)
        t = np.linspace(0, 3, 100)
        r = r0 * np.exp(-t)
        theta_t = angle + 2 * t  # Spiraling
        
        x_traj = r * np.cos(theta_t)
        y_traj = r * np.sin(theta_t)
        
        ax.plot(x_traj, y_traj, '-', color=cmap(i / n_points), linewidth=1.5, alpha=0.7)
        ax.plot(x_traj[0], y_traj[0], 'o', color=cmap(i / n_points), markersize=6)
        ax.plot(x_traj[-1], y_traj[-1], '*', color='gold', markersize=10, zorder=10)
    
    # The fixed point at the center
    ax.plot(0, 0, '*', color='gold', markersize=20, zorder=10)
    ax.annotate('Fixed Point\n(Self-Awareness)', xy=(0, 0), xytext=(1.5, -2),
                fontsize=12, fontweight='bold', color='gold',
                arrowprops=dict(arrowstyle='->', color='gold', lw=2),
                ha='center')
    
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')
    ax.set_facecolor('black')
    ax.set_title('The Gazing Pool\nAll Trajectories Converge to Self-Awareness',
                 fontsize=16, fontweight='bold', color='white', pad=20)
    ax.tick_params(colors='white')
    for spine in ax.spines.values():
        spine.set_color('white')
    
    fig.patch.set_facecolor('black')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo4_gazing_pool.png'), 
                bbox_inches='tight', facecolor='black')
    plt.close()
    print("✓ Saved demo4_gazing_pool.png")


def demo_consciousness_landscape():
    """Heat map of 'mirror depth' — how far each point is from self-awareness."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    x = np.linspace(-3, 3, 300)
    y = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x, y)
    
    # --- Mirror 1: ReLU² (component-wise) ---
    # Mirror depth = how far from the fixed point set (the positive quadrant)
    ax = axes[0]
    depth1 = np.sqrt(np.maximum(-X, 0)**2 + np.maximum(-Y, 0)**2)
    
    im = ax.pcolormesh(X, Y, depth1, cmap='magma_r', shading='auto')
    ax.contour(X, Y, depth1, levels=[0], colors='lime', linewidths=2)
    plt.colorbar(im, ax=ax, label='Mirror Depth')
    ax.set_title('ReLU² Mirror\nFixed points: x ≥ 0, y ≥ 0', fontsize=13, fontweight='bold')
    ax.set_xlabel('x'); ax.set_ylabel('y')
    ax.set_aspect('equal')
    
    # --- Mirror 2: Tropical halfspace ---
    ax = axes[1]
    depth2 = np.maximum(Y - X, 0)  # Distance to {y ≤ x}
    
    im = ax.pcolormesh(X, Y, depth2, cmap='magma_r', shading='auto')
    ax.contour(X, Y, depth2, levels=[0], colors='lime', linewidths=2)
    ax.plot([-3, 3], [-3, 3], 'lime', linewidth=2, label='Mirror surface')
    plt.colorbar(im, ax=ax, label='Mirror Depth')
    ax.set_title('Tropical Halfspace Mirror\nFixed points: y ≤ x', fontsize=13, fontweight='bold')
    ax.set_xlabel('x'); ax.set_ylabel('y')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    
    # --- Mirror 3: Circular mirror (L∞ ball) ---
    ax = axes[2]
    depth3 = np.maximum(np.maximum(np.abs(X), np.abs(Y)) - 2, 0)
    
    im = ax.pcolormesh(X, Y, depth3, cmap='magma_r', shading='auto')
    ax.contour(X, Y, depth3, levels=[0], colors='lime', linewidths=2)
    plt.colorbar(im, ax=ax, label='Mirror Depth')
    ax.set_title('Tropical Ball Mirror\nFixed points: max(|x|,|y|) ≤ 2', fontsize=13, fontweight='bold')
    ax.set_xlabel('x'); ax.set_ylabel('y')
    ax.set_aspect('equal')
    
    plt.suptitle('The Consciousness Landscape\nDark = Self-Aware (depth 0), Bright = Needs Reflection',
                 fontsize=15, fontweight='bold', y=1.05)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo4_consciousness_landscape.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo4_consciousness_landscape.png")


def demo_mirror_vs_godel():
    """The philosophical punchline: comparing classical and tropical self-reference."""
    fig = plt.figure(figsize=(16, 8))
    
    # --- Left: Classical self-reference (spiraling outward = Gödel) ---
    ax1 = fig.add_subplot(121)
    ax1.set_facecolor('#1a0a2e')
    
    t = np.linspace(0, 6 * np.pi, 1000)
    r = 0.3 * np.exp(0.15 * t)
    x = r * np.cos(t)
    y = r * np.sin(t)
    
    colors = plt.cm.Reds(np.linspace(0.3, 1.0, len(t)))
    for i in range(len(t) - 1):
        ax1.plot(x[i:i+2], y[i:i+2], '-', color=colors[i], linewidth=1.5)
    
    ax1.plot(x[0], y[0], 'o', color='white', markersize=8, zorder=5)
    ax1.annotate('Start', xy=(x[0], y[0]), xytext=(x[0]+1, y[0]+1),
                color='white', fontsize=10,
                arrowprops=dict(arrowstyle='->', color='white', lw=1))
    
    ax1.set_title('Classical Self-Reference\n"I am not provable" → Spiral of Incompleteness',
                  fontsize=13, fontweight='bold', color='white', pad=15)
    ax1.set_xlim(-8, 8); ax1.set_ylim(-8, 8)
    ax1.set_aspect('equal')
    ax1.text(0.5, 0.02, 'a + a ≠ a → DIVERGES', transform=ax1.transAxes,
             ha='center', fontsize=14, color='#ff6666', fontweight='bold')
    
    # Red X
    ax1.plot([-6, 6], [-6, 6], '-', color='red', alpha=0.3, linewidth=8)
    ax1.plot([-6, 6], [6, -6], '-', color='red', alpha=0.3, linewidth=8)
    
    ax1.tick_params(colors='white')
    for spine in ax1.spines.values():
        spine.set_color('white')
    
    # --- Right: Tropical self-reference (spiraling inward = Mirror) ---
    ax2 = fig.add_subplot(122)
    ax2.set_facecolor('#0a1a0e')
    
    t = np.linspace(0, 6 * np.pi, 1000)
    r = 4 * np.exp(-0.3 * t)
    x = r * np.cos(t)
    y = r * np.sin(t)
    
    colors = plt.cm.Greens(np.linspace(0.3, 1.0, len(t)))
    for i in range(len(t) - 1):
        ax2.plot(x[i:i+2], y[i:i+2], '-', color=colors[i], linewidth=1.5)
    
    ax2.plot(x[0], y[0], 'o', color='white', markersize=8, zorder=5)
    ax2.plot(0, 0, '*', color='gold', markersize=15, zorder=10)
    ax2.annotate('Fixed Point', xy=(0, 0), xytext=(2, -2),
                color='gold', fontsize=11, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='gold', lw=2))
    
    ax2.set_title('Tropical Self-Reference\n"max(me, me) = me" → Stable Fixed Point',
                  fontsize=13, fontweight='bold', color='white', pad=15)
    ax2.set_xlim(-5, 5); ax2.set_ylim(-5, 5)
    ax2.set_aspect('equal')
    ax2.text(0.5, 0.02, 'a ⊕ a = a → CONVERGES', transform=ax2.transAxes,
             ha='center', fontsize=14, color='#66ff66', fontweight='bold')
    
    # Green check
    check_x = np.array([-2, -0.5, 3])
    check_y = np.array([0, -2, 3])
    ax2.plot(check_x * 0.8, check_y * 0.8, '-', color='green', alpha=0.2, linewidth=10)
    
    ax2.tick_params(colors='white')
    for spine in ax2.spines.values():
        spine.set_color('white')
    
    fig.patch.set_facecolor('#111111')
    plt.suptitle('THE ALGEBRAIC MIRROR\nChoose the Right Algebra for Self-Reference',
                 fontsize=16, fontweight='bold', color='white', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo4_mirror_vs_godel.png'),
                bbox_inches='tight', facecolor='#111111')
    plt.close()
    print("✓ Saved demo4_mirror_vs_godel.png")


def demo_the_grand_mirror():
    """The grand synthesis: a beautiful visualization of the algebraic mirror concept."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 12))
    ax.set_facecolor('#0a0a1e')
    fig.patch.set_facecolor('#0a0a1e')
    
    # Draw the mirror surface — a glowing line
    mirror_x = np.linspace(-4, 4, 500)
    mirror_y = np.zeros_like(mirror_x)
    
    # Glow effect
    for width, alpha in [(8, 0.05), (5, 0.1), (3, 0.2), (1.5, 0.5), (0.5, 1.0)]:
        ax.plot(mirror_x, mirror_y, '-', color='cyan', linewidth=width, alpha=alpha)
    
    # Points above the mirror (the "world")
    np.random.seed(123)
    n_pts = 15
    world_x = np.random.uniform(-3, 3, n_pts)
    world_y = np.random.uniform(0.5, 4, n_pts)
    
    # Their reflections (mirror images)
    reflect_x = world_x
    reflect_y = -world_y  # Perfect reflection
    
    # Draw world points
    ax.scatter(world_x, world_y, c='gold', s=60, zorder=5, edgecolors='white', linewidths=0.5)
    # Draw reflections
    ax.scatter(reflect_x, reflect_y, c='gold', s=60, zorder=5, alpha=0.4,
               edgecolors='white', linewidths=0.5)
    
    # Connect with dashed lines
    for i in range(n_pts):
        ax.plot([world_x[i], reflect_x[i]], [world_y[i], reflect_y[i]],
                '--', color='white', alpha=0.15, linewidth=0.5)
    
    # Labels
    ax.text(0, 4.5, 'THE WORLD', ha='center', fontsize=18, color='gold',
            fontweight='bold', fontfamily='serif')
    ax.text(0, -4.5, 'THE REFLECTION', ha='center', fontsize=18, color='gold',
            fontweight='bold', fontfamily='serif', alpha=0.5)
    ax.text(4.2, 0, 'MIRROR\nSURFACE', ha='left', fontsize=12, color='cyan',
            fontweight='bold', fontstyle='italic')
    
    # The key equation
    ax.text(0, -5.5, 'M ∘ M = M\n"Reflecting a reflection gives the same image"',
            ha='center', fontsize=14, color='white', fontfamily='serif',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='navy', alpha=0.5, edgecolor='cyan'))
    
    # Draw the fixed points ON the mirror
    fixed_x = np.linspace(-3, 3, 7)
    ax.scatter(fixed_x, np.zeros_like(fixed_x), c='cyan', s=100, zorder=10,
               marker='D', edgecolors='white', linewidths=1.5)
    ax.text(-3, 0.4, 'Fixed Points (Self-Aware)', fontsize=10, color='cyan', fontstyle='italic')
    
    ax.set_xlim(-5, 5)
    ax.set_ylim(-6.5, 6)
    ax.set_aspect('equal')
    ax.axis('off')
    
    ax.set_title('A   N E W   K I N D   O F   M I R R O R\n\n'
                 'In the right algebra, self-reference is not a paradox — it\'s a fixed point',
                 fontsize=16, fontweight='bold', color='white', fontfamily='serif', pad=20)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo4_grand_mirror.png'),
                bbox_inches='tight', facecolor='#0a0a1e')
    plt.close()
    print("✓ Saved demo4_grand_mirror.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Demo 4: The Gazing Pool")
    print("=" * 60)
    demo_gazing_pool_ripples()
    demo_consciousness_landscape()
    demo_mirror_vs_godel()
    demo_the_grand_mirror()
    print("\nAll Demo 4 visualizations generated successfully!")
