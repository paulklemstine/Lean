# The Dial That Was Turned Too Far

### How a single exponent, chosen by eye, quietly cost a third of a measurement's power — and what the mathematics says about where it should have been set

---

## A knob nobody fitted

Every experimental science has a moment where somebody writes down a formula that "looks right." A weighting scheme, a kernel width, a decay rate. It is chosen by inspection because it is natural, because it is the first thing that comes to mind, and because the alternatives all seem equally arbitrary. Then it hardens. It gets cited. It becomes *the* covariate, and a hundred later measurements inherit it without ever asking whether the choice was correct.

This is the story of one such knob, what happened when somebody finally turned it, and the mathematics that turns out to sit underneath.

The setting is a family of statistics built out of primes. Suppose you have a large integer $N$, and for each odd prime $\ell$ in some window — say all the odd primes between $3$ and $400$ — you record a single bit: is $N$ a quadratic residue modulo $\ell$, or is it not? Write $c_\ell = 1$ when it is and $c_\ell = 0$ when it is not. This bit is a coarse but real piece of arithmetic information about $N$: it tells you, for that prime, whether $N$ can be a square in the world modulo $\ell$.

One bit per prime is nearly nothing. But a hundred bits, aggregated, is a signal. The natural way to aggregate them is a **weighted count**: pick a weight $w(\ell)$ for each prime and form

$$S \;=\; \sum_{\ell \,:\, c_\ell = 1} w(\ell).$$

The bits are all equally real, so why weight at all? Because the primes are not interchangeable. Small primes carry heavier arithmetic constraints than large ones: knowing $N$'s residue class mod $3$ constrains $N$ far more than knowing its class mod $397$. If you weight everything equally, the hundred large primes drown out the handful of small ones that actually matter. Some downweighting of large $\ell$ is essential.

The obvious downweighting is the **harmonic weight** $w(\ell) = 1/\ell$. It is the weight you write down without thinking. It is the weight that appears everywhere in analytic number theory. It was adopted, by inspection, and it stayed.

The question nobody asked for a long time is: *is the exponent right?*

---

## Turning the knob

Replace $1/\ell$ by $1/\ell^{\alpha}$ and treat $\alpha$ as a dial. At $\alpha = 0$ you get the plain unweighted count of active primes. At $\alpha = 1$ you get the harmonic weight. At $\alpha = 1/2$ you get a square-root weight, downweighting large primes but far more gently. As $\alpha$ grows past $1$, the weight collapses onto the very smallest primes and everything else is ignored.

So the family is

$$S_\alpha \;=\; \sum_{\ell \,:\, c_\ell = 1} \ell^{-\alpha},$$

and the harmonic choice is one point on a continuum.

The way to test a covariate is to ask how much of a response variable it explains. Take a sample of $128$ integers of a fixed size, compute for each the statistic $S_\alpha$, regress an observed log-rate against it, and record the coefficient of determination $R^2$ — the fraction of variance in the response explained by the covariate. Then sweep $\alpha$.

Here is what came out, on a grid from $0$ to $2$:

| $\alpha$ | $0$ | $0.25$ | $\mathbf{0.5}$ | $0.75$ | $1$ | $1.25$ | $1.5$ | $2$ |
|---|---|---|---|---|---|---|---|---|
| $R^2$ | $.3207$ | $.4985$ | $\mathbf{.6242}$ | $.5752$ | $.4731$ | $.3969$ | $.3479$ | $.2944$ |

The curve rises, peaks sharply at $\alpha = 1/2$, and falls. It is *single-peaked*: strictly increasing up to $1/2$, strictly decreasing after. And the harmonic exponent $\alpha = 1$ — the one everybody was using — is not at the peak. It is not even adjacent to it. It sits on the falling limb, beaten by all three of its left-hand neighbours, at $R^2 = .4731$ against the peak's $.6242$.

The gap is $\Delta R^2 = 0.1511$. The pre-registered threshold for calling a refinement real was $0.03$. This clears it by a factor of five. Resampling the data $500$ times, the peak landed at $\alpha = 1/2$ in $492$ replicates and at $\alpha = 3/4$ in the other $8$; the confidence interval for the optimal exponent is the single point $\{1/2\}$, and it excludes $1$ without ambiguity.

Two sanity anchors are worth recording, because they tell you exactly what the original choice got right and what it got wrong. Weighting by $1/\ell$ beats not weighting at all by $0.1524$ — so the instinct that the primes should be weighted was correct. But the *best* weight beats not weighting at all by $0.3035$ — twice as much. The instinct was right; the exponent was wrong, and it was wrong by enough to throw away half of the available gain. Moving from $1/\ell$ to $1/\sqrt{\ell}$ lifts explanatory power from $.473$ to $.624$: a **31% relative improvement, on exactly the same data, with no new measurements at all.**

