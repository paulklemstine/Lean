# The Ceiling You Can't See: How Ties Quietly Cap a Correlation

*When data come in lumps, even a perfect relationship cannot score a perfect correlation. A small piece of algebra tells us exactly how much is lost — and overturns a tempting rule of thumb about where the loss comes from.*

---

## A dial, a response, and a number that won't reach 1

Imagine an experiment with a **dial** and a **response**. The dial is something you set — a dose, a difficulty level, a temperature setting. The response is what you observe — a score, a rating, a measured outcome. You run many trials, and you want to summarise in a single number how faithfully the response tracks the dial.

The classic tool for this is **Spearman's rank correlation**, written $\rho$ (the Greek letter rho). Spearman's idea, more than a century old, is beautifully robust: forget the raw values, keep only their *order*. Replace each dial setting by its rank among all settings (smallest is rank 1, next is rank 2, and so on), do the same for the responses, and measure how well the two rank lists agree. If the response always goes up when the dial goes up, the ranks match perfectly and $\rho = 1$. If they are unrelated, $\rho$ hovers near $0$.

Now suppose your pooled analysis reports $\rho = 0.669$. Is that a moderate relationship? Or is it as good as the data could possibly have shown?

The surprising answer is: *it depends on the ties.* And working out exactly how it depends on them is the subject of this story.

## Lumps in the data

Real data are lumpy. A dial often has only a handful of settings, so dozens of trials share the same setting. Responses are often recorded on a coarse scale — a 1-to-5 rating, a pass/fail, a count — so many trials share the same response. Statisticians call these shared values **ties**.

Ties break the simple picture of ranks $1, 2, 3, \dots$. If three trials tie for the lowest response, which of them gets rank 1? The standard answer is democratic: they share. All three receive the average of ranks 1, 2 and 3, namely the **midrank** $2$. In general, if a tied block of size $l$ starts right after position $s$, every member of the block receives the midrank

$$s + \frac{l+1}{2}.$$

So a dataset's ties are described by its **tie profile**: the list of block sizes $l_1, l_2, \dots, l_k$, read from the smallest value to the largest, adding up to the number of observations $n$. An untied variable has profile $1, 1, \dots, 1$. A variable that takes a single value on every trial has profile consisting of a single block of size $n$.

## Ties drain variance — by an exact amount

Here is the first key fact. Ranks without ties are just the numbers $1$ through $n$, and their spread around the centre $(n+1)/2$ is a classical quantity: the sum of squared deviations equals $(n^3 - n)/12$.

When ties are present, midranks are *less spread out*, because averaging squeezes each tied block to a single point. How much spread is lost? Remarkably, the answer is clean and depends only on the block sizes:

> **Tie correction identity.** For any tie profile with blocks $l_1, \dots, l_k$ summing to $n$, the midranks $R_1, \dots, R_n$ satisfy
> $$\sum_{i=1}^n \left(R_i - \frac{n+1}{2}\right)^2 = \frac{(n^3 - n) - \sum_j (l_j^3 - l_j)}{12}.$$

The reason is pleasingly local. Replacing the consecutive ranks $s+1, \dots, s+l$ of a block by their average doesn't change their sum, but it removes exactly their internal spread — and the spread of $l$ consecutive integers about their mean is $(l^3 - l)/12$. Add up the losses block by block and the formula falls out.

It is natural to express this as a fraction of the untied spread. Define the **tie factor** of a profile $L$:

$$f(L) = 1 - \frac{\sum_j (l_j^3 - l_j)}{n^3 - n}.$$

The identity says that the midrank spread is exactly $f(L)$ times what it would be without ties. Since spread is never negative and the tie mass $\sum (l_j^3 - l_j)$ is never negative, the factor always lies between $0$ and $1$. It equals $1$ for an untied variable and $0$ for a variable with no variation at all.

A small example makes it concrete. Four observations with profile $2, 1, 1$ — the two smallest tied — have tie mass $2^3 - 2 = 6$, while $n^3 - n = 60$. So $f = 1 - 6/60 = 0.9$: the tie costs ten percent of the rank variance.

## Two ways to compute rho, two kinds of ceiling

With ties around, there are two common recipes for Spearman's rho. Both start from the same numerator: the **rank covariance**, the sum over trials of (dial midrank minus centre) times (response midrank minus centre). They differ in what they divide by.

- The **textbook rho**, which we'll write $\rho_u$, divides by the untied spread $(n^3 - n)/12$, as if there were no ties at all.
- The **tie-corrected rho**, $\rho_c$, divides by the geometric mean of the actual spreads of the two midrank lists. This is simply the ordinary Pearson correlation of the midranks.

The two are related by $\rho_c = \rho_u / \sqrt{f(L)\, f(M)}$, where $L$ is the dial's profile and $M$ is the response's profile.

The tie-corrected version is designed to "undo" the ties, but as we'll see, it can't fully do so. And the textbook version wears its ties openly: its ceiling sits strictly below 1 whenever there are ties.

## The headroom product bound

How high can the textbook rho possibly go? The rank covariance is an inner product of two vectors — the centred dial midranks and the centred response midranks. The most famous inequality in all of mathematics, the **Cauchy–Schwarz inequality**, says an inner product is at most the product of the lengths. The squared lengths are exactly the midrank spreads, which we just computed. Putting the pieces together:

> **Product bound.** For any dial profile $L$ and response profile $M$ on the same $n \ge 2$ observations, and *any* way of pairing dial values with response values,
> $$\rho_u^2 \le f(L)\cdot f(M).$$

This holds exactly, with no error term — the original conjecture had allowed for a correction of order $1/n^2$, but none is needed. It is a genuine ceiling: the dial's ties and the response's ties each eat into the room available, and on a logarithmic scale their "headrooms" add.

