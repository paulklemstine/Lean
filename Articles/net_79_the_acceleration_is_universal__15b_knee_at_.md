# The Knee in the Curve: How Right Triangles Explain a Memory Cliff

## A budget that refuses to behave

Suppose you are running a language model that must keep a long conversation in mind. Every token it has already read leaves behind a small packet of state — a *key* — and each new token looks back over all of them, distributing a fixed amount of attention across the whole history. The packets are expensive: they live in fast memory, and fast memory is the scarcest thing in the machine.

So you ask the obvious engineering question. *How many of those packets do I actually need to keep?*

Rank the keys by how much attention they receive, keep the top $k$, throw the rest away, and ask what fraction of the total attention mass you have preserved. Call that fraction the **retained mass** $R(n,k)$, where $n$ is the length of the context. Fix a tolerance — say you insist on retaining $98.5\%$ of the mass — and define the **knee** $k^{\star}$ to be the smallest budget that clears the bar. That single integer is the answer to the engineering question, and if you are provisioning hardware it is the number you write on the purchase order.

Measuring this number across two model sizes and four context lengths produced a table that broke every intuition anyone had brought to it:

| model | @512 | @1024 | @2048 | @4096 |
|---|---|---|---|---|
| small | 16 | 20 | 24 | **40** |
| large | 16 | 16 | 18 | **56** |

Read the rows. The small model's budget grows placidly — $+4$, $+4$ — and then jumps by $16$. The large model barely moves at all — $0$, $+2$ — and then jumps by $38$. The *acceleration factor* is $4$ for the small model and $19$ for the large one. And notice the columns: at $512$, $1024$ and $2048$ the large model is the more frugal of the two, needing fewer keys per unit of context. At $4096$ it is the more expensive: $56$ against $40$.

The ordering **inverts**.

That is not a rounding artefact, and it is not a statement about one particular pair of models. It is a structural fact about what retained-mass knees can do, and the surprising route to understanding it runs through the oldest theorem in mathematics.

## Making the question exact

To reason about knees rather than merely measure them, we need a clean object. An **attention profile** is a positive sequence $w_0, w_1, w_2, \dots$, where $w_i$ is the mass carried by the $i$-th most attended key. Its **head mass** is the partial sum
$$H_w(n) = \sum_{i<n} w_i,$$
and the **retained mass** of a top-$k$ truncation inside a context of length $n$ is
$$R_w(n,k) = \frac{H_w(\min(k,n))}{H_w(n)}.$$
Given a **gate** $\tau \le 1$, the **knee** $k^{\star}(w,n,\tau)$ is the least $k$ with $R_w(n,k) \ge \tau$. Two facts hold for every positive profile and are used constantly: the knee genuinely passes ($\tau \le R_w(n,k^{\star})$), and any $k$ that passes bounds the knee from above. Between them they give a *bracket* principle: if $k$ fails and $k+1$ passes, the knee is exactly $k+1$.

The simplest interesting profiles are the **geometric** ones, $w_i = r^i$ for some decay ratio $0 < r < 1$. Small $r$ means attention is hoarded by the first few keys; $r$ close to $1$ means attention is spread almost flat across the whole context. For these, everything is computable:
$$R_{r}(n,k) = \frac{1 - r^{\min(k,n)}}{1 - r^{n}}.$$

## The rearrangement at the heart of it

The first theorem says something you would guess and then fail to prove naively.

> **Ratio monotonicity.** If $0 < r \le s < 1$, then $R_s(n,k) \le R_r(n,k)$ for every context $n \ge 1$ and every budget $k$. Consequently the knee is monotone: $k^{\star}(r,n,\tau) \le k^{\star}(s,n,\tau)$.

