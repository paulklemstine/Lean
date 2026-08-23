# Three Clocks, One Race: What Happens When You Measure a Scaling Exponent Honestly

## The oldest question in computational number theory

Give me a number $N$ that I know to be the product of two primes, $N = pq$, both of them roughly the same size. How long will it take to find $p$?

There is no shortage of methods. The most obvious is *trial division*: walk through $2, 3, 5, 7, \dots$ until something divides $N$. Since the smaller factor $p$ is about $\sqrt{N}$, this takes on the order of $p$ steps. There is *Pollard's rho*, a beautiful piece of probabilistic trickery that wanders pseudorandomly through the residues modulo $p$ and waits for a repeat; by the birthday paradox, a repeat is expected after about $\sqrt{p}$ steps. And there is *Fermat's method*, which searches for a representation $N = x^2 - y^2$ by starting at $x = \lceil \sqrt{N} \rceil$ and marching upward — devastatingly fast when $p$ and $q$ are close together, useless when they are not.

Everyone "knows" the exponents: $1$ for trial division, $1/2$ for rho. The interesting question is what happens when you actually *measure* them.

## The experiment, and its surprise

Here is the protocol. Fix a bit size $k$, and draw a large batch — say fifteen hundred — of balanced semiprimes whose smaller prime factor $p$ has exactly $k$ bits. Run all three algorithms on *the same* instances. Average the running times. Then repeat at $k = 16$, $k = 20$, $k = 24$, and ask how the average cost grows.

The natural way to summarize growth is the *log-log slope*. If $E(k)$ denotes the mean cost at bit size $k$, define

$$\mathrm{slope}(k_1, k_2) \;=\; \frac{\log_2 E(k_2) - \log_2 E(k_1)}{k_2 - k_1}.$$

The idea is transparent: if the cost really behaves like $C \cdot 2^{\alpha k}$ — that is, like $p^{\alpha}$ — then the logarithm is a straight line of slope $\alpha$, and the two-point slope reads $\alpha$ off exactly, no matter which two levels you use and no matter what the constant $C$ is. The constant cancels. That is the whole reason exponent measurements are believed at all.

The measurement returned:

| channel | measured slope |
|---|---|
| trial division | $0.84$ |
| Pollard rho | $0.52$ |
| Fermat | $0.50$ |

Two of these look like triumphs. The rho slope $0.52$ is essentially the birthday exponent $1/2$. Fermat's $0.50$ is not an algorithmic exponent at all, as we shall see — it is a thermometer reading of the population.

But trial division came in at $0.84$, not $1$. Sixteen percent short. And the obvious reflex is to shrug: *finite-size effects; the constants are drifting; the lever arm is short; what did you expect?*

This article is about what happens if you refuse to shrug.

## How much can a constant lie to you?

The first thing to nail down is exactly how much slack a drifting constant buys. Suppose we do not know the constant at all, only that it is trapped in a range. Say the mean cost satisfies

$$c_1 \cdot 2^{\alpha k} \;\le\; E(k) \;\le\; c_2 \cdot 2^{\alpha k} \qquad \text{for every } k,$$

with $0 < c_1 \le c_2$. Call this a *power band* with exponent $\alpha$ and spread $c_2/c_1$. It is the honest form of a scaling hypothesis: you assert the exponent, you decline to assert the constant.

**Identifiability Theorem.** *If $E$ obeys a power band with exponent $\alpha$ and constants $c_1 \le c_2$, then for any two levels $k_1 < k_2$,*

$$\bigl|\mathrm{slope}(k_1,k_2) - \alpha\bigr| \;\le\; \frac{\log_2(c_2/c_1)}{k_2 - k_1}.$$

The proof is two lines once you take logarithms: $\log_2 E(k)$ lives in a vertical strip of height $\log_2(c_2/c_1)$ around the line $\alpha k$, and a chord across a strip of that height over a horizontal run of $\Delta k = k_2 - k_1$ can tilt by at most (height)/(run).