Is the ceiling ever reached? Yes: when the dial and response have the *same* profile and are paired in order, the covariance equals the common spread, and $\rho_u = f(L)$, so $\rho_u^2 = f(L)\cdot f(L)$ exactly.

## The tempting conjecture

This suggested an elegant accounting rule — call it **headroom conservation**. Suppose the best achievable correlation were always *exactly* the product ceiling, so that the maximum depended only on the two tie factors and the logarithmic headrooms simply added. Then one could do clean bookkeeping. The dial's ties can be removed by design — just use a finer dial, flattening its profile until $f(L) = 1$. Any remaining shortfall in the observed $0.669$ would then be "charged" entirely to the response's ties. And a recorded advantage of $+0.045$ between two analyses might be predicted from the response's tie profile alone.

It is a lovely story. It is also false.

## Where the story breaks

The first crack appears at the simplest possible setting: an untied dial. Pair an untied dial (profile $1,1,\dots,1$, factor $1$) in order with a tied response of factor $f(M)$. Because the dial ranks within each response block average out to that block's midrank, the covariance equals the response's own spread, and

$$\rho_u = f(M), \qquad \rho_c = \sqrt{f(M)}.$$

By the rearrangement inequality, pairing in order is the best you can do. But the product bound would allow $\rho_u^2$ up to $1 \cdot f(M) = f(M)$, while we only reach $f(M)^2$. Whenever the response is genuinely tied but not constant ($0 < f(M) < 1$), the ceiling is **never attained**.

The second crack is more decisive: the best achievable correlation is **not a function of the two tie factors at all**. Take four observations.

- Dial profile $2,1,1$ (the two lowest tied) and response profile $2,1,1$. Both factors are $0.9$, and the best achievable $\rho_u$ is $0.9$.
- Dial profile $2,1,1$ and response profile $1,1,2$ (the two *highest* tied). Both factors are *still* $0.9$ — the tie mass doesn't care where the tie sits — but now the best achievable $\rho_u$ is only $0.8$.

Same tie factors, different ceilings. *Where* the ties sit relative to one another matters, not just how heavy they are. No bookkeeping in terms of separate dial and response factors can be correct.

## What replaces it: a ratio, not a product

So what *does* govern the ceiling? The cleanest case is when one profile is a **coarsening** of the other — every block of the coarse profile is made by merging consecutive blocks of the fine one. (An untied dial is the finest profile of all, so the previous example is a special case.) Here the answer is exact:

> **Nested-profile law.** If the dial and response profiles are nested, with the coarser one having factor $f_{\text{coarse}}$ and the finer one $f_{\text{fine}}$, then the best achievable correlations are
> $$\max \rho_u = f_{\text{coarse}}, \qquad \max \rho_c = \sqrt{\frac{f_{\text{coarse}}}{f_{\text{fine}}}}.$$

Coarsening acts like averaging, and averaging the finer midranks over the coarse blocks reproduces the coarse midranks exactly. That's why the covariance equals the coarse spread.

So the headrooms do combine — but as a **ratio**, not a product. On the log scale, the tie-corrected headroom is *half the difference* of the two log-factors, not their sum. The coarser variable is the bottleneck; refining the finer one further does nothing for the textbook rho and actually *lowers* the tie-corrected one.

## Back to the pooled reading

What does this mean for the observed $0.669$? Suppose the dial is flattened to be untied. The untied-dial result says every pairing satisfies $\rho_u \le f(M)$ and $\rho_c \le \sqrt{f(M)}$. Read in reverse, the observation is a certificate about the response's ties:

- If $0.669$ is a textbook rho, the response's tie factor must be at least $0.669$.
- If $0.669$ is a tie-corrected rho, the response's tie factor must be at least $0.669^2 = 0.447561$.

These are hard, distribution-free constraints: no amount of luck could have produced $0.669$ from a more heavily tied response. But the stronger claim — that a $+0.045$ advantage is predicted by the response's profile alone — does not follow. It would require the dial's profile to be nested inside the response's, and in general the joint arrangement of both profiles enters. (The detailed tie profiles behind the pooled data weren't available, so the $0.045$ figure itself could not be tested here.)

## Why this matters

Rank correlations are everywhere: in psychology and medicine (where Likert scales produce massive ties), ecology (counts), machine learning (ranking metrics), and quality control. Whenever someone reports "a correlation of 0.67" on lumpy data, a natural follow-up is: *out of how much?* The tie correction identity and the product bound give a clean, exact answer for the ceiling's outer envelope. The counterexamples warn against the convenient habit of attributing lost correlation separately to each variable. And the nested law shows the right mental model: correlation between coarse and fine measurements is limited by the coarser one, and the two headrooms interact as a ratio.

## Open questions

The story leaves inviting puzzles:

1. **When is the product ceiling exactly reached?** Numerical evidence suggests: only when the two profiles are identical, or one of them is a single block (no variation at all). For $n$ observations this predicts exactly $3\cdot 2^{n-1} - 2$ equality pairs among all ordered pairs of profiles — a count that checks out exhaustively for small $n$.
2. **A general formula.** For arbitrary (non-nested) profiles, is there an "interaction tie mass," computed from how the blocks overlap, that plays the role of the coarse factor?
3. **A universal ratio law.** Is it always true that $\max \rho_c^2 \le \min(f(L), f(M)) / \max(f(L), f(M))$, with equality exactly for nested profiles? Every pair of profiles checked so far for small $n$ obeys it.

A century after Spearman, his simple idea of trading values for ranks still hides crisp, surprising mathematics — and a ceiling that, once you know where to look, you can see after all.
