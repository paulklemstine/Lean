# The Feature That Vanished: Why an Effect Can Be Real and Still Not Replicate

## A number that refused to come back

Somewhere in a long-running measurement campaign, a small victory was recorded. A predictive
model — a "dial" that converts a structural footprint of an object into a prediction of its
yield — was improved by adding one extra ingredient: an indicator that flags whether a key
index is a *prime power*, a number of the form $p^k$. Adding this flag raised the fraction
of explained variance by $+0.089$. Not enormous, but real, clean, and reproducible on that
population.

Then the same augmented dial was run on five fresh populations. The added value of the
prime-power flag was, in every single case, indistinguishable from zero. The full augmented
model reported explained-variance readings of
$$0.490,\quad 0.555,\quad 0.428,\quad 0.532,\quad 0.508,$$
with mean $0.502$; exactly one of the five cleared the target of $0.55$. If each fresh
population really had an $80\%$ chance of clearing the target, seeing at most one success out
of five would have probability at most $21/3125 < 0.007$. The hypothesis is dead.

And yet nothing else broke. The baseline footprint dial replicated. The marginal association
between the prime-power flag and the yield replicated. The transfer slope, measuring how well
the footprint carries from one population to the next, came in at $0.898$ — comfortably in
band. Every dial that could be read replicated except the one that mattered.

This article is about what is really going on. The punchline is not "noise". The punchline is
that the quantity that failed to replicate — an *increment*, the extra explanatory power one
feature buys **on top of** another — is a fundamentally different kind of object from the
quantities that did replicate. It is a knife-edge functional of the population, it is
determined by exactly five numbers, and it can be silently annihilated by a mechanism that
leaves every other diagnostic in the report untouched. Once you see the geometry, the
non-replication stops looking like a failure of the experiment and starts looking like a
theorem.

## The set-up, stripped to its bones

Fix a finite collection of *keys* — think of them as the objects being measured, indexed
$1, 2, \dots, n$. A **draw regime** is a probability weighting $p = (p_1, \dots, p_n)$ with
$p_i \ge 0$ and $\sum_i p_i = 1$: it says how often each key is sampled. Every quantity we
measure is a function on keys, averaged against $p$. Write
$$\langle f, g\rangle = \sum_i p_i f_i g_i, \qquad
\sigma_{fg} = \sum_i p_i (f_i - \bar f)(g_i - \bar g),$$
for the weighted inner product and the weighted covariance, with $\bar f = \sum_i p_i f_i$.

Three functions matter. The **footprint** $x$ is the validated baseline predictor. The
**feature** $z$ is the candidate addition — here the $0/1$ prime-power indicator. The **rate**
$y$ is what we are trying to explain.

The baseline model fits $y \approx a + bx$ by least squares, leaving a residual
$r_i = y_i - a - b x_i$. That residual is characterised by two equations — it averages to
zero and it is uncorrelated with the footprint — and those two equations are not merely
descriptive but a *certificate*: any affine predictor $a' + b'x$ has weighted mean squared
error at least that of $a + bx$. So "the residual" is unambiguous.

The baseline's score is the variance share
$R^2(x,y) = \sigma_{xy}^2 / (\sigma_{xx}\sigma_{yy})$, and the number under dispute is the
**increment**
$$\Delta R^2(z) \;=\; R^2(\text{footprint and feature}) \;-\; R^2(\text{footprint alone}).$$

## What an increment actually measures

Here is the first key fact. Adding the feature $z$ to a model that already contains the
footprint does not use all of $z$. It uses only the part of $z$ the footprint cannot already
express. Split $z$ into its own affine-in-$x$ part plus a remainder $\tilde z$, the
**partialled feature**. Then, writing $\|f\|^2 = \langle f,f\rangle$,
$$\Delta R^2(z)\cdot \sigma_{yy} \;=\; \frac{\langle r, \tilde z\rangle^2}{\|\tilde z\|^2}.$$

A pleasant symmetry makes this workable: it does not matter which side you residualise.
The partial covariance satisfies
$$\langle r, z\rangle \;=\; \langle r, \tilde z\rangle \;=\; \langle y, \tilde z\rangle,$$
because a residual is blind to any affine function of the footprint. This *duality* is the
structural fact behind everything that follows.

Two immediate consequences. First, the increment is at least as large as the cruder statistic
that regresses the raw feature against the residual, but the two vanish *together* — so
"the feature contributes nothing" is an unambiguous statement, not an artefact of which
version you compute. Second, the increment factors exactly:
$$\Delta R^2(z) \;=\; \bigl(1 - R^2(x,y)\bigr)\cdot \rho_{\text{partial}}^2 ,
\qquad \rho_{\text{partial}}^2 = \frac{\langle r,\tilde z\rangle^2}{\|r\|^2\,\|\tilde z\|^2}.$$
The increment is a product of *how much is left to explain* and *how well the leftover
feature explains it*. Either factor can shift between populations, and neither is visible in
the base dial alone. Already this tells you that a replicated baseline gives no guarantee
whatsoever about an increment.

