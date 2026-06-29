#!/usr/bin/env python3
"""
Real-World Applications of the Gibbs Variational Principle.

Demonstrates applications across machine learning, physics, and optimization,
all grounded in the formally verified free energy theorems.
"""

import numpy as np
from typing import Tuple


# ============================================================
# Application 1: Softmax Classifier with Certified Bounds
# ============================================================

def softmax_classifier(
    logits: np.ndarray,  # shape (n_classes,)
    true_class: int,
    temperature: float = 1.0,
) -> dict:
    """Softmax classification with certified optimality bounds.
    
    The softmax function IS the Gibbs distribution with β = 1/temperature
    and E_i = -logits_i.
    
    By free_energy_bounds_min:
        max(logits) - log(n)/β ≤ log(Σ exp(logits)) ≤ max(logits) + log(n)
    """
    beta = 1.0 / temperature
    E = -logits  # Energy = negative logits
    
    # Gibbs distribution = softmax
    shifted = logits / temperature
    shifted -= np.max(shifted)
    probs = np.exp(shifted) / np.sum(np.exp(shifted))
    
    # Cross-entropy loss = free energy of one-hot at true class
    loss = -np.log(probs[true_class])
    
    # Certified bounds on log-partition function
    n = len(logits)
    log_Z = np.log(np.sum(np.exp(shifted)))
    upper = np.max(logits / temperature)
    lower = upper - np.log(n)
    
    return {
        "probabilities": probs,
        "predicted_class": int(np.argmax(probs)),
        "loss": loss,
        "log_partition": log_Z,
        "partition_bounds": (lower, upper),
        "temperature": temperature,
    }


# ============================================================
# Application 2: Energy-Based Model Sampling
# ============================================================

def energy_based_model(
    energy_fn: callable,
    n_states: int,
    betas: np.ndarray,
) -> dict:
    """Energy-based model analysis across temperatures.
    
    By gibbs_concentrates_on_unique_argmin: as β → ∞, the model
    concentrates on the lowest-energy state.
    
    By free_energy_gap_eq_kl_div: the quality of any approximate
    distribution q is measured exactly by KL(q || gibbs).
    """
    energies = np.array([energy_fn(i) for i in range(n_states)])
    
    results = []
    for beta in betas:
        shifted = -beta * energies
        shifted -= np.max(shifted)
        probs = np.exp(shifted) / np.sum(np.exp(shifted))
        
        entropy = -np.sum(np.where(probs > 0, probs * np.log(probs), 0))
        expected_energy = np.sum(probs * energies)
        free_energy = expected_energy - entropy / beta
        
        results.append({
            "beta": beta,
            "distribution": probs,
            "expected_energy": expected_energy,
            "entropy": entropy,
            "free_energy": free_energy,
            "mode": int(np.argmax(probs)),
        })
    
    return {
        "energies": energies,
        "ground_state": int(np.argmin(energies)),
        "results": results,
    }


# ============================================================
# Application 3: Portfolio Optimization via Entropy Regularization
# ============================================================

def entropy_regularized_portfolio(
    expected_returns: np.ndarray,
    risk_aversion: float,
    prior_weights: np.ndarray,
) -> Tuple[np.ndarray, float]:
    """Entropy-regularized portfolio optimization.
    
    Minimize: -Σ w_i r_i + (1/β) KL(w || prior)
    
    By posterior_as_free_energy_minimizer, the optimal portfolio is:
        w*(i) ∝ prior(i) * exp(β * r_i)
    
    This balances exploitation (high returns) with diversification
    (staying close to prior in KL sense).
    """
    beta = risk_aversion
    
    # Optimal portfolio = Gibbs posterior
    log_unnorm = np.log(prior_weights) + beta * expected_returns
    log_unnorm -= np.max(log_unnorm)
    unnorm = np.exp(log_unnorm)
    optimal_weights = unnorm / np.sum(unnorm)
    
    # Optimal value
    Z = np.sum(prior_weights * np.exp(beta * expected_returns))
    optimal_value = (1.0 / beta) * np.log(Z)  # Note: maximizing returns
    
    return optimal_weights, optimal_value


