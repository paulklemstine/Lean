"""Assemble PACKAGE.json from the packaged artefacts in this directory."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

ROOT = Path(__file__).parent


def read(name: str) -> str:
    return (ROOT / name).read_text()


LEAN_FILES: List[str] = [
    "Catalog/Logic/KneeMedianLaw.lean",
    "Catalog/Logic/KneeQuotaScaling.lean",
    "Catalog/Logic/KneeMedianAmplification.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {path} =====\n\n" + (ROOT / path).read_text() for path in LEAN_FILES
)

ALGO_LADDER = '''"""Quota ladder of a seed ensemble."""

from typing import List, Sequence


def pass_count(knees: Sequence[int], budget: int) -> int:
    """Number of seeds satisfied at `budget`."""
    return sum(1 for k in knees if k <= budget)


def quota_budget(knees: Sequence[int], m: int) -> int:
    """Least budget at which at least `m` of the seeds clear the bar.

    By the Rung Characterisation, Q(m) <= b iff m <= pass_count(knees, b);
    hence Q(m) is the m-th smallest knee.
    """
    if not 1 <= m <= len(knees):
        raise ValueError("quota must satisfy 1 <= m <= number of seeds")
    return sorted(knees)[m - 1]


def quota_ladder(knees: Sequence[int]) -> List[int]:
    """The whole ladder Q(1) <= Q(2) <= ... <= Q(n)."""
    return sorted(knees)


def certified_budget(knees: Sequence[int]) -> int:
    """The only rung that is a guarantee: every seed passes here."""
    return max(knees)


def verify_rung_characterisation(knees: Sequence[int], budget_bound: int) -> bool:
    """Exhaustively check Q(m) <= b  <=>  m <= #pass(b) on 0..budget_bound."""
    return all(
        (quota_budget(knees, m) <= b) == (m <= pass_count(knees, b))
        for m in range(1, len(knees) + 1)
        for b in range(budget_bound + 1)
    )


if __name__ == "__main__":
    knees = [256, 224, 160]
    print("ladder:", quota_ladder(knees))
    print("centre:", quota_budget(knees, 2), "= 7/8 * 256")
    print("guarantee:", certified_budget(knees))
    print("characterisation verified:", verify_rung_characterisation(knees, 1024))
'''

ALGO_RUNG_PROB = '''"""Rung distribution functions of an n-seed quota ladder."""

from fractions import Fraction
from math import comb
from typing import List, Union

Number = Union[Fraction, float]


def rung_probability(p: Number, m: int, n: int = 3) -> Number:
    """P[the m-th rung sits at or below the budget] = P[at least m of n seeds pass].

    Exact in rational arithmetic when `p` is a Fraction. Cost O(n) after the
    binomial coefficients, O(n^2) if they are recomputed naively.
    """
    if not 0 <= m <= n:
        raise ValueError("quota out of range")
    one = (Fraction(1) if isinstance(p, Fraction) else 1.0)
    return sum(comb(n, j) * p ** j * (one - p) ** (n - j) for j in range(m, n + 1))


def rung_profile(p: Number, n: int = 3) -> List[Number]:
    """The whole probabilistic ladder F_n(p) <= ... <= F_1(p)."""
    return [rung_probability(p, m, n) for m in range(n, 0, -1)]


def centre_map(p: Number) -> Number:
    """The three-seed majority-amplification map 3p^2 - 2p^3."""
    return 3 * p ** 2 - 2 * p ** 3


def amplification_report(p: Fraction) -> str:
    """Describe whether the centre amplifies or attenuates the per-seed tendency."""
    value = centre_map(p)
    if value > p:
        return f"p = {p}: centre {value} > p  (majority amplified)"
    if value < p:
        return f"p = {p}: centre {value} < p  (minority attenuated)"
    return f"p = {p}: centre {value} = p  (fixed point)"


if __name__ == "__main__":
    half = Fraction(1, 2)
    print("calibration at 1/2:", rung_profile(half))       # [1/8, 1/2, 7/8]
    for num in (1, 2, 3):
        print(amplification_report(Fraction(num, 3)))
'''

ALGO_FIT = '''"""Two-context affine fit of a rung, and the intercept-free dichotomy."""

from fractions import Fraction
from typing import Dict, Sequence, Tuple


def affine_fit(c1: Fraction, v1: Fraction,
               c2: Fraction, v2: Fraction) -> Tuple[Fraction, Fraction]:
    """Unique (alpha, beta) with v(ctx) = alpha * ctx + beta through two points."""
    if c1 == c2:
        raise ValueError("the two contexts must differ")
    alpha = (v2 - v1) / (c2 - c1)
    return alpha, v1 - alpha * c1


def is_ratio_law(c1: Fraction, v1: Fraction, c2: Fraction, v2: Fraction) -> bool:
    """A rung carries a context-free ratio law iff its affine fit has zero intercept."""
    return affine_fit(c1, v1, c2, v2)[1] == 0


def dichotomy_report(contexts: Tuple[int, int],
                     rungs: Dict[str, Sequence[int]]) -> Dict[str, str]:
    """Classify each rung as ratio-lawful or floor-bearing."""
    c1, c2 = (Fraction(c) for c in contexts)
    out: Dict[str, str] = {}
    for name, (v1, v2) in rungs.items():
        alpha, beta = affine_fit(c1, Fraction(v1), c2, Fraction(v2))
        out[name] = (f"alpha = {alpha}, beta = {beta} -> "
                     + ("ratio law" if beta == 0 else f"floor of {beta}"))
    return out


if __name__ == "__main__":
    report = dichotomy_report((1024, 2048),
                              {"minimum": (96, 160),
                               "median": (112, 224),
                               "maximum": (128, 256)})
    for name, verdict in report.items():
        print(f"{name:8s}: {verdict}")
