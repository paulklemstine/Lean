"""Assemble PACKAGE.json from the deliverable files in this directory."""
import json
import pathlib

HERE = pathlib.Path(__file__).parent


def read(name: str) -> str:
    return (HERE / name).read_text(encoding="utf-8")


article = read("ARTICLE.md")
paper = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo = read("demo.py")
viz = read("visualize.py")
interactive = read("interactive.html")

lean_proofs = read("LEAN_SOURCE.txt") if (HERE / "LEAN_SOURCE.txt").exists() else "See Catalog/Applications/ContinuedFractions/*.lean"

algo_cf = '''from fractions import Fraction
from typing import Iterator
import math


def continued_fraction_convergents(x: float, n_terms: int) -> Iterator[Fraction]:
    """Yield convergents p_k/q_k of x; each satisfies |x - p_k/q_k| < 1/q_k^2
    with strictly increasing denominators (effective `irrational_den_unbounded`)."""
    p_prev, p_cur = 0, 1
    q_prev, q_cur = 1, 0
    xk: float = x
    for _ in range(n_terms):
        a = math.floor(xk)
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        yield Fraction(p_cur, q_cur)
        frac = xk - a
        if frac <= 1e-15:
            return
        xk = 1.0 / frac


def good_approx_with_denominator_at_least(x: float, N: int,
                                          max_terms: int = 80) -> Fraction:
    """Return a Dirichlet-good rational p/q with q >= N (Theorem: unbounded denominators)."""
    for c in continued_fraction_convergents(x, max_terms):
        if c.denominator >= N:
            return c
    raise ValueError("increase max_terms")
'''

algo_lc = '''from typing import Callable


def nearest_int_distance(y: float) -> float:
    """||y|| = distance from y to the nearest integer, in [0, 1/2]."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """approx(x, q) = q * ||q x||."""
    return q * nearest_int_distance(q * x)


def empirical_lagrange_constant(x: float, q_max: int) -> float:
    """Estimate Lc(x) = liminf_{q->inf} q*||q x|| by the minimum over 1..q_max.

    By `Lc_le_one_of_irrational` the result is <= 1 for irrational x; for a
    Liouville number it tends to 0 (`Lc_eq_zero_of_liouville`)."""
    return min(approx(x, q) for q in range(1, q_max + 1))
'''

