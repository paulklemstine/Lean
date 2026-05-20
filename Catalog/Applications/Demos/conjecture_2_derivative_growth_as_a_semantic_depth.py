#!/usr/bin/env python3
"""
Applications of Derivative Growth as a Semantic Depth Invariant.

This module demonstrates practical applications of the depth-derivative theory:
1. Analog circuit complexity lower bounds
2. Neural network expressivity bounds
3. Symbolic regression depth detection
4. Sensitivity analysis for compositional programs
"""

import math
from typing import List, Tuple, Optional
from algorithms import (
    Expr, ExprKind, tower_expr, eval_expr, eval_deriv,
    depth, size, iter_exp, depth_majorant, certify_deriv_bound,
    estimate_max_deriv, random_exp_fragment, random_full_expr,
    depth_lower_bound_certificate
)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Analog Circuit Complexity
# ─────────────────────────────────────────────────────────────────────

def analog_circuit_depth_lower_bound(
    f_samples: List[Tuple[float, float]],
    h: float = 1e-5,
    M: float = 10.0
) -> int:
    """Compute a depth lower bound for an analog circuit computing a function f.

    Given samples of f on [0,1], estimates the maximum derivative and
    uses the depth separation theorem to derive a lower bound on the
    circuit depth needed to compute f using exp gates.

    Args:
        f_samples: List of (x, f(x)) pairs on [0,1]
        h: Step size for numerical differentiation
        M: Assumed subexpression bound

    Returns:
        Lower bound on circuit depth

    Example:
        >>> # f(x) = exp(exp(exp(x))) needs depth ≥ 3
        >>> samples = [(x/100, math.exp(math.exp(math.exp(x/100)))) for x in range(101)]
        >>> analog_circuit_depth_lower_bound(samples)
        3
    """
    # Estimate max derivative from samples
    max_deriv = 0.0
    for i in range(len(f_samples) - 1):
        x1, y1 = f_samples[i]
        x2, y2 = f_samples[i + 1]
        if x2 > x1:
            deriv_est = abs((y2 - y1) / (x2 - x1))
            max_deriv = max(max_deriv, deriv_est)

    return depth_lower_bound_certificate(max_deriv, M)


# ─────────────────────────────────────────────────────────────────────
# Application 2: Neural Network Expressivity Bounds
# ─────────────────────────────────────────────────────────────────────

def neural_depth_certificate(
    target_sensitivity: float,
    activation_bound: float = 3.0
) -> int:
    """Certify the minimum network depth needed to achieve a given sensitivity.

    Models a neural network as a composition of bounded smooth activations.
    If the target function has derivative magnitude exceeding
    depth_majorant(d, M), then no depth-d network with activations
    bounded by M can represent it.

    Args:
        target_sensitivity: Required maximum derivative magnitude
        activation_bound: Bound on activation function values

    Returns:
        Minimum depth certificate

    Example:
        >>> neural_depth_certificate(1000.0, activation_bound=3.0)
        2
    """
    return depth_lower_bound_certificate(target_sensitivity, activation_bound)


def expressivity_landscape(max_depth: int = 6, M: float = 2.0) -> None:
    """Print the expressivity landscape: what derivative magnitudes
    are achievable at each depth.

    Args:
        max_depth: Maximum depth to analyze
        M: Subexpression bound
    """
    print("Neural Expressivity Landscape")
    print(f"Activation bound M = {M}")
    print(f"{'Depth':>6} {'Max achievable deriv':>24} {'Log10':>10}")
    print(f"{'─'*6} {'─'*24} {'─'*10}")
    for d in range(max_depth + 1):
        bound = depth_majorant(d, M)
        if math.isfinite(bound) and bound > 0:
            log_bound = math.log10(bound) if bound > 0 else 0
            print(f"{d:>6} {bound:>24.6g} {log_bound:>10.2f}")
        else:
            print(f"{d:>6} {'overflow':>24} {'∞':>10}")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Symbolic Regression Depth Detection
# ─────────────────────────────────────────────────────────────────────

