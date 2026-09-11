# How Many More Measurements? Pricing the Cost of Watching a Curve Settle Down

## A staircase that never quite stops

Imagine a quantity that improves in ever-smaller jumps. A learning curve whose
accuracy climbs and then flattens. A cooling body whose temperature slides
towards the ambient. A sequence of engineering revisions, each one buying less
than the last. A benchmark score that creeps down as a model is scaled up.

In all of these there is a sequence of readings

$$s_0 \ \ge\ s_1 \ \ge\ s_2 \ \ge\ \cdots$$

which we will call a **fade**, and there is a number everyone actually wants: the
**plateau**

$$L \ = \ \lim_{n\to\infty} s_n,$$

the value the process is heading towards. The uncomfortable fact is that you can
never measure $L$. You can only measure finitely many *rungs* $s_0, s_1, \dots,
s_{m+1}$ of the ladder, and the plateau lives at infinity.

So the practical question is not "what is $L$?" but the far more useful

> **Given the rungs I have already climbed, how narrow is the range of plateaus
> still consistent with my data — and how many more rungs must I measure to
> narrow it to a target precision?**

This article is about a complete answer to that question. It turns out that the
answer is exact, short, and slightly surprising: **only your last measured step
matters**, the range of admissible plateaus shrinks by a fixed factor per rung
in the worst case, and there is a closed formula for the number of rungs you
must buy. It also turns out that the formula has a hard limit that no
experimenter can cross, and — in the one real dataset we apply it to — the
formula says that the extra measurements everybody assumed were necessary are
in fact worthless.

## The one assumption: the steps decelerate

Nothing can be said about the plateau of an arbitrary decreasing sequence. If the
steps $d_n = s_n - s_{n+1}$ are allowed to be anything nonnegative, the sequence
$1, \tfrac12, \tfrac13, \tfrac14, \dots$ (which converges) and the sequence
$1, \tfrac12, \tfrac13 + \tfrac14, \dots$ (which does not) look identical for as
many rungs as you care to measure.

So we assume the one thing that experimentalists routinely certify: the steps
**decelerate at a certified rate**. Fix a ratio $r$ with $0 \le r < 1$. Call a
fade **$r$-admissible** if

$$s_{n+1} \le s_n \quad\text{and}\quad d_{n+1} \le r\, d_n \quad\text{for every } n,
\qquad d_n := s_n - s_{n+1}.$$

Each step is at most $r$ times the previous one. That single inequality is
enough. It forces convergence — the remaining drop after rung $n$ is at most
$d_n(r + r^2 + r^3 + \cdots) = r\,d_n/(1-r)$ — and it is exactly the leverage we
need to pin down $L$.

## The main theorem: only the last step matters

Suppose you have measured a prefix of rungs $p_0, p_1, \dots, p_{m+1}$, and that
this prefix is itself consistent with the deceleration rule. Write

$$d_m = p_m - p_{m+1}$$

for the **last measured step**. Which plateaus $L$ are still possible? That is,
for which $L$ does there exist an $r$-admissible fade that agrees with your data
on every measured rung and tends to $L$?

> **Theorem (Exact identifiability from a measured prefix).** The set of
> admissible plateaus is *exactly* the closed interval
> $$\Big[\,p_{m+1} - \frac{r\,d_m}{1-r}\ ,\ \ p_{m+1}\,\Big].$$
> Both endpoints are attained. Its length is
> $$\Lambda_m \ = \ \frac{r\,d_m}{1-r}.$$

Two halves, each easy to see once stated.

*Nothing above $p_{m+1}$, nothing below the interval.* A fade is decreasing, so
its limit cannot exceed any value it has already passed: $L \le p_{m+1}$. And the
remaining drop after rung $m+1$ is at most $d_{m+1} + d_{m+2} + \cdots \le d_{m+1}
(1 + r + r^2 + \cdots) = d_{m+1}/(1-r)$, while the deceleration rule caps the
first unmeasured step at $d_{m+1} \le r\,d_m$. Together: $p_{m+1} - L \le
r\,d_m/(1-r)$.