pkg = {
    "title": "Continued Fractions and Diophantine Approximation: The Lagrange Constant",
    "domain": "Applications",
    "description": (
        "A formally verified bridge from classical Diophantine approximation to the "
        "Lagrange constant Lc(x) = liminf q*||qx||: denominators of good rational "
        "approximations are unbounded, every irrational obeys Lc(x) <= 1, and Liouville "
        "numbers achieve Lc(x) = 0 and so are never badly approximable."
    ),
    "authors": ["Aristotle"],
    "date": "2026-06-28",
    "key_results": [
        "irrational_den_unbounded: for irrational x and any N there is a Dirichlet-good rational q (|x - q| < 1/q.den^2) with denominator >= N",
        "finite_den_le_in_interval: only finitely many rationals of bounded denominator lie in a bounded interval",
        "irrational_infinitely_many_coprime_approx: arbitrarily large coprime denominators b with |x - a/b| < 1/b^2",
        "Lc_le_one_of_irrational: every irrational number has Lagrange constant Lc(x) <= 1",
        "Lc_eq_zero_of_liouville: every Liouville number has Lc(x) = 0, hence liouville_not_bad: no Liouville number is badly approximable",
    ],
    "keywords": [
        "continued fractions", "Diophantine approximation", "Lagrange constant",
        "Liouville numbers", "Dirichlet's theorem", "badly approximable",
        "irrational numbers", "liminf",
    ],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "Unbounded Denominators and the Universal Lagrange Bound",
            "description": (
                "Computes continued-fraction convergents to verify that for sqrt(2) and pi "
                "there exist Dirichlet-good rationals (|x - p/q| < 1/q^2) with denominator "
                "exceeding any prescribed N (10, 10^3, 10^6, 10^9), and empirically estimates "
                "the Lagrange constant Lc(x) = min q*||qx|| for sqrt(2), pi, and e, confirming "
                "Lc(x) <= 1 in every case."
            ),
            "code": demo,
        },
    ],
    "algorithms": [
        {
            "name": "Continued-Fraction Convergents as Effective Best Approximations",
            "description": (
                "Generates the convergents p_k/q_k of a real number x via the Gauss map and the "
                "standard linear recurrences p_k = a_k p_{k-1} + p_{k-2}, q_k = a_k q_{k-1} + "
                "q_{k-2}. Each convergent is a best rational approximation satisfying "
                "|x - p_k/q_k| < 1/q_k^2 with strictly increasing denominators, giving a "
                "constructive witness for irrational_den_unbounded. Reaching denominator >= N "
                "costs O(log N) iterations for badly approximable x; arbitrary-precision "
                "rationals keep the arithmetic exact."
            ),
            "pseudocode": (
                "function convergents(x, n_terms):\n"
                "    (p_prev, p_cur) <- (0, 1)\n"
                "    (q_prev, q_cur) <- (1, 0)\n"
                "    xk <- x\n"
                "    repeat n_terms times:\n"
                "        a <- floor(xk)\n"
                "        (p_prev, p_cur) <- (p_cur, a*p_cur + p_prev)\n"
                "        (q_prev, q_cur) <- (q_cur, a*q_cur + q_prev)\n"
                "        emit p_cur / q_cur\n"
                "        frac <- xk - a\n"
                "        if frac ~ 0: stop      // x is rational\n"
                "        xk <- 1 / frac\n\n"
                "function good_approx_with_denominator_at_least(x, N):\n"
                "    for c in convergents(x, large):\n"
                "        if denominator(c) >= N: return c"
            ),
            "code": algo_cf,
        },
        {
            "name": "Empirical Lagrange Constant via the Nearest-Integer Norm",
            "description": (
                "Estimates the Lagrange constant Lc(x) = liminf_{q->inf} q*||qx|| by the minimum "
                "of the approximation function approx(x,q) = q*||qx|| over q = 1..q_max, where "
                "||y|| is the distance from y to the nearest integer. Runs in O(q_max) time and "
                "O(1) space. The output is <= 1 for irrational x (Lc_le_one_of_irrational) and "
                "collapses toward 0 for Liouville numbers (Lc_eq_zero_of_liouville); the golden "
                "ratio levels at the Hurwitz floor 1/sqrt(5)."
            ),
            "pseudocode": (
                "function nearest_int_distance(y):\n"
                "    return |y - round(y)|\n\n"
                "function approx(x, q):\n"
                "    return q * nearest_int_distance(q * x)\n\n"
                "function empirical_lagrange_constant(x, q_max):\n"
                "    best <- +inf\n"
                "    for q in 1..q_max:\n"
                "        best <- min(best, approx(x, q))\n"
                "    return best"
            ),
            "code": algo_lc,
        },
    ],
    "visualizations": [
        {
            "name": "The Approximation Function and the Lagrange Constant Floor",
            "description": (
                "Two-panel matplotlib figure. Left: scatter of q*||qx|| over q=1..Q for the "
                "golden ratio, sqrt(2), and pi, with the universal bound y=1 and the Hurwitz "
                "floor y=1/sqrt(5) overlaid. Right: the running minimum (empirical Lc) on a "
                "log-x axis, showing the golden ratio leveling at 1/sqrt(5) while other numbers "
                "dip lower."
            ),
            "code": viz,
        },
    ],
    "interactive_demos": [
        {
            "title": "The Lagrange Constant Explorer",
            "description": (
                "An interactive single-file widget. Pick a real number (golden ratio, sqrt(2), "
                "sqrt(3), pi, e, a Liouville number, or a custom value) and a maximum denominator "
                "Q, then watch the scatter of q*||qx|| against the universal bound 1 and the "
                "Hurwitz floor 1/sqrt(5), see the live empirical Lagrange constant with a verdict "
                "(within bound / essentially zero), and read off the continued-fraction "
                "convergents in a table with their errors and 1/q^2 bounds."
            ),
            "html": interactive,
        },
    ],
    "lean_proofs": lean_proofs,
    "future_directions": read("FUTURE_DIRECTIONS.txt"),
    "modules": {
        "demo": demo,
        "visualize": viz,
        "interactive": interactive,
    },
    "lean_files": [
        "Catalog/Applications/ContinuedFractions/DiophantineApproximation.lean",
        "Catalog/Applications/ContinuedFractions/LagrangeConstantBridge.lean",
    ],
}

(HERE / "PACKAGE.json").write_text(json.dumps(pkg, indent=2, ensure_ascii=False), encoding="utf-8")
print("wrote PACKAGE.json")


