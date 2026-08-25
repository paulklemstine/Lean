# A Positional-Stratum Measure Framework for Retrieval Cost Laws

### The r̄-identity as universal object, the sharp booked envelope, an unconditional master inequality, and a corrected anchor table

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop a finite-measure framework for *positional strata* in one-shot search and retrieval cost models, and use it to settle the status of a family of closed-form "value" (speedup) laws that circulate in the applied literature on stratified retrieval. The central object is an exact identity: for every weight, every cost kernel and every stratum of nondegenerate mass, the expected cost decomposes as $\mathrm{EC} = P\,\bar r_R + (1-P)\,\bar r_C$, where $P$ is the capture mass of the retained stratum and $\bar r_R, \bar r_C$ are the conditional mean costs inside the stratum and its complement. Every closed form in the subject is a *booking* of this identity: a decision about how to summarise $\bar r_R$ and $\bar r_C$.

Three results follow. First, the standard closed form is exactly the uniform-within-cells booking, characterised by a booking factor $\Theta = \bar r_R/\mathrm{centre}(R)$ equal to $1$; we prove that $\Theta \equiv 1$ on all strata forces uniformity but that the single-cell converse is false, and we exhibit a family of admissible weights on which the booked *value* law overestimates the true cost by an unbounded factor. Value-universality therefore fails. Second, we supply the two guarded statements that survive: a two-sided booked envelope $P + (1-P)(m+1) \le \mathrm{EC} \le Pm + (1-P)M$ that is *sharp at both ends*, and an unconditional master inequality $S \le \min\big(1/(\Lambda\Theta\hat q),\, 2^{k}/(\Lambda\Theta)\big)$ whose only inputs are a majorization step and a pigeonhole bound on a $k$-bit filter. Third, we analyse the simultaneous-commitment (block) model, whose certified law is $S(\mu,P) = 1/\big(\mu P + (1-\mu)(1-P)\big)$: we show it is *derived* rather than posited, that it is **baseline-conditional** — against the descending baseline $C_0 = (M+1)/2$ the same algorithm is worth $S\cdot(M+1)/(2M) \in (S/2, S)$, asymptotically half — and that a same-prior adversary at a neighbouring admissible locus undercuts the certified anchor $5.4054\ldots$ with $5.3648\ldots$

We also record an erratum to a previously published anchor table: the row $(\mu, \hat P) = (0.02, 0.9853)$ is printed with the value $29.0698\ldots$, which is the law evaluated at the *rounded* input $P = 0.985$; at the stored $\hat P$ the correct value is $29.3152\ldots$. We prove that the feasibility verdict $\mu \le 1/S$ holds on the whole admissible half-box $\mu \le 1/2$, so no anchor's feasibility conclusion is affected. Finally we observe that $1/S$ is a Bernoulli agreement probability, which makes composition of strata strictly submultiplicative rather than multiplicative, and we characterise the canonical reporting prior $b(r) = \tfrac12 r^{-3/2}$ as the unique continuous density with a linear capture curve.

**Keywords:** positional strata, retrieval cost models, majorization, Chebyshev sum inequality, rearrangement, capture probability, speedup bounds, baseline conditionality.

---

## 1. Introduction

### 1.1 The setting

A one-shot retrieval algorithm faces $M$ ranked candidate slots and must find a single target. It may commit to examining a subset first — a *retained stratum* — and pay the remainder only if the target escaped. Cost models of this type appear wherever a ranked shortlist precedes an exhaustive fallback: cache hierarchies, candidate generation in recommender systems, filter-then-verify database pipelines, and the two-stage retrieval architectures of modern search.

The literature summarises such an algorithm by two numbers: the *retained fraction* $\mu$ and the *capture probability* $P$, and attaches to the pair a closed-form value

$$S(\mu, P) = \frac{1}{\mu P + (1-\mu)(1-P)}. \tag{1}$$

Anchor tables list measured pairs $(\mu, \hat P)$ from real workloads with their $S$ values, and use them for feasibility decisions of the form $\mu \le 1/S$.

Three questions about (1) have not been settled: whether it is derived or posited; whether it is universal across workloads honouring the same bookings; and which baseline it is a claim against. This paper answers all three, and in doing so corrects a printed anchor.

### 1.2 Contributions

1. **The universal object (Theorem 1).** The exact r̄-identity $\mathrm{EC} = P\bar r_R + (1-P)\bar r_C$, valid for all weights, all cost kernels and all strata of nondegenerate mass.
2. **Booking factors and uniformity (Theorems 2–6).** The uniform-cells closed form is the $\Theta \equiv 1$ booking; $\Theta \equiv 1$ on all strata characterises uniformity, but the single-cell converse fails.
3. **Failure of value-universality (Theorem 7).** An explicit family, honouring bookings exactly, on which the booked prediction exceeds the true cost by an unbounded factor.
4. **The sharp booked envelope (Theorems 8–11).** A two-sided bound determined by the bookings alone, attained at both ends, containing the booked value.
5. **Majorization, strictly (Theorems 12–14).** Chebyshev's inequality gives $C_{\mathrm{sort}} \le C_0$; a double-sum identity upgrades it to a strict inequality with an exact equality characterisation.
6. **The master inequality (Theorems 15–17).** $S \le \min\big(1/(\Lambda\Theta\hat q), 2^k/(\Lambda\Theta)\big)$, unconditional.
7. **The certified block law and its baseline (Theorems 18–22, 26).** Derivation, exact baseline ratio, strict two-sided baseline bracket, and a same-prior adversarial undercut.
8. **Feasibility and the erratum (Theorems 23–25).** $\mu \le 1/S$ on the admissible half-box; the corrected table row; feasibility unaffected.
9. **Coupling and composition (Theorems 27–29).** $1/S$ is a Bernoulli agreement probability; composition is strictly submultiplicative.
10. **The canonical reporting prior (Theorems 30–33).** $b(r) = \tfrac12 r^{-3/2}$ is uniform in the balance coordinate and is the unique continuous density with a linear capture curve.

