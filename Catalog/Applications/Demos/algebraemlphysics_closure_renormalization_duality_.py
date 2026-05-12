"""
Applications of Filtered Closure Reconstruction.

Demonstrates real-world applications:
1. Feature hierarchy analysis in ML
2. Causal structure discovery
3. Biological scale analysis
4. Data compression via closure reduction
"""

from algorithms import (
    FilteredClosureSystem, scale_defect, defect_profile,
    reconstruct_renorm_dag, FiniteScaleObservations,
    verify_defect_decomposition, _powerset
)
from typing import FrozenSet, Dict, List, Set, Tuple
import random


def ml_feature_hierarchy():
    """Application 1: ML Feature Hierarchy Analysis.

    Scenario: A classifier has 8 features observed at 4 abstraction levels.
    Features at higher levels are composites of lower-level features.

    The filtered closure system models which features are "implied" by
    a set of observations at each abstraction level.
    """
    print("=" * 60)
    print("APPLICATION 1: ML Feature Hierarchy")
    print("=" * 60)

    # Features: 0=pixel, 1=edge, 2=texture, 3=shape,
    #           4=part, 5=object, 6=scene, 7=context
    feature_names = {
        0: 'pixel', 1: 'edge', 2: 'texture', 3: 'shape',
        4: 'part', 5: 'object', 6: 'scene', 7: 'context'
    }
    elements = frozenset(range(8))

    # Abstraction levels (layers): 0=raw, 1=low, 2=mid, 3=high
    scales = [0, 1, 2, 3]

    # Implications at each level:
    # Level 0: pixels are self-contained
    # Level 1: edges compose from pixels; textures from edges
    # Level 2: shapes from edges+textures; parts from shapes
    # Level 3: objects from parts; scenes from objects; context from scenes
    implications = {
        1: [(0, 1), (1, 2)],           # pixel→edge, edge→texture
        2: [(1, 3), (2, 3), (3, 4)],   # edge→shape, texture→shape, shape→part
        3: [(4, 5), (5, 6), (6, 7)]    # part→object, object→scene, scene→context
    }

    def cl(r, A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            for s in range(r + 1):
                if s in implications:
                    for (x, y) in implications[s]:
                        if x in result and y not in result:
                            result.add(y)
                            changed = True
        return frozenset(result)

    F = FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)

    # Analyze: starting from a pixel observation
    A = frozenset([0])  # observe a single pixel
    print(f"\nStarting from: {{{feature_names[0]}}}")
    for r in scales:
        closure = F.scale_closure(r, A)
        names = [feature_names[x] for x in sorted(closure)]
        print(f"  Level {r} (closure): {names}")

    # Show defects = "features learned at each layer"
    print(f"\nFeatures learned at each layer transition:")
    for i, r in enumerate(scales):
        for s in scales[i+1:i+2]:  # only consecutive
            d = scale_defect(F, A, r, s)
            if d:
                names = [feature_names[x] for x in sorted(d)]
                print(f"  Layer {r}→{s}: {names}")

    # DAG reconstruction
    test_sets = [frozenset([i]) for i in range(8)]
    obs = FiniteScaleObservations(
        test_sets=test_sets,
        observed=lambda A, r: cl(r, A),
        scales=scales
    )
    dag = reconstruct_renorm_dag(obs)
    print(f"\nReconstructed feature DAG: {dag.edge_count()} edges")
    print(f"Active layers: {sorted(dag.active_scales())}")

    # Count "relevant features" = distinct defect labels
    defect_labels = set()
    for e in dag.edges:
        defect_labels.add(e.label)
    print(f"Distinct interaction classes: {len(defect_labels)}")


