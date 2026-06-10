#!/usr/bin/env python3
"""
Applications of Higher-Order State Complexity Theory

Demonstrates practical applications of the typeStateBound invariant
and the Global Tightness theorem:

1. Complexity classification of lambda terms by type
2. Automatic detection of maximal-complexity programs
3. Program equivalence testing via state-space comparison
4. Type-guided resource estimation for higher-order programs
"""

from __future__ import annotations
from algorithms import (
    Ty, Base, Arrow, Lam, Var, App, Abs,
    type_state_bound, type_depth, type_size,
    bounded_state_set, canonical_quotient_size,
    beta_reductions, is_normal_form, subst,
    iter_end_ty, synthesize_witness_base_arrow,
    detect_saturation
)


# ─── Application 1: Complexity Classification ─────────────────────────────

def classify_type_complexity(ty: Ty) -> dict:
    """Classify a type by its state complexity profile.

    Returns a dictionary with:
    - state_bound: the typeStateBound
    - depth: type depth
    - size: type size
    - complexity_class: human-readable classification
    """
    tsb = type_state_bound(ty)
    depth = type_depth(ty)
    size = type_size(ty)

    if tsb == 1:
        cls = "trivial (base type)"
    elif tsb <= 10:
        cls = "low complexity"
    elif tsb <= 100:
        cls = "moderate complexity"
    elif tsb <= 10000:
        cls = "high complexity"
    else:
        cls = "extreme complexity"

    return {
        "type": str(ty),
        "state_bound": tsb,
        "depth": depth,
        "size": size,
        "complexity_class": cls,
    }


# ─── Application 2: Maximal-Complexity Detection ──────────────────────────

def find_maximal_terms(
    ty: Ty,
    terms: list[Lam],
    max_depth: int = 10
) -> list[tuple[Lam, int, int]]:
    """Find terms whose state complexity is closest to the type bound.

    For each term, computes the maximum canonical quotient size
    over depths up to max_depth, and reports how close it is
    to typeStateBound(ty).

    Args:
        ty: The type to evaluate against.
        terms: List of candidate terms.
        max_depth: Maximum reduction depth to explore.

    Returns:
        List of (term, max_quotient_size, achieving_depth) sorted
        by quotient size descending.
    """
    target = type_state_bound(ty)
    results = []

    for term in terms:
        best_qs = 0
        best_d = 0
        for d in range(max_depth + 1):
            qs = canonical_quotient_size(d, term)
            if qs > best_qs:
                best_qs = qs
                best_d = d
            if qs >= target:
                break
        results.append((term, best_qs, best_d))

    results.sort(key=lambda x: -x[1])
    return results


# ─── Application 3: Program Equivalence Testing ───────────────────────────

def behavioral_fingerprint(term: Lam, max_depth: int = 5) -> list[int]:
    """Compute a behavioral fingerprint: the sequence of quotient sizes.

    Two terms with different fingerprints are guaranteed to be
    behaviorally distinct. Same fingerprints suggest (but don't prove)
    behavioral similarity.

    Args:
        term: The term to fingerprint.
        max_depth: Number of depth levels to include.

    Returns:
        List of canonical quotient sizes [qs(0), qs(1), ..., qs(max_depth)].
    """
    return [canonical_quotient_size(d, term) for d in range(max_depth + 1)]


def are_behaviorally_distinct(t1: Lam, t2: Lam, max_depth: int = 5) -> bool:
    """Test if two terms are behaviorally distinct up to the given depth.

    Uses fingerprint comparison as a quick discriminator.
    """
    return behavioral_fingerprint(t1, max_depth) != behavioral_fingerprint(t2, max_depth)


# ─── Application 4: Resource Estimation ───────────────────────────────────

