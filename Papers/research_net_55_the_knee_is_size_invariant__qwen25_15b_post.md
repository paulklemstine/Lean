# Size-Invariant Attention Budgets: Scale Invariance, Envelopes, Aggregation, and the Limits of a Two-Point Sweep

## Abstract

The *lossless attention budget*, or **knee** $k^*$, of an attention profile is the least number of top-ranked keys whose retention preserves a prescribed fraction $\tau$ of the profile's total mass over a context of length $n$. Empirically, the knee of a $1.5$-billion-parameter language model at gate $\tau=0.98$ is $16$ at context $512$ and $16$ at context $1024$ — identical to, and at the longer context half of, the knees of a model with one third the parameters, and below the pre-registered floor of a "budget grows with capacity" hypothesis at both cells. This paper develops the model-free theory of the knee functional that explains why such flatness is structural rather than accidental, and delimits exactly what a two-point budget sweep can and cannot establish.

We prove four independent mechanisms for size invariance. (i) **Exact homogeneity**: the knee is invariant under every positive rescaling of the profile, so parameter count per se can never move it; head replication is the special case. (ii) **Shared envelopes**: a family of profiles dominated by one summable envelope, with lead weights bounded below, admits a single budget serving *every* member at *every* context, computed from the envelope alone; conversely a size-uniform budget forces uniform mass concentration, so the invariance is rigid. (iii) **Aggregation over heads**: if every head of a model clears the gate at $K$ keys, so does the model, with no hypothesis whatsoever on the number of heads — the sharpest formal reading of "the key-value working set does not scale with model size". (iv) **Bounded distortion**: profiles agreeing within a multiplicative factor $\lambda$ have knees related by $k^*(w_2,n,\tau) \le k^*(w_1,n,\lambda^2\tau)$, and the $\lambda^2$ gate shift cannot be dropped — explicit $4$-comparable profiles have knees $1$ and $2$.

We refute the monotone size law outright: two strictly positive profiles, the second carrying strictly greater total mass at every context, have knees $18$ and $8$ at gate $0.98$. We show the measured flat chain $k^*(512)=k^*(1024)=16$ is exactly realizable (geometric profile of ratio $39/50$), hence consistent but not universal. Finally we audit the measurement protocol: at context $512$ the fail/pass pair $(8,16)$ soundly brackets the knee; at context $1024$ the single pass at the grid floor is compatible with knees $16$ and $1$, so the reported value is an upper bound only; and both reported sweeps decrease somewhere, which proves that the measured statistic is *not* the retained-mass functional. A complete realizability characterisation — a two-point sweep segment is realizable iff strictly increasing inside $(0,1)$ — locates the inconsistency precisely. An arithmetic mirror in the Pythagorean family yields exact size invariance under similarity, a sharp universal $12$-key short-leg budget at gate $0.98$, and a dichotomy: long-leg budgets are unbounded at every gate above $5/9$.

**Keywords:** attention budget, knee, key-value cache, retained mass, size invariance, multi-head aggregation, geometric profile, Pythagorean triples, sweep realizability.

---

## 1. Introduction

### 1.1 The empirical question

A transformer attending over a context of $n$ tokens produces, at each query position, a nonnegative weight for each of the $n$ keys. Sorting those weights in decreasing order gives a *profile*. A practical question with immediate consequences for deployment is: **how many of the top-ranked keys must be retained before truncation ceases to matter?** That number — the lossless attention budget, or the *knee* — is the size of the working set that a key-value cache must serve.

The intuition that this number grows with model capacity is natural: larger models are usually claimed to use their context more richly. It also has a testable form. A round of experiments measured a $1.5$B-parameter model against a $0.5$B baseline under an identical protocol, at a $0.98$ agreement gate on held-out text:

| context $n$ | full accuracy | $k^*$ ($1.5$B) | $k^*$ ($0.5$B) |
|---|---|---|---|
| $512$ | $0.4680$ | $16$ | $16$ |
| $1024$ | $0.5004$ | $16$ | $32$ |

with sweeps (budget $\mapsto$ agreement ratio)

- $n=512$: $8\mapsto0.9727$ (fail), $16\mapsto0.9896$ (pass), $24\mapsto0.9915$, $32\mapsto0.9969$, $48\mapsto0.9993$, $64\mapsto0.9988$;
- $n=1024$: $16\mapsto0.9806$ (pass), $24\mapsto0.9867$, $32\mapsto0.9881$, $48\mapsto0.9928$, $64\mapsto0.9927$, $96\mapsto0.9954$, $128\mapsto0.9974$.

Tripling the parameter count raised the budget by zero keys; at $n=1024$ it halved it. The pre-registered prediction ($[24,48]$ at $512$, $[32,96]$ at $1024$) failed below its own floor at both cells.

### 1.2 The mathematical question

An experiment on two model sizes cannot, by itself, establish a law. This paper asks the structural question behind the verdict: *which properties of a family of attention profiles make the knee independent of the family index?* We answer with four separate mechanisms, prove that the growth hypothesis is refutable by explicit profiles rather than merely unsupported, and prove sharp limits on what a budget sweep of the kind performed can certify.

Nothing below depends on any property of transformers. The objects are strictly positive sequences; the theorems are statements about the geometry of their partial sums.

### 1.3 Contributions