---

## What the exponent actually does to the primes

To see how large a change this is, look at the two ends of the window. At $\alpha = 1$, the prime $\ell = 400$ at the edge of the window carries weight $1/400$ against $\ell = 3$'s weight of $1/3$ — a relative weight of $3/400$, about one part in $133$. At $\alpha = 1/2$, the same edge prime carries $1/20$ against $1/\sqrt 3$, a relative weight of $\sqrt{3/400} \approx 1/11.5$.

That is the whole erratum in one number: **the square-root weight gives the window-edge prime more than eleven and a half times the relative voice the harmonic weight gave it.** The harmonic instrument was effectively deaf to the top of its own window. It was measuring with primes up to $400$ while listening almost exclusively to primes below $20$.

---

## Why the curve must have a peak

The empirical curve has a peak. Is that an accident of one data set, or is it forced?

It is forced, and the reason is a piece of geometry that lives entirely in the weight family, independent of any data. It has to do with what the dial does at its two extremes.

**At $\alpha = 0$** the statistic is a plain count: how many primes in the window are active. All the structure in *which* primes are active is discarded.

**At $\alpha \to \infty$** something more interesting happens. Let $m$ be the smallest active prime. Every term $\ell^{-\alpha}$ with $\ell > m$ is exponentially smaller than $m^{-\alpha}$, so the sum is squeezed:

$$m^{-\alpha} \;\le\; S_\alpha \;\le\; |\mathrm{supp}| \cdot m^{-\alpha},$$

with $|\mathrm{supp}|$ the number of active primes. The upper and lower bounds differ by a factor that does not depend on $\alpha$ at all, so on the logarithmic scale they merge:

$$\frac{\log S_\alpha}{\alpha} \;\longrightarrow\; -\log m \qquad (\alpha \to \infty),$$

and the error is at most $(\log |\mathrm{supp}|)/\alpha$ — an explicit, quantitative rate.

This is a genuine **tropical limit**, the same dequantization that turns ordinary arithmetic into min-plus arithmetic: sums become minima, products become sums. As the exponent grows, the weighted sum $\sum \ell^{-\alpha}$ dequantizes into the min-plus statistic $\min\{\ell : c_\ell = 1\}$. The dial does not merely "concentrate on small primes" in a vague sense; in the limit it becomes *exactly* the smallest-active-prime statistic, and nothing else.

One can say more, and this is the sharp form. Normalize the covariate by dividing out the global factor $m^{-\alpha}$, giving $\sum_{\ell} (m/\ell)^{\alpha}$. This converges, as $\alpha \to \infty$, to the single **bit** $\mathbb{1}[m \text{ is active}]$. If every active prime other than $m$ is at least $m'$, the convergence is geometric with rate $(m/m')^{\alpha}$ — the collapse is governed by the *spectral gap* of the window, the ratio between its smallest prime and the next one up.

And now the key structural point. The coefficient of determination is blind to rescaling: if you multiply a covariate by any nonzero constant and add any constant, $R^2$ does not change. (This invariance is what makes the whole $\alpha$-sweep legitimate in the first place — $S_\alpha$ shrinks dramatically as $\alpha$ grows, and if $R^2$ noticed magnitude rather than shape, the ranking across exponents would be an artefact.) The global factor $m^{-\alpha}$ is therefore invisible, and the explanatory power of the dial converges to the explanatory power of that single bit:

$$R^2(\alpha) \;\longrightarrow\; R^2\big(\mathbb{1}[m \text{ active}]\big) \qquad (\alpha \to \infty).$$

**One bit.** The whole window — a hundred primes of arithmetic information — is thrown away in the large-$\alpha$ limit, leaving a single indicator.

So the two endpoints of the dial are both information-poor: a count that forgets which primes, and a bit that forgets all but one prime. And now the existence theorem writes itself. The map $\alpha \mapsto R^2(\alpha)$ is continuous. If *some* exponent beats the tropical limiting value, then past some point the tail of the curve is permanently below that exponent's value, so the search can be confined to a compact interval $[0,T]$, where a continuous function attains its maximum. If in addition the unweighted endpoint $\alpha = 0$ is beaten, that maximizer cannot be at $0$ either. Conclusion: **an interior optimum exists.**

The measured single peak at $1/2$ is therefore not a fluke of one sample. Given only that the middle of the dial beats both of its ends — which the data says loudly, by $0.30$ against $\alpha = 0$ and by $0.33$ against $\alpha = 2$ — an interior best exponent *must* exist. The experiment's job was only to locate it.

---

## A one-parameter family with no shortcuts

