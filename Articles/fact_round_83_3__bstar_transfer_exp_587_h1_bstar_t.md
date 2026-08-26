# The Peak That Wasn't There: What a Window Curve Really Tells You

## A number that everybody trusts

Somewhere in almost every quantitative laboratory there is a dial. You turn it,
you watch a number, and you stop turning when the number stops improving.

In the experiment that motivates this article, the dial is a *window*. Data are
collected about a family of arithmetic objects — say, one measurement per sampled
modulus $N$ — and the explanatory variable is built by summing up contributions
from small primes $\ell$ below a cutoff $B$:

$$S_{w,B} \;=\; \sum_{\ell \le B} w(\ell)\, v_\ell .$$

Here $v_\ell$ is a column of numbers, one per sample: the indicator of some
local condition at the prime $\ell$. The function $w$ is a *weight* — how loudly
each prime is allowed to speak. And $B$ is the dial: how many primes are allowed
to speak at all.

The number you watch is the coefficient of determination $R^2$ of the simple
regression of the response on $S_{w,B}$ — the fraction of variance the window
statistic explains. Turn the dial and record the curve.

In the run that prompted this work, the curve looked like this, on a
factor-of-two grid of cutoffs, under the weight $w(\ell) = \ell^{-1/2}$:

| cutoff $B$ | 100 | 200 | **400** | 800 | 1600 |
|---|---|---|---|---|---|
| $R^2$ | .528 | .598 | **.624** | .591 | .614 |

A rise, a peak at $B^\star = 400$, and then a fall. The natural reading writes
itself: *the information saturates at 400; primes beyond that carry nothing.*
The location $400$ gets a name, gets adopted as the laboratory's standard
setting, and enters the next paper as a fact about the primes.

Under the competing weight $w(\ell) = \ell^{-1}$ the same data produce a flat
plateau with a shrug of a maximum at the far edge, $1600$, exceeding the value at
$400$ by $0.006$ — pure noise. So the "saturation at 400" is visible under one
weight and invisible under the other.

This article is about what that peak actually means. The short answer, made
precise below, is startling: **an interior peak is not a fact about the primes at
all. It is a certificate that your weight is wrong.**

## Stripping the problem to its skeleton

To see this, forget primes for a moment and keep only the structure.

We have a response vector $y \in \mathbb{R}^n$ — one number per sample — and $m$
predictor columns $v_0, v_1, \dots, v_{m-1}$, also in $\mathbb{R}^n$. Assume the
idealisation that distinct columns carry independent information: they are
pairwise orthogonal, $\langle v_i, v_j\rangle = 0$ for $i \ne j$, and none is
zero. Write

$$s_i = \|v_i\|^2 \quad \text{(the mass of column } i), \qquad
a_i = \langle v_i, y\rangle \quad \text{(its signal)}.$$

The window statistic is $S_{w,B} = \sum_{i<B} w_i v_i$, and orthogonality makes
its two relevant scalars collapse into sums:

$$A_B = \langle S_{w,B}, y \rangle = \sum_{i<B} w_i a_i, \qquad
\Sigma_B = \|S_{w,B}\|^2 = \sum_{i<B} w_i^2 s_i .$$

The score you watch on the dial is exactly

$$R^2(w,B) \;=\; \frac{A_B^2}{\Sigma_B \,\|y\|^2}.$$

That this really is the regression $R^2$, and not merely a suggestive ratio, is
the content of a single identity. For any slope $b$,

$$\|y - b\,S_{w,B}\|^2 \;=\; \|y\|^2\bigl(1 - R^2(w,B)\bigr) \;+\;
\Sigma_B\Bigl(b - \tfrac{A_B}{\Sigma_B}\Bigr)^{\!2}.$$

Read it twice. The second term is a square, so no slope does better than
$\|y\|^2(1-R^2)$, and the best slope is the familiar least-squares one — that is
optimality. And since the left side is a sum of squares and hence nonnegative,
$R^2 \le 1$ — that is the calibration of the scale. One line of algebra, two
theorems.

## What one more prime does

Now turn the dial by one notch: add column $B$ with weight $w_B$. It contributes
signal $p = w_B a_B$ to the numerator and mass $c = w_B^2 s_B$ to the
denominator. The score changes by exactly

$$R^2(w,B{+}1) - R^2(w,B) \;=\;
\frac{\Sigma_B\, p\,(2A_B + p) \;-\; A_B^2\, c}
{\Sigma_B(\Sigma_B + c)\,\|y\|^2}.$$

Everything about window curves follows from the sign of that numerator. Two
corollaries make the empirical picture rigorous.

**Noise dilutes.** If the new column is orthogonal to the response — $a_B = 0$,
no signal whatsoever — but you still give it a nonzero weight, then $p=0$, $c>0$,
and the change is strictly negative. The score *falls*. This is worth
emphasising because it contradicts the usual intuition about saturation.
Saturation is not a curve flattening out as fresh information runs dry; it is a
curve being actively pushed down by mass you insisted on adding. Every useless
prime you let into the window costs you.

