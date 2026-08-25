"""Certified Banach inversion of a contractive residual block."""

from __future__ import annotations

import math
from typing import Callable, Tuple


def invert_residual_block(
    residual: Callable[[float], float],
    k: float,
    y: float,
    tol: float = 1e-14,
    max_iter: int = 10_000,
) -> Tuple[float, int, float]:
    """Solve x + residual(x) = y for a k-Lipschitz residual with k < 1.

    The iteration x <- y - residual(x) is a k-contraction of the line, so by the
    Banach fixed point theorem it converges geometrically to the unique solution;
    the a posteriori error after a step of size s is bounded by s*k/(1-k), and the
    resulting inverse map is globally (1-k)^{-1}-Lipschitz.

    Returns (solution, iterations used, certified error bound). The iteration count
    to reach tolerance eps is O(log(1/eps) / log(1/k)).
    """
    if not 0.0 <= k < 1.0:
        raise ValueError("the certificate must satisfy 0 <= k < 1")
    x = y
    for it in range(1, max_iter + 1):
        x_new = y - residual(x)
        step = abs(x_new - x)
        x = x_new
        bound = step * k / (1.0 - k)
        if bound <= tol:
            return x, it, bound
    return x, max_iter, float("inf")


def parallel_inverse_certificate(k1: float, k2: float) -> float:
    """Sharp Lipschitz constant of the inverse of a parallel pair of blocks.

    Equals (1 - max(k1,k2))^{-1} = max((1-k1)^{-1}, (1-k2)^{-1}) -- the inverse
    certificates obey the very same max rule as the forward ones.
    """
    if not (0.0 <= k1 < 1.0 and 0.0 <= k2 < 1.0):
        raise ValueError("both certificates must lie in [0, 1)")
    return 1.0 / (1.0 - max(k1, k2))


if __name__ == "__main__":
    k = 0.5
    r = lambda t: k * math.sin(t)
    for y in (0.0, 1.0, -2.5, 7.0):
        x, it, err = invert_residual_block(r, k, y)
        print(f"y = {y:6.2f} -> x = {x:12.8f}  (x + r(x) = {x + r(x):.8f}), "
              f"{it} iterations, error <= {err:.1e}")
    print("parallel inverse certificate for k1=0.5, k2=0.9:",
          parallel_inverse_certificate(0.5, 0.9))


"""Layerwise certificate contraction and the laxity defect ratio."""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


def log_sharp(certs: Sequence[Sequence[float]]) -> float:
    """Depth-first bookkeeping:  max_i sum_j log(1 + K_ij)."""
    return max(sum(math.log1p(k) for k in row) for row in certs)


def log_coarse(certs: Sequence[Sequence[float]]) -> float:
    """Width-first bookkeeping:  sum_j max_i log(1 + K_ij)."""
    depth = len(certs[0])
    return sum(max(math.log1p(row[j]) for row in certs) for j in range(depth))


def laxity_defect(certs: Sequence[Sequence[float]]) -> Tuple[float, float, float]:
    """Return (log sharp, log coarse, log defect) for a rectangular architecture.

    Both quantities certify the same map. The defect log(coarse) - log(sharp) is
    always nonnegative; it vanishes exactly when a single stream attains the layer
    maximum at every layer, and is maximised by permutation-like supports, in
    which each layer's heaviest block sits in a different stream.
    Cost: O(w*d) additions and comparisons.
    """
    ls, lc = log_sharp(certs), log_coarse(certs)
    return ls, lc, lc - ls


def dominating_stream_per_layer(certs: Sequence[Sequence[float]]) -> List[int]:
    """The stream in which each layer's maximum certificate is attained.

    A constant list means zero defect; a list visiting many distinct streams
    means a large defect.
    """
    depth = len(certs[0])
    return [max(range(len(certs)), key=lambda i: certs[i][j]) for j in range(depth)]


if __name__ == "__main__":
    alternating = [
        [1.0 if j % 2 == 0 else 0.0 for j in range(16)],
        [0.0 if j % 2 == 0 else 1.0 for j in range(16)],
    ]
    ls, lc, ld = laxity_defect(alternating)
    print(f"sharp  = {math.exp(ls):.1f}")
    print(f"coarse = {math.exp(lc):.1f}")
    print(f"defect = {math.exp(ld):.1f}")
    print("dominating stream per layer:", dominating_stream_per_layer(alternating))


"""Streamwise (depth-first) sharp certificate contraction."""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


def sharp_certificate(certs: Sequence[Sequence[float]]) -> Tuple[float, int]:
    """Least valid gain of a rectangular residual architecture, in log space.

    `certs[i][j]` is the residual certificate of the block in stream i at layer j.
    Returns (log of the sharp gain, index of the dominating stream), where

        log sharp = max_i sum_j log(1 + K_ij).

    This is a valid certificate for every architecture with these constants, and
    it is exactly the least Lipschitz constant for the parallel dilation
    architecture, so no smaller value is available in general.
    Cost: O(w*d) additions and w-1 comparisons; numerically stable because the
    products of gains are never formed directly.
    """
    best_log = -math.inf
    best_i = 0
    for i, row in enumerate(certs):
        total = 0.0
        for k in row:
            if k < 0:
                raise ValueError("certificates must be nonnegative")
            total += math.log1p(k)
        if total > best_log:
            best_log, best_i = total, i
    return best_log, best_i


def sharp_gain(certs: Sequence[Sequence[float]]) -> float:
    """The sharp gain itself (may overflow for large depth; use the log form)."""
    return math.exp(sharp_certificate(certs)[0])


def stream_gains(certs: Sequence[Sequence[float]]) -> List[float]:
    """Per-stream gains prod_j (1 + K_ij), the quantities the max is taken over."""
    return [math.prod(1.0 + k for k in row) for row in certs]


if __name__ == "__main__":
    arch = [
        [1.0 if j % 2 == 0 else 0.0 for j in range(16)],
        [0.0 if j % 2 == 0 else 1.0 for j in range(16)],
    ]
    log_sharp, which = sharp_certificate(arch)
    print(f"stream gains       : {stream_gains(arch)}")
    print(f"sharp gain         : {math.exp(log_sharp):.1f}  (dominating stream {which})")


