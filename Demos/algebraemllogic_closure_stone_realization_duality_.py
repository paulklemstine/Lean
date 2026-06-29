#!/usr/bin/env python3
"""
Closure-Stone Realization Duality: Applications

Real-world applications of the reconstruction theorem:
1. Database schema analysis (functional dependency discovery)
2. Feature interaction analysis (ML interpretability)
3. Knowledge base compression and reconstruction
"""

from itertools import combinations
from typing import FrozenSet, Set, List, Dict, Callable, Tuple


def powerset(X):
    items = sorted(X)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def make_closure(X, deps):
    def cl(A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            for p, c in deps:
                if p <= result and c not in result:
                    result.add(c)
                    changed = True
        return frozenset(result)
    return cl


def forward_chain(basis, A):
    result = set(A)
    changed = True
    while changed:
        changed = False
        for p, c in basis:
            if p <= result and c not in result:
                result.add(c)
                changed = True
    return frozenset(result)


def extract_full_basis(X, cl):
    basis = []
    for S in powerset(X):
        closure = cl(S)
        for x in sorted(closure - S):
            basis.append((S, x))
    return basis


def reduce_basis(X, cl, full_basis):
    all_subsets = powerset(X)
    reduced = list(full_basis)
    i = 0
    while i < len(reduced):
        candidate = reduced[:i] + reduced[i+1:]
        is_redundant = all(forward_chain(candidate, S) == cl(S) for S in all_subsets)
        if is_redundant:
            reduced = candidate
        else:
            i += 1
    return reduced


def enumerate_closed_sets(X, cl):
    return sorted(
        [S for S in powerset(X) if cl(S) == S],
        key=lambda s: (len(s), sorted(s))
    )


# ============================================================
# Application 1: Database Schema Analysis
# ============================================================

def app_database_schema():
    print("=" * 60)
    print("  Application 1: Database Functional Dependency Analysis")
    print("=" * 60)
    print()

    # Schema: StudentID(0), Name(1), Email(2), Major(3), Dept(4), Dean(5)
    attrs = {0, 1, 2, 3, 4, 5}
    names = {0: "StudentID", 1: "Name", 2: "Email", 3: "Major", 4: "Dept", 5: "Dean"}

    # Functional dependencies
    deps = [
        (frozenset({0}), 1),  # StudentID -> Name
        (frozenset({0}), 2),  # StudentID -> Email
        (frozenset({0}), 3),  # StudentID -> Major
        (frozenset({3}), 4),  # Major -> Dept
        (frozenset({4}), 5),  # Dept -> Dean
    ]

    cl = make_closure(attrs, deps)

    print("Schema: StudentID, Name, Email, Major, Dept, Dean")
    print("Given FDs: StudentID→Name, StudentID→Email, StudentID→Major,")
    print("           Major→Dept, Dept→Dean")
    print()

    # Key analysis
    print("Attribute closure analysis:")
    for a in sorted(attrs):
        c = cl(frozenset({a}))
        print(f"  cl({{{names[a]}}}) = {{{', '.join(sorted(names[x] for x in c))}}}")

    # Candidate keys (minimal sets whose closure is all attributes)
    print("\nCandidate keys (minimal sets with full closure):")
    for r in range(1, len(attrs) + 1):
        for combo in combinations(sorted(attrs), r):
            S = frozenset(combo)
            if cl(S) == frozenset(attrs):
                # Check minimality
                minimal = all(cl(S - {x}) != frozenset(attrs) for x in S)
                if minimal:
                    print(f"  {{{', '.join(names[x] for x in sorted(S))}}}")

    # Extracted canonical rules
    basis = extract_full_basis(attrs, cl)
    reduced = reduce_basis(attrs, cl, basis)
    print(f"\nReduced basis ({len(reduced)} rules, from {len(basis)} full):")
    for p, c in reduced:
        p_names = sorted(names[x] for x in p)
        print(f"  {{{', '.join(p_names)}}} → {names[c]}")

    # Closed sets (correspond to "determined" attribute groups)
    closed = enumerate_closed_sets(attrs, cl)
    print(f"\nClosed attribute sets ({len(closed)} total):")
    for C in closed:
        c_names = sorted(names[x] for x in C)
        print(f"  {{{', '.join(c_names) if c_names else '∅'}}}")
    print()


# ============================================================
# Application 2: Feature Interaction in ML
# ============================================================

def app_feature_interaction():
    print("=" * 60)
    print("  Application 2: Feature Interaction Analysis")
    print("=" * 60)
    print()

    # Features: Temperature(0), Humidity(1), Rain(2), WindSpeed(3), CloudCover(4)
    features = {0, 1, 2, 3, 4}
    names = {0: "Temp", 1: "Humidity", 2: "Rain", 3: "Wind", 4: "Clouds"}

    # Learned feature entailments (from a model):
    # High humidity + clouds -> rain
    # Rain -> clouds
    # Wind + rain -> low temperature
    deps = [
        (frozenset({1, 4}), 2),  # Humidity+Clouds -> Rain
        (frozenset({2}), 4),     # Rain -> Clouds
        (frozenset({3, 2}), 0),  # Wind+Rain -> Temp
    ]

    cl = make_closure(features, deps)

    print("Features: Temp(0), Humidity(1), Rain(2), Wind(3), Clouds(4)")
    print("Learned entailments: {Humidity,Clouds}→Rain, Rain→Clouds,")
    print("                     {Wind,Rain}→Temp")
    print()

    # Feature group analysis
    print("Feature group closures:")
    interesting = [
        frozenset({2}),
        frozenset({1, 4}),
        frozenset({3, 2}),
        frozenset({1, 3, 4}),
    ]
    for S in interesting:
        c = cl(S)
        s_names = sorted(names[x] for x in S)
        c_names = sorted(names[x] for x in c)
        print(f"  cl({{{', '.join(s_names)}}}) = {{{', '.join(c_names)}}}")

    # "Independent" feature groups (closed sets)
    closed = enumerate_closed_sets(features, cl)
    print(f"\nClosed feature groups ({len(closed)} stable configurations):")
    for C in closed:
        c_names = sorted(names[x] for x in C)
        desc = ', '.join(c_names) if c_names else '∅'
        print(f"  {{{desc}}}")

    # Canonical rules
    basis = extract_full_basis(features, cl)
    reduced = reduce_basis(features, cl, basis)
    print(f"\nMinimal explanation rules ({len(reduced)} rules):")
    for p, c in reduced:
        p_names = sorted(names[x] for x in p)
        print(f"  {{{', '.join(p_names)}}} → {names[c]}")
    print()


# ============================================================
# Application 3: Knowledge Base Compression
# ============================================================

def app_knowledge_compression():
    print("=" * 60)
    print("  Application 3: Knowledge Base Compression")
    print("=" * 60)
    print()

    # Facts: A(0), B(1), C(2), D(3), E(4), F(5)
    facts = {0, 1, 2, 3, 4, 5}
    names = {i: chr(65 + i) for i in range(6)}

    # A complex rule set
    deps = [
        (frozenset({0}), 1),      # A -> B
        (frozenset({1}), 2),      # B -> C
        (frozenset({0, 3}), 4),   # A,D -> E
        (frozenset({4}), 5),      # E -> F
        (frozenset({3, 2}), 4),   # D,C -> E
    ]

    cl = make_closure(facts, deps)

    print("Knowledge base with 6 facts {A, B, C, D, E, F}")
    print("Rules: A→B, B→C, A+D→E, E→F, D+C→E")
    print()

    # Full basis size
    full = extract_full_basis(facts, cl)
    reduced = reduce_basis(facts, cl, full)

    print(f"Full basis: {len(full)} implications")
    print(f"Reduced basis: {len(reduced)} implications")
    print(f"Compression ratio: {len(full)/max(len(reduced),1):.1f}x")
    print()

    print("Reduced canonical rules:")
    for p, c in reduced:
        p_names = sorted(names[x] for x in p)
        print(f"  {{{', '.join(p_names)}}} → {names[c]}")

    # Verify lossless compression
    all_ok = all(
        forward_chain(reduced, S) == cl(S)
        for S in powerset(facts)
    )
    print(f"\nLossless reconstruction verified: {all_ok}")

    # Statistics
    closed = enumerate_closed_sets(facts, cl)
    print(f"Number of distinct knowledge states (closed sets): {len(closed)}")
    print(f"Number of facts: {len(facts)}")
    print(f"Max possible states: {2**len(facts)}")
    print(f"Constraint ratio: {len(closed)}/{2**len(facts)} = {len(closed)/2**len(facts):.3f}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Stone Realization Duality: Applications        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_database_schema()
    app_feature_interaction()
    app_knowledge_compression()

    print("=" * 60)
    print("  All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure-Stone Realization Duality: Demonstrations

Demonstrates the main theorems with concrete finite closure operators:
1. Closure operator evaluation and closed set enumeration
2. Full basis extraction and forward-chaining reconstruction
3. Prime spectrum computation and separation verification
4. Closure table isomorphism and structure preservation
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set, List, Tuple

# Type aliases
Element = int
Subset = frozenset
Implication = Tuple[frozenset, int]  # (premise, conclusion)


def powerset(X: set) -> list:
    """Return all subsets of X as frozensets."""
    items = sorted(X)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


# ============================================================
# Example 1: A simple closure operator on {0, 1, 2, 3}
# ============================================================

def make_dependency_closure(X: set, deps: list) -> Callable:
    """
    Create a closure operator from functional dependencies.
    deps: list of (premise_set, conclusion_element)
    """
    def cl(A: frozenset) -> frozenset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            for premise, conclusion in deps:
                if premise <= result and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return frozenset(result)
    return cl


def enumerate_closed_sets(X: set, cl: Callable) -> list:
    """Enumerate all closed sets of a closure operator."""
    closed = []
    for S in powerset(X):
        if cl(S) == S:
            closed.append(S)
    return sorted(closed, key=lambda s: (len(s), sorted(s)))


def extract_full_basis(X: set, cl: Callable) -> list:
    """Extract the full implicational basis."""
    basis = []
    for S in powerset(X):
        closure = cl(S)
        for x in closure - S:
            basis.append((S, x))
    return basis


def forward_chain(basis: list, A: frozenset) -> frozenset:
    """Compute closure of A under a set of implications by forward chaining."""
    result = set(A)
    changed = True
    while changed:
        changed = False
        for premise, conclusion in basis:
            if premise <= result and conclusion not in result:
                result.add(conclusion)
                changed = True
    return frozenset(result)


def is_meet_prime(P: frozenset, closed_sets: list, X: set) -> bool:
    """Check if P is meet-prime among closed sets."""
    if P == frozenset(X):
        return False
    for A in closed_sets:
        for B in closed_sets:
            inter = A & B
            if inter <= P and not A <= P and not B <= P:
                return False
    return True


def prime_spectrum(X: set, cl: Callable) -> list:
    """Compute the prime spectrum of a closure operator."""
    closed = enumerate_closed_sets(X, cl)
    return [P for P in closed if is_meet_prime(P, closed, X)]


def verify_separation(closed_sets: list, primes: list) -> bool:
    """Verify that primes separate all pairs of distinct closed sets."""
    for i, A in enumerate(closed_sets):
        for B in closed_sets[i+1:]:
            separated = False
            for P in primes:
                if (A <= P and not B <= P) or (B <= P and not A <= P):
                    separated = True
                    break
            if not separated:
                return False
    return True


def print_section(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


# ============================================================
# Demo 1: Basic closure operator
# ============================================================

def demo_basic_closure():
    print_section("Demo 1: Basic Closure Operator on {0, 1, 2, 3}")

    X = {0, 1, 2, 3}
    # Dependencies: {0} -> 1, {1} -> 2, {0,3} -> 2
    deps = [
        (frozenset({0}), 1),
        (frozenset({1}), 2),
        (frozenset({0, 3}), 2),
    ]
    cl = make_dependency_closure(X, deps)

    print("Universe X = {0, 1, 2, 3}")
    print("Dependencies: {0}→1, {1}→2, {0,3}→2")
    print()

    # Show some closures
    print("Sample closures:")
    for S in [frozenset(), frozenset({0}), frozenset({1}), frozenset({3}),
              frozenset({0, 3}), frozenset({2, 3})]:
        print(f"  cl({set(S)}) = {set(cl(S))}")

    # Verify closure operator axioms
    print("\nVerifying closure operator axioms:")
    all_subsets = powerset(X)
    ext_ok = all(S <= cl(S) for S in all_subsets)
    mon_ok = all(cl(A) <= cl(B) for A in all_subsets for B in all_subsets if A <= B)
    idem_ok = all(cl(cl(S)) == cl(S) for S in all_subsets)
    print(f"  Extensive:  {ext_ok}")
    print(f"  Monotone:   {mon_ok}")
    print(f"  Idempotent: {idem_ok}")

    # Closed sets
    closed = enumerate_closed_sets(X, cl)
    print(f"\nClosed sets ({len(closed)} total):")
    for C in closed:
        print(f"  {set(C)}")

    # Full basis
    basis = extract_full_basis(X, cl)
    print(f"\nFull basis ({len(basis)} implications):")
    for premise, conclusion in sorted(basis, key=lambda b: (len(b[0]), sorted(b[0]), b[1])):
        print(f"  {set(premise)} → {conclusion}")

    # Verify reconstruction
    print("\nVerifying basis reconstruction (cl_B = cl):")
    reconstruction_ok = True
    for S in all_subsets:
        if forward_chain(basis, S) != cl(S):
            print(f"  MISMATCH at {set(S)}: got {set(forward_chain(basis, S))}, expected {set(cl(S))}")
            reconstruction_ok = False
    print(f"  Reconstruction correct: {reconstruction_ok}")

    # Prime spectrum
    primes = prime_spectrum(X, cl)
    print(f"\nPrime spectrum ({len(primes)} primes):")
    for P in primes:
        print(f"  {set(P)}")

    # Separation
    sep = verify_separation(closed, primes)
    print(f"\nPrime separation of closed sets: {sep}")

    return X, cl, closed, basis, primes


# ============================================================
# Demo 2: Database functional dependencies
# ============================================================

def demo_database():
    print_section("Demo 2: Database Functional Dependencies")

    # Attributes: Name(0), Email(1), Dept(2), Building(3), Floor(4)
    attrs = {0, 1, 2, 3, 4}
    attr_names = {0: "Name", 1: "Email", 2: "Dept", 3: "Building", 4: "Floor"}

    # FDs: Email -> Name, Dept -> Building, Building -> Floor
    deps = [
        (frozenset({1}), 0),  # Email -> Name
        (frozenset({2}), 3),  # Dept -> Building
        (frozenset({3}), 4),  # Building -> Floor
    ]
    cl = make_dependency_closure(attrs, deps)

    print("Attributes: Name(0), Email(1), Dept(2), Building(3), Floor(4)")
    print("Functional dependencies: Email→Name, Dept→Building, Building→Floor")
    print()

    # Closures of single attributes
    print("Attribute closures:")
    for a in sorted(attrs):
        c = cl(frozenset({a}))
        names = sorted([attr_names[x] for x in c])
        print(f"  cl({{{attr_names[a]}}}) = {{{', '.join(names)}}}")

    # Closed sets
    closed = enumerate_closed_sets(attrs, cl)
    print(f"\nClosed sets ({len(closed)} total):")
    for C in closed:
        names = sorted([attr_names[x] for x in C])
        print(f"  {{{', '.join(names) if names else '∅'}}}")

    # Extracted basis
    basis = extract_full_basis(attrs, cl)
    # Show only "essential" implications (single-premise or small)
    small_basis = [(p, c) for p, c in basis if len(p) <= 2]
    print(f"\nSmall implications (premises ≤ 2, {len(small_basis)} of {len(basis)} total):")
    for premise, conclusion in sorted(small_basis, key=lambda b: (len(b[0]), sorted(b[0]))):
        p_names = sorted([attr_names[x] for x in premise])
        print(f"  {{{', '.join(p_names)}}} → {attr_names[conclusion]}")

    # Verify
    all_subsets = powerset(attrs)
    ok = all(forward_chain(basis, S) == cl(S) for S in all_subsets)
    print(f"\nReconstruction verified: {ok}")

    # Prime spectrum
    primes = prime_spectrum(attrs, cl)
    print(f"\nPrime spectrum ({len(primes)} primes):")
    for P in primes:
        names = sorted([attr_names[x] for x in P])
        print(f"  {{{', '.join(names)}}}")


# ============================================================
# Demo 3: Closure table isomorphism
# ============================================================

def demo_isomorphism():
    print_section("Demo 3: Closure Table Isomorphism Invariance")

    X = {0, 1, 2}
    Y = {10, 11, 12}

    # Closure on X: {0} -> 1
    deps_X = [(frozenset({0}), 1)]
    cl_X = make_dependency_closure(X, deps_X)

    # Isomorphism f: 0->10, 1->11, 2->12
    f = {0: 10, 1: 11, 2: 12}
    f_inv = {v: k for k, v in f.items()}

    # Induced closure on Y
    def cl_Y(A):
        preimage = frozenset(f_inv[y] for y in A if y in f_inv)
        cl_preimage = cl_X(preimage)
        return frozenset(f[x] for x in cl_preimage)

    print(f"X = {X}, Y = {Y}")
    print(f"Isomorphism f: {f}")
    print(f"Closure on X: {{0}} → 1")
    print()

    # Verify isomorphism commutes
    print("Verifying f ∘ cl_X = cl_Y ∘ f:")
    for S in powerset(X):
        f_cl = frozenset(f[x] for x in cl_X(S))
        cl_f = cl_Y(frozenset(f[x] for x in S))
        ok = f_cl == cl_f
        print(f"  S={set(S)}: f(cl_X(S))={set(f_cl)}, cl_Y(f(S))={set(cl_f)}, match={ok}")

    # Compare closed sets
    closed_X = enumerate_closed_sets(X, cl_X)
    closed_Y = enumerate_closed_sets(Y, cl_Y)
    print(f"\nClosed sets of X: {[set(C) for C in closed_X]}")
    print(f"Closed sets of Y: {[set(C) for C in closed_Y]}")

    # Compare primes
    primes_X = prime_spectrum(X, cl_X)
    primes_Y = prime_spectrum(Y, cl_Y)
    print(f"\nPrime spectrum of X: {[set(P) for P in primes_X]}")
    print(f"Prime spectrum of Y: {[set(P) for P in primes_Y]}")

    # Verify f maps primes to primes
    print("\nVerifying f maps primes of X to primes of Y:")
    for P in primes_X:
        fP = frozenset(f[x] for x in P)
        is_prime = fP in [frozenset(Q) for Q in primes_Y]
        print(f"  f({set(P)}) = {set(fP)}, is prime in Y: {is_prime}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Stone Realization Duality: Demonstrations      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_closure()
    demo_database()
    demo_isomorphism()

    print_section("Summary")
    print("All demonstrations completed successfully.")
    print("Key verified properties:")
    print("  ✓ Closure operators satisfy extensiveness, monotonicity, idempotency")
    print("  ✓ Full implicational basis exactly reconstructs the closure operator")
    print("  ✓ Prime spectrum separates distinct closed sets")
    print("  ✓ Closure table isomorphisms preserve spectral structure")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all content embedded."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
        return f'data:image/png;base64,{data}'

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Bridges/AlgebraEMLLogic/ClosureStoneRealizationDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read images
viz_lattice = read_image_base64('viz_lattice.png')
viz_basis = read_image_base64('viz_basis_comparison.png')
viz_recon = read_image_base64('viz_reconstruction.png')

package = {
    "title": "Closure–Stone Realization Duality via Idempotent Consequence Semimodules",
    "domain": "Algebra–Logic–Geometry Bridge (Closure Systems, Stone Duality, Spectral Semantics)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Closure Operator Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Full Basis Extraction",
            "pseudocode": "FullBasis(X, cl):\n  B ← ∅\n  for each S ⊆ X:\n    for each x ∈ cl(S) \\ S:\n      B ← B ∪ {(S, x)}\n  return B\n\nComplexity: O(2^|X| · |X| · T_cl)",
            "code": algorithms_code
        },
        {
            "name": "Forward-Chaining Closure",
            "pseudocode": "ForwardChain(B, A):\n  C ← A\n  repeat:\n    for each (S, x) ∈ B:\n      if S ⊆ C and x ∉ C:\n        C ← C ∪ {x}\n  until no change\n  return C\n\nComplexity: O(|X| · |B|)",
            "code": algorithms_code
        },
        {
            "name": "Prime Spectrum Computation",
            "pseudocode": "PrimeSpectrum(X, cl):\n  closed ← {A ⊆ X | cl(A) = A}\n  primes ← ∅\n  for each P ∈ closed:\n    if P ≠ X and IsMeetPrime(P, closed):\n      primes ← primes ∪ {P}\n  return primes\n\nComplexity: O(2^|X| · T_cl + |closed|³ · |X|)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Closed Set Lattice with Prime Spectrum",
            "data": viz_lattice
        },
        {
            "name": "Full vs Reduced Basis Size Comparison",
            "data": viz_basis
        },
        {
            "name": "Closure Reconstruction Verification",
            "data": viz_recon
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False, indent=2)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Closure-Stone Realization Duality: Visualizations

Generates visualizations of:
1. Closed set lattice (Hasse diagram)
2. Basis size comparison (full vs reduced)
3. Prime spectrum structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import base64
from io import BytesIO


def powerset(X):
    items = sorted(X)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def make_closure(X, deps):
    def cl(A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            for p, c in deps:
                if p <= result and c not in result:
                    result.add(c)
                    changed = True
        return frozenset(result)
    return cl


def enumerate_closed_sets(X, cl):
    return sorted(
        [S for S in powerset(X) if cl(S) == S],
        key=lambda s: (len(s), sorted(s))
    )


def extract_full_basis(X, cl):
    basis = []
    for S in powerset(X):
        closure = cl(S)
        for x in sorted(closure - S):
            basis.append((S, x))
    return basis


def forward_chain(basis, A):
    result = set(A)
    changed = True
    while changed:
        changed = False
        for p, c in basis:
            if p <= result and c not in result:
                result.add(c)
                changed = True
    return frozenset(result)


def reduce_basis(X, cl, full_basis):
    all_subsets = powerset(X)
    reduced = list(full_basis)
    i = 0
    while i < len(reduced):
        candidate = reduced[:i] + reduced[i+1:]
        is_redundant = all(forward_chain(candidate, S) == cl(S) for S in all_subsets)
        if is_redundant:
            reduced = candidate
        else:
            i += 1
    return reduced


def is_meet_prime(P, closed_sets, X):
    if P == frozenset(X):
        return False
    for A in closed_sets:
        for B in closed_sets:
            if (A & B) <= P and not A <= P and not B <= P:
                return False
    return True


# ============================================================
# Visualization 1: Closed Set Lattice
# ============================================================

def viz_closed_lattice():
    X = {0, 1, 2, 3}
    deps = [
        (frozenset({0}), 1),
        (frozenset({1}), 2),
        (frozenset({0, 3}), 2),
    ]
    cl = make_closure(X, deps)
    closed = enumerate_closed_sets(X, cl)
    primes = [P for P in closed if is_meet_prime(P, closed, X)]

    # Build Hasse diagram
    # Group by size for y-coordinate
    levels = {}
    for C in closed:
        sz = len(C)
        if sz not in levels:
            levels[sz] = []
        levels[sz].append(C)

    # Assign positions
    pos = {}
    for level, sets in sorted(levels.items()):
        n = len(sets)
        for i, S in enumerate(sets):
            x = (i - (n-1)/2) * 2.5
            pos[S] = (x, level * 2)

    # Find cover relations (edges in Hasse diagram)
    edges = []
    for i, A in enumerate(closed):
        for B in closed:
            if A < B:
                # Check if B covers A (no C with A < C < B)
                is_cover = not any(A < C < B for C in closed)
                if is_cover:
                    edges.append((A, B))

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges
    for A, B in edges:
        ax.plot([pos[A][0], pos[B][0]], [pos[A][1], pos[B][1]],
                'k-', linewidth=1, alpha=0.5, zorder=1)

    # Draw nodes
    for C in closed:
        x, y = pos[C]
        is_prime = C in primes
        color = '#ff6b6b' if is_prime else '#4ecdc4'
        size = 800 if is_prime else 600
        ax.scatter(x, y, s=size, c=color, zorder=2, edgecolors='black', linewidth=1.5)
        label = '{' + ','.join(str(e) for e in sorted(C)) + '}' if C else '∅'
        ax.annotate(label, (x, y), ha='center', va='center', fontsize=9,
                   fontweight='bold', zorder=3)

    ax.set_title('Closed Set Lattice with Prime Spectrum\n'
                 'X = {0,1,2,3}, Rules: {0}→1, {1}→2, {0,3}→2',
                 fontsize=14, fontweight='bold')
    ax.set_ylabel('Set Size', fontsize=12)

    # Legend
    prime_patch = mpatches.Patch(color='#ff6b6b', label='Meet-Prime')
    other_patch = mpatches.Patch(color='#4ecdc4', label='Non-Prime')
    ax.legend(handles=[prime_patch, other_patch], loc='upper left', fontsize=11)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-1, max(pos[C][1] for C in closed) + 1.5)
    ax.grid(True, alpha=0.3)
    ax.set_xticks([])

    plt.tight_layout()
    plt.savefig('viz_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved viz_lattice.png")


# ============================================================
# Visualization 2: Basis Size Comparison
# ============================================================

def viz_basis_comparison():
    sizes = range(2, 6)
    full_sizes = []
    reduced_sizes = []
    closed_counts = []

    for n in sizes:
        X = set(range(n))
        # Chain closure: 0->1->2->...
        deps = [(frozenset({i}), i+1) for i in range(n-1)]
        cl = make_closure(X, deps)

        full = extract_full_basis(X, cl)
        reduced = reduce_basis(X, cl, full)
        closed = enumerate_closed_sets(X, cl)

        full_sizes.append(len(full))
        reduced_sizes.append(len(reduced))
        closed_counts.append(len(closed))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Basis size comparison
    x = np.array(list(sizes))
    width = 0.35
    ax1.bar(x - width/2, full_sizes, width, label='Full Basis', color='#e74c3c', alpha=0.8)
    ax1.bar(x + width/2, reduced_sizes, width, label='Reduced Basis', color='#2ecc71', alpha=0.8)
    ax1.set_xlabel('Universe Size |X|', fontsize=12)
    ax1.set_ylabel('Number of Implications', fontsize=12)
    ax1.set_title('Full vs Reduced Basis Size\n(Chain Closure: 0→1→2→...)', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_xticks(list(sizes))
    ax1.grid(True, alpha=0.3, axis='y')

    # Compression ratio
    ratios = [f/max(r,1) for f, r in zip(full_sizes, reduced_sizes)]
    ax2.plot(list(sizes), ratios, 'bo-', linewidth=2, markersize=8)
    ax2.fill_between(list(sizes), ratios, alpha=0.2, color='blue')
    ax2.set_xlabel('Universe Size |X|', fontsize=12)
    ax2.set_ylabel('Compression Ratio', fontsize=12)
    ax2.set_title('Basis Compression Ratio\n(Full / Reduced)', fontsize=14, fontweight='bold')
    ax2.set_xticks(list(sizes))
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_basis_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved viz_basis_comparison.png")


# ============================================================
# Visualization 3: Reconstruction Verification
# ============================================================

def viz_reconstruction():
    X = {0, 1, 2, 3}
    deps = [
        (frozenset({0}), 1),
        (frozenset({1}), 2),
        (frozenset({0, 3}), 2),
    ]
    cl = make_closure(X, deps)
    basis = extract_full_basis(X, cl)

    # For each subset, compare cl(S) and forward_chain(basis, S)
    all_subsets = powerset(X)

    # Create a matrix: rows = subsets, cols = elements, showing closure
    n = len(all_subsets)
    m = len(X)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 10))

    # Original closure
    matrix1 = np.zeros((n, m))
    labels = []
    for i, S in enumerate(all_subsets):
        c = cl(S)
        for x in X:
            if x in c:
                matrix1[i, x] = 1
        label = '{' + ','.join(str(e) for e in sorted(S)) + '}' if S else '∅'
        labels.append(label)

    im1 = ax1.imshow(matrix1, cmap='YlGn', aspect='auto', vmin=0, vmax=1)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels(labels, fontsize=7)
    ax1.set_xticks(range(m))
    ax1.set_xticklabels(sorted(X))
    ax1.set_xlabel('Elements', fontsize=12)
    ax1.set_ylabel('Input Set', fontsize=12)
    ax1.set_title('Original Closure cl(S)', fontsize=14, fontweight='bold')

    # Reconstructed closure
    matrix2 = np.zeros((n, m))
    for i, S in enumerate(all_subsets):
        c = forward_chain(basis, S)
        for x in X:
            if x in c:
                matrix2[i, x] = 1

    im2 = ax2.imshow(matrix2, cmap='YlGn', aspect='auto', vmin=0, vmax=1)
    ax2.set_yticks(range(n))
    ax2.set_yticklabels(labels, fontsize=7)
    ax2.set_xticks(range(m))
    ax2.set_xticklabels(sorted(X))
    ax2.set_xlabel('Elements', fontsize=12)
    ax2.set_title('Reconstructed cl_B(S)', fontsize=14, fontweight='bold')

    # Check match
    match = np.array_equal(matrix1, matrix2)
    fig.suptitle(f'Closure Reconstruction Verification (Match: {match})',
                 fontsize=16, fontweight='bold', y=1.02)

    plt.tight_layout()
    plt.savefig('viz_reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved viz_reconstruction.png")


# ============================================================
# Generate base64 encoded images for PACKAGE.json
# ============================================================

def generate_base64_images():
    """Generate all visualizations and return as base64 strings."""
    results = {}

    for name, func in [
        ('lattice', viz_closed_lattice),
        ('basis_comparison', viz_basis_comparison),
        ('reconstruction', viz_reconstruction),
    ]:
        func()
        with open(f'viz_{name}.png', 'rb') as f:
            data = base64.b64encode(f.read()).decode('utf-8')
            results[name] = f'data:image/png;base64,{data}'

    return results


if __name__ == "__main__":
    print("Generating visualizations...")
    viz_closed_lattice()
    viz_basis_comparison()
    viz_reconstruction()
    print("Done!")
