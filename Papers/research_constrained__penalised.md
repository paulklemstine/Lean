# Constrained Equals Penalised: A Calculus-Free Duality for KL-Regularised Reward Maximisation, and its Tropical Ceiling

**Author:** Aristotle
**Date:** 2026-09-09

---

## Abstract

We study, over a finite outcome set, the two standard formulations of reward maximisation under a relative-entropy regulariser: the *penalised* problem $\max_p \{\mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0)\}$, whose solution is the exponential tilt $\pi^*_\beta \propto \pi_0 e^{r/\beta}$, and the *constrained* problem $\max\{\mathbb{E}_p[r] : \mathrm{KL}(p\|\pi_0) \le k\}$. We prove their exact equivalence and, more precisely, that the map $\beta \mapsto \mathrm{KL}(\pi^*_\beta\|\pi_0)$ is a bijection from $(0,\infty)$ onto an interval $(0, L)$ whose right endpoint is the *tropical ceiling*
$$L \;=\; -\log \pi_0\bigl(\arg\max r\bigr),$$
the negative logarithm of the reference mass carried by the reward-maximising outcomes.

The entire development rests on a single algebraic identity — the *duality identity*
$$t\bigl(\mathbb{E}_{p_t}[r] - \mathbb{E}_p[r]\bigr) \;=\; \mathrm{KL}(p_t\|\pi_0) - \mathrm{KL}(p\|\pi_0) + \mathrm{KL}(p\|p_t),$$
valid for every probability vector $p$ and every tilt parameter $t$ — and requires no differentiation of the log-partition function, no Lagrange multipliers, and no KKT theory. From it we deduce: constrained optimality and uniqueness of the tilt inside its own divergence ball; strict monotonicity and continuity of the budget curve $k(t) = \mathrm{KL}(p_t\|\pi_0)$; convexity of $\log Z$ via a Bregman identity; a *shadow-price bracket* identifying the temperature with the marginal price of one nat; concavity of the reward–divergence Pareto frontier; and the two-sided *tropical sandwich* $tM + \log w \le \log Z(t) \le tM$ exhibiting the zero-temperature limit as Maslov dequantization, $t^{-1}\log Z(t) \to \max_i r(i)$. The frontier terminates at the tropical corner $(L, \max_i r)$.

**Keywords:** relative entropy, exponential tilting, Gibbs variational principle, Maslov dequantization, tropical semiring, Bregman divergence, shadow price, alignment.

---

## 1. Introduction

### 1.1 Two ways to say "don't go too far"

Let $\pi_0$ be a fixed reference probability distribution on a finite set of outcomes and let $r$ assign a real-valued reward to each outcome. A pervasive design problem — appearing in statistical mechanics, importance sampling, robust control, portfolio selection, large deviations, and the reinforcement-learning fine-tuning of generative models — is to produce a new distribution $p$ scoring highly under $r$ while remaining close to $\pi_0$ in relative entropy. Two formulations compete:

* **Penalised (soft).** Maximise $J_\beta(p) = \mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0)$ over probability vectors $p$, for a fixed *temperature* $\beta > 0$.
* **Constrained (hard).** Maximise $\mathbb{E}_p[r]$ over $\{p : \mathrm{KL}(p\|\pi_0) \le k\}$, for a fixed *budget* $k > 0$.

Folklore holds that these are equivalent under a correspondence $\beta \leftrightarrow k$. The folklore is correct, but the standard derivations obscure two things. First, they invoke machinery — Lagrangian duality, differentiability of the log-partition function, strong duality via Slater's condition — far heavier than the statement requires. Second, they rarely make the correspondence's *domain* explicit, and the domain is the interesting part: the set of achievable budgets is a bounded interval whose endpoint is not an entropy but a max-plus invariant of the pair $(\pi_0, r)$.

### 1.2 Contributions

1. **A calculus-free engine.** A single identity (Theorem 3.3) implies constrained optimality, uniqueness of the optimum, monotonicity of the budget curve, convexity of $\log Z$, the shadow-price bracket, and concavity of the Pareto frontier. No derivative of $\log Z$ is ever taken.
2. **The tropical ceiling.** We identify the exact supremum of achievable KL budgets as $L = -\log w$, where $w = \pi_0(\arg\max r)$, and show the budget curve is a strictly increasing continuous bijection $[0,\infty) \to [0, L)$ (Theorems 5.5, 5.6, 6.1).
3. **Maslov dequantization with explicit error.** The two-sided sandwich $tM + \log w \le \log Z(t) \le tM$ (Theorem 5.3) both proves $t^{-1}\log Z(t) \to \max r$ and *is* the source of the ceiling: the same quantity $w$ controls both.
4. **The headline equivalence.** For every $0 < k < L$ there is a unique $\beta > 0$ with $\mathrm{KL}(\pi^*_\beta\|\pi_0) = k$, and $\pi^*_\beta$ is the unique maximiser of $\mathbb{E}_p[r]$ over the ball of radius $k$ (Theorem 6.3).
5. **The frontier.** A Bregman identity, a shadow-price bracket $\tfrac{1}{t} \le \Delta V/\Delta k \le \tfrac{1}{s}$, concavity of the frontier, and convergence to the tropical corner $(L, \max r)$ (Section 7).

