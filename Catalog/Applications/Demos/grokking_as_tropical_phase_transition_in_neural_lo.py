#!/usr/bin/env python3
"""
Applications of Tropical Phase Transition Theory to Neural Networks

Demonstrates practical applications of the tropical grokking framework:
1. Early detection of grokking in training curves
2. Decision boundary analysis via tropical geometry
3. Generalization prediction from tropical order parameters
"""

import numpy as np
from typing import List, Tuple
from algorithms import TropParams, compute_class_score, compute_tropical_boundary_gap
from algorithms import compute_tropical_order_sum, detect_corner_locus
from algorithms import interpolate_params, detect_phase_transition


def application_grokking_detection():
    """
    Application 1: Early Detection of Grokking
    
    Uses the tropical order parameter as an early warning signal for
    grokking onset. The key insight: monitoring Φ (the sum of boundary gaps)
    allows detecting generalization improvement before it appears in
    standard metrics like test accuracy.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: EARLY GROKKING DETECTION")
    print("=" * 60)
    
    rng = np.random.RandomState(42)
    n, k, m = 4, 3, 3
    
    # Simulate a realistic training trajectory
    # Phase 1 (steps 0-60): memorization — large boundary gaps, high order parameter
    # Phase 2 (steps 60-80): transition — gaps start collapsing
    # Phase 3 (steps 80-100): generalization — low order parameter, good margins
    
    dataset = [rng.randn(n) for _ in range(10)]
    
    # Create trajectory with engineered phases
    W_base = rng.randn(k, m, n) * 0.5
    b_base = rng.randn(k, m) * 2.0
    
    P_memo = TropParams(W=W_base.copy(), b=b_base.copy())
    
    # Generalizing params: equalize scores for first few samples
    P_gen = TropParams(W=W_base.copy(), b=b_base.copy())
    for sample_idx in range(3):
        x = dataset[sample_idx]
        s0 = compute_class_score(P_gen, 0, x)
        s1 = compute_class_score(P_gen, 1, x)
        P_gen.b[1, 0] += (s0 - s1) / 3
    
    T = 100
    trajectory = []
    for t in range(T + 1):
        alpha = 1.0 / (1.0 + np.exp(-0.15 * (t - 70)))
        trajectory.append(interpolate_params(P_memo, P_gen, alpha))
    
    # Run phase transition detection
    result = detect_phase_transition(trajectory, dataset, window_size=10)
    
    # Simulate train/test accuracy (crude approximation)
    train_acc = [0.3 + 0.6 * min(1, t / 30) for t in range(T + 1)]
    test_acc = [0.3 + 0.5 / (1 + np.exp(-0.2 * (t - 75))) for t in range(T + 1)]
    
    print(f"\nTrajectory length: {T + 1} steps")
    print(f"Phase transition detected: {result['is_phase_transition']}")
    if result['transition_step']:
        print(f"Tropical detection step: {result['transition_step']}")
        
        # When would standard metrics detect grokking?
        std_detect = None
        for t in range(T + 1):
            if test_acc[t] > 0.6:
                std_detect = t
                break
        print(f"Standard metric detection: step {std_detect}")
        if std_detect and result['transition_step']:
            lead = std_detect - result['transition_step']
            print(f"→ Tropical detection leads by {lead} steps!")
    
    # Report order parameter values
    ops = result['order_parameters']
    print(f"\nOrder parameter at step 0: {ops[0]:.4f}")
    print(f"Order parameter at step {T//2}: {ops[T//2]:.4f}")
    print(f"Order parameter at step {T}: {ops[T]:.4f}")


def application_boundary_analysis():
    """
    Application 2: Decision Boundary Analysis
    
    Uses tropical geometry to analyze and characterize neural network
    decision boundaries. The corner locus (where class scores tie)
    gives exact equations for the boundary pieces.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: DECISION BOUNDARY ANALYSIS")
    print("=" * 60)
    
    # Create a simple 2D, 2-class tropical classifier
    params = TropParams(
        W=np.array([
            [[1.0, 0.5], [-0.5, 1.0]],  # Class 0: two pieces
            [[0.5, -0.3], [0.2, 0.8]]    # Class 1: two pieces
        ]),
        b=np.array([
            [0.0, -0.5],
            [0.3, -0.2]
        ])
    )
    
    print(f"\nClassifier: 2 classes, 2 pieces each, 2D input")
    
    # Sample the decision boundary
    boundary_points = []
    n_samples = 10000
    rng = np.random.RandomState(0)
    for _ in range(n_samples):
        x = rng.uniform(-3, 3, size=2)
        gap = compute_tropical_boundary_gap(params, x)
        if gap < 0.05:
            boundary_points.append(x)
    
    boundary_points = np.array(boundary_points)
    print(f"Found {len(boundary_points)} points near decision boundary")
    
    # Analyze boundary geometry
    if len(boundary_points) > 2:
        # Compute principal direction (boundary should be piecewise-linear)
        mean = np.mean(boundary_points, axis=0)
        centered = boundary_points - mean
        cov = centered.T @ centered / len(centered)
        eigenvalues, eigenvectors = np.linalg.eigh(cov)
        
        print(f"Boundary center: ({mean[0]:.3f}, {mean[1]:.3f})")
        print(f"Principal directions: {eigenvectors[:, -1]}")
        print(f"Variance ratio: {eigenvalues[-1]/eigenvalues[-2]:.2f}")
        print("(High ratio = nearly linear boundary)")
    
    # Check specific points
    test_points = [np.array([0.0, 0.0]), np.array([1.0, 1.0]), 
                   np.array([-1.0, 0.5])]
    print("\nPoint-by-point analysis:")
    for x in test_points:
        is_on, pair = detect_corner_locus(params, x, tol=0.1)
        gap = compute_tropical_boundary_gap(params, x)
        scores = [compute_class_score(params, c, x) for c in range(2)]
        predicted = np.argmax(scores)
        print(f"  x={x}: predicted class={predicted}, gap={gap:.4f}, "
              f"near boundary={is_on}")


