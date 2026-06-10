#!/usr/bin/env python3
"""
Closure Growth Separation Demo
===============================

Demonstrates the core theorems from EntropyClosureSeparation.lean with
concrete numerical examples:

1. Iterated closure growth under different preclosure operators
2. Stabilization of genuine closure operators (idempotent)
3. Finite witness extraction when two policies diverge
4. EML closure dynamics on real-number seed sets

Usage:
    python demo_closure_growth.py
"""

import math
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import numpy as np
from typing import Callable, Set, Tuple, Optional

# ============================================================
# Core definitions (mirroring the Lean formalization)
# ============================================================

def closure_iter(C: Callable[[set], set], n: int, S: set) -> set:
    """Iterate a set transformer C by n-fold self-composition.
    Corresponds to `closureIter C n S` in Lean."""
    result = set(S)
    for _ in range(n):
        result = C(result)
    return result


def is_preclosure(C: Callable[[set], set], test_sets: list) -> bool:
    """Check if C is extensive and monotone on given test sets."""
    for S in test_sets:
        # Extensive: S ⊆ C(S)
        if not S.issubset(C(S)):
            return False
    for i, S in enumerate(test_sets):
        for T in test_sets[i:]:
            if S.issubset(T):
                # Monotone: S ⊆ T → C(S) ⊆ C(T)
                if not C(S).issubset(C(T)):
                    return False
    return True


def find_witness(F: Callable[[set], set], G: Callable[[set], set],
                 S: set, max_n: int = 20) -> Optional[Tuple[int, object]]:
    """Find the first stage n and witness x such that x ∈ F^[n](S) but x ∉ G^[n](S).
    Corresponds to `finite_witness_of_stage_separation` in Lean."""
    F_current = set(S)
    G_current = set(S)
    for n in range(max_n + 1):
        diff = F_current - G_current
        if diff:
            witness = min(diff)  # Pick smallest for determinism
            return (n, witness)
        F_current = F(F_current)
        G_current = G(G_current)
    return None


# ============================================================
# Example 1: Arithmetic preclosure operators
# ============================================================

