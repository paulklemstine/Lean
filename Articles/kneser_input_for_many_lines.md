# Three Lines Are Enough — and Four Are Not

*How a natural-looking rule about reaching every point of a finite plane turned out to be false, and what the true rule is instead.*

---

## A game played on a tiny plane

Pick a prime number $p$ — think of $p = 5$ — and build a plane out of it. Instead of the usual coordinates, the points of our plane are pairs $(x, y)$ where $x$ and $y$ are integers modulo $p$. There are exactly $p^2$ of them: for $p = 5$, twenty-five points arranged on a torus, where moving five steps to the right brings you back where you started. Mathematicians call this plane $\mathbb{F}_p^2$.

Now here is the game. I hand you a small number of **directions** — vectors $v_1, v_2, \dots, v_k$ in the plane, no two of them parallel. Along each direction $v_i$ you are permitted a restricted set of step-lengths: a set $S_i$ of scalars, always containing $0$ (you are allowed to skip a direction). Starting at the origin, you make exactly one move along each direction: you choose $s_1 \in S_1$, $s_2 \in S_2$, and so on, and you land at
$$s_1 v_1 + s_2 v_2 + \cdots + s_k v_k .$$

The set of all points you can land on is your **reach**:
$$\mathcal{R} = \{\, s_1 v_1 + \cdots + s_k v_k \;:\; s_i \in S_i \,\}.$$

The question is disarmingly simple: **when can you reach every point of the plane?**

If every $S_i$ were all of $\mathbb{F}_p$, you would trivially reach everything as soon as you had two non-parallel directions. The interest is in what happens when the step-sets are *deficient*. Define the **deficiency** of the $i$-th set as the number of forbidden step-lengths,
$$d_i = p - |S_i| ,$$
and the **total deficiency** as $D = d_1 + d_2 + \cdots + d_k$. A set with $d_i = 0$ is unrestricted; a set with $d_i = p - 1$ is the useless singleton $\{0\}$.

Intuitively, more directions should buy you more freedom, so you should be able to afford more deficiency. The natural guess — and the conjecture this article is about — is that the exchange rate is exactly $p-1$ per extra direction beyond the second:

> **Conjecture.** If the directions are pairwise non-parallel, each $S_i$ contains $0$, and
> $$D \le (k-2)(p-1),$$
> then the reach is all of $\mathbb{F}_p^2$.

Two directions with full sets already span the plane with zero deficiency budget, and each additional direction seems to add a whole extra line's worth of slack, $p-1$. The formula is clean, the heuristics are good, and — as we will see — a serious counting argument from the polynomial method predicts exactly this threshold.

It is false.

But the story of *how* it fails, and of the sharp criterion that replaces it, is more interesting than the conjecture itself.

---

## The case of three lines: a covering argument

Start with $k = 3$, where the conjectured bound reads $D \le p-1$, i.e. $D < p$. Here the conjecture is true, and the proof is a small gem.

> **Three-Line Theorem.** Let $p$ be prime and let $v_1, v_2, v_3$ be pairwise non-parallel directions in $\mathbb{F}_p^2$. Let $S_1, S_2, S_3 \subseteq \mathbb{F}_p$ satisfy
> $$(p - |S_1|) + (p - |S_2|) + (p - |S_3|) < p.$$
> Then every point of $\mathbb{F}_p^2$ can be written as $s_1v_1 + s_2v_2 + s_3v_3$ with $s_i \in S_i$.

Why? Fix a target point $t$. Because $v_1$ and $v_2$ are not parallel, they form a basis, so there are unique scalars $\alpha, \beta$ with
$$t = \alpha v_1 + \beta v_2,$$
and there are unique scalars $\gamma, \delta$ expressing the third direction in that basis,
$$v_3 = \gamma v_1 + \delta v_2 .$$
Crucially, $\gamma \ne 0$ and $\delta \ne 0$: if $\gamma$ vanished, $v_3$ would be parallel to $v_2$, and if $\delta$ vanished, $v_3$ would be parallel to $v_1$. Pairwise non-parallelism is exactly the hypothesis that keeps both coefficients alive.

Now suppose you decide in advance to take $s_3 = c$ along the third direction. Then the first two steps are completely determined:
$$s_1 = \alpha - \gamma c, \qquad s_2 = \beta - \delta c .$$
There is a *one-parameter family* of representations of $t$, parameterised by $c \in \mathbb{F}_p$, and it is the only family there is. So if $t$ is unreachable, then **every single value of $c$ must be sabotaged**: for each $c$, at least one of the three requirements
$$c \in S_3, \qquad \alpha - \gamma c \in S_1, \qquad \beta - \delta c \in S_2$$
must fail.

