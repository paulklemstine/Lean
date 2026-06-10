#!/usr/bin/env python3
"""
Applications of Contraction Dynamics
=====================================

Demonstrates practical applications of the contraction dynamics theory
for lambda calculus evaluation strategies:

1. Normalization budget estimation via contraction rates
2. Compiler optimization pass convergence analysis
3. Evaluation strategy comparison
4. Term distance computation for program equivalence
"""

from dataclasses import dataclass
from typing import Optional
from collections import defaultdict

# Import from algorithms
from algorithms import (
    Term, Var, Lam, App, subst,
    lo_step, lo_iter, normalize, all_reducts,
    eq_path_dist_upper, classify_head_aligned,
    contraction_defect, enumerate_terms,
    find_beta_equivalent_pairs
)


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Normalization Budget Estimator
# ═══════════════════════════════════════════════════════════════════════

def estimate_normalization_budget(term: Term, reference: Optional[Term] = None,
                                   max_steps: int = 1000) -> dict:
    """Estimate how many LO steps are needed to normalize a term.

    Uses the contraction dynamics theory: if each step decreases
    eqPathDist by at least 1 (head-aligned case), then the budget
    is at most eqPathDist(term, normal_form).

    If a reference normal form is provided, uses it; otherwise
    computes the normal form.

    Returns:
        dict with budget estimate, actual steps, and quality metrics.
    """
    # Normalize to find actual cost
    nf, actual_steps = normalize(term, max_steps)
    is_nf = lo_step(nf) is None

    # Estimate budget via distance
    if reference is not None:
        dist = eq_path_dist_upper(term, reference)
    else:
        dist = actual_steps  # trivial bound: steps taken = upper bound on distance

    # Track distance decrease during normalization
    current = term
    distances = []
    for step in range(min(actual_steps, 50)):
        d = eq_path_dist_upper(current, nf)
        distances.append(d if d is not None else -1)
        nxt = lo_step(current)
        if nxt is None:
            break
        current = nxt

    # Compute convergence rate
    if len(distances) >= 2 and distances[0] and distances[0] > 0:
        avg_decrease = (distances[0] - (distances[-1] or 0)) / len(distances)
    else:
        avg_decrease = 0

    return {
        'term': str(term),
        'normal_form': str(nf),
        'is_normalized': is_nf,
        'actual_steps': actual_steps,
        'distance_bound': dist,
        'distance_trajectory': distances[:20],
        'avg_decrease_per_step': avg_decrease,
    }


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Optimization Pass Convergence
# ═══════════════════════════════════════════════════════════════════════

def analyze_optimization_convergence(term: Term, max_passes: int = 20) -> dict:
    """Simulate repeated optimization passes and track convergence.

    Models a compiler performing iterative optimization: each pass
    applies one LO reduction step. The contraction dynamics theory
    guarantees convergence to a fixed point (normal form) with
    quantitative rate bounds.

    The key insight is that on bounded-distance shells, the contraction
    constant c = (R-1)/R gives:
        after k passes: distance ≤ ((R-1)/R)^k * R → 0

    Returns convergence trajectory and rate estimates.
    """
    trajectory = []
    current = term
    nf, total_steps = normalize(term, max_passes * 10)

    for pass_num in range(max_passes):
        dist = eq_path_dist_upper(current, nf)
        nxt = lo_step(current)
        is_normal = nxt is None

        trajectory.append({
            'pass': pass_num,
            'term': str(current)[:60],
            'distance_to_nf': dist,
            'is_fixed_point': is_normal,
            'term_size': current.size(),
        })

        if is_normal:
            break
        current = nxt

    # Estimate convergence rate from trajectory
    dists = [t['distance_to_nf'] for t in trajectory if t['distance_to_nf'] is not None and t['distance_to_nf'] > 0]
    if len(dists) >= 2:
        ratios = [dists[i+1] / dists[i] for i in range(len(dists)-1) if dists[i] > 0]
        avg_ratio = sum(ratios) / len(ratios) if ratios else None
    else:
        avg_ratio = None

    return {
        'term': str(term)[:80],
        'trajectory': trajectory,
        'converged': trajectory[-1]['is_fixed_point'] if trajectory else False,
        'steps_to_convergence': len(trajectory) - 1 if trajectory and trajectory[-1]['is_fixed_point'] else None,
        'average_contraction_ratio': avg_ratio,
    }


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Evaluation Strategy Comparison
# ═══════════════════════════════════════════════════════════════════════

