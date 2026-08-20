"""Assemble PACKAGE.json from the source deliverables in the repository."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


FUTURE_DIRECTIONS = """# Future directions: next-cycle conjectures on PTX-augmented alignment optima

## What this cycle settled

* The two-scale law `|‖q*_{β,γ} − p‖₁ − γ‖d − p‖₁| ≤ e^{(M−L)/β} σ_{p_γ}(r)/β` holds, hence
  `‖q*_{β,γ} − p‖₁ → γ‖d − p‖₁` and the limit is nonzero whenever `γ > 0`, `d ≠ p`.
* The `Θ(σ_p(r)/β)` reading of the reward part is **not** exactly right as a two-sided
  statement: the exact first-order constant is the *mean absolute deviation*,
  `β‖q*_{β,γ} − p_γ‖₁ → MAD_{p_γ}(r)`, and `σ²/(M−L) ≤ MAD ≤ σ` is the sharp sandwich. The
  `Θ(σ/β)` reading survives only up to the dimensionless factor `σ/(M−L)`.
* The floor is model independent: for any anchor `m`, the drift from `p` tends to `‖m − p‖₁`,
  hence the optimum returns to `p` iff the anchor *is* `p`; this covers the geometric mix-in
  `p^{1−γ}d^γ/Z` as well as the arithmetic one.
* The optimum studied is the true maximiser of `q ↦ 𝔼_q[r] − β KL(q ‖ p_γ)`, and the tax also
  appears in reward units: the achieved reward tends to `𝔼_p[r] + γ(𝔼_d[r] − 𝔼_p[r])`.
* The exact `1/β` coefficient of the *total* drift is a signed covariance, so the reward term
  can partially cancel the mix-in term.

## Conjecture A (settled in-cycle, now sharpened to a rate)

The first-order form of Conjecture A was **proved** during this cycle: under the
nondegeneracy hypothesis `p_γ(y) ≠ p(y)` for all `y`,

`β(‖q*_{β,γ} − p‖₁ − γ‖d − p‖₁) → ∑_y sgn(p_γ(y) − p(y))·p_γ(y)(r(y) − 𝔼_{p_γ}r)`,

a *signed* covariance. The key insight is that once the mix-in makes every coordinate of
`q* − p` have a fixed sign for large `β`, the absolute values in `‖·‖₁` become linear, so the
`1/β` correction is a covariance rather than a mean absolute deviation — and hence reward
optimisation can *reduce* the total drift, partially cancelling the PTX tax.

The open successor: the error is `O(β^{-2})` with an explicit constant, and the degenerate
case `p_γ(y) = p(y)` for some `y` contributes an extra `MAD`-type term supported on the
degenerate coordinates, giving
`β(‖q*−p‖₁ − γ‖d−p‖₁) → ∑_{y : p_γ≠p} sgn(·)p_γ(y)(r(y)−𝔼 r) + ∑_{y : p_γ=p} p_γ(y)|r(y)−𝔼 r|`.
Why now: the nondegenerate case is proved and the degenerate coordinates are exactly where
the `MAD` proof applies verbatim, so the two proofs should glue.

## Conjecture B (the alignment tax is unavoidable in reward as well as in distance)

For `γ > 0` and `d ≠ p` there is `c(γ, d, p) > 0`, independent of `β`, with
`𝔼_p[r] − 𝔼_{q*_{β,γ}}[r] ≥ −range(r)·γ‖d − p‖₁/2` and, for the worst-case reward of unit
range, `sup_r (𝔼_{q*}[r] − sup_q 𝔼_q[r]) ≤ −c(γ, d, p)`: the mix-in costs a fixed amount of
achievable reward no matter how the KL penalty is tuned.

The key insight is that the floor proved here is a statement in total variation, and total
variation dualises against bounded statistics; making that duality quantitative in the
reverse direction is the remaining step.

## Further directions

* **Scheduled mix-ins.** Real pipelines vary `γ` over training. The floor should be governed
  by the terminal anchor, but the transient behaviour — and whether an annealed schedule can
  land below the terminal floor — is open.
* **Beyond total variation.** The same two-scale structure should hold in KL, Hellinger and
  Wasserstein distance, with the `O(1)` term given by the corresponding anchor displacement
  and the `1/β` constant by the appropriate dispersion functional.
* **Infinite output spaces.** Extension to countable or continuous spaces requires uniform
  integrability of `e^{r/β}`; routine for bounded rewards, open for unbounded ones.
"""


INTERACTIVE_LAYOUT = r"""
# The Alignment Floor: why a pretraining mix-in never washes out

Suppose you have a language model whose output distribution is $p$ — the *reference policy*,
produced by supervised fine-tuning on human demonstrations. You want it to score better on a
reward $r$. Maximising reward alone is catastrophic, so the standard move is a leash:

$$\max_q \; \mathbb{E}_q[r] \;-\; \beta\,\mathrm{KL}(q\,\|\,p).$$

The parameter $\beta$ is the leash strength. This page is about a single question:

> **Is $\beta$ really a dial that returns you to $p$?**

Without a pretraining mix-in, yes. With one, *no* — and the gap is not a small correction,
it is the leading-order term. Let us build up to that.

---

## 1. The classical picture: the Gibbs tilt

The objective above has a closed-form maximiser, the **exponential (Gibbs) tilt**

$$\pi_\beta(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{\sum_z p(z)\,e^{r(z)/\beta}}.$$

As $\beta\to\infty$ the factor $e^{r(y)/\beta}\to1$ uniformly, so $\pi_\beta\to p$. And the
rate is $1/\beta$: measuring distance by $\|f-g\|_1 = \sum_y|f(y)-g(y)|$, one has
$\|\pi_\beta - p\|_1 = O(\sigma_p(r)/\beta)$, where $\sigma_p(r)$ is the reward's standard
deviation. A flat reward moves nothing; a dispersed reward moves a lot; the leash divides.

<details>
<summary><b>Where does the closed form come from?</b> (Gibbs variational principle)</summary>

Write $Z_\beta = \sum_z p(z)e^{r(z)/\beta}$ and $g = \pi_\beta$. For every distribution $q$,
a two-line algebraic identity — the *free-energy identity* — holds:

$$\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\,\|\,p) \;=\; \beta\log Z_\beta \;-\; \beta\,\mathrm{KL}(q\,\|\,g).$$