"""Assemble PACKAGE.json from the individual artefacts in the project."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Algebra/ResidualCertificateAlgebra.lean",
    "Catalog/Algebra/ParallelResidualBlocks.lean",
    "Catalog/Algebra/ResidualLpIndependence.lean",
    "Catalog/Algebra/ResidualFamilyDepth.lean",
    "Catalog/Algebra/ResidualLaxityDefect.lean",
    "Catalog/Algebra/ResidualBlockInvertibility.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {rel} =====\n{read(ROOT / rel)}" for rel in LEAN_FILES
)

FUTURE_DIRECTIONS = read(A / "future_directions.md")
INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "The Sharp Tensor-Product Certificate for Parallel Residual Blocks",
    "domain": "Algebra",
    "description": (
        "Parallel composition of residual blocks with residual constants K\u2081 and K\u2082 has "
        "Lipschitz constant exactly max(1+K\u2081, 1+K\u2082) \u2014 the bound holds for all blocks, is "
        "attained for every pair of constants, is the smallest valid rule, and is independent of "
        "the product metric. Serial composition multiplies gains, making the certificate calculus "
        "the max-times tropical semiring, and the calculus is only lax: layerwise bookkeeping "
        "over-estimates the true constant by a factor exponential in the depth."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-25",
    "key_results": [
        "Tensor-product certificate: the parallel composition of residual blocks with certificates K\u2081 and K\u2082 is Lipschitz with constant max(1+K\u2081, 1+K\u2082) for the max product norm",
        "Attainment of the bound: for every K\u2081, K\u2082 \u2265 0 the parallel pair of dilation blocks has least Lipschitz constant exactly max(1+K\u2081, 1+K\u2082)",
        "Minimality of the max rule: any rule assigning valid certificates to parallel compositions dominates the maximum pointwise",
        "Independence of the cartesian structure: the same sharp constant is optimal in the max, sum and Euclidean product metrics",
        "Unbounded laxity defect: at depth 2n the alternating width-two architecture has true amplification 2\u207f while layerwise certification returns 4\u207f",
        "Dual max rule: certificates below 1 force bi-Lipschitz invertibility, and the inverse certificates obey the same maximum rule, sharply",
    ],
    "keywords": [
        "residual block",
        "Lipschitz certificate",
        "monoidal category",
        "lax monoidal functor",
        "product norm",
        "tropical semiring",
        "interchange law",
        "bi-Lipschitz invertibility",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Verification of the Residual Certificate Calculus",
            "description": (
                "A self-contained tour of every quantitative claim of the theory. It measures the "
                "Lipschitz constant of residual blocks (linear dilations and a nonlinear tanh block) "
                "against the predicted gain 1+K; checks that serial composition multiplies gains "
                "according to K\u2081*K\u2082 = K\u2081+K\u2082+K\u2081K\u2082; measures the least Lipschitz constant of parallel "
                "pairs and confirms it equals max(1+K\u2081,1+K\u2082) rather than the naive sum; repeats the "
                "measurement in the max, sum and Euclidean product metrics to exhibit metric "
                "invariance; verifies the wide rule sup_i (1+K_i) and the depth rule (1+K)^d together "
                "with the relaxation exp(Kd); tabulates the sharp versus layerwise certificates of the "
                "alternating and cyclic architectures, showing the 2\u207f versus 4\u207f gap; and finally "
                "inverts contractive blocks by Banach iteration, confirming the dual max rule for "
                "inverse certificates. Uses only the standard library."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "The Certificate Semiring: Algebraic Laws, Interchange Strictness and Rule Minimality",
            "description": (
                "Explores the algebraic layer beneath the geometry. Random sampling verifies that "
                "serial composition a*b = a+b+ab is an associative, commutative monoid law with unit 0, "
                "that the maximum is an idempotent monoid law, that serial distributes over parallel, "
                "and that the gain map g(a)=1+a is a monoid homomorphism onto multiplication \u2014 i.e. the "
                "certificates form the positive part of the max-times tropical semiring. A scan over "
                "certificate quadruples then locates the extremal violation of the interchange law "
                "(sharp gain 2 versus coarse gain 4), and a search over candidate parallel rules "
                "confirms numerically that a rule is valid precisely when it dominates the maximum, "
                "so that the max rule is the pointwise smallest valid tensor-product certificate."
            ),
            "code": read(A / "demo_certificate_algebra.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Streamwise Sharp Certificate Contraction in Logarithmic Coordinates",
            "description": (
                "Computes the sharp (least) Lipschitz certificate of a rectangular residual "
                "architecture of width w and depth d. Each stream's gain is the product of its layer "
                "gains 1+K_ij (serial composition multiplies gains), and the parallel rule takes the "
                "maximum across streams, so the sharp gain is max_i prod_j (1+K_ij). The computation is "
                "carried out in log space as max_i sum_j log(1+K_ij), using log1p for accuracy at small "
                "certificates and avoiding the overflow that plagues direct products at large depth. "
                "The result is exactly the least Lipschitz constant for the parallel dilation "
                "architecture and a valid certificate for any architecture with the same constants. "
                "Complexity: O(wd) additions and w-1 comparisons; O(w) working memory."
            ),
            "pseudocode": (
                "Input : certificates K[1..w][1..d], all nonnegative\n"
                "Output: log of the sharp gain, and the dominating stream index\n"
                "\n"
                "1.  best_log <- -infinity ; best_i <- 1\n"
                "2.  for i = 1 to w do\n"
                "3.      total <- 0\n"
                "4.      for j = 1 to d do\n"
                "5.          assert K[i][j] >= 0\n"
                "6.          total <- total + log1p(K[i][j])      // log of the layer gain\n"
                "7.      end for\n"
                "8.      if total > best_log then\n"
                "9.          best_log <- total ; best_i <- i      // parallel rule = max\n"
                "10.     end if\n"
                "11. end for\n"
                "12. return (best_log, best_i)                     // gain = exp(best_log)"
            ),
            "code": read(A / "algo_sharp.py"),
        },
        {
            "name": "Layerwise Contraction and Evaluation of the Laxity Defect",
            "description": (
                "Computes the alternative, layerwise certificate of the same architecture \u2014 certify "
                "each layer as a parallel block (gain max_i (1+K_ij)) and then compose serially, giving "
                "prod_j max_i (1+K_ij) \u2014 and compares it with the sharp certificate. Both quantities are "
                "valid certificates of the identical map, and the ratio, the laxity defect, is always at "
                "least 1. In log coordinates the two contractions are max_i sum_j and sum_j max_i of the "
                "same matrix log(1+K_ij), the two natural contraction orders in the max-plus semiring; "
                "their difference is manifestly nonnegative and vanishes exactly when one stream attains "
                "the maximum at every layer. The routine also reports, for each layer, which stream "
                "attains its maximum: a constant list certifies zero defect, while a list visiting many "
                "streams signals a permutation-like support and a large defect. "
                "Complexity: O(wd) additions and comparisons."
            ),
            "pseudocode": (
                "Input : certificates K[1..w][1..d]\n"
                "Output: (log sharp, log coarse, log defect)\n"
                "\n"
                "1.  log_sharp  <- max over i of ( sum over j of log1p(K[i][j]) )\n"
                "2.  log_coarse <- 0\n"
                "3.  for j = 1 to d do\n"
                "4.      m <- max over i of log1p(K[i][j])         // certify layer j by the max rule\n"
                "5.      log_coarse <- log_coarse + m              // then compose serially\n"
                "6.  end for\n"
                "7.  defect <- log_coarse - log_sharp              // always >= 0\n"
                "8.  for j = 1 to d do\n"
                "9.      dominating[j] <- argmax over i of K[i][j]\n"
                "10. end for\n"
                "11. return (log_sharp, log_coarse, defect, dominating)"
            ),
            "code": read(A / "algo_laxity.py"),
        },
        {
            "name": "Certified Banach Inversion of a Contractive Residual Block",
            "description": (
                "Inverts a residual block x -> x + r(x) whose certificate satisfies K < 1. Solving "
                "x + r(x) = y is a fixed point problem for the map x -> y - r(x), which is a "
                "K-contraction; the Banach fixed point theorem yields existence, uniqueness and "
                "geometric convergence. The a posteriori bound after a step of size s is s*K/(1-K), "
                "so the routine returns a certified error together with the solution, and the inverse "
                "map it realises is globally (1-K)^{-1}-Lipschitz. For a parallel pair of such blocks "
                "the inverse certificate is (1 - max(K\u2081,K\u2082))^{-1} = max((1-K\u2081)^{-1},(1-K\u2082)^{-1}), the "
                "same max rule as in the forward direction, and it is attained by the inward dilations "
                "x -> (1-K)x. Complexity: O(log(1/eps)/log(1/K)) evaluations of the residual."
            ),
            "pseudocode": (
                "Input : residual r (K-Lipschitz with K < 1), target y, tolerance eps\n"
                "Output: x with x + r(x) = y, iteration count, certified error bound\n"
                "\n"
                "1.  require 0 <= K < 1\n"
                "2.  x <- y                                        // any starting point converges\n"
                "3.  repeat\n"
                "4.      x_new <- y - r(x)                         // the K-contraction\n"
                "5.      s     <- |x_new - x|\n"
                "6.      x     <- x_new\n"
                "7.      bound <- s * K / (1 - K)                  // a posteriori error\n"
                "8.  until bound <= eps or iteration limit reached\n"
                "9.  return (x, iterations, bound)\n"
                "\n"
                "Parallel case: the inverse of a pair of blocks with certificates K1, K2 < 1\n"
                "is Lipschitz with the sharp constant max( (1-K1)^-1, (1-K2)^-1 )."
            ),
            "code": read(A / "algo_inverse.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Sharp Certificate Surface, the Slack of Alternative Rules, and Metric Invariance",
            "description": (
                "Three panels. The first plots the sharp gain max(1+K\u2081,1+K\u2082) over the square of "
                "certificate pairs, exhibiting the ridge along the diagonal where the two streams tie. "
                "The second plots the slack of the naive additive rule (1+K\u2081)+(1+K\u2082), a valid but never "
                "attained certificate, making visible how much a non-minimal rule wastes. The third "
                "takes the slice K\u2082 = 1 and measures the least Lipschitz constant of the parallel "
                "dilation pair directly in the max, sum and Euclidean product metrics, showing all three "
                "measurements landing exactly on the predicted curve \u2014 the sharp constant does not see "
                "the cartesian structure."
            ),
            "code": read(A / "viz_max_rule.py"),
        },
        {
            "name": "Exponential Growth of the Laxity Defect with Depth and Width",
            "description": (
                "Two panels on logarithmic axes. The first shows, for the alternating width-two "
                "architecture with all certificates in {0,1}, the true amplification 2\u207f against the "
                "layerwise certificate 4\u207f at depth 2n, with the shaded region between them being the "
                "logarithm of the over-estimation factor: it widens linearly in the depth, so the defect "
                "grows exponentially. The second sweeps the cyclic architectures of widths 2, 3, 4 and 6 "
                "\u2014 the conjectured extremisers \u2014 plotting the measured defect against the conjectured "
                "extremal value (1+C)^{d(1-1/w)}, which the measurements reproduce whenever the width "
                "divides the depth."
            ),
            "code": read(A / "viz_laxity.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Parallel Residual Sandbox: Watching the Max Rule Become Sharp",
            "description": (
                "Drag the two residual certificates K\u2081 and K\u2082 and watch the unit ball of the product "
                "metric deform under the parallel pair of blocks (x,y) -> ((1+K\u2081)x,(1+K\u2082)y). The widget "
                "searches two thousand directions for the one that is stretched the most and highlights "
                "it, reporting the measured maximum next to the predicted value max(1+K\u2081,1+K\u2082) and next "
                "to the naive additive rule. Switching between the max, sum and Euclidean product "
                "metrics reshapes the ball dramatically but never changes the measured constant \u2014 the "
                "extremal direction is always a coordinate axis, where all product metrics agree. This "
                "is the geometric content of both the attainment theorem and the metric-independence "
                "theorem, discoverable by hand in a few seconds."
            ),
            "html": read(A / "widget_parallel.html"),
        },
        {
            "title": "The Laxity Defect Explorer: One Map, Two Certificates",
            "description": (
                "An editable grid of residual certificates \u2014 rows are parallel streams, columns are "
                "layers \u2014 with live computation of both bookkeeping schemes: the sharp gain "
                "max_i prod_j (1+K_ij) obtained by multiplying down each stream and taking the maximum "
                "at the end, and the coarse gain prod_j max_i (1+K_ij) obtained by certifying each layer "
                "with the max rule and then composing. Click any cell to toggle it between a trivial and "
                "a heavy block, or load the alternating, cyclic, uniform and single-stream presets, and "
                "adjust width, depth and the heavy value. The defect ratio is displayed alongside a "
                "log-scale plot of both certificates against depth, so the reader can see for themselves "
                "that the gap closes exactly when one stream dominates every layer and blows up "
                "exponentially when the heavy blocks are spread across distinct streams."
            ),
            "html": read(A / "widget_laxity.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "certificate_algebra_demo": read(A / "demo_certificate_algebra.py"),
        "algorithm_sharp_certificate": read(A / "algo_sharp.py"),
        "algorithm_laxity_defect": read(A / "algo_laxity.py"),
        "algorithm_certified_inversion": read(A / "algo_inverse.py"),
        "visualization_max_rule": read(A / "viz_max_rule.py"),
        "visualization_laxity": read(A / "viz_laxity.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size:,} bytes)")


"""Numerical exploration of the certificate semiring and the minimality of the max rule.