def rightmost_innermost_step(term: Term) -> Optional[Term]:
    """Rightmost-innermost one-step β-reduction (alternative strategy)."""
    if isinstance(term, App):
        # Try argument first (innermost)
        u2 = rightmost_innermost_step(term.arg)
        if u2 is not None:
            return App(term.fun, u2)
        # Then function
        t2 = rightmost_innermost_step(term.fun)
        if t2 is not None:
            return App(t2, term.arg)
        # Then beta-redex at this level
        if isinstance(term.fun, Lam):
            return subst(term.fun.body, term.fun.var, term.arg)
        return None
    elif isinstance(term, Lam):
        b2 = rightmost_innermost_step(term.body)
        return Lam(term.var, b2) if b2 is not None else None
    return None


def compare_strategies(terms: list[Term]) -> dict:
    """Compare LO and RI evaluation strategies on a set of terms.

    For each term, measures:
    - Steps to normalize under each strategy
    - Average contraction defect under each strategy

    The theory predicts that LO has better contraction properties
    on head-aligned pairs.
    """
    lo_steps_list = []
    ri_steps_list = []

    for term in terms:
        # LO strategy
        current = term
        lo_count = 0
        for _ in range(200):
            nxt = lo_step(current)
            if nxt is None:
                break
            current = nxt
            lo_count += 1

        # RI strategy
        current = term
        ri_count = 0
        for _ in range(200):
            nxt = rightmost_innermost_step(current)
            if nxt is None:
                break
            current = nxt
            ri_count += 1

        lo_steps_list.append(lo_count)
        ri_steps_list.append(ri_count)

    return {
        'num_terms': len(terms),
        'lo_avg_steps': sum(lo_steps_list) / len(lo_steps_list) if lo_steps_list else 0,
        'ri_avg_steps': sum(ri_steps_list) / len(ri_steps_list) if ri_steps_list else 0,
        'lo_max_steps': max(lo_steps_list) if lo_steps_list else 0,
        'ri_max_steps': max(ri_steps_list) if ri_steps_list else 0,
        'lo_total': sum(lo_steps_list),
        'ri_total': sum(ri_steps_list),
    }


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Program Equivalence via Distance
# ═══════════════════════════════════════════════════════════════════════

def program_equivalence_certificate(t: Term, u: Term) -> dict:
    """Generate a certificate of β-equivalence with quantitative metrics.

    Uses the eqPathDist pseudometric to measure "how different" two
    β-equivalent programs are, and the contraction dynamics to estimate
    how quickly evaluation converges them.
    """
    nf_t, steps_t = normalize(t, 100)
    nf_u, steps_u = normalize(u, 100)

    are_equivalent = nf_t == nf_u
    dist = eq_path_dist_upper(t, u) if are_equivalent else None

    # Convergence trajectory
    if are_equivalent:
        current_t = t
        current_u = u
        convergence = []
        for step in range(min(steps_t + steps_u, 20)):
            d = eq_path_dist_upper(current_t, current_u)
            convergence.append(d)
            if current_t == current_u:
                break
            nt = lo_step(current_t)
            nu = lo_step(current_u)
            current_t = nt if nt is not None else current_t
            current_u = nu if nu is not None else current_u
    else:
        convergence = []

    return {
        'term_1': str(t),
        'term_2': str(u),
        'are_equivalent': are_equivalent,
        'normal_form': str(nf_t) if are_equivalent else None,
        'distance': dist,
        'steps_t': steps_t,
        'steps_u': steps_u,
        'convergence_trajectory': convergence,
        'join_budget': steps_t + steps_u if are_equivalent else None,
    }


