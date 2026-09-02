# The 0.81-Degree Problem: Why Some Experiments Can Never Be Settled by Doing Them Again

## A dial that will not commit

Somewhere in the lifetime of almost every long-running experimental programme there is a number that refuses to resolve. A correlation is supposed to cross a pre-registered threshold. It gets close. It sits, stubbornly, just at the edge. The pooled reading comes back as $0.558$ against a floor of $0.550$ — above the line by eight thousandths, with a bootstrap confidence interval that straddles the floor like a foot on a border. The verdict written into the record is the most honest one available: *approaching, not crossed*.

The natural response is to collect more data. Replicate. Increase the sample. Pool across laboratories. The intuition is deeply ingrained: statistical noise falls like $1/\sqrt{N}$, so with enough $N$ any real effect eventually declares itself.

This article is about a geometric obstruction that makes that intuition fail — not because the effect is small, and not because the noise is large, but because the *two hypotheses themselves are almost the same object*. When they are, a whole class of test statistics — essentially every statistic anyone actually computes — is provably incapable of separating them, by an amount that **does not depend on the sample size at all**. No number of replications changes it. The ceiling is a fact about geometry, not about data.

And, remarkably, the same geometry tells you exactly which test is the best one you *can* run, exactly how much it wins by, and exactly what property you must sacrifice if you want to do better.

## Turning hypotheses into arrows

Here is the translation that starts everything.

A measurement of the kind we are describing compares a *predictor* — a vector $u = (u_1, \dots, u_n)$ of $n$ recorded values — against a *response* $w$, and reports their correlation
$$\operatorname{corr}(u, w) \;=\; \frac{\langle u, w\rangle}{\|u\|\,\|w\|},$$
where $\langle u, w\rangle = \sum_i u_i w_i$ and $\|u\| = \sqrt{\langle u,u\rangle}$. Because this quantity is unchanged when $u$ is rescaled by a positive number, all the information in $u$ that the experiment can see is contained in its *direction*
$$\hat{u} \;=\; \frac{u}{\|u\|},$$
a point on the unit sphere in $n$-dimensional space. The experiment does not measure vectors. It measures points on a sphere.

Now consider the two competing hypotheses at the sticking point. Hypothesis $A$ says: the dial reads $0.558$ — the threshold has been crossed. Hypothesis $B$ says: the dial sits exactly on the floor, $0.550$ — it has not. Each hypothesis is realised by some predictor direction: $\hat{u}$ producing the reading $0.558$ against $w$, and $\hat{v}$ producing $0.550$.

The crucial and slightly unsettling fact is that $\hat u$ and $\hat v$ can be chosen to be *nearly identical*. There exist configurations realising both readings against a common response in which
$$\operatorname{corr}(u, v) \;\ge\; 0.9999.$$

Two arrows correlated at $0.9999$. How far apart is that?

## The chord

The distance between two points on the unit sphere, measured through the interior — the *chordal* distance — has an exact and beautifully simple expression in terms of their correlation. Expanding the square,
$$\|\hat u - \hat v\|^2 \;=\; \|\hat u\|^2 - 2\langle \hat u, \hat v\rangle + \|\hat v\|^2 \;=\; 2 - 2\operatorname{corr}(u,v),$$
because unit vectors have $\|\hat u\| = \|\hat v\| = 1$ and $\langle \hat u, \hat v \rangle$ is precisely the correlation. So

> **Chordal identity.** For nonzero $u, v$, the distance between their directions is $\|\hat u - \hat v\| = \sqrt{2 - 2\operatorname{corr}(u,v)}$. In particular, if $\operatorname{corr}(u,v) \ge 1 - \varepsilon$ then $\|\hat u - \hat v\| \le \sqrt{2\varepsilon}$.

Put in the recorded numbers. Alignment $0.9999$ means $\varepsilon = 10^{-4}$, so the two hypotheses are separated by at most
$$\sqrt{2 \times 10^{-4}} \;=\; \frac{\sqrt 2}{100} \;=\; 0.0141421\ldots$$

