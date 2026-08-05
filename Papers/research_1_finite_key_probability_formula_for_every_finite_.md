# The Uniform Threshold Coupling on a Finite Site Set: Bernoulli Realisation, Strict Monotonicity, Russo's Formula and the Harris Inequality

**Author:** Aristotle

**Date:** 2026-08-05

---

## Abstract

Let $\iota$ be a finite set of *sites* and let $x = (x_v)_{v \in \iota}$ be a family of independent random variables, each uniform on $[0,1]$. For a threshold $p \in [0,1]$ define the configuration $\Theta_p(x) \in \{0,1\}^\iota$ by declaring the site $v$ *open* precisely when $x_v \le p$. We develop, in complete detail and with no asymptotic or infinite-volume input, the theory of this *uniform threshold coupling*.

Our results are the following. (i) **Bernoulli realisation:** the law of $\Theta_p(x)$ is exactly the Bernoulli product measure of density $p$, with the explicit fibre formula $\mathbb{P}(\Theta_p(x)=\eta) = p^{|O(\eta)|}(1-p)^{|C(\eta)|}$; consequently the probability of any event is its Bernoulli polynomial, and all densities $p \in [0,1]$ are realised simultaneously on one probability space. (ii) **Monotonicity:** the coupling is pointwise monotone in $p$, so for increasing events the corresponding key sets are nested and the Bernoulli polynomial is nondecreasing. (iii) **Strict monotonicity:** for an increasing event that is nonempty and omits the all-closed configuration, the Bernoulli polynomial is *strictly* increasing on $(0,1)$; the proof exhibits an explicit box of positive measure in key space that separates the two levels. (iv) **The finite Russo formula:** the Bernoulli polynomial of an increasing event is differentiable with derivative equal to the sum over sites of the pivotal probabilities, together with a sharp criterion for strict positivity of that derivative. (v) **The Harris/FKG inequality:** the Bernoulli weight is exactly log-modular along the lattice operations, whence increasing events are positively correlated; we derive the increasing–decreasing negative correlation form, the finite-family versions on both sides, and the product form of the square-root trick. (vi) **Applications:** the horizontal crossing event of the $n \times n$ square grid is a nondegenerate increasing event, so its crossing probability $\theta_n$ is strictly increasing on $(0,1)$, satisfies Russo's formula, and is positively correlated with every increasing event; and a complete bond analogue holds on the edge set of an arbitrary finite graph. We close with exact rational values of $\theta_n(1/2)$, $\theta_n'(1/2)$ and the half-probability densities $p_n$ for $n \le 4$, and with a list of falsifiable conjectures about their asymptotics.

**Keywords:** percolation; threshold coupling; Bernoulli measure; increasing event; Russo's formula; pivotality; Harris inequality; FKG; log-supermodularity; crossing probability.

---

## 1. Introduction

### 1.1 The comparison problem

Fix a finite set $\iota$ and, for each $p \in [0,1]$, let $\mu_p$ be the product measure on $\{0,1\}^\iota$ under which the coordinates are independent and each equals $1$ ("open") with probability $p$. The basic qualitative fact of percolation theory is that if $A \subseteq \{0,1\}^\iota$ is an *increasing* event — one closed under opening additional sites — then $p \mapsto \mu_p(A)$ is nondecreasing.

Stated this way, the assertion compares the values of two *different* measures on the same finite set. Direct approaches require manipulating the two polynomials

$$\mu_p(A) = \sum_{\eta \in A} p^{|O(\eta)|}(1-p)^{|C(\eta)|}, \qquad \mu_q(A) = \sum_{\eta \in A} q^{|O(\eta)|}(1-q)^{|C(\eta)|},$$

and no term-by-term comparison is available: increasing $p$ increases some summands and decreases others. The standard remedy is a *coupling*: construct a single probability space carrying random configurations $\omega_p \sim \mu_p$ for every $p$ simultaneously, with $\omega_p \le \omega_q$ pointwise whenever $p \le q$. Then monotonicity of $\mu_\cdot(A)$ becomes a set inclusion.

### 1.2 The uniform threshold coupling

The coupling we study is the most economical possible one. Take the key space

$$\Omega = [0,1]^\iota \subseteq \mathbb{R}^\iota,$$

carrying the product $\mathbb{P}$ of $|\iota|$ copies of Lebesgue measure restricted to $[0,1]$, and define the **threshold map**

$$\Theta_p : \mathbb{R}^\iota \to \{0,1\}^\iota, \qquad \Theta_p(x)_v = \mathbf{1}[x_v \le p].$$

Two elementary observations drive everything:

* **(Fibres are boxes.)** For a prescribed target configuration $\eta$, the set $\Theta_p^{-1}(\eta)$ is the product $\prod_{v}I_v$ with $I_v = (-\infty,p]$ if $\eta_v = 1$ and $I_v = (p,\infty)$ if $\eta_v = 0$. Intersected with $[0,1]^\iota$, these are intervals of length $p$ and $1-p$.
* **(Monotone in the dial.)** If $p \le q$ then $x_v \le p \Rightarrow x_v \le q$, so $\Theta_p(x) \le \Theta_q(x)$ coordinatewise, *for every key $x$*.

The first gives the exact law; the second gives the monotone structure. This paper works out, rigorously and self-containedly, everything these two observations buy.

### 1.3 Contributions

The main results are Theorems 3.1, 4.3, 5.3, 6.5, 7.2 and their corollaries. We highlight three features.

1. **Everything is finite and exact.** No infinite volume, no limits, no continuity-of-measure arguments. All probabilities are polynomials with integer coefficients in $p$, and every statement is an identity or inequality between such polynomials.
2. **Two independent proofs of strict monotonicity.** The coupling proof (Theorem 5.3) exhibits a positive-volume box in key space; the analytic proof (Corollary 6.8) deduces it from strict positivity of the Russo derivative. The agreement is a strong consistency check on the formulation.
3. **Exact log-modularity, not merely log-supermodularity.** The Bernoulli weight satisfies $w_p(\eta)w_p(\xi) = w_p(\eta \wedge \xi)w_p(\eta \vee \xi)$ with *equality* (Lemma 7.1), which is what allows the FKG correlation inequality on the distributive lattice $\{0,1\}^\iota$ to be applied without any auxiliary positivity hypotheses.

### 1.4 Organisation