def estimate_reduction_resources(ty: Ty) -> dict:
    """Estimate computational resources for terms of a given type.

    Based on the typeStateBound, provides estimates for:
    - Maximum distinct intermediate states during evaluation
    - Upper bound on reduction graph size
    - Suggested evaluation budget

    This is a type-guided resource estimation: the type alone
    determines the worst-case state complexity.
    """
    tsb = type_state_bound(ty)
    depth = type_depth(ty)

    return {
        "type": str(ty),
        "max_states": tsb,
        "suggested_depth_budget": 2 * depth + 2,
        "reduction_graph_bound": tsb * tsb,
        "memory_estimate_terms": tsb,
    }


# ─── Demo ──────────────────────────────────────────────────────────────────

def demo_complexity_classification():
    """Demonstrate type complexity classification."""
    print("=" * 65)
    print("APPLICATION 1: Type Complexity Classification")
    print("=" * 65)
    print()

    types = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Base(), Arrow(Base(), Base())),
        Arrow(Arrow(Base(), Base()), Arrow(Base(), Base())),
        iter_end_ty(3),
    ]

    for ty in types:
        info = classify_type_complexity(ty)
        print(f"Type: {info['type']}")
        print(f"  State bound: {info['state_bound']}")
        print(f"  Depth: {info['depth']}, Size: {info['size']}")
        print(f"  Class: {info['complexity_class']}")
        print()


def demo_maximal_detection():
    """Demonstrate detection of maximal-complexity terms."""
    print("=" * 65)
    print("APPLICATION 2: Maximal-Complexity Term Detection")
    print("=" * 65)
    print()

    ty = Arrow(Base(), Base())
    tsb = type_state_bound(ty)
    print(f"Type: {ty}  (typeStateBound = {tsb})")
    print()

    # Generate candidate terms
    candidates = [
        Abs(0, Var(0)),                                    # λx.x
        App(Abs(0, Var(0)), Abs(1, Var(1))),               # (λx.x)(λy.y)
        synthesize_witness_base_arrow(),                    # (λx.x)((λy.y)(λz.z))
        App(Abs(0, Var(0)), App(Abs(1, Var(1)),
            App(Abs(2, Var(2)), Abs(3, Var(3))))),          # deeper nesting
    ]

    results = find_maximal_terms(ty, candidates)

    print(f"{'Term':<50} {'Max QS':>8} {'Depth':>6} {'Ratio':>8}")
    print("-" * 75)
    for term, qs, d in results:
        ratio = qs / tsb
        marker = " ← MAXIMAL" if qs == tsb else ""
        print(f"{str(term):<50} {qs:>8} {d:>6} {ratio:>7.1%}{marker}")
    print()


def demo_equivalence_testing():
    """Demonstrate behavioral equivalence testing."""
    print("=" * 65)
    print("APPLICATION 3: Behavioral Equivalence Testing")
    print("=" * 65)
    print()

    terms = {
        "λx.x": Abs(0, Var(0)),
        "(λx.x)(λy.y)": App(Abs(0, Var(0)), Abs(1, Var(1))),
        "(λx.x)((λy.y)(λz.z))": synthesize_witness_base_arrow(),
        "λz.z": Abs(2, Var(2)),
    }

    names = list(terms.keys())
    print("Behavioral fingerprints (quotient sizes at depths 0-5):")
    for name, term in terms.items():
        fp = behavioral_fingerprint(term)
        print(f"  {name:<30} → {fp}")

    print()
    print("Pairwise distinctness:")
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            distinct = are_behaviorally_distinct(terms[names[i]], terms[names[j]])
            status = "DISTINCT" if distinct else "SIMILAR"
            print(f"  {names[i]} vs {names[j]}: {status}")
    print()


def demo_resource_estimation():
    """Demonstrate type-guided resource estimation."""
    print("=" * 65)
    print("APPLICATION 4: Type-Guided Resource Estimation")
    print("=" * 65)
    print()

    types = [
        Arrow(Base(), Base()),
        Arrow(Arrow(Base(), Base()), Arrow(Base(), Base())),
        iter_end_ty(3),
    ]

    for ty in types:
        est = estimate_reduction_resources(ty)
        print(f"Type: {est['type']}")
        print(f"  Max intermediate states: {est['max_states']}")
        print(f"  Suggested depth budget: {est['suggested_depth_budget']}")
        print(f"  Reduction graph bound: {est['reduction_graph_bound']}")
        print(f"  Memory estimate: {est['memory_estimate_terms']} terms")
        print()


