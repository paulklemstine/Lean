# Two Numbers Are All a Hint Is Worth

*How much faster can you find a needle if someone whispers where the haystack's sweet spot is — and what if they are sometimes wrong?*

---

## A search, a whisper, and a price tag

Picture a row of $M$ identical lockers. Exactly one of them hides the thing you want. You may open them one at a time, and every opening costs you something — a second, a database query, a trial division, an expensive lab test. If you know nothing, every locker is equally likely and the best you can do is to march down the row. On average you will open

$$\frac{M+1}{2}$$

lockers before you hit the right one. That is the *blind cost*, the baseline every clever idea must beat.

Now a stranger leans over and says: *"It's in one of these $W$ lockers."* If the stranger is always right, the problem shrinks from $M$ lockers to $W$, and the average cost drops to $(W+1)/2$. But strangers are not always right. Suppose this one is right with probability $\alpha$ — we will call $\alpha$ the **coverage** of the hint, and the fraction $w = W/M$ its **width**.

How much is such a whisper worth? This question sounds like a curiosity, but it sits underneath an enormous range of practical problems. A heuristic that ranks the likely location of a bug in a codebase, a model that predicts which range of keys a password is drawn from, a side channel that leaks roughly where a secret lies, an astronomer's prior about which patch of sky to scan first — all of them are "interval hints": a window, plus a reliability. The question is how to *price* them.

The answer, it turns out, is startlingly clean. A hint is worth exactly two numbers, and those two numbers combine in a way that is easy to get wrong.

## The rule of the game: probe the likeliest locker first

Before pricing hints, we need to know how to *use* them. Suppose you have any belief about where the prize is: locker $j$ has probability $q_j$. You choose an order in which to open lockers. If the $i$-th locker you open is the right one, you pay $i$. So the expected cost of an order is

$$\text{cost} = \sum_{i=1}^{M} i \cdot q_{(\text{$i$-th locker opened})}.$$

Which order is best? Intuition says: open the most likely locker first, then the next most likely, and so on. Intuition is right, and the reason is a classical piece of mathematics called the **rearrangement inequality**: if you pair an increasing list of numbers (the probe positions $1,2,3,\dots$) with a list of probabilities, the sum of products is smallest when the large probabilities are matched to the small positions. Any order that opens lockers in non-increasing order of probability — a *greedy* order — is therefore optimal among all $M!$ possible orders. Statisticians call such an optimal strategy **Bayes-optimal**: it minimizes the expected cost given what you believe.

## What an honest hint does to your beliefs

Now let the stranger speak. If you start with every locker equally likely and the stranger is honest about their reliability, your updated belief is simple. The probability $\alpha$ that the prize is in the window is spread evenly over its $W$ lockers, and the remaining $1-\alpha$ is spread evenly over the other $M-W$:

$$q_j = \begin{cases} \dfrac{\alpha}{W} & \text{if locker } j \text{ is in the window,}\\[2mm] \dfrac{1-\alpha}{M-W} & \text{otherwise.}\end{cases}$$

The natural plan — the **committed procedure** — is: search the window first, then everything else. Adding up the costs gives an exact answer. The expected number of lockers opened is

$$\frac{W + 1 + (1-\alpha)M}{2},$$

and so the **speedup** over the blind search is

$$\boxed{\;S \;=\; \frac{M+1}{(1-\alpha)M + W + 1}\;}$$

This formula is the heart of the story. Let it sink in for a moment, because it says something surprising about what a hint really is.

## Not a product: a sum

Many people, asked to guess, would say a hint's value is something like "coverage times narrowness" — a product of how often it's right and how much it shrinks the search. The exact law says otherwise. Divide the top and bottom by $M$ and let the number of lockers grow, keeping the width fraction $w$ fixed. The speedup settles down to

$$S \;\longrightarrow\; \frac{1}{\,1 - \alpha + w\,}.$$

The two numbers do not multiply. They **add**. What matters is the *coverage deficit* $1-\alpha$ (how often the hint misleads you) plus the *width* $w$ (how much of the space it still asks you to search). Their sum is, quite literally, the fraction of the blind cost you still pay.

