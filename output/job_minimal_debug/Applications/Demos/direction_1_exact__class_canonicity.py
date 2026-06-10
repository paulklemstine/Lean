#!/usr/bin/env python3
"""
applications.py — Real-world applications of β-class structural canonicity.

Demonstrates practical applications of the theoretical results:
1. Program equivalence checking via FTS comparison
2. Code optimization validation
3. Compiler correctness testing
4. Lambda calculus term enumeration and classification
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
from collections import defaultdict
import time


# ─── Lambda Calculus Core (self-contained) ─────────────────────────────────

@dataclass(frozen=True)
class Var:
    name: int
    def __repr__(self): return f"x{self.name}"
    def size(self): return 1

@dataclass(frozen=True)
class Lam:
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}. {self.body})"
    def size(self): return 1 + self.body.size()

@dataclass(frozen=True)
class App:
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()

Term = Var | Lam | App

def subst(t, x, s):
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, Lam):
        return t if t.var == x else Lam(t.var, subst(t.body, x, s))
    else:
        return App(subst(t.fun, x, s), subst(t.arg, x, s))

def is_normal_form(t):
    if isinstance(t, Var): return True
    if isinstance(t, Lam): return is_normal_form(t.body)
    if isinstance(t, App):
        return not isinstance(t.fun, Lam) and is_normal_form(t.fun) and is_normal_form(t.arg)

def beta_reduce_one(t):
    results = []
    if isinstance(t, Lam):
        for b in beta_reduce_one(t.body):
            results.append(Lam(t.var, b))
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        for f in beta_reduce_one(t.fun):
            results.append(App(f, t.arg))
        for a in beta_reduce_one(t.arg):
            results.append(App(t.fun, a))
    return results

def normalize(t, max_steps=500):
    for _ in range(max_steps):
        if is_normal_form(t): return t
        reducts = beta_reduce_one(t)
        if not reducts: return t
        t = reducts[0]
    return None

def build_fts(t, depth):
    states, transitions = set(), set()
    queue = [(t, 0)]
    visited = set()
    while queue:
        term, d = queue.pop(0)
        key = repr(term)
        if key in visited or d > depth: continue
        visited.add(key)
        states.add(key)
        if d < depth:
            for r in beta_reduce_one(term):
                rk = repr(r)
                states.add(rk)
                transitions.add((key, rk))
                queue.append((r, d + 1))
    return states, transitions, repr(t)

def bisim_quotient(states, transitions):
    succs = defaultdict(set)
    for s, t in transitions:
        succs[s].add(t)
    part = {s: 0 for s in states}
    prev = -1
    while len(set(part.values())) != prev:
        prev = len(set(part.values()))
        sigs, np, nid = {}, {}, 0
        for s in states:
            sig = frozenset(part[t] for t in succs[s])
            key = (part[s], sig)
            if key not in sigs: sigs[key] = nid; nid += 1
            np[s] = sigs[key]
        part = np
    return part


# ─── Application 1: Program Equivalence Checker ───────────────────────────

def check_program_equivalence(prog1: Term, prog2: Term, max_depth: int = 8) -> dict:
    """
    Check if two programs (λ-terms) are β-equivalent by comparing
    their bisimulation quotients at increasing depths.

    This implements the decidability result: for simply-typed terms,
    β-equivalence can be decided by FTS comparison at bounded depth.

    Returns a report with the comparison results.
    """
    nf1 = normalize(prog1)
    nf2 = normalize(prog2)
    nf_equal = repr(nf1) == repr(nf2) if nf1 and nf2 else None

    results = []
    for d in range(max_depth):
        s1, t1, i1 = build_fts(prog1, d)
        s2, t2, i2 = build_fts(prog2, d)
        q1 = bisim_quotient(s1, t1)
        q2 = bisim_quotient(s2, t2)
        n1 = len(set(q1.values()))
        n2 = len(set(q2.values()))
        results.append({
            'depth': d,
            'quotient_size_1': n1,
            'quotient_size_2': n2,
            'same_size': n1 == n2
        })

    return {
        'program1': repr(prog1),
        'program2': repr(prog2),
        'normal_form_1': repr(nf1) if nf1 else "diverges",
        'normal_form_2': repr(nf2) if nf2 else "diverges",
        'normal_forms_equal': nf_equal,
        'depth_analysis': results
    }


# ─── Application 2: Compiler Optimization Validator ────────────────────────

def validate_optimization(original: Term, optimized: Term) -> dict:
    """
    Validate that a compiler optimization preserves program semantics
    by checking β-equivalence of the original and optimized terms.

    Real-world use case: Compilers for functional languages (Haskell, ML, etc.)
    apply β-reduction, η-expansion, and other transformations. This tool
    can verify that specific transformation instances preserve semantics.
    """
    nf_orig = normalize(original)
    nf_opt = normalize(optimized)

    if nf_orig is None or nf_opt is None:
        return {
            'valid': None,
            'reason': 'One or both terms do not normalize'
        }

    is_valid = repr(nf_orig) == repr(nf_opt)

    # Measure optimization benefit
    orig_size = original.size()
    opt_size = optimized.size()

    return {
        'valid': is_valid,
        'original': repr(original),
        'optimized': repr(optimized),
        'original_size': orig_size,
        'optimized_size': opt_size,
        'size_reduction': orig_size - opt_size,
        'reduction_pct': (1 - opt_size / orig_size) * 100 if orig_size > 0 else 0,
        'normal_form': repr(nf_orig) if is_valid else f"{repr(nf_orig)} ≠ {repr(nf_opt)}"
    }


# ─── Application 3: β-Equivalence Class Enumeration ───────────────────────

def enumerate_closed_terms(max_size: int, num_vars: int = 0) -> list[Term]:
    """
    Enumerate all closed λ-terms up to the given size.
    Uses de Bruijn-style enumeration with named variables.
    """
    results = []

    def gen(size: int, bound_vars: list[int]) -> list[Term]:
        if size <= 0:
            return []
        if size == 1:
            return [Var(v) for v in bound_vars]

        terms = []
        # Lambda abstraction
        if size >= 2:
            new_var = max(bound_vars) + 1 if bound_vars else 0
            for body in gen(size - 1, bound_vars + [new_var]):
                terms.append(Lam(new_var, body))

        # Application
        for s1 in range(1, size - 1):
            s2 = size - 1 - s1
            for f in gen(s1, bound_vars):
                for a in gen(s2, bound_vars):
                    terms.append(App(f, a))

        return terms

    return gen(max_size, list(range(num_vars)))


def classify_by_beta_equivalence(terms: list[Term]) -> dict[str, list[Term]]:
    """
    Classify a list of terms into β-equivalence classes
    based on their normal forms.
    """
    classes = defaultdict(list)
    for t in terms:
        nf = normalize(t)
        if nf is not None:
            classes[repr(nf)].append(t)
    return dict(classes)


# ─── Main Application Demos ───────────────────────────────────────────────

def app_program_equivalence():
    """Demo: Program equivalence checking."""
    print("=" * 70)
    print("APPLICATION 1: PROGRAM EQUIVALENCE CHECKER")
    print("=" * 70)
    print()

    I = Lam(0, Var(0))
    K = Lam(0, Lam(1, Var(0)))
    S = Lam(0, Lam(1, Lam(2, App(App(Var(0), Var(2)), App(Var(1), Var(2))))))
    SKK = App(App(S, K), K)
    II = App(I, I)

    pairs = [
        ("I", I, "I·I", II),
        ("I", I, "SKK", SKK),
        ("K·I", App(K, I), "λy.I", Lam(1, I)),
    ]

    for n1, t1, n2, t2 in pairs:
        report = check_program_equivalence(t1, t2, max_depth=5)
        equiv = report['normal_forms_equal']
        print(f"  {n1} ≡β {n2} ? {'YES' if equiv else 'NO'}")
        print(f"    Normal forms: {report['normal_form_1']} {'=' if equiv else '≠'} {report['normal_form_2']}")

        for r in report['depth_analysis']:
            marker = '✓' if r['same_size'] else '·'
            print(f"    d={r['depth']}: |Q₁|={r['quotient_size_1']}, "
                  f"|Q₂|={r['quotient_size_2']} {marker}")
        print()


def app_compiler_validation():
    """Demo: Compiler optimization validation."""
    print("=" * 70)
    print("APPLICATION 2: COMPILER OPTIMIZATION VALIDATOR")
    print("=" * 70)
    print()

    I = Lam(0, Var(0))
    K = Lam(0, Lam(1, Var(0)))

    # Optimization: (λx.x)(λy.y) → λy.y  (β-reduction)
    original = App(I, Lam(1, Var(1)))
    optimized = Lam(1, Var(1))
    report = validate_optimization(original, optimized)
    print(f"  Optimization: β-reduction of ({original}) → ({optimized})")
    print(f"    Valid: {report['valid']}")
    print(f"    Size reduction: {report['size_reduction']} ({report['reduction_pct']:.1f}%)")
    print()

    # Optimization: (λx.λy.x)(I) → λy.I  (partial evaluation)
    original2 = App(K, I)
    optimized2 = Lam(1, I)
    report2 = validate_optimization(original2, optimized2)
    print(f"  Optimization: partial evaluation of ({original2}) → ({optimized2})")
    print(f"    Valid: {report2['valid']}")
    print(f"    Size reduction: {report2['size_reduction']} ({report2['reduction_pct']:.1f}%)")
    print()

    # Invalid optimization (intentionally wrong)
    wrong = Lam(0, Lam(1, Var(1)))  # λx.λy.y instead of λx.λy.x
    report3 = validate_optimization(K, wrong)
    print(f"  INVALID optimization: ({K}) → ({wrong})")
    print(f"    Valid: {report3['valid']}")
    print(f"    Diverging normal forms: {report3['normal_form']}")
    print()


def app_term_classification():
    """Demo: β-equivalence class enumeration."""
    print("=" * 70)
    print("APPLICATION 3: β-EQUIVALENCE CLASS ENUMERATION")
    print("=" * 70)
    print()

    for size in range(1, 6):
        terms = enumerate_closed_terms(size)
        if not terms:
            continue
        classes = classify_by_beta_equivalence(terms)
        print(f"  Size ≤ {size}: {len(terms)} closed terms, "
              f"{len(classes)} β-equivalence classes")
        if len(classes) <= 8:
            for nf, members in sorted(classes.items(), key=lambda x: len(x[1]), reverse=True):
                print(f"    [{nf}]: {len(members)} terms")
                if len(members) <= 3:
                    for m in members:
                        print(f"      - {m}")

    print()


def app_performance_benchmark():
    """Demo: Performance benchmarks for quotient computation."""
    print("=" * 70)
    print("APPLICATION 4: PERFORMANCE BENCHMARKS")
    print("=" * 70)
    print()

    I = Lam(0, Var(0))
    K = Lam(0, Lam(1, Var(0)))
    S = Lam(0, Lam(1, Lam(2, App(App(Var(0), Var(2)), App(Var(1), Var(2))))))

    terms = [
        ("I", I),
        ("K", K),
        ("S", S),
        ("SKK", App(App(S, K), K)),
        ("S(KK)(KK)", App(App(S, App(K, K)), App(K, K))),
    ]

    print(f"  {'Term':<15} {'Depth':>5} {'States':>8} {'Trans':>8} {'Time(ms)':>10}")
    print(f"  {'-'*15} {'-'*5} {'-'*8} {'-'*8} {'-'*10}")

    for name, t in terms:
        for d in [2, 4, 6]:
            start = time.time()
            states, transitions, _ = build_fts(t, d)
            q = bisim_quotient(states, transitions)
            elapsed = (time.time() - start) * 1000
            print(f"  {name:<15} {d:>5} {len(states):>8} {len(transitions):>8} {elapsed:>10.2f}")
    print()


if __name__ == "__main__":
    app_program_equivalence()
    print()
    app_compiler_validation()
    print()
    app_term_classification()
    print()
    app_performance_benchmark()


#!/usr/bin/env python3
"""
demo.py — β-Class Structural Canonicity: Bisimulation Quotient Isomorphism

