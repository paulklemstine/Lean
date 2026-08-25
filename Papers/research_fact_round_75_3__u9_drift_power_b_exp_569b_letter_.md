# The Exact Algebra of Overlapping Measurement Legs

## Variance defects, lineage bounds, and cluster ceilings for estimators pooled from a shared random stream

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Large computational experiments are routinely extended, re-run, and pooled. When the extensions are generated from the same pseudorandom master seed, the resulting "replication legs" are not statistically independent, and the standard inverse-variance combination silently understates the variance of the pooled estimator. We give a complete and exact account of this phenomenon in a Hilbert-space model of correlated measurements, in which the inner product of two centred readouts is their covariance.

Four results form the core. First, for sample means cut from a single stream of pairwise uncorrelated draws of common variance $\sigma^2$, the covariance of two legs is exactly $\sigma^2|S \cap T|/(|S||T|)$, whence the *exact defect law*: the true variance of a weighted pool exceeds the independence bookkeeping by precisely $2w(1-w)\sigma^2|S\cap T|/(|S||T|)$, with equality to the naive value **if and only if** the legs are disjoint. Second, a *lineage bound*: for any chain $S_1 \subseteq \cdots \subseteq S_n$ of legs from one stream and any convex weighting, the pooled variance is at least $\sigma^2/|S_n|$ — a lineage is worth its longest run — and more generally, for an arbitrary overlapping family, at least $\sigma^2/|\bigcup_l S_l|$, a bound depending on nothing but the number of distinct draws consumed, and attained by the uniform average over that union. Third, a *population overlap identity* for two-level designs, $\mathrm{Cov} = \rho\sigma^2|K\cap K'|/(|K||K'|) + (1-\rho)\sigma^2|K\cap K'||T\cap T'|/(|K||T||K'||T'|)$, which exhibits shared-draw and shared-population dependence as the two summands of one formula. Fourth, a *cluster ceiling*: the grand mean over $k$ clusters of $m$ equicorrelated draws has variance $\sigma^2(1 + (m-1)\rho)/(km) \ge \rho\sigma^2/k$ uniformly in $m$, with the floor attained in the limit, so the effective sample size never exceeds $k/\rho$.

We complete the picture with the generalised-least-squares rule for two correlated legs, obtained by completing the square: the optimal weight is $w^\star = (v_2 - c)/(v_1 + v_2 - 2c)$ with floor $(v_1v_2 - c^2)/(v_1 + v_2 - 2c)$; inverse-variance weighting is optimal exactly when $c(v_2 - v_1) = 0$; the optimum for a nested pair is $w^\star = 0$ ("discard the prefix"); and disjoint legs restore the classical weights exactly.

We then apply these results to a concrete audit. A randomness experiment evaluated $128$ moduli $\times\ 600{,}000$ paired samples $= 76.8$ million pairs, reporting a rate ratio $r$ against the null $r = 1$. Two pooled analyses are shown to be invalid: a three-leg combination that treated a run and its own strict prefix as independent (an error equivalent to pooling a dataset with itself, which reports exactly half the true variance), and a two-leg combination whose legs share no draws but whose modulus populations are nested. At the audited nesting ratio $|T| = 4|S|$ the variance inflation is exactly $7/5$, so any reported two-sided statistic of at most $2.14$ has honest statistic below $1.96$: the apparent exclusion of the null dissolves. With $k = 128$ and an intra-modulus correlation of $\rho = 10^{-2}$, the $76.8$-million-pair run carries no more information than $12{,}800$ independent evaluations. The operational conclusion — that replication legs must vary the master seed — is not a policy preference but a corollary.

**Keywords:** design effect, intra-cluster correlation, effective sample size, inverse-variance weighting, generalised least squares, shared random streams, replication, variance inflation.

---

## 1. Introduction

### 1.1 The problem

A computational experiment produces an estimate $\hat\theta_1$ with a standard error. It is then re-run longer, producing $\hat\theta_2$ with a smaller standard error. A natural instinct is to combine them, weighting each by its precision. If $\hat\theta_1$ and $\hat\theta_2$ have variances $v_1, v_2$ and are independent, the inverse-variance weighted (IVW) combination

$$\hat\theta = w\hat\theta_1 + (1-w)\hat\theta_2, \qquad w = \frac{v_2}{v_1 + v_2},$$

has variance $v_1v_2/(v_1 + v_2)$, smaller than either. This is the workhorse of meta-analysis.

The hypothesis of independence is doing all the work, and in a deterministic pseudorandom pipeline it is frequently false in a way that is invisible from the summary statistics. If the second run consumes the same seeded stream as the first, extended, then the second run's data *contains* the first run's data. The legs are not merely correlated; the short one is a subset of the long one. IVW then reports a variance that is too small by an amount we compute exactly below, and confidence intervals derived from it are too narrow by a factor we also compute exactly.

There is a second, subtler failure. Two legs may consume disjoint draws — different code paths, no shared random consumption — and still be dependent, because they measure the *same objects*. In a two-level design where objects carry idiosyncratic components, sharing objects induces covariance even under complete draw-disjointness. If the object population is itself generated from the master seed, "re-drawing the population" inside a fixed stream reproduces the same objects and thus the same dependence.

### 1.2 Contributions

We work in a coordinate-free model: centred readouts are vectors in a real inner product space $E$, with $\langle x, y\rangle$ interpreted as covariance and $\langle x, x\rangle$ as variance. This is not an abstraction for its own sake — it makes every statement below an algebraic identity in finitely many cardinalities, provable without measure-theoretic machinery and valid for any joint distribution with the stated second moments.

