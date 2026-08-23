# The Ceiling in the Instrument

## Why a perfectly good diagnostic can never score above $0.926$ — and why that is the best news you'll get all week

---

### A ruler with 53 marks

Suppose you hand someone a wooden ruler that has only 53 marks on it, and ask them to measure the length of a table to the nearest millimetre. They will fail, and it will not be their fault. The failure is *in the instrument*. No amount of care, no better eyesight, no steadier hand recovers information that the marks were never fine enough to carry.

Statistics has the same problem, and it is much less obvious there, because a correlation coefficient does not announce that it is being throttled by its own granularity. It just comes back low. And a low number invites a story — "the effect is weak," "the feature doesn't matter," "the model isn't learning" — when the honest explanation may be that the instrument had a ceiling and the measurement hit it.

This article is about computing those ceilings exactly. It turns out you can, they have beautiful closed forms, and once you know them, several intuitions about which measurements are trustworthy flip over completely.

---

### The dial

Here is the concrete setting. A monitoring system draws 52-bit integers — machine words, hash outputs, sampled counters, whatever your pipeline produces — and computes a very cheap number from each one: **how many binary zeros does it end in?** A word ending in `...11010` has one trailing zero. A word ending in `...101000` has three. An odd word has none.

Number theorists call this the **2-adic valuation** $v_2(x)$; engineers call it a *trailing-zero count*, and every modern processor computes it in one instruction. Call it the **dial**.

The dial is used as a diagnostic: does it track some downstream quantity of interest — a failure rate, a latency, a collision count? To answer that, you rank the sample by the dial, rank it by the response, and compute the correlation between the two rank orderings. That is **Spearman's rank correlation** $\rho$, the workhorse of monotone-association testing. It is scale-free, outlier-robust, and it does not care about the shape of either distribution.

Three independent runs of that measurement at 52-bit word length returned

$$\rho = 0.698, \qquad 0.697, \qquad 0.720,$$

pooling to $\rho \approx 0.705$. Against an obvious alternative diagnostic — the **count**, meaning the number of $1$-bits in the word, its Hamming weight — the dial came out ahead by $+0.070$, with a confidence interval of $[0.046,\, 0.093]$ that comfortably excludes zero.

So the dial wins. But *why* does it win, and is the win real?

---

### Ties, and the price you pay for them

Here is the difficulty. Both statistics take very few distinct values. On $b$-bit words there are $2^b$ possible inputs, but the trailing-zero count only ever returns one of $b+1$ answers, and so does the Hamming weight. At $b = 52$ that is four and a half quadrillion inputs mapped onto **53** outputs.

When you rank a sample and enormous batches of points share a value, the standard remedy is *midranks*: every member of a tied group receives the average of the ranks the group occupies. Midranks are fair, but they are also lossy — they deliberately erase the within-group ordering, because there isn't one.

The cost is precisely quantifiable. If the statistic's tie structure is described by its **tie profile** — the list $L = (m_1, m_2, \dots, m_K)$ of tie-class sizes, summing to the sample size $n$ — then the **tie correction**

$$C(L) \;=\; \sum_{j=1}^{K} \frac{m_j^3 - m_j}{12}$$

is exactly the variance the midranking destroys. And this yields the central object of the story. Even against a *perfect* response — one that orders the sample as finely as the statistic possibly permits, breaking no tie the wrong way — the squared Spearman correlation cannot exceed

$$\boxed{\;\rho^2_{\max}(L) \;=\; 1 \;-\; \frac{12\,C(L)}{n^3 - n}\;}$$

Call this the **tie ceiling**. It depends on nothing about the response, nothing about the science, nothing about the sample values. It depends only on the *shape* of the tie profile — in fact only on the single number $\sum_j m_j^3$. It is a property of the instrument, printed on the instrument, and it can be computed before any data is collected.

Sanity checks: with no ties at all, $L = (1,1,\dots,1)$ and $C(L) = 0$, so the ceiling is $1$ — a perfect instrument. With everything tied, $L = (n)$, the correction is maximal and the ceiling is exactly $0$ — a constant statistic tells you nothing. Everything interesting lives in between.

