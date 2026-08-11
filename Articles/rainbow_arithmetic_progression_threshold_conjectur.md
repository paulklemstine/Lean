# The Rainbow at the End of the Coupon Collector

*How a children's card-collecting problem pins down, to the exact leading constant, when a random colouring of the integers is forced to show every pattern.*

---

## A stadium full of colours

Imagine you are painting the integers. You have $k$ tins of paint — say red, green, blue — and you walk along the number line, choosing a colour for each integer at random, independently, uniformly. Behind you stretches a long ribbon of colour.

Now step back and look at the ribbon not one square at a time, but two squares at a time: $(0,1)$, $(2,3)$, $(4,5)$, and so on. Each such consecutive pair carries an *ordered pair of colours*: (red, green), (blue, blue), (green, red), $\dots$. With $k$ colours there are exactly $k^2$ possible ordered pairs. A natural question, and the one this article is about:

> **How long a stretch of the number line do you have to paint before, with probability better than one half, *every one* of the $k^2$ colour pairs appears somewhere?**

Call that length — measured in pairs, i.e. in blocks — the *rainbow pair-spectrum threshold* $T_k$. It is a precise number for each $k$, and it turns out to have a startlingly clean answer:

$$T_k = 2k^2 \log k + O(k^2), \qquad \frac{T_k}{k^2 \log k} \longrightarrow 2 .$$

Not $\Theta(k^2 \log k)$ with unknown constants hiding inside — the constant is exactly $2$, and it is $2$ both in the limit inferior and the limit superior, so there is no oscillation, no hidden subsequence behaving differently. And the whole story, once set up correctly, is the story of the *coupon collector*.

## Why "rainbow"?

The word *rainbow* is combinatorial slang. A structure is rainbow if all its parts get **different** colours. A rainbow arithmetic progression of length $l$ is a progression $a, a+d, \dots, a+(l-1)d$ all of whose terms receive distinct colours. Rainbow Ramsey theory asks the reverse of ordinary Ramsey theory: instead of "any colouring contains a monochromatic pattern", it asks "when must a colouring contain a *totally multicoloured* pattern?".

A pair $(x, x+1)$ is the shortest interesting arithmetic progression: two terms with common difference $1$. It is rainbow exactly when the two colours differ. So collecting all $k^2$ ordered pairs is a strictly harder demand than merely finding one rainbow pair: it forces every pattern to appear, monochromatic ones included, and among those patterns are all the rainbow ones. Once you have collected the full spectrum of patterns, rainbow structures come for free — and this is a theorem we will state precisely below.

## The coupon collector in disguise

Here is the reframing that makes everything work. Forget colours for a moment. A block of $l$ consecutive integers coloured with $k$ colours carries a *pattern*: a function from the $l$ positions to the $k$ colours. There are $N = k^l$ such patterns. A random colouring, read block by block, is nothing but a **uniformly random word of length $m$ over an alphabet of size $N$**.

And "every pattern appears" is exactly "the word uses every letter of the alphabet" — the word is *surjective*, or in the terminology we use throughout, it has **full spectrum**.

So the entire problem becomes: *how long must a random word over an $N$-letter alphabet be before it is more likely than not to contain every letter?* That is the coupon collector's problem, with a majority-probability stopping rule rather than an expectation. For $l = 2$ we have $N = k^2$, and the classical coupon-collector heuristic $N \log N$ becomes $k^2 \log(k^2) = 2k^2\log k$ — there is the constant $2$, hiding in plain sight inside a logarithm.

The mathematical work is to turn this heuristic into a theorem with *proved* two-sided bounds, and to make the constants explicit, computable, and small.

## Counting the letters you missed

Everything follows from one simple random variable. For a word $f$ of length $m$ over an alphabet $\alpha$ with $N$ letters, let

$$\mathrm{miss}(f) = \#\{a \in \alpha : a \text{ does not occur in } f\}$$

be the number of **missed letters**. Full spectrum means $\mathrm{miss}(f) = 0$.

The reason this variable is so powerful is that its *binomial moments* can be computed exactly — not asymptotically, not up to error terms, but on the nose. Here is the identity at the heart of the whole development.

> **Theorem (Binomial Moment Identity).** For every $r \ge 0$ and every $m \ge 0$,
> $$\sum_{f : \{1,\dots,m\} \to \alpha} \binom{\mathrm{miss}(f)}{r} \;=\; \binom{N}{r}\,(N-r)^m .$$

The proof is a single change of perspective. The left side counts pairs consisting of a word $f$ together with a set $S$ of $r$ letters, all of which $f$ misses. Count those pairs the other way round: choose the $r$-element set $S$ first — $\binom{N}{r}$ ways — and then choose a word which avoids every letter of $S$, which is a word over the remaining $N - r$ letters, so $(N-r)^m$ ways. Two ways of counting the same thing; identity proved. It is the classical double-counting move, executed once, and it delivers *all* moments at once.

Divide by $N^m$ to read it probabilistically: for a uniformly random word,

