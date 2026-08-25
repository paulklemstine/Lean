# Converses to the Union Bound for Universal Hashing: The Exact Extremal Collision Probability

**Author:** Aristotle

**Date:** 2026-08-25

---

## Abstract

For a family of hash functions from a key set into $m$ buckets, the Carter–Wegman axiom of $2$-universality — every pair of distinct keys collides with probability at most $1/m$ — combined with the union bound yields the classical estimate $\Pr[\text{collision among } n \text{ keys}] \le \binom{n}{2}/m$. We study the opposite direction and determine the extremal problem completely. Our main theorem is a *converse to the union bound*: every family that is **exactly** $2$-universal (every pair of distinct keys collides with probability exactly $1/m$) collides on any $n \ge 2$ keys with probability **at least** $1/m$, irrespective of $n$ and of the structure of the family. The bound is attained: the Carter–Wegman affine family $x \mapsto ax + b$ over $\mathbb{Z}_p$ collides with probability exactly $1/p$ for every key set of size between $2$ and $p$, and for an arbitrary number of buckets $m$ the mixture of a uniformly random bijection (mass $1 - 1/m$) with a uniformly random constant map (mass $1/m$) is exactly $2$-universal and attains $1/m$. Consequently the extremal value function is
$$\min_{\text{exactly } 2\text{-universal}} \Pr[\text{collision}] = \begin{cases} 1/m & 2 \le n \le m,\\ 1 & n > m,\end{cases}$$
for every $m$, with no primality hypothesis. We show that exactness is indispensable: under the inequality-only axiom the extremal value collapses to the dichotomy $0$ (for $n \le m$) versus $1$ (for $n > m$). We complement these results with a first-moment analysis showing that exact $2$-universality is optimal up to an additive $n(1 - 1/m)$ colliding ordered pairs, with an arithmetic obstruction ($m \mid |\Omega|$ for uniformly weighted families), with a second-moment (Chung–Erdős) refinement, and with exact numerics for $m = 2, 3, 5, 7$ quantifying the gap between the two endpoints — at $m = n = 7$ the union bound permits the vacuous value $3$ while the truth is $1/7$.

**Keywords:** universal hashing, Carter–Wegman families, union bound, reverse Markov inequality, collision probability, pairwise independence, extremal value function, Chung–Erdős inequality.

---

## 1. Introduction

### 1.1 The classical picture

Universal hashing, introduced by Carter and Wegman, is one of the load-bearing ideas of algorithm design. Instead of committing to a single hash function $h : K \to V$ — which an adversary can always defeat by choosing keys that map to the same bucket — one fixes a *family* $\{h_\omega\}_{\omega \in \Omega}$ together with a probability law on the index set $\Omega$, and draws $\omega$ at run time. The design requirement is:

> **Carter–Wegman $2$-universality.** For all distinct keys $x \ne y$, $\Pr_\omega[h_\omega(x) = h_\omega(y)] \le 1/m$, where $m = |V|$ is the number of buckets.

The single consequence of this axiom that is used in practice is obtained from the union bound applied to the $\binom{n}{2}$ pairs of a key set $S$ of size $n$:
$$\Pr_\omega[\,h_\omega \text{ is not injective on } S\,] \le \frac{\binom{n}{2}}{m}. \tag{1}$$
This is the entire analysis behind perfect hashing, hash-table load bounds, sketching algorithms, and much of derandomisation: choose $m \gg n^2$ and collisions vanish.

### 1.2 The question

Estimate (1) is an *upper* bound. Its proof — sum the pair probabilities — is loose whenever the pairwise collision events overlap, and for hash families they overlap enormously: a hash function that collides on one pair typically collides on many. This raises a question that appears not to have been asked in the extremal form:

> **Question.** Over *all* families satisfying the universality axiom, how *small* can the collision probability on $n$ keys be?

This is a converse to the union bound rather than another application of it, and it requires lower-bounding the probability of a union — a direction for which the union bound itself is useless.

### 1.3 Results

We answer the question completely. Throughout, $m$ denotes the number of buckets and $n \ge 2$ the number of keys.

