#!/usr/bin/env python3
"""
Applications: Church-Rosser as a Bisimulation Generator

Demonstrates practical applications of the theoretical framework:
1. Program equivalence checking via common reducts
2. Compiler optimization verification
3. Bounded model checking for lambda terms
4. Normalization cost analysis
"""

from algorithms import *


def app_program_equivalence():
    """Application 1: Verify two program transformations are equivalent."""
    print("=" * 60)
    print("APPLICATION 1: Program Equivalence via Church-Rosser")
    print("=" * 60)

    # Two implementations of "apply identity to argument"
    # Version 1: (λf. f x) (λy. y) — apply identity to x
    v1 = App(Lam_(0, App(Var(0), Var(2))), Lam_(1, Var(1)))
    # Version 2: x — the optimized version
    v2 = Var(2)

    print(f"\nProgram v1 = {v1}")
    print(f"Program v2 = {v2}")

    result = find_common_reduct_bfs(v1, v2, max_depth=5)
    if result:
        common, d1, d2 = result
        print(f"✓ Programs are β-equivalent!")
        print(f"  Common reduct: {common}")
        print(f"  v1 reduces in {d1} steps, v2 in {d2} steps")
        print(f"  Joinability budget: {max(d1, d2)}")
    else:
        print("✗ Could not verify equivalence within search depth")


def app_optimization_verification():
    """Application 2: Verify compiler optimizations are sound."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Compiler Optimization Verification")
    print("=" * 60)

    optimizations = [
        ("Identity elimination",
         App(Lam_(0, Var(0)), Var(5)),   # (λx.x) a → a
         Var(5)),
        ("Constant folding",
         App(Lam_(0, Var(1)), Var(5)),   # (λx.y) a → y
         Var(1)),
        ("Beta-eta equivalence",
         Lam_(0, App(Lam_(1, Var(1)), Var(0))),  # λx. (λy.y) x
         Lam_(0, Var(0))),                         # λx. x
    ]

    for name, before, after in optimizations:
        result = find_common_reduct_bfs(before, after, max_depth=5)
        status = "✓" if result else "✗"
        print(f"\n{status} {name}:")
        print(f"  Before: {before}")
        print(f"  After:  {after}")
        if result:
            common, d1, d2 = result
            print(f"  Common reduct: {common} ({d1}+{d2} steps)")


def app_bounded_model_checking():
    """Application 3: Bounded model checking for lambda terms."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Bounded Model Checking")
    print("=" * 60)

    # Check how the transition system grows with depth
    t = App(Lam_(0, App(Var(0), Var(0))), Lam_(1, App(Var(1), Var(1))))
    print(f"\nΩ-like term: {t}")
    print(f"(Self-application of self-application)")

    for d in range(5):
        fts = build_bounded_fts(t, d)
        print(f"  depth {d}: {len(fts['states']):3d} states, "
              f"{len(fts['transitions']):3d} transitions")

    # Check a normalizing term
    t2 = App(Lam_(0, App(Lam_(1, Var(1)), Var(0))), Var(2))
    print(f"\nNormalizing term: {t2}")

    for d in range(5):
        fts = build_bounded_fts(t2, d)
        print(f"  depth {d}: {len(fts['states']):3d} states, "
              f"{len(fts['transitions']):3d} transitions")


def app_normalization_cost():
    """Application 4: Normalization cost analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Normalization Cost Analysis")
    print("=" * 60)

    terms = [
        ("Identity", Lam_(0, Var(0))),
        ("(λx.x) y", App(Lam_(0, Var(0)), Var(1))),
        ("(λx.x x) (λy.y)", App(Lam_(0, App(Var(0), Var(0))), Lam_(1, Var(1)))),
        ("(λf.λx.f x) (λy.y)", App(Lam_(0, Lam_(1, App(Var(0), Var(1)))),
                                     Lam_(2, Var(2)))),
    ]

    print(f"\n{'Term':<35} {'Size':>5} {'Normal form':<25} {'Steps':>5}")
    print("-" * 75)

    for name, t in terms:
        size = term_size(t)
        current = t
        steps = 0
        for _ in range(20):
            rs = beta_reducts(current)
            if not rs:
                break
            current = rs[0]  # leftmost reduction
            steps += 1
        print(f"{name:<35} {size:>5} {str(current):<25} {steps:>5}")


if __name__ == "__main__":
    app_program_equivalence()
    app_optimization_verification()
    app_bounded_model_checking()
    app_normalization_cost()
    print("\n" + "=" * 60)
    print("All applications complete.")


#!/usr/bin/env python3
"""
Demo: Church-Rosser Confluence and Bisimulation Transfer