## Absence is exact, not approximate

When does the increment vanish? Exactly when $\langle r, \tilde z\rangle = 0$ — when the
partialled feature is orthogonal to the residual. This is a razor-thin condition, and that
thinness is quantifiable.

Fix the population's draw regime and its feature; let the rate profile vary over all of
$\mathbb{R}^n$. The map $y \mapsto \langle y, \tilde z\rangle$ is a *linear functional*, and
(provided the partialled feature is not degenerate) it is onto. So the set of rate profiles
for which the feature contributes exactly nothing is the kernel of a surjective linear map:
a **hyperplane of codimension exactly one** in the $n$-dimensional space of rate profiles.

That is a sharp dichotomy. Zero increment on one population is a coincidence of measure zero
— you would never expect to land on it by accident. Zero increment on five fresh populations
in a row is not a coincidence at all. It is structure. The observed pattern is telling us
that these populations are being pushed onto the absence locus by something systematic.

## Five numbers, and nothing else

What is that something? To find out, we ask what the increment is a function of. The answer
is startlingly small. Write the five second moments
$$\sigma_{xx},\quad \sigma_{xy},\quad \sigma_{xz},\quad \sigma_{zy},\quad \sigma_{zz}.$$
Then the partial covariance and the partialled energy have closed forms,
$$\langle r,\tilde z\rangle = \sigma_{zy} - \frac{\sigma_{xy}\sigma_{xz}}{\sigma_{xx}},
\qquad
\|\tilde z\|^2 = \sigma_{zz} - \frac{\sigma_{xz}^2}{\sigma_{xx}},$$
and therefore
$$\Delta R^2(z)\cdot\sigma_{yy}
= \frac{\bigl(\sigma_{zy} - \sigma_{xy}\sigma_{xz}/\sigma_{xx}\bigr)^2}
{\sigma_{zz} - \sigma_{xz}^2/\sigma_{xx}}.$$

The increment is a rational function of five second moments and *nothing else*. Two
populations built on entirely different key sets, sampled under entirely different draw
regimes, with different sizes and different higher-order structure, that happen to agree on
those five numbers, report the *same* increment. Full stop.

This is an exoneration and an indictment at once. It exonerates every explanation that lives
above second order: no seed-specific quirk, no heavy tail, no third moment, no idiosyncrasy
of a particular sampling run can be responsible for the non-replication. And it indicts the
second moments: whatever changed, it changed one of those five numbers. The search space for
the cause has collapsed from "everything about the population" to five scalars.

The formula also makes the absence locus explicit. The increment is zero precisely when
$$\sigma_{zy}\,\sigma_{xx} \;=\; \sigma_{xy}\,\sigma_{xz}.$$
This is a *quadric*: a genuine algebraic surface in moment space, not a fuzzy neighbourhood.
Its meaning is plain. The feature's covariance with the rate is exactly what the footprint
would have predicted it to be, given how the feature and the footprint overlap. The feature
carries signal; it just carries no signal the footprint has not already spent.

## The trap: identical diagnostics, opposite conclusions

Now the sharpest construction in the story, and the one that should change how such
experiments are reported.

Take four keys with footprint $w = (1,2,3,4)$ and prime-power indicator
$\mathrm{pp} = (1,1,0,0)$, sampled uniformly. Consider two rate profiles:
$$y^{\text{sup}} = \left(\tfrac{7}{10}, -\tfrac{2}{5}, -\tfrac{3}{10}, 1\right),
\qquad
y^{\text{act}} = \left(\tfrac{3}{10}, \tfrac{2}{5}, -\tfrac{7}{10}, 1\right).$$

Compute every marginal diagnostic. The footprint dial reads $R^2(w,y) = 5/149$ on **both**.
The marginal prime-power dial reads $R^2(\mathrm{pp}, y) = 4/149$ on **both**. The rate
variance is $149/400$ on **both**. The footprint–feature overlap $\sigma_{xz}$ is a property
of the features alone, so it is identical too. Every single number the experiment records is
the same. The two populations differ only in the *sign* of the covariance between the feature
and the rate: $\sigma_{zy} = -1/20$ versus $+1/20$.

And their increments are
$$\Delta R^2(\mathrm{pp}) = 0 \quad\text{and}\quad \Delta R^2(\mathrm{pp}) = \frac{80}{149}
\approx 0.537 .$$