* **Converse endpoint (Theorem 4.2).** Every *exactly* $2$-universal family — one for which each pair of distinct keys collides with probability exactly $1/m$ — collides on $S$ with probability at least $1/m$. The bound does not depend on $n$.
* **Sandwich (Corollary 4.3).** For exactly $2$-universal families, $1/m \le \Pr[\text{collision}] \le \binom{n}{2}/m$.
* **Attainment, prime case (Theorem 5.3).** The affine family over $\mathbb{Z}_p$ collides with probability exactly $1/p$, for every key set of size $2 \le n \le p$; it is moreover pairwise independent (Theorem 5.4).
* **Extremal value function (Theorem 6.1, Theorem 7.4).** For every number of buckets $m$ and every $n \ge 2$, the minimum collision probability over exactly $2$-universal families equals $1/m$ if $n \le m$, while for $n > m$ every family (universal or not) has collision probability $1$. No primality is needed: the attaining family for general $m$ is a bijection–constant mixture (Section 7).
* **Necessity of exactness (Theorem 8.4).** With the inequality-only axiom, the extremal value is $0$ for $n \le m$ and $1$ for $n > m$: the value $1/m$ is a phenomenon of exact (equivalently, pairwise independent) universality.
* **First-moment optimality (Theorem 8.2).** Every single hash function collides on at least $n^2/m - n$ ordered pairs of $n$ keys; an exactly $2$-universal family exceeds this absolute minimum in expectation by exactly $n(1 - 1/m)$.
* **Arithmetic obstruction (Theorem 5.5).** A uniformly weighted exactly $2$-universal family on $\ge 2$ keys has $m \mid |\Omega|$.
* **Numerics (Section 9).** Exact collision probabilities $1/p$ for $p = 2, 3, 5, 7$, with the collision index counts verified by explicit enumeration, and the gap to the union bound quantified.

### 1.4 The mechanism in one paragraph

Let $X(\omega)$ count the *ordered* pairs of distinct keys of $S$ on which $h_\omega$ collides. Exact $2$-universality pins its mean, $\mathbb{E}[X] = n(n-1)/m$, and the number of ordered pairs caps it, $X \le n(n-1)$. The reverse Markov inequality $\mathbb{E}[X] \le (\max X)\Pr[X > 0]$ then gives $\Pr[X > 0] \ge 1/m$, and $\{X > 0\}$ is the collision event. The factor $n(n-1)$ cancels — the very factor by which the union bound *degrades* as keys are added — which is why the answer is independent of $n$. Tightness in reverse Markov requires $X$ to be $\{0, \max\}$-valued, so the extremal families must be *all-or-nothing*; both attaining families below have exactly that shape.

---

## 2. Framework: finite probability laws

We work in a completely elementary finite setting, which suffices for all statements and makes the extremal claims quantify over a transparent class of objects.

**Definition 2.1 (Finite law).** Let $\Omega$ be a finite type. A *law* on $\Omega$ is a function $w : \Omega \to \mathbb{R}$ with $w(\omega) \ge 0$ for all $\omega$ and $\sum_{\omega} w(\omega) = 1$. For $f : \Omega \to \mathbb{R}$ we write $\mathbb{E}[f] = \sum_\omega w(\omega) f(\omega)$, and for a predicate $A$ on $\Omega$ we write $\Pr[A] = \mathbb{E}[\mathbf{1}_A]$ where $\mathbf{1}_A(\omega) \in \{0,1\}$ is the indicator. The *uniform law* on a nonempty $\Omega$ assigns $w(\omega) = 1/|\Omega|$, so that $\Pr[A] = |\{\omega : A(\omega)\}| / |\Omega|$.

A law is automatically supported on a nonempty type (an empty sum cannot equal $1$). Expectation is monotone, additive and homogeneous; probability is monotone, lies in $[0,1]$, and is invariant under logical equivalence of predicates. We record the four inequalities we use.

**Proposition 2.2 (Union bound).** For any finite index set $I$ and predicates $A_i$,
$$\Pr\Big[\bigcup_{i \in I} A_i\Big] \le \sum_{i \in I} \Pr[A_i].$$
*Proof sketch.* Pointwise, $\mathbf{1}_{\bigcup A_i} \le \sum_i \mathbf{1}_{A_i}$, since the left side is $0$ or $1$ and in the latter case at least one summand is $1$. Take expectations. $\square$

**Proposition 2.3 (Bonferroni converse).** With the same notation,
$$\sum_{i \in I} \Pr[A_i] - \sum_{(i,j) \in I^{\ne}} \Pr[A_i \wedge A_j] \le \Pr\Big[\bigcup_{i} A_i\Big],$$
the second sum running over ordered pairs of distinct indices.
*Proof sketch.* Pointwise: if $k \ge 1$ of the events hold at $\omega$, the left-hand integrand is $k - k(k-1) \le 1$, and if $k = 0$ both sides vanish. $\square$

**Proposition 2.4 (Reverse Markov inequality).** If $0 \le f \le C$ pointwise, then $\mathbb{E}[f] \le C \cdot \Pr[f > 0]$; equivalently, if $C > 0$ then $\Pr[f > 0] \ge \mathbb{E}[f]/C$.
*Proof sketch.* Pointwise $f(\omega) \le C\,\mathbf{1}_{\{f > 0\}}(\omega)$: where $f(\omega) = 0$ the right side is $\ge 0$; where $f(\omega) > 0$ the right side is $C \ge f(\omega)$. Take expectations. $\square$

**Proposition 2.5 (Chung–Erdős / second moment).** For $f \ge 0$, $\mathbb{E}[f]^2 \le \mathbb{E}[f^2] \cdot \Pr[f > 0]$.
*Proof sketch.* Cauchy–Schwarz applied to $f = f \cdot \mathbf{1}_{\{f>0\}}$. $\square$

