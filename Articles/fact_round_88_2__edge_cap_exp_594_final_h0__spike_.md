# The Cliff You Cannot Measure

## What happens when your data can tell you that something is sharp, but never *how* sharp

There is a particular kind of failure that haunts anyone who fits models to data,
and it is not the failure everyone worries about. The famous failure is
*overfitting*: your model learns the noise, and you fool yourself into believing
a pattern that isn't there. The failure in this story is quieter, more polite,
and in some ways more dangerous. Your model finds something that **is** really
there — and then reports a number for it that is pure fiction.

Here is how it began. A large collection of measurements had been pooled
together: $9594$ events, each recorded as a position somewhere along an interval
that we can normalize to run from $0$ to $1$. Plotted as a histogram, the
positions looked *almost* flat — a broad, featureless plateau — except for one
thing. At the very left edge, the first bin, there was a spike. A pile-up. Far
more events crowded into that first sliver than a flat distribution would allow.

So a natural model suggests itself. Suppose a fraction $1-\rho$ of the events are
scattered uniformly across $[0,1]$, and the remaining fraction $\rho$ belong to a
separate population that hugs the left edge, decaying exponentially away from it.
Write $b$ for the steepness of that decay: the edge population has density
proportional to $e^{-bx}$ on $[0,1]$. Large $b$ means a razor-thin cliff pressed
against zero; small $b$ means a gentle ramp.

Two numbers to estimate: $\rho$, how much mass is in the spike, and $b$, how
steep it is. The first came out cleanly, somewhere around $0.48$. The second
did something strange.

## The parameter that ran away

When the optimizer was allowed to search $b$ up to a ceiling of $40$, it returned
$b = 40.000$ — exactly the ceiling. When the ceiling was raised to $80$, it
returned $b = 40.46$; and a bootstrap resampling gave a confidence interval of
$[15.25,\, 80.0]$, whose upper endpoint was, once again, the ceiling itself.
Twenty-seven percent of the bootstrap replicates pinned themselves against
$80$. At the lower ceiling of $40$, sixty percent did.

In the trade this is called **cap-riding**, and the reflex diagnosis is that
something is broken: a bug, a bad initialization, a flat spot in the numerics.
The reflex remedy is to raise the cap and try again.

The reflex is wrong. The parameter is not running away because the optimizer is
confused. It is running away because *the data cannot see it*, and the model
class knows this even if the analyst does not. What follows is a proof of that
statement — and, in the same breath, a proof that the spike itself is
absolutely, unambiguously real.

## Why steepness disappears

Everything turns on a single observation: a histogram does not record positions.
It records **counts in bins**. And the only thing the leftmost bin — say, the
interval $[0,t]$ for some small width $t$ — can tell you about the spike is *how
much of the spike landed inside it*.

Let us compute that. An exponential law with rate $b$, conditioned to live on
$[0,1]$, puts mass

$$F(b,t) \;=\; \frac{1 - e^{-bt}}{1 - e^{-b}}$$

into $[0,t]$. Mix it with the uniform bulk at weight $\rho$ and the model's
prediction for the edge bin is

$$p(b) \;=\; (1-\rho)\,t \;+\; \rho\,F(b,t).$$

Now watch what this function does. It is **strictly increasing** in $b$ — steeper
spikes really do crowd more mass into the edge bin, and that is a theorem, not
a picture. (It follows from the strict convexity of the exponential function, in
the concrete form $e^{bt} - 1 < t\,(e^{b}-1)$ whenever $0<t<1$ and $b>0$: the
chord of $e^x$ from $0$ to $b$ lies strictly above the curve.)

But it is also **bounded**. As $b \to \infty$ the spike degenerates into a point
mass sitting exactly at zero, all of it inside the edge bin, and the edge
probability climbs to a ceiling

$$P_\infty \;=\; (1-\rho)\,t + \rho,$$

which it never reaches. And here is the crucial quantitative fact — the whole
paper in one line:

$$1 - F(b,t) \;\le\; 2\,e^{-bt} \qquad (b \ge 1,\ t \le 1).$$

The gap between what a spike of steepness $b$ delivers and what an infinitely
steep spike would deliver **shrinks exponentially in $bt$**.

Put a number on it. In the analysis at hand the edge bin had width around
$t \approx 0.036$. At $b=15$, $e^{-bt} \approx 0.58$. At $b=40$, it is $0.24$.
At $b=80$, $0.056$. At $b=200$, $0.0007$. The difference between a spike of
steepness $80$ and a spike of steepness $200$ — which is the difference between
a cliff and an *infinitely sharper* cliff — moves the observable by less than a
tenth of a percent of the bin's content. With ten thousand events, sampling
noise on that bin is roughly one percent. The signal is buried more than an order
of magnitude below the noise, and no amount of clever optimization retrieves it.

## Cap-riding is a theorem

Now we can say precisely why the optimizer behaved as it did.

