# The Dial That Refuses to Be Diluted

## Why a simple pairwise identity guarantees that a statistical signal survives an unfair sample

---

### A worry that everybody has

Suppose you run a workshop that manufactures keys. Not house keys — *keys* in the abstract sense: units of work, each of which has a **footprint** (how big it is, how much material it consumes, how many moving parts it has) and a **yield rate** (how much value it returns per unit of effort).

You suspect that footprint predicts yield. Bigger keys pay off better. So you build a **dial**: a single number, computed from your sample, that measures how strongly footprint tracks yield. Turn the dial up, and you should be looking at the profitable end of the catalogue.

Then somebody asks the awkward question.

*"Your sample isn't representative. You drew mostly small keys, because small keys are what walked in the door. Isn't your dial just an artefact of how you sampled?"*

This is a real and reasonable worry, and it has a name in the folklore of applied statistics: **dilution**. The fear is that when your draw is unbalanced — when 70% of your observations come from one corner of the population and the remaining 30% is spread thinly over everything else — the association you measure gets watered down. The signal is still there in the population, but your lopsided sample can no longer see it. You would then be forced to conclude, wrongly, that footprint doesn't matter.

The purpose of this article is to explain a clean structural fact that puts most of this worry to rest, and to say precisely how much of it legitimately remains.

The short version: **the dial is a pairwise object**, and once you see that, dilution becomes almost impossible.

---

### The setup, stated once and for all

Let there be finitely many keys, indexed by $i$. Key $i$ has a footprint $x_i$ and a yield rate $y_i$ — both real numbers.

A **draw regime** is just a probability weighting of the population: a list of nonnegative numbers $p_i$ with $\sum_i p_i = 1$. The uniform (perfectly balanced) regime puts $p_i = 1/n$ on each of the $n$ keys. A genuinely unbalanced regime might put $0.7$ on a single key and $0.1$ on each of three others. Both are draw regimes; nothing distinguishes them structurally. This is the key modelling move: *balanced* and *unbalanced* are not two different kinds of thing, they are two points in the same simplex.

Under a regime $p$, the **weighted mean** of the footprint is
$$\mu_p(x) = \sum_i p_i\, x_i,$$
and the **dial** — the weighted covariance between footprint and yield — is
$$\operatorname{Cov}_p(x,y) = \sum_i p_i \,\bigl(x_i - \mu_p(x)\bigr)\bigl(y_i - \mu_p(y)\bigr).$$

The dial is positive when big footprints tend to come with big yields, negative when they anticorrelate, and zero when the two are unrelated *as seen by this regime*. The whole question is: how much can changing $p$ change the answer?

---

### The identity that changes everything

Written as above, the dial looks like it depends on the regime in two places at once: in the explicit weights $p_i$, and again inside the centring terms $\mu_p(x)$ and $\mu_p(y)$, which are themselves regime-dependent. That entanglement is exactly what makes dilution feel plausible.

But there is a beautiful old identity — a weighted version of what is variously credited to Hoeffding and to Chebyshev — that untangles it completely.

> **Theorem (Pair Identity).** For any probability weighting $p$ and any footprints $x$ and yields $y$,
> $$2\operatorname{Cov}_p(x,y) = \sum_{i}\sum_{j} p_i\, p_j\, (x_i - x_j)(y_i - y_j).$$

Take a moment with this. On the right there is no mean, no centring, nothing that mixes the regime into the population. There is a **population part** — the quantity
$$D_{ij} = (x_i - x_j)(y_i - y_j),$$
which compares two keys directly and knows nothing whatsoever about how you sampled — and a **regime part**, the product $p_i p_j$, which is a *nonnegative* weight on the pair $\{i,j\}$.

The proof is a two-line expansion: multiply out $(x_i - x_j)(y_i-y_j)$ into four terms, sum each against $p_ip_j$, and use $\sum_i p_i = 1$ to collapse the sums; three of the four terms reassemble into $\sum_i p_i x_iy_i$ and the cross-products $(\sum p_ix_i)(\sum p_iy_i)$, and what is left is exactly twice the raw-moment form of the covariance.

The consequence is conceptual, and it is the whole story of this article:

**A draw regime cannot decide what a pair of keys says. It can only decide how loudly that pair speaks — and it can never make a pair speak with a negative sign.**

---

### Concordance: the shape of a population

The number $D_{ij} = (x_i - x_j)(y_i - y_j)$ is the **concordance** of the pair $(i,j)$. It is positive when the two keys are ordered the same way in footprint and in yield (both larger, or both smaller), and negative when they disagree — a bigger key with a smaller yield.

Call the population **comonotone** if no pair disagrees:
$$D_{ij} = (x_i - x_j)(y_i - y_j) \ \geq\ 0 \quad \text{for all } i, j.$$

