# The Fingerprint of a Second Component

## How a "contradiction" in a power law turned out to be a theorem

Somewhere in almost every quantitative science there is a graph that decays. The frequency
of words in a novel, the size of cities, the number of citations a paper collects, the
probability that a randomly chosen integer's smallest prime factor is the $k$-th prime,
the waiting time until a randomized algorithm finds what it is looking for. Plot such a
quantity against rank on log–log paper and you get, astonishingly often, something close to
a straight line. The slope of that line is the *exponent*, and it is the single number
practitioners argue about.

Here is a small drama that plays out constantly and is almost never resolved cleanly.

You measure the exponent two ways. You fit the whole curve and get $1.10$. Then you look
only at the first few points — the "head", the left edge of the plot — and ask what
exponent *those* points would imply on their own. You get something visibly steeper. The
first data cell carries too much mass. The first decile carries too much mass. The ratio of
the first cell to the second is $2.54$, whereas a clean exponent of $1.10$ predicts
$2^{1.10} \approx 2.15$.

Two honest measurements of the same quantity disagree. What do you do?

The usual moves are all bad. You can average them and quote $1.2$-ish, which is a number
that describes nothing. You can call the head "noise" and drop it, which is how real
structure gets thrown away. You can call the bulk fit "contaminated" and trust the edge,
which is how noise gets promoted to structure. Or you can quietly report whichever number
supports the story you already wanted to tell.

This article is about a fifth option: prove a theorem that says the disagreement is not a
contradiction at all, but a *measurement*. Under a precise and mild hypothesis, the gap
between the edge exponent and the bulk exponent is exactly what you should expect to see,
in exactly the direction you saw it. It is the fingerprint left by a second component
hiding inside the first.

---

## The objects

Everything happens inside a very small mathematical world, which is part of the point.

Fix a *truncation* $n$ — the number of cells you actually observed — and consider weights
on the cells $1, 2, \dots, n$. The purest thing you can put there is a **power law with
exponent $a$**:
$$p_a(k) = k^{-a}, \qquad k = 1, 2, \dots, n.$$
Larger $a$ means faster decay: more of the total weight sits near $k=1$.

Now the statistic everyone actually measures. Choose a **head window** $\{1, \dots, m\}$
with $m < n$, and record the fraction of the total weight it carries:
$$M_a(n,m) \;=\; \frac{H_a(m)}{H_a(n)}, \qquad \text{where } H_a(m) = \sum_{k=1}^{m} k^{-a}.$$
This one quantity is a stand-in for every head statistic in practice. Take $m = 1$ and it
is the mass of the top cell. Take $m = n/10$ and it is the first-decile mass. Take a ratio
of two of them and you get a peak-to-end ratio. Every "the edge is too heavy" complaint is
a statement about $M_a(n,m)$.

Finally, the move that creates the drama. Given an observed head mass $v$ on the window
$\{1,\dots,m\}$, the **implied exponent** is the value of $a$ for which $M_a(n,m) = v$. It
is the exponent that window, taken alone, is voting for.

---

## Step one: a single power law cannot equivocate

The first result is the one that makes the drama a genuine paradox rather than sloppiness.

**Monotonicity.** If $a < b$, then $M_a(n,m) < M_b(n,m)$ for every window $1 \le m < n$.
A steeper power law puts strictly more mass on every head window.

This is intuitive and the proof is a two-line cross-multiplication in disguise. What makes
it work is a *monotone likelihood ratio*: for indices $k \le j$ and exponents $a \le b$,
$$p_a(k)\,p_b(j) \;\le\; p_b(k)\,p_a(j),$$
because the ratio $p_b/p_a$ is itself decreasing in $k$. Summing this cross-inequality over
$k$ inside the window and $j$ outside it gives
$H_b(m)H_a(n) \ge H_a(m)H_b(n)$, which is exactly $M_b \ge M_a$, and strictly so when the
exponents differ. (This is the classical fact that a monotone likelihood ratio implies
first-order stochastic dominance, done by hand in a finite discrete setting.)

Because $a \mapsto M_a(n,m)$ is strictly increasing — and continuous, being a ratio of
finite sums of continuous functions — two consequences follow immediately.

**Rigidity.** A single head statistic pins the exponent down: if $M_a(n,m) = M_b(n,m)$ for
one window, then $a = b$.

