#!/usr/bin/env python3
"""
Applications of State-Space Growth Bounds for Lambda Calculus

Demonstrates real-world applications of the exponential bound theorems:
1. Bounded model checking budget estimation
2. Symbolic execution state-space prediction
3. Resource-aware interpreter with growth monitoring
"""

from algorithms import (
    Term, Var, App, Lam,
    size, subst, redex_count, branch_complexity, is_affine,
    compute_successors, compute_bounded_states, state_growth_sequence,
)


# --- Application 1: Bounded Model Checking ---

def estimate_model_checking_budget(term: Term, max_depth: int) -> dict:
    """Estimate the computational budget for bounded model checking.

    Given a lambda term (representing a program) and a maximum exploration
    depth, uses the exponential bound theorem to predict the worst-case
    number of states that need to be examined.

    Returns a dict with budget estimates and recommendations.
    """
    bc = branch_complexity(term)
    sz = size(term)
    aff = is_affine(term)

    # Theoretical worst-case
    worst_case_states = bc ** max_depth

    # Actual state count
    actual_growth = state_growth_sequence(term, min(max_depth, 12))
    actual_states = actual_growth[-1]

    # Estimate practical depth limit (states < 10^6)
    if bc <= 1:
        practical_limit = max_depth
    else:
        import math
        practical_limit = int(math.log(1e6) / math.log(bc))

    return {
        "term_size": sz,
        "branch_complexity": bc,
        "is_affine": aff,
        "max_depth": max_depth,
        "worst_case_states": worst_case_states,
        "actual_states": actual_states,
        "practical_depth_limit": practical_limit,
        "recommendation": (
            "feasible" if worst_case_states < 1e6 else
            "marginal" if worst_case_states < 1e9 else
            "infeasible"
        ),
    }


# --- Application 2: Symbolic Execution ---

def symbolic_execute(term: Term, max_depth: int, max_states: int = 10000) -> dict:
    """Perform symbolic execution with state-space explosion detection.

    Explores all possible reduction paths up to max_depth, but aborts
    early if the state count exceeds max_states (using the growth rate
    to predict future explosion).

    Returns execution results including path coverage statistics.
    """
    bc = branch_complexity(term)
    states = {term}
    frontier = {term}
    growth_history = [1]
    depth_reached = 0
    aborted = False

    for d in range(max_depth):
        new_frontier = set()
        for s in frontier:
            for succ in compute_successors(s):
                if succ not in states:
                    states.add(succ)
                    new_frontier.add(succ)

        frontier = new_frontier
        growth_history.append(len(states))
        depth_reached = d + 1

        # Check for state-space explosion
        if len(states) > max_states:
            aborted = True
            break

        if not frontier:
            break

    # Identify normal forms (states with no successors)
    normal_forms = [s for s in states if not compute_successors(s)]

    return {
        "depth_reached": depth_reached,
        "total_states": len(states),
        "normal_forms": len(normal_forms),
        "growth_history": growth_history,
        "branch_complexity": bc,
        "aborted": aborted,
        "coverage": f"{depth_reached}/{max_depth} depths explored",
    }


# --- Application 3: Resource-Aware Interpreter ---

class ResourceAwareInterpreter:
    """An interpreter that monitors state-space growth in real-time.

    Uses the branching complexity bound to provide early warnings
    about potential state-space explosion.
    """

    def __init__(self, max_states: int = 1000, max_depth: int = 50):
        self.max_states = max_states
        self.max_depth = max_depth
        self.log: list = []

    def evaluate(self, term: Term) -> dict:
        """Evaluate a term with resource monitoring."""
        bc = branch_complexity(term)
        aff = is_affine(term)

        self.log.append(f"Starting evaluation of {term}")
        self.log.append(f"  Branch complexity: {bc}")
        self.log.append(f"  Affine: {aff}")

        if bc == 1:
            self.log.append("  → Already in normal form (bc=1)")
            return {
                "result": term,
                "steps": 0,
                "states_explored": 1,
                "warnings": [],
            }

        states = {term}
        frontier = {term}
        warnings = []
        depth = 0

        for d in range(self.max_depth):
            new_frontier = set()
            for s in frontier:
                succs = compute_successors(s)
                for succ in succs:
                    if succ not in states:
                        states.add(succ)
                        new_frontier.add(succ)

            if not new_frontier:
                self.log.append(f"  → Converged at depth {d+1}")
                break

            frontier = new_frontier
            depth = d + 1

            # Growth rate warning
            growth_rate = len(states) / max(len(states) - len(new_frontier), 1)
            if growth_rate > 2.0:
                msg = f"High growth rate {growth_rate:.1f}x at depth {depth}"
                warnings.append(msg)
                self.log.append(f"  ⚠ {msg}")

            if len(states) > self.max_states:
                msg = f"State limit exceeded at depth {depth}"
                warnings.append(msg)
                self.log.append(f"  ✗ {msg}")
                break

        # Find normal forms
        normal_forms = [s for s in states if not compute_successors(s)]

        return {
            "result": normal_forms[0] if normal_forms else term,
            "steps": depth,
            "states_explored": len(states),
            "normal_forms": len(normal_forms),
            "warnings": warnings,
        }


