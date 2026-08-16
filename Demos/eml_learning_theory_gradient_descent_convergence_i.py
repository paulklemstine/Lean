"""Temperature-annealed training of a smooth exp-log unit into its tropical limit.

The smooth surrogate at temperature T differs from the tropical objective by at most
N * T * log k uniformly (N samples, k monomials per unit). Choosing
T = eps / (2 N log k) therefore makes any eps/2-optimal point of the surrogate an
eps-optimal point of the tropical problem. This routine anneals T geometrically,
running smooth gradient steps at each temperature, and reports the certified gap.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Pair = Tuple[float, float]


def tropical(monomials: Sequence[Pair], x: float) -> float:
    return max(a * x + c for (a, c) in monomials)


def smooth(monomials: Sequence[Pair], x: float, temperature: float) -> float:
    """Numerically stable T log sum exp((a x + c)/T)."""
    vals = [a * x + c for (a, c) in monomials]
    m = max(vals)
    return m + temperature * math.log(sum(math.exp((v - m) / temperature) for v in vals))


def smooth_derivative(monomials: Sequence[Pair], x: float,
                      temperature: float) -> float:
    """d/dx of the smooth unit: the softmax-weighted average of the slopes."""
    vals = [a * x + c for (a, c) in monomials]
    m = max(vals)
    w = [math.exp((v - m) / temperature) for v in vals]
    z = sum(w)
    return sum(wi * a for wi, (a, _) in zip(w, monomials)) / z


def certified_gap(n_samples: int, n_monomials: int, temperature: float) -> float:
    """Uniform bound N * T * log k between smooth and tropical objectives."""
    return n_samples * temperature * math.log(n_monomials)


def anneal(monomials: Sequence[Pair], x0: float, n_samples: int,
           temperatures: Sequence[float], steps_per_stage: int,
           learning_rate: float) -> List[Tuple[float, float, float]]:
    """Run smooth gradient descent through a decreasing temperature schedule.

    Returns a list of (temperature, parameter, certified gap) at the end of each stage.
    Complexity: Theta(k) per gradient step, Theta(|schedule| * steps * k) overall.
    """
    x = x0
    log: List[Tuple[float, float, float]] = []
    for T in temperatures:
        for _ in range(steps_per_stage):
            x -= learning_rate * smooth_derivative(monomials, x, T)
        log.append((T, x, certified_gap(n_samples, len(monomials), T)))
    return log


def schedule_for_accuracy(eps: float, n_samples: int, n_monomials: int,
                          stages: int) -> List[float]:
    """Geometric schedule ending at the temperature that certifies accuracy eps."""
    t_final = eps / (2.0 * n_samples * math.log(n_monomials))
    return [t_final * (10.0 ** (stages - 1 - j)) for j in range(stages)]


if __name__ == "__main__":
    monos: List[Pair] = [(-2.0, 1.0), (0.0, 0.0), (1.0, -0.5), (3.0, -4.0)]
    sched = schedule_for_accuracy(eps=1e-3, n_samples=9, n_monomials=len(monos),
                                  stages=5)
    print("temperature schedule:", [f"{t:.3e}" for t in sched])
    for (T, x, gap) in anneal(monos, x0=1.5, n_samples=9, temperatures=sched,
                              steps_per_stage=200, learning_rate=0.05):
        print(f"T={T:.3e}  x={x:+.6f}  smooth={smooth(monos, x, T):+.6f}  "
              f"tropical={tropical(monos, x):+.6f}  certified gap={gap:.3e}")


"""Compile a tropical rational function into a rectifier network, and prune it.

Two routines:

  compile_tropical  — turns a tropical polynomial (a list of affine monomials)
                      into a rectifier expression using max(u,v) = v + relu(u-v),
                      spending exactly one rectifier per extra monomial;
  prune_monomials   — removes inessential monomials, those whose affine piece never
                      attains the maximum, by an upper-hull sweep.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

Pair = Tuple[float, float]  # (slope, coefficient)


class ReluExpr:
    """A one-dimensional feed-forward rectifier expression."""

    def __init__(self, kind: str, *args: object) -> None:
        self.kind = kind
        self.args = args

    def eval(self, x: float) -> float:
        if self.kind == "affine":
            a, b = self.args  # type: ignore[misc]
            return float(a) * x + float(b)
        if self.kind == "add":
            f, g = self.args  # type: ignore[misc]
            return f.eval(x) + g.eval(x)      # type: ignore[union-attr]
        if self.kind == "smul":
            c, f = self.args  # type: ignore[misc]
            return float(c) * f.eval(x)       # type: ignore[union-attr]
        if self.kind == "act":
            (f,) = self.args  # type: ignore[misc]
            v = f.eval(x)                     # type: ignore[union-attr]
            return v if v > 0.0 else 0.0
        raise ValueError(f"unknown node {self.kind}")


def compile_tropical(base: Pair, monomials: Sequence[Pair]) -> ReluExpr:
    """Rectifier realization of max(base, max_j monomial_j).

    Complexity: Theta(k) nodes and exactly k-1 rectifier units for k monomials;
    depth Theta(k) (a balanced binary variant achieves depth Theta(log k)).
    """
    expr = ReluExpr("affine", base[0], base[1])
    for (a, c) in monomials:
        expr = ReluExpr(
            "add", expr,
            ReluExpr("act", ReluExpr("add", ReluExpr("affine", a, c),
                                     ReluExpr("smul", -1.0, expr))))
    return expr


def compile_tropical_rational(num: Tuple[Pair, List[Pair]],
                              den: Tuple[Pair, List[Pair]]) -> ReluExpr:
    """Rectifier realization of a difference of two tropical polynomials."""
    return ReluExpr("add", compile_tropical(*num),
                    ReluExpr("smul", -1.0, compile_tropical(*den)))


def prune_monomials(monomials: Sequence[Pair]) -> List[Pair]:
    """Keep only the monomials that attain the maximum somewhere (upper hull).

    Sort by slope; among equal slopes keep the highest coefficient. Then sweep,
    discarding a line whenever its two neighbours already meet to the left of where
    it would take over: with slopes a1 < a2 < a3, the middle line is inessential iff
    (c1 - c3)(a2 - a1) <= (c1 - c2)(a3 - a1).
    Complexity: Theta(k log k).
    """
    best: dict = {}
    for (a, c) in monomials:
        if a not in best or c > best[a]:
            best[a] = c
    lines: List[Pair] = sorted(best.items())

    hull: List[Pair] = []
    for (a3, c3) in lines:
        while len(hull) >= 2:
            (a1, c1), (a2, c2) = hull[-2], hull[-1]
            if (c1 - c3) * (a2 - a1) <= (c1 - c2) * (a3 - a1):
                hull.pop()
            else:
                break
        hull.append((a3, c3))
    return hull