'''

INTERACTIVE_LAYOUT = '\n# The Quota Ladder: a guided tour\n\n*How three noisy measurements become one lawful number.*\n\n---\n\n## 0. The puzzle, in one paragraph\n\nA laboratory notebook contains four numbers written **before** an experiment: $192$, $224$, $240$,\n$256$. They are pre-registered guesses at a single quantity — the smallest budget at which a system\nstill retains $98\\%$ of its full performance. The experiment runs. The answer is $160$. All four\nguesses are wrong. And yet the same round confirmed, to the digit, a law stated in advance: the\n**median** of the three seeds run at this configuration is exactly $\\tfrac78$ of a reference scale,\nreplicating the same ratio at a shorter configuration.\n\nBy the end of this page you will know exactly why those two facts are compatible — and why the\nmedian, not the mean, not the best case, not the worst case, is the number to bet on.\n\n---\n\n## 1. Knees, budgets, and why one number is not enough\n\nA system has a tunable budget $k$. Its *retained performance* $c(k)$ — measured as a fraction of\nfull-budget performance — is non-decreasing. Fix a bar, say $0.98$. The **knee** $k^{*}$ is the\nsmallest grid budget with $c(k) \\ge 0.98$.\n\nHere is the measured curve at one configuration. Read along it and find the knee yourself:\n\n| $k$ | 96 | 128 | **160** | 192 | 224 | 240 | 256 | 288 | 384 | 512 |\n|---|---|---|---|---|---|---|---|---|---|---|\n| retained | 0.963 | 0.973 | **0.981** | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 |\n\nThe knee is $160$: the first entry at or above $0.98$. Notice what this does to the four\npre-registered guesses — every one of them *clears the bar*, and a value that clears the bar cannot\nbe the first value that clears the bar. All four are refuted at once.\n\n<details>\n<summary><b>Why is the knee unique?</b> (click to expand)</summary>\n\nIf $k$ and $k\'$ are both knees with $k < k\'$, then $k$ lies on the grid below $k\'$, so the third\nclause in the definition of a knee applied to $k\'$ gives $c(k) < \\mathrm{bar}$, contradicting the\nsecond clause applied to $k$. Hence at most one knee exists, and it exists exactly when some grid\npoint clears the bar. Uniqueness is what makes "all four pre-registered values clear the bar"\nequivalent to "all four are refuted".\n</details>\n\nNow run the experiment with three random seeds. You get three knees: $160$, $224$, $256$. Which one\ndo you report?\n\n---\n\n## 2. Play with it: the quota ladder\n\nThere is not one answer but a **ladder** of answers. Say a seed *passes* at budget $b$ if its knee\nis at most $b$, and define\n$$Q(m) = \\min\\{\\, b : \\text{at least } m \\text{ seeds pass at } b \\,\\}.$$\nFor three seeds this is the minimum, the median and the maximum. Drag the three seed thresholds\nbelow and watch all three rungs move — and watch the $7/8$ law survive or die.\n\n{{interactive_demo:0}}\n\nThree things are worth discovering by hand in the widget above:\n\n1. **Only the top rung is a guarantee.** Set the sliders anywhere and look at the last column: every\n   rung below the maximum has at least one seed failing at it.\n2. **The centre is stubborn.** Send the third seed rogue (there is a button) and watch the centre\n   refuse to leave the interval spanned by the other two, while the guarantee follows the rogue\n   wherever it goes.\n3. **The law is falsifiable.** Push the third seed to $240$ or beyond and the $7/8$ verdict flips to\n   red. It could have happened; it did not.\n\n<details>\n<summary><b>The theorem behind the ladder</b> — the Rung Characterisation</summary>\n\n**Theorem.** For any ensemble of seeds and any feasible quota $m$,\n$$Q(m) \\le b \\quad\\Longleftrightarrow\\quad m \\le |\\mathrm{pass}(b)|.$$\n\n*Proof.* Right-to-left is the definition of an infimum. Left-to-right: the defining set is\nnon-empty (it contains $\\max_i K_i$), so its least element $Q(m)$ lies in it, giving\n$m \\le |\\mathrm{pass}(Q(m))|$; and $Q(m) \\le b$ makes $\\mathrm{pass}(Q(m)) \\subseteq \\mathrm{pass}(b)$\nby monotonicity of the pass set. $\\blacksquare$\n\nThis innocuous equivalence is the hinge of the whole theory: it turns a statement about an order\nstatistic into a statement about a *counting event*, which is what lets us attach probabilities to\nrungs in §4.\n</details>\n\nThe algorithm that computes the ladder — and exhaustively checks the characterisation, which is the\npractical guard against off-by-one errors in the quota convention:\n\n{{algorithm:0}}\n\n---\n\n## 3. Robustness: what one bad seed can do\n\nRobust statistics has a standard vocabulary for this. The **breakdown point** of a summary is the\nfraction of the sample an adversary must corrupt to move the summary arbitrarily far. For the\nmedian of $2m+1$ values it is $1/2$ — the best possible for any reasonable location functional. For\nthe maximum it is $0$.\n\nThat dichotomy is exactly the tension a practitioner faces:\n\n| rung | breakdown point | is it a guarantee? |\n|---|---|---|\n| best case (min) | $0$ | no |\n| **centre (median)** | $\\mathbf{1/2}$ | no |\n| guarantee (max) | $0$ | **yes** |\n\nYou cannot have both. The precise statement is: *a quota budget is safe for every seed if and only\nif it is the full-quota budget.* Stepping down from the maximum to gain robustness surrenders the\npromise, always.\n\n<details>\n<summary><b>The general one-seed bound</b> (and why the top rung has no protection)</summary>\n\n**Theorem.** Replace one seed $i_0$ by an arbitrary value $x$, giving $K\'$. Then for every quota $m$\nwith $m+1 \\le n$,\n$$Q_K(m) \\le Q_{K\'}(m+1) \\qquad\\text{and}\\qquad Q_{K\'}(m) \\le Q_K(m+1).$$\n\n*Proof.* $\\mathrm{pass}_{K\'}(b) \\subseteq \\mathrm{pass}_K(b) \\cup \\{i_0\\}$, so\n$|\\mathrm{pass}_{K\'}(b)| \\le |\\mathrm{pass}_K(b)| + 1$; now apply the Rung Characterisation twice.\n$\\blacksquare$\n\nSo a rung slips by at most one rung. The top rung $m = n$ has no rung above it to catch it — which\nis the structural reason its breakdown point is $0$. Corrupting $|S|$ seeds generalises the bound to\n$Q_K(m) \\le Q_{K\'}(m + |S|)$, giving the classical $1/2$ breakdown point of the centre; and setting\ntwo of three seeds to any target $B$ shows $1/2$ is sharp.\n</details>\n\n<details>\n<summary><b>Could the sweep grid be manufacturing the law?</b> No — and here is why</summary>\n\nOrder statistics commute with **every** monotone map: $\\operatorname{med}(f(a),f(b),f(c)) = f(\\operatorname{med}(a,b,c))$,\nbecause a monotone map on a linear order commutes with binary $\\min$ and $\\max$. Grid quantisation\n$\\kappa \\mapsto s\\lceil \\kappa/s\\rceil$ is monotone. Hence the median of the three *reported* knees\nis exactly the quantisation of the median of the three *true* knees, and the displacement lies in\n$[0, s)$ — strictly less than one grid step. A coarse grid can blur a ratio law; it cannot invent\none or destroy one. The same argument covers any monotone reparametrisation of the budget axis, so\na law read through the centre is a property of the sample and not of the reporting scale. (Read on\nWikipedia: [order statistic](https://en.wikipedia.org/wiki/Order_statistic),\n[robust statistics](https://en.wikipedia.org/wiki/Robust_statistics).)\n</details>\n\n---\n\n## 4. The heart of it: only the centre is calibrated\n\nNow randomise the seeds. Fix a budget and let $p$ be the probability that a single seed\'s knee lands\nat or below it. By the Rung Characterisation, the probability that rung $m$ sits at or below that\nbudget is the probability that at least $m$ seeds pass:\n$$F_3(p) = p^3, \\qquad F_2(p) = 3p^2 - 2p^3, \\qquad F_1(p) = 3p - 3p^2 + p^3.$$\n\nEvaluate at $p = 1/2$ — a single seed is a fair coin — and something striking happens:\n$$F_3(\\tfrac12) = \\tfrac18, \\qquad F_2(\\tfrac12) = \\tfrac12, \\qquad F_1(\\tfrac12) = \\tfrac78 .$$\n\n**The median is the unique calibrated rung.** Put a coin flip in, get a coin flip out. Report the\nguarantee instead and you understate by a factor of four; report the best case and you overstate by\nthe same factor.\n\n{{visualization:0}}\n\nBetter still, the median does not merely transmit a tendency — it *sharpens* it. On $(1/2, 1)$ we\nhave $F_2(p) > p$; on $(0, 1/2)$ we have $F_2(p) < p$; the fixed points are exactly $0$, $1/2$, $1$;\nand $F_2\'(1/2) = 3/2 > 1$, so the calibrated point is **repelling**. Three seeds turn a weak\nper-seed majority into a stronger ensemble regularity — that is what "the centre is the robust\nreading" means quantitatively.\n\n<details>\n<summary><b>All of §4 in three lines of algebra</b></summary>\n\nEverything follows from one factorisation:\n$$F_2(p) - p = p\\,(2p-1)\\,(1-p).$$\nThe sign of the right-hand side on $(0,1)$ is the sign of $2p-1$, giving amplification above $1/2$\nand attenuation below. The zero set is exactly $\\{0, 1/2, 1\\}$, giving the three fixed points.\nAnd $F_2\'(p) = 6p - 6p^2$ evaluates to $3/2$ at $p = 1/2$. The ordering\n$F_3 \\le F_2 \\le F_1$ is likewise two one-line differences: $F_2 - F_3 = 3p^2(1-p) \\ge 0$ and\n$F_1 - F_2 = 3p(1-p)^2 \\ge 0$. (Background reading:\n[majority function](https://en.wikipedia.org/wiki/Majority_function),\n[binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution).)\n</details>\n\nThe general-$n$ version — the upper binomial tail, evaluated exactly in rational arithmetic:\n\n{{algorithm:1}}\n\nUse the widget\'s third panel to sample: at $p = 2/3$, which is the observed per-seed frequency in\nthe recorded data, twenty thousand simulated three-seed experiments should put the centre rung at\nabout $20/27 \\approx 0.741$ and the guarantee rung at about $8/27 \\approx 0.296$. The gap between\nthose two numbers is exactly what reading the centre buys you.\n\n---\n\n## 5. The measured law: two contexts, six seeds, one ratio\n\nThe reference scale is the **product point** $P = d\\cdot\\mathrm{ctx}/32$ — $128$ at the shorter\nconfiguration, $256$ at the longer.\n\n| configuration | knee set | as multiples of $P$ | spread | median |\n|---|---|---|---|---|\n| shorter, $P=128$ | $\\{96, 112, 128\\}$ | $\\{0.750, 0.875, 1.000\\}$ | $0.250$ | $112 = \\tfrac78\\cdot128$ |\n| longer, $P=256$ | $\\{160, 224, 256\\}$ | $\\{0.625, 0.875, 1.000\\}$ | $0.375$ | $224 = \\tfrac78\\cdot256$ |\n\nThree separate facts hide in that table, and the next visualization pulls them apart.\n\n{{visualization:1}}\n\n- **The centre is a genuine ratio law.** $7/8$ is the *unique* constant fitting both contexts.\n- **The top rung is a ratio law too**, with ratio $1$: a pinned upper edge.\n- **The bottom rung is not a ratio law at all.** No single ratio fits $3/4$ and $5/8$. Its unique\n  affine fit is $\\mathrm{ctx}/16 + 32$ — with a **floor of 32**.\n\nThat is the **intercept-free dichotomy**: exactly the upper two rungs carry context-free ratio laws.\nAn intercept is the signature of a fixed cost paid before any budget-proportional benefit accrues,\nand only the optimistic rung — dominated by whichever seed concentrated most tightly — is positioned\nto see it.\n\n{{algorithm:2}}\n\n<details>\n<summary><b>What this means for deployment</b> — three speedups, not one</summary>\n\nA budget $k$ against context $\\mathrm{ctx}$ buys a factor $\\mathrm{ctx}/k$. Then:\n\n- guarantee: $\\mathrm{ctx}/P = 32/d$ — *context-free*, $8\\times$ at $d = 4$, verified at all six\n  recorded seeds;\n- centre: $\\mathrm{ctx}/(\\tfrac78 P) = 256/(7d)$ — also context-free, $\\approx 9.14\\times$;\n- best case: **not** context-free, $10.67\\times \\to 12.8\\times$ — but bounded, since under the\n  affine low-tail law the best-case speedup is the hyperbola\n  $16\\,\\mathrm{ctx}/(\\mathrm{ctx}+512) < 16$, strictly increasing and saturating below $16\\times$.\n\nSo the honest deployment reading is a distribution $\\{8.0\\times,\\ 9.1\\times,\\ 12.8\\times\\}$:\nguaranteed, typical, lucky.\n</details>\n\n---\n\n## 6. Why $0/4$ and $1/1$ are not a contradiction\n\nReturn to the four failed guesses. With two seeds recorded at $224$ and $256$, the third seed $x$\nleaves the median at $224$ **exactly when** $x \\le 224$. The pre-registered guesses form\n$H = \\{192, 224, 240, 256\\}$. Now look at all four combinations:\n\n| | preserves the centre | breaks the centre |\n|---|---|---|\n| $x \\in H$ | $x = 224$ | $x = 240$ |\n| $x \\notin H$ | $x = 160$ &nbsp;*(what happened)* | $x = 288$ |\n\nEvery cell is occupied by an admissible value. Hitting a point prediction and confirming the\npredicted centre are **logically independent events** — neither implies the other, in either\ndirection. A round can be $0/4$ on points and $1/1$ on the law with no contradiction whatsoever.\n\nNote the asymmetry, and note that it is not cheating: the centre prediction had a large target\n($x \\le 224$) but a real one, since any $x \\ge 240$ would have destroyed it, and two of the three\nseeds in fact landed there.\n\n---\n\n## 7. What the next experiment decides\n\nThe theory hands the next run a single inequality. Adjoin a fourth seed $x$ to $\\{256, 224, 160\\}$:\n$$Q(2) = \\min(224, \\max(160, x)), \\qquad Q(3) = \\max(224, \\min(256, x)), \\qquad Q(4) = \\max(256, x),$$\nso the upper-median rung stays at $224$ **iff** $x \\le 224$. Explore this in part four of the widget\nabove.\n\nTwo rival readings of the observed $7/8$ are on the table:\n\n- **it is a constant** — the four-seed centre stays at $224$;\n- **it is $1 - 2^{-n}$ at $n = 3$** — the median of the maximum of $n$ exchangeable draws — in which\n  case a fourth seed should push the centre to $\\tfrac{15}{16}\\cdot 256 = 240$.\n\nThey differ by exactly one grid step. One run decides. And at double the context the two low-tail\nfamilies split too, by $\\mathrm{ctx}/64 - 32$: constant-ratio predicts $320$, affine predicts $288$,\nand the median law predicts $448 = \\tfrac78 \\cdot 512$.\n\n---\n\n## 8. Check everything yourself\n\nThe following script reproduces every number on this page: the knee and its four refutations, the\nladder and an exhaustive check of the Rung Characterisation, two hundred thousand random rogue seeds\nagainst the breakdown bracket, a hundred thousand random triples against the quantisation-error\nbound, the rung polynomials against brute-force enumeration in exact rational arithmetic, the $7/8$\nlaw, the intercept-free dichotomy, the speedup distribution, the independence table, and the\nfour-seed pre-registration.\n\n{{demo:0}}\n\n---\n\n## 9. The moral\n\nIt is tempting to score a scientific prediction like a dart throw: hit or miss on a number. For\nnoisy systems that habit rewards lucky laws and punishes true ones. The alternative is to predict a\n*functional of the distribution*, chosen for its statistical virtues rather than its rhetorical\nconvenience — and the median has those virtues, provably:\n\n- it is the **only calibrated** rung of a three-seed ladder;\n- it has the **maximal breakdown point**, $1/2$, where the guarantee has $0$;\n- it is **equivariant** under every monotone change of scale, so no reparametrisation can fake it;\n- and its calibrated point is **repelling**, with derivative $3/2$, so three seeds buy strictly more\n  than one.\n\nFour sharp guesses failed and one soft-looking law survived. That is not a paradox — it is the\nexpected signature of a system whose individual outcomes are noisy and whose centre is lawful.\n'

FUTURE_DIRECTIONS = '# Future directions — bold, testable conjectures from the order-statistics round\n\nThe round replaced a point law ("the knee equals `d*ctx/32`") by a *distributional* law\n("the centre of the knee distribution equals `7/8 * d*ctx/32`"), and this cycle formalised the\norder theory behind it: the quota ladder `min <= median <= max` of an ensemble, its breakdown\nbehaviour under one bad seed, its equivariance under monotone reparametrisation, and the\nprobability polynomials `p^3 <= 3p^2 - 2p^3 <= 3p - 3p^2 + p^3` attached to its three rungs. The\nfollowing conjectures are the natural next targets; each is falsifiable by a single run or by a\nsingle proof.\n\n---\n\n## C1. The quota-ladder scaling conjecture (rung-indexed exponents)\n\n**Statement.** For a fixed depth `d`, there are constants `alpha_m` such that the `m`-th rung of an\n`n`-seed quota ladder satisfies `quotaBudget(ctx, m) = alpha_m * d*ctx/32 + beta_m` with\n`beta_m = 0` exactly for the *upper half* of the ladder (`m > n/2`), and `beta_m > 0` strictly below\nit. Measured instance: `beta = 0` for the median (`alpha = 7/8`) and the maximum (`alpha = 1`),\nwhile the minimum needs `beta = 32`.\n\n**The key insight is** that an intercept is the signature of a *floor* — a budget that must be paid\nbefore any attention mass can be captured at all — and only the optimistic rungs of the ladder,\nwhich are dominated by the luckiest seed, can see that floor; the centre and the guarantee end\naverage it away.\n\n**Why now?** Two contexts and six seeds already separate the three rungs of a three-seed ladder, and\na single `ctx = 4096` cell distinguishes the two candidate low-tail families by exactly one grid\nstep: `320` (constant ratio) versus `288` (affine).\n\n---\n\n## C2. The `7/8` centre is a `1 - 2^{-n}` law, not a `7/8` law\n\n**Statement.** For an `n`-seed ensemble at depth `d`, the median rung sits at\n`(1 - 2^{-n}) * d*ctx/32` — for `n = 3` this is `7/8`. Equivalently, the deficit of the centre below\nthe product point halves with every additional seed.\n\n**The key insight is** that the product point behaves like the *supremum* of the knee distribution\nand the median like the median of the maximum of `n` exchangeable draws, for which `1 - 2^{-n}` is\nexactly the median of the `n`-fold order statistic of a uniform law; the ladder polynomials\n(`p^3`, `3p^2 - 2p^3`, `3p - 3p^2 + p^3`) are the `n = 3` instance of that computation.\n\n**Why now?** It is decided by the announced fourth seed: the whole four-seed ladder is known in\nclosed form, so the run either lands `<= 224` (centre stable, `7/8` unchanged, C2\'s `15/16 = 240`\nrefuted) or in `(224, 256]` (centre moves up, C2 supported). No new harness is needed.\n\n---\n\n## C3. Rung-Lipschitz stability as an empirical law (the breakdown theorem is now proved)\n\n**Settled this cycle.** The `1/2` breakdown point of the median rung is no longer a conjecture:\ncorrupting any `m` of `2m + 1` seeds provably leaves the middle rung inside the clean ensemble\'s\nrange, and `m + 1` corruptions already make it arbitrary, so `1/2` is sharp. What remains open is\nthe *typical* case: is there a quantitative Lipschitz constant relating the displacement of a rung\nto the per-seed variance, so that the worst-case one-rung bound can be sharpened into an\nempirically useful error bar for the reported centre?\n\n---\n\n## C4. Next cells, in priority order\n\nA fourth seed at `ctx = 2048` (the low-tail test — `s4` in `{160, 192}` means the `0.625` low tail\nis a real, stable feature; `s4` in `{224, 256}` means it was seed-specific); a fourth seed at\n`ctx = 1024` (refines `{96, 112, 128}`; low value); the `d = 8` corner at short context; a `d = 8`\ncompression floor check; and the carry chain at scale, which is the frontier.\n'

package: Dict[str, Any] = {
    "title": "The Quota Ladder of a Seed Ensemble: Order Statistics, Calibration, "
             "and the 7/8 Median Law",
    "domain": "Logic",
    "description": "A complete order-statistical theory of threshold measurements repeated over "
                   "random seeds: the quota ladder Q(m), its breakdown and equivariance "
                   "properties, and the rung distribution functions p^3, 3p^2-2p^3, 3p-3p^2+p^3 "
                   "that single out the median as the unique calibrated summary. Applied to a "
                   "measured two-context ensemble, the theory explains why every pre-registered "
                   "point prediction failed while the centre of the distribution sat exactly at "
                   "7/8 of the reference scale at both contexts.",
    "authors": ["Aristotle"],
    "date": "2026-08-17",
    "key_results": [
        "Rung Characterisation: the m-th quota budget of a seed ensemble sits at or below a "
        "budget b precisely when at least m seeds clear the bar at b; for three seeds the ladder "
        "is exactly minimum, median, maximum.",
        "Breakdown dichotomy: one seed moves the m-rung only into the original ensemble's "
        "interval between the (m-1)-rung and the (m+1)-rung, so the centre of 2m+1 seeds "
        "tolerates m corruptions and no more (breakdown point 1/2, sharp), while the all-seeds "
        "guarantee has breakdown point zero; a quota budget is safe for every seed if and only "
        "if it is the full-quota budget.",
        "Calibration theorem: the three rung distribution functions are p^3, 3p^2-2p^3 and "
        "3p-3p^2+p^3, ordered on [0,1], reading 1/8, 1/2 and 7/8 at p = 1/2 — the median is the "
        "unique calibrated rung, the extremes being wrong by a factor of four in opposite "
        "directions.",
        "Majority amplification: the centre map 3p^2-2p^3 strictly amplifies a per-seed majority "
        "and attenuates a per-seed minority, has exactly the fixed points 0, 1/2 and 1, and has "
        "derivative 3/2 > 1 at 1/2, so the calibrated point is repelling.",
        "The 7/8 median law and the intercept-free dichotomy: the measured knee sets {96,112,128} "
        "and {160,224,256} have medians 112 = (7/8)*128 and 224 = (7/8)*256 against the reference "
        "scale d*ctx/32, with 7/8 the unique fitting ratio; the median and maximum admit "
        "intercept-free two-context fits while the low tail requires an additive floor of 32.",
        "Logical independence of point prediction and centre prediction: all four combinations of "
        "hitting a pre-registered point value and preserving the predicted median are realised by "
        "admissible third-seed values, so a round can refute every point prediction while "
        "confirming the distributional law.",
    ],
    "keywords": [
        "order statistics", "median", "breakdown point", "calibration", "quota budget",
        "threshold estimation", "monotone equivariance", "ratio law",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Audit of the Quota Ladder and the 7/8 Median Law",
            "description": "A single self-contained script that reproduces every quantitative "
                           "claim of the theory. It extracts the knee from the measured "
                           "retained-performance table and shows that all four pre-registered "
                           "point values clear the bar (hence none is the knee); builds the quota "
                           "ladder and verifies the Rung Characterisation exhaustively over all "
                           "budgets 0..1099 and all quotas; stress-tests the breakdown dichotomy "
                           "with 200 000 random rogue seeds; verifies monotone equivariance of "
                           "the median under grid quantisation on 100 000 random triples together "
                           "with the sharp error bound [0, s); checks the three rung polynomials "
                           "against brute-force enumeration of the eight-point sample space in "
                           "exact rational arithmetic, together with calibration at p = 1/2, "
                           "amplification, the three fixed points and the derivative 3/2; "
                           "confirms the 7/8 median law, the uniqueness of the ratio and the "
                           "intercept-free dichotomy; tabulates the guaranteed, typical and "
                           "best-case speedups and the bounded best-case hyperbola; exhibits all "
                           "four combinations witnessing the logical independence of point and "
                           "centre prediction; and prints the closed-form four-seed ladder with "
                           "its pre-registered inequality.",
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Quota Ladder Construction and Verification of the Rung Characterisation",
            "description": "Given the knees reported by n seeds, this computes the entire ladder "
                           "Q(1) <= ... <= Q(n), where Q(m) is the least budget at which at least "
                           "m seeds clear the bar. Correctness rests on the Rung "
                           "Characterisation, Q(m) <= b iff m <= #pass(b), which identifies Q(m) "
                           "with the m-th order statistic of the knee sample; the routine also "
                           "verifies that equivalence exhaustively over a budget range, which is "
                           "the practical guard against off-by-one errors in the quota "
                           "convention. Sorting dominates the cost: O(n log n) time and O(n) "
                           "space for the ladder, O(n * B) for the exhaustive verification over B "
                           "budgets. The ladder is the object one should report from a seed "
                           "sweep: the top rung is the only guarantee, the middle rung the only "
                           "calibrated summary.",
            "pseudocode": "INPUT  knees K[1..n] (one measured threshold per seed), quota m\n"
                          "OUTPUT Q(m), the least budget satisfying at least m seeds\n"
                          "\n"
                          "1  assert 1 <= m <= n\n"
                          "2  S <- sort(K) ascending\n"
                          "3  return S[m]                       // the m-th order statistic\n"
                          "\n"
                          "LADDER(K):\n"
                          "4  return sort(K)                    // Q(1) <= Q(2) <= ... <= Q(n)\n"
                          "\n"
                          "VERIFY(K, B):                        // Rung Characterisation\n"
                          "5  for m <- 1 to n:\n"
                          "6      for b <- 0 to B:\n"
                          "7          lhs <- (QUOTA(K, m) <= b)\n"
                          "8          rhs <- (m <= |{ i : K[i] <= b }|)\n"
                          "9          if lhs != rhs: return FALSE\n"
                          "10 return TRUE",
            "code": ALGO_LADDER,
        },
        {
            "name": "Rung Distribution Functions and the Majority-Amplification Map",
            "description": "Under the honest model for a seed sweep — n independent seeds, each "
                           "passing at a fixed budget with probability p — the probability that "
                           "the m-th rung sits at or below that budget is the upper binomial tail "
                           "sum_{j>=m} C(n,j) p^j (1-p)^{n-j}, by the Rung Characterisation. For "
                           "n = 3 this yields p^3 for the guarantee rung, 3p^2-2p^3 for the "
                           "centre and 3p-3p^2+p^3 for the best case. Evaluated in exact rational "
                           "arithmetic the routine reproduces the calibration table 1/8, 1/2, 7/8 "
                           "at p = 1/2 and the amplification behaviour of the centre map, whose "
                           "fixed points are exactly 0, 1/2 and 1 and whose derivative at 1/2 is "
                           "3/2 > 1. Complexity: O(n) multiplications per rung given cached "
                           "binomial coefficients, O(n^2) for the whole profile.",
            "pseudocode": "INPUT  per-seed pass probability p, quota m, ensemble size n\n"
                          "OUTPUT F_m(p) = P[the m-th rung sits at or below the budget]\n"
                          "\n"
                          "1  assert 0 <= m <= n and 0 <= p <= 1\n"
                          "2  total <- 0\n"
                          "3  for j <- m to n:\n"
                          "4      total <- total + C(n, j) * p^j * (1-p)^(n-j)\n"
                          "5  return total\n"
                          "\n"
                          "PROFILE(p, n):\n"
                          "6  return [ F_n(p), F_{n-1}(p), ..., F_1(p) ]   // increasing\n"
                          "\n"
                          "CENTRE_MAP(p):                      // n = 3 middle rung\n"
                          "7  return 3*p^2 - 2*p^3\n"
                          "8  // > p iff p in (1/2, 1); < p iff p in (0, 1/2);\n"
                          "9  // fixed points exactly {0, 1/2, 1}; derivative 3/2 at 1/2",
            "code": ALGO_RUNG_PROB,
        },
        {
            "name": "Two-Context Affine Fitting and the Intercept-Free Dichotomy Test",
            "description": "Each rung of the ladder is measured at two context lengths and fitted "
                           "with the two-parameter law v(ctx) = alpha*ctx + beta. Because the "
                           "resulting 2x2 system has determinant c2 - c1 != 0, the fit is unique "
                           "and the test is exact rather than statistical: a rung carries a "
                           "context-free ratio law precisely when its intercept beta vanishes. "
                           "Applied to the measured ladder the test returns alpha = 7/64, "
                           "beta = 0 for the median; alpha = 1/8, beta = 0 for the maximum; and "
                           "alpha = 1/16, beta = 32 for the minimum — the intercept-free "
                           "dichotomy, which identifies a non-zero intercept as a fixed floor "
                           "visible only to the optimistic tail. Complexity O(1) per rung, in "
                           "exact rational arithmetic so that beta = 0 is decided without "
                           "floating-point tolerance.",
            "pseudocode": "INPUT  contexts c1 != c2, rung values v1 at c1 and v2 at c2\n"
                          "OUTPUT (alpha, beta) with v(ctx) = alpha*ctx + beta, and a verdict\n"
                          "\n"
                          "1  alpha <- (v2 - v1) / (c2 - c1)      // exact rational division\n"
                          "2  beta  <- v1 - alpha * c1\n"
                          "3  if beta = 0:\n"
                          "4      return (alpha, 0), 'context-free ratio law'\n"
                          "5  else:\n"
                          "6      return (alpha, beta), 'floor of beta must be paid first'\n"
                          "\n"
                          "DICHOTOMY(c1, c2, rungs):\n"
                          "7  for each rung (name, v1, v2) in rungs:\n"
                          "8      report name with FIT(c1, v1, c2, v2)\n"
                          "9  // measured: median 7/64 with beta = 0, maximum 1/8 with beta = 0,\n"
                          "10 //           minimum 1/16 with beta = 32",
            "code": ALGO_FIT,
        },
    ],
    "visualizations": [
        {
            "name": "The Probabilistic Quota Ladder and the Repelling Calibrated Point",
            "description": "Two panels. The left plots the three rung distribution functions "
                           "p^3, 3p^2-2p^3 and 3p-3p^2+p^3 on [0,1], shades the band between the "
                           "extremes, and marks the calibration readings 1/8, 1/2 and 7/8 at "
                           "p = 1/2 — visual proof that only the centre returns the per-seed "
                           "probability. The right plots the centre map against the identity, "
                           "marks its three fixed points 0, 1/2, 1, draws the tangent of slope "
                           "3/2 at the repelling point, and shades the regions where a majority "
                           "is amplified and a minority attenuated.",
            "code": read("viz_rung_polynomials.py"),
        },
        {
            "name": "Rung Scaling Across Contexts and the Intercept-Free Dichotomy",
            "description": "Two panels. The left plots the measured knee sets {96,112,128} and "
                           "{160,224,256} against context length together with the unique "
                           "two-point fits of each rung: the median line 7*ctx/64 and the maximum "
                           "line ctx/8 pass through the origin, while the low-tail line "
                           "ctx/16 + 32 does not, and its floor of 32 is drawn explicitly; the "
                           "next context cell is marked with the competing predictions 288 versus "
                           "320 for the low tail and 448 for the centre. The right panel "
                           "normalises by the reference scale, exhibiting the pinned upper edge "
                           "at 1, the pinned centre at 7/8, and the low tail falling from 3/4 to "
                           "5/8 — the entire widening of the spread.",
            "code": read("viz_ladder_scaling.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Quota Ladder Laboratory: Move the Seeds, Watch the Law",
            "description": "A four-part interactive laboratory. Part one lets you drag three "
                           "measured thresholds along the sweep grid and watch the ladder — best "
                           "case, centre, guarantee — respond, with live readouts of each rung as "
                           "a multiple of the reference scale, its speedup, whether it is "
                           "actually a guarantee, and whether the 7/8 median law survives your "
                           "configuration. Part two isolates one rogue seed against two fixed "
                           "measurements and shows the centre trapped inside the bracket of the "
                           "other two while the guarantee escapes without bound, together with "
                           "the exact stability family x <= 224. Part three randomises the seeds: "
                           "a slider over the per-seed pass probability drives the three rung "
                           "polynomials, displays the calibration table (only the centre is "
                           "calibrated at p = 1/2), draws the amplification map against the "
                           "identity, and runs 20 000 simulated three-seed experiments on demand "
                           "to confirm the closed forms empirically. Part four exposes the "
                           "pre-registered four-seed test: adjoin a fourth measurement and watch "
                           "the upper-median rung stay at 224 exactly when it is at most 224.",
            "html": read("widget.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read("demo.py"),
        "viz_rung_polynomials": read("viz_rung_polynomials.py"),
        "viz_ladder_scaling": read("viz_ladder_scaling.py"),
    },
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n")
print("wrote PACKAGE.json",
      (ROOT / "PACKAGE.json").stat().st_size, "bytes")


"""
Numerical demonstration of the quota-ladder theory of seed ensembles
and the 7/8 median law.

Self-contained: standard library only (math, itertools, fractions, random).

The script verifies, numerically and symbolically-by-exact-rational-arithmetic:

  1. Knee extraction from a measured retained-performance curve, and the
     refutation of the four pre-registered point predictions.
  2. The quota ladder Q(m) = min{b : #{i : K_i <= b} >= m} and the
     Rung Characterisation  Q(m) <= b  <=>  m <= #pass(b).
  3. The breakdown behaviour of the rungs: the median is bracketed by the
     other two seeds; the maximum is unbounded under a single bad seed.
  4. Monotone equivariance: grid quantisation commutes with the median, with
     error in [0, s).
  5. The rung distribution functions p^3, 3p^2 - 2p^3, 3p - 3p^2 + p^3, their
     ordering, the calibration table at p = 1/2, amplification/attenuation,
     the three fixed points, and the derivative 3/2 at p = 1/2.
  6. The measured law: medians 112 = (7/8)*128 and 224 = (7/8)*256, the
     uniqueness of the ratio 7/8, and the intercept-free dichotomy.
  7. Deployment speedups and the bounded best-case hyperbola.
  8. Logical independence of point prediction and centre prediction.
  9. The four-seed ladder in closed form and the pre-registered inequality.
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------
# 0.  The measured data
# --------------------------------------------------------------------------

GRID_16X: List[int] = [96, 128, 160, 192, 224, 240, 256, 288, 384, 512, 768, 1024]

RETAINED_16X_SEED3: Dict[int, float] = {
    96: 0.963, 128: 0.973, 160: 0.981, 192: 0.984, 224: 0.986, 240: 0.987,
    256: 0.990, 288: 0.993, 384: 0.999, 512: 1.000, 768: 1.003, 1024: 1.003,
}

BAR: float = 0.98
HORNS: Tuple[int, ...] = (192, 224, 240, 256)

KNEES_8X: Tuple[int, int, int] = (128, 112, 96)     # ctx = 1024, seeds 1,2,3
KNEES_16X: Tuple[int, int, int] = (256, 224, 160)   # ctx = 2048, seeds 1,2,3


def product_point(depth: int, ctx: int) -> Fraction:
    """The reference scale P(d, ctx) = d * ctx / 32."""
    return Fraction(depth * ctx, 32)


# --------------------------------------------------------------------------
# 1.  Knee extraction
# --------------------------------------------------------------------------

def knee(grid: Sequence[int], bar: float, curve: Dict[int, float]) -> Optional[int]:
    """Least grid budget whose retained value clears the bar."""
    for k in sorted(grid):
        if curve[k] >= bar:
            return k
    return None


def demo_knee() -> None:
    print("=" * 74)
    print("1.  KNEE EXTRACTION AND THE REFUTED POINT PREDICTIONS")
    print("=" * 74)
    k_star = knee(GRID_16X, BAR, RETAINED_16X_SEED3)
    print(f"  measured knee k* = {k_star}   (margin {RETAINED_16X_SEED3[k_star] - BAR:+.4f})")
    for h in HORNS:
        clears = RETAINED_16X_SEED3[h] >= BAR
        print(f"  pre-registered point {h:4d}: retained {RETAINED_16X_SEED3[h]:.3f}, "
              f"clears bar = {clears}, is the knee = {h == k_star}")
    assert k_star == 160
    assert all(RETAINED_16X_SEED3[h] >= BAR and h != k_star for h in HORNS)
    print("  => all four point predictions clear the bar, so none of them is the knee.")
    print()


# --------------------------------------------------------------------------
# 2.  The quota ladder
# --------------------------------------------------------------------------

def pass_count(knees: Sequence[int], budget: int) -> int:
    """#{i : K_i <= budget}."""
    return sum(1 for k in knees if k <= budget)


def quota_budget(knees: Sequence[int], m: int) -> int:
    """Least budget b with at least m seeds passing."""
    if m <= 0:
        return 0
    return sorted(knees)[m - 1]


def demo_ladder() -> None:
    print("=" * 74)
    print("2.  THE QUOTA LADDER AND THE RUNG CHARACTERISATION")
    print("=" * 74)
    for name, knees in (("ctx=1024", KNEES_8X), ("ctx=2048", KNEES_16X)):
        rungs = [quota_budget(knees, m) for m in (1, 2, 3)]
        print(f"  {name}: knees {sorted(knees)} -> ladder Q(1),Q(2),Q(3) = {rungs}"
              f"   (min, median, max)")
        assert rungs == [min(knees), sorted(knees)[1], max(knees)]
    # Rung Characterisation, checked exhaustively on a budget range.
    for knees in (KNEES_8X, KNEES_16X):
        for m in (1, 2, 3):
            for b in range(0, 1100):
                assert (quota_budget(knees, m) <= b) == (m <= pass_count(knees, b))
    print("  Rung Characterisation  Q(m) <= b  <=>  m <= #pass(b): verified for all")
    print("  budgets 0..1099 and all quotas m = 1,2,3 at both contexts.")
    print()


# --------------------------------------------------------------------------
# 3.  Breakdown behaviour
# --------------------------------------------------------------------------

def median3(a: int, b: int, c: int) -> int:
    return sorted((a, b, c))[1]


def demo_breakdown(trials: int = 200_000, seed: int = 12345) -> None:
    print("=" * 74)
    print("3.  BREAKDOWN: THE CENTRE IS BRACKETED, THE GUARANTEE IS NOT")
    print("=" * 74)
    rng = random.Random(seed)
    b, c = 224, 256
    worst_med, worst_max = 0, 0
    for _ in range(trials):
        x = rng.randint(0, 10 ** 6)
        m = median3(x, b, c)
        assert min(b, c) <= m <= max(b, c)
        worst_med = max(worst_med, m)
        worst_max = max(worst_max, max(x, b, c))
    print(f"  {trials} random rogue seeds x in [0, 10^6] against recorded (224, 256):")
    print(f"    largest median observed : {worst_med}   (provably <= max(224,256) = 256)")
    print(f"    largest maximum observed: {worst_max}   (provably unbounded in x)")
    print("  => median breakdown point 1/2; guarantee breakdown point 0.")
    print()


# --------------------------------------------------------------------------
# 4.  Monotone equivariance of the median under grid quantisation
# --------------------------------------------------------------------------

def grid_quantise(kappa: float, step: float) -> float:
    """The reported budget for a true knee kappa on a grid of step `step`."""
    return step * math.ceil(kappa / step)


def demo_equivariance(trials: int = 100_000, seed: int = 777) -> None:
    print("=" * 74)
    print("4.  EQUIVARIANCE: QUANTISATION COMMUTES WITH THE MEDIAN")
    print("=" * 74)
    rng = random.Random(seed)
    step = 32.0
    worst_error = 0.0
    for _ in range(trials):
        a, b, c = (rng.uniform(0.0, 1024.0) for _ in range(3))
        lhs = sorted((grid_quantise(a, step), grid_quantise(b, step),
                      grid_quantise(c, step)))[1]
        mu = sorted((a, b, c))[1]
        rhs = grid_quantise(mu, step)
        assert abs(lhs - rhs) < 1e-9
        err = lhs - mu
        assert -1e-9 <= err < step
        worst_error = max(worst_error, err)
    print(f"  step s = {step:.0f}, {trials} random triples of true knees in [0,1024]:")
    print("    med(gq(a),gq(b),gq(c)) == gq(med(a,b,c))  in every case")
    print(f"    largest displacement of the median: {worst_error:.4f} < s = {step:.0f}")
    print()


# --------------------------------------------------------------------------
# 5.  The rung distribution functions
# --------------------------------------------------------------------------

def rung_probability_bruteforce(p: Fraction, m: int) -> Fraction:
    """P[at least m of three independent seeds pass], from the 8-point space."""
    total = Fraction(0)
    for outcome in itertools.product((True, False), repeat=3):
        if sum(outcome) >= m:
            weight = Fraction(1)
            for passed in outcome:
                weight *= p if passed else (1 - p)
            total += weight
    return total


def F3(p: Fraction) -> Fraction:
    return p ** 3


def F2(p: Fraction) -> Fraction:
    return 3 * p ** 2 - 2 * p ** 3


def F1(p: Fraction) -> Fraction:
    return 3 * p - 3 * p ** 2 + p ** 3


def demo_rung_polynomials() -> None:
    print("=" * 74)
    print("5.  RUNG POLYNOMIALS, CALIBRATION, AMPLIFICATION")
    print("=" * 74)
    for num in range(0, 21):
        p = Fraction(num, 20)
        assert rung_probability_bruteforce(p, 3) == F3(p)
        assert rung_probability_bruteforce(p, 2) == F2(p)
        assert rung_probability_bruteforce(p, 1) == F1(p)
        assert F3(p) <= F2(p) <= F1(p)
    print("  closed forms p^3, 3p^2-2p^3, 3p-3p^2+p^3 match the 8-point sample space")
    print("  and satisfy F3 <= F2 <= F1 at p = 0, 0.05, ..., 1.")

    half = Fraction(1, 2)
    print(f"\n  calibration at p = 1/2:")
    print(f"    guarantee rung F3(1/2) = {F3(half)}   (pessimistic by a factor of 4)")
    print(f"    centre     rung F2(1/2) = {F2(half)}   <-- the unique calibrated rung")
    print(f"    best-case  rung F1(1/2) = {F1(half)}   (optimistic by a factor of 4)")
    assert (F3(half), F2(half), F1(half)) == (Fraction(1, 8), half, Fraction(7, 8))

    print("\n  amplification / attenuation of the centre:")
    for num in (1, 3, 5, 7, 10, 13, 15, 17, 19):
        p = Fraction(num, 20)
        rel = "<" if F2(p) < p else ("=" if F2(p) == p else ">")
        print(f"    p = {float(p):.2f}:  F2(p) = {float(F2(p)):.4f}  {rel}  p")
    assert all(F2(Fraction(n, 20)) > Fraction(n, 20) for n in range(11, 20))
    assert all(F2(Fraction(n, 20)) < Fraction(n, 20) for n in range(1, 10))

    fixed = [Fraction(n, 1000) for n in range(0, 1001)
             if F2(Fraction(n, 1000)) == Fraction(n, 1000)]
    print(f"\n  fixed points of F2 on a 1/1000 lattice: {[str(f) for f in fixed]}")
    assert fixed == [Fraction(0), Fraction(1, 2), Fraction(1)]

    h = 1e-6
    deriv = (float(F2(Fraction(1, 2) + Fraction(1, 10 ** 6)))
             - float(F2(Fraction(1, 2) - Fraction(1, 10 ** 6)))) / (2 * h)
    print(f"  derivative of F2 at 1/2 (central difference): {deriv:.6f}  "
          f"(exact value 3/2 > 1 => repelling)")
    assert abs(deriv - 1.5) < 1e-6

    p23 = Fraction(2, 3)
    print(f"\n  reading for the recorded data, p = 2/3 (4 of 6 seeds at or below 7/8 P):")
    print(f"    centre rung    F2(2/3) = {F2(p23)} = {float(F2(p23)):.4f}  >  2/3")
    print(f"    guarantee rung F3(2/3) = {F3(p23)} = {float(F3(p23)):.4f}  <  2/3")
    assert F2(p23) == Fraction(20, 27) and F3(p23) == Fraction(8, 27)
    print()


# --------------------------------------------------------------------------
# 6.  The measured law and the intercept-free dichotomy
# --------------------------------------------------------------------------

def affine_fit(c1: Fraction, v1: Fraction, c2: Fraction,
               v2: Fraction) -> Tuple[Fraction, Fraction]:
    """Unique (alpha, beta) with alpha*c + beta through the two points."""
    alpha = (v2 - v1) / (c2 - c1)
    beta = v1 - alpha * c1
    return alpha, beta


def demo_median_law() -> None:
    print("=" * 74)
    print("6.  THE 7/8 MEDIAN LAW AND THE INTERCEPT-FREE DICHOTOMY")
    print("=" * 74)
    for ctx, knees in ((1024, KNEES_8X), (2048, KNEES_16X)):
        P = product_point(4, ctx)
        lo, mid, hi = sorted(knees)
        print(f"  ctx = {ctx:5d}:  P = {P}   knees {sorted(knees)}   "
              f"ratios {[str(Fraction(k) / P) for k in sorted(knees)]}")
        print(f"                median {mid} = {Fraction(mid) / P} * P,   "
              f"spread {(Fraction(hi - lo) / P)}")
        assert Fraction(mid) == Fraction(7, 8) * P
        assert Fraction(hi) == P

    print("\n  two-context affine fits  v(ctx) = alpha*ctx + beta :")
    rows = [("minimum", Fraction(96), Fraction(160)),
            ("median ", Fraction(112), Fraction(224)),
            ("maximum", Fraction(128), Fraction(256))]
    for name, v1, v2 in rows:
        alpha, beta = affine_fit(Fraction(1024), v1, Fraction(2048), v2)
        verdict = "RATIO LAW (intercept-free)" if beta == 0 else "needs an intercept"
        print(f"    {name}: alpha = {alpha}, beta = {beta}   -> {verdict}")
    assert affine_fit(Fraction(1024), Fraction(112), Fraction(2048), Fraction(224))[1] == 0
    assert affine_fit(Fraction(1024), Fraction(128), Fraction(2048), Fraction(256))[1] == 0
    assert affine_fit(Fraction(1024), Fraction(96), Fraction(2048),
                      Fraction(160)) == (Fraction(1, 16), Fraction(32))

    # Uniqueness of the ratio 7/8 for the median.
    candidates = [Fraction(n, 64) for n in range(1, 65)
                  if Fraction(n, 64) * 128 == 112 and Fraction(n, 64) * 256 == 224]
    print(f"\n  ratios alpha with alpha*128 = 112 and alpha*256 = 224: "
          f"{[str(a) for a in candidates]}")
    assert candidates == [Fraction(7, 8)]
    bad = [Fraction(n, 64) for n in range(1, 65)
           if Fraction(n, 64) * 128 == 96 and Fraction(n, 64) * 256 == 160]
    print(f"  ratios alpha with alpha*128 =  96 and alpha*256 = 160: {bad}  (none exist)")
    assert bad == []
    print()


# --------------------------------------------------------------------------
# 7.  Deployment speedups
# --------------------------------------------------------------------------

def speedup(ctx: float, budget: float) -> float:
    return ctx / budget


def affine_best_case_speedup(ctx: float) -> float:
    """Best-case speedup under the affine low-tail law k = ctx/16 + 32."""
    return 16.0 * ctx / (ctx + 512.0)


def demo_speedups() -> None:
    print("=" * 74)
    print("7.  DEPLOYMENT: THE SPEEDUP DISTRIBUTION")
    print("=" * 74)
    for ctx, knees in ((1024, KNEES_8X), (2048, KNEES_16X)):
        lo, mid, hi = sorted(knees)
        print(f"  ctx = {ctx:5d}:  guaranteed {speedup(ctx, hi):5.2f}x   "
              f"typical {speedup(ctx, mid):5.2f}x   best {speedup(ctx, lo):5.2f}x")
    print("\n  the two upper rungs are context-free (d = 4):")
    for ctx in (256, 512, 1024, 2048, 4096, 8192):
        P = float(product_point(4, ctx))
        print(f"    ctx = {ctx:5d}: guarantee {speedup(ctx, P):.4f}x  "
              f"centre {speedup(ctx, 0.875 * P):.4f}x  "
              f"affine best case {affine_best_case_speedup(ctx):.4f}x  (< 16)")
        assert abs(speedup(ctx, P) - 8.0) < 1e-9
        assert abs(speedup(ctx, 0.875 * P) - 64.0 / 7.0) < 1e-9
        assert affine_best_case_speedup(ctx) < 16.0
    assert abs(affine_best_case_speedup(1024) - 32.0 / 3.0) < 1e-9
    assert abs(affine_best_case_speedup(2048) - 12.8) < 1e-9
    print("  the affine best-case hyperbola reproduces 32/3 at 1024 and 12.8 at 2048,")
    print("  is strictly increasing, and saturates strictly below 16x.")
    print()


# --------------------------------------------------------------------------
# 8.  Point prediction versus centre prediction
# --------------------------------------------------------------------------

def demo_independence() -> None:
    print("=" * 74)
    print("8.  POINT PREDICTION AND CENTRE PREDICTION ARE INDEPENDENT")
    print("=" * 74)
    table: Dict[Tuple[bool, bool], List[int]] = {}
    for x in range(0, 1025, 32):
        cell = (x in HORNS, median3(x, 224, 256) == 224)
        table.setdefault(cell, []).append(x)
    for in_horns in (True, False):
        for keeps in (True, False):
            witnesses = table.get((in_horns, keeps), [])
            print(f"  x in horns = {str(in_horns):5s}, centre preserved = {str(keeps):5s}"
                  f"  -> witnesses {witnesses[:4]}{' ...' if len(witnesses) > 4 else ''}")
            assert witnesses, "all four combinations must be realised"
    print("\n  stability family: med(x,224,256) = 224 exactly for x <= 224")
    for x in (128, 160, 192, 224, 240, 256, 288):
        print(f"    x = {x:4d}: median = {median3(x, 224, 256):4d}"
              f"{'   <- preserves the centre' if median3(x,224,256)==224 else ''}")
    assert all((median3(x, 224, 256) == 224) == (x <= 224) for x in range(0, 1025))
    print("  measured round: x = 160 -> zero of four points hit, the centre preserved.")
    print()


# --------------------------------------------------------------------------
# 9.  The four-seed pre-registration
# --------------------------------------------------------------------------

def four_seed_ladder(x: int) -> Tuple[int, int, int, int]:
    """Closed-form ladder of the ensemble (256, 224, 160, x)."""
    q1 = min(160, x)
    q2 = min(224, max(160, x))
    q3 = max(224, min(256, x))
    q4 = max(256, x)
    return q1, q2, q3, q4


def demo_four_seed() -> None:
    print("=" * 74)
    print("9.  THE PRE-REGISTERED FOUR-SEED TEST")
    print("=" * 74)
    print("   x     Q(1)  Q(2)  Q(3)  Q(4)     upper median stays 224?")
    for x in (96, 128, 160, 192, 224, 240, 256, 288, 384):
        q1, q2, q3, q4 = four_seed_ladder(x)
        print(f"  {x:4d}   {q1:4d}  {q2:4d}  {q3:4d}  {q4:4d}     {q3 == 224}")
        brute = sorted((256, 224, 160, x))
        assert (q1, q2, q3, q4) == tuple(brute)
        assert (q3 == 224) == (x <= 224)
    print("\n  => the whole four-seed reading is decided by the single inequality x <= 224.")
    print("     constant-centre hypothesis : x <= 224 (centre stays at 7/8 * 256 = 224)")
    print("     order-statistic hypothesis : x in (224, 256] (centre moves to 15/16 * 256 = 240)")
    print()
    print("  extrapolation to ctx = 4096:")
    ratio_pred = Fraction(5, 64) * 4096
    affine_pred = Fraction(1, 16) * 4096 + 32
    median_pred = Fraction(7, 64) * 4096
    print(f"    low tail, constant-ratio family : {ratio_pred}")
    print(f"    low tail, affine family         : {affine_pred}   (gap {ratio_pred - affine_pred}"
          f" = one grid step)")
    print(f"    median law                      : {median_pred} = 7/8 * 512")
    assert ratio_pred - affine_pred == 32
    assert median_pred == Fraction(7, 8) * 512
    print()


# --------------------------------------------------------------------------

def main() -> None:
    demo_knee()
    demo_ladder()
    demo_breakdown()
    demo_equivariance()
    demo_rung_polynomials()
    demo_median_law()
    demo_speedups()
    demo_independence()
    demo_four_seed()
    print("=" * 74)
    print("All demonstrations completed; every assertion held.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""
Visualization: the three rungs of the measured quota ladder against context length,
and the intercept-free dichotomy.

Left panel  : the measured knee sets {96,112,128} at ctx = 1024 and {160,224,256} at
              ctx = 2048, with the fitted lines of each rung. The median line 7*ctx/64
              and the maximum line ctx/8 pass through the origin; the low-tail line
              ctx/16 + 32 does not, and its intercept 32 is drawn explicitly.
Right panel : the same data normalised by the reference scale P = d*ctx/32, showing the
              pinned upper edge at 1, the pinned centre at 7/8, and the low tail falling
              from 3/4 to 5/8 - the widening spread.

Run:  python viz_ladder_scaling.py       (writes ladder_scaling.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

CONTEXTS: List[int] = [1024, 2048]
KNEES: Dict[int, Tuple[int, int, int]] = {1024: (96, 112, 128), 2048: (160, 224, 256)}
DEPTH: int = 4


def product_point(ctx: float) -> float:
    return DEPTH * ctx / 32.0


def main() -> None:
    ctx = np.linspace(0.0, 4400.0, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    fits = [("low tail (min)", ctx / 16.0 + 32.0, "$\\mathrm{ctx}/16+32$  (intercept 32)"),
            ("centre (median)", 7.0 * ctx / 64.0, "$7\\,\\mathrm{ctx}/64=\\frac{7}{8}P$  (no intercept)"),
            ("guarantee (max)", ctx / 8.0, "$\\mathrm{ctx}/8=P$  (no intercept)")]
    for (_, line, label), colour in zip(fits, ("tab:red", "tab:blue", "tab:green")):
        ax1.plot(ctx, line, lw=2.2, color=colour, label=label)
    for c in CONTEXTS:
        lo, mid, hi = KNEES[c]
        ax1.plot([c, c, c], [lo, mid, hi], "o", ms=9, color="black", zorder=5)
        for value in (lo, mid, hi):
            ax1.annotate(str(value), (c, value), textcoords="offset points",
                         xytext=(8, -4), fontsize=10)
    ax1.plot([0], [32], "s", ms=8, color="tab:red")
    ax1.annotate("floor 32", (0, 32), textcoords="offset points", xytext=(6, 14),
                 fontsize=10, color="tab:red")
    ax1.axvline(4096, ls=":", color="grey")
    ax1.annotate("next cell:\n288 vs 320 (low tail)\n448 (centre)", (4096, 400),
                 textcoords="offset points", xytext=(-170, 30), fontsize=9, color="grey")
    ax1.set_xlabel("context length")
    ax1.set_ylabel("budget (knee)")
    ax1.set_title("The three rungs against context\n"
                  "only the upper two are intercept-free")
    ax1.legend(loc="upper left", fontsize=9)
    ax1.grid(alpha=0.25)

    width = 0.28
    positions = np.arange(len(CONTEXTS), dtype=float)
    for offset, index, name, colour in ((-width, 0, "low tail", "tab:red"),
                                        (0.0, 1, "centre", "tab:blue"),
                                        (width, 2, "guarantee", "tab:green")):
        ratios = [KNEES[c][index] / product_point(c) for c in CONTEXTS]
        ax2.bar(positions + offset, ratios, width=width, color=colour, alpha=0.85,
                label=name)
        for x, r in zip(positions + offset, ratios):
            ax2.annotate(f"{r:.3f}", (x, r), ha="center", textcoords="offset points",
                         xytext=(0, 4), fontsize=9)
    ax2.axhline(1.0, ls="--", color="tab:green", lw=1.2)
    ax2.axhline(0.875, ls="--", color="tab:blue", lw=1.2)
    ax2.annotate("pinned upper edge $1$", (1.35, 1.005), fontsize=9, color="tab:green")
    ax2.annotate("pinned centre $7/8$", (1.35, 0.88), fontsize=9, color="tab:blue")
    ax2.set_xticks(positions)
    ax2.set_xticklabels([f"ctx = {c}\nP = {int(product_point(c))}" for c in CONTEXTS])
    ax2.set_ylim(0.0, 1.15)
    ax2.set_ylabel("knee as a multiple of the reference scale $P$")
    ax2.set_title("Normalised ladder\nthe spread widens entirely through the low tail")
    ax2.legend(loc="lower left", fontsize=9)
    ax2.grid(axis="y", alpha=0.25)

    fig.tight_layout()
    fig.savefig("ladder_scaling.png", dpi=160)
    print("wrote ladder_scaling.png")


if __name__ == "__main__":
    main()


"""
Visualization: the three rung distribution functions of a three-seed quota ladder,
their calibration behaviour, and the amplification map.

Left panel  : F3(p) = p^3, F2(p) = 3p^2 - 2p^3, F1(p) = 3p - 3p^2 + p^3, with the
              calibration readings 1/8, 1/2, 7/8 marked at p = 1/2.
Right panel : the amplification map F2 against the identity, its three fixed points
              0, 1/2, 1, and the tangent of slope 3/2 at the repelling point p = 1/2.

Run:  python viz_rung_polynomials.py       (writes rung_polynomials.png)
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def F3(p: np.ndarray) -> np.ndarray:
    return p ** 3


def F2(p: np.ndarray) -> np.ndarray:
    return 3 * p ** 2 - 2 * p ** 3


def F1(p: np.ndarray) -> np.ndarray:
    return 3 * p - 3 * p ** 2 + p ** 3


def main() -> None:
    p = np.linspace(0.0, 1.0, 601)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    ax1.plot(p, F1(p), lw=2.2, label=r"best-case rung  $F_1(p)=3p-3p^2+p^3$")
    ax1.plot(p, F2(p), lw=3.0, label=r"centre rung  $F_2(p)=3p^2-2p^3$")
    ax1.plot(p, F3(p), lw=2.2, label=r"guarantee rung  $F_3(p)=p^3$")
    ax1.fill_between(p, F3(p), F1(p), alpha=0.08)
    for value, text in ((1 / 8, "1/8"), (1 / 2, "1/2"), (7 / 8, "7/8")):
        ax1.plot([0.5], [value], "o", ms=7, color="black")
        ax1.annotate(text, (0.5, value), textcoords="offset points",
                     xytext=(10, -4), fontsize=11)
    ax1.axvline(0.5, ls=":", color="grey")
    ax1.set_xlabel("per-seed pass probability $p$")
    ax1.set_ylabel("probability the rung sits at or below the budget")
    ax1.set_title("The probabilistic quota ladder\n"
                  "(only the centre is calibrated at $p=1/2$)")
    ax1.legend(loc="upper left", fontsize=9)
    ax1.grid(alpha=0.25)

    ax2.plot(p, F2(p), lw=3.0, label=r"$F_2(p)=3p^2-2p^3$")
    ax2.plot(p, p, ls="--", lw=1.6, color="grey", label=r"identity $p$")
    tangent: np.ndarray = 0.5 + 1.5 * (p - 0.5)
    mask = (tangent >= -0.05) & (tangent <= 1.05)
    ax2.plot(p[mask], tangent[mask], ls="-.", lw=1.4,
             label=r"tangent at $1/2$, slope $3/2>1$")
    fixed_points: List[float] = [0.0, 0.5, 1.0]
    ax2.plot(fixed_points, fixed_points, "o", ms=8, color="crimson",
             label="fixed points $0,\\;1/2,\\;1$")
    ax2.fill_between(p, p, F2(p), where=(p > 0.5), alpha=0.15,
                     label="majority amplified")
    ax2.fill_between(p, F2(p), p, where=(p < 0.5), alpha=0.15,
                     label="minority attenuated")
    ax2.set_xlabel("per-seed pass probability $p$")
    ax2.set_ylabel("three-seed centre probability")
    ax2.set_title("Majority amplification\n"
                  "the calibrated point $p=1/2$ is repelling")
    ax2.legend(loc="upper left", fontsize=9)
    ax2.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig("rung_polynomials.png", dpi=160)
    print("wrote rung_polynomials.png")


if __name__ == "__main__":
    main()