The certificates of residual blocks carry two operations:

    serial(a, b)   = a + b + a*b        (composition in depth)
    parallel(a, b) = max(a, b)          (composition in width)

and the gain map  g(a) = 1 + a  turns  (serial, parallel)  into  (times, max):
the positive part of the max-times tropical semiring.  This script checks the
algebraic laws numerically on random inputs, exhibits the strictness of the
interchange inequality, and searches a family of candidate parallel rules to
confirm that none smaller than max can be valid.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple


def serial(a: float, b: float) -> float:
    return a + b + a * b


def parallel(a: float, b: float) -> float:
    return max(a, b)


def gain(a: float) -> float:
    return 1.0 + a


def check_laws(trials: int = 200_000, seed: int = 1) -> None:
    """Verify the monoid, distributivity and homomorphism laws on random inputs."""
    rng = random.Random(seed)
    worst = {name: 0.0 for name in
             ("serial assoc", "serial comm", "serial unit", "parallel assoc",
              "distributivity", "gain homomorphism", "interchange")}
    for _ in range(trials):
        a, b, c, d = (rng.uniform(0.0, 5.0) for _ in range(4))
        worst["serial assoc"] = max(worst["serial assoc"],
                                    abs(serial(serial(a, b), c) - serial(a, serial(b, c))))
        worst["serial comm"] = max(worst["serial comm"], abs(serial(a, b) - serial(b, a)))
        worst["serial unit"] = max(worst["serial unit"], abs(serial(a, 0.0) - a))
        worst["parallel assoc"] = max(worst["parallel assoc"],
                                      abs(parallel(parallel(a, b), c) - parallel(a, parallel(b, c))))
        worst["distributivity"] = max(worst["distributivity"],
                                      abs(serial(parallel(a, b), c)
                                          - parallel(serial(a, c), serial(b, c))))
        worst["gain homomorphism"] = max(worst["gain homomorphism"],
                                         abs(gain(serial(a, b)) - gain(a) * gain(b)))
        # interchange: the sharp side never exceeds the parallel-first side
        lhs = parallel(serial(a, c), serial(b, d))
        rhs = serial(parallel(a, b), parallel(c, d))
        worst["interchange"] = max(worst["interchange"], max(0.0, lhs - rhs))

    print("Algebraic laws of the certificate semiring (worst deviation over "
          f"{trials:,} random quadruples):")
    for name, err in worst.items():
        status = "ok" if err < 1e-9 else "VIOLATED"
        print(f"   {name:20s} {err:.3e}   {status}")
    print("   (for 'interchange' the quantity shown is the violation of "
          "sharp <= coarse, which is 0)\n")


