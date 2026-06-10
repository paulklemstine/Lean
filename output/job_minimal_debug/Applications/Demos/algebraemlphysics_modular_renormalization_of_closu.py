"""
Applications of Closure-Scale Spectral Duality

Demonstrates real-world applications of the transfer dynamics framework:
1. Terminal SCC decomposition in directed graphs (automata theory)
2. Coarse-graining in lattice models (physics)
3. Feature collapse analysis (machine learning)
"""

from algorithms import (
    ClosureScaleSystem, find_stabilization_index,
    compute_recurrent_core, compute_recurrent_classes,
    classify_element, compute_temporal_observable_class,
    compute_observable_boolean_algebra
)
from typing import Dict, List, Set, Tuple


# =============================================================
# Application 1: Terminal SCC Decomposition
# =============================================================

def terminal_scc_from_transfer(adjacency: Dict[str, str]) -> List[Set[str]]:
    """
    Compute terminal strongly connected components of a deterministic
    transition system using transfer dynamics.

    In a deterministic system (each state has exactly one successor),
    the terminal SCCs are exactly the recurrent classes of the
    transfer operator.

    Args:
        adjacency: Maps each state to its unique successor.

    Returns:
        List of terminal SCCs as sets.
    """
    elements = list(adjacency.keys())
    # Identity closure (no abstraction)
    cl = lambda x: x
    sigma = lambda x: adjacency[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)
    return [set(c) for c in compute_recurrent_classes(system)]


# =============================================================
# Application 2: Coarse-Graining in Lattice Models
# =============================================================

def lattice_coarse_graining(
    lattice_size: int,
    block_size: int,
) -> dict:
    """
    Demonstrate coarse-graining on a 1D lattice model.

    States are binary strings of length lattice_size.
    The scale map σ performs block averaging (majority vote in blocks).
    The closure cl applies a local smoothing rule.

    This models Kadanoff-style block spin renormalization.
    """
    import itertools

    n = lattice_size
    b = block_size
    assert n % b == 0, "Block size must divide lattice size"

    # States are tuples of 0/1
    elements = list(itertools.product([0, 1], repeat=n))

    def sigma(state):
        """Block majority vote."""
        new_state = []
        for i in range(0, n, b):
            block = state[i:i+b]
            majority = 1 if sum(block) > b / 2 else 0
            new_state.extend([majority] * b)
        return tuple(new_state)

    def cl(state):
        """Local smoothing: if neighbors agree, adopt their value."""
        result = list(state)
        for i in range(1, n - 1):
            if state[i-1] == state[i+1]:
                result[i] = state[i-1]
        return tuple(result)

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)

    # Verify absorption law
    axioms = system.verify_axioms()

    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    # Analyze the universality classes
    print(f"\n1D Lattice with {n} sites, block size {b}")
    print(f"Total states: {len(elements)}")
    print(f"Absorption law holds: {axioms['absorption']}")
    print(f"Core size: {len(core)}")
    print(f"Number of universality classes: {len(classes)}")

    # Show representative from each class
    for i, cls in enumerate(classes[:5]):  # Show first 5
        rep = next(iter(cls))
        print(f"  Class {i+1}: representative = {''.join(str(b) for b in rep)}, size = {len(cls)}")

    return {
        'core_size': len(core),
        'num_classes': len(classes),
        'classes': classes,
    }


# =============================================================
# Application 3: Feature Collapse in Neural Networks
# =============================================================

def feature_collapse_analysis(
    features: List[str],
    projection: Dict[str, str],
    normalization: Dict[str, str],
) -> dict:
    """
    Analyze feature collapse under repeated projection + normalization.

    In deep learning, features can collapse to a lower-dimensional
    manifold under repeated application of projection and normalization
    layers. The transfer dynamics framework reveals the "universality
    classes" of feature collapse.

    Args:
        features: List of feature names/labels.
        projection: Maps each feature to its projected version.
        normalization: Maps each feature to its normalized version.

    Returns:
        Analysis of the collapse dynamics.
    """
    cl = lambda x: normalization.get(x, x)
    sigma = lambda x: projection.get(x, x)

    system = ClosureScaleSystem(elements=features, cl=cl, sigma=sigma)

    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    results = {
        'total_features': len(features),
        'surviving_features': len(core),
        'collapse_ratio': 1 - len(core) / len(features),
        'universality_classes': len(classes),
        'classes': [set(c) for c in classes],
    }

    return results