---

## 2. The positional-stratum measure framework

### 2.1 Definitions

**Definition 1 (Positional space).** For $M \in \mathbb{N}$ the *positional space* is the finite set of ranked slots $\mathrm{Pos}(M) = \{1, 2, \ldots, M\}$.

**Definition 2 (Weight).** A *weight* is a function $w : \mathbb{N} \to \mathbb{R}$ with $w \ge 0$; the *mass* of a stratum $R$ is $\mathrm{mass}(R) = \sum_{i \in R} w(i)$. The weight is *normalised* if $\mathrm{mass}(\mathrm{Pos}(M)) = 1$; then $w(i)$ is the probability that the target sits in slot $i$.

**Definition 3 (Cost kernel).** A *cost kernel* is a function $c : \mathbb{N} \to \mathbb{R}$; $c(i)$ is the number of probes charged when the target is resolved at slot $i$. Two kernels carry the load:

- the **scan kernel** $c(i) = i$ (sequential probing, stopping at the target);
- the **block-commitment kernel**, constant on each stratum (the algorithm commits to a whole block before probing).

**Definition 4 (Expected cost).** $\displaystyle \mathrm{EC}(M; c, w) = \sum_{i \in \mathrm{Pos}(M)} c(i)\, w(i)$.

**Definition 5 (Conditional mean cost).** For a stratum $R$ of nonzero mass,
$$\bar r_R \;=\; \frac{\sum_{i \in R} c(i) w(i)}{\mathrm{mass}(R)}.$$

**Definition 6 (Cell centre and booking factor).** The *centre* of $R$ under the kernel $c$ is $\mathrm{centre}(R) = \frac{1}{|R|}\sum_{i \in R} c(i)$, the unweighted mean. The *booking factor* is
$$\Theta_R \;=\; \frac{\bar r_R}{\mathrm{centre}(R)},$$
the ratio of the true conditional mean cost to the cost of a uniformly distributed target inside the same stratum.

**Definition 7 (Full-scan and descending baselines).** The *full-scan-$M$ baseline* is $M$ (read everything). The *descending baseline* is $C_0 = (M+1)/2$, the expected scan cost of a uniformly located target in a sorted list.

### 2.2 The universal object

**Theorem 1 (r̄-identity).** Let $R \subseteq \mathrm{Pos}(M)$, let $w$ be normalised, and suppose $\mathrm{mass}(R) \ne 0$ and $\mathrm{mass}(\mathrm{Pos}(M)\setminus R) \ne 0$. Write $P = \mathrm{mass}(R)$ and let $C = \mathrm{Pos}(M) \setminus R$. Then for every cost kernel $c$,
$$\mathrm{EC}(M; c, w) \;=\; P\,\bar r_R \;+\; (1-P)\,\bar r_C .$$

*Proof sketch.* Split the index set: $\sum_{C} c w + \sum_{R} c w = \sum_{\mathrm{Pos}(M)} c w$. Normalisation gives $\mathrm{mass}(C) = 1 - P$. Multiplying each conditional mean by its own mass cancels the denominators, and the identity is the split. $\square$

Three features deserve emphasis. The identity assumes no shape for $w$, no monotonicity for $c$, and no relation between $R$ and the ordering of slots. It is an exact statement about a two-block conditional decomposition, and *every* closed-form law in this subject is obtained from it by substituting estimates for $\bar r_R$ and $\bar r_C$. We call such substitutions **bookings**.

### 2.3 Bookings and the detection of uniformity

**Theorem 2 (Uniform cells book $\Theta = 1$).** If $w$ is constant and nonzero on a nonempty stratum $R$, and $\mathrm{centre}(R) \ne 0$, then $\Theta_R = 1$.

*Proof sketch.* With $w \equiv a$ on $R$, $\mathrm{mass}(R) = |R|\,a$ and $\sum_{i\in R} c(i) w(i) = a \sum_{i \in R} c(i)$, so $\bar r_R = \frac{1}{|R|}\sum_{i\in R}c(i) = \mathrm{centre}(R)$. $\square$

**Theorem 3 ($\Theta \equiv 1$ on all cells forces uniformity).** Let $w \ge 0$ on $\mathrm{Pos}(M)$ and suppose that for *every* nonempty $R \subseteq \mathrm{Pos}(M)$ of nonzero mass, the conditional mean of the scan kernel equals the cell centre. Then $w$ is constant on $\mathrm{Pos}(M)$.

*Proof sketch.* Apply the hypothesis to the two-element stratum $R = \{i,j\}$ with $i \ne j$. It reads $\frac{i w_i + j w_j}{w_i + w_j} = \frac{i+j}{2}$, i.e. $2(i w_i + j w_j) = (i+j)(w_i + w_j)$, which rearranges to $(i-j)(w_i - w_j) = 0$; as $i \ne j$, $w_i = w_j$. The degenerate case $w_i + w_j = 0$ forces $w_i = w_j = 0$ by nonnegativity. $\square$

**Theorem 4 (The single-cell converse is false).** There is a nonnegative normalised weight on $\mathrm{Pos}(3)$ with $\bar r_{\mathrm{Pos}(3)} = \mathrm{centre}(\mathrm{Pos}(3))$ under the scan kernel and $w_1 \ne w_2$.

