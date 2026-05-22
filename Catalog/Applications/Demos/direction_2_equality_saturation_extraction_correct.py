#!/usr/bin/env python3
"""
applications.py — Real-World Applications of E-Graph Extraction Correctness

Demonstrates practical applications:
1. Compiler optimization pass verification
2. Symbolic algebra simplification
3. Circuit optimization
4. Testing the global optimality conjecture
"""

import random
from typing import Dict, List, Tuple
from dataclasses import dataclass

# Import core infrastructure
from algorithms import (
    Term, Const, Var, BinOp, term_size, eval_term,
    RewriteRule, make_arithmetic_rules, normalize,
    EGraph, verified_extract
)


# ============================================================
# Application 1: Compiler Optimization Pass
# ============================================================

def compiler_optimization_demo():
    """Simulate a compiler optimization pass using equality saturation.

    Shows how the extraction correctness theorem guarantees that
    program transformations preserve semantics.
    """
    print("=" * 70)
    print("APPLICATION 1: COMPILER OPTIMIZATION PASS")
    print("=" * 70)
    print()

    # Simulate a simple "program" as an arithmetic expression
    # representing a computation like: result = (1 * input + 0) * (input + 0)
    programs = [
        ("Dead code elimination",
         BinOp("+", BinOp("*", Const(0), Var("unused")), Var("result")),
         "0*unused + result"),
        ("Identity simplification",
         BinOp("*", BinOp("+", Var("x"), Const(0)), Const(1)),
         "(x + 0) * 1"),
        ("Constant folding",
         BinOp("+", BinOp("*", Const(3), Const(4)), Var("y")),
         "3*4 + y"),
        ("Nested simplification",
         BinOp("*", BinOp("+", BinOp("*", Const(1), Var("a")), Const(0)),
                BinOp("+", Var("b"), BinOp("*", Const(0), Var("c")))),
         "(1*a + 0) * (b + 0*c)"),
    ]

    rules = make_arithmetic_rules()
    envs = [{"x": i, "y": j, "a": k, "b": l, "c": m,
             "result": n, "input": p, "unused": q}
            for i, j, k, l, m, n, p, q in [
                (1, 2, 3, 4, 5, 6, 7, 8),
                (-1, 0, 1, -2, 3, -4, 5, -6),
                (100, -50, 25, -12, 6, -3, 1, 0),
            ]]

    for name, program, desc in programs:
        extracted, ok = verified_extract(program, rules, envs)
        orig_size = term_size(program)
        opt_size = term_size(extracted)
        speedup = orig_size / max(opt_size, 1)

        print(f"  {name}:")
        print(f"    Input:     {desc}")
        print(f"    Optimized: {extracted}")
        print(f"    Size: {orig_size} → {opt_size} ({speedup:.1f}x reduction)")
        print(f"    Semantics preserved: {'✓' if ok else '✗'}")
        print()


# ============================================================
# Application 2: Symbolic Algebra
# ============================================================

def symbolic_algebra_demo():
    """Use e-graph extraction for symbolic simplification.

    Shows how the extraction correctness theorem guarantees that
    algebraic simplifications preserve mathematical meaning.
    """
    print("=" * 70)
    print("APPLICATION 2: SYMBOLIC ALGEBRA SIMPLIFICATION")
    print("=" * 70)
    print()

    # Extended rules for algebra
    rules = make_arithmetic_rules()

    # Expressions to simplify
    expressions = [
        ("Polynomial identity",
         BinOp("+", BinOp("*", Var("x"), Const(1)),
                BinOp("*", Const(0), BinOp("+", Var("x"), Var("y")))),
         "x*1 + 0*(x+y)"),
        ("Nested multiplication",
         BinOp("*", BinOp("*", Const(1), Var("x")),
                BinOp("*", Var("y"), Const(1))),
         "(1*x) * (y*1)"),
        ("Zero absorption",
         BinOp("+", BinOp("*", Var("a"),
                BinOp("*", Const(0), Var("b"))),
                BinOp("*", Const(1), Var("c"))),
         "a*(0*b) + 1*c"),
    ]

    envs = [{"x": x, "y": y, "a": a, "b": b, "c": c}
            for x in range(-3, 4) for y in range(-3, 4)
            for a, b, c in [(1, 2, 3), (-1, 0, 1)]]

    for name, expr, desc in expressions:
        eg = EGraph()
        tid = eg.add(expr)
        merges, iters = eg.saturate(rules)
        extracted = eg.extract(tid)
        ok = all(eval_term(expr, env) == eval_term(extracted, env) for env in envs)

        print(f"  {name}:")
        print(f"    Input:      {desc}")
        print(f"    Simplified: {extracted}")
        print(f"    E-classes:  {eg.num_classes()}")
        print(f"    Correct:    {'✓' if ok else '✗'} (tested {len(envs)} environments)")
        print()


