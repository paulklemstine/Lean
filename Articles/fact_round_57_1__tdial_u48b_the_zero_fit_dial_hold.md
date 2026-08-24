# The Dial That Refuses to Move

## How counting trailing zeros led to a theorem about every window of integers

### A statistic with a very lumpy shadow

Pick a random whole number and ask a strange question: how many zeros does it end with, when written in binary? The number $12 = 1100_2$ ends with two zeros. The number $7 = 111_2$ ends with none. The number $2^{20}$ ends with twenty.

Mathematicians call this quantity the *2-adic valuation* of the number, written $\nu_2(x)$: the largest $k$ with $2^k \mid x$. Engineers call it the trailing-zero count, and every modern processor computes it in a single instruction. It is the humblest possible measurement one can make of an integer, and it turns out to be a surprisingly informative one.

The story here begins with an empirical observation from a series of numerical experiments. A quantity $T$ — the trailing-zero count of a randomly drawn integer — was measured against a downstream "rate" produced by a computational pipeline, and the two turned out to be strongly rank-correlated. Across three independent random seeds, the Spearman rank correlation came out as
$$0.7291, \qquad 0.7286, \qquad 0.7087,$$
all comfortably inside a pre-registered validation band $[0.55, 0.85]$. The integers in that experiment were drawn uniformly among those of *exactly* 48 bits — that is, uniformly from the window $[2^{47}, 2^{48})$. Against a natural competitor, the *popcount* baseline (how many one-bits does the number have?), the trailing-zero statistic won by a pooled margin of $+0.134$, with confidence interval $[0.113, 0.158]$.

Whenever a number like $0.73$ comes out of a machine, a sceptical mathematician asks the deflationary question first: **is this a real effect, or is it an artefact of how the measurement was set up?** The trailing-zero statistic is extraordinarily lumpy. Among the integers in any long stretch, about half have no trailing zeros at all, a quarter have exactly one, an eighth have exactly two, and so on. Rank correlation with such a coarse statistic is intrinsically capped: if half your sample is tied at the same value of $T$, you can never rank it perfectly against anything. Maybe $0.73$ is just what the ceiling looks like. Maybe the change from one sampling window to another moves that ceiling around, and the seed-to-seed wobble is nothing but the arithmetic of windows.

This article is about the mathematics that answers those questions. The answer, in a sentence: **the ceiling is a function of the sample size and of absolutely nothing else** — not the magnitude of the integers, not whether you condition on their bit-length, not where the sampling window sits on the number line. And the ceiling sits at a height that is essentially the same constant for every experiment anybody will ever run.

### Ties, and the price you pay for them

Spearman's rank correlation is Pearson correlation applied to ranks. When a statistic takes the same value on many sample points, those points must share a rank — the average of the ranks they would have occupied — and the correlation loses headroom.

The bookkeeping is exact. Suppose a statistic partitions a sample of $n$ points into tied blocks of sizes $m_1, m_2, \ldots, m_r$, with $\sum_j m_j = n$. Call the list $(m_1,\ldots,m_r)$ the **tie profile**. Then no matter what response variable you correlate against — even one that resolves the sample perfectly apart from the unavoidable ties — the squared Spearman coefficient cannot exceed
$$\rho^2_{\max} \;=\; 1 \;-\; \frac{\sum_j m_j^3 - n}{n^3 - n}.$$
This is the classical tie correction, read as an upper bound rather than as an adjustment. Everything the profile knows about the ceiling is contained in two numbers: the **mass** $n$ and the **cube sum** $\sum_j m_j^3$. Two profiles of equal mass can be compared purely by cube sums, and the comparison *reverses*: bigger cube sum, smaller ceiling. That little observation turns out to be the single most useful technical lever in the whole story, because cube sums are combinatorics and ceilings are algebra, and combinatorics is where the good inequalities live.

### The dyadic profile and the constant $6/7$

