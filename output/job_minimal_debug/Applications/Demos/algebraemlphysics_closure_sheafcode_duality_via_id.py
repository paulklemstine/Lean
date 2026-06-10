"""
Applications of Closure-Sheaf Code Duality

Demonstrates real-world applications:
1. Error-correcting code design from constraint systems
2. Distributed sensor network consistency checking
3. Puzzle solving via constraint propagation
4. Network protocol verification via gluing properties
"""

from algorithms import (
    CellComplex, ConstraintSystem, CellularDecoder,
    canonical_decoder, canonical_constraint, refine_to_reachable,
    iterative_arc_consistency, has_gluing_property,
    zero_defect_kernel_classes, verify_duality
)
from itertools import product
import numpy as np


# ============================================================
# Application 1: Error-Correcting Code Design
# ============================================================

def app_error_correcting_codes():
    """Design error-correcting codes from constraint systems.

    The duality theorem tells us:
    - Parity checks = minimal closed generators
    - Codewords = zero-defect global sections
    - Syndrome = defect functional value
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: ERROR-CORRECTING CODE DESIGN")
    print("=" * 70)

    # Simple (4,1) repetition code
    n = 4
    K = CellComplex.path_graph(n)
    domains = [set(range(2)) for _ in range(n)]
    S = ConstraintSystem(K, 2, domains, lambda s, t, a, b: a == b if s != t else True)

    valid = S.valid_set()
    D = canonical_decoder(S)
    codewords = D.codewords(S.domains)

    print(f"Repetition code: {n} cells, {len(valid)} codewords")
    print(f"Code rate: 1/{n} = {1/n:.3f}")
    print(f"Codewords: {sorted(valid)}")

    # Syndrome (defect) analysis
    print("\nSyndrome analysis:")
    for f in sorted(product(range(2), repeat=n)):
        defect = S.total_defect(f)
        status = "CODEWORD" if defect == 0 else f"defect={defect}"
        print(f"  {f}: {status}")

    # Build canonical constraint from codewords
    C = canonical_constraint(K, 2, valid)
    print(f"\nCanonical domain sizes: {[len(d) for d in C.domains]}")
    print(f"Duality verified: {verify_duality(S, verbose=False)['theorem_a']}")


# ============================================================
# Application 2: Distributed Sensor Consistency
# ============================================================

def app_sensor_network():
    """Distributed sensor network consistency checking.

    Sensors on a small grid must report consistent readings.
    Adjacent sensors should agree within a tolerance.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: DISTRIBUTED SENSOR NETWORK")
    print("=" * 70)

    # 2x3 grid of sensors
    K = CellComplex.grid_graph(2, 3)
    n = K.n_cells

    # Temperature: {cold=0, mild=1, warm=2}
    obs_size = 3
    domains = [set(range(obs_size)) for _ in range(n)]

    def compat(s, t, a, b):
        if s == t:
            return True
        return abs(a - b) <= 1

    S = ConstraintSystem(K, obs_size, domains, compat)
    valid = S.valid_set()

    print(f"Sensor grid: 2×3 = {n} sensors")
    print(f"Temperature levels: {obs_size} (cold, mild, warm)")
    print(f"Constraint: adjacent differ by ≤ 1")
    print(f"Consistent readings: {len(valid)}")

    # Refinement
    R = refine_to_reachable(S)
    print("\nReachable states per sensor:")
    for i in range(n):
        r, c = i // 3, i % 3
        print(f"  Sensor ({r},{c}): {sorted(R.domains[i])}")

    # Defect analysis of anomalous reading
    bad = (0, 0, 0, 0, 2, 0)  # spike at position (1,1)
    print(f"\nAnomaly detection for {bad}:")
    print(f"  Total defect: {S.total_defect(bad)}")
    print(f"  Compat defects: {S.compat_defect_count(bad)}")

    # Verify duality
    print("\nDuality verification:")
    verify_duality(S, verbose=True)


# ============================================================
# Application 3: Graph Coloring via Constraint Propagation
# ============================================================