# ═══════════════════════════════════════════════════════════════════════
# MAIN DEMONSTRATION
# ═══════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATIONS OF CONTRACTION DYNAMICS")
    print("=" * 70)

    # ─── Application 1: Budget Estimation ────────────────────────────

    print("\n" + "─" * 70)
    print("APPLICATION 1: Normalization Budget Estimation")
    print("─" * 70)

    # Church numerals
    zero = Lam(0, Lam(1, Var(1)))            # λf.λx.x
    one = Lam(0, Lam(1, App(Var(0), Var(1))))  # λf.λx.f x
    succ = Lam(2, Lam(0, Lam(1, App(Var(0), App(App(Var(2), Var(0)), Var(1))))))

    test_terms = [
        ("I I", App(Lam(0, Var(0)), Lam(0, Var(0)))),
        ("(λx.x x)(λy.y)", App(Lam(0, App(Var(0), Var(0))), Lam(1, Var(1)))),
        ("succ 0", App(succ, zero)),
    ]

    for name, term in test_terms:
        result = estimate_normalization_budget(term)
        print(f"\n  Term: {name}")
        print(f"  Normal form: {result['normal_form'][:50]}")
        print(f"  Actual steps: {result['actual_steps']}")
        print(f"  Distance bound: {result['distance_bound']}")
        if result['distance_trajectory']:
            print(f"  Distance trajectory: {result['distance_trajectory'][:10]}")

    # ─── Application 2: Optimization Convergence ────────────────────

    print("\n" + "─" * 70)
    print("APPLICATION 2: Optimization Pass Convergence")
    print("─" * 70)

    complex_term = App(
        Lam(0, App(Var(0), Var(0))),
        App(Lam(1, Var(1)), Var(0))
    )
    result = analyze_optimization_convergence(complex_term)
    print(f"\n  Term: {result['term']}")
    print(f"  Converged: {result['converged']}")
    print(f"  Steps: {result['steps_to_convergence']}")
    print(f"  Avg contraction ratio: {result['average_contraction_ratio']}")
    print(f"\n  Pass trajectory:")
    for entry in result['trajectory']:
        print(f"    Pass {entry['pass']}: dist={entry['distance_to_nf']}, "
              f"size={entry['term_size']}, fixed={entry['is_fixed_point']}")

    # ─── Application 3: Strategy Comparison ─────────────────────────

    print("\n" + "─" * 70)
    print("APPLICATION 3: Evaluation Strategy Comparison")
    print("─" * 70)

    terms = enumerate_terms(5)
    comparison = compare_strategies(terms)
    print(f"\n  Terms analyzed: {comparison['num_terms']}")
    print(f"  LO strategy: avg {comparison['lo_avg_steps']:.2f} steps, "
          f"max {comparison['lo_max_steps']}")
    print(f"  RI strategy: avg {comparison['ri_avg_steps']:.2f} steps, "
          f"max {comparison['ri_max_steps']}")
    print(f"  LO total: {comparison['lo_total']}, RI total: {comparison['ri_total']}")
    if comparison['ri_total'] > 0:
        print(f"  LO/RI ratio: {comparison['lo_total']/comparison['ri_total']:.3f}")

    # ─── Application 4: Equivalence Certificates ────────────────────

    print("\n" + "─" * 70)
    print("APPLICATION 4: Program Equivalence Certificates")
    print("─" * 70)

    # Two β-equivalent programs
    prog1 = App(Lam(0, Var(0)), App(Lam(1, Var(1)), Var(0)))  # I (I x0)
    prog2 = Var(0)  # x0

    cert = program_equivalence_certificate(prog1, prog2)
    print(f"\n  Program 1: {cert['term_1']}")
    print(f"  Program 2: {cert['term_2']}")
    print(f"  Equivalent: {cert['are_equivalent']}")
    print(f"  Distance: {cert['distance']}")
    print(f"  Join budget: {cert['join_budget']}")
    if cert['convergence_trajectory']:
        print(f"  Convergence: {cert['convergence_trajectory']}")

    # Non-equivalent programs
    prog3 = Var(0)
    prog4 = Var(1)
    cert2 = program_equivalence_certificate(prog3, prog4)
    print(f"\n  Program 3: {cert2['term_1']}")
    print(f"  Program 4: {cert2['term_2']}")
    print(f"  Equivalent: {cert2['are_equivalent']}")

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Contraction Dynamics of Lambda Calculus Evaluation
===================================================

Interactive demonstration of how leftmost-outermost (LO) evaluation
creates a dissipative flow on β-equivalence classes. Explores the
contraction ratio eqPathDist(eval(t), eval(u)) / eqPathDist(t, u)
for β-equivalent lambda terms.

Usage:
    python demo.py [--max-size N] [--max-depth D]
"""

import argparse
import itertools
from dataclasses import dataclass
from typing import Optional
from collections import defaultdict


# ─── Lambda Term Representation ──────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """Variable reference."""
    name: int
    def __repr__(self): return f"x{self.name}"
    def size(self): return 1

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction λx.body."""
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}.{self.body})"
    def size(self): return 1 + self.body.size()

@dataclass(frozen=True)
class App:
    """Application (fun arg)."""
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()

