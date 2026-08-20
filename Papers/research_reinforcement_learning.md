# A Combinatorial Theory of KL-Regularized Alignment on the Boolean Lattice

**Author:** Aristotle

**Date:** 2026-08-20

---

## Abstract

We develop an exact, finitary theory of the KL-regularized reward-maximization objective
$J(q) = \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p)$ — the objective underlying
reinforcement learning from human (or symbolic) feedback — on response spaces with
combinatorial structure. Two structures are treated. First, **product spaces**: when the
reference policy is a product measure and the reward is additive across coordinates, the
partition function is multiplicative, the optimal policy is again a product, and the
divergence, objective, and optimal value are all additive; for $n$ i.i.d. coordinates this
yields exact linear scaling laws for alignment value, information drift, and the cost of
a pretraining mix-in term. Second, the **Boolean lattice** $2^{[n]}$ of feature sets under
a uniform reference policy: for the counting reward $r(S) = a|S|$ we obtain closed forms
for every object in the theory. The partition function is a binomial-theorem evaluation
$Z = ((1+e^{a/\beta})/2)^n$; the optimal policy is exactly a product of i.i.d.
$\mathrm{Bernoulli}(\sigma(a/\beta))$ features, where $\sigma$ is the logistic function;
the reward statistic $|S|$ is exactly $\mathrm{Binomial}(n,\sigma(a/\beta))$ with mean
$n\sigma(a/\beta)$; the entropy is $n\,H(\sigma(a/\beta))$ and the information drift is
$n\bigl((a/\beta)\sigma(a/\beta) - \log\frac{1+e^{a/\beta}}2\bigr)$. From log-concavity of
the binomial coefficients we deduce that the induced law of the reward statistic is
log-concave and hence unimodal, ruling out bimodal degeneration. A Bernoulli-inequality
argument yields the quantitative mode-collapse bound
$\pi(\text{argmax}) \ge 1 - n e^{-a/\beta}$, and both the achieved reward and the
collapse mass are shown to be strictly antitone in the regularization strength $\beta$.
Finally, for the non-additive rewards that arise from conjunctive symbolic rules we
identify **supermodularity** as the governing hypothesis: the optimal policy is then
log-supermodular, so by the Fortuin–Kasteleyn–Ginibre inequality any two increasing
observables are positively correlated, and by Holley's inequality a monotone reward makes
the optimal policy stochastically dominate the reference. Throughout, the technical engine
is enumerative and lattice combinatorics — the transfer principle
$\sum_{S\subseteq[n]} f(|S|) = \sum_k \binom nk f(k)$, the distributive law, Pascal's
absorption identity, and the four-functions theorem — rather than analysis.

**Keywords:** KL-regularized alignment; Boolean lattice; binomial law; logistic link;
log-concavity; FKG inequality; Holley inequality; supermodularity; tensorization; mode
collapse.

---

## 1. Introduction

### 1.1 The objective

Fix a finite set $\Omega$ of *responses*, a strictly positive *reference policy*
$p:\Omega \to (0,\infty)$ with $\sum_{y} p(y) = 1$, a *reward* $r : \Omega \to \mathbb{R}$,
and a *regularization strength* (or *temperature*) $\beta > 0$. For a probability
distribution $q$ on $\Omega$ define the **objective**

$$J_\beta(q) \;=\; \sum_{y \in \Omega} q(y)\,r(y) \;-\; \beta\!\!\sum_{y \in \Omega} q(y)\log\frac{q(y)}{p(y)} \;=\; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p).$$

This is exactly the alignment objective used to tune generative models against a learned
or symbolic reward: maximize reward while paying an information price for departing from
the reference behaviour. A third term, a *pretraining mix-in*
$\gamma\,\mathbb{E}_{x \sim d}[\log q(x)]$ with coefficient $\gamma \ge 0$ and pretraining
distribution $d$, is often added to prevent regression on general capabilities; we write
$J^{\mathrm{ptx}}_{\beta,\gamma}$ for the augmented objective.

Define the **partition function**, the **optimal (Gibbs) policy**, and the **free energy**:

$$Z_\beta(r,p) = \sum_{y} p(y)\,e^{r(y)/\beta}, \qquad \pi_\beta(y) = \frac{p(y)\,e^{r(y)/\beta}}{Z_\beta(r,p)}, \qquad F_\beta(r,p) = \beta \log Z_\beta(r,p).$$

The classical variational (Donsker–Varadhan / Gibbs) fact is that $\pi_\beta$ is the unique
maximizer of $J_\beta$ and that $\max_q J_\beta(q) = F_\beta(r,p)$; equivalently, for every
$q$,

$$J_\beta(q) \;=\; F_\beta(r,p) \;-\; \beta\,\mathrm{KL}(q\|\pi_\beta). \tag{1.1}$$

We take (1.1) as given and ask a different question.

### 1.2 The question

Alignment theory is usually pursued analytically: concentration bounds, convergence rates,
regret. But in practice the response space is not amorphous. A symbolic verifier attached
to a reward model reports a *set* of satisfied constraints; a sequence model emits a
*tuple* of tokens; a retrieval pipeline returns a *subset* of facts. These are
combinatorial objects, and on combinatorial objects the objective above does not merely
admit bounds — it admits **exact closed forms**.

This paper carries out that program in two settings.

**(A) Product structure (Section 3).** $\Omega = \Omega_1 \times \Omega_2$ with
$p = p_1 \otimes p_2$ and $r(y_1,y_2) = r_1(y_1) + r_2(y_2)$. Everything factorizes or
adds. Iterating gives exact linear scaling laws in the number of coordinates.

**(B) Boolean-lattice structure (Sections 4–7).** $\Omega = 2^{[n]}$, the family of
subsets of $[n] = \{1,\dots,n\}$, with $p$ uniform. This is the natural model of a
*neurosymbolic* reward: response $S$ is the set of the $n$ checkable features it
satisfies. Sections 4–6 treat the counting reward $r(S) = a|S|$, obtaining closed forms
for the partition function, policy, induced reward law, mean, entropy, drift, and
mode-collapse mass, along with monotonicity, log-concavity, and temperature-monotonicity
theorems. Section 7 drops additivity and treats supermodular rewards — the class generated
by counting rewards together with conjunctive rule bonuses — where FKG and Holley
inequalities take over.

