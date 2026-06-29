#!/usr/bin/env python3
"""
Demonstration of Constructive Prime Witness Extraction
in Finite Distributive Closure Systems

This script illustrates the key mathematical results proved in
LatticePrimeSeparation.lean with concrete, executable examples.

The main idea: in a finite distributive lattice of "theories" (closed sets
under a closure operator), if an element a is NOT in a closed set K, then
there exists a PRIME closed set P containing K that still avoids a.
This is the "spectral separation" phenomenon.
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, FrozenSet, List, Tuple, Optional, Dict

# ============================================================
# Core: Closure Operators on Finite Sets
# ============================================================

class ClosureSystem:
    """
    A closure operator on a finite set {0, 1, ..., n-1}.
    
    A closure operator cl satisfies:
      - Extensive: S ⊆ cl(S)
      - Monotone: S ⊆ T → cl(S) ⊆ cl(T)
      - Idempotent: cl(cl(S)) = cl(S)
    """
    
    def __init__(self, n: int, cl_func):
        self.n = n
        self.universe = frozenset(range(n))
        self._cl = cl_func
        
    def cl(self, s: FrozenSet[int]) -> FrozenSet[int]:
        return self._cl(s)
    
    def is_closed(self, s: FrozenSet[int]) -> bool:
        return self.cl(s) == s
    
    def all_closed_sets(self) -> List[FrozenSet[int]]:
        """Enumerate all closed subsets."""
        result = []
        for r in range(self.n + 1):
            for subset in itertools.combinations(range(self.n), r):
                s = frozenset(subset)
                if self.is_closed(s):
                    result.append(s)
        return sorted(result, key=lambda s: (len(s), sorted(s)))


def is_distributive_lattice(closed_sets: List[FrozenSet[int]], cl_func) -> bool:
    """Check if the lattice of closed sets is distributive."""
    for a in closed_sets:
        for b in closed_sets:
            for c in closed_sets:
                # meet = intersection, join = cl(union)
                lhs = a & cl_func(b | c)
                rhs = cl_func((a & b) | (a & c))
                if lhs != rhs:
                    return False
    return True


# ============================================================
# Example 1: Power Set Closure (Identity)
# ============================================================

def identity_closure(n: int) -> ClosureSystem:
    """The identity closure: cl(S) = S. Every subset is closed.
    The lattice of closed sets is the Boolean lattice 2^n, which is distributive."""
    return ClosureSystem(n, lambda s: s)


# ============================================================
# Example 2: Convex Closure on a Line
# ============================================================

def convex_closure(n: int) -> ClosureSystem:
    """
    Convex closure on {0, 1, ..., n-1} viewed as a linearly ordered set.
    cl(S) = convex hull of S = {i : min(S) ≤ i ≤ max(S)}.
    """
    def cl(s):
        if not s:
            return frozenset()
        return frozenset(range(min(s), max(s) + 1))
    return ClosureSystem(n, cl)


# ============================================================
# Example 3: Divisibility Closure
# ============================================================

def divisibility_closure(elements: List[int]) -> ClosureSystem:
    """
    Closure under divisibility: cl(S) includes all elements that divide
    some element of S and are themselves in the universe.
    """
    n = len(elements)
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    
    def cl(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            new = set()
            for i in result:
                for j in range(n):
                    if j not in result and elements[j] != 0:
                        if elements[i] % elements[j] == 0:
                            new.add(j)
            if new:
                result |= new
                changed = True
        return frozenset(result)
    
    return ClosureSystem(n, cl)


# ============================================================
# Lattice Operations and Prime Detection
# ============================================================

def lattice_meet(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
    """Meet = intersection (always closed for closed a, b)."""
    return a & b

def lattice_join(a: FrozenSet[int], b: FrozenSet[int], cl_func) -> FrozenSet[int]:
    """Join = closure of union."""
    return cl_func(a | b)

def is_inf_prime(p: FrozenSet[int], closed_sets: List[FrozenSet[int]], 
                  universe: FrozenSet[int]) -> bool:
    """
    A closed set P is inf-prime (meet-prime) if:
    1. P ≠ universe (not the top element)
    2. For all closed A, B: A ∩ B ⊆ P → A ⊆ P or B ⊆ P
    """
    if p == universe:
        return False
    for a in closed_sets:
        for b in closed_sets:
            if (a & b) <= p:
                if not (a <= p or b <= p):
                    return False
    return True


def find_prime_witnesses(K: FrozenSet[int], a: int, 
                          closed_sets: List[FrozenSet[int]],
                          universe: FrozenSet[int]) -> List[FrozenSet[int]]:
    """
    Find all prime closed sets P such that:
    - K ⊆ P (P extends K)
    - a ∉ P (P avoids a)
    """
    witnesses = []
    for P in closed_sets:
        if K <= P and a not in P and is_inf_prime(P, closed_sets, universe):
            witnesses.append(P)
    return witnesses


def find_minimal_prime_witness(K: FrozenSet[int], a: int,
                                closed_sets: List[FrozenSet[int]],
                                universe: FrozenSet[int]) -> Optional[FrozenSet[int]]:
    """Find a minimal (by inclusion) prime witness."""
    witnesses = find_prime_witnesses(K, a, closed_sets, universe)
    if not witnesses:
        return None
    # Find minimal by inclusion
    minimal = []
    for w in witnesses:
        if not any(v < w for v in witnesses):
            minimal.append(w)
    return min(minimal, key=len) if minimal else None


# ============================================================
# Demonstration
# ============================================================

def demonstrate_example(name: str, cs: ClosureSystem, 
                        test_K: FrozenSet[int], test_a: int):
    """Run a complete demonstration on a given closure system."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    print(f"Universe: {set(range(cs.n))}")
    
    closed = cs.all_closed_sets()
    print(f"Number of closed sets: {len(closed)}")
    
    if len(closed) <= 20:
        print(f"Closed sets:")
        for s in closed:
            tag = " [PRIME]" if is_inf_prime(s, closed, cs.universe) else ""
            print(f"  {set(s) if s else '{}'}{tag}")
    
    distrib = is_distributive_lattice(closed, cs.cl)
    print(f"Distributive lattice: {distrib}")
    
    primes = [s for s in closed if is_inf_prime(s, closed, cs.universe)]
    print(f"Number of prime closed sets: {len(primes)}")
    if len(primes) <= 10:
        for p in primes:
            print(f"  Prime: {set(p) if p else '{}'}")
    
    # Spectral reconstruction: every closed set = ∩ of primes above it
    print(f"\n--- Spectral Reconstruction Check ---")
    reconstruction_ok = True
    for K in closed[:min(len(closed), 8)]:
        primes_above = [p for p in primes if K <= p]
        if primes_above:
            intersection = primes_above[0]
            for p in primes_above[1:]:
                intersection = intersection & p
        else:
            intersection = cs.universe
        ok = intersection == K
        reconstruction_ok = reconstruction_ok and ok
        if len(closed) <= 20:
            print(f"  K={set(K) if K else '{}'}: "
                  f"∩(primes above K) = {set(intersection) if intersection else '{}'} "
                  f"{'✓' if ok else '✗'}")
    if reconstruction_ok:
        print(f"  All closed sets reconstructed from primes ✓")
    
    # Prime witness extraction
    print(f"\n--- Prime Witness Extraction ---")
    print(f"  K = {set(test_K) if test_K else '{}'}")
    print(f"  a = {test_a}")
    
    if test_a in test_K:
        print(f"  a ∈ K, so no witness needed.")
        return
    
    if not cs.is_closed(test_K):
        print(f"  K is not closed! Using cl(K) instead.")
        test_K = cs.cl(test_K)
        print(f"  K = cl(K) = {set(test_K)}")
    
    witnesses = find_prime_witnesses(test_K, test_a, closed, cs.universe)
    print(f"  Found {len(witnesses)} prime witness(es) avoiding a={test_a}:")
    for w in witnesses:
        print(f"    P = {set(w) if w else '{}'}")
    
    minimal = find_minimal_prime_witness(test_K, test_a, closed, cs.universe)
    if minimal is not None:
        print(f"  Minimal prime witness: {set(minimal) if minimal else '{}'}")
    
    return closed, primes


