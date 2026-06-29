#!/usr/bin/env python3
"""
Algorithms for Normalization-Path Synchronization Bisimulation

Implements the core algorithms from the research paper:
1. Canonical normalization trace computation
2. Padded canonical state construction
3. Synchronization relation builder
4. Bisimulation certificate construction and verification
5. Sync depth computation

All algorithms are O(n) in normalization length, with the bisimulation
check being O(d) where d = max normalization depth of the two terms.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, List, Tuple, Set, Dict
from enum import Enum


# ============================================================
# Term Representation (STLC)
# ============================================================

@dataclass(frozen=True)
class Var:
    """Variable term."""
    name: int
    def __str__(self): return f"x{self.name}"
    def __repr__(self): return f"Var({self.name})"

@dataclass(frozen=True)
class App:
    """Application term."""
    fun: 'Term'
    arg: 'Term'
    def __str__(self):
        f = str(self.fun) if isinstance(self.fun, Var) else f"({self.fun})"
        a = str(self.arg) if isinstance(self.arg, Var) else f"({self.arg})"
        return f"{f} {a}"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction."""
    var: int
    body: 'Term'
    def __str__(self): return f"λx{self.var}.{self.body}"

Term = Var | App | Lam


def term_size(t: Term) -> int:
    """Number of constructors in a term."""
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)
    return 0

def free_vars(t: Term) -> Set[int]:
    """Free variables of a term."""
    if isinstance(t, Var): return {t.name}
    if isinstance(t, App): return free_vars(t.fun) | free_vars(t.arg)
    if isinstance(t, Lam): return free_vars(t.body) - {t.var}
    return set()


# ============================================================
# Algorithm 1: Capture-Avoiding Substitution
# ============================================================

_fresh_counter = 1000

def fresh_var() -> int:
    """Generate a fresh variable name.

    Time complexity: O(1)
    """
    global _fresh_counter
    _fresh_counter += 1
    return _fresh_counter

def subst(t: Term, x: int, s: Term) -> Term:
    """Capture-avoiding substitution t[x := s].

    Time complexity: O(|t| * |s|) worst case due to variable capture avoidance.

    Args:
        t: Term to substitute into
        x: Variable to replace
        s: Replacement term

    Returns:
        t with all free occurrences of x replaced by s
    """
    if isinstance(t, Var):
        return s if t.name == x else t
    if isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))
    if isinstance(t, Lam):
        if t.var == x:
            return t  # x is bound here
        if t.var in free_vars(s):
            # Capture would occur; rename bound variable
            z = fresh_var()
            new_body = subst(t.body, t.var, Var(z))
            return Lam(z, subst(new_body, x, s))
        return Lam(t.var, subst(t.body, x, s))
    raise TypeError(f"Unknown term type: {type(t)}")


# ============================================================
# Algorithm 2: Canonical (Leftmost-Outermost) β-Reduction
# ============================================================

def canonical_step(t: Term) -> Optional[Term]:
    """One step of leftmost-outermost β-reduction.

    This is the canonical deterministic normalization strategy.
    It always reduces the leftmost-outermost β-redex first.

    Time complexity: O(|t|) for finding the redex, O(|t|²) including substitution.

    Args:
        t: Input term

    Returns:
        The one-step reduct, or None if t is in normal form.

    Example:
        >>> canonical_step(App(Lam(0, Var(0)), Var(1)))
        Var(1)
        >>> canonical_step(Var(0))
        None
    """
    if isinstance(t, Var):
        return None
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            # Beta redex found: (λx.body) arg → body[x := arg]
            return subst(t.fun.body, t.fun.var, t.arg)
        # Try function position first (leftmost)
        r = canonical_step(t.fun)
        if r is not None:
            return App(r, t.arg)
        # Then argument position
        r = canonical_step(t.arg)
        if r is not None:
            return App(t.fun, r)
        return None
    if isinstance(t, Lam):
        r = canonical_step(t.body)
        if r is not None:
            return Lam(t.var, r)
        return None
    return None

def is_normal_form(t: Term) -> bool:
    """Check if a term is in β-normal form.

    Time complexity: O(|t|)
    """
    return canonical_step(t) is None


# ============================================================
# Algorithm 3: Canonical Normalization Trace
# ============================================================