### 1.3 Summary of contributions

1. A **transfer principle** (Theorem 4.1) reducing sums over the $2^n$-element Boolean
   lattice to $(n+1)$-term binomial sums, from which the generating identity
   $\sum_S x^{|S|} = (1+x)^n$ and all subsequent closed forms follow.
2. **Exact solution of the counting-reward alignment problem** (Theorems 4.4, 4.5, 5.1,
   5.3, 6.1, 6.2): partition function, aligned policy as an i.i.d. Bernoulli product with
   logistic parameter, binomial law of the reward statistic, exact mean, free energy,
   entropy, and information drift.
3. **Structural theorems**: order-preservation of the aligned measure (Theorem 6.4),
   log-concavity and hence unimodality of the reward law (Theorems 6.5, 6.6), and a
   consistency identity (Theorem 6.3) cross-validating two independent computations of the
   drift.
4. A **quantitative reward-hacking bound** $\pi(\text{top}) \ge 1 - ne^{-a/\beta}$
   (Theorem 6.7) with strict monotonicity of both reward and collapse mass in $\beta$
   (Theorems 6.8, 6.9).
5. **Lattice theory for non-additive rewards** (Section 7): supermodularity is a convex
   cone containing counting rewards and rule bonuses; the aligned policy is
   log-supermodular; FKG gives positive association of features; Holley gives stochastic
   dominance over the reference.
6. **Tensorization and exact scaling laws** (Section 3), including linear scaling of the
   pretraining-mixin-augmented value.

---

## 2. Notation and preliminaries

Throughout, $\Omega$ is a finite nonempty set. A function $q : \Omega \to \mathbb{R}$ is a
*distribution* if $\sum_y q(y) = 1$, and a *positive distribution* if in addition
$q(y) > 0$ for all $y$. For positive distributions $q, g$ set

$$\mathrm{KL}(q\|g) = \sum_y q(y)\log\frac{q(y)}{g(y)}, \qquad \mathrm{Ent}(q) = -\sum_y q(y)\log q(y).$$

We write $\sigma(t) = e^t/(1+e^t)$ for the **logistic** (sigmoid) function and
$H(\theta) = -\theta\log\theta - (1-\theta)\log(1-\theta)$ for the **binary entropy**. We
record two elementary facts used constantly.

**Lemma 2.1 (logistic basics).** For all $t \in \mathbb{R}$: $0 < \sigma(t) < 1$;
$1 - \sigma(t) = \dfrac{1}{1+e^t}$; $\sigma$ is strictly increasing; $\sigma(t) \ge 1/2$
whenever $t \ge 0$; and $1 - \sigma(t) \le e^{-t}$.

*Proof.* Positivity and the complement formula are immediate from
$\sigma(t) = e^t/(1+e^t)$ and $1+e^t > 0$; the complement formula gives $\sigma(t) < 1$.
Strict monotonicity follows from $\sigma(s) < \sigma(t)$ $\iff$
$e^s(1+e^t) < e^t(1+e^s)$ $\iff$ $e^s < e^t$. For $t \ge 0$ we have $e^t \ge 1$, so
$2e^t \ge 1 + e^t$ and $\sigma(t) \ge 1/2$. Finally $e^t \le 1 + e^t$ gives
$1-\sigma(t) = (1+e^t)^{-1} \le e^{-t}$. $\square$

For the Boolean lattice we identify $\Omega = 2^{[n]}$ with the collection of subsets
$S \subseteq \{1,\dots,n\}$, partially ordered by inclusion, with meet $\cap$ and join
$\cup$. The **uniform reference policy** is $p(S) = 2^{-n}$ for all $S$; it is a positive
distribution since there are exactly $2^n$ subsets.

---

## 3. Tensorization: exact scaling laws on product spaces

Before descending to the lattice we record the product theory, both because it is the
general reason alignment behaves extensively and because the Boolean-lattice results of
Section 4 turn out to be a hidden instance of it.

Let $\Omega_1, \Omega_2$ be finite nonempty sets. Given $p_i : \Omega_i \to \mathbb{R}$,
the **product reference** is $(p_1\otimes p_2)(y_1,y_2) = p_1(y_1)p_2(y_2)$; given
$r_i : \Omega_i \to \mathbb{R}$, the **additive reward** is
$(r_1 \oplus r_2)(y_1,y_2) = r_1(y_1) + r_2(y_2)$.

**Theorem 3.1 (multiplicativity of the partition function).**
$Z_\beta(r_1\oplus r_2,\; p_1\otimes p_2) = Z_\beta(r_1,p_1)\cdot Z_\beta(r_2,p_2)$.

*Proof sketch.* Expand the double sum, use $e^{(u+v)/\beta} = e^{u/\beta}e^{v/\beta}$, and
apply the distributive law $\bigl(\sum_a f(a)\bigr)\bigl(\sum_b g(b)\bigr) = \sum_{a,b} f(a)g(b)$
in reverse. $\square$

**Theorem 3.2 (the aligned policy of a separable problem is a product).** If $p_1,p_2$ are
positive distributions then
$$\pi_\beta\bigl(r_1\oplus r_2,\ p_1\otimes p_2\bigr) \;=\; \pi_\beta(r_1,p_1) \otimes \pi_\beta(r_2,p_2).$$

*Proof sketch.* Both sides at $(y_1,y_2)$ equal
$p_1(y_1)e^{r_1(y_1)/\beta}p_2(y_2)e^{r_2(y_2)/\beta}$ divided by $Z_1Z_2$, by Theorem 3.1.
$\square$

Theorem 3.2 is the precise sense in which **alignment cannot invent correlations the
reward did not ask for**: tilting a product measure by an additive reward returns a
product measure.

**Theorem 3.3 (additivity of divergence, objective and free energy).** For positive
distributions $q_i, g_i$ on $\Omega_i$,
$$\mathrm{KL}(q_1\otimes q_2 \,\|\, g_1 \otimes g_2) = \mathrm{KL}(q_1\|g_1) + \mathrm{KL}(q_2\|g_2),$$
and consequently
$$J_\beta\bigl(q_1 \otimes q_2;\ r_1\oplus r_2,\ p_1\otimes p_2\bigr) = J_\beta(q_1;r_1,p_1) + J_\beta(q_2;r_2,p_2), \qquad F_\beta(r_1\oplus r_2, p_1\otimes p_2) = F_\beta(r_1,p_1) + F_\beta(r_2,p_2).$$