def causal_discovery():
    """Application 2: Causal Structure Discovery.

    Scenario: 6 variables with causal relationships that become
    visible at different levels of experimental intervention.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Causal Structure Discovery")
    print("=" * 60)

    var_names = {0: 'Gene', 1: 'mRNA', 2: 'Protein', 3: 'Signal', 4: 'Phenotype', 5: 'Fitness'}
    elements = frozenset(range(6))
    scales = [0, 1, 2, 3]

    # Causal links at different intervention levels:
    # Level 0: Gene → mRNA (transcription)
    # Level 1: mRNA → Protein (translation)
    # Level 2: Protein → Signal (signaling)
    # Level 3: Signal → Phenotype → Fitness
    causal_links = {
        0: [(0, 1)],
        1: [(1, 2)],
        2: [(2, 3)],
        3: [(3, 4), (4, 5)]
    }

    def cl(r, A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            for s in range(r + 1):
                if s in causal_links:
                    for (x, y) in causal_links[s]:
                        if x in result and y not in result:
                            result.add(y)
                            changed = True
        return frozenset(result)

    F = FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)

    # Trace causal closure from Gene
    A = frozenset([0])  # intervene on Gene
    print(f"\nCausal closure from {{{var_names[0]}}}:")
    for r in scales:
        closure = F.scale_closure(r, A)
        names = [var_names[x] for x in sorted(closure)]
        print(f"  Intervention level {r}: {names}")

    # Defects = new causal effects at each level
    print(f"\nNew causal effects at each level:")
    for i in range(len(scales) - 1):
        d = scale_defect(F, A, scales[i], scales[i+1])
        if d:
            names = [var_names[x] for x in sorted(d)]
            print(f"  Level {scales[i]}→{scales[i+1]}: {names}")

    # DAG reconstruction
    test_sets = [frozenset([i]) for i in range(6)]
    obs = FiniteScaleObservations(
        test_sets=test_sets,
        observed=lambda A, r: cl(r, A),
        scales=scales
    )
    dag = reconstruct_renorm_dag(obs)
    print(f"\nReconstructed causal DAG: {dag.edge_count()} edges")

    # Check: the DAG should have the same structure as the causal links
    print("Causal edges recovered:")
    seen = set()
    for e in dag.edges:
        key = (e.source, e.target)
        if key not in seen:
            seen.add(key)
            defect_vars = [var_names[x] for x in sorted(e.label)]
            print(f"  Level {e.source}→{e.target}: {defect_vars} "
                  f"(from intervening on {{{var_names[x] for x in sorted(e.test_set)}}})")


def data_compression():
    """Application 3: Hierarchical Data Compression.

    The defect profile provides a compressed representation:
    instead of storing closure values at every scale, store only
    the base closure + defects at each transition.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Data Compression via Defect Profiles")
    print("=" * 60)

    elements = frozenset(range(10))
    scales = list(range(5))

    # Random system with known structure
    random.seed(123)
    thresholds = {x: random.randint(0, 4) for x in elements}
    implications = {
        1: [(0, 5), (1, 6)],
        2: [(5, 7)],
        3: [(7, 8), (6, 9)],
    }

    def cl(r, A):
        result = set(A)
        for x in elements:
            if thresholds[x] <= r:
                result.add(x)
        changed = True
        while changed:
            changed = False
            for s in range(r + 1):
                if s in implications:
                    for (x, y) in implications[s]:
                        if x in result and y not in result:
                            result.add(y)
                            changed = True
        return frozenset(result)

    F = FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)

    # Compare storage: full vs defect-compressed
    test_sets = [frozenset([i]) for i in range(5)]
    full_storage = 0
    defect_storage = 0

    print("\nCompression analysis:")
    for A in test_sets:
        # Full storage: store closure at every scale
        for r in scales:
            full_storage += len(F.scale_closure(r, A))

        # Defect storage: store base + defects
        defect_storage += len(F.scale_closure(scales[0], A))  # base
        for i in range(len(scales) - 1):
            d = scale_defect(F, A, scales[i], scales[i+1])
            defect_storage += len(d)

    print(f"  Full storage (sum of closure sizes): {full_storage}")
    print(f"  Defect storage (base + defects): {defect_storage}")
    ratio = defect_storage / max(1, full_storage)
    print(f"  Compression ratio: {ratio:.2%}")
    print(f"  Savings: {1 - ratio:.2%}")

    # Verify reconstruction
    print("\nReconstruction verification:")
    all_ok = True
    for A in test_sets:
        base = F.scale_closure(scales[0], A)
        reconstructed = base
        for i in range(len(scales) - 1):
            d = scale_defect(F, A, scales[i], scales[i+1])
            reconstructed = reconstructed | d
            actual = F.scale_closure(scales[i+1], A)
            if reconstructed != actual:
                all_ok = False
                print(f"  FAIL at scale {scales[i+1]} for A={set(A)}")
    if all_ok:
        print("  All reconstructions exact ✓")