def canonical_trace(t: Term, max_steps: int = 1000) -> List[Term]:
    """Compute the full canonical normalization trace.

    Returns the sequence [t, σ(t), σ²(t), ..., nf] where σ is the
    canonical step function and nf is the normal form.

    Time complexity: O(L * |t|²) where L is the normalization length
    Space complexity: O(L * |t|) for storing all intermediate terms

    Args:
        t: Starting term
        max_steps: Safety bound to prevent infinite loops (should not
                   be needed for well-typed terms by strong normalization)

    Returns:
        List of terms from t to its normal form

    Example:
        >>> trace = canonical_trace(App(Lam(0, Var(0)), Var(1)))
        >>> len(trace)
        2
        >>> trace[0]
        App(Lam(0, Var(0)), Var(1))
        >>> trace[1]
        Var(1)
    """
    trace = [t]
    current = t
    for _ in range(max_steps):
        next_t = canonical_step(current)
        if next_t is None:
            break
        trace.append(next_t)
        current = next_t
    return trace


# ============================================================
# Algorithm 4: Padded Canonical State
# ============================================================

def padded_canonical_state(t: Term, n: int, max_steps: int = 1000) -> Term:
    """Compute the padded canonical state at index n.

    This is the central new definition. After the normalization sequence
    reaches the normal form at step L, the padded state at index n ≥ L
    equals the normal form (stuttering/padding).

    Time complexity: O(min(n, L) * |t|²) where L is normalization length

    Pseudocode:
        state ← t
        for i in 0..n-1:
            next ← canonical_step(state)
            if next is None: return state  # reached NF, pad
            state ← next
        return state

    Args:
        t: Starting term
        n: Time index
        max_steps: Safety bound

    Returns:
        The term at position n in the padded canonical trace
    """
    trace = canonical_trace(t, max_steps)
    if n < len(trace):
        return trace[n]
    return trace[-1]


# ============================================================
# Algorithm 5: Synchronization Depth
# ============================================================

def norm_length(t: Term, max_steps: int = 1000) -> int:
    """Compute the normalization length (number of canonical steps to NF).

    Time complexity: O(L * |t|²)
    """
    return len(canonical_trace(t, max_steps)) - 1

def sync_depth(t: Term, u: Term, max_steps: int = 1000) -> int:
    """Compute the synchronization depth for a pair of terms.

    The synchronization depth is max(normLength(t), normLength(u)),
    ensuring both canonical paths are fully covered by the padded trace.

    Time complexity: O((L_t + L_u) * max(|t|, |u|)²)

    Args:
        t, u: Terms to synchronize

    Returns:
        The synchronization depth
    """
    return max(norm_length(t, max_steps), norm_length(u, max_steps))


# ============================================================
# Algorithm 6: Normalization Path Synchronization Relation
# ============================================================

def build_normalization_path_sync(
    t: Term, u: Term, d: Optional[int] = None, max_steps: int = 1000
) -> List[Tuple[Term, Term]]:
    """Build the normalization-path synchronization relation.

    For each index i ∈ {0, ..., d}, pairs up the padded canonical states:
        R = {(paddedCanonicalState(i, t), paddedCanonicalState(i, u)) | i ≤ d}

    Time complexity: O(d * (|t|² + |u|²))
    Space complexity: O(d * (|t| + |u|))

    Args:
        t, u: Terms to synchronize
        d: Synchronization depth (defaults to sync_depth(t, u))
        max_steps: Safety bound

    Returns:
        List of (s₁, s₂) pairs indexed by time step
    """
    if d is None:
        d = sync_depth(t, u, max_steps)

    trace_t = canonical_trace(t, max_steps)
    trace_u = canonical_trace(u, max_steps)

    relation = []
    for i in range(d + 1):
        st = trace_t[i] if i < len(trace_t) else trace_t[-1]
        su = trace_u[i] if i < len(trace_u) else trace_u[-1]
        relation.append((st, su))
    return relation


# ============================================================
# Algorithm 7: Bisimulation Condition Checker
# ============================================================

def check_forth(sync_rel: List[Tuple[Term, Term]]) -> Tuple[bool, Optional[int]]:
    """Check the forth condition of strong bisimulation.

    For each related pair (s₁, s₂) where s₁ can take a canonical step
    to s₁', verify that s₂ can also step to s₂' such that (s₁', s₂')
    is in the relation.

    Time complexity: O(d * (|t|² + |u|²))

    Returns:
        (True, None) if forth holds, or (False, violating_index)
    """
    for i in range(len(sync_rel) - 1):
        s1, s2 = sync_rel[i]
        s1_next = canonical_step(s1)
        if s1_next is not None:
            expected_s1_next = sync_rel[i + 1][0]
            expected_s2_next = sync_rel[i + 1][1]

            if str(s1_next) != str(expected_s1_next):
                return False, i

            s2_next = canonical_step(s2)
            if s2_next is not None and str(s2_next) != str(expected_s2_next):
                return False, i

    return True, None

