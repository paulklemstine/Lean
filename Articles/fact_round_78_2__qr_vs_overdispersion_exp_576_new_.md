# The Dial That Wasn't There

## How to prove that an explanation *can't* work

There is a particular kind of scientific disappointment that turns out, on inspection, to be the most useful thing in the room.

You have a phenomenon. It is loud, reproducible, and unexplained. You have a candidate explanation — a *dial*, some measurable quantity you can compute cheaply for every case, which you suspect is secretly driving the phenomenon. You turn the dial. Nothing much happens. The phenomenon shrugs.

The tempting response is to keep fiddling: rescale the dial, take its logarithm, bin it differently, add an interaction term. Maybe the dial *does* explain the phenomenon and you simply haven't found the right functional form. This is how a research programme can burn a decade.

The alternative — the one this article is about — is to prove a theorem that closes the door. Not "this particular fit was poor" but "**no** recalibration of this dial, linear or nonlinear, can explain more than $14\%$ of what we see." Once you have that, a negative result stops being an absence and becomes a *measurement*: a certified lower bound on how much structure remains unaccounted for.

That is what happened here, in a corner of computational number theory, to a phenomenon called overdispersion.

---

## Clumping

Imagine a sieve. For each of $128$ carefully matched large integers $N$ — each a product of two primes of equal size, each around $96$ bits — you run a randomized search that occasionally scores a "hit." You run $150{,}000$ trials per integer, nearly twenty million trials in total, and you count the hits.

If the hits arrived independently and at a rate depending only on the integer's size, the counts would be Poisson. The signature of a Poisson count is a beautiful and rigid one: **the variance equals the mean**. Their ratio, the *dispersion index*
$$D \;=\; \frac{\operatorname{Var}}{\operatorname{Mean}},$$
would be $1$.

The observed mean was $76.7$ hits per integer. The observed dispersion index was
$$D_{\text{raw}} \;=\; 7.27.$$

Seven times too spread out. The counts ranged from $29$ to $172$. A few integers were wildly generous; others were miserly. The clumping was not noise — it survived a completely fresh randomization with a new master seed and a provably disjoint set of integers, and the top cluster reproduced an earlier experiment's envelope, rescaled, almost exactly.

So: something about the *arithmetic of the individual integer* $N$ — not its size, not the random seed — makes it a good or bad target. What?

---

## The obvious suspect

There is a natural candidate, and it comes from the mechanics of the sieve itself. Small primes $\ell$ can divide the quantities the sieve inspects only under an arithmetic condition: $\ell$ can divide $x^2 - N$ for some $x$ precisely when $N$ is a **quadratic residue** modulo $\ell$ — that is, when $N$ is a perfect square in the arithmetic of remainders mod $\ell$. Half of all primes should qualify for a "random" $N$; the ones that do are the primes that can help.

So count them. Define a *dial*: for each integer $N$, let
$$S_{\text{prod}}(N) \;=\; \#\{\ell \le 100 : N \text{ is a quadratic residue mod } \ell\}.$$
An integer with an unusually helpful set of small primes should be an unusually generous target. That is a clean, mechanistic, falsifiable story, and a related version of it had been calibrated successfully at smaller scales — around $40$ to $48$ bits.

Two other dials were tested alongside it: a variant counting the individual quadratic-residue conditions on each of the two secret prime factors separately, and a third recorded form using a wider prime window up to $400$.

Before looking at the data, the experiment pre-registered a bar. For the dial to count as *the* explanation, it had to clear both legs: a regression $R^2$ of at least $0.25$, **and** a dispersion reduction of at least $30\%$.

The results:

| Dial | $R^2$ | Dispersion reduction |
|---|---|---|
| Individual-symbol count | $0.0127$ | $0.88\%$ |
| Product-symbol count $S_{\text{prod}}$ | $0.0781$ | $14.22\%$ |
| Wider-window recorded form | $0.0565$ | $9.07\%$ |