In words: a profile that decays more slowly retains less mass at every budget, and therefore never needs fewer keys. The naive attempt — compare $(1-r^k)/(1-r^n)$ with $(1-s^k)/(1-s^n)$ by moving numerator and denominator separately — collapses immediately, because raising the ratio pushes *both* in the same direction. What actually carries the proof is a rearrangement. Split the context at $m = \min(k,n)$ into a head $\{0,\dots,m-1\}$ and a tail $\{m,\dots,n-1\}$. Cross-multiplying the two retained masses reduces the whole claim to
$$\Big(\sum_{i<m} s^i\Big)\Big(\sum_{m \le j < n} r^j\Big) \;\le\; \Big(\sum_{i<m} r^i\Big)\Big(\sum_{m \le j < n} s^j\Big),$$
and this in turn follows term by term from the elementary inequality $s^i r^j \le r^i s^j$ whenever $i \le j$: writing $j = i + d$, both sides share the factor $r^i s^i$ and what remains is $r^d \le s^d$. Head indices are always below tail indices, so the hypothesis $i \le j$ is free. It is a one-line inequality doing a genuinely non-obvious job.

This is the engine. Any statement about which of two profiles is *steeper* now converts, with no analysis and no calculus, into a statement about which needs more keys.

## Enter the right triangle

Here is where the story takes its turn. Take a Pythagorean triple: integers with $a^2 + b^2 = c^2$, say $3^2 + 4^2 = 5^2$. Divide through by $c^2$ and you obtain a point on the unit circle:
$$\left(\frac{a}{c}\right)^2 + \left(\frac{b}{c}\right)^2 = 1.$$
Now read each of the two **leg ratios** $a/c$ and $b/c$ as a decay ratio, generating a geometric attention profile. The triple gives you not one profile but a *rigidly coupled pair*: the two ratios cannot both be small, and cannot both be large. They are locked together by the circle.

That lock has consequences that are surprisingly sharp.

> **The universal short-leg budget.** For every Pythagorean triple with $0 < a \le b$, and at every context length whatsoever, the short-leg profile clears the $98.5\%$ gate with $13$ keys.

The mechanism is pure elementary geometry. Since $a \le b$ and $a^2 + b^2 = c^2$, the shorter leg satisfies $2a^2 \le c^2$, so $(a/c)^2 \le 1/2$ and hence $a/c \le 0.708$. Now use the exact closed form: for a geometric profile, any $K$ with $r^K \le 1 - \tau$ clears the gate at every context, with no dependence on $n$ at all. And
$$r^{13} = (r^2)^6 \cdot r \le \left(\tfrac12\right)^6 \cdot 0.708 = 0.01106\ldots \le 0.015 = 1 - 0.985.$$
Thirteen keys. Not thirteen *on average*, not thirteen *asymptotically* — thirteen for every right triangle with integer sides and every context length in existence.

It is worth pausing on how tight this route is. A cruder, more generally applicable certificate — the tail-sum bound $r^K/(1-r) \le 1-\tau$ — would have given $16$ instead of $13$. The gap of three keys is precisely the $1/(1-r)$ loss you pay for not using the exact geometric sum.

And $13$ cannot be improved:

> **Sharpness.** The near-isosceles triple $(696, 697, 985)$ has short-leg knee *exactly* $13$ at context $64$.

That triple is not a lucky find; it is the fourth member of a distinguished arithmetic family, which we will meet in a moment. A sweep of all $477$ primitive triples with hypotenuse up to $3000$ turns up exactly two that attain $13$: $(696,697,985)$ and $(1748,1755,2477)$ — precisely the two whose shape is closest to a half-square.

Meanwhile the *other* leg behaves in exactly the opposite way:

> **No universal long-leg budget.** For every bound $K$, there is a Pythagorean triple and a context length at which the long-leg profile needs more than $K$ keys.

The witnesses are the near-square triples $(2m+1,\; 2m(m+1),\; 2m(m+1)+1)$ — for $m=1$ this is $(3,4,5)$, for $m=2$ it is $(5,12,13)$, and so on. Their long-leg ratio is $t/(t+1)$ with $t = 2m(m+1)$, which crawls up towards $1$. A profile with ratio near $1$ is nearly flat, and a nearly flat profile forces you to keep a constant *fraction* of the context; a Bernoulli estimate turns that into an arbitrarily large key budget.

## The inversion, forced

Now put the two halves together. Two triangles, two pairs of ratios, all four on the unit circle.