Propositions 2.4 and 2.5 are the genuinely converse tools: each bounds the probability of a union *from below* using moment data.

---

## 3. Universality and the collision counter

Fix a finite bucket type $V$ with $|V| = m$, a key type $K$ with decidable equality, a finite index type $\Omega$ carrying a law, and a family $h : \Omega \to (K \to V)$. Fix a finite key set $S \subseteq K$ with $|S| = n$.

**Definition 3.1 (Collision event).** $\mathrm{Coll}(\omega)$ holds iff $h_\omega$ fails to be injective on $S$, i.e. iff there exist $x, y \in S$ with $x \ne y$ and $h_\omega(x) = h_\omega(y)$.

**Definition 3.2 (Universality).** The family is
* *(Carter–Wegman) $2$-universal on $S$* if $\Pr[h_\omega(x) = h_\omega(y)] \le 1/m$ for all distinct $x,y \in S$;
* *exactly $2$-universal on $S$* if $\Pr[h_\omega(x) = h_\omega(y)] = 1/m$ for all distinct $x,y \in S$;
* *pairwise independent* (*strongly $2$-universal*) *on $S$* if for all distinct $x, y \in S$ and all $u, v \in V$, $\Pr[h_\omega(x) = u \ \wedge\ h_\omega(y) = v] = 1/m^2$.

Exact $2$-universality implies the inequality version. Pairwise independence implies exactness:

**Proposition 3.3.** A pairwise independent family is exactly $2$-universal.
*Proof sketch.* The event $h_\omega(x) = h_\omega(y)$ is the disjoint union over $u \in V$ of the events $\{h_\omega(x) = u \wedge h_\omega(y) = u\}$; these are pairwise disjoint since they determine $h_\omega(x)$. Finite additivity gives $m \cdot 1/m^2 = 1/m$. $\square$

**Definition 3.4 (Collision counter).** $X(\omega) := \#\{(x,y) \in S \times S : x \ne y,\ h_\omega(x) = h_\omega(y)\}$, the number of *ordered* colliding pairs.

Three elementary facts drive everything:

**Lemma 3.5.** (i) $0 \le X(\omega) \le n(n-1)$ for all $\omega$. (ii) $X(\omega) > 0$ iff $\mathrm{Coll}(\omega)$. (iii) $\mathbb{E}[X] = \sum_{(x,y),\, x \ne y} \Pr[h_\omega(x) = h_\omega(y)]$.
*Proof sketch.* (i) $X$ counts a subset of the $n(n-1)$ off-diagonal pairs. (ii) A positive count exhibits a colliding pair and conversely. (iii) Write $X$ as the sum of pair indicators and use linearity. $\square$

**Corollary 3.6 (First moment of an exactly $2$-universal family).** If the family is exactly $2$-universal on $S$ then $\mathbb{E}[X] = n(n-1)/m$.

---

## 4. The two endpoints

### 4.1 The union bound endpoint

**Theorem 4.1.** If the family is (inequality) $2$-universal on $S$, then
$$\Pr[\mathrm{Coll}] \le \frac{\binom{n}{2}}{m}.$$
*Proof sketch.* $\mathrm{Coll}$ implies that some two-element subset $T \subseteq S$ is collapsed by $h_\omega$; that is, $\mathrm{Coll} \subseteq \bigcup_{T \in \binom{S}{2}} A_T$ where $A_T$ is the event that the two elements of $T$ collide. By Proposition 2.2 the probability is at most $\sum_T \Pr[A_T]$, and each term is at most $1/m$ by universality. There are $\binom{n}{2}$ terms. $\square$

### 4.2 The converse endpoint

The key general statement requires only a *lower* bound on the pair probabilities.

**Theorem 4.2 (General converse bound).** Suppose $n \ge 2$ and there is $\delta$ with $\Pr[h_\omega(x) = h_\omega(y)] \ge \delta$ for all distinct $x, y \in S$. Then
$$\Pr[\mathrm{Coll}] \ \ge\ \delta.$$
In particular, an exactly $2$-universal family satisfies $\Pr[\mathrm{Coll}] \ge 1/m$.

*Proof.* Let $D = n(n-1) > 0$ be the number of ordered pairs of distinct keys. By Lemma 3.5(iii) and the hypothesis, $\mathbb{E}[X] \ge D\delta$. By Lemma 3.5(i), $0 \le X \le D$, so the reverse Markov inequality (Proposition 2.4 with $C = D$) gives
$$\Pr[X > 0] \ \ge\ \frac{\mathbb{E}[X]}{D} \ \ge\ \frac{D\delta}{D} \ =\ \delta.$$
By Lemma 3.5(ii), $\Pr[X>0] = \Pr[\mathrm{Coll}]$. $\square$

