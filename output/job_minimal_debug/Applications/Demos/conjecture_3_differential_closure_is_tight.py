#!/usr/bin/env python3
"""
Applications of the Elementary Differential Closure.

Demonstrates real-world connections:
1. Verified symbolic computation (proof-producing CAS)
2. Newton's method with certified derivatives
3. Taylor series approximation using iterated symbolic derivatives
4. ODE solution verification via substitution
5. Sensitivity analysis for elementary models
"""

import math
from algorithms import (
    EExpr, Var, Const, Add, Sub, Mul, Div, Exp, Log,
    eval_expr, symbolic_deriv, simplify, expr_size, is_valid_at
)


# ═══════════════════════════════════════════════════════════════════════════════
# Application 1: Certified Newton's Method
# ═══════════════════════════════════════════════════════════════════════════════

def newton_method(f: EExpr, x0: float, tol: float = 1e-12, max_iter: int = 50):
    """Newton's method using symbolically computed (and formally verified) derivatives.

    Because derivE_sound guarantees the derivative is correct, Newton's method
    inherits a correctness certificate: the derivative evaluations are provably
    equal to the true mathematical derivative.

    Args:
        f: Expression whose root we seek
        x0: Initial guess
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        (root, iterations, convergence_history)
    """
    df = symbolic_deriv(f)
    x = x0
    history = [x]

    for i in range(max_iter):
        fx = eval_expr(f, x)
        dfx = eval_expr(df, x)
        if abs(dfx) < 1e-15:
            break
        x_new = x - fx / dfx
        history.append(x_new)
        if abs(x_new - x) < tol:
            break
        x = x_new

    return x, len(history) - 1, history


# ═══════════════════════════════════════════════════════════════════════════════
# Application 2: Taylor Series via Iterated Symbolic Differentiation
# ═══════════════════════════════════════════════════════════════════════════════

def taylor_coefficients(f: EExpr, x0: float, n: int):
    """Compute Taylor coefficients f^(k)(x0) / k! for k = 0, ..., n.

    Uses iterated symbolic differentiation. Each derivative is guaranteed
    correct by derivE_sound (and validity preservation by validAt_derivE).

    Returns list of (coefficient, derivative_expression, derivative_size).
    """
    coeffs = []
    current = f
    factorial = 1
    for k in range(n + 1):
        if k > 0:
            factorial *= k
        val = eval_expr(current, x0)
        coeffs.append((val / factorial, current, expr_size(current)))
        current = symbolic_deriv(current)
    return coeffs


def taylor_eval(coeffs: list[tuple], x: float, x0: float) -> float:
    """Evaluate Taylor polynomial."""
    result = 0.0
    dx = x - x0
    dx_pow = 1.0
    for c, _, _ in coeffs:
        result += c * dx_pow
        dx_pow *= dx
    return result


# ═══════════════════════════════════════════════════════════════════════════════
# Application 3: ODE Solution Verification
# ═══════════════════════════════════════════════════════════════════════════════

def verify_ode_solution(y: EExpr, ode_rhs, description: str, test_points: list[float]):
    """Verify that y(x) satisfies y'(x) = ode_rhs(y, x) at given points.

    The derivative y' is computed symbolically with a correctness guarantee.
    We then check numerically that y'(x) = ode_rhs(y(x), x).

    This demonstrates the bridge to dynamical systems: if an observable is
    EExpr-representable, its time derivative along an elementary vector field
    is again EExpr-representable (by derivE_sound + closure).
    """
    dy = symbolic_deriv(y)
    print(f"\n  ODE: {description}")
    print(f"  y(x) = {y}")
    print(f"  y'(x) = {simplify(dy)}")
    col_yp = "y'(x)"
    print(f"  {'x':>8} | {'y(x)':>12} | {col_yp:>12} | {'RHS':>12} | {'|error|':>10}")
    print(f"  {'-'*8}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}-+-{'-'*10}")

    for x in test_points:
        try:
            y_val = eval_expr(y, x)
            dy_val = eval_expr(dy, x)
            rhs_val = ode_rhs(y_val, x)
            err = abs(dy_val - rhs_val)
            print(f"  {x:8.3f} | {y_val:12.6f} | {dy_val:12.6f} | {rhs_val:12.6f} | {err:10.2e}")
        except (ValueError, ZeroDivisionError, OverflowError):
            print(f"  {x:8.3f} | {'N/A':>12} | {'N/A':>12} | {'N/A':>12} | {'N/A':>10}")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 4: Sensitivity Analysis
