# A Variational and Torsor-Theoretic Analysis of the KL-Regularised Alignment Objective

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We give a complete exact analysis of the KL-regularised reinforcement-learning
objective used for language-model alignment, in the form

$$\mathcal{J}(p) \;=\; \mathbb{E}_{y \sim p}[R(y)] \;-\; \beta\, D_{\mathrm{KL}}\!\left(p \,\|\, \pi_{\mathrm{ref}}\right) \;+\; \gamma\, \mathbb{E}_{y \sim \mathcal{D}_{\mathrm{pre}}}[\log p(y)],$$

over a finite response alphabet, where $R$ is a reward model (human-preference
trained, symbolic-rule based, or a hybrid of the two), $\pi_{\mathrm{ref}}$ is a
full-support reference policy, $\beta>0$ is the divergence coefficient, and the
third term is a pre-training mix-in with coefficient $\gamma \ge 0$.

Everything rests on a single exact decomposition, the *three-point identity*
$\mathbb{E}_p[R] - \beta D_{\mathrm{KL}}(p\|\pi_{\mathrm{ref}}) = \beta\log Z - \beta D_{\mathrm{KL}}(p\|\pi^\star)$,
where $\pi^\star$ is the exponentially tilted policy and $\beta \log Z$ its free
energy. From it we derive: the Gibbs variational principle with uniqueness of the
maximiser; the sandwich $\mathbb{E}_{\pi_{\mathrm{ref}}}[R] \le \beta\log Z \le \max R$;
antitonicity of the optimal value in $\beta$; the drift bound
$\beta D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}}) \le \max R - \min R$; and
monotone improvement of expected reward.

We then establish structural results: exponential tilting is a transitive action
of the additive group of rewards on the open simplex whose stabiliser is exactly
the constants, so the simplex is a torsor under rewards-modulo-constants, and
sequential alignment composes additively. Bradley–Terry preference data determines
the reward exactly up to an additive constant, hence determines the aligned policy
uniquely; the implicit-reward ("direct preference") reparametrisation is an exact
inverse of tilting. Quantitatively we prove convexity and $1$-Lipschitzness of the
free energy in the reward, a $2\varepsilon$ reward-misspecification bound, two-sided
no-collapse support bounds $e^{\mp\Delta/\beta}$, an $L^1$ drift bound
$e^{\Delta/\beta}-1$ where $\Delta = \max R - \min R$, and — via a self-contained
finite-alphabet Pinsker inequality — the sharper square-root drift law
$\|\pi^\star-\pi_{\mathrm{ref}}\|_1^2 \le 2\Delta/\beta$, which dominates the
exponential bound in the practically relevant regime $\Delta > \beta$. We
characterise both temperature limits: $L^1$ convergence to $\pi_{\mathrm{ref}}$ as
$\beta\to\infty$, and convergence of the optimal value to $\max R$ with exponential
suppression of suboptimal responses as $\beta\to0^+$. We show the achievable
(divergence, reward) pairs form a monotone Pareto frontier in $\beta$.

For the multi-prompt objective we prove that optimality decomposes prompt-wise, and
that the pre-training mix-in induces an exact obstruction: the sum of the two
individual maxima is attainable if and only if $\mathcal{D}_{\mathrm{pre}} = \pi^\star$,
and this alignment tax is localised to the prompt to which the mix-in is coupled.
Finally, using strict convexity of $x\mapsto x\log x$ together with convexity of
$D_{\mathrm{KL}}$ in its second argument, we prove that the full three-term
objective has at most one maximiser among full-support policies — without any
appeal to differentiability or first-order conditions.

**Keywords:** KL-regularised reinforcement learning, Gibbs variational principle,
exponential tilting, free energy, Bradley–Terry model, Pinsker inequality,
alignment tax, torsor.

---

## 1. Introduction

### 1.1 The objective

Contemporary alignment of large generative models proceeds in three stages:
supervised fine-tuning produces a reference policy $\pi_{\mathrm{ref}}$; a reward
model $R$ is fitted to human preference comparisons (or, in a neurosymbolic
pipeline, assembled from logical constraints and verifier scores); and the policy
is then optimised against $R$ subject to a divergence penalty that prevents it
from drifting away from $\pi_{\mathrm{ref}}$. A pre-training mix-in term is
commonly added to prevent regression on general language capabilities.

The composite objective is
$$\mathcal{J}(p) \;=\; \mathbb{E}_{x \sim \mathcal{D},\, y \sim p(\cdot|x)}\big[R(x,y)\big] \;-\; \beta\, \mathbb{E}_{x}\left[\mathbb{E}_{y\sim p(\cdot|x)}\log \frac{p(y|x)}{\pi_{\mathrm{ref}}(y|x)}\right] \;+\; \gamma\, \mathbb{E}_{y \sim \mathcal{D}_{\mathrm{pre}}}\big[\log p(y)\big].$$

In practice $\mathcal{J}$ is maximised approximately, by policy-gradient methods
over a parametric family, using sampled expectations. This paper studies the
*idealised* problem: maximise $\mathcal{J}$ over all probability distributions on
a finite response set. The idealised problem is exactly solvable, and its solution
is the object that every practical method is approximating.

### 1.2 Contributions

1. A single exact identity (Theorem 3.2) from which the entire first-order theory
   follows as bookkeeping, with no calculus of variations.
2. A complete set of quantitative alignment bounds: value sandwich, divergence
   leash, two-sided support bounds, $L^1$ and square-root drift laws, both
   temperature limits, and a monotone Pareto frontier in $\beta$.
3. A structural (group-theoretic) description: tilting is a free transitive action
   modulo constants, giving additive composition of alignment stages and exact
   identifiability of the aligned policy from preference data.
4. An exact obstruction theorem for the pre-training mix-in, together with its
   localisation across prompts.
5. Uniqueness of the maximiser for the full three-term objective, proved from
   strict convexity alone.

### 1.3 Standing conventions

Throughout, $\iota$ is a finite nonempty set of responses. A *probability vector*
is $p:\iota\to\mathbb{R}$ with $p(i)\ge0$ and $\sum_i p(i)=1$; it has *full
support* if $p(i)>0$ for all $i$. We write $\Delta^\circ$ for the set of
full-support probability vectors (the open simplex). The finite Kullback–Leibler
divergence is
$$D_{\mathrm{KL}}(p\|q) \;=\; \sum_i p(i)\log\frac{p(i)}{q(i)},$$
with the convention $0\log 0 = 0$, which is automatic here since we always take
the second argument to have full support. Rewards are arbitrary real functions
$R:\iota\to\mathbb{R}$; when boundedness is needed we write $m \le R(i) \le M$ and
$\Delta = M - m$.

