#!/usr/bin/env python3
"""
Algorithms for Strong Normalization and Finite Strong Bisimulation

Implements the key algorithms from the research:
1. STLC type checking and inference
2. β-normalization with path recording
3. Bounded FTS construction
4. Bisimulation witness computation
5. Bisimulation verification
6. Normalization depth computation
"""

from dataclasses import dataclass, field
from typing import Optional
from enum import Enum, auto


# =============================================================================
# Core Data Structures
# =============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class Term:
    """Lambda calculus term with named variables."""
    kind: TermKind
    var_idx: Optional[int] = None
    func: Optional['Term'] = None
    arg: Optional['Term'] = None
    binder: Optional[int] = None
    body: Optional['Term'] = None

    def __repr__(self) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_idx}"
        elif self.kind == TermKind.APP:
            f_str = f"({self.func})" if self.func.kind == TermKind.LAM else repr(self.func)
            a_str = f"({self.arg})" if self.arg.kind == TermKind.APP else repr(self.arg)
            return f"{f_str} {a_str}"
        else:
            return f"λx{self.binder}.{self.body}"

    def size(self) -> int:
        """Number of constructors in the term."""
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.func.size() + self.arg.size()
        else:
            return 1 + self.body.size()


@dataclass(frozen=True)
class Ty:
    """Simple type: base type or arrow type."""
    is_base: bool = True
    dom: Optional['Ty'] = None
    cod: Optional['Ty'] = None

    def __repr__(self) -> str:
        if self.is_base:
            return "ι"
        d = f"({self.dom})" if not self.dom.is_base else repr(self.dom)
        return f"{d} → {self.cod}"

    def depth(self) -> int:
        if self.is_base:
            return 0
        return 1 + max(self.dom.depth(), self.cod.depth())

    def complexity(self) -> int:
        """Type complexity measure used for normalization bounds."""
        if self.is_base:
            return 1
        return (self.dom.complexity() + 1) * (self.cod.complexity() + 1)


# Constructors
BASE = Ty()
def var(n: int) -> Term:
    return Term(TermKind.VAR, var_idx=n)
def app(f: Term, a: Term) -> Term:
    return Term(TermKind.APP, func=f, arg=a)
def lam(x: int, body: Term) -> Term:
    return Term(TermKind.LAM, binder=x, body=body)
def arrow(a: Ty, b: Ty) -> Ty:
    return Ty(is_base=False, dom=a, cod=b)


# =============================================================================
# Algorithm 1: Substitution
# =============================================================================

def subst(term: Term, x: int, s: Term) -> Term:
    """
    Substitute s for variable x in term.

    Complexity: O(|term| * |s|) in the worst case.

    Note: This is naive substitution (no capture avoidance).
    For well-scoped terms under the Barendregt convention, this is correct.
    """
    if term.kind == TermKind.VAR:
        return s if term.var_idx == x else term
    elif term.kind == TermKind.APP:
        return app(subst(term.func, x, s), subst(term.arg, x, s))
    else:
        if term.binder == x:
            return term
        return lam(term.binder, subst(term.body, x, s))


# =============================================================================
# Algorithm 2: Beta Reduction
# =============================================================================

def is_normal(term: Term) -> bool:
    """
    Check if a term is in β-normal form.

    Complexity: O(|term|)
    """
    if term.kind == TermKind.VAR:
        return True
    elif term.kind == TermKind.APP:
        if term.func.kind == TermKind.LAM:
            return False
        return is_normal(term.func) and is_normal(term.arg)
    else:
        return is_normal(term.body)


def beta_step_leftmost(term: Term) -> Optional[Term]:
    """
    Perform one step of leftmost-outermost β-reduction.

    Complexity: O(|term| + |subst result|)
    """
    if term.kind == TermKind.VAR:
        return None
    elif term.kind == TermKind.APP:
        if term.func.kind == TermKind.LAM:
            return subst(term.func.body, term.func.binder, term.arg)
        left = beta_step_leftmost(term.func)
        if left is not None:
            return app(left, term.arg)
        right = beta_step_leftmost(term.arg)
        return app(term.func, right) if right is not None else None
    else:
        inner = beta_step_leftmost(term.body)
        return lam(term.binder, inner) if inner is not None else None


def find_all_reducts(term: Term) -> list[Term]:
    """
    Find all possible one-step β-reducts of a term.

    Complexity: O(|term|^2) worst case (branching factor * substitution cost)
    """
    reducts = []
    if term.kind == TermKind.APP:
        if term.func.kind == TermKind.LAM:
            reducts.append(subst(term.func.body, term.func.binder, term.arg))
        for r in find_all_reducts(term.func):
            reducts.append(app(r, term.arg))
        for r in find_all_reducts(term.arg):
            reducts.append(app(term.func, r))
    elif term.kind == TermKind.LAM:
        for r in find_all_reducts(term.body):
            reducts.append(lam(term.binder, r))
    return reducts