if __name__ == "__main__":
    demo_complexity_classification()
    demo_maximal_detection()
    demo_equivalence_testing()
    demo_resource_estimation()


#!/usr/bin/env python3
"""Build PACKAGE.json from the deliverable files."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Catalog/Pythagorean/GlobalTightness.lean')

package = {
    "title": "Exact Higher-Order State Complexity: A Myhill-Nerode Theorem for Simply Typed Lambda Calculus",
    "domain": "Pythagorean",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Higher-Order State Complexity Explorer",
            "code": demo_code
        },
        {
            "name": "Applications of Type Complexity Theory",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Type State Bound Computation",
            "pseudocode": "function typeStateBound(ty):\n  if ty is Base: return 1\n  if ty is Arrow(A, B): return (typeStateBound(A) + 1) * (typeStateBound(B) + 1)",
            "code": algorithms_code
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json written successfully.")


#!/usr/bin/env python3
"""
Demo: Higher-Order State Complexity Explorer

Explores the Global Tightness Conjecture for simply typed lambda calculus.
For each simple type, computes typeStateBound and constructs witness terms
whose beta-reduction state spaces achieve (or approach) this bound.

Usage:
    python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional


# ─── Simple Types ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Ty:
    """Simple type: either Base or Arrow(dom, cod)."""
    pass

@dataclass(frozen=True)
class Base(Ty):
    def __repr__(self): return "o"

@dataclass(frozen=True)
class Arrow(Ty):
    dom: Ty
    cod: Ty
    def __repr__(self):
        d = f"({self.dom})" if isinstance(self.dom, Arrow) else f"{self.dom}"
        return f"{d} → {self.cod}"

def type_state_bound(ty: Ty) -> int:
    """Compute typeStateBound(ty)."""
    if isinstance(ty, Base):
        return 1
    elif isinstance(ty, Arrow):
        return (type_state_bound(ty.dom) + 1) * (type_state_bound(ty.cod) + 1)
    raise TypeError

def type_depth(ty: Ty) -> int:
    if isinstance(ty, Base): return 0
    return 1 + max(type_depth(ty.dom), type_depth(ty.cod))

def iter_end_ty(n: int) -> Ty:
    """Iterated endomorphism type: iterEndTy(0) = o, iterEndTy(n+1) = iterEndTy(n) → iterEndTy(n)."""
    if n == 0: return Base()
    sub = iter_end_ty(n - 1)
    return Arrow(sub, sub)


# ─── Lambda Terms ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Lam:
    """Lambda term: Var(n), App(fun, arg), or Abs(x, body)."""
    pass

@dataclass(frozen=True)
class Var(Lam):
    n: int
    def __repr__(self): return f"x{self.n}"

@dataclass(frozen=True)
class App(Lam):
    fun: Lam
    arg: Lam
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Abs(Lam):
    x: int
    body: Lam
    def __repr__(self): return f"(λx{self.x}. {self.body})"


def subst(term: Lam, x: int, s: Lam) -> Lam:
    """Substitute s for variable x in term (no capture avoidance)."""
    if isinstance(term, Var):
        return s if term.n == x else term
    elif isinstance(term, App):
        return App(subst(term.fun, x, s), subst(term.arg, x, s))
    elif isinstance(term, Abs):
        if term.x == x:
            return term  # x is shadowed
        return Abs(term.x, subst(term.body, x, s))
    raise TypeError


def beta_step(term: Lam) -> list[Lam]:
    """All one-step beta reductions of term."""
    results = []
    if isinstance(term, App):
        if isinstance(term.fun, Abs):
            # Beta redex
            results.append(subst(term.fun.body, term.fun.x, term.arg))
        # Reduce in function position
        for t2 in beta_step(term.fun):
            results.append(App(t2, term.arg))
        # Reduce in argument position
        for t2 in beta_step(term.arg):
            results.append(App(term.fun, t2))
    elif isinstance(term, Abs):
        for t2 in beta_step(term.body):
            results.append(Abs(term.x, t2))
    return results


