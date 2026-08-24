# The Dial That Drifts: How a Signal Dies by Being Outvoted

## A needle that keeps slipping

Imagine an instrument with a single needle. You feed it a stream of random integers, each one $b$ bits long. For each integer it computes a simple arithmetic descriptor — how many trailing binary zeros the number has, i.e. how many times $2$ divides it — and it compares that descriptor, by rank, against some observed outcome of a downstream computation. The needle reports one number: the rank correlation $\rho$ between descriptor and outcome.

For years the needle has been trusted because it sits in a comfortable band, $0.55 \le \rho \le 0.85$. A reading inside the band means "this descriptor still explains the outcome." A reading below the floor means the descriptor has stopped being informative.

Then someone ran the instrument up a ladder of bit-lengths and wrote down what it said:

| bits $b$ | 44 | 52 | 56 | 64 | 68 | 72 | 76 | 80 | 84 | 88 |
|---|---|---|---|---|---|---|---|---|---|---|
| $\rho$ | 0.78 | 0.81 | 0.69 | 0.65 | 0.61 | 0.61 | 0.61 | 0.57 | 0.56 | **0.534** |

The needle is sliding. And at $88$ bits it slid, for the first time, *below the floor*. The confidence interval $[0.509,\,0.555]$ straddles $0.55$, so the reading is not a clean rejection — but it is the first band miss in the entire series.

Two very different explanations are on the table, and they lead to opposite engineering decisions.

**Explanation A (the instrument is breaking).** Rank correlations are computed on ranks, and the trailing-zero descriptor has enormous *ties*: half of all integers have zero trailing zeros, a quarter have exactly one, an eighth exactly two. Ties compress ranks and cap the achievable correlation. Maybe the cap is falling as $b$ grows and the needle is simply running out of headroom.

**Explanation B (the signal is being outvoted).** Maybe the descriptor is still saying exactly what it always said, but the outcome is being driven by a growing crowd of *other* influences. One honest voice in a room of $m$ shouting strangers is not less honest; it is just less audible.

This article is about how you settle that question with theorems rather than with more runs of the instrument — and about what the answer turned out to be.

## The dilution law: one channel out of $b$

Start with the cleanest possible version of Explanation B. Suppose the outcome $Y$ is a sum of $b$ independent binary influences, or *channels*, each contributing $0$ or $1$ with equal probability. Suppose the descriptor $X$ *is* one of those channels — the honest voice — and that it is carried into the outcome with weight $a$:

$$Y = a X + C_1 + C_2 + \cdots + C_m, \qquad b = m+1.$$

What correlation does the needle read? Take the exact sample: all $2^{m+1}$ equally likely configurations, no sampling noise, no approximation. Compute the three moments — the variance of $X$, the variance of $Y$, and their covariance — and form Pearson's squared coefficient. The answer is a single rational number.

> **Channel-Dilution Law.** In a model with $b = m+1$ independent binary channels whose outcome carries the descriptor's own channel with weight $a \neq 0$, the squared correlation between that channel and the outcome is exactly
> $$\rho^2 \;=\; \frac{a^2}{a^2 + m} \;=\; \frac{a^2}{a^2 + b - 1}.$$
> In particular, when the descriptor is carried with unit weight, $\rho^2 = 1/b$: **one channel out of $b$ buys exactly one $b$-th of the squared correlation.**

That statement is exact — not asymptotic, not approximate, not a simulation. The proof is a moment computation over the Hamming-weight spectrum of the $m$-dimensional cube: among the $2^m$ possible settings of the competing channels, the number with weight $w$ is $\binom{m}{w}$, and the first two moments of that spectrum are $2\sum w = m 2^m$ and $4 \sum w^2 = 2^m(m^2+m)$. Everything else is algebra, and every factor of $2^m$ cancels.

Two immediate consequences. The law is strictly decreasing in the number of channels, as it must be. And multiplying by the bit-length,

$$b\,\rho^2(b) - a^2 = \frac{a^2(1-a^2)}{a^2+b-1} \longrightarrow 0,$$

so $b\rho^2(b) \to a^2$. Dilution is an **inverse-bit-length law**: the *product* $b\rho^2$, not $\rho$ itself, is the stable observable.

## The alphabet does not matter

Here is the obvious objection to all of this, and it is a good one. Why binary? The ladder is indexed by *bit*-length, so bits felt natural — but that is a modelling convenience, not a fact about the world. Real computations move bytes, limbs, residues modulo some $q$. If widening the alphabet changed the dilution rate, then the whole "channel" reading of the ladder would be an artefact of an arbitrary choice, and the erosion could be blamed on quantisation width.