if __name__ == "__main__":
    # Demo 1: Terminal SCC
    print("=" * 60)
    print("APPLICATION 1: Terminal SCC Decomposition")
    print("=" * 60)

    graph = {
        'A': 'B', 'B': 'C', 'C': 'A',  # cycle A→B→C→A
        'D': 'E', 'E': 'D',              # cycle D→E→D
        'F': 'A',                          # transient → cycle 1
        'G': 'D',                          # transient → cycle 2
        'H': 'F',                          # transient → transient → cycle 1
    }

    print(f"\nGraph: {graph}")
    sccs = terminal_scc_from_transfer(graph)
    print(f"Terminal SCCs: {sccs}")
    print(f"Number of terminal SCCs: {len(sccs)}")

    for x in sorted(graph.keys()):
        status, cls = classify_element(
            ClosureScaleSystem(list(graph.keys()), lambda x: x, lambda x: graph[x]),
            x
        )
        print(f"  {x}: {status}" + (f" → {set(cls)}" if cls else ""))

    # Demo 2: Lattice coarse-graining (small example)
    print("\n" + "=" * 60)
    print("APPLICATION 2: Lattice Coarse-Graining")
    print("=" * 60)

    result = lattice_coarse_graining(lattice_size=4, block_size=2)

    # Demo 3: Feature collapse
    print("\n" + "=" * 60)
    print("APPLICATION 3: Feature Collapse Analysis")
    print("=" * 60)

    features = ['f1', 'f2', 'f3', 'f4', 'f5', 'f6']
    projection = {'f1': 'f1', 'f2': 'f1', 'f3': 'f3', 'f4': 'f3', 'f5': 'f5', 'f6': 'f5'}
    normalization = {f: f for f in features}  # Identity normalization

    result = feature_collapse_analysis(features, projection, normalization)
    print(f"\nFeature collapse analysis:")
    print(f"  Total features: {result['total_features']}")
    print(f"  Surviving features: {result['surviving_features']}")
    print(f"  Collapse ratio: {result['collapse_ratio']:.1%}")
    print(f"  Universality classes: {result['universality_classes']}")
    print(f"  Classes: {result['classes']}")


"""
Demo: Finite Transfer Dynamics and Closure-Scale Spectral Duality

Demonstrates the core theorems with concrete numerical examples:
1. A 4-state system with 2 recurrent classes
2. A 6-state system with 3 recurrent classes and a nontrivial closure
3. Renormalization convergence visualization
"""

from algorithms import (
    ClosureScaleSystem, find_stabilization_index,
    compute_recurrent_core, compute_recurrent_classes,
    classify_element, compute_temporal_observable_class,
    renormalization_action, iterate_function,
    compute_observable_boolean_algebra
)


def demo_four_state():
    """
    Example 1: Four states, identity closure, two recurrent classes.

    States: {s1, s2, s3, s4}
    Closure: identity (everything is already "closed")
    Scale map σ: s1→s1, s2→s2, s3→s1, s4→s2
    Transfer T = cl∘σ: s1→s1, s2→s2, s3→s1, s4→s2

    Expected: Core = {s1, s2}, two singleton recurrent classes.
    """
    print("=" * 60)
    print("EXAMPLE 1: Four States, Two Recurrent Classes")
    print("=" * 60)

    elements = ['s1', 's2', 's3', 's4']
    cl = lambda x: x
    sigma = lambda x: {'s1': 's1', 's2': 's2', 's3': 's1', 's4': 's2'}[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)
    T = system.transfer

    print(f"\nTransfer map T:")
    for x in elements:
        print(f"  T({x}) = {T(x)}")

    N, core = find_stabilization_index(T, elements)
    print(f"\nStabilization at N = {N}")
    print(f"Recurrent core = {core}")

    classes = compute_recurrent_classes(system)
    print(f"Recurrent classes = {[set(c) for c in classes]}")
    print(f"Number of recurrent classes = {len(classes)}")

    for x in elements:
        status, cls = classify_element(system, x)
        if cls:
            print(f"  {x}: {status}, class = {set(cls)}")
        else:
            print(f"  {x}: {status}")

    # Temporal observables
    print(f"\nTemporal Boolean algebra has {2**len(classes)} elements")
    print("Atoms (= recurrent classes):")
    for i, cls in enumerate(classes):
        print(f"  Atom {i+1}: {set(cls)}")

    print()


