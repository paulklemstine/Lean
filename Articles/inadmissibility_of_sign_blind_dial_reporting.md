# The Missing Bit: Why a Dashboard That Forgets Signs Can Never Tell You What a New Variable Is Worth

## A question every analyst asks

You have a model. It explains some fraction of the variation in whatever you care
about — sales, exam scores, the density of primes in an arithmetic progression, the
failure rate of a machine. That fraction is the familiar number $R^2$, the *variance
share*: how much of the target's wobble your model accounts for.

Now someone hands you a new variable and asks the obvious question: **if I add this,
how much more will I explain?** The answer is a number, the *augmentation increment*
$\Delta R^2$, and it is the quantity on which a great many decisions rest — which
sensor to install, which covariate to collect, which feature to ship.

Here is the situation that makes this article worth writing. Almost every reporting
system in the world — every dashboard, every summary table, every "correlation
matrix heatmap" rendered in shades of blue — presents *variance shares*. It shows
you three numbers:

$$R^2(x,y), \qquad R^2(z,y), \qquad R^2(x,z),$$

where $x$ is your existing predictor (call it the **footprint**), $z$ is the candidate
new **feature**, and $y$ is the **target**. These say: how well the footprint explains
the target, how well the feature explains the target, and how much the feature
overlaps with the footprint.

It feels like enough. It is not. And the failure is not a rounding error or an edge
case — it is total, it is robust, and it has an exact size.

## Squares forget

A variance share is a squared correlation: $R^2(x,y) = \rho_{xy}^2$. Squaring is where
the information dies. A correlation of $+0.6$ and a correlation of $-0.6$ produce the
same reading of $0.36$. The dashboard reports three squares, so it throws away three
signs.

Does that matter? Naively, no: if a feature is negatively correlated with the target
instead of positively, surely it explains just as much. That intuition is correct for
a *single* predictor. It is spectacularly wrong for an *augmentation*, because the
increment does not depend on the three correlations separately — it depends on how
they conspire.

The exact law, which is the backbone of everything that follows, is this. Write
$\rho_{xy}, \rho_{xz}, \rho_{zy}$ for the three signed correlations. Then the
increment in variance share obtained by adding $z$ to a model already containing $x$
is the square of the *partial correlation*:

$$\Delta R^2 \;=\; \frac{(\rho_{zy} - \rho_{xy}\rho_{xz})^2}{1 - \rho_{xz}^2}.$$

Look at the numerator. It is a *difference*. The feature's raw association with the
target, $\rho_{zy}$, minus the part of that association the footprint was already
providing, $\rho_{xy}\rho_{xz}$. Whether these two terms reinforce or cancel is
entirely a matter of sign. Flip the sign of $\rho_{zy}$ and the numerator changes
from a cancellation to a reinforcement — or vice versa — while every reading on the
dashboard stays frozen.

## A concrete pair of worlds

Abstraction is cheap; let us be specific. Take four keys, each drawn with probability
$1/4$. The footprint takes the values $x = (1,2,3,4)$ across them, and the candidate
feature is an indicator, $z = (1,1,0,0)$ — present on the first two keys, absent on
the last two. These are fixed once and for all; only the target varies.

Consider two targets:

$$y_B = (0.7,\; -0.4,\; -0.3,\; 1.0), \qquad y_C = (0.3,\; 0.4,\; -0.7,\; 1.0).$$

Run the numbers. Both targets have exactly the same variance, $0.3725$. Both have
exactly the same covariance with the footprint, $0.125$. Their covariances with the
feature are $-0.05$ and $+0.05$: equal in magnitude, opposite in sign. Consequently
the three dashboard readings are *identical* to the last decimal:

$$R^2(x,y) = \tfrac{5}{149}, \qquad R^2(z,y) = \tfrac{4}{149}, \qquad R^2(x,z) = \tfrac{4}{5}.$$

Two analysts, each looking at one of these two worlds, see the same screen. They see
a feature that on its own explains a measly $2.7\%$ of the target and that is heavily
entangled with the footprint ($80\%$ shared variance) — by every dashboard heuristic,
a feature not worth collecting.

One of them is right. In world $B$, adding the feature improves the model by exactly
**nothing**: $\Delta R^2 = 0$. In world $C$, adding the same feature improves the
model by $80/149 \approx 54\%$ of the target's total variance — it more than
*quintuples* the explanatory power of the model, taking it from $3.4\%$ to $57\%$.

The two analysts have identical evidence and opposite conclusions. This is the
phenomenon of **suppression**: a variable that looks worthless in isolation becomes
decisive once the footprint's contribution is partialled out, and the dashboard is
constitutionally incapable of telling you which case you are in.

The formal statement is an impossibility theorem.

> **Theorem (Inadmissibility of sign-blind reporting).** There is no function $F$ of
> three real arguments such that $\Delta R^2 = F\big(R^2(x,y), R^2(z,y), R^2(x,z)\big)$
> for all finite populations. Indeed, no such function exists even when restricted to
> populations on four keys.

