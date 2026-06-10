#!/usr/bin/env python3
"""
Algorithms for De Bruijn Lambda Calculus

Implements verified algorithms from the research paper:
1. Simultaneous substitution (σ-algebra)
2. Complete development (Takahashi's star-translation)
3. Parallel reduction enumeration
4. Confluence testing via diamond property

All algorithms correspond to formally verified Lean 4 definitions.
"""

from demo import (
    Term, Var, App, Lam,
    rename, lift_ren, shift1,
    subst_env, lift_subst, scons, ids, subst0,
    develop, beta_step, all_parallel_reducts,
    size, redex_count, is_closed, enumerate_terms
)
from typing import Callable


# ─── Simultaneous Substitution Algebra ───────────────────────────────────────

SubstEnv = Callable[[int], Term]

def compose_subst(sigma: SubstEnv, tau: SubstEnv) -> SubstEnv:
    """Compose two substitution environments: (σ ∘ₛ τ)(k) = σ(τ(k)).

    This is the key algebraic operation. The formally verified fusion lemma
    states: substEnv σ (substEnv τ t) = substEnv (compose_subst σ τ) t

    Time complexity: O(1) for the composition itself; application to a term
    is O(n * m) where n = size of term, m = size of substituted terms.
    """
    return lambda k: subst_env(sigma, tau(k))

def subst_at(k: int, s: Term) -> SubstEnv:
    """Create a substitution environment that replaces variable k with s
    and decrements variables above k.

    Corresponds to the Lean definition:
    fun n => if n < k then .var n else if n = k then s else .var (n - 1)
    """
    def sigma(n):
        if n < k:
            return Var(n)
        elif n == k:
            return s
        else:
            return Var(n - 1)
    return sigma


# ─── Normalization ───────────────────────────────────────────────────────────

def normalize(t: Term, max_steps: int = 1000) -> tuple[Term, int]:
    """Normalize a term by repeated leftmost-outermost beta reduction.

    Returns (normal_form, steps) or (last_term, max_steps) if not terminating.

    The Church-Rosser theorem guarantees: if normalization succeeds from two
    different starting points that are beta-equivalent, the results are
    alpha-equivalent (identical in de Bruijn representation).
    """
    steps = 0
    while steps < max_steps:
        r = beta_step(t)
        if r is None:
            return (t, steps)
        t = r
        steps += 1
    return (t, steps)


def normalize_via_develop(t: Term, max_steps: int = 100) -> tuple[Term, int]:
    """Normalize by iterated complete development.

    Each step contracts ALL redexes simultaneously. This is a parallel
    reduction strategy that converges faster than sequential reduction
    (measured in number of development steps, not total work).

    The triangle property ensures this always reaches the same normal
    form as any other reduction strategy (when one exists).
    """
    steps = 0
    while steps < max_steps:
        dt = develop(t)
        if dt == t:  # Fixed point = normal form
            return (t, steps)
        t = dt
        steps += 1
    return (t, steps)


# ─── Diamond Property Verification ──────────────────────────────────────────

def verify_diamond(t: Term) -> tuple[bool, dict]:
    """Verify the diamond property for all pairs of parallel reducts of t.

    For each pair (u, v) of parallel reducts of t, checks that there
    exists w such that u ⇒ w and v ⇒ w.

    The formally verified theorem guarantees this always succeeds,
    with w = develop(t).

    Returns (success, statistics).
    """
    dev_t = develop(t)
    reducts = all_parallel_reducts(t)
    pairs_checked = 0
    all_pass = True

    for u in reducts:
        u_reducts = set()
        for r in all_parallel_reducts(u):
            u_reducts.add(repr(r))
        if repr(dev_t) not in u_reducts:
            all_pass = False
        pairs_checked += 1

    return (all_pass, {
        "term": repr(t),
        "develop": repr(dev_t),
        "num_reducts": len(reducts),
        "pairs_checked": pairs_checked,
        "all_converge_to_develop": all_pass
    })


# ─── Confluence Testing ─────────────────────────────────────────────────────

def test_confluence_exhaustive(max_size: int = 6) -> dict:
    """Exhaustively test confluence for all closed terms up to given size.

    For each term t and all pairs of parallel reducts (u, v),
    verifies that u and v can be joined.

    Returns detailed statistics.
    """
    terms = [t for t in enumerate_terms(max_size) if is_closed(t)]
    total_terms = len(terms)
    total_pairs = 0
    all_pass = True
    max_reducts = 0

    for t in terms:
        success, stats = verify_diamond(t)
        total_pairs += stats["pairs_checked"]
        max_reducts = max(max_reducts, stats["num_reducts"])
        if not success:
            all_pass = False

    return {
        "max_size": max_size,
        "total_closed_terms": total_terms,
        "total_diamond_checks": total_pairs,
        "max_parallel_reducts": max_reducts,
        "all_passed": all_pass
    }


if __name__ == "__main__":
    print("Confluence Testing")
    print("=" * 50)

    for sz in range(3, 8):
        result = test_confluence_exhaustive(sz)
        status = "✓" if result["all_passed"] else "✗"
        print(f"  Size ≤ {sz}: {result['total_closed_terms']:>5} terms, "
              f"{result['total_diamond_checks']:>6} checks — {status}")

    print("\nNormalization Comparison")
    print("=" * 50)
    t = App(App(Lam(Lam(Var(1))), Lam(Var(0))), Lam(App(Var(0), Var(0))))
    print(f"  Term: {t}")
    nf1, s1 = normalize(t)
    nf2, s2 = normalize_via_develop(t)
    print(f"  Sequential:  {nf1}  ({s1} steps)")
    print(f"  Development: {nf2}  ({s2} dev steps)")
    print(f"  Same result: {nf1 == nf2}")