1. **Scale invariance** (§3.1): $k^*(cw) = k^*(w)$ for $c>0$, exactly, at every context and gate.
2. **Envelope size-uniformity and rigidity** (§3.2–3.3): a summable shared envelope plus uniformly positive lead weight yields one budget for a whole family; conversely, size-uniformity is equivalent to a uniform concentration bound.
3. **Multi-head aggregation** (§4): the aggregate knee is bounded by the worst per-head knee, uniformly in the head count.
4. **Distortion transfer and its sharpness** (§5): a $\lambda^2$ gate shift transfers a measured budget across $\lambda$-comparable profiles, and cannot be removed.
5. **Refutation of the size law and realizability of the flat chain** (§6).
6. **A sweep calculus** (§7): sound bracketing, grid-floor indeterminacy, non-monotonicity as a proof that the measured statistic is not retained mass, and an exact realizability criterion for two-point segments.
7. **An arithmetic mirror** (§8): similarity invariance of the knee on Pythagorean triples, a sharp universal $12$-key short-leg budget at gate $0.98$, and a short-leg / long-leg dichotomy.

---

## 2. The knee functional

Throughout, a **profile** is a function $w : \mathbb{N} \to \mathbb{R}$ with $w_i > 0$ for all $i$, interpreted as attention weights already sorted in decreasing order of importance. (Positivity, not monotonicity, is what the theory needs; monotone rearrangement is assumed to have been performed.)

**Definition 2.1 (Head mass).** For $k \in \mathbb{N}$,
$$M_w(k) \;=\; \sum_{i<k} w_i .$$
$M_w$ is strictly increasing, $M_w(0)=0$, and $M_w(k+1) = M_w(k) + w_k$.

**Definition 2.2 (Retained fraction).** For a context length $n \ge 1$ and a budget $k$,
$$R_w(n,k) \;=\; \frac{M_w(\min(k,n))}{M_w(n)} \;\in\; (0,1] \quad (k \ge 1).$$
$R_w(n,\cdot)$ is strictly increasing on $[0,n]$ and constant at $1$ beyond $n$.

**Definition 2.3 (Knee / lossless attention budget).** For a gate $\tau \in \mathbb{R}$,
$$k^*(w,n,\tau) \;=\; \min\{\, k \in \mathbb{N} \;:\; R_w(n,k) \ge \tau \,\}.$$
The set is nonempty for $\tau \le 1$ since $R_w(n,n)=1$.

Two elementary facts are used constantly and we record them as lemmas.

**Lemma 2.4 (Pass certificate).** If $R_w(n,k) \ge \tau$ then $k^*(w,n,\tau) \le k$.

**Lemma 2.5 (Fail certificate).** If $n \ge 1$, $\tau \le 1$ and $R_w(n,k) < \tau$ then $k < k^*(w,n,\tau)$.

*Proof of both.* Immediate from the definition of a minimum, together with the fact that the passing set is upward-closed (monotonicity of $R_w(n,\cdot)$). $\square$

**Lemma 2.6 (Bracketing).** If $n \ge 1$, $\tau \le 1$, $R_w(n,j) < \tau$ and $R_w(n,k) \ge \tau$, then $j < k^*(w,n,\tau) \le k$.

*Proof.* Combine Lemmas 2.4 and 2.5. $\square$

**Definition 2.7 (Geometric profile).** For $0<r<1$, $g_r(i) = r^i$. Then $M_{g_r}(k) = \frac{1-r^k}{1-r}$ and
$$R_{g_r}(n,k) = \frac{1-r^{\min(k,n)}}{1-r^{\,n}} .$$

---

## 3. Mechanism I: homogeneity, envelopes, rigidity

### 3.1 Exact scale invariance

**Lemma 3.1.** $M_{cw}(k) = c\,M_w(k)$ for all $c \in \mathbb{R}$, $k \in \mathbb{N}$.

*Proof.* Distributivity of multiplication over the finite sum $\sum_{i<k}$. $\square$

**Theorem 3.2 (Retained mass is scale free).** For $c>0$, every $n \ge 1$ and every $k$,
$$R_{cw}(n,k) = R_w(n,k).$$

*Proof.* Apply Lemma 3.1 to numerator and denominator; $c>0$ lets it cancel. $\square$

**Theorem 3.3 (Scale invariance of the knee).** For $c>0$, every $n$, every $\tau$,
$$k^*(cw,n,\tau) = k^*(w,n,\tau).$$

*Proof.* By Theorem 3.2 the two passing sets $\{k : R(n,k)\ge\tau\}$ are the same set, hence have the same minimum. $\square$

**Corollary 3.4 (Head replication).** Replacing a head by $m \ge 1$ identical copies produces the aggregate profile $m\,w$ and leaves the knee unchanged at every context and gate. In particular $k^*(3w,n,\tau)=k^*(w,n,\tau)$: in the replication model of capacity, tripling the model moves the budget by exactly zero keys.

**Interpretation.** The knee is a *class function on the projective space of profiles*: it sees shape, never total mass. Any notion of "size" that enters the profile through an overall normalisation is invisible to it. This mechanism is exact and unconditional, and it is the reason no measurement of size alone can be informative about the knee unless the shape changes too.

### 3.2 Size-uniform budgets from a shared envelope

Real families are not rescalings of one another, so we need a mechanism tolerant of genuine structural change.

**Definition 3.5 (Size-uniform budget).** A family $\{W_s\}_{s\in I}$ of profiles is *size-uniform at gate $\tau$* if
$$\exists K \in \mathbb{N}\ \ \forall s \in I\ \ \forall n \ge 1: \quad k^*(W_s, n, \tau) \le K .$$

**Lemma 3.6 (Block bound).** Suppose $0 < W_s(i) \le v_i$ for all $s,i$, with $v$ summable. Then for all $s$ and all $k,n$,
$$M_{W_s}(n) - M_{W_s}(k) \;\le\; \sum_{i} v_i \;-\; \sum_{i<k} v_i .$$