---

## 2. Definitions

**Definition 2.1 (Partition function and tilted policy).** For $\beta>0$, a
full-support reference $\pi_{\mathrm{ref}}$ and a reward $R$, set
$$Z_\beta(\pi_{\mathrm{ref}},R) \;=\; \sum_i \pi_{\mathrm{ref}}(i)\, e^{R(i)/\beta}, \qquad \pi^\star_\beta(i) \;=\; \frac{\pi_{\mathrm{ref}}(i)\,e^{R(i)/\beta}}{Z_\beta(\pi_{\mathrm{ref}},R)}.$$
We call $\pi^\star_\beta$ the *exponentially tilted* (Gibbs, softmax) policy and
suppress subscripts when unambiguous.

**Definition 2.2 (Free energy).** $F_\beta(\pi_{\mathrm{ref}},R) = \beta \log Z_\beta(\pi_{\mathrm{ref}},R)$.

**Definition 2.3 (Objective terms).** The reward-plus-divergence objective is
$$\mathcal{J}^{\mathrm{RL}}_\beta(p) \;=\; \sum_i p(i)R(i) \;-\; \beta\, D_{\mathrm{KL}}(p\|\pi_{\mathrm{ref}}),$$
the pre-training mix-in is
$$\mathcal{P}_\gamma(p) \;=\; \gamma\sum_i \mathcal{D}_{\mathrm{pre}}(i)\log p(i),$$
and the full objective is $\mathcal{J}_{\beta,\gamma}(p) = \mathcal{J}^{\mathrm{RL}}_\beta(p) + \mathcal{P}_\gamma(p)$.

**Definition 2.4 (Bradley–Terry preferences).** For a reward $R$, the induced
preference probability of $i$ over $j$ is
$$\Pr[i \succ j] \;=\; \frac{1}{1 + e^{R(j)-R(i)}}.$$

**Definition 2.5 (Implicit reward).** For $q \in \Delta^\circ$ and $\beta > 0$,
$$R_q(i) \;=\; \beta \log \frac{q(i)}{\pi_{\mathrm{ref}}(i)}.$$

**Definition 2.6 (Multi-prompt objective).** For a finite prompt set $\chi$ with
weights $D(x) > 0$, per-prompt references $\pi_{\mathrm{ref}}(\cdot|x)$, rewards
$R(\cdot|x)$ and conditional policies $p(\cdot|x)$,
$$\mathcal{J}^{\mathrm{multi}}_\beta(p) \;=\; \sum_{x} D(x)\, \mathcal{J}^{\mathrm{RL}}_\beta\big(p(\cdot|x)\big), \qquad F^{\mathrm{multi}}_\beta \;=\; \sum_x D(x)\, F_\beta\big(\pi_{\mathrm{ref}}(\cdot|x), R(\cdot|x)\big),$$
and, for a distinguished prompt $x_0$,
$$\mathcal{J}^{\mathrm{full}}_{\beta,\gamma}(p) \;=\; \mathcal{J}^{\mathrm{multi}}_\beta(p) + \mathcal{P}_\gamma\big(p(\cdot|x_0)\big).$$

---

## 3. The variational principle

### 3.1 Gibbs' inequality

**Lemma 3.1 (Pointwise bound).** For $a \ge 0$ and $b > 0$,
$a - b \le a\log(a/b)$, with equality iff $a = b$.

*Proof sketch.* For $a = 0$ the claim is $-b \le 0$, strict since $b>0$. For
$a>0$ put $t = a/b$; the claim is $b(t - 1) \le b\,t\log t$, i.e.
$t-1 \le t \log t$, equivalently $\log(1/t) \le 1/t - 1$, which is the standard
bound $\log u \le u - 1$ with $u = 1/t$, strict unless $u = 1$. $\square$

**Theorem 3.1 (Gibbs' inequality and its equality case).** If $p$ is a
probability vector and $q$ has full support, then $D_{\mathrm{KL}}(p\|q) \ge 0$,
and $D_{\mathrm{KL}}(p\|q) = 0$ if and only if $p = q$.

*Proof sketch.* Summing Lemma 3.1 termwise gives
$0 = \sum_i p(i) - \sum_i q(i) \le \sum_i p(i)\log(p(i)/q(i))$. For the equality
case, if $p(j) \ne q(j)$ for some $j$ then the $j$-th summand is *strictly* above
$p(j)-q(j)$ while all others are weakly above, so the total is strictly positive.
$\square$

### 3.2 The three-point identity

**Lemma 3.2 (Change of reference).** For $p$ a probability vector,
$\pi_{\mathrm{ref}}$ full support and $\beta>0$,
$$D_{\mathrm{KL}}(p\|\pi^\star) \;=\; D_{\mathrm{KL}}(p\|\pi_{\mathrm{ref}}) \;-\; \frac{1}{\beta}\sum_i p(i)R(i) \;+\; \log Z.$$

*Proof sketch.* Write $\log\frac{p(i)}{\pi^\star(i)} = \log\frac{p(i)}{\pi_{\mathrm{ref}}(i)} - \frac{R(i)}{\beta} + \log Z$ pointwise (valid since $\pi_{\mathrm{ref}}(i), Z > 0$; the summand vanishes where $p(i)=0$), multiply by $p(i)$ and sum, using $\sum_i p(i) = 1$. $\square$

**Theorem 3.2 (Three-point identity).** For $\beta > 0$, full-support
$\pi_{\mathrm{ref}}$, and any probability vector $p$,
$$\mathcal{J}^{\mathrm{RL}}_\beta(p) \;=\; F_\beta(\pi_{\mathrm{ref}},R) \;-\; \beta\, D_{\mathrm{KL}}\big(p\,\|\,\pi^\star\big).$$

*Proof.* Multiply Lemma 3.2 by $-\beta$ and rearrange; the $\log Z$ term becomes
$-\beta\log Z$ on one side and produces $F_\beta$ on the other. $\square$

This identity is the entire content of the first-order theory. Every statement in
§3.3 and §4 is obtained by choosing a particular $p$ and applying Theorem 3.1.

### 3.3 Optimality

**Theorem 3.3 (Gibbs variational principle with uniqueness).** Let $\beta>0$ and
$\pi_{\mathrm{ref}}$ have full support. Then for every probability vector $p$,
$$\mathcal{J}^{\mathrm{RL}}_\beta(p) \;\le\; F_\beta(\pi_{\mathrm{ref}},R),$$
with equality if and only if $p = \pi^\star$. In particular the maximiser exists
and is unique, the optimal value is the free energy $\beta \log Z$, and
$\pi^\star$ is a full-support probability vector.

*Proof.* Immediate from Theorem 3.2 and Theorem 3.1: the correction term
$\beta D_{\mathrm{KL}}(p\|\pi^\star)$ is nonnegative and vanishes exactly at
$p = \pi^\star$. That $\pi^\star$ is a full-support probability vector is a direct
computation: $Z>0$ because each summand is positive, and the normalisation is by
construction. $\square$

The interpretation is thermodynamic: $-R$ is an energy, $\beta$ a temperature,
$\pi^\star$ a Boltzmann distribution relative to the base measure
$\pi_{\mathrm{ref}}$, and the optimal value a free energy.

---

## 4. Quantitative alignment bounds

Throughout this section $\beta > 0$, $\pi_{\mathrm{ref}}$ has full support and,
where indicated, $m \le R \le M$ with $\Delta = M - m$.

**Theorem 4.1 (Value sandwich).** $\displaystyle \mathbb{E}_{\pi_{\mathrm{ref}}}[R] \le F_\beta \le M$, and hence $m \le F_\beta \le M$.

*Proof sketch.* Lower bound: evaluate Theorem 3.3 at $p = \pi_{\mathrm{ref}}$, for
which the divergence term vanishes. Upper bound: at $p = \pi^\star$ the objective
equals $F_\beta$, so $F_\beta = \mathbb{E}_{\pi^\star}[R] - \beta D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}}) \le \mathbb{E}_{\pi^\star}[R] \le M$. $\square$