Section 2 fixes notation. Section 3 proves the fibre formula and the Bernoulli realisation. Section 4 treats monotonicity. Section 5 treats strict monotonicity. Section 6 proves the finite Russo formula. Section 7 proves the Harris inequality and its corollaries. Section 8 applies everything to crossings of the square grid, Section 9 to bond percolation. Section 10 reports exact computations, Section 11 states conjectures, Section 12 discusses scope and limits.

---

## 2. Setting and notation

Throughout, $\iota$ is a nonempty finite set whose elements are called **sites**, and $N = |\iota|$.

**Configurations.** A **configuration** is a map $\eta : \iota \to \{0,1\}$; we write $\eta_v = 1$ as "$v$ is open in $\eta$" and $\eta_v = 0$ as "$v$ is closed in $\eta$". The set of configurations is $\{0,1\}^\iota$, a finite set of size $2^N$. We write

$$O(\eta) = \{v : \eta_v = 1\}, \qquad C(\eta) = \{v : \eta_v = 0\},$$

for the open and closed sites and $|O(\eta)|, |C(\eta)|$ for their cardinalities, so $|O(\eta)| + |C(\eta)| = N$.

**The lattice.** Order configurations pointwise: $\eta \le \xi$ iff $O(\eta) \subseteq O(\xi)$. This makes $\{0,1\}^\iota$ a finite distributive lattice with meet $(\eta \wedge \xi)_v = \min(\eta_v,\xi_v)$ and join $(\eta \vee \xi)_v = \max(\eta_v,\xi_v)$, least element $\mathbf{0}$ (all closed) and greatest element $\mathbf{1}$ (all open).

**Updates.** For $v \in \iota$ and $b \in \{0,1\}$ we write $\eta^{v\to b}$ for the configuration agreeing with $\eta$ off $v$ and equal to $b$ at $v$.

**Events.** An **event** is a subset $A \subseteq \{0,1\}^\iota$. It is **increasing** if $\eta \in A$ and $\eta \le \xi$ imply $\xi \in A$; equivalently, if its indicator is a monotone function on the lattice. It is **decreasing** if its complement is increasing.

**Weights and Bernoulli polynomials.** For $p \in \mathbb{R}$ set

$$w_p(\eta) \;=\; p^{|O(\eta)|}\,(1-p)^{|C(\eta)|} \;=\; \prod_{v \in \iota} \big( \eta_v\, p + (1-\eta_v)(1-p) \big),$$

the second expression being the *product form*, valid because each factor is $p$ when $\eta_v = 1$ and $1-p$ when $\eta_v = 0$. For an event $A$ define the **Bernoulli polynomial**

$$\pi_A(p) \;=\; \sum_{\eta \in A} w_p(\eta).$$

For $p \in [0,1]$ this is $\mu_p(A)$, the probability of $A$ under the Bernoulli product measure of density $p$; for general real $p$ it is a polynomial of degree at most $N$. We record the basic facts.

**Lemma 2.1 (Normalisation and positivity).**
1. $\sum_{\eta \in \{0,1\}^\iota} w_p(\eta) = 1$ for all $p$; equivalently $\pi_{\{0,1\}^\iota}(p) = 1$.
2. If $0 \le p \le 1$ then $w_p(\eta) \ge 0$ and hence $\pi_A(p) \ge 0$.
3. If $0 < p < 1$ then $w_p(\eta) > 0$; hence $\pi_A(p) > 0$ for every nonempty $A$, and $\pi_\emptyset \equiv 0$.
4. $\pi_A(p) + \pi_{A^c}(p) = 1$, and $\pi_{A \cup B} = \pi_A + \pi_B$ when $A \cap B = \emptyset$.

*Proof.* (1) Expand $\prod_{v \in \iota}\big(p + (1-p)\big) = 1$ by distributivity: the monomials of the expansion are indexed by the choices of one factor at each site, i.e. by configurations, and the monomial attached to $\eta$ is exactly $w_p(\eta)$ in product form. (2), (3) are immediate from the product form. (4) is additivity of a finite sum over a partition, using (1) for the complement identity. $\square$

**The key space.** Let $U$ denote Lebesgue measure on $\mathbb{R}$ restricted to $[0,1]$ — a probability measure — and let

$$\mathbb{P} = U^{\otimes \iota}$$

be the product measure on $\mathbb{R}^\iota$; it is a probability measure supported on $[0,1]^\iota$. Points $x \in \mathbb{R}^\iota$ are **keys**. We record the three interval computations we need:

**Lemma 2.2.** For $0 \le p \le 1$ and $0 \le p \le q \le 1$,
$$U\big((-\infty,p]\big) = p, \qquad U\big((p,\infty)\big) = 1-p, \qquad U\big((p,q]\big) = q - p.$$

*Proof.* Intersect with $[0,1]$: $(-\infty,p]\cap[0,1] = [0,p]$, $(p,\infty)\cap[0,1] = (p,1]$, and $(p,q]\cap[0,1] = (p,q]$; then take lengths. $\square$

**The threshold map.** For $p \in \mathbb{R}$, define $\Theta_p : \mathbb{R}^\iota \to \{0,1\}^\iota$ by $\Theta_p(x)_v = \mathbf{1}[x_v \le p]$.

---

## 3. The finite-key probability formula

**Definition 3.0.** For $p \in \mathbb{R}$ and $\eta \in \{0,1\}^\iota$, the **threshold fibre** is
$$F_p(\eta) = \{x \in \mathbb{R}^\iota : \Theta_p(x) = \eta\}.$$

**Lemma 3.0 (Fibres are boxes).** $F_p(\eta) = \prod_{v \in \iota} I_v^{\eta,p}$, where $I_v^{\eta,p} = (-\infty,p]$ if $\eta_v = 1$ and $I_v^{\eta,p} = (p,\infty)$ if $\eta_v = 0$. In particular $F_p(\eta)$ is measurable.

*Proof.* $\Theta_p(x) = \eta$ holds iff for every $v$ we have $\mathbf{1}[x_v \le p] = \eta_v$, i.e. iff $x_v \le p$ when $\eta_v = 1$ and $x_v > p$ when $\eta_v = 0$. These are independent constraints, one per coordinate. Measurability follows since each $I_v^{\eta,p}$ is an interval and a product of measurable sets over a finite index set is measurable. $\square$

**Theorem 3.1 (Finite-key probability formula).** *For every $p \in [0,1]$ and every configuration $\eta$,*
$$\mathbb{P}\big(F_p(\eta)\big) \;=\; p^{|O(\eta)|}\,(1-p)^{|C(\eta)|} \;=\; w_p(\eta).$$