One population where the prime-power feature contributes *nothing*, and one where it
contributes more than half the variance — and no marginal diagnostic in the entire report can
tell them apart. The first sits exactly on the absence quadric; the second does not. The
mechanism has a name in the statistical literature: **suppression**. The footprint and the
feature overlap, and in the first population that overlap exactly cancels the feature's own
association with the rate.

This is why the original experiment's stable readings offered no protection. Stability of
marginals is not weak evidence for a replicable increment; it is *no* evidence.

## The mirror image: real signal, zero contribution

The dual phenomenon is just as instructive. Take four keys, a footprint
$w' = (7/2, 7/2, 1, 0)$ and a rate $y' = (4,3,1,0)$. Here the prime-power indicator is
*comonotone* with the rate: whenever the flag goes up, the rate does not go down. Comonotone
features have strictly positive covariance with the rate under *every* full-support draw
regime — this is as strong and regime-robust a marginal signal as one can ask for. The
footprint model is not saturated either: it explains $19/20$ of the variance and leaves
genuine residual energy behind.

And the prime-power feature's increment over the footprint is exactly $0$.

So a feature can be genuinely, universally, robustly associated with the outcome, in a model
that still has room to improve, and contribute precisely nothing once the baseline is in
place. Reporting $\Delta R^2(\mathrm{pp}) \approx 0$ is entirely consistent with the
prime-power structure being real. It simply is not *new*.

## Why it might be doomed at scale anyway

There is a second, completely different mechanism, and it needs no cancellation at all —
only sparsity.

Suppose the feature is a $0/1$ indicator with density $\delta = \sum_i p_i z_i$ under the
draw regime, and suppose the baseline residual is bounded, $|r_i| \le B$. Then
$$\text{gain} \;\le\; B^2\,\delta .$$
That is all: an indicator that is rarely on cannot buy much, whatever it is correlated with.
Consequently, if $\delta < \varepsilon/B^2$ the gain is below $\varepsilon$, uniformly over
all bounded residuals.

Now count prime powers. Among $1, 2, \dots, N$ they thin out — every prime power above $3$ is
congruent to $\pm 1$ modulo $6$, which already caps the density at about $1/3$, and the true
density tends to zero. So on large key ranges, under any draw regime that does not
deliberately over-sample prime powers, the prime-power feature is *structurally* incapable of
delivering a sizeable increment against a bounded residual. The $+0.089$ observed once was
tied to a small key range and a particular population; it was never going to scale.

## Two loose ends, tied off

**Could re-weighting explain it?** No. The partial covariance is Lipschitz in the draw
regime: if two regimes $p$ and $q$ differ by $\sum_i |p_i - q_i|$ in total variation, and the
products $r_i z_i$ are bounded by $M$, then the covariances differ by at most
$M \sum_i |p_i - q_i|$. So if the feature is exactly absent under one regime, its gain under a
nearby regime is at most *quadratically* small in the regime distance. You cannot resurrect an
absent feature by re-weighting a population; you have to change the population.

**Why is the transfer slope below one?** Because it must be. If the measured footprint is
$x + u$, with noise $u$ uncorrelated with both the true footprint and the rate, and the rate
is calibrated so that $\sigma_{xy} = \sigma_{xx}$, then the fitted transfer slope is exactly
$$\frac{\sigma_{xx}}{\sigma_{xx} + \sigma_{uu}} ,$$
which is strictly less than $1$ whenever the noise is nondegenerate. If the noise is at most a
fifth of the signal, the slope lands in $[5/6, 1)$ — and the observed $0.898$ is squarely in
that band. A slope below one is not evidence of decay; it is attenuation, and it is forced.

## What to take away

The story has a clean moral, and it is not confined to prime powers.

Marginal statistics and incremental statistics are different species. The marginal ones —
covariances, single-predictor variance shares, comonotonicity, transfer slopes — are robust,
regime-stable, and replicate readily. Increments are none of those things. An increment is a
*difference* of two fits, and differences live on knife edges: they vanish on a quadric, their
zero set is a hyperplane of codimension one, and they are determined by five second moments
that can conspire to cancel without moving any headline number.

So when a validated model gains a small amount from a new ingredient, the honest question is
not "is the gain significant?" but "is the population sitting near the absence quadric, and
would a fresh population sit somewhere else?" Answering that means reporting the partial
covariance and the overlap $\sigma_{xz}$, not just the marginal dials. Absence, when it comes,
is exact and structural — and the same geometry that explains why it happened tells you
exactly which five numbers to check next time.

The prime-power feature did not fail because the measurement was noisy. It failed because,
on those populations, the footprint had already spent everything it had to say.
