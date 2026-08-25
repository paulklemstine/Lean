# The Dial That Tuned Itself to Nothing

## What a portfolio of algorithms can — and cannot — learn from what it can see

There is a moment familiar to anyone who has ever tried to make a computer smarter about its own work. You have five algorithms for the same job. None of them is best. Each wins sometimes. So you do the obvious thing: you look at the input, you learn which algorithm tends to win on inputs that look like that, and you route accordingly. A dial, tuned by data.

And then the dial turns itself to zero. It settles on "always run the same algorithm," refuses to move, and reports an improvement of exactly $0.000$. Worse, when you replace the tuned dial with a machine-learned rule, performance gets *substantially worse* — the learned rule is beaten by the simplest possible strategy, the one that ignores the input entirely.

The instinct is to blame the tuning. Bad features. Too little data. Wrong model class. This article is about a case where all three explanations are wrong, and where the null result turns out to be a theorem rather than a failure — a theorem with a clean, exact statement about exactly when routing can help, and how much.

## The setting: five factoring algorithms and one hidden number

Concretely: we are handed integers $N$, each the product of two primes, and we want to split them. We have a portfolio of five classical methods — Pollard's rho, the $p-1$ method with a small bound, the $p-1$ method with a large bound, Fermat's difference-of-squares method, and plain trial division. On each $N$, one of them finishes first.

Tabulate who wins, over a large sample, and you get a distribution of *winner shares*: rho wins about $58\%$ of the time, the small-bound $p-1$ method about $34.5\%$, the large-bound version $4.5\%$, Fermat $2.8\%$, trial division a fraction of a percent. No universal winner. A portfolio, genuinely.

Now the crucial observation. Slice the data by anything you can *read off* $N$ — its bit length, how balanced its two prime factors are, any quintile of any such statistic — and the winner shares barely move. They are flat. Whatever decides the winner, it is not a function of the visible features of $N$.

What does decide the winner? For the $p-1$ family, it is the *powersmoothness of $p-1$*, where $p$ is a prime factor of $N$. Call a number $n$ **$B$-powersmooth** if every prime power $p^k$ dividing $n$ is at most $B$. When $p-1$ is $256$-powersmooth, the $p-1$ method with bound $256$ walks straight to the factor. When it is not, that method is useless and rho takes over.

And here is the point: powersmoothness of $p-1$ is a property of the *factorisation you do not have*. It is not visible in $N$. To make this precise rather than merely plausible, consider these two integers:

$$1085683 = 1051 \times 1033, \qquad 1723933 = 1319 \times 1307.$$

Both are exactly $21$ bits. Both are products of two primes of exactly $11$ bits each — perfectly balanced semiprimes, indistinguishable on every visible axis one usually measures. But $1051 - 1 = 2 \cdot 3 \cdot 5^2 \cdot 7$ and $1033 - 1 = 2^3 \cdot 3 \cdot 43$ are both $256$-powersmooth, while $1319 - 1 = 2 \cdot 659$ and $1307 - 1 = 2 \cdot 653$ are not, since $659$ and $653$ are primes far above $256$. The same visible profile; opposite hidden class; opposite winner. The channel that organises the whole experiment is, in the strict sense, **invisible**.

Once you see this, the null dial stops being a disappointment and starts being something you ought to be able to *prove*.

## Making "invisible" precise

Strip away the number theory. What is left is a small, exact piece of probability.

There is a finite set of instances, each with a weight (its probability). There is a finite portfolio of members. Running member $s$ on instance $\omega$ costs $c(\omega,s)$. A scheduler sees not $\omega$ itself but an observation $\varphi(\omega)$ — the visible features — and must pick a member from that alone. Such a rule is a function $\pi$ from observations to members, and its expected cost is $\mathbb{E}[c(\omega, \pi(\varphi(\omega)))]$.

Three benchmarks bracket the problem:

- the **oracle**, $\mathbb{E}[\min_s c(\omega,s)]$, which chooses with hindsight and is unattainable;
- the **best static member**, $\min_s \mathbb{E}[c(\omega,s)]$, the do-nothing baseline;
- the **dial value**, the cost of the best rule that reads $\varphi$.

The observation $\varphi$ carves the instance space into *fibers*: one fiber per possible observed value. Write $V(o,s)$ for the total weighted cost of member $s$ on the fiber over $o$, and $\mu(o)$ for the total weight of that fiber. The first and most useful fact is that everything decomposes fiberwise: **every rule $\pi$ costs exactly $\sum_o V(o,\pi(o))$**. A scheduler makes one independent decision per fiber, and pays the sum.

That single identity gives the whole theory. The best possible rule picks, on each fiber, the member minimising $V(o,\cdot)$, so the **dial value equals $\sum_o \min_s V(o,s)$** — a quantity you can compute by scanning a table once, and one that is actually attained by an explicit rule.

Now say the observation is **invisible** for the portfolio if there are numbers $m(s)$ with
$$V(o,s) = \mu(o)\, m(s) \quad \text{for every fiber } o \text{ and every member } s.$$
In words: conditioning on what you can see does not change any member's average cost. This is exactly the flatness of the winner shares across bit-length and balance quintiles, written as an equation.

**Theorem (no dial edge).** *If the observation is invisible, then every rule that schedules on it costs at least as much as the best static member. The optimal dial is the do-nothing dial.*

The proof is two lines once you have the decomposition: the rule pays $\sum_o \mu(o) m(\pi(o))$, and since the fiber masses are nonnegative and sum to $1$, that is a weighted average of the numbers $m(s)$, hence at least $\min_s m(s)$, which is what the best static member pays.

There is a strict version, and it is the one that explains the second half of the empirical story.

**Theorem (a tuned rule can only hurt).** *If a rule deviates, on a fiber of positive probability, toward a member whose conditional mean is not optimal, it is strictly worse than doing nothing.*

So the measured $\Delta = 0.000$ for the tuned dial and the measured degradation of the learned rule are not artifacts of a bad fit. They are the two directions of a theorem. Any learner that responds to invisible features can only lose, and loses in proportion to how often it responds.

## Exactly when a dial *does* help

The negative result invites the sharp question: drop invisibility, and characterise precisely when routing pays. It has a surprisingly crisp answer.

**Theorem (dial edge criterion).** *An optimised rule strictly beats the best static member if and only if **every** member of the portfolio is strictly beaten on at least one fiber.*

The "only if" direction is the interesting one, and it says something counterintuitive about portfolios. A dial is worthless the moment a *single* member is fiberwise unbeatable — even if all the other members trade places wildly across fibers. One universal champion, and the entire routing problem collapses, no matter how much structure is visible elsewhere in the table.

Around this criterion sits a small hierarchy of facts that together form a complete value-of-information theory for finite portfolios:

- **The ladder.** Oracle $\le$ dial value $\le$ best static member. Routing is never worse than doing nothing (if you optimise it) and never better than hindsight.
- **Monotonicity of information.** If one observation is a function of another — coarser — then the finer observation is worth at least as much. Refining features cannot hurt.
- **The gap is an optimisation over members.** Define the *fiberwise regret* of member $s$ as the total amount by which $s$ is beaten by the fiberwise best, summed over fibers. Then the dial gain (best static minus dial value) is exactly the *smallest* fiberwise regret in the portfolio. So the gain is not merely bounded by member-level quantities; it *is* one.
- **What a null measurement certifies.** A dial gain of zero holds if and only if some single member minimises the conditional cost on every fiber. It certifies a fiberwise champion — nothing more. In particular it does *not* certify that the observation carries no information.

That last caveat deserves a concrete counterexample, and it is a two-line one. Take two instances of probability $1/2$ each; let *every* member cost $0$ on the first and $2$ on the second. The members are indistinguishable, so the dial gain is $0$ on even the finest observation — yet the observation tells you everything about the cost. A null dial is one-sided evidence.

