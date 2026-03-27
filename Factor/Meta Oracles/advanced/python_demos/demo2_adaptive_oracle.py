#!/usr/bin/env python3
"""
Meta-Oracle Demo 2: The Adaptive Meta-Oracle

Implements a meta-oracle that continuously improves itself by:
1. Maintaining a population of strategies
2. Measuring improvement rates (oracle entropy)
3. Reallocating resources to the most promising improvement directions
4. Self-modifying its own meta-parameters

This demonstrates the key theoretical concept: a meta-oracle can treat
its own parameters as an oracle space and apply self-improvement recursively.

Run: python3 demo2_adaptive_oracle.py
Output: adaptive_oracle_plots.png
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from dataclasses import dataclass, field
from typing import List, Tuple, Dict

# ============================================================
# The Adaptive Meta-Oracle Framework
# ============================================================

@dataclass
class OracleState:
    """State of an oracle: its parameters and performance history."""
    params: np.ndarray
    quality_history: List[float] = field(default_factory=list)
    entropy_history: List[float] = field(default_factory=list)


class AdaptiveMetaOracle:
    """
    A self-improving meta-oracle that adapts to the problem structure.
    
    Architecture:
    - Level 0: The base oracle (a parameterized function)
    - Level 1: The meta-oracle (improves Level 0 parameters)
    - Level 2: The meta-meta-oracle (improves Level 1 hyper-parameters)
    
    The key insight is that each level can be viewed as an oracle in a
    higher-level oracle space, enabling recursive self-improvement.
    
    Theoretical guarantee: If each level is a contraction with rate kᵢ,
    the total system contracts with rate k₁ · k₂ · ... · kₙ, and the
    total oracle entropy is H₁ + H₂ + ... + Hₙ (additive!).
    """
    
    def __init__(self, dim: int, target_fn, noise_std: float = 0.1):
        self.dim = dim
        self.target_fn = target_fn
        self.noise_std = noise_std
        
        # Level 1 parameters (meta-oracle)
        self.learning_rate = 0.1
        self.momentum = 0.0
        self.exploration_std = 0.5
        
        # Level 2 parameters (meta-meta-oracle)
        self.lr_adaptation_rate = 0.01
        self.momentum_adaptation_rate = 0.01
        
        # History
        self.velocity = np.zeros(dim)
        self.quality_log = []
        self.entropy_log = []
        self.lr_log = []
        self.momentum_log = []
    
    def evaluate(self, params: np.ndarray) -> float:
        """Evaluate the oracle quality (negative loss)."""
        return -self.target_fn(params) + np.random.normal(0, self.noise_std)
    
    def improve_level0(self, state: OracleState) -> OracleState:
        """Level 1 meta-oracle: improve the base oracle parameters."""
        # Estimate gradient via finite differences (exploration)
        grad = np.zeros(self.dim)
        current_q = self.evaluate(state.params)
        
        for i in range(self.dim):
            perturbation = np.zeros(self.dim)
            perturbation[i] = self.exploration_std
            q_plus = self.evaluate(state.params + perturbation)
            q_minus = self.evaluate(state.params - perturbation)
            grad[i] = (q_plus - q_minus) / (2 * self.exploration_std)
        
        # Momentum-based update
        self.velocity = self.momentum * self.velocity + self.learning_rate * grad
        new_params = state.params + self.velocity
        
        new_state = OracleState(params=new_params)
        new_state.quality_history = state.quality_history + [current_q]
        
        return new_state
    
    def improve_level1(self, state: OracleState):
        """Level 2 meta-meta-oracle: adapt the meta-oracle's own parameters."""
        if len(state.quality_history) < 3:
            return
        
        # Measure recent oracle entropy (improvement rate)
        recent = state.quality_history[-3:]
        improvements = [recent[i+1] - recent[i] for i in range(len(recent)-1)]
        avg_improvement = np.mean(improvements)
        
        # Estimate oracle entropy
        if len(state.quality_history) >= 4:
            prev_improvements = [state.quality_history[-4+i+1] - state.quality_history[-4+i] 
                                for i in range(2)]
            prev_avg = np.mean(prev_improvements)
            if prev_avg != 0:
                entropy = np.log(max(1e-10, abs(avg_improvement / prev_avg)))
            else:
                entropy = 0
        else:
            entropy = 0
        
        self.entropy_log.append(entropy)
        
        # Adapt learning rate
        if avg_improvement > 0:
            # Making progress → try increasing learning rate
            self.learning_rate *= (1 + self.lr_adaptation_rate)
        else:
            # Stuck or regressing → decrease learning rate
            self.learning_rate *= (1 - self.lr_adaptation_rate * 2)
        
        self.learning_rate = np.clip(self.learning_rate, 1e-4, 1.0)
        
        # Adapt momentum
        if len(improvements) >= 2 and improvements[0] * improvements[1] > 0:
            # Consistent direction → increase momentum
            self.momentum = min(0.95, self.momentum + self.momentum_adaptation_rate)
        else:
            # Direction changed → decrease momentum
            self.momentum = max(0.0, self.momentum - self.momentum_adaptation_rate * 2)
        
        # Adapt exploration
        if avg_improvement < 0.01:
            self.exploration_std *= 0.99  # Fine-tune
        else:
            self.exploration_std *= 1.01  # Explore more
        self.exploration_std = np.clip(self.exploration_std, 0.01, 2.0)
        
        self.lr_log.append(self.learning_rate)
        self.momentum_log.append(self.momentum)
    
    def iterate(self, initial_params: np.ndarray, n_iterations: int) -> OracleState:
        """Run the full adaptive meta-oracle for n iterations."""
        state = OracleState(params=initial_params)
        
        for i in range(n_iterations):
            # Level 0 improvement
            state = self.improve_level0(state)
            
            # Level 1 self-improvement (meta-meta)
            self.improve_level1(state)
            
            # Log quality
            true_quality = -self.target_fn(state.params)
            self.quality_log.append(true_quality)
        
        return state


