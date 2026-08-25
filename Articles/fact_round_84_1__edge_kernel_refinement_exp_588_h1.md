# The Spike at the Edge: When a Beautiful Power Law Turns Out to Be Two Laws in Disguise

## A number that would not sit still

Some of the most stubborn facts in mathematics look, at first, like bookkeeping. You count how often something happens, you plot the counts, and a curve appears. If the curve is a straight line on log-log paper, you say the word *power law*, write down an exponent, and move on. Power laws are the wallpaper of quantitative science: they describe earthquake magnitudes, city sizes, word frequencies, and — as it happens — the way certain arithmetic events distribute themselves inside a sliding window.

The story here begins with such a curve, and with a single number that refused to fit it.

The setting is a positional profile. Imagine a family of windows, one for each parameter, and inside each window a scatter of *hits* — the places where some arithmetic condition is satisfied. To compare windows of different sizes, rescale each to the unit interval: a hit at absolute position $p$ inside a window $[j_{\mathrm{lo}}, j_{\mathrm{hi}}]$ becomes the normalised coordinate

$$x = \frac{p - j_{\mathrm{lo}}}{j_{\mathrm{hi}} - j_{\mathrm{lo}}} \in [0,1].$$

Pool thousands of hits from many windows, histogram them against $x$, and you get a shape. For years, that shape had a name and a number: a decaying power law with exponent about $1.10$, meaning the density of hits behaved like

$$T(x) \;\propto\; (1+x)^{-1.104}.$$

Fits were good. The exponent was reproducible. It became the canonical summary.

Then somebody looked at the far left.

If the profile really is $(1+x)^{-1.104}$, then the leftmost tenth of the window — the *left decile*, $0 \le x \le 0.1$ — must carry a very specific share of the total mass. The share is computable in closed form, and it comes out to $14.15\%$. The measured share, over nearly ten thousand pooled hits, was $16.20\%$, with a confidence interval of roughly $[15.47\%, 16.95\%]$. Two percentage points does not sound like much. But the prediction sits well outside the interval, and the discrepancy is concentrated precisely at the boundary of the window — the one place where you might expect either a genuine effect or a subtle artefact.

Is the left edge telling us something, or is it noise?

That is the question this work answers — and the answer, it turns out, has a rigid mathematical skeleton underneath it. Once you write down the family of candidate laws and ask what it can and cannot do, the statistics stop being a matter of taste. Several things become provable: which measurements can *never* settle the question, which ones *must*, and what a fitted exponent is really reporting when the truth is not a single law at all.

## The kernel and the edge fraction

Everything revolves around one function. Call

$$\kappa_b(x) = (1+x)^{-b}, \qquad x \in [0,1],$$

the *harmonic-type kernel* with exponent $b$. It is the shape a pure power law makes on the rescaled window. (The shift by $1$ is what makes it finite and well-behaved at the left endpoint — the profile does not blow up at $x = 0$, it simply starts at height $1$ and decays.)

The quantity everyone actually measures is not the kernel but its normalised cumulative mass. Define the **edge fraction**

$$F(b,t) \;=\; \frac{\displaystyle\int_0^t (1+x)^{-b}\,dx}{\displaystyle\int_0^1 (1+x)^{-b}\,dx},$$

the share of the total profile mass lying in the initial segment $[0,t]$. For $b \ne 1$ the integrals evaluate cleanly and the whole thing collapses to a formula with no integrals in it at all:

$$F(b,t) \;=\; \frac{(1+t)^{1-b} - 1}{2^{\,1-b} - 1}.$$

The left-decile share is $F(b, 0.1)$. Plugging in $b = 1.104$ gives $0.14181\ldots$ — that is where the number $14.15\%$ (up to the exact fitted exponent) comes from. The flat case $b = 0$ gives $F(0,t) = t$, as it must: a uniform profile puts exactly a tenth of its mass in a tenth of the window.

## Rigidity: one number pins down one law

Here is the first structural fact, and it is stronger than it looks.

> **Rigidity of the single-law family.** For every interior window $t \in (0,1)$, the map $b \mapsto F(b,t)$ is *strictly increasing*.

Steepen the law, and more mass moves left. Always, everywhere, without exception. It sounds obvious — steeper means more front-loaded — but "obvious" is doing real work here, because the edge fraction is a *ratio* of two integrals, and both numerator and denominator shrink when $b$ grows. The proof is a monotone-likelihood-ratio argument: increasing the exponent from $b$ to $b+c$ multiplies the kernel pointwise by $(1+x)^{-c}$, a factor that is at least $(1+t)^{-c}$ on the head $[0,t]$ and *strictly* less than $(1+t)^{-c}$ somewhere on the tail $[t,1]$. So the head is discounted less than the tail, and the ratio must rise.