*Proof sketch.* Take $w = (\tfrac12, 0, \tfrac12)$. Then $\bar r = \tfrac12\cdot 1 + \tfrac12 \cdot 3 = 2 = \mathrm{centre}(\{1,2,3\})$, while $w_1 = \tfrac12 \ne 0 = w_2$. $\square$

Thus $\Theta$ is a *first-moment* statistic: a single value $\Theta = 1$ certifies nothing, and only the family $\{\Theta_R\}_R$ over all strata is a complete uniformity certificate. This is the precise sense in which "$\Theta \equiv 1$ iff uniform" is true.

**Theorem 5 (Booked law in $\Theta$-form).** Under the hypotheses of Theorem 1 and with nonzero cell centres,
$$\mathrm{EC} \;=\; P\,\Theta_R\,\mathrm{centre}(R) \;+\; (1-P)\,\Theta_C\,\mathrm{centre}(C).$$

*Proof sketch.* Substitute $\bar r_R = \Theta_R \,\mathrm{centre}(R)$ into Theorem 1. $\square$

This is the **F1 reporting convention**: state positional-stratum laws in this form, with the bookings $(\mu_{\mathrm{eff}}, P_{\mathrm{eff}}, \bar r_R, \bar r_C; \Lambda)$ exhibited, never as a bare closed form in $(\mu, P)$.

---

## 3. Value-universality fails, unboundedly

### 3.1 The booked prediction

For a *head stratum* of size $m$ inside $M$ slots with capture probability $P$, the uniform-cells booking of the scan kernel predicts
$$\mathrm{EC}_{\mathrm{booked}}(M, m, P) \;=\; P\cdot\frac{m+1}{2} \;+\; (1-P)\left(m + \frac{M-m+1}{2}\right), \tag{2}$$
the capture branch paying the centre of the head block and the escape branch paying the whole head block plus the centre of the tail.

**Theorem 6 (Exactness on uniform cells).** If $w \equiv P/m$ on $\mathrm{Pos}(m)$ and $w \equiv (1-P)/(M-m)$ on the complement, then $\mathrm{EC}(M; \mathrm{scan}, w)$ equals (2) exactly.

*Proof sketch.* Both blocks have uniform weight, so by Theorem 2 each conditional mean is its cell centre; substitute into Theorem 1. $\square$

### 3.2 The unbounded witness

**Theorem 7 (Value-universality fails).** For every $B \in \mathbb{R}$ there exist $M, m, P$ and a nonnegative weight $w$ with $0 < m < M$, $0 < P < 1$, $\mathrm{mass}(\mathrm{Pos}(m)) = P$, $\mathrm{mass}(\mathrm{Pos}(M)) = 1$, and
$$B \cdot \mathrm{EC}(M; \mathrm{scan}, w) \;<\; \mathrm{EC}_{\mathrm{booked}}(M, m, P).$$

*Proof sketch.* Choose $m$ large, set $M = 2m$, and let the **head witness** be
$$w(1) = 1 - \tfrac1m, \qquad w(m+1) = \tfrac1m, \qquad w \equiv 0 \text{ elsewhere}.$$
Its head mass is exactly $P = 1 - 1/m$, so the bookings are honoured. Its expected scan cost is
$$1\cdot\left(1-\tfrac1m\right) + (m+1)\cdot\tfrac1m \;=\; 2,$$
independent of $m$, whereas (2) at these bookings evaluates to $(m+3)/2$. Taking $m > 8B$ gives the claim. $\square$

So the booked *value* law is not an upper bound off uniform cells, and its failure is not by a constant factor. Empirically the effect is concentrated at head placements — sweeps over instances with $M = 64$ show violation rates near $0.44$ overall, and substantially higher when the mass is placed at the head of the stratum than at its middle or tail — which is exactly the geometry the witness above isolates.

### 3.3 What replaces it: the sharp booked envelope

**Theorem 8 (Booked envelope).** Let $m \le M$, let $w \ge 0$ satisfy $\mathrm{mass}(\mathrm{Pos}(m)) = P$ and $\mathrm{mass}(\mathrm{Pos}(M)) = 1$. Then
$$P\cdot 1 + (1-P)(m+1) \;\le\; \mathrm{EC}(M; \mathrm{scan}, w) \;\le\; P\,m + (1-P)\,M .$$

*Proof sketch.* Split $\mathrm{EC}$ over the head stratum and its complement. On the head, $1 \le i \le m$ for every slot, so its contribution lies between $1\cdot P$ and $m \cdot P$. On the complement, $m+1 \le i \le M$, so its contribution lies between $(m+1)(1-P)$ and $M(1-P)$. Add. $\square$

**Theorem 9 (Lower end attained).** The head witness of Theorem 7 with $M = 2m$ attains the lower bound exactly.

**Theorem 10 (Upper end attained).** The *tail witness* placing mass $P$ at slot $m$ and mass $1-P$ at slot $M$ satisfies $\mathrm{EC} = Pm + (1-P)M$ exactly.

*Proof sketch of both.* Each is a two-atom weight; evaluate $\mathrm{EC}$ directly and compare with the corresponding bound. $\square$

**Theorem 11 (The booked value is admissible as a report).** For $1 \le m$, $m+1 \le M$, $0 \le P \le 1$, the booked prediction (2) lies inside the envelope of Theorem 8.

*Proof sketch.* Both comparisons reduce, after clearing denominators, to $(1-P)(M - m - 1) \ge 0$ and $P(m-1) \ge 0$. $\square$