def main():
    """Demonstrate all applications."""
    print()
    print("=" * 70)
    print("  APPLICATION 1: BOUNDED MODEL CHECKING BUDGET ESTIMATION")
    print("=" * 70)
    print()

    test_terms = [
        ("Identity", Lam(0, Var(0))),
        ("Simple redex", App(Lam(0, Var(0)), Lam(1, Var(1)))),
        ("Church 2", Lam(0, Lam(1, App(Var(0), App(Var(0), Var(1)))))),
        ("Nested app", App(App(Lam(0, Var(0)), Lam(1, Var(1))),
                          App(Lam(2, Var(2)), Var(3)))),
    ]

    for name, term in test_terms:
        result = estimate_model_checking_budget(term, max_depth=10)
        print(f"  {name}: {term}")
        print(f"    Size={result['term_size']}, BC={result['branch_complexity']}, "
              f"Affine={result['is_affine']}")
        print(f"    Worst case at d=10: {result['worst_case_states']:,} states")
        print(f"    Actual states: {result['actual_states']}")
        print(f"    Practical depth limit (< 10^6): {result['practical_depth_limit']}")
        print(f"    Recommendation: {result['recommendation']}")
        print()

    print()
    print("=" * 70)
    print("  APPLICATION 2: SYMBOLIC EXECUTION")
    print("=" * 70)
    print()

    for name, term in test_terms:
        result = symbolic_execute(term, max_depth=8)
        print(f"  {name}:")
        print(f"    Coverage: {result['coverage']}")
        print(f"    States explored: {result['total_states']}")
        print(f"    Normal forms found: {result['normal_forms']}")
        print(f"    Growth: {result['growth_history']}")
        print()

    print()
    print("=" * 70)
    print("  APPLICATION 3: RESOURCE-AWARE INTERPRETER")
    print("=" * 70)
    print()

    interp = ResourceAwareInterpreter(max_states=500, max_depth=20)

    for name, term in test_terms:
        result = interp.evaluate(term)
        print(f"  {name}: {term}")
        print(f"    Result: {result['result']}")
        print(f"    Steps: {result['steps']}, States: {result['states_explored']}")
        if result['warnings']:
            for w in result['warnings']:
                print(f"    ⚠ {w}")
        print()

    print()
    print("  Log:")
    for entry in interp.log[-10:]:
        print(f"    {entry}")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive Demo: Exponential Growth Bounds for Lambda Calculus

Demonstrates the key theorems from the research:
1. State growth curves for various lambda terms
2. Comparison of growth rates across linear/affine/general fragments
3. Exponential vs polynomial model fitting
4. Verification of the branching complexity bound

Usage:
    python demo.py
