"""Numerical demonstrations for the EML Fixed-Point / ResNet Residual bridge.

This self-contained script illustrates the formally verified results:

  * The EML operator  f(x) = exp(a) * log(b*x + c)  is a contraction on an
    invariant interval, and the iteration  x_{n+1} = f(x_n)  converges to a
    unique fixed point at a certified geometric rate O(rho^n).
  * The concrete certified instance  f(x) = exp(1) * log(x + 100)  on [0, 20]
    with contraction ratio rho = 1/30.
  * The clamp (metric projection) is 1-Lipschitz, globalizing the contraction.
  * An EML residual block  x -> x + f(clamp(x))  is (1 + rho)-Lipschitz, and a
    depth-K stack obeys the Bernoulli floor (1 + rho)^K >= 1 + K*rho.

Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Core EML operator
# --------------------------------------------------------------------------- #
def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    """Return the EML single operator f(x) = exp(a) * log(b*x + c)."""
    def f(x: float) -> float:
        return math.exp(a) * math.log(b * x + c)
    return f


def eml_derivative(a: float, b: float, c: float) -> Callable[[float], float]:
    """Return f'(x) = exp(a) * b / (b*x + c), the verified derivative formula."""
    def fp(x: float) -> float:
        return math.exp(a) * b / (b * x + c)
    return fp


def iterate(f: Callable[[float], float], x0: float, n: int) -> List[float]:
    """Return the iteration sequence [x0, x1, ..., xn] with x_{k+1} = f(x_k)."""
    seq: List[float] = [x0]
    x = x0
    for _ in range(n):
        x = f(x)
        seq.append(x)
    return seq


def fixed_point(f: Callable[[float], float], x0: float,
                tol: float = 1e-15, max_iter: int = 10000) -> Tuple[float, int]:
    """Iterate to the fixed point; return (x_star, number_of_steps)."""
    x = x0
    for k in range(1, max_iter + 1):
        x_next = f(x)
        if abs(x_next - x) < tol:
            return x_next, k
        x = x_next
    return x, max_iter


# --------------------------------------------------------------------------- #
# The clamp (metric projection onto [lo, hi]) and the residual block
# --------------------------------------------------------------------------- #
def clamp(lo: float, hi: float, x: float) -> float:
    """Project x onto [lo, hi]: min(hi, max(lo, x)). It is 1-Lipschitz."""
    return min(hi, max(lo, x))


def clamped_eml(a: float, b: float, c: float, lo: float, hi: float
                ) -> Callable[[float], float]:
    """The globally rho-Lipschitz map g(x) = f(clamp(lo, hi, x))."""
    f = eml_operator(a, b, c)
    return lambda x: f(clamp(lo, hi, x))


def eml_residual_block(a: float, b: float, c: float, lo: float, hi: float
                       ) -> Callable[[float], float]:
    """One EML residual block: x -> x + f(clamp(lo, hi, x))."""
    g = clamped_eml(a, b, c, lo, hi)
    return lambda x: x + g(x)


def compose_blocks(block: Callable[[float], float], depth: int
                   ) -> Callable[[float], float]:
    """Stack `depth` identical residual blocks."""
    def stacked(x: float) -> float:
        for _ in range(depth):
            x = block(x)
        return x
    return stacked


# --------------------------------------------------------------------------- #
# Demonstration 1: convergence and certified rate for the concrete instance
# --------------------------------------------------------------------------- #
def demo_concrete_convergence() -> None:
    """concreteEML: f(x) = exp(1) * log(x + 100) on [0, 20], rho = 1/30."""
    print("=" * 70)
    print("DEMO 1: Concrete certified instance  f(x) = e * log(x + 100)")
    print("=" * 70)
    a, b, c, lo, hi, rho = 1.0, 1.0, 100.0, 0.0, 20.0, 1.0 / 30.0
    f = eml_operator(a, b, c)
    fp = eml_derivative(a, b, c)

    x_star, steps = fixed_point(f, x0=0.0)
    print(f"fixed point x*  = {x_star:.12f}   (reached in {steps} steps)")
    print(f"check f(x*)     = {f(x_star):.12f}")
    print(f"implicit eqn    : x* = e*log(x*+100) = {math.exp(a)*math.log(x_star+100):.12f}")
    print(f"|f'(x*)|        = {abs(fp(x_star)):.6f}   (certified rho = {rho:.6f})")
    print(f"derivative bound holds on [lo,hi]: {abs(fp(lo)) <= rho and abs(fp(hi)) <= rho}")

    # a priori error bound  |x_n - x*| <= |x1 - x0| * rho^n / (1 - rho)
    x0 = 5.0
    seq = iterate(f, x0, 8)
    c0 = abs(seq[1] - seq[0])
    print(f"\nstarting from x0 = {x0}:  certified bound |x_n - x*| <= "
          f"{c0:.4f} * (1/30)^n / (1 - 1/30)")
    print(f"{'n':>3} {'x_n':>16} {'|x_n - x*|':>16} {'certified bound':>18}")
    for n, xn in enumerate(seq):
        actual = abs(xn - x_star)
        bound = c0 * rho ** n / (1 - rho)
        ok = "OK" if actual <= bound + 1e-12 else "FAIL"
        print(f"{n:>3} {xn:>16.10f} {actual:>16.3e} {bound:>18.3e}  {ok}")