def demo_six_state():
    """
    Example 2: Six states, nontrivial closure, three recurrent classes.

    States: {a, b, c, d, e, f}
    Closure: cl(d)=a, cl(e)=b, everything else fixed
    Scale map σ: a→a, b→c, c→b, d→a, e→b, f→c
    Transfer T = cl∘σ: a→a, b→c, c→b, d→a, e→b, f→c

    Expected: Core = {a, b, c}, classes = {{a}, {b, c}}.
    Wait, let's recalculate. T(a)=cl(σ(a))=cl(a)=a, T(b)=cl(σ(b))=cl(c)=c,
    T(c)=cl(σ(c))=cl(b)=b, T(d)=cl(σ(d))=cl(a)=a, T(e)=cl(σ(e))=cl(b)=b,
    T(f)=cl(σ(f))=cl(c)=c.

    After one step: range = {a, b, c}
    T on core: a→a, b→c, c→b (2-cycle)
    Classes: {a} and {b,c}
    """
    print("=" * 60)
    print("EXAMPLE 2: Six States, Nontrivial Closure, Two Classes")
    print("=" * 60)

    elements = ['a', 'b', 'c', 'd', 'e', 'f']

    def cl(x):
        return {'a': 'a', 'b': 'b', 'c': 'c', 'd': 'a', 'e': 'b', 'f': 'f'}[x]

    def sigma(x):
        return {'a': 'a', 'b': 'c', 'c': 'b', 'd': 'a', 'e': 'b', 'f': 'c'}[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)
    T = system.transfer

    # Verify axioms
    axioms = system.verify_axioms()
    print(f"\nAxiom verification: {axioms}")

    print(f"\nTransfer map T:")
    for x in elements:
        print(f"  T({x}) = {T(x)}")

    N, core = find_stabilization_index(T, elements)
    print(f"\nStabilization at N = {N}")
    print(f"Recurrent core = {core}")

    classes = compute_recurrent_classes(system)
    print(f"Recurrent classes = {[set(c) for c in classes]}")

    for x in elements:
        status, cls = classify_element(system, x)
        if cls:
            print(f"  {x}: {status}, class = {set(cls)}")
        else:
            print(f"  {x}: {status}")

    # Demonstrate Stone duality
    print(f"\n--- Stone-Transfer Duality ---")
    print(f"Temporal Boolean algebra B_T ≅ P(Spec_T)")
    print(f"|Spec_T| = {len(classes)}, |B_T| = {2**len(classes)}")

    # Example observables
    obs1 = lambda x: x in ('a',)
    obs2 = lambda x: x in ('b', 'c')
    obs3 = lambda x: True

    for name, obs in [("x ∈ {a}", obs1), ("x ∈ {b,c}", obs2), ("always true", obs3)]:
        tc = compute_temporal_observable_class(system, obs)
        print(f"  Observable '{name}' → classes {[set(c) for c in tc]}")

    print()