The proof is the pair above: $F$ is fed identical arguments and required to return
both $0$ and $80/149$.

## Not an accident: an open region of failure

A single counterexample invites a natural objection. Algebraic coincidences happen;
perhaps this pair sits on some thin, measure-zero surface in the space of populations,
a curiosity that real data would never approach. If so, the dashboard would be *almost
always* right, which for practical purposes is right.

That escape is closed. The pair above is the base point of a smooth two-parameter
family. Let $e = (1,-1,-1,1)$ — a direction that is centred and orthogonal to the
footprint — and let $\tilde z$ be the feature with the footprint's influence removed.
For parameters $b$ and $u > 0$ define two targets:

$$y_B(b,u) = b\,x + \Big(u + \tfrac{5b^2}{u}\Big)e, \qquad
y_C(b,u) = b\,x + \Big(u - \tfrac{5b^2}{u}\Big)e + 20b\,\tilde z.$$

The design is exact rather than approximate. The coefficient $20b$ is precisely the
amount needed to reverse the sign of the feature–target covariance; the compensating
shift $\pm 5b^2/u$ in the $e$-direction is precisely the amount needed to keep the two
target variances equal. The consequence is that for *every* parameter value the pair
is dashboard-identical: same $R^2(x,y)$, same $R^2(z,y)$, same $R^2(x,z)$, and exactly
opposite signed covariances with the feature. Their increments are $0$ and
$80b^2u^2 / \big(5b^2u^2 + 4(u^2+5b^2)^2\big)$.

At $(b,u) = (1/10, 1/2)$ this reproduces the concrete pair. And on the whole ball of
radius $1/100$ around that point — an honest open set — the gap between the two
increments stays at least $1/3$. The dial readings themselves genuinely vary across
the ball, so this is not one moment configuration wearing different costumes: the
failure occupies a region of positive volume in the space of second moments. A
dashboard is not *usually* right with rare exceptions; it is unreliable on an open
neighbourhood of ordinary-looking data.

## The damage is quantised

So far, a negative. Now the surprise, which is the mathematical heart of the story.
One expects that once a predictor is impossible, the ambiguity is a smear — an
interval of possible true values consistent with a given screen. It isn't. The
ambiguity is a **two-point set**.

Rewrite the increment law in dashboard coordinates. Let $a = R^2(x,y)$,
$c = R^2(z,y)$, $e = R^2(x,z)$ be the three readings, and let

$$P = \rho_{xy}\,\rho_{xz}\,\rho_{zy}$$

be the *correlation triple product*. A short computation turns the partial-correlation
law into

$$\Delta R^2 \;=\; \frac{c + a\,e - 2P}{1 - e}.$$

Everything on the right except $P$ is on the screen. And $P$ is very nearly on the
screen too, because squaring it gives

$$P^2 = a\,c\,e = R^2(x,y)\cdot R^2(z,y)\cdot R^2(x,z).$$

So the dashboard determines $|P|$ *exactly*. The only thing it does not determine is
the **sign of $P$** — a single bit. Not three bits, as the three discarded signs
suggested: flipping any two of the three correlations leaves $P$ alone and leaves the
increment alone, so the real quotient is one bit, the parity of the sign pattern.

From this, rigidity follows at once.

> **Theorem (Ambiguity dichotomy).** Let two finite populations — different key sets,
> different weights, different everything — agree on all three readings. Then either
> they report the *same* increment, or their increments differ by exactly
> $$A \;=\; \frac{4\sqrt{R^2(x,y)\,R^2(z,y)\,R^2(x,z)}}{1 - R^2(x,z)}.$$
> No intermediate disagreement is possible.

The harm sign-blindness does comes in exactly one size, and the screen tells you what
that size is. This is unusually good news dressed as bad news: a dashboard cannot give
you the increment, but it *can* give you a precise error bar, namely $\{t, t+A\}$ for
a computable $t$.

When is the error bar a point? Exactly when $A = 0$, and since the denominator is
always positive (a feature not perfectly collinear with the footprint has
$R^2(x,z) < 1$), that happens precisely when one of the three readings is zero. That
is a nowhere-dense condition: sign-blind reporting is admissible only on a set of
readings with empty interior.

## How much can be hidden?

If the damage has a size, what is the largest it can be? Within the explicit family
the answer is exact and slightly startling. The concealable share — the fraction of
the target's variance that one member attributes to the new feature while its
dashboard twin attributes nothing — is

$$\frac{80b^2u^2}{5b^2u^2 + 4(u^2+5b^2)^2},$$

and over all parameters this has a greatest value of

$$\boxed{\;\frac{16}{17} \approx 94.1\%\;}$$