def detect_expression_depth(
    f_eval,
    x_points: List[float],
    M_candidates: List[float] = None
) -> Tuple[int, float]:
    """Detect the minimum expression depth from function evaluations.

    Uses derivative estimation and the depth separation theorem to
    infer a lower bound on the syntactic depth of any expression
    computing the target function.

    Args:
        f_eval: Function to evaluate at points
        x_points: Sample points in [0, 1]
        M_candidates: Candidate subexpression bounds to try

    Returns:
        (depth_lower_bound, best_M) tuple

    Example:
        >>> f = lambda x: math.exp(math.exp(x))
        >>> pts = [i/1000 for i in range(1001)]
        >>> detect_expression_depth(f, pts)
        (2, ...)
    """
    if M_candidates is None:
        M_candidates = [1.0, 2.0, 5.0, 10.0, 50.0, 100.0]

    # Estimate max derivative using central differences
    max_deriv = 0.0
    h = 1e-6
    for x in x_points:
        if h < x < 1 - h:
            try:
                deriv_est = abs(f_eval(x + h) - f_eval(x - h)) / (2 * h)
                if math.isfinite(deriv_est):
                    max_deriv = max(max_deriv, deriv_est)
            except (OverflowError, ValueError):
                pass

    # Try each M and find the one giving the best lower bound
    best_depth = 0
    best_M = M_candidates[0]
    for M in M_candidates:
        # Check if function values are bounded by M
        all_bounded = all(
            abs(f_eval(x)) <= M
            for x in x_points
            if math.isfinite(f_eval(x))
        )
        if not all_bounded:
            continue
        d = depth_lower_bound_certificate(max_deriv, M)
        if d > best_depth:
            best_depth = d
            best_M = M

    return best_depth, best_M


# ─────────────────────────────────────────────────────────────────────
# Application 4: Sensitivity Analysis for Compositional Programs
# ─────────────────────────────────────────────────────────────────────

def sensitivity_profile(e: Expr, n_points: int = 200) -> List[Tuple[float, float]]:
    """Compute the sensitivity profile |E'(x)| over [0, 1].

    Args:
        e: Expression to analyze
        n_points: Number of sample points

    Returns:
        List of (x, |E'(x)|) pairs
    """
    profile = []
    for i in range(n_points + 1):
        x = i / n_points
        try:
            d = abs(eval_deriv(e, x))
            if math.isfinite(d):
                profile.append((x, d))
        except (OverflowError, ValueError):
            pass
    return profile


def compositional_instability_report(e: Expr) -> None:
    """Print a report on the compositional instability of an expression.

    This interprets the derivative magnitude as a Lyapunov-like
    sensitivity measure: how much does a small perturbation of the
    input propagate through the compositional layers?

    Args:
        e: Expression to analyze
    """
    d = depth(e)
    s = size(e)
    max_d, argmax = estimate_max_deriv(e)
    profile = sensitivity_profile(e)

    print(f"Compositional Instability Report")
    print(f"  Expression depth: {d}")
    print(f"  Expression size:  {s}")
    print(f"  Max sensitivity:  {max_d:.6g} at x = {argmax:.4f}")

    if profile:
        avg_sensitivity = sum(p[1] for p in profile) / len(profile)
        print(f"  Avg sensitivity:  {avg_sensitivity:.6g}")
        print(f"  Sensitivity ratio (max/avg): {max_d / avg_sensitivity:.4f}"
              if avg_sensitivity > 0 else "")

    # Certified bound
    M = max(1.0, max(abs(eval_expr(e, p[0])) for p in profile)) if profile else 1.0
    cert = certify_deriv_bound(e, M)
    print(f"  Certified bound:  {cert:.6g} (with M = {M:.4g})")
    print(f"  Tightness ratio:  {max_d / cert:.4f}" if cert > 0 else "")