That is a covering statement. The values of $c$ sabotaged by the third set form the complement of $S_3$, of size $d_3$. The values sabotaged by the first set are $c = (\alpha - u)/\gamma$ for $u$ outside $S_1$ — and since $\gamma \ne 0$, that is an *injective* relabelling, so there are at most $d_1$ of them. Similarly at most $d_2$ from the second set. Three sets of sizes at most $d_1, d_2, d_3$ must cover all $p$ values of $c$, so
$$p \le d_1 + d_2 + d_3,$$
contradicting our hypothesis. Hence $t$ was reachable after all. $\blacksquare$

The whole proof is: *a missed point forces a line's worth of coincidences, and there are not enough forbidden values to supply them.* Non-parallelism enters only to guarantee that the two "sabotage" maps are bijections rather than collapses. And the bound is sharp: configurations with $D = p$ that miss a point exist in abundance — an exhaustive search over $p=5$ finds $14{,}400$ of them.

---

## Three lines inside a crowd

The three-line theorem has an immediate and surprisingly powerful consequence for arbitrary $k$. Suppose you have a hundred directions and a hundred step-sets, all containing $0$. Pick any three indices $i, j, l$ you like. Because $0$ belongs to every other set, you may simply *decline to move* along the other ninety-seven directions. The remaining three-direction configuration is still pairwise non-parallel, so the theorem applies:

> **Triple Criterion.** For any $k \ge 3$ pairwise non-parallel directions and any step-sets containing $0$: if some three distinct indices satisfy
> $$d_i + d_j + d_l < p,$$
> then the reach is the whole plane.

Equivalently — since the three smallest deficiencies are the best candidates — the reach is everything whenever the three smallest deficiencies sum to less than $p$. Note what this criterion does *not* care about: the number of directions, the total deficiency, the geometry beyond pairwise non-parallelism. A single sufficiently rich triple carries the entire configuration. In particular, if the total deficiency $D$ is less than $p$, the criterion applies to any three indices, so **$D \le p - 1$ always suffices**, for every $k$.

---

## Where the conjecture breaks: the harmonic quadruple

So why is the conjectured budget $(k-2)(p-1)$ wrong? Because deficiency is a scalar, and a scalar cannot see geometry. Total deficiency $(k-2)(p-1)$ can be spent wisely — spread evenly, keeping every triple rich — or it can be spent perversely, hoarded onto a few directions in a way that creates a genuine obstruction.

Here is the perverse configuration. Take the four directions
$$v_1 = (1,0), \quad v_2 = (0,1), \quad v_3 = (1,1), \quad v_4 = (-1,1),$$
a *harmonic quadruple*: four points of the projective line in harmonic position. Give the first two directions almost everything, forbidding only the single step-length $1$:
$$S_1 = S_2 = \mathbb{F}_p \setminus \{1\}, \qquad d_1 = d_2 = 1,$$
and give the last two directions only the two step-lengths $0$ and $1$:
$$S_3 = S_4 = \{0, 1\}, \qquad d_3 = d_4 = p-2 .$$
Total deficiency: $1 + 1 + (p-2) + (p-2) = 2(p-1) = (4-2)(p-1)$. Exactly the conjectured budget.

Now try to reach the point $(1, 2)$. Writing out the coordinates, we need
$$s_1 + s_3 - s_4 = 1, \qquad s_2 + s_3 + s_4 = 2 .$$
There are only four choices of $(s_3, s_4) \in \{0,1\}^2$, and each is fatal:

| $(s_3, s_4)$ | forced value | verdict |
|---|---|---|
| $(0,0)$ | $s_1 = 1$ | forbidden |
| $(1,0)$ | $s_2 = 1$ | forbidden |
| $(0,1)$ | $s_2 = 1$ | forbidden |
| $(1,1)$ | $s_1 = 1$ | forbidden |

Every route to $(1,2)$ passes through the one step-length we removed. The point is unreachable, and the conjecture is dead at $k = 4$.

It stays dead for larger $k$. Pad the configuration with extra directions $(1, 2), (1, 3), \dots$ — any distinct new slopes, so the family stays pairwise non-parallel — and give each of them the trivial step-set $\{0\}$. Each padded direction adds exactly $p-1$ to the deficiency and nothing to the reach, so the total lands precisely on $(k-2)(p-1)$ while $(1,2)$ remains unreachable. Since a pairwise non-parallel family in $\mathbb{F}_p^2$ can have at most $p+1$ members (that is how many directions the plane has), this covers the entire feasible range:

> **Sharpness Theorem.** For every prime $p \ge 3$ and every $k$ with $4 \le k \le p+1$, there is a pairwise non-parallel family of $k$ directions and step-sets containing $0$ with total deficiency exactly $(k-2)(p-1)$ whose reach is not the whole plane.

And in this family, every triple of distinct indices has deficiency sum at least $p$ — the cheapest triple being $1 + 1 + (p-2) = p$ exactly. So the strict inequality in the Triple Criterion cannot be relaxed to $\le p$: the criterion is not merely sufficient but *optimal* as a statement about triples.