**Well-posedness.** Any head-mass value strictly between two achievable ones is achieved by
*exactly one* exponent (existence by the intermediate value theorem, uniqueness by strict
monotonicity). So "the implied exponent" is a legitimate, well-defined quantity, not a
figure of speech.

And now the paradox has teeth:

**No single power law fits two windows with different implied exponents.** If a narrow
window implies $a_1$, a wide window implies $a_2$, and $a_1 \ne a_2$, then there is no
exponent $a$ whatsoever with $M_a(n,m_1) = M_{a_1}(n,m_1)$ and
$M_a(n,m_2) = M_{a_2}(n,m_2)$.

So the disagreement is not a fitting artifact you can massage away by choosing a better
estimator. It is a *proof*, from the data, that the underlying weights are not a single
power law. The measurement has told you something true.

---

## Step two: what two components do

The natural repair is to allow two mechanisms rather than one. Let $a < b$ and $0 < w < 1$,
and consider the **bulk × edge mixture**
$$q(k) \;=\; (1-w)\,k^{-a} \;+\; w\,k^{-b}.$$
Think of $k^{-a}$ as the shallow bulk process that governs the body of the distribution, and
$k^{-b}$ as a steeper process that is only significant near the left edge.

To see how this behaves, it helps to measure slope *locally*. Define the **local exponent**
of a positive weight sequence $f$ at index $k$ by
$$E_f(k) \;=\; \frac{\log\!\big(f(k)/f(k+1)\big)}{\log\!\big((k+1)/k\big)}.$$
This is just the slope of the log–log chord between consecutive points. For a pure power
law it returns the exponent exactly: $E_{p_a}(k) = a$ for every $k$.

For the mixture, three facts hold, and together they are the whole picture.

**Every local slope is strictly between the two components.** For all $k \ge 1$,
$$a \;<\; E_q(k) \;<\; b.$$
The mixture is steeper than its own bulk at every single index — never as steep as the edge
component, never as shallow as the bulk.

**The steep component is genuinely an edge phenomenon.** Its local share
$$s(k) \;=\; \frac{w\,k^{-b}}{q(k)} \;=\; \frac{w}{(1-w)\,k^{\,b-a} + w}$$
is strictly decreasing in $k$ and tends to $0$. Whatever the edge component is, it is loud
at $k=1$ and inaudible far out.

**Bulk recovery, with a rate.** Consequently $E_q(k) \to a$; and quantitatively
$$a \;<\; E_q(k) \;\le\; a + \frac{w}{1-w}\,(b-a)\,k^{-(b-a)} .$$
The excess steepness decays at a power rate governed by the *gap* $b-a$ between the two
mechanisms.

The same mediant structure appears at the level of the statistic itself: the mixture's head
mass lies strictly between the two pure head masses,
$$M_a(n,m) \;<\; M_q(n,m) \;<\; M_b(n,m),$$
so by well-posedness every window of a mixture reports an implied exponent strictly inside
$(a,b)$: steeper than the bulk, shallower than the edge. Already this dissolves the naive
version of the paradox. But it does not yet explain the *pattern* — why the narrow window
was the steeper one.

---

## Step three: the window law

Here is the heart of the matter.

**The window law.** Let $q$ be a genuine two-component mixture ($0 < w < 1$, $a < b$). Let
$m_1 < m_2 < n$ be two nested head windows, and let $c_1$ and $c_2$ be the exponents they
imply. Then
$$c_2 \;<\; c_1 .$$
**A narrower window always reports a strictly steeper exponent.**

Not "usually". Not "for reasonable parameters". Always, for every genuine mixture, every
pair of nested windows, every truncation.

Why is it true? Compare the mixture to the single power law $p_c$ that matches it on the
wide window, by looking at the ratio
$$R(k) \;=\; \frac{q(k)}{p_c(k)} \;=\; (1-w)\,k^{\,c-a} + w\,k^{\,c-b}.$$
Substitute $t = \log k$: the ratio becomes $(1-w)e^{(c-a)t} + w e^{(c-b)t}$, a positive
combination of two exponentials. Since $a < b$, the exponents $c-a$ and $c-b$ cannot both
be zero, so this function is **strictly convex in $t$** — a $U$ shape (possibly just one of
its branches). A strictly convex function dips below a horizontal level on a single
interval and is strictly above it on both sides: once it has come back *up* to a level, it
stays strictly above forever after.