*Everything in between actually happens.* Given any target $L$ in that interval,
splice a purely geometric tail onto your data: keep $s_n = p_n$ for $n \le m+1$,
and then set
$$s_n \ = \ L + (p_{m+1} - L)\,q^{\,n - (m+1)}, \qquad n > m+1,$$
for a suitable tail ratio $q \in [0, r]$. This tail is automatically admissible
(its steps shrink by exactly $q \le r$), it converges to $L$, and the only thing
to check is the *junction*: the first tail step is $(p_{m+1}-L)(1-q)$, and it must
be at most $r\,d_m$. That is precisely the condition defining the interval. Take
$q = r$ for the bottom endpoint and $q = 0$ — a fade that simply stops — for the
top.

The striking part is the phrase **only the last step matters**. All the
information in $p_0, \dots, p_{m-1}$ is discarded; the width of your uncertainty
about the plateau is determined by two numbers alone, the last measured step
$d_m$ and the certified ratio $r$. And note the asymmetry: the *upper* end of the
window is your last reading itself, and no amount of further measurement will
ever push it down faster than the readings themselves fall. Extra rungs improve
only the lower edge.

## Each rung buys a factor of $r$ — in the worst case

Now the question the whole enterprise was built for: what does one more
measurement buy?

Consider the extremal ladder, the one that decelerates exactly at the certified
rate: $d_n = d_0 r^n$, i.e.
$$p_n \ = \ s_0 - d_0\,\frac{1-r^{\,n}}{1-r}.$$
For this ladder the admissible-plateau interval after $m$ further rungs has
length
$$\Lambda_m \ = \ \frac{d_0\, r^{\,m+1}}{1-r},$$
so that
$$\Lambda_{m+1} \ = \ r\,\Lambda_m .$$

**Each extra rung contracts the window by exactly the factor $r$.** The
conjecture that motivated this work is therefore true — on the worst-case
ladder.

It is *not* a universal law, and the deviation always goes in the experimenter's
favour:

> **Theorem (Contraction bound, and its non-exactness).** For any admissible
> prefix, $\Lambda_{m+1} \le r\,\Lambda_m$. But there are admissible prefixes on
> which one extra rung collapses the window to a *single point*.

The counterexample is disarmingly simple. Measure $p_0 = d_0 > 0$, then $p_1 = 0$,
then $p_2 = 0$. The last measured step is now $d_1 = 0$, so the window has length
$r \cdot 0/(1-r) = 0$: the fade has demonstrably stopped, and the plateau is
known exactly. One rung took a window of positive length to nothing. So $r$ per
rung is a guarantee, not a prediction — you may get lucky, never unlucky.

## The stopping rule

Put the pieces together and you get an experimental plan with a price tag. You
want the plateau to within $\varepsilon$. You know $d_0$ and $r$. How many further
rungs $m$?

You need $d_0 r^{m+1}/(1-r) \le \varepsilon$. Taking logarithms (and remembering
that $\log r < 0$ flips the inequality) gives the clean criterion:

> **Theorem (Rung budget).** For $d_0 > 0$, $0 < r < 1$ and $\varepsilon > 0$,
> measuring $m$ further rungs identifies the plateau to within $\varepsilon$ **if
> and only if**
> $$m \ \ge\ \Big\lceil \frac{\log\!\big(\varepsilon (1-r)/d_0\big)}{\log r} \Big\rceil - 1 .$$

That right-hand side is the **rung budget**. It converts the vague managerial
instruction "measure more rungs" into a number, computable before a single new
measurement is taken.

## The other branch: when no ladder will ever do

What if you have no genuine deceleration certificate — only the trivial
observation that the steps are non-increasing, i.e. $r = 1$?