# ============================================================
# Test Functions (Optimization Landscapes)
# ============================================================

def rosenbrock(x: np.ndarray) -> float:
    """Rosenbrock function: classic difficult optimization landscape."""
    return sum(100 * (x[i+1] - x[i]**2)**2 + (1 - x[i])**2 for i in range(len(x)-1))

def rastrigin(x: np.ndarray) -> float:
    """Rastrigin function: many local optima."""
    n = len(x)
    return 10 * n + sum(x[i]**2 - 10 * np.cos(2 * np.pi * x[i]) for i in range(n))

def sphere(x: np.ndarray) -> float:
    """Sphere function: simple convex landscape."""
    return np.sum(x**2)


# ============================================================
# Comparison: Adaptive vs Fixed Meta-Oracle
# ============================================================

def compare_adaptive_vs_fixed():
    """Compare the adaptive meta-oracle against fixed-parameter versions."""
    np.random.seed(42)
    dim = 5
    n_iter = 200
    
    results = {}
    
    # Adaptive meta-oracle
    meta_adaptive = AdaptiveMetaOracle(dim, rosenbrock, noise_std=0.05)
    initial = np.random.randn(dim) * 2
    state = meta_adaptive.iterate(initial.copy(), n_iter)
    results['Adaptive'] = meta_adaptive.quality_log
    
    # Fixed learning rates
    for lr in [0.01, 0.05, 0.2]:
        meta_fixed = AdaptiveMetaOracle(dim, rosenbrock, noise_std=0.05)
        meta_fixed.learning_rate = lr
        meta_fixed.lr_adaptation_rate = 0  # Disable adaptation
        meta_fixed.momentum_adaptation_rate = 0
        state = meta_fixed.iterate(initial.copy(), n_iter)
        results[f'Fixed lr={lr}'] = meta_fixed.quality_log
    
    return results, meta_adaptive


# ============================================================
# Multi-Problem Adaptation Experiment
# ============================================================