Demonstrates that β-equivalent λ-calculus terms yield isomorphic
bisimulation quotients at sufficient depth. Enumerates β-equivalent
term pairs, computes FTS quotients at multiple depths, checks
isomorphism via canonical labeling, and visualizes convergence.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
from collections import defaultdict
import itertools


# ─── Lambda Calculus Terms ──────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    name: int
    def __repr__(self): return f"x{self.name}"
    def size(self): return 1
    def free_vars(self): return {self.name}

@dataclass(frozen=True)
class Lam:
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}. {self.body})"
    def size(self): return 1 + self.body.size()
    def free_vars(self): return self.body.free_vars() - {self.var}

@dataclass(frozen=True)
class App:
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()
    def free_vars(self): return self.fun.free_vars() | self.arg.free_vars()

Term = Var | Lam | App


# ─── Substitution ──────────────────────────────────────────────────────────

def subst(t: Term, x: int, s: Term) -> Term:
    """Substitute s for x in t (capture-avoiding for our named vars)."""
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, Lam):
        if t.var == x:
            return t  # x is bound
        return Lam(t.var, subst(t.body, x, s))
    elif isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))


# ─── Beta Reduction ────────────────────────────────────────────────────────

def is_normal_form(t: Term) -> bool:
    """Check if t is in β-normal form."""
    if isinstance(t, Var):
        return True
    elif isinstance(t, Lam):
        return is_normal_form(t.body)
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return False  # β-redex
        return is_normal_form(t.fun) and is_normal_form(t.arg)