The proof is short, but the phenomenon is not obvious: it says that the union of $\binom{n}{2}$ events, each of probability exactly $1/m$, cannot be *diluted* below the probability of a single one of them — which is trivially true for any single event, and the content is that the collision structure allows no cancellation to do better than that trivial floor, i.e. the floor is *achieved*.

**Corollary 4.3 (Birthday sandwich).** For an exactly $2$-universal family on $n \ge 2$ keys,
$$\frac{1}{m} \ \le\ \Pr[\mathrm{Coll}] \ \le\ \frac{\binom{n}{2}}{m}.$$

**Theorem 4.4 (Pigeonhole degeneration).** If $n > m$ then $\Pr[\mathrm{Coll}] = 1$ for *every* family and every law.
*Proof sketch.* Pointwise pigeonhole: no map from an $n$-element set into an $m$-element set with $n > m$ is injective, so $\mathrm{Coll}(\omega)$ holds for every $\omega$. $\square$

**Theorem 4.5 (Second-moment refinement).** For an exactly $2$-universal family with $\mathbb{E}[X^2] > 0$,
$$\Pr[\mathrm{Coll}] \ \ge\ \frac{\big(n(n-1)/m\big)^2}{\mathbb{E}[X^2]}.$$
*Proof sketch.* Chung–Erdős (Proposition 2.5) applied to $X$, using $\mathbb{E}[X] = n(n-1)/m$ and $\{X>0\} = \mathrm{Coll}$. $\square$

Theorem 4.5 improves on $1/m$ whenever $\mathbb{E}[X^2] < n(n-1)\,\mathbb{E}[X]$, i.e. whenever the counter is *not* concentrated on $\{0, n(n-1)\}$. For the extremal families below, $X \in \{0, n(n-1)\}$ exactly and Theorem 4.5 returns precisely $1/m$: the two bounds coincide at the extremal point, confirming that Theorem 4.2 cannot be improved by second-moment information.

---

## 5. The affine family: sharpness for prime $m$

Let $p$ be prime, $V = K = \mathbb{Z}_p$, $\Omega = \mathbb{Z}_p \times \mathbb{Z}_p$ with the uniform law, and
$$h_{(a,b)}(x) = a x + b .$$

**Lemma 5.1 (Collision locus).** For distinct $x, y \in \mathbb{Z}_p$, $h_{(a,b)}(x) = h_{(a,b)}(y)$ iff $a = 0$.
*Proof sketch.* $ax + b = ay + b \iff a(x - y) = 0$, and $\mathbb{Z}_p$ is a field with $x - y \ne 0$. $\square$

**Theorem 5.2 (Exact universality).** The affine family is exactly $2$-universal on every key set: for distinct $x, y$, the set of colliding indices is $\{0\} \times \mathbb{Z}_p$, of size $p$ out of $p^2$, so the probability is $1/p$.

**Theorem 5.3 (Sharpness witness).** For every $S \subseteq \mathbb{Z}_p$ with $|S| \ge 2$,
$$\Pr[\mathrm{Coll}] = \frac 1p,$$
independently of $|S|$.
*Proof sketch.* By Lemma 5.1 applied to any witnessing pair, $\mathrm{Coll}(a,b)$ holds iff $a = 0$: if $a \ne 0$ then $h_{(a,b)}$ is injective (it is an affine bijection), and if $a = 0$ then $h_{(a,b)}$ is constant, which collides as soon as $|S| \ge 2$. The event $\{a = 0\}$ has $p$ of the $p^2$ indices. $\square$

Thus the counter satisfies $X \in \{0, n(n-1)\}$: all-or-nothing, exactly the equality case of reverse Markov.

**Theorem 5.4 (Strong universality of the affine family).** The affine family is pairwise independent: for distinct $x, y$ and any $u, v \in \mathbb{Z}_p$, exactly one index $(a,b)$ satisfies $h_{(a,b)}(x) = u$ and $h_{(a,b)}(y) = v$, namely $a = (u-v)/(x-y)$, $b = u - ax$; hence the probability is $1/p^2$.
*Proof sketch.* Subtracting the two linear conditions gives $a(x-y) = u - v$, which determines $a$ uniquely since $x - y$ is invertible; then $b$ is determined. Conversely that pair satisfies both conditions. $\square$

Consequently the extremal value is attained already *within* the class of strongly $2$-universal families — the class used in practice — so it is not an artifact of admitting exotic weights.

**Theorem 5.5 (Divisibility obstruction).** If a family indexed by a finite nonempty $\Omega$ with the **uniform** law is exactly $2$-universal on a key set of size $\ge 2$, then $m \mid |\Omega|$.
*Proof sketch.* Fix distinct $x, y \in S$ and let $c$ be the number of indices $\omega$ with $h_\omega(x) = h_\omega(y)$. Exactness reads $c/|\Omega| = 1/m$, i.e. $c\,m = |\Omega|$. $\square$

