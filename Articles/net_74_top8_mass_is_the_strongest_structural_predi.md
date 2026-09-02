# The Knee at the End of the Tail

## What a five-domain study of attention can — and cannot — tell you

Imagine you are packing for a trip and you are allowed exactly one carry-on bag. You lay every possession you own on the floor, sorted from most to least important, and start filling the bag from the top of the pile. At some point you have packed *enough*: ninety percent of what you actually care about is in the bag. How many items did that take?

That number — call it the **knee** — is the central quantity of this article. It is not a metaphor. Machines that read text (the "attention" mechanisms inside modern language models) do exactly this at every step: they lay out all the words they have seen, score each one for relevance, sort, and then need only the top few to reconstruct almost all of the information they will use. Knowing where the knee sits tells an engineer how much memory to buy. Knowing *what determines* the knee tells a scientist something about the structure of language itself.

A recent study measured the knee across five kinds of text — computer code, English prose, mathematics, German prose, and French prose — and asked which of three structural descriptions of the attention pattern best predicts it. The three candidates were:

- the **entropy** of the attention distribution (how spread out it is, in the information-theoretic sense),
- the **top-8 mass** (what fraction of the total attention lands on the eight highest-scoring words),
- the **cross-head agreement** (how much the model's many parallel attention "heads" agree with each other).

The measured table was:

| domain | entropy | top-8 mass | head agreement | knee |
|---|---|---|---|---|
| code | 3.798 | 0.488 | 0.083 | 12 |
| prose-en | 3.801 | 0.488 | 0.082 | 16 |
| math | 3.615 | 0.526 | 0.086 | 16 |
| prose-de | 3.752 | 0.502 | 0.080 | 20 |
| prose-fr | 3.864 | 0.473 | 0.079 | >24 |

and the announced verdict was that top-8 mass is the winner, with a rank correlation of $+0.80$ against the knee, entropy a partial second at $-0.60$, and head agreement a dud at $-0.40$ — "constant, not a differentiator."

This article is about what happens when you take those five rows completely seriously, do the arithmetic exactly, and then ask the deeper question the numbers were meant to answer. Three things emerge, and all three are, in their own way, more interesting than the announced verdict.

---

## Act I: The arithmetic disagrees

Rank correlation is a beautifully robust idea. Forget the actual numbers; keep only their *order*. Code has the smallest knee, so its knee-rank is $1$; French prose the largest, so its rank is $5$; English prose and mathematics are tied at $16$, so each gets the average rank $2.5$. Do the same for a predictor column, then measure how well the two rank orders line up. The measure is Spearman's coefficient $\rho$, which is $+1$ for perfect agreement, $-1$ for perfect reversal, $0$ for no relationship.

Here are the four rank columns from the table, computed with the standard average-rank convention for ties:

$$\text{knee} : (1,\ 2.5,\ 2.5,\ 4,\ 5), \qquad \text{entropy} : (3,\ 4,\ 1,\ 2,\ 5),$$
$$\text{top-8} : (2.5,\ 2.5,\ 5,\ 4,\ 1), \qquad \text{head agr.} : (4,\ 3,\ 5,\ 2,\ 1).$$

Look at the top-8 column against the knee. Code and English prose both sit at $0.488$, the lowest tier — and their knees are $12$ and $16$, the two *smallest*. Mathematics has the largest top-8 mass, $0.526$, and a middling knee. French prose has the *smallest* top-8 mass, $0.473$, and the *largest* knee. That last pairing alone — smallest predictor, largest response — is a strongly *negative* signal, and it dominates.

Doing the sum exactly gives

$$\rho(\text{top-8}, \text{knee}) = -\tfrac{11}{38} \approx -0.289.$$

Not $+0.80$. Not even positive. Meanwhile,

$$\rho(\text{entropy}, \text{knee}) = \frac{7}{2\sqrt{95}} \approx +0.359, \qquad \rho(\text{head agr.}, \text{knee}) = -\frac{8}{\sqrt{95}} \approx -0.821.$$

Every one of the three reported coefficients is wrong in sign, in magnitude, or in both — and the *ordering* of the predictors is exactly inverted. The column dismissed as a constant, cross-head agreement, is the only one that clears the study's own pre-registered bar of $|\rho| \ge 0.7$. It is the strongest signal in the table by a wide margin, and it was thrown away.

Two natural objections deserve answers, and both have them.

*"French prose's knee was recorded as '>24' — surely that censoring changes things?"* It does not. Every value strictly greater than $20$ leaves French prose in last place in the rank order, and the rank order is all Spearman sees. Whether the true knee is $21$, $24$, or $10{,}000$, the three coefficients are unchanged.

*"Maybe the tie-handling convention is doing the work?"* It is not. There are two ties in the table (code/English in top-8 mass, English/math in the knee), so there are only a handful of ways to break them into strict orderings. Enumerate all of them. In every single case top-8 mass correlates *negatively* with the knee, entropy *positively*, and head agreement at $-0.7$ or below. No convention rescues the announced verdict.

---

## Act II: With five data points, a strong correlation is cheap

Suppose the arithmetic *had* come out as announced. Would $\rho = +0.80$ on five domains have meant anything?

Here is the way to ask that question honestly. Pretend the predictor column and the knee column have nothing whatever to do with each other. Then any of the $5! = 120$ possible alignments of the two rank orders is equally likely. How many of those $120$ produce a correlation of magnitude $0.7$ or more, purely by luck?

At five items, Spearman's coefficient takes a beautifully rigid form. If $D = \sum_i (r_i - s_i)^2$ is the total squared rank displacement between the two orderings, then

$$\rho = 1 - \frac{6D}{n(n^2-1)} = 1 - \frac{D}{20}.$$

So $\rho$ lives on a lattice: it can only be $1.00, 0.90, 0.80, \ldots, -1.00$ in steps of $0.10$. Counting the $120$ permutations by their value of $D$ gives the complete null distribution, and the answer to our question is a single exact fraction:

$$\Pr\big[\,|\rho| \ge 0.7\,\big] = \frac{28}{120} = \frac{7}{30} \approx 0.233.$$

**Nearly one random pairing in four clears the bar.** A threshold of $|\rho| \ge 0.7$, applied to five domains, is not a $5\%$ test — it is a $23\%$ test. Fire it at three independent predictors, as this study did, and the chance that at least one of them "confirms" by pure noise is better than one in two. The study pre-registered three hypotheses and reported one confirmation, one partial, and one refutation. That is very close to exactly what pure chance produces.

And it gets sharper. The one genuine signal in the table — head agreement, at $\rho \approx -0.82$ — has an exact one-sided $p$-value that depends on how the English/math knee tie is broken. Break it one way and the displacement is $D = 34$, giving

$$p = \frac{14}{120} = \frac{7}{60} \approx 0.117 \quad (\text{not significant at } 5\%).$$

Break it the other way and $D = 38$, giving

$$p = \frac{5}{120} = \frac{1}{24} \approx 0.042 \quad (\text{significant at } 5\%).$$

Two equally admissible conventions, opposite verdicts. When a coin-flip about a tie decides whether your strongest result is significant, the design has run out of resolution. Five domains simply cannot separate three hypotheses.

---

## Act III: The mechanism was right, and the correlation could never have shown it

Now for the part that redeems the whole enterprise. Alongside the correlations, the study offered a *mechanism*: the knee, it said, "is set by the residual spread after the top keys are captured, not by how concentrated the peak is." The mechanism lives in the tail.

That sentence is not a hypothesis awaiting more data. It is a **theorem**. And once proved, it shows that the correlations were never capable of testing it.

To state it, we need the right object. A **capture curve** is a function $c(k)$ giving the total attention mass carried by the $k$ heaviest keys. It starts at $c(0) = 0$, never decreases, never exceeds $1$, and climbs arbitrarily close to $1$. For a tolerance $\tau \in (0,1)$ — say $\tau = 0.9$ — the **knee** is

$$k^*(\tau) = \min\{\, k : c(k) \ge \tau \,\},$$

the smallest budget that captures a $\tau$-fraction of the attention. The **residual** after $r$ keys is $R(r) = 1 - c(r)$, the mass still out in the tail.

**The Tail Reduction Theorem.** *If the $r$ heaviest keys fall short of the tolerance — that is, $c(r) < \tau$ — then*
$$k^*(\tau) = r + \min\{\, j : c(r+j) \ge \tau \,\}.$$
*The knee splits exactly into a fixed head budget plus a knee computed entirely inside the residual curve.*

The proof is a one-line observation once stated: the knee is at least $r$ (since $r$ keys don't suffice), so writing $k^* = r + j$ and minimising over $j$ is the same minimisation. Trivial — and consequential, because it immediately yields:

**The Tail Determination Theorem.** *If two capture curves agree from index $r$ onward, and neither reaches the tolerance by index $r$, they have exactly the same knee — no matter how differently their heads behave.*

The knee is a functional of the tail. Full stop. Now, how badly does this break the head statistics?

**The Decoupling Theorem.** *For any head mass $c \in (0,\tau)$ and any target knee $k > 8$, there is a capture curve whose top-8 mass is exactly $c$ and whose knee is exactly $k$.*

The construction is a two-phase, or *staged*, curve: pile mass $c$ onto the very first key, hold flat through key $r = 8$, then ramp linearly, adding $(\tau - c)/(k-8)$ per key until the curve hits $\tau$ precisely at key $k$. Head and knee are independent dials.

Three corollaries follow, and each one dismantles a piece of the original study's logic.

*There is no law at all.* Since the same head mass $c = 1/2$ is compatible with a knee of $9$, of $10$, of $1000$, **no function whatsoever** maps top-8 mass to the knee. Not a linear one, not a monotone one, not a wild one. The map is not a map.

*The sign is free.* One can exhibit a pair of domains where more top-8 mass accompanies a *later* knee, and another pair where more top-8 mass accompanies an *earlier* knee. So a positive measured correlation is not evidence for the residual-spread mechanism — and neither is a negative one. Whatever sign the data had produced, it would have been consistent with the mechanism, which means it tested nothing. This is the sharpest finding here: the study's headline number was not merely miscomputed; even computed correctly it would have carried no information about the claim it was offered in support of.

*The tail can be arbitrarily loud.* For every $N$ there are two capture curves that are **identical on the first eight keys** — identical top-8 mass, identical head entropy, identical everything a head statistic can see — whose knees differ by at least $N$. Take two staged curves with the same $c$ and $r=8$ but knees $9$ and $9+N$.

So what *does* control the knee? The shape of the tail, and here the story becomes quantitative and genuinely useful. Two regimes bracket the possibilities:

**Light (geometric) tails.** If the residual decays like $R(r+j) \le R\rho^{\,j}$ for some ratio $\rho < 1$, then the knee arrives as soon as $R\rho^{\,j}$ dips below the missing mass $1-\tau$:
$$k^* \le r + \frac{\log\!\big(R/(1-\tau)\big)}{\log(1/\rho)}.$$
The knee grows *logarithmically* as you demand more coverage. Doubling your standards costs you a constant handful of extra keys.

**Heavy (Pareto) tails.** If instead the residual stays above $R/(j+1)$, then
$$k^* \ge r + \frac{R}{1-\tau} - 1.$$
The knee grows *linearly* in $1/(1-\tau)$ and diverges as $\tau \to 1$. Demanding $99.9\%$ coverage instead of $99\%$ costs you ten times the budget.

Same head. Wildly different engineering consequences. If you want to predict a domain's memory requirements, measure how its attention *decays*, not how tall its peak is.

---

## Coda: Every peak statistic is one-sided

There is a last, elegant twist, and it explains *why* head statistics keep failing in the same way.

Physicists studying localisation use a quantity called the **participation ratio**. Its reciprocal, the **collision mass** of the top $k$ keys, is
$$C(k) = \sum_{j<k} m_j^2,$$
where $m_j = c(j+1) - c(j)$ is the mass on the $j$-th heaviest key. If the mass spreads evenly over $n$ keys, $C = 1/n$; the smaller $C$ is, the more keys genuinely participate. It is the natural $\ell^2$ measure of concentration, and a strictly finer instrument than top-8 mass or entropy.

Apply Cauchy–Schwarz to the capture curve — the mass captured by $k$ keys is a sum of $k$ terms — and you get $c(k)^2 \le k \cdot C(k)$. At the knee, $c(k^*) \ge \tau$, so:

**The Participation Bound.** *If a domain's collision mass never exceeds $C$, then* $k^* \ge \tau^2 / C$.

A domain whose attention genuinely spreads over many keys *must* have a late knee. And the bound is sharp: the uniform domain, which splits mass $\tau/k$ evenly over $k$ keys, has collision mass exactly $\tau^2/k$ at its own knee $k$ — turning the Cauchy–Schwarz inequality into an equality. It also refines the cruder statement that $C(k)$ is bounded by the largest single-key mass, so the $\ell^2$ picture sits properly beneath the $\ell^\infty$ one.

But now the twist. Is there a matching upper bound — a guarantee that a *concentrated* domain has an *early* knee? No, and provably not:

**One-Sidedness.** *For every collision budget $C > 0$ and every target $N$, there exists a domain whose collision mass stays below $C$ at every prefix and whose knee exceeds $N$.*

Take the uniform domain over enough keys: its collision mass shrinks like $1/k$ while its knee grows like $k$. Spread thin enough and you satisfy any concentration budget while pushing the knee arbitrarily far out.

This is the general shape of the situation, and the honest summary of the whole affair. Every scalar summary of the *head* of an attention distribution — top-8 mass, entropy, collision mass — can bound the knee on **one side only**. It can tell you the knee is at least somewhere. It can never tell you the knee is at most somewhere. The interval $[\tau^2/C, \infty)$ that the bound leaves open is exactly where the tail does its work.

Which is, word for word, the mechanism the original study proposed. It was right. The evidence it offered could not have shown it, the arithmetic offered against it was wrong, and the design was underpowered by a factor of five — but the idea was right, and it turns out to be provable without measuring anything at all.

That is a strange and rather wonderful outcome. The correlation was noise. The intuition behind it was a theorem. And the moral for anyone who packs a bag, buys a memory budget, or reads a five-row table of coefficients is the same: the answer is not in the pile at the top. It is in the long, thin tail of everything you *almost* left behind.