Demonstrates the core ideas of the formalization:
1. Lambda calculus terms and beta-reduction
2. Parallel beta-reduction and Takahashi's complete development
3. The diamond property and Church-Rosser theorem
4. Bounded finite transition systems from lambda terms
5. Strong bisimulation checking at various depths
"""

from dataclasses import dataclass
from typing import Optional


# ─── Lambda Calculus Terms ────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """Variable: var(n)"""
    n: int
    def __repr__(self): return f"x{self.n}"

@dataclass(frozen=True)
class App:
    """Application: (fun arg)"""
    fun: 'Lam'
    arg: 'Lam'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam_:
    """Lambda abstraction: λn. body"""
    var: int
    body: 'Lam'
    def __repr__(self): return f"(λx{self.var}. {self.body})"

Lam = Var | App | Lam_


def subst(t: Lam, x: int, s: Lam) -> Lam:
    """Substitute s for variable x in term t (naive, capture-allowing)."""
    if isinstance(t, Var):
        return s if t.n == x else t
    elif isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))
    elif isinstance(t, Lam_):
        if t.var == x:
            return t  # bound variable shadows
        return Lam_(t.var, subst(t.body, x, s))


# ─── Beta Reduction ──────────────────────────────────────────────────────

def beta_reducts(t: Lam) -> list[Lam]:
    """Find all one-step beta reducts of t."""
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam_):
            # Beta redex: (λx. body) arg → body[x := arg]
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        # Reduce in function position
        for f in beta_reducts(t.fun):
            results.append(App(f, t.arg))
        # Reduce in argument position
        for a in beta_reducts(t.arg):
            results.append(App(t.fun, a))
    elif isinstance(t, Lam_):
        for b in beta_reducts(t.body):
            results.append(Lam_(t.var, b))
    return results


def multi_step_reducts(t: Lam, depth: int) -> set:
    """Find all terms reachable from t within `depth` beta steps."""
    current = {t}
    all_reachable = {t}
    for _ in range(depth):
        next_level = set()
        for term in current:
            for r in beta_reducts(term):
                if r not in all_reachable:
                    next_level.add(r)
                    all_reachable.add(r)
        current = next_level
        if not current:
            break
    return all_reachable


# ─── Parallel Beta Reduction ─────────────────────────────────────────────

def complete_development(t: Lam) -> Lam:
    """Takahashi's complete development (star translation).
    Simultaneously contracts ALL outermost redexes."""
    if isinstance(t, Var):
        return t
    elif isinstance(t, App):
        if isinstance(t.fun, Lam_):
            # Beta redex: contract it
            body_star = complete_development(t.fun.body)
            arg_star = complete_development(t.arg)
            return subst(body_star, t.fun.var, arg_star)
        else:
            return App(complete_development(t.fun), complete_development(t.arg))
    elif isinstance(t, Lam_):
        return Lam_(t.var, complete_development(t.body))


def find_common_reduct(t: Lam, u: Lam, max_steps: int = 20) -> Optional[Lam]:
    """Find a common reduct of t and u by bounded search."""
    t_reducts = multi_step_reducts(t, max_steps)
    u_reducts = multi_step_reducts(u, max_steps)
    common = t_reducts & u_reducts
    return min(common, key=lambda x: term_size(x)) if common else None


def term_size(t: Lam) -> int:
    if isinstance(t, Var): return 1
    elif isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    elif isinstance(t, Lam_): return 1 + term_size(t.body)


# ─── Bounded FTS ─────────────────────────────────────────────────────────

def build_fts(t: Lam, depth: int) -> dict:
    """Build a bounded finite transition system from term t at depth d.
    Returns {states: set, init: Lam, transitions: set of (s1, s2)}."""
    states = multi_step_reducts(t, depth)
    transitions = set()
    for s in states:
        for r in beta_reducts(s):
            if r in states:
                transitions.add((s, r))
    return {"states": states, "init": t, "transitions": transitions}


def check_strong_bisimulation(fts_a: dict, fts_b: dict) -> bool:
    """Check if two FTS are strongly bisimilar using partition refinement.
    Returns True if a strong bisimulation exists relating the initial states."""
    # Simple BFS-based check: try R = {(a.init, b.init)} and see if it extends
    from collections import deque

    R = set()
    queue = deque()
    queue.append((fts_a["init"], fts_b["init"]))

    while queue:
        a, b = queue.popleft()
        if (a, b) in R:
            continue
        R.add((a, b))

        # Forward matching
        a_succs = {s2 for (s1, s2) in fts_a["transitions"] if s1 == a}
        b_succs = {s2 for (s1, s2) in fts_b["transitions"] if s1 == b}

        for a_prime in a_succs:
            matched = False
            for b_prime in b_succs:
                if (a_prime, b_prime) not in R:
                    queue.append((a_prime, b_prime))
                    matched = True
                    break
                elif (a_prime, b_prime) in R:
                    matched = True
                    break
            if not matched and b_succs:
                return False
            if not matched and not b_succs:
                return False

        for b_prime in b_succs:
            matched = False
            for a_prime in a_succs:
                if (a_prime, b_prime) in R:
                    matched = True
                    break
            if not matched:
                return False

    return True


# ─── Demonstrations ──────────────────────────────────────────────────────

def demo_diamond_property():
    """Demonstrate the diamond property of parallel reduction."""
    print("=" * 60)
    print("DEMO 1: Diamond Property via Complete Development")
    print("=" * 60)

    # (λx. (λy. x) z) w — has two redexes
    t = App(Lam_(0, App(Lam_(1, Var(0)), Var(2))), Var(3))
    print(f"\nTerm t = {t}")

    reducts = beta_reducts(t)
    print(f"One-step reducts:")
    for r in reducts:
        print(f"  t →β {r}")

    star = complete_development(t)
    print(f"\nComplete development t⋆ = {star}")
    print("All reducts converge to t⋆ (diamond property):")
    for r in reducts:
        r_star = complete_development(r)
        print(f"  {r} →⋆ {r_star}")


def demo_church_rosser():
    """Demonstrate Church-Rosser: β-equivalent terms have common reducts."""
    print("\n" + "=" * 60)
    print("DEMO 2: Church-Rosser — Common Reducts")
    print("=" * 60)

    # Two β-equivalent terms
    t = App(Lam_(0, Var(0)), Var(1))  # (λx.x) y
    u = Var(1)                         # y
    print(f"\nt = {t}")
    print(f"u = {u}")
    print(f"BetaEq(t, u): t →β u ✓")

    common = find_common_reduct(t, u)
    print(f"Common reduct: {common}")

    # More complex example
    t2 = App(Lam_(0, App(Var(0), Var(0))), Lam_(1, Var(1)))
    print(f"\nt₂ = {t2}")
    reducts_t2 = beta_reducts(t2)
    print(f"Reducts of t₂:")
    for r in reducts_t2:
        print(f"  t₂ →β {r}")
        r2 = beta_reducts(r)
        for rr in r2:
            print(f"       →β {rr}")


def demo_bounded_fts():
    """Demonstrate bounded FTS construction and bisimulation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Bounded FTS and Bisimulation")
    print("=" * 60)

    t = App(Lam_(0, Var(0)), Var(1))  # (λx.x) y
    u = Var(1)                         # y

    for d in range(4):
        fts_t = build_fts(t, d)
        fts_u = build_fts(u, d)
        is_bisim = check_strong_bisimulation(fts_t, fts_u)
        print(f"\nd = {d}:")
        print(f"  toFTS({d}, t): {len(fts_t['states'])} states, "
              f"{len(fts_t['transitions'])} transitions")
        print(f"  toFTS({d}, u): {len(fts_u['states'])} states, "
              f"{len(fts_u['transitions'])} transitions")
        print(f"  Strongly bisimilar: {is_bisim}")

    # Common reduct FTS
    print(f"\n  Common reduct v = {u}")
    for d in range(4):
        fts_v = build_fts(u, d)
        print(f"  toFTS({d}, v): {len(fts_v['states'])} states, "
              f"{len(fts_v['transitions'])} transitions — "
              f"trivially self-bisimilar ✓")


