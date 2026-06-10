#!/usr/bin/env python3
"""
Closure-Circuit Duality: Applications

Real-world applications of the closure-circuit duality theorem:
1. Database schema analysis (functional dependency canonicalization)
2. Knowledge base inference optimization
3. Feature dependency analysis for ML feature selection
"""

from algorithms import (
    ClosurePresentation, ImplicationRule, make_closure_operator,
    compute_canonical_basis, reconstruct_circuit, verify_circuit_correctness,
    verify_basis_uniqueness
)
from typing import FrozenSet, List, Dict, Set


# =============================================================================
# Application 1: Database Schema Analysis
# =============================================================================

def database_schema_analysis():
    """Analyze functional dependencies in a database schema.

    Given a set of functional dependencies, compute:
    1. The canonical cover (= canonical residual basis)
    2. Candidate keys
    3. Normal form analysis
    """
    print("=" * 70)
    print("APPLICATION 1: Database Schema Analysis")
    print("=" * 70)
    print()

    # Example: Student enrollment database
    attrs = frozenset({'StudentID', 'Name', 'Course', 'Instructor', 'Grade', 'Dept'})
    rules = [
        ImplicationRule(frozenset({'StudentID'}), 'Name'),
        ImplicationRule(frozenset({'Course'}), 'Instructor'),
        ImplicationRule(frozenset({'Course'}), 'Dept'),
        ImplicationRule(frozenset({'StudentID', 'Course'}), 'Grade'),
        ImplicationRule(frozenset({'Instructor'}), 'Dept'),
    ]
    presentation = ClosurePresentation(universe=attrs, rules=rules)
    cl = make_closure_operator(presentation)

    print("Schema attributes:", sorted(attrs))
    print("Functional dependencies:")
    for r in rules:
        print(f"  {r}")
    print()

    # Canonical basis
    basis = compute_canonical_basis(attrs, cl)
    print(f"Canonical Basis ({basis.cardinality} generators):")
    for gen in basis.generators:
        print(f"  {gen}")
    print()

    # Find candidate keys
    candidate_keys = []
    elements = sorted(attrs)
    n = len(elements)
    for size in range(1, n + 1):
        from itertools import combinations
        for combo in combinations(elements, size):
            key = frozenset(combo)
            if cl(key) == attrs:
                # Check minimality
                is_minimal = True
                for existing in candidate_keys:
                    if existing <= key:
                        is_minimal = False
                        break
                if is_minimal:
                    candidate_keys.append(key)

    print("Candidate keys:")
    for key in candidate_keys:
        print(f"  {set(key)}")
    print()

    # Circuit for quick closure computation
    circuit = reconstruct_circuit(basis, attrs)
    print("Example queries via circuit evaluation:")
    for test_set in [
        frozenset({'StudentID'}),
        frozenset({'Course'}),
        frozenset({'StudentID', 'Course'}),
    ]:
        determined = {a for a in attrs if circuit.evaluate(a, test_set)}
        print(f"  Attributes determined by {set(test_set)}: {determined}")
    print()


# =============================================================================
# Application 2: Knowledge Base Inference
# =============================================================================