> **Forced inversion.** If one triple has the smaller short-leg ratio, it necessarily has the larger long-leg ratio. Hence: whichever triple needs fewer keys on its short leg needs at least as many on its long leg — at every context length and every gate.

This follows from the circle in one step: $x_1 < x_2$ with $x_i^2 + y_i^2 = 1$ and all quantities positive forces $y_2 < y_1$. Combined with ratio monotonicity of the knee, the budget ordering inverts. There is no such thing as a uniformly steeper triangle.

The concrete instance is vivid. At context $64$ and gate $0.985$:

| triple | short-leg knee | long-leg knee |
|---|---|---|
| $(3,4,5)$ | **9** | **19** |
| $(20,21,29)$ | **12** | **14** |

The $(3,4,5)$ triangle wins decisively on its short leg, $9$ against $12$ — and loses just as decisively on its long leg, $19$ against $14$. Rank the two triangles by "key efficiency" and the ranking depends entirely on which leg you asked about. This is exactly the shape of the empirical finding: an ordering of budgets that reverses when you change a parameter you thought was incidental.

Sharper still, the inversion does not need two triangles. There is a single Pythagorean triple and a single context at which the triple's *own* long leg exceeds $13$ — strictly more than the universal budget its own short leg is guaranteed to meet at every context. The two sides of one right triangle disagree about how much memory they need.

## Where the two legs meet

If the gap between the two leg budgets can be enormous, can it also close? Follow the **near-isosceles** triples, those whose legs are consecutive integers:
$$(3,4,5) \;\to\; (20,21,29) \;\to\; (119,120,169) \;\to\; (696,697,985) \;\to\; \cdots$$
They are generated by the map $(a,c) \mapsto (3a + 2c + 1,\; 4a + 3c + 2)$ on the pair (short leg, hypotenuse), and the family is characterised by a single Pell-type invariant that the recurrence preserves:
$$c^2 = 2a^2 + 2a + 1.$$
Verifying that this is preserved is a two-line algebraic identity, and it says exactly that $a^2 + (a+1)^2 = c^2$ — the legs really are consecutive.

Along this branch, the short-leg ratio strictly increases and the long-leg ratio strictly decreases (both are elementary cross-multiplications using the invariant). Feed that into ratio monotonicity of the knee and you get a **monotone squeeze**: at every context length and every gate, the short-leg budget is non-decreasing along the branch and the long-leg budget is non-increasing. The two budgets march towards each other and cannot ever pass one another back.

Do they actually meet? At context $64$ and gate $0.985$ the two budgets and their gaps are:

| triple | short | long | gap |
|---|---|---|---|
| $(3,4,5)$ | 9 | 19 | **10** |
| $(20,21,29)$ | 12 | 14 | **2** |
| $(119,120,169)$ | 12 | 13 | **1** |
| $(696,697,985)$ | 13 | 13 | **0** |

They meet — and they meet exactly at $13$, the universal short-leg bound. So the constant $13$ is not merely attained somewhere: it is the value at which the entire Pythagorean budget inversion degenerates, the place where the two legs of a right triangle finally agree. The gaps $10, 2, 1, 0$ collapse fast and then get quantised: once the two ratios are within a hair of $1/\sqrt2$ of each other, the integer-valued knee simply cannot tell them apart.

## Localising the cliff

Return to the measured surface. Two things about it can be settled without appealing to any model at all, treating the table as four-point sequences.

First, the table is **not separable**. There is no way to write the budget as $f(\text{scale}) + g(\text{context})$, and no way to write it as $f(\text{scale}) \cdot g(\text{context})$. The additive obstruction is immediate — the scale gap is $0$ at $512$ but $16$ at $4096$, and an additive law forces a constant gap. The multiplicative one takes a further step: matching the first column forces the two scale factors to be equal, and then the second column reads $20 = 16$. A two-factor provisioning table is therefore provably wrong; scale and context interact, and non-monotonically.

