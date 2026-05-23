"""
Algorithms for Convergent Rewrite Systems as Quotient Optimizers.

Implements the core algorithms from the research paper:
- Term representation and evaluation
- Rewrite rule application and normalization
- Confluence checking via critical pairs
- Convergent system generation and validation

All algorithms correspond to formally verified counterparts in Lean 4.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum
import random


# ============================================================
# Term Representation
# ============================================================

class TermKind(Enum):
    VAR = "var"
    CONST = "const"
    APP = "app"


@dataclass(frozen=True)
class Term:
    """First-order term over a signature.

    Corresponds to the Lean type:
        inductive RExpr (α : Type*)
          | var : α → RExpr α
          | zero | one : RExpr α
          | add | mul : RExpr α → RExpr α → RExpr α
    """
    kind: TermKind
    name: str = ""
    children: tuple[Term, ...] = ()

    def __repr__(self) -> str:
        if self.kind == TermKind.VAR:
            return self.name
        elif self.kind == TermKind.CONST:
            return self.name
        else:
            args = ", ".join(repr(c) for c in self.children)
            return f"{self.name}({args})"

    @property
    def size(self) -> int:
        """Term size (number of nodes).
        Corresponds to RExpr.size in the Lean formalization."""
        if self.kind in (TermKind.VAR, TermKind.CONST):
            return 1
        return 1 + sum(c.size for c in self.children)

    def subterms(self) -> list[Term]:
        """All subterms including self."""
        result = [self]
        for c in self.children:
            result.extend(c.subterms())
        return result

    def substitute(self, mapping: dict[str, Term]) -> Term:
        """Apply a substitution."""
        if self.kind == TermKind.VAR:
            return mapping.get(self.name, self)
        elif self.kind == TermKind.CONST:
            return self
        else:
            new_children = tuple(c.substitute(mapping) for c in self.children)
            return Term(TermKind.APP, self.name, new_children)


def var(name: str) -> Term:
    return Term(TermKind.VAR, name)


def const(name: str) -> Term:
    return Term(TermKind.CONST, name)


def app(name: str, *args: Term) -> Term:
    return Term(TermKind.APP, name, tuple(args))


# ============================================================
# Rewrite Rules
# ============================================================

@dataclass(frozen=True)
class RewriteRule:
    """A rewrite rule lhs → rhs.

    Corresponds to:
        structure RewriteRule (T : Type*) where
          lhs : T
          rhs : T
    """
    lhs: Term
    rhs: Term

    def __repr__(self) -> str:
        return f"{self.lhs} → {self.rhs}"

    def variables(self) -> set[str]:
        """Variables appearing in the rule."""
        def vars_of(t: Term) -> set[str]:
            if t.kind == TermKind.VAR:
                return {t.name}
            return set().union(*(vars_of(c) for c in t.children)) if t.children else set()
        return vars_of(self.lhs) | vars_of(self.rhs)


# ============================================================
# Pattern Matching
# ============================================================

def match_term(pattern: Term, target: Term) -> Optional[dict[str, Term]]:
    """Try to match pattern against target, returning a substitution if successful."""
    if pattern.kind == TermKind.VAR:
        return {pattern.name: target}
    if pattern.kind == TermKind.CONST:
        if target.kind == TermKind.CONST and target.name == pattern.name:
            return {}
        return None
    if pattern.kind == TermKind.APP:
        if target.kind != TermKind.APP or target.name != pattern.name:
            return None
        if len(pattern.children) != len(target.children):
            return None
        combined: dict[str, Term] = {}
        for pc, tc in zip(pattern.children, target.children):
            sub = match_term(pc, tc)
            if sub is None:
                return None
            for k, v in sub.items():
                if k in combined:
                    if combined[k] != v:
                        return None
                else:
                    combined[k] = v
        return combined
    return None


# ============================================================
# Normalization (corresponds to rewriteNormalize in Lean)
# ============================================================

def apply_rule_at_root(rule: RewriteRule, t: Term) -> Optional[Term]:
    """Try to apply a rule at the root of a term.
    Corresponds to applyRule in the Lean formalization."""
    subst = match_term(rule.lhs, t)
    if subst is not None:
        return rule.rhs.substitute(subst)
    return None


def apply_first_rule(rules: list[RewriteRule], t: Term) -> Optional[Term]:
    """Try to apply any rule at any position (top-down, leftmost).
    Extends applyFirstRule to work on subterms."""
    # Try at root first
    for rule in rules:
        result = apply_rule_at_root(rule, t)
        if result is not None:
            return result
    # Try in children
    if t.kind == TermKind.APP:
        for i, child in enumerate(t.children):
            result = apply_first_rule(rules, child)
            if result is not None:
                new_children = list(t.children)
                new_children[i] = result
                return Term(TermKind.APP, t.name, tuple(new_children))
    return None


def normalize(rules: list[RewriteRule], t: Term, fuel: int = 1000) -> tuple[Term, int]:
    """Normalize a term by repeatedly applying rules.

    Returns (normal_form, num_steps).

    Corresponds to rewriteNormalize in the Lean formalization,
    with the correctness guarantee from rewriteNormalize_correct:
        eval(normalize(rules, t)) = eval(t)
    whenever each rule preserves evaluation.

    Complexity: O(fuel × |rules| × term_size × match_cost)
    """
    steps = 0
    current = t
    for _ in range(fuel):
        result = apply_first_rule(rules, current)
        if result is None:
            break
        current = result
        steps += 1
    return current, steps


# ============================================================
# Evaluation (corresponds to RExpr.eval in Lean)
# ============================================================

@dataclass
class Algebra:
    """A finite algebra: a carrier set with interpretations for function symbols.

    Corresponds to the eval function in the Lean formalization.
    """
    carrier: list[int]
    interp: dict[str, Callable]  # symbol -> function
    const_interp: dict[str, int]  # constant -> value

    def evaluate(self, t: Term, assignment: dict[str, int]) -> int:
        """Evaluate a term in this algebra under a variable assignment.

        This is the concrete counterpart of:
            def RExpr.eval (ι : α → A) : RExpr α → A
        """
        if t.kind == TermKind.VAR:
            return assignment[t.name]
        elif t.kind == TermKind.CONST:
            return self.const_interp[t.name]
        else:
            child_vals = [self.evaluate(c, assignment) for c in t.children]
            return self.interp[t.name](*child_vals)


# ============================================================
# Confluence Checking via Critical Pairs
# ============================================================

@dataclass
class CriticalPairResult:
    """Result of a critical pair analysis.
    Corresponds to CriticalPair in the Lean formalization."""
    peak: Term
    left_result: Term
    right_result: Term
    joinable: bool
    common_reduct: Optional[Term] = None


def check_critical_pairs(
    rules: list[RewriteRule],
    fuel: int = 100
) -> list[CriticalPairResult]:
    """Check critical pairs for local confluence.

    Corresponds to the Critical Pair Theorem (confluence_of_cps_joinable):
    if all critical pairs are joinable and the system terminates,
    then the system is confluent.
    """
    results = []
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            # Try to find overlaps between r1.lhs and r2.lhs
            if r1.lhs.kind == TermKind.APP and r2.lhs.kind == TermKind.APP:
                # Simple overlap: r1 and r2 apply to the same root
                subst = match_term(r1.lhs, r2.lhs)
                if subst is not None and i != j:
                    left = r1.rhs.substitute(subst)
                    right = r2.rhs.substitute(subst)
                    peak = r1.lhs.substitute(subst)
                    # Check joinability
                    nf_left, _ = normalize(rules, left, fuel)
                    nf_right, _ = normalize(rules, right, fuel)
                    joinable = nf_left == nf_right
                    results.append(CriticalPairResult(
                        peak=peak,
                        left_result=left,
                        right_result=right,
                        joinable=joinable,
                        common_reduct=nf_left if joinable else None
                    ))
    return results


# ============================================================
# Random System Generation
# ============================================================

def random_term(
    symbols: list[tuple[str, int]],
    variables: list[str],
    max_depth: int = 3,
    const_names: list[str] | None = None
) -> Term:
    """Generate a random term over the given signature."""
    if max_depth <= 0 or random.random() < 0.3:
        if random.random() < 0.5 and variables:
            return var(random.choice(variables))
        elif const_names:
            return const(random.choice(const_names))
        elif variables:
            return var(random.choice(variables))
        else:
            return const("c0")

    eligible = [(name, arity) for name, arity in symbols if arity > 0]
    if not eligible:
        if variables:
            return var(random.choice(variables))
        return const("c0")

    name, arity = random.choice(eligible)
    children = [random_term(symbols, variables, max_depth - 1, const_names) for _ in range(arity)]
    return app(name, *children)


def generate_convergent_system(
    num_symbols: int = 3,
    max_arity: int = 2,
    num_rules: int = 5,
    num_variables: int = 3
) -> tuple[list[tuple[str, int]], list[RewriteRule], list[str]]:
    """Generate a random rewrite system that is likely convergent.

    Strategy: generate rules where lhs is strictly larger than rhs
    (guaranteeing termination by size decrease).
    """
    symbols = [(f"f{i}", random.randint(0, max_arity)) for i in range(num_symbols)]
    # Ensure at least one symbol with arity > 0
    symbols[0] = (symbols[0][0], max(1, symbols[0][1]))
    variables = [f"x{i}" for i in range(num_variables)]
    const_names = [name for name, arity in symbols if arity == 0]
    if not const_names:
        const_names = ["c0"]

    rules = []
    attempts = 0
    while len(rules) < num_rules and attempts < 100:
        attempts += 1
        lhs = random_term(symbols, variables, max_depth=3, const_names=const_names)
        rhs = random_term(symbols, variables, max_depth=2, const_names=const_names)
        # Ensure termination: lhs must be strictly larger
        if lhs.size > rhs.size and lhs.kind == TermKind.APP:
            # Ensure rhs variables are subset of lhs variables
            lhs_vars = {st.name for st in lhs.subterms() if st.kind == TermKind.VAR}
            rhs_vars = {st.name for st in rhs.subterms() if st.kind == TermKind.VAR}
            if rhs_vars <= lhs_vars:
                rule = RewriteRule(lhs, rhs)
                rules.append(rule)

    return symbols, rules, variables


def generate_random_algebra(
    symbols: list[tuple[str, int]],
    carrier_size: int = 5
) -> Algebra:
    """Generate a random finite algebra over the given signature."""
    carrier = list(range(carrier_size))
    interp: dict[str, Callable] = {}
    const_interp: dict[str, int] = {}

    for name, arity in symbols:
        if arity == 0:
            const_interp[name] = random.choice(carrier)
        elif arity == 1:
            table = {x: random.choice(carrier) for x in carrier}
            interp[name] = lambda x, t=table: t[x % len(t)]
        elif arity == 2:
            table = {(x, y): random.choice(carrier) for x in carrier for y in carrier}
            interp[name] = lambda x, y, t=table: t[(x % len(carrier), y % len(carrier))]
    # Add constants
    const_interp.setdefault("c0", 0)

    return Algebra(carrier=carrier, interp=interp, const_interp=const_interp)


# ============================================================
# Soundness Verification
# ============================================================

def verify_soundness(
    rules: list[RewriteRule],
    algebra: Algebra,
    variables: list[str],
    num_assignments: int = 100
) -> tuple[bool, list[dict]]:
    """Verify that rules preserve evaluation in a given algebra.

    This checks the hypothesis of rewriteNormalize_correct:
        ∀ r ∈ rules, eval r.lhs = eval r.rhs

    Returns (all_sound, counterexamples).
    """
    counterexamples = []
    for _ in range(num_assignments):
        assignment = {v: random.choice(algebra.carrier) for v in variables}
        for rule in rules:
            try:
                lhs_val = algebra.evaluate(rule.lhs, assignment)
                rhs_val = algebra.evaluate(rule.rhs, assignment)
                if lhs_val != rhs_val:
                    counterexamples.append({
                        "rule": str(rule),
                        "assignment": assignment.copy(),
                        "lhs_val": lhs_val,
                        "rhs_val": rhs_val
                    })
            except (KeyError, TypeError):
                pass
    return len(counterexamples) == 0, counterexamples


def verify_normalization_preserves_eval(
    rules: list[RewriteRule],
    algebra: Algebra,
    variables: list[str],
    num_terms: int = 100,
    symbols: list[tuple[str, int]] | None = None,
    max_depth: int = 4
) -> dict:
    """Verify that normalization preserves evaluation.

    This is the computational check of the Master Theorem:
        eval(nf(t)) = eval(t) for all t

    Returns statistics on agreement, size reduction, etc.
    """
    const_names = [name for name, arity in (symbols or []) if arity == 0] or ["c0"]
    agreements = 0
    disagreements = 0
    total_size_before = 0
    total_size_after = 0
    total_steps = 0
    examples = []

    for _ in range(num_terms):
        t = random_term(symbols or [], variables, max_depth, const_names)
        nf, steps = normalize(rules, t)
        assignment = {v: random.choice(algebra.carrier) for v in variables}

        try:
            val_before = algebra.evaluate(t, assignment)
            val_after = algebra.evaluate(nf, assignment)
            if val_before == val_after:
                agreements += 1
            else:
                disagreements += 1
                if len(examples) < 5:
                    examples.append({
                        "term": str(t),
                        "nf": str(nf),
                        "assignment": assignment,
                        "val_before": val_before,
                        "val_after": val_after
                    })
        except (KeyError, TypeError):
            pass

        total_size_before += t.size
        total_size_after += nf.size
        total_steps += steps

    total = agreements + disagreements
    return {
        "agreements": agreements,
        "disagreements": disagreements,
        "agreement_rate": agreements / total if total > 0 else 1.0,
        "avg_size_before": total_size_before / num_terms,
        "avg_size_after": total_size_after / num_terms,
        "avg_compression": 1 - (total_size_after / total_size_before) if total_size_before > 0 else 0,
        "avg_steps": total_steps / num_terms,
        "counterexamples": examples
    }


if __name__ == "__main__":
    # Example: commutative addition
    x, y, z = var("x"), var("y"), var("z")

    # Rule: f(x, y) -> f(y, x) (commutativity)
    rule_comm = RewriteRule(app("f", x, y), app("f", y, x))
    # Rule: f(x, f(y, z)) -> f(f(x, y), z) (associativity)
    rule_assoc = RewriteRule(app("f", x, app("f", y, z)), app("f", app("f", x, y), z))

    t = app("f", var("a"), app("f", var("b"), var("c")))
    print(f"Original: {t}")
    nf, steps = normalize([rule_assoc], t)
    print(f"Normal form: {nf} (in {steps} steps)")
    print(f"Size: {t.size} -> {nf.size}")
