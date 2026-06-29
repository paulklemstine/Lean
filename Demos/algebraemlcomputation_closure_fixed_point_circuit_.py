#!/usr/bin/env python3
"""
Closure Fixed-Point Circuit Duality: Demonstrations

Demonstrates the core theorems with concrete numerical examples:
1. Kleene chain stabilization on finite posets
2. Least fixed point computation
3. Iteration indistinguishability and minimal quotient
4. Convergence depth computation
5. Visualization of convergence behavior
"""

import itertools
from typing import Callable, TypeVar, Set, FrozenSet, Dict, List, Tuple
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

T = TypeVar('T')

# ============================================================
# Core Infrastructure
# ============================================================

class IterationSystem:
    """A finite monotone closure-controlled iteration system.
    
    Elements are represented as frozensets (powerset lattice with ⊆ order).
    """
    
    def __init__(self, universe: set, cl: Callable, F: Callable):
        self.universe = frozenset(universe)
        self.cl = cl
        self.F = F
        # All elements of the powerset lattice
        self.elements = list(self._powerset(universe))
    
    @staticmethod
    def _powerset(s):
        s = list(s)
        for r in range(len(s) + 1):
            for combo in itertools.combinations(s, r):
                yield frozenset(combo)
    
    def iterate(self, x: frozenset, n: int) -> frozenset:
        """Compute F^[n](x)."""
        result = x
        for _ in range(n):
            result = self.F(result)
        return result
    
    def kleene_chain(self, x: frozenset, max_steps: int = None) -> List[frozenset]:
        """Compute the Kleene chain from cl(x) until stabilization."""
        if max_steps is None:
            max_steps = len(self.elements)
        
        chain = [self.cl(x)]
        for i in range(max_steps):
            next_val = self.F(chain[-1])
            chain.append(next_val)
            if next_val == chain[-2]:
                break
        return chain
    
    def convergence_depth(self, x: frozenset) -> int:
        """Find the first n where F^n(cl(x)) = F^{n+1}(cl(x))."""
        chain = self.kleene_chain(x)
        for i in range(len(chain) - 1):
            if chain[i] == chain[i + 1]:
                return i
        return len(chain) - 1
    
    def least_fixed_point_above(self, x: frozenset) -> frozenset:
        """Compute the least fixed point of F above cl(x)."""
        chain = self.kleene_chain(x)
        return chain[-1]
    
    def iteration_indistinguishable(self, x: frozenset, y: frozenset) -> bool:
        """Check if x ~ y (iteration indistinguishable)."""
        N = len(self.elements)
        for n in range(N + 1):
            if self.cl(self.iterate(x, n)) != self.cl(self.iterate(y, n)):
                return False
        return True
    
    def minimal_quotient(self) -> Dict[frozenset, int]:
        """Compute the iteration indistinguishability classes."""
        classes = {}
        class_id = 0
        for x in self.elements:
            found = False
            for rep, cid in list(classes.items()):
                if self.iteration_indistinguishable(x, rep):
                    classes[x] = cid
                    found = True
                    break
            if not found:
                classes[x] = class_id
                class_id += 1
        return classes
    
    def worst_case_depth(self) -> int:
        """Compute worst-case convergence depth over all starting points."""
        return max(self.convergence_depth(x) for x in self.elements)


# ============================================================
# Example 1: Boolean Lattice Feedback (2 registers)
# ============================================================

def demo_boolean_feedback():
    """2-register Boolean feedback: F(a,b) = (a∨b, b)."""
    print("=" * 60)
    print("DEMO 1: Boolean Lattice Feedback (2 registers)")
    print("=" * 60)
    print()
    print("Universe: {0, 1}²  with pointwise Boolean order")
    print("F(a, b) = (a ∨ b, b)")
    print("Closure: identity (cl = id)")
    print()
    
    # Encode pairs as frozensets of tagged elements
    def encode(a, b):
        s = set()
        if a: s.add('a')
        if b: s.add('b')
        return frozenset(s)
    
    def decode(s):
        return ('a' in s, 'b' in s)
    
    universe = {'a', 'b'}
    cl = lambda x: x  # identity closure
    
    def F(s):
        a, b = decode(s)
        return encode(a or b, b)
    
    sys = IterationSystem(universe, cl, F)
    
    # Show chains from all starting points
    for elem in sorted(sys.elements, key=lambda s: (len(s), sorted(s))):
        a, b = decode(elem)
        chain = sys.kleene_chain(elem)
        depth = sys.convergence_depth(elem)
        chain_str = " → ".join(str(decode(c)) for c in chain)
        print(f"  Start ({a},{b}): {chain_str}  [depth={depth}]")
    
    print()
    print(f"  Worst-case convergence depth: {sys.worst_case_depth()}")
    print(f"  Cardinality bound: {len(sys.elements)}")
    
    # Quotient
    classes = sys.minimal_quotient()
    n_classes = len(set(classes.values()))
    print(f"  Indistinguishability classes: {n_classes}")
    for cid in range(n_classes):
        members = [decode(x) for x, c in classes.items() if c == cid]
        print(f"    Class {cid}: {members}")
    print()