Two consequences follow immediately. First, a single edge-mass measurement *identifies* the exponent: the map is injective, so if two power laws agree on the left-decile share, they are the same law. Second, every decaying kernel over-weights its own left edge:

$$F(b,t) > t \quad\text{whenever } b > 0,$$

with equality exactly in the flat case. A tenth of the window always holds more than a tenth of the mass.

## Why one number can never refute a power law

Now the counterpoint, and it is the reason the original discrepancy could not, by itself, close the case.

Push the exponent up and the mass keeps piling onto the left. In the limit,

$$F(b,t) \longrightarrow 1 \quad \text{as } b \to \infty$$

for every fixed $t > 0$: an infinitely steep law puts *everything* in the first sliver. Combine that limit with the fact that $F$ varies continuously in $b$, and the intermediate value theorem delivers a slightly deflating conclusion:

> **Non-falsifiability of a single measurement.** Given any reference law $b_0 > 1$ and any target value $\alpha$ with $F(b_0,t) < \alpha < 1$, there exists an exponent $b > b_0$ with $F(b,t) = \alpha$ exactly.

In other words: no measured edge fraction, no matter how far it sits from your favourite exponent's prediction, is *evidence against a power law*. It is evidence against *that* power law. Some other power law reproduces it perfectly. Concretely, the measured $16.20\%$ left-decile share is matched to the digit by the exponent $b \approx 1.5698$.

This is why the left-edge tension could not be resolved by staring harder at one number. To distinguish "a slightly steeper single law" from "something structurally different at the edge", you need a comparison of *shapes across windows* — and that is exactly what the next results provide.

## Two components, and a shape you cannot fake

The alternative hypothesis is a **two-component profile**: a flat bulk plus a narrow left-edge spike,

$$T(x) \;=\; A\,(1+x)^{-b_1} \;+\; K\,(1+x)^{-b_2}, \qquad A, K > 0,\; b_1 < b_2 .$$

The bulk exponent $b_1$ is small — the interior of the window is nearly flat — and the spike exponent $b_2$ is large, so the second term is a thin flare that dies away almost immediately. In the data, the fitted values are a bulk of $b_1 \approx 0.57$ and a spike so sharp that fitting procedures ran into their own numerical ceilings; the honest statement is $b_2 \gtrsim 10$, with the spike carrying roughly a tenth of the mass.

Is this really a different animal, or just a power law wearing a costume? Here the answer is unambiguous and, pleasingly, purely algebraic.

Call three positions $x_0 < x_1 < x_2$ a **geometric triple** when their shifted coordinates form a geometric progression, $(1+x_1)^2 = (1+x_0)(1+x_2)$. On any such triple, a pure power law is *exactly* multiplicative: $\kappa_b(x_1)^2 = \kappa_b(x_0)\kappa_b(x_2)$, because a power law is log-affine in $\log(1+x)$ and the triple is equally spaced on that scale. And now:

> **Strict log-convexity.** If $A, K > 0$ and $b_1 \ne b_2$, then on *every* geometric triple the two-component profile satisfies the strict inequality
> $$T(x_1)^2 \;<\; T(x_0)\,T(x_2).$$

The proof is a strict arithmetic–geometric mean inequality in disguise. Expanding both sides, the difference reduces to $A K$ times $\big(\text{cross terms}\big) - 2\sqrt{\cdots}$, and the cross terms $\kappa_{b_1}(x_0)\kappa_{b_2}(x_2)$ and $\kappa_{b_2}(x_0)\kappa_{b_1}(x_2)$ have the *same product* as the square of the middle value but are *unequal* whenever $b_1 \ne b_2$. Two positive numbers with a fixed product and different values have a sum strictly exceeding twice their geometric mean. That single gap is the whole obstruction.

The consequence is a genuine no-go theorem:

> **No single power law on any subwindow.** For $A, K > 0$ and $b_1 \ne b_2$, there are no constants $C$ and $b$ with $T(x) = C(1+x)^{-b}$ for all $x$ in a nondegenerate interval $[s,e] \subseteq [0,\infty)$.

Not globally, and — this is the sharpening that matters — not on *any* window, however small. A mixture of two power laws is never a power law, anywhere. So if the bulk+spike description is right, a pure power law is not an approximation that improves as you restrict attention; it is structurally wrong at every scale.

## What a fitted exponent is actually reporting

Suppose you do not know any of this and simply fit a single power law to bulk+spike data. What number comes back?

First, a clean bookkeeping identity. Normalising the two-component profile turns it into an honest two-point mixture of the normalised components:

$$\frac{\int_0^t T}{\int_0^1 T} \;=\; (1-w)\,F(b_1,t) \;+\; w\,F(b_2,t), \qquad w = \frac{K \int_0^1 \kappa_{b_2}}{A\int_0^1\kappa_{b_1} + K\int_0^1 \kappa_{b_2}},$$

