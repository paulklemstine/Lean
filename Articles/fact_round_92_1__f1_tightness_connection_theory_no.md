# The Bound That Can Never Be Met

## What a search algorithm's "speed limit" really tells you

Imagine you have lost your keys somewhere along a long shelf. You could start at the left end and work right, one section at a time. You could start at the right and work left. You could search in a random order. If you have no idea where the keys are, all three strategies cost you the same on average: you expect to check about half the shelf.

But you are rarely that ignorant. Keys tend to end up near where you set your bag down. Files tend to sit near the front of a directory. Photons tend to arrive early in a detection window. Whenever the thing you are hunting for is *front-loaded* — more likely near the start than the end — searching in the natural order beats searching backwards, and both beat guessing.

The question this article is about is deceptively simple: **how much faster can a well-chosen search order possibly be?** There is a classical-looking answer, an inequality that puts a hard ceiling on the achievable speed-up. And there is a surprising fact about that ceiling, discovered by pinning it against real measured data: the ceiling is *correct*, it is *unimprovable*, and yet **nothing can ever reach it**. Not because our algorithms are bad, but because the very shape of the data that makes speed-up possible in the first place also guarantees a permanent gap.

We can say exactly how big the gap is. On the measured profile the answer is a factor of $1.153$ — the ceiling overshoots the best achievable performance by about $15\%$, with a confidence interval from $10\%$ to $22\%$. And that overshoot is not an artefact of a particular algorithm. It is forced by the data.

---

## The setup: cells, priors, policies

Split the search window into $M$ equal cells, numbered $0, 1, \dots, M-1$. The target sits in cell $i$ with probability $p_i$; the list $p = (p_0, \dots, p_{M-1})$ is what we'll call the **positional profile**. It is a genuine probability distribution: $p_i \ge 0$ and $\sum_i p_i = 1$.

A **policy** is simply an order in which to visit the cells — formally a permutation $\sigma$ that probes cell $i$ at rank $\sigma(i) + 1$. Its expected cost is the average number of probes before you find the target:

$$c(\sigma) \;=\; \sum_{i} (\sigma(i)+1)\, p_i.$$

Three of these costs matter. The **ascending** cost $c_{\mathrm{asc}} = \sum_i (i+1) p_i$ is the cost of scanning left to right. The **descending** cost $c_{\mathrm{desc}} = \sum_i (M - i) p_i$ is the cost of scanning right to left. And the **baseline** $C_0 = (M+1)/2$ is the cost you pay under a flat profile, or equivalently the cost of a random order under any profile.

Everything that follows springs from one embarrassingly simple observation. Add the two directed costs together:

$$c_{\mathrm{asc}} + c_{\mathrm{desc}} \;=\; \sum_i \big[(i+1) + (M-i)\big] p_i \;=\; (M+1)\sum_i p_i \;=\; M+1 \;=\; 2C_0.$$

**The conservation identity.** Forward and backward costs always sum to twice the baseline. Whatever the ascending scan saves relative to a random order, the descending scan loses by exactly the same amount. The two directions are mirror images across the baseline, and there is no profile, however exotic, that escapes this.

The consequence is that the entire geometry of the problem is *one-dimensional*. Fix any one of the three quantities $c_{\mathrm{asc}}$, $c_{\mathrm{desc}}$, $C_0/c_{\mathrm{asc}}$ and the others are determined.

---

## Two parameters, and the ceiling they impose

The speed-up ceiling is written in terms of two shape parameters. The first,

$$\Lambda \;=\; \frac{c_{\mathrm{asc}}}{c_{\mathrm{desc}}},$$

measures how much better forward is than backward. On a front-loaded profile $\Lambda < 1$, and the reciprocal $1/\Lambda$ is exactly the speed-up the ascending scan actually delivers. The second,

$$\Theta \;=\; \frac{c_{\mathrm{asc}}}{C_0},$$

measures alignment against the flat baseline. The master inequality — the "speed limit" — reads

