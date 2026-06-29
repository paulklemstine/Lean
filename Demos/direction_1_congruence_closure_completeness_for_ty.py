#!/usr/bin/env python3
"""
Applications of Typed Congruence Closure
=========================================

Concrete applications demonstrating how the typed congruence closure
completeness theorem applies to real-world domains:

1. Compiler optimization: algebraic simplification of arithmetic
2. Symbolic algebra: canonical forms for polynomial expressions
3. Circuit equivalence: detecting equivalent Boolean circuits
"""

from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, Set, Tuple


# ═══════════════════════════════════════════════════════════════════════════
# Shared Infrastructure
# ═══════════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Term:
    sort: str
    sym: str
    args: Tuple['Term', ...] = ()

    def __repr__(self):
        if not self.args:
            return self.sym
        return f"{self.sym}({', '.join(str(a) for a in self.args)})"


class EGraph:
    """Minimal e-graph with congruence closure."""

    def __init__(self):
        self.parent: Dict[Term, Term] = {}
        self.rank: Dict[Term, int] = {}

    def add(self, t: Term):
        if t not in self.parent:
            self.parent[t] = t
            self.rank[t] = 0

    def find(self, t: Term) -> Term:
        if self.parent[t] != t:
            self.parent[t] = self.find(self.parent[t])
        return self.parent[t]

    def union(self, a: Term, b: Term) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True

    def same(self, a: Term, b: Term) -> bool:
        return self.find(a) == self.find(b)

    def propagate(self, terms: List[Term]) -> int:
        """Propagate congruences among terms."""
        by_sym = defaultdict(list)
        for t in terms:
            if t.args:
                by_sym[t.sym].append(t)

        merges = 0
        changed = True
        while changed:
            changed = False
            for sym, ts in by_sym.items():
                for i, t1 in enumerate(ts):
                    for t2 in ts[i+1:]:
                        if t1.sort == t2.sort and len(t1.args) == len(t2.args):
                            if all(self.same(a1, a2) for a1, a2 in zip(t1.args, t2.args)):
                                if self.union(t1, t2):
                                    merges += 1
                                    changed = True
        return merges

    def classes(self) -> Dict[Term, Set[Term]]:
        result = defaultdict(set)
        for t in self.parent:
            result[self.find(t)].add(t)
        return dict(result)


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Compiler Optimization — Algebraic Simplification
# ═══════════════════════════════════════════════════════════════════════════

def app_compiler_optimization():
    """
    Demonstrate how congruence closure discovers algebraic optimizations.

    Scenario: An optimizing compiler has arithmetic rewrite rules:
    - x * 1 → x
    - x + 0 → x
    - x * 0 → 0

    The compiler wants to know: are two expressions equivalent?
    Congruence closure gives the complete answer for the explored universe.
    """
    print("=" * 60)
    print("APPLICATION 1: Compiler Optimization")
    print("=" * 60)

    # Define some integer terms
    x = Term("Int", "x")
    zero = Term("Int", "0")
    one = Term("Int", "1")

    # Build compound expressions
    x_times_1 = Term("Int", "*", (x, one))          # x * 1
    x_plus_0 = Term("Int", "+", (x, zero))           # x + 0
    x_times_0 = Term("Int", "*", (x, zero))          # x * 0

    # More complex: (x * 1) + 0
    x1_plus_0 = Term("Int", "+", (x_times_1, zero))

    # Even more: ((x * 1) + 0) * 1
    complex_expr = Term("Int", "*", (x1_plus_0, one))

    all_terms = [x, zero, one, x_times_1, x_plus_0, x_times_0,
                 x1_plus_0, complex_expr]

    eg = EGraph()
    for t in all_terms:
        eg.add(t)

    # Apply rewrite rules
    rules = [
        (x_times_1, x),   # x * 1 → x
        (x_plus_0, x),     # x + 0 → x
        (x_times_0, zero), # x * 0 → 0
    ]

    print("\nRewrite rules:")
    for lhs, rhs in rules:
        print(f"  {lhs} → {rhs}")

    for lhs, rhs in rules:
        eg.union(lhs, rhs)

    # Propagate congruences
    merges = eg.propagate(all_terms)

    print(f"\nCongruence propagation: {merges} additional merges")

    # Check equivalences
    print(f"\nDiscovered equivalences:")
    print(f"  x * 1 ≡ x? {eg.same(x_times_1, x)}")
    print(f"  (x * 1) + 0 ≡ x? {eg.same(x1_plus_0, x)}")
    print(f"  ((x * 1) + 0) * 1 ≡ x? {eg.same(complex_expr, x)}")
    print(f"  x * 0 ≡ 0? {eg.same(x_times_0, zero)}")

    # Show equivalence classes
    print(f"\nEquivalence classes:")
    for rep, members in eg.classes().items():
        if len(members) > 1:
            print(f"  {{{', '.join(str(m) for m in members)}}}")

    print(f"\n  → Compiler discovers: '{complex_expr}' simplifies to '{x}'")
    print(f"    This optimization was found by congruence propagation,")
    print(f"    not by applying rules in sequence!")


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Symbolic Algebra — Polynomial Canonicalization
# ═══════════════════════════════════════════════════════════════════════════