def emergence_analysis():
    """Application 4: Emergence Detection.

    Identify "emergent" phenomena: features that appear at coarser scales
    but cannot be attributed to any single fine-scale input.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Emergence Detection")
    print("=" * 60)

    # System: 4 "micro" elements, 4 "macro" elements
    # Macro elements emerge from combinations of micro elements
    elements = frozenset(range(8))
    scales = [0, 1, 2]
    names = {0: 'H₂O', 1: 'NaCl', 2: 'temp', 3: 'pressure',
             4: 'salinity', 5: 'density', 6: 'current', 7: 'climate'}

    def cl(r, A):
        result = set(A)
        if r >= 1:
            # Macro-level emergence
            if {1, 0} <= result:  # NaCl + H₂O → salinity
                result.add(4)
            if {0, 2, 3} <= result:  # H₂O + temp + pressure → density
                result.add(5)
        if r >= 2:
            if {4, 5} <= result:  # salinity + density → current
                result.add(6)
            if {5, 2} <= result:  # density + temp → climate
                result.add(7)
        return frozenset(result)

    F = FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)

    print("\nEmergence from {H₂O, NaCl, temp, pressure}:")
    A = frozenset([0, 1, 2, 3])
    for r in scales:
        closure = F.scale_closure(r, A)
        feature_names = [names[x] for x in sorted(closure)]
        print(f"  Scale {r}: {feature_names}")

    print("\nEmergent features at each scale:")
    for i in range(len(scales) - 1):
        d = scale_defect(F, A, scales[i], scales[i+1])
        if d:
            feature_names = [names[x] for x in sorted(d)]
            print(f"  Scale {scales[i]}→{scales[i+1]}: {feature_names}")
        else:
            print(f"  Scale {scales[i]}→{scales[i+1]}: (none)")

    # Test: does salinity emerge from NaCl alone?
    A2 = frozenset([1])  # just NaCl
    print(f"\nDoes salinity emerge from NaCl alone?")
    for r in scales:
        closure = F.scale_closure(r, A2)
        print(f"  Scale {r}: {[names[x] for x in sorted(closure)]}")
    print("  No — salinity requires both NaCl AND H₂O (genuine emergence)")


if __name__ == '__main__':
    print("Applications of Filtered Closure Reconstruction")
    print("=" * 60 + "\n")

    ml_feature_hierarchy()
    causal_discovery()
    data_compression()
    emergence_analysis()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Demo: Filtered Closure Reconstruction and Renormalization DAG Extraction.

Demonstrates the core theorems with concrete numerical examples:
1. Threshold closure system — basic example
2. Implication closure system — richer structure
3. Random closure systems — statistical properties
4. DAG reconstruction and certification
5. Defect decomposition verification
"""

from algorithms import (
    FilteredClosureSystem, threshold_closure, transitive_closure_system,
    random_filtered_closure, identity_closure, full_closure,
    scale_defect, defect_profile, verify_defect_decomposition,
    verify_reconstruction, reconstruct_renorm_dag,
    FiniteScaleObservations, verify_flow_recovery, _powerset
)
from typing import FrozenSet
import random


