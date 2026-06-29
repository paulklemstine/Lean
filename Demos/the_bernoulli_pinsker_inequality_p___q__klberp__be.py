from __future__ import annotations
import math
from typing import Sequence


def kl_ber(p: float, q: float) -> float:
    """KL divergence between Bernoulli(p) and Bernoulli(q), p, q in (0,1)."""
    return p * math.log(p / q) + (1 - p) * math.log((1 - p) / (1 - q))


def bernoulli_gap(p: float, q: float) -> float:
    """g(q) = KL(Ber p || Ber q) - 2(p-q)^2; provably >= 0."""
    return kl_ber(p, q) - 2.0 * (p - q) ** 2


def gap_derivative(p: float, q: float) -> float:
    """Closed-form g'(q) = (q-p)(1-2q)^2 / (q(1-q))."""
    return (q - p) * (1 - 2 * q) ** 2 / (q * (1 - q))


def verify(p: float, grid: Sequence[float], h: float = 1e-6) -> bool:
    for q in grid:
        assert bernoulli_gap(p, q) >= -1e-9
        num = (bernoulli_gap(p, q + h) - bernoulli_gap(p, q - h)) / (2 * h)
        assert abs(gap_derivative(p, q) - num) < 1e-4
    return True


from __future__ import annotations
import math
from typing import Sequence, Tuple


def kl_sandwich(p: Sequence[float], q: Sequence[float]) -> Tuple[float, float, float]:
    """Return (2*TV^2, KL, chi^2) and assert the sandwich chain.

    Requires p, q strictly positive and each summing to 1.
    """
    assert all(pi > 0 for pi in p) and all(qi > 0 for qi in q)
    assert abs(sum(p) - 1.0) < 1e-9 and abs(sum(q) - 1.0) < 1e-9
    kl = sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))
    chi = sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))
    fisher = sum((pi - qi) * (pi - qi) / qi for pi, qi in zip(p, q))
    tv_floor = 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q)) ** 2
    assert abs(chi - fisher) < 1e-9      # chiSquared_eq_fisher
    assert kl >= -1e-12                  # Gibbs
    assert kl <= chi + 1e-9              # bridge
    assert tv_floor <= kl + 1e-9         # Pinsker (conjecture)
    return tv_floor, kl, chi


import json
import os

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def rd(rel):
    with open(os.path.join(root, rel), encoding="utf-8") as f:
        return f.read()


lean = rd("Catalog/Speculative/AutoResearch/FisherInformationMetric.lean")
demo = rd("demo.py")
viz_code = rd("assets/viz_kl_sandwich.py")
interactive_html = rd("assets/interactive.html")
algo_sandwich = rd("assets/algo_kl_sandwich.py")
algo_bernoulli = rd("assets/algo_bernoulli_gap.py")
demo_metric = rd("assets/demo_metric_axioms.py")
future_directions = rd("assets/future_directions.md")