def app_coloring():
    """Graph coloring via constraint propagation.

    Demonstrates how arc consistency can reduce the search space
    for graph coloring problems.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: GRAPH COLORING VIA CONSTRAINT PROPAGATION")
    print("=" * 70)

    # Pentagon (C5) with 3 colors
    K = CellComplex.cycle_graph(5)
    n = K.n_cells
    num_colors = 3

    domains = [set(range(num_colors)) for _ in range(n)]

    def compat(s, t, a, b):
        if s == t:
            return True
        return a != b

    S = ConstraintSystem(K, num_colors, domains, compat)

    # Fix one vertex's color
    domains_fixed = [set(d) for d in domains]
    domains_fixed[0] = {0}  # Fix vertex 0 to color 0

    S_fixed = ConstraintSystem(K, num_colors, domains_fixed, compat)

    print(f"Pentagon (C5) with {num_colors} colors")
    print(f"Before fixing: {sum(len(d) for d in domains)} total domain elements")

    # Arc consistency
    R, iters = iterative_arc_consistency(S_fixed)
    print(f"\nAfter fixing vertex 0 = color 0 and {iters} rounds of AC:")
    for i in range(n):
        print(f"  Vertex {i}: {sorted(R.domains[i])}")

    remaining = sum(len(R.domains[i]) for i in range(n))
    print(f"Remaining domain elements: {remaining}")
    print(f"Reduction: {sum(len(d) for d in domains)} → {remaining}")

    valid = S.valid_set()
    print(f"\nTotal valid 3-colorings of C5: {len(valid)}")


# ============================================================
# Application 4: Network Protocol Verification
# ============================================================

def app_protocol_verification():
    """Verify distributed protocol consistency.

    Token-passing protocol on a small ring.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: PROTOCOL CONSISTENCY VERIFICATION")
    print("=" * 70)

    n = 4  # 4-node ring
    K = CellComplex.cycle_graph(n)

    # States: 0=idle, 1=requesting, 2=holding
    obs_size = 3
    domains = [set(range(obs_size)) for _ in range(n)]

    # Adjacent nodes can't both hold token
    def compat(s, t, a, b):
        if s == t:
            return True
        return not (a == 2 and b == 2)

    S = ConstraintSystem(K, obs_size, domains, compat)
    valid = S.valid_set()

    print(f"Ring network: {n} nodes")
    print(f"States: idle(0), requesting(1), holding(2)")
    print(f"Constraint: adjacent can't both hold token")
    print(f"Valid configurations: {len(valid)}")

    # Classify by holders
    by_holders = {}
    for v in valid:
        holders = sum(1 for x in v if x == 2)
        by_holders.setdefault(holders, []).append(v)

    for h in sorted(by_holders.keys()):
        print(f"  {h} holder(s): {len(by_holders[h])} configs")

    # Gluing property
    gluing = has_gluing_property(S)
    print(f"\nGluing property: {gluing}")
    if not gluing:
        print("  → Global verification needed!")

    # Duality
    print("\nDuality verification:")
    verify_duality(S, verbose=True)


if __name__ == '__main__':
    app_error_correcting_codes()
    app_sensor_network()
    app_coloring()
    app_protocol_verification()


"""
Demo: Closure-Sheaf Code Duality

Demonstrates the core theorems with concrete examples, showing how
constraint systems and cellular decoders are dual descriptions of
the same mathematical object.
"""

from algorithms import (
    CellComplex, ConstraintSystem, canonical_decoder,
    canonical_constraint, refine_to_reachable, iterative_arc_consistency,
    has_gluing_property, zero_defect_kernel_classes,
    repetition_code, parity_check_code, coloring_constraint,
    verify_duality
)


def demo_repetition_code():
    """Demo 1: Repetition Code — the simplest closure-decoder duality."""
    print("\n" + "=" * 70)
    print("DEMO 1: REPETITION CODE")
    print("=" * 70)
    print("""
A repetition code on a path graph requires all cells to have the same
binary value. This is the simplest non-trivial constraint system.

Cell complex: 0 -- 1 -- 2 -- 3  (path graph)
Alphabet: {0, 1}
Constraint: adjacent cells must be equal
    """)

    S = repetition_code(4, 2)
    valid = S.valid_set()
    print(f"Valid assignments (codewords): {sorted(valid)}")
    print(f"  → Only constant assignments: all-0 and all-1")

    # Canonical decoder
    D = canonical_decoder(S)
    print(f"\nCanonical decoder codewords = valid set? "
          f"{D.codewords(S.domains) == valid}")

    # Demonstrate defect counting
    print("\nDefect analysis of sample assignments:")
    test_assignments = [
        (0, 0, 0, 0),  # valid
        (1, 1, 1, 1),  # valid
        (0, 1, 0, 1),  # invalid
        (0, 0, 1, 1),  # invalid
    ]
    for a in test_assignments:
        dd = S.domain_defect_count(a)
        cd = S.compat_defect_count(a)
        status = "VALID" if S.is_valid(a) else "INVALID"
        print(f"  {a}: domain defects={dd}, compat defects={cd}, {status}")

    # Kernel congruence
    print("\nZero-defect kernel classes at cell 0:")
    classes = zero_defect_kernel_classes(S, 0)
    for cls in classes:
        print(f"  {cls}")

    print("\nGluing property:", has_gluing_property(S))


