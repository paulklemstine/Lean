#!/usr/bin/env python3
"""Numerical demonstrations for exponential--logarithmic chain rules.

The script uses only Python's standard library.  It evaluates the first three
closed-form derivatives of exp(x^2) log(x+1), compares them with central finite
differences, exhibits the counterexample to an incorrect factorization, and
checks fixed-depth exp--log representations of positive monomials.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isfinite, log
from typing import Callable, Iterable, Sequence

RealFunction = Callable[[float], float]


@dataclass(frozen=True)
class Check:
    """One numerical comparison between an analytic and numerical value."""

    label: str
    x: float
    analytic: float
    numerical: float

    @property
    def absolute_error(self) -> float:
        return abs(self.analytic - self.numerical)

    @property
    def relative_error(self) -> float:
        scale = max(1.0, abs(self.analytic))
        return self.absolute_error / scale


def central_difference(function: RealFunction, x: float, step: float = 1e-5) -> float:
    """Return the second-order central-difference approximation to f'(x)."""
    if step <= 0.0:
        raise ValueError("step must be positive")
    return (function(x + step) - function(x - step)) / (2.0 * step)


def exp_log_product(h: RealFunction, g: RealFunction, x: float) -> float:
    """Evaluate exp(h(x)) * log(g(x)); the demonstration uses g(x) > 0."""
    gx = g(x)
    if gx <= 0.0:
        raise ValueError("the real logarithm requires g(x) > 0")
    return exp(h(x)) * log(gx)


def unfactored_derivative(
    h: RealFunction,
    h_prime: RealFunction,
    g: RealFunction,
    g_prime: RealFunction,
    x: float,
) -> float:
    """Evaluate exp(h) * (h' log(g) + g'/g)."""
    gx = g(x)
    if gx <= 0.0:
        raise ValueError("the real logarithm requires g(x) > 0")
    return exp(h(x)) * (h_prime(x) * log(gx) + g_prime(x) / gx)


def factored_derivative(
    h: RealFunction,
    h_prime: RealFunction,
    g: RealFunction,
    g_prime: RealFunction,
    x: float,
) -> float:
    """Evaluate the guarded factorization F * (h' + g'/(g log(g)))."""
    gx = g(x)
    if gx <= 0.0:
        raise ValueError("the real logarithm requires g(x) > 0")
    log_gx = log(gx)
    if log_gx == 0.0:
        raise ValueError("the factored form is undefined when log(g(x)) = 0")
    original = exp(h(x)) * log_gx
    return original * (h_prime(x) + g_prime(x) / (gx * log_gx))


def f0(x: float) -> float:
    """Evaluate exp(x^2) log(x+1) on x > -1."""
    if x <= -1.0:
        raise ValueError("f0 requires x > -1")
    return exp(x * x) * log(x + 1.0)


def f1(x: float) -> float:
    """Evaluate the first derivative of f0."""
    if x <= -1.0:
        raise ValueError("f1 requires x > -1")
    y = x + 1.0
    return exp(x * x) * (2.0 * x * log(y) + 1.0 / y)


def f2(x: float) -> float:
    """Evaluate the second derivative of f0."""
    if x <= -1.0:
        raise ValueError("f2 requires x > -1")
    y = x + 1.0
    inner = (4.0 * x * x + 2.0) * log(y) + 4.0 * x / y - 1.0 / (y * y)
    return exp(x * x) * inner


def f3(x: float) -> float:
    """Evaluate the third derivative of f0."""
    if x <= -1.0:
        raise ValueError("f3 requires x > -1")
    y = x + 1.0
    inner = (
        (8.0 * x**3 + 12.0 * x) * log(y)
        + (12.0 * x * x + 6.0) / y
        - 6.0 * x / (y * y)
        + 2.0 / (y**3)
    )
    return exp(x * x) * inner


def derivative_checks(points: Iterable[float], step: float = 1e-5) -> list[Check]:
    """Compare each closed form with a finite difference of its predecessor."""
    checks: list[Check] = []
    pairs: Sequence[tuple[str, RealFunction, RealFunction]] = (
        ("f0' = f1", f0, f1),
        ("f1' = f2", f1, f2),
        ("f2' = f3", f2, f3),
    )
    for x in points:
        if x - step <= -1.0:
            raise ValueError("finite-difference stencil crosses x = -1")
        for label, previous, closed_form in pairs:
            checks.append(Check(label, x, closed_form(x), central_difference(previous, x, step)))
    return checks


def monomial_exp_log(power: int, x: float) -> float:
    """Evaluate x^power as exp(power * log(x)) on the positive half-line."""
    if power < 1:
        raise ValueError("power must be a positive integer")
    if x <= 0.0:
        raise ValueError("the exp--log representation requires x > 0")
    return exp(float(power) * log(x))


def monomial_derivative_exp_log(power: int, x: float) -> float:
    """Evaluate the analytic derivative of exp(power * log(x))."""
    if power < 1 or x <= 0.0:
        raise ValueError("power >= 1 and x > 0 are required")
    return float(power) * x ** (power - 1)


def print_counterexample() -> None:
    """Display the exact shape of the failed proposed factorization at x=2."""
    x = 2.0
    h = lambda _: 0.0
    hp = lambda _: 0.0
    g = exp
    gp = exp
    actual = unfactored_derivative(h, hp, g, gp, x)
    incorrect = exp_log_product(h, g, x) * (hp(x) + gp(x) / g(x))
    corrected = factored_derivative(h, hp, g, gp, x)
    print("Counterexample with h(x)=0 and g(x)=exp(x) at x=2")
    print(f"  true derivative:                 {actual:.12g}")
    print(f"  incorrect F*(h' + g'/g):        {incorrect:.12g}")
    print(f"  corrected guarded factorization: {corrected:.12g}\n")


def print_derivative_table() -> None:
    """Display values and finite-difference errors for three derivatives."""
    print("Closed forms versus central finite differences")
    print("  identity       x         analytic          numerical       relative error")
    for check in derivative_checks((-0.5, 0.0, 0.5, 1.0), 1e-5):
        print(
            f"  {check.label:9s} {check.x:6.2f} "
            f"{check.analytic:17.9g} {check.numerical:17.9g} "
            f"{check.relative_error:14.3e}"
        )
    print()


def print_monomial_table() -> None:
    """Compare fixed-depth exp--log powers and their derivatives."""
    x = 1.7
    step = 1e-5
    print(f"Positive monomials represented as exp(m*log(x)) at x={x}")
    print("  m       representation          x^m       derivative      finite diff")
    for power in (1, 2, 5, 10, 25):
        represented = monomial_exp_log(power, x)
        ordinary = x**power
        derivative = monomial_derivative_exp_log(power, x)
        numerical = central_difference(lambda t, p=power: monomial_exp_log(p, t), x, step)
        assert isfinite(represented) and isfinite(numerical)
        print(
            f" {power:2d} {represented:20.10g} {ordinary:12.6g} "
            f"{derivative:15.7g} {numerical:15.7g}"
        )
    print()


def main() -> None:
    print_counterexample()
    print_derivative_table()
    print_monomial_table()
    print("Benchmark values at x=0: "
          f"f0={f0(0.0):g}, f1={f1(0.0):g}, f2={f2(0.0):g}, f3={f3(0.0):g}")


if __name__ == "__main__":
    main()
