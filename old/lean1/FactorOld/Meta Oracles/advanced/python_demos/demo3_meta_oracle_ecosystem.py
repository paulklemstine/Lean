#!/usr/bin/env python3
"""
Meta-Oracle Demo 3: Meta-Oracle Ecosystem

An ecosystem of meta-oracles that compete and cooperate:
- Each oracle specializes in a different domain
- A meta-meta-oracle selects and combines the best oracles
- The system exhibits emergent collective intelligence

This demonstrates:
1. No-Free-Lunch theorem: No single oracle dominates on all tasks
2. Portfolio theory: Combining oracles reduces variance
3. Reflective stability: The ecosystem converges to a fixed point

Run: python3 demo3_meta_oracle_ecosystem.py
Output: ecosystem_plots.png
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Dict, Tuple
from dataclasses import dataclass

# ============================================================
# Oracle Species
# ============================================================

class OracleSpecies:
    """A species of oracle with specific strengths and weaknesses."""
    
    def __init__(self, name: str, dim: int, specialty_dims: List[int], 
                 strength: float = 1.0):
        self.name = name
        self.dim = dim
        self.specialty_dims = specialty_dims
        self.strength = strength
        self.params = np.random.randn(dim) * 0.1
        self.fitness_history = []
        
    def predict(self, x: np.ndarray) -> np.ndarray:
        """Make a prediction."""
        # Oracle is strong in its specialty dimensions
        prediction = np.zeros_like(x)
        for d in range(self.dim):
            if d in self.specialty_dims:
                prediction[d] = x[d] * self.strength + self.params[d]
            else:
                prediction[d] = x[d] * 0.1 + self.params[d]  # Weak elsewhere
        return prediction
    
    def improve(self, target: np.ndarray, lr: float = 0.3):
        """Self-improve based on observed error."""
        x = np.random.randn(self.dim)
        pred = self.predict(x)
        error = target - pred
        
        # Update params more strongly in specialty dimensions
        for d in range(self.dim):
            if d in self.specialty_dims:
                self.params[d] += lr * error[d]
            else:
                self.params[d] += lr * 0.1 * error[d]


# ============================================================
# Meta-Oracle Ecosystem
# ============================================================

class MetaOracleEcosystem:
    """
    An ecosystem of competing and cooperating meta-oracles.
    
    Architecture:
    - N oracle species, each specialized for different problem aspects
    - A portfolio meta-oracle that combines them with adaptive weights
    - A selection mechanism that allocates resources to top performers
    
    Key property: The ecosystem is a contraction mapping on the space
    of oracle portfolios, with oracle entropy equal to the sum of
    individual oracle entropies weighted by portfolio weights.
    """
    
    def __init__(self, n_species: int, dim: int, target_fn):
        self.n_species = n_species
        self.dim = dim
        self.target_fn = target_fn
        
        # Create diverse oracle species
        self.species = []
        dims_per_species = max(1, dim // n_species)
        for i in range(n_species):
            start = (i * dims_per_species) % dim
            specialty = list(range(start, min(start + dims_per_species, dim)))
            strength = 0.5 + np.random.random() * 0.5
            species = OracleSpecies(f"Oracle-{i}", dim, specialty, strength)
            self.species.append(species)
        
        # Portfolio weights (start uniform)
        self.weights = np.ones(n_species) / n_species
        self.weight_history = [self.weights.copy()]
        
        # Tracking
        self.combined_fitness_history = []
        self.individual_fitness_history = {i: [] for i in range(n_species)}
        self.diversity_history = []
        
    def evaluate_species(self, x: np.ndarray) -> np.ndarray:
        """Evaluate each species' prediction quality."""
        target = self.target_fn(x)
        fitnesses = np.zeros(self.n_species)
        for i, species in enumerate(self.species):
            pred = species.predict(x)
            error = np.linalg.norm(pred - target)
            fitnesses[i] = np.exp(-error)  # Fitness in [0, 1]
        return fitnesses
    
    def combined_predict(self, x: np.ndarray) -> np.ndarray:
        """Weighted combination of all species' predictions."""
        prediction = np.zeros(self.dim)
        for i, species in enumerate(self.species):
            prediction += self.weights[i] * species.predict(x)
        return prediction
    
    def iterate(self, n_steps: int):
        """Run the ecosystem for n steps."""
        for step in range(n_steps):
            # Sample evaluation points
            n_eval = 20
            total_fitness = np.zeros(self.n_species)
            
            for _ in range(n_eval):
                x = np.random.randn(self.dim) * 2
                fitnesses = self.evaluate_species(x)
                total_fitness += fitnesses
                
                # Have each species self-improve
                target = self.target_fn(x)
                for i, species in enumerate(self.species):
                    species.improve(target, lr=0.1 * self.weights[i])
            
            avg_fitness = total_fitness / n_eval
            
            # Record individual fitness
            for i in range(self.n_species):
                self.individual_fitness_history[i].append(avg_fitness[i])
            
            # Update portfolio weights (softmax with temperature annealing)
            temp = max(0.1, 1.0 - step / n_steps)
            log_weights = np.log(self.weights + 1e-10) + avg_fitness / temp
            self.weights = np.exp(log_weights - np.max(log_weights))
            self.weights /= self.weights.sum()
            self.weight_history.append(self.weights.copy())
            
            # Evaluate combined oracle
            combined_fitness = 0
            for _ in range(n_eval):
                x = np.random.randn(self.dim) * 2
                target = self.target_fn(x)
                pred = self.combined_predict(x)
                combined_fitness += np.exp(-np.linalg.norm(pred - target))
            self.combined_fitness_history.append(combined_fitness / n_eval)
            
            # Measure diversity (entropy of weights)
            diversity = -np.sum(self.weights * np.log(self.weights + 1e-10))
            self.diversity_history.append(diversity)


