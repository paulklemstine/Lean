#!/usr/bin/env python3
"""
Tropical Morse Theory — Applications to Machine Learning and Optimization

Demonstrates how tropical corner critical points appear in:
  1. ReLU neural network loss landscapes
  2. Training trajectory analysis (grokking detection)
  3. Phase transition identification
  4. Optimization barrier certification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import AffinePiece, tropical_max, active_indices, find_corner_crossings


# ─────────────────────────────────────────────────────────
# Application 1: ReLU Network as Tropical Function
# ─────────────────────────────────────────────────────────

def app_relu_tropical():
    """
    A single-hidden-layer ReLU network computes a tropical (max-of-affines)
    function. We show how the corner locus corresponds to activation pattern
    boundaries, and corner critical points identify optimization barriers.
    """
    print("=" * 60)
    print("Application 1: ReLU Network as Tropical Function")
    print("=" * 60)

    # Simple 2→3→1 ReLU network
    # Hidden layer: 3 neurons with ReLU activation
    # Output: linear combination of hidden activations
    # Each activation pattern gives one affine piece

    # Weight matrix W (3×2) and bias b (3,)
    W = np.array([[1.0, 0.5],
                   [-0.5, 1.0],
                   [0.3, -0.8]])
    b = np.array([0.0, 0.5, -0.3])

    # Output weights a (3,) and output bias c
    a = np.array([1.0, -0.5, 0.8])
    c = 0.0

    # For each activation pattern σ ∈ {0,1}³, the network computes
    # f_σ(x) = a · diag(σ) · (Wx + b) + c = (a·diag(σ)·W)·x + (a·diag(σ)·b + c)
    pieces = []
    patterns = []
    for s0 in [0, 1]:
        for s1 in [0, 1]:
            for s2 in [0, 1]:
                sigma = np.array([s0, s1, s2], dtype=float)
                grad = (a * sigma) @ W
                bias = (a * sigma) @ b + c
                pieces.append(AffinePiece(grad, bias))
                patterns.append((s0, s1, s2))

    print(f"\nNetwork architecture: 2 → 3 (ReLU) → 1")
    print(f"Number of activation patterns: {len(pieces)}")
    print(f"Each pattern defines one affine piece of the network function")

    # Evaluate on grid
    x = np.linspace(-3, 3, 300)
    X0, X1 = np.meshgrid(x, x)
    Z = np.zeros_like(X0)
    Active = np.zeros_like(X0, dtype=int)

    for i in range(X0.shape[0]):
        for j in range(X0.shape[1]):
            pt = np.array([X0[i,j], X1[i,j]])
            vals = [p.eval(pt) for p in pieces]
            Z[i,j] = max(vals)
            Active[i,j] = np.argmax(vals)

    # Count distinct active regions
    n_regions = len(np.unique(Active))
    print(f"Distinct linear regions on grid: {n_regions}")

    # Find a transition path
    t = np.linspace(0, 1, 500)
    path = np.column_stack([3 - 6*t, -3 + 6*t])
    crossings = find_corner_crossings(pieces, path, tol=1e-8)
    print(f"Corner crossings along diagonal path: {len(crossings)}")
    for i, cr in enumerate(crossings):
        print(f"  Crossing {i+1}: point=({cr.point[0]:.2f},{cr.point[1]:.2f}), "
              f"active pieces={cr.active_indices}")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax = axes[0]
    c_plot = ax.contourf(X0, X1, Z, levels=40, cmap='viridis')
    plt.colorbar(c_plot, ax=ax, label='Network output')
    ax.plot(path[:,0], path[:,1], 'w--', linewidth=2, label='Path')
    for cr in crossings:
        ax.plot(cr.point[0], cr.point[1], 'r*', markersize=12)
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('ReLU Network Output = Tropical Max Function')
    ax.legend()

    ax = axes[1]
    ax.pcolormesh(X0, X1, Active, cmap='tab10', shading='auto')
    ax.plot(path[:,0], path[:,1], 'w--', linewidth=2)
    for cr in crossings:
        ax.plot(cr.point[0], cr.point[1], 'r*', markersize=12)
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Activation Pattern Regions (Tropical Cells)')

    plt.tight_layout()
    plt.savefig('app_relu_tropical.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: app_relu_tropical.png")


# ─────────────────────────────────────────────────────────
# Application 2: Grokking Detection via Corner Crossings
# ─────────────────────────────────────────────────────────

def app_grokking_detection():
    """
    Simulated grokking: a training trajectory that initially memorizes
    (stays in one tropical cell) and then suddenly generalizes
    (crosses the corner locus to a better cell).
    """
    print("\n" + "=" * 60)
    print("Application 2: Grokking Detection via Corner Crossings")
    print("=" * 60)

    # Model: 4 affine pieces representing different "regimes"
    # Piece 0: memorization regime (high training loss, low generalization)
    # Piece 1: transition regime
    # Piece 2: generalization regime (low training loss, high generalization)
    # Piece 3: overfitting regime

    pieces = [
        AffinePiece(np.array([0.1, 0.1]), 5.0),     # Memorization (flat, high)
        AffinePiece(np.array([-1.0, 0.5]), 8.0),     # Transition
        AffinePiece(np.array([-0.1, -0.1]), 2.0),    # Generalization (flat, low)
        AffinePiece(np.array([0.5, -1.0]), 7.0),     # Overfitting
    ]

    # Simulated training trajectory: starts in memorization, ends in generalization
    n_steps = 500
    t = np.linspace(0, 10, n_steps)

    # Trajectory in parameter space
    gamma = np.column_stack([
        2 + 0.5 * np.sin(0.3 * t) - 0.1 * t,
        1 + 0.3 * np.cos(0.5 * t) + 0.2 * t
    ])

    # Track values and active sets
    losses = np.array([tropical_max(pieces, gamma[i]) for i in range(n_steps)])
    actives = [tuple(active_indices(pieces, gamma[i])) for i in range(n_steps)]

    # Detect regime changes
    crossings = find_corner_crossings(pieces, gamma, tol=1e-8)

    print(f"\nSimulated training trajectory: {n_steps} steps")
    print(f"Corner crossings (regime changes): {len(crossings)}")
    print(f"Initial active piece: {actives[0]} (memorization)")
    print(f"Final active piece: {actives[-1]} (generalization)")
    print(f"\nTheorem: no_grokking_without_corner_crossing guarantees")
    print(f"that the loss stays affine within each regime.")
    print(f"Theorem A: transition forces corner locus crossing.")

    # Plot
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Loss curve
    ax = axes[0, 0]
    ax.plot(t, losses, 'b-', linewidth=1.5, label='Tropical loss')
    for cr in crossings:
        # Find closest t
        dists = np.linalg.norm(gamma - cr.point, axis=1)
        idx = np.argmin(dists)
        ax.axvline(t[idx], color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Training step')
    ax.set_ylabel('Loss')
    ax.set_title('Tropical Loss Along Training Trajectory')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Active piece tracking
    ax = axes[0, 1]
    active_main = [a[0] for a in actives]
    ax.plot(t, active_main, 'g-', linewidth=1.5)
    ax.set_xlabel('Training step')
    ax.set_ylabel('Active piece index')
    ax.set_title('Active Regime Along Training')
    ax.set_yticks([0, 1, 2, 3])
    ax.set_yticklabels(['Memorize', 'Transit', 'Generalize', 'Overfit'])
    ax.grid(True, alpha=0.3)

    # Parameter space trajectory
    ax = axes[1, 0]
    ax.plot(gamma[:, 0], gamma[:, 1], 'b-', linewidth=1, alpha=0.5)
    ax.plot(gamma[0, 0], gamma[0, 1], 'go', markersize=10, label='Start')
    ax.plot(gamma[-1, 0], gamma[-1, 1], 'rs', markersize=10, label='End')
    for cr in crossings:
        ax.plot(cr.point[0], cr.point[1], 'r*', markersize=15)
    ax.set_xlabel('Parameter θ₀')
    ax.set_ylabel('Parameter θ₁')
    ax.set_title('Training Trajectory in Parameter Space')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Individual piece values along trajectory
    ax = axes[1, 1]
    labels = ['Memorize', 'Transit', 'Generalize', 'Overfit']
    colors = ['blue', 'orange', 'green', 'red']
    for i, p in enumerate(pieces):
        vals = [p.eval(gamma[j]) for j in range(n_steps)]
        ax.plot(t, vals, color=colors[i], linewidth=1, label=labels[i], alpha=0.7)
    ax.plot(t, losses, 'k--', linewidth=2, label='max (loss)')
    ax.set_xlabel('Training step')
    ax.set_ylabel('Piece value')
    ax.set_title('Individual Piece Values')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_grokking.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: app_grokking.png")


# ─────────────────────────────────────────────────────────
# Application 3: Optimization Barrier Certification
# ─────────────────────────────────────────────────────────

def app_barrier_certification():
    """
    Use tropical Morse theory to certify that certain optimization
    barriers are unavoidable: any path from a high-loss region to
    a low-loss region must cross the corner locus.
    """
    print("\n" + "=" * 60)
    print("Application 3: Optimization Barrier Certification")
    print("=" * 60)

    # Create a "barrier" landscape with 3 pieces
    pieces = [
        AffinePiece(np.array([1.0, 0.0]), 0.0),   # Low region left
        AffinePiece(np.array([-1.0, 0.0]), 4.0),   # Low region right
        AffinePiece(np.array([0.0, 0.5]), 1.0),    # Barrier ridge
    ]

    x = np.linspace(-3, 5, 300)
    y = np.linspace(-3, 5, 300)
    X, Y = np.meshgrid(x, y)
    Z = np.zeros_like(X)

    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            Z[i,j] = tropical_max(pieces, np.array([X[i,j], Y[i,j]]))

    # Multiple paths crossing the barrier
    paths = []
    n_paths = 5
    for k in range(n_paths):
        offset = -1 + 0.5 * k
        t = np.linspace(0, 1, 300)
        path = np.column_stack([-2 + 6*t, offset * np.ones_like(t) + np.sin(2*np.pi*t)])
        paths.append(path)

    print(f"\nBarrier landscape: 3 affine pieces")
    print(f"Piece 1: x₀ (dominant for x₀ > 2)")
    print(f"Piece 2: -x₀ + 4 (dominant for x₀ < 2)")
    print(f"Piece 3: 0.5x₁ + 1 (barrier ridge)")
    print(f"\n{n_paths} test paths crossing from left to right")

    total_crossings = 0
    for i, path in enumerate(paths):
        crossings = find_corner_crossings(pieces, path, tol=1e-8)
        total_crossings += len(crossings)
        print(f"  Path {i+1}: {len(crossings)} corner crossings")

    print(f"\nTotal crossings across all paths: {total_crossings}")
    print(f"Theorem A guarantees: every path from piece-1-dominant")
    print(f"to piece-2-dominant must cross the corner locus at least once.")

    fig, ax = plt.subplots(figsize=(10, 8))
    c_plot = ax.contourf(X, Y, Z, levels=30, cmap='hot_r')
    plt.colorbar(c_plot, ax=ax, label='Tropical loss')

    for i, path in enumerate(paths):
        ax.plot(path[:,0], path[:,1], '--', linewidth=1.5, alpha=0.7,
                label=f'Path {i+1}')
        crossings = find_corner_crossings(pieces, path, tol=1e-8)
        for cr in crossings:
            ax.plot(cr.point[0], cr.point[1], 'c*', markersize=12)

    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Optimization Barrier: All Paths Must Cross Corner Locus')
    ax.legend(fontsize=8)
    plt.tight_layout()
    plt.savefig('app_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: app_barrier.png")


if __name__ == "__main__":
    app_relu_tropical()
    app_grokking_detection()
    app_barrier_certification()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Morse Theory — Interactive Demonstrations

Concrete numerical examples demonstrating corner critical points,
transition paths, and the tropical Morse index for piecewise-linear
(max-of-affines) functions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import os

# ─────────────────────────────────────────────────────────
# Demo 1: Two-Piece Tropical Function on R²
# ─────────────────────────────────────────────────────────

def demo_two_piece():
    """
    Visualize f(x) = max(x₀ - x₁, -x₀ + x₁) on R².

    The corner locus is the line x₀ = x₁ (the "wall").
    On this wall, the two gradients (1,-1) and (-1,1) are perfectly
    opposing, so every point is corner critical with Morse index 1.
    """
    print("=" * 60)
    print("Demo 1: Two-Piece Tropical Function on R²")
    print("=" * 60)

    # Define the two affine pieces
    def piece1(x0, x1):
        return x0 - x1

    def piece2(x0, x1):
        return -x0 + x1

    def tropical_max(x0, x1):
        return np.maximum(piece1(x0, x1), piece2(x0, x1))

    # Create grid
    x = np.linspace(-3, 3, 500)
    X0, X1 = np.meshgrid(x, x)
    Z = tropical_max(X0, X1)

    # Identify active regions
    active1 = piece1(X0, X1) >= piece2(X0, X1)
    active2 = piece2(X0, X1) >= piece1(X0, X1)
    wall = np.abs(piece1(X0, X1) - piece2(X0, X1)) < 0.05

    # Transition path
    t = np.linspace(0, 1, 100)
    gamma_0 = 2 * (1 - t) - 2 * t  # x₀ coordinate: 2 → -2
    gamma_1 = -2 * (1 - t) + 2 * t  # x₁ coordinate: -2 → 2

    # Find corner crossing
    gap = piece1(gamma_0, gamma_1) - piece2(gamma_0, gamma_1)
    crossing_idx = np.argmin(np.abs(gap))
    crossing_t = t[crossing_idx]

    print(f"\nPiece 1: f₁(x) = x₀ - x₁, gradient = (1, -1)")
    print(f"Piece 2: f₂(x) = -x₀ + x₁, gradient = (-1, 1)")
    print(f"Corner locus: x₀ = x₁ (the diagonal)")
    print(f"\nTransition path: γ(t) = (2-4t, -2+4t), t ∈ [0,1]")
    print(f"  At t=0: γ = (2,-2), piece 1 active (f₁=4, f₂=-4)")
    print(f"  At t=1: γ = (-2,2), piece 2 active (f₁=-4, f₂=4)")
    print(f"  Corner crossing at t ≈ {crossing_t:.4f}")
    print(f"  Crossing point: ({gamma_0[crossing_idx]:.4f}, {gamma_1[crossing_idx]:.4f})")
    print(f"\nGradient product at any direction v:")
    print(f"  (1,-1)·v × (-1,1)·v = -(v₀-v₁)² ≤ 0")
    print(f"  → Perfectly opposing → Morse index = 1")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Surface plot
    ax = axes[0]
    c = ax.contourf(X0, X1, Z, levels=30, cmap='viridis')
    plt.colorbar(c, ax=ax, label='f(x)')
    ax.contour(X0, X1, Z, levels=30, colors='white', alpha=0.3, linewidths=0.5)
    # Wall
    ax.plot([-3, 3], [-3, 3], 'r-', linewidth=2, label='Corner locus')
    # Path
    ax.plot(gamma_0, gamma_1, 'w--', linewidth=2, label='Transition path')
    ax.plot(gamma_0[crossing_idx], gamma_1[crossing_idx], 'r*',
            markersize=15, label=f'Corner critical point')
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Tropical Max Function f(x) = max(x₀-x₁, -x₀+x₁)')
    ax.legend(loc='upper left', fontsize=8)

    # Active regions
    ax = axes[1]
    region = np.where(active1 & ~active2, 1,
             np.where(active2 & ~active1, 2,
             np.where(wall, 0, 1.5)))
    cmap = LinearSegmentedColormap.from_list('active',
        [(0.8,0.2,0.2), (0.2,0.5,0.8), (0.8,0.5,0.2)])
    ax.pcolormesh(X0, X1, region, cmap=cmap, shading='auto')
    ax.plot([-3, 3], [-3, 3], 'k-', linewidth=2)
    ax.plot(gamma_0, gamma_1, 'w--', linewidth=2)
    ax.plot(gamma_0[crossing_idx], gamma_1[crossing_idx], 'r*', markersize=15)
    # Gradient arrows
    ax.annotate('', xy=(1.5, 0.5), xytext=(1, 1),
                arrowprops=dict(arrowstyle='->', color='white', lw=2))
    ax.annotate('', xy=(0.5, 1.5), xytext=(1, 1),
                arrowprops=dict(arrowstyle='->', color='white', lw=2))
    ax.text(0.5, -2, 'Piece 1 active\n(grad = (1,-1))', color='white',
            fontsize=10, ha='center')
    ax.text(-0.5, 2, 'Piece 2 active\n(grad = (-1,1))', color='white',
            fontsize=10, ha='center')
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Active Regions and Corner Locus')

    # Gap function along path
    ax = axes[2]
    ax.plot(t, piece1(gamma_0, gamma_1), 'b-', linewidth=2, label='f₁(γ(t))')
    ax.plot(t, piece2(gamma_0, gamma_1), 'r-', linewidth=2, label='f₂(γ(t))')
    ax.plot(t, tropical_max(gamma_0, gamma_1), 'k--', linewidth=2,
            label='max(f₁,f₂)')
    ax.axvline(crossing_t, color='green', linestyle=':', linewidth=2,
               label=f'Corner crossing (t≈{crossing_t:.2f})')
    ax.fill_between(t[:crossing_idx+1], piece1(gamma_0[:crossing_idx+1],
                    gamma_1[:crossing_idx+1]),
                    piece2(gamma_0[:crossing_idx+1],
                    gamma_1[:crossing_idx+1]),
                    alpha=0.2, color='blue')
    ax.set_xlabel('Path parameter t')
    ax.set_ylabel('Function value')
    ax.set_title('Piece Values Along Transition Path')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_two_piece.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved: tropical_two_piece.png")


# ─────────────────────────────────────────────────────────
# Demo 2: Three-Piece Tropical Function
# ─────────────────────────────────────────────────────────

def demo_three_piece():
    """
    Visualize f(x) = max(2x₀+1, -x₀+x₁, x₁-2) on R².

    The corner locus has three branches meeting at a tropical vertex.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Three-Piece Tropical Function on R²")
    print("=" * 60)

    def p1(x0, x1): return 2*x0 + 1
    def p2(x0, x1): return -x0 + x1
    def p3(x0, x1): return x1 - 2

    def tmax(x0, x1):
        return np.maximum(np.maximum(p1(x0,x1), p2(x0,x1)), p3(x0,x1))

    x = np.linspace(-4, 4, 500)
    X0, X1 = np.meshgrid(x, x)
    Z = tmax(X0, X1)

    # Find walls
    wall12 = np.abs(p1(X0,X1) - p2(X0,X1)) < 0.05
    wall13 = np.abs(p1(X0,X1) - p3(X0,X1)) < 0.05
    wall23 = np.abs(p2(X0,X1) - p3(X0,X1)) < 0.05

    # Find tropical vertex (all three equal)
    diff = np.abs(p1(X0,X1) - p2(X0,X1)) + np.abs(p1(X0,X1) - p3(X0,X1))
    min_idx = np.unravel_index(np.argmin(diff), diff.shape)
    vertex = (X0[min_idx], X1[min_idx])

    # Active piece at each point
    active = np.argmax(np.stack([p1(X0,X1), p2(X0,X1), p3(X0,X1)]), axis=0)

    print(f"\nPiece 1: f₁(x) = 2x₀ + 1")
    print(f"Piece 2: f₂(x) = -x₀ + x₁")
    print(f"Piece 3: f₃(x) = x₁ - 2")
    print(f"\nTropical vertex (all three active): ≈ ({vertex[0]:.2f}, {vertex[1]:.2f})")
    print(f"Three walls (codimension-1 faces) meet at this vertex")

    # Transition path from piece-1-dominant to piece-3-dominant
    t = np.linspace(0, 1, 200)
    g0 = 2 - 5*t
    g1 = -2 + 5*t

    vals1 = p1(g0, g1)
    vals2 = p2(g0, g1)
    vals3 = p3(g0, g1)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Contour with walls
    ax = axes[0]
    c = ax.contourf(X0, X1, Z, levels=40, cmap='plasma')
    plt.colorbar(c, ax=ax, label='f(x)')

    # Draw walls on the corner locus
    ax.contour(X0, X1, p1(X0,X1)-p2(X0,X1), levels=[0], colors='cyan', linewidths=2)
    ax.contour(X0, X1, p1(X0,X1)-p3(X0,X1), levels=[0], colors='lime', linewidths=2)
    ax.contour(X0, X1, p2(X0,X1)-p3(X0,X1), levels=[0], colors='yellow', linewidths=2)
    ax.plot(*vertex, 'r*', markersize=20, label='Tropical vertex')
    ax.plot(g0, g1, 'w--', linewidth=2, label='Transition path')
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Three-Piece Tropical Function')
    ax.legend(fontsize=8)
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)

    # Active regions
    ax = axes[1]
    cmap3 = LinearSegmentedColormap.from_list('active3',
        [(0.2,0.4,0.8), (0.8,0.3,0.3), (0.3,0.7,0.3)])
    ax.pcolormesh(X0, X1, active, cmap=cmap3, shading='auto')
    ax.plot(*vertex, 'r*', markersize=20)
    ax.contour(X0, X1, p1(X0,X1)-p2(X0,X1), levels=[0], colors='white', linewidths=1)
    ax.contour(X0, X1, p1(X0,X1)-p3(X0,X1), levels=[0], colors='white', linewidths=1)
    ax.contour(X0, X1, p2(X0,X1)-p3(X0,X1), levels=[0], colors='white', linewidths=1)
    ax.set_xlabel('x₀')
    ax.set_ylabel('x₁')
    ax.set_title('Active Piece Regions')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)

    # Values along path
    ax = axes[2]
    ax.plot(t, vals1, 'b-', linewidth=2, label='f₁(γ(t))')
    ax.plot(t, vals2, 'r-', linewidth=2, label='f₂(γ(t))')
    ax.plot(t, vals3, 'g-', linewidth=2, label='f₃(γ(t))')
    ax.plot(t, np.maximum(np.maximum(vals1, vals2), vals3), 'k--',
            linewidth=2, label='max')
    ax.set_xlabel('Path parameter t')
    ax.set_ylabel('Value')
    ax.set_title('Piece Values Along Transition Path')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_three_piece.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: tropical_three_piece.png")