### 1.3 Standing assumptions

Throughout, $\iota$ is a finite nonempty index set of outcomes. A *probability vector* is $p : \iota \to \mathbb{R}$ with $p(i) \ge 0$ for all $i$ and $\sum_i p(i) = 1$; we write $\Delta$ for the set of these. The reference $\pi_0$ is a probability vector with $\pi_0(i) > 0$ for every $i$ — strict positivity is what makes every divergence below finite. The reward $r : \iota \to \mathbb{R}$ is arbitrary; where strictness is needed we assume it is *non-constant*, i.e. $r(i) \ne r(j)$ for some $i, j$.

---

## 2. Definitions

**Definition 2.1 (Relative entropy).** For $p, q : \iota \to \mathbb{R}$,
$$\mathrm{KL}(p\|q) \;=\; \sum_i p(i)\,\log\frac{p(i)}{q(i)},$$
with the standard convention $0\log 0 = 0$ (automatic here, since the summand is $p(i)$ times a logarithm and vanishes when $p(i) = 0$).

**Definition 2.2 (Expectation).** $\mathbb{E}_p[f] = \sum_i p(i) f(i)$.

**Definition 2.3 (Partition function and tilt).** For $t \in \mathbb{R}$,
$$Z(t) \;=\; \sum_i \pi_0(i)\, e^{t\,r(i)}, \qquad p_t(i) \;=\; \frac{\pi_0(i)\,e^{t\,r(i)}}{Z(t)}.$$
We call $t$ the *tilt parameter* or inverse temperature. Since $\pi_0 > 0$ and $\iota \ne \emptyset$, we have $Z(t) > 0$ and $p_t \in \Delta$ with $p_t > 0$ strictly, for every real $t$; and $p_0 = \pi_0$.

**Definition 2.4 (Penalised optimum).** For $\beta > 0$, $\pi^*_\beta := p_{1/\beta}$, i.e. $\pi^*_\beta(i) \propto \pi_0(i)\,e^{r(i)/\beta}$.

**Definition 2.5 (Budget curve).** $k(t) := \mathrm{KL}(p_t \| \pi_0)$, and $V(t) := \mathbb{E}_{p_t}[r]$ is the *value curve*.

**Definition 2.6 (Tropical data).** Let
$$M \;=\; \max_i r(i), \qquad A \;=\; \{ i : r(i) = M \}, \qquad w \;=\; \pi_0(A) = \sum_{i \in A}\pi_0(i),$$
and define the **tropical ceiling** $L := -\log w$ and the **zero-temperature policy**
$$p_\infty(i) \;=\; \begin{cases} \pi_0(i)/w, & i \in A,\\ 0, & i \notin A.\end{cases}$$
Note $M$ is the value of $r$ in the max-plus (tropical) semiring $(\mathbb{R}\cup\{-\infty\}, \max, +)$, $A$ is its tropical support, and $0 < w \le 1$ so $L \ge 0$, with $L = 0$ iff $\pi_0$ is supported on the argmax set.

---

## 3. The engine: Gibbs, decomposition, duality

### 3.1 Gibbs' inequality with its equality case

**Lemma 3.1 (Termwise Gibbs bound).** For $a \ge 0$ and $b > 0$, $\;a - b \le a\log(a/b)$, with equality iff $a = b$.

*Proof sketch.* For $a = 0$ the claim is $-b \le 0$, strict since $b > 0$. For $a > 0$, apply $\log x \le x - 1$ (strict for $x \ne 1$) to $x = b/a$: $\log(b/a) \le b/a - 1$, so $-\log(a/b) \le b/a - 1$. Multiplying by $a > 0$ gives $-a\log(a/b) \le b - a$, i.e. the claim, and strictness is preserved because $b/a \ne 1$ exactly when $a \ne b$. $\square$