Suppose you fit by maximum likelihood on the two-cell table "edge bin vs.
everything else". If $h$ is the observed fraction of events in the edge bin, the
per-observation log-likelihood is

$$\ell(h,p) \;=\; h\log p + (1-h)\log(1-p).$$

This is a strictly increasing function of $p$ as long as $p$ stays at or below
$h$ — you always improve the fit by pushing the predicted probability up toward
the observed frequency. Combine that with the two facts above:

> **Theorem (Forced cap-riding).** If the observed edge fraction $h$ is at least
> the ceiling $P_\infty = (1-\rho)t + \rho$, then $b \mapsto \ell(h, p(b))$ is
> strictly increasing on $(0,\infty)$. Consequently, for every cap $B$, the
> constrained maximum-likelihood estimate of $b$ is exactly $B$.

And immediately:

> **Theorem (No finite maximizer).** Under the same condition, for every $b>0$
> there is a $b' > b$ with strictly higher likelihood. The unconstrained
> estimator does not exist.

So the cap-riding is not a bug. It is the *correct* answer to a badly posed
question. The likelihood surface is a monotone ramp in $b$; asking an optimizer
for its maximum on $(0,\infty)$ is asking for the largest real number. It will
hand you back whatever fence you built.

Raising the fence does not help, and we can quantify exactly how much it does
not help:

> **Theorem (Exponentially small cap gains).** All the log-likelihood remaining
> above a cap $b \ge 1$ is bounded:
> $$\ell(h, P_\infty) - \ell\big(h, p(b)\big) \;\le\; C\, e^{-bt}, \qquad
> C = \frac{2\rho}{\min\{(1-\rho)t,\ 1-P_\infty\}}.$$

This is the theoretical shadow of a number that was actually observed: doubling
the cap from $40$ to $80$ improved the model-selection score by $0.05$ units —
against a total model-selection margin of over $100$ units in favour of the
spike existing at all. The cap raise bought essentially nothing, exactly as the
bound predicts.

## What "unidentifiable" really means

At this point one is tempted to declare the steepness *unidentifiable* and move
on. But that word, taken literally, is **false**, and the false version is worth
correcting because the corrected version is what an honest report should say.

The map $b \mapsto p(b)$ is strictly increasing, hence injective. If you knew the
edge probability exactly — to infinite precision, with no noise — you could
invert it and recover $b$ uniquely. Formally:

> **Theorem (Population identification).** If the true edge mass $v$ is bracketed
> by two model values, $p(b_0) \le v \le p(b_1)$ with $0 < b_0 \le b_1$, then
> there is exactly one $b \in [b_0,b_1]$ with $p(b) = v$.

So the population parameter is perfectly well defined. What fails is something
subtler and much more practical, which we might call **tolerance
identifiability**. Real data determine $v$ only up to some tolerance
$\varepsilon$. Ask which values of $b$ are compatible with the observation to
within that tolerance, and the answer is:

> **Theorem (The identified set contains a ray).** Suppose the observed edge mass
> $v$ sits within $\varepsilon$ of the ceiling, $P_\infty - \varepsilon \le v \le
> P_\infty$. Choose any threshold $B_0 \ge 1$ with $2\rho\,e^{-B_0 t} \le
> \varepsilon$ — such a $B_0$ always exists. Then **every** $b \ge B_0$ satisfies
> $|p(b) - v| \le \varepsilon$.

The compatible set is not an interval. It is a half-line $[B_0,\infty)$. There is
no finite upper confidence limit, not because the estimator is poor but because
the geometry forbids one.

The good news is that the *other* end survives intact:

> **Theorem (Lower bounds do survive).** If some $b_1$ undershoots the observation
> by more than the tolerance, $p(b_1) + \varepsilon < v$, then $b_1$ is excluded —
> and by monotonicity so is every $b \le b_1$.

Which is exactly the amendment the original analysis needed. The correct
statement is not "the spike has steepness $40$". It is: *flat bulk plus a
left-edge spike with steepness at least about $15$ — a lower bound only, with no
upper limit supported by the data.* The only hypothesis that can be excluded
anywhere is that the steepness equals the value a single, spike-free law would
have implied (about $1.16$ here). Everything above the threshold is equally
consistent.

## The half you *can* trust

If steepness is invisible, is anything visible? Emphatically yes — and the second
half of the story shows that the *existence* of the spike is identified with a
margin that does not degrade at all as the steepness runs off to infinity.

The tool is an old and beautiful one. Chop $[0,1]$ into three equal bins. A
single truncated exponential with rate $b$ puts mass $r^j/(1+r+r^2)$ into bin
$j$, where $r=e^{-b/3}$. These three numbers form a **geometric progression** —
and geometric progressions are characterized by a single algebraic identity.
Define the *log-convexity defect* of a triple:

$$D(x,y,z) \;=\; xz - y^2.$$

> **Theorem (The single-law family is a zero set).** For every rate whatsoever,
> the three bin probabilities of a truncated exponential satisfy $D = 0$
> identically.