So do it again over the alphabet $\{0,1,\dots,q-1\}$. Let the descriptor be one uniform $q$-ary digit; let the outcome be that digit carried with weight $a$ plus the sum of $m$ further independent uniform $q$-ary digits. That is a sample of $q^{m+1}$ equally likely configurations. You need the first two moments of a sum of $m$ i.i.d. uniform $q$-ary digits, which come out of a short induction:

$$\sum w = q^m \cdot \frac{m(q-1)}{2}, \qquad 12\sum w^2 = q^m\bigl(m(q^2-1) + 3m^2(q-1)^2\bigr).$$

Feed those in, and something pretty happens. All three determinant-form moments collapse onto a *single* common scale
$$V = q^{2m}\cdot \frac{q^2(q^2-1)}{12},$$
with the variance of the descriptor equal to $V$, the covariance equal to $aV$, and the variance of the outcome equal to $(a^2+m)V$. The scale cancels in the ratio.

> **Alphabet Universality.** For every alphabet size $q \ge 2$, every weight $a \neq 0$ and every channel count $m$,
> $$\rho^2 = \frac{a^2}{a^2+m}.$$
> The correlation is literally independent of $q$: bits, bytes and residues mod $q$ all dilute at exactly the same rate. **Dilution counts channels, not symbols.**

Setting $q=2$ recovers the binary law, as it must.

## Why the law is forced, not fitted

A skeptic can always say: you found a curve that fits. The dilution law is better than that — it is the unique solution of a functional equation.

Define the **reciprocal excess** of a reading, $e = 1/\rho^2 - 1$. For any genuine independent-channel model this is the size of the competing pool measured in units of the descriptor's own channel. Under the dilution law $e(m) = m/a^2$, and therefore

> **Additivity of the Reciprocal Excess.** $e(m+n) = e(m) + e(n)$: two independent blocks of competing channels contribute independent, additive amounts of dilution.

And that additivity, plus one anchor, pins the law completely:

> **Uniqueness.** Let $f : \mathbb{N} \to \mathbb{Q}$ satisfy $f(0)=1$, $f(1)=a^2/(a^2+1)$, and $1/f(m+n) - 1 = (1/f(m)-1) + (1/f(n)-1)$ for all $m,n$. Then $f(m) = a^2/(a^2+m)$ for every $m$.

The proof is a two-line induction on the reciprocal scale: additivity forces $1/f(m) = 1 + m/a^2$, and inverting gives the law. This is why the reciprocal excess, and not the correlation itself, is the right coordinate for reading the ladder. On the $e$-scale, "adding channels" is *addition*.

## Ties and channels multiply, and do not interact

That still leaves Explanation A on the table. Ties genuinely do cap the correlation: if a descriptor takes only a few distinct values, its ranks are heavily tied, and no outcome whatsoever can push the rank correlation to $1$. For the trailing-zero descriptor on $b$-bit integers the tie structure is exactly dyadic: $2^{b-1}$ integers with no trailing zero, $2^{b-2}$ with exactly one, and so on down to a singleton. The maximum achievable squared rank correlation against a perfectly refining outcome is then

$$\rho^2_{\text{tie}}(b) = \frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right).$$

Two mechanisms, then: a tie ceiling and a channel pool. Do they interfere? Cross a tie profile with an independent $m$-channel noise cube — take the outcome to be $a \cdot(\text{refining rank}) + c\cdot(\text{channel sum})$ — and compute the exact correlation of the resulting sample of size $2^m n$.

> **Product Law.** For a tie profile with total mass $n$, refining sum of squares $S_R$ and total sum of squares $S_S$,
> $$\rho^2 \;=\; \frac{a^2 S_R}{a^2 S_S + \tfrac14 c^2 n m} \;=\; \rho^2_{\text{tie}} \cdot \frac{a^2 S_S}{a^2 S_S + \tfrac14 c^2 n m}.$$
> **Tie attenuation and channel dilution compose multiplicatively, with no interaction term.**

Every cross term between tie structure and noise cancels identically, because the mid-rank mass of a tie profile about its grand mean is zero. That is a genuinely clean structural fact: the two mechanisms live in orthogonal directions and can be reasoned about separately.