algorithms = [
    {
        "name": "kl_sandwich_evaluator",
        "description": (
            "Given two strictly positive normalized distributions p, q over a finite "
            "index set, computes the three divergences KL(p||q), chi^2(p||q), and "
            "2*TV(p,q)^2, and certifies the proved sandwich 0 <= KL <= chi^2 together "
            "with the conjectured Pinsker floor 2*TV^2 <= KL. The chi^2 value is "
            "computed both directly and as the Fisher quadratic form g_q(p-q, p-q) to "
            "exhibit the identity chiSquared_eq_fisher. Complexity: O(n) arithmetic "
            "operations and O(n) logarithms for n = |index set|; O(1) extra space. The "
            "role in the pipeline is to provide a constant-time-per-coordinate "
            "numerical witness for the formally verified inequalities."
        ),
        "pseudocode": (
            "function KL_SANDWICH(p[1..n], q[1..n]):\n"
            "  require p[i] > 0, q[i] > 0 for all i\n"
            "  require sum(p) == 1 and sum(q) == 1        # normalization\n"
            "  KL <- 0; CHI <- 0; FISH <- 0; L1 <- 0\n"
            "  for i in 1..n:\n"
            "    KL   <- KL   + p[i] * log(p[i] / q[i])\n"
            "    CHI  <- CHI  + (p[i] - q[i])^2 / q[i]\n"
            "    FISH <- FISH + (p[i]-q[i]) * (p[i]-q[i]) / q[i]   # g_q(p-q,p-q)\n"
            "    L1   <- L1   + |p[i] - q[i]|\n"
            "  TVfloor <- 0.5 * L1 * L1                   # = 2*TV^2\n"
            "  assert CHI ~= FISH                         # chiSquared_eq_fisher\n"
            "  assert 0 <= KL                             # Gibbs\n"
            "  assert KL <= CHI                           # bridge\n"
            "  assert TVfloor <= KL                       # Pinsker (conjecture)\n"
            "  return (TVfloor, KL, CHI)"
        ),
        "code": algo_sandwich,
    },
    {
        "name": "bernoulli_gap_minimizer",
        "description": (
            "Verifies the Bernoulli base case of Pinsker, 2(p-q)^2 <= KL(Ber p||Ber q), "
            "by analyzing the gap function g(q) = KL(Ber p||Ber q) - 2(p-q)^2 through "
            "its closed-form factored derivative g'(q) = (q-p)(1-2q)^2 / (q(1-q)). "
            "Because the middle factor (1-2q)^2 is a perfect square and the denominator "
            "is positive on (0,1), sign(g'(q)) = sign(q-p); thus q=p is the unique "
            "global minimizer with g(p)=0, proving g(q) >= 0. The algorithm certifies "
            "non-negativity of the gap on a grid and checks the closed-form derivative "
            "against a central finite difference. Complexity: O(m) for an m-point grid; "
            "O(1) space."
        ),
        "pseudocode": (
            "function BERNOULLI_GAP(p, grid q_1..q_m):\n"
            "  define klBer(p,q) = p*log(p/q) + (1-p)*log((1-p)/(1-q))\n"
            "  define g(q)       = klBer(p,q) - 2*(p-q)^2\n"
            "  define gp(q)      = (q-p)*(1-2q)^2 / (q*(1-q))   # closed form\n"
            "  for q in grid:\n"
            "    assert g(q) >= 0                                # gap non-negative\n"
            "    num <- (g(q+h) - g(q-h)) / (2h)                 # numeric derivative\n"
            "    assert |gp(q) - num| < tol                      # factored form correct\n"
            "    assert sign(gp(q)) == sign(q - p)               # perfect-square argument\n"
            "  assert g(p) == 0                                  # unique minimizer value"
        ),
        "code": algo_bernoulli,
    },
]

demos = [
    {
        "name": "kl_sandwich_random_trials",
        "description": (
            "Draws random strictly-positive normalized distributions and prints, for "
            "each pair, KL, chi^2, and 2*TV^2, confirming 0 <= KL <= chi^2 and the "
            "conjectured floor 2*TV^2 <= KL across thousands of trials; also exhibits "
            "the Bernoulli factored derivative."
        ),
        "code": demo,
    },
    {
        "name": "metric_axiom_checker",
        "description": (
            "Numerically checks the four Riemannian-metric axioms of the Fisher form "
            "(symmetry, additivity, homogeneity, positive-definiteness) on random base "
            "points and tangent vectors."
        ),
        "code": demo_metric,
    },
]

visualizations = [
    {
        "name": "kl_sandwich_and_bernoulli_gap",
        "description": (
            "Plots (1) KL, chi^2 and the Pinsker floor 2*TV^2 along an interpolation "
            "path between two distributions, illustrating the sandwich, and (2) the "
            "Bernoulli gap function with its unique zero at q = p. Requires matplotlib; "
            "writes kl_sandwich.png."
        ),
        "code": viz_code,
    },
]

interactive_demos = [
    {
        "title": "The KL Sandwich Explorer",
        "description": (
            "Interactive widget over two 3-outcome distributions: move the sliders and "
            "watch KL, chi^2 and 2*TV^2 update live, with a real-time check that the "
            "proved chain 0 <= KL <= chi^2 and the conjectured Pinsker floor "
            "2*TV^2 <= KL both hold."
        ),
        "html": interactive_html,
    },
]