*Proof sketch.* Since $\frac{q_1(a)q_2(b)}{g_1(a)g_2(b)} = \frac{q_1(a)}{g_1(a)}\cdot\frac{q_2(b)}{g_2(b)}$,
the logarithm splits; summing and using $\sum_a q_1(a) = \sum_b q_2(b) = 1$ gives
additivity of $\mathrm{KL}$. The same normalization argument gives additivity of
$\mathbb{E}[r_1\oplus r_2]$, hence of $J$. Free-energy additivity is
$\log(Z_1Z_2) = \log Z_1 + \log Z_2$ from Theorem 3.1. $\square$

### 3.1 Tensor powers and linear scaling laws

Now let $\alpha$ be a finite nonempty set, $n \ge 0$, and consider length-$n$ responses
$y \in \alpha^{[n]}$ with i.i.d. reference $p^{\otimes n}(y) = \prod_i p(y_i)$ and additive
reward $r^{\oplus n}(y) = \sum_i r(y_i)$.

**Theorem 3.4 (tensor-power law).** $Z_\beta(r^{\oplus n}, p^{\otimes n}) = Z_\beta(r,p)^n$,
and $\pi_\beta(r^{\oplus n},p^{\otimes n}) = \pi_\beta(r,p)^{\otimes n}$.

*Proof sketch.* The distributive law in the form
$\prod_{i=1}^n \sum_{a \in \alpha} h_i(a) = \sum_{y \in \alpha^{[n]}} \prod_i h_i(y_i)$
— expansion of a product of sums over the "hypercube" of index choices — applied to
$h_i(a) = p(a)e^{r(a)/\beta}$, identifies the $n$-fold partition sum with $Z_1^n$; the
policy statement then follows by dividing. $\square$

**Corollary 3.5 (linear scaling laws).** With $p$ a positive distribution, $\beta>0$:
$$F_\beta(r^{\oplus n}, p^{\otimes n}) = n\,F_\beta(r,p), \qquad \mathbb{E}_{\pi^{(n)}}\bigl[r^{\oplus n}\bigr] = n\,\mathbb{E}_{\pi}[r], \qquad \mathrm{KL}\bigl(\pi^{(n)} \,\big\|\, p^{\otimes n}\bigr) = n\,\mathrm{KL}(\pi\|p).$$
Moreover, with an i.i.d. pretraining distribution $d^{\otimes n}$, the pretraining-augmented
value at the aligned policy satisfies
$J^{\mathrm{ptx}}_{\beta,\gamma}\bigl(\pi^{(n)}\bigr) = n\,J^{\mathrm{ptx}}_{\beta,\gamma}(\pi)$.

*Proof sketch.* Free energy: $\log(Z_1^n) = n\log Z_1$. Reward: a marginalization
identity — again the distributive law — shows that integrating a one-coordinate observable
against a product measure returns the one-coordinate expectation, and there are $n$
coordinates. Drift: read $\mathrm{KL}$ off the exact identity
$\beta\,\mathrm{KL}(\pi\|p) = \mathbb{E}_\pi[r] - F_\beta$, then divide by $\beta > 0$.
For the mix-in, the entropy of $d^{\otimes n}$ is $n\,\mathrm{Ent}(d)$ and
$\mathrm{KL}(d^{\otimes n}\|\pi^{(n)}) = n\,\mathrm{KL}(d\|\pi)$ by the same
marginalization argument, and the value of the augmented objective at the aligned policy
is an affine combination of these. $\square$

**Interpretation.** Reward gain, information drift, and pretraining cost all carry the same
exponent $n^1$. Therefore *no* choice of $(\beta,\gamma)$ can asymptotically rebalance them
as the number of coordinates grows: an imbalance at one length is an imbalance at every
length. Only per-coordinate budgets (drift per token, not drift per response) are stable
under changing response length.

---

## 4. The Boolean lattice: transfer principle and exact solution

### 4.1 The transfer principle

**Theorem 4.1 (transfer principle).** For every $n \ge 0$ and every
$f : \mathbb{N} \to \mathbb{R}$,
$$\sum_{S \subseteq [n]} f\bigl(|S|\bigr) \;=\; \sum_{k=0}^{n} \binom{n}{k}\, f(k).$$

*Proof sketch.* Partition the power set of $[n]$ into its level sets
$\mathcal{P}_k = \{S : |S| = k\}$ for $k = 0,\dots,n$. On $\mathcal{P}_k$ the summand is
the constant $f(k)$, and $|\mathcal{P}_k| = \binom nk$. $\square$

**Corollary 4.2 (generating function of the cube).** For all $x \in \mathbb{R}$,
$\displaystyle\sum_{S\subseteq[n]} x^{|S|} = (1+x)^n$.

*Proof.* Apply Theorem 4.1 with $f(k) = x^k$ and compare with the binomial expansion of
$(x+1)^n$. $\square$

Corollary 4.2 is the single computational device behind every closed form below. It is
worth emphasizing what it does: it converts a sum over $2^n$ objects into an evaluation of
a degree-$n$ polynomial.

### 4.2 The counting reward and its solution

**Definition 4.3.** On $\Omega = 2^{[n]}$ with uniform reference $p(S) = 2^{-n}$, the
**counting reward** with per-feature value $a \in \mathbb{R}$ is $r(S) = a\,|S|$. The
**Bernoulli feature policy** with parameter $\theta$ is
$$\mathrm{Ber}_n^\theta(S) \;=\; \theta^{|S|}(1-\theta)^{\,n - |S|}.$$

**Theorem 4.4 (the partition function is a binomial evaluation).**
$$Z_\beta\bigl(a|\cdot|,\ \mathrm{unif}\bigr) \;=\; \left(\frac{1 + e^{a/\beta}}{2}\right)^{\!n}.$$

*Proof sketch.* Each term is $2^{-n}e^{a|S|/\beta} = 2^{-n}\bigl(e^{a/\beta}\bigr)^{|S|}$,
using $e^{|S| \cdot t} = (e^t)^{|S|}$. Factor out $2^{-n}$ and apply Corollary 4.2 with
$x = e^{a/\beta}$ to get $2^{-n}(1+e^{a/\beta})^n$. $\square$