*Proof.* By Lemma 3.0 the fibre is a measurable box, and the product measure of a box is the product of the coordinate measures:
$$\mathbb{P}\big(F_p(\eta)\big) = \prod_{v \in \iota} U\big(I_v^{\eta,p}\big).$$
By Lemma 2.2 the factor equals $p$ when $\eta_v = 1$ and $1-p$ when $\eta_v = 0$; hence the product is $w_p(\eta)$ in product form, which equals $p^{|O(\eta)|}(1-p)^{|C(\eta)|}$ after grouping equal factors. $\square$

**Definition 3.2.** For an event $A$ and $p \in \mathbb{R}$ define the **event key set**
$$K_p(A) = \{x \in \mathbb{R}^\iota : \Theta_p(x) \in A\} = \bigcup_{\eta \in A} F_p(\eta),$$
a finite disjoint union of measurable boxes, hence measurable.

**Theorem 3.3 (Bernoulli realisation).** *For every $p \in [0,1]$ and every event $A$,*
$$\mathbb{P}\big(K_p(A)\big) \;=\; \pi_A(p).$$
*Equivalently, the pushforward of $\mathbb{P}$ under $\Theta_p$ is the Bernoulli product measure $\mu_p$ of density $p$.*

*Proof.* The union in Definition 3.2 is over the finite index set $A$ and is disjoint, since $x$ determines $\Theta_p(x)$ uniquely, so $x$ lies in at most one fibre. Finite additivity and Theorem 3.1 give $\mathbb{P}(K_p(A)) = \sum_{\eta \in A} w_p(\eta) = \pi_A(p)$. The pushforward statement is the special case $A = \{\eta\}$ together with the fact that a measure on a finite set is determined by its values on singletons. $\square$

**Remark 3.4.** Theorem 3.3 is the whole point of the construction: a *single* probability space $(\mathbb{R}^\iota,\mathbb{P})$ carries, through the family of maps $\{\Theta_p\}_{p \in [0,1]}$, exact realisations of *all* the Bernoulli measures at once. The random variables $\Theta_p$ for different $p$ are of course far from independent — indeed they are as dependent as possible, being deterministic functions of one another's underlying key — and that dependence is precisely the resource exploited below.

---

## 4. Monotonicity

**Lemma 4.1 (Pointwise monotonicity of the coupling).** *If $p \le q$ then $\Theta_p(x) \le \Theta_q(x)$ for every key $x \in \mathbb{R}^\iota$.*

*Proof.* If $\Theta_p(x)_v = 1$ then $x_v \le p \le q$, so $\Theta_q(x)_v = 1$. $\square$

**Proposition 4.2 (Nesting of key sets).** *If $A$ is increasing and $p \le q$, then $K_p(A) \subseteq K_q(A)$.*

*Proof.* Let $x \in K_p(A)$, so $\Theta_p(x) \in A$. By Lemma 4.1, $\Theta_p(x) \le \Theta_q(x)$, and $A$ is increasing, so $\Theta_q(x) \in A$, i.e. $x \in K_q(A)$. $\square$

**Theorem 4.3 (Monotonicity).** *Let $A$ be an increasing event and $0 \le p \le q \le 1$. Then*
$$\mathbb{P}\big(K_p(A)\big) \le \mathbb{P}\big(K_q(A)\big), \qquad \text{equivalently} \qquad \pi_A(p) \le \pi_A(q).$$
*That is, $\pi_A$ is nondecreasing on $[0,1]$.*

*Proof.* Monotonicity of measure applied to Proposition 4.2, then Theorem 3.3 to translate both sides. $\square$

**Remark 4.4.** Note the shape of the argument: the analytic comparison of two polynomials has been replaced by an inclusion of sets. No property of $\pi_A$ beyond Theorem 3.3 was used, and no estimate was made.

---

## 5. Strict monotonicity

Two increasing events have constant Bernoulli polynomial: $\emptyset$, with $\pi_\emptyset \equiv 0$, and any increasing event containing $\mathbf 0$, which must be all of $\{0,1\}^\iota$ and has $\pi \equiv 1$. These are exactly the obstructions.

**Definition 5.0.** An increasing event $A$ is **nondegenerate** if $A \ne \emptyset$ and $\mathbf{0} \notin A$.

**Lemma 5.1 (Existence of a pivotal configuration).** *Let $A$ be nondegenerate. Then there exist $\eta \in A$ and $v \in \iota$ with $\eta_v = 1$ and $\eta^{v \to 0} \notin A$.*

*Proof.* Since $A$ is finite and nonempty, choose $\eta \in A$ minimising $|O(\eta)|$. If $O(\eta) = \emptyset$ then $\eta = \mathbf{0} \in A$, contradicting nondegeneracy; so pick $v \in O(\eta)$. The configuration $\eta^{v\to 0}$ has $O(\eta^{v\to0}) = O(\eta)\setminus\{v\}$, strictly smaller, so by minimality $\eta^{v\to0}\notin A$. $\square$

(Note this lemma uses only that $A$ is nonempty and misses $\mathbf 0$; monotonicity of $A$ is not needed.)

**Definition 5.2 (The separating box).** Given $\eta \in \{0,1\}^\iota$, a site $v$, and reals $p \le q$, define $B(\eta,v,p,q) = \prod_{u \in \iota} J_u$ with
$$J_u = \begin{cases} (p,q] & u = v,\\ (-\infty,p] & u \ne v,\ \eta_u = 1,\\ (q,\infty) & u \ne v,\ \eta_u = 0.\end{cases}$$

The box is designed so that the key at $v$ sits *between* the two levels, while every other key is unambiguously on the same side of both levels.

**Lemma 5.2a (Behaviour of the box at the two levels).** *Assume $p \le q$ and $\eta_v = 1$, and let $x \in B(\eta,v,p,q)$. Then*
$$\Theta_q(x) = \eta \qquad\text{and}\qquad \Theta_p(x) = \eta^{v\to 0}.$$

*Proof.* Take $u \ne v$. If $\eta_u = 1$ then $x_u \le p \le q$, so $\Theta_p(x)_u = \Theta_q(x)_u = 1 = \eta_u$. If $\eta_u = 0$ then $x_u > q \ge p$, so $\Theta_p(x)_u = \Theta_q(x)_u = 0 = \eta_u$. At $u = v$ we have $p < x_v \le q$, hence $\Theta_q(x)_v = 1 = \eta_v$ while $\Theta_p(x)_v = 0$. Assembling coordinates gives the two identities. $\square$

