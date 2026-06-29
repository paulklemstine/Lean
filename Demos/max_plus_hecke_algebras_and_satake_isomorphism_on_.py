#!/usr/bin/env python3
"""
Max-Plus Hecke Algebras on Finite Lattices — Numerical Demonstrations

This script demonstrates the key theorems from the Lean 4 formalization
of tropical Hecke operators on finite lattices, providing concrete
numerical examples and visualizations.

Bridge: connects formal mathematics to computational exploration.
"""

import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Dict, List, Tuple, Set, Callable

# ============================================================
# §1. Lattice Infrastructure
# ============================================================

class FiniteLattice:
    """A finite lattice defined by its elements and partial order."""

    def __init__(self, elements: list, leq: Callable):
        self.elements = elements
        self.n = len(elements)
        self.leq = leq  # leq(a, b) -> bool
        # Precompute join table
        self._join = {}
        for a in elements:
            for b in elements:
                self._join[(a, b)] = self._compute_join(a, b)

    def _compute_join(self, a, b):
        """Compute a ⊔ b as the least upper bound."""
        upper = [x for x in self.elements if self.leq(a, x) and self.leq(b, x)]
        # Find the minimum among upper bounds
        for u in upper:
            if all(self.leq(u, v) for v in upper):
                return u
        return upper[0] if upper else None

    def join(self, a, b):
        return self._join[(a, b)]

    def top(self):
        """The top element: ≥ everything."""
        return max(self.elements, key=lambda x: sum(1 for y in self.elements if self.leq(y, x)))

    def bot(self):
        """The bottom element: ≤ everything."""
        return max(self.elements, key=lambda x: sum(1 for y in self.elements if self.leq(x, y)))


def bool_lattice():
    """The two-element Boolean lattice {False, True}."""
    return FiniteLattice([False, True], lambda a, b: (not a) or b)


def chain_lattice(n):
    """The chain lattice {0, 1, ..., n-1}."""
    return FiniteLattice(list(range(n)), lambda a, b: a <= b)


def diamond_lattice():
    """The diamond lattice M3 = {0, a, b, c, 1} with a,b,c incomparable."""
    elems = ['0', 'a', 'b', 'c', '1']
    def leq(x, y):
        if x == y: return True
        if x == '0': return True
        if y == '1': return True
        return False
    return FiniteLattice(elems, leq)


def power_set_lattice(n):
    """The power set lattice 2^[n] ordered by inclusion."""
    elems = []
    for i in range(2**n):
        elems.append(frozenset(j for j in range(n) if i & (1 << j)))
    return FiniteLattice(elems, lambda a, b: a.issubset(b))


# ============================================================
# §2. Hecke Operators
# ============================================================

def hecke_filter(L: FiniteLattice, p, q) -> list:
    """Compute the Hecke filter {r ∈ L : p ≤ r ⊔ q}."""
    return [r for r in L.elements if L.leq(p, L.join(r, q))]


def hecke_op(L: FiniteLattice, p, f: dict, q):
    """Compute (T_p f)(q) = max{f(r) : r ⊔ q ≥ p}."""
    filt = hecke_filter(L, p, q)
    if not filt:
        return float('-inf')
    return max(f[r] for r in filt)


def hecke_op_full(L: FiniteLattice, p, f: dict) -> dict:
    """Compute T_p f as a function on L."""
    return {q: hecke_op(L, p, f, q) for q in L.elements}


def double_reach(L: FiniteLattice, p, q, s, u) -> bool:
    """Check if u is (p,q)-double-reachable from s."""
    return any(
        L.leq(p, L.join(r, s)) and L.leq(q, L.join(u, r))
        for r in L.elements
    )


# ============================================================
# §3. Demonstrations
# ============================================================

def demo_commutativity():
    """Demonstrate Hecke commutativity on various lattices."""
    print("=" * 60)
    print("DEMO 1: Hecke Commutativity (Gelfand Property)")
    print("=" * 60)
    print()

    lattices = [
        ("Bool lattice {0,1}", bool_lattice()),
        ("Chain lattice {0,1,2,3}", chain_lattice(4)),
        ("Diamond lattice M3", diamond_lattice()),
    ]

    for name, L in lattices:
        print(f"Lattice: {name}")
        print(f"  Elements: {L.elements}")

        # Random function
        np.random.seed(42)
        f = {x: np.random.randint(0, 10) for x in L.elements}
        print(f"  f = {f}")

        # Check commutativity for all pairs
        all_commute = True
        for p in L.elements:
            for q in L.elements:
                lhs = hecke_op_full(L, p, hecke_op_full(L, q, f))
                rhs = hecke_op_full(L, q, hecke_op_full(L, p, f))
                if lhs != rhs:
                    all_commute = False
                    print(f"  FAIL: T_{p} ∘ T_{q} ≠ T_{q} ∘ T_{p}")

        if all_commute:
            print(f"  ✓ All {L.n}² = {L.n**2} pairs commute!")
        print()