The envelope has width $P(m-1) + (1-P)(M-m-1)$: sharp given the bookings $(m, M, P)$, but wide when the stratum is large. Narrowing it requires booking a second statistic — most naturally $\Theta$ itself, or a within-cell second moment.

---

## 4. The two branches of the master inequality

### 4.1 Majorization

**Theorem 12 (Chebyshev / majorization step).** Let $M > 0$ and let $w$ be a normalised weight that is *antitone* on $\mathrm{Pos}(M)$ (i.e. $i \le j \Rightarrow w_j \le w_i$: heavier slots come first). Then
$$\mathrm{EC}(M; \mathrm{scan}, w) \;\le\; C_0 \;=\; \frac{M+1}{2}.$$

*Proof sketch.* The pair $(i \mapsto i,\, w)$ antivaries on $\mathrm{Pos}(M)$, so Chebyshev's sum inequality gives $M \sum_i i\,w_i \le \big(\sum_i i\big)\big(\sum_i w_i\big) = \frac{M(M+1)}{2}\cdot 1$. Divide by $M$. $\square$

**Theorem 13 (Rearrangement / exchange).** For $i \le j$ and $b \le a$, $\; i a + j b \le i b + j a$. Consequently, for an antitone $w$ and any permutation $\sigma$ supported on $\mathrm{Pos}(M)$,
$$\mathrm{EC}(M; \mathrm{scan}, w) \;\le\; \sum_{i \in \mathrm{Pos}(M)} i \cdot w(\sigma(i)).$$

*Proof sketch.* The scalar exchange is $(j-i)(a-b) \ge 0$; the global statement is the rearrangement inequality for an antivarying pair. $\square$

**Theorem 14 (Strict majorization and its equality case).** Let $w$ be antitone and normalised on $\mathrm{Pos}(M)$, $M > 0$. If there exist $a < b$ in $\mathrm{Pos}(M)$ with $w_b < w_a$, then $\mathrm{EC}(M;\mathrm{scan},w) < C_0$ strictly. Moreover
$$\mathrm{EC}(M;\mathrm{scan},w) = C_0 \iff w \text{ is constant on } \mathrm{Pos}(M).$$

*Proof sketch.* The engine is the exact **Chebyshev double-sum identity**, valid on any finite set $S$ and any $c, w$:
$$\sum_{i \in S}\sum_{j\in S} (c_i - c_j)(w_i - w_j) \;=\; 2\Big(|S| \sum_{i\in S} c_i w_i - \big(\textstyle\sum_{i\in S} c_i\big)\big(\sum_{i \in S} w_i\big)\Big),$$
proved by expanding the inner sum termwise. Under antitonicity every summand $(i - j)(w_i - w_j)$ is $\le 0$, so the whole double sum is $\le 0$, recovering Theorem 12. A single strict drop $w_b < w_a$ with $a<b$ contributes two strictly negative terms, so the double sum is strictly negative and the inequality is strict. Conversely, if $w$ is constant, both sides equal $C_0$ by the Gauss sum. $\square$

The strict form is what keeps the master chain informative: without it, a flat prior would satisfy the chain with equality and the bound would carry no information about non-flat priors.

### 4.2 Pigeonhole on a $k$-bit filter

**Theorem 15 (Large bucket).** Let $h$ assign each slot of $\mathrm{Pos}(M)$ to one of $2^k$ buckets. Then some bucket $b$ satisfies $|\{i \in \mathrm{Pos}(M) : h(i) = b\}| \ge M/2^k$.

*Proof sketch.* Fibrewise counting gives $\sum_b |h^{-1}(b)| = M$. If every fibre were strictly smaller than $M/2^k$, summing over the $2^k$ buckets would give $M < M$. $\square$

**Theorem 16 (Filter branch of the value bound).** If an algorithm's worst-case cost $C_A$ satisfies $C_A \ge M/2^k$ (it must scan a full bucket) and the baseline cost $C_{\mathrm{desc}} \ge 0$, then its speedup obeys
$$\frac{C_{\mathrm{desc}}}{C_A} \;\le\; \frac{C_{\mathrm{desc}}\, 2^{k}}{M}.$$

*Proof sketch.* Cross-multiply using $M \le C_A 2^k$. $\square$

### 4.3 The master inequality

**Theorem 17 (Master inequality).** Let $C_A > 0$ be the algorithm's cost, $C_{\mathrm{desc}}$ the baseline cost, and let $\Lambda > 0$, $\Theta > 0$, $\hat q > 0$ be the bookings (sort-to-descending cost ratio, within-cell nonuniformity, booked capture rate). If
$$\Lambda\Theta\hat q\, C_{\mathrm{desc}} \le C_A \quad\text{and}\quad \Lambda\Theta\, C_{\mathrm{desc}} \le 2^{k} C_A,$$
then
$$S = \frac{C_{\mathrm{desc}}}{C_A} \;\le\; \min\left(\frac{1}{\Lambda\Theta\hat q},\; \frac{2^{k}}{\Lambda\Theta}\right).$$
Moreover the second hypothesis is *automatic* whenever the algorithm must scan a full bucket of a $k$-bit filter ($M/2^k \le C_A$) and the bookings satisfy $\Lambda\Theta C_{\mathrm{desc}} \le M$.

*Proof sketch.* Each branch is a cross-multiplication of the corresponding hypothesis against $C_A > 0$. For the automatic case, chain $\Lambda\Theta C_{\mathrm{desc}} \le M \le 2^k C_A$. $\square$