Comonotonicity is a *monotone-relationship* hypothesis, and a weak one. It does not ask for linearity, or for a particular functional form, or for normality, or for anything about error distributions. It just says: sorting the keys by footprint sorts them by yield too (allowing ties). For a great many real mechanisms — bigger job, more output; more surface, more reaction; longer key, more tumblers engaged — this is exactly the right assumption.

And now the pair identity does its work in one stroke.

> **Theorem (No Dilution, Qualitative Form).** If the population is comonotone, then $\operatorname{Cov}_p(x,y) \geq 0$ for **every** draw regime $p$, no matter how unbalanced.

Because every term $p_ip_jD_{ij}$ on the right-hand side of the pair identity is a product of nonnegative numbers. A sum of nonnegative numbers is nonnegative. That is the entire proof.

There is no sampling condition, no sample-size threshold, no asymptotics, no independence assumption. The sign of the dial is a property of the *population's shape*, and the regime is powerless against it.

Strictness follows the same way:

> **Theorem (No Dilution, Strict Form).** If the population is comonotone and there exist two keys $a$ and $b$ that the regime actually charges — $p_a > 0$ and $p_b > 0$ — and which are *strictly* concordant, $(x_a - x_b)(y_a - y_b) > 0$, then $\operatorname{Cov}_p(x,y) > 0$.

The moral: a full-support unbalanced regime fires exactly when a balanced one does. To kill the dial by sampling, you must *zero out* the informative pairs entirely — starve them of mass, not merely under-weight them. Under-weighting is not dilution; it is only quietness.

---

### The dial survives being re-encoded

There is a second, equally common worry: that the dial's verdict depends on the arbitrary units in which footprint and yield happen to be recorded. Should we measure footprint linearly, or logarithmically? Should we use raw yields, or *ranks*?

Ranks matter especially, because rank-based statistics — Spearman-type correlations — are the standard tool when you distrust the scale. Here they cost nothing:

> **Theorem (Invariance Under Monotone Re-encoding).** If the population is comonotone in $(x, y)$ and $g, h$ are any nondecreasing functions of a real variable, then the population is comonotone in $(g\circ x, h\circ y)$. Consequently $\operatorname{Cov}_p(g\circ x, h\circ y) \geq 0$ for every draw regime $p$.

Why: comonotonicity is a statement about *orderings*, and a nondecreasing function preserves orderings. If $x_i \le x_j$ then $g(x_i) \le g(x_j)$; if additionally $y_i \le y_j$ then $h(y_i) \le h(y_j)$; so the re-encoded pair is again concordant. (The only care needed is checking that comonotonicity really does force $x_i < x_j \Rightarrow y_i \le y_j$, which it does: a violation would make $D_{ij}$ strictly negative.)

Ranking is a monotone re-encoding. So the theorem applies verbatim to the Spearman version of the dial. The signal is invariant to draws *and* to units.

---

### How much wobble is left? A precise answer

None of the above says the dial's *numerical value* is regime-independent. It isn't, and it shouldn't be — a regime that concentrates on one key sees less spread and reports a smaller covariance. What we can do is bound the wobble exactly.

Measure the distance between two regimes $p$ and $q$ by their $\ell^1$ distance $\|p - q\|_1 = \sum_i |p_i - q_i|$ (this is twice the total-variation distance). Suppose the footprints span at most $M_x$, meaning $|x_i - x_j| \le M_x$ for all $i,j$, and similarly the yields span at most $M_y$.

> **Theorem (Regime Stability).** For any two draw regimes $p$ and $q$,
> $$\bigl|\operatorname{Cov}_p(x,y) - \operatorname{Cov}_q(x,y)\bigr| \ \leq\ M_x\, M_y\, \|p - q\|_1.$$

The proof runs entirely through the pair identity. Subtract the two identities: the difference is $\sum_{i,j}(p_ip_j - q_iq_j)D_{ij}$. Bound each $|D_{ij}| \le M_xM_y$ by the range hypotheses. What remains is the pair-mass estimate $\sum_{i,j}|p_ip_j - q_iq_j| \le 2\|p-q\|_1$, which follows by writing $p_ip_j - q_iq_j = p_i(p_j - q_j) + (p_i - q_i)q_j$ and summing.

This is the honest, quantitative form of the phrase "identical within noise". Two regimes that are $\ell^1$-close *must* report nearly the same dial; there is no room for a dilution effect to hide in. And in general, the deviation cannot exceed the product of the two ranges times the sampling discrepancy — a Lipschitz guarantee, not a hope.

---

### Walking from one regime to the other

You can do better than a bound: you can compute the dial's entire trajectory as you slide continuously from a balanced regime $p$ to an unbalanced regime $q$. Define the **homotopy** $p^t = (1-t)p + tq$ for $t \in [0,1]$; each $p^t$ is again a legitimate draw regime.

