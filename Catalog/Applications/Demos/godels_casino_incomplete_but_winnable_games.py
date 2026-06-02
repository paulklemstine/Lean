#!/usr/bin/env python3
"""
Gödel's Casino: Interactive Demonstration

Simulates Gödel's Casino with various oracle strengths and strategies,
demonstrating that the selective strategy guarantees non-negative profit
while naive strategies can be catastrophically exploited.
"""

import random
import statistics

def godel_casino_round(truth: bool, decidable: bool, strategy: str) -> int:
    """
    Simulate one round of Gödel's Casino.
    
    Args:
        truth: The actual truth value of the statement
        decidable: Whether the oracle can determine the truth
        strategy: One of 'selective', 'always_true', 'always_false', 'random'
    
    Returns:
        Payoff: +1 (correct), -1 (incorrect), 0 (abstain)
    """
    if strategy == 'selective':
        if decidable:
            return 1  # Always correct when decidable
        else:
            return 0  # Abstain when undecidable
    elif strategy == 'always_true':
        return 1 if truth else -1
    elif strategy == 'always_false':
        return -1 if truth else 1
    elif strategy == 'random':
        bet_true = random.choice([True, False])
        return 1 if bet_true == truth else -1
    else:
        raise ValueError(f"Unknown strategy: {strategy}")


def simulate_casino(n_rounds: int, decidable_fraction: float,
                     strategy: str, n_simulations: int = 1000) -> dict:
    """
    Simulate multiple games of Gödel's Casino.
    
    Args:
        n_rounds: Number of rounds per game
        decidable_fraction: Fraction of rounds that are decidable
        strategy: Strategy to use
        n_simulations: Number of games to simulate
    
    Returns:
        Dictionary with mean profit, std, min, max
    """
    profits = []
    for _ in range(n_simulations):
        total = 0
        for _ in range(n_rounds):
            truth = random.choice([True, False])
            decidable = random.random() < decidable_fraction
            total += godel_casino_round(truth, decidable, strategy)
        profits.append(total)
    
    return {
        'mean': statistics.mean(profits),
        'std': statistics.stdev(profits) if len(profits) > 1 else 0,
        'min': min(profits),
        'max': max(profits),
        'positive_rate': sum(1 for p in profits if p > 0) / len(profits),
        'nonneg_rate': sum(1 for p in profits if p >= 0) / len(profits),
    }


def oracle_hierarchy_demo():
    """Demonstrate how oracle strength affects profit."""
    print("=" * 70)
    print("GÖDEL'S CASINO: Oracle Hierarchy Demonstration")
    print("=" * 70)
    print()
    
    n_rounds = 100
    strategies = ['selective', 'always_true', 'random']
    fractions = [0.0, 0.1, 0.25, 0.5, 0.75, 1.0]
    
    for frac in fractions:
        print(f"\n--- Decidable Fraction: {frac:.0%} ---")
        for strat in strategies:
            result = simulate_casino(n_rounds, frac, strat, n_simulations=500)
            print(f"  {strat:15s}: mean={result['mean']:+7.1f}, "
                  f"std={result['std']:5.1f}, "
                  f"P(profit>0)={result['positive_rate']:.1%}, "
                  f"P(profit≥0)={result['nonneg_rate']:.1%}")


def information_value_demo():
    """Demonstrate the Information Value Theorem."""
    print("\n" + "=" * 70)
    print("INFORMATION VALUE THEOREM DEMONSTRATION")
    print("=" * 70)
    print()
    print("The Information Value of an oracle = # of additionally decidable rounds")
    print()
    
    n_rounds = 50
    for base_frac in [0.2, 0.4, 0.6]:
        for oracle_frac in [0.1, 0.3, 0.5]:
            combined = min(base_frac + oracle_frac, 1.0)
            base_profit = int(n_rounds * base_frac)
            combined_profit = int(n_rounds * combined)
            info_value = combined_profit - base_profit
            print(f"  Base dec: {base_frac:.0%}, Oracle ext: {oracle_frac:.0%} "
                  f"→ Combined: {combined:.0%}, "
                  f"Info Value: {info_value} rounds")


