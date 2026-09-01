# The Dial That Would Not Say Whether It Was Dying

## A story about seven numbers, and about what a finite table of measurements can honestly be made to confess

---

### 1. A signal, fading

Somewhere inside a machine-learning pipeline there is a feature — a single number extracted from each input — and that feature is useful. Feed the model a large integer $x$ and count how many zeros sit at the bottom of its binary expansion: $12 = 1100_2$ ends in two zeros, $40 = 101000_2$ ends in three, an odd number ends in none. Call that count $T(x)$. It is the humblest possible statistic, the *2-adic valuation*, and for reasons that need not detain us it correlates with a downstream quantity the pipeline cares about, which we will simply call the *rate*.

How useful is it? Draw a large sample of integers uniformly at random from a fixed bit-length $b$, compute $T$ for each, compute the rate for each, and measure the Spearman rank correlation

$$\rho(b) \;=\; \operatorname{corr}_{\text{rank}}\bigl(T,\ \text{rate}\bigr).$$

Now turn a dial: increase $b$. Longer inputs, more entropy, more room for the rate to be determined by things $T$ cannot see. The correlation should fall. It does.

At bit-length $104$ — three independent random seeds, pooled — the reading is

$$\rho(104) = 0.500, \qquad \text{95\% CI } [0.456,\ 0.545],$$

with per-seed values $0.493$, $0.499$, $0.509$. For the first time every seed sits below $0.55$. The four-bit steps immediately before it were $-0.030$ and $-0.043$: monotone, near-linear, and if anything *accelerating*.

There is a second, more cheerful number in the same experiment. A naive baseline statistic — just counting set bits — is also being tracked, and it is degrading *faster*. The advantage of $T$ over the baseline has grown from $+0.070$ to $+0.073$ to $+0.126$. The feature is fading, but it is fading more slowly than its competitor.

And so the question that this article is about:

> **Does $\rho(b)$ level off at some positive floor, or does it reach zero at a finite bit-length?**

The stakes are practical. A positive floor means the feature is permanently worth computing; you build it into the production system and forget about it. Extinction at finite $b$ means there is a bit-length past which the feature is literally worthless, and you had better know where it is before your inputs get there.

By the time the dust settled, seven rungs of the ladder had been measured, at bit-lengths $96$ through $120$ in steps of four:

$$0.5739,\quad 0.5436,\quad 0.5005,\quad 0.4880,\quad 0.4621,\quad 0.4847,\quad 0.43636.$$

Two competing analyses of exactly those seven numbers reached opposite conclusions. One localized a *plateau* in the band $[0.4362, 0.488]$ and recovered a floor near $0.474$. The other extrapolated a secant and forecast the dial's death somewhere around bit-length $230$.

Somebody had to be wrong. It turns out that the honest answer is stranger and more useful than "somebody is wrong."

---

### 2. Ladders, and the only question that matters

Strip away the statistics. What we have is a **ladder**: a sequence of numbers $\rho_0, \rho_1, \rho_2, \dots$ (rung $k$ is bit-length $96 + 4k$) together with its **decrements**

$$d_k \;=\; \rho_k - \rho_{k+1}.$$

Any ladder can be rebuilt from its start and its decrements: $\rho_n = \rho_0 - \sum_{k<n} d_k$.

Suppose for a moment that all decrements are nonnegative — the fade never rebounds. Then a completely elementary observation carves the world in two.

> **The Fade Dichotomy.** Every fade with nonnegative decrements either has a floor — a single number $L$ with $L \le \rho_n$ for every $n$ — or reaches zero at a finite rung. There is no third possibility.

The proof is one line, and it is worth seeing because it relocates the entire debate. Either the partial sums $\sum_{k<n} d_k$ are bounded above by some budget $S$, or they are not. If they are bounded by $S$, then $\rho_n = \rho_0 - \sum_{k<n} d_k \ge \rho_0 - S$ for every $n$: there is your floor, explicitly, and if $S < \rho_0$ it is a *positive* floor and the dial survives for ever. If they are not bounded, then some partial sum exceeds $\rho_0$, and at that rung $\rho_n \le 0$: the dial is dead, at a finite, nameable bit-length.

So the question is not *how fast does the fade decay?* The question is **is the total remaining fade finite?** Summability, not decay. This distinction sounds pedantic. It is the whole story.

---

### 3. The harmonic trap: a signal that dies invisibly

Here is why the distinction bites.

The measurement at bit-length $108$ was greeted as good news for the plateau camp. The decrement dropped from $0.0431$ to $0.0125$ — the fade was *decelerating*, the steps were shrinking, surely the ladder was flattening out towards something.

Consider, then, the **harmonic fade**: start where the real ladder starts, at $\rho_0 = 0.5739$, and take as your $k$-th decrement

$$d_k \;=\; \frac{0.0303}{k+1},$$

so the first step is exactly the recorded first step of $0.0303$ and every subsequent step is smaller than the last. The decrements shrink to zero. They shrink to zero *monotonically*. Anyone watching this ladder rung by rung would report deceleration, then flattening, then apparent convergence.

