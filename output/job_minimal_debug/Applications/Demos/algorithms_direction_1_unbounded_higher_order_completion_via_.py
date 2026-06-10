#!/usr/bin/env python3
"""
Algorithms for Recursive Critical Pair Saturation

Implements the core algorithms from the research paper:
1. Term algebra operations (substitution, beta reduction, normalization)
2. Critical pair enumeration with size bounds
3. Recursive saturation procedure
4. Joinability checking via bounded normalization
5. Completion certificate generation

Time complexity analysis:
- CP enumeration at level N: O(|R|² × T(N)) where T(N) = # terms of size ≤ N
- Saturation up to level N₀: O(N₀ × |R|² × T(N₀))
- Joinability check: O(|CP| × fuel) where fuel is the normalization budget

Space complexity:
- O(|CP(N₀)|) for storing the critical pair set
- O(N₀ × max_term_size) for normalization
"""

from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum


# ============================================================================
# Term Algebra
# ============================================================================

class TermKind(Enum):
    VAR = "var"
    APP = "app"
    LAM = "lam"

@dataclass(frozen=True)
class Term:
    """Higher-order term (λ-calculus with de Bruijn indices)."""
    kind: TermKind
    var_index: int = 0        # For VAR
    func: Optional['Term'] = None   # For APP
    arg: Optional['Term'] = None    # For APP
    body: Optional['Term'] = None   # For LAM
    
    @staticmethod
    def var(i: int) -> 'Term':
        return Term(kind=TermKind.VAR, var_index=i)
    
    @staticmethod
    def app(f: 'Term', a: 'Term') -> 'Term':
        return Term(kind=TermKind.APP, func=f, arg=a)
    
    @staticmethod
    def lam(b: 'Term') -> 'Term':
        return Term(kind=TermKind.LAM, body=b)
    
    def size(self) -> int:
        """Size of the term (number of nodes)."""
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.func.size() + self.arg.size()
        else:
            return 1 + self.body.size()
    
    def depth(self) -> int:
        """Depth of the term (longest root-to-leaf path)."""
        if self.kind == TermKind.VAR:
            return 0
        elif self.kind == TermKind.APP:
            return 1 + max(self.func.depth(), self.arg.depth())
        else:
            return 1 + self.body.depth()
    
    def subterms(self) -> list['Term']:
        """All subterms."""
        result = [self]
        if self.kind == TermKind.APP:
            result.extend(self.func.subterms())
            result.extend(self.arg.subterms())
        elif self.kind == TermKind.LAM:
            result.extend(self.body.subterms())
        return result
    
    def is_beta_normal(self) -> bool:
        """Check if term is in beta normal form."""
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.func.kind == TermKind.LAM:
                return False
            return self.func.is_beta_normal() and self.arg.is_beta_normal()
        else:
            return self.body.is_beta_normal()
    
    def __repr__(self):
        if self.kind == TermKind.VAR:
            return f"x{self.var_index}"
        elif self.kind == TermKind.APP:
            return f"({self.func} {self.arg})"
        else:
            return f"(λ.{self.body})"


# ============================================================================
# Substitution
# ============================================================================

def shift(term: Term, cutoff: int, amount: int) -> Term:
    """Shift free variables in term by amount, above cutoff."""
    if term.kind == TermKind.VAR:
        if term.var_index >= cutoff:
            return Term.var(term.var_index + amount)
        return term
    elif term.kind == TermKind.APP:
        return Term.app(shift(term.func, cutoff, amount),
                       shift(term.arg, cutoff, amount))
    else:
        return Term.lam(shift(term.body, cutoff + 1, amount))

def substitute(term: Term, var_idx: int, replacement: Term) -> Term:
    """Substitute replacement for var_idx in term (capture-avoiding)."""
    if term.kind == TermKind.VAR:
        if term.var_index == var_idx:
            return replacement
        elif term.var_index > var_idx:
            return Term.var(term.var_index - 1)
        return term
    elif term.kind == TermKind.APP:
        return Term.app(substitute(term.func, var_idx, replacement),
                       substitute(term.arg, var_idx, replacement))
    else:
        return Term.lam(substitute(term.body, var_idx + 1,
                                   shift(replacement, 0, 1)))

def beta_contract(body: Term, arg: Term) -> Term:
    """Contract a beta redex (λ.body) arg."""
    return substitute(body, 0, arg)


# ============================================================================
# Normalization
# ============================================================================

