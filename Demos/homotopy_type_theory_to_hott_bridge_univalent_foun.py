#!/usr/bin/env python3
"""
Proof Transfer Pipeline: Numerical Demonstrations

Demonstrates the key concepts from the proof transfer framework:
1. Predicate transfer across bijections
2. Relation property transfer
3. Proof compression analysis
4. Algebraic property transfer
"""

import math
from typing import Callable, TypeVar, Any

T = TypeVar('T')
U = TypeVar('U')


def demonstrate_predicate_transfer():
    """Show how predicates transfer across bijections."""
    print("=" * 60)
    print("DEMO 1: Predicate Transfer Across Bijections")
    print("=" * 60)
    
    # Bijection: integers mod 5 <-> {0,1,2,3,4}
    # e: ZZ/5 -> {0,...,4}  (identity on representatives)
    # e_inv: {0,...,4} -> ZZ/5
    
    A = list(range(5))  # {0,1,2,3,4} as ZZ/5
    B = ['a', 'b', 'c', 'd', 'e']  # arbitrary labels
    
    # Bijection
    e = dict(zip(A, B))  # 0->a, 1->b, ...
    e_inv = dict(zip(B, A))  # a->0, b->1, ...
    
    # Predicate on A: "is even"
    P = lambda x: x % 2 == 0
    
    # Transferred predicate on B: P(e_inv(b))
    P_transferred = lambda b: P(e_inv[b])
    
    print(f"\nOriginal set A = {A}")
    print(f"Target set B = {B}")
    print(f"Bijection e: {e}")
    print(f"\nPredicate P on A: 'is even'")
    print(f"  P(0)={P(0)}, P(1)={P(1)}, P(2)={P(2)}, P(3)={P(3)}, P(4)={P(4)}")
    
    print(f"\nTransferred predicate P' on B: P'(b) = P(e⁻¹(b))")
    for b in B:
        print(f"  P'({b}) = P(e⁻¹({b})) = P({e_inv[b]}) = {P_transferred(b)}")
    
    # Verify: universal statement transfers
    Q = lambda x: x < 10  # True for all elements of A
    Q_transferred = lambda b: Q(e_inv[b])
    
    all_A = all(Q(a) for a in A)
    all_B = all(Q_transferred(b) for b in B)
    print(f"\nUniversal transfer: ∀a∈A, Q(a) = {all_A}")
    print(f"                    ∀b∈B, Q'(b) = {all_B}")
    print(f"  Transfer preserves universal: {all_A == all_B} ✓")


def demonstrate_relation_transfer():
    """Show how equivalence relations transfer."""
    print("\n" + "=" * 60)
    print("DEMO 2: Equivalence Relation Transfer")
    print("=" * 60)
    
    # A = {0,...,5}, B = {'a','b','c','d','e','f'}
    A = list(range(6))
    B = list('abcdef')
    e = dict(zip(A, B))
    e_inv = dict(zip(B, A))
    
    # Equivalence relation on A: congruence mod 3
    R = lambda x, y: x % 3 == y % 3
    
    # Transferred relation on B
    R_transferred = lambda b1, b2: R(e_inv[b1], e_inv[b2])
    
    print(f"\nRelation R on A: congruence mod 3")
    print(f"  R(0,3)={R(0,3)}, R(1,4)={R(1,4)}, R(0,1)={R(0,1)}")
    
    # Check properties transfer
    print(f"\nReflexivity on A: ∀a, R(a,a) = {all(R(a,a) for a in A)}")
    print(f"Reflexivity on B: ∀b, R'(b,b) = {all(R_transferred(b,b) for b in B)}")
    
    sym_A = all(R(a1,a2) == R(a2,a1) for a1 in A for a2 in A)
    sym_B = all(R_transferred(b1,b2) == R_transferred(b2,b1) for b1 in B for b2 in B)
    print(f"Symmetry on A: {sym_A}")
    print(f"Symmetry on B: {sym_B}")
    
    # Check transitivity
    trans_A = all(
        not (R(a1,a2) and R(a2,a3)) or R(a1,a3)
        for a1 in A for a2 in A for a3 in A
    )
    trans_B = all(
        not (R_transferred(b1,b2) and R_transferred(b2,b3)) or R_transferred(b1,b3)
        for b1 in B for b2 in B for b3 in B
    )
    print(f"Transitivity on A: {trans_A}")
    print(f"Transitivity on B: {trans_B}")
    print(f"\nAll properties transferred correctly ✓")