Term = Var | Lam | App


# ─── Substitution ────────────────────────────────────────────────────────

def subst(term: Term, x: int, s: Term) -> Term:
    """Substitute s for variable x in term (capture-avoiding not needed for
    our simple named-variable calculus with distinct binders)."""
    if isinstance(term, Var):
        return s if term.name == x else term
    elif isinstance(term, Lam):
        if term.var == x:
            return term  # bound variable shadows
        return Lam(term.var, subst(term.body, x, s))
    elif isinstance(term, App):
        return App(subst(term.fun, x, s), subst(term.arg, x, s))
    raise TypeError


# ─── Leftmost-Outermost Evaluator ────────────────────────────────────────

def lo_step(term: Term) -> Optional[Term]:
    """One step of leftmost-outermost β-reduction. Returns None if normal."""
    if isinstance(term, App):
        if isinstance(term.fun, Lam):
            # Beta redex: (λx.body) arg → body[x := arg]
            return subst(term.fun.body, term.fun.var, term.arg)
        # Try reducing function position first
        t2 = lo_step(term.fun)
        if t2 is not None:
            return App(t2, term.arg)
        # Then argument
        u2 = lo_step(term.arg)
        if u2 is not None:
            return App(term.fun, u2)
        return None
    elif isinstance(term, Lam):
        b2 = lo_step(term.body)
        if b2 is not None:
            return Lam(term.var, b2)
        return None
    return None  # Var is normal


def is_normal(term: Term) -> bool:
    return lo_step(term) is None


def normalize(term: Term, max_steps: int = 1000) -> tuple[Term, int]:
    """Normalize a term, returning (normal_form, steps)."""
    steps = 0
    current = term
    while steps < max_steps:
        nxt = lo_step(current)
        if nxt is None:
            return current, steps
        current = nxt
        steps += 1
    return current, steps


# ─── β-Equivalence Path Distance (BFS) ──────────────────────────────────

def one_step_reducts(term: Term) -> list[Term]:
    """All one-step β-reducts of term."""
    results = []
    if isinstance(term, App):
        if isinstance(term.fun, Lam):
            results.append(subst(term.fun.body, term.fun.var, term.arg))
        for t2 in one_step_reducts(term.fun):
            results.append(App(t2, term.arg))
        for u2 in one_step_reducts(term.arg):
            results.append(App(term.fun, u2))
    elif isinstance(term, Lam):
        for b2 in one_step_reducts(term.body):
            results.append(Lam(term.var, b2))
    return results


def one_step_expansions(term: Term, all_terms: set) -> list[Term]:
    """Terms in all_terms that β-reduce to term in one step."""
    return [t for t in all_terms if term in one_step_reducts(t)]


def eq_path_dist_bfs(t: Term, u: Term, max_depth: int = 20) -> Optional[int]:
    """Compute eqPathDist(t, u) via BFS on the β-equivalence graph.
    Each edge is a single β-step (forward or backward).
    Returns None if distance exceeds max_depth."""
    if t == u:
        return 0

    visited = {t}
    frontier = {t}

    for depth in range(1, max_depth + 1):
        new_frontier = set()
        for term in frontier:
            # Forward steps
            for r in one_step_reducts(term):
                if r == u:
                    return depth
                if r not in visited:
                    visited.add(r)
                    new_frontier.add(r)
            # Backward steps: find terms that reduce to 'term'
            # This is expensive; for small terms we enumerate
            # For practical purposes, we use a bounded approach
        frontier = new_frontier
        if not frontier:
            break

    return None


def eq_path_dist_via_nf(t: Term, u: Term, max_steps: int = 100) -> Optional[int]:
    """Upper bound on eqPathDist via normalization: if t and u normalize to
    the same term, then eqPathDist ≤ steps(t) + steps(u)."""
    nf_t, steps_t = normalize(t, max_steps)
    nf_u, steps_u = normalize(u, max_steps)
    if nf_t == nf_u:
        return steps_t + steps_u
    return None


# ─── Term Enumeration ────────────────────────────────────────────────────

def enumerate_terms(max_size: int, num_vars: int = 2) -> list[Term]:
    """Enumerate lambda terms up to a given size."""
    cache = {}

    def gen(size: int) -> list[Term]:
        if size in cache:
            return cache[size]
        result = []
        if size == 1:
            result = [Var(i) for i in range(num_vars)]
        elif size >= 2:
            # Lambda: size = 1 + body.size
            for v in range(num_vars):
                for body in gen(size - 1):
                    result.append(Lam(v, body))
            # App: size = 1 + fun.size + arg.size
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