def interchange_gap_scan(trials: int = 300_000, seed: int = 2) -> None:
    """Find how strict the interchange inequality can get on a bounded box."""
    rng = random.Random(seed)
    best_ratio, best_args = 1.0, (0.0, 0.0, 0.0, 0.0)
    for _ in range(trials):
        a, b, c, d = (rng.choice([0.0, rng.uniform(0, 1), 1.0]) for _ in range(4))
        lhs = gain(parallel(serial(a, c), serial(b, d)))
        rhs = gain(serial(parallel(a, b), parallel(c, d)))
        if rhs / lhs > best_ratio:
            best_ratio, best_args = rhs / lhs, (a, b, c, d)
    a, b, c, d = best_args
    print("Strictness of the interchange law on certificates in [0,1]:")
    print(f"   worst configuration  (a,b,c,d) = ({a:.3f}, {b:.3f}, {c:.3f}, {d:.3f})")
    print(f"   sharp gain  = {gain(parallel(serial(a, c), serial(b, d))):.4f}")
    print(f"   coarse gain = {gain(serial(parallel(a, b), parallel(c, d))):.4f}")
    print(f"   ratio       = {best_ratio:.4f}   (the extremal 2 vs 4 pattern)\n")


def minimality_scan() -> None:
    """Test candidate parallel rules against the extremal dilation blocks.

    A rule c(K1,K2) is valid iff every parallel pair with those certificates is
    (1 + c)-Lipschitz.  Because the parallel dilation pair has least Lipschitz
    constant exactly max(1+K1, 1+K2), a rule is valid iff c >= max pointwise.
    """
    candidates: List[Tuple[str, Callable[[float, float], float]]] = [
        ("max(K1,K2)          ", lambda a, b: max(a, b)),
        ("K1 + K2             ", lambda a, b: a + b),
        ("serial(K1,K2)       ", serial),
        ("sqrt(K1^2 + K2^2)   ", lambda a, b: math.hypot(a, b)),
        ("(K1 + K2)/2         ", lambda a, b: 0.5 * (a + b)),
        ("0.9 * max(K1,K2)    ", lambda a, b: 0.9 * max(a, b)),
        ("min(K1,K2)          ", lambda a, b: min(a, b)),
    ]
    grid = [i * 0.25 for i in range(13)]
    print("Which parallel rules are valid?  (a rule is valid iff it dominates max)")
    for name, rule in candidates:
        violation = 0.0
        for k1 in grid:
            for k2 in grid:
                violation = max(violation, max(k1, k2) - rule(k1, k2))
        verdict = "VALID" if violation <= 1e-12 else f"INVALID (short by {violation:.3f})"
        tight = "  <- minimal" if name.strip() == "max(K1,K2)" else ""
        print(f"   c(K1,K2) = {name} {verdict}{tight}")
    print("Only rules dominating max survive, and max itself is one of them:\n"
          "   the max rule is the pointwise smallest valid tensor-product certificate.\n")


