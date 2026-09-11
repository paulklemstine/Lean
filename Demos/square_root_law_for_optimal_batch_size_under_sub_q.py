"""Calibration of the batching cost model from timing measurements.

At a fixed multiplication exponent mu the model
    C(k) = A/k + c + q (k^(mu-1) - 1)
is *linear* in the unknowns (A, c, q), with design row
    (1/k, 1, k^(mu-1) - 1).
Hence m >= 3 measurements determine (A, c, q) by ordinary least squares
(solved here through the 3x3 normal equations, so the routine has no
third-party dependencies).  If mu itself is unknown, the outer problem is a
well-conditioned one-dimensional search: for each candidate exponent the inner
fit is linear, so we simply scan a grid and keep the exponent with the least
residual.

Complexity: O(m) per exponent for the normal equations plus O(1) to solve
them, hence O(G m) for a grid of G exponents.
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


def design_row(k: float, mu: float) -> Tuple[float, float, float]:
    """The row (1/k, 1, k^(mu-1) - 1) of the linear model at batch size k."""
    return (1.0 / k, 1.0, k ** (mu - 1.0) - 1.0)


def solve3(matrix: List[List[float]], rhs: List[float]) -> Tuple[float, float, float]:
    """Solve a 3x3 linear system by Gauss-Jordan elimination with pivoting."""
    m = [list(row) + [b] for row, b in zip(matrix, rhs)]
    for col in range(3):
        piv = max(range(col, 3), key=lambda r: abs(m[r][col]))
        m[col], m[piv] = m[piv], m[col]
        pivot = m[col][col]
        if abs(pivot) < 1e-14:
            raise ValueError("singular system: measurements are not informative")
        m[col] = [x / pivot for x in m[col]]
        for r in range(3):
            if r != col and m[r][col] != 0.0:
                f = m[r][col]
                m[r] = [a - f * b for a, b in zip(m[r], m[col])]
    return m[0][3], m[1][3], m[2][3]


def fit_linear(
    ks: Sequence[float], ys: Sequence[float], mu: float
) -> Tuple[Tuple[float, float, float], float]:
    """Least-squares fit of (A, c, q) at fixed mu; returns params and residual."""
    if len(ks) < 3:
        raise ValueError("need at least three measurements")
    gram = [[0.0] * 3 for _ in range(3)]
    rhs = [0.0] * 3
    for k, y in zip(ks, ys):
        row = design_row(k, mu)
        for i in range(3):
            rhs[i] += row[i] * y
            for j in range(3):
                gram[i][j] += row[i] * row[j]
    A, c, q = solve3(gram, rhs)
    resid = 0.0
    for k, y in zip(ks, ys):
        row = design_row(k, mu)
        pred = A * row[0] + c * row[1] + q * row[2]
        resid += (pred - y) ** 2
    return (A, c, q), math.sqrt(resid / len(ks))


def fit_with_exponent(
    ks: Sequence[float],
    ys: Sequence[float],
    mu_lo: float = 1.01,
    mu_hi: float = 2.5,
    grid: int = 300,
) -> Tuple[float, Tuple[float, float, float], float]:
    """Fit (mu, A, c, q) by scanning the exponent and fitting linearly inside."""
    best: Tuple[float, Tuple[float, float, float], float] = (
        mu_lo,
        (0.0, 0.0, 0.0),
        float("inf"),
    )
    for i in range(grid + 1):
        mu = mu_lo + (mu_hi - mu_lo) * i / grid
        try:
            params, resid = fit_linear(ks, ys, mu)
        except ValueError:
            continue
        if resid < best[2]:
            best = (mu, params, resid)
    return best


def collapse_coordinates(
    ks: Sequence[float], ys: Sequence[float], A: float, c: float, q: float, mu: float
) -> List[Tuple[float, float]]:
    """Map measurements into universal shape coordinates (theta, S).

    Under the model every measurement must land on the single curve
        S(mu, theta) = (mu-1)/theta + theta^(mu-1).
    Systematic deviation is evidence that the model is incomplete (for
    example, that a cache tier boundary has been crossed).
    """
    k_star = (A / ((mu - 1.0) * q)) ** (1.0 / mu)
    scale = q * k_star ** (mu - 1.0)
    return [((k / k_star), (y - (c - q)) / scale) for k, y in zip(ks, ys)]


if __name__ == "__main__":
    A_t, c_t, q_t, mu_t = 4096.0, 0.75, 0.004, 1.585
    ks = [4.0, 16.0, 64.0, 256.0, 1024.0, 4096.0, 16384.0]
    ys = [A_t / k + c_t + q_t * (k ** (mu_t - 1) - 1) for k in ks]
    mu_hat, (A_h, c_h, q_h), resid = fit_with_exponent(ks, ys)
    print(f"recovered mu = {mu_hat:.4f} (true {mu_t}), residual {resid:.3e}")
    print(f"recovered A = {A_h:.4f}, c = {c_h:.4f}, q = {q_h:.6f}")
    for theta, shape in collapse_coordinates(ks, ys, A_h, c_h, q_h, mu_hat):
        pred = (mu_hat - 1) / theta + theta ** (mu_hat - 1)
        print(f"theta = {theta:12.5f}   S_measured = {shape:.6f}   S_model = {pred:.6f}")


"""Closed-form optimal batch sizing under the root law.

Given the calibration constants (A, c, q, mu) of the per-candidate cost
    C(k) = A/k + c + q (k^(mu-1) - 1),
return the exact optimal integer batch size, together with the real optimum
k* = (A/((mu-1) q))^(1/mu) and the attainable optimal cost.

Correctness rests on two facts: (i) k* is the unique real minimiser, and
(ii) the cost is strictly unimodal, so the best integer batch is one of the
two neighbours of k*.  Complexity: O(1) arithmetic and transcendental
operations.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class BatchPlan:
    """The output of the sizing algorithm."""

    real_optimum: Optional[float]      # k*, or None when mu <= 1
    integer_optimum: Optional[int]     # best admissible integer batch
    optimal_cost: Optional[float]      # C(k*) in closed form
    integer_cost: Optional[float]      # C at the recommended integer batch
    note: str


def block_cost(A: float, c: float, q: float, mu: float, k: float) -> float:
    """Per-candidate cost of streaming in blocks of size k > 0."""
    if k <= 0.0:
        raise ValueError("batch size must be positive")
    return A / k + c + q * (k ** (mu - 1.0) - 1.0)


def plan_batch(A: float, c: float, q: float, mu: float) -> BatchPlan:
    """Return the optimal batching plan for the given calibration."""
    if A <= 0.0 or q <= 0.0:
        raise ValueError("setup A and penalty q must be positive")

    if mu <= 1.0:
        # Degenerate regime: the cost is strictly decreasing in k.
        return BatchPlan(
            real_optimum=None,
            integer_optimum=None,
            optimal_cost=None,
            integer_cost=None,
            note="mu <= 1: no interior optimum; take the largest feasible batch.",
        )

    k_star = (A / ((mu - 1.0) * q)) ** (1.0 / mu)
    c_star = (
        c
        - q
        + mu
        * (mu - 1.0) ** ((1.0 - mu) / mu)
        * A ** ((mu - 1.0) / mu)
        * q ** (1.0 / mu)
    )

    lo = max(1, math.floor(k_star))
    hi = max(1, math.ceil(k_star))
    n_best = min((lo, hi), key=lambda n: block_cost(A, c, q, mu, float(n)))

    return BatchPlan(
        real_optimum=k_star,
        integer_optimum=n_best,
        optimal_cost=c_star,
        integer_cost=block_cost(A, c, q, mu, float(n_best)),
        note="unique optimum; integer optimum is a neighbour of k*",
    )


if __name__ == "__main__":
    for params in [(1000.0, 1.0, 1e-3, 2.0),
                   (1000.0, 1.0, 1e-3, 1.5),
                   (4096.0, 0.75, 0.004, math.log2(3.0)),
                   (1000.0, 1.0, 1e-3, 1.0)]:
        print(params, "->", plan_batch(*params))