# ─── Head-Alignment Classification ──────────────────────────────────────

def is_head_aligned(t: Term, u: Term, dist_tu: int) -> bool:
    """Check if (t, u) is head-aligned: some one-step reduct t' of t
    has eqPathDist(t', u) < dist_tu."""
    if dist_tu <= 0:
        return False
    for t_prime in one_step_reducts(t):
        d = eq_path_dist_via_nf(t_prime, u)
        if d is not None and d < dist_tu:
            return True
    return False


# ─── Main Analysis ───────────────────────────────────────────────────────

def analyze_contraction(max_size: int = 5, max_depth: int = 10):
    """Analyze contraction behavior of LO evaluation on β-equivalent pairs."""
    print("=" * 70)
    print("CONTRACTION DYNAMICS OF LAMBDA CALCULUS EVALUATION")
    print("=" * 70)
    print(f"\nEnumerating terms up to size {max_size}...")

    terms = enumerate_terms(max_size)
    print(f"Generated {len(terms)} terms")

    # Find β-equivalent pairs via shared normal forms
    nf_classes: dict[Term, list[tuple[Term, int]]] = defaultdict(list)
    normalizable = 0
    for t in terms:
        nf, steps = normalize(t, max_steps=50)
        if is_normal(nf):
            nf_classes[nf].append((t, steps))
            normalizable += 1

    print(f"Normalizable terms: {normalizable}")
    print(f"Distinct normal forms: {len(nf_classes)}")

    # Analyze β-equivalent pairs
    pairs_analyzed = 0
    ratios = []
    additive_defects = []
    visible_ratios = []
    non_visible_ratios = []
    shell_data: dict[int, list[float]] = defaultdict(list)
    counterexamples = []
    extremal_pairs = []

    print(f"\nAnalyzing β-equivalent pairs...")

    for nf, members in nf_classes.items():
        if len(members) < 2:
            continue

        for i, (t, steps_t) in enumerate(members):
            for j, (u, steps_u) in enumerate(members):
                if i >= j:
                    continue

                dist_before = steps_t + steps_u  # upper bound via join

                if dist_before == 0:
                    continue

                t_prime = lo_step(t)
                u_prime = lo_step(u)

                if t_prime is None or u_prime is None:
                    continue

                dist_after_bound = eq_path_dist_via_nf(t_prime, u_prime)
                if dist_after_bound is None:
                    continue

                ratio = dist_after_bound / dist_before if dist_before > 0 else 0
                defect = dist_after_bound - dist_before

                pairs_analyzed += 1
                ratios.append(ratio)
                additive_defects.append(defect)
                shell_data[dist_before].append(ratio)

                # Classify visible/non-visible
                ha = is_head_aligned(t, u, dist_before)
                if ha:
                    visible_ratios.append(ratio)
                else:
                    non_visible_ratios.append(ratio)

                if ratio >= 1.0:
                    counterexamples.append((t, u, t_prime, u_prime, ratio, dist_before, dist_after_bound))

                if len(extremal_pairs) < 10 or ratio > min(r for _, _, _, _, r, _, _ in extremal_pairs):
                    extremal_pairs.append((t, u, t_prime, u_prime, ratio, dist_before, dist_after_bound))
                    extremal_pairs.sort(key=lambda x: -x[4])
                    extremal_pairs = extremal_pairs[:10]

    # ─── Results ─────────────────────────────────────────────────────────

    print(f"\n{'─' * 70}")
    print(f"RESULTS")
    print(f"{'─' * 70}")
    print(f"Pairs analyzed: {pairs_analyzed}")

    if ratios:
        print(f"\nContraction Ratios (dist_after / dist_before):")
        print(f"  Min ratio:  {min(ratios):.4f}")
        print(f"  Max ratio:  {max(ratios):.4f}")
        print(f"  Mean ratio: {sum(ratios)/len(ratios):.4f}")
        print(f"  Pairs with ratio < 1 (contractive):    {sum(1 for r in ratios if r < 1)}")
        print(f"  Pairs with ratio = 1 (nonexpansive):   {sum(1 for r in ratios if r == 1.0)}")
        print(f"  Pairs with ratio > 1 (expansive):      {sum(1 for r in ratios if r > 1)}")

    if additive_defects:
        print(f"\nAdditive Defects (dist_after - dist_before):")
        print(f"  Min defect:  {min(additive_defects)}")
        print(f"  Max defect:  {max(additive_defects)}")
        print(f"  Mean defect: {sum(additive_defects)/len(additive_defects):.4f}")

    if visible_ratios:
        print(f"\nHead-Aligned (Visible) Pairs: {len(visible_ratios)}")
        print(f"  Max ratio among visible: {max(visible_ratios):.4f}")
        print(f"  Mean ratio:              {sum(visible_ratios)/len(visible_ratios):.4f}")

    if non_visible_ratios:
        print(f"\nNon-Visible Pairs: {len(non_visible_ratios)}")
        print(f"  Max ratio among non-visible: {max(non_visible_ratios):.4f}")

    print(f"\n{'─' * 70}")
    print(f"SHELL-WISE CONTRACTION CONSTANTS")
    print(f"{'─' * 70}")
    for R in sorted(shell_data.keys()):
        shell_ratios = shell_data[R]
        max_r = max(shell_ratios)
        theoretical = (R - 1) / R if R > 0 else 0
        print(f"  Shell R={R:3d}: max_ratio={max_r:.4f}  "
              f"theoretical_bound={(R-1)/R:.4f}  "
              f"{'✓ CONTRACTIVE' if max_r < 1 else '✗ NOT UNIFORMLY CONTRACTIVE'}")

    if counterexamples:
        print(f"\n{'─' * 70}")
        print(f"COUNTEREXAMPLES TO GLOBAL STRICT CONTRACTION (ratio ≥ 1)")
        print(f"{'─' * 70}")
        for t, u, t2, u2, ratio, db, da in counterexamples[:5]:
            print(f"  t = {t}")
            print(f"  u = {u}")
            print(f"  t' = {t2}")
            print(f"  u' = {u2}")
            print(f"  dist_before={db}, dist_after={da}, ratio={ratio:.4f}")
            print()

    print(f"\n{'─' * 70}")
    print(f"EXTREMAL PAIRS (highest contraction ratio)")
    print(f"{'─' * 70}")
    for t, u, t2, u2, ratio, db, da in extremal_pairs[:5]:
        print(f"  t = {t}")
        print(f"  u = {u}")
        print(f"  ratio = {ratio:.4f} (dist: {db} → {da})")
        print()

    # ─── ASCII Plot ──────────────────────────────────────────────────────

    if ratios:
        print(f"{'─' * 70}")
        print(f"RATIO HISTOGRAM")
        print(f"{'─' * 70}")

        # Simple ASCII histogram
        buckets = 20
        min_r, max_r = min(ratios), max(ratios)
        if max_r > min_r:
            width = (max_r - min_r) / buckets
            counts = [0] * buckets
            for r in ratios:
                idx = min(int((r - min_r) / width), buckets - 1)
                counts[idx] += 1
            max_count = max(counts) if counts else 1
            for i, c in enumerate(counts):
                lo = min_r + i * width
                hi = lo + width
                bar = '█' * int(40 * c / max_count) if max_count > 0 else ''
                marker = ' ←1.0' if lo <= 1.0 <= hi else ''
                print(f"  [{lo:5.2f},{hi:5.2f}) |{bar} ({c}){marker}")

    print(f"\n{'=' * 70}")
    print(f"SUMMARY")
    print(f"{'=' * 70}")
    if counterexamples:
        print(f"⚠  Found {len(counterexamples)} pairs with ratio ≥ 1.0")
        print(f"   → Global uniform contraction is NOT possible")
        print(f"   → But head-aligned pairs may still be strictly contractive")
    else:
        print(f"✓  All {pairs_analyzed} pairs had ratio < 1.0")
        print(f"   → Consistent with strict contraction conjecture")

    return {
        'pairs_analyzed': pairs_analyzed,
        'ratios': ratios,
        'visible_ratios': visible_ratios,
        'non_visible_ratios': non_visible_ratios,
        'shell_data': dict(shell_data),
        'counterexamples': counterexamples,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Contraction dynamics explorer')
    parser.add_argument('--max-size', type=int, default=5,
                        help='Maximum term size to enumerate (default: 5)')
    parser.add_argument('--max-depth', type=int, default=10,
                        help='Maximum BFS depth for distance computation')
    args = parser.parse_args()

    results = analyze_contraction(max_size=args.max_size, max_depth=args.max_depth)
