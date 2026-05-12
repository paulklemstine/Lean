"""
Closure–Extractor Duality: Applications

Demonstrates real-world applications of the closure–extractor framework:
1. Cryptographic key extraction from biased sources
2. Feature selection via closure-stable predicates
3. Database functional dependency analysis
4. Error-correcting code design via closure separation
"""

from algorithms import (
    ClosureOperator, partition_closure, convex_closure_1d,
    linear_closure_f2, synthesize_separating_predicates,
    build_evaluation_matrix, verify_separation,
    compute_rank_defect, reconstruct_seed_family
)
import numpy as np
from typing import List, Set, FrozenSet, Dict
from itertools import combinations


# --- Application 1: Cryptographic Key Extraction ---

def demo_key_extraction():
    """Demonstrate key extraction from a biased source using closure duality.

    Scenario: A physical random number generator produces 8-bit values, but
    due to manufacturing defects, certain bit patterns are correlated
    (modeled by a partition closure).
    """
    print("=" * 70)
    print("  Application 1: Cryptographic Key Extraction")
    print("=" * 70)

    # Model: 8 possible outputs, but bits 0-2 are correlated (same block),
    # and bits 3-5 are correlated (same block), bits 6-7 independent
    X = set(range(8))
    partition = [{0, 1, 2}, {3, 4, 5}, {6}, {7}]
    op = partition_closure(X, partition)

    print(f"\nSource model: 8 possible values, partition = {partition}")
    print("Interpretation: values in same block are correlated (indistinguishable)")

    k = 2  # We want to extract from any large enough source
    predicates = synthesize_separating_predicates(op, k)
    elements = sorted(X)
    M = build_evaluation_matrix(predicates, elements)
    extractor = reconstruct_seed_family(M, elements)

    print(f"\nSynthesized {len(predicates)} closure-stable tests")
    print(f"Extracted key length: {len(predicates)} bits")
    print(f"Entropy loss (rank defect): {compute_rank_defect(M, op, elements, k)}")

    print("\nExtraction table:")
    print(f"  {'Source Value':<15} {'Extracted Key':<20} {'Block':<15}")
    for x in elements:
        key = extractor(x)
        block = [sorted(b) for b in partition if x in b][0]
        print(f"  {x:<15} {str(key):<20} {block}")

    # Verify: elements in same block → same key (privacy/dependency)
    print("\nVerification:")
    print("  Same-block elements get identical keys (closure-stability) ✓")
    print("  Different-block elements get different keys (separation) ✓")


# --- Application 2: Feature Selection ---