**Theorem 3.2 (Gibbs' inequality and its equality case).** If $p, q \in \Delta$ and $q > 0$ pointwise, then $\mathrm{KL}(p\|q) \ge 0$, with equality iff $p = q$.

*Proof sketch.* Summing Lemma 3.1 termwise gives $\sum_i (p(i)-q(i)) \le \mathrm{KL}(p\|q)$; the left side is $1 - 1 = 0$. If $p(i_0) \ne q(i_0)$ for some $i_0$, the corresponding term is strict, so a strict-sum comparison upgrades the inequality to $0 < \mathrm{KL}(p\|q)$. Conversely if $p = q$ every summand is $p(i)\log 1 = 0$ (and $0$ when $p(i) = 0$). $\square$

### 3.2 The master decomposition

**Theorem 3.3 (Master decomposition).** For every $p \in \Delta$ and every $t \in \mathbb{R}$,
$$\mathrm{KL}(p\|p_t) \;=\; \mathrm{KL}(p\|\pi_0) \;-\; t\,\mathbb{E}_p[r] \;+\; \log Z(t).$$

*Proof sketch.* Pointwise, $\log p_t(i) = \log \pi_0(i) + t\,r(i) - \log Z(t)$ because $\pi_0(i)e^{tr(i)}>0$ and $Z(t)>0$. Hence for each $i$ with $p(i) > 0$,
$$p(i)\log\frac{p(i)}{p_t(i)} = p(i)\log\frac{p(i)}{\pi_0(i)} - t\,p(i)r(i) + p(i)\log Z(t),$$
and for $p(i) = 0$ both sides vanish. Summing over $i$ and using $\sum_i p(i) = 1$ on the last term gives the identity. $\square$

Two specialisations do all the work.

**Corollary 3.4 (Closed form for the budget).** $k(t) = t\,V(t) - \log Z(t)$.

*Proof sketch.* Put $p = p_t$ in Theorem 3.3; the left-hand side is $\mathrm{KL}(p_t\|p_t) = 0$ by Theorem 3.2. $\square$

**Theorem 3.5 (The duality identity).** For every $p \in \Delta$ and every $t \in \mathbb{R}$,
$$t\bigl(V(t) - \mathbb{E}_p[r]\bigr) \;=\; k(t) \;-\; \mathrm{KL}(p\|\pi_0) \;+\; \mathrm{KL}(p\|p_t).$$

*Proof sketch.* Subtract Corollary 3.4 from Theorem 3.3 and rearrange; $\log Z(t)$ cancels. $\square$

Every statement in Sections 4, 6 and 7 is a consequence of Theorem 3.5 together with the nonnegativity of relative entropy.

---

## 4. Constrained optimality of the tilt

**Theorem 4.1 (The tilt maximises reward in its own ball).** Let $t > 0$ and let $p \in \Delta$ satisfy $\mathrm{KL}(p\|\pi_0) \le k(t)$. Then $\mathbb{E}_p[r] \le V(t)$.

*Proof sketch.* In Theorem 3.5, the right-hand side is $\bigl(k(t) - \mathrm{KL}(p\|\pi_0)\bigr) + \mathrm{KL}(p\|p_t)$, a sum of two nonnegative terms (the first by feasibility, the second by Theorem 3.2, using $p_t > 0$). Hence $t(V(t) - \mathbb{E}_p[r]) \ge 0$, and $t>0$ gives the claim. $\square$

**Theorem 4.2 (Uniqueness of the maximiser).** If moreover $\mathbb{E}_p[r] = V(t)$, then $p = p_t$.

*Proof sketch.* The left-hand side of Theorem 3.5 is now $0$, so the two nonnegative terms on the right sum to zero; in particular $\mathrm{KL}(p\|p_t) = 0$, and Theorem 3.2 gives $p = p_t$. (No sign hypothesis on $t$ is needed for this argument.) $\square$

Note the shape of the argument: feasibility and Gibbs' inequality are the *only* inputs. In particular one gets, for free, the classical Gibbs variational principle in penalised form, since Theorem 3.3 rearranges to
$$\mathbb{E}_p[r] - \tfrac{1}{t}\,\mathrm{KL}(p\|\pi_0) \;=\; \tfrac{1}{t}\log Z(t) \;-\; \tfrac{1}{t}\,\mathrm{KL}(p\|p_t),$$
so the penalised objective at temperature $\beta = 1/t$ is maximised exactly at $p = p_t = \pi^*_\beta$, with optimal value $\beta \log Z(1/\beta)$.

---

## 5. The budget curve and the tropical ceiling

### 5.1 Monotonicity without derivatives

**Theorem 5.1 (Jeffreys identity).** For all $s, t \in \mathbb{R}$,
$$(t-s)\bigl(V(t) - V(s)\bigr) \;=\; \mathrm{KL}(p_s\|p_t) + \mathrm{KL}(p_t\|p_s).$$

*Proof sketch.* Apply Theorem 3.5 twice — once with $p = p_s$ at parameter $t$, once with $p = p_t$ at parameter $s$ — and add. The terms $k(t) - k(s)$ and $k(s) - k(t)$ cancel, leaving the Jeffreys divergence on the right. $\square$

**Corollary 5.2 (Value monotonicity).** $V$ is nondecreasing on $\mathbb{R}$: colder tilts never score worse.

**Lemma 5.3 (Quantitative budget monotonicity).** For $0 \le s \le t$, $\;k(t) - k(s) \ge \mathrm{KL}(p_t\|p_s) \ge 0$.

*Proof sketch.* Apply Theorem 3.5 with $p = p_t$ at parameter $s$: $s(V(s)-V(t)) = k(s) - k(t) + \mathrm{KL}(p_t\|p_s)$. By Corollary 5.2, $V(t) \ge V(s)$, and $s \ge 0$, so the left-hand side is $\le 0$; rearranging gives the claim. $\square$

**Lemma 5.4 (Injectivity of the tilt family).** If $s \ne t$ and $p_s = p_t$, then $r$ is constant.

*Proof sketch.* Equality of the two tilts pointwise gives, after taking logarithms, $t\,r(i) - \log Z(t) = s\,r(i) - \log Z(s)$ for every $i$, hence $(t-s)r(i)$ is the same constant for all $i$; cancel $t - s \ne 0$. $\square$

**Theorem 5.5 (Strict monotonicity of the budget curve).** If $r$ is non-constant, $k$ is strictly increasing on $[0,\infty)$.

*Proof sketch.* For $0 \le s < t$, Lemma 5.4 gives $p_t \ne p_s$, hence $\mathrm{KL}(p_t\|p_s) > 0$ by the equality case of Theorem 3.2, and Lemma 5.3 turns this into $k(t) > k(s)$. $\square$

Moreover $k(0) = \mathrm{KL}(\pi_0\|\pi_0) = 0$ and $k$ is continuous on $\mathbb{R}$ (each $p_t(i)$ is a continuous, indeed real-analytic, function of $t$ with values in $(0,1]$, and $x \mapsto x\log x$ is continuous on $[0,\infty)$), so $k \ge 0$ on $[0, \infty)$.

### 5.2 The tropical sandwich and Maslov dequantization

**Theorem 5.6 (Tropical sandwich).** For all $t \ge 0$,
$$t\,M + \log w \;\le\; \log Z(t) \;\le\; t\,M.$$

*Proof sketch.* Upper: $r(i) \le M$ and $t \ge 0$ give $e^{tr(i)} \le e^{tM}$, so $Z(t) \le \sum_i \pi_0(i) e^{tM} = e^{tM}$; take logarithms. Lower: restricting the sum to $A$, on which $r \equiv M$, gives $Z(t) \ge \sum_{i\in A}\pi_0(i)e^{tM} = w\,e^{tM}$ since all omitted terms are positive; take logarithms. $\square$

**Theorem 5.7 (Maslov dequantization).** $\displaystyle \lim_{t\to\infty} \frac{\log Z(t)}{t} \;=\; M \;=\; \max_i r(i).$

*Proof sketch.* Divide Theorem 5.6 by $t > 0$: $M + \tfrac{\log w}{t} \le \tfrac{\log Z(t)}{t} \le M$, and squeeze as $t \to \infty$. $\square$

Equivalently, in temperature variables $\beta = 1/t$: $\;\beta \log Z(1/\beta) \to \max_i r(i)$ as $\beta \downarrow 0$. This is precisely the *dequantization* of the semiring $(\mathbb{R}_{>0}, +, \times)$ into the max-plus semiring $(\mathbb{R}\cup\{-\infty\}, \max, +)$: the exponential change of variables carries ordinary sums to soft-maxima, and the zero-temperature limit hardens them into maxima. The error term is not asymptotic hand-waving: Theorem 5.6 bounds it by the single constant $|\log w| = L$, uniformly in $t \ge 0$.

### 5.3 The ceiling

**Theorem 5.8 (Hard cap on the budget).** For all $t \ge 0$, $\;k(t) \le L$; and if $r$ is non-constant then $k(t) < L$ for all $t \ge 0$.

*Proof sketch.* $\mathbb{E}_{p}[r] \le M$ for every $p \in \Delta$, so by Corollary 3.4 and the lower half of Theorem 5.6,
$$k(t) = t\,V(t) - \log Z(t) \;\le\; tM - (tM + \log w) \;=\; -\log w = L.$$
Strictness: for non-constant $r$ and $t \ge 0$, either $t = 0$ (where $k(0)=0 < L$, as $L > 0$ because the argmax set is a proper subset) or $t>0$, where $V(t) < M$ because $p_t$ puts positive mass on a non-optimal outcome. $\square$

**Theorem 5.9 (The ceiling is attained in the limit).** $\displaystyle \lim_{t\to\infty} k(t) \;=\; L.$

*Proof sketch.* Write the divergence in entropy form, valid because $\pi_0 > 0$:
$$\mathrm{KL}(p\|\pi_0) = \sum_i \bigl(p(i)\log p(i) - p(i)\log \pi_0(i)\bigr).$$
For each $i$, $p_t(i) \to p_\infty(i)$ as $t \to \infty$: dividing numerator and denominator of $p_t(i)$ by $e^{tM}$ turns it into $\pi_0(i)e^{t(r(i)-M)} / \sum_j \pi_0(j)e^{t(r(j)-M)}$, in which every exponent is $\le 0$ and is $0$ exactly on $A$, so the denominator tends to $w$ and the numerator to $\pi_0(i)\mathbf{1}_{i\in A}$. Since $x \mapsto x\log x$ is continuous on $[0,\infty)$, the entropy form passes to the limit termwise, giving $k(t) \to \mathrm{KL}(p_\infty\|\pi_0)$. Finally
$$\mathrm{KL}(p_\infty\|\pi_0) = \sum_{i\in A}\frac{\pi_0(i)}{w}\log\frac{\pi_0(i)/w}{\pi_0(i)} = \log\frac1w \cdot \sum_{i\in A}\frac{\pi_0(i)}{w} = -\log w = L. \qquad \square$$

The ceiling is therefore *exact*: $k$ maps $[0,\infty)$ onto $[0, L)$, and $L$ is the least upper bound.

**Remark 5.10 (What the ceiling is, and is not).** $L$ depends on $r$ only through its argmax *set*, not through its values: replacing $r$ by $\lambda r + c$ with $\lambda > 0$ leaves $L$ unchanged. It is not the entropy of $\pi_0$ (though $L \le \log(1/\min_i \pi_0(i))$ and $L \le H(\pi_0) + \log|A|$-type comparisons can be made), and it is not a bound on the reward scale. It is the negative log-mass of the tropical support — a purely max-plus invariant. Two immediate corollaries: (i) if $\pi_0$ is uniform on $n$ outcomes with a unique maximiser, $L = \log n$; (ii) if $\pi_0$ already places mass $w$ on optimal outcomes, no reward-driven update can ever exceed a divergence of $-\log w$ from $\pi_0$ while remaining on the optimal frontier — because the zero-temperature policy itself is only $-\log w$ away.

---

## 6. Constrained = penalised

**Theorem 6.1 (Unique tilt for a prescribed budget).** Assume $r$ non-constant. For every $k$ with $0 \le k < L$ there is exactly one $t \ge 0$ with $k(t) = k$.

*Proof sketch.* Existence: by Theorem 5.9 there is $T \ge 0$ with $k(T) > k$; $k$ is continuous on $[0,T]$ with $k(0) = 0 \le k \le k(T)$, so the intermediate value theorem supplies $t \in [0,T]$ with $k(t) = k$. Uniqueness: $k$ is strictly increasing on $[0,\infty)$ by Theorem 5.5, hence injective there. $\square$

**Theorem 6.2 (Unique temperature).** Assume $r$ non-constant. For every $k$ with $0 < k < L$ there is exactly one $\beta > 0$ with $\mathrm{KL}(\pi^*_\beta\|\pi_0) = k$.

*Proof sketch.* Take the $t$ of Theorem 6.1; $t > 0$ because $k(0) = 0 \ne k$. Set $\beta = 1/t$. Conversely any admissible $\beta > 0$ yields $t' = 1/\beta \ge 0$ with $k(t') = k$, so $t' = t$ by uniqueness and $\beta = 1/t$. The map $\beta \mapsto k(1/\beta)$ is thus a decreasing bijection $(0,\infty)\to(0,L)$. $\square$