There is an angular version too, and it is the one that makes the situation vivid. The angle between two unit vectors is $\arccos c$ where $c$ is their correlation, and a classical inequality of Jordan — $\sin x \ge 2x/\pi$ on $[0, \pi/2]$ — converts chord to angle:
$$\arccos c \;\le\; \frac{\pi}{2}\sqrt{2 - 2c}.$$
For $c = 0.9999$ a direct estimate is even sharper: the angle is $0.0141423$ radians, which is $0.81027$ degrees — strictly less than $0.9^\circ$.

**The entire dispute lives inside a spherical cap of angular radius under nine-tenths of one degree.** Every possible realisation of "crossed" and every possible realisation of "not crossed" is a point inside a patch of sphere smaller than the apparent width of a fingernail held at arm's length.

## A ceiling on every smooth test

Now bring in the test statistic. A test statistic is a function $F$ that eats a direction and returns a number; the experiment "separates the hypotheses" to the extent that $|F(\hat u) - F(\hat v)|$ is large. Almost every statistic in practical use has a *stability* property: nudging the predictor slightly changes the statistic slightly. Formally, $F$ is $L$-Lipschitz on the sphere if
$$|F(x) - F(y)| \;\le\; L\,\|x - y\| \qquad \text{for all unit vectors } x, y.$$
This is the mathematical content of "the statistic is well behaved". A pooled correlation, a regression slope, a smoothed effect size, a likelihood ratio for a smooth model — all satisfy it.

Combining the Lipschitz property with the chordal identity gives an inequality of almost embarrassing simplicity and quite un-embarrassing consequence:

> **Spherical-Cap Power Ceiling.** If $\operatorname{corr}(u,v) \ge 1 - \varepsilon$ and $F$ is $L$-Lipschitz on the sphere, then
> $$|F(\hat u) - F(\hat v)| \;\le\; L\sqrt{2\varepsilon}.$$

Look at what is *not* in that formula. There is no $n$. The dimension of the data — the sample size — has vanished. The bound is the same for two observations and for two billion.

For the recorded configuration, with $L = 1$: any stable statistic normalised to move at most one unit per unit of directional change can separate the crossed and uncrossed hypotheses by at most
$$\frac{\sqrt 2}{100} \;=\; 0.0141.$$
Run the argument backwards and you get the price of decisiveness: a statistic that fully separates the hypotheses — value $1$ under one and $0$ under the other, a clean verdict — must have Lipschitz constant
$$L \;\ge\; \frac{1}{\sqrt2/100} \;=\; 70.71\ldots,$$
so at least $70$. Such a statistic changes its value by $70$ units for every unit of movement on the sphere. It is a hair trigger.

## Replication is powerless

One might hope the ceiling is an artefact of considering a single small experiment. It is not, and the reason is structural.

Model $m$ independent replications of the same experiment by *repeating* the coordinate vectors: form $\operatorname{rep}_m(u)$, the vector of length $mn$ consisting of $m$ copies of $u$. Then $\langle \operatorname{rep}_m u, \operatorname{rep}_m v\rangle = m\langle u, v\rangle$ and $\|\operatorname{rep}_m u\| = \sqrt m \|u\|$, so the factors of $m$ cancel exactly in the ratio:
$$\operatorname{corr}(\operatorname{rep}_m u, \operatorname{rep}_m v) \;=\; \operatorname{corr}(u,v).$$

Correlation is replication-invariant, and therefore so is the chord, and therefore so is the ceiling.

> **Replication does not help.** For every $m \ge 1$ the $m$-fold replicated configuration lives in dimension $2m$, realises the same two readings, and obeys the *identical* ceiling $L\sqrt2/100$.

This is the punchline for the experimentalist. Replicating an ambiguous near-threshold reading does not shrink the ambiguity for any smooth statistic — it reproduces it at larger $n$. The reason the question has not been settled by repetition is not bad luck, insufficient funding, or heterogeneous laboratories. It is that repetition is the wrong operation.

## Is the ceiling real, or just a crude bound?

A bound that is never attained is a bound one should distrust. This one is attained exactly.

