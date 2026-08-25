# The Bump That Wouldn't Go Away

## What histograms can and cannot lie about

Somewhere near two-thirds of the way along a curve, there is a bump.

The curve came out of a numerical experiment: a ratio $R(u) = T(u)/M(u)$ of a measured
quantity to a modelled baseline, plotted over a normalised window $u \in [0,1]$. If the
model were perfect, $R$ would sit flat at $1$. It does not. Around $u^{*} \approx 0.65$
it rises to roughly $1.2$ — a hump, a fifth again above the baseline, sitting in the
middle of the window like a wave that refuses to break.

Anybody who has stared at a histogram knows the next question, and knows to dread it.
**Is the bump in the data, or in the picture?**

A histogram is not a neutral instrument. It has two knobs: how wide you make the bins,
and where you start counting. Turn either knob and the picture changes. Features
appear, features vanish; a "peak" can be nothing more than the accident of a boundary
falling in a lucky place. Statisticians have known this for a century, and the standard
response is to shrug: *try a few bin widths, and if the feature survives, believe it.*

That is a folk rule, not a theorem. This article is about replacing it with theorems —
about working out precisely which properties of a bump are immune to the histogram's
two knobs, and which are hostages to them. The answer turns out to be sharp and, in
places, surprising. Some things a histogram literally cannot fake. Some things it
cannot help but distort, but by an amount you can write down in closed form. And one
thing that everybody instinctively treats as the *conservative* choice — fitting a
smooth parabola to the top of the bump instead of trusting the raw bar heights — turns
out to bias the answer in the opposite direction from the one you would guess.

---

## Thirty pictures of the same curve

The experiment that provoked all this was a deliberately dumb one, in the good sense.
Take the curve. Histogram it six ways, with $10$, $20$, $33$, $50$, $66$ and $100$ bins.
For each of those, slide the whole grid sideways by five different amounts — a quarter
of a bin left, an eighth left, nothing, an eighth right, a quarter right, wrapping
around at the edges. That is $6 \times 5 = 30$ different pictures of one and the same
curve. Then ask, of each picture, three questions: is there a hump; how tall is it; and
where is it?

The results came back stubborn.

The hump appeared in **all thirty** pictures, with heights ranging from $1.0706$ to
$1.2960$ — never once sinking into the noise floor. Its position was even more
striking. The *bin label* of the tallest bar drifted around as the grid slid, exactly as
it must: if you move the ruler, the numbers written on the ruler move too. But the
*absolute* position — bin label plus the shift you applied — sat at
$0.6482, 0.6484, \ldots, 0.6492$ across all five shifts at the finest resolution. Five
different pictures agreeing on the location of a feature to one part in a thousand.

And yet the experiment's own pre-registered significance test *failed*. The test fitted
a parabola through the tallest bar and its two neighbours, read off the parabola's peak
height, and demanded that it exceed $1.10$. Only $7$ of $30$ cells cleared that bar. On
its own terms, the hypothesis was not confirmed.

So which is it? A robust geometric feature, or a failed test? The honest answer — and
the reason this became a piece of mathematics rather than a footnote — is that *the
phenomenon and the instrument were being confused with each other*. To disentangle
them you need to know what box-averaging actually does to a shape. So let us work that
out.

---

## Everything is one function in disguise

Start with the object itself. The height of a histogram bar is an average: for a bin
running from $a$ to $a+w$, the bar height is

$$\operatorname{avg}(f; a, w) \;=\; \frac{1}{w}\int_{a}^{a+w} f(x)\,dx .$$

A grid is specified by an offset $o$ and a width $w$; its $i$-th bar has height
$B_i(o,w) = \operatorname{avg}(f;\, o + iw,\, w)$ and its $i$-th bin has centre
$c_i(o,w) = o + (i + \tfrac12)w$.

Now the first observation, which sounds trivial and is not. Define the **sliding
average** of $f$ at scale $w$:

$$ (S_w f)(x) \;=\; \frac{1}{w}\int_{x - w/2}^{\,x + w/2} f(s)\,ds . $$

This is a function of a *continuous* variable $x$ — a smoothed copy of $f$, with no
grid anywhere in sight. And then:

> **The Sampling Identity.** For every offset $o$, every width $w$ and every index $i$,
> $$ B_i(o,w) \;=\; (S_w f)\big(c_i(o,w)\big). $$

Every bar of every histogram you can draw is a *sample of one and the same
offset-independent function*. The bin width chooses which smoothed copy of $f$ you are
looking at; the offset chooses only *where along that copy* you place your sampling
points. The offset is not a degree of freedom in the mathematics at all — it is a
choice of where to stand.

That single identity reorganises the whole problem. Thirty histograms are not thirty
statistics; they are six functions, sampled at five sets of points each. Once you see
it, several of the experiment's puzzles dissolve.

