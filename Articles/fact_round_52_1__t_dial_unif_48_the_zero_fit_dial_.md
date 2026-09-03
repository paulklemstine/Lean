# The Ceiling in the Room: Why a Coarse Ruler Can Never Measure a Fine Thing

## A dial, a rate, and a suspicion

Somewhere inside a cryptographic pipeline there is a knob. Turn it, and a downstream
success rate goes up or down. The knob is embarrassingly cheap to read: given a
48-bit integer $x$, count how many zeros sit at the bottom of its binary expansion
before the first $1$. Call that number $T(x)$. If $x$ ends in `...1011000`, then
$T(x) = 3$. Number theorists know $T$ under a grander name — it is the **2-adic
valuation** $v_2(x)$, the exponent of the largest power of two dividing $x$ — but the
implementer knows it as a single machine instruction.

The empirical claim, measured three times on three independent random seeds over
uniformly drawn 48-bit integers, is that $T$ tracks the downstream rate with a
Spearman rank correlation of

$$\rho = 0.777, \qquad 0.755, \qquad 0.801 .$$

Three seeds, three readings, all inside the pre-registered validation band
$[0.55,\,0.85]$, spread under $0.05$. That is a stable dial.

But a good referee is a suspicious referee, and here is the suspicion. Any single
number, however impressive, means very little on its own; what matters is whether it
beats a *baseline*. The natural arithmetic baseline for a bitstring statistic is
not another bitstring statistic — it is a **quadratic residue count**. Pick an odd
prime $p$; for each drawn integer, ask whether it is a perfect square modulo $p$;
record $1$ if yes and $0$ if no. This is the Legendre symbol, the oldest
pseudo-random bit in number theory, and it has the reputation to match. Against
this baseline, $T$ wins on every seed, by between $+0.09$ and $+0.13$ of correlation.

And now the suspicion sharpens into a genuine worry. The QR baseline is a
*two-valued* statistic. It carves the whole population into two enormous groups —
squares and non-squares — and inside each group it says nothing at all. The dial
$T$, by contrast, is *many*-valued: half the integers have $T = 0$, a quarter have
$T = 1$, an eighth have $T = 2$, and so on down to a lonely single value at the
bottom. When you compute a rank correlation with a statistic that has huge blocks of
tied values, those ties mechanically drag the correlation down, regardless of whether
the statistic is any good. A coarse ruler measures a fine thing badly *for reasons of
geometry, not of substance*.

So: is $T$'s $0.09$-to-$0.13$ margin real signal, or is it just the QR baseline being
handicapped by its own coarseness?

The results below answer that question exactly, with no statistics and no
simulation — only algebra.

## The ceiling

Here is the pivotal observation. Fix a statistic $S$ on a population of $n$ items.
Suppose $S$ takes some finite set of values, and let $m_1, m_2, \dots, m_k$ be the
sizes of the groups of items sharing each value. Call the list
$(m_1, \dots, m_k)$ the **tie profile** of $S$; note that $\sum_j m_j = n$.

Then there is a hard cap on how well $S$ can rank-correlate with *anything at all*:

> **Tie-Ceiling Theorem.** For any statistic with tie profile $(m_1,\dots,m_k)$ on a
> population of size $n \ge 2$, the squared Spearman correlation with any other
> variable satisfies
> $$\rho^2 \;\le\; 1 \;-\; \frac{\sum_j m_j^3 \;-\; n}{n^3 - n}.$$

The right-hand side is the **tie ceiling** of the profile. If every group is a
singleton, then $\sum_j m_j^3 = n$ and the ceiling is $1$: a perfectly fine ruler
can, in principle, measure perfectly. If everything is tied into one block, then
$\sum_j m_j^3 = n^3$ and the ceiling is $0$: a statistic that says nothing measures
nothing.

Notice the remarkable economy of this formula. Of everything one might know about a
statistic — what it means, how it is computed, what deep theorem governs it — the
ceiling sees exactly one number: the **cube sum** $\sum_j m_j^3$. Everything else
cancels. This gives an immediate comparison rule:

> **Cube-Sum Monotonicity.** If two statistics live on the same population size and
> the first has the smaller cube sum, then the first has the higher ceiling. Coarsening
> a statistic — merging two of its value classes — always increases the cube sum
> (because $(a+b)^3 > a^3 + b^3$), and therefore always lowers the ceiling.

That last clause is the moral engine of everything that follows. Losing information
can never raise your ceiling.

## The dial's ceiling: $6/7$, essentially forever

Apply this to $T$. Among the $N = 2^b$ integers with $b$ bits, exactly $N/2$ have
$T = 0$, exactly $N/4$ have $T = 1$, and so on, with a single leftover at the bottom.
The tie profile is
$$\Bigl(\tfrac{N}{2},\ \tfrac{N}{4},\ \dots,\ 2,\ 1,\ 1\Bigr),$$
a geometric cascade. Its cube sum is a geometric series, and the algebra collapses
beautifully:

> **Dyadic Ceiling.** The trailing-zero statistic at bit-length $b$, with $N = 2^b$,
> has tie ceiling exactly
> $$\rho^2 \;\le\; \frac{6}{7}\left(1 + \frac{1}{N(N+1)}\right).$$

At $b = 48$ the correction term is smaller than $10^{-28}$. For every practical
purpose the ceiling is $6/7 = 0.857142\ldots$, and in correlation units
$$\rho \le \sqrt{6/7} = 0.925820\ldots$$

The factor $6/7$ deserves a moment. It comes from the identity
$1 + 8 + 64 + \cdots = \frac{1}{1 - 1/8}$: the cube sum of a halving cascade is
$\frac{1}{7}$ of $N^3$, so a seventh of the available "resolution" is destroyed by
ties, and six-sevenths survives. The number $6/7$ is not a fitted constant; it is
the fingerprint of the number $2$.

The consequence for the experimental program is immediate. Across the whole recorded
deployment envelope — bit-lengths $44$ through $52$ — the ceiling *does* strictly
decrease with $b$, but it moves by less than $2^{-80}$. Whatever bit-length dependence
the dial exhibits in practice, it is not tie geometry. Geometry, at these scales, is a
constant.

## The baseline's ceiling: $3/4$, exactly, for every prime