def application_generalization_prediction():
    """
    Application 3: Generalization Prediction via Tropical Order Parameter
    
    Shows that the tropical order parameter can predict whether a model
    is in the memorization or generalization regime.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: GENERALIZATION PREDICTION")
    print("=" * 60)
    
    rng = np.random.RandomState(42)
    n, k, m = 3, 2, 2
    
    # Generate several different models and check correlation between
    # order parameter and generalization
    n_models = 20
    train_data = [rng.randn(n) for _ in range(8)]
    test_data = [rng.randn(n) for _ in range(20)]
    
    results = []
    for trial in range(n_models):
        params = TropParams(
            W=rng.randn(k, m, n) * (0.5 + trial * 0.15),
            b=rng.randn(k, m) * (1.0 + trial * 0.1)
        )
        
        train_op = compute_tropical_order_sum(params, train_data)
        test_op = compute_tropical_order_sum(params, test_data)
        
        # Count corner-locus events on train vs test
        train_corner = sum(1 for x in train_data 
                          if detect_corner_locus(params, x, tol=0.5)[0])
        test_corner = sum(1 for x in test_data 
                         if detect_corner_locus(params, x, tol=0.5)[0])
        
        results.append({
            'trial': trial,
            'train_order_param': train_op,
            'test_order_param': test_op,
            'train_corner_fraction': train_corner / len(train_data),
            'test_corner_fraction': test_corner / len(test_data)
        })
    
    print(f"\nAnalyzed {n_models} random tropical classifiers")
    print(f"Training set: {len(train_data)} samples, Test set: {len(test_data)} samples")
    
    # Sort by order parameter
    results.sort(key=lambda r: r['train_order_param'])
    
    print("\n{:<6} {:<15} {:<15} {:<12} {:<12}".format(
        "Trial", "Train Φ", "Test Φ", "Train CL%", "Test CL%"))
    print("-" * 60)
    for r in results[:5]:
        print("{:<6d} {:<15.4f} {:<15.4f} {:<12.1%} {:<12.1%}".format(
            r['trial'], r['train_order_param'], r['test_order_param'],
            r['train_corner_fraction'], r['test_corner_fraction']))
    print("  ...")
    for r in results[-5:]:
        print("{:<6d} {:<15.4f} {:<15.4f} {:<12.1%} {:<12.1%}".format(
            r['trial'], r['train_order_param'], r['test_order_param'],
            r['train_corner_fraction'], r['test_corner_fraction']))
    
    # Correlation analysis
    train_ops = [r['train_order_param'] for r in results]
    test_ops = [r['test_order_param'] for r in results]
    correlation = np.corrcoef(train_ops, test_ops)[0, 1]
    print(f"\nCorrelation(train Φ, test Φ): {correlation:.4f}")
    print("→ High correlation suggests order parameter transfers across datasets")


if __name__ == "__main__":
    application_grokking_detection()
    application_boundary_analysis()
    application_generalization_prediction()


#!/usr/bin/env python3
"""
Tropical Phase Transitions in Neural Loss Landscapes: Demo