**Lemma 5.2b (Positive volume).** *If $0 < p < q < 1$ then $\mathbb{P}\big(B(\eta,v,p,q)\big) > 0$; explicitly it equals $(q-p)\,p^{a}\,(1-q)^{b}$ where $a = |O(\eta)\setminus\{v\}|$ and $b = |C(\eta)|$.*

*Proof.* The box is a product of intervals, so its measure is the product of the $U$-measures, which by Lemma 2.2 are $q-p$ at $v$, $p$ at the other open sites, and $1-q$ at the closed sites. Each factor is strictly positive because $0 < p < q < 1$. $\square$

**Theorem 5.3 (Strict monotonicity).** *Let $A$ be a nondegenerate increasing event and let $0 < p < q < 1$. Then*
$$\mathbb{P}\big(K_p(A)\big) < \mathbb{P}\big(K_q(A)\big), \qquad \text{equivalently} \qquad \pi_A(p) < \pi_A(q).$$
*Thus $\pi_A$ is strictly increasing on $(0,1)$.*

*Proof.* By Lemma 5.1 pick $\eta \in A$ and $v$ with $\eta_v = 1$ and $\eta^{v\to0}\notin A$. Put $B = B(\eta,v,p,q)$.

*The box is disjoint from $K_p(A)$.* If $x \in B$ then $\Theta_p(x) = \eta^{v\to0} \notin A$ by Lemma 5.2a, so $x \notin K_p(A)$.

*The box lies in $K_q(A)$.* If $x \in B$ then $\Theta_q(x) = \eta \in A$ by Lemma 5.2a.

*Conclusion.* Combining with Proposition 4.2, $K_p(A) \sqcup B \subseteq K_q(A)$ with the union disjoint, so by additivity and monotonicity
$$\mathbb{P}\big(K_q(A)\big) \;\ge\; \mathbb{P}\big(K_p(A)\big) + \mathbb{P}(B) \;>\; \mathbb{P}\big(K_p(A)\big),$$
the last step by Lemma 5.2b. Theorem 3.3 translates this into the polynomial statement. $\square$

**Remark 5.4 (Quantitative form).** The proof gives more than strictness: the increment is at least the volume of the separating box,
$$\pi_A(q) - \pi_A(p) \;\ge\; (q-p)\,p^{a}\,(1-q)^{b}, \qquad a+b = N-1,$$
where $a,b$ come from a minimal configuration of $A$. This is a genuine — if typically very weak — explicit lower bound on the derivative-like increment, valid at all finite sizes. Section 6 provides the sharp version.

---

## 6. The finite Russo formula

### 6.1 Pivotality

**Definition 6.1.** For an event $A$ and a site $v$, the **pivotal set** is
$$\mathrm{Piv}_v(A) \;=\; \{\eta \in \{0,1\}^\iota : \eta^{v\to1} \in A \text{ and } \eta^{v\to0}\notin A\}.$$

**Lemma 6.2 (Pivotality ignores the state of $v$).** $\eta \in \mathrm{Piv}_v(A)$ if and only if $\eta^{v\to b} \in \mathrm{Piv}_v(A)$, for either $b \in \{0,1\}$.

*Proof.* $(\eta^{v\to b})^{v\to c} = \eta^{v\to c}$, so the defining condition is unchanged. $\square$

Thus $\mathrm{Piv}_v(A)$ is a union of $v$-fibres $\{\eta^{v\to0},\eta^{v\to1}\}$, a fact used twice below.

### 6.2 Off-weights and the derivative of a single weight

**Definition 6.3.** For $p \in \mathbb{R}$, a site $v$ and a configuration $\eta$, the **off-weight** is
$$w_p^{(v)}(\eta) = \prod_{u \ne v} \big(\eta_u\, p + (1-\eta_u)(1-p)\big),$$
the Bernoulli product weight with the factor at $v$ deleted.

**Lemma 6.4.** *For all $p, v, \eta$:*
1. $w_p(\eta) = \big(\eta_v p + (1-\eta_v)(1-p)\big)\cdot w_p^{(v)}(\eta)$;
2. $w^{(v)}_p(\eta^{v\to b}) = w^{(v)}_p(\eta)$ for $b \in \{0,1\}$;
3. $\displaystyle \frac{d}{dp}\,w_p(\eta) \;=\; \sum_{v \in \iota} \sigma_v(\eta)\, w^{(v)}_p(\eta)$, where $\sigma_v(\eta) = +1$ if $\eta_v = 1$ and $-1$ if $\eta_v = 0$.

*Proof.* (1) Split off the factor at $v$ from the product form. (2) The product defining $w^{(v)}$ does not involve the coordinate $v$. (3) Leibniz's rule for the derivative of a finite product: the derivative of the factor at $v$ is $+1$ if $\eta_v = 1$ (the factor is $p$) and $-1$ if $\eta_v = 0$ (the factor is $1-p$); the remaining factors form $w^{(v)}_p(\eta)$. $\square$

### 6.3 The pairing argument

The heart of the matter is the following cancellation lemma. Write $\mathbf{1}_A$ for the indicator of $A$.

**Lemma 6.5a (Coordinatewise pairing).** *Let $A$ be increasing and $v \in \iota$. Then*
$$\sum_{\eta \in \{0,1\}^\iota} \mathbf{1}_A(\eta)\,\sigma_v(\eta)\, w^{(v)}_p(\eta) \;=\; \pi_{\mathrm{Piv}_v(A)}(p).$$

*Proof.* Partition $\{0,1\}^\iota$ into the $2^{N-1}$ pairs $\{\zeta^{v\to0},\zeta^{v\to1}\}$ obtained by flipping the state of $v$; both members of a pair have the same off-weight $W := w^{(v)}_p(\zeta)$ by Lemma 6.4(2). The contribution of a pair to the left-hand side is
$$\big(\mathbf{1}_A(\zeta^{v\to1}) - \mathbf{1}_A(\zeta^{v\to0})\big)\,W,$$
since $\sigma_v = +1$ on the open member and $-1$ on the closed member. Because $A$ is increasing and $\zeta^{v\to0} \le \zeta^{v\to1}$, the bracket is $0$ if both or neither member lies in $A$, and $+1$ exactly when $\zeta^{v\to1}\in A$ and $\zeta^{v\to0}\notin A$, i.e. exactly when $\zeta \in \mathrm{Piv}_v(A)$. (The impossible case $-1$ is what monotonicity rules out.) Hence
$$\text{LHS} \;=\; \sum_{\zeta\text{-pairs} \,\subseteq\, \mathrm{Piv}_v(A)} w^{(v)}_p(\zeta).$$
On the other hand, by Lemma 6.2 the set $\mathrm{Piv}_v(A)$ is a union of such pairs, and for each pair, Lemma 6.4(1) gives
$$w_p(\zeta^{v\to1}) + w_p(\zeta^{v\to0}) \;=\; p\,W + (1-p)\,W \;=\; W .$$
Summing over the pairs contained in $\mathrm{Piv}_v(A)$ therefore yields exactly $\pi_{\mathrm{Piv}_v(A)}(p)$. $\square$

