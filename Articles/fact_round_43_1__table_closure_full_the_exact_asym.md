# The Fork in the Road: Four Ways to Measure a Vanishing Bias

## A coin that is almost fair

Imagine a coin that lands heads with probability $\frac{1}{2} + \frac{1}{n}$. For $n = 2$ it always lands heads — no coin at all, just a certainty. For $n = 10$ it is noticeably loaded. For $n = 655360$ it is, for every practical purpose, fair: you would need billions of flips to notice anything at all.

The interesting question is not *whether* the bias disappears — obviously it does — but *how fast*, and, more subtly, whether different ways of measuring "how far from fair" die out at the same speed and in the same proportion to one another.

This article is about four such measurements, which we will call the four **fork channels**. They all describe the same underlying situation — a branch point, a decision, a fork in the road, whose asymmetry is governed by a single resolution parameter $n$ — and they all shrink to zero like $1/n^2$. But their *exact* rates of shrinkage turn out to be four different constants, and the ratios between those constants are not the ones anyone would guess.

The story here has a small human twist. The relationships between these constants were first *guessed* — plausibly, on the strength of a clean heuristic — and the guess was then refuted by the very numbers it was designed to explain. The corrected constants, derived afterwards and now proved exactly, are the subject of this article.

## The four channels

Everything is measured in **bits**, so all logarithms below are base $2$ unless we say otherwise. The central object is the **binary entropy function**

$$H(p) = -p\log_2 p - (1-p)\log_2(1-p),$$

the average number of bits of surprise you get from one flip of a $p$-coin. It is maximal, equal to $1$, at $p = \tfrac12$, and drops to $0$ at $p=0$ and $p=1$.

Now fix an integer resolution $n \ge 2$ and define:

**1. The capacity channel.**
$$X(n) = 1 - H\!\left(\tfrac12 + \tfrac1n\right).$$
This is the number of bits *lost* relative to a perfectly fair coin. Equivalently, it is the information-theoretic distance from the biased coin to the fair one: how much a coin with bias $1/n$ tells you, on average, that a fair coin would not.

**2. The ambiguity channel.**
$$A(n) = \frac{\log_2 n}{n^2}.$$
Think of a rare fork event of probability $1/n^2$. Its surprisal is $2\log_2 n$ bits; $A(n)$ is half of that surprisal, weighted by the probability of the event. It is the only one of the four channels that carries a logarithm in its numerator.

**3. The gap channel.**
$$g(n) = -\left(1 - \tfrac{1}{n^2}\right)\log_2\!\left(1 - \tfrac{1}{n^2}\right) - \tfrac{1}{n^2}.$$
Here $1/n^2$ is again the fork probability. The first term is the entropy contribution of the *survival* branch (the fork does not happen); from it we subtract the raw probability of the fork. The gap channel measures the excess of one over the other — a bookkeeping residue, and by far the smallest of the four.

**4. The reverse channel and the isolation channel.**
$$R(n) = -\tfrac12 \log_2\!\left(1 - \tfrac{4}{n^2}\right), \qquad \mathrm{Is}(n) = A(n) + R(n).$$
The capacity channel $X$ measures the distance from the biased coin to the fair one; $R$ measures it the other way round, from fair to biased. (These two directional distances are famously *not* equal in general.) The isolation channel simply stacks the ambiguity term on top of the reverse term.

All four vanish as $n$ grows. The whole question is: multiplied by $n^2$, what do they converge to?

## The four exact constants

Here is the answer, and it is remarkably clean. Write $\log_2 e = 1/\ln 2 = 1.442695\ldots$ for the reciprocal of the natural logarithm of two.

> **The Gap Law.** $\;g(n)\,n^2 \longrightarrow \log_2 e - 1 = 0.442695\ldots$
>
> **The Capacity Law.** $\;X(n)\,n^2 \longrightarrow 2\log_2 e = 2.885390\ldots$
>
> **The Ambiguity Law.** $\;\dfrac{A(n)\,n^2}{\log_2 n} = 1$ — not in the limit, but *exactly*, for every $n \ge 2$.
>
> **The Isolation Law.** $\;\bigl(\mathrm{Is}(n) - A(n)\bigr)\,n^2 \longrightarrow 2\log_2 e = 2.885390\ldots$

Look at what these say. Three of the four channels are pure $1/n^2$ quantities — **no logarithmic correction at all**, just a bare constant. The gap channel in particular decays like $0.442695/n^2$, with no $\log n$ anywhere in sight. That was the first surprise: a quantity built entirely out of logarithms, whose asymptotic size contains none.

The ambiguity channel is the exception, and it is exceptional in the most extreme possible way: the ratio $A(n)n^2 / \log_2 n$ is not merely asymptotically $1$, it is *identically* $1$. There is nothing to prove and nothing to estimate; it is a rearrangement of the definition. But that identity has teeth, because it means $A$ carries a genuine $\log n$ that the other channels lack.

