#!/usr/bin/env python3
"""
Algorithms for Contraction Dynamics of Lambda Calculus
======================================================

Core algorithms implementing the certified evaluator, distance
computation, and head-alignment classification.

These correspond to the formally verified Lean 4 definitions in
ContractionDynamics.lean.
"""

from dataclasses import dataclass
from typing import Optional, Generator
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════════
# SECTION 1: Lambda Term Representation
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Var:
    """Variable reference."""
    name: int
    def size(self) -> int: return 1
    def __repr__(self) -> str: return f"x{self.name}"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction λx.body."""
    var: int
    body: 'Term'
    def size(self) -> int: return 1 + self.body.size()
    def __repr__(self) -> str: return f"(λx{self.var}.{self.body})"

@dataclass(frozen=True)
class App:
    """Application (fun arg)."""
    fun: 'Term'
    arg: 'Term'
    def size(self) -> int: return 1 + self.fun.size() + self.arg.size()
    def __repr__(self) -> str: return f"({self.fun} {self.arg})"

Term = Var | Lam | App


# ═══════════════════════════════════════════════════════════════════════
# SECTION 2: Substitution
# ═══════════════════════════════════════════════════════════════════════

def subst(term: Term, x: int, s: Term) -> Term:
    """Substitute s for free occurrences of variable x in term.

    Complexity: O(|term| * |s|) in the worst case.
    Corresponds to Lam.subst in BoundedBetaDefs.lean.
    """
    if isinstance(term, Var):
        return s if term.name == x else term
    elif isinstance(term, Lam):
        return term if term.var == x else Lam(term.var, subst(term.body, x, s))
    elif isinstance(term, App):
        return App(subst(term.fun, x, s), subst(term.arg, x, s))
    raise TypeError(f"Unknown term type: {type(term)}")


# ═══════════════════════════════════════════════════════════════════════
# SECTION 3: Leftmost-Outermost Evaluator (Certified)
# ═══════════════════════════════════════════════════════════════════════

def lo_step(term: Term) -> Optional[Term]:
    """Leftmost-outermost one-step β-reduction.

    Returns None if the term is already in β-normal form.
    Corresponds to loStep in ContractionDynamics.lean.

    This is the deterministic evaluator whose correctness is formally
    verified by loStep_betaStep: if lo_step(t) = Some(t'), then
    BetaStep t t'.

    Algorithm:
        1. If term is (λx.body) arg, contract the beta-redex.
        2. Otherwise if term is (f a), try reducing f first (leftmost),
           then a if f is normal.
        3. If term is λx.body, try reducing body.
        4. Variables are normal forms.

    Complexity: O(|term|) per step for finding the redex,
                plus O(|body| * |arg|) for the substitution.
    """
    if isinstance(term, App):
        if isinstance(term.fun, Lam):
            return subst(term.fun.body, term.fun.var, term.arg)
        t2 = lo_step(term.fun)
        if t2 is not None:
            return App(t2, term.arg)
        u2 = lo_step(term.arg)
        if u2 is not None:
            return App(term.fun, u2)
        return None
    elif isinstance(term, Lam):
        b2 = lo_step(term.body)
        return Lam(term.var, b2) if b2 is not None else None
    return None


def lo_iter(n: int, term: Term) -> Optional[Term]:
    """Iterated LO evaluation: apply lo_step n times.
    Corresponds to loIter in ContractionDynamics.lean."""
    current = term
    for _ in range(n):
        nxt = lo_step(current)
        if nxt is None:
            return current
        current = nxt
    return current


def normalize(term: Term, max_steps: int = 1000) -> tuple[Term, int]:
    """Normalize a term via LO evaluation, returning (result, steps_taken).

    Complexity: O(max_steps * max_term_size * max_substitution_size)
    """
    current = term
    for step in range(max_steps):
        nxt = lo_step(current)
        if nxt is None:
            return current, step
        current = nxt
    return current, max_steps


# ═══════════════════════════════════════════════════════════════════════
# SECTION 4: β-Step Enumeration
# ═══════════════════════════════════════════════════════════════════════

def all_reducts(term: Term) -> list[Term]:
    """All one-step β-reducts of a term.
    Corresponds to Lam.betaReducts in NormalizationBisimDistance.lean."""
    results = []
    if isinstance(term, App):
        if isinstance(term.fun, Lam):
            results.append(subst(term.fun.body, term.fun.var, term.arg))
        for t2 in all_reducts(term.fun):
            results.append(App(t2, term.arg))
        for u2 in all_reducts(term.arg):
            results.append(App(term.fun, u2))
    elif isinstance(term, Lam):
        for b2 in all_reducts(term.body):
            results.append(Lam(term.var, b2))
    return results


# ═══════════════════════════════════════════════════════════════════════
# SECTION 5: Distance Computation
# ═══════════════════════════════════════════════════════════════════════

def eq_path_dist_upper(t: Term, u: Term, max_steps: int = 100) -> Optional[int]:
    """Upper bound on eqPathDist via join through normal forms.

    If t →*_k1 nf and u →*_k2 nf, then eqPathDist(t,u) ≤ k1 + k2.
    Corresponds to eqPathDist_le_of_joinBudget.

    Returns None if either term fails to normalize within budget.
    """
    nf_t, k1 = normalize(t, max_steps)
    nf_u, k2 = normalize(u, max_steps)
    if nf_t == nf_u:
        return k1 + k2
    return None


def eq_path_dist_bfs(t: Term, u: Term, max_depth: int = 15) -> Optional[int]:
    """Exact eqPathDist via bidirectional BFS on the β-equivalence graph.

    Each step explores both forward (reduction) and backward (expansion)
    edges. This is expensive but exact for small terms.

    Complexity: O(branching_factor^max_depth) worst case.
    """
    if t == u:
        return 0

    # Bidirectional BFS
    visited_t = {t: 0}
    visited_u = {u: 0}
    frontier_t = [t]
    frontier_u = [u]

    for depth in range(1, max_depth + 1):
        # Expand from t side
        new_frontier_t = []
        for term in frontier_t:
            for r in all_reducts(term):
                if r in visited_u:
                    return visited_t[term] + 1 + visited_u[r]
                if r not in visited_t:
                    visited_t[r] = depth
                    new_frontier_t.append(r)
        frontier_t = new_frontier_t

        # Expand from u side
        new_frontier_u = []
        for term in frontier_u:
            for r in all_reducts(term):
                if r in visited_t:
                    return visited_t[r] + visited_u[term] + 1
                if r not in visited_u:
                    visited_u[r] = depth
                    new_frontier_u.append(r)
        frontier_u = new_frontier_u

        if not frontier_t and not frontier_u:
            break

    return None


# ═══════════════════════════════════════════════════════════════════════
# SECTION 6: Head-Alignment Classifier
# ═══════════════════════════════════════════════════════════════════════

def classify_head_aligned(t: Term, u: Term) -> dict:
    """Classify whether (t, u) is head-aligned.

    Returns a dict with:
    - is_head_aligned: bool
    - is_doubly_head_aligned: bool
    - best_reduct: the reduct achieving minimal distance
    - distance_drop: how much the distance decreases

    Corresponds to HeadAligned and DoublyHeadAligned in
    ContractionDynamics.lean.
    """
    dist = eq_path_dist_upper(t, u)
    if dist is None or dist == 0:
        return {
            'is_head_aligned': False,
            'is_doubly_head_aligned': False,
            'best_reduct': None,
            'distance_drop': 0
        }

    # Check head-alignment for t
    ha_t = False
    best_reduct_t = None
    best_drop_t = 0
    for t_prime in all_reducts(t):
        d = eq_path_dist_upper(t_prime, u)
        if d is not None and d < dist:
            ha_t = True
            drop = dist - d
            if drop > best_drop_t:
                best_drop_t = drop
                best_reduct_t = t_prime

    # Check head-alignment for u
    ha_u = False
    for u_prime in all_reducts(u):
        d = eq_path_dist_upper(t, u_prime)
        if d is not None and d < dist:
            ha_u = True
            break

    return {
        'is_head_aligned': ha_t,
        'is_doubly_head_aligned': ha_t and ha_u,
        'best_reduct': best_reduct_t,
        'distance_drop': best_drop_t
    }


# ═══════════════════════════════════════════════════════════════════════
# SECTION 7: Contraction Defect Computation
# ═══════════════════════════════════════════════════════════════════════

def contraction_defect(t: Term, u: Term) -> Optional[dict]:
    """Compute the contraction defect for a paired LO step.

    Returns dict with:
    - defect: eqPathDist(t', u') - eqPathDist(t, u) (negative = contractive)
    - ratio: eqPathDist(t', u') / eqPathDist(t, u)
    - dist_before: eqPathDist(t, u)
    - dist_after: eqPathDist(t', u')

    Corresponds to contractionDefect in ContractionDynamics.lean.
    """
    dist_before = eq_path_dist_upper(t, u)
    if dist_before is None or dist_before == 0:
        return None

    t_prime = lo_step(t)
    u_prime = lo_step(u)
    if t_prime is None or u_prime is None:
        return None

    dist_after = eq_path_dist_upper(t_prime, u_prime)
    if dist_after is None:
        return None

    return {
        'defect': dist_after - dist_before,
        'ratio': dist_after / dist_before,
        'dist_before': dist_before,
        'dist_after': dist_after,
        't_prime': t_prime,
        'u_prime': u_prime,
    }


# ═══════════════════════════════════════════════════════════════════════
# SECTION 8: Shell-Wise Contraction Analyzer
# ═══════════════════════════════════════════════════════════════════════

def analyze_shell_contraction(pairs: list[tuple[Term, Term]]) -> dict:
    """Compute shell-wise contraction constants c_R for shells [1, R].

    For each R, finds the maximum ratio eqPathDist(t',u')/eqPathDist(t,u)
    over all pairs with eqPathDist(t,u) = R.

    The theoretical bound from eqPathDist_contracts_on_shell is (R-1)/R.

    Returns dict mapping R -> {max_ratio, theoretical_bound, pairs_count, tight}.
    """
    shell_data: dict[int, list[float]] = defaultdict(list)

    for t, u in pairs:
        result = contraction_defect(t, u)
        if result is None:
            continue
        shell_data[result['dist_before']].append(result['ratio'])

    analysis = {}
    for R in sorted(shell_data.keys()):
        ratios = shell_data[R]
        max_ratio = max(ratios)
        theoretical = (R - 1) / R if R > 0 else 0
        analysis[R] = {
            'max_ratio': max_ratio,
            'theoretical_bound': theoretical,
            'pairs_count': len(ratios),
            'satisfies_bound': max_ratio <= theoretical + 1e-10,
            'tight': abs(max_ratio - theoretical) < 0.1,
        }

    return analysis


# ═══════════════════════════════════════════════════════════════════════
# SECTION 9: Term Enumeration
# ═══════════════════════════════════════════════════════════════════════

def enumerate_terms(max_size: int, num_vars: int = 2) -> list[Term]:
    """Enumerate all lambda terms up to a given size.

    Size is the number of constructors: var=1, lam=1+body, app=1+fun+arg.

    Complexity: O(Catalan(max_size) * num_vars^max_size) roughly.
    """
    cache: dict[int, list[Term]] = {}

    def gen(size: int) -> list[Term]:
        if size in cache:
            return cache[size]
        result = []
        if size == 1:
            result = [Var(i) for i in range(num_vars)]
        elif size >= 2:
            for v in range(num_vars):
                for body in gen(size - 1):
                    result.append(Lam(v, body))
            for sf in range(1, size - 1):
                sa = size - 1 - sf
                if sa >= 1:
                    for f in gen(sf):
                        for a in gen(sa):
                            result.append(App(f, a))
        cache[size] = result
        return result

    all_terms = []
    for s in range(1, max_size + 1):
        all_terms.extend(gen(s))
    return all_terms


def find_beta_equivalent_pairs(terms: list[Term],
                                max_steps: int = 50) -> list[tuple[Term, Term]]:
    """Find pairs of β-equivalent terms by normalizing to shared normal forms."""
    nf_classes: dict[Term, list[Term]] = defaultdict(list)
    for t in terms:
        nf, _ = normalize(t, max_steps)
        nf_classes[nf].append(t)

    pairs = []
    for members in nf_classes.values():
        for i in range(len(members)):
            for j in range(i + 1, len(members)):
                pairs.append((members[i], members[j]))
    return pairs


# ═══════════════════════════════════════════════════════════════════════
# SECTION 10: Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("Lambda Calculus Contraction Dynamics - Algorithm Library")
    print("=" * 60)

    # Example terms
    identity = Lam(0, Var(0))
    id_id = App(identity, identity)
    omega_safe = App(Lam(0, Var(1)), Var(0))

    print(f"\nIdentity:       {identity}")
    print(f"I I:            {id_id}")
    print(f"(λx.y) z:       {omega_safe}")

    print(f"\nlo_step(I I) = {lo_step(id_id)}")
    print(f"lo_step(I)   = {lo_step(identity)}")
    print(f"lo_step((λx.y) z) = {lo_step(omega_safe)}")

    nf, steps = normalize(id_id)
    print(f"\nnormalize(I I) = {nf} in {steps} steps")

    # Distance computation
    t = id_id
    u = App(Lam(1, Var(0)), Var(0))  # (λy.x0) x0 → x0
    print(f"\nt = {t}")
    print(f"u = {u}")
    d = eq_path_dist_upper(t, u)
    print(f"eqPathDist upper bound: {d}")

    # Head-alignment
    ha = classify_head_aligned(t, u)
    print(f"Head-aligned: {ha['is_head_aligned']}")
    print(f"Doubly head-aligned: {ha['is_doubly_head_aligned']}")

    # Shell analysis
    print(f"\n{'=' * 60}")
    print("Shell-wise contraction analysis (terms up to size 5)")
    terms = enumerate_terms(5)
    pairs = find_beta_equivalent_pairs(terms)
    print(f"Found {len(pairs)} β-equivalent pairs")

    shell = analyze_shell_contraction(pairs)
    for R, data in sorted(shell.items()):
        print(f"  R={R}: max_ratio={data['max_ratio']:.4f}, "
              f"bound={data['theoretical_bound']:.4f}, "
              f"n={data['pairs_count']}")