This is a small inequality with a large moral. **Multiplicative model error enters an exponent measurement divided by the lever arm.** Ignorance about constants does not corrupt an exponent estimate uniformly; it is suppressed linearly in how far apart your measurement levels are. With $k$ running from $16$ to $24$ we have $\Delta k = 8$, so a factor-of-two ambiguity in the constant costs only $1/8$ of an exponent.

And the inequality runs backwards too, which is where it starts to bite. Turn it around: if the measured slope misses $\alpha$ by at least $d$, then *no* power band with spread less than $2^{d \cdot \Delta k}$ can hold. A slope anomaly is not merely a disappointment; it is a quantified piece of evidence about the constants.

## The window pins the constants

So far $c_1$ and $c_2$ have been free. But in this experiment they are not free, because the population is confined to a *dyadic window*. Saying "$p$ has exactly $k$ bits" means $2^{k-1} \le p < 2^k$: the factor varies by at most a factor of two within a level.

That confinement is enough to pin the band. If every instance at level $k$ costs exactly $a \cdot p^{s}$ for some fixed exponent $s \ge 0$ and some fixed implementation constant $a > 0$, then the mean cost is trapped between $a \cdot 2^{s(k-1)}$ and $a \cdot 2^{sk}$ — a power band with exponent $s$ and spread exactly $2^{s}$. The unknown constant $a$ appears in both endpoints and cancels from the spread.

Feed this into the Identifiability Theorem and something striking pops out:

**Pointwise Slope Band.** *For a pointwise cost $a \cdot p^{s}$ on a dyadic population, the measured across-$k$ slope satisfies*

$$\bigl|\mathrm{slope}(k_1,k_2) - s\bigr| \;\le\; \frac{s}{\Delta k},$$

*with no hypothesis whatsoever on the implementation constant.*

Now put in the numbers for trial division: $s = 1$, $\Delta k = 8$. The bound reads $|\mathrm{slope} - 1| \le 1/8$, so the slope must be at least $0.875$.

The measurement said $0.84$.

**A pointwise linear trial-division cost on a dyadic balanced population is refuted by the data, outright, with no free parameters left to blame.** The measurement is not a noisy confirmation. It is a falsification.

## Two clocks on the same stopwatch

The refutation above uses one channel at a time. The distinguishing feature of the protocol, though, is that all three algorithms run on *the same draws*. That coupling is itself mathematics.

Here is why. The trial-division cost and the rho cost are two different functions of the *same* random variable $p$. If trial division costs $a \cdot p$ and rho costs $c \cdot \sqrt{p}$, then their expectations are $a \cdot \mathbb{E}[p]$ and $c \cdot \mathbb{E}[\sqrt{p}]$ — and those two numbers are not independent. Cauchy–Schwarz gives one direction immediately:

$$\bigl(\mathbb{E}\sqrt{p}\bigr)^2 \;\le\; \mathbb{E}[p].$$

For the other direction you need to know the sample is confined. If every draw lies in $[L, U]$, then $\mathbb{E}[p] \le (U/L)\,(\mathbb{E}\sqrt{p})^2$; on a dyadic window $U/L = 2$. Together these bracket the trial-division mean between one and two copies of the square of the rho mean, up to a single constant $K = a/c^2$:

$$K \cdot \mathbb{E}[T_\rho]^2 \;\le\; \mathbb{E}[T_{\mathrm{trial}}] \;\le\; 2K \cdot \mathbb{E}[T_\rho]^2.$$

Take logarithms, difference across the lever arm, and the constant $K$ vanishes — along with both implementation constants $a$ and $c$. What survives is a pure relation between the two *measured* slopes:

**Cross-Channel Rigidity Law.** *On one dyadic population, with pointwise costs $a \cdot p$ and $c \cdot \sqrt{p}$,*

