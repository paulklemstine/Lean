#!/usr/bin/env python3
"""
Applications of Tropical Grokking Theory

Demonstrates how the tropical grokking framework applies to:
1. Modular arithmetic learning (the classic grokking setting)
2. ReLU network score tropicalization
3. Grokking prediction in toy models
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(x, 0)."""
    return np.maximum(x, 0)


def simulate_modular_arithmetic_grokking(
    p: int = 7,
    epochs: int = 2000,
    lr: float = 0.01,
    wd: float = 0.01,
    hidden: int = 32,
    seed: int = 42
) -> Tuple[List[float], List[float], List[float]]:
    """Simulate grokking on modular addition task a + b (mod p).

    Uses a simple 2-layer ReLU network trained on a subset of the data.
    Tracks train loss, test accuracy, and a tropical margin proxy.

    Args:
        p: Prime modulus
        epochs: Number of training epochs
        lr: Learning rate
        wd: Weight decay
        hidden: Hidden layer size
        seed: Random seed

    Returns:
        Tuple of (train_losses, test_accuracies, margin_proxies)
    """
    np.random.seed(seed)

    # Generate data: all (a, b) pairs with label (a + b) mod p
    data = []
    for a in range(p):
        for b in range(p):
            # One-hot encode input
            x = np.zeros(2 * p)
            x[a] = 1.0
            x[p + b] = 1.0
            y = (a + b) % p
            data.append((x, y))

    # Train/test split (30% train, 70% test — classic grokking setup)
    np.random.shuffle(data)
    n_train = max(len(data) * 3 // 10, 1)
    train_data = data[:n_train]
    test_data = data[n_train:]

    n_in = 2 * p
    n_out = p

    # Initialize network: x -> W1*x + b1 -> ReLU -> W2*h + b2
    W1 = np.random.randn(hidden, n_in) * 0.1
    b1 = np.zeros(hidden)
    W2 = np.random.randn(n_out, hidden) * 0.1
    b2 = np.zeros(n_out)

    train_losses = []
    test_accs = []
    margin_proxies = []

    for epoch in range(epochs):
        # Forward pass on train
        total_loss = 0.0
        correct_train = 0

        for x, y in train_data:
            # Forward
            h = relu(W1 @ x + b1)
            logits = W2 @ h + b2

            # Softmax cross-entropy loss
            logits_shifted = logits - np.max(logits)
            probs = np.exp(logits_shifted) / np.sum(np.exp(logits_shifted))
            loss = -np.log(probs[y] + 1e-10)
            total_loss += loss

            if np.argmin(-logits) == y:
                correct_train += 1

            # Backward (simplified SGD)
            grad_logits = probs.copy()
            grad_logits[y] -= 1.0

            grad_W2 = np.outer(grad_logits, h)
            grad_b2 = grad_logits
            grad_h = W2.T @ grad_logits
            grad_pre = grad_h * (W1 @ x + b1 > 0).astype(float)
            grad_W1 = np.outer(grad_pre, x)
            grad_b1 = grad_pre

            # Update with weight decay
            W2 -= lr * (grad_W2 + wd * W2)
            b2 -= lr * grad_b2
            W1 -= lr * (grad_W1 + wd * W1)
            b1 -= lr * grad_b1

        train_losses.append(total_loss / len(train_data))

        # Test accuracy
        correct = 0
        total_margin = 0.0
        for x, y in test_data:
            h = relu(W1 @ x + b1)
            logits = W2 @ h + b2
            if np.argmin(-logits) == y:
                correct += 1
            # Margin proxy: gap between correct class and best competitor
            sorted_logits = np.sort(logits)[::-1]
            if np.argmax(logits) == y:
                margin = sorted_logits[0] - sorted_logits[1]
            else:
                margin = logits[y] - np.max([logits[j] for j in range(n_out) if j != y])
            total_margin += margin

        test_accs.append(correct / len(test_data))
        margin_proxies.append(total_margin / len(test_data))

    return train_losses, test_accs, margin_proxies


def tropical_relu_network_analysis():
    """Analyze a ReLU network as a tropical polynomial.

    A single ReLU neuron max(w·x + b, 0) is already a tropical polynomial
    (maximum of two affine forms). A composition of ReLU layers produces
    a piecewise-linear function that can be represented as a tropical
    rational function.

    This demo shows how the active linear regions of a small ReLU network
    correspond to tropical cells, and how training moves between them.
    """
    print("=" * 60)
    print("Application: ReLU Network as Tropical Polynomial")
    print("=" * 60)

    # Small network: R^2 -> R with 3 ReLU neurons
    # Neuron i computes max(w_i · x + b_i, 0)
    # Output = sum of neurons (before training)

    W = np.array([
        [1.0, 0.5],
        [-0.3, 1.0],
        [0.7, -0.8]
    ])
    b = np.array([-0.5, -0.2, 0.3])
    v = np.array([1.0, 1.0, 1.0])  # output weights

    def network(x):
        h = np.maximum(W @ x + b, 0)
        return np.dot(v, h)

    # Compute linear regions on a grid
    x_range = np.linspace(-2, 2, 200)
    y_range = np.linspace(-2, 2, 200)
    X, Y = np.meshgrid(x_range, y_range)

    # For each point, compute which neurons are active
    region_ids = np.zeros_like(X, dtype=int)
    output = np.zeros_like(X)

    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            x = np.array([X[i,j], Y[i,j]])
            activations = W @ x + b
            active = tuple(int(a > 0) for a in activations)
            region_ids[i,j] = active[0] * 4 + active[1] * 2 + active[2]
            output[i,j] = network(x)

    n_regions = len(np.unique(region_ids))
    print(f"\nNetwork has {n_regions} distinct linear regions")
    print(f"(These correspond to tropical cells in the dual picture)")

    # Count transitions along a path
    path_t = np.linspace(0, 1, 100)
    path = np.array([[-1.5, -1.5]]) + np.outer(path_t, np.array([3.0, 3.0]))
    path_regions = []
    for pt in path:
        activations = W @ pt + b
        active = tuple(int(a > 0) for a in activations)
        path_regions.append(active[0] * 4 + active[1] * 2 + active[2])

    crossings = sum(1 for i in range(len(path_regions)-1)
                    if path_regions[i] != path_regions[i+1])
    print(f"Path from (-1.5,-1.5) to (1.5,1.5) crosses {crossings} cell boundaries")

    return X, Y, region_ids, output


def visualize_grokking_application():
    """Create visualization of grokking in modular arithmetic."""
    print("\n" + "=" * 60)
    print("Application: Grokking in Modular Arithmetic")
    print("=" * 60)

    train_losses, test_accs, margin_proxies = simulate_modular_arithmetic_grokking(
        p=7, epochs=1500, lr=0.005, wd=0.005, hidden=48
    )

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Grokking in Modular Arithmetic: Tropical Perspective',
                 fontsize=14, fontweight='bold')

    epochs = range(len(train_losses))

    # Panel 1: Train loss
    axes[0].semilogy(epochs, train_losses, 'b-', linewidth=1.5)
    axes[0].set_xlabel('Epoch', fontsize=11)
    axes[0].set_ylabel('Train Loss', fontsize=11)
    axes[0].set_title('Training Loss (Continuous Descent)', fontsize=12)
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Test accuracy
    axes[1].plot(epochs, test_accs, 'r-', linewidth=1.5)
    axes[1].set_xlabel('Epoch', fontsize=11)
    axes[1].set_ylabel('Test Accuracy', fontsize=11)
    axes[1].set_title('Test Accuracy (Delayed Jump)', fontsize=12)
    axes[1].grid(True, alpha=0.3)
    axes[1].set_ylim(-0.05, 1.05)

    # Panel 3: Margin proxy
    axes[2].plot(epochs, margin_proxies, 'g-', linewidth=1.5)
    axes[2].set_xlabel('Epoch', fontsize=11)
    axes[2].set_ylabel('Avg. Decision Margin', fontsize=11)
    axes[2].set_title('Decision Margin (Phase Transition)', fontsize=12)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/grokking_application.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Grokking application plot saved to grokking_application.png")


