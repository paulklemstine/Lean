"""
Applications of Closure-Operator Network Theory

Demonstrates real-world applications of the universal approximation
and certified robustness theorems:

1. Robust image classification with certified perturbation bounds
2. Anomaly detection with closure-based decision regions  
3. Safe control: certified invariant sets via closure operators
4. Signal denoising using idempotent morphological networks
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List


# ============================================================================
# Application 1: Robust Binary Classification
# ============================================================================

def robust_classifier_demo():
    """
    Builds a closure-operator binary classifier on 2D data with
    certified robustness guarantees.
    
    The classifier:
    1. Partitions ℝ² into Voronoi cells (closure regions)
    2. Assigns labels based on training data
    3. Certifies robustness radius at each point
    """
    print("=" * 60)
    print("APPLICATION 1: Robust Binary Classification")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Generate 2-class spiral dataset
    n_per_class = 100
    theta = np.linspace(0, 3 * np.pi, n_per_class)
    
    r1 = 0.5 + theta / (3 * np.pi)
    x1 = np.column_stack([r1 * np.cos(theta), r1 * np.sin(theta)])
    x1 += np.random.randn(n_per_class, 2) * 0.08
    
    r2 = 0.5 + theta / (3 * np.pi)
    x2 = np.column_stack([r2 * np.cos(theta + np.pi), r2 * np.sin(theta + np.pi)])
    x2 += np.random.randn(n_per_class, 2) * 0.08
    
    X = np.vstack([x1, x2])
    y = np.array([1] * n_per_class + [-1] * n_per_class)
    
    # Build closure-network classifier
    # Centers = training points, values = labels
    # This gives a Voronoi partition (closure regions)
    from scipy.spatial import KDTree
    tree = KDTree(X)
    
    # Evaluate on grid
    xx = np.linspace(-2, 2, 200)
    yy = np.linspace(-2, 2, 200)
    XX, YY = np.meshgrid(xx, yy)
    grid_points = np.column_stack([XX.ravel(), YY.ravel()])
    
    # Nearest-neighbor classification
    dists, idx = tree.query(grid_points)
    predictions = y[idx]
    
    # Certified robustness: distance to nearest point with different label
    cert_radius = np.zeros(len(grid_points))
    for i, (pt, pred) in enumerate(zip(grid_points, predictions)):
        # Find nearest point with opposite label
        opp_mask = y != pred
        opp_dists = np.linalg.norm(X[opp_mask] - pt, axis=1)
        nearest_same = dists[i]
        nearest_opp = np.min(opp_dists)
        cert_radius[i] = max(0, (nearest_opp - nearest_same) / 2)
    
    avg_radius = np.mean(cert_radius[cert_radius > 0])
    print(f"  Training points: {len(X)}")
    print(f"  Average certified radius: {avg_radius:.4f}")
    print(f"  Fraction with positive certification: "
          f"{np.mean(cert_radius > 0.01):.2%}")
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    Z = predictions.reshape(XX.shape)
    axes[0].contourf(XX, YY, Z, levels=[-1.5, 0, 1.5], colors=['#ff9999', '#9999ff'], alpha=0.5)
    axes[0].scatter(x1[:, 0], x1[:, 1], c='blue', s=20, label='Class +1')
    axes[0].scatter(x2[:, 0], x2[:, 1], c='red', s=20, label='Class -1')
    axes[0].set_title('Closure-Network Classifier')
    axes[0].legend()
    axes[0].set_aspect('equal')
    
    R = cert_radius.reshape(XX.shape)
    im = axes[1].imshow(R, extent=[-2, 2, -2, 2], origin='lower', cmap='YlGn')
    axes[1].set_title('Certified Robustness Radius')
    plt.colorbar(im, ax=axes[1])
    axes[1].set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('app_robust_classifier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Plot saved to app_robust_classifier.png")


# ============================================================================
# Application 2: Signal Denoising via Idempotent Operators
# ============================================================================

def signal_denoising_demo():
    """
    Uses composition of closure operators (morphological opening/closing)
    to denoise a signal. The idempotence property ensures stability:
    applying the filter twice gives the same result as once.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Signal Denoising via Closure Operators")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Clean signal
    t = np.linspace(0, 1, 500)
    clean = np.sin(4 * np.pi * t) + 0.5 * np.sin(8 * np.pi * t)
    
    # Add noise
    noisy = clean + np.random.randn(len(t)) * 0.3
    
    # Morphological closure operators
    def dilation(signal, width=5):
        """Max filter (dilation) — a closure operator."""
        from scipy.ndimage import maximum_filter1d
        return maximum_filter1d(signal, size=width)
    
    def erosion(signal, width=5):
        """Min filter (erosion)."""
        from scipy.ndimage import minimum_filter1d
        return minimum_filter1d(signal, size=width)
    
    def opening(signal, width=5):
        """Morphological opening = erosion then dilation."""
        return dilation(erosion(signal, width), width)
    
    def closing(signal, width=5):
        """Morphological closing = dilation then erosion."""
        return erosion(dilation(signal, width), width)
    
    # Apply closure composition: opening then closing (alternating filter)
    width = 7
    filtered = closing(opening(noisy, width), width)
    
    # Verify idempotence
    filtered2 = closing(opening(filtered, width), width)
    idem_error = np.max(np.abs(filtered2 - filtered))
    
    mse_noisy = np.mean((noisy - clean) ** 2)
    mse_filtered = np.mean((filtered - clean) ** 2)
    
    print(f"  MSE (noisy): {mse_noisy:.4f}")
    print(f"  MSE (filtered): {mse_filtered:.4f}")
    print(f"  Improvement: {(1 - mse_filtered/mse_noisy)*100:.1f}%")
    print(f"  Idempotence error: {idem_error:.2e}")
    
    fig, axes = plt.subplots(3, 1, figsize=(12, 8))
    
    axes[0].plot(t, clean, 'b-', linewidth=2, label='Clean signal')
    axes[0].plot(t, noisy, 'gray', alpha=0.5, linewidth=0.5, label='Noisy')
    axes[0].set_title('Original and Noisy Signal')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(t, noisy, 'gray', alpha=0.5, linewidth=0.5, label='Noisy')
    axes[1].plot(t, filtered, 'r-', linewidth=2, label='Closure-filtered')
    axes[1].set_title('Closure-Operator Denoising (Opening ∘ Closing)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    axes[2].plot(t, np.abs(filtered - filtered2), 'g-', linewidth=1)
    axes[2].set_title(f'Idempotence Verification: |f²(x) - f(x)| (max = {idem_error:.2e})')
    axes[2].set_xlabel('t')
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('app_denoising.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Plot saved to app_denoising.png")


# ============================================================================
# Application 3: Certified Safe Control Regions
# ============================================================================

def safe_control_demo():
    """
    Uses closure operators to define and certify safe control regions.
    The closure of a safe set under dynamics gives the maximal
    controllably invariant set — a certified safety envelope.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Certified Safe Control via Closure Operators")
    print("=" * 60)
    
    # Simple 2D system: double integrator
    # x' = v, v' = u, |u| ≤ 1
    # Safe region: |x| ≤ 2, |v| ≤ 2
    
    nx, nv = 100, 100
    x_range = np.linspace(-3, 3, nx)
    v_range = np.linspace(-3, 3, nv)
    X, V = np.meshgrid(x_range, v_range)
    
    # Initial safe set: box constraint
    safe = (np.abs(X) <= 2.0) & (np.abs(V) <= 2.0)
    
    # Closure operator: backward reachable set computation
    # For small dt, the predecessor set of safe states
    dt = 0.1
    
    def predecessor_closure(safe_set, n_iters=20):
        """Compute the maximal controllably invariant subset.
        
        This is a closure operator: it's extensive (safe ⊆ closure(safe)),
        monotone, and idempotent (fixed point after convergence).
        """
        current = safe_set.copy()
        for _ in range(n_iters):
            new_safe = np.zeros_like(current, dtype=bool)
            dx = x_range[1] - x_range[0]
            dv = v_range[1] - v_range[0]
            
            for i in range(1, nv - 1):
                for j in range(1, nx - 1):
                    if not current[i, j]:
                        continue
                    # Check if there exists u ∈ [-1, 1] keeping us safe
                    # Next state: x + v*dt, v + u*dt
                    v_val = v_range[i]
                    x_next = x_range[j] + v_val * dt
                    
                    # Try u = -1, 0, 1
                    for u in [-1, 0, 1]:
                        v_next = v_val + u * dt
                        # Check if (x_next, v_next) is in current safe set
                        xi = np.searchsorted(x_range, x_next) 
                        vi = np.searchsorted(v_range, v_next)
                        if 0 <= xi < nx and 0 <= vi < nv and current[vi, xi]:
                            new_safe[i, j] = True
                            break
            
            if np.array_equal(new_safe, current):
                break  # Fixed point reached — idempotence!
            current = new_safe
        
        return current
    
    invariant = predecessor_closure(safe)
    
    # Verify idempotence
    invariant2 = predecessor_closure(invariant)
    idem_match = np.array_equal(invariant, invariant2)
    
    print(f"  Initial safe set size: {np.sum(safe)} cells")
    print(f"  Invariant set size: {np.sum(invariant)} cells")
    print(f"  Reduction: {(1 - np.sum(invariant)/np.sum(safe))*100:.1f}%")
    print(f"  Idempotence verified: {idem_match}")
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    axes[0].contourf(X, V, safe.astype(float), levels=[0.5, 1.5], colors=['lightblue'], alpha=0.5)
    axes[0].contour(X, V, safe.astype(float), levels=[0.5], colors=['blue'])
    axes[0].set_title('Initial Safe Set')
    axes[0].set_xlabel('Position x')
    axes[0].set_ylabel('Velocity v')
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)
    
    axes[1].contourf(X, V, safe.astype(float), levels=[0.5, 1.5], colors=['lightblue'], alpha=0.2)
    axes[1].contourf(X, V, invariant.astype(float), levels=[0.5, 1.5], colors=['lightgreen'], alpha=0.5)
    axes[1].contour(X, V, invariant.astype(float), levels=[0.5], colors=['green'], linewidths=2)
    axes[1].set_title('Maximal Invariant Set (Closure Fixed Point)')
    axes[1].set_xlabel('Position x')
    axes[1].set_ylabel('Velocity v')
    axes[1].set_aspect('equal')
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('app_safe_control.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Plot saved to app_safe_control.png")


if __name__ == "__main__":
    robust_classifier_demo()
    signal_denoising_demo()
    safe_control_demo()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


"""Build the PACKAGE.json deliverable."""
import json

# Load visualizations
with open("visuals_b64.json") as f:
    visuals = json.load(f)

# Load markdown files
with open("ARTICLE.md") as f:
    article = f.read()
with open("RESEARCH_PAPER.md") as f:
    research_paper = f.read()
with open("FUTURE_DIRECTIONS.md") as f:
    future_directions = f.read()

# Load Lean proofs
with open("Catalog/MachineLearning/ClosureNetworkBreakthrough.lean") as f:
    lean_proofs = f.read()

# Load Python code
with open("demo.py") as f:
    demo_code = f.read()
with open("algorithms.py") as f:
    algo_code = f.read()
with open("applications.py") as f:
    app_code = f.read()

package = {
    "title": "Closure-Operator Networks: Universal Approximation via Idempotent Semimodules",
    "domain": "Machine Learning / Approximation Theory / Certified Robustness",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Universal Approximation Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Robust Classification, Denoising, Safe Control",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Closure Network Construction",
            "pseudocode": """Algorithm: Build Closure Network
Input: f : K → R (continuous), K ⊆ R^n (compact), ε > 0
Output: Closure network N with ||f - N||_∞ < ε on K

1. Compute δ from uniform continuity of f on K
   (δ such that d(x,y) < δ ⟹ |f(x)-f(y)| < ε)
2. Construct finite δ-net S = {s₁, ..., sₘ} ⊆ K
3. For each sᵢ, compute vᵢ = f(sᵢ)
4. Define N(x) = v_{argmin_i d(x, sᵢ)}
5. Return N with centers S, values (v₁,...,vₘ)

Complexity: O(m·n) per evaluation, O((diam(K)/δ)^n) storage""",
            "code": algo_code
        },
        {
            "name": "Certified Robustness Radius",
            "pseudocode": """Algorithm: Certified Robustness Radius
Input: Closure network N with centers S, query point x
Output: Certified radius r

1. Find nearest center: s* = argmin_{s ∈ S} d(x, s)
2. For each center sᵢ with N(sᵢ) ≠ N(s*):
   Compute boundary distance: (d(x, sᵢ) - d(x, s*)) / 2
3. Return r = min of all boundary distances

Complexity: O(m) per query""",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "Theorem A: Universal Approximation",
            "data": visuals["theorem_a"]
        },
        {
            "name": "Lipschitz Error Decay Rate",
            "data": visuals["lipschitz"]
        },
        {
            "name": "Certified Robustness Regions",
            "data": visuals["robustness"]
        },
        {
            "name": "Algebraic Structure of Closure Operators",
            "data": visuals["algebraic"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} bytes)")


"""
Closure-Operator Networks: Demonstrations and Numerical Examples

This module demonstrates the key theorems from the closure-operator network
universal approximation theory with concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ============================================================================
# Demo 1: Finite ε-Net Construction and Codebook Approximation
# ============================================================================

def demo_eps_net_approx():
    """
    Demonstrates Theorem A: Universal approximation on compact sets.
    
    Given a continuous function f on [0,1], constructs a finite ε-net
    and builds a nearest-neighbor codebook approximant that achieves
    uniform error < ε.
    """
    print("=" * 70)
    print("DEMO 1: Universal Approximation via ε-Net Codebook")
    print("=" * 70)
    
    # Target function: a continuous function on [0,1]
    f = lambda x: np.sin(2 * np.pi * x) * np.exp(-x)
    
    x_fine = np.linspace(0, 1, 1000)
    
    for eps in [0.5, 0.2, 0.1, 0.05, 0.01]:
        # Construct ε-net: uniform grid with spacing ≈ δ
        # By uniform continuity, choose δ such that |x-y| < δ => |f(x)-f(y)| < ε
        # For this smooth function, δ ≈ ε / (2π) works
        delta = eps / (2 * np.pi + 1)  # conservative
        n_points = max(int(np.ceil(1.0 / delta)), 2)
        net_points = np.linspace(0, 1, n_points)
        
        # Codebook approximant: N(x) = f(nearest net point)
        def make_codebook(net_pts, func):
            def N(x):
                idx = np.argmin(np.abs(x[:, None] - net_pts[None, :]), axis=1)
                return func(net_pts[idx])
            return N
        
        N = make_codebook(net_points, f)
        
        # Compute uniform error
        f_vals = f(x_fine)
        N_vals = N(x_fine.reshape(-1, 1) if len(x_fine.shape) == 1 else x_fine)
        # Fix: reshape properly
        N_vals_computed = f(net_points[np.argmin(
            np.abs(x_fine[:, None] - net_points[None, :]), axis=1)])
        
        max_error = np.max(np.abs(f_vals - N_vals_computed))
        print(f"  ε = {eps:.3f}: net size = {n_points:4d}, "
              f"actual max error = {max_error:.6f}, "
              f"within ε: {'YES' if max_error < eps else 'NO'}")
    
    # Plot for ε = 0.1
    eps = 0.1
    delta = eps / (2 * np.pi + 1)
    n_points = max(int(np.ceil(1.0 / delta)), 2)
    net_points = np.linspace(0, 1, n_points)
    N_vals = f(net_points[np.argmin(
        np.abs(x_fine[:, None] - net_points[None, :]), axis=1)])
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    axes[0].plot(x_fine, f(x_fine), 'b-', linewidth=2, label='f(x) = sin(2πx)e⁻ˣ')
    axes[0].plot(x_fine, N_vals, 'r--', linewidth=1.5, label=f'Closure network (n={n_points})')
    axes[0].scatter(net_points, f(net_points), c='green', s=40, zorder=5, label='ε-net points')
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('y')
    axes[0].set_title('Theorem A: Universal Approximation')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(x_fine, np.abs(f(x_fine) - N_vals), 'purple', linewidth=1.5)
    axes[1].axhline(y=eps, color='red', linestyle='--', label=f'ε = {eps}')
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('|f(x) - N(x)|')
    axes[1].set_title('Approximation Error')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demo_theorem_a.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Plot saved to demo_theorem_a.png")


# ============================================================================
# Demo 2: Lipschitz Error Decay
# ============================================================================

def demo_lipschitz_rate():
    """
    Demonstrates the Lipschitz error bound: for L-Lipschitz functions,
    closure-step networks with N cells achieve error ≤ L/N.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Lipschitz Error Decay Rate")
    print("=" * 70)
    
    # Lipschitz function with known constant
    f = lambda x: np.abs(x - 0.5)  # L = 1
    L = 1.0
    
    x_fine = np.linspace(0, 1, 10000)
    
    Ns = [2, 4, 8, 16, 32, 64, 128, 256]
    errors = []
    bounds = []
    
    for N in Ns:
        # Closure-step network: piecewise constant on N cells
        delta = 1.0 / N
        centers = np.array([(i + 0.5) * delta for i in range(N)])
        
        # Assign each x to its cell
        cell_idx = np.clip(np.floor(x_fine / delta).astype(int), 0, N - 1)
        N_vals = f(centers[cell_idx])
        
        max_err = np.max(np.abs(f(x_fine) - N_vals))
        errors.append(max_err)
        bounds.append(L / N)
        
        print(f"  N = {N:4d}: max error = {max_err:.6f}, bound L/N = {L/N:.6f}, "
              f"ratio = {max_err/(L/N):.3f}")
    
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.loglog(Ns, errors, 'bo-', linewidth=2, markersize=8, label='Actual error')
    ax.loglog(Ns, bounds, 'r--', linewidth=1.5, label='Bound L/N')
    ax.set_xlabel('Number of cells N')
    ax.set_ylabel('Max approximation error')
    ax.set_title('Lipschitz Error Decay: |f(x) - N(x)| ≤ L/N')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.savefig('demo_lipschitz_rate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Plot saved to demo_lipschitz_rate.png")


# ============================================================================
# Demo 3: Certified Robustness from Closure Radius
# ============================================================================

def demo_certified_robustness():
    """
    Demonstrates Theorem C: Certified robustness of closure networks.
    
    A closure network with radius r is locally constant within balls of
    radius r, giving certified robustness for classification.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Certified Robustness via Closure Radius")
    print("=" * 70)
    
    # Target classifier: sign of a function with margin
    f = lambda x: np.sin(4 * np.pi * x) - 0.3
    
    # Closure-step network with N=20 cells
    N_cells = 20
    delta = 1.0 / N_cells
    x_fine = np.linspace(0, 1, 1000)
    
    # Build closure network
    centers = np.array([(i + 0.5) * delta for i in range(N_cells)])
    cell_idx = np.clip(np.floor(x_fine / delta).astype(int), 0, N_cells - 1)
    N_vals = f(centers[cell_idx])
    
    # The closure radius is delta/2 (half the cell width)
    r = delta / 2
    
    # Find points with margin > 2 * max_error
    max_error = np.max(np.abs(f(x_fine) - N_vals))
    margin_threshold = 2 * max_error
    
    robust_mask = np.abs(N_vals) > margin_threshold
    
    print(f"  Cell width δ = {delta:.4f}")
    print(f"  Closure radius r = {r:.4f}")
    print(f"  Max approximation error = {max_error:.4f}")
    print(f"  Margin threshold = {margin_threshold:.4f}")
    print(f"  Fraction of domain with certified robustness: "
          f"{np.mean(robust_mask):.2%}")
    
    # Verify: for each robust point, all perturbations within r give same sign
    n_tests = 0
    n_violations = 0
    for i in range(0, len(x_fine), 10):
        if robust_mask[i]:
            x = x_fine[i]
            sign_x = np.sign(N_vals[i])
            # Test perturbations within radius r
            perturbs = np.linspace(max(0, x - r * 0.99), min(1, x + r * 0.99), 20)
            p_cell_idx = np.clip(np.floor(perturbs / delta).astype(int), 0, N_cells - 1)
            p_vals = f(centers[p_cell_idx])
            for pv in p_vals:
                n_tests += 1
                if np.sign(pv) != sign_x and pv != 0:
                    n_violations += 1
    
    print(f"  Robustness verification: {n_tests} tests, {n_violations} violations")
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    
    axes[0].plot(x_fine, f(x_fine), 'b-', linewidth=2, label='f(x)')
    axes[0].plot(x_fine, N_vals, 'r-', linewidth=1.5, alpha=0.8, label='N(x) (closure network)')
    axes[0].axhline(y=0, color='gray', linewidth=0.5)
    axes[0].fill_between(x_fine, -margin_threshold, margin_threshold,
                         alpha=0.1, color='orange', label='Margin zone')
    axes[0].set_title('Theorem C: Certified Robustness')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Show certified regions
    axes[1].fill_between(x_fine, 0, 1, where=robust_mask,
                         alpha=0.3, color='green', label='Certified robust')
    axes[1].fill_between(x_fine, 0, 1, where=~robust_mask,
                         alpha=0.3, color='red', label='Near decision boundary')
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('Certification')
    axes[1].set_title(f'Certified Robustness Regions (radius r = {r:.4f})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demo_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Plot saved to demo_robustness.png")


# ============================================================================
# Demo 4: Closure Operator Algebraic Properties
# ============================================================================

def demo_algebraic_structure():
    """
    Demonstrates the algebraic properties of closure operators:
    idempotence, monotonicity, extensivity, and composition.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Algebraic Structure of Closure Operators")
    print("=" * 70)
    
    # ReLU as a closure operator on ℝ
    relu = lambda x: np.maximum(0, x)
    
    x = np.linspace(-2, 2, 1000)
    
    # Verify idempotence: relu(relu(x)) = relu(x)
    idem_error = np.max(np.abs(relu(relu(x)) - relu(x)))
    print(f"  ReLU idempotence error: {idem_error}")
    
    # Verify monotonicity
    diffs = np.diff(relu(x))
    is_monotone = np.all(diffs >= -1e-15)
    print(f"  ReLU is monotone: {is_monotone}")
    
    # Verify extensivity on nonneg
    x_nonneg = x[x >= 0]
    is_extensive = np.all(relu(x_nonneg) >= x_nonneg - 1e-15)
    print(f"  ReLU is extensive on [0, ∞): {is_extensive}")
    
    # Composition of commuting closure operators
    # c(x) = max(0, x), d(x) = min(1, max(0, x)) (clamp to [0,1])
    c = relu
    d = lambda x: np.minimum(1, np.maximum(0, x))
    
    # Check commutativity on a sample
    sample = np.random.randn(1000) * 3
    comm_error = np.max(np.abs(c(d(sample)) - d(c(sample))))
    print(f"  Commutativity error (ReLU ∘ clamp vs clamp ∘ ReLU): {comm_error:.10f}")
    
    # Check idempotence of composition
    cd = lambda x: c(d(x))
    comp_idem_error = np.max(np.abs(cd(cd(sample)) - cd(sample)))
    print(f"  Composition idempotence error: {comp_idem_error:.10f}")
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    axes[0].plot(x, x, 'gray', linewidth=1, linestyle='--', label='identity')
    axes[0].plot(x, relu(x), 'b-', linewidth=2, label='ReLU(x)')
    axes[0].plot(x, relu(relu(x)), 'r--', linewidth=2, label='ReLU(ReLU(x))')
    axes[0].set_title('Idempotence: ReLU ∘ ReLU = ReLU')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(x, relu(x), 'b-', linewidth=2, label='c = ReLU')
    axes[1].plot(x, d(x), 'g-', linewidth=2, label='d = clamp[0,1]')
    axes[1].plot(x, c(d(x)), 'r--', linewidth=2, label='c ∘ d')
    axes[1].set_title('Composition of Closure Operators')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Show the lattice of fixed points
    x_plot = np.linspace(-1, 2, 1000)
    axes[2].fill_between(x_plot, 0, np.maximum(0, x_plot), alpha=0.3, color='blue',
                         label='Fixed points of ReLU')
    axes[2].plot(x_plot, np.maximum(0, x_plot), 'b-', linewidth=2)
    axes[2].axhline(y=0, color='gray', linewidth=0.5)
    axes[2].set_title('Fixed Point Set of ReLU')
    axes[2].set_xlabel('x')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demo_algebraic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Plot saved to demo_algebraic.png")


# ============================================================================
# Demo 5: 2D Approximation on Compact Domain
# ============================================================================

def demo_2d_approx():
    """
    Demonstrates universal approximation on compact subsets of ℝ².
    """
    print("\n" + "=" * 70)
    print("DEMO 5: 2D Universal Approximation on [0,1]²")
    print("=" * 70)
    
    # Target function on [0,1]²
    f = lambda x, y: np.sin(2 * np.pi * x) * np.cos(2 * np.pi * y)
    
    # Fine grid for evaluation
    n_fine = 100
    x_fine = np.linspace(0, 1, n_fine)
    y_fine = np.linspace(0, 1, n_fine)
    X, Y = np.meshgrid(x_fine, y_fine)
    F = f(X, Y)
    
    for n_net in [4, 8, 16, 32]:
        # ε-net: uniform grid
        net_x = np.linspace(0, 1, n_net)
        net_y = np.linspace(0, 1, n_net)
        
        # Build codebook: nearest-neighbor approximant
        N_vals = np.zeros_like(F)
        for i in range(n_fine):
            for j in range(n_fine):
                # Find nearest net point
                ix = np.argmin(np.abs(x_fine[j] - net_x))
                iy = np.argmin(np.abs(y_fine[i] - net_y))
                N_vals[i, j] = f(net_x[ix], net_y[iy])
        
        max_error = np.max(np.abs(F - N_vals))
        print(f"  Net size {n_net}×{n_net} = {n_net**2:4d}: max error = {max_error:.6f}")
    
    # Plot for n_net = 8
    n_net = 8
    net_x = np.linspace(0, 1, n_net)
    net_y = np.linspace(0, 1, n_net)
    N_vals = np.zeros_like(F)
    for i in range(n_fine):
        for j in range(n_fine):
            ix = np.argmin(np.abs(x_fine[j] - net_x))
            iy = np.argmin(np.abs(y_fine[i] - net_y))
            N_vals[i, j] = f(net_x[ix], net_y[iy])
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    im0 = axes[0].imshow(F, extent=[0, 1, 0, 1], origin='lower', cmap='RdBu_r')
    axes[0].set_title('f(x,y) = sin(2πx)cos(2πy)')
    plt.colorbar(im0, ax=axes[0])
    
    im1 = axes[1].imshow(N_vals, extent=[0, 1, 0, 1], origin='lower', cmap='RdBu_r')
    axes[1].set_title(f'Closure Network (8×8 net)')
    plt.colorbar(im1, ax=axes[1])
    
    im2 = axes[2].imshow(np.abs(F - N_vals), extent=[0, 1, 0, 1], origin='lower', cmap='hot')
    axes[2].set_title('|f - N| (error)')
    plt.colorbar(im2, ax=axes[2])
    
    plt.tight_layout()
    plt.savefig('demo_2d_approx.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Plot saved to demo_2d_approx.png")


if __name__ == "__main__":
    demo_eps_net_approx()
    demo_lipschitz_rate()
    demo_certified_robustness()
    demo_algebraic_structure()
    demo_2d_approx()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


"""Generate base64-encoded visualizations for the JSON package."""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"

def make_theorem_a_viz():
    f = lambda x: np.sin(2 * np.pi * x) * np.exp(-x)
    x_fine = np.linspace(0, 1, 1000)
    eps = 0.1
    delta = eps / (2 * np.pi + 1)
    n_points = max(int(np.ceil(1.0 / delta)), 2)
    net_points = np.linspace(0, 1, n_points)
    N_vals = f(net_points[np.argmin(
        np.abs(x_fine[:, None] - net_points[None, :]), axis=1)])
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    axes[0].plot(x_fine, f(x_fine), 'b-', linewidth=2, label='f(x) = sin(2πx)e⁻ˣ')
    axes[0].plot(x_fine, N_vals, 'r--', linewidth=1.5, label=f'Closure network (n={n_points})')
    axes[0].scatter(net_points, f(net_points), c='green', s=40, zorder=5, label='ε-net points')
    axes[0].set_xlabel('x'); axes[0].set_ylabel('y')
    axes[0].set_title('Theorem A: Universal Approximation'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
    axes[1].plot(x_fine, np.abs(f(x_fine) - N_vals), 'purple', linewidth=1.5)
    axes[1].axhline(y=eps, color='red', linestyle='--', label=f'ε = {eps}')
    axes[1].set_xlabel('x'); axes[1].set_ylabel('|f(x) - N(x)|')
    axes[1].set_title('Approximation Error'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
    plt.tight_layout()
    return fig_to_base64(fig)

def make_lipschitz_viz():
    f = lambda x: np.abs(x - 0.5)
    L = 1.0
    x_fine = np.linspace(0, 1, 10000)
    Ns = [2, 4, 8, 16, 32, 64, 128, 256]
    errors = []
    bounds = []
    for N in Ns:
        delta = 1.0 / N
        centers = np.array([(i + 0.5) * delta for i in range(N)])
        cell_idx = np.clip(np.floor(x_fine / delta).astype(int), 0, N - 1)
        N_vals = f(centers[cell_idx])
        errors.append(np.max(np.abs(f(x_fine) - N_vals)))
        bounds.append(L / N)
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.loglog(Ns, errors, 'bo-', linewidth=2, markersize=8, label='Actual error')
    ax.loglog(Ns, bounds, 'r--', linewidth=1.5, label='Bound L/N')
    ax.set_xlabel('Number of cells N'); ax.set_ylabel('Max approximation error')
    ax.set_title('Lipschitz Error Decay'); ax.legend(); ax.grid(True, alpha=0.3)
    return fig_to_base64(fig)

def make_robustness_viz():
    f = lambda x: np.sin(4 * np.pi * x) - 0.3
    N_cells = 20
    delta = 1.0 / N_cells
    x_fine = np.linspace(0, 1, 1000)
    centers = np.array([(i + 0.5) * delta for i in range(N_cells)])
    cell_idx = np.clip(np.floor(x_fine / delta).astype(int), 0, N_cells - 1)
    N_vals = f(centers[cell_idx])
    max_error = np.max(np.abs(f(x_fine) - N_vals))
    margin_threshold = 2 * max_error
    robust_mask = np.abs(N_vals) > margin_threshold
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    axes[0].plot(x_fine, f(x_fine), 'b-', linewidth=2, label='f(x)')
    axes[0].plot(x_fine, N_vals, 'r-', linewidth=1.5, alpha=0.8, label='N(x)')
    axes[0].axhline(y=0, color='gray', linewidth=0.5)
    axes[0].fill_between(x_fine, -margin_threshold, margin_threshold, alpha=0.1, color='orange', label='Margin zone')
    axes[0].set_title('Certified Robustness'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
    axes[1].fill_between(x_fine, 0, 1, where=robust_mask, alpha=0.3, color='green', label='Certified robust')
    axes[1].fill_between(x_fine, 0, 1, where=~robust_mask, alpha=0.3, color='red', label='Near boundary')
    axes[1].set_xlabel('x'); axes[1].set_title('Certified Regions'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
    plt.tight_layout()
    return fig_to_base64(fig)

def make_algebraic_viz():
    relu = lambda x: np.maximum(0, x)
    x = np.linspace(-2, 2, 1000)
    d = lambda x: np.minimum(1, np.maximum(0, x))
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    axes[0].plot(x, x, 'gray', linewidth=1, linestyle='--', label='identity')
    axes[0].plot(x, relu(x), 'b-', linewidth=2, label='ReLU(x)')
    axes[0].plot(x, relu(relu(x)), 'r--', linewidth=2, label='ReLU(ReLU(x))')
    axes[0].set_title('Idempotence'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
    axes[1].plot(x, relu(x), 'b-', linewidth=2, label='ReLU')
    axes[1].plot(x, d(x), 'g-', linewidth=2, label='clamp[0,1]')
    axes[1].plot(x, relu(d(x)), 'r--', linewidth=2, label='ReLU ∘ clamp')
    axes[1].set_title('Composition'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
    x_plot = np.linspace(-1, 2, 1000)
    axes[2].fill_between(x_plot, 0, np.maximum(0, x_plot), alpha=0.3, color='blue', label='Fixed points')
    axes[2].plot(x_plot, np.maximum(0, x_plot), 'b-', linewidth=2)
    axes[2].set_title('Fixed Points of ReLU'); axes[2].legend(); axes[2].grid(True, alpha=0.3)
    plt.tight_layout()
    return fig_to_base64(fig)

# Generate all visualizations
visuals = {
    "theorem_a": make_theorem_a_viz(),
    "lipschitz": make_lipschitz_viz(),
    "robustness": make_robustness_viz(),
    "algebraic": make_algebraic_viz(),
}

# Save for later use by JSON builder
with open("visuals_b64.json", "w") as f:
    json.dump(visuals, f)

print("All visualizations generated and saved.")