And the reverse channel converges to *exactly the same* constant $2\log_2 e$ as the capacity channel. Forward and backward information distances between a fair coin and a $1/n$-biased coin differ at every finite $n$ — you can see the difference in the third digit at $n = 100$ — but their leading coefficients agree perfectly. Their asymmetry is a second-order effect.

## The ratio that refuted a guess

Combine the first two laws and you get the headline number:

> **The Ratio Law.** $\;\dfrac{X(n)}{g(n)} \longrightarrow \dfrac{2\log_2 e}{\log_2 e - 1} = \dfrac{2}{1 - \ln 2} = 6.51778\ldots$

The pre-data prediction had been $X/g \to 2$. The reasoning behind it was seductive: both channels are quadratic in the small parameter, both come from the same entropy function, and $X$ involves a bias of $2/n$ where $g$ involves $1/n^2$ — a factor of two seemed to fall out. The table of computed values then said $6.5$, and kept saying $6.5$ all the way out to $n = 655360$.

Why is the true answer $6.5$? The mechanism is a *near-cancellation* inside the gap channel, and it is worth seeing in detail, because it is the whole reason the two channels do not scale alike.

Set $u = 1/n^2$. Expanding the logarithm,
$$-\log_2(1-u) = \frac{u + \tfrac{u^2}{2} + \cdots}{\ln 2} = u\log_2 e + O(u^2),$$
so
$$g(n) = (1-u)\bigl(u \log_2 e + O(u^2)\bigr) - u = u\,(\log_2 e - 1) + O(u^2).$$
The leading term of the entropy piece is $u\log_2 e$ — and then the definition of $g$ *subtracts a whole $u$ from it*. Since $\log_2 e = 1.4427$, the subtraction destroys nearly seventy percent of the leading coefficient, leaving the modest $0.442695$. The gap channel is small not because it decays faster, but because it is a difference of two nearly equal things.

The capacity channel suffers no such cancellation. With $x = 2/n$,
$$X(n) = \frac{(1+x)\ln(1+x) + (1-x)\ln(1-x)}{2\ln 2} = \frac{x^2 + O(x^4)}{2\ln 2} = \frac{2\log_2 e}{n^2} + O(n^{-4}).$$
Its leading coefficient survives intact.

So the ratio of the constants is
$$\frac{2\log_2 e}{\log_2 e - 1} = \frac{2/\ln 2}{(1-\ln 2)/\ln 2} = \frac{2}{1 - \ln 2} = 6.5177827\ldots,$$
and the appearance of $\ln 2 = 0.693147$ in a *denominator* — rather than as an overall scale — is exactly the signature of the cancellation. Guessing $2$ meant tacitly assuming the two channels had the same leading coefficient up to a factor. They do not, and no amount of dimensional reasoning could have produced $1/(1-\ln 2)$.

## Crossings and collapses: the small-$n$ end

Asymptotics tell you what happens eventually. The small-$n$ behaviour of the fork channels is just as sharply structured, and it is where the four channels cross paths.

