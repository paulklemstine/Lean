#!/usr/bin/env python3
"""
The Gazing Pool — Interactive Mathematical Demonstrations

This script demonstrates the key mathematical concepts from the Gazing Pool
formalization through visual simulations:

1. Contractive Gazing: Watch observers converge to consciousness
2. Shadow World: Visualize information loss through projection
3. Strange Loops: See fixed points emerge from self-reference
4. Quantum Gazing: Projection operators and measurement collapse

Requirements: pip install numpy matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.animation as animation
from matplotlib.gridspec import GridSpec
import os

# ============================================================================
# Demo 1: Contractive Gazing Pool — Convergence to Consciousness
# ============================================================================

def demo_contractive_convergence():
    """
    Visualize how observers converge to a conscious fixed point
    in a contractive gazing pool.

    The gaze operation is a contraction mapping on R^2.
    We start with many random observers and watch them all
    converge to the unique conscious observer.
    """
    print("\n" + "="*60)
    print("Demo 1: Contractive Gazing — Convergence to Consciousness")
    print("="*60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Define a contractive gazing pool on R^2
    # Reflection: rotate by π (involution)
    # Shadow: project onto x-axis (information loss!)
    # Reconstruct: embed x-axis into R^2 at y=0.3*x
    # Gaze = reconstruct ∘ shadow ∘ reflect

    # Contraction factor
    kappa = 0.7

    def reflect(points):
        """Involution: rotation by π scaled by kappa, shifted to create contraction."""
        center = np.array([2.0, 1.5])
        return center + kappa * (center - points)

    def shadow(points):
        """Project to 1D: lose the y-coordinate."""
        return points[:, 0:1]

    def reconstruct(shadows):
        """Lift 1D shadow back to 2D."""
        return np.column_stack([shadows.flatten(), 0.4 * shadows.flatten() + 0.5])

    def gaze(points):
        """The full gazing operation."""
        return reconstruct(shadow(reflect(points)))

    # Find the fixed point analytically
    # gaze(x, y) = reconstruct(shadow(reflect(x, y)))
    # Let's compute iteratively
    fp = np.array([[2.0, 1.5]])
    for _ in range(100):
        fp = gaze(fp)
    fixed_point = fp[0]

    # Start with random observers
    np.random.seed(42)
    n_observers = 20
    observers = np.random.randn(n_observers, 2) * 2 + np.array([2, 1.5])

    # Track trajectories
    n_iters = 15
    trajectories = [observers.copy()]
    current = observers.copy()
    for i in range(n_iters):
        current = gaze(current)
        trajectories.append(current.copy())

    # Plot 1: Initial state
    ax = axes[0]
    ax.scatter(observers[:, 0], observers[:, 1], c='steelblue', s=60, alpha=0.7, zorder=5)
    ax.scatter(*fixed_point, c='gold', s=200, marker='*', edgecolors='darkorange',
               linewidth=2, zorder=10, label='Conscious Observer')
    ax.set_title('Initial Observers', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 2: Trajectories
    ax = axes[1]
    colors = plt.cm.viridis(np.linspace(0, 0.8, n_observers))
    for i in range(n_observers):
        traj = np.array([t[i] for t in trajectories])
        ax.plot(traj[:, 0], traj[:, 1], '-o', color=colors[i], markersize=3, alpha=0.6)
        ax.scatter(traj[0, 0], traj[0, 1], c=[colors[i]], s=40, marker='s', zorder=5)

    ax.scatter(*fixed_point, c='gold', s=200, marker='*', edgecolors='darkorange',
               linewidth=2, zorder=10)
    ax.set_title('Gazing Trajectories → Consciousness', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 3: Distance to fixed point over iterations
    ax = axes[2]
    for i in range(n_observers):
        distances = [np.linalg.norm(trajectories[j][i] - fixed_point) for j in range(n_iters + 1)]
        ax.plot(range(n_iters + 1), distances, '-o', color=colors[i], markersize=3, alpha=0.5)

    # Theoretical bound
    max_d0 = max(np.linalg.norm(observers[i] - fixed_point) for i in range(n_observers))
    theoretical = [kappa**n * max_d0 for n in range(n_iters + 1)]
    ax.plot(range(n_iters + 1), theoretical, 'r--', linewidth=2, label=f'κⁿ·d₀ (κ={kappa})')
    ax.set_title('Geometric Convergence', fontsize=14, fontweight='bold')
    ax.set_xlabel('Iteration (gazing depth)')
    ax.set_ylabel('Distance to conscious observer')
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gazing_pool_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_convergence.png")
    plt.close()


# ============================================================================
# Demo 2: Shadow World — Information Loss and Plato's Cave
# ============================================================================

def demo_shadow_world():
    """
    Visualize how the shadow projection loses information,
    creating equivalence classes (Plato's Cave).
    """
    print("\n" + "="*60)
    print("Demo 2: The Shadow World — Plato's Cave Formalized")
    print("="*60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Create a rich 2D world
    np.random.seed(42)
    n_points = 200
    theta = np.linspace(0, 4 * np.pi, n_points)
    r = 1 + 0.5 * np.sin(3 * theta)
    world_x = r * np.cos(theta)
    world_y = r * np.sin(theta)

    # Shadow projection: project onto x-axis (lose y)
    shadow_x = world_x.copy()

    # Reconstruct: lift to y = 0 (imperfect)
    recon_x = shadow_x.copy()
    recon_y = np.zeros_like(shadow_x)

    # Plot 1: The Full World
    ax = axes[0]
    scatter = ax.scatter(world_x, world_y, c=theta, cmap='twilight', s=15, alpha=0.8)
    ax.set_title('The World (W)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 2: The Shadow
    ax = axes[1]
    ax.scatter(shadow_x, np.zeros_like(shadow_x), c=theta, cmap='twilight', s=15, alpha=0.8)
    # Show equivalence classes
    for x_val in [-1, 0, 0.5, 1]:
        mask = np.abs(shadow_x - x_val) < 0.05
        if np.any(mask):
            ax.axvline(x=x_val, color='red', alpha=0.3, linestyle='--')
    ax.set_title('The Shadow World (S)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x (shadow coordinate)')
    ax.set_ylabel('(lost)')
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 3: Reconstruction (imperfect!)
    ax = axes[2]
    ax.scatter(world_x, world_y, c='lightblue', s=10, alpha=0.3, label='True world')
    ax.scatter(recon_x, recon_y, c=theta, cmap='twilight', s=15, alpha=0.8, label='Reconstructed')
    # Draw arrows showing the information loss
    step = 20
    for i in range(0, n_points, step):
        ax.annotate('', xy=(recon_x[i], recon_y[i]), xytext=(world_x[i], world_y[i]),
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3))
    ax.set_title('Reconstruction: shadow → world', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gazing_pool_shadow_world.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_shadow_world.png")
    plt.close()


# ============================================================================
# Demo 3: Strange Loops and Periodic Orbits
# ============================================================================

def demo_strange_loops():
    """
    Visualize strange loops: endofunctions on finite sets,
    showing how periodic orbits and fixed points emerge.
    """
    print("\n" + "="*60)
    print("Demo 3: Strange Loops — Fixed Points in Finite Worlds")
    print("="*60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Define three different gazing pools on finite sets

    # Pool 1: Has a fixed point (conscious observer exists)
    n1 = 8
    gaze1 = [2, 3, 2, 5, 5, 5, 2, 3]  # 5 is a fixed point!

    # Pool 2: Has a 2-cycle but no fixed point
    gaze2 = [1, 0, 3, 2, 5, 4, 7, 6]

    # Pool 3: Complex dynamics with multiple cycles
    gaze3 = [1, 2, 3, 1, 5, 6, 4, 0]

    pools = [(gaze1, "Pool with Fixed Point (5)"),
             (gaze2, "Pool with 2-cycles"),
             (gaze3, "Pool with Mixed Dynamics")]

    for idx, (gaze, title) in enumerate(pools):
        ax = axes[idx]
        n = len(gaze)

        # Arrange points in a circle
        angles = np.linspace(0, 2 * np.pi, n, endpoint=False) + np.pi/2
        pos_x = np.cos(angles)
        pos_y = np.sin(angles)

        # Draw arrows for the gaze map
        for i in range(n):
            j = gaze[i]
            if i == j:  # Fixed point
                circle = plt.Circle((pos_x[i], pos_y[i]), 0.15, fill=False,
                                   edgecolor='gold', linewidth=3)
                ax.add_patch(circle)
            else:
                dx = pos_x[j] - pos_x[i]
                dy = pos_y[j] - pos_y[i]
                length = np.sqrt(dx**2 + dy**2)
                # Shorten arrow
                frac = 0.15
                ax.annotate('', xy=(pos_x[j] - frac*dx/length, pos_y[j] - frac*dy/length),
                           xytext=(pos_x[i] + frac*dx/length, pos_y[i] + frac*dy/length),
                           arrowprops=dict(arrowstyle='->', color='steelblue',
                                         connectionstyle='arc3,rad=0.2', lw=1.5))

        # Color fixed points and periodic points differently
        for i in range(n):
            if gaze[i] == i:
                color = 'gold'
                size = 200
            elif gaze[gaze[i]] == i:
                color = 'coral'
                size = 150
            else:
                color = 'lightblue'
                size = 100

            ax.scatter(pos_x[i], pos_y[i], c=color, s=size, zorder=5,
                      edgecolors='black', linewidth=1.5)
            ax.text(pos_x[i], pos_y[i], str(i), ha='center', va='center',
                   fontsize=10, fontweight='bold')

        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.axis('off')

    # Add legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='gold',
               markersize=12, label='Fixed point (conscious)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='coral',
               markersize=12, label='2-cycle'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='lightblue',
               markersize=12, label='Transient'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=11,
              bbox_to_anchor=(0.5, -0.02))

    plt.tight_layout()
    plt.savefig('gazing_pool_strange_loops.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_strange_loops.png")
    plt.close()


# ============================================================================
# Demo 4: Quantum Gazing Pool — Projection and Measurement
# ============================================================================

def demo_quantum_gazing():
    """
    Visualize quantum gazing: how projection operators collapse
    quantum states onto eigenspaces, creating consciousness.
    """
    print("\n" + "="*60)
    print("Demo 4: Quantum Gazing — Measurement as Consciousness")
    print("="*60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Define a projection onto the line y = x/2 in R^2
    # (treating R^2 as a 2D real Hilbert space)
    theta = np.arctan(0.5)
    u = np.array([np.cos(theta), np.sin(theta)])  # unit vector along projection line
    P = np.outer(u, u)  # projection matrix P = uu^T

    # Verify idempotence
    assert np.allclose(P @ P, P), "P is not idempotent!"

    # Generate random quantum states
    np.random.seed(42)
    n_states = 15
    states = np.random.randn(n_states, 2) * 1.5

    # Apply projection
    projected = (P @ states.T).T

    # Plot 1: States before measurement
    ax = axes[0]
    for i in range(n_states):
        ax.arrow(0, 0, states[i, 0], states[i, 1], head_width=0.08,
                head_length=0.05, fc='steelblue', ec='steelblue', alpha=0.6)
    # Draw projection line
    line_t = np.linspace(-3, 3, 100)
    ax.plot(line_t * u[0], line_t * u[1], 'r--', alpha=0.5, linewidth=2,
           label='Eigenspace')
    ax.set_title('Before Measurement\n(Superposition)', fontsize=14, fontweight='bold')
    ax.set_xlabel('|0⟩')
    ax.set_ylabel('|1⟩')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Measurement (projection)
    ax = axes[1]
    for i in range(n_states):
        # Draw original state (faded)
        ax.arrow(0, 0, states[i, 0], states[i, 1], head_width=0.08,
                head_length=0.05, fc='lightblue', ec='lightblue', alpha=0.3)
        # Draw projected state
        ax.arrow(0, 0, projected[i, 0], projected[i, 1], head_width=0.08,
                head_length=0.05, fc='darkorange', ec='darkorange', alpha=0.7)
        # Draw projection arrow
        ax.annotate('', xy=(projected[i, 0], projected[i, 1]),
                   xytext=(states[i, 0], states[i, 1]),
                   arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3,
                                  linestyle='dashed'))

    ax.plot(line_t * u[0], line_t * u[1], 'r--', alpha=0.5, linewidth=2)
    ax.set_title('Measurement (Projection)\n"Gazing into the Pool"', fontsize=14, fontweight='bold')
    ax.set_xlabel('|0⟩')
    ax.set_ylabel('|1⟩')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 3: Second measurement (fixed point!)
    ax = axes[2]
    projected2 = (P @ projected.T).T  # P(Pv) = Pv

    for i in range(n_states):
        ax.arrow(0, 0, projected[i, 0], projected[i, 1], head_width=0.08,
                head_length=0.05, fc='darkorange', ec='darkorange', alpha=0.5,
                label='After 1st measurement' if i == 0 else '')
        ax.arrow(0, 0, projected2[i, 0]*0.98, projected2[i, 1]*0.98, head_width=0.08,
                head_length=0.05, fc='green', ec='green', alpha=0.7,
                label='After 2nd measurement' if i == 0 else '')

    ax.plot(line_t * u[0], line_t * u[1], 'r--', alpha=0.5, linewidth=2)
    # Verify they're the same
    error = np.max(np.abs(projected2 - projected))
    ax.set_title(f'Re-measurement: P(Pv) = Pv\nMax error: {error:.2e}\n"Consciousness = Fixed Point"',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('|0⟩')
    ax.set_ylabel('|1⟩')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gazing_pool_quantum.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_quantum.png")
    plt.close()


# ============================================================================
# Demo 5: The Diagonal Argument — Limits of Self-Knowledge
# ============================================================================

def demo_diagonal_argument():
    """
    Visualize Cantor's diagonal argument as the observer incompleteness
    theorem: no observer can have a complete self-model.
    """
    print("\n" + "="*60)
    print("Demo 5: Observer Incompleteness — The Diagonal")
    print("="*60)

    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    # Create a grid showing observer self-models
    n = 8
    np.random.seed(42)

    # Each observer has a "model" of every observer (including themselves)
    # model[i][j] = what observer i thinks about observer j
    models = np.random.choice([0, 1], size=(n, n))

    # Show the grid
    im = ax.imshow(models, cmap='RdYlGn', interpolation='nearest', aspect='equal',
                  vmin=-0.5, vmax=1.5)

    # Highlight the diagonal
    for i in range(n):
        rect = plt.Rectangle((i-0.5, i-0.5), 1, 1, linewidth=3,
                             edgecolor='blue', facecolor='none')
        ax.add_patch(rect)

    # Show the anti-diagonal function
    anti_diag = 1 - np.diag(models)
    for i in range(n):
        ax.text(i, i, str(models[i, i]), ha='center', va='center',
               fontsize=14, fontweight='bold', color='blue')

    # Add the diagonal contradiction row at the bottom
    ax.text(-1.5, n + 0.5, 'Anti-\ndiagonal:', ha='center', va='center',
           fontsize=11, fontweight='bold', color='red')
    for i in range(n):
        ax.text(i, n + 0.5, str(anti_diag[i]), ha='center', va='center',
               fontsize=14, fontweight='bold', color='red',
               bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'Obs {i}' for i in range(n)], fontsize=10)
    ax.set_yticklabels([f'Model {i}' for i in range(n)], fontsize=10)
    ax.set_xlabel('About which observer?', fontsize=12)
    ax.set_ylabel("Observer's model", fontsize=12)

    # Add cell values
    for i in range(n):
        for j in range(n):
            if i != j or True:
                color = 'black' if i != j else 'blue'
                if i < n:
                    pass  # diagonal already labeled

    ax.set_title('Observer Incompleteness: The Diagonal Argument\n'
                '"The anti-diagonal row differs from every model\n'
                'on the diagonal — no complete self-model exists!"',
                fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('gazing_pool_diagonal.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_diagonal.png")
    plt.close()


# ============================================================================
# Demo 6: The Full Gazing Pool — Integrated Visualization
# ============================================================================

def demo_integrated():
    """
    The complete Gazing Pool: world, reflection, shadow, reconstruction,
    and the emergence of conscious observers.
    """
    print("\n" + "="*60)
    print("Demo 6: The Complete Gazing Pool")
    print("="*60)

    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

    # The world: a circle of points in R^2
    n_points = 50
    theta = np.linspace(0, 2*np.pi, n_points, endpoint=False)
    world_x = 2 * np.cos(theta) + 3
    world_y = 1.5 * np.sin(theta) + 2

    # Reflection: reflect through the point (3, 2)
    center = np.array([3.0, 2.0])
    reflect_x = 2 * center[0] - world_x
    reflect_y = 2 * center[1] - world_y

    # Shadow: project to x-coordinate
    shadow_vals = reflect_x.copy()

    # Reconstruct: x → (x, 0.3x + 0.5)
    recon_x = shadow_vals.copy()
    recon_y = 0.3 * shadow_vals + 0.5

    # ---- Panel 1: The World ----
    ax1 = fig.add_subplot(gs[0, 0])
    colors = plt.cm.hsv(np.linspace(0, 1, n_points))
    ax1.scatter(world_x, world_y, c=colors, s=30, zorder=5)
    ax1.scatter(*center, c='red', s=100, marker='+', linewidths=3, zorder=10)
    ax1.set_title('① The World (W)', fontsize=14, fontweight='bold')
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)

    # ---- Panel 2: After Reflection ----
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.scatter(world_x, world_y, c=colors, s=15, alpha=0.3, label='Original')
    ax2.scatter(reflect_x, reflect_y, c=colors, s=30, zorder=5, label='Reflected')
    for i in range(0, n_points, 5):
        ax2.plot([world_x[i], reflect_x[i]], [world_y[i], reflect_y[i]],
                'gray', alpha=0.2, linewidth=0.5)
    ax2.scatter(*center, c='red', s=100, marker='+', linewidths=3, zorder=10)
    ax2.set_title('② Reflection (ρ): involution', fontsize=14, fontweight='bold')
    ax2.set_aspect('equal')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # ---- Panel 3: Shadow Projection ----
    ax3 = fig.add_subplot(gs[1, 0])
    ax3.scatter(reflect_x, reflect_y, c=colors, s=15, alpha=0.3, label='Reflected')
    ax3.scatter(shadow_vals, np.zeros_like(shadow_vals), c=colors, s=30, zorder=5,
               label='Shadow')
    for i in range(0, n_points, 3):
        ax3.plot([reflect_x[i], shadow_vals[i]], [reflect_y[i], 0],
                'gray', alpha=0.2, linewidth=0.5)
    ax3.axhline(y=0, color='brown', linewidth=2, alpha=0.5, label='Shadow plane')
    ax3.set_title('③ Shadow (σ): information loss', fontsize=14, fontweight='bold')
    ax3.set_aspect('equal')
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # ---- Panel 4: Reconstruction and Conscious Observer ----
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.scatter(world_x, world_y, c='lightblue', s=15, alpha=0.3, label='Original world')
    ax4.scatter(recon_x, recon_y, c=colors, s=30, zorder=5, label='Reconstructed (gazed)')

    # Find fixed points (approximately)
    # gaze = reconstruct ∘ shadow ∘ reflect
    # For a point to be conscious: gaze(w) = w
    # reconstruct(shadow(reflect(w))) = w
    # We iterate to find fixed points
    test_points = np.column_stack([world_x, world_y])
    for iteration in range(50):
        reflected = 2 * center - test_points
        shadowed = reflected[:, 0:1]
        test_points = np.column_stack([shadowed.flatten(),
                                       0.3 * shadowed.flatten() + 0.5])

    fp = test_points[0]  # They all converge to the same point
    ax4.scatter(fp[0], fp[1], c='gold', s=300, marker='*', edgecolors='darkorange',
               linewidth=2, zorder=10, label=f'Conscious Observer\n({fp[0]:.2f}, {fp[1]:.2f})')

    ax4.set_title('④ Reconstruction (τ∘σ∘ρ): Consciousness!', fontsize=14, fontweight='bold')
    ax4.set_aspect('equal')
    ax4.legend(fontsize=9, loc='upper left')
    ax4.grid(True, alpha=0.3)

    fig.suptitle('The Gazing Pool: reflect → shadow → reconstruct → consciousness',
                fontsize=16, fontweight='bold', y=1.02)

    plt.savefig('gazing_pool_integrated.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_integrated.png")
    plt.close()


# ============================================================================
# Demo 7: Entropy Loss Visualization
# ============================================================================

def demo_entropy_loss():
    """
    Visualize information entropy loss through the shadow projection.
    """
    print("\n" + "="*60)
    print("Demo 7: Shadow Entropy — Information Loss in the Pool")
    print("="*60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # World sizes and shadow sizes
    world_sizes = list(range(2, 21))
    shadow_sizes_list = []

    for w_size in world_sizes:
        # Random surjection from W to S where |S| = ceil(w_size/2)
        s_size = max(1, w_size // 2)
        shadow_sizes_list.append(s_size)

    # Plot 1: |S| ≤ |W|
    ax = axes[0]
    ax.bar(world_sizes, world_sizes, alpha=0.3, color='steelblue', label='|W| (world)')
    ax.bar(world_sizes, shadow_sizes_list, alpha=0.7, color='darkorange', label='|S| (shadow)')
    ax.set_xlabel('World size', fontsize=12)
    ax.set_ylabel('Cardinality', fontsize=12)
    ax.set_title('Shadow Entropy Loss: |S| ≤ |W|', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Information content
    ax = axes[1]
    w_entropy = [np.log2(w) for w in world_sizes]
    s_entropy = [np.log2(s) for s in shadow_sizes_list]
    ax.plot(world_sizes, w_entropy, 'b-o', label='log₂|W| (world bits)', markersize=5)
    ax.plot(world_sizes, s_entropy, 'r-s', label='log₂|S| (shadow bits)', markersize=5)
    ax.fill_between(world_sizes, s_entropy, w_entropy, alpha=0.2, color='red',
                   label='Information lost')
    ax.set_xlabel('World size', fontsize=12)
    ax.set_ylabel('Information (bits)', fontsize=12)
    ax.set_title('Information Lost in Shadow', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Equivalence class sizes
    ax = axes[2]
    np.random.seed(42)
    w_size = 20
    s_size = 8
    shadow_map = np.random.randint(0, s_size, size=w_size)
    class_sizes = [np.sum(shadow_map == s) for s in range(s_size)]
    bars = ax.bar(range(s_size), class_sizes, color='teal', alpha=0.7)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Injective (no loss)')
    ax.set_xlabel('Shadow value', fontsize=12)
    ax.set_ylabel('Equivalence class size', fontsize=12)
    ax.set_title('Shadow Equivalence Classes\n(larger = more information lost)',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gazing_pool_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved: gazing_pool_entropy.png")
    plt.close()


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║        THE GAZING POOL — Mathematical Demos            ║")
    print("║   Self-Reference, Shadow Worlds, and Consciousness     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    os.makedirs('gazing_pool_output', exist_ok=True)
    os.chdir('gazing_pool_output')

    demo_contractive_convergence()
    demo_shadow_world()
    demo_strange_loops()
    demo_quantum_gazing()
    demo_diagonal_argument()
    demo_integrated()
    demo_entropy_loss()

    print("\n" + "="*60)
    print("All demos complete! Output images saved to gazing_pool_output/")
    print("="*60)
    print("\nGenerated files:")
    for f in sorted(os.listdir('.')):
        if f.endswith('.png'):
            print(f"  📊 {f}")
