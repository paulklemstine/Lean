import json, pathlib

base = pathlib.Path(__file__).parent

def rd(name):
    return (base / name).read_text()

article = rd("ARTICLE.md")
paper = rd("RESEARCH_PAPER.md")
paper_tex = rd("RESEARCH_PAPER.tex")
demo = rd("demo.py")
viz = rd("viz.py")
interactive = rd("interactive.html")
lean = rd("lean_source.txt")

algo_point_count = '''from fractions import Fraction
from typing import Tuple

Mat = Tuple[Fraction, Fraction, Fraction, Fraction]  # [[a,b],[c,d]]
A: Mat = (Fraction(1), Fraction(1), Fraction(1), Fraction(1))
I2: Mat = (Fraction(1), Fraction(0), Fraction(0), Fraction(1))


def mat_mul(M: Mat, N: Mat) -> Mat:
    a, b, c, d = M
    e, f, g, h = N
    return (a*e + b*g, a*f + b*h, c*e + d*g, c*f + d*h)


def trace(M: Mat) -> Fraction:
    a, _b, _c, d = M
    return a + d


def point_count_naive(r: int) -> Fraction:
    """O(r) matrix powers: trace(A**r) by repeated multiplication."""
    P: Mat = I2
    for _ in range(r):
        P = mat_mul(P, A)
    return trace(P)


def point_count_closed(r: int) -> int:
    """O(log r) closed form from the theorems:
       trace(A**0) = 2 (boundary anomaly); trace(A**r) = 2**r for r >= 1."""
    if r == 0:
        return 2          # trace(I2) = 2  != 2**0 = 1
    return 1 << r         # 2**r via bit shift
'''

algo_zeta = '''import math
from fractions import Fraction


def point_count(r: int) -> int:
    return 2 if r == 0 else (1 << r)


def zeta_closed_form(t: Fraction) -> Fraction:
    """Exact value Z(t) = 1/(1-2t) (valid identity for |t| < 1/2)."""
    return Fraction(1) / (Fraction(1) - 2 * t)


def zeta_series(t: float, terms: int) -> float:
    """Truncated defining series exp(sum_{r=1..terms} N_r t^r / r).
       Converges to 1/(1-2t) at geometric rate |2t|**terms for |t| < 1/2."""
    s = 0.0
    for r in range(1, terms + 1):
        s += point_count(r) * (t ** r) / r
    return math.exp(s)


def zeta_with_tolerance(t: float, tol: float = 1e-12) -> float:
    """Adaptive zeta evaluation: add terms until successive partial sums of the
       exponent change by less than `tol`. Requires |t| < 1/2 to converge."""
    if abs(t) >= 0.5:
        raise ValueError("series diverges for |t| >= 1/2")
    s, prev, r = 0.0, None, 1
    while prev is None or abs(s - prev) > tol:
        prev = s
        s += point_count(r) * (t ** r) / r
        r += 1
    return math.exp(s)
'''