*Proof.* If $n \le k$ the left side is $\le 0$ and the right side is $\ge 0$ by nonnegativity of $v$. If $k<n$, the left side equals $\sum_{k \le i < n} W_s(i) \le \sum_{k\le i<n} v_i \le \sum_i v_i - \sum_{i<k} v_i$. $\square$

**Theorem 3.7 (Envelope theorem).** Let $\{W_s\}_{s\in I}$ satisfy: (a) $W_s(i)>0$ for all $s,i$; (b) $W_s(i) \le v_i$ for a summable $v$; (c) $W_s(0) \ge c$ for some $c>0$ and all $s$. Then for every gate $\tau < 1$ the family is size-uniform at $\tau$. Moreover a valid $K$ is determined by $v$, $c$ and $\tau$ alone — it does not depend on the index $s$, hence not on depth, width or parameter count.

*Proof.* Since $v$ is summable, its partial sums converge, so there is $K_0$ with
$$\sum_i v_i - \sum_{i<K_0} v_i \;<\; (1-\tau)\,c .$$
Put $K = \max(K_0,1)$; the tail bound persists because the partial sums increase. Fix $s$ and $n\ge1$. If $n \le K$ then $k^*(W_s,n,\tau) \le n \le K$, since a budget equal to the context always retains everything. If $n > K$, we verify the pass certificate $R_{W_s}(n,K) \ge \tau$, i.e. $\tau\,M_{W_s}(n) \le M_{W_s}(K)$. From (c), $M_{W_s}(K) \ge M_{W_s}(1) = W_s(0) \ge c$. From Lemma 3.6,
$$M_{W_s}(n) - M_{W_s}(K) \;<\; (1-\tau)c .$$
For $\tau \le 0$ the claim is trivial. For $0<\tau<1$,
$$\tau\big(M_{W_s}(n) - M_{W_s}(K)\big) \le \tau (1-\tau)c \le (1-\tau)c \le (1-\tau) M_{W_s}(K),$$
which rearranges to $\tau M_{W_s}(n) \le M_{W_s}(K)$. Apply Lemma 2.4. $\square$

**Remark 3.8 (Necessity of the lead-weight hypothesis).** The hypothesis $c>0$ is load-bearing. Take $W_s$ to be, for each $s$, a profile that is nearly uniform on its first $s$ coordinates with total mass $1$: the lead weights tend to $0$, the profiles flatten, and $k^*(W_s,s,\tau) \to \infty$. Summability of an envelope alone cannot prevent this because the envelope only bounds from above.

**Interpretation.** Theorem 3.7 is the precise content of the empirical slogan that a budget of a few tens of keys covers every real model at every context measured. What is being asserted is not a property of the models' sizes but a property of a *tail envelope* shared across the family.

### 3.3 Rigidity: size-uniformity forces uniform concentration

**Theorem 3.9 (Rigidity).** Let $\{W_s\}$ be strictly positive and $\tau \le 1$. If the family is size-uniform at $\tau$ with budget $K$, then
$$\tau \, M_{W_s}(n) \;\le\; M_{W_s}(K) \qquad \text{for every } s \text{ and every } n \ge 1 .$$

*Proof.* Fix $s,n$. By definition of the knee, $R_{W_s}(n, k^*(W_s,n,\tau)) \ge \tau$, i.e. $\tau M_{W_s}(n) \le M_{W_s}(\min(k^*,n))$. Since $\min(k^*,n) \le k^* \le K$ and $M_{W_s}$ is increasing, the right side is $\le M_{W_s}(K)$. $\square$

Thus "one budget for all sizes" is *equivalent* (with Theorem 3.7 supplying a sufficient condition) to a uniform concentration statement: each member of the family concentrates a $\tau$-fraction of the mass of every context inside a common finite prefix. Size invariance is not a soft or statistical claim; it is a rigid structural one.

---

## 4. Mechanism II: aggregation over heads

The profile a deployment sees is a *sum over attention heads*. In the model families in question, parameter count grows largely by adding heads (and layers, which aggregate similarly). This section shows aggregation is the mechanism most directly responsible for the observed flatness.

**Lemma 4.1 (Additivity of head mass).** For a finite index set $S$ and profiles $\{W_j\}_{j\in S}$,
$$M_{\sum_{j\in S} W_j}(k) \;=\; \sum_{j \in S} M_{W_j}(k).$$

*Proof.* Exchange the two finite sums. $\square$

**Theorem 4.2 (Aggregate pass).** Let $S$ be a nonempty finite index set, $W_j$ strictly positive profiles, $n \ge 1$, $k \in \mathbb{N}$. If $R_{W_j}(n,k) \ge \tau$ for every $j \in S$, then
$$R_{\textstyle\sum_{j\in S} W_j}(n,k) \;\ge\; \tau .$$

*Proof.* The hypothesis at head $j$ is the linear inequality $\tau\,M_{W_j}(n) \le M_{W_j}(\min(k,n))$. Sum over $j \in S$:
$$\tau \sum_{j\in S} M_{W_j}(n) \;\le\; \sum_{j\in S} M_{W_j}(\min(k,n)).$$
By Lemma 4.1 both sides are the head masses of the aggregate, and the aggregate's denominator is positive since each $W_j$ is. Divide. $\square$

**Theorem 4.3 (Multi-head budget theorem).** Let $S$ be a nonempty finite index set, $W_j$ strictly positive, $n \ge 1$, $\tau \le 1$, and suppose $k^*(W_j,n,\tau) \le K$ for every $j \in S$. Then
$$k^*\Big(\sum_{j\in S} W_j,\ n,\ \tau\Big) \;\le\; K .$$
**No hypothesis is placed on $|S|$.**

