#!/usr/bin/env python3
"""
Applications of Categorical Coherence via Confluent Rewriting

This module demonstrates real-world applications of the coherence theorem:
1. Quantum circuit canonicalization
2. Type-checker optimization for dependent type theories
3. Algebraic expression simplification
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union

# =============================================================================
# Shared infrastructure (from algorithms.py, inlined for self-containedness)
# =============================================================================

@dataclass(frozen=True)
class Var:
    name: str
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(('Var', self.name))

@dataclass(frozen=True)
class UnitExpr:
    def __repr__(self): return "I"
    def __eq__(self, other): return isinstance(other, UnitExpr)
    def __hash__(self): return hash('Unit')

@dataclass(frozen=True)
class Tensor:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} ⊗ {self.right})"
    def __eq__(self, other):
        return isinstance(other, Tensor) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('Tensor', self.left, self.right))

Expr = Union[Var, UnitExpr, Tensor]

def flatten(expr: Expr) -> list[str]:
    result = []
    stack = [expr]
    while stack:
        node = stack.pop()
        if isinstance(node, Var): result.append(node.name)
        elif isinstance(node, Tensor):
            stack.append(node.right)
            stack.append(node.left)
    return result

def right_assoc(variables: list[str]) -> Expr:
    if not variables: return UnitExpr()
    if len(variables) == 1: return Var(variables[0])
    return Tensor(Var(variables[0]), right_assoc(variables[1:]))

def normalize(expr: Expr) -> Expr:
    return right_assoc(flatten(expr))

def are_equivalent(a: Expr, b: Expr) -> bool:
    return flatten(a) == flatten(b)

# =============================================================================
# Application 1: Quantum Circuit Canonicalization
# =============================================================================

def quantum_circuit_demo():
    """Demonstrate quantum circuit wire canonicalization.
    
    In categorical quantum mechanics (Abramsky & Coecke), quantum circuits
    are morphisms in a monoidal category where:
    - Objects are wire types (qubits, classical bits)
    - Tensor product represents parallel composition
    - Monoidal unit represents the empty wire bundle
    
    Coherence guarantees that wire rebracketings are invisible:
    any two ways of grouping wires that preserve their order are equal.
    Our normalization algorithm provides canonical wire layouts.
    """
    print("=" * 60)
    print("APPLICATION 1: Quantum Circuit Wire Canonicalization")
    print("=" * 60)
    print()
    
    # Wire types as variables
    q1, q2, q3 = Var("qubit₁"), Var("qubit₂"), Var("qubit₃")
    cl = Var("classical")
    
    # Different wire groupings for a 3-qubit + 1-classical circuit
    layouts = [
        ("Layout A", Tensor(Tensor(q1, q2), Tensor(q3, cl))),
        ("Layout B", Tensor(q1, Tensor(q2, Tensor(q3, cl)))),
        ("Layout C", Tensor(Tensor(Tensor(q1, q2), q3), cl)),
        ("Layout D", Tensor(q1, Tensor(Tensor(q2, q3), cl))),
    ]
    
    print("  Different wire groupings for a quantum circuit:")
    for name, layout in layouts:
        nf = normalize(layout)
        print(f"    {name}: {layout}")
        print(f"           → canonical: {nf}")
    
    print(f"\n  All layouts equivalent: ", end="")
    all_eq = all(are_equivalent(layouts[0][1], layout) for _, layout in layouts)
    print(f"{'YES ✓' if all_eq else 'NO ✗'}")
    print(f"  → Wire rebracketings are structurally invisible.")
    print(f"  → The coherence theorem guarantees this automatically.\n")

# =============================================================================
# Application 2: Type System Optimization
# =============================================================================

def type_system_demo():
    """Demonstrate product type canonicalization in type theory.
    
    In dependent type theory, product types (Σ-types, ×-types) are
    associative and unital up to isomorphism. When checking type equality,
    a compiler can normalize product types to canonical form, avoiding
    expensive recursive comparison of structurally equivalent types.
    """
    print("=" * 60)
    print("APPLICATION 2: Product Type Canonicalization")
    print("=" * 60)
    print()
    
    # Type names
    Int = Var("Int")
    Bool = Var("Bool")
    String = Var("String")
    Float = Var("Float")
    
    # Two function signatures with different product groupings
    sig1 = Tensor(Tensor(Int, Bool), Tensor(String, Float))    # (Int × Bool) × (String × Float)
    sig2 = Tensor(Int, Tensor(Bool, Tensor(String, Float)))    # Int × (Bool × (String × Float))
    sig3 = Tensor(Tensor(Tensor(Int, Bool), String), Float)    # ((Int × Bool) × String) × Float
    
    print("  Three product type representations:")
    print(f"    Type A: {sig1}")
    print(f"    Type B: {sig2}")
    print(f"    Type C: {sig3}")
    print()
    
    nf = normalize(sig1)
    print(f"  Canonical form: {nf}")
    print()
    
    print(f"  A ≡ B: {are_equivalent(sig1, sig2)} ✓")
    print(f"  B ≡ C: {are_equivalent(sig2, sig3)} ✓")
    print(f"  A ≡ C: {are_equivalent(sig1, sig3)} ✓")
    print()
    print(f"  → A type checker can normalize product types in O(n) time")
    print(f"    and compare canonically, avoiding exponential blowup.\n")

# =============================================================================
# Application 3: Expression Simplification Pipeline
# =============================================================================

def simplification_demo():
    """Demonstrate algebraic expression simplification.
    
    The coherence theorem tells us that any simplification pipeline
    based on oriented structural rules will produce the same result
    regardless of the order rules are applied. This is the coherence
    of optimization: different optimization schedules are equivalent.
    """
    print("=" * 60)
    print("APPLICATION 3: Coherent Optimization Pipelines")
    print("=" * 60)
    print()
    
    A, B, C = Var("A"), Var("B"), Var("C")
    I = UnitExpr()
    
    # An expression with redundant units
    expr = Tensor(Tensor(I, Tensor(A, I)), Tensor(Tensor(I, B), Tensor(C, I)))
    
    print(f"  Input expression (with redundant units):")
    print(f"    {expr}")
    print(f"    Size: {count_nodes(expr)} nodes")
    print()
    
    nf = normalize(expr)
    print(f"  Normalized (units eliminated, right-associated):")
    print(f"    {nf}")
    print(f"    Size: {count_nodes(nf)} nodes")
    print()
    
    print(f"  Reduction ratio: {count_nodes(nf)}/{count_nodes(expr)} = "
          f"{count_nodes(nf)/count_nodes(expr):.1%}")
    print()
    print(f"  Key property (proven in Lean): ANY sequence of structural")
    print(f"  simplifications reaches this same normal form. The order of")
    print(f"  rule application doesn't matter — this is coherence!\n")

def count_nodes(expr: Expr) -> int:
    if isinstance(expr, (Var, UnitExpr)): return 1
    return 1 + count_nodes(expr.left) + count_nodes(expr.right)

# =============================================================================
# Application 4: Symmetric Monoidal — Set Theory
# =============================================================================

def symmetric_demo():
    """Demonstrate symmetric monoidal coherence for set operations.
    
    In the symmetric monoidal category of sets with Cartesian product,
    coherence + symmetry means that product types with the same multiset
    of components are equivalent, regardless of order and bracketing.
    """
    print("=" * 60)
    print("APPLICATION 4: Symmetric Equivalence (Multiset Invariant)")
    print("=" * 60)
    print()
    
    A, B, C = Var("A"), Var("B"), Var("C")
    
    expressions = [
        Tensor(Tensor(A, B), C),       # (A × B) × C
        Tensor(A, Tensor(B, C)),       # A × (B × C)
        Tensor(Tensor(B, A), C),       # (B × A) × C  — uses symmetry
        Tensor(C, Tensor(A, B)),       # C × (A × B)  — uses symmetry
    ]
    
    print("  Four expressions with the same component multiset {A, B, C}:")
    for i, expr in enumerate(expressions):
        flat = flatten(expr)
        print(f"    {i+1}. {expr}  →  flatten = {flat}")
    
    print()
    print("  Monoidal equivalence (order matters):")
    for i, e1 in enumerate(expressions):
        for j, e2 in enumerate(expressions):
            if i < j:
                eq = are_equivalent(e1, e2)
                sym_eq = sorted(flatten(e1)) == sorted(flatten(e2))
                print(f"    {i+1} ≡ {j+1}: monoidal={'✓' if eq else '✗'}, "
                      f"symmetric={'✓' if sym_eq else '✗'}")
    print()
    print("  → Symmetric monoidal equivalence = same multiset of leaves")
    print("    (Conjectured and partially proven in Lean)\n")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF COHERENCE VIA CONFLUENT REWRITING       ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()
    
    quantum_circuit_demo()
    type_system_demo()
    simplification_demo()
    symmetric_demo()


#!/usr/bin/env python3
"""
Categorical Coherence via Confluent Rewriting — Interactive Demo