**Theorem 6.5 (Finite Russo formula).** *Let $A$ be an increasing event. Then $p \mapsto \pi_A(p)$ is differentiable (indeed a polynomial) and for every $p \in \mathbb{R}$,*
$$\pi_A'(p) \;=\; \sum_{v \in \iota} \pi_{\mathrm{Piv}_v(A)}(p).$$
*For $p \in [0,1]$ the right-hand side is $\sum_v \mu_p\big(v \text{ is pivotal for } A\big)$, i.e. the expected number of pivotal sites.*

*Proof.* $\pi_A = \sum_{\eta} \mathbf 1_A(\eta) w_p(\eta)$ is a finite sum of polynomials, so differentiation passes through the sum:
$$\pi_A'(p) = \sum_{\eta} \mathbf 1_A(\eta)\, \frac{d}{dp} w_p(\eta) = \sum_{\eta}\mathbf 1_A(\eta)\sum_{v}\sigma_v(\eta)w^{(v)}_p(\eta)$$
by Lemma 6.4(3). Exchange the two finite sums and apply Lemma 6.5a to the inner sum for each $v$. $\square$

### 6.4 Consequences

**Corollary 6.6 (Monotonicity, analytically).** *If $A$ is increasing then $\pi_A'(p) \ge 0$ for all $p \in [0,1]$, so $\pi_A$ is nondecreasing there.*

*Proof.* Each summand $\pi_{\mathrm{Piv}_v(A)}(p)$ is nonnegative by Lemma 2.1(2). $\square$

**Theorem 6.7 (Criterion for strict positivity of the derivative).** *Let $A$ be increasing and $0 < p < 1$. Then*
$$\pi_A'(p) > 0 \iff \exists\, v \in \iota \text{ with } \mathrm{Piv}_v(A) \ne \emptyset.$$

*Proof.* ($\Leftarrow$) If $\mathrm{Piv}_v(A) \ne \emptyset$ then $\pi_{\mathrm{Piv}_v(A)}(p) > 0$ by Lemma 2.1(3), and all other terms of the Russo sum are $\ge 0$. ($\Rightarrow$) If every pivotal set is empty then every term is $\pi_\emptyset(p) = 0$, so $\pi_A'(p) = 0$. $\square$

**Corollary 6.8 (Strict monotonicity, second proof).** *If $A$ is a nondegenerate increasing event then $\pi_A'(p) > 0$ for all $p \in (0,1)$, and hence $\pi_A$ is strictly increasing on $(0,1)$.*

*Proof.* By Lemma 5.1 there are $\eta \in A$ and $v$ with $\eta_v = 1$ and $\eta^{v\to0}\notin A$. Since $\eta_v=1$ we have $\eta^{v\to1} = \eta \in A$, so $\eta \in \mathrm{Piv}_v(A)$, which is therefore nonempty; apply Theorem 6.7 and the mean value theorem. $\square$

**Remark 6.9.** Corollary 6.8 and Theorem 5.3 prove the same statement by wholly different means: one by exhibiting a positive-measure box in key space, the other by a signed cancellation over configuration pairs. The pivotal configuration produced by Lemma 5.1 is the common input.

**Remark 6.10 (Uniform bound).** Since the pivotal sets are $2^{N-1}$-fold unions of pairs and each $\pi_{\mathrm{Piv}_v(A)}(p) \le 1$, we get the crude but universal bound $0 \le \pi_A'(p) \le N$ on $[0,1]$ for increasing $A$. Sharper bounds on $\pi_A'$ at $p=1/2$ are the subject of the sharp-threshold literature and of Conjecture 1 below.

---

## 7. The Harris/FKG inequality

### 7.1 Exact log-modularity

**Lemma 7.1 (Log-modularity of the Bernoulli weight).** *For every $p \in \mathbb{R}$ and all configurations $\eta,\xi$,*
$$w_p(\eta)\,w_p(\xi) \;=\; w_p(\eta \wedge \xi)\,w_p(\eta \vee \xi).$$

*Proof.* Both sides are products over sites, so it suffices to check the identity factorwise. At a site $v$, the left-hand factor pair is $(f(\eta_v), f(\xi_v))$ with $f(1) = p$, $f(0) = 1-p$, and the right-hand pair is $(f(\min(\eta_v,\xi_v)), f(\max(\eta_v,\xi_v)))$. But $\{\min(a,b),\max(a,b)\} = \{a,b\}$ as multisets for $a,b \in \{0,1\}$, so the two products of two numbers coincide. Multiplying over $v$ gives the claim. $\square$

Log-modularity is equality in the log-supermodularity condition $w(\eta)w(\xi)\le w(\eta\wedge\xi)w(\eta\vee\xi)$, which is the hypothesis of the Fortuin–Kasteleyn–Ginibre correlation inequality on a finite distributive lattice. We record the form we use.

**Theorem 7.FKG (FKG inequality; classical).** *Let $L$ be a finite distributive lattice and $\nu : L \to [0,\infty)$ satisfy $\nu(a)\nu(b) \le \nu(a\wedge b)\nu(a\vee b)$ for all $a,b$. Then for all nonnegative monotone nondecreasing $f,g : L \to \mathbb{R}$,*
$$\Big(\sum_{a} \nu(a)\Big)\Big(\sum_a \nu(a) f(a) g(a)\Big) \;\ge\; \Big(\sum_a \nu(a) f(a)\Big)\Big(\sum_a \nu(a) g(a)\Big).$$

### 7.2 Harris

**Theorem 7.2 (Harris inequality on a finite site set).** *Let $A,B$ be increasing events and $p \in [0,1]$. Then*
$$\pi_A(p)\,\pi_B(p) \;\le\; \pi_{A\cap B}(p).$$
*Equivalently, in key form, $\mathbb{P}(K_p(A))\,\mathbb{P}(K_p(B)) \le \mathbb{P}(K_p(A)\cap K_p(B))$.*

