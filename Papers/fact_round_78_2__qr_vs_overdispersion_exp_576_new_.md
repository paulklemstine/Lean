# How to Prove That an Explanation Cannot Work

*A guided tour of capture ceilings, exact orthogonality, and the arithmetic of clumping.*

---

## 1. The phenomenon: counts that clump

Run a randomized arithmetic search separately for each of $128$ large integers $N$ — each a
product of two primes of equal size, each around $96$ bits — drawing $150{,}000$ samples per
integer and counting "hits". If hits arrived independently at a rate depending only on the
coarse parameters, the counts would be **Poisson**, and Poisson counts satisfy a rigid law:

$$\text{variance} = \text{mean}, \qquad\text{so}\qquad D \;=\; \frac{\operatorname{Var}}{\text{mean}} \;=\; 1 .$$

What was actually observed:

| quantity | value |
|---|---|
| mean hits per integer | $76.7$ |
| dispersion index $D_{\mathrm{raw}}$ | $\mathbf{7.27}$ |
| range | $29$ to $172$ |
| top cluster | $172 / 151 / 130$ |

Seven times too spread out — and it replicates under a completely fresh randomization with a
provably disjoint set of integers. So the clumping is a property of the *arithmetic of each
individual $N$*, not of the random seed.

> **The whole question of this tour:** what carries that clumping, and how do you *prove* that
> a proposed explanation isn't it?

<details>
<summary>Background: what is a dispersion index, and why is Poisson the null?</summary>

A [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution) describes counts
of independent rare events at a fixed rate. Its defining moment property is that variance
equals mean, so $D = 1$ exactly. Values $D > 1$ are called **overdispersion** and indicate
that the rate itself varies between units — some units are systematically richer targets than
others. Values $D < 1$ (underdispersion) indicate a repulsion or regularity in the events.

Here $D = 7.27$ means the per-integer rates are wildly heterogeneous, and the natural next
question is which measurable feature of an integer predicts a high rate.
</details>

---

## 2. The obvious suspect, and the disappointment

The mechanics of this kind of search single out one candidate. A small prime $\ell$ can divide
the quantities the sieve inspects exactly when $N$ is a **quadratic residue** modulo $\ell$ —
that is, when $N$ is a perfect square in the arithmetic of remainders mod $\ell$. So count the
helpful primes:

$$S_{\mathrm{prod}}(N) \;=\; \#\{\ell \le 100 : N \text{ is a quadratic residue mod } \ell\}.$$

Three such **dials** were tested against a pre-registered acceptance bar demanding *both*
$R^2 \ge 0.25$ *and* a dispersion reduction of at least $30\%$:

| dial | $R^2$ | dispersion reduction |
|---|---|---|
| individual-symbol count, $\ell \le 100$ | $0.0127$ | $0.88\%$ |
| product-symbol count, $\ell \le 100$ | $0.0781$ | $\mathbf{14.22\%}$ |
| wider window, $\ell \le 400$ | $0.0565$ | $9.07\%$ |

Every one misses. The lazy conclusion is "the fit was poor". The rest of this page turns that
into something much stronger.

---

## 3. Laboratory: build the phenomenon yourself

Before the theorems, get a feel for the objects. In the laboratory below you generate a clumpy
count sample, give it a dial that knows *part* of the story, and watch two exact laws hold on
live data:

- the **dispersion reduction** is numerically identical to the **explained-variance fraction**
  $\eta^2$ — the two legs of the acceptance bar are one scalar;
- no straight line and no arbitrary function of the dial can push the residual below the
  certified floors.

Try this: set the hidden carrier to zero and watch the dial explain everything. Then turn the
carrier up and watch the residual dispersion refuse to fall, no matter how strong you make the
dial.

{{interactive_demo:0}}

---

## 4. First theorem: the two acceptance legs are one number

Group the sample into **cells** — one for each value of the dial. Let the *within-cell
variance* be the average squared deviation of each count from its own cell's mean, and the
*between-cell variance* the average squared deviation of the cell means from the grand mean.