**The collapse at $n = 2$.** Setting $n = 2$ makes the coin certain: $\frac12 + \frac12 = 1$. The entropy of a certainty is zero, so $X(2) = 1$ — the capacity channel is maximal, a full bit. Meanwhile
$$A(2) = \frac{\log_2 2}{4} = \frac14, \qquad g(2) = \frac54 - \frac34\log_2 3 = 0.0612781\ldots.$$
Here the reverse channel refuses to play: $1 - 4/n^2$ vanishes at $n = 2$, so $R(2)$ and $\mathrm{Is}(2)$ are infinite. The collapse point is a genuine singularity for half of the family, and only the three genuinely-defined channels have values there. (An informal tabulation had listed a different, finite figure for $g(2)$; the exact value above is $5/4 - (3/4)\log_2 3$, and it is the one consistent with the table's own $g\cdot n^2$ column, which reads $0.245112 = 4 \times 0.0612781$.)

**The crossing between $7$ and $8$.** At small $n$ the capacity channel dominates the ambiguity channel; at large $n$ the situation reverses, because $A(n)n^2 = \log_2 n$ grows without bound while $X(n)n^2$ settles at $2.885390$. So $A/X \to \infty$, and somewhere the two curves must cross. They cross exactly once in the integers, and the crossing is pinned to a single window:

> **The Crossing Theorem.** $A(7) < X(7)$ and $X(8) < A(8)$.

That the crossing is where it is comes down to two inequalities between integers. Writing the fork values at $n=7$ and $n=8$ in closed form and clearing denominators, the two comparisons reduce to
$$7^{100} < 3^{126}\cdot 5^{35} \qquad\text{and}\qquad 5^{40}\cdot 3^{24} < 2^{131}.$$
These are enormous integers — the first has $85$ digits — but they are integers, and comparing them is a finite computation with no floating-point ambiguity anywhere. It is a pleasing reduction: a question about transcendental entropies becomes a question about which of two specific $85$-digit numbers is larger. The margins are not huge (the ratio $A(7)/X(7)$ is $0.959$ and $A(8)/X(8)$ is $1.029$), which is exactly why an exact certificate rather than a decimal estimate is the right tool.

## How the constants get proved

None of the four laws needs heavy machinery. Every one of them is a squeeze between two elementary windows on the logarithm.

The first window is the pair of inequalities
$$u \;\le\; -\ln(1-u) \;\le\; u + 2u^2 \qquad (0 < u \le \tfrac12),$$
whose left half is the classical bound $\ln t \le t-1$ applied at $t = 1-u$, and whose right half is the same bound applied to $1/(1-u)$ together with $\frac{1}{1-u}\le 1 + u + 2u^2$. Feeding $u = 1/n^2$ into this window and rearranging gives an *explicit finite-$n$ error bound* for the gap channel:
$$\left|\,g(n)\,n^2 - (\log_2 e - 1)\,\right| \;\le\; \frac{1}{n\ln 2} \qquad (n \ge 2),$$
and $u = 4/n^2$ gives $\left|R(n)n^2 - 2\log_2 e\right| \le 16/(n\ln 2)$ for $n \ge 4$.

The capacity channel needs one order more, because its leading term is quadratic and so the linear terms must cancel exactly. The right tool is the symmetrised **fork function**
$$F(x) = (1+x)\ln(1+x) + (1-x)\ln(1-x),$$
in terms of which $X(n) = F(2/n)/(2\ln 2)$ — a small algebraic identity that already does most of the work, because it makes the symmetry of the situation manifest. A quadratic Taylor estimate with an honest cubic remainder, $|\ln(1+x) - (x - x^2/2)| \le 2|x|^3$ for $|x| \le \frac12$, applied to both halves of $F$ and added, yields
$$|F(x) - x^2| \le 6|x|^3 \qquad (|x| \le \tfrac12),$$
in which the odd terms have cancelled and the quadratic terms have doubled. Setting $x = 2/n$:
$$\left|\,X(n)\,n^2 - 2\log_2 e\,\right| \;\le\; \frac{24}{n\ln 2} \qquad (n \ge 4).$$

These are not merely limits, they are rates: at $n = 10^5$ the guaranteed accuracy of the capacity constant is about $3.5\times 10^{-4}$, and the observed accuracy is far better still. Dividing the $X$ estimate by the $g$ estimate gives the ratio law, and the resulting limit $6.51778$ is provably greater than $6$ — which is a formal refutation of the guess $X/g \to 2$, since a sequence has at most one limit.

## Why any of this matters

The fork channels are toy quantities, but the phenomenon they illustrate is not.

First, **near-cancellation is the enemy of heuristic asymptotics**. Every one of the four channels is "quadratic in the small parameter", and that shared description is precisely what made the wrong guess feel safe. The moment a definition subtracts one leading term from another — as $g$ does — the surviving constant is a *difference* of constants, and differences of constants know nothing about the tidy factors of $2$ that generated them. Anyone who has watched a numerical scheme lose four digits to catastrophic cancellation will recognise the pattern.

Second, **rates beat limits**. The squeeze arguments above do not just say "the limit is $2\log_2 e$"; they say how far you can be at any given $n$. That is what makes the small-$n$ facts — the collapse at $n = 2$, the crossing in $(7,8)$ — compatible with the large-$n$ facts rather than in tension with them. A channel can be dominant at $n=7$ and negligible at $n=8000$ without anything mysterious happening; the crossover point is computable, and here it is exactly located.

Third, **the same constants keep reappearing**. The number $2/(1-\ln 2)$ is not an artefact of the specific bias $1/n$. Replace the bias by $c/n$ for any fixed $c > 0$ and the numerator and denominator both rescale by $c^2$: the ratio is unchanged. The constant is a property of the pair of *germs* — the two analytic functions near zero — not of the parametrisation. That kind of rigidity is what separates a real law from a numerical coincidence.

Finally, there is the epistemological moral, which is the reason this particular story is worth telling at all. A clean heuristic produced the prediction $X/g \to 2$. A table of exact values produced $6.51778$. The table won. But the table alone could never have told you that the true value was $2/(1-\ln 2)$ rather than, say, $6.518$ or some other nearby number with no closed form. Only the analysis — the squeeze, the cancellation, the identification of $\log_2 e - 1$ as the surviving coefficient — turns six decimal digits into a theorem. Numbers refute; proofs explain.