def demonstrate_compression():
    """Demonstrate proof compression ratios."""
    print("\n" + "=" * 60)
    print("DEMO 3: Proof Compression Analysis")
    print("=" * 60)
    
    print("\nProof complexity model:")
    print("  Direct cost of k theorems, each complexity n: C_direct = n * k")
    print("  Transfer cost via equivalence of complexity m: C_transfer = m + k")
    print("  Compression ratio: ρ = (m + k) / (n * k)")
    
    print(f"\n{'k':>5} {'n':>5} {'m':>5} {'Direct':>10} {'Transfer':>10} {'Ratio':>10} {'Savings':>10}")
    print("-" * 65)
    
    for n in [5, 10, 20]:
        m = n  # equivalence has same complexity as typical proof
        for k in [3, 5, 10, 20, 50, 100]:
            direct = n * k
            transfer = m + k
            ratio = transfer / direct
            savings = 1 - ratio
            print(f"{k:>5} {n:>5} {m:>5} {direct:>10} {transfer:>10} {ratio:>10.3f} {savings:>9.1%}")
        print()
    
    print("Key insight: As k grows, ratio → 1/n (approaches 0 for large n)")
    print("The bound k ≥ 3 is tight: at m=n=k=2, ratio = 4/4 = 1.0 (no compression)")


def demonstrate_algebraic_transfer():
    """Show commutativity transferring across group isomorphism."""
    print("\n" + "=" * 60)
    print("DEMO 4: Algebraic Property Transfer")
    print("=" * 60)
    
    # Z/6 (additive, commutative) ≅ Z/2 × Z/3 (product)
    # Isomorphism: n ↦ (n mod 2, n mod 3)
    
    Z6 = list(range(6))
    Z2xZ3 = [(a, b) for a in range(2) for b in range(3)]
    
    # The isomorphism
    phi = {n: (n % 2, n % 3) for n in Z6}
    phi_inv = {v: k for k, v in phi.items()}
    
    print(f"\nIsomorphism φ: Z/6 → Z/2 × Z/3")
    for n in Z6:
        print(f"  φ({n}) = {phi[n]}")
    
    # Verify it's a group homomorphism
    print(f"\nHomomorphism check: φ(a+b) = φ(a) + φ(b)")
    all_homo = True
    for a in Z6:
        for b in Z6:
            lhs = phi[(a + b) % 6]
            rhs_a, rhs_b = phi[a], phi[b]
            rhs = ((rhs_a[0] + rhs_b[0]) % 2, (rhs_a[1] + rhs_b[1]) % 3)
            if lhs != rhs:
                all_homo = False
                print(f"  FAIL at a={a}, b={b}")
    print(f"  All checks passed: {all_homo} ✓")
    
    # Commutativity in Z/6
    comm_Z6 = all((a + b) % 6 == (b + a) % 6 for a in Z6 for b in Z6)
    print(f"\nCommutativity in Z/6: {comm_Z6}")
    
    # Transfer commutativity to Z/2 × Z/3
    def add_prod(x, y):
        return ((x[0] + y[0]) % 2, (x[1] + y[1]) % 3)
    
    comm_prod = all(
        add_prod(x, y) == add_prod(y, x)
        for x in Z2xZ3 for y in Z2xZ3
    )
    print(f"Commutativity in Z/2 × Z/3: {comm_prod}")
    print(f"Transferred correctly: {comm_Z6 == comm_prod} ✓")
    
    # Transfer proof via the pipeline
    print(f"\nTransfer proof:")
    print(f"  For any x, y in Z/2 × Z/3:")
    print(f"  x + y = φ(φ⁻¹(x) + φ⁻¹(y))     [homomorphism]")
    print(f"       = φ(φ⁻¹(y) + φ⁻¹(x))     [commutativity in Z/6]")
    print(f"       = y + x                      [homomorphism]")