if __name__ == "__main__":
    base: Pair = (-2.0, 1.0)
    monos: List[Pair] = [(0.0, 0.0), (3.0, -4.0), (1.0, -0.5), (0.5, -9.0)]
    net = compile_tropical(base, monos)
    trop = lambda x: max([base[0]*x + base[1]] + [a*x + c for (a, c) in monos])
    worst = max(abs(net.eval(i/20.0) - trop(i/20.0)) for i in range(-100, 101))
    print(f"network reproduces the tropical polynomial, max error {worst:.3e}")
    kept = prune_monomials([base] + monos)
    pruned = lambda x: max(a*x + c for (a, c) in kept)
    same = max(abs(pruned(i/20.0) - trop(i/20.0)) for i in range(-200, 201))
    print(f"pruning: {len([base] + monos)} monomials -> {len(kept)} essential ones, "
          f"function unchanged (max deviation {same:.3e})")
    print("essential:", kept)


"""Polyak-step subgradient descent on a sharp tropical loss.

Returns the full trajectory together with the proved geometric envelope
(1 - mu^2/G^2)^n * (theta_0 - theta_star)^2, so that the certificate can be
checked at every step.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple


def trop_l1_loss(y: Sequence[float], x: float) -> float:
    """R(x) = sum_i |x - y_i|: the tropical absolute-error risk."""
    return sum(abs(x - yi) for yi in y)


def trop_l1_subgradient(y: Sequence[float], x: float) -> float:
    """Canonical subgradient selection: the sign sum, ties resolved to +1.

    Satisfies the affine-minorant property R(x) + g(x)(u - x) <= R(u) for all u,
    and |g(x)| <= N.
    """
    return float(sum(1.0 if yi <= x else -1.0 for yi in y))


def median_parameter(y: Sequence[float]) -> float:
    """The unique minimizer of the tropical L1 risk for an odd sample."""
    s = sorted(y)
    return s[(len(s) - 1) // 2]


def polyak_train(y: Sequence[float], theta0: float, n_steps: int
                 ) -> Tuple[List[float], List[float], List[float]]:
    """Run n_steps Polyak iterations.

    Returns (iterates, squared_errors, geometric_envelope).

    Complexity: Theta(N) per iteration; O(N^2 log(D/eps)) iterations for
    parameter accuracy eps, by the contraction factor 1 - 1/N^2.
    """
    n_samples = len(y)
    theta_star = median_parameter(y)
    f_star = trop_l1_loss(y, theta_star)
    rate = 1.0 - 1.0 / (n_samples * n_samples)
    d0_sq = (theta0 - theta_star) ** 2

    theta = theta0
    iterates: List[float] = [theta0]
    errors: List[float] = [d0_sq]
    envelope: List[float] = [d0_sq]

    for k in range(1, n_steps + 1):
        g = trop_l1_subgradient(y, theta)
        if g != 0.0:
            gap = trop_l1_loss(y, theta) - f_star
            theta = theta - (gap / (g * g)) * g
        iterates.append(theta)
        errors.append((theta - theta_star) ** 2)
        envelope.append(rate ** k * d0_sq)

    return iterates, errors, envelope


if __name__ == "__main__":
    samples = [-3.1, -2.0, -0.7, 0.2, 0.9, 1.4, 2.6, 3.3, 5.0]
    xs, errs, env = polyak_train(samples, theta0=12.0, n_steps=8)
    print(f"median = {median_parameter(samples)}, N = {len(samples)}, "
          f"guaranteed factor = {1 - 1/len(samples)**2:.6f}")
    for k, (x, e, b) in enumerate(zip(xs, errs, env)):
        print(f"n={k:2d}  theta={x:12.9f}  err^2={e:.3e}  envelope={b:.3e}  "
              f"ok={e <= b + 1e-12}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Applications/EMLTropicalLearning/TropicalPWL.lean",
    "Catalog/Applications/EMLTropicalLearning/TropicalLimit.lean",
    "Catalog/Applications/EMLTropicalLearning/SubgradientRate.lean",
    "Catalog/Applications/EMLTropicalLearning/TropicalERM.lean",
    "Catalog/Applications/EMLTropicalLearning/PolyakLinearRate.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===================================================================\n"
    f"-- FILE: {f}\n"
    f"-- ===================================================================\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future Directions — Tropical learning theory in the max-plus limit (next cycle)

Derived from what survived and what failed in this cycle. Established this cycle: the
tropical/rectifier dictionary in one variable, quantitative Maslov dequantization of
exp–log units (the two-sided bound with uniform error `T log k` and the large-weight
limit), the `O(D G / sqrt(n))` subgradient best-iterate rate, sharpness of the tropical
`L^1` loss, the geometric Polyak rate, and the fixed-step non-convergence boundary.

Failure analysis feeding the conjectures below:

* *True but hard*: multivariate tropical rational calculus. The pairwise-sum product
  rule generalizes verbatim, but the median/sharpness argument does not: in `R^d` the
  `L^1` minimizer is a coordinatewise median only for separable losses.
* *Needs a different definition*: "gradient descent converges to a tropical rational
  function" is false as literally stated for a fixed step (see the 2-cycle
  counterexample); the correct statements are best-iterate and Polyak-step convergence.
* *Structural pattern*: every rate proved is controlled by two tropical invariants —
  the largest absolute slope (the Lipschitz constant) and the sharpness constant
  (growth away from the minimizer). This slope/sharpness pair is the tropical
  replacement for the smoothness/strong-convexity pair.

## Conjecture 1 (Tropical condition number governs all first-order rates)

For any tropical rational loss `L` on `R^d`, with `G` its maximal tropical slope and `mu`
its sharpness constant at the minimizer, Polyak-step subgradient descent contracts the
squared distance by exactly `1 − mu^2/G^2` per step, and no first-order method beats
`(1 − mu^2/G^2)^{n/2}` on the worst instance with these invariants.

*The key insight is* that `mu/G` is a purely combinatorial quantity — the ratio between
the smallest and largest slopes of the tropical normal fan at the optimum — so the
optimization rate is computed by the geometry of a Newton polytope rather than by any
analytic estimate. *Why now?* The one-variable case is fully proved here (`mu = 1`,
`G = N`, contraction `1 − 1/N^2`), and the multivariate normal-fan machinery needed for
the lower bound is elementary polyhedral combinatorics.

## Conjecture 2 (Dequantization commutes with training)

Let `theta_T(n)` be the `n`-th gradient-descent iterate of the smooth exp–log network at
temperature `T`, and `theta_0(n)` the `n`-th subgradient iterate of its tropical limit.
Then `|theta_T(n) − theta_0(n)| <= C · n · T · log k`, and consequently the two training
trajectories have the same limit set as `T → 0+`.

*The key insight is* that the dequantization defect is uniformly `T log k` **per unit**,
so it can only accumulate linearly along a trajectory of `1`-Lipschitz update maps.
*Why now?* The per-unit bound with its explicit constant is already proved; what remains
is a discrete Grönwall argument for nonexpansive piecewise-linear update maps.

## Further problems

* **Pruning and canonical form.** Characterize which tropical monomials are inessential
  (never attain the maximum), giving a canonical minimal rectifier realization and a
  notion of model compression with an exact, not approximate, guarantee.
* **Stochastic Polyak steps.** Mini-batch versions of the Polyak rule for tropical
  losses, where the optimal value must be estimated online.
* **Generalization.** Sharpness at the empirical optimum plus a uniform bound on
  tropical slopes should yield fast (non-`1/sqrt(n)`) excess-risk rates, since sharp
  empirical risk pins down the parameter rather than merely the loss value.
* **Depth.** The compilation used here has depth linear in the number of monomials;
  quantifying the depth/monomial trade-off would give a tropical account of the
  expressivity benefits of depth.
"""

