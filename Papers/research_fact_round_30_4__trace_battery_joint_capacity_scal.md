# Joint Capacity of a Battery of Bounded-Modulus Dials: Monotone Scaling, Two Ceilings, and Wall Inversion

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $\Omega$ be a finite population and let a *dial* on $\Omega$ be a reading
$r : \Omega \to \mathbb{N}$ with a modulus $m \ge 1$ satisfying $r(x) < m$ for
all $x$. A *battery* is a finite family of dials; for a subset $S$ of the
battery, the *joint capacity* $C(S)$ is the Shannon capacity, in bits, of the
tuple-valued joint reading, computed against the uniform measure on $\Omega$.
Because readings are deterministic functions of the individual, $C(S)$ coincides
exactly with the mutual information between an individual and the readings of
the dials in $S$, and is therefore a purely combinatorial invariant of the
partition of $\Omega$ induced by $S$.

We develop the exact finitary Shannon calculus needed for this setting and
establish six structural results with no numerical input: (i) **monotone
scaling**, $S \subseteq T \Rightarrow C(S) \le C(T)$; (ii) a **strict scaling
criterion**, giving $C(S) < C(T)$ as soon as some dial of $T$ separates two
individuals confused by all of $S$; (iii) the **multiplicative (CRT) ceiling**
$C(S) \le \log_2 \prod_{i \in S} m_i$; (iv) the **sample ceiling**
$C(S) \le \log_2 |\Omega|$, independent of the moduli; (v) the **per-dial
budget** $C(S) \le \sum_{i \in S} C(\{i\})$; and (vi) **sharpness**: any
separating reading has capacity exactly $\log_2 |\Omega|$, and on
$\mathbb{Z}/31 \times \mathbb{Z}/23$ the two-coordinate battery attains
$\log_2 713$ exactly, so the multiplicative ceiling is not an artefact of the
estimate.

We then apply the theory to a reported measurement of a four-dial battery with
moduli $31, 23, 9, 8$ on an independent population, whose nested sub-batteries
gave $7.9455$, $10.4462$, $12.1080$ bits against cell counts $713$, $6\,417$,
$51\,336$. We show that the monotonicity and both ceiling constraints are
satisfied and, crucially, that they were *forced*: the informative content of
the measurement is not the trend but the shortfall against the ceilings and the
eighty-fold spread of per-dial values, which we prove separates a *saturated*
modulus-$11$ dial (whose ceiling $\log_2 11 = 3.4594\ldots$ lies within $0.001$
bits of the reported $3.46$) from a *nearly blind* modulus-$31$ dial (ceiling
$> 4.9$ bits, reported $0.04$). We further show that the per-dial budget acts as
a falsification test which the reported figures fail: a $0.04$-bit dial can
contribute at most $0.04$ bits to any battery, so the reported pair value
$7.9455$ exceeds its cap $0.04 + \log_2 23 = 4.5636$ by $3.38$ bits, whence the
per-dial and joint tables cannot describe the same dials on the same population.
Finally we prove that a binary "which-factor"
readout has capacity exactly the binary entropy of its class imbalance, whence a
reported wall value **inverts**: it is a sufficient statistic for the imbalance,
and the reported $0.4677$ bits determines a class split of $p \approx 0.0996$.
We conclude with a program for closing the remaining gap — a lower-bound theory
of sample-limited capacity.

**Keywords:** empirical Shannon entropy, joint channel capacity, data
processing inequality, Chinese Remainder Theorem, subadditivity, binary entropy,
sparse-table bias, dial battery.

---

## 1. Introduction

### 1.1 The measurement problem

A recurring pattern in applied combinatorics is the following. One has a finite
population $\Omega$ — genotypes, database records, group elements, integers in a
range — and a family of coarse, cheap *readings* of that population, each taking
values in a small finite alphabet. Individually the readings are almost useless;
jointly they may or may not identify individuals. The practical question is how
much identifying power the family has, and how that power grows as readings are
added.

The natural currency is information. If we sample an individual $x$ uniformly
from $\Omega$ and observe the tuple of readings, the mutual information between
$x$ and the observation measures, in bits, the average reduction in the log-size
of the candidate set. Since the readings are deterministic, the conditional
entropy of the observation given $x$ vanishes, and the mutual information equals
the entropy of the observation. This is a purely combinatorial quantity: the
entropy of the block-size distribution of the partition of $\Omega$ into
level sets.

We call a bounded-alphabet reading a **dial**, a family of dials a **battery**,
and the resulting quantity the **joint capacity** of the battery. This paper
determines the structural laws obeyed by joint capacity, proves each of them
sharp or explains why it is not, and uses them to audit a concrete measurement.

### 1.2 The measurement to be audited

A four-dial battery with moduli $31$, $23$, $9$, $8$ was read on a population of
several thousand individuals. Three nested sub-batteries were reported:

| sub-battery | cells $M = \prod_{i \in S} m_i$ | measured $C(S)$ |
|---|---|---|
| moduli $\{31, 23\}$ | $713$ | $7.9455$ |
| moduli $\{31, 23, 9\}$ | $6\,417$ | $10.4462$ |
| moduli $\{31, 23, 9, 8\}$ | $51\,336$ | $12.1080$ |