*Proof.* For each $j$, $R_{W_j}(n,k^*(W_j,n,\tau)) \ge \tau$ and $R_{W_j}(n,\cdot)$ is monotone, so $R_{W_j}(n,K) \ge \tau$. Apply Theorem 4.2 at $k=K$ and then Lemma 2.4. $\square$

**Corollary 4.4 (Head count does not move the budget).** Let $S,T$ be nonempty finite head pools of *arbitrary* sizes drawn from a common pool of strictly positive heads all satisfying $k^*(W_j,n,\tau)\le K$. Then both aggregated models have budget at most $K$:
$$k^*\Big(\sum_{j\in S} W_j, n, \tau\Big) \le K \quad\text{and}\quad k^*\Big(\sum_{j\in T} W_j, n, \tau\Big) \le K .$$

**Interpretation.** This is the sharpest available formal reading of "the key-value working-set budget does not scale with model size". A model can only become expensive by *acquiring a bad head* — a head with a flat profile and hence a large individual knee — never by getting bigger per se. The theorem also identifies the decisive missing measurement: because the model-level knee is controlled by the worst per-head knee, a per-head knee spectrum is the *only* mechanistic explanation of a model-level knee. That spectrum was not recorded in the round.

**Remark 4.5 (Direction of the bound).** Theorem 4.3 is a one-sided bound and the inequality can be strict: mixing heads with different shapes can produce an aggregate sharper than the worst head. Equality is expected unless one head carries a vanishing share of the total mass, since retained mass of a sum is a *mediant* of the retained masses of the summands, weighted by their mass shares.

---

## 5. Mechanism III: bounded distortion and budget transfer

Transferring a measured budget between two models requires a quantitative notion of "similar attention shape".

**Definition 5.1 ($\lambda$-comparability).** Profiles $w_1,w_2$ are $\lambda$-comparable ($\lambda \ge 1$) if $w_1(i) \le \lambda\,w_2(i)$ and $w_2(i) \le \lambda\,w_1(i)$ for all $i$.

**Theorem 5.2 (Distortion bound).** If $w_1,w_2$ are strictly positive and $\lambda$-comparable, then for all $n \ge 1$ and all $k$,
$$\frac{R_{w_1}(n,k)}{\lambda^{2}} \;\le\; R_{w_2}(n,k).$$

*Proof.* Summing $w_1(i)\le\lambda w_2(i)$ over $i < \min(k,n)$ gives $M_{w_1}(\min(k,n)) \le \lambda M_{w_2}(\min(k,n))$; summing $w_2(i) \le \lambda w_1(i)$ over $i<n$ gives $M_{w_2}(n) \le \lambda M_{w_1}(n)$. Then
$$\frac{M_{w_1}(\min(k,n))}{M_{w_1}(n)} \;\le\; \frac{\lambda M_{w_2}(\min(k,n))}{M_{w_2}(n)/\lambda} \;=\; \lambda^{2} R_{w_2}(n,k). \qquad\square$$

The exponent $2$ is structural: comparability is used once in the numerator and once, in the reverse direction, in the denominator.

**Theorem 5.3 (Budget transfer with a gate shift).** Under the hypotheses of Theorem 5.2, if $\lambda^2\tau \le 1$ then
$$k^*(w_2,n,\tau) \;\le\; k^*\big(w_1,n,\lambda^{2}\tau\big).$$

*Proof.* Put $k_1 = k^*(w_1,n,\lambda^2\tau)$, so $R_{w_1}(n,k_1) \ge \lambda^2\tau$. By Theorem 5.2, $R_{w_2}(n,k_1) \ge R_{w_1}(n,k_1)/\lambda^2 \ge \tau$. Apply Lemma 2.4. $\square$

**Theorem 5.4 (The gate shift cannot be dropped).** There exist strictly positive profiles $w_1,w_2$ that are $4$-comparable with
$$k^*(w_1,3,0.9) = 1, \qquad k^*(w_2,3,0.9) = 2 .$$

*Proof.* Take $w_1 = (95,4,1,1,1,\dots)$ and $w_2 = (85,14,1,1,1,\dots)$ (only the first three coordinates matter at context $3$). Comparability with $\lambda=4$ holds coordinatewise: $95 \le 4\cdot 85$, $85 \le 4\cdot 95$, $4 \le 4\cdot 14$, $14 \le 4\cdot 4$, $1\le4$. At context $3$: $M_{w_1}(3)=100$, $R_{w_1}(3,1) = 0.95 \ge 0.9$ and $R_{w_1}(3,0)=0<0.9$, so $k^*=1$ by Lemma 2.6. Also $M_{w_2}(3)=100$, $R_{w_2}(3,1)=0.85 < 0.9$ and $R_{w_2}(3,2)=0.99 \ge 0.9$, so $k^*=2$. $\square$

Both witnesses are strictly positive, and $\tau=0.9$ is interior to $(0,1)$; the example is not degenerate. **Consequence:** approximate agreement of attention shape suffices to transfer a budget, but always at a price paid in gate margin — precisely the quantity a two-point size sweep does not report.

---

## 6. Refuting the size law; realizing the flat chain

### 6.1 A context-cheap knee calculus for geometric profiles

Exact knee values at contexts $512$ and $1024$ appear to require evaluating $r^{1024}$ in exact arithmetic. Two observations remove that cost.

**Lemma 6.1 (Context-free pass).** If $0<r<1$, $n\ge1$ and $r^{K} \le 1-\tau$, then $R_{g_r}(n,K) \ge \tau$ and hence $k^*(g_r,n,\tau) \le K$.