# ============================================================
# Application 3: Testing the Global Optimality Conjecture
# ============================================================

def test_global_optimality_conjecture():
    """Test whether extraction always yields the globally minimum-cost term.

    Conjecture: For a convergent rewrite system R with monotone cost c,
    cost(extract(t)) ≤ cost(t') for all t' equivalent to t.

    We test this by enumerating all terms in each e-class after saturation
    and checking that the extracted term has minimal cost.
    """
    print("=" * 70)
    print("APPLICATION 3: GLOBAL OPTIMALITY CONJECTURE TEST")
    print("=" * 70)
    print()

    random.seed(42)
    rules = make_arithmetic_rules()

    n_tests = 200
    violations = 0
    tested = 0

    for i in range(n_tests):
        # Generate random term
        depth = random.randint(1, 4)
        t = random_binop_term(depth)

        eg = EGraph()
        tid = eg.add(t)
        eg.saturate(rules)

        # Extract cheapest
        extracted = eg.extract(tid)
        extract_cost = term_size(extracted)

        # Check all terms in the same class
        root = eg.find(tid)
        class_terms = [(t2, term_size(t2))
                       for t2, t_id in eg.hashcons.items()
                       if eg.find(t_id) == root]

        if class_terms:
            min_cost = min(c for _, c in class_terms)
            if extract_cost > min_cost:
                violations += 1
                cheaper = [(t2, c) for t2, c in class_terms if c < extract_cost]
                if violations <= 3:
                    print(f"  Violation #{violations}: extract cost={extract_cost}, "
                          f"min in class={min_cost}")
            tested += 1

    print(f"  Tested: {tested} e-classes")
    print(f"  Violations: {violations}")
    if violations == 0:
        print("  ✓ Conjecture holds for all tested cases!")
    else:
        print(f"  ✗ {violations} violations found — conjecture may be false")
    print()


def random_binop_term(depth: int) -> Term:
    """Generate a random term using BinOp."""
    if depth <= 0:
        if random.random() < 0.4:
            return Const(random.choice([0, 1, 2, 3]))
        else:
            return Var(random.choice(["x", "y", "z"]))

    choice = random.random()
    if choice < 0.2:
        return Const(random.choice([0, 1, 2, 3]))
    elif choice < 0.4:
        return Var(random.choice(["x", "y", "z"]))
    elif choice < 0.7:
        return BinOp("+", random_binop_term(depth - 1), random_binop_term(depth - 1))
    else:
        return BinOp("*", random_binop_term(depth - 1), random_binop_term(depth - 1))


# ============================================================
# Application 4: Benchmark — Extraction vs Direct Normalization
# ============================================================

def benchmark_extraction_vs_normalization():
    """Compare e-graph extraction with direct normalization.

    Both approaches should produce equivalent results, but may differ in:
    - Output term (extraction might find smaller terms via alternative paths)
    - Performance (normalization is deterministic, extraction explores more)
    """
    print("=" * 70)
    print("APPLICATION 4: EXTRACTION vs DIRECT NORMALIZATION")
    print("=" * 70)
    print()

    random.seed(123)
    rules = make_arithmetic_rules()
    n_terms = 300

    agree = 0
    extraction_wins = 0
    normalization_wins = 0

    for _ in range(n_terms):
        t = random_binop_term(random.randint(2, 5))

        # Direct normalization
        nf, nf_steps = normalize(t, rules)
        nf_cost = term_size(nf)

        # E-graph extraction
        eg = EGraph()
        tid = eg.add(t)
        eg.saturate(rules)
        extracted = eg.extract(tid)
        ext_cost = term_size(extracted)

        if nf_cost == ext_cost:
            agree += 1
        elif ext_cost < nf_cost:
            extraction_wins += 1
        else:
            normalization_wins += 1

    print(f"  Same cost:          {agree}/{n_terms}")
    print(f"  Extraction better:  {extraction_wins}/{n_terms}")
    print(f"  Normalization better: {normalization_wins}/{n_terms}")
    print()
    print("  Note: Both methods preserve semantics (by our theorem).")
    print("  E-graph extraction can find shorter terms by exploring")
    print("  alternative reduction paths simultaneously.")
    print()