attained at the irrational parameters $b = 1$, $u = \sqrt 5$. The bound falls out of a
perfect square: the difference between $\tfrac{16}{17}$ and the expression is
proportional to $(u^2 - 5b^2)^2$, which vanishes exactly at $u = \sqrt 5\,b$. So there
exist two four-key populations, indistinguishable on every sign-blind reading, one of
which owes $94\%$ of its target's variance to the new feature while the other owes
$0\%$.

Is there a bound for *arbitrary* populations, not just this family? The formula alone
offers no comfort: as a function of three free numbers in $[0,1)$, the amplitude
$4\sqrt{ace}/(1-e)$ is unbounded — push all three readings towards $1$. But those
readings are not free. A triple of readings that admits *both* signs of $P$ must be
realisable as a genuine correlation structure for both signs, and a correlation matrix
must be positive semidefinite. In dashboard coordinates that requirement reads

$$1 - a - e - c + 2P \ge 0,$$

and this inequality, rather than being imposed as an assumption, is *derived* from a
statement with a clean meaning: no model explains more than all of the variance, i.e.
$R^2(x,y) + \Delta R^2 \le 1$, which is Cauchy–Schwarz applied to the residual and the
partialled feature. Imposing the inequality with the unfavourable sign, and then
applying the arithmetic–geometric mean inequality $a + c \ge 2\sqrt{ac}$, yields the
ceiling.

> **Theorem (Universal ceiling).** For any two finite populations with identical
> dashboard readings and opposite triple-product signs, their increments differ by at
> most
> $$\frac{2\sqrt{R^2(x,z)}}{1 + \sqrt{R^2(x,z)}} \;<\; 1.$$

The maximum misattribution a sign-blind report can cause is governed by one number
only: the collinearity between footprint and feature. If your candidate feature barely
overlaps with what you already have, sign-blindness costs you almost nothing; if it
overlaps heavily, it can cost you nearly everything — but never quite everything.
There is always a strictly positive share of variance that sign-blindness cannot touch.

For the four-key family the collinearity reading is $R^2(x,z) = 4/5$, giving the
ceiling $2\sqrt{4/5}/(1+\sqrt{4/5}) = 4/(2+\sqrt5) \approx 0.9443$, and the family's
peak of $16/17 \approx 0.9412$ sits just beneath it. The explicit construction comes
within three-tenths of a percent of the theoretical limit.

## The repair costs one bit

Every impossibility theorem is only as interesting as the possibility theorem beside
it. Here the two fit together perfectly, because the analysis identified the missing
datum precisely: the sign of $P$. Log that, and everything works. Define

$$G(a, c, e, s) \;=\; \frac{c + a e - 2s\sqrt{a\,e\,c}}{1 - e}, \qquad s \in \{+1,-1\}.$$

> **Theorem (Sufficiency of one bit).** For every finite population,
> $\Delta R^2 = G\big(R^2(x,y),\, R^2(z,y),\, R^2(x,z),\, \operatorname{sign} P\big)$.

Set against the impossibility theorem, this locates the defect exactly: **sign-blind
reporting fails by precisely one bit per augmentation.** Not by an unquantifiable loss
of context, not by an open-ended need for raw data — by one bit.

On the concrete pair, the two worlds feed the repaired formula identical readings and
opposite bits, and it returns $0$ and $80/149$ respectively: correct in both cases.

There is a structural reason the answer is one bit rather than three. The increment is
unchanged when you rescale the target or the feature by any nonzero constant, so it is
really a function on the quotient of moment space by the group of unit changes; the
three signed correlations are coordinates on that quotient. Changing the sign of a
variable acts on those coordinates, and the three variance shares are exactly the
invariants of the *even* part of that action. What survives the quotient is a residual
$\mathbb{Z}/2$ — and that leftover $\mathbb{Z}/2$ is the sign of $P$.

## What to take away

Three lessons, in descending order of abstraction.

**For mathematics.** A sign-blind statistic is an invariant of a group action, and the
question "is this invariant complete?" has a crisp answer computed by identifying what
the action leaves over. Here the leftover is a single $\mathbb{Z}/2$, which is why the
failure is one bit deep, why the ambiguity is a two-point set rather than an interval,
and why the amplitude has a closed form.

**For statistics.** Suppression is not pathology. It lives on open sets in moment
space and it can conceal up to $94\%$ of a target's variance. The standard triple of
variance shares is genuinely, provably insufficient to evaluate a candidate variable,
and the gap has an exact size $4\sqrt{ace}/(1-e)$ that a dashboard can print alongside
its readings.

**For anyone who builds reporting systems.** Store the signed covariances. The cost is
one bit per triple; the benefit is the difference between a report that can certify a
modelling decision and one that provably cannot. And if you must report squares, at
least report the ambiguity amplitude next to them — then a reader knows whether they
are looking at an answer or at a coin flip between two known outcomes.

The next time a dashboard tells you a variable explains $2.7\%$ of the variance and
overlaps $80\%$ with what you already have, remember: that screen is consistent with
the variable being worthless, and it is equally consistent with the variable being the
most valuable thing in your dataset. One bit decides which.