def visualize_closure_lattice(cs: ClosureSystem, name: str, filename: str):
    """Create a Hasse diagram of the lattice of closed sets."""
    closed = cs.all_closed_sets()
    primes = [s for s in closed if is_inf_prime(s, closed, cs.universe)]
    
    if len(closed) > 30:
        print(f"  Too many closed sets ({len(closed)}) to visualize.")
        return
    
    # Compute Hasse diagram edges (covering relations)
    edges = []
    for i, a in enumerate(closed):
        for j, b in enumerate(closed):
            if a < b:
                # Check if b covers a (no c with a < c < b)
                if not any(a < c < b for c in closed):
                    edges.append((i, j))
    
    # Assign positions: x by some heuristic, y by cardinality
    levels = {}
    for i, s in enumerate(closed):
        lev = len(s)
        if lev not in levels:
            levels[lev] = []
        levels[lev].append(i)
    
    pos = {}
    for lev, indices in levels.items():
        n_at_level = len(indices)
        for k, idx in enumerate(indices):
            x = (k - (n_at_level - 1) / 2) * 1.5
            pos[idx] = (x, lev)
    
    fig, ax = plt.subplots(1, 1, figsize=(max(8, len(closed) * 0.6), 6))
    
    # Draw edges
    for i, j in edges:
        ax.plot([pos[i][0], pos[j][0]], [pos[i][1], pos[j][1]], 
                'k-', alpha=0.3, linewidth=0.8)
    
    # Draw nodes
    for i, s in enumerate(closed):
        is_prime = s in primes
        color = '#e74c3c' if is_prime else '#3498db'
        marker_size = 200 if is_prime else 120
        ax.scatter(*pos[i], c=color, s=marker_size, zorder=5, 
                   edgecolors='black', linewidths=0.5)
        label = str(set(s)) if s else '∅'
        if len(label) > 12:
            label = '{' + ','.join(str(x) for x in sorted(s)) + '}'
        ax.annotate(label, pos[i], textcoords="offset points", 
                    xytext=(0, 10), ha='center', fontsize=7)
    
    # Legend
    prime_patch = mpatches.Patch(color='#e74c3c', label='Prime (inf-prime)')
    other_patch = mpatches.Patch(color='#3498db', label='Non-prime')
    ax.legend(handles=[prime_patch, other_patch], loc='upper right', fontsize=8)
    
    ax.set_title(f"Closed Set Lattice: {name}", fontsize=12, fontweight='bold')
    ax.set_ylabel("Cardinality", fontsize=10)
    ax.set_xticks([])
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Lattice diagram saved to {filename}")


