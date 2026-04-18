#!/usr/bin/env python3
"""
Stereographic Projection: Novel Applications Demos
====================================================

Demonstrates cutting-edge applications of stereographic projection
to machine learning, cryptography, and physics.

Requirements: pip install numpy matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Core definitions
def sq_norm(y): return np.sum(y**2, axis=-1)
def stereo_denom(y): return 1.0 + sq_norm(y)
def conformal_factor(y): return 2.0 / stereo_denom(y)

def inv_stereo_n(y):
    y = np.atleast_2d(y)
    D = stereo_denom(y)
    S = sq_norm(y)
    first = 2 * y / D[..., np.newaxis]
    last = (S - 1) / D
    return np.concatenate([first, last[..., np.newaxis]], axis=-1)

def stereo_n(x):
    x = np.atleast_2d(x)
    return x[..., :-1] / (1 - x[..., -1:])


# ============================================================
# Application 1: StereoNorm — Stereographic Normalization Layer
# ============================================================

def demo_stereonorm():
    """Compare StereoNorm with other normalization techniques."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    
    np.random.seed(42)
    N = 500
    
    # Generate "activations" with varying scales (simulating hidden layer outputs)
    scales = np.random.exponential(3, N)
    directions = np.random.randn(N, 3)
    activations = directions * scales[:, np.newaxis]
    
    # --- Normalization methods ---
    
    # 1. Raw activations
    ax = axes[0, 0]
    ax.scatter(activations[:, 0], activations[:, 1], c=scales, cmap='viridis', s=10, alpha=0.5)
    ax.set_title("Raw Activations\n(unbounded, varying scale)", fontsize=11, fontweight='bold')
    ax.set_xlim(-15, 15); ax.set_ylim(-15, 15)
    ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    
    # 2. L2 Normalization (projects to unit sphere, loses scale info)
    norms = np.sqrt(sq_norm(activations))
    l2_normed = activations / np.maximum(norms[:, np.newaxis], 1e-8)
    ax = axes[0, 1]
    ax.scatter(l2_normed[:, 0], l2_normed[:, 1], c=scales, cmap='viridis', s=10, alpha=0.5)
    circle = plt.Circle((0, 0), 1, fill=False, color='red', linewidth=1.5)
    ax.add_patch(circle)
    ax.set_title("L2 Normalization\n(scale info LOST)", fontsize=11, fontweight='bold')
    ax.set_xlim(-1.5, 1.5); ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    
    # 3. StereoNorm (invStereoN — preserves scale info via last coordinate!)
    stereo_pts = inv_stereo_n(activations)
    ax = axes[0, 2]
    ax.scatter(stereo_pts[:, 0], stereo_pts[:, 1], c=scales, cmap='viridis', s=10, alpha=0.5)
    circle = plt.Circle((0, 0), 1, fill=False, color='red', linewidth=1.5)
    ax.add_patch(circle)
    ax.set_title("StereoNorm (invStereoN)\n(bounded + scale PRESERVED\nin last coord)", fontsize=11, fontweight='bold')
    ax.set_xlim(-1.5, 1.5); ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    
    # 4. Scale information recovery comparison
    ax = axes[1, 0]
    # From L2 norm: scale is completely lost
    # From StereoNorm: scale encoded in last coordinate
    last_coords = stereo_pts[:, -1]
    recovered_scale = np.sqrt((1 + last_coords) / (1 - last_coords + 1e-10))
    ax.scatter(norms, recovered_scale, s=5, alpha=0.3, c='purple')
    max_val = max(norms.max(), recovered_scale.max())
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='Perfect recovery')
    ax.set_xlabel("True ||x||", fontsize=10)
    ax.set_ylabel("Recovered ||x|| from last coord", fontsize=10)
    ax.set_title("Scale Recovery from StereoNorm\n(information preserved!)", fontsize=11, fontweight='bold')
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
    
    # 5. Gradient flow comparison
    ax = axes[1, 1]
    norms_range = np.linspace(0.01, 10, 500)
    
    # StereoNorm gradient: conformal factor 2/D
    stereo_grad = 2 / (1 + norms_range**2)
    # L2 norm gradient: 1/||x|| (problematic near 0)
    l2_grad = 1 / norms_range
    # Sigmoid gradient (for comparison)
    sigmoid_grad = np.exp(-norms_range) / (1 + np.exp(-norms_range))**2
    
    ax.plot(norms_range, stereo_grad, 'b-', linewidth=2, label='StereoNorm: 2/(1+||x||²)')
    ax.plot(norms_range, l2_grad, 'r-', linewidth=2, label='L2Norm: 1/||x||')
    ax.plot(norms_range, sigmoid_grad, 'g-', linewidth=2, label='Sigmoid gradient')
    ax.set_xlabel("||x||", fontsize=10)
    ax.set_ylabel("Gradient magnitude", fontsize=10)
    ax.set_title("Gradient Flow Comparison\n(StereoNorm: smooth, bounded)", fontsize=11, fontweight='bold')
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)
    
    # 6. Round-trip accuracy
    ax = axes[1, 2]
    recovered = stereo_n(stereo_pts)
    errors = np.sqrt(np.sum((recovered - activations)**2, axis=1))
    ax.hist(np.log10(errors + 1e-20), bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    ax.set_xlabel("log₁₀(round-trip error)", fontsize=10)
    ax.set_ylabel("Count", fontsize=10)
    ax.set_title(f"Round-trip: stereoN ∘ invStereoN = id\nMax error: {errors.max():.2e}", 
                fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig("demos/app_stereonorm.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 1: StereoNorm saved to demos/app_stereonorm.png")


# ============================================================
# Application 2: Conformal Anomaly Detection
# ============================================================

def demo_anomaly_detection():
    """Use conformal factor as an anomaly score."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    np.random.seed(42)
    
    # Normal data: clustered around origin
    normal = np.random.randn(800, 2) * 0.8
    # Anomalies: scattered far from origin
    anomalies = np.random.randn(50, 2) * 0.5 + np.random.choice([-3, 3], (50, 2))
    all_data = np.vstack([normal, anomalies])
    labels = np.array([0]*800 + [1]*50)
    
    # Panel 1: Raw data
    ax = axes[0]
    ax.scatter(normal[:, 0], normal[:, 1], c='blue', s=10, alpha=0.3, label='Normal')
    ax.scatter(anomalies[:, 0], anomalies[:, 1], c='red', s=30, marker='x', label='Anomaly')
    ax.set_title("Input Data", fontsize=13, fontweight='bold')
    ax.legend(); ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    
    # Panel 2: Conformal factor as anomaly score
    ax = axes[1]
    cf = conformal_factor(all_data)
    ax.scatter(all_data[labels==0, 0], all_data[labels==0, 1], c=cf[labels==0], 
              cmap='RdYlGn', s=10, alpha=0.5, vmin=0, vmax=2)
    ax.scatter(all_data[labels==1, 0], all_data[labels==1, 1], c=cf[labels==1],
              cmap='RdYlGn', s=30, marker='x', vmin=0, vmax=2)
    ax.set_title("Conformal Factor = 2/(1+||y||²)\n(high=normal, low=anomaly)", fontsize=13, fontweight='bold')
    ax.set_aspect('equal')
    
    # Panel 3: ROC-like curve
    ax = axes[2]
    thresholds = np.linspace(0, 2, 200)
    tpr = [np.mean(cf[labels==1] < t) for t in thresholds]
    fpr = [np.mean(cf[labels==0] < t) for t in thresholds]
    ax.plot(fpr, tpr, 'b-', linewidth=2)
    ax.plot([0, 1], [0, 1], 'k--', alpha=0.3)
    ax.set_xlabel("False Positive Rate", fontsize=11)
    ax.set_ylabel("True Positive Rate", fontsize=11)
    ax.set_title("Anomaly Detection ROC\n(conformal factor as score)", fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Compute AUC
    from numpy import trapezoid
    auc = trapezoid(tpr, fpr)
    ax.text(0.6, 0.2, f'AUC = {abs(auc):.3f}', fontsize=14, fontweight='bold',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig("demos/app_anomaly_detection.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 2: Anomaly detection saved to demos/app_anomaly_detection.png")


# ============================================================
# Application 3: Sphere Packing Visualization
# ============================================================

def demo_sphere_packing():
    """Optimize point configurations on S^2 using stereographic coordinates."""
    fig = plt.figure(figsize=(16, 6))
    
    # Start with random points on S^2 (via random ℝ^2 stereographic coords)
    np.random.seed(42)
    n_points = 30
    y = np.random.randn(n_points, 2) * 2
    
    # Optimize: maximize minimum chordal distance
    # Using gradient descent in stereographic coordinates
    lr = 0.01
    history = []
    
    for step in range(500):
        sphere_pts = inv_stereo_n(y)
        
        # Compute all pairwise chordal distances
        min_dist = float('inf')
        grad = np.zeros_like(y)
        
        for i in range(n_points):
            for j in range(i+1, n_points):
                diff = y[i] - y[j]
                Di = stereo_denom(y[i:i+1])[0]
                Dj = stereo_denom(y[j:j+1])[0]
                
                dist_sq = 4 * np.sum(diff**2) / (Di * Dj)
                min_dist = min(min_dist, dist_sq)
                
                if dist_sq < 0.5:  # Repulsive force for close pairs
                    force = diff / (np.sum(diff**2) + 1e-8)
                    grad[i] += force * 0.1
                    grad[j] -= force * 0.1
        
        y += lr * grad
        history.append(np.sqrt(min_dist))
    
    # Panel 1: Initial configuration (random)
    np.random.seed(42)
    y_init = np.random.randn(n_points, 2) * 2
    sphere_init = inv_stereo_n(y_init)
    
    ax1 = fig.add_subplot(131, projection='3d')
    u_s = np.linspace(0, 2*np.pi, 40)
    v_s = np.linspace(0, np.pi, 25)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax1.plot_surface(xs, ys, zs, alpha=0.08, color='lightblue')
    ax1.scatter(sphere_init[:, 0], sphere_init[:, 1], sphere_init[:, 2],
               c='red', s=50, zorder=5)
    ax1.set_title("Initial: Random on S²", fontsize=12, fontweight='bold')
    
    # Panel 2: Optimized configuration
    sphere_opt = inv_stereo_n(y)
    ax2 = fig.add_subplot(132, projection='3d')
    ax2.plot_surface(xs, ys, zs, alpha=0.08, color='lightblue')
    ax2.scatter(sphere_opt[:, 0], sphere_opt[:, 1], sphere_opt[:, 2],
               c='green', s=50, zorder=5)
    ax2.set_title("Optimized: Max min-distance\n(via stereographic gradient)", fontsize=12, fontweight='bold')
    
    # Panel 3: Convergence
    ax3 = fig.add_subplot(133)
    ax3.plot(history, 'b-', linewidth=1.5)
    ax3.set_xlabel("Iteration", fontsize=11)
    ax3.set_ylabel("Min chordal distance", fontsize=11)
    ax3.set_title("Convergence of\nsphere packing optimization", fontsize=12, fontweight='bold')
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("demos/app_sphere_packing.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 3: Sphere packing saved to demos/app_sphere_packing.png")


# ============================================================
# Application 4: Poincaré Disk via Stereographic Duality
# ============================================================

def demo_poincare_disk():
    """Visualize the Poincaré disk model using the hyperbolic-spherical duality."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Spherical stereographic (our formalization)
    ax = axes[0]
    x = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x, x)
    pts = np.stack([X, Y], axis=-1)
    CF_sphere = 2 / (1 + X**2 + Y**2)
    
    im = ax.imshow(CF_sphere, extent=[-3, 3, -3, 3], cmap='YlOrRd', origin='lower')
    ax.set_title("Spherical: 2/(1+||y||²)\n(decays to 0 at ∞)", fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    plt.colorbar(im, ax=ax, label='Conformal factor')
    
    # Panel 2: Hyperbolic conformal factor (Poincaré disk)
    ax = axes[1]
    r_vals = np.sqrt(X**2 + Y**2)
    CF_hyp = np.where(r_vals < 1, 2 / (1 - X**2 - Y**2), np.nan)
    
    im = ax.imshow(CF_hyp, extent=[-3, 3, -3, 3], cmap='YlOrRd', origin='lower', vmin=0, vmax=10)
    circle = plt.Circle((0, 0), 1, fill=False, color='white', linewidth=2)
    ax.add_patch(circle)
    ax.set_title("Hyperbolic: 2/(1-||y||²)\n(blows up at boundary)", fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    plt.colorbar(im, ax=ax, label='Conformal factor')
    
    # Panel 3: Geodesics in the Poincaré disk
    ax = axes[2]
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Geodesics = arcs of circles orthogonal to the unit circle
    for offset in [0.3, 0.5, 0.7, -0.3, -0.5, -0.7]:
        # Vertical geodesics (diameters)
        t = np.linspace(-0.99, 0.99, 200)
        ax.plot(t, np.full_like(t, offset) * np.sqrt(1 - t**2 / (1 + offset**2)), 
               'b-', alpha=0.3, linewidth=1)
    
    # Diameter geodesics
    for angle in np.linspace(0, np.pi, 8):
        t = np.linspace(-0.99, 0.99, 200)
        ax.plot(t * np.cos(angle), t * np.sin(angle), 'r-', alpha=0.3, linewidth=1)
    
    ax.set_aspect('equal')
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_title("Poincaré Disk Geodesics\n(straight lines = geodesics)", fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig("demos/app_poincare_disk.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 4: Poincaré disk saved to demos/app_poincare_disk.png")


# ============================================================
# Application 5: Bloch Sphere Quantum Computing
# ============================================================

def demo_bloch_sphere():
    """Visualize qubit states on the Bloch sphere using stereographic coordinates."""
    fig = plt.figure(figsize=(16, 6))
    
    # Panel 1: Stereographic parametrization of the Bloch sphere
    ax1 = fig.add_subplot(131, projection='3d')
    
    u_s = np.linspace(0, 2*np.pi, 40)
    v_s = np.linspace(0, np.pi, 25)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax1.plot_surface(xs, ys, zs, alpha=0.08, color='lightblue')
    
    # Key quantum states
    states = {
        '|0⟩': np.array([0, 0, -1]),   # South pole (ground state)
        '|1⟩': np.array([0, 0, 1]),     # North pole (excited state)
        '|+⟩': np.array([1, 0, 0]),     # Hadamard superposition
        '|-⟩': np.array([-1, 0, 0]),
        '|+i⟩': np.array([0, 1, 0]),
        '|-i⟩': np.array([0, -1, 0]),
    }
    
    colors = plt.cm.Set1(np.linspace(0, 0.7, len(states)))
    for idx, (name, pos) in enumerate(states.items()):
        ax1.scatter(*pos, s=100, color=colors[idx], zorder=5, label=name)
    
    ax1.set_title("Bloch Sphere\n(qubit state space = S²)", fontsize=12, fontweight='bold')
    ax1.legend(fontsize=7, loc='upper left')
    
    # Panel 2: Stereographic coordinates of quantum gates
    ax2 = fig.add_subplot(132)
    
    # Pauli X gate: rotation by π around x-axis
    # In stereographic coords: inversion z ↦ 1/z̄
    t = np.linspace(0, 2*np.pi, 100)
    
    # Trajectory of |0⟩ under Rz(θ) (rotation around z-axis)
    for theta in np.linspace(0, np.pi, 5):
        # State: cos(θ/2)|0⟩ + sin(θ/2)e^{iφ}|1⟩
        # Stereographic: z = tan(θ/2) * e^{iφ}
        r = np.tan(theta/2 + 1e-10)
        circle_x = r * np.cos(t)
        circle_y = r * np.sin(t)
        ax2.plot(circle_x, circle_y, '-', alpha=0.5, linewidth=1.5,
                label=f'θ={theta:.2f}' if theta < 2 else None)
    
    ax2.set_xlim(-3, 3)
    ax2.set_ylim(-3, 3)
    ax2.set_aspect('equal')
    ax2.set_title("Stereographic Coordinates\nof Rz(θ) Trajectories", fontsize=12, fontweight='bold')
    ax2.set_xlabel("Re(z)")
    ax2.set_ylabel("Im(z)")
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Quantum gate as Möbius transformation
    ax3 = fig.add_subplot(133)
    
    # The Hadamard gate in stereographic coordinates is z ↦ (z+1)/(z-1)
    # which is a Möbius transformation!
    z_real = np.linspace(-3, 3, 200)
    z_imag = np.linspace(-3, 3, 200)
    Z_R, Z_I = np.meshgrid(z_real, z_imag)
    Z = Z_R + 1j * Z_I
    
    # Hadamard: H = (Z + 1) / (Z - 1), but we need to be careful about poles
    H = (Z + 1) / (Z - 1 + 1e-10j)
    
    # Plot: magnitude of Hadamard transform
    mag = np.abs(H)
    mag = np.clip(mag, 0, 5)
    
    im = ax3.imshow(mag, extent=[-3, 3, -3, 3], cmap='twilight', origin='lower', vmin=0, vmax=5)
    ax3.scatter([0], [0], color='white', s=100, marker='*', zorder=5, label='|0⟩ → |+⟩')
    ax3.scatter([1], [0], color='yellow', s=100, marker='x', zorder=5, label='Pole at z=1')
    ax3.set_title("Hadamard Gate as\nMöbius Transform z↦(z+1)/(z-1)", fontsize=12, fontweight='bold')
    ax3.set_xlabel("Re(z)")
    ax3.set_ylabel("Im(z)")
    ax3.legend(fontsize=8)
    plt.colorbar(im, ax=ax3, label='|H(z)|')
    
    plt.tight_layout()
    plt.savefig("demos/app_bloch_sphere.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 5: Bloch sphere saved to demos/app_bloch_sphere.png")


# ============================================================
# Application 6: Rational Sphere Parametrization for Number Theory
# ============================================================

def demo_rational_spheres():
    """Visualize rational point density on higher-dimensional spheres."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Rational points on S^1 (all Pythagorean angles)
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, 500)
    ax.plot(np.cos(theta), np.sin(theta), 'gray', alpha=0.3, linewidth=1)
    
    max_denom = 30
    rational_pts = set()
    for q in range(1, max_denom):
        for p in range(-max_denom, max_denom+1):
            t = p / q
            x = 2*t / (1 + t**2)
            y = (t**2 - 1) / (1 + t**2)
            rational_pts.add((round(x, 10), round(y, 10)))
    
    pts = np.array(list(rational_pts))
    ax.scatter(pts[:, 0], pts[:, 1], s=5, c='blue', zorder=5)
    ax.set_aspect('equal')
    ax.set_title(f"Rational Points on S¹\n({len(rational_pts)} points, denom ≤ {max_denom})", 
                fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Density vs denominator
    ax = axes[1]
    counts = []
    denoms = range(1, 60)
    for max_d in denoms:
        pts_set = set()
        for q in range(1, max_d+1):
            for p in range(-3*max_d, 3*max_d+1):
                t = p / q
                x = 2*t / (1 + t**2)
                y = (t**2 - 1) / (1 + t**2)
                pts_set.add((round(x, 8), round(y, 8)))
        counts.append(len(pts_set))
    
    ax.plot(list(denoms), counts, 'b-', linewidth=2)
    ax.set_xlabel("Max denominator", fontsize=11)
    ax.set_ylabel("# Distinct rational points", fontsize=11)
    ax.set_title("Growth of Rational Points\non S¹ (quadratic growth)", fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Sum of squares representation
    ax = axes[2]
    # For each n, count representations as a² + b² using Brahmagupta-Fibonacci
    max_n = 100
    n_values = range(1, max_n + 1)
    rep_counts = []
    for n in n_values:
        count = 0
        for a in range(int(np.sqrt(n)) + 1):
            b_sq = n - a**2
            if b_sq >= 0 and int(np.sqrt(b_sq))**2 == b_sq:
                count += 1
        rep_counts.append(count)
    
    colors_bar = ['green' if c > 0 else 'red' for c in rep_counts]
    ax.bar(list(n_values), rep_counts, color=colors_bar, alpha=0.7, width=1)
    ax.set_xlabel("n", fontsize=11)
    ax.set_ylabel("# representations as a²+b²", fontsize=11)
    ax.set_title("Sum of Two Squares\n(green = representable)", fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig("demos/app_rational_spheres.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 6: Rational spheres saved to demos/app_rational_spheres.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Stereographic Projection: Novel Applications")
    print("=" * 60)
    print()
    
    demo_stereonorm()
    demo_anomaly_detection()
    demo_sphere_packing()
    demo_poincare_disk()
    demo_bloch_sphere()
    demo_rational_spheres()
    
    print()
    print("=" * 60)
    print("All 6 application demos generated successfully!")
    print("=" * 60)