There is a second structural fact worth knowing, and it is what makes fitting $\alpha$ a well-posed problem rather than a mirage.

For any two exponents $\alpha, \beta$, the Cauchy–Schwarz inequality applied to the vectors $(\ell^{-\alpha/2})$ and $(\ell^{-\beta/2})$ gives

$$S_{(\alpha+\beta)/2}^{\,2} \;\le\; S_\alpha \cdot S_\beta,$$

which says exactly that $\alpha \mapsto \log S_\alpha$ is a **convex** function. More generally, for any $t \in [0,1]$, $S_{t\alpha + (1-t)\beta} \le S_\alpha^{\,t} S_\beta^{\,1-t}$ — the Hölder form of the same statement.

And as soon as the support contains two distinct primes and $\alpha \ne \beta$, the inequality is *strict*. Equality in Cauchy–Schwarz would require the two weight vectors to be proportional, which for two distinct primes $a \ne b$ forces $(\beta - \alpha)(\log a - \log b) = 0$. So distinct exponents never give proportional covariates. Since $R^2$ is invariant under rescaling, this is exactly the identifiability statement: no two settings of the dial are the same measurement in disguise. The dial genuinely has a continuum of distinct positions, and asking which one is best is a real question with a real answer.

The convexity also has a diagnostic reading: the second derivative of $\log S_\alpha$ is the weighted variance of $\log \ell$ across the active primes. The dial's sensitivity to its own exponent is literally the spread of the logarithms of the primes it is listening to. A window with a wide dynamic range is a window where the exponent matters most — which is why the effect here is so large, with $\ell$ ranging over more than two orders of magnitude.

---

## The awkward consequence

Refinements are cheap when they only improve things. This one has teeth.

An earlier line of work had measured a **saturation scale**: extend the prime window outward and, past $B^* = 400$, adding more primes stopped helping. That measurement was made under the harmonic weight, and it is a perfectly good measurement — of the harmonic instrument.

It does not transfer. Here is why, in a form that requires no data at all. Consider the mass a dyadic-type window $[B, 4B)$ contributes at exponent $\alpha$:

$$T_\alpha(B) \;=\; \sum_{B \le \ell < 4B} \ell^{-\alpha}.$$

The window contains $3B$ integers, each of size between $B$ and $4B$, so

$$3 \cdot 4^{-\alpha} \cdot B^{\,1-\alpha} \;\le\; T_\alpha(B) \;\le\; 3\,B^{\,1-\alpha}.$$

The window mass is of *exact* order $B^{1-\alpha}$, pinned between two constants. And that identifies $\alpha = 1$ as the critical exponent. At $\alpha = 1$, the exponent $1 - \alpha$ vanishes and every window carries mass at most $3$, uniformly in $B$: distant windows contribute a bounded amount, no matter how far out you go. That is precisely the analytic reason a finite saturation scale can exist at all.

At $\alpha = 1/2$, the exponent $1-\alpha$ is $+1/2$ and the mass grows like $\sqrt{B}$. Taking $B = n^2$ gives window mass at least $\tfrac{3}{2}n$, which is unbounded. **No uniform bound of the harmonic kind holds for the square-root weight.**

So the saturation scale $B^* = 400$ cannot be reused. Under the harmonic weight, distant primes were a convergent tail that could safely be truncated. Under the square-root weight they are a divergent one. The window has to be re-measured from scratch — and that is not a footnote, it is a research programme, because the new instrument may well have no saturation scale at all in the old sense, only a bias–variance tradeoff at a different location.

---

## The moral

The pleasant part of this story is the number: $+31\%$ explanatory power, extracted from data that had already been collected, by turning a knob that nobody had turned. No new experiment, no new theory, no new primes. Just a parameter that had been fixed by taste rather than by fit.

The less comfortable part is the second-order consequence. A parameter chosen by inspection does not sit alone. Everything measured downstream of it — saturation scales, window locations, thresholds — was measured *through* it, and when the parameter moves, those measurements do not automatically come along. Some of them provably do not, as the divergent window mass at $\alpha = 1/2$ shows.

There is a suggestive coda. Why $1/2$? The value is not arbitrary-looking. Quadratic-residue indicators over primes are the archetypal square-root-cancellation objects: sums of such symbols over $\ell \le B$ are expected to be of size $\sqrt{B}$ rather than $B$, and $\alpha = 1/2$ is exactly the exponent at which the weighted sum sees that scale. The critical exponent for *window mass* is $\alpha = 1$; the critical exponent for *square-root cancellation* is $\alpha = 1/2$; the fit found the latter. Whether that is the explanation or a coincidence is, at present, genuinely open — which is the best possible place for a story like this to end.