if __name__ == '__main__':
    X, Y, regions, output = tropical_relu_network_analysis()
    visualize_grokking_application()
    print("\nAll applications completed!")


#!/usr/bin/env python3
"""
Tropical Grokking Demo: Phase Transitions in Piecewise-Linear Loss Landscapes

This script demonstrates the core mathematical framework connecting delayed
generalization (grokking) with tropical geometry. It shows how:

1. Tropical polynomials (minima of affine forms) create piecewise-linear landscapes
2. Active sets partition parameter space into tropical cells
3. Corner-locus crossings cause discontinuous changes in decision margin
4. The degeneracy index serves as an order parameter predicting grokking

Run: python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.patches as mpatches

# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def eval_affine(w, b, x):
    """Evaluate affine form w·x + b."""
    return np.dot(w, x) + b

def trop_poly(forms, x):
    """Tropical polynomial: minimum of affine forms at x."""
    return min(eval_affine(w, b, x) for w, b in forms)

def active_set(forms, x):
    """Active set: indices of forms achieving the minimum."""
    val = trop_poly(forms, x)
    return frozenset(i for i, (w, b) in enumerate(forms)
                     if abs(eval_affine(w, b, x) - val) < 1e-12)

def margin_from_scores(scores, y_true):
    """Decision margin: min_{j≠y} (score_j - score_y)."""
    return min(scores[j] - scores[y_true]
               for j in range(len(scores)) if j != y_true)

def degeneracy_index(scores, y_true, delta):
    """Count of classes within delta of the decision boundary."""
    return sum(1 for j in range(len(scores))
               if j != y_true and scores[j] - scores[y_true] <= delta)


# ============================================================
# Example 1: 2D Corner Crossing (matching Lean example)
# ============================================================

def demo_corner_crossing():
    """Demonstrate active set change and corner crossing in 2D."""
    print("=" * 60)
    print("DEMO 1: Corner Crossing in 2D")
    print("=" * 60)

    # Two affine forms: f1(x) = x1, f2(x) = x2 - 1
    forms = [
        (np.array([1.0, 0.0]), 0.0),   # f1(x) = x1
        (np.array([0.0, 1.0]), -1.0),  # f2(x) = x2 - 1
    ]

    # Point A: (2, 0) -> min(2, -1) = -1, active: f2
    x_a = np.array([2.0, 0.0])
    val_a = trop_poly(forms, x_a)
    active_a = active_set(forms, x_a)
    print(f"\nPoint A = (2, 0):")
    print(f"  f1(A) = {eval_affine(*forms[0], x_a):.1f}")
    print(f"  f2(A) = {eval_affine(*forms[1], x_a):.1f}")
    print(f"  TropPoly(A) = {val_a:.1f}")
    print(f"  Active set = {active_a}")

    # Point B: (0, 2) -> min(0, 1) = 0, active: f1
    x_b = np.array([0.0, 2.0])
    val_b = trop_poly(forms, x_b)
    active_b = active_set(forms, x_b)
    print(f"\nPoint B = (0, 2):")
    print(f"  f1(B) = {eval_affine(*forms[0], x_b):.1f}")
    print(f"  f2(B) = {eval_affine(*forms[1], x_b):.1f}")
    print(f"  TropPoly(B) = {val_b:.1f}")
    print(f"  Active set = {active_b}")

    is_crossing = active_a != active_b
    print(f"\nCorner crossing detected: {is_crossing}")
    print(f"  Active sets differ: {active_a} ≠ {active_b}")

    return forms


# ============================================================
# Example 2: Grokking Trajectory Simulation
# ============================================================

def demo_grokking_trajectory():
    """Simulate a training trajectory that exhibits grokking."""
    print("\n" + "=" * 60)
    print("DEMO 2: Grokking Trajectory Simulation")
    print("=" * 60)

    # Setup: 2 classes, each with 3 affine forms in R^2
    # Class 0 (true class) score forms
    class0_forms = [
        (np.array([1.0, 0.5]), -2.0),
        (np.array([0.3, 1.0]), -1.5),
        (np.array([0.7, 0.7]), -1.0),
    ]

    # Class 1 (competitor) score forms
    class1_forms = [
        (np.array([0.8, 0.3]), -1.8),
        (np.array([0.2, 0.9]), -1.2),
        (np.array([0.5, 0.6]), -0.8),
    ]

    def score(x):
        s0 = trop_poly(class0_forms, x)
        s1 = trop_poly(class1_forms, x)
        return [s0, s1]

    # Training trajectory: starts in one cell, crosses to another
    T = 50
    trajectory = []
    for t in range(T):
        if t < 30:
            # Phase 1: slow drift within a cell (memorization)
            theta = np.array([0.5 + 0.02 * t, 0.3 + 0.01 * t])
        elif t < 35:
            # Phase 2: crossing the corner locus (transition)
            theta = np.array([1.1 + 0.15 * (t - 30), 0.6 + 0.12 * (t - 30)])
        else:
            # Phase 3: settled in new cell (generalization)
            theta = np.array([1.85 + 0.01 * (t - 35), 1.2 + 0.005 * (t - 35)])
        trajectory.append(theta)

    # Compute metrics along trajectory
    margins = []
    degeneracies = []
    active_sets_class0 = []
    delta = 0.3  # degeneracy threshold

    for t, theta in enumerate(trajectory):
        scores = score(theta)
        m = margin_from_scores(scores, 0)
        d = degeneracy_index(scores, 0, delta)
        a = active_set(class0_forms, theta)
        margins.append(m)
        degeneracies.append(d)
        active_sets_class0.append(a)

    # Find grokking onset
    margin_jumps = [(t, margins[t+1] - margins[t])
                    for t in range(len(margins)-1)
                    if margins[t+1] - margins[t] > 0.05]

    print(f"\nTrajectory length: {T} steps")
    print(f"Margin range: [{min(margins):.4f}, {max(margins):.4f}]")
    print(f"\nSignificant margin jumps (ε > 0.05):")
    for t, jump in margin_jumps:
        print(f"  t={t}: Δmargin = {jump:.4f}")
        if t > 0:
            print(f"    Active set before: {active_sets_class0[t-1]}")
            print(f"    Active set after:  {active_sets_class0[t+1]}")
            if active_sets_class0[t-1] != active_sets_class0[t+1]:
                print(f"    → CORNER CROSSING DETECTED!")

    # Detect degeneracy drops
    for t in range(len(degeneracies)-1):
        if degeneracies[t+1] < degeneracies[t]:
            print(f"\nDegeneracy drop at t={t}: "
                  f"{degeneracies[t]} → {degeneracies[t+1]}")

    return trajectory, margins, degeneracies, active_sets_class0


# ============================================================
# Example 3: Tropical Cell Decomposition Visualization
# ============================================================

def demo_cell_decomposition():
    """Visualize the tropical cell decomposition of a 2D parameter space."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Cell Decomposition")
    print("=" * 60)

    # 3 affine forms in R^2
    forms = [
        (np.array([1.0, 0.0]), 0.0),    # f1 = x1
        (np.array([0.0, 1.0]), 0.0),    # f2 = x2
        (np.array([-0.5, -0.5]), 2.0),  # f3 = -0.5x1 - 0.5x2 + 2
    ]

    # Grid
    x_range = np.linspace(-1, 4, 200)
    y_range = np.linspace(-1, 4, 200)
    X, Y = np.meshgrid(x_range, y_range)

    # Compute active form index at each point
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            x = np.array([X[i,j], Y[i,j]])
            vals = [eval_affine(w, b, x) for w, b in forms]
            Z[i,j] = np.argmin(vals)

    print(f"Cell decomposition computed on {X.shape[0]}x{X.shape[1]} grid")
    print(f"Number of distinct cells: {len(np.unique(Z))}")

    return X, Y, Z, forms