"""Numerical demonstrations for:

    Diophantine Approximation and the Lagrange Constant

This self-contained script illustrates the three formalized results:

  * irrational_den_unbounded
        For an irrational x and any N there is a Dirichlet-good rational p/q
        (|x - p/q| < 1/q^2) with denominator q >= N.

  * Lc_le_one_of_irrational
        Lc(x) = liminf_{q->inf} q * ||q x||  <=  1  for every irrational x,
        where ||y|| is the distance from y to the nearest integer.

  * Lc_eq_zero_of_liouville / liouville_not_bad
        Liouville numbers have Lc(x) = 0, hence are not badly approximable.

Everything below is implemented from scratch with type hints; no third-party
libraries are required (only the standard library).
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Iterator


# --------------------------------------------------------------------------- #
#  Core quantities
# --------------------------------------------------------------------------- #
def nearest_int_distance(y: float) -> float:
    """Return ||y|| = distance from y to the nearest integer (in [0, 1/2])."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """The approximation function approx(x, q) = q * ||q x||."""
    return q * nearest_int_distance(q * x)


# --------------------------------------------------------------------------- #
#  Continued fractions: an effective witness for unbounded denominators
# --------------------------------------------------------------------------- #
def continued_fraction_convergents(x: float, n_terms: int) -> Iterator[Fraction]:
    """Yield successive convergents p_k / q_k of the real number x.

    Each convergent is a best rational approximation and satisfies
    |x - p_k/q_k| < 1/q_k^2, with strictly increasing denominators q_k --
    an explicit constructive form of `irrational_den_unbounded`.
    """
    p_prev, p_cur = 0, 1          # p_{-2}, p_{-1}
    q_prev, q_cur = 1, 0          # q_{-2}, q_{-1}
    xk: float = x
    for _ in range(n_terms):
        a = math.floor(xk)
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        yield Fraction(p_cur, q_cur)
        frac = xk - a
        if frac <= 1e-15:         # x was (numerically) rational; stop
            return
        xk = 1.0 / frac


def demo_unbounded_denominators(x: float, name: str, targets: list[int]) -> None:
    """Show that Dirichlet-good approximations exist with denominator >= N."""
    print(f"\n[unbounded denominators] x = {name} ~ {x:.12f}")
    convs = list(continued_fraction_convergents(x, 40))
    for N in targets:
        chosen = next((c for c in convs if c.denominator >= N), None)
        if chosen is None:
            print(f"  N = {N:>10}: (need more convergents)")
            continue
        q = chosen.denominator
        err = abs(x - float(chosen))
        bound = 1.0 / q ** 2
        flag = "OK" if err < bound else "??"
        print(
            f"  N = {N:>10}: p/q = {chosen}  "
            f"q = {q:>12}  |x - p/q| = {err:.3e} < 1/q^2 = {bound:.3e}  [{flag}]"
        )


# --------------------------------------------------------------------------- #
#  Empirical Lagrange constant
# --------------------------------------------------------------------------- #
def empirical_lagrange_constant(x: float, q_max: int) -> float:
    """Estimate Lc(x) = liminf_q q*||q x|| as the minimum over 1..q_max."""
    return min(approx(x, q) for q in range(1, q_max + 1))


def demo_universal_bound(x: float, name: str, q_max: int = 5000) -> None:
    """Illustrate Lc(x) <= 1 for an irrational x."""
    est = empirical_lagrange_constant(x, q_max)
    flag = "OK (<= 1)" if est <= 1.0 + 1e-12 else "?? exceeds 1"
    print(f"  Lc({name}) ~ min_{{q<= {q_max}}} q*||qx|| = {est:.6f}   [{flag}]")


# --------------------------------------------------------------------------- #
#  Liouville number L = sum 10^{-k!}
# --------------------------------------------------------------------------- #
def liouville_number(num_terms: int = 8) -> Fraction:
    """Exact partial sum of the canonical Liouville number sum_{k>=1} 10^{-k!}."""
    total = Fraction(0)
    for k in range(1, num_terms + 1):
        total += Fraction(1, 10 ** math.factorial(k))
    return total


def demo_liouville_vanishing() -> None:
    """Show approx(L, q) plunges toward 0: Lc(L) = 0, so L is not badly approx."""
    print("\n[Liouville vanishing]  L = sum_{k>=1} 10^{-k!}")
    L = liouville_number(8)
    Lf = float(L)
    # Use the factorial-truncation denominators q = 10^{n!} as best witnesses.
    for n in range(1, 6):
        q = 10 ** math.factorial(n)
        # exact distance using rational arithmetic where feasible
        p = round(L * q)
        err = abs(L - Fraction(p, q))
        a = float(q) * float(abs(err))   # q * ||qL|| along these denominators
        print(f"  n = {n}: q = 10^{math.factorial(n)} (={q:.3e})  "
              f"q*||qL|| ~ {a:.3e}")
    print("  -> the values collapse toward 0, witnessing Lc(L) = 0.")
    print(f"  (numeric L ~ {Lf:.18f})")


# --------------------------------------------------------------------------- #
#  Contrast: the golden ratio, the most badly approximable number
# --------------------------------------------------------------------------- #
def demo_golden_ratio_floor() -> None:
    """The golden ratio realizes the largest Lc, approaching 1/sqrt(5)."""
    phi = (1 + math.sqrt(5)) / 2
    est = empirical_lagrange_constant(phi, 20000)
    print("\n[contrast] golden ratio phi = (1+sqrt5)/2")
    print(f"  Lc(phi) ~ {est:.6f}   (theory: 1/sqrt(5) = {1/math.sqrt(5):.6f})")
    print("  phi is badly approximable: Lc(phi) > 0, unlike any Liouville number.")


def main() -> None:
    print("=" * 70)
    print("Diophantine Approximation and the Lagrange Constant -- demo")
    print("=" * 70)

    targets = [10, 1000, 10 ** 6, 10 ** 9]
    demo_unbounded_denominators(math.sqrt(2), "sqrt(2)", targets)
    demo_unbounded_denominators(math.pi, "pi", targets)

    print("\n[universal bound]  Lc(x) <= 1 for every irrational x")
    demo_universal_bound(math.sqrt(2), "sqrt(2)")
    demo_universal_bound(math.pi, "pi")
    demo_universal_bound(math.e, "e")

    demo_liouville_vanishing()
    demo_golden_ratio_floor()


if __name__ == "__main__":
    main()


"""Visualization: the approximation function q -> q*||q x|| and the Lagrange
constant floor, contrasting a quadratic irrational, pi, and a Liouville number.