def demo_coloring_code():
    """Demo 2: Graph Coloring — demonstrating the gluing gap."""
    print("\n" + "=" * 70)
    print("DEMO 2: GRAPH COLORING CONSTRAINT SYSTEM")
    print("=" * 70)
    print("""
A 2-coloring constraint on a cycle graph of length 4.
Adjacent cells must have different colors.

Cell complex: 0 -- 1
              |    |
              3 -- 2   (cycle graph C4)
Alphabet: {0, 1}
Constraint: adjacent cells must differ
    """)

    K = CellComplex.cycle_graph(4)
    S = coloring_constraint(K, 2)
    valid = S.valid_set()
    print(f"Valid 2-colorings: {sorted(valid)}")
    print(f"Number of valid colorings: {len(valid)}")

    # Check gluing property
    gluing = has_gluing_property(S)
    print(f"\nGluing property: {gluing}")
    if not gluing:
        print("  → Pairwise consistency ≠ global consistency!")
        print("  → This shows the gluing axiom is non-trivial")

    # Verify duality
    print("\nFull duality verification:")
    verify_duality(S, verbose=True)


def demo_triangle_coloring():
    """Demo 3: Triangle 3-coloring — a system with the gluing property."""
    print("\n" + "=" * 70)
    print("DEMO 3: TRIANGLE 3-COLORING")
    print("=" * 70)
    print("""
3-coloring of a triangle (K3). Since the chromatic number equals the
number of colors, this system has interesting kernel structure.

Cell complex: complete graph K3
Alphabet: {0, 1, 2}
Constraint: adjacent cells must differ
    """)

    K = CellComplex.complete_graph(3)
    S = coloring_constraint(K, 3)
    valid = S.valid_set()
    print(f"Valid 3-colorings: {len(valid)} (= 3! = 6 permutations)")
    for v in sorted(valid):
        print(f"  {v}")

    # Kernel congruence at cell 0
    print("\nZero-defect kernel classes at cell 0:")
    classes = zero_defect_kernel_classes(S, 0)
    for cls in classes:
        print(f"  {cls}")
    print("  → Each color forms its own class (no swaps preserve validity)")

    # Refinement
    print("\nRefinement analysis:")
    R = refine_to_reachable(S)
    for sigma in range(3):
        print(f"  Cell {sigma}: original domain = {S.domains[sigma]}, "
              f"refined = {R.domains[sigma]}")

    # Verify duality
    print("\nFull duality verification:")
    verify_duality(S, verbose=True)


def demo_arc_consistency():
    """Demo 4: Arc Consistency Refinement."""
    print("\n" + "=" * 70)
    print("DEMO 4: ARC CONSISTENCY REFINEMENT")
    print("=" * 70)
    print("""
Starting with an over-specified domain, arc consistency iteratively
removes values that have no compatible partner at incident cells.
This converges to the largest arc-consistent subdomain.
    """)

    # Create a system with extra domain elements
    K = CellComplex.path_graph(3)
    # Domains: {0, 1, 2} at each cell
    # Constraint: adjacent values must differ by at most 1
    domains = [set(range(3)) for _ in range(3)]

    def compat(s, t, a, b):
        if s == t:
            return True
        return abs(a - b) <= 1

    S = ConstraintSystem(K, 3, domains, compat)

    print("Original system:")
    for sigma in range(3):
        print(f"  Cell {sigma}: domain = {sorted(S.domains[sigma])}")

    valid = S.valid_set()
    print(f"\nValid assignments: {len(valid)}")
    for v in sorted(valid):
        print(f"  {v}")

    # Arc consistency
    R, iters = iterative_arc_consistency(S)
    print(f"\nAfter {iters} iterations of arc consistency:")
    for sigma in range(3):
        print(f"  Cell {sigma}: domain = {sorted(R.domains[sigma])}")

    # Reachability refinement
    R2 = refine_to_reachable(S)
    print("\nAfter refinement to reachable states:")
    for sigma in range(3):
        print(f"  Cell {sigma}: domain = {sorted(R2.domains[sigma])}")

    print(f"\nRefinement preserves valid set: {R2.valid_set() == valid}")