Now compute the tie profile of the trailing-zero count on the full range $[0, 2^b)$. Among those $2^b$ integers, exactly $2^{b-1-k}$ have precisely $k$ trailing zeros, for each $k = 0, 1, \ldots, b-1$; and exactly one point, namely $0$, is left over. The profile is the **dyadic profile**
$$D_b = (2^{b-1},\, 2^{b-2},\, \ldots,\, 2,\, 1,\, 1),$$
of mass $2^b$. Its cube sum is a geometric series:
$$\sum_j m_j^3 \;=\; \frac{8^b - 1}{7} + 1.$$
Feed that into the tie-correction formula, write $n = 2^b$, and after a small amount of factoring the ceiling collapses to a startlingly clean closed form:

> **Dyadic ceiling.** For every $b \ge 1$, the trailing-zero statistic on $2^b$ uniformly drawn integers has tie ceiling
> $$\rho^2_{\max} \;=\; \frac{6}{7}\left(1 + \frac{1}{2^b\,(2^b+1)}\right).$$

The number $6/7$ is not a coincidence; it is the geometric series $\sum 8^{-k}$ in disguise, the signature of a statistic whose tie blocks halve at every step. Numerically $\sqrt{6/7} = 0.9258\ldots$, and the correction term is under $4^{-b}$: at $b = 47$ it is smaller than $10^{-28}$. The ceiling is, for all practical purposes, the constant $0.9258$ — for every bit-length anyone will ever sample at.

That single fact already kills the first deflationary hypothesis. The measured dial declines with bit-length, roughly $0.78 \to 0.72 \to 0.65 \to 0.61$ as the sampling widens; the ceiling changes across the same range by less than $10^{-28}$. Whatever is moving the dial, it is not the tie geometry.

### Conditioning on the bit-length costs exactly one bit

The experiment did not draw from $[0, 2^{48})$. It drew from $[2^{47}, 2^{48})$ — integers of exactly 48 bits, with the top bit conditioned to be one. That is a genuinely different probability measure, and one should not assume the arithmetic transfers.

It does, and in the most economical way imaginable.

> **One-bit shift law.** For $k < b$, exactly $2^{b-1-k}$ of the integers in $[2^b, 2^{b+1})$ have precisely $k$ trailing zeros, and exactly one — namely $2^b$ itself — has $b$. Hence the tie profile of the trailing-zero statistic on uniform draws of exact bit-length $b+1$ is *literally* the dyadic profile $D_b$ of full-range bit-length $b$.

The proof is a two-line set difference: the block of $[0,2^{b+1})$ with $k$ trailing zeros has $2^{b-k}$ elements, the corresponding block of $[0,2^b)$ has $2^{b-1-k}$, and the window is the difference of the two ranges.

The same shift holds for the competitor. The popcount statistic on the full range $[0,2^b)$ has the **binomial profile** $B_b = \big(\binom{b}{0}, \binom{b}{1}, \ldots, \binom{b}{b}\big)$, since $\binom{b}{j}$ words of $b$ bits have exactly $j$ ones. Restricted to words of exact bit-length $b+1$ — top bit forced on — the words of popcount $j+1$ are in bijection with the $j$-subsets of the remaining $b$ positions, so there are $\binom{b}{j}$ of them, and the profile is again $B_b$.

Both statistics shift down by exactly one bit under bit-length conditioning. Every comparison between them therefore transports unchanged: the exact-bit-length-48 experiment is, in tie-geometric terms, a full-range bit-length-47 experiment for both statistics simultaneously. Conditioning raises the trailing-zero ceiling — from the $b+1$ value to the $b$ value, and the ceiling is strictly decreasing in $b$ — but only by less than $4^{-b}$, invisible to any measurement.

### The inversion, and exactly where it starts

Now the interesting comparison. Which statistic has more tie headroom, trailing zeros or popcount?

Both profiles have mass $2^b$, so by the cube-sum principle the comparison is decided entirely by their cube sums. The dyadic cube sum is $\frac{8^b-1}{7} + 1$. The binomial cube sum is
$$\sum_{j=0}^{b} \binom{b}{j}^3,$$
the $b$-th **Franel number** — $1, 2, 10, 56, 346, 2252, \ldots$ — a classical sequence with no elementary closed form. The dyadic ceiling is strictly *below* the binomial ceiling precisely when the dyadic cube sum is strictly larger, i.e. when
$$7 \cdot \mathrm{franel}(b) \;<\; 8^b + 6.$$