Our contributions are:

1. **The overlap master identity and the exact defect law** (§3): the covariance of two legs from one stream, and the exact excess of true over reported variance, with an iff-characterisation of when IVW is valid.
2. **Quantification of the two audited failure modes** (§4): the duplicate-leg case (variance halved, error bars shrunk by $\sqrt2$) and the nested case (inflation $(3|S|+|T|)/(|S|+|T|)$, equal to $7/5$ at the audited geometry), including the fact that pooling a prefix with its superset is *strictly worse* than discarding the prefix, and the resulting retraction of a threshold crossing.
3. **The lineage and distinct-draw bounds** (§5): $\mathrm{Var} \ge \sigma^2/|S_n|$ for chains and $\mathrm{Var} \ge \sigma^2/|\bigcup_l S_l|$ for arbitrary families under arbitrary convex weights, with sharpness.
4. **The population overlap identity** (§6): a two-level model in which both failure modes appear as the two summands of a single covariance formula.
5. **The cluster ceiling** (§7): the design-effect identity, the uniform-in-$m$ variance floor $\rho\sigma^2/k$, its attainment in the limit, and the effective-sample-size bound $k/\rho$.
6. **The GLS repair** (§8): optimal weights for known covariance, and the exact condition under which IVW is optimal.
7. **An applied audit** (§9) and the resulting design rule (§10).

All models introduced are shown to be realisable (§2.3), so no statement is vacuous.

---

## 2. The model

### 2.1 Covariance as inner product

Let $E$ be a real inner product space. We interpret an element $x \in E$ as a centred scalar readout, $\langle x, y \rangle$ as $\mathrm{Cov}(x,y)$ and $\langle x, x\rangle$ as $\mathrm{Var}(x)$. Linear combinations of readouts correspond to linear combinations of vectors, and bilinearity of the inner product is exactly bilinearity of covariance. Every result below is therefore a statement about second moments only, and holds for any distribution realising them.

**Definition 2.1 (Design).** A *design* consists of a family $(x_i)_{i \in \mathbb{N}}$ of vectors in $E$ (the *draws*, indexed by position in a random stream) together with a scale $\sigma > 0$ such that

- $\langle x_i, x_i\rangle = \sigma^2$ for all $i$ (common per-draw variance), and
- $\langle x_i, x_j \rangle = 0$ for $i \ne j$ (distinct stream positions are uncorrelated).

**Definition 2.2 (Leg).** For a finite nonempty $S \subseteq \mathbb{N}$, the *leg* indexed by $S$ is the sample mean
$$\bar{x}_S := \frac{1}{|S|}\sum_{i \in S} x_i .$$

A leg models one measurement run: the positions in $S$ are the stream positions that run consumed. Two runs from the same seeded stream overlap precisely on $S \cap T$; two runs from independent seeds have $S \cap T = \varnothing$ after relabelling.

### 2.2 The combinatorial core

**Lemma 2.3 (Orthogonal partial sums).** Let $(f_p)_{p \in \iota}$ be a family in $E$ with $\langle f_p, f_p\rangle = v$ for all $p$ and $\langle f_p, f_q \rangle = 0$ for $p \ne q$. Then for finite $S, T \subseteq \iota$,
$$\Bigl\langle \sum_{p \in S} f_p, \ \sum_{q \in T} f_q \Bigr\rangle = v\,|S \cap T| .$$

*Proof sketch.* Expand by bilinearity. For fixed $p \in S$, the inner product $\langle f_p, \sum_{q\in T} f_q\rangle$ collapses by orthogonality to $v$ if $p \in T$ and to $0$ otherwise. Summing the indicator over $S$ gives $v|S\cap T|$. $\square$

Lemma 2.3 is stated for an arbitrary index type deliberately: it is applied below to stream positions, to clusters, and to (cluster, draw) pairs alike.

### 2.3 Non-vacuity

**Proposition 2.4.** For every $\sigma > 0$ there is a design realising it: take $E = \ell^2(\mathbb{N})$ and $x_i = \sigma e_i$ with $(e_i)$ the standard orthonormal basis. Similarly (§6, §7) the two-level models are realised in $\ell^2$ of a disjoint union, with the cluster component of norm $\sqrt{\rho}\,\sigma$ and the private component of norm $\sqrt{1-\rho}\,\sigma$, for every $0 \le \rho \le 1$.

Consequently every theorem below is a statement about a nonempty class of models.

---

## 3. The overlap identity and the exact defect law

**Theorem 3.1 (Master identity).** For any two legs of a design,
$$\mathrm{Cov}(\bar{x}_S, \bar{x}_T) = \frac{\sigma^2\,|S \cap T|}{|S|\,|T|}.$$

*Proof sketch.* $\bar{x}_S = |S|^{-1}\sum_{i \in S} x_i$; apply Lemma 2.3 with $v = \sigma^2$ and divide by $|S||T|$. $\square$

Three immediate consequences:

- **Single-leg variance.** $\mathrm{Var}(\bar{x}_S) = \sigma^2/|S|$ (take $T = S$).
- **Disjointness gives independence at second order.** If $S \cap T = \varnothing$ then $\mathrm{Cov} = 0$.
- **Nesting is total correlation with the long leg.** If $S \subseteq T$ then $\mathrm{Cov}(\bar{x}_S, \bar{x}_T) = \sigma^2/|T| = \mathrm{Var}(\bar{x}_T)$. The short leg's covariance with the long one equals the long one's entire variance: the prefix carries no information the superset lacks.