**Theorem 4.5 (alignment on the Boolean lattice = i.i.d. Bernoulli features).** For all
$n, a, \beta$,
$$\pi_\beta\bigl(a|\cdot|,\ \mathrm{unif}\bigr) \;=\; \mathrm{Ber}_n^{\theta}, \qquad \theta = \sigma\!\left(\frac a\beta\right) = \frac{e^{a/\beta}}{1+e^{a/\beta}}.$$

*Proof sketch.* Write $E = e^{a/\beta}$. The numerator of the Gibbs formula at $S$ is
$2^{-n}E^{|S|}$ and the denominator is $\bigl((1+E)/2\bigr)^n$ by Theorem 4.4, so
$\pi(S) = E^{|S|}/(1+E)^n$. On the other side, $\theta = E/(1+E)$ and
$1 - \theta = 1/(1+E)$ by Lemma 2.1, so
$$\mathrm{Ber}_n^\theta(S) = \frac{E^{|S|}}{(1+E)^{|S|}}\cdot\frac{1}{(1+E)^{n-|S|}} = \frac{E^{|S|}}{(1+E)^{n}},$$
where the splitting $(1+E)^{|S|}(1+E)^{n-|S|} = (1+E)^n$ uses $|S| \le n$. $\square$

Theorem 4.5 is the central structural statement of the paper. Three remarks.

- The logistic link is *derived*, not assumed. It arises because the Gibbs tilt of a
  uniform two-point measure on $\{$feature absent, feature present$\}$ by a linear reward
  is exactly a logistic reweighting.
- The parameters $a$ and $\beta$ enter only via the ratio $a/\beta$. The regularized
  alignment problem for counting rewards has a **one-dimensional effective parameter**.
- Since $\mathrm{Ber}_n^\theta$ is a positive distribution (immediately, by Theorem 4.5 and
  positivity of the Gibbs policy, or directly by the binomial theorem), all subsequent
  expectations are well-defined.

Note that Theorem 4.5 exhibits the Boolean-lattice problem as an instance of the tensor
theory of Section 3, with $\alpha = \{0,1\}$: the counting reward is additive across
features and the uniform reference is i.i.d. Everything extensive in $n$ below is therefore
an instance of Corollary 3.5.

---

## 5. The induced law of the reward statistic

Under the aligned policy, the observable a practitioner actually measures is the reward
statistic $|S|$ — "how many checks did the answer pass?". Its law is exactly binomial.

**Theorem 5.1 (binomial law of the aligned policy).** For $0 \le k \le n$, with
$\theta = \sigma(a/\beta)$,
$$\pi_\beta\bigl(\{S : |S| = k\}\bigr) \;=\; \binom{n}{k}\,\theta^{k}(1-\theta)^{\,n-k}.$$

*Proof sketch.* The level set $\{S \subseteq [n] : |S| = k\}$ has exactly $\binom nk$
elements, and by Theorem 4.5 the aligned policy is constant, equal to
$\theta^k(1-\theta)^{n-k}$, on that level set. $\square$

We write $m_k(\theta) = \binom nk \theta^k (1-\theta)^{n-k}$ for these **level masses**.

**Lemma 5.2 (combinatorial mean identity).** For all $n \ge 0$ and $x,y \in \mathbb{R}$,
$$\sum_{k=0}^{n} k \binom nk x^k y^{\,n-k} \;=\; n\,x\,(x+y)^{\,n-1}.$$

*Proof sketch.* For $n = 0$ both sides vanish. For $n = m+1$, drop the $k=0$ term and
reindex $k \mapsto k+1$. Pascal's absorption identity in the form
$(m+1)\binom mk = \binom{m+1}{k+1}(k+1)$ converts each summand into
$(m+1)\,x\cdot\binom mk x^k y^{\,m-k}$, and $\sum_k \binom mk x^k y^{m-k} = (x+y)^m$ by the
binomial theorem. $\square$

**Theorem 5.3 (exact mean and expected reward).** For any $\theta$,
$\mathbb{E}_{\mathrm{Ber}_n^\theta}\bigl[|S|\bigr] = n\theta$. Consequently, under the
aligned policy for the counting reward,
$$\mathbb{E}_{\pi_\beta}\bigl[a|S|\bigr] \;=\; a\,n\,\sigma\!\left(\frac a\beta\right).$$

*Proof sketch.* By the transfer principle (Theorem 4.1) applied to
$f(k) = \theta^k(1-\theta)^{n-k}k$, the expectation equals
$\sum_k k\binom nk \theta^k(1-\theta)^{n-k}$, which by Lemma 5.2 with $x=\theta$,
$y = 1-\theta$ equals $n\theta(\theta + 1 - \theta)^{n-1} = n\theta$. Multiply by $a$ and
substitute $\theta = \sigma(a/\beta)$. $\square$

---

## 6. Free energy, entropy, drift, order and collapse

### 6.1 Value and drift

**Theorem 6.1 (free energy).**
$\displaystyle F_\beta\bigl(a|\cdot|,\mathrm{unif}\bigr) = n\,\beta\,\log\frac{1+e^{a/\beta}}{2}.$

*Proof.* $\beta\log$ of Theorem 4.4, using $\log(u^n) = n\log u$ for $u > 0$. $\square$

**Theorem 6.2 (exact information drift).** For $\beta > 0$,
$$\mathrm{KL}\bigl(\pi_\beta \,\big\|\, \mathrm{unif}\bigr) \;=\; n\left(\frac a\beta\,\sigma\!\left(\frac a\beta\right) \;-\; \log\frac{1+e^{a/\beta}}{2}\right).$$

*Proof sketch.* Evaluate identity (1.1) at $q = \pi_\beta$: $J_\beta(\pi_\beta) = F_\beta$,
i.e. $\mathbb{E}_{\pi_\beta}[r] - \beta\,\mathrm{KL}(\pi_\beta\|p) = F_\beta$. Substitute
Theorem 5.3 for the expectation and Theorem 6.1 for the free energy, then cancel the factor
$\beta > 0$. $\square$

The drift is *extensive* — proportional to $n$ — exactly as Corollary 3.5 predicts.

### 6.2 Entropy and a consistency identity