The ladder value after $n$ steps is $0.5739 - 0.0303\,H_n$, where $H_n = 1 + \tfrac12 + \dots + \tfrac1n$ is the harmonic number. And $H_n \to \infty$. So:

> **Vanishing steps certify nothing.** The harmonic fade has positive decrements tending to zero; it still reads above $0.33$ throughout its first one hundred and twenty-eight four-bit steps — a span of $512$ bits, four times the entire recorded sweep — and it is nevertheless extinguished at a finite rung.

How finite? Using the classical bounds $1 + \tfrac{m}{2} \le H_{2^m} \le 1 + m$, one checks that this particular fade is certainly dead by its $2^{36}$-th step and certainly alive through its $128$-th. Its death is real, mathematically certain, and utterly unobservable. You would need to run the experiment out past $2^{38}$ bits to see it.

The deceleration recorded at bit-length $108$, then, is not evidence for a plateau. It is consistent with a plateau. It is equally consistent with a death sentence that no experiment will ever execute.

---

### 4. Two futures, one past

Worse follows. Deceleration is weak evidence, but perhaps the seven numbers *together* pin things down? They do not, and the failure is total.

Take any observed ladder $g_0, \dots, g_N$ whatsoever, with $g_N > 0$. Build two continuations of it:

- **The floor continuation.** For $k \le N$ it equals $g_k$. For $k > N$ it equals $\dfrac{g_N}{2}\left(1 + \left(\tfrac12\right)^{k-N}\right)$.
- **The extinction continuation.** For $k \le N$ it equals $g_k$. For $k > N$ it equals $g_N - (k-N)\cdot \dfrac{g_N}{10}$.

Both reproduce every observed rung exactly. Both are decreasing from rung $N$ onward — neither does anything perverse. Yet the first never falls below $g_N/2 > 0$, and the second hits exactly $0$ at rung $N+10$.

Instantiate this on the seven recorded rungs, with $g_6 = 0.43636$ at bit-length $120$:

> **The plateau reading and the extinction reading are both consistent with every number measured.** One continuation of the recorded ladder never falls below $0.21818$; another reproduces the same seven values and reads exactly zero at bit-length $160$.

This is not a statement about statistical power, sample size, or confidence intervals. It is a statement about logic. No amount of precision in those seven measurements can separate the two hypotheses, because both hypotheses *contain* those seven measurements.

If you want the deadlock broken, you must either measure a new rung — the two continuations above differ by more than $0.17$ at bit-length $156$, which makes for a clean discriminating experiment — or you must import an assumption about the shape of the future.

---

### 5. Contraction: the assumption that actually does the work

What kind of assumption would suffice? Not "the steps shrink" — the harmonic fade shrinks its steps and dies. You need the steps to shrink *at a definite rate*.

Call a ladder **$q$-contractive** if each decrement is at most $q$ times the previous one in absolute value:

$$|d_{k+1}| \;\le\; q\,|d_k| \qquad \text{for all } k.$$

A one-line induction gives $|d_{n+j}| \le q^j |d_n|$: from any rung, the decrements decay geometrically. Sum the geometric series, and you get the result that makes contraction so powerful:

> **The Tail Bound.** If a ladder is $q$-contractive with $0 \le q < 1$, then for every $n$ and every $m$,
> $$\bigl|\rho_{n+m} - \rho_n\bigr| \;\le\; \frac{|d_n|}{1-q}.$$

Read that again, because it is remarkable. **One measured step controls the entire infinite future.** You measure a single decrement $d_n$, you divide by $1-q$, and you have bounded everything that can ever happen to the ladder from rung $n$ onwards.

Two corollaries fall out immediately. First, the floor is explicit: every later rung satisfies

$$\rho_{n+m} \;\ge\; \rho_n - \frac{|d_n|}{1-q}.$$

Second, if that quantity happens to be positive — if $|d_n|/(1-q) < \rho_n$, i.e. if the current step is small compared to the current reading — then the dial is **never** extinguished. Every future rung is strictly positive.

So the plateau reading is not an alternative *interpretation* of the data. It is exactly, precisely, the contraction hypothesis, wearing a different hat. And both of the analyses that produced a floor were quietly making it: one assumed the decrements contract by a factor $r \le 1/2$; the other applied Aitken's $\Delta^2$ extrapolation, which is *exact* precisely for geometrically contracting sequences and merely heuristic otherwise.

Which raises the obvious question. Does the recorded ladder contract?

---

### 6. The audit

Compute the six decrements of the recorded ladder:

| step | bit-lengths | decrement |
|---|---|---|
| $d_0$ | $96 \to 100$ | $\phantom{-}0.0303$ |
| $d_1$ | $100 \to 104$ | $\phantom{-}0.0431$ |
| $d_2$ | $104 \to 108$ | $\phantom{-}0.0125$ |
| $d_3$ | $108 \to 112$ | $\phantom{-}0.0259$ |
| $d_4$ | $112 \to 116$ | $-0.0226$ |
| $d_5$ | $116 \to 120$ | $\phantom{-}0.04834$ |