Now fix a pooling weight $w \in \mathbb{R}$ and set
$$\hat\theta_w := w\,\bar{x}_S + (1-w)\,\bar{x}_T .$$

**Definition 3.2.** The *reported* (naive) variance is the independence bookkeeping
$$V_{\mathrm{rep}}(w) := \frac{w^2\sigma^2}{|S|} + \frac{(1-w)^2\sigma^2}{|T|},$$
and the *true* variance is $V_{\mathrm{true}}(w) := \mathrm{Var}(\hat\theta_w)$.

**Theorem 3.3 (Exact defect law).**
$$V_{\mathrm{true}}(w) = V_{\mathrm{rep}}(w) + \frac{2w(1-w)\,\sigma^2\,|S \cap T|}{|S|\,|T|}.$$

*Proof sketch.* Expand $\langle \hat\theta_w, \hat\theta_w\rangle$ bilinearly into three terms and apply Theorem 3.1 to each. $\square$

**Corollary 3.4 (Conservativeness of disjointness).** For $0 \le w \le 1$, $V_{\mathrm{rep}}(w) \le V_{\mathrm{true}}(w)$: independence bookkeeping never overstates the variance of a convex pool from a shared stream.

**Theorem 3.5 (Independence is disjointness).** For $0 < w < 1$ and nonempty $S, T$,
$$V_{\mathrm{true}}(w) = V_{\mathrm{rep}}(w) \iff S \cap T = \varnothing .$$

*Proof sketch.* The defect term is a product of strictly positive factors times $|S \cap T|$; it vanishes iff the intersection is empty. $\square$

Theorem 3.5 is the conceptual heart of the paper: **for sample means cut from a single stream, statistical independence *is* set-theoretic disjointness.** There is no weaker sufficient condition, no notion of "approximately disjoint" that rescues the formula, and no way to certify independence from summary statistics alone — one must inspect which draws were consumed.

---

## 4. The two audited failure modes

### 4.1 A dataset pooled with itself

**Theorem 4.1 (Duplicate leg).** For $S = T$ and $w = 1/2$,
$$V_{\mathrm{true}} = \frac{\sigma^2}{|S|} = 2\,V_{\mathrm{rep}} .$$

*Proof sketch.* $\hat\theta_{1/2} = \bar{x}_S$, whose variance is $\sigma^2/|S|$; the reported value is $\tfrac14\sigma^2/|S| + \tfrac14\sigma^2/|S| = \sigma^2/(2|S|)$. $\square$

Counting one dataset twice therefore halves the reported variance and shrinks confidence half-widths by exactly $\sqrt{2}$. This is not a modelling nuance requiring judgement; it is a factor-of-two arithmetic error.

### 4.2 A prefix pooled with its superset

Let $S \subseteq T$ with $|S| < |T|$, and let $w_{\mathrm{IVW}} = |S|/(|S| + |T|)$ be the inverse-variance weight (which, since $v_1 = \sigma^2/|S|$ and $v_2 = \sigma^2/|T|$, is $v_2/(v_1+v_2)$).

**Theorem 4.2 (Reported variance).** $V_{\mathrm{rep}}(w_{\mathrm{IVW}}) = \dfrac{\sigma^2}{|S| + |T|}$ — the "pooled sample size" value.

**Theorem 4.3 (True variance of a nested IVW pool).**
$$V_{\mathrm{true}}(w_{\mathrm{IVW}}) = \frac{\sigma^2\bigl(3|S| + |T|\bigr)}{\bigl(|S| + |T|\bigr)^2} = \frac{3|S| + |T|}{|S| + |T|}\; V_{\mathrm{rep}}(w_{\mathrm{IVW}}),$$
and the inflation factor $(3|S| + |T|)/(|S|+|T|)$ is strictly greater than $1$ for all nonempty $S, T$.

*Proof sketch.* Apply Theorem 3.3 with $|S \cap T| = |S|$ and simplify. $\square$

**Theorem 4.4 (Nested pooling is worse than discarding).** For $S \subseteq T$ with $|S| < |T|$,
$$\frac{\sigma^2}{|T|} < V_{\mathrm{true}}(w_{\mathrm{IVW}}).$$

*Proof sketch.* The inequality reduces after clearing denominators to $(|T| - |S|)^2 > 0$. $\square$

Thus the folklore "pooling more legs cannot hurt" is false for overlapping legs. The correct statement is that pooling more *distinct draws* cannot hurt.

A cleaner form of the same phenomenon, valid at every weight:

**Theorem 4.5 (Nested variance at arbitrary weight).** For $S \subseteq T$,
$$V_{\mathrm{true}}(w) = \sigma^2\left(\frac{w^2}{|S|} + \frac{1 - w^2}{|T|}\right).$$

*Proof sketch.* Theorem 3.3 with $|S\cap T| = |S|$; the cross term upgrades $(1-w)^2$ to $1 - w^2$ exactly. $\square$

**Corollary 4.6 (Optimal nested weight is zero).** For $S \subsetneq T$ the map $w \mapsto V_{\mathrm{true}}(w)$ is strictly minimised at $w = 0$. Discarding the prefix is optimal, not merely acceptable.

### 4.3 The audited geometry and the retraction

**Theorem 4.7 (Quarter-prefix inflation).** If $S \subseteq T$ and $|T| = 4|S|$ then
$$V_{\mathrm{true}}(w_{\mathrm{IVW}}) = \tfrac{7}{5}\,V_{\mathrm{rep}}(w_{\mathrm{IVW}}).$$

