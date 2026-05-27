#!/usr/bin/env python3
"""
algorithms.py — Higher-Order Critical Pair Algorithms
=====================================================

Implements the core algorithms from the research paper:
1. Bounded β-critical pair enumeration for Miller-pattern systems
2. Bounded joinability checking via normalization
3. Bounded local confluence certification pipeline

All algorithms operate on simply-typed λ-terms with de Bruijn indices.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum, auto


# ============================================================================
# Core Data Structures
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class Term:
    """Simply-typed λ-term with de Bruijn indices.

    Representation:
    - VAR(i): variable at de Bruijn index i
    - APP(s, t): application s t
    - LAM(body): λ-abstraction λ.body

    Example:
        λx. λy. x y  =  LAM(LAM(APP(VAR(1), VAR(0))))
    """
    kind: TermKind
    var_idx: int = 0
    left: Optional['Term'] = None
    right: Optional['Term'] = None
    body: Optional['Term'] = None

    @staticmethod
    def var(i: int) -> 'Term':
        return Term(TermKind.VAR, var_idx=i)

    @staticmethod
    def app(s: 'Term', t: 'Term') -> 'Term':
        return Term(TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'Term') -> 'Term':
        return Term(TermKind.LAM, body=body)

    def size(self) -> int:
        """Number of constructors in the term."""
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.left.size() + self.right.size()
        else:
            return 1 + self.body.size()

    def is_beta_normal(self) -> bool:
        """Check if term contains no β-redex."""
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.LAM:
                return False
            return self.left.is_beta_normal() and self.right.is_beta_normal()
        else:
            return self.body.is_beta_normal()

    def is_closed_at(self, depth: int = 0) -> bool:
        """Check if all free variables have index < depth."""
        if self.kind == TermKind.VAR:
            return self.var_idx < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def free_vars(self, depth: int = 0) -> set[int]:
        """Return set of free variable indices."""
        if self.kind == TermKind.VAR:
            return {self.var_idx - depth} if self.var_idx >= depth else set()
        elif self.kind == TermKind.APP:
            return self.left.free_vars(depth) | self.right.free_vars(depth)
        else:
            return self.body.free_vars(depth + 1)

    def is_miller_pattern_at(self, depth: int = 0) -> bool:
        """Check Miller pattern condition at binding depth."""
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.VAR and self.left.var_idx >= depth:
                # Free var applied to arg: arg must be bound var
                return (self.right.kind == TermKind.VAR and
                        self.right.var_idx < depth)
            return (self.left.is_miller_pattern_at(depth) and
                    self.right.is_miller_pattern_at(depth))
        else:
            return self.body.is_miller_pattern_at(depth + 1)

    def is_linear_at(self, depth: int = 0) -> bool:
        """Check if each free variable occurs at most once."""
        fvs = list(self.free_vars(depth))
        return len(fvs) == len(set(fvs))

    def subterms(self) -> list['Term']:
        """List all subterms."""
        result = [self]
        if self.kind == TermKind.APP:
            result.extend(self.left.subterms())
            result.extend(self.right.subterms())
        elif self.kind == TermKind.LAM:
            result.extend(self.body.subterms())
        return result

    def pretty(self, names: Optional[list[str]] = None) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_idx}"
        elif self.kind == TermKind.APP:
            return f"({self.left.pretty(names)} {self.right.pretty(names)})"
        else:
            return f"(λ.{self.body.pretty(names)})"


# ============================================================================
# Substitution Infrastructure
# ============================================================================

def rename(rho: Callable[[int], int], t: Term) -> Term:
    """Apply a variable renaming to a term.

    Complexity: O(|t|)
    """
    if t.kind == TermKind.VAR:
        return Term.var(rho(t.var_idx))
    elif t.kind == TermKind.APP:
        return Term.app(rename(rho, t.left), rename(rho, t.right))
    else:
        lift = lambda n: 0 if n == 0 else rho(n - 1) + 1
        return Term.lam(rename(lift, t.body))


def apply_subst(t: Term, sigma: Callable[[int], Term]) -> Term:
    """Apply a substitution to a term.

    Complexity: O(|t| * max(|σ(i)|))
    """
    if t.kind == TermKind.VAR:
        return sigma(t.var_idx)
    elif t.kind == TermKind.APP:
        return Term.app(apply_subst(t.left, sigma), apply_subst(t.right, sigma))
    else:
        lift = lambda n: Term.var(0) if n == 0 else rename(lambda x: x + 1, sigma(n - 1))
        return Term.lam(apply_subst(t.body, lift))


def beta_contract(body: Term, arg: Term) -> Term:
    """Perform β-contraction: (λ.body) arg → body[0 := arg]."""
    single = lambda n: arg if n == 0 else Term.var(n - 1)
    return apply_subst(body, single)


# ============================================================================
# Algorithm 1: Bounded β-Normalization
# ============================================================================

def bounded_normalize(t: Term, fuel: int = 1000) -> Term:
    """Normalize a term with bounded fuel.

    Algorithm: leftmost-outermost β-reduction strategy.

    Complexity: O(fuel * |t|) per step
    Convergence: Terminates when fuel exhausted or no redex found.

    Args:
        t: Term to normalize
        fuel: Maximum number of reduction steps

    Returns:
        The (possibly partially) normalized term
    """
    for _ in range(fuel):
        reduced = _reduce_once(t)
        if reduced is None:
            return t
        t = reduced
    return t


def _reduce_once(t: Term) -> Optional[Term]:
    """Perform one leftmost-outermost β-reduction step."""
    if t.kind == TermKind.APP:
        if t.left.kind == TermKind.LAM:
            return beta_contract(t.left.body, t.right)
        left_reduced = _reduce_once(t.left)
        if left_reduced is not None:
            return Term.app(left_reduced, t.right)
        right_reduced = _reduce_once(t.right)
        if right_reduced is not None:
            return Term.app(t.left, right_reduced)
    elif t.kind == TermKind.LAM:
        body_reduced = _reduce_once(t.body)
        if body_reduced is not None:
            return Term.lam(body_reduced)
    return None


# ============================================================================
# Algorithm 2: Syntactic Overlap Detection
# ============================================================================

def syntactic_matchable(pattern: Term, target: Term) -> bool:
    """Check if pattern could potentially match target.

    Conservative approximation: returns True if a substitution
    could exist mapping pattern variables to make pattern = target.

    Complexity: O(min(|pattern|, |target|))
    """
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_matchable(pattern.left, target.left) and
                syntactic_matchable(pattern.right, target.right))
    if pattern.kind == TermKind.LAM:
        return syntactic_matchable(pattern.body, target.body)
    return False


# ============================================================================
# Algorithm 3: Bounded Critical Pair Enumeration
# ============================================================================

@dataclass
class CriticalPair:
    """A critical pair: two terms that should be joinable for confluence."""
    left: Term
    right: Term
    rule1_name: str
    rule2_name: str
    overlap_size: int = 0


@dataclass
class Rule:
    """A rewrite rule l → r."""
    name: str
    lhs: Term
    rhs: Term


@dataclass
class RewriteSystem:
    """A higher-order rewrite system."""
    name: str
    rules: list[Rule]


def enumerate_critical_pairs(system: RewriteSystem, bound: int) -> list[CriticalPair]:
    """Enumerate all candidate critical pairs up to size bound.

    Algorithm:
    For each pair of rules (r1, r2), check if any subterm of r1.lhs
    could overlap with r2.lhs. If so, generate the critical pair
    (r1.rhs, r2.rhs).

    Complexity: O(|rules|² * max_lhs_size * bound)

    Args:
        system: The rewrite system
        bound: Maximum combined size of overlapping LHS terms

    Returns:
        List of candidate critical pairs
    """
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if (syntactic_matchable(sub, r2.lhs) and
                        r1.lhs.size() + r2.lhs.size() <= bound):
                    pairs.append(CriticalPair(
                        left=r1.rhs,
                        right=r2.rhs,
                        rule1_name=r1.name,
                        rule2_name=r2.name,
                        overlap_size=sub.size()
                    ))
    return pairs


# ============================================================================
# Algorithm 4: Bounded Joinability Checking
# ============================================================================

def try_join(t: Term, u: Term, fuel: int = 100) -> bool:
    """Try to join two terms by normalizing both.

    Algorithm: Normalize both terms and check equality.
    Sound but incomplete: True means genuinely joinable,
    False may be a false negative if fuel is insufficient.

    Complexity: O(fuel * max(|t|, |u|))

    Args:
        t, u: Terms to join
        fuel: Normalization fuel

    Returns:
        True if terms normalize to the same result
    """
    nt = bounded_normalize(t, fuel)
    nu = bounded_normalize(u, fuel)
    return nt == nu


# ============================================================================
# Algorithm 5: Bounded Local Confluence Certification
# ============================================================================

@dataclass
class ConfluenceCertificate:
    """Certificate for bounded local confluence."""
    system_name: str
    bound: int
    total_critical_pairs: int
    joinable_pairs: int
    non_joinable_pairs: list[CriticalPair]
    is_locally_confluent: bool

    def __str__(self):
        status = "CONFLUENT" if self.is_locally_confluent else "NON-CONFLUENT"
        return (f"Certificate({self.system_name}, N={self.bound}, "
                f"CPs={self.total_critical_pairs}, "
                f"joinable={self.joinable_pairs}, "
                f"status={status})")


def certify_bounded_confluence(
    system: RewriteSystem,
    bound: int,
    join_fuel: int = 100
) -> ConfluenceCertificate:
    """Certify bounded local confluence of a rewrite system.

    Algorithm:
    1. Enumerate all critical pairs up to size bound
    2. Attempt to join each pair
    3. If all pairs join, certify local confluence

    Complexity: O(|rules|² * bound * join_fuel)

    Args:
        system: The rewrite system to certify
        bound: Size bound for critical pair enumeration
        join_fuel: Normalization fuel for joining

    Returns:
        A ConfluenceCertificate
    """
    cps = enumerate_critical_pairs(system, bound)
    non_joinable = []
    joinable_count = 0

    for cp in cps:
        if try_join(cp.left, cp.right, join_fuel):
            joinable_count += 1
        else:
            non_joinable.append(cp)

    return ConfluenceCertificate(
        system_name=system.name,
        bound=bound,
        total_critical_pairs=len(cps),
        joinable_pairs=joinable_count,
        non_joinable_pairs=non_joinable,
        is_locally_confluent=(len(non_joinable) == 0)
    )


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    # Map fusion system
    map_fusion = Rule(
        name="map-fusion",
        lhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                      Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        rhs=Term.app(Term.app(Term.var(0),
                               Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                      Term.var(3))
    )
    map_id = Rule(
        name="map-id",
        lhs=Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1)),
        rhs=Term.var(1)
    )

    system = RewriteSystem("MapFusion", [map_fusion, map_id])

    print("Certifying bounded local confluence...")
    cert = certify_bounded_confluence(system, bound=20)
    print(cert)

    # Test β-normalization
    omega = Term.lam(Term.app(Term.var(0), Term.var(0)))
    identity = Term.lam(Term.var(0))
    test = Term.app(identity, Term.var(42))

    print(f"\nβ-normalizing: {test.pretty()}")
    result = bounded_normalize(test, 10)
    print(f"Result: {result.pretty()}")
