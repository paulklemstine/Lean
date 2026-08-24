# The Margin That Refuses to Shrink

## A story about depth, attention, and a prediction that can fail

Deep networks are stacks. Information enters at the bottom, is transformed layer
by layer, and emerges at the top as a set of scores — *logits* — one per possible
next token. The gap between the score of the winning token and the score of its
closest rival is called the **margin**. It is the network's confidence, measured
in the only units the network has.

Here is a question that sounds like it should have an obvious answer. If you take
the same data, the same tokeniser, the same context window, and train three
models that differ *only* in how many layers they have — four, eight, sixteen —
what happens to the margin?

Almost everyone's first instinct is: it shrinks. A deeper stack has more places
for approximation error to creep in. If depth $d$ multiplies the accumulated
error, surely the usable confidence at the top must fall off like $1/d$.
Quadruple the depth, quarter the margin.

This article is about a mechanism that says the opposite — and, more importantly,
about how to *make that disagreement decidable*. The claim is not "deeper models
are secretly more confident." The claim is sharper and stranger: within the
mechanism, **the margin is exactly the same number at every depth**, and every
bit of the depth-dependence that people observe in practice lives somewhere else
entirely.

---

## Where the depth actually goes

The context for all this is a very concrete engineering question: how much of the
attention pattern can you throw away?

A modern attention layer, for each query, computes a probability distribution
over all $\mathrm{ctx}$ positions in the context and takes a weighted average.
Empirically, that distribution is extremely top-heavy: sort the attention weights
in decreasing order and they fall off like a power law. If you keep only the
top-$k$ positions and discard the rest, you make an error equal to the mass in
the discarded tail. For a scale-free profile with amplitude $A$, that leftover
mass at budget $k$ is
$$\mathrm{tail}(k) \;=\; \frac{A \cdot \mathrm{ctx}}{k}.$$
Keep more, lose less. The question is: how much is enough?

"Enough" has to be defined at the top of the stack, not inside it. A truncation
is acceptable if the answer that comes out is still the same answer — that is, if
the perturbation it injects is smaller than the margin. Two ingredients turn a
per-layer tail into a top-of-stack statement:

- **The depth leg.** Perturbations compose through layers. If each layer is
  Lipschitz and you perturb each of $d$ of them by $\varepsilon$, the output moves
  by at most $d\varepsilon$. Errors *add up along depth*. This is the only place
  where $d$ enters.
- **The read-out leg.** The final logits are a bounded linear read-out of the
  last hidden state, with a constant we may call $L\cdot B$ (Lipschitz constant
  times a bound). A hidden-state perturbation of size $\varepsilon$ moves the
  logit gap by at most a fixed multiple of $L B \varepsilon$.

Put the two together and you get a *criterion*: a budget $k$ is sufficient for a
model of margin $m$ at depth $d$ precisely when the accumulated, read-out-amplified
tail stays under the margin. Solving that inequality gives the smallest sufficient
budget — the **knee** of the accuracy-versus-budget curve:
$$k^*(d,m) \;=\; \frac{4\,L\,B\,A\,d\,\mathrm{ctx}}{m}.$$

Everything in this article follows from that formula. The knee grows *linearly in
depth*, and it is *inversely proportional to the margin*. Deeper stacks need
bigger budgets; confident models tolerate more truncation.

And measurement agrees with the linear growth. Sweeps report a knee that behaves
like
$$k^* \;=\; \frac{d \cdot \mathrm{ctx}}{32}.$$

Here is the pivot. Two things could produce a knee that grows like $d$: error
accumulating over layers, or the margin shrinking with depth. The formula tells
us we cannot have *both* and still land on $d\,\mathrm{ctx}/32$. Set the mechanism
equal to the measurement:
$$\frac{4LBA\,d\,\mathrm{ctx}}{m} \;=\; \frac{d\,\mathrm{ctx}}{32}.$$
The depth cancels. So does the context. What is left is an equation with no free
variables on the left except $m$:
$$m \;=\; 128\,L\,B\,A.$$

**The Pinning Theorem.** *If the budget demanded by the margin channel at depth
$d$ equals the measured knee $d\,\mathrm{ctx}/c$ for a calibration constant
$c > 0$, then the margin is forced: $m = 4\,c\,L\,B\,A$. At the fitted value
$c = 32$ this is $m = 128\,L\,B\,A$ — a number in which the depth does not
appear.*

The measured linear knee has been converted into a statement about margins, and
that statement has no $d$ in it. If you believe the mechanism *and* the measured
knee, you are committed to the margin being the same at four layers, eight, and
sixteen. The linear growth of the budget is entirely the depth leg's doing — pure
error accumulation — with a constant margin riding on top.