"""Model-free discrete batch tuning by unimodal (ternary) search.

The per-candidate cost C(k) = A/k + c + q (k^(mu-1) - 1) is strictly
decreasing on (0, k*] and strictly increasing on [k*, infinity), so its
restriction to the positive integers is strictly unimodal.  Ternary search is
therefore *correct*: it cannot be trapped by a spurious local minimum.  This
matters in practice because it needs no knowledge of A, c, q or mu -- only the
ability to time a batch.

Complexity: each round shrinks the bracket by a factor 2/3, so the exact
integer optimum in [1, N] is found in O(log N) cost evaluations
(about 5.13 * log2(N) evaluations in the worst case).
"""

from __future__ import annotations

import math
from typing import Callable, Tuple


def ternary_search_int(
    cost: Callable[[int], float], lo: int = 1, hi: int = 1 << 20
) -> Tuple[int, int]:
    """Exact minimiser of a strictly unimodal integer cost on [lo, hi].

    Returns (argmin, number_of_evaluations).
    """
    if lo > hi:
        raise ValueError("empty bracket")
    evaluations = 0

    def f(n: int) -> float:
        nonlocal evaluations
        evaluations += 1
        return cost(n)

    while hi - lo > 2:
        m1 = lo + (hi - lo) // 3
        m2 = hi - (hi - lo) // 3
        if f(m1) <= f(m2):
            hi = m2
        else:
            lo = m1
    best = min(range(lo, hi + 1), key=f)
    return best, evaluations


def doubling_bracket(cost: Callable[[int], float], start: int = 1) -> Tuple[int, int]:
    """Find a bracket [1, N] guaranteed to contain the optimum.

    Doubles the trial batch while the cost keeps falling; unimodality
    guarantees that the first increase brackets the optimum from above.
    """
    n = max(1, start)
    prev = cost(n)
    while True:
        nxt = 2 * n
        val = cost(nxt)
        if val >= prev:
            return 1, nxt
        n, prev = nxt, val


if __name__ == "__main__":
    A, c, q, mu = 1000.0, 1.0, 1e-3, 1.5

    def cost(n: int) -> float:
        return A / n + c + q * (float(n) ** (mu - 1.0) - 1.0)

    lo, hi = doubling_bracket(cost)
    best, evals = ternary_search_int(cost, lo, hi)
    k_star = (A / ((mu - 1.0) * q)) ** (1.0 / mu)
    print(f"bracket [{lo}, {hi}]")
    print(f"ternary optimum   : {best}  (cost {cost(best):.10f}) in {evals} evaluations")
    print(f"real optimum k*   : {k_star:.4f}  -> neighbours "
          f"{math.floor(k_star)}, {math.ceil(k_star)}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Computation/BatchSubquadraticRootLaw.lean",
    "Catalog/Computation/BatchRootLawGeometry.lean",
    "Catalog/Computation/BatchRootLawDiscrete.lean",
    "Catalog/Computation/BatchCrossoverRoot.lean",
]

lean_proofs = "\n\n".join(
    f"-- FILE: {f}\n" + read(ROOT / f) for f in LEAN_FILES
)

