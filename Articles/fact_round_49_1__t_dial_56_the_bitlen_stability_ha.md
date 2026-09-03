# The Dial That Wasn't Broken

## How a cubic inequality overturned the diagnosis of a failing experiment

### A number that looked like a verdict

Somewhere in the machinery of a large computational number-theory experiment sits a small, unglamorous object called a *dial*. A dial is a cheap statistic you can compute about an integer $N$ — call it $T(N)$ — that is supposed to predict something expensive: the *smooth-hit rate* of a sieve run on $N$, the fraction of trial values that factor completely over a fixed small set of primes. If $T$ is a good dial, the moduli it ranks highest really are the ones the sieve likes best, and you can spend your computer time where it pays.

The way you grade a dial is with **Spearman's rank correlation**. Forget the actual numbers; keep only the ordering. Sort the $n$ sampled moduli by $T$, sort them again by measured rate, and ask how well the two orderings agree. A coefficient of $\rho = 1$ means perfect agreement, $\rho = 0$ means the dial is telling you nothing. In this project a dial was considered healthy if $\rho$ landed in the band $[0.55,\, 0.85]$ — good enough to be useful, not so good that you suspect you have accidentally recomputed the answer.

At bit length 48, 50, 52, the dial behaved. Then the experiment was pushed to bit length 56, with $n = 1200$ sampled moduli, and the number came back:

$$\rho = 0.405.$$

Below the band. The dial had failed.

And there was, sitting right there in the log file, an obvious culprit. At bit length 56 the sieve is *starved*: the mean smooth rate has collapsed to $0.89\%$, and **194 of the 1200 moduli recorded zero hits at all**. Zero hits means the measured rate for all 194 of them is literally the same number — zero. In rank terms they form a single enormous **tie block**: 194 moduli that the measurement simply cannot tell apart. The recorded explanation wrote itself: *the starved regime destroys rank resolution*. Of course the correlation collapsed; a sixth of the sample has been flattened into a single indistinguishable lump.

It is a satisfying story. It is also, as it turns out, arithmetically impossible.

### What a tie block actually costs

Here is the question nobody had asked: *how much* correlation can a tie block destroy? Not qualitatively — quantitatively. Given that 194 out of 1200 responses are tied, what is the highest score any dial in the universe could still achieve?

That question has an exact answer, and getting it takes two ideas.

**Idea one: ties make part of your predictor invisible.** Suppose the response $Y$ is constant on each block of some partition of the sample. Then $Y$ cannot see any variation of the predictor *inside* a block. Split the predictor $X$ into its block averages $\mathbb{E}[X\mid b]$ — the coarse, blockwise picture — plus a residual $X - \mathbb{E}[X\mid b]$ that records everything happening inside blocks. The residual is orthogonal to every function of the block label, which is exactly the classical **law of total variance**:

$$\operatorname{Var}X = \operatorname{Var}\big(\mathbb{E}[X\mid b]\big) + W, \qquad W = \sum_i \big(X_i - \mathbb{E}[X\mid b]_i\big)^2 .$$

The quantity $W$ is the *within-block sum of squares*, and against a blockwise-constant response it is dead weight. Cauchy–Schwarz on the surviving part gives the **Tie-Block Ceiling**:

$$\operatorname{Cov}(X, Y)^2 \le \big(\operatorname{Var}X - W\big)\cdot \operatorname{Var}Y, \qquad\text{equivalently}\qquad \rho(X,Y)^2 \le 1 - \frac{W}{\operatorname{Var}X}.$$

You are penalised, exactly and only, for the resolution the measurement threw away.

**Idea two: rank vectors cannot huddle.** So how big is $W$ for a *rank* vector? A rank vector is special: it takes distinct integer values. And $m$ distinct integers cannot be crowded together — the tightest they can possibly be packed is consecutively. Compute the spread of $m$ consecutive integers about their mean and you get exactly

$$\frac{m^3 - m}{12}.$$

That is the **Discrete Spread Bound**: any $m$ distinct integers have squared spread at least $(m^3-m)/12$, with equality precisely for a consecutive run. It is a discrete isoperimetric fact, and it is sharp. Applied to the whole sample, it says a rank vector on $n$ points has variance exactly $(n^3-n)/12$.

Put the two together. A dial's ranks $X$, a response tied on a block of size $m$ out of $n$:

$$\boxed{\ \rho^2 \le 1 - \frac{m^3 - m}{n^3 - n}\ }$$

This is the **Starved-Regime Ceiling**. Note what it looks like: with $q = m/n$ the zero-hit fraction, the penalty is essentially $q^3$. **The tie penalty is cubic in the tie fraction.**

### The cubic is merciless — to the explanation

