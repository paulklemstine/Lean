"""
Applications of Vector-Valued EML Density Theorem
===================================================

Concrete demonstrations of how the VecEML density theorem applies to:
1. Multiclass classification (simplex outputs)
2. Attention-like affine coding
3. Neural network output layer universality
4. Certified robustness via perturbation bounds
"""

import numpy as np
import matplotlib.pyplot as plt

# ===================================================================
# Application 1: Multiclass Classification via Prototype Coding
# ===================================================================

def app_multiclass_prototypes():
    """
    Show how a multiclass classifier can be built from scalar EML
    functions and prototype probability vectors.
    
    F̂(x) = ∑ᵢ φᵢ(x) · pᵢ  where pᵢ ∈ Δ³ are prototype distributions
    """
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Input space: 2D grid
    N = 200
    x = np.linspace(-3, 3, N)
    y = np.linspace(-3, 3, N)
    X, Y = np.meshgrid(x, y)
    pts = np.column_stack([X.ravel(), Y.ravel()])
    
    # Define 3-class target using softmax of linear classifiers
    W = np.array([[2, 0], [-1, 1.7], [-1, -1.7]])  # weight matrix
    b = np.array([0, 0, 0])  # biases
    logits = pts @ W.T + b
    exp_l = np.exp(logits - logits.max(axis=1, keepdims=True))
    target_probs = exp_l / exp_l.sum(axis=1, keepdims=True)
    
    # Define prototype probability vectors (anchor points on simplex)
    prototypes = np.array([
        [0.9, 0.05, 0.05],  # strongly class 1
        [0.05, 0.9, 0.05],  # strongly class 2
        [0.05, 0.05, 0.9],  # strongly class 3
        [0.4, 0.4, 0.2],    # mixed 1-2
        [0.2, 0.4, 0.4],    # mixed 2-3
        [0.4, 0.2, 0.4],    # mixed 1-3
        [0.33, 0.33, 0.34], # uniform
    ])
    n_proto = len(prototypes)
    
    # EML scalar weight functions: logistic gates
    # φᵢ(x) = σ(wᵢ · x + bᵢ)
    centers = np.array([
        [2, 0], [-1, 1.7], [-1, -1.7],
        [0.5, 0.85], [-1, 0], [0.5, -0.85],
        [0, 0]
    ])
    
    alpha = 1.5
    weights = np.zeros((len(pts), n_proto))
    for i in range(n_proto):
        dist_sq = np.sum((pts - centers[i]) ** 2, axis=1)
        weights[:, i] = np.exp(-alpha * dist_sq)
    weights = weights / weights.sum(axis=1, keepdims=True)
    
    # Affine coding: F̂ = ∑ φᵢ · pᵢ
    approx_probs = weights @ prototypes
    
    # Plot target vs approximation (class argmax)
    target_class = target_probs.argmax(axis=1).reshape(N, N)
    approx_class = approx_probs.argmax(axis=1).reshape(N, N)
    
    colors = ['#e41a1c', '#377eb8', '#4daf4a']
    cmap = plt.cm.colors.ListedColormap(colors)
    
    axes[0, 0].pcolormesh(X, Y, target_class, cmap=cmap, vmin=0, vmax=2)
    axes[0, 0].set_title('Target: argmax class', fontsize=12)
    
    axes[0, 1].pcolormesh(X, Y, approx_class, cmap=cmap, vmin=0, vmax=2)
    axes[0, 1].scatter(centers[:, 0], centers[:, 1], c='white', 
                        edgecolors='black', s=100, zorder=5, label='Prototypes')
    axes[0, 1].legend()
    axes[0, 1].set_title('VecEML Approx: argmax class', fontsize=12)
    
    # Plot probability for class 1
    im1 = axes[1, 0].pcolormesh(X, Y, target_probs[:, 0].reshape(N, N), 
                                  cmap='RdYlBu_r', vmin=0, vmax=1)
    axes[1, 0].set_title('Target P(class 1)', fontsize=12)
    plt.colorbar(im1, ax=axes[1, 0])
    
    im2 = axes[1, 1].pcolormesh(X, Y, approx_probs[:, 0].reshape(N, N),
                                  cmap='RdYlBu_r', vmin=0, vmax=1)
    axes[1, 1].set_title('VecEML Approx P(class 1)', fontsize=12)
    plt.colorbar(im2, ax=axes[1, 1])
    
    error = np.max(np.linalg.norm(target_probs - approx_probs, axis=1))
    plt.suptitle(f'Multiclass Classification via Prototype Coding\n'
                 f'Max approximation error: {error:.4f}', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/app_multiclass.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Saved app_multiclass.png (error: {error:.4f})")

# ===================================================================
# Application 2: Attention-like Affine Coding
# ===================================================================

def app_attention_coding():
    """
    Demonstrate that transformer-style attention is an instance of VecEML coding:
    output(x) = ∑ᵢ αᵢ(x) · vᵢ
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Sequence of "tokens" (1D positions)
    seq_len = 50
    positions = np.arange(seq_len)
    
    # Value vectors (2D for visualization)
    np.random.seed(123)
    values = np.column_stack([
        np.sin(2 * np.pi * positions / seq_len),
        np.cos(2 * np.pi * positions / seq_len)
    ]) * 2
    
    # Query position
    query_positions = [10, 25, 40]
    colors_q = ['red', 'blue', 'green']
    
    for q_idx, (q_pos, color) in enumerate(zip(query_positions, colors_q)):
        # Attention weights: softmax of dot product similarity
        # This is an EML-type scalar function of the key positions
        sigma = 5.0
        scores = np.exp(-((positions - q_pos) ** 2) / (2 * sigma ** 2))
        attention = scores / scores.sum()
        
        # Attention output = ∑ αᵢ · vᵢ (VecEML coding!)
        output = attention @ values
        
        # Plot attention weights
        axes[0].plot(positions, attention, color=color, label=f'q={q_pos}')
        
        # Plot value vectors and output
        axes[1].scatter(values[:, 0], values[:, 1], c='gray', s=20, alpha=0.5)
        axes[1].scatter(output[0], output[1], c=color, s=200, marker='*',
                       zorder=5, edgecolors='black', linewidths=1.5)
    
    axes[0].set_xlabel('Position')
    axes[0].set_ylabel('Attention weight')
    axes[0].set_title('Attention Weights αᵢ(query)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].set_xlabel('Value dim 1')
    axes[1].set_ylabel('Value dim 2')
    axes[1].set_title('Value Vectors & Attention Outputs')
    axes[1].grid(True, alpha=0.3)
    
    # Show how VecEML density applies: any smooth target can be approximated
    t = np.linspace(0, 1, 200)
    target = np.column_stack([np.sin(4*np.pi*t), np.cos(6*np.pi*t)])
    
    for n_v in [5, 15, 50]:
        t_v = np.linspace(0, 1, n_v)
        vals = np.column_stack([np.sin(4*np.pi*t_v), np.cos(6*np.pi*t_v)])
        
        sigma_v = 1.0 / n_v
        w = np.zeros((len(t), n_v))
        for i in range(n_v):
            w[:, i] = np.exp(-(t - t_v[i])**2 / (2*sigma_v**2))
        w = w / w.sum(axis=1, keepdims=True)
        
        approx = w @ vals
        err = np.max(np.linalg.norm(target - approx, axis=1))
        axes[2].plot(approx[:, 0], approx[:, 1], label=f'n={n_v} (err={err:.3f})')
    
    axes[2].plot(target[:, 0], target[:, 1], 'k--', alpha=0.3, label='Target')
    axes[2].set_title('Attention as VecEML Approximation')
    axes[2].legend(fontsize=8)
    axes[2].grid(True, alpha=0.3)
    
    plt.suptitle('Attention Mechanism as VecEML Coding: output = ∑ αᵢ · vᵢ', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/app_attention.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved app_attention.png")

# ===================================================================
# Application 3: Certified Robustness via Perturbation Bounds
# ===================================================================

def app_certified_robustness():
    """
    Use the perturbation bound theorem to certify robustness of a
    VecEML classifier. If ‖φᵢ(x) - φᵢ(x')‖ ≤ Lᵢ·‖x-x'‖, then
    ‖F(x) - F(x')‖ ≤ (∑ Lᵢ·‖x-x'‖) · B.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1D input for clarity
    x = np.linspace(-3, 3, 500)
    
    # Define a VecEML classifier: 3-class, 5 scalar functions
    n_scalars = 5
    m_classes = 3
    
    # Scalar EML functions (sigmoids)
    w_params = np.array([2, -1.5, 1, -2, 0.5])
    b_params = np.array([0, 1, -1, 0.5, -0.5])
    
    phi = np.zeros((len(x), n_scalars))
    for i in range(n_scalars):
        phi[:, i] = 1 / (1 + np.exp(-(w_params[i] * x + b_params[i])))
    
    # Output vectors (class prototypes)
    v = np.array([
        [0.8, 0.1, 0.1],
        [0.1, 0.7, 0.2],
        [0.2, 0.2, 0.6],
        [0.5, 0.3, 0.2],
        [0.3, 0.3, 0.4],
    ])
    
    B = np.max(np.linalg.norm(v, axis=1))
    
    # Compute output
    F = phi @ v
    
    # Plot output probabilities
    for k in range(m_classes):
        axes[0].plot(x, F[:, k], label=f'Class {k+1}')
    axes[0].set_title('VecEML Classifier Output')
    axes[0].set_xlabel('Input x')
    axes[0].set_ylabel('Score')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Compute Lipschitz bound using perturbation theorem
    # L_i = max|w_i| · max|σ'| = |w_i| · 0.25
    L = np.abs(w_params) * 0.25
    total_L = np.sum(L) * B
    
    # Plot certified radius
    delta_range = np.linspace(0, 1, 100)
    certified_bound = total_L * delta_range
    
    # For each point, compute the actual margin and certified radius
    margins = np.zeros(len(x))
    for idx in range(len(x)):
        sorted_scores = np.sort(F[idx])[::-1]
        margins[idx] = sorted_scores[0] - sorted_scores[1]
    
    certified_radius = margins / total_L
    
    axes[1].plot(x, certified_radius, 'b-', linewidth=2)
    axes[1].fill_between(x, 0, certified_radius, alpha=0.2)
    axes[1].set_title('Certified Robustness Radius')
    axes[1].set_xlabel('Input x')
    axes[1].set_ylabel('Max perturbation δ for class stability')
    axes[1].grid(True, alpha=0.3)
    
    # Verify bound by random perturbations
    np.random.seed(42)
    x_test = np.linspace(-2, 2, 20)
    delta_values = [0.1, 0.3, 0.5]
    
    for delta in delta_values:
        actual_max_change = []
        bound_val = total_L * delta
        
        for x0 in x_test:
            # Sample random perturbations
            x_perturbed = x0 + delta * np.random.uniform(-1, 1, 100)
            
            phi_0 = np.array([1/(1+np.exp(-(w*x0+b))) for w, b in zip(w_params, b_params)])
            F_0 = phi_0 @ v
            
            max_change = 0
            for xp in x_perturbed:
                phi_p = np.array([1/(1+np.exp(-(w*xp+b))) for w, b in zip(w_params, b_params)])
                F_p = phi_p @ v
                max_change = max(max_change, np.linalg.norm(F_0 - F_p))
            actual_max_change.append(max_change)
        
        axes[2].scatter(x_test, actual_max_change, s=30, label=f'Actual (δ={delta})')
        axes[2].axhline(y=bound_val, linestyle='--', label=f'Bound (δ={delta})')
    
    axes[2].set_title('Perturbation Bound Verification')
    axes[2].set_xlabel('Input x')
    axes[2].set_ylabel('‖F(x) - F(x+δ)‖')
    axes[2].legend(fontsize=7)
    axes[2].grid(True, alpha=0.3)
    
    plt.suptitle('Certified Robustness via VecEML Perturbation Bounds', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/app_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved app_robustness.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Applications of Vector-Valued EML Density Theorem")
    print("=" * 60)
    print()
    
    print("App 1: Multiclass classification via prototype coding")
    app_multiclass_prototypes()
    
    print("\nApp 2: Attention mechanism as VecEML coding")
    app_attention_coding()
    
    print("\nApp 3: Certified robustness via perturbation bounds")
    app_certified_robustness()
    
    print("\n" + "=" * 60)
    print("All applications complete!")
    print("=" * 60)


"""
Vector-Valued EML Approximation Demo
=====================================

This script demonstrates the core theorem: any continuous map F : X → ℝ^m
can be uniformly approximated by affine codings ∑ᵢ φᵢ(x) · vᵢ where
φᵢ are scalar EML functions and vᵢ are constant output vectors.

We show this concretely by:
1. Approximating a continuous curve in ℝ² using barycentric coding
2. Approximating a continuous map into ℝ³ (color space) using EML scalar weights
3. Demonstrating the perturbation bound theorem numerically
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from mpl_toolkits.mplot3d import Axes3D

# --- EML building blocks ---

def sigmoid(x):
    """Logistic activation (EML logistic generator)."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -500, 500)))

def eml_exp_gen(x, w, b):
    """EML exponential generator: exp(w·x + b)."""
    return np.exp(np.clip(w * x + b, -500, 500))

def eml_logistic_gen(x, w, b):
    """EML logistic generator: σ(w·x + b)."""
    return sigmoid(w * x + b)

# --- Demo 1: Barycentric coding of a 2D curve ---

def demo_barycentric_curve():
    """
    Approximate a continuous curve F : [0,1] → ℝ² by barycentric coding.
    
    F(t) = (cos(2πt), sin(2πt)) — a circle in ℝ².
    
    We construct G(t) = ∑ᵢ ψᵢ(t) · yᵢ where:
    - ψᵢ are partition-of-unity functions (bump functions)
    - yᵢ = F(tᵢ) are sampled output vectors
    
    Then we replace ψᵢ by EML approximations φᵢ to get the final EML coding.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Target curve
    t = np.linspace(0, 1, 500)
    F = np.column_stack([np.cos(2 * np.pi * t), np.sin(2 * np.pi * t)])
    
    for n_pts, ax, title_suffix in [(4, axes[0], "4 points"), 
                                      (8, axes[1], "8 points"),
                                      (20, axes[2], "20 points")]:
        # Sample points
        t_samples = np.linspace(0, 1, n_pts + 1)[:-1]  # Exclude endpoint (periodic)
        y_samples = np.column_stack([np.cos(2 * np.pi * t_samples), 
                                      np.sin(2 * np.pi * t_samples)])
        
        # Build partition of unity using EML logistic generators
        # ψᵢ(t) ∝ exp(-α(t - tᵢ)²) approximated by EML functions
        alpha = n_pts ** 2 * 4
        weights = np.zeros((len(t), n_pts))
        for i in range(n_pts):
            # Use product of two sigmoids to create a bump
            width = 1.0 / n_pts
            center = t_samples[i]
            # Approximate Gaussian bump with EML functions
            weights[:, i] = np.exp(-alpha * np.minimum(np.abs(t - center), 
                                                         np.abs(t - center + 1),)**2)
            weights[:, i] = np.maximum(weights[:, i], 
                                        np.exp(-alpha * np.abs(t - center - 1)**2))
        
        # Normalize to partition of unity
        row_sums = weights.sum(axis=1, keepdims=True)
        weights = weights / row_sums
        
        # Barycentric coding: G(t) = ∑ᵢ ψᵢ(t) · yᵢ
        G = weights @ y_samples
        
        # Plot
        ax.plot(F[:, 0], F[:, 1], 'b-', alpha=0.3, linewidth=3, label='Target F(t)')
        ax.plot(G[:, 0], G[:, 1], 'r-', linewidth=1.5, label=f'Approx G(t)')
        ax.scatter(y_samples[:, 0], y_samples[:, 1], c='green', s=60, 
                   zorder=5, label=f'Samples yᵢ')
        
        # Compute error
        error = np.max(np.linalg.norm(F - G, axis=1))
        ax.set_title(f'Barycentric coding ({title_suffix})\nmax error: {error:.4f}')
        ax.legend(fontsize=8)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Vector-Valued EML: Barycentric Coding of a Circle', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/barycentric_curve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved barycentric_curve.png")

# --- Demo 2: Color map approximation ---

def demo_color_approximation():
    """
    Approximate a continuous color map F : [0,1] → ℝ³ (RGB space)
    using EML barycentric coding.
    """
    fig, axes = plt.subplots(3, 1, figsize=(12, 6))
    
    t = np.linspace(0, 1, 500)
    
    # Target: smooth rainbow-like color map
    F = np.column_stack([
        0.5 + 0.5 * np.cos(2 * np.pi * t),
        0.5 + 0.5 * np.cos(2 * np.pi * t + 2 * np.pi / 3),
        0.5 + 0.5 * np.cos(2 * np.pi * t + 4 * np.pi / 3)
    ])
    F = np.clip(F, 0, 1)
    
    for n_pts, ax, title in [(5, axes[0], "5 anchors"),
                               (10, axes[1], "10 anchors"),
                               (25, axes[2], "25 anchors")]:
        t_samples = np.linspace(0, 1, n_pts)
        y_samples = np.column_stack([
            0.5 + 0.5 * np.cos(2 * np.pi * t_samples),
            0.5 + 0.5 * np.cos(2 * np.pi * t_samples + 2 * np.pi / 3),
            0.5 + 0.5 * np.cos(2 * np.pi * t_samples + 4 * np.pi / 3)
        ])
        y_samples = np.clip(y_samples, 0, 1)
        
        # EML partition of unity
        alpha = n_pts ** 2
        weights = np.zeros((len(t), n_pts))
        for i in range(n_pts):
            weights[:, i] = np.exp(-alpha * (t - t_samples[i]) ** 2)
        weights = weights / weights.sum(axis=1, keepdims=True)
        
        G = weights @ y_samples
        G = np.clip(G, 0, 1)
        
        # Plot color bars
        for j in range(len(t) - 1):
            ax.axvspan(t[j], t[j+1], facecolor=G[j], edgecolor='none')
        
        error = np.max(np.linalg.norm(F - G, axis=1))
        ax.set_xlim(0, 1)
        ax.set_title(f'{title} — max error: {error:.4f}', fontsize=10)
        ax.set_yticks([])
    
    plt.suptitle('Color Map Approximation by Barycentric EML Coding', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/color_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved color_approximation.png")

# --- Demo 3: Perturbation bound verification ---

def demo_perturbation_bound():
    """
    Numerically verify the affine coding perturbation bound theorem:
    
    ‖∑ψᵢ·yᵢ - ∑φᵢ·yᵢ‖ ≤ (∑‖ψᵢ - φᵢ‖) · B
    
    where B = max_i ‖yᵢ‖.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    np.random.seed(42)
    t = np.linspace(0, 1, 1000)
    
    n_pts = 8
    m = 3  # output dimension
    
    # Random output vectors
    y_samples = np.random.randn(n_pts, m) * 2
    B = np.max(np.linalg.norm(y_samples, axis=1))
    
    # "Exact" partition of unity
    t_centers = np.linspace(0, 1, n_pts)
    alpha = n_pts ** 2
    psi = np.zeros((len(t), n_pts))
    for i in range(n_pts):
        psi[:, i] = np.exp(-alpha * (t - t_centers[i]) ** 2)
    psi = psi / psi.sum(axis=1, keepdims=True)
    
    # Vary perturbation level
    noise_levels = np.linspace(0, 0.5, 50)
    actual_errors = []
    bound_values = []
    
    for noise in noise_levels:
        # Perturbed weights (simulating EML approximation)
        phi = psi + noise * np.random.randn(*psi.shape) * 0.1
        
        # Compute actual error
        G_exact = psi @ y_samples
        G_approx = phi @ y_samples
        actual_error = np.max(np.linalg.norm(G_exact - G_approx, axis=1))
        
        # Compute bound: (∑‖ψᵢ - φᵢ‖_sup) * B
        weight_errors = np.max(np.abs(psi - phi), axis=0)  # sup norm per function
        bound = np.sum(weight_errors) * B
        
        actual_errors.append(actual_error)
        bound_values.append(bound)
    
    axes[0].plot(noise_levels, actual_errors, 'b-', linewidth=2, label='Actual error')
    axes[0].plot(noise_levels, bound_values, 'r--', linewidth=2, label='Theorem bound')
    axes[0].fill_between(noise_levels, actual_errors, bound_values, alpha=0.2, color='green')
    axes[0].set_xlabel('Perturbation level')
    axes[0].set_ylabel('Error / Bound')
    axes[0].set_title('Perturbation Bound Verification')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Demo: convergence rate
    n_values = range(3, 50)
    errors_by_n = []
    for n in n_values:
        t_c = np.linspace(0, 1, n)
        al = n ** 2
        w = np.zeros((len(t), n))
        for i in range(n):
            w[:, i] = np.exp(-al * (t - t_c[i]) ** 2)
        w = w / w.sum(axis=1, keepdims=True)
        
        # Target function
        F_target = np.column_stack([np.sin(4 * np.pi * t), np.cos(6 * np.pi * t)])
        y_s = np.column_stack([np.sin(4 * np.pi * t_c), np.cos(6 * np.pi * t_c)])
        
        G_n = w @ y_s
        err = np.max(np.linalg.norm(F_target - G_n, axis=1))
        errors_by_n.append(err)
    
    axes[1].semilogy(list(n_values), errors_by_n, 'b-o', markersize=3)
    axes[1].set_xlabel('Number of anchor points n')
    axes[1].set_ylabel('Approximation error (log scale)')
    axes[1].set_title('Convergence: Error vs. Number of Anchors')
    axes[1].grid(True, alpha=0.3)
    
    plt.suptitle('Affine Coding Error Bounds', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/perturbation_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved perturbation_bounds.png")

# --- Demo 4: Multiclass classification simplex ---

def demo_simplex_coding():
    """
    Demonstrate simplex-valued outputs: approximate a continuous map
    F : [0,1]² → Δ³ (probability simplex for 3 classes) using EML coding.
    """
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    
    # Grid on [0,1]²
    N = 100
    x1 = np.linspace(0, 1, N)
    x2 = np.linspace(0, 1, N)
    X1, X2 = np.meshgrid(x1, x2)
    
    # Target: smooth 3-class probability map
    logits = np.stack([
        2 * X1 - X2,
        -X1 + 2 * X2,
        -X1 - X2 + 1.5
    ], axis=-1)
    
    # Softmax to get probabilities
    exp_logits = np.exp(logits - logits.max(axis=-1, keepdims=True))
    F = exp_logits / exp_logits.sum(axis=-1, keepdims=True)
    
    # Plot target
    for k in range(3):
        im = axes[0, k].pcolormesh(X1, X2, F[:, :, k], cmap='viridis', vmin=0, vmax=1)
        axes[0, k].set_title(f'Target P(class {k+1})')
        plt.colorbar(im, ax=axes[0, k])
    
    # EML barycentric approximation
    n_anchors = 16
    t1_anchors = np.linspace(0, 1, int(np.sqrt(n_anchors)))
    t2_anchors = np.linspace(0, 1, int(np.sqrt(n_anchors)))
    T1, T2 = np.meshgrid(t1_anchors, t2_anchors)
    anchor_pts = np.column_stack([T1.ravel(), T2.ravel()])
    
    # Compute anchor values
    anchor_logits = np.stack([
        2 * anchor_pts[:, 0] - anchor_pts[:, 1],
        -anchor_pts[:, 0] + 2 * anchor_pts[:, 1],
        -anchor_pts[:, 0] - anchor_pts[:, 1] + 1.5
    ], axis=-1)
    exp_al = np.exp(anchor_logits - anchor_logits.max(axis=-1, keepdims=True))
    y_anchors = exp_al / exp_al.sum(axis=-1, keepdims=True)
    
    # Build weights using EML (Gaussian-like bumps from sigmoids)
    alpha = 20
    pts = np.column_stack([X1.ravel(), X2.ravel()])
    weights = np.zeros((len(pts), len(anchor_pts)))
    for i in range(len(anchor_pts)):
        dist_sq = np.sum((pts - anchor_pts[i]) ** 2, axis=1)
        weights[:, i] = np.exp(-alpha * dist_sq)
    weights = weights / weights.sum(axis=1, keepdims=True)
    
    # G = ∑ ψᵢ · yᵢ
    G_flat = weights @ y_anchors
    G = G_flat.reshape(N, N, 3)
    
    for k in range(3):
        im = axes[1, k].pcolormesh(X1, X2, G[:, :, k], cmap='viridis', vmin=0, vmax=1)
        axes[1, k].set_title(f'EML Approx P(class {k+1})')
        plt.colorbar(im, ax=axes[1, k])
    
    error = np.max(np.linalg.norm(F.reshape(-1, 3) - G_flat, axis=1))
    plt.suptitle(f'Simplex-Valued EML Coding (3-class, {len(anchor_pts)} anchors)\n'
                 f'Max error: {error:.4f}', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/simplex_coding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Saved simplex_coding.png (max error: {error:.4f})")

# --- Demo 5: Embedding approximation ---

def demo_embedding_approx():
    """
    Approximate a continuous embedding F : [0,1] → ℝ^d using VecEML.
    Shows how word/token embeddings can be approximated by affine coding.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Target: a smooth curve in ℝ³ projected to 2D
    t = np.linspace(0, 1, 500)
    F3d = np.column_stack([
        np.cos(4 * np.pi * t) * (1 + 0.3 * t),
        np.sin(4 * np.pi * t) * (1 + 0.3 * t),
        t
    ])
    
    # Project to 2D for visualization
    proj = np.array([[1, 0, 0.3], [0, 1, 0.5]])
    F2d = F3d @ proj.T
    
    n_anchors_list = [5, 10, 30]
    colors = ['red', 'orange', 'green']
    
    ax.plot(F2d[:, 0], F2d[:, 1], 'b-', linewidth=3, alpha=0.3, label='Target embedding')
    
    for n_a, color in zip(n_anchors_list, colors):
        t_a = np.linspace(0, 1, n_a)
        y_a = np.column_stack([
            np.cos(4 * np.pi * t_a) * (1 + 0.3 * t_a),
            np.sin(4 * np.pi * t_a) * (1 + 0.3 * t_a),
            t_a
        ]) @ proj.T
        
        alpha_val = n_a ** 2
        w = np.zeros((len(t), n_a))
        for i in range(n_a):
            w[:, i] = np.exp(-alpha_val * (t - t_a[i]) ** 2)
        w = w / w.sum(axis=1, keepdims=True)
        
        G2d = w @ y_a
        err = np.max(np.linalg.norm(F2d - G2d, axis=1))
        ax.plot(G2d[:, 0], G2d[:, 1], color=color, linewidth=1.5,
                label=f'{n_a} anchors (err={err:.3f})')
    
    ax.set_title('Embedding Approximation by Barycentric EML Coding', fontsize=13)
    ax.legend()
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/embedding_approx.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved embedding_approx.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Vector-Valued EML Approximation Demos")
    print("=" * 60)
    print()
    
    print("Demo 1: Barycentric coding of a 2D curve")
    demo_barycentric_curve()
    
    print("\nDemo 2: Color map (ℝ³) approximation")
    demo_color_approximation()
    
    print("\nDemo 3: Perturbation bound verification")
    demo_perturbation_bound()
    
    print("\nDemo 4: Simplex-valued multiclass coding")
    demo_simplex_coding()
    
    print("\nDemo 5: Embedding approximation")
    demo_embedding_approx()
    
    print("\n" + "=" * 60)
    print("All demos complete! Check the demos/ directory for plots.")
    print("=" * 60)