---

## The near miss: why the wrong bound looked so right

The conjectured threshold was not plucked from the air. Alon's Combinatorial Nullstellensatz — the polynomial method's workhorse — attacks precisely this problem. Encode the two coordinates of the direction family as linear forms
$$L_1 = \sum_i (v_i)_1 X_i, \qquad L_2 = \sum_i (v_i)_2 X_i,$$
and consider the product $L_1^{\,p-1} L_2^{\,p-1}$, of degree $2(p-1)$. The Nullstellensatz says: if some monomial $\prod_i X_i^{e_i}$ with $e_i < |S_i|$ and $\sum_i e_i = 2(p-1)$ has a **nonzero coefficient** in this product, then every point of the plane is reachable.

When is such a monomial even available? The exponent $e_i$ can be at most $|S_i| - 1$, so the total exponent budget is
$$\sum_i (|S_i| - 1) = k(p-1) - D,$$
and this is at least the required $2(p-1)$ precisely when
$$D \le (k-2)(p-1).$$

There is the conjectured bound, derived exactly. The conjecture is the statement "the degree budget suffices" — and the degree budget is genuinely necessary. What the conjecture silently assumes is that *some* admissible coefficient is nonzero. That is the gap, and the harmonic quadruple walks straight through it: in the counterexample configurations the budget is met with a single admissible monomial to spare, and its coefficient is $0$. The criterion is not wrong; it is simply silent.

---

## What survives

The conjecture is false, but its intuition is not worthless. Two positive results salvage most of it.

**First, one full set restores the bound.** Suppose one of the step-sets, say $S_{i_0}$, is all of $\mathbb{F}_p$. Then $D \le (k-2)(p-1)$ *does* force the reach to be everything. The reason is a change of viewpoint: measure a point $r$ by $\det(r, v_{i_0})$, which records which line parallel to $v_{i_0}$ it lies on. This linear functional turns the problem into one about sumsets in $\mathbb{F}_p$, where the Cauchy–Davenport inequality applies: a sum of sets $A_1 + \cdots + A_m$ in $\mathbb{F}_p$ has size at least $\min\bigl(p,\ \sum |A_i| - m + 1\bigr)$. Iterating over the $k-1$ directions other than $i_0$, the deficiency bound is exactly what makes the estimate reach $p$ — so the reach meets every line parallel to $v_{i_0}$ — and then the unrestricted set $S_{i_0}$ slides freely along each such line, sweeping out the whole plane.

**Second, even without a full set, the bound buys surjectivity onto every quotient line.** For *any* configuration with $D \le (k-2)(p-1)$ and any index $i_0$, the reach meets every line parallel to $v_{i_0}$. Equivalently, the complement of the reach never contains a whole line in any of the $k$ directions. So a configuration obeying the conjectured bound can only miss a *sparse* set of points — never a line's worth. The harmonic counterexamples honour this dramatically: for every prime and every admissible $k$ tested, the reach misses exactly one point, $(1,2)$, out of $p^2$.

Put together, the landscape is now fully mapped. The conjectured threshold $(k-2)(p-1)$ is the correct degree budget, and it delivers line-by-line surjectivity for free, and full spanning when one set is unrestricted — but as a criterion for spanning in general it fails for every $k \ge 4$, at every prime, by exactly one point. The correct universal criterion is the triple criterion: **the reach is everything as soon as three of the directions have deficiencies summing to less than $p$**, and no weaker inequality on triples will do.

---

## The moral, and the road ahead

The failure here is a failure of *aggregation*. Total deficiency is one number; spanning is a geometric property. When the deficiency is spread out, the plane is easy to fill; when it is concentrated on a harmonically-positioned quadruple, one point can be walled off no matter how generous the total budget. The three-line theorem is robust precisely because it refuses to aggregate: it looks at three directions and asks whether *they* are rich enough, and a triple's richness is not something the rest of the configuration can dilute.

What is not yet settled is the exact classification. Given a prime $p$ and a list of deficiencies $d_1 \le d_2 \le \cdots \le d_k$, when does *some* pairwise non-parallel configuration with those deficiencies fail to span? The triple criterion says that $d_1 + d_2 + d_3 \ge p$ is necessary for failure. Computation shows it is not sufficient: at $p=5$ the profiles $(0,2,3,3)$, $(1,2,2,2)$ and $(2,2,2,2)$ satisfy it yet always span, as does $(1,3,3,4)$ at $p=7$. In each of those cases the obstruction is projective rather than numerical: there simply is no way to arrange four indices with the available set sizes into the harmonic cross-ratio pattern that makes the walling-off work. Pinning down the exceptional list — turning "harmonic position" from a lucky construction into a classification theorem — is the natural next problem, and the one the sharp triple criterion has now made tractable.

Three lines are enough. Four, arranged just so, are not.