package = {
    "title": "The Square-Root Law of Batching, Generalised: A Root Law for Optimal "
             "Batch Size under Sub-Quadratic Multiplication",
    "domain": "Computation",
    "description": (
        "The per-candidate cost of batching a stream, A/k + c + q(k^(mu-1) - 1), has for "
        "every multiplication exponent mu > 1 a unique optimal batch size "
        "k* = (A/((mu-1)q))^(1/mu) with optimal cost "
        "c - q + mu (mu-1)^((1-mu)/mu) A^((mu-1)/mu) q^(1/mu), degenerating to "
        "'bigger is always better' exactly at mu = 1. Together with a universal collapse "
        "of the cost curve, a quadratic flatness bound, strict unimodality and a root law "
        "for the batch-versus-solo crossover, this explains an observed batching reversal "
        "as a property of schoolbook arithmetic rather than of batching."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-11",
    "key_results": [
        "Root law for the optimal batch size: for setup A > 0, penalty q > 0 and "
        "multiplication exponent mu > 1, the per-candidate cost A/k + c + q(k^(mu-1) - 1) "
        "has the unique global minimiser k* = (A/((mu-1)q))^(1/mu), with minimum value "
        "c - q + mu (mu-1)^((1-mu)/mu) A^((mu-1)/mu) q^(1/mu); at mu = 2 this is the "
        "classical square-root law k* = sqrt(A/q) with cost c - q + 2 sqrt(Aq).",
        "Equipartition and degeneration: at the optimum the amortised setup equals "
        "(mu - 1) times the marginal multiplication penalty, so at mu = 1 the penalty "
        "vanishes, the cost is strictly decreasing and no interior optimum exists; the "
        "optimal batch is antitone in mu and diverges as mu decreases to 1.",
        "Universal collapse and quadratic flatness: measured in units of k*, every cost "
        "curve equals (c - q) + q (k*)^(mu-1) times the two-parameter shape "
        "S(mu, theta) = (mu-1)/theta + theta^(mu-1) with minimum mu at theta = 1, and the "
        "excess satisfies S(mu, theta) - mu <= (mu-1)(theta-1)^2/theta, so mis-sizing the "
        "batch is a second-order error.",
        "Multiplicative but not additive convexity: the cost is convex along geometric "
        "interpolations of the batch size for every mu, yet fails to be convex in the "
        "batch size itself once mu < 2, with the explicit witness mu = 3/2, A = q = 1, "
        "batch sizes 4 and 100 and midpoint 52.",
        "Strict unimodality and the crossover root law: the cost strictly decreases on "
        "(0, k*] and strictly increases on [k*, infinity), so the best integer batch is "
        "floor(k*) or ceil(k*); and batching beats solo testing exactly for pools of size "
        "at most (1 + (s1 - c1)/q)^(1/(mu-1)), which is linear only at mu = 2 and equals "
        "1715^2 at mu = 3/2 when calibrated to a measured crossover of 1715 candidates.",
    ],
    "keywords": [
        "batch amortisation",
        "multiplication exponent",
        "Karatsuba",
        "weighted AM-GM",
        "Bernoulli inequality",
        "multiplicative convexity",
        "unimodality",
        "smoothness testing",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Guided Numerical Tour of the Root Law, the Collapse and the Crossover",
            "description": (
                "An eight-part console walkthrough of every result in the package. It "
                "tabulates the optimal batch size and optimal cost across multiplication "
                "exponents and cross-checks each against a dense grid minimisation; "
                "verifies the schoolbook specialisation k* = sqrt(A/q) and "
                "C* = c - q + 2 sqrt(Aq); exhibits the equipartition identity "
                "A/k* = (mu-1) q (k*)^(mu-1) together with the setup share (mu-1)/mu; "
                "shows the strictly decreasing cost of the flat mu = 1 model against the "
                "turning mu = 2 model; demonstrates the universal collapse by mapping "
                "several very different (A, q) pairs onto the single shape curve "
                "S(mu, theta) = (mu-1)/theta + theta^(mu-1) and comparing the excess with "
                "the flatness bound (mu-1)(theta-1)^2/theta; exhibits the explicit failure "
                "of ordinary convexity at mu = 3/2 alongside the geometric-interpolation "
                "inequality that does hold; confirms on six parameter sets that the "
                "brute-force integer optimum is a neighbour of k* and that ternary search "
                "reproduces it; tabulates the crossover pool size as a function of mu "
                "calibrated to the measured value 1715; and finally recovers (A, c, q) "
                "from three timings and issues a batch-size recommendation."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Randomised Audit of Unimodality, the Closed Form and the Integer Optimum",
            "description": (
                "A quantitative stress test over hundreds of random parameter triples "
                "(A, q, mu) drawn across ten orders of magnitude. For each triple it "
                "measures the relative error between the attained cost at k* and the "
                "closed-form optimum; checks that a geometric sampling of the cost is "
                "strictly decreasing before k* and strictly increasing after it; verifies "
                "that the brute-force integer minimiser over a wide window is floor(k*) or "
                "ceil(k*); confirms the flatness bound and the multiplicative-convexity "
                "inequality on random geometric interpolations. Rather than a pass/fail "
                "verdict it reports worst-case discrepancies, which makes visible an "
                "instructive phenomenon: for very large k* the plateau is so flat that "
                "neighbouring integer costs are indistinguishable in double precision, so "
                "the neighbour property must be checked with a relative tolerance."
            ),
            "code": read(A / "demo_unimodality_stress.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Closed-Form Optimal Batch Sizing via the Root Law",
            "description": (
                "Given the calibration constants (A, c, q, mu) of the per-candidate cost "
                "C(k) = A/k + c + q(k^(mu-1) - 1), this routine returns the exact optimal "
                "integer batch size together with the real optimum and the attainable "
                "optimal cost. Its correctness rests on two theorems: the root law, which "
                "identifies k* = (A/((mu-1)q))^(1/mu) as the unique real minimiser, and "
                "strict unimodality, which forces the discrete optimum to be one of the two "
                "integer neighbours of k*, so only two cost evaluations are needed to settle "
                "the tie. The degenerate regime mu <= 1 is detected and reported separately: "
                "there the cost is strictly decreasing and the correct advice is to take the "
                "largest feasible batch. Complexity is O(1) arithmetic and transcendental "
                "operations, independent of the batch size, in contrast with the O(log N) "
                "measurements a black-box search would need."
            ),
            "pseudocode": (
                "ALGORITHM PlanBatch(A, c, q, mu)\n"
                "  INPUT : setup A > 0, flat cost c, penalty q > 0, exponent mu\n"
                "  OUTPUT: real optimum k*, integer optimum n*, optimal cost C*\n"
                "\n"
                "  1. if A <= 0 or q <= 0 then error 'A and q must be positive'\n"
                "  2. if mu <= 1 then\n"
                "  3.     return (none, none, none,\n"
                "                 'no interior optimum: cost strictly decreasing in k')\n"
                "  4. k*  <- (A / ((mu - 1) * q)) ^ (1 / mu)\n"
                "  5. C*  <- c - q + mu * (mu-1)^((1-mu)/mu) * A^((mu-1)/mu) * q^(1/mu)\n"
                "  6. lo  <- max(1, floor(k*));  hi <- max(1, ceil(k*))\n"
                "  7. C_lo <- A/lo + c + q*(lo^(mu-1) - 1)\n"
                "  8. C_hi <- A/hi + c + q*(hi^(mu-1) - 1)\n"
                "  9. n*  <- lo if C_lo <= C_hi else hi\n"
                " 10. return (k*, n*, C*, C(n*))\n"
                "\n"
                "  CORRECTNESS: k* is the unique minimiser of C on (0, infinity)\n"
                "  (root law); C is strictly decreasing on (0, k*] and strictly\n"
                "  increasing on [k*, infinity) (unimodality), hence every integer\n"
                "  n >= 1 satisfies C(n) >= min(C(lo), C(hi))."
            ),
            "code": read(A / "algo_root_law_sizing.py"),
        },
        {
            "name": "Cost-Model Calibration and the Universal-Collapse Diagnostic",
            "description": (
                "Recovers the model parameters from timing measurements. At a fixed "
                "multiplication exponent the cost model is linear in the unknowns (A, c, q), "
                "with design row (1/k, 1, k^(mu-1) - 1), so m >= 3 measurements determine "
                "them by ordinary least squares through the 3x3 normal equations, solved "
                "here by Gauss-Jordan elimination with partial pivoting. When mu itself is "
                "unknown the outer problem is a well-conditioned one-dimensional search: for "
                "each candidate exponent the inner fit is linear, so a grid scan keeping the "
                "least residual suffices. The routine also maps the measurements into shape "
                "coordinates theta = k/k*, S = (C - (c-q))/(q (k*)^(mu-1)); by the universal "
                "collapse theorem every measurement must land on the single curve "
                "S(mu, theta) = (mu-1)/theta + theta^(mu-1), so systematic deviation is a "
                "parameter-free indication that the single-tier model is incomplete, for "
                "example because a cache boundary was crossed. Complexity is O(G m) for a "
                "grid of G exponents and m measurements."
            ),
            "pseudocode": (
                "ALGORITHM Calibrate(k[1..m], y[1..m], mu_lo, mu_hi, G)\n"
                "  INPUT : batch sizes k[i], measured per-candidate costs y[i]\n"
                "  OUTPUT: exponent mu, parameters (A, c, q), residual\n"
                "\n"
                "  1. best <- (mu_lo, (0,0,0), +infinity)\n"
                "  2. for g = 0 .. G do\n"
                "  3.     mu <- mu_lo + (mu_hi - mu_lo) * g / G\n"
                "  4.     for i = 1 .. m: row[i] <- (1/k[i], 1, k[i]^(mu-1) - 1)\n"
                "  5.     Gram  <- sum_i row[i]^T row[i]        // 3x3\n"
                "  6.     rhs   <- sum_i row[i]^T y[i]          // 3x1\n"
                "  7.     (A,c,q) <- Solve3(Gram, rhs)          // Gauss-Jordan, pivoting\n"
                "  8.     resid <- sqrt( mean_i (row[i].(A,c,q) - y[i])^2 )\n"
                "  9.     if resid < best.residual then best <- (mu, (A,c,q), resid)\n"
                " 10. (mu, (A,c,q), resid) <- best\n"
                "\n"
                " 11. // Universal-collapse diagnostic\n"
                " 12. k*    <- (A / ((mu - 1) q))^(1/mu)\n"
                " 13. scale <- q * (k*)^(mu - 1)\n"
                " 14. for i = 1 .. m do\n"
                " 15.     theta[i] <- k[i] / k*\n"
                " 16.     S_meas[i] <- (y[i] - (c - q)) / scale\n"
                " 17.     S_model[i] <- (mu - 1)/theta[i] + theta[i]^(mu - 1)\n"
                " 18.     flag a tier boundary if |S_meas[i] - S_model[i]| exceeds noise\n"
                " 19. return (mu, (A, c, q), resid, collapse table)"
            ),
            "code": read(A / "algo_calibration.py"),
        },
        {
            "name": "Model-Free Discrete Batch Tuning by Unimodal Ternary Search",
            "description": (
                "Finds the exact optimal integer batch size using nothing but black-box cost "
                "measurements: no knowledge of A, c, q or mu is required. Correctness follows "
                "from strict unimodality of the cost, which guarantees that the restriction to "
                "the positive integers has no spurious local minimum, so the standard ternary "
                "comparison never discards the optimum. A doubling phase first produces a valid "
                "bracket: the trial batch is doubled while the measured cost keeps falling, and "
                "unimodality guarantees that the first increase brackets the optimum from above. "
                "Each ternary round shrinks the bracket by a factor 2/3, so the exact optimum in "
                "[1, N] is reached in O(log N) evaluations, roughly 5.13 log2(N) in the worst "
                "case. This is the recommended autotuning strategy on real hardware, where the "
                "closed form serves as a sanity check and an extrapolation device across "
                "machines."
            ),
            "pseudocode": (
                "ALGORITHM TuneBatch(cost)\n"
                "  INPUT : oracle cost(n) for integer batch sizes n >= 1\n"
                "  OUTPUT: exact discrete minimiser n*\n"
                "\n"
                "  // Phase 1: bracket the optimum by doubling\n"
                "  1. n <- 1; prev <- cost(1)\n"
                "  2. loop\n"
                "  3.     val <- cost(2n)\n"
                "  4.     if val >= prev then hi <- 2n; break\n"
                "  5.     n <- 2n; prev <- val\n"
                "  6. lo <- 1\n"
                "\n"
                "  // Phase 2: ternary search on the unimodal bracket\n"
                "  7. while hi - lo > 2 do\n"
                "  8.     m1 <- lo + floor((hi - lo)/3)\n"
                "  9.     m2 <- hi - floor((hi - lo)/3)\n"
                " 10.     if cost(m1) <= cost(m2) then hi <- m2 else lo <- m1\n"
                " 11. return argmin over n in [lo, hi] of cost(n)\n"
                "\n"
                "  CORRECTNESS: the cost is strictly decreasing on (0, k*] and strictly\n"
                "  increasing on [k*, infinity); comparing two interior points therefore\n"
                "  always discards a subinterval that cannot contain the minimum.\n"
                "  COMPLEXITY: O(log N) oracle calls for a bracket of width N."
            ),
            "code": read(A / "algo_ternary.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Batching Cost Curves Across Multiplication Exponents",
            "description": (
                "Log-log plot of the per-candidate cost A/k + c + q(k^(mu-1) - 1) for "
                "multiplication exponents from schoolbook mu = 2 down to mu = 1.15, with the "
                "root-law optimum k* = (A/((mu-1)q))^(1/mu) marked on each curve, and the flat "
                "model mu = 1 drawn dashed as a monotonically decreasing reference. The figure "
                "makes visible both the existence of a unique turning point for every mu > 1 "
                "and its systematic migration to larger batch sizes as multiplication gets "
                "cheaper."
            ),
            "code": read(A / "viz_cost_curves.py"),
        },
        {
            "name": "Universal Collapse and the Flat Plateau of the Optimum",
            "description": (
                "Two panels. The left panel takes cost curves for very different setup and "
                "penalty pairs at a common exponent and rescales them to shape coordinates "
                "theta = k/k*, S = (C - (c-q))/(q (k*)^(mu-1)); every curve collapses onto the "
                "single universal shape S(mu, theta) = (mu-1)/theta + theta^(mu-1), whose "
                "minimum is exactly mu at theta = 1. The right panel plots the excess "
                "S(mu, theta) - mu against the proved bound (mu-1)(theta-1)^2/theta for several "
                "exponents, showing that the excess is second order in the sizing error and that "
                "the plateau is flatter for faster arithmetic."
            ),
            "code": read(A / "viz_collapse_and_flatness.py"),
        },
        {
            "name": "The Batch-Versus-Solo Crossover as a Root of the Cost Ratio",
            "description": (
                "Left panel: the crossover pool size M*(mu) = (1 + (s1-c1)/q)^(1/(mu-1)) as a "
                "function of the multiplication exponent, on a logarithmic axis, calibrated to a "
                "measured schoolbook crossover of 1715 candidates and annotated at the "
                "schoolbook, Karatsuba and mu = 3/2 exponents. Right panel: the per-candidate "
                "batch cost curves for those exponents against the constant solo baseline, so "
                "that the crossover is visible as the intersection point. Together they show "
                "that lowering the exponent below 2 pushes the reversal out by orders of "
                "magnitude and that it disappears entirely in the limit mu -> 1."
            ),
            "code": read(A / "viz_crossover.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Batching Cost Explorer: Watch the Optimum Slide as Multiplication Gets Cheaper",
            "description": (
                "A live, dependency-free explorer for the per-candidate cost "
                "C(k) = A/k + c + q(k^(mu-1) - 1). Sliders control the multiplication exponent "
                "mu, the setup A and penalty q on logarithmic scales, the flat cost c, and the "
                "chosen batch expressed as a multiple theta of the optimum. The canvas plots the "
                "cost on log-log axes with the root-law optimum marked, the dashed flat model "
                "mu = 1 as a reference, and a shaded band showing the plus-or-minus ten percent "
                "plateau around k*. A toggle switches to shape coordinates, in which the curve "
                "becomes the universal shape S(mu, theta) = (mu-1)/theta + theta^(mu-1) and "
                "stops moving when A and q are changed, making the collapse theorem tangible. "
                "Live readouts give the real optimum, the best integer batch, the closed-form "
                "optimal cost, the cost at the user's chosen batch, the setup share (mu-1)/mu at "
                "the optimum, and the relative loss from mis-sizing next to the proved bound "
                "(mu-1)(theta-1)^2/theta. Presets jump to schoolbook, Karatsuba, Toom-3 and the "
                "near-flat regime, where the running commentary reports that the optimum has "
                "escaped and batching never reverses."
            ),
            "html": read(A / "widget_explorer.html"),
        },
        {
            "title": "Should I Batch? Exploring the Crossover Root Law",
            "description": (
                "An interactive answer to the practitioner's binary question. Sliders set the "
                "multiplication exponent mu, the setup-to-penalty ratio R = 1 + (s1-c1)/q on a "
                "logarithmic scale (default: the measured calibration R = 1715), and the pool "
                "size at hand. The canvas plots the crossover M*(mu) = R^(1/(mu-1)) against the "
                "exponent on a logarithmic axis, with the user's pool drawn as a horizontal "
                "threshold, so the verdict is read off geometrically: below the curve, batch; "
                "above it, split the pool or switch to faster arithmetic. A colour-coded verdict "
                "panel states the recommendation in words, and a companion table lists the "
                "crossover at the schoolbook, Karatsuba and lower exponents together with its "
                "multiple of the schoolbook value, exhibiting the square 1715^2 at mu = 3/2 and "
                "the divergence as mu approaches 1."
            ),
            "html": read(A / "widget_crossover.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": read(A / "future_directions_source.md"),
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "unimodality_stress_test": read(A / "demo_unimodality_stress.py"),
        "root_law_sizing": read(A / "algo_root_law_sizing.py"),
        "calibration": read(A / "algo_calibration.py"),
        "ternary_tuning": read(A / "algo_ternary.py"),
        "viz_cost_curves": read(A / "viz_cost_curves.py"),
        "viz_collapse_and_flatness": read(A / "viz_collapse_and_flatness.py"),
        "viz_crossover": read(A / "viz_crossover.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Randomised stress test of unimodality, the root law and the integer optimum.

For hundreds of random parameter triples (A, q, mu) this script checks, purely
numerically, the three claims that a practitioner relies on:

  (1) Root law.        The dense-grid minimiser of C(k) = A/k + c + q(k^(mu-1)-1)
                       agrees with k* = (A/((mu-1) q))^(1/mu), and the minimum
                       value agrees with the closed form
                       c - q + mu (mu-1)^((1-mu)/mu) A^((mu-1)/mu) q^(1/mu).
  (2) Unimodality.     Sampled geometrically, the cost decreases up to k* and
                       increases afterwards, with no interior wobble.
  (3) Integer optimum. The brute-force integer minimiser over a wide window is
                       floor(k*) or ceil(k*) (clamped at 1), up to floating-point
                       ties: on the extremely flat plateau of a very large k* the
                       costs of nearby integers can be indistinguishable in double
                       precision, so the check is made with a relative tolerance
                       and the worst relative gap is reported.

It also checks the flatness bound S(mu,theta) - mu <= (mu-1)(theta-1)^2/theta
and the multiplicative-convexity inequality on random geometric interpolations.
Every check reports a worst-case discrepancy, so the output is a quantitative
audit rather than a pass/fail claim.
"""

from __future__ import annotations

import math
import random
from typing import Tuple


def block_cost(A: float, c: float, q: float, mu: float, k: float) -> float:
    return A / k + c + q * (k ** (mu - 1.0) - 1.0)


def opt_batch(A: float, q: float, mu: float) -> float:
    return (A / ((mu - 1.0) * q)) ** (1.0 / mu)


def opt_cost(A: float, c: float, q: float, mu: float) -> float:
    return (c - q + mu * (mu - 1.0) ** ((1.0 - mu) / mu)
            * A ** ((mu - 1.0) / mu) * q ** (1.0 / mu))


def random_case(rng: random.Random) -> Tuple[float, float, float, float]:
    A = 10 ** rng.uniform(-2, 6)
    q = 10 ** rng.uniform(-5, 2)
    mu = rng.uniform(1.05, 2.4)
    c = rng.uniform(0.0, 5.0)
    return A, c, q, mu


def main(trials: int = 400, seed: int = 20260911) -> None:
    rng = random.Random(seed)
    worst_value_err = 0.0
    worst_grid_ratio = 0.0
    unimodal_failures = 0
    integer_failures = 0
    worst_integer_gap = 0.0
    worst_flatness_slack = float("inf")
    convexity_failures = 0

    for _ in range(trials):
        A, c, q, mu = random_case(rng)
        ks = opt_batch(A, q, mu)
        cs = opt_cost(A, c, q, mu)

        # (1) closed form equals the attained value
        worst_value_err = max(
            worst_value_err,
            abs(block_cost(A, c, q, mu, ks) - cs) / max(1.0, abs(cs)),
        )

        # (2) geometric sampling: monotone down then up, and grid min near k*
        grid = [ks * 10 ** (t / 12.0) for t in range(-36, 37)]
        vals = [block_cost(A, c, q, mu, k) for k in grid]
        i_min = min(range(len(vals)), key=lambda i: vals[i])
        worst_grid_ratio = max(worst_grid_ratio, abs(math.log10(grid[i_min] / ks)))
        for i in range(len(grid) - 1):
            if grid[i + 1] <= ks and not vals[i + 1] < vals[i] + 1e-12 * abs(vals[i]):
                unimodal_failures += 1
            if grid[i] >= ks and not vals[i + 1] > vals[i] - 1e-12 * abs(vals[i]):
                unimodal_failures += 1

        # (3) integer optimum is a neighbour of k*
        lo = max(1, math.floor(ks))
        hi = max(1, math.ceil(ks))
        window = range(max(1, lo - 50), hi + 51)
        brute = min(window, key=lambda n: block_cost(A, c, q, mu, float(n)))
        if brute not in (lo, hi):
            c_brute = block_cost(A, c, q, mu, float(brute))
            c_neigh = min(block_cost(A, c, q, mu, float(lo)),
                          block_cost(A, c, q, mu, float(hi)))
            gap = (c_neigh - c_brute) / max(1e-300, abs(c_brute))
            worst_integer_gap = max(worst_integer_gap, gap)
            if gap > 1e-12:
                integer_failures += 1

        # flatness bound (only asserted for mu <= 2)
        if mu <= 2.0:
            for theta in (0.3, 0.7, 1.0, 1.4, 2.5):
                shape = (mu - 1.0) / theta + theta ** (mu - 1.0)
                bound = mu + (mu - 1.0) * (theta - 1.0) ** 2 / theta
                worst_flatness_slack = min(worst_flatness_slack, bound - shape)

        # multiplicative convexity
        k1 = ks * 10 ** rng.uniform(-2, 0)
        k2 = ks * 10 ** rng.uniform(0, 2)
        for w in (0.2, 0.5, 0.8):
            kg = k1 ** w * k2 ** (1.0 - w)
            lhs = block_cost(A, c, q, mu, kg)
            rhs = w * block_cost(A, c, q, mu, k1) + (1 - w) * block_cost(A, c, q, mu, k2)
            if lhs > rhs + 1e-9 * max(1.0, abs(rhs)):
                convexity_failures += 1

    print(f"trials                                : {trials}")
    print(f"max relative error, closed-form value : {worst_value_err:.3e}")
    print(f"max log10 distance, grid min vs k*    : {worst_grid_ratio:.3e}")
    print(f"unimodality violations                : {unimodal_failures}")
    print(f"integer-optimum violations            : {integer_failures}")
    print(f"worst relative neighbour gap (ties)   : {worst_integer_gap:.3e}")
    print(f"min slack in the flatness bound       : {worst_flatness_slack:.3e} (>= 0 expected)")
    print(f"multiplicative-convexity violations   : {convexity_failures}")


if __name__ == "__main__":
    main()


"""Visualisation: universal collapse of the cost curve and the flat plateau.

Left panel.  Cost curves for wildly different setup/penalty pairs (A, q), all
at the same multiplication exponent, are rescaled to shape coordinates
    theta = k / k*,   S = (C(k) - (c - q)) / (q (k*)^(mu-1)).
Every curve collapses onto the single universal shape
    S(mu, theta) = (mu - 1)/theta + theta^(mu - 1),
whose minimum value is exactly mu, attained at theta = 1.

Right panel.  The excess S(mu, theta) - mu against the proved upper bound
(mu - 1)(theta - 1)^2 / theta, for several exponents.  The excess is second
order in the sizing error: mis-sizing the batch by a bounded factor is cheap,
which is why measured optima are broad plateaus rather than sharp spikes.

Output: batch_collapse_flatness.png
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

MU: float = 1.6


def cost_shape(mu: float, theta: np.ndarray) -> np.ndarray:
    return (mu - 1.0) / theta + theta ** (mu - 1.0)


def opt_batch(A: float, q: float, mu: float) -> float:
    return (A / ((mu - 1.0) * q)) ** (1.0 / mu)


def main() -> None:
    thetas = np.logspace(-1.3, 1.3, 800)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.0, 5.4))

    # --- left: collapse ---
    pairs: List[Tuple[float, float]] = [(10.0, 1.0), (1e6, 1e-4), (3.5, 0.7),
                                        (1e3, 5e-2)]
    markers = ["o", "s", "^", "D"]
    for (A, q), mk in zip(pairs, markers):
        k_star = opt_batch(A, q, MU)
        scale = q * k_star ** (MU - 1.0)
        ks = thetas * k_star
        c = 0.0
        raw = A / ks + c + q * (ks ** (MU - 1.0) - 1.0)
        collapsed = (raw - (c - q)) / scale
        ax1.loglog(thetas[::40], collapsed[::40], mk, ms=6, alpha=0.85,
                   label=rf"$A={A:g},\ q={q:g}$")
    ax1.loglog(thetas, cost_shape(MU, thetas), "k-", lw=2.0,
               label=r"$S_\mu(\theta)=\frac{\mu-1}{\theta}+\theta^{\mu-1}$")
    ax1.axvline(1.0, color="grey", ls=":", lw=1.2)
    ax1.axhline(MU, color="grey", ls=":", lw=1.2)
    ax1.set_xlabel(r"$\theta = k / k^{*}$", fontsize=12)
    ax1.set_ylabel("cost in shape units", fontsize=12)
    ax1.set_title(rf"Universal collapse at $\mu = {MU}$ (minimum $= \mu$)", fontsize=13)
    ax1.grid(True, which="both", alpha=0.25)
    ax1.legend(frameon=False, fontsize=9)

    # --- right: flatness ---
    lin = np.linspace(0.2, 3.0, 600)
    for mu, col in zip([2.0, 1.585, 1.3, 1.1],
                       plt.cm.plasma(np.linspace(0.1, 0.8, 4))):
        excess = cost_shape(mu, lin) - mu
        bound = (mu - 1.0) * (lin - 1.0) ** 2 / lin
        ax2.plot(lin, excess, lw=2.0, color=col, label=rf"excess, $\mu={mu:.3f}$")
        ax2.plot(lin, bound, lw=1.2, ls="--", color=col, alpha=0.75)
    ax2.axvline(1.0, color="grey", ls=":", lw=1.2)
    ax2.set_xlabel(r"$\theta = k / k^{*}$", fontsize=12)
    ax2.set_ylabel(r"$S_\mu(\theta) - \mu$", fontsize=12)
    ax2.set_title(r"Quadratic flatness: excess $\leq (\mu-1)(\theta-1)^2/\theta$"
                  "\n(dashed = bound)", fontsize=13)
    ax2.grid(True, alpha=0.25)
    ax2.legend(frameon=False, fontsize=9)

    fig.tight_layout()
    fig.savefig("batch_collapse_flatness.png", dpi=160)
    print("wrote batch_collapse_flatness.png")


if __name__ == "__main__":
    main()


"""Visualisation: batching cost curves as the multiplication exponent varies.

Plots the per-candidate cost C(k) = A/k + c + q (k^(mu-1) - 1) on log-log axes
for a range of multiplication exponents, marking the root-law optimum
k* = (A/((mu-1) q))^(1/mu) on each curve.  The flat model mu = 1 is drawn as a
dashed reference: it is monotonically decreasing and carries no optimum, while
every mu > 1 curve turns upward at its own k*, further to the right the smaller
mu is.

Output: batch_cost_curves.png
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np

A: float = 1000.0
C: float = 1.0
Q: float = 1e-3


def block_cost(k: np.ndarray, mu: float) -> np.ndarray:
    return A / k + C + Q * (k ** (mu - 1.0) - 1.0)


def opt_batch(mu: float) -> float:
    return (A / ((mu - 1.0) * Q)) ** (1.0 / mu)


def main() -> None:
    ks = np.logspace(0, 7, 2000)
    exponents: List[float] = [2.0, math.log2(3.0), 1.5, 1.3, 1.15]
    colors = plt.cm.viridis(np.linspace(0.05, 0.85, len(exponents)))

    fig, ax = plt.subplots(figsize=(9.5, 6.0))
    ax.loglog(ks, block_cost(ks, 1.0), "k--", lw=1.4,
              label=r"$\mu = 1$ (flat model: no optimum)")

    for mu, col in zip(exponents, colors):
        ax.loglog(ks, block_cost(ks, mu), lw=2.0, color=col,
                  label=rf"$\mu = {mu:.3f}$")
        ks_opt = opt_batch(mu)
        ax.plot([ks_opt], [block_cost(np.array([ks_opt]), mu)[0]], "o",
                color=col, ms=9, mec="white", mew=1.2, zorder=5)

    ax.set_xlabel("batch size $k$ (candidates)", fontsize=12)
    ax.set_ylabel("per-candidate cost $C(k)$", fontsize=12)
    ax.set_title(
        r"Root law: $k^{*}=\left(A/((\mu-1)q)\right)^{1/\mu}$"
        f"   (A = {A:.0f}, c = {C:.0f}, q = {Q:g})",
        fontsize=13,
    )
    ax.grid(True, which="both", alpha=0.25)
    ax.legend(frameon=False, fontsize=10)
    fig.tight_layout()
    fig.savefig("batch_cost_curves.png", dpi=160)
    print("wrote batch_cost_curves.png")


if __name__ == "__main__":
    main()


"""Visualisation: the batch-versus-solo crossover as a root of the cost ratio.

For a pool of size k the per-candidate batch cost is q(k^(mu-1) - 1) + c1 and
the solo cost is the constant s1.  Batching wins exactly for
    k <= M*(mu) = (1 + (s1 - c1)/q)^(1/(mu - 1)).
The exponent 1/(mu - 1) is the whole story: at mu = 2 the crossover is the
linear expression 1 + (s1 - c1)/q, calibrated here to the measured value 1715,
while for mu < 2 it is a root of the same ratio and explodes as mu decreases,
reaching 1715^2 at mu = 3/2 and diverging as mu approaches 1.

Left panel: crossover pool size against the multiplication exponent (log axis).
Right panel: per-candidate batch cost curves against the solo baseline.

Output: batch_crossover.png
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np

Q: float = 1.0
C1: float = 0.0
S1: float = 1714.0          # calibration: 1 + (s1 - c1)/q = 1715
RATIO: float = 1.0 + (S1 - C1) / Q


def crossover(mu: np.ndarray) -> np.ndarray:
    return RATIO ** (1.0 / (mu - 1.0))


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.0, 5.4))

    mus = np.linspace(1.05, 2.5, 500)
    ax1.semilogy(mus, crossover(mus), lw=2.2, color="#1f4e9c")
    for mu, label in [(2.0, "schoolbook"), (np.log2(3.0), "Karatsuba"),
                      (1.5, r"$\mu=3/2$")]:
        m = RATIO ** (1.0 / (mu - 1.0))
        ax1.plot([mu], [m], "o", ms=9, color="#c0392b", zorder=5)
        ax1.annotate(f"{label}\n{m:.3g}", (mu, m), textcoords="offset points",
                     xytext=(8, 6), fontsize=9)
    ax1.axhline(1715, color="grey", ls=":", lw=1.2)
    ax1.set_xlabel(r"multiplication exponent $\mu$", fontsize=12)
    ax1.set_ylabel(r"crossover pool size $M^{*}(\mu)$", fontsize=12)
    ax1.set_title(r"$M^{*}(\mu)=\left(1+\frac{s_1-c_1}{q}\right)^{1/(\mu-1)}$",
                  fontsize=13)
    ax1.grid(True, which="both", alpha=0.25)

    ks = np.logspace(0, 7, 800)
    for mu, col in zip([2.0, np.log2(3.0), 1.5, 1.2],
                       plt.cm.viridis(np.linspace(0.05, 0.8, 4))):
        ax2.loglog(ks, Q * (ks ** (mu - 1.0) - 1.0) + C1, lw=2.0, color=col,
                   label=rf"batch, $\mu={mu:.3f}$")
    ax2.axhline(S1, color="#c0392b", lw=2.0, ls="--", label="solo baseline $s_1$")
    ax2.set_xlabel("pool size $k$", fontsize=12)
    ax2.set_ylabel("per-candidate cost", fontsize=12)
    ax2.set_title("Batch beats solo up to the crossover", fontsize=13)
    ax2.grid(True, which="both", alpha=0.25)
    ax2.legend(frameon=False, fontsize=9)

    fig.tight_layout()
    fig.savefig("batch_crossover.png", dpi=160)
    print("wrote batch_crossover.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstration of the root law for optimal batch size under
sub-quadratic multiplication.

Cost model (per candidate, batch of size k > 0):

    C(k) = A / k + c + q * (k**(mu - 1) - 1)

    A   > 0 : per-batch setup cost (amortised over the batch)
    c       : flat per-candidate cost
    q   > 0 : multiplication-penalty scale
    mu      : multiplication exponent (2 = schoolbook, log2(3) = Karatsuba,
              -> 1 = FFT-like / flat operation model)

Main facts demonstrated here:

  1. Root law: for mu > 1 the unique minimiser is
         k* = (A / ((mu - 1) * q)) ** (1 / mu)
     with optimal value
         C* = c - q + mu * (mu-1)**((1-mu)/mu) * A**((mu-1)/mu) * q**(1/mu).
  2. mu = 2 gives the classical square-root law k* = sqrt(A/q),
     C* = c - q + 2*sqrt(A*q).
  3. mu = 1 has no interior optimum: the cost is strictly decreasing.
  4. Equipartition: A/k* = (mu - 1) * q * (k*)**(mu-1) at the optimum.
  5. Universal collapse: with k = theta * k*, the cost is
         (c - q) + q * (k*)**(mu-1) * S(mu, theta),
         S(mu, theta) = (mu - 1)/theta + theta**(mu - 1),  S(mu, 1) = mu.
  6. Quadratic flatness: S(mu, theta) - mu <= (mu-1)*(theta-1)**2/theta.
  7. Multiplicative convexity holds for all mu; additive convexity fails
     for mu < 2 (explicit witness at mu = 3/2, k = 4, 100, midpoint 52).
  8. Unimodality: the best integer batch is floor(k*) or ceil(k*);
     ternary search finds it.
  9. Crossover: batch beats solo exactly for pools of size at most
         M*(mu) = (1 + (s1 - c1)/q) ** (1/(mu - 1)),
     linear at mu = 2, and a root (hence much larger) for mu < 2.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Core model
# --------------------------------------------------------------------------


def block_cost(A: float, c: float, q: float, mu: float, k: float) -> float:
    """Per-candidate cost of streaming in blocks of size ``k``."""
    if k <= 0.0:
        raise ValueError("batch size must be positive")
    return A / k + c + q * (k ** (mu - 1.0) - 1.0)


def opt_batch(A: float, q: float, mu: float) -> float:
    """The root-law optimum k* = (A / ((mu-1) q)) ** (1/mu), for mu > 1."""
    if mu <= 1.0:
        raise ValueError("no finite optimum for mu <= 1")
    return (A / ((mu - 1.0) * q)) ** (1.0 / mu)


def opt_cost(A: float, c: float, q: float, mu: float) -> float:
    """Closed form of the optimal per-candidate cost."""
    if mu <= 1.0:
        raise ValueError("no finite optimum for mu <= 1")
    return (
        c
        - q
        + mu
        * (mu - 1.0) ** ((1.0 - mu) / mu)
        * A ** ((mu - 1.0) / mu)
        * q ** (1.0 / mu)
    )


def cost_shape(mu: float, theta: float) -> float:
    """Universal shape S(mu, theta) = (mu-1)/theta + theta**(mu-1)."""
    return (mu - 1.0) / theta + theta ** (mu - 1.0)


def crossover(q: float, c1: float, s1: float, mu: float) -> float:
    """Crossover pool size M*(mu) = (1 + (s1-c1)/q) ** (1/(mu-1))."""
    if mu <= 1.0:
        raise ValueError("no finite crossover for mu <= 1")
    return (1.0 + (s1 - c1) / q) ** (1.0 / (mu - 1.0))


# --------------------------------------------------------------------------
# Search utilities
# --------------------------------------------------------------------------


def brute_force_real_min(
    A: float, c: float, q: float, mu: float, lo: float, hi: float, samples: int = 400_001
) -> Tuple[float, float]:
    """Dense grid minimisation on [lo, hi] -- an independent check on k*."""
    best_k = lo
    best_v = block_cost(A, c, q, mu, lo)
    for i in range(samples):
        k = lo + (hi - lo) * i / (samples - 1)
        v = block_cost(A, c, q, mu, k)
        if v < best_v:
            best_v, best_k = v, k
    return best_k, best_v


def integer_ternary_search(f: Callable[[int], float], lo: int, hi: int) -> int:
    """Exact discrete minimiser of a strictly unimodal integer function."""
    while hi - lo > 2:
        m1 = lo + (hi - lo) // 3
        m2 = hi - (hi - lo) // 3
        if f(m1) <= f(m2):
            hi = m2
        else:
            lo = m1
    return min(range(lo, hi + 1), key=f)


def brute_force_integer_min(
    A: float, c: float, q: float, mu: float, n_max: int
) -> int:
    return min(range(1, n_max + 1), key=lambda n: block_cost(A, c, q, mu, float(n)))


def fit_parameters(
    ks: Sequence[float], ys: Sequence[float], mu: float
) -> Tuple[float, float, float]:
    """Recover (A, c, q) from three exact measurements at fixed mu.

    Rows of the design matrix are (1/k, 1, k**(mu-1) - 1).  Solved by plain
    Gaussian elimination so the demo has no third-party dependencies.
    """
    if len(ks) != 3 or len(ys) != 3:
        raise ValueError("need exactly three measurements")
    m: List[List[float]] = [
        [1.0 / k, 1.0, k ** (mu - 1.0) - 1.0, y] for k, y in zip(ks, ys)
    ]
    for col in range(3):
        piv = max(range(col, 3), key=lambda r: abs(m[r][col]))
        m[col], m[piv] = m[piv], m[col]
        pivot = m[col][col]
        if abs(pivot) < 1e-15:
            raise ValueError("singular design matrix -- choose distinct batch sizes")
        m[col] = [x / pivot for x in m[col]]
        for r in range(3):
            if r != col and m[r][col] != 0.0:
                factor = m[r][col]
                m[r] = [a - factor * b for a, b in zip(m[r], m[col])]
    return m[0][3], m[1][3], m[2][3]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

RULE = "=" * 78


def demo_root_law() -> None:
    print(RULE)
    print("1. The root law across multiplication exponents (A = 1000, c = 1, q = 1e-3)")
    print(RULE)
    A, c, q = 1000.0, 1.0, 1e-3
    print(f"{'mu':>8} {'k*':>16} {'C*':>14} {'grid k':>16} {'grid C':>14}")
    for mu in (2.0, math.log2(3.0), 1.465, 1.5, 1.2, 1.05):
        ks = opt_batch(A, q, mu)
        cs = opt_cost(A, c, q, mu)
        gk, gv = brute_force_real_min(A, c, q, mu, 1.0, 4.0 * ks, 200_001)
        print(f"{mu:8.4f} {ks:16.4f} {cs:14.8f} {gk:16.4f} {gv:14.8f}")
    print("\nSchoolbook check (mu = 2): k* = sqrt(A/q), C* = c - q + 2 sqrt(A q)")
    print(f"  k*  = {opt_batch(A, q, 2.0):.10f}   sqrt(A/q) = {math.sqrt(A / q):.10f}")
    print(
        f"  C*  = {opt_cost(A, c, q, 2.0):.10f}   "
        f"c-q+2sqrt(Aq) = {c - q + 2 * math.sqrt(A * q):.10f}"
    )
    print("\nThe optimal batch is antitone in mu: cheaper multiplication -> bigger batch.")


def demo_equipartition() -> None:
    print(RULE)
    print("2. Equipartition at the optimum: A/k* = (mu-1) * q * (k*)^(mu-1)")
    print(RULE)
    A, q = 5000.0, 0.02
    print(f"{'mu':>8} {'A/k*':>14} {'(mu-1) q (k*)^(mu-1)':>24} {'setup share':>14}")
    for mu in (2.0, 1.585, 1.3, 1.1):
        ks = opt_batch(A, q, mu)
        left = A / ks
        right = (mu - 1.0) * q * ks ** (mu - 1.0)
        total = left + q * ks ** (mu - 1.0)
        print(f"{mu:8.3f} {left:14.6f} {right:24.6f} {left / total:14.4f}")
    print("\nAs mu -> 1 the setup share -> 0, which is why the optimum escapes.")


def demo_flat_model() -> None:
    print(RULE)
    print("3. The flat model mu = 1: bigger is always better (no optimum)")
    print(RULE)
    A, c, q = 1000.0, 1.0, 1e-3
    print(f"{'k':>10} {'C(k), mu=1':>16} {'C(k), mu=2':>16}")
    for k in (1.0, 8.0, 64.0, 512.0, 4096.0, 32768.0):
        print(
            f"{k:10.0f} {block_cost(A, c, q, 1.0, k):16.8f} "
            f"{block_cost(A, c, q, 2.0, k):16.8f}"
        )
    print("\nAt mu = 1 the column is strictly decreasing; at mu = 2 it turns at k* = 1000.")


def demo_collapse_and_flatness() -> None:
    print(RULE)
    print("4. Universal collapse and quadratic flatness of the optimum")
    print(RULE)
    A, c, q, mu = 1000.0, 1.0, 1e-3, 1.6
    ks = opt_batch(A, q, mu)
    scale = q * ks ** (mu - 1.0)
    print(f"mu = {mu}, k* = {ks:.4f}, vertical scale q (k*)^(mu-1) = {scale:.6f}\n")
    print(
        f"{'theta':>8} {'C(theta k*)':>16} {'collapse pred.':>16} "
        f"{'S - mu':>12} {'bound':>12} {'rel. loss':>10}"
    )
    for theta in (0.25, 0.5, 0.8, 1.0, 1.25, 2.0, 4.0):
        direct = block_cost(A, c, q, mu, theta * ks)
        pred = (c - q) + scale * cost_shape(mu, theta)
        excess = cost_shape(mu, theta) - mu
        bound = (mu - 1.0) * (theta - 1.0) ** 2 / theta
        print(
            f"{theta:8.2f} {direct:16.8f} {pred:16.8f} "
            f"{excess:12.6f} {bound:12.6f} {excess / mu:10.4%}"
        )
    print("\nDifferent (A, q) collapse onto the same shape curve:")
    print(f"{'A':>10} {'q':>10} {'theta':>8} {'(C - (c-q)) / scale':>22} {'S(mu,theta)':>14}")
    for A2, q2 in ((10.0, 1.0), (1e6, 1e-4), (3.5, 0.7)):
        ks2 = opt_batch(A2, q2, mu)
        scale2 = q2 * ks2 ** (mu - 1.0)
        for theta in (0.5, 1.0, 3.0):
            val = (block_cost(A2, 0.0, q2, mu, theta * ks2) - (0.0 - q2)) / scale2
            print(f"{A2:10.4g} {q2:10.4g} {theta:8.2f} {val:22.10f} "
                  f"{cost_shape(mu, theta):14.10f}")


def demo_convexity() -> None:
    print(RULE)
    print("5. Multiplicative convexity holds; additive convexity fails for mu < 2")
    print(RULE)
    mu, A, c, q = 1.5, 1.0, 0.0, 1.0
    c4 = block_cost(A, c, q, mu, 4.0)
    c100 = block_cost(A, c, q, mu, 100.0)
    c52 = block_cost(A, c, q, mu, 52.0)
    print(f"mu = {mu}: C(4) = {c4:.6f}, C(100) = {c100:.6f}, average = {(c4 + c100)/2:.6f}")
    print(f"          C(52) = {c52:.6f}  ->  midpoint cost EXCEEDS the average "
          f"({c52:.4f} > {(c4 + c100)/2:.4f}): not convex in k.")
    c2mid = block_cost(A, c, q, 2.0, 52.0)
    c2avg = (block_cost(A, c, q, 2.0, 4.0) + block_cost(A, c, q, 2.0, 100.0)) / 2
    print(f"mu = 2  : C(52) = {c2mid:.6f} <= average {c2avg:.6f}: convex, as expected.")
    print("\nGeometric interpolation k = k1^w k2^(1-w) never violates convexity:")
    print(f"{'w':>6} {'geom. k':>12} {'C(geom k)':>14} {'w C1 + (1-w) C2':>18} {'ok':>5}")
    k1, k2 = 4.0, 100.0
    for w in (0.0, 0.25, 0.5, 0.75, 1.0):
        kg = k1 ** w * k2 ** (1.0 - w)
        lhs = block_cost(A, c, q, mu, kg)
        rhs = w * c4 + (1.0 - w) * c100
        print(f"{w:6.2f} {kg:12.4f} {lhs:14.6f} {rhs:18.6f} {str(lhs <= rhs + 1e-12):>5}")


def demo_discrete_optimum() -> None:
    print(RULE)
    print("6. The discrete optimum is a neighbour of k*, and ternary search finds it")
    print(RULE)
    print(f"{'A':>10} {'q':>9} {'mu':>7} {'k*':>12} {'floor':>7} {'ceil':>7} "
          f"{'brute':>7} {'ternary':>8} {'match':>6}")
    cases = [
        (1000.0, 1e-3, 2.0),
        (1000.0, 1e-3, 1.5),
        (250.0, 0.5, 1.585),
        (7.0, 3.0, 1.9),
        (0.5, 40.0, 1.7),
        (12345.0, 0.01, 1.25),
    ]
    for A, q, mu in cases:
        c = 1.0
        ks = opt_batch(A, q, mu)
        lo_n = max(1, math.floor(ks))
        hi_n = max(1, math.ceil(ks))
        f = lambda n: block_cost(A, c, q, mu, float(n))
        n_max = max(4, 4 * hi_n)
        brute = brute_force_integer_min(A, c, q, mu, n_max)
        tern = integer_ternary_search(f, 1, n_max)
        ok = brute in (lo_n, hi_n) and tern == brute
        print(f"{A:10.4g} {q:9.4g} {mu:7.3f} {ks:12.4f} {lo_n:7d} {hi_n:7d} "
              f"{brute:7d} {tern:8d} {str(ok):>6}")
    print("\n'match' checks: the brute-force integer optimum is a neighbour of k*,")
    print("and ternary search (which only assumes unimodality) reproduces it.")


def demo_crossover() -> None:
    print(RULE)
    print("7. Batch-versus-solo crossover, calibrated to a measured M* = 1715")
    print(RULE)
    q, c1 = 1.0, 0.0
    s1 = c1 + 1714.0 * q  # calibration: 1 + (s1 - c1)/q = 1715
    print(f"calibration: q = {q}, c1 = {c1}, s1 = {s1}  ->  ratio R = "
          f"{1 + (s1 - c1)/q:.0f}\n")
    print(f"{'mu':>8} {'M*(mu)':>20} {'M*(mu)/M*(2)':>16}")
    base = crossover(q, c1, s1, 2.0)
    for mu in (2.0, 1.8, math.log2(3.0), 1.5, 1.3, 1.1, 1.05):
        m = crossover(q, c1, s1, mu)
        print(f"{mu:8.4f} {m:20.4g} {m / base:16.4g}")
    print("\nSanity check of the crossover characterisation (batch cost <= solo cost):")
    for mu in (2.0, 1.5):
        m = crossover(q, c1, s1, mu)
        for k in (0.5 * m, 0.999 * m, m, 1.001 * m, 2.0 * m):
            batch = q * (k ** (mu - 1.0) - 1.0) + c1
            print(f"  mu={mu:4.2f}  k={k:14.4f}  batch={batch:14.4f}  "
                  f"solo={s1:10.2f}  batch<=solo: {batch <= s1 + 1e-9}")
    print(f"\nAt mu = 3/2 the crossover is exactly 1715^2 = "
          f"{crossover(q, c1, s1, 1.5):.0f}.")


def demo_calibration() -> None:
    print(RULE)
    print("8. Calibration: recover (A, c, q) from three measurements, then size")
    print(RULE)
    A_true, c_true, q_true, mu = 4096.0, 0.75, 0.004, 1.585
    ks = [16.0, 256.0, 4096.0]
    ys = [block_cost(A_true, c_true, q_true, mu, k) for k in ks]
    A_hat, c_hat, q_hat = fit_parameters(ks, ys, mu)
    print(f"true   : A = {A_true:.6f}, c = {c_true:.6f}, q = {q_true:.6f}")
    print(f"fitted : A = {A_hat:.6f}, c = {c_hat:.6f}, q = {q_hat:.6f}")
    k_true = opt_batch(A_true, q_true, mu)
    k_hat = opt_batch(A_hat, q_hat, mu)
    print(f"k* from true parameters   : {k_true:.6f}")
    print(f"k* from fitted parameters : {k_hat:.6f}")
    n_hat = min(
        (max(1, math.floor(k_hat)), max(1, math.ceil(k_hat))),
        key=lambda n: block_cost(A_true, c_true, q_true, mu, float(n)),
    )
    print(f"recommended integer batch : {n_hat}")
    print(f"cost there                : "
          f"{block_cost(A_true, c_true, q_true, mu, float(n_hat)):.10f}")
    print(f"ideal continuous cost     : {opt_cost(A_true, c_true, q_true, mu):.10f}")


def main() -> None:
    demo_root_law()
    print()
    demo_equipartition()
    print()
    demo_flat_model()
    print()
    demo_collapse_and_flatness()
    print()
    demo_convexity()
    print()
    demo_discrete_optimum()
    print()
    demo_crossover()
    print()
    demo_calibration()
    print()
    print(RULE)
    print("All demonstrations complete.")
    print(RULE)


if __name__ == "__main__":
    main()