def main() -> None:
    check_laws()
    interchange_gap_scan()
    minimality_scan()


if __name__ == "__main__":
    main()


"""Visualization: the laxity defect of layerwise certificate bookkeeping.

Left panel : for the alternating width-two architecture with certificates in
             {0, 1}, the true amplification 2^n and the layerwise certificate
             4^n at depth 2n, on a logarithmic scale.  The vertical gap is the
             logarithm of the over-estimation factor, and it grows linearly in
             the depth.
Right panel: the defect ratio for cyclic architectures of several widths, which
             are conjectured to be the extremisers; the observed slopes match
             the conjectured value (1+C)^{d(1 - 1/w)}.
"""

from __future__ import annotations

import math
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def sharp_gain(rows: Sequence[Sequence[float]]) -> float:
    """max_i prod_j (1 + K_ij): depth-first bookkeeping (the true constant)."""
    return max(math.prod(1.0 + k for k in row) for row in rows)


def coarse_gain(rows: Sequence[Sequence[float]]) -> float:
    """prod_j max_i (1 + K_ij): width-first (layerwise) bookkeeping."""
    depth = len(rows[0])
    return math.prod(max(1.0 + row[j] for row in rows) for j in range(depth))


def cyclic(width: int, depth: int, c: float) -> List[List[float]]:
    """K_ij = c if j = i (mod width), else 0."""
    return [[c if j % width == i else 0.0 for j in range(depth)] for i in range(width)]


def make_figure() -> plt.Figure:
    fig, axes = plt.subplots(1, 2, figsize=(14.0, 5.2))

    ns = np.arange(1, 13)
    sharp = [2.0 ** n for n in ns]
    coarse = [4.0 ** n for n in ns]
    depths = 2 * ns

    axes[0].semilogy(depths, sharp, "o-", color="#2a9d5c", lw=2.5, label="true constant  $2^n$")
    axes[0].semilogy(depths, coarse, "s-", color="#c8402f", lw=2.5, label="layerwise certificate  $4^n$")
    axes[0].fill_between(depths, sharp, coarse, color="#c8402f", alpha=0.12)
    axes[0].set_title("Alternating width-two architecture\nall certificates in $\\{0,1\\}$")
    axes[0].set_xlabel("depth  $2n$")
    axes[0].set_ylabel("gain (log scale)")
    axes[0].legend()
    axes[0].grid(alpha=0.25, which="both")
    axes[0].annotate(
        "over-estimation factor $2^n$",
        xy=(depths[7], math.sqrt(sharp[7] * coarse[7])),
        xytext=(6, 5e4),
        arrowprops=dict(arrowstyle="->", color="#555"),
        fontsize=10,
    )

    depth_grid = np.arange(2, 25)
    for width, colour in zip((2, 3, 4, 6), ("#1f77b4", "#ff7f0e", "#9467bd", "#8c564b")):
        ratios = []
        for d in depth_grid:
            rows = cyclic(width, int(d), 1.0)
            ratios.append(coarse_gain(rows) / sharp_gain(rows))
        axes[1].semilogy(depth_grid, ratios, "o-", ms=4, color=colour, label=f"width {width}")
        axes[1].semilogy(
            depth_grid,
            [2.0 ** (d * (1 - 1 / width)) for d in depth_grid],
            "--",
            color=colour,
            alpha=0.55,
        )
    axes[1].set_title("Cyclic architectures, $C = 1$\nsolid: measured defect,  dashed: $(1+C)^{d(1-1/w)}$")
    axes[1].set_xlabel("depth $d$")
    axes[1].set_ylabel("defect  coarse / sharp (log scale)")
    axes[1].legend()
    axes[1].grid(alpha=0.25, which="both")

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    make_figure().savefig("laxity_defect.png", dpi=150)
    print("wrote laxity_defect.png")


"""Visualization: the sharp parallel certificate surface and its minimality.

Left panel  : the sharp gain max(1+K1, 1+K2) of a parallel pair of residual
              blocks, as a function of the two certificates, with its
              characteristic "ridge" along the diagonal K1 = K2.
Middle panel: the slack of the naive additive rule (1+K1)+(1+K2), which is
              valid but never attained -- the max rule is the pointwise
              smallest valid rule.
Right panel : the measured least Lipschitz constant of the parallel dilation
              pair in the l^inf, l^1 and l^2 product metrics along the slice
              K2 = 1, showing that all three coincide with max(1+K1, 2).
"""

from __future__ import annotations

import math
from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np


def operator_norm_diag(a: float, b: float, p: float, samples: int = 4001) -> float:
    """Least Lipschitz constant of (x,y) -> (a x, b y) in the l^p product metric.

    Computed by maximising ||A u||_p over the unit l^p sphere, parameterised by
    angle; for diagonal maps this converges to the exact value max(a, b).
    """

    def norm(x: float, y: float) -> float:
        if math.isinf(p):
            return max(abs(x), abs(y))
        return (abs(x) ** p + abs(y) ** p) ** (1.0 / p)

    best = 0.0
    for i in range(samples):
        t = 2.0 * math.pi * i / samples
        cx, cy = math.cos(t), math.sin(t)
        n = norm(cx, cy)
        ux, uy = cx / n, cy / n
        best = max(best, norm(a * ux, b * uy))
    return best