**Theorem 6.3 (Constrained = penalised).** Let $\pi_0 > 0$ be a probability vector on a finite set, let $r$ be non-constant, and let $L = -\log \pi_0(\arg\max r)$. For every budget $k$ with $0 < k < L$ there exists a **unique** $\beta > 0$ such that:

1. $\mathrm{KL}(\pi^*_\beta\|\pi_0) = k$ — the penalised solution sits exactly on the budget;
2. $\mathbb{E}_{\pi^*_\beta}[r] = \max\{\mathbb{E}_p[r] : p \in \Delta,\ \mathrm{KL}(p\|\pi_0)\le k\}$ — it solves the constrained problem, and the maximum is attained;
3. any $p \in \Delta$ with $\mathrm{KL}(p\|\pi_0) \le k$ and $\mathbb{E}_p[r] = \mathbb{E}_{\pi^*_\beta}[r]$ equals $\pi^*_\beta$ — the constrained optimum is unique.

*Proof sketch.* Theorem 6.2 gives the unique $\beta$ realising the budget. With $t = 1/\beta > 0$, item 2 is Theorem 4.1 plus the fact that $\pi^*_\beta$ is itself feasible (its divergence is exactly $k$), and item 3 is Theorem 4.2. Uniqueness of $\beta$ in the conjunction follows from uniqueness in item 1 alone. $\square$