The point of Theorem 17 is what it does *not* assume. The proof chain is: r̄-identity (exact) $\Rightarrow$ majorization $C_{\mathrm{sort}} \le C_0$ (Theorem 12, no shape hypothesis beyond antitonicity of the prior) $\Rightarrow$ the $\Lambda$-chain and the pigeonhole branch. Uniformity within cells is used nowhere. This is precisely the asymmetry established in this paper: **the value law is conditional, the master inequality is not.** There is no constant cap on the value; what survives is an inequality chain, with the cost-side structure intact and the *pathwise product* form lost (see §6).

---

## 5. The certified block law, its baseline, and the erratum

### 5.1 The simultaneous-commitment model

In the block (simultaneous-commitment) model the algorithm chooses a stratum of relative size $\mu$ *before* probing and must pay for the whole block it scans: $\mu M$ probes when the target is captured (probability $P$), and $(1-\mu)M$ otherwise.

**Definition 8.** $\mathrm{EC}_{\mathrm{blk}}(M;\mu,P) = M\big(\mu P + (1-\mu)(1-P)\big)$, and the *certified value* against the full-scan-$M$ baseline is $S(\mu,P) = 1/\big(\mu P + (1-\mu)(1-P)\big)$, i.e. equation (1).

**Theorem 18 (The certified law is an instance of the r̄-identity).**
$$\mathrm{EC}_{\mathrm{blk}}(M;\mu,P) \;=\; P\cdot(\mu M) \;+\; (1-P)\cdot\big((1-\mu)M\big).$$

*Proof sketch.* With the block-commitment kernel the conditional mean costs are the two block sizes; expand. $\square$

**Theorem 19 (The certified law is the block-model speedup).** For $M > 0$ and $(\mu, P)$ in the open unit box,
$$\frac{M}{\mathrm{EC}_{\mathrm{blk}}(M;\mu,P)} \;=\; S(\mu,P).$$

*Proof sketch.* The denominator $D(\mu,P) = \mu P + (1-\mu)(1-P)$ is positive on the open box, being a sum of two positive products; cancel $M$. $\square$

So (1) is *derived*, not posited — but only relative to the full-scan-$M$ baseline that appears in the numerator.

### 5.2 Baseline conditionality

**Definition 9.** The value of the same algorithm against the descending baseline is $S_{C_0}(M;\mu,P) = \dfrac{(M+1)/2}{\mathrm{EC}_{\mathrm{blk}}(M;\mu,P)}$.

**Theorem 20 (Exact baseline ratio).** For $M > 0$ and $(\mu,P)$ in the open box,
$$S_{C_0}(M;\mu,P) \;=\; S(\mu,P)\cdot\frac{M+1}{2M}.$$

**Theorem 21 (Baseline conditionality, two-sided).** For $M > 1$ and $(\mu,P)$ in the open box,
$$\frac{S(\mu,P)}{2} \;<\; S_{C_0}(M;\mu,P) \;<\; S(\mu,P).$$

*Proof sketch.* Both follow from Theorem 20 and the elementary bracket $\tfrac12 < \frac{M+1}{2M} < 1$ for $M > 1$, multiplied by the positive quantity $S(\mu,P)$. $\square$

The correction factor $(M+1)/(2M) \to \tfrac12$: for large $M$, the certified number **doubles** the value the same algorithm has against the descending baseline. A value claim is meaningless without naming its baseline, and this is the quantitative form of that slogan. We call this the *baseline-conditional* status of the block-model value law.

### 5.3 A same-prior adversary undercuts the anchor

**Theorem 22 (No locus-free guarantee).** $S(0.05, 0.85) = 200/37 = 5.4054\ldots$, whereas
$$5.3647 \;<\; S(0.052,\, 0.85) \;<\; 5.3649,$$
and in particular $S(0.052, 0.85) < S(0.05, 0.85)$.

*Proof sketch.* Direct evaluation: $D(0.05,0.85) = 0.0425 + 0.1425 = 0.185$, and $D(0.052,0.85) = 0.0442 + 0.1422 = 0.1864$. $\square$

The adversarial locus uses the *same prior* and remains admissible; only the booked retained fraction moves, by two parts in a thousand. Hence a guarantee must pin the locus as well as the baseline: value claims are properties of $(\text{model}, \text{baseline}, \text{locus})$, not of the algorithm alone.

### 5.4 Feasibility is rounding-insensitive

**Theorem 23 (Feasibility test).** For $0 < \mu \le \tfrac12$ and $0 < P < 1$,
$$\mu \;\le\; \frac{1}{S(\mu,P)} \;=\; D(\mu,P).$$

*Proof sketch.* $D(\mu,P) - \mu = \mu P - \mu + (1-\mu)(1-P) = (1-P)(1 - 2\mu) \ge 0$. $\square$

The defect $(1-P)(1-2\mu)$ is an exact expression, nonnegative on the entire admissible half-box, and vanishing only at the boundary $\mu = \tfrac12$ or $P = 1$. Feasibility therefore cannot be flipped by re-reading a measurement at a different precision — the fact we now use.

### 5.5 Erratum to the recorded anchor table

**Theorem 24 (Erratum).** With the certified law (1):
$$S(0.02,\, 0.9853) = \frac{10^{7}}{341120} \in (29.3151,\, 29.3152), \qquad S(0.02,\, 0.985) = \frac{10^{6}}{34400} \in (29.0697,\, 29.0698),$$
and $S(0.02, 0.985) < S(0.02, 0.9853)$.

*Proof sketch.* $D(0.02, 0.9853) = 0.019706 + 0.98\cdot 0.0147 = 0.0341120$ and $D(0.02, 0.985) = 0.0197 + 0.98\cdot 0.015 = 0.0344$; invert. $\square$