> **Theorem (Exact Quadratic Law).** With the **cross term**
> $$K(p,q) = \tfrac{1}{2}\sum_{i}\sum_{j} p_i\, q_j\, (x_i - x_j)(y_i - y_j),$$
> we have, for every $t$,
> $$\operatorname{Cov}_{p^t}(x,y) = (1-t)^2 \operatorname{Cov}_p(x,y) + 2t(1-t) K(p,q) + t^2 \operatorname{Cov}_q(x,y).$$

The dial is an exact quadratic polynomial in the mixing parameter. Not approximately: exactly. And the cross term $K(p,q)$ is itself nonnegative for a comonotone population — same argument, nonnegative weights $p_iq_j$ against nonnegative concordances. So the middle term can only help, giving

$$\operatorname{Cov}_{p^t}(x,y) \ \geq\ (1-t)^2 \operatorname{Cov}_p(x,y) + t^2 \operatorname{Cov}_q(x,y),$$

and, since $(1-t)^2 + t^2 \geq \tfrac12$ for all $t\in[0,1]$, a clean universal floor:

> **Corollary (The Half-Minimum Floor).** For a comonotone population, every regime on the segment between $p$ and $q$ reads at least half the smaller of the two endpoint readings:
> $$\operatorname{Cov}_{p^t}(x,y) \ \geq\ \tfrac{1}{2}\min\bigl(\operatorname{Cov}_p(x,y),\ \operatorname{Cov}_q(x,y)\bigr).$$

You cannot lose more than a factor of two by drifting anywhere between two regimes. There is no interior collapse, no cancellation valley — the worry that the dial might vanish "somewhere in the middle" is simply false.

---

### When the population is *not* comonotone: a triage rule

Real populations have exceptions. A few keys are large and unproductive; the ordering is mostly right but not perfectly right. So split the pair budget into its two halves:

$$C = \sum_{i,j} \max(D_{ij}, 0) \qquad \text{(concordance mass)}, \qquad \Delta = \sum_{i,j} \max(-D_{ij}, 0) \qquad \text{(discordance mass)}.$$

Both are properties of the population alone — no regime appears. They satisfy $C - \Delta = \sum_{i,j} D_{ij}$, and $\Delta = 0$ holds precisely when the population is comonotone. Together they form a **budget**: $C$ is the evidence for the dial, $\Delta$ is the evidence against.

Now suppose you know something about how unbalanced your draw can get: every key receives mass at least $\varepsilon$ and at most $M$. Call $\kappa = M/\varepsilon$ the regime's **conditioning number** — it is $1$ for a perfectly balanced draw and grows as the draw gets lopsided.

> **Theorem (Concordance Budget).** If $\varepsilon \le p_i \le M$ for all keys, then
> $$\varepsilon^2\, C - M^2\, \Delta \ \leq\ 2\operatorname{Cov}_p(x,y).$$

The proof is one inequality per pair: in the identity $2\operatorname{Cov}_p = \sum_{i,j}p_ip_jD_{ij}$, replace $p_ip_j$ by its lower bound $\varepsilon^2$ where $D_{ij}$ is positive and by its upper bound $M^2$ where $D_{ij}$ is negative.

Divide by $\varepsilon^2$ and the theorem becomes a decision procedure:

> **Corollary (Triage Rule).** If
> $$\kappa^2 \ <\ \frac{C}{\Delta},$$
> then the dial is strictly positive — for **every** regime with conditioning number at most $\kappa$.

This is an operationally useful statement. The right-hand side is computed once, from the population, before you sample anything. The left-hand side is a fact about your sampling apparatus. If the population's concordance-to-discordance ratio beats the square of your worst-case imbalance, you are guaranteed a positive reading and can stop worrying. And when $\Delta = 0$ the ratio is infinite, recovering the unconditional theorem.

---

### What is *not* invariant — the honest boundary

It would be tempting to declare that everything about the dial is regime-invariant. It isn't, and the honest statement of the boundary is more interesting than a false universal.

The natural way to grade a dial is by its **variance share** $R^2$ — the fraction of yield variation the footprint explains. Fitting the best straight line $a + bx$ to the yields under regime $p$ minimises the weighted squared error, and the minimum equals
$$\operatorname{Var}_p(y)\bigl(1 - R_p^2\bigr), \qquad R^2_p = \frac{\operatorname{Cov}_p(x,y)^2}{\operatorname{Var}_p(x)\operatorname{Var}_p(y)},$$
which is between $0$ and $1$ by the weighted Cauchy–Schwarz inequality — itself just the statement that the minimal error cannot be negative.