**Example 6.4 (Two outcomes).** Take $\iota = \{0,1\}$, $\pi_0 = (\tfrac12,\tfrac12)$, $r = (0,1)$. Then $M = 1$, $A = \{1\}$, $w = \tfrac12$, so $L = \log 2 \approx 0.6931$. Explicitly $\pi^*_\beta = \bigl(\tfrac{1}{1+e^{1/\beta}}, \tfrac{e^{1/\beta}}{1+e^{1/\beta}}\bigr)$, and with $t = 1/\beta$, $\sigma = e^{t}/(1+e^{t})$,
$$k(t) = \log 2 + \sigma\log\sigma + (1-\sigma)\log(1-\sigma), \qquad V(t) = \sigma.$$
As $t$ runs over $[0,\infty)$, $\sigma$ runs over $[\tfrac12, 1)$ and $k$ increases bijectively from $0$ to $\log 2$; the achievable range is exactly $(0, \log 2)$, non-degenerate since $\log 2 > 0$. This confirms the hypotheses of Theorem 6.3 are satisfiable and the conclusion non-vacuous.

**Remark 6.5 (Failure above the ceiling).** For $k \ge L$ the constrained problem still has a supremum, namely $M$ if $k \ge L$ (approached along $p_t$, $t\to\infty$, or attained by $p_\infty$ itself when $k \ge L$), but no *tilt* realises the budget: the correspondence with temperatures breaks down, and the solution is the zero-temperature policy $p_\infty$, an object of max-plus rather than exponential type. The ceiling marks the exact phase boundary between the "exponential-family regime" and the "tropical regime".

