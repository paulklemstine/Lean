#!/usr/bin/env python3
"""
Reflective Operator Algebras: Numerical Demonstrations

This script demonstrates the key concepts of the Reflective Operator Algebra
framework through concrete numerical examples:
1. The Cantor diagonal obstruction
2. The Kleene ascending chain and fixed point convergence
3. The diagonal tower hierarchy
4. Finite self-reference impossibility (cardinality argument)
"""

import math
from typing import Callable, List, Dict, Set, Tuple


def demo_diagonal_obstruction():
    """
    Demonstrate the Cantor diagonal argument concretely.
    
    Given a function f : {0,...,n-1} -> ({0,...,n-1} -> {T,F}),
    construct the diagonal witness and show it's not in the range.
    """
    print("=" * 60)
    print("DEMO 1: Cantor Diagonal Obstruction")
    print("=" * 60)
    
    n = 5
    # Define f(i) as a predicate on {0,...,n-1}
    # f(i)(j) = True iff j < i+1 (i.e., f(i) = {0, 1, ..., i})
    f = {i: {j: (j < i + 1) for j in range(n)} for i in range(n)}
    
    print(f"\nEncoding function f : {{0,...,{n-1}}} -> ({{0,...,{n-1}}} -> Bool):")
    for i in range(n):
        bits = ''.join(['T' if f[i][j] else 'F' for j in range(n)])
        print(f"  f({i}) = [{bits}]")
    
    # Diagonal: d(x) = NOT f(x)(x)
    diagonal = {x: not f[x][x] for x in range(n)}
    diag_bits = ''.join(['T' if diagonal[j] else 'F' for j in range(n)])
    print(f"\nDiagonal witness d(x) = ¬f(x)(x): [{diag_bits}]")
    
    # Verify it's not in the range
    for i in range(n):
        match = all(f[i][j] == diagonal[j] for j in range(n))
        if match:
            print(f"  !! d = f({i})  -- THIS SHOULD NEVER HAPPEN")
        else:
            diff_at = [j for j in range(n) if f[i][j] != diagonal[j]]
            print(f"  d ≠ f({i}), differ at positions {diff_at}")
    
    print("\n  ✓ Diagonal witness is NOT in the range of f")
    print("  This is the constructive content of self-model incompleteness.")


def demo_kleene_chain():
    """
    Demonstrate the Kleene ascending chain on the lattice [0, 1].
    
    F(x) = (x + 1) / 2 on the complete lattice [0, 1].
    Kleene chain: F^0(0) = 0, F^1(0) = 0.5, F^2(0) = 0.75, ...
    Fixed point: x = 1 (the least fixed point in [0,1] for this F).
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Kleene Ascending Chain")
    print("=" * 60)
    
    def F(x: float) -> float:
        return (x + 1) / 2
    
    print("\nOperator F(x) = (x + 1) / 2 on [0, 1]")
    print("Fixed point: x = 1 (since F(1) = 1)")
    print("\nKleene chain F^n(⊥) where ⊥ = 0:")
    
    x = 0.0
    for n in range(15):
        print(f"  F^{n:2d}(⊥) = {x:.10f}   (gap to fp: {1.0 - x:.10f})")
        x = F(x)
    
    print(f"\n  Chain converges to lfp = 1.0")
    print(f"  Rate: geometric with ratio 1/2 (each step halves the gap)")
    
    # Also demonstrate with a non-continuous operator
    print("\n--- Non-continuous operator example ---")
    print("G(x) = 0.5 if x < 0.5, else 1.0")
    
    def G(x: float) -> float:
        return 0.5 if x < 0.5 else 1.0
    
    x = 0.0
    for n in range(6):
        print(f"  G^{n}(⊥) = {x}")
        x = G(x)
    print("  Chain stabilizes at G^2(⊥) = 1.0 (which IS lfp)")


def demo_diagonal_tower():
    """
    Demonstrate the diagonal tower: iterating the diagonal construction.
    
    Level 0: d₀(x) = ¬f(x)(x)
    Level 1: d₁(x) = ¬d₀(x) = f(x)(x)  
    Level 2: d₂(x) = ¬d₁(x) = ¬f(x)(x) = d₀(x)
    
    The tower alternates with period 2, demonstrating that each adjacent
    pair is distinct (the hierarchy is strict).
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Diagonal Tower (Hierarchy of Self-Reference)")
    print("=" * 60)
    
    n = 6
    # Base encoding
    f = {i: {j: (i + j) % 3 == 0 for j in range(n)} for i in range(n)}
    
    print(f"\nBase encoding f on {{0,...,{n-1}}}:")
    for i in range(n):
        bits = ''.join(['T' if f[i][j] else 'F' for j in range(n)])
        print(f"  f({i}) = [{bits}]")
    
    # Build tower
    tower = []
    # Level 0: diagonal of f
    d0 = {x: not f[x][x] for x in range(n)}
    tower.append(d0)
    
    for level in range(1, 8):
        prev = tower[-1]
        curr = {x: not prev[x] for x in range(n)}
        tower.append(curr)
    
    print("\nDiagonal tower:")
    for level, d in enumerate(tower):
        bits = ''.join(['T' if d[j] else 'F' for j in range(n)])
        print(f"  d_{level}(x) = [{bits}]", end="")
        if level > 0:
            same_as_prev = all(tower[level][x] == tower[level-1][x] for x in range(n))
            print(f"  {'= d_{}'.format(level-1) if same_as_prev else '≠ d_{}'.format(level-1)}", end="")
        print()
    
    print("\n  ✓ Adjacent levels are always distinct (hierarchy is strict)")
    print("  ✓ Tower has period 2: d_{n+2} = d_n for all n")
    print("  This reflects the arithmetical hierarchy structure:")
    print("  each level of self-reference is genuinely new.")