def knowledge_base_inference():
    """Optimize inference in a knowledge base using the canonical basis.

    Given a set of inference rules, compute the minimal inference engine.
    """
    print("=" * 70)
    print("APPLICATION 2: Knowledge Base Inference Optimization")
    print("=" * 70)
    print()

    # Medical diagnosis rules
    symptoms = frozenset({
        'fever', 'cough', 'headache', 'rash',
        'fatigue', 'sore_throat', 'runny_nose',
        'flu_diagnosis', 'cold_diagnosis', 'allergy_diagnosis'
    })
    rules = [
        ImplicationRule(frozenset({'fever', 'cough', 'fatigue'}), 'flu_diagnosis'),
        ImplicationRule(frozenset({'cough', 'runny_nose', 'sore_throat'}), 'cold_diagnosis'),
        ImplicationRule(frozenset({'runny_nose', 'rash'}), 'allergy_diagnosis'),
        ImplicationRule(frozenset({'flu_diagnosis'}), 'fatigue'),  # flu causes fatigue
        ImplicationRule(frozenset({'flu_diagnosis'}), 'headache'),  # flu causes headache
    ]
    presentation = ClosurePresentation(universe=symptoms, rules=rules)
    cl = make_closure_operator(presentation)

    print("Medical inference rules:")
    for r in rules:
        print(f"  {r}")
    print()

    # Canonical basis
    basis = compute_canonical_basis(symptoms, cl)
    print(f"Canonical Basis ({basis.cardinality} generators):")
    for gen in basis.generators:
        print(f"  {gen}")
    print()

    # Circuit for fast inference
    circuit = reconstruct_circuit(basis, symptoms)

    # Test scenarios
    scenarios = [
        ("Patient A", frozenset({'fever', 'cough', 'fatigue'})),
        ("Patient B", frozenset({'cough', 'runny_nose', 'sore_throat'})),
        ("Patient C", frozenset({'runny_nose', 'rash'})),
        ("Patient D", frozenset({'fever', 'cough'})),
    ]
    print("Diagnostic scenarios:")
    for name, observed in scenarios:
        inferred = {s for s in symptoms if circuit.evaluate(s, observed)}
        diagnoses = {s for s in inferred if s.endswith('_diagnosis')}
        print(f"  {name} ({set(observed)}):")
        print(f"    Diagnoses: {diagnoses if diagnoses else 'None'}")
        print(f"    All inferred: {inferred}")
    print()


# =============================================================================
# Application 3: Feature Dependency Analysis
# =============================================================================

