"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Shared/SeparatedPrincipalFiltration.lean",
    "Catalog/Shared/SeparatedPrincipalFiltrationValuation.lean",
    "Catalog/Shared/SeparatedPrincipalFiltrationStructure.lean",
    "Catalog/Shared/SeparatedPrincipalFiltrationExamples.lean",
    "Catalog/Shared/SeparatedPrincipalFiltrationCounterexample.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {path} =====\n\n{read(ROOT / path)}" for path in LEAN_FILES
)

package = {
    "title": "Separated Principal Filtrations: Heights, Chain Conditions, and the Archimedean Boundary",
    "domain": "Shared",
    "description": (
        "For an element a of a commutative domain R, the principal filtration n ↦ (aⁿ) is "
        "separated (its total intersection is zero) precisely when there exists an ℕ-valued "
        "height function that strictly increases under multiplication by a; chain conditions "
        "such as Noetherianity or unique factorization are sufficient but not necessary, and "
        "the ring ℤ + X·ℚ[X] marks the exact boundary where separation fails."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-12",
    "key_results": [
        "Height Criterion: in a domain, the existence of any ℕ-valued function v with v(x) < v(ax) for every nonzero x forces the intersection of all powers of (a) to vanish, with no chain or finiteness hypothesis.",
        "Separation is equivalent to the existence of a height function, and the a-adic order is the pointwise minimal such height — so a Krull-type intersection theorem is a statement about heights rather than about ascending chains.",
        "Krull separation for principal filtrations: in a domain with well-founded divisibility (hence in every Noetherian domain and every unique factorization domain), the principal filtration at an element is separated exactly when that element is not a unit.",
        "The intersection of the powers of (a) is the greatest a-divisible ideal, i.e. the greatest fixed point of I ↦ (a)·I on the ideal lattice; the Noetherian case follows from Nakayama's lemma applied to that fixed point.",
        "Separation is equivalent to Hausdorffness of the a-adic topology and to injectivity into the a-adic completion, and for a prime element it upgrades the adic order to a non-archimedean absolute value ‖x‖ = 2^(−ord(x)).",
        "Exact boundary computation: in ℤ + X·ℚ[X] the element 2 is a nonzero non-unit whose principal filtration has intersection exactly X·ℚ[X], so that ring is neither Noetherian nor a UFD and admits no ℕ-valued height function for 2.",
    ],
    "keywords": [
        "Krull intersection theorem",
        "principal filtration",
        "adic topology",
        "height function",
        "multiplicity",
        "non-archimedean absolute value",
        "Nakayama's lemma",
        "D+M construction",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Tour of Separated Principal Filtrations",
            "description": (
                "A self-contained, dependency-free walkthrough of every result in the theory, "
                "using exact rational arithmetic. It verifies that the absolute value on ℤ and "
                "the degree on ℚ[X] are height functions and exhibits the growth bound "
                "n + v(x) ≤ v(aⁿx); computes the 2-adic order and checks the increment law "
                "ord(ax) = ord(x) + 1, additivity on products, and the ultrametric inequality; "
                "tabulates the 2-adic absolute value and confirms multiplicativity and the strong "
                "triangle inequality; demonstrates that an inflated height still dominates the adic "
                "order pointwise; constructs the ring ℤ + X·ℚ[X] and prints explicit witnesses "
                "showing X = 2ⁿ·(X/2ⁿ) inside it for every n, so that the intersection of all powers "
                "of (2) equals the ideal of elements with zero constant coefficient; contrasts the "
                "terminating 'strip all factors of a' loop in ℤ with its non-termination there; "
                "verifies the greatest-fixed-point description of the intersection; and simulates the "
                "non-finite-generation argument for the irrelevant ideal of a polynomial ring in "
                "countably many variables."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Adic Order by Exhaustive Trial Division",
            "description": (
                "Computes ord_a(x), the largest exponent n with aⁿ dividing x, by repeatedly "
                "dividing out factors of a. The algorithm is generic over any ring equipped with a "
                "divisibility test, an exact division, and a zero test. Its termination on every "
                "nonzero input is not an implementation detail but is mathematically *equivalent* to "
                "separation of the principal filtration at a: the loop halts everywhere exactly when "
                "the intersection of all powers of (a) is zero. In ℤ with |a| ≥ 2 it performs "
                "O(log_{|a|}|x|) exact divisions, each of cost linear in the bit length; in a "
                "polynomial ring at a = X it performs at most deg(x) steps. The optional step budget "
                "converts the algorithm into a detector: exhausting the budget certifies (at that "
                "precision) an infinitely divisible element and hence failure of separation. The "
                "returned order immediately yields the adic absolute value 2^(−ord)."
            ),
            "pseudocode": (
                "INPUT : a ring element x ≠ 0; a divisibility predicate divides(·);\n"
                "        an exact division divide(·); a zero test is_zero(·);\n"
                "        an optional step budget B.\n"
                "OUTPUT: (k, terminated) where k = ord_a(x) when terminated is true.\n"
                "\n"
                "1.  if is_zero(x) then FAIL  (the order is undefined at 0)\n"
                "2.  k   <- 0\n"
                "3.  cur <- x\n"
                "4.  while divides(cur) do\n"
                "5.       cur <- divide(cur)        // exact; no remainder by construction\n"
                "6.       k   <- k + 1\n"
                "7.       if B is given and k >= B then\n"
                "8.            return (k, false)    // infinite divisibility suspected:\n"
                "9.                                 // separation fails at this element\n"
                "10. return (k, true)\n"
                "\n"
                "CORRECTNESS: each iteration replaces cur by cur/a, so after k iterations\n"
                "x = a^k · cur; the loop exits when a does not divide cur, which is exactly\n"
                "the maximality defining ord_a(x).\n"
                "TERMINATION: guaranteed for all nonzero x if and only if ⋂ₙ (aⁿ) = 0."
            ),
            "code": read(A / "algorithm_ord.py"),
        },
        {
            "name": "Separation Certification by Height Verification",
            "description": (
                "Turns the Height Criterion into a practical certification procedure. A height "
                "function for a is any v : R → ℕ with v(x) < v(ax) for every nonzero x; exhibiting "
                "one proves, over a domain, that the principal filtration at a is separated — with no "
                "chain condition, no factorization theory, and no finiteness assumption on the ring. "
                "The module checks a candidate height on a finite sample and reports counterexamples; "
                "converts a verified height into the explicit termination bound v(x) + 1, the first "
                "exponent at which divisibility by a power of a must fail; and compares the candidate "
                "against the canonical adic order, illustrating the minimality theorem that every "
                "height dominates the adic order pointwise. Verification costs one evaluation of v "
                "and one ring multiplication per sample point. The method is complete in the sense "
                "that separation always admits some height, so failure to find one is informative."
            ),
            "pseudocode": (
                "PART A — verify a candidate height on a sample.\n"
                "INPUT : candidate v : R → ℕ; the multiplication map x ↦ a·x; a finite sample S.\n"
                "OUTPUT: (passed, failures).\n"
                "1.  failures <- empty list\n"
                "2.  for each x in S with x ≠ 0 do\n"
                "3.       if not (v(x) < v(a·x)) then append x to failures\n"
                "4.  return (failures is empty, failures)\n"
                "\n"
                "PART B — convert a verified height into a termination bound.\n"
                "INPUT : a verified height v; an element x ≠ 0.\n"
                "OUTPUT: the least N with a^N ∤ x guaranteed.\n"
                "1.  return v(x) + 1\n"
                "JUSTIFICATION: induction gives n + v(y) ≤ v(aⁿ y) for y ≠ 0; if x = a^N y with\n"
                "N = v(x)+1 and y ≠ 0 then v(x) ≥ v(x) + 1 + v(y), a contradiction.\n"
                "\n"
                "PART C — minimality check against the canonical height.\n"
                "1.  for each x ≠ 0 in the sample: assert ord_a(x) ≤ v(x)."
            ),
            "code": read(A / "algorithm_height.py"),
        },
        {
            "name": "Exact Intersection Computation in the D+M Domain",
            "description": (
                "Decides, in closed form, membership in the infinite intersection of the powers of "
                "(2) inside S = ℤ + X·ℚ[X], the ring of rational polynomials whose constant "
                "coefficient is an integer. Although the defining condition quantifies over all "
                "exponents n, the theory collapses it to a single O(1) test: an element of S lies in "
                "the intersection if and only if its constant coefficient is zero. The module also "
                "produces the explicit divisibility witnesses q with p = 2ⁿ·q lying in S (they exist "
                "for all n exactly when the constant coefficient vanishes), and verifies on a sample "
                "that X·ℚ[X] is a fixed point of the ideal map I ↦ (2)·I — hence, by the "
                "greatest-fixed-point theorem, the greatest 2-divisible ideal of S. Together these "
                "give an effective refutation of separation at a nonzero non-unit, and thereby "
                "effective proofs that S is neither Noetherian nor a unique factorization domain and "
                "admits no ℕ-valued height function for 2. Cost: exact rational arithmetic linear in "
                "the number of coefficients."
            ),
            "pseudocode": (
                "MEMBERSHIP TEST\n"
                "INPUT : p, a polynomial over ℚ with integer constant coefficient (i.e. p ∈ S).\n"
                "OUTPUT: whether p ∈ ⋂ₙ (2ⁿ).\n"
                "1.  if constant_coefficient(p) is not an integer then FAIL (p ∉ S)\n"
                "2.  return constant_coefficient(p) == 0\n"
                "JUSTIFICATION: writing p = 2ⁿ q with q ∈ S and comparing constant coefficients\n"
                "gives m = 2ⁿ k with m, k ∈ ℤ, so m is divisible by every power of 2, hence m = 0;\n"
                "conversely if m = 0 then p/2ⁿ again has constant coefficient 0 and lies in S.\n"
                "\n"
                "WITNESS GENERATION\n"
                "INPUT : p ∈ S and a bound N.\n"
                "1.  for n = 0 .. N do\n"
                "2.       q <- p scaled by 1/2ⁿ\n"
                "3.       emit q if its constant coefficient is an integer, else emit 'none'\n"
                "\n"
                "FIXED-POINT CHECK\n"
                "INPUT : a finite sample of elements of the candidate ideal I = X·ℚ[X].\n"
                "1.  for each p in the sample: assert p/2 lies in S and has zero constant term\n"
                "2.  conclude I ⊆ (2)·I on the sample, witnessing a nonzero 2-divisible ideal."
            ),
            "code": read(A / "algorithm_dm.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Collapsing Filtration, the Adic Metric, and the Growth Bound",
            "description": (
                "A three-panel figure for ℤ at a = 2. The left panel draws the nested ideals (2ⁿ) "
                "as increasingly sparse dot lattices inside the window [−32, 32], with only the "
                "origin surviving every level — the visual content of the statement that the "
                "intersection of all powers is zero. The middle panel plots the 2-adic absolute "
                "value 2^(−ord₂ x) for x = 1..64 on a logarithmic axis, exhibiting its "
                "characteristic self-similar comb and, crucially, its never vanishing off zero: "
                "that nondegeneracy is precisely separation. The right panel plots the height "
                "v = |·| of 2ⁿx against the linear lower bound n + v(x) for several starting "
                "values, displaying the single inequality that powers the Height Criterion."
            ),
            "code": read(A / "viz_filtration.py"),
        },
        {
            "name": "The Boundary Case: Infinite Divisibility in ℤ + X·ℚ[X]",
            "description": (
                "A two-panel figure explaining where and why the theory stops. The left panel tracks "
                "the coefficient of X in X/2ⁿ as n grows: it shrinks geometrically yet never leaves "
                "the ring, because only the constant coefficient is constrained to be an integer — so "
                "X is divisible by every power of 2 and the intersection is nonzero. The right panel "
                "renders the underlying rank-two, non-archimedean structure: one axis records the "
                "powers of 2 available in the constant term, the other the freely divisible "
                "X-direction. An element such as 3 + X is blocked immediately on the first axis, while "
                "X slides forever along the second, since dividing by 2 costs nothing there. This is "
                "the geometric reason no ℕ-valued height function can exist."
            ),
            "code": read(A / "viz_counterexample.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Infinite Divisibility Explorer",
            "description": (
                "A single, carefully built laboratory for the whole theory. Choose one of three "
                "rings — the integers, the rational polynomials, or the D+M ring ℤ + X·ℚ[X] of "
                "rational polynomials with integer constant term — then choose a divisor a and a "
                "target x, and watch the descent x, x/a, x/a², … unfold step by step with exact "
                "rational arithmetic (arbitrary-precision, so nothing is lost to floating point). "
                "In the first two rings the descent always halts, the number of steps is displayed as "
                "the adic order, and the adic absolute value 2^(−ord) is computed; in the third, "
                "starting from X with a = 2, the descent visibly never halts, and the widget spells "
                "out the full cascade of consequences: the intersection of the ideal powers is "
                "nonzero, the adic order is infinite, the adic topology is not Hausdorff, the map "
                "into the completion kills the element, and no ℕ-valued height function for 2 can "
                "exist on that ring at all. A side panel evaluates candidate height functions on the "
                "current input and reports whether each strictly increases under multiplication by a; "
                "another tabulates the adic order along the descent with a bar chart of the adic "
                "norm, illustrating that the adic order is the minimal height. A drawn lattice shows "
                "the nested ideals thinning out until only zero survives, and collapsible panels "
                "reveal the two-line proof of the Height Criterion and the cancellation argument "
                "behind the increment law ord(ax) = ord(x) + 1."
            ),
            "html": read(A / "widget.html"),
        }
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": read(A / "future_directions.txt"),
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Visualization: where separation fails — the ring Z + X*Q[X].

Left panel: repeatedly halving X inside S = Z + X*Q[X]. The coefficient of X
shrinks as 2^-n but never leaves the ring, because only the *constant*
coefficient is constrained to be an integer. Hence X lies in every ideal (2^n)
and the intersection is nonzero.

Right panel: the two-scale ("rank two") structure that causes the failure.
Elements of S are plotted by (integrality budget of the constant term,
2-adic freedom of the X-direction). Dividing by 2 moves an element one step
left on the first axis and zero steps on the second — so an element living
purely on the second axis can be divided forever.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Left: X / 2^n stays in S forever.
    ax = axes[0]
    ns = np.arange(0, 13)
    coeffs: List[float] = [float(Fraction(1, 2**int(n))) for n in ns]
    ax.semilogy(ns, coeffs, "o-", color="crimson", label=r"coefficient of $X$ in $X/2^n$")
    ax.axhline(1.0, color="gray", ls=":", lw=1)
    ax.fill_between(ns, 1e-5, 2, color="mediumseagreen", alpha=0.12)
    ax.text(6.0, 3e-4, "all of these lie in $S$:\nthe constant term is $0\\in\\mathbb{Z}$",
            ha="center", fontsize=10)
    ax.set_xlabel("$n$")
    ax.set_ylabel("coefficient")
    ax.set_title(r"$X = 2^n\cdot(X/2^n)$ inside $S=\mathbb{Z}+X\mathbb{Q}[X]$")
    ax.legend()
    ax.grid(alpha=0.25, which="both")

    # Right: the rank-two picture.
    ax = axes[1]
    ax.annotate("", xy=(6.2, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.annotate("", xy=(0, 4.2), xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.text(6.3, -0.15, "powers of $2$ available in the constant term", fontsize=9)
    ax.text(-0.2, 4.35, "the $X$-direction (free over $\\mathbb{Q}$)", fontsize=9)

    # Trajectory of 3 + X under division by 2: halts after 0 steps.
    ax.scatter([0], [1.0], s=110, color="crimson", zorder=3)
    ax.text(0.15, 1.05, "$3 + X$: constant term $3$ blocks division", fontsize=9)

    # Trajectory of X: slides forever along the X-axis at height 0 cost.
    ys = [2.6] * 7
    xs = list(range(7))
    ax.plot(xs, ys, "o-", color="seagreen")
    for k in range(7):
        ax.text(k - 0.1, 2.75, f"$X/2^{k}$", fontsize=8)
    ax.text(1.6, 3.4, "division by $2$ costs nothing here:\nthe value monoid has rank two",
            fontsize=10)

    ax.set_xlim(-0.6, 7.4)
    ax.set_ylim(-0.6, 4.8)
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.set_title("Why separation fails: a non-archimedean, rank-two scale")

    fig.suptitle("The boundary case: $\\bigcap_n (2^n) = X\\,\\mathbb{Q}[X] \\neq 0$",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("separation_counterexample.png", dpi=150)
    print("wrote separation_counterexample.png")


if __name__ == "__main__":
    main()


"""Visualization: the shrinking principal filtration and the 2-adic metric.

Three panels:
  (left)   the nested ideals (2^n) inside a window of Z, drawn as increasingly
           sparse dot lattices — the visual content of ⋂_n (2^n) = 0;
  (middle) the 2-adic absolute value ||x||_2 = 2^(-ord_2 x) on 1..64, whose
           nondegeneracy is exactly separation;
  (right)  the growth bound n + v(x) <= v(2^n x) for the height v = |.|,
           the single inequality that powers the Height Criterion.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def ord2(x: int) -> int:
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: nested ideals (2^n) in the window [-32, 32].
    ax = axes[0]
    window = 32
    levels = 6
    for n in range(levels):
        step = 2**n
        pts: List[int] = list(range(-window, window + 1, step))
        ax.scatter(pts, [n] * len(pts), s=18, color=plt.cm.viridis(n / levels))
    ax.scatter([0], [levels], s=90, color="crimson", zorder=3)
    ax.set_yticks(list(range(levels + 1)))
    ax.set_yticklabels([f"$(2^{n})$" for n in range(levels)] + [r"$\bigcap_n (2^n)=\{0\}$"])
    ax.set_xlabel("integers in the window $[-32, 32]$")
    ax.set_title("The principal filtration collapses to $0$")
    ax.grid(alpha=0.2)

    # Panel 2: the 2-adic absolute value.
    ax = axes[1]
    xs = np.arange(1, 65)
    vals = [2.0 ** (-ord2(int(x))) for x in xs]
    ax.stem(xs, vals, basefmt=" ", linefmt="C0-", markerfmt="C0o")
    ax.set_yscale("log", base=2)
    ax.set_xlabel("$x$")
    ax.set_ylabel(r"$\|x\|_2 = 2^{-\mathrm{ord}_2 x}$")
    ax.set_title("The $2$-adic absolute value is never $0$ off $0$")
    ax.grid(alpha=0.25, which="both")

    # Panel 3: the growth bound n + v(x) <= v(2^n x).
    ax = axes[2]
    ns = np.arange(0, 13)
    for x0 in (1, 3, 7):
        ax.plot(ns, [abs(x0) * 2 ** int(n) for n in ns], "o-", label=fr"$v(2^n\cdot{x0})$")
        ax.plot(ns, [int(n) + abs(x0) for n in ns], "--", alpha=0.7,
                label=fr"$n + v({x0})$ (lower bound)")
    ax.set_yscale("log", base=2)
    ax.set_xlabel("$n$")
    ax.set_ylabel("height $v = |\\cdot|$")
    ax.set_title("Height grows at least linearly: $n + v(x) \\leq v(a^n x)$")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.25, which="both")

    fig.suptitle("Separated principal filtrations in $\\mathbb{Z}$ at $a = 2$", fontsize=14)
    fig.tight_layout()
    fig.savefig("separation_filtration.png", dpi=150)
    print("wrote separation_filtration.png")


if __name__ == "__main__":
    main()


"""
Separated Principal Filtrations — numerical demonstrations.
============================================================

For a commutative domain R and an element a in R, the principal a-adic
filtration is the descending tower of ideals

        R = (a^0) ⊇ (a) ⊇ (a^2) ⊇ ...

It is called *separated* when the total intersection collapses:

        ⋂_n (a^n) = {0},

equivalently: the only element divisible by every power of a is 0.

This script demonstrates, with explicit computation:

  1. Separation in Z at a = 2 (and other |a| >= 2), via the height |x|.
  2. Separation in Q[X] at a = X, via the height deg(p).
  3. The a-adic order ord_a, its increment-by-one law ord_a(a x) = ord_a(x) + 1,
     additivity for prime a, and the ultrametric inequality.
  4. The a-adic absolute value ||x||_a = 2^(-ord_a x) and the strong triangle
     inequality ||x + y||_a <= max(||x||_a, ||y||_a).
  5. Minimality of ord_a among all height functions.
  6. The counterexample S = Z + X·Q[X], in which 2 is a nonzero non-unit and
     X is divisible by every power of 2, so that ⋂_n (2^n) = X·Q[X] ≠ 0.
  7. The greatest-fixed-point description: ⋂_n (a^n) is the largest ideal I
     with I ⊆ (a)·I; in S this is exactly the ideal of elements with zero
     constant coefficient.
  8. Termination of the "divide out all factors of a" loop as an operational
     reading of separation — and its non-termination in S.

Everything is self-contained: only the Python standard library is used
(`fractions.Fraction` for exact rational arithmetic).
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Section 0. A minimal exact polynomial type over the rationals.
# ----------------------------------------------------------------------------


@dataclass(frozen=True)
class Poly:
    """A polynomial with exact rational coefficients, coeffs[i] = coefficient of X^i."""

    coeffs: Tuple[Fraction, ...]

    @staticmethod
    def of(values: Sequence[object]) -> "Poly":
        """Build a polynomial from a coefficient list (constant term first)."""
        cs = [Fraction(v) for v in values]  # type: ignore[arg-type]
        while cs and cs[-1] == 0:
            cs.pop()
        return Poly(tuple(cs))

    def is_zero(self) -> bool:
        return len(self.coeffs) == 0

    def degree(self) -> int:
        """Degree, with the convention deg(0) = 0 (only used as a height)."""
        return max(len(self.coeffs) - 1, 0)

    def coeff(self, i: int) -> Fraction:
        return self.coeffs[i] if i < len(self.coeffs) else Fraction(0)

    def __add__(self, other: "Poly") -> "Poly":
        n = max(len(self.coeffs), len(other.coeffs))
        return Poly.of([self.coeff(i) + other.coeff(i) for i in range(n)])

    def __mul__(self, other: "Poly") -> "Poly":
        if self.is_zero() or other.is_zero():
            return Poly.of([])
        n = len(self.coeffs) + len(other.coeffs) - 1
        out = [Fraction(0)] * n
        for i, c in enumerate(self.coeffs):
            for j, d in enumerate(other.coeffs):
                out[i + j] += c * d
        return Poly.of(out)

    def scale(self, factor: Fraction) -> "Poly":
        return Poly.of([c * factor for c in self.coeffs])

    def shift(self, k: int) -> "Poly":
        """Multiply by X^k."""
        return Poly.of([Fraction(0)] * k + list(self.coeffs))

    def divide_by_X(self) -> Optional["Poly"]:
        """Exact division by X, or None if the constant term is nonzero."""
        if self.is_zero():
            return self
        if self.coeff(0) != 0:
            return None
        return Poly.of(list(self.coeffs[1:]))

    def __str__(self) -> str:
        if self.is_zero():
            return "0"
        parts: List[str] = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                parts.append(f"{c}")
            elif i == 1:
                parts.append(f"{c}*X")
            else:
                parts.append(f"{c}*X^{i}")
        return " + ".join(parts)


X = Poly.of([0, 1])


def const(value: object) -> Poly:
    return Poly.of([value])


# ----------------------------------------------------------------------------
# Section 1. Heights and the Height Criterion.
# ----------------------------------------------------------------------------


def check_height_property_int(a: int, sample: Iterable[int]) -> bool:
    """Verify v(x) < v(a*x) for v = |.| on a sample of nonzero integers."""
    return all(abs(x) < abs(a * x) for x in sample if x != 0)


def check_height_property_poly(sample: Iterable[Poly]) -> bool:
    """Verify v(p) < v(X*p) for v = deg on a sample of nonzero polynomials."""
    return all(p.degree() < (X * p).degree() for p in sample if not p.is_zero())


def growth_bound_int(a: int, x: int, n: int) -> Tuple[int, int]:
    """Return (n + v(x), v(a^n x)) for v = |.|, illustrating n + v(x) <= v(a^n x)."""
    return n + abs(x), abs(a**n * x)


# ----------------------------------------------------------------------------
# Section 2. The a-adic order (multiplicity), computed by trial division.
# ----------------------------------------------------------------------------


def ord_int(a: int, x: int, cap: int = 10_000) -> int:
    """The a-adic order of a nonzero integer x: the largest n with a^n | x.

    The loop terminates precisely because the principal filtration at a is
    separated; `cap` is a guard, never reached for |a| >= 2 and x != 0.
    """
    if x == 0:
        raise ValueError("ord is undefined at 0 (formally +infinity)")
    if abs(a) < 2:
        raise ValueError("a must be a non-unit, nonzero integer")
    k = 0
    while x % a == 0 and k < cap:
        x //= a
        k += 1
    return k


def ord_poly_X(p: Poly, cap: int = 10_000) -> int:
    """The X-adic order of a nonzero polynomial: the index of its lowest nonzero term."""
    if p.is_zero():
        raise ValueError("ord is undefined at 0")
    k = 0
    cur = p
    while k < cap:
        nxt = cur.divide_by_X()
        if nxt is None:
            return k
        cur = nxt
        k += 1
    return k


def adic_abs_from_ord(order: Optional[int]) -> Fraction:
    """||x||_a = 2^(-ord_a x), with ||0||_a = 0 (order = None encodes x = 0)."""
    if order is None:
        return Fraction(0)
    return Fraction(1, 2**order)


def adic_abs_int(a: int, x: int) -> Fraction:
    return adic_abs_from_ord(None if x == 0 else ord_int(a, x))


# ----------------------------------------------------------------------------
# Section 3. The ring S = Z + X*Q[X]: rational polynomials with integer
#            constant coefficient. Here separation FAILS at a = 2.
# ----------------------------------------------------------------------------


def in_S(p: Poly) -> bool:
    """Membership test for S = Z + X*Q[X]: the constant coefficient is an integer."""
    return p.coeff(0).denominator == 1


def two_pow_divides_in_S(p: Poly, n: int) -> Optional[Poly]:
    """Return q in S with p = 2^n * q, if such a q exists; else None."""
    q = p.scale(Fraction(1, 2**n))
    return q if in_S(q) else None


def intersection_membership_certificate(p: Poly, upto: int) -> List[Tuple[int, str]]:
    """For each n <= upto, exhibit the witness q with p = 2^n q inside S (if any)."""
    out: List[Tuple[int, str]] = []
    for n in range(upto + 1):
        q = two_pow_divides_in_S(p, n)
        out.append((n, str(q) if q is not None else "— not divisible in S —"))
    return out


def strip_twos_in_S(p: Poly, budget: int = 12) -> Tuple[int, bool]:
    """Run the 'divide out all factors of 2' loop inside S, with a step budget.

    Returns (steps_taken, terminated). For p with zero constant coefficient the
    loop never terminates: that is exactly the failure of separation.
    """
    cur = p
    for step in range(budget):
        nxt = cur.scale(Fraction(1, 2))
        if not in_S(nxt):
            return step, True
        cur = nxt
    return budget, False


# ----------------------------------------------------------------------------
# Section 4. Minimality of the adic order among height functions.
# ----------------------------------------------------------------------------


def is_height_function_int(a: int, v: Callable[[int], int], sample: Iterable[int]) -> bool:
    return all(v(x) < v(a * x) for x in sample if x != 0)


def check_order_minimality_int(
    a: int, v: Callable[[int], int], sample: Iterable[int]
) -> List[Tuple[int, int, int]]:
    """Compare ord_a(x) with v(x); the theory predicts ord_a(x) <= v(x)."""
    rows: List[Tuple[int, int, int]] = []
    for x in sample:
        if x == 0:
            continue
        rows.append((x, ord_int(a, x), v(x)))
    return rows


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def demo_1_height_criterion() -> None:
    rule("1. The Height Criterion in Z and in Q[X]")
    sample = [1, -1, 3, 7, -12, 96, 1024, -3**7]
    print(f"  v = |.| is a height function for a = 2 on the sample: "
          f"{check_height_property_int(2, sample)}")
    print(f"  v = |.| is a height function for a = -5 on the sample: "
          f"{check_height_property_int(-5, sample)}")
    polys = [const(1), X, X + const(3), Poly.of([Fraction(1, 3), 0, 2])]
    print(f"  v = deg is a height function for a = X on polynomials: "
          f"{check_height_property_poly(polys)}")
    print()
    print("  Growth bound  n + v(x) <= v(a^n x)  for a = 2:")
    for (x, n) in [(3, 0), (3, 1), (3, 4), (-7, 6)]:
        lhs, rhs = growth_bound_int(2, x, n)
        print(f"    x = {x:>4}, n = {n}:  {lhs:>6} <= {rhs:<8} {'OK' if lhs <= rhs else 'FAIL'}")
    print()
    print("  Consequence (Height Criterion): the only integer divisible by every")
    print("  power of 2 is 0. Concretely, for x = 3^7 = 2187 the divisibility")
    print(f"  2^n | x already fails at n = {ord_int(2, 3**7) + 1}.")


def demo_2_adic_order() -> None:
    rule("2. The 2-adic order: increment law, additivity, ultrametricity")
    print("   x      ord_2(x)   ord_2(2x)   (increment law: +1 exactly)")
    for x in [1, 3, 12, 40, -96, 2**10]:
        print(f"  {x:>6}      {ord_int(2, x):>3}        {ord_int(2, 2 * x):>3}"
              f"        {'OK' if ord_int(2, 2 * x) == ord_int(2, x) + 1 else 'FAIL'}")
    print()
    print("  Additivity ord_2(xy) = ord_2(x) + ord_2(y)  (2 is prime in Z):")
    for (x, y) in [(12, 40), (3, 7), (-8, 6), (2**5, 2**7 * 3)]:
        lhs = ord_int(2, x * y)
        rhs = ord_int(2, x) + ord_int(2, y)
        print(f"    x = {x:>6}, y = {y:>6}:  {lhs} = {rhs}   {'OK' if lhs == rhs else 'FAIL'}")
    print()
    print("  Ultrametric inequality  min(ord x, ord y) <= ord(x+y):")
    for (x, y) in [(12, 40), (4, 4), (6, 10), (2**6, 2**6 * 3)]:
        if x + y == 0:
            continue
        lhs = min(ord_int(2, x), ord_int(2, y))
        rhs = ord_int(2, x + y)
        print(f"    x = {x:>5}, y = {y:>5}:  min = {lhs} <= {rhs} = ord(x+y)"
              f"   {'OK' if lhs <= rhs else 'FAIL'}")


def demo_3_absolute_value() -> None:
    rule("3. The 2-adic absolute value ||x|| = 2^(-ord_2 x)")
    print("   x       ||x||_2")
    for x in [1, 2, 3, 4, 12, 40, 1024]:
        print(f"  {x:>6}     {adic_abs_int(2, x)}")
    print()
    print(f"  ||2||_2 = {adic_abs_int(2, 2)}   (the filtration really shrinks)")
    print()
    print("  Multiplicativity and the strong triangle inequality:")
    pairs = [(12, 40), (3, 5), (8, 24), (2**4, 2**4), (7, -7 + 2**8)]
    for (x, y) in pairs:
        mul_ok = adic_abs_int(2, x * y) == adic_abs_int(2, x) * adic_abs_int(2, y)
        s = x + y
        tri_ok = adic_abs_int(2, s) <= max(adic_abs_int(2, x), adic_abs_int(2, y))
        print(f"    x = {x:>5}, y = {y:>5}:  multiplicative {mul_ok},  ultrametric {tri_ok}")


def demo_4_minimality() -> None:
    rule("4. The adic order is the minimal height function")
    # An inflated, perfectly valid height function for a = 2.
    def v(x: int) -> int:
        return 3 * ord_int(2, x) + (abs(x) % 5) if x != 0 else 0

    sample = [1, 3, 12, 40, 96, 2**9, -48]
    print(f"  v(x) = 3*ord_2(x) + (|x| mod 5) is a height function: "
          f"{is_height_function_int(2, v, sample)}")
    print()
    print("     x      ord_2(x)     v(x)     ord <= v ?")
    for (x, o, vv) in check_order_minimality_int(2, v, sample):
        print(f"  {x:>6}       {o:>3}       {vv:>4}        {'OK' if o <= vv else 'FAIL'}")
    print()
    print("  Every height function dominates the adic order pointwise, so the adic")
    print("  order is the canonical, tightest witness of separation.")


def demo_5_counterexample() -> None:
    rule("5. Failure of separation in S = Z + X*Q[X]")
    print("  S = { rational polynomials whose constant coefficient is an integer }.")
    print()
    print("  Is 2 a unit of S?  Its inverse in Q[X] is the constant 1/2, whose")
    print(f"  constant coefficient 1/2 is an integer: {in_S(const(Fraction(1, 2)))}")
    print("  So 2 is a nonzero non-unit of S.")
    print()
    print("  Yet X is divisible by every power of 2 inside S, because X/2^n has")
    print("  constant coefficient 0:")
    for (n, witness) in intersection_membership_certificate(X, 6):
        print(f"    n = {n}:  X = 2^{n} * ({witness})")
    print()
    print("  Hence  ⋂_n (2^n) ⊇ X*Q[X] ≠ 0:  the filtration is NOT separated.")
    print()
    print("  Conversely, an element with nonzero constant coefficient is not")
    print("  infinitely divisible. Take p = 3 + X:")
    p = const(3) + X
    for (n, witness) in intersection_membership_certificate(p, 3):
        print(f"    n = {n}:  {witness}")
    print()
    print("  So ⋂_n (2^n) = { p in S : p(0) = 0 } = X*Q[X], exactly as the theory")
    print("  predicts; and this is also the greatest 2-divisible ideal of S.")


def demo_6_termination() -> None:
    rule("6. Separation as termination of the 'strip all factors of a' loop")
    print("  In Z the loop terminates, and its step count is the adic order:")
    for x in [12, 96, 1024, 3]:
        print(f"    x = {x:>5}:  terminates after {ord_int(2, x)} divisions by 2")
    print()
    print("  In S the same loop does not terminate on elements of X*Q[X]:")
    for p in [X, X.scale(Fraction(7, 3)), const(3) + X]:
        steps, done = strip_twos_in_S(p)
        verdict = f"stopped after {steps} steps" if done else f"still running after {steps} steps"
        print(f"    p = {str(p):<14} -> {verdict}")
    print()
    print("  Non-termination here is not an implementation defect: by the")
    print("  equivalence between separation and heights, NO N-valued height")
    print("  function for 2 can exist on S at all.")


def demo_7_fixed_point() -> None:
    rule("7. The intersection as the greatest a-divisible ideal")
    print("  An ideal I is a-divisible when I ⊆ (a)·I: every element of I is a")
    print("  times another element of I, forever. Over a domain the intersection")
    print("  ⋂_n (a^n) is the greatest such ideal.")
    print()
    print("  In Z at a = 2 the only 2-divisible ideal is 0: (m) ⊆ (2)(m) would give")
    print("  m = 2mk for some integer k, i.e. 2k = 1, impossible unless m = 0.")
    for m in [1, 3, 6, 12]:
        divisible = any(m == 2 * m * k for k in range(-4, 5))
        print(f"    ideal (m) with m = {m:>3}: 2-divisible? {divisible}")
    print("    ideal (0):                  2-divisible? True   (trivially)")
    print()
    print("  In S, the ideal X*Q[X] IS 2-divisible: for every p with p(0) = 0 we")
    print("  have p = 2 * (p/2) with p/2 again in X*Q[X]. Check on samples:")
    for p in [X, X.shift(2), X.scale(Fraction(5, 7))]:
        half = p.scale(Fraction(1, 2))
        print(f"    p = {str(p):<14} -> p/2 = {str(half):<16} in S and in X*Q[X]: "
              f"{in_S(half) and half.coeff(0) == 0}")


def demo_8_non_noetherian() -> None:
    rule("8. Beyond Noetherian: separation from unique factorization alone")
    print("  The polynomial ring Q[X_0, X_1, X_2, ...] in countably many variables")
    print("  is NOT Noetherian: the ideal generated by all variables is not finitely")
    print("  generated, since any finite generating set mentions only finitely many")
    print("  variables and misses the rest.")
    print()
    print("  Simulation of that obstruction: given a finite candidate generating")
    print("  set using variables from a finite set V, pick the first index outside V.")
    for gens_vars in [{0, 1, 2}, {0, 3, 4, 9}, set(range(6))]:
        missing = min(i for i in range(100) if i not in gens_vars)
        print(f"    generators use variables {sorted(gens_vars)} -> X_{missing} is missed")
    print()
    print("  Nevertheless the ring is a unique factorization domain, so divisibility")
    print("  chains are well founded, so every non-unit has separated filtration.")
    print("  In particular ⋂_n (X_0^n) = 0 and ||X_0|| = 1/2, exactly as in Q[X]:")
    for k in [0, 1, 2, 5]:
        p = X.shift(k - 1) if k >= 1 else const(1)
        order = ord_poly_X(p)
        print(f"    element X^{k:<2}: X-adic order {order}, absolute value "
              f"{adic_abs_from_ord(order)}")


def main() -> None:
    print(__doc__)
    demo_1_height_criterion()
    demo_2_adic_order()
    demo_3_absolute_value()
    demo_4_minimality()
    demo_5_counterexample()
    demo_6_termination()
    demo_7_fixed_point()
    demo_8_non_noetherian()
    rule("Summary")
    print("  Separation of the principal filtration at a is equivalent, over a")
    print("  domain, to each of the following:")
    print("    * every nonzero element has finite a-multiplicity;")
    print("    * there is an N-valued height v with v(x) < v(ax) for x != 0;")
    print("    * the only ideal I with I ⊆ (a)I is the zero ideal;")
    print("    * the a-adic topology is Hausdorff;")
    print("    * the map into the a-adic completion is injective.")
    print("  Chain conditions (Noetherian, unique factorization) are sufficient but")
    print("  not necessary; Z + X*Q[X] at a = 2 is the boundary case where all of")
    print("  the above fail simultaneously.")


if __name__ == "__main__":
    main()