$$\bigl|\,\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_{\rho}\,\bigr| \;\le\; \frac{1}{\Delta k}.$$

This is a *consistency law*. It says nothing about what either slope is; it says the two of them cannot be chosen independently. Whatever the population, whatever the constants, one slope must be twice the other to within $1/\Delta k$.

Now evaluate at the reported pair. With $\Delta k = 8$ the law allows a discrepancy of $0.125$. The measurement demands

$$2 \times 0.52 - 0.84 \;=\; 0.20.$$

**The reported pair is impossible.** Not unlikely, not marginal: impossible, for any population of that shape, under those two cost models. And the hypotheses are not vacuous — a one-point population sitting at the bottom of every dyadic window realizes them with slopes exactly $(1, \tfrac12)$, saturating the law with zero slack. The law genuinely constrains, and given $\mathrm{slope}_{\rho} = 1/2$ it predicts $\mathrm{slope}_{\mathrm{trial}} = 1$, not $0.84$.

## The constant was too generous

That $1/\Delta k$ came from the crude reversal $\mathbb{E}[p] \le 2 (\mathbb{E}\sqrt{p})^2$, which throws away everything about the interior of the window. The right tool is the **Kantorovich inequality** (sometimes Pólya–Szegő): for a sample $y$ confined to $[a,b]$,

$$4ab\,\mathbb{E}[y^2] \;\le\; (a+b)^2\,(\mathbb{E}y)^2 .$$

It follows from a single pointwise observation, $(y-a)(b-y) \ge 0$, and one completion of a square. Substituting $y = \sqrt{p}$ on a dyadic window, where $b/a = \sqrt{2}$, replaces the factor $2$ with

$$\frac{4 + 3\sqrt{2}}{8} \approx 1.0303,$$

and hence sharpens the rigidity law to

$$\bigl|\,\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_{\rho}\,\bigr| \;\le\; \frac{\log_2\!\bigl((4+3\sqrt{2})/8\bigr)}{\Delta k} \;<\; \frac{0.044}{\Delta k}.$$

At $\Delta k = 8$ the entire admissible discrepancy is below $0.0055$. The reported pair demands $0.20$. It misses by a factor of more than thirty-six.

The Kantorovich constant is not an isolated trick. Substituting $y = p^{t}$ shows that the whole *doubling ray* — comparing a cost with exponent $2t$ against a cost with exponent $t$ — carries a sharp constant

$$K(t) \;=\; \frac{(1 + 2^{t})^{2}}{4 \cdot 2^{t}},$$

with $K(1/2) = (4+3\sqrt{2})/8$ recovering the case above, and $\log_2 K(t) < 2t^2$ showing it always beats the generic bound. Away from the doubling ray, for arbitrary exponent pairs $0 < t \le s$, power-mean monotonicity still yields a constant-free law

$$\bigl|\,t\cdot \mathrm{slope}_{s} - s \cdot \mathrm{slope}_{t}\,\bigr| \;\le\; \frac{s\,t}{\Delta k}.$$

The rigidity is a general phenomenon: *co-measuring two cost channels on one population is itself a constraint*, and the constraint tightens as the exponents get close.

## Where did the missing exponent go?

We now have a hard fact — the trial-division number is inconsistent with the naive model — and an obligation to say where the inconsistency lives. Two hypotheses present themselves.

**Hypothesis one: the cost accounting is wrong.** Real implementations do not pay $p$; they abandon trial division after a bound proportional to the modulus, so the per-instance cost is $\min(p, B \cdot 2^{k})$. Perhaps truncation manufactures the deficit.

It does not. On a dyadic population the truncated cost still obeys a power band with exponent $1$ and constants $a\min(1/2, B)$ and $a\min(1, B)$ — a spread of at most $2$, *uniformly in the truncation level $B$*. Truncation removes mass; it cannot tilt the window by more than the window's own width. So the slope is still at least $0.875$, and the deficit truncation can produce is strictly below $1/8$, never the required $0.16$. The extreme case is the sharpest form of the obstruction: if $B \le 1/2$ the bound binds on every single draw, the cost becomes the pure power $a B \cdot 2^{k}$, and the measured slope is *exactly* $1$ — deficit zero.