$$S \;\le\; \frac{1}{\Lambda\,\Theta\,\hat q},$$

where $S$ is the achieved speed-up and $\hat q$ is a coverage parameter that equals $1$ when the whole window is scanned. This is a proven theorem, and it is not in dispute. What is in dispute is whether anything can ever sit *on* the line.

Now push the conservation identity through. Since $c_{\mathrm{desc}} = 2C_0 - c_{\mathrm{asc}}$, both parameters are functions of a single number. Defining the **slack factor**

$$X \;=\; \frac{C_0}{c_{\mathrm{asc}}},$$

a two-line computation gives three exact identities:

$$X = \frac{1}{\Theta}, \qquad X = \frac{1+\Lambda}{2\Lambda}, \qquad \Theta = \frac{2\Lambda}{1+\Lambda}.$$

These are exact — no continuum limit, no approximation, no large-$M$ asymptotics. And from them falls the identity that names the whole story:

$$\underbrace{\frac{1}{\Lambda\Theta}}_{\text{the ceiling}} \;=\; X \cdot \underbrace{\frac{1}{\Lambda}}_{\text{best achievable}}.$$

**The slack identity.** The ceiling equals the best realizable speed-up multiplied by $X$. The gap between what the theorem permits and what the world delivers is *exactly one number*, and that number depends only on the shape of the prior — not on the policy, not on the baseline against which speed-up is measured, not on the algorithm.

---

## Why nothing reaches the ceiling

Two facts finish the argument.

**First: the forward scan is optimal.** If the profile is front-loaded — formally, if $p$ is non-increasing, so $p_0 \ge p_1 \ge \cdots$ — then no ordering beats ascending. This is the rearrangement inequality: to minimise $\sum_i (\sigma(i)+1)p_i$ you must pair the biggest probabilities with the smallest ranks, which is precisely what ascending does. So $c_{\mathrm{asc}} \le c(\sigma)$ for every policy $\sigma$, and the best achievable speed-up is $1/\Lambda$. Better still, on a *strictly* decreasing profile the ascending scan is the **unique** minimiser: any other order contains an inversion, and swapping that inversion strictly reduces the cost. There is no tie-breaking ambiguity hiding in the statement.

**Second: front-loading forces $X > 1$ strictly.** This is a strict form of Chebyshev's sum inequality. Consider the doubly-indexed sum

$$\sum_{i}\sum_{j} \big(a_i - a_j\big)\big(p_i - p_j\big), \qquad a_i = i+1.$$

Expanding, it equals $2\big(M \sum_i a_i p_i - (\sum_i a_i)(\sum_i p_i)\big)$ — a pure algebraic identity. When $p$ is non-increasing and $a$ is increasing, every single term $(a_i-a_j)(p_i-p_j)$ is $\le 0$; and if the profile is *not flat*, at least one term is strictly negative. So the whole double sum is strictly negative, which rearranges to

$$c_{\mathrm{asc}} \;<\; C_0 \qquad\Longleftrightarrow\qquad X > 1.$$

Put the two together and you get the punchline.

**Unattainability Theorem.** *For a front-loaded profile that is not flat, every policy $\sigma$ satisfies*
$$S(\sigma) \cdot X \;\le\; \frac{1}{\Lambda\Theta}, \qquad X > 1,$$
*and therefore $S(\sigma) < 1/(\Lambda\Theta)$ strictly. No realizable policy attains the master bound.*

Conversely, $X = 1$ happens **exactly** when $c_{\mathrm{asc}} = C_0$ — for instance on the flat profile, where every ordering is equally good and the speed-up is trivially $1$. The bound is tight precisely in the one case where there is nothing to gain.

---

## The measured data: three independent refutations of flatness