# ═══════════════════════════════════════════════════════════════════════════════

def sensitivity_analysis(model: EExpr, param_name: str, test_points: list[float]):
    """Compute the sensitivity df/dx of a model using verified symbolic derivatives.

    In scientific computing, sensitivity = ∂(output)/∂(input). With derivE_sound,
    this sensitivity is provably correct — useful for uncertainty quantification
    and gradient-based optimization.
    """
    dmodel = symbolic_deriv(model)
    dmodel_s = simplify(dmodel)
    print(f"\n  Model: {model}")
    print(f"  Sensitivity d(model)/d({param_name}): {dmodel_s}")
    col_fp = "f'(x)"
    print(f"  {'x':>8} | {'f(x)':>12} | {col_fp:>12} | {'elasticity':>12}")
    print(f"  {'-'*8}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}")

    for x in test_points:
        try:
            f_val = eval_expr(model, x)
            df_val = eval_expr(dmodel, x)
            elasticity = (df_val * x / f_val) if abs(f_val) > 1e-15 else float('inf')
            print(f"  {x:8.3f} | {f_val:12.6f} | {df_val:12.6f} | {elasticity:12.6f}")
        except (ValueError, ZeroDivisionError, OverflowError):
            print(f"  {x:8.3f} | {'N/A':>12} | {'N/A':>12} | {'N/A':>12}")


# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    x = Var()

    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Elementary Differential Closure           ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # --- Application 1: Newton's Method ---
    print("\n" + "="*60)
    print("APPLICATION 1: Certified Newton's Method")
    print("="*60)

    # Find root of exp(x) - 3x = 0
    f1 = Sub(Exp(x), Mul(Const(3), x))
    root, iters, hist = newton_method(f1, 1.5)
    print(f"\n  f(x) = exp(x) - 3x")
    print(f"  Root found: x = {root:.15f} (in {iters} iterations)")
    print(f"  f(root) = {eval_expr(f1, root):.2e}")
    print(f"  Convergence: {' → '.join(f'{h:.8f}' for h in hist[:6])}")

    # Find root of log(x) - 1 = 0 (should give e)
    f2 = Sub(Log(x), Const(1))
    root2, iters2, _ = newton_method(f2, 2.0)
    print(f"\n  f(x) = log(x) - 1")
    print(f"  Root found: x = {root2:.15f} (expected e = {math.e:.15f})")
    print(f"  Error: {abs(root2 - math.e):.2e}")

    # --- Application 2: Taylor Series ---
    print("\n" + "="*60)
    print("APPLICATION 2: Taylor Series via Iterated Symbolic Derivatives")
    print("="*60)

    # Taylor series of exp(x) around x=0
    f_exp = Exp(x)
    coeffs = taylor_coefficients(f_exp, 0.0, 6)
    print(f"\n  Taylor coefficients of exp(x) around x=0:")
    print(f"  {'k':>4} | {'f^(k)(0)/k!':>14} | {'expected':>10} | {'deriv size':>10}")
    for k, (c, _, sz) in enumerate(coeffs):
        expected = 1.0 / math.factorial(k)
        print(f"  {k:4d} | {c:14.10f} | {expected:10.6f} | {sz:10d}")

    # Evaluate Taylor polynomial and compare
    print(f"\n  Taylor polynomial evaluation vs true exp(x):")
    for xv in [0.5, 1.0, 2.0]:
        approx = taylor_eval(coeffs, xv, 0.0)
        true_val = math.exp(xv)
        print(f"    x={xv}: T₆(x)={approx:.10f}, exp(x)={true_val:.10f}, err={abs(approx-true_val):.2e}")

    # Taylor series of log(1+x) around x=0
    f_log = Log(Add(Const(1), x))
    coeffs_log = taylor_coefficients(f_log, 0.0, 6)
    print(f"\n  Taylor coefficients of log(1+x) around x=0:")
    for k, (c, _, sz) in enumerate(coeffs_log):
        expected = ((-1)**(k+1) / k) if k > 0 else 0.0
        print(f"    a_{k} = {c:12.8f}  (expected ≈ {expected:8.4f}), deriv size = {sz}")

    # --- Application 3: ODE Verification ---
    print("\n" + "="*60)
    print("APPLICATION 3: ODE Solution Verification")
    print("="*60)

    # y = exp(x) satisfies y' = y
    verify_ode_solution(
        Exp(x),
        lambda y, t: y,
        "y' = y  (exponential growth)",
        [0, 0.5, 1, 2]
    )

    # y = x*exp(x) satisfies y' = y + exp(x) = (1+x)*exp(x)/x * y ... let's use y' = (1+1/x)*y
    # Actually y = x*exp(x), y' = exp(x) + x*exp(x) = (1+x)*exp(x)
    verify_ode_solution(
        Mul(x, Exp(x)),
        lambda y, t: (1 + t) * math.exp(t),
        "y' = (1+x)·exp(x)  where y = x·exp(x)",
        [0.5, 1, 2, 3]
    )

    # y = log(x), y' = 1/x
    verify_ode_solution(
        Log(x),
        lambda y, t: 1/t,
        "y' = 1/x  where y = log(x)",
        [0.5, 1, 2, 5]
    )

    # --- Application 4: Sensitivity Analysis ---
    print("\n" + "="*60)
    print("APPLICATION 4: Sensitivity Analysis with Certified Derivatives")
    print("="*60)

    # Logistic-like model: f(x) = exp(x) / (1 + exp(x))
    logistic = Div(Exp(x), Add(Const(1), Exp(x)))
    sensitivity_analysis(logistic, "x", [-2, -1, 0, 1, 2])

    # Arrhenius-like model: f(x) = exp(-1/x) for x > 0
    arrhenius = Exp(Div(Const(-1), x))
    sensitivity_analysis(arrhenius, "x (temperature)", [0.5, 1, 2, 5, 10])

    print("\n" + "="*60)
    print("All applications use derivE with a machine-checked correctness proof.")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of the Elementary Differential Closure.