## Knife edges and stability

Exact invisibility is an equation, and no measurement will ever certify an equation. So the theorem needs a stable version.

Call an observation **$\varepsilon$-invisible** if on every fiber, every member's conditional cost sits within $\varepsilon$ times the fiber mass of its global mean:
$$\bigl| V(o,s) - \mu(o) m(s) \bigr| \le \varepsilon\, \mu(o).$$

**Theorem (stability).** *Under $\varepsilon$-invisibility the best static member costs at most $\min_s m(s) + \varepsilon$, the optimal dial costs at least $\min_s m(s) - \varepsilon$, and therefore*
$$\text{best static} - \text{dial value} \le 2\varepsilon.$$
*Moreover every rule on such an observation is within $2\varepsilon$ of doing nothing.*

At $\varepsilon = 0$ this is the original theorem. Away from zero it is a genuinely usable certificate: measure near-invisibility of your features and you have bounded, in advance, the best possible payoff of *any* router built on them.

The constant $2$ cannot be improved. The witness is a pleasantly simple family: $n+1$ instances of equal probability, $n+1$ members, and a cost of $-1$ when member and instance match, $+1$ otherwise. Every member wins on exactly one instance. This portfolio is $1$-invisible about the mean profile $m \equiv 0$, its best static member costs $(n-1)/(n+1)$, its optimal dial costs $-1$, and the gap is exactly
$$\frac{2n}{n+1} \longrightarrow 2.$$
So the bound is approached but never reached, for every $\varepsilon$.

## The tail no median can see

The experiment also reported a strange pair of numbers: a mean regret of $3.117$ against the oracle, and a *median* regret ratio of exactly $1.000$ for every strategy tried. Half the time, the best static strategy ties the oracle exactly. The loss lives entirely in a minority of instances.

Is that a quirk of the sample? No — it is unavoidable in principle.

**Theorem (median blindness).** *For every level $M$ there is a two-instance, two-member portfolio whose optimal static strategy ties the oracle on more than half the probability mass — median regret ratio exactly $1$ — while its mean regret ratio exceeds $M$.*

The witness is small enough to check by hand: put mass $3/4$ on a "bulk" instance and $1/4$ on a "tail" instance; let the first member cost $1$ on the bulk and $4M+4$ on the tail, the second cost $8M+8$ on the bulk and $1$ on the tail. The oracle pays $1$ everywhere; the first member is optimal and ties the oracle on mass $3/4$; its mean regret ratio is $M + 7/4$. The median is uninformative by construction, and no median-based diagnostic will ever see the tail.