---

### The dial's ceiling is $6/7$, and it does not care how big your words are

Now compute the dial's profile. Among $2^b$ uniformly drawn $b$-bit words, exactly half are odd — trailing-zero count $0$. A quarter end in exactly one zero. An eighth end in exactly two. And the lone word $0$ sits alone in its own class. The profile is a perfect geometric cascade:

$$L_{\mathrm{dyadic}}(b) \;=\; \bigl(2^{b-1},\, 2^{b-2},\, \dots,\, 4,\, 2,\, 1,\, 1\bigr).$$

Plug that into the ceiling formula. The cube sum is a geometric series, $\sum_{k=0}^{b-1} 8^k + 1 = \frac{8^b-1}{7} + 1$, and after the algebra collapses — writing $n = 2^b$ — one gets something startlingly clean:

> **The Dyadic Ceiling Theorem.** *For every word length $b \ge 1$, the trailing-zero statistic on uniformly drawn $b$-bit words has tie ceiling exactly*
> $$\rho^2_{\max} \;=\; \frac{6}{7}\left(1 + \frac{1}{2^b\,(2^b+1)}\right).$$

Two things about this deserve a pause.

First, it is *exact*, not an estimate — a rational number, for every $b$.

Second, the correction term is microscopic and the answer is essentially **$6/7$ forever**. At $b=4$ the ceiling is $0.8603$; at $b = 16$ it is $0.85714286$; at $b=52$ it differs from $6/7$ in the thirty-second decimal place. Doubling your word length buys you nothing. The dial's ceiling on the correlation scale is

$$\rho_{\max} \;=\; \sqrt{6/7} \;=\; 0.9258\ldots,$$

permanently. A reading of $0.98$ from this dial is not an impressive result; it is an impossible one, and would mean something is wrong with the pipeline.

Why $6/7$? Because the geometric cascade is *self-similar*. Each block is half the previous one, so the cube sum is dominated by its first term and the whole profile is, in cube-sum terms, essentially "one block of size $n/2$ plus a scaled copy of itself." The fixed point of that recursion is $1/7$ of the maximum possible correction, and $1 - 1/7 = 6/7$. The constant is a signature of the doubling, not of the hardware.

---

### The intuition that is wrong

Now the competitor. The count statistic — Hamming weight — has profile given by a row of Pascal's triangle:

$$L_{\mathrm{binom}}(b) \;=\; \left(\binom{b}{0}, \binom{b}{1}, \dots, \binom{b}{b}\right).$$

At $b = 52$ the central class has size $\binom{52}{26} = 495{,}918{,}532{,}948{,}104$ — nearly half a quadrillion words all sharing the same value. Surely *this* is the tie-crippled statistic. Surely the dial's $+0.070$ advantage is just an artefact: the count is drowning in ties, the dial isn't, and the "signal" is bookkeeping.

That intuition is exactly backwards, and proving so is the sharpest result here.

The cube sum of a binomial row, $F(b) = \sum_k \binom{b}{k}^3$, is the **Franel number** (a classical sequence, catalogued as A000172). What matters is its size relative to the maximum possible, $8^b$. The central binomial coefficient satisfies the sharp bound $\binom{2m}{m}^2 (3m+1) \le 16^m$ — equivalently $\binom{2m}{m} \le 4^m/\sqrt{3m+1}$ — and feeding that through the elementary collapse $\sum_k \binom{b}{k}^3 \le \bigl(\max_k \binom{b}{k}\bigr)^2 \cdot 2^b$ gives:

> **The Count Ceiling Law.** *For every even word length $b \ge 2$, the Hamming-weight statistic has tie ceiling*
> $$\rho^2_{\max} \;\ge\; 1 - \frac{4}{3b+2}.$$
> *In particular $\rho^2_{\max} \to 1$ as $b \to \infty$: the count statistic is asymptotically tie-transparent.*