**Theorem 4.2 (Antitonicity in $\beta$).** If $0 < \beta_1 \le \beta_2$ then
$F_{\beta_2} \le F_{\beta_1}$.

*Proof sketch.* $F_{\beta_2} = \mathbb{E}_{\pi^\star_{\beta_2}}[R] - \beta_2 D_{\mathrm{KL}}(\pi^\star_{\beta_2}\|\pi_{\mathrm{ref}}) \le \mathbb{E}_{\pi^\star_{\beta_2}}[R] - \beta_1 D_{\mathrm{KL}}(\pi^\star_{\beta_2}\|\pi_{\mathrm{ref}}) \le F_{\beta_1}$, the last step by Theorem 3.3 at temperature $\beta_1$. $\square$

**Theorem 4.3 (Divergence leash).** $\beta\, D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}}) \le M - m$.

*Proof.* $F_\beta = \mathbb{E}_{\pi^\star}[R] - \beta D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}}) \le M - \beta D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}})$, while $F_\beta \ge m$ by Theorem 4.1. $\square$

**Theorem 4.4 (Reward improvement).** $\mathbb{E}_{\pi_{\mathrm{ref}}}[R] \le \mathbb{E}_{\pi^\star}[R]$.

*Proof.* $\mathbb{E}_{\pi^\star}[R] = F_\beta + \beta D_{\mathrm{KL}}(\pi^\star\|\pi_{\mathrm{ref}}) \ge F_\beta \ge \mathbb{E}_{\pi_{\mathrm{ref}}}[R]$. $\square$

**Theorem 4.5 (Two-sided support bounds).** For every $i$,
$$\pi_{\mathrm{ref}}(i)\, e^{-\Delta/\beta} \;\le\; \pi^\star(i) \;\le\; \pi_{\mathrm{ref}}(i)\, e^{\Delta/\beta}.$$

*Proof sketch.* $e^{m/\beta} \le Z \le e^{M/\beta}$, since each $e^{R(i)/\beta}$ is
between $e^{m/\beta}$ and $e^{M/\beta}$ and $\pi_{\mathrm{ref}}$ sums to one. Insert
these into $\pi^\star(i) = \pi_{\mathrm{ref}}(i)e^{R(i)/\beta}/Z$ together with
$e^{m/\beta} \le e^{R(i)/\beta} \le e^{M/\beta}$. $\square$

Thus alignment can neither annihilate a response nor create one: probabilities are
multiplied by a factor in $[e^{-\Delta/\beta}, e^{\Delta/\beta}]$.

**Corollary 4.6 ($L^1$ drift).** $\displaystyle \sum_i \big|\pi^\star(i) - \pi_{\mathrm{ref}}(i)\big| \le e^{\Delta/\beta} - 1$.

*Proof sketch.* Theorem 4.5 gives $|\pi^\star(i)-\pi_{\mathrm{ref}}(i)| \le \pi_{\mathrm{ref}}(i)\max\{e^{\Delta/\beta}-1,\,1-e^{-\Delta/\beta}\}$, and
$1 - e^{-u} \le e^{u}-1$ for $u \ge 0$. Sum over $i$. $\square$

**Corollary 4.7 (Strong-regularisation limit).** $\displaystyle \lim_{\beta\to\infty}\sum_i|\pi^\star_\beta(i)-\pi_{\mathrm{ref}}(i)| = 0$.

*Proof.* $\Delta/\beta \to 0$, so $e^{\Delta/\beta}-1 \to 0$; apply Corollary 4.6 and
nonnegativity. $\square$

### 4.1 A sharper, square-root drift law

Corollary 4.6 is an $L^\infty$-flavoured estimate and is vacuous when
$\Delta \gg \beta$, since $\sum_i|\pi^\star(i)-\pi_{\mathrm{ref}}(i)|$ never exceeds
$2$. The correct geometry of a divergence ball is Euclidean, and is captured by
Pinsker's inequality, which we prove from scratch in the finite setting.

**Lemma 4.8 (Sharp scalar estimate).** For $x \ge 0$,
$$x\log x - x + 1 \;\ge\; \frac{3(x-1)^2}{2(x+2)}.$$

*Proof sketch.* Let $H(x) = x\log x - \tfrac{5}{2}x + 7 - \tfrac{27}{2}(x+2)^{-1}$,
an algebraically rearranged form of the difference of the two sides. Then $H(1)=0$
and $H'(x) = \log x + 1 - \tfrac52 + \tfrac{27}{2}(x+2)^{-2}$ satisfies $H'(1)=0$
and $H''(x) = 1/x - 27/(x+2)^3 \ge 0$ for $x>0$; the last inequality is
$(x+2)^3 \ge 27x$, which is AM–GM applied to $x, 2, \dots$ (equivalently, expand:
$(x+2)^3 - 27x = (x-1)^2(x+8) \ge 0$). Hence $H'$ is monotone with a zero at $1$,
so $H$ decreases on $(0,1]$ and increases on $[1,\infty)$, giving $H \ge H(1) = 0$.
The case $x = 0$ is checked directly: $1 \ge 3/4$. $\square$

