# Scheduling a Finite Portfolio over an Invisible Channel: An Exact Value-of-Information Theory

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop an exact, finite, and entirely elementary theory of algorithm-portfolio scheduling under partial observation, motivated by a measured phenomenon in integer factorisation: a five-member factoring portfolio in which no member is a universal winner, in which winner shares are flat across every feature computable from the input, and in which a tuned routing rule improves the expected cost by exactly zero while a learned routing rule is significantly *worse* than the best fixed member.

The central object is the **dial value** $D(\varphi)$ of an observation map $\varphi$: the expected cost of the best rule measurable with respect to $\varphi$. We prove that every rule decomposes over the fibers of $\varphi$, that $D(\varphi) = \sum_o \min_s V(o,s)$ where $V$ is the unnormalised conditional cost table, and that this value is attained. From this we obtain: the information ladder $\mathbb{E}[\text{oracle}] \le D(\varphi) \le B$, where $B$ is the best static value; monotonicity of $D$ under refinement of the observation; and an **exact characterisation** — $D(\varphi) < B$ if and only if every member of the portfolio is strictly beaten on some fiber.

We introduce **invisibility** of an observation (conditional means constant across fibers) and prove that it forces $D(\varphi) = B$, with a strict converse: any rule deviating toward a suboptimal member on a positive-mass fiber is strictly worse than doing nothing. We then make the hypothesis quantitative: an $\varepsilon$-invisible observation satisfies $B - D(\varphi) \le 2\varepsilon$, and the constant $2$ is optimal, witnessed by an explicit anti-diagonal family with gap $2n/(n+1)$. The naive converse fails: a portfolio of indistinguishable members has zero gap yet is not $\varepsilon$-invisible for any $\varepsilon < 1$.

Refining this, we prove that the dial gain equals the smallest **fiberwise regret** in the portfolio, so that a null measurement certifies exactly the existence of a fiberwise champion; that for a two-member portfolio the gain is exactly the minimum of two **swap masses**; and that this pairwise certificate is invisible at portfolio level — an explicit irredundant three-member family has arbitrarily large swap masses relative to its dial gain.

Two further strands complete the picture. On the statistics of regret: median regret ratio $1$ is compatible with arbitrarily large mean regret ratio for the *optimal* static member, so median diagnostics are provably blind; a reverse Markov bound converts a measured mean and a cost cap into a forced tail mass; stochastic dominance implies a mean inequality via an exact finite layer-cake identity, but the converse fails, so mean-based elimination of a portfolio member is unsound while pointwise and fiberwise dominance are sound. On the structure of the hidden channel: it is the $B$-powersmoothness of $p-1$, which we exhibit as strictly invisible via two $21$-bit balanced semiprimes with identical visible profile and opposite smoothness class, and we prove that a budget-capped $p-1$ probe genuinely detects the smooth class. Finally, when the probe returns an ordered quantile, a discrete Topkis theorem shows that decreasing differences make the optimal schedule monotone — a threshold rule — and that the hypothesis is necessary.

**Keywords:** algorithm portfolios, value of information, regret, invisible channel, powersmoothness, stochastic dominance, Topkis monotonicity, reverse Markov inequality.

---

## 1. Introduction

### 1.1 The empirical cell

Consider a portfolio of five classical integer-factorisation methods run on semiprimes $N = pq$: Pollard's rho, the $p-1$ method with bound $256$, the $p-1$ method with bound $1024$, Fermat's difference-of-squares method, and trial division. Over a broad sample, the *oracle winner shares* — the fraction of instances on which each method is the first to finish — are approximately

$$\rho:\ 0.580,\qquad (p-1)@256:\ 0.345,\qquad (p-1)@1024:\ 0.045,\qquad \text{Fermat}:\ 0.028,\qquad \text{trial division}:\ 0.002 .$$

Three facts about this table are the subject of this paper.

1. **No universal winner.** Every member wins on a set of positive probability, and every member loses on a set of positive probability.
2. **Flatness.** The shares are essentially constant across bit-length quintiles and across balance quintiles — indeed, across every statistic computable from $N$ alone that was measured.
3. **Null scheduling.** A tuned routing rule that selects a member from those visible statistics improves the expected cost by $\Delta = 0.000$; the best static member has expected regret $3.117$ against the oracle; and a learned routing rule achieves $4.683$, i.e. it is significantly worse than doing nothing. The median regret ratio is exactly $1.000$ for every strategy considered.

The explanation is that the organising variable is not visible. For the $p-1$ family the winner is decided by the *powersmoothness of $p-1$*, a property of the factorisation of $N$ and hence of the very thing being computed. This paper turns that explanation into theorems, and in doing so obtains a complete value-of-information theory for finite portfolios which appears to be of independent interest.

### 1.2 Contributions and organisation

Section 2 fixes the finite probabilistic model. Section 3 proves the fiberwise decomposition and the exact formula for the dial value, and derives the information ladder, monotonicity, and the dial-edge criterion. Section 4 introduces invisibility and proves the no-dial-edge theorem and its strict converse. Section 5 makes invisibility quantitative and proves the sharp stability bound $B - D \le 2\varepsilon$. Section 6 analyses what a null measurement certifies: the fiberwise-regret formula, the fiberwise-champion criterion, the two-member swap-mass identity, and the unboundedness of pairwise structure on irredundant portfolios. Section 7 treats the statistics of regret: median blindness, the reverse Markov bound, the layer cake, and elimination discipline. Section 8 supplies the number theory of the hidden channel and the guarantee behind a paid probe. Section 9 proves the threshold-optimality theorem for ordered probes. Section 10 assembles the exact rational model of the measured cell and recovers every reported number. Section 11 discusses scope and limitations; Section 12 lists directions.

All statements are finite and rational; no measure theory is used. Costs are elements of $\mathbb{Q}$ and probabilities are rational weights, so every concrete example in the paper is exactly computable.

---

## 2. The model

**Definition 2.1 (portfolio problem).** A *finite portfolio problem* consists of

- a finite instance space $\Omega$ with a weight function $w : \Omega \to \mathbb{Q}$ satisfying $w \ge 0$ and $\sum_{\omega} w(\omega) = 1$;
- a finite nonempty set $S$ of *members*;
- a *cost* $c : \Omega \times S \to \mathbb{Q}$, where $c(\omega,s)$ is the cost of running member $s$ on instance $\omega$.

We write $\mathbb{E}[f] = \sum_{\omega} w(\omega) f(\omega)$ for $f : \Omega \to \mathbb{Q}$.