def demo_round_trip():
    """Demo 5: Full Round-Trip Reconstruction."""
    print("\n" + "=" * 70)
    print("DEMO 5: FULL ROUND-TRIP RECONSTRUCTION")
    print("=" * 70)
    print("""
Demonstrates the complete closure → decoder → closure round-trip:
1. Start with a constraint system S
2. Build canonical decoder D (Theorem A)
3. Extract codewords = valid set
4. Build canonical constraint C from codewords (Theorem B)
5. Verify C recovers the original valid set (Theorem D under gluing)
    """)

    # Use repetition code (has gluing property)
    S = repetition_code(3, 3)
    print("Original system: repetition code, 3 cells, alphabet {0,1,2}")
    print(f"  Domain sizes: {[len(d) for d in S.domains]}")

    # Step 1: canonical decoder
    D = canonical_decoder(S)
    codewords = D.codewords(S.domains)
    valid = S.valid_set()
    print(f"\nStep 1: Canonical decoder")
    print(f"  Codewords = valid set? {codewords == valid}")
    print(f"  Codewords: {sorted(codewords)}")

    # Step 2: canonical constraint from codewords
    C = canonical_constraint(S.complex, S.obs_size, valid)
    print(f"\nStep 2: Canonical constraint from codewords")
    print(f"  Domain sizes: {[len(d) for d in C.domains]}")

    # Step 3: verify round-trip
    c_valid = C.valid_set()
    print(f"\nStep 3: Round-trip verification")
    print(f"  Original valid set size: {len(valid)}")
    print(f"  Canonical valid set size: {len(c_valid)}")
    print(f"  Sets equal (gluing holds): {c_valid == valid}")

    # Minimality
    print(f"\nMinimality check:")
    print(f"  Original domain sizes: {[len(d) for d in S.domains]}")
    print(f"  Canonical domain sizes: {[len(d) for d in C.domains]}")
    print(f"  Canonical ⊆ Original at each cell: "
          f"{all(C.domains[i] <= S.domains[i] for i in range(S.complex.n_cells))}")


def demo_defect_landscape():
    """Demo 6: Defect Landscape Analysis."""
    print("\n" + "=" * 70)
    print("DEMO 6: DEFECT LANDSCAPE")
    print("=" * 70)
    print("""
Visualizes the defect functional over all possible assignments.
Zero-defect points are codewords; higher defect means more violations.
    """)

    S = parity_check_code(3)
    print("System: parity check code on path of length 3")
    print("  Adjacent cells must have DIFFERENT binary values")
    print(f"\nAll assignments and their defects:")

    from itertools import product as iproduct
    assignments = list(iproduct(range(2), repeat=3))

    for a in assignments:
        dd = S.domain_defect_count(a)
        cd = S.compat_defect_count(a)
        td = S.total_defect(a)
        marker = " ← CODEWORD" if td == 0 else ""
        print(f"  {a}: domain={dd}, compat={cd}, total={td}{marker}")


if __name__ == '__main__':
    demo_repetition_code()
    demo_coloring_code()
    demo_triangle_coloring()
    demo_arc_consistency()
    demo_round_trip()
    demo_defect_landscape()