def demonstrate_composition():
    """Show that transfer pipelines compose correctly."""
    print("\n" + "=" * 60)
    print("DEMO 5: Pipeline Composition (Functoriality)")
    print("=" * 60)
    
    A = [0, 1, 2]
    B = ['x', 'y', 'z']
    C = [10, 20, 30]
    
    e1 = dict(zip(A, B))
    e1_inv = dict(zip(B, A))
    e2 = dict(zip(B, C))
    e2_inv = dict(zip(C, B))
    
    # Composed equivalence
    e_comp = {a: e2[e1[a]] for a in A}
    e_comp_inv = {c: e1_inv[e2_inv[c]] for c in C}
    
    print(f"\ne₁: {A} → {B}: {e1}")
    print(f"e₂: {B} → {C}: {e2}")
    print(f"e₁∘e₂: {A} → {C}: {e_comp}")
    
    P = lambda a: a >= 1  # predicate on A
    
    # Transfer via composition
    P_via_comp = lambda c: P(e_comp_inv[c])
    
    # Transfer via pipeline (e₂ ∘ e₁)
    P_via_e1 = lambda b: P(e1_inv[b])
    P_via_pipeline = lambda c: P_via_e1(e2_inv[c])
    
    print(f"\nPredicate P on A: a ≥ 1")
    print(f"\nDirect transfer via composed equivalence:")
    for c in C:
        print(f"  P'({c}) = P(e_comp⁻¹({c})) = P({e_comp_inv[c]}) = {P_via_comp(c)}")
    
    print(f"\nPipeline transfer (e₂ after e₁):")
    for c in C:
        b = e2_inv[c]
        a = e1_inv[b]
        print(f"  P'({c}) = P(e₁⁻¹(e₂⁻¹({c}))) = P(e₁⁻¹({b})) = P({a}) = {P_via_pipeline(c)}")
    
    match = all(P_via_comp(c) == P_via_pipeline(c) for c in C)
    print(f"\nFunctoriality: both methods agree = {match} ✓")


if __name__ == "__main__":
    demonstrate_predicate_transfer()
    demonstrate_relation_transfer()
    demonstrate_compression()
    demonstrate_algebraic_transfer()
    demonstrate_composition()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Proof Compression Ratios

Plots the compression ratio (transfer cost / direct cost) as a function
of the number of theorems transferred, for various proof complexities.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def transfer_cost(m: int, k: int) -> int:
    """Cost of transferring k theorems through equivalence of complexity m."""
    return m + k


def direct_cost(n: int, k: int) -> int:
    """Cost of directly proving k theorems each of complexity n."""
    return n * k


def compression_ratio(m: int, n: int, k: int) -> float:
    """Ratio of transfer cost to direct cost."""
    if n * k == 0:
        return float('inf')
    return (m + k) / (n * k)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Compression ratio vs k for different n
    ax1 = axes[0]
    k_vals = np.arange(1, 101)
    for n in [2, 5, 10, 20]:
        m = n  # equiv complexity = proof complexity
        ratios = [compression_ratio(m, n, k) for k in k_vals]
        ax1.plot(k_vals, ratios, label=f'n = {n}', linewidth=2)
    
    ax1.set_xlabel('Number of theorems (k)', fontsize=12)
    ax1.set_ylabel('Compression ratio ρ', fontsize=12)
    ax1.set_title('Compression Ratio vs Theorem Count', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax1.set_ylim(0, 1.5)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Break-even line', xy=(80, 1.02), fontsize=9, color='gray')
    
    # Plot 2: Total cost comparison
    ax2 = axes[1]
    n = 10
    m = 10
    k_vals_2 = np.arange(1, 51)
    direct_costs = [direct_cost(n, k) for k in k_vals_2]
    transfer_costs = [transfer_cost(m, k) for k in k_vals_2]
    
    ax2.plot(k_vals_2, direct_costs, 'r-', label='Direct (n·k)', linewidth=2)
    ax2.plot(k_vals_2, transfer_costs, 'b-', label='Transfer (m+k)', linewidth=2)
    ax2.fill_between(k_vals_2, transfer_costs, direct_costs,
                      alpha=0.2, color='green', label='Savings')
    
    ax2.set_xlabel('Number of theorems (k)', fontsize=12)
    ax2.set_ylabel('Total proof cost', fontsize=12)
    ax2.set_title(f'Cost Comparison (n={n}, m={m})', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Asymptotic compression ratio
    ax3 = axes[2]
    n_vals = np.arange(2, 51)
    asymptotic_ratios = [1/n for n in n_vals]
    threshold_k = [n + 1 for n in n_vals]  # k threshold for m=n
    
    ax3.bar(n_vals, asymptotic_ratios, color='steelblue', alpha=0.7, width=0.8)
    ax3.set_xlabel('Proof complexity (n)', fontsize=12)
    ax3.set_ylabel('Asymptotic ratio (1/n)', fontsize=12)
    ax3.set_title('Asymptotic Compression Ratio', fontsize=13)
    ax3.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('compression_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved compression_analysis.png")


if __name__ == "__main__":
    main()
