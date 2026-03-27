#!/usr/bin/env python3
"""
Meta-Oracle Demo 1: Convergence of Iterative Self-Improvement

Demonstrates the core theorem: a contractive meta-oracle converges geometrically
to a unique fixed point. We visualize this with three examples:

1. Function approximation: A meta-oracle that iteratively refines a polynomial
   approximation to sin(x).
2. Strategy improvement: A meta-oracle for the multi-armed bandit problem.
3. Self-tuning optimizer: A meta-oracle that adapts its own learning rate.

Run: python3 demo1_convergence.py
Output: convergence_plots.png
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ============================================================
# Example 1: Contractive Function Approximation Meta-Oracle
# ============================================================

def meta_oracle_polynomial(coeffs: np.ndarray, target_fn: Callable,
                           x_samples: np.ndarray, learning_rate: float = 0.5) -> np.ndarray:
    """
    A meta-oracle that improves polynomial coefficients to approximate a target function.
    
    This is a contraction mapping when learning_rate < 1:
      M(c) = c + lr * (c_optimal - c) = (1 - lr) * c + lr * c_optimal
    
    Contraction constant k = (1 - learning_rate).
    """
    # Compute the optimal coefficients via least squares
    degree = len(coeffs) - 1
    X = np.vander(x_samples, degree + 1, increasing=True)
    y = target_fn(x_samples)
    c_optimal = np.linalg.lstsq(X, y, rcond=None)[0]
    
    # Contraction step: move toward optimal
    return (1 - learning_rate) * coeffs + learning_rate * c_optimal


def run_polynomial_convergence():
    """Run the polynomial approximation meta-oracle and track convergence."""
    np.random.seed(42)
    x = np.linspace(-np.pi, np.pi, 100)
    target = np.sin
    degree = 7
    
    # Start from random coefficients
    coeffs = np.random.randn(degree + 1) * 0.1
    
    distances = []
    # Compute optimal once for distance tracking
    X = np.vander(x, degree + 1, increasing=True)
    c_opt = np.linalg.lstsq(X, target(x), rcond=None)[0]
    
    learning_rates = [0.3, 0.5, 0.8]
    all_distances = {}
    
    for lr in learning_rates:
        c = coeffs.copy()
        dists = []
        for i in range(30):
            d = np.linalg.norm(c - c_opt)
            dists.append(d)
            c = meta_oracle_polynomial(c, target, x, learning_rate=lr)
        all_distances[lr] = dists
    
    return all_distances, learning_rates


# ============================================================
# Example 2: Multi-Armed Bandit Strategy Improvement
# ============================================================

class BanditMetaOracle:
    """
    A meta-oracle for the multi-armed bandit problem.
    
    The oracle is a probability distribution over K arms.
    The meta-oracle updates the distribution using observed rewards,
    implementing a contraction toward the optimal (greedy) strategy.
    """
    def __init__(self, K: int, true_means: np.ndarray, contraction_rate: float = 0.7):
        self.K = K
        self.true_means = true_means
        self.optimal_arm = np.argmax(true_means)
        self.k = contraction_rate  # contraction constant
        
    def improve(self, strategy: np.ndarray, n_samples: int = 100) -> np.ndarray:
        """One step of meta-oracle improvement."""
        # Estimate means from samples
        estimated_means = np.zeros(self.K)
        for arm in range(self.K):
            n_pulls = max(1, int(strategy[arm] * n_samples))
            rewards = np.random.normal(self.true_means[arm], 1.0, n_pulls)
            estimated_means[arm] = np.mean(rewards)
        
        # Compute softmax (near-optimal) target strategy
        temp = 0.1
        target = np.exp(estimated_means / temp)
        target /= target.sum()
        
        # Contract toward target
        new_strategy = (1 - self.k) * strategy + self.k * target
        new_strategy /= new_strategy.sum()
        return new_strategy
    
    def distance_to_optimal(self, strategy: np.ndarray) -> float:
        """Distance to the optimal (greedy) strategy."""
        optimal = np.zeros(self.K)
        optimal[self.optimal_arm] = 1.0
        return np.linalg.norm(strategy - optimal)


def run_bandit_convergence():
    """Run the bandit meta-oracle convergence experiment."""
    np.random.seed(123)
    K = 5
    true_means = np.array([1.0, 2.5, 1.8, 0.5, 3.0])
    
    meta = BanditMetaOracle(K, true_means, contraction_rate=0.7)
    
    # Start with uniform strategy
    strategy = np.ones(K) / K
    distances = []
    
    for i in range(40):
        d = meta.distance_to_optimal(strategy)
        distances.append(d)
        strategy = meta.improve(strategy)
    
    return distances


# ============================================================
# Example 3: Self-Tuning Meta-Oracle (Adaptive Learning Rate)
# ============================================================

class SelfTuningMetaOracle:
    """
    A meta-oracle that adapts its own contraction rate (learning rate).
    
    This demonstrates the "meta-meta" level: the meta-oracle observes
    its own convergence rate and adjusts its aggressiveness.
    
    Key insight: Oracle entropy H = -log(k) should be maximized.
    Too aggressive (k near 0) → overshoot and oscillate.
    Too conservative (k near 1) → slow convergence.
    """
    def __init__(self, target: float, initial_k: float = 0.5):
        self.target = target
        self.k = initial_k
        self.k_history = [initial_k]
        
    def improve(self, x: float) -> float:
        """Improve the estimate x toward the target."""
        new_x = (1 - self.k) * x + self.k * (self.target + np.random.normal(0, 0.1))
        
        # Meta-adaptation: adjust k based on improvement
        improvement = abs(x - self.target) - abs(new_x - self.target)
        
        if improvement > 0:
            # Good step — try being more aggressive
            self.k = min(0.95, self.k * 1.05)
        else:
            # Bad step — be more conservative
            self.k = max(0.05, self.k * 0.8)
        
        self.k_history.append(self.k)
        return new_x


def run_self_tuning():
    """Run the self-tuning meta-oracle experiment."""
    np.random.seed(456)
    
    target = 3.14159
    meta = SelfTuningMetaOracle(target, initial_k=0.1)
    
    x = 0.0  # Start far from target
    distances = []
    
    for i in range(60):
        distances.append(abs(x - target))
        x = meta.improve(x)
    
    return distances, meta.k_history


# ============================================================
# Oracle Entropy Visualization
# ============================================================

def oracle_entropy_plot():
    """Visualize oracle entropy H = -log(k) for different contraction rates."""
    k_values = np.linspace(0.01, 0.99, 200)
    entropy = -np.log(k_values)
    return k_values, entropy


# ============================================================
# Main: Generate All Plots
# ============================================================

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Meta-Oracle Theory: Convergence Demonstrations", fontsize=16, fontweight='bold')
    
    # Plot 1: Polynomial approximation convergence
    ax1 = axes[0, 0]
    all_distances, learning_rates = run_polynomial_convergence()
    for lr in learning_rates:
        dists = all_distances[lr]
        theoretical = [dists[0] * (1 - lr)**n for n in range(len(dists))]
        ax1.semilogy(dists, 'o-', markersize=3, label=f'k={1-lr:.1f} (lr={lr})')
        ax1.semilogy(theoretical, '--', alpha=0.5, color='gray')
    ax1.set_xlabel('Iteration n')
    ax1.set_ylabel('Distance to optimal ‖cₙ - c*‖')
    ax1.set_title('(a) Polynomial Approximation\n(Contractive Meta-Oracle)')
    ax1.legend(title='Contraction rate k')
    ax1.grid(True, alpha=0.3)
    ax1.annotate('d(fₙ, f*) ≤ kⁿ · d(f₀, f*)', xy=(0.5, 0.02),
                xycoords='axes fraction', ha='center', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Plot 2: Multi-armed bandit convergence
    ax2 = axes[0, 1]
    bandit_distances = run_bandit_convergence()
    ax2.semilogy(bandit_distances, 'ro-', markersize=4, label='Bandit Meta-Oracle')
    n = np.arange(len(bandit_distances))
    ax2.semilogy(n, bandit_distances[0] * 0.3**n, 'k--', alpha=0.5, label='Geometric bound k=0.3')
    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('Distance to optimal strategy')
    ax2.set_title('(b) Multi-Armed Bandit\n(Strategy Improvement)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Self-tuning meta-oracle
    ax3 = axes[1, 0]
    st_distances, k_history = run_self_tuning()
    color1 = 'tab:blue'
    color2 = 'tab:orange'
    ax3.semilogy(st_distances, 'o-', color=color1, markersize=3, label='Distance to target')
    ax3_twin = ax3.twinx()
    ax3_twin.plot(k_history[:len(st_distances)], '-', color=color2, alpha=0.7, label='Adapted k')
    ax3.set_xlabel('Iteration n')
    ax3.set_ylabel('|xₙ - x*|', color=color1)
    ax3_twin.set_ylabel('Contraction rate k', color=color2)
    ax3.set_title('(c) Self-Tuning Meta-Oracle\n(Adaptive Contraction Rate)')
    ax3.grid(True, alpha=0.3)
    lines1, labels1 = ax3.get_legend_handles_labels()
    lines2, labels2 = ax3_twin.get_legend_handles_labels()
    ax3.legend(lines1 + lines2, labels1 + labels2, loc='upper right')
    
    # Plot 4: Oracle Entropy
    ax4 = axes[1, 1]
    k_vals, entropy = oracle_entropy_plot()
    ax4.plot(k_vals, entropy, 'g-', linewidth=2)
    ax4.fill_between(k_vals, entropy, alpha=0.1, color='green')
    ax4.axvline(x=0.5, color='red', linestyle='--', alpha=0.5, label='k=0.5 (H=0.69)')
    ax4.axvline(x=np.exp(-1), color='blue', linestyle='--', alpha=0.5, label=f'k=1/e (H=1.0)')
    ax4.set_xlabel('Contraction rate k')
    ax4.set_ylabel('Oracle Entropy H = -log(k)')
    ax4.set_title('(d) Oracle Entropy\n(Information per Iteration)')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.set_xlim(0, 1)
    ax4.set_ylim(0, 5)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/python_demos/convergence_plots.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved convergence_plots.png")
    
    # Print summary statistics
    print("\n" + "="*60)
    print("META-ORACLE CONVERGENCE SUMMARY")
    print("="*60)
    
    print("\n1. Polynomial Approximation:")
    for lr in learning_rates:
        k = 1 - lr
        H = -np.log(k)
        final_d = all_distances[lr][-1]
        print(f"   k={k:.1f}, H={H:.2f} nats, final distance={final_d:.2e}")
    
    print(f"\n2. Multi-Armed Bandit:")
    print(f"   Initial distance: {bandit_distances[0]:.4f}")
    print(f"   Final distance:   {bandit_distances[-1]:.6f}")
    print(f"   Convergence factor: {bandit_distances[-1]/bandit_distances[0]:.6f}")
    
    print(f"\n3. Self-Tuning Meta-Oracle:")
    print(f"   Initial distance: {st_distances[0]:.4f}")
    print(f"   Final distance:   {st_distances[-1]:.6e}")
    print(f"   Adapted k: {k_history[0]:.2f} → {k_history[-1]:.2f}")
    print(f"   Oracle entropy: {-np.log(k_history[-1]):.2f} nats")


if __name__ == "__main__":
    main()