The affine family has $|\Omega| = p^2$, the smallest square multiple of $p$; more importantly, Theorem 5.5 shows that uniformly weighted exactly $2$-universal families are arithmetically constrained, so the search for extremal families of a prescribed size is a genuinely number-theoretic question.

**Combining.** Define the set of *achievable collision probabilities* on a key set $S$ with $|S| = n \ge 2$ into $p$ buckets as
$$\mathcal{A} = \{\, c \in \mathbb{R} : c = \Pr[\mathrm{Coll}] \text{ for some finite index set, law and exactly } 2\text{-universal family} \,\}.$$

**Theorem 5.6 (Exact extremal value, prime case).** $\min \mathcal{A} = 1/p$; that is, $1/p \in \mathcal{A}$ and $c \ge 1/p$ for all $c \in \mathcal{A}$.
*Proof.* Membership is Theorem 5.3 with Theorem 5.2; the lower bound is Theorem 4.2. $\square$

---

## 6. The extremal value function

Transporting the affine family along an injective encoding of an abstract key set removes the assumption that keys are field elements.

**Lemma 6.1 (Transport).** Let $\iota : K \to \mathbb{Z}_p$ be injective on $S$ and set $h^\iota_{(a,b)}(k) = a\,\iota(k) + b$. Then $h^\iota$ is exactly $2$-universal on $S$, and if $|S| \ge 2$ its collision probability is $1/p$.
*Proof sketch.* Injectivity of $\iota$ on $S$ turns distinct keys into distinct field elements, and the proofs of Theorems 5.2 and 5.3 apply verbatim; the collision locus is again $\{a = 0\}$. $\square$

Taking $K = \{1, \dots, n\}$ and $\iota$ the inclusion into $\mathbb{Z}_p$ (injective precisely when $n \le p$) gives:

**Theorem 6.2 (Extremal value function, prime case).** Let $p$ be prime and $n \ge 2$. Let $\mathcal{A}_{p,n}$ be the set of collision probabilities achievable by exactly $2$-universal families from $n$ keys into $p$ buckets. Then
* if $n \le p$: $\min \mathcal{A}_{p,n} = 1/p$;
* if $n > p$: every element of $\mathcal{A}_{p,n}$ equals $1$.

**Corollary 6.3 (Independence of the number of keys).** For $2 \le n_1, n_2 \le p$, $\min \mathcal{A}_{p,n_1} = \min \mathcal{A}_{p,n_2} = 1/p$. The extremal value is a *constant* function of $n$ on the whole nondegenerate range, whereas the union bound $\binom{n}{2}/p$ grows quadratically and becomes vacuous for $n \gtrsim \sqrt{p}$.

---

## 7. Prime-free attainment: the bijection–constant mixture

The equality analysis of reverse Markov dictates the shape of any extremal family: the counter must be $\{0, n(n-1)\}$-valued, i.e. each member of the family is either injective on $S$ or collapses all of $S$ to one bucket. That shape can be realised for *any* $m$.

**Definition 7.1 (Mixture family).** Let $m \ge 1$ and $V = \{1, \dots, m\}$. Index the family by $\Omega = \mathrm{Sym}(V) \sqcup V$: the *bijection branch* consists of the $m!$ permutations $\sigma$, acting as $h_\sigma = \sigma$; the *constant branch* consists of the $m$ constants $c$, acting as $h_c \equiv c$. Weight them by
$$w(\sigma) = \frac{1 - 1/m}{m!}, \qquad w(c) = \frac{1}{m^2}.$$

**Lemma 7.2.** These weights form a law: the bijection branch has total mass $1 - 1/m$ and the constant branch total mass $m \cdot 1/m^2 = 1/m$.

**Theorem 7.3 (The mixture is exactly $2$-universal and extremal).** For every $m \ge 1$ and every key set $S$:
1. for distinct $x, y \in S$, $h_\omega(x) = h_\omega(y)$ holds exactly on the constant branch, so $\Pr[h_\omega(x) = h_\omega(y)] = 1/m$ — the family is exactly $2$-universal;
2. if $|S| \ge 2$, $\mathrm{Coll}$ also holds exactly on the constant branch, so $\Pr[\mathrm{Coll}] = 1/m$.

*Proof sketch.* A permutation is injective, so it never identifies two distinct keys and never collides; a constant map identifies everything, so it collides on any $\ge 2$ keys and satisfies $h(x) = h(y)$ for any pair. Both events therefore coincide with the constant branch, whose mass is $1/m$ by Lemma 7.2. $\square$