> **Theorem (The impossible branch).** If the only certified bound is $r = 1$ and
> the last measured step is positive, then the set of admissible plateaus is the
> entire half-line $(-\infty,\, p_{m+1}]$, for *every* prefix length.

Every value below your last reading remains possible, forever. The construction
is again a spliced geometric tail, but now the tail ratio $q$ may be taken as
close to $1$ as you like, and a tail with ratio near $1$ can travel arbitrarily
far before settling.

So the dichotomy of the whole programme is a theorem, not a slogan:
**with a certified ratio $r < 1$, plateau identification is cheap and explicitly
costed; with $r = 1$, it is impossible at any price.** The value of an experiment
is not in its length but in the certificate it comes with.

This has a quantitative echo. The window width is proportional to
$r/(1-r)$, a function that explodes as $r \to 1$: at $r = 0.5$ it equals $1$, at
$r = 0.9$ it equals $9$, at $r = 0.99$ it equals $99$. Sharpening your ratio
certificate from $r'$ down to $r$ shrinks the admissible set *monotonically* —
every fade admissible for the sharper ratio is admissible for the weaker one. In
the weak-certificate regime, one better certificate beats any number of rungs.
Halving $r$ from $0.98$ to $0.49$ buys you a factor of $50$; buying that factor
with rungs at $r = 0.98$ would take nearly $200$ measurements.

## The floor that no ladder can cross

Everything above assumed the rung values were known exactly. Real rungs come with
error bars. Suppose each measured value is known only to within $\eta$. Then the
admissible plateau set must be enlarged: a fade counts as consistent if it passes
within $\eta$ of every reading.

> **Theorem (Noise floor).** If the rung readings carry uncertainty $\eta$, then
> for **every** prefix length the admissible plateau set contains both
> $p_{m+1} + \eta$ and $p_{m+1} - \eta$. Hence it always contains two points at
> distance $2\eta$, no matter how many rungs are measured.

The proof is a shrug made rigorous: shift the *entire* measured prefix rigidly up
by $\eta$, or rigidly down by $\eta$. A rigid shift changes no step, so it
violates no deceleration constraint; then freeze the tail (take the constant
continuation, tail ratio $q = 0$) and the plateau sits exactly at the shifted last
value. Both shifted ladders are consistent with the data.

This is the real stopping rule. The geometric contraction $d_0
r^{m+1}/(1-r)$ marches towards zero, but the noise floor $2\eta$ does not move.
Measuring past the point where the geometric window has shrunk to the size of
your error bars is provably wasted effort. **A ladder is rung-limited only until
it becomes noise-limited.**

## A real dataset, and a refuted estimate

The programme that prompted all of this had a concrete ladder. Its measured
first step was $d_0 = 0.0259$, its certified deceleration ratio was $r = 1/2$, and
the target precision was the half-width of the reported confidence interval
$[0.445,\,0.534]$ around the reading $0.488$ — that is,
$$\varepsilon \ = \ \tfrac12(0.534 - 0.445) \ = \ 0.0445 .$$
The working estimate had been that **three** further rungs would be needed.

Run the formula. The one-rung window already has length
$$\frac{d_0\,r}{1-r} \ = \ 0.0259 \times \frac{0.5}{0.5} \ = \ 0.0259 \ < \ 0.0445 .$$
And the budget itself,
$$\Big\lceil \frac{\log(0.0445 \times 0.5 / 0.0259)}{\log(1/2)} \Big\rceil - 1
= \Big\lceil \frac{\log(445/518)}{\log(1/2)} \Big\rceil - 1
= \lceil 0.219 \rceil - 1 = 0,$$
is **zero**. At the confidence-interval scale, the plateau is already identified.
Three further rungs are not needed; not one is needed. The estimate was wrong by
three rungs and an argument.

