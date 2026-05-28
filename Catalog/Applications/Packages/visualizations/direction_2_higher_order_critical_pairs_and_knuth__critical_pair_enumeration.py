#!/usr/bin/env python3
"""
Algorithms for Higher-Order Critical Pair Analysis and
Bounded Knuth-Bendix Completion Modulo β

Implements:
1. Higher-order term algebra with de Bruijn indices
2. β-normalization with fuel-bounded reduction
3. Syntactic pattern matching (Miller patterns)
4. Critical pair enumeration for pattern rewrite systems
5. Bounded joinability checking
6. Completion certificate generation

Type hints and docstrings throughout.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, Tuple
from enum import Enum, auto


# ============================================================================
# Algorithm 1: Higher-Order Term Representation
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class HOTerm:
    """
    Higher-order term with de Bruijn indices.

    Variants:
      - VAR(i): variable with index i
      - APP(left, right): application
      - LAM(body): lambda abstraction (de Bruijn)

    Complexity: O(1) construction, O(n) size/traversal.
    """
    kind: TermKind
    var_id: int = 0
    left: Optional['HOTerm'] = None
    right: Optional['HOTerm'] = None
    body: Optional['HOTerm'] = None

    @staticmethod
    def var(i: int) -> 'HOTerm':
        return HOTerm(kind=TermKind.VAR, var_id=i)

    @staticmethod
    def app(s: 'HOTerm', t: 'HOTerm') -> 'HOTerm':
        return HOTerm(kind=TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'HOTerm') -> 'HOTerm':
        return HOTerm(kind=TermKind.LAM, body=body)

    def size(self) -> int:
        """Number of constructors. O(n) time."""
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.left.size() + self.right.size()
        else:
            return 1 + self.body.size()

    def is_beta_normal(self) -> bool:
        """Check if term is in β-normal form. O(n) time."""
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.LAM:
                return False
            return self.left.is_beta_normal() and self.right.is_beta_normal()
        else:
            return self.body.is_beta_normal()

    def is_closed_at(self, depth: int = 0) -> bool:
        """Check if term is closed at given binding depth. O(n) time."""
        if self.kind == TermKind.VAR:
            return self.var_id < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def is_miller_pattern_at(self, depth: int = 0) -> bool:
        """
        Check if term is a Miller pattern at given depth.

        A Miller pattern has the property that every free variable
        occurrence appears applied only to distinct bound variables.

        O(n) time.
        """
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.VAR and self.left.var_id >= depth:
                return (self.right.kind == TermKind.VAR and
                        self.right.var_id < depth)
            return (self.left.is_miller_pattern_at(depth) and
                    self.right.is_miller_pattern_at(depth))
        else:
            return self.body.is_miller_pattern_at(depth + 1)

    def subterms(self):
        """Enumerate all subterms. O(n) time, O(n) space."""
        yield self
        if self.kind == TermKind.APP:
            yield from self.left.subterms()
            yield from self.right.subterms()
        elif self.kind == TermKind.LAM:
            yield from self.body.subterms()

    def __repr__(self):
        if self.kind == TermKind.VAR:
            return f"x{self.var_id}"
        elif self.kind == TermKind.APP:
            return f"({self.left} {self.right})"
        else:
            return f"(λ.{self.body})"


# ============================================================================
# Algorithm 2: Substitution and β-Reduction
# ============================================================================

def rename(rho: Callable[[int], int], term: HOTerm) -> HOTerm:
    """
    Apply a variable renaming to a term.

    Pseudocode:
      rename(ρ, x_i) = x_{ρ(i)}
      rename(ρ, s t) = (rename(ρ, s)) (rename(ρ, t))
      rename(ρ, λ.t) = λ.(rename(lift(ρ), t))
        where lift(ρ)(0) = 0, lift(ρ)(n+1) = ρ(n) + 1

    Time: O(n), Space: O(n)
    """
    if term.kind == TermKind.VAR:
        return HOTerm.var(rho(term.var_id))
    elif term.kind == TermKind.APP:
        return HOTerm.app(rename(rho, term.left), rename(rho, term.right))
    else:
        lift = lambda n: 0 if n == 0 else rho(n - 1) + 1
        return HOTerm.lam(rename(lift, term.body))


def subst(term: HOTerm, sigma: Callable[[int], HOTerm]) -> HOTerm:
    """
    Apply a substitution to a term.

    Pseudocode:
      subst(x_i, σ) = σ(i)
      subst(s t, σ) = (subst(s, σ)) (subst(t, σ))
      subst(λ.t, σ) = λ.(subst(t, lift(σ)))
        where lift(σ)(0) = x_0, lift(σ)(n+1) = rename(+1, σ(n))

    Time: O(n × |σ|), Space: O(n × |σ|)
    """
    if term.kind == TermKind.VAR:
        return sigma(term.var_id)
    elif term.kind == TermKind.APP:
        return HOTerm.app(subst(term.left, sigma), subst(term.right, sigma))
    else:
        lift = lambda n: (HOTerm.var(0) if n == 0
                          else rename(lambda k: k + 1, sigma(n - 1)))
        return HOTerm.lam(subst(term.body, lift))


def beta_contract(body: HOTerm, arg: HOTerm) -> HOTerm:
    """
    β-contraction: (λ.body) arg → body[0 := arg].

    Time: O(|body| × |arg|)
    """
    single = lambda n: arg if n == 0 else HOTerm.var(n - 1)
    return subst(body, single)


# ============================================================================
# Algorithm 3: Bounded β-Normalization
# ============================================================================

def normalize(term: HOTerm, fuel: int = 100) -> Tuple[HOTerm, int]:
    """
    Normalize a term by leftmost-outermost β-reduction with fuel bound.

    Returns: (normal_form, steps_taken)

    Pseudocode:
      1. While fuel > 0:
         a. Find leftmost-outermost β-redex
         b. If none found, return (current term, 0)
         c. Contract the redex
         d. Decrement fuel
      2. Return (current term, fuel_used)

    Time: O(fuel × n²) worst case
    Space: O(n) per step
    """
    current = term
    steps = 0
    for _ in range(fuel):
        reduced = _reduce_once(current)
        if reduced is None:
            return current, steps
        current = reduced
        steps += 1
    return current, steps


def _reduce_once(term: HOTerm) -> Optional[HOTerm]:
    """One step of leftmost-outermost β-reduction."""
    if term.kind == TermKind.APP and term.left.kind == TermKind.LAM:
        return beta_contract(term.left.body, term.right)
    if term.kind == TermKind.APP:
        left = _reduce_once(term.left)
        if left is not None:
            return HOTerm.app(left, term.right)
        right = _reduce_once(term.right)
        if right is not None:
            return HOTerm.app(term.left, right)
    if term.kind == TermKind.LAM:
        body = _reduce_once(term.body)
        if body is not None:
            return HOTerm.lam(body)
    return None


# ============================================================================
# Algorithm 4: Critical Pair Enumeration
# ============================================================================

@dataclass
class Rule:
    """A rewrite rule with a name."""
    name: str
    lhs: HOTerm
    rhs: HOTerm


@dataclass
class CriticalPair:
    """A critical pair arising from overlapping rule applications."""
    left: HOTerm
    right: HOTerm
    rule1: str
    rule2: str
    overlap_size: int


def syntactic_overlap(pattern: HOTerm, target: HOTerm) -> bool:
    """
    Check if two terms could potentially overlap (unify).

    Conservative approximation: variables match anything.
    Time: O(min(|pattern|, |target|))
    """
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_overlap(pattern.left, target.left) and
                syntactic_overlap(pattern.right, target.right))
    if pattern.kind == TermKind.LAM:
        return syntactic_overlap(pattern.body, target.body)
    return False


def enumerate_critical_pairs(rules: list, bound: int) -> list:
    """
    Enumerate β-critical pairs up to a size bound.

    Pseudocode:
      For each pair of rules (r₁, r₂):
        For each non-variable subterm s of r₁.lhs:
          If syntactic_overlap(s, r₂.lhs) and combined size ≤ bound:
            Generate critical pair (r₁.rhs, r₂.rhs)

    Time: O(|rules|² × max_lhs_size × bound)
    Space: O(|output|)

    Returns: list of CriticalPair objects
    """
    pairs = []
    for r1 in rules:
        for r2 in rules:
            for sub in r1.lhs.subterms():
                combined_size = r1.lhs.size() + r2.lhs.size()
                if (syntactic_overlap(sub, r2.lhs) and
                        combined_size <= bound):
                    cp = CriticalPair(
                        left=r1.rhs,
                        right=r2.rhs,
                        rule1=r1.name,
                        rule2=r2.name,
                        overlap_size=combined_size
                    )
                    pairs.append(cp)
    return pairs


# ============================================================================
# Algorithm 5: Bounded Joinability Checker
# ============================================================================

def try_join(t1: HOTerm, t2: HOTerm, fuel: int = 50) -> Tuple[bool, Optional[HOTerm]]:
    """
    Try to join two terms by normalizing both.

    Pseudocode:
      1. Normalize t1 with given fuel → nf1
      2. Normalize t2 with given fuel → nf2
      3. Return (nf1 == nf2, nf1 if joined else None)

    Time: O(fuel × max(|t1|, |t2|)²)
    Returns: (is_joinable, common_reduct_or_None)
    """
    nf1, _ = normalize(t1, fuel)
    nf2, _ = normalize(t2, fuel)
    if nf1 == nf2:
        return True, nf1
    return False, None


# ============================================================================
# Algorithm 6: Completion Certificate Generation
# ============================================================================

@dataclass
class CompletionCertificate:
    """
    A bounded completion certificate for a higher-order rewrite system.

    Fields:
      - rules: the rewrite system
      - bound: size bound for analysis
      - critical_pairs: enumerated critical pairs
      - all_joinable: whether all pairs are joinable
      - non_joinable_pairs: first few non-joinable pairs (if any)
      - is_miller: whether all LHS are Miller patterns
      - is_locally_confluent: certificate conclusion
    """
    rules: list
    bound: int
    critical_pairs: list
    all_joinable: bool
    non_joinable_pairs: list
    is_miller: bool
    is_locally_confluent: bool


def generate_certificate(rules: list, bound: int,
                          join_fuel: int = 50) -> CompletionCertificate:
    """
    Generate a bounded completion certificate.

    Pseudocode:
      1. Check Miller pattern property for all LHS
      2. Enumerate critical pairs up to bound
      3. For each critical pair, attempt bounded joining
      4. Collect results into certificate

    Time: O(|rules|² × max_size × bound × join_fuel)
    """
    is_miller = all(r.lhs.is_miller_pattern_at(0) for r in rules)

    cps = enumerate_critical_pairs(rules, bound)

    non_joinable = []
    all_joinable = True
    for cp in cps:
        joined, _ = try_join(cp.left, cp.right, join_fuel)
        if not joined:
            all_joinable = False
            non_joinable.append(cp)

    return CompletionCertificate(
        rules=rules,
        bound=bound,
        critical_pairs=cps,
        all_joinable=all_joinable,
        non_joinable_pairs=non_joinable[:5],
        is_miller=is_miller,
        is_locally_confluent=all_joinable
    )


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Example: β-admin system
    beta_rule = Rule(
        name="beta-admin",
        lhs=HOTerm.app(HOTerm.lam(HOTerm.var(0)), HOTerm.var(1)),
        rhs=HOTerm.var(1)
    )

    cert = generate_certificate([beta_rule], bound=20)

    print("Completion Certificate:")
    print(f"  Rules: {len(cert.rules)}")
    print(f"  Bound: {cert.bound}")
    print(f"  Critical pairs: {len(cert.critical_pairs)}")
    print(f"  All joinable: {cert.all_joinable}")
    print(f"  Miller patterns: {cert.is_miller}")
    print(f"  Locally confluent: {cert.is_locally_confluent}")