Fix any $L \ge 0$ and any pair of directions, and define the *distance statistic*
$$F(x) \;=\; L\,\|x - \hat v\|.$$
The reverse triangle inequality makes $F$ exactly $L$-Lipschitz, and by construction $F(\hat v) = 0$ while $F(\hat u) = L\|\hat u - \hat v\|$. So $|F(\hat u) - F(\hat v)| = L \cdot \|\hat u - \hat v\|$: the ceiling is met, not merely respected. It is the truth about the class, not an artefact of a lossy estimate.

Nor is the class empty of statistics one would actually run. Correlating against a fixed unit response $w$ — the statistic $x \mapsto \operatorname{corr}(x, w)$ — is exactly $1$-Lipschitz on the sphere, by Cauchy–Schwarz. The experiment's own headline number lies inside the constrained class.

## How aligned can the hypotheses be forced to be?

There is a second, dual constraint hiding in the recorded numbers, and it works in the opposite direction.

Since $x \mapsto \operatorname{corr}(x,w)$ is $1$-Lipschitz on the sphere, the *reading gap itself* forces the two directions apart:
$$|\operatorname{corr}(u,w) - \operatorname{corr}(v,w)| \;\le\; \|\hat u - \hat v\|.$$
The recorded gap is $\delta = 0.558 - 0.550 = 0.008$. Hence $\|\hat u - \hat v\| \ge 0.008$, and by the chordal identity, $2 - 2\operatorname{corr}(u,v) \ge \delta^2$, i.e.

> **A recorded margin caps the alignment.** If two predictors differ by $\delta$ in their reading against a common response, then $\operatorname{corr}(u,v) \le 1 - \delta^2/2$.

With $\delta = 0.008$ this gives $\operatorname{corr}(u,v) \le 0.999968$. Combined with the attained configuration at $0.9999$, the alignment of the two hypotheses is pinned inside a narrow window:
$$0.9999 \;\le\; \operatorname{corr}(u,v) \;\le\; 0.999968.$$
The recorded configuration is within $6.8 \times 10^{-5}$ of the geometric optimum. There is essentially nowhere left for the hypotheses to hide, and essentially nothing left to gain by finding a cleverer realisation of them.

## The best test you can run — and how little it buys

So the smooth tests are capped. Which one is the *champion*? This is not an idle question: if the ceiling is $0.0141$ and the test you are running achieves $0.008$, you might reasonably ask whether there is a better test and whether it is worth switching to.

The answer is clean, and it is a statistic a physicist would happily compute. Take the **contrast direction**
$$e \;=\; \frac{\hat u - \hat v}{\|\hat u - \hat v\|},$$
the unit vector pointing from one hypothesis to the other, and correlate against it. Then
$$\operatorname{corr}(\hat u, e) - \operatorname{corr}(\hat v, e) \;=\; \langle \hat u - \hat v, e\rangle \;=\; \frac{\|\hat u - \hat v\|^2}{\|\hat u - \hat v\|} \;=\; \|\hat u - \hat v\|.$$

The contrast test separates the two hypotheses by *exactly* the chordal distance — precisely the Lipschitz ceiling. And since no $1$-Lipschitz statistic can exceed that distance, we have an exact optimum:

> **The smooth optimum is the chord.** The maximum separation achievable by any statistic that is $1$-Lipschitz on the sphere equals $\|\hat u - \hat v\|$, and it is attained by a correlation statistic: correlation against the contrast direction.

Now the accounting for the case at hand. The recorded response correlation separates the hypotheses by exactly $0.008$. The contrast test separates them by the full chord, which the two-sided window pins between $0.008$ and $\sqrt2/100 = 0.0141$. So switching to the optimal smooth test can improve the separation, but by at most a factor
$$\frac{\sqrt2/100}{0.008} \;=\; 1.7678.$$

That is the whole prize on offer for smooth statistics. Not an order of magnitude. Not a decisive verdict. A factor of $1.77$ on an eight-thousandths gap.

## Only one rung fits in the cap