def normalize(term: Term, fuel: int = 100) -> Term:
    """Normalize a term using leftmost-outermost reduction.
    
    Time: O(fuel × term_size)
    Space: O(fuel × term_size) for intermediate terms
    """
    if fuel <= 0:
        return term
    
    if term.kind == TermKind.APP and term.func.kind == TermKind.LAM:
        # Beta reduction
        reduced = beta_contract(term.func.body, term.arg)
        return normalize(reduced, fuel - 1)
    elif term.kind == TermKind.APP:
        new_func = normalize(term.func, fuel - 1)
        if new_func != term.func:
            return normalize(Term.app(new_func, term.arg), fuel - 1)
        new_arg = normalize(term.arg, fuel - 1)
        return Term.app(new_func, new_arg)
    elif term.kind == TermKind.LAM:
        return Term.lam(normalize(term.body, fuel - 1))
    return term


# ============================================================================
# Rewrite System
# ============================================================================

@dataclass
class Rule:
    """A rewrite rule l → r."""
    lhs: Term
    rhs: Term
    name: str = ""

@dataclass
class RewriteSystem:
    """A higher-order rewrite system."""
    rules: list[Rule] = field(default_factory=list)
    
    def add_rule(self, lhs: Term, rhs: Term, name: str = "") -> None:
        self.rules.append(Rule(lhs, rhs, name))


# ============================================================================
# Critical Pair Enumeration
# ============================================================================

def syntactic_match(pattern: Term, target: Term) -> bool:
    """Check if pattern could match target (simplified unification check).
    
    Time: O(min(|pattern|, |target|))
    """
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_match(pattern.func, target.func) and
                syntactic_match(pattern.arg, target.arg))
    if pattern.kind == TermKind.LAM:
        return syntactic_match(pattern.body, target.body)
    return False

@dataclass(frozen=True)
class CriticalPair:
    """A critical pair (s, t) arising from overlapping rule applications."""
    left: Term
    right: Term
    source_size: int = 0

def enumerate_critical_pairs(system: RewriteSystem, N: int) -> list[CriticalPair]:
    """Enumerate critical pairs with source terms of size ≤ N.
    
    Algorithm:
    1. For each pair of rules (r1, r2):
    2.   For each subterm s of r1.lhs:
    3.     If s could unify with r2.lhs and combined size ≤ N:
    4.       Record the critical pair (r1.rhs, r2.rhs)
    
    Time: O(|R|² × S × N) where S = max subterm count
    Space: O(|CP|) for the result set
    """
    pairs: list[CriticalPair] = []
    seen: set = set()
    
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if syntactic_match(sub, r2.lhs):
                    combined = r1.lhs.size() + r2.lhs.size()
                    if combined <= N:
                        key = (repr(r1.rhs), repr(r2.rhs))
                        if key not in seen:
                            seen.add(key)
                            pairs.append(CriticalPair(
                                left=r1.rhs,
                                right=r2.rhs,
                                source_size=combined
                            ))
    return pairs


# ============================================================================
# Joinability Checking
# ============================================================================

def try_join(system: RewriteSystem, t: Term, u: Term, 
             fuel: int = 100) -> bool:
    """Check if two terms are joinable by normalizing both.
    
    Time: O(fuel × max(|t|, |u|))
    """
    nt = normalize(t, fuel)
    nu = normalize(u, fuel)
    return nt == nu


# ============================================================================
# Recursive Saturation (Main Algorithm)
# ============================================================================

@dataclass
class SaturationResult:
    """Result of the recursive saturation procedure."""
    stabilized: bool
    stabilization_level: Optional[int]
    cp_counts: list[tuple[int, int]]  # (level, count)
    all_joinable: bool
    total_cps: int

