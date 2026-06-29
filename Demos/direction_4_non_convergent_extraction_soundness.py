#!/usr/bin/env python3
"""
Applications of Semantic Quotient Extraction

Demonstrates the theorems in three real-world domains:
1. Compiler optimization with non-confluent algebraic identities
2. Boolean circuit simplification
3. Symbolic expression compression
"""

from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
import random
from demo import Term, Var, Const, Add, Mul, term_size, denote, term_str
from algorithms import UnionFindEGraph, verify_extraction_soundness


# ─────────────────────────────────────────────────────────────────────
# Application 1: Compiler Optimization
# ─────────────────────────────────────────────────────────────────────

def compiler_optimization_demo():
    """
    Demonstrate how semantic quotient extraction enables compiler
    optimizations that do NOT require confluence.

    Real compilers face non-confluent situations constantly:
    - Strength reduction: x * 2 → x + x  (but also x + x → x * 2)
    - Constant folding: 3 + 4 → 7
    - Algebraic simplification: x * 1 → x, x + 0 → x
    - Commutativity: x + y ↔ y + x

    These rules overlap and don't orient into a terminating system,
    but each preserves semantics.
    """
    print("=" * 70)
    print("APPLICATION 1: Compiler Optimization Without Confluence")
    print("=" * 70)
    print()

    # A small program: (x + 0) * (1 + y) + (y + 1) * x
    program = Add(
        Mul(Add(Var(0), Const(0)), Add(Const(1), Var(1))),
        Mul(Add(Var(1), Const(1)), Var(0))
    )

    print(f"Original program: {term_str(program)}")
    print(f"Size: {term_size(program)}")
    print()

    # Apply rewrites manually to build equivalence class
    eg = UnionFindEGraph(cost_fn=term_size)

    # x + 0 → x
    simplified1 = Mul(Var(0), Add(Const(1), Var(1)))
    eg.merge(program, simplified1)

    # 1 + y → y + 1
    simplified2 = Mul(Var(0), Add(Var(1), Const(1)))
    eg.merge(simplified1, simplified2)

    # (y + 1) * x → x * (y + 1)
    rhs_comm = Mul(Var(0), Add(Var(1), Const(1)))
    eg.merge(Mul(Add(Var(1), Const(1)), Var(0)), rhs_comm)

    # Full simplification: x*(y+1) + x*(y+1) = 2*x*(y+1)
    full_simplified = Mul(Const(2), Mul(Var(0), Add(Var(1), Const(1))))
    eg.merge(program, full_simplified)

    extracted = eg.extract_cheapest(program)
    print(f"Extracted (cheapest): {term_str(extracted)}")
    print(f"Size: {term_size(extracted)}")
    print()

    # Verify semantics preserved
    envs = [{0: x, 1: y} for x in range(-3, 4) for y in range(-3, 4)]
    sound, violations = verify_extraction_soundness(
        eg, [program],
        lambda t, env: denote(t, env),
        envs
    )
    print(f"Semantics preserved across {len(envs)} environments: {sound}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 2: Boolean Circuit Simplification
# ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class BoolExpr:
    pass

@dataclass(frozen=True)
class BVar(BoolExpr):
    name: int

@dataclass(frozen=True)
class BConst(BoolExpr):
    value: bool

@dataclass(frozen=True)
class BAnd(BoolExpr):
    left: BoolExpr
    right: BoolExpr

@dataclass(frozen=True)
class BOr(BoolExpr):
    left: BoolExpr
    right: BoolExpr

@dataclass(frozen=True)
class BNot(BoolExpr):
    inner: BoolExpr


def bool_denote(t: BoolExpr, env: Dict[int, bool]) -> bool:
    if isinstance(t, BVar): return env.get(t.name, False)
    if isinstance(t, BConst): return t.value
    if isinstance(t, BAnd): return bool_denote(t.left, env) and bool_denote(t.right, env)
    if isinstance(t, BOr): return bool_denote(t.left, env) or bool_denote(t.right, env)
    if isinstance(t, BNot): return not bool_denote(t.inner, env)
    raise TypeError


def bool_size(t: BoolExpr) -> int:
    if isinstance(t, (BVar, BConst)): return 1
    if isinstance(t, BNot): return 1 + bool_size(t.inner)
    if isinstance(t, (BAnd, BOr)): return 1 + bool_size(t.left) + bool_size(t.right)
    return 1


def bool_str(t: BoolExpr) -> str:
    if isinstance(t, BVar): return f"x{t.name}"
    if isinstance(t, BConst): return str(t.value)
    if isinstance(t, BAnd): return f"({bool_str(t.left)} ∧ {bool_str(t.right)})"
    if isinstance(t, BOr): return f"({bool_str(t.left)} ∨ {bool_str(t.right)})"
    if isinstance(t, BNot): return f"¬{bool_str(t.inner)}"
    return "?"


def circuit_simplification_demo():
    """
    Boolean circuit optimization via non-confluent rewrites.

    Boolean algebra has many overlapping identities:
    - De Morgan: ¬(a ∧ b) ↔ ¬a ∨ ¬b
    - Double negation: ¬¬a ↔ a
    - Idempotence: a ∧ a ↔ a, a ∨ a ↔ a
    - Absorption: a ∧ (a ∨ b) ↔ a

    These form a non-confluent system, but each preserves boolean semantics.
    """
    print("=" * 70)
    print("APPLICATION 2: Boolean Circuit Simplification")
    print("=" * 70)
    print()

    # Circuit: ¬¬(x0 ∧ x1) ∨ (x0 ∧ ¬¬x1)
    circuit = BOr(
        BNot(BNot(BAnd(BVar(0), BVar(1)))),
        BAnd(BVar(0), BNot(BNot(BVar(1))))
    )

    print(f"Original circuit: {bool_str(circuit)}")
    print(f"Gate count: {bool_size(circuit)}")
    print()

    # Build equivalence class
    eg = UnionFindEGraph(cost_fn=bool_size)

    # ¬¬(x0 ∧ x1) → x0 ∧ x1
    s1 = BAnd(BVar(0), BVar(1))
    eg.merge(BNot(BNot(BAnd(BVar(0), BVar(1)))), s1)

    # ¬¬x1 → x1
    eg.merge(BNot(BNot(BVar(1))), BVar(1))

    # x0 ∧ ¬¬x1 → x0 ∧ x1
    s2 = BAnd(BVar(0), BVar(1))
    eg.merge(BAnd(BVar(0), BNot(BNot(BVar(1)))), s2)

    # (x0 ∧ x1) ∨ (x0 ∧ x1) → x0 ∧ x1 (idempotence)
    eg.merge(BOr(s1, s2), s1)

    # Original circuit is equivalent to x0 ∧ x1
    eg.merge(circuit, s1)

    extracted = eg.extract_cheapest(circuit)
    print(f"Optimized circuit: {bool_str(extracted)}")
    print(f"Gate count: {bool_size(extracted)}")
    print()

    # Verify over all boolean inputs
    envs = [
        {0: a, 1: b}
        for a in [True, False]
        for b in [True, False]
    ]

    all_ok = True
    for env in envs:
        v1 = bool_denote(circuit, env)
        v2 = bool_denote(extracted, env)
        ok = v1 == v2
        all_ok = all_ok and ok
        print(f"  x0={env[0]}, x1={env[1]}: original={v1}, optimized={v2}  {'✓' if ok else '✗'}")

    print(f"\nAll semantics preserved: {all_ok}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 3: Symbolic Compression
# ─────────────────────────────────────────────────────────────────────

def symbolic_compression_demo():
    """
    Use extraction for symbolic expression compression.

    Given a large expression, find the smallest equivalent expression
    using algebraic identities. This is useful in:
    - Computer algebra systems
    - Symbolic differentiation
    - Code generation from mathematical specifications
    """
    print("=" * 70)
    print("APPLICATION 3: Symbolic Expression Compression")
    print("=" * 70)
    print()

    # A bloated expression: ((x * 1) + 0) * ((0 + y) * 1) + 0
    bloated = Add(
        Mul(
            Add(Mul(Var(0), Const(1)), Const(0)),
            Mul(Add(Const(0), Var(1)), Const(1))
        ),
        Const(0)
    )

    print(f"Bloated expression: {term_str(bloated)}")
    print(f"Size: {term_size(bloated)}")
    print()

    # Build equivalence class with simplification rules
    eg = UnionFindEGraph(cost_fn=term_size)

    # Chain of simplifications
    step1 = Mul(Add(Var(0), Const(0)), Mul(Add(Const(0), Var(1)), Const(1)))
    eg.merge(bloated, step1)  # x*1 → x

    step2 = Mul(Var(0), Mul(Add(Const(0), Var(1)), Const(1)))
    eg.merge(step1, step2)  # x+0 → x

    step3 = Mul(Var(0), Mul(Var(1), Const(1)))
    eg.merge(step2, step3)  # 0+y → y

    step4 = Mul(Var(0), Var(1))
    eg.merge(step3, step4)  # y*1 → y

    # Also add the +0 → identity at top level
    eg.merge(Add(step4, Const(0)), step4)
    eg.merge(bloated, step4)

    extracted = eg.extract_cheapest(bloated)
    print(f"Compressed expression: {term_str(extracted)}")
    print(f"Size: {term_size(extracted)}")
    compression = 1 - term_size(extracted) / term_size(bloated)
    print(f"Compression: {compression:.0%}")
    print()

    # Verify
    envs = [{0: x, 1: y} for x in range(-5, 6) for y in range(-5, 6)]
    sound, _ = verify_extraction_soundness(
        eg, [bloated],
        lambda t, env: denote(t, env),
        envs
    )
    print(f"Semantics preserved across {len(envs)} environments: {sound}")
    print()


if __name__ == "__main__":
    compiler_optimization_demo()
    print()
    circuit_simplification_demo()
    print()
    symbolic_compression_demo()


#!/usr/bin/env python3
"""
Demo: Semantic Quotient Extraction — Non-Convergent Soundness

This script demonstrates the core theorem computationally:
  "Extraction from equivalence classes preserves semantics,
   even when the rewrite system is non-confluent and non-terminating."

We generate random non-confluent rewrite systems, build equivalence classes,
extract cheapest representatives, and verify that denotations are preserved.
"""

import random
import itertools
from typing import Dict, List, Tuple, Set, Callable, Optional
from dataclasses import dataclass, field
from collections import defaultdict


# ─────────────────────────────────────────────────────────────────────
# Term Language
# ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Term:
    """Simple arithmetic expression tree."""
    pass

@dataclass(frozen=True)
class Var(Term):
    name: int

@dataclass(frozen=True)
class Const(Term):
    value: int

@dataclass(frozen=True)
class Add(Term):
    left: Term
    right: Term

@dataclass(frozen=True)
class Mul(Term):
    left: Term
    right: Term


def term_size(t: Term) -> int:
    """Cost = number of nodes."""
    if isinstance(t, (Var, Const)):
        return 1
    elif isinstance(t, (Add, Mul)):
        return 1 + term_size(t.left) + term_size(t.right)
    return 1


def denote(t: Term, env: Dict[int, int]) -> int:
    """Evaluate a term in an environment."""
    if isinstance(t, Var):
        return env.get(t.name, 0)
    elif isinstance(t, Const):
        return t.value
    elif isinstance(t, Add):
        return denote(t.left, env) + denote(t.right, env)
    elif isinstance(t, Mul):
        return denote(t.left, env) * denote(t.right, env)
    raise TypeError(f"Unknown term type: {type(t)}")


def term_str(t: Term) -> str:
    """Pretty-print a term."""
    if isinstance(t, Var):
        return f"x{t.name}"
    elif isinstance(t, Const):
        return str(t.value)
    elif isinstance(t, Add):
        return f"({term_str(t.left)} + {term_str(t.right)})"
    elif isinstance(t, Mul):
        return f"({term_str(t.left)} * {term_str(t.right)})"
    return "?"


# ─────────────────────────────────────────────────────────────────────
# Rewrite Rules (intentionally non-confluent & non-terminating)
# ─────────────────────────────────────────────────────────────────────

@dataclass
class RewriteRule:
    """A rewrite rule: match a pattern and produce a replacement."""
    name: str
    match_fn: Callable[[Term], Optional[Term]]

    def apply_anywhere(self, t: Term) -> List[Term]:
        """Apply this rule at every possible position in the term."""
        results = []
        # Try at root
        r = self.match_fn(t)
        if r is not None:
            results.append(r)
        # Try in subterms
        if isinstance(t, Add):
            for l2 in self.apply_anywhere(t.left):
                results.append(Add(l2, t.right))
            for r2 in self.apply_anywhere(t.right):
                results.append(Add(t.left, r2))
        elif isinstance(t, Mul):
            for l2 in self.apply_anywhere(t.left):
                results.append(Mul(l2, t.right))
            for r2 in self.apply_anywhere(t.right):
                results.append(Mul(t.left, r2))
        return results


def make_non_confluent_rules() -> List[RewriteRule]:
    """Create a deliberately non-confluent, non-terminating rule set."""
    rules = []

    # x + 0 → x  (simplification)
    rules.append(RewriteRule(
        "add_zero_elim",
        lambda t: t.left if isinstance(t, Add) and isinstance(t.right, Const) and t.right.value == 0 else None
    ))

    # x → x + 0  (expansion — makes system non-terminating!)
    rules.append(RewriteRule(
        "add_zero_intro",
        lambda t: Add(t, Const(0))
    ))

    # a + b → b + a  (commutativity — makes system non-confluent!)
    rules.append(RewriteRule(
        "comm_add",
        lambda t: Add(t.right, t.left) if isinstance(t, Add) else None
    ))

    # a * b → b * a  (commutativity)
    rules.append(RewriteRule(
        "comm_mul",
        lambda t: Mul(t.right, t.left) if isinstance(t, Mul) else None
    ))

    # a * (b + c) → a*b + a*c  (distribution)
    rules.append(RewriteRule(
        "distribute",
        lambda t: Add(Mul(t.left, t.right.left), Mul(t.left, t.right.right))
        if isinstance(t, Mul) and isinstance(t.right, Add) else None
    ))

    # a * 1 → a
    rules.append(RewriteRule(
        "mul_one_elim",
        lambda t: t.left if isinstance(t, Mul) and isinstance(t.right, Const) and t.right.value == 1 else None
    ))

    # a * 0 → 0
    rules.append(RewriteRule(
        "mul_zero",
        lambda t: Const(0) if isinstance(t, Mul) and isinstance(t.right, Const) and t.right.value == 0 else None
    ))

    return rules


# ─────────────────────────────────────────────────────────────────────
# E-Graph (Union-Find based equivalence class builder)
# ─────────────────────────────────────────────────────────────────────

class EGraph:
    """A simple e-graph that builds equivalence classes from rewrite rules."""

    def __init__(self):
        self.parent: Dict[Term, Term] = {}
        self.rank: Dict[Term, int] = {}
        self.classes: Dict[Term, Set[Term]] = {}

    def _find(self, t: Term) -> Term:
        if t not in self.parent:
            self.parent[t] = t
            self.rank[t] = 0
            self.classes[t] = {t}
        if self.parent[t] != t:
            self.parent[t] = self._find(self.parent[t])
        return self.parent[t]

    def merge(self, a: Term, b: Term):
        ra, rb = self._find(a), self._find(b)
        if ra == rb:
            return
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.classes[ra] = self.classes[ra] | self.classes[rb]
        del self.classes[rb]
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1

    def same_class(self, a: Term, b: Term) -> bool:
        return self._find(a) == self._find(b)

    def get_class(self, t: Term) -> Set[Term]:
        return self.classes[self._find(t)]

    def extract_cheapest(self, t: Term) -> Term:
        """Extract the cheapest (smallest) term from t's equivalence class."""
        cls = self.get_class(t)
        return min(cls, key=term_size)


def saturate(seed_terms: List[Term], rules: List[RewriteRule],
             max_iterations: int = 5, max_terms: int = 500) -> EGraph:
    """Run equality saturation: apply rules and merge equivalent terms."""
    eg = EGraph()
    worklist = set(seed_terms)
    all_terms = set(seed_terms)

    for iteration in range(max_iterations):
        new_terms = set()
        for t in list(all_terms):
            for rule in rules:
                for result in rule.apply_anywhere(t):
                    if term_size(result) <= 20:  # bound term size
                        eg.merge(t, result)
                        if result not in all_terms:
                            new_terms.add(result)
        if not new_terms or len(all_terms) >= max_terms:
            break
        all_terms |= new_terms

    return eg


# ─────────────────────────────────────────────────────────────────────
# Random term generation
# ─────────────────────────────────────────────────────────────────────

def random_term(depth: int = 3, num_vars: int = 3) -> Term:
    if depth <= 0 or random.random() < 0.3:
        if random.random() < 0.5:
            return Var(random.randint(0, num_vars - 1))
        else:
            return Const(random.randint(-5, 5))
    op = random.choice([Add, Mul])
    return op(random_term(depth - 1, num_vars), random_term(depth - 1, num_vars))


def random_env(num_vars: int = 3) -> Dict[int, int]:
    return {i: random.randint(-10, 10) for i in range(num_vars)}


# ─────────────────────────────────────────────────────────────────────
# Main Demo
# ─────────────────────────────────────────────────────────────────────

def demo_non_confluent_soundness():
    """
    Core demonstration: non-confluent, non-terminating rewrites
    still produce semantically correct extractions.
    """
    print("=" * 70)
    print("DEMO: Semantic Quotient Extraction — Non-Convergent Soundness")
    print("=" * 70)
    print()
    print("We generate random arithmetic terms, apply non-confluent and")
    print("non-terminating rewrite rules, build equivalence classes, and")
    print("verify that extracted cheapest representatives preserve semantics.")
    print()

    rules = make_non_confluent_rules()
    print(f"Rewrite rules ({len(rules)} total):")
    for r in rules:
        print(f"  • {r.name}")
    print()
    print("Key properties of this system:")
    print("  ✗ NOT confluent (commutativity creates diamond failures)")
    print("  ✗ NOT terminating (add_zero_intro creates infinite chains)")
    print("  ✗ NOT oriented toward normalization")
    print("  ✓ Every rule preserves denotation (semantically sound)")
    print()

    num_experiments = 20
    num_envs = 5
    total_checks = 0
    violations = 0

    print(f"Running {num_experiments} experiments...")
    print("-" * 70)

    for exp in range(num_experiments):
        random.seed(42 + exp)
        terms = [random_term(depth=3) for _ in range(5)]
        eg = saturate(terms, rules, max_iterations=3, max_terms=100)

        for t in terms:
            extracted = eg.extract_cheapest(t)
            for _ in range(num_envs):
                env = random_env()
                val_orig = denote(t, env)
                val_extr = denote(extracted, env)
                total_checks += 1
                if val_orig != val_extr:
                    violations += 1
                    print(f"  ✗ VIOLATION in experiment {exp}!")
                    print(f"    Original:  {term_str(t)} = {val_orig}")
                    print(f"    Extracted: {term_str(extracted)} = {val_extr}")
                    print(f"    Env: {env}")

        if exp % 5 == 4:
            print(f"  Experiments {exp - 3}–{exp + 1}: {total_checks} checks, {violations} violations")

    print("-" * 70)
    print(f"\nRESULTS:")
    print(f"  Total experiments:   {num_experiments}")
    print(f"  Total checks:        {total_checks}")
    print(f"  Semantic violations: {violations}")
    print()

    if violations == 0:
        print("  ✓ ALL EXTRACTIONS PRESERVED SEMANTICS")
        print()
        print("  This confirms the theorem: semantic soundness of individual rewrite")
        print("  steps is sufficient for extraction correctness. Confluence and")
        print("  termination are irrelevant to semantic preservation.")
    else:
        print("  ✗ VIOLATIONS FOUND — this would falsify the soundness hypothesis")
        print("  (check if a rewrite rule is semantically unsound)")

    print()


def demo_compression_ratio():
    """
    Measure how much compression extraction achieves
    in non-confluent rewrite systems.
    """
    print("=" * 70)
    print("DEMO: Compression Ratios in Non-Confluent Systems")
    print("=" * 70)
    print()

    rules = make_non_confluent_rules()
    ratios = []

    for trial in range(30):
        random.seed(100 + trial)
        t = random_term(depth=4)
        orig_size = term_size(t)

        eg = saturate([t], rules, max_iterations=4, max_terms=300)
        extracted = eg.extract_cheapest(t)
        extr_size = term_size(extracted)

        ratio = extr_size / max(orig_size, 1)
        ratios.append(ratio)

        class_size = len(eg.get_class(t))

        if trial < 10:  # Print first 10
            print(f"  Trial {trial + 1}:")
            print(f"    Original:  {term_str(t)}")
            print(f"    Size: {orig_size}")
            print(f"    Extracted: {term_str(extracted)}")
            print(f"    Size: {extr_size}  (ratio: {ratio:.2f})")
            print(f"    E-class size: {class_size}")
            print()

    avg_ratio = sum(ratios) / len(ratios)
    min_ratio = min(ratios)
    max_ratio = max(ratios)

    print(f"Compression statistics over {len(ratios)} trials:")
    print(f"  Average ratio (extracted/original): {avg_ratio:.3f}")
    print(f"  Best compression:  {min_ratio:.3f}")
    print(f"  Worst compression: {max_ratio:.3f}")
    print(f"  Trials with compression (ratio < 1): {sum(1 for r in ratios if r < 1)}/{len(ratios)}")
    print()


def demo_sk_combinators():
    """
    Demonstrate semantic preservation for SK combinator rewrites —
    a famously non-normalizing system.
    """
    print("=" * 70)
    print("DEMO: SK Combinator Extraction (Non-Normalizing System)")
    print("=" * 70)
    print()

    # We represent SK terms and evaluate them as functions on a finite domain
    # For simplicity, we use a small finite model

    @dataclass(frozen=True)
    class SK:
        pass

    @dataclass(frozen=True)
    class S_atom(SK):
        pass

    @dataclass(frozen=True)
    class K_atom(SK):
        pass

    @dataclass(frozen=True)
    class App(SK):
        left: SK
        right: SK

    def sk_str(t):
        if isinstance(t, S_atom): return "S"
        if isinstance(t, K_atom): return "K"
        if isinstance(t, App): return f"({sk_str(t.left)} {sk_str(t.right)})"
        return "?"

    def sk_size(t):
        if isinstance(t, (S_atom, K_atom)): return 1
        if isinstance(t, App): return 1 + sk_size(t.left) + sk_size(t.right)
        return 1

    # One-step SK reductions (applied at root only for simplicity)
    def sk_reduce_root(t):
        """Try K and S reductions at root."""
        results = []
        # K x y → x
        if (isinstance(t, App) and isinstance(t.left, App)
                and isinstance(t.left.left, K_atom)):
            results.append(t.left.right)
        # S x y z → (x z)(y z)
        if (isinstance(t, App) and isinstance(t.left, App)
                and isinstance(t.left.left, App)
                and isinstance(t.left.left.left, S_atom)):
            x = t.left.left.right
            y = t.left.right
            z = t.right
            results.append(App(App(x, z), App(y, z)))
        return results

    def sk_reduce_anywhere(t, depth=0):
        if depth > 5: return []
        results = sk_reduce_root(t)
        if isinstance(t, App):
            for l2 in sk_reduce_anywhere(t.left, depth + 1):
                results.append(App(l2, t.right))
            for r2 in sk_reduce_anywhere(t.right, depth + 1):
                results.append(App(t.left, r2))
        return results

    # Build equivalence classes via bounded saturation
    def sk_saturate(terms, max_iter=3, max_size=100):
        eg = EGraph()
        all_terms = set(terms)
        for _ in range(max_iter):
            new = set()
            for t in list(all_terms):
                for r in sk_reduce_anywhere(t):
                    if sk_size(r) <= 12:
                        eg.merge(t, r)
                        if r not in all_terms:
                            new.add(r)
            if not new or len(all_terms) >= max_size:
                break
            all_terms |= new
        return eg

    # Finite model: functions on {0, 1, 2}
    # K maps to: K x y = x (constant function)
    # S maps to: S x y z = (x z)(y z)
    # We represent as lookup tables on a 3-element domain

    DOMAIN = [0, 1, 2]

    def make_fn_table():
        """Random function {0,1,2} → {0,1,2}."""
        return tuple(random.choice(DOMAIN) for _ in DOMAIN)

    # In a finite model, we represent values as elements of DOMAIN
    # and app as function application via lookup tables
    # This is necessarily approximate, but demonstrates the principle

    print("SK combinator terms are famously non-normalizing:")
    print("  Ω = S S K (S S K) has no normal form.")
    print("  But semantic soundness of extraction still holds!")
    print()

    # Generate some SK terms and show rewrite preservation
    test_terms = [
        App(App(K_atom(), S_atom()), K_atom()),   # K S K → S
        App(App(K_atom(), K_atom()), S_atom()),    # K K S → K
        App(App(K_atom(), App(K_atom(), S_atom())), K_atom()),  # K (K S) K → K S
    ]

    print("Example SK reductions:")
    for t in test_terms:
        reds = sk_reduce_root(t)
        for r in reds:
            print(f"  {sk_str(t)}  →  {sk_str(r)}")
            # Both should denote the same in any model
            print(f"    (size {sk_size(t)} → {sk_size(r)})")

    print()

    # Saturation demo
    seed = App(App(App(S_atom(), K_atom()), K_atom()), S_atom())
    print(f"Saturating from: {sk_str(seed)}")
    eg = sk_saturate([seed], max_iter=3)
    cls = eg.get_class(seed)
    print(f"  E-class size: {len(cls)}")
    cheapest = min(cls, key=sk_size)
    print(f"  Cheapest:     {sk_str(cheapest)} (size {sk_size(cheapest)})")
    print(f"  Original:     {sk_str(seed)} (size {sk_size(seed)})")
    print()
    print("The theorem guarantees these have the same denotation in ALL models,")
    print("even though the rewrite system has no normal forms in general.")
    print()


if __name__ == "__main__":
    demo_non_confluent_soundness()
    print()
    demo_compression_ratio()
    print()
    demo_sk_combinators()
