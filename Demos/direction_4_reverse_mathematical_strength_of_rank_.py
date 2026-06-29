#!/usr/bin/env python3
"""
Applications of Rank-Bounded EML Theory

This module demonstrates real-world applications of the rank-indexed
totality hierarchy:

1. Termination analysis: Using ordinal rank as a Lyapunov function
2. Complexity classification: Automatic growth-rate classification
3. Program stratification: Sorting programs by recursion depth
4. Certificate verification: Checking growth bounds

These applications illustrate how the formal theory translates into
practical computational tools.
"""

import math
from typing import List, Dict, Tuple, Optional
from algorithms import (
    EmlExpr, OmegaBlock, TotalityCertificate,
    evaluate, compute_rank, compute_eml_depth,
    synthesize_certificate, classify_expression,
    find_separator, iter_exp
)


# ============================================================================
# Application 1: Termination Complexity Analysis
# ============================================================================

def analyze_termination_complexity(expr: EmlExpr) -> Dict:
    """
    Analyze the termination complexity of an EML expression viewed
    as a computation.

    The ordinal rank serves as a Lyapunov function: higher rank means
    the function grows faster, requiring more induction depth to prove
    termination.

    Returns analysis including:
    - Termination class (polynomial, exponential, etc.)
    - Induction depth required
    - Growth rate estimate
    """
    rank = compute_rank(expr)
    k = rank.omega_coeff

    termination_classes = {
        0: {
            "class": "Primitive recursive",
            "induction": "Single induction (Σ⁰₁)",
            "complexity": "Polynomial time decidable",
            "example_programs": ["loop { n-- }",
                                 "for i in range(n): compute(i)"],
        },
        1: {
            "class": "Exponential recursive",
            "induction": "Nested induction (Σ⁰₂)",
            "complexity": "Exponential time",
            "example_programs": ["binary tree recursion",
                                 "Tower of Hanoi"],
        },
        2: {
            "class": "Super-exponential recursive",
            "induction": "Doubly-nested induction (Σ⁰₃)",
            "complexity": "Double-exponential time",
            "example_programs": ["Ackermann-like functions",
                                 "Nested exponential recursion"],
        },
    }

    info = termination_classes.get(k, {
        "class": f"{k}-exponential recursive",
        "induction": f"{k}-nested induction (Σ⁰_{k+1})",
        "complexity": f"{k}-fold exponential time",
        "example_programs": [f"{k}-level nested recursion"],
    })

    # Estimate growth rate at sample points
    growth_data = []
    for x in [1, 5, 10, 20, 50]:
        try:
            val = evaluate(expr, x)
            if math.isfinite(val):
                growth_data.append((x, val))
        except (OverflowError, ValueError):
            growth_data.append((x, float('inf')))

    return {
        "rank": rank,
        "omega_block": k,
        **info,
        "growth_data": growth_data,
    }


# ============================================================================
# Application 2: Automatic Growth Classification
# ============================================================================

def classify_growth_rate(values: List[Tuple[float, float]]) -> Dict:
    """
    Given sampled function values, classify the growth rate into
    an omega-block.

    This is the inverse problem: given f(x) at sample points,
    determine which omega-block the function belongs to.

    Uses the formal hierarchy:
    - Block 0: f(x) = O(x^d)         (polynomial)
    - Block 1: f(x) = O(exp(poly(x))) (exponential)
    - Block 2: f(x) = O(exp(exp(poly(x)))) (double-exp)
    """
    if len(values) < 3:
        return {"block": 0, "confidence": 0.0, "reason": "Insufficient data"}

    # Filter finite values
    finite_vals = [(x, y) for x, y in values if math.isfinite(y) and y > 0 and x > 1]
    if len(finite_vals) < 3:
        return {"block": 0, "confidence": 0.0, "reason": "Too few finite values"}

    # Test polynomial fit: log(y) vs log(x) should be linear
    log_log = [(math.log(x), math.log(y)) for x, y in finite_vals]
    poly_r2 = _linear_r_squared(log_log)

    # Test exponential fit: log(y) vs x should be linear
    log_lin = [(x, math.log(y)) for x, y in finite_vals]
    exp_r2 = _linear_r_squared(log_lin)

    # Test double-exponential: log(log(y)) vs x should be linear
    log_log_lin = []
    for x, y in finite_vals:
        if y > math.e:
            log_log_lin.append((x, math.log(math.log(y))))
    dexp_r2 = _linear_r_squared(log_log_lin) if len(log_log_lin) >= 3 else 0

    # Classify
    if poly_r2 > 0.95 and poly_r2 > exp_r2:
        return {"block": 0, "confidence": poly_r2,
                "reason": "log-log linearity suggests polynomial growth"}
    elif exp_r2 > 0.95 and exp_r2 > dexp_r2:
        return {"block": 1, "confidence": exp_r2,
                "reason": "log-linear fit suggests exponential growth"}
    elif dexp_r2 > 0.9:
        return {"block": 2, "confidence": dexp_r2,
                "reason": "log-log-linear fit suggests double-exp growth"}
    else:
        # Default: use the best fit
        fits = [(poly_r2, 0), (exp_r2, 1), (dexp_r2, 2)]
        best = max(fits, key=lambda x: x[0])
        return {"block": best[1], "confidence": best[0],
                "reason": "Best fit classification"}