> **Variance Decomposition.** For any sample and any grouping,
> $$\operatorname{Var} \;=\; \operatorname{Var}_{\mathrm{within}} + \operatorname{Var}_{\mathrm{between}}.$$

Define $\eta^2 = \operatorname{Var}_{\mathrm{between}} / \operatorname{Var}$, the fraction of
variance the dial explains. Then:

> **Dispersion-Reduction Identity.** For a sample with positive mean and variance,
> $$\frac{D - D_{\mathrm{within}}}{D} \;=\; \eta^2 .$$

<details>
<summary>Click to reveal the two-line proof</summary>

Both dispersion indices have the *same* denominator, the sample mean, so the mean cancels in
the relative reduction:

$$\frac{D - D_{\mathrm{within}}}{D}
= \frac{\operatorname{Var} - \operatorname{Var}_{\mathrm{within}}}{\operatorname{Var}}
= \frac{\operatorname{Var}_{\mathrm{between}}}{\operatorname{Var}}
= \eta^2 ,$$

using the variance decomposition in the middle step. $\blacksquare$

The consequence is that a two-legged bar asking for both a regression $R^2$ and a dispersion
reduction is testing a one-dimensional quantity — and, as the next section shows, the $R^2$ leg
is the *weaker* of the two.
</details>

---

## 5. Second theorem: closing the door on every recalibration

Someone objects: your straight line was crude; let me use a smarter function of the dial. Two
results answer this completely.

> **Linear Capture Bound.** For any target $y$ and dial $s$ with positive variance, every
> affine recalibration $y \approx a + b\,s$ leaves residual at least
> $$\operatorname{Var}(y) - \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)} = (1 - r^2)\operatorname{Var}(y),$$
> attained exactly at the least-squares coefficients.

> **Conditional-Mean Optimality.** Among *all* predictors depending on the sample only through
> the dial's value, the one replacing each observation by the mean of its own cell minimises
> the sum of squared errors.

<details>
<summary>Click to reveal both proofs</summary>

**Linear bound.** Expand the mean squared error exactly:
$$\operatorname{MSE}(a,b) = \operatorname{Var}(y) - 2b\operatorname{Cov}(y,s) + b^2\operatorname{Var}(s) + \bigl(\operatorname{avg} y - a - b\operatorname{avg} s\bigr)^2 .$$
Complete the square in $b$:
$$-2b\operatorname{Cov}(y,s) + b^2\operatorname{Var}(s) = \frac{(\operatorname{Cov}(y,s) - b\operatorname{Var}(s))^2}{\operatorname{Var}(s)} - \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)} .$$
Both the completed square and the intercept square are non-negative and both vanish at the
least-squares choice. $\blacksquare$

**Conditional-mean optimality.** Inside a single cell $C$ with mean $m_C$, for any constant $h$,
$$\sum_{i \in C}(x_i - h)^2 = \sum_{i \in C}(x_i - m_C)^2 + |C|\,(m_C - h)^2 .$$
The last term is a square. Sum over cells. $\blacksquare$

**Corollary $r^2 \le \eta^2$.** An affine function of the dial is one particular cell-measurable
predictor, so it cannot beat the cell means. This is exactly why the measured dispersion
reduction ($14.22\%$) *exceeds* the linear $R^2$ ($7.81\%$) — that gap is the theorem being
tight, not an inconsistency in the data.
</details>

And then the payoff:

> **Residual Dispersion Floor.** If a dial's explained fraction is at most $e$, then after
> conditioning on it the residual dispersion index is still at least $(1-e)\,D$.

Feed in $D_{\mathrm{raw}} = 7.27$ and $\eta^2 \le 0.1422$:

$$D_{\mathrm{within}} \;\ge\; 6.23, \qquad \text{and} \qquad D_{\mathrm{within}} - 1 \;\ge\; 0.83\,(D - 1).$$

**At least $83\%$ of the sevenfold Poisson excess is arithmetic structure that no recorded
mechanism sees.** Not "the fit was poor" — a ceiling over every recalibration there is.