Now the quadratic residue baseline. Modulo an odd prime $p$, how many residues are
squares? The classical answer comes from the quadratic character
$\chi(a) = \left(\frac{a}{p}\right)$, which is $+1$ on nonzero squares, $-1$ on
non-squares, and $0$ at the origin — and which sums to zero over the whole of
$\mathbb{Z}/p$. Splitting that vanishing sum into its two halves gives
$(\#\text{squares} - 1) - \#\text{non-squares} = 0$, so:

> **Arithmetic Bridge.** Modulo an odd prime $p = 2m+1$, exactly $m+1$ residues are
> squares (counting $0$) and exactly $m$ are not.

So the QR indicator's tie profile is $(m,\ m+1)$ — two blocks, as balanced as an odd
number allows. Feed it into the ceiling formula with $n = 2m+1$ and
$\sum_j m_j^3 = m^3 + (m+1)^3$. The cubic terms conspire, and out comes something
strikingly clean:

> **Prime-Independence Law.** For *every* odd prime modulus, the bare quadratic
> residue count has tie ceiling exactly
> $$\rho^2 = \frac{3}{4}, \qquad \text{i.e.} \qquad \rho \le \frac{\sqrt{3}}{2} = 0.866025\ldots$$

Not approximately $3/4$; not $3/4$ in the limit of large $p$. Exactly $3/4$, for
$p = 3$ and for $p = 2^{521} - 1$ alike. The modulus cancels entirely. All the
arithmetic depth of quadratic reciprocity, all the delicate character-sum estimates
that make Legendre symbols look random — none of it survives contact with the ceiling
formula, because the ceiling of a two-valued statistic depends only on how evenly the
two classes split, and the Legendre split is always as even as it can be.

This is the first sharp negative result. The bare QR baseline is *structurally*
incapable of matching the dial. Its ceiling $3/4$ sits below the dial's $6/7$ at
every bit-length and every modulus. No choice of prime helps. No amount of data
helps.

## The gap law: the margin is real

Now we can settle the referee's worry, and the answer is a subtraction.

The very best the dial could possibly do at bit-length 48 is $\rho = 0.925820$.
The very best the bare QR baseline could possibly do, at any prime, is
$\rho = 0.866025$. The difference is
$$0.925820\ldots - 0.866025\ldots = 0.0598 \;<\; 0.06 .$$

> **Gap Law.** The entire tie-geometry advantage of the trailing-zero dial over the
> bare quadratic residue count, at bit-length 48 and any odd prime modulus, is less
> than $0.06$ in correlation units.

The recorded advantage is $0.09$ to $0.13$. Tie geometry can supply at most two
thirds of the smaller of those, and less than half of the larger. Therefore:

> **The recorded gap forces slack.** If the dial's measured reading sits at or below
> its own ceiling — which it must — and it beats the baseline by at least $0.09$, then
> the baseline's reading must lie at least $0.03$ *below its own ceiling*. The
> baseline is not merely handicapped; it is genuinely underperforming, with room to
> spare that it fails to use.

That is the punchline. The dial's margin is not a resolution artefact. It is signal.
Whatever coupling exists between the 2-adic valuation and the downstream rate, it is
a coupling that Legendre symbols do not share, and the difference is measured in
substance, not in granularity.

## Two calibrations that cannot be swapped

There is a quieter corollary that anyone running such an experiment should stare at.
The pre-registered validation band was $[0.55,\,0.85]$. Compare its top edge to the
two ceilings:

- The QR baseline's ceiling is $0.8660$. The top of the band is $0.85$. The band
  leaves the baseline **less than $0.017$** of room — it is nearly saturating.
- The dial's ceiling is $0.9258$. The band leaves the dial **more than $0.075$**
  of room.

> **Band-Saturation Asymmetry.** A validation band calibrated on one of these two
> statistics is not transportable to the other. The same nominal interval represents
> "comfortably within reach" for the dial and "essentially at the physical limit" for
> the baseline.

This is a general methodological hazard dressed up in a specific example. When two
estimators have different intrinsic ceilings, a fixed acceptance interval silently
imposes two different standards.

## How to build a better baseline — and how not to

If one Legendre symbol cannot compete, use several. Take primes $p_1, \dots, p_r$
and record the whole *vector* of symbols. By the Chinese Remainder Theorem the
classes multiply: the tie profile of the joint statistic is the set of all products of
one block size from each factor. Both the population size and the cube sum are
therefore multiplicative, with no interaction term at all:

> **Multiplicative Tower Law.** For primes $p_i = 2m_i + 1$, the joint Legendre
> vector has ceiling
> $$1 - \frac{\prod_i \bigl(m_i^3 + (m_i+1)^3\bigr) - N}{N^3 - N}, \qquad N = \prod_i (2m_i+1).$$

But there is a wrong way to combine them, and it is the way everyone reaches for
first: *add the symbols up* and record how many of the $r$ tests came out "square."
That is a coarsening — many distinct vectors collapse into the same count — so by
cube-sum monotonicity it can only lower the ceiling:

> **Counting Collapse.** For any list of prime moduli, the ceiling of the QR *count*
> is at most the ceiling of the QR *vector*.

The quantitative difference is not subtle. Take the primes $3$ and $5$. The vector
has profile $(2,3,4,6)$ on $15$ residues and ceiling $51/56 = 0.9107$. The count has
profile $(6,7,2)$ and ceiling $117/140 = 0.8357$. Summing throws away nearly eight
points of ceiling.

And this reshapes the whole crossover story at bit-length 48, where the dial's
ceiling is $6/7 = 0.8571$:

| Baseline | Ceiling $\rho^2$ | Versus the dial |
|---|---|---|
| One Legendre symbol | $3/4 = 0.7500$ | below |
| Two symbols, counted | $117/140 = 0.8357$ | below |
| **Trailing-zero dial, 48 bits** | $6/7 = 0.8571$ | — |
| Three symbols, counted | $2433/2756 = 0.8828$ | above |
| Two symbols, as a vector | $51/56 = 0.9107$ | above |

> **Crossover Hierarchy.** Three Legendre symbols are needed before a QR *count* can,
> on tie geometry alone, out-resolve the trailing-zero dial at bit-length 48 — but only
> two suffice if the symbols are kept as a vector.

Finally, the ceiling is not a permanent cap on the arithmetic side. Take $r$
independent Legendre symbols at the prime $3$ and keep them as a vector; the closed
form is
$$\rho^2 = 1 - \frac{9^r - 3^r}{27^r - 3^r} \;\ge\; 1 - \frac{2}{3^{\,r}},$$
which races to $1$ geometrically. Two symbols already give $0.9$. The quadratic
residue baseline is capped only in its bare, one-symbol form; the cap is a property of
*how much you record*, not of *what quadratic residues are*.

## What the ceiling is really telling us

Step back from the cryptographic specifics and a general principle is visible. Every
statistic carries an intrinsic resolution, computable in closed form from nothing but
the sizes of its level sets, and that resolution bounds every correlation it will ever
produce. Two consequences follow, and they pull in opposite directions.

The pessimistic one: a coarse statistic will look bad against a fine one no matter how
good it is, so comparisons between statistics of different granularity are not
comparisons of merit until the ceilings are quotiented out.

The optimistic one: because the ceiling is exactly computable, that quotient can be
taken. Here it was taken, and the dial survived — the recorded margin exceeds the
maximum geometric advantage by a factor of at least $1.5$, and the shortfall it forces
on the baseline is at least $0.03$.

The final irony is worth savouring. The Legendre symbol is one of the great objects of
number theory, a two-century-old source of pseudo-randomness whose depth we are still
mining. The trailing-zero count is a single machine instruction. And on this
particular measurement, at this particular bit-length, the machine instruction wins —
not because the arithmetic is shallow, but because a two-valued statistic, however
profound, has only two values to spend, and the ceiling formula does not care where
those values came from.