The best dial explains one part in seven. The bar was $30\%$. The obvious suspect has an alibi.

---

## Two numbers, one quantity

Here is the first place where a theorem replaces a shrug. Why should the regression $R^2$ and the "dispersion reduction" be comparable at all? They are computed differently — one from a straight-line fit, the other from re-estimating how clumpy the counts are once you group integers by their dial value.

They are, in fact, two faces of a single quantity. Group the sample into *cells*, one for each value the dial takes. Let the *within-cell variance* be the average squared deviation of each count from its own cell's mean, and the *between-cell variance* the average squared deviation of the cell means from the grand mean. Then a classical identity holds exactly, with no approximation and no asymptotics:

> **The Variance Decomposition.** For any sample and any grouping into cells, the total variance is the sum of the within-cell variance and the between-cell variance.

Define the *explained fraction* $\eta^2$ to be the between-cell variance divided by the total variance. Then:

> **The Dispersion-Reduction Identity.** For a sample with positive mean and positive variance, the relative reduction in dispersion index achieved by conditioning on the dial's cells equals exactly the explained fraction:
> $$\frac{D - D_{\text{within}}}{D} \;=\; \eta^2 .$$

So the second leg of the pre-registered bar was never an independent test. Both legs measure $\eta^2$. The bar is one-dimensional. That is a small clarification with a large consequence: it means one can reason about *all* dial-based explanations at once, instead of one fitting procedure at a time.

---

## Closing the door on every recalibration

Now the crucial move. Suppose someone objects: your straight-line fit was crude; let me use a smarter function of the dial.

Two theorems answer this in full.

> **The Linear Capture Bound.** For any target $y$ and any dial $s$ with positive variance, every affine recalibration $y \approx a + b\,s$ leaves a mean squared residual of at least
> $$\operatorname{Var}(y) - \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)} \;=\; (1 - r^2)\operatorname{Var}(y),$$
> and this bound is attained exactly at the least-squares coefficients.

No retuning of slope or intercept can beat the squared correlation. Fine — but what about *nonlinear* functions of the dial?

> **Conditional-Mean Optimality.** Among all predictors that depend on the sample only through the dial's value, the one that replaces each observation by the mean of its own cell minimises the sum of squared errors.

That is the strongest possible statement: the cell-mean predictor is the best imaginable use of the dial, and its residual is exactly the within-cell variance. Together these give $r^2 \le \eta^2$ — which is precisely why the measured dispersion reduction $14.22\%$ *exceeds* the linear $R^2$ of $7.81\%$. The gap is not an inconsistency; it is the theorem being tight.

And then the punchline:

> **The Residual Dispersion Floor.** If a dial's explained fraction is at most $e$, then after conditioning on it the residual dispersion index is still at least $(1-e)\,D$.

Feed in the numbers. With $D_{\text{raw}} = 7.27$ and $\eta^2 \le 0.1422$:

- the residual dispersion index is at least $6.23$ — still six times Poisson;
- and of the Poisson *excess* $D - 1 = 6.27$, at least $83\%$ survives every dial-based correction.

The verdict is no longer "the fit was bad." It is: **at least $83\%$ of the clumping is arithmetic structure in $N$ that no recorded mechanism sees.** The successful small-scale calibration does not extend to this scale.

---

## The orthogonality catch

A good experiment tries to break its own conclusion. Here is the attempt.

The two main dials look like they should be nearly the same statistic — one counts residue conditions on the two secret factors individually, the other counts them for the product. Perhaps the primary dial failed simply because it is redundant with, or badly aligned to, the mechanistic one?