**Definition 2.2 (benchmarks).**
- The *oracle cost* is $\mathrm{Or}(\omega) = \min_{s \in S} c(\omega,s)$, the cost of the member chosen with hindsight.
- The *best static value* is $B = \min_{s \in S} \mathbb{E}[c(\cdot,s)]$.
- The *static regret* is $R = B - \mathbb{E}[\mathrm{Or}]$.

Since $\mathrm{Or}(\omega) \le c(\omega,s)$ pointwise and $w \ge 0$, we have $\mathbb{E}[\mathrm{Or}] \le \mathbb{E}[c(\cdot,s)]$ for every $s$, hence $R \ge 0$.

**Definition 2.3 (observation, rule, fiber).** An *observation* is a map $\varphi : \Omega \to O$ into a finite set $O$. A *rule* (or *dial*) is a map $\pi : O \to S$; its cost on instance $\omega$ is $c(\omega, \pi(\varphi(\omega)))$. For $o \in O$ the *fiber* over $o$ is $\varphi^{-1}(o)$, with

$$\mu(o) \;=\; \sum_{\omega \,:\, \varphi(\omega) = o} w(\omega) \qquad\text{(fiber mass)},$$

$$V(o,s) \;=\; \sum_{\omega \,:\, \varphi(\omega) = o} w(\omega)\, c(\omega,s) \qquad\text{(fiber value)} .$$

Note $\sum_o \mu(o) = 1$ and $\mu(o) \ge 0$.

**Definition 2.4 (dial value).** The *dial value* of the observation $\varphi$ is

$$D(\varphi) \;=\; \sum_{o \in O} \min_{s \in S} V(o,s).$$

The interpretation of $D(\varphi)$ as the value of the best $\varphi$-measurable rule is Theorem 3.3.

---

## 3. Fiberwise decomposition and the information ladder

**Theorem 3.1 (fiberwise decomposition).** *For every rule $\pi : O \to S$,*
$$\mathbb{E}\bigl[c(\cdot,\pi(\varphi(\cdot)))\bigr] \;=\; \sum_{o \in O} V\bigl(o,\pi(o)\bigr).$$

*Proof.* Partition $\Omega$ into the fibers of $\varphi$ and sum fiberwise. On the fiber over $o$ we have $\varphi(\omega) = o$, so $c(\omega,\pi(\varphi(\omega))) = c(\omega,\pi(o))$, and the inner sum is exactly $V(o,\pi(o))$. $\square$

Applying Theorem 3.1 to the constant rule $\pi \equiv s$ gives the companion identity.

**Corollary 3.2.** $\mathbb{E}[c(\cdot,s)] = \sum_{o} V(o,s)$ for every member $s$.

**Theorem 3.3 (the dial value is the optimum, and is attained).** *For every rule $\pi$ we have $D(\varphi) \le \mathbb{E}[c(\cdot,\pi(\varphi(\cdot)))]$, and there exists a rule $\pi^\star$ attaining $D(\varphi)$.*

*Proof.* By Theorem 3.1 the cost of $\pi$ is $\sum_o V(o,\pi(o)) \ge \sum_o \min_s V(o,s) = D(\varphi)$. For attainment, choose for each $o$ a minimiser $\pi^\star(o) \in \arg\min_s V(o,s)$; since $S$ is finite and nonempty this is possible, and the resulting rule has cost exactly $D(\varphi)$. $\square$

**Theorem 3.4 (an optimised dial never hurts).** $D(\varphi) \le B$.

*Proof.* Let $s_0$ attain $B$. By Corollary 3.2, $B = \sum_o V(o,s_0) \ge \sum_o \min_s V(o,s) = D(\varphi)$. $\square$

**Theorem 3.5 (the oracle bounds the dial from below).** $\mathbb{E}[\mathrm{Or}] \le D(\varphi)$.

*Proof.* Take an optimal rule $\pi^\star$; then pointwise $\mathrm{Or}(\omega) \le c(\omega,\pi^\star(\varphi(\omega)))$, and $w \ge 0$ preserves the inequality in expectation. Conclude by Theorem 3.3. $\square$

**Theorem 3.6 (information ladder).** $\mathbb{E}[\mathrm{Or}] \le D(\varphi) \le B.$

The three quantities are the fundamental benchmarks: hindsight, best routing on the available information, and best fixed choice. The two gaps have names: $B - D(\varphi)$ is the *dial gain* (what routing on $\varphi$ buys), and $R = B - \mathbb{E}[\mathrm{Or}]$ is the static regret (what perfect information would buy).

**Theorem 3.7 (monotone value of information).** *Let $\varphi : \Omega \to O$ and $\psi : \Omega \to O'$ be observations with $\varphi = g \circ \psi$ for some $g : O' \to O$ — that is, $\psi$ refines $\varphi$. Then $D(\psi) \le D(\varphi)$.*

*Proof.* Let $\pi^\star$ be optimal for $\varphi$. The rule $\pi^\star \circ g$ is $\psi$-measurable and has the *same* pointwise cost as $\pi^\star$, since $\pi^\star(g(\psi(\omega))) = \pi^\star(\varphi(\omega))$. Hence $D(\psi) \le \mathbb{E}[c(\cdot,\pi^\star \circ g \circ \psi)] = \mathbb{E}[c(\cdot,\pi^\star \circ \varphi)] = D(\varphi)$. $\square$

Refining features can only increase the value of routing, and the finest observation $\varphi = \mathrm{id}$ recovers the oracle: with singleton fibers, $D(\mathrm{id}) = \sum_\omega w(\omega)\min_s c(\omega,s) = \mathbb{E}[\mathrm{Or}]$.

The main structural result of this section is the following exact criterion.

**Theorem 3.8 (dial-edge criterion).** $D(\varphi) < B$ *if and only if for every member $s \in S$ there exists a fiber $o$ with*
$$\min_{t \in S} V(o,t) \;<\; V(o,s).$$

*Proof.* ($\Rightarrow$) Fix $s$. By Corollary 3.2 and $B \le \mathbb{E}[c(\cdot,s)]$,
$$\sum_o \min_t V(o,t) = D(\varphi) < B \le \sum_o V(o,s).$$
If $s$ were fiberwise optimal on every fiber, the two sums would be equal, a contradiction; hence $s$ is strictly beaten on some fiber.
($\Leftarrow$) Let $s_0$ attain $B$ and let $o_0$ be a fiber on which $s_0$ is strictly beaten. Then $\min_t V(o,t) \le V(o,s_0)$ for every $o$, with strict inequality at $o_0$, so summing gives $D(\varphi) < \sum_o V(o,s_0) = B$. $\square$

The content of the "only if" direction is worth emphasising. A dial pays off *only* when the portfolio has no fiberwise champion. A single member that minimises the conditional cost on every fiber renders every observation-measurable rule worthless, regardless of how much the remaining members trade places.

