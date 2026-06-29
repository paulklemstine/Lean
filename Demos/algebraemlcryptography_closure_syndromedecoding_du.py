#!/usr/bin/env python3
"""
Closure–Syndrome Decoding Duality: Demonstration and Visualization

This script demonstrates the core constructions and theorems from the
closure–syndrome decoding duality theory:

1. Construction of closure-parity systems
2. Canonical Tanner hypergraph reconstruction
3. Syndrome computation and separation
4. Extremal generator identification
5. Parity capacity computation

All constructions are finite and computable, matching the formal theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
from typing import Dict, List, Set, Tuple, Optional
import json


# ============================================================
# §1. Core Data Structures
# ============================================================

class FinClosureOp:
    """A finite closure operator on subsets of a finite set."""

    def __init__(self, universe: Set[int], cl_func):
        self.universe = universe
        self._cl = cl_func

    def cl(self, s: frozenset) -> frozenset:
        return self._cl(s)

    def is_closed(self, s: frozenset) -> bool:
        return self.cl(s) == s

    @staticmethod
    def identity(universe: Set[int]) -> 'FinClosureOp':
        """The identity closure: cl(S) = S."""
        return FinClosureOp(universe, lambda s: s)

    @staticmethod
    def from_implications(universe: Set[int],
                          implications: List[Tuple[frozenset, frozenset]]) -> 'FinClosureOp':
        """Closure operator from a set of implications {A} -> {B}."""
        def cl(s: frozenset) -> frozenset:
            result = set(s)
            changed = True
            while changed:
                changed = False
                for ant, cons in implications:
                    if ant.issubset(result) and not cons.issubset(result):
                        result.update(cons)
                        changed = True
            return frozenset(result)
        return FinClosureOp(universe, cl)


class ClosureParitySystem:
    """A closure-parity system: closure operator + parity observables."""

    def __init__(self, universe: Set[int], cl: FinClosureOp,
                 supports: Dict[str, frozenset],
                 weights: Dict[str, int]):
        self.universe = universe
        self.cl = cl
        self.supports = supports
        self.weights = weights

        # Verify supports are closed
        for name, supp in supports.items():
            assert cl.is_closed(supp), \
                f"Support of {name} is not closed: cl({supp}) = {cl.cl(supp)}"

    @property
    def active_obs(self) -> Set[str]:
        return {o for o, s in self.supports.items() if len(s) > 0}

    @property
    def is_separated(self) -> bool:
        supps = list(self.supports.values())
        return len(supps) == len(set(supps))

    @property
    def has_incomparable_supports(self) -> bool:
        active = [(o, s) for o, s in self.supports.items() if len(s) > 0]
        for i, (o1, s1) in enumerate(active):
            for j, (o2, s2) in enumerate(active):
                if i != j and s1.issubset(s2):
                    return False
        return True


class TannerHypergraph:
    """A Tanner hypergraph: bipartite incidence structure."""

    def __init__(self, check_nodes: Set[str],
                 incidence: Dict[str, frozenset],
                 check_weight: Dict[str, int]):
        self.check_nodes = check_nodes
        self.incidence = incidence
        self.check_weight = check_weight

    def realizes(self, sys: ClosureParitySystem) -> bool:
        """Check if this Tanner hypergraph realizes the given system."""
        # All active observables must be check nodes
        if not sys.active_obs.issubset(self.check_nodes):
            return False
        # Incidence and weights must match on check nodes
        for o in self.check_nodes:
            if self.incidence.get(o) != sys.supports.get(o):
                return False
            if self.check_weight.get(o) != sys.weights.get(o):
                return False
        return True


# ============================================================
# §2. Canonical Construction
# ============================================================

def canonical_tanner(sys: ClosureParitySystem) -> TannerHypergraph:
    """Construct the canonical minimal Tanner hypergraph."""
    return TannerHypergraph(
        check_nodes=sys.active_obs,
        incidence=dict(sys.supports),
        check_weight=dict(sys.weights)
    )


# ============================================================
# §3. Syndrome Computation
# ============================================================

def syndrome(sys: ClosureParitySystem, word: Dict[int, int], obs: str) -> int:
    """Compute the syndrome of a word at an observable."""
    return sum(word.get(a, 0) for a in sys.supports[obs])


def syndrome_vector(sys: ClosureParitySystem, word: Dict[int, int]) -> Dict[str, int]:
    """Compute the full syndrome vector."""
    return {o: syndrome(sys, word, o) for o in sys.supports}


# ============================================================
# §4. Parity Indicators and Extremality
# ============================================================

def parity_indicator(sys: ClosureParitySystem, obs: str) -> Dict[int, int]:
    """Compute the parity indicator vector for an observable."""
    return {a: sys.weights[obs] if a in sys.supports[obs] else 0
            for a in sys.universe}


def is_extremal_generator(sys: ClosureParitySystem, obs: str) -> bool:
    """Check if an observable is an extremal generator.

    An observable is extremal if its indicator cannot be written as
    a non-negative integer combination of other observables' indicators.
    """
    if not sys.supports[obs]:
        return False

    indicator = parity_indicator(sys, obs)
    other_obs = [o for o in sys.supports if o != obs]

    if not other_obs:
        return True

    # Check if indicator is in the cone of other indicators
    # This is a simple feasibility check via enumeration for small systems
    # For large systems, use LP
    other_indicators = [parity_indicator(sys, o) for o in other_obs]

    # Try small coefficients
    max_coeff = max(indicator.values()) + 1 if any(indicator.values()) else 1
    from itertools import product as iprod

    # For small systems, enumerate; for larger ones, use a heuristic
    n_others = len(other_obs)
    if n_others <= 6 and max_coeff <= 5:
        for coeffs in iprod(range(max_coeff + 1), repeat=n_others):
            match = True
            for a in sys.universe:
                val = sum(c * oi[a] for c, oi in zip(coeffs, other_indicators))
                if val != indicator[a]:
                    match = False
                    break
            if match:
                return False
        return True
    else:
        # Heuristic: check containment condition
        for o in other_obs:
            if sys.supports[o] and sys.supports[o].issubset(sys.supports[obs]):
                # Potential decomposition exists
                return False
        return True


def parity_capacity(sys: ClosureParitySystem, S: frozenset) -> int:
    """Compute the parity capacity of a set."""
    return sum(1 for o in sys.supports
               if sys.supports[o] and sys.supports[o].issubset(S))


# ============================================================
# §5. Demonstration Examples
# ============================================================

def demo_basic():
    """Basic demonstration of closure-parity system and canonical Tanner."""
    print("=" * 60)
    print("DEMO 1: Basic Closure-Parity System")
    print("=" * 60)

    universe = {0, 1, 2, 3}
    cl = FinClosureOp.identity(universe)

    supports = {
        'o1': frozenset({0, 1}),
        'o2': frozenset({2, 3}),
        'o3': frozenset({0, 2}),
    }
    weights = {'o1': 1, 'o2': 1, 'o3': 2}

    sys = ClosureParitySystem(universe, cl, supports, weights)

    print(f"Universe: {universe}")
    print(f"Observables: {list(supports.keys())}")
    for o, s in supports.items():
        print(f"  {o}: support={set(s)}, weight={weights[o]}")
    print(f"Active observables: {sys.active_obs}")
    print(f"Separated: {sys.is_separated}")
    print(f"Incomparable supports: {sys.has_incomparable_supports}")

    # Canonical Tanner
    T = canonical_tanner(sys)
    print(f"\nCanonical Tanner hypergraph:")
    print(f"  Check nodes: {T.check_nodes}")
    print(f"  Realizes system: {T.realizes(sys)}")

    # Syndrome computation
    word = {0: 1, 1: 0, 2: 1, 3: 0}
    sv = syndrome_vector(sys, word)
    print(f"\nWord: {word}")
    print(f"Syndrome vector: {sv}")

    # Extremal generators
    print(f"\nExtremal generators:")
    for o in supports:
        ext = is_extremal_generator(sys, o)
        print(f"  {o}: extremal={ext}")

    # Parity capacity
    for S in [frozenset({0, 1}), frozenset({0, 1, 2}), frozenset(universe)]:
        print(f"  Parity capacity of {set(S)}: {parity_capacity(sys, S)}")

    return sys, T


def demo_implication_closure():
    """Demonstration with non-trivial closure operator."""
    print("\n" + "=" * 60)
    print("DEMO 2: Closure from Implications")
    print("=" * 60)

    universe = {0, 1, 2, 3, 4}
    # Implications: {0} -> {1}, {2} -> {3,4}
    implications = [
        (frozenset({0}), frozenset({0, 1})),
        (frozenset({2}), frozenset({2, 3, 4})),
    ]
    cl = FinClosureOp.from_implications(universe, implications)

    print(f"Universe: {universe}")
    print(f"Implications: {{0}} → {{0,1}}, {{2}} → {{2,3,4}}")
    print(f"cl({{0}}) = {set(cl.cl(frozenset({0})))}")
    print(f"cl({{2}}) = {set(cl.cl(frozenset({2})))}")
    print(f"cl({{0,2}}) = {set(cl.cl(frozenset({0,2})))}")

    # Closed supports
    supports = {
        'p1': frozenset({0, 1}),        # cl({0}) = {0,1}
        'p2': frozenset({2, 3, 4}),      # cl({2}) = {2,3,4}
        'p3': frozenset({0, 1, 2, 3, 4}), # full set
    }
    weights = {'p1': 1, 'p2': 2, 'p3': 1}

    sys = ClosureParitySystem(universe, cl, supports, weights)
    T = canonical_tanner(sys)

    print(f"\nClosure-parity system:")
    for o, s in supports.items():
        closed = cl.is_closed(s)
        print(f"  {o}: support={set(s)}, weight={weights[o]}, closed={closed}")

    print(f"Separated: {sys.is_separated}")
    print(f"Incomparable supports: {sys.has_incomparable_supports}")

    print(f"\nCanonical Tanner: {T.check_nodes}")
    print(f"Realizes: {T.realizes(sys)}")

    # Test syndrome separation
    w1 = {0: 1, 1: 0, 2: 0, 3: 0, 4: 0}
    w2 = {0: 0, 1: 0, 2: 1, 3: 0, 4: 0}
    print(f"\nSyndrome of {w1}: {syndrome_vector(sys, w1)}")
    print(f"Syndrome of {w2}: {syndrome_vector(sys, w2)}")

    return sys, T


def demo_syndrome_separation():
    """Demonstrate syndrome separation property."""
    print("\n" + "=" * 60)
    print("DEMO 3: Syndrome Separation")
    print("=" * 60)

    universe = {0, 1, 2, 3, 4, 5}
    cl = FinClosureOp.identity(universe)

    supports = {
        f'o{i}': frozenset({i, (i+1) % 6})
        for i in range(6)
    }
    weights = {f'o{i}': 1 for i in range(6)}

    sys = ClosureParitySystem(universe, cl, supports, weights)

    print(f"Circular code on {universe}")
    for o, s in supports.items():
        print(f"  {o}: support={set(s)}")
    print(f"Separated: {sys.is_separated}")

    # Show that distinct observables can be distinguished by syndromes
    print(f"\nSyndrome separation test:")
    for o1, o2 in [('o0', 'o1'), ('o0', 'o3'), ('o1', 'o4')]:
        found = False
        for a in universe:
            w = {x: (1 if x == a else 0) for x in universe}
            s1 = syndrome(sys, w, o1)
            s2 = syndrome(sys, w, o2)
            if s1 != s2:
                print(f"  {o1} vs {o2}: word={w} gives syn({o1})={s1}, syn({o2})={s2}")
                found = True
                break
        if not found:
            print(f"  {o1} vs {o2}: NOT separated (supports equal?)")

    return sys


def demo_minimality():
    """Demonstrate minimality of canonical construction."""
    print("\n" + "=" * 60)
    print("DEMO 4: Minimality of Canonical Construction")
    print("=" * 60)

    universe = {0, 1, 2, 3}
    cl = FinClosureOp.identity(universe)

    supports = {
        'a': frozenset({0, 1}),
        'b': frozenset({2, 3}),
        'c': frozenset({0, 3}),
        'd': frozenset(),  # inactive observable
    }
    weights = {'a': 1, 'b': 1, 'c': 1, 'd': 0}

    sys = ClosureParitySystem(universe, cl, supports, weights)
    T_canonical = canonical_tanner(sys)

    print(f"System with {len(supports)} observables, {len(sys.active_obs)} active")
    print(f"Canonical Tanner: {len(T_canonical.check_nodes)} check nodes")
    print(f"Active observables: {sys.active_obs}")

    # Non-minimal realization (adding the inactive observable as a check node)
    T_non_minimal = TannerHypergraph(
        check_nodes=set(supports.keys()),  # includes 'd'
        incidence=dict(supports),
        check_weight=dict(weights)
    )
    print(f"\nNon-minimal realization: {len(T_non_minimal.check_nodes)} check nodes")
    print(f"  Realizes system: {T_non_minimal.realizes(sys)}")
    print(f"  Canonical is smaller: {len(T_canonical.check_nodes)} < {len(T_non_minimal.check_nodes)}")

    return sys


# ============================================================
# §6. Visualization
# ============================================================

def visualize_tanner_graph(sys: ClosureParitySystem, T: TannerHypergraph,
                           filename: str = 'tanner_graph.png'):
    """Visualize the Tanner hypergraph as a bipartite graph."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    var_nodes = sorted(sys.universe)
    check_nodes = sorted(T.check_nodes)

    n_var = len(var_nodes)
    n_check = len(check_nodes)

    # Position variable nodes on the left
    var_positions = {v: (0, i * 1.5) for i, v in enumerate(var_nodes)}
    # Position check nodes on the right
    check_positions = {c: (4, i * 1.5 + 0.5) for i, c in enumerate(check_nodes)}

    # Draw edges
    colors = plt.cm.Set2(np.linspace(0, 1, n_check))
    for i, c in enumerate(check_nodes):
        supp = T.incidence.get(c, frozenset())
        for v in supp:
            vp = var_positions[v]
            cp = check_positions[c]
            ax.plot([vp[0], cp[0]], [vp[1], cp[1]], '-',
                   color=colors[i], alpha=0.6, linewidth=2)

    # Draw variable nodes
    for v, pos in var_positions.items():
        circle = plt.Circle(pos, 0.25, color='steelblue', ec='black', zorder=5)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], str(v), ha='center', va='center',
               fontsize=12, fontweight='bold', color='white', zorder=6)

    # Draw check nodes
    for c, pos in check_positions.items():
        rect = mpatches.FancyBboxPatch((pos[0]-0.35, pos[1]-0.25), 0.7, 0.5,
                                        boxstyle="round,pad=0.1",
                                        facecolor='coral', edgecolor='black',
                                        zorder=5)
        ax.add_patch(rect)
        wt = T.check_weight.get(c, 0)
        ax.text(pos[0], pos[1], f'{c}\nw={wt}', ha='center', va='center',
               fontsize=9, fontweight='bold', zorder=6)

    ax.set_xlim(-1, 5.5)
    ax.set_ylim(-1, max(n_var, n_check) * 1.5 + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Canonical Minimal Tanner Hypergraph', fontsize=14, fontweight='bold')

    # Labels
    ax.text(-0.5, -0.7, 'Variable Nodes', ha='center', fontsize=11, style='italic')
    ax.text(4, -0.7, 'Check Nodes', ha='center', fontsize=11, style='italic')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Tanner graph saved to {filename}")
    return filename


def visualize_syndrome_heatmap(sys: ClosureParitySystem,
                                filename: str = 'syndrome_heatmap.png'):
    """Visualize syndrome vectors for all unit words."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    var_nodes = sorted(sys.universe)
    obs_list = sorted(sys.supports.keys())

    # Compute syndrome matrix: rows = unit words, cols = observables
    matrix = np.zeros((len(var_nodes), len(obs_list)))
    for i, v in enumerate(var_nodes):
        word = {x: (1 if x == v else 0) for x in sys.universe}
        for j, o in enumerate(obs_list):
            matrix[i, j] = syndrome(sys, word, o)

    im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto')
    ax.set_xticks(range(len(obs_list)))
    ax.set_xticklabels(obs_list, rotation=45, ha='right')
    ax.set_yticks(range(len(var_nodes)))
    ax.set_yticklabels([f'e_{v}' for v in var_nodes])
    ax.set_xlabel('Observable', fontsize=12)
    ax.set_ylabel('Unit Word', fontsize=12)
    ax.set_title('Syndrome Matrix: syn(e_v, o)', fontsize=14, fontweight='bold')

    # Add value annotations
    for i in range(len(var_nodes)):
        for j in range(len(obs_list)):
            ax.text(j, i, f'{int(matrix[i,j])}', ha='center', va='center',
                   fontsize=10, color='black' if matrix[i,j] < 1.5 else 'white')

    plt.colorbar(im, ax=ax, label='Syndrome Value')
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Syndrome heatmap saved to {filename}")
    return filename


def visualize_parity_capacity(sys: ClosureParitySystem,
                               filename: str = 'parity_capacity.png'):
    """Visualize parity capacity for all subsets."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 5))

    var_nodes = sorted(sys.universe)

    # Compute capacity for subsets of each size
    sizes = range(len(var_nodes) + 1)
    capacities_by_size = {s: [] for s in sizes}

    for size in sizes:
        for subset in combinations(var_nodes, size):
            fs = frozenset(subset)
            cap = parity_capacity(sys, fs)
            capacities_by_size[size].append(cap)

    # Box plot of capacities by subset size
    data = [capacities_by_size[s] for s in sizes if capacities_by_size[s]]
    labels = [str(s) for s in sizes if capacities_by_size[s]]

    bp = ax.boxplot(data, labels=labels, patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('lightblue')

    ax.set_xlabel('Subset Size', fontsize=12)
    ax.set_ylabel('Parity Capacity', fontsize=12)
    ax.set_title('Parity Capacity vs. Subset Size (Monotonicity)', fontsize=14,
                fontweight='bold')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Parity capacity plot saved to {filename}")
    return filename


# ============================================================
# §7. Main Execution
# ============================================================

if __name__ == '__main__':
    # Run all demos
    sys1, T1 = demo_basic()
    sys2, T2 = demo_implication_closure()
    sys3 = demo_syndrome_separation()
    sys4 = demo_minimality()

    # Generate visualizations
    print("\n" + "=" * 60)
    print("GENERATING VISUALIZATIONS")
    print("=" * 60)

    visualize_tanner_graph(sys1, T1, 'tanner_graph.png')
    visualize_syndrome_heatmap(sys1, 'syndrome_heatmap.png')
    visualize_parity_capacity(sys1, 'parity_capacity.png')

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