The recorded table prints the row with stored measurement $\hat P = 0.9853$ but with the value $29.0698\ldots$, which Theorem 24 identifies as the law evaluated at the **rounded** input $P = 0.985$. The corrected entry is $29.3152\ldots$. The discrepancy is a genuine bookkeeping error, and it is instructive: at $\mu = 0.02$ the certified law is steep in $P$, so the *fourth decimal* of the stored measurement carries a quarter of a unit of value. This is one of the two places where the resolution of the stored measurement is visible in the reported value; the other is the neighbouring reading $29.1$, which corresponds to an implied $P \approx 0.98504$ and therefore also lives in the fourth decimal of $\hat P$ — at the resolution limit of the recorded data.

**Theorem 25 (Feasibility unaffected).** At both the stored and the rounded readings, $0.02 \le 1/S$.

*Proof sketch.* Immediate from Theorem 23 with $\mu = 0.02 \le \tfrac12$. $\square$

Two further table readings should be recorded as superseded rather than erroneous. Rows printing $5.19$, $6.91$ and $4.35$ carry values from a *drafted* form of the law; the certified law at the same loci gives $5.4054$, $7.1567$ and $4.536$ respectively. In particular the reading $5.19$ is structurally explained: it sits inside the window between the drafted value $5.1948$ and the certified value $5.4054$, which pins a mild adverse loading of the retained stratum rather than indicating a corner identity. Finally, the prose value $4.649$ belongs to a stale locus: $S(0.115, 0.87) \in (4.6489, 4.6491)$, a locus not among the certified anchors.

**Feasibility conclusions of all four anchors are unaffected**, by Theorem 23: the verdict $\mu \le 1/S$ holds throughout the admissible half-box regardless of which reading of $\hat P$ is used.

### 5.6 Structure of the certified law

**Theorem 26 (Symmetries, positivity, monotonicity).** For all $\mu, P$:

1. $S(\mu, P) = S(1-\mu,\, 1-P)$ (complementation invariance);
2. $S(\mu, P) = S(P, \mu)$ (**balance is position**: the two bookings are interchangeable);
3. $S(\mu,P) > 1$ strictly on the open box (commitment never hurts, and strictly helps in the interior);
4. for $0 < \mu < \tfrac12$, $P \mapsto S(\mu, P)$ is strictly increasing (better capture is always worth more).

*Proof sketch.* (1) and (2) are polynomial identities in $D$. (3) is $D < 1$, which follows from $1 - D = \mu(1-P) + P(1-\mu) > 0$. (4) reduces after cross-multiplication to $(Q - P)(1-2\mu) > 0$ for $P < Q$. $\square$

Item (2) is the formal content of the slogan "balance is position": the geometric coordinate $\mu$ and the probabilistic coordinate $P$ enter the value law in exactly the same way, which is what licenses the reparametrisation $s = r^{-1/2}$ of §7.

---

## 6. Composition: a coupling reading

**Definition 10 (Agreement).** $D(\mu, P) = \mu P + (1-\mu)(1-P)$, so $S = 1/D$.

$D$ is exactly the probability that two independent Bernoulli variables, with parameters $\mu$ and $P$, take the same value. The certified value is therefore the reciprocal of an *agreement probability*, and the symmetries of Theorem 26 are the symmetries of agreement.

Stacking two independent stratifications multiplies the bookings: the composite retained fraction is $\mu_1\mu_2$ and the composite capture probability is $P_1P_2$ (the target must survive both filters). Does the value multiply?

**Theorem 27 (Coupling slack identity).** For all $a,b,c,d$,
$$D(ac,\, bd) - D(a,b)\,D(c,d) \;=\; (1-a)b(1-d) \;+\; a(1-b)(1-c) \;+\; (1-a)(1-b)\big((1-c)d + c(1-d)\big).$$

*Proof sketch.* Expand both sides; the identity is a polynomial rearrangement. Probabilistically, the event "the two products agree" strictly contains the event "both coordinate pairs agree", and the right-hand side enumerates the extra configurations. $\square$

**Theorem 28 (Strict submultiplicativity).** On the open box $0 < a,b,c,d < 1$,
$$S(ac,\, bd) \;<\; S(a,b)\,S(c,d).$$

*Proof sketch.* Every term on the right of Theorem 27 is positive on the open box, so $D(ac,bd) > D(a,b)D(c,d) > 0$; invert, reversing the inequality. $\square$

**Theorem 29 (Not multiplicative).** At $(\mu_1,P_1) = (\tfrac12, \tfrac9{10})$ and $(\mu_2, P_2) = (\tfrac12, 1)$: the composite value is $S(\tfrac14, \tfrac9{10}) = \tfrac{10}{3}$ while $S(\tfrac12,\tfrac9{10})\,S(\tfrac12,1) = 2\cdot 2 = 4$.

*Proof sketch.* Direct evaluation. $\square$

The practical reading: composed guarantees *may* be reported as products of factor values — the product is then conservative, never optimistic. The pathwise product form of the law is genuinely lost, but the inequality chain survives, which is exactly the pattern of §4.

---

## 7. The canonical reporting prior

The scale $\times$ balance formulation observes that if balance is position (Theorem 26(2)), the natural coordinate is the *balance coordinate* $s = r^{-1/2}$, where $r \ge 1$ is a scale variable.

**Definition 11.** The *canonical kernel* is $b(r) = \dfrac{1}{2r\sqrt r} = \tfrac12 r^{-3/2}$; the *capture CDF* is $x(r) = 1 - r^{-1/2}$.

**Theorem 30 (The canonical kernel is uniform in the balance coordinate).** For $R \ge 1$, $\;\int_1^R b(r)\,dr = 1 - R^{-1/2}$; equivalently the mass the canonical prior assigns to $[1, R]$ is the length of the balance interval $[R^{-1/2}, 1]$.