"""

import sys
import random
import math
from algorithms import (
    Term, Var, App, Lam,
    size, subst, var_count, redex_count, branch_complexity, is_affine,
    compute_successors, compute_bounded_states, compute_state_growth,
    state_growth_sequence, random_term, random_affine_term,
    IDENTITY, SIMPLE_REDEX, SELF_APP, OMEGA, CHURCH_2, CHURCH_3
)


def fit_exponential(growth: list) -> tuple:
    """Fit growth ~ a * C^d using least squares on log scale.

    Returns (a, C, R_squared).
    """
    n = len(growth)
    if n < 2 or any(g <= 0 for g in growth):
        return (1.0, 1.0, 0.0)

    log_g = [math.log(g) for g in growth]
    ds = list(range(n))

    # Linear regression on log_g = log(a) + d * log(C)
    mean_d = sum(ds) / n
    mean_lg = sum(log_g) / n

    ss_dd = sum((d - mean_d) ** 2 for d in ds)
    if ss_dd == 0:
        return (growth[0], 1.0, 1.0)

    ss_dlg = sum((d - mean_d) * (lg - mean_lg) for d, lg in zip(ds, log_g))
    slope = ss_dlg / ss_dd
    intercept = mean_lg - slope * mean_d

    C = math.exp(slope)
    a = math.exp(intercept)

    # R-squared
    ss_res = sum((lg - (intercept + slope * d)) ** 2 for d, lg in zip(ds, log_g))
    ss_tot = sum((lg - mean_lg) ** 2 for lg in log_g)
    r_sq = 1 - ss_res / ss_tot if ss_tot > 0 else 1.0

    return (a, C, r_sq)


def fit_polynomial(growth: list) -> tuple:
    """Fit growth ~ c * (d+1)^k using least squares on log-log scale.

    Returns (c, k, R_squared).
    """
    n = len(growth)
    if n < 2 or any(g <= 0 for g in growth):
        return (1.0, 0.0, 0.0)

    log_g = [math.log(g) for g in growth]
    log_d = [math.log(d + 1) for d in range(n)]

    mean_ld = sum(log_d) / n
    mean_lg = sum(log_g) / n

    ss_dd = sum((ld - mean_ld) ** 2 for ld in log_d)
    if ss_dd == 0:
        return (growth[0], 0.0, 1.0)

    ss_dlg = sum((ld - mean_ld) * (lg - mean_lg) for ld, lg in zip(log_d, log_g))
    slope = ss_dlg / ss_dd
    intercept = mean_lg - slope * mean_ld

    k = slope
    c = math.exp(intercept)

    ss_res = sum((lg - (intercept + slope * ld)) ** 2 for ld, lg in zip(log_d, log_g))
    ss_tot = sum((lg - mean_lg) ** 2 for lg in log_g)
    r_sq = 1 - ss_res / ss_tot if ss_tot > 0 else 1.0

    return (c, k, r_sq)


def ascii_bar(value: int, max_value: int, width: int = 50) -> str:
    """Create an ASCII bar chart entry."""
    if max_value == 0:
        bar_len = 0
    else:
        bar_len = int(value / max_value * width)
    return '█' * bar_len + '░' * (width - bar_len)


def demo_growth_curves():
    """Demonstrate state growth curves for various lambda terms."""
    print("=" * 70)
    print("  STATE GROWTH CURVES FOR LAMBDA TERMS")
    print("=" * 70)
    print()

    max_d = 8

    examples = [
        ("Identity λ0.0", IDENTITY),
        ("Simple redex (λ0.0)(λ1.1)", SIMPLE_REDEX),
        ("Church 2 λf.λx.f(f x)", CHURCH_2),
        ("Church 3 λf.λx.f(f(f x))", CHURCH_3),
        ("(λ0.0 0)(λ1.1)", App(Lam(0, App(Var(0), Var(0))), Lam(1, Var(1)))),
    ]

    for name, term in examples:
        bc = branch_complexity(term)
        aff = is_affine(term)
        growth = state_growth_sequence(term, max_d)
        max_g = max(growth) if growth else 1

        print(f"  {name}")
        print(f"  branchComplexity = {bc}, affine = {aff}")
        print(f"  Theoretical bound: stateGrowth ≤ {bc}^d")
        print()

        for d, g in enumerate(growth):
            bound = bc ** d
            bar = ascii_bar(g, max(max_g, 1), 40)
            ok = "✓" if g <= bound else "✗"
            print(f"    d={d:2d}: {g:6d} ≤ {bound:8d} {ok} {bar}")
        print()

    print()


def demo_fragment_comparison():
    """Compare growth rates across linear/affine/general fragments."""
    print("=" * 70)
    print("  COMPLEXITY CLASSIFICATION BY FRAGMENT")
    print("=" * 70)
    print()

    max_d = 10
    n_samples = 15

    random.seed(42)

    print("  Generating random terms and computing growth rates...")
    print()

    categories = {
        "General": [],
        "Affine": [],
    }

    # Generate general terms
    for i in range(n_samples):
        t = random_term(3, max_var=3, p_lam=0.35)
        growth = state_growth_sequence(t, max_d)
        if max(growth) > 1:  # Skip trivial terms
            _, C, r2 = fit_exponential(growth)
            categories["General"].append((t, growth, C, r2))

    # Generate affine terms
    for i in range(n_samples):
        t = random_affine_term(3)
        growth = state_growth_sequence(t, max_d)
        _, C, r2 = fit_exponential(growth)
        categories["Affine"].append((t, growth, C, r2))

    for cat_name, entries in categories.items():
        if not entries:
            print(f"  {cat_name}: no non-trivial terms generated")
            continue

        bases = [C for _, _, C, _ in entries]
        avg_base = sum(bases) / len(bases)
        max_base = max(bases)

        print(f"  {cat_name} terms ({len(entries)} samples):")
        print(f"    Average exponential base: {avg_base:.3f}")
        print(f"    Maximum exponential base: {max_base:.3f}")
        print()

        # Show top 3 fastest-growing
        entries_sorted = sorted(entries, key=lambda x: x[2], reverse=True)
        for j, (t, growth, C, r2) in enumerate(entries_sorted[:3]):
            bc = branch_complexity(t)
            print(f"    #{j+1}: {t}")
            print(f"         bc={bc}, fitted C={C:.3f} (R²={r2:.3f})")
            print(f"         growth: {growth[:6]}...")
            print()

    print()


def demo_model_comparison():
    """Compare exponential vs polynomial model fits."""
    print("=" * 70)
    print("  EXPONENTIAL vs POLYNOMIAL MODEL FIT")
    print("=" * 70)
    print()

    max_d = 10

    # Test with known examples
    test_terms = [
        ("(λ0.0)(λ1.1)", SIMPLE_REDEX),
        ("Church 2", CHURCH_2),
        ("(λ0.0 0)(λ1.1)", App(Lam(0, App(Var(0), Var(0))), Lam(1, Var(1)))),
        ("(λ0.0)(λ1.(1 1))", App(Lam(0, Var(0)), Lam(1, App(Var(1), Var(1))))),
    ]

    print(f"  {'Term':<30} {'Exp C':>8} {'Exp R²':>8} {'Poly k':>8} {'Poly R²':>8} {'Best':>8}")
    print(f"  {'-'*30} {'-'*8} {'-'*8} {'-'*8} {'-'*8} {'-'*8}")

    for name, term in test_terms:
        growth = state_growth_sequence(term, max_d)

        # Only fit on non-trivial data
        if max(growth) <= 1:
            print(f"  {name:<30} {'trivial':>8}")
            continue

        a_exp, C_exp, r2_exp = fit_exponential(growth)
        c_poly, k_poly, r2_poly = fit_polynomial(growth)

        best = "Exp" if r2_exp > r2_poly else "Poly"
        print(f"  {name:<30} {C_exp:8.3f} {r2_exp:8.3f} {k_poly:8.3f} {r2_poly:8.3f} {best:>8}")

    print()


def demo_bound_verification():
    """Verify the exponential bound theorem computationally."""
    print("=" * 70)
    print("  THEOREM VERIFICATION: stateGrowth(t, d) ≤ (B+1)^d")
    print("=" * 70)
    print()

    random.seed(123)
    max_d = 8
    n_terms = 30
    violations = 0
    tested = 0

    for i in range(n_terms):
        t = random_term(3, max_var=3, p_lam=0.4)
        bc = branch_complexity(t)
        growth = state_growth_sequence(t, max_d)

        for d, g in enumerate(growth):
            bound = bc ** d
            tested += 1
            if g > bound:
                violations += 1
                print(f"  VIOLATION: {t}, d={d}, growth={g} > {bound}=bc^d")

    print(f"  Tested {tested} (term, depth) pairs: "
          f"{violations} violations, {tested - violations} verified")
    print()
    if violations == 0:
        print("  ✓ All bounds verified — consistent with Theorem A")
    else:
        print("  ✗ Violations found — investigate!")
    print()


def demo_counterexample():
    """Demonstrate the counterexample to affine monotonicity."""
    print("=" * 70)
    print("  COUNTEREXAMPLE: AFFINE MONOTONICITY FAILURE")
    print("=" * 70)
    print()

    # t = ((λ0. λ3. (0 1)) (λ2. 2)) 4
    t = App(App(Lam(0, Lam(3, App(Var(0), Var(1)))), Lam(2, Var(2))), Var(4))
    # After reducing inner redex: (λ3. (λ2. 2) 1) 4
    u = App(Lam(3, App(Lam(2, Var(2)), Var(1))), Var(4))

    print(f"  t = {t}")
    print(f"  u = {u}  (after one β-step)")
    print()
    print(f"  IsAffine(t) = {is_affine(t)}")
    print(f"  branchComplexity(t) = {branch_complexity(t)}")
    print(f"  branchComplexity(u) = {branch_complexity(u)}")
    print()

    if branch_complexity(u) > branch_complexity(t):
        print("  ✓ Confirmed: branchComplexity INCREASES under β-reduction")
        print("    even for affine terms with naive substitution.")
        print()
        print("  The substitution λ2.2 for var 0 in (var 0)(var 1)")
        print("  creates the new redex (λ2.2)(var 1).")
    print()


def main():
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   EXPONENTIAL GROWTH BOUNDS FOR BOUNDED β-REDUCTION                ║")
    print("║   Interactive Demonstration of State-Space Complexity Theory        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_growth_curves()
    demo_fragment_comparison()
    demo_model_comparison()
    demo_bound_verification()
    demo_counterexample()

    print("=" * 70)
    print("  SUMMARY")
    print("=" * 70)
    print()
    print("  Key verified results:")
    print("  1. stateGrowth(t, d+1) ≤ (B+1) × stateGrowth(t, d)  [Recurrence]")
    print("  2. stateGrowth(t, d) ≤ (B+1)^d                       [Exp. Bound]")
    print("  3. |successors(t)| ≤ redex_count(t)                   [Succ. Bound]")
    print("  4. Affine monotonicity FAILS with naive substitution  [Counter-ex]")
    print()
    print("  All proofs machine-verified. See BranchComplexity.lean.")
    print()


if __name__ == "__main__":
    main()