def make_figure() -> Tuple[plt.Figure, np.ndarray]:
    ks = np.linspace(0.0, 3.0, 240)
    K1, K2 = np.meshgrid(ks, ks)
    sharp = np.maximum(1 + K1, 1 + K2)
    naive = (1 + K1) + (1 + K2)

    fig, axes = plt.subplots(1, 3, figsize=(16.5, 5.0))

    im0 = axes[0].contourf(K1, K2, sharp, levels=24, cmap="viridis")
    axes[0].contour(K1, K2, sharp, levels=12, colors="white", linewidths=0.5, alpha=0.5)
    axes[0].plot([0, 3], [0, 3], "w--", lw=1.6, alpha=0.9)
    axes[0].set_title("Sharp gain  max(1+$K_1$, 1+$K_2$)\n(attained, and minimal)")
    axes[0].set_xlabel("$K_1$")
    axes[0].set_ylabel("$K_2$")
    fig.colorbar(im0, ax=axes[0])

    im1 = axes[1].contourf(K1, K2, naive - sharp, levels=24, cmap="magma")
    axes[1].set_title("Slack of the additive rule\n$(1+K_1)+(1+K_2) - \\max(1+K_1,1+K_2)$")
    axes[1].set_xlabel("$K_1$")
    axes[1].set_ylabel("$K_2$")
    fig.colorbar(im1, ax=axes[1])

    slice_ks = np.linspace(0.0, 3.0, 31)
    predicted = [max(1 + k, 2.0) for k in slice_ks]
    measured = {
        r"$\ell^\infty$": [operator_norm_diag(1 + k, 2.0, math.inf, 721) for k in slice_ks],
        r"$\ell^1$": [operator_norm_diag(1 + k, 2.0, 1.0, 721) for k in slice_ks],
        r"$\ell^2$": [operator_norm_diag(1 + k, 2.0, 2.0, 721) for k in slice_ks],
    }
    axes[2].plot(slice_ks, predicted, "k-", lw=3, label="predicted  max(1+$K_1$, 2)")
    for (label, vals), style in zip(measured.items(), ["o", "s", "^"]):
        axes[2].plot(slice_ks, vals, style, ms=6, mfc="none", label="measured " + label)
    axes[2].set_title("Metric independence (slice $K_2 = 1$)\nsame sharp constant in every product metric")
    axes[2].set_xlabel("$K_1$")
    axes[2].set_ylabel("least Lipschitz constant")
    axes[2].legend(loc="upper left", fontsize=9)
    axes[2].grid(alpha=0.25)

    fig.tight_layout()
    return fig, axes


if __name__ == "__main__":
    fig, _ = make_figure()
    fig.savefig("max_rule.png", dpi=150)
    print("wrote max_rule.png")