$R^2$ is **not** regime-invariant. Here is a four-key population that makes the point concretely. Footprints $x = (1, 2, 4, 8)$, plain counts $z = (1,1,2,2)$ used as a rival predictor, and yields $y = (1,2,5,9)$. Compare the balanced regime $p = (\tfrac14,\tfrac14,\tfrac14,\tfrac14)$ with a genuinely unbalanced one $q = (0.7, 0.1, 0.1, 0.1)$; these are far apart, at $\ell^1$ distance $0.9$.

| | balanced $p$ | unbalanced $q$ |
|---|---|---|
| $R^2$ of the footprint dial | $0.9924$ | $0.9953$ |
| $R^2$ of the plain count | $0.7806$ | $0.8615$ |
| advantage of footprint | $+0.2117$ | $+0.1337$ |

The **ordering** is stable — footprint beats count by a comfortable margin in both regimes. The **margin** is not: it drops from $0.21$ to $0.13$ when the draw becomes lopsided. That is the honest boundary of "identical within noise". What survives regime change is the *sign* of the dial, the *ordering* of competing dials under an exact driver, and $\ell^1$-controlled deviations of the covariance. What does not survive is the exact numerical value of the variance share.

The ordering, though, does have a structural guarantee in the limiting case:

> **Theorem (Draw-Invariant Dominance).** If the yield is an exact nonconstant affine function of the footprint, $y_i = a + b x_i$ with $b \neq 0$, then the footprint dial reads $R^2 = 1$ in *every* draw regime — and consequently no rival predictor $z$ can beat it, in any regime.

The proof is a computation: under any $p$, $\operatorname{Cov}_p(x, a+bx) = b\operatorname{Var}_p(x)$ and $\operatorname{Var}_p(a+bx) = b^2\operatorname{Var}_p(x)$, so the ratio defining $R^2$ collapses to $1$; and every $R^2$ is at most $1$. When footprint *is* the mechanism, footprint wins, and no sampling scheme can promote a rival above it.

---

### Adding a predictor always helps — by an exact amount

One final piece completes the picture. Suppose you have already fitted something and are left with residuals $r_i$, and you propose adding a further predictor $z$. Regressing $r$ on $z$ under regime $p$ reduces the weighted squared error by a quantity you can name:

> **Theorem (Augmentation Gain).** If $\sum_i p_i z_i^2 > 0$, then choosing $c = \bigl(\sum_i p_i r_i z_i\bigr)\big/\bigl(\sum_i p_i z_i^2\bigr)$ gives
> $$\sum_i p_i\,(r_i - c z_i)^2 \ =\ \sum_i p_i r_i^2 \ -\ \frac{\bigl(\sum_i p_i r_i z_i\bigr)^2}{\sum_i p_i z_i^2}.$$
> In particular the fit strictly improves whenever the residual is not orthogonal to $z$ under $p$.

The gain $\langle r, z\rangle_p^2 / \|z\|_p^2$ is exactly the squared projection of the residual onto the new direction — the Pythagorean theorem in the inner product that the regime defines. It is a formula, not an estimate, and it explains why an *augmented* $R^2$ is the right comparison to make: it isolates the marginal contribution of the footprint dial over and above whatever else is in the model.

---

### What to take away

The worry we started with — *my sample is unfair, so my signal must be watered down* — conflates two very different things.

It is true that an unfair sample sees a **smaller** covariance: less spread means less signal in absolute terms. It is false that an unfair sample sees a **weaker relationship**. The direction of the association is a property of the population's pair structure, and a draw regime contributes only nonnegative pair weights. You can turn the volume down. You cannot change the tune.

The precise inventory of what is safe:

- **Always safe:** the sign of the dial, for comonotone populations, in every regime, and after any monotone re-encoding of either coordinate — so rank-based versions inherit the guarantee.
- **Quantitatively safe:** the covariance moves by at most (footprint range) × (yield range) × ($\ell^1$ regime distance); and along any path between two regimes it never falls below half the smaller endpoint reading.
- **Conditionally safe:** when the population has some discordance $\Delta > 0$, positivity is still guaranteed for every regime with conditioning number $\kappa$ satisfying $\kappa^2 < C/\Delta$.
- **Not safe:** the numerical value of the variance share. It genuinely moves — in our worked example the footprint's advantage over plain count fell from $0.21$ to $0.13$ — while the ordering held.

That last line is not a defeat; it is the point. Knowing exactly which parts of a statistic are robust, and exactly how the rest degrade, is worth more than a blanket reassurance. The pair identity is what makes the accounting possible: it separates the population from the sample so completely that each can be reasoned about on its own.

Once you have seen it, you will find yourself reaching for it constantly. Any statistic that can be written as a nonnegatively-weighted sum over *pairs* of a population-intrinsic quantity inherits this whole story: the sign is a shape invariant, the magnitude is Lipschitz in the sampling weights, and the interpolation between samples is an exact quadratic. Covariance was only the first example.