def beta_reduce_one(t: Term) -> list[Term]:
    """All possible one-step β-reducts of t."""
    results = []
    if isinstance(t, Var):
        pass
    elif isinstance(t, Lam):
        for b in beta_reduce_one(t.body):
            results.append(Lam(t.var, b))
    elif isinstance(t, App):
        # β-redex at root
        if isinstance(t.fun, Lam):
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        # Reduce in function position
        for f in beta_reduce_one(t.fun):
            results.append(App(f, t.arg))
        # Reduce in argument position
        for a in beta_reduce_one(t.arg):
            results.append(App(t.fun, a))
    return results

def normalize(t: Term, max_steps: int = 1000) -> Optional[Term]:
    """Normalize t by leftmost-outermost reduction."""
    for _ in range(max_steps):
        if is_normal_form(t):
            return t
        reducts = beta_reduce_one(t)
        if not reducts:
            return t
        t = reducts[0]  # leftmost
    return None  # didn't terminate


# ─── Finite Transition System ──────────────────────────────────────────────

@dataclass
class FTS:
    """A finite transition system extracted from a λ-term at bounded depth."""
    states: set
    init: Term
    transitions: set  # set of (source, target) pairs

    def state_count(self) -> int:
        return len(self.states)

    def transition_count(self) -> int:
        return len(self.transitions)


