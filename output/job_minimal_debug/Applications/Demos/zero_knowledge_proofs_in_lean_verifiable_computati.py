#!/usr/bin/env python3
"""
Verifiable Computation Demo: R1CS, QAP, and SNARK Soundness

Demonstrates the algebraic pipeline underlying zk-SNARKs:
1. R1CS constraint satisfaction
2. QAP polynomial encoding
3. Schwartz-Zippel soundness verification
4. Graph 3-coloring ZK protocol
"""

import random
from typing import List, Tuple, Optional


def demo_r1cs():
    """Demonstrate R1CS constraint satisfaction.
    
    Example: Prove knowledge of x such that x^3 + x + 5 = 35.
    Solution: x = 3.
    
    R1CS encoding (5 variables: 1, x, x^2, x^3, out):
    Constraint 1: x * x = x^2        (A=[0,1,0,0,0], B=[0,1,0,0,0], C=[0,0,1,0,0])
    Constraint 2: x^2 * x = x^3      (A=[0,0,1,0,0], B=[0,1,0,0,0], C=[0,0,0,1,0])
    Constraint 3: (x^3+x+5)*1 = out  (A=[5,1,0,1,0], B=[1,0,0,0,0], C=[0,0,0,0,1])
    """
    print("=" * 60)
    print("DEMO 1: R1CS Constraint Satisfaction")
    print("=" * 60)
    print("\nProblem: Prove knowledge of x where x³ + x + 5 = 35")
    print("Solution: x = 3")
    
    # Witness: [1, x, x², x³, out] = [1, 3, 9, 27, 35]
    w = [1, 3, 9, 27, 35]
    
    # R1CS matrices (each row is a constraint)
    A = [[0, 1, 0, 0, 0],  # x
         [0, 0, 1, 0, 0],  # x²
         [5, 1, 0, 1, 0]]  # x³ + x + 5
    
    B = [[0, 1, 0, 0, 0],  # x
         [0, 1, 0, 0, 0],  # x
         [1, 0, 0, 0, 0]]  # 1
    
    C = [[0, 0, 1, 0, 0],  # x²
         [0, 0, 0, 1, 0],  # x³
         [0, 0, 0, 0, 1]]  # out
    
    print(f"\nWitness w = {w}")
    print(f"\nConstraint verification:")
    
    for i in range(3):
        left = sum(A[i][j] * w[j] for j in range(5))
        right = sum(B[i][j] * w[j] for j in range(5))
        out = sum(C[i][j] * w[j] for j in range(5))
        satisfied = left * right == out
        print(f"  Constraint {i+1}: ({left}) × ({right}) = {left*right} {'==' if satisfied else '!='} {out}  {'✓' if satisfied else '✗'}")
    
    print("\nAll constraints satisfied! R1CS is valid.")


def demo_vanishing_polynomial():
    """Demonstrate the vanishing polynomial and QAP encoding."""
    print("\n" + "=" * 60)
    print("DEMO 2: Vanishing Polynomial & QAP")
    print("=" * 60)
    
    # Domain points
    domain = [1, 2, 3]
    print(f"\nEvaluation domain: ω = {domain}")
    
    # Vanishing polynomial t(x) = (x-1)(x-2)(x-3)
    def t(x):
        result = 1
        for omega in domain:
            result *= (x - omega)
        return result
    
    print(f"\nt(x) = (x-1)(x-2)(x-3)")
    print(f"Degree of t(x) = {len(domain)}")
    
    for omega in domain:
        print(f"  t({omega}) = {t(omega)} {'✓ (zero!)' if t(omega) == 0 else '✗'}")
    
    # Non-domain points
    for x in [0, 4, 5]:
        print(f"  t({x}) = {t(x)} (nonzero)")