Per-dial capacities across the wider instrument ranged over a factor of eighty:
a modulus-$11$ dial carried $3.46$ bits, a modulus-$31$ dial carried $0.04$
bits. A binary "which-factor" readout was reported to be capped at $0.4677$
bits. The verdict attached to the experiment was that the joint capacity scales
with battery size, replicating an earlier finding on an independent population.

Our thesis is that a replication of this kind must be decomposed before it can
be believed to say anything. Some of what was observed is a theorem and could
not have failed; some is a genuine measurement of the population. Sections 3–6
establish the theorems; Section 7 performs the decomposition.

### 1.3 Contributions

1. A self-contained exact finitary Shannon calculus for deterministic statistics
   on finite populations: maximum-entropy bound, data processing, strict data
   processing, invariance under relabelling, positivity, and subadditivity
   (Section 2).
2. Monotone and strictly monotone scaling laws for joint capacity of batteries
   (Section 3).
3. Two independent ceilings — multiplicative and sample — with a proof that the
   multiplicative one is attained, via a Chinese Remainder witness (Sections 4
   and 5).
4. A per-dial budget by subadditivity over the battery, an increment bound
   showing that no dial ever contributes more jointly than it is worth alone,
   and the resulting falsification test — which the reported figures fail,
   proving that the per-dial and joint tables cannot describe the same dials on
   the same population (Sections 6 and 7.4).
5. Exact inversion of a binary "wall" value into a class imbalance, making a
   reported wall a sufficient statistic and yielding a falsifiable
   cross-population prediction (Section 8).
6. Numerical certificates for every inequality relating the reported table to
   its ceilings, including the delicate $\log_2 11 < 3.46$ (Section 7).

---

## 2. The finitary Shannon calculus

Throughout, $\Omega$ is a finite nonempty set with $N = |\Omega|$, and a
*statistic* is any function $f : \Omega \to A$ into an arbitrary set.

### 2.1 Definitions

**Definition 2.1 (fibres and counts).** For $a \in A$, the *fibre* is
$f^{-1}(a) = \{x \in \Omega : f(x) = a\}$; its cardinality is written $n_a$ or
$\mathrm{cnt}_f(a)$. The *image* $\mathrm{img}(f)$ is the finite set of attained
values. Trivially $\sum_{a \in \mathrm{img}(f)} n_a = N$ and $n_a \ge 1$ for
attained $a$.

**Definition 2.2 (empirical entropy).** The *empirical entropy* of $f$, in nats,
is
$$H(f) \;=\; \sum_{a \in \mathrm{img}(f)} \frac{n_a}{N}\,\log\frac{N}{n_a}.$$
The *capacity in bits* is $C(f) = H(f)/\log 2$.

$H(f)$ is the Shannon entropy of the push-forward under $f$ of the uniform
measure on $\Omega$. Since $f$ is deterministic, $H(f) = I(x ; f(x))$ for $x$
uniform: capacity is mutual information.

Two immediate special cases anchor the scale. If $f$ is constant, the sum has one
term with $n_a = N$ and $H(f) = 0$. If $f$ is injective, the sum has $N$ terms
each equal to $(1/N)\log N$, so $H(f) = \log N$.

### 2.2 Non-negativity and the maximum-entropy bound

**Proposition 2.3 (non-negativity).** $H(f) \ge 0$.

*Proof.* Each attained $a$ has $1 \le n_a \le N$, so $N/n_a \ge 1$ and
$\log(N/n_a) \ge 0$; all terms are non-negative. $\square$

**Theorem 2.4 (alphabet ceiling / maximum entropy).** Let
$K = |\mathrm{img}(f)|$. Then $H(f) \le \log K$.

*Proof sketch.* This is the Gibbs estimate against the uniform distribution on
the attained alphabet. Write $p_a = n_a/N$. For each attained $a$ apply
$\log t \le t-1$ with $t = \frac{1}{p_a K}$, i.e.
$$\log \frac{1}{p_a} \;=\; \log\frac{1}{p_a K} + \log K \;\le\; \Bigl(\frac{1}{p_a K} - 1\Bigr) + \log K .$$
Multiplying by $p_a \ge 0$ and summing over the $K$ attained values gives
$$H(f) \;\le\; \sum_a p_a \log K + \sum_a\Bigl(\frac{1}{K} - p_a\Bigr) \;=\; \log K + (1 - 1) \;=\; \log K,$$
using $\sum_a p_a = 1$ and that there are exactly $K$ summands. $\square$

**Corollary 2.5 (sample ceiling / sparse-table bias).** $H(f) \le \log N$ for
every statistic $f$, regardless of its alphabet.

*Proof.* $K = |\mathrm{img}(f)| \le |\Omega| = N$, and $\log$ is monotone.
$\square$

Corollary 2.5 is the formal content of what practitioners call sparse-table
bias: an entropy estimated from an $N$-row table cannot exceed $\log_2 N$ bits
no matter how many cells the table has. It is also, read backwards, a lower
bound on population size implied by any reported capacity.

### 2.3 Data processing

**Definition 2.6 (coarsening).** A statistic $g \circ f$ obtained by
post-composing $f$ with a map $g$ on labels is a *coarsening* of $f$: each block
of $g \circ f$ is a disjoint union of blocks of $f$.