The first term on the right does not depend on $q$; the second is nonnegative and vanishes
exactly at $q=g$. So $g$ is the maximiser and the optimal value is $\beta\log Z_\beta$. The
only ingredient is Gibbs' inequality $\mathrm{KL}(q\|s)\ge0$, itself a one-line consequence of
$\log t \le t-1$. See [KL divergence](https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence)
and the [Gibbs measure](https://en.wikipedia.org/wiki/Gibbs_measure).
</details>

---

## 2. The ingredient that breaks the dial

Production alignment pipelines add a **pretraining mix-in**: a fraction $\gamma$ of the
training signal is drawn from the original pretraining distribution $d$, as insurance against
the capability loss that hard reward optimisation causes. Modelled cleanly, the mix-in
replaces the *anchor* of the KL penalty by the mixture

$$p_\gamma \;=\; (1-\gamma)p + \gamma d,$$

and the optimum becomes $q^*_{\beta,\gamma}(y) \propto p_\gamma(y)e^{r(y)/\beta}$. Every
ingredient is standard. Now play with the dial yourself.

{{interactive_demo:0}}

**Things to try.**
1. Set $\gamma=0$ and press *sweep*: the drift curve descends all the way to zero. The dial works.
2. Set $\gamma=0.3$ and sweep again: the curve descends to the dashed magenta line and stops.
   That line is the **floor**, $\gamma\|d-p\|_1$.
3. Choose *pretraining distribution: equal to p*. The floor collapses to zero — because the
   anchor never moved.
4. Choose *reward shape: high where the mix-in cut mass*, and watch the drift curve approach
   the floor **from below**. That is the signed covariance at work (section 5).

---

## 3. The theorem, and why it is almost obvious once you see it

> **Two-scale drift law.** For distributions $p,d$, mix-in fraction $\gamma\in[0,1]$, reward
> with $L\le r\le M$, and every $\beta>0$,
> $$\Bigl|\;\|q^*_{\beta,\gamma}-p\|_1 \;-\; \gamma\|d-p\|_1\;\Bigr| \;\le\; e^{(M-L)/\beta}\,\frac{\sigma_{p_\gamma}(r)}{\beta}.$$
> Consequently $\|q^*_{\beta,\gamma}-p\|_1 \to \gamma\|d-p\|_1$ as $\beta\to\infty$, which is
> nonzero whenever $\gamma>0$ and $d\ne p$.

<details>
<summary><b>Click to reveal the proof</b></summary>

Two facts, glued by the triangle inequality.

**Fact 1 (the anchor displacement is exact).** Pointwise,
$p_\gamma(y)-p(y) = (1-\gamma)p(y)+\gamma d(y) - p(y) = \gamma(d(y)-p(y))$, so taking absolute
values and summing, $\|p_\gamma - p\|_1 = \gamma\|d-p\|_1$. No error term, no $\beta$, no $r$.

**Fact 2 (the tilt is a $1/\beta$ perturbation of its anchor).** Writing
$Z_\beta = \mathbb{E}_m[e^{r/\beta}]$, a line of algebra gives
$$\|\mathrm{tilt}_\beta(m)-m\|_1 = \frac{\mathbb{E}_m\bigl|e^{r/\beta} - Z_\beta\bigr|}{Z_\beta}.$$
The numerator is a mean absolute deviation, at most the standard deviation
$\sigma_m(e^{r/\beta})$ by Cauchy–Schwarz. Now use the convexity estimate
$|e^a - e^b| \le e^{\max(a,b)}|a-b|$ together with the variational fact
$\mathrm{Var}(X)\le\mathbb{E}(X-c)^2$ (take $c = e^{\mathbb{E}_m[r]/\beta}$) to get
$\sigma_m(e^{r/\beta}) \le (e^{M/\beta}/\beta)\,\sigma_m(r)$. The denominator is at least
$e^{L/\beta}$. Dividing gives $e^{(M-L)/\beta}\sigma_m(r)/\beta$.

**Gluing.** $\bigl|\|q^*-p\|_1 - \|p_\gamma-p\|_1\bigr| \le \|q^*-p_\gamma\|_1$ by the reverse
triangle inequality; substitute Facts 1 and 2.

Notice there is no differentiation of the free energy anywhere.
</details>

The structural reason is worth saying in one sentence: **the tilt lives at scale $1/\beta$
and the anchor lives at scale $1$.** Perturbations can be turned off; the starting point of
the optimisation cannot.

{{visualization:0}}

The left panel is the theorem: five values of $\gamma$, five different floors, and the
certified band from the inequality above. The right panel is a surprise we come to in
section 4 — the true constant of the vanishing part is *not* the standard deviation.

---

## 4. The reward-induced part: the constant is the mean absolute deviation

The $\sigma/\beta$ bound is a bound. What is the truth?

> **Sharp drift constant.** For any anchor $m$,
> $$\beta\,\|\mathrm{tilt}_\beta(m)-m\|_1 \;\longrightarrow\; \mathrm{MAD}_m(r) = \mathbb{E}_m\bigl|r-\mathbb{E}_m r\bigr|,$$
> the **mean absolute deviation**. Moreover, for $L\le r\le M$ with $L<M$,
> $$\frac{\sigma_m(r)^2}{M-L} \;\le\; \mathrm{MAD}_m(r) \;\le\; \sigma_m(r).$$

<details>
<summary><b>Why MAD and not σ?</b></summary>

Rescale the pointwise displacement. Since
$\mathrm{tilt}_\beta(m)(y)-m(y) = m(y)(e^{r(y)/\beta}-Z_\beta)/Z_\beta$ and
$\beta(e^{c/\beta}-1)\to c$ (the derivative of $t\mapsto e^{ct}$ at $t=0$), we get
$\beta(e^{r(y)/\beta}-Z_\beta)\to r(y)-\mathbb{E}_m[r]$ while $Z_\beta\to1$. Hence
$$\beta\,\|\mathrm{tilt}_\beta(m)-m\|_1 = \sum_y m(y)\frac{|\beta(e^{r(y)/\beta}-Z_\beta)|}{Z_\beta}
\;\longrightarrow\; \sum_y m(y)\bigl|r(y)-\mathbb{E}_m r\bigr|.$$
The $\ell^1$ norm sees $\mathbb{E}|X|$; only an $\ell^2$ norm would see $\sqrt{\mathbb{E}X^2}$.
The $\sigma$ in the earlier bound came from a Cauchy–Schwarz step, and Cauchy–Schwarz is
lossy. The sandwich quantifies exactly how lossy: the upper half is Cauchy–Schwarz, the lower
half is $|x|^2\le(M-L)|x|$ applied to a centred deviation that cannot exceed the reward range.
So $\Theta(\sigma/\beta)$ is legitimate only up to the dimensionless factor $\sigma/(M-L)$, and
cannot be improved to an equality.
</details>

Everything the expansion needs — floor, sharp constant, sandwich, reward tax — is computable
in one linear pass with no optimisation at all:

{{algorithm:0}}

---

## 5. The twist: reward optimisation can repay part of the tax

The floor is unmovable. The *approach* to it is not.

Once the mix-in moves every coordinate, the sign of $q^*_{\beta,\gamma}(y)-p(y)$ is frozen for
large $\beta$: the tilt is a tiny perturbation of an anchor already strictly on one side of
$p$. The absolute values in $\|\cdot\|_1$ therefore become *linear*, and the $1/\beta$
coefficient collapses to a **signed covariance**.

> **Exact $1/\beta$ correction.** If $p_\gamma(y)\ne p(y)$ for every $y$,
> $$\|q^*_{\beta,\gamma}-p\|_1 \;=\; \gamma\|d-p\|_1 \;+\; \frac1\beta\sum_y \operatorname{sgn}\bigl(p_\gamma(y)-p(y)\bigr)\,p_\gamma(y)\,\bigl(r(y)-\mathbb{E}_{p_\gamma}[r]\bigr) \;+\; o(1/\beta).$$

Unlike a mean absolute deviation, this can be **negative**: if the reward is high exactly on
the outputs whose probability the mix-in reduced, tilting toward the reward pushes those
coordinates back toward $p$, and the total drift shrinks below the floor at finite $\beta$.

{{visualization:1}}

The left panel is the whole story in one image: for large $\beta$ the level sets of the drift
become *horizontal lines* $\gamma = \text{const}$ — the drift has stopped depending on $\beta$
altogether. The right panel rotates the reward from "high where mass was removed" to "high
where mass was added" and shows the coefficient crossing zero.

<details>
<summary><b>What happens at a degenerate coordinate?</b></summary>

If $p_\gamma(y) = p(y)$ for some $y$ — which happens exactly when $d(y)=p(y)$ — the sign of
$q^*(y)-p(y)$ is *not* eventually constant, and that coordinate contributes an absolute value
$p_\gamma(y)|r(y)-\mathbb{E}_{p_\gamma}r|$ rather than a signed term. The conjectured unified
formula sums signed terms over the moved coordinates and absolute values over the degenerate
ones; numerical experiment matches it to eight significant figures. The numerical demo below
exhibits exactly such a case.
</details>

---

## 6. The tax in reward units

Total variation is abstract. Dualising against the reward turns the floor into a number on a
scorecard.

> **Reward-level alignment tax.** If $|r|\le C$, then as $\beta\to\infty$,
> $$\mathbb{E}_{q^*_{\beta,\gamma}}[r] \;\longrightarrow\; \mathbb{E}_p[r] + \gamma\bigl(\mathbb{E}_d[r]-\mathbb{E}_p[r]\bigr).$$

The proof is one line: $|\mathbb{E}_f[h]-\mathbb{E}_g[h]| \le C\|f-g\|_1$ for bounded $h$, so
the achieved reward converges to the *anchor's* reward, which is
$(1-\gamma)\mathbb{E}_p[r]+\gamma\mathbb{E}_d[r]$ by linearity of the mixture.

Since the reference policy was built to score well, typically $\mathbb{E}_d[r] < \mathbb{E}_p[r]$
and the limit sits strictly below $\mathbb{E}_p[r]$. That is the price of the capability
insurance, and now it has a closed form: $\gamma$ times the reward gap between the pretraining
corpus and the reference policy — both estimable before a single step of training.

---

## 7. Is the floor an artifact of how we modelled the mix-in?

No, and the reason is completely general.

> **Return criterion.** For *any* anchor distribution $m$ and bounded reward,
> $\|\mathrm{tilt}_\beta(m)-p\|_1 \to \|m-p\|_1$; hence the optimum returns to $p$
> **if and only if** $m = p$.

Regularising with $(1-\gamma)\mathrm{KL}(q\|p)+\gamma\mathrm{KL}(q\|d)$ instead of mixing data
produces the *geometric* anchor $p^{1-\gamma}d^\gamma/Z$, and the criterion applies verbatim.
Arithmetic mixture, geometric mixture, a second divergence term — every scheme that displaces
the anchor pays a floor equal to that displacement. Escaping requires leaving the anchor at
$p$, which is a genuinely different optimisation problem.

---

## 8. See it all at once

The demo below reproduces every result on a concrete five-output example: the exact mix-in
displacement, the certified two-scale bracket, the floor, the MAD law and its sandwich, the
reward tax, the signed covariance (including a degenerate coordinate), the geometric mix-in,
and a Monte-Carlo check that the closed form really maximises the objective.

{{demo:0}}

---

## What to take away

- $\beta$ and $\gamma$ are **not two dials on the same axis**. $\beta$ controls an
  $O(1/\beta)$ effect; $\gamma$ controls an $O(1)$ effect.
- "We set $\beta$ large, so the aligned model is close to the reference model" is **false**
  whenever $\gamma > 0$ and $d \ne p$. The correct statement is a *lower* bound,
  $\|q^*-p\|_1 \gtrsim \gamma\|d-p\|_1$.
- The floor and the reward tax are both **computable before training**, from $\gamma$,
  $\|d-p\|_1$, and the reward gap.
- The honest first-order constant for the reward-induced drift is the **mean absolute
  deviation**, not the standard deviation; using $\sigma$ over-predicts by a factor between
  $1$ and $(M-L)/\sigma$.
- The $1/\beta$ correction to the total drift is a **signed** covariance, so at finite $\beta$
  the model can sit closer to the reference than the asymptotic floor.

The leash still works. It is just tied to a different post.
"""


def main() -> None:
    package = {
        "title": "The Alignment Floor: A Regularization-Independent Drift Law "
                 "for Pretraining-Mixed RLHF Optima",
        "domain": "Novelty",
        "description": (
            "When a pretraining mix-in of fraction gamma displaces the reference measure of "
            "the KL-regularised alignment objective, the optimum's distance from the "
            "supervised policy splits into a beta-independent floor gamma*||d - p||_1 plus a "
            "reward-induced term of order 1/beta, so no amount of KL regularisation returns "
            "the aligned policy to its reference. The sharp first-order constant of the "
            "reward-induced part is the mean absolute deviation, not the standard deviation."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-20",
        "key_results": [
            "Two-scale drift law: the distance of the pretraining-mixed optimum from the "
            "supervised policy differs from gamma times the total-variation distance between "
            "the pretraining and supervised distributions by at most "
            "exp((M-L)/beta) times the reward standard deviation divided by beta.",
            "The alignment floor: the drift converges to gamma times the distance between the "
            "pretraining and supervised distributions, which is strictly positive whenever the "
            "mix-in fraction is positive and the two distributions differ; the KL coefficient "
            "cannot return the optimum to its reference.",
            "Model independence of the floor: for every anchor distribution the drift from the "
            "supervised policy tends to the anchor's own displacement, so the optimum returns "
            "to the supervised policy if and only if the anchor equals it, covering the "
            "geometric mix-in as well as the arithmetic one.",
            "The sharp constant of the reward-induced drift is the mean absolute deviation of "
            "the reward, not its standard deviation, with the exact sandwich "
            "variance over range at most mean absolute deviation at most standard deviation.",
            "The reward-level alignment tax: the achieved reward converges to the supervised "
            "policy's reward plus gamma times the reward gap between the pretraining "
            "distribution and the supervised policy, a shift independent of the KL coefficient.",
            "The exact 1/beta correction to the floor is a signed covariance between the "
            "reward and the direction of the anchor displacement, and may be negative, so "
            "reward optimisation can partially cancel the pretraining tax.",
        ],
        "keywords": [
            "RLHF",
            "KL regularisation",
            "Gibbs variational principle",
            "pretraining mix-in",
            "total variation",
            "mean absolute deviation",
            "alignment tax",
            "exponential tilting",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": [
            {
                "name": "End-to-End Verification of the Two-Scale Drift Law on a "
                        "Five-Output Policy Space",
                "description": (
                    "A self-contained numerical laboratory for the pretraining-mixed alignment "
                    "optimum on a five-element output space. It (i) confirms that the mix-in "
                    "displaces the anchor by exactly gamma times the distance between the "
                    "pretraining and supervised distributions, with no error term; (ii) tabulates "
                    "the total drift against the beta-independent floor and checks the rigorous "
                    "two-scale envelope at nine values of the KL coefficient, contrasting with "
                    "the mix-in-free case where the drift genuinely vanishes; (iii) shows the "
                    "rescaled reward-induced drift converging to the mean absolute deviation "
                    "rather than to the standard deviation, and verifies the sandwich between "
                    "variance-over-range and standard deviation; (iv) exhibits the achieved "
                    "reward settling at the supervised reward plus the beta-independent tax; "
                    "(v) compares the observed 1/beta correction against the predicted signed "
                    "covariance both for a fully nondegenerate mix-in and for a mix-in with one "
                    "degenerate coordinate, where the coefficient acquires an absolute-value "
                    "term; (vi) reproduces the same floor for the geometric mix-in anchor, "
                    "demonstrating model independence; (vii) checks by Monte-Carlo search over "
                    "twenty thousand random competing policies that the closed-form optimum "
                    "really maximises the objective, and that the optimal value equals "
                    "beta times the log partition function; and (viii) prints training-free "
                    "certified brackets for the drift. Standard library only."
                ),
                "code": read(ROOT / "demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Stabilised Gibbs Tilting, Certified Drift Bracketing, and the "
                        "Asymptotic Panel of the Two-Scale Expansion",
                "description": (
                    "Three linear-time procedures that together turn the theory into a "
                    "practical toolkit. (A) The exact optimum: form the mixture anchor "
                    "p_gamma = (1-gamma)p + gamma d, exponentiate the reward at inverse "
                    "temperature 1/beta after subtracting max(r) — a shift that cancels "
                    "identically in the normalisation, so the result is exact while no "
                    "exponential can overflow for any beta > 0 — and renormalise. Two passes, "
                    "O(n) time and space. (B) The certified bracket: without optimising at all, "
                    "compute the floor gamma*||d-p||_1 and the envelope "
                    "exp((M-L)/beta)*sigma/beta and return the interval that provably contains "
                    "the drift; the bracket is valid for every beta > 0, not merely "
                    "asymptotically, and its width shrinks like 1/beta. (C) The asymptotic "
                    "panel: in a single O(n) pass, return the floor, the mean absolute "
                    "deviation that is the sharp constant of the reward-induced drift, the "
                    "standard deviation and the exact sandwich around the mean absolute "
                    "deviation, the dimensionless dispersion ratio measuring how far the "
                    "Theta(sigma/beta) reading is two-sided, the exact 1/beta coefficient of "
                    "the total drift as a signed covariance (with absolute values inserted on "
                    "degenerate coordinates where the anchor coincides with the reference "
                    "policy), the list of those degenerate coordinates, and the reward-unit tax "
                    "together with the limiting achieved reward. Together these predict the "
                    "drift to o(1/beta) and the achieved reward to o(1) with no optimisation "
                    "performed whatsoever."
                ),
                "pseudocode": (
                    "ALGORITHM A: PTX-OPTIMUM(p, d, r, beta, gamma)\n"
                    "  require beta > 0 and 0 <= gamma <= 1\n"
                    "  1  for each y:  anchor[y] <- (1 - gamma) * p[y] + gamma * d[y]\n"
                    "  2  rmax <- max_y r[y]\n"
                    "  3  for each y:  w[y] <- anchor[y] * exp((r[y] - rmax) / beta)\n"
                    "  4  Z <- sum_y w[y]\n"
                    "  5  return [ w[y] / Z : y ]\n"
                    "\n"
                    "ALGORITHM B: DRIFT-CERTIFICATE(p, d, r, beta, gamma)\n"
                    "  1  anchor <- (1 - gamma) * p + gamma * d\n"
                    "  2  floor  <- gamma * sum_y |d[y] - p[y]|\n"
                    "  3  L <- min_y r[y];  M <- max_y r[y]\n"
                    "  4  mu <- sum_y anchor[y] * r[y]\n"
                    "  5  sigma <- sqrt( sum_y anchor[y] * (r[y] - mu)^2 )\n"
                    "  6  envelope <- exp((M - L) / beta) * sigma / beta\n"
                    "  7  return ( max(0, floor - envelope), floor + envelope )\n"
                    "      // the true drift ||q* - p||_1 lies in this interval, for every beta > 0\n"
                    "\n"
                    "ALGORITHM C: ASYMPTOTIC-PANEL(p, d, r, gamma, tol)\n"
                    "  1  anchor <- (1 - gamma) * p + gamma * d\n"
                    "  2  L <- min_y r[y];  M <- max_y r[y];  range <- M - L\n"
                    "  3  mu    <- sum_y anchor[y] * r[y]\n"
                    "  4  sigma <- sqrt( sum_y anchor[y] * (r[y] - mu)^2 )\n"
                    "  5  MAD   <- sum_y anchor[y] * |r[y] - mu|\n"
                    "  6  coefficient <- 0;  degenerate <- empty list\n"
                    "  7  for each y:\n"
                    "  8      if |anchor[y] - p[y]| <= tol then\n"
                    "  9          append y to degenerate\n"
                    " 10          coefficient <- coefficient + anchor[y] * |r[y] - mu|\n"
                    " 11      else\n"
                    " 12          s <- +1 if anchor[y] > p[y] else -1\n"
                    " 13          coefficient <- coefficient + s * anchor[y] * (r[y] - mu)\n"
                    " 14  tax <- gamma * ( sum_y d[y]*r[y] - sum_y p[y]*r[y] )\n"
                    " 15  return record with\n"
                    "         floor             = gamma * sum_y |d[y] - p[y]|\n"
                    "         anchor_mad        = MAD\n"
                    "         anchor_sd         = sigma\n"
                    "         sandwich          = ( sigma^2 / range , sigma )\n"
                    "         dispersion_ratio  = sigma / range\n"
                    "         drift_coefficient = coefficient\n"
                    "         degenerate        = degenerate\n"
                    "         reward_tax        = tax\n"
                    "         reward_limit      = sum_y p[y]*r[y] + tax\n"
                    "\n"
                    "PREDICTION:  ||q*_{beta,gamma} - p||_1  =  floor + drift_coefficient / beta"
                    "  +  o(1/beta)"
                ),
                "code": read(ASSETS / "algorithms.py"),
            }
        ],
        "visualizations": [
            {
                "name": "The Two-Scale Drift Law and the Sharpness of the Mean "
                        "Absolute Deviation",
                "description": (
                    "A two-panel figure. The left panel plots the distance of the "
                    "pretraining-mixed optimum from the supervised policy against the KL "
                    "coefficient on a logarithmic axis, for five mix-in fractions, with each "
                    "curve's beta-independent floor drawn as a dotted horizontal line and the "
                    "rigorously certified band shaded for the largest fraction. The "
                    "mix-in-free curve descends to zero; every other curve descends only to its "
                    "floor, and — because the 1/beta coefficient is negative for this reward — "
                    "several curves dip below their floor before rising back to it. The right "
                    "panel plots the rescaled reward-induced drift against the KL coefficient "
                    "together with the three horizontal levels of the sandwich: the classical "
                    "standard-deviation bound, the true limiting mean absolute deviation, and "
                    "the variance-over-range lower end. The curve visibly converges to the "
                    "middle level, demonstrating that the standard-deviation bound is not "
                    "attained."
                ),
                "code": read(ASSETS / "viz_two_scale.py"),
            },
            {
                "name": "Phase Portrait of the Drift and the Sign Map of the 1/beta Correction",
                "description": (
                    "A two-panel figure exposing the two-scale structure globally. The left "
                    "panel is a heat map with contours of the drift over the rectangle spanned "
                    "by the logarithm of the KL coefficient and the mix-in fraction: at small "
                    "KL coefficient the level sets are steep, because reward optimisation "
                    "dominates, while at large KL coefficient they straighten into horizontal "
                    "lines of constant mix-in fraction — a direct picture of the drift ceasing "
                    "to depend on the regularisation strength at all. The right panel rotates "
                    "the reward continuously between two extremes, one placing high reward "
                    "exactly where the mix-in removed probability mass and one where it added "
                    "mass, and plots the exact 1/beta coefficient of the total drift for four "
                    "mix-in fractions. The coefficient crosses zero: in the shaded region it is "
                    "negative, meaning that at finite regularisation strength the optimum sits "
                    "closer to the supervised policy than the asymptotic floor, because reward "
                    "optimisation partially repays the pretraining tax."
                ),
                "code": read(ASSETS / "viz_phase.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Alignment Floor Explorer: Turn the KL Dial to Infinity and "
                         "Watch the Model Fail to Come Home",
                "description": (
                    "A live laboratory for the two-scale drift law on a five-output policy "
                    "space. Sliders control the KL coefficient (logarithmically, over four "
                    "decades), the pretraining mix-in fraction, and the reward spread; dropdowns "
                    "select the pretraining distribution — including the degenerate choice equal "
                    "to the supervised policy, which collapses the floor to zero — and the "
                    "reward shape, including one deliberately placed high where the mix-in "
                    "removed probability mass. Three synchronised panels update continuously: a "
                    "bar chart of the supervised policy, the mixture anchor and the optimum "
                    "side by side; a drift-versus-KL-coefficient curve with the floor drawn as a "
                    "dashed line, the certified two-scale band shaded, and the mix-in-free curve "
                    "overlaid for contrast; and a rescaled-drift panel showing convergence to "
                    "the mean absolute deviation strictly below the classical standard-deviation "
                    "bound and above the variance-over-range level. A live readout displays the "
                    "expansion floor plus signed-covariance-over-beta with its sign interpreted "
                    "in words, alongside the achieved reward and the beta-independent reward "
                    "tax. A sweep button animates the KL coefficient to infinity so the failure "
                    "to return to the reference policy can be seen rather than merely computed. "
                    "Three collapsible sections give the full proofs of the floor, of the "
                    "mean-absolute-deviation law, and of the sign change in the correction."
                ),
                "html": read(ASSETS / "widget_floor.html"),
            }
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": read(ROOT / "Catalog" / "Novelty" / "RLHFPretrainingMixIn.lean"),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": read(ROOT / "demo.py"),
            "algorithms": read(ASSETS / "algorithms.py"),
            "visualization_two_scale": read(ASSETS / "viz_two_scale.py"),
            "visualization_phase": read(ASSETS / "viz_phase.py"),
        },
        "lean_files": ["Catalog/Novelty/RLHFPretrainingMixIn.lean"],
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
Visualization: the (beta, gamma) phase portrait of the alignment drift, and the
sign map of the 1/beta correction.

Left panel
    A heat map of ||q*_{beta,gamma} - p||_1 over the rectangle
    (log10 beta) x gamma.  Contours make the two-scale structure visible: for
    large beta the level sets become horizontal lines gamma = const, because the
    drift no longer depends on beta at all --- it has reached the floor
    gamma ||d - p||_1.  For small beta the level sets bend, because reward
    optimisation dominates.

Right panel
    The sign of the exact 1/beta coefficient
        sum_y sgn(p_gamma(y) - p(y)) p_gamma(y) (r(y) - E_{p_gamma}[r])
    as the reward is rotated between two extremes: r aligned with the direction
    in which the mix-in ADDED mass, and r aligned with the direction in which it
    REMOVED mass.  Where the coefficient is negative, the finite-beta optimum is
    CLOSER to the reference policy than the asymptotic floor: reward
    optimisation partially repays the pretraining tax.

Requires numpy and matplotlib.
"""

from __future__ import annotations

from typing import Sequence

import matplotlib.pyplot as plt
import numpy as np


def normalise(v: Sequence[float]) -> np.ndarray:
    a = np.asarray(v, dtype=float)
    return a / a.sum()


def mix(gamma: float, p: np.ndarray, d: np.ndarray) -> np.ndarray:
    return (1.0 - gamma) * p + gamma * d


def gibbs_tilt(beta: float, m: np.ndarray, r: np.ndarray) -> np.ndarray:
    w = m * np.exp((r - r.max()) / beta)
    return w / w.sum()


def l1(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.abs(a - b).sum())


def signed_coefficient(gamma: float, p: np.ndarray, d: np.ndarray, r: np.ndarray) -> float:
    """sum_y sgn(p_gamma - p) p_gamma (r - E_{p_gamma} r), with |.| on degenerate coords."""
    pg = mix(gamma, p, d)
    mu = float((pg * r).sum())
    total = 0.0
    for pgi, pi, ri in zip(pg, p, r):
        if abs(pgi - pi) <= 1e-12:
            total += pgi * abs(ri - mu)
        else:
            total += (1.0 if pgi > pi else -1.0) * pgi * (ri - mu)
    return total


def main() -> None:
    p = normalise([0.40, 0.25, 0.20, 0.10, 0.05])
    d = normalise([0.10, 0.15, 0.22, 0.23, 0.30])
    r = np.array([3.0, 1.0, 0.0, -1.0, -2.0])

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    # -------- left: phase portrait --------
    logb = np.linspace(-0.3, 3.4, 220)
    gams = np.linspace(0.0, 1.0, 200)
    Z = np.zeros((gams.size, logb.size))
    for i, g in enumerate(gams):
        pg = mix(g, p, d)
        for j, lb in enumerate(logb):
            Z[i, j] = l1(gibbs_tilt(10.0**lb, pg, r), p)

    im = ax0.pcolormesh(logb, gams, Z, shading="auto", cmap="magma")
    cs = ax0.contour(logb, gams, Z, levels=[0.05, 0.15, 0.3, 0.5, 0.8, 1.1],
                     colors="white", linewidths=1.0, alpha=0.7)
    ax0.clabel(cs, inline=True, fontsize=8, fmt="%.2f")
    ax0.set_xlabel(r"$\log_{10}\beta$")
    ax0.set_ylabel(r"mix-in fraction $\gamma$")
    ax0.set_title(r"$\|q^*_{\beta,\gamma}-p\|_1$: level sets flatten as $\beta\to\infty$")
    fig.colorbar(im, ax=ax0, label=r"$\ell^1$ drift")

    # -------- right: sign of the 1/beta coefficient --------
    thetas = np.linspace(0.0, 1.0, 240)
    disp = mix(0.5, p, d) - p           # direction the mix-in moves the anchor
    r_plus = 4.0 * disp / np.abs(disp).max()      # reward aligned with added mass
    r_minus = -r_plus                              # reward aligned with removed mass
    gam_list = [0.1, 0.25, 0.5, 0.8]
    for g, col in zip(gam_list, plt.cm.coolwarm(np.linspace(0.1, 0.9, len(gam_list)))):
        vals = [signed_coefficient(g, p, d, (1 - t) * r_minus + t * r_plus) for t in thetas]
        ax1.plot(thetas, vals, lw=2.2, color=col, label=rf"$\gamma={g}$")
    ax1.axhline(0.0, color="black", lw=1.2)
    ax1.fill_between(thetas, -1e3, 0, color="#22c55e", alpha=0.08)
    ax1.text(0.03, 0.06, "coefficient < 0:\nreward repays part of the tax",
             transform=ax1.transAxes, fontsize=9, color="#166534")
    ax1.set_ylim(
        min(-0.1, 1.15 * min(signed_coefficient(0.8, p, d, r_minus), 0.0)),
        1.15 * max(signed_coefficient(0.8, p, d, r_plus), 0.1),
    )
    ax1.set_xlabel("reward rotated: high where mass was removed (0)\n"
                   "to high where mass was added (1)")
    ax1.set_ylabel(r"$1/\beta$ coefficient of the total drift")
    ax1.set_title("The correction is a signed covariance")
    ax1.grid(alpha=0.22)
    ax1.legend(fontsize=9)

    fig.tight_layout()
    fig.savefig("alignment_floor_phase.png", dpi=170)
    print("wrote alignment_floor_phase.png")


if __name__ == "__main__":
    main()


"""
Visualization: the two-scale drift law and the alignment floor.

Produces a two-panel figure.

Left panel
    ||q*_{beta,gamma} - p||_1 as a function of beta, on a logarithmic beta axis,
    for several mix-in fractions gamma, together with the horizontal floors
    gamma * ||d - p||_1 and the rigorously certified band
        [ floor - E(beta),  floor + E(beta) ],   E(beta) = e^{(M-L)/beta} sigma / beta,
    for the largest gamma shown.  The gamma = 0 curve descends to zero; every
    gamma > 0 curve descends only to its floor.

Right panel
    The rescaled reward-induced drift beta * ||q* - p_gamma||_1 against beta,
    with the three horizontal reference levels of the sandwich
        sigma^2/(M-L)  <=  MAD  <=  sigma.
    The curve converges to MAD, strictly below the classical sigma bound.

Requires numpy and matplotlib.
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def normalise(v: Sequence[float]) -> np.ndarray:
    a = np.asarray(v, dtype=float)
    return a / a.sum()


def mix(gamma: float, p: np.ndarray, d: np.ndarray) -> np.ndarray:
    return (1.0 - gamma) * p + gamma * d


def gibbs_tilt(beta: float, m: np.ndarray, r: np.ndarray) -> np.ndarray:
    w = m * np.exp((r - r.max()) / beta)
    return w / w.sum()


def l1(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.abs(a - b).sum())


def mean(p: np.ndarray, f: np.ndarray) -> float:
    return float((p * f).sum())


def sd(p: np.ndarray, f: np.ndarray) -> float:
    mu = mean(p, f)
    return float(np.sqrt((p * (f - mu) ** 2).sum()))


def mad(p: np.ndarray, f: np.ndarray) -> float:
    mu = mean(p, f)
    return float((p * np.abs(f - mu)).sum())


def main() -> None:
    p = normalise([0.40, 0.25, 0.20, 0.10, 0.05])
    d = normalise([0.10, 0.15, 0.22, 0.23, 0.30])
    r = np.array([3.0, 1.0, 0.0, -1.0, -2.0])
    lo, hi = float(r.min()), float(r.max())

    betas = np.logspace(-0.3, 3.6, 500)
    gammas: List[float] = [0.0, 0.05, 0.15, 0.30, 0.50]
    colours = plt.cm.viridis(np.linspace(0.15, 0.9, len(gammas)))

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    # ---------------- left panel ----------------
    for g, col in zip(gammas, colours):
        pg = mix(g, p, d)
        drift = [l1(gibbs_tilt(b, pg, r), p) for b in betas]
        ax0.plot(betas, drift, color=col, lw=2.1, label=rf"$\gamma={g:.2f}$")
        floor = g * l1(d, p)
        if g > 0:
            ax0.axhline(floor, color=col, ls=":", lw=1.4, alpha=0.85)

    g_band = gammas[-1]
    pg = mix(g_band, p, d)
    floor = g_band * l1(d, p)
    env = np.exp((hi - lo) / betas) * sd(pg, r) / betas
    ax0.fill_between(
        betas,
        np.maximum(0.0, floor - env),
        floor + env,
        color=colours[-1],
        alpha=0.13,
        label="certified band",
    )

    ax0.set_xscale("log")
    ax0.set_xlabel(r"KL coefficient $\beta$")
    ax0.set_ylabel(r"$\|q^*_{\beta,\gamma}-p\|_1$")
    ax0.set_title("Two-scale drift law: the floor does not vanish")
    ax0.set_ylim(0, 1.35)
    ax0.grid(alpha=0.22)
    ax0.legend(fontsize=9, loc="upper right")

    # ---------------- right panel ----------------
    g = 0.20
    pg = mix(g, p, d)
    resc = [b * l1(gibbs_tilt(b, pg, r), pg) for b in betas]
    ax1.plot(betas, resc, color="#0f766e", lw=2.4,
             label=r"$\beta\,\|q^*_{\beta,\gamma}-p_\gamma\|_1$")
    m_val, s_val = mad(pg, r), sd(pg, r)
    ax1.axhline(s_val, color="#dc2626", ls="--", lw=1.6,
                label=rf"$\sigma={s_val:.4f}$ (classical bound)")
    ax1.axhline(m_val, color="#7c3aed", ls="-.", lw=1.8,
                label=rf"MAD $={m_val:.4f}$ (sharp constant)")
    ax1.axhline(s_val**2 / (hi - lo), color="#64748b", ls=":", lw=1.6,
                label=rf"$\sigma^2/(M-L)={s_val**2/(hi-lo):.4f}$")
    ax1.set_xscale("log")
    ax1.set_xlabel(r"KL coefficient $\beta$")
    ax1.set_ylabel("rescaled reward-induced drift")
    ax1.set_title("The sharp constant is the mean absolute deviation")
    ax1.set_ylim(0, s_val * 1.45)
    ax1.grid(alpha=0.22)
    ax1.legend(fontsize=9, loc="lower right")

    fig.suptitle(
        "A pretraining mix-in of fraction $\\gamma$ puts a $\\beta$-independent floor "
        "$\\gamma\\|d-p\\|_1$ under the alignment drift",
        fontsize=12.5,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("alignment_floor.png", dpi=170)
    print("wrote alignment_floor.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstration of the two-scale drift law for the PTX-augmented
KL-regularised alignment optimum.

Setting
-------
On a finite output space of size n we are given

    p      -- the supervised reference policy (a probability vector),
    d      -- the pretraining distribution (a probability vector),
    r      -- a bounded reward vector,
    gamma  -- the pretraining mix-in fraction in [0, 1],
    beta   -- the KL regularisation strength, beta > 0.

The mix-in displaces the reference measure of the KL penalty to the mixture

    p_gamma = (1 - gamma) * p + gamma * d,

and the maximiser of  q |-> E_q[r] - beta * KL(q || p_gamma)  is the Gibbs tilt

    q*(y)  proportional to  p_gamma(y) * exp(r(y) / beta).

Results demonstrated
--------------------
1.  Exact mix-in displacement:      ||p_gamma - p||_1 = gamma * ||d - p||_1.
2.  Two-scale drift law:            | ||q* - p||_1 - gamma||d - p||_1 |
                                        <= exp((M-L)/beta) * sigma_{p_gamma}(r) / beta.
3.  The alignment floor:            ||q* - p||_1 -> gamma * ||d - p||_1  as beta -> oo,
                                    which is nonzero when gamma > 0 and d != p.
4.  Sharp reward-drift constant:    beta * ||q* - p_gamma||_1 -> MAD_{p_gamma}(r),
                                    the MEAN ABSOLUTE DEVIATION, not the standard deviation,
                                    with sandwich  sigma^2/(M-L) <= MAD <= sigma.
5.  Reward-level alignment tax:     E_{q*}[r] -> E_p[r] + gamma * (E_d[r] - E_p[r]).
6.  Signed covariance correction:   beta * ( ||q* - p||_1 - gamma||d - p||_1 )
                                        -> sum_y sgn(p_gamma(y) - p(y)) p_gamma(y)
                                                 (r(y) - E_{p_gamma}[r]),
                                    which can be NEGATIVE.
7.  Model independence:             for the geometric mix-in p^(1-gamma) d^gamma / Z the
                                    same floor appears, equal to the anchor displacement.
8.  Gibbs variational principle:    q* beats random competitors on the PTX objective.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Vector = List[float]

# ----------------------------------------------------------------------------
# Basic functionals
# ----------------------------------------------------------------------------


def normalise(v: Sequence[float]) -> Vector:
    """Rescale a nonnegative vector to unit total mass."""
    total = sum(v)
    if total <= 0.0:
        raise ValueError("cannot normalise a vector of nonpositive total mass")
    return [x / total for x in v]


def mean(p: Sequence[float], f: Sequence[float]) -> float:
    """E_p[f] = sum_y p(y) f(y)."""
    return sum(pi * fi for pi, fi in zip(p, f))


def variance(p: Sequence[float], f: Sequence[float]) -> float:
    """Var_p(f) = sum_y p(y) (f(y) - E_p f)^2."""
    mu = mean(p, f)
    return sum(pi * (fi - mu) ** 2 for pi, fi in zip(p, f))


def sd(p: Sequence[float], f: Sequence[float]) -> float:
    """sigma_p(f) = sqrt(Var_p(f))."""
    return math.sqrt(variance(p, f))


def mad(p: Sequence[float], f: Sequence[float]) -> float:
    """MAD_p(f) = sum_y p(y) |f(y) - E_p f|, the mean absolute deviation."""
    mu = mean(p, f)
    return sum(pi * abs(fi - mu) for pi, fi in zip(p, f))


def l1(f: Sequence[float], g: Sequence[float]) -> float:
    """Unnormalised total variation distance ||f - g||_1 = sum_y |f(y) - g(y)|."""
    return sum(abs(fi - gi) for fi, gi in zip(f, g))


def kl(q: Sequence[float], s: Sequence[float]) -> float:
    """KL(q || s) = sum_y q(y) log(q(y)/s(y)), with 0 log 0 = 0."""
    total = 0.0
    for qi, si in zip(q, s):
        if qi > 0.0:
            total += qi * math.log(qi / si)
    return total


# ----------------------------------------------------------------------------
# The PTX optimum and its anchors
# ----------------------------------------------------------------------------


def mix(gamma: float, p: Sequence[float], d: Sequence[float]) -> Vector:
    """The arithmetic mix-in anchor p_gamma = (1 - gamma) p + gamma d."""
    return [(1.0 - gamma) * pi + gamma * di for pi, di in zip(p, d)]


def geo_mix(gamma: float, p: Sequence[float], d: Sequence[float]) -> Vector:
    """The geometric (log-linear) mix-in anchor p^(1-gamma) d^gamma / Z."""
    raw = [pi ** (1.0 - gamma) * di**gamma for pi, di in zip(p, d)]
    return normalise(raw)


def gibbs_tilt(beta: float, m: Sequence[float], r: Sequence[float]) -> Vector:
    """
    The Gibbs tilt  tilt_beta(m)(y) proportional to m(y) exp(r(y)/beta).

    The maximum of r is subtracted inside the exponential for numerical
    stability; the shift cancels exactly in the normalisation.
    """
    if beta <= 0.0:
        raise ValueError("beta must be strictly positive")
    rmax = max(r)
    weights = [mi * math.exp((ri - rmax) / beta) for mi, ri in zip(m, r)]
    return normalise(weights)


def ptx_opt(
    beta: float, gamma: float, p: Sequence[float], d: Sequence[float], r: Sequence[float]
) -> Vector:
    """The PTX-augmented optimum q*_{beta,gamma} = tilt_beta(p_gamma)."""
    return gibbs_tilt(beta, mix(gamma, p, d), r)


def ptx_objective(
    q: Sequence[float],
    beta: float,
    gamma: float,
    p: Sequence[float],
    d: Sequence[float],
    r: Sequence[float],
) -> float:
    """The PTX objective  E_q[r] - beta * KL(q || p_gamma)."""
    return mean(q, r) - beta * kl(q, mix(gamma, p, d))


# ----------------------------------------------------------------------------
# Certificates and asymptotic panel
# ----------------------------------------------------------------------------


def drift_envelope(
    beta: float, gamma: float, p: Sequence[float], d: Sequence[float], r: Sequence[float]
) -> float:
    """The rigorous two-scale envelope exp((M-L)/beta) * sigma_{p_gamma}(r) / beta."""
    pg = mix(gamma, p, d)
    lo, hi = min(r), max(r)
    return math.exp((hi - lo) / beta) * sd(pg, r) / beta


def drift_certificate(
    beta: float, gamma: float, p: Sequence[float], d: Sequence[float], r: Sequence[float]
) -> Tuple[float, float]:
    """A certified interval containing ||q*_{beta,gamma} - p||_1, computed without optimising."""
    floor_value = gamma * l1(d, p)
    env = drift_envelope(beta, gamma, p, d, r)
    return (max(0.0, floor_value - env), floor_value + env)


def signed_covariance(
    gamma: float,
    p: Sequence[float],
    d: Sequence[float],
    r: Sequence[float],
    tol: float = 1e-12,
) -> float:
    """
    The exact 1/beta coefficient of the total drift ||q* - p||_1 - gamma||d - p||_1.

    On coordinates where the mix-in actually moves the anchor (p_gamma(y) != p(y))
    the contribution is the SIGNED term

        sgn(p_gamma(y) - p(y)) * p_gamma(y) * (r(y) - E_{p_gamma}[r]),

    because the sign of q*(y) - p(y) is frozen for large beta and the absolute
    value becomes linear.  On DEGENERATE coordinates, where p_gamma(y) = p(y),
    the sign is not eventually constant and the contribution is the absolute value

        p_gamma(y) * |r(y) - E_{p_gamma}[r]|,

    exactly as in the mean-absolute-deviation law.  The signed part can be
    negative; the degenerate part never is.
    """
    pg = mix(gamma, p, d)
    mu = mean(pg, r)
    total = 0.0
    for pgi, pi, ri in zip(pg, p, r):
        if abs(pgi - pi) <= tol:
            total += pgi * abs(ri - mu)
        else:
            sign = 1.0 if pgi > pi else -1.0
            total += sign * pgi * (ri - mu)
    return total


def degenerate_coordinates(
    gamma: float, p: Sequence[float], d: Sequence[float], tol: float = 1e-12
) -> List[int]:
    """Indices y at which the mix-in leaves the anchor unmoved, p_gamma(y) = p(y)."""
    pg = mix(gamma, p, d)
    return [i for i, (pgi, pi) in enumerate(zip(pg, p)) if abs(pgi - pi) <= tol]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


P: Vector = normalise([0.40, 0.25, 0.20, 0.10, 0.05])
D: Vector = normalise([0.10, 0.15, 0.20, 0.25, 0.30])
R: Vector = [3.0, 1.0, 0.0, -1.0, -2.0]
GAMMA: float = 0.20


def demo_exact_mix_displacement() -> None:
    rule("1.  Exact mix-in displacement:  ||p_gamma - p||_1 = gamma * ||d - p||_1")
    print(f"    ||d - p||_1                      = {l1(D, P):.12f}")
    for g in (0.0, 0.05, 0.2, 0.5, 1.0):
        lhs = l1(mix(g, P, D), P)
        rhs = g * l1(D, P)
        print(
            f"    gamma = {g:4.2f}:  ||p_gamma - p||_1 = {lhs:.12f}"
            f"   gamma*||d-p||_1 = {rhs:.12f}   error = {abs(lhs - rhs):.2e}"
        )


def demo_two_scale_law() -> None:
    rule("2-3.  Two-scale drift law and the alignment floor")
    floor_value = GAMMA * l1(D, P)
    print(f"    gamma = {GAMMA}, floor gamma*||d-p||_1 = {floor_value:.9f}")
    print()
    print(f"    {'beta':>10} {'||q*-p||_1':>14} {'|drift-floor|':>15} {'envelope':>13} {'ok':>4}")
    for beta in (0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 200.0, 1000.0, 10000.0):
        q = ptx_opt(beta, GAMMA, P, D, R)
        drift = l1(q, P)
        gap = abs(drift - floor_value)
        env = drift_envelope(beta, GAMMA, P, D, R)
        print(f"    {beta:10.1f} {drift:14.9f} {gap:15.9f} {env:13.9f} {'yes' if gap <= env + 1e-12 else 'NO':>4}")
    print()
    print("    The drift converges to the floor, never to 0:  the KL coefficient")
    print("    cannot bring the PTX-augmented optimum back to the reference policy.")
    print(f"    Contrast gamma = 0 (no mix-in), where the drift does vanish:")
    for beta in (1.0, 10.0, 100.0, 1000.0):
        print(f"        beta = {beta:7.1f}:  ||q*-p||_1 = {l1(ptx_opt(beta, 0.0, P, D, R), P):.9f}")


def demo_sharp_constant() -> None:
    rule("4.  The sharp reward-drift constant is the MEAN ABSOLUTE DEVIATION")
    pg = mix(GAMMA, P, D)
    m_val, s_val = mad(pg, R), sd(pg, R)
    rng = max(R) - min(R)
    print(f"    MAD_{{p_gamma}}(r)        = {m_val:.9f}")
    print(f"    sigma_{{p_gamma}}(r)      = {s_val:.9f}")
    print(f"    sigma^2/(M-L)          = {s_val**2 / rng:.9f}   (lower end of the sandwich)")
    print(f"    sandwich sigma^2/(M-L) <= MAD <= sigma holds: "
          f"{s_val**2 / rng <= m_val + 1e-12 <= s_val + 1e-12}")
    print()
    print(f"    {'beta':>10} {'beta*||q*-p_gamma||_1':>24} {'MAD':>12} {'sigma':>12}")
    for beta in (1.0, 10.0, 100.0, 1000.0, 100000.0):
        q = ptx_opt(beta, GAMMA, P, D, R)
        print(f"    {beta:10.1f} {beta * l1(q, pg):24.9f} {m_val:12.9f} {s_val:12.9f}")
    print()
    print("    The rescaled drift converges to MAD, strictly below the sigma bound.")


def demo_reward_tax() -> None:
    rule("5.  The reward-level alignment tax")
    limit = mean(P, R) + GAMMA * (mean(D, R) - mean(P, R))
    print(f"    E_p[r]                       = {mean(P, R):.9f}")
    print(f"    E_d[r]                       = {mean(D, R):.9f}")
    print(f"    gamma*(E_d[r] - E_p[r])      = {GAMMA * (mean(D, R) - mean(P, R)):.9f}  (the tax)")
    print(f"    predicted limit of E_{{q*}}[r] = {limit:.9f}")
    print()
    for beta in (1.0, 10.0, 100.0, 1000.0, 100000.0):
        q = ptx_opt(beta, GAMMA, P, D, R)
        print(f"        beta = {beta:10.1f}:  E_{{q*}}[r] = {mean(q, R):.9f}")
    print()
    print("    The achieved reward settles strictly below E_p[r] because the")
    print("    pretraining distribution scores worse than the reference policy.")


def _correction_table(
    label: str, gamma: float, p: Sequence[float], d: Sequence[float], r: Sequence[float]
) -> None:
    floor_value = gamma * l1(d, p)
    cov = signed_covariance(gamma, p, d, r)
    deg = degenerate_coordinates(gamma, p, d)
    print(f"    {label}")
    print(f"        degenerate coordinates (p_gamma = p): {deg if deg else 'none'}")
    print(f"        predicted coefficient = {cov:+.9f}")
    print(f"        {'beta':>10} {'beta*(drift - floor)':>24}")
    for beta in (100.0, 1000.0, 10000.0, 1000000.0):
        q = ptx_opt(beta, gamma, p, d, r)
        print(f"        {beta:10.1f} {beta * (l1(q, p) - floor_value):+24.9f}")
    print()


def demo_signed_covariance() -> None:
    rule("6.  The exact 1/beta correction is a SIGNED covariance")
    print("    Away from degenerate coordinates the sign of q*(y) - p(y) is frozen for")
    print("    large beta, so the absolute values in the l1 norm become linear and the")
    print("    1/beta coefficient is a covariance between the reward and the direction")
    print("    of the anchor displacement.  Unlike the mean absolute deviation it can")
    print("    be negative: reward optimisation then partially cancels the tax.")
    print()

    d_nondeg = normalise([0.10, 0.15, 0.22, 0.23, 0.30])
    _correction_table(
        "(a) fully nondegenerate mix-in, d = " + str([round(x, 4) for x in d_nondeg]),
        GAMMA,
        P,
        d_nondeg,
        R,
    )
    _correction_table(
        "(b) the running example, which has one degenerate coordinate",
        GAMMA,
        P,
        D,
        R,
    )
    print("    In case (b) the coordinate where p and d agree contributes an absolute")
    print("    value rather than a signed term, exactly as in the MAD law.")
    print()
    print("    Contrast the drift from the ANCHOR, whose coefficient MAD is always")
    print(f"    nonnegative ({mad(mix(GAMMA, P, D), R):.9f} here).  A negative total coefficient means")
    print("    that at finite beta the model sits CLOSER to p than the asymptotic floor.")


def demo_geometric_mix_in() -> None:
    rule("7.  Model independence: the geometric mix-in pays the same kind of floor")
    for g in (0.0, 0.1, 0.3, 0.6, 1.0):
        anchor = geo_mix(g, P, D)
        predicted = l1(anchor, P)
        observed = l1(gibbs_tilt(20000.0, anchor, R), P)
        print(
            f"    gamma = {g:4.2f}:  ||geo anchor - p||_1 = {predicted:.9f}"
            f"   observed drift at beta=2e4 = {observed:.9f}"
        )
    print()
    print("    For every anchor m the drift from p tends to ||m - p||_1, so the")
    print("    optimum returns to p if and only if the anchor IS p.  No")
    print("    reformulation of the mix-in avoids the floor.")


def demo_variational_principle(trials: int = 20000, seed: int = 20260820) -> None:
    rule("8.  Gibbs variational principle: q* maximises the PTX objective")
    rng = random.Random(seed)
    beta = 1.3
    q_star = ptx_opt(beta, GAMMA, P, D, R)
    best = ptx_objective(q_star, beta, GAMMA, P, D, R)
    n = len(P)
    worst_violation = 0.0
    best_competitor = best
    for _ in range(trials):
        raw = [rng.expovariate(1.0) for _ in range(n)]
        q = normalise(raw)
        value = ptx_objective(q, beta, GAMMA, P, D, R)
        best_competitor = max(best_competitor, value)
        worst_violation = max(worst_violation, value - best)
    print(f"    beta = {beta}, gamma = {GAMMA}, random competitors = {trials}")
    print(f"    objective at q*                     = {best:.12f}")
    print(f"    best objective among random q       = {best_competitor:.12f}")
    print(f"    largest violation (should be <= 0)  = {worst_violation:.3e}")
    print(f"    also: beta*log Z_beta               = "
          f"{beta * math.log(sum(mi * math.exp(ri / beta) for mi, ri in zip(mix(GAMMA, P, D), R))):.12f}")
    print("    (the free-energy identity says the optimal value equals beta*log Z_beta)")


def demo_certificate_table() -> None:
    rule("9.  Training-free drift certificates")
    print("    Certified intervals containing ||q* - p||_1, computed from p, d, r alone:")
    print()
    print(f"    {'beta':>8} {'lower':>12} {'actual':>12} {'upper':>12} {'contained':>10}")
    for beta in (1.0, 3.0, 10.0, 30.0, 100.0, 1000.0):
        lo, hi = drift_certificate(beta, GAMMA, P, D, R)
        actual = l1(ptx_opt(beta, GAMMA, P, D, R), P)
        ok = lo - 1e-12 <= actual <= hi + 1e-12
        print(f"    {beta:8.1f} {lo:12.9f} {actual:12.9f} {hi:12.9f} {'yes' if ok else 'NO':>10}")


def main() -> None:
    print("PTX pretraining mix-in: the regularisation-independent alignment floor")
    print()
    print(f"    reference policy p      = {[round(x, 4) for x in P]}")
    print(f"    pretraining d           = {[round(x, 4) for x in D]}")
    print(f"    reward r                = {R}")
    print(f"    mix-in fraction gamma   = {GAMMA}")

    demo_exact_mix_displacement()
    demo_two_scale_law()
    demo_sharp_constant()
    demo_reward_tax()
    demo_signed_covariance()
    demo_geometric_mix_in()
    demo_variational_principle()
    demo_certificate_table()

    rule("Summary")
    print("    ||q* - p||_1  =  gamma*||d - p||_1  +  (signed covariance)/beta  +  o(1/beta),")
    print("    with the leading term independent of beta:  the KL coefficient tunes")
    print("    the reward-induced motion and nothing else.")


if __name__ == "__main__":
    main()