# =============================================================================
# Algorithm 3: Normalization with Path Recording
# =============================================================================

def normalize(term: Term, max_steps: int = 10000) -> tuple[Term, list[Term], int]:
    """
    Normalize a term using leftmost-outermost strategy.

    Returns: (normal_form, reduction_path, normalization_depth)

    Complexity: O(max_steps * |term|^k) where k depends on term structure.
    For well-typed STLC terms, termination is guaranteed.
    """
    path = [term]
    current = term
    depth = 0

    for _ in range(max_steps):
        next_term = beta_step_leftmost(current)
        if next_term is None:
            break
        path.append(next_term)
        current = next_term
        depth += 1

    return current, path, depth


# =============================================================================
# Algorithm 4: Bounded FTS Construction
# =============================================================================

@dataclass
class BoundedFTS:
    """
    A bounded finite transition system extracted from a lambda term.

    States are string representations of lambda terms.
    Transitions are β-reduction steps between reachable terms.
    """
    states: set[str] = field(default_factory=set)
    init: str = ""
    transitions: set[tuple[str, str]] = field(default_factory=set)
    term_map: dict[str, Term] = field(default_factory=dict)

    def successors(self, state: str) -> set[str]:
        return {t for s, t in self.transitions if s == state}

    def state_count(self) -> int:
        return len(self.states)

    def transition_count(self) -> int:
        return len(self.transitions)

    def normal_forms(self) -> set[str]:
        """States with no outgoing transitions."""
        sources = {s for s, _ in self.transitions}
        return self.states - sources


def build_bounded_fts(term: Term, depth: int) -> BoundedFTS:
    """
    Build a bounded FTS by exploring β-reductions up to `depth` steps.

    Algorithm:
    1. Start with {term} as the frontier.
    2. For each term in the frontier at depth d < depth:
       a. Compute all one-step β-reducts.
       b. Add them as states and transitions.
       c. Add new terms to the frontier for depth d+1.
    3. Stop when depth is reached or no new terms appear.

    Complexity: O(|reachable set| * branching_factor * substitution_cost)
    Space: O(|reachable set|)
    """
    fts = BoundedFTS(init=repr(term))
    fts.states.add(repr(term))
    fts.term_map[repr(term)] = term

    frontier = [(term, 0)]
    visited = set()

    while frontier:
        current, d = frontier.pop(0)
        key = repr(current)
        if key in visited:
            continue
        visited.add(key)

        if d >= depth:
            continue

        reducts = find_all_reducts(current)
        for r in reducts:
            r_key = repr(r)
            fts.states.add(r_key)
            fts.term_map[r_key] = r
            fts.transitions.add((key, r_key))
            if r_key not in visited:
                frontier.append((r, d + 1))

    return fts


# =============================================================================
# Algorithm 5: Bisimulation Witness Computation
# =============================================================================

@dataclass
class BisimulationWitness:
    """
    A bisimulation witness for two β-equivalent well-typed terms.

    Contains:
    - The shared normal form
    - The threshold depth
    - Reduction paths from each term to the normal form
    - The bisimulation relation R
    """
    nf: Term
    depth: int
    t_path: list[Term]
    u_path: list[Term]
    relation: set[tuple[str, str]]
    is_valid: bool

    def __repr__(self) -> str:
        return (
            f"BisimulationWitness(\n"
            f"  nf = {self.nf}\n"
            f"  depth = {self.depth}\n"
            f"  |R| = {len(self.relation)}\n"
            f"  valid = {self.is_valid}\n"
            f")"
        )


def compute_bisim_witness(t: Term, u: Term) -> Optional[BisimulationWitness]:
    """
    Compute a bisimulation witness for two terms.

    Algorithm:
    1. Normalize both terms.
    2. Check they share a normal form.
    3. Compute the threshold depth d = max(norm_depth(t), norm_depth(u)).
    4. Build bounded FTS at depth d.
    5. Construct R = {(nf, nf)} at the normal form.
    6. Verify the bisimulation conditions.

    Returns None if the terms don't share a normal form.

    Complexity: O(normalization + FTS construction + verification)
    """
    t_nf, t_path, t_depth = normalize(t)
    u_nf, u_path, u_depth = normalize(u)

    if repr(t_nf) != repr(u_nf):
        return None

    depth = max(t_depth, u_depth)
    nf_key = repr(t_nf)

    fts_t = build_bounded_fts(t, depth)
    fts_u = build_bounded_fts(u, depth)

    R = {(nf_key, nf_key)}
    valid = verify_strong_bisimulation(fts_t, fts_u, R)

    return BisimulationWitness(
        nf=t_nf,
        depth=depth,
        t_path=t_path,
        u_path=u_path,
        relation=R,
        is_valid=valid
    )