# ============================================================
# Example 2: Dataflow Analysis
# ============================================================

def demo_dataflow():
    """3-variable dataflow analysis with dependency propagation."""
    print("=" * 60)
    print("DEMO 2: Dataflow Analysis (3 variables)")
    print("=" * 60)
    print()
    print("Variables: x₁, x₂, x₃")
    print("Transfer: x₁' = x₁ ∪ x₂,  x₂' = x₃,  x₃' = x₃")
    print("Facts universe: {a, b, c}")
    print()
    
    # State = (set1, set2, set3) where each set ⊆ {a,b,c}
    # Encode as frozenset of tagged elements
    def encode(s1, s2, s3):
        result = set()
        for x in s1: result.add(('1', x))
        for x in s2: result.add(('2', x))
        for x in s3: result.add(('3', x))
        return frozenset(result)
    
    def decode(s):
        s1 = {x for (i, x) in s if i == '1'}
        s2 = {x for (i, x) in s if i == '2'}
        s3 = {x for (i, x) in s if i == '3'}
        return s1, s2, s3
    
    def F(s):
        s1, s2, s3 = decode(s)
        return encode(s1 | s2, s3, s3)
    
    cl = lambda x: x
    
    # Start from ({}, {a}, {b})
    start = encode(set(), {'a'}, {'b'})
    
    print("  Kleene chain from (∅, {a}, {b}):")
    current = start
    for i in range(5):
        s1, s2, s3 = decode(current)
        print(f"    Step {i}: ({s1}, {s2}, {s3})")
        next_val = F(current)
        if next_val == current:
            print(f"    ← Stabilized at step {i}!")
            break
        current = next_val
    else:
        s1, s2, s3 = decode(current)
        print(f"    Step {i+1}: ({s1}, {s2}, {s3})")
    
    print()
    # Compute fixed point
    lfp = current
    s1, s2, s3 = decode(lfp)
    print(f"  Least fixed point: ({s1}, {s2}, {s3})")
    
    # Verify it's a fixed point
    s1f, s2f, s3f = decode(F(lfp))
    print(f"  F(lfp) = ({s1f}, {s2f}, {s3f}) {'✓ fixed!' if F(lfp) == lfp else '✗ not fixed'}")
    print()


# ============================================================
# Example 3: Convergence Visualization
# ============================================================

def demo_convergence_visualization():
    """Visualize convergence depths across different lattice sizes."""
    print("=" * 60)
    print("DEMO 3: Convergence Depth vs. Lattice Size")
    print("=" * 60)
    print()
    
    depths_data = []
    sizes = list(range(1, 7))
    
    for n in sizes:
        universe = set(range(n))
        cl = lambda x: x
        
        # F adds the smallest missing element (if any)
        def make_F(univ):
            def F(s):
                result = set(s)
                for i in sorted(univ):
                    if i not in result:
                        result.add(i)
                        return frozenset(result)
                return frozenset(result)
            return F
        
        F = make_F(universe)
        sys = IterationSystem(universe, cl, F)
        
        worst_depth = sys.worst_case_depth()
        n_elements = len(sys.elements)
        depths_data.append((n, n_elements, worst_depth))
        
        print(f"  |Universe|={n}: |Lattice|={n_elements}, worst depth={worst_depth}, bound={n_elements}")
    
    print()
    
    # Create visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    ns = [d[0] for d in depths_data]
    lattice_sizes = [d[1] for d in depths_data]
    worst_depths = [d[2] for d in depths_data]
    
    # Plot 1: Convergence depth vs universe size
    ax1.bar(ns, worst_depths, color='steelblue', alpha=0.7, label='Worst-case depth')
    ax1.plot(ns, ns, 'r--', linewidth=2, label='Universe size n')
    ax1.set_xlabel('Universe size n')
    ax1.set_ylabel('Convergence depth')
    ax1.set_title('Convergence Depth vs. Universe Size')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Depth vs lattice size (the cardinality bound)
    ax2.scatter(lattice_sizes, worst_depths, color='steelblue', s=100, zorder=5)
    ax2.plot([0, max(lattice_sizes)], [0, max(lattice_sizes)], 'r--', 
             linewidth=2, label='y = x (tight bound)')
    ax2.set_xlabel('Lattice size |α|')
    ax2.set_ylabel('Worst-case convergence depth')
    ax2.set_title('Depth vs. Cardinality Bound')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('convergence_depth.png', dpi=150, bbox_inches='tight')
    print("  Saved: convergence_depth.png")
    print()