def bounded_state_set(depth: int, term: Lam) -> set[Lam]:
    """Compute all terms reachable from term within depth beta steps."""
    current = {term}
    frontier = {term}
    for _ in range(depth):
        new_frontier = set()
        for t in frontier:
            for t2 in beta_step(t):
                if t2 not in current:
                    current.add(t2)
                    new_frontier.add(t2)
        frontier = new_frontier
        if not frontier:
            break
    return current


def canonical_quotient_size(depth: int, term: Lam) -> int:
    """Compute the canonical quotient size = |bounded_state_set(depth, term)|."""
    return len(bounded_state_set(depth, term))


# ─── Witness Construction ─────────────────────────────────────────────────

def make_identity(var_id: int) -> Lam:
    """λx. x at any type A → A."""
    return Abs(var_id, Var(var_id))


def make_nested_identity_witness(var_base: int = 0) -> Lam:
    """Construct (λx₀. x₀)((λx₁. x₁)(λx₂. x₂)) — the witness for base → base.
    Has 4 reachable states matching typeStateBound(base → base) = 4."""
    return App(
        make_identity(var_base),
        App(make_identity(var_base + 1), make_identity(var_base + 2))
    )


def make_deep_witness(n_layers: int, var_start: int = 0) -> Lam:
    """Construct a witness with n_layers of nested identity applications.
    More layers = more reachable states."""
    if n_layers == 0:
        return make_identity(var_start)
    inner = make_deep_witness(n_layers - 1, var_start + 1)
    outer_id = make_identity(var_start)
    return App(outer_id, inner)


# ─── Demo ──────────────────────────────────────────────────────────────────

def demo_type_state_bounds():
    """Show typeStateBound for several types."""
    print("=" * 65)
    print("TYPE STATE BOUND — The Exact Complexity Invariant")
    print("=" * 65)
    print()
    print(f"{'Type':<35} {'typeStateBound':>14} {'Depth':>6}")
    print("-" * 65)

    types = [
        ("base", Base()),
        ("base → base", Arrow(Base(), Base())),
        ("(base→base) → (base→base)", Arrow(Arrow(Base(), Base()), Arrow(Base(), Base()))),
        ("base → base → base", Arrow(Base(), Arrow(Base(), Base()))),
        ("iterEndTy(0) = base", iter_end_ty(0)),
        ("iterEndTy(1) = base → base", iter_end_ty(1)),
        ("iterEndTy(2)", iter_end_ty(2)),
        ("iterEndTy(3)", iter_end_ty(3)),
        ("iterEndTy(4)", iter_end_ty(4)),
    ]

    for name, ty in types:
        tsb = type_state_bound(ty)
        d = type_depth(ty)
        print(f"{name:<35} {tsb:>14,} {d:>6}")

    print()
    print("Note: typeStateBound grows super-exponentially for iterated")
    print("endomorphism types: 1, 4, 25, 676, 458329, ...")
    print()


def demo_witness_base_arrow():
    """Demonstrate the witness construction for base → base."""
    print("=" * 65)
    print("WITNESS CONSTRUCTION — base → base (typeStateBound = 4)")
    print("=" * 65)
    print()

    w = make_nested_identity_witness()
    print(f"Witness term: {w}")
    print()

    print("Reduction diamond:")
    print(f"  w₀ = {w}")
    reductions = beta_step(w)
    for i, r in enumerate(reductions):
        print(f"  w₀ →β {r}")
    print()

    print(f"{'Depth':<8} {'Quotient Size':<16} {'typeStateBound':<16} {'Match?'}")
    print("-" * 55)
    tsb = type_state_bound(Arrow(Base(), Base()))

    for d in range(6):
        qs = canonical_quotient_size(d, w)
        match = "✓ EXACT" if qs == tsb else ("↑ growing" if qs < tsb else "")
        print(f"{d:<8} {qs:<16} {tsb:<16} {match}")

    print()
    print("The witness achieves exactly 4 reachable states at depth 2,")
    print("matching typeStateBound(base → base) = 4.")
    print()