# ============================================================
# Visualization
# ============================================================

def create_visualizations(trajectory, margins, degeneracies, active_sets,
                          X, Y, Z, cell_forms):
    """Create publication-quality visualizations."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Tropical Grokking: Phase Transitions in Loss Landscapes',
                 fontsize=16, fontweight='bold', y=0.98)

    # --- Panel 1: Cell Decomposition ---
    ax1 = axes[0, 0]
    cmap = LinearSegmentedColormap.from_list('tropical',
        ['#2196F3', '#4CAF50', '#FF9800'], N=3)
    im = ax1.pcolormesh(X, Y, Z, cmap=cmap, alpha=0.7, shading='auto')

    # Draw corner locus (boundaries between cells)
    ax1.contour(X, Y, Z, levels=[0.5, 1.5], colors='black',
                linewidths=2, linestyles='--')

    ax1.set_xlabel('θ₁', fontsize=12)
    ax1.set_ylabel('θ₂', fontsize=12)
    ax1.set_title('Tropical Cell Decomposition', fontsize=13, fontweight='bold')

    patches = [mpatches.Patch(color='#2196F3', label='Cell 0 (f₁ active)'),
               mpatches.Patch(color='#4CAF50', label='Cell 1 (f₂ active)'),
               mpatches.Patch(color='#FF9800', label='Cell 2 (f₃ active)')]
    ax1.legend(handles=patches, loc='upper right', fontsize=9)

    # --- Panel 2: Margin Evolution ---
    ax2 = axes[0, 1]
    t_vals = range(len(margins))
    ax2.plot(t_vals, margins, 'b-', linewidth=2, label='Decision Margin')

    # Highlight grokking onset
    for t in range(len(margins)-1):
        if margins[t+1] - margins[t] > 0.05:
            ax2.axvline(x=t, color='red', linestyle='--', alpha=0.7)
            ax2.annotate('Grokking\nOnset', xy=(t, margins[t]),
                        xytext=(t+3, margins[t]+0.1),
                        arrowprops=dict(arrowstyle='->', color='red'),
                        fontsize=10, color='red', fontweight='bold')
            break

    ax2.set_xlabel('Training Step t', fontsize=12)
    ax2.set_ylabel('Decision Margin', fontsize=12)
    ax2.set_title('Margin Jump at Corner Crossing', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Degeneracy Index (Order Parameter) ---
    ax3 = axes[1, 0]
    ax3.step(t_vals, degeneracies, 'g-', linewidth=2, where='mid',
             label='Degeneracy Index Φ(θₜ)')
    ax3.fill_between(t_vals, degeneracies, alpha=0.2, color='green', step='mid')

    # Highlight drop
    for t in range(len(degeneracies)-1):
        if degeneracies[t+1] < degeneracies[t]:
            ax3.annotate('Φ drops\n(predicts grokking)',
                        xy=(t, degeneracies[t]),
                        xytext=(t+5, degeneracies[t]+0.3),
                        arrowprops=dict(arrowstyle='->', color='darkgreen'),
                        fontsize=10, color='darkgreen', fontweight='bold')
            break

    ax3.set_xlabel('Training Step t', fontsize=12)
    ax3.set_ylabel('Degeneracy Index Φ', fontsize=12)
    ax3.set_title('Order Parameter Predicts Grokking', fontsize=13, fontweight='bold')
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(-0.1, max(degeneracies) + 0.5)

    # --- Panel 4: Active Set Changes ---
    ax4 = axes[1, 1]
    # Encode active sets as integers for plotting
    unique_sets = list(set(active_sets))
    set_to_idx = {s: i for i, s in enumerate(unique_sets)}
    active_indices = [set_to_idx[s] for s in active_sets]

    ax4.step(t_vals, active_indices, 'purple', linewidth=2, where='mid')
    ax4.fill_between(t_vals, active_indices, alpha=0.15, color='purple', step='mid')

    # Mark transitions
    for t in range(len(active_indices)-1):
        if active_indices[t] != active_indices[t+1]:
            ax4.axvline(x=t+0.5, color='red', linestyle=':', alpha=0.8)

    ax4.set_xlabel('Training Step t', fontsize=12)
    ax4.set_ylabel('Active Cell Index', fontsize=12)
    ax4.set_title('Active Set (Tropical Cell) Evolution', fontsize=13, fontweight='bold')
    ax4.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('/workspace/request-project/tropical_grokking_visualization.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\nVisualization saved to tropical_grokking_visualization.png")


def create_phase_diagram():
    """Create a phase diagram showing grokking regions."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Parameter space: vary two hyperparameters
    lr_range = np.linspace(0.01, 0.5, 100)
    wd_range = np.linspace(0.0, 0.1, 100)
    LR, WD = np.meshgrid(lr_range, wd_range)

    # Simulated grokking time (higher = later grokking)
    # Models the empirical observation that grokking time depends on
    # learning rate and weight decay
    grokking_time = np.exp(3.0 / (LR + 0.01)) * np.exp(-30 * WD)
    grokking_time = np.clip(grokking_time, 0, 1000)

    im = ax.pcolormesh(LR, WD, np.log10(grokking_time + 1),
                       cmap='RdYlBu_r', shading='auto')
    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('log₁₀(Grokking Time)', fontsize=11)

    # Phase boundaries
    ax.contour(LR, WD, grokking_time, levels=[50, 200, 500],
               colors='black', linewidths=1.5, linestyles=['--', '-', '-.'])

    ax.set_xlabel('Learning Rate', fontsize=12)
    ax.set_ylabel('Weight Decay', fontsize=12)
    ax.set_title('Phase Diagram: Grokking Time in Hyperparameter Space',
                 fontsize=13, fontweight='bold')

    # Annotate regions
    ax.text(0.35, 0.08, 'Fast\nGeneralization', fontsize=11,
            ha='center', color='white', fontweight='bold')
    ax.text(0.1, 0.01, 'Delayed\nGrokking', fontsize=11,
            ha='center', color='darkred', fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/phase_diagram.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Phase diagram saved to phase_diagram.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    # Demo 1: Basic corner crossing
    forms = demo_corner_crossing()

    # Demo 2: Full grokking trajectory
    trajectory, margins, degeneracies, active_sets = demo_grokking_trajectory()

    # Demo 3: Cell decomposition
    X, Y, Z, cell_forms = demo_cell_decomposition()

    # Create visualizations
    create_visualizations(trajectory, margins, degeneracies, active_sets,
                          X, Y, Z, cell_forms)
    create_phase_diagram()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