So the whole question of tightness collapses to: *is the measured profile flat?* Three independent statistical tests on the measured positional data say no, emphatically: a Kolmogorov–Smirnov test ($D = 0.095$, $p \approx 7 \times 10^{-76}$), a two-component likelihood-ratio test ($p \approx 9 \times 10^{-10}$) whose fitted spike weight and bulk parameter both have confidence intervals excluding flatness, and a binning-free conditional-logistic likelihood-ratio test ($p \approx 1 \times 10^{-21}$). The refutation is *pool-side*: it is a property of the data, not of any algorithmic choice. So no policy on this data can ever touch the ceiling.

Plugging in the measured shape parameter $\Lambda = 0.765671$ gives

$$\Theta = \frac{2\Lambda}{1+\Lambda} \approx 0.867, \qquad X = \frac{1+\Lambda}{2\Lambda} \approx 1.15302, \qquad S_{\mathrm{asc}} = \frac{1}{\Lambda} \approx 1.306, \qquad \text{ceiling} \approx 1.506.$$

Propagating the reported uncertainty on $\Lambda$ gives $X \in [1.102,\,1.221]$: **the proven bound overshoots every achievable policy by at least $10\%$ and at most $22\%$**.

---

## Is the bound simply wrong, then?

No — and this is the subtlest point in the story. The inequality is **sharp over the class of priors** even though it is attained on none of them.

Take the two-cell family $p_\delta = (\tfrac12 + \delta,\ \tfrac12 - \delta)$ with $0 < \delta < \tfrac12$. It is front-loaded and non-flat, so $X > 1$; but a direct computation gives $c_{\mathrm{asc}} = \tfrac32 - \delta$ and hence

$$X(p_\delta) = \frac{3/2}{3/2 - \delta} \xrightarrow[\delta \to 0]{} 1.$$

So for every $\varepsilon > 0$ there is an admissible non-flat profile with $1 < X < 1+\varepsilon$. The constant in the bound cannot be improved by any uniform factor. Sharpness lives in the *closure* of the class; attainment lives nowhere in it. The right way to pose a tightness question is over the class of priors — never as tightness on a single pool. The naïve version of the question was ill-posed all along.

---

## How much slack, exactly? A dispersion inequality

"$X > 1$" is qualitative. One can do better and give the overshoot a formula in terms of how far the profile is from flat. Write $\|p - \mathrm{flat}\|_1 = \sum_i |p_i - 1/M|$. Then for every front-loaded profile,

$$X \;\ge\; 1 + \frac{\|p - \mathrm{flat}\|_1}{2\,c_{\mathrm{asc}}} \;\ge\; 1 + \frac{\|p - \mathrm{flat}\|_1}{2M},$$

and consequently the master inequality can be *strengthened* to

$$S \cdot \left(1 + \frac{\|p - \mathrm{flat}\|_1}{2\,c_{\mathrm{asc}}}\right) \;\le\; \frac{1}{\Lambda\Theta}.$$

The dispersion functional vanishes exactly on the flat profile — the case rejected by the data. And the constant $1$ in front of the correction is *optimal*: on the two-cell family the sharper inequality is an exact identity, so replacing $1$ by any $c > 1$ produces a counterexample immediately. The extremal profiles are supported on two cells.

---

## Which profiles give which slack

Because $X = C_0/c_{\mathrm{asc}}$ and the ascending cost can be rewritten in terms of the **mean probe position** $E_x = \sum_i \frac{i + 1/2}{M} p_i$ as $c_{\mathrm{asc}} = M E_x + \tfrac12$, we get

$$X \;=\; \frac{M+1}{2M E_x + 1}.$$

Two profiles with the same mean position have the *same* slack, whatever their shape. All shape information beyond the first moment is invisible to $X$. Since $E_x$ ranges over $\big[\tfrac{1}{2M},\, \tfrac{2M-1}{2M}\big]$ — the endpoints attained by point masses on the first and last cell — the slack factor ranges over exactly

$$X \in \left[\frac{M+1}{2M},\ \frac{M+1}{2}\right],$$

both endpoints attained. A perfectly sorted pool has enormous slack; the reverse-sorted pool has slack just below $1$.

Add a realistic constraint and the picture sharpens. Suppose the profile is known to place at least mass $m$ on cells of index $\ge K$ — an "edge mass" floor. Then $E_x \ge (1/2 + Km)/M$, hence