package = {
    "title": "Information Geometry of the KL Sandwich: Fisher Metric, \u03c7\u00b2, and the Road to Pinsker",
    "domain": "Novelty",
    "description": (
        "A machine-verified development of the Fisher information metric on the finite "
        "probability simplex, proving it is a genuine Riemannian metric and that it "
        "sandwiches the Kullback\u2013Leibler divergence from above "
        "(0 \u2264 KL \u2264 \u03c7\u00b2 = Fisher form), with the Pinsker lower bound "
        "stated as a precise open conjecture."
    ),
    "authors": ["Aristotle (Harmonic)"],
    "date": "2026-06-11",
    "key_results": [
        "The Fisher information form g_p(v,w) = \u2211 v_i w_i / p_i is a Riemannian metric: symmetric, bilinear, and positive-definite for p > 0.",
        "Exact identity \u03c7\u00b2(p\u2016q) = g_q(p\u2212q, p\u2212q): the Pearson chi-squared divergence is the Fisher quadratic form at the displacement.",
        "Gibbs' inequality 0 \u2264 KL(p\u2016q) for positive normalized distributions.",
        "Bridge theorem KL(p\u2016q) \u2264 \u03c7\u00b2(p\u2016q) = g_q(p\u2212q, p\u2212q), a global (non-infinitesimal) form of 'Fisher metric = Hessian of KL'.",
        "Both KL bounds reduce to the single elementary inequality log y \u2264 y \u2212 1; the upper bound provably requires normalization.",
        "Pinsker's inequality \u00bd(\u2211|p_i\u2212q_i|)\u00b2 \u2264 KL(p\u2016q) stated as an open conjecture, with a factored-derivative strategy g'(q) = (q\u2212p)(1\u22122q)\u00b2/(q(1\u2212q)) for the Bernoulli base case.",
    ],
    "keywords": [
        "information geometry", "Fisher information metric", "Kullback-Leibler divergence",
        "chi-squared divergence", "Gibbs inequality", "Pinsker inequality",
        "statistical manifold", "Riemannian metric", "formal verification",
    ],
    "article": "ARTICLE.md",
    "research_paper": "RESEARCH_PAPER.md",
    "demo": "demo.py",
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": ["Catalog/Speculative/AutoResearch/FisherInformationMetric.lean"],
}

out = os.path.join(root, "PACKAGE.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

# validate
with open(out, encoding="utf-8") as f:
    json.load(f)
print("wrote and validated PACKAGE.json")


from __future__ import annotations
import random
from typing import List, Sequence


def fisher_form(p: Sequence[float], v: Sequence[float], w: Sequence[float]) -> float:
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))


def check(seed: int = 0) -> None:
    rng = random.Random(seed)
    p = [rng.uniform(0.1, 1.0) for _ in range(4)]
    u = [rng.uniform(-1, 1) for _ in range(4)]
    v = [rng.uniform(-1, 1) for _ in range(4)]
    w = [rng.uniform(-1, 1) for _ in range(4)]
    c = rng.uniform(-3, 3)
    assert abs(fisher_form(p, v, w) - fisher_form(p, w, v)) < 1e-9
    add_l = fisher_form(p, [a + b for a, b in zip(u, v)], w)
    assert abs(add_l - (fisher_form(p, u, w) + fisher_form(p, v, w))) < 1e-9
    sm_l = fisher_form(p, [c * x for x in v], w)
    assert abs(sm_l - c * fisher_form(p, v, w)) < 1e-9
    assert fisher_form(p, v, v) >= 0
    assert fisher_form(p, [0.0] * 4, [0.0] * 4) == 0.0
    print("all metric axioms hold")


if __name__ == "__main__":
    check()