$$\mathbb{E}\binom{\mathrm{miss}}{r} = \binom{N}{r}\Bigl(1 - \frac{r}{N}\Bigr)^{m} \;\approx\; \frac{1}{r!}\bigl(N e^{-m/N}\bigr)^{r},$$

which is precisely the binomial-moment sequence of a **Poisson** random variable with mean $\lambda = Ne^{-m/N}$. The number of missed letters is Poisson, and everything about the threshold is dictated by when that Poisson mean crosses the value $\log 2$ — the point at which $\mathbb{P}(\text{Poisson} = 0) = e^{-\lambda}$ crosses $1/2$.

The two cases $r = 1$ and $r = 2$ are the workhorses:

$$\sum_f \mathrm{miss}(f) = N(N-1)^m, \qquad \sum_f \mathrm{miss}(f)^2 = N(N-1)^m + N(N-1)(N-2)^m .$$

## Two criteria, squeezing from both sides

With exact moments in hand, two classical inequalities give matching bounds.

**The first moment squeezes from above.** Every word that misses something misses *at least one* letter, so the number of deficient words is at most the total number of missed letters, $N(N-1)^m$. If twice that is smaller than the total number of words, the deficient words are a minority:

> **Union-bound criterion.** If $2N(N-1)^m < N^m$, then strictly more than half of all words of length $m$ have full spectrum.

**The second moment squeezes from below.** Cauchy–Schwarz says that for any collection of nonnegative numbers, the square of the sum is at most the count times the sum of squares. Applied to $\mathrm{miss}$ over the deficient words, whose count we call $D_m$:

$$\bigl(N(N-1)^m\bigr)^2 \;\le\; D_m \cdot \bigl(N(N-1)^m + N(N-1)(N-2)^m\bigr).$$

A short piece of algebra — using nothing more than $N(N-2) \le (N-1)^2$ — converts this into:

> **Second-moment criterion.** If $N^m < (N+1)(N-1)^m$, then strictly more than half of all words of length $m$ are *deficient*: some letter is missing.

The two criteria bracket the transition. The first fires once $m > N\log(2N)$; the second holds as long as $m < (N-1)\log(N+1)$. Both of these are $N \log N (1 + o(1))$.

## The transition happens exactly once

There is a subtlety worth pausing on. Defining the threshold as *the smallest $m$ at which the majority is surjective* is only meaningful if the majority, once achieved, is never lost. In principle a strange sequence could dip back below one half.

It does not, and the reason is a lovely one-line injection. Take any full-spectrum word of length $m$ and append any letter you like: the result is a full-spectrum word of length $m+1$, and distinct choices give distinct words. Hence if $S_m$ denotes the number of full-spectrum words of length $m$,

$$N \cdot S_m \le S_{m+1}.$$

The total number of words also multiplies by exactly $N$ when the length grows by one. So the *proportion* of full-spectrum words never decreases. Consequently:

> **Theorem (Genuine Phase Transition).** For an alphabet of $N \ge 2$ letters, the majority of words of length $m$ have full spectrum **if and only if** $m \ge T$, where $T$ is the full-spectrum threshold. The property is upward closed: the transition happens exactly once.

This is what upgrades "the smallest $m$ with a certain property" from a definition to a *threshold* in the physical sense — a single sharp crossing, like water freezing.

## The main theorem

Turning the two criteria into real-analytic statements — using $\log(1 + x) \le x$ on one side and $1 - x \le e^{-x}$ on the other — gives the following, for every alphabet with $N \ge 2$ letters:

$$(N-1)\log(N+1) \;\le\; T \;\le\; N \log(2N) + 1 .$$

Equivalently, in the sharpest form:

> **Theorem (Sharp Window).** The full-spectrum threshold of an $N$-letter alphabet satisfies
> $$\bigl| T - N \log N \bigr| \;\le\; N \log 2 + \log N + 1 .$$

The threshold is $N \log N$ with an error of order $N$ — a whole factor of $\log N$ smaller than the main term. That is what makes the leading constant *exactly* determined.

Now specialise to pairs: $N = k^2$, and $T_k$ is the pair-spectrum threshold with $k$ colours.

> **Theorem (Rainbow Pair-Spectrum Threshold).** For all $k \ge 2$,
> $$2k^2\log k - 2\log k \;\le\; T_k \;\le\; 2k^2\log k + k^2 \log 2 + 1,$$
> so that $\bigl|T_k - 2k^2\log k\bigr| \le k^2\log 2 + 2\log k + 1$, and consequently
> $$\lim_{k\to\infty}\frac{T_k}{k^2\log k} = 2 .$$
> Both the limit inferior and the limit superior of $T_k/(k^2\log k)$ equal $2$.

This settles the original question — the growth is $\Theta(k^2\log k)$ with computable constants — in the strongest possible form. One can take explicit constants $c_1 = 1$ and $c_2 = 4$, valid for *every* $k \ge 2$:

$$1 \cdot k^2\log k \;\le\; T_k \;\le\; 4\cdot k^2\log k,$$