---

## Making it fail

A prediction that cannot fail is not worth much, and the Pinning Theorem as
stated cannot fail: it assumes the knee is measured *exactly*. Real sweeps report
a knee on a coarse grid, at a handful of random seeds, with noise. The exact
hypothesis is never available, so the exact conclusion is never testable.

The fix is to redo the algebra with error bars. Say a measurement $K$ is
**within relative tolerance $\eta$** of a reference $y > 0$ if
$|K - y| \le \eta\, y$. Given a measured knee $K$ at depth $d$, invert the
mechanism to get the margin that measurement *implies*:
$$m(d,K) \;=\; \frac{4\,L\,B\,A\,d\,\mathrm{ctx}}{K}.$$

**The Band Theorem.** *Suppose the knee is measured at two depths $d_1, d_2$,
each within relative tolerance $\eta < 1$ of the depth-linear law
$d\,\mathrm{ctx}/c$. Then the ratio of the implied margins satisfies*
$$\frac{1-\eta}{1+\eta} \;\le\; \frac{m(d_1,K_1)}{m(d_2,K_2)} \;\le\; \frac{1+\eta}{1-\eta}.$$

Look at what has disappeared. The depths are gone. The context is gone. The tail
amplitude $A$ — the hardest quantity in the whole story to measure — is gone. The
read-out constant $L\cdot B$ is gone. Only the measurement tolerance survives.
There is not a single free parameter left to fit, which is exactly what you want
from a prediction: nothing to tune after the fact.

Plug in the numbers the protocol asks for. If the knee is measured to
$\eta = 1/21 \approx 4.8\%$, then $(1+\eta)/(1-\eta) = 11/10$, and:

**The Depth-Independence Theorem (the headline).** *A knee measured to within
$\pm 1/21$ of $d\,\mathrm{ctx}/32$ at two depths certifies that the implied
held-out margins agree to within $\pm 10\%$:*
$$0.9 \;\le\; \frac{m(d_1)}{m(d_2)} \;\le\; 1.1.$$
*If the band holds at every depth, it holds at every pair of depths — in
particular across the whole ladder $d = 4, 8, 16$.*

Is $\pm 10\%$ the best you can do from $\pm 4.8\%$ knees? Yes, exactly:

**Sharpness.** *There exist knee measurements inside the $\pm 1/21$ band whose
implied margin ratio is exactly $1.1$.* Take one knee at the bottom of its band
and the other at the top; the ratio lands precisely on the edge. So no argument
using only this hypothesis can promise a narrower window.

---

## The two hypotheses exclude each other

Now the confrontation. The naive expectation says $m(16) = m(4)/4$. The mechanism,
given knees in the band, says $m(16)/m(4) \ge 0.9$. Since $0.25 < 0.9$:

**The Refutation Theorem.** *If the knees at $d = 4$ and $d = 16$ are both
measured inside the $\pm 1/21$ band, the implied margins cannot satisfy
$m(16) = m(4)/4$. The two readings are not competing fits to the same data —
they are logically incompatible.*

That matters for how you interpret a result. A measured ratio near $1/4$ is not a
mild embarrassment for the mechanism to be absorbed by adjusting a constant. It
is a refutation of its premises: it says the linear knee and the margin channel
cannot both be right.

Real measurements are noisy, so the decision rule needs a noise budget. Suppose
the true ratio is $r$ and the harness reports $\hat r = r(1+e)$ with a
multiplicative error of up to $50\%$.

**Threshold Test.** *The rule "accept the mechanism if and only if
$\hat r > 0.45$" is correct on both sides: it accepts whenever the mechanism's
band $r \ge 0.9$ holds, and rejects whenever $r \le 0.275$ — the naive quarter,
generously inflated by $10\%$.* Even with half of everything wrong, the two
hypotheses are separated with room to spare, because they differ by a factor of
nearly four.

---

## Same statement, read as an exponent

Suppose you refuse to commit to either hypothesis and simply fit a power law,
$m(d) = m_1 d^{-\alpha}$. The naive expectation is $\alpha = 1$; the mechanism
says $\alpha = 0$. What does a $\pm 10\%$ flat margin buy you?

The predicted ratio between $d=4$ and $d=16$ is $4^{-\alpha}$, with the prefactor
$m_1$ cancelling. Taking logarithms of the band constraint:

**Exponent Rigidity.** *If the measured ratio $m(16)/m(4)$ lies in $[0.9, 1.1]$
and the margin follows a power law, then*
$$|\alpha| \;\le\; \frac{\log(10/9)}{\log 4} \;\approx\; 0.076.$$
*In particular $\alpha \ne 1$, since $\log(10/9) < \log 4$ by a factor of about
thirteen. And if the margins at $d=4$ and $d=16$ are exactly equal, then
$\alpha = 0$ exactly: the margin is genuinely constant in depth, not merely
slowly varying.*

There is a pleasing symmetry here. You can also read the exponent off the *knee*
side. Under the power-law margin, the knee at depth $d$ carries a factor $d$ from
error accumulation and a factor $d^{\alpha}$ from margin drift, so between $d=4$
and $d=16$:
$$\frac{k^*(16)}{k^*(4)} \;=\; 4^{\,1+\alpha}.$$
Sweeps report a knee ratio of exactly $4$ (say $16 \to 64$). Therefore
$4^{1+\alpha} = 4$, therefore $\alpha = 0$. The depth leg of the mechanism and
the depth-independence of the margin are the very same statement, read from
opposite ends.

That equivalence is worth stating on its own:

**The Equivalence.** *A depth-linear knee $k^* = d\,\mathrm{ctx}/32$ pins the
margin at the depth-free value $128\,L\,B\,A$; conversely, a margin fixed at
$128\,L\,B\,A$ regenerates exactly the knee $d\,\mathrm{ctx}/32$ at every depth
and context. Depth-linear knee $\iff$ depth-free margin.*

---

## The band has a shape

There is a geometric reason the nuisance parameters vanished, and it is worth a
paragraph.

Put the **log-ratio distance** on positive numbers:
$$\rho(x,y) \;=\; \bigl|\log(x/y)\bigr|.$$
This is the Hilbert projective metric on the positive ray. It is blind to common
rescaling: multiply both arguments by the same positive constant and the distance
is unchanged.

Now the map "measured knee $\mapsto$ implied margin" is $K \mapsto 4LBA\,d\,\mathrm{ctx}/K$
— an inversion composed with multiplication by a positive constant. In log-ratio
terms, that is an **isometry**: the distance between two implied margins is
exactly the distance between the two depth-normalised knees $K/d$. The amplitude,
the context and the read-out constant are projective rescalings, so they cannot
survive. Their cancellation was not an algebraic coincidence; it is the geometry.

The metric view also settles a question about error accumulation. The distance
satisfies the triangle inequality, so you *could* bound the $4$-vs-$16$
comparison by chaining through $d=8$ — but that would cost you
$2\log\frac{1+\eta}{1-\eta}$ instead of $\log\frac{1+\eta}{1-\eta}$. Comparing the
two extreme depths *directly* is strictly better. In other words, along the depth
ladder the margin channel does **not** accumulate error. Accumulation is real,
but it lives in the depth leg — the physical composition of layers — not in the
statement about margins.

---

## Can the experiment as usually run even see this?

No. And that is the most immediately useful thing here.

Budget sweeps are typically run on a *dyadic* grid: try $k = 8, 16, 32, 64, 128,
\dots$ and report the first budget that passes. Such a sweep never reports the
true knee; it reports the first grid point at or above it, overshooting by a
factor somewhere in $[1, \rho]$ where $\rho$ is the grid's multiplicative step.

**Grid Resolution Theorem.** *If the true knees obey the depth-linear law exactly
and the sweep reports them on a geometric grid of step $\rho \ge 1$, the implied
margin ratio is confined to $[1/\rho, \rho]$ — and to nothing smaller: one depth
reported exactly and the other overshooting by the full step attains the ratio
$\rho$.*

For a dyadic grid, $\rho = 2$. So a doubling sweep cannot distinguish a perfectly
flat margin from one that drifts by a factor of two. The knee sweep that produced
$k^* = 16, 32, 64$ across the three depths — beautiful as that arithmetic looks —
carries *no information at all* about margin depth-scaling at the precision the
claim asks for.

The remedy is exact and cheap to state:

**Grid Design.** *A geometric sweep certifies the $\pm 10\%$ window if and only
if its step satisfies $\rho \le 11/10$.* Refine the budget grid to $10\%$
multiplicative steps (or interpolate the knee between grid points), and the depth
leg becomes testable.

---

## How many seeds, and which average

Two more practical theorems, both of them about the fact that the reported
statistic is a *median over random seeds*.