The same geometry limits how many *distinct* claims a stable statistic can make inside the cap. Suppose a ladder of hypotheses $f_0, f_1, \dots, f_k$ is arranged so that a $1$-Lipschitz statistic gains at least $\delta$ at every rung: $F(\hat f_{i+1}) - F(\hat f_i) \ge \delta$. Telescoping, $F(\hat f_k) - F(\hat f_0) \ge k\delta$, while the ceiling says the same difference is at most $\sqrt{2\varepsilon}$ if the endpoints are aligned at $1 - \varepsilon$. Hence
$$k \;\le\; \frac{\sqrt{2\varepsilon}}{\delta}.$$

With $\varepsilon = 10^{-4}$ and $\delta = 0.008$, we get $k \le 1.767\ldots$, so $k \le 1$: **the cap holds at most one resolvable rung**. And exactly one *is* resolvable — the response correlation itself gains the full $0.008$ between the two recorded configurations. The capacity of the cap is not "small"; it is exactly one bit of ladder.

The same argument survives weakening the smoothness hypothesis. If $F$ is merely Hölder with exponent $\alpha$ — $|F(x)-F(y)| \le C\|x-y\|^\alpha$ on the sphere — the ceiling becomes $C(\sqrt{2\varepsilon})^\alpha$, and $\alpha = 1$ recovers the Lipschitz case exactly. Softening continuity to a fractional exponent does not remove the obstruction; it only reshapes the constant.

## The escape hatch, and what it costs

Every impossibility theorem is an invitation to violate its hypothesis, and here the hypothesis is continuity.

Consider the blunt rank-and-threshold statistic: fix a cut $t = 0.554$, halfway between the two readings, and report
$$F(x) \;=\; \begin{cases} 1 & \text{if } \operatorname{corr}(x, w) \ge t,\\ 0 & \text{otherwise.}\end{cases}$$
On exactly the same configuration, $\operatorname{corr}(\hat u, w) = 0.558 \ge t$ and $\operatorname{corr}(\hat v, w) = 0.550 < t$, so this statistic separates the two hypotheses by the maximal possible amount, $1$. Perfect discrimination, inside a cap of radius $0.81^\circ$.

There is no contradiction, because this statistic is not $L$-Lipschitz for *any* $L$: given any candidate constant $L$, one can construct two unit vectors arbitrarily close together that straddle the cut, forcing a jump of $1$ across a distance smaller than $1/L$. The threshold statistic escapes the ceiling by having no ceiling — its local sensitivity is unbounded.

This reframes the entire methodological situation. The choice is not "run a better experiment" versus "run a bigger one". It is:

- **Stable and blind.** Any statistic with bounded sensitivity is guaranteed, forever and regardless of sample size, to see a difference of at most $0.0141$ between the crossed and uncrossed hypotheses.
- **Sharp and brittle.** A discontinuous rank or threshold statistic can separate them completely — but its verdict flips under a perturbation of the predictor smaller than a hundredth of a degree.

The second option is not obviously worse. It is a genuine, concrete, better test to run, and the analysis says exactly what to look for: the deciding statistic must be discontinuous, and it must place its discontinuity inside the cap. What one pays for the escape is *variation*: a statistic that jumps by $1$ across a cap of radius $\sqrt{2\varepsilon}$ has concentrated all of that variation into a region of vanishing size, so its answer is bought with instability rather than with information.

## What the geometry teaches

The lesson generalises well beyond a single stuck dial. Whenever two scientific hypotheses are realised by predictors that are nearly parallel, they are, from the point of view of any stable summary statistic, *the same hypothesis* — and the degree of sameness is quantified exactly by $\sqrt{2 - 2\rho}$ where $\rho$ is their mutual correlation. This quantity is dimension-free, replication-free, and computable before any data are collected.

That last point is the practical one. The alignment $\rho$ between the two hypotheses can be estimated at the *design* stage. If $\rho$ is close to $1$, no amount of subsequent data collection with a smooth statistic will resolve the question, and one may as well know it in advance. Power calculations traditionally ask "how many samples do I need?" The geometry here answers a prior question that no sample size can override: **is my test statistic capable of seeing the difference at all?**

A near-threshold reading that refuses to settle after many replications is not always evidence of a weak effect. Sometimes it is evidence that the two things being compared are separated by less than a degree, and that the instrument being used to compare them cannot resolve a degree — no matter how long one looks.
