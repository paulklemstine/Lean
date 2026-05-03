"""
Tropical Certified Robustness for Plurality-of-Experts Ensembles
================================================================

This demo illustrates the formally verified theorems from the Lean 4
formalization. We construct concrete ensembles of piecewise-linear
(ReLU) experts, compute per-expert logit-gap certificates, and derive
ensemble-level plurality robustness radii.

Key results demonstrated:
1. Per-expert score-gap certificates under L∞ perturbation
2. Identification of "frozen" experts whose decisions are stable
3. Plurality robustness certification for the ensemble
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyBboxPatch
import matplotlib.patches as mpatches
from itertools import product

# ─────────────────────────────────────────────────────────────────
# 1. Define simple piecewise-linear (ReLU-like) expert networks
# ─────────────────────────────────────────────────────────────────

class PLExpert:
    """A piecewise-linear expert: f(x) = W @ x + b, with Lipschitz constant K."""
    
    def __init__(self, W, b, name="Expert"):
        """
        W: (C, d) weight matrix
        b: (C,) bias vector
        """
        self.W = np.array(W, dtype=float)
        self.b = np.array(b, dtype=float)
        self.name = name
        self.C, self.d = self.W.shape
        # Coordinatewise Lipschitz constant: max_c sum_k |W[c,k]|
        # Actually, |f(z,c) - f(x,c)| = |W[c,:] @ (z-x)| ≤ sum_k |W[c,k]| |z_k - x_k|
        # ≤ (max_c sum_k |W[c,k]|) * sum_k |z_k - x_k|
        # So K = max_c sum_k |W[c,k]|
        self.K = np.max(np.sum(np.abs(self.W), axis=1))
    
    def __call__(self, x):
        """Compute score vector f(x) ∈ R^C."""
        return self.W @ x + self.b
    
    def score_gap(self, x, c):
        """Score gap: f(x)[c] - max_{j≠c} f(x)[j]."""
        scores = self(x)
        others = np.delete(scores, c)
        return scores[c] - np.max(others)
    
    def cert_radius(self, x, c):
        """Certified radius: scoreGap / (2 * K * d)."""
        gap = self.score_gap(x, c)
        if self.K == 0 or self.d == 0:
            return float('inf') if gap > 0 else 0.0
        return gap / (2 * self.K * self.d)
    
    def decides(self, x):
        """Return the predicted class (argmax)."""
        return int(np.argmax(self(x)))
    
    def strictly_decides(self, x, c):
        """Check if c is the strict argmax."""
        scores = self(x)
        return all(scores[j] < scores[c] for j in range(self.C) if j != c)


def plurality_vote(experts, x):
    """Return (winner_class, vote_counts)."""
    C = experts[0].C
    votes = np.zeros(C, dtype=int)
    for expert in experts:
        pred = expert.decides(x)
        votes[pred] += 1
    return int(np.argmax(votes)), votes


def compute_ensemble_certificate(experts, x, cstar):
    """
    Compute the certified L∞ robustness radius for the ensemble's
    plurality decision at x, predicting class cstar.
    
    Returns:
        r_cert: certified radius (largest r such that cstar remains winner)
        stable_experts: list of (expert_idx, cert_radius) for experts voting cstar
        details: dict with analysis details
    """
    n = len(experts)
    C = experts[0].C
    
    # Find experts voting for cstar
    winner_voters = []
    for i, expert in enumerate(experts):
        if expert.decides(x) == cstar:
            r_i = expert.cert_radius(x, cstar)
            winner_voters.append((i, r_i))
    
    # Sort by certified radius (descending)
    winner_voters.sort(key=lambda t: -t[1])
    
    # Find the largest r such that stableWinnerVoters forms a majority
    # stableWinnerVoters(r) = {i : winner_voter | cert_radius_i > r}
    # We need |stableWinnerVoters(r)| > n - |stableWinnerVoters(r)|
    # i.e., 2 * |stableWinnerVoters(r)| > n
    # i.e., |stableWinnerVoters(r)| > n/2
    
    # The certified radius is the largest r_i such that
    # the number of winner-voters with cert_radius > r is > n/2
    majority_threshold = n / 2
    
    r_cert = 0.0
    stable_count = len(winner_voters)  # at r=0, all winner-voters are stable
    
    for i, (idx, r_i) in enumerate(winner_voters):
        remaining = len(winner_voters) - i  # experts with cert_radius ≥ r_i
        if remaining > majority_threshold:
            r_cert = r_i
        else:
            break
    
    return r_cert, winner_voters, {
        'n_experts': n,
        'n_classes': C,
        'n_winner_voters': len(winner_voters),
        'majority_threshold': majority_threshold,
    }


# ─────────────────────────────────────────────────────────────────
# 2. Example 1: Three linear experts on 2D inputs, 3 classes
# ─────────────────────────────────────────────────────────────────

def demo_basic():
    """Basic demonstration with 3 experts, 3 classes, 2D inputs."""
    print("=" * 70)
    print("DEMO 1: Basic Plurality Robustness Certification")
    print("=" * 70)
    
    # Define 5 experts (C=3 classes, d=2 dimensions)
    experts = [
        PLExpert([[2, 1], [-1, 1], [0, -1]], [1, 0, 0], "Expert A"),
        PLExpert([[1, 2], [-1, 0], [0, -1]], [0.5, 0, 0], "Expert B"),
        PLExpert([[1.5, 0.5], [-0.5, 1], [-1, -1]], [0.8, 0, 0], "Expert C"),
        PLExpert([[0.5, 1.5], [0, -1], [-0.5, 0.5]], [1.2, -0.5, 0], "Expert D"),
        PLExpert([[1, 1], [-1, -1], [0.5, 0]], [0.3, 0, 0], "Expert E"),
    ]
    
    x = np.array([1.0, 0.5])
    
    print(f"\nInput point x = {x}")
    print(f"Number of experts: {len(experts)}")
    print(f"Number of classes: {experts[0].C}")
    print(f"Input dimension: {experts[0].d}")
    
    print("\n--- Per-Expert Analysis ---")
    for i, expert in enumerate(experts):
        scores = expert(x)
        pred = expert.decides(x)
        gap = expert.score_gap(x, pred)
        r = expert.cert_radius(x, pred)
        print(f"  {expert.name}: scores={np.round(scores, 3)}, "
              f"pred={pred}, gap={gap:.3f}, K={expert.K:.3f}, "
              f"cert_radius={r:.4f}")
    
    cstar, votes = plurality_vote(experts, x)
    print(f"\n--- Ensemble Decision ---")
    print(f"  Vote counts: {votes}")
    print(f"  Plurality winner: class {cstar}")
    
    r_cert, stable, details = compute_ensemble_certificate(experts, x, cstar)
    print(f"\n--- Robustness Certificate ---")
    print(f"  Certified L∞ radius: {r_cert:.4f}")
    print(f"  Winner-voters: {[(i, f'{r:.4f}') for i, r in stable]}")
    print(f"  Majority threshold: {details['majority_threshold']}")
    
    # Verify empirically
    print(f"\n--- Empirical Verification (random perturbations) ---")
    n_trials = 10000
    violations = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-r_cert * 0.99, r_cert * 0.99, size=x.shape)
        z = x + delta
        winner_z, _ = plurality_vote(experts, z)
        if winner_z != cstar:
            violations += 1
    print(f"  Violations within 0.99 * r_cert: {violations}/{n_trials}")
    
    return experts, x, cstar, r_cert


# ─────────────────────────────────────────────────────────────────
# 3. Example 2: Visualization of robustness regions
# ─────────────────────────────────────────────────────────────────

def demo_visualization(experts, x, cstar, r_cert):
    """Visualize the decision boundaries and certified robust region."""
    print("\n" + "=" * 70)
    print("DEMO 2: Visualization of Certified Robustness Region")
    print("=" * 70)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: per-expert decisions
    ax = axes[0]
    grid_size = 200
    x_range = np.linspace(x[0] - 1.5, x[0] + 1.5, grid_size)
    y_range = np.linspace(x[1] - 1.5, x[1] + 1.5, grid_size)
    X, Y = np.meshgrid(x_range, y_range)
    
    # Plurality decision map
    Z_plurality = np.zeros((grid_size, grid_size))
    for i in range(grid_size):
        for j in range(grid_size):
            pt = np.array([X[i, j], Y[i, j]])
            winner, _ = plurality_vote(experts, pt)
            Z_plurality[i, j] = winner
    
    colors = ['#2196F3', '#F44336', '#4CAF50']
    cmap = plt.cm.colors.ListedColormap(colors[:experts[0].C])
    ax.contourf(X, Y, Z_plurality, levels=[-0.5, 0.5, 1.5, 2.5],
                colors=colors[:experts[0].C], alpha=0.3)
    ax.contour(X, Y, Z_plurality, levels=[0.5, 1.5], colors='black',
               linewidths=0.5)
    
    # Draw L∞ ball
    rect = Rectangle((x[0] - r_cert, x[1] - r_cert), 2 * r_cert, 2 * r_cert,
                      linewidth=2, edgecolor='red', facecolor='none',
                      linestyle='--', label=f'Certified L∞ ball (r={r_cert:.3f})')
    ax.add_patch(rect)
    ax.plot(*x, 'k*', markersize=15, label=f'Basepoint x')
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_title('Ensemble Plurality Decision Map')
    ax.legend(fontsize=8)
    
    # Right: per-expert certificate radii
    ax = axes[1]
    n = len(experts)
    radii = []
    for i, expert in enumerate(experts):
        pred = expert.decides(x)
        if pred == cstar:
            r_i = expert.cert_radius(x, cstar)
            radii.append((i, r_i, expert.name))
    
    radii.sort(key=lambda t: -t[1])
    bars = ax.barh(range(len(radii)),
                   [r for _, r, _ in radii],
                   color=['#4CAF50' if r > r_cert else '#FF9800'
                          for _, r, _ in radii],
                   edgecolor='black', linewidth=0.5)
    ax.set_yticks(range(len(radii)))
    ax.set_yticklabels([name for _, _, name in radii])
    ax.axvline(r_cert, color='red', linestyle='--', linewidth=2,
               label=f'Ensemble cert. radius = {r_cert:.4f}')
    ax.set_xlabel('Per-Expert Certified Radius')
    ax.set_title('Expert Certificate Radii')
    ax.legend(fontsize=8)
    
    # Color legend
    green_patch = mpatches.Patch(color='#4CAF50', label='Frozen (radius > cert)')
    orange_patch = mpatches.Patch(color='#FF9800', label='May change')
    ax.legend(handles=[green_patch, orange_patch,
              plt.Line2D([0], [0], color='red', linestyle='--', linewidth=2,
                         label=f'Ensemble radius = {r_cert:.4f}')],
              fontsize=8)
    
    plt.tight_layout()
    plt.savefig('MachineLearning/fig_robustness_regions.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  Saved figure: MachineLearning/fig_robustness_regions.png")


# ─────────────────────────────────────────────────────────────────
# 4. Example 3: Scaling behavior with ensemble size
# ─────────────────────────────────────────────────────────────────

def demo_scaling():
    """Show how certified radius improves with more experts."""
    print("\n" + "=" * 70)
    print("DEMO 3: Scaling of Certified Radius with Ensemble Size")
    print("=" * 70)
    
    np.random.seed(42)
    d = 5
    C = 3
    x = np.ones(d) * 0.5
    
    ensemble_sizes = [3, 5, 7, 9, 11, 15, 21, 31, 51]
    certified_radii = []
    
    for n in ensemble_sizes:
        # Create n experts with random weights but biased toward class 0
        experts = []
        for i in range(n):
            W = np.random.randn(C, d) * 0.5
            # Bias class 0 to be the winner
            W[0, :] += 0.3
            b = np.random.randn(C) * 0.1
            b[0] += 1.0
            experts.append(PLExpert(W, b, f"Expert_{i}"))
        
        cstar, votes = plurality_vote(experts, x)
        if cstar == 0:
            r_cert, _, _ = compute_ensemble_certificate(experts, x, cstar)
            certified_radii.append(r_cert)
        else:
            certified_radii.append(0.0)
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ensemble_sizes, certified_radii, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Number of Experts (n)', fontsize=12)
    ax.set_ylabel('Certified L∞ Radius', fontsize=12)
    ax.set_title('Ensemble Certified Robustness vs. Size', fontsize=14)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('MachineLearning/fig_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved figure: MachineLearning/fig_scaling.png")
    
    for n, r in zip(ensemble_sizes, certified_radii):
        print(f"  n={n:3d}: certified radius = {r:.4f}")


# ─────────────────────────────────────────────────────────────────
# 5. Application: MNIST-like adversarial robustness certification
# ─────────────────────────────────────────────────────────────────

def demo_application():
    """
    Simulate a realistic adversarial robustness certification scenario.
    
    This demonstrates how the theorem would be applied in practice:
    given a trained ensemble of piecewise-linear networks, compute
    the certified robust radius for each test input.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Simulated Adversarial Robustness Certification")
    print("=" * 70)
    
    np.random.seed(123)
    n_experts = 7
    d = 10  # input dimension (e.g., reduced MNIST features)
    C = 10  # 10 classes (digits 0-9)
    n_test = 100
    
    # Create experts with varying quality
    experts = []
    for i in range(n_experts):
        W = np.random.randn(C, d) * (0.3 + 0.1 * i)
        b = np.random.randn(C) * 0.2
        experts.append(PLExpert(W, b, f"Net_{i}"))
    
    # Generate test inputs
    test_inputs = np.random.randn(n_test, d) * 0.5
    
    certified_count = 0
    radii = []
    
    for t in range(n_test):
        x = test_inputs[t]
        cstar, votes = plurality_vote(experts, x)
        r_cert, stable, details = compute_ensemble_certificate(experts, x, cstar)
        radii.append(r_cert)
        if r_cert > 0:
            certified_count += 1
    
    print(f"  Test inputs: {n_test}")
    print(f"  Certified (r > 0): {certified_count}/{n_test} "
          f"({100*certified_count/n_test:.1f}%)")
    print(f"  Mean certified radius: {np.mean(radii):.4f}")
    print(f"  Median certified radius: {np.median(radii):.4f}")
    print(f"  Max certified radius: {np.max(radii):.4f}")
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.hist(radii, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    ax.axvline(np.mean(radii), color='red', linestyle='--', linewidth=2,
               label=f'Mean = {np.mean(radii):.4f}')
    ax.set_xlabel('Certified L∞ Radius', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Certified Robustness Radii\n'
                 f'({n_experts} experts, {C} classes, d={d})', fontsize=13)
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig('MachineLearning/fig_application.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  Saved figure: MachineLearning/fig_application.png")


# ─────────────────────────────────────────────────────────────────
# 6. Run all demos
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    experts, x, cstar, r_cert = demo_basic()
    demo_visualization(experts, x, cstar, r_cert)
    demo_scaling()
    demo_application()
    
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
    print("\nGenerated figures:")
    print("  - MachineLearning/fig_robustness_regions.png")
    print("  - MachineLearning/fig_scaling.png")
    print("  - MachineLearning/fig_application.png")