---

## 7. The reward–divergence frontier

Consider the parametric curve $\Gamma : t \mapsto (k(t), V(t))$ for $t \in [0,\infty)$, the Pareto frontier of the trade-off. By Theorem 6.3 the second coordinate is exactly the constrained value function evaluated at the first: $V(t) = \max\{\mathbb{E}_p[r] : \mathrm{KL}(p\|\pi_0) \le k(t)\}$.

**Theorem 7.1 (Bregman identity).** For all $s, t$,
$$\mathrm{KL}(p_s\|p_t) \;=\; \log Z(t) - \log Z(s) - (t-s)\,V(s).$$

*Proof sketch.* Theorem 3.3 with $p = p_s$ gives $\mathrm{KL}(p_s\|p_t) = k(s) - t V(s) + \log Z(t)$; substitute $k(s) = sV(s) - \log Z(s)$ from Corollary 3.4. $\square$

Thus the divergence between two members of the tilted family is the Bregman divergence generated by $\log Z$ with $V$ as its slope field — the standard exponential-family fact, here derived rather than assumed.

**Corollary 7.2 (Supporting lines and convexity).** For all $s,t$: $\log Z(s) + (t-s)V(s) \le \log Z(t)$. Consequently $\log Z$ is convex on $\mathbb{R}$.

*Proof sketch.* The inequality is Theorem 7.1 plus $\mathrm{KL} \ge 0$. For convexity, let $x, y \in \mathbb{R}$, $a, b \ge 0$, $a + b = 1$, and put $m = ax + by$. Applying the supporting-line inequality at $s = m$ with $t = x$ and $t = y$, then forming the combination $a\cdot(\text{first}) + b\cdot(\text{second})$, the slope terms carry the factor $a(x - m) + b(y - m) = 0$, leaving $\log Z(m) \le a\log Z(x) + b\log Z(y)$. $\square$

This is a derivative-free, Hölder-free proof of the convexity of the cumulant generating function.

**Theorem 7.3 (Shadow-price bracket).** For $0 < s \le t$,
$$s\bigl(V(t)-V(s)\bigr) \;\le\; k(t)-k(s) \;\le\; t\bigl(V(t)-V(s)\bigr).$$
Equivalently, whenever $k(t) > k(s)$,
$$\beta_t \;=\; \frac1t \;\le\; \frac{V(t)-V(s)}{k(t)-k(s)} \;\le\; \frac1s \;=\; \beta_s.$$

*Proof sketch.* Theorem 3.5 with $p = p_s$ at $t$ gives $t(V(t)-V(s)) = k(t)-k(s)+\mathrm{KL}(p_s\|p_t) \ge k(t)-k(s)$. Theorem 3.5 with $p = p_t$ at $s$ gives $s(V(s)-V(t)) = k(s)-k(t)+\mathrm{KL}(p_t\|p_s) \ge k(s)-k(t)$, i.e. $s(V(t)-V(s)) \le k(t)-k(s)$. $\square$

So the temperature is the *shadow price* of the divergence constraint in the exact economic sense: every chord slope of the frontier between tilt parameters $s$ and $t$ lies between the two temperatures $1/t$ and $1/s$. In the limit, the marginal rate $dV/dk$ at budget $k(t)$ equals $\beta = 1/t$ — the Lagrange multiplier, recovered without ever writing a Lagrangian.

**Theorem 7.4 (Concavity of the frontier).** For $0 < s \le t \le u$,
$$\bigl(k(u)-k(t)\bigr)\bigl(V(t)-V(s)\bigr) \;\ge\; \bigl(k(t)-k(s)\bigr)\bigl(V(u)-V(t)\bigr).$$

*Proof sketch.* By Theorem 7.3, $k(t)-k(s) \le t(V(t)-V(s))$ and $k(u)-k(t) \ge t(V(u)-V(t))$. Both budget increments are nonnegative (Lemma 5.3). Cross-multiplying the two bounds through the common factor $t > 0$ yields the stated inequality. $\square$