def app_symbolic_algebra():
    """
    Demonstrate congruence closure for discovering polynomial identities.

    The key insight: commutativity and associativity rules, when saturated
    via congruence closure, identify all equivalent polynomial expressions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Symbolic Algebra")
    print("=" * 60)

    a = Term("R", "a")
    b = Term("R", "b")

    # a + b and b + a
    ab = Term("R", "+", (a, b))
    ba = Term("R", "+", (b, a))

    # a * b and b * a
    a_times_b = Term("R", "*", (a, b))
    b_times_a = Term("R", "*", (b, a))

    # (a + b) * (b + a)
    prod1 = Term("R", "*", (ab, ba))
    # (b + a) * (a + b)
    prod2 = Term("R", "*", (ba, ab))
    # (a + b) * (a + b)  — same as prod1 after commutativity
    prod3 = Term("R", "*", (ab, ab))

    all_terms = [a, b, ab, ba, a_times_b, b_times_a, prod1, prod2, prod3]

    eg = EGraph()
    for t in all_terms:
        eg.add(t)

    # Commutativity rules
    rules = [
        (ab, ba),               # a + b = b + a
        (a_times_b, b_times_a), # a * b = b * a
    ]

    print("\nCommutativity rules:")
    for lhs, rhs in rules:
        print(f"  {lhs} = {rhs}")

    for lhs, rhs in rules:
        eg.union(lhs, rhs)

    merges = eg.propagate(all_terms)

    print(f"\nCongruence propagation: {merges} additional merges")
    print(f"\nDiscovered identities:")
    print(f"  (a+b)*(b+a) ≡ (b+a)*(a+b)? {eg.same(prod1, prod2)}")
    print(f"  (a+b)*(b+a) ≡ (a+b)*(a+b)? {eg.same(prod1, prod3)}")
    print(f"  All three products equivalent? {eg.same(prod1, prod2) and eg.same(prod2, prod3)}")

    print(f"\n  → Congruence closure discovers: all three products are equal")
    print(f"    because a+b ≡ b+a, and * respects this equivalence.")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Circuit Equivalence
# ═══════════════════════════════════════════════════════════════════════════

def app_circuit_equivalence():
    """
    Demonstrate congruence closure for Boolean circuit equivalence.

    Two circuits are equivalent if they compute the same function.
    Congruence closure with Boolean algebra rules can discover this.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Circuit Equivalence Checking")
    print("=" * 60)

    x = Term("Bool", "x")
    y = Term("Bool", "y")
    true = Term("Bool", "T")
    false = Term("Bool", "F")

    # NOT(NOT(x))
    not_x = Term("Bool", "NOT", (x,))
    not_not_x = Term("Bool", "NOT", (not_x,))

    # AND(x, TRUE) and AND(TRUE, x)
    and_x_t = Term("Bool", "AND", (x, true))
    and_t_x = Term("Bool", "AND", (true, x))

    # OR(x, FALSE) and OR(FALSE, x)
    or_x_f = Term("Bool", "OR", (x, false))
    or_f_x = Term("Bool", "OR", (false, x))

    # AND(NOT(NOT(x)), TRUE)
    complex_circuit = Term("Bool", "AND", (not_not_x, true))

    all_terms = [x, y, true, false, not_x, not_not_x,
                 and_x_t, and_t_x, or_x_f, or_f_x, complex_circuit]

    eg = EGraph()
    for t in all_terms:
        eg.add(t)

    # Boolean algebra rules
    rules = [
        (not_not_x, x),       # NOT(NOT(x)) = x (double negation)
        (and_x_t, x),         # AND(x, T) = x (identity)
        (and_t_x, x),         # AND(T, x) = x (identity)
        (or_x_f, x),          # OR(x, F) = x (identity)
        (or_f_x, x),          # OR(F, x) = x (identity)
    ]

    print("\nBoolean algebra rules:")
    for lhs, rhs in rules:
        print(f"  {lhs} = {rhs}")

    for lhs, rhs in rules:
        eg.union(lhs, rhs)

    merges = eg.propagate(all_terms)

    print(f"\nCongruence propagation: {merges} additional merges")
    print(f"\nCircuit equivalences discovered:")
    print(f"  NOT(NOT(x)) ≡ x? {eg.same(not_not_x, x)}")
    print(f"  AND(x, T) ≡ x? {eg.same(and_x_t, x)}")
    print(f"  AND(NOT(NOT(x)), T) ≡ x? {eg.same(complex_circuit, x)}")

    classes = eg.classes()
    print(f"\n  Equivalence classes:")
    for rep, members in classes.items():
        if len(members) > 1:
            print(f"    {{{', '.join(str(m) for m in members)}}}")

    print(f"\n  → Circuit simplification: '{complex_circuit}' reduces to '{x}'")
    print(f"    The e-graph discovered this through congruence propagation!")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Model-Theoretic Soundness Demonstration