**Theorem 7.4 (Prime-free extremal value function).** For every $m \ge 1$ and every $n \ge 2$, let $\mathcal{A}_{m,n}$ be the set of collision probabilities achievable by exactly $2$-universal families from $n$ keys into $m$ buckets. Then
$$\min \mathcal{A}_{m,n} = \frac 1m \quad (n \le m), \qquad \mathcal{A}_{m,n} = \{1\} \quad (n > m).$$
*Proof.* For $n \le m$, transport the mixture along the inclusion $\{1,\dots,n\} \hookrightarrow \{1,\dots,m\}$ (which preserves both statements of Theorem 7.3, since injectivity of the encoding is all that was used); this gives $1/m \in \mathcal{A}_{m,n}$. The lower bound is Theorem 4.2. For $n > m$, Theorem 4.4 gives value $1$ for every family. $\square$

**Remark 7.5.** The mixture is a *caricature* of a hash family: with probability $1/m$ it collapses the entire universe to a single bucket. The affine family fails with the same probability $1/p$, but its failure mode is identical (it becomes constant), which retrospectively explains why the classical construction is extremal: the standard textbook family already sits at the vertex of the universality polytope that minimises the collision probability. Whether the mixture is also *strongly* $2$-universal for every $m$ — that is, whether $\Pr[h(x)=u,\ h(y)=v] = 1/m^2$ for all $u,v$ — reduces to a permutation count and is discussed in Section 11.

---

## 8. Two refinements: how much does universality cost?

### 8.1 An absolute pigeonhole bound on collision counts

**Theorem 8.1 (Every function collides often).** Let $f : K \to V$ be *any* function and $S$ a key set of size $n$. Then the number of ordered colliding pairs of $f$ on $S$ is at least $n^2/m - n$.
*Proof.* Let $c_v = |\{x \in S : f(x) = v\}|$ be the fibre sizes, so $\sum_v c_v = n$. Cauchy–Schwarz gives $\sum_v c_v^2 \ge (\sum_v c_v)^2/m = n^2/m$. On the other hand, counting pairs $(x,y) \in S \times S$ with $f(x) = f(y)$ fibre by fibre gives $\sum_v c_v^2 = \#\{\text{ordered colliding pairs}\} + n$, where the $+n$ accounts for the diagonal. Combining yields the claim. $\square$

Averaging over any law, the expected collision count of *any* family is at least $n^2/m - n$.

**Theorem 8.2 (First-moment optimality of exact $2$-universality).** For an exactly $2$-universal family,
$$\mathbb{E}[X] - \left(\frac{n^2}{m} - n\right) = n\left(1 - \frac1m\right).$$
*Proof.* $\mathbb{E}[X] = n(n-1)/m = n^2/m - n/m$; subtract. $\square$

So the Carter–Wegman axiom costs *less than $n$ extra colliding ordered pairs* relative to the information-theoretic optimum achieved by the most balanced possible single function. At the level of first moments, universality is essentially free — and, notably, the entire gap between the union bound and the truth in Corollary 4.3 is therefore *not* a first-moment phenomenon but a concentration phenomenon.

### 8.2 Exactness is indispensable

**Theorem 8.3.** If $2 \le n \le m$, there is a family that is (inequality) $2$-universal on $S$ and never collides: take the one-element family consisting of a single injective map $S \hookrightarrow V$, with the point law. Every pair collides with probability $0 \le 1/m$, and $\Pr[\mathrm{Coll}] = 0$.

**Theorem 8.4 (Carter–Wegman dichotomy).** Under the inequality-only axiom the extremal collision probability is
$$0 \quad (2 \le n \le m), \qquad 1 \quad (n > m),$$
with no intermediate value. In particular no bound of the form $\Pr[\mathrm{Coll}] \ge 1/m$ can hold under the inequality axiom.
*Proof.* Theorem 8.3 and Theorem 4.4. $\square$

This is the sharp delimitation of the main theorem. The floor $1/m$ is a consequence of *exact* universality — equivalently, it holds for every pairwise independent family, by Proposition 3.3 — and not of the hypothesis used in the union bound. Informally: a family that is *better* than random on every pair (a perfect hash) evades the floor; a family that is *exactly* as random as random on every pair cannot.

**Corollary 8.5 (Pairwise independence forces collisions).** Every pairwise independent family collides on $n \ge 2$ keys with probability at least $1/m$.

---

## 9. Exact numerics and the size of the gap

We record exact values for small prime bucket counts, using the affine family over $\mathbb{Z}_p$ on the full key set $\mathbb{Z}_p$. In each case the number of indices $(a,b) \in \mathbb{Z}_p^2$ at which the hash function collides on the key set is exactly $p$ — namely those with $a = 0$ — out of $p^2$ indices, giving probability $1/p$.

| $p$ | colliding indices | total indices | collision probability | union bound $\binom{p}{2}/p$ |
|---|---|---|---|---|
| $2$ | $2$ | $4$ | $1/2 = 0.5$ | $0.5$ |
| $3$ | $3$ | $9$ | $1/3 \approx 0.3333$ | $1$ |
| $5$ | $5$ | $25$ | $1/5 = 0.2$ | $2$ |
| $7$ | $7$ | $49$ | $1/7 \approx 0.1429$ | $3$ |

