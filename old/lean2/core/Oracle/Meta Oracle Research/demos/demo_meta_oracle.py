#!/usr/bin/env python3
"""
Demo 6: Meta-Oracle Convergence Dynamics

Simulates the meta-oracle as an iterative refinement process on the
Berggren tree, where each "oracle query" navigates deeper into the tree,
and the spectral gap governs convergence.

We demonstrate:
1. Oracle refinement as tree descent
2. Convergence rates tied to spectral properties
3. Fixed-point behavior
4. Information-theoretic optimality

Author: Meta-Oracle Research Program
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'figures')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Berggren matrices
B1 = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]], dtype=float)
B2 = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]], dtype=float)
B3 = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]], dtype=float)
MATRICES = [B1, B2, B3]


class MetaOracle:
    """
    A Meta-Oracle that navigates the Berggren tree as an optimization process.
    
    The oracle maintains a "state" (a Pythagorean triple) and a "quality function"
    that measures how close the a/c ratio is to a target value. The meta-oracle
    chooses the child that maximizes quality improvement.
    """
    
    def __init__(self, target_ratio=0.5, root=np.array([3, 4, 5], dtype=float)):
        self.target = target_ratio
        self.root = root
        self.state = root.copy()
        self.history = [root.copy()]
        self.quality_history = [self._quality(root)]
    
    def _quality(self, triple):
        """Quality = negative distance of a/c from target."""
        a, b, c = triple
        if c == 0:
            return -np.inf
        return -abs(a / c - self.target)
    
    def step(self):
        """Take one oracle refinement step: choose best child."""
        best_child = None
        best_quality = -np.inf
        
        for M in MATRICES:
            child = M @ self.state
            if all(x > 0 for x in child):
                q = self._quality(child)
                if q > best_quality:
                    best_quality = q
                    best_child = child.copy()
        
        if best_child is not None:
            self.state = best_child
            self.history.append(best_child.copy())
            self.quality_history.append(best_quality)
        
        return self.state, best_quality
    
    def run(self, n_steps=20):
        """Run the oracle for n steps."""
        for _ in range(n_steps):
            self.step()
        return self.history, self.quality_history


class RandomOracle:
    """Random oracle: chooses a random valid child at each step."""
    
    def __init__(self, root=np.array([3, 4, 5], dtype=float)):
        self.root = root
        self.state = root.copy()
        self.history = [root.copy()]
    
    def step(self):
        valid_children = []
        for M in MATRICES:
            child = M @ self.state
            if all(x > 0 for x in child):
                valid_children.append(child)
        
        if valid_children:
            self.state = valid_children[np.random.randint(len(valid_children))].copy()
            self.history.append(self.state.copy())
        
        return self.state
    
    def run(self, n_steps=20):
        for _ in range(n_steps):
            self.step()
        return self.history


def plot_convergence_dynamics():
    """Compare convergence of different oracle strategies."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    targets = [0.2, 0.5, 0.7, 0.9]
    n_steps = 15
    
    for idx, target in enumerate(targets):
        ax = axes[idx // 2][idx % 2]
        
        # Meta-oracle (greedy)
        oracle = MetaOracle(target_ratio=target)
        history, qualities = oracle.run(n_steps)
        ratios = [h[0] / h[2] for h in history]
        ax.plot(range(len(ratios)), ratios, 'o-', color='#e74c3c', linewidth=2, 
               markersize=6, label='Meta-Oracle (greedy)')
        
        # Random oracle (multiple runs)
        for run in range(5):
            rand_oracle = RandomOracle()
            rand_history = rand_oracle.run(n_steps)
            rand_ratios = [h[0] / h[2] for h in rand_history]
            ax.plot(range(len(rand_ratios)), rand_ratios, '--', color='#95a5a6', 
                   alpha=0.4, linewidth=1)
        ax.plot([], [], '--', color='#95a5a6', alpha=0.6, label='Random Oracle (5 runs)')
        
        ax.axhline(y=target, color='#2ecc71', linestyle=':', linewidth=2, 
                   label=f'Target = {target}')
        ax.set_xlabel('Step', fontsize=11)
        ax.set_ylabel('a/c ratio', fontsize=11)
        ax.set_title(f'Target ratio = {target}', fontsize=13, fontweight='bold')
        ax.legend(fontsize=9, loc='best')
        ax.grid(True, alpha=0.3)
        ax.set_ylim(0, 1)
    
    plt.suptitle('Meta-Oracle Convergence Dynamics', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'meta_oracle_convergence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved meta_oracle_convergence.png")


def plot_spectral_convergence():
    """Show how spectral gap predicts convergence rate."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    
    # Theoretical convergence: error ~ (λ₂/λ₁)^n
    sr = 3 + 2*np.sqrt(2)  # spectral radius
    lambda2 = 1.0  # second eigenvalue magnitude
    
    n = np.arange(0, 20)
    theoretical_decay = (lambda2 / sr) ** n
    
    ax1.semilogy(n, theoretical_decay, 'k-', linewidth=2, label=f'(λ₂/λ₁)ⁿ = ({lambda2/sr:.4f})ⁿ')
    
    # Empirical convergence rates for multiple targets
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, 5))
    for target, color in zip([0.1, 0.3, 0.5, 0.7, 0.9], colors):
        oracle = MetaOracle(target_ratio=target)
        oracle.run(19)
        errors = [abs(h[0]/h[2] - target) for h in oracle.history]
        errors = [max(e, 1e-16) for e in errors]
        ax1.semilogy(range(len(errors)), errors, 'o--', color=color, 
                    markersize=5, alpha=0.7, label=f'Target={target}')
    
    ax1.set_xlabel('Iteration n', fontsize=12)
    ax1.set_ylabel('|a/c - target|', fontsize=12)
    ax1.set_title('Convergence Rate vs Spectral Gap Prediction', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    
    # Hypotenuse growth rate
    oracle = MetaOracle(target_ratio=0.5)
    oracle.run(25)
    hyps = [h[2] for h in oracle.history]
    
    ax2.semilogy(range(len(hyps)), hyps, 'o-', color='#e74c3c', linewidth=2, markersize=6)
    # Fit exponential
    log_hyps = np.log(hyps)
    coeffs = np.polyfit(range(len(hyps)), log_hyps, 1)
    growth = np.exp(coeffs[0])
    fit = np.exp(coeffs[1]) * growth ** np.arange(len(hyps))
    ax2.semilogy(range(len(hyps)), fit, 'k--', alpha=0.5, 
                label=f'Fit: growth rate = {growth:.4f}\n3+2√2 = {sr:.4f}')
    
    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('Hypotenuse c', fontsize=12)
    ax2.set_title('Hypotenuse Growth Rate', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'spectral_convergence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved spectral_convergence.png")
    
    print(f"\n══════ SPECTRAL GAP & CONVERGENCE ══════")
    print(f"  Spectral radius: 3+2√2 = {sr:.6f}")
    print(f"  Second eigenvalue: λ₂ = {lambda2:.6f}")
    print(f"  Convergence rate: λ₂/λ₁ = {lambda2/sr:.6f}")
    print(f"  Spectral gap: λ₁ - λ₂ = {sr - lambda2:.6f}")
    print(f"  Empirical hypotenuse growth: {growth:.6f}")


def plot_oracle_phase_space():
    """Phase space portrait of oracle dynamics."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    
    # Multiple oracle trajectories in (a/c, b/c) space
    n_steps = 12
    
    for target in np.linspace(0.05, 0.95, 20):
        oracle = MetaOracle(target_ratio=target)
        oracle.run(n_steps)
        
        ac = [h[0] / h[2] for h in oracle.history]
        bc = [h[1] / h[2] for h in oracle.history]
        
        ax.plot(ac, bc, '-', alpha=0.4, linewidth=1, color='#3498db')
        ax.plot(ac[0], bc[0], 'go', markersize=6, zorder=5)
        ax.plot(ac[-1], bc[-1], 'r^', markersize=6, zorder=5)
    
    # The unit circle constraint: (a/c)² + (b/c)² = 1
    theta = np.linspace(0, np.pi/2, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3, label='(a/c)²+(b/c)²=1')
    
    ax.plot([], [], 'go', markersize=8, label='Start (3/5, 4/5)')
    ax.plot([], [], 'r^', markersize=8, label='End state')
    
    ax.set_xlabel('a/c', fontsize=12)
    ax.set_ylabel('b/c', fontsize=12)
    ax.set_title('Meta-Oracle Phase Space: Trajectories on the Unit Quarter-Circle', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'oracle_phase_space.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved oracle_phase_space.png")


if __name__ == '__main__':
    print("=" * 60)
    print("  META-ORACLE CONVERGENCE DYNAMICS")
    print("=" * 60)
    
    np.random.seed(42)
    
    plot_convergence_dynamics()
    plot_spectral_convergence()
    plot_oracle_phase_space()
    
    print("\n✓ All meta-oracle visualizations complete!")