**Why labels drift and absolute positions don't.** Shifting the data by $t$ and
shifting the grid by $t$ are *literally the same operation*:
$\operatorname{avg}(f(\cdot + t); a, w) = \operatorname{avg}(f; a+t, w)$, and hence
$B_i(o,w)$ computed on shifted data equals $B_i(o+t,w)$ computed on the original.
Meanwhile the centres move rigidly, $c_i(o+t,w) = c_i(o,w) + t$. So the label of the
winning bin *must* drift under a grid shift, by construction, and the quantity
"label plus shift" *must* be the invariant. The observed $0.6482$–$0.6492$ was not luck;
it was the only thing the geometry permitted, up to the width of a bin.

---

## Three things a histogram cannot do

### It cannot invent a hump

Here is the cleanest result in the whole story, and the one that settles the headline
question.

> **The One-Sided Certificate.** If any bar of any histogram — any width, any offset —
> records a height of at least $c$, then the underlying curve genuinely attains a value
> of at least $c$ somewhere inside that bin.

The proof is a single line of honesty about averages: an average of a continuous
function over an interval never exceeds the function's maximum on that interval, so if
the average is at least $c$, the maximum is too, and a continuous function on a closed
interval attains its maximum.

The consequence is decisive. Binning is a *lossy, one-directional* operation: it can
flatten a spike into invisibility, but it can never manufacture height that the curve
does not have. So the observation "the hump appears in $30/30$ cells, with heights
between $1.0706$ and $1.2960$" is not an artefact *candidate*. There is nothing to
argue about. The curve really does exceed $1.07$ somewhere in the window, in every
single reading. Only the *calibration* of the amplitude — whether $1.07$ is large
compared to what noise alone would produce — remains open.

### It cannot move the amplitude by much

Suppose $f$ is $L$-Lipschitz, meaning $|f(x)-f(y)| \le L|x-y|$: the curve has no
infinitely steep pieces. If $f$ attains its maximum at $x_{s}$ and $x_{s}$ falls in the
bin $[a, a+w]$, then

$$ \big|\operatorname{avg}(f;a,w) - f(x_{s})\big| \;\le\; L\,w. $$

Averaging can only deflate the peak (that is the certificate again), and it cannot
deflate it by more than the curve can fall across one bin's width. The immediate
corollary is what the experiment was groping for:

> **Width Independence of the Raw Maximum.** Given two grids of widths $w_1, w_2$ with
> *arbitrary, unrelated* offsets, each contains a bin whose height is within
> $L(w_1 + w_2)$ of the other's.

So the raw histogram maximum is a genuine estimator of the true peak height, with an
error you can bound from the curve's own steepness. Two analysts using different bin
counts and different alignments are looking at the same number to within $O(Lw)$.

For the canonical smooth hump the bound can be replaced by an exact formula. Take a
parabola $f(s) = c - k(s-x_s)^2$. Its sliding average is

$$ (S_w f)(x) \;=\; c - k\Big[(x - x_{s})^{2} + \tfrac{w^{2}}{12}\Big]. $$

Read that carefully: the parabola is reproduced *verbatim*, with the *same* curvature
and the *same* vertex position, and the only effect of the bin width is to lower the
whole thing by exactly $k w^{2}/12$. The offset does not appear. Two bin widths differ
by exactly $k(w_2^2 - w_1^2)/12$ — a deterministic, computable deflation that you can
correct for, not evidence against a feature. This is the exact form of the phenomenon
the experimenters described informally as "the estimator is stricter than the
phenomenon."

### It cannot move the vertex, either

Amplitude is one thing; position is the more delicate claim, because that is where the
grid-shift knob bites hardest. Two results bracket it.

The general one asks only that the peak be a genuine peak, in the quantitative sense of
a *cone condition*: $f(x) \le f(x_s) - \kappa|x - x_s|$, so the curve falls away at rate
at least $\kappa$ on both sides. Then for **any** offset $o$ and width $w$, any bin that
beats the bin containing the true peak has its centre within

$$ \frac{w}{2} + \frac{L}{\kappa}\,w $$

of $x_s$. The bound makes no mention of $o$ whatsoever. Slide the grid however you like:
the winning bin's *absolute* centre stays inside a fixed window around the true peak
whose size is proportional to the bin width. Refine the bins and the window closes.

The sharp one drops the $O(w)$ slack entirely, at the price of a symmetry hypothesis.
Box averaging turns out to be *shape-preserving* in two specific senses: it preserves
reflection symmetry about a point, and it preserves concavity. A function that is both
symmetric about $x_s$ and concave is unimodal in the strongest sense — its value depends
monotonically on the distance from $x_s$ — and unimodality is inherited by the smoothed
copy. Therefore:

> **Exact Rigid Transport.** If $f$ is symmetric about $x_s$ and concave, then for every
> bin width the sliding average is maximised *exactly* at $x_s$; every bar of every
> histogram is capped by the single number $(S_w f)(x_s)$; and for every offset, the
> winning bar is precisely the one whose centre lies closest to $x_s$.

No slack, no $O(w)$, no dependence on the offset. Under symmetry, the argmax bin is
determined by pure geometry: it is the nearest bin, always. The empirical finding that
"absolute vertex position pins to $0.6482$–$0.6492$ across all five shifts" is exactly
what this predicts, and the tiny residual spread is the residue of the curve's own
asymmetry.

---

## The instrument, indicted