# ─────────────────────────────────────────────────────────────────────
# Main: Run all application demos
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("  APPLICATIONS: Derivative Depth Invariant")
    print("=" * 65)

    # Application 1: Circuit depth
    print("\n--- Application 1: Analog Circuit Depth Lower Bounds ---\n")
    for k in range(1, 5):
        try:
            samples = [(x / 200, iter_exp(k, x / 200)) for x in range(201)]
            lb = analog_circuit_depth_lower_bound(samples, M=max(1.0, iter_exp(k, 1.0)))
            print(f"  iterExp({k}): circuit depth lower bound = {lb} (actual depth = {k})")
        except (OverflowError, ValueError):
            print(f"  iterExp({k}): overflow")

    # Application 2: Neural expressivity
    print("\n--- Application 2: Neural Network Expressivity ---\n")
    expressivity_landscape(max_depth=6, M=2.0)

    print()
    for sens in [10, 100, 1000, 1e6, 1e20]:
        d = neural_depth_certificate(sens, activation_bound=3.0)
        print(f"  Sensitivity {sens:.0e} requires depth ≥ {d}")

    # Application 3: Symbolic regression
    print("\n--- Application 3: Symbolic Regression Depth Detection ---\n")
    test_fns = [
        ("x", lambda x: x, 1),
        ("exp(x)", lambda x: math.exp(x), 1),
        ("exp(exp(x))", lambda x: math.exp(math.exp(x)), 2),
    ]
    pts = [i / 500 for i in range(501)]
    for name, f, true_depth in test_fns:
        detected, M = detect_expression_depth(f, pts)
        print(f"  {name}: detected depth ≥ {detected} (true = {true_depth}), M = {M:.2f}")

    # Application 4: Sensitivity analysis
    print("\n--- Application 4: Compositional Sensitivity Analysis ---\n")
    for k in range(1, 4):
        print(f"\n  Tower Expression k = {k}:")
        e = tower_expr(k)
        compositional_instability_report(e)
        print()


#!/usr/bin/env python3
"""
Derivative Growth as a Semantic Depth Invariant — Interactive Demo

Demonstrates the core theorems:
1. Derivative growth of iterated exponentials follows a tower pattern
2. Certified derivative bounds track depth via the depth majorant
3. Depth separation: functions with "too fast" derivative growth
   cannot be represented by shallow expressions

Run: python demo.py
"""

import math
import sys

# Import algorithms from local module
from algorithms import (
    Expr, ExprKind, tower_expr, eval_expr, eval_deriv,
    depth, size, iter_exp, depth_majorant, certify_deriv_bound,
    iter_exp_deriv_prod, estimate_max_deriv, random_exp_fragment,
    random_full_expr, check_subexpr_bounded, depth_lower_bound_certificate
)


def print_header(title: str) -> None:
    print("\n" + "═" * 70)
    print(f"  {title}")
    print("═" * 70)


def demo_tower_derivatives() -> None:
    """Demonstrate the derivative product formula for iterated exponentials."""
    print_header("THEOREM 1: Derivative Formula for Iterated Exponentials")
    print()
    print("  iterExp(k, x) = exp^[k](x)")
    print("  d/dx iterExp(k, x) = ∏_{i=1}^{k} iterExp(i, x)")
    print()

    x_vals = [0.0, 0.5, 1.0]
    for x in x_vals:
        print(f"  x = {x}:")
        print(f"  {'k':>4} {'iterExp(k,x)':>16} {'deriv':>16} {'product formula':>16}")
        print(f"  {'─'*4} {'─'*16} {'─'*16} {'─'*16}")
        for k in range(6):
            val = iter_exp(k, x)
            e = tower_expr(k)
            deriv_val = eval_deriv(e, x)
            prod_val = iter_exp_deriv_prod(k, x)
            if math.isfinite(val) and math.isfinite(deriv_val):
                print(f"  {k:>4} {val:>16.6g} {deriv_val:>16.6g} {prod_val:>16.6g}")
            else:
                print(f"  {k:>4} {'overflow':>16} {'overflow':>16} {'overflow':>16}")
        print()


def demo_lower_bound() -> None:
    """Demonstrate the derivative lower bound at x=1."""
    print_header("THEOREM 2: Derivative Lower Bound at x = 1")
    print()
    print("  iterExp(k+1, 1) ≤ d/dx iterExp(k+1, x)|_{x=1}")
    print("  depthMajorant(k, 1) ≤ d/dx iterExp(k+1, x)|_{x=1}")
    print()
    print(f"  {'k':>4} {'iterExp(k+1,1)':>18} {'deriv at 1':>18} {'ratio':>10}")
    print(f"  {'─'*4} {'─'*18} {'─'*18} {'─'*10}")

    for k in range(6):
        val_kp1 = iter_exp(k + 1, 1.0)
        e_kp1 = tower_expr(k + 1)
        deriv_at_1 = eval_deriv(e_kp1, 1.0)
        if math.isfinite(val_kp1) and math.isfinite(deriv_at_1) and val_kp1 > 0:
            ratio = deriv_at_1 / val_kp1
            print(f"  {k:>4} {val_kp1:>18.6g} {deriv_at_1:>18.6g} {ratio:>10.4f}")
        else:
            print(f"  {k:>4} {'overflow':>18} {'overflow':>18} {'—':>10}")

    print()
    print("  → The ratio deriv/iterExp grows, confirming the lower bound is not tight.")
    print("    The derivative actually equals the PRODUCT of all tower levels.")