The very first pair already misbehaves: $|d_1| = 0.0431 > 0.0303 = |d_0|$, so no $q < 1$ survives even the opening move. But the decisive failure is at the end. At bit-length $116$ the dial *rebounded* — the decrement was negative, $-0.0226$, the correlation went up. And then at bit-length $120$ it gave the gain back and more, with a step of $+0.04834$.

Any $q$ satisfying $|d_5| \le q\,|d_4|$ must satisfy

$$q \;\ge\; \frac{0.04834}{0.0226} \;=\; 2.1389\ldots$$

Hence:

> **The recorded ladder is not contractive.** Any factor $q$ bounding all six consecutive step ratios satisfies $q \ge 2$. In particular no $q < 1$ exists, and the hypothesis $r \le 1/2$ under which a plateau was localized is violated — by a factor of more than four — by the very ladder it was applied to.

Put the two halves side by side and you have the finding of this work:

> **Identifiability requires contraction, and the data supply none.** Contraction with $q<1$ implies an explicit floor $\rho_n - |d_n|/(1-q)$ at every later rung. The recorded ladder admits no contraction factor below $2$. The plateau reading is therefore a hypothesis about rungs that have not been measured, not a consequence of the rungs that have.

---

### 7. Curvature, and why no smooth law fits either

One might hope to escape by fitting a functional form. The previous round had done exactly that, fitting the hyperbolic erosion law $\rho(b) = \tfrac{5}{14} + \tfrac{93}{5b}$, which decays for ever towards the asymptote $5/14 \approx 0.357$ but never dies.

The bit-length-$104$ reading kills not just that fit but its entire shape class, via a small exact computation. On a four-bit grid, the second difference of the hyperbolic law $A + C/b$ is

$$\bigl(\rho(b) - \rho(b{+}4)\bigr) - \bigl(\rho(b{+}4) - \rho(b{+}8)\bigr) \;=\; \frac{32\,C}{b\,(b{+}4)\,(b{+}8)},$$

and for the geometric law $A + Cq^b$ it is $C\,q^{b}\,(1-q^4)^2$. Both are positive whenever $C > 0$, and positivity of that expression says exactly one thing: **the decrements are decreasing.** Every convex fade law, hyperbolic or geometric, with any parameters whatsoever, *decelerates*.

The recorded decrements at bit-lengths $96 \to 100 \to 104$ do the opposite: $0.0303$ then $0.0431$. They accelerate. So no hyperbolic law and no geometric law passes through those three readings — not a mis-fit, an exclusion.

And when the later rungs arrived, the exclusion widened rather than narrowed. The triple at bit-lengths $96, 100, 104$ has second difference $0.0303 - 0.0431 = -0.0128 < 0$: strictly concave. The triple at $100, 104, 108$ has second difference $0.0431 - 0.0125 = +0.0306 > 0$: strictly convex. The full seven-rung ladder therefore contains both, and **no law of fixed curvature sign can reproduce it at all.** The ladder is not the smooth decay curve everybody, including the models, wanted it to be.

---

### 8. What to take away

Three things, in increasing order of generality.

**About this feature.** At bit-length $104$ the trailing-zero statistic still carries a rank correlation of $0.500$ with the rate, and its margin over the naive baseline is *widening* to $+0.126$ because the baseline is collapsing faster. Whether the correlation levels off or reaches zero is, on the present evidence, undetermined. Two independent secants — one through bit-lengths $52$ and $104$, one through $104$ and $120$ — happen to agree on a death between bit-lengths $228$ and $231$; that is a forecast, clearly labelled, not a theorem.

**About extrapolation.** The tail bound is a genuinely useful tool and deserves to be used properly. If your process is $q$-contractive, one measured step certifies the whole future to within $|d_n|/(1-q)$. But the certificate is only as good as $q$, and $q$ is an *assumption*, not a measurement. The right discipline is to compute, from your data, the smallest $q$ that actually holds — the maximum consecutive step ratio — and see whether it is less than one. Here it is $2.14$. The honest reading is: the certificate does not apply.

**About reading tables of numbers.** Shrinking increments feel like convergence. They are not convergence. The harmonic fade shrinks its increments to zero, holds above $0.33$ for four times the length of the observed experiment, and still dies. Between "the steps are getting smaller" and "the total remaining change is finite" lies the entire difference between a feature you can rely on and one that is quietly on its way to worthless — and no finite table of readings can tell you which side of that line you are on.

The dial at bit-length $104$ reads $0.500$. What it will read at bit-length $1040$ is not written in the seven numbers we have. It is written in an assumption, and the useful contribution of this work is to have named the assumption precisely, shown exactly what it buys, and shown that the data do not support it.

That is a less satisfying answer than "the feature has a floor." It has the advantage of being true.