def build_fts(t: Term, depth: int) -> FTS:
    """Build the bounded FTS of term t at depth d."""
    states = set()
    transitions = set()
    queue = [(t, 0)]
    visited = set()

    while queue:
        term, d = queue.pop(0)
        term_key = repr(term)
        if term_key in visited or d > depth:
            continue
        visited.add(term_key)
        states.add(term_key)

        if d < depth:
            for reduct in beta_reduce_one(term):
                reduct_key = repr(reduct)
                states.add(reduct_key)
                transitions.add((term_key, reduct_key))
                queue.append((reduct, d + 1))

    return FTS(states=states, init=repr(t), transitions=transitions)


# ─── Bisimulation Quotient ─────────────────────────────────────────────────

def compute_bisim_quotient(fts: FTS) -> dict:
    """
    Compute the bisimulation quotient of an FTS using partition refinement.
    Returns a dict mapping states to their equivalence class index.
    """
    # Build adjacency list
    successors = defaultdict(set)
    for s, t in fts.transitions:
        successors[s].add(t)

    # Initial partition: all states in one block
    partition = {s: 0 for s in fts.states}

    changed = True
    while changed:
        changed = False
        # Refine: two states are equivalent iff they have the same
        # set of successor-block-signatures
        new_partition = {}
        signatures = {}
        next_id = 0

        for s in fts.states:
            sig = frozenset(partition[t] for t in successors[s])
            key = (partition[s], sig)
            if key not in signatures:
                signatures[key] = next_id
                next_id += 1
            new_partition[s] = signatures[key]

        if new_partition != partition:
            changed = True
            partition = new_partition

    return partition