And the tail in the measured portfolio is not an outlier artifact either, because a reverse Markov inequality forces it. If a cost is bounded above by $K$ and has mean $R$, then the event that the cost exceeds $t$ must carry probability at least $(R - t)/(K - t)$. In the measured cell, the best static member has mean $4.117$ and no run costs more than $1179/140 \approx 8.421$; taking $t = 1$ (the oracle's cost) forces at least $0.42$ of the mass into the losing set. That is precisely the complement of rho's $58\%$ winner share. The fat tail is not an accident of sampling; it is arithmetic.

## What you may not delete, and what you may

A portfolio with five members invites pruning. Trial division wins two runs in a thousand — surely it can go?

Here the discipline matters, and it is easy to get wrong. A comparison of *means* is not a licence to eliminate. Take two instances with masses $3/4$ and $1/4$, and two members costing $(1,5)$ and $(5,1)$ respectively. The first has mean $2$, the second mean $4$ — twice as expensive. Delete the expensive one and the oracle's expected cost jumps from $1$ to $2$. The member with the worse mean was the only thing keeping the tail cheap.

What *is* safe? Two certificates, of increasing subtlety:

- **Pointwise dominance.** If member $a$ is at least as cheap as member $b$ on every single instance, deleting $b$ changes the oracle nowhere.
- **Fiberwise dominance.** If $a$ beats $b$ on every fiber of the observation, deleting $b$ changes neither the optimal dial value nor the best static value.

And what does dominance in *distribution* buy? Exactly the mean inequality, and only in one direction. If $X$ exceeds every threshold no more often than $Y$ does, then $\mathbb{E}[X] \le \mathbb{E}[Y]$ — a clean consequence of the layer-cake identity $\mathbb{E}[X] = \sum_{t\ge 0} \Pr[X > t]$ for integer-valued costs. The converse fails at once: with $X$ equal to $0$ or $10$ with equal probability and $Y$ constantly $6$, the mean of $X$ is $5 < 6$, yet $X$ exceeds $6$ half the time and $Y$ never does.

There is one more trap, and it is the subtlest of the lot. Suppose you first delete everything deletable — make the portfolio **irredundant**, so no member is fiberwise beaten by another — and *then* measure a small dial gain. Surely now the small gain means there is little pairwise structure left? No. There is an explicit three-instance, three-member portfolio, irredundant for every parameter $e > 0$, whose dial gain is exactly $2e/3$ while its first two members swap places with mass $10/3$ in *both* directions. Send $e$ to zero: the ratio of hidden pairwise structure to measured gain is unbounded. No constant, and no function of the portfolio size, controls it. Pairwise trade-offs must be measured pair by pair.

For two members, incidentally, there is a complete and decidable answer: the dial gain equals the smaller of the two **swap masses** — the total amount by which each member exceeds the other on the fibers where it loses — so a dial helps for a pair exactly when both swap masses are positive.

## Buying the invisible

If the organising channel cannot be seen, and no rule built on visible features can help, the only remaining move is to *pay* for a look.

The economics are exact. A probe that reveals the hidden class and costs $\kappa$ per instance beats the best static schedule if and only if $\kappa$ is less than the static regret — in the measured cell, if and only if $\kappa < 3.117$. Every unit of probe budget below that threshold is well spent, and every unit above it is wasted. No tuning required; the threshold is a subtraction.

What would such a probe be? Exactly the thing the hidden channel is about: a short, budget-capped run of the $p-1$ method used not as a factoring attempt but as an *observation*. And it provably works, because of an old fact given a new job. If $p-1$ is $B$-powersmooth and $L = \mathrm{lcm}(1,2,\dots,B)$, then for every $a$ not divisible by $p$,
$$p \mid a^{L} - 1 .$$
So $\gcd(a^L - 1, N)$ exposes $p$ whenever $p$ lies in the smooth class. A capped $p-1$ probe is a genuine, one-sided measurement of the hidden coordinate — and the value-of-information theorems are therefore about something real rather than a hypothetical.

Finally: if the probe delivers not a yes/no but an *ordered* readout — a smoothness quantile — one would like the optimal schedule to be a simple threshold in that number. It is, under exactly the right structural hypothesis. If the conditional costs have **decreasing differences** in (quantile, member) — raising the observed quantile never raises a later member's cost relative to an earlier one — then a *monotone* rule attains the optimal dial value: a discrete Topkis theorem. The set of quantiles on which any member is played is an interval, and for two members the rule is literally a threshold. The hypothesis is not decorative: an explicit $2 \times 2$ cost matrix without decreasing differences has a non-monotone optimal schedule. Ordered observations do not, by themselves, make schedules ordered.

## The moral

A null result in algorithm selection usually reads as a failure of engineering. Here it reads as a measurement of *where the information is*. The five factoring methods are organised by a single hidden scalar; the visible features are, provably and demonstrably, orthogonal to it; and once that is written as an equation, the flat dial and the counterproductive learner are consequences rather than symptoms.

What the theory then hands back is a short list of things worth doing instead of tuning. Compute the dial value — one pass over a table — and you know the *ceiling* of every router you could build. Measure near-invisibility and you have bounded that ceiling in advance. Compare the static regret with the price of a probe and you know whether to buy information at all. And when you prune, prune on dominance, never on means.

The most useful thing a dial can tell you, it turns out, is that it has nothing to tell you.