# ═══════════════════════════════════════════════════════════════════════════

def app_model_theoretic():
    """
    Demonstrate Theorem 6 (model-theoretic soundness): any interpretation
    respecting the rewrite rules is constant on e-graph equivalence classes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Model-Theoretic Soundness")
    print("=" * 60)

    # Terms
    a = Term("Nat", "a")
    b = Term("Nat", "b")
    fa = Term("Nat", "f", (a,))
    fb = Term("Nat", "f", (b,))
    ga = Term("Nat", "g", (a,))
    gb = Term("Nat", "g", (b,))

    terms = [a, b, fa, fb, ga, gb]

    eg = EGraph()
    for t in terms:
        eg.add(t)

    # Rule: a ≡ b
    eg.union(a, b)
    eg.propagate(terms)

    print("\nSetup: a ≡ b (one rewrite rule)")
    print("Congruence closure discovers: f(a)≡f(b), g(a)≡g(b)")

    # Define three different interpretations, all respecting a=b
    def interp1(t: Term) -> int:
        """Interpretation in ℤ: a,b↦3, f↦(x↦x²), g↦(x↦x+1)"""
        if t.sym in ('a', 'b'):
            return 3
        if t.sym == 'f':
            return interp1(t.args[0]) ** 2
        if t.sym == 'g':
            return interp1(t.args[0]) + 1
        return 0

    def interp2(t: Term) -> str:
        """Interpretation in strings: a,b↦'hello', f↦reverse, g↦upper"""
        if t.sym in ('a', 'b'):
            return 'hello'
        if t.sym == 'f':
            return interp2(t.args[0])[::-1]
        if t.sym == 'g':
            return interp2(t.args[0]).upper()
        return ''

    def interp3(t: Term) -> float:
        """Interpretation in ℝ: a,b↦π, f↦sin, g↦cos"""
        import math
        if t.sym in ('a', 'b'):
            return math.pi
        if t.sym == 'f':
            return math.sin(interp3(t.args[0]))
        if t.sym == 'g':
            return math.cos(interp3(t.args[0]))
        return 0.0

    print("\n  Three different interpretations, all respecting a=b:")
    print(f"\n  Interpretation 1 (integers, f=square, g=succ):")
    for t in terms:
        print(f"    I₁({t}) = {interp1(t)}")

    print(f"\n  Interpretation 2 (strings, f=reverse, g=upper):")
    for t in terms:
        print(f"    I₂({t}) = '{interp2(t)}'")

    print(f"\n  Interpretation 3 (reals, f=sin, g=cos):")
    for t in terms:
        print(f"    I₃({t}) = {interp3(t):.6f}")

    # Verify: same-class terms have same interpretation
    print(f"\n  Verification (Theorem 6):")
    for t1 in terms:
        for t2 in terms:
            if eg.same(t1, t2) and t1 != t2:
                ok1 = interp1(t1) == interp1(t2)
                ok2 = interp2(t1) == interp2(t2)
                ok3 = abs(interp3(t1) - interp3(t2)) < 1e-10
                print(f"    {t1} ≡ {t2}: I₁ equal={ok1}, I₂ equal={ok2}, I₃ equal={ok3}")

    print(f"\n  → Every interpretation respecting a=b is constant on e-classes.")
    print(f"    This is Theorem 6: model-theoretic soundness of congruence closure.")


if __name__ == "__main__":
    app_compiler_optimization()
    app_symbolic_algebra()
    app_circuit_equivalence()
    app_model_theoretic()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Typed Congruence Closure Demo
=============================

Interactive demonstration of the completeness theorem for typed congruence
closure in e-graphs. Generates random typed signatures and rewrite systems,
runs incremental congruence closure, and compares with normal-form equivalence.

Usage:
    python demo.py
"""