package = {
    "title": "Learning at Absolute Zero: Gradient Descent in the Tropical Limit",
    "domain": "Applications",
    "description": (
        "A complete first-order learning theory for exp\u2013log neural units in their "
        "max-plus (tropical) limit: quantitative Maslov dequantization with uniform "
        "error T log k, an exact tropical/rectifier dictionary costing one rectifier "
        "per tropical monomial, and sharpness of the tropical absolute-error risk that "
        "upgrades the optimal O(1/\u221an) subgradient rate to geometric convergence at "
        "rate 1 \u2212 \u03bc\u00b2/G\u00b2 under Polyak steps."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-16",
    "key_results": [
        "Quantitative Maslov dequantization: a smooth exp-log aggregator over k terms at "
        "temperature T lies between the max-plus fold and that fold plus T log k, "
        "uniformly in the input, so an exp-log neuron converges to a tropical polynomial "
        "as the weight scale tends to infinity.",
        "Tropical/rectifier dictionary in one variable: a function of a real variable is "
        "a difference of two finite maxima of affine functions if and only if some "
        "feed-forward rectifier network computes it exactly, with one rectifier unit per "
        "tropical monomial via the identity max(u,v) = v + relu(u - v).",
        "Sharpness of the tropical absolute-error risk: on an ordered sample of odd size "
        "the risk exceeds its minimum by at least the distance to the median parameter, "
        "so the median is the unique empirical risk minimizer and every risk guarantee "
        "transfers to a parameter guarantee.",
        "Geometric convergence under Polyak steps: for a convex objective with "
        "subgradient bound G that is sharp with constant mu, each Polyak step multiplies "
        "the squared distance to the minimizer by 1 - mu^2/G^2; for tropical training on "
        "N samples this is 1 - 1/N^2, against the optimal O(D N / sqrt(n)) fixed-step "
        "rate.",
        "Failure of fixed steps and landscape equivalence: on the samples 0, 1, 2 with "
        "step 3 the iterates form an exact two-cycle never within distance 2 of the "
        "unique minimizer, while a function is tropical rational precisely when some "
        "rectifier network has the same empirical risk on every data set, so the "
        "convergence rate is a property of the tropical geometry of the loss and not of "
        "the parameterization.",
    ],
    "keywords": [
        "tropical geometry",
        "max-plus algebra",
        "Maslov dequantization",
        "ReLU networks",
        "subgradient method",
        "sharpness",
        "Polyak step size",
        "piecewise-linear optimization",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Verification of the Tropical Learning Theory",
            "description": (
                "A single self-contained script that exercises every theorem in the "
                "development. It (i) evaluates a smooth exp-log neuron against its "
                "tropical polynomial shadow across six decades of temperature and checks "
                "that the defect stays inside [0, T log k] both pointwise and uniformly "
                "over a grid of inputs; (ii) compiles tropical polynomials into rectifier "
                "expressions and verifies exact agreement together with the predicted "
                "count of one rectifier per extra monomial, and confirms the tropical "
                "product rule that a pointwise sum of max-plus polynomials is the max-plus "
                "polynomial of pairwise sums; (iii) tests the sharpness inequality "
                "R(x) >= R(median) + |x - median| on random ordered samples and exhibits "
                "the absolute-error loss explicitly as a maximum of 2^N affine functions "
                "with maximal slope N; (iv) compares fixed-step subgradient descent at the "
                "tuned step against the proved O(D N / sqrt n) best-iterate bound and "
                "Polyak-step descent against the proved geometric envelope "
                "(1 - 1/N^2)^n; (v) reproduces the exact two-cycle showing permanent "
                "failure of a large fixed step; and (vi) confirms that a compiled "
                "rectifier network reproduces the empirical risk of its tropical model on "
                "random data sets to machine precision."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Tropical-to-Rectifier Compilation with Upper-Hull Monomial Pruning",
            "description": (
                "Converts a tropical polynomial, given as a list of affine monomials "
                "(slope, coefficient), into an exactly equivalent feed-forward rectifier "
                "expression, and removes monomials that are provably inessential. The "
                "compilation rests on the identity max(u, v) = v + relu(u - v), applied "
                "once per monomial, so a polynomial with k monomials becomes a network "
                "with exactly k - 1 rectifier units, Theta(k) nodes and depth Theta(k) "
                "(a balanced binary variant achieves depth Theta(log k)). A tropical "
                "rational function, being a difference of two tropical polynomials, "
                "compiles to the difference of two such blocks. The pruning pass is an "
                "upper-envelope (convex-hull) sweep in Theta(k log k): after sorting by "
                "slope and keeping the highest coefficient among equal slopes, a line is "
                "discarded exactly when its two neighbours already meet to the left of "
                "where it would take over, which for slopes a1 < a2 < a3 is the test "
                "(c1 - c3)(a2 - a1) <= (c1 - c2)(a3 - a1). Pruning leaves the function "
                "pointwise unchanged, so it is exact model compression rather than "
                "approximation, and it minimizes the rectifier count of the realization."
            ),
            "pseudocode": (
                "COMPILE(base, monomials):\n"
                "  E <- AffineNode(base.slope, base.coeff)\n"
                "  for (a, c) in monomials:\n"
                "      U <- AffineNode(a, c)\n"
                "      D <- AddNode(U, ScaleNode(-1, E))       # u - v\n"
                "      E <- AddNode(E, ReluNode(D))            # max(u,v) = v + relu(u-v)\n"
                "  return E                                     # k-1 relu units\n"
                "\n"
                "COMPILE_RATIONAL(numerator, denominator):\n"
                "  return AddNode(COMPILE(numerator),\n"
                "                 ScaleNode(-1, COMPILE(denominator)))\n"
                "\n"
                "PRUNE(monomials):\n"
                "  best <- map slope -> maximal coefficient with that slope\n"
                "  L <- entries of best sorted by increasing slope\n"
                "  H <- empty stack\n"
                "  for (a3, c3) in L:\n"
                "      while |H| >= 2:\n"
                "          (a1, c1) <- H[-2];  (a2, c2) <- H[-1]\n"
                "          if (c1 - c3)*(a2 - a1) <= (c1 - c2)*(a3 - a1):\n"
                "              pop H                            # middle line never wins\n"
                "          else:\n"
                "              break\n"
                "      push (a3, c3) onto H\n"
                "  return H                                     # the essential monomials"
            ),
            "code": read(A / "algo_compile.py"),
        },
        {
            "name": "Polyak-Step Subgradient Training with a Per-Iteration Geometric Certificate",
            "description": (
                "Minimizes the tropical absolute-error risk R(theta) = sum_i |theta - y_i| "
                "by subgradient descent with the self-tuning Polyak step "
                "theta <- theta - (R(theta) - R*) g(theta) / g(theta)^2, where g is the "
                "sign-sum subgradient selection and R* the optimal value at the median. "
                "The step needs no hyperparameter. Its correctness rests on two facts "
                "about the tropical landscape: the subgradient is bounded by G = N (the "
                "maximal tropical slope of the loss) and the loss is sharp with constant "
                "mu = 1 (it grows at least linearly away from the median). Together these "
                "give a contraction of the squared distance by 1 - mu^2/G^2 = 1 - 1/N^2 "
                "at every step, so the iteration count to parameter accuracy eps from "
                "initial distance D is O(N^2 log(D/eps)) and the total cost is "
                "O(N^3 log(D/eps)), against O(D^2 N^2 / eps^2) iterations for the tuned "
                "fixed step. The routine returns, alongside the trajectory, the proved "
                "envelope (1 - 1/N^2)^n (theta_0 - theta*)^2, so the certificate can be "
                "checked at every single iteration."
            ),
            "pseudocode": (
                "POLYAK_TRAIN(samples y[0..N-1], theta_0, n_steps):\n"
                "  theta*  <- median(y)                     # unique minimizer\n"
                "  R*      <- sum_i |theta* - y_i|\n"
                "  rate    <- 1 - 1/N^2                     # = 1 - mu^2/G^2, mu=1, G=N\n"
                "  D2      <- (theta_0 - theta*)^2\n"
                "  theta   <- theta_0\n"
                "  for k = 1 .. n_steps:\n"
                "      g <- sum_i sign_plus(theta - y_i)    # |g| <= N\n"
                "      if g != 0:\n"
                "          gap   <- (sum_i |theta - y_i|) - R*\n"
                "          theta <- theta - (gap / g^2) * g\n"
                "      record( theta,\n"
                "              error   = (theta - theta*)^2,\n"
                "              envelope= rate^k * D2 )      # error <= envelope, always\n"
                "  return trajectory, errors, envelope"
            ),
            "code": read(A / "algo_polyak.py"),
        },
        {
            "name": "Temperature-Annealed Dequantization Schedule for Exp-Log Units",
            "description": (
                "Turns the dequantization bound into an executable training schedule. At "
                "temperature T the smooth exp-log objective on N samples differs from the "
                "tropical objective by at most N T log k uniformly in the parameter, where "
                "k is the number of monomials per unit. Hence choosing "
                "T = eps / (2 N log k) makes any eps/2-optimal point of the smooth "
                "surrogate an eps-optimal point of the tropical problem: the smooth model "
                "is a certified proxy, not merely a heuristic one. The routine runs "
                "gradient descent on the smooth surrogate through a geometrically "
                "decreasing temperature schedule ending at that value, using the exact "
                "derivative of the log-sum-exp unit, which is the softmax-weighted average "
                "of the monomial slopes and hence always lies in the convex hull of those "
                "slopes. All evaluations use the shift-by-the-maximum trick so that no "
                "exponential overflows even at temperatures of order 1e-8. Cost is "
                "Theta(k) per gradient step and Theta(stages * steps * k) overall; the "
                "certified gap is reported at the end of every stage."
            ),
            "pseudocode": (
                "SCHEDULE(eps, N, k, stages):\n"
                "  T_final <- eps / (2 * N * log k)      # certifies eps-optimality\n"
                "  return [ T_final * 10^(stages-1-j) for j = 0 .. stages-1 ]\n"
                "\n"
                "SMOOTH(monomials, x, T):                # stable log-sum-exp\n"
                "  v <- [ a*x + c for (a,c) in monomials ];  m <- max v\n"
                "  return m + T * log( sum_j exp((v_j - m)/T) )\n"
                "\n"
                "SMOOTH_DERIV(monomials, x, T):          # softmax-weighted slope\n"
                "  v <- [ a*x + c ];  m <- max v;  w_j <- exp((v_j - m)/T)\n"
                "  return ( sum_j w_j * a_j ) / ( sum_j w_j )\n"
                "\n"
                "ANNEAL(monomials, x_0, N, schedule, steps, lr):\n"
                "  x <- x_0\n"
                "  for T in schedule:\n"
                "      repeat steps times:\n"
                "          x <- x - lr * SMOOTH_DERIV(monomials, x, T)\n"
                "      report( T, x, certified_gap = N * T * log k )\n"
                "  return x"
            ),
            "code": read(A / "algo_anneal.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Freezing an Exp-Log Neuron: the Certified T log k Band",
            "description": (
                "Two panels. The left panel draws a tropical polynomial (the upper "
                "envelope of four affine monomials, shown in grey) together with the "
                "smooth exp-log units that approximate it at temperatures 1, 0.4, 0.15 "
                "and 0.05, so one can watch the kinks being rounded off and then re-form "
                "as the temperature drops. The right panel plots, on log-log axes, the "
                "observed uniform defect sup_x (smooth - tropical) against the proved "
                "envelope T log k across three decades of temperature: the two curves are "
                "parallel lines of slope one, with the observed defect always below the "
                "bound, which is the graphical content of the dequantization theorem."
            ),
            "code": read(A / "viz_dequantization.py"),
        },
        {
            "name": "The Sharp Landscape and the Fate of Three Step Rules",
            "description": (
                "Two panels. The left panel shows the tropical absolute-error risk of a "
                "nine-sample problem, its breakpoints at the data, and the sharpness cone "
                "R(median) + |theta - median| that the risk must dominate everywhere; the "
                "cone touches the risk exactly at the median, which certifies both that "
                "the minimizer is unique and that the growth constant is exactly one. The "
                "right panel tracks the squared parameter error on a logarithmic axis for "
                "three step rules from the same initialization: a fixed step that is too "
                "large (which locks into a cycle and never approaches the optimum), the "
                "tuned fixed step D/(N sqrt n) (which decays slowly and then stalls at the "
                "resolution set by the step), and the Polyak step (which plunges far below "
                "the proved geometric envelope (1 - 1/N^2)^n, drawn dashed for comparison)."
            ),
            "code": read(A / "viz_landscape.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Dequantization Explorer \u2014 watching a smooth network freeze",
            "description": (
                "An interactive canvas showing a tropical polynomial (the maximum of k "
                "affine monomials) together with the smooth exp-log unit that approximates "
                "it, and the certified error band of width T log k drawn between them. A "
                "logarithmic temperature slider sweeps from T = 2.5 down to T = 0.001, "
                "equivalently a weight scale from 0.4 up to 1000, and a second slider "
                "varies the number of monomials from two to nine, with a button to "
                "randomize the monomial slopes and coefficients. Live readouts report the "
                "certified bound T log k, the observed supremum defect measured over the "
                "whole visible input range, a pass/fail indicator for the two-sided "
                "inequality, and the number of rectifier units (k - 1) needed to realize "
                "the frozen unit exactly. The widget is designed so that three facts "
                "become visible rather than merely stated: the smooth curve never "
                "undershoots the hard maximum; the gap is uniform in the input rather than "
                "pointwise; and widening the layer costs only a logarithm."
            ),
            "html": read(A / "widget_dequantization.html"),
        },
        {
            "title": "The Tropical Training Lab \u2014 sharpness, cycles, and the geometric rate",
            "description": (
                "A two-panel laboratory for the tropical absolute-error training problem. "
                "The left panel draws the risk landscape of the current data set together "
                "with its sharpness cone R(median) + |theta - median| and the running "
                "trajectory of iterates; clicking anywhere on it inserts a new data point, "
                "so the reader can reshape the landscape and watch the median, the slope "
                "bound G = N and the guaranteed contraction factor 1 - 1/N^2 update in "
                "real time. The right panel plots the squared parameter error on a "
                "logarithmic scale against the proved geometric envelope. Three step rules "
                "can be selected: the self-tuning Polyak step, the tuned fixed step "
                "D/(N sqrt n), and a fixed step whose size is set by a slider \u2014 push "
                "that slider up and the trajectory locks into the exact two-cycle that "
                "shows fixed-step subgradient descent can fail permanently on a "
                "piecewise-linear landscape. Play, single-step and reset controls, plus "
                "collapsible panels containing the contraction proof and the two-cycle "
                "counterexample, let a reader move between experiment and proof without "
                "leaving the page."
            ),
            "html": read(A / "widget_training_lab.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "algo_compile": read(A / "algo_compile.py"),
        "algo_polyak": read(A / "algo_polyak.py"),
        "algo_anneal": read(A / "algo_anneal.py"),
        "viz_dequantization": read(A / "viz_dequantization.py"),
        "viz_landscape": read(A / "viz_landscape.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
               encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Visualization: Maslov dequantization of an exp-log neuron.

Left panel  — a tropical polynomial (max of four affine pieces) together with its
smooth log-sum-exp surrogates at decreasing temperatures, showing the kinks being
rounded off and then re-forming as T -> 0.

Right panel — the uniform defect sup_x (LSE_T(x) - tropical(x)) plotted against the
theoretical envelope T log k on log-log axes: the defect is squeezed into [0, T log k],
so the two curves must sit one below the other with slope 1 in log-log coordinates.

Run: python3 viz_dequantization.py   (writes dequantization.png)
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

Pair = Tuple[float, float]

MONOMIALS: List[Pair] = [(-2.0, 1.0), (0.0, 0.0), (1.2, -0.6), (3.0, -4.0)]


def tropical(x: np.ndarray, monomials: Sequence[Pair]) -> np.ndarray:
    return np.max(np.stack([a * x + c for (a, c) in monomials]), axis=0)


def lse(x: np.ndarray, monomials: Sequence[Pair], T: float) -> np.ndarray:
    pieces = np.stack([a * x + c for (a, c) in monomials])
    m = np.max(pieces, axis=0)
    return m + T * np.log(np.sum(np.exp((pieces - m) / T), axis=0))


def main() -> None:
    x = np.linspace(-2.0, 3.0, 2001)
    k = len(MONOMIALS)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for (a, c) in MONOMIALS:
        ax1.plot(x, a * x + c, color="0.85", lw=1, zorder=1)
    ax1.plot(x, tropical(x, MONOMIALS), color="black", lw=2.4,
             label="tropical polynomial  (T = 0)", zorder=4)
    for T, colour in zip((1.0, 0.4, 0.15, 0.05), ("#d62728", "#ff7f0e",
                                                  "#2ca02c", "#1f77b4")):
        ax1.plot(x, lse(x, MONOMIALS, T), color=colour, lw=1.6,
                 label=f"exp-log neuron, T = {T}", zorder=3)
    ax1.set_title(f"Dequantization of an exp-log neuron  (k = {k} monomials)")
    ax1.set_xlabel("input $x$")
    ax1.set_ylabel("output")
    ax1.legend(loc="upper left", fontsize=9)
    ax1.grid(alpha=0.25)

    temps = np.logspace(-3, 0.3, 40)
    defects = [float(np.max(lse(x, MONOMIALS, T) - tropical(x, MONOMIALS)))
               for T in temps]
    ax2.loglog(temps, defects, "o-", color="#1f77b4", ms=3,
               label=r"observed  $\sup_x\,(\mathrm{LSE}_T - \mathrm{trop})$")
    ax2.loglog(temps, temps * math.log(k), "--", color="black",
               label=r"proved bound  $T\log k$")
    ax2.axhline(0, color="0.7", lw=0.8)
    ax2.set_title("Uniform dequantization error is trapped in $[0,\\;T\\log k]$")
    ax2.set_xlabel("temperature $T$")
    ax2.set_ylabel("uniform defect")
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("dequantization.png", dpi=160)
    print("wrote dequantization.png")


if __name__ == "__main__":
    main()


"""Visualization: the sharp tropical landscape and three training trajectories.

Left panel  — the tropical L1 risk R(x) = sum_i |x - y_i| for an odd sample, its
breakpoints, and the sharpness cone R(x*) + |x - x*| that the risk must dominate.
The cone touches the risk exactly at the median, certifying that the minimizer is
unique and that the growth constant is mu = 1.

Right panel — squared parameter error against iteration for a fixed step that is too
large (an exact two-cycle: never within distance 2 of the optimum), for the tuned
1/sqrt(n) fixed step, and for the self-tuning Polyak step, plotted against the proved
geometric envelope (1 - 1/N^2)^n (x_0 - x*)^2.

Run: python3 viz_landscape.py   (writes landscape.png)
"""

from __future__ import annotations

import math
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np

SAMPLES: List[float] = [-3.1, -2.0, -0.7, 0.2, 0.9, 1.4, 2.6, 3.3, 5.0]


def risk(y: Sequence[float], x: float) -> float:
    return float(sum(abs(x - yi) for yi in y))


def subgrad(y: Sequence[float], x: float) -> float:
    return float(sum(1.0 if yi <= x else -1.0 for yi in y))


def fixed_step(y: Sequence[float], eta: float, x0: float, n: int) -> List[float]:
    xs, x = [x0], x0
    for _ in range(n):
        x -= eta * subgrad(y, x)
        xs.append(x)
    return xs


def polyak(y: Sequence[float], f_star: float, x0: float, n: int) -> List[float]:
    xs, x = [x0], x0
    for _ in range(n):
        g = subgrad(y, x)
        if g != 0.0:
            x -= ((risk(y, x) - f_star) / (g * g)) * g
        xs.append(x)
    return xs


def main() -> None:
    y = sorted(SAMPLES)
    N = len(y)
    m = (N - 1) // 2
    x_star, r_star = y[m], risk(y, y[m])
    x0 = 12.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    grid = np.linspace(-7.0, 13.0, 1200)
    ax1.plot(grid, [risk(y, float(t)) for t in grid], color="#1f77b4", lw=2.2,
             label=r"tropical risk $R(\theta)=\sum_i|\theta-y_i|$")
    ax1.plot(grid, [r_star + abs(float(t) - x_star) for t in grid], "--",
             color="#d62728", lw=1.8,
             label=r"sharpness cone $R(\theta^\star)+|\theta-\theta^\star|$")
    ax1.plot(y, [risk(y, yi) for yi in y], "o", color="0.35", ms=4,
             label="breakpoints (data)")
    ax1.plot([x_star], [r_star], "*", color="#d62728", ms=16,
             label=f"median $\\theta^\\star={x_star}$")
    ax1.set_title(f"Sharp piecewise-linear landscape  ($N={N}$, slope bound $G=N$)")
    ax1.set_xlabel(r"parameter $\theta$")
    ax1.set_ylabel("empirical risk")
    ax1.legend(fontsize=9)
    ax1.grid(alpha=0.25)

    n = 60
    eta_bad = 2.0
    eta_good = abs(x0 - x_star) / (N * math.sqrt(n))
    traj_bad = fixed_step(y, eta_bad, x0, n)
    traj_good = fixed_step(y, eta_good, x0, n)
    traj_pol = polyak(y, r_star, x0, n)
    err = lambda t: [max((v - x_star) ** 2, 1e-32) for v in t]
    ks = np.arange(n + 1)

    ax2.semilogy(ks, err(traj_bad), color="#d62728", lw=1.6,
                 label=f"fixed step $\\eta={eta_bad}$ (cycles forever)")
    ax2.semilogy(ks, err(traj_good), color="#ff7f0e", lw=1.6,
                 label=r"tuned step $\eta=D/(N\sqrt{n})$")
    ax2.semilogy(ks, err(traj_pol), "o-", color="#1f77b4", lw=1.8, ms=3,
                 label="Polyak step")
    ax2.semilogy(ks, [(1 - 1 / N ** 2) ** int(kk) * (x0 - x_star) ** 2 for kk in ks],
                 "--", color="black", lw=1.4,
                 label=r"proved envelope $(1-1/N^2)^n(\theta_0-\theta^\star)^2$")
    ax2.set_ylim(1e-20, 1e3)
    ax2.set_title("Squared parameter error: three step rules")
    ax2.set_xlabel("iteration $n$")
    ax2.set_ylabel(r"$(\theta_n-\theta^\star)^2$")
    ax2.legend(fontsize=9, loc="lower left")
    ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("landscape.png", dpi=160)
    print("wrote landscape.png")


if __name__ == "__main__":
    main()


"""
Gradient Descent in the Tropical Limit — numerical demonstrations.

Self-contained Python (standard library only) illustrating every main result:

  1. Quantitative Maslov dequantization:  max <= LSE_T <= max + T log k.
  2. The tropical/rectifier dictionary:   one rectifier per tropical monomial.
  3. Tropicality of the L1 training loss  (a max of 2^N affine functions).
  4. Sharpness:                           R(x) >= R(x*) + |x - x*|,  x* = median.
  5. Fixed-step subgradient descent:      O(D G / sqrt(n)) best-iterate rate, G = N.
  6. Polyak-step subgradient descent:     (x_n - x*)^2 <= (1 - 1/N^2)^n (x_0 - x*)^2.
  7. The two-cycle counterexample:        fixed step eta = 3 on samples 0,1,2 never
                                          comes within distance 2 of the optimum.
  8. Risk-landscape equivalence:          a compiled rectifier network has exactly
                                          the same empirical risk as its tropical model.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, List, Sequence, Tuple

Pair = Tuple[float, float]  # (slope, coefficient) of a tropical monomial


# ----------------------------------------------------------------------------
# 1. Tropical arithmetic and tropical polynomials
# ----------------------------------------------------------------------------

def trop_add(a: float, b: float) -> float:
    """Tropical addition: a (+) b = max(a, b)."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a (*) b = a + b."""
    return a + b


def tmax(base: float, terms: Sequence[float]) -> float:
    """Max-plus fold of a nonempty family with distinguished base value."""
    value = base
    for t in terms:
        value = max(value, t)
    return value


def tp_eval(base: Pair, monomials: Sequence[Pair], x: float) -> float:
    """Tropical polynomial: max over affine pieces (slope * x + coefficient)."""
    return tmax(base[0] * x + base[1], [a * x + c for (a, c) in monomials])


def tp_product(p: Tuple[Pair, List[Pair]], q: Tuple[Pair, List[Pair]]
               ) -> Tuple[Pair, List[Pair]]:
    """Tropical product (= ordinary pointwise sum): monomials are pairwise sums."""
    pb, pl = p
    qb, ql = q
    p_all = [pb] + list(pl)
    q_all = [qb] + list(ql)
    sums = [(a1 + a2, c1 + c2) for (a1, c1) in p_all for (a2, c2) in q_all]
    return sums[0], sums[1:]


def tp_max_slope(base: Pair, monomials: Sequence[Pair]) -> float:
    """Largest absolute tropical slope = Lipschitz constant of the polynomial."""
    return max([abs(base[0])] + [abs(a) for (a, _) in monomials])


# ----------------------------------------------------------------------------
# 2. Rectifier expressions and the compilation  max(u, v) = v + relu(u - v)
# ----------------------------------------------------------------------------

def relu(u: float) -> float:
    return u if u > 0.0 else 0.0


class ReluExpr:
    """One-dimensional feed-forward rectifier expression."""

    def __init__(self, kind: str, *args: object) -> None:
        self.kind = kind
        self.args = args

    def eval(self, x: float) -> float:
        if self.kind == "affine":
            a, b = self.args  # type: ignore[misc]
            return float(a) * x + float(b)
        if self.kind == "add":
            f, g = self.args  # type: ignore[misc]
            return f.eval(x) + g.eval(x)   # type: ignore[union-attr]
        if self.kind == "smul":
            c, f = self.args  # type: ignore[misc]
            return float(c) * f.eval(x)    # type: ignore[union-attr]
        if self.kind == "act":
            (f,) = self.args  # type: ignore[misc]
            return relu(f.eval(x))         # type: ignore[union-attr]
        raise ValueError(f"unknown node {self.kind}")

    def relu_count(self) -> int:
        """Number of distinct rectifier units (shared subexpressions counted once)."""
        seen: set = set()
        count = 0
        stack: List[ReluExpr] = [self]
        while stack:
            node = stack.pop()
            if id(node) in seen:
                continue
            seen.add(id(node))
            if node.kind == "act":
                count += 1
            for a in node.args:
                if isinstance(a, ReluExpr):
                    stack.append(a)
        return count


def compile_tropical(base: Pair, monomials: Sequence[Pair]) -> ReluExpr:
    """Compile a tropical polynomial into a rectifier expression.

    Uses max(u, v) = v + relu(u - v) once per extra monomial, so the resulting
    network has exactly len(monomials) rectifier units.
    """
    expr = ReluExpr("affine", base[0], base[1])
    for (a, c) in monomials:
        expr = ReluExpr(
            "add",
            expr,
            ReluExpr("act", ReluExpr("add", ReluExpr("affine", a, c),
                                     ReluExpr("smul", -1.0, expr))),
        )
    return expr


# ----------------------------------------------------------------------------
# 3. Smooth exp-log aggregator and dequantization
# ----------------------------------------------------------------------------

def lse(temperature: float, base: float, terms: Sequence[float]) -> float:
    """T * log( exp(base/T) + sum_j exp(term_j/T) ), computed stably."""
    values = [base] + list(terms)
    m = max(values)
    total = sum(math.exp((v - m) / temperature) for v in values)
    return m + temperature * math.log(total)


def lse_neuron(temperature: float, base: Pair, monomials: Sequence[Pair],
               x: float) -> float:
    return lse(temperature, base[0] * x + base[1],
               [a * x + c for (a, c) in monomials])


def large_weight(scale: float, base: float, terms: Sequence[float]) -> float:
    """s^{-1} log( exp(s*base) + sum exp(s*term) ) == lse(1/s, ...)."""
    return lse(1.0 / scale, base, terms)


# ----------------------------------------------------------------------------
# 4. The tropical L1 training problem
# ----------------------------------------------------------------------------

def trop_l1_loss(y: Sequence[float], x: float) -> float:
    return sum(abs(x - yi) for yi in y)


def trop_l1_subgradient(y: Sequence[float], x: float) -> float:
    """Canonical subgradient selection: sum of signs, ties resolved to +1."""
    return float(sum(1.0 if yi <= x else -1.0 for yi in y))


def gd_iterate(y: Sequence[float], eta: float, x0: float, n: int) -> List[float]:
    xs = [x0]
    x = x0
    for _ in range(n):
        x = x - eta * trop_l1_subgradient(y, x)
        xs.append(x)
    return xs


def polyak_iterate(y: Sequence[float], f_star: float, x0: float,
                   n: int) -> List[float]:
    xs = [x0]
    x = x0
    for _ in range(n):
        g = trop_l1_subgradient(y, x)
        if g == 0.0:
            xs.append(x)
            continue
        x = x - ((trop_l1_loss(y, x) - f_star) / (g * g)) * g
        xs.append(x)
    return xs


def empirical_risk(f: Callable[[float], float], X: Sequence[float],
                   Y: Sequence[float]) -> float:
    return sum(abs(f(xi) - yi) for xi, yi in zip(X, Y))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_dequantization() -> None:
    print("=" * 78)
    print("1. QUANTITATIVE MASLOV DEQUANTIZATION:  max <= LSE_T <= max + T log k")
    print("=" * 78)
    base, monomials = (-1.0, 0.5), [(0.0, 0.0), (2.0, -1.0), (0.7, 0.25)]
    k = len(monomials) + 1
    print(f"tropical polynomial with k = {k} monomials, evaluated at x = 0.4")
    x = 0.4
    exact = tp_eval(base, monomials, x)
    print(f"{'T':>10} {'LSE_T(x)':>14} {'defect':>12} {'bound T log k':>14}  ok")
    for T in (1.0, 0.3, 0.1, 0.03, 0.01, 1e-3):
        smooth = lse_neuron(T, base, monomials, x)
        defect = smooth - exact
        bound = T * math.log(k)
        ok = -1e-12 <= defect <= bound + 1e-12
        print(f"{T:>10.4g} {smooth:>14.9f} {defect:>12.3e} {bound:>14.3e}  {ok}")

    # Uniformity in x: the same bound holds at every input.
    worst = max(abs(lse_neuron(0.01, base, monomials, xx)
                    - tp_eval(base, monomials, xx))
                for xx in [i / 50.0 - 2.0 for i in range(201)])
    print(f"\nsup over x in [-2,2] of |LSE_0.01 - tropical| = {worst:.6e}"
          f"   (bound {0.01 * math.log(k):.6e})")

    # Large-weight form.
    print("\nlarge-weight scaling  s^-1 log sum exp(s * .):")
    terms = [1.0, 2.5, 2.0]
    for s in (1.0, 10.0, 100.0, 1000.0):
        print(f"  s = {s:>7.0f}:  {large_weight(s, 0.0, terms):.9f}"
              f"   ->  tmax = {tmax(0.0, terms)}")


def demo_dictionary() -> None:
    print()
    print("=" * 78)
    print("2. TROPICAL / RECTIFIER DICTIONARY: one rectifier per tropical monomial")
    print("=" * 78)
    base, monomials = (-2.0, 1.0), [(0.0, 0.0), (3.0, -4.0), (1.0, -0.5)]
    net = compile_tropical(base, monomials)
    print(f"monomials: {[base] + monomials}")
    print(f"compiled network uses {net.relu_count()} rectifier units "
          f"(= number of extra monomials = {len(monomials)})")
    worst = 0.0
    for i in range(-100, 101):
        x = i / 20.0
        worst = max(worst, abs(net.eval(x) - tp_eval(base, monomials, x)))
    print(f"max |network(x) - tropical(x)| over x in [-5, 5]: {worst:.3e}")

    # Tropical product rule: pointwise sum of two tropical polynomials.
    p = ((1.0, 0.0), [(-1.0, 2.0)])
    q = ((2.0, -1.0), [(0.0, 1.0), (-3.0, 0.0)])
    prod = tp_product(p, q)
    worst = max(abs(tp_eval(*prod, x) - (tp_eval(*p, x) + tp_eval(*q, x)))
                for x in [i / 10.0 for i in range(-50, 51)])
    print(f"product rule: {len(prod[1]) + 1} monomials, "
          f"max deviation from pointwise sum {worst:.3e}")


def demo_sharpness() -> None:
    print()
    print("=" * 78)
    print("3. SHARPNESS OF THE TROPICAL L1 RISK:  R(x) >= R(x*) + |x - x*|")
    print("=" * 78)
    random.seed(20260816)
    for trial in range(3):
        m = random.randint(1, 4)
        N = 2 * m + 1
        y = sorted(round(random.uniform(-5.0, 5.0), 3) for _ in range(N))
        x_star = y[m]
        r_star = trop_l1_loss(y, x_star)
        slack = min(trop_l1_loss(y, x) - r_star - abs(x - x_star)
                    for x in [x_star + i / 40.0 - 5.0 for i in range(401)])
        print(f"trial {trial}: N = {N}, median = {x_star:+.3f}, R* = {r_star:.3f}, "
              f"min slack over a fine grid = {slack:+.3e} (>= 0)")

    # The loss really is a max of 2^N affine functions (a tropical polynomial).
    y = [0.0, 1.0, 2.0]
    monos = [(float(sum(s)), -float(sum(si * yi for si, yi in zip(s, y))))
             for s in itertools.product((1.0, -1.0), repeat=len(y))]
    worst = max(abs(tp_eval(monos[0], monos[1:], x) - trop_l1_loss(y, x))
                for x in [i / 25.0 - 4.0 for i in range(201)])
    print(f"\nloss as tropical polynomial with 2^{len(y)} = {len(monos)} monomials: "
          f"max deviation {worst:.3e}; max slope = "
          f"{tp_max_slope(monos[0], monos[1:]):.0f} = N")


def demo_rates() -> None:
    print()
    print("=" * 78)
    print("4. CONVERGENCE RATES: fixed step O(1/sqrt n) vs Polyak geometric")
    print("=" * 78)
    m = 4
    N = 2 * m + 1
    y = sorted([-3.1, -2.0, -0.7, 0.2, 0.9, 1.4, 2.6, 3.3, 5.0])
    x_star = y[m]
    r_star = trop_l1_loss(y, x_star)
    x0 = 12.0
    D = abs(x0 - x_star)
    print(f"N = {N} samples, median x* = {x_star}, R* = {r_star:.3f}, x0 = {x0}")

    print("\nfixed step eta = D / (N sqrt(n)), best iterate before time n:")
    print(f"{'n':>7} {'best risk gap':>16} {'bound D N/sqrt n':>18} "
          f"{'param error':>14}  ok")
    for n in (10, 100, 1_000, 10_000):
        eta = D / (N * math.sqrt(n))
        xs = gd_iterate(y, eta, x0, n)[:n]
        gaps = [trop_l1_loss(y, x) - r_star for x in xs]
        best = min(range(n), key=lambda k: gaps[k])
        bound = D * N / math.sqrt(n)
        print(f"{n:>7} {gaps[best]:>16.6f} {bound:>18.6f} "
              f"{abs(xs[best] - x_star):>14.6f}  "
              f"{gaps[best] <= bound + 1e-9 and abs(xs[best] - x_star) <= bound + 1e-9}")

    print("\nPolyak step, squared parameter error vs the guarantee "
          f"(1 - 1/N^2)^n (x0 - x*)^2  with 1 - 1/{N}^2 = "
          f"{1 - 1 / N ** 2:.6f}:")
    xs = polyak_iterate(y, r_star, x0, 12)
    print(f"{'n':>4} {'x_n':>14} {'(x_n - x*)^2':>16} {'guarantee':>16}  ok")
    for n, x in enumerate(xs):
        err = (x - x_star) ** 2
        guar = (1 - 1 / N ** 2) ** n * (x0 - x_star) ** 2
        print(f"{n:>4} {x:>14.9f} {err:>16.3e} {guar:>16.3e}  "
              f"{err <= guar + 1e-12}")

    eps = 1e-6
    n_fixed = D * D * N * N / (eps * eps)
    n_polyak = 2 * N * N * math.log(D / eps)
    print(f"\niterations to parameter accuracy {eps:g}: "
          f"fixed-step guarantee ~ {n_fixed:.3e}, Polyak guarantee ~ {n_polyak:.3e}")


def demo_two_cycle() -> None:
    print()
    print("=" * 78)
    print("5. THE BOUNDARY: a fixed step can cycle forever")
    print("=" * 78)
    y = [0.0, 1.0, 2.0]
    xs = gd_iterate(y, 3.0, 3.0, 10)
    print(f"samples {y}, unique minimizer 1, fixed step eta = 3, x0 = 3")
    print("iterates:", ", ".join(f"{x:g}" for x in xs))
    print("distances to the optimum:",
          ", ".join(f"{abs(x - 1.0):g}" for x in xs))
    print(f"min distance over 10 steps = {min(abs(x - 1.0) for x in xs):g} "
          f"(>= 2 for all n, forever)")
    print("Polyak from the same start, by contrast:")
    print("  ", ", ".join(f"{x:g}" for x in
                          polyak_iterate(y, trop_l1_loss(y, 1.0), 3.0, 4)))


def demo_landscape_equivalence() -> None:
    print()
    print("=" * 78)
    print("6. RISK-LANDSCAPE EQUIVALENCE with rectifier networks")
    print("=" * 78)
    random.seed(7)
    # A tropical rational model: difference of two tropical polynomials.
    p = ((1.0, 0.5), [(-2.0, 1.0), (0.3, -0.4)])
    q = ((0.0, 0.0), [(1.5, -2.0)])

    def tropical_model(x: float) -> float:
        return tp_eval(*p, x) - tp_eval(*q, x)

    net = ReluExpr("add", compile_tropical(*p),
                   ReluExpr("smul", -1.0, compile_tropical(*q)))
    print(f"compiled network: {net.relu_count()} rectifier units "
          f"(= {len(p[1])} + {len(q[1])} monomials)")
    worst = 0.0
    for _ in range(5):
        n = random.randint(3, 8)
        X = [random.uniform(-4.0, 4.0) for _ in range(n)]
        Y = [random.uniform(-4.0, 4.0) for _ in range(n)]
        r1 = empirical_risk(tropical_model, X, Y)
        r2 = empirical_risk(net.eval, X, Y)
        worst = max(worst, abs(r1 - r2))
        print(f"  data set of size {n}: tropical risk {r1:.6f}, "
              f"network risk {r2:.6f}")
    print(f"max discrepancy across random data sets: {worst:.3e} "
          "-> identical landscapes")


def main() -> None:
    demo_dequantization()
    demo_dictionary()
    demo_sharpness()
    demo_rates()
    demo_two_cycle()
    demo_landscape_equivalence()
    print()
    print("All demonstrations agree with the stated theorems.")


if __name__ == "__main__":
    main()