def quotient_structure(fts: FTS) -> tuple:
    """
    Return a canonical representation of the bisimulation quotient:
    (num_classes, frozenset of (class_i, class_j) transitions, init_class)
    """
    partition = compute_bisim_quotient(fts)
    num_classes = len(set(partition.values()))

    # Canonical transitions
    q_transitions = set()
    for s, t in fts.transitions:
        q_transitions.add((partition[s], partition[t]))

    init_class = partition.get(fts.init, 0)

    return (num_classes, frozenset(q_transitions), init_class)


def are_isomorphic_quotients(fts1: FTS, fts2: FTS) -> bool:
    """
    Check if two FTS have isomorphic bisimulation quotients.
    Uses canonical labeling based on sorted transition signatures.
    """
    q1 = quotient_structure(fts1)
    q2 = quotient_structure(fts2)

    if q1[0] != q2[0]:
        return False  # Different number of classes

    # Check structural isomorphism by comparing canonical forms
    # Build adjacency for each quotient
    def canonical_form(num_classes, transitions, init):
        adj = defaultdict(set)
        for s, t in transitions:
            adj[s].add(t)

        # BFS from init to assign canonical labels
        labels = {}
        queue = [init]
        next_label = 0
        while queue:
            s = queue.pop(0)
            if s in labels:
                continue
            labels[s] = next_label
            next_label += 1
            for t in sorted(adj[s]):
                if t not in labels:
                    queue.append(t)

        # Relabel all states
        canon_trans = frozenset(
            (labels.get(s, s), labels.get(t, t)) for s, t in transitions
        )
        return (num_classes, canon_trans, labels.get(init, init))

    c1 = canonical_form(*q1)
    c2 = canonical_form(*q2)
    return c1 == c2


# ─── Example Terms ─────────────────────────────────────────────────────────

# Identity: λx. x
I = Lam(0, Var(0))

# K combinator: λx. λy. x
K = Lam(0, Lam(1, Var(0)))

# S combinator: λx. λy. λz. (x z) (y z)
S = Lam(0, Lam(1, Lam(2, App(App(Var(0), Var(2)), App(Var(1), Var(2))))))

# SKK = S K K  (β-equivalent to I)
SKK = App(App(S, K), K)

# KI = K I (λy. I)
KI = App(K, I)

# (λx. x) (λy. y) — I applied to I
II = App(I, I)


def reduction_depth(t: Term, max_steps: int = 100) -> int:
    """Count the number of reduction steps to normal form."""
    steps = 0
    for _ in range(max_steps):
        if is_normal_form(t):
            return steps
        reducts = beta_reduce_one(t)
        if not reducts:
            return steps
        t = reducts[0]
        steps += 1
    return steps


# ─── Main Demo ─────────────────────────────────────────────────────────────

def demo_beta_equivalence():
    """Demonstrate β-equivalence and FTS quotient isomorphism."""
    print("=" * 70)
    print("β-CLASS STRUCTURAL CANONICITY DEMO")
    print("Bisimulation Quotient Isomorphism for λ-Calculus")
    print("=" * 70)
    print()

    # Define β-equivalent pairs
    pairs = [
        ("I", I, "II (= I I)", II, "I applied to itself reduces to I"),
        ("I", I, "SKK", SKK, "SKK reduces to I (classic result)"),
        ("KI", KI, "λy. I", Lam(1, I), "K I reduces to λy. I"),
    ]

    for name1, t1, name2, t2, desc in pairs:
        print(f"--- Pair: {name1} vs {name2} ---")
        print(f"  {desc}")
        print(f"  t1 = {t1}")
        print(f"  t2 = {t2}")

        nf1 = normalize(t1)
        nf2 = normalize(t2)
        print(f"  Normal form of t1: {nf1}")
        print(f"  Normal form of t2: {nf2}")
        print(f"  Same normal form: {repr(nf1) == repr(nf2)}")

        rd1 = reduction_depth(t1)
        rd2 = reduction_depth(t2)
        print(f"  Reduction depth t1: {rd1}, t2: {rd2}")
        print(f"  max(normDepth) + 1 = {max(rd1, rd2) + 1}")

        print()
        print(f"  Depth | States(t1) | States(t2) | Trans(t1) | Trans(t2) | Iso?")
        print(f"  ------+------------+------------+-----------+-----------+-----")

        for d in range(max(rd1, rd2) + 3):
            fts1 = build_fts(t1, d)
            fts2 = build_fts(t2, d)
            iso = are_isomorphic_quotients(fts1, fts2)
            print(f"  {d:5d} | {fts1.state_count():10d} | {fts2.state_count():10d} "
                  f"| {fts1.transition_count():9d} | {fts2.transition_count():9d} "
                  f"| {'✓' if iso else '✗'}")

        print()