**Lemma 2.7 (fibrewise splitting).** For any $g$,
$$H(f) \;=\; \sum_{b \in \mathrm{img}(g \circ f)} \ \sum_{\substack{a \in \mathrm{img}(f) \\ g(a) = b}} \frac{n_a}{N}\log\frac{N}{n_a},$$
and moreover $\sum_{a : g(a) = b} n_a = \mathrm{cnt}_{g \circ f}(b)$ for each
attained $b$.

*Proof.* The map $a \mapsto g(a)$ sends $\mathrm{img}(f)$ into
$\mathrm{img}(g \circ f)$, so the defining sum for $H(f)$ may be grouped along
its fibres; the count identity is the disjoint decomposition of a coarse fibre
into fine fibres. $\square$

**Theorem 2.8 (data processing inequality).** $H(g \circ f) \le H(f)$.

*Proof sketch.* Fix an attained $b$ and write $n_b^{\,\mathrm{c}}$ for its coarse
count. Every fine label $a$ over $b$ has $n_a \le n_b^{\,\mathrm{c}}$, hence
$\log(N/n_b^{\,\mathrm{c}}) \le \log(N/n_a)$. Therefore
$$\frac{n_b^{\,\mathrm{c}}}{N}\log\frac{N}{n_b^{\,\mathrm{c}}}
= \sum_{a : g(a)=b} \frac{n_a}{N}\log\frac{N}{n_b^{\,\mathrm{c}}}
\le \sum_{a : g(a)=b} \frac{n_a}{N}\log\frac{N}{n_a},$$
where the first equality uses the count identity of Lemma 2.7. Summing over $b$
and applying Lemma 2.7 to the right-hand side gives
$H(g\circ f) \le H(f)$. $\square$

**Theorem 2.9 (strict data processing).** Suppose there exist $x, y \in \Omega$
with $f(x) \ne f(y)$ but $g(f(x)) = g(f(y))$. Then $H(g \circ f) < H(f)$.

*Proof sketch.* Let $b = g(f(x))$. The coarse fibre over $b$ contains at least
the two distinct fine labels $f(x)$ and $f(y)$, both with positive counts, so
$n_{f(x)} < n_b^{\,\mathrm{c}}$ *strictly*. Then
$\log(N/n_b^{\,\mathrm{c}}) < \log(N/n_{f(x)})$ strictly, and multiplying by the
positive weight $n_{f(x)}/N$ makes the $a = f(x)$ term of the displayed estimate
in Theorem 2.8 strict. A sum of valid inequalities with at least one strict term
is strict. $\square$

**Proposition 2.10 (relabelling is free).** If $g$ is injective on
$\mathrm{img}(f)$ then $H(g \circ f) = H(f)$.

*Proof.* The fibres are in bijection with equal counts, and the defining sum is
reindexed by the injection. $\square$

**Proposition 2.11 (separation implies positivity).** If $f(x) \ne f(y)$ for
some $x, y$, then $H(f) > 0$.

*Proof.* The fibre over $f(x)$ omits $y$, hence $n_{f(x)} < N$ and the
corresponding term $\frac{n_{f(x)}}{N}\log\frac{N}{n_{f(x)}}$ is strictly
positive; all other terms are non-negative. $\square$

### 2.4 Subadditivity

**Theorem 2.12 (subadditivity for a pair).** For statistics $f$ and $g$ on the
same population,
$$H\bigl(x \mapsto (f(x), g(x))\bigr) \;\le\; H(f) + H(g).$$

*Proof sketch.* Write $p_c = n_c/N$ for the joint block probabilities,
$c = (a,b)$, and let $q_a, r_b$ be the marginal probabilities; note that the
joint image is contained in $\mathrm{img}(f) \times \mathrm{img}(g)$ and that
summing $p_{(a,b)}$ over $b$ gives $q_a$ (and symmetrically). Apply
$\log t \le t - 1$ with $t = q_a r_b / p_{(a,b)}$, so that
$$\log\frac{1}{p_c} \;=\; \log\frac{1}{q_a} + \log\frac{1}{r_b} + \log\frac{q_a r_b}{p_c}
\;\le\; \log\frac{1}{q_a} + \log\frac{1}{r_b} + \frac{q_a r_b}{p_c} - 1 .$$
Multiply by $p_c$ and sum over the attained joint labels. The first two groups of
terms collapse to $H(f)$ and $H(g)$ by the marginal identities; the remainder is
$\sum_c q_a r_b - \sum_c p_c \le 1 - 1 = 0$, since the joint image is a subset of
the product of the images. $\square$

The slack in Theorem 2.12 is exactly the mutual information $I(f;g)$ between the
two statistics; equality holds iff $f$ and $g$ are independent under the uniform
measure on $\Omega$.

---

## 3. Batteries of dials and monotone scaling

**Definition 3.1 (dial).** A *dial* on $\Omega$ is a triple $(m, r)$ where
$m \ge 1$ is the *modulus* and $r : \Omega \to \mathbb{N}$ is the *reading*,
subject to $r(x) < m$ for all $x \in \Omega$.

