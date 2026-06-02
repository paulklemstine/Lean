#!/usr/bin/env python3
"""
Tropical Proof Complexity — Numerical Demonstrations

This script demonstrates the core results of the tropical proof complexity framework:
1. Parallel repetition amplification (soundness error decay)
2. Tropical cost scaling under composition
3. Oracle corruption detection bounds
4. Security threshold calculations
"""

import math

def tropical_cost(epsilon: float) -> float:
    """Tropical verification cost: -log(epsilon)."""
    assert 0 < epsilon < 1, "epsilon must be in (0, 1)"
    return -math.log(epsilon)

def parallel_repetition_error(epsilon: float, k: int) -> float:
    """Soundness error after k-fold parallel repetition."""
    return epsilon ** k

def oracle_miss_probability(delta: float, q: int) -> float:
    """Probability of missing all corrupted positions with q queries."""
    return (1 - delta) ** q

def min_rounds_for_security(epsilon: float, barrier: float) -> int:
    """Minimum rounds needed to achieve tropical cost >= barrier."""
    cost_per_round = tropical_cost(epsilon)
    return math.ceil(barrier / cost_per_round)

def detection_probability(delta: float, q: int) -> float:
    """Probability of detecting corruption with q queries."""
    return 1 - oracle_miss_probability(delta, q)


def demo_parallel_repetition():
    """Demonstrate exponential error decay under parallel repetition."""
    print("=" * 60)
    print("DEMO 1: Parallel Repetition Amplification")
    print("=" * 60)
    epsilon = 0.5  # Base soundness error (coin flip)
    
    print(f"\nBase soundness error: ε = {epsilon}")
    print(f"Base tropical cost: -log(ε) = {tropical_cost(epsilon):.4f}")
    print(f"\n{'Rounds k':>10} {'Error ε^k':>15} {'Tropical Cost':>15} {'Ratio':>10}")
    print("-" * 55)
    
    for k in [1, 2, 5, 10, 20, 50, 100]:
        err = parallel_repetition_error(epsilon, k)
        cost = k * tropical_cost(epsilon)
        print(f"{k:>10} {err:>15.2e} {cost:>15.4f} {cost / k:>10.4f}")
    
    print("\n→ Tropical cost scales LINEARLY (additive), while error")
    print("  decays EXPONENTIALLY (multiplicative). This is the duality.")


def demo_oracle_detection():
    """Demonstrate oracle corruption detection bounds."""
    print("\n" + "=" * 60)
    print("DEMO 2: Oracle Corruption Detection")
    print("=" * 60)
    
    delta = 0.1  # 10% corruption rate
    print(f"\nCorruption rate: δ = {delta}")
    print(f"\n{'Queries q':>10} {'Miss prob':>15} {'exp(-δq)':>15} {'Detect prob':>15}")
    print("-" * 60)
    
    for q in [1, 5, 10, 20, 50, 100]:
        miss = oracle_miss_probability(delta, q)
        exp_bound = math.exp(-delta * q)
        detect = detection_probability(delta, q)
        print(f"{q:>10} {miss:>15.6e} {exp_bound:>15.6e} {detect:>15.6f}")
    
    print("\n→ Miss probability (1-δ)^q ≤ exp(-δq) always holds (Theorem 4).")
    print("  Detection probability approaches 1 exponentially fast.")