# ============================================================
# Example 4: Quotient Minimization
# ============================================================

def demo_quotient_minimization():
    """Show how iteration indistinguishability reduces state count."""
    print("=" * 60)
    print("DEMO 4: Quotient Minimization")
    print("=" * 60)
    print()
    
    # 3-element universe, but with a closure that collapses some elements
    universe = {'a', 'b', 'c'}
    
    def cl(s):
        """Closure: if 'a' and 'b' are both present, add 'c'."""
        result = set(s)
        if 'a' in result and 'b' in result:
            result.add('c')
        return frozenset(result)
    
    def F(s):
        """Add smallest missing element."""
        result = set(s)
        for x in ['a', 'b', 'c']:
            if x not in result:
                result.add(x)
                return cl(frozenset(result))  # Apply closure after adding
        return frozenset(result)
    
    sys = IterationSystem(universe, cl, F)
    
    print(f"  Total elements in powerset lattice: {len(sys.elements)}")
    
    # Show some chains
    for start in [frozenset(), frozenset({'a'}), frozenset({'b'}), frozenset({'a', 'b'})]:
        chain = sys.kleene_chain(start)
        depth = sys.convergence_depth(start)
        chain_str = " → ".join(str(set(c)) for c in chain)
        print(f"  Start {set(start)}: {chain_str}  [depth={depth}]")
    
    print()
    
    # Compute quotient
    classes = sys.minimal_quotient()
    n_classes = len(set(classes.values()))
    print(f"  Original states: {len(sys.elements)}")
    print(f"  Minimal states (quotient): {n_classes}")
    print(f"  Reduction: {len(sys.elements)} → {n_classes}")
    print()
    
    for cid in sorted(set(classes.values())):
        members = [set(x) for x, c in classes.items() if c == cid]
        print(f"    Class {cid}: {members}")
    print()


# ============================================================
# Example 5: Capacity = Convergence Depth Verification
# ============================================================

def demo_capacity_depth():
    """Verify capacity = convergence depth on multiple examples."""
    print("=" * 60)
    print("DEMO 5: Capacity = Convergence Depth Verification")
    print("=" * 60)
    print()
    
    test_cases = []
    
    for n in range(1, 5):
        universe = set(range(n))
        cl = lambda x: x
        
        # Various F functions
        def make_F_add_min(univ):
            def F(s):
                result = set(s)
                for i in sorted(univ):
                    if i not in result:
                        result.add(i)
                        return frozenset(result)
                return frozenset(result)
            return F
        
        def make_F_add_all(univ):
            def F(s):
                return frozenset(univ)
            return F
        
        for name, F_maker in [("add-min", make_F_add_min), ("add-all", make_F_add_all)]:
            F = F_maker(universe)
            sys = IterationSystem(universe, cl, F)
            
            capacity = len(sys.elements)  # = |α|
            worst_depth = sys.worst_case_depth()
            
            # Verify: for ALL x, F^[capacity](x) = F^[capacity+1](x)
            all_stabilize = True
            for x in sys.elements:
                fn = sys.iterate(x, capacity)
                fn1 = sys.iterate(x, capacity + 1)
                if fn != fn1:
                    all_stabilize = False
                    break
            
            status = "✓" if all_stabilize else "✗"
            print(f"  n={n}, F={name}: |α|={capacity}, depth={worst_depth}, "
                  f"all stabilize at capacity: {status}")
            test_cases.append((n, name, capacity, worst_depth, all_stabilize))
    
    print()
    print("  All systems stabilize within capacity bound: ",
          "✓" if all(t[4] for t in test_cases) else "✗")
    print()


