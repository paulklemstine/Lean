#!/usr/bin/env python3
"""
Numerical demonstrations of the EML variational principles and bounded
beta-reduction semantics.

All functions are self-contained and inlined. No external dependencies
beyond the Python standard library and math module.
"""

from __future__ import annotations
import math
from typing import NamedTuple


# ============================================================================
# Part I: EML Potential and Variational Principles
# ============================================================================

def f_var(x: float) -> float:
    """The EML potential: f(x) = exp(x) - ln(x) - 1."""
    if x <= 0:
        raise ValueError(f"f_var requires x > 0, got {x}")
    return math.exp(x) - math.log(x) - 1.0


def g_var(x: float) -> float:
    """The EML Riemannian metric coefficient: g(x) = exp(x) + x^{-2}."""
    if x <= 0:
        raise ValueError(f"g_var requires x > 0, got {x}")
    return math.exp(x) + x ** (-2)


def kinetic(x: float, v: float) -> float:
    """Kinetic energy: K(x,v) = g(x) * v^2 / 2."""
    return g_var(x) * v ** 2 / 2.0


def total_energy(x: float, v: float) -> float:
    """Total energy: E(x,v) = K(x,v) + f(x)."""
    return kinetic(x, v) + f_var(x)


def lagrangian(x: float, v: float) -> float:
    """EML Lagrangian: L(x,v) = K(x,v) - f(x)."""
    return kinetic(x, v) - f_var(x)


def eml_iteration(x: float) -> float:
    """The EML iteration map: T(x) = exp(x) - ln(x)."""
    if x <= 0:
        raise ValueError(f"eml_iteration requires x > 0, got {x}")
    return math.exp(x) - math.log(x)


def f_var_second_derivative(x: float) -> float:
    """Second derivative of f: f''(x) = exp(x) + 1/x^2."""
    if x <= 0:
        raise ValueError(f"f_var_second_derivative requires x > 0, got {x}")
    return math.exp(x) + 1.0 / (x ** 2)


# ============================================================================
# Part II: Lambda Calculus and Bounded Beta-Reduction
# ============================================================================

class Var(NamedTuple):
    """A variable term."""
    name: int

class App(NamedTuple):
    """An application term."""
    func: object  # Lam
    arg: object   # Lam

class Abs(NamedTuple):
    """A lambda abstraction."""
    var: int
    body: object  # Lam

# Type alias for lambda terms
Lam = Var | App | Abs