"""
Visualizations for Closure-Sheaf Code Duality

Generates publication-quality figures demonstrating:
1. Defect landscapes
2. Domain refinement convergence
3. Round-trip duality diagrams
4. Kernel congruence structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from algorithms import (
    CellComplex, ConstraintSystem, canonical_decoder,
    canonical_constraint, refine_to_reachable,
    repetition_code, parity_check_code, coloring_constraint,
    zero_defect_kernel_classes, has_gluing_property,
    verify_duality
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_defect_landscape():
    """Plot the defect landscape for a small constraint system."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    systems = [
        ("Repetition Code (n=3)", repetition_code(3, 2)),
        ("Parity Check Code (n=3)", parity_check_code(3)),
        ("3-Coloring Triangle", coloring_constraint(CellComplex.complete_graph(3), 3)),
    ]

    for ax, (name, S) in zip(axes, systems):
        domain_lists = [sorted(S.domains[i]) for i in range(S.complex.n_cells)]
        all_assignments = list(product(*domain_lists))

        defects = [S.total_defect(a) for a in all_assignments]
        colors = ['#2ecc71' if d == 0 else '#e74c3c' if d >= 2 else '#f39c12'
                  for d in defects]

        x = range(len(all_assignments))
        bars = ax.bar(x, defects, color=colors, edgecolor='white', linewidth=0.5)
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xlabel('Assignment Index')
        ax.set_ylabel('Total Defect')
        ax.set_xticks([])

        # Add legend
        codeword_patch = mpatches.Patch(color='#2ecc71', label='Codeword (0 defect)')
        low_defect = mpatches.Patch(color='#f39c12', label='1 defect')
        high_defect = mpatches.Patch(color='#e74c3c', label='≥2 defects')
        ax.legend(handles=[codeword_patch, low_defect, high_defect],
                  fontsize=8, loc='upper right')

    fig.suptitle('Defect Landscape: Codewords Are Zero-Defect Assignments',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_domain_minimality():
    """Compare original vs canonical domain sizes across examples."""
    fig, ax = plt.subplots(figsize=(10, 6))

    examples = []

    # Example 1: Repetition with extra domain
    K1 = CellComplex.path_graph(4)
    S1 = ConstraintSystem(K1, 4, [set(range(4)) for _ in range(4)],
                          lambda s, t, a, b: a == b)
    valid1 = S1.valid_set()
    C1 = canonical_constraint(K1, 4, valid1)
    examples.append(("Repetition\n(oversized domain)", S1, C1))

    # Example 2: Coloring with extra colors
    K2 = CellComplex.path_graph(3)
    S2 = coloring_constraint(K2, 4)
    valid2 = S2.valid_set()
    C2 = canonical_constraint(K2, 4, valid2)
    examples.append(("Path Coloring\n(4 colors, need 2)", S2, C2))

    # Example 3: Standard parity check
    S3 = parity_check_code(4)
    valid3 = S3.valid_set()
    C3 = canonical_constraint(S3.complex, 2, valid3)
    examples.append(("Parity Check\n(already minimal)", S3, C3))

    x = np.arange(len(examples))
    width = 0.35

    original_totals = [sum(len(d) for d in s.domains) for _, s, _ in examples]
    canonical_totals = [sum(len(d) for d in c.domains) for _, _, c in examples]

    bars1 = ax.bar(x - width/2, original_totals, width, label='Original',
                   color='#3498db', edgecolor='white')
    bars2 = ax.bar(x + width/2, canonical_totals, width, label='Canonical (Minimal)',
                   color='#2ecc71', edgecolor='white')

    ax.set_xlabel('Constraint System', fontsize=12)
    ax.set_ylabel('Total Domain Size (sum over cells)', fontsize=12)
    ax.set_title('Domain Minimization via Myhill–Nerode Refinement',
                 fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels([name for name, _, _ in examples])
    ax.legend(fontsize=11)

    # Add value labels
    for bar in bars1:
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.3,
                f'{int(bar.get_height())}', ha='center', va='bottom', fontweight='bold')
    for bar in bars2:
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.3,
                f'{int(bar.get_height())}', ha='center', va='bottom', fontweight='bold')

    plt.tight_layout()
    return fig