Now let $\theta$ be the level at which matching occurs, and consider the signed discrepancy
$$d(k) \;=\; q(k) - \theta\,p_c(k) \;=\; p_c(k)\big(R(k)-\theta\big).$$
By convexity, $d$ is strictly positive before the dip, nonpositive inside it, and strictly
positive after it. Two book-keeping identities then pin everything down: the total of $d$
over $\{1,\dots,n\}$ vanishes (that is exactly what $\theta$ was chosen to arrange), and so
does the total over the wide window $\{1,\dots,m_2\}$ (that is what "matching" means).
Subtracting, the total over the outside $\{m_2+1,\dots,n\}$ vanishes as well — impossible
unless the dip extends past $m_2$, because beyond the dip every term is strictly positive.

So the wide window ends *inside* the dip. Walking backwards from $m_2$ to any narrower
$m_1$, we remove nonpositive terms (or reach the strictly positive stretch that precedes the
dip), so the running total strictly increases: $\sum_{k \le m_1} d(k) > 0$. Unwound, that
says precisely that the matched power law *under-reports* the head mass on every narrower
window. And since head mass is strictly increasing in the exponent, under-reporting means
the narrow window demands a strictly steeper exponent. $\blacksquare$

There is an elegant economy to the argument: the entire law comes from convexity of the
exponential function together with the observation that a zero-sum sequence which is
positive, then nonpositive, then positive must have strictly positive partial sums up to any
index inside the middle stretch. No analysis heavier than that is needed.

---

## Step four: it is falsifiable, and it is not about the number two

A law that always predicts "steeper on the left" is only interesting if it *forbids*
something. It does:

**Diagnostic.** For a genuine bulk × edge mixture, two distinct nested windows can never
report the *same* implied exponent. So if you measure two windows and they agree exactly,
you have certified that your kernel is **not** a two-component mixture of power laws.
The theory can be killed by data.

And the number two is irrelevant. Run the same argument on an arbitrary finite positive
combination
$$k \;\longmapsto\; \sum_{i \in S} w_i\, k^{-e_i}, \qquad w_i > 0,$$
and, provided at least two of the exponents $e_i$ differ, the window-implied exponent is
again strictly antitone in the window width. Strict log-convexity survives summation: as
long as one summand is strictly convex in $\log k$ and the rest are convex, the total is
strictly convex, and every step of the proof goes through unchanged. The two-component case
is recovered as the instance with index set $\{0,1\}$.

So the theorem is not about a fitted model with two knobs. It is about **exponent
heterogeneity as such**. Any decaying kernel assembled from more than one scale of decay
must show a steeper left edge than bulk, no matter how many mechanisms are involved or how
they are weighted.

---

## Step five: how much can you recover?

If a steeper edge is a fingerprint, can it be read?

**The weight is identifiable from one window.** With the two component exponents fixed, the
map $w \mapsto M_q(n,m)$ is strictly increasing on $[0,1]$, hence injective; it is
continuous, and it runs from $M_a(n,m)$ at $w=0$ to $M_b(n,m)$ at $w=1$. So every value in
that range is realized by exactly one weight. A single head statistic determines *how much*
of the second component is present — and then the window law predicts every other window,
so the model is over-determined and therefore testable.

The engine here is one strictly positive determinant,
$$H_b(m)\,H_a(n) - H_a(m)\,H_b(n) \;>\; 0 \qquad (a<b,\; 1 \le m < n),$$
which is the same monotone-likelihood-ratio quantity that started everything.

The other coordinate is honestly open. Monotonicity in the *edge exponent* $b$ does not
follow from these arguments, and for a good reason: raising $b$ makes the edge component
steeper but simultaneously shrinks the total mass it contributes, and the two effects pull
against each other. That is stated here as a question, not smoothed into a claim.

---

## The original numbers

Return to the drama we started with. The bulk fit was $1.104$; the top-cell-to-second-cell
ratio was $2.54$.

For a pure power law, that ratio is exactly $p_a(1)/p_a(2) = 2^{a}$. And
$$2^{1.104} \;<\; 2^{9/8} \;=\; 2 \cdot 2^{1/8} \;<\; 2 \times 1.27 \;=\; 2.54 ,$$
using only that $1.27^8 > 2$. So **no** power law respecting the fitted bulk exponent can
produce the observed peak-to-end ratio. The tension is real, sharp, and arithmetic.