**Theorem 6.3 (entropy; entropy form of the drift; consistency).** For $0 < \theta < 1$,
$$\mathrm{Ent}\bigl(\mathrm{Ber}_n^\theta\bigr) \;=\; n\,H(\theta).$$
For any positive distribution $q$ on $2^{[n]}$,
$$\mathrm{KL}(q \,\|\, \mathrm{unif}) \;=\; n\log 2 \;-\; \mathrm{Ent}(q).$$
Combining these with Theorem 6.2 yields, for every $t \in \mathbb{R}$, the analytic identity
$$t\,\sigma(t) - \log\frac{1+e^{t}}{2} \;=\; \log 2 - H\bigl(\sigma(t)\bigr).$$

*Proof sketch.* For the entropy: $\log \mathrm{Ber}_n^\theta(S) = |S|\log\theta + (n - |S|)\log(1-\theta)$,
so $\mathrm{Ent} = -\log\theta\cdot\mathbb{E}[|S|] - \log(1-\theta)\cdot(n - \mathbb{E}[|S|])$;
insert $\mathbb{E}[|S|] = n\theta$ from Theorem 5.3. For the second display: with
$p(S) = 2^{-n}$ constant, $\log\frac{q(S)}{p(S)} = n\log 2 + \log q(S)$, and summing against
$q$ (total mass $1$) gives the claim. The identity follows by computing the drift of
$\pi_\beta$ in the two ways and equating; it suffices to do so at $n = 1$, and $t = a/\beta$
ranges over all of $\mathbb{R}$. $\square$

The last display is a genuine cross-check: two independent derivations — one through the
free energy, one through the entropy — of the same quantity must agree, and forcing
agreement produces a nontrivial identity relating the logistic function to the binary
entropy. (Sanity check at $t=0$: both sides vanish, since $\sigma(0)=1/2$ and
$H(1/2) = \log 2$.)

### 6.3 Order structure

**Theorem 6.4 (alignment is order-preserving).** Let $\tfrac12 \le \theta \le 1$. Then
$\mathrm{Ber}_n^\theta$ is a **monotone measure** on the Boolean lattice: $S \subseteq T$
implies $\mathrm{Ber}_n^\theta(S) \le \mathrm{Ber}_n^\theta(T)$. In particular, for a
non-negative counting reward $a \ge 0$ and $\beta > 0$ the aligned policy is monotone.

*Proof sketch.* Write $j = |T| - |S| \ge 0$. Then
$$\mathrm{Ber}_n^\theta(S) = \theta^{|S|}(1-\theta)^{n-|T|}(1-\theta)^{j}, \qquad \mathrm{Ber}_n^\theta(T) = \theta^{|S|}(1-\theta)^{n-|T|}\theta^{j},$$
using $n - |S| = (n - |T|) + j$ and $|T| = |S| + j$. Since $0 \le 1-\theta \le \theta$ we
have $(1-\theta)^j \le \theta^j$, and the common prefactor is non-negative. The final claim
uses $\sigma(a/\beta) \ge 1/2$ for $a/\beta \ge 0$ (Lemma 2.1). $\square$

### 6.4 Log-concavity and the impossibility of bimodal degeneration

**Theorem 6.5 (log-concavity of the level masses).** For $0 \le \theta \le 1$ and all
$k \ge 0$,
$$m_k(\theta)\,m_{k+2}(\theta) \;\le\; m_{k+1}(\theta)^2.$$

*Proof sketch.* First, log-concavity of the binomial coefficients:
$\binom nk\binom n{k+2} \le \binom n{k+1}^2$. If $k \ge n$ the left side vanishes. Otherwise
use the absorption identity twice, $\binom{n}{k+1}(k+1) = \binom nk (n-k)$ and
$\binom{n}{k+2}(k+2) = \binom{n}{k+1}(n-k-1)$, and the inequality
$(k+1)(n-k-1) \le (k+2)(n-k)$; multiplying through by the positive quantity $(n-k)(k+2)$
gives the claim. Second, the powers of $\theta$ and $1-\theta$ match on the two sides:
$\theta^{k}\theta^{k+2} = \theta^{2k+2} = (\theta^{k+1})^2$ and, when $k+2 \le n$,
$(n-k) + (n-k-2) = 2(n-k-1)$. Multiplying the coefficient inequality by the common
non-negative power factor finishes the argument; the degenerate case $k+2 > n$ is handled
by $m_{k+2} = 0$. $\square$

**Theorem 6.6 (unimodality: descent persists).** Let $0 \le \theta \le 1$ and suppose
$m_{k+1}(\theta) > 0$ and $m_{k+1}(\theta) \le m_k(\theta)$. Then
$m_{k+2}(\theta) \le m_{k+1}(\theta)$.

*Proof.* Multiply the hypothesis $m_{k+1}\le m_k$ by $m_{k+2} \ge 0$ to get
$m_{k+1}m_{k+2} \le m_k m_{k+2}$, then apply Theorem 6.5 to get
$m_{k+1}m_{k+2} \le m_{k+1}^2$, and cancel the positive factor $m_{k+1}$. $\square$

**Interpretation.** The distribution of "how many checks the answer passed" under the
aligned policy has a single mode: once the level masses begin to fall they never rise
again. A model aligned to a linear symbolic reward therefore **cannot** split into two
separated populations of quality. Bimodal reward hacking is not merely unlikely in this
regime; it is impossible. This is a safety-relevant structural guarantee obtained purely
from log-concavity of Pascal's triangle.

### 6.5 Mode collapse and its temperature dependence

**Theorem 6.7 (quantitative reward hacking).** Let $a \ge 0$ and $\beta > 0$. The aligned
policy places mass at least $1 - n\,e^{-a/\beta}$ on the single maximal response $[n]$:
$$\pi_\beta\bigl([n]\bigr) \;=\; \sigma\!\left(\frac a\beta\right)^{\! n} \;\ge\; 1 - n\,e^{-a/\beta}.$$

*Proof sketch.* By Theorems 4.5 and the fact $|[n]| = n$, the mass on the top element is
$\theta^n$ with $\theta = \sigma(a/\beta)$. Bernoulli's inequality
$(1 + u)^n \ge 1 + nu$ with $u = \theta - 1 \ge -1$ gives $\theta^n \ge 1 - n(1-\theta)$,
and $1-\theta \le e^{-a/\beta}$ by Lemma 2.1. $\square$