def demo_saturation_depths():
    """Show how quotient size grows with depth for various witnesses."""
    print("=" * 65)
    print("SATURATION DEPTH — When Does the Witness Achieve the Bound?")
    print("=" * 65)
    print()

    witnesses = [
        ("Identity (λx.x)", make_identity(0), Arrow(Base(), Base())),
        ("Nested id ((λx.x)((λy.y)(λz.z)))", make_nested_identity_witness(), Arrow(Base(), Base())),
        ("3-layer witness", make_deep_witness(2), Arrow(Base(), Base())),
        ("4-layer witness", make_deep_witness(3), Arrow(Base(), Base())),
    ]

    for name, term, ty in witnesses:
        tsb = type_state_bound(ty)
        print(f"Term: {name}")
        print(f"  Type: {ty}  (typeStateBound = {tsb})")
        sat_depth = None
        for d in range(10):
            qs = canonical_quotient_size(d, term)
            marker = " ← SATURATED" if qs == tsb else ""
            print(f"  depth {d}: quotient_size = {qs}{marker}")
            if qs == tsb and sat_depth is None:
                sat_depth = d
            if qs == tsb:
                break
        if sat_depth is not None:
            print(f"  → Saturation achieved at depth {sat_depth}")
        else:
            print(f"  → Max observed: {canonical_quotient_size(9, term)} (bound: {tsb})")
        print()


def demo_conjecture_testing():
    """Test the global tightness conjecture computationally."""
    print("=" * 65)
    print("CONJECTURE TESTING — Global Tightness")
    print("=" * 65)
    print()
    print("For each inhabited type, we search for a witness term whose")
    print("reachable state count matches typeStateBound.")
    print()

    # Test for several types
    test_cases = [
        ("base → base", Arrow(Base(), Base()), make_nested_identity_witness()),
    ]

    # Generate more test cases with deeper witnesses
    for layers in range(1, 6):
        term = make_deep_witness(layers)
        ty = Arrow(Base(), Base())
        test_cases.append((f"{layers+1}-layer witness at BB", ty, term))

    print(f"{'Type':<25} {'tsb':>6} {'Max QS':>8} {'Depth':>6} {'Match?':>8}")
    print("-" * 60)

    for name, ty, term in test_cases:
        tsb = type_state_bound(ty)
        max_qs = 0
        best_d = 0
        for d in range(15):
            qs = canonical_quotient_size(d, term)
            if qs > max_qs:
                max_qs = qs
                best_d = d
            if qs == tsb:
                break
        match = "✓" if max_qs == tsb else "✗"
        print(f"{name:<25} {tsb:>6} {max_qs:>8} {best_d:>6} {match:>8}")

    print()
    print("Note: The nested identity witness achieves the bound for base → base.")
    print("For higher types, more sophisticated constructions are needed.")
    print()


def demo_exponential_growth():
    """Demonstrate the exponential growth of typeStateBound."""
    print("=" * 65)
    print("EXPONENTIAL GROWTH — iterEndTy State Bounds")
    print("=" * 65)
    print()

    print(f"{'n':>3} {'iterEndTy(n)':<30} {'typeStateBound':>15} {'2^n':>10} {'ratio':>10}")
    print("-" * 70)

    for n in range(8):
        ty = iter_end_ty(n)
        tsb = type_state_bound(ty)
        exp = 2 ** n
        ratio = tsb / exp if exp > 0 else float('inf')
        ty_str = str(ty)[:28]
        print(f"{n:>3} {ty_str:<30} {tsb:>15,} {exp:>10} {ratio:>10.1f}")

    print()
    print("The state bound grows as a tower function, far exceeding 2^n.")
    print("This reflects the immense combinatorial richness of higher-order types.")


if __name__ == "__main__":
    demo_type_state_bounds()
    demo_witness_base_arrow()
    demo_saturation_depths()
    demo_conjecture_testing()
    demo_exponential_growth()