pkg = {
    "title": "The Character Class Contradiction: A Rank-One Zeta Computation",
    "domain": "Novelty",
    "description": (
        "A complete, formally verified zeta-function computation for the rank-one "
        "all-ones matrix A = [[1,1],[1,1]], proving trace(A^r) = 2^r and "
        "Z(t) = 1/(1-2t), and refuting the naive expectation that a degenerate "
        "matrix has vanishing higher point counts (trace(A^2) = 4 != 0)."
    ),
    "authors": ["Aristotle"],
    "date": "2026-06-27",
    "key_results": [
        "A_mul_A_eq_two_mul_A: the rank-one matrix satisfies A * A = 2 * A",
        "A_pow_succ: every power is a scalar multiple, A^(n+1) = 2^n * A",
        "trace_pow_two_shift: trace(A^r) = 2^r for r >= 1",
        "det_one_sub_t_mul_A: the spectral determinant det(I - t*A) = 1 - 2t",
        "zeta_function: Z(t) = exp(sum N_r t^r / r) = 1/(1-2t) for |t| < 1/2",
        "naive_expectation_false: it is false that trace(A^r) = 0 for all r != 1, since trace(A^2) = 4",
    ],
    "keywords": [
        "zeta function", "rank-one matrix", "trace", "spectral determinant",
        "subshift of finite type", "Bowen-Lanford", "Cuntz-Krieger", "eigenvalue",
    ],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "Exact Rational Verification of the Rank-One Zeta Identities",
            "description": (
                "A self-contained standard-library demo that represents A as a tuple of "
                "Fractions and verifies, with exact arithmetic, every theorem in the "
                "package: the quadratic relation A@A = 2A, the closed-form powers "
                "A^(n+1) = 2^n A, the trace law trace(A^r) = 2^r for r >= 1 together with "
                "the r=0 boundary anomaly (trace = 2 != 1), the spectral determinant "
                "det(I - tA) = 1 - 2t, the agreement of the truncated zeta series with the "
                "closed form 1/(1-2t) inside |t| < 1/2 (and its divergence outside), and the "
                "contradiction witness trace(A^2) = 4 != 0."
            ),
            "code": demo,
        }
    ],
    "algorithms": [
        {
            "name": "Closed-Form Point Counting via the Power Law trace(A^r) = 2^r",
            "description": (
                "Computes the period counts N_r = trace(A^r). The naive route forms A^r by r "
                "matrix multiplications (O(r) matrix products). The proven identities collapse "
                "this to a single exponentiation: trace(A^r) = 2^r for r >= 1, computable in "
                "O(log r) bit operations by repeated squaring (here a bit shift), with the "
                "r=0 case handled separately as trace(I2) = 2 (the boundary anomaly, since "
                "2^0 = 1). Both routes are provided so the closed form can be checked against "
                "the definition."
            ),
            "pseudocode": (
                "function POINT_COUNT(r):\n"
                "    if r == 0:\n"
                "        return 2            # trace(I2) = 2, not 2^0 = 1\n"
                "    return 2 ** r           # trace_pow_two_shift\n"
                "\n"
                "function POINT_COUNT_NAIVE(r):\n"
                "    P <- I2\n"
                "    repeat r times: P <- P * A\n"
                "    return trace(P)         # equals POINT_COUNT(r) by the theorem"
            ),
            "code": algo_point_count,
        },
        {
            "name": "Zeta Evaluation via the Spectral Determinant and Series Equivalence",
            "description": (
                "Evaluates the zeta function Z(t) = exp(sum_{r>=1} N_r t^r / r). The "
                "exponential-of-traces series converges only on the disc |t| < 1/2 (radius set "
                "by the dominant eigenvalue 2), where it equals the closed form 1/(1-2t) = "
                "1/det(I - tA), the Bowen-Lanford reciprocal. The closed form is O(1); a "
                "truncated series of R terms approximates the exponent with geometric error "
                "|2t|^R, and an adaptive variant adds terms until the partial sums stabilize. "
                "Outside the disc the series diverges and the routine reports this rather than "
                "returning the analytic continuation."
            ),
            "pseudocode": (
                "function ZETA_CLOSED(t):\n"
                "    require |t| < 1/2\n"
                "    return 1 / (1 - 2*t)                 # = 1/det(I - tA)\n"
                "\n"
                "function ZETA_SERIES(t, R):\n"
                "    require |t| < 1/2\n"
                "    s <- 0\n"
                "    for r in 1..R:\n"
                "        s <- s + POINT_COUNT(r) * t^r / r\n"
                "    return exp(s)                        # -> 1/(1-2t) as R -> infinity"
            ),
            "code": algo_zeta,
        },
    ],
    "visualizations": [
        {
            "name": "Point-Count Tower and the Zeta Pole",
            "description": (
                "A two-panel matplotlib figure. The left panel plots the point counts "
                "N_r = trace(A^r) = 2^r on a log scale, highlighting the r=0 boundary anomaly "
                "(trace = 2, not 1) in red against the geometric tower. The right panel plots "
                "the zeta function Z(t) = 1/(1-2t) on (-1/2, 1/2) with its single pole at "
                "t = 1/2 marked, overlaid with truncated-series approximations (2, 5, 20 terms) "
                "converging to it inside the disc of convergence."
            ),
            "code": viz,
        }
    ],
    "interactive_demos": [
        {
            "title": "Interactive Zeta Explorer for the Rank-One Matrix",
            "description": (
                "A self-contained HTML/JavaScript widget (MathJax-rendered) for exploring the "
                "Character Class Contradiction. Sliders control the zeta variable t and the "
                "series truncation R; the widget live-updates the closed-form value "
                "Z(t) = 1/(1-2t), the spectral determinant 1 - 2t, the truncated series (with a "
                "'diverges' indicator outside |t| < 1/2), a canvas plot of Z(t) with its pole at "
                "t = 1/2, a table of trace(A^r) versus 2^r flagging the r=0 anomaly, and a panel "
                "stating the contradiction trace(A^2) = 4 != 0."
            ),
            "html": interactive,
        }
    ],
    "lean_proofs": lean,
    "future_directions": (
        "# Future Directions \u2014 Character Class Contradiction\n\n"
        "Derived from the two cycles in `CharacterClassContradiction.lean` and "
        "`CuntzKriegerFullShiftFamily.lean`, which proved: for the full shift on `n` symbols "
        "(`= \U0001d4aa\u2099` Cuntz\u2013Krieger matrix `J n`), the point count is "
        "`tr((J n)^r) = n^r` (`r \u2265 1`), the zeta reciprocal is `det(1 - t\u00b7J n) = 1 - n\u00b7t`, "
        "and `det(1 - J n) = 1 - n` (so `|K\u2080(\U0001d4aa\u2099)| = n - 1`, with "
        "`K\u2080(\U0001d4aa\u2082) = 0` an exact `Subsingleton` cokernel).\n\n"
        "## Conjecture 1 \u2014 Primitive zeta factorization for general 0\u20131 matrices\n"
        "For an irreducible `0\u20131` matrix `A` (a general subshift of finite type, not just the "
        "full shift), the Bowen\u2013Lanford zeta reciprocal `det(1 - t\u00b7A)` factors over `\u2124[t]` "
        "into cyclotomic-free \"primitive\" pieces whose constant terms multiply to "
        "`\u00b1 det(1 - A) = \u00b1 |K\u2080(\U0001d4aa_A)|`.\n"
        "- **The key insight is** that the same matrix simultaneously controls dynamics "
        "(`tr(A^r)`), the zeta numerator (`det(1 - tA)`), and the C*-algebra invariant "
        "(`coker(1 - A\u1d40)`), so a factorization of the zeta polynomial should be *visible* as a "
        "direct-sum decomposition of `K\u2080`.\n"
        "- **Why now?** We already have the full-shift base case (`det(1 - tJ) = 1 - nt`, "
        "`K\u2080 = \u2124/(n-1)`) fully formalized; extending `J_sq`-style power identities to block / "
        "companion forms is the next mechanical step.\n\n"
        "## Conjecture 2 \u2014 Eigenvalue dichotomy = ordinary/supersingular shadow\n"
        "For any `2\u00d72` integer \"Frobenius\" `A` with `det A \u2265 0`, the period counts `tr(A^r)` "
        "are eventually positive **iff** the dominant eigenvalue is real and `> 1`; the boundary "
        "case (repeated eigenvalue) is the formal trace of \"supersingular\" behaviour, mirroring "
        "`DeligneBoundGL2`.\n"
        "- **The key insight is** that `A_sq : A\u00b7A = 2\u00b7A` forces eigenvalues `{0, 2}` \u2014 a "
        "maximally degenerate (rank-one) Frobenius \u2014 which is the cleanest instance of the "
        "ordinary/supersingular split already seen in the GL\u2082 Deligne-bound file.\n"
        "- **Why now?** The catalog has both the GL\u2082 Weil-number machinery (`DeligneBoundGL2`) "
        "and now the `F\u2081` full-shift counts; merging them tests whether the \u221ap circle and the "
        "`n`-eigenvalue ray are two limits of one inequality.\n\n"
        "## Conjecture 3 \u2014 `K\u2080(\U0001d4aa_A) = 0 \u21d4 1 - A\u1d40 unimodular \u21d4 flow-equivalence to "
        "\U0001d4aa\u2082`\n"
        "For an irreducible non-permutation `0\u20131` matrix `A`, the Cuntz\u2013Krieger algebra is "
        "`\U0001d4aa\u2082`-like (`K\u2080 = 0`) **iff** `det(1 - A) = \u00b11`, and this is detected purely by "
        "the integer linear algebra of `1 - A\u1d40` being a unit in `GL\u2099(\u2124)`.\n"
        "- **The key insight is** that we already reduced `K\u2080(\U0001d4aa\u2082) = 0` to `IsUnit (1 - A)` "
        "via `det = -1`; the converse direction (unimodular \u21d2 trivial cokernel) is a "
        "Smith-normal-form statement provable in Lean for fixed `n`.\n"
        "- **Why now?** The `Subsingleton`-cokernel proof technique (`mulVecLin` surjective from "
        "a unit matrix) is already in hand and generalizes verbatim to any unimodular "
        "`1 - A\u1d40`.\n\n"
        "## Conjecture 4 \u2014 The `F_{1^r}` count is multiplicative over shift products\n"
        "For full shifts on `m` and `n` symbols, the product subshift (Kronecker product "
        "`J m \u2297 J n`) has point count `(mn)^r`, and its zeta reciprocal should factor "
        "compatibly, expressing multiplicativity of the construction under products of "
        "dynamical systems."
    ),
    "modules": {"demo": demo},
    "lean_files": [
        "Catalog/Novelty/CharacterClassContradiction.lean"
    ],
}