Now put in the numbers. $m = 194$, $n = 1200$:

$$\frac{194^3 - 194}{1200^3 - 1200} = \frac{7{,}301{,}190}{1{,}727{,}998{,}800} \approx 0.00423.$$

So $\rho^2 \le 0.99577$, that is,

$$\rho \le 0.9979.$$

The zero-hit block, all 194 moduli of it, costs the dial *two tenths of one percent* of its possible score. It cannot bring $\rho$ down to $0.85$. It cannot bring it near $0.55$. It comes nowhere within astronomical distance of explaining $0.405$.

This is the cubic biting. Sixteen percent of the sample sounds like a lot — until you cube it. $0.162^3 \approx 0.0042$. To drag the correlation down to the band edge $0.55$ by ties alone, you would need

$$q^3 \gtrsim 0.6975, \qquad\text{i.e.}\qquad q \gtrsim 0.887.$$

**Nearly ninety percent of your sample would have to record zero hits.** The observed sixteen percent is not in the same universe. The recorded explanation of the failure is false — not slightly optimistic, not imprecise, but off by a factor that no amount of experimental slop can close.

### Two escape routes, both closed

A good sceptic immediately offers two rescues.

**"Maybe your ceiling is lossy."** Cauchy–Schwarz is an inequality; perhaps it threw away most of the truth, and the *real* ceiling is far lower. It did not. There is a **Sharpness Theorem**: the ceiling is attained, and the response that attains it is the block-averaged predictor $\mathbb{E}[X\mid b]$ itself. For that response the Cauchy–Schwarz step becomes an equality, because covariance with the block average is exactly the between-block variance. So $\operatorname{Var}X - W$ is not an upper estimate of the achievable numerator — it *is* the achievable numerator. The $0.9979$ figure is the true optimum.

**"Maybe it's not one block, it's all of them."** A rate is a count divided by a trial budget, so the measured response is *quantized*: it takes only finitely many distinct values, say $r$ of them, and every one of those levels is a tie block of its own. Surely the whole grid of ties does more damage than the single zero block?

The Tie-Block Ceiling generalises to a full partition — every block $k$ of size $m_k$ subtracts its own $(m_k^3 - m_k)/12$, which is the classical Spearman tie correction, now derived rather than assumed. And then a power-mean inequality finishes it: subject to $\sum_k m_k = n$, the sum $\sum_k m_k^3$ is *minimised* when all $r$ blocks are equal, giving $\sum_k m_k^3 \ge n^3/r^2$. Hence the **Quantization Ceiling**:

$$\rho^2 \le 1 - \frac{n^3/r^2 - n}{n^3 - n} \ \xrightarrow[\ n\ \text{large}\ ]{}\ 1 - \frac{1}{r^2}.$$

And for every $r \ge 2$ — even a response quantized to *two values*, a coin flip — this is at least $3/4$, so $\rho \le 0.866$ at worst. Never below $0.55$.

The verdict is total. One block, the whole partition, or maximally brutal quantization: **no tie-based mechanism whatsoever can push the score below the band.** The measurement's loss of resolution is simply not what happened at bit length 56.

### So what did happen?

If ties didn't do it, what did? There is exactly one candidate left, and it is the one that creates *no ties at all*.

At a $0.89\%$ smooth rate, the "measured rate" of each modulus is not the rate. It is a Monte-Carlo estimate of the rate, from a finite budget of trials. And a noisy estimate does not tie things together — it *shuffles* them. The measured ranking is a randomly displaced copy of the true ranking. Every modulus still gets its own distinct rank; they are just in the wrong places. Ties destroy resolution; noise destroys *accuracy*, and correlation does not care about the difference in provenance, only in magnitude.

How much shuffling would it take? This too has an exact answer, and it comes from reading a stability theorem backwards. Covariance is linear in its second argument, so changing the response from $Z$ to $Y$ changes the covariance by $\operatorname{Cov}(X, Y-Z)$, and Cauchy–Schwarz caps that:

$$\big(\operatorname{Cov}(X,Y) - \operatorname{Cov}(X,Z)\big)^2 \le \operatorname{Var}X \cdot \operatorname{Var}(Y - Z).$$

Forwards, this says correlation is robust: a small perturbation of the response moves the score only a little. Backwards — and this is the trick — it says that a *large* drop in the score is a *certificate* of a large perturbation. If the dial would have scored $a$ against the true ranking and scores only $b < a$ against the measured one, then the displacement vector $D$ (measured rank minus true rank, modulus by modulus) must satisfy the **Noise Budget**:

$$\operatorname{Var}(D) \ \ge\ (a-b)^2\,\frac{n^3-n}{12}.$$