"""Visualization: the KL sandwich and the Bernoulli gap function.

Generates two figures:
  (1) KL, chi^2, and 2*TV^2 vs. an interpolation parameter, showing
      2*TV^2 <= KL <= chi^2 (the conjectured floor and the proved ceiling).
  (2) The Bernoulli gap g(q) = KL(Ber p || Ber q) - 2(p-q)^2 with its
      unique zero at q = p.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def kl(p: List[float], q: List[float]) -> float:
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))


def chi2(p: List[float], q: List[float]) -> float:
    return sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))


def tv(p: List[float], q: List[float]) -> float:
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


def kl_ber(p: float, q: float) -> float:
    return p * math.log(p / q) + (1 - p) * math.log((1 - p) / (1 - q))


# Figure 1: sandwich along a path p(t) = (1-t)*base + t*target
base = [0.5, 0.3, 0.2]
target = [0.1, 0.2, 0.7]
ts = [i / 200 for i in range(1, 200)]
kls, chis, tvs = [], [], []
for t in ts:
    p = [(1 - t) * b + t * c for b, c in zip(base, target)]
    q = base
    kls.append(kl(p, q))
    chis.append(chi2(p, q))
    tvs.append(2 * tv(p, q) ** 2)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
axes[0].plot(ts, chis, label=r"$\chi^2(p\|q)$ (proved ceiling)", lw=2)
axes[0].plot(ts, kls, label=r"$KL(p\|q)$", lw=2)
axes[0].plot(ts, tvs, label=r"$2\,TV^2$ (conjectured floor)", lw=2, ls="--")
axes[0].set_xlabel("interpolation parameter t")
axes[0].set_ylabel("divergence")
axes[0].set_title("The KL sandwich")
axes[0].legend()

# Figure 2: Bernoulli gap
p0 = 0.3
qs = [i / 500 for i in range(1, 500)]
gap = [kl_ber(p0, q) - 2 * (p0 - q) ** 2 for q in qs]
axes[1].plot(qs, gap, lw=2)
axes[1].axvline(p0, color="red", ls=":", label=f"q = p = {p0}")
axes[1].axhline(0, color="black", lw=0.8)
axes[1].set_xlabel("q")
axes[1].set_ylabel("g(q) = KL(Ber p || Ber q) - 2(p-q)^2")
axes[1].set_title("Bernoulli gap: unique zero at q = p")
axes[1].legend()

plt.tight_layout()
plt.savefig("kl_sandwich.png", dpi=150)
print("Saved kl_sandwich.png")


"""Numerical demonstrations of the information-geometric KL sandwich.

This script illustrates, with concrete finite distributions, the results
formally verified in the companion Lean development:

    Definitions
        fisherForm(p, v, w) = sum_i v_i * w_i / p_i        (Fisher metric)
        klDiv(p, q)         = sum_i p_i * log(p_i / q_i)    (KL divergence)
        chiSquared(p, q)    = sum_i (p_i - q_i)^2 / q_i     (Pearson chi^2)

    Verified theorems
        fisherForm_symm        : g_p(v, w) = g_p(w, v)
        fisherForm_add_left    : g_p(u+v, w) = g_p(u, w) + g_p(v, w)
        fisherForm_smul_left   : g_p(c*v, w) = c * g_p(v, w)
        fisherForm_nonneg      : 0 <= g_p(v, v)
        fisherForm_eq_zero_iff : g_p(v, v) = 0  iff  v = 0
        chiSquared_eq_fisher   : chi^2(p||q) = g_q(p-q, p-q)
        klDiv_nonneg (Gibbs)   : 0 <= KL(p||q)
        klDiv_le_fisher        : KL(p||q) <= chi^2(p||q) = g_q(p-q, p-q)

    Open conjecture (still a `sorry` in Lean)
        klDiv_ge_half_tv_sq    : (1/2)*(sum_i |p_i - q_i|)^2 <= KL(p||q)   (Pinsker)

Everything below is self-contained: it uses only the Python standard library.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Vector = List[float]


