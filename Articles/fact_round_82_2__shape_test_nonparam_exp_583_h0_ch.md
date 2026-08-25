# The Ghost in the Baseline

### How a bump that never existed taught us to trust a power law

There is a particular kind of scientific disappointment that only happens after a success. You run an experiment. Something in the data refuses to be flat, refuses to be a straight line, refuses to be noise. The statistics are overwhelming — the kind of number where the $p$-value has an exponent of $-21$ attached, where four hundred randomized reshufflings of the data never once produce anything as extreme as what you saw. You have found *structure*. And then, weeks later, you discover that the most exciting-looking part of that structure was manufactured by your own yardstick.

This is the story of such a bump, of why it appeared, and of the small body of mathematics that now makes it impossible for that particular ghost to fool anyone again. The mathematics turns out to be surprisingly clean: three theorems about the shape of declining curves, and one very old inequality between three kinds of average.

---

## The setup: a rate that depends on where you look

Strip away the domain-specific details and the situation is this. Events — call them *hits* — occur at positions $x$ inside a window. You want to know how the hit rate depends on position. Is the rate constant? Does it slide steadily downward? Or is there a preferred location, a *mode*, some spot in the middle of the window where hits pile up?

That last question is the interesting one, because a mode is a mechanism. A steady decline can be produced by a hundred boring processes; a bump at a specific interior location says *something happens here*. The claim on the table was exactly that: an excess in the middle of the window.

To test it, one compares two models of the log-rate:

- **The linear model:** $\log T(x) = p + qx$. The log-rate is a straight line in position.
- **The free model:** $\log T(x)$ is an arbitrary smooth curve (in practice, a flexible spline with a handful of degrees of freedom).

The free model won, and it won decisively: a likelihood-ratio statistic of $100.6$ on $3$ degrees of freedom, an asymptotic $p$-value of $1.17 \times 10^{-21}$, and — the more robust check — zero out of four hundred randomized relabelings reaching that value. There is real curvature in the data. The straight line is dead.

And here is the trap. It is extremely tempting to read "the straight line is dead" as "there is a bump." Those are not the same statement, and the gap between them is where most of the trouble in this story lives.

---

## Nonlinearity is not a mode

Consider the family of shapes that actually fits data of this kind:

$$T(x) = C(1+x)^{-a}, \qquad C > 0,\ a > 0,\ x > -1.$$

This is a power law in the shifted coordinate $1+x$. The recorded fit was $T(x) \approx 0.0295\,(1+x)^{-1.104}$: a steep decline, of the type familiar from Dickman-style distributions where the density falls off sharply as you move away from the small-$x$ edge.

Two facts about this curve pull in opposite directions.

**First, it is genuinely nonlinear.** Its log-rate is
$$\log T(x) = \log C - a\log(1+x),$$
and the function $x \mapsto -a\log(1+x)$ is *strictly convex* on the whole admissible range: its second derivative is $a/(1+x)^2 > 0$. A strictly convex function can never coincide with an affine function $p + qx$ on an interval of positive length — if it did, its own chord would lie strictly below itself, which is a contradiction. So no straight line fits the log-rate, anywhere, ever. A likelihood-ratio test comparing "free" against "linear" *must* reject, given enough data. The rejection is real and it is informative.

**Second, it has no interior mode.** Because $a > 0$, the function $T$ is strictly decreasing: $x < y$ forces $T(x) > T(y)$. Its largest value on any window $[l,u]$ therefore sits at the left edge $l$ and nowhere else. There is no interior point that dominates its neighbours, because there is no interior point that dominates the left edge.

Put these together and you get what I would call the headline decomposition:

> **Nonlinearity Without Mode.** For every $C, a > 0$ and every window $[l,u]$ inside $x > -1$, the power law $T(x) = C(1+x)^{-a}$ simultaneously (i) admits no affine fit to its log-rate on that window, (ii) is strictly decreasing on that window, and (iii) has no interior maximum on that window.