---

## 4. Invisibility and the no-dial-edge theorem

**Definition 4.1 (invisibility).** An observation $\varphi$ is *invisible* for the portfolio, with mean profile $m : S \to \mathbb{Q}$, if
$$V(o,s) \;=\; \mu(o)\, m(s) \qquad \text{for all } o \in O,\ s \in S .$$

Equivalently: on every fiber of positive mass, the conditional mean cost of member $s$ equals $m(s)$, independently of the fiber. Invisibility is the exact statement of "the winner shares are flat across the observable quintiles".

**Lemma 4.2.** *Under invisibility, $\mathbb{E}[c(\cdot,s)] = m(s)$ for every $s$, and hence $B = \min_s m(s)$.*

*Proof.* By Corollary 3.2, $\mathbb{E}[c(\cdot,s)] = \sum_o V(o,s) = \bigl(\sum_o \mu(o)\bigr) m(s) = m(s)$. Take the minimum over $s$. $\square$

**Theorem 4.3 (no dial edge).** *If $\varphi$ is invisible with profile $m$, then for every rule $\pi$,*
$$B \;\le\; \mathbb{E}\bigl[c(\cdot,\pi(\varphi(\cdot)))\bigr].$$
*The optimal dial is the do-nothing dial.*

*Proof.* By Theorem 3.1 and invisibility the rule costs $\sum_o \mu(o)\, m(\pi(o))$. The fiber masses are nonnegative and sum to $1$, so this is a convex combination of values of $m$, hence at least $\min_s m(s) = B$ by Lemma 4.2. $\square$

**Theorem 4.4 (a tuned rule can only hurt).** *Suppose $\varphi$ is invisible with profile $m$, and let $\pi$ be a rule for which there is a fiber $o_0$ with $\mu(o_0) > 0$ and $m(\pi(o_0)) > \min_s m(s)$. Then*
$$B \;<\; \mathbb{E}\bigl[c(\cdot,\pi(\varphi(\cdot)))\bigr].$$

*Proof.* As above, with the sum $\sum_o \mu(o) m(\pi(o))$ compared termwise to $\sum_o \mu(o)\min_s m(s) = B$; every term is $\ge$, and the term at $o_0$ is strictly $>$ because $\mu(o_0) > 0$. $\square$

**Corollary 4.5.** *Under invisibility, $D(\varphi) = B$: the dial gain is exactly $0$.*

Theorems 4.3 and 4.4 are the formal shadow of the two measured facts: $\Delta = 0.000$ for the tuned dial, and a learned rule that is *worse* than static. A learner responding to invisible features is not merely useless; it is harmful in exact proportion to the mass on which it deviates.

Consistently with Theorem 3.8: under invisibility every member $s$ satisfies $V(o,s) = \mu(o)m(s)$, so a member minimising $m$ minimises $V(o,\cdot)$ on *every* fiber — a fiberwise champion exists, and the criterion fails.

**Theorem 4.6 (paid probes).** *For a probe that reveals the instance exactly, at price $\kappa$ per instance, the resulting schedule beats the best static schedule if and only if $\kappa < R$, where $R = B - \mathbb{E}[\mathrm{Or}]$ is the static regret.*

*Proof.* A rule measurable with respect to the identity observation attains $\mathbb{E}[\mathrm{Or}]$ (choose a pointwise minimiser), so the total cost with the probe is $\mathbb{E}[\mathrm{Or}] + \kappa$, and $\mathbb{E}[\mathrm{Or}] + \kappa < B \iff \kappa < B - \mathbb{E}[\mathrm{Or}] = R$. $\square$

This is the exact economics of buying the invisible channel: the static regret is the *reservation price* of perfect information.

---

## 5. Quantitative invisibility and stability

Exact invisibility is a knife-edge hypothesis: it is an equation, and no finite measurement certifies an equation. We replace it by a metric notion.

**Definition 5.1 ($\varepsilon$-invisibility).** For $\varepsilon \in \mathbb{Q}$, the observation $\varphi$ is *$\varepsilon$-invisible* with profile $m$ if
$$\bigl|\, V(o,s) - \mu(o)\,m(s) \,\bigr| \;\le\; \varepsilon\,\mu(o) \qquad \text{for all } o,\ s .$$

Invisibility is $0$-invisibility. Dividing by $\mu(o) > 0$, the condition says the conditional mean of every member on every fiber lies within $\varepsilon$ of its global mean.

**Theorem 5.2 (upper bound on the static value).** *If $\varphi$ is $\varepsilon$-invisible with profile $m$, then $B \le \min_s m(s) + \varepsilon$.*

*Proof.* Let $s_0$ minimise $m$. Summing the upper half of Definition 5.1 over $o$ gives $\mathbb{E}[c(\cdot,s_0)] = \sum_o V(o,s_0) \le \sum_o \mu(o)(m(s_0) + \varepsilon) = m(s_0) + \varepsilon$, and $B \le \mathbb{E}[c(\cdot,s_0)]$. $\square$

**Theorem 5.3 (lower bound on the dial value).** *If $\varphi$ is $\varepsilon$-invisible with profile $m$, then $D(\varphi) \ge \min_s m(s) - \varepsilon$.*

*Proof.* On each fiber, for every $s$, the lower half of Definition 5.1 gives $V(o,s) \ge \mu(o)(m(s) - \varepsilon) \ge \mu(o)(\min_t m(t) - \varepsilon)$, using $\mu(o) \ge 0$. Hence $\min_s V(o,s) \ge \mu(o)(\min_t m(t) - \varepsilon)$, and summing over $o$ with $\sum_o \mu(o) = 1$ gives the claim. $\square$

**Theorem 5.4 (stability of the no-dial-edge theorem).** *If $\varphi$ is $\varepsilon$-invisible then*
$$B - D(\varphi) \;\le\; 2\varepsilon,$$
*and consequently every rule $\pi$ satisfies $\mathbb{E}[c(\cdot,\pi(\varphi(\cdot)))] \ge B - 2\varepsilon$.*

*Proof.* Subtract Theorem 5.3 from Theorem 5.2. The second statement follows from $D(\varphi) \le \mathbb{E}[c(\cdot,\pi \circ \varphi)]$ (Theorem 3.3). $\square$

At $\varepsilon = 0$ this recovers Corollary 4.5 and Theorem 4.3. As a certificate it is directly usable: *measure* the deviation of conditional means from global means, and you have bounded the payoff of every conceivable router built on those features, before building any.

A first consequence for probes: if the dial happens to be *optimal* in the strong sense $D(\varphi) = \mathbb{E}[\mathrm{Or}]$, then combining with Theorem 5.4 gives $R \le 2\varepsilon$; a nearly invisible observation cannot recover a large static regret.