def demo_renormalization():
    """
    Example 3: Renormalization convergence.

    Shows how the renormalization action R_n(p) = p ∘ T^n converges
    to a fixed point on the recurrent core.
    """
    print("=" * 60)
    print("EXAMPLE 3: Renormalization Convergence")
    print("=" * 60)

    elements = list(range(8))

    # Closure: round up to nearest even
    def cl(x):
        return x if x % 2 == 0 else x + 1

    # Scale: divide by 2 (integer), staying in range
    def sigma(x):
        return min(x, 6)  # cap at 6

    # Actually let's use a simpler system for clarity
    elements = list(range(6))

    def cl(x):
        return x  # identity

    def sigma(x):
        # 0→0, 1→0, 2→3, 3→2, 4→0, 5→3
        return {0: 0, 1: 0, 2: 3, 3: 2, 4: 0, 5: 3}[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)
    T = system.transfer

    print(f"\nTransfer map T:")
    for x in elements:
        print(f"  T({x}) = {T(x)}")

    N, core = find_stabilization_index(T, elements)
    classes = compute_recurrent_classes(system)
    print(f"\nCore = {core}")
    print(f"Classes = {[set(c) for c in classes]}")

    # Show renormalization convergence
    p = lambda x: x >= 3  # "x is large"

    print(f"\nRenormalization of observable 'x ≥ 3':")
    print(f"{'n':>4} | {'R_n(p) on each element':>40}")
    print("-" * 50)

    for n in range(6):
        rn_p = renormalization_action(system, p, n)
        values = [rn_p(x) for x in elements]
        print(f"{n:>4} | {str(values):>40}")

    # Show convergence
    print(f"\nAfter stabilization, R_n(p) restricted to core is constant per class.")
    rN_p = renormalization_action(system, p, N + 5)
    for cls in classes:
        vals = {x: rN_p(x) for x in cls}
        print(f"  Class {set(cls)}: {vals}")

    print()


def demo_boolean_algebra():
    """
    Example 4: Explicit Boolean algebra structure.
    """
    print("=" * 60)
    print("EXAMPLE 4: Boolean Algebra of Temporal Observables")
    print("=" * 60)

    elements = ['a', 'b', 'c', 'd']
    cl = lambda x: x
    # a→a, b→c, c→b, d→a (one fixed point, one 2-cycle, one transient)
    sigma = lambda x: {'a': 'a', 'b': 'c', 'c': 'b', 'd': 'a'}[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)
    T = system.transfer

    print(f"\nTransfer map: ", {x: T(x) for x in elements})

    N, core = find_stabilization_index(T, elements)
    classes = compute_recurrent_classes(system)
    print(f"Core = {core}")
    print(f"Recurrent classes = {[set(c) for c in classes]}")

    algebra = compute_observable_boolean_algebra(system)
    print(f"\nBoolean algebra B_T has {len(algebra)} elements:")
    for i, (key, _) in enumerate(sorted(algebra.items(), key=lambda x: len(x[0]))):
        subset_str = "{" + ", ".join(str(set(c)) for c in key) + "}" if key else "∅"
        print(f"  {i}: {subset_str}")

    # Demonstrate Boolean operations
    print(f"\nBoolean operations (via set operations on Spec_T):")
    class_list = list(classes)
    if len(class_list) >= 2:
        A = frozenset([class_list[0]])
        B = frozenset([class_list[1]])
        print(f"  A = {{{set(class_list[0])}}}")
        print(f"  B = {{{set(class_list[1])}}}")
        print(f"  A ∨ B = {{{', '.join(str(set(c)) for c in A | B)}}}")
        print(f"  A ∧ B = {{{', '.join(str(set(c)) for c in A & B)}}}")
        print(f"  ¬A = {{{', '.join(str(set(c)) for c in frozenset(classes) - A)}}}")

    print()


if __name__ == "__main__":
    demo_four_state()
    demo_six_state()
    demo_renormalization()
    demo_boolean_algebra()


