#!/usr/bin/env python3
"""
Meta-Oracle Demo 4: The Complete Self-Improving Algorithm

Implements the full Adaptive Meta-Oracle algorithm from the paper,
with convergence detection, entropy tracking, and hierarchical adaptation.

This is the practical realization of the theory: a system that
continuously monitors its own improvement rate and adapts accordingly.

Run: python3 demo4_self_improving_algorithm.py
Output: self_improving_algorithm.png
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Optional, Tuple, Dict
from dataclasses import dataclass, field
import time

@dataclass
class OracleState:
    params: np.ndarray
    quality: float = float('-inf')
    iteration: int = 0

@dataclass
class MetaState:
    learning_rate: float = 0.1
    momentum: float = 0.0
    exploration: float = 0.5
    batch_size: int = 10

@dataclass
class MetaMetaState:
    lr_adapt_rate: float = 0.05
    momentum_adapt_rate: float = 0.02
    exploration_adapt_rate: float = 0.03
    temperature: float = 1.0

class SelfImprovingMetaOracle:
    """
    The complete self-improving meta-oracle algorithm.
    
    Three-level hierarchy:
    - Level 0: Oracle parameters (the solution)
    - Level 1: Meta-parameters (how to search)
    - Level 2: Meta-meta-parameters (how to adapt the search)
    
    With convergence detection via oracle entropy monitoring.
    """
    
    def __init__(self, dim: int, objective: Callable, 
                 entropy_window: int = 10, convergence_threshold: float = 0.01):
        self.dim = dim
        self.objective = objective
        self.entropy_window = entropy_window
        self.convergence_threshold = convergence_threshold
        
        # State at each level
        self.oracle = OracleState(params=np.random.randn(dim) * 2)
        self.meta = MetaState()
        self.metameta = MetaMetaState()
        
        # History tracking
        self.quality_history: List[float] = []
        self.entropy_history: List[float] = []
        self.lr_history: List[float] = []
        self.momentum_history: List[float] = []
        self.exploration_history: List[float] = []
        self.distance_history: List[float] = []
        self.velocity = np.zeros(dim)
        
        # Best found
        self.best_params = self.oracle.params.copy()
        self.best_quality = float('-inf')
    
    def evaluate(self, params: np.ndarray) -> float:
        """Evaluate oracle quality (negative objective for minimization)."""
        return -self.objective(params)
    
    def estimate_gradient(self, params: np.ndarray) -> np.ndarray:
        """Estimate gradient via Gaussian perturbation (evolution strategy)."""
        grad = np.zeros(self.dim)
        perturbations = np.random.randn(self.meta.batch_size, self.dim)
        
        for p in perturbations:
            noise = self.meta.exploration * p
            q_plus = self.evaluate(params + noise)
            q_minus = self.evaluate(params - noise)
            grad += (q_plus - q_minus) * p
        
        grad /= (2 * self.meta.batch_size * self.meta.exploration)
        return grad
    
    def level0_improve(self) -> float:
        """Level 0: Improve oracle parameters."""
        grad = self.estimate_gradient(self.oracle.params)
        
        # Momentum update
        self.velocity = self.meta.momentum * self.velocity + self.meta.learning_rate * grad
        self.oracle.params = self.oracle.params + self.velocity
        
        # Evaluate new quality
        quality = self.evaluate(self.oracle.params)
        self.oracle.quality = quality
        self.oracle.iteration += 1
        
        # Track best
        if quality > self.best_quality:
            self.best_quality = quality
            self.best_params = self.oracle.params.copy()
        
        return quality
    
    def estimate_oracle_entropy(self) -> float:
        """Estimate oracle entropy from recent quality improvements."""
        if len(self.quality_history) < 3:
            return 1.0  # Default
        
        recent = self.quality_history[-self.entropy_window:]
        if len(recent) < 2:
            return 1.0
        
        # Estimate convergence rate from quality improvement decay
        improvements = [abs(recent[i+1] - recent[i]) for i in range(len(recent)-1)]
        if len(improvements) < 2:
            return 1.0
        
        # Fit exponential decay to improvement magnitudes
        if improvements[-1] > 1e-15 and improvements[0] > 1e-15:
            ratio = improvements[-1] / improvements[0]
            n_steps = len(improvements) - 1
            if ratio > 0 and ratio < 1:
                k = ratio ** (1.0 / n_steps)
                return -np.log(max(k, 1e-10))
        
        return 0.01  # Very low entropy if can't estimate
    
    def level1_adapt(self, quality: float, entropy: float):
        """Level 1: Adapt meta-parameters based on observed improvement."""
        if len(self.quality_history) >= 2:
            improvement = quality - self.quality_history[-1]
        else:
            improvement = 0
        
        # Adapt learning rate based on improvement sign
        if improvement > 0:
            self.meta.learning_rate *= (1 + self.metameta.lr_adapt_rate)
        else:
            self.meta.learning_rate *= (1 - self.metameta.lr_adapt_rate * 1.5)
        self.meta.learning_rate = np.clip(self.meta.learning_rate, 1e-5, 2.0)
        
        # Adapt momentum based on consistency
        if len(self.quality_history) >= 3:
            recent_improvements = [self.quality_history[i+1] - self.quality_history[i] 
                                  for i in range(len(self.quality_history[-3:])-1)]
            if len(recent_improvements) >= 2:
                if recent_improvements[-1] * recent_improvements[-2] > 0:
                    self.meta.momentum = min(0.99, 
                        self.meta.momentum + self.metameta.momentum_adapt_rate)
                else:
                    self.meta.momentum = max(0.0,
                        self.meta.momentum - self.metameta.momentum_adapt_rate * 2)
        
        # Adapt exploration based on entropy
        if entropy < 0.5:
            self.meta.exploration *= (1 - self.metameta.exploration_adapt_rate)
        elif entropy > 2.0:
            self.meta.exploration *= (1 + self.metameta.exploration_adapt_rate)
        self.meta.exploration = np.clip(self.meta.exploration, 0.001, 5.0)
    
    def level2_adapt(self, entropy: float):
        """Level 2: Adapt meta-meta-parameters (the adaptation rates themselves)."""
        if len(self.entropy_history) < 5:
            return
        
        # Is entropy increasing or decreasing?
        recent_entropy = self.entropy_history[-5:]
        entropy_trend = np.polyfit(range(len(recent_entropy)), recent_entropy, 1)[0]
        
        # If entropy is decreasing (convergence slowing), increase adaptation aggressiveness
        if entropy_trend < -0.01:
            self.metameta.lr_adapt_rate *= 1.1
            self.metameta.temperature *= 0.95
        elif entropy_trend > 0.01:
            self.metameta.lr_adapt_rate *= 0.95
            self.metameta.temperature *= 1.02
        
        self.metameta.lr_adapt_rate = np.clip(self.metameta.lr_adapt_rate, 0.001, 0.5)
        self.metameta.temperature = np.clip(self.metameta.temperature, 0.1, 5.0)
    
    def has_converged(self) -> bool:
        """Check convergence via oracle entropy."""
        if len(self.entropy_history) < self.entropy_window:
            return False
        recent = self.entropy_history[-self.entropy_window:]
        return np.mean(recent) < self.convergence_threshold
    
    def run(self, max_iterations: int = 500, verbose: bool = True) -> OracleState:
        """Run the full self-improving algorithm."""
        if verbose:
            print(f"{'Iter':>5} {'Quality':>12} {'Entropy':>10} {'LR':>10} {'Mom':>8} {'Expl':>8}")
            print("-" * 60)
        
        for i in range(max_iterations):
            # Level 0: Improve oracle
            quality = self.level0_improve()
            
            # Estimate oracle entropy
            entropy = self.estimate_oracle_entropy()
            
            # Level 1: Adapt meta-parameters
            self.level1_adapt(quality, entropy)
            
            # Level 2: Adapt meta-meta-parameters
            self.level2_adapt(entropy)
            
            # Record history
            self.quality_history.append(quality)
            self.entropy_history.append(entropy)
            self.lr_history.append(self.meta.learning_rate)
            self.momentum_history.append(self.meta.momentum)
            self.exploration_history.append(self.meta.exploration)
            
            if verbose and (i % 25 == 0 or i == max_iterations - 1):
                print(f"{i:5d} {quality:12.4f} {entropy:10.4f} {self.meta.learning_rate:10.6f} "
                      f"{self.meta.momentum:8.4f} {self.meta.exploration:8.4f}")
            
            # Check convergence
            if self.has_converged():
                if verbose:
                    print(f"\n✓ Converged at iteration {i} (oracle entropy < {self.convergence_threshold})")
                break
        
        self.oracle.params = self.best_params
        self.oracle.quality = self.best_quality
        return self.oracle


# ============================================================
# Test Problems
# ============================================================

def ackley(x: np.ndarray) -> float:
    """Ackley function: heavily multi-modal."""
    n = len(x)
    sum1 = np.sum(x**2)
    sum2 = np.sum(np.cos(2 * np.pi * x))
    return -20 * np.exp(-0.2 * np.sqrt(sum1/n)) - np.exp(sum2/n) + 20 + np.e

def schwefel(x: np.ndarray) -> float:
    """Schwefel function: deceptive landscape."""
    n = len(x)
    return 418.9829 * n - np.sum(x * np.sin(np.sqrt(np.abs(x))))

def styblinski_tang(x: np.ndarray) -> float:
    """Styblinski-Tang function."""
    return np.sum(x**4 - 16*x**2 + 5*x) / 2


# ============================================================
# Comparative Experiment
# ============================================================

def run_comparison():
    """Compare self-improving meta-oracle against baselines."""
    np.random.seed(42)
    dim = 5
    n_iter = 300
    
    problems = {
        'Ackley': (ackley, np.zeros(dim)),  # optimal at origin
        'Styblinski-Tang': (styblinski_tang, np.full(dim, -2.903534)),
    }
    
    results = {}
    
    for prob_name, (fn, optimal) in problems.items():
        print(f"\n{'='*60}")
        print(f"Problem: {prob_name} (dim={dim})")
        print(f"{'='*60}")
        
        # Self-improving meta-oracle
        meta = SelfImprovingMetaOracle(dim, fn, convergence_threshold=0.005)
        meta.oracle.params = np.random.randn(dim) * 3
        initial_params = meta.oracle.params.copy()
        
        result = meta.run(max_iterations=n_iter, verbose=True)
        
        print(f"\nFinal quality: {result.quality:.6f}")
        print(f"Distance to known optimum: {np.linalg.norm(meta.best_params - optimal):.6f}")
        
        results[prob_name] = {
            'quality': meta.quality_history,
            'entropy': meta.entropy_history,
            'lr': meta.lr_history,
            'momentum': meta.momentum_history,
            'exploration': meta.exploration_history,
            'best_params': meta.best_params,
            'best_quality': meta.best_quality,
            'optimal': optimal,
        }
    
    return results


def main():
    results = run_comparison()
    
    n_problems = len(results)
    fig, axes = plt.subplots(n_problems, 3, figsize=(16, 5 * n_problems))
    if n_problems == 1:
        axes = axes[np.newaxis, :]
    
    fig.suptitle("Self-Improving Meta-Oracle: Complete Algorithm", 
                 fontsize=16, fontweight='bold')
    
    for idx, (name, data) in enumerate(results.items()):
        # Quality evolution
        ax1 = axes[idx, 0]
        ax1.plot(data['quality'], 'b-', linewidth=1.5)
        ax1.axhline(y=-min(1e-10, abs(data['best_quality'])), color='r', linestyle='--', 
                    alpha=0.5, label='Best found')
        ax1.set_xlabel('Iteration')
        ax1.set_ylabel('Quality')
        ax1.set_title(f'{name}: Quality Evolution')
        ax1.grid(True, alpha=0.3)
        
        # Oracle entropy
        ax2 = axes[idx, 1]
        ax2.plot(data['entropy'], 'g-', linewidth=1.5)
        ax2.axhline(y=0.005, color='r', linestyle='--', alpha=0.5, 
                    label='Convergence threshold')
        ax2.set_xlabel('Iteration')
        ax2.set_ylabel('Oracle Entropy (nats)')
        ax2.set_title(f'{name}: Oracle Entropy')
        ax2.legend(fontsize=8)
        ax2.grid(True, alpha=0.3)
        
        # Adapted parameters
        ax3 = axes[idx, 2]
        ax3.plot(data['lr'], 'b-', linewidth=1, label='Learning Rate', alpha=0.8)
        ax3.plot(data['momentum'], 'r-', linewidth=1, label='Momentum', alpha=0.8)
        ax3.plot(data['exploration'], 'g-', linewidth=1, label='Exploration', alpha=0.8)
        ax3.set_xlabel('Iteration')
        ax3.set_ylabel('Parameter Value')
        ax3.set_title(f'{name}: Self-Adapted Parameters')
        ax3.legend(fontsize=8)
        ax3.set_yscale('log')
        ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/python_demos/self_improving_algorithm.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Saved self_improving_algorithm.png")


if __name__ == "__main__":
    main()