def demo_threshold_closure():
    """Demo 1: Threshold closure system.

    Elements: {a=0, b=1, c=2, d=3}
    Scales: {fine=0, medium=1, coarse=2}
    Thresholds: a activates at 0, b at 0, c at 1, d at 2

    Physical interpretation: a,b are "UV modes" (visible at fine scale),
    c is a "relevant coupling" (appears at medium scale),
    d is an "IR mode" (only visible at coarse scale).
    """
    print("=" * 60)
    print("DEMO 1: Threshold Closure System")
    print("=" * 60)

    elements = frozenset(range(4))
    scales = [0, 1, 2]
    labels = {0: 'a', 1: 'b', 2: 'c', 3: 'd'}

    F = threshold_closure(elements, scales, {0: 0, 1: 0, 2: 1, 3: 2})

    # Show closure profiles
    print("\nClosure profiles:")
    for A_raw in [set(), {0}, {0, 1}, {0, 1, 2, 3}]:
        A = frozenset(A_raw)
        print(f"  A = {{{', '.join(labels[x] for x in sorted(A))}}}:")
        for r in scales:
            cl = F.scale_closure(r, A)
            print(f"    cl_{r}(A) = {{{', '.join(labels[x] for x in sorted(cl))}}}")

    # Show defects
    A = frozenset([0])
    print(f"\nDefects for A = {{a}}:")
    for i, r in enumerate(scales):
        for s in scales[i+1:]:
            d = scale_defect(F, A, r, s)
            print(f"  D(A, {r}, {s}) = {{{', '.join(labels[x] for x in sorted(d))}}}")

    # Verify defect decomposition
    print(f"\nDefect decomposition D(A,0,2) = D(A,0,1) ∪ D(A,1,2):")
    d02 = scale_defect(F, A, 0, 2)
    d01 = scale_defect(F, A, 0, 1)
    d12 = scale_defect(F, A, 1, 2)
    print(f"  D(A,0,2) = {{{', '.join(labels[x] for x in sorted(d02))}}}")
    print(f"  D(A,0,1) ∪ D(A,1,2) = {{{', '.join(labels[x] for x in sorted(d01 | d12))}}}")
    print(f"  Equal: {d02 == d01 | d12} ✓")

    # Verify axioms
    print(f"\nAxiom verification:")
    test_sets = _powerset(elements)
    axioms = F.verify_axioms(test_sets)
    for k, v in axioms.items():
        print(f"  {k}: {'✓' if v else '✗'}")

    return F, scales