# --------------------------------------------------------------------------
# Core definitions (mirroring the Lean definitions exactly)
# --------------------------------------------------------------------------
def fisher_form(p: Sequence[float], v: Sequence[float], w: Sequence[float]) -> float:
    """Fisher information bilinear form g_p(v, w) = sum_i v_i * w_i / p_i."""
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))


def kl_div(p: Sequence[float], q: Sequence[float]) -> float:
    """Kullback-Leibler divergence KL(p || q) = sum_i p_i * log(p_i / q_i)."""
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))


def chi_squared(p: Sequence[float], q: Sequence[float]) -> float:
    """Pearson chi-squared divergence chi^2(p || q) = sum_i (p_i - q_i)^2 / q_i."""
    return sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))


def total_variation(p: Sequence[float], q: Sequence[float]) -> float:
    """Total-variation distance TV(p, q) = (1/2) * sum_i |p_i - q_i|."""
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


def vsub(p: Sequence[float], q: Sequence[float]) -> Vector:
    """Componentwise difference p - q."""
    return [pi - qi for pi, qi in zip(p, q)]


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
def random_distribution(n: int, rng: random.Random) -> Vector:
    """A strictly positive probability vector of length n (entries sum to 1)."""
    raw = [rng.uniform(0.05, 1.0) for _ in range(n)]
    s = sum(raw)
    return [x / s for x in raw]


def approx(a: float, b: float, tol: float = 1e-9) -> bool:
    return abs(a - b) <= tol * (1.0 + abs(a) + abs(b))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_metric_axioms(rng: random.Random) -> None:
    print("=" * 70)
    print("1. The Fisher form is a Riemannian metric")
    print("=" * 70)
    p = random_distribution(4, rng)
    u = [rng.uniform(-1, 1) for _ in range(4)]
    v = [rng.uniform(-1, 1) for _ in range(4)]
    w = [rng.uniform(-1, 1) for _ in range(4)]
    c = rng.uniform(-3, 3)

    sym_l, sym_r = fisher_form(p, v, w), fisher_form(p, w, v)
    print(f"  symmetry        g_p(v,w)={sym_l:+.6f}  g_p(w,v)={sym_r:+.6f}  "
          f"[ok={approx(sym_l, sym_r)}]")

    add_l = fisher_form(p, [ui + vi for ui, vi in zip(u, v)], w)
    add_r = fisher_form(p, u, w) + fisher_form(p, v, w)
    print(f"  additivity      g_p(u+v,w)={add_l:+.6f}  sum={add_r:+.6f}  "
          f"[ok={approx(add_l, add_r)}]")

    sm_l = fisher_form(p, [c * vi for vi in v], w)
    sm_r = c * fisher_form(p, v, w)
    print(f"  homogeneity     g_p(c*v,w)={sm_l:+.6f}  c*g={sm_r:+.6f}  "
          f"[ok={approx(sm_l, sm_r)}]")

    pdef = fisher_form(p, v, v)
    print(f"  positivity      g_p(v,v)={pdef:+.6f}  [>=0: {pdef >= 0}]")

    zero = fisher_form(p, [0.0] * 4, [0.0] * 4)
    print(f"  definiteness    g_p(0,0)={zero:.6f}  (zero iff v=0)")
    print()


def demo_chi_squared_identity(rng: random.Random) -> None:
    print("=" * 70)
    print("2. chi^2(p||q) = g_q(p-q, p-q)   (chiSquared_eq_fisher)")
    print("=" * 70)
    for _ in range(3):
        p = random_distribution(5, rng)
        q = random_distribution(5, rng)
        d = vsub(p, q)
        lhs = chi_squared(p, q)
        rhs = fisher_form(q, d, d)
        print(f"  chi^2={lhs:.8f}  g_q(p-q,p-q)={rhs:.8f}  "
              f"[ok={approx(lhs, rhs)}]")
    print()


