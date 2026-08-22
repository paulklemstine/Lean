# Rigidity and Strict Subadditivity of the Universal Coding Price

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

For a class of probability laws $\{p_\theta\}_{\theta\in\Theta}$ on a finite message
space $\mathcal{X}$, the minimax pointwise regret of universal coding equals
$\log_2 C_S$, where $C_S = \sum_{x}\sup_\theta p_\theta(x)$ is the Shtarkov sum of
the class. The elementary bounds $1 \le C_S \le |\Theta|$ have been known since the
subject began; this paper carries out the corresponding **equality analysis**, and
then cashes it in for the memoryless class.

The organising observation is an exact conservation law: for a finite class,
$C_S + \Omega = |\Theta|$, where
$\Omega = \sum_x\big(\sum_\theta p_\theta(x) - \max_\theta p_\theta(x)\big) \ge 0$ is
the *overlap* — the probability mass shared by the sources. From this identity we
derive: (i) $C_S = |\Theta|$ if and only if the sources are mutually singular,
equivalently if and only if they admit pairwise disjoint full-mass supports;
(ii) $C_S = 1$ if and only if all sources coincide; (iii) the exact two-source
formula $C_S = 1 + d_{\mathrm{TV}}(p,q)$; (iv) a total-variation sandwich
$1 + \max_{\theta\ne\theta'} d_{\mathrm{TV}} \le C_S \le 1 + \sum_\theta d_{\mathrm{TV}}(p_\theta,p_{\theta_0})$;
(v) stability of the upper endpoint, $C_S \le |\Theta| - 1 + d_{\mathrm{TV}}(p_\theta,p_{\theta'})$,
and an all-pairs version bounding the total pairwise affinity by
$|\Theta|(|\Theta|-1)\,\Omega$; (vi) the equality case of the monotonicity law under
parameter pruning; and (vii) the equality case of the sufficient-statistic (method
of types) bound.

The same "sum of a pointwise inequality" analysis applied to the tied-product
construction yields the central structural theorem: for two source families indexed
by a *common* parameter, $C_S(\mathrm{tied}) = C_S^{(1)}C_S^{(2)}$ holds if and only
if every pair of block outcomes admits a common maximum-likelihood parameter. A
finiteness-free strict variant, driven by a *quantitative* deficiency at a single
outcome pair, transfers the criterion to continuous parameter spaces.

Applying it to the memoryless (i.i.d.) class on an alphabet $\mathcal{A}$ with
$m = |\mathcal{A}| \ge 2$ letters, we show: the length-one class sits exactly at the
upper rigid endpoint, $C_S(1) = m$; the length-$(n_1+n_2)$ class is isomorphic to the
tied product of its two blocks; the two constant strings $a^{n_1}$ and $b^{n_2}$ on
distinct letters have tied envelope at most $1/4$ against a separate-envelope product
of $1$; hence
$$C_S(n_1+n_2) < C_S(n_1)\,C_S(n_2) \quad (n_1,n_2 \ge 1),$$
the minimax regret is strictly subadditive in block length, and
$$C_S(n) < m^n \quad \text{for all } n \ge 2.$$
Universal coding of a memoryless source is strictly cheaper than treating every
symbol as carrying its own free parameter, and the saving is realised anew at every
split.

**Keywords:** universal coding, Shtarkov sum, normalised maximum likelihood, minimax
regret, rigidity, total variation distance, mutual singularity, strict subadditivity,
memoryless sources, method of types.

---

## 1. Introduction

### 1.1 The problem

Let $\mathcal{X}$ be a finite set of messages and let $\mathcal{P} = \{p_\theta\}_{\theta\in\Theta}$
be a family of probability distributions on $\mathcal{X}$ — a *source class*. A coder
who knows the true $\theta$ can achieve codelength $\log_2(1/p_\theta(x))$ on message
$x$; a universal coder, who does not, must commit in advance to a single distribution
$q$ and pay $\log_2(1/q(x))$. The **pointwise regret** of $q$ on $x$ relative to the
best member of the class *in hindsight* is
$$R(q,x) \;=\; \log_2\frac{\sup_{\theta} p_\theta(x)}{q(x)}.$$

Shtarkov's theorem states that the minimax value $\min_q \max_x R(q,x)$ is attained by
the **normalised maximum likelihood** (NML) distribution
$$q^\star(x) \;=\; \frac{\sup_\theta p_\theta(x)}{C_S}, \qquad
C_S \;=\; C_S(\mathcal{P}) \;=\; \sum_{x\in\mathcal{X}} \sup_{\theta\in\Theta} p_\theta(x),$$
and that its value is $\log_2 C_S$, achieved *equally* at every message. The quantity
$C_S$ — the **Shtarkov sum**, or the *price of universality* in its multiplicative
form — is therefore the single scalar summarising the worst-case cost of ignorance
about $\theta$.

Two universal bounds are immediate:

* **Lower.** For any fixed $\theta_0$, $C_S \ge \sum_x p_{\theta_0}(x) = 1$.
* **Upper.** For a finite class, $\sup_\theta p_\theta(x) \le \sum_\theta p_\theta(x)$,
  so $C_S \le |\Theta|$; in bits, one never pays more than $\log_2|\Theta|$, the cost
  of naming the source outright.

Both bounds are attained. The question this paper answers is *when*, and *by how much
one misses* when one does not.

### 1.2 Contributions

1. **A conservation law** (§3) that converts the inequality $C_S \le |\Theta|$ into an
   exact identity, with the deficiency identified as a natural "shared-mass" functional.
2. **Rigidity** at both endpoints (§4), including support-partition and bit-level
   restatements.
3. **Exact and approximate total-variation formulas** (§5): $C_S = 1 + d_{\mathrm{TV}}$
   for pairs; sandwich bounds and stability estimates for general classes.
4. **Equality analysis of the structural laws** (§6, §8): monotonicity under parameter
   pruning, the tied-product (subadditivity) induction, and the sufficient-statistic
   bound.
5. **Strict subadditivity of the memoryless price** (§7): a quantitative,
   finiteness-free application yielding $C_S(n_1+n_2) < C_S(n_1)C_S(n_2)$ and
   $C_S(n) < m^n$ for $n \ge 2$.
6. **Algorithms** (§9) for exact evaluation of $C_S$ via the method of types, together
   with numerical corroboration.

---

## 2. Setting and basic notions

Throughout, $\mathcal{X}$ is a finite non-empty set and $\Theta$ a non-empty index set,
finite where indicated.

> **Definition 2.1 (Source class).** A *source class* on $\mathcal{X}$ with parameter
> set $\Theta$ is a family $p : \Theta \times \mathcal{X} \to \mathbb{R}$ with
> $p_\theta(x)\ge 0$ for all $\theta,x$ and $\sum_{x} p_\theta(x) = 1$ for all $\theta$.

> **Definition 2.2 (Maximum-likelihood envelope).** The *envelope* of a source class is
> $\widehat{p}(x) = \sup_{\theta\in\Theta} p_\theta(x)$. It satisfies
> $0 \le \widehat p(x) \le 1$, $p_\theta(x) \le \widehat p(x)$ for every $\theta$, and
> $\widehat p(x) \le c$ whenever $p_\theta(x) \le c$ for all $\theta$.

> **Definition 2.3 (Shtarkov sum, price of universality).**
> $C_S = \sum_{x\in\mathcal{X}} \widehat p(x)$, and the *price of universality* in bits
> is $\log_2 C_S$.

Basic facts used freely: $C_S \ge 1$ (hence $C_S > 0$ and $\log_2 C_S \ge 0$); if all
sources have the same law then $C_S = 1$; and $C_S \le |\Theta|$ when $\Theta$ is
finite.

> **Definition 2.4 (Total variation distance).** For laws $p,q$ on $\mathcal{X}$,
> $d_{\mathrm{TV}}(p,q) = \tfrac12\sum_x |p(x)-q(x)| \in [0,1]$. The *affinity* of the
> pair is $1 - d_{\mathrm{TV}}(p,q) = \sum_x \min(p(x),q(x))$.

> **Definition 2.5 (Tied product).** Given source classes $\mathcal{P}^{(1)}$ on
> $\mathcal{X}_1$ and $\mathcal{P}^{(2)}$ on $\mathcal{X}_2$ *sharing the same parameter
> set* $\Theta$, their *tied product* is the class on $\mathcal{X}_1\times\mathcal{X}_2$
> with $p_\theta(x_1,x_2) = p^{(1)}_\theta(x_1)\,p^{(2)}_\theta(x_2)$.

> **Definition 2.6 (Memoryless class).** Let $\mathcal{A}$ be a finite alphabet,
> $m = |\mathcal{A}|$, and let $\Delta(\mathcal{A}) = \{\theta : \mathcal{A}\to[0,1],\ \sum_a \theta(a) = 1\}$
> be the parameter simplex. The *memoryless class of block length $n$* is the family on
> $\mathcal{A}^n$ with $p_\theta(x) = \prod_{i=1}^n \theta(x_i)$. We write $C_S(n)$ for
> its Shtarkov sum. Its parameter set is continuous.

> **Definition 2.7 (Point mass in the simplex).** For $a \in \mathcal{A}$, the point mass
> $\delta_a \in \Delta(\mathcal{A})$ is $\delta_a(b) = \mathbf{1}[b = a]$.

Two elementary simplex facts will be used repeatedly, both immediate from
non-negativity and $\sum_b\theta(b)=1$: $\theta(a) \le 1$ for every letter $a$; and
$\theta(a)+\theta(b) \le 1$ for distinct letters $a\ne b$.

---

## 3. The conservation law

> **Definition 3.1 (Overlap).** For a finite class,
> $$\Omega \;=\; \sum_{x\in\mathcal{X}}\Big(\sum_{\theta\in\Theta} p_\theta(x) - \widehat p(x)\Big).$$

Each summand is non-negative because $\widehat p(x) = \max_\theta p_\theta(x)$ is one of
the terms of the inner sum and the rest are non-negative; hence $\Omega \ge 0$. $\Omega$
is the total probability mass *not* claimed by the locally best source: the mass the
class shares.

> **Theorem 3.2 (Conservation law).** For a finite class with $k = |\Theta|$ sources,
> $$C_S + \Omega = k.$$

*Proof.* Add the two sums termwise: for each $x$,
$\widehat p(x) + \big(\sum_\theta p_\theta(x) - \widehat p(x)\big) = \sum_\theta p_\theta(x)$.
Summing over $x$ and exchanging the order of summation gives
$\sum_\theta \sum_x p_\theta(x) = \sum_\theta 1 = k$. $\square$

The inequality $C_S \le k$ is exactly the statement $\Omega \ge 0$; the conservation law
tells us that the *deficiency* $k - C_S$ is a meaningful quantity in its own right, and
every result below is a statement about it.

---

## 4. Rigidity at the endpoints

### 4.1 The upper endpoint

> **Definition 4.1 (Mutual singularity).** A class is *mutually singular* if for every
> message $x$ and every pair $\theta \ne \theta'$, at least one of $p_\theta(x)$,
> $p_{\theta'}(x)$ vanishes.

> **Lemma 4.2 (Pointwise rigidity).** For a finite class and a fixed message $x$,
> $\widehat p(x) = \sum_\theta p_\theta(x)$ if and only if at most one source charges $x$.

*Proof sketch.* ($\Rightarrow$) Let $\theta_0$ attain the maximum (finiteness gives
attainment). Then $\sum_{\theta\ne\theta_0} p_\theta(x) = 0$, and since all terms are
non-negative every one of them vanishes; hence any two distinct indices include at least
one with zero mass. ($\Leftarrow$) If all sources vanish at $x$ both sides are $0$;
otherwise the unique charging source $\theta_0$ realises both the maximum and the total.
$\square$

> **Theorem 4.3 (Rigidity of the maximal price).** For a finite class,
> $C_S = k$ if and only if the class is mutually singular.

*Proof.* By Theorem 3.2, $C_S = k$ iff $\Omega = 0$. Since $\Omega$ is a sum of
non-negative terms, $\Omega = 0$ iff each term vanishes, which by Lemma 4.2 is mutual
singularity at every message. $\square$

> **Theorem 4.4 (Support form).** $C_S = k$ if and only if there exist pairwise disjoint
> sets $S_\theta \subseteq \mathcal{X}$ with $p_\theta(S_\theta) = 1$ for every $\theta$.

*Proof sketch.* If $C_S = k$, take $S_\theta = \{x : p_\theta(x) \ne 0\}$; these are
pairwise disjoint by Theorem 4.3, and each carries full mass. Conversely, given such a
partition, $\widehat p$ dominates $p_\theta$ on $S_\theta$, so
$C_S \ge \sum_\theta \sum_{x\in S_\theta} p_\theta(x) = k$, and the reverse bound is
universal. $\square$

Thus the classical sufficient condition (disjoint supports) is also necessary.

> **Theorem 4.5 (Strictness).** If some message $x$ satisfies $p_\theta(x) > 0$ and
> $p_{\theta'}(x) > 0$ for two distinct $\theta,\theta'$, then $C_S < k$ strictly.

*Proof.* Immediate from Theorem 4.3 and $C_S\le k$. $\square$

### 4.2 The lower endpoint

> **Theorem 4.6 (Rigidity of the free class).** For any class (finite or not),
> $C_S = 1$ if and only if $p_\theta(x) = p_{\theta'}(x)$ for all $\theta,\theta',x$.

*Proof sketch.* ($\Leftarrow$) All sources equal implies $\widehat p = p_{\theta_0}$,
which sums to $1$. ($\Rightarrow$) Fix $\vartheta$. Then $p_\vartheta \le \widehat p$
pointwise and both sum to $1$ (the latter by hypothesis); a sum of non-negative
differences vanishing forces $p_\vartheta = \widehat p$ pointwise. As $\vartheta$ was
arbitrary, all sources equal $\widehat p$. $\square$

> **Corollary 4.7.** If two members of the class differ at any message, then $C_S > 1$:
> the price of universality is strictly positive.

### 4.3 Bit form

> **Theorem 4.8.** $\log_2 C_S = 0$ iff all sources coincide, and (for a finite class)
> $\log_2 C_S = \log_2 k$ iff the class is mutually singular.

*Proof.* $\log_2$ is strictly increasing on $(0,\infty)$ and $C_S \ge 1 > 0$; apply
Theorems 4.6 and 4.3. $\square$

---

## 5. Total variation: exact formula, sandwich, stability

### 5.1 Two sources

> **Theorem 5.1 (The price of a pair is a distance).** For a class with exactly two
> members $p, q$, $$C_S = 1 + d_{\mathrm{TV}}(p,q).$$

*Proof.* $\widehat p(x) = \max(p(x),q(x)) = \tfrac12\big(p(x)+q(x)+|p(x)-q(x)|\big)$.
Summing over $x$ and using $\sum_x p = \sum_x q = 1$ gives
$C_S = \tfrac12(1 + 1 + 2 d_{\mathrm{TV}}) = 1 + d_{\mathrm{TV}}$. $\square$

Theorem 5.1 interpolates exactly between the two rigidity theorems: $d_{\mathrm{TV}}=0$
is Theorem 4.6 and $d_{\mathrm{TV}}=1$ is Theorem 4.3 for $k=2$.

### 5.2 The sandwich

Two elementary identities are used, both proved by the same $\max/\min$-to-absolute-value
substitution as in Theorem 5.1:
$$\sum_x \big(p(x)-q(x)\big)_+ = d_{\mathrm{TV}}(p,q), \qquad
\sum_x \min\big(p(x),q(x)\big) = 1 - d_{\mathrm{TV}}(p,q).$$

> **Theorem 5.2 (Lower bound: pairwise separation).** For any class and any two members
> $\theta,\theta'$,
> $$1 + d_{\mathrm{TV}}(p_\theta,p_{\theta'}) \;\le\; C_S .$$

*Proof.* Restricting the parameter set to $\{\theta,\theta'\}$ can only decrease the
envelope pointwise, hence the Shtarkov sum (monotonicity under parameter pruning);
apply Theorem 5.1 to the pair. $\square$

> **Theorem 5.3 (Upper bound relative to a reference source).** For a finite class and
> any reference member $\theta_0$,
> $$C_S \;\le\; 1 + \sum_{\theta\in\Theta} d_{\mathrm{TV}}(p_\theta,p_{\theta_0}).$$

*Proof sketch.* Pointwise, for each $\theta$,
$p_\theta(x) \le p_{\theta_0}(x) + (p_\theta(x)-p_{\theta_0}(x))_+ \le p_{\theta_0}(x) + \sum_{\vartheta}(p_\vartheta(x)-p_{\theta_0}(x))_+$,
so the same bounds the envelope. Summing over $x$, exchanging the order of summation and
applying the positive-part identity yields the claim. $\square$

Together, $1 + \max_{\theta\ne\theta'}d_{\mathrm{TV}} \le C_S \le 1 + \sum_\theta d_{\mathrm{TV}}(p_\theta,p_{\theta_0})$:
the price of universality is sandwiched between the largest and the total statistical
separation inside the class.

### 5.3 Stability of the upper endpoint

> **Theorem 5.4 (One close pair pulls the price down).** For a finite class with
> $k$ sources and any distinct $\theta,\theta'$,
> $$C_S \;\le\; k - 1 + d_{\mathrm{TV}}(p_\theta,p_{\theta'}).$$

*Proof sketch.* Fix $x$ and let $\vartheta_0$ attain the envelope. At least one of
$\theta,\theta'$ differs from $\vartheta_0$, and its mass survives in the non-maximal
part; hence
$\min(p_\theta(x),p_{\theta'}(x)) \le \sum_\vartheta p_\vartheta(x) - \widehat p(x)$.
Summing over $x$ gives $1 - d_{\mathrm{TV}}(p_\theta,p_{\theta'}) \le \Omega$, and the
conservation law converts this into the stated bound. $\square$

At $d_{\mathrm{TV}} = 0$ this recovers Theorem 4.3 quantitatively (coincident sources
force $C_S \le k-1$); at $d_{\mathrm{TV}} = 1$ it degenerates to the sharp bound.

> **Theorem 5.5 (All-pairs stability).** For a finite class with $k$ sources,
> $$\sum_{\theta}\sum_{\theta'\ne\theta}\big(1 - d_{\mathrm{TV}}(p_\theta,p_{\theta'})\big)
> \;\le\; k(k-1)\,\Omega \;=\; k(k-1)\,\big(k - C_S\big).$$

*Proof sketch.* The pointwise inequality in the proof of Theorem 5.4 holds for *every*
ordered pair of distinct indices simultaneously. Summing it over the $k(k-1)$ ordered
pairs at each fixed message and then over messages, and using the affinity identity
$\sum_x \min(p,q) = 1 - d_{\mathrm{TV}}$, gives the claim; the final equality is
Theorem 3.2. $\square$

Equivalently, $C_S \le k - \mathrm{avg}$, where $\mathrm{avg}$ is the average pairwise
affinity divided by $k(k-1)$: the deficiency from the maximal price dominates the mean
indistinguishability of the family, not merely its best pair. The constant $k(k-1)$ is
almost certainly not sharp (see §10).

---

## 6. Equality analysis of the structural laws

### 6.1 Monotonicity under parameter pruning

> **Definition 6.1 (Subclass by reindexing).** Given a class $\{p_\theta\}_{\theta\in\Theta}$
> and a map $\iota : \Theta' \to \Theta$, the *reindexed class* is
> $\{p_{\iota(\theta')}\}_{\theta'\in\Theta'}$.

Pruning parameters can only lower the envelope, hence $C_S(\text{reindexed}) \le C_S$.

> **Theorem 6.2 (Equality case of monotonicity).**
> $C_S(\text{reindexed}) = C_S$ if and only if the reindexed class reproduces the
> envelope at *every* message.

*Proof.* The inequality is a sum of pointwise inequalities; a sum of non-negative
differences vanishes iff each difference does. $\square$

In words: discarding parameters is free precisely when the discarded ones were never
maximisers.

### 6.2 The tied product

> **Lemma 6.3 (Pointwise tied bound).** For the tied product,
> $\widehat p(x_1,x_2) \le \widehat p^{(1)}(x_1)\,\widehat p^{(2)}(x_2)$.

*Proof.* For each $\theta$, $p^{(1)}_\theta(x_1)p^{(2)}_\theta(x_2) \le \widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2)$
by multiplying the two envelope bounds (all quantities are non-negative); take the
supremum over $\theta$. $\square$

> **Lemma 6.4.** $\sum_{(x_1,x_2)} \widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2) = C_S^{(1)}C_S^{(2)}$.

*Proof.* Fubini on a product of finite sums. $\square$

> **Theorem 6.5 (Submultiplicativity / subadditivity).**
> $C_S(\mathrm{tied}) \le C_S^{(1)}C_S^{(2)}$; in bits,
> $\log_2 C_S(\mathrm{tied}) \le \log_2 C_S^{(1)} + \log_2 C_S^{(2)}$.

*Proof.* Sum Lemma 6.3 and apply Lemma 6.4. $\square$

Applied to blocks of a stationary parametric family, Theorem 6.5 is precisely the
hypothesis of Fekete's subadditivity lemma, guaranteeing that the per-symbol price
$\frac1n \log_2 C_S(n)$ converges.

> **Theorem 6.6 (Equality criterion).** For a *finite* parameter set,
> $C_S(\mathrm{tied}) = C_S^{(1)}C_S^{(2)}$ if and only if for every pair
> $(x_1,x_2)$ there exists $\theta \in \Theta$ with
> $p^{(1)}_\theta(x_1) = \widehat p^{(1)}(x_1)$ and $p^{(2)}_\theta(x_2) = \widehat p^{(2)}(x_2)$
> — a *common maximiser* for the pair.

*Proof sketch.* ($\Rightarrow$) Equality of the sums forces equality in Lemma 6.3 at
every $(x_1,x_2)$. Finiteness gives an attaining $\theta_0$ for the tied envelope, so
$p^{(1)}_{\theta_0}(x_1)p^{(2)}_{\theta_0}(x_2) = \widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2)$.
If both block envelopes are positive, the pointwise bounds
$p^{(i)}_{\theta_0} \le \widehat p^{(i)}$ combined with equality of the products force
equality in each factor, so $\theta_0$ is a common maximiser; if one block envelope
vanishes, all parameters maximise that block trivially and the condition is vacuous
there. ($\Leftarrow$) A common maximiser makes Lemma 6.3 an equality at that pair; if
this holds everywhere, the sums agree. $\square$

> **Theorem 6.7 (Strictness from a single deficient outcome; no finiteness needed).**
> If for some pair $(x_1,x_2)$ one has
> $\widehat p(x_1,x_2) < \widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2)$, then
> $C_S(\mathrm{tied}) < C_S^{(1)}C_S^{(2)}$.

*Proof.* A sum of pointwise inequalities with one strict term is strict. $\square$

Theorem 6.7 is the workhorse for continuous parameter spaces, where a maximiser need
not exist and Theorem 6.6 does not apply. The methodological point is that "no common
maximiser" must be replaced by a *quantitative envelope deficiency* to survive the
passage from finite to infinite $\Theta$.

### 6.3 A worked extremal family

Let $\mathcal{A}$ be a finite alphabet and consider the **point-mass class**: message
space $\mathcal{A}$, parameter space $\mathcal{A}$, with source $a$ putting all its mass
on the message $a$. Its envelope is identically $1$, so $C_S = |\mathcal{A}| = m$ — the
upper endpoint, consistent with Theorem 4.3 since the sources are mutually singular.

Now tie two copies: the tied product on $\mathcal{A}\times\mathcal{A}$ has envelope
$\mathbf{1}[x_1 = x_2]$, hence $C_S(\mathrm{tied}) = m$, whereas
$C_S^{(1)}C_S^{(2)} = m^2$. For $m \ge 2$ this is a strict gap, exactly as predicted by
Theorem 6.6: the outcome pair $(a,b)$ with $a \ne b$ has no common maximiser. The
saving is dramatic — $\log_2 m$ bits instead of $2\log_2 m$ — and this family is the
finite shadow of the memoryless phenomenon analysed next.

---

## 7. The memoryless class: strict subadditivity

Throughout this section $\mathcal{A}$ is a finite alphabet with $m = |\mathcal{A}| \ge 2$,
and $C_S(n)$ denotes the Shtarkov sum of the memoryless class of block length $n$
(Definition 2.6).

### 7.1 Constant strings and point masses

> **Lemma 7.1.** For every $n$ and every letter $a$, the point mass $\delta_a$ gives the
> constant string $a^n$ likelihood $1$; consequently $\widehat p(a^n) = 1$.

*Proof.* $\prod_{i=1}^{n} \delta_a(a) = 1^n = 1$, and envelopes never exceed $1$. $\square$

> **Lemma 7.2 (Uniqueness of the maximiser).** For $n \ge 1$, if $p_\theta(a^n) = 1$ then
> $\theta(a) = 1$.

*Proof.* $p_\theta(a^n) = \theta(a)^n$. If $\theta(a) < 1$ then $\theta(a)^n < 1$ for
$n\ge1$; since $\theta(a)\le 1$ always, equality forces $\theta(a)=1$. $\square$

> **Theorem 7.3 (Length one sits at the upper endpoint).** $C_S(1) = m$.

*Proof.* Every one-symbol message is a constant string, so by Lemma 7.1 the envelope is
identically $1$ and the sum over the $m$ messages is $m$. $\square$

Equivalently: at $n=1$ the memoryless class *is* the point-mass class in disguise, and
Theorem 4.3 applies.

### 7.2 Blocks are tied products

> **Theorem 7.4 (Block isomorphism).** For all $n_1,n_2 \ge 0$, the memoryless class of
> length $n_1+n_2$ and the tied product of the memoryless classes of lengths $n_1$ and
> $n_2$ have the same Shtarkov sum.

*Proof sketch.* Splitting the index set $\{1,\dots,n_1+n_2\}$ into its first $n_1$ and
last $n_2$ positions is a bijection of message spaces
$\mathcal{A}^{n_1+n_2} \cong \mathcal{A}^{n_1}\times\mathcal{A}^{n_2}$ under which
likelihoods correspond exactly, because $\prod_{i=1}^{n_1+n_2}\theta(x_i)
= \prod_{i\le n_1}\theta(x_i)\cdot\prod_{j\le n_2}\theta(x_{n_1+j})$. A likelihood-preserving
bijection of message spaces preserves envelopes and hence Shtarkov sums; applying the
comparison in both directions gives equality. $\square$

The point deserves emphasis: nothing is lost in the relabelling, so the tied-product
theory applies to the memoryless class *verbatim*, not merely as an upper bound.

### 7.3 The quantitative deficiency

> **Theorem 7.5 (Quarter bound).** Let $n_1,n_2 \ge 1$ and let $a \ne b$ be distinct
> letters. Then, in the tied product of the length-$n_1$ and length-$n_2$ memoryless
> classes,
> $$\widehat p\big(a^{n_1},\, b^{n_2}\big) \;\le\; \frac14,$$
> while $\widehat p^{(1)}(a^{n_1})\cdot \widehat p^{(2)}(b^{n_2}) = 1$.

*Proof.* For any $\theta \in \Delta(\mathcal{A})$ the tied likelihood at this pair is
$\theta(a)^{n_1}\theta(b)^{n_2}$. Since $0\le\theta(a)\le1$ and $n_1\ge1$,
$\theta(a)^{n_1} \le \theta(a)$, and likewise $\theta(b)^{n_2}\le\theta(b)$. Because
$a\ne b$, $\theta(a)+\theta(b)\le 1$, so by the arithmetic–geometric mean inequality
$$\theta(a)\theta(b) \;\le\; \Big(\frac{\theta(a)+\theta(b)}{2}\Big)^2 \;\le\; \frac14 .$$
Taking the supremum over $\theta$ bounds the tied envelope by $1/4$. The second claim is
Lemma 7.1 applied to each block. $\square$

The bound is attained in the limit $n_1=n_2=1$, $\theta(a)=\theta(b)=1/2$; the essential
content is that the deficiency is bounded away from $0$ *uniformly in the block lengths*,
which is exactly what a continuous parameter space demands.

### 7.4 Main theorems

> **Theorem 7.6 (Strict submultiplicativity of the memoryless price).** For
> $m \ge 2$ and $n_1,n_2 \ge 1$,
> $$C_S(n_1+n_2) \;<\; C_S(n_1)\cdot C_S(n_2).$$

*Proof.* By Theorem 7.4 the left side is the Shtarkov sum of the tied product. Pick
distinct letters $a\ne b$ (possible since $m\ge2$). By Theorem 7.5 the tied envelope at
$(a^{n_1},b^{n_2})$ is at most $1/4 < 1$, whereas the product of the block envelopes at
that pair equals $1$. Theorem 6.7 — which needs no finiteness of the parameter set —
converts this single strict pointwise inequality into a strict inequality of sums.
$\square$

> **Corollary 7.7 (Bit form).** For $m\ge2$ and $n_1,n_2\ge1$,
> $$\log_2 C_S(n_1+n_2) \;<\; \log_2 C_S(n_1) + \log_2 C_S(n_2).$$

*Proof.* $C_S > 0$ always, and $\log_2$ is strictly increasing; apply it to
Theorem 7.6 and use $\log_2(uv) = \log_2 u + \log_2 v$. $\square$

> **Theorem 7.8 (Compounding gain).** For $m\ge2$ and every $n \ge 2$,
> $$C_S(n) \;<\; m^n .$$

*Proof.* Induction. Base $n=2$: Theorem 7.6 with $n_1=n_2=1$ and Theorem 7.3 give
$C_S(2) < C_S(1)^2 = m^2$. Step: assuming $C_S(n) < m^n$, Theorem 7.6 with
$(n,1)$ and Theorem 7.3 give $C_S(n+1) < C_S(n)\cdot m < m^n\cdot m = m^{n+1}$, using
$m>0$. $\square$

### 7.5 Interpretation

The quantity $m^n$ is the Shtarkov sum one would pay if each of the $n$ symbols carried
its *own free parameter*: $n$ independent copies of the length-one problem, each at the
maximal price $m$, for a total of $n\log_2 m$ bits of regret — linear in $n$, i.e. a
constant per-symbol overhead, which is useless. Theorem 7.8 says that tying the
parameter always wins, strictly, and Theorem 7.6 says the win is picked up afresh at
every split.

This is the qualitative content behind the classical asymptotics: for the memoryless
class on an $m$-letter alphabet, the minimax regret satisfies
$$\log_2 C_S(n) \;=\; \frac{m-1}{2}\log_2 n \;+\; O(1),$$
logarithmic rather than linear. The strict inequality proved here is very far from
tight — see the numbers in §9 — but it is exact, uniform, and requires no asymptotics,
no Stirling approximation, and no analytic machinery: it follows from a single
quantitative deficiency at one message pair, propagated by a sum of pointwise
inequalities.

---

## 8. The sufficient-statistic (method of types) bound

A map $T : \mathcal{X}\to\sigma$ into a finite set is a *sufficient statistic* for the
class if $p_\theta(x)$ depends on $x$ only through $T(x)$, i.e. $T(x)=T(y)$ implies
$p_\theta(x) = p_\theta(y)$ for every $\theta$.

> **Lemma 8.1 (Fibrewise unit bound).** For a sufficient statistic $T$ and each value
> $s$, $\sum_{x : T(x)=s} \widehat p(x) \le 1$.

*Proof sketch.* On a non-empty fibre all the likelihoods $p_\theta(\cdot)$ are constant,
hence so is the envelope; if the fibre has $\kappa$ elements and $x_0$ is one of them,
every $\theta$ satisfies $\kappa\, p_\theta(x_0) \le \sum_x p_\theta(x) = 1$, so
$p_\theta(x_0) \le 1/\kappa$, hence $\widehat p(x_0) \le 1/\kappa$ and the fibre sum is
at most $1$. $\square$

Summing over $s$ recovers the classical bound $C_S \le |\sigma|$: the price of
universality never exceeds the logarithm of the number of *types*. For the memoryless
class the natural statistic is the empirical letter-count vector, of which there are
$\binom{n+m-1}{m-1} = O(n^{m-1})$, giving the polynomial (indeed $O(\log n)$-bit) upper
bound on regret.

> **Theorem 8.2 (Equality case).** $C_S = |\sigma|$ if and only if *every* fibre of $T$
> carries exactly unit envelope mass.

*Proof.* Decompose $C_S$ fibrewise (partitioning $\mathcal X$ by the level sets of $T$);
the total equals $|\sigma|$ iff each of the $|\sigma|$ fibre sums, each bounded by $1$
by Lemma 8.1, equals $1$. $\square$

Together with Theorem 7.8 this explains the gap: the memoryless class does *not*
saturate its type bound — most type classes carry strictly less than a full unit of
envelope mass — and the resulting slack is what turns $O(n^{m-1})$ types into a regret
of $\frac{m-1}{2}\log_2 n$ rather than $(m-1)\log_2 n$.

---

## 9. Algorithms and numerics

### 9.1 Exact evaluation for the memoryless class

The envelope of a memoryless block is computed in closed form by maximum likelihood: for
a string $x$ with letter counts $(k_a)_{a\in\mathcal{A}}$, $\sum_a k_a = n$, the maximiser
is the empirical distribution $\hat\theta(a) = k_a/n$, and
$$\widehat p(x) \;=\; \prod_{a\in\mathcal{A}} \Big(\frac{k_a}{n}\Big)^{k_a}$$
(with $0^0 = 1$). Since this depends only on the count vector — the letter counts are a
sufficient statistic — one can sum over *types* rather than strings:
$$C_S(n) \;=\; \sum_{\substack{(k_a)\ \ge 0 \\ \sum_a k_a = n}} \binom{n}{k_{a_1},\dots,k_{a_m}} \prod_a \Big(\frac{k_a}{n}\Big)^{k_a}.$$
There are $\binom{n+m-1}{m-1}$ types, so the evaluation is polynomial in $n$ for fixed
$m$ — as against $m^n$ strings — and, done in exact rational arithmetic, gives exact
values. For $m=2$:

| $n$ | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| $C_S(n)$ | $2$ | $5/2$ | $26/9$ | $103/32$ | $2194/625$ |
| $2^n$ | $2$ | $4$ | $8$ | $16$ | $32$ |
| ratio $2^n/C_S(n)$ | $1$ | $1.60$ | $2.77$ | $4.97$ | $9.11$ |

The ratio grows without bound (indeed $C_S(n) \sim \sqrt{\pi n/2}$ for $m=2$), so the
strict inequality $C_S(n) < 2^n$ is true but extremely lossy; quantifying the true rate
of the deficiency is the natural sharpening.

### 9.2 Exact evaluation for finite classes

For a finite class given by a $k \times |\mathcal{X}|$ table of rational probabilities,
$C_S$, $\Omega$ and all pairwise total variation distances are computed in
$O(k|\mathcal{X}|)$ and $O(k^2|\mathcal{X}|)$ operations respectively, with exact
rational arithmetic. Direct checks confirm each theorem numerically:

* $p = (1/2,1/3,1/6)$, $q = (1/4,1/4,1/2)$: $C_S = 4/3 = 1 + d_{\mathrm{TV}}$.
* $p = (1,0,0)$, $q = (0,1/2,1/2)$: $C_S = 2 = 1 + d_{\mathrm{TV}}$, the singular case.
* Three copies of the uniform law on three letters: $C_S = 1$, $\Omega = 2$, and
  $C_S + \Omega = 3 = k$.
* An exhaustive sweep of all $8^3 = 512$ classes of three sources on three letters drawn
  from the palette $(1,0,0),(0,1,0),(0,0,1),(\tfrac12,\tfrac12,0),(\tfrac12,0,\tfrac12),(0,\tfrac12,\tfrac12),(\tfrac13,\tfrac13,\tfrac13),(\tfrac14,\tfrac14,\tfrac12)$:
  the predicate $C_S = 3$ agreed with mutual singularity in every single case.
* Tied product of two point-mass blocks on two letters: $C_S(\mathrm{tied}) = 2$ against
  $C_S\cdot C_S = 4$.

### 9.3 Applications

*Model selection.* $\log_2 C_S$ is the parametric complexity term of the minimum
description length principle: the NML codelength of $x$ under a model class is
$\log_2(1/\widehat p(x)) + \log_2 C_S$, and comparing model classes means comparing these
complexities. Theorem 4.3 identifies the classes for which the complexity term is
maximal (models whose members are mutually singular are "as complex as a lookup table"),
while Theorem 5.4 says that near-duplicated members of a class contribute strictly less
than a full unit of complexity — a principled quantitative version of the intuition that
redundant parametrisations should not be penalised twice.

*Sequential prediction and online learning.* $\log_2 C_S$ is exactly the minimax
cumulative regret of probability forecasting against the best model in hindsight, so
Corollary 7.7 states that the regret of the memoryless expert class is strictly
subadditive across any split of the horizon: merging two prediction phases into a single
tied problem always saves regret.

*Data compression.* Theorem 7.8 is the formal statement that a two-pass or adaptive code
which shares one parameter across the block strictly beats a per-symbol adaptive code, at
every block length, on every alphabet with at least two letters.

---

## 10. Discussion and future directions

### 10.1 What the analysis shows

The whole rigidity picture reduces to two mechanisms. First, the *conservation law*
$C_S + \Omega = k$ turns the upper bound into an identity, so every statement about
$C_S$ near the top is a statement about the shared mass $\Omega$. Second, essentially
every inequality in the subject — the upper bound, the tied-product bound, the
monotonicity bound, the type bound — is a *sum of pointwise inequalities*, and for such
a sum, equality is equivalent to pointwise equality everywhere, while a single strict
term suffices for strictness. Once this is recognised, the equality cases are forced,
and the only real work is identifying the pointwise conditions.

The one genuine subtlety is the passage to continuous parameter spaces. The clean
criterion "equality iff every pair of block outcomes has a common maximiser" *extracts*
an attaining parameter, which requires finiteness. Its replacement — a quantitative
envelope deficiency at a single outcome pair — is weaker as a criterion but strictly more
applicable, and is exactly what the memoryless simplex needs. This "replace attainment by
quantitative deficiency" move seems to be a reusable pattern.

### 10.2 Open problems

Included below are the directions this line of work identifies.

**Sharp constant in the all-pairs stability bound.** The crude bound of Theorem 5.5,
$$\sum_{\theta\ne\theta'}\big(1 - d_{\mathrm{TV}}(p_\theta,p_{\theta'})\big) \le k(k-1)\,\Omega,$$
i.e. $C_S \le k - (\text{average pairwise affinity})$, is proved. It is conjectured that
the constant improves by a factor $k$:
$$\sum_{\theta\ne\theta'}\big(1 - d_{\mathrm{TV}}(p_\theta,p_{\theta'})\big) \le 2(k-1)\,\Omega,$$
and that this is sharp for the family consisting of two coincident sources among $k$.
The key insight is that at a fixed message, sorting the likelihoods
$a_1 \ge \cdots \ge a_k$ turns the pair sum into $2\sum_j (j-1)a_j$, which the non-maximal
mass $\sum_{j\ge2} a_j$ dominates up to the factor $2(k-1)$; the crude proof discards this
ordering and pays an extra factor $k$. What is missing is a monotone-rearrangement
argument at each fixed message.

**Rigidity for the redundancy–capacity inequality.** The bound $I(w) \le \log_2 C_S$,
relating the mutual information of a prior $w$ over parameters to the Shtarkov sum, has an
untouched equality case. Unlike everything above it is *not* a sum of pointwise
inequalities: the mixture side needs a Gibbs-type equality analysis rather than a
termwise one.

**Quantifying the memoryless deficit.** Theorem 7.8 shows $C_S(n) < m^n$ but the true
behaviour is $C_S(n) = \Theta(n^{(m-1)/2})$. The elementary machinery here yields only a
constant-factor gain per split; recovering even the correct polynomial order from
pointwise deficiency arguments — by exhibiting a deficiency at *many* outcome pairs rather
than one — would be a genuinely quantitative upgrade of the method.

**Beyond memorylessness.** The tied-product machinery is agnostic to the internal
structure of the blocks, so the strictness argument should transfer to Markov chains,
tree sources and exponential families: the only input needed is a single pair of block
outcomes whose separate maximisers provably conflict, together with a uniform quantitative
gap. Identifying the right "conflicting pair" for each model class is the concrete task.

**Stability under approximate ties.** All of the above is exact. A robust theory would
ask how $C_S$ moves under perturbation of the class in total variation; Theorems 5.3 and
5.4 are first steps, but a two-sided Lipschitz estimate for $C_S$ as a functional of the
family, in a suitable metric on classes, is missing.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Conservation law | $C_S + \Omega = k$, $\Omega = \sum_x(\sum_\theta p_\theta(x) - \max_\theta p_\theta(x)) \ge 0$ |
| Upper rigidity | $C_S = k \iff$ mutual singularity $\iff$ disjoint full-mass supports |
| Strictness | one shared message with two positive masses $\Rightarrow C_S < k$ |
| Lower rigidity | $C_S = 1 \iff$ all sources coincide |
| Two-source formula | $C_S = 1 + d_{\mathrm{TV}}(p,q)$ |
| TV sandwich | $1 + \max_{\theta\ne\theta'} d_{\mathrm{TV}} \le C_S \le 1 + \sum_\theta d_{\mathrm{TV}}(p_\theta,p_{\theta_0})$ |
| Stability | $C_S \le k - 1 + d_{\mathrm{TV}}(p_\theta,p_{\theta'})$; all-pairs affinity $\le k(k-1)\Omega$ |
| Monotonicity equality | pruning is free iff the envelope is reproduced at every message |
| Tied-product equality | equality iff every outcome pair has a common maximiser (finite $\Theta$) |
| Tied-product strictness | one deficient outcome pair suffices (any $\Theta$) |
| Type-bound equality | $C_S = |\sigma| \iff$ every fibre carries unit envelope mass |
| Memoryless, length one | $C_S(1) = m$ |
| Quarter bound | tied envelope at $(a^{n_1},b^{n_2})$, $a\ne b$, is $\le 1/4$ |
| Strict subadditivity | $C_S(n_1+n_2) < C_S(n_1)C_S(n_2)$ for $m\ge2$, $n_1,n_2\ge1$ |
| Compounding gain | $C_S(n) < m^n$ for $n \ge 2$ |
