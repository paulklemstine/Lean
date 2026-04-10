#!/usr/bin/env python3
"""
Maslov Dequantization Demo
===========================

Visualizes how the Maslov deformation parameter ε continuously
interpolates between quantum (ε = 1) and tropical (ε → 0) computation.

The deformed addition: a ⊕_ε b = ε · log(exp(a/ε) + exp(b/ε))

As ε → 0⁺: ⊕_ε → max (tropical semiring)
At ε = 1:   ⊕_ε = LogSumExp (quantum/probabilistic)
As ε → ∞:   ⊕_ε → (a+b)/2 (average, maximum entropy)

Usage:
    python maslov_dequantization_demo.py
"""

import math

def maslov_add(eps, a, b):
    """Maslov deformed addition: ε · log(exp(a/ε) + exp(b/ε))"""
    if eps < 1e-15:
        return max(a, b)
    # Numerically stable computation
    m = max(a/eps, b/eps)
    return eps * (m + math.log(math.exp(a/eps - m) + math.exp(b/eps - m)))

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  MASLOV DEQUANTIZATION: Quantum → Classical Transition  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    a, b = 3.0, 7.0
    print(f"Input: a = {a}, b = {b}")
    print(f"max(a,b) = {max(a,b)} (tropical limit)")
    print(f"(a+b)/2  = {(a+b)/2} (averaging limit)")
    print()
    
    epsilons = [0.001, 0.01, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]
    
    print(f"{'ε':>8} {'a ⊕_ε b':>12} {'Gap from max':>14} {'Regime':>15}")
    print("-" * 55)
    
    for eps in epsilons:
        result = maslov_add(eps, a, b)
        gap = result - max(a, b)
        
        if eps <= 0.01:
            regime = "≈ tropical"
        elif eps <= 1.0:
            regime = "quantum"
        elif eps <= 10:
            regime = "hot quantum"
        else:
            regime = "≈ averaging"
        
        print(f"{eps:8.3f} {result:12.6f} {gap:14.6f} {regime:>15}")
    
    print()
    print("Phase diagram:")
    print()
    print("  ε → 0⁺                ε = 1               ε → ∞")
    print("  ├────────────────────┼───────────────────┤")
    print("  │     TROPICAL       │      QUANTUM      │   AVERAGING")
    print("  │  max(a,b) = 7      │  LSE(3,7) ≈ 7.02  │   (a+b)/2 = 5")
    print("  │  Deterministic     │  Probabilistic     │   Maximum Entropy")
    print("  │  Optimization      │  Bayesian          │   Ignorance")
    print("  └────────────────────┴───────────────────┘")
    print()
    
    # Show the deformation is continuous
    print("=" * 55)
    print("ASSOCIATIVITY CHECK: (a ⊕_ε b) ⊕_ε c = a ⊕_ε (b ⊕_ε c)")
    print("=" * 55)
    print()
    
    a, b, c = 2.0, 5.0, 3.0
    for eps in [0.1, 0.5, 1.0, 2.0]:
        lhs = maslov_add(eps, maslov_add(eps, a, b), c)
        rhs = maslov_add(eps, a, maslov_add(eps, b, c))
        print(f"  ε = {eps:4.1f}: LHS = {lhs:.8f}, RHS = {rhs:.8f}, "
              f"Δ = {abs(lhs-rhs):.2e} {'✓' if abs(lhs-rhs) < 1e-10 else '✗'}")
    
    print()
    print("Maslov addition is ALWAYS associative — at every temperature.")
    print("This means the deformation preserves the semiring structure:")
    print("  (ℝ, ⊕_ε, +) is a semiring for every ε > 0.")
    print()
    
    # Show connection to softmax
    print("=" * 55)
    print("CONNECTION TO SOFTMAX")
    print("=" * 55)
    print()
    print("The gradient of LogSumExp is softmax:")
    print("  ∂/∂xᵢ [ε·log Σ exp(xⱼ/ε)] = exp(xᵢ/ε) / Σ exp(xⱼ/ε)")
    print()
    print("As ε → 0: softmax → argmax (one-hot)")
    print("At ε = 1: softmax = standard attention weights")
    print("As ε → ∞: softmax → uniform (1/n, ..., 1/n)")
    print()
    print("This means: ATTENTION IS DEQUANTIZED ARGMAX!")
    print()

if __name__ == "__main__":
    main()