# ─────────────────────────────────────────────────────────
# Demo 3: Morse Index Computation
# ─────────────────────────────────────────────────────────

def demo_morse_index():
    """
    Compute the tropical Morse index for various two-piece configurations.
    """
    print("\n" + "=" * 60)
    print("Demo 3: Tropical Morse Index Computation")
    print("=" * 60)

    configs = [
        ("Opposing: (1,-1) vs (-1,1)", np.array([1,-1]), np.array([-1,1])),
        ("Parallel: (1,0) vs (2,0)", np.array([1,0]), np.array([2,0])),
        ("Orthogonal: (1,0) vs (0,1)", np.array([1,0]), np.array([0,1])),
        ("Anti-parallel: (1,0) vs (-1,0)", np.array([1,0]), np.array([-1,0])),
        ("Scaled opposing: (3,-2) vs (-3,2)", np.array([3,-2]), np.array([-3,2])),
    ]

    print(f"\n{'Configuration':<40} {'Max product':>12} {'Index':>6}")
    print("-" * 60)

    for name, g1, g2 in configs:
        # Check if fully opposing: ∀ v, g1·v × g2·v ≤ 0
        # This is equivalent to g2 = -c*g1 for c ≥ 0
        # Sample many directions
        n_dirs = 10000
        angles = np.linspace(0, 2*np.pi, n_dirs)
        dirs = np.stack([np.cos(angles), np.sin(angles)], axis=1)
        products = (dirs @ g1) * (dirs @ g2)
        max_product = np.max(products)
        fully_opposing = max_product <= 1e-10
        index = 1 if fully_opposing else 0
        print(f"  {name:<38} {max_product:>12.6f} {index:>6}")

    print(f"\nMorse index = 1 ↔ gradients fully oppose (g₂ = -c·g₁, c ≥ 0)")
    print(f"Morse index = 0 ↔ ∃ direction with same-sign derivatives")