Three observations.

**(a) The union bound is vacuous long before it is wrong.** At $p = 7$ with all seven keys it permits the value $3$; probabilities do not exceed $1$. The truth, and the extremal value over *all* exactly $2$-universal families, is $1/7$.

**(b) The extremal value is independent of the number of keys.** Over $\mathbb{Z}_7$, the collision probability of the affine family on the two keys $\{0,1\}$ equals its collision probability on all seven keys: both are $1/7$. The union bound moves from $1/7$ to $3$ across the same range.

**(c) Degeneration is abrupt.** With eight keys and seven buckets — for instance the affine family over $\mathbb{Z}_7$ read through the reduction map $\{0,\dots,7\} \to \mathbb{Z}_7$ — the collision probability jumps to $1$. The value function is $1/m$ on $2 \le n \le m$ and $1$ immediately after, with no transition region.

---

## 10. Algorithms

Three computational primitives support the results.

**Algorithm A: exact collision probability of a finite family.** Given a finite index set with weights and a family of hash functions on a key set, compute $\Pr[\mathrm{Coll}]$ by summing the weights of the indices at which the hash function is non-injective on the key set. Complexity: $O(|\Omega| \cdot n)$ using a bucket-membership array per index. This is what verifies the table of Section 9 and, more importantly, lets one test candidate extremal families directly.

**Algorithm B: exact-universality certification.** Given the same data, compute $\Pr[h(x) = h(y)]$ for every one of the $\binom{n}{2}$ pairs and compare to $1/m$ (exactly, in rational arithmetic). Complexity $O(|\Omega| \cdot n^2)$. Certification in exact arithmetic matters: with floating point, "exactly $2$-universal" cannot be distinguished from "within $10^{-16}$ of it", and Theorem 8.4 shows the two hypotheses have entirely different extremal answers.

**Algorithm C: extremal value evaluation.** Given $(m, n)$ with $n \ge 2$, return $1/m$ if $n \le m$ and $1$ otherwise. Constant time — the point being that the closed form is a theorem (Theorem 7.4), not an approximation, and that the difficult direction (the lower bound) is exactly what makes the value a *minimum* rather than merely an achieved value.

A fourth routine is useful for exploration: interpolate between the two branches of Definition 7.1, giving the bijection branch mass $1 - t$ and the constant branch mass $t$ for $t \in [0,1]$. The resulting family has pair-collision probability exactly $t$ and collision probability exactly $t$, so it is exactly $2$-universal precisely at $t = 1/m$ and traces out the *entire* interval of collision probabilities as $t$ varies. Scanning $t$ makes the role of the axiom visible: the constraint $t = 1/m$ is what selects the extremal value out of a continuum, and relaxing it to $t \le 1/m$ (the inequality axiom) immediately allows $t = 0$, in agreement with Theorem 8.4.

---

## 11. Discussion and future directions

### 11.1 What the theorem says about practice

Practitioners already know that a $2$-universal hash table has a small but irreducible probability of clustering. The theorem quantifies the irreducibility: no design effort, no increase in the family size, no clever weighting can push the probability of *some* collision among $n$ keys below $1/m$, as long as one insists on the exact Carter–Wegman guarantee. If a design *does* beat $1/m$, then some pair of keys must collide with probability strictly less than $1/m$ — the family is *better than random* on that pair, which is what a perfect hash for a known key set does, and which is precisely what the adversarial setting forbids one to rely on.

The second reading is a design principle. The extremal families are all-or-nothing: their failure mode is total collapse. This suggests that among exactly $2$-universal families there is a genuine trade-off between the *probability* of a collision and the *severity* of one, and that the families minimising collision probability are the worst possible choices from the standpoint of graceful degradation. Quantifying this trade-off — minimising, say, the expected maximum bucket load subject to exact $2$-universality — is an attractive open direction and is not addressed here.

### 11.2 Relation to the union bound literature

The union bound and its Bonferroni refinements bound $\Pr[\bigcup A_i]$ from above and below in terms of low-order joint probabilities. Proposition 2.3 gives one such lower bound, but for the collision structure it is useless: with $\Pr[A_i] = 1/m$ for all $\binom{n}{2}$ pairs, the Bonferroni lower bound is $\binom{n}{2}/m$ minus a quadratic correction, which is negative as soon as pairs overlap significantly. What makes Theorem 4.2 work is not a Bonferroni-type inclusion–exclusion but the *boundedness* of the counter, which is a purely combinatorial input (there are only $n(n-1)$ ordered pairs). This is worth emphasising: the converse to the union bound here comes from a counting cap, not from correlation control.

### 11.3 Future directions

The following directions are stated so that each can be falsified.