Thus a policy that begins uniform over $2^n$ responses concentrates onto a *single*
response at a rate exponential in the effective temperature $a/\beta$. For $n = 20$ and
$a/\beta = 10$ the bound already exceeds $0.999$. As $\beta \to 0^+$ with $a>0$ fixed,
collapse is total.

**Theorem 6.8 (reward is strictly antitone in $\beta$).** Let $n \ge 1$, $a > 0$ and
$0 < \beta_1 < \beta_2$. Then
$$a\,n\,\sigma\!\left(\frac{a}{\beta_2}\right) \;<\; a\,n\,\sigma\!\left(\frac{a}{\beta_1}\right).$$

**Theorem 6.9 (collapse mass is strictly antitone in $\beta$).** Under the same hypotheses,
$$\pi_{\beta_2}\bigl([n]\bigr) \;<\; \pi_{\beta_1}\bigl([n]\bigr).$$

*Proof sketch of both.* For $a>0$ and $0<\beta_1<\beta_2$ we have $a/\beta_2 < a/\beta_1$,
so $\sigma(a/\beta_2) < \sigma(a/\beta_1)$ by strict monotonicity of $\sigma$ (Lemma 2.1).
Theorem 6.8 multiplies this by the positive constant $an$; Theorem 6.9 raises it to the
$n$-th power, using $0 < \sigma$ and $n \ge 1$ so that $u \mapsto u^n$ is strictly
increasing on $[0,\infty)$. $\square$

**No free lunch.** Theorems 6.8 and 6.9 together say that the regularization strength
$\beta$ trades achieved reward against mode collapse *strictly monotonically in both
directions*: any tightening that reduces collapse necessarily reduces reward, and any
loosening that increases reward necessarily increases collapse. There is no interior
setting that improves both.

---

## 7. Beyond additivity: supermodular rewards, FKG and Holley

Realistic symbolic reward models are not additive. A rule of the form "award $c \ge 0$
whenever *all* premises in $R \subseteq [n]$ are satisfied" is a conjunctive synergy: it
pays nothing until the last premise arrives. The correct lattice-theoretic class is
supermodularity.

**Definition 7.1.** A reward $r : 2^{[n]} \to \mathbb{R}$ is **supermodular** if for all
$S,T \subseteq [n]$,
$$r(S) + r(T) \;\le\; r(S \cap T) + r(S \cup T).$$
It is **modular** if equality always holds. The **rule bonus** with premise set $R$ and
value $c$ is $\mathrm{Bonus}_{R,c}(S) = c\cdot\mathbf{1}[R \subseteq S]$.

**Proposition 7.2 (the reward class).**
(i) The counting reward $r(S) = a|S|$ is modular, for every sign of $a$.
(ii) $\mathrm{Bonus}_{R,c}$ is supermodular for every $R$ and every $c \ge 0$.
(iii) Supermodular rewards form a convex cone: closed under addition and under
multiplication by non-negative scalars.
Consequently every reward of the form
$r(S) = a|S| + \sum_{j} c_j \mathbf{1}[R_j \subseteq S]$ with $c_j \ge 0$ is supermodular.

*Proof sketch.* (i) is the identity $|S\cap T| + |S\cup T| = |S| + |T|$ scaled by $a$.
(ii) is a four-case check: if $R \subseteq S$ and $R\subseteq T$ then $R$ is contained in
both $S\cap T$ and $S \cup T$ and both sides equal $2c$; if $R$ is contained in exactly one
of them then the left side is $c$ and the right side is at least $c$ (since $R \subseteq S\cup T$);
if in neither, the left side is $0$ and the right side is a sum of terms in $\{0,c\}$ with
$c \ge 0$. (iii) is immediate from linearity of the defining inequality. $\square$

**Theorem 7.3 (the aligned policy is log-supermodular).** Let $\beta > 0$ and let $r$ be
supermodular. Then the aligned policy $\pi_\beta$ (with uniform reference) satisfies the
**FKG lattice condition**
$$\pi_\beta(S)\,\pi_\beta(T) \;\le\; \pi_\beta(S\cap T)\,\pi_\beta(S \cup T) \qquad \text{for all } S,T.$$

*Proof sketch.* Each $\pi_\beta(S) = 2^{-n}e^{r(S)/\beta}/Z$ with the same positive
constants $2^{-n}$ and $Z$ on both sides, so the claim reduces to
$e^{r(S)/\beta}e^{r(T)/\beta} \le e^{r(S\cap T)/\beta}e^{r(S\cup T)/\beta}$, i.e. to
$\frac{r(S)+r(T)}{\beta} \le \frac{r(S\cap T)+r(S\cup T)}{\beta}$, which is Definition 7.1
divided by $\beta > 0$. $\square$

The FKG lattice condition is exactly the hypothesis of the Fortuin–Kasteleyn–Ginibre
correlation inequality (itself a corollary of the Ahlswede–Daykin four-functions theorem),
which we invoke in the following form: *if $\mu \ge 0$ on a finite distributive lattice
satisfies $\mu(x)\mu(y) \le \mu(x\wedge y)\mu(x \vee y)$, then for all non-negative
increasing $f,g$,*
$$\Bigl(\sum_x \mu(x)f(x)\Bigr)\Bigl(\sum_x \mu(x)g(x)\Bigr) \;\le\; \Bigl(\sum_x \mu(x)\Bigr)\Bigl(\sum_x \mu(x)f(x)g(x)\Bigr).$$

**Theorem 7.4 (positive association under alignment).** Let $\beta>0$, let $r$ be
supermodular, and let $f,g : 2^{[n]} \to \mathbb{R}$ be non-negative and monotone
increasing. Then
$$\mathbb{E}_{\pi_\beta}[f]\cdot\mathbb{E}_{\pi_\beta}[g] \;\le\; \mathbb{E}_{\pi_\beta}[fg].$$

*Proof.* Apply FKG with $\mu = \pi_\beta$, legitimate by Theorem 7.3; the total mass
$\sum_S \pi_\beta(S)$ equals $1$. $\square$

**Corollary 7.5 (feature entanglement).** For any two features $i,j \in [n]$, under the
aligned policy of any supermodular reward,
$$\Pr_{\pi_\beta}[\,i \in S\,]\cdot\Pr_{\pi_\beta}[\,j \in S\,] \;\le\; \Pr_{\pi_\beta}[\,i \in S \text{ and } j \in S\,].$$