Demonstrates the core mathematical framework connecting grokking (delayed
generalization) in neural networks to tropical geometry via corner-locus
crossing and order parameter collapse.

This demo:
1. Constructs concrete tropical score functions (max-plus polynomials)
2. Computes tropical boundary gaps and order parameters
3. Simulates a training trajectory that crosses a corner locus
4. Visualizes the phase transition (order parameter collapse at grokking onset)
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple
import os


# ============================================================
# Core Definitions (matching the formal Lean definitions)
# ============================================================

def class_score(W: np.ndarray, b: np.ndarray, c: int, x: np.ndarray) -> float:
    """
    Tropical (max-plus) class score: max_j (b[c,j] + sum_i W[c,j,i] * x[i])
    
    Parameters:
        W: Weight tensor of shape (k, m, n) - k classes, m pieces, n input dims
        b: Bias matrix of shape (k, m)
        c: Class index
        x: Input vector of shape (n,)
    
    Returns:
        The max-plus tropical polynomial value for class c at input x
    """
    # For each piece j, compute b[c,j] + W[c,j,:] · x
    affine_values = b[c, :] + W[c, :, :] @ x
    return np.max(affine_values)


def tropical_boundary_gap(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> float:
    """
    Minimum absolute pairwise class-score difference.
    Measures "distance to the decision boundary" in tropical geometry.
    
    Returns 0 iff x lies on the corner locus (decision boundary).
    """
    k = W.shape[0]
    scores = np.array([class_score(W, b, c, x) for c in range(k)])
    min_gap = float('inf')
    for c in range(k):
        for c_prime in range(k):
            if c != c_prime:
                gap = abs(scores[c] - scores[c_prime])
                min_gap = min(min_gap, gap)
    return min_gap


def on_corner_locus(W: np.ndarray, b: np.ndarray, x: np.ndarray, 
                     tol: float = 1e-10) -> bool:
    """Check if x lies on the corner locus (decision boundary)."""
    return tropical_boundary_gap(W, b, x) < tol


def tropical_order_sum(W: np.ndarray, b: np.ndarray, 
                        dataset: List[np.ndarray]) -> float:
    """
    Sum of boundary gaps over a dataset.
    This is the tropical order parameter (unnormalized).
    """
    return sum(tropical_boundary_gap(W, b, x) for x in dataset)


# ============================================================
# Training Trajectory Simulation
# ============================================================

def simulate_grokking_trajectory(
    n_steps: int = 100,
    n_input: int = 2,
    n_classes: int = 3,
    n_pieces: int = 2,
    seed: int = 42
) -> Tuple[List[np.ndarray], List[np.ndarray], List[np.ndarray]]:
    """
    Simulate a training trajectory that exhibits grokking behavior:
    - Early phase: memorization (high order parameter, no generalization)
    - Corner-locus crossing: order parameter collapses
    - Late phase: generalization (low order parameter)
    
    Returns:
        W_trajectory: List of weight tensors at each step
        b_trajectory: List of bias matrices at each step
        dataset: The training dataset
    """
    rng = np.random.RandomState(seed)
    
    # Create a small training dataset
    dataset = [rng.randn(n_input) for _ in range(8)]
    
    # Initial parameters (memorizing regime - large gaps, class scores well separated)
    W_init = rng.randn(n_classes, n_pieces, n_input) * 0.5
    b_init = rng.randn(n_classes, n_pieces) * 2.0
    
    # Final parameters (generalizing regime - some samples near decision boundary)
    W_final = W_init.copy()
    b_final = b_init.copy()
    
    # Engineer the final parameters so that at least one sample hits the corner locus
    # Make class 0 and class 1 scores equal at dataset[0]
    target_x = dataset[0]
    score_0 = class_score(W_final, b_final, 0, target_x)
    score_1 = class_score(W_final, b_final, 1, target_x)
    # Adjust bias to make scores equal
    b_final[1, 0] += (score_0 - score_1)
    
    # Interpolate parameters along the trajectory
    W_traj = []
    b_traj = []
    for t in range(n_steps):
        alpha = t / (n_steps - 1)
        # Use a sigmoid-like schedule for more realistic dynamics
        alpha_smooth = 1.0 / (1.0 + np.exp(-10 * (alpha - 0.7)))
        W_t = (1 - alpha_smooth) * W_init + alpha_smooth * W_final
        b_t = (1 - alpha_smooth) * b_init + alpha_smooth * b_final
        W_traj.append(W_t)
        b_traj.append(b_t)
    
    return W_traj, b_traj, dataset


# ============================================================
# Visualization
# ============================================================

def plot_order_parameter_trajectory(save_path: str = "order_parameter_trajectory.png"):
    """
    Plot the tropical order parameter along a simulated training trajectory,
    showing the phase transition (sharp collapse) at grokking onset.
    """
    W_traj, b_traj, dataset = simulate_grokking_trajectory(n_steps=200)
    
    # Compute order parameter at each step
    order_params = []
    boundary_gaps_sample0 = []
    corner_locus_flags = []
    
    for W, b in zip(W_traj, b_traj):
        op = tropical_order_sum(W, b, dataset)
        order_params.append(op)
        bg = tropical_boundary_gap(W, b, dataset[0])
        boundary_gaps_sample0.append(bg)
        cl = on_corner_locus(W, b, dataset[0])
        corner_locus_flags.append(cl)
    
    steps = np.arange(len(order_params))
    
    fig, axes = plt.subplots(2, 1, figsize=(10, 8), sharex=True)
    
    # Top: Order parameter
    ax1 = axes[0]
    ax1.plot(steps, order_params, 'b-', linewidth=2, label='Tropical Order Parameter Φ')
    ax1.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Critical threshold (Φ = 0)')
    
    # Mark the transition region
    transition_idx = None
    for i, cl in enumerate(corner_locus_flags):
        if cl and transition_idx is None:
            transition_idx = i
    if transition_idx is not None:
        ax1.axvline(x=transition_idx, color='orange', linestyle=':', linewidth=2,
                    label=f'Corner-locus crossing (step {transition_idx})')
    
    ax1.set_ylabel('Order Parameter Φ', fontsize=12)
    ax1.set_title('Tropical Phase Transition: Order Parameter Collapse at Grokking Onset',
                  fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Bottom: Boundary gap for sample 0
    ax2 = axes[1]
    ax2.plot(steps, boundary_gaps_sample0, 'g-', linewidth=2, 
             label='Boundary gap (sample 0)')
    ax2.axhline(y=0, color='r', linestyle='--', alpha=0.5)
    if transition_idx is not None:
        ax2.axvline(x=transition_idx, color='orange', linestyle=':', linewidth=2)
    ax2.set_xlabel('Training Step', fontsize=12)
    ax2.set_ylabel('Tropical Boundary Gap', fontsize=12)
    ax2.set_title('Witness Sample: Gap Collapses to Zero at Decision Boundary',
                  fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")
    return order_params, boundary_gaps_sample0


def plot_decision_boundary_2d(save_path: str = "decision_boundary.png"):
    """
    Visualize the tropical decision boundary (corner locus) in 2D input space.
    Shows how the piecewise-linear score functions create a tropical hypersurface.
    """
    # Simple 2-class, 2-piece model in 2D
    W = np.array([
        # Class 0: two pieces
        [[1.0, 0.5], [-0.5, 1.0]],
        # Class 1: two pieces
        [[0.5, -0.3], [0.2, 0.8]]
    ])
    b = np.array([
        [0.0, -0.5],  # Class 0 biases
        [0.3, -0.2]   # Class 1 biases
    ])
    
    # Grid
    x_range = np.linspace(-3, 3, 300)
    y_range = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x_range, y_range)
    
    # Compute score gap |s0 - s1| at each point
    gap_grid = np.zeros_like(X)
    score0_grid = np.zeros_like(X)
    score1_grid = np.zeros_like(X)
    
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            x = np.array([X[i, j], Y[i, j]])
            s0 = class_score(W, b, 0, x)
            s1 = class_score(W, b, 1, x)
            score0_grid[i, j] = s0
            score1_grid[i, j] = s1
            gap_grid[i, j] = abs(s0 - s1)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Score difference heatmap with corner locus
    ax1 = axes[0]
    diff = score0_grid - score1_grid
    im = ax1.contourf(X, Y, diff, levels=50, cmap='RdBu_r', alpha=0.8)
    ax1.contour(X, Y, diff, levels=[0], colors='black', linewidths=3)
    plt.colorbar(im, ax=ax1, label='Score gap (class 0 - class 1)')
    ax1.set_xlabel('x₁', fontsize=12)
    ax1.set_ylabel('x₂', fontsize=12)
    ax1.set_title('Tropical Score Difference\n(Black = Corner Locus / Decision Boundary)',
                  fontsize=13)
    ax1.grid(True, alpha=0.2)
    
    # Right: Boundary gap (distance to decision boundary)
    ax2 = axes[1]
    im2 = ax2.contourf(X, Y, gap_grid, levels=50, cmap='viridis_r', alpha=0.8)
    ax2.contour(X, Y, gap_grid, levels=[0.01], colors='red', linewidths=2, linestyles='--')
    plt.colorbar(im2, ax=ax2, label='Tropical Boundary Gap')
    ax2.set_xlabel('x₁', fontsize=12)
    ax2.set_ylabel('x₂', fontsize=12)
    ax2.set_title('Tropical Boundary Gap\n(Dark = Near Decision Boundary)',
                  fontsize=13)
    ax2.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")


def plot_discrete_sign_change(save_path: str = "discrete_sign_change.png"):
    """
    Visualize the discrete intermediate value theorem (Theorem C):
    when a score gap changes sign along a training trajectory,
    there must be a crossing point.
    """
    # Simulate a score gap that changes sign
    T = 30
    t = np.arange(T + 1)
    
    # Score gap: starts negative (class c' ahead), ends positive (class c ahead)
    gap = -2.0 + 4.0 / (1 + np.exp(-0.3 * (t - 15)))
    # Add some noise to make it non-monotone
    rng = np.random.RandomState(123)
    gap += rng.randn(T + 1) * 0.3
    # Ensure start < 0 and end > 0
    gap[0] = -1.8
    gap[-1] = 1.9
    
    # Find the crossing point
    crossing_idx = None
    for i in range(T):
        if gap[i] <= 0 and gap[i + 1] >= 0:
            crossing_idx = i
            break
    
    fig, ax = plt.subplots(figsize=(10, 5))
    
    # Color bars by sign
    colors = ['#d63031' if g < 0 else '#00b894' for g in gap]
    ax.bar(t, gap, color=colors, alpha=0.7, edgecolor='white', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=1.5)
    
    if crossing_idx is not None:
        ax.axvline(x=crossing_idx + 0.5, color='orange', linewidth=3, 
                   linestyle='--', label=f'Sign change at step {crossing_idx}→{crossing_idx+1}')
        ax.annotate('Corner-locus\ncrossing', 
                    xy=(crossing_idx + 0.5, 0), xytext=(crossing_idx + 5, gap.max() * 0.7),
                    fontsize=11, fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='orange', lw=2),
                    color='orange')
    
    ax.set_xlabel('Training Step', fontsize=12)
    ax.set_ylabel('Score Gap (class c - class c\')', fontsize=12)
    ax.set_title('Discrete Sign-Change Theorem: Score Gap Reversal Forces Boundary Crossing',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Add annotations
    ax.text(2, gap[0] - 0.3, "c' leads\n(memorizing)", fontsize=10, 
            color='#d63031', fontweight='bold')
    ax.text(T - 7, gap[-1] + 0.2, "c leads\n(generalizing)", fontsize=10, 
            color='#00b894', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")


def print_numerical_demo():
    """Print a concrete numerical demonstration of the theorems."""
    print("=" * 70)
    print("TROPICAL PHASE TRANSITION: NUMERICAL DEMONSTRATION")
    print("=" * 70)
    
    # Simple 2D, 3-class, 2-piece model
    n, k, m = 2, 3, 2
    
    # Parameters before grokking (well-separated classes)
    W_before = np.array([
        [[2.0, 0.0], [0.0, 1.0]],   # Class 0
        [[0.0, 2.0], [1.0, 0.0]],   # Class 1  
        [[-1.0, -1.0], [0.5, 0.5]]  # Class 2
    ])
    b_before = np.array([
        [1.0, -1.0],
        [0.5, -0.5],
        [-2.0, -3.0]
    ])
    
    # Parameters after grokking (classes 0 and 1 scores equalized at x0)
    x0 = np.array([1.0, 1.0])
    s0_before = class_score(W_before, b_before, 0, x0)
    s1_before = class_score(W_before, b_before, 1, x0)
    
    W_after = W_before.copy()
    b_after = b_before.copy()
    b_after[1, 0] += (s0_before - s1_before)
    
    dataset = [np.array([1.0, 1.0]), np.array([-1.0, 0.5]), 
               np.array([0.5, -1.0]), np.array([0.0, 0.0])]
    
    print(f"\nInput dimension: {n}, Classes: {k}, Pieces per class: {m}")
    print(f"Dataset size: {len(dataset)}")
    
    print("\n--- BEFORE CORNER-LOCUS CROSSING ---")
    for i, x in enumerate(dataset):
        scores = [class_score(W_before, b_before, c, x) for c in range(k)]
        gap = tropical_boundary_gap(W_before, b_before, x)
        on_cl = on_corner_locus(W_before, b_before, x)
        print(f"  Sample {i} ({x}): scores={[f'{s:.3f}' for s in scores]}, "
              f"gap={gap:.4f}, on_corner_locus={on_cl}")
    
    op_before = tropical_order_sum(W_before, b_before, dataset)
    print(f"  Tropical Order Parameter: {op_before:.4f}")
    
    print("\n--- AFTER CORNER-LOCUS CROSSING ---")
    for i, x in enumerate(dataset):
        scores = [class_score(W_after, b_after, c, x) for c in range(k)]
        gap = tropical_boundary_gap(W_after, b_after, x)
        on_cl = on_corner_locus(W_after, b_after, x)
        print(f"  Sample {i} ({x}): scores={[f'{s:.3f}' for s in scores]}, "
              f"gap={gap:.4f}, on_corner_locus={on_cl}")
    
    op_after = tropical_order_sum(W_after, b_after, dataset)
    print(f"  Tropical Order Parameter: {op_after:.4f}")
    
    print(f"\n--- THEOREM VERIFICATION ---")
    print(f"  Theorem A: Sample 0 on corner locus after = {on_corner_locus(W_after, b_after, dataset[0])}")
    print(f"    ↔ boundary gap = 0: {tropical_boundary_gap(W_after, b_after, dataset[0]):.10f}")
    print(f"  Theorem B: Order param dropped: {op_after:.4f} < {op_before:.4f} = {op_after < op_before}")
    print(f"    Strict drop: {op_before - op_after:.4f}")
    print()


if __name__ == "__main__":
    print_numerical_demo()
    
    # Generate visualizations
    os.makedirs("figures", exist_ok=True)
    plot_order_parameter_trajectory("figures/order_parameter_trajectory.png")
    plot_decision_boundary_2d("figures/decision_boundary.png")
    plot_discrete_sign_change("figures/discrete_sign_change.png")
    
    print("\nAll demos and visualizations generated successfully.")