*Proof sketch.* $x$ is differentiable on $(0,\infty)$ with $x'(r) = b(r)$: differentiate $1 - (\sqrt r)^{-1}$ using $(\sqrt r)' = 1/(2\sqrt r)$ and simplify. Then apply the fundamental theorem of calculus, $b$ being continuous on $[1,R]$, together with $x(1) = 0$. $\square$

**Definition 12.** The *capture probability curve* of a reporting density $g$ is $P_g(R) = \big(\int_1^R g\big) / \big(\int_1^{R_{\max}} g\big)$.

**Theorem 31 (Exactly linear capture).** For $1 \le R$ and $1 < R_{\max}$, the canonical capture curve is
$$P(R) \;=\; \frac{1 - R^{-1/2}}{1 - R_{\max}^{-1/2}}, \qquad\text{i.e.}\qquad P(\mu) = \frac{\mu}{1 - R_{\max}^{-1/2}} \ \text{ with } \ \mu = 1 - R^{-1/2}.$$

*Proof sketch.* Substitute Theorem 30 into Definition 12 and note $x(R_{\max}) > 0$. $\square$

**Theorem 32 (Linear iff canonical).** Let $g$ be continuous with $\int_1^R g = c\,x(R)$ for all $R \ge 1$ and some constant $c$. Then $g(r) = c\,b(r)$ for all $r > 1$.