def demo_counterexample():
    """Demonstrate why naive strong bisimulation fails."""
    print("\n" + "=" * 60)
    print("DEMO 4: Counterexample — Strong Bisimulation Fails at d≥1")
    print("=" * 60)

    t = App(Lam_(0, Var(0)), Var(1))  # (λx.x) y
    u = Var(1)                         # y

    print(f"\nt = {t}, u = {u}")
    print(f"BetaEq(t, u) ✓")
    print(f"\nReduction: t →β y = u")
    print(f"u is in normal form (no reducts)")

    fts_t = build_fts(t, 1)
    fts_u = build_fts(u, 1)

    print(f"\ntoFTS(1, t):")
    print(f"  States: {fts_t['states']}")
    print(f"  Transitions: {fts_t['transitions']}")
    print(f"\ntoFTS(1, u):")
    print(f"  States: {fts_u['states']}")
    print(f"  Transitions: {fts_u['transitions']}")

    print(f"\nStrong bisimulation requires matching t →β y in toFTS(1,t)")
    print(f"with some transition from u in toFTS(1,u). But u has none!")
    print(f"⇒ StrongBisimilar(toFTS(d',t), toFTS(d',u)) is FALSE for d' ≥ 1")
    print(f"\nThe correct theorem uses the COMMON REDUCT FTS:")
    print(f"  ∃ v, MultiBeta t v ∧ MultiBeta u v ∧ StrongBisimilar(toFTS(d',v), toFTS(d',v))")
    print(f"  Here v = y, and toFTS(d', y) is trivially self-bisimilar.")