# ============================================================
# Application 4: Simulated Annealing with Certified Convergence
# ============================================================

def certified_annealing(
    objective: np.ndarray,
    beta_init: float = 0.1,
    beta_final: float = 100.0,
    n_steps: int = 50,
) -> dict:
    """Simulated annealing with certified approximation bounds.
    
    At each temperature 1/β, the certified bound from free_energy_bounds_min
    guarantees:
        min(E) ≤ soft_min(β) + log(n)/β
    
    So the gap to optimality is at most log(n)/β.
    """
    n = len(objective)
    betas = np.geomspace(beta_init, beta_final, n_steps)
    
    trajectory = []
    for beta in betas:
        # Gibbs distribution at current temperature
        shifted = -beta * objective
        shifted -= np.max(shifted)
        probs = np.exp(shifted) / np.sum(np.exp(shifted))
        
        # Soft-min with certified bound
        soft_min = np.sum(probs * objective)  # Expected energy under Gibbs
        certified_gap = np.log(n) / beta
        
        trajectory.append({
            "beta": beta,
            "temperature": 1.0 / beta,
            "soft_min": -(1.0/beta) * np.log(np.sum(np.exp(-beta * objective))),
            "expected_energy": soft_min,
            "certified_gap": certified_gap,
            "mode": int(np.argmax(probs)),
            "mode_energy": objective[np.argmax(probs)],
        })
    
    return {
        "true_min": float(np.min(objective)),
        "true_argmin": int(np.argmin(objective)),
        "trajectory": trajectory,
    }


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Softmax Classifier")
    print("=" * 70)
    
    logits = np.array([2.0, 1.0, 0.5, -1.0, 3.0])
    classes = ["cat", "dog", "bird", "fish", "horse"]
    
    for temp in [0.1, 1.0, 5.0]:
        result = softmax_classifier(logits, true_class=4, temperature=temp)
        print(f"\n  Temperature = {temp}:")
        print(f"    Probabilities: {np.round(result['probabilities'], 4)}")
        print(f"    Predicted: {classes[result['predicted_class']]}")
        print(f"    Loss: {result['loss']:.4f}")
    
    print()
    print("=" * 70)
    print("APPLICATION 2: Energy-Based Model")
    print("=" * 70)
    
    def protein_energy(state):
        # Simplified protein folding energy landscape
        energies = [5.0, 3.0, 1.0, 2.0, 4.0, 3.5, 6.0, 2.5]
        return energies[state]
    
    result = energy_based_model(
        protein_energy, 
        n_states=8,
        betas=np.array([0.5, 1.0, 5.0, 20.0])
    )
    
    print(f"\n  Ground state: {result['ground_state']} (energy = {result['energies'][result['ground_state']]})")
    for r in result['results']:
        print(f"  β={r['beta']:5.1f}: mode={r['mode']}, "
              f"E[energy]={r['expected_energy']:.3f}, "
              f"entropy={r['entropy']:.3f}, "
              f"F={r['free_energy']:.3f}")
    
    print()
    print("=" * 70)
    print("APPLICATION 3: Portfolio Optimization")
    print("=" * 70)
    
    assets = ["Tech", "Bonds", "Gold", "Real Estate"]
    returns = np.array([0.12, 0.04, 0.06, 0.08])
    prior = np.array([0.25, 0.25, 0.25, 0.25])
    
    for risk_aversion in [1.0, 5.0, 20.0]:
        weights, value = entropy_regularized_portfolio(returns, risk_aversion, prior)
        print(f"\n  Risk aversion β = {risk_aversion}:")
        for asset, w in zip(assets, weights):
            print(f"    {asset}: {w:.4f}")
        print(f"    Expected return bound: {value:.4f}")
    
    print()
    print("=" * 70)
    print("APPLICATION 4: Certified Annealing")
    print("=" * 70)
    
    np.random.seed(42)
    objective = np.random.randn(20) * 2 + 5
    objective[7] = 0.5  # Plant a minimum
    
    result = certified_annealing(objective, n_steps=10)
    print(f"\n  True minimum: {result['true_min']:.4f} at index {result['true_argmin']}")
    print(f"\n  {'Step':>4} | {'β':>8} | {'Soft-min':>10} | {'Gap bound':>10} | {'Mode E':>8}")
    print("  " + "-" * 55)
    for i, t in enumerate(result['trajectory']):
        print(f"  {i+1:4d} | {t['beta']:8.2f} | {t['soft_min']:10.4f} | "
              f"{t['certified_gap']:10.4f} | {t['mode_energy']:8.4f}")
    
    print("\n  Note: 'Gap bound' = log(n)/β is a certified upper bound on the")
    print("  difference between soft-min and the true minimum.")
    
    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demonstration of the Gibbs Variational Principle and Tropical Optimization.