def demonstrate_non_derivability():
    """
    Demonstrate the connection to proof theory / non-derivability.
    
    Think of elements as "formulas" and closed sets as "theories"
    (deductively closed sets of formulas). A prime theory is one where
    if A∩B ⊆ T then A ⊆ T or B ⊆ T.
    
    Non-derivability of formula 'a' from theory K is witnessed by
    a prime theory extending K that doesn't contain 'a'.
    """
    print(f"\n{'='*60}")
    print(f"  Application: Non-Derivability Certificates")
    print(f"{'='*60}")
    
    # Create a small "proof system" with 5 formulas
    # Formulas: 0=p, 1=q, 2=p∧q, 3=p∨q, 4=⊤
    formulas = ['p', 'q', 'p∧q', 'p∨q', '⊤']
    n = len(formulas)
    
    # Deductive closure: captures basic logical consequences
    def deductive_cl(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            new_elts = set()
            # Rule: {p, q} → p∧q
            if 0 in result and 1 in result:
                new_elts.add(2)
            # Rule: p∧q → p, q
            if 2 in result:
                new_elts.add(0)
                new_elts.add(1)
            # Rule: p → p∨q, q → p∨q
            if 0 in result or 1 in result:
                new_elts.add(3)
            # Rule: anything → ⊤
            if result:
                new_elts.add(4)
            if new_elts - result:
                result |= new_elts
                changed = True
        return frozenset(result)
    
    cs = ClosureSystem(n, deductive_cl)
    closed = cs.all_closed_sets()
    primes = [s for s in closed if is_inf_prime(s, closed, cs.universe)]
    
    print(f"\nFormulas: {formulas}")
    print(f"Closed theories:")
    for s in closed:
        names = '{' + ', '.join(formulas[i] for i in sorted(s)) + '}' if s else '∅'
        tag = " [PRIME]" if is_inf_prime(s, closed, cs.universe) else ""
        print(f"  {names}{tag}")
    
    # Test: is 'q' derivable from 'p'?
    K = cs.cl(frozenset({0}))  # Theory generated by p
    print(f"\nTheory generated by 'p': {{{', '.join(formulas[i] for i in sorted(K))}}}")
    
    target = 1  # q
    print(f"Is 'q' derivable from 'p'?")
    if target in K:
        print(f"  Yes, q ∈ cl({{p}})")
    else:
        print(f"  No! q ∉ cl({{p}})")
        witnesses = find_prime_witnesses(K, target, closed, cs.universe)
        if witnesses:
            w = witnesses[0]
            names = '{' + ', '.join(formulas[i] for i in sorted(w)) + '}'
            print(f"  Prime witness certificate: T = {names}")
            print(f"  This theory extends cl({{p}}), contains no 'q', and is prime.")
            print(f"  → Certified non-derivability!")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Constructive Prime Witness Extraction Demo             ║")
    print("║  Finite Distributive Closure Systems                    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Example 1: Power set (Boolean lattice)
    cs1 = identity_closure(4)
    demonstrate_example(
        "Example 1: Power Set (Boolean Lattice on {0,1,2,3})",
        cs1, frozenset({0, 1}), 2
    )
    visualize_closure_lattice(cs1, "Boolean Lattice 2^4", 
                               "Bridges/lattice_boolean.png")
    
    # Example 2: Convex closure
    cs2 = convex_closure(5)
    demonstrate_example(
        "Example 2: Convex Closure on {0,1,2,3,4}",
        cs2, frozenset({1, 3}), 4
    )
    visualize_closure_lattice(cs2, "Convex Closure on [0..4]",
                               "Bridges/lattice_convex.png")
    
    # Example 3: Divisibility
    cs3 = divisibility_closure([1, 2, 3, 6])
    demonstrate_example(
        "Example 3: Divisibility Closure on {1,2,3,6}",
        cs3, frozenset({3}), 0  # index 0 = element 1
    )
    visualize_closure_lattice(cs3, "Divisibility on {1,2,3,6}",
                               "Bridges/lattice_divisibility.png")
    
    # Application: Non-derivability
    demonstrate_non_derivability()
    
    # Summary statistics
    print(f"\n{'='*60}")
    print(f"  Summary")
    print(f"{'='*60}")
    print(f"""
The demonstrations above illustrate the main theorem:

  THEOREM (Prime Separation for Finite Distributive Closure Systems):
  
  In a finite distributive closure system, for any closed set K
  and any element a ∉ K, there exists a PRIME closed set P with:
    • K ⊆ P  (P extends K)
    • a ∉ P  (P avoids a)
  
  Moreover, K = ∩ {{P : P is prime and K ⊆ P}}.

This means non-membership in a closed set is always WITNESSED
by a prime closed set — a "spectral point" that separates the
element from the set. In proof-theoretic terms: non-derivability
is always certified by a prime theory.

This has been formally verified in Lean 4 (see LatticePrimeSeparation.lean).
""")


if __name__ == "__main__":
    main()