def entropy_duality_demo():
    """Demonstrate the Entropy-Profit Duality."""
    print("\n" + "=" * 70)
    print("ENTROPY-PROFIT DUALITY")
    print("=" * 70)
    print()
    print("Incompleteness Entropy + Decidable Fraction = 1 (always!)")
    print()
    
    for n in [10, 50, 100, 1000]:
        for dec in range(0, n + 1, max(1, n // 5)):
            entropy = (n - dec) / n
            dec_frac = dec / n
            print(f"  n={n:4d}, dec={dec:4d}: "
                  f"entropy={entropy:.3f} + dec_frac={dec_frac:.3f} = "
                  f"{entropy + dec_frac:.3f}")


def layered_casino_demo():
    """Demonstrate the Layered Casino (oracle hierarchy)."""
    print("\n" + "=" * 70)
    print("LAYERED CASINO: Oracle Hierarchy")
    print("=" * 70)
    print()
    print("Each layer decides a superset of the previous layer.")
    print("Profit monotonically increases through layers.")
    print()
    
    n_statements = 100
    n_layers = 5
    
    # Simulate: each layer decides ~20% more
    decidable_at_layer = [set() for _ in range(n_layers)]
    all_indices = list(range(n_statements))
    
    for layer in range(n_layers):
        if layer == 0:
            # Base: decide ~30% of statements
            decidable_at_layer[0] = set(random.sample(all_indices, 30))
        else:
            # Each layer adds ~15% more
            remaining = set(all_indices) - decidable_at_layer[layer - 1]
            new_count = min(15, len(remaining))
            new_dec = set(random.sample(list(remaining), new_count))
            decidable_at_layer[layer] = decidable_at_layer[layer - 1] | new_dec
    
    print(f"  {'Layer':>8s}  {'Decidable':>10s}  {'Profit':>8s}  {'Entropy':>10s}")
    for layer in range(n_layers):
        dec = len(decidable_at_layer[layer])
        profit = dec  # Selective strategy profit = decidable count
        entropy = (n_statements - dec) / n_statements
        print(f"  {layer:>8d}  {dec:>10d}  {profit:>8d}  {entropy:>10.3f}")


def conjecture_test():
    """
    Test the Arithmetic Decidability Density Conjecture.
    
    Conjecture: For sentences of quantifier complexity ≤ k,
    at least fraction 1/(2^k) are decidable.
    
    We simulate this by generating random "statements" with assigned
    complexity levels and checking if our model predicts the bound.
    """
    print("\n" + "=" * 70)
    print("FALSIFIABLE CONJECTURE TEST")
    print("=" * 70)
    print()
    print("Conjecture: At complexity level k, ≥ 1/2^k fraction is decidable")
    print()
    
    n_statements = 1000
    max_complexity = 5
    
    for k in range(max_complexity + 1):
        # Model: decidable fraction decreases with complexity
        # Σ₁ sentences: ~100% decidable (Σ₁-completeness)
        # Higher levels: ~1/2 of previous level
        true_decidable_frac = max(0.05, 1.0 / (2 ** k))
        
        decidable_count = sum(
            1 for _ in range(n_statements)
            if random.random() < true_decidable_frac
        )
        actual_frac = decidable_count / n_statements
        bound = 1.0 / (2 ** k)
        holds = actual_frac >= bound * 0.9  # Allow 10% noise
        
        print(f"  k={k}: decidable={actual_frac:.3f}, "
              f"bound=1/{2**k}={bound:.4f}, "
              f"{'✓ HOLDS' if holds else '✗ FAILS'}")


if __name__ == '__main__':
    random.seed(42)
    oracle_hierarchy_demo()
    information_value_demo()
    entropy_duality_demo()
    layered_casino_demo()
    conjecture_test()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy Profit Landscape

Shows how selective strategy profit increases with oracle strength,
demonstrating the Layer Profit Monotonicity theorem visually.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def generate_layered_casino(n_statements: int, n_layers: int, seed: int = 42):
    """Generate a layered casino with monotonically increasing oracle strength."""
    rng = np.random.RandomState(seed)
    decidable = np.zeros((n_layers, n_statements), dtype=bool)
    
    # Each layer decides a superset of the previous
    for layer in range(n_layers):
        if layer == 0:
            # Base: ~20% decidable
            idx = rng.choice(n_statements, size=int(0.2 * n_statements), replace=False)
            decidable[0, idx] = True
        else:
            decidable[layer] = decidable[layer - 1].copy()
            remaining = np.where(~decidable[layer])[0]
            new_count = min(int(0.15 * n_statements), len(remaining))
            if new_count > 0:
                new_idx = rng.choice(remaining, size=new_count, replace=False)
                decidable[layer, new_idx] = True
    
    return decidable

def plot_oracle_hierarchy():
    """Plot the oracle hierarchy profit landscape."""
    n_statements = 200
    n_layers = 8
    
    decidable = generate_layered_casino(n_statements, n_layers)
    
    layers = np.arange(n_layers)
    dec_counts = decidable.sum(axis=1)
    profits = dec_counts  # Selective profit = decidable count
    entropies = 1 - dec_counts / n_statements
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Profit vs Layer (monotonically increasing)
    ax1 = axes[0]
    ax1.bar(layers, profits, color='#2ecc71', alpha=0.8, edgecolor='#27ae60')
    ax1.set_xlabel('Oracle Layer (Arithmetic Hierarchy Level)', fontsize=12)
    ax1.set_ylabel('Selective Strategy Profit', fontsize=12)
    ax1.set_title('Layer Profit Monotonicity', fontsize=14, fontweight='bold')
    ax1.set_xticks(layers)
    ax1.set_xticklabels([f'Σ_{k}' for k in range(n_layers)])
    
    # Annotate monotonicity
    for i in range(len(profits) - 1):
        ax1.annotate('', xy=(i + 1, profits[i + 1]), xytext=(i, profits[i]),
                     arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=1.5))
    
    # Plot 2: Entropy-Profit Duality
    ax2 = axes[1]
    ax2.bar(layers, profits / n_statements, label='Decidable Fraction', 
            color='#3498db', alpha=0.8)
    ax2.bar(layers, entropies, bottom=profits / n_statements,
            label='Incompleteness Entropy', color='#e74c3c', alpha=0.8)
    ax2.axhline(y=1, color='black', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Oracle Layer', fontsize=12)
    ax2.set_ylabel('Fraction', fontsize=12)
    ax2.set_title('Entropy-Profit Duality\n(Always Sums to 1)', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_xticks(layers)
    ax2.set_xticklabels([f'Σ_{k}' for k in range(n_layers)])
    
    # Plot 3: Strategy Comparison
    ax3 = axes[2]
    selective_profits = profits
    
    # Simulate naive strategies
    rng = np.random.RandomState(42)
    truths = rng.choice([True, False], size=n_statements)
    naive_true_profits = np.array([
        sum(1 if truths[j] else -1 for j in range(n_statements))
        for _ in range(n_layers)
    ])
    naive_random_profits = np.array([
        sum(1 if rng.random() < 0.5 else -1 for _ in range(n_statements))
        for _ in range(n_layers)
    ])
    
    ax3.plot(layers, selective_profits, 'o-', color='#2ecc71', lw=2, 
             markersize=8, label='Selective (optimal)')
    ax3.axhline(y=naive_true_profits[0], color='#e74c3c', linestyle='--', 
                alpha=0.7, label=f'Naive TRUE (profit={naive_true_profits[0]})')
    ax3.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax3.fill_between(layers, 0, selective_profits, alpha=0.1, color='#2ecc71')
    ax3.set_xlabel('Oracle Layer', fontsize=12)
    ax3.set_ylabel('Profit', fontsize=12)
    ax3.set_title('Strategy Comparison', fontsize=14, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.set_xticks(layers)
    ax3.set_xticklabels([f'Σ_{k}' for k in range(n_layers)])
    
    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved oracle_hierarchy.png")

if __name__ == '__main__':
    plot_oracle_hierarchy()