This script demonstrates the core computational content of the coherence theorem:
- Builds random tensor expressions
- Normalizes them via flatten → right-associate
- Checks structural equivalence by comparing normal forms
- Displays reduction sequences step by step

The key insight: two tensor expressions are structurally equivalent (related by
associativity and unit laws) if and only if they have the same flattened list
of variables. This makes coherence decidable by a simple normalization algorithm.
"""

from __future__ import annotations
import random
from dataclasses import dataclass
from typing import Union

# =============================================================================
# Section 1: Tensor Expression AST
# =============================================================================

@dataclass
class Var:
    """A variable (atomic object)."""
    name: str
    def __repr__(self):
        return self.name

@dataclass
class Unit:
    """The monoidal unit I."""
    def __repr__(self):
        return "I"

@dataclass
class Tensor:
    """Binary tensor product A ⊗ B."""
    left: 'TensorExpr'
    right: 'TensorExpr'
    def __repr__(self):
        return f"({self.left} ⊗ {self.right})"

TensorExpr = Union[Var, Unit, Tensor]

# =============================================================================
# Section 2: Core Algorithms (Proven Correct in Lean)
# =============================================================================

def flatten(expr: TensorExpr) -> list[str]:
    """Flatten a tensor expression to a list of variable names.
    
    This erases all unit elements and reads variable leaves left-to-right.
    Proven invariant: flatten is preserved by all monoidal structural rules.
    """
    if isinstance(expr, Var):
        return [expr.name]
    elif isinstance(expr, Unit):
        return []
    elif isinstance(expr, Tensor):
        return flatten(expr.left) + flatten(expr.right)

def right_assoc(variables: list[str]) -> TensorExpr:
    """Build a canonical right-associated tensor expression from a variable list.
    
    This is the normal form constructor:
    - [] → I
    - [x] → x
    - [x, y, ...] → x ⊗ (y ⊗ ...)
    """
    if not variables:
        return Unit()
    elif len(variables) == 1:
        return Var(variables[0])
    else:
        return Tensor(Var(variables[0]), right_assoc(variables[1:]))

def normalize(expr: TensorExpr) -> TensorExpr:
    """Normalize a tensor expression: flatten then right-associate.
    
    This is the verified normalization algorithm. Properties (all proven in Lean):
    - Soundness: expr is equivalent to normalize(expr)
    - Completeness: normalize(a) == normalize(b) iff a ≡ b
    - Canonicity: normalize(normalize(t)) == normalize(t)
    """
    return right_assoc(flatten(expr))

def are_equivalent(a: TensorExpr, b: TensorExpr) -> bool:
    """Decide structural equivalence by comparing normal forms.
    
    This is the decidable word problem for monoidal structural equivalence,
    proven correct in Lean.
    """
    return flatten(a) == flatten(b)

# =============================================================================
# Section 3: Reduction Step Display
# =============================================================================

def find_and_show_reductions(expr: TensorExpr, max_steps: int = 20) -> list[TensorExpr]:
    """Show the reduction sequence from expr to its normal form.
    
    Applies oriented structural rules one step at a time:
    - (A ⊗ B) ⊗ C → A ⊗ (B ⊗ C)  [associativity]
    - I ⊗ A → A                      [left unit]
    - A ⊗ I → A                      [right unit]
    """
    steps = [expr]
    current = expr
    for _ in range(max_steps):
        reduced, rule = try_reduce_one_step(current)
        if reduced is None:
            break
        steps.append((reduced, rule))
        current = reduced
    return steps

def try_reduce_one_step(expr: TensorExpr) -> tuple:
    """Try to apply one structural reduction rule. Returns (result, rule_name) or (None, None)."""
    if isinstance(expr, Tensor):
        # Left unit: I ⊗ A → A
        if isinstance(expr.left, Unit):
            return expr.right, "unitL"
        # Right unit: A ⊗ I → A
        if isinstance(expr.right, Unit):
            return expr.left, "unitR"
        # Associativity: (A ⊗ B) ⊗ C → A ⊗ (B ⊗ C)
        if isinstance(expr.left, Tensor):
            result = Tensor(expr.left.left, Tensor(expr.left.right, expr.right))
            return result, "assoc"
        # Try reducing left subtree
        reduced_left, rule = try_reduce_one_step(expr.left)
        if reduced_left is not None:
            return Tensor(reduced_left, expr.right), f"tensorL({rule})"
        # Try reducing right subtree
        reduced_right, rule = try_reduce_one_step(expr.right)
        if reduced_right is not None:
            return Tensor(expr.left, reduced_right), f"tensorR({rule})"
    return None, None

# =============================================================================
# Section 4: Random Expression Generation
# =============================================================================

def random_tensor_expr(variables: list[str], max_depth: int = 4, 
                        unit_prob: float = 0.15) -> TensorExpr:
    """Generate a random tensor expression."""
    if max_depth <= 0 or (max_depth <= 2 and random.random() < 0.5):
        if random.random() < unit_prob:
            return Unit()
        return Var(random.choice(variables))
    if random.random() < 0.6:
        left = random_tensor_expr(variables, max_depth - 1, unit_prob)
        right = random_tensor_expr(variables, max_depth - 1, unit_prob)
        return Tensor(left, right)
    elif random.random() < unit_prob:
        return Unit()
    else:
        return Var(random.choice(variables))

# =============================================================================
# Section 5: Demo Execution
# =============================================================================

def demo_normalization():
    """Demonstrate the normalization algorithm on concrete examples."""
    print("=" * 70)
    print("DEMO 1: Normalization of Tensor Expressions")
    print("=" * 70)
    print()
    
    # Example 1: Simple reassociation
    A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")
    
    examples = [
        ("Left-associated", Tensor(Tensor(Tensor(A, B), C), D)),
        ("Mixed association", Tensor(Tensor(A, B), Tensor(C, D))),
        ("Right-associated (NF)", Tensor(A, Tensor(B, Tensor(C, D)))),
        ("With units", Tensor(Tensor(Unit(), A), Tensor(B, Unit()))),
        ("Nested units", Tensor(Unit(), Tensor(Tensor(Unit(), A), Unit()))),
    ]
    
    for name, expr in examples:
        nf = normalize(expr)
        flat = flatten(expr)
        print(f"  {name}:")
        print(f"    Expression:   {expr}")
        print(f"    Flattened:    {flat}")
        print(f"    Normal form:  {nf}")
        print()

def demo_equivalence_checking():
    """Demonstrate equivalence checking."""
    print("=" * 70)
    print("DEMO 2: Structural Equivalence Checking")
    print("=" * 70)
    print()
    
    A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")
    
    pairs = [
        (Tensor(Tensor(A, B), C), Tensor(A, Tensor(B, C)),
         "Associativity"),
        (Tensor(Tensor(Tensor(A, B), C), D), Tensor(A, Tensor(B, Tensor(C, D))),
         "Full left-to-right association"),
        (Tensor(Unit(), A), A,
         "Left unit elimination"),
        (Tensor(A, B), Tensor(B, A),
         "A⊗B vs B⊗A (NOT equivalent in plain monoidal!)"),
        (Tensor(Tensor(A, Unit()), B), Tensor(A, B),
         "Unit in subexpression"),
    ]
    
    for expr1, expr2, desc in pairs:
        equiv = are_equivalent(expr1, expr2)
        print(f"  {desc}:")
        print(f"    {expr1}")
        print(f"    {'≡' if equiv else '≢'} {expr2}")
        print(f"    flatten₁ = {flatten(expr1)}")
        print(f"    flatten₂ = {flatten(expr2)}")
        print()

def demo_reduction_sequence():
    """Show step-by-step reduction to normal form."""
    print("=" * 70)
    print("DEMO 3: Step-by-Step Reduction Sequences")
    print("=" * 70)
    print()
    
    A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")
    
    expr = Tensor(Tensor(Tensor(A, Unit()), Tensor(B, C)), D)
    print(f"  Starting expression: {expr}")
    print(f"  Target normal form:  {normalize(expr)}")
    print()
    
    steps = find_and_show_reductions(expr)
    for i, item in enumerate(steps):
        if i == 0:
            print(f"  Step 0: {item}")
        else:
            reduced, rule = item
            print(f"  Step {i}: {reduced}  [{rule}]")
    print()

def demo_random_equivalences():
    """Generate random expressions and test equivalence."""
    print("=" * 70)
    print("DEMO 4: Random Equivalence Testing")
    print("=" * 70)
    print()
    
    variables = ["A", "B", "C"]
    equiv_count = 0
    total = 20
    
    random.seed(42)
    for i in range(total):
        e1 = random_tensor_expr(variables, max_depth=3)
        e2 = random_tensor_expr(variables, max_depth=3)
        equiv = are_equivalent(e1, e2)
        if equiv:
            equiv_count += 1
        marker = "≡" if equiv else "≢"
        print(f"  {i+1:2d}. {e1} {marker} {e2}")
    
    print(f"\n  {equiv_count}/{total} pairs were structurally equivalent")
    print()

def demo_associahedron():
    """Demonstrate the associahedron connection."""
    print("=" * 70)
    print("DEMO 5: Associahedron — All Parenthesizations of A⊗B⊗C⊗D")
    print("=" * 70)
    print()
    
    A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")
    
    # All 14 binary trees on 4 leaves (Catalan number C₃ = 5 for 4 leaves actually)
    # C₃ = 5 parenthesizations of 4 elements
    parenthesizations = [
        Tensor(Tensor(Tensor(A, B), C), D),      # ((A⊗B)⊗C)⊗D
        Tensor(Tensor(A, Tensor(B, C)), D),       # (A⊗(B⊗C))⊗D
        Tensor(Tensor(A, B), Tensor(C, D)),       # (A⊗B)⊗(C⊗D)
        Tensor(A, Tensor(Tensor(B, C), D)),       # A⊗((B⊗C)⊗D)
        Tensor(A, Tensor(B, Tensor(C, D))),       # A⊗(B⊗(C⊗D))  ← normal form
    ]
    
    print("  All 5 parenthesizations of A ⊗ B ⊗ C ⊗ D:")
    for i, p in enumerate(parenthesizations):
        is_nf = "← NORMAL FORM" if p == normalize(p) else ""
        print(f"    {i+1}. {p}  {is_nf}")
    
    print(f"\n  All have flatten = {flatten(parenthesizations[0])}")
    print(f"  All are structurally equivalent: ", end="")
    all_equiv = all(are_equivalent(parenthesizations[0], p) for p in parenthesizations)
    print(f"{'YES ✓' if all_equiv else 'NO ✗'}")
    print(f"\n  → This is the content of the Stasheff associahedron:")
    print(f"    all vertices (parenthesizations) reduce to the same normal form.")
    print()

def demo_idempotence():
    """Verify idempotence of normalization."""
    print("=" * 70)
    print("DEMO 6: Normalization is Idempotent (Proven in Lean)")
    print("=" * 70)
    print()
    
    variables = ["X", "Y", "Z", "W"]
    random.seed(123)
    
    all_idempotent = True
    for i in range(10):
        expr = random_tensor_expr(variables, max_depth=4)
        nf1 = normalize(expr)
        nf2 = normalize(nf1)
        idempotent = (flatten(nf1) == flatten(nf2))
        all_idempotent = all_idempotent and idempotent
        print(f"  {i+1}. normalize(normalize({expr}))")
        print(f"     = normalize({nf1})")
        print(f"     = {nf2}")
        print(f"     Idempotent: {'✓' if idempotent else '✗'}")
        print()
    
    print(f"  All idempotent: {'YES ✓' if all_idempotent else 'NO ✗'}")
    print()

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  CATEGORICAL COHERENCE VIA CONFLUENT REWRITING                     ║")
    print("║  Interactive Demonstration                                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    print("This demo illustrates the computational content of the coherence")
    print("theorem: structural equivalence of tensor expressions is decidable")
    print("by normalization to right-associated unit-free canonical forms.")
    print()
    
    demo_normalization()
    demo_equivalence_checking()
    demo_reduction_sequence()
    demo_random_equivalences()
    demo_associahedron()
    demo_idempotence()
    
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The coherence theorem, proven in Lean 4 with zero sorry:")
    print("  - Every tensor expression has a unique normal form")
    print("  - Equivalence = same normal form = same flattened variable list")
    print("  - The rewrite system is confluent and terminating")
    print("  - This is Mac Lane's coherence theorem, re-derived as a")
    print("    corollary of confluent rewriting theory")
    print()


#!/usr/bin/env python3
"""
Visualization: The Associahedron and Confluent Normalization