**Lemma 4.9 (Homogeneous form).** For $a \ge 0$, $b > 0$,
$$a\log\frac{a}{b} - a + b \;\ge\; \frac{3(a-b)^2}{2(a+2b)}.$$

*Proof.* Apply Lemma 4.8 with $x = a/b$ and multiply by $b$. $\square$

**Theorem 4.10 (Pinsker's inequality, finite alphabet).** For a probability vector
$p$ and a full-support probability vector $q$,
$$\Big(\sum_i |p(i)-q(i)|\Big)^2 \;\le\; 2\, D_{\mathrm{KL}}(p\|q).$$

*Proof sketch.* Put $w(i) = p(i) + 2q(i) > 0$. By Lemma 4.9 and
$\sum_i(p(i)-q(i))=0$,
$$D_{\mathrm{KL}}(p\|q) \;\ge\; \sum_i \frac{3(p(i)-q(i))^2}{2\,w(i)}.$$
By Cauchy–Schwarz,
$$\Big(\sum_i |p(i)-q(i)|\Big)^2 \;=\; \Big(\sum_i \frac{|p(i)-q(i)|}{\sqrt{w(i)}}\cdot\sqrt{w(i)}\Big)^2 \;\le\; \Big(\sum_i \frac{(p(i)-q(i))^2}{w(i)}\Big)\Big(\sum_i w(i)\Big),$$
and $\sum_i w(i) = 3$. Combining, $\big(\sum_i|p-q|\big)^2 \le 3 \cdot \tfrac{2}{3}D_{\mathrm{KL}}(p\|q) = 2D_{\mathrm{KL}}(p\|q)$. $\square$

**Theorem 4.11 (Square-root drift law).** $\displaystyle \Big(\sum_i|\pi^\star(i)-\pi_{\mathrm{ref}}(i)|\Big)^2 \le \frac{2(M-m)}{\beta}$.

*Proof.* Theorem 4.10 with $p = \pi^\star$, $q = \pi_{\mathrm{ref}}$, then Theorem 4.3. $\square$

Thus total drift scales as $\sqrt{\Delta/\beta}$. When $\Delta > \beta$ this is
strictly stronger than Corollary 4.6, and it is the regime in which practical
alignment operates: reward ranges are large compared to the divergence
coefficient. Halving $\beta$ therefore buys only a factor $\sqrt2$ in drift budget.

### 4.2 The low-temperature limit

**Theorem 4.12 (Value converges to the maximum).** $\displaystyle \lim_{\beta\to0^+} F_\beta = \max_i R(i)$.

*Proof sketch.* Fix a maximiser $i_0$. Retaining only the $i_0$ term in $Z$ gives
$Z \ge \pi_{\mathrm{ref}}(i_0)e^{R(i_0)/\beta}$, hence
$F_\beta \ge R(i_0) + \beta\log\pi_{\mathrm{ref}}(i_0)$. Together with
$F_\beta \le \max R$ (Theorem 4.1) and $\beta\log\pi_{\mathrm{ref}}(i_0) \to 0$, the
squeeze applies. $\square$

**Theorem 4.13 (Exponential suppression and concentration).** For any $i_0$ and $i$,
$$\pi^\star_\beta(i) \;\le\; \frac{\pi_{\mathrm{ref}}(i)}{\pi_{\mathrm{ref}}(i_0)}\, e^{-(R(i_0)-R(i))/\beta}.$$
Consequently, if $R(i) < R(i_0)$ then $\pi^\star_\beta(i) \to 0$ as $\beta \to 0^+$.

*Proof sketch.* Bound $Z$ below by its $i_0$ term and simplify. The limit follows
because the exponent $-(R(i_0)-R(i))/\beta \to -\infty$. $\square$

So at vanishing regularisation the aligned policy concentrates on the arg-max of
the reward model: mode collapse and reward hacking are the $\beta \to 0^+$
boundary behaviour of the exact solution, not an artefact of the optimiser.

### 4.3 The Pareto frontier

**Theorem 4.14 (Monotone alignment frontier).** If $0 < \beta_1 < \beta_2$, then
$$D_{\mathrm{KL}}\big(\pi^\star_{\beta_2}\|\pi_{\mathrm{ref}}\big) \le D_{\mathrm{KL}}\big(\pi^\star_{\beta_1}\|\pi_{\mathrm{ref}}\big) \quad\text{and}\quad \mathbb{E}_{\pi^\star_{\beta_2}}[R] \le \mathbb{E}_{\pi^\star_{\beta_1}}[R].$$

*Proof sketch.* Write $A_k = \mathbb{E}_{\pi^\star_{\beta_k}}[R]$ and
$K_k = D_{\mathrm{KL}}(\pi^\star_{\beta_k}\|\pi_{\mathrm{ref}})$. Optimality of
$\pi^\star_{\beta_1}$ at temperature $\beta_1$, evaluated against
$\pi^\star_{\beta_2}$, gives $A_2 - \beta_1 K_2 \le A_1 - \beta_1 K_1$; symmetrically
$A_1 - \beta_2 K_1 \le A_2 - \beta_2 K_2$. Adding the two yields
$(\beta_2-\beta_1)(K_2 - K_1) \le 0$, so $K_2 \le K_1$. Substituting back into the
first inequality gives $A_2 \le A_1 + \beta_1(K_2-K_1) \le A_1$. $\square$

This is the exchange rate the coefficient $\beta$ actually controls: reward is
bought with divergence, monotonically, and the frontier is traced out as $\beta$
sweeps $(0,\infty)$ between the two limits of §4.2 and Corollary 4.7.

---

## 5. Structural theory: tilting as a group action

**Theorem 5.1 (Additivity).** For $\beta>0$ and full-support $\pi_{\mathrm{ref}}$,
$$\pi^\star_\beta\big(\pi^\star_\beta(\pi_{\mathrm{ref}},R),\,S\big) \;=\; \pi^\star_\beta\big(\pi_{\mathrm{ref}},\,R+S\big),$$
and $\pi^\star_\beta(\pi_{\mathrm{ref}},0) = \pi_{\mathrm{ref}}$.

*Proof sketch.* Tilting $\pi_{\mathrm{ref}}$ by $R$ then by $S$ multiplies each
coordinate by $e^{R(i)/\beta}e^{S(i)/\beta} = e^{(R+S)(i)/\beta}$ and renormalises;
the two normalising constants combine into the single constant for $R+S$, since
the intermediate partition function is a positive scalar that cancels. $\square$

Hence $(R, \pi) \mapsto \pi^\star_\beta(\pi, R)$ is an action of the additive group
$(\mathbb{R}^\iota, +)$ on $\Delta^\circ$.

**Theorem 5.2 (Transitivity).** For $p, q \in \Delta^\circ$ there is a reward $R$
with $\pi^\star_\beta(p,R) = q$; explicitly $R(i) = \beta\log(q(i)/p(i))$ works.

*Proof sketch.* With this $R$, $p(i)e^{R(i)/\beta} = q(i)$ and $Z = \sum_i q(i) = 1$. $\square$

**Theorem 5.3 (Stabiliser).** $\pi^\star_\beta(\pi_{\mathrm{ref}},R) = \pi^\star_\beta(\pi_{\mathrm{ref}},S)$
if and only if $R - S$ is constant. In particular
$\pi^\star_\beta(\pi_{\mathrm{ref}},R+c) = \pi^\star_\beta(\pi_{\mathrm{ref}},R)$ for
constants $c$, while $F_\beta(\pi_{\mathrm{ref}},R+c) = F_\beta(\pi_{\mathrm{ref}},R) + c$.

*Proof sketch.* If $R = S + c$ then numerator and partition function both scale by
$e^{c/\beta}$ and the ratio is unchanged. Conversely, equality of the tilted
policies at every $i$ gives $e^{(R(i)-S(i))/\beta} = Z_R/Z_S$, a constant
independent of $i$; taking logs, $R - S$ is the constant $\beta\log(Z_R/Z_S)$. $\square$

**Corollary 5.4 (Torsor structure).** The open simplex $\Delta^\circ$ is a torsor
under the quotient group $\mathbb{R}^\iota/\mathbb{R}\mathbf{1}$: the action is free
and transitive after quotienting by constant rewards.

**Corollary 5.5 (Sequential alignment composes).** Running a second alignment stage
with reward $S$ against the first-stage optimum yields exactly the single-stage
optimum for reward $R + S$: a policy $p$ maximises
$\mathbb{E}_p[S] - \beta D_{\mathrm{KL}}(p\|\pi^\star_\beta(\pi_{\mathrm{ref}},R))$
if and only if $p = \pi^\star_\beta(\pi_{\mathrm{ref}}, R+S)$.

*Proof.* Theorem 3.3 applied with reference $\pi^\star_\beta(\pi_{\mathrm{ref}},R)$,
combined with Theorem 5.1. $\square$

Iterated alignment therefore explores no more of policy space than a single stage
with a well-chosen reward — and it is *path-independent*: the order of stages does
not matter, because addition of rewards is commutative.

---

## 6. Preference data, identifiability, and the implicit reward

**Theorem 6.1 (Bradley–Terry identifiability).** Two rewards $R, S$ induce the same
Bradley–Terry preference probabilities for all pairs if and only if $R - S$ is
constant.

*Proof sketch.* $\Pr_R[i \succ j] = \Pr_S[i \succ j]$ for all $i,j$ iff
$R(j)-R(i) = S(j)-S(i)$ for all $i,j$ (the logistic function is injective), iff
$R - S$ takes the same value at every pair of points, i.e. is constant. $\square$

**Corollary 6.2 (Well-posedness of alignment on preference data).** If $R$ and $S$
induce identical preferences then $\pi^\star_\beta(\pi_{\mathrm{ref}},R) = \pi^\star_\beta(\pi_{\mathrm{ref}},S)$;
conversely, if they induce the same aligned policy they induce the same
preferences.

*Proof.* Combine Theorem 6.1 with Theorem 5.3: both conditions are equivalent to
"$R-S$ is constant". $\square$

The non-identifiability of a reward model from comparison data is thus exactly the
gauge freedom to which the aligned policy is blind. Nothing observable is lost.

**Theorem 6.3 (Implicit-reward reparametrisation).** For $q \in \Delta^\circ$, the
implicit reward $R_q(i) = \beta\log(q(i)/\pi_{\mathrm{ref}}(i))$ satisfies
$\pi^\star_\beta(\pi_{\mathrm{ref}}, R_q) = q$. Conversely, for any reward $R$ the
implicit reward of $\pi^\star_\beta(\pi_{\mathrm{ref}},R)$ equals $R - F_\beta(\pi_{\mathrm{ref}},R)$,
i.e. $R$ up to an additive constant.

*Proof sketch.* The first claim is Theorem 5.2. For the second,
$\beta\log(\pi^\star(i)/\pi_{\mathrm{ref}}(i)) = \beta\log(e^{R(i)/\beta}/Z) = R(i) - \beta\log Z$. $\square$

This is the exact statement underlying direct preference optimisation: policies and
rewards are two coordinate systems on the same object, related by a bijection
modulo constants, so one may fit a policy directly to preference data instead of
fitting a reward and then optimising it.

---

## 7. Robustness of the optimal value in the reward

**Theorem 7.1 (Monotonicity).** If $R(i) \le S(i)$ for all $i$ then $F_\beta(\pi_{\mathrm{ref}},R) \le F_\beta(\pi_{\mathrm{ref}},S)$.

**Theorem 7.2 (Convexity).** For $\lambda \in [0,1]$,
$$F_\beta\big(\pi_{\mathrm{ref}},\, \lambda R + (1-\lambda)S\big) \;\le\; \lambda F_\beta(\pi_{\mathrm{ref}},R) + (1-\lambda)F_\beta(\pi_{\mathrm{ref}},S).$$

*Proof sketch.* By Theorem 3.3, $F_\beta(\cdot)$ is the pointwise supremum over
$p$ of the affine-in-$R$ functionals $p \mapsto \mathbb{E}_p[R] - \beta D_{\mathrm{KL}}(p\|\pi_{\mathrm{ref}})$;
a supremum of affine functions is convex. Concretely, let $T = \lambda R + (1-\lambda)S$
and $p = \pi^\star_\beta(\pi_{\mathrm{ref}},T)$; then
$F_\beta(T) = \mathbb{E}_p[T] - \beta D_{\mathrm{KL}}(p\|\pi_{\mathrm{ref}})$ splits
linearly into $\lambda(\mathbb{E}_p[R] - \beta D_{\mathrm{KL}}) + (1-\lambda)(\mathbb{E}_p[S] - \beta D_{\mathrm{KL}})$,
and each bracket is at most the corresponding free energy. $\square$

**Theorem 7.3 (Lipschitz continuity).** If $|R(i)-S(i)| \le \varepsilon$ for all $i$
then $|F_\beta(\pi_{\mathrm{ref}},R) - F_\beta(\pi_{\mathrm{ref}},S)| \le \varepsilon$.

*Proof sketch.* $R \le S + \varepsilon$ pointwise, so by Theorem 7.1 and the shift
rule of Theorem 5.3, $F_\beta(R) \le F_\beta(S) + \varepsilon$; symmetrise. $\square$

**Theorem 7.4 (Reward misspecification / hacking bound).** If
$|R(i) - \hat R(i)| \le \varepsilon$ for all $i$, then the policy obtained by
optimising $\hat R$ loses at most $2\varepsilon$ of true objective value:
$$\mathcal{J}^{\mathrm{RL}}_\beta\big(\pi^\star_\beta(\pi_{\mathrm{ref}},\hat R)\big) \;\ge\; F_\beta(\pi_{\mathrm{ref}},R) - 2\varepsilon.$$

*Proof sketch.* Let $\hat\pi = \pi^\star_\beta(\pi_{\mathrm{ref}},\hat R)$. Then
$\mathcal{J}^{\mathrm{RL}}_\beta(\hat\pi)$, evaluated with the *true* reward,
differs from its value with $\hat R$ — which equals $F_\beta(\hat R)$ exactly — by
at most $\varepsilon$, since $|\mathbb{E}_{\hat\pi}[R] - \mathbb{E}_{\hat\pi}[\hat R]| \le \varepsilon$.
By Theorem 7.3, $F_\beta(\hat R) \ge F_\beta(R) - \varepsilon$. Adding the two
losses gives $2\varepsilon$. $\square$

The two $\varepsilon$'s are of different natures: one is the error in the *value*
of the optimum, the other the error in *evaluating* the wrong optimiser. Both are
first order; there is no amplification.

---

## 8. Multiple prompts and the pre-training mix-in

### 8.1 Prompt-wise decomposition

**Theorem 8.1 (Prompt-wise optimality).** Let $D(x) > 0$ for every prompt $x$,
let each $\pi_{\mathrm{ref}}(\cdot|x)$ have full support and each $p(\cdot|x)$ be a
probability vector. Then
$$\mathcal{J}^{\mathrm{multi}}_\beta(p) \le F^{\mathrm{multi}}_\beta,$$
with equality if and only if $p(\cdot|x) = \pi^\star_\beta\big(\pi_{\mathrm{ref}}(\cdot|x),R(\cdot|x)\big)$ for every $x$.

*Proof sketch.* The objective is a $D$-weighted sum of per-prompt objectives, each
bounded by its own free energy (Theorem 3.3). A weighted sum of terms, each below
its bound, equals the sum of bounds iff every term attains its bound; the weights
being strictly positive lets one cancel them. Each per-prompt equality is
equivalent to tiltedness by Theorem 3.3. $\square$

Alignment therefore decouples completely across prompts: it is a family of
independent one-prompt problems.

### 8.2 The mix-in and the alignment tax

**Lemma 8.2 (The mix-in is maximised at the pre-training distribution).** For
$\gamma \ge 0$, full-support $\mathcal{D}_{\mathrm{pre}}$ and full-support $p$,
$$\mathcal{P}_\gamma(p) \le \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}}), \qquad \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}}) - \mathcal{P}_\gamma(p) = \gamma\, D_{\mathrm{KL}}\big(\mathcal{D}_{\mathrm{pre}}\,\|\,p\big).$$