This script provides concrete numerical examples illustrating the formally
verified theorems:
  1. Free energy gap = (1/β) * KL(p || gibbs)
  2. Gibbs variational inequality: F(p) ≥ -log(Z)/β
  3. Tropical sandwich: m - log(n)/β ≤ -log(Z)/β ≤ m
  4. Gibbs concentration on unique minimizer as β → ∞
  5. Bayesian posterior as free energy minimizer
"""

import numpy as np
from typing import Tuple

def partition_function(beta: float, E: np.ndarray) -> float:
    """Compute Z_β(E) = Σ exp(-β * E_i)."""
    return np.sum(np.exp(-beta * E))

def gibbs_weights(beta: float, E: np.ndarray) -> np.ndarray:
    """Compute Gibbs distribution p_β(i) = exp(-β E_i) / Z."""
    Z = partition_function(beta, E)
    return np.exp(-beta * E) / Z

def free_energy(beta: float, E: np.ndarray, p: np.ndarray) -> float:
    """Compute F_β(p; E) = Σ p_i E_i + (1/β) Σ p_i log(p_i)."""
    # Handle 0 * log(0) = 0 convention
    entropy_terms = np.where(p > 0, p * np.log(p), 0.0)
    return np.sum(p * E) + (1.0 / beta) * np.sum(entropy_terms)

def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """Compute KL(p || q) = Σ p_i log(p_i / q_i)."""
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))

def soft_min(beta: float, E: np.ndarray) -> float:
    """Compute -(1/β) log Z = soft minimum of E."""
    Z = partition_function(beta, E)
    return -(1.0 / beta) * np.log(Z)

# ============================================================
# Demo 1: KL Decomposition Identity
# ============================================================
print("=" * 70)
print("DEMO 1: Free Energy Gap = (1/β) * KL(p || gibbs)")
print("=" * 70)

E = np.array([1.0, 3.0, 2.0, 5.0])
beta = 2.0
n = len(E)

p_gibbs = gibbs_weights(beta, E)
Z = partition_function(beta, E)

# Test with various distributions
test_dists = [
    ("Uniform", np.ones(n) / n),
    ("Concentrated on min", np.array([0.7, 0.1, 0.1, 0.1])),
    ("Gibbs distribution", p_gibbs),
    ("Anti-Gibbs", np.array([0.05, 0.15, 0.1, 0.7])),
]

print(f"\nEnergy function E = {E}")
print(f"β = {beta}, n = {n}")
print(f"Partition function Z = {Z:.6f}")
print(f"Gibbs weights = {p_gibbs}")
print(f"-log(Z)/β = {-np.log(Z)/beta:.6f}")
print()

for name, p in test_dists:
    F = free_energy(beta, E, p)
    gap = F - (-np.log(Z) / beta)
    kl = kl_divergence(p, p_gibbs)
    kl_scaled = (1.0 / beta) * kl
    
    print(f"  {name}:")
    print(f"    F(p) = {F:.6f}")
    print(f"    F(p) + log(Z)/β = {gap:.6f}")
    print(f"    (1/β) KL(p||gibbs) = {kl_scaled:.6f}")
    print(f"    Match: {np.isclose(gap, kl_scaled)}")
    print(f"    F(p) ≥ -log(Z)/β: {F >= -np.log(Z)/beta - 1e-10}")
    print()

# ============================================================
# Demo 2: Tropical Sandwich Theorem
# ============================================================
print("=" * 70)
print("DEMO 2: Tropical Sandwich — Soft-Min Converges to Hard Min")
print("=" * 70)

E = np.array([3.0, 1.0, 4.0, 1.5, 2.7])
m = np.min(E)
n = len(E)

print(f"\nEnergy E = {E}")
print(f"Hard minimum m = {m}")
print(f"n = {n}, log(n) = {np.log(n):.4f}")
print()
print(f"{'β':>8} | {'soft-min':>12} | {'lower bound':>12} | {'upper bound':>6} | {'gap':>10}")
print("-" * 65)

for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0, 1000.0]:
    sm = soft_min(beta, E)
    lower = m - np.log(n) / beta
    upper = m
    gap = upper - sm
    print(f"{beta:8.1f} | {sm:12.6f} | {lower:12.6f} | {upper:6.1f} | {gap:10.6f}")

# ============================================================
# Demo 3: Gibbs Concentration on Unique Argmin
# ============================================================
print()
print("=" * 70)
print("DEMO 3: Gibbs Concentration on Unique Minimizer")
print("=" * 70)

E = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
k = np.argmin(E)
print(f"\nEnergy E = {E}")
print(f"Unique minimizer: index {k} with E[{k}] = {E[k]}")
print()
print(f"{'β':>8} | {'gibbs[k]':>10} | {'max other':>10} | {'near 1?':>8}")
print("-" * 50)

for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]:
    g = gibbs_weights(beta, E)
    others = np.max(np.delete(g, k))
    print(f"{beta:8.1f} | {g[k]:10.8f} | {others:10.8f} | {'YES' if g[k] > 0.99 else 'no':>8}")

# ============================================================
# Demo 4: Bayesian Posterior as Free Energy Minimizer
# ============================================================
print()
print("=" * 70)
print("DEMO 4: Bayesian Posterior Minimizes KL-Regularized Loss")
print("=" * 70)

# Prior and loss
prior = np.array([0.25, 0.25, 0.25, 0.25])
loss = np.array([0.5, 2.0, 1.0, 3.0])
beta = 3.0
n = len(prior)

# Gibbs posterior
Z_bayes = np.sum(prior * np.exp(-beta * loss))
posterior = prior * np.exp(-beta * loss) / Z_bayes

# Objective: E_p[L] + (1/β) KL(p || prior)
def bayes_objective(p, prior, loss, beta):
    expected_loss = np.sum(p * loss)
    kl = kl_divergence(p, prior)
    return expected_loss + (1.0 / beta) * kl

opt_val = -np.log(Z_bayes) / beta

print(f"\nPrior w = {prior}")
print(f"Loss L = {loss}")
print(f"β = {beta}")
print(f"Gibbs posterior q = {np.round(posterior, 6)}")
print(f"Optimal value = -(1/β)log(Z) = {opt_val:.6f}")
print()

test_dists_bayes = [
    ("Uniform", np.ones(n) / n),
    ("Prior", prior.copy()),
    ("Gibbs posterior", posterior),
    ("Concentrated on min-loss", np.array([0.7, 0.1, 0.1, 0.1])),
]

for name, p in test_dists_bayes:
    obj = bayes_objective(p, prior, loss, beta)
    print(f"  {name}: objective = {obj:.6f} (≥ {opt_val:.6f}? {obj >= opt_val - 1e-10})")

# ============================================================
# Demo 5: Temperature Sweep — From Bayesian to Tropical
# ============================================================
print()
print("=" * 70)
print("DEMO 5: Temperature Sweep — Bayesian → Tropical Transition")
print("=" * 70)

E = np.array([2.0, 1.0, 3.0])
print(f"\nEnergy E = {E}")
print(f"Hard minimum = {np.min(E)} at index {np.argmin(E)}")
print()
print(f"{'β':>8} | {'gibbs[0]':>8} | {'gibbs[1]':>8} | {'gibbs[2]':>8} | {'soft-min':>10} | {'entropy':>8}")
print("-" * 70)

for beta in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
    g = gibbs_weights(beta, E)
    sm = soft_min(beta, E)
    ent = -np.sum(np.where(g > 0, g * np.log(g), 0))
    print(f"{beta:8.2f} | {g[0]:8.4f} | {g[1]:8.4f} | {g[2]:8.4f} | {sm:10.6f} | {ent:8.4f}")

print()
print("As β → ∞: Gibbs → one-hot at minimizer, soft-min → hard min, entropy → 0")
print("As β → 0: Gibbs → uniform, soft-min → -∞, entropy → log(n)")

if __name__ == "__main__":
    print("\n\nAll demos completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Tropical/InformationTheory/FreeEnergyPrinciple.lean')

# Read visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Variational Free Energy as the Bridge Between Tropical Optimization and Bayesian Inference",
    "domain": "Tropical Mathematics / Statistical Mechanics / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Free Energy Principle Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Numerically Stable Soft-Minimum",
            "pseudocode": "1. c <- min(E)\n2. S <- sum(exp(-beta*(E_i - c)))\n3. return c - (1/beta)*log(S)\n\nComplexity: O(n) time, O(1) space\nCertified: |output - min(E)| <= log(n)/beta",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Sandwich Theorem",
            "data": viz_data["tropical_sandwich"]
        },
        {
            "name": "Gibbs Concentration on Unique Minimizer",
            "data": viz_data["gibbs_concentration"]
        },
        {
            "name": "Free Energy Landscape on Probability Simplex",
            "data": viz_data["free_energy_landscape"]
        },
        {
            "name": "Bayesian Posterior as Free Energy Minimizer",
            "data": viz_data["bayesian_posterior"]
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualizations for the Free Energy Principle and Tropical Optimization.

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_tropical_sandwich():
    """Visualization of the tropical sandwich theorem."""
    E = np.array([3.0, 1.0, 4.0, 1.5, 2.7])
    m = np.min(E)
    n = len(E)
    
    betas = np.linspace(0.1, 20, 200)
    soft_mins = []
    upper_bounds = []
    lower_bounds = []
    
    for beta in betas:
        Z = np.sum(np.exp(-beta * E))
        sm = -(1.0 / beta) * np.log(Z)
        soft_mins.append(sm)
        upper_bounds.append(m)
        lower_bounds.append(m - np.log(n) / beta)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.fill_between(betas, lower_bounds, upper_bounds, alpha=0.15, color='steelblue', 
                     label='Certified region')
    ax.plot(betas, soft_mins, 'b-', linewidth=2.5, label=r'Soft-min: $-\frac{1}{\beta}\log Z$')
    ax.plot(betas, upper_bounds, 'r--', linewidth=1.5, label=r'Hard min: $m = \min_i E_i$')
    ax.plot(betas, lower_bounds, 'g--', linewidth=1.5, label=r'Lower: $m - \frac{\log n}{\beta}$')
    
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Tropical Sandwich Theorem: Soft-Min → Hard Min', fontsize=16)
    ax.legend(fontsize=12, loc='lower right')
    ax.set_ylim([-1, 3.5])
    ax.grid(True, alpha=0.3)
    
    # Annotate
    ax.annotate(r'$\beta \to \infty$: tropical limit', 
                xy=(18, m), xytext=(12, m + 0.8),
                fontsize=11, arrowprops=dict(arrowstyle='->', color='black'),
                ha='center')
    
    plt.tight_layout()
    return fig


def plot_gibbs_concentration():
    """Visualization of Gibbs concentration on unique argmin."""
    E = np.array([2.0, 1.0, 3.0, 1.8, 2.5])
    k = np.argmin(E)
    
    betas = np.linspace(0.1, 15, 200)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: All Gibbs weights
    colors = ['#e74c3c', '#2ecc71', '#3498db', '#f39c12', '#9b59b6']
    for i in range(len(E)):
        weights = []
        for beta in betas:
            shifted = -beta * E
            shifted -= np.max(shifted)
            w = np.exp(shifted) / np.sum(np.exp(shifted))
            weights.append(w[i])
        label = f'State {i} (E={E[i]})' + (' ★' if i == k else '')
        lw = 3 if i == k else 1.5
        ax1.plot(betas, weights, color=colors[i], linewidth=lw, label=label)
    
    ax1.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax1.set_ylabel('Gibbs weight', fontsize=13)
    ax1.set_title('Gibbs Concentration on Minimizer', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([0, 1.05])
    
    # Right: Entropy decay
    entropies = []
    for beta in betas:
        shifted = -beta * E
        shifted -= np.max(shifted)
        w = np.exp(shifted) / np.sum(np.exp(shifted))
        ent = -np.sum(np.where(w > 0, w * np.log(w), 0))
        entropies.append(ent)
    
    ax2.plot(betas, entropies, 'b-', linewidth=2.5)
    ax2.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Zero entropy (one-hot)')
    ax2.axhline(y=np.log(len(E)), color='g', linestyle='--', alpha=0.5, 
                label=f'Max entropy = log({len(E)})')
    ax2.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax2.set_ylabel('Shannon entropy', fontsize=13)
    ax2.set_title('Entropy → 0 as β → ∞', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_free_energy_landscape():
    """3D-like visualization of free energy landscape."""
    E = np.array([1.0, 3.0, 2.0])
    n = len(E)
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    for idx, beta in enumerate([0.5, 2.0, 10.0]):
        ax = axes[idx]
        
        # Create simplex grid
        resolution = 100
        points = []
        values = []
        
        for i in range(resolution + 1):
            for j in range(resolution + 1 - i):
                k = resolution - i - j
                p = np.array([i, j, k]) / resolution
                if np.all(p >= 0) and np.abs(np.sum(p) - 1) < 1e-10:
                    # Free energy
                    ent = np.where(p > 1e-15, p * np.log(np.maximum(p, 1e-15)), 0)
                    F = np.sum(p * E) + (1.0 / beta) * np.sum(ent)
                    
                    # Barycentric to Cartesian
                    x = p[1] + 0.5 * p[2]
                    y = p[2] * np.sqrt(3) / 2
                    points.append((x, y))
                    values.append(F)
        
        points = np.array(points)
        values = np.array(values)
        
        scatter = ax.scatter(points[:, 0], points[:, 1], c=values, 
                           cmap='RdYlBu_r', s=3, vmin=np.min(values),
                           vmax=np.min(values) + 3)
        
        # Mark Gibbs distribution
        gibbs = np.exp(-beta * E) / np.sum(np.exp(-beta * E))
        gx = gibbs[1] + 0.5 * gibbs[2]
        gy = gibbs[2] * np.sqrt(3) / 2
        ax.plot(gx, gy, 'k*', markersize=15, markeredgecolor='white', markeredgewidth=1.5)
        
        # Draw simplex boundary
        ax.plot([0, 1, 0.5, 0], [0, 0, np.sqrt(3)/2, 0], 'k-', linewidth=1)
        
        ax.set_title(f'β = {beta}', fontsize=14)
        ax.set_aspect('equal')
        ax.axis('off')
        
        # Label vertices
        ax.text(-0.05, -0.05, f'E₁={E[0]}', fontsize=10, ha='center')
        ax.text(1.05, -0.05, f'E₂={E[1]}', fontsize=10, ha='center')
        ax.text(0.5, np.sqrt(3)/2 + 0.05, f'E₃={E[2]}', fontsize=10, ha='center')
        
        plt.colorbar(scatter, ax=ax, shrink=0.6, label='Free energy')
    
    fig.suptitle('Free Energy Landscape on the Probability Simplex', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig


def plot_bayesian_posterior():
    """Visualization of Bayesian posterior as free energy minimizer."""
    prior = np.array([0.25, 0.25, 0.25, 0.25])
    loss = np.array([0.5, 2.0, 1.0, 3.0])
    n = len(prior)
    
    betas = np.linspace(0.1, 10, 100)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Posterior evolution
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for i in range(n):
        posts = []
        for beta in betas:
            Z = np.sum(prior * np.exp(-beta * loss))
            post = prior[i] * np.exp(-beta * loss[i]) / Z
            posts.append(post)
        ax1.plot(betas, posts, color=colors[i], linewidth=2.5,
                label=f'State {i} (L={loss[i]})')
    
    ax1.axhline(y=0.25, color='gray', linestyle=':', alpha=0.5, label='Prior (uniform)')
    ax1.set_xlabel(r'Inverse temperature $\beta$ (regularization)', fontsize=13)
    ax1.set_ylabel('Posterior weight', fontsize=13)
    ax1.set_title('Bayesian Posterior: Prior → Concentrated', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([0, 1.05])
    
    # Right: Objective decomposition
    expected_losses = []
    kl_terms = []
    objectives = []
    opt_vals = []
    
    for beta in betas:
        Z = np.sum(prior * np.exp(-beta * loss))
        post = prior * np.exp(-beta * loss) / Z
        
        el = np.sum(post * loss)
        kl = np.sum(np.where(post > 0, post * np.log(post / prior), 0))
        obj = el + (1.0 / beta) * kl
        opt = -(1.0 / beta) * np.log(Z)
        
        expected_losses.append(el)
        kl_terms.append((1.0 / beta) * kl)
        objectives.append(obj)
        opt_vals.append(opt)
    
    ax2.plot(betas, expected_losses, 'r-', linewidth=2, label='Expected loss')
    ax2.plot(betas, kl_terms, 'b-', linewidth=2, label=r'$(1/\beta) \cdot$ KL(post || prior)')
    ax2.plot(betas, objectives, 'k-', linewidth=2.5, label='Total objective')
    ax2.plot(betas, opt_vals, 'g--', linewidth=2, label=r'$-(1/\beta)\log Z$ (minimum)')
    
    ax2.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax2.set_ylabel('Value', fontsize=13)
    ax2.set_title('Free Energy Decomposition at Optimum', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = plot_tropical_sandwich()
    fig1.savefig('tropical_sandwich.png', dpi=150, bbox_inches='tight')
    print("  Saved tropical_sandwich.png")
    
    fig2 = plot_gibbs_concentration()
    fig2.savefig('gibbs_concentration.png', dpi=150, bbox_inches='tight')
    print("  Saved gibbs_concentration.png")
    
    fig3 = plot_free_energy_landscape()
    fig3.savefig('free_energy_landscape.png', dpi=150, bbox_inches='tight')
    print("  Saved free_energy_landscape.png")
    
    fig4 = plot_bayesian_posterior()
    fig4.savefig('bayesian_posterior.png', dpi=150, bbox_inches='tight')
    print("  Saved bayesian_posterior.png")
    
    # Export base64 for JSON package
    viz_data = {
        "tropical_sandwich": fig_to_base64(fig1),
        "gibbs_concentration": fig_to_base64(fig2),
        "free_energy_landscape": fig_to_base64(fig3),
        "bayesian_posterior": fig_to_base64(fig4),
    }
    
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("  Saved viz_data.json")
    
    plt.close('all')
    print("All visualizations generated successfully.")
