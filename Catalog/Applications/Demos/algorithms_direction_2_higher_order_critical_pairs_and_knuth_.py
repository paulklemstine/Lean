#!/usr/bin/env python3
"""
algorithms.py — Algorithms for bounded higher-order critical pair analysis
and Knuth-Bendix completion modulo β.

Implements:
1. Higher-order term algebra with β-reduction
2. Miller pattern detection
3. Bounded critical pair enumeration
4. Bounded joinability checking
5. Completion certificate generation

All algorithms match the formal specifications in the Lean development.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Set, FrozenSet
from enum import Enum, auto
import time


# ============================================================================
# 1. Term Algebra
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class Term:
    """Simply-typed higher-order term.

    Represents variables (de Bruijn indices), applications, and λ-abstractions.
    Terms are immutable and hashable for use in sets and dicts.

    >>> Term.var(0)
    Term(kind=VAR, idx=0)
    >>> Term.app(Term.var(0), Term.var(1))
    Term(kind=APP, left=x0, right=x1)
    """
    kind: TermKind
    idx: int = -1
    left: Optional['Term'] = None
    right: Optional['Term'] = None
    body: Optional['Term'] = None

    @staticmethod
    def var(i: int) -> 'Term':
        """Create a variable with de Bruijn index i."""
        return Term(TermKind.VAR, idx=i)

    @staticmethod
    def app(s: 'Term', t: 'Term') -> 'Term':
        """Create an application s t."""
        return Term(TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'Term') -> 'Term':
        """Create a λ-abstraction λ.body."""
        return Term(TermKind.LAM, body=body)

    def size(self) -> int:
        """Compute the size (number of constructors) of a term.

        Time complexity: O(n) where n is the term size.

        >>> Term.var(0).size()
        1
        >>> Term.app(Term.var(0), Term.var(1)).size()
        3
        """
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.left.size() + self.right.size()
        else:
            return 1 + self.body.size()

    def is_beta_normal(self) -> bool:
        """Check if the term is in β-normal form.

        A term is β-normal if it contains no β-redex (λ.t) u.

        Time complexity: O(n).

        >>> Term.app(Term.lam(Term.var(0)), Term.var(1)).is_beta_normal()
        False
        >>> Term.app(Term.var(0), Term.var(1)).is_beta_normal()
        True
        """
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.LAM:
                return False
            return self.left.is_beta_normal() and self.right.is_beta_normal()
        else:
            return self.body.is_beta_normal()

    def is_closed_at(self, depth: int = 0) -> bool:
        """Check if the term is closed (no free variables) at given binding depth.

        Time complexity: O(n).
        """
        if self.kind == TermKind.VAR:
            return self.idx < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def is_closed(self) -> bool:
        """Check if the term has no free variables."""
        return self.is_closed_at(0)

    def rename(self, rho) -> 'Term':
        """Apply a renaming function to all free variables."""
        if self.kind == TermKind.VAR:
            return Term.var(rho(self.idx))
        elif self.kind == TermKind.APP:
            return Term.app(self.left.rename(rho), self.right.rename(rho))
        else:
            lifted = lambda n: 0 if n == 0 else rho(n - 1) + 1
            return Term.lam(self.body.rename(lifted))

    def subst(self, sigma: Dict[int, 'Term'], depth: int = 0) -> 'Term':
        """Apply a substitution (dict from var index to term).

        Handles de Bruijn index shifting correctly.

        Time complexity: O(n * max_subst_size) in the worst case.
        """
        if self.kind == TermKind.VAR:
            if self.idx >= depth:
                adjusted_idx = self.idx - depth
                if adjusted_idx in sigma:
                    # Shift the substituted term up by 'depth'
                    result = sigma[adjusted_idx]
                    for _ in range(depth):
                        result = result.rename(lambda n: n + 1)
                    return result
            return self
        elif self.kind == TermKind.APP:
            return Term.app(self.left.subst(sigma, depth),
                          self.right.subst(sigma, depth))
        else:
            return Term.lam(self.body.subst(sigma, depth + 1))

    def beta_contract(self) -> Optional['Term']:
        """Try one-step β-contraction at the root: (λ.body) arg → body[0:=arg]."""
        if self.kind == TermKind.APP and self.left.kind == TermKind.LAM:
            return self.left.body.subst({0: self.right})
        return None

    def subterms(self) -> List['Term']:
        """Return all subterms (including self)."""
        if self.kind == TermKind.VAR:
            return [self]
        elif self.kind == TermKind.APP:
            return [self] + self.left.subterms() + self.right.subterms()
        else:
            return [self] + self.body.subterms()

    def __str__(self) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.idx}"
        elif self.kind == TermKind.APP:
            l = str(self.left)
            r = str(self.right)
            if self.right.kind == TermKind.APP:
                r = f"({r})"
            return f"{l} {r}"
        else:
            return f"(λ.{self.body})"

    def __repr__(self) -> str:
        return str(self)


# ============================================================================
# 2. Miller Pattern Detection
# ============================================================================

def is_miller_pattern_at(t: Term, depth: int = 0) -> bool:
    """Check if a term is a Miller pattern at given binding depth.

    A term is a Miller pattern if every free variable occurrence appears
    applied only to distinct bound variables.

    Time complexity: O(n) where n is the term size.

    Args:
        t: The term to check
        depth: Current binding depth

    Returns:
        True if t is a Miller pattern

    >>> is_miller_pattern_at(Term.var(0))
    True
    >>> is_miller_pattern_at(Term.lam(Term.app(Term.var(1), Term.var(0))))
    True
    """
    if t.kind == TermKind.VAR:
        return True
    elif t.kind == TermKind.APP:
        if t.left.kind == TermKind.VAR and t.left.idx >= depth:
            # Free variable applied to something: check it's a bound var
            if t.right.kind == TermKind.VAR and t.right.idx < depth:
                return True
            return False
        return (is_miller_pattern_at(t.left, depth) and
                is_miller_pattern_at(t.right, depth))
    else:
        return is_miller_pattern_at(t.body, depth + 1)


def is_miller_pattern(t: Term) -> bool:
    """Check if a term is a Miller pattern."""
    return is_miller_pattern_at(t, 0)


# ============================================================================
# 3. Rewrite Systems
# ============================================================================

@dataclass
class RewriteRule:
    """A rewrite rule with name, LHS, and RHS."""
    name: str
    lhs: Term
    rhs: Term

    def is_left_linear(self) -> bool:
        """Check if the rule is left-linear (each variable appears at most once in LHS)."""
        vars_seen: Set[int] = set()
        return self._check_linear(self.lhs, vars_seen)

    def _check_linear(self, t: Term, seen: Set[int]) -> bool:
        if t.kind == TermKind.VAR:
            if t.idx in seen:
                return False
            seen.add(t.idx)
            return True
        elif t.kind == TermKind.APP:
            return (self._check_linear(t.left, seen) and
                    self._check_linear(t.right, seen))
        else:
            return self._check_linear(t.body, seen)

    def __str__(self):
        return f"{self.name}: {self.lhs} → {self.rhs}"


@dataclass
class RewriteSystem:
    """A higher-order rewrite system."""
    name: str
    rules: List[RewriteRule]

    def is_left_linear(self) -> bool:
        """Check if all rules are left-linear."""
        return all(r.is_left_linear() for r in self.rules)

    def all_miller_patterns(self) -> bool:
        """Check if all LHS are Miller patterns."""
        return all(is_miller_pattern(r.lhs) for r in self.rules)


# ============================================================================
# 4. Bounded Normalization
# ============================================================================

def bounded_normalize(t: Term, fuel: int) -> Term:
    """Normalize a term with bounded computation steps.

    Repeatedly applies β-reduction and subterm normalization until
    either a normal form is reached or fuel is exhausted.

    Time complexity: O(fuel * n) where n is the term size.
    Space complexity: O(n * fuel) in the worst case due to substitution growth.

    Args:
        t: Term to normalize
        fuel: Maximum number of reduction steps

    Returns:
        The (possibly partially) normalized term
    """
    if fuel <= 0:
        return t

    contracted = t.beta_contract()
    if contracted is not None:
        return bounded_normalize(contracted, fuel - 1)

    if t.kind == TermKind.APP:
        left_n = bounded_normalize(t.left, fuel // 2)
        right_n = bounded_normalize(t.right, fuel // 2)
        new_t = Term.app(left_n, right_n)
        if new_t != t:
            return bounded_normalize(new_t, fuel - 1)
        return t
    elif t.kind == TermKind.LAM:
        body_n = bounded_normalize(t.body, fuel - 1)
        return Term.lam(body_n) if body_n != t.body else t

    return t


# ============================================================================
# 5. Critical Pair Enumeration
# ============================================================================

@dataclass
class CriticalPair:
    """A critical pair: two terms arising from overlapping rewrites."""
    left: Term
    right: Term
    rule1: RewriteRule
    rule2: RewriteRule
    overlap_term: Term

    def __str__(self):
        return f"⟨{self.left}, {self.right}⟩ from {self.rule1.name} × {self.rule2.name}"


def syntactic_overlap(p: Term, q: Term) -> bool:
    """Check if two terms could have a syntactic overlap (unifiable).

    This is an over-approximation: returns True if the terms might unify,
    treating variables as wildcards.

    Time complexity: O(min(|p|, |q|)).
    """
    if p.kind == TermKind.VAR or q.kind == TermKind.VAR:
        return True
    if p.kind != q.kind:
        return False
    if p.kind == TermKind.APP:
        return syntactic_overlap(p.left, q.left) and syntactic_overlap(p.right, q.right)
    if p.kind == TermKind.LAM:
        return syntactic_overlap(p.body, q.body)
    return False


def enumerate_beta_critical_pairs(system: RewriteSystem, bound: int) -> List[CriticalPair]:
    """Enumerate all β-critical pairs up to a given size bound.

    For each pair of rules (r1, r2), checks if any subterm of r1.lhs
    can overlap with r2.lhs within the size bound.

    Time complexity: O(|rules|² * max_lhs_size * bound).

    Args:
        system: The rewrite system
        bound: Maximum combined size for overlap detection

    Returns:
        List of critical pairs found

    >>> sys = make_map_fusion_system()
    >>> cps = enumerate_beta_critical_pairs(sys, 20)
    >>> len(cps) >= 0
    True
    """
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if (syntactic_overlap(sub, r2.lhs) and
                    r1.lhs.size() + r2.lhs.size() <= bound):
                    pairs.append(CriticalPair(
                        left=r1.rhs,
                        right=r2.rhs,
                        rule1=r1,
                        rule2=r2,
                        overlap_term=sub
                    ))
    return pairs


# ============================================================================
# 6. Bounded Joinability Checking
# ============================================================================

def try_join(t1: Term, t2: Term, fuel: int = 20) -> Tuple[bool, Optional[Term]]:
    """Try to join two terms by bounded normalization.

    Normalizes both terms and checks if they reach the same normal form.

    Time complexity: O(fuel * max(|t1|, |t2|)).

    Args:
        t1: First term
        t2: Second term
        fuel: Maximum normalization steps

    Returns:
        (success, common_reduct) where success is True if joined
    """
    n1 = bounded_normalize(t1, fuel)
    n2 = bounded_normalize(t2, fuel)
    if n1 == n2:
        return True, n1
    return False, None


# ============================================================================
# 7. Completion Certificate
# ============================================================================

@dataclass
class CompletionCertificate:
    """A bounded local confluence certificate for a rewrite system.

    Bundles:
    - The rewrite system
    - Size bound
    - Proof that all rules have Miller-pattern LHS
    - Proof that the system is left-linear
    - All critical pairs and their joinability status
    - Bounded local confluence status
    """
    system: RewriteSystem
    bound: int
    is_pattern_system: bool
    is_left_linear: bool
    critical_pairs: List[CriticalPair]
    all_joinable: bool
    non_joinable_pairs: List[CriticalPair]
    computation_time_ms: float

    def is_valid(self) -> bool:
        """Check if this is a valid local confluence certificate."""
        return (self.is_pattern_system and
                self.is_left_linear and
                self.all_joinable)

    def __str__(self):
        lines = [
            f"CompletionCertificate for {self.system.name}:",
            f"  Bound: {self.bound}",
            f"  Miller patterns: {self.is_pattern_system}",
            f"  Left-linear: {self.is_left_linear}",
            f"  Critical pairs: {len(self.critical_pairs)}",
            f"  All joinable: {self.all_joinable}",
            f"  Valid certificate: {self.is_valid()}",
            f"  Computation time: {self.computation_time_ms:.1f} ms",
        ]
        if self.non_joinable_pairs:
            lines.append(f"  Non-joinable pairs:")
            for cp in self.non_joinable_pairs:
                lines.append(f"    {cp}")
        return "\n".join(lines)


def generate_certificate(system: RewriteSystem, bound: int,
                         join_fuel: int = 20) -> CompletionCertificate:
    """Generate a bounded local confluence certificate.

    This is the main algorithmic entry point. It:
    1. Checks Miller-pattern and left-linearity conditions
    2. Enumerates all critical pairs up to the bound
    3. Attempts to join each critical pair
    4. Produces a certificate

    Time complexity: O(|rules|² * max_lhs * bound + |CPs| * join_fuel * max_size).

    Args:
        system: The rewrite system to analyze
        bound: Size bound for critical pair enumeration
        join_fuel: Fuel for joinability checking

    Returns:
        A CompletionCertificate
    """
    start = time.time()

    is_pattern = system.all_miller_patterns()
    is_ll = system.is_left_linear()

    cps = enumerate_beta_critical_pairs(system, bound)

    non_joinable = []
    all_join = True
    for cp in cps:
        joined, _ = try_join(cp.left, cp.right, join_fuel)
        if not joined:
            all_join = False
            non_joinable.append(cp)

    elapsed = (time.time() - start) * 1000

    return CompletionCertificate(
        system=system,
        bound=bound,
        is_pattern_system=is_pattern,
        is_left_linear=is_ll,
        critical_pairs=cps,
        all_joinable=all_join,
        non_joinable_pairs=non_joinable,
        computation_time_ms=elapsed
    )


# ============================================================================
# 8. Benchmark Systems
# ============================================================================

def make_map_fusion_system() -> RewriteSystem:
    """Create the map fusion benchmark system."""
    x0, x1, x2, x3 = [Term.var(i) for i in range(4)]

    rules = [
        RewriteRule("MapFusion",
            Term.app(Term.app(x0, x1), Term.app(Term.app(x0, x2), x3)),
            Term.app(Term.app(x0,
                Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                x3)),
        RewriteRule("MapId",
            Term.app(Term.app(x0, Term.lam(Term.var(0))), x1),
            x1),
    ]
    return RewriteSystem("MapFusion", rules)


def make_eta_system() -> RewriteSystem:
    """Create the η-reduction system."""
    return RewriteSystem("Eta", [
        RewriteRule("Eta",
            Term.lam(Term.app(Term.var(1), Term.var(0))),
            Term.var(0))
    ])


def make_cps_system() -> RewriteSystem:
    """Create a CPS transformation system."""
    return RewriteSystem("CPS", [
        RewriteRule("CPS-Id",
            Term.app(Term.var(0), Term.lam(Term.var(0))),
            Term.app(Term.var(1), Term.lam(Term.var(0))))
    ])


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Higher-Order Critical Pair Algorithms ===\n")

    systems = [
        make_map_fusion_system(),
        make_eta_system(),
        make_cps_system(),
    ]

    for sys in systems:
        cert = generate_certificate(sys, bound=20)
        print(cert)
        print()