*Proof.* $R_{g_r}(n,K) = \frac{1-r^{\min(K,n)}}{1-r^n} \ge 1-r^{\min(K,n)} \ge 1-r^{K} \ge \tau$ (using $1-r^n \le 1$ and monotonicity of $r^{(\cdot)}$). $\square$

**Lemma 6.2 (Antitone in context).** If $0<r<1$, $1 \le m \le n$ and $k \le n$, then
$$R_{g_r}(n,k) \;\le\; \frac{1-r^{k}}{1-r^{m}} .$$

*Proof.* $R_{g_r}(n,k)=\frac{1-r^k}{1-r^n}$ and $r^n \le r^m$, so the denominator on the right is no larger. $\square$

**Theorem 6.3 (Exact knee from small powers).** Let $0<r<1$, $1 \le m \le n$, $1 \le K \le n$, $\tau \le 1$. If
$$r^{K} \le 1-\tau \qquad\text{and}\qquad \frac{1-r^{K-1}}{1-r^{m}} < \tau,$$
then $k^*(g_r,n,\tau) = K$.

*Proof.* Lemma 6.1 gives $k^* \le K$. Lemma 6.2 with $k = K-1$ and the second hypothesis give $R_{g_r}(n,K-1) < \tau$, so Lemma 2.5 gives $K-1 < k^*$. $\square$

Both certificates involve only powers up to $\max(K,m)$, so a short reference context $m=64$ suffices for all $n \ge 64$.

**Example 6.4.** At gate $\tau=0.98$: $k^*(g_{3/5},n,0.98)=8$, $k^*(g_{4/5},n,0.98)=18$, $k^*(g_{1/100},n,0.98)=1$, and $k^*(g_{39/50},n,0.98)=16$, for every $n \ge 64$. (For $r=4/5$: $0.8^{18} \approx 0.0180 \le 0.02$ while $(1-0.8^{17})/(1-0.8^{64}) \approx 0.9775 < 0.98$.)

### 6.2 The pre-registered growth law is false

**Theorem 6.5 (No monotone size law).** There exist strictly positive profiles $w_{\mathrm{small}}, w_{\mathrm{large}}$ with
$$M_{w_{\mathrm{small}}}(n) < M_{w_{\mathrm{large}}}(n) \quad \text{for every } n \ge 1,$$
yet
$$k^*(w_{\mathrm{small}},512,0.98) = 18, \qquad k^*(w_{\mathrm{large}},512,0.98) = 8 .$$

*Proof.* Take $w_{\mathrm{small}} = g_{4/5}$ and $w_{\mathrm{large}} = 10\,g_{3/5}$. Then $M_{w_{\mathrm{small}}}(n) = 5(1-(4/5)^n)$ and $M_{w_{\mathrm{large}}}(n) = 25(1-(3/5)^n)$. For $n \ge 1$, $(3/5)^n \le 3/5$ so $M_{w_{\mathrm{large}}}(n) \ge 10 > 5 > M_{w_{\mathrm{small}}}(n)$. The knees follow from Example 6.4 together with scale invariance (Theorem 3.3) for the factor $10$. $\square$

**Discussion.** Total attention mass at every context is the natural capacity proxy available at the level of profiles; the theorem exhibits a capacity increase accompanied by a ten-key *decrease* in the budget. Note the refutation is not a rescaling artefact: the witnesses have genuinely different decay ratios ($3/5$ against $4/5$), so the knee gap $8$ versus $18$ survives any normalisation. "The knee grows with model size" is therefore false as a law about attention profiles, independently of any measurement.

### 6.3 The measured flat chain is exactly realizable

**Theorem 6.6 (Flat chain).** $k^*(g_{39/50},512,0.98) = 16$ and $k^*(g_{39/50},1024,0.98) = 16$.

*Proof.* Theorem 6.3 with $r=0.78$, $K=16$, $m=64$: $0.78^{16} \approx 0.0185 \le 0.02$, and $(1-0.78^{15})/(1-0.78^{64}) \approx 0.9763 < 0.98$. Both certificates are context-free or evaluated at $m=64$, so they serve $n=512$ and $n=1024$ alike. $\square$

So the measured chain $\{16,16\}$ is attained on the nose by an explicit profile. Flatness across contexts is *consistent*, but only as a statement about a profile class: it is not a theorem about all profiles (a profile whose knee at $2n$ exceeds its knee at $n$ is easy to construct), and it is not evidence for any particular mechanism, since exact homogeneity and a shared envelope both produce the same table.

---

## 7. Auditing the sweep: what a knee table can and cannot say

### 7.1 A sound bracket, and a hole at the grid floor

**Theorem 7.1 (Bracket at $n=512$).** Let $w$ be strictly positive, $n \ge 1$, and suppose $R_w(n,8) = 0.9727$ and $R_w(n,16) \ge 0.98$. Then
$$8 < k^*(w,n,0.98) \le 16 .$$

*Proof.* Lemma 2.6. $\square$

Only monotonicity of retained mass is used: the fail/pass pair straddling the gate is a sound razor.

**Theorem 7.2 (Grid-floor indeterminacy at $n=1024$).** There exist strictly positive profiles $w_1,w_2$ with
$$R_{w_1}(1024,16) \ge 0.98, \quad R_{w_2}(1024,16) \ge 0.98,$$
$$k^*(w_1,1024,0.98) = 16, \qquad k^*(w_2,1024,0.98) = 1 .$$

*Proof.* Take $w_1 = g_{39/50}$ (Theorem 6.6) and $w_2 = g_{1/100}$, whose knee is $1$ because $0.01 \le 1-0.98$ (Lemma 6.1) and $R_{w_2}(1024,0)=0<0.98$. Both clear the gate at $16$ keys. $\square$