with $w$ the share of total mass carried by the spike. Because $F$ is strictly increasing in the exponent, the mixture's edge fraction is squeezed strictly between the two pure values, and hence:

> **Effective-exponent inflation.** If a single law is calibrated to reproduce the mixture's edge fraction on some window, its exponent $b_{\mathrm{eff}}$ satisfies $b_1 < b_{\mathrm{eff}} < b_2$ — strictly steeper than the bulk, strictly flatter than the spike.

That is the mechanism behind the whole affair. A flat bulk of $0.57$ and a razor-thin spike, pooled and fitted with one law, report something around $1.1$. The famous canonical exponent was never a physical slope; it was a compromise, an average dragged steeper by a narrow feature at the boundary.

And the compromise is unstable, in a way that is itself a theorem. Fit window by window and you get a function $t \mapsto b_{\mathrm{eff}}(t)$, well defined for each $t$ (by rigidity, the calibration equation has exactly one solution). Then:

> **Window dependence.** No single exponent reproduces the mixture's edge fraction simultaneously at all windows $t \in (0,1)$. Hence $b_{\mathrm{eff}}$ is provably non-constant.

The proof is a lovely bit of leverage. If one exponent worked at every $t$, then differentiating the identity in $t$ would force the *densities* to agree, and we already know a mixture is not a single kernel on any subwindow — contradiction. So the cumulative statistic, not just the density, separates the two families.

Finally, the drift has a direction. The exponent that a two-point log-log slope measurement reports on a window $[x,y]$ is

$$-\,\frac{\log T(y) - \log T(x)}{\log(1+y) - \log(1+x)}.$$

For a pure power law this returns $b$ regardless of the window — the measurement is scale-free, which is precisely what makes power laws so seductive. For a genuine two-component profile, strict log-convexity says otherwise:

> **Left-edge steepening.** On every geometric triple $x_0 < x_1 < x_2$, the slope measured on the left half-window $[x_0,x_1]$ is *strictly steeper* than the slope measured on the right half-window $[x_1,x_2]$.

So the pathology is not random wobble; it is a systematic, one-directional drift toward steeper exponents as you move left. Refit the data on the left half of the window and the reported exponent must go up. It did: in the data, the left-half refit steepened from about $1.10$ to about $1.80$.

## The spike is real; its sharpness is not measurable

One last theorem, and it is a warning label.

As the spike sharpens without bound, the mixture's edge fraction converges:

$$(1-w)F(b_1,t) + w\,F(b_2,t) \;\longrightarrow\; (1-w)F(b_1,t) + w \qquad (b_2 \to \infty).$$

The limit does not depend on $b_2$ at all. So the *weight* $w$ of the spike is identified — it is exactly the excess of the measured edge mass over the bulk prediction, rescaled — while the *exponent* $b_2$ becomes invisible once the spike is narrower than the resolution of your windows. Numerically the convergence is fast: at $t = 0.1$, exponents $b_2 = 50$ and $b_2 = 2000$ produce edge fractions differing in the fourth decimal place.

This is exactly what the fitting procedure reported in practice. Asked to estimate the spike exponent, it slammed into whatever ceiling it was given, and when the ceiling was raised from $10$ to $40$ it found an interior optimum near $22.5$ with a bootstrap interval stretching from $11$ to $41$. That is not a failure of the fit. It is the theorem: above a threshold, the data cannot see the difference. The right thing to report is a lower bound and a weight, which is what the analysis now does.

## What changes

Three things.

The canonical description of this positional profile is no longer a single power law with exponent $-1.104$; it is a **flat bulk plus a narrow left-edge spike**, with the old exponent demoted from "the law" to "a pooled summary statistic". The improvement is decisive by every standard model-comparison criterion, and — the crucial control — the same two-component fit applied to matched control data shows no spike at all, so the feature is not an artefact of the normalisation or the binning.

Second, the attribution is clean: more than half of the improvement in fit lives in the first decile alone, and essentially none of it near the interior features of the profile. The spike is a boundary phenomenon, orthogonal to whatever else the window is doing in its middle.

Third — and this is the part that outlives the particular dataset — a pure power law is now *known wrong* here, in a falsifiable, structural sense. Any future model that proposes a shape for this profile must produce something that is not log-affine on geometric triples. That is a hard constraint, and it came not from more data but from taking seriously what the mathematics of a two-parameter family can and cannot do.

There is a moral in the arithmetic. The tension that started all this was a two-percentage-point mismatch in a single cumulative statistic — the kind of thing that gets rounded away or attributed to binning. What made it decidable was not a bigger sample. It was knowing, in advance and with proof, that a single number can never refute a power law, that a mixture can never *be* one on any window, and that the fitted exponent of a mixture must drift steeper toward the edge. Once you know which measurements are informative, the data has no room left to be ambiguous.