*Proof.* The displayed identity is the definition of the divergence expanded; the
inequality then follows from Theorem 3.1. $\square$

**Theorem 8.3 (Master decomposition of the full objective).** For $\beta>0$, $\gamma\ge0$ and full-support $p$,
$$\mathcal{J}_{\beta,\gamma}(p) \;=\; \Big[F_\beta(\pi_{\mathrm{ref}},R) + \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}})\Big] \;-\; \beta\, D_{\mathrm{KL}}(p\|\pi^\star) \;-\; \gamma\, D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|p).$$

*Proof.* Add Theorem 3.2 and Lemma 8.2. $\square$

The two penalty terms are divergences *in opposite arguments*: the first wants $p$
to be $\pi^\star$, the second wants $p$ to cover $\mathcal{D}_{\mathrm{pre}}$. They
can be simultaneously zero only if the two targets coincide.

**Theorem 8.4 (Alignment tension: exact obstruction).** Let $\beta,\gamma > 0$ and
let $\pi_{\mathrm{ref}}, \mathcal{D}_{\mathrm{pre}}$ have full support. There
exists a full-support $p$ with
$$\mathcal{J}_{\beta,\gamma}(p) \;=\; F_\beta(\pi_{\mathrm{ref}},R) + \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}})$$
if and only if $\mathcal{D}_{\mathrm{pre}} = \pi^\star$. Moreover, when
$\mathcal{D}_{\mathrm{pre}} \ne \pi^\star$, *every* full-support $p$ satisfies the
strict inequality $\mathcal{J}_{\beta,\gamma}(p) < F_\beta + \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}})$.