Now we can decide between Explanations A and B, because the tie ceiling is *numerically frozen*. Across the entire recorded ladder — from $44$ bits to $88$ bits, a doubling — the ceiling $\tfrac67(1 + 2^{-b}(2^b+1)^{-1})$ moves by less than $10^{-26}$. The needle, meanwhile, fell by more than $0.32$ on the $\rho^2$ scale. The $88$-bit reading of $0.534$ sits nowhere near a ceiling of $0.857$.

**Explanation A is dead.** The erosion is not the instrument running out of headroom. It is the signal being outvoted.

## The ladder as an inverse-bit-length law — and the retrodiction

If dilution is the mechanism, the stable observable should be $\rho^2 b$. So compute it, rung by rung:

| $b$ | 44 | 56 | 64 | 68 | 72 | 76 | 80 | 84 | 88 | *(52)* |
|---|---|---|---|---|---|---|---|---|---|---|
| $\rho^2 b$ | 26.77 | 26.66 | 27.04 | 25.30 | 26.79 | 28.28 | 25.99 | 26.34 | 25.09 | *34.12* |

Nine of the ten rungs lie in $[25,\,28.3]$ — the invariant is constant to about $\pm 6\%$ across a *doubling* of the bit-length, while $\rho^2$ itself falls by a factor $2.13$. The tenth rung, at $52$ bits, sits at $34.12$, far outside; it is also the rung that broke monotonicity by reading $0.81 > 0.78$. It is a genuine outlier, and every subsequent analysis flags it independently.

The invariant even predicts out of sample: fit it at one rung and use it to forecast the *next* rung, and for all eight consecutive pairs the forecast lands within $0.03$ of the observed $\rho^2$ — with nothing fitted to the target.

Pool the nine good rungs into a single constant:

$$C = \frac{7446029}{281250} = 26.4747\ldots$$

Now ask when the fitted law $\rho^2(b) = C/b$ crosses the squared band floor $0.55^2 = 0.3025$. The crossing bit-length is

$$b^\star = \frac{C}{0.55^2} = 87.52\ldots, \qquad 87 < b^\star < 88.$$

> **Retrodiction.** Under the pooled inverse-bit-length law, $\rho^2(b) > 0.3025$ for every $b \le 84$ and $\rho^2(b) < 0.3025$ for every $b \ge 88$. The first band miss is *forced* to occur at the $88$-rung.

The instrument was not having a bad day at $88$ bits. Given the shape of the erosion, $88$ is exactly where the needle *had* to fall through the floor — and the ladder's rungs, spaced four bits apart, bracket the crossing at $87.5$ between the last two available readings.

There is even a sanity check on where the law is allowed to live. The fitted law $C/b$ lies strictly below the exact tie ceiling for every $b \ge 31$, and strictly above it for $1 \le b \le 30$. The recorded ladder starts at $44$, safely inside the legal region. Below $31$ bits the tie ceiling, not the channel pool, would be the binding constraint — a different regime entirely.

## The model is right about the shape and wrong about the details

Good science kills its own models. The literal fixed-weight channel model does *not* survive.

> **Fixed-weight dilution is excluded.** For every weight $a \neq 0$, the exact law $a^2/(a^2+b-1)$ decays *strictly more slowly* between $44$ and $88$ bits than the recorded needle does.

And the alphabet universality theorem upgrades this from a statement about bits to a statement about everything: for every alphabet size $q \ge 2$ as well, no fixed-weight channel model of any width fits both ends of the ladder. The failure is not a quantisation artefact.

It gets worse for the simple model. Allow the pool to grow at any linear rate: $\rho^2(b) = a^2/(a^2 + \kappa(b-1))$ with any weight $a \neq 0$ and any rate $\kappa > 0$. The whole two-parameter family decays too slowly. The reason is visible on the reciprocal scale, where additivity lives:

> **Super-additivity of the channel budget.** A genuine fixed-weight channel model requires $e(88)\cdot 43 = e(44)\cdot 87$. The record gives $e(88)\cdot 43 > e(44)\cdot 87$ strictly: $107.8$ against $56.0$.

The effective pool nearly *quadruples* — by a factor between $3.8$ and $4$ — while the bit-length merely doubles. That is the precise sense in which the ladder is "super-dilute": the pool grows roughly like $b^2$, not like $b$.

## Two models, one answer

So try a quadratic pool with a constant noise floor,
$$\frac{1}{\rho^2(b)} - 1 = \kappa b^2 + c,$$
and fit $(\kappa, c)$ exactly to the two extreme rungs, $44$ and $88$. Three things happen.