**Definition 3.2 (battery, joint reading, joint capacity).** A *battery* is a
family $d = (d_i)_{i \in \iota}$ of dials indexed by a finite set $\iota$. For a
subset $S \subseteq \iota$, the *joint reading* is
$$\mathrm{jt}_S : \Omega \to \mathbb{N}^S, \qquad \mathrm{jt}_S(x) = \bigl(r_i(x)\bigr)_{i \in S},$$
and the *joint capacity* is $C(S) = H(\mathrm{jt}_S)/\log 2$ bits. The *per-dial
capacity* is $c_i = H(r_i)/\log 2$.

By Proposition 2.3, $C(S) \ge 0$ always, and $C(\emptyset) = 0$ since the empty
tuple is constant.

**Lemma 3.3 (restriction is a coarsening).** For $S \subseteq T$, let
$\pi_{S,T} : \mathbb{N}^T \to \mathbb{N}^S$ be the coordinate projection. Then
$\mathrm{jt}_S = \pi_{S,T} \circ \mathrm{jt}_T$.

*Proof.* Both sides evaluate at $x$ and $i \in S$ to $r_i(x)$. $\square$

**Theorem 3.4 (monotone scaling).** If $S \subseteq T$ then
$C(S) \le C(T)$.

*Proof.* Combine Lemma 3.3 with Theorem 2.8 and divide by $\log 2 > 0$.
$\square$

**Theorem 3.5 (strict scaling criterion).** Let $S \subseteq T$. Suppose there
are individuals $x, y \in \Omega$ with $\mathrm{jt}_S(x) = \mathrm{jt}_S(y)$ —
i.e. every dial of $S$ confuses $x$ and $y$ — and some index $i \in T$ with
$r_i(x) \ne r_i(y)$. Then $C(S) < C(T)$ strictly.

*Proof.* The dial $i$ separates $x$ and $y$, so
$\mathrm{jt}_T(x) \ne \mathrm{jt}_T(y)$; and applying $\pi_{S,T}$ to both sides
recovers $\mathrm{jt}_S(x) = \mathrm{jt}_S(y)$, so the coarsening merges them.
Theorem 2.9 applies with $f = \mathrm{jt}_T$, $g = \pi_{S,T}$. $\square$

**Example 3.6 (the criterion is not vacuous).** Take $\Omega = \{0,1,2,3\}$ with
two dials of modulus $2$: the parity dial $r_0(x) = x \bmod 2$ and the half dial
$r_1(x) = \lfloor x/2 \rfloor$. The parity dial confuses $0$ and $2$; the half
dial separates them. Hence $C(\{0\}) < C(\{0,1\})$; explicitly $1 < 2$ bits,
since parity splits $\Omega$ into two blocks of size $2$ while the pair of dials
is injective.

Theorems 3.4 and 3.5 already dispose of the qualitative part of the reported
verdict: for *any* population and *any* battery whatsoever, the joint capacities
of a nested chain of sub-batteries increase, and they increase strictly exactly
when each new dial resolves at least one collision left by its predecessors.

---

## 4. The multiplicative (CRT) ceiling

**Lemma 4.1 (cell count).** For any battery and any $S$,
$$\bigl|\mathrm{img}(\mathrm{jt}_S)\bigr| \;\le\; \prod_{i \in S} m_i .$$

*Proof.* The joint reading takes values in the product
$\prod_{i \in S}\{0, 1, \dots, m_i - 1\}$, because $r_i(x) < m_i$ for every $i$
and $x$. That product has $\prod_{i \in S} m_i$ elements. $\square$

**Theorem 4.2 (multiplicative ceiling).** For any battery and any $S$,
$$C(S) \;\le\; \log_2 \prod_{i \in S} m_i .$$

*Proof.* Theorem 2.4 gives $C(S) \le \log_2 |\mathrm{img}(\mathrm{jt}_S)|$;
apply Lemma 4.1 and monotonicity of $\log_2$. $\square$

We call this the *CRT ceiling* because for coprime moduli the product
$\prod m_i$ is the size of the Chinese-Remainder target $\prod \mathbb{Z}/m_i$
into which residue dials naturally map, and Section 5 shows that the ceiling is
attained exactly in that setting.

**Theorem 4.3 (sample ceiling).** For any battery and any $S$,
$$C(S) \;\le\; \log_2 N, \qquad N = |\Omega|,$$
independently of the moduli.

*Proof.* Corollary 2.5 applied to $\mathrm{jt}_S$. $\square$

**Remark 4.4 (which ceiling binds).** The effective ceiling is
$\min\{\log_2 \prod_{i \in S} m_i, \log_2 N\}$. When $N \ll M = \prod m_i$ the
sample ceiling binds and the measured capacity is a statement about the
population, not the instrument; when $M \ll N$ the multiplicative ceiling binds
and the measurement is instrument-limited. The transition happens at
$N \approx M$, and near it neither bound is tight: for a uniformly random assignment of $N$
rows to $M$ cells the expected number of occupied cells is
$M\bigl(1 - (1 - 1/M)^N\bigr)$, and the capacity lies between $\log_2$ of a
concentration lower bound on that count and $\min\{\log_2 M, \log_2 N\}$. Making
this precise is Problem 1 of Section 9.