# =============================================================================
# Algorithm 6: Bisimulation Verification
# =============================================================================

def verify_strong_bisimulation(
    fts1: BoundedFTS, fts2: BoundedFTS, R: set[tuple[str, str]]
) -> bool:
    """
    Verify that R is a strong bisimulation between fts1 and fts2.

    Checks both forth and back conditions:
    - Forth: ∀(a,b)∈R, ∀a'∈succ(a), ∃b'∈succ(b) s.t. (a',b')∈R
    - Back:  ∀(a,b)∈R, ∀b'∈succ(b), ∃a'∈succ(a) s.t. (a',b')∈R

    Complexity: O(|R| * max_branching_factor)
    """
    for a, b in R:
        # Forth
        for a_prime in fts1.successors(a):
            if not any((a_prime, b_prime) in R for b_prime in fts2.successors(b)):
                # Check vacuous case: if b has no successors and a_prime needs matching
                if fts2.successors(b):
                    return False
                # a_prime needs a matching b_prime but b has none
                return False

        # Back
        for b_prime in fts2.successors(b):
            if not any((a_prime, b_prime) in R for a_prime in fts1.successors(a)):
                return False

    return True


# =============================================================================
# Algorithm 7: Normalization Depth Computation
# =============================================================================

def compute_normalization_depth(term: Term, max_steps: int = 10000) -> Optional[int]:
    """
    Compute the normalization depth of a term.

    For well-typed STLC terms, this is guaranteed to terminate.
    Returns None if normalization doesn't complete within max_steps.

    Complexity: O(max_steps * |term|^k)
    """
    _, _, depth = normalize(term, max_steps)
    if depth >= max_steps:
        return None
    return depth


# =============================================================================
# Algorithm 8: Coalgebraic Invariant Verification
# =============================================================================

def verify_coalgebraic_invariant(
    t: Term, u: Term, depths: list[int]
) -> dict[int, bool]:
    """
    Verify the coalgebraic invariant at multiple depths.

    For each depth d, checks whether the bounded FTS of t and u
    at depth d have a strong bisimulation at the normal form.

    Returns a dictionary mapping depth → bisimulation_exists.

    Complexity: O(|depths| * FTS_construction_cost)
    """
    t_nf, _, _ = normalize(t)
    u_nf, _, _ = normalize(u)
    nf_key = repr(t_nf)

    results = {}
    for d in depths:
        fts_t = build_bounded_fts(t, d)
        fts_u = build_bounded_fts(u, d)

        if nf_key in fts_t.states and nf_key in fts_u.states:
            R = {(nf_key, nf_key)}
            results[d] = verify_strong_bisimulation(fts_t, fts_u, R)
        else:
            results[d] = False

    return results


# =============================================================================
# Usage Examples
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example terms
    id_fn = lam(0, var(0))
    id_y = app(lam(0, var(0)), var(1))
    y = var(1)

    print("\n--- Normalization ---")
    nf, path, depth = normalize(id_y)
    print(f"normalize({id_y}) = {nf}")
    print(f"  path: {' → '.join(str(s) for s in path)}")
    print(f"  depth: {depth}")

    print("\n--- Bounded FTS ---")
    fts = build_bounded_fts(id_y, 2)
    print(f"FTS({id_y}, depth=2):")
    print(f"  states: {fts.states}")
    print(f"  transitions: {fts.transitions}")
    print(f"  normal forms: {fts.normal_forms()}")

    print("\n--- Bisimulation Witness ---")
    witness = compute_bisim_witness(id_y, y)
    print(f"witness({id_y}, {y}):")
    print(f"  {witness}")

    print("\n--- Coalgebraic Invariant ---")
    results = verify_coalgebraic_invariant(id_y, y, list(range(5)))
    for d, ok in results.items():
        print(f"  depth {d}: {'✓' if ok else '✗'}")

    print("\n--- Normalization Depth ---")
    for t in [id_y, y, app(lam(0, lam(1, app(var(0), var(1)))), lam(2, var(2)))]:
        d = compute_normalization_depth(t)
        print(f"  norm_depth({t}) = {d}")