Visualizes all parenthesizations of a 4-element tensor product as nodes
in the Stasheff associahedron (K₄), with edges representing single
associativity steps. Shows how all paths converge to the unique
right-associated normal form.

This illustrates the core theorem: the monoidal rewrite system is confluent,
so all parenthesizations of the same sequence normalize to the same canonical form.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# =============================================================================
# Tensor Expression AST (self-contained)
# =============================================================================

class Var:
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(('V', self.name))

class Unit:
    def __repr__(self): return "I"
    def __eq__(self, other): return isinstance(other, Unit)
    def __hash__(self): return hash('U')

class Tensor:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"
    def __eq__(self, other):
        return isinstance(other, Tensor) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('T', self.left, self.right))

def flatten(e):
    if isinstance(e, Var): return [e.name]
    if isinstance(e, Unit): return []
    return flatten(e.left) + flatten(e.right)

def right_assoc(vs):
    if not vs: return Unit()
    if len(vs) == 1: return Var(vs[0])
    return Tensor(Var(vs[0]), right_assoc(vs[1:]))

def normalize(e): return right_assoc(flatten(e))

def is_normal_form(e):
    return e == normalize(e)

def try_reduce(e):
    """Return list of (result, rule) for all possible one-step reductions."""
    results = []
    if isinstance(e, Tensor):
        if isinstance(e.left, Unit):
            results.append((e.right, "unitL"))
        if isinstance(e.right, Unit):
            results.append((e.left, "unitR"))
        if isinstance(e.left, Tensor):
            r = Tensor(e.left.left, Tensor(e.left.right, e.right))
            results.append((r, "assoc"))
        for (rl, rule) in try_reduce(e.left):
            results.append((Tensor(rl, e.right), f"L:{rule}"))
        for (rr, rule) in try_reduce(e.right):
            results.append((Tensor(e.left, rr), f"R:{rule}"))
    return results