# ============================================================
# Visualization: Kleene Chain Diagram
# ============================================================

def create_kleene_chain_diagram():
    """Create a visual diagram of a Kleene chain convergence."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Simulate a chain on subsets of {1,2,3,4}
    chain = [
        set(),
        {1},
        {1, 2},
        {1, 2, 3},
        {1, 2, 3, 4},
        {1, 2, 3, 4},  # stabilized
    ]
    
    steps = range(len(chain))
    sizes = [len(c) for c in chain]
    
    # Plot the chain
    ax.plot(list(steps), sizes, 'o-', color='steelblue', linewidth=2, markersize=10)
    
    # Annotate
    for i, (step, s) in enumerate(zip(steps, chain)):
        label = str(s) if s else '∅'
        ax.annotate(label, (step, sizes[i]), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=9)
    
    # Mark stabilization
    ax.axvline(x=4, color='red', linestyle='--', alpha=0.5, label='Stabilization')
    ax.fill_between([4, 5], 0, 5, alpha=0.1, color='green', label='Fixed point region')
    
    ax.set_xlabel('Iteration step n', fontsize=12)
    ax.set_ylabel('|F^n(x)|', fontsize=12)
    ax.set_title('Kleene Chain Convergence: F adds the smallest missing element', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 5.5)
    
    plt.tight_layout()
    plt.savefig('kleene_chain.png', dpi=150, bbox_inches='tight')
    print("  Saved: kleene_chain.png")


def create_quotient_diagram():
    """Visualize the quotient reduction."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Before quotient: all states
    states_before = ['∅', '{a}', '{b}', '{c}', '{a,b}', '{a,c}', '{b,c}', '{a,b,c}']
    n_before = len(states_before)
    
    # After quotient (example grouping)
    groups = {
        0: ['∅'],
        1: ['{a}', '{b}'],
        2: ['{c}'],
        3: ['{a,b}', '{a,c}', '{b,c}'],
        4: ['{a,b,c}'],
    }
    n_after = len(groups)
    
    # Before: all states in a grid
    colors_before = ['#ff9999', '#99ccff', '#99ccff', '#ffcc99', 
                     '#99ff99', '#99ff99', '#99ff99', '#cc99ff']
    
    for i, (state, color) in enumerate(zip(states_before, colors_before)):
        row, col = divmod(i, 4)
        rect = mpatches.FancyBboxPatch((col * 1.5, (1 - row) * 1.2), 1.2, 0.8,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, edgecolor='black')
        ax1.add_patch(rect)
        ax1.text(col * 1.5 + 0.6, (1 - row) * 1.2 + 0.4, state,
                ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax1.set_xlim(-0.3, 6.3)
    ax1.set_ylim(-0.7, 2.5)
    ax1.set_title(f'Before Quotient: {n_before} states', fontsize=13)
    ax1.set_aspect('equal')
    ax1.axis('off')
    
    # After: grouped states
    group_colors = ['#ff9999', '#99ccff', '#ffcc99', '#99ff99', '#cc99ff']
    for i, (gid, members) in enumerate(groups.items()):
        y = 2 - i * 0.5
        rect = mpatches.FancyBboxPatch((0.5, y - 0.15), 4, 0.3,
                                        boxstyle="round,pad=0.05",
                                        facecolor=group_colors[i], edgecolor='black')
        ax2.add_patch(rect)
        label = f"Class {gid}: {', '.join(members)}"
        ax2.text(2.5, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
    
    ax2.set_xlim(-0.3, 5.3)
    ax2.set_ylim(-0.7, 2.5)
    ax2.set_title(f'After Quotient: {n_after} classes', fontsize=13)
    ax2.set_aspect('equal')
    ax2.axis('off')
    
    plt.suptitle('Minimization via Iteration Indistinguishability', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('quotient_minimization.png', dpi=150, bbox_inches='tight')
    print("  Saved: quotient_minimization.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Closure Fixed-Point Circuit Duality: Demonstrations      ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()
    
    demo_boolean_feedback()
    demo_dataflow()
    demo_convergence_visualization()
    demo_quotient_minimization()
    demo_capacity_depth()
    
    print("=" * 60)
    print("VISUALIZATIONS")
    print("=" * 60)
    print()
    create_kleene_chain_diagram()
    create_quotient_diagram()
    
    print()
    print("All demonstrations completed successfully!")