*Proof sketch.* By Theorem 8.3, attaining the sum of the individual maxima forces
both divergence terms to vanish, hence $p = \pi^\star$ and
$\mathcal{D}_{\mathrm{pre}} = p$ by the equality case of Theorem 3.1. Conversely if
$\mathcal{D}_{\mathrm{pre}} = \pi^\star$, take $p = \pi^\star$. The strict form is the
contrapositive together with the non-strict bound. $\square$

This is the precise sense in which the anti-forgetting term costs alignment
quality: the *alignment tax* $\beta D_{\mathrm{KL}}(p\|\pi^\star) + \gamma D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|p)$
is strictly positive for every policy unless the pre-training distribution is
already the aligned optimum.

**Theorem 8.5 (Localisation of the tax).** Consider the full multi-prompt objective
$\mathcal{J}^{\mathrm{full}}_{\beta,\gamma}$ with the mix-in coupled to the single
prompt $x_0$, with $\beta,\gamma>0$, $D(x)>0$ for all $x$, and all policies of full
support. Then
$$\mathcal{J}^{\mathrm{full}}_{\beta,\gamma}(p) \;\le\; F^{\mathrm{multi}}_\beta + \mathcal{P}_\gamma(\mathcal{D}_{\mathrm{pre}}),$$
with equality if and only if (i) $p(\cdot|x)$ is the tilted policy for every prompt
$x$, and (ii) $\mathcal{D}_{\mathrm{pre}} = p(\cdot|x_0)$.