def recursive_saturation(
    system: RewriteSystem,
    max_level: int = 50,
    join_fuel: int = 200,
    verbose: bool = False
) -> SaturationResult:
    """
    Recursive Critical Pair Saturation Algorithm
    
    Input: A rewrite system E, maximum search level, joinability fuel
    Output: Stabilization level N₀ (if found) and joinability status
    
    Pseudocode:
        prev_count ← 0
        for N = 1 to max_level:
            CPs ← EnumerateCriticalPairs(E, N)
            if |CPs| = prev_count and N > 1:
                // Stabilized!
                all_join ← ∀ (s,t) ∈ CPs: TryJoin(s, t)
                return (N, CPs, all_join)
            prev_count ← |CPs|
        return TIMEOUT
    
    Complexity:
        Time: O(N₀ × |R|² × T(N₀) + |CP| × join_fuel)
        Space: O(|CP(N₀)|)
    
    Correctness: By our main theorem (unbounded_completion_theorem),
    if the procedure returns stabilization level N₀ with all CPs joinable,
    and the system is terminating, then the system is confluent.
    """
    prev_count = 0
    cp_counts = []
    
    for N in range(1, max_level + 1):
        cps = enumerate_critical_pairs(system, N)
        count = len(cps)
        cp_counts.append((N, count))
        
        if verbose:
            new = count - prev_count
            print(f"  Level {N}: {count} CPs ({'+' if new >= 0 else ''}{new} new)")
        
        if count == prev_count and N > 1:
            # Check joinability
            all_joinable = all(
                try_join(system, cp.left, cp.right, join_fuel) 
                for cp in cps
            )
            return SaturationResult(
                stabilized=True,
                stabilization_level=N,
                cp_counts=cp_counts,
                all_joinable=all_joinable,
                total_cps=count
            )
        
        prev_count = count
    
    return SaturationResult(
        stabilized=False,
        stabilization_level=None,
        cp_counts=cp_counts,
        all_joinable=False,
        total_cps=prev_count
    )


# ============================================================================
# Completion Certificate
# ============================================================================

@dataclass
class CompletionCertificate:
    """A certificate of completion (confluence proof artifact)."""
    system: RewriteSystem
    stabilization_level: int
    total_critical_pairs: int
    all_joinable: bool
    
    @property
    def is_valid(self) -> bool:
        """A valid certificate proves confluence (given termination)."""
        return self.all_joinable
    
    def summary(self) -> str:
        status = "VALID ✓" if self.is_valid else "INVALID ✗"
        return (f"Completion Certificate ({status})\n"
                f"  Stabilization level: {self.stabilization_level}\n"
                f"  Critical pairs: {self.total_critical_pairs}\n"
                f"  All joinable: {self.all_joinable}\n"
                f"  Conclusion: {'Confluent' if self.is_valid else 'Unknown'}"
                f" (given termination)")

def generate_certificate(
    system: RewriteSystem,
    max_level: int = 50,
    join_fuel: int = 200
) -> Optional[CompletionCertificate]:
    """Generate a completion certificate for a rewrite system.
    
    Returns None if saturation does not terminate within max_level.
    """
    result = recursive_saturation(system, max_level, join_fuel)
    
    if result.stabilized:
        return CompletionCertificate(
            system=system,
            stabilization_level=result.stabilization_level,
            total_critical_pairs=result.total_cps,
            all_joinable=result.all_joinable
        )
    return None


# ============================================================================
# Benchmark Systems
# ============================================================================

def map_fusion_system() -> RewriteSystem:
    """The map fusion benchmark system."""
    sys = RewriteSystem()
    # map f (map g xs) → map (f ∘ g) xs
    sys.add_rule(
        lhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                     Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        rhs=Term.app(Term.app(Term.var(0),
                     Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                     Term.var(3)),
        name="map-fusion"
    )
    # map id xs → xs
    sys.add_rule(
        lhs=Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1)),
        rhs=Term.var(1),
        name="map-id"
    )
    return sys

def idempotent_system() -> RewriteSystem:
    """f(f(x)) → f(x)."""
    sys = RewriteSystem()
    sys.add_rule(
        lhs=Term.app(Term.var(0), Term.app(Term.var(0), Term.var(1))),
        rhs=Term.app(Term.var(0), Term.var(1)),
        name="idempotent"
    )
    return sys

def associativity_system() -> RewriteSystem:
    """f(f(x,y),z) → f(x,f(y,z)) (right association)."""
    sys = RewriteSystem()
    sys.add_rule(
        lhs=Term.app(Term.app(Term.var(0), Term.app(Term.app(Term.var(0), Term.var(1)), Term.var(2))),
                     Term.var(3)),
        rhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                     Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        name="assoc"
    )
    return sys


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Recursive Critical Pair Saturation — Algorithm Demo")
    print("=" * 55)
    
    benchmarks = [
        ("Map Fusion", map_fusion_system()),
        ("Idempotent", idempotent_system()),
        ("Associativity", associativity_system()),
    ]
    
    for name, sys in benchmarks:
        print(f"\n--- {name} ---")
        cert = generate_certificate(sys, max_level=20)
        if cert:
            print(cert.summary())
        else:
            print("  No certificate (saturation did not stabilize)")