At $b = 1$: $7\cdot 2 = 14 = 8 + 6$. Equality. At $b = 2$: $7 \cdot 10 = 70 = 64 + 6$. Equality again — and no wonder, since $D_2 = (2,1,1)$ and $B_2 = (1,2,1)$ are permutations of each other, hence tie-equivalent. At $b = 3$: $7 \cdot 56 = 392 < 518$. Strict, and it never turns back.

> **Inversion threshold.** For every $b \ge 1$, the popcount baseline has a strictly higher tie ceiling than the trailing-zero statistic if and only if $b \ge 3$. At $b = 1$ and $b = 2$ the two ceilings coincide exactly.

Getting this cleanly required a genuine estimate, because Franel numbers do not submit to direct computation at $b = 47$. Bounding each $\binom{b}{j}^3$ by (middle binomial)$^2 \times \binom{b}{j}$ gives $\mathrm{franel}(b) \le \binom{b}{\lfloor b/2\rfloor}^2 2^b$, and a central-binomial estimate then yields, for odd bit-lengths $b = 2m+1$,
$$\mathrm{franel}(2m+1)\,(3m+1) \;\le\; 8^{2m+1},$$
using the Pascal-rule inequality $\binom{2m+1}{m} \le 2\binom{2m}{m}$. Such a bound converts immediately into a ceiling bound $\rho^2_{\max} \ge 1 - 2/(3m+1)$ for the popcount profile — which for $m \ge 5$ already exceeds $6/7 + 2^{-b}$, the trailing-zero ceiling's upper envelope. That handles all bit-lengths from 10 upward, in both parities. Below 10 the estimate is too lossy (at $b = 8$ it only gives $0.846 < 6/7$), but there the cube sums are finite arithmetic and can simply be checked.

The scientific consequence is sharp and slightly deflating for the deflationist. At exact bit-length 48 — tie-geometrically, bit-length 47 — the *popcount baseline has strictly more headroom than the trailing-zero statistic*. Yet the measurement puts the trailing-zero statistic $+0.134$ ahead. The measured advantage therefore runs **against** the tie geometry, not with it. It cannot be a tie artefact; it is signal.

### Where the window sits: it does not matter

One deflationary hypothesis remains, and it is the most tempting one, because it would explain the seed-to-seed spread $0.7291 / 0.7286 / 0.7087$. Perhaps the sampling window's *placement* matters. The dyadic computation above used the special window $[2^{47}, 2^{48})$, which starts at a power of two. Surely a window sitting at some arbitrary offset chops the 2-adic blocks unevenly and perturbs the profile by $\Theta(2^{-s})$?

It does not. And the proof of why not is the prettiest part of the story.

Start with the easy case, an *aligned* window $[c\cdot 2^s, (c+1)\cdot 2^s)$ of scale $s$ at arbitrary offset $c$. For $k < s$, the number $2^{k+1}$ divides $2^s$, so adding $c \cdot 2^s$ to an integer changes nothing about its divisibility by $2^k$ or $2^{k+1}$. Translation by $c\cdot 2^s$ is therefore a bijection from the $k$-th trailing-zero block of $[0, 2^s)$ onto the $k$-th block of the window, and the block sizes are the same $2^{s-1-k}$. The leftover point is $c \cdot 2^s$ itself, the unique multiple of $2^s$ in the window. So:

> **Dyadic-scale invariance.** Every aligned window $[c\cdot 2^s, (c+1)\cdot 2^s)$, at every offset $c$, has trailing-zero tie profile exactly $D_s$ — hence exactly the ceiling $\frac{6}{7}\big(1 + \frac{1}{2^s(2^s+1)}\big)$.

