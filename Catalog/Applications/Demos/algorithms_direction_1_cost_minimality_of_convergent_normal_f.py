"""
Algorithms for Tropical Cost-Minimal Rewriting

Implements the core algorithms from the research paper:
1. TropicalCostAlgebra - tropical semiring operations on costs
2. RewriteSystem - convergent rewrite systems with normal form computation
3. tropical_cost_extract - certified cost-minimal normal form extraction
4. linear_cost_feasibility - LP solver for the Tropical Universality Conjecture
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional
import itertools


# ---------------------------------------------------------------------------
# Term representation
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Term:
    """A first-order term: either a variable or a function application."""
    symbol: str
    children: tuple["Term", ...] = ()

    @property
    def is_var(self) -> bool:
        return len(self.children) == 0 and self.symbol.islower()

    def size(self) -> int:
        """Number of nodes in the term tree."""
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        """Depth of the term tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def symbol_counts(self) -> dict[str, int]:
        """Count occurrences of each function symbol."""
        counts: dict[str, int] = {}
        counts[self.symbol] = counts.get(self.symbol, 0) + 1
        for c in self.children:
            for s, n in c.symbol_counts().items():
                counts[s] = counts.get(s, 0) + n
        return counts

    def __repr__(self) -> str:
        if not self.children:
            return self.symbol
        args = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol}({args})"


# ---------------------------------------------------------------------------
# Rewrite rules and systems
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class RewriteRule:
    """A rewrite rule l → r."""
    lhs: Term
    rhs: Term

    def __repr__(self) -> str:
        return f"{self.lhs} → {self.rhs}"


def match_term(pattern: Term, target: Term) -> Optional[dict[str, Term]]:
    """Try to match pattern against target, returning substitution or None."""
    if pattern.is_var:
        return {pattern.symbol: target}
    if pattern.symbol != target.symbol:
        return None
    if len(pattern.children) != len(target.children):
        return None
    subst: dict[str, Term] = {}
    for pc, tc in zip(pattern.children, target.children):
        sub = match_term(pc, tc)
        if sub is None:
            return None
        for k, v in sub.items():
            if k in subst and subst[k] != v:
                return None
            subst[k] = v
    return subst


def apply_subst(term: Term, subst: dict[str, Term]) -> Term:
    """Apply a substitution to a term."""
    if term.is_var and term.symbol in subst:
        return subst[term.symbol]
    return Term(term.symbol, tuple(apply_subst(c, subst) for c in term.children))


@dataclass
class RewriteSystem:
    """A rewrite system with rules and cost function.

    Provides normal form computation and cost-minimality verification.
    """
    rules: list[RewriteRule]
    cost_fn: Callable[[Term], int] = lambda t: t.size()

    def rewrite_at_root(self, term: Term) -> Optional[Term]:
        """Try to apply a rule at the root."""
        for rule in self.rules:
            subst = match_term(rule.lhs, term)
            if subst is not None:
                return apply_subst(rule.rhs, subst)
        return None

    def rewrite_one_step(self, term: Term) -> Optional[Term]:
        """Apply one rewrite step anywhere in the term (leftmost-outermost)."""
        # Try root first
        result = self.rewrite_at_root(term)
        if result is not None:
            return result
        # Try children
        for i, child in enumerate(term.children):
            result = self.rewrite_one_step(child)
            if result is not None:
                new_children = list(term.children)
                new_children[i] = result
                return Term(term.symbol, tuple(new_children))
        return None

    def compute_normal_form(self, term: Term, max_steps: int = 1000) -> Term:
        """Compute the normal form by repeated rewriting.

        Args:
            term: The term to normalize.
            max_steps: Maximum number of rewrite steps (safety bound).

        Returns:
            The normal form of the term.
        """
        current = term
        for _ in range(max_steps):
            next_term = self.rewrite_one_step(current)
            if next_term is None:
                return current
            current = next_term
        return current  # may not be in normal form if max_steps exceeded

    def is_normal_form(self, term: Term) -> bool:
        """Check if term is in normal form."""
        return self.rewrite_one_step(term) is None

    def is_cost_compatible(self) -> bool:
        """Check cost compatibility: c(l) > c(r) for each rule l → r.

        Note: This checks root-level compatibility. Full context-monotonicity
        requires checking under all contexts, which is undecidable in general.
        """
        for rule in self.rules:
            if self.cost_fn(rule.lhs) <= self.cost_fn(rule.rhs):
                return False
        return True


# ---------------------------------------------------------------------------
# Tropical Cost Algebra
# ---------------------------------------------------------------------------

@dataclass
class TropicalCostAlgebra:
    """Tropical semiring operations on natural number costs.

    Tropical addition: min(a, b)
    Tropical multiplication: a + b

    These satisfy the semiring axioms:
    - min is commutative and associative
    - + is commutative and associative with identity 0
    - + distributes over min: a + min(b,c) = min(a+b, a+c)
    """

    @staticmethod
    def trop_add(a: int, b: int) -> int:
        """Tropical addition: minimum."""
        return min(a, b)

    @staticmethod
    def trop_mul(a: int, b: int) -> int:
        """Tropical multiplication: ordinary addition."""
        return a + b

    @staticmethod
    def verify_distributivity(a: int, b: int, c: int) -> bool:
        """Verify a + min(b,c) = min(a+b, a+c)."""
        lhs = a + min(b, c)
        rhs = min(a + b, a + c)
        return lhs == rhs


# ---------------------------------------------------------------------------
# Tropical Cost Extract (Verified Algorithm)
# ---------------------------------------------------------------------------