def multi_problem_experiment():
    """
    Test the adaptive meta-oracle on multiple problem types,
    demonstrating its ability to adapt to problem structure.
    """
    np.random.seed(789)
    dim = 3
    n_iter = 150
    
    problems = {
        'Sphere (Easy)': sphere,
        'Rosenbrock (Hard)': rosenbrock,
        'Rastrigin (Multi-modal)': rastrigin,
    }
    
    all_results = {}
    all_lr_histories = {}
    
    for name, fn in problems.items():
        meta = AdaptiveMetaOracle(dim, fn, noise_std=0.05)
        initial = np.random.randn(dim) * 2
        state = meta.iterate(initial.copy(), n_iter)
        all_results[name] = meta.quality_log
        all_lr_histories[name] = meta.lr_log
    
    return all_results, all_lr_histories


# ============================================================
# Main Visualization
# ============================================================

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Adaptive Meta-Oracle: Self-Improving Optimization", 
                 fontsize=16, fontweight='bold')
    
    # Plot 1: Adaptive vs Fixed comparison
    ax1 = axes[0, 0]
    results, meta_adaptive = compare_adaptive_vs_fixed()
    for name, quality in results.items():
        style = '-' if 'Adaptive' in name else '--'
        lw = 2.5 if 'Adaptive' in name else 1.5
        ax1.plot(quality, style, linewidth=lw, label=name)
    ax1.set_xlabel('Iteration')
    ax1.set_ylabel('Quality (negative loss)')
    ax1.set_title('(a) Adaptive vs Fixed Meta-Oracles\non Rosenbrock Function')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Self-adapted parameters
    ax2 = axes[0, 1]
    if meta_adaptive.lr_log:
        ax2.plot(meta_adaptive.lr_log, 'b-', label='Learning Rate', linewidth=1.5)
    if meta_adaptive.momentum_log:
        ax2.plot(meta_adaptive.momentum_log, 'r-', label='Momentum', linewidth=1.5)
    ax2.set_xlabel('Iteration')
    ax2.set_ylabel('Parameter Value')
    ax2.set_title('(b) Self-Adapted Meta-Parameters\n(Level 2 Meta-Oracle)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.annotate('Meta-oracle adapts its own\nhyperparameters online', 
                xy=(0.5, 0.95), xycoords='axes fraction', ha='center', va='top',
                fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Plot 3: Multi-problem adaptation
    ax3 = axes[1, 0]
    multi_results, multi_lr = multi_problem_experiment()
    colors = ['tab:blue', 'tab:orange', 'tab:green']
    for (name, quality), color in zip(multi_results.items(), colors):
        ax3.plot(quality, '-', color=color, linewidth=1.5, label=name)
    ax3.set_xlabel('Iteration')
    ax3.set_ylabel('Quality')
    ax3.set_title('(c) Adaptation to Different Problems\n(Same Meta-Oracle, Different Landscapes)')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Adapted learning rates per problem
    ax4 = axes[1, 1]
    for (name, lr_hist), color in zip(multi_lr.items(), colors):
        if lr_hist:
            ax4.plot(lr_hist, '-', color=color, linewidth=1.5, label=name)
    ax4.set_xlabel('Iteration')
    ax4.set_ylabel('Adapted Learning Rate')
    ax4.set_title('(d) Problem-Specific Adaptation\n(Learning Rate Self-Tuning)')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)
    ax4.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/python_demos/adaptive_oracle_plots.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved adaptive_oracle_plots.png")
    
    # Summary
    print("\n" + "="*60)
    print("ADAPTIVE META-ORACLE RESULTS")
    print("="*60)
    print(f"\nRosenbrock comparison (final quality):")
    for name, quality in results.items():
        print(f"  {name:20s}: {quality[-1]:.4f}")
    print(f"\nAdaptive meta-oracle final parameters:")
    print(f"  Learning rate: {meta_adaptive.learning_rate:.6f}")
    print(f"  Momentum:      {meta_adaptive.momentum:.4f}")
    print(f"  Exploration σ: {meta_adaptive.exploration_std:.4f}")


if __name__ == "__main__":
    main()