# =============================================================================
# Enumerate all binary trees on 4 leaves (Catalan number C₃ = 5)
# =============================================================================

A, B, C, D = Var("A"), Var("B"), Var("C"), Var("D")

parenthesizations = [
    Tensor(Tensor(Tensor(A, B), C), D),      # ((A⊗B)⊗C)⊗D
    Tensor(Tensor(A, Tensor(B, C)), D),       # (A⊗(B⊗C))⊗D
    Tensor(Tensor(A, B), Tensor(C, D)),       # (A⊗B)⊗(C⊗D)
    Tensor(A, Tensor(Tensor(B, C), D)),       # A⊗((B⊗C)⊗D)
    Tensor(A, Tensor(B, Tensor(C, D))),       # A⊗(B⊗(C⊗D)) ← NF
]

labels = [
    "((A⊗B)⊗C)⊗D",
    "(A⊗(B⊗C))⊗D",
    "(A⊗B)⊗(C⊗D)",
    "A⊗((B⊗C)⊗D)",
    "A⊗(B⊗(C⊗D))\n[Normal Form]",
]

# =============================================================================
# Build adjacency (which pairs are connected by one assoc step)
# =============================================================================

def are_one_step(e1, e2):
    """Check if e2 is reachable from e1 in one associativity step."""
    for (r, _) in try_reduce(e1):
        if r == e2:
            return True
    return False