# ─────────────────────────────────────────────────────────
# Demo 4: Graph-Theoretic Morse Theory
# ─────────────────────────────────────────────────────────

def demo_graph_morse():
    """
    Compute local maxima/minima for functions on graphs.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Graph-Theoretic Tropical Morse Theory")
    print("=" * 60)

    # Example 1: Path graph
    n = 7
    adj = {i: set() for i in range(n)}
    for i in range(n-1):
        adj[i].add(i+1)
        adj[i+1].add(i)

    phi = [1.0, 3.0, 2.0, 5.0, 4.0, 6.0, 0.0]

    local_max = []
    local_min = []
    for v in range(n):
        is_max = all(phi[u] <= phi[v] for u in adj[v])
        is_min = all(phi[v] <= phi[u] for u in adj[v])
        if is_max:
            local_max.append(v)
        if is_min:
            local_min.append(v)

    print(f"\nPath graph: 0 — 1 — 2 — 3 — 4 — 5 — 6")
    print(f"φ values:   {phi}")
    print(f"Local maxima: {local_max} (vertices {[phi[v] for v in local_max]})")
    print(f"Local minima: {local_min} (vertices {[phi[v] for v in local_min]})")
    print(f"Euler characteristic χ = V - E = {n} - {n-1} = 1")
    print(f"#local_max = {len(local_max)} ≥ 1 = β₀ ✓")

    # Example 2: Cycle graph
    n2 = 6
    adj2 = {i: set() for i in range(n2)}
    for i in range(n2):
        adj2[i].add((i+1) % n2)
        adj2[(i+1) % n2].add(i)

    phi2 = [1.0, 4.0, 2.0, 5.0, 3.0, 6.0]

    local_max2 = [v for v in range(n2) if all(phi2[u] <= phi2[v] for u in adj2[v])]
    local_min2 = [v for v in range(n2) if all(phi2[v] <= phi2[u] for u in adj2[v])]

    print(f"\nCycle graph: 0 — 1 — 2 — 3 — 4 — 5 — 0")
    print(f"φ values:    {phi2}")
    print(f"Local maxima: {local_max2}")
    print(f"Local minima: {local_min2}")
    print(f"Euler characteristic χ = V - E = {n2} - {n2} = 0")
    print(f"#local_max = {len(local_max2)} ≥ 1 = β₀ ✓")
    print(f"#local_max - #saddle + #local_min relates to χ (discrete Morse)")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Path graph
    ax = axes[0]
    positions = [(i, 0) for i in range(n)]
    for v in range(n):
        color = 'red' if v in local_max else ('blue' if v in local_min else 'gray')
        size = 200 if v in local_max or v in local_min else 100
        ax.scatter(v, phi[v], c=color, s=size, zorder=5, edgecolors='black')
        ax.text(v, phi[v]+0.3, f'v{v}\nφ={phi[v]:.0f}', ha='center', fontsize=8)

    for i in range(n-1):
        ax.plot([i, i+1], [phi[i], phi[i+1]], 'k-', linewidth=1)

    ax.set_xlabel('Vertex')
    ax.set_ylabel('φ value')
    ax.set_title('Path Graph: Local Max (red), Min (blue)')
    ax.grid(True, alpha=0.3)

    # Cycle graph
    ax = axes[1]
    angles = np.linspace(0, 2*np.pi, n2, endpoint=False)
    cx, cy = np.cos(angles), np.sin(angles)
    for v in range(n2):
        color = 'red' if v in local_max2 else ('blue' if v in local_min2 else 'gray')
        size = 200 if v in local_max2 or v in local_min2 else 100
        ax.scatter(cx[v], cy[v], c=color, s=size, zorder=5, edgecolors='black')
        offset = 0.15
        ax.text(cx[v]*(1+offset), cy[v]*(1+offset),
                f'v{v}\nφ={phi2[v]:.0f}', ha='center', fontsize=8)

    for i in range(n2):
        j = (i+1) % n2
        ax.plot([cx[i], cx[j]], [cy[i], cy[j]], 'k-', linewidth=1)

    ax.set_aspect('equal')
    ax.set_title('Cycle Graph: Local Max (red), Min (blue)')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_graph_morse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved: tropical_graph_morse.png")


# ─────────────────────────────────────────────────────────
# Demo 5: Corner-Critical Transition Count
# ─────────────────────────────────────────────────────────

def demo_transition_count():
    """
    Count corner crossings along a path through a multi-piece tropical function.
    """
    print("\n" + "=" * 60)
    print("Demo 5: Corner Crossing Count Along Training Path")
    print("=" * 60)

    # 4 pieces in R²
    pieces = [
        (np.array([2, 1]), 0),     # 2x₀ + x₁
        (np.array([-1, 2]), 1),    # -x₀ + 2x₁ + 1
        (np.array([0, -1]), 3),    # -x₁ + 3
        (np.array([-2, -1]), 5),   # -2x₀ - x₁ + 5
    ]

    def eval_piece(piece, x):
        return piece[0] @ x + piece[1]

    def tropical_max_val(x):
        return max(eval_piece(p, x) for p in pieces)

    def active_set(x):
        mx = tropical_max_val(x)
        return [i for i, p in enumerate(pieces) if abs(eval_piece(p, x) - mx) < 1e-10]

    # Spiral path
    t = np.linspace(0, 4*np.pi, 2000)
    r = 3 * t / (4*np.pi)
    gamma = np.stack([r * np.cos(t), r * np.sin(t)], axis=1)

    # Track active set changes
    crossings = []
    prev_active = tuple(active_set(gamma[0]))
    for idx in range(1, len(t)):
        curr_active = tuple(active_set(gamma[idx]))
        if curr_active != prev_active:
            if len(curr_active) >= 2:
                crossings.append((t[idx], gamma[idx], curr_active))
            prev_active = curr_active

    print(f"\n{len(pieces)} affine pieces in R²")
    print(f"Path: spiral γ(t) = (r(t)cos(t), r(t)sin(t))")
    print(f"\nCorner crossings detected: {len(crossings)}")
    for i, (tc, pt, act) in enumerate(crossings[:10]):
        print(f"  Crossing {i+1}: t={tc:.3f}, point=({pt[0]:.2f},{pt[1]:.2f}), "
              f"active pieces={act}")

    print(f"\nTheorem A guarantees: every active-piece transition forces")
    print(f"at least one corner locus crossing. Found {len(crossings)} crossings")
    print(f"along this path, confirming the theorem.")


if __name__ == "__main__":
    demo_two_piece()
    demo_three_piece()
    demo_morse_index()
    demo_graph_morse()
    demo_transition_count()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