First, why a median at all. Consider six runs, all reporting the flat ratio $1$,
one of which crashes and reports a garbage value of $100$. The mean of the
corrupted log is $35/2 = 17.5$, hopelessly outside any acceptance band. The
median is still $1$ — and not by luck: if the genuine values all lie in a band
and strictly fewer than half of the reported runs are corrupted, then *every*
median of the reported log lies in that band. The mean has breakdown point zero;
the median has breakdown point one half. A protocol that reports a mean can be
destroyed by a single hardware fault.

Second, how many seeds. The robustness statement needs $2k < n$: strictly more
than twice as many runs as possible failures.

**Seed Budget.** *With $n$ runs per depth of which at most $k$ are corrupted, the
reported median is certified exactly when $2k < n$. Two seeds per depth are
therefore not enough — with a two-run log, a single crashed run lets an
adversary, or a hardware fault, install **any** value whatsoever as the reported
median. Three seeds tolerate one failure.*

And the verdict itself can be made a computation on the harness output, needing
no reference to a hypothetical uncorrupted log:

**Majority Verdict.** *If strictly more than half of the reported per-run ratios
lie in $[0.9, 1.1]$, then every median of the log lies in $[0.9, 1.1]$. The
strict majority cannot be weakened to a tie: the four-run log $[1, 1, 2, 2]$ has
exactly half its entries in band and admits the out-of-band median $2$.*

---

## Nothing left to assume

Two objections remain, and both dissolve.

*"You assumed the shape of the margin channel."* Hardly. Suppose $K(d,m)$ is any
rule for the budget a truncation criterion demands, and assume only two things:
that scaling a model's margin by $c$ scales the required budget by $1/c$ (the only
dimensionally consistent behaviour for a threshold criterion — a model with twice
the confidence tolerates twice the perturbation), and that the depth leg is linear
(errors add over layers). Then $K(d,m) = d\,K(1,1)/m$, full stop. The entire
functional form is determined; only the single number $K(1,1)$ is empirical. The
prediction is not an artefact of a chosen parametrisation.

*"You assumed the tail exponent."* Also forced, and quantitatively. For a
scale-free tail $A\,\mathrm{ctx}/k^{\beta}$, the knee ratio between $d = 4$ and
$d = 16$ is $4^{1/\beta}$. If the measured ratio is within relative tolerance
$\eta < 1$ of the value $4$, then $|1/\beta - 1| \le \log\!\big(1/(1-\eta)\big)/\log 4$;
at $\eta = 0$ this is exactly $\beta = 1$, and for any $\eta < 1/2$ it excludes
$\beta = 2$ — a quadratic attention tail would have produced a knee ratio of $2$,
not $4$.

Finally, the whole thread collapses into a single dimensionless number. With the
margin pinned, the attention mass discarded at the selected budget is confined to
$[16A, 32A]$, or equivalently $[m/(8LB),\, m/(4LB)]$ — the same window at every
depth and every context of at least $32$. Dividing out:

**The Invariant.** *The attention deficit at the selected budget, measured in
units of $m/(L B)$, lies in $[1/8, 1/4]$.* No depth, no context, no amplitude, no
read-out constant. A single measured pair — the discarded attention mass at the
knee, and the held-out margin — at any one cell of the grid is a complete test of
the mechanism.

---

## What the experiment is now

Start with a folk expectation ("deeper means a proportionally smaller usable
margin"), a mechanism, and a measured curve. End with a protocol you could hand
to an engineer this afternoon:

1. Train at $d = 4, 8, 16$ with everything else held fixed. Use **at least three
   seeds** per depth — two cannot support the claim, whatever the numbers say.
2. Measure the held-out logit margin on the same split. One forward pass per run.
3. Report the **median** ratio $m(16)/m(4)$ — never the mean.
4. Accept if a strict majority of runs land in $[0.9, 1.1]$; reject at $0.45$.
5. If you want to test through the budget sweep instead, refine the grid to
   $10\%$ multiplicative steps. A doubling grid tells you nothing at this
   precision.

The satisfying part is how much of the original question turned out to be
answerable without running a truncation sweep at all. The naive intuition and the
mechanism disagree by a factor of four, and a factor of four survives $50\%$
noise, coarse instruments, and a minority of crashed runs. What was needed was
not a bigger experiment but a sharper statement of what the experiment measures:
turning "the margin is roughly the same" into "the ratio of implied margins is
confined to $[(1-\eta)/(1+\eta), (1+\eta)/(1-\eta)]$, and that window is
attained" is the difference between a hunch and a claim that can be wrong.

Deeper stacks do pay for their depth. But they pay in *budget*, not in
confidence — and if a measurement ever says otherwise, we now know exactly which
number will say it, and exactly how precisely it must be measured to count.