$$X \;\le\; \frac{M+1}{2Km + 2},$$

and the reachable slacks are exactly $\big[\tfrac{M+1}{2M},\ \tfrac{M+1}{2Km+2}\big]$, with the upper endpoint attained by a two-cell profile placing $1-m$ on the first cell and $m$ on cell $K$. Read backwards, this converts a *measured* slack into a hard constraint on the prior: $2Km + 2 \le (M+1)/X$.

---

## Where the shape comes from, and the grid you measure it on

The measured positional profile is harmonic: on a window with dynamic range $r > 1$ the density is proportional to $1/x$, with cumulative distribution $F_r(u) = \log(1 + (r-1)u)/\log r$. Its mean position is

$$E(r) \;=\; \frac{1}{\log r} - \frac{1}{r-1}.$$

That $E(r) < 1/2$ for every $r > 1$ is exactly equivalent to the Padé-type inequality $\log r > \frac{2(r-1)}{r+1}$, provable by a one-line derivative argument. So the continuum slack $X = 1/(2E)$ exceeds $1$ **for every window ratio** — the slack is profile-forced, with no mention of any policy. Moreover $E(r) \to 0$ as $r \to \infty$: *the wider the scan window, the more the bound overshoots*, without limit.

Finally, a reassuring caveat about measurement. The slack is estimated on a finite grid ($27$ cells in the reported measurement), while the underlying profile is continuous. At a fixed mean position $E < 1/2$ the grid slack $X_M(E) = \frac{M+1}{2ME+1}$ is strictly below the continuum value $1/(2E)$, strictly increases with $M$, and converges to it. And when a grid is genuinely refined — cells split rather than the mean held fixed — the coarse mean position exceeds the fine one by exactly $\frac{1}{4M}\sum_j (g_{2j} - g_{2j+1}) \ge 0$ on a front-loaded profile, so the coarse slack is strictly smaller. **Every finite-grid estimate of the slack is a lower bound.** The booked $X = 1.15302$ can be read one-sidedly: the true overshoot is at least that.

---

## The trap: circular tightness

There is a cautionary tale buried in this. Historically, four "anchor" datasets appeared to sit right on the ceiling — apparent evidence of tightness. They do not, and the reason is a purely logical one.

The coverage parameter $\hat q$ is **not identified** by any recorded measurement in this chain. And with $\hat q$ free, the ceiling can be made to equal *anything*: given any $\Lambda, \Theta, S > 0$, the unique $q = 1/(\Lambda\Theta S)$ satisfies $1/(\Lambda\Theta q) = S$ exactly. In particular, reading parameters off at $\Lambda = \Theta = 1$ through $S = 1/\hat q$ reproduces the observation perfectly, *for every observation*. It is a tautology, not a measurement.

All four legacy anchors were built this way — their parameters satisfy $\Lambda\Theta \approx 1.00$–$1.04$ **by construction**, because they were obtained by inverting the very law they were then said to confirm. Their evidential weight for attainment is exactly zero. Anchor tightness is not currently decidable, and will not become decidable until someone produces a raw, non-inverted measurement under a pre-committed protocol.

That is the real lesson, and it generalises far beyond scan policies. A parameter that is fitted by inverting a law can never test that law. The apparent agreement is a mirror.

---

## What would settle it

The theory makes a falsifiable prediction. A joint measurement of speed-up, shape and alignment on the recorded positional data, under the window-ascending policy, should give $S \approx 1.31$ against a ceiling of $1.51$. Observing $S$ meaningfully above $1.51$ would falsify the mapping outright; observing $S$ near $1.31$ confirms it. It is a genuine two-sided test, cheap to run, requiring no new physics.

And the theorem side is settled: the master inequality is true, unimprovable over the class of priors, and unattainable on any front-loaded non-flat pool. The gap is not a defect. It is a measurement — of how far the world's data is from the featureless case where the bound would bite.