**Hypothesis two: the population is wrong.** Write each level in normalized form, $p_k(i) = 2^{k} \cdot u_k(i)$, where $u_k$ is the level-$k$ sample rescaled to the unit window. Define the *shape moment* $M_s(k) = \mathbb{E}[u_k^{s}]$ — a pure number describing the *shape* of the distribution inside the window, stripped of scale. Then the expected pointwise power cost factorizes exactly:

$$E(k) \;=\; \bigl(a \cdot M_s(k)\bigr)\cdot 2^{sk}.$$

Take logarithms and difference. Everything cancels except one term, and we get not a bound but an **identity**:

**Shape-Drift Identity.** $$\mathrm{slope}(k_1,k_2) \;=\; s \;+\; \frac{\log_2\bigl(M_s(k_2)/M_s(k_1)\bigr)}{\Delta k}.$$

This is the cleanest statement in the whole story. The measured exponent is the true exponent *plus* the logarithmic drift of the normalized shape, divided by the lever arm. Immediately:

- The measurement is *compressed* ($\mathrm{slope} < s$) **if and only if** the normalized moment strictly decreases across the lever arm. Compression is not merely *explained by* shape drift; it is *equivalent* to it.
- Inverting: a deficit $d$ pins the drift exactly, $M_s(k_1)/M_s(k_2) = 2^{d \cdot \Delta k}$. At $s = 1$, $k: 16 \to 24$, the reported $0.84$ forces $M_1(16)/M_1(24) = 2^{1.28} \approx 2.43$.
- But a genuinely dyadic sampler has $u_k \in [1/2, 1]$, so its normalized means live in $[1/2, 1]$ and the ratio is at most $2 < 2^{1.28}$. **The measurement refutes the dyadic window itself.**
- And the mechanism is nonetheless *sufficient*: the explicit drifting sampler $u_k \equiv 2^{-0.16k}$ realizes slope exactly $0.84$ with exactly the predicted shape ratio.

So the missing exponent is accounted for, and the accounting is falsifiable: it converts "the balanced draws compress the exponent" from a narrative into a directly measurable number — go and compute the mean normalized factor at $k = 16$ and $k = 24$, and the ratio must be $2^{1.28}$ or the reported slope is wrong.

## Fermat is a thermometer, not a clock

That leaves the third channel, whose $0.50$ looks suspiciously like a birthday exponent but is nothing of the kind.

Fermat's method starts at $\lceil\sqrt{N}\rceil$ and halts at $(p+q)/2$, so the number of steps is essentially the *offset* $(p+q)/2 - \sqrt{pq}$. A one-line algebraic identity says this offset is exactly $(\sqrt{q}-\sqrt{p})^2/2$, and from there one gets a clean two-sided bound:

**Gap-Locality Law.** *For $0 < p \le q$,*

$$\frac{(q-p)^2}{8q} \;\le\; \frac{p+q}{2} - \sqrt{pq} \;\le\; \frac{(q-p)^2}{8p}.$$

Fermat's cost is $\Theta(\mathrm{gap}^2/p)$, a purely local function of the prime gap. It is not an intrinsic property of the algorithm — it is a readout of the *gap distribution of the population you fed it*.

The consequence is an **exponent transfer law**. If the population's mean gap scales like $2^{\beta k}$, then the Fermat cost surrogate $\mathrm{gap}^2/(8p)$ scales like $2^{(2\beta - 1)k}$:

$$\alpha_{\mathrm{Fermat}} \;=\; 2\beta_{\mathrm{gap}} - 1.$$