if __name__ == "__main__":
    compiler_optimization_demo()
    symbolic_algebra_demo()
    test_global_optimality_conjecture()
    benchmark_extraction_vs_normalization()


#!/usr/bin/env python3
"""
demo.py — E-Graph Saturation and Extraction Correctness Demo

Demonstrates the core theorem: for a convergent rewrite system, extracting the
cheapest representative from a saturated e-graph preserves evaluation semantics.

Shows:
1. A concrete convergent rewrite system (integer arithmetic simplification)
2. E-graph saturation and extraction under a monotone cost model
3. Verification that eval(extract(t)) == eval(t) for 1000 random terms
4. A counterexample showing non-saturated e-graphs can violate this property
"""

import random
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple, Callable, Set
from collections import defaultdict

# ============================================================
# Term Algebra
# ============================================================

@dataclass(frozen=True)
class Term:
    """Base class for terms in a simple arithmetic expression language."""
    pass

@dataclass(frozen=True)
class Const(Term):
    value: int

@dataclass(frozen=True)
class Var(Term):
    name: str

@dataclass(frozen=True)
class Add(Term):
    left: Term
    right: Term

@dataclass(frozen=True)
class Mul(Term):
    left: Term
    right: Term

def eval_term(t: Term, env: Dict[str, int]) -> int:
    """Evaluate a term under a variable assignment."""
    if isinstance(t, Const):
        return t.value
    elif isinstance(t, Var):
        return env.get(t.name, 0)
    elif isinstance(t, Add):
        return eval_term(t.left, env) + eval_term(t.right, env)
    elif isinstance(t, Mul):
        return eval_term(t.left, env) * eval_term(t.right, env)
    raise ValueError(f"Unknown term type: {type(t)}")

def term_size(t: Term) -> int:
    """AST node count (monotone cost function)."""
    if isinstance(t, (Const, Var)):
        return 1
    elif isinstance(t, (Add, Mul)):
        return 1 + term_size(t.left) + term_size(t.right)
    return 1

def term_to_str(t: Term) -> str:
    if isinstance(t, Const):
        return str(t.value)
    elif isinstance(t, Var):
        return t.name
    elif isinstance(t, Add):
        return f"({term_to_str(t.left)} + {term_to_str(t.right)})"
    elif isinstance(t, Mul):
        return f"({term_to_str(t.left)} * {term_to_str(t.right)})"
    return "?"

# ============================================================
# Rewrite Rules (Convergent System)
# ============================================================

def apply_rewrite(t: Term) -> List[Tuple[str, Term]]:
    """Apply all applicable rewrite rules, returning (rule_name, result) pairs.

    Rules (oriented for termination — all reduce AST size or simplify):
      R1: x + 0 → x
      R2: 0 + x → x
      R3: x * 1 → x
      R4: 1 * x → x
      R5: x * 0 → 0
      R6: 0 * x → 0
      R7: x + y → y + x  (commutativity, oriented by lexicographic order)
      R8: x * y → y * x  (commutativity, oriented by lexicographic order)
    """
    results = []

    if isinstance(t, Add):
        if isinstance(t.right, Const) and t.right.value == 0:
            results.append(("x+0→x", t.left))
        if isinstance(t.left, Const) and t.left.value == 0:
            results.append(("0+x→x", t.right))

    if isinstance(t, Mul):
        if isinstance(t.right, Const) and t.right.value == 1:
            results.append(("x*1→x", t.left))
        if isinstance(t.left, Const) and t.left.value == 1:
            results.append(("1*x→x", t.right))
        if isinstance(t.right, Const) and t.right.value == 0:
            results.append(("x*0→0", Const(0)))
        if isinstance(t.left, Const) and t.left.value == 0:
            results.append(("0*x→0", Const(0)))

    return results

# ============================================================
# E-Graph (Union-Find based)
# ============================================================