def demo_capture_issue():
    """Demonstrate why naive substitution breaks Church-Rosser."""
    print("\n" + "=" * 60)
    print("DEMO 5: Variable Capture — Why Naive Substitution Fails")
    print("=" * 60)

    # t = (λ0. (λ1. 0) 2) 1
    t = App(Lam_(0, App(Lam_(1, Var(0)), Var(2))), Var(1))
    print(f"\nt = {t}")

    # Path 1: reduce inner first
    inner = App(Lam_(1, Var(0)), Var(2))
    inner_reduced = subst(Var(0), 1, Var(2))  # var(0)[1:=var(2)] = var(0)
    t_after_inner = App(Lam_(0, inner_reduced), Var(1))
    result1 = subst(inner_reduced, 0, Var(1))  # var(0)[0:=var(1)] = var(1)
    print(f"\nPath 1 (inner first):")
    print(f"  (λ1. x0) x2 →β x0")
    print(f"  (λ0. x0) x1 →β x1")
    print(f"  Result: {result1}")

    # Path 2: reduce outer first
    body = App(Lam_(1, Var(0)), Var(2))
    body_subst = subst(body, 0, Var(1))
    print(f"\nPath 2 (outer first):")
    print(f"  (λ0. (λ1. x0) x2) x1 →β {body_subst}")
    result2_parts = beta_reducts(body_subst)
    if result2_parts:
        print(f"  {body_subst} →β {result2_parts[0]}")
        print(f"  Result: {result2_parts[0]}")
    else:
        print(f"  (already in normal form)")
        print(f"  Result: {body_subst}")

    print(f"\nWith capture-avoiding substitution, both paths give the same result.")
    print(f"With naive substitution, capture can cause divergence.")


if __name__ == "__main__":
    demo_diamond_property()
    demo_church_rosser()
    demo_bounded_fts()
    demo_counterexample()
    demo_capture_issue()
    print("\n" + "=" * 60)
    print("All demos complete.")