out = base / "PACKAGE.json"
out.write_text(json.dumps(pkg, indent=2, ensure_ascii=False))
print("wrote", out, len(json.dumps(pkg)))


"""
demo.py — The Character Class Contradiction
============================================

Numerical demonstration of the rank-one zeta computation for the all-ones matrix

    A = [[1, 1],
         [1, 1]]   over the rationals.

We verify, with exact arithmetic where possible:

  * A @ A == 2 * A                          (A_mul_A_eq_two_mul_A)
  * A**(n+1) == 2**n * A                    (A_pow_succ)
  * trace(A) == 2                           (trace_A)
  * trace(A**r) == 2**r  for r >= 1         (trace_pow_two_shift)
  * trace(A**0) == 2 != 1 == 2**0           (boundary anomaly)
  * det(I - t*A) == 1 - 2*t                 (det_one_sub_t_mul_A)
  * Z(t) := exp(sum_{r>=1} N_r t^r / r) == 1/(1-2t)  for |t| < 1/2   (zeta_function)
  * trace(A**2) == 4 != 0                   (naive_expectation_false)

The script uses only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Tuple

# A 2x2 matrix is represented as a tuple of 4 Fractions: (a, b, c, d) for [[a,b],[c,d]].
Mat = Tuple[Fraction, Fraction, Fraction, Fraction]

A: Mat = (Fraction(1), Fraction(1), Fraction(1), Fraction(1))
I2: Mat = (Fraction(1), Fraction(0), Fraction(0), Fraction(1))


def mat_mul(M: Mat, N: Mat) -> Mat:
    """Multiply two 2x2 matrices with exact rational arithmetic."""
    a, b, c, d = M
    e, f, g, h = N
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def scalar_mul(s: Fraction, M: Mat) -> Mat:
    """Multiply a 2x2 matrix by a scalar."""
    a, b, c, d = M
    return (s * a, s * b, s * c, s * d)


def mat_sub(M: Mat, N: Mat) -> Mat:
    """Subtract two 2x2 matrices."""
    a, b, c, d = M
    e, f, g, h = N
    return (a - e, b - f, c - g, d - h)


def mat_pow(M: Mat, r: int) -> Mat:
    """r-th power of a 2x2 matrix; M**0 is the identity."""
    result: Mat = I2
    for _ in range(r):
        result = mat_mul(result, M)
    return result


def trace(M: Mat) -> Fraction:
    """Trace (sum of diagonal entries) of a 2x2 matrix."""
    a, _b, _c, d = M
    return a + d


def det(M: Mat) -> Fraction:
    """Determinant of a 2x2 matrix."""
    a, b, c, d = M
    return a * d - b * c


def point_count(r: int) -> int:
    """N_r = trace(A**r), via the proven closed form (with the r=0 anomaly)."""
    if r == 0:
        return 2  # trace(I2) = 2, NOT 2**0 = 1
    return 2 ** r


def zeta_closed_form(t: Fraction) -> Fraction:
    """Z(t) = 1 / (1 - 2t)  (requires |t| < 1/2 for the series identity)."""
    return Fraction(1) / (Fraction(1) - 2 * t)


def zeta_partial_series(t: float, terms: int) -> float:
    """Truncated defining series exp(sum_{r=1..terms} N_r t^r / r)."""
    s = 0.0
    for r in range(1, terms + 1):
        s += point_count(r) * (t ** r) / r
    return math.exp(s)


def demo_quadratic_relation() -> None:
    print("== A @ A == 2 * A ==")
    lhs = mat_mul(A, A)
    rhs = scalar_mul(Fraction(2), A)
    print(f"  A@A = {lhs}")
    print(f"  2*A = {rhs}")
    assert lhs == rhs
    print("  OK\n")


def demo_powers() -> None:
    print("== A**(n+1) == 2**n * A ==")
    for n in range(0, 6):
        lhs = mat_pow(A, n + 1)
        rhs = scalar_mul(Fraction(2 ** n), A)
        assert lhs == rhs
        print(f"  n={n}: A**{n+1} = {lhs} == 2**{n} * A")
    print("  OK\n")


def demo_traces() -> None:
    print("== trace(A**r) vs 2**r ==")
    print(f"  {'r':>2} {'trace(A^r)':>12} {'2^r':>8}  agree?")
    for r in range(0, 6):
        tr = trace(mat_pow(A, r))
        pw = 2 ** r
        agree = "yes" if tr == pw else "NO (boundary)"
        assert tr == point_count(r)
        if r >= 1:
            assert tr == pw
        print(f"  {r:>2} {str(tr):>12} {pw:>8}  {agree}")
    print(f"  trace(A) = {trace(A)} (== 2)")
    print("  OK\n")


def demo_determinant() -> None:
    print("== det(I - t*A) == 1 - 2t ==")
    for t in [Fraction(0), Fraction(1, 10), Fraction(1, 4), Fraction(-1, 3)]:
        M = mat_sub(I2, scalar_mul(t, A))
        d = det(M)
        expected = Fraction(1) - 2 * t
        assert d == expected
        print(f"  t={str(t):>6}: det(I - tA) = {d} == 1 - 2t")
    print("  OK\n")


def demo_zeta() -> None:
    print("== Z(t) = exp(sum N_r t^r / r) == 1/(1-2t), |t| < 1/2 ==")
    for t in [0.0, 0.1, 0.25, -0.3, 0.45]:
        closed = float(zeta_closed_form(Fraction(t).limit_denominator()))
        series = zeta_partial_series(t, terms=200)
        print(f"  t={t:>6}: closed={closed:.10f}  series(200)={series:.10f}  "
              f"|diff|={abs(closed-series):.2e}")
        assert abs(closed - series) < 1e-6
    print("  -- outside the disc the series diverges (no identity):")
    t = 0.6
    s = sum(point_count(r) * (t ** r) / r for r in range(1, 41))
    print(f"  t={t}: log-sum over 40 terms = {s:.3e} and grows without bound, so")
    print(f"          exp(series) overflows; the identity 1/(1-2t) = "
          f"{float(zeta_closed_form(Fraction(t).limit_denominator())):.3f} "
          f"does NOT come from the series here.")
    print("  OK\n")


def demo_contradiction() -> None:
    print("== naive_expectation_false: trace(A**2) = 4 != 0 ==")
    tr2 = trace(mat_pow(A, 2))
    print(f"  trace(A**2) = {tr2}")
    assert tr2 == 4 and tr2 != 0
    print("  The expectation 'trace(A^r) = 0 for all r != 1' is FALSE.\n")


def main() -> None:
    print("The Character Class Contradiction — numerical demo")
    print("=" * 52, "\n")
    demo_quadratic_relation()
    demo_powers()
    demo_traces()
    demo_determinant()
    demo_zeta()
    demo_contradiction()
    print("All checks passed.")


if __name__ == "__main__":
    main()


"""
viz.py — Visualizations for the Character Class Contradiction
=============================================================