This is exactly the configuration of the audited experiment: a run of $150{,}000$ samples per modulus nested as a deterministic prefix inside a run of $600{,}000$.

Write $z(d, v) := d/\sqrt{v}$ for the standardised deficit.

**Lemma 4.8 (Rescaling).** $z(d, fv) = z(d,v)/\sqrt{f}$ for $f \ge 0$.

**Theorem 4.9 (Gate retraction).** Let $d \ge 0$, $v > 0$, and suppose the reported statistic satisfies $z(d, v) \le 2.14$. Then the honest statistic satisfies
$$z\bigl(d, \tfrac{7}{5}v\bigr) < 1.96 .$$

*Proof sketch.* $z(d, \tfrac75 v) = z(d,v)/\sqrt{7/5} \le 2.14/\sqrt{1.4}$, and $\sqrt{1.4} > 1.1832$, so the bound is at most $2.14/1.1832 = 1.809 < 1.96$. $\square$

**Corollary 4.10 (Interval widths).** The honest half-width of a nested IVW pool is $\sqrt{7/5} \in (1.1832,\ 1.1833)$ times the reported one; equivalently, the reported interval spans about $84.5\%$ of the honest length.

Consequently the corrected interval $[0.9226, 0.9966]$, which nominally excluded the null value $1$ with $z \approx 2.14$, does not exclude it once the shared stream is paid for. No threshold is crossed.

---

## 5. Lineage and distinct-draw bounds

Section 4 shows what goes wrong with two specific configurations. This section shows that *no* repair of the weights can rescue a lineage.

### 5.1 Chains

**Lemma 5.1 (Chain covariance floor).** Let $S_0 \subseteq S_1 \subseteq \cdots$ be a chain of nonempty legs from one design. For any $i, j \le n$,
$$\mathrm{Cov}(\bar{x}_{S_i}, \bar{x}_{S_j}) \ \ge\ \frac{\sigma^2}{|S_n|}.$$

*Proof sketch.* By monotonicity, for $p \le q \le n$ we have $S_p \subseteq S_q$, so $\mathrm{Cov} = \sigma^2/|S_q| \ge \sigma^2/|S_n|$; the two-sided case follows by symmetry. $\square$

**Theorem 5.2 (Lineage bound).** Let $S_0 \subseteq \cdots \subseteq S_n$ be a chain and let $w_0, \dots, w_n \ge 0$ with $\sum_i w_i = 1$. Then
$$\mathrm{Var}\Bigl(\sum_{i=0}^{n} w_i \bar{x}_{S_i}\Bigr)\ \ge\ \frac{\sigma^2}{|S_n|}.$$

*Proof sketch.* Expand the variance as $\sum_{i,j} w_i w_j \mathrm{Cov}(\bar{x}_{S_i}, \bar{x}_{S_j})$, bound each covariance below by $\sigma^2/|S_n|$ using Lemma 5.1 and nonnegativity of $w_iw_j$, and use $\bigl(\sum_i w_i\bigr)^2 = 1$. $\square$

A lineage of $n$ nested "replications", however weighted, carries exactly the information of its longest run. In particular no repair of the retracted three-leg combination could have beaten the single longest leg.

### 5.2 Arbitrary overlapping families

The chain hypothesis is not needed. Let $L$ be a finite index set of legs $S_l$, all nonempty, with weights $w_l$ summing to $1$, and let $U := \bigcup_{l \in L} S_l$ be the set of distinct stream positions consumed.

**Lemma 5.3 (Pools are linear forms).** With
$$c_i := \sum_{l \in L}\ \mathbb{1}[i \in S_l]\ \frac{w_l}{|S_l|},$$
we have $\sum_{l} w_l\bar{x}_{S_l} = \sum_{i \in U} c_i x_i$, and $\sum_{i \in U} c_i = \sum_{l \in L} w_l = 1$.

*Proof sketch.* Rewrite each leg mean as a sum over $U$ with indicator coefficients and exchange the order of summation; unbiasedness (the coefficient sum) follows from $\sum_{i \in S_l} 1/|S_l| = 1$. $\square$

**Lemma 5.4 (Variance of a linear form).** $\mathrm{Var}\bigl(\sum_{i \in U} c_i x_i\bigr) = \sigma^2\sum_{i \in U} c_i^2$.

**Theorem 5.5 (Distinct-draw bound).** For any finite family of nonempty legs from one design and any weights summing to $1$,
$$\mathrm{Var}\Bigl(\sum_{l \in L} w_l \bar{x}_{S_l}\Bigr)\ \ge\ \frac{\sigma^2}{|U|}, \qquad U = \bigcup_{l\in L} S_l .$$

*Proof sketch.* By Lemmas 5.3–5.4 the variance is $\sigma^2\sum_{i\in U} c_i^2$. Cauchy–Schwarz gives $1 = \bigl(\sum_{i \in U} c_i\bigr)^2 \le |U|\sum_{i\in U}c_i^2$. $\square$

**Theorem 5.6 (Sharpness).** The uniform pool $|U|^{-1}\sum_{i \in U} x_i$ attains the bound, with variance exactly $\sigma^2/|U|$.

The bound depends on nothing but the number of distinct draws consumed: not on the number of legs, not on the weights, not on how the analysis slices the stream. It is the exact sense in which *one seed is one dataset*.

### 5.3 What a fresh stream buys

**Theorem 5.7 (Disjoint pooling).** If $S \cap T = \varnothing$ then $V_{\mathrm{true}}(w_{\mathrm{IVW}}) = \sigma^2/(|S| + |T|)$, i.e. the reported value is honest.