Second, the inversion is **realizable**, meaning it is a genuine phenomenon of retained-mass knees and not a measurement artefact. Take
$$w_A(i) = \left(\tfrac12\right)^i, \qquad w_B(i) = \left(\tfrac1{16}\right)^i + \tfrac1{1000},$$
both honest positive profiles, and set the gate at $0.9$. Profile $B$ has a far steeper head — ratio $1/16$ against $1/2$ — but it carries a small positive *floor*. At context $2$, $B$ needs a single key while $A$ needs two: the steeper profile is cheaper. At context $5000$, $A$ still needs at most $4$ keys (its geometric certificate is context-free: $(1/2)^4 = 1/16 \le 1 - 0.9$), while $B$ needs strictly more than $4$ — because a profile bounded between a floor $c$ and a cap $M$ must keep at least $\tau n c / M$ keys, a quantity growing linearly in the context.

The floor is the whole mechanism, and it is the moral of the story. **A profile can look better at short context precisely by concentrating its head mass, and be asymptotically worse because its tail refuses to vanish relative to the context.** A steeper head buys short-context efficiency, and pays for it later. That is a completely satisfying structural reading of "the acceleration is universal, and amplifies with scale".

And the phase transition cannot be postponed forever. Here is an explicit bound.

> **Crossover localisation.** Suppose profile $v$ has a context-free budget: $k^{\star}(v,n,\tau) \le K$ for all $n \ge 1$. Suppose profile $w$ has all its weights confined to a band $0 < c \le w_i \le M$. Then for every context
> $$n \;\ge\; \frac{(K+1)M}{\tau c},$$
> we have $k^{\star}(v,n,\tau) < k^{\star}(w,n,\tau)$: the crossover has already happened.

The proof is three lines. The band forces $k^{\star}(w,n,\tau) \ge \tau n c / M$; the hypothesis on $n$ makes that at least $K+1$; and $K+1 > K \ge k^{\star}(v,n,\tau)$. For the witness pair above, with $K = 4$, $c = 1/1000$, $M = 1.001$ and $\tau = 0.9$, the bound reads
$$\frac{5 \times 1.001}{0.9 \times 0.001} = 5561.1\ldots,$$
so context $5562$ certifies the crossover. The bound is an honest upper estimate rather than a sharp one: an exact computation puts the true crossover for this pair at context $123$, where the budgets read $4$ against $5$.

The scaling is the interesting part: the crossover context goes like $M/(\tau c)$, **inversely proportional to the floor**. Halve the tail floor and you push the phase transition twice as far out. A profile with a very small floor will look, at every context you can afford to test, as though it has no phase transition at all — and then the transition arrives abruptly, exactly as the measured surface reports. The cliff was always there; the floor merely decides how far away you have to walk to fall off it.

## What to take away

Three ideas, each simple, combining into something that is not.

The first is that **steepness is the only thing that matters, and it is totally ordered**. A slower-decaying attention profile retains less mass at every budget, so decay ratios and key budgets are two views of one quantity. The proof is a rearrangement of a double sum, and it needs no calculus.

The second is that **arithmetic can rigidly couple two steepnesses**. Pythagorean triples place two decay ratios on the unit circle, where they cannot both be small. That produces a universal budget of $13$ keys for every short leg at the $98.5\%$ gate — sharp, attained at $(696,697,985)$ — no budget at all for long legs, and an inversion of orderings that is *forced*, not incidental. Along the near-isosceles branch the two budgets squeeze monotonically together and meet, at $13$.

The third is that **a positive floor creates a phase transition, and the floor's size says where**. A profile that is cheap at short context because of a concentrated head becomes expensive at long context because of its tail, the crossover is guaranteed by an explicit bound $(K+1)M/(\tau c)$, and the surface of budgets over scale and context is provably non-separable.

The practical upshot for anyone provisioning memory is blunt: there is no such thing as a model's key budget. There is only a budget at a scale *and* a context, and the interaction between the two changes sign. Any table with one number per model is describing a world that does not exist.

That the crispest available witness to all of this should be a $3$-$4$-$5$ triangle — the object every schoolchild meets first and every mathematician meets last — is the kind of coincidence that stops being a coincidence once you see the circle.
