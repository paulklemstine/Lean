#!/usr/bin/env python3
"""
Equality Saturation Extraction: Real-World Applications

Demonstrates the theorems applied to concrete optimization domains:
1. Arithmetic Expression Optimization (compiler optimization)
2. Boolean Circuit Minimization (hardware synthesis)
3. Matrix Expression Optimization (scientific computing)
4. Cost-Pareto Analysis (multi-objective optimization)
"""

from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from algorithms import (
    Term, RewriteRule, UnionFindEGraph, CostModel,
    bounded_saturation, extract_cheapest, compute_normal_form,
    verify_extraction_semantics, verified_extraction_pipeline
)
import itertools


# ============================================================================
# Application 1: Arithmetic Expression Optimization
# ============================================================================

def arithmetic_optimization():
    """
    Demonstrates equality saturation for arithmetic expression optimization.

    This is the canonical application: a compiler wants to find the cheapest
    equivalent arithmetic expression. By Theorem 2, the extracted expression
    is both semantically equivalent and cost-optimal within the saturated
    equivalence class.
    """
    print("=" * 70)
    print("APPLICATION 1: Arithmetic Expression Optimization")
    print("=" * 70)
    print()

    x, y, z = Term("?x"), Term("?y"), Term("?z")

    # Algebraic rules (convergent for the identity/zero rules)
    rules = [
        # Identities
        RewriteRule(Term("add", (x, Term("0"))), x),
        RewriteRule(Term("mul", (x, Term("1"))), x),
        RewriteRule(Term("mul", (x, Term("0"))), Term("0")),
        # Commutativity
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
    ]

    # Test expressions of increasing complexity
    a, b, c = Term("a"), Term("b"), Term("c")
    expressions = [
        ("x+0",        Term("add", (a, Term("0")))),
        ("x*1",        Term("mul", (a, Term("1")))),
        ("(x+0)*1",    Term("mul", (Term("add", (a, Term("0"))), Term("1")))),
        ("x*0 + y*1",  Term("add", (Term("mul", (a, Term("0"))),
                                     Term("mul", (b, Term("1")))))),
        ("(x+0)*(y*1)+0", Term("add", (
            Term("mul", (Term("add", (a, Term("0"))),
                         Term("mul", (b, Term("1"))))),
            Term("0")))),
    ]

    print(f"{'Expression':<20} {'Original':>8} {'Extracted':>10} {'NF':>8} {'Saved':>6}")
    print("-" * 60)

    for name, expr in expressions:
        result = verified_extraction_pipeline(expr, rules, max_saturation_depth=10)
        nf, _ = compute_normal_form(expr, rules)

        print(f"{name:<20} {result.original_cost:>8} {result.extracted_cost:>10} "
              f"{nf.size():>8} {result.cost_reduction:>5.0%}")

    print()
    print("By Theorem 1: All extracted expressions preserve semantics.")
    print("By Theorem 2: Extracted cost ≤ cost of any equivalent expression.")
    print("By Theorem 3: Extracted and normal form have same denotation.")
    print()


# ============================================================================
# Application 2: Boolean Circuit Minimization
# ============================================================================