*Proof sketch.* The bound is the sum of Theorem 8.1 and Lemma 8.2. Equality of a
sum of two quantities each below its bound forces both to be tight; tightness of
the first is condition (i) by Theorem 8.1, and tightness of the second is
$\gamma D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|p(\cdot|x_0)) = 0$, i.e.
condition (ii) by the equality case of Theorem 3.1 and $\gamma>0$. $\square$

The content is the conjunction's shape: condition (i) is imposed at *every* prompt
and involves only the reward and reference, while condition (ii) constrains only
the conditional at $x_0$. The pre-training mix-in therefore does not perturb the
optimal conditional policy at any other prompt. The tax is localised where the
mix-in touches.

### 8.3 Uniqueness of the full optimum

The three-point identity does not apply to $\mathcal{J}_{\beta,\gamma}$ as a whole,
because $\mathcal{P}_\gamma$ is not a divergence in the first argument. Uniqueness
nevertheless survives, by convexity.

**Lemma 8.6 (Strict convexity in the first argument).** If $p \ne q$ are
probability vectors and $c$ has full support, then
$$D_{\mathrm{KL}}\!\left(\tfrac{p+q}{2}\,\Big\|\,c\right) \;<\; \tfrac12 D_{\mathrm{KL}}(p\|c) + \tfrac12 D_{\mathrm{KL}}(q\|c).$$

*Proof sketch.* Write each summand as $a\log a - a\log c(i)$ using
$a\log(a/c) = a\log a - a\log c$ (valid also at $a = 0$). The $-a\log c(i)$ part is
affine in $a$ and contributes equally to both sides. The remaining part is
$x\mapsto x\log x$, which is *strictly* convex on $[0,\infty)$; hence every summand
satisfies midpoint convexity, and at any index $j$ with $p(j)\ne q(j)$ the
inequality is strict. Summing a family of weak inequalities containing one strict
inequality gives a strict total. $\square$

**Lemma 8.7 (Convexity in the second argument).** For a probability vector $a$ and
full-support $p,q$,
$$D_{\mathrm{KL}}\!\left(a\,\Big\|\,\tfrac{p+q}{2}\right) \;\le\; \tfrac12 D_{\mathrm{KL}}(a\|p) + \tfrac12 D_{\mathrm{KL}}(a\|q).$$

*Proof sketch.* Termwise, this reduces to $-\log\frac{p+q}{2} \le -\frac12\log p - \frac12\log q$,
i.e. to concavity of the logarithm (equivalently AM–GM,
$\frac{p+q}{2} \ge \sqrt{pq}$), multiplied by $a(i) \ge 0$. $\square$

**Theorem 8.8 (Uniqueness of the full optimum).** Let $\beta>0$, $\gamma\ge0$, and
let $\pi_{\mathrm{ref}}, \mathcal{D}_{\mathrm{pre}}$ have full support. If $p$ and
$q$ are full-support policies that both maximise $\mathcal{J}_{\beta,\gamma}$ over
full-support policies, then $p = q$.

*Proof sketch.* Suppose $p \ne q$. Both being maximisers, $\mathcal{J}(p) = \mathcal{J}(q)$.
Let $m = (p+q)/2$, again of full support. By Theorem 8.3,
$$\mathcal{J}(m) = C - \beta D_{\mathrm{KL}}(m\|\pi^\star) - \gamma D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|m).$$
Lemma 8.6 (with $c = \pi^\star$) gives $D_{\mathrm{KL}}(m\|\pi^\star) < \frac12(D_{\mathrm{KL}}(p\|\pi^\star)+D_{\mathrm{KL}}(q\|\pi^\star))$
strictly, and Lemma 8.7 gives $D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|m) \le \frac12(D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|p)+D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|q))$
weakly. Since $\beta > 0$ and $\gamma \ge 0$, we conclude
$\mathcal{J}(m) > \frac12(\mathcal{J}(p)+\mathcal{J}(q)) = \mathcal{J}(p)$,
contradicting maximality of $p$. $\square$

Note the economy: strictness comes from the divergence term alone, so the result
covers the pure case $\gamma = 0$ as well, and no differentiability of any
parametrisation is used.

---

## 9. Algorithms

The theory is constructive. Three procedures follow immediately.

**Algorithm A (Exact aligned policy).** Given $\pi_{\mathrm{ref}}, R, \beta$, compute
$u(i) = \log\pi_{\mathrm{ref}}(i) + R(i)/\beta$, then $\pi^\star = \mathrm{softmax}(u)$
and $F_\beta = \beta\,\mathrm{logsumexp}(u)$. Using the log-sum-exp trick this is
numerically stable for all $\beta > 0$ and costs $O(|\iota|)$ time and space. The
stability matters: at small $\beta$ the raw exponentials overflow, while the shifted
form $\mathrm{logsumexp}(u) = u_{\max} + \log\sum_i e^{u_i - u_{\max}}$ never does.

**Algorithm B (Frontier tracing).** Sweep $\beta$ over a logarithmic grid, apply
Algorithm A at each node, and record the pair
$\big(D_{\mathrm{KL}}(\pi^\star_\beta\|\pi_{\mathrm{ref}}),\, \mathbb{E}_{\pi^\star_\beta}[R]\big)$.
By Theorem 4.14 the resulting point set is monotone in both coordinates, and by
§4.2 it interpolates between $(0, \mathbb{E}_{\pi_{\mathrm{ref}}}[R])$ and
$\big(\log(1/\pi_{\mathrm{ref}}(i_{\max})), \max R\big)$. Cost: $O(N|\iota|)$ for $N$ grid points.