"""
Visualizations for Closure-Scale Spectral Duality.

Generates publication-quality figures showing:
1. Transfer dynamics convergence
2. Recurrent class decomposition
3. Boolean algebra structure
4. Renormalization flow
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    ClosureScaleSystem, find_stabilization_index,
    compute_recurrent_core, compute_recurrent_classes,
    iterate_function, renormalization_action
)

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'figure.facecolor': 'white',
})


def plot_transfer_convergence():
    """
    Plot the convergence of iterated ranges to the recurrent core.
    Shows |Im(T^n)| decreasing and stabilizing.
    """
    elements = list(range(10))
    # T: 0→0, 1→0, 2→3, 3→2, 4→0, 5→3, 6→0, 7→2, 8→3, 9→0
    mapping = {0:0, 1:0, 2:3, 3:2, 4:0, 5:3, 6:0, 7:2, 8:3, 9:0}
    T = lambda x: mapping[x]

    system = ClosureScaleSystem(elements=elements, cl=lambda x: x, sigma=T)

    sizes = []
    current = set(elements)
    for n in range(8):
        sizes.append(len(current))
        current = {T(x) for x in current}

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(range(len(sizes)), sizes, 'bo-', markersize=10, linewidth=2)
    ax.axhline(y=sizes[-1], color='r', linestyle='--', alpha=0.7, label=f'Core size = {sizes[-1]}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|Im(T^n)|')
    ax.set_title('Theorem A: Range Stabilization of Transfer Operator')
    ax.set_xticks(range(len(sizes)))
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('convergence.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved convergence.png")


def plot_recurrent_classes():
    """
    Visualize the decomposition into recurrent classes and transient states.
    """
    elements = list(range(8))
    mapping = {0:1, 1:2, 2:0, 3:4, 4:3, 5:0, 6:3, 7:5}
    T = lambda x: mapping[x]

    system = ClosureScaleSystem(elements=elements, cl=lambda x: x, sigma=T)

    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Position nodes in a circle
    n = len(elements)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    positions = {x: (1.5*np.cos(a), 1.5*np.sin(a)) for x, a in zip(elements, angles)}

    # Color by class membership
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    node_colors = []
    for x in elements:
        if x in core:
            for i, cls in enumerate(classes):
                if x in cls:
                    node_colors.append(colors[i % len(colors)])
                    break
        else:
            node_colors.append('#bdc3c7')

    # Draw edges
    for x in elements:
        x_pos = positions[x]
        y_pos = positions[T(x)]
        dx = y_pos[0] - x_pos[0]
        dy = y_pos[1] - x_pos[1]
        if x != T(x):
            ax.annotate("", xy=(y_pos[0]-0.15*dx/max(abs(dx+0.01),abs(dy+0.01)),
                                y_pos[1]-0.15*dy/max(abs(dx+0.01),abs(dy+0.01))),
                        xytext=x_pos,
                        arrowprops=dict(arrowstyle="->", color='gray', lw=1.5))
        else:
            # Self-loop
            circle = mpatches.Arc(
                (x_pos[0], x_pos[1]+0.3), 0.4, 0.4, angle=0,
                theta1=30, theta2=330, color='gray', lw=1.5
            )
            ax.add_patch(circle)

    # Draw nodes
    for i, x in enumerate(elements):
        circle = plt.Circle(positions[x], 0.2, color=node_colors[i],
                           ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(positions[x][0], positions[x][1], str(x),
               ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)

    # Legend
    legend_elements = []
    for i, cls in enumerate(classes):
        legend_elements.append(
            mpatches.Patch(color=colors[i % len(colors)],
                          label=f'Class {i+1}: {set(cls)}')
        )
    legend_elements.append(
        mpatches.Patch(color='#bdc3c7', label='Transient states')
    )
    ax.legend(handles=legend_elements, loc='upper right')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title('Theorem B: Recurrent Class Decomposition (Spec_T)')
    ax.axis('off')
    fig.tight_layout()
    fig.savefig('recurrent_classes.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved recurrent_classes.png")


def plot_boolean_algebra():
    """
    Visualize the Boolean algebra of temporal observables
    as a Hasse diagram of P(Spec_T).
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # For a system with 3 recurrent classes, the Boolean algebra has 8 elements
    classes = ['{a}', '{b,c}', '{d}']
    n = len(classes)

    # Positions for Hasse diagram of P({1,2,3})
    levels = {
        0: [frozenset()],
        1: [frozenset([0]), frozenset([1]), frozenset([2])],
        2: [frozenset([0,1]), frozenset([0,2]), frozenset([1,2])],
        3: [frozenset([0,1,2])],
    }

    positions = {}
    y_spacing = 1.5
    for level, sets in levels.items():
        x_start = -(len(sets) - 1) / 2
        for i, s in enumerate(sets):
            positions[s] = (x_start + i, level * y_spacing)

    # Draw edges (cover relations)
    for level in range(3):
        for s_lower in levels[level]:
            for s_upper in levels[level + 1]:
                if s_lower < s_upper and len(s_upper) == len(s_lower) + 1:
                    p1 = positions[s_lower]
                    p2 = positions[s_upper]
                    ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'k-', lw=1.5, alpha=0.5)

    # Draw nodes
    colors_list = ['#ecf0f1', '#e74c3c', '#3498db', '#2ecc71',
                   '#f39c12', '#9b59b6', '#1abc9c', '#e67e22']
    for i, (s, pos) in enumerate(positions.items()):
        circle = plt.Circle(pos, 0.35, color=colors_list[i],
                           ec='black', lw=2, zorder=5)
        ax.add_patch(circle)

        if len(s) == 0:
            label = '∅'
        elif len(s) == 3:
            label = 'C'
        else:
            label = '∪'.join(classes[j] for j in sorted(s))

        fontsize = 7 if len(label) > 5 else 9
        ax.text(pos[0], pos[1], label, ha='center', va='center',
               fontsize=fontsize, zorder=6)

    ax.set_xlim(-2, 2)
    ax.set_ylim(-1, 5.5)
    ax.set_aspect('equal')
    ax.set_title('Theorem C/D: B_T ≅ P(Spec_T)\nBoolean Algebra of Temporal Observables')
    ax.axis('off')
    fig.tight_layout()
    fig.savefig('boolean_algebra.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved boolean_algebra.png")


def plot_renormalization_flow():
    """
    Visualize the renormalization semigroup action converging to
    fixed observables on the core.
    """
    elements = list(range(6))
    mapping = {0:0, 1:0, 2:3, 3:2, 4:0, 5:3}
    T = lambda x: mapping[x]

    system = ClosureScaleSystem(elements=elements, cl=lambda x: x, sigma=T)

    # Observable: "x >= 3"
    p = lambda x: x >= 3

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: truth table evolution
    ax = axes[0]
    n_steps = 6
    truth_table = np.zeros((n_steps, len(elements)))

    for n in range(n_steps):
        rn_p = renormalization_action(system, p, n)
        for i, x in enumerate(elements):
            truth_table[n, i] = 1 if rn_p(x) else 0

    im = ax.imshow(truth_table, aspect='auto', cmap='RdYlGn',
                   interpolation='nearest', vmin=0, vmax=1)
    ax.set_xlabel('State x')
    ax.set_ylabel('Renormalization step n')
    ax.set_xticks(range(len(elements)))
    ax.set_xticklabels(elements)
    ax.set_yticks(range(n_steps))
    ax.set_title('R_n(p)(x) = p(T^n(x))\nObservable "x ≥ 3"')
    plt.colorbar(im, ax=ax, label='True/False')

    # Right: convergence of observable entropy
    ax = axes[1]
    # Track how many distinct truth values exist on each class
    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    variations = []
    for n in range(10):
        rn_p = renormalization_action(system, p, n)
        # Count variation: number of elements where R_n(p) differs from R_{n-1}(p)
        if n > 0:
            rn1_p = renormalization_action(system, p, n-1)
            diff = sum(1 for x in elements if rn_p(x) != rn1_p(x))
        else:
            diff = len(elements)  # maximal variation at start
        variations.append(diff)

    ax.bar(range(len(variations)), variations, color='steelblue', alpha=0.8)
    ax.set_xlabel('Step n')
    ax.set_ylabel('Number of changed values')
    ax.set_title('Theorem E: Renormalization Convergence\n|R_n(p) ⊕ R_{n-1}(p)|')
    ax.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    fig.savefig('renormalization_flow.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved renormalization_flow.png")


if __name__ == "__main__":
    plot_transfer_convergence()
    plot_recurrent_classes()
    plot_boolean_algebra()
    plot_renormalization_flow()
    print("\nAll visualizations saved.")