The huge central class is a red herring. It is huge in absolute terms, but $\binom{52}{26} \approx 5 \times 10^{14}$ is only about $1/9$ of $n = 2^{52} \approx 4.5\times 10^{15}$, and — crucially — the mass around it is spread over dozens of comparably sized neighbours rather than concentrated. The Franel sum is only of order $8^b/b$, a vanishing fraction of the $8^b$ that a truly degenerate profile would need. At $b=52$ the count's ceiling is $\rho^2_{\max} = 0.99298$, i.e. $\rho_{\max} = 0.9965$.

Put the two side by side and you get the **Inversion Law**: for every even $b \ge 10$, the count baseline's ceiling *strictly exceeds* the dial's. The count is the **less** tie-limited statistic, by a wide margin — $0.9965$ against $0.9258$.

And that settles the question that motivated the whole exercise. The recorded ordering is dial $0.705$ beats count $0.635$. The ceiling ordering is count $0.9965$ beats dial $0.9258$. **The statistic that wins the measurement is the one with the worse instrument.** No amount of tie or quantisation bookkeeping can produce that ordering — granularity, if anything, was working *against* the dial. The $+0.070$ is signal.

There is a quantitative version too. Measure each statistic by how much of its own resolving power it wastes — the gap between its ceiling and its actual squared reading. The count wastes $0.590$; the dial wastes $0.360$. The count squanders more than $0.2$ extra, on top of starting from a better instrument.

---

### Resolution is a budget, not a prediction

If ties are the enemy, how many distinct values does a statistic actually need? There is a clean universal answer, and it comes from a power-mean inequality: for any profile with $K$ classes and total mass $n$, one has $n^3 \le K^2 \sum_j m_j^3$. (The proof is an induction resting on the algebraic identity
$$K^2(K+1)^2 m^3 + (K+1)^2 s^3 - K^2 (m+s)^3 = (Km - s)^2\bigl(K^2 m + 2Km + 2Ks + s\bigr),$$
whose right-hand side is visibly non-negative — a sum-of-squares certificate that makes the whole thing self-verifying.) Rearranged:

> **The Resolution Law.** *A statistic taking $K$ distinct values on $n$ points has tie ceiling at most*
> $$\rho^2_{\max} \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2}.$$

Read backwards, it is a **resolution budget**: to have any hope of reading $\rho^2 \ge 1-\varepsilon$, you need at least about $1/\sqrt{\varepsilon}$ distinct values. Want $\rho^2 = 0.99$? Ten values, minimum. Want $0.9999$? A hundred. This is a hard architectural constraint on the design of any discrete diagnostic, and it costs nothing to check.

But now look at what happens when you apply it to our two statistics. Both have $K = 53$. The budget permits $\rho^2 \le 0.99964$. The count comes within $0.007$ of the budget. The dial misses it by more than $0.14$.

That gap is the moral of the story. **Resolution alone does not determine a ceiling — shape does.** Two statistics with the identical number of distinct values can sit at opposite ends of the achievable range, purely because one spreads its mass and the other piles it up. Counting your categories tells you what is *impossible*; only the profile tells you what is *achievable*.

---

### A cap you cannot escape

The dial's shape has one dominant feature: half the sample is odd. That single fact, with nothing else assumed, already forces a ceiling.

The mechanism is simple. The tie correction is a sum of non-negative terms, so a single class of size $M$ contributes at least $(M^3 - M)/12$ all by itself, giving the **Dominant-Block Upper Law**:

$$\rho^2_{\max} \;\le\; 1 - \frac{M^3 - M}{n^3 - n}.$$

Set $M \ge n/2$ and the fraction is at least $1/8$ up to a negligible correction:

> **The Half-Mass Cap.** *If any single value of a statistic is taken by at least half the sample, then*
> $$\rho^2_{\max} \;\le\; \frac{7}{8} + \frac{7}{8(n^2-1)},$$
> *and hence, once $n \ge 1024$, the correlation itself satisfies $\rho \le 0.936$.*

This is a **distribution-free** guarantee, and that is what makes it useful. It does not assume uniform draws. It assumes only that the modal value carries half the mass — which for the trailing-zero dial holds under *any* draw law in which at least half of the inputs are odd. Balanced draws, uniform draws, skewed draws, adversarial draws: as long as odd numbers are not rare, the cap holds.