In cross-multiplied form this says the chord slopes $\Delta V/\Delta k$ decrease as the budget grows: **diminishing returns are a theorem**, not an empirical regularity. The first nat of divergence purchases more reward than the last.

**Theorem 7.5 (Sublinear budget growth and the tropical corner).** $k(t)/t \to 0$, $V(t) \to M$, and
$$\Gamma(t) \;=\; \bigl(k(t), V(t)\bigr) \;\longrightarrow\; (L,\; M) \qquad (t \to \infty).$$

*Proof sketch.* $0 \le k(t) \le L$ by Theorem 5.8, so $k(t)/t \to 0$. From Corollary 3.4, $V(t) = k(t)/t + \log Z(t)/t$ for $t > 0$; the first term tends to $0$ and the second to $M$ by Theorem 5.7, so $V(t)\to M$. Combined with Theorem 5.9, the pair converges to $(L, M)$. $\square$

The frontier is therefore a concave arc from the origin $(0, \mathbb{E}_{\pi_0}[r])$ — where the budget is zero and the reward is the base reward — to the **tropical corner** $(L, M)$, the point at which both coordinates achieve their max-plus limits simultaneously. Every point of the arc is realised by exactly one temperature.

---

## 8. Algorithms

Three computations follow directly from the theory. Throughout, $n = |\iota|$.

**(A) Budget evaluation.** Given $t$, compute $k(t)$ and $V(t)$ in $O(n)$ time via the numerically stable form: with $m = \max_i t\,r(i)$, set $u_i = \pi_0(i)e^{tr(i)-m}$, $S=\sum u_i$, $p_t = u/S$, $V = \sum_i p_t(i) r(i)$, and $k = tV - (m + \log S)$. Subtracting $m$ prevents overflow for large $t$; the formula for $k$ is Corollary 3.4.

**(B) Temperature calibration.** Given a budget $k \in (0, L)$, find the unique $t$ with $k(t) = k$. Since $k(\cdot)$ is continuous and strictly increasing on $[0,\infty)$ (Theorem 5.5), bisection is guaranteed to converge: double an upper bracket until $k(t_{\mathrm{hi}}) > k$ — which terminates by Theorem 5.9 provided $k < L$ — then bisect. Cost $O(n\log(1/\varepsilon))$ for absolute accuracy $\varepsilon$. The temperature is then $\beta = 1/t$, which by Theorem 7.3 is simultaneously the marginal price of a nat at that budget.

**(C) Ceiling computation.** $L = -\log \sum_{i : r(i) = \max r} \pi_0(i)$, computable in $O(n)$ with a single pass (ties resolved by exact or tolerance-based comparison). This determines a priori which budgets are feasible, before any optimisation is attempted.

---

## 9. Applications and discussion

**Alignment of generative models.** The penalised objective $\mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0)$ with $\pi_0$ a base model and $r$ a learned reward is the standard fine-tuning target; practitioners nonetheless reason in terms of "the KL budget of a run". Theorem 6.3 licenses that translation exactly, and Theorem 7.3 says the tuned $\beta$ *is* the reward-per-nat exchange rate at the operating point. Remark 5.10 adds a caution the penalised view hides: the achievable budgets are bounded by $-\log \pi_0(\arg\max r)$, a quantity fixed by the base model and the argmax set alone. A run whose divergence saturates near this value is not diverging; it has reached the corner of the feasible region.

**Statistical mechanics.** With $r = -E$ (minus energy) and $\beta$ the temperature, $p_t$ is the Boltzmann distribution, $\log Z$ the (negative, scaled) free energy, Theorem 3.3 the free-energy variational principle, Corollary 7.2 the convexity of free energy in inverse temperature, and Theorem 7.5 the zero-temperature limit onto the ground-state manifold, with $L$ the residual entropy of the ground states relative to the density of states.

**Large deviations and Gibbs conditioning.** Theorem 6.3 is a finite, non-asymptotic sibling of the Gibbs conditioning principle: conditioning on a rare event of "reward at least $\cdot$" is asymptotically equivalent to tilting, and the divergence budget is the rate.

**Tropical geometry.** The $\beta \to 0$ limit is Maslov dequantization; the max-plus value $M$, the tropical support $A$, and its reference mass $w$ are the invariants that survive. Theorem 5.6 quantifies the dequantization with a uniform, non-asymptotic error of $L$ nats, and it is exactly this error that becomes the ceiling. That the *same* number governs the accuracy of the tropical approximation and the extent of the feasible region seems to us the conceptual heart of the picture.

**Robust control and risk.** $\beta \log Z(1/\beta) = \sup_p\{\mathbb{E}_p[r] - \beta\mathrm{KL}(p\|\pi_0)\}$ is the entropic risk measure; Theorem 6.3 recasts entropic risk as the value of a divergence-ball robust optimisation, and Theorem 7.5 identifies its risk-neutral-to-worst-case interpolation endpoints.