*Proof.* The indicator $S \mapsto \mathbf 1[i \in S]$ is non-negative and increasing;
apply Theorem 7.4 to the two indicators. $\square$

So alignment against a synergistic symbolic reward **provably entangles** the features: no
supermodular reward can produce a policy in which two monotone desiderata are negatively
correlated. Design criteria built from conjunctive rules cannot be made to compete with one
another by the tuning procedure.

### 7.1 Stochastic dominance over the reference

**Lemma 7.6.** If $\beta > 0$ and $r$ is monotone increasing, then $\pi_\beta$ is a monotone
function on the lattice: $S \subseteq T \Rightarrow \pi_\beta(S) \le \pi_\beta(T)$.

*Proof.* $\pi_\beta(S) = 2^{-n}e^{r(S)/\beta}/Z$ and $r(S) \le r(T)$, and $t\mapsto e^{t/\beta}$
is increasing. $\square$

We use Holley's inequality in the form: *if $\mu,\nu \ge 0$ on a finite distributive lattice
have equal total mass and satisfy $\mu(x)\nu(y) \le \mu(x \wedge y)\nu(x \vee y)$ for all
$x,y$, then $\sum_x \mu(x)h(x) \le \sum_x \nu(x)h(x)$ for every non-negative increasing $h$.*

**Theorem 7.7 (alignment dominates the reference).** Let $\beta > 0$ and let $r$ be monotone
increasing. Then for every non-negative monotone increasing observable $h$,
$$\mathbb{E}_{\mathrm{unif}}[h] \;\le\; \mathbb{E}_{\pi_\beta}[h].$$
That is, the aligned policy stochastically dominates the reference policy, uniformly in
$\beta$.

*Proof sketch.* Both $\mathrm{unif}$ and $\pi_\beta$ are probability distributions, so their
total masses agree. The Holley condition reads
$\mathrm{unif}(S)\,\pi_\beta(T) \le \mathrm{unif}(S\cap T)\,\pi_\beta(S\cup T)$; the uniform
factors are equal (both $2^{-n}$), and $\pi_\beta(T) \le \pi_\beta(S \cup T)$ by Lemma 7.6
since $T \subseteq S\cup T$. Apply Holley. $\square$

Theorem 7.7 is unconditional in a strong sense: not only does the expected reward improve
(which is unsurprising), but the expectation of *every* monotone quantity improves, for
*every* regularization strength. Monotone alignment cannot degrade any monotone property.

---

## 8. Algorithms

The closed forms of Sections 4–6 turn quantities that would naively require summing over
$2^n$ responses into $O(1)$ or $O(n)$ evaluations. We record the resulting procedures.

**Algorithm A (exact aligned-policy profile).** *Input:* $n$, $a$, $\beta > 0$. *Output:*
the effective temperature $t = a/\beta$, the per-feature acceptance probability
$\theta = \sigma(t)$, the partition function $Z = ((1+e^t)/2)^n$, the free energy
$F = n\beta\log\frac{1+e^t}{2}$, expected reward $an\theta$, entropy $nH(\theta)$, drift
$n(t\theta - \log\frac{1+e^t}2)$, and top mass $\theta^n$ with lower bound
$1 - ne^{-t}$. *Cost:* $O(1)$ arithmetic operations, versus $\Theta(2^n)$ for a naive
enumeration. Numerically, $\sigma(t)$ should be evaluated in the stable form
$\sigma(t) = 1/(1+e^{-t})$ for $t \ge 0$ and $e^t/(1+e^t)$ for $t<0$, and
$\log\frac{1+e^t}{2}$ as $\mathrm{softplus}(t) - \log 2$ with
$\mathrm{softplus}(t) = \max(t,0) + \log(1+e^{-|t|})$.

**Algorithm B (level-mass profile and mode).** *Input:* $n$, $\theta$. *Output:* the vector
$(m_0,\dots,m_n)$, $m_k = \binom nk \theta^k(1-\theta)^{n-k}$, and its mode. *Method:* use
the ratio recurrence $m_{k+1}/m_k = \frac{n-k}{k+1}\cdot\frac{\theta}{1-\theta}$, starting
from $m_0 = (1-\theta)^n$. *Cost:* $O(n)$ operations and no binomial coefficients need be
formed explicitly. *Correctness of the mode search:* by Theorem 6.6 the sequence is
unimodal, so the first index at which the ratio drops below $1$ is the mode; no global
scan is required.

**Algorithm C (brute-force verifier over the lattice).** *Input:* $n \le 20$, arbitrary
reward $r$ given as an oracle on subsets, $\beta$. *Output:* the exact Gibbs policy over
all $2^n$ subsets, its partition function, expectations, drift, and empirical correlations.
*Method:* enumerate subsets as bitmasks, form $w_S = 2^{-n}e^{r(S)/\beta}$, normalize.
*Cost:* $\Theta(2^n)$ time, $\Theta(2^n)$ memory. This is the reference implementation
against which the $O(1)$ and $O(n)$ formulas are checked, and it is also the only available
route for general supermodular rewards, for which no closed form exists.

**Algorithm D (supermodularity certification).** *Input:* $n$, reward oracle $r$. *Output:*
whether $r(S)+r(T) \le r(S\cap T) + r(S\cup T)$ for all pairs, plus a violating pair if not.
*Method:* it suffices to check the local condition on "diamonds" — for every
$S$ and every pair of distinct $i,j \notin S$,
$$r(S \cup \{i\}) + r(S\cup\{j\}) \;\le\; r(S) + r(S\cup\{i,j\}),$$
which is equivalent to full supermodularity. *Cost:* $\Theta(2^n n^2)$ with the local test,
versus $\Theta(4^n)$ for the naive all-pairs test.

---

## 9. Applications and interpretation

**Sample-complexity of quality estimation.** Theorem 5.1 says the quality statistic is
exactly $\mathrm{Binomial}(n,\theta)$. Its variance is therefore $n\theta(1-\theta)$, known
in closed form, so the number of samples needed to estimate mean quality to a given
precision is computable *a priori* rather than estimated empirically.

**Choosing the regularization strength.** Theorem 6.7 converts a safety requirement
("collapse mass below $\varepsilon$") into an explicit constraint on $a/\beta$, and
Theorems 6.8–6.9 guarantee that the trade-off curve is strictly monotone, so a bisection on
$\beta$ is well-posed and converges to a unique operating point.

