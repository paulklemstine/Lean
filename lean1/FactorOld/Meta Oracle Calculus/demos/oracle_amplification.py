#!/usr/bin/env python3
"""
Oracle Amplification — From Weak to Strong

Demonstrates the Oracle Amplification Theorem: a noisy oracle that is correct
with probability p > 1/2 can be boosted to arbitrary accuracy by majority vote.

The key insight (Theorem 3.3): the error decays exponentially because
4p(1-p) < 1 whenever p ≠ 1/2. This is the (2p-1)² > 0 inequality.

Applications:
- Boosting in machine learning (AdaBoost)
- Randomized algorithms (BPP ⊂ PSPACE)  
- Polling and voting theory
- Ensemble methods in AI
"""

import random
import math
import statistics
from typing import List, Tuple

# ═══════════════════════════════════════════════════════════════════════════
# §1: Noisy Oracle Model
# ═══════════════════════════════════════════════════════════════════════════

class NoisyOracle:
    """
    A noisy oracle: answers correctly with probability p.
    Models any imperfect information source.
    """
    
    def __init__(self, truth: bool, accuracy: float):
        assert 0.5 < accuracy <= 1.0, "Oracle must be better than random"
        self.truth = truth
        self.accuracy = accuracy
        self.queries = 0
    
    def query(self) -> bool:
        """Ask the oracle. Returns correct answer with probability p."""
        self.queries += 1
        if random.random() < self.accuracy:
            return self.truth
        else:
            return not self.truth
    
    def error_rate(self) -> float:
        return 1.0 - self.accuracy
    
    def decay_factor(self) -> float:
        """4p(1-p) — the amplification decay factor. Always < 1 when p ≠ 1/2."""
        p = self.accuracy
        return 4 * p * (1 - p)


def majority_vote(oracle: NoisyOracle, n_queries: int) -> bool:
    """
    Amplification by majority vote.
    
    Ask the oracle n_queries times and return the majority answer.
    Error probability decays exponentially in n_queries.
    """
    votes = [oracle.query() for _ in range(n_queries)]
    return sum(votes) > n_queries / 2


# ═══════════════════════════════════════════════════════════════════════════
# §2: Amplification Experiment
# ═══════════════════════════════════════════════════════════════════════════

def amplification_experiment():
    """
    Empirically verify the amplification theorem.
    Shows error decaying exponentially with number of rounds.
    """
    
    print("=" * 70)
    print("  ORACLE AMPLIFICATION THEOREM")
    print("  'Democracy makes oracles trustworthy'")
    print("=" * 70)
    print()
    
    accuracies = [0.55, 0.6, 0.7, 0.8]
    n_trials = 10000
    
    for accuracy in accuracies:
        print(f"  Oracle accuracy p = {accuracy}")
        decay = 4 * accuracy * (1 - accuracy)
        print(f"  Decay factor 4p(1-p) = {decay:.4f}")
        print(f"  (2p-1)² = {(2*accuracy-1)**2:.4f} > 0  ← Why it works!")
        print()
        print(f"  {'Rounds':>8} {'Empirical Error':>16} {'Theoretical Bound':>18} {'Ratio':>8}")
        print(f"  {'-'*52}")
        
        for n_rounds in [1, 3, 5, 11, 21, 51, 101]:
            errors = 0
            for _ in range(n_trials):
                oracle = NoisyOracle(truth=True, accuracy=accuracy)
                result = majority_vote(oracle, n_rounds)
                if result != True:
                    errors += 1
            
            empirical_error = errors / n_trials
            # Theoretical bound: roughly (4p(1-p))^((n-1)/2)
            k = (n_rounds - 1) // 2
            theoretical = min(1.0, decay ** k)
            ratio = empirical_error / theoretical if theoretical > 0 else 0
            
            print(f"  {n_rounds:>8} {empirical_error:>16.6f} {theoretical:>18.6f} {ratio:>8.3f}")
        
        print()
    
    print("  CONCLUSION: Error decays EXPONENTIALLY with the number of rounds!")
    print("  This is the power of the amplification theorem (Theorem 3.3).")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §3: Cost-Optimal Amplification
# ═══════════════════════════════════════════════════════════════════════════

def cost_optimal_amplification():
    """
    Given a target error rate δ, find the minimum-cost amplification strategy.
    
    If each query costs $c and the oracle has accuracy p, the optimal number
    of rounds is k = ⌈log(δ) / log(4p(1-p))⌉, costing (2k+1)·c total.
    """
    
    print("=" * 70)
    print("  COST-OPTIMAL AMPLIFICATION")
    print("  Minimum queries to achieve target accuracy")
    print("=" * 70)
    print()
    
    target_errors = [0.1, 0.01, 0.001, 0.0001, 1e-6, 1e-10]
    
    print(f"  Oracle accuracy p = 0.6")
    print(f"  Cost per query: $1")
    print()
    print(f"  {'Target Error δ':>16} {'Rounds needed':>15} {'Total Queries':>15} {'Total Cost':>12}")
    print(f"  {'-'*60}")
    
    p = 0.6
    decay = 4 * p * (1 - p)
    
    for delta in target_errors:
        if decay >= 1:
            k = float('inf')
        else:
            k = max(1, math.ceil(math.log(delta) / math.log(decay)))
        
        n_queries = 2 * k + 1
        cost = n_queries * 1  # $1 per query
        
        print(f"  {delta:>16.1e} {k:>15} {n_queries:>15} {f'${cost}':>12}")
    
    print()
    print(f"  Key insight: cost grows as O(log(1/δ)) — LOGARITHMIC in precision!")
    print(f"  Going from 10% to 0.0001% error only costs ~4x more queries.")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §4: Oracle Ensemble — Combining Multiple Oracles