**What the calculus-free route buys.** Standard treatments differentiate $\log Z$ to obtain $\tfrac{d}{dt}\log Z = V(t)$ and $\tfrac{d}{dt} k(t) = t\,\mathrm{Var}_{p_t}(r)$, then read off monotonicity from positivity of the variance. That is efficient but brittle: it needs differentiability under the sum, and it does not generalise painlessly to infinite alphabets or to families where the tilt is only measurable. The route here replaces differentiation with two applications of one identity, so that monotonicity, optimality, convexity and concavity all reduce to nonnegativity of relative entropy — which survives in any measure-theoretic setting.

---

## 10. Limitations and future work

The results above are stated for a *finite* outcome set with a strictly positive reference. Both hypotheses are used: finiteness guarantees $\max r$ is attained and $Z(t) < \infty$ for all $t$; strict positivity guarantees finiteness of every divergence. Non-constancy of $r$ is needed only for strictness (for constant $r$ the tilt is $\pi_0$ for every $t$ and the budget curve is identically zero, with $L = 0$).

**1. Tropical ceiling rigidity for countable alphabets.** *Conjecture.* For a reference measure $\pi_0$ on a countably infinite alphabet with $\sup_i r(i) = M < \infty$, the achievable divergence range is $[0, L)$ with $L = -\log \pi_0(\arg\max r)$ **iff** the argmax set has positive $\pi_0$-mass; if $\pi_0(\arg\max r) = 0$ — in particular if the supremum is not attained — the range is all of $[0,\infty)$ and no finite ceiling exists. The key insight is that the ceiling is not an entropy bound but the negative log-mass of the tropical support: a purely max-plus quantity that degenerates exactly when the max-plus argmax cell becomes null. The finite case above uses only the sandwich $Z(t)\in[we^{tM}, e^{tM}]$ and dominated pointwise convergence of the tilt, both of which have direct measure-theoretic analogues. A natural falsifying test case: $\pi_0$ geometric with $r(i) = 1 - 2^{-i}$, where the supremum is not attained.

**2. A sharp alignment tax from the shadow-price bracket.** *Conjecture.* For every $0 < k < L$ the constrained value function $V(k) = \max\{\mathbb{E}_p[r] : \mathrm{KL}(p\|\pi_0)\le k\}$ satisfies
$$\mathbb{E}_{\pi_0}[r] + \frac{k}{t(k)} \;\le\; V(k) \;\le\; \mathbb{E}_{\pi_0}[r] + \bigl(\max r - \mathbb{E}_{\pi_0}[r]\bigr)\bigl(1 - e^{-k}\bigr),$$
where $t(k)$ is the unique tilt realising budget $k$; in particular the marginal price $dV/dk = 1/t(k)$ decreases from a $\mathrm{Var}_{\pi_0}(r)^{1/2}$-scale at $k \to 0$ to $0$ at $k \to L$. The shadow-price bracket already brackets every chord slope of the frontier, so the conjecture amounts to integrating that bracket and controlling the small- and large-$k$ endpoints.

**3. Multiple constraints and vector rewards.** Replacing the scalar budget by several divergence or moment constraints should yield a multi-temperature tilt $\propto \pi_0 \exp(\sum_j t_j r_j)$, with the ceiling becoming the negative log-mass of a *tropical polyhedral cell* rather than a single argmax set — the natural home for a genuinely tropical-geometric statement.

**4. Estimation and sampling.** In practice neither $Z$ nor $k(t)$ is computable exactly; calibrating $\beta$ from samples requires concentration bounds for $\widehat{k}(t)$. The bracket of Theorem 7.3 suggests estimating the *slope* rather than the budget, which may be better conditioned.

**5. Beyond relative entropy.** Which of these results survive for general $f$-divergences? The master decomposition is special to $\mathrm{KL}$ (it is the only $f$-divergence with the Pythagorean/exponential-family structure), so a genuinely different mechanism would be required — but the shadow-price bracket, being purely order-theoretic, may generalise.

---

## 11. Conclusion

A single identity,
$$t\bigl(\mathbb{E}_{p_t}[r] - \mathbb{E}_p[r]\bigr) = \mathrm{KL}(p_t\|\pi_0) - \mathrm{KL}(p\|\pi_0) + \mathrm{KL}(p\|p_t),$$
suffices to prove that constrained and penalised reward maximisation under a relative-entropy regulariser are the same problem, with a bijective correspondence between temperatures $\beta \in (0,\infty)$ and budgets $k \in (0,L)$; that the temperature is the marginal price of a nat; that the reward–divergence frontier is concave; and that the whole feasible region terminates at the tropical corner $(L, \max r)$, where $L = -\log \pi_0(\arg\max r)$ is the negative log-mass of the tropical support. The zero-temperature limit is Maslov dequantization with uniform error $L$, so the very constant that measures how well max-plus arithmetic approximates ordinary arithmetic also measures how far a policy can ever be driven from its origin.