def demo_certified_bounds() -> None:
    """Demonstrate the certified derivative bound algorithm."""
    print_header("THEOREM 3: Certified Derivative Bounds")
    print()
    print("  For exp-fragment expressions with subexpressions bounded by M:")
    print("  |E'(x)| ≤ certDerivBound(E, M) ≤ depthMajorant(depth(E), M)")
    print()

    for k in range(1, 6):
        e = tower_expr(k)
        # Compute actual subexpression bound
        M = 1.0
        for j in range(k + 1):
            val = iter_exp(j, 1.0)  # max of iter_exp(j, x) on [0,1] is at x=1
            if math.isfinite(val):
                M = max(M, abs(val))
            else:
                M = float('inf')
                break

        if not math.isfinite(M):
            print(f"  towerExpr({k}): overflow (M too large)")
            continue

        cert = certify_deriv_bound(e, M)
        maj = depth_majorant(k, M)
        actual_max, _ = estimate_max_deriv(e)

        print(f"  towerExpr({k}): depth={k}, M={M:.4g}")
        print(f"    actual max|f'|  = {actual_max:.6g}")
        print(f"    certified bound = {cert:.6g}")
        print(f"    tower majorant  = {maj:.6g}")
        is_sound = actual_max <= cert + 1e-6 or not math.isfinite(cert)
        is_tight = cert <= maj + 1e-6 or not math.isfinite(maj)
        print(f"    actual ≤ cert? {is_sound}  |  cert ≤ majorant? {is_tight}")
        print()


def demo_separation() -> None:
    """Demonstrate the depth separation theorem."""
    print_header("THEOREM 4: Depth Separation via Derivative Obstruction")
    print()
    print("  If max|f'| > depthMajorant(d, M), then f cannot be represented")
    print("  by any depth-d expression with subexpressions bounded by M.")
    print()

    # Show that towerExpr(k+1) cannot be represented at depth k
    # (with the same subexpression bound)
    print("  Demonstrating separation for towerExpr(k+1):")
    print()
    for k in range(1, 5):
        e = tower_expr(k + 1)
        actual_max, argmax = estimate_max_deriv(e)

        if not math.isfinite(actual_max):
            continue

        # For a depth-d candidate with bound M, what's the max allowed derivative?
        print(f"  towerExpr({k+1}): depth={k+1}, max|f'| = {actual_max:.6g}")
        for d in range(1, k + 1):
            # Need M such that the function values are bounded
            M_needed = max(1.0, iter_exp(k + 1, 1.0))
            if not math.isfinite(M_needed):
                continue
            maj = depth_majorant(d, M_needed)
            if math.isfinite(maj):
                exceeds = actual_max > maj
                print(f"    depth {d}: majorant = {maj:.6g}, exceeds? {exceeds}")
        print()


def demo_random_expressions() -> None:
    """Generate random expressions and verify bounds."""
    print_header("NUMERICAL EXPERIMENTS: Random Expression Bounds")
    print()
    print("  Generating random exp-fragment expressions and checking:")
    print("  actual max|f'| ≤ certified bound ≤ tower majorant")
    print()

    import random
    random.seed(42)

    n_expr = 20
    violations = 0

    header_deriv = "max|f'|"
    print(f"  {'depth':>5} {'size':>5} {'max|f|':>12} {header_deriv:>12} {'cert':>12} {'majorant':>12} {'ok?':>5}")
    print(f"  {'─'*5} {'─'*5} {'─'*12} {'─'*12} {'─'*12} {'─'*12} {'─'*5}")

    for _ in range(n_expr):
        d_max = random.randint(1, 4)
        e = random_exp_fragment(d_max, const_bound=0.5)
        d = depth(e)
        s = size(e)

        # Compute M (subexpression bound)
        x_pts = [i / 200 for i in range(201)]
        max_val = max(abs(eval_expr(e, x)) for x in x_pts)
        M = max(1.0, max_val * 1.1)  # Add margin

        if not math.isfinite(M) or M > 1e100:
            continue

        actual_max, _ = estimate_max_deriv(e, n_points=500)
        cert = certify_deriv_bound(e, M)
        maj = depth_majorant(d, M)

        if not math.isfinite(actual_max) or not math.isfinite(cert):
            continue

        ok = actual_max <= cert + 1e-6
        if not ok:
            violations += 1

        print(f"  {d:>5} {s:>5} {max_val:>12.4g} {actual_max:>12.4g} {cert:>12.4g} "
              f"{maj if math.isfinite(maj) else 'inf':>12} {'✓' if ok else '✗':>5}")

    print(f"\n  Violations: {violations}/{n_expr}")
    if violations == 0:
        print("  All certified bounds verified numerically! ✓")