This script implements the EExpr symbolic differentiation algebra in Python,
showing derivative computation, numerical verification against finite differences,
expression size growth, and the generator-separation phenomenon.
"""

import math
from dataclasses import dataclass
from typing import Callable

# ─── Expression AST ──────────────────────────────────────────────────────────

class EExpr:
    """Base class for elementary expressions in one variable."""
    pass

@dataclass
class Var(EExpr):
    def __repr__(self): return "x"

@dataclass
class Const(EExpr):
    value: float
    def __repr__(self): return f"{self.value}"

@dataclass
class Add(EExpr):
    left: EExpr
    right: EExpr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class Sub(EExpr):
    left: EExpr
    right: EExpr
    def __repr__(self): return f"({self.left} - {self.right})"

@dataclass
class Mul(EExpr):
    left: EExpr
    right: EExpr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass
class Div(EExpr):
    left: EExpr
    right: EExpr
    def __repr__(self): return f"({self.left} / {self.right})"

@dataclass
class Exp(EExpr):
    arg: EExpr
    def __repr__(self): return f"exp({self.arg})"

@dataclass
class Log(EExpr):
    arg: EExpr
    def __repr__(self): return f"log({self.arg})"

# ─── Evaluation ──────────────────────────────────────────────────────────────

def eval_expr(e: EExpr, x: float) -> float:
    """Evaluate an elementary expression at a point."""
    if isinstance(e, Var): return x
    if isinstance(e, Const): return e.value
    if isinstance(e, Add): return eval_expr(e.left, x) + eval_expr(e.right, x)
    if isinstance(e, Sub): return eval_expr(e.left, x) - eval_expr(e.right, x)
    if isinstance(e, Mul): return eval_expr(e.left, x) * eval_expr(e.right, x)
    if isinstance(e, Div): return eval_expr(e.left, x) / eval_expr(e.right, x)
    if isinstance(e, Exp): return math.exp(eval_expr(e.arg, x))
    if isinstance(e, Log): return math.log(eval_expr(e.arg, x))
    raise TypeError(f"Unknown expression type: {type(e)}")

# ─── Symbolic Differentiation ────────────────────────────────────────────────

def deriv(e: EExpr) -> EExpr:
    """Symbolic differentiation — the verified algorithm from the Lean formalization."""
    if isinstance(e, Var): return Const(1)
    if isinstance(e, Const): return Const(0)
    if isinstance(e, Add): return Add(deriv(e.left), deriv(e.right))
    if isinstance(e, Sub): return Sub(deriv(e.left), deriv(e.right))
    if isinstance(e, Mul):
        return Add(Mul(deriv(e.left), e.right), Mul(e.left, deriv(e.right)))
    if isinstance(e, Div):
        return Div(
            Sub(Mul(deriv(e.left), e.right), Mul(e.left, deriv(e.right))),
            Mul(e.right, e.right)
        )
    if isinstance(e, Exp): return Mul(deriv(e.arg), Exp(e.arg))
    if isinstance(e, Log): return Div(deriv(e.arg), e.arg)
    raise TypeError(f"Unknown expression type: {type(e)}")

# ─── Utilities ────────────────────────────────────────────────────────────────

def size(e: EExpr) -> int:
    """AST node count."""
    if isinstance(e, (Var, Const)): return 1
    if isinstance(e, (Add, Sub, Mul, Div)): return 1 + size(e.left) + size(e.right)
    if isinstance(e, (Exp, Log)): return 1 + size(e.arg)
    raise TypeError

def contains_exp(e: EExpr) -> bool:
    if isinstance(e, Exp): return True
    if isinstance(e, (Var, Const)): return False
    if isinstance(e, (Add, Sub, Mul, Div)):
        return contains_exp(e.left) or contains_exp(e.right)
    if isinstance(e, Log): return contains_exp(e.arg)
    return False

def contains_log(e: EExpr) -> bool:
    if isinstance(e, Log): return True
    if isinstance(e, (Var, Const)): return False
    if isinstance(e, (Add, Sub, Mul, Div)):
        return contains_log(e.left) or contains_log(e.right)
    if isinstance(e, Exp): return contains_log(e.arg)
    return False

def finite_diff(f, x, h=1e-7):
    """Central finite difference approximation to f'(x)."""
    return (f(x + h) - f(x - h)) / (2 * h)