**Theorem 5.5 (sharpness of the constant $2$).** *For $n \ge 1$ consider $\Omega = S = O = \{0,1,\dots,n\}$ with uniform weights $w \equiv 1/(n+1)$, the finest observation $\varphi = \mathrm{id}$, and the anti-diagonal cost*
$$c(\omega,s) = \begin{cases} -1 & \omega = s,\\ \phantom{-}1 & \omega \neq s.\end{cases}$$
*This portfolio is $1$-invisible with profile $m \equiv 0$, its best static value is $B = (n-1)/(n+1)$, its dial value is $D = -1$, and*
$$B - D \;=\; \frac{2n}{n+1}.$$
*Consequently, for every $\delta > 0$ there is a $1$-invisible portfolio with dial gain $> 2 - \delta$: the constant $2$ in Theorem 5.4 cannot be lowered.*

*Proof.* Each fiber is a singleton $\{\omega\}$, so $\mu(o) = 1/(n+1)$ and $V(o,s) = c(o,s)/(n+1)$, giving $|V(o,s) - \mu(o)\cdot 0| = 1/(n+1) = 1 \cdot \mu(o)$: exactly $1$-invisible. Each member costs $-1$ on one instance and $+1$ on the other $n$, so $\mathbb{E}[c(\cdot,s)] = (n-1)/(n+1)$ for all $s$, whence $B = (n-1)/(n+1)$. On each singleton fiber the minimum over members is $-1/(n+1)$, so $D = -1$. Subtract; then choose $n > 2/\delta$. $\square$

Already $n=1$ forces $B - D = 1 = \varepsilon$, so a single pair of fibers costs half the extremal constant.

**Theorem 5.6 (the naive converse fails).** *A zero dial gain does not certify near-invisibility. Let $\Omega = \{0,1\}$ with $w \equiv 1/2$, let the portfolio have any number of members, and let $c(\omega,s) = 0$ for $\omega = 0$ and $c(\omega,s) = 2$ for $\omega = 1$, independently of $s$. Then on the finest observation the dial gain is $0$, yet the portfolio is not $\varepsilon$-invisible for any $\varepsilon < 1$ and any profile $m$.*

*Proof.* All members have identical cost functions, so every rule has the same cost as every constant rule and the gain is $0$ (this holds for any observation). For the second claim: with $\varphi = \mathrm{id}$, $\mu(0) = \mu(1) = 1/2$, $V(0,s) = 0$ and $V(1,s) = 1$. The $\varepsilon$-invisibility conditions read $|0 - m(s)/2| \le \varepsilon/2$ and $|1 - m(s)/2| \le \varepsilon/2$; adding them and using the triangle inequality gives $1 \le \varepsilon$. $\square$

So the implication in Theorem 5.4 is genuinely one-directional: near-invisibility caps the gain, but a null gain is only one-sided evidence about the observation. What a null gain *does* certify is the subject of the next section.

---

## 6. What a null measurement certifies

**Definition 6.1 (fiberwise regret).** The *fiberwise regret* of member $s$ is
$$\mathrm{FR}(s) \;=\; \sum_{o \in O} \Bigl( V(o,s) - \min_{t} V(o,t) \Bigr) \;\ge\; 0 .$$

**Lemma 6.2.** $\mathrm{FR}(s) = \mathbb{E}[c(\cdot,s)] - D(\varphi)$.

*Proof.* Split the sum and apply Corollary 3.2 and Definition 2.4. $\square$

**Theorem 6.3 (the dial gain is an optimisation over members).**
$$B - D(\varphi) \;=\; \min_{s \in S} \mathrm{FR}(s).$$

*Proof.* By Lemma 6.2, $\min_s \mathrm{FR}(s) = \min_s \mathbb{E}[c(\cdot,s)] - D(\varphi) = B - D(\varphi)$. $\square$

Thus the scheduling gap is not merely bounded by member-level quantities: it *equals* one, namely the smallest total fiberwise shortfall in the portfolio.

**Theorem 6.4 (the correct converse: null gain $=$ fiberwise champion).**
$$D(\varphi) = B \quad\Longleftrightarrow\quad \exists\, s \in S\ \forall\, o \in O:\ V(o,s) = \min_t V(o,t).$$

*Proof.* By Theorem 6.3, $D(\varphi) = B$ iff some $s$ has $\mathrm{FR}(s) = 0$. Since each summand of $\mathrm{FR}(s)$ is nonnegative, $\mathrm{FR}(s) = 0$ iff all summands vanish, i.e. $s$ attains the fiberwise minimum everywhere. $\square$

This is the exact content of the measured $\Delta = 0.000$: it certifies the existence of a single member that minimises conditional cost on every fiber — nothing more. It does not certify invisibility of the observation (Theorem 5.6), nor the absence of member-discriminating information.

For a two-member portfolio the gap has a fully explicit form.

**Definition 6.5 (swap mass).** For $f,g : O \to \mathbb{Q}$ set $\mathrm{Sw}(f,g) = \sum_{o} \max\bigl(f(o) - g(o),\, 0\bigr)$, the total excess of $f$ over $g$ on the fibers where $f$ loses.

**Theorem 6.6 (two-member gap).** *For $S = \{0,1\}$, writing $f(o) = V(o,0)$ and $g(o) = V(o,1)$,*
$$B - D(\varphi) \;=\; \min\bigl(\mathrm{Sw}(f,g),\ \mathrm{Sw}(g,f)\bigr).$$
*Consequently a dial strictly helps for a two-member portfolio if and only if both swap masses are strictly positive — a decidable test.*

*Proof sketch.* $B = \min(\sum_o f, \sum_o g)$ by Corollary 3.2, and $D = \sum_o \min(f(o),g(o))$. Using $\min(a,b) = a - (a-b)^+$ and $\min(a,b) = b - (b-a)^+$ termwise, one gets $\sum_o f - D = \mathrm{Sw}(f,g)$ and $\sum_o g - D = \mathrm{Sw}(g,f)$; taking the minimum of these two differences gives the claim. $\square$

But the pairwise certificate is not visible at portfolio level.

**Theorem 6.7 (a swap hidden by a third member).** *There is an explicit three-member portfolio whose dial gain is exactly $0$ while two of its members have swap masses $1$ in both directions.*

Indeed, by Theorem 6.4 the gain vanishes as soon as a third member is fiberwise optimal everywhere, and this constraint says nothing about how the other two behave relative to each other. A null dial can hide arbitrarily much pairwise structure.

The natural repair is to delete the dominating structure first.