That is remarkable: an entire one-parameter family of models collapses onto a
single algebraic surface. Now compute the defect for the two-component mixture,
weight $\rho$ on the spike:

> **Theorem (Closed form).** The mixture's three-bin defect equals
> $$D \;=\; \frac{\rho(1-\rho)}{3}\cdot\frac{(1-r)^2}{1+r+r^2}\;>\;0.$$
> Moreover, once $r \le 1/2$ (that is, $b \ge 3\log 2 \approx 2.08$),
> $$D \;\ge\; \frac{\rho(1-\rho)}{21},$$
> a bound **independent of the steepness**.

The defect is a fixed distance away from zero no matter how steep the spike gets.
And because $D$ is $4$-Lipschitz in the sup-norm on probability triples, that
algebraic gap converts into a geometric one:

> **Theorem (Uniform single-law exclusion).** For any spike steepness with
> $r\le 1/2$ and *any* single-law rate whatsoever, at least one of the three bin
> probabilities differs by at least $\rho(1-\rho)/84$.

With $\rho \approx 0.48$ that is about $0.003$ — three parts in a thousand of
total probability mass, spread over $9594$ observations, which is many standard
errors. No single exponential can imitate the mixture, ever, at any steepness.
This is the formal content of the observed model-selection margin of roughly
$100$ units, essentially unchanged across every cap tried: the *existence* of the
second component never wavered, even while its steepness was thrashing between
$0.83$ and $40.5$.

And the argument is not an artifact of choosing three bins. With $k$ equal bins,
the single-law weights $r^j(1-r)/(1-r^k)$ are still geometric, so all the defects
still vanish; the mixture's defect equals $\frac{\rho(1-\rho)}{k}\,q_j(1-r)^2$
and is at least $\rho(1-\rho)/(8k)$, giving a separation of $\rho(1-\rho)/(32k)$.
The evidence for a second component degrades only *linearly in the number of
bins* — and never with the steepness.

Sitting alongside this is the mirror-image statement, which explains the numerics
directly:

> **Theorem (The steepness valley).** For any threshold $B \ge 0$ and any two
> steepnesses $b, b' \ge B$, every bin probability of the mixture differs by at
> most $4\rho\,e^{-B/3}$.

Above a modest threshold, all steepnesses look alike. The likelihood surface has
a long flat valley running out to infinity, and the optimizer simply slides down
it until it hits a wall.

## A second ghost: the role swap

One more pathology deserves mention, because it was seen in the data and it is
*exact*, not asymptotic. At the two lowest caps, the fit did something bizarre:
the parameter meant to describe the bulk rode *its own* upper bound near $30$,
behaving as the spike, while the parameter meant to describe the spike settled at
$0.83$ and absorbed the smooth part. The roles had swapped, and the swapped
solution's fit was within about two units of the intended one.

This is not numerical mischief either. Consider a genuine two-component mixture
with steepnesses $b_1, b_2$ and weight $\rho$ on the first. Then

$$\rho\,g(b_1) + (1-\rho)\,g(b_2) \;=\; (1-\rho')\,g(b_2) + \rho'\,g(b_1),
\qquad \rho' = 1-\rho,$$

trivially. Exchanging the two components *together with* the mixing weight leaves
every single observable untouched. So any fitting criterion that reads the model
only through its bin probabilities has, whenever $b_1 \neq b_2$, at least two
distinct global optima. Mixture likelihoods are permutation-symmetric by
construction, and the optimizer is entitled to land in either basin.

## The moral

There is a control experiment in this story, and it is the part that makes
everything else credible. Run the identical pipeline on data where no spike
should exist, and the model-selection score moves the *other* way — a penalty of
$+4.85$ against the two-component model at every cap, with the fitted spike
weight collapsing to $8\times10^{-7}$ and the single fitted rate settling at
$0.08$, indistinguishable from uniform. The machinery is not manufacturing
spikes out of nothing. When there is nothing there, it says so.

Which leaves us with a clean two-part conclusion, and a general lesson worth
carrying elsewhere.

**Identified:** whether the second component exists. Guaranteed by an algebraic
invariant that vanishes identically on the null family and is bounded away from
zero on the alternative, uniformly in every parameter you cannot pin down.

**Unidentified:** how steep that component is. Forbidden by an exponential decay
$e^{-bt}$ in the sensitivity of every observable to the parameter.

Both facts are properties of the *model class and the binning*, not of any
particular algorithm, dataset, or software. And they combine into a single
picture that is worth remembering: the family of models traces out a curve in the
space of observable bin probabilities. Motion *along* that curve dies
exponentially — that is the direction you cannot resolve. Distance *transverse*
to the single-law surface stays bounded below — that is the direction you can.
Identifiability, in this setting, is nothing more than a race between a decay
rate and a transverse margin.

When a fitted parameter rides its cap, the temptation is to raise the cap. The
better move is to ask what the observable actually depends on. Sometimes the
honest answer is a number with a floor and no ceiling — and reporting it that way
is not a weakness of the analysis. It is the result.