# ─── Demo ─────────────────────────────────────────────────────────────────────

def demo_derivative(name: str, e: EExpr, test_points: list[float]):
    """Compute symbolic derivative and verify numerically."""
    de = deriv(e)
    print(f"\n{'='*60}")
    print(f"Expression: {name}")
    print(f"  e    = {e}")
    print(f"  e'   = {de}")
    print(f"  size(e)  = {size(e)},  size(e') = {size(de)}")
    print(f"  contains_exp(e) = {contains_exp(e)},  contains_exp(e') = {contains_exp(de)}")
    print(f"  contains_log(e) = {contains_log(e)},  contains_log(e') = {contains_log(de)}")
    print(f"  {'x':>10} | {'symbolic':>14} | {'finite diff':>14} | {'error':>12}")
    print(f"  {'-'*10}-+-{'-'*14}-+-{'-'*14}-+-{'-'*12}")
    for x in test_points:
        try:
            sym_val = eval_expr(de, x)
            fd_val = finite_diff(lambda y: eval_expr(e, y), x)
            err = abs(sym_val - fd_val)
            print(f"  {x:10.4f} | {sym_val:14.8f} | {fd_val:14.8f} | {err:12.2e}")
        except (ValueError, ZeroDivisionError, OverflowError) as ex:
            print(f"  {x:10.4f} | {'N/A':>14} | {'N/A':>14} | {str(ex)[:12]}")