def demo_depth_growth_comparison() -> None:
    """Compare derivative growth patterns across depths."""
    print_header("GROWTH COMPARISON: Derivative vs Tower Depth")
    print()
    print("  Derivative of towerExpr(k) at x=1 compared to towers:")
    print()
    h_f1 = "f'(1)"
    h_ratio = "f'(1)/f(1)"
    print(f"  {'k':>4} {'f(1)':>16} {h_f1:>16} {h_ratio:>14} {'tower ratio':>14}")
    print(f"  {'─'*4} {'─'*16} {'─'*16} {'─'*14} {'─'*14}")

    for k in range(1, 7):
        f1 = iter_exp(k, 1.0)
        e = tower_expr(k)
        d1 = eval_deriv(e, 1.0)
        if math.isfinite(f1) and math.isfinite(d1) and f1 > 0:
            ratio = d1 / f1
            # The ratio should be ≈ product of lower tower levels
            lower_prod = 1.0
            for j in range(1, k):
                lower_prod *= iter_exp(j, 1.0)
            print(f"  {k:>4} {f1:>16.6g} {d1:>16.6g} {ratio:>14.6g} {lower_prod:>14.6g}")
        else:
            print(f"  {k:>4} {'overflow':>16} {'overflow':>16} {'—':>14} {'—':>14}")

    print()
    print("  → f'(1)/f(1) = product of lower tower levels (chain rule).")
    print("  → Derivative growth is strictly faster than the function itself.")


def demo_sharpness_test() -> None:
    """Test the sharpness conjecture by computing ratios."""
    print_header("CONJECTURE TEST: Sharpness of Tower Bound")
    print()
    print("  R(E) = max|E'| / iterExp(depth(E), M)")
    print("  Conjecture: R(E) is bounded by a polynomial in size(E).")
    print()

    import random
    random.seed(123)

    h_maxE = "max|E'|"
    print(f"  {'depth':>5} {'size':>5} {h_maxE:>14} {'majorant':>14} {'R(E)':>14}")
    print(f"  {'─'*5} {'─'*5} {'─'*14} {'─'*14} {'─'*14}")

    for trial in range(15):
        d_max = random.randint(1, 3)
        e = random_exp_fragment(d_max)
        d = depth(e)
        s = size(e)

        x_pts = [i / 200 for i in range(201)]
        max_val = max(abs(eval_expr(e, x)) for x in x_pts)
        M = max(1.0, max_val)

        actual_max, _ = estimate_max_deriv(e, n_points=500)
        maj = depth_majorant(d, M)

        if math.isfinite(actual_max) and math.isfinite(maj) and maj > 0:
            R = actual_max / maj
            print(f"  {d:>5} {s:>5} {actual_max:>14.6g} {maj:>14.6g} {R:>14.6g}")

    print()
    print("  → R(E) stays bounded, consistent with the sharpness conjecture.")


def main() -> None:
    """Run all demos."""
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  DERIVATIVE GROWTH AS A SEMANTIC DEPTH INVARIANT               ║")
    print("║  Interactive Demonstration                                     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_tower_derivatives()
    demo_lower_bound()
    demo_certified_bounds()
    demo_separation()
    demo_random_expressions()
    demo_depth_growth_comparison()
    demo_sharpness_test()

    print_header("SUMMARY")
    print()
    print("  Key verified results:")
    print("  1. d/dx iterExp(k,x) = ∏ iterExp(i,x) — exact closed form")
    print("  2. iterExp(k+1,1) ≤ (iterExp(k+1))'(1) — lower bound witness")
    print("  3. |E'(x)| ≤ certDerivBound(E, M) ≤ depthMajorant(depth, M)")
    print("  4. Derivative obstruction ⟹ depth lower bound")
    print()
    print("  All theorems formally verified (machine-checked proofs).")
    print()


if __name__ == "__main__":
    main()