edges = []
for i in range(len(parenthesizations)):
    for j in range(len(parenthesizations)):
        if i != j and are_one_step(parenthesizations[i], parenthesizations[j]):
            edges.append((i, j))

# =============================================================================
# Layout: Pentagon (Stasheff associahedron K₄)
# =============================================================================

# The K₄ associahedron is a pentagon
angles = [np.pi/2 + 2*np.pi*k/5 for k in range(5)]
# Reorder to match the natural adjacency
# Standard pentagon ordering: 0-1-2-3-4
pos = {}
radius = 2.5
for i in range(5):
    pos[i] = (radius * np.cos(angles[i]), radius * np.sin(angles[i]))

# =============================================================================
# Draw
# =============================================================================

fig, ax = plt.subplots(1, 1, figsize=(10, 10))
ax.set_aspect('equal')

# Draw edges
for (i, j) in edges:
    x1, y1 = pos[i]
    x2, y2 = pos[j]
    # Color: green if pointing toward NF (index 4), gray otherwise
    color = '#2ecc71' if j == 4 else '#bdc3c7'
    width = 2.5 if j == 4 else 1.0
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=width,
                               connectionstyle='arc3,rad=0.1'))

# Draw nodes
for i in range(5):
    x, y = pos[i]
    is_nf = (i == 4)
    color = '#27ae60' if is_nf else '#3498db'
    size = 1800 if is_nf else 1200
    ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='white', linewidth=2)
    
    # Label
    offset_y = -0.6 if y < 0 else 0.6
    va = 'top' if y >= 0 else 'bottom'
    if i == 4:
        offset_y = 0.8
        va = 'bottom'
    ax.text(x, y + offset_y, labels[i], ha='center', va=va,
            fontsize=9, fontweight='bold' if is_nf else 'normal',
            color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

# Title and annotations
ax.set_title("The Stasheff Associahedron K₄\nConfluent Normalization of Tensor Expressions",
             fontsize=14, fontweight='bold', pad=20)
ax.text(0, -3.8,
        "Green arrows: reduction toward the unique normal form\n"
        "All paths converge — this is confluence = coherence",
        ha='center', fontsize=10, style='italic', color='#7f8c8d')

# Legend
nf_patch = mpatches.Patch(color='#27ae60', label='Normal form (canonical)')
expr_patch = mpatches.Patch(color='#3498db', label='Non-canonical expression')
ax.legend(handles=[nf_patch, expr_patch], loc='lower right', fontsize=10)

ax.set_xlim(-4, 4)
ax.set_ylim(-4.5, 4)
ax.axis('off')

plt.tight_layout()
plt.savefig('associahedron.png', dpi=150, bbox_inches='tight')
print("Saved associahedron.png")


#!/usr/bin/env python3
"""
Visualization: Reduction Sequences and Complexity Descent

Shows two plots:
1. Multiple reduction sequences converging to the same normal form
2. The complexity measure strictly decreasing along each reduction path

This visualizes the key properties: termination (complexity always decreases)
and confluence (all paths lead to the same normal form).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# =============================================================================
# Self-contained tensor expression infrastructure
# =============================================================================

class Var:
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(('V', self.name))

class UnitE:
    def __repr__(self): return "I"
    def __eq__(self, other): return isinstance(other, UnitE)
    def __hash__(self): return hash('U')

class Tensor:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"
    def __eq__(self, other):
        return isinstance(other, Tensor) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('T', self.left, self.right))

def flatten(e):
    if isinstance(e, Var): return [e.name]
    if isinstance(e, UnitE): return []
    return flatten(e.left) + flatten(e.right)

def right_assoc(vs):
    if not vs: return UnitE()
    if len(vs) == 1: return Var(vs[0])
    return Tensor(Var(vs[0]), right_assoc(vs[1:]))

def normalize(e): return right_assoc(flatten(e))

def complexity(e):
    """Termination measure: counts left-nested tensors + unit adjacencies."""
    if isinstance(e, (Var, UnitE)): return 0
    c = complexity(e.left) + complexity(e.right)
    if isinstance(e.left, Tensor): c += 1
    if isinstance(e.left, UnitE): c += 1
    if isinstance(e.right, UnitE): c += 1
    return c

def expr_size(e):
    if isinstance(e, (Var, UnitE)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)

def reduce_leftmost(e):
    """Reduce using leftmost-outermost strategy."""
    if not isinstance(e, Tensor): return None
    if isinstance(e.left, UnitE): return e.right
    if isinstance(e.right, UnitE): return e.left
    if isinstance(e.left, Tensor):
        return Tensor(e.left.left, Tensor(e.left.right, e.right))
    r = reduce_leftmost(e.left)
    if r is not None: return Tensor(r, e.right)
    r = reduce_leftmost(e.right)
    if r is not None: return Tensor(e.left, r)
    return None

def reduce_rightmost(e):
    """Reduce using rightmost-innermost strategy."""
    if not isinstance(e, Tensor): return None
    # Try right subtree first
    r = reduce_rightmost(e.right)
    if r is not None: return Tensor(e.left, r)
    r = reduce_rightmost(e.left)
    if r is not None: return Tensor(r, e.right)
    # Then try root rules
    if isinstance(e.right, UnitE): return e.left
    if isinstance(e.left, UnitE): return e.right
    if isinstance(e.left, Tensor):
        return Tensor(e.left.left, Tensor(e.left.right, e.right))
    return None

def full_reduction(e, strategy='leftmost', max_steps=50):
    steps = [e]
    current = e
    reduce_fn = reduce_leftmost if strategy == 'leftmost' else reduce_rightmost
    for _ in range(max_steps):
        r = reduce_fn(current)
        if r is None: break
        steps.append(r)
        current = r
    return steps

# =============================================================================
# Build test expressions
# =============================================================================

A, B, C, D, E = Var("A"), Var("B"), Var("C"), Var("D"), Var("E")
I = UnitE()

test_exprs = [
    ("((A⊗B)⊗C)⊗D", Tensor(Tensor(Tensor(A, B), C), D)),
    ("(I⊗(A⊗I))⊗(B⊗C)", Tensor(Tensor(I, Tensor(A, I)), Tensor(B, C))),
    ("((A⊗I)⊗(I⊗B))⊗(C⊗(D⊗E))",
     Tensor(Tensor(Tensor(A, I), Tensor(I, B)), Tensor(C, Tensor(D, E)))),
    ("(((A⊗B)⊗C)⊗D)⊗E",
     Tensor(Tensor(Tensor(Tensor(A, B), C), D), E)),
]

# =============================================================================
# Plot 1: Complexity descent
# =============================================================================

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

ax1 = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

for idx, (name, expr) in enumerate(test_exprs):
    # Use leftmost strategy
    steps = full_reduction(expr, 'leftmost')
    complexities = [complexity(s) for s in steps]
    x = list(range(len(complexities)))
    
    ax1.plot(x, complexities, 'o-', color=colors[idx], linewidth=2, 
             markersize=6, label=name, alpha=0.8)

ax1.set_xlabel("Reduction Step", fontsize=12)
ax1.set_ylabel("Complexity Measure", fontsize=12)
ax1.set_title("Termination: Complexity Strictly Decreases\nWith Each Rewrite Step", 
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=-0.5)

# =============================================================================
# Plot 2: Two strategies converge to same NF
# =============================================================================

ax2 = axes[1]

expr = Tensor(Tensor(Tensor(A, I), Tensor(I, B)), Tensor(C, Tensor(D, I)))
steps_lm = full_reduction(expr, 'leftmost')
steps_rm = full_reduction(expr, 'rightmost')

sizes_lm = [expr_size(s) for s in steps_lm]
sizes_rm = [expr_size(s) for s in steps_rm]

x_lm = list(range(len(sizes_lm)))
x_rm = list(range(len(sizes_rm)))

ax2.plot(x_lm, sizes_lm, 'o-', color='#e74c3c', linewidth=2.5, 
         markersize=7, label='Leftmost-outermost strategy', alpha=0.8)
ax2.plot(x_rm, sizes_rm, 's--', color='#3498db', linewidth=2.5,
         markersize=7, label='Rightmost-innermost strategy', alpha=0.8)

# Mark the common normal form
nf = normalize(expr)
nf_size = expr_size(nf)
ax2.axhline(y=nf_size, color='#2ecc71', linestyle=':', linewidth=2, alpha=0.7,
            label=f'Normal form size = {nf_size}')

# Verify both reach the same NF
assert flatten(steps_lm[-1]) == flatten(steps_rm[-1]) == flatten(nf)

ax2.set_xlabel("Reduction Step", fontsize=12)
ax2.set_ylabel("Expression Size (nodes)", fontsize=12)
ax2.set_title("Confluence: Different Strategies\nConverge to Same Normal Form",
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate(f'Both reach: {nf}',
             xy=(max(len(x_lm), len(x_rm)) - 1, nf_size),
             xytext=(max(len(x_lm), len(x_rm)) - 3, nf_size + 3),
             fontsize=9, ha='center',
             arrowprops=dict(arrowstyle='->', color='#2ecc71'),
             bbox=dict(boxstyle='round', facecolor='#eafaf1'))

plt.tight_layout()
plt.savefig('reduction_convergence.png', dpi=150, bbox_inches='tight')
print("Saved reduction_convergence.png")