**Theorem 5.8 (Strict improvement).** In the same situation $V_{\mathrm{true}}(w_{\mathrm{IVW}}) < \sigma^2/|T|$: a disjoint replication strictly improves on the longer leg alone — in contrast to Theorem 4.4.

**Theorem 5.9 (Equal-size fresh replication).** If additionally $|S| = |T|$ then
$$V_{\mathrm{true}}(w_{\mathrm{IVW}}) = \tfrac12 \cdot \frac{\sigma^2}{|T|},$$
i.e. error bars are divided by exactly $\sqrt2$.

The $\sqrt2$ of Theorem 5.9 is the genuine gain that duplicate counting (Theorem 4.1) manufactures fraudulently. The two theorems are numerically identical and epistemically opposite: the same factor, earned in one case and fabricated in the other.

---

## 6. Shared populations: the overlap identity one level up

Draw-disjointness is necessary for independence but, in a two-level design, not sufficient.

**Definition 6.1 (Population design).** Fix $\sigma > 0$ and $\rho \in [0,1]$. A *population design* consists of vectors $u_i$ (a shared component per object $i$) and $p_{i,t}$ (a private component per object $i$ and draw index $t$), mutually orthogonal in all distinct arguments, with
$$\langle u_i, u_i\rangle = \rho\sigma^2, \qquad \langle p_{i,t}, p_{i,t}\rangle = (1-\rho)\sigma^2 .$$
A readout is $o_{i,t} := u_i + p_{i,t}$, of variance $\sigma^2$; two readouts on the same object have covariance $\rho\sigma^2$, on different objects $0$.

**Definition 6.2 (Two-level leg).** For finite nonempty sets $K$ of objects and $T$ of draw indices,
$$\bar{o}_{K,T} := \frac{1}{|K||T|}\sum_{i \in K}\sum_{t \in T} o_{i,t}.$$

**Theorem 6.3 (Population overlap identity).** For any two legs,
$$\mathrm{Cov}\bigl(\bar{o}_{K,T},\ \bar{o}_{K',T'}\bigr) \;=\; \frac{\rho\sigma^2\,|K \cap K'|}{|K|\,|K'|} \;+\; \frac{(1-\rho)\sigma^2\,|K\cap K'|\,|T \cap T'|}{|K|\,|T|\,|K'|\,|T'|}.$$