def demo_arithmetic_preclosure():
    """Two preclosure operators on integers that diverge.

    F: adds all pairwise sums (grows fast)
    G: adds only successors (grows linearly)
    """
    print("=" * 60)
    print("DEMO 1: Arithmetic Preclosure Separation")
    print("=" * 60)

    # Preclosure F: add all pairwise sums (capped at 100 for finiteness)
    def F(S: set) -> set:
        result = set(S)
        for a in S:
            for b in S:
                if 0 <= a + b <= 100:
                    result.add(a + b)
        return result

    # Preclosure G: add successor of each element
    def G(S: set) -> set:
        result = set(S)
        for x in S:
            if x + 1 <= 100:
                result.add(x + 1)
        return result

    seed = {1, 2}
    print(f"\nSeed set S = {sorted(seed)}")
    print(f"F: pairwise sums (fast growth)")
    print(f"G: successors only (linear growth)")

    # Track growth
    F_sizes = []
    G_sizes = []
    F_current = set(seed)
    G_current = set(seed)

    for n in range(15):
        F_sizes.append(len(F_current))
        G_sizes.append(len(G_current))
        print(f"  Stage {n:2d}: |F^[{n}](S)| = {len(F_current):3d}, "
              f"|G^[{n}](S)| = {len(G_current):3d}")
        F_current = F(F_current)
        G_current = G(G_current)

    # Find witness
    result = find_witness(F, G, seed, max_n=20)
    if result:
        n, x = result
        print(f"\n  ✓ Finite witness found at stage {n}: x = {x}")
        print(f"    x ∈ F^[{n}](S) but x ∉ G^[{n}](S)")
    else:
        print(f"\n  No witness found in 20 stages")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(F_sizes)), F_sizes, 'b-o', label='F (pairwise sums)', markersize=4)
    ax.plot(range(len(G_sizes)), G_sizes, 'r-s', label='G (successors)', markersize=4)
    if result:
        ax.axvline(x=result[0], color='green', linestyle='--', alpha=0.7,
                   label=f'Separation at stage {result[0]}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|Closure^[n](S)|')
    ax.set_title('Closure Growth: Fast vs Slow Policy')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.savefig('/workspace/request-project/Bridges/NeuralProofMining/demo1_arithmetic_growth.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Plot saved to demo1_arithmetic_growth.png")


# ============================================================
# Example 2: Idempotent closure stabilization
# ============================================================

def demo_idempotent_stabilization():
    """Demonstrates closureIter_stabilizes: a genuine closure operator
    reaches its fixed point in one step."""
    print("\n" + "=" * 60)
    print("DEMO 2: Idempotent Closure Stabilization")
    print("=" * 60)

    # Closure operator: downward closure (all elements ≤ max of S)
    def C(S: set) -> set:
        if not S:
            return set()
        return set(range(min(S), max(S) + 1))

    seed = {2, 5, 8}
    print(f"\nClosure C: fill in all integers between min and max")
    print(f"Seed S = {sorted(seed)}")

    for n in range(5):
        result = closure_iter(C, n, seed)
        print(f"  C^[{n}](S) = {sorted(result)}")

    print(f"\n  ✓ Stabilizes at stage 1: C^[n+1](S) = C(S) for all n")
    print(f"    This is Theorem closureIter_stabilizes in Lean")

    # Verify idempotence
    CS = C(seed)
    CCS = C(CS)
    print(f"\n  C(S)    = {sorted(CS)}")
    print(f"  C(C(S)) = {sorted(CCS)}")
    print(f"  Idempotent: C(C(S)) = C(S)? {CS == CCS}")


# ============================================================
# Example 3: Fixed-point invariance
# ============================================================

def demo_fixed_point_invariance():
    """Demonstrates closure_fixed_points_are_iterative_invariants:
    if C(S) = S, then C^[n](S) = S for all n."""
    print("\n" + "=" * 60)
    print("DEMO 3: Fixed-Point Iterative Invariance")
    print("=" * 60)

    # Closure: convex hull on integers (fill gaps)
    def C(S: set) -> set:
        if not S:
            return set()
        return set(range(min(S), max(S) + 1))

    # A fixed point: already a complete interval
    fixed_point = {3, 4, 5, 6, 7}
    print(f"\nFixed point S = {sorted(fixed_point)}")
    print(f"C(S) = {sorted(C(fixed_point))}")
    print(f"S is a fixed point: C(S) = S? {C(fixed_point) == fixed_point}")

    print(f"\nVerifying iterative invariance:")
    for n in range(6):
        result = closure_iter(C, n, fixed_point)
        is_equal = result == fixed_point
        print(f"  C^[{n}](S) = {sorted(result)}  (= S? {is_equal})")

    print(f"\n  ✓ All iterates equal S — this is Theorem")
    print(f"    closure_fixed_points_are_iterative_invariants in Lean")


# ============================================================
# Example 4: EML Closure dynamics
# ============================================================

def demo_eml_closure():
    """Demonstrates EML closure growth on real numbers.
    EMLd(a, b) = exp(a) - log(b)"""
    print("\n" + "=" * 60)
    print("DEMO 4: EML Closure Dynamics")
    print("=" * 60)

    def emld(a: float, b: float) -> Optional[float]:
        """EML operation: exp(a) - log(b). Returns None if overflow."""
        if b <= 0:
            return None
        try:
            val = math.exp(a) - math.log(b)
            if abs(val) > 1e6:
                return None
            return val
        except OverflowError:
            return None

    def eml_closure_step(S: set) -> set:
        """One step of EML closure: add all EMLd(a, b) for a, b in S."""
        result = set(S)
        for a in list(S):
            for b in list(S):
                val = emld(a, b)
                if val is not None:
                    result.add(round(val, 8))
        return result

    seed = {1.0}
    print(f"\nSeed S = {seed}")
    print(f"EMLd(a, b) = exp(a) - log(b)")

    current = set(seed)
    for n in range(3):  # Only 3 stages to keep computation tractable
        print(f"\n  EMLClosure' stage {n}: {len(current)} elements")
        sorted_vals = sorted(current)
        if len(sorted_vals) <= 10:
            for v in sorted_vals:
                print(f"    {v:.6f}")
        else:
            for v in sorted_vals[:5]:
                print(f"    {v:.6f}")
            print(f"    ... ({len(sorted_vals) - 10} more) ...")
            for v in sorted_vals[-5:]:
                print(f"    {v:.6f}")
        current = eml_closure_step(current)

    # Demonstrate key EML identities
    print(f"\n  Key EML identities (verified numerically):")
    x = 2.0
    print(f"    EMLd(x, 1) = exp(x) = {emld(x, 1):.6f} (exp({x}) = {math.exp(x):.6f})")
    print(f"    EMLd(0, x) = 1 - ln(x) = {emld(0, x):.6f} (1 - ln({x}) = {1 - math.log(x):.6f})")

    # Plot growth
    seed_set = {1.0}
    sizes = []
    current = set(seed_set)
    for n in range(4):  # Cap at 4 for tractability
        sizes.append(len(current))
        current = eml_closure_step(current)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(range(len(sizes)), sizes, color='steelblue', alpha=0.8)
    ax.set_xlabel('Depth n')
    ax.set_ylabel('|EMLClosure\'(n, {1})|')
    ax.set_title('EML Closure Growth from Seed {1}')
    ax.grid(True, alpha=0.3, axis='y')
    fig.savefig('/workspace/request-project/Bridges/NeuralProofMining/demo4_eml_growth.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"\n  Plot saved to demo4_eml_growth.png")


# ============================================================
# Example 5: Eventual growth gap visualization
# ============================================================

def demo_eventual_gap():
    """Demonstrates EventuallyStrictlyLarger and witness extraction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Eventual Growth Gap and Witness Extraction")
    print("=" * 60)

    # F: multiplication closure (adds products, capped)
    def F(S: set) -> set:
        result = set(S)
        for a in list(S):
            for b in list(S):
                if 0 < a * b <= 200:
                    result.add(a * b)
        return result

    # G: only adds squares
    def G(S: set) -> set:
        result = set(S)
        for a in list(S):
            if 0 < a * a <= 200:
                result.add(a * a)
        return result

    seed = {2, 3}
    print(f"\nSeed S = {sorted(seed)}")
    print(f"F: all products a·b for a,b in S")
    print(f"G: only squares a² for a in S")

    F_sizes = []
    G_sizes = []
    F_current = set(seed)
    G_current = set(seed)
    witness_stage = None
    witness_elem = None

    for n in range(12):
        F_sizes.append(len(F_current))
        G_sizes.append(len(G_current))

        diff = F_current - G_current
        strictly_larger = G_current.issubset(F_current) and diff
        marker = " ⊂" if strictly_larger else ""

        if diff and witness_stage is None:
            witness_stage = n
            witness_elem = min(diff)

        print(f"  Stage {n:2d}: |F^[{n}]| = {len(F_current):3d}, "
              f"|G^[{n}]| = {len(G_current):3d}{marker}")

        F_current = F(F_current)
        G_current = G(G_current)

    if witness_stage is not None:
        print(f"\n  ✓ Witness: x = {witness_elem} at stage {witness_stage}")
        print(f"    {witness_elem} ∈ F^[{witness_stage}](S) but {witness_elem} ∉ G^[{witness_stage}](S)")
        print(f"    This is Theorem finite_witness_of_eventual_growth_gap in Lean")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(F_sizes)), F_sizes, 'b-o', label='F (all products)', markersize=4)
    ax.plot(range(len(G_sizes)), G_sizes, 'r-s', label='G (squares only)', markersize=4)
    if witness_stage is not None:
        ax.axvline(x=witness_stage, color='green', linestyle='--', alpha=0.7,
                   label=f'First witness at stage {witness_stage}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|Closure^[n](S)|')
    ax.set_title('Eventual Growth Gap: Product vs Square Policy')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.fill_between(range(len(F_sizes)), G_sizes, F_sizes, alpha=0.15, color='blue',
                    label='_nolegend_')
    fig.savefig('/workspace/request-project/Bridges/NeuralProofMining/demo5_eventual_gap.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Plot saved to demo5_eventual_gap.png")


# ============================================================
# Example 6: Preclosure vs Closure comparison
# ============================================================

def demo_preclosure_vs_closure():
    """Shows the dichotomy: preclosure operators can grow forever,
    but closure operators saturate immediately."""
    print("\n" + "=" * 60)
    print("DEMO 6: Preclosure vs Closure — The Growth Dichotomy")
    print("=" * 60)

    # Preclosure: add n+1 for each n in S (unbounded growth)
    def pre_C(S: set) -> set:
        result = set(S)
        for x in list(S):
            result.add(x + 1)
        return result

    # Genuine closure: convex hull (fill all gaps, idempotent)
    def true_C(S: set) -> set:
        if not S:
            return set()
        return set(range(min(S), max(S) + 1))

    seed = {1, 5, 10}
    print(f"\nSeed S = {sorted(seed)}")

    pre_sizes = []
    true_sizes = []
    pre_current = set(seed)
    true_current = set(seed)

    print(f"\n  {'Stage':>5} | {'Preclosure |S|':>15} | {'Closure |S|':>12} | Note")
    print(f"  {'-'*5}-+-{'-'*15}-+-{'-'*12}-+-{'-'*25}")

    for n in range(12):
        pre_sizes.append(len(pre_current))
        true_sizes.append(len(true_current))

        note = ""
        if n == 0:
            note = "seed"
        elif n == 1:
            note = "closure saturates here"
        elif n > 1 and true_sizes[-1] == true_sizes[-2]:
            note = "closure stable (idempotent)"

        print(f"  {n:5d} | {len(pre_current):15d} | {len(true_current):12d} | {note}")
        pre_current = pre_C(pre_current)
        true_current = true_C(true_current)

    print(f"\n  ✓ The closure operator stabilizes at stage 1 (closureIter_stabilizes)")
    print(f"    The preclosure operator keeps growing (positive 'entropy rate')")
    print(f"    This dichotomy is the formal kernel of thermodynamic proof complexity")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(range(len(pre_sizes)), pre_sizes, 'b-o', markersize=4)
    ax1.set_xlabel('Iteration n')
    ax1.set_ylabel('|F^[n](S)|')
    ax1.set_title('Preclosure: Unbounded Growth')
    ax1.grid(True, alpha=0.3)

    ax2.plot(range(len(true_sizes)), true_sizes, 'r-s', markersize=4)
    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('|C^[n](S)|')
    ax2.set_title('Closure: Immediate Stabilization')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('The Growth Dichotomy: Preclosure vs Closure', fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/Bridges/NeuralProofMining/demo6_dichotomy.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Plot saved to demo6_dichotomy.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Closure Growth Separation — Numerical Demonstrations")
    print("Companion to EntropyClosureSeparation.lean")
    print()

    demo_arithmetic_preclosure()
    demo_idempotent_stabilization()
    demo_fixed_point_invariance()
    demo_eml_closure()
    demo_eventual_gap()
    demo_preclosure_vs_closure()

    print("\n" + "=" * 60)
    print("All demos complete. See .png files for visualizations.")
    print("=" * 60)