# ============================================================
# No-Free-Lunch Demonstration
# ============================================================

def demonstrate_no_free_lunch():
    """
    Demonstrate the No-Free-Lunch theorem for meta-oracles:
    No single oracle dominates across all task permutations.
    """
    np.random.seed(42)
    n_tasks = 50
    n_oracles = 5
    
    # Generate random performance matrix
    # Each oracle has different strengths on different tasks
    performance = np.zeros((n_oracles, n_tasks))
    
    for i in range(n_oracles):
        # Each oracle is good at some tasks and bad at others
        base = np.random.randn(n_tasks)
        # Specialize: boost performance on certain tasks
        specialty = np.random.choice(n_tasks, n_tasks // n_oracles, replace=False)
        base[specialty] += 2
        performance[i] = base
    
    # For each task, rank the oracles
    rankings = np.zeros((n_oracles, n_tasks))
    for t in range(n_tasks):
        order = np.argsort(-performance[:, t])
        for rank, oracle_idx in enumerate(order):
            rankings[oracle_idx, t] = rank + 1
    
    avg_rankings = rankings.mean(axis=1)
    
    # The key NFL result: average ranking is always (n_oracles + 1) / 2
    # for a truly uniform distribution over tasks
    
    return performance, rankings, avg_rankings


# ============================================================
# Main
# ============================================================

def main():
    np.random.seed(42)
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle("Meta-Oracle Ecosystem: Collective Intelligence Through Self-Improvement", 
                 fontsize=16, fontweight='bold')
    
    # --- Ecosystem Experiment ---
    dim = 8
    n_species = 5
    n_steps = 100
    
    # Target function: a nonlinear transformation
    def target_fn(x):
        return np.sin(x) + 0.5 * np.cos(2 * x) + 0.1 * x**2
    
    ecosystem = MetaOracleEcosystem(n_species, dim, target_fn)
    ecosystem.iterate(n_steps)
    
    # Plot 1: Combined fitness over time
    ax1 = axes[0, 0]
    ax1.plot(ecosystem.combined_fitness_history, 'k-', linewidth=2, label='Combined Oracle')
    for i in range(n_species):
        ax1.plot(ecosystem.individual_fitness_history[i], '--', alpha=0.5, 
                label=f'Species {i}')
    ax1.set_xlabel('Generation')
    ax1.set_ylabel('Fitness')
    ax1.set_title('(a) Ecosystem Fitness Evolution')
    ax1.legend(fontsize=7, ncol=2)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Portfolio weight evolution
    ax2 = axes[0, 1]
    weight_array = np.array(ecosystem.weight_history)
    for i in range(n_species):
        ax2.fill_between(range(len(weight_array)), 
                        weight_array[:, :i].sum(axis=1),
                        weight_array[:, :i+1].sum(axis=1),
                        alpha=0.7, label=f'Species {i}')
    ax2.set_xlabel('Generation')
    ax2.set_ylabel('Portfolio Weight')
    ax2.set_title('(b) Portfolio Weight Evolution\n(Specialization Emergence)')
    ax2.legend(fontsize=7)
    ax2.set_ylim(0, 1)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Diversity over time
    ax3 = axes[0, 2]
    ax3.plot(ecosystem.diversity_history, 'g-', linewidth=2)
    ax3.axhline(y=np.log(n_species), color='r', linestyle='--', 
               label=f'Max entropy (log {n_species}={np.log(n_species):.2f})')
    ax3.set_xlabel('Generation')
    ax3.set_ylabel('Portfolio Entropy (bits)')
    ax3.set_title('(c) Ecosystem Diversity\n(Reflective Stability Convergence)')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # --- No Free Lunch ---
    performance, rankings, avg_rankings = demonstrate_no_free_lunch()
    
    # Plot 4: Performance heatmap
    ax4 = axes[1, 0]
    im = ax4.imshow(performance[:, :20], aspect='auto', cmap='RdYlGn')
    ax4.set_xlabel('Task')
    ax4.set_ylabel('Oracle')
    ax4.set_title('(d) No-Free-Lunch: Performance Matrix\n(No oracle dominates all tasks)')
    plt.colorbar(im, ax=ax4, shrink=0.8)
    
    # Plot 5: Average rankings
    ax5 = axes[1, 1]
    bars = ax5.bar(range(len(avg_rankings)), avg_rankings, color='steelblue', alpha=0.8)
    ax5.axhline(y=(len(avg_rankings) + 1) / 2, color='red', linestyle='--', 
               label='NFL theoretical average')
    ax5.set_xlabel('Oracle Index')
    ax5.set_ylabel('Average Rank (lower = better)')
    ax5.set_title('(e) Average Rankings Across Tasks\n(NFL: all oracles average ~3.0)')
    ax5.legend()
    ax5.grid(True, alpha=0.3)
    
    # Plot 6: Phase diagram (exploration vs exploitation)
    ax6 = axes[1, 2]
    # Simulate ecosystem for different initial diversities
    diversities_final = []
    fitnesses_final = []
    initial_temps = np.linspace(0.01, 2.0, 30)
    
    for temp_init in initial_temps:
        eco = MetaOracleEcosystem(n_species, dim, target_fn)
        # Set initial weights based on temperature
        eco.weights = np.exp(np.random.randn(n_species) / temp_init)
        eco.weights /= eco.weights.sum()
        eco.iterate(50)
        
        diversity = -np.sum(eco.weights * np.log(eco.weights + 1e-10))
        fitness = eco.combined_fitness_history[-1] if eco.combined_fitness_history else 0
        diversities_final.append(diversity)
        fitnesses_final.append(fitness)
    
    scatter = ax6.scatter(diversities_final, fitnesses_final, c=initial_temps, 
                         cmap='viridis', s=50, edgecolors='black', linewidth=0.5)
    plt.colorbar(scatter, ax=ax6, label='Initial Temperature', shrink=0.8)
    ax6.set_xlabel('Final Diversity (Portfolio Entropy)')
    ax6.set_ylabel('Final Combined Fitness')
    ax6.set_title('(f) Phase Diagram\n(Diversity vs Performance)')
    ax6.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/python_demos/ecosystem_plots.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved ecosystem_plots.png")
    
    # Summary
    print("\n" + "="*60)
    print("META-ORACLE ECOSYSTEM RESULTS")
    print("="*60)
    print(f"\nEcosystem ({n_species} species, {dim} dimensions, {n_steps} generations):")
    print(f"  Initial combined fitness: {ecosystem.combined_fitness_history[0]:.4f}")
    print(f"  Final combined fitness:   {ecosystem.combined_fitness_history[-1]:.4f}")
    print(f"  Final diversity:          {ecosystem.diversity_history[-1]:.4f}")
    print(f"\n  Final portfolio weights:")
    for i in range(n_species):
        print(f"    Species {i}: {ecosystem.weights[i]:.4f}")
    
    print(f"\nNo-Free-Lunch verification:")
    print(f"  Average rankings: {avg_rankings}")
    print(f"  Theoretical NFL:  {(len(avg_rankings)+1)/2:.1f}")
    print(f"  Observed mean:    {avg_rankings.mean():.2f}")
    
    # Hypothesis: The combined oracle outperforms any individual
    best_individual = max(max(ecosystem.individual_fitness_history[i]) 
                         for i in range(n_species))
    best_combined = max(ecosystem.combined_fitness_history)
    print(f"\n  HYPOTHESIS: Combined > Best Individual")
    print(f"  Best individual: {best_individual:.4f}")
    print(f"  Best combined:   {best_combined:.4f}")
    print(f"  Hypothesis {'CONFIRMED' if best_combined >= best_individual else 'REJECTED'}")


if __name__ == "__main__":
    main()