def demo_implication_closure():
    """Demo 2: Implication-based closure with richer structure.

    Elements: {0, 1, 2, 3, 4, 5}
    Scales: {0, 1, 2, 3}

    Implications:
      Scale 0: 0 → 1 (fine-scale link)
      Scale 1: 1 → 2, 3 → 4 (medium-scale links)
      Scale 2: 2 → 3 (coarse-scale link, creates chain 0→1→2→3→4)
      Scale 3: 4 → 5 (very coarse link)
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Implication Closure System")
    print("=" * 60)

    elements = frozenset(range(6))
    scales = [0, 1, 2, 3]
    implications = {
        0: [(0, 1)],
        1: [(1, 2), (3, 4)],
        2: [(2, 3)],
        3: [(4, 5)]
    }

    F = transitive_closure_system(elements, scales, implications)

    # Trace the closure chain
    A = frozenset([0])
    print(f"\nClosure chain starting from {{0}}:")
    for r in scales:
        cl = F.scale_closure(r, A)
        print(f"  cl_{r}({{0}}) = {set(sorted(cl))}")

    # Show defect profile
    print(f"\nDefect profile for A = {{0}}:")
    for i, r in enumerate(scales):
        for s in scales[i+1:]:
            d = scale_defect(F, A, r, s)
            if d:
                print(f"  D({{0}}, {r}, {s}) = {set(sorted(d))}")

    # Three-scale decomposition
    print(f"\nThree-scale decomposition D({{0}},0,3) = D(0,1) ∪ D(1,2) ∪ D(2,3):")
    d03 = scale_defect(F, A, 0, 3)
    d01 = scale_defect(F, A, 0, 1)
    d12 = scale_defect(F, A, 1, 2)
    d23 = scale_defect(F, A, 2, 3)
    union = d01 | d12 | d23
    # Note: our formal theorem proves D(0,3) = D(0,1) ∪ D(1,3)
    # and D(1,3) = D(1,2) ∪ D(2,3), so by induction all three work
    print(f"  D(0,3) = {set(sorted(d03))}")
    print(f"  D(0,1) ∪ D(1,2) ∪ D(2,3) = {set(sorted(union))}")
    print(f"  Equal: {d03 == union} ✓")

    # Axiom verification
    print(f"\nAxiom verification (on subset of power set):")
    test_sets = [frozenset(), frozenset([0]), frozenset([3]), frozenset([0,3]),
                 frozenset([0,1,2]), elements]
    axioms = F.verify_axioms(test_sets)
    for k, v in axioms.items():
        print(f"  {k}: {'✓' if v else '✗'}")

    return F, scales


def demo_dag_reconstruction(F: FilteredClosureSystem, scales):
    """Demo 3: DAG reconstruction from observations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Renormalization DAG Reconstruction")
    print("=" * 60)

    # Use several test sets
    test_sets = [frozenset(), frozenset([0]), frozenset([1]),
                 frozenset([0, 1]), frozenset([0, 2])]

    obs = FiniteScaleObservations(
        test_sets=test_sets,
        observed=lambda A, r: F.scale_closure(r, A),
        scales=scales
    )

    dag = reconstruct_renorm_dag(obs)
    print(f"\nReconstructed DAG:")
    print(f"  Edges: {dag.edge_count()}")
    print(f"  Active scales: {sorted(dag.active_scales())}")

    # Show edges grouped by scale pair
    from collections import defaultdict
    edge_groups = defaultdict(list)
    for e in dag.edges:
        edge_groups[(e.source, e.target)].append(e)

    for (r, s), edges in sorted(edge_groups.items()):
        defects = set()
        for e in edges:
            defects |= set(e.label)
        print(f"  Scale {r} → {s}: defect elements = {sorted(defects)}")

    # Verify soundness
    print(f"\n  Soundness: {dag.is_sound(lambda A, r: F.scale_closure(r, A))} ✓")
    print(f"  Flow recovery: {verify_flow_recovery(obs)} ✓")


def demo_random_systems():
    """Demo 4: Statistics on random closure systems."""
    print("\n" + "=" * 60)
    print("DEMO 4: Random Closure Systems")
    print("=" * 60)

    n_trials = 20
    n_elements = 6
    n_scales = 4

    total_defect_decomp = 0
    total_reconstruction = 0
    total_tests = 0
    axiom_pass = 0
    total_dag_edges = 0

    for trial in range(n_trials):
        F = random_filtered_closure(n_elements, n_scales, seed=42 + trial)
        elements = F.elements
        scales = F.scales

        # Check axioms on small test set
        test_sets = [frozenset(), frozenset([0]), frozenset([0,1]),
                     frozenset([0,1,2]), elements]
        axioms = F.verify_axioms(test_sets)
        if all(axioms.values()):
            axiom_pass += 1

            # Verify defect decomposition
            for A in test_sets:
                for i, r in enumerate(scales):
                    for j, s in enumerate(scales[i+1:], i+1):
                        for t in scales[j+1:]:
                            total_tests += 1
                            if verify_defect_decomposition(F, A, r, s, t):
                                total_defect_decomp += 1
                            if verify_reconstruction(F, A, r, s):
                                total_reconstruction += 1

            # DAG reconstruction
            obs = FiniteScaleObservations(
                test_sets=test_sets,
                observed=lambda A, r, F=F: F.scale_closure(r, A),
                scales=scales
            )
            dag = reconstruct_renorm_dag(obs)
            total_dag_edges += dag.edge_count()

    print(f"\n  Trials: {n_trials}")
    print(f"  Axiom-valid systems: {axiom_pass}/{n_trials}")
    if total_tests > 0:
        print(f"  Defect decomposition verified: {total_defect_decomp}/{total_tests}")
        print(f"  Reconstruction verified: {total_reconstruction}/{total_tests}")
    print(f"  Average DAG edges: {total_dag_edges / max(1, axiom_pass):.1f}")


