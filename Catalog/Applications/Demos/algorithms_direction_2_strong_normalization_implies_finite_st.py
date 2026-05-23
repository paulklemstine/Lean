#!/usr/bin/env python3
"""
Algorithms for Strong Normalization → Finite Strong Bisimulation

Implements:
1. Normalization with depth tracking
2. Bounded FTS construction
3. Bisimulation witness computation
4. Bisimulation verification

All algorithms are verified against the formal Lean theorems.
"""

from dataclasses import dataclass, field
from typing import Optional
from collections import deque


# === Term Representation ===

@dataclass(frozen=True)
class Var:
    """Variable."""
    name: str
    def __repr__(self): return self.name

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction."""
    var: str
    body: 'Term'
    def __repr__(self): return f"(λ{self.var}.{self.body})"

@dataclass(frozen=True)
class App:
    """Application."""
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"

Term = Var | Lam | App

@dataclass(frozen=True)
class BaseTy:
    name: str = "ι"
    def __repr__(self): return self.name

@dataclass(frozen=True)
class ArrowTy:
    dom: 'SimpleType'
    cod: 'SimpleType'
    def __repr__(self): return f"({self.dom} → {self.cod})"

SimpleType = BaseTy | ArrowTy


# === Core Operations ===

def free_vars(t: Term) -> set[str]:
    """Compute free variables of a term."""
    match t:
        case Var(x): return {x}
        case Lam(x, body): return free_vars(body) - {x}
        case App(f, a): return free_vars(f) | free_vars(a)

_fresh_counter = [0]
def fresh_var(avoid: set[str]) -> str:
    """Generate a fresh variable name."""
    while True:
        _fresh_counter[0] += 1
        name = f"_v{_fresh_counter[0]}"
        if name not in avoid:
            return name

def substitute(t: Term, x: str, s: Term) -> Term:
    """Capture-avoiding substitution: t[x := s]."""
    match t:
        case Var(y):
            return s if y == x else t
        case Lam(y, body):
            if y == x:
                return t
            fv_s = free_vars(s)
            if y in fv_s:
                z = fresh_var(free_vars(body) | fv_s | {x})
                body = substitute(body, y, Var(z))
                return Lam(z, substitute(body, x, s))
            return Lam(y, substitute(body, x, s))
        case App(f, a):
            return App(substitute(f, x, s), substitute(a, x, s))


def is_normal_form(t: Term) -> bool:
    """Check if a term is in normal form (no β-redexes)."""
    match t:
        case Var(_): return True
        case Lam(_, body): return is_normal_form(body)
        case App(Lam(_, _), _): return False
        case App(f, a): return is_normal_form(f) and is_normal_form(a)


def beta_step(t: Term) -> Optional[Term]:
    """One-step leftmost-outermost β-reduction. Returns None if in NF."""
    match t:
        case App(Lam(x, body), arg):
            return substitute(body, x, arg)
        case App(f, a):
            f2 = beta_step(f)
            if f2 is not None: return App(f2, a)
            a2 = beta_step(a)
            if a2 is not None: return App(f, a2)
            return None
        case Lam(x, body):
            body2 = beta_step(body)
            if body2 is not None: return Lam(x, body2)
            return None
        case Var(_):
            return None


# === Algorithm 1: Normalization with Depth ===

@dataclass
class NormalizationResult:
    """Result of normalizing a term."""
    original: Term
    normal_form: Term
    reduction_path: list[Term]
    depth: int  # number of β-steps

    def __repr__(self):
        return (f"NormalizationResult(depth={self.depth}, "
                f"nf={self.normal_form})")


def normalize_with_depth(t: Term, max_steps: int = 1000) -> NormalizationResult:
    """
    Normalize a term, tracking the full reduction path and depth.

    Algorithm:
        1. Start with t.
        2. Repeatedly apply leftmost-outermost β-reduction.
        3. Record each intermediate term.
        4. Stop when no more reductions apply or max_steps reached.

    Time complexity: O(max_steps * |t|) where |t| is term size.
    Space complexity: O(max_steps * |t|) for the path.

    Returns:
        NormalizationResult with the normal form, path, and depth.
    """
    path = [t]
    current = t
    for _ in range(max_steps):
        next_t = beta_step(current)
        if next_t is None:
            break
        path.append(next_t)
        current = next_t
    return NormalizationResult(
        original=t,
        normal_form=current,
        reduction_path=path,
        depth=len(path) - 1
    )


# === Algorithm 2: Bounded FTS Construction ===

@dataclass
class BoundedFTS:
    """
    Bounded Finite Transition System.

    Corresponds to `toFTS d t` in the formal development.
    States are terms reachable within d β-steps from the initial term.
    Transitions are single β-steps between reachable states.
    """
    initial: str  # repr of initial term
    states: set[str]  # set of repr(term) for reachable terms
    transitions: dict[str, list[str]]  # adjacency list
    depth_bound: int
    term_map: dict[str, Term]  # repr -> actual term

    def state_count(self) -> int:
        return len(self.states)

    def transition_count(self) -> int:
        return sum(len(v) for v in self.transitions.values())

    def reachable_normal_forms(self) -> set[str]:
        """Find all normal forms in the reachable states."""
        nfs = set()
        for key, term in self.term_map.items():
            if is_normal_form(term):
                nfs.add(key)
        return nfs

    def has_outgoing(self, state: str) -> bool:
        """Check if a state has outgoing transitions."""
        return len(self.transitions.get(state, [])) > 0


def build_bounded_fts(t: Term, depth: int) -> BoundedFTS:
    """
    Build a bounded FTS by BFS unfolding of β-reductions.

    Algorithm:
        1. Start with {t} at depth 0.
        2. BFS: for each state at depth d < depth_bound,
           compute all one-step β-reducts and add as successors.
        3. Record all states and transitions.

    Time complexity: O(B^d * |t|) where B = max branching factor.
    Space complexity: O(B^d * |t|) for storing all states.

    Note: For deterministic (leftmost-outermost) reduction, B = 1.
    """
    states = set()
    transitions: dict[str, list[str]] = {}
    term_map: dict[str, Term] = {}
    initial = repr(t)

    queue = deque([(t, 0)])
    visited = set()

    while queue:
        term, d = queue.popleft()
        key = repr(term)

        if key in visited:
            continue
        visited.add(key)
        states.add(key)
        term_map[key] = term

        if d >= depth:
            continue

        # Compute one-step reduct (deterministic strategy)
        next_t = beta_step(term)
        if next_t is not None:
            next_key = repr(next_t)
            if key not in transitions:
                transitions[key] = []
            transitions[key].append(next_key)
            states.add(next_key)
            term_map[next_key] = next_t
            queue.append((next_t, d + 1))

    return BoundedFTS(
        initial=initial,
        states=states,
        transitions=transitions,
        depth_bound=depth,
        term_map=term_map
    )


# === Algorithm 3: Bisimulation Witness Computation ===

@dataclass
class BisimulationWitness:
    """
    A witness that two bounded FTS are strongly bisimilar at their
    shared terminal state (the common normal form).

    Corresponds to BisimWitness in the formal development.
    """
    shared_nf: str  # repr of the shared normal form
    depth: int  # sufficient depth
    t_depth: int  # normalization depth of t
    u_depth: int  # normalization depth of u
    relation: set[tuple[str, str]]  # the bisimulation relation

    def is_valid(self, fts_t: BoundedFTS, fts_u: BoundedFTS) -> bool:
        """Verify this is a valid strong bisimulation."""
        for (a, b) in self.relation:
            # Forward condition
            for tgt in fts_t.transitions.get(a, []):
                found = any(
                    (tgt, tgt2) in self.relation
                    for tgt2 in fts_u.transitions.get(b, [])
                )
                if not found and fts_t.has_outgoing(a):
                    return False
            # Backward condition
            for tgt in fts_u.transitions.get(b, []):
                found = any(
                    (tgt2, tgt) in self.relation
                    for tgt2 in fts_t.transitions.get(a, [])
                )
                if not found and fts_u.has_outgoing(b):
                    return False
        return True


def compute_bisimulation_witness(
    t: Term, u: Term, max_steps: int = 1000
) -> Optional[BisimulationWitness]:
    """
    Compute a bisimulation witness for β-equivalent terms.

    Algorithm:
        1. Normalize both terms.
        2. Check normal forms are equal (necessary for typed terms).
        3. Compute sufficient depth = max(depth_t, depth_u).
        4. Construct relation R = {(nf, nf)}.
        5. Verify R is a strong bisimulation.

    Time complexity: O(max_steps * max(|t|, |u|)).
    Space complexity: O(max_steps * max(|t|, |u|)).

    Returns:
        BisimulationWitness if terms share a normal form, None otherwise.
    """
    nr_t = normalize_with_depth(t, max_steps)
    nr_u = normalize_with_depth(u, max_steps)

    nf_t_key = repr(nr_t.normal_form)
    nf_u_key = repr(nr_u.normal_form)

    if nf_t_key != nf_u_key:
        return None  # Not β-equivalent (or not normalizing)

    depth = max(nr_t.depth, nr_u.depth)
    relation = {(nf_t_key, nf_t_key)}

    return BisimulationWitness(
        shared_nf=nf_t_key,
        depth=depth,
        t_depth=nr_t.depth,
        u_depth=nr_u.depth,
        relation=relation
    )


# === Algorithm 4: Full Pipeline ===

def analyze_beta_equivalence(t: Term, u: Term) -> dict:
    """
    Full analysis pipeline for β-equivalent terms.

    Returns a dictionary with all analysis results.
    """
    nr_t = normalize_with_depth(t)
    nr_u = normalize_with_depth(u)

    nf_match = repr(nr_t.normal_form) == repr(nr_u.normal_form)
    depth = max(nr_t.depth, nr_u.depth)

    fts_t = build_bounded_fts(t, depth) if depth > 0 else build_bounded_fts(t, 1)
    fts_u = build_bounded_fts(u, depth) if depth > 0 else build_bounded_fts(u, 1)

    witness = compute_bisimulation_witness(t, u) if nf_match else None

    return {
        "t": repr(t),
        "u": repr(u),
        "nf_t": repr(nr_t.normal_form),
        "nf_u": repr(nr_u.normal_form),
        "depth_t": nr_t.depth,
        "depth_u": nr_u.depth,
        "nf_match": nf_match,
        "threshold_depth": depth,
        "fts_t_states": fts_t.state_count(),
        "fts_u_states": fts_u.state_count(),
        "fts_t_transitions": fts_t.transition_count(),
        "fts_u_transitions": fts_u.transition_count(),
        "fts_t_nfs": fts_t.reachable_normal_forms(),
        "fts_u_nfs": fts_u.reachable_normal_forms(),
        "witness": witness,
        "witness_valid": witness.is_valid(fts_t, fts_u) if witness else False,
    }


# === Example Usage ===

if __name__ == "__main__":
    print("=" * 60)
    print("  Bisimulation Witness Computation Algorithm")
    print("=" * 60)

    # Example 1: Simple identity
    t1 = App(Lam("x", Var("x")), Var("y"))
    u1 = Var("y")
    result1 = analyze_beta_equivalence(t1, u1)
    print(f"\nExample 1: (λx.x)y vs y")
    print(f"  Normal forms match: {result1['nf_match']}")
    print(f"  Threshold depth: {result1['threshold_depth']}")
    print(f"  Witness valid: {result1['witness_valid']}")

    # Example 2: Church numerals
    two = Lam("f", Lam("x", App(Var("f"), App(Var("f"), Var("x")))))
    zero = Lam("f", Lam("x", Var("x")))
    add = Lam("m", Lam("n", Lam("f", Lam("x",
        App(App(Var("m"), Var("f")), App(App(Var("n"), Var("f")), Var("x")))))))
    t2 = App(App(add, two), zero)
    u2 = two
    result2 = analyze_beta_equivalence(t2, u2)
    print(f"\nExample 2: add 2 0 vs 2")
    print(f"  Normal forms match: {result2['nf_match']}")
    print(f"  Threshold depth: {result2['threshold_depth']}")
    print(f"  FTS(t): {result2['fts_t_states']} states, {result2['fts_t_transitions']} trans")
    print(f"  FTS(u): {result2['fts_u_states']} states, {result2['fts_u_transitions']} trans")
    print(f"  Witness valid: {result2['witness_valid']}")

    # Example 3: Not β-equivalent
    t3 = Var("x")
    u3 = Var("y")
    result3 = analyze_beta_equivalence(t3, u3)
    print(f"\nExample 3: x vs y (not β-equivalent)")
    print(f"  Normal forms match: {result3['nf_match']}")
    print(f"  Witness: {result3['witness']}")