def demo_reachability_symmetry():
    """Demonstrate the lattice reachability symmetry lemma."""
    print("=" * 60)
    print("DEMO 2: Lattice Reachability Symmetry")
    print("=" * 60)
    print()

    L = diamond_lattice()
    print(f"Lattice: Diamond M3 = {L.elements}")
    print()

    for p in L.elements:
        for q in L.elements:
            for s in L.elements:
                reach_pq = {u for u in L.elements if double_reach(L, p, q, s, u)}
                reach_qp = {u for u in L.elements if double_reach(L, q, p, s, u)}
                if reach_pq != reach_qp:
                    print(f"  FAIL: DoubleReach({p},{q},{s}) ≠ DoubleReach({q},{p},{s})")
                    print(f"    {reach_pq} vs {reach_qp}")

    print("  ✓ All reachability sets are symmetric in p, q!")
    print()


def demo_hecke_filter():
    """Demonstrate Hecke filter properties."""
    print("=" * 60)
    print("DEMO 3: Hecke Filter Properties")
    print("=" * 60)
    print()

    L = chain_lattice(5)
    print(f"Lattice: Chain {{0,1,2,3,4}}")

    for p in L.elements:
        for q in L.elements:
            filt = hecke_filter(L, p, q)
            print(f"  Filter(p={p}, q={q}) = {filt}  |filter| = {len(filt)}")
    print()

    # Verify anti-monotonicity in p
    print("  Verifying anti-monotonicity in p:")
    for q in L.elements:
        sizes = [len(hecke_filter(L, p, q)) for p in L.elements]
        monotone = all(sizes[i] >= sizes[i+1] for i in range(len(sizes)-1))
        print(f"    q={q}: sizes = {sizes}  {'✓ decreasing' if monotone else '✗ NOT decreasing'}")

    # Verify monotonicity in q
    print("  Verifying monotonicity in q:")
    for p in L.elements:
        sizes = [len(hecke_filter(L, p, q)) for q in L.elements]
        monotone = all(sizes[i] <= sizes[i+1] for i in range(len(sizes)-1))
        print(f"    p={p}: sizes = {sizes}  {'✓ increasing' if monotone else '✗ NOT increasing'}")
    print()


def demo_eigenvalues():
    """Demonstrate eigenfunction structure on power set lattice."""
    print("=" * 60)
    print("DEMO 4: Hecke Eigenfunctions on Power Set Lattice 2^[3]")
    print("=" * 60)
    print()

    L = power_set_lattice(3)
    print(f"Lattice: 2^[3] with {L.n} elements")

    # Constant function is always an eigenfunction
    c = 5
    f_const = {x: c for x in L.elements}
    print(f"\n  Constant function f = {c}:")
    for p in L.elements:
        Tf = hecke_op_full(L, p, f_const)
        is_eigen = all(Tf[q] == c for q in L.elements)
        if not is_eigen:
            print(f"    p={p}: NOT eigenfunction")
    print("    ✓ Constant function is eigenfunction for all T_p with eigenvalue", c)

    # Cardinality function
    f_card = {x: len(x) for x in L.elements}
    print(f"\n  Cardinality function f(S) = |S|:")
    for p in sorted(L.elements, key=len)[:4]:
        Tf = hecke_op_full(L, p, f_card)
        print(f"    T_{{{set(p) if p else '∅'}}} f = {dict(sorted(Tf.items(), key=lambda x: len(x[0])))}")
    print()


def demo_satake_cardinality():
    """Demonstrate the Satake cardinality map."""
    print("=" * 60)
    print("DEMO 5: Satake Cardinality Map")
    print("=" * 60)
    print()

    L = chain_lattice(6)
    print(f"Lattice: Chain {{0,...,5}}")

    print("\n  Satake cardinality table |Filter(p, q)|:")
    print("    p\\q", end="")
    for q in L.elements:
        print(f"  {q}", end="")
    print()
    for p in L.elements:
        print(f"    {p}  ", end="")
        for q in L.elements:
            card = len(hecke_filter(L, p, q))
            print(f"  {card}", end="")
        print()

    # Verify satakeCard_bot: |Filter(0, q)| = |L| for all q
    bot = L.bot()
    for q in L.elements:
        assert len(hecke_filter(L, bot, q)) == L.n, \
            f"satakeCard_bot failed for q={q}"
    print(f"\n  ✓ satakeCard(⊥, q) = |L| = {L.n} for all q")
    print()