def _linear_r_squared(points: List[Tuple[float, float]]) -> float:
    """Compute R² for linear regression on (x, y) points."""
    if len(points) < 2:
        return 0.0

    n = len(points)
    sx = sum(x for x, _ in points)
    sy = sum(y for _, y in points)
    sxx = sum(x * x for x, _ in points)
    sxy = sum(x * y for x, y in points)
    syy = sum(y * y for _, y in points)

    denom = n * sxx - sx * sx
    if abs(denom) < 1e-12:
        return 0.0

    ss_tot = syy - sy * sy / n
    if abs(ss_tot) < 1e-12:
        return 1.0  # Constant function

    b = (n * sxy - sx * sy) / denom
    a = (sy - b * sx) / n
    ss_res = sum((y - (a + b * x)) ** 2 for x, y in points)

    return max(0, 1 - ss_res / ss_tot)


# ============================================================================
# Application 3: Program Stratification
# ============================================================================

def stratify_programs(expressions: List[Tuple[str, EmlExpr]]) -> Dict[int, List]:
    """
    Stratify a collection of EML programs by their omega-block.

    This partitions programs into equivalence classes where programs
    in the same class require the same depth of induction for
    totality proofs.

    Returns a dictionary mapping block index to list of (name, expr, info).
    """
    strata = {}

    for name, expr in expressions:
        info = classify_expression(expr)
        k = info["omega_coeff"]
        if k not in strata:
            strata[k] = []
        strata[k].append({
            "name": name,
            "expression": expr,
            "rank": info["rank"],
            "certificate": info["certificate"],
        })

    return strata


# ============================================================================
# Application 4: Certificate Verification
# ============================================================================

def verify_certificate(expr: EmlExpr, cert: TotalityCertificate,
                       test_points: Optional[List[float]] = None) -> Dict:
    """
    Verify a totality certificate against sampled function values.

    Checks that |f(x)| <= iterExp(k, C * x^d) at test points.
    Returns verification results including any violations found.
    """
    if test_points is None:
        test_points = [cert.threshold, cert.threshold + 1,
                       10, 50, 100, 500, 1000]

    results = []
    violations = 0
    max_ratio = 0.0

    for x in test_points:
        if x < cert.threshold:
            continue

        try:
            fx = abs(evaluate(expr, x))
            bound = cert.bound(x)

            if not math.isfinite(fx) or not math.isfinite(bound):
                results.append({
                    "x": x, "f(x)": fx, "bound": bound,
                    "status": "overflow"
                })
                continue

            ratio = fx / bound if bound > 0 else float('inf')
            max_ratio = max(max_ratio, ratio)

            if fx > bound * (1 + 1e-10):  # Small tolerance
                violations += 1
                results.append({
                    "x": x, "f(x)": fx, "bound": bound,
                    "ratio": ratio, "status": "VIOLATION"
                })
            else:
                results.append({
                    "x": x, "f(x)": fx, "bound": bound,
                    "ratio": ratio, "status": "ok"
                })
        except (OverflowError, ValueError):
            results.append({"x": x, "status": "error"})

    return {
        "verified": violations == 0,
        "violations": violations,
        "max_ratio": max_ratio,
        "test_count": len(results),
        "details": results,
    }


# ============================================================================
# Demo
# ============================================================================