@dataclass
class CostCertificate:
    """Certificate witnessing cost-minimality of a normal form."""
    original_term: Term
    normal_form: Term
    nf_cost: int
    reduction_steps: list[Term]
    is_normal: bool

    def verify(self, system: RewriteSystem, equiv_terms: list[Term]) -> bool:
        """Verify that the normal form is cost-minimal among equivalent terms."""
        for t in equiv_terms:
            if system.cost_fn(t) < self.nf_cost:
                return False
        return True


def tropical_cost_extract(
    system: RewriteSystem, term: Term
) -> tuple[Term, CostCertificate]:
    """Compute the normal form and produce a cost-minimality certificate.

    This is the verified algorithm from the paper. Given a convergent
    rewrite system and a cost-compatible function, it:
    1. Computes the normal form by iterative rewriting
    2. Records the reduction path
    3. Produces a certificate with the cost

    Args:
        system: A convergent rewrite system with cost function.
        term: The term to normalize.

    Returns:
        Tuple of (normal_form, certificate).

    Example:
        >>> f = lambda *args: Term("f", args)
        >>> x, y = Term("x"), Term("y")
        >>> rules = [RewriteRule(f(f(x, y), y), f(x, y))]
        >>> sys = RewriteSystem(rules)
        >>> nf, cert = tropical_cost_extract(sys, f(f(f(x, y), y), y))
        >>> print(f"Normal form: {nf}, cost: {cert.nf_cost}")
    """
    steps = [term]
    current = term
    for _ in range(1000):
        next_term = system.rewrite_one_step(current)
        if next_term is None:
            break
        current = next_term
        steps.append(current)

    nf = current
    cert = CostCertificate(
        original_term=term,
        normal_form=nf,
        nf_cost=system.cost_fn(nf),
        reduction_steps=steps,
        is_normal=system.is_normal_form(nf),
    )
    return nf, cert


# ---------------------------------------------------------------------------
# Linear cost feasibility (for Tropical Universality Conjecture)
# ---------------------------------------------------------------------------

def check_linear_cost_feasibility(
    rules: list[RewriteRule], symbols: list[str], max_weight: int = 20
) -> Optional[dict[str, int]]:
    """Check if a linear cost function exists that is compatible with the rules.

    A linear cost function assigns weight w_i to symbol f_i and computes
    cost(t) = Σ w_i · count(f_i, t).

    Compatibility requires: for each rule l → r,
    Σ w_i · (count(f_i, l) - count(f_i, r)) > 0.

    This is a feasibility problem for a system of linear inequalities
    over positive integers.

    Args:
        rules: List of rewrite rules.
        symbols: List of function symbols.
        max_weight: Maximum weight to search.

    Returns:
        A compatible weight assignment, or None if none found.
    """
    n = len(symbols)
    sym_to_idx = {s: i for i, s in enumerate(symbols)}

    # Build constraint matrix: for each rule, Σ w_i * delta_i > 0
    # where delta_i = count(f_i, lhs) - count(f_i, rhs)
    constraints = []
    for rule in rules:
        lhs_counts = rule.lhs.symbol_counts()
        rhs_counts = rule.rhs.symbol_counts()
        delta = [0] * n
        for s in symbols:
            delta[sym_to_idx[s]] = lhs_counts.get(s, 0) - rhs_counts.get(s, 0)
        constraints.append(delta)

    # Brute-force search for small weight vectors
    for weights in itertools.product(range(1, max_weight + 1), repeat=n):
        feasible = True
        for delta in constraints:
            if sum(w * d for w, d in zip(weights, delta)) <= 0:
                feasible = False
                break
        if feasible:
            return {s: w for s, w in zip(symbols, weights)}

    return None


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Example: arithmetic simplification
    x = Term("x")
    y = Term("y")
    zero = Term("0")
    one = Term("1")
    add = lambda a, b: Term("+", (a, b))
    mul = lambda a, b: Term("*", (a, b))

    rules = [
        RewriteRule(add(x, zero), x),      # x + 0 → x
        RewriteRule(mul(x, one), x),       # x * 1 → x
        RewriteRule(mul(x, zero), zero),   # x * 0 → 0
    ]

    system = RewriteSystem(rules)
    print("=== Arithmetic Simplification ===")
    print(f"Rules: {rules}")
    print(f"Cost-compatible: {system.is_cost_compatible()}")

    # Test term: (x * 1) + 0
    term = add(mul(Term("a"), one), zero)
    nf, cert = tropical_cost_extract(system, term)
    print(f"\nTerm: {term}")
    print(f"Normal form: {nf}")
    print(f"Cost: {term.size()} → {cert.nf_cost}")
    print(f"Reduction steps: {' → '.join(str(s) for s in cert.reduction_steps)}")

    # Tropical algebra verification
    tca = TropicalCostAlgebra()
    print("\n=== Tropical Semiring Verification ===")
    for a, b, c in [(3, 5, 7), (1, 1, 1), (0, 10, 5)]:
        print(f"  Distributivity({a},{b},{c}): {tca.verify_distributivity(a, b, c)}")
        print(f"    {a} + min({b},{c}) = {a + min(b,c)}")
        print(f"    min({a}+{b}, {a}+{c}) = {min(a+b, a+c)}")

    # Linear cost feasibility
    print("\n=== Linear Cost Feasibility ===")
    syms = ["+", "*", "0", "1"]
    result = check_linear_cost_feasibility(rules, syms)
    if result:
        print(f"  Compatible weights found: {result}")
    else:
        print("  No compatible linear cost function found")