---

## 6. The orthogonality catch

Good experiments try to break their own conclusions. Perhaps the primary dial failed simply
because it is redundant with the mechanistic one?

Model each small prime as contributing an independent, uniformly random pair of signs: whether
each of the two secret factors is a residue. At one prime, over the four sign patterns
$(+,+), (+,-), (-,+), (-,-)$:

| statistic | values | mean | centred |
|---|---|---|---|
| individual count | $2, 1, 1, 0$ | $1$ | $+1, 0, 0, -1$ |
| product indicator | $1, 0, 0, 1$ | $\tfrac12$ | $+\tfrac12, -\tfrac12, -\tfrac12, +\tfrac12$ |

Multiply and add: $\tfrac12 + 0 + 0 - \tfrac12 = 0$.

> **Exact Dial Orthogonality.** Under independent uniform sign pairs at each of $k$ primes, the
> individual-symbol dial and the product-symbol dial have covariance **exactly zero**, for
> every $k$.

<details>
<summary>Click to reveal why: a parity argument, then induction</summary>

**The parity.** Under the global sign flip $u \mapsto -u$, the centred individual count is
**odd** and the centred product indicator is **even**. An odd function paired against an even
one sums to zero over a symmetric set. That is the one-prime identity.

**The propagation.** For centred per-coordinate statistics $a, b$ on an alphabet $\Sigma$ with
$\sum_\sigma a = \sum_\sigma b = \sum_\sigma ab = 0$, induct on the number of coordinates $k$,
splitting off the first. Expanding
$$(a(\sigma) + A)(b(\sigma) + B) = a(\sigma)b(\sigma) + a(\sigma)B + b(\sigma)A + AB$$
where $A, B$ are the tail sums: the first term contributes $|\Sigma|^{k-1}\sum_\sigma ab = 0$,
the two cross terms vanish because the tail sums of a centred statistic vanish, and the last
term vanishes by the inductive hypothesis. $\blacksquare$
</details>

The measured value was $r = -0.01$ — a sampling fluctuation around an exact zero. And this
*strengthens* the verdict rather than weakening it: **orthogonal explanations do not overlap,
so their shares simply add**. With $r_1^2 = 0.0127$ and $r_2^2 = 0.0781$, the two dials
together still leave over $90\%$ of the variance unexplained.

---

## 7. From two dials to seventy-eight thousand

If the informative primes merely *moved* — if at $96$ bits the relevant window sits out near
$10^6$ rather than below $400$ — the follow-up is cheap: about $78{,}498$ Legendre symbols per
integer. But what would count as success? Three theorems make the answer exact.

> **Family Capture Ceiling.** For pairwise uncorrelated dials, no joint affine recalibration
> pushes the residual below $\bigl(1 - \sum_j r_j^2\bigr)\operatorname{Var}(y)$, and
> coordinatewise least squares attains it.

> **Bessel Inequality for Dials.** For any orthogonal family, $\sum_j r_j^2 \le 1$. Hence if
> all $m$ dials are equally strong, each has $r^2 \le 1/m$.

> **Aggregation Loses.** The collapsed dial $S = \sum_j s_j$ — exactly the shape of a
> product-form count — satisfies $r^2(y, S) \le \sum_j r_j^2$.

So the bar for a whole window is a single scalar: does $\sum_{\ell \le X} r_\ell^2$ reach
$0.30$? Explore that curve directly:

{{interactive_demo:1}}

---

## 8. The falsifiable prediction

Two more steps turn the ceiling into a prediction the next experiment can *fail*.

> **Window Transfer.** If the tested window contributes at most $0.1422$ and the full family
> is to meet the $0.30$ bar, the untested extension must supply at least $0.1578$ by itself.

> **Per-Symbol Target.** A budget of $0.1578$ spread over at most $78{,}498$ primes forces some
> *single* Legendre symbol to reach $r^2 \ge 2\times 10^{-6}$.