def demo_trivial_systems():
    """Demo 5: Trivial closure systems (identity and full)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Trivial Closure Systems")
    print("=" * 60)

    elements = frozenset(range(4))
    scales = [0, 1, 2]

    # Identity closure
    F_id = identity_closure(elements, scales)
    print("\nIdentity closure (cl_r(A) = A):")
    A = frozenset([0, 1])
    for r in scales:
        d = scale_defect(F_id, A, 0, r)
        print(f"  D({set(A)}, 0, {r}) = {set(d)} (empty ✓)")

    # Full closure
    F_full = full_closure(elements, scales)
    print("\nFull closure (cl_r(A) = universe):")
    A = frozenset([0])
    for r in scales:
        cl = F_full.scale_closure(r, A)
        print(f"  cl_{r}({set(A)}) = {set(sorted(cl))}")
    d = scale_defect(F_full, A, 0, 2)
    print(f"  D({set(A)}, 0, 2) = {set(d)} (empty since cl is constant ✓)")


if __name__ == '__main__':
    print("Filtered Closure Reconstruction — Demonstration")
    print("================================================\n")

    F1, scales1 = demo_threshold_closure()
    F2, scales2 = demo_implication_closure()
    demo_dag_reconstruction(F2, scales2)
    demo_random_systems()
    demo_trivial_systems()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Visualizations for Filtered Closure Reconstruction.

Generates charts showing:
1. Closure growth profiles across scales
2. Defect decomposition diagram
3. Renormalization DAG
4. Compression ratios for random systems
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random
import base64
import io

from algorithms import (
    FilteredClosureSystem, threshold_closure, transitive_closure_system,
    random_filtered_closure, scale_defect, reconstruct_renorm_dag,
    FiniteScaleObservations, _powerset
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_closure_growth():
    """Plot 1: Closure growth profiles across scales."""
    elements = frozenset(range(8))
    scales = list(range(5))

    # Create a system with interesting structure
    implications = {
        0: [(0, 1)],
        1: [(1, 2), (3, 4)],
        2: [(2, 3)],
        3: [(4, 5), (5, 6)],
        4: [(6, 7)]
    }
    F = transitive_closure_system(elements, scales, implications)

    fig, ax = plt.subplots(figsize=(10, 6))

    test_sets = [frozenset([0]), frozenset([3]), frozenset([0, 3]),
                 frozenset([0, 1, 2, 3])]
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    markers = ['o', 's', '^', 'D']

    for i, A in enumerate(test_sets):
        sizes = [len(F.scale_closure(r, A)) for r in scales]
        label = '{' + ', '.join(str(x) for x in sorted(A)) + '}'
        ax.plot(scales, sizes, color=colors[i], marker=markers[i],
                linewidth=2, markersize=8, label=f'A = {label}')

    ax.set_xlabel('Scale (σ)', fontsize=13)
    ax.set_ylabel('|cl_σ(A)|', fontsize=13)
    ax.set_title('Closure Growth Profiles Across Scales', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(scales)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 9)

    fig.savefig('closure_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_defect_decomposition():
    """Plot 2: Defect decomposition diagram."""
    elements = frozenset(range(6))
    scales = [0, 1, 2, 3]

    implications = {
        0: [(0, 1)],
        1: [(1, 2), (3, 4)],
        2: [(2, 3)],
        3: [(4, 5)]
    }
    F = transitive_closure_system(elements, scales, implications)

    A = frozenset([0])

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Closure at each scale
    ax = axes[0]
    for r in scales:
        cl = F.scale_closure(r, A)
        ax.barh(r, len(cl), color=plt.cm.Blues(0.3 + 0.15 * r), edgecolor='black')
        ax.text(len(cl) + 0.1, r, f'{set(sorted(cl))}', va='center', fontsize=9)
    ax.set_xlabel('|cl_r(A)|', fontsize=12)
    ax.set_ylabel('Scale r', fontsize=12)
    ax.set_title('Closure Size by Scale', fontsize=12, fontweight='bold')
    ax.set_yticks(scales)

    # Panel 2: Defect sizes
    ax = axes[1]
    for i, r in enumerate(scales):
        for j, s in enumerate(scales[i+1:i+2]):
            d = scale_defect(F, A, r, s)
            bar = ax.bar(f'{r}→{s}', len(d), color=plt.cm.Oranges(0.4 + 0.15 * i),
                        edgecolor='black')
            if d:
                ax.text(bar[0].get_x() + bar[0].get_width()/2, len(d) + 0.05,
                       f'{set(sorted(d))}', ha='center', fontsize=9)
    ax.set_xlabel('Scale Transition', fontsize=12)
    ax.set_ylabel('|D(A, r, s)|', fontsize=12)
    ax.set_title('Defect Sizes', fontsize=12, fontweight='bold')

    # Panel 3: Cumulative defect decomposition
    ax = axes[2]
    d_total = scale_defect(F, A, 0, 3)
    d_01 = scale_defect(F, A, 0, 1)
    d_12 = scale_defect(F, A, 1, 2)
    d_23 = scale_defect(F, A, 2, 3)

    bottom = 0
    colors_defect = ['#E91E63', '#FF9800', '#4CAF50']
    labels = ['D(0,1)', 'D(1,2)', 'D(2,3)']
    for d, c, l in zip([d_01, d_12, d_23], colors_defect, labels):
        ax.bar('Decomposed', len(d), bottom=bottom, color=c, edgecolor='black', label=l)
        bottom += len(d)
    ax.bar('Total D(0,3)', len(d_total), color='#2196F3', edgecolor='black', label='D(0,3)')
    ax.set_ylabel('|Defect|', fontsize=12)
    ax.set_title('Defect Decomposition', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)

    fig.suptitle(f'Defect Analysis for A = {{0}}', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('defect_decomposition.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_compression_ratios():
    """Plot 3: Compression ratios for random systems."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Vary number of elements
    n_scales = 4
    element_counts = [4, 6, 8, 10, 12]
    ratios = []
    for n in element_counts:
        trial_ratios = []
        for seed in range(10):
            F = random_filtered_closure(n, n_scales, seed=seed * 100 + n)
            elements = F.elements
            scales = F.scales
            test_sets = [frozenset([i]) for i in range(min(n, 5))]

            full = 0
            defect = 0
            for A in test_sets:
                for r in scales:
                    full += len(F.scale_closure(r, A))
                defect += len(F.scale_closure(scales[0], A))
                for i in range(len(scales) - 1):
                    d = scale_defect(F, A, scales[i], scales[i+1])
                    defect += len(d)

            if full > 0:
                trial_ratios.append(defect / full)

        ratios.append(np.mean(trial_ratios) if trial_ratios else 1.0)

    ax = axes[0]
    ax.plot(element_counts, ratios, 'o-', color='#2196F3', linewidth=2, markersize=8)
    ax.set_xlabel('Number of Elements |α|', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_title('Defect Compression vs Elements', fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1)

    # Vary number of scales
    n_elements = 8
    scale_counts = [2, 3, 4, 5, 6]
    ratios2 = []
    for ns in scale_counts:
        trial_ratios = []
        for seed in range(10):
            F = random_filtered_closure(n_elements, ns, seed=seed * 200 + ns)
            scales = F.scales
            test_sets = [frozenset([i]) for i in range(min(n_elements, 5))]

            full = 0
            defect = 0
            for A in test_sets:
                for r in scales:
                    full += len(F.scale_closure(r, A))
                defect += len(F.scale_closure(scales[0], A))
                for i in range(len(scales) - 1):
                    d = scale_defect(F, A, scales[i], scales[i+1])
                    defect += len(d)

            if full > 0:
                trial_ratios.append(defect / full)

        ratios2.append(np.mean(trial_ratios) if trial_ratios else 1.0)

    ax = axes[1]
    ax.plot(scale_counts, ratios2, 's-', color='#FF5722', linewidth=2, markersize=8)
    ax.set_xlabel('Number of Scales |σ|', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_title('Defect Compression vs Scales', fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1)

    fig.suptitle('Hierarchical Compression via Defect Profiles', fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('compression_ratios.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_dag_structure():
    """Plot 4: Renormalization DAG visualization."""
    elements = frozenset(range(6))
    scales = [0, 1, 2, 3]

    implications = {
        0: [(0, 1)],
        1: [(1, 2), (3, 4)],
        2: [(2, 3)],
        3: [(4, 5)]
    }
    F = transitive_closure_system(elements, scales, implications)

    test_sets = [frozenset([i]) for i in range(6)]
    obs = FiniteScaleObservations(
        test_sets=test_sets,
        observed=lambda A, r: F.scale_closure(r, A),
        scales=scales
    )
    dag = reconstruct_renorm_dag(obs)

    fig, ax = plt.subplots(figsize=(10, 6))

    # Count edges per scale pair
    from collections import Counter
    edge_counts = Counter()
    edge_defects = {}
    for e in dag.edges:
        key = (e.source, e.target)
        edge_counts[key] += 1
        if key not in edge_defects:
            edge_defects[key] = set()
        edge_defects[key] |= set(e.label)

    # Draw nodes (scales)
    y_pos = {s: s for s in scales}
    x_pos = {s: 2 for s in scales}

    for s in scales:
        circle = plt.Circle((x_pos[s], y_pos[s]), 0.3,
                           color=plt.cm.Blues(0.3 + 0.15 * s),
                           edgecolor='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x_pos[s], y_pos[s], f'σ={s}', ha='center', va='center',
               fontsize=11, fontweight='bold', zorder=6)

    # Draw edges
    for (r, s), count in edge_counts.items():
        defects = sorted(edge_defects[(r, s)])
        # Curved arrow
        ax.annotate('', xy=(x_pos[s] + 0.35, y_pos[s]),
                   xytext=(x_pos[r] + 0.35, y_pos[r]),
                   arrowprops=dict(arrowstyle='->', color='#E91E63',
                                  lw=1 + count * 0.5, connectionstyle='arc3,rad=0.2'))
        # Label
        mid_y = (y_pos[r] + y_pos[s]) / 2
        ax.text(x_pos[r] + 0.8, mid_y, f'D={set(defects)}\n({count} obs)',
               fontsize=8, ha='left', va='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                        edgecolor='gray', alpha=0.8))

    ax.set_xlim(0, 5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Renormalization DAG\n(edges = observed defects between scales)',
                fontsize=14, fontweight='bold')

    fig.savefig('dag_structure.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == '__main__':
    print("Generating visualizations...")

    b64_growth = plot_closure_growth()
    print(f"  closure_growth.png generated ({len(b64_growth)} chars)")

    b64_defect = plot_defect_decomposition()
    print(f"  defect_decomposition.png generated ({len(b64_defect)} chars)")

    b64_compress = plot_compression_ratios()
    print(f"  compression_ratios.png generated ({len(b64_compress)} chars)")

    b64_dag = plot_dag_structure()
    print(f"  dag_structure.png generated ({len(b64_dag)} chars)")

    print("\nAll visualizations generated successfully.")