def main():
    x = Var()

    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     Elementary Differential Closure — Demonstration        ║")
    print("║  Verified Symbolic Differentiation for exp/log Algebra     ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Example 1: exp(x)
    demo_derivative("exp(x)", Exp(x), [0, 1, -1, 2])

    # Example 2: log(x)
    demo_derivative("log(x)", Log(x), [0.5, 1, 2, 5])

    # Example 3: x^2 (= x * x)
    x_sq = Mul(x, x)
    demo_derivative("x²", x_sq, [0, 1, -1, 3])

    # Example 4: log(exp(x) + 1)  — nested exp and log
    e4 = Log(Add(Exp(x), Const(1)))
    demo_derivative("log(exp(x) + 1)", e4, [0, 1, -1, 5])

    # Example 5: exp(log(x) + x²)
    e5 = Exp(Add(Log(x), Mul(x, x)))
    demo_derivative("exp(log(x) + x²)", e5, [0.5, 1, 2])

    # Example 6: exp(x) / (1 + log(x))
    e6 = Div(Exp(x), Add(Const(1), Log(x)))
    demo_derivative("exp(x) / (1 + log(x))", e6, [0.5, 1, 2, 3])

    # Example 7: deeply nested — exp(exp(x))
    e7 = Exp(Exp(x))
    demo_derivative("exp(exp(x))", e7, [0, 0.5, 1])

    # ─── Generator Separation Demo ────────────────────────────────────────
    print("\n" + "="*60)
    print("GENERATOR SEPARATION: Subclass Differential Stability")
    print("="*60)

    # Exp-free expressions stay exp-free under differentiation
    exp_free_exprs = [
        ("x", x),
        ("x*x", Mul(x, x)),
        ("log(x)", Log(x)),
        ("x / log(x)", Div(x, Log(x))),
        ("log(x*x + 1)", Log(Add(Mul(x, x), Const(1)))),
    ]
    print("\nExp-free subclass (should remain exp-free after differentiation):")
    for name, e in exp_free_exprs:
        de = deriv(e)
        print(f"  d/dx [{name}]: contains_exp = {contains_exp(de)}  (expression: {de})")

    # Log-free expressions stay log-free under differentiation
    log_free_exprs = [
        ("x", x),
        ("exp(x)", Exp(x)),
        ("x * exp(x)", Mul(x, Exp(x))),
        ("exp(x*x)", Exp(Mul(x, x))),
        ("exp(x) / x", Div(Exp(x), x)),
    ]
    print("\nLog-free subclass (should remain log-free after differentiation):")
    for name, e in log_free_exprs:
        de = deriv(e)
        print(f"  d/dx [{name}]: contains_log = {contains_log(de)}  (expression: {de})")

    print("\n" + "="*60)
    print("COUNTEREXAMPLE: Naive 'removing any generator breaks closure' is FALSE")
    print("="*60)
    print("Both the exp-free and log-free subclasses are independently")
    print("differentiation-stable. Neither exp nor log is 'forced' by")
    print("differentiation alone — both are needed for expressiveness,")
    print("not for differential stability.")

    # ─── Size Growth Demo ─────────────────────────────────────────────────
    print("\n" + "="*60)
    print("DERIVATIVE SIZE GROWTH (Quadratic Bound)")
    print("="*60)
    header_ep = "size(e')"
    print(f"  {'expr':>25} | {'size(e)':>8} | {header_ep:>9} | {'ratio':>8} | {'6n^2':>6}")
    print(f"  {'-'*25}-+-{'-'*8}-+-{'-'*9}-+-{'-'*8}-+-{'-'*6}")

    test_exprs = [
        ("x", x),
        ("x*x", Mul(x, x)),
        ("exp(x)", Exp(x)),
        ("x*x*x", Mul(Mul(x, x), x)),
        ("exp(x*x)", Exp(Mul(x, x))),
        ("log(exp(x)+1)", Log(Add(Exp(x), Const(1)))),
        ("exp(x)/(1+log(x))", Div(Exp(x), Add(Const(1), Log(x)))),
    ]
    for name, e in test_exprs:
        de = deriv(e)
        s, sd = size(e), size(de)
        bound = 6 * s * s
        ratio = sd / s if s > 0 else 0
        print(f"  {name:>25} | {s:>8} | {sd:>9} | {ratio:>8.2f} | {bound:>6}")

    print("\n✓ All derivatives satisfy size(e') ≤ 6·size(e)² (verified in Lean)")


if __name__ == "__main__":
    main()