If you want a genuinely informative target — say $\varepsilon = 0.001$, an order of
magnitude below the confidence interval — the formula prices it honestly. The
window after $m$ rungs is $0.0259 \cdot 2^{-m}$; at $m = 4$ it is $0.00162 >
0.001$, and at $m = 5$ it is $0.00081 \le 0.001$. **Exactly five further rungs**,
no fewer.

And now the noise floor bites. The uncertainty on each rung reading is itself the
confidence-interval half-width $\eta = 0.0445$, so the floor is $2\eta = 0.089$ —
more than three times the one-rung window $0.0259$. The five-rung plan for
$\varepsilon = 0.001$ is therefore unbuyable at the current measurement precision:
those five rungs would each be measured to $\pm 0.0445$, and the resulting
window could never fall below $0.089$. The verdict is unambiguous:
**this ladder is noise-limited, not rung-limited.** The correct next experiment
is not more rungs; it is more precise rungs, or a sharper deceleration
certificate.

## Squeezing from below

One last refinement, because it changes the shape of the answer. All of the above
uses a *one-sided* certificate: the steps shrink at least as fast as $r$. Suppose
the experiment can also certify that the fade does not stop abruptly — a *lower*
ratio $r_{\min}$ with $r_{\min} d_n \le d_{n+1}$.

> **Theorem (Two-sided identification).** With ratios certified in
> $[r_{\min}, r_{\max}] \subseteq [0,1)$, the admissible plateaus after the prefix
> are exactly
> $$\Big[\,p_{m+1} - \frac{r_{\max} d_m}{1-r_{\max}}\ ,\ \ p_{m+1} - \frac{r_{\min} d_m}{1-r_{\min}}\,\Big],$$
> an interval of length
> $$\frac{d_m\,(r_{\max}-r_{\min})}{(1-r_{\max})(1-r_{\min})},$$
> strictly shorter than the one-sided width $r_{\max} d_m/(1-r_{\max})$ whenever
> $r_{\min} > 0$.

The interval is no longer anchored at your last reading: knowing that the fade
keeps fading pushes the plateau strictly below $p_{m+1}$. Both endpoints are
realised by pure geometric tails, of ratio $r_{\max}$ and $r_{\min}$ respectively;
interior points by intermediate ratios.

For the real ladder, certifying ratios in $[0.4,\, 0.5]$ instead of just
"$\le 0.5$" shrinks the window from $0.0259$ to
$$\frac{0.0259 \times 0.1}{0.5 \times 0.6} \ = \ \frac{0.0259}{3} \ \approx \ 0.0086,$$
a factor of three, and again without measuring a single further rung. The
per-rung contraction factor is now itself only bracketed, between $r_{\min}$ and
$r_{\max}$ — you no longer know exactly how fast your window shrinks, only that
it does.

## What this is really about

The mathematics here is elementary: geometric series, a splicing construction,
and a ceiling function. What is not elementary is the reframing.

The usual instinct when a curve has not obviously flattened is to take more
data. This says: before you do, compute. Your uncertainty about the plateau is
exactly $r\,d_m/(1-r)$, an explicit number you already possess. Compare it to your
target. Compare it to your noise floor $2\eta$. Only if the first exceeds the
second and both exceed the target does another rung buy you anything, and then
you know exactly how many rungs to buy: $\lceil \log(\varepsilon(1-r)/d_0)/\log r
\rceil - 1$.

Three lessons generalise well beyond any particular ladder:

1. **The certificate is the currency.** The whole edifice rests on $r$, and
   $r/(1-r)$ is brutally sensitive near $1$. Effort spent tightening the
   deceleration bound dominates effort spent extending the ladder.
2. **Information saturates.** History is discarded — only the last step matters —
   and measurement noise imposes a floor $2\eta$ that no length of ladder can
   cross.
3. **"Measure more" is a decision, not a reflex.** With a closed-form budget it
   becomes a line item, with a cost, a benefit, and — sometimes, as here — a
   provable answer of zero.