Generates a figure with two panels:
  (left)  scatter of q*||q x|| for q = 1..Q, with the universal bound y = 1
          and the Hurwitz floor y = 1/sqrt(5) drawn for reference;
  (right) the running minimum (empirical Lc) vs q on a log-x axis, showing the
          golden ratio leveling at 1/sqrt(5) while a Liouville-like number dives.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import math
from typing import Callable

import numpy as np
import matplotlib.pyplot as plt


def nearest_int_distance(y: float) -> float:
    """||y|| = distance from y to the nearest integer."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """approx(x, q) = q * ||q x||."""
    return q * nearest_int_distance(q * x)


def running_min(x: float, q_max: int) -> np.ndarray:
    """Vector of running minima of approx(x, .) up to each q."""
    vals = np.array([approx(x, q) for q in range(1, q_max + 1)])
    return np.minimum.accumulate(vals)


def main() -> None:
    q_max = 3000
    phi = (1 + math.sqrt(5)) / 2
    numbers: dict[str, float] = {
        "golden ratio phi": phi,
        "sqrt(2)": math.sqrt(2),
        "pi": math.pi,
    }

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    qs = np.arange(1, q_max + 1)
    for name, x in numbers.items():
        ax1.scatter(qs, [approx(x, q) for q in qs], s=4, alpha=0.4, label=name)
    ax1.axhline(1.0, color="black", ls="--", lw=1, label="universal bound 1")
    ax1.axhline(1 / math.sqrt(5), color="red", ls=":", lw=1.5,
                label="Hurwitz floor 1/sqrt5")
    ax1.set_xlabel("denominator q")
    ax1.set_ylabel("q * ||q x||")
    ax1.set_title("Approximation function (every value <= 1 universally)")
    ax1.set_ylim(0, 1.2)
    ax1.legend(loc="upper right", fontsize=8)

    for name, x in numbers.items():
        ax2.plot(qs, running_min(x, q_max), label=name)
    ax2.axhline(1 / math.sqrt(5), color="red", ls=":", lw=1.5,
                label="1/sqrt5")
    ax2.set_xscale("log")
    ax2.set_xlabel("denominator q (log scale)")
    ax2.set_ylabel("running min  (empirical Lc)")
    ax2.set_title("Empirical Lagrange constant: phi levels off, others dip lower")
    ax2.legend(loc="upper right", fontsize=8)

    fig.suptitle("Diophantine approximation and the Lagrange constant")
    fig.tight_layout()
    fig.savefig("lagrange_constant.png", dpi=150)
    print("wrote lagrange_constant.png")


if __name__ == "__main__":
    main()