Generates two figures:

  1. The point counts N_r = trace(A^r) = 2^r on a log scale, with the r=0
     boundary anomaly (trace = 2, not 2^0 = 1) highlighted in red.
  2. The zeta function Z(t) = 1/(1-2t) on (-1/2, 1/2), with its single pole
     at t = 1/2 marked, alongside truncated-series approximations converging
     to it inside the disc of convergence.

Run:  python viz.py   ->   writes character_class_contradiction.png
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def point_count(r: int) -> int:
    """N_r = trace(A^r): 2 at r=0 (boundary), 2^r for r >= 1."""
    return 2 if r == 0 else 2 ** r


def zeta_closed(t: float) -> float:
    """Z(t) = 1/(1-2t)."""
    return 1.0 / (1.0 - 2.0 * t)


def zeta_series(t: float, terms: int) -> float:
    """Truncated exp(sum_{r=1..terms} 2^r t^r / r)."""
    s = sum(point_count(r) * (t ** r) / r for r in range(1, terms + 1))
    return math.exp(s)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # --- Panel 1: point counts ---
    rs: List[int] = list(range(0, 11))
    counts = [point_count(r) for r in rs]
    pow2 = [2 ** r for r in rs]
    ax1.semilogy(rs[1:], pow2[1:], "o-", color="#1f77b4", label=r"$2^r$ (theorem)")
    ax1.semilogy([0], [counts[0]], "s", color="#d62728", markersize=11,
                 label=r"$\mathrm{trace}(A^0)=2\neq 1$ (anomaly)")
    ax1.semilogy([0], [pow2[0]], "x", color="#999999", markersize=10,
                 label=r"$2^0=1$")
    ax1.set_xlabel("r")
    ax1.set_ylabel(r"$N_r = \mathrm{trace}(A^r)$")
    ax1.set_title("Point counts: an unbounded geometric tower")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    # --- Panel 2: zeta function ---
    ts = np.linspace(-0.49, 0.49, 400)
    zs = [zeta_closed(t) for t in ts]
    ax2.plot(ts, zs, color="#2ca02c", lw=2.5, label=r"$Z(t)=\frac{1}{1-2t}$")
    for k, terms in enumerate([2, 5, 20]):
        approx = [zeta_series(t, terms) for t in ts]
        ax2.plot(ts, approx, "--", lw=1, alpha=0.7,
                 label=f"series, {terms} terms")
    ax2.axvline(0.5, color="#d62728", ls=":", label=r"pole $t=1/2$")
    ax2.set_xlabel("t")
    ax2.set_ylabel("Z(t)")
    ax2.set_ylim(-2, 12)
    ax2.set_title("Zeta function and its truncated series")
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("The Character Class Contradiction: "
                 r"$A=\left(\begin{smallmatrix}1&1\\1&1\end{smallmatrix}\right)$",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("character_class_contradiction.png", dpi=150)
    print("wrote character_class_contradiction.png")


if __name__ == "__main__":
    main()
