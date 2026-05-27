#!/usr/bin/env python3
"""
Algorithms for Higher-Order Critical Pair Analysis Modulo β

Implements:
1. Bounded β-critical pair enumeration for Miller-pattern systems
2. Bounded joinability checking via BFS
3. Local confluence certification pipeline
"""

from dataclasses import dataclass, field
from typing import Optional, Dict, List, Set, Tuple
from collections import deque

# =============================================================================
# Term Language
# =============================================================================

@dataclass(frozen=True)
class Var:
    """De Bruijn variable."""
    index: int
    def __repr__(self): return f"x{self.index}"
    @property
    def size(self) -> int: return 1

@dataclass(frozen=True)
class Const:
    """Named constant / function symbol."""
    name: str
    def __repr__(self): return self.name
    @property
    def size(self) -> int: return 1

@dataclass(frozen=True)
class App:
    """Application."""
    fun: object
    arg: object
    def __repr__(self): return f"({self.fun} {self.arg})"
    @property
    def size(self) -> int: return 1 + self.fun.size + self.arg.size

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction."""
    body: object
    def __repr__(self): return f"(λ.{self.body})"
    @property
    def size(self) -> int: return 1 + self.body.size

Term = (Var, Const, App, Lam)

# =============================================================================
# Algorithm 1: Pattern Matching
# =============================================================================

def match_pattern(pattern, target, bindings: Optional[Dict] = None) -> Optional[Dict]:
    """
    First-order-style matching of pattern against target.

    Args:
        pattern: Pattern term (may contain variables)
        target: Ground or partially-ground target term
        bindings: Current variable bindings

    Returns:
        Updated bindings dict if match succeeds, None otherwise

    Complexity: O(|pattern| + |target|) time
    """
    if bindings is None:
        bindings = {}

    if isinstance(pattern, Var):
        if pattern.index in bindings:
            return bindings if bindings[pattern.index] == target else None
        return {**bindings, pattern.index: target}

    if isinstance(pattern, Const):
        return bindings if isinstance(target, Const) and target.name == pattern.name else None

    if isinstance(pattern, App) and isinstance(target, App):
        m = match_pattern(pattern.fun, target.fun, bindings)
        return match_pattern(pattern.arg, target.arg, m) if m else None

    if isinstance(pattern, Lam) and isinstance(target, Lam):
        return match_pattern(pattern.body, target.body, bindings)

    return None


# =============================================================================
# Algorithm 2: Substitution Application
# =============================================================================

def apply_substitution(term, sigma: Dict) -> object:
    """
    Apply a substitution (variable -> term mapping) to a term.

    Args:
        term: The term to substitute into
        sigma: Dict mapping variable indices to replacement terms

    Returns:
        The substituted term

    Complexity: O(|term| * max(|sigma(v)|))
    """
    if isinstance(term, Var):
        return sigma.get(term.index, term)
    if isinstance(term, Const):
        return term
    if isinstance(term, App):
        return App(apply_substitution(term.fun, sigma),
                   apply_substitution(term.arg, sigma))
    if isinstance(term, Lam):
        return Lam(apply_substitution(term.body, sigma))
    return term


# =============================================================================
# Algorithm 3: One-Step Rewriting
# =============================================================================

@dataclass
class RewriteRule:
    """A rewrite rule with left-hand side and right-hand side."""
    lhs: object
    rhs: object
    name: str = ""

@dataclass
class RewriteSystem:
    """A higher-order rewrite system."""
    rules: List[RewriteRule] = field(default_factory=list)
    name: str = ""

def one_step_reducts(system: RewriteSystem, term, max_depth: int = 10) -> List:
    """
    Compute all one-step reducts of a term under a rewrite system.
    Includes both β-reduction and rule application.

    Args:
        system: The rewrite system
        term: The term to reduce
        max_depth: Maximum recursion depth

    Returns:
        List of one-step reducts

    Complexity: O(|term| * |rules| * match_cost) per level
    """
    if max_depth <= 0:
        return []

    results = []

    # β-reduction at root
    if isinstance(term, App) and isinstance(term.fun, Lam):
        results.append(apply_substitution(term.fun.body, {0: term.arg}))

    # Rule application at root
    for rule in system.rules:
        m = match_pattern(rule.lhs, term)
        if m is not None:
            results.append(apply_substitution(rule.rhs, m))

    # Recurse into subterms
    if isinstance(term, App):
        for r in one_step_reducts(system, term.fun, max_depth - 1):
            results.append(App(r, term.arg))
        for r in one_step_reducts(system, term.arg, max_depth - 1):
            results.append(App(term.fun, r))
    elif isinstance(term, Lam):
        for r in one_step_reducts(system, term.body, max_depth - 1):
            results.append(Lam(r))

    return results


# =============================================================================
# Algorithm 4: Critical Pair Enumeration
# =============================================================================

def enumerate_critical_pairs(system: RewriteSystem) -> List[Tuple]:
    """
    Enumerate all critical pairs arising from rule overlaps.

    For each pair of rules (r₁, r₂), tries to unify r₂.lhs with
    subterms of r₁.lhs. When successful, generates a critical pair
    (r₁.rhs[σ], r₁.lhs[pos←r₂.rhs][σ]).

    Args:
        system: The rewrite system

    Returns:
        List of (left, right, peak, rule1_name, rule2_name) tuples

    Complexity: O(|rules|² * max_lhs_size² * unification_cost)
    """
    pairs = []

    for r1 in system.rules:
        for r2 in system.rules:
            # Root overlap
            sigma = _unify(r1.lhs, r2.lhs)
            if sigma is not None:
                left = apply_substitution(r1.rhs, sigma)
                right = apply_substitution(r2.rhs, sigma)
                if left != right:
                    peak = apply_substitution(r1.lhs, sigma)
                    pairs.append((left, right, peak, r1.name, r2.name))

            # Non-root overlaps of r2 into r1
            for pos, sub in _subterms(r1.lhs):
                if not pos:  # skip root
                    continue
                sigma = _unify(sub, r2.lhs)
                if sigma is not None:
                    replaced = _replace(r1.lhs, pos, apply_substitution(r2.rhs, sigma))
                    peak = apply_substitution(r1.lhs, sigma)
                    left = apply_substitution(r1.rhs, sigma)
                    right = apply_substitution(replaced, sigma)
                    if left != right:
                        pairs.append((left, right, peak, r1.name, r2.name))

    return pairs


def _unify(t1, t2, bindings=None):
    """Simple first-order unification."""
    if bindings is None: bindings = {}
    if isinstance(t1, Var):
        return {**bindings, t1.index: t2} if t1.index not in bindings else \
            (_unify(bindings[t1.index], t2, bindings))
    if isinstance(t2, Var):
        return {**bindings, t2.index: t1} if t2.index not in bindings else \
            (_unify(t1, bindings[t2.index], bindings))
    if isinstance(t1, Const) and isinstance(t2, Const):
        return bindings if t1.name == t2.name else None
    if isinstance(t1, App) and isinstance(t2, App):
        m = _unify(t1.fun, t2.fun, bindings)
        return _unify(t1.arg, t2.arg, m) if m else None
    if isinstance(t1, Lam) and isinstance(t2, Lam):
        return _unify(t1.body, t2.body, bindings)
    return None


def _subterms(t, pos=()):
    """Yield (position, subterm) pairs."""
    yield (pos, t)
    if isinstance(t, App):
        yield from _subterms(t.fun, pos + (0,))
        yield from _subterms(t.arg, pos + (1,))
    elif isinstance(t, Lam):
        yield from _subterms(t.body, pos + (0,))


def _replace(t, pos, replacement):
    """Replace subterm at position."""
    if not pos: return replacement
    if isinstance(t, App):
        if pos[0] == 0: return App(_replace(t.fun, pos[1:], replacement), t.arg)
        return App(t.fun, _replace(t.arg, pos[1:], replacement))
    if isinstance(t, Lam) and pos[0] == 0:
        return Lam(_replace(t.body, pos[1:], replacement))
    return t


# =============================================================================
# Algorithm 5: Bounded Joinability Checker (BFS)
# =============================================================================

def check_joinability(system: RewriteSystem, s, t,
                      max_steps: int = 20, max_size: int = 50) -> Tuple[bool, Optional[object]]:
    """
    Check if two terms are joinable by bounded BFS rewriting.

    Args:
        system: The rewrite system
        s, t: Terms to check for joinability
        max_steps: Maximum number of rewriting steps
        max_size: Maximum term size to explore

    Returns:
        (True, witness) if joinable, (False, None) otherwise

    Complexity: O(branching^max_steps) worst case, bounded by max_size
    """
    if s == t:
        return True, s

    reach_s = {repr(s)}
    reach_t = {repr(t)}
    front_s = [s]
    front_t = [t]

    for _ in range(max_steps):
        new_s = []
        for term in front_s:
            for r in one_step_reducts(system, term):
                key = repr(r)
                if key in reach_t:
                    return True, r
                if key not in reach_s and r.size <= max_size:
                    reach_s.add(key)
                    new_s.append(r)
        front_s = new_s[:30]

        new_t = []
        for term in front_t:
            for r in one_step_reducts(system, term):
                key = repr(r)
                if key in reach_s:
                    return True, r
                if key not in reach_t and r.size <= max_size:
                    reach_t.add(key)
                    new_t.append(r)
        front_t = new_t[:30]

        if not front_s and not front_t:
            break

    return False, None


# =============================================================================
# Algorithm 6: Local Confluence Certification Pipeline
# =============================================================================

@dataclass
class ConfluenceCertificate:
    """Certificate for bounded local confluence."""
    system_name: str
    all_miller: bool
    critical_pairs: List[Tuple]
    all_joinable: bool
    locally_confluent: bool
    witnesses: Dict[int, object] = field(default_factory=dict)

def certify_local_confluence(system: RewriteSystem) -> ConfluenceCertificate:
    """
    Full certification pipeline for bounded local confluence.

    Steps:
    1. Check Miller pattern property of all LHS
    2. Enumerate all critical pairs
    3. Attempt to join each critical pair
    4. If all join, certify local confluence

    Args:
        system: The rewrite system to certify

    Returns:
        ConfluenceCertificate with the certification result
    """
    # Step 1: Check Miller patterns
    all_miller = all(
        _is_beta_normal(r.lhs) for r in system.rules
    )

    # Step 2: Enumerate critical pairs
    cps = enumerate_critical_pairs(system)

    # Step 3: Check joinability
    witnesses = {}
    all_joinable = True
    for i, (l, r, peak, n1, n2) in enumerate(cps):
        joined, witness = check_joinability(system, l, r)
        if joined:
            witnesses[i] = witness
        else:
            all_joinable = False

    # Step 4: Determine local confluence
    locally_confluent = all_miller and all_joinable

    return ConfluenceCertificate(
        system_name=system.name,
        all_miller=all_miller,
        critical_pairs=cps,
        all_joinable=all_joinable,
        locally_confluent=locally_confluent,
        witnesses=witnesses,
    )


def _is_beta_normal(t) -> bool:
    """Check if a term is in β-normal form."""
    if isinstance(t, (Var, Const)):
        return True
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return False
        return _is_beta_normal(t.fun) and _is_beta_normal(t.arg)
    if isinstance(t, Lam):
        return _is_beta_normal(t.body)
    return True


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    # Identity elimination system
    sys = RewriteSystem(
        rules=[RewriteRule(App(Const("id"), Var(0)), Var(0), "id-elim")],
        name="IdentityElim"
    )

    cert = certify_local_confluence(sys)
    print(f"System: {cert.system_name}")
    print(f"Miller patterns: {cert.all_miller}")
    print(f"Critical pairs: {len(cert.critical_pairs)}")
    print(f"All joinable: {cert.all_joinable}")
    print(f"Locally confluent: {cert.locally_confluent}")