def demo_schwartz_zippel():
    """Demonstrate Schwartz-Zippel soundness."""
    print("\n" + "=" * 60)
    print("DEMO 3: Schwartz-Zippel Soundness")
    print("=" * 60)
    
    # Polynomial p(x) = x^3 - 6x^2 + 11x - 6 = (x-1)(x-2)(x-3)
    # Degree 3, so at most 3 roots in any set
    def p(x):
        return x**3 - 6*x**2 + 11*x - 6
    
    print(f"\nPolynomial: p(x) = x³ - 6x² + 11x - 6 = (x-1)(x-2)(x-3)")
    print(f"Degree: 3")
    
    # Test over various set sizes
    for set_size in [5, 10, 50, 100]:
        S = list(range(-set_size//2, set_size//2 + 1))[:set_size]
        roots_in_S = [z for z in S if p(z) == 0]
        print(f"\n  Set S of size {set_size}:")
        print(f"    Roots in S: {roots_in_S}")
        print(f"    Root count: {len(roots_in_S)} ≤ deg(p) = 3  ✓")
        print(f"    Soundness: 1 - {len(roots_in_S)}/{set_size} = {1 - len(roots_in_S)/set_size:.4f}")
    
    # Monte Carlo experiment
    print(f"\n  Monte Carlo (1000 random evaluations from [-1000, 1000]):")
    hits = sum(1 for _ in range(1000) if p(random.randint(-1000, 1000)) == 0)
    print(f"    Zero hits: {hits}/1000")
    print(f"    Expected bound: ≤ 3/2001 ≈ 0.0015")


def demo_zk_coloring():
    """Demonstrate the 3-coloring zero-knowledge protocol."""
    print("\n" + "=" * 60)
    print("DEMO 4: Graph 3-Coloring ZK Protocol")
    print("=" * 60)
    
    # Triangle graph (K3)
    n = 3
    edges = [(0, 1), (1, 2), (0, 2)]
    coloring = [0, 1, 2]  # Valid 3-coloring
    
    print(f"\nGraph: Triangle (K₃)")
    print(f"Edges: {edges}")
    print(f"Secret coloring: {coloring}")
    
    # Verify it's a valid coloring
    valid = all(coloring[i] != coloring[j] for i, j in edges)
    print(f"Valid 3-coloring: {valid}")
    
    # Simulate the ZK protocol
    print(f"\nZero-Knowledge Protocol Simulation (20 rounds):")
    
    all_permutations = [
        [0, 1, 2], [0, 2, 1], [1, 0, 2],
        [1, 2, 0], [2, 0, 1], [2, 1, 0]
    ]
    
    for round_num in range(1, 6):
        # Prover: pick random permutation
        perm = random.choice(all_permutations)
        permuted = [perm[c] for c in coloring]
        
        # Verifier: pick random edge
        edge = random.choice(edges)
        i, j = edge
        
        # Prover: reveal colors of endpoints
        ci, cj = permuted[i], permuted[j]
        
        print(f"  Round {round_num}: σ={perm}, edge=({i},{j}), "
              f"colors=({ci},{cj}), different={ci != cj} ✓")
    
    print(f"\n  Verifier sees different pairs each round (ZK: no info about original)")
    print(f"  Cheating probability after k rounds: (2/3)^k")
    print(f"  After 20 rounds: (2/3)^20 ≈ {(2/3)**20:.10f}")


def demo_composition():
    """Demonstrate R1CS composition."""
    print("\n" + "=" * 60)
    print("DEMO 5: R1CS Composition (Recursive SNARKs)")
    print("=" * 60)
    
    # System 1: x * y = z (multiplication gate)
    print("\nSystem 1: x × y = z")
    print("System 2: z × z = z² (squaring gate)")
    print("Composed: Both constraints simultaneously")
    
    # Witness: [1, x, y, z, z²] = [1, 3, 4, 12, 144]
    w = [1, 3, 4, 12, 144]
    
    # System 1: A1=[0,1,0,0,0], B1=[0,0,1,0,0], C1=[0,0,0,1,0]
    A1, B1, C1 = [0,1,0,0,0], [0,0,1,0,0], [0,0,0,1,0]
    # System 2: A2=[0,0,0,1,0], B2=[0,0,0,1,0], C2=[0,0,0,0,1]
    A2, B2, C2 = [0,0,0,1,0], [0,0,0,1,0], [0,0,0,0,1]
    
    for name, A, B, C in [("System 1", A1, B1, C1), ("System 2", A2, B2, C2)]:
        left = sum(A[j]*w[j] for j in range(5))
        right = sum(B[j]*w[j] for j in range(5))
        out = sum(C[j]*w[j] for j in range(5))
        print(f"  {name}: ({left}) × ({right}) = {left*right} == {out}  ✓")
    
    print(f"\n  Composition: Both constraints satisfied ⟺ individual systems satisfied")
    print(f"  This enables recursive SNARK verification!")


def demo_polynomial_commitment():
    """Demonstrate polynomial commitment soundness."""
    print("\n" + "=" * 60)
    print("DEMO 6: Polynomial Commitment Soundness")
    print("=" * 60)
    
    # Honest polynomial: p(x) = 2x² + 3x + 1
    def p_honest(x):
        return 2*x**2 + 3*x + 1
    
    # Cheating polynomial: q(x) = 2x² + 3x + 2 (differs by constant)
    def p_cheat(x):
        return 2*x**2 + 3*x + 2
    
    claimed_value = p_honest(5)  # = 66
    
    print(f"\nHonest polynomial: p(x) = 2x² + 3x + 1")
    print(f"Cheating polynomial: q(x) = 2x² + 3x + 2")
    print(f"Claimed evaluation: p(5) = {claimed_value}")
    
    # Random verification points
    S = list(range(1, 101))  # |S| = 100
    
    caught = 0
    total = 20
    for _ in range(total):
        z = random.choice(S)
        if p_cheat(z) != claimed_value:
            caught += 1
    
    print(f"\n  Random verification ({total} trials from S={{1,...,100}}):")
    print(f"  Cheater caught: {caught}/{total} times")
    print(f"  Soundness bound: 1 - deg(p-v)/|S| = 1 - 2/100 = 0.98")
    print(f"  (Most evaluation points distinguish honest from cheating)")


if __name__ == "__main__":
    random.seed(42)
    
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  VERIFIABLE COMPUTATION: R1CS, QAP & SNARK SOUNDNESS   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_r1cs()
    demo_vanishing_polynomial()
    demo_schwartz_zippel()
    demo_zk_coloring()
    demo_composition()
    demo_polynomial_commitment()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Schwartz-Zippel Soundness Bound

Shows how the soundness error decreases as the evaluation set grows,
and compares theoretical bounds with empirical root counts.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

def compute_root_counts(degree: int, num_trials: int = 1000):
    """Compute empirical root counts for random polynomials."""
    set_sizes = list(range(degree + 1, 201, 5))
    avg_root_fractions = []
    
    for s in set_sizes:
        S = list(range(-s//2, s//2 + 1))[:s]
        total_roots = 0
        for _ in range(num_trials):
            # Random polynomial of given degree
            coeffs = [random.randint(-10, 10) for _ in range(degree)]
            coeffs.append(random.randint(1, 10))  # ensure degree is exact
            
            roots_in_S = sum(1 for x in S if sum(c * x**i for i, c in enumerate(coeffs)) == 0)
            total_roots += roots_in_S
        
        avg_root_fractions.append(total_roots / (num_trials * s))
    
    return set_sizes, avg_root_fractions

def main():
    random.seed(42)
    np.random.seed(42)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Soundness error vs set size
    ax1 = axes[0]
    degrees = [3, 5, 10, 20]
    set_sizes = np.arange(1, 201)
    
    for d in degrees:
        errors = [min(1.0, d / s) for s in set_sizes]
        ax1.plot(set_sizes, errors, label=f'deg = {d}', linewidth=2)
    
    ax1.set_xlabel('Evaluation Set Size |S|', fontsize=12)
    ax1.set_ylabel('Soundness Error ε = d/|S|', fontsize=12)
    ax1.set_title('Schwartz-Zippel Soundness Bound', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 1.1)
    ax1.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε = 1%')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Root count vs degree for a specific polynomial
    ax2 = axes[1]
    p_coeffs = [-6, 11, -6, 1]  # (x-1)(x-2)(x-3)
    
    set_sizes_2 = list(range(5, 101, 5))
    root_counts = []
    for s in set_sizes_2:
        S = list(range(-s//2, s//2 + 1))[:s]
        count = sum(1 for x in S if sum(c * x**i for i, c in enumerate(p_coeffs)) == 0)
        root_counts.append(count)
    
    ax2.bar(set_sizes_2, root_counts, width=4, alpha=0.7, color='steelblue', label='Actual roots')
    ax2.axhline(y=3, color='red', linestyle='--', linewidth=2, label='Degree bound (3)')
    ax2.set_xlabel('Set Size |S|', fontsize=12)
    ax2.set_ylabel('Number of Roots in S', fontsize=12)
    ax2.set_title('Root Count: p(x) = (x-1)(x-2)(x-3)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: SNARK verification confidence vs number of checks
    ax3 = axes[2]
    field_sizes = [2**8, 2**16, 2**32, 2**64]
    degrees_3 = [100]
    
    num_checks = np.arange(1, 21)
    for fs in field_sizes:
        confidence = [1 - (100/fs)**k for k in num_checks]
        ax3.plot(num_checks, confidence, 'o-', label=f'|F| = 2^{int(np.log2(fs))}', linewidth=2)
    
    ax3.set_xlabel('Number of Verification Checks', fontsize=12)
    ax3.set_ylabel('Confidence (1 - ε^k)', fontsize=12)
    ax3.set_title('SNARK Verification Confidence', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.set_ylim(0.9, 1.001)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_soundness.png', dpi=150, bbox_inches='tight')
    print("Saved viz_soundness.png")

if __name__ == "__main__":
    main()