But alignment was never the operative hypothesis. What actually matters is a much older and simpler fact: **a run of $M \cdot r$ consecutive integers meets each residue class modulo $r$ exactly $M$ times.** And having exactly $k$ trailing zeros is precisely membership in one residue class:
$$\nu_2(x) = k \iff x \equiv 2^k \pmod{2^{k+1}}.$$
So in *any* window of $2^s = 2^{s-1-k}\cdot 2^{k+1}$ consecutive integers, the number of points with exactly $k$ trailing zeros is exactly $2^{s-1-k}$; and taking $r = 2^s$, $M = 1$, the window contains exactly one multiple of $2^s$.

> **Translation invariance.** For every starting point $A$ and every scale $s$, the window $\{A, A+1, \ldots, A + 2^s - 1\}$ has trailing-zero tie profile exactly $D_s$, and hence the ceiling
> $$\frac{6}{7}\left(1 + \frac{1}{2^s(2^s+1)}\right).$$

The alignment theorem is a special case ($A = c\cdot 2^s$); so is the exact-bit-length window ($A = 2^s$); so is the full range ($A = 0$). One clause covers them all: **the tie ceiling of the trailing-zero dial is a function of the sample size and of nothing else.** Not the magnitude of the integers. Not the bit-length conditioning. Not the offset, alignment, or placement of the sampling window.

There is a real surprise buried here. The natural guess — that non-aligned windows perturb the profile at order $2^{-s}$ — is not just wrong to leading order; it is wrong *exactly*. There is no error term at all. This is one of those situations where a stronger statement is easier to prove than the weak one, because the correct mechanism (period divisibility) is cleaner than the one you first reached for (alignment).

### What survives

Line up the deflationary hypotheses and see which are still standing.

*"The measured $0.73$ is just the ceiling."* No: the ceiling is $\sqrt{6/7} = 0.9258$, and every recorded seed sits strictly below it, with room to spare.

*"The bit-length trend is a quantisation artefact."* No: from exact bit-length 48 to full-range bit-length 64 the ceiling moves by less than $4^{-47}$, while the dial moves by more than $0.07$. Those are twenty-eight orders of magnitude apart.

*"The advantage over popcount is tie geometry."* No, and emphatically: at these bit-lengths the tie geometry strictly favours the popcount baseline. The measured advantage of $+0.134$ is achieved *despite* the geometry.

*"The seed spread comes from where the sampling window sits."* No: window placement is provably invisible. Every window of $2^{47}$ consecutive integers, wherever it starts, carries the identical ceiling.

What remains is a clean factorisation of the problem. Write the measured correlation as
$$\rho \;=\; \rho_{\text{ceiling}} \cdot \rho_{\text{response}},$$
where the first factor is the tie geometry — now pinned exactly, for all windows, at $\sqrt{6/7}$ up to $O(4^{-s})$ — and the second is whatever the downstream response actually does with the information. All the variation the experiment records lives in the second factor. Any explanatory model must be *response-side*.

That is a modest-sounding conclusion, but it is the useful kind. A great deal of empirical work consists of chasing a number around a parameter space, not knowing which knobs are real. Here four knobs have been proved inert, once and for all, by pure arithmetic: magnitude, bit-length conditioning, window alignment, window placement. The search space for an explanation just got much smaller.

### A coda on humble statistics

It is worth pausing on how little machinery was needed. The whole edifice rests on three elementary facts: a geometric series sums to $\frac{8^b-1}{7}$; a run of $Mr$ consecutive integers meets each residue class mod $r$ exactly $M$ times; and comparing two tie ceilings of equal mass is comparing two cube sums, backwards. From those, one gets a closed-form ceiling with the peculiar constant $6/7$, an exact threshold at $b = 3$ separating a degenerate regime from a universal one, and an invariance theorem with no error term.

The trailing-zero count is the crudest imaginable summary of an integer: it throws away everything but the length of the run of zeros at the bottom. Its statistical shadow — the tie profile $(2^{s-1}, 2^{s-2}, \ldots, 1, 1)$ — is so rigid that it survives every translation, every rescaling, every conditioning one might apply. In a subject where measurements drift and parameters interact, a quantity that provably refuses to move is worth quite a lot.