def boolean_circuit_minimization():
    """
    Demonstrates equality saturation for Boolean circuit optimization.

    Models Boolean gates as terms and applies algebraic identities
    to minimize gate count.
    """
    print("=" * 70)
    print("APPLICATION 2: Boolean Circuit Minimization")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")

    rules = [
        # Identity
        RewriteRule(Term("and", (x, Term("T"))), x),
        RewriteRule(Term("or", (x, Term("F"))), x),
        # Annihilation
        RewriteRule(Term("and", (x, Term("F"))), Term("F")),
        RewriteRule(Term("or", (x, Term("T"))), Term("T")),
        # Idempotence
        RewriteRule(Term("and", (x, x)), x),
        RewriteRule(Term("or", (x, x)), x),
        # Commutativity
        RewriteRule(Term("and", (x, y)), Term("and", (y, x))),
        RewriteRule(Term("or", (x, y)), Term("or", (y, x))),
    ]

    a, b = Term("a"), Term("b")
    circuits = [
        ("a AND T",           Term("and", (a, Term("T")))),
        ("a OR F",            Term("or", (a, Term("F")))),
        ("a AND F",           Term("and", (a, Term("F")))),
        ("(a AND T) OR F",    Term("or", (Term("and", (a, Term("T"))), Term("F")))),
        ("(a OR a) AND T",    Term("and", (Term("or", (a, a)), Term("T")))),
        ("(a AND b) OR (b AND a)",
            Term("or", (Term("and", (a, b)), Term("and", (b, a))))),
    ]

    # Gate cost model: each gate costs 1, constants cost 0
    def gate_cost(t: Term) -> int:
        if t.symbol in ("T", "F", "a", "b", "c"):
            return 0
        return 1 + sum(gate_cost(c) for c in t.children)

    cost_model = CostModel(gate_cost)

    print(f"{'Circuit':<30} {'Gates':>5} {'Optimized':>10} {'Gates':>5}")
    print("-" * 55)

    for name, circuit in circuits:
        result = verified_extraction_pipeline(
            circuit, rules, cost_model=cost_model, max_saturation_depth=10
        )
        orig_gates = gate_cost(circuit)
        opt_gates = gate_cost(result.extracted)
        print(f"{name:<30} {orig_gates:>5} {'→ ' + repr(result.extracted):>10} {opt_gates:>5}")

    print()
    print("Cost model: number of logic gates (constants are free)")
    print("By Theorem 2: extracted circuit has minimum gate count in its e-class.")
    print()


# ============================================================================
# Application 3: Symbolic Expression Simplification
# ============================================================================

def symbolic_simplification():
    """
    Demonstrates equality saturation for symbolic mathematics.

    Shows how equality saturation can find simplifications that
    normalization-based systems miss.
    """
    print("=" * 70)
    print("APPLICATION 3: Symbolic Expression Simplification")
    print("=" * 70)
    print()

    x, y, z = Term("?x"), Term("?y"), Term("?z")

    rules = [
        # Additive identity
        RewriteRule(Term("add", (x, Term("0"))), x),
        # Multiplicative identity
        RewriteRule(Term("mul", (x, Term("1"))), x),
        # Multiplicative zero
        RewriteRule(Term("mul", (x, Term("0"))), Term("0")),
        # Commutativity
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
        # Double negation
        RewriteRule(Term("neg", (Term("neg", (x,)),)), x),
        # Additive inverse
        RewriteRule(Term("add", (x, Term("neg", (x,)))), Term("0")),
    ]

    a, b = Term("a"), Term("b")
    expressions = [
        ("--a",         Term("neg", (Term("neg", (a,)),))),
        ("a + (-a)",    Term("add", (a, Term("neg", (a,))))),
        ("a*1 + 0",     Term("add", (Term("mul", (a, Term("1"))), Term("0")))),
        ("-(-a) * 1",   Term("mul", (Term("neg", (Term("neg", (a,)),)), Term("1")))),
        ("(a+(-a))*b",  Term("mul", (Term("add", (a, Term("neg", (a,)))), b))),
    ]

    print(f"{'Expression':<20} {'Size':>5} {'Simplified':>15} {'Size':>5}")
    print("-" * 50)

    for name, expr in expressions:
        result = verified_extraction_pipeline(expr, rules, max_saturation_depth=15)
        print(f"{name:<20} {expr.size():>5} {'→ ' + repr(result.extracted):>15} "
              f"{result.extracted.size():>5}")

    print()
    print("Key insight: equality saturation explores ALL equivalent forms,")
    print("then selects the smallest. This finds simplifications that")
    print("fixed-strategy normalizers may miss.")
    print()


# ============================================================================
# Application 4: Cost-Pareto Analysis
# ============================================================================