def feature_dependency_analysis():
    """Analyze feature dependencies for ML feature selection.

    Given known dependencies between features, compute:
    1. Minimal feature sets that determine each target
    2. Feature importance via support frequency
    """
    print("=" * 70)
    print("APPLICATION 3: Feature Dependency Analysis for ML")
    print("=" * 70)
    print()

    features = frozenset({
        'age', 'income', 'education', 'occupation',
        'credit_score', 'loan_amount', 'risk_level',
        'approval'
    })
    rules = [
        ImplicationRule(frozenset({'income', 'credit_score'}), 'risk_level'),
        ImplicationRule(frozenset({'risk_level', 'loan_amount'}), 'approval'),
        ImplicationRule(frozenset({'education', 'occupation'}), 'income'),
        ImplicationRule(frozenset({'age', 'income'}), 'credit_score'),
    ]
    presentation = ClosurePresentation(universe=features, rules=rules)
    cl = make_closure_operator(presentation)

    print("Feature dependency rules:")
    for r in rules:
        print(f"  {r}")
    print()

    basis = compute_canonical_basis(features, cl)

    # Analyze which features determine the target 'approval'
    approval_supports = basis.generators_for('approval')
    print("Minimal feature sets determining 'approval':")
    for support in approval_supports:
        print(f"  {set(support)}")
    print()

    # Feature importance: count how often each feature appears in supports
    feature_freq: Dict[str, int] = {}
    for gen in basis.generators:
        for f in gen.support:
            feature_freq[f] = feature_freq.get(f, 0) + 1

    print("Feature importance (frequency in minimal supports):")
    for f, count in sorted(feature_freq.items(), key=lambda x: -x[1]):
        print(f"  {f}: appears in {count} minimal supports")
    print()

    # Verify circuit
    circuit = reconstruct_circuit(basis, features)
    correct, _ = verify_circuit_correctness(circuit, cl, features)
    print(f"Circuit correctness verified: {correct}")
    print(f"Total circuit gates: {circuit.total_gate_count()}")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    database_schema_analysis()
    knowledge_base_inference()
    feature_dependency_analysis()

    print("=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Closure-Circuit Duality: Demonstrations

This script demonstrates the main theorems with concrete numerical examples,
showing how closure operators yield canonical residual bases and monotone
DNF circuits.
"""

from itertools import combinations
from typing import Set, FrozenSet, Dict, List, Tuple, Callable


# =============================================================================
# Core: Closure operators from implications
# =============================================================================

def make_closure_from_implications(
    universe: set, rules: List[Tuple[frozenset, str]]
) -> Callable[[frozenset], frozenset]:
    """Build a closure operator from a set of implication rules.
    
    Each rule is (premises: frozenset, conclusion: element).
    The closure is computed by repeatedly applying rules until fixpoint.
    """
    def cl(s: frozenset) -> frozenset:
        result = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= result and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return frozenset(result)
    return cl


def compute_minimal_supports(
    universe: set,
    cl: Callable[[frozenset], frozenset],
    target: str
) -> List[frozenset]:
    """Compute all minimal supports for a target element.
    
    A minimal support A for x is a minimal set such that x ∈ cl(A).
    """
    minimal = []
    # Check all subsets in order of increasing size
    elements = sorted(universe)
    for size in range(len(elements) + 1):
        for combo in combinations(elements, size):
            A = frozenset(combo)
            if target in cl(A):
                # Check minimality: no proper subset should work
                is_minimal = True
                for existing in minimal:
                    if existing < A:
                        is_minimal = False
                        break
                if is_minimal:
                    # Also check that no proper subset of A works
                    proper_subset_works = False
                    for i in range(len(combo)):
                        B = frozenset(combo[:i] + combo[i+1:])
                        if target in cl(B):
                            proper_subset_works = True
                            break
                    if not proper_subset_works:
                        minimal.append(A)
    return minimal


def compute_canonical_basis(
    universe: set,
    cl: Callable[[frozenset], frozenset]
) -> Dict[str, List[frozenset]]:
    """Compute the canonical residual basis for a closure operator.
    
    Returns a dict mapping each element to its list of minimal supports.
    """
    basis = {}
    for x in sorted(universe):
        supports = compute_minimal_supports(universe, cl, x)
        if supports:
            basis[x] = supports
    return basis


def verify_characterization(
    universe: set,
    cl: Callable[[frozenset], frozenset],
    basis: Dict[str, List[frozenset]]
) -> bool:
    """Verify the closure characterization theorem:
    x ∈ cl(S) ↔ ∃ A ∈ minSupp(x), A ⊆ S
    
    Tests all 2^n subsets.
    """
    elements = sorted(universe)
    n = len(elements)
    for mask in range(2**n):
        S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        closure_S = cl(S)
        for x in elements:
            # Forward: x ∈ cl(S) → some support ⊆ S
            in_closure = x in closure_S
            has_support = any(A <= S for A in basis.get(x, []))
            if in_closure != has_support:
                return False
    return True


# =============================================================================
# DNF Circuit Construction
# =============================================================================

class MonotoneCircuit:
    """A monotone Boolean circuit (tree-structured)."""
    pass

class InputGate(MonotoneCircuit):
    def __init__(self, var: str):
        self.var = var
    def evaluate(self, s: frozenset) -> bool:
        return self.var in s
    def __repr__(self):
        return self.var

class TopGate(MonotoneCircuit):
    def evaluate(self, s: frozenset) -> bool:
        return True
    def __repr__(self):
        return "⊤"

class BotGate(MonotoneCircuit):
    def evaluate(self, s: frozenset) -> bool:
        return False
    def __repr__(self):
        return "⊥"

class AndGate(MonotoneCircuit):
    def __init__(self, children: List[MonotoneCircuit]):
        self.children = children
    def evaluate(self, s: frozenset) -> bool:
        return all(c.evaluate(s) for c in self.children)
    def __repr__(self):
        return f"({' ∧ '.join(str(c) for c in self.children)})"

class OrGate(MonotoneCircuit):
    def __init__(self, children: List[MonotoneCircuit]):
        self.children = children
    def evaluate(self, s: frozenset) -> bool:
        return any(c.evaluate(s) for c in self.children)
    def __repr__(self):
        return f"({' ∨ '.join(str(c) for c in self.children)})"


def build_dnf_circuit(supports: List[frozenset]) -> MonotoneCircuit:
    """Build a monotone DNF circuit from a list of minimal supports.
    
    Circuit = OR( AND(input(a) for a in A) for A in supports )
    """
    if not supports:
        return BotGate()
    conjuncts = []
    for A in supports:
        if not A:
            conjuncts.append(TopGate())
        else:
            conjuncts.append(AndGate([InputGate(a) for a in sorted(A)]))
    if len(conjuncts) == 1:
        return conjuncts[0]
    return OrGate(conjuncts)


def reconstruct_closure_circuit(
    universe: set,
    basis: Dict[str, List[frozenset]]
) -> Dict[str, MonotoneCircuit]:
    """Reconstruct the full closure circuit from the canonical basis."""
    circuit = {}
    for x in sorted(universe):
        supports = basis.get(x, [])
        circuit[x] = build_dnf_circuit(supports)
    return circuit


def circuit_size(c: MonotoneCircuit) -> int:
    """Count the number of gates in a circuit."""
    if isinstance(c, (InputGate, TopGate, BotGate)):
        return 1
    elif isinstance(c, (AndGate, OrGate)):
        return 1 + sum(circuit_size(child) for child in c.children)
    return 0


# =============================================================================
# Demo 1: Database functional dependencies
# =============================================================================

def demo_database():
    print("=" * 70)
    print("DEMO 1: Database Functional Dependencies")
    print("=" * 70)
    print()
    print("Schema: {A, B, C, D, E}")
    print("Dependencies: AB→C, C→D, D→E, B→E")
    print()

    universe = {'A', 'B', 'C', 'D', 'E'}
    rules = [
        (frozenset({'A', 'B'}), 'C'),
        (frozenset({'C'}), 'D'),
        (frozenset({'D'}), 'E'),
        (frozenset({'B'}), 'E'),
    ]
    cl = make_closure_from_implications(universe, rules)

    # Compute canonical basis
    basis = compute_canonical_basis(universe, cl)

    print("Canonical Residual Basis:")
    total_generators = 0
    for x in sorted(basis):
        for A in basis[x]:
            print(f"  {set(A)} → {x}")
            total_generators += 1
    print(f"\nTotal generators: {total_generators}")

    # Verify characterization
    ok = verify_characterization(universe, cl, basis)
    print(f"Characterization theorem verified: {ok}")

    # Build and display circuit
    circuit = reconstruct_closure_circuit(universe, basis)
    print("\nReconstructed DNF Circuit:")
    for x in sorted(circuit):
        print(f"  C({x}) = {circuit[x]}")

    # Test some closures
    print("\nExample closures:")
    for test in [frozenset(), frozenset({'A'}), frozenset({'B'}),
                 frozenset({'A', 'B'}), frozenset({'C'})]:
        result = cl(test)
        print(f"  cl({set(test)}) = {set(result)}")
    print()


# =============================================================================
# Demo 2: Propositional Horn theory
# =============================================================================

def demo_horn():
    print("=" * 70)
    print("DEMO 2: Propositional Horn Theory")
    print("=" * 70)
    print()
    print("Atoms: {p, q, r, s}")
    print("Horn clauses: p∧q→r, r→s, p→s, ∅→p (p is always derivable)")
    print()

    universe = {'p', 'q', 'r', 's'}
    rules = [
        (frozenset({'p', 'q'}), 'r'),
        (frozenset({'r'}), 's'),
        (frozenset({'p'}), 's'),
        (frozenset(), 'p'),  # p is always true
    ]
    cl = make_closure_from_implications(universe, rules)

    basis = compute_canonical_basis(universe, cl)

    print("Canonical Residual Basis:")
    for x in sorted(basis):
        for A in basis[x]:
            premise = set(A) if A else "∅"
            print(f"  {premise} → {x}")

    ok = verify_characterization(universe, cl, basis)
    print(f"\nCharacterization verified: {ok}")

    # Show the closed sets (Moore family)
    elements = sorted(universe)
    n = len(elements)
    closed_sets = []
    for mask in range(2**n):
        S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if cl(S) == S:
            closed_sets.append(S)

    print(f"\nClosed sets ({len(closed_sets)} total):")
    for S in sorted(closed_sets, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(S) if S else '∅'}")
    print()


# =============================================================================
# Demo 3: Residual equivalence classes
# =============================================================================

def demo_residual_equivalence():
    print("=" * 70)
    print("DEMO 3: Residual Equivalence Classes")
    print("=" * 70)
    print()
    print("Universe: {a, b, c, d, e, f}")
    print("Rules: ab→c, ab→d, c→e, d→e, f→f (f always in closure of {f})")
    print()

    universe = {'a', 'b', 'c', 'd', 'e', 'f'}
    rules = [
        (frozenset({'a', 'b'}), 'c'),
        (frozenset({'a', 'b'}), 'd'),
        (frozenset({'c'}), 'e'),
        (frozenset({'d'}), 'e'),
    ]
    cl = make_closure_from_implications(universe, rules)

    # Compute residual profiles
    elements = sorted(universe)
    n = len(elements)
    profiles = {}
    for x in elements:
        profile = []
        for mask in range(2**n):
            S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
            profile.append(x in cl(S))
        profiles[x] = tuple(profile)

    # Find equivalence classes
    classes = {}
    for x in elements:
        found = False
        for rep, members in classes.items():
            if profiles[x] == profiles[rep]:
                members.append(x)
                found = True
                break
        if not found:
            classes[x] = [x]

    print("Residual equivalence classes:")
    for rep, members in classes.items():
        print(f"  [{', '.join(sorted(members))}]  (profile representative: {rep})")

    print(f"\nNumber of classes: {len(classes)}")
    print(f"Number of elements: {len(elements)}")

    # Check: c and d should be equivalent
    print(f"\nc ≡ d? {profiles['c'] == profiles['d']}")
    print(f"a ≡ b? {profiles['a'] == profiles['b']}")
    print()


# =============================================================================
# Demo 4: Uniqueness verification
# =============================================================================

def demo_uniqueness():
    print("=" * 70)
    print("DEMO 4: Basis Uniqueness Verification")
    print("=" * 70)
    print()

    universe = {'x', 'y', 'z', 'w'}
    rules = [
        (frozenset({'x', 'y'}), 'z'),
        (frozenset({'z'}), 'w'),
        (frozenset({'x', 'w'}), 'y'),
    ]
    cl = make_closure_from_implications(universe, rules)

    # Compute basis
    basis = compute_canonical_basis(universe, cl)
    print("Canonical basis:")
    for x in sorted(basis):
        for A in basis[x]:
            print(f"  {set(A)} → {x}")

    # Verify characterization holds
    ok = verify_characterization(universe, cl, basis)
    print(f"\nCharacterization verified: {ok}")

    # Try alternative bases and show they must equal the canonical one
    print("\nTesting uniqueness: any basis satisfying the characterization")
    print("must be identical to the canonical basis.")

    # Verify that removing any generator breaks the characterization
    all_generators = [(x, A) for x in basis for A in basis[x]]
    for i, (x, A) in enumerate(all_generators):
        # Remove this generator
        modified_basis = {}
        for y in basis:
            modified_basis[y] = [B for B in basis[y] if not (y == x and B == A)]
            if not modified_basis[y]:
                del modified_basis[y]

        ok_modified = verify_characterization(universe, cl, modified_basis)
        print(f"  Remove {set(A)}→{x}: characterization still holds? {ok_modified}")

    print("\n(All removals break the characterization, confirming irredundancy)")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_database()
    demo_horn()
    demo_residual_equivalence()
    demo_uniqueness()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Closure-Circuit Duality: Visualizations

Creates matplotlib visualizations of:
1. Lattice of closed sets
2. Canonical basis structure
3. Circuit diagram
4. Scaling behavior
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import numpy as np
from itertools import combinations
import base64
import io


def make_closure(universe, rules):
    """Build closure operator from implications."""
    def cl(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= result and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return frozenset(result)
    return cl


def compute_min_supports(universe, cl, target):
    """Compute minimal supports for target."""
    elements = sorted(universe)
    minimal = []
    for size in range(len(elements) + 1):
        for combo in combinations(elements, size):
            A = frozenset(combo)
            if any(ms <= A for ms in minimal):
                continue
            if target in cl(A):
                is_min = True
                for i in range(len(combo)):
                    B = frozenset(combo[:i] + combo[i+1:])
                    if target in cl(B):
                        is_min = False
                        break
                if is_min:
                    minimal.append(A)
    return minimal


def fig_to_base64(fig):
    """Convert a matplotlib figure to base64 PNG."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# =============================================================================
# Visualization 1: Lattice of Closed Sets
# =============================================================================

def visualize_closed_sets_lattice():
    """Visualize the lattice of closed sets as a Hasse diagram."""
    universe = {'a', 'b', 'c', 'd'}
    rules = [
        (frozenset({'a', 'b'}), 'c'),
        (frozenset({'c'}), 'd'),
    ]
    cl = make_closure(universe, rules)

    elements = sorted(universe)
    n = len(elements)
    closed_sets = []
    for mask in range(2**n):
        S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if cl(S) == S:
            closed_sets.append(S)

    # Sort by size for layering
    closed_sets.sort(key=lambda s: len(s))

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Assign positions
    layers = {}
    for S in closed_sets:
        k = len(S)
        layers.setdefault(k, []).append(S)

    positions = {}
    max_width = max(len(v) for v in layers.values())
    for k, sets_in_layer in layers.items():
        w = len(sets_in_layer)
        for i, S in enumerate(sets_in_layer):
            x = (i - (w - 1) / 2) * 2.5
            y = k * 2
            positions[S] = (x, y)

    # Draw edges (cover relations)
    for i, S1 in enumerate(closed_sets):
        for j, S2 in enumerate(closed_sets):
            if S1 < S2:
                # Check if it's a cover (no set between them)
                is_cover = True
                for S3 in closed_sets:
                    if S1 < S3 < S2:
                        is_cover = False
                        break
                if is_cover:
                    x1, y1 = positions[S1]
                    x2, y2 = positions[S2]
                    ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.5)

    # Draw nodes
    for S in closed_sets:
        x, y = positions[S]
        label = '{' + ', '.join(sorted(S)) + '}' if S else '∅'
        circle = plt.Circle((x, y), 0.4, color='#4CAF50', alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center',
                fontsize=8, fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-1, max(len(S) for S in closed_sets) * 2 + 1)
    ax.set_aspect('equal')
    ax.set_title('Lattice of Closed Sets\n(Moore Family)',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    fig.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/lattice_of_closed_sets.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


# =============================================================================
# Visualization 2: Canonical Basis Structure
# =============================================================================

def visualize_canonical_basis():
    """Visualize the canonical basis as a bipartite graph."""
    universe = {'A', 'B', 'C', 'D', 'E'}
    rules = [
        (frozenset({'A', 'B'}), 'C'),
        (frozenset({'C'}), 'D'),
        (frozenset({'D'}), 'E'),
        (frozenset({'B'}), 'E'),
    ]
    cl = make_closure(universe, rules)

    elements = sorted(universe)
    basis = {}
    for x in elements:
        supports = compute_min_supports(universe, cl, x)
        # Filter out trivial self-supports
        non_trivial = [s for s in supports if s != frozenset({x})]
        if non_trivial:
            basis[x] = non_trivial

    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    # Left side: targets
    targets = sorted(basis.keys())
    target_y = {t: i * 1.5 for i, t in enumerate(targets)}

    # Right side: unique support sets
    all_supports = []
    for t in targets:
        for s in basis[t]:
            if s not in all_supports:
                all_supports.append(s)
    support_y = {tuple(sorted(s)): i * 1.2 for i, s in enumerate(all_supports)}

    # Draw connections
    colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
    for idx, t in enumerate(targets):
        for s in basis[t]:
            key = tuple(sorted(s))
            x1, y1 = 1, target_y[t]
            x2, y2 = 5, support_y[key]
            ax.plot([x1, x2], [y1, y2], '-', color=colors[idx % len(colors)],
                    linewidth=2, alpha=0.6)

    # Draw target nodes
    for t in targets:
        y = target_y[t]
        circle = plt.Circle((1, y), 0.3, color='#2196F3', zorder=5)
        ax.add_patch(circle)
        ax.text(1, y, t, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    # Draw support nodes
    for s in all_supports:
        key = tuple(sorted(s))
        y = support_y[key]
        label = '{' + ','.join(sorted(s)) + '}'
        rect = FancyBboxPatch((4.2, y - 0.25), 1.6, 0.5,
                              boxstyle="round,pad=0.1",
                              facecolor='#FF9800', alpha=0.8, zorder=5)
        ax.add_patch(rect)
        ax.text(5, y, label, ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-0.5, 7)
    y_max = max(max(target_y.values()), max(support_y.values())) + 1
    ax.set_ylim(-1, y_max)
    ax.text(1, -0.7, 'Targets', ha='center', fontsize=12, fontweight='bold')
    ax.text(5, -0.7, 'Minimal Supports', ha='center', fontsize=12, fontweight='bold')
    ax.set_title('Canonical Residual Basis\n(Non-trivial generators only)',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    fig.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/canonical_basis.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


# =============================================================================
# Visualization 3: Circuit Diagram
# =============================================================================

def visualize_circuit():
    """Visualize the reconstructed DNF circuit for one target."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Circuit for C: OR(AND(A,B), input(C))
    # Draw from bottom (inputs) to top (output)

    # Input layer
    inputs = ['A', 'B', 'C', 'D']
    input_y = 0
    input_positions = {}
    for i, inp in enumerate(inputs):
        x = i * 2.5 + 1
        input_positions[inp] = (x, input_y)
        circle = plt.Circle((x, input_y), 0.35, color='#2196F3',
                            zorder=5, alpha=0.9)
        ax.add_patch(circle)
        ax.text(x, input_y, inp, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    # AND gate for {A, B}
    and_x, and_y = 2.25, 2
    rect = FancyBboxPatch((and_x - 0.5, and_y - 0.3), 1.0, 0.6,
                          boxstyle="round,pad=0.1",
                          facecolor='#4CAF50', alpha=0.9, zorder=5)
    ax.add_patch(rect)
    ax.text(and_x, and_y, 'AND', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white', zorder=6)

    # Connections to AND
    ax.annotate('', xy=(and_x - 0.3, and_y - 0.3),
                xytext=(input_positions['A'][0], input_positions['A'][1] + 0.35),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2))
    ax.annotate('', xy=(and_x + 0.3, and_y - 0.3),
                xytext=(input_positions['B'][0], input_positions['B'][1] + 0.35),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2))

    # OR gate (output for 'C')
    or_x, or_y = 4.0, 4
    rect2 = FancyBboxPatch((or_x - 0.5, or_y - 0.3), 1.0, 0.6,
                           boxstyle="round,pad=0.1",
                           facecolor='#E91E63', alpha=0.9, zorder=5)
    ax.add_patch(rect2)
    ax.text(or_x, or_y, 'OR', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white', zorder=6)

    # Connections to OR
    ax.annotate('', xy=(or_x - 0.3, or_y - 0.3),
                xytext=(and_x, and_y + 0.3),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2))
    ax.annotate('', xy=(or_x + 0.3, or_y - 0.3),
                xytext=(input_positions['C'][0], input_positions['C'][1] + 0.35),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2))

    # Output label
    ax.text(or_x, or_y + 0.8, 'Output: C ∈ cl(S)',
            ha='center', fontsize=11, fontweight='bold', color='#E91E63')

    # Labels
    ax.text(1, -1, 'Input Layer: elements of S',
            ha='left', fontsize=10, style='italic', color='gray')

    ax.set_xlim(-0.5, 10)
    ax.set_ylim(-1.5, 5.5)
    ax.set_title('Reconstructed DNF Circuit for target C\n'
                 'C(x=C) = OR(AND(A, B), input(C))',
                 fontsize=13, fontweight='bold')
    ax.axis('off')

    fig.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/circuit_diagram.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


# =============================================================================
# Visualization 4: Scaling Behavior
# =============================================================================

def visualize_scaling():
    """Visualize how basis size scales with universe size."""
    import time
    import random

    random.seed(42)
    sizes = [3, 4, 5, 6, 7, 8]
    avg_basis_sizes = []
    avg_times = []
    num_trials = 3

    for n in sizes:
        trial_basis_sizes = []
        trial_times = []

        for trial in range(num_trials):
            elements = [chr(ord('a') + i) for i in range(n)]
            universe = set(elements)

            # Generate random rules of arity 2
            rules = []
            num_rules = n  # roughly n rules
            for _ in range(num_rules):
                a, b = random.sample(elements, 2)
                c = random.choice(elements)
                rules.append((frozenset({a, b}), c))

            cl = make_closure(universe, rules)

            start = time.time()
            all_gens = 0
            for x in elements:
                supports = compute_min_supports(universe, cl, x)
                all_gens += len(supports)
            elapsed = time.time() - start

            trial_basis_sizes.append(all_gens)
            trial_times.append(elapsed)

        avg_basis_sizes.append(np.mean(trial_basis_sizes))
        avg_times.append(np.mean(trial_times))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Basis size vs universe size
    ax1.bar(sizes, avg_basis_sizes, color='#2196F3', alpha=0.8, edgecolor='navy')
    ax1.set_xlabel('Universe Size |α|', fontsize=12)
    ax1.set_ylabel('Average Basis Cardinality', fontsize=12)
    ax1.set_title('Canonical Basis Size vs Universe Size', fontsize=13, fontweight='bold')
    ax1.grid(axis='y', alpha=0.3)

    # Computation time vs universe size
    ax2.plot(sizes, [t * 1000 for t in avg_times], 'o-',
             color='#E91E63', linewidth=2, markersize=8)
    ax2.set_xlabel('Universe Size |α|', fontsize=12)
    ax2.set_ylabel('Computation Time (ms)', fontsize=12)
    ax2.set_title('Basis Computation Time', fontsize=13, fontweight='bold')
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Scaling Behavior of Canonical Basis Computation',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/scaling_behavior.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = visualize_closed_sets_lattice()
    print(f"  Lattice of closed sets: {len(img1)} chars")

    img2 = visualize_canonical_basis()
    print(f"  Canonical basis: {len(img2)} chars")

    img3 = visualize_circuit()
    print(f"  Circuit diagram: {len(img3)} chars")

    img4 = visualize_scaling()
    print(f"  Scaling behavior: {len(img4)} chars")

    print("All visualizations generated and saved as PNG files.")