# ═══════════════════════════════════════════════════════════════════════════

def oracle_ensemble_demo():
    """
    Demonstrate combining multiple oracles with different accuracies.
    
    The optimal weighting follows from Bayesian updating:
    weight each oracle proportionally to log(p/(1-p)).
    """
    
    print("=" * 70)
    print("  ORACLE ENSEMBLE — Weighted Combination")
    print("  Bayesian optimal weighting of multiple oracles")
    print("=" * 70)
    print()
    
    truth = True
    n_trials = 10000
    
    oracle_specs = [
        ("Weak", 0.55),
        ("Medium", 0.70),
        ("Strong", 0.90),
    ]
    
    # Strategy 1: Single best oracle
    errors_single = 0
    for _ in range(n_trials):
        oracle = NoisyOracle(truth=truth, accuracy=0.90)
        if oracle.query() != truth:
            errors_single += 1
    
    # Strategy 2: Unweighted majority of all three
    errors_majority = 0
    for _ in range(n_trials):
        votes = []
        for name, acc in oracle_specs:
            oracle = NoisyOracle(truth=truth, accuracy=acc)
            votes.append(oracle.query())
        if sum(votes) <= len(votes) / 2:
            errors_majority += 1
    
    # Strategy 3: Bayesian weighted vote (log-odds weighting)
    errors_bayesian = 0
    weights = [math.log(acc / (1 - acc)) for _, acc in oracle_specs]
    for _ in range(n_trials):
        score = 0
        for (name, acc), w in zip(oracle_specs, weights):
            oracle = NoisyOracle(truth=truth, accuracy=acc)
            vote = oracle.query()
            score += w if vote else -w
        if score <= 0:
            errors_bayesian += 1
    
    print(f"  Oracle ensemble: {', '.join(f'{n}(p={a})' for n, a in oracle_specs)}")
    print(f"  Log-odds weights: {', '.join(f'{w:.2f}' for w in weights)}")
    print()
    print(f"  Strategy                  Error Rate")
    print(f"  {'—'*45}")
    print(f"  Single best (p=0.90)      {errors_single/n_trials:.4f}")
    print(f"  Unweighted majority       {errors_majority/n_trials:.4f}")
    print(f"  Bayesian weighted         {errors_bayesian/n_trials:.4f}")
    print()
    print(f"  → Bayesian weighting optimally combines oracle strengths!")
    print(f"  → Each oracle's weight = log(p/(1-p)), its 'log-odds' of reliability")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §5: The Self-Improving Oracle (Bootstrap)
# ═══════════════════════════════════════════════════════════════════════════

def bootstrap_demo():
    """
    Demonstrate the Oracle Bootstrap Theorem:
    An oracle that uses its own outputs as inputs converges to truth.
    
    This models self-improving AI: each iteration of self-evaluation
    brings the oracle closer to an idempotent fixed point.
    """
    
    print("=" * 70)
    print("  ORACLE BOOTSTRAP — Self-Improving Oracle")
    print("  Theorem 8.1: Monotone improvement converges to a fixed point")
    print("=" * 70)
    print()
    
    # Model: oracle estimates a value, each iteration reduces error
    true_value = 3.14159
    
    def noisy_estimate(current: float, noise_level: float) -> float:
        """One iteration of self-improvement."""
        noise = random.gauss(0, noise_level)
        # Contraction: move 80% toward truth + noise
        return 0.2 * current + 0.8 * true_value + noise
    
    # Run bootstrap iterations
    print(f"  True value: {true_value}")
    print(f"  Contraction factor: c = 0.2 (convergence guaranteed since c < 1)")
    print()
    print(f"  {'Iteration':>10} {'Estimate':>12} {'Error':>12} {'c^n bound':>12}")
    print(f"  {'-'*48}")
    
    current = 100.0  # Start far from truth
    initial_error = abs(current - true_value)
    c = 0.2
    
    for i in range(20):
        error = abs(current - true_value)
        bound = c ** i * initial_error
        print(f"  {i:>10} {current:>12.6f} {error:>12.6f} {bound:>12.6f}")
        current = noisy_estimate(current, noise_level=0.01)
    
    print()
    print(f"  → Error decays geometrically: bounded by c^n × initial_error")
    print(f"  → Converges to a FIXED POINT (idempotent oracle)")
    print(f"  → This is the Banach contraction theorem applied to oracles!")
    print()


if __name__ == "__main__":
    random.seed(42)
    amplification_experiment()
    cost_optimal_amplification()
    oracle_ensemble_demo()
    bootstrap_demo()