**Algorithm C (Divergence-budgeted alignment).** To realise a prescribed divergence
budget $k$, solve $D_{\mathrm{KL}}(\pi^\star_\beta\|\pi_{\mathrm{ref}}) = k$ for
$\beta$. The left side is continuous and nonincreasing in $\beta$ (Theorem 4.14),
tends to $0$ as $\beta\to\infty$ and to $\log(1/\pi_{\mathrm{ref}}(i_{\max}))$ (for a
unique maximiser) as $\beta\to0^+$, so bisection converges for any feasible $k$ and
returns the unique $\beta$ up to the tolerance. Theorem 4.3 supplies an a priori
bracket: any $\beta > \Delta/k$ is too regularised. Cost: $O(|\iota|\log(1/\text{tol}))$.

A fourth, purely diagnostic procedure is worth naming: given a candidate policy $q$,
compute its implicit reward $R_q = \beta\log(q/\pi_{\mathrm{ref}})$ (Theorem 6.3).
This certifies $q$ as the exact optimum of an explicit reward, and comparing $R_q$
against the intended $R$ (modulo an additive constant, which is unobservable by
Theorem 6.1) measures how far an approximate optimiser has actually landed.

---

## 10. Discussion

**What the results are, and are not, about.** The theorems describe the idealised
optimisation over all distributions on a finite response set. Practical alignment
optimises over a parametric family, with sampled expectations and a learned reward.
The idealised solution is the target those methods approximate; results such as the
$\sqrt{\Delta/\beta}$ drift law and the $2\varepsilon$ hacking bound are therefore
statements about the *problem*, not guarantees about any particular optimiser. They
do, however, tell one what to expect in the limit of good optimisation, and where
degradation cannot be blamed on the optimiser.

**Temperature and thermodynamics.** The dictionary is complete: $-R$ is energy,
$\beta$ temperature, $Z$ the partition function, $\beta\log Z$ the free energy,
$\pi^\star$ the Boltzmann distribution over the base measure $\pi_{\mathrm{ref}}$,
and Theorem 4.14 the statement that lowering temperature increases both "order"
(divergence from the base measure) and "energy captured" (reward). Theorem 7.2
identifies the free energy as a convex function of the reward — a cumulant
generating functional — so the frontier of Theorem 4.14 is naturally read as a
Legendre-type duality between divergence budget and achievable reward.

**Design implications.**
- The drift budget scales as $\sqrt{\Delta/\beta}$, so aggressive reductions in
  $\beta$ produce only square-root gains in how far the model can move. Conversely
  they produce *linear* gains in the divergence, which is the quantity the leash
  of Theorem 4.3 controls.
- Because reward shifts are unobservable (Theorems 5.3, 6.1), normalising a reward
  model is free; only its *spread* $\Delta$ matters, and it enters every bound.
  Reward models with large dynamic range are exactly the ones with weak drift
  guarantees at fixed $\beta$.
- Sequential alignment stages add rewards (Corollary 5.5). A pipeline of $k$ stages
  at fixed $\beta$ is a single stage with reward $R_1+\cdots+R_k$; nothing is gained
  in expressivity, though the intermediate policies may of course differ from the
  final one, which matters if training is truncated.
- The pre-training mix-in strictly reduces attainable alignment quality
  (Theorem 8.4) but only at the prompts it touches (Theorem 8.5). If the goal is to
  protect general capability, coupling the mix-in narrowly is provably cheaper than
  coupling it globally.

**Limitations.** The response set is finite; the extension to countable or
continuous response spaces requires integrability hypotheses on $e^{R/\beta}$ but
should be routine, since every proof here uses only Gibbs' inequality, convexity of
$x\log x$, and Cauchy–Schwarz. Full support of $\pi_{\mathrm{ref}}$ is essential:
Theorem 4.5 shows that a response with zero reference probability is unreachable at
any temperature, which is the exact statement that alignment cannot teach a
behaviour the reference model never emits. Finally, all statements are about the
exact optimum; approximation-theoretic and sample-complexity questions are
untouched.

---

## 11. Future directions

**Sharpness of the drift law.** Theorem 4.11 gives
$\|\pi^\star - \pi_{\mathrm{ref}}\|_1 \le \sqrt{2\Delta/\beta}$. We conjecture the
square-root rate is optimal: there is a two-point family for which the ratio of the
two sides is bounded below by a positive constant as $\beta \to \infty$. Proving
this would pin the alignment drift budget exactly, converting the bound into a
scaling law.

**Curvature of the alignment frontier.** We conjecture the map
$\beta \mapsto \big(D_{\mathrm{KL}}(\pi^\star_\beta\|\pi_{\mathrm{ref}}),\, \mathbb{E}_{\pi^\star_\beta}[R]\big)$
traces a *concave* curve: achievable reward is a concave nondecreasing function of
the divergence budget, and its slope at budget $k$ is the unique $\beta$ with
$D_{\mathrm{KL}}(\pi^\star_\beta\|\pi_{\mathrm{ref}}) = k$. The natural mechanism is
that $\beta \mapsto \beta\log Z$ is a Legendre transform of the reward with respect
to the divergence, making the monotone frontier of Theorem 4.14 the graph of a
concave conjugate and $\beta$ literally the Lagrange multiplier of the divergence
constraint. Convexity and $1$-Lipschitzness of the free energy in the reward
(Theorems 7.2–7.3) are the inputs already in place.

**Beyond finite alphabets and beyond KL.** Replacing $D_{\mathrm{KL}}$ by a general
$f$-divergence changes the tilt from exponential to the corresponding conjugate
link; which of the structural results (additivity, torsor, implicit reward) survive
is an inviting question, since the group action is a specifically exponential
phenomenon.

**Approximate optimality.** Every result here has a natural stability version: if a
policy is within $\delta$ of optimal in objective value, Theorem 3.2 immediately
gives $D_{\mathrm{KL}}(p\|\pi^\star) \le \delta/\beta$ and hence, via Theorem 4.10,
$\|p - \pi^\star\|_1 \le \sqrt{2\delta/\beta}$. Turning this into end-to-end
guarantees for sampled, parametric optimisation is the obvious next step.

---

## 12. Conclusion

The KL-regularised alignment objective, with or without a pre-training mix-in, is
exactly solvable on a finite response set, and its solution is an exponentially
tilted reference policy with optimal value a free energy. From one identity follow
uniqueness, a value sandwich, a divergence leash, sharp square-root drift, both
temperature limits, a monotone reward/divergence frontier, additive composition of
alignment stages, exact identifiability of the aligned policy from preference data,
a $2\varepsilon$ reward-misspecification bound, an exact obstruction theorem for
the pre-training mix-in and its localisation, and uniqueness of the full optimum.
The mathematics of alignment, in this idealisation, is the mathematics of the
Boltzmann distribution.