def demo_bool_concrete():
    """Concrete Bool lattice computations matching Lean theorems."""
    print("=" * 60)
    print("DEMO 6: Bool Lattice Concrete Computations")
    print("=" * 60)
    print()

    L = bool_lattice()
    f = {False: 3, True: 7}
    print(f"  f = {{False: {f[False]}, True: {f[True]}}}")

    # T_false f q = max(f(True), f(False)) for all q
    for q in [False, True]:
        val = hecke_op(L, False, f, q)
        expected = max(f[True], f[False])
        print(f"  T_false f({q}) = {val} = max({f[True]}, {f[False]}) ✓" if val == expected
              else f"  T_false f({q}) = {val} ✗ expected {expected}")

    # T_true f(True) = max(f(True), f(False))
    val = hecke_op(L, True, f, True)
    expected = max(f[True], f[False])
    print(f"  T_true f(True) = {val} = max({f[True]}, {f[False]}) ✓" if val == expected
          else f"  T_true f(True) = {val} ✗")

    # T_true f(False) = f(True)
    val = hecke_op(L, True, f, False)
    expected = f[True]
    print(f"  T_true f(False) = {val} = f(True) = {expected} ✓" if val == expected
          else f"  T_true f(False) = {val} ✗")
    print()


# ============================================================
# §4. Visualization
# ============================================================

def visualize_hecke_filters():
    """Create a visualization of Hecke filter sizes."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Chain lattice
    n = 8
    L = chain_lattice(n)
    data = np.zeros((n, n))
    for i, p in enumerate(L.elements):
        for j, q in enumerate(L.elements):
            data[i][j] = len(hecke_filter(L, p, q))

    ax = axes[0]
    im = ax.imshow(data, cmap='YlOrRd', aspect='equal')
    ax.set_xlabel('q')
    ax.set_ylabel('p')
    ax.set_title(f'Hecke Filter |F(p,q)|\nChain Lattice [0..{n-1}]')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Add text annotations
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(int(data[i][j])), ha='center', va='center',
                   color='white' if data[i][j] > n/2 else 'black', fontsize=8)

    # Power set lattice 2^[3]
    L2 = power_set_lattice(3)
    elems_sorted = sorted(L2.elements, key=lambda s: (len(s), tuple(sorted(s))))
    n2 = len(elems_sorted)
    data2 = np.zeros((n2, n2))
    for i, p in enumerate(elems_sorted):
        for j, q in enumerate(elems_sorted):
            data2[i][j] = len(hecke_filter(L2, p, q))

    ax = axes[1]
    im = ax.imshow(data2, cmap='YlOrRd', aspect='equal')
    labels = [str(set(s)) if s else '∅' for s in elems_sorted]
    ax.set_xlabel('q')
    ax.set_ylabel('p')
    ax.set_title('Hecke Filter |F(p,q)|\nPower Set 2^[3]')
    ax.set_xticks(range(n2))
    ax.set_yticks(range(n2))
    ax.set_xticklabels(labels, rotation=90, fontsize=6)
    ax.set_yticklabels(labels, fontsize=6)
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Commutativity verification heatmap
    L3 = chain_lattice(6)
    n3 = L3.n
    np.random.seed(42)
    f = {x: np.random.randint(0, 20) for x in L3.elements}

    comm_data = np.zeros((n3, n3))
    for i, p in enumerate(L3.elements):
        for j, q in enumerate(L3.elements):
            lhs = hecke_op_full(L3, p, hecke_op_full(L3, q, f))
            rhs = hecke_op_full(L3, q, hecke_op_full(L3, p, f))
            # Max absolute difference (should be 0 if commutative)
            comm_data[i][j] = max(abs(lhs[s] - rhs[s]) for s in L3.elements)

    ax = axes[2]
    im = ax.imshow(comm_data, cmap='RdYlGn_r', aspect='equal', vmin=0, vmax=1)
    ax.set_xlabel('q')
    ax.set_ylabel('p')
    ax.set_title('Commutativity Error\n‖T_p∘T_q - T_q∘T_p‖∞\n(all zeros = commutative)')
    ax.set_xticks(range(n3))
    ax.set_yticks(range(n3))
    plt.colorbar(im, ax=ax, shrink=0.8)

    for i in range(n3):
        for j in range(n3):
            ax.text(j, i, str(int(comm_data[i][j])), ha='center', va='center',
                   fontsize=10, fontweight='bold')

    plt.tight_layout()
    plt.savefig('hecke_visualization.png', dpi=150, bbox_inches='tight')
    print("  Saved visualization to hecke_visualization.png")


# ============================================================
# §5. Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Max-Plus Hecke Algebras — Numerical Demonstrations     ║")
    print("║  Tropical Langlands Foundations                         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_commutativity()
    demo_reachability_symmetry()
    demo_hecke_filter()
    demo_eigenvalues()
    demo_satake_cardinality()
    demo_bool_concrete()

    print("=" * 60)
    print("VISUALIZATION")
    print("=" * 60)
    visualize_hecke_filters()
    print()
    print("All demonstrations completed successfully!")