**1. The second-moment profile of extremal families.** *Conjecture.* Among exactly $2$-universal families on $n \ge 3$ keys and $m$ buckets, the minimum of the second moment $\mathbb{E}[X^2]$ of the collision counter equals
$$\frac{n(n-1)\big(n(n-1) - (n-2)(n+1)/m\big)}{m},$$
attained by the affine family; equivalently, minimising $\Pr[\mathrm{Coll}]$ and minimising $\mathbb{E}[X^2]$ are achieved by the same extremal point of the universality polytope. The key insight is that the reverse Markov inequality $\Pr[X>0] \ge \mathbb{E}[X]/\max X$ is tight exactly when $X$ is $\{0, \max\}$-valued, which is precisely the behaviour of the affine family ($X \in \{0, n(n-1)\}$), so the extremal family is characterised by a *degenerate second moment*, not merely by a small mean. Both the Chung–Erdős inequality and the second-moment collision bound are already available (Propositions 2.5 and Theorem 4.5), so the conjecture concerns a quantity the framework can already express and bound.

**2. Strong universality of the extremal mixture.** The composite-$m$ attainment is a theorem (Theorem 7.4): the mixture of a uniformly random bijection (mass $1 - 1/m$) with a uniformly random constant (mass $1/m$) is exactly $2$-universal for every $m$ and attains $1/m$. What remains open is whether the extremal family is *strongly* $2$-universal. *Conjecture.* For every $m \ge 2$ the bijection–constant mixture is pairwise independent: $\Pr[h(x) = u,\ h(y) = v] = 1/m^2$ for all $u, v$ and all distinct keys $x, y$. Consequently the extremal value $1/m$ would be attained inside the class of strongly $2$-universal families for every $m$, not only for primes. The key insight is that pairwise independence for the mixture reduces to the permutation count $|\{\sigma : \sigma(x) = u,\ \sigma(y) = v\}| = (m-2)!$ for $u \ne v$, weighted by the bijection-branch mass, plus the constant-branch contribution when $u = v$; the two cases must both yield $1/m^2$, which is an identity in $m$ rather than a structural condition.

**3. Severity versus probability.** Formulate and solve the bi-objective problem: over exactly $2$-universal families, characterise the Pareto frontier of $(\Pr[\mathrm{Coll}],\ \mathbb{E}[\text{max bucket load}])$. Theorem 7.3 shows that the probability-minimising vertex has the worst possible load profile; the affine family, with the same probability, has the same profile, which suggests the frontier may be degenerate at the extremal probability and interesting only strictly above it.

**4. $k$-wise generalisation.** For exactly $k$-universal families ($k \ge 3$), is the minimum probability of a $k$-fold coincidence among $n \ge k$ keys equal to $1/m^{k-1}$, again independently of $n$? The same reverse Markov argument applied to the counter of ordered $k$-tuples gives the lower bound immediately; the question is attainment, and whether an all-or-nothing family exists in that regime for every $m$.

**5. Constrained index sets.** Theorem 5.5 shows that a uniformly weighted exactly $2$-universal family must have $m \mid |\Omega|$. What is the minimum size $|\Omega|$ of a uniformly weighted exactly $2$-universal family on $n$ keys and $m$ buckets attaining collision probability $1/m$? For $m = p$ prime, the affine family gives $p^2$; is $p^2$ optimal, or can $|\Omega| = p \cdot k$ with $k < p$ suffice?

---

## 12. Summary of results

| Statement | Content |
|---|---|
| Union bound endpoint | $2$-universal $\Rightarrow \Pr[\mathrm{Coll}] \le \binom{n}{2}/m$ |
| Converse endpoint | exactly $2$-universal, $n \ge 2$ $\Rightarrow \Pr[\mathrm{Coll}] \ge 1/m$ |
| Birthday sandwich | $1/m \le \Pr[\mathrm{Coll}] \le \binom{n}{2}/m$ |
| Affine sharpness | affine family over $\mathbb{Z}_p$ has $\Pr[\mathrm{Coll}] = 1/p$ for all $2 \le n \le p$ |
| Strong universality | affine family is pairwise independent |
| Divisibility obstruction | uniform exactly $2$-universal family $\Rightarrow m \mid |\Omega|$ |
| Pigeonhole degeneration | $n > m \Rightarrow \Pr[\mathrm{Coll}] = 1$ for every family |
| Extremal value function | $\min \Pr[\mathrm{Coll}] = 1/m$ for $2 \le n \le m$, $=1$ for $n > m$, every $m$ |
| Prime-free attainment | bijection–constant mixture is exactly $2$-universal with $\Pr[\mathrm{Coll}] = 1/m$ |
| Necessity of exactness | inequality-only axiom $\Rightarrow$ extremal value $0$ ($n \le m$) or $1$ ($n>m$) |
| First-moment optimality | every function collides on $\ge n^2/m - n$ ordered pairs; gap $= n(1-1/m)$ |
| Second-moment refinement | $\Pr[\mathrm{Coll}] \ge \mathbb{E}[X]^2/\mathbb{E}[X^2]$, equal to $1/m$ at the extremal families |