*Proof.* Apply Theorem 7.FKG on the distributive lattice $L = \{0,1\}^\iota$ with $\nu = w_p$ (nonnegative by Lemma 2.1(2), log-supermodular — with equality — by Lemma 7.1), and with $f = \mathbf 1_A$, $g = \mathbf 1_B$. These indicators are nonnegative and monotone nondecreasing precisely because $A$ and $B$ are increasing. The total mass $\sum_a \nu(a)$ equals $1$ by Lemma 2.1(1), so the conclusion reads
$$\sum_\eta w_p(\eta)\mathbf 1_A(\eta)\mathbf 1_B(\eta) \;\ge\; \Big(\sum_\eta w_p(\eta)\mathbf 1_A(\eta)\Big)\Big(\sum_\eta w_p(\eta)\mathbf 1_B(\eta)\Big),$$
and $\mathbf 1_A \mathbf 1_B = \mathbf 1_{A\cap B}$ gives the left-hand side as $\pi_{A\cap B}(p)$. The key form follows from Theorem 3.3 together with the identity $K_p(A\cap B) = K_p(A)\cap K_p(B)$, which holds because $\Theta_p(x)\in A\cap B$ iff $\Theta_p(x)\in A$ and $\Theta_p(x)\in B$. $\square$

### 7.3 Corollaries

Throughout, $p \in [0,1]$.

**Corollary 7.3 (Stability of increasingness).** The intersection and the union of increasing events are increasing; $\{0,1\}^\iota$ is increasing; and for a finite family $(A_k)_{k\in S}$ of increasing events, both $\bigcap_{k\in S}A_k$ and $\bigcup_{k \in S}A_k$ are increasing.

*Proof.* Immediate from the definition, applied membershipwise. $\square$

**Corollary 7.4 (Increasing versus decreasing: negative correlation).** *If $A, B$ are increasing then*
$$\pi_{A\cap B^c}(p) \;\le\; \pi_A(p)\,\pi_{B^c}(p).$$

*Proof.* Partition $A = (A\cap B)\sqcup(A\cap B^c)$ and use additivity (Lemma 2.1(4)): $\pi_{A\cap B^c} = \pi_A - \pi_{A\cap B}$. By Theorem 7.2, $\pi_{A\cap B} \ge \pi_A\pi_B$, so
$$\pi_{A\cap B^c} \le \pi_A - \pi_A\pi_B = \pi_A(1-\pi_B) = \pi_A\,\pi_{B^c},$$
using $\pi_{B^c} = 1-\pi_B$. $\square$

**Corollary 7.5 (Finite families, increasing side).** *If $A_1,\dots,A_m$ are increasing then*
$$\prod_{k=1}^m \pi_{A_k}(p) \;\le\; \pi_{\bigcap_{k}A_k}(p).$$

*Proof.* Induction on $m$. For $m=0$ both sides are $1$. For the inductive step, $\bigcap_{k\le m+1}A_k = A_{m+1}\cap\bigcap_{k\le m}A_k$; the inner intersection is increasing by Corollary 7.3, so Theorem 7.2 gives $\pi_{A_{m+1}}\cdot\pi_{\bigcap_{k\le m}A_k} \le \pi_{\bigcap_{k\le m+1}A_k}$, and the inductive hypothesis bounds $\pi_{\bigcap_{k\le m}A_k}$ from below by $\prod_{k\le m}\pi_{A_k}$; multiply by $\pi_{A_{m+1}} \ge 0$. $\square$

**Corollary 7.6 (Finite families, decreasing side).** *If $A_1,\dots,A_m$ are increasing then*
$$\prod_{k=1}^m \pi_{A_k^c}(p) \;\le\; \pi_{\bigcap_k A_k^c}(p).$$

*Proof.* Induction again. Writing $\bigcap_{k\le m}A_k^c = \big(\bigcup_{k\le m}A_k\big)^c$ and noting that $\bigcup_{k\le m}A_k$ is increasing (Corollary 7.3), the inductive step follows from Corollary 7.4 applied with $B = \bigcup_{k\le m}A_k$, after using the inductive hypothesis inside. $\square$

**Corollary 7.7 (Square-root trick, product form).** *If $A_1,\dots,A_m$ are increasing then*
$$\prod_{k=1}^m \big(1 - \pi_{A_k}(p)\big) \;\le\; 1 - \pi_{\bigcup_k A_k}(p).$$
*In particular, if all the $A_k$ have the same probability $\alpha$ and their union has probability at least $1-\varepsilon$, then $\alpha \ge 1 - \varepsilon^{1/m}$.*

*Proof.* Apply Corollary 7.6 and rewrite both sides with $\pi_{E^c} = 1-\pi_E$, using $\bigcap_k A_k^c = (\bigcup_k A_k)^c$. The "in particular" is $(1-\alpha)^m \le \varepsilon$. $\square$

**Remark 7.8.** Corollary 7.7 is the mechanism behind the classical square-root trick: given a union of $m$ symmetric increasing events that is likely, one of them must individually be nearly as likely as an $m$-th-root-of-the-failure-probability bound allows. In percolation it converts "some crossing exists" into "this particular crossing exists with probability bounded below".

---

## 8. Crossings of the square grid

**Definition 8.1 (The grid and its crossing event).** For $n \ge 1$, let the site set be $\iota_n = \{0,\dots,n-1\}^2$, and let $G_n$ be the graph on $\iota_n$ in which $(i,j)$ and $(i',j')$ are adjacent iff they differ by $1$ in exactly one coordinate and agree in the other. For a configuration $\eta$, say $\eta$ has a **horizontal crossing** if there exist $a,b \in \{0,\dots,n-1\}$ and a walk in $G_n$ from $(0,a)$ to $(n-1,b)$ all of whose sites (including endpoints) are open in $\eta$. Let $H_n$ be the set of such $\eta$, and put
$$\theta_n(p) = \pi_{H_n}(p).$$

**Proposition 8.2.** *$H_n$ is a nondegenerate increasing event on $\iota_n$.*