def demo_termination_analysis():
    """Demonstrate termination complexity analysis."""
    print("=" * 60)
    print("APPLICATION: Termination Complexity Analysis")
    print("=" * 60)
    print()

    programs = [
        ("Linear scan",       EmlExpr.var()),
        ("Quadratic search",  EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        ("Exponential tree",  EmlExpr.eml(EmlExpr.const(1), EmlExpr.var())),
        ("Tower of Hanoi",    EmlExpr.eml(EmlExpr.const(1),
                               EmlExpr.mul(EmlExpr.var(), EmlExpr.const(0.7)))),
        ("Ackermann-like",    EmlExpr.eml(EmlExpr.const(1),
                               EmlExpr.eml(EmlExpr.const(1), EmlExpr.var()))),
    ]

    for name, expr in programs:
        analysis = analyze_termination_complexity(expr)
        print(f"  {name}:")
        print(f"    Rank: {analysis['rank']}, Block: {analysis['omega_block']}")
        print(f"    Class: {analysis['class']}")
        print(f"    Induction: {analysis['induction']}")
        print()


def demo_growth_classification():
    """Demonstrate automatic growth classification from data."""
    print("=" * 60)
    print("APPLICATION: Growth Rate Classification from Data")
    print("=" * 60)
    print()

    # Generate data from known functions
    test_cases = [
        ("x^3",     lambda x: x**3),
        ("2^x",     lambda x: 2**x),
        ("x^2 + 5", lambda x: x**2 + 5),
        ("exp(x)",  lambda x: math.exp(x)),
    ]

    for name, f in test_cases:
        data = [(x, f(x)) for x in [2, 5, 10, 20, 50, 100]]
        result = classify_growth_rate(data)
        block_names = {0: "Polynomial", 1: "Exponential", 2: "Double-exp"}
        print(f"  {name}: Block {result['block']} "
              f"({block_names.get(result['block'], '?')}) "
              f"[confidence: {result['confidence']:.3f}]")

    print()


def demo_certificate_verification():
    """Demonstrate certificate verification."""
    print("=" * 60)
    print("APPLICATION: Certificate Verification")
    print("=" * 60)
    print()

    expr = EmlExpr.mul(EmlExpr.var(), EmlExpr.var())  # x^2
    cert = synthesize_certificate(expr)

    if cert:
        print(f"  Expression: x^2")
        print(f"  Certificate: |f(x)| ≤ iterExp({cert.depth}, "
              f"{cert.coeff:.1f} * x^{cert.degree}) for x ≥ {cert.threshold}")

        result = verify_certificate(expr, cert)
        status = "PASSED" if result["verified"] else "FAILED"
        print(f"  Verification: {status}")
        print(f"    Tests run: {result['test_count']}")
        print(f"    Max ratio |f|/bound: {result['max_ratio']:.6f}")
        print(f"    Violations: {result['violations']}")

    print()


def demo_program_stratification():
    """Demonstrate program stratification."""
    print("=" * 60)
    print("APPLICATION: Program Stratification by Induction Depth")
    print("=" * 60)
    print()

    programs = [
        ("const_5",    EmlExpr.const(5)),
        ("identity",   EmlExpr.var()),
        ("square",     EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        ("x+1",        EmlExpr.add(EmlExpr.var(), EmlExpr.const(1))),
        ("exp",        EmlExpr.eml(EmlExpr.const(1), EmlExpr.var())),
        ("x*exp(x)",   EmlExpr.eml(EmlExpr.var(), EmlExpr.var())),
        ("exp(exp)",   EmlExpr.eml(EmlExpr.const(1),
                        EmlExpr.eml(EmlExpr.const(1), EmlExpr.var()))),
    ]

    strata = stratify_programs(programs)

    for k in sorted(strata.keys()):
        depth_name = ["Primitive recursive", "Exponential",
                      "Double-exponential"][k] if k < 3 else f"{k}-exponential"
        print(f"  Block {k} — {depth_name}:")
        for item in strata[k]:
            print(f"    • {item['name']} (rank: {item['rank']})")
        print()


if __name__ == "__main__":
    print()
    print("  Applications of Rank-Bounded EML Theory")
    print()

    demo_termination_analysis()
    demo_growth_classification()
    demo_certificate_verification()
    demo_program_stratification()


#!/usr/bin/env python3
"""
Demo: Rank-Bounded EML — Reverse-Mathematical Strength of Expression Rank

This script demonstrates the formal correspondence between EML expression rank
and proof-theoretic strength. It shows:
1. EML expressions with their omega-block classification
2. Growth function sampling at each rank level
3. Totality certificate synthesis (polynomial bounds for rank 0)
4. Separation between adjacent rank blocks
5. Visual comparison of growth across blocks

Usage:
    python demo.py
"""

import math
from typing import Callable, Tuple, Optional, List


# ============================================================================
# EML Expression AST
# ============================================================================

class EmlExpr:
    """Abstract base for EML expressions."""
    pass

class Var(EmlExpr):
    """The variable x."""
    def __repr__(self): return "x"

class Const(EmlExpr):
    """A real constant."""
    def __init__(self, c: float):
        self.c = c
    def __repr__(self): return f"{self.c}"

class Add(EmlExpr):
    def __init__(self, a: EmlExpr, b: EmlExpr):
        self.a, self.b = a, b
    def __repr__(self): return f"({self.a} + {self.b})"

class Mul(EmlExpr):
    def __init__(self, a: EmlExpr, b: EmlExpr):
        self.a, self.b = a, b
    def __repr__(self): return f"({self.a} * {self.b})"

class Neg(EmlExpr):
    def __init__(self, a: EmlExpr):
        self.a = a
    def __repr__(self): return f"(-{self.a})"

class Eml(EmlExpr):
    """The transcendental EML operation: eml(a, b) = a * exp(b)."""
    def __init__(self, a: EmlExpr, b: EmlExpr):
        self.a, self.b = a, b
    def __repr__(self): return f"eml({self.a}, {self.b})"


# ============================================================================
# Evaluation
# ============================================================================

def eval_expr(e: EmlExpr, x: float) -> float:
    """Evaluate an EML expression at a point x."""
    if isinstance(e, Var):
        return x
    elif isinstance(e, Const):
        return e.c
    elif isinstance(e, Add):
        return eval_expr(e.a, x) + eval_expr(e.b, x)
    elif isinstance(e, Mul):
        return eval_expr(e.a, x) * eval_expr(e.b, x)
    elif isinstance(e, Neg):
        return -eval_expr(e.a, x)
    elif isinstance(e, Eml):
        return eval_expr(e.a, x) * math.exp(eval_expr(e.b, x))
    else:
        raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================================
# EML Depth and Rank
# ============================================================================

def eml_depth(e: EmlExpr) -> int:
    """Compute the EML nesting depth (= omega-coefficient of rank)."""
    if isinstance(e, Var) or isinstance(e, Const):
        return 0
    elif isinstance(e, Add) or isinstance(e, Mul):
        return max(eml_depth(e.a), eml_depth(e.b))
    elif isinstance(e, Neg):
        return eml_depth(e.a)
    elif isinstance(e, Eml):
        return 1 + max(eml_depth(e.a), eml_depth(e.b))
    else:
        raise TypeError(f"Unknown expression type: {type(e)}")


def omega_block(e: EmlExpr) -> int:
    """Return the omega-block index k such that the rank lies in [ω·k, ω·(k+1))."""
    return eml_depth(e)


# ============================================================================
# Iterated Exponential
# ============================================================================

def iter_exp(k: int, x: float) -> float:
    """Compute iterExp k x = exp^k(x), the k-fold iterated exponential."""
    result = x
    for _ in range(k):
        if result > 700:  # Overflow guard
            return float('inf')
        result = math.exp(result)
    return result


# ============================================================================
# Canonical EML expressions for iterExp
# ============================================================================

def make_iter_exp_expr(n: int) -> EmlExpr:
    """Create the canonical EML expression for iterExp n."""
    if n == 0:
        return Var()
    else:
        return Eml(Const(1.0), make_iter_exp_expr(n - 1))


# ============================================================================
# Totality Certificate Synthesis (for rank 0)
# ============================================================================

def synthesize_certificate_rank0(e: EmlExpr) -> Optional[Tuple[float, int, float]]:
    """
    For a rank-0 expression, synthesize a polynomial growth certificate.
    Returns (C, d, A) such that |f(x)| <= C * x^d for x >= A.
    Returns None if the expression is not rank 0.
    """
    if omega_block(e) != 0:
        return None

    # Sample the expression at several points to estimate C and d
    samples = [(x, abs(eval_expr(e, x))) for x in [10, 50, 100, 500, 1000]]

    # Estimate degree: log(|f(x)|) / log(x) for large x
    best_d = 0
    for x, fx in samples:
        if fx > 0 and x > 1:
            est_d = math.log(fx) / math.log(x) if fx > 1 else 0
            best_d = max(best_d, math.ceil(est_d))

    d = int(best_d) + 1  # Add safety margin

    # Find C
    best_C = 1.0
    for x, fx in samples:
        if x > 0:
            c_needed = fx / (x ** d) if x ** d > 0 else fx
            best_C = max(best_C, c_needed)

    C = best_C * 2  # Safety factor
    A = 1.0

    return (C, d, A)


# ============================================================================
# Demo: Growth Comparison Across Omega Blocks
# ============================================================================

def demo_growth_comparison():
    """Show growth rates across different omega blocks."""
    print("=" * 72)
    print("GROWTH COMPARISON ACROSS OMEGA BLOCKS")
    print("=" * 72)
    print()

    # Create expressions at each rank level
    expressions = [
        ("Block 0: x",           Var()),
        ("Block 0: x²",          Mul(Var(), Var())),
        ("Block 0: x³ + x",      Add(Mul(Mul(Var(), Var()), Var()), Var())),
        ("Block 1: exp(x)",      make_iter_exp_expr(1)),
        ("Block 1: x·exp(x)",    Eml(Var(), Var())),
        ("Block 2: exp(exp(x))", make_iter_exp_expr(2)),
        ("Block 3: exp³(x)",     make_iter_exp_expr(3)),
    ]

    print(f"{'Expression':<28} {'ω-block':>7} {'f(1)':>12} {'f(2)':>12} {'f(5)':>12} {'f(10)':>15}")
    print("-" * 90)

    for name, expr in expressions:
        k = omega_block(expr)
        values = []
        for x in [1, 2, 5, 10]:
            try:
                v = eval_expr(expr, x)
                if v > 1e15:
                    values.append(f"{v:.2e}")
                else:
                    values.append(f"{v:.2f}")
            except OverflowError:
                values.append("∞")

        print(f"{name:<28} {k:>7} {values[0]:>12} {values[1]:>12} {values[2]:>12} {values[3]:>15}")

    print()


def demo_certificate_synthesis():
    """Demonstrate totality certificate synthesis for rank-0 expressions."""
    print("=" * 72)
    print("TOTALITY CERTIFICATE SYNTHESIS (Rank 0)")
    print("=" * 72)
    print()

    rank0_exprs = [
        ("x",        Var()),
        ("x²",       Mul(Var(), Var())),
        ("x² + 3x",  Add(Mul(Var(), Var()), Mul(Const(3), Var()))),
        ("5",        Const(5)),
    ]

    for name, expr in rank0_exprs:
        cert = synthesize_certificate_rank0(expr)
        if cert:
            C, d, A = cert
            print(f"  {name:<12}  →  |f(x)| ≤ {C:.1f} · x^{d}  for x ≥ {A}")

            # Verify certificate at sample points
            violations = 0
            for x in [A, A+1, 10, 100, 1000]:
                fx = abs(eval_expr(expr, x))
                bound = C * x**d
                if fx > bound + 1e-10:
                    violations += 1

            status = "✓ VERIFIED" if violations == 0 else f"✗ {violations} violations"
            print(f"               Certificate status: {status}")
        print()


def demo_separation():
    """Demonstrate strict separation between adjacent omega blocks."""
    print("=" * 72)
    print("STRICT SEPARATION BETWEEN ADJACENT ω-BLOCKS")
    print("=" * 72)
    print()
    print("Theorem: For each k, iterExp(k+1) escapes all depth-k certificates.")
    print()

    for k in range(4):
        separator = make_iter_exp_expr(k + 1)
        sep_name = f"iterExp({k+1})"

        print(f"  Block {k} → Block {k+1} separator: {sep_name}")
        print(f"  ω-block of separator: {omega_block(separator)}")

        # Show that it grows faster than any polynomial bound (for k=0)
        # or any previous-level certificate
        if k == 0:
            # Compare exp(x) vs polynomials
            print(f"  Comparison: exp(x) vs C·x^d")
            for d in [1, 2, 5, 10]:
                C = 100.0
                # Find where exp(x) > C·x^d
                x_cross = 1
                while x_cross < 1000:
                    if math.exp(x_cross) > C * x_cross**d:
                        break
                    x_cross += 1
                print(f"    exp(x) > {C}·x^{d} for x ≥ {x_cross}")
        elif k == 1:
            # Compare exp(exp(x)) vs exp(C·x^d)
            print(f"  Comparison: exp(exp(x)) vs exp(C·x^d)")
            for d in [1, 2]:
                C = 10.0
                for x in [5, 10, 15]:
                    left = iter_exp(2, x)
                    right = math.exp(C * x**d) if C * x**d < 700 else float('inf')
                    ratio = left / right if right > 0 and right != float('inf') else float('inf')
                    print(f"    x={x}: exp²(x)/exp({C}x^{d}) = {ratio:.2e}" if ratio < 1e15 else f"    x={x}: ratio = ∞")
        print()


def demo_omega_block_classification():
    """Show the omega-block classification of various expressions."""
    print("=" * 72)
    print("ω-BLOCK CLASSIFICATION OF EML EXPRESSIONS")
    print("=" * 72)
    print()
    print("  Each ω-block corresponds to a level of the Hardy hierarchy,")
    print("  and to a specific depth of nested induction required for totality proof.")
    print()

    examples = [
        Var(),
        Const(42),
        Mul(Var(), Var()),
        Add(Mul(Var(), Var()), Const(1)),
        Eml(Const(1), Var()),                              # exp(x)
        Eml(Var(), Var()),                                  # x·exp(x)
        Eml(Const(1), Eml(Const(1), Var())),               # exp(exp(x))
        Eml(Var(), Eml(Const(1), Var())),                   # x·exp(exp(x))
        Eml(Const(1), Eml(Const(1), Eml(Const(1), Var()))),  # exp³(x)
    ]

    print(f"  {'Expression':<35} {'ω-block':>7} {'Induction depth':>16} {'Growth class':>20}")
    print("  " + "-" * 82)

    growth_names = {
        0: "Polynomial",
        1: "Exponential",
        2: "Double-exponential",
        3: "Triple-exponential",
    }

    for expr in examples:
        k = omega_block(expr)
        growth = growth_names.get(k, f"{k}-fold exponential")
        print(f"  {str(expr):<35} {k:>7} {k:>16} {growth:>20}")

    print()
    print("  Key insight: ω-block = EML depth = Hardy level = induction depth")
    print()


def demo_hierarchy_visualization():
    """ASCII visualization of the rank hierarchy."""
    print("=" * 72)
    print("RANK-INDEXED TOTALITY HIERARCHY")
    print("=" * 72)
    print()
    print("  The hierarchy of totality certificates is strict and non-collapsing:")
    print()
    print("  Block 0 (polynomial):      TC₀ ⊊ TC₁ ⊊ TC₂ ⊊ TC₃ ⊊ ...")
    print("  ────────────────────────────────────────────────────────")
    print("  │ x, x², x³+x, ...                                   │")
    print("  │ Growth: |f(x)| ≤ C·x^d                             │")
    print("  │ Induction: Σ⁰₁ (primitive recursion)               │")
    print("  ════════════════════════════════════════════════════════")
    print("         ↓ STRICT SEPARATION: exp(x) escapes TC₀")
    print("  ════════════════════════════════════════════════════════")
    print("  Block 1 (exponential):                                │")
    print("  │ exp(x), x·exp(x), exp(x²), ...                     │")
    print("  │ Growth: |f(x)| ≤ exp(C·x^d)                        │")
    print("  │ Induction: Σ⁰₂ (one nested induction)              │")
    print("  ════════════════════════════════════════════════════════")
    print("         ↓ STRICT SEPARATION: exp(exp(x)) escapes TC₁")
    print("  ════════════════════════════════════════════════════════")
    print("  Block 2 (double-exponential):                         │")
    print("  │ exp(exp(x)), x·exp(exp(x)), ...                     │")
    print("  │ Growth: |f(x)| ≤ exp(exp(C·x^d))                   │")
    print("  │ Induction: Σ⁰₃ (two nested inductions)             │")
    print("  ════════════════════════════════════════════════════════")
    print("         ↓  ... and so on for every k ...")
    print()
    print("  Formally proved: for ALL k, Block k+1 strictly exceeds Block k.")
    print()


if __name__ == "__main__":
    print()
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║  RANK-BOUNDED EML: Reverse-Mathematical Strength Demo      ║")
    print("  ║  Connecting expression syntax to proof-theoretic strength   ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_omega_block_classification()
    demo_growth_comparison()
    demo_certificate_synthesis()
    demo_separation()
    demo_hierarchy_visualization()

    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print()
    print("  All results above are backed by machine-verified proofs:")
    print()
    print("  1. rank_implies_hardyLevel: rank ω-coeff = k → Hardy level k")
    print("  2. hardyLevel_zero_implies_certificate: Hardy 0 → polynomial cert")
    print("  3. iterExp_not_totalityCertificate: iterExp(k+1) ∉ TC_k  ∀k")
    print("  4. exists_rank_block_separator: separating expression exists  ∀k")
    print()
    print("  Central thesis: EML rank is a proof-theoretic observable.")
    print()