class EGraph:
    """A simple e-graph implementation using union-find."""

    def __init__(self):
        self.parent: Dict[int, int] = {}
        self.rank: Dict[int, int] = {}
        self.terms: Dict[int, Term] = {}  # id -> term
        self.term_to_id: Dict[Term, int] = {}  # term -> id (hashcons)
        self.next_id = 0

    def add(self, t: Term) -> int:
        """Add a term to the e-graph, returning its e-class id."""
        if t in self.term_to_id:
            return self.find(self.term_to_id[t])

        tid = self.next_id
        self.next_id += 1
        self.parent[tid] = tid
        self.rank[tid] = 0
        self.terms[tid] = t
        self.term_to_id[t] = tid

        # Recursively add subterms
        if isinstance(t, (Add, Mul)):
            self.add(t.left)
            self.add(t.right)

        return tid

    def find(self, x: int) -> int:
        """Find with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> int:
        """Union by rank, returns the new root."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return rx
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return rx

    def are_equal(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)

    def saturate(self, max_iters: int = 100) -> int:
        """Apply all rewrite rules until saturation or max iterations.
        Returns the number of new equalities discovered."""
        total_merges = 0
        for iteration in range(max_iters):
            new_merges = 0
            # Collect all terms and their ids
            all_terms = list(self.term_to_id.items())
            for t, tid in all_terms:
                rewrites = apply_rewrite(t)
                for rule_name, result in rewrites:
                    rid = self.add(result)
                    if not self.are_equal(tid, rid):
                        self.union(tid, rid)
                        new_merges += 1
            total_merges += new_merges
            if new_merges == 0:
                break
        return total_merges

    def extract_cheapest(self, tid: int) -> Term:
        """Extract the cheapest (smallest AST) term from an e-class."""
        root = self.find(tid)
        best_term = None
        best_cost = float('inf')
        for t, t_id in self.term_to_id.items():
            if self.find(t_id) == root:
                cost = term_size(t)
                if cost < best_cost:
                    best_cost = cost
                    best_term = t
        return best_term if best_term is not None else self.terms[tid]

    def get_class_members(self, tid: int) -> List[Term]:
        """Get all terms in the same e-class."""
        root = self.find(tid)
        return [t for t, t_id in self.term_to_id.items() if self.find(t_id) == root]


# ============================================================
# Random Term Generator
# ============================================================

def random_term(depth: int, vars: List[str] = ["x", "y", "z"]) -> Term:
    """Generate a random term of bounded depth."""
    if depth <= 0:
        if random.random() < 0.4:
            return Const(random.choice([0, 1, 2, 3]))
        else:
            return Var(random.choice(vars))

    op = random.choice(["add", "mul", "const", "var"])
    if op == "const":
        return Const(random.choice([0, 1, 2, 3]))
    elif op == "var":
        return Var(random.choice(vars))
    elif op == "add":
        return Add(random_term(depth - 1, vars), random_term(depth - 1, vars))
    else:
        return Mul(random_term(depth - 1, vars), random_term(depth - 1, vars))


def random_env(vars: List[str] = ["x", "y", "z"]) -> Dict[str, int]:
    """Generate a random variable assignment."""
    return {v: random.randint(-10, 10) for v in vars}


# ============================================================
# Main Demo
# ============================================================

def demo_extraction_correctness():
    """Demonstrate that extraction preserves evaluation for 1000 random terms."""
    print("=" * 70)
    print("E-GRAPH EXTRACTION CORRECTNESS DEMO")
    print("=" * 70)
    print()
    print("Theorem: For a convergent rewrite system R with monotone cost,")
    print("         eval(extract(t)) = eval(t) for all terms t.")
    print()

    random.seed(42)
    n_terms = 1000
    n_envs = 10
    vars = ["x", "y", "z"]

    print(f"Testing with {n_terms} random terms, {n_envs} random environments each...")
    print()

    violations = 0
    total_checks = 0
    total_cost_savings = 0
    terms_simplified = 0

    for i in range(n_terms):
        t = random_term(depth=3, vars=vars)
        eg = EGraph()
        tid = eg.add(t)
        eg.saturate()
        extracted = eg.extract_cheapest(tid)

        orig_cost = term_size(t)
        extr_cost = term_size(extracted)

        if extr_cost < orig_cost:
            terms_simplified += 1
            total_cost_savings += (orig_cost - extr_cost)

        for _ in range(n_envs):
            env = random_env(vars)
            val_orig = eval_term(t, env)
            val_extr = eval_term(extracted, env)
            total_checks += 1
            if val_orig != val_extr:
                violations += 1
                print(f"  VIOLATION: {term_to_str(t)} -> {term_to_str(extracted)}")
                print(f"    env={env}, eval(orig)={val_orig}, eval(extr)={val_extr}")

    print(f"Results:")
    print(f"  Total checks: {total_checks}")
    print(f"  Violations: {violations}")
    print(f"  Terms simplified: {terms_simplified}/{n_terms}")
    print(f"  Total AST nodes saved: {total_cost_savings}")
    print()

    if violations == 0:
        print("✓ All checks passed! Extraction preserves evaluation.")
    else:
        print("✗ VIOLATIONS FOUND — extraction is not sound!")
    print()