That last is pure [pigeonhole](https://en.wikipedia.org/wiki/Pigeonhole_principle): not every
term can be below the average. **Measure every symbol in the extension window; if all come in
below two parts in a million, the scale-shift story is dead.**

And a constraint on whatever the carrier turns out to be:

> **Carrier-Dimension Lower Bound.** If no single dial of an orthogonal family carries more
> than $c$, reaching the bar takes at least $0.3/c$ of them. At the strongest recorded strength
> $c = 0.0781$: at least **four** mutually uncorrelated mechanisms.

Combined with the Bessel budget, the carrier is bracketed from both sides — it cannot be a haze
of arbitrarily many arbitrarily weak orthogonal causes, and it cannot be three weak ones.

{{visualization:0}}

---

## 9. Running the numbers

The pipeline is three cheap procedures. The first audits one dial; the second scans a whole
family and adjudicates the bar; the third handles the bookkeeping question of the last section.

{{algorithm:0}}

Note what the second one replaces. The original analysis fitted a generalized linear model,
which *diverged* on a first smoke run and needed Fisher scoring with deviance step-halving to
converge. Adding non-negative scalars cannot diverge — the ceiling theory buys numerical
robustness as well as logical strength.

{{algorithm:1}}

And the full numerical walk-through, reproducing every claim above on live data:

{{demo:0}}

The capture spectrum in three hypothetical regimes, with the decision rule applied:

{{demo:1}}

---

## 10. A footnote with a sharp point: resolution limits

Attached to this work is a smaller story about scientific bookkeeping whose lesson generalizes
far beyond arithmetic.

Four amplification anchors had been booked together with an underlying probability $\hat P$. An
archival dig established that **no raw $\hat P$ was ever stored**. Every booked value was
recovered by *inverting* a law from the stored anchor, to a precision of about $2\times10^{-4}$.

What does it mean to book a number you inverted rather than measured?

> **Resolution Limit (two-sided).** For a law that is at least $m$-expansive and at most
> $L$-Lipschitz on a window, the set of values compatible with an anchor stored to precision
> $\delta$ — the *resolution cell* — has diameter at most $2\delta/m$, and contains a whole
> interval of half-width $\delta/L$ around any exact preimage.

The cell is a genuine interval, never a point. Running the same estimate *forwards* quantifies
the cost of a discrepancy: a difference $\varepsilon$ in $\hat P$ moves the anchor by at most
$L\varepsilon$. At the most dramatic locus, a discrepancy of $2.32\times10^{-4}$ against a local
sensitivity of $826$ gives an overstatement of at most $0.192$ — matching the observed drift of
a printed $29.3152$ from a certified $29.1254$.

Play with it:

{{interactive_demo:2}}

And the procedure that computes cells and audits margins in practice:

{{algorithm:2}}

<details>
<summary>Does the discrepancy break anything downstream?</summary>

No, and that is a theorem too. If a feasibility reading was recorded with slack $\mu$, a
perturbation of size $\varepsilon \le \mu$ cannot flip it:
$$S_A' \;\ge\; S_A - \varepsilon \;\ge\; S_{\mathrm{raw}} + \mu - \varepsilon \;\ge\; S_{\mathrm{raw}} .$$
All four recorded margins — $0.212$, $0.242$, $0.183$, $0.190$ — exceed the $0.18$ perturbation,
so every locus survives rebooking. The recommendation is a bookkeeping rule with teeth:
**book at resolution limit, not at stored value**, because the raw-value-stored clause was
never met.
</details>

{{visualization:1}}

---

## 11. What a good negative result looks like

Nothing here proves the clumping is mysterious forever. It proves something more useful: it
draws a boundary and puts numbers on it.

- **Inside the boundary:** everything the recorded quadratic-residue mechanisms can see — at
  most $14\%$ of the variance, provably, for *every* recalibration of them, affine or not,
  singly or jointly.
- **Outside:** at least $83\%$ of a sevenfold Poisson excess, requiring at least four
  uncorrelated mechanisms if it is orthogonal, with a per-symbol threshold of
  $2\times10^{-6}$ that the next experiment either hits or misses.

The mathematics is elementary — the variance decomposition,
[Cauchy–Schwarz](https://en.wikipedia.org/wiki/Cauchy%E2%80%93Schwarz_inequality), completion of
the square, and a parity argument on four sign patterns. What makes it powerful is that every
statement is exact and finite-sample, with the measured numbers entering only as hypotheses.

A fit tells you what happened once. A capture ceiling tells you what can never happen. When you
cannot yet explain a phenomenon, the second is the more valuable possession.


# Future directions — dial capture ceilings and the `u ≈ 10` overdispersion carrier

The formalization converts the exp-576 verdict from a fitted number into a set of exact
finite-sample laws:

* the two H1 legs (regression `R²`, dispersion reduction `D-red`) are the *same* quantity
  `η²`, so the bar is one-dimensional;
* affine dial recalibration can never beat `r²`, and cell conditioning is the best possible
  use of a dial (conditional-mean optimality, `r² ≤ η²`);
* the two exp-576 dials are *exactly* uncorrelated under independent characters, so their
  shares add and the whole orthogonal family has a capture ceiling `Σ_j r_j²`;
* the capture budget of an orthogonal family is bounded by `1`, so a window of `m` equally
  strong symbols has `r² ≤ 1/m` per symbol, and collapsing a window into one count statistic
  can only lose; together these turn the `ℓ ≤ 10⁶` follow-up into a proved decision rule with
  a per-symbol threshold;
* the rider's "resolution limit" is a two-sided statement about the diameter of the
  compatible-probability cell and does not disturb feasibility.

What is *not* settled is the mechanism: `≥ 83%` of the Poisson excess dispersion is carried by
something no recorded dial sees. The directions below are the concrete, falsifiable follow-ups
this structure suggests.

---

## 1. Prime-window capture spectrum

**The key insight is** that the family capture ceiling `Σ_{ℓ ≤ X} r_ℓ²` is a *monotone function
of the prime cut* `X`, so the question "did the informative window move past 400?" becomes the
question "does the capture spectrum `X ↦ Σ_{ℓ ≤ X} r_ℓ²` cross `0.30`?", and that is a single
scalar curve, measurable and provably bounded.

**Why now?** The family capture bound already proves the ceiling is the sum of individual
shares for orthogonal per-prime dials, and independent characters make distinct primes
orthogonal, so the whole `ℓ ≤ 10⁶` follow-up reduces to computing 78k scalars and adding them —
with a proved stopping rule instead of a fitted GLM.

## 2. Carrier-dimension lower bound

**The key insight is** that a variance-to-mean ratio of `7.27` forces *any* explanatory family,
orthogonal or not, to contain at least one direction with `r² ≥ (D−1)/(m·D)` if it is to explain
the excess with `m` regressors — so overdispersion of this size cannot be produced by many
individually weak, mutually orthogonal causes.

**Why now?** The exact family bound makes the counting argument rigorous: the Bessel budget
caps the total at `1` and the dilution ceiling caps each of `m` equally strong dials at `1/m`,
so "many weak causes" is a quantified impossibility rather than an intuition. Sharpening this
into a rank lower bound for non-orthogonal designs is the natural next theorem.

## 3. Beyond quadratic residues

If the extension window misses the per-symbol threshold of `2·10⁻⁶`, the search must move
outside the character family altogether. Candidate carriers include the multiplicative
structure of `p ± 1` and `q ± 1`, class-group data of the associated quadratic order, and
short-interval statistics of the smoothness profile — each of which admits the same treatment:
define a dial, compute `r²`, and adjudicate against a family ceiling instead of a fit.

## 4. Resolution-limit bookkeeping as a general rule

Any pipeline that stores derived anchors and later re-infers inputs from them incurs a
resolution cell of width `2δ/m`; booking practice should record the cell, not a point, whenever
the raw-input-stored clause is unmet. Codifying the admissibility rule — *book at resolution
limit unless the raw quantity is stored* — as a checkable condition on an artifact schema is a
small but high-leverage piece of infrastructure.