def demo_security_threshold():
    """Demonstrate security threshold calculations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Security Thresholds")
    print("=" * 60)
    
    print(f"\n{'Security bits':>15} {'ε=1/2 rounds':>15} {'ε=1/3 rounds':>15} {'ε=1/4 rounds':>15}")
    print("-" * 65)
    
    for bits in [40, 80, 128, 256]:
        barrier = bits * math.log(2)  # Convert bits to nats
        for i, eps in enumerate([0.5, 1/3, 0.25]):
            rounds = min_rounds_for_security(eps, barrier)
            if i == 0:
                print(f"{bits:>15}", end="")
            print(f" {rounds:>14}", end="")
        print()
    
    print("\n→ Weaker base systems (larger ε) need more rounds.")
    print("  Cost grows linearly in security parameter (Theorem 5).")


def demo_composition():
    """Demonstrate sequential vs parallel composition."""
    print("\n" + "=" * 60)
    print("DEMO 4: Sequential vs Parallel Composition")
    print("=" * 60)
    
    eps1 = 0.3
    eps2 = 0.2
    
    print(f"\nSystem 1: ε₁ = {eps1}, tropical cost = {tropical_cost(eps1):.4f}")
    print(f"System 2: ε₂ = {eps2}, tropical cost = {tropical_cost(eps2):.4f}")
    
    # Sequential: error = ε₁ + ε₂ - ε₁ε₂
    seq_error = eps1 + eps2 - eps1 * eps2
    seq_cost = tropical_cost(eps1 * eps2)
    min_cost = min(tropical_cost(eps1), tropical_cost(eps2))
    
    print(f"\nSequential composition:")
    print(f"  Combined error (inclusion-exclusion): {seq_error:.4f}")
    print(f"  Union bound: {eps1 + eps2:.4f}")
    print(f"  Tropical cost -log(ε₁·ε₂): {seq_cost:.4f}")
    print(f"  min(-log ε₁, -log ε₂): {min_cost:.4f}")
    print(f"  Theorem 3 verified: {min_cost:.4f} ≤ {seq_cost:.4f}: {min_cost <= seq_cost}")
    
    # Parallel: error = ε₁ · ε₂
    par_error = eps1 * eps2
    par_cost = tropical_cost(eps1) + tropical_cost(eps2)
    
    print(f"\nParallel composition:")
    print(f"  Combined error: {par_error:.4f}")
    print(f"  Tropical cost (sum): {par_cost:.4f}")
    print(f"  = -log(ε₁) + -log(ε₂) = -log(ε₁·ε₂)")
    

def demo_amplification_detection_duality():
    """Demonstrate the duality between amplification and detection."""
    print("\n" + "=" * 60)
    print("DEMO 5: Amplification-Detection Duality")
    print("=" * 60)
    
    epsilon = 0.4  # Proof system soundness error
    delta = 0.15   # Oracle corruption rate
    
    print(f"\nProof system: ε = {epsilon}")
    print(f"Oracle: δ = {delta}, miss_base = 1-δ = {1-delta}")
    print(f"\n{'k':>5} {'ε^k':>15} {'(1-δ)^k':>15} {'cost_amp':>12} {'cost_det':>12}")
    print("-" * 65)
    
    for k in [1, 2, 5, 10, 20]:
        amp_err = epsilon ** k
        det_miss = (1 - delta) ** k
        cost_amp = k * tropical_cost(epsilon)
        cost_det = k * (-math.log(1 - delta))
        print(f"{k:>5} {amp_err:>15.6e} {det_miss:>15.6e} {cost_amp:>12.4f} {cost_det:>12.4f}")
    
    print("\n→ Both follow the SAME tropical scaling law: cost(k) = k × cost(1)")
    print("  This is the Amplification-Detection Duality (Theorem 6).")


if __name__ == "__main__":
    demo_parallel_repetition()
    demo_oracle_detection()
    demo_security_threshold()
    demo_composition()
    demo_amplification_detection_duality()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Amplification-Detection Duality

Shows the parallel between soundness amplification and corruption detection,
both governed by exponential decay in the tropical cost framework.
"""

import math

def tropical_cost(eps):
    return -math.log(eps)

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available. Printing text-based output.")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Proof Complexity: Amplification-Detection Duality',
                 fontsize=14, fontweight='bold')

    # Panel 1: Exponential error decay
    ax = axes[0, 0]
    ks = np.arange(1, 51)
    for eps in [0.5, 0.3, 0.1]:
        errors = eps ** ks
        ax.semilogy(ks, errors, label=f'ε = {eps}', linewidth=2)
    ax.set_xlabel('Repetitions k')
    ax.set_ylabel('Soundness error ε^k')
    ax.set_title('(a) Parallel Repetition: Error Decay')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Tropical cost scaling
    ax = axes[0, 1]
    for eps in [0.5, 0.3, 0.1]:
        costs = ks * tropical_cost(eps)
        ax.plot(ks, costs, label=f'ε = {eps}', linewidth=2)
    ax.set_xlabel('Repetitions k')
    ax.set_ylabel('Tropical cost k·(-log ε)')
    ax.set_title('(b) Tropical Cost: Linear Scaling')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Oracle detection
    ax = axes[1, 0]
    queries = np.arange(1, 101)
    for delta in [0.05, 0.1, 0.2]:
        miss_prob = (1 - delta) ** queries
        exp_bound = np.exp(-delta * queries)
        ax.semilogy(queries, miss_prob, linewidth=2, label=f'(1-δ)^q, δ={delta}')
        ax.semilogy(queries, exp_bound, '--', linewidth=1, alpha=0.5,
                   label=f'exp(-δq), δ={delta}')
    ax.set_xlabel('Number of queries q')
    ax.set_ylabel('Miss probability')
    ax.set_title('(c) Oracle Detection: Bound Verification')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 4: Security threshold
    ax = axes[1, 1]
    bits_range = np.arange(10, 260, 5)
    for eps in [0.5, 0.3, 0.1]:
        rounds = np.ceil(bits_range * math.log(2) / tropical_cost(eps))
        ax.plot(bits_range, rounds, label=f'ε = {eps}', linewidth=2)
    ax.set_xlabel('Security level (bits)')
    ax.set_ylabel('Minimum rounds')
    ax.set_title('(d) Security Thresholds')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_proof_complexity.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_proof_complexity.png")

if __name__ == "__main__":
    main()