So the specification sheet for the dial reads: **valid range $[0, 0.936]$, hard stop.** The validation band $[0.55, 0.85]$ that the recorded readings are checked against sits entirely and comfortably inside it, and all three seed readings — $0.698$, $0.697$, $0.720$ — land in the band with room on both sides. Conversely, a reported reading above $0.936$ would not be a triumph; it would be a *falsification* of the model, proof that the sample is not what it is claimed to be.

---

### Does the ceiling move when the world does?

One last worry, and the deepest one. All of this assumed a particular draw law. Real deployments drift. Inputs stop being uniform; some source starts over-producing even numbers; a cache changes the mix. If the ceiling is exquisitely sensitive to the draw law, then every guarantee above is a knife-edge and worth nothing in production.

It is not. The ceiling is **Lipschitz in the draw law**, with an explicit constant.

Measure the distance between two draw laws by the total variation $\tau$ between their induced tie profiles. Because the ceiling depends on the profile only through the cube sum, and cubes are locally Lipschitz, one gets a bound immediately. The naive version, treating each class independently, yields a constant of $7$. But it throws away a conservation law: the two profiles carry the *same total mass*, so mass cannot vanish, only move — and a **displacement lemma** shows that in consequence no single class can absorb more than half of the total $\ell^1$ budget:

$$2\,\bigl|m_j - m_j'\bigr| \;\le\; \|L - L'\|_1 + \bigl|{\textstyle\sum} L - {\textstyle\sum} L'\bigr|.$$

Exploiting that conservation improves the cube bound by a factor of $3/2$ and gives:

> **The Envelope Stability Law.** *If two draw laws produce tie profiles of equal length and equal total mass $n \ge 7$, at total variation distance $\tau$, then their tie ceilings satisfy*
> $$\bigl|\rho^2_{\max}(L) - \rho^2_{\max}(L')\bigr| \;\le\; 4.1\,\tau.$$

And the constant is genuinely of order one — it cannot be pushed much lower. Take the 52-bit profile $A = (2^{52}-1,\, 1)$, which is almost totally degenerate (ceiling essentially $0$), and move exactly $1\%$ of its mass into the second class to get $B$. The two are at total variation exactly $0.01$, and their ceilings differ by $0.0297$. So any valid envelope law needs a constant of at least $2.96$. **The sharp constant lies in $[2.96,\, 4.1]$** — bracketed within a factor of $1.4$.

Now cash it out. The dial's ceiling under uniform draws is $6/7 \approx 0.857$; the pooled reading squared is $0.705^2 \approx 0.497$. The margin is $0.360$. Dividing by the Lipschitz constant: the recorded band membership survives *any* draw-law shift of total variation up to about $8.8\%$. That is not a knife-edge. That is a deployment envelope with a number attached.

Concretely: every draw law within $1\%$ total variation of uniform still has 52-bit dial ceiling above $0.78$ — strictly above the square of every recorded reading. The measurement is robust to the world moving.

---

### What an instrument's spec sheet should say

Step back and look at what has been assembled. For a discrete statistic used as a diagnostic, we now have four numbers that can be computed before the experiment runs, from the tie profile alone:

1. **The exact ceiling** — for the trailing-zero dial, $\sqrt{6/7} = 0.926$, independent of word length.
2. **The resolution budget** — $K$ distinct values buy at most $1 - 1/K^2$, and *only* the shape says how much of that budget you actually get.
3. **A distribution-free cap** — a modal class carrying half the mass forces $\rho \le 0.936$ under any draw law.
4. **A stability modulus** — a $1\%$ shift in the draw law moves the ceiling by at most $4.1\%$, and by at least $2.96\%$ in the worst case.

None of these is about the phenomenon under study. All of them are about the ruler. And the payoff is that when a measurement comes back at $0.705$, you can say something much more interesting than "moderate correlation." You can say: *this instrument tops out at $0.926$; the reading uses $54\%$ of the available dynamic range; the competing instrument tops out higher at $0.997$ and still lost by $0.070$; therefore the difference is not an artefact of granularity, and it will survive an $8\%$ perturbation of the input distribution.*

That is what it means to know your ruler. The 53 marks were never the problem — assuming they were is.