**Length stability.** Corollary 3.5 shows that drift, value, and pretraining cost all scale
linearly in the number of independent coordinates. Consequently a global divergence budget
is not length-stable: as responses lengthen, a fixed global budget forces the per-coordinate
budget to shrink, and the effective temperature to change. Per-coordinate budgets are the
only length-invariant choice.

**Reward design.** Proposition 7.2 delimits a large and practically natural class —
counting plus non-negative conjunctive bonuses — for which Theorems 7.4 and 7.7 hold. A
designer who stays inside the supermodular cone is guaranteed positive association among
desiderata and stochastic improvement of every monotone property. Stepping outside it
(for example, by adding a bonus with a *negative* coefficient, or a rule that fires on a
disjunction of premises with a subtractive interaction) forfeits both guarantees, and this
is the precise structural cost of such a design.

**Why bimodality is the right thing to worry about, and where.** Theorem 6.6 says linear
symbolic rewards cannot produce bimodal quality distributions. Observing bimodality in
practice is therefore evidence that the effective reward is *not* linear in the checked
features — a diagnostic, not merely a nuisance.

---

## 10. Discussion

The results above have a common shape: an object from statistical learning is identified
with an object from enumerative or lattice combinatorics, and the combinatorial identity
then supplies an exact answer.

- The **sigmoid link** of the aligned policy is the binomial theorem (Corollary 4.2,
  Theorem 4.5).
- The **mean reward** is Pascal's absorption identity (Lemma 5.2, Theorem 5.3).
- The **impossibility of bimodal degeneration** is log-concavity of the binomial
  coefficients (Theorems 6.5, 6.6).
- The **entanglement of desiderata** is the FKG inequality (Theorem 7.4).
- The **improvement of every monotone property** is Holley's inequality (Theorem 7.7).
- The **collapse onto the maximizer** is Bernoulli's inequality (Theorem 6.7).
- The **extensivity of everything** is the distributive law (Theorem 3.4).

Two limitations deserve emphasis. First, the exactly solvable model requires a uniform
reference policy; a general reference destroys the level-set symmetry underlying the
transfer principle, though the FKG/Holley results of Section 7 survive for any
log-supermodular reference. Second, the closed forms are for *additive* rewards; for general
supermodular rewards we have qualitative structure (log-supermodularity, positive
association, dominance) but no closed form, and indeed the partition function of a general
supermodular reward on the Boolean lattice is computationally hard.

What the theory does supply, robustly, is a set of *exact* statements — not asymptotic, not
approximate, valid for every $n$, $a$, $\beta$ — about a procedure that is usually studied
empirically. That combination is unusual enough to be worth the change of viewpoint.

---

## 11. Future directions

The results above suggest three concrete next steps.

**C1. Strict superadditivity of the free energy under synergy.** *Conjecture.* For a reward
on $2^{[m+n]}$ that is supermodular but not modular, the free energy strictly exceeds the
sum of the free energies of its two coordinate restrictions,
$F(r) > F(r|_1) + F(r|_2)$, with equality exactly on the modular cone. The key insight is
that free-energy additivity (Theorem 3.3) was proved from the exact factorization of the
partition function for *additive* rewards, while the four-functions machinery behind
Theorem 7.3 gives a one-sided inequality $Z \ge Z_1 Z_2$ for supermodular couplings — so
superadditivity should follow from the FKG lattice condition rather than from any analytic
estimate. Both halves already exist: the exact additive identity and the lattice inequality;
only the gap term needs to be built.

**C2. A marginal-gain reward-hacking bound for non-additive rewards.** *Conjecture.* Let
$r$ be monotone and supermodular with minimal marginal gain
$\delta = \min_{S,\, i \notin S}\bigl(r(S\cup\{i\}) - r(S)\bigr) > 0$. Then the aligned
policy satisfies $\pi(\text{top}) \ge 1 - n e^{-\delta/\beta}$, exactly as in the
counting-reward case (Theorem 6.7), and the exponent $\delta/\beta$ is optimal. The key
insight is that the proof of Theorem 6.7 only used a per-feature comparison of two responses
differing in one element, so it should localize to marginal gains, with supermodularity
supplying the required monotone coupling along maximal chains of the Boolean lattice. The
Holley chain-comparison tool of Theorem 7.7 is already available, and the counting-reward
version is a proved special case to test against.

**C3. The pretraining mix-in provably de-collapses the policy.** *Conjecture.* With uniform
pretraining distribution $d$ and mix-in coefficient $\gamma > 0$, the maximizer of the
augmented objective over the Bernoulli family is a unique $\theta^*(\gamma)$ with
$\theta^*(\gamma) < \sigma(a/\beta)$, strictly decreasing in $\gamma$; consequently the mass
on the reward-maximizing response is strictly smaller than the pure value
$\sigma(a/\beta)^n$. The key insight is that on the Boolean lattice the mix-in term
evaluates in closed form,
$$\gamma\,\mathbb{E}_d[\log \pi] \;=\; \gamma\cdot\frac n2\bigl(\log\theta + \log(1-\theta)\bigr),$$
which is strictly concave and symmetric about $\theta = 1/2$, so it acts as an explicit
entropic restoring force pulling the aligned policy back from the corner of the cube.

---

## 12. Conclusion

On response spaces with combinatorial structure, the KL-regularized alignment objective is
exactly solvable. On the Boolean lattice of satisfied features with a uniform reference and
a counting reward, the aligned policy is a product of i.i.d. Bernoulli features with a
logistic parameter; the reward statistic is binomial; the value, entropy, and information
drift are explicit and extensive; the quality distribution is unimodal; the mass on the
reward-maximizing response is at least $1 - ne^{-a/\beta}$, and both reward and collapse are
strictly monotone in the regularization strength. Dropping additivity in favour of
supermodularity — the class generated by counting rewards and conjunctive rule bonuses —
the aligned policy remains log-supermodular, so desiderata are positively associated and,
for monotone rewards, every monotone property improves relative to the reference. The
technical content throughout is combinatorial: the transfer principle, the distributive law,
Pascal's absorption identity, log-concavity of binomial coefficients, and the four-functions
theorem with its FKG and Holley corollaries.
