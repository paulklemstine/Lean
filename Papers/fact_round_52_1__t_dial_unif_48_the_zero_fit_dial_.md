# The Ceiling in the Room

### Why a coarse ruler can never measure a fine thing — and how to tell signal from geometry

---

## 1. A knob, a rate, and a suspicion

Somewhere inside a cryptographic pipeline there is a knob. Turn it, and a downstream success rate
moves. The knob is embarrassingly cheap to read: given an integer $x$, count how many zeros sit at
the bottom of its binary expansion before the first $1$. If $x$ ends in `...1011000`, that count is
$3$.

Number theorists know this quantity under a grander name — the **2-adic valuation**
$v_2(x) = \max\{k : 2^k \mid x\}$ — but an implementer knows it as a single machine instruction.
Call it $T$, the **dial**.

The empirical record is this. On uniformly drawn 48-bit integers, measured three times on three
independent random seeds, the rank correlation between $T$ and the downstream rate reads

$$\rho = 0.777, \qquad 0.755, \qquad 0.801.$$

Three seeds, three readings, all inside the pre-registered validation band $[0.55, 0.85]$, spread
under $0.05$. That is a stable dial.

But a good referee is a suspicious referee. A number means little on its own; what matters is
whether it beats a **baseline**. The natural arithmetic baseline for a bitstring statistic is not
another bitstring statistic — it is a **quadratic residue count**. Pick an odd prime $p$; for each
draw, ask whether it is a perfect square modulo $p$; record $1$ for yes and $0$ for no. That is the
[Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol), the oldest pseudo-random bit in
number theory. Against it, $T$ wins on every seed, by between $+0.09$ and $+0.13$.

And now the suspicion sharpens. The baseline is a *two-valued* statistic. It carves the population
into two enormous groups and says nothing inside either. The dial is *many*-valued: half the
integers have $T = 0$, a quarter have $T = 1$, an eighth have $T = 2$, down to a lonely single value
at the bottom. When you rank-correlate against a statistic with huge blocks of tied values, those
ties mechanically drag the correlation down — regardless of whether the statistic is any good.

**So is the dial's margin real signal, or is the baseline merely handicapped by its own
coarseness?**

Everything below answers that question exactly. No simulation, no distributional assumption about
the rate. Only algebra.

---

## 2. The one formula you need

<details>
<summary><b>New to rank correlation? Click for the two-minute background.</b></summary>