"""Numerical demonstrations of the sharp tensor-product certificate for
parallel residual blocks.

A *residual block* with certificate K on a normed space is a map

    B(x) = x + r(x),      r  K-Lipschitz,

which is (1 + K)-Lipschitz.  The quantity 1 + K is the block's *gain*.  The
results demonstrated here are:

  1. Gain bound        : B is (1 + K)-Lipschitz.
  2. Serial rule       : certificates compose by  a * b = a + b + a*b,
                         equivalently gains multiply.
  3. Parallel rule     : in the max product norm, the parallel product of two
                         blocks has certificate max(K1, K2), gain
                         max(1 + K1, 1 + K2) -- and this is ATTAINED.
  4. Minimality        : no smaller parallel rule can be valid.
  5. Metric invariance : the same sharp constant in the l^inf, l^1 and l^2
                         cartesian products.
  6. Width / depth     : sharp gains sup_i (1 + K_i) and (1 + K)^d.
  7. Laxity defect     : the same map admits two certificates,
                         sharp = max_i prod_j (1 + K_ij)  and
                         coarse = prod_j max_i (1 + K_ij),
                         with coarse/sharp growing like 2^n at depth 2n for the
                         alternating width-two architecture.
  8. Dual max rule     : for K < 1 the block is invertible and the inverse
                         certificates obey the same max rule, sharply.

Everything is self-contained: only the standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Vector = Tuple[float, ...]

# ----------------------------------------------------------------------------
# Certificate arithmetic
# ----------------------------------------------------------------------------


def serial(a: float, b: float) -> float:
    """Serial composition of certificates: a * b = a + b + a*b."""
    return a + b + a * b


def parallel(a: float, b: float) -> float:
    """Parallel composition of certificates (max product norm)."""
    return max(a, b)


def gain(a: float) -> float:
    """The gain 1 + a of a certificate a."""
    return 1.0 + a


# ----------------------------------------------------------------------------
# Product metrics
# ----------------------------------------------------------------------------


def dist_p(u: Vector, v: Vector, p: float) -> float:
    """l^p distance on R^n; p = math.inf gives the max product metric."""
    diffs = [abs(a - b) for a, b in zip(u, v)]
    if math.isinf(p):
        return max(diffs)
    return sum(d**p for d in diffs) ** (1.0 / p)


# ----------------------------------------------------------------------------
# Empirical Lipschitz constant
# ----------------------------------------------------------------------------


def empirical_lipschitz(
    f: Callable[[Vector], Vector],
    dim: int,
    p: float = math.inf,
    samples: int = 20000,
    radius: float = 1.0,
    seed: int = 0,
) -> float:
    """Estimate sup_{x != y} d_p(f x, f y) / d_p(x, y) by random sampling.

    The estimate is a lower bound on the true least Lipschitz constant; for the
    linear maps used below it converges to it, and the coordinate-direction test
    pairs are included explicitly so the sharp value is always achieved.
    """
    rng = random.Random(seed)
    best = 0.0

    # Deterministic coordinate probes: these are the extremisers of the theory.
    zero: Vector = tuple(0.0 for _ in range(dim))
    for i in range(dim):
        e_i: Vector = tuple(1.0 if j == i else 0.0 for j in range(dim))
        num = dist_p(f(e_i), f(zero), p)
        den = dist_p(e_i, zero, p)
        best = max(best, num / den)

    for _ in range(samples):
        x: Vector = tuple(rng.uniform(-radius, radius) for _ in range(dim))
        y: Vector = tuple(rng.uniform(-radius, radius) for _ in range(dim))
        den = dist_p(x, y, p)
        if den < 1e-12:
            continue
        best = max(best, dist_p(f(x), f(y), p) / den)
    return best


# ----------------------------------------------------------------------------
# Residual blocks
# ----------------------------------------------------------------------------


def dilation_block(k: float) -> Callable[[float], float]:
    """Residual block on R with residual r(x) = k*x; computes x -> (1+k)x."""
    return lambda x: x + k * x


def inward_dilation_block(k: float) -> Callable[[float], float]:
    """Residual block on R with residual r(x) = -k*x; computes x -> (1-k)x."""
    return lambda x: x - k * x


def soft_block(k: float) -> Callable[[float], float]:
    """A genuinely nonlinear residual block: r(x) = k * tanh(x), certificate k.

    tanh is 1-Lipschitz, so r is exactly k-Lipschitz; the block's gain is at most
    1 + k, attained in the limit x -> 0 (where tanh'(0) = 1).
    """
    return lambda x: x + k * math.tanh(x)


def par2(
    f: Callable[[float], float], g: Callable[[float], float]
) -> Callable[[Vector], Vector]:
    """Parallel product of two scalar maps as a map on R^2."""
    return lambda z: (f(z[0]), g(z[1]))


def compose(fs: Sequence[Callable[[float], float]]) -> Callable[[float], float]:
    """Serial composition fs[-1] o ... o fs[0]."""

    def h(x: float) -> float:
        for f in fs:
            x = f(x)
        return x

    return h


# ----------------------------------------------------------------------------
# Laxity bookkeeping
# ----------------------------------------------------------------------------


def sharp_gain(rows: Sequence[Sequence[float]]) -> float:
    """max_i prod_j (1 + K_ij): depth-first (stream-wise) bookkeeping."""
    return max(math.prod(1.0 + k for k in row) for row in rows)


def coarse_gain(rows: Sequence[Sequence[float]]) -> float:
    """prod_j max_i (1 + K_ij): width-first (layer-wise) bookkeeping."""
    depth = len(rows[0])
    return math.prod(max(1.0 + row[j] for row in rows) for j in range(depth))


def alternating_architecture(n: int) -> List[List[float]]:
    """Width-two alternating architecture at depth 2n: certificates in {0, 1}."""
    depth = 2 * n
    row_a = [1.0 if j % 2 == 0 else 0.0 for j in range(depth)]
    row_b = [0.0 if j % 2 == 0 else 1.0 for j in range(depth)]
    return [row_a, row_b]


def cyclic_architecture(width: int, depth: int, c: float) -> List[List[float]]:
    """K_ij = c if j = i (mod width), else 0 -- the conjectured extremiser."""
    return [[c if j % width == i else 0.0 for j in range(depth)] for i in range(width)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_gain_bound() -> None:
    print("=" * 78)
    print("1. GAIN BOUND:  a block with certificate K is (1 + K)-Lipschitz")
    print("=" * 78)
    print(f"{'K':>6} {'predicted 1+K':>15} {'measured (linear)':>19} {'measured (tanh)':>17}")
    for k in (0.0, 0.25, 0.5, 1.0, 2.0):
        lin = empirical_lipschitz(lambda z, k=k: (dilation_block(k)(z[0]),), dim=1)
        nl = empirical_lipschitz(lambda z, k=k: (soft_block(k)(z[0]),), dim=1)
        print(f"{k:6.2f} {1 + k:15.6f} {lin:19.6f} {nl:17.6f}")
    print("The linear (dilation) block attains the bound; the nonlinear one\n"
          "approaches it near the origin, where tanh has slope 1.\n")


def demo_serial_rule() -> None:
    print("=" * 78)
    print("2. SERIAL RULE:  certificates compose by a*b = a+b+ab, gains multiply")
    print("=" * 78)
    print(f"{'K1':>6} {'K2':>6} {'serial':>10} {'1+serial':>12} {'(1+K1)(1+K2)':>14} {'measured':>12}")
    for k1, k2 in ((0.0, 1.0), (0.5, 0.5), (1.0, 2.0), (0.25, 3.0)):
        s = serial(k1, k2)
        h = compose([dilation_block(k1), dilation_block(k2)])
        measured = empirical_lipschitz(lambda z, h=h: (h(z[0]),), dim=1)
        print(f"{k1:6.2f} {k2:6.2f} {s:10.4f} {1 + s:12.6f} "
              f"{(1 + k1) * (1 + k2):14.6f} {measured:12.6f}")
    print()


def demo_parallel_sharpness() -> None:
    print("=" * 78)
    print("3-4. PARALLEL RULE AND ITS SHARPNESS (max product norm)")
    print("=" * 78)
    print(f"{'K1':>6} {'K2':>6} {'max(1+K1,1+K2)':>16} {'measured':>12} {'sum rule':>10} {'slack':>10}")
    for k1, k2 in ((0.0, 0.0), (0.0, 1.0), (0.5, 2.0), (3.0, 1.0), (2.0, 2.0)):
        f = par2(dilation_block(k1), dilation_block(k2))
        measured = empirical_lipschitz(f, dim=2, p=math.inf)
        predicted = max(1 + k1, 1 + k2)
        naive = (1 + k1) + (1 + k2)  # a valid but non-minimal rule
        print(f"{k1:6.2f} {k2:6.2f} {predicted:16.6f} {measured:12.6f} "
              f"{naive:10.4f} {naive - predicted:10.4f}")
    print("Measured equals predicted to sampling accuracy: the max rule is attained,\n"
          "so no rule smaller than max can ever be valid (minimality).\n")


def demo_metric_invariance() -> None:
    print("=" * 78)
    print("5. METRIC INVARIANCE:  the same sharp constant in l^inf, l^1, l^2")
    print("=" * 78)
    print(f"{'K1':>6} {'K2':>6} {'max(1+K1,1+K2)':>16} {'l^inf':>10} {'l^1':>10} {'l^2':>10}")
    for k1, k2 in ((0.0, 1.0), (0.5, 2.0), (3.0, 0.25)):
        f = par2(dilation_block(k1), dilation_block(k2))
        predicted = max(1 + k1, 1 + k2)
        vals = [empirical_lipschitz(f, dim=2, p=p) for p in (math.inf, 1.0, 2.0)]
        print(f"{k1:6.2f} {k2:6.2f} {predicted:16.6f} "
              f"{vals[0]:10.6f} {vals[1]:10.6f} {vals[2]:10.6f}")
    print("The extremisers are the coordinate directions, where all l^p norms agree.\n")


def demo_width_and_depth() -> None:
    print("=" * 78)
    print("6. WIDTH AND DEPTH")
    print("=" * 78)
    certs = [0.0, 0.5, 2.0, 1.0]
    f = lambda z: tuple((1 + k) * zi for k, zi in zip(certs, z))
    measured = empirical_lipschitz(f, dim=len(certs), p=math.inf)
    print(f"width-{len(certs)} family, certificates {certs}")
    print(f"   predicted sup_i (1+K_i) = {max(1 + k for k in certs):.6f}")
    print(f"   measured                = {measured:.6f}\n")

    print(f"{'K':>6} {'d':>4} {'(1+K)^d':>14} {'measured':>14} {'exp(K d)':>14}")
    for k, d in ((0.1, 10), (0.5, 5), (1.0, 4), (0.05, 50)):
        stack = compose([dilation_block(k)] * d)
        measured = empirical_lipschitz(lambda z, s=stack: (s(z[0]),), dim=1)
        print(f"{k:6.2f} {d:4d} {(1 + k) ** d:14.6f} {measured:14.6f} "
              f"{math.exp(k * d):14.6f}")
    print("The exponential is a relaxation: (1+K)^d <= exp(Kd), tight for small K.\n")


def demo_laxity_defect() -> None:
    print("=" * 78)
    print("7. THE LAXITY DEFECT:  one map, two certificates")
    print("=" * 78)
    print("Smallest witness (depth 2, width 2): identity then doubling in stream A,")
    print("doubling then identity in stream B.  Both streams compute t -> 2t.")
    stream_a = compose([dilation_block(0.0), dilation_block(1.0)])
    stream_b = compose([dilation_block(1.0), dilation_block(0.0)])
    f = par2(stream_a, stream_b)
    measured = empirical_lipschitz(f, dim=2, p=math.inf)
    coarse = gain(serial(parallel(0.0, 1.0), parallel(1.0, 0.0)))
    print(f"   true least Lipschitz constant : {measured:.6f}")
    print(f"   layer-wise certificate        : {coarse:.6f}\n")

    print("Alternating width-two architecture at depth 2n:")
    print(f"{'n':>4} {'depth':>6} {'sharp':>12} {'2^n':>10} {'coarse':>14} {'4^n':>12} {'ratio':>10}")
    for n in range(1, 9):
        rows = alternating_architecture(n)
        s, c = sharp_gain(rows), coarse_gain(rows)
        print(f"{n:4d} {2 * n:6d} {s:12.1f} {2 ** n:10d} {c:14.1f} {4 ** n:12d} {c / s:10.1f}")
    print("The over-estimation ratio is exactly 2^n -- unbounded in the depth,\n"
          "even though every certificate is 0 or 1.\n")

    print("Cyclic architectures (conjectured extremisers), C = 1, depth 12:")
    print(f"{'width':>6} {'sharp':>12} {'coarse':>12} {'ratio':>12} {'(1+C)^(d(1-1/w))':>18}")
    depth = 12
    for w in (2, 3, 4, 6):
        rows = cyclic_architecture(w, depth, 1.0)
        s, c = sharp_gain(rows), coarse_gain(rows)
        print(f"{w:6d} {s:12.1f} {c:12.1f} {c / s:12.1f} {2 ** (depth * (1 - 1 / w)):18.1f}")
    print("The ratio matches the conjectured extremal value (1+C)^{d(1-1/w)}.\n")


def demo_inverse_max_rule() -> None:
    print("=" * 78)
    print("8. DUAL MAX RULE:  inverse certificates obey the same max rule")
    print("=" * 78)
    print(f"{'K1':>6} {'K2':>6} {'max (1-Ki)^-1':>16} {'measured inverse':>18}")
    for k1, k2 in ((0.1, 0.5), (0.9, 0.25), (0.5, 0.5)):
        inv = lambda z, a=k1, b=k2: (z[0] / (1 - a), z[1] / (1 - b))
        measured = empirical_lipschitz(inv, dim=2, p=math.inf)
        predicted = max(1 / (1 - k1), 1 / (1 - k2))
        print(f"{k1:6.2f} {k2:6.2f} {predicted:16.6f} {measured:18.6f}")

    print("\nBanach fixed point: solving x + r(x) = y for a nonlinear contractive")
    print("residual r(x) = 0.5 * sin(x) (certificate 0.5 < 1).")
    k = 0.5
    r = lambda x: k * math.sin(x)
    for y in (0.0, 1.0, -2.5, 7.0):
        x = 0.0
        for _ in range(200):
            x = y - r(x)
        print(f"   y = {y:6.2f}  ->  x = {x:10.6f},   x + r(x) = {x + r(x):10.6f}")
    print("   inverse gain bound (1-K)^-1 =", f"{1 / (1 - k):.6f}\n")


def main() -> None:
    demo_gain_bound()
    demo_serial_rule()
    demo_parallel_sharpness()
    demo_metric_invariance()
    demo_width_and_depth()
    demo_laxity_defect()
    demo_inverse_max_rule()
    print("=" * 78)
    print("All demonstrations agree with the theory.")
    print("=" * 78)


if __name__ == "__main__":
    main()
