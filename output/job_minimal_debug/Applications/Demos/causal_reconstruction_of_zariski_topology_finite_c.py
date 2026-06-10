#!/usr/bin/env python3
"""
Causal Reconstruction of Zariski Topology — Python Demo
========================================================

This demo visualizes the causal structure of prime spectra for concrete rings,
illustrating the theorems proved in the Lean 4 formalization.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def prime_ideals_of_Z():
    """The prime spectrum of ℤ: {(0), (2), (3), (5), (7), (11), ...}"""
    return [(0,)] + [(p,) for p in [2, 3, 5, 7, 11, 13]]


def prime_ideals_of_Z_mod_n(n):
    """Prime ideals of ℤ/nℤ = maximal ideals = (p) for p | n."""
    primes = []
    temp = n
    for p in range(2, n + 1):
        if temp % p == 0:
            primes.append(p)
            while temp % p == 0:
                temp //= p
    return primes


def causal_future(p, all_primes, containment):
    """J⁺(p) = {q : p ⊆ q} in the prime spectrum."""
    return {q for q in all_primes if containment(p, q)}


def causal_past(p, all_primes, containment):
    """J⁻(p) = {q : q ⊆ p} in the prime spectrum."""
    return {q for q in all_primes if containment(q, p)}


def causal_diamond(p, q, all_primes, containment):
    """J(p,q) = J⁺(p) ∩ J⁻(q)."""
    return causal_future(p, all_primes, containment) & causal_past(q, all_primes, containment)


def krull_dimension(all_primes, strict_containment):
    """Compute the Krull dimension = max length of strict chain."""
    max_len = 0
    # BFS/DFS to find longest chain
    def dfs(current, length):
        nonlocal max_len
        max_len = max(max_len, length)
        for q in all_primes:
            if strict_containment(current, q):
                dfs(q, length + 1)
    
    for p in all_primes:
        dfs(p, 0)
    return max_len


# ============================================================
# Demo 1: Causal Structure of Spec(ℤ)
# ============================================================
def demo_spec_Z():
    """Visualize the causal structure of Spec(ℤ).
    
    The prime spectrum of ℤ consists of:
    - The generic point (0) — the "Big Bang"
    - The closed points (p) for each prime p — the "endpoints"
    
    Krull dimension = 1 (proved as integers_causal_depth_one).
    """
    print("=" * 60)
    print("Demo 1: Causal Structure of Spec(ℤ)")
    print("=" * 60)
    
    primes_display = [0, 2, 3, 5, 7, 11, 13]
    
    # The ordering: (0) ⊆ (p) for all primes p, and (p) ⊆ (q) only if p = q
    print("\nPrime ideals: (0), (2), (3), (5), (7), (11), (13)")
    print("\nCausal order (⊆ on ideals):")
    print("  (0) ≤ (p) for all primes p")
    print("  (p) ≤ (q) only if p = q")
    
    print("\nCausal futures J⁺(p):")
    print(f"  J⁺((0)) = Spec(ℤ) = all primes  [Big Bang theorem]")
    for p in [2, 3, 5, 7, 11, 13]:
        print(f"  J⁺(({p})) = {{({p})}}  [maximal ideal → singleton]")
    
    print(f"\nKrull dimension = 1  [integers_causal_depth_one]")
    print(f"  Longest causal chain: (0) ⊂ (p) — length 1")
    print(f"  This means the causal hierarchy has exactly one level.")
    
    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Draw the Big Bang at the bottom
    ax.plot(5, 0, 'ro', markersize=15, zorder=5)
    ax.annotate('(0)\nBig Bang', (5, 0), textcoords="offset points",
                xytext=(0, -30), ha='center', fontsize=10, fontweight='bold')
    
    # Draw maximal ideals at the top
    x_positions = np.linspace(1, 9, 6)
    for i, (p, x) in enumerate(zip([2, 3, 5, 7, 11, 13], x_positions)):
        ax.plot(x, 2, 'bs', markersize=12, zorder=5)
        ax.annotate(f'({p})', (x, 2), textcoords="offset points",
                    xytext=(0, 15), ha='center', fontsize=9)
        # Draw causal arrow from (0) to (p)
        ax.annotate('', xy=(x, 1.85), xytext=(5, 0.15),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, alpha=0.5))
    
    ax.set_xlim(0, 10)
    ax.set_ylim(-1, 3.5)
    ax.set_title('Causal Structure of Spec(ℤ)\nKrull dimension = 1', fontsize=14)
    ax.set_ylabel('Causal Depth', fontsize=12)
    ax.set_yticks([0, 2])
    ax.set_yticklabels(['Depth 0\n(generic)', 'Depth 1\n(maximal)'])
    ax.set_xticks([])
    
    # Legend
    red_patch = mpatches.Patch(color='red', label='Generic point (0) — Big Bang')
    blue_patch = mpatches.Patch(color='blue', label='Maximal ideals (p) — Endpoints')
    ax.legend(handles=[red_patch, blue_patch], loc='upper right')
    
    plt.tight_layout()
    plt.savefig('spec_Z_causal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: spec_Z_causal.png")


# ============================================================
# Demo 2: Causal Structure of Spec(ℤ[x])
# ============================================================
def demo_spec_Zx():
    """Visualize a portion of Spec(ℤ[x]).
    
    The prime spectrum of ℤ[x] has three layers:
    - (0) at depth 0 (generic point)
    - (p) and (f(x)) at depth 1 (height-1 primes)
    - (p, f(x)) at depth 2 (maximal ideals)
    
    Krull dimension = 2.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Causal Structure of Spec(ℤ[x])")
    print("=" * 60)
    
    print("\nPrime ideals (partial list):")
    print("  Depth 0: (0)")
    print("  Depth 1: (2), (3), (x), (x+1), (x²+1)")
    print("  Depth 2: (2,x), (2,x+1), (3,x), (3,x+1)")
    
    print("\nKrull dimension = 2")
    print("  Longest chain: (0) ⊂ (2) ⊂ (2,x) — length 2")
    
    print("\nCausal futures:")
    print("  J⁺((0)) = Spec(ℤ[x])  [Big Bang]")
    print("  J⁺((2)) = {(2), (2,x), (2,x+1), ...}  [all primes containing 2]")
    print("  J⁺((x)) = {(x), (2,x), (3,x), ...}  [all primes containing x]")
    print("  J⁺((2,x)) = {(2,x)}  [maximal → singleton]")
    
    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    
    # Depth 0
    ax.plot(6, 0, 'ro', markersize=15, zorder=5)
    ax.annotate('(0)', (6, 0), textcoords="offset points",
                xytext=(15, 0), ha='left', fontsize=11, fontweight='bold')
    
    # Depth 1
    depth1 = [(2, 2), (3, 4), ('x', 6), ('x+1', 8), ('x²+1', 10)]
    for label, x in depth1:
        ax.plot(x, 2, 'gs', markersize=10, zorder=5)
        ax.annotate(f'({label})', (x, 2), textcoords="offset points",
                    xytext=(0, 12), ha='center', fontsize=9)
        ax.annotate('', xy=(x, 1.85), xytext=(6, 0.15),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1, alpha=0.4))
    
    # Depth 2
    depth2 = [('2,x', 1.5, [2, 6]), ('2,x+1', 3.5, [2, 8]),
              ('3,x', 5, [4, 6]), ('3,x+1', 7, [4, 8]),
              ('3,x²+1', 9, [4, 10])]
    for label, x, parents in depth2:
        ax.plot(x, 4, 'b^', markersize=10, zorder=5)
        ax.annotate(f'({label})', (x, 4), textcoords="offset points",
                    xytext=(0, 12), ha='center', fontsize=8)
        for px in parents:
            ax.annotate('', xy=(x, 3.85), xytext=(px, 2.15),
                        arrowprops=dict(arrowstyle='->', color='lightblue', lw=1, alpha=0.6))
    
    ax.set_xlim(0, 12)
    ax.set_ylim(-1, 5.5)
    ax.set_title('Causal Structure of Spec(ℤ[x])\nKrull dimension = 2', fontsize=14)
    ax.set_ylabel('Causal Depth', fontsize=12)
    ax.set_yticks([0, 2, 4])
    ax.set_yticklabels(['Depth 0', 'Depth 1', 'Depth 2'])
    ax.set_xticks([])
    
    red_patch = mpatches.Patch(color='red', label='Generic point (depth 0)')
    green_patch = mpatches.Patch(color='green', label='Height-1 primes (depth 1)')
    blue_patch = mpatches.Patch(color='blue', label='Maximal ideals (depth 2)')
    ax.legend(handles=[red_patch, green_patch, blue_patch], loc='upper right')
    
    plt.tight_layout()
    plt.savefig('spec_Zx_causal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: spec_Zx_causal.png")


# ============================================================
# Demo 3: Causal Diamonds and Their Properties
# ============================================================
def demo_causal_diamonds():
    """Demonstrate causal diamond properties.
    
    Key theorem: J(p,p) = {p} (degenerate diamond = singleton).
    Key theorem: J(q,p) = ∅ when p < q (no backwards causality).
    """
    print("\n" + "=" * 60)
    print("Demo 3: Causal Diamonds")
    print("=" * 60)
    
    print("\nIn Spec(ℤ[x]):")
    print("  J((0), (2,x)) = {(0), (2), (x), (2,x)}  — all primes between (0) and (2,x)")
    print("  J((2), (2,x)) = {(2), (2,x)}  — primes between (2) and (2,x)")
    print("  J((2,x), (2,x)) = {(2,x)}  — degenerate diamond [causalDiamond_self]")
    print("  J((2,x), (0)) = ∅  — reversed diamond is empty [causalDiamond_reverse_empty]")
    
    print("\nNested diamonds (causalDiamond_nested):")
    print("  (0) ≤ (2) and (2,x) ≤ (2,x) implies J((2),(2,x)) ⊆ J((0),(2,x))")


# ============================================================
# Demo 4: Finite Causal Decomposition
# ============================================================
def demo_finite_decomposition():
    """Demonstrate the finite causal decomposition theorem.
    
    For Noetherian R, every V(I) = finite union of V(p_i) = finite union of J⁺(p_i).
    """
    print("\n" + "=" * 60)
    print("Demo 4: Finite Causal Decomposition")
    print("=" * 60)
    
    print("\nExample: R = ℤ[x], I = (6x)")
    print("  V(6x) = V(2) ∪ V(3) ∪ V(x)")
    print("  = J⁺((2)) ∪ J⁺((3)) ∪ J⁺((x))")
    print("  Causal complexity = 3")
    print()
    print("  Minimal primes over (6x): {(2), (3), (x)}")
    print("  V(6x) decomposes into exactly 3 causal futures")
    print()
    print("Example: R = ℤ, I = (30)")
    print("  V(30) = V(2) ∪ V(3) ∪ V(5)")
    print("  = J⁺((2)) ∪ J⁺((3)) ∪ J⁺((5))")
    print("  Causal complexity = 3")
    
    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # V(30) in Spec(ℤ)
    ax1.set_title('V(30) in Spec(ℤ)\n= J⁺((2)) ∪ J⁺((3)) ∪ J⁺((5))', fontsize=12)
    for i, (p, color) in enumerate([(2, 'red'), (3, 'blue'), (5, 'green')]):
        ax1.plot(i * 2 + 1, 1, 'o', color=color, markersize=15, zorder=5)
        ax1.annotate(f'({p})', (i * 2 + 1, 1), textcoords="offset points",
                     xytext=(0, 15), ha='center', fontsize=12, fontweight='bold')
        ax1.annotate(f'J⁺(({p})) = {{({p})}}', (i * 2 + 1, 1),
                     textcoords="offset points", xytext=(0, -25), ha='center', fontsize=9)
    ax1.set_xlim(-0.5, 5.5)
    ax1.set_ylim(0, 2)
    ax1.set_xticks([])
    ax1.set_yticks([])
    
    # V(6x) in Spec(ℤ[x]) — show the tree structure
    ax2.set_title('V(6x) in Spec(ℤ[x])\n= J⁺((2)) ∪ J⁺((3)) ∪ J⁺((x))', fontsize=12)
    
    # Minimal primes
    for i, (label, color, x_pos) in enumerate([
        ('(2)', 'red', 1), ('(3)', 'blue', 3), ('(x)', 'green', 5)
    ]):
        ax2.plot(x_pos, 1, 's', color=color, markersize=12, zorder=5)
        ax2.annotate(label, (x_pos, 1), textcoords="offset points",
                     xytext=(0, 12), ha='center', fontsize=10)
    
    # Some maximal ideals above
    maxmals = [('(2,x)', 1, 'red'), ('(2,x+1)', 2, 'red'),
               ('(3,x)', 3, 'blue'), ('(3,x+1)', 4, 'blue'),
               ('(2,x)', 1, 'green'), ('(3,x)', 3, 'green')]
    seen = set()
    for label, x_pos, color in maxmals:
        if label not in seen:
            ax2.plot(x_pos, 2.5, '^', color='purple', markersize=8, zorder=5)
            ax2.annotate(label, (x_pos, 2.5), textcoords="offset points",
                         xytext=(0, 10), ha='center', fontsize=7)
            seen.add(label)
    
    ax2.set_xlim(-0.5, 6)
    ax2.set_ylim(0, 3.5)
    ax2.set_xticks([])
    ax2.set_yticks([])
    
    plt.tight_layout()
    plt.savefig('causal_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: causal_decomposition.png")


# ============================================================
# Demo 5: Holographic Encoding
# ============================================================
def demo_holographic():
    """Demonstrate the holographic encoding theorem.
    
    The topology is determined by singleton closures:
    closure({p}) = J⁺(p) = V(p).
    """
    print("\n" + "=" * 60)
    print("Demo 5: Holographic Encoding")
    print("=" * 60)
    
    print("\nThe Zariski topology is determined by singleton closures:")
    print("  closure({p}) = J⁺(p) = V(p)")
    print()
    print("In Spec(ℤ):")
    print("  closure({(0)}) = V((0)) = Spec(ℤ)  [the whole space]")
    print("  closure({(2)}) = V((2)) = {(2)}  [just the point]")
    print("  closure({(3)}) = V((3)) = {(3)}  [just the point]")
    print()
    print("A set S is closed iff ∀ p ∈ S, closure({p}) ⊆ S")
    print("  {(0), (2), (3)} is closed ✗  (closure({(0)}) = Spec(ℤ) ⊄ S)")
    print("  {(2), (3), (5)} is closed ✓  (each is maximal, closure = singleton)")
    print("  Spec(ℤ) is closed ✓  (trivially)")
    print()
    print("This is the 'holographic principle': knowing the causal future of")
    print("each point suffices to reconstruct the full topology.")


if __name__ == '__main__':
    demo_spec_Z()
    demo_spec_Zx()
    demo_causal_diamonds()
    demo_finite_decomposition()
    demo_holographic()
    
    print("\n" + "=" * 60)
    print("Summary of Verified Theorems (all proved in Lean 4)")
    print("=" * 60)
    print("""
  1. specialization_iff_causal_order: p ⤳ q ↔ p ≤ q
  2. causalFuture_eq_closure: J⁺(p) = closure({p})
  3. causalFuture_eq_zeroLocus: J⁺(p) = V(p)
  4. causalFuture_isClosed: J⁺(p) is Zariski-closed
  5. closed_upward_closed_causal: closed sets are upward-closed
  6. causalFuture_union_isClosed: finite ∪ J⁺(pᵢ) is closed
  7. zeroLocus_eq_union_minimalPrime_futures: V(I) = ∪ V(min primes)
  8. causal_finite_decomposition_forward: V(I) = finite ∪ J⁺(pᵢ)
  9. krullDim_eq_sup_causalDepth: dim R = sup of causal depths
  10. integers_causal_depth_one: dim ℤ = 1
  11. generic_point_causal_source: ∃ generic point for irreducible sets
  12. causalFuture_bot_eq_univ: J⁺(0) = Spec(R) for domains
  13. causalFuture_maximal: J⁺(m) = {m} for maximal m
  14. causalDiamond_self: J(p,p) = {p}
  15. causalDiamond_reverse_empty: J(q,p) = ∅ when p < q
  
  Total: 50 theorems, 11 definitions, 0 sorries.
""")
