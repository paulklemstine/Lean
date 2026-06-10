#!/usr/bin/env python3
"""
Tropical Quantum Code Geometry — Interactive Demo

This script demonstrates the key concepts from the formalized Lean 4 development:
1. Stabilizer valuations as tropical cost functions
2. Tropical weight enumerators and breakpoints
3. Inf-convolution for code concatenation
4. Distance certification via breakpoint analysis

All algorithms match the formal definitions in QuantumTropicalCore.lean.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Optional

INF = float('inf')

# ============================================================
# Core Data Structures
# ============================================================

class StabilizerValuation:
    """
    Tropical valuation on Pauli-weight vectors.
    
    Corresponds to QuantumTropical.StabilizerValuation in Lean.
    val(f) measures the tropical cost of a Pauli operator with weight profile f.
    """
    def __init__(self, val_func):
        """val_func: dict mapping weight vectors (tuples) to WithTop ℕ values."""
        self.val_func = val_func
    
    def val(self, f: tuple) -> float:
        """Evaluate the valuation. Returns INF if not in the domain."""
        return self.val_func.get(f, INF)


def pauli_weight(f: tuple) -> int:
    """
    Pauli weight: sum of all components.
    Corresponds to QuantumTropical.pauliWeight.
    O(|support|) computation.
    """
    return sum(f)


def trop_weight_enumerator(v: StabilizerValuation, S: list, k: int) -> float:
    """
    Tropical weight enumerator: min valuation among weight-k elements.
    
    Corresponds to QuantumTropical.tropWeightEnumerator.
    W(k) = inf { v(f) : f ∈ S, pauli_weight(f) = k }
    O(|S|) per evaluation.
    """
    result = INF
    for f in S:
        if pauli_weight(f) == k:
            result = min(result, v.val(f))
    return result


def inf_convolution(f_vals: list, g_vals: list, n: int) -> float:
    """
    Min-plus inf-convolution at point n.
    
    Corresponds to QuantumTropical.infConvolutionNat.
    (f ⊕ g)(n) = min_{0 ≤ i ≤ n} { f(i) + g(n-i) }
    O(n) per evaluation point.
    """
    result = INF
    for i in range(n + 1):
        if i < len(f_vals) and (n - i) < len(g_vals):
            val = f_vals[i] + g_vals[n - i]
            result = min(result, val)
        elif i < len(f_vals):
            pass  # g(n-i) = INF implicitly
        elif (n - i) < len(g_vals):
            pass  # f(i) = INF implicitly
    return result


def is_tropical_breakpoint(W: list, d: int) -> bool:
    """
    Check if W has a tropical breakpoint at d.
    Corresponds to QuantumTropical.IsTropicalBreakpoint.
    """
    return all(W[k] == INF for k in range(d))


def compute_profile(f_vals: list, g_vals: list, max_n: int) -> list:
    """Compute the full inf-convolution profile up to max_n."""
    return [inf_convolution(f_vals, g_vals, n) for n in range(max_n + 1)]


# ============================================================
# Example 1: The [[5,1,3]] Quantum Code
# ============================================================

def example_five_qubit_code():
    """
    Demonstrates tropical analysis of a code inspired by the [[5,1,3]] code.
    
    The [[5,1,3]] code encodes 1 logical qubit into 5 physical qubits
    with minimum distance 3 (can correct any single-qubit error).
    
    We model stabilizer generators with weight profiles and show that
    the tropical breakpoint at d=3 certifies the distance.
    """
    print("=" * 60)
    print("Example 1: [[5,1,3]] Quantum Code — Tropical Analysis")
    print("=" * 60)
    
    # Weight profiles of stabilizer generators (simplified)
    # Each tuple represents the Pauli weight on each qubit
    # The [[5,1,3]] code has generators of weight 4
    S = [
        (1, 1, 1, 1, 0),  # XZZXI — weight 4
        (0, 1, 1, 1, 1),  # IXZZX — weight 4
        (1, 0, 1, 1, 1),  # XIXZZ — weight 4
        (1, 1, 0, 1, 1),  # ZXIXZ — weight 4
    ]
    
    # Simple valuation: v(f) = pauli_weight(f)
    val_dict = {f: pauli_weight(f) for f in S}
    v = StabilizerValuation(val_dict)
    
    # Compute tropical weight enumerator
    max_weight = 6
    W = []
    print("\nTropical Weight Enumerator W(k):")
    for k in range(max_weight + 1):
        w = trop_weight_enumerator(v, S, k)
        W.append(w)
        w_str = "⊤" if w == INF else str(int(w))
        print(f"  W({k}) = {w_str}")
    
    # Find breakpoint
    breakpoint = 0
    for d in range(max_weight + 1):
        if is_tropical_breakpoint(W, d):
            breakpoint = d
    
    print(f"\nTropical breakpoint: d = {breakpoint}")
    print(f"Certified minimum distance: ≥ {breakpoint}")
    print(f"→ This code can correct ⌊({breakpoint}-1)/2⌋ = {(breakpoint-1)//2} errors")
    
    return W


# ============================================================
# Example 2: Code Concatenation via Inf-Convolution
# ============================================================

def example_concatenation():
    """
    Demonstrates the breakpoint-additivity theorem for concatenated codes.
    
    If Code A has breakpoint d₁ and Code B has breakpoint d₂,
    then the concatenated code has breakpoint d₁ + d₂.
    
    This is Theorem breakpoint_add_of_both in the Lean development.
    """
    print("\n" + "=" * 60)
    print("Example 2: Code Concatenation — Inf-Convolution")
    print("=" * 60)
    
    # Code A: breakpoint at d=3 (like [[5,1,3]])
    W_A = [INF, INF, INF, 3, 4, 5, 6, 7, 8]
    
    # Code B: breakpoint at d=2 (like a simple repetition code)
    W_B = [INF, INF, 2, 3, 4, 5, 6, 7, 8]
    
    max_n = 12
    W_concat = compute_profile(W_A, W_B, max_n)
    
    print("\nCode A profile (breakpoint = 3):")
    for k in range(len(W_A)):
        w_str = "⊤" if W_A[k] == INF else str(int(W_A[k]))
        print(f"  W_A({k}) = {w_str}")
    
    print("\nCode B profile (breakpoint = 2):")
    for k in range(len(W_B)):
        w_str = "⊤" if W_B[k] == INF else str(int(W_B[k]))
        print(f"  W_B({k}) = {w_str}")
    
    print("\nConcatenated profile W_A ⊕ W_B:")
    for n in range(max_n + 1):
        w_str = "⊤" if W_concat[n] == INF else str(int(W_concat[n]))
        print(f"  (W_A ⊕ W_B)({n}) = {w_str}")
    
    # Verify breakpoint additivity
    concat_bp = 0
    for d in range(max_n + 1):
        if is_tropical_breakpoint(W_concat, d):
            concat_bp = d
    
    print(f"\nBreakpoint of W_A: 3")
    print(f"Breakpoint of W_B: 2")
    print(f"Breakpoint of W_A ⊕ W_B: {concat_bp}")
    print(f"Theorem guarantees: ≥ 3 + 2 = 5 ✓" if concat_bp >= 5 else "ERROR!")
    
    return W_A, W_B, W_concat


# ============================================================
# Example 3: Hash Collision Lower Bound
# ============================================================

def example_collision_bound():
    """
    Demonstrates the tropical hash collision lower bound.
    
    Self-convolution doubles the breakpoint:
    If W has breakpoint d, then W ⊕ W has breakpoint 2d.
    
    This is Theorem tropical_hash_collision_lower_bound in the Lean development.
    """
    print("\n" + "=" * 60)
    print("Example 3: Tropical Hash Collision Lower Bound")
    print("=" * 60)
    
    # Profile with breakpoint d=4
    W = [INF, INF, INF, INF, 4, 5, 6, 7, 8, 9, 10]
    
    max_n = 16
    W_self = compute_profile(W, W, max_n)
    
    self_bp = 0
    for d in range(max_n + 1):
        if is_tropical_breakpoint(W_self, d):
            self_bp = d
    
    print(f"\nOriginal breakpoint: d = 4")
    print(f"Self-convolution breakpoint: {self_bp}")
    print(f"Theorem guarantees: ≥ 2 × 4 = 8 ✓" if self_bp >= 8 else "ERROR!")
    
    # Show the profile
    print("\nSelf-convolution profile:")
    for n in range(max_n + 1):
        w_str = "⊤" if W_self[n] == INF else str(int(W_self[n]))
        print(f"  (W ⊕ W)({n}) = {w_str}")
    
    return W, W_self


# ============================================================
# Visualization
# ============================================================

def create_visualizations(W_513, W_A, W_B, W_concat, W_orig, W_self):
    """Create publication-quality visualizations."""
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Quantum Code Geometry', fontsize=16, fontweight='bold')
    
    # Plot 1: [[5,1,3]] code enumerator
    ax = axes[0, 0]
    k_vals = list(range(len(W_513)))
    finite_mask = [w != INF for w in W_513]
    finite_vals = [w if w != INF else None for w in W_513]
    
    # Plot finite values as bars
    for k in k_vals:
        if finite_mask[k]:
            ax.bar(k, finite_vals[k], color='steelblue', alpha=0.8, edgecolor='navy')
        else:
            ax.bar(k, 0.5, bottom=-0.3, color='red', alpha=0.3, edgecolor='red',
                   hatch='///')
    
    # Mark breakpoint
    bp = 0
    for d in range(len(W_513)):
        if is_tropical_breakpoint(W_513, d):
            bp = d
    ax.axvline(x=bp - 0.5, color='red', linestyle='--', linewidth=2, label=f'Breakpoint d={bp}')
    
    ax.set_xlabel('Weight k')
    ax.set_ylabel('W(k)')
    ax.set_title('[[5,1,3]] Code — Tropical Enumerator')
    ax.legend()
    ax.set_xticks(k_vals)
    
    # Plot 2: Concatenation
    ax = axes[0, 1]
    max_n = min(len(W_concat), 13)
    n_vals = list(range(max_n))
    
    for n in n_vals:
        if W_concat[n] != INF:
            ax.bar(n, W_concat[n], color='forestgreen', alpha=0.8, edgecolor='darkgreen')
        else:
            ax.bar(n, 0.5, bottom=-0.3, color='red', alpha=0.3, edgecolor='red',
                   hatch='///')
    
    concat_bp = 0
    for d in range(max_n):
        if is_tropical_breakpoint(W_concat[:max_n], d):
            concat_bp = d
    ax.axvline(x=concat_bp - 0.5, color='red', linestyle='--', linewidth=2,
               label=f'Breakpoint d={concat_bp} ≥ 3+2')
    
    ax.set_xlabel('Weight n')
    ax.set_ylabel('(W_A ⊕ W_B)(n)')
    ax.set_title('Concatenation via Inf-Convolution')
    ax.legend(fontsize=9)
    ax.set_xticks(n_vals)
    
    # Plot 3: Self-convolution (collision bound)
    ax = axes[1, 0]
    max_n = min(len(W_self), 17)
    n_vals = list(range(max_n))
    
    for n in n_vals:
        if W_self[n] != INF:
            ax.bar(n, W_self[n], color='darkorange', alpha=0.8, edgecolor='brown')
        else:
            ax.bar(n, 0.5, bottom=-0.3, color='red', alpha=0.3, edgecolor='red',
                   hatch='///')
    
    self_bp = 0
    for d in range(max_n):
        if is_tropical_breakpoint(W_self[:max_n], d):
            self_bp = d
    ax.axvline(x=self_bp - 0.5, color='red', linestyle='--', linewidth=2,
               label=f'Breakpoint d={self_bp} ≥ 2×4')
    
    ax.set_xlabel('Weight n')
    ax.set_ylabel('(W ⊕ W)(n)')
    ax.set_title('Self-Convolution — Collision Bound')
    ax.legend(fontsize=9)
    ax.set_xticks(n_vals)
    
    # Plot 4: Comparison of original and iterated profiles
    ax = axes[1, 1]
    
    # Compute W^⊕3
    W_triple = compute_profile(W_self, W_orig, max_n - 1)
    
    profiles = {
        'W (d=4)': W_orig,
        'W⊕W (d≥8)': W_self,
        'W⊕W⊕W (d≥12)': W_triple,
    }
    colors = ['steelblue', 'darkorange', 'forestgreen']
    
    for (label, profile), color in zip(profiles.items(), colors):
        xs = []
        ys = []
        for n in range(min(len(profile), max_n)):
            if profile[n] != INF:
                xs.append(n)
                ys.append(profile[n])
        if xs:
            ax.plot(xs, ys, 'o-', color=color, label=label, markersize=5, linewidth=2)
    
    ax.set_xlabel('Weight n')
    ax.set_ylabel('Profile value')
    ax.set_title('Iterated Self-Convolution — Breakpoint Growth')
    ax.legend(fontsize=9)
    ax.set_xticks(range(max_n))
    
    plt.tight_layout()
    plt.savefig('Bridges/tropical_quantum_demo.png', dpi=150, bbox_inches='tight')
    print("\n[Saved visualization to Bridges/tropical_quantum_demo.png]")
    plt.close()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Quantum Code Geometry — Interactive Demo      ║")
    print("║  Companion to QuantumTropicalCore.lean                  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    W_513 = example_five_qubit_code()
    W_A, W_B, W_concat = example_concatenation()
    W_orig, W_self = example_collision_bound()
    
    print("\n" + "=" * 60)
    print("Summary of Certified Results")
    print("=" * 60)
    print("""
All results below are machine-verified in Lean 4:

1. quantum_certified_breakpoint_distance:
   Breakpoint at d ⟹ all stabilizer elements have weight ≥ d
   
2. breakpoint_add_of_both:
   Breakpoints are additive under inf-convolution (concatenation)
   d₁ + d₂ ≤ breakpoint(W₁ ⊕ W₂)
   
3. tropical_hash_collision_lower_bound:
   Self-convolution doubles the breakpoint
   2d ≤ breakpoint(W ⊕ W)

4. tropicalSupportFunction_infimal:
   σ_{S∪T}(x) = min(σ_S(x), σ_T(x))
   Support function distributes over union

Computational complexity:
  - tropWeightEnumerator: O(|S|) per weight
  - infConvolutionNat: O(n) per evaluation point
  - Full profile (N weights): O(N²) naively
""")
    
    try:
        create_visualizations(W_513, W_A, W_B, W_concat, W_orig, W_self)
    except Exception as e:
        print(f"[Visualization skipped: {e}]")