*Proof sketch.* Both sides of the hypothesis are differentiable in $R$; differentiating and using continuity of $g$ (so that the integral's derivative is $g$) gives $g = c\,x' = c\,b$ pointwise. $\square$

**Theorem 33 (The characterisation has content).** The uniform density on $[1, R_{\max}]$ does not have the canonical capture curve: at $R_{\max} = 4$, $R = 2$ the uniform capture value is $1/3$ while the canonical one is $1 - 2^{-1/2}$ divided by $1 - 4^{-1/2} = 1/2$, i.e. $2 - \sqrt 2 \approx 0.5858$.

Hence the canonical prior $b \propto r^{-3/2}$ is not a convention but the unique shape compatible with a linear capture curve — and it coincides with the uniform-in-position prior used in the certified reporting of the framework.

A caveat belongs here. The four measured anchors, read through the canonical prior, demand extremely balanced populations: the required scale ratio falls in the narrow range $R \approx 1.04$–$1.14$. Such populations are not typical of the workloads the anchors were taken from, so the anchors should be interpreted as *generator-shape estimators* — estimates of the shape of the population that would reproduce the reported captures — rather than as witnesses of an achieved value.

---

## 8. Algorithms

Three procedures follow directly from the theory and are worth isolating.

**(A) Envelope evaluation.** Given bookings $(M, m, P)$, return the interval $[\,P + (1-P)(m+1),\; Pm + (1-P)M\,]$ and the booked point value (2). Cost $O(1)$. By Theorems 8–10 the interval is the exact range of $\mathrm{EC}$ over all admissible weights, so a measured cost outside it certifies a booking violation.

**(B) Certified-value audit.** Given a locus $(\mu, \hat P)$, a slot count $M$, and a stated baseline, return: the full-scan value $S = 1/D$; the descending-baseline value $S\cdot(M+1)/(2M)$; the feasibility slack $D - \mu = (1-\hat P)(1-2\mu)$; and the *rounding sensitivity* $|S(\mu, \hat P) - S(\mu, \mathrm{round}(\hat P))|$. Cost $O(1)$. Running this audit on the anchor $(0.02, 0.9853)$ is what surfaces the erratum of §5.5.

**(C) Adversarial locus search.** Given a certified anchor and an admissible neighbourhood, maximise and minimise $S$ over the neighbourhood by evaluating $D$ on a grid or by using $\partial_\mu D = 2P - 1$ and $\partial_P D = 2\mu - 1$, whose signs are constant on each half-box. Since $D$ is bilinear, the extrema over an axis-aligned admissible box are attained at corners — a fact confirmed by brute-force enumeration in the block model — so the search is $O(1)$ per box. Theorem 22 is the output of this procedure at the anchor $(0.05, 0.85)$.

---

## 9. Discussion

### 9.1 What is universal and what is not

The framework separates cleanly into three tiers.

- **Tier 1 (identities).** The r̄-identity, the $\Theta$-form booked law, the Chebyshev double-sum identity, the coupling slack identity, the derivation of the block law. These hold with no hypotheses beyond nondegeneracy.
- **Tier 2 (unconditional inequalities).** The booked envelope, majorization $C_{\mathrm{sort}} \le C_0$ with its strict form, pigeonhole on a $k$-bit filter, the master inequality, submultiplicativity of composition, the feasibility test. These hold for all admissible bookings, with no shape assumption within cells.
- **Tier 3 (conditional closed forms).** The uniform-cells value law. Exact on uniform cells, admissible as a reporting convention, unbounded in error as a guarantee (Theorem 7), and baseline- and locus-dependent even when it is exact (Theorems 21 and 22).

Confusing Tier 3 for Tier 2 is the error this paper diagnoses; the erratum of §5.5 is a symptom of the same habit at the level of arithmetic hygiene.

### 9.2 A reporting discipline

The analysis supports four concrete conventions.

1. **State the law with its bookings.** Report $\mathrm{EC} = P\,\Theta_R\,\mathrm{centre}(R) + (1-P)\,\Theta_C\,\mathrm{centre}(C)$ with $(\mu_{\mathrm{eff}}, P_{\mathrm{eff}}, \bar r_R, \bar r_C; \Lambda)$ exhibited — never a bare closed form in $(\mu, P)$.
2. **Use the canonical prior for reporting.** $b \propto r^{-3/2}$, justified by Theorem 32 as the unique shape with linear capture.
3. **Admissibility rule.** Store the raw, unrounded measurement $\hat P$, and report the descending-baseline correction alongside any value.
4. **Name the baseline.** Every value claim must state its denominator; by Theorem 21 the ambiguity is a factor of nearly two.

### 9.3 Applications

The results transfer to any filter-then-verify pipeline. The envelope of Theorem 8 gives an audit test with no distributional assumptions: measure the cost, compare with the interval, and a violation certifies that the reported bookings do not describe the workload. The master inequality of Theorem 17 gives a hard cap on the value of a hashed-filter stage in terms of its bit budget: no amount of prior quality can push the speedup past $2^k/(\Lambda\Theta)$. Theorem 28 tells a pipeline designer that stacking stages is safe to report multiplicatively, and Theorem 23 tells a capacity planner that feasibility verdicts are robust to measurement resolution even where the value itself is not.

### 9.4 Limitations

The framework is one-shot: it does not model repeated queries with adaptive re-stratification, and the composition theory of §6 treats independent stages only. The cost kernels considered are deterministic functions of the resolved slot; probabilistic verification costs would replace $\bar r$ with a nested conditional mean, which the r̄-identity accommodates but the closed forms do not. The canonical prior characterisation of §7 assumes continuity of the reporting density; a distributional version would need a measure-theoretic argument. Finally, the converse direction of the master inequality — a matching lower bound exhibiting an algorithm that attains $\min(1/(\Lambda\Theta\hat q), 2^k/(\Lambda\Theta))$ — remains open, and constructing one is the natural next target.

---

## 10. Future directions

**What this cycle established, in one paragraph.** The universal object of the positional-stratum framework is the exact r̄-identity $\mathrm{EC} = P\bar r_R + (1-P)\bar r_C$, valid for every weight, every cost kernel and every stratum; the booked closed form is recovered exactly on uniform cells, and only there. The value law derived from the bookings is therefore **not** universal — its failure is unbounded — while the master inequality $S \le \min(1/(\Lambda\Theta\hat q), 2^k/(\Lambda\Theta))$ is unconditional, because it uses only the majorization step $C_{\mathrm{sort}} \le C_0$ and a pigeonhole bound on a $k$-bit filter. Two further structures emerged that were not in the original plan: the sharp two-sided booked envelope which replaces the failed value law, and the coupling reading of the certified law ($1/S$ is a Bernoulli agreement probability), which makes composition strictly submultiplicative rather than multiplicative.

**1. Envelope-optimal bookings.** The envelope $[P + (1-P)(m+1),\, Pm + (1-P)M]$ is sharp given $(m, M, P)$, but its width $P(m-1) + (1-P)(M-m-1)$ is large when the stratum is large. Adding one more booking — the within-cell second moment, or $\Theta$ itself — should collapse the envelope quadratically. The key insight is that $\Theta$ is exactly the first-order shape statistic the envelope is blind to, so bookkeeping $\Theta$ upgrades a two-sided bound into an identity. The $\Theta$-form law is already exact, so the only missing step is a sharp bound on $\Theta$ in terms of an entropy or variance budget.

**2. Information-theoretic master constant.** The $2^k$ branch of the master inequality comes from pigeonhole on a $k$-bit filter, which ignores the *distribution* of bucket sizes. Replacing counting by entropy should give $S \le 2^{H(\mathrm{bucket})}/(\Lambda\Theta)$ with $H \le k$, strictly better whenever the filter is unbalanced. The key insight is that the worst-case bucket is a maximum while the expected probe count is an average, and the gap between them is exactly a Rényi-entropy deficit. The pigeonhole step is already isolated as the only combinatorial input to the chain, so it can be swapped without touching the rest.

**3. Strict-majorization stability.** Strict majorization says a non-flat descending weight strictly beats the baseline, with equality exactly on the flat weight. Conjecture: the defect is bounded below by a multiple of the total variation distance to the flat weight, $C_0 - C_{\mathrm{sort}} \ge c\,M\,\lVert w - u\rVert_1^2$. The key insight is that the Chebyshev double sum is a positive-definite quadratic form in $w$ once the cost kernel is strictly increasing, so the defect is a squared distance in disguise. The double-sum identity is already available, which is the hard half of any quantitative version.

**4. Composition semigroup of loci.** $D(\mu,P) = \mu P + (1-\mu)(1-P)$ is a Bernoulli agreement probability, and the coupling slack identity quantifies the failure of multiplicativity exactly. The natural question is whether the loci form a semigroup under a modified composition law that *is* multiplicative — that is, whether one can renormalise the bookings after composition so that composed values multiply on the nose, and what the fixed points of that renormalisation are.

---

## 11. Conclusion

A closed-form speedup law is a compression of an identity. The identity here — $\mathrm{EC} = P\bar r_R + (1-P)\bar r_C$ — is exact and universal; the compression is not. We have shown precisely what the compression assumes (uniformity within cells, detectable only by the full family of booking factors), by how much it can fail (unboundedly, in the direction of overstating cost and hence understating value), what replaces it (a sharp envelope and an unconditional master inequality), and what it silently fixes when it is exact (a baseline, worth a factor of nearly two, and a locus, worth a few percent). We have corrected a printed anchor whose value was computed at a rounded input, and proved that the feasibility conclusions drawn from that table survive the correction. The discipline that emerges — book your averages, name your baseline, keep your raw digits — is inexpensive, and the results above are the price of skipping it.