Model each small prime as contributing an independent, uniformly random pair of signs: whether the first factor is a residue, and whether the second is. At a single prime, the individual count takes the value $2, 1, 1, 0$ across the four sign patterns (mean $1$), while the product indicator — which fires exactly when the two signs *agree* — takes $1, 0, 0, 1$ (mean $1/2$). Centre both. The centred individual count is $+1, 0, 0, -1$; the centred product indicator is $+\tfrac12, -\tfrac12, -\tfrac12, +\tfrac12$. Multiply and add: $\tfrac12 + 0 + 0 - \tfrac12 = 0$.

The reason is a parity: under flipping *both* signs, the centred individual count is odd and the centred product indicator is even. Odd against even integrates to zero.

> **Exact Dial Orthogonality.** Under independent uniform sign pairs at each of $k$ primes, the individual-symbol dial and the product-symbol dial have covariance exactly zero, for every $k$.

Not $-0.01$, the measured value. Exactly $0$, by algebra, for all window sizes. The primary dial is orthogonal *by construction* to the divisibility carrier. Far from weakening the verdict, this strengthens it: orthogonal explanations do not overlap, so their explanatory shares simply **add**.

> **The Joint Capture Bound.** If two dials are uncorrelated across the sample, no joint affine recalibration of both can push the residual below $(1 - r_1^2 - r_2^2)\operatorname{Var}(y)$.

With $r_1^2 = 0.0127$ and $r_2^2 = 0.0781$, the two dials together still leave over $90\%$ of the variance unexplained.

---

## From two dials to seventy-eight thousand

If the informative primes simply moved — if at $96$ bits the relevant window sits not below $400$ but somewhere out towards $10^6$ — then the natural follow-up is obvious: compute the residue condition for *every* prime up to a million, about $78{,}498$ Legendre symbols per integer. Cheap. But what, exactly, would count as success?

Extending the orthogonality argument to a whole family of pairwise-uncorrelated dials gives an exact answer.

> **The Family Capture Ceiling.** For a family of pairwise uncorrelated dials, no joint affine recalibration can push the residual below $\bigl(1 - \sum_j r_j^2\bigr)\operatorname{Var}(y)$, and coordinatewise least squares attains this exactly.

So the bar for a whole window is simply $\sum_j r_j^2 \ge 0.30$: one scalar, computed by adding seventy-eight thousand squared correlations. No model selection, no fitted generalized linear model, no divergence. A proved stopping rule.

Three further theorems sharpen what that budget can look like.

> **A Bessel Inequality for Dials.** For any orthogonal family, $\sum_j r_j^2 \le 1$.

The explanatory budget is finite, so primes compete. An immediate corollary: if all $m$ dials in an orthogonal family are equally strong, each has $r^2 \le 1/m$. "Many weak symbols" is a real constraint, not a free lunch.

> **Aggregation Loses.** The single collapsed dial $S = \sum_j s_j$ — which is exactly the shape of a count statistic like "how many primes in this window is $N$ a residue mod" — satisfies $r^2(y, S) \le \sum_j r_j^2$.

So the recorded product-form reading is a *lower* bound for the window it summarises. The family ceiling, not the collapsed count, is the right thing to test.

> **Window Transfer.** If the already-tested window contributes at most $0.1422$ and the full family is to meet the $0.30$ bar, the untested extension window must supply at least $0.1578$ on its own.

> **Per-Symbol Target.** A budget of $0.1578$ spread over at most $78{,}498$ primes forces some *single* Legendre symbol in the extension window to reach $r^2 \ge 2\times 10^{-6}$.

That last line is the payoff. It converts a vague hypothesis — "maybe the informative scale moved" — into a crisp, falsifiable, per-symbol prediction. Measure every symbol in the extension window; if all of them come in below two parts in a million, the scale-shift story is dead, and the clumping is carried by something outside the quadratic-residue family altogether.

And one more constraint on what that something could be:

> **Carrier-Dimension Lower Bound.** If no single dial of an orthogonal family carries more than $c$ of squared correlation, reaching the $0.30$ bar requires at least $0.3/c$ dials.