**Consequence.** At $n=1024$ the round measured a pass at the grid floor $16$ and nothing below it. That single measurement is compatible with every knee in $[1,16]$. The reported $k^*=16$ is therefore an **upper bound only**, and a sub-$16$ sweep is logically necessary. The low-knee witness is not pathological — it is an ordinary geometric profile with a strong spectral gap, precisely the regime real models are claimed to occupy.

### 7.2 Realizability of sweep segments

**Theorem 7.3 (Cumulative realization principle).** Let $F : \mathbb{N} \to \mathbb{R}$ be strictly increasing with $F(0)=0$. Then $w_i := F(i+1)-F(i)$ is a strictly positive profile with $M_w(k) = F(k)$ for all $k$.

*Proof.* Positivity is strict monotonicity; the mass identity is the telescoping sum $\sum_{i<k}(F(i+1)-F(i)) = F(k)-F(0)$. $\square$

**Definition 7.4 (Block profile).** For $p<q$ and $a,b,c>0$,
$$B_{p,q}^{a,b,c}(i) = \begin{cases} a & i<p,\\ b & p \le i < q,\\ c & i \ge q.\end{cases}$$
Its head masses are $ka$ for $k\le p$; $pa+(k-p)b$ for $p \le k \le q$; and $pa+(q-p)b+(k-q)c$ for $k \ge q$.

**Theorem 7.5 (Two-point realizability).** Let $0<p<q<n$ and $v_1,v_2 \in \mathbb{R}$. There exists a strictly positive profile $w$ with $R_w(n,p)=v_1$ and $R_w(n,q)=v_2$ **if and only if** $0<v_1<v_2<1$.

*Proof.* ($\Rightarrow$) Positivity of head mass gives $v_1>0$; strict monotonicity of $R_w(n,\cdot)$ below $n$ gives $v_1<v_2$; and $q<n$ gives $v_2<1$. ($\Leftarrow$) Set
$$a = \frac{v_1}{p}, \qquad b = \frac{v_2-v_1}{q-p}, \qquad c = \frac{1-v_2}{n-q},$$
all strictly positive under the hypotheses, and take $w = B_{p,q}^{a,b,c}$. Then $M_w(p)=v_1$, $M_w(q)=v_2$ and $M_w(n)=1$, so $R_w(n,p)=v_1$ and $R_w(n,q)=v_2$. $\square$

Thus the *only* constraint a genuine attention profile places on a two-point sweep segment is strict increase inside $(0,1)$; a sweep table that respects this reveals nothing further about the underlying profile.

### 7.3 The measured statistic is not retained mass

**Lemma 7.6 (No retained inversion).** If $w$ is strictly positive and $j<k<n$, then $R_w(n,j) < R_w(n,k)$.

*Proof.* $M_w(j) < M_w(k)$ since the omitted weights $w_j,\dots,w_{k-1}$ are strictly positive; both budgets lie below $n$, so no truncation occurs, and the common denominator $M_w(n)$ is positive. $\square$

**Theorem 7.7 (Both sweeps are inconsistent with retained mass).**
1. No strictly positive profile satisfies $R_w(512,48) = 0.9993$ and $R_w(512,64) = 0.9988$.
2. No strictly positive profile satisfies $R_w(1024,48) = 0.9928$ and $R_w(1024,64) = 0.9927$.

*Proof.* Both pairs decrease as the budget increases, contradicting Lemma 7.6 since $48<64<512$ and $48<64<1024$. $\square$

**Theorem 7.8 (The monotone prefix *is* realizable).** There exists a strictly positive profile with $R_w(512,8)=0.9727$ and $R_w(512,16)=0.9896$.

*Proof.* Theorem 7.5 with $p=8$, $q=16$, $n=512$, since $0<0.9727<0.9896<1$. $\square$

**Interpretation.** Retained mass is strictly increasing in the budget below the context length; both measured sweeps decrease somewhere. Therefore the measured agreement ratio is **not** the retained-mass functional — it is a downstream, non-monotone read-out of it. The size of the violations, $5\times10^{-4}$ and $1\times10^{-4}$, sits well inside the reported standard error of about $0.3\%$, which locates the effect precisely: sampling noise on an accuracy statistic. Knee brackets read off such a curve are therefore statements about that statistic, and inherit its noise; Theorem 7.8 shows the inconsistency is confined to the $48\to64$ step and does not touch the bracket used for the headline at $n=512$.

---

## 8. An arithmetic mirror: similarity invariance on Pythagorean triples

Geometric profiles need decay ratios; Pythagorean triples supply an arithmetically rigid family of them, in which "size" has an exact meaning and no noise exists at all.

**Definition 8.1.** A triple $(a,b,c)$ of integers is *Pythagorean* if $a^2+b^2=c^2$. For $c \ne 0$ the *leg ratio* is $\rho(a,c) = a/c \in \mathbb{R}$. The *size* of a triple within its similarity class is the scaling parameter $m$ in $(ma,mb,mc)$.

**Lemma 8.2 (Scale invariance of the ratio).** For $m>0$ and $c>0$, $\rho(ma,mc) = \rho(a,c)$.

*Proof.* $ma/(mc) = a/c$ since $m \ne 0$. $\square$

**Theorem 8.3 (The knee is a similarity invariant).** For $m>0$, $c>0$, every context $n$ and every gate $\tau$,
$$k^*\big(g_{\rho(ma,mc)}, n, \tau\big) \;=\; k^*\big(g_{\rho(a,c)}, n, \tau\big).$$

*Proof.* Immediate from Lemma 8.2. $\square$

This is the same homogeneity as Theorem 3.3, but acting on the *index* of the family rather than on the weights: two group actions, one invariance. Growing a triple by a factor $m$ — the arithmetic analogue of tripling a parameter count — moves the budget by zero keys.