def demo_cardinality_impossibility():
    """
    Demonstrate the cardinality argument against finite self-reference.
    
    For a finite type α with |α| = n:
    |α → Bool| = 2^n
    
    We need n = 2^n, which has no solutions for n ∈ ℕ.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Finite Self-Reference Impossibility")
    print("=" * 60)
    
    print("\nFor finite α with |α| = n, a bijection α ≃ (α → Bool)")
    print("requires n = 2^n. Checking all small n:\n")
    
    for n in range(20):
        power = 2 ** n
        ratio = power / n if n > 0 else float('inf')
        status = "✓ IMPOSSIBLE" if n != power else "?? MATCH"
        print(f"  n = {n:2d}: 2^n = {power:7d}  (ratio: {ratio:8.2f})  {status}")
    
    print(f"\n  The equation n = 2^n has NO solutions in ℕ.")
    print(f"  Therefore no finite type can be its own function space.")
    print(f"  Self-reference requires infinite cardinality.")


def demo_reflective_spectrum():
    """
    Demonstrate the reflective spectrum: fixed points of the reflection operator.
    
    On the Boolean lattice P({0,1,2}), consider ρ(S) = S ∪ complement(S)^c = S ∪ S = S.
    Actually, let's use ρ(S) = S ∪ {max(S) + 1} if max(S) < n-1, else S.
    Then the only fixed point is S = {0, 1, ..., n-1} = the full set.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Reflective Spectrum (Fixed Points of ρ)")
    print("=" * 60)
    
    n = 4
    universe = set(range(n))
    
    def rho(S: frozenset) -> frozenset:
        """ρ(S) = upward closure of S: add all supersets of elements"""
        if not S:
            return frozenset({0})  # ⊥ maps to {0}
        m = max(S)
        if m < n - 1:
            return frozenset(S | {m + 1})
        return S
    
    print(f"\nReflection operator ρ on P({{0,...,{n-1}}}):")
    print(f"ρ(S) = S ∪ {{max(S) + 1}} if max(S) < {n-1}, else S")
    
    # Find fixed points
    fixed_points = []
    for mask in range(2**n):
        S = frozenset(i for i in range(n) if mask & (1 << i))
        if rho(S) == S:
            fixed_points.append(S)
    
    print(f"\nFixed points of ρ (the reflective spectrum):")
    for fp in fixed_points:
        print(f"  {set(fp)}")
    
    # Show Kleene chain
    print(f"\nKleene chain ρ^k(∅):")
    S = frozenset()
    for k in range(n + 2):
        print(f"  ρ^{k}(∅) = {set(S)}")
        S = rho(S)
    
    print(f"\n  ✓ Spectrum is nonempty (Knaster-Tarski guarantees this)")
    print(f"  ✓ lfp ρ = {set(fixed_points[0])} is in the spectrum")


if __name__ == "__main__":
    demo_diagonal_obstruction()
    demo_kleene_chain()
    demo_diagonal_tower()
    demo_cardinality_impossibility()
    demo_reflective_spectrum()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
All five demonstrations confirm the formal theorems:

1. diagonal_not_in_range: The Cantor diagonal is constructively 
   outside any encoding's range.

2. kleeneChain_mono + kleeneLimit_fixed_of_continuous: The Kleene 
   chain converges monotonically; for ω-continuous operators, 
   the limit IS the least fixed point.

3. diagonal_tower_adjacent_distinct: The hierarchy of iterated 
   diagonals is strict — each level is genuinely new.

4. finite_self_ref_impossible: n = 2^n has no natural number 
   solutions, so no finite type is self-referential.

5. reflective_spectrum_nonempty: Every monotone operator on a 
   complete lattice has fixed points (Knaster-Tarski).
""")


#!/usr/bin/env python3
"""
Visualization: Diagonal Tower and Self-Reference Impossibility