Now the resolution, in closed form. Take the harmonic bulk $a=1$, a quadratic edge $b=2$,
and weight $w = 54/127$. Then $q(1) = 1$ and
$$q(2) \;=\; \frac{73}{127}\cdot\frac12 + \frac{54}{127}\cdot\frac14 \;=\; \frac{50}{127},$$
so the peak-to-end ratio is exactly $127/50 = 2.54$. The same kernel has every local slope
strictly inside $(1,2)$, an edge share decaying to zero, and — by the window law — a strictly
steeper implied exponent on every narrower window. The "contradiction" is reproduced exactly
by a two-component kernel whose bulk is precisely the harmonic law that was fitted.

---

## A twist in the tail: the dial that only looks saturated

One more trap deserves a mention, because it is the same trap wearing a different hat.

Practitioners often need to know whether a statistic has *converged* as the truncation $n$
grows. For head masses, there is a clean dichotomy: as $n \to \infty$ with the window $m$
fixed, $M_a(n,m)$ tends to a strictly positive limit if $a > 1$, and to $0$ if $a \le 1$.
Saturation is a strictly super-harmonic phenomenon.

That sounds decisive until you ask *how fast*. At the harmonic exponent $a = 1$, the head
mass decays like $H(m)/\log n$ — precisely,
$$M_1(n,m)\cdot \log n \;\longrightarrow\; H(m) = \sum_{k \le m} \tfrac1k,$$
with the non-asymptotic guarantee $M_1(n,m) \ge H(m)/(1+\log n)$ for every $n \ge 1$. The
striking way to say it: **squaring the truncation only halves the dial**,
$$\frac{M_1(n^2,m)}{M_1(n,m)} \;\longrightarrow\; \tfrac12 .$$
A quantity that requires you to *square* your sample range before it drops by a factor of
two will look perfectly flat over any range you can actually run. An observed "saturation by
$n = 400$" is therefore fully consistent with a dial whose true limit is zero.

Below the harmonic threshold the collapse is polynomial instead, and comes with an exact
constant. For $0 \le a < 1$, a sum–integral sandwich
$$\frac{(n+1)^{1-a}-1}{1-a} \;\le\; H_a(n) \;\le\; 1 + \frac{n^{1-a}-1}{1-a}$$
gives $H_a(n)/n^{1-a} \to 1/(1-a)$, and hence
$$M_a(n,m)\cdot n^{1-a} \;\longrightarrow\; (1-a)\,H_a(m).$$
The usable calibration: **doubling** the truncation multiplies the dial asymptotically by
$2^{a-1}$. Below harmonic, doubling shrinks it; at harmonic, doubling is asymptotically
neutral; only above harmonic does it stabilize. Two dials recorded at different truncations
can now be put on the same footing across the whole range $a \le 1$, instead of being
compared and silently mis-read.

There is a companion caution about *weighting*. Equal-weight counting is the degenerate
exponent $a = 0$, for which the head mass is exactly $m/n$; and for any genuinely decaying
weight, $M_a(n,m) > m/n$ strictly. An equal-weight dial and a $1/k$-weighted dial are
therefore never directly comparable — a difference between them can be manufactured entirely
by the choice of weighting, with no change in the underlying phenomenon.

---

## Why this matters

The specific numbers here came from one study, but the shape of the situation is universal.
Whenever two windows of the same decaying dataset disagree about an exponent, three things
are now known with certainty:

1. **The disagreement is informative, not erroneous.** No single power law can produce it —
   rigidity forbids it.
2. **The direction of the disagreement is predicted.** If the truth is any heterogeneous
   mixture of decay scales, the narrower window must be the steeper one. Observing the
   opposite direction refutes the mixture explanation outright.
3. **The magnitude is partially decodable.** With the two scales fixed, one window
   determines the mixture weight uniquely, and every remaining window becomes a prediction.

And a fourth, methodological point, which may be the most practically valuable: statistics
that "look converged" over the range you tested may be decaying at $1/\log n$, which is
indistinguishable from flat over any feasible range but has limit zero. The rate theorems
above turn that from a hazard into a correction factor.

The intellectual moral is one that recurs across mathematics. A contradiction between two
measurements is rarely a signal that one measurement is wrong. More often it is a signal
that the model is too small — and if you are lucky, the *pattern* of the contradiction tells
you exactly what is missing. Here the pattern was "narrower is steeper", and the missing
thing was a second scale of decay. The theorem does not merely permit that explanation. It
says that heterogeneity of decay scales always leaves this exact fingerprint, that the
fingerprint points in only one direction, and that if you ever fail to see it, the
explanation is wrong.

That is what a contradiction should be turned into: not an average, not an excuse, but a
mechanism.