[Spearman's $\rho$](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) is
Pearson correlation applied not to two variables but to their *ranks*. Sort the population by
statistic $S$, replace each value by its position, do the same for the target, and correlate. It
measures monotone association without assuming linearity.

The wrinkle is ties. When several items share the same value of $S$, there is no way to rank them
against each other, so they all receive the same **midrank** — the average of the positions they
collectively occupy. Ties therefore *compress* the rank vector: its variance falls below the value
$\frac{n^3-n}{12}$ it would have if all $n$ ranks were distinct. Since a correlation is a
covariance divided by a product of standard deviations, shrinking one of those standard deviations
caps the correlation itself. That cap is the subject of everything that follows.
</details>

Fix a statistic $S$ on a population of $n$ items, and let $m_1, \dots, m_k$ be the sizes of the
groups of items sharing each value. Call $(m_1, \dots, m_k)$ the **tie profile**; note
$\sum_j m_j = n$.

> **The Tie-Ceiling Theorem.** For any statistic with tie profile $(m_1,\dots,m_k)$ on $n \ge 2$
> items, the squared Spearman correlation with *any* other variable satisfies
> $$\rho^2 \;\le\; 1 - \frac{\sum_j m_j^3 - n}{n^3 - n}.$$

<details>
<summary><b>Click to reveal the derivation.</b></summary>

The classical [Kendall tie correction](https://en.wikipedia.org/wiki/Kendall_rank_correlation_coefficient)
of a profile is $\mathcal{T}(L) = \sum_j \frac{m_j^3 - m_j}{12}$, and the midrank variance of $S$
is $\frac{n^3-n}{12} - \mathcal{T}(L)$. A one-line induction on the profile gives the compact form
$$12\,\mathcal{T}(L) = \sum_j m_j^3 - n,$$
so the ratio of tied to untied variance is exactly $1 - \frac{\sum_j m_j^3 - n}{n^3-n}$. Cauchy–Schwarz
against the target's rank vector gives the bound, and it is attained when the target is strictly
monotone in $S$ and untied within blocks — so this is the exact supremum, not a lossy estimate.
</details>

Notice the economy. Of everything one might know about a statistic — what it means, how it is
computed, what deep theorem governs it — the ceiling sees exactly **one number**: the cube sum
$\sum_j m_j^3$. That gives a comparison rule with teeth:

> **Cube-Sum Monotonicity.** At fixed sample size, a smaller cube sum means a higher ceiling.
> Merging two value classes replaces $a^3 + b^3$ by $(a+b)^3$, which is strictly larger — so
> **coarsening a statistic can never raise its ceiling.**

Let's make that tactile. In the workbench below, build a statistic and watch its ceiling; then
click any two bars in the tie profile to merge them and watch the ceiling drop.

{{interactive_demo:0}}

> **Two things to try before reading on.**
> 1. Choose *One Legendre symbol* and drag the prime from $3$ all the way to $31$. The ceiling
>    does not move — not approximately, exactly. Hold that thought.
> 2. Choose *Legendre vector*, note the ceiling, then switch to *Legendre count* with the same
>    number of primes. It falls. You have just discovered the counting collapse.

---

## 3. The dial's ceiling is $6/7$, essentially forever

Among the $N = 2^b$ integers of $b$ bits, exactly $N/2$ have $T = 0$, exactly $N/4$ have $T = 1$,
and so on with a single leftover at the bottom. The tie profile is a geometric cascade
$$D_b = \Bigl(\tfrac{N}{2},\ \tfrac{N}{4},\ \dots,\ 2,\ 1,\ 1\Bigr),$$
and the cube sum is a geometric series that collapses beautifully.

> **The Dyadic Ceiling.** With $N = 2^b$,
> $$\rho^2 \;\le\; \frac{6}{7}\left(1 + \frac{1}{N(N+1)}\right).$$

<details>
<summary><b>Click for the computation.</b></summary>

The cube sum is $\sum_{k=0}^{b-1} 8^{\,b-1-k} + 1 = \frac{N^3-1}{7} + 1 = \frac{N^3+6}{7}$. Hence
$$1 - \frac{N^3 - 7N + 6}{7(N^3 - N)} = 1 - \frac{(N-1)(N-2)(N+3)}{7N(N-1)(N+1)} = 1 - \frac{(N-2)(N+3)}{7N(N+1)},$$
and since $7N(N+1) - (N^2+N-6) = 6(N^2+N+1)$ this is $\frac{6(N^2+N+1)}{7N(N+1)}$, which is exactly
$\frac{6}{7}\bigl(1 + \frac{1}{N(N+1)}\bigr)$.
</details>

At $b = 48$ the correction is below $10^{-28}$. For every practical purpose the ceiling is
$6/7 = 0.857142\ldots$, so in correlation units $\rho \le \sqrt{6/7} = 0.925820\ldots$

The factor $6/7$ deserves a moment: it is the fingerprint of the number $2$. A halving cascade has
cube sum $\frac{1}{1 - 1/8} = \frac{8}{7}$ times its largest cube, that is, one seventh of $N^3$.
A seventh of the resolution is destroyed by ties; six sevenths survive.

---

## 4. The baseline's ceiling is $3/4$, exactly, for every prime

Now the arithmetic side. Modulo an odd prime $p$, how many residues are squares?

> **Arithmetic Bridge.** Modulo an odd prime $p = 2m+1$, exactly $m+1$ residues are squares
> (counting $0$) and exactly $m$ are not.

<details>
<summary><b>Click for the character-sum proof.</b></summary>

Let $\chi$ be the quadratic character: $\chi(0) = 0$, $\chi(a) = +1$ on nonzero squares,
$\chi(a) = -1$ on non-squares. (This trichotomy needs the characteristic to differ from $2$.) The
character is nontrivial, so by orthogonality it sums to zero over all of $\mathbb{Z}/p$. Split that
vanishing sum along the square / non-square partition. The non-square half contributes
$-\#\{\text{non-squares}\}$. The square half contributes $\#\{\text{squares}\} - 1$, because $0$ is
a square but contributes $0$ instead of $+1$. Hence
$\#\{\text{squares}\} - 1 - \#\{\text{non-squares}\} = 0$, and since the two classes partition a set
of size $2m+1$ the counts are $m+1$ and $m$.
</details>

So the tie profile is $(m,\ m+1)$ — two blocks, as balanced as an odd number allows. Feed it in:

> **The Prime-Independence Law.** For *every* odd prime modulus, the bare quadratic-residue count
> has ceiling exactly
> $$\rho^2 = \frac{3}{4}, \qquad \rho \le \frac{\sqrt{3}}{2} = 0.866025\ldots$$

<details>
<summary><b>Click to see why the modulus cancels identically.</b></summary>

The whole content is the factorisation
$$m^3 + (m+1)^3 = (2m+1)(m^2+m+1).$$
With $n = 2m+1$ it gives
$$\textstyle\sum_j m_j^3 - n = (2m+1)(m^2+m+1) - (2m+1) = (2m+1)\,m(m+1),$$
while $n^3 - n = (2m+1)\bigl((2m+1)^2 - 1\bigr) = (2m+1)\cdot 4m(m+1)$. The two share the factor
$(2m+1)m(m+1)$, so the quotient is exactly $1/4$ — with the modulus vanishing identically rather
than merely to leading order. That exact cancellation is special to the split $(m, m+1)$.
</details>

Not approximately $3/4$. Not $3/4$ in the limit. **Exactly** $3/4$, for $p = 3$ and for a
500-digit prime alike. All the depth of [quadratic reciprocity](https://en.wikipedia.org/wiki/Quadratic_reciprocity),
all the delicate character-sum estimates that make Legendre symbols look random — none of it
survives contact with the formula, because the ceiling of a two-valued statistic depends only on
how evenly its two classes split.

**First sharp negative result:** since $3/4 < 6/7$, the bare quadratic-residue count is
*structurally* incapable of matching the dial, at every bit-length and every modulus. No choice of
prime helps. No amount of data helps.

---

## 5. Settling the referee's worry — it's a subtraction

The very best the dial could do at 48 bits is $\rho = 0.925820$. The very best the bare baseline
could do, at any prime, is $\rho = 0.866025$. Their difference:

$$0.925820\ldots - 0.866025\ldots = 0.0598 \;<\; 0.06 .$$

> **The Gap Law.** The entire tie-geometry advantage of the dial over the bare quadratic-residue
> count, at bit-length 48 and any odd prime, is less than $0.06$ in correlation units.
>
> **Forced slack.** Since the recorded advantage is $0.09$ to $0.13$, and the dial cannot exceed
> its own ceiling, the baseline's reading must sit at least $0.03$ **below its own ceiling**. The
> margin is not a resolution artefact — it is signal.

Take the console below and check it yourself: load each recorded seed, or invent a reading and see
where the verdict flips.

{{interactive_demo:1}}

> **Push the sliders.** Drop the advantage to $0.05$ and the verdict turns INCONCLUSIVE — that is
> exactly the regime where granularity alone would suffice. Raise the dial reading above $0.9259$
> and the console refuses the reading as impossible: no statistic can exceed its own ceiling.

There is a quieter corollary that anyone running such an experiment should stare at. Compare the
band's top edge, $0.85$, to the two ceilings: the baseline's is $0.8660$, leaving **under $0.017$**
of room; the dial's is $0.9258$, leaving **over $0.075$**.

> **Band-Saturation Asymmetry.** The same nominal interval means "comfortably within reach" for the
> dial and "essentially at the physical limit" for the baseline. A validation band calibrated on one
> statistic is not transportable to the other.

The remedy is to report ceiling-normalised correlations $\rho/\rho_{\max}$, which for the three
recorded seeds read $0.839$, $0.815$ and $0.865$.

---

## 6. Building a better baseline — and the trap on the way

If one Legendre symbol cannot compete, use several. By the
[Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem) the classes
multiply, and both the population size and the cube sum are multiplicative:

> **Multiplicative Tower Law.** For primes $p_i = 2m_i+1$, the joint Legendre *vector* has ceiling
> $$1 - \frac{\prod_i \bigl(m_i^3+(m_i+1)^3\bigr) - N}{N^3 - N}, \qquad N = \prod_i (2m_i+1),$$
> with no interaction term between the primes at all.

But there is a wrong way to combine them, and it is the way everyone reaches for first: *add the
symbols up* and record how many came out "square". That is a coarsening, so by cube-sum
monotonicity it can only lower the ceiling.

> **Counting Collapse.** For any list of primes, the ceiling of the Legendre *count* is at most the
> ceiling of the Legendre *vector*.

The difference is not subtle. At the primes $3$ and $5$: the vector has profile $(2,3,4,6)$ and
ceiling $51/56 = 0.9107$; the count has profile $(6,7,2)$ and ceiling $117/140 = 0.8357$. Summing
throws away nearly eight points.

And this reshapes the entire crossover story at bit-length 48:

| Baseline | Ceiling $\rho^2$ | Versus the dial ($6/7$) |
|---|---|---|
| One Legendre symbol | $3/4 = 0.7500$ | below |
| Two symbols, counted | $117/140 = 0.8357$ | below |
| **Trailing-zero dial, 48 bits** | $6/7 = 0.8571$ | — |
| Three symbols, counted | $2433/2756 = 0.8828$ | above |
| Two symbols, as a vector | $51/56 = 0.9107$ | above |

> **Crossover Hierarchy.** Three Legendre symbols are needed before a quadratic-residue *count*
> can, on tie geometry alone, out-resolve the dial — but only two suffice if kept as a vector.

Here is the whole hierarchy drawn to scale, with the recorded readings placed against both
ceilings:

{{visualization:0}}

And here is how resolution grows as you add symbols — together with the widening penalty for
summing them, and the near-perfect flatness of the dial's own ceiling across the deployment
envelope:

{{visualization:1}}

<details>
<summary><b>Click for the closed form of the replicated tower.</b></summary>

Take $r$ Legendre symbols at the prime $3$ and keep them as a vector. Then $N = 3^r$ and the cube
sum is $9^r$, so
$$\rho^2 = 1 - \frac{9^r - 3^r}{27^r - 3^r} \;\ge\; 1 - \frac{2}{3^{\,r}},$$
the lower bound following from $\frac{2}{x} - \frac{x^2-x}{x^3-x} = \frac{x^2+x-2}{x^3-x} \ge 0$
with $x = 3^r$. Two symbols already reach $0.9$; the convergence to $1$ is geometric. So the
quadratic-residue baseline is capped only in its *bare, one-symbol* form. The cap is a property of
how much you record, not of what quadratic residues are.
</details>

---

## 7. The machinery, in three routines

Everything above is exactly computable in rational arithmetic. First the primitive that every other
result calls — the ceiling itself, plus the coarsening operation:

{{algorithm:0}}

Next, the two encodings of a Legendre tower. Note the complexity asymmetry: the vector profile
costs $O(2^r)$ to build and the count profile only $O(r^2)$ — the cheap encoding is precisely the
one that is provably worse.

{{algorithm:1}}

Finally the audit itself, which turns a pair of recorded correlations into a verdict:

{{algorithm:2}}

---

## 8. Run the whole thing

The script below reproduces every number in this page in exact rational arithmetic, and checks each
one with an assertion — including brute-force recomputations of both tie profiles from their raw
definitions, so that no closed form is taken on trust.

{{demo:0}}

---

## 9. What the ceiling is really telling us

Step back and a general principle appears. Every statistic carries an intrinsic resolution,
computable in closed form from nothing but the sizes of its level sets, and that resolution bounds
every correlation it will ever produce. Two consequences pull in opposite directions.

**The pessimistic one.** A coarse statistic will look bad against a fine one no matter how good it
is. Comparisons between statistics of different granularity are not comparisons of merit until the
ceilings are quotiented out.

**The optimistic one.** Because the ceiling is exactly computable, that quotient *can* be taken.
Here it was, and the dial survived: the recorded margin exceeds the maximum geometric advantage by
a factor of at least $1.5$, forcing at least $0.03$ of genuine shortfall on the baseline.

A caveat worth stating plainly: none of this explains *why* the 2-adic valuation of a uniform draw
should couple to a downstream success rate. It establishes only that the coupling is not an
accounting illusion. That question — the mechanism — is the more interesting one, and it is still
open.

The final irony is worth savouring. The Legendre symbol is one of the great objects of number
theory, a two-century-old source of pseudo-randomness we are still mining. The trailing-zero count
is a single machine instruction. And on this measurement, at this bit-length, the machine
instruction wins — not because the arithmetic is shallow, but because a two-valued statistic,
however profound, has only two values to spend, and the ceiling formula does not care where those
values came from.