**Theorem 8.4 (Universal short-leg budget at gate $0.98$).** For every Pythagorean triple $(a,b,c)$ with $0<a\le b$ and $c>0$, and every context $n \ge 1$,
$$k^*\big(g_{\rho(a,c)}, n, 0.98\big) \;\le\; 12 .$$

*Proof.* The short leg of a right triangle satisfies $a/c \le 1/\sqrt2$, and in the integer setting $\rho(a,c) \le 0.708$. Then $\rho^{12} \le 0.708^{12} < 0.02 = 1-\tau$, and Lemma 6.1 applies. $\square$

**Theorem 8.5 (Sharpness and an infinite size-invariant family).** The near-isosceles Pell triple $(696,697,985)$ has $k^*(g_{696/985},n,0.98)=12$ exactly for every $n \ge 64$; hence no budget below $12$ serves all triples. Moreover for every $m \ge 1$ the triple $(696m, 697m, 985m)$ is Pythagorean with short-leg knee exactly $12$ at gate $0.98$ and every $n \ge 64$.

*Proof.* Theorem 6.3 with $r=696/985 \approx 0.7066$, $K=12$, $m_{\text{ref}}=64$: $r^{12} < 0.02$ while $(1-r^{11})/(1-r^{64}) < 0.98$. The family statement follows from Theorem 8.3. $\square$

**Theorem 8.6 (Shape, not size).** For every $m>0$ and every $n \ge 64$,
$$k^*\big(g_{\rho(3m,5m)},n,0.98\big) = 8, \qquad k^*\big(g_{\rho(4m,5m)},n,0.98\big) = 18 .$$

*Proof.* $\rho(3m,5m)=3/5$ and $\rho(4m,5m)=4/5$ by Lemma 8.2; apply Example 6.4. $\square$

A single triangle realizes two budgets ten keys apart on its two legs, while every rescaling reproduces the same pair exactly. Size is the direction in which the budget provably does not move; shape is the direction in which it moves a lot.

**Theorem 8.7 (Long-leg divergence, gate-uniform).** For every gate $\tau$ with $5/9 < \tau \le 1$ and every bound $K$, there is a Pythagorean triple $(a,b,c)$ with $0<a\le b$ and a context $n\ge1$ such that
$$k^*\big(g_{\rho(b,c)},n,\tau\big) > K .$$

*Proof sketch.* Use the near-square family $\big(2m+1,\; t,\; t+1\big)$ with $t = 2m^2+2m$, which is Pythagorean for every $m$. Its long-leg ratio is $r = t/(t+1)$, so $r \to 1$: the profile is asymptotically flat. Choosing $m = 10K+10$ and $n = 2K+2$, a Bernoulli-type bound $r^{\,2K+1} \ge 1 - \frac{2K+1}{t+1} \ge 9/10$ shows the retained fraction at budget $n-1$ stays below $\tau$ whenever $\tau > 5/9$, whence $k^* > K$ by Lemma 2.5. $\square$

**Theorem 8.8 (Budget dichotomy at gate $0.98$).** Short legs of Pythagorean triples carry a universal $12$-key budget, valid at every size and every context, while long legs carry no universal budget at all.

*Proof.* Theorems 8.4 and 8.7 (with $0.98 > 5/9$). $\square$

The dichotomy shows the invariance is not an artefact of the parametrisation: within one arithmetic family, one regime of shapes is uniformly cheap and the other is unboundedly expensive, and the size direction is flat *inside each regime*. A two-point size sweep, by construction, cannot distinguish "flat in size" from "flat in everything".

---

## 9. Algorithms

Three computational procedures follow directly from the theory.

**A. Exact knee of a geometric profile via small powers.** Given $r \in (0,1)$, gate $\tau$, context $n$ and reference $m \le n$: find the least $K$ with $r^K \le 1-\tau$; verify $(1-r^{K-1})/(1-r^m) < \tau$; return $K$. Cost: $O(K + m)$ multiplications, independent of $n$. Correctness: Theorem 6.3. This is what makes exact knees at $n = 1024$ or $n = 10^6$ cheap.

**B. Sweep audit.** Given a sweep table $(k_1,v_1),\dots,(k_M,v_M)$ with $k_1<\dots<k_M<n$ and gate $\tau$: (i) report any $i$ with $v_{i+1} \le v_i$ as a *monotonicity violation*, certifying that the measured statistic is not retained mass (Theorem 7.7); (ii) locate the largest failing point $k_i$ ($v_i<\tau$) and the smallest passing point $k_j$ ($v_j \ge \tau$); if a failing point exists below the smallest passing point, report the sound bracket $(k_i,k_j]$; otherwise report the *indeterminate* bracket $[1,k_j]$ and flag that the grid floor is a hole (Theorem 7.2); (iii) for any consecutive pair inside $(0,1)$ and strictly increasing, exhibit a realizing three-block profile (Theorem 7.5). Cost: $O(M)$.

**C. Aggregate budget certification.** Given per-head profiles $W_1,\dots,W_H$, a context $n$ and gate $\tau$: compute each per-head knee by prefix sums, return $K = \max_j k^*(W_j,n,\tau)$ as a certified aggregate budget, and optionally compute the true aggregate knee to measure the slack. Cost: $O(Hn)$; the certificate is valid for any head count (Theorem 4.3).

---

## 10. Discussion

### 10.1 What the flatness means

Four independent mechanisms produce a size-invariant knee, and they are genuinely different:

- **Homogeneity** (Theorem 3.3) is exact, unconditional, and blind: any capacity notion entering through normalisation is invisible.
- **Envelopes** (Theorem 3.7) are quantitative and family-level: one summable tail plus a floor on the lead weight pins one budget for everyone, and by rigidity (Theorem 3.9) this is equivalent to uniform concentration.
- **Aggregation** (Theorem 4.3) is combinatorial and applies to the dominant mode of growth (adding heads), with *no* dependence on head count.
- **Distortion transfer** (Theorem 5.3) is the approximate version, with an explicit and unavoidable $\lambda^2$ price in gate margin.

A measured pair such as $\{16,16\}$ cannot distinguish among these. Distinguishing them requires measuring *shape* — the decay ratio, or equivalently the tail exponent — rather than size.

### 10.2 Deployment reading

The key-value working set is governed by the concentration structure of trained attention, not by capacity. Adding heads cannot raise it (Theorem 4.3); rescaling cannot raise it (Theorem 3.3); a shared tail envelope pins it for a whole family (Theorem 3.7). What can raise it is a change of shape: a flatter profile, one bad head, or distortion large enough that the $\lambda^2$ shift consumes the gate margin. Consequently, at larger model scales the binding memory constraint migrates from the cache to the weights.

### 10.3 Limitations

We are explicit about what is *not* established.

1. **Two size points.** The empirical support is two model sizes and one corpus, with a standard error of roughly $0.3\%$ on the agreement statistic.
2. **Grid floor.** At $n=1024$ nothing was measured below $16$; by Theorem 7.2 the reported knee is an upper bound only.
3. **Per-head spectrum unmeasured.** The measurement most directly implicated by Theorem 4.3 — the per-head knee spectrum — was not recorded.
4. **Metric mismatch.** By Theorem 7.7 the measured agreement ratio is provably not retained mass. All statements linking the measurement to the theory pass through the assumption that the measured statistic is a monotone-in-expectation surrogate for retained mass, which the noise level supports but does not prove.
5. **Arithmetic family is a source of profiles.** The Pythagorean results (§8) supply explicit, exactly computable profiles; they are not a model of a transformer.

---

## 11. Future directions

**1. Exponent rigidity of the sub-knee window.** *Conjecture.* For a positive sorted profile with knee $k^*(n,\tau)=K$ at two contexts $n$ and $2n$, the sub-knee window $\big(k^*(n,\tau'), k^*(n,\tau)\big)$, as $\tau'$ ranges over $[\tau-\varepsilon,\tau]$, has width bounded by a function of the Zipf decay exponent alone, and the width diverges exactly as the exponent crosses $1$. The knee is a finite-sample probe of a convergence property, so the *local sensitivity of the knee to the gate* — not its value — is the observable carrying the exponent. A gate sweep at fixed budget is strictly cheaper than the budget sweep already performed, and converts a knee measurement into an estimate of the tail exponent, hence into a prediction for unmeasured contexts.

**2. Per-head knee spectrum and the worst-head law.** *Conjecture.* The model-level knee equals the maximum of the per-head knees up to a bounded additive defect, the defect controlled by the spread of per-head mass totals: $k^*(\sum_j \text{head}_j) \le \max_j k^*(\text{head}_j)$ always (Theorem 4.3), with equality unless one head carries a vanishing share of the total mass. The pass inequalities add, so aggregation can be limited only by the worst head, while the *mediant* structure of retained mass prevents a large gap unless mass shares are extremely unequal. This is exactly the measurement the round dropped: the per-head statistics are not a nice-to-have but the only mechanistic explanation of a model-level knee.

**3. Distortion radius of a transferred budget.** *Conjecture.* The $\lambda^2$ gate shift of Theorem 5.3 is sharp: for every $\lambda>1$ and every gate $\tau$ with $\lambda^2\tau<1$ there are $\lambda$-comparable profiles whose knees differ by $\Theta\!\big(\log\lambda / \log(1/r)\big)$ keys, and no bound better than $\lambda^2$ holds. Comparability controls head mass multiplicatively at both ends of the ratio defining retained mass, so the loss is exactly the square; the extremal witness should be a geometric profile perturbed on a single block.

**4. Beyond two size points.** A three- or four-point size ladder combined with a gate sweep would separate homogeneity from envelope-sharing empirically: exact invariance predicts an identical *gate-sensitivity curve*, while a shared envelope predicts identical budgets with differing curves.

**5. Oracle-to-policy gap.** All results here concern the *oracle* budget: the knee assumes the top-$k$ keys are known. A deployed eviction policy must choose them online. Quantifying the gap between the oracle knee and the budget attainable by a causal policy is the natural next step for the deployment reading.

---

## 12. Conclusion

The observation that tripling a model's parameter count changed its lossless attention budget by zero keys is not a coincidence of two measurements. It is what four separate structural properties of the knee functional predict. The knee is homogeneous, so it cannot see scale. It is uniform across any family sharing a summable tail envelope with lead weights bounded below, and that uniformity is rigid, equivalent to uniform concentration. It is bounded by the worst per-head knee, uniformly in the head count — so the dominant mode of growth is a direction along which the budget provably does not move. And it transfers across approximately similar profiles at a precise, unavoidable price in gate margin.

Equally, the mathematics constrains the claim. The pre-registered growth law is refutable outright by explicit profiles, but the measured flat chain is *also* only realizable rather than universal. At the longer context the reported budget is an upper bound only, because a single pass at a grid floor is compatible with every knee below it. And both measured sweeps are provably not retained-mass curves, which places the knee brackets where they belong: as statements about a noisy downstream statistic.

The unifying slogan is the one the arithmetic mirror states most cleanly. The lossless attention budget is a *shape* functional and a similarity invariant. Size is precisely the direction in which it does not move.
