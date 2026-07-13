"""
demo.py -- Numerical demonstration of the cubic uncanny-valley model U(x) = x^3 - 3x.

This self-contained script verifies, numerically, every result of the accompanying
paper:

  * the difference identity           U(b) - U(a) = (b - a)(a^2 + ab + b^2 - 3)
  * the two factorizations            U(x) - 2 = (x-2)(x+1)^2,  U(x) + 2 = (x-1)^2(x+2)
  * the three landmark values         U(-1) = 2, U(1) = -2, U(2) = 2
  * strict monotonicity on the three regimes (ascent, descent, recovery)
  * the strict drop                   U(1) < U(-1)
  * global minimality of the valley   U(x) >= U(1) for x >= -2
  * full recovery                     U(x) > U(-1) for x > 2

Run:  python demo.py
"""

from __future__ import annotations

from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# The model                                                                   #
# --------------------------------------------------------------------------- #

def U(x: float) -> float:
    """Acceptance as a function of human-likeness x, U(x) = x^3 - 3x."""
    return x ** 3 - 3.0 * x


def Q(a: float, b: float) -> float:
    """The symmetric quadratic factor Q(a, b) = a^2 + ab + b^2 - 3."""
    return a * a + a * b + b * b - 3.0


# --------------------------------------------------------------------------- #
# Verification helpers                                                        #
# --------------------------------------------------------------------------- #

def check(label: str, condition: bool) -> None:
    status = "OK " if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        raise AssertionError(label)


def approx(a: float, b: float, tol: float = 1e-9) -> bool:
    return abs(a - b) <= tol


# --------------------------------------------------------------------------- #
# Individual demonstrations                                                   #
# --------------------------------------------------------------------------- #

def demo_difference_identity(samples: List[Tuple[float, float]]) -> None:
    print("Difference identity  U(b) - U(a) = (b - a) * Q(a, b):")
    for a, b in samples:
        lhs = U(b) - U(a)
        rhs = (b - a) * Q(a, b)
        check(f"a={a:+.2f}, b={b:+.2f}:  {lhs:+.4f} == {rhs:+.4f}", approx(lhs, rhs))


def demo_factorizations(samples: List[float]) -> None:
    print("Factorizations:")
    for x in samples:
        peak = (x - 2.0) * (x + 1.0) ** 2
        valley = (x - 1.0) ** 2 * (x + 2.0)
        check(f"U({x:+.2f}) - 2 == (x-2)(x+1)^2", approx(U(x) - 2.0, peak))
        check(f"U({x:+.2f}) + 2 == (x-1)^2(x+2)", approx(U(x) + 2.0, valley))


def demo_landmarks() -> None:
    print("Landmark values:")
    check("U(-1) = 2 (near-human peak)", approx(U(-1.0), 2.0))
    check("U(1)  = -2 (valley bottom)", approx(U(1.0), -2.0))
    check("U(2)  = 2 (recovery point)", approx(U(2.0), 2.0))


def _strictly_monotone(f: Callable[[float], float], xs: List[float],
                        increasing: bool) -> bool:
    ys = [f(x) for x in xs]
    if increasing:
        return all(ys[i] < ys[i + 1] for i in range(len(ys) - 1))
    return all(ys[i] > ys[i + 1] for i in range(len(ys) - 1))


def _grid(lo: float, hi: float, n: int) -> List[float]:
    return [lo + (hi - lo) * i / (n - 1) for i in range(n)]


def demo_monotonicity() -> None:
    print("Monotonicity on the three regimes:")
    ascent = _grid(-4.0, -1.0, 50)
    descent = _grid(-1.0, 1.0, 50)
    recovery = _grid(1.0, 4.0, 50)
    check("strictly increasing on (-inf, -1] (ascent)",
          _strictly_monotone(U, ascent, increasing=True))
    check("strictly decreasing on [-1, 1] (uncanny descent)",
          _strictly_monotone(U, descent, increasing=False))
    check("strictly increasing on [1, inf) (recovery)",
          _strictly_monotone(U, recovery, increasing=True))


def demo_drop_and_recovery() -> None:
    print("The drop, the minimum, and full recovery:")
    check("strict drop: U(1) < U(-1)", U(1.0) < U(-1.0))
    # immediate descent past the peak
    just_past = _grid(-0.999, 1.0, 50)
    check("U(x) < U(-1) for all -1 < x <= 1",
          all(U(x) < U(-1.0) for x in just_past))
    # global minimality on [-2, inf)
    min_grid = _grid(-2.0, 6.0, 200)
    check("U(x) >= U(1) for all x >= -2 (global min)",
          all(U(x) >= U(1.0) - 1e-12 for x in min_grid))
    # full recovery beyond x = 2
    beyond = _grid(2.001, 6.0, 100)
    check("U(x) > U(-1) for all x > 2 (full recovery)",
          all(U(x) > U(-1.0) for x in beyond))


def demo_ascii_plot() -> None:
    """A small ASCII rendering of the acceptance curve over [-2.5, 2.5]."""
    print("Acceptance curve U(x) = x^3 - 3x over [-2.5, 2.5]:")
    xs = _grid(-2.5, 2.5, 51)
    ys = [U(x) for x in xs]
    lo, hi = min(ys), max(ys)
    width = 60
    for x, y in zip(xs, ys):
        pos = int((y - lo) / (hi - lo) * (width - 1))
        line = [" "] * width
        line[pos] = "*"
        marker = ""
        if approx(x, -1.0, 0.05):
            marker = "  <- near-human peak"
        elif approx(x, 1.0, 0.05):
            marker = "  <- valley bottom"
        elif approx(x, 2.0, 0.05):
            marker = "  <- recovery"
        print(f"x={x:+.2f} |{''.join(line)}|{marker}")


# --------------------------------------------------------------------------- #
# Main                                                                        #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("The Uncanny Valley of Mathematics -- numerical demonstration")
    print("=" * 70)

    samples = [(-3.0, -2.0), (-1.0, 1.0), (0.5, 2.5), (2.0, 3.0), (-2.0, 4.0)]
    demo_difference_identity(samples)
    print()
    demo_factorizations([-2.0, -1.0, 0.0, 1.0, 2.0, 3.0])
    print()
    demo_landmarks()
    print()
    demo_monotonicity()
    print()
    demo_drop_and_recovery()
    print()
    demo_ascii_plot()
    print()
    print("All checks passed: the cubic reproduces Mori's uncanny valley.")


if __name__ == "__main__":
    main()