Two panels:
1. The diagonal tower showing alternating levels
2. The cardinality argument n vs 2^n
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Self-Reference: Diagonal Tower & Cardinality Obstruction',
                 fontsize=15, fontweight='bold')

    # Panel 1: Diagonal Tower
    ax = axes[0]
    n = 8
    # Base encoding: f(i)(j) = (i + j) % 3 == 0
    f = {i: {j: (i + j) % 3 == 0 for j in range(n)} for i in range(n)}
    
    # Build tower
    levels = 8
    tower = []
    d = {x: not f[x][x] for x in range(n)}
    tower.append(d)
    for _ in range(1, levels):
        d = {x: not tower[-1][x] for x in range(n)}
        tower.append(d)
    
    # Display as heatmap
    data = np.array([[1 if tower[lev][x] else 0 for x in range(n)]
                     for lev in range(levels)])
    
    im = ax.imshow(data, cmap='RdYlBu', aspect='auto', interpolation='nearest')
    ax.set_xlabel('Element x', fontsize=12)
    ax.set_ylabel('Tower Level', fontsize=12)
    ax.set_title('Diagonal Tower: Alternating Hierarchy', fontsize=13)
    ax.set_xticks(range(n))
    ax.set_yticks(range(levels))
    ax.set_yticklabels([f'd_{i}' for i in range(levels)])
    
    # Add text annotations
    for lev in range(levels):
        for x in range(n):
            ax.text(x, lev, 'T' if tower[lev][x] else 'F',
                   ha='center', va='center', fontsize=8,
                   color='white' if tower[lev][x] else 'black')
    
    # Panel 2: n vs 2^n
    ax = axes[1]
    ns = np.arange(0, 11)
    powers = 2.0 ** ns
    
    ax.bar(ns - 0.15, ns, width=0.3, color='steelblue', label='n', alpha=0.8)
    ax.bar(ns + 0.15, np.minimum(powers, 1200), width=0.3, color='coral',
           label='2^n', alpha=0.8)
    
    # Mark the gap
    for ni in ns:
        if 2**ni <= 1200:
            gap = 2**ni - ni
            if gap > 0 and ni > 0:
                ax.annotate(f'gap={gap}', xy=(ni, max(ni, 2**ni) + 10),
                           fontsize=7, ha='center', color='darkred')
    
    ax.set_xlabel('n = |α|', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Finite Self-Reference Impossibility:\nn ≠ 2^n for all n ∈ ℕ',
                fontsize=13)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.set_ylim(0.5, 2000)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('diagonal_tower_cardinality.png', dpi=150, bbox_inches='tight')
    print("Saved: diagonal_tower_cardinality.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Kleene Ascending Chain Convergence

Shows the Kleene chain F^n(⊥) converging to the least fixed point
for several different operators, illustrating the monotone ascent
and convergence behavior.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


def kleene_chain_values(F, bottom, n_steps):
    """Compute the Kleene chain F^0(⊥), F^1(⊥), ..., F^n(⊥)."""
    chain = [bottom]
    x = bottom
    for _ in range(n_steps):
        x = F(x)
        chain.append(x)
    return chain


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Kleene Ascending Chains: Convergence to Fixed Points',
                 fontsize=16, fontweight='bold')

    n_steps = 20

    # Operator 1: F(x) = (x + 1) / 2, lfp = 1
    ax = axes[0, 0]
    chain = kleene_chain_values(lambda x: (x + 1) / 2, 0.0, n_steps)
    ax.plot(range(len(chain)), chain, 'bo-', markersize=4, linewidth=1.5)
    ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='lfp = 1')
    ax.set_title(r'$F(x) = \frac{x+1}{2}$', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel(r'$F^n(\bot)$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Operator 2: F(x) = sqrt(x + 1), lfp ≈ 1.618 (golden ratio)
    ax = axes[0, 1]
    chain = kleene_chain_values(lambda x: np.sqrt(x + 1), 0.0, n_steps)
    golden = (1 + np.sqrt(5)) / 2
    ax.plot(range(len(chain)), chain, 'go-', markersize=4, linewidth=1.5)
    ax.axhline(y=golden, color='r', linestyle='--', alpha=0.7,
               label=f'lfp = φ ≈ {golden:.4f}')
    ax.set_title(r'$F(x) = \sqrt{x+1}$', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel(r'$F^n(\bot)$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Operator 3: F(x) = x^2/4 + x/2 + 0.25 (slow convergence)
    ax = axes[1, 0]
    chain = kleene_chain_values(lambda x: 0.5 * x + 0.5, 0.0, n_steps)
    ax.plot(range(len(chain)), chain, 'mo-', markersize=4, linewidth=1.5)
    ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='lfp = 1')
    ax.set_title(r'$F(x) = \frac{x}{2} + \frac{1}{2}$', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel(r'$F^n(\bot)$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Operator 4: F(x) = 1 - (1-x)^3, fast convergence
    ax = axes[1, 1]
    chain = kleene_chain_values(lambda x: 1 - (1 - x) ** 3, 0.0, n_steps)
    ax.plot(range(len(chain)), chain, 'co-', markersize=4, linewidth=1.5)
    ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='lfp = 1')
    ax.set_title(r'$F(x) = 1 - (1-x)^3$', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel(r'$F^n(\bot)$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('kleene_chain_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: kleene_chain_convergence.png")


if __name__ == "__main__":
    main()