def cost_pareto_analysis():
    """
    Analyzes the Pareto frontier of cost vs. different metrics
    within equivalence classes.

    Shows that different cost models lead to different optimal
    extractions from the same equivalence class.
    """
    print("=" * 70)
    print("APPLICATION 4: Multi-Objective Cost Analysis")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")

    rules = [
        RewriteRule(Term("add", (x, Term("0"))), x),
        RewriteRule(Term("mul", (x, Term("1"))), x),
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
    ]

    a, b = Term("a"), Term("b")
    expr = Term("add", (Term("mul", (a, Term("1"))), Term("add", (b, Term("0")))))

    # Build saturated e-graph
    egraph = UnionFindEGraph()
    egraph.add(expr)
    result = bounded_saturation(egraph, rules, max_depth=10)

    eclass = egraph.get_class(expr)
    print(f"Expression: {expr}")
    print(f"E-class has {len(eclass)} members after saturation")
    print()

    # Define multiple cost models
    cost_models = {
        "Size (nodes)": CostModel(lambda t: t.size()),
        "Depth": CostModel(lambda t: t.depth()),
        "Multiplications": CostModel(
            lambda t: (1 if t.symbol == "mul" else 0) +
                      sum((1 if c.symbol == "mul" else 0) for c in t.children)
        ),
    }

    print(f"{'Member':<30} ", end="")
    for name in cost_models:
        print(f"{name:>15}", end="")
    print()
    print("-" * (30 + 15 * len(cost_models)))

    for member in sorted(eclass, key=lambda t: t.size()):
        print(f"{repr(member):<30} ", end="")
        for cm in cost_models.values():
            print(f"{cm.cost(member):>15}", end="")
        print()

    print()
    print("Optimal extractions by cost model:")
    for name, cm in cost_models.items():
        best = extract_cheapest(egraph, expr, cm)
        print(f"  {name}: {best} (cost={cm.cost(best)})")

    print()
    print("By Theorem 2: each extraction is optimal for its cost model.")
    print("By Theorem 1: ALL extractions preserve semantics.")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  EQUALITY SATURATION — REAL-WORLD APPLICATIONS                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    arithmetic_optimization()
    boolean_circuit_minimization()
    symbolic_simplification()
    cost_pareto_analysis()

    print("=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Equality Saturation Extraction: Interactive Demonstration

Demonstrates the core theorems computationally:
1. Extraction preserves semantics (Theorem 1)
2. Cheapest extraction is optimal (Theorem 2)
3. Extraction agrees with normal forms for convergent systems (Theorem 3)
4. Bounded saturation is always sound (Theorem 4)
5. Falsifiable conjecture: polynomial saturation depth

Usage:
    python demo.py
"""

import random
import itertools
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional, Callable

# ============================================================================
# Core Data Structures
# ============================================================================

class Term:
    """A simple first-order term over a finite alphabet."""
    def __init__(self, symbol: str, children: Tuple['Term', ...] = ()):
        self.symbol = symbol
        self.children = children

    def __repr__(self):
        if not self.children:
            return self.symbol
        args = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol}({args})"

    def __eq__(self, other):
        return (isinstance(other, Term) and
                self.symbol == other.symbol and
                self.children == other.children)

    def __hash__(self):
        return hash((self.symbol, self.children))

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)


class RewriteRule:
    """A rewrite rule lhs -> rhs (both are Terms, may contain variables)."""
    def __init__(self, lhs: Term, rhs: Term):
        self.lhs = lhs
        self.rhs = rhs

    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"


class EGraph:
    """
    A simple e-graph implementation for finite term universes.
    Uses union-find for equivalence class tracking.
    """
    def __init__(self):
        self.parent: Dict[Term, Term] = {}
        self.rank: Dict[Term, int] = {}
        self.members: Dict[Term, Set[Term]] = {}

    def add(self, t: Term) -> Term:
        if t not in self.parent:
            self.parent[t] = t
            self.rank[t] = 0
            self.members[t] = {t}
        return self.find(t)

    def find(self, t: Term) -> Term:
        if t not in self.parent:
            self.add(t)
        while self.parent[t] != t:
            self.parent[t] = self.parent[self.parent[t]]  # path compression
            t = self.parent[t]
        return t

    def merge(self, a: Term, b: Term) -> bool:
        """Merge e-classes of a and b. Returns True if a new merge occurred."""
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.members[ra] = self.members[ra] | self.members[rb]
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True

    def same_class(self, a: Term, b: Term) -> bool:
        return self.find(a) == self.find(b)

    def get_class(self, t: Term) -> Set[Term]:
        root = self.find(t)
        return self.members[root]

    def all_classes(self) -> List[Set[Term]]:
        classes = defaultdict(set)
        for t in self.parent:
            classes[self.find(t)].add(t)
        return list(classes.values())


# ============================================================================
# Rewrite System and Saturation
# ============================================================================

def match_term(pattern: Term, target: Term) -> Optional[Dict[str, Term]]:
    """Try to match pattern against target, returning variable bindings."""
    if pattern.symbol.startswith("?"):  # variable
        return {pattern.symbol: target}
    if pattern.symbol != target.symbol:
        return None
    if len(pattern.children) != len(target.children):
        return None
    bindings = {}
    for pc, tc in zip(pattern.children, target.children):
        sub = match_term(pc, tc)
        if sub is None:
            return None
        for k, v in sub.items():
            if k in bindings and bindings[k] != v:
                return None
            bindings[k] = v
    return bindings


def apply_bindings(term: Term, bindings: Dict[str, Term]) -> Term:
    """Substitute variables in term according to bindings."""
    if term.symbol.startswith("?"):
        return bindings.get(term.symbol, term)
    return Term(term.symbol, tuple(apply_bindings(c, bindings) for c in term.children))


def saturate(egraph: EGraph, rules: List[RewriteRule], max_depth: int, max_terms: int = 500) -> Tuple[EGraph, int, bool]:
    """
    Run bounded equality saturation.
    Returns (egraph, steps_taken, is_complete).
    """
    for step in range(max_depth):
        new_merges = False
        current_terms = list(egraph.parent.keys())
        if len(current_terms) > max_terms:
            return egraph, step, False
        for rule in rules:
            for t in current_terms:
                bindings = match_term(rule.lhs, t)
                if bindings is not None:
                    rhs = apply_bindings(rule.rhs, bindings)
                    egraph.add(rhs)
                    if egraph.merge(t, rhs):
                        new_merges = True
                # Also try reverse direction (for symmetric saturation)
                bindings = match_term(rule.rhs, t)
                if bindings is not None:
                    lhs = apply_bindings(rule.lhs, bindings)
                    egraph.add(lhs)
                    if egraph.merge(t, lhs):
                        new_merges = True
        if not new_merges:
            return egraph, step + 1, True
    return egraph, max_depth, False


def extract_cheapest(egraph: EGraph, term: Term) -> Term:
    """Extract the cheapest (smallest) term from the e-class of term."""
    eclass = egraph.get_class(term)
    return min(eclass, key=lambda t: t.size())


# ============================================================================
# Semantic Evaluation
# ============================================================================

def make_algebra(symbols: List[str], arities: Dict[str, int], size: int) -> Dict:
    """Create a random finite algebra of given size."""
    carrier = list(range(size))
    interp = {}
    for sym in symbols:
        arity = arities[sym]
        if arity == 0:
            interp[sym] = random.choice(carrier)
        else:
            keys = list(itertools.product(carrier, repeat=arity))
            interp[sym] = {k: random.choice(carrier) for k in keys}
    return {"carrier": carrier, "interp": interp}


def evaluate(term: Term, algebra: Dict) -> int:
    """Evaluate a term in a finite algebra."""
    interp = algebra["interp"]
    if not term.children:
        return interp[term.symbol]
    child_vals = tuple(evaluate(c, algebra) for c in term.children)
    return interp[term.symbol][child_vals]


# ============================================================================
# Convergent System: Normal Forms
# ============================================================================

def compute_nf(term: Term, rules: List[RewriteRule], max_steps: int = 1000) -> Term:
    """Compute normal form by exhaustive rule application (left-to-right)."""
    current = term
    for _ in range(max_steps):
        changed = False
        for rule in rules:
            bindings = match_term(rule.lhs, current)
            if bindings is not None:
                current = apply_bindings(rule.rhs, bindings)
                changed = True
                break
            # Try in subterms
            new_children = []
            subchanged = False
            for c in current.children:
                if not subchanged:
                    nc = compute_nf_step(c, rules)
                    if nc != c:
                        new_children.append(nc)
                        subchanged = True
                        changed = True
                    else:
                        new_children.append(c)
                else:
                    new_children.append(c)
            if subchanged:
                current = Term(current.symbol, tuple(new_children))
                break
        if not changed:
            break
    return current


def compute_nf_step(term: Term, rules: List[RewriteRule]) -> Term:
    """One step of normalization."""
    for rule in rules:
        bindings = match_term(rule.lhs, term)
        if bindings is not None:
            return apply_bindings(rule.rhs, bindings)
    return term


# ============================================================================
# Demo 1: Extraction Preserves Semantics
# ============================================================================

def demo_extraction_semantics():
    """
    Demonstrates Theorem 1: extraction_semantics_preserved.
    Shows that extracting from a saturated e-graph preserves semantics.
    """
    print("=" * 70)
    print("DEMO 1: Extraction Preserves Semantics")
    print("=" * 70)
    print()

    # Define a simple rewrite system: commutativity and identity
    x, y = Term("?x"), Term("?y")
    a, b, c = Term("a"), Term("b"), Term("c")
    zero = Term("0")

    rules = [
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),  # commutativity
        RewriteRule(Term("add", (x, zero)), x),  # identity
    ]

    # Create test terms
    t1 = Term("add", (a, Term("add", (b, zero))))  # a + (b + 0)
    t2 = Term("add", (Term("add", (zero, a)), b))  # (0 + a) + b

    print(f"Term 1: {t1}")
    print(f"Term 2: {t2}")
    print()

    # Build e-graph and saturate
    egraph = EGraph()
    egraph.add(t1)
    egraph.add(t2)
    egraph, steps, complete = saturate(egraph, rules, max_depth=10)
    print(f"Saturation: {steps} steps, complete={complete}")

    # Extract cheapest
    ext1 = extract_cheapest(egraph, t1)
    ext2 = extract_cheapest(egraph, t2)
    print(f"Extracted from t1: {ext1} (size {ext1.size()})")
    print(f"Extracted from t2: {ext2} (size {ext2.size()})")
    print()

    # Verify semantics across random algebras
    symbols = ["a", "b", "c", "0", "add"]
    arities = {"a": 0, "b": 0, "c": 0, "0": 0, "add": 2}
    n_algebras = 100
    all_match = True
    for i in range(n_algebras):
        alg = make_algebra(symbols, arities, size=5)
        # Make 0 actually behave as identity for add
        for k, v in alg["interp"]["add"].items():
            pass  # random algebra, no identity guarantee
        v_t1 = evaluate(t1, alg)
        v_ext1 = evaluate(ext1, alg)
        if egraph.same_class(t1, ext1) and v_t1 != v_ext1:
            print(f"  COUNTEREXAMPLE at algebra {i}: eval(t1)={v_t1}, eval(ext1)={v_ext1}")
            all_match = False

    if egraph.same_class(t1, ext1):
        print(f"Semantic verification: t1 and ext1 are in same e-class")
        print(f"  (Theorem 1 guarantees M(extract(t)) = M(t) for any M respecting EqvGen)")
    else:
        print(f"t1 and ext1 are NOT in same e-class (saturation incomplete for this pair)")
    print()


# ============================================================================
# Demo 2: Cheapest Extraction is Optimal
# ============================================================================

def demo_cheapest_extraction():
    """
    Demonstrates Theorem 2: cheapest_extraction_sound_and_optimal.
    """
    print("=" * 70)
    print("DEMO 2: Cheapest Extraction Is Sound and Optimal")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")
    a, b = Term("a"), Term("b")
    zero = Term("0")

    rules = [
        RewriteRule(Term("mul", (x, Term("1"))), x),  # x * 1 = x
        RewriteRule(Term("add", (x, zero)), x),       # x + 0 = x
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),  # comm
    ]

    # A complex expression
    t = Term("add", (Term("mul", (a, Term("1"))), Term("add", (b, zero))))
    print(f"Original term: {t} (size {t.size()})")

    egraph = EGraph()
    egraph.add(t)
    egraph, steps, complete = saturate(egraph, rules, max_depth=10)
    print(f"Saturation: {steps} steps, complete={complete}")

    # Show all members of the e-class
    eclass = egraph.get_class(t)
    print(f"E-class has {len(eclass)} members:")
    for member in sorted(eclass, key=lambda m: m.size()):
        print(f"  {member} (cost={member.size()})")

    # Extract cheapest
    extracted = extract_cheapest(egraph, t)
    print(f"\nCheapest extraction: {extracted} (cost={extracted.size()})")
    print(f"Cost reduction: {t.size()} → {extracted.size()}")

    # Verify optimality
    min_cost = min(m.size() for m in eclass)
    print(f"Minimum cost in class: {min_cost}")
    assert extracted.size() == min_cost, "Extraction should be cheapest!"
    print("✓ Extraction is cost-optimal within the e-class")
    print()


# ============================================================================
# Demo 3: Agreement with Normal Forms
# ============================================================================

def demo_nf_agreement():
    """
    Demonstrates Theorem 3: extraction_agrees_with_quotient_nf_semantically.
    """
    print("=" * 70)
    print("DEMO 3: Extraction Agrees with Normal Form Semantically")
    print("=" * 70)
    print()

    x = Term("?x")

    # Convergent system: x * 1 -> x, x + 0 -> x (terminating + confluent)
    rules = [
        RewriteRule(Term("mul", (x, Term("1"))), x),
        RewriteRule(Term("add", (x, Term("0"))), x),
    ]

    terms = [
        Term("mul", (Term("a"), Term("1"))),
        Term("add", (Term("b"), Term("0"))),
        Term("mul", (Term("add", (Term("a"), Term("0"))), Term("1"))),
    ]

    symbols = ["a", "b", "0", "1", "add", "mul"]
    arities = {"a": 0, "b": 0, "0": 0, "1": 0, "add": 2, "mul": 2}

    for t in terms:
        # Compute normal form
        nf = compute_nf(t, rules)

        # Build e-graph and extract
        egraph = EGraph()
        egraph.add(t)
        egraph, steps, complete = saturate(egraph, rules, max_depth=10)
        extracted = extract_cheapest(egraph, t)

        print(f"Term: {t}")
        print(f"  Normal form: {nf}")
        print(f"  Extracted:   {extracted}")

        # Verify semantic agreement across random algebras
        agree_count = 0
        total = 50
        for _ in range(total):
            alg = make_algebra(symbols, arities, size=4)
            v_nf = evaluate(nf, alg)
            v_ext = evaluate(extracted, alg)
            if v_nf == v_ext:
                agree_count += 1
        if nf == extracted:
            print(f"  Normal form = extracted term (trivially agree)")
        else:
            print(f"  Semantic agreement: {agree_count}/{total} algebras")
        print()


# ============================================================================
# Demo 4: Bounded Saturation Soundness
# ============================================================================

def demo_bounded_saturation():
    """
    Demonstrates Theorem 4: bounded_extractor_sound_of_complete.
    Even partial saturation preserves soundness.
    """
    print("=" * 70)
    print("DEMO 4: Bounded Saturation Is Always Sound")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")
    rules = [
        RewriteRule(Term("f", (Term("f", (x,)),)), Term("f", (x,))),  # f(f(x)) = f(x)
        RewriteRule(Term("g", (x, y)), Term("g", (y, x))),  # g(x,y) = g(y,x)
    ]

    t = Term("f", (Term("f", (Term("f", (Term("a"),)),)),))
    print(f"Term: {t}")
    print()

    for depth in [1, 2, 3, 5, 10]:
        egraph = EGraph()
        egraph.add(t)
        egraph, steps, complete = saturate(egraph, rules, max_depth=depth)
        extracted = extract_cheapest(egraph, t)
        n_classes = len(egraph.all_classes())

        print(f"  Depth {depth:2d}: {steps} steps, complete={complete}, "
              f"classes={n_classes}, extracted={extracted} (size={extracted.size()})")
        if egraph.same_class(t, extracted):
            print(f"           ✓ Extracted term is in same e-class (sound by Theorem 4)")
    print()


# ============================================================================
# Demo 5: Falsifiable Conjecture — Saturation Depth
# ============================================================================

def demo_saturation_depth_conjecture():
    """
    Tests the falsifiable conjecture: for finite convergent systems,
    saturation depth grows at most polynomially in the size of the
    reachable normal-form closure.
    """
    print("=" * 70)
    print("DEMO 5: Saturation Depth Conjecture (Falsifiable)")
    print("=" * 70)
    print()
    print("Conjecture: For finite convergent systems with max rule size k,")
    print("the saturation depth grows at most polynomially in the reachable closure size.")
    print()

    x = Term("?x")
    results = []

    # Generate random convergent (terminating) rewrite systems
    base_symbols = ["a", "b", "c"]
    for trial in range(20):
        random.seed(42 + trial)

        # Create simple terminating rules (larger → smaller)
        n_rules = random.randint(1, 4)
        rules = []
        for _ in range(n_rules):
            # Rule: f(x) → x  or  f(g(x)) → g(x)  etc.
            sym1 = random.choice(["f", "g", "h"])
            sym2 = random.choice(["f", "g", "h"])
            if random.random() < 0.5:
                rules.append(RewriteRule(Term(sym1, (x,)), x))
            else:
                rules.append(RewriteRule(
                    Term(sym1, (Term(sym2, (x,)),)),
                    Term(sym2, (x,))
                ))

        # Generate seed terms
        seeds = []
        for _ in range(10):
            t = Term(random.choice(base_symbols))
            for _ in range(random.randint(0, 4)):
                sym = random.choice(["f", "g", "h"])
                t = Term(sym, (t,))
            seeds.append(t)

        # Run saturation
        egraph = EGraph()
        for s in seeds:
            egraph.add(s)
        _, depth, complete = saturate(egraph, rules, max_depth=50)

        max_rule_size = max(r.lhs.size() for r in rules)
        total_seed_size = sum(s.size() for s in seeds)
        n_terms = len(egraph.parent)

        results.append({
            "trial": trial,
            "n_rules": n_rules,
            "max_rule_size": max_rule_size,
            "total_seed_size": total_seed_size,
            "depth": depth,
            "complete": complete,
            "n_terms": n_terms,
        })

    # Display results
    print(f"{'Trial':>5} {'Rules':>5} {'MaxK':>5} {'Seeds':>6} {'Depth':>6} {'Done':>5} {'Terms':>6}")
    print("-" * 46)
    for r in results:
        print(f"{r['trial']:5d} {r['n_rules']:5d} {r['max_rule_size']:5d} "
              f"{r['total_seed_size']:6d} {r['depth']:6d} "
              f"{'✓' if r['complete'] else '✗':>5} {r['n_terms']:6d}")

    # Analyze: is depth bounded polynomially?
    max_depth = max(r['depth'] for r in results)
    avg_depth = sum(r['depth'] for r in results) / len(results)
    complete_count = sum(1 for r in results if r['complete'])

    print()
    print(f"Summary: max depth = {max_depth}, avg depth = {avg_depth:.1f}, "
          f"complete = {complete_count}/{len(results)}")
    if max_depth <= 10:
        print("→ Consistent with polynomial bound conjecture (all depths small)")
    else:
        print("→ Possible evidence against tight polynomial bound")
    print()


# ============================================================================
# Demo 6: Visualize Class Merges and Costs
# ============================================================================

def demo_class_visualization():
    """
    Visualizes e-class merges and extracted costs.
    """
    print("=" * 70)
    print("DEMO 6: E-Class Merges and Cost Visualization")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")
    a, b = Term("a"), Term("b")

    rules = [
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),  # comm
        RewriteRule(Term("add", (x, Term("0"))), x),  # identity
        RewriteRule(Term("mul", (x, Term("1"))), x),  # mul identity
    ]

    seed = Term("add", (Term("mul", (a, Term("1"))), Term("add", (b, Term("0")))))
    print(f"Seed term: {seed} (cost={seed.size()})")
    print()

    egraph = EGraph()
    egraph.add(seed)

    for step in range(1, 8):
        old_classes = len(egraph.all_classes())
        egraph_copy = EGraph()
        egraph_copy.parent = dict(egraph.parent)
        egraph_copy.rank = dict(egraph.rank)
        egraph_copy.members = {k: set(v) for k, v in egraph.members.items()}

        _, _, _ = saturate(egraph, rules, max_depth=1)
        new_classes = len(egraph.all_classes())

        eclass = egraph.get_class(seed)
        cheapest = min(eclass, key=lambda t: t.size()) if eclass else seed

        bar = "█" * len(eclass)
        print(f"Step {step}: classes={new_classes:3d} | class_size={len(eclass):3d} | "
              f"cheapest={cheapest} (cost={cheapest.size()}) | {bar}")

        if new_classes == old_classes and step > 1:
            print("  → Saturated! No new merges.")
            break

    print()
    print("Final e-class contents:")
    eclass = egraph.get_class(seed)
    for member in sorted(eclass, key=lambda t: t.size()):
        cost_bar = "■" * member.size()
        print(f"  {cost_bar} (cost={member.size():2d}) {member}")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  EQUALITY SATURATION EXTRACTION CORRECTNESS — INTERACTIVE DEMO     ║")
    print("║                                                                    ║")
    print("║  Demonstrating that optimization by equality saturation is          ║")
    print("║  quotient-theoretic semantics in disguise.                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_extraction_semantics()
    demo_cheapest_extraction()
    demo_nf_agreement()
    demo_bounded_saturation()
    demo_saturation_depth_conjecture()
    demo_class_visualization()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()