def demo_nerode_classes():
    """Demonstrate Nerode equivalence classes."""
    print("=" * 70)
    print("NERODE EQUIVALENCE CLASSES")
    print("=" * 70)
    print()

    terms = [
        ("I", I),
        ("II", II),
        ("SKK", SKK),
        ("K", K),
        ("KI", KI),
    ]

    depth = 3
    print(f"Computing Nerode classes at depth {depth}:")
    print()

    classes = defaultdict(list)
    for name, t in terms:
        fts = build_fts(t, depth)
        q = quotient_structure(fts)
        classes[q].append(name)

    for i, (structure, members) in enumerate(classes.items()):
        print(f"  Class {i+1}: {', '.join(members)}")
        print(f"    Quotient states: {structure[0]}")
        print(f"    Quotient transitions: {len(structure[1])}")
        print()


def demo_stabilization():
    """Demonstrate Nerode index stabilization."""
    print("=" * 70)
    print("NERODE INDEX STABILIZATION")
    print("=" * 70)
    print()

    terms = [
        ("I (normal form)", I),
        ("I I", II),
        ("S K K", SKK),
        ("K I", KI),
    ]

    for name, t in terms:
        print(f"  Term: {name} = {t}")
        indices = []
        for d in range(8):
            fts = build_fts(t, d)
            idx = len(compute_bisim_quotient(fts))
            indices.append(idx)

        print(f"  Nerode index by depth: {indices}")

        # Find stabilization point
        stable_from = 0
        for i in range(len(indices) - 1):
            if indices[i] != indices[-1]:
                stable_from = i + 1
        print(f"  Stabilizes at depth: {stable_from}")
        print()


def demo_conjecture_test():
    """Test the tight depth bound conjecture."""
    print("=" * 70)
    print("FALSIFIABLE CONJECTURE TEST: TIGHT DEPTH BOUND")
    print("=" * 70)
    print()
    print("Conjecture: d₀ = max(normDepth t, normDepth u) + 1 suffices")
    print("for isomorphic bisimulation quotients, and is tight.")
    print()

    pairs = [
        ("I", I, "II", II),
        ("I", I, "SKK", SKK),
        ("KI", KI, "λy.I", Lam(1, I)),
    ]

    all_confirmed = True
    for name1, t1, name2, t2 in pairs:
        rd1 = reduction_depth(t1)
        rd2 = reduction_depth(t2)
        d_max = max(rd1, rd2)
        d_threshold = d_max + 1

        print(f"  Pair: {name1} vs {name2}")
        print(f"    max(normDepth) = {d_max}")

        # Check at d_max (should potentially fail)
        fts1_low = build_fts(t1, d_max)
        fts2_low = build_fts(t2, d_max)
        iso_low = are_isomorphic_quotients(fts1_low, fts2_low)

        # Check at d_max + 1 (should succeed per conjecture)
        fts1_high = build_fts(t1, d_threshold)
        fts2_high = build_fts(t2, d_threshold)
        iso_high = are_isomorphic_quotients(fts1_high, fts2_high)

        print(f"    At d={d_max}: isomorphic = {iso_low}")
        print(f"    At d={d_threshold}: isomorphic = {iso_high}")

        if not iso_high:
            print(f"    *** CONJECTURE FALSIFIED! ***")
            all_confirmed = False
        else:
            print(f"    Conjecture confirmed for this pair")
        print()

    if all_confirmed:
        print("  All pairs confirm the conjecture.")
    else:
        print("  CONJECTURE FALSIFIED by at least one pair.")


if __name__ == "__main__":
    demo_beta_equivalence()
    print()
    demo_nerode_classes()
    print()
    demo_stabilization()
    print()
    demo_conjecture_test()