Two of the experiment's three anomalies were now explained as features of the curve. The
remaining two were features of the *test*, and both turned out to be mis-specified. This
is the part of the story that generalises furthest beyond the original data.

**The parabola fit is not conservative.** The pre-registered pipeline fitted a parabola
through three consecutive bars $(y_-, y_0, y_+)$ at spacing $w$ and used its apex as the
amplitude. Write $D = y_- - 2y_0 + y_+$ for the discrete curvature. The apex height is

$$ \hat{y} \;=\; y_0 - \frac{(y_+ - y_-)^2}{8D}, $$

and whenever the fit is genuinely concave ($D < 0$) the subtracted term is *negative*:
$\hat y \ge y_0$, always. The fit can only *raise* the amplitude above the raw bar
height. So a $\ge 1.10$ bar on the fitted amplitude is *strictly easier* to clear than
the same bar on the raw value — which means the observed marginals ($22/30$ raw
maxima above $1.10$, but only $7/30$ fitted peaks) cannot be blamed on the fit shaving
the top off the hump. The gap has to come from *which* bar was being used as the centre
point. Diagnosis, not excuse: the failure was in the pipeline's bar selection, and it
was recorded as a failure of the phenomenon.

**A far-flung vertex is a certificate of degeneracy.** One cell, at $33$ bins, reported
a fitted vertex $0.19$ away from where it should be — while its own tallest bar sat
$0.01$ from the consensus. Alarming, until you compute. The fitted vertex is

$$ \hat{x} \;=\; x_0 + \frac{w\,(y_- - y_+)}{2D}, $$

and if the centre bar dominates its neighbours ($y_\pm \le y_0$) and the fit is concave,
then $|\hat x - x_0| \le w/2$: the apex is always within half a bin. Contrapositively,
*a vertex further away than half a bin proves that $|y_- - y_+| > |D|$* — the neighbour
asymmetry exceeded the curvature. That is the signature of a numerically degenerate
fit, a near-flat three-point cluster where the denominator is small and the apex flies
off. The erratic cell is not evidence that the feature is unstable; it is a certificate
that one particular least-squares division was ill-conditioned.

**The control threshold was the wrong shape.** Finally, three cells breached a control
bar set at $1.02$, at values $1.0215$–$1.0305$ — all three at the finest binnings, $50$,
$66$ and $100$ bins. A mechanical audit rule flagged this as contamination. But a
threshold that does not depend on the number of bins cannot possibly control anything.
If each of $n$ bins independently exceeds a level with probability $p > 0$, then the
probability that *at least one* does is $1 - (1-p)^n$, which tends to $1$ as $n$ grows.
A flat bar is *guaranteed* to be breached, eventually, by refinement alone. The correct
construction is the bin-count-aware bar: use per-bin level $\alpha/n$, and Bernoulli's
inequality gives

$$ 1 - \Big(1 - \frac{\alpha}{n}\Big)^{n} \;\le\; \alpha $$

for all $n$ and all $\alpha \in [0,1]$ — genuine control, at any resolution. With
$\alpha = 0.05$ and $n = 100$ this is the $1.05$ ceiling, and the observed breaches at
$1.0215$–$1.0305$ sit comfortably inside it. They are the expected extremes of a
multinomial count, not contamination.

---

## What honesty looks like

The verdict on the original hypothesis stands: *as operationalised*, it failed, and no
amount of retrospective mathematics changes that. Nothing above is a licence to declare
the bump significant.

What the mathematics does establish is the more valuable thing, which is what the
failure *means*. The hump's existence is certified — binning cannot invent height. Its
amplitude is binning-independent to $O(Lw)$, and exactly $kw^2/12$ deflated for a
parabolic peak. Its location transports rigidly with the grid, exactly so under
symmetry. The three anomalies that looked like instability were, respectively, an
ill-conditioned division, an over-permissive apex estimator, and a threshold with the
wrong asymptotics. The feature at $u^{*} \approx 0.65$ is a stable geometric property of
the curve; what was refuted is one particular recipe for calling it significant.

There is a lesson here that reaches well past this one curve. The folk rule — "vary the
bin width and see if it survives" — is *right*, and now it is right for reasons you can
state. Survival across widths is meaningful because averaging cannot manufacture peaks.
Agreement of absolute positions across offsets is meaningful because box averaging
transports vertices rigidly. And the parts of the pipeline that most people never
question — the smoothing fit, the flat threshold — are precisely the parts that fail
first, because they are the parts with free parameters and no invariance to protect
them.

The natural next step writes itself. If every histogram is a sample of the sliding
average, then stop sampling: test the shape of $S_w f$ directly. There is already a
parameter-free start. For a concave curve, the discrete second difference of three
consecutive bars,

$$ B_{i+1} - 2B_i + B_{i-1} \;\le\; 0, $$

for *every* width and *every* offset, with nothing fitted and nothing to become
degenerate. Curvature sign, read straight off the bars, with no apex to fly away. That
is a shape test which cannot suffer the fate of the $33$-bin cell — and it is where the
next round of this work begins.

The bump, meanwhile, is still there. It has been looked at thirty ways, and it has not
blinked.