**Remark 4.5 (non-coprime moduli).** Lemma 4.1 uses only the alphabet sizes, so
Theorem 4.2 holds for arbitrary moduli; but for genuine residue dials on a
cyclic population, non-coprime moduli make the joint reading factor through
$\mathbb{Z}/\mathrm{lcm}(m_i)$, so the true ceiling is $\log_2 \mathrm{lcm}$,
strictly smaller than $\log_2 \prod m_i$ whenever the moduli share a factor.
Sharpening Theorem 4.2 to this exact value is Problem 2 of Section 9. For the
audited battery the moduli $31, 23, 9, 8$ are pairwise coprime, so
$\mathrm{lcm} = \prod = 51\,336$ and no correction applies.

---

## 5. Sharpness: the multiplicative ceiling is attained

**Theorem 5.1 (separating statistics saturate the sample ceiling).** If
$f : \Omega \to A$ is injective then $H(f)/\log 2 = \log_2 N$ exactly.

*Proof.* Every attained label has $n_a = 1$, so $|\mathrm{img}(f)| = N$ by the
count identity $\sum_a n_a = N$, and
$H(f) = \sum_{a} \frac{1}{N}\log N = \log N$. $\square$

**Theorem 5.2 (Chinese Remainder witness).** Let
$\Omega = \mathbb{Z}/31 \times \mathbb{Z}/23$, a population of exactly
$N = 713$ individuals, and let the battery consist of the two dials
$r_1(x) = $ the representative of the first coordinate (modulus $31$) and
$r_2(x) = $ the representative of the second coordinate (modulus $23$). Then
$$C(\{1,2\}) \;=\; \log_2 713 \;=\; \log_2 (31 \cdot 23),$$
i.e. the multiplicative ceiling of Theorem 4.2 is attained with equality.

*Proof.* The joint reading is injective: if two elements have the same residues
in both coordinates, they are equal, since the canonical representative map
$\mathbb{Z}/m \to \{0, \dots, m-1\}$ is a bijection. (Equivalently, by the
Chinese Remainder Theorem the pair of residues modulo the coprime moduli $31$
and $23$ determines an element of $\mathbb{Z}/713$.) Apply Theorem 5.1 with
$N = 31 \cdot 23 = 713$; the value coincides with the ceiling
$\log_2(31\cdot 23)$ of Theorem 4.2. $\square$

**Corollary 5.3 (shortfalls are data).** Since Theorem 4.2 is attained, any
observed gap between a measured $C(S)$ and $\log_2 \prod_{i\in S} m_i$ is a
property of the population being measured — a quantification of collisions in
the joint reading — and not slack in the inequality.

Corollary 5.3 is what licenses the interpretation in Section 7. Without a
witness of attainment, a shortfall would be uninformative: it could be an
artefact of a loose estimate.

---

## 6. The per-dial budget

**Theorem 6.1 (per-dial budget).** For any battery and any finite $S$,
$$C(S) \;\le\; \sum_{i \in S} c_i,$$
where $c_i$ is the per-dial capacity of dial $i$.