**Signal helps.** If the new column's weighted contribution is at least as
efficient as the running average — precisely, if $p\Sigma_B \ge A_B c$ with
$p>0$ — the score strictly rises.

Put the two together and you get the mechanism behind every clean "saturation"
plot. Suppose the first $t$ columns are *matched* to the weight, meaning their
weighted contributions all sit on one common slope, $w_i a_i = \rho\, w_i^2 s_i$
for $i < t$, all strictly positive; and suppose every later column in the window
is pure noise, $a_i = 0$, but still receives a nonzero weight. Then the curve
$B \mapsto R^2(w,B)$ is strictly increasing on $[0,t]$ and strictly decreasing on
$[t,m]$. Its maximum is attained at $t$ and nowhere else: **a unique interior
peak**.

So the shape is real, and it is explained. But by what?

## The matched filter, and the sting in the tail

There is one distinguished weight. Give each column exactly the weight that its
own single-column regression would assign:

$$w^{\mathrm{mf}}_i \;=\; \frac{a_i}{s_i}.$$

This is the *matched filter*, and it is the same object that appears in radar
detection and in optimal linear estimation. Under it, numerator and denominator
coincide: both equal the *explained signal*

$$E(B) = \sum_{i<B} \frac{a_i^2}{s_i},$$

so the score is simply $R^2(w^{\mathrm{mf}}, B) = E(B)/\|y\|^2$.

Three consequences follow immediately, and together they overturn the naive
reading of the dial.

*First: the matched filter never peaks in the interior.* $E$ is a sum of
nonnegative terms, so it is nondecreasing in $B$. Widening the window can never
hurt. A noiseless column contributes $0$ and the curve simply holds flat — an
exact plateau, not a decline. The matched curve's maximum always includes the
far edge.

*Second: the matched filter dominates every rival, at every window
simultaneously.* For any weight $w$ and any cutoff $B$,

$$R^2(w,B) \;\le\; R^2(w^{\mathrm{mf}},B).$$

Not "on average", not "eventually" — pointwise on the whole grid. This is the
precise form of the empirical observation that one weight raised the plateau
everywhere: in the data table above, the $\ell^{-1/2}$ weight beat the harmonic
weight at all five cutoffs, by between $+0.089$ and $+0.151$, with no
weight-by-window interaction. That is exactly the signature of moving toward the
matched direction, and it is a theorem, not a coincidence.

*Third — and this is the sting — an interior peak is a certificate of
mismatch.* Suppose your measured curve has $R^2(w,t) > R^2(w,m)$ for some
interior $t < m$: the peak beats the far edge. Then $w$ cannot be the matched
filter, nor any rescaling of it. The proof is two lines: $R^2$ is invariant under
multiplying the whole weight by a nonzero constant, so if $w$ were proportional
to $w^{\mathrm{mf}}$ its curve would be the matched curve, which is monotone — and
a monotone curve cannot dip below its own peak at the far end.

Turn that around and it is a piece of practical advice with teeth. **The peak
you are proudly reporting is your instrument telling you that it is
misconfigured.** A genuinely well-chosen weight would not have a peak at all;
it would have a plateau. The "saturation location $B^\star$" measures the point
at which the deadweight of the mass you are adding overtakes the signal you are
extracting — which depends on how you are weighting, not on where the arithmetic
information stops.

## How big is the drop, and why near-ties are normal

The same calculus explains a nagging feature of real data: the runner-up is
often almost as good as the winner.

In a signal-then-noise window — every column after $t$ orthogonal to the
response — the drop from the peak to the far edge is exactly

$$R^2(w,t) - R^2(w,m) \;=\; R^2(w,t)\cdot \frac{\Sigma_m - \Sigma_t}{\Sigma_m}.$$

The whole margin is governed by one dimensionless quantity: the *relative added
mass*, the fraction of the total window mass contributed by the columns beyond
$t$. If the tail columns are lightly weighted — and under $w(\ell) = \ell^{-1/2}$
the primes between $400$ and $1600$ are indeed lightly weighted — that fraction
is small and the drop is small.

So the observed near-tie in the motivating experiment (the far window sitting
only $0.0105$ below the peak, with a bootstrap argmax splitting $\{400: 276,\,
1600: 178\}$ out of $500$ resamples) is not a defect in the analysis. It is
predicted. And its consequence for inference is quantified by a matching pair of
stability statements: if the peak beats every rival by a margin $\delta$, then
*every* perturbation of the curve smaller than $\delta/2$ leaves the argmax where
it is; and conversely, for any $\varepsilon>0$ there is a perturbation of size
$\delta/2 + \varepsilon$ that flips the argmax onto a runner-up sitting $\delta$
below. Half the top-two gap is exactly the noise budget — no more, no less. A
bimodal bootstrap tail is what you should *expect* when resampling noise is
comparable to that budget, and the honest report is "saturation is reached by
$400$; nothing further is gained through $1600$", not "the peak is at $400$ and
not at $1600$".