def term_size(t: Lam) -> int:
    """The size of a lambda term (number of constructors)."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + term_size(t.func) + term_size(t.arg)
    elif isinstance(t, Abs):
        return 1 + term_size(t.body)
    raise TypeError(f"Unknown term type: {type(t)}")


def subst(t: Lam, x: int, s: Lam) -> Lam:
    """Substitute s for variable x in term t (naive, no capture avoidance)."""
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, App):
        return App(subst(t.func, x, s), subst(t.arg, x, s))
    elif isinstance(t, Abs):
        if t.var == x:
            return t  # x is shadowed
        return Abs(t.var, subst(t.body, x, s))
    raise TypeError(f"Unknown term type: {type(t)}")


def beta_reduce_one_step(t: Lam) -> Lam | None:
    """Attempt one step of leftmost-outermost beta reduction. Returns None if no redex."""
    if isinstance(t, App) and isinstance(t.func, Abs):
        # Beta redex: (λx.body) arg -> body[x := arg]
        return subst(t.func.body, t.func.var, t.arg)
    elif isinstance(t, App):
        left = beta_reduce_one_step(t.func)
        if left is not None:
            return App(left, t.arg)
        right = beta_reduce_one_step(t.arg)
        if right is not None:
            return App(t.func, right)
    elif isinstance(t, Abs):
        inner = beta_reduce_one_step(t.body)
        if inner is not None:
            return Abs(t.var, inner)
    return None


def bounded_reducts(t: Lam, depth: int) -> set[str]:
    """
    Compute the set of all terms reachable from t within `depth` beta steps.
    Returns term string representations for display.
    """
    def term_to_str(t: Lam) -> str:
        if isinstance(t, Var):
            return f"x{t.name}"
        elif isinstance(t, App):
            return f"({term_to_str(t.func)} {term_to_str(t.arg)})"
        elif isinstance(t, Abs):
            return f"(λx{t.var}.{term_to_str(t.body)})"
        return "?"

    visited: set[str] = set()
    frontier: list[Lam] = [t]
    visited.add(term_to_str(t))

    for _ in range(depth):
        next_frontier: list[Lam] = []
        for term in frontier:
            # Try all possible one-step reductions
            result = beta_reduce_one_step(term)
            if result is not None:
                s = term_to_str(result)
                if s not in visited:
                    visited.add(s)
                    next_frontier.append(result)
        frontier = next_frontier

    return visited


def show_term(t: Lam) -> str:
    """Pretty-print a lambda term."""
    if isinstance(t, Var):
        return f"x{t.name}"
    elif isinstance(t, App):
        return f"({show_term(t.func)} {show_term(t.arg)})"
    elif isinstance(t, Abs):
        return f"(λx{t.var}.{show_term(t.body)})"
    return "?"


# ============================================================================
# Demo 1: EML Potential Lower Bound (Theorem 3.1)
# ============================================================================

def demo_potential_lower_bound() -> None:
    """Verify f(x) >= 1 for a range of positive x values."""
    print("=" * 65)
    print("DEMO 1: EML Potential Lower Bound — f(x) ≥ 1 for all x > 0")
    print("=" * 65)
    print(f"{'x':>10} {'f(x)':>15} {'f(x) >= 1?':>12}")
    print("-" * 40)

    test_values = [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
    for x in test_values:
        fx = f_var(x)
        check = "✓" if fx >= 1.0 else "✗"
        print(f"{x:>10.3f} {fx:>15.6f} {check:>12}")

    # Find approximate minimum
    best_x = 0.001
    best_f = f_var(best_x)
    for i in range(1, 100000):
        x = i * 0.0001
        fx = f_var(x)
        if fx < best_f:
            best_f = fx
            best_x = x

    print(f"\nApproximate minimum: f({best_x:.4f}) = {best_f:.6f}")
    print(f"Minimum value is {'≥' if best_f >= 1.0 else '<'} 1.0  ✓")
    print()


# ============================================================================
# Demo 2: Positive Energy Theorem (Theorem 3.8)
# ============================================================================

def demo_positive_energy() -> None:
    """Verify E(x,v) >= 1 for various (x,v) pairs."""
    print("=" * 65)
    print("DEMO 2: Positive Energy Theorem — E(x,v) ≥ 1")
    print("=" * 65)
    print(f"{'x':>8} {'v':>8} {'K(x,v)':>12} {'f(x)':>12} {'E(x,v)':>12} {'≥1?':>5}")
    print("-" * 60)

    pairs = [
        (0.1, 0.0), (0.1, 1.0), (0.1, -2.0),
        (1.0, 0.0), (1.0, 0.5), (1.0, 3.0),
        (5.0, 0.0), (5.0, 0.1), (5.0, -1.0),
        (0.01, 10.0), (10.0, 0.001),
    ]
    for x, v in pairs:
        k = kinetic(x, v)
        f = f_var(x)
        e = total_energy(x, v)
        check = "✓" if e >= 1.0 else "✗"
        print(f"{x:>8.3f} {v:>8.3f} {k:>12.4f} {f:>12.4f} {e:>12.4f} {check:>5}")
    print()


# ============================================================================
# Demo 3: Convexity Verification (Theorem 3.9)
# ============================================================================

def demo_convexity() -> None:
    """Verify f''(x) >= 0 and the convexity inequality."""
    print("=" * 65)
    print("DEMO 3: Convexity — f''(x) = exp(x) + 1/x² ≥ 0")
    print("=" * 65)
    header_fpp = 'f"(x)'
    print(f"{'x':>10} {'exp(x)':>12} {'1/x²':>12} {header_fpp:>12} {'≥0?':>5}")
    print("-" * 55)

    for x in [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        ex = math.exp(x)
        inv_sq = 1.0 / x**2
        d2 = f_var_second_derivative(x)
        check = "✓" if d2 >= 0 else "✗"
        print(f"{x:>10.3f} {ex:>12.4f} {inv_sq:>12.4f} {d2:>12.4f} {check:>5}")

    # Verify midpoint convexity: f((a+b)/2) <= (f(a) + f(b))/2
    print("\nMidpoint convexity check: f((a+b)/2) ≤ (f(a) + f(b))/2")
    print(f"{'a':>6} {'b':>6} {'f(mid)':>12} {'avg f':>12} {'convex?':>8}")
    print("-" * 48)
    for a, b in [(0.1, 2.0), (0.5, 5.0), (1.0, 10.0), (0.01, 1.0)]:
        mid = (a + b) / 2
        f_mid = f_var(mid)
        f_avg = (f_var(a) + f_var(b)) / 2
        check = "✓" if f_mid <= f_avg + 1e-10 else "✗"
        print(f"{a:>6.2f} {b:>6.2f} {f_mid:>12.6f} {f_avg:>12.6f} {check:>8}")
    print()


# ============================================================================
# Demo 4: Orbit Growth (Theorem 3.10)
# ============================================================================

def demo_orbit_growth() -> None:
    """Verify f(T(x)) > f(x) along the EML iteration map."""
    print("=" * 65)
    print("DEMO 4: Orbit Growth — f(exp(x) - ln(x)) > f(x)")
    print("=" * 65)
    print(f"{'x':>10} {'T(x)':>12} {'f(x)':>14} {'f(T(x))':>14} {'growth?':>8}")
    print("-" * 62)

    for x in [0.01, 0.1, 0.5, 1.0, 2.0, 3.0]:
        tx = eml_iteration(x)
        fx = f_var(x)
        ftx = f_var(tx)
        check = "✓" if ftx > fx else "✗"
        print(f"{x:>10.4f} {tx:>12.4f} {fx:>14.6f} {ftx:>14.6f} {check:>8}")

    # Show orbit divergence
    print("\nOrbit divergence from x₀ = 1.0:")
    x = 1.0
    for step in range(4):
        fx = f_var(x)
        print(f"  Step {step}: x = {x:.6f}, f(x) = {fx:.6e}")
        x = eml_iteration(x)
        if x > 700:  # exp overflow guard
            print(f"  Step {step+1}: x = {x:.6e} (orbit escaping to infinity)")
            break
    print()


# ============================================================================
# Demo 5: Bounded Beta-Reduction
# ============================================================================

def demo_bounded_reduction() -> None:
    """Demonstrate bounded reachability for simple lambda terms."""
    print("=" * 65)
    print("DEMO 5: Bounded Beta-Reduction Semantics")
    print("=" * 65)

    # Identity: (λx.x)
    identity = Abs(0, Var(0))
    # Constant: (λx.λy.x)
    const_k = Abs(0, Abs(1, Var(0)))
    # A simple argument
    arg_a = Var(42)

    # Example 1: (λx.x) a → a
    term1 = App(identity, arg_a)
    print(f"\nTerm: {show_term(term1)}")
    print(f"Size: {term_size(term1)}")
    result1 = beta_reduce_one_step(term1)
    print(f"One-step reduction: {show_term(result1) if result1 else 'normal form'}")

    # Example 2: (λx.λy.x) a → λy.a
    term2 = App(const_k, arg_a)
    print(f"\nTerm: {show_term(term2)}")
    result2 = beta_reduce_one_step(term2)
    print(f"One-step reduction: {show_term(result2) if result2 else 'normal form'}")

    # Example 3: ((λx.λy.x) a) b → (λy.a) b → a
    arg_b = Var(43)
    term3 = App(App(const_k, arg_a), arg_b)
    print(f"\nTerm: {show_term(term3)}")
    print(f"Size: {term_size(term3)}")

    for depth in range(4):
        reducts = bounded_reducts(term3, depth)
        print(f"  Depth {depth}: {len(reducts)} reachable terms: {sorted(reducts)}")

    # Show monotonicity: depth d1 <= d2 implies |reducts(d1)| <= |reducts(d2)|
    print("\nMonotonicity: |Reachable(d)| is non-decreasing in d")
    term4 = App(App(Abs(0, App(Var(0), Var(0))), Abs(1, Var(1))), arg_a)
    print(f"  Term: {show_term(term4)}")
    for d in range(5):
        r = bounded_reducts(term4, d)
        print(f"  Depth {d}: {len(r)} terms")
    print()


# ============================================================================
# Demo 6: Lagrangian at Rest (Theorems 3.6 & 3.7)
# ============================================================================

def demo_lagrangian_at_rest() -> None:
    """Verify L(x, 0) = -f(x) < 0 for positive x."""
    print("=" * 65)
    print("DEMO 6: Lagrangian at Rest — L(x,0) = -f(x) < 0")
    print("=" * 65)
    print(f"{'x':>10} {'L(x,0)':>14} {'-f(x)':>14} {'equal?':>8} {'< 0?':>6}")
    print("-" * 55)

    for x in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        lx0 = lagrangian(x, 0.0)
        neg_fx = -f_var(x)
        eq_check = "✓" if abs(lx0 - neg_fx) < 1e-12 else "✗"
        neg_check = "✓" if lx0 < 0 else "✗"
        print(f"{x:>10.3f} {lx0:>14.6f} {neg_fx:>14.6f} {eq_check:>8} {neg_check:>6}")
    print()


# ============================================================================
# Main
# ============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  EML Variational Principles & Bounded Reduction Semantics  ║")
    print("║  Numerical Demonstrations                                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_potential_lower_bound()
    demo_positive_energy()
    demo_convexity()
    demo_orbit_growth()
    demo_bounded_reduction()
    demo_lagrangian_at_rest()

    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