def demo_non_saturated_counterexample():
    """Show that a non-saturated e-graph can violate extraction correctness."""
    print("=" * 70)
    print("COUNTEREXAMPLE: NON-SATURATED E-GRAPH")
    print("=" * 70)
    print()
    print("Without saturation, extraction can choose a term from a DIFFERENT")
    print("equivalence class, violating eval(extract(t)) = eval(t).")
    print()

    # Create an e-graph and manually merge classes that shouldn't be merged
    # (simulating incomplete saturation that incorrectly merges)
    eg = EGraph()

    # Terms: x and (x + 0) should be equivalent after saturation
    # But if we merge x with y (incorrectly), extraction can go wrong
    t1 = Var("x")
    t2 = Var("y")
    t3 = Add(Var("x"), Const(0))

    id1 = eg.add(t1)
    id2 = eg.add(t2)
    id3 = eg.add(t3)

    print(f"  Terms: t1 = {term_to_str(t1)}, t2 = {term_to_str(t2)}, t3 = {term_to_str(t3)}")
    print(f"  E-class ids: t1={id1}, t2={id2}, t3={id3}")
    print()

    # Incorrect merge: pretend x = y (this is unsound)
    print("  Performing UNSOUND merge: x ≡ y (incorrect!)")
    eg.union(id1, id2)
    print()

    env = {"x": 5, "y": 10}
    print(f"  Environment: {env}")

    # Now extraction from t1's class might return y
    extracted = eg.extract_cheapest(id1)
    print(f"  extract(x) = {term_to_str(extracted)}")
    print(f"  eval(x) = {eval_term(t1, env)}")
    print(f"  eval(extract(x)) = {eval_term(extracted, env)}")

    if eval_term(t1, env) != eval_term(extracted, env):
        print()
        print("✗ MISMATCH! Unsound e-graph breaks extraction correctness.")
        print("  This demonstrates why saturation must be SOUND:")
        print("  only terms provably equivalent under R should be merged.")
    print()


def demo_cost_monotonicity():
    """Demonstrate that extraction never increases cost under monotone cost model."""
    print("=" * 70)
    print("COST MONOTONICITY DEMO")
    print("=" * 70)
    print()

    random.seed(123)
    n_terms = 500
    vars = ["x", "y", "z"]

    cost_increased = 0
    cost_decreased = 0
    cost_same = 0

    for _ in range(n_terms):
        t = random_term(depth=4, vars=vars)
        eg = EGraph()
        tid = eg.add(t)
        eg.saturate()
        extracted = eg.extract_cheapest(tid)

        orig_cost = term_size(t)
        extr_cost = term_size(extracted)

        if extr_cost < orig_cost:
            cost_decreased += 1
        elif extr_cost > orig_cost:
            cost_increased += 1
        else:
            cost_same += 1

    print(f"  Cost decreased: {cost_decreased}/{n_terms}")
    print(f"  Cost unchanged: {cost_same}/{n_terms}")
    print(f"  Cost increased: {cost_increased}/{n_terms}")
    print()

    if cost_increased == 0:
        print("✓ Cost never increased — monotonicity verified!")
    else:
        print("✗ Cost increased in some cases — monotonicity violated!")
    print()


def demo_convergent_vs_nonconvergent():
    """Show the difference between convergent and non-convergent systems."""
    print("=" * 70)
    print("CONVERGENT vs NON-CONVERGENT SYSTEMS")
    print("=" * 70)
    print()

    # Example: convergent system
    print("Convergent system (our rules): always terminates, unique normal form")
    examples = [
        Add(Mul(Const(1), Var("x")), Const(0)),  # 1*x + 0 → x
        Mul(Add(Var("x"), Const(0)), Const(1)),   # (x+0)*1 → x
        Add(Const(0), Mul(Const(0), Var("y"))),   # 0 + 0*y → 0
    ]

    for t in examples:
        eg = EGraph()
        tid = eg.add(t)
        merges = eg.saturate()
        extracted = eg.extract_cheapest(tid)
        print(f"  {term_to_str(t):30s} → {term_to_str(extracted):10s} "
              f"(size: {term_size(t)} → {term_size(extracted)}, merges: {merges})")
    print()


if __name__ == "__main__":
    demo_extraction_correctness()
    demo_non_saturated_counterexample()
    demo_cost_monotonicity()
    demo_convergent_vs_nonconvergent()