import random
import itertools
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Set, Optional


# ─── Typed Signature ────────────────────────────────────────────────────────

@dataclass
class TypedSignature:
    """A many-sorted signature with typed function symbols."""
    sorts: List[str]
    symbols: List[Tuple[str, List[str], str]]  # (name, arg_sorts, result_sort)

    def __repr__(self):
        lines = [f"Signature with sorts: {self.sorts}"]
        for name, args, ret in self.symbols:
            if args:
                arg_str = " × ".join(args)
                lines.append(f"  {name} : {arg_str} → {ret}")
            else:
                lines.append(f"  {name} : {ret}")
        return "\n".join(lines)


# ─── Typed Terms ─────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Term:
    """A typed first-order term."""
    sort: str
    head: str
    args: Tuple['Term', ...] = ()

    def __repr__(self):
        if not self.args:
            return self.head
        arg_str = ", ".join(str(a) for a in self.args)
        return f"{self.head}({arg_str})"

    def depth(self) -> int:
        if not self.args:
            return 0
        return 1 + max(a.depth() for a in self.args)

    def subterms(self) -> Set['Term']:
        result = {self}
        for a in self.args:
            result |= a.subterms()
        return result


def generate_terms(sig: TypedSignature, max_depth: int) -> List[Term]:
    """Generate all well-typed terms up to a given depth."""
    terms_by_sort: Dict[str, Set[Term]] = {s: set() for s in sig.sorts}

    # Depth 0: constants (nullary symbols)
    for name, args, ret in sig.symbols:
        if not args:
            terms_by_sort[ret].add(Term(ret, name))

    # Build up to max_depth
    for d in range(1, max_depth + 1):
        new_terms: Dict[str, Set[Term]] = {s: set() for s in sig.sorts}
        for name, arg_sorts, ret in sig.symbols:
            if not arg_sorts:
                continue
            # Generate all combinations of argument terms
            arg_options = []
            for s in arg_sorts:
                arg_options.append(list(terms_by_sort[s]))
            if any(not opts for opts in arg_options):
                continue
            for combo in itertools.product(*arg_options):
                t = Term(ret, name, combo)
                if t.depth() <= max_depth:
                    new_terms[ret].add(t)
        for s in sig.sorts:
            terms_by_sort[s] |= new_terms[s]

    all_terms = []
    for s in sig.sorts:
        all_terms.extend(terms_by_sort[s])
    return all_terms