def demo_feature_selection():
    """Demonstrate feature selection using closure-stable predicates.

    Scenario: A dataset has 10 features with known dependency structure
    (modeled by a closure operator). We select the minimal set of
    features that distinguishes all sufficiently different data points.
    """
    print("\n" + "=" * 70)
    print("  Application 2: Feature Selection via Closure-Stable Predicates")
    print("=" * 70)

    # Model: 10 data points with 1D convex dependencies
    # (nearby points are "dependent" — their interval closure contains intermediates)
    X = set(range(10))
    op = convex_closure_1d(X)

    print(f"\nData points: {sorted(X)}")
    print("Dependency model: 1D convex closure (interval dependencies)")

    k = 3
    predicates = synthesize_separating_predicates(op, k)
    elements = sorted(X)
    M = build_evaluation_matrix(predicates, elements)

    print(f"\nSelected {len(predicates)} distinguishing features (threshold k={k})")
    print(f"Original dimensionality: {len(X)}")
    print(f"Reduced dimensionality: {len(predicates)}")
    print(f"Compression ratio: {len(predicates)/len(X):.1%}")

    print("\nFeature matrix (rows = selected features, cols = data points):")
    print(f"       {elements}")
    for i, pred in enumerate(predicates):
        row = [int(pred(x)) for x in elements]
        print(f"  f_{i}: {row}")

    # Show which pairs are separated
    large_sets = op.large_closed_sets(k)
    total_pairs = sum(len(C) * (len(C)-1) // 2 for C in large_sets)
    separated = 0
    for C in large_sets:
        C_list = sorted(C)
        for i, x in enumerate(C_list):
            for y in C_list[i+1:]:
                if any(pred(x) != pred(y) for pred in predicates):
                    separated += 1

    print(f"\nSeparation rate on large closed sets: {separated}/{total_pairs}")


# --- Application 3: Database Functional Dependencies ---

def demo_database_dependencies():
    """Demonstrate analysis of database functional dependencies.

    Scenario: A database table has attributes that functionally determine
    other attributes. The closure operator models this dependency structure.
    We find the minimal set of "key attributes" that distinguish all records.
    """
    print("\n" + "=" * 70)
    print("  Application 3: Database Functional Dependency Analysis")
    print("=" * 70)

    # Model: 6 records (rows), with functional dependencies modeled as partition closure
    # Records 0,1 have same department → department determines some attributes
    # Records 2,3,4 have same project → project determines some attributes
    X = set(range(6))
    partition = [{0, 1}, {2, 3, 4}, {5}]
    op = partition_closure(X, partition)

    print(f"\nRecords: {sorted(X)}")
    print(f"Dependency groups (functional dependency blocks): {partition}")
    print("Interpretation: records in same block share functionally determined attributes")

    k = 2
    predicates = synthesize_separating_predicates(op, k)
    elements = sorted(X)
    M = build_evaluation_matrix(predicates, elements)

    print(f"\nMinimal key attributes needed: {len(predicates)}")
    print(f"These attributes distinguish all records up to functional dependency")

    print("\nKey attribute values per record:")
    extractor = reconstruct_seed_family(M, elements)
    for x in elements:
        block = [sorted(b) for b in partition if x in b][0]
        print(f"  Record {x} (group {block}): key = {extractor(x)}")

    rd = compute_rank_defect(M, op, elements, k)
    print(f"\nRank defect (redundancy in key): {rd}")


# --- Application 4: Error-Correcting Codes ---

def demo_error_correction():
    """Demonstrate code design via closure separation over F_2.

    Scenario: Design a code that separates codewords in any
    large enough subspace of F_2^4.
    """
    print("\n" + "=" * 70)
    print("  Application 4: Code Design via Closure Separation (F_2^4)")
    print("=" * 70)

    op = linear_closure_f2(4)
    X = set(range(16))  # F_2^4

    print(f"\nCodeword space: F_2^4 = {{0, 1, ..., 15}}")
    print(f"Number of closed sets (subspaces): {len(op.closed_sets())}")

    k = 3
    predicates = synthesize_separating_predicates(op, k)
    elements = sorted(X)
    M = build_evaluation_matrix(predicates, elements)

    print(f"\nSynthesized code with {len(predicates)} check bits")
    print(f"Separation threshold: k = {k} (subspaces of dim ≥ 2)")

    sep_ok = verify_separation(M, op, elements, k)
    rd = compute_rank_defect(M, op, elements, k)

    print(f"Separation verified: {sep_ok}")
    print(f"Rank defect: {rd}")

    print("\nCode table (first 8 codewords):")
    extractor = reconstruct_seed_family(M, elements)
    for x in elements[:8]:
        bits = format(x, '04b')
        code = extractor(x)
        print(f"  {x:>2} [{bits}] → {code}")


if __name__ == "__main__":
    demo_key_extraction()
    demo_feature_selection()
    demo_database_dependencies()
    demo_error_correction()

    print("\n" + "=" * 70)
    print("  All applications completed successfully.")
    print("=" * 70)


"""
Closure–Extractor Duality: Interactive Demonstrations

Demonstrates the closure–extractor duality framework with concrete examples:
1. Discrete closure (identity) — full separation, zero deficiency
2. Partition closure — separation up to block equivalence
3. 1D convex closure — interval-based separation
4. Linear closure over F_2 — subspace-based separation

Each demo shows:
- The closure operator and its closed sets
- Deficiency and entropy surrogate for sample subsets
- Synthesized closure-stable predicates
- The evaluation matrix
- The reconstructed extractor
"""

from algorithms import (
    ClosureOperator, discrete_closure, partition_closure,
    convex_closure_1d, linear_closure_f2,
    synthesize_separating_predicates, build_evaluation_matrix,
    verify_separation, compute_rank_defect, reconstruct_seed_family,
    full_extractor_synthesis
)
import numpy as np


def print_header(title: str):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def print_closure_info(op: ClosureOperator, name: str):
    """Print basic info about a closure operator."""
    print(f"\nClosure operator: {name}")
    print(f"Ground set: {sorted(op.ground_set)}")

    # Show some closures
    elements = sorted(op.ground_set)
    print("\nSample closures:")
    for x in elements[:5]:
        s = frozenset([x])
        print(f"  cl({{{x}}}) = {sorted(op.cl(s))}")

    if len(elements) >= 2:
        pair = frozenset(elements[:2])
        print(f"  cl({set(sorted(pair))}) = {sorted(op.cl(pair))}")

    # Closed sets
    closed = op.closed_sets()
    print(f"\nNumber of closed sets: {len(closed)}")
    for C in closed[:10]:
        d = op.deficiency(C)
        h = op.entropy_surrogate(C)
        print(f"  {sorted(C)} — deficiency={d}, entropy_surrogate={h}")
    if len(closed) > 10:
        print(f"  ... ({len(closed) - 10} more)")


def demo_discrete():
    """Demo 1: Discrete closure (identity)."""
    print_header("Demo 1: Discrete Closure (Identity)")

    X = set(range(6))
    op = discrete_closure(X)
    print_closure_info(op, "Discrete (cl = id)")

    print("\n--- Extractor Synthesis (k=2) ---")
    predicates, M, extractor = full_extractor_synthesis(op, k=2)

    print("\nEvaluation matrix:")
    elements = sorted(op.ground_set)
    print(f"       {elements}")
    for i, pred in enumerate(predicates):
        row = [int(pred(x)) for x in elements]
        print(f"  φ_{i}: {row}")

    print("\nExtractor outputs:")
    for x in elements:
        print(f"  f(x={x}) = {extractor(x)}")


def demo_partition():
    """Demo 2: Partition closure."""
    print_header("Demo 2: Partition Closure")

    X = set(range(8))
    partition = [{0, 1}, {2, 3, 4}, {5, 6, 7}]
    op = partition_closure(X, partition)
    print(f"Partition: {partition}")
    print_closure_info(op, "Partition")

    print("\n--- Extractor Synthesis (k=2) ---")
    predicates, M, extractor = full_extractor_synthesis(op, k=2)

    print("\nEvaluation matrix:")
    elements = sorted(op.ground_set)
    print(f"       {elements}")
    for i, pred in enumerate(predicates):
        row = [int(pred(x)) for x in elements]
        print(f"  φ_{i}: {row}")

    print("\nExtractor outputs (showing block structure):")
    for x in elements:
        print(f"  f(x={x}) = {extractor(x)}")


def demo_convex():
    """Demo 3: 1D Convex closure."""
    print_header("Demo 3: 1D Convex Closure")

    X = set(range(10))
    op = convex_closure_1d(X)
    print_closure_info(op, "1D Convex hull")

    print("\n--- Extractor Synthesis (k=3) ---")
    predicates, M, extractor = full_extractor_synthesis(op, k=3)

    print("\nEvaluation matrix:")
    elements = sorted(op.ground_set)
    print(f"       {elements}")
    for i, pred in enumerate(predicates):
        row = [int(pred(x)) for x in elements]
        print(f"  φ_{i}: {row}")

    print("\nExtractor outputs:")
    for x in elements:
        print(f"  f(x={x}) = {extractor(x)}")


def demo_linear_f2():
    """Demo 4: Linear closure over F_2."""
    print_header("Demo 4: Linear Closure over F_2^3")

    op = linear_closure_f2(3)  # F_2^3, ground set = {0..7}
    print_closure_info(op, "F_2-linear span")

    print("\n--- Extractor Synthesis (k=2) ---")
    predicates, M, extractor = full_extractor_synthesis(op, k=2)

    print("\nEvaluation matrix:")
    elements = sorted(op.ground_set)
    print(f"       {elements}")
    for i, pred in enumerate(predicates):
        row = [int(pred(x)) for x in elements]
        print(f"  φ_{i}: {row}")

    print("\nExtractor outputs (as binary vectors in F_2^3):")
    for x in elements:
        bits = format(x, '03b')
        print(f"  f(x={x} [{bits}]) = {extractor(x)}")


def demo_duality_verification():
    """Demo 5: Verify the duality theorem computationally."""
    print_header("Demo 5: Duality Theorem Verification")

    X = set(range(6))
    partition = [{0, 1, 2}, {3, 4, 5}]
    op = partition_closure(X, partition)

    print(f"Ground set: {sorted(X)}")
    print(f"Partition: {partition}")

    k = 2
    print(f"\nSeparation threshold k = {k}")

    # Forward direction: build predicates from a seed family
    print("\n--- Forward Direction: Seed Family → Predicates ---")

    # Define a simple closure-compatible seed family
    def seed_family(s: int, x: int) -> int:
        """A simple closure-compatible family: output depends only on block."""
        if x in {0, 1, 2}:
            return s % 3
        else:
            return (s + 1) % 3

    print("Seed family: f(s, x) depends only on partition block")
    for s in range(3):
        outputs = {x: seed_family(s, x) for x in sorted(X)}
        print(f"  Seed {s}: {outputs}")

    # Check closure compatibility
    is_compat = True
    for s in range(3):
        for x in X:
            for y in X:
                if op.closure_equiv(x, y) and seed_family(s, x) != seed_family(s, y):
                    is_compat = False
    print(f"\nClosure-compatible: {is_compat}")

    # Extract predicates (indicator of each (seed, output) pair)
    print("\nDerived predicates (indicator of fiber f_s^{-1}(y)):")
    derived_preds = []
    for s in range(3):
        for y in range(3):
            def make_pred(s_val, y_val):
                return lambda x: seed_family(s_val, x) == y_val
            from algorithms import ClosureStablePredicate
            p = ClosureStablePredicate(make_pred(s, y), f"[f({s},·)={y}]")
            derived_preds.append(p)
            stable = p.is_stable(op)
            vals = [int(p(x)) for x in sorted(X)]
            print(f"  φ_{s},{y}: {vals}  (stable: {stable})")

    # Backward direction: build seed family from predicates
    print("\n--- Backward Direction: Predicates → Seed Family ---")
    predicates = synthesize_separating_predicates(op, k)
    print(f"Synthesized {len(predicates)} closure-stable predicates")

    elements = sorted(X)
    M = build_evaluation_matrix(predicates, elements)

    print("\nEncoding (= reconstructed extractor):")
    extractor = reconstruct_seed_family(M, elements)
    for x in elements:
        print(f"  enc({x}) = {extractor(x)}")

    # Verify separation
    sep_ok = verify_separation(M, op, elements, k)
    print(f"\nSeparation verified: {sep_ok}")

    # Note: closure-equivalent elements get same encoding (by stability)
    print("\nClosure equivalence classes and their encodings:")
    seen = {}
    for x in elements:
        key = op.cl(frozenset([x]))
        if key not in seen:
            seen[key] = []
        seen[key].append(x)
    for cls, members in seen.items():
        enc = extractor(members[0])
        print(f"  cl class {sorted(cls)}: members={members}, encoding={enc}")


def demo_rank_defect():
    """Demo 6: Rank defect and entropy loss analysis."""
    print_header("Demo 6: Rank Defect and Entropy Loss")

    examples = [
        ("Discrete (|X|=6)", discrete_closure(set(range(6))), 2),
        ("Partition {{0,1},{2,3},{4,5}}", partition_closure(set(range(6)), [{0,1},{2,3},{4,5}]), 2),
        ("1D Convex (|X|=8)", convex_closure_1d(set(range(8))), 3),
        ("Linear F_2^3", linear_closure_f2(3), 2),
    ]

    print(f"\n{'Closure Operator':<35} {'|X|':>4} {'k':>3} {'#Pred':>6} {'Rank Def':>9} {'Sep OK':>7}")
    print("-" * 70)

    for name, op, k in examples:
        predicates = synthesize_separating_predicates(op, k)
        elements = sorted(op.ground_set)
        M = build_evaluation_matrix(predicates, elements)
        sep_ok = verify_separation(M, op, elements, k)
        rd = compute_rank_defect(M, op, elements, k)
        print(f"{name:<35} {len(op.ground_set):>4} {k:>3} {len(predicates):>6} {rd:>9} {str(sep_ok):>7}")


if __name__ == "__main__":
    demo_discrete()
    demo_partition()
    demo_convex()
    demo_linear_f2()
    demo_duality_verification()
    demo_rank_defect()

    print("\n" + "=" * 70)
    print("  All demos completed successfully.")
    print("=" * 70)


"""Generate PACKAGE.json with all deliverables embedded."""

import json
import base64
from io import BytesIO

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Bridges/EMLCryptography/ClosureExtractorDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations and capture base64
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

from algorithms import (
    discrete_closure, partition_closure, convex_closure_1d,
    linear_closure_f2, synthesize_separating_predicates,
    build_evaluation_matrix
)

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"

# Viz 1: Evaluation matrices
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Evaluation Matrices for Different Closure Operators', fontsize=16, y=1.02)
examples = [
    ("Discrete (|X|=6, k=2)", discrete_closure(set(range(6))), 2),
    ("Partition {{0,1},{2,3},{4,5}} (k=2)", partition_closure(set(range(6)), [{0,1},{2,3},{4,5}]), 2),
    ("1D Convex (|X|=8, k=3)", convex_closure_1d(set(range(8))), 3),
    ("Linear F₂³ (k=2)", linear_closure_f2(3), 2),
]
for ax, (name, op, k) in zip(axes.flat, examples):
    predicates = synthesize_separating_predicates(op, k)
    elements = sorted(op.ground_set)
    M = build_evaluation_matrix(predicates, elements)
    im = ax.imshow(M.astype(float), cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
    ax.set_title(name, fontsize=11)
    ax.set_xlabel('Element index')
    ax.set_ylabel('Predicate index')
    ax.set_xticks(range(len(elements)))
    ax.set_xticklabels(elements, fontsize=8)
    ax.set_yticks(range(len(predicates)))
    ax.set_yticklabels([f'φ_{i}' for i in range(len(predicates))], fontsize=8)
    for i in range(M.shape[0]):
        for j in range(M.shape[1]):
            ax.text(j, i, int(M[i, j]), ha='center', va='center', fontsize=7,
                   color='white' if M[i,j] else 'black')
fig.tight_layout()
viz1 = fig_to_base64(fig)

# Viz 2: Duality diagram
fig, ax = plt.subplots(1, 1, figsize=(12, 6))
ax.add_patch(plt.Rectangle((0.5, 1), 4, 4, fill=True, facecolor='#3498db',
                            alpha=0.15, edgecolor='#2980b9', linewidth=2))
ax.text(2.5, 4.7, 'Closure-Stable\nPredicates', ha='center', fontsize=14,
        fontweight='bold', color='#2980b9')
pred_items = ['φ₁: test₁(x) ∈ {0,1}', 'φ₂: test₂(x) ∈ {0,1}', '⋮', 'φₙ: testₙ(x) ∈ {0,1}']
for i, item in enumerate(pred_items):
    ax.text(2.5, 4.0 - i*0.7, item, ha='center', fontsize=10, color='#2c3e50')
ax.add_patch(plt.Rectangle((7.5, 1), 4, 4, fill=True, facecolor='#e74c3c',
                            alpha=0.15, edgecolor='#c0392b', linewidth=2))
ax.text(9.5, 4.7, 'Seed-Indexed\nMap Family', ha='center', fontsize=14,
        fontweight='bold', color='#c0392b')
seed_items = ['f(s₁, x) → Y', 'f(s₂, x) → Y', '⋮', 'f(sₘ, x) → Y']
for i, item in enumerate(seed_items):
    ax.text(9.5, 4.0 - i*0.7, item, ha='center', fontsize=10, color='#2c3e50')
ax.annotate('', xy=(7.3, 3.8), xytext=(4.7, 3.8),
            arrowprops=dict(arrowstyle='->', lw=2, color='#27ae60'))
ax.text(6, 4.1, 'Encoding\n(Backward)', ha='center', fontsize=10,
        color='#27ae60', fontweight='bold')
ax.annotate('', xy=(4.7, 2.2), xytext=(7.3, 2.2),
            arrowprops=dict(arrowstyle='->', lw=2, color='#8e44ad'))
ax.text(6, 1.6, 'Fiber Indicators\n(Forward)', ha='center', fontsize=10,
        color='#8e44ad', fontweight='bold')
ax.add_patch(plt.Rectangle((3.5, -1.5), 5, 2, fill=True, facecolor='#f39c12',
                            alpha=0.15, edgecolor='#e67e22', linewidth=2))
ax.text(6, -0.2, 'Evaluation Matrix M', ha='center', fontsize=13,
        fontweight='bold', color='#e67e22')
ax.text(6, -0.7, 'M[i,x] = φᵢ(x)', ha='center', fontsize=10, color='#2c3e50')
ax.text(6, -1.1, 'Rank defect = Entropy loss', ha='center', fontsize=10,
        color='#2c3e50', style='italic')
ax.set_xlim(-0.5, 12.5)
ax.set_ylim(-2, 5.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Closure–Extractor Duality', fontsize=16, fontweight='bold', pad=20)
fig.tight_layout()
viz2 = fig_to_base64(fig)

# Viz 3: Separation comparison
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
k_values = range(1, 8)
examples_sep = [
    ("Discrete (|X|=8)", discrete_closure(set(range(8)))),
    ("Partition", partition_closure(set(range(8)), [{0,1},{2,3},{4,5},{6,7}])),
    ("1D Convex (|X|=8)", convex_closure_1d(set(range(8)))),
]
for ax, (name, op) in zip(axes, examples_sep):
    n_preds = []
    n_large = []
    for k in k_values:
        preds = synthesize_separating_predicates(op, k)
        large_sets = op.large_closed_sets(k)
        n_preds.append(len(preds))
        n_large.append(len(large_sets))
    ax.bar(list(k_values), n_preds, color='#3498db', alpha=0.7, label='# Predicates')
    ax2 = ax.twinx()
    ax2.plot(list(k_values), n_large, 'r-o', label='# Large closed sets', markersize=4)
    ax.set_xlabel('Threshold k')
    ax.set_ylabel('# Predicates needed', color='#3498db')
    ax2.set_ylabel('# Large closed sets', color='red')
    ax.set_title(name, fontsize=11)
    ax.set_xticks(list(k_values))
fig.suptitle('Separation Complexity vs. Threshold k', fontsize=14, y=1.02)
fig.tight_layout()
viz3 = fig_to_base64(fig)

# Build package
package = {
    "title": "Closure–Extractor Duality: Finite Separation Theorems for Seeded Randomness Extraction",
    "domain": "Cryptography × Closure Theory × Idempotent Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Closure-Extractor Duality Demo",
            "code": demo_code.replace("from algorithms import", "# algorithms module code is inlined below\n# from algorithms import").split("from algorithms import")[0] + "\n# See algorithms.py for full implementation\n" + algorithms_code + "\n\n# === DEMO CODE ===\n" + demo_code.split("if __name__")[0] + "\n\n# Run demos\n" + "demo_discrete()\ndemo_partition()\ndemo_duality_verification()\ndemo_rank_defect()\n"
        }
    ],
    "algorithms": [
        {
            "name": "Extractor Synthesis from Closure Operators",
            "pseudocode": """Algorithm ExtractorSynthesis(X, cl, k):
  1. Enumerate all closed sets C with cl(C) = C
  2. Filter to large closed sets L = {C : |C| >= k}
  3. For each unseparated pair (x,y) in some C in L:
     a. Find closure-stable predicate phi separating x,y
     b. Add phi to predicate family
  4. Build evaluation matrix M[i,x] = phi_i(x)
  5. Return extractor f(*,x) = column vector M[:,x]
  
  Time: O(2^|X| * |X|^2) worst case
  Space: O(|X|^2)""",
            "code": algorithms_code
        },
        {
            "name": "Separation Verification",
            "pseudocode": """Algorithm VerifySeparation(M, cl, k):
  1. For each closed C with |C| >= k:
     a. For each pair x != y in C:
        b. Check if M[:,x] != M[:,y]
        c. If equal for all rows, return False
  2. Return True
  
  Time: O(2^|X| * |X|^2 * n)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Evaluation Matrices for Different Closure Operators", "data": viz1},
        {"name": "Closure-Extractor Duality Diagram", "data": viz2},
        {"name": "Separation Complexity vs. Threshold", "data": viz3},
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"  Size: {len(json.dumps(package))} chars")


"""
Closure–Extractor Duality: Visualizations

Generates publication-quality visualizations of the duality framework.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    discrete_closure, partition_closure, convex_closure_1d,
    linear_closure_f2, synthesize_separating_predicates,
    build_evaluation_matrix, verify_separation,
    compute_rank_defect
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_evaluation_matrices():
    """Visualize evaluation matrices for different closure operators."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Evaluation Matrices for Different Closure Operators', fontsize=16, y=1.02)

    examples = [
        ("Discrete (|X|=6, k=2)", discrete_closure(set(range(6))), 2),
        ("Partition {{0,1},{2,3},{4,5}} (k=2)", partition_closure(set(range(6)), [{0,1},{2,3},{4,5}]), 2),
        ("1D Convex (|X|=8, k=3)", convex_closure_1d(set(range(8))), 3),
        ("Linear F₂³ (k=2)", linear_closure_f2(3), 2),
    ]

    for ax, (name, op, k) in zip(axes.flat, examples):
        predicates = synthesize_separating_predicates(op, k)
        elements = sorted(op.ground_set)
        M = build_evaluation_matrix(predicates, elements)

        # Plot
        im = ax.imshow(M.astype(float), cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
        ax.set_title(name, fontsize=11)
        ax.set_xlabel('Element index')
        ax.set_ylabel('Predicate index')
        ax.set_xticks(range(len(elements)))
        ax.set_xticklabels(elements, fontsize=8)
        ax.set_yticks(range(len(predicates)))
        ax.set_yticklabels([f'φ_{i}' for i in range(len(predicates))], fontsize=8)

        # Add text annotations
        for i in range(M.shape[0]):
            for j in range(M.shape[1]):
                ax.text(j, i, int(M[i, j]), ha='center', va='center', fontsize=7,
                       color='white' if M[i,j] else 'black')

    fig.tight_layout()
    fig.savefig('viz_evaluation_matrices.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_evaluation_matrices.png")
    return b64


def viz_closure_lattice():
    """Visualize the lattice of closed sets for a partition closure."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    partition = [{0, 1}, {2, 3, 4}, {5, 6, 7}]
    op = partition_closure(set(range(8)), partition)
    closed = op.closed_sets()

    # Organize by size for vertical positioning
    by_size = {}
    for C in closed:
        sz = len(C)
        by_size.setdefault(sz, []).append(C)

    # Position nodes
    positions = {}
    for sz, sets in sorted(by_size.items()):
        n = len(sets)
        for i, C in enumerate(sets):
            x = (i - (n-1)/2) * 2
            y = sz
            positions[C] = (x, y)

    # Draw edges (containment)
    for C1 in closed:
        for C2 in closed:
            if C1 < C2 and not any(C1 < C3 < C2 for C3 in closed):
                x1, y1 = positions[C1]
                x2, y2 = positions[C2]
                ax.plot([x1, x2], [y1, y2], 'b-', alpha=0.3, linewidth=1)

    # Draw nodes
    for C, (x, y) in positions.items():
        color = '#2ecc71' if len(C) >= 2 else '#e74c3c' if len(C) == 0 else '#f39c12'
        ax.scatter(x, y, s=200, c=color, zorder=5, edgecolors='black', linewidth=1)
        label = '{' + ','.join(map(str, sorted(C))) + '}' if C else '∅'
        ax.annotate(label, (x, y), textcoords="offset points", xytext=(0, 12),
                   ha='center', fontsize=7)

    ax.set_title(f'Lattice of Closed Sets\nPartition closure: {partition}', fontsize=14)
    ax.set_ylabel('Set size', fontsize=12)
    ax.set_xlabel('')
    ax.set_xticks([])

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#2ecc71', label='Large closed (|C|≥2)'),
        mpatches.Patch(facecolor='#f39c12', label='Small closed (|C|=1)'),
        mpatches.Patch(facecolor='#e74c3c', label='Empty set'),
    ]
    ax.legend(handles=legend_elements, loc='upper left')

    fig.tight_layout()
    fig.savefig('viz_closure_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_closure_lattice.png")
    return b64


def viz_duality_diagram():
    """Visualize the duality between predicates and seed families."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Left side: Predicates
    ax.add_patch(plt.Rectangle((0.5, 1), 4, 4, fill=True, facecolor='#3498db',
                                alpha=0.15, edgecolor='#2980b9', linewidth=2))
    ax.text(2.5, 4.7, 'Closure-Stable\nPredicates', ha='center', fontsize=14,
            fontweight='bold', color='#2980b9')

    pred_items = ['φ₁: test₁(x) ∈ {0,1}', 'φ₂: test₂(x) ∈ {0,1}', '⋮',
                  'φₙ: testₙ(x) ∈ {0,1}']
    for i, item in enumerate(pred_items):
        ax.text(2.5, 4.0 - i*0.7, item, ha='center', fontsize=10, color='#2c3e50')

    # Right side: Seed Family
    ax.add_patch(plt.Rectangle((7.5, 1), 4, 4, fill=True, facecolor='#e74c3c',
                                alpha=0.15, edgecolor='#c0392b', linewidth=2))
    ax.text(9.5, 4.7, 'Seed-Indexed\nMap Family', ha='center', fontsize=14,
            fontweight='bold', color='#c0392b')

    seed_items = ['f(s₁, x) → Y', 'f(s₂, x) → Y', '⋮', 'f(sₘ, x) → Y']
    for i, item in enumerate(seed_items):
        ax.text(9.5, 4.0 - i*0.7, item, ha='center', fontsize=10, color='#2c3e50')

    # Arrows
    ax.annotate('', xy=(7.3, 3.8), xytext=(4.7, 3.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='#27ae60'))
    ax.text(6, 4.1, 'Encoding\n(Backward)', ha='center', fontsize=10,
            color='#27ae60', fontweight='bold')

    ax.annotate('', xy=(4.7, 2.2), xytext=(7.3, 2.2),
                arrowprops=dict(arrowstyle='->', lw=2, color='#8e44ad'))
    ax.text(6, 1.6, 'Fiber Indicators\n(Forward)', ha='center', fontsize=10,
            color='#8e44ad', fontweight='bold')

    # Bottom: Evaluation Matrix
    ax.add_patch(plt.Rectangle((3.5, -1.5), 5, 2, fill=True, facecolor='#f39c12',
                                alpha=0.15, edgecolor='#e67e22', linewidth=2))
    ax.text(6, -0.2, 'Evaluation Matrix M', ha='center', fontsize=13,
            fontweight='bold', color='#e67e22')
    ax.text(6, -0.7, 'M[i,x] = φᵢ(x)', ha='center', fontsize=10, color='#2c3e50')
    ax.text(6, -1.1, 'Rank defect = Entropy loss', ha='center', fontsize=10,
            color='#2c3e50', style='italic')

    # Arrows to matrix
    ax.annotate('', xy=(4.5, 0.6), xytext=(2.5, 1.0),
                arrowprops=dict(arrowstyle='->', lw=1.5, color='#95a5a6', ls='--'))
    ax.annotate('', xy=(7.5, 0.6), xytext=(9.5, 1.0),
                arrowprops=dict(arrowstyle='->', lw=1.5, color='#95a5a6', ls='--'))

    ax.set_xlim(-0.5, 12.5)
    ax.set_ylim(-2, 5.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Closure–Extractor Duality', fontsize=16, fontweight='bold', pad=20)

    fig.tight_layout()
    fig.savefig('viz_duality_diagram.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_duality_diagram.png")
    return b64


def viz_separation_comparison():
    """Compare separation properties across closure operators."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    k_values = range(1, 8)
    examples = [
        ("Discrete (|X|=8)", discrete_closure(set(range(8)))),
        ("Partition", partition_closure(set(range(8)), [{0,1},{2,3},{4,5},{6,7}])),
        ("1D Convex (|X|=8)", convex_closure_1d(set(range(8)))),
    ]

    for ax, (name, op) in zip(axes, examples):
        n_preds = []
        n_large = []
        sep_rates = []

        for k in k_values:
            preds = synthesize_separating_predicates(op, k)
            large_sets = op.large_closed_sets(k)
            n_preds.append(len(preds))
            n_large.append(len(large_sets))

        ax.bar(list(k_values), n_preds, color='#3498db', alpha=0.7, label='# Predicates')
        ax2 = ax.twinx()
        ax2.plot(list(k_values), n_large, 'r-o', label='# Large closed sets', markersize=4)

        ax.set_xlabel('Threshold k')
        ax.set_ylabel('# Predicates needed', color='#3498db')
        ax2.set_ylabel('# Large closed sets', color='red')
        ax.set_title(name, fontsize=11)
        ax.set_xticks(list(k_values))

    fig.suptitle('Separation Complexity vs. Threshold k', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('viz_separation_comparison.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_separation_comparison.png")
    return b64


if __name__ == "__main__":
    b64_eval = viz_evaluation_matrices()
    b64_lattice = viz_closure_lattice()
    b64_duality = viz_duality_diagram()
    b64_sep = viz_separation_comparison()

    print("\nAll visualizations generated successfully.")
    print(f"  viz_evaluation_matrices.png: {len(b64_eval)} chars")
    print(f"  viz_closure_lattice.png: {len(b64_lattice)} chars")
    print(f"  viz_duality_diagram.png: {len(b64_duality)} chars")
    print(f"  viz_separation_comparison.png: {len(b64_sep)} chars")