Inverting, a measured Fermat slope $\sigma$ determines the gap exponent to half the slope tolerance: $\beta = (\sigma + 1)/2$. The reported $0.50$ therefore predicts $\beta = 0.75$. A population whose gaps scaled proportionally to $p$ — the naive "uniformly balanced" picture — would have $\beta = 1$ and would have shown a Fermat slope of $1$. So the Fermat channel is a *gap-exponent meter*, and it reports that this balanced sampler produces gaps growing like $p^{3/4}$, not like $p$.

Notice the harmony with the previous section. Both the trial channel and the Fermat channel are saying that the sampler's normalized shape is not scale-invariant. The two channels detect the same non-invariance through completely different mathematics.

## And the birthday exponent is a theorem

Meanwhile the rho slope $0.52$ sits comfortably inside its band. The birthday model $\mathbb{E}[T_\rho] = \Theta(\sqrt{p})$ on a dyadic window gives a band of spread $\sqrt{2}$, hence a certified slope band of $1/2 \pm 1/16$ at $\Delta k = 8$. And $0.52$ is not merely *inside* the band — there is an explicit admissible cost curve, obeying the dyadic birthday window at every level, whose two-point slope is exactly $0.52$. The measurement is *non-refuting*, and the analysis pins its status precisely: $0.52$ is admissible only because the window slack is spent almost entirely on the two endpoints.

One can go further and anchor the exponent $1/2$ in a genuine threshold theorem rather than a heuristic. Consider the guaranteed-collision question: how many stored residues force a repeated two-element sum modulo $p$? The answer is exact — one needs $m$ elements with $p < m^2$, and

$$p < m^2 \iff \lfloor\sqrt{p}\rfloor + 1 \le m,$$

so the minimal storage is precisely $\lfloor\sqrt{p}\rfloor + 1$, and at that threshold a collision provably exists. Since $\sqrt{p} \le \lfloor\sqrt{p}\rfloor + 1 \le 2\sqrt{p}$ for $p \ge 1$, the threshold is a $1/2$-power law with spread at most $2$, and the Identifiability Theorem identifies its exponent. The birthday $1/2$ is not folklore here; it is the exponent of a proved threshold.

## The limits of two points

Finally, a word of honesty about the instrument itself. The Identifiability Theorem is *sharp*: inside a window of spread $2^{\sigma}$ there is an endpoint-saturating curve whose measured slope is exactly $\alpha + \sigma/\Delta k$. The band cannot be improved.

Worse — and this is the theorem behind the caveat that fits *within* a single bit size are confounded — the theorem has a converse. Two exponents differing by exactly $2\sigma/\Delta k$ admit two admissible populations, both obeying a window of spread $2^{\sigma}$, whose measured two-point slopes are *identical*. No two-level estimator can separate them. Which means: the lever arm is not a nuisance parameter to be apologized for. It is the resolution of the instrument, and it is exactly computable.

## What to take away

The narrative that survives is not "we measured three exponents." It is this.

An exponent measurement across levels is a legitimate inference, and its error budget is exactly one number: multiplicative model ignorance divided by the lever arm. Once you write that budget down, three things follow. First, the Pollard rho measurement is a clean replication of an exponent that is itself a theorem about a collision threshold. Second, the Fermat measurement is not about Fermat at all; through an exact gap-locality law it is a thermometer reading the gap exponent of the population, and it reads $3/4$. Third — and this is the reason to do the arithmetic honestly — the trial-division measurement is *not* a slightly-off confirmation of linearity. It is a refutation, robust to every free constant, immune to the obvious rescue via cost truncation, sharpened by a rigidity law that links it to the rho channel measured on the very same draws, and resolvable into a single exactly-specified, directly-measurable claim: the normalized factor distribution of the sampler drifts by a factor $2^{1.28}$ across eight bits.

A number that refuses to be $1$ is more informative than a number that agrees. You just have to build the inequality that lets it speak.