Now instantiate. Suppose the dial is genuinely a band-edge dial, worth $a = 0.55$ against the truth, and it measured $b = 0.405$. With $n = 1200$:

$$\operatorname{Var}(D) \ \ge\ (0.145)^2 \cdot \frac{1200^3 - 1200}{12} \ \approx\ 3.0 \times 10^6 .$$

Divide by $n$ and take a square root and this becomes something you can picture. The typical modulus must have been moved

$$\text{RMS displacement} \ \approx\ \sqrt{3.0\times 10^6 / 1200} \ \approx\ 50 \ \text{rank positions},$$

out of 1200 — about **four percent of the sample**, for every modulus, on average.

And that is only the *floor*. The inequality says fifty positions is necessary; it does not say fifty is enough. Fifty is the figure you would need if the noise were adversarially aimed — every displacement conspiring to work against this particular dial. Real estimator noise is not aimed; it is isotropic, scattering points in directions that mostly have nothing to do with the dial, and isotropic noise is a wasteful way to destroy a correlation. If the displacement is independent from point to point, the arithmetic changes: the correlation is attenuated by a factor $\sqrt{V/(V+S)}$, where $V$ is the rank variance and $S$ the noise energy, and reproducing the drop from $0.55$ to $0.405$ then demands an RMS displacement of roughly **318 rank positions — twenty-seven percent of the sample**, about forty times the certified energy floor.

So the conclusion only hardens. Whichever way the noise is structured, the amount required is enormous — while the tie block, remember, costs two tenths of one percent. And it is a specific, *falsifiable* claim about the rate estimator: measure the actual rank jitter of the rate measurement at bit length 56, by re-running it with an independent seed and comparing the two rankings. If the jitter comes out far below fifty positions, the noise explanation fails too, and something genuinely new is happening. If it comes out in the hundreds — which, when most moduli record a handful of hits and 194 record none, is entirely plausible — the case is closed.

### The floor is real — but it belongs to something else

The original headline was that the dial's bit-length stability "has a practical floor near bit length 54, beyond which the starved regime destroys rank resolution." Half of that survives, and the surviving half is sharper than the original.

The floor is real: past some bit length, the dial does leave the band. But the floor is **not a property of the dial**, and it is not a resolution phenomenon. It is a property of the *measurement apparatus*. The floor sits exactly where the Monte-Carlo error of the rate estimate, translated into rank units, reaches about four percent of the sample size. Push the trial budget up and the floor moves down; keep the budget fixed and shrink the smooth rate and the floor comes to meet you. The dial itself, for all this analysis knows, may still be perfectly good at bit length 56 — we would have no way to tell, because we have not measured its target accurately enough to grade it.

There is a general moral here, and it is worth more than the specific experiment. When a rank statistic degrades, the reflex is to blame *coarseness*: ties, quantization, saturation, floor effects, censoring. Coarseness feels like it should be devastating. But the cubic in $(m^3-m)/(n^3-n)$ says otherwise. Rank correlation is astonishingly tolerant of coarseness and astonishingly intolerant of jitter. You can tie a sixth of your data together and lose 0.2%. But misplacing each point — by four percent of the sample if the errors conspire against you, by a quarter of it if they are merely random — costs 0.15 in $\rho$, half the distance from a useful dial to a useless one.

Coarse data is usually fine. Wrong data is not. The two failure modes look identical in a log file and are separated by a cube.

The asymmetry is stark once you line the numbers up at $n = 1200$. Tying sixteen percent of the sample into one block: $\rho$ can still reach $0.998$. Quantizing the response to a single bit — two levels, the crudest measurement imaginable: $\rho$ can still reach $0.866$. But shuffling each point by a few hundred positions: $\rho$ falls through the floor. Resolution is cheap; accuracy is everything.

### Coda: what it means to grade a diagnosis

None of the mathematics above is exotic. The law of total variance is a century old; Cauchy–Schwarz is older; the fact that consecutive integers minimise spread is the sort of thing you might set as an exercise. The tie correction $(m^3-m)/12$ appears in Spearman's own tables.

What was missing was nobody having *multiplied it out*. The explanation "starvation destroys rank resolution" was plausible, mechanistically vivid, and consistent with every qualitative feature of the data. It was also refutable in about four lines of arithmetic, once you knew which four lines. The cubic threshold at $q \approx 0.887$ is not a subtle correction to the story; it is a wall the story runs into at full speed.

The productive part is what replaces it. A false explanation with no number attached generates no further work. A quantified one — *the estimator must be jittering ranks by about fifty positions* — tells the next experiment exactly what to measure. That is the trade the mathematics bought: a comfortable story exchanged for an uncomfortable, checkable one.