def demo_kl_sandwich(rng: random.Random) -> None:
    print("=" * 70)
    print("3. The KL sandwich   0 <= KL(p||q) <= chi^2(p||q)")
    print("=" * 70)
    print(f"  {'KL':>12}  {'chi^2 = g_q':>12}  {'gap (chi^2-KL)':>14}  {'KL>=0':>6}")
    for _ in range(6):
        p = random_distribution(5, rng)
        q = random_distribution(5, rng)
        kl = kl_div(p, q)
        chi = chi_squared(p, q)
        print(f"  {kl:12.8f}  {chi:12.8f}  {chi - kl:14.8f}  "
              f"{kl >= -1e-12!s:>6}")
    print("  -> KL is always non-negative (Gibbs) and below chi^2 (bridge).")
    print()


def demo_pinsker_conjecture(rng: random.Random) -> None:
    print("=" * 70)
    print("4. Pinsker lower bound (open conjecture):  2*TV^2 <= KL")
    print("=" * 70)
    print(f"  {'2*TV^2':>12}  {'KL':>12}  {'chi^2':>12}  {'2TV^2<=KL':>10}")
    worst_margin = math.inf
    for _ in range(2000):
        n = rng.randint(2, 6)
        p = random_distribution(n, rng)
        q = random_distribution(n, rng)
        tv = total_variation(p, q)
        kl = kl_div(p, q)
        chi = chi_squared(p, q)
        lo = 2.0 * tv * tv
        worst_margin = min(worst_margin, kl - lo)
    # show a few representative rows
    rng2 = random.Random(7)
    for _ in range(5):
        n = rng2.randint(2, 6)
        p = random_distribution(n, rng2)
        q = random_distribution(n, rng2)
        tv = total_variation(p, q)
        kl = kl_div(p, q)
        chi = chi_squared(p, q)
        lo = 2.0 * tv * tv
        print(f"  {lo:12.8f}  {kl:12.8f}  {chi:12.8f}  {lo <= kl + 1e-12!s:>10}")
    print(f"  Over 2000 random pairs, min(KL - 2*TV^2) = {worst_margin:.6e} "
          f"(>= 0 supports the conjecture).")
    print()


def demo_bernoulli_factored_derivative() -> None:
    print("=" * 70)
    print("5. Bernoulli Pinsker:  2(p-q)^2 <= KL(Ber p || Ber q)")
    print("   and the factored derivative g'(q) = (q-p)(1-2q)^2 / (q(1-q))")
    print("=" * 70)

    def kl_ber(p: float, q: float) -> float:
        return p * math.log(p / q) + (1 - p) * math.log((1 - p) / (1 - q))

    def gap(p: float, q: float) -> float:
        return kl_ber(p, q) - 2.0 * (p - q) ** 2

    def gap_deriv_closed(p: float, q: float) -> float:
        return (q - p) * (1 - 2 * q) ** 2 / (q * (1 - q))

    def gap_deriv_numeric(p: float, q: float, h: float = 1e-6) -> float:
        return (gap(p, q + h) - gap(p, q - h)) / (2 * h)

    p = 0.3
    print(f"  Fix p = {p}. The gap g(q) = KL(Ber p||Ber q) - 2(p-q)^2:")
    print(f"  {'q':>6}  {'g(q)':>12}  {'g(q)>=0':>8}  "
          f"{'closed g`':>12}  {'numeric g`':>12}")
    for q in [0.05, 0.15, 0.30, 0.45, 0.70, 0.95]:
        g = gap(p, q)
        dc = gap_deriv_closed(p, q)
        dn = gap_deriv_numeric(p, q)
        print(f"  {q:6.2f}  {g:12.8f}  {g >= -1e-12!s:>8}  "
              f"{dc:12.8f}  {dn:12.8f}")
    print("  -> g(q) >= 0 with unique minimum at q = p (g(p)=0), and the")
    print("     closed-form derivative matches the numerical one; its sign")
    print("     equals sign(q-p) because (1-2q)^2 >= 0.")
    print()


def main() -> None:
    rng = random.Random(2024)
    print()
    print("INFORMATION-GEOMETRIC KL SANDWICH -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_metric_axioms(rng)
    demo_chi_squared_identity(rng)
    demo_kl_sandwich(rng)
    demo_pinsker_conjecture(rng)
    demo_bernoulli_factored_derivative()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