A crushing rejection of linearity is therefore *exactly what a mode-free steep decline predicts*. The $p$-value of $10^{-21}$ is evidence about curvature, and curvature is not location. Anyone who reads a linearity rejection as a licence to hunt for a mid-window peak has committed a category error, and the theorem above is the receipt.

There is even a sharper version. Convexity alone forbids interior maxima: if a function is strictly convex on $[l,u]$, then every interior point lies on a chord and is therefore strictly below the larger of the two endpoint values. So *any* shape with convex log-rate — the whole scale-free family, and much else besides — is structurally incapable of the phenomenon the mode-hunt was looking for.

What the data *did* say, once you ask the right question, is unambiguous: the profile's interior maximum was pinned at the extreme left edge of the window, $x^\star = 0.020$, in every single one of $150$ bootstrap replicates, with a confidence interval of zero width. The deciles fall monotonically from $1554$ down to $694$. The peak-to-end rate ratio is $2.54$, with confidence interval $[2.24, 2.80]$. That is a cliff, not a hill.

---

## Reading the exponent off the cliff

The ratio $2.54$ is not just a descriptive number; in the power-law family it *is* the exponent, in disguise. Across a window $[l,u]$,

$$\frac{T(l)}{T(u)} = \left(\frac{1+u}{1+l}\right)^{a},$$

because the amplitude $C$ cancels. So if you write $\rho = (1+u)/(1+l)$ for the *window ratio* and $R$ for the observed peak-to-end ratio, the exponent is identified by a single division:

$$a = \frac{\log R}{\log \rho}.$$

Two measurements pin the whole curve: a power law is determined by its values at any two distinct points, both amplitude and exponent, with no residual freedom. And there is a memorable steepness criterion buried in the formula:

> **Steepness Test.** If the observed peak-to-end ratio exceeds the window ratio, $R > \rho$, then $a > 1$ — the decline is steeper than reciprocal.

That threshold matters because $a = 1$ is the boundary between a rate whose integral over $(0,\infty)$ diverges logarithmically and one that converges: it separates "heavy but summable" from "scale-invariant". For the recorded exponent $a \approx 1.104$, the observed ratio $R = 2.54$ corresponds to a window ratio of $\rho = R^{1/a} \approx 2.33$ in the shifted coordinate — comfortably consistent, and comfortably in the steep regime.

---

## Now the ghost

So where did the bump come from? Not from the positional shape. It came from the ruler.

No one measures an absolute rate. One measures a rate *relative to a baseline*: an expected profile derived from a model of the process that would be operating even if nothing interesting were happening. In this experiment the baseline was of mixture-Dickman type, which for the purposes of the mathematics we can write in the analytically tractable form

$$B(x) = C'(1+x)^{-a'}e^{-bx}.$$

The reported quantity is the *log-residual*, the log of signal over baseline. Take logs and everything collapses beautifully:

$$\log \frac{T(x)}{B(x)} \;=\; \log\frac{C}{C'} \;+\; d\log(1+x) \;+\; bx, \qquad d := a' - a.$$

Every trace of the individual models has vanished except one number: $d$, the **curvature mismatch** between the baseline's exponent and the signal's. If $d = 0$, the residual is a straight line plus a constant — flat and boring. If $d \neq 0$, it is curved.

Now add the step that every practitioner performs without thinking: the residual is *calibrated*, tilted so that it agrees at the two ends of the window. Any monotone drift is absorbed into the fit; what remains is the deviation of the middle from the ends. That calibration fixes the tilt to

$$b^\star = -\,d\,\frac{\log(1+u) - \log(1+l)}{u-l}.$$

With that tilt, $r(l) = r(u)$ exactly — and then something inevitable happens.

> **Baseline Leakage Manufactures a Mid-Window Mode.** If the baseline is *more* curved than the signal ($d > 0$) and the tilt is calibrated to match the residual at the window edges, then the residual $r(x) = d\log(1+x) + b^\star x$ has a genuine strict interior maximum on $[l,u]$ — every other point of the window is strictly below it — even though the underlying signal is strictly decreasing and mode-free.

You can see why in one line. The function $r$ is strictly concave (its second derivative is $-d/(1+x)^2 < 0$), and a strictly concave function with equal values at the two ends must bulge upward in between. A bump appears. It is a real feature of the residual, reproducible, statistically significant, and about a positional mechanism it says precisely nothing.

---

## Exactly where the ghost lives

Here is the part that turns a cautionary tale into a usable instrument. The location of the manufactured bump is not arbitrary. Differentiate: $r'(x) = d/(1+x) + b^\star = 0$ gives

$$1 + x^\star = \frac{-d}{b^\star} = \frac{u-l}{\log(1+u)-\log(1+l)}.$$

The mismatch $d$ *cancels*. What is left is the **logarithmic mean** of the two window edges in the shifted coordinate,
$$L(A,B) = \frac{B-A}{\log B - \log A}, \qquad A = 1+l,\ B = 1+u,$$
a quantity that has been floating around analysis and heat-transfer engineering for two centuries. The peak sits at $x^\star = L(A,B) - 1$, a location determined entirely by the window and not at all by how badly the baseline was misspecified.

And the logarithmic mean has a famous place in the pecking order of averages:

$$\sqrt{AB} \;<\; \frac{B-A}{\log B - \log A} \;<\; \frac{A+B}{2} \qquad (0 < A < B).$$

Geometric mean below, arithmetic mean above. Both inequalities become transparent in the normal form $B = Ae^{2s}$ with $s>0$: the three means become $Ae^{s}$, $Ae^{s}\sinh(s)/s$, and $Ae^{s}\cosh(s)$, so the chain reduces to the two elementary facts $s < \sinh s$ and $\tanh s < s$. (The second follows by noting that $t\cosh t - \sinh t$ vanishes at $0$ and has derivative $t\sinh t > 0$.)

Translate back and you get a hard, falsifiable prediction:

> **The Ghost Is Trapped in the Left Half.** An endpoint-matched curvature-leakage artefact always sits strictly between the geometric mean of the window edges and the window midpoint:
> $$\sqrt{(1+l)(1+u)} - 1 \;<\; x^\star \;<\; \frac{l+u}{2}.$$

The upper bound is the punchline. **A peak observed in the right half of a window cannot be produced by this mechanism.** The logarithmic mean is strictly less than the arithmetic mean, always, and the gap does not depend on the size of the baseline error. On the unit window $[0,1]$, for instance, the ghost sits at $1/\log 2 - 1 = 0.44266\ldots$, trapped between $\sqrt{2}-1 = 0.4142$ and $0.5$ — never at $0.6$.

---

## The tell: bump height scales, bump position does not

The second signature is even sharper. Write $A(d)$ for the height of the manufactured bump above the common edge value. A short computation with the logarithmic mean $L$ gives the closed form

$$A(d) = d\left[\log\frac{L}{A} - 1 + \frac{A}{L}\right],$$

which is strictly positive for $d>0$ (because $\log t > 1 - 1/t$ for $t>1$) and, crucially, is **exactly proportional to $d$**:

> **Amplitude Scales Linearly, Location Does Not Move.** The height of a leakage bump is exactly proportional to the curvature mismatch $d$, while its location — the logarithmic mean of the edges — is completely independent of $d$.

That is an experimental protocol, not just a formula. Perturb the baseline's curvature deliberately: double the mismatch. If the bump doubles in height and stays exactly where it was, you are looking at leakage. If it moves, or if it fails to scale, you are looking at something else. Few diagnostics in applied statistics are that crisp.

There is also a sign rule, and it is absolute. If the baseline is *less* curved than the signal ($d < 0$), the residual is convex rather than concave, and then no tilt whatsoever — calibrated, fitted, adversarially chosen — can produce an interior maximum. Convexity forbids it. Bump or dip is decided by the *sign* of the curvature mismatch; its magnitude only sets the scale.

Nor is any of this an artefact of choosing a power-law baseline. Let $g$ be *any* continuous, strictly convex excess in the log-baseline over the window, and tilt by the secant slope $c = (g(u)-g(l))/(u-l)$. Then $cy - g(y)$ is strictly concave with matching endpoint values, and a strict interior maximum exists. Curvature alone does it. The power-law calculation just tells you *where*.

---

## Binning is innocent

One more suspect had to be cleared. The re-analysis that closed this question was run with *zero binning* — raw hit indicators, stratum-conditional, $128$ profiled intercepts, no histogram anywhere — precisely because binning is the traditional scapegoat for spurious shape. It deserves to be exonerated in at least one direction.

Suppose you take a continuous shape $f$ that is strictly decreasing, and average it over equal-width blocks $[l + kh,\, l+(k+1)h]$. Sliding a window of fixed width $h$ to the right strictly decreases its integral, because at every offset the shifted curve is strictly below the original. Hence:

> **Block Averages Preserve Decline.** Equal-width block averages of a continuous, strictly decreasing shape are themselves strictly decreasing — for any bin width. The first bin dominates every later bin, and no bin strictly inside the range can be a maximum.

Binning can blur a peak, and it can lower one; it cannot conjure one out of a monotone decline. The observed strictly declining deciles were therefore not a binning accident, and neither would a peak have been.

---

## What was actually concluded

Putting the pieces together produced an erratum rather than a discovery, and a better result than the discovery would have been.

The claimed **peaked mid-window residual is retracted** — not as noise, but as *baseline curvature leakage*: the excess lived in the curvature of the mixture denominator, not in the positional shape. The theorem behind the retraction is a principle, not an excuse:

> **Erratum Principle.** A strict interior mode in a log-residual is impossible when the log-baseline differs from the log-signal by an affine function. Therefore any observed strict interior mode is a proof of baseline misspecification, never evidence for a positional mode within the power-law family.

Meanwhile the **power law itself stands, and stands stronger than before**: re-found without any binning at all, with a steep monotone decline, a peak-to-end ratio of $2.54$, an interior maximum pinned to the left edge in every bootstrap replicate, and a control arm that is properly null (permutation $p = 0.856$). The residual ripple of $+1.6\%$ near the middle of the window is a baseline-relative wrinkle, not a mode.

The absolute-shape channel is closed. And because the closure is theorem-backed rather than merely empirical, the closure has teeth: to reopen it, a future claim must be a *baseline-misspecification* claim, and it must survive the location trap (left half only) and the amplitude test (height proportional to mismatch, position immovable). One open item remains on the thread — a covariate at the rate layer — but the shape question itself is settled.

---

## Why this generalizes

None of the mathematics above knows anything about the experiment that motivated it. Every ingredient is generic to the practice of measuring one curve against another:

1. **A significance test against a linear alternative measures curvature, not location.** Rejecting linearity licenses "not a straight line" and nothing more.
2. **Endpoint-calibrated residuals of curvature-mismatched models bulge in the middle, always.** The bulge is a theorem about concavity, not a finding about nature.
3. **The bulge is trapped between the geometric mean and the midpoint of the window**, so it is confined to the left half, and its height is exactly linear in the mismatch while its location is exactly independent of it.
4. **Coarse-graining a monotone decline leaves it monotone.**

Any field that fits ratios to models — astronomy fitting counts against a luminosity function, genomics fitting coverage against a GC-content baseline, particle physics fitting a spectrum against a smooth background, epidemiology fitting incidence against a demographic expectation — is running the same machinery and is exposed to the same ghost. The remedy is not more data. It is knowing exactly where the ghost has to stand, and how tall it has to be.

That is what makes a negative result worth writing down. The bump is gone; the power law survived; and the next person to see a bump in the middle of a window now has two numbers to check before believing it.