*Proof sketch.* Split each leg sum as $|T| \sum_{i\in K} u_i + \sum_{(i,t) \in K\times T} p_{i,t}$. The cross terms vanish by orthogonality of shared and private components. Lemma 2.3 applied to the $u$'s over $K, K'$ contributes $\rho\sigma^2|K\cap K'|\,|T||T'|$, and applied to the $p$'s over the product sets contributes $(1-\rho)\sigma^2|K \cap K'||T \cap T'|$ (since $(K\times T)\cap(K'\times T') = (K\cap K')\times(T\cap T')$). Divide by $|K||T||K'||T'|$. $\square$

The two summands are exactly the two failure modes of the audit: shared draws (second term) and shared objects (first term).

**Corollary 6.4 (Design effect, two-level form).** Taking $K = K'$, $T = T'$,
$$\mathrm{Var}(\bar{o}_{K,T}) = \frac{\rho\sigma^2}{|K|} + \frac{(1-\rho)\sigma^2}{|K||T|} .$$

**Corollary 6.5 (Disjoint draws are not enough).** If $T \cap T' = \varnothing$ then
$$\mathrm{Cov} = \frac{\rho\sigma^2|K\cap K'|}{|K||K'|},$$
which is strictly positive whenever $\rho > 0$ and the object populations meet. In particular, if $K \subseteq K'$ the covariance is $\rho\sigma^2/|K'| > 0$.

**Corollary 6.6 (Disjoint populations give exact independence).** If $K \cap K' = \varnothing$ then $\mathrm{Cov} = 0$ regardless of draw overlap.

**Theorem 6.7 (Quantified consequence for the audited pair).** For $K \subseteq K'$, disjoint draws, $\rho > 0$ and $0 < w < 1$, the honest variance of the pooled estimator exceeds the reported inverse-variance value by exactly
$$\frac{2w(1-w)\rho\sigma^2}{|K'|} > 0 .$$

*Proof sketch.* Expand the pooled variance and substitute Corollary 6.5. $\square$

This is the precise sense in which the "nominally independent" two-leg combination fails: the legs are disjoint as *measurement machinery* but nested as *populations*, and only the latter controls the leading term of their covariance. Since the object population was itself generated deterministically from the master seed, re-drawing it within a fixed stream reproduces the same objects — the shared component, and hence the covariance, is unchanged.

---

## 7. The cluster ceiling

Section 6 explains why one must resample *objects*, not *draws*, to obtain honest intervals. This section explains why enlarging the number of draws per object cannot substitute for enlarging the number of objects.

**Definition 7.1 (Cluster model).** Fix $k$ clusters and $m$ draws per cluster, $\sigma > 0$, $\rho \in [0,1]$, and centred readouts $y_{i,j}$ ($i < k$, $j < m$) with
$$\langle y_{i,j}, y_{i,j}\rangle = \sigma^2, \quad \langle y_{i,j}, y_{i,j'}\rangle = \rho\sigma^2\ (j \ne j'), \quad \langle y_{i,j}, y_{i',j'}\rangle = 0\ (i \ne i').$$
The *grand mean* is $\bar y := (km)^{-1}\sum_{i,j} y_{i,j}$.

**Lemma 7.2 (Readout–total covariance).** For every $(i,j)$,
$$\bigl\langle y_{i,j},\ \textstyle\sum_{i',j'} y_{i',j'}\bigr\rangle = \sigma^2\bigl(1 + (m-1)\rho\bigr).$$

*Proof sketch.* Only the cluster of $i$ contributes; within it, the readout's own variance $\sigma^2$ plus $m-1$ sibling covariances $\rho\sigma^2$. $\square$

**Theorem 7.3 (Design-effect identity).** For $k, m \ge 1$,
$$\mathrm{Var}(\bar y) = \frac{\sigma^2\bigl(1 + (m-1)\rho\bigr)}{km}.$$

*Proof sketch.* Sum Lemma 7.2 over all $km$ readouts and divide by $(km)^2$. $\square$

**Definition 7.4.** The *design effect* is $\mathrm{Deff} := 1 + (m-1)\rho$ and the *effective sample size* is $n_{\mathrm{eff}} := km/\mathrm{Deff}$.

**Theorem 7.5 (Clustering never helps).** $\mathrm{Deff} \ge 1$ for $m \ge 1$, with equality iff $\rho = 0$ or $m = 1$.

**Theorem 7.6 (Cluster ceiling).** For $k, m \ge 1$,
$$\mathrm{Var}(\bar y) \ \ge\ \frac{\rho\,\sigma^2}{k} \qquad \text{uniformly in } m .$$

*Proof sketch.* Cross-multiplying, the claim is $\rho m \le 1 + (m-1)\rho$, i.e. $\rho \le 1$. $\square$

**Theorem 7.7 (The ceiling is attained).** For fixed $k \ge 1$, $\sigma$ and $\rho$,
$$\lim_{m \to \infty} \frac{\sigma^2\bigl(1 + (m-1)\rho\bigr)}{km} = \frac{\rho\sigma^2}{k}.$$

*Proof sketch.* Write the quotient as $\rho\sigma^2/k + \sigma^2(1-\rho)/(km)$ and let $m \to \infty$. $\square$

So the floor is sharp: intra-cluster sampling approaches it and never crosses it.

**Theorem 7.8 (Information ceiling).** If $\rho > 0$ then $n_{\mathrm{eff}} \le k/\rho$ for every $m$.

*Proof sketch.* Equivalent to $\rho km \le k(1 + (m-1)\rho)$, i.e. $\rho \le 1$. $\square$

**Corollary 7.9 (The audited run).** With $k = 128$ clusters and $\rho = 10^{-2}$, $n_{\mathrm{eff}} \le 12{,}800$ for every $m$. The $76.8$-million-pair run therefore carries no more information than $12{,}800$ independent evaluations — a ratio of $6000{:}1$ between raw and effective counts. (At $m = 600{,}000$ the design effect is $1 + 599{,}999/100 = 6000.99$, giving $n_{\mathrm{eff}} = 12{,}798$, within $0.02\%$ of the ceiling: the run is already at the floor.)

Corollary 7.9 justifies cluster-level resampling for interval construction and, more importantly, rules out "run it longer" as a route to a decisive result.

---

## 8. What to do instead: optimal weights under known covariance

Once the covariance is *known* — and Theorems 3.1 and 6.3 make it known in both failure modes — the weight is no longer a matter of convention.

For legs of variances $v_1, v_2$ and covariance $c$, define
$$f(w) := w^2 v_1 + (1-w)^2 v_2 + 2w(1-w)c .$$

**Theorem 8.1 (Completed square).** If $v_1 + v_2 - 2c > 0$ then for all $w$,
$$f(w) = (v_1 + v_2 - 2c)\bigl(w - w^\star\bigr)^2 + F, \qquad w^\star := \frac{v_2 - c}{v_1 + v_2 - 2c}, \quad F := \frac{v_1v_2 - c^2}{v_1 + v_2 - 2c}.$$

*Proof sketch.* Expand the right side and match coefficients. $\square$

**Corollary 8.2.** $f(w) \ge F$ for all $w$, with equality iff $w = w^\star$. Thus $w^\star$ is the unique generalised-least-squares weight and $F$ the attainable floor.

**Theorem 8.3 (When IVW is optimal).** Assuming $v_1 + v_2 > 0$ and $v_1 + v_2 - 2c > 0$,
$$\frac{v_2}{v_1 + v_2} = w^\star \iff c\,(v_2 - v_1) = 0 .$$

*Proof sketch.* Cross-multiply the two fractions; the difference reduces to $c(v_2 - v_1)$. $\square$

So for legs of *unequal* precision, zero covariance is not merely convenient — it is the exact condition under which the textbook weights are correct.

**Theorem 8.4 (Nested legs).** For $S \subseteq T$ with $|S| < |T|$, substituting $v_1 = \sigma^2/|S|$, $v_2 = \sigma^2/|T|$, $c = \sigma^2/|T|$ gives
$$w^\star = 0, \qquad F = \frac{\sigma^2}{|T|} .$$

Discarding the prefix is the GLS solution, in agreement with Corollary 4.6.

**Theorem 8.5 (Disjoint legs).** For $S \cap T = \varnothing$, $c = 0$ and $w^\star = |S|/(|S| + |T|)$: the classical inverse-variance weight. A genuinely fresh master seed restores the published procedure exactly.

---

## 9. The audit, quantitatively

We now apply the framework to the experiment that motivated it. The experiment measures a rate ratio $r$ between a candidate-side and a matched control-side hit rate for a smoothness property, at two smoothness cuts ($10^5$ primary, $10^6$ secondary). The null hypothesis is $r = 1$.

**The run.** $128$ moduli (band-9, $96$-bit semiprimes), $600{,}000$ paired samples each: $76.8$ million paired evaluations, $2.15\times$ the earlier pilot, at $68.1\ \mu s$ per evaluation for a wall time of $5233.6$ s.

**Reported point estimates and intervals** (cluster bootstrap over the $128$ moduli):

| Cut | $r$ | Events | Interval |
|---|---|---|---|
| $10^5$ (primary) | $0.9710$ | $2280/2348$ | $[0.8976,\ 1.0521]$ |
| $10^6$ (secondary) | $0.9623$ | $37255/38718$ | $[0.9224,\ 1.0040]$ |

Both intervals cover $1$; no threshold is crossed by the run itself.

**Failure 1 — the three-leg combination.** A joint over pilot, a $150{,}000$-per-modulus run, and the $600{,}000$-per-modulus run gave $r \approx 0.971$ with interval $[0.942, 1.000]$. But the two later legs share a master seed end to end, and the longer run's draws are a strict superset of the shorter's: identical chunk seeds, deterministic prefix consumption, byte-identical first $150{,}000$ samples per modulus including paired controls. By Theorem 3.5 the combination is invalid; by Theorem 4.1 it is arithmetically a self-pool, reporting half the true variance; by Theorem 5.2 no reweighting of the chain could have beaten the longest leg. The combination is withdrawn.

**Failure 2 — the two-leg fallback.** Combining only the pilot ($0.9468 \pm 0.0449$) and the long run ($0.9623 \pm 0.0208$) under independence gives $r = 0.9596$ with $\sigma \approx 0.0189$ and interval $[0.9226, 0.9966]$ — a $\approx 4\%$ deficit excluding $1$ at $z \approx 2.14$. However, the pilot's $24$ moduli reconstruct inside the long run's $128$-modulus pool ($24/24$, zero rejects), because the pilot's generator uses the same master-seed literal, an unconsumed-until-pools main generator, and a byte-identical prime-start primitive. By Corollary 6.5 the covariance is $\rho\sigma^2/128 > 0$ whenever $\rho > 0$; by Theorem 6.7 the honest variance exceeds the reported value by $2w(1-w)\rho\sigma^2/128$. By Theorem 4.9, a reported statistic of $2.14$ subject to the audited $7/5$ inflation has honest statistic below $1.96$. The exclusion is withdrawn.

**Disposition.** Every dataset from the master seed in question constitutes *one* seed's evidence, jointly $3$–$5\%$ below $1$: a twice-gated candidate deviation, not a confirmation. The point estimate remains meaningful — the measurement machinery of the two legs is genuinely disjoint, so the estimate is not double-counted, only its precision was overstated — but the edge does not survive.

**Mechanism note.** The candidate-side deficit is *opposite in sign* to the direction a known compensating mechanism (a quadratic-residue sieve advantage) would predict. If real, it is therefore a new weak effect at the relevant smoothness scale; full scepticism is warranted until a fresh master seed lands.

**The decisive step.** By Corollary 7.9 more samples on the same $128$ moduli are worthless: the run is already within $0.02\%$ of the cluster floor. By Theorem 5.5 more legs from the same stream are worthless: the bound depends only on the distinct draws consumed. Only a fresh master seed — new population, new stream, disjoint at both levels — moves the floor, and by Theorem 5.9 an equal-size disjoint replication delivers a genuine $\sqrt2$ tightening. If a below-$1$ result then survives a pooled exclusion licensed by Theorem 8.5, the deviation becomes a confirmed candidate; if the ratio returns to $1$, the randomness hypothesis stands, tightened.

---

## 10. The design rule, as a corollary

The rule adopted after this audit — *replication legs must vary the master seed, and scripts must assert seed distinctness in their own output* — is a consequence of the theorems rather than an administrative preference:

1. **Independence requires disjointness of draws** (Theorem 3.5), which cannot be certified from summary statistics; it must be certified from the stream.
2. **Draw-disjointness alone is insufficient** when the object population is shared (Corollary 6.5); the population must also be disjoint.
3. **A deterministically generated population is a function of the master seed**, so "re-draw the population" inside a fixed stream changes neither the objects nor the covariance. Varying the master seed is the only operation that makes both levels disjoint at once.
4. **Nothing else buys precision**: more draws per object are capped by $\rho\sigma^2/k$ (Theorem 7.6), more legs from the same stream are capped by $\sigma^2/|U|$ (Theorem 5.5), and cleverer weights are capped by the GLS floor (Corollary 8.2), which for a nested pair is just the long leg's own variance (Theorem 8.4).

---

## 11. Algorithms

The theory yields three directly implementable procedures.

**Algorithm A (Overlap-aware pooling).** *Input:* legs $S_1, \dots, S_n$ as sets of stream positions, per-draw variance $\sigma^2$. *Output:* honest pooled variance and optimal weights. Compute the covariance matrix $C_{lm} = \sigma^2|S_l \cap S_m|/(|S_l||S_m|)$ by Theorem 3.1; solve the GLS problem $\min_w w^\top C w$ subject to $\mathbf{1}^\top w = 1$ (for $n = 2$, closed form by Theorem 8.1); report $w^\top C w$, never the diagonal-only value. Complexity: $O(n^2 \bar{s})$ for intersection sizes with sorted or hashed leg representations, plus $O(n^3)$ for the solve.

**Algorithm B (Design-effect audit).** *Input:* per-cluster counts and rates. *Output:* $\hat\rho$, design effect, effective sample size, cluster-bootstrap interval. Estimate $\rho$ from between- and within-cluster mean squares; report $n_{\mathrm{eff}} = km/(1 + (m-1)\hat\rho)$ and the ceiling $k/\hat\rho$ from Theorem 7.8; construct intervals by resampling clusters with replacement, never draws.

**Algorithm C (Stream-provenance check).** *Input:* two run manifests (master seed, chunk-seed derivation rule, per-modulus sample counts, population-generation primitive). *Output:* a verdict of `disjoint`, `nested`, `population-shared`, or `unknown`. If master seeds are equal and chunk-seed rules coincide, the shorter run's draws are a prefix of the longer's: verdict `nested`, inflation $(3|S| + |T|)/(|S| + |T|)$. If master seeds are equal but consumption paths differ, reconstruct the population and compare: nonempty intersection gives `population-shared` with covariance $\rho\sigma^2|K\cap K'|/(|K||K'|)$. Only distinct master seeds with verified distinct populations yield `disjoint`. Complexity: linear in manifest size plus the cost of population reconstruction.

---

## 12. Discussion

### 12.1 What is genuinely new here

The design effect and the inverse-variance formula are classical. What the present development contributes is exactness and an iff. Practitioners typically treat overlap as a source of "some" underestimation to be handled by conservative choices; Theorem 3.3 says the underestimation is a specific number computable from three cardinalities, Theorem 3.5 says there is no intermediate regime between disjoint and defective, Theorem 4.4 says the folk principle "more data cannot hurt" is false for overlapping legs, and Theorem 5.5 says no analytic ingenuity can extract more than the distinct draws contain. Theorem 6.3 unifies the two mechanisms — shared draws and shared objects — as summands of one identity, which is what makes a mechanical provenance audit (Algorithm C) possible.

### 12.2 Scope and limitations

The model is a second-moment model. Everything is exact for arbitrary joint distributions with the stated covariance structure, but nothing is claimed about higher moments, about non-exchangeable within-cluster correlation, or about bias. Equicorrelation within a cluster is an idealisation; with heterogeneous intra-cluster correlations the ceiling of Theorem 7.6 becomes $\bar\rho\sigma^2/k$ with $\bar\rho$ an appropriate average, and the qualitative conclusion is unchanged. The identification of "run overlap" with "index-set intersection" presumes a deterministic stream whose consumption order is reproducible — which is exactly the setting where the failure occurs.

We also emphasise what the audit does *not* establish. Nothing here says the observed $3$–$5\%$ deficit is spurious. The point estimate is unaffected by the variance defects; only the claimed precision is. The correct summary is that the evidence for a deviation is one seed's worth, which is less than it appeared to be.

### 12.3 Relation to the reported intervals

The run's own intervals, being cluster bootstraps over the $128$ moduli, are consistent with Theorem 7.6: they do not pretend to the precision that $76.8$ million pairs would imply under independence. It is only the *cross-run* combinations that failed, and they failed for reasons orthogonal to the intra-run analysis — which is why the intra-run verdict (both intervals cover $1$; randomness extended) survives the audit intact.

---

## 13. Future directions

**An intra-modulus correlation law.** The ceiling $k/\rho$ makes $\rho$ the single most valuable unknown in the design. A predictive law for $\rho$ as a function of modulus size, smoothness cut, and band would convert experiment planning from guesswork into optimisation: given a compute budget $B = km$ evaluations, the optimal split maximises $km/(1 + (m-1)\rho)$, which for known $\rho$ is monotone in $k$ — spend everything on more moduli until the per-modulus fixed cost dominates. Measuring $\hat\rho$ directly from existing per-cluster counts is cheap and should be done for every archived run.

**Sequential designs with provenance constraints.** Theorem 5.5 suggests a sequential rule: at each stage, the marginal value of a new leg is governed by $|U \cup S_{\mathrm{new}}| - |U|$, the *new* draws it contributes. A design that maximises new-draw yield per unit compute, subject to population-disjointness, is a well-posed combinatorial optimisation problem worth formulating.

**Heterogeneous and hierarchical correlations.** Extending Theorem 6.3 to three levels (band, modulus, draw) would let one audit designs that share a band but not a modulus, which is the next-finest failure mode after the two documented here.

**Sharp lineage bounds with partial overlap.** Theorem 5.5 is tight for the uniform pool over $U$, but for structured families (chains, prefix trees) one can ask for the tight bound as a function of the overlap poset — a question in the geometry of coefficient vectors under a lattice of constraints.

**Automatic provenance certificates.** Algorithm C should be a compulsory pre-registration artefact: a machine-checkable certificate accompanying each reported combination, asserting master-seed distinctness and population disjointness, so that a defective pooling cannot reach publication in the first place.

---

## 14. Conclusion

Three cardinalities decide whether a pooled estimate is honest: the sizes of two index sets and the size of their intersection. From that single observation follow an exact defect law, an iff-characterisation of valid inverse-variance pooling, a bound on what an entire lineage of runs from one seed can ever be worth, a two-level identity that catches shared populations as well as shared draws, and a ceiling that makes long runs on a fixed set of objects mathematically futile beyond a computable point.

Applied to a $76.8$-million-pair randomness experiment, these results retract one combination outright, dissolve the apparent threshold crossing of another, and leave a coherent verdict: both intervals cover the null, the deficit is a twice-gated candidate, and the only informative next move is a genuinely fresh master seed. That the corresponding lab rule is a corollary rather than a convention is the most useful thing the algebra provides.