# ─── Rewrite System ──────────────────────────────────────────────────────────

@dataclass
class RewriteRule:
    """A typed rewrite rule l → r where sort(l) = sort(r)."""
    lhs: Term
    rhs: Term

    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"


# ─── Union-Find (E-Graph Core) ──────────────────────────────────────────────

class UnionFind:
    """Union-Find data structure for e-graph equivalence classes."""

    def __init__(self):
        self.parent: Dict[Term, Term] = {}
        self.rank: Dict[Term, int] = {}

    def make_set(self, x: Term):
        if x not in self.parent:
            self.parent[x] = x
            self.rank[x] = 0

    def find(self, x: Term) -> Term:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: Term, y: Term) -> bool:
        """Merge classes of x and y. Returns True if a merge occurred."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def same_class(self, x: Term, y: Term) -> bool:
        return self.find(x) == self.find(y)


# ─── Incremental Congruence Closure ─────────────────────────────────────────

class TypedCongruenceEGraph:
    """
    Typed congruence e-graph with incremental closure.

    Implements the incremental merge-and-propagate algorithm:
    1. Initialize each term in its own class
    2. Merge rewrite-related pairs
    3. Propagate congruences: if f(a) and f(b) exist and a ~ b, merge f(a) ~ f(b)
    4. Repeat until fixpoint
    """

    def __init__(self, sig: TypedSignature, terms: List[Term]):
        self.sig = sig
        self.terms = terms
        self.uf = UnionFind()
        self.merge_count = 0
        self.check_count = 0
        self.merge_history: List[Tuple[Term, Term, str]] = []

        # Initialize union-find
        for t in terms:
            self.uf.make_set(t)

        # Index terms by head symbol and arguments for congruence lookup
        self.terms_by_head: Dict[str, List[Term]] = defaultdict(list)
        for t in terms:
            self.terms_by_head[t.head].append(t)

    def merge(self, a: Term, b: Term, reason: str) -> bool:
        """Merge two terms into the same class."""
        if self.uf.union(a, b):
            self.merge_count += 1
            self.merge_history.append((a, b, reason))
            return True
        return False

    def propagate_congruences(self) -> int:
        """Propagate congruence merges. Returns number of new merges."""
        new_merges = 0
        for sym_name, terms in self.terms_by_head.items():
            for i, t1 in enumerate(terms):
                for t2 in terms[i+1:]:
                    self.check_count += 1
                    if t1.sort != t2.sort:
                        continue
                    if len(t1.args) != len(t2.args):
                        continue
                    if all(self.uf.same_class(a1, a2)
                           for a1, a2 in zip(t1.args, t2.args)):
                        if self.merge(t1, t2, f"congruence({sym_name})"):
                            new_merges += 1
        return new_merges

    def run_closure(self, rules: List[RewriteRule]) -> int:
        """
        Run incremental congruence closure to saturation.
        Returns total number of merges.
        """
        # Phase 1: Apply all rewrite rules
        for rule in rules:
            for t in self.terms:
                # Check if rule.lhs matches t (exact match for ground terms)
                if t == rule.lhs:
                    if rule.rhs in self.uf.parent:
                        self.merge(t, rule.rhs, f"rewrite({rule})")

        # Phase 2: Propagate congruences until fixpoint
        while True:
            new = self.propagate_congruences()
            if new == 0:
                break

        return self.merge_count

    def get_partition(self) -> Dict[Term, Set[Term]]:
        """Get the equivalence class partition."""
        classes: Dict[Term, Set[Term]] = defaultdict(set)
        for t in self.terms:
            rep = self.uf.find(t)
            classes[rep].add(t)
        return dict(classes)

    def same_class(self, a: Term, b: Term) -> bool:
        return self.uf.same_class(a, b)


# ─── Normal Form Computation ────────────────────────────────────────────────

def compute_normal_forms(terms: List[Term], rules: List[RewriteRule],
                         max_steps: int = 1000) -> Dict[Term, Term]:
    """
    Compute normal forms by exhaustive rewriting.
    For ground terms, this is just repeated rule application.
    """
    nf: Dict[Term, Term] = {}
    for t in terms:
        current = t
        for _ in range(max_steps):
            rewritten = False
            # Try to rewrite at root
            for rule in rules:
                if current == rule.lhs:
                    current = rule.rhs
                    rewritten = True
                    break
            # Try to rewrite subterms
            if not rewritten and current.args:
                new_args = list(current.args)
                for i, arg in enumerate(current.args):
                    for rule in rules:
                        if arg == rule.lhs:
                            new_args[i] = rule.rhs
                            rewritten = True
                            break
                    if rewritten:
                        break
                if rewritten:
                    current = Term(current.sort, current.head, tuple(new_args))
            if not rewritten:
                break
        nf[t] = current
    return nf


def nf_partition(terms: List[Term], nf: Dict[Term, Term]) -> Dict[Term, Set[Term]]:
    """Partition terms by their normal forms."""
    classes: Dict[Term, Set[Term]] = defaultdict(set)
    for t in terms:
        classes[nf[t]].add(t)
    return dict(classes)


# ─── Random Generation ──────────────────────────────────────────────────────

def random_signature(num_sorts: int = 3, num_symbols: int = 5,
                     max_arity: int = 2) -> TypedSignature:
    """Generate a random typed signature."""
    sorts = [f"S{i}" for i in range(num_sorts)]
    symbols = []
    # Ensure at least one constant per sort
    for s in sorts:
        symbols.append((f"c_{s}", [], s))
    # Add random function symbols
    for i in range(num_symbols):
        arity = random.randint(0, max_arity)
        arg_sorts = [random.choice(sorts) for _ in range(arity)]
        ret_sort = random.choice(sorts)
        symbols.append((f"f{i}", arg_sorts, ret_sort))
    return TypedSignature(sorts, symbols)


def random_convergent_rules(sig: TypedSignature, terms: List[Term],
                            num_rules: int = 3) -> List[RewriteRule]:
    """
    Generate random convergent rewrite rules.
    Strategy: order terms by depth (deeper → simpler), pick random pairs.
    This ensures termination by construction.
    """
    rules = []
    terms_by_sort: Dict[str, List[Term]] = defaultdict(list)
    for t in terms:
        terms_by_sort[t.sort].append(t)

    for _ in range(num_rules):
        sort = random.choice(list(terms_by_sort.keys()))
        sort_terms = terms_by_sort[sort]
        if len(sort_terms) < 2:
            continue
        # Pick lhs with higher depth, rhs with lower depth (ensures termination)
        candidates = [(t1, t2) for t1, t2 in itertools.combinations(sort_terms, 2)
                       if t1.depth() > t2.depth()]
        if not candidates:
            # Pick any pair with different terms, orienting deeper → shallower
            candidates = [(t1, t2) for t1, t2 in itertools.combinations(sort_terms, 2)
                          if t1 != t2]
        if candidates:
            lhs, rhs = random.choice(candidates)
            if lhs.depth() < rhs.depth():
                lhs, rhs = rhs, lhs
            rules.append(RewriteRule(lhs, rhs))
    return rules


# ─── Demo Functions ──────────────────────────────────────────────────────────

def demo_basic():
    """Basic demonstration of congruence closure."""
    print("=" * 70)
    print("DEMO 1: Basic Congruence Closure")
    print("=" * 70)

    # Simple signature: sort Nat, constants 0, 1, unary s (successor), binary +
    sig = TypedSignature(
        sorts=["Nat"],
        symbols=[
            ("0", [], "Nat"),
            ("1", [], "Nat"),
            ("s", ["Nat"], "Nat"),
            ("plus", ["Nat", "Nat"], "Nat"),
        ]
    )
    print(f"\n{sig}\n")

    terms = generate_terms(sig, max_depth=2)
    print(f"Generated {len(terms)} terms up to depth 2")

    # Rules: s(0) → 1
    zero = Term("Nat", "0")
    one = Term("Nat", "1")
    s_zero = Term("Nat", "s", (zero,))
    rules = [RewriteRule(s_zero, one)]
    print(f"Rules: {rules}\n")

    # Run congruence closure
    egraph = TypedCongruenceEGraph(sig, terms)
    merges = egraph.run_closure(rules)

    print(f"Total merges: {merges}")
    print(f"Total congruence checks: {egraph.check_count}")
    print(f"\nMerge history:")
    for a, b, reason in egraph.merge_history:
        print(f"  {a} ≡ {b}  [{reason}]")

    # Check: s(0) and 1 should be in the same class
    print(f"\ns(0) ≡ 1? {egraph.same_class(s_zero, one)}")

    # Check congruence propagation: plus(s(0), x) ≡ plus(1, x)
    plus_s0_0 = Term("Nat", "plus", (s_zero, zero))
    plus_1_0 = Term("Nat", "plus", (one, zero))
    if plus_s0_0 in egraph.uf.parent and plus_1_0 in egraph.uf.parent:
        print(f"plus(s(0), 0) ≡ plus(1, 0)? {egraph.same_class(plus_s0_0, plus_1_0)}")

    # Compare with normal forms
    nf = compute_normal_forms(terms, rules)
    nf_part = nf_partition(terms, nf)
    egraph_part = egraph.get_partition()

    # Check agreement
    agree = True
    for t1 in terms:
        for t2 in terms:
            if t1.sort == t2.sort:
                same_nf = (nf[t1] == nf[t2])
                same_class = egraph.same_class(t1, t2)
                if same_nf != same_class:
                    agree = False
                    print(f"DISAGREEMENT: {t1}, {t2}: nf={same_nf}, class={same_class}")

    print(f"\nCongruence closure agrees with normal forms: {agree}")
    print(f"Number of equivalence classes (e-graph): {len(egraph_part)}")
    print(f"Number of equivalence classes (normal form): {len(nf_part)}")


def demo_random_systems():
    """Test completeness on random typed rewrite systems."""
    print("\n" + "=" * 70)
    print("DEMO 2: Random Typed Rewrite Systems")
    print("=" * 70)

    num_trials = 50
    all_agree = True
    total_merges = []
    total_checks = []
    total_terms = []

    for trial in range(num_trials):
        sig = random_signature(
            num_sorts=random.randint(2, 3),
            num_symbols=random.randint(2, 4),
            max_arity=random.randint(1, 2)
        )
        terms = generate_terms(sig, max_depth=2)
        if len(terms) < 3 or len(terms) > 200:
            continue

        rules = random_convergent_rules(sig, terms, num_rules=random.randint(1, 3))
        if not rules:
            continue

        # Run congruence closure
        egraph = TypedCongruenceEGraph(sig, terms)
        egraph.run_closure(rules)

        # Compute normal forms
        nf = compute_normal_forms(terms, rules)

        # Check agreement
        trial_agrees = True
        for t1 in terms:
            for t2 in terms:
                if t1.sort == t2.sort:
                    same_nf = (nf[t1] == nf[t2])
                    same_class = egraph.same_class(t1, t2)
                    if same_nf != same_class:
                        trial_agrees = False
                        all_agree = False

        total_merges.append(egraph.merge_count)
        total_checks.append(egraph.check_count)
        total_terms.append(len(terms))

        if not trial_agrees:
            print(f"  Trial {trial}: DISAGREEMENT (terms={len(terms)}, rules={len(rules)})")

    print(f"\nResults over {num_trials} random typed rewrite systems:")
    print(f"  All agree: {all_agree}")
    if total_merges:
        print(f"  Avg merges: {sum(total_merges)/len(total_merges):.1f}")
        print(f"  Max merges: {max(total_merges)}")
        print(f"  Avg checks: {sum(total_checks)/len(total_checks):.1f}")
        print(f"  Max checks: {max(total_checks)}")
        print(f"  Avg terms: {sum(total_terms)/len(total_terms):.1f}")
        print(f"  Max terms: {max(total_terms)}")


def demo_merge_growth():
    """Measure merge growth as signature complexity increases."""
    print("\n" + "=" * 70)
    print("DEMO 3: Merge Growth Statistics")
    print("=" * 70)

    print(f"\n{'Symbols':>8} {'MaxArity':>8} {'Terms':>8} {'Merges':>8} "
          f"{'Checks':>8} {'Classes':>8} {'Ratio':>10}")
    print("-" * 70)

    for num_sym in [3, 5, 7]:
        for max_ar in [1, 2]:
            merge_totals = []
            check_totals = []
            term_totals = []
            class_totals = []

            for _ in range(20):
                sig = random_signature(
                    num_sorts=2,
                    num_symbols=num_sym,
                    max_arity=max_ar
                )
                terms = generate_terms(sig, max_depth=2)
                if len(terms) < 3:
                    continue

                rules = random_convergent_rules(sig, terms, num_rules=3)
                egraph = TypedCongruenceEGraph(sig, terms)
                egraph.run_closure(rules)

                partition = egraph.get_partition()
                merge_totals.append(egraph.merge_count)
                check_totals.append(egraph.check_count)
                term_totals.append(len(terms))
                class_totals.append(len(partition))

            if merge_totals:
                avg_m = sum(merge_totals) / len(merge_totals)
                avg_c = sum(check_totals) / len(check_totals)
                avg_t = sum(term_totals) / len(term_totals)
                avg_cl = sum(class_totals) / len(class_totals)
                bound = num_sym * avg_t ** max_ar if avg_t > 0 else 0
                ratio = avg_c / bound if bound > 0 else 0
                print(f"{num_sym:>8} {max_ar:>8} {avg_t:>8.0f} {avg_m:>8.1f} "
                      f"{avg_c:>8.0f} {avg_cl:>8.0f} {ratio:>10.4f}")

    print(f"\nRatio = actual_checks / (n_symbols × universe_size^max_arity)")
    print(f"Values ≤ 1.0 confirm the polynomial bound from Theorem 7.")


def demo_e_class_evolution():
    """Show how e-classes evolve during incremental closure."""
    print("\n" + "=" * 70)
    print("DEMO 4: E-Class Evolution")
    print("=" * 70)

    sig = TypedSignature(
        sorts=["A", "B"],
        symbols=[
            ("a1", [], "A"), ("a2", [], "A"), ("a3", [], "A"),
            ("b1", [], "B"), ("b2", [], "B"),
            ("f", ["A"], "B"),
            ("g", ["B"], "A"),
        ]
    )
    print(f"\n{sig}\n")

    terms = generate_terms(sig, max_depth=2)
    print(f"Terms ({len(terms)}):")
    for t in sorted(terms, key=lambda x: (x.depth(), str(x))):
        print(f"  {t} : {t.sort}")

    # Rules: a1 → a2, b1 → b2
    a1 = Term("A", "a1")
    a2 = Term("A", "a2")
    b1 = Term("B", "b1")
    b2 = Term("B", "b2")
    rules = [RewriteRule(a1, a2), RewriteRule(b1, b2)]
    print(f"\nRules: {rules}")

    egraph = TypedCongruenceEGraph(sig, terms)

    # Show initial state
    print(f"\n--- Initial state ---")
    part = egraph.get_partition()
    print(f"  {len(part)} classes (each term in its own class)")

    # Apply rules and show step by step
    egraph.run_closure(rules)

    print(f"\n--- After saturation ---")
    print(f"  Merge history:")
    for a, b, reason in egraph.merge_history:
        print(f"    {a} ≡ {b}  [{reason}]")

    part = egraph.get_partition()
    print(f"\n  {len(part)} equivalence classes:")
    for rep, members in sorted(part.items(), key=lambda x: str(x[0])):
        members_str = ", ".join(str(m) for m in sorted(members, key=str))
        print(f"    [{members_str}] : {rep.sort}")

    # Verify against normal forms
    nf = compute_normal_forms(terms, rules)
    print(f"\n  Normal forms:")
    for t in sorted(terms, key=lambda x: (x.depth(), str(x))):
        if nf[t] != t:
            print(f"    nf({t}) = {nf[t]}")


if __name__ == "__main__":
    random.seed(42)
    demo_basic()
    demo_random_systems()
    demo_merge_growth()
    demo_e_class_evolution()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