First, **the floor is forced positive**: any $(\kappa,c)$ reproducing those two rungs has $\kappa > 0$ *and* $c > 0$. The pure quadratic pool $c=0$ is excluded by the data. So is the pure pairwise-interaction model, in which the competing channels are the $\binom{b}{2}$ pairs of $b$ base channels — that model has the exact dilution $2a^2/(2a^2 + b(b-1))$ and multiplies the reciprocal excess by $174/43 \approx 4.047$ between the endpoints, while the record multiplies it by only $3.895$. The observed erosion is super-additive but *slower* than pure pairwise interaction, and the positive floor fills exactly that gap.

Second, **it retrodicts the ladder**. Fitted on two rungs, the law hits all nine non-outlier rungs to within $0.027$ in $\rho^2$ — including the six it never saw. And it misses the $52$-rung by more than $0.08$, three times the worst deviation anywhere else: a second, independent conviction of the one bad rung.

Third, and this is the payload:

> **Robustness of the $88$-rung.** The inverse-bit-length law (pooled over nine rungs) and the quadratic-pool-with-floor law (interpolated through two rungs) are structurally different and fitted by different procedures — yet both clear the floor at $84$ and fail it at $88$. Both place the band crossing strictly inside $(84,\,88]$.

The first band miss at $88$ bits is a property of the ladder, not of a chosen functional form.

There is also a model that the ladder *rejects*. An equally plausible hypothesis says the inverse-square law lives on the odds scale, $\rho^2/(1-\rho^2) = K/b^2$. On trend alone the two are indistinguishable: all nine good rungs give $K \in [2700, 3450]$, pooling to $K = 3053.6$. But they disagree about the one thing that matters. The odds law puts the first band miss at $84$ — and the $84$-rung *held*, at $0.56 \ge 0.55$. The ladder discriminates, and it selects the $\rho^2$-scale law, whose crossing sits at $87.5$.

## A bridge to Pythagoras

One last surprise, and it is the reason this analysis is not just about one instrument.

Every primitive Pythagorean triple comes from Euclid's parametrisation: for integers $m > n$,
$$(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2.$$
Fix an *odd* generator $m$ and let the other generator $n$ range over all $2^b$ residues below $2^b$. How is the trailing-zero descriptor distributed on the even leg $2mn$?

Because $m$ is odd, $2^{k+1} \mid 2mn$ if and only if $2^{k} \mid n$ — the odd factor $m$ is invisible to the $2$-adic valuation, and the factor $2$ merely shifts the index by one. Consequently exactly $2^{\,b-1-k}$ of the $2^b$ generators produce an even leg with precisely $k+1$ trailing binary zeros.

> **Pythagorean Transfer.** For every odd generator $m$, the tie profile of the trailing-zero descriptor on the even legs $2mn$, $n < 2^b$, is *literally* the dyadic profile $(2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$ of uniform integers. Hence the exact tie ceiling
> $$\rho^2_{\text{tie}}(b) = \frac67\left(1 + \frac{1}{2^b(2^b+1)}\right)$$
> holds verbatim on Pythagorean even legs, and the $88$-bit band miss transfers unchanged: at $88$ bits the ceiling is still above $6/7$, so the reading of $0.534$ is nowhere near it.

Every ceiling proved for uniform integers holds, without modification, on the even legs of the Euclid family. The erosion at $88$ bits must be charged to the response, not to the arithmetic of the tie blocks — in the Pythagorean world exactly as in the uniform one.

## What the needle was really telling us

The story has a shape worth remembering, because it recurs whenever a diagnostic starts to fade.

A statistic that is losing its correlation is not necessarily *wrong*. Here the descriptor's own contribution never changed: the same weight $a$, the same honest voice. What changed was the size of the room. The correlation obeys $\rho^2 = a^2/(a^2 + m)$ — a law that does not care whether the channels are bits or bytes, that is forced by a single additivity axiom rather than fitted, and that composes with the tie ceiling by plain multiplication.

Reading that law backwards turns a fading needle into a *measuring device for the competition*: the reciprocal excess $1/\rho^2 - 1$ counts, in units of the signal's own channel, how many independent influences are shouting. Do that on the recorded ladder and you learn something the raw readings hide — the crowd is growing like $b^2$, not like $b$, and there is a small positive constant of non-channel noise on top.

And you learn that the $88$-bit miss was scheduled. Two independent models, fitted by different procedures, both place the crossing between $84$ and $88$ bits; the pooled inverse-bit-length constant places it at $87.52$. The instrument did not break. It reached, precisely on time, the bit-length at which one honest voice is no longer loud enough to be heard.