def plot_round_trip_diagram():
    """Visualize the round-trip reconstruction for several systems."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    systems = [
        ("Repetition (n=3, binary)", repetition_code(3, 2)),
        ("Parity Check (n=3)", parity_check_code(3)),
        ("3-Coloring Path(3)", coloring_constraint(CellComplex.path_graph(3), 3)),
        ("2-Coloring C4", coloring_constraint(CellComplex.cycle_graph(4), 2)),
    ]

    for ax, (name, S) in zip(axes.flat, systems):
        valid = S.valid_set()
        D = canonical_decoder(S)
        codewords = D.codewords(S.domains)

        # Domain sizes at each step
        orig_sizes = [len(d) for d in S.domains]

        if valid:
            C = canonical_constraint(S.complex, S.obs_size, valid)
            canon_sizes = [len(d) for d in C.domains]
            c_valid = C.valid_set()
            round_trip_exact = (c_valid == valid)
        else:
            canon_sizes = [0] * S.complex.n_cells
            round_trip_exact = False

        cells = range(S.complex.n_cells)
        x = np.arange(len(cells))
        width = 0.35

        ax.bar(x - width/2, orig_sizes, width, label='Original', color='#3498db')
        ax.bar(x + width/2, canon_sizes, width, label='Canonical', color='#e74c3c')

        ax.set_title(f'{name}\n|Valid|={len(valid)}, Round-trip: '
                     f'{"✓" if round_trip_exact else "✗"}',
                     fontsize=11, fontweight='bold')
        ax.set_xlabel('Cell')
        ax.set_ylabel('Domain Size')
        ax.set_xticks(x)
        ax.legend(fontsize=9)

    fig.suptitle('Round-Trip Domain Recovery: Original vs Canonical',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_gluing_analysis():
    """Analyze the gluing property across different constraint systems."""
    fig, ax = plt.subplots(figsize=(10, 6))

    test_cases = []

    # Various systems
    for n in range(2, 7):
        S = repetition_code(n, 2)
        valid = S.valid_set()
        gluing = has_gluing_property(S)
        test_cases.append((f"Rep(n={n})", len(valid), S.total_domain_size(), gluing))

    for n in range(2, 6):
        S = parity_check_code(n)
        valid = S.valid_set()
        gluing = has_gluing_property(S)
        test_cases.append((f"Parity(n={n})", len(valid), S.total_domain_size(), gluing))

    for k in range(2, 5):
        K = CellComplex.complete_graph(3)
        S = coloring_constraint(K, k)
        valid = S.valid_set()
        gluing = has_gluing_property(S)
        test_cases.append((f"K3-{k}col", len(valid), S.total_domain_size(), gluing))

    names = [t[0] for t in test_cases]
    codeword_counts = [t[1] for t in test_cases]
    gluings = [t[3] for t in test_cases]

    colors = ['#2ecc71' if g else '#e74c3c' for g in gluings]

    bars = ax.bar(range(len(names)), codeword_counts, color=colors, edgecolor='white')
    ax.set_xticks(range(len(names)))
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=9)
    ax.set_ylabel('Number of Codewords', fontsize=12)
    ax.set_title('Gluing Property Analysis Across Constraint Systems',
                 fontsize=14, fontweight='bold')

    gluing_patch = mpatches.Patch(color='#2ecc71', label='Has Gluing Property')
    no_gluing = mpatches.Patch(color='#e74c3c', label='No Gluing Property')
    ax.legend(handles=[gluing_patch, no_gluing], fontsize=11)

    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    print("Generating defect landscape...")
    fig1 = plot_defect_landscape()
    fig1.savefig('/workspace/request-project/fig_defect_landscape.png',
                 dpi=150, bbox_inches='tight')

    print("Generating domain minimality...")
    fig2 = plot_domain_minimality()
    fig2.savefig('/workspace/request-project/fig_domain_minimality.png',
                 dpi=150, bbox_inches='tight')

    print("Generating round-trip diagram...")
    fig3 = plot_round_trip_diagram()
    fig3.savefig('/workspace/request-project/fig_round_trip.png',
                 dpi=150, bbox_inches='tight')

    print("Generating gluing analysis...")
    fig4 = plot_gluing_analysis()
    fig4.savefig('/workspace/request-project/fig_gluing_analysis.png',
                 dpi=150, bbox_inches='tight')

    # Also return base64 versions
    return {
        'defect_landscape': fig_to_base64(plot_defect_landscape()),
        'domain_minimality': fig_to_base64(plot_domain_minimality()),
        'round_trip': fig_to_base64(plot_round_trip_diagram()),
        'gluing_analysis': fig_to_base64(plot_gluing_analysis()),
    }


if __name__ == '__main__':
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations")
    for name, data in vizs.items():
        print(f"  {name}: {len(data)} bytes")