This has an immediate and very practical consequence: an **exchange rate**. Two hints give exactly the same speedup if and only if

$$(1-\alpha)M + W \;=\; (1-\alpha')M + W'.$$

In words: **one locker of width is worth exactly $1/M$ of reliability.** If a rival offers you a window that is 30 lockers wider (out of 1000) but 3 percentage points more reliable, the two hints are worth exactly the same. A 90%-reliable window of 20 lockers and a 93%-reliable window of 50 lockers both speed you up by the identical factor $8.27\ldots$ when $M=1000$.

The additive law also explains two **ceilings**, one for each number:

- **The coverage ceiling.** No matter how narrow the window — even a single locker — the speedup can never exceed $1/(1-\alpha)$. A 90%-reliable whisper can never buy you more than a tenfold gain. When the hint is wrong, you are back to searching the rest of the row, and that residual cost dominates.
- **The width ceiling.** No matter how reliable the hint — even a perfect one — the speedup can never exceed $(M+1)/(W+1)$, and perfect coverage achieves it exactly.

Reliability and narrowness are not interchangeable resources that can each be pushed indefinitely; each one caps what the other can do. And the speedup is strictly increasing in $\alpha$: every bit of extra reliability helps, but with sharply diminishing returns once $1-\alpha$ falls below $w$.

## When trusting the hint is a mistake

So far we have assumed that "search the window first" is the right way to use a hint. Is it always?

No — and the exact boundary is beautifully simple. Searching the window first is Bayes-optimal **if and only if**

$$\alpha \;\ge\; w.$$

The reason is visible in the posterior. Window lockers each carry probability $\alpha/W$; outside lockers each carry $(1-\alpha)/(M-W)$. Window-first is greedy exactly when the first is at least the second, and a line of algebra turns that into $\alpha \ge W/M$. When $\alpha < w$, the hint is *worse than random* in a precise sense: it points at a region that is less likely, per locker, than the region it ignores. Then swapping just two probes — the last locker of the window with the first locker outside it — strictly lowers the expected cost. The committed procedure is beaten by a single exchange.

A tiny example makes this concrete. Take $M=6$ lockers and a window of $W=2$, so $w = 1/3$. Checking all $720$ possible search orders by brute force:

| coverage $\alpha$ | committed cost | best possible cost |
|---|---|---|
| $1/2$ | $3$ | $3$ |
| $1/3$ | $7/2$ | $7/2$ |
| $1/4$ | $15/4$ | $13/4$ |

At $\alpha = 1/4 < 1/3$, the best order searches the four *outside* lockers first.

## Information never hurts — but misinformation does

Two further facts round out the picture.

First, **an honest hint can never make the best possible search worse.** Write $\mathrm{opt}(q)$ for the Bayes-optimal expected cost under belief $q$. It is the minimum of finitely many linear functions of $q$ — one for each order — and a minimum of linear functions is *concave*. Concretely, if your prior belief is a mixture $t\,q_1 + (1-t)\,q_2$ and an honest hint tells you which component you are in, then

$$t\,\mathrm{opt}(q_1) + (1-t)\,\mathrm{opt}(q_2) \;\le\; \mathrm{opt}\big(t\,q_1 + (1-t)\,q_2\big).$$

On average, learning which world you are in can only help. And whenever $\alpha \ge w$, the committed procedure's cost is not just good — it *is* the Bayes-optimal cost.

Second, **a dishonest reliability claim costs you a precise amount.** Suppose the stranger *claims* coverage $\alpha$ but the truth is $\beta$. The window-first order does not depend on the claimed number, so you search exactly as before — but you pay

$$\frac{(\alpha - \beta)\,M}{2}$$

more lockers than advertised, on average. Every percentage point of overstated reliability costs $M/200$ probes. Worse, if the true coverage falls below the width ($\beta < w$), then the window-first search is strictly worse than the best search you could have run had you known the truth.

## Pricing a mystery gain: the 5.19× crossing

This framework was built to answer a concrete question. An earlier study of a structured search had found that ordering candidates by their *magnitude* — a natural heuristic — produced a speedup of about $5.19\times$. Where does such a gain come from, and how much "positional information" is it equivalent to? The tempting story was: it is as if an oracle knew the target's position to within a $2$–$5\%$-wide window at about $90\%$ reliability.

The additive law lets us test that story exactly, at least under the uniform prior. Setting $1/(1-\alpha+w) = 5.19$ gives

$$\alpha \;=\; 1 - \tfrac{1}{5.19} + w \;\approx\; 0.807 + w .$$

For any width between $2\%$ and $5\%$, the required reliability lies strictly between $0.82$ and $0.86$ — specifically from about $0.827$ to $0.857$. A $90\%$-reliable window of that width would be worth *more*: between $6.67\times$ and $8.33\times$. So the "90% at 2–5%" description **overprices** the observed gain. The qualitative idea survives — external positional information really is a two-number object — but the exact dictionary corrects the numbers, and it corrects the grammar too: coverage and width combine as a sum, not a product.

## When the target likes small numbers: the min-law

The uniform prior is the simplest world, but many real searches are tilted. A classic example is the *smaller of two random numbers*. If $p$ and $q$ are drawn independently and uniformly from $\{1,\dots,M\}$ and you hunt for $J = \min(p,q)$ — as when searching for the smaller of two hidden quantities, such as the smaller factor of a product — small values are far more likely. Counting pairs shows that exactly $2(M-j)+1$ of the $M^2$ pairs have minimum $j$, so

$$P(J = j) \;=\; \frac{2(M-j)+1}{M^2}.$$

This **min-law** is strictly decreasing, so the best blind search simply counts upward from $1$, at average cost

$$\frac{(M+1)(2M+1)}{6M} \;\approx\; \frac{M}{3},$$

already a third better than the uniform $M/2$. One subtle consequence: under the min-law, knowing that the target lies in a window does *not* make it uniform within the window. An earlier modeling attempt had assumed exactly that, and the assumption was caught because its predictions disagreed with simulation.

For hints with perfect coverage that name which of $M/W$ consecutive blocks contains the target, the exact cost is

$$\frac{(W+1)(3M - W + 1)}{6M},$$

so the speedup over the best blind search is

$$S = \frac{(M+1)(2M+1)}{(W+1)(3M-W+1)} \;\longrightarrow\; \frac{2}{w(3-w)}.$$

At $M = 10{,}000$ this gives $33.39\times$, $13.53\times$, $6.89\times$ and $3.57\times$ for widths $w = 0.02, 0.05, 0.10, 0.20$. An earlier empirical table — which parametrized its windows slightly differently, so the comparison is indicative rather than exact — had reported maximal (perfect-coverage) speedups of $29.13\times$, $13.12\times$, $7.11\times$ and $3.96\times$ at the same four widths, with simulation giving $34.0\times$ at $w = 0.02$. The closed form sits in the same range throughout, and at $w=0.02$ it lands next to the simulated value, not the grid value — pinpointing where the earlier grid computation and its simulation disagreed. The full table for imperfect coverage under the min-law remains open — the honest residual of this work.

## What a hint is

Strip away the lockers and the strangers, and here is what remains.

A positional hint is not a vague "boost." It is **two numbers**: how often it is right, and how much of the space it still makes you search. Under an even prior, the fraction of your search effort that survives is exactly $1 - \alpha + w$. Trade-offs between reliability and precision happen at a fixed exchange rate. A hint less reliable than it is wide should not be trusted first. Honest information never hurts; overstated reliability costs a precisely computable number of wasted probes.

These are small, sharp statements, the kind that make a vague engineering intuition into a ledger you can audit. And the ledger matters: twice in the course of this study, an attractive model was exposed not by argument but because exact computation and simulation refused to agree. A clean law is valuable precisely because it tells you when the numbers in front of you cannot both be right.