At the strongest recorded strength $c = 0.0781$, that is at least four mutually uncorrelated mechanisms. Dispersion of this magnitude cannot be manufactured out of many individually feeble, mutually independent causes — that is what the Bessel inequality forbids — nor out of one or two weak ones.

---

## A footnote about resolution

Attached to this work is a smaller, sharper story about scientific bookkeeping, and it deserves telling because the lesson generalizes far beyond number theory.

An earlier paper had booked four amplification anchors, each derived from an underlying hit probability $\hat P$. An archival dig established something uncomfortable: **no raw $\hat P$ was ever stored.** Every booked value was recovered by *inverting* a drafted law from the stored anchor, to a precision of about $2\times 10^{-4}$.

What does it mean to book a number you inverted rather than measured? The honest answer is a theorem about *cells*.

Say a law $f$ is at least $m$-expansive and at most $L$-Lipschitz on a window: over any subinterval, $f$ grows by at least $m$ and at most $L$ times the length. Given an anchor stored as $R$ with precision $\delta$, define the **resolution cell** to be all admissible $\hat P$ with $|f(\hat P) - R| \le \delta$. Then:

> **Resolution Limit (two-sided).** Any two probabilities in the same cell differ by at most $2\delta/m$; and conversely, every admissible probability within $\delta/L$ of an exact preimage lies in the cell.

The upper half says an inversion cannot report more than the cell. The lower half says the cell is a genuine interval, not an artifact of a lazy bound. A concrete law makes this vivid: for $f(P) = 1/(1-P)$ on $[0.98, 0.99]$, the growth rate is between $2500$ and $10{,}000$, so the cell has width at most $\delta/1250$ and at least $\delta/10000$ — bracketed by a factor of $8$, and definitely not a point.

Running the same Lipschitz estimate *forwards* quantifies the cost of the discrepancy:

> **Forward Amplification.** A discrepancy of $\varepsilon$ in $\hat P$ moves the anchor by at most $L\varepsilon$.

At the most dramatic locus, the booked $\hat P = 0.9853$ exceeds the certified-law-implied $0.985068$ by $2.32\times 10^{-4}$, and the law's local sensitivity there is about $826$. Multiply: the printed anchor overstates by at most $0.192$ — matching the reported $\approx 0.19$ drift from $29.315$ toward the certified $29.125$.

Does this break anything downstream? No — and that is a theorem too. A perturbation smaller than a recorded feasibility margin cannot flip a feasibility inequality, and all four recorded margins ($0.212$, $0.242$, $0.183$, $0.190$) exceed the $0.18$ perturbation. All four loci survive.

The recommendation that follows is a bookkeeping rule with teeth: book these anchors *at resolution limit*, not *at stored $\hat P$* — because the stored-$\hat P$ clause was never met.

---

## What a good negative result looks like

None of this proves the clumping is mysterious forever. It proves something better-behaved and more useful: it draws a boundary and puts numbers on it.

Inside the boundary: everything the recorded quadratic-residue mechanisms can see, capped at $14\%$ of the variance, and provably so for every recalibration of them, affine or not, singly or jointly.

Outside: at least $83\%$ of a sevenfold Poisson excess, carried by something that needs at least four uncorrelated mechanisms if it is orthogonal, or one strong non-obvious one if it is not — and with a per-symbol threshold of $2\times 10^{-6}$ that the next experiment can either hit or miss.

The mathematics that does this work is not exotic. It is the variance decomposition, Cauchy–Schwarz, and a parity argument on four sign patterns. What makes it powerful is that every statement is exact and finite-sample: no asymptotics, no distributional assumption beyond one explicitly-flagged Poisson calibration, and the measured numbers entering only as hypotheses so that the conclusions move continuously if the measurements are revised.

A fit tells you what happened once. A capture ceiling tells you what can never happen. When you cannot yet explain a phenomenon, the second is the more valuable possession — and, occasionally, the more beautiful.