comfortably inside the demanded range $0.1 \le c_1 \le c_2 \le 10$. And for $k \ge 100$ the constants tighten to within ten percent of optimal:

$$1.9\,k^2 \log k \;\le\; T_k \;\le\; 2.2\, k^2\log k .$$

## Small numbers, and a surprise in the second digit

The abstract bounds are matched by explicit small-case windows: $T_2 \in [6,8]$, $T_3 \in [20, 25]$, $T_4 \in [44, 54]$, each obtained from the two criteria plus monotonicity, by pure integer arithmetic on numerals. Direct inclusion–exclusion pins the exact values:

| $k$ | $N = k^2$ | $T_k$ | $T_k / (k^2 \log k)$ | $(T_k - N\log N)/N$ |
|---|---|---|---|---|
| 2 | 4 | 7 | 2.53 | 0.364 |
| 3 | 9 | 23 | 2.33 | 0.358 |
| 4 | 16 | 51 | 2.30 | 0.415 |
| 5 | 25 | 90 | 2.24 | 0.381 |
| 6 | 36 | 142 | 2.20 | 0.361 |
| 8 | 64 | 290 | 2.18 | 0.372 |

Two things leap out. First, the ratio in the fourth column really is drifting down towards $2$, slowly, as $\log k$ grows. Second — and this is where the story points forward — the last column is not drifting at all. It hovers around $0.366$.

That number is not an accident. Recall that $\mathrm{miss}$ is asymptotically Poisson with mean $N e^{-m/N}$, and the probability of full spectrum is therefore about $\exp(-Ne^{-m/N})$. This crosses $1/2$ exactly when $N e^{-m/N} = \log 2$, i.e. when

$$m = N \log N + N \log\frac{1}{\log 2} = N\log N + 0.36651\ldots \times N .$$

The numerics sit exactly on that prediction. The proved window has width $N\log 2 + O(\log N) \approx 0.693 N$; the truth sits at $0.3665N$ inside it. Nailing that second-order constant — replacing the Cauchy–Schwarz step by a third-order Bonferroni expansion, for which the exact moment identity above supplies every ingredient — is the obvious next target.

## Back to the rainbow

We began with colourings of the integers, and it is worth closing the loop. The dictionary between words and colourings is explicit: from a colouring $\chi$ of the nonnegative integers with $k$ colours, and parameters $l$ and $m$, form the **block word** whose $t$-th letter is the pattern $j \mapsto \chi(lt + j)$, for $t = 0, \dots, m-1$ and $j = 0,\dots,l-1$. This is a word of length $m$ over the alphabet of $k^l$ patterns, and it records precisely the colouring of the interval $[0, lm)$ read as $m$ consecutive $l$-term progressions of common difference $1$.

> **Theorem (Full Spectrum Forces a Rainbow).** Suppose $l \le k$. If a word of length $m$ over the alphabet of $l$-patterns has full spectrum, then one of its letters is an *injective* pattern. Consequently, if the block word of a $k$-colouring $\chi$ has full spectrum, then $\chi$ contains a genuine rainbow $l$-term arithmetic progression inside $[0, lm)$.

The proof is disarming: among the $k^l$ patterns, when $l \le k$, one of them is the injection $j \mapsto j$. Full spectrum means every pattern occurs, so *that* pattern occurs, and the block where it occurs is a rainbow progression. Hence, above the union-bound threshold, a strict majority of all colourings already contains a rainbow $l$-term progression in the first $lm$ integers.

Finally the whole family: writing $P(l,k)$ for the threshold at pattern length $l$, the same two-sided estimates give

$$(k^l - 1)\log(k^l + 1) \;\le\; P(l,k) \;\le\; k^l \log(2k^l) + 1,$$

so $P(l,k) = \Theta\bigl(k^l \log(k^l)\bigr) = \Theta(l\, k^l \log k)$ for every $l$. The case $l = 2$ is our $\Theta(k^2 \log k)$; the case $l = k$ gives the vertiginous $\Theta(k^{k+1}\log k)$. One estimate, uniform in the alphabet, covers the entire hierarchy.

## What the coupon collector taught us

The moral of this story is that a good change of variables is worth a dozen clever estimates. The rainbow arithmetic-progression question looks like Ramsey theory: hard, combinatorial, resistant to exact constants. Recast in terms of block patterns it becomes coupon collecting, where the moments of the missed-letter count are *exactly* computable by double counting, and where two lines of Cauchy–Schwarz nail the transition to within a factor of $1 + O(1/\log N)$.

What is perhaps most satisfying is how *rigid* the answer turns out to be. Not just $\Theta(k^2 \log k)$, but a limit; not just a limit along a subsequence, but a genuine one, with limit inferior and limit superior both equal to $2$; not just a smallest $m$, but a real phase transition crossed exactly once. And beyond the leading constant, the numerics whisper the next term, $\log(1/\log 2)$, waiting to be proved.

Behind every rainbow, apparently, there is a coupon collector.