# --------------------------------------------------------------------------- #
# Demonstration 2: clamp is 1-Lipschitz and globalizes the contraction
# --------------------------------------------------------------------------- #
def demo_clamp_lipschitz() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: The clamp is 1-Lipschitz; clamped EML is globally rho-Lipschitz")
    print("=" * 70)
    a, b, c, lo, hi, rho = 1.0, 1.0, 100.0, 0.0, 20.0, 1.0 / 30.0
    g = clamped_eml(a, b, c, lo, hi)
    test_pairs = [(-50.0, 80.0), (3.0, 17.0), (100.0, -100.0), (10.0, 10.5)]
    print(f"{'x':>8} {'y':>8} {'|clamp x - clamp y|':>22} {'<= |x-y|':>10} "
          f"{'|g x - g y|':>14} {'<= rho|x-y|':>14}")
    for x, y in test_pairs:
        cl = abs(clamp(lo, hi, x) - clamp(lo, hi, y))
        gd = abs(g(x) - g(y))
        print(f"{x:>8.1f} {y:>8.1f} {cl:>22.6f} {abs(x-y):>10.4f} "
              f"{gd:>14.6f} {rho*abs(x-y):>14.6f}")


# --------------------------------------------------------------------------- #
# Demonstration 3: EML residual block and Bernoulli depth growth
# --------------------------------------------------------------------------- #
def demo_residual_depth() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: EML residual block is (1+rho)-Lipschitz; depth growth (1+rho)^K")
    print("=" * 70)
    a, b, c, lo, hi, rho = 1.0, 1.0, 100.0, 0.0, 20.0, 1.0 / 30.0
    block = eml_residual_block(a, b, c, lo, hi)

    # single block Lipschitz check
    x, y = 4.0, 11.0
    ratio = abs(block(x) - block(y)) / abs(x - y)
    print(f"single block: |R(x)-R(y)|/|x-y| = {ratio:.6f}  <= 1+rho = {1+rho:.6f}")

    # depth-K growth: empirical vs Bernoulli floor vs exp ceiling
    print(f"\n{'K':>4} {'(1+rho)^K':>14} {'Bernoulli 1+K*rho':>20} {'exp(K*rho) ceiling':>20}")
    for K in [1, 2, 5, 10, 50, 100]:
        worst = (1 + rho) ** K
        floor = 1 + K * rho
        ceil = math.exp(K * rho)
        print(f"{K:>4} {worst:>14.6f} {floor:>20.6f} {ceil:>20.6f}")
    print("\nNote: a feedforward stack with per-layer factor L=1.5 would give "
          f"1.5^100 = {1.5**100:.3e} (exponential blow-up).")


# --------------------------------------------------------------------------- #
# Demonstration 4: fixed-point power-series first-order approximation in a
# --------------------------------------------------------------------------- #
def demo_fixed_point_sensitivity() -> None:
    """f(x) = exp(a) * log(x + 2): first-order approx x*(a) ~ x*(0) + a * slope."""
    print("\n" + "=" * 70)
    print("DEMO 4: Fixed-point sensitivity in a for  f(x) = exp(a) * log(x + 2)")
    print("=" * 70)
    b, c = 1.0, 2.0
    # x*(0) solves x = log(x + 2)
    x0_star, _ = fixed_point(eml_operator(0.0, b, c), x0=1.0)
    # slope dx*/da = x* / (1 - f'(x*)) at a = 0 ; f'(x*) = 1/(x*+2)
    slope = x0_star / (1 - 1.0 / (x0_star + c))
    print(f"x*(0) = {x0_star:.10f}   first-order slope dx*/da = {slope:.10f}")
    print(f"{'a':>8} {'x*(a) exact':>16} {'linear approx':>16} {'error':>12}")
    for a in [0.01, 0.05, 0.1, 0.3]:
        exact, _ = fixed_point(eml_operator(a, b, c), x0=x0_star)
        approx = x0_star + a * slope
        print(f"{a:>8.2f} {exact:>16.10f} {approx:>16.10f} {abs(exact-approx):>12.2e}")


def main() -> None:
    demo_concrete_convergence()
    demo_clamp_lipschitz()
    demo_residual_depth()
    demo_fixed_point_sensitivity()


if __name__ == "__main__":
    main()