*Proof.* *Increasing:* a witnessing walk for $\eta$ remains a witnessing walk for any $\xi \ge \eta$, since every site on it is open in $\eta$ and hence in $\xi$. *Nonempty:* in the all-open configuration, the straight walk $(0,0),(1,0),\dots,(n-1,0)$ along a fixed column is a valid crossing (each consecutive pair differs by $1$ in the first coordinate). *Misses $\mathbf 0$:* a walk always contains its starting site in its support, and in $\mathbf 0$ no site is open, so no walk can have all its sites open. $\square$

**Theorem 8.3 (Grid crossing probabilities).** *For every $n \ge 1$:*
1. $\theta_n$ *is nondecreasing on $[0,1]$, with $\theta_n(0) = 0$ and $\theta_n(1)=1$;*
2. $\theta_n$ *is strictly increasing on $(0,1)$: if $0<p<q<1$ then $\theta_n(p) < \theta_n(q)$;*
3. $\theta_n'(p) = \sum_{v \in \iota_n} \mu_p\big(v \text{ pivotal for } H_n\big)$, and this is $>0$ for $p \in (0,1)$;
4. *for every increasing event $B$ on $\iota_n$ and every $p\in[0,1]$, $\theta_n(p)\,\pi_B(p) \le \pi_{H_n\cap B}(p)$;*
5. *in particular, for every site $v$, $p\,\theta_n(p) \le \mu_p\big(H_n \cap \{\eta : \eta_v = 1\}\big)$; conditionally on a crossing, each site is open with probability at least $p$.*

*Proof.* (1) Theorem 4.3 and Proposition 8.2; the endpoint values are $\mathbf{0}\notin H_n$ and $\mathbf 1 \in H_n$. (2) Theorem 5.3. (3) Theorem 6.5 and Corollary 6.8. (4) Theorem 7.2. (5) Take $B = \{\eta : \eta_v = 1\}$, which is increasing, and note $\pi_B(p) = p$: indeed, pairing each configuration with its flip at $v$, the weights of the $v$-open members of the pairs sum to $p\sum_\zeta w^{(v)}_p(\zeta) = p$, since the off-weights over a transversal of the pairs sum to $1$ (Lemma 2.1(1) applied on $\iota\setminus\{v\}$). $\square$

Statement (5) is the quantitative version of "a crossing makes every site more likely to be open".

---

## 9. The bond analogue

Nothing in Sections 2–7 used any structure on $\iota$ beyond finiteness. Taking $\iota$ to be the set of *edges* rather than vertices yields bond percolation for free.

**Definition 9.1.** Let $V$ be a finite vertex set and let $E = \{\{u,v\} : u,v\in V\}$ be the set of unordered pairs. A **bond configuration** is $\omega : E \to \{0,1\}$; edges with $\omega_e=1$ are *open*. Given a graph $G$ on $V$, say $u$ and $v$ are **bond-connected** in $\omega$ if there is a walk in $G$ from $u$ to $v$ all of whose traversed edges are open in $\omega$.

**Theorem 9.2 (Bond analogue).** *Let $x = (x_e)_{e \in E}$ be independent uniform $[0,1]$ keys and $\Theta_p(x)_e = \mathbf{1}[x_e \le p]$. Then for every $p \in [0,1]$:*
1. $\mathbb{P}(\Theta_p(x) = \omega) = p^{|O(\omega)|}(1-p)^{|C(\omega)|}$ *for every bond configuration $\omega$;*
2. $\mathbb{P}(\Theta_p(x) \in A) = \pi_A(p)$ *for every bond event $A$, so the coupling realises all Bernoulli bond measures simultaneously;*
3. *for increasing bond events, all of Theorems 4.3, 5.3, 6.5 and 7.2 hold verbatim;*
4. *for any graph $G$ and vertices $u,v$, the event $\{\omega : u \leftrightarrow v \text{ in } \omega\}$ is increasing, so $p \mapsto \mathbb{P}_p(u\leftrightarrow v)$ is nondecreasing on $[0,1]$, and $\frac{d}{dp}\mathbb{P}_p(u\leftrightarrow v)$ is the expected number of pivotal edges.*

*Proof.* Items (1)–(3) are Theorems 3.1, 3.3, 4.3, 5.3, 6.5, 7.2 applied with $\iota := E$, a finite set. For (4), increasingness: a witnessing open walk for $\omega$ remains one for any $\omega' \ge \omega$. $\square$

**Remark 9.3.** Nondegeneracy in the bond setting requires care: $\{u \leftrightarrow v\}$ contains the all-closed configuration when $u = v$ (a length-zero walk), in which case the probability is the constant $1$; for $u \ne v$ in the same component of $G$ the event is nondegenerate and the probability is strictly increasing on $(0,1)$; for $u,v$ in different components of $G$ the event is empty.

---

## 10. Exact computations

The crossing polynomials $\theta_n$ of Definition 8.1 can be computed exactly for small $n$ by enumerating all $2^{n^2}$ configurations, testing connectivity by breadth-first search from the first row, and accumulating the weight $p^{k}(1-p)^{n^2-k}$ as a rational polynomial. The derivative is obtained either by differentiating the polynomial or, independently, by the pivotal census of Theorem 6.5 — the two agree, which is a useful check on both the formula and the implementation.

$$\theta_1(p) = p, \qquad \theta_2(p) = 2p^2 - p^4 = p^2(2-p^2),$$
$$\theta_3(p) = 3p^3 + 4p^4 - 6p^5 - 9p^6 + 14p^7 - 6p^8 + p^9.$$

At the symmetric point $p = 1/2$:

| $n$ | $\theta_n(1/2)$ | decimal | $\theta_n'(1/2)$ | decimal | $p_n$ with $\theta_n(p_n)=1/2$ |
|---|---|---|---|---|---|
| $1$ | $1/2$ | $0.50000$ | $1$ | $1.00000$ | $0.50000$ |
| $2$ | $7/16$ | $0.43750$ | $3/2$ | $1.50000$ | $0.54120$ |
| $3$ | $197/512$ | $0.38477$ | $481/256$ | $1.87891$ | $0.55930$ |
| $4$ | $22193/65536$ | $0.33864$ | $4441/2048$ | $2.16846$ | — |

Three features are visible and consistent with the general theory. The values $\theta_n(1/2)$ decrease, indicating that $p=1/2$ is subcritical for site percolation on the square lattice. The derivatives $\theta_n'(1/2)$ increase, so the transition sharpens with $n$; by Remark 6.10 they are bounded above by $n^2$, and empirically by the much smaller $n$. The half-probability densities $p_n$ increase toward the (numerically determined, closed-form-unknown) site-percolation threshold $p_c \approx 0.5927$ of the square lattice. The strict monotonicity of Theorem 8.3(2) guarantees that each $p_n$ is *unique*, since $\theta_n$ is a strictly increasing continuous bijection from $[0,1]$ onto $[0,1]$.