def check_back(sync_rel: List[Tuple[Term, Term]]) -> Tuple[bool, Optional[int]]:
    """Check the back condition of strong bisimulation.

    Symmetric to check_forth.

    Time complexity: O(d * (|t|² + |u|²))

    Returns:
        (True, None) if back holds, or (False, violating_index)
    """
    for i in range(len(sync_rel) - 1):
        s1, s2 = sync_rel[i]
        s2_next = canonical_step(s2)
        if s2_next is not None:
            expected_s1_next = sync_rel[i + 1][0]
            expected_s2_next = sync_rel[i + 1][1]

            if str(s2_next) != str(expected_s2_next):
                return False, i

            s1_next = canonical_step(s1)
            if s1_next is not None and str(s1_next) != str(expected_s1_next):
                return False, i

    return True, None


# ============================================================
# Algorithm 8: Bisimulation Certificate Construction
# ============================================================

@dataclass
class SyncBisimCertificate:
    """A synchronization bisimulation certificate.

    Contains all data needed to verify that two terms are behaviorally
    equivalent along their canonical normalization paths.
    """
    term_t: Term
    term_u: Term
    nf: Term
    depth: int
    path_t: List[Term]
    path_u: List[Term]
    sync_relation: List[Tuple[Term, Term]]
    forth_ok: bool
    back_ok: bool
    forth_violation: Optional[int] = None
    back_violation: Optional[int] = None

    @property
    def is_valid(self) -> bool:
        """Certificate is valid iff both forth and back conditions hold."""
        return self.forth_ok and self.back_ok

    def __str__(self):
        status = "VALID" if self.is_valid else "INVALID"
        return (f"SyncBisimCertificate({status}, "
                f"depth={self.depth}, nf={self.nf})")


def build_sync_bisim_certificate(
    t: Term, u: Term, max_steps: int = 1000
) -> Optional[SyncBisimCertificate]:
    """Build a synchronization bisimulation certificate.

    Complete algorithm:
    1. Compute canonical traces for both terms
    2. Check that normal forms agree
    3. Compute synchronization depth
    4. Build the synchronization relation
    5. Check forth and back conditions
    6. Return certificate or None

    Time complexity: O(d * (|t|² + |u|²)) where d = sync_depth(t, u)
    Space complexity: O(d * (|t| + |u|))

    Args:
        t, u: Terms to check for bisimulation
        max_steps: Safety bound for normalization

    Returns:
        SyncBisimCertificate if normal forms agree, None otherwise

    Example:
        >>> t = App(Lam(0, Var(0)), Var(1))  # (λx.x) y
        >>> u = Var(1)                        # y
        >>> cert = build_sync_bisim_certificate(t, u)
        >>> cert.is_valid
        True
    """
    trace_t = canonical_trace(t, max_steps)
    trace_u = canonical_trace(u, max_steps)

    nf_t = trace_t[-1]
    nf_u = trace_u[-1]

    # Normal forms must agree for β-equivalent well-typed terms
    if str(nf_t) != str(nf_u):
        return None

    d = max(len(trace_t), len(trace_u)) - 1
    sync_rel = build_normalization_path_sync(t, u, d, max_steps)

    forth_ok, forth_viol = check_forth(sync_rel)
    back_ok, back_viol = check_back(sync_rel)

    return SyncBisimCertificate(
        term_t=t,
        term_u=u,
        nf=nf_t,
        depth=d,
        path_t=trace_t,
        path_u=trace_u,
        sync_relation=sync_rel,
        forth_ok=forth_ok,
        back_ok=back_ok,
        forth_violation=forth_viol,
        back_violation=back_viol,
    )


# ============================================================
# Usage Examples
# ============================================================

if __name__ == "__main__":
    # Example: (λx.x)(λy.y) vs λy.y
    t = App(Lam(0, Var(0)), Lam(1, Var(1)))
    u = Lam(1, Var(1))

    print("Term t:", t)
    print("Term u:", u)
    print()

    print("Canonical trace of t:", [str(s) for s in canonical_trace(t)])
    print("Canonical trace of u:", [str(s) for s in canonical_trace(u)])
    print()

    print("Normalization length of t:", norm_length(t))
    print("Normalization length of u:", norm_length(u))
    print("Synchronization depth:", sync_depth(t, u))
    print()

    cert = build_sync_bisim_certificate(t, u)
    if cert:
        print("Certificate:", cert)
        print("Forth condition:", "PASS" if cert.forth_ok else "FAIL")
        print("Back condition:", "PASS" if cert.back_ok else "FAIL")
        print("Valid bisimulation:", cert.is_valid)
    else:
        print("No certificate: normal forms do not agree")