**Definition 6.8 (irredundant portfolio).** The portfolio is *irredundant* for $\varphi$ if for all $s \ne t$ there is a fiber $o$ with $V(o,t) < V(o,s)$; equivalently, no member is weakly beaten by another on *every* fiber, so the fiberwise elimination rule (Theorem 7.7 below) applies to no pair.

One might hope that on an irredundant portfolio the measured gain controls all pairwise swap masses, up to a constant depending only on the number of members. It does not — already with three members, and for every constant.

**Theorem 6.9 (pairwise structure is unbounded on irredundant portfolios).** *For $e \in \mathbb{Q}$ with $0 < e \le 1$, let $\Omega = O = S = \{0,1,2\}$ with uniform weights $1/3$, the finest observation, and cost matrix (rows $=$ instances, columns $=$ members)*
$$c \;=\; \begin{pmatrix} 0 & 10 & e \\ 10 & 0 & e \\ 10 & 10 & 0 \end{pmatrix}.$$
*Then the portfolio is irredundant, its dial value is $0$, its best static value is $2e/3$, hence its dial gain is exactly $2e/3$; while the swap masses of members $0$ and $1$ are exactly $10/3$ in both directions. Consequently, for every $M$ there is an irredundant three-member portfolio with*
$$M \cdot \bigl(B - D(\varphi)\bigr) \;<\; \min\bigl(\mathrm{Sw}, \mathrm{Sw}'\bigr).$$

*Proof.* Each fiber is a singleton with mass $1/3$, so $V(o,s) = c(o,s)/3$. The row minima are all $0$, so $D = 0$. The column means are $20/3,\ 20/3,\ 2e/3$; since $e \le 1$, $B = 2e/3$. Irredundancy: for the ordered pair $(s,t) = (0,1)$ take $o = 1$ ($0 < 10$); for $(1,0)$ take $o=0$; for $(s,2)$ with $s \in \{0,1\}$ take $o = 2$ ($0 < 10$); for $(2,s)$ take the fiber $o = s$, where $c(s,s) = 0 < e$ — this is where $e > 0$ is needed. The swap masses between members $0$ and $1$ are $\max(0-10,0)/3 + \max(10-0,0)/3 + \max(10-10,0)/3 = 10/3$, and symmetrically. Finally take $e$ small enough that $M \cdot 2e/3 < 10/3$. $\square$

The moral for the measured cell is sharp: a small scheduling gain is compatible with arbitrarily large pairwise trade-offs even after every eliminable member has been removed. Pairwise structure must be measured pair by pair (Theorem 6.6), never inferred from a portfolio-level dial.

---

## 7. The statistics of regret, and elimination discipline

### 7.1 Median blindness

**Definition 7.1.** The *regret ratio* of member $s$ on instance $\omega$ is $c(\omega,s)/\mathrm{Or}(\omega)$ (defined when $\mathrm{Or}(\omega) > 0$).

Experiment reports a median regret ratio of exactly $1.000$ for every strategy considered, alongside a mean regret of $3.117$. This combination is not an anomaly.

**Theorem 7.2 (median blindness).** *For every $M \ge 0$ there is a two-instance, two-member portfolio with strictly positive oracle cost whose optimal static member ties the oracle on probability mass at least $1/2$ — median regret ratio exactly $1$ — while its mean regret ratio exceeds $M$.*

*Proof.* Take $\Omega = \{0,1\}$ with $w = (3/4,\,1/4)$ and
$$c \;=\; \begin{pmatrix} 1 & 8M+8 \\ 4M+4 & 1 \end{pmatrix}.$$
The oracle cost is $\min(1, 8M+8) = 1$ on instance $0$ and $\min(4M+4,1) = 1$ on instance $1$. The means are $\mathbb{E}[c(\cdot,0)] = \tfrac34 + \tfrac14(4M+4) = M + \tfrac74$ and $\mathbb{E}[c(\cdot,1)] = \tfrac34(8M+8) + \tfrac14 = 6M + \tfrac{25}{4}$, so member $0$ is optimal for $M \ge 0$. It ties the oracle on instance $0$, of mass $3/4 \ge 1/2$, so its median regret ratio is $1$. Since the oracle is identically $1$, its mean regret ratio is $M + 7/4 > M$. $\square$

Hence the median is a provably uninformative statistic for portfolio selection: it can equal $1$ while the mean is arbitrarily large, and this for the *optimal* static member, not a straw man.

### 7.2 The tail is forced

**Theorem 7.3 (reverse Markov bound).** *Let $X : \Omega \to \mathbb{Q}$ satisfy $X \le K$ pointwise, and let $t < K$. Then*
$$\Pr\bigl[X > t\bigr] \;\ge\; \frac{\mathbb{E}[X] - t}{K - t}.$$

*Proof.* Split $\mathbb{E}[X]$ over $\{X > t\}$ and its complement. On the tail, $X \le K$ gives a contribution at most $K\Pr[X>t]$; on the bulk, $X \le t$ gives at most $t(1 - \Pr[X>t])$. Hence $\mathbb{E}[X] \le t + (K-t)\Pr[X>t]$; rearrange, using $K - t > 0$. $\square$

Applied to the measured cell (Section 10): the best static member has mean $4117/1000$ and no run costs more than $1179/140$; taking $t = 1$ (the oracle cost) forces
$$\Pr[\text{best static member loses}] \;\ge\; \frac{4117/1000 - 1}{1179/140 - 1} \;=\; \frac{3117/1000}{1039/140} \;=\; 0.42 .$$
The losing minority carries at least $42\%$ of the mass — exactly the complement of the $58\%$ winner share of $\rho$. The fat tail is not an outlier artifact; it is forced by the mean and the cap.

### 7.3 Layer cake and stochastic dominance

**Definition 7.4.** For integer-valued $X, Y : \Omega \to \mathbb{N}$, say $X$ is *stochastically dominated* by $Y$ if $\Pr[X > t] \le \Pr[Y > t]$ for all $t \in \mathbb{N}$.

**Lemma 7.5 (finite layer cake).** *If $X \le B$ pointwise, then $\mathbb{E}[X] = \sum_{t=0}^{B-1} \Pr[X > t]$.*

*Proof.* Exchange the order of summation in $\sum_{t<B}\sum_\omega w(\omega)\,\mathbf 1[t < X(\omega)]$; the inner index set is $\{0,\dots,X(\omega)-1\}$, of size $X(\omega)$. $\square$

**Theorem 7.6 (dominance implies a mean inequality; the converse fails).** *If $X$ and $Y$ are bounded by $B$ and $X$ is stochastically dominated by $Y$, then $\mathbb{E}[X] \le \mathbb{E}[Y]$. Conversely, $\mathbb{E}[X] < \mathbb{E}[Y]$ does not imply dominance: with $w = (1/2,1/2)$, $X = (0,10)$ and $Y = (6,6)$ we have $\mathbb{E}[X] = 5 < 6 = \mathbb{E}[Y]$, yet $\Pr[X > 6] = 1/2 > 0 = \Pr[Y > 6]$.*

*Proof.* The first claim is Lemma 7.5 applied termwise. The second is the displayed computation. $\square$

### 7.4 Elimination: what is safe

**Theorem 7.7 (safe eliminations).**
1. *(Pointwise dominance.)* If $c(\omega,a) \le c(\omega,b)$ for every instance $\omega$, then deleting $b$ from the portfolio leaves the oracle unchanged instancewise, hence in expectation.
2. *(Fiberwise dominance.)* If $V(o,a) \le V(o,b)$ for every fiber $o$, then deleting $b$ changes neither the optimal dial value nor the best static value.

*Proof.* Both are instances of the elementary fact that deleting an element of a finite set that is weakly beaten by a surviving element does not change the infimum — applied pointwise to $c(\omega,\cdot)$ in case 1, and fiberwise to $V(o,\cdot)$ (and to $\mathbb{E}[c(\cdot,\cdot)]$, by Corollary 3.2) in case 2. $\square$

**Theorem 7.8 (mean-based elimination is unsafe).** *There is a two-member portfolio in which one member has twice the mean cost of the other, yet deleting it doubles the expected oracle cost. Take $w = (3/4,1/4)$ and*
$$c \;=\; \begin{pmatrix} 1 & 5 \\ 5 & 1\end{pmatrix}.$$
*Then $\mathbb{E}[c(\cdot,0)] = 2$, $\mathbb{E}[c(\cdot,1)] = 4$, the oracle costs $1$ everywhere, and the oracle of the sub-portfolio $\{0\}$ costs $2$.*

*Proof.* Direct computation. $\square$

The hierarchy is therefore: pointwise dominance (safest, preserves the oracle) $\Rightarrow$ fiberwise dominance (preserves dial and static values) $\Rightarrow$ stochastic dominance (implies only a mean inequality) $\not\Leftarrow$ mean comparison (no elimination content at all).

### 7.5 Winner shares measure the sampler

A final scope caveat, provable in full generality. Let $S$ be a finite member set, $P > 1$ a penalty, and consider the *diagonal portfolio* on $\Omega = S$ with $c(\omega,s) = 1$ if $s = \omega$ and $P$ otherwise: each member wins exactly on its own instance class.

**Theorem 7.9 (share realisability).** *For every probability vector $p$ on $S$, the diagonal portfolio sampled with weights $p$ has oracle winner shares exactly $p$; the expected cost of member $s$ is $p(s) + (1 - p(s))P$; and the static ranking of the members is exactly the ranking of $p$ (larger share $\Rightarrow$ smaller expected cost).*

*Proof.* Member $s$ wins exactly on $\omega = s$, of mass $p(s)$; the cost identity is a one-line computation, and it is decreasing in $p(s)$ because $P > 1$. $\square$

Consequently the measured share vector $(0.580, 0.345, 0.045, 0.028, 0.002)$ is a statement about the *instance sampler*, not about the algorithms: any share vector whatsoever is realisable. "No universal winner" can neither be inferred from, nor refuted by, a single sampler. A sampler over wide parameter ranges dilutes the Fermat channel relative to a balanced-bet design, and the shares move accordingly.

---

## 8. The hidden channel is number-theoretic

**Definition 8.1 (powersmoothness).** For $B, n \in \mathbb{N}$, $n$ is *$B$-powersmooth* if every prime power $p^k$ dividing $n$ satisfies $p^k \le B$.

The organising coordinate of the measured cell is the $B$-powersmoothness of $p-1$ for the prime factors $p$ of $N$: when it holds, the $p-1$ method at bound $B$ wins immediately; when it fails, it is useless and the generic method (Pollard's rho) takes over.

**Theorem 8.2 (strict invisibility of the channel).** *There exist balanced semiprimes $N_1 = p_1q_1$ and $N_2 = p_2q_2$ with the same visible profile — both exactly $21$ bits, with both prime factors exactly $11$ bits — such that $p_1 - 1$ and $q_1 - 1$ are both $256$-powersmooth while neither $p_2 - 1$ nor $q_2 - 1$ is.*

*Proof.* Take $N_1 = 1051 \cdot 1033 = 1085683$ and $N_2 = 1319 \cdot 1307 = 1723933$. All four factors lie in $[2^{10}, 2^{11})$ and both products lie in $[2^{20}, 2^{21})$. Now $1051 - 1 = 2 \cdot 3 \cdot 5^2 \cdot 7$ with prime powers $2, 3, 25, 7 \le 256$, and $1033 - 1 = 2^3 \cdot 3 \cdot 43$ with prime powers $8, 3, 43 \le 256$; while $1319 - 1 = 2 \cdot 659$ and $1307 - 1 = 2 \cdot 653$ with $659, 653 > 256$ prime. $\square$

Thus the observation fiber determined by $(\text{bit length of } N, \text{bit lengths of the factors})$ genuinely contains both smoothness classes: the channel is invisible in the strong, pointwise sense — not merely on average.

The other half of the story is that the invisible coordinate *can be bought*.

**Theorem 8.3 (a capped probe detects the smooth class).** *Let $p$ be prime with $p - 1$ $B$-powersmooth, and put $L = \mathrm{lcm}(1,2,\dots,B)$. Then $p \mid a^{L} - 1$ for every integer $a$ not divisible by $p$.*

*Proof.* Write $p - 1 = \prod_i q_i^{k_i}$. Each $q_i^{k_i} \le B$ by powersmoothness, so each $q_i^{k_i}$ divides $L$, and therefore $p - 1 \mid L$. Since $a \not\equiv 0 \pmod p$, Fermat's little theorem gives $a^{p-1} \equiv 1 \pmod p$, hence $a^{L} \equiv 1 \pmod p$. $\square$

Consequently $\gcd(a^{L} \bmod N - 1,\ N)$ is a nontrivial factor of any $N$ divisible by such a $p$: a short, budget-capped $p-1$ computation is a genuine one-sided *observation* of the hidden coordinate, and the value-of-information theory of Sections 3–5 applies to a real, purchasable channel. By Theorem 4.6, buying it at price $\kappa$ pays exactly when $\kappa$ is below the static regret.

---

## 9. Ordered probes and threshold schedules

Suppose the probe returns not a bit but an ordered readout — a smoothness quantile. One would like the optimal schedule to be a *threshold rule* in that scalar rather than an unstructured lookup table. This holds under exactly the classical single-crossing hypothesis.

**Definition 9.1 (decreasing differences).** Let $O$ and $S$ be preordered. A function $F : O \times S \to \mathbb{Q}$ has *decreasing differences* if for all $o \le o'$ and $s \le s'$,
$$F(o',s') - F(o',s) \;\le\; F(o,s') - F(o,s).$$
In words: raising the observation never raises the cost of a later member relative to an earlier one.

**Definition 9.2.** For a linearly ordered finite $S$ and $f : S \to \mathbb{Q}$, let $\mathrm{lam}(f)$ be the *least* minimiser of $f$.

**Theorem 9.3 (discrete Topkis).** *If $F$ has decreasing differences, then $o \mapsto \mathrm{lam}(F(o,\cdot))$ is monotone.*

*Proof sketch.* Suppose $o \le o'$ but $t := \mathrm{lam}(F(o',\cdot)) < s := \mathrm{lam}(F(o,\cdot))$. Optimality of $s$ at $o$ gives $F(o,s) \le F(o,t)$, and *least*-ness gives strictness unless $t$ also minimises, which contradicts $t<s$; so $F(o,s) < F(o,t)$, i.e. $F(o,t) - F(o,s) > 0$. Decreasing differences applied to $t \le s$ and $o \le o'$ yields $F(o',s) - F(o',t) \le F(o,s) - F(o,t) < 0$, so $F(o',s) < F(o',t)$, contradicting optimality of $t$ at $o'$. $\square$

**Theorem 9.4 (threshold optimality).** *Let $O$ be a finite linear order and $S$ a finite linear order. If the fiber-value table $V$ has decreasing differences in (observation, member), then the rule $\pi^\star(o) = \mathrm{lam}(V(o,\cdot))$ is monotone and attains the optimal dial value $D(\varphi)$. Scheduling on an ordered probe therefore reduces to a threshold search.*

*Proof.* $\pi^\star$ attains the fiberwise minima, so it attains $D(\varphi)$ by Theorem 3.3; it is monotone by Theorem 9.3. $\square$

**Corollary 9.5 (interval and threshold structure).** *For a monotone rule, the set of observations on which a given member is played is an interval of the order (order-convex). For a two-member portfolio it is literally a threshold: if the second member is played at $o$ and $o \le o'$, then it is played at $o'$ — the set on which it is played is upward-closed.*

**Theorem 9.6 (necessity of single crossing).** *There is a $2 \times 2$ cost table without decreasing differences whose fiberwise-optimal schedule is not monotone, hence not a threshold rule. Ordered observations alone do not make optimal schedules ordered.*

The practical reading: before searching for a smoothness threshold, check the single-crossing property of the conditional cost table. If it holds, one may search over the $|S|$-choose-thresholds family instead of the $|S|^{|O|}$ rules, at no loss.

---

## 10. The measured cell as an exact rational model

We now assemble a portfolio whose numbers coincide *exactly* with the measured ones, and derive each reported quantity from the theory.

**Construction 10.1.** Let $\Omega = \{0,1,2,3,4\} \times \{0,1\}$. The first coordinate is the *hidden* powersmoothness class — equivalently, which member wins — with masses
$$\lambda = \left(\tfrac{58}{100},\ \tfrac{345}{1000},\ \tfrac{45}{1000},\ \tfrac{28}{1000},\ \tfrac{1}{500}\right),$$
matching the measured winner shares $0.580, 0.345, 0.045, 0.028, 0.002$. The second coordinate is a *visible* bit (a bit-length or balance quintile marker), a fair coin drawn independently, so $w(c,b) = \lambda(c)/2$. The observation available to a scheduler is $\varphi(c,b) = b$. Each member costs $1$ on the class it owns and the common penalty $P = 1179/140 \approx 8.4214$ elsewhere:
$$c\bigl((c_0,b),\,s\bigr) = \begin{cases} 1 & s = c_0,\\ P & s \ne c_0.\end{cases}$$

**Theorem 10.2 (properties of the measured model).**
1. *Winner shares.* The oracle winner shares are exactly $(0.580, 0.345, 0.045, 0.028, 0.002)$.
2. *No universal winner.* Every member wins on a set of positive mass and loses on a set of positive mass.
3. *Invisibility.* $\varphi$ is invisible with profile $m(s) = \lambda(s) + (1-\lambda(s))P$; both fibers have mass $1/2$.
4. *Static value and regret.* $B = m(0) = 4117/1000 = 4.117$, $\mathbb{E}[\mathrm{Or}] = 1$, and the static regret is exactly $R = 3117/1000 = 3.117$.
5. *No dial edge.* Every rule reading the visible bit costs at least $4.117$; the dial gain is $0$.
6. *A learned rule is strictly worse.* The two-armed rule playing $\rho$ on one value of the bit and $(p-1)@256$ on the other costs exactly $279385/56000 \approx 4.989 > 4.117$.
7. *Probe threshold.* Buying the hidden class at price $\kappa$ per instance beats the best static schedule if and only if $\kappa < 3.117$.
8. *Forced tail.* At least $42\%$ of the mass lies in the set where the best static member loses.

*Proof.* (1) Member $s$ is uniquely cheapest exactly on the classes $c_0 = s$, of mass $\lambda(s)$, since $P > 1$. (2) Immediate from (1) and $\lambda(s) \in (0,1)$. (3) The fiber over $b$ is a copy of the class axis with weights $\lambda/2$; hence $V(b,s) = \tfrac12\bigl(\lambda(s)\cdot 1 + (1-\lambda(s))P\bigr) = \mu(b)m(s)$ with $\mu(b) = 1/2$. (4) By Lemma 4.2, $B = \min_s m(s)$; since $m(s) = P - \lambda(s)(P-1)$ is decreasing in $\lambda(s)$, the minimum is at $s = 0$, giving $m(0) = 0.58 + 0.42 \cdot \tfrac{1179}{140} = 0.58 + 3.537 = 4.117$. The oracle costs $1$ on every instance. (5) Theorem 4.3 with (3). (6) By Theorem 3.1 the cost is $\tfrac12 m(0) + \tfrac12 m(1)$, where $m(1) = 0.345 + 0.655\cdot\tfrac{1179}{140} = 164109/28000 \approx 5.8610$; adding $m(0) = 4.117$ and halving gives $279385/56000 \approx 4.9890$. (7) Theorem 4.6 with (4). (8) Theorem 7.3 with $\mathbb{E}[X] = 4.117$, $K = 1179/140$, $t = 1$. $\square$

Every headline number of the experiment is thereby a theorem about an explicit rational portfolio: the shares, the $3.117$ static regret, the $\Delta = 0.000$ dial, the worse-than-static learned rule, the $0.42$ tail, and the probe threshold. In particular, the penalty $P = 1179/140$ is precisely calibrated so that the reverse Markov bound at $t=1$ returns exactly the complementary share $0.42$.

---

## 11. Discussion

**What the null result means.** The most common reading of $\Delta = 0.000$ is "the tuner failed". Theorems 4.3 and 4.4 say otherwise: when the observation is invisible for the portfolio, the do-nothing dial is *optimal*, and any deviation on positive mass is strictly harmful. A learner that responds to invisible features cannot break even. The measured degradation of the learned rule (from $4.117$ to $4.683$ in the experiment; to $4.989$ for the exact two-armed model) is therefore a lower-bound phenomenon, not a fitting artifact.

**What to compute instead of tuning.** Theorem 3.3 gives an $O(|\Omega| \cdot |S| + |O|\cdot|S|)$ procedure that returns both the ceiling of every possible router on the given features and an optimal router attaining it. Theorem 5.4 turns a *measurement* of near-invisibility into an a-priori cap of $2\varepsilon$ on that ceiling. Theorem 4.6 reduces the decision "should we buy information?" to comparing a price with the static regret. None of these require training.

**Evidence discipline.** Three asymmetries recur. (i) Near-invisibility caps the dial gain, but a null dial gain does not imply near-invisibility (Theorems 5.4, 5.6); what it does imply is the existence of a fiberwise champion (Theorem 6.4). (ii) Stochastic dominance implies a mean inequality, but a mean inequality implies nothing about elimination (Theorems 7.6, 7.8). (iii) A portfolio-level dial gain says nothing about pairwise structure, even after irredundancy (Theorems 6.7, 6.9). Each asymmetry corresponds to a natural but invalid inference that the theory now blocks.

**Scope.** The winner shares are a property of the sampler (Theorem 7.9), so all quantitative statements are conditional on the instance distribution. A sampler over wide bit-length ranges dilutes channels — Fermat's method in particular — relative to a design that deliberately balances the factors. The correct object to report alongside any share table is the sampler, and ideally the dial value of every feature set considered.

**Limitations.** The theory is finite, and costs are treated as deterministic given the instance; randomised members with instance-dependent cost distributions require replacing $c(\omega,s)$ by a conditional mean, which preserves all results in Sections 3–7 verbatim (they use only linearity and nonnegativity of weights). Capped runs — the realistic setting, where a member may be stopped at a budget — are modelled by censoring the cost at the cap, which is exactly the boundedness hypothesis $X \le K$ used in the reverse Markov bound. Sequential and interleaved schedules (running several members concurrently with a time-slicing schedule) are outside the present model; extending the dial-edge criterion to that setting is the most interesting open direction.

---

## 12. Future directions

1. **Paid smoothness probes as first-class observations.** The theory prices perfect information at the static regret. The realistic probe is *partial*: a $p-1$ attempt capped at a small budget, returning a one-sided signal. Model it as an observation with a known false-negative rate and compute the resulting dial value as a function of the cap, converting Theorem 4.6 into an optimal-budget theorem.
2. **Noisy quantile channels.** Combine Section 9 with a noise model: if the observed quantile is the true smoothness quantile perturbed by a stochastic kernel, does the single-crossing property survive? Monotone likelihood ratio kernels are the natural sufficient condition.
3. **Interleaved schedules.** Extend the ladder to time-sliced portfolios where several members run concurrently. The oracle stays the same, but the "static" benchmark becomes a simplex of time allocations, and the dial-edge criterion should acquire a Blackwell-type form.
4. **Sampler-invariant reporting.** Given Theorem 7.9, design a report that separates algorithm properties from sampler properties — e.g. the dial value of a canonical family of feature sets, normalised across samplers.
5. **Empirical $\varepsilon$ estimation.** Turn Theorem 5.4 into a statistical procedure: estimate $\varepsilon$ from finite samples with confidence bands, yielding a certified upper bound on the achievable gain of any router on a given feature set.
6. **Beyond pairwise measurement.** Theorem 6.9 shows that pairwise swap masses are not controlled by the portfolio-level gain. Is there a tractable intermediate statistic — a subset-level gain, say — that does control them?

---

## Appendix A: Summary of the main statements

| Result | Statement |
|---|---|
| Fiberwise decomposition | $\mathbb{E}[c(\cdot,\pi\circ\varphi)] = \sum_o V(o,\pi(o))$ |
| Dial value | $D(\varphi) = \sum_o \min_s V(o,s)$, attained, and $\le$ every rule |
| Information ladder | $\mathbb{E}[\mathrm{Or}] \le D(\varphi) \le B$ |
| Monotone information | $\varphi = g\circ\psi \Rightarrow D(\psi) \le D(\varphi)$ |
| Dial-edge criterion | $D(\varphi) < B \iff$ every member is strictly beaten on some fiber |
| No dial edge | invisibility $\Rightarrow$ every rule costs $\ge B$ |
| Strict harm | deviation on a positive-mass fiber to a suboptimal member $\Rightarrow$ strictly $> B$ |
| Stability | $\varepsilon$-invisibility $\Rightarrow B - D(\varphi) \le 2\varepsilon$; constant $2$ optimal |
| Failed converse | zero gap $\not\Rightarrow$ $\varepsilon$-invisibility for any $\varepsilon<1$ |
| Gap formula | $B - D(\varphi) = \min_s \mathrm{FR}(s)$ |
| Null-dial certificate | $D(\varphi) = B \iff$ a fiberwise champion exists |
| Two-member gap | $B - D(\varphi) = \min(\mathrm{Sw}(f,g), \mathrm{Sw}(g,f))$ |
| Hidden swaps | irredundancy does not bound swap mass by the gain |
| Median blindness | median ratio $1$ with mean ratio $> M$, for the optimal static member |
| Reverse Markov | $\Pr[X>t] \ge (\mathbb{E}[X]-t)/(K-t)$ for $X \le K$ |
| Elimination | pointwise / fiberwise dominance safe; mean comparison unsafe |
| Share realisability | every share vector is realisable by some sampler |
| Channel invisibility | $21$-bit balanced semiprimes, identical profile, opposite $256$-smoothness class |
| Probe guarantee | $p-1$ $B$-powersmooth $\Rightarrow p \mid a^{\mathrm{lcm}(1..B)}-1$ |
| Threshold optimality | decreasing differences $\Rightarrow$ a monotone rule attains $D(\varphi)$; hypothesis necessary |
| Probe economics | probe at price $\kappa$ pays $\iff \kappa <$ static regret |