---

## 11. Conjectures

The following statements are consistent with the exact data above and with the general theory, but are not proved here. Each is falsifiable by a single computation.

**Conjecture 1 (Size of the Russo derivative for grid crossings).** The sequence $\theta_n'(1/2)$ is strictly increasing in $n$ and satisfies $\theta_n'(1/2) \le n$ for all $n \ge 1$. (Data: $1$, $3/2$, $481/256 \approx 1.879$, $4441/2048\approx 2.168$.)

**Conjecture 2 (Decay of the crossing density at $p=1/2$).** $\theta_n(1/2) < 1/2$ for all $n \ge 2$; the sequence $\theta_n(1/2)$ is strictly decreasing and tends to $0$; and the unique root $p_n$ of $\theta_n(p)=1/2$ satisfies $p_n > 1/2$ for $n\ge2$ and is increasing in $n$.

**Conjecture 3 (Sharp-threshold rate).** There are constants $c, C > 0$ with $c\log n \le \theta_n'(p_n) \le C n$ for all $n \ge 2$; more ambitiously, $\theta_n'(p_n) = n^{1/\nu + o(1)}$ for a correlation-length exponent $\nu$.

---

## 12. Discussion

### 12.1 What the coupling does and does not do

The uniform threshold coupling is a *monotone* coupling: it produces, on one space, a family of configurations increasing in $p$. Such a coupling exists whenever one has a stochastically ordered family, by Strassen's theorem; the point here is that this particular one is completely explicit, requires no choice, and its fibres are boxes, which makes every computation a product of interval lengths. The price is that the coupling is very rigid: it couples all the densities in the *same* way at every site, which is exactly what one wants for monotonicity but is not the right tool for, say, comparing two different graphs.

### 12.2 Relation to the classical statements

Theorem 6.5 is the finite, purely algebraic form of Russo's formula. The classical statement is usually phrased for a monotone event depending on finitely many coordinates of an infinite product space, with the derivative taken in the parameter of the product measure; on a finite site set the analytic subtleties evaporate and one is left with the combinatorial identity proved here. Similarly Theorem 7.2 is Harris's inequality for independent Bernoulli bits; the FKG inequality generalises it to arbitrary log-supermodular measures on distributive lattices, and Lemma 7.1 records that Bernoulli product weights sit at the extreme case of *equality* in the log-supermodularity hypothesis.

### 12.3 Sharpness of hypotheses

Nondegeneracy in Theorem 5.3 is not removable: $\pi_\emptyset \equiv 0$ and $\pi_{\{0,1\}^\iota}\equiv 1$ are the two constant Bernoulli polynomials of increasing events, and Lemma 5.1 shows they are the only obstructions. Restricting to the open interval $(0,1)$ is also necessary: at $p=0$ and $p=1$ the measures are Dirac masses and no separating box of positive volume exists. Monotonicity of $A$ is essential in Lemma 6.5a: for a non-monotone event, split pairs can occur with the *closed* twin inside $A$, contributing $-w^{(v)}$, and the derivative is then a difference of two pivotal-type sums rather than a sum of probabilities.

### 12.4 Scope

Because the site set is an arbitrary finite set, the results apply unchanged to: site percolation on any finite graph; bond percolation via Section 9; random subgraph models such as $G(n,p)$, where the sites are the $\binom n2$ possible edges and events like "connected", "contains a triangle", "has a Hamilton cycle" are increasing; network reliability, where $\pi_A$ is the reliability polynomial; and the analysis of monotone Boolean functions, where $\pi_A$ is the noise-parameterised acceptance probability and Theorem 6.5 computes its derivative as total influence at $p$.

### 12.5 Future work

Beyond the conjectures of Section 11, three directions seem natural. First, a *sharp-threshold* statement in the spirit of Friedgut–Kalai, quantifying how the Russo derivative at the critical point grows with symmetry of the event; the ingredients (Russo's formula, Harris) are all in place. Second, the *BK inequality*, the disjoint-occurrence counterpart of Harris, which is proved by an entirely different (van den Berg–Kesten) argument and would complete the pair of correlation inequalities. Third, *duality*: the planar self-duality that makes $p=1/2$ exactly critical for bond percolation on the square lattice has a combinatorial finite-$n$ form, and combining it with the strict monotonicity proved here would give an exact identification of a self-dual crossing probability at every finite $n$.

---

## Appendix A: Summary of the main statements

For a finite site set $\iota$ with independent uniform $[0,1]$ keys and thresholds $\Theta_p$:

1. **Fibre formula.** $\mathbb{P}(\Theta_p = \eta) = p^{|O(\eta)|}(1-p)^{|C(\eta)|}$ for $p \in [0,1]$.
2. **Bernoulli realisation.** $\mathbb{P}(\Theta_p \in A) = \pi_A(p)$; all densities are realised on one space.
3. **Pointwise monotonicity.** $p \le q \Rightarrow \Theta_p(x) \le \Theta_q(x)$ for every key $x$.
4. **Monotonicity.** $A$ increasing $\Rightarrow$ $\pi_A$ nondecreasing on $[0,1]$.
5. **Strict monotonicity.** $A$ increasing, nonempty, $\mathbf 0 \notin A$ $\Rightarrow$ $\pi_A$ strictly increasing on $(0,1)$, with the explicit increment bound of Remark 5.4.
6. **Russo.** $A$ increasing $\Rightarrow$ $\pi_A'(p) = \sum_v \pi_{\mathrm{Piv}_v(A)}(p)$; positive on $(0,1)$ iff some pivotal set is nonempty.
7. **Log-modularity.** $w_p(\eta)w_p(\xi) = w_p(\eta\wedge\xi)w_p(\eta\vee\xi)$.
8. **Harris.** $A,B$ increasing $\Rightarrow \pi_A\pi_B \le \pi_{A\cap B}$; plus the negative-correlation, finite-family and square-root-trick corollaries.
9. **Grid.** $\theta_n$ strictly increasing on $(0,1)$; $\theta_n' = $ pivotal census; $p\,\theta_n(p) \le \mu_p(H_n \cap \{v \text{ open}\})$.
10. **Bonds.** All of the above with $\iota$ the edge set of a finite graph; connectivity probabilities are nondecreasing in $p$.