*Proof.* Induction on $S$. For $S = \emptyset$ the joint reading is constant, so
$C(\emptyset) = 0$ and the empty sum is $0$. For the inductive step, write
$S' = \{a\} \cup S$ with $a \notin S$. The map
$$u \;\longmapsto\; \bigl(u_a,\ (u_i)_{i \in S}\bigr)$$
from $\mathbb{N}^{S'}$ to $\mathbb{N} \times \mathbb{N}^{S}$ is injective — it
merely reorganises the tuple — and composing it with $\mathrm{jt}_{S'}$ yields
the pair statistic $x \mapsto (r_a(x), \mathrm{jt}_S(x))$. By Proposition 2.10
this relabelling leaves the entropy unchanged, so
$$C(S') = C\bigl(x \mapsto (r_a(x), \mathrm{jt}_S(x))\bigr) \le c_a + C(S)$$
by Theorem 2.12. The inductive hypothesis $C(S) \le \sum_{i \in S} c_i$ finishes
the step. $\square$

**Remark 6.2 (the slack is mutual information).** The slack in Theorem 6.1 is a
sum of mutual informations among the dials, so the budget is tight exactly for a
battery whose dials are mutually independent across the population.

**Corollary 6.3 (increment bound).** For $a \notin S$,
$$C(\{a\} \cup S) \;-\; C(S) \;=\; C\bigl(r_a \mid \mathrm{jt}_S\bigr) \;\le\; c_a ,$$
where the conditional capacity $C(r_a \mid \mathrm{jt}_S)$ is the average, over
blocks of $\mathrm{jt}_S$, of the capacity of $r_a$ restricted to that block.

*Proof.* The chain rule identity is the fibrewise splitting of Lemma 2.7 applied
to the pair statistic $(r_a, \mathrm{jt}_S)$, using Proposition 2.10 to identify
that pair with $\mathrm{jt}_{\{a\}\cup S}$. The inequality is the pair form of
Theorem 2.12, i.e. non-negativity of the mutual information
$I(r_a ; \mathrm{jt}_S)$. $\square$

Corollary 6.3 is worth stating explicitly because it forecloses an attractive
heuristic. One might expect that a dial which is nearly constant globally — and
hence has a tiny solo capacity — could nevertheless split exactly the right
collisions of an existing sub-battery and so contribute far more jointly than it
does alone. Conditioning can only *decrease* the capacity of a statistic, so this
is impossible: no dial ever contributes more to a battery than it is worth by
itself. Section 7.4 turns this into a falsification test.

---

## 7. Auditing the measurement

We now apply Sections 3–6 to the reported table. Every inequality below is a
consequence of the theorems together with an elementary integer certificate; no
statistical assumption is used.

### 7.1 The trend and the ceilings were forced

The three sub-batteries are nested, so Theorem 3.4 forces
$C(S_1) \le C(S_2) \le C(S_3)$: the observation
$7.9455 \le 10.4462 \le 12.1080$ carries no information beyond a check that the
pipeline computes a monotone quantity monotonically.

Theorem 4.2 forces each value below its cell-count logarithm. Certificates:

* $2^{8} = 256 \le 713$, hence $\log_2 713 \ge 8 > 7.9455$;
* $2^{12} = 4096 \le 6417$, hence $\log_2 6417 \ge 12 > 10.4462$;
* $2^{15} = 32768 \le 51336$, hence $\log_2 51336 \ge 15 > 12.1080$.

Thus all three measurements are strictly admissible, with actual ceilings
$\log_2 713 = 9.4781\ldots$, $\log_2 6417 = 12.6479\ldots$,
$\log_2 51336 = 15.6478\ldots$.

Theorem 4.3 forces each value below $\log_2 N$. Read backwards, the top value
implies
$$N \;\ge\; 2^{12.1080} \;\approx\; 4415,$$
so the reported figure is only attainable on a population of at least about
$4\,400$ individuals. This is a genuine, checkable constraint that the reporting
of a capacity places on the reporting of a sample size.

We record the combined statement, which holds for every population and every
battery with the given moduli:

> **Theorem 7.1 (audited scaling).** Let $\Omega$ be any finite nonempty
> population and let $d_0, d_1, d_2, d_3$ be any dials on $\Omega$ with moduli
> $31, 23, 9, 8$ respectively. Put $S_1 = \{0,1\}$, $S_2 = \{0,1,2\}$,
> $S_3 = \{0,1,2,3\}$. Then
> $$C(S_1) \le C(S_2) \le C(S_3), \qquad C(S_1) \le \log_2 713, \quad C(S_2) \le \log_2 6417,$$
> $$C(S_3) \le \log_2 51336, \qquad C(S_3) \le \log_2 |\Omega| .$$

*Proof.* Monotonicity is Theorem 3.4 applied twice; the three product bounds are
Theorem 4.2 with $31 \cdot 23 = 713$, $31 \cdot 23 \cdot 9 = 6417$,
$31 \cdot 23 \cdot 9 \cdot 8 = 51336$; the last is Theorem 4.3. $\square$

### 7.2 The shortfalls are not forced

By Corollary 5.3 the ceilings of Theorem 7.1 are attainable, so the gaps
$$9.478 - 7.946 = 1.532, \qquad 12.648 - 10.446 = 2.202, \qquad 15.648 - 12.108 = 3.540$$
bits are measurements. Each gap is a log-scale count of collisions: if the joint
reading of $S$ attains $K_S$ distinct cells out of $M_S$, then
$C(S) \le \log_2 K_S$, so a shortfall of $\delta$ bits below $\log_2 M_S$
implies at most $M_S 2^{-\delta}$ cells are occupied *or* the occupied cells are
unevenly loaded. Observe that the gaps *grow* as dials are added — $1.53$, then
$2.20$, then $3.54$ — which is exactly the signature of an increasingly sparse
table: with $N \approx 4\,400$ rows, the first sub-battery has more rows than
cells ($4400 > 713$) while the last has an order of magnitude more cells than
rows ($51\,336 \gg 4\,400$), so the binding constraint migrates from the
multiplicative ceiling to the sample ceiling as the battery grows. Indeed, if
the population is of order $4\,400$ to $5\,000$, the sample ceiling $\log_2 N$
lies between $12.10$ and $12.29$ bits, so the final measured value $12.108$ sits
within a fraction of a bit of it: the battery has essentially exhausted its
population, and further dials can buy almost nothing without more individuals.

### 7.3 The per-dial spread separates saturation from blindness

The reported per-dial extremes admit sharp, certified interpretations.

**Proposition 7.2 (a modulus-$11$ dial cannot exceed $3.46$ bits).** Any dial of
modulus $11$ on any finite nonempty population has capacity
$c \le \log_2 11 < 3.46$.

*Proof.* The image has at most $11$ elements, so Theorem 2.4 gives
$c \le \log_2 11$. For the numerical part, $11^{50} < 2^{173}$ — a comparison of
two explicit integers — gives $50 \log_2 11 < 173$, i.e.
$\log_2 11 < 3.46$. $\square$

Since $\log_2 11 = 3.45943\ldots$, the reported $3.46$ bits for the modulus-$11$
dial is the rounding of a value within $0.0006$ bits of its own ceiling: this
dial is **saturated**, distributing the population as evenly across its eleven
positions as it is possible to do.

**Proposition 7.3 (a modulus-$31$ dial has ceiling above $4.9$ bits).** Any dial
of modulus $31$ has capacity $c \le \log_2 31$, and $\log_2 31 > 4.9$.

*Proof.* The first part is Theorem 2.4 with $|\mathrm{img}| \le 31$. For the
second, $2^{49} < 31^{10}$ gives $49 < 10\log_2 31$. $\square$

Since $\log_2 31 = 4.9542\ldots$ and the modulus-$31$ dial reported $0.04$ bits,
this dial sits at about $0.8\%$ of its ceiling: it is **nearly blind**, not
resolution-limited. Concretely, a capacity of $0.04$ bits from a binary-like
split corresponds (by the binary law of Section 8) to a minority class of well
under $1\%$ of the population.

The reported eighty-fold spread of per-dial capacities is therefore not a defect
of the instrument but a real and structurally meaningful heterogeneity: at one
end an information-optimal dial, at the other a dial that essentially dumps the
whole population into one position.

### 7.4 The budget as a falsification test, and a detected inconsistency

Theorem 6.1 is not merely descriptive: it is a hard constraint linking the
per-dial table to the joint table, and it can fail. Applying it to the first row
of the reported measurement, with the reported per-dial value $c_{31} = 0.04$
bits for the modulus-$31$ dial and the most generous conceivable value
$c_{23} \le \log_2 23 = 4.5236$ for its partner:
$$C(\{31, 23\}) \;\le\; c_{31} + c_{23} \;\le\; 0.04 + 4.5236 \;=\; 4.5636 \text{ bits.}$$
The reported joint value is $7.9455$ bits, exceeding this cap by $3.38$ bits.
Equivalently, by Corollary 6.3 the modulus-$31$ dial cannot contribute more than
$0.04$ bits to any battery, so a pair containing it cannot exceed
$\log_2 23 + 0.04$.

We therefore conclude, with no statistical assumption whatsoever, that **the
per-dial figures and the joint figures cannot both describe the same dials on
the same population.** The most likely reconciliations are that the per-dial
table was collected on a different population or instrument configuration from
the joint table (the joint measurement is described as being taken on a fresh,
independent population, and the per-dial list contains a modulus-$11$ dial that
does not appear in the four-dial joint battery at all), or that the $0.04$ figure
is attached to the wrong dial. What cannot be true is that a $0.04$-bit dial
participates in a $7.9455$-bit pair.

This is the practical payoff of a structural theory. A monotone trend can be
"confirmed" by a pipeline that is silently comparing quantities measured under
different conditions; an inequality between the quantities cannot be.

---

## 8. The "wall" is an imbalance meter

The experiment also reported a *which-factor wall*: a binary readout that never
exceeded $0.4677$ bits. For binary statistics the entire theory collapses onto
one real parameter.

**Theorem 8.1 (binary law).** Let $f : \Omega \to A$ attain exactly two values
$a \ne b$, and let $p = n_a / N$ be the fraction of the population in the
$a$-class. Then
$$C(f) \;=\; h(p) \;=\; -p\log_2 p - (1-p)\log_2(1-p),$$
the binary entropy of $p$.

*Proof.* The defining sum has exactly two terms, with probabilities $p$ and
$1 - p$ (since $n_a + n_b = N$), and $\log(N/n_a) = \log(1/p)$,
$\log(N/n_b) = \log(1/(1-p))$. $\square$

**Corollary 8.2 (one-bit cap).** A statistic with at most two attained values has
capacity at most $1$ bit.

*Proof.* Theorem 2.4 with $K \le 2$; equivalently $h(p) \le h(1/2) = 1$.
$\square$

Hence the reported $0.4677 < 1$ is admissible on its face and, taken alone,
evidences nothing.

**Theorem 8.3 (strict monotonicity in the imbalance).** $h$ is strictly
increasing on $[0, 1/2]$: if $0 \le p < q \le 1/2$ then $h(p) < h(q)$.

**Theorem 8.4 (wall inversion).** If $p, q \in [0, 1/2]$ and $h(p) = h(q)$, then
$p = q$. Consequently a reported binary capacity determines the class imbalance
uniquely: it is a *sufficient statistic* for the split.

*Proof.* Strict monotonicity on $[0,1/2]$ implies injectivity there. $\square$

**Corollary 8.5 (cross-population inversion).** Let $f$ and $g$ be binary
statistics on two possibly different finite populations $\Omega_1, \Omega_2$,
with minority fractions $p, q \in [0, 1/2]$ respectively. If $C(f) = C(g)$ then
$p = q$.

Applying Theorem 8.4 to the reported value: solving $h(p) = 0.4677$ on
$[0, 1/2]$ gives
$$p \;=\; 0.09959\ldots \;\approx\; 9.96\% .$$
The "wall" is therefore not a barrier at all; it is a thermometer, and what it
reads is that the which-factor split divides the population approximately
$10\%$ / $90\%$. Corollary 8.5 upgrades this into a falsifiable prediction: two
independent populations reporting the same wall value, within measurement error,
must exhibit the same class proportions. The prediction has no free parameters
and can be checked directly against the class counts.

The attribution of the wall to "sparse-table bias" is consistent with, but weaker
than, this analysis: sparse-table bias (Corollary 2.5) bounds *all* capacities by
$\log_2 N$, which for $N \approx 4\,400$ is $12.1$ bits and does not bind on a
binary statistic at all. The binary cap of $1$ bit (Corollary 8.2) is what binds,
and the residual gap from $1$ to $0.4677$ is pure imbalance.

---

## 9. Discussion and future directions

The theory developed above establishes, for arbitrary finite populations and
arbitrary dial batteries: monotone scaling of joint capacity, a strict scaling
criterion, the multiplicative ceiling $\log_2 \prod m_i$ with a witness showing
it is attained, the sample ceiling $\log_2 N$, a per-dial budget by
subadditivity, and an exact identification of the binary wall with the binary
entropy of the class imbalance. What this covers is exactly the *structural*
content of the "scaling is confirmed" verdict. What measurement alone cannot
decide is *how much* of the multiplicative ceiling a real population can reach.
The directions below attack that gap.

### 9.1 Sample-limited capacity law (the sparse-table exponent)

The shortfall of a measured capacity below its multiplicative ceiling is not
noise but should be a deterministic function of the ratio $N/M$. For a uniformly
random reading table with $N$ rows and $M$ cells, the expected number of occupied
cells is $M\bigl(1 - (1 - 1/M)^N\bigr)$, and the capacity is squeezed between
$\log_2$ of that count and $\log_2 N$. Both ceilings are now theorems, so the
only missing piece is a *lower* bound, which needs a concentration statement
rather than new definitions. The target is an asymptotic law
$$C \;=\; \log_2 N \;-\; \Delta(N/M) \;+\; o(1)$$
with $\Delta$ an explicit convex function of the load, vanishing as
$N/M \to 0$.

### 9.2 Exact saturation threshold for residue batteries

Saturation of the multiplicative ceiling is equivalent to injectivity of the
joint reading, and by the Chinese Remainder Theorem injectivity holds as soon as
the population injects into $\prod \mathbb{Z}/m_i$ with pairwise coprime $m_i$.
For non-coprime moduli the true ceiling is $\log_2 \mathrm{lcm}(m_i)$, strictly
smaller than $\log_2 \prod m_i$. The coprime case is settled (Theorem 5.2); the
non-coprime correction is a clean, self-contained refinement of Theorem 4.2 that
would make the ceiling exact rather than an upper bound.

### 9.3 A reverse budget: per-dial spread versus joint capacity

Subadditivity is very lossy as an *upper* bound for batteries with an
eighty-fold per-dial spread, and it says nothing from below. The joint capacity
should be bounded below by the largest per-dial value plus the conditional
information of the remaining dials, i.e. by making the chain rule of
Corollary 6.3 quantitative: $C(S) \ge \max_{i \in S} c_i$ trivially, and the
interesting question is how much of $\sum_i c_i$ survives conditioning as a
function of the pairwise dependencies among dials. The fibrewise splitting lemma
(Lemma 2.7) already isolates exactly the conditional term required. A companion
question is how large a per-dial spread is compatible with a given joint value —
the combination of Corollary 6.3 with the ceilings gives one answer, namely that
the joint value is capped by $\sum_i \min\{c_i, \log_2 m_i\}$, and this is the
inequality that detected the inconsistency of Section 7.4.

### 9.4 Wall inversion as a statistical test

Because binary capacity is a strictly monotone function of the class imbalance,
a reported wall value is a sufficient statistic for that imbalance (Theorem 8.4),
so two independent populations agreeing on the wall to within measurement error
must agree on their which-factor split — a falsifiable cross-population
prediction. Turning it into a test requires only an error propagation analysis:
the derivative $h'(p) = \log_2\frac{1-p}{p}$ converts a capacity uncertainty
$\pm \varepsilon$ into an imbalance uncertainty $\pm \varepsilon / h'(p)$, which
near $p = 0.1$ is $\pm \varepsilon / 3.17$.

### 9.5 Methodological remark

The audit performed in Section 7 has a general form worth isolating. Given a
reported measurement with a trend, compute first the part of the report that is
*forced* by structure — here, monotonicity and two ceilings — and treat it as a
check on apparatus rather than as a discovery. What remains, after the forced
part is subtracted, is the data: here, three collision shortfalls, an
eighty-fold per-dial spread whose two ends have certified and opposite
interpretations, and a class imbalance recoverable exactly from a single number.
Applied systematically, this discipline would prevent a large class of
confirmations that confirm only that arithmetic is monotone.

---

## 10. Conclusion

We have given a structural theory of the joint capacity of a battery of
bounded-modulus dials on a finite population. Joint capacity is monotone under
enlargement of the battery, strictly so under an explicit and checkable
separation criterion; it is bounded by the logarithm of the number of cells and,
independently, by the logarithm of the population size; it is bounded by the sum
of per-dial capacities; and the cell-count bound is attained exactly on a
Chinese Remainder population, so shortfalls against it are measurements rather
than artefacts. For binary readouts the theory reduces to the binary entropy
function, which is invertible on the balanced side, making a reported "wall"
an exact report of a class imbalance.

Applied to a four-dial battery of moduli $31, 23, 9, 8$, this analysis shows
that the trend and the ceiling compliance were guaranteed in advance, while the
substantive content of the measurement lies in the growing shortfalls (a
migration from instrument-limited to sample-limited regimes), in the certified
contrast between a saturated modulus-$11$ dial within $0.001$ bits of its
ceiling and a nearly blind modulus-$31$ dial at under $1\%$ of its own, and in
the inversion of a $0.4677$-bit wall into a $10\%/90\%$ population split. The
same theory also detects what no trend analysis could: the reported per-dial and
joint figures violate the per-dial budget by $3.38$ bits and therefore cannot
refer to the same dials on the same population.