## Does the peak location tell you anything about the columns?

One might retreat to a weaker hope: fine, the peak is weight-dependent, but
surely its *location* says something about the underlying column family — about
the primes.

It does not, and the counterexample is complete rather than partial. Fix *any*
family of pairwise orthogonal nonzero columns $v_0,\dots,v_{m-1}$, and pick *any*
interior cutoff $1 \le t < m$ you like. Take the response to be the plain sum of
the first $t$ columns, $y = v_0 + \cdots + v_{t-1}$. Then the unit-weight window
curve has its unique maximum exactly at $t$. Every interior location is
realisable inside every column family. A measured $B^\star$ constrains the
response and the weight; it says nothing whatever about the columns.

This holds in particular for the most combinatorial supply of column families
imaginable: $\pm 1$ designs of strength two, in which any two distinct columns
agree on exactly half the samples — the rows of a Hadamard matrix being the model
case. Such a family automatically satisfies the orthogonality hypothesis, with
every column having mass equal to the sample size. The order-$4$ Hadamard matrix
with response $y = h_0 + h_1 = (2,0,2,0)$ gives a fully explicit miniature of the
whole phenomenon: the unit-weight curve is

$$0,\ \tfrac12,\ 1,\ \tfrac23,\ \tfrac12$$

as the window runs $0,1,2,3,4$ — up to a perfect fit at $t=2$, then down. And the
peak margin is $1 \cdot \frac{16-8}{16} = \frac12$, exactly as the formula
predicts.

## The last hope: unimodality

There is one more thing an experimenter might want to believe. Even granting all
of the above, surely the *underlying* curve rises and then falls — one hump, one
maximum — so that any second bump in a bootstrap histogram must be resampling
noise?

No. Consider three perfectly orthonormal columns — the standard basis of
$\mathbb{R}^3$ — unit weights, and the response $y = (3,1,1)$. The signals are
$a = (3,1,1)$, the masses are all $1$, so the per-column efficiencies
$a_i/s_i = 3, 1, 1$ are already sorted in decreasing order: there is no "you
scanned the columns in a silly order" excuse available. The curve is

$$R^2(1) = \frac{27}{33}, \qquad R^2(2) = \frac{24}{33}, \qquad
R^2(3) = \frac{25}{33}.$$

It falls, then rises. There is a strict interior local *minimum* at $B=2$, hence
two distinct local maxima, at $B=1$ and at $B=3$. The window curve of a perfectly
well-behaved orthogonal design need not be unimodal. A second mode in an argmax
distribution is therefore not, by itself, evidence of a broken estimator: it can
be a faithful picture of a genuinely two-humped curve.

The reason is easy to feel once seen. Adding the second column dilutes: it brings
mass $1$ but only signal $1$, against a running slope of $3$. Adding the third
does the same thing — but by then the running slope has already fallen to $2$,
and a column of efficiency $1$ is no longer as badly out of step. Dilution is
self-limiting, and once it slows enough, accumulation wins again.

And the punchline repeats itself: on that very same data, the matched filter —
here $w = (3,1,1)$, the signals themselves — produces the curve
$\frac{9}{11}, \frac{10}{11}, 1$, strictly increasing to a perfect fit. The
bimodality, like the interior peak and like the "saturation location", is a
property of the weight, not of the columns.

## What to do on Monday morning

The mathematics assembles into a short and unusually actionable checklist for
anyone who reports a saturation cutoff.

1. **A peak is a diagnosis, not a discovery.** If your score curve has an
   interior maximum, your weight is provably not the matched one, and a better
   weight exists that dominates yours at every cutoff at once.
2. **Compute the matched filter and look at its curve.** It is monotone by
   construction, and its value at the full window, $E(m)/\|y\|^2$, is a hard cap:
   no weight and no cutoff, anywhere in your entire design space, can exceed it.
   That single number tells you how much of your response is explainable at all.
3. **Report a margin, not just a location.** The peak margin equals the score
   times the relative added mass, and the argmax is provably stable only against
   perturbations below half the top-two gap. If the gap is $0.01$ and your
   resampling noise is $0.02$, you have measured a plateau, not a peak.
4. **Do not read geometry into $B^\star$.** Every interior location is realisable
   inside any fixed orthogonal column family; and curves with two humps exist
   even for orthonormal columns with sorted efficiencies.

None of this makes the original experiment worthless. Quite the opposite: it
converts a soft claim ("information saturates at $400$") into a sharp one ("the
$\ell^{-1/2}$ weight dominates the harmonic weight at every cutoff, and the
saturation observed by $400$ reflects the mass–signal tradeoff of that weight").
The first claim was about the primes and was unsupported. The second is about the
instrument, and it is true.

That trade — a romantic claim exchanged for a correct one — is what a theorem
buys you. And in this case the theorem also hands back something the experiment
could never have found on its own: the matched filter, sitting quietly at the top
of the whole design space, dominating every dial setting simultaneously, waiting
to be used.
