# Quota Arithmetic for Seed Ensembles: What a Fourth Run Can Decide About the Low Tail of an Attention-Truncation Knee

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Truncating attention to the top $k$ entries per query converts a quadratic-cost transformer layer into a near-linear one, provided $k$ exceeds the *knee*: the smallest retained budget at which the model still meets a prescribed fraction of its untruncated accuracy. Knees are seed-dependent, so a knee is really a small sample, and every statement about it is a statement about an order statistic of that sample. We study the concrete situation of a $16\times$ configuration ($d = 4$ heads, context $\mathrm{ctx} = 2048$, accuracy bar $0.98$, product point $P = d\cdot\mathrm{ctx}/32 = 256$) in which three training seeds produced knees $\{256, 224, 160\}$, with centre $224 = \tfrac78 P$ and low tail $160 = \tfrac58 P$, and in which a fourth seed was pre-registered with outcome set $\{160, 192, 224, 256\}$ and the announced reading "$\{160,192\}$ establishes the low tail, $\{224,256\}$ marks it seed-specific".

We develop the counting theory needed to adjudicate such a plan and prove that the plan is correct, and correct for a reason stronger than intended. Our contributions are: (i) an exact finite-sample breakdown number $\mathrm{bd}(n,k) = \min\{k, n-k+1\}$ for the $k$-th order statistic of an integer sample, with matching two-sided attacks, yielding a **parity law**: the lower-median breakdown number $\lceil n/2\rceil$ is flat across $(2m-1, 2m)$, so even sample sizes are never design optima; (ii) an exact **verdict breakdown number** for threshold ("quota") verdicts, equal to the observed slack, showing verdict robustness to be data-dependent where centre robustness is design-determined; (iii) a counting characterisation of the one-dimensional Fermat–Weber set, from which the invariance of the centre $224$ under every fourth seed follows; (iv) the **diagnosticity theorem**: both centre summaries are constant across the pre-registered outcome set while the tail verdict is not, so no function of either can reproduce the tail verdict — the fourth seed carries exactly one bit, and that bit concerns the tail alone; (v) an **exclusion theorem**: every fourth-seed outcome confirming the low tail biases the four-seed central reading by at least $P/16$, so confirmation and calibration are mutually exclusive at four seeds, while an explicit five-seed ensemble achieves stable tail, zero bias, and breakdown $3$ simultaneously; and (vi) **design laws** inverting both robustness measures: the least sample size whose median tolerates $r$ corruptions is $2r-1$, and a quota-$m$ tail verdict robust to $r$ corruptions on this data requires at least $m + r + 1$ seeds — five for the next round. The engineering consequence: a confirmed low tail certifies a majority attention speed-up of at least $32/3 \approx 10.7\times$, against the $8\times$ guaranteed for all seeds by the product point.

**Keywords:** attention truncation, knee estimation, order statistics, finite-sample breakdown point, Fermat–Weber point, quota functionals, experiment design, seed ensembles.

---

## 1. Introduction

### 1.1 The measurement

Attention in a transformer costs $O(n^2)$ in the context length $n$. A standard economy is *data-free top-$k$ truncation*: for each query, retain only the $k$ largest attention logits and mask the rest. The retained budget $k$ is a free parameter, and the empirical question is how small it can be made before quality degrades.

Fix a model configuration, a corpus, a held-out split, and an accuracy bar (a fraction of the untruncated accuracy — here $0.98$). The **knee** is then

$$K \ :=\ \min\{k : \text{accuracy at budget } k \ \ge\ 0.98 \times \text{accuracy at budget } \mathrm{ctx}\}.$$

Below the knee the model degrades; above it, compute is wasted. The **speed-up** certified by a budget $k$ against a context $\mathrm{ctx}$ is $\mathrm{ctx}/k$.

For the configuration under study — a causal transformer, model width $64$, $d = 4$ heads, $\mathrm{ctx} = 2048$, word-level corpus, vocabulary $4097$, held-out final $10\%$ — an empirical reference scale had been established across the grid, the **product point**

$$P \ :=\ \frac{d \cdot \mathrm{ctx}}{32} \ =\ \frac{4 \cdot 2048}{32} \ =\ 256,$$

corresponding to an $8\times$ speed-up. Three training seeds produced knees

$$K_1 = 256 = P, \qquad K_2 = 224 = \tfrac78 P, \qquad K_3 = 160 = \tfrac58 P,$$

the last with a thin accuracy margin of $0.001$ above the bar. The sample centre (lower median) is $224 = \tfrac78 P$; the outlier $160 = \tfrac58 P$ we call the **low tail**.

### 1.2 The question and the plan

Is the low tail a stable feature of this configuration or a property of seed 3? The stakes are quantitative: a stable low tail would license a majority budget well under the product point, hence a materially larger speed-up than the all-seeds $8\times$.

The pre-registered plan for a fourth seed was:

> A fourth knee in $\{160, 192\}$ establishes the $0.625P$ low tail as a stable feature of the $16\times$ cell, while a value in $\{224, 256\}$ marks it seed-specific. Strengthening the centre requires a fifth seed, since a fourth improves neither the breakdown number nor the calibration.

This paper proves the plan, sharpens it, and quantifies exactly what it forgoes. The technical thread is that both halves of the plan — the tail claim and the centre claim — are statements about a single primitive, the counting function of the sample, read at different arguments with different quotas.

### 1.3 Overview of results

Section 2 fixes notation and defines the counting function, order statistics, and breakdown numbers. Section 3 develops the exact breakdown theory of order statistics over $\mathbb{Z}$ and extracts the parity law. Section 4 does the same for quota verdicts. Section 5 gives the counting characterisation of the one-dimensional Fermat–Weber set. Section 6 applies all three to the pre-registered experiment: the dichotomy, the one-bit theorem, and the two independence theorems. Section 7 proves the confirmation/calibration exclusion and exhibits the reconciling five-seed ensemble. Section 8 inverts the robustness measures into design laws. Section 9 states the physical payoff. Sections 10–11 discuss scope and future directions.

---

## 2. Setting and basic definitions

Throughout, a **seed ensemble** is a finite family $K : I \to \mathbb{Z}$ of measured knees indexed by a finite nonempty index set $I$ with $n := |I|$ seeds. We work over $\mathbb{Z}$ rather than $\mathbb{N}$ deliberately: adversarial corruption must be unbounded in *both* directions, and over $\mathbb{N}$ downward corruption is artificially capped at $0$, which would inflate every robustness statement below.

**Definition 2.1 (Counting functions).** For $w \in \mathbb{Z}$ set
$$\mathrm{count}_{\le}(K, w) := \#\{i \in I : K_i \le w\}, \qquad \mathrm{count}_{\ge}(K, w) := \#\{i \in I : w \le K_i\}.$$
Both are monotone ($\mathrm{count}_{\le}$ non-decreasing, $\mathrm{count}_{\ge}$ non-increasing) and bounded by $n$.

**Definition 2.2 (Order statistic, counting form).** For $1 \le k \le n$, a value $v \in \mathbb{Z}$ is *the $k$-th order statistic of $K$*, written $\mathrm{OStat}(K,k,v)$, if
$$k \le \mathrm{count}_{\le}(K, v) \qquad\text{and}\qquad \mathrm{count}_{\le}(K, w) < k \ \text{ for every } w < v.$$

**Proposition 2.3 (Existence and uniqueness).** For every $1 \le k \le n$ there is exactly one $v$ with $\mathrm{OStat}(K,k,v)$.

*Proof sketch.* Uniqueness: if $v < v'$ both satisfy the definition, the first clause at $v$ contradicts the second clause at $v'$ applied to $w = v$. Existence: $\mathrm{count}_\le(K, \cdot)$ is a non-decreasing integer-valued step function which is $0$ far to the left and $n \ge k$ far to the right; take the least $v$ at which it reaches $k$, which exists because the function only jumps at sample values. $\square$

This counting definition is preferred to "the $k$-th entry of the sorted list" because all the perturbation arguments below are inequalities between counting functions, and no sortedness hypothesis is ever needed.

**Definition 2.4 (Corruption).** Let $S \subseteq I$. An ensemble $K'$ is an *$S$-corruption* of $K$ if $K_i = K'_i$ for all $i \notin S$. The adversary may set $K'_i$ to arbitrary integers on $S$; $|S|$ is the number of re-run (or falsified) seeds.

**Lemma 2.5 (Perturbation bound).** If $K'$ is an $S$-corruption of $K$ then for every $w$,
$$|\mathrm{count}_{\le}(K, w) - \mathrm{count}_{\le}(K', w)| \le |S|.$$

*Proof sketch.* The two filtered index sets differ only within $S$: each set is contained in the union of the other with $S$, so each cardinality exceeds the other by at most $|S|$. $\square$

Lemma 2.5 is the single inequality from which every robustness statement in this paper follows.

**Definition 2.6 (Breakdown number of an order statistic).** Say the $k$-th order statistic *breaks* under $m$ corruptions if for every bound $B$ there is an $S$-corruption $K'$ with $|S| \le m$ whose $k$-th order statistic exceeds $B$ (breaking *up*), or if for every $B$ there is such a corruption whose $k$-th order statistic falls below $B$ (breaking *down*). The **breakdown number** $\mathrm{bd}(K,k)$ is the least such $m$.

**Definition 2.7 (Tail verdict).** For a bar $\tau \in \mathbb{Z}$ and a quota $m \in \mathbb{N}$, the *tail verdict* is the proposition
$$V(K, \tau, m) \ :\Longleftrightarrow\ m \le \mathrm{count}_{\le}(K, \tau),$$
"at least $m$ of the seeds have knee at or below $\tau$". Its **verdict breakdown number** $\mathrm{vbd}(K,\tau,m)$ is the least $c$ such that some $S$-corruption with $|S| \le c$ flips the truth value of $V$.

**Definition 2.8 ($\ell^1$ centre).** The *cost* of a candidate budget $t$ is $C_K(t) := \sum_{i} |t - K_i|$, and $t$ is an *$\ell^1$ centre* (Fermat–Weber point) of $K$ if $C_K(t) \le C_K(s)$ for all $s \in \mathbb{Z}$.

**Definition 2.9 (Quota budget).** For a natural-number-valued ensemble and quota $m$, the *quota budget* $Q(K,m)$ is the least budget $b$ with $\mathrm{count}_{\le}(K,b) \ge m$: the smallest truncation budget that suffices for at least $m$ of the seeds. $Q(K,n)$ is the *certified* budget (all seeds), $Q(K,\lceil n/2\rceil)$ the *majority* budget.

---

## 3. Exact breakdown theory of order statistics

### 3.1 Stability

**Theorem 3.1 (Range stability).** Let $K'$ be an $S$-corruption of $K$ with $|S| = m$, let $1 \le k \le n$, and suppose $m < k$ and $k + m \le n$. If $\mathrm{OStat}(K', k, v)$ then
$$\min_i K_i \ \le\ v\ \le\ \max_i K_i.$$

*Proof sketch.* For the lower bound, let $w < \min_i K_i$. Then $\mathrm{count}_\le(K, w) = 0$, so by Lemma 2.5 $\mathrm{count}_\le(K', w) \le m < k$, and the second clause of Definition 2.2 forces $v > w$; as this holds for every $w$ below the minimum, $v \ge \min_i K_i$. For the upper bound, take $w = \max_i K_i$: then $\mathrm{count}_\le(K, w) = n$, so $\mathrm{count}_\le(K', w) \ge n - m \ge k$, whence the least value at which $K'$ reaches quota $k$ is at most $w$. $\square$

Thus fewer than $\min\{k,\, n-k+1\}$ corruptions cannot move the $k$-th order statistic outside the honest range.

### 3.2 Attacks

**Theorem 3.2 (Two-sided attacks).** Fix $1 \le k \le n$ and a bound $B$.
1. *(Down.)* If $|S| \ge k$ there is an $S$-corruption whose $k$-th order statistic is $< B$.
2. *(Up.)* If $|S| \ge n - k + 1$ there is an $S$-corruption whose $k$-th order statistic is $> B$.

*Proof sketch.* (1) Set all corrupted coordinates to a common value $c$ far below $\min\{B, \min_i K_i\}$. Then $\mathrm{count}_\le(K', c) \ge k$ already at $c$, so the $k$-th order statistic is at most $c < B$. (2) Set all corrupted coordinates to a common value $c$ far above $\max\{B, \max_i K_i\}$. Now at any $w < c$ the count is at most $n - |S| \le k - 1$, so quota $k$ is not reached below $c$, and the $k$-th order statistic is $c > B$. Both attacks are *oblivious*: they use no knowledge of the honest data. $\square$

### 3.3 The exact breakdown number and the parity law

**Theorem 3.3 (Exact finite-sample breakdown number).** For $1 \le k \le n$,
$$\boxed{\ \mathrm{bd}(K, k) \ =\ \min\{k,\ n - k + 1\}.\ }$$

*Proof sketch.* $\le$: Theorem 3.2 realises breaking at $m = \min\{k, n-k+1\}$ (choosing whichever of the two attacks is feasible at that budget). $\ge$: for $m$ strictly smaller, both $m < k$ and $k + m \le n$ hold, so Theorem 3.1 confines every corrupted estimate to the honest range, and no bound $B$ outside that range can be crossed. $\square$

Note the asymmetry hidden in the formula: for $k$ below the median it is easier to drag the statistic down than up, and vice versa. In the four-seed application this says it is easier to fake an optimistic (small) budget than a pessimistic one — worth remembering when the reported quantity is a cost.

**Corollary 3.4 (Lower median).** For $k = \lceil n/2\rceil = \lfloor (n+1)/2 \rfloor$ the formula collapses to
$$\mathrm{bd}(K, \lceil n/2\rceil) \ =\ \Big\lceil \tfrac{n}{2} \Big\rceil \ =:\ \beta(n),$$
and $\beta(n)$ is the maximum of $\mathrm{bd}(K, \cdot)$ over all $k$: no rung is more robust than the lower median.

**Theorem 3.5 (Parity law).** For every $m \ge 1$,
$$\beta(2m) = \beta(2m-1) = m, \qquad \beta(2m+1) = m+1 > \beta(2m).$$
Consequently, padding an odd-sized ensemble to the next even size buys no robustness at any rung, and robustness increases only at the next odd size.

*Proof sketch.* Immediate from $\beta(n) = \lfloor (n+1)/2\rfloor$. The "at any rung" strengthening uses Theorem 3.3: $\mathrm{bd}(K,k) \le \beta(n)$ for all $k$. $\square$

**Corollary 3.6 (The fourth seed buys no robustness).** For every value $x$ of a pending fourth seed appended to $\{256, 224, 160\}$,
$$\mathrm{bd}(\{256,224,160,x\},\, 2) \;=\; 2 \;=\; \mathrm{bd}(\{256,224,160\},\, 2),$$
and moreover $\mathrm{bd}(\{256,224,160,x\},\, k) \le 2$ for every $1 \le k \le 4$. In particular the certified (quota $4$) budget of a four-seed ensemble has breakdown number $1$: one unlucky seed destroys it.

**Corollary 3.7 (The fifth seed does).** $\mathrm{bd}(\{256,224,160,x,y\},3) = 3 > 2$ for all $x,y$.

Matching these positive statements, the attack of Theorem 3.2 specialises to: two corrupted seeds out of four drive the four-seed median below any prescribed bound, while three are needed to raise it above the honest maximum. Three seeds and four seeds are therefore bracketed identically — robust to one, destroyed by two.

---

## 4. Robustness of a quota verdict

The centre analysis above is about a *location*. The pre-registered experiment reports a *verdict*, and verdicts have their own robustness theory, with a strikingly different character.

**Theorem 4.1 (Verdict stability).** Let $K'$ be an $S$-corruption of $K$.
1. If $|S| + m \le \mathrm{count}_\le(K,\tau)$ then $V(K',\tau,m)$ holds.
2. If $\mathrm{count}_\le(K,\tau) + |S| < m$ then $V(K',\tau,m)$ fails.

*Proof sketch.* Both from Lemma 2.5: the corrupted count differs from the honest one by at most $|S|$, so a verdict with slack exceeding $|S|$ (in either direction) is preserved. $\square$

**Theorem 4.2 (Verdict attacks).** If $V(K,\tau,m)$ holds and $m \ge 1$, there is a corruption of $\mathrm{count}_\le(K,\tau) - m + 1$ seeds under which it fails; if it fails and $m \le n$, there is a corruption of $m - \mathrm{count}_\le(K,\tau)$ seeds under which it holds.

*Proof sketch.* To break a true verdict, move exactly $\mathrm{count}_\le - m + 1$ of the tail seeds to $\tau + 1$; the count drops to $m - 1$. To create a false one, move $m - \mathrm{count}_\le$ above-bar seeds down to $\tau$. Both attacks move seeds across the bar and no further — they are *minimal* in magnitude as well as in cardinality. $\square$

**Theorem 4.3 (Exact verdict breakdown number).**
$$\mathrm{vbd}(K,\tau,m) \;=\; \begin{cases} \mathrm{count}_\le(K,\tau) - m + 1, & \text{if } V(K,\tau,m) \text{ holds } (m \ge 1),\\[2pt] m - \mathrm{count}_\le(K,\tau), & \text{if } V(K,\tau,m) \text{ fails } (m \le n).\end{cases}$$

*Proof sketch.* Upper bounds from Theorem 4.2, lower bounds from Theorem 4.1; the two meet. $\square$

**Remark 4.4 (Design versus data).** Compare Theorem 3.3 with Theorem 4.3. The breakdown number of an order statistic depends only on $(n,k)$ — it is a *design* quantity, known before any measurement. The breakdown number of a verdict is the *observed slack* — a *data-dependent* quantity that must be earned by observations that actually land in the tail. Nothing in a sampling process guarantees slack.

**Corollary 4.5 (The tail bit is fragile at four seeds).** With bar $\tau = 192$, quota $m = 2$, and ensemble $\{256,224,160,x\}$:
* if $x \le 192$, then $\mathrm{count}_\le = 2$ and $\mathrm{vbd} = 2 - 2 + 1 = 1$;
* if $x > 192$, then $\mathrm{count}_\le = 1$ and $\mathrm{vbd} = 2 - 1 = 1$.

Either way the verdict is overturned by re-running a single seed. Combined with Corollary 3.6:

$$\mathrm{vbd}(\{256,224,160,x\},192,2) \;=\; 1 \;<\; 2 \;=\; \mathrm{bd}(\{256,224,160,x\},2).$$

**The bit the experiment can measure is strictly less robust than the bit it cannot.**

**Corollary 4.6 (The fifth seed lifts both).** For the ensemble $\{256,224,160,192,160\}$ one has $\mathrm{count}_\le(\cdot,192) = 3$, hence $\mathrm{vbd} = 2$, while the centre breakdown at quota $3$ is $3$. Both four-seed deficits are cured by one further run.

---

## 5. The centre: a counting characterisation of the Fermat–Weber set

**Lemma 5.1 (Slope estimates).** For $t \le t'$,
$$C_K(t') - C_K(t) \ \ge\ (t' - t)\big(2\,\mathrm{count}_\le(K,t) - n\big),$$
and symmetrically, for $t' \le t$,
$$C_K(t') - C_K(t) \ \ge\ (t - t')\big(2\,\mathrm{count}_\ge(K,t) - n\big).$$

*Proof sketch.* Termwise. For each $i$ with $K_i \le t$ the summand increases by exactly $t' - t$ when moving right; for each $i$ with $K_i > t$ it decreases by at most $t' - t$. Summing gives the first bound; the second is the mirror image. $\square$

**Theorem 5.2 (General $\ell^1$ median theorem).** If $n \le 2\,\mathrm{count}_\le(K,t)$ and $n \le 2\,\mathrm{count}_\ge(K,t)$ then $t$ is an $\ell^1$ centre of $K$.

*Proof sketch.* Both slope coefficients in Lemma 5.1 are non-negative, so moving in either direction cannot decrease the cost. No sortedness hypothesis and no restriction on $n$ is used. $\square$

**Theorem 5.3 (Converse).** If $2\,\mathrm{count}_\le(K,t) < n$, then $t$ is not an $\ell^1$ centre: the least sample value strictly greater than $t$ has strictly smaller cost. Symmetrically if $2\,\mathrm{count}_\ge(K,t) < n$.

*Proof sketch.* Let $t'$ be the least sample value $> t$. No sample point lies strictly between, so on $[t,t']$ the cost is affine with slope $\mathrm{count}_\le(K,t) - \mathrm{count}_>(K,t) = 2\,\mathrm{count}_\le(K,t) - n < 0$; hence $C_K(t') < C_K(t)$. $\square$

**Corollary 5.4 (Characterisation).** $t$ is an $\ell^1$ centre of $K$ if and only if $n \le 2\,\mathrm{count}_\le(K,t)$ and $n \le 2\,\mathrm{count}_\ge(K,t)$: at least half the sample weakly on each side.

**Corollary 5.5 (Centre invariance under the fourth seed).** For every $x \in \mathbb{Z}$, the value $224$ is an $\ell^1$ centre of $\{256, 224, 160, x\}$.

*Proof sketch.* $\mathrm{count}_\le(\cdot,224) \ge 2$ always (from $224$ and $160$) and $\mathrm{count}_\ge(\cdot,224) \ge 2$ always (from $224$ and $256$); with $n = 4$ the two conditions read $4 \le 2\cdot 2$, satisfied. $\square$

**Proposition 5.6 (Non-uniqueness at four, uniqueness at five).** With the low-tail outcome $x = 160$ the four-seed centre is not unique: both $224$ and $160$ minimise the cost (indeed the whole interval between two middle sample values does). For the five-seed ensemble $\{256,224,160,192,224\}$, $224$ is the *unique* $\ell^1$ centre, and $160$ is not a centre at all.

*Proof sketch.* At $n=4$ the counting conditions hold on a whole interval when the two middle order statistics differ. At $n=5$ the conditions read $\mathrm{count}_\le \ge 3$ and $\mathrm{count}_\ge \ge 3$, which for this ensemble pin $t = 224$ exactly. $\square$

**Theorem 5.7 (Unification: centre and tail are two quotas of one counting function).** For any ensemble $K$, bar $\tau$, candidate centre $v$, and quota $m$:
$$V(K,\tau,m) \iff m \le \mathrm{count}_\le(K,\tau),$$
$$v \text{ is an } \ell^1 \text{ centre} \iff \tfrac{n}{2} \le \mathrm{count}_\le(K,v) \ \text{ and } \ \tfrac{n}{2} \le \mathrm{count}_\ge(K,v).$$

Both are quota statements about the same primitive $\mathrm{count}_\le$: the experiment reads it at a *fixed* bar, the centre reads it at a *moving* one. This is the structural reason one additional observation can be informative for one and vacuous for the other.

---

## 6. The pre-registered experiment

### 6.1 The tail bar

**Definition 6.1.** The **tail bar** is the midpoint of the measured low tail and the measured centre:
$$\tau \ :=\ \frac{160 + 224}{2} \ =\ 192, \qquad \text{equivalently } \ 4\tau = 3P, \ \text{ i.e. } \ \tau = \tfrac34 P.$$
(Recall $160 = \tfrac58 P$ and $224 = \tfrac78 P$ with $P = 256$, so $\tau$ is the natural separator on the $P$-scale as well as on the raw scale.)

**Definition 6.2.** For a pending fourth knee $x \in \mathbb{N}$, write $E(x) := \{256, 224, 160, x\}$ and
$$L(x) \ :=\ \mathrm{count}_\le(E(x), \tau) \ =\ \#\{\text{seeds of } E(x) \text{ at or below } \tau\}.$$
The low tail is **stable** if $L(x) \ge 2$, and **replicated** if $x \le 160$.

**Proposition 6.3 (Threshold form of the tail statistic).**
$$L(x) \;=\; \begin{cases}2, & x \le 192,\\ 1, & x > 192,\end{cases} \qquad\text{hence}\qquad \text{stable} \iff x \le 192.$$

*Proof sketch.* Of the recorded knees only $160 \le 192$; add $1$ if and only if $x \le 192$. $\square$

Note that replication implies stability ($160 \le 192$) but not conversely.

### 6.2 The dichotomy and the one-bit theorem

Let $\Pi := \{160, 192, 224, 256\}$ be the pre-registered outcome set.

**Theorem 6.4 (The experiment, as pre-registered).** For every $x \in \Pi$:
$$\text{the low tail is stable} \iff x \in \{160, 192\}.$$

*Proof sketch.* Proposition 6.3 plus the arithmetic $160 \le 192$, $192 \le 192$, $224 > 192$, $256 > 192$. $\square$

**Theorem 6.5 (Exactly one bit).** The verdict is constant on $\{160,192\}$, constant on $\{224,256\}$, and differs across the two pairs. Both verdicts are attainable ($L(160)=L(192)=2$, $L(224)=L(256)=1$), so the experiment is informative — but it cannot distinguish a repeat of the recorded tail value $160$ from the intermediate rung $192$, nor $224$ from $256$.

**Proposition 6.6 (A finer three-way reading).** On $\Pi$: the tail is replicated iff $x = 160$; it is stable but not replicated iff $x = 192$; it is not stable iff $x \in \{224, 256\}$. The two-way pre-registered verdict thus discards one further distinction the data would support.

### 6.3 Diagnosticity: the fourth seed sees the tail and nothing else

Two summaries describe the centre of the four-seed ensemble:

* **(C1)** the proposition "$224$ is an $\ell^1$ centre of $E(x)$";
* **(C2)** the breakdown number $\mathrm{bd}(E(x), 2)$.

**Theorem 6.7 (Both centre summaries are constant on $\Pi$).** (C1) holds for every $x$ (Corollary 5.5), and (C2) equals $2$ for every $x$ (Corollary 3.6).

**Theorem 6.8 (Independence of the tail bit from the centre).** There is no function $f$ of (C1) — of any kind, however constructed — with $f(\text{C1}(x)) = [\text{tail stable at } x]$ for all $x \in \Pi$; and there is no function $g$ with $g(\text{C2}(x)) = [\text{tail stable at } x]$ for all $x \in \Pi$.

*Proof sketch.* Suppose such an $f$ existed. Since C1$(160)$ and C1$(256)$ are the same proposition (both true, hence equal as propositions), $f$ takes the same value at $x = 160$ and $x = 256$. But the tail is stable at $160$ and not at $256$ — contradiction. Identically for $g$, using $\mathrm{bd}(E(160),2) = \mathrm{bd}(E(256),2) = 2$. $\square$

This is the formal content of "diagnostic for the tail, not the centre". It is an impossibility statement, not a power calculation: everything the fourth run contributes to the centre summaries is already determined before the run.

---

## 7. Confirmation versus calibration

The four-seed ensemble also yields a *central reading*: the conventional even-sample median, the midpoint of the two middle order statistics. Write $M(x)$ for that reading and
$$b(x) \ :=\ |M(x) - 224|$$
for its **bias** against the recorded centre.

**Proposition 7.1 (Bias profile).**
$$b(x) \;=\; \begin{cases} 32, & x \le 160,\\[2pt] \tfrac12(224 - x), & 160 \le x \le 224,\\[2pt] \tfrac12(x - 224), & 224 \le x \le 256,\\[2pt] 16, & x \ge 256.\end{cases}$$

*Proof sketch.* Case analysis on where $x$ falls in the sorted recorded knees. E.g. for $160 \le x \le 224$ the sorted sample is $(160, x, 224, 256)$, so $M(x) = (x + 224)/2$ and $b(x) = (224-x)/2$. $\square$

In particular $b$ vanishes only at $x = 224$: the *unique* exactly calibrating outcome.

**Theorem 7.2 (Tail stability costs calibration).** If the fourth seed confirms the low tail ($x \le 192$) then
$$b(x) \ \ge\ 16 \ =\ \frac{P}{16}.$$

*Proof sketch.* For $x \le 160$, $b(x) = 32$. For $160 \le x \le 192$, $b(x) = (224-x)/2 \ge (224-192)/2 = 16$. $\square$

**Corollary 7.3 (Exclusion).** No four-seed outcome both confirms the low tail and calibrates the centre: $b(x) = 0$ and stability cannot hold together.

This is the parity obstruction of Theorem 3.5 in its sharpest, most operational form. An even sample splits its mass into two equal halves; the tail quota and the centre quota pull those halves in opposite directions.

**Theorem 7.4 (The fifth seed reconciles).** The ensemble
$$E_5 \ :=\ \{256,\ 224,\ 160,\ 192,\ 224\}$$
simultaneously satisfies:
1. two seeds at or below the tail bar — the low tail is stable;
2. median rung (quota $3$ of $5$) exactly $224 = \tfrac78 P$ — zero bias, impossible at four seeds by Corollary 7.3;
3. breakdown number $3$ at that rung — impossible at four seeds *at any rung* by Corollary 3.6.

Moreover the variant $E_5' := \{256, 224, 160, 192, 160\}$ attains tail-verdict breakdown $2$ together with centre breakdown $3$ (Corollary 4.6). The choice between $E_5$ and $E_5'$ is precisely the choice between calibrating the centre and hardening the tail verdict; at five seeds each is available, and each dominates every four-seed design on its own objective.

*Proof sketch of (2).* $\mathrm{count}_\le(E_5, 224) = 4 \ge 3$ and $\mathrm{count}_\le(E_5, 223) = 2 < 3$, so the least budget meeting quota $3$ is $224$. $\square$

---

## 8. Design laws: inverting the robustness measures

Both robustness measures are now exact, so both can be inverted: instead of asking how robust a given design is, ask how large a design must be to reach a prescribed robustness. This is what an experiment plan actually needs.

**Theorem 8.1 (Centre design law).** For $r \ge 1$,
$$r \le \beta(n) \iff 2r - 1 \le n,$$
so $2r-1$ is the *least* sample size whose median tolerates $r$ corrupted seeds.

*Proof sketch.* $\beta(n) = \lfloor (n+1)/2\rfloor$; the equivalence is elementary integer arithmetic. $\square$

**Corollary 8.2.** Breakdown $2$ costs three seeds (already achieved); breakdown $3$ costs five. Four seeds are never a design optimum: if four seeds achieve robustness level $r$, three already did.

**Theorem 8.3 (Tail design law).** Let $V(K,\tau,m)$ hold with $m \ge 1$. Then
$$r \le \mathrm{vbd}(K,\tau,m) \iff m + r \le \mathrm{count}_\le(K,\tau) + 1.$$

*Proof sketch.* Substitute Theorem 4.3. $\square$

**Theorem 8.4 (Seeds needed for a robust tail verdict).** Suppose $S$ is a set of seeds recorded strictly above the bar, the verdict $V(K,\tau,m)$ holds, and it tolerates $r$ corruptions. Then
$$n \ \ge\ m + r - 1 + |S|.$$

*Proof sketch.* The tail seeds and $S$ are disjoint populations; the tail population has size at least $m + r - 1$ by Theorem 8.3, and both fit inside the $n$ seeds. $\square$

**Corollary 8.5 (The concrete prediction).** In the $16\times$ cell the two recorded knees $256$ and $224$ sit permanently above $\tau = 192$, so $|S| \ge 2$. Hence a majority tail verdict ($m = 2$) robust to a single re-run ($r = 2$) requires $n \ge 2 + 2 - 1 + 2 = 5$ seeds. No four-seed ensemble containing the recorded knees can support it. Five seeds do: $E_5'$ attains verdict breakdown $2$ and centre breakdown $3$.

**Summary of the design table.**

| Design | Centre breakdown | Tail-verdict breakdown | Zero-bias centre reading attainable? |
|---|---|---|---|
| 3 seeds $\{256,224,160\}$ | $2$ | — (count $1$, quota $2$: verdict false with deficit $1$) | reading is $224$ by definition |
| 4 seeds $\{256,224,160,x\}$ | $2$ (all $x$) | $1$ (all $x$) | only for $x = 224$, which refutes the tail |
| 5 seeds $E_5 = \{\dots,192,224\}$ | $3$ | $1$ | yes, exactly $224$ |
| 5 seeds $E_5' = \{\dots,192,160\}$ | $3$ | $2$ | no (but tail hardened) |

---

## 9. The physical payoff

**Theorem 9.1 (Speed-up gain from a confirmed low tail).** If the fourth seed confirms the low tail ($x \le 192$), then the majority budget (quota $2$ of $4$) of the $16\times$ cell satisfies
$$Q(E(x), 2) \ \le\ \tau \ =\ \tfrac34 P \ =\ 192,$$
and therefore the attention speed-up certified for a majority of seeds is at least
$$\frac{\mathrm{ctx}}{Q(E(x),2)} \ \ge\ \frac{2048}{192} \ =\ \frac{32}{3} \ \approx\ 10.67\times,$$
against the $8\times$ that the product point $P = 256$ guarantees for *all* seeds.

*Proof sketch.* The majority budget is the second smallest knee, which is $\le 192$ exactly when $L(x) \ge 2$; monotonicity of $\mathrm{ctx}/b$ in $b$ finishes. $\square$

Two caveats belong with this number, and both are theorems above rather than hedges. First, the majority guarantee is *not* an all-seeds guarantee: at quota $4$ the certified budget has breakdown number $1$ (Corollary 3.6), so a single unlucky seed invalidates it. Second, the majority verdict underlying the $10.67\times$ figure has verdict breakdown $1$ at four seeds (Corollary 4.5): one re-run would overturn it. A deployment decision that needs slack must buy the fifth seed.

---

## 10. Discussion

### 10.1 What kind of statement this is

Nothing above uses a distributional model for the seed-to-seed variation of the knee. There is no likelihood, no independence assumption, no asymptotics. The reason such assumptions are dispensable is that both objects the experiment reports — a verdict and a centre — are *quota functionals* of a single counting function, and quota functionals admit exact finite-sample analysis. This yields conclusions that survive whatever the true seed distribution is, at the cost of being statements about worst-case corruption rather than about sampling error.

The corruption model deserves a word. "An adversary re-runs $m$ seeds arbitrarily" is a proxy for several practical hazards at once: a seed whose training diverged, a mis-recorded knee, a bar crossed by $0.001$ (as seed 3 was), a corpus shard swapped. Breakdown numbers measure how many such events the conclusion survives, without needing a model of how likely they are.

### 10.2 Why the parity law is the organising fact

The parity law $\beta(2m) = \beta(2m-1)$ explains all three negative results simultaneously:

* the fourth seed does not improve the centre's breakdown number (Corollary 3.6);
* the fourth seed cannot both confirm and calibrate (Corollary 7.3), because the even-sample reading is a midpoint of two middle values that the tail quota and the centre quota move oppositely;
* the least design achieving any robustness level is odd (Theorem 8.1).

It also delimits the negative results: the fourth seed is not useless, it is *tail-only*. One bit for one run is a poor exchange rate for a training cycle, but it is a real bit, and Theorem 6.5 shows it is attainable.

### 10.3 The fragility inversion

Perhaps the least expected consequence is Corollary 4.5. Intuition says the quantity you can measure is the one you can trust. Here the opposite holds: the fourth run's verdict has breakdown $1$, while the centre it cannot influence has breakdown $2$. The mechanism is Remark 4.4 — verdict robustness is *slack*, and slack must be purchased with observations in the tail, whereas centre robustness is fixed by the design. In a plot of (centre robustness, verdict robustness), real experiments accumulate on the line "verdict robustness $=1$" until the tail population is deliberately oversampled.

### 10.4 Practical recipe

For an experimenter facing an analogous cell:

1. Fix the bar before the run, and fix it at the midpoint of the two features you want to separate (here $\tau = \tfrac34 P$, the midpoint of $\tfrac58 P$ and $\tfrac78 P$).
2. Compute, *before running*, whether the planned sample size can change any summary you care about. If a summary is constant across all pre-registered outcomes, the run cannot inform it (Theorem 6.8).
3. Check parity. If your current $n$ is odd, the next run improves no robustness measure of the centre; budget two runs or none (Theorem 8.1).
4. Decide in advance whether you want confirmation or calibration; at even $n$ you cannot have both (Corollary 7.3).
5. Quote verdicts with their slack, not just their truth value (Theorem 4.3).

---

## 11. Future directions

Five conjectures distilled from the programme, each falsifiable by a finite computation or a single further development, each stated so that a counterexample would be recognisable.

**C1. The parity dividend is universal for quota estimators.** For every functional built from the counting function $\mathrm{count}_\le$ — order statistics, trimmed means over an integer grid, quota budgets — the finite-sample breakdown number at sample size $n$ equals its value at $n-1$ whenever $n$ is even. Equivalently: no even-sized seed ensemble is a design optimum for any robustness target. The key insight is that the breakdown number of the $k$-th order statistic is $\min\{k, n-k+1\}$, whose maximum over $k$ is $\lceil n/2\rceil$, and $\lceil n/2\rceil$ is constant across the pair $(2m-1, 2m)$; anything assembled from quotas inherits the plateau. The order-statistic case is settled here; the general case needs only a definition of "quota functional" and the same two counting inequalities. A counterexample would have to be a robust estimator that is not a function of $\mathrm{count}_\le$ — itself a discovery.

**C2. Tail and centre bits are complementary at every even sample size.** For every even $n$ and every tail bar $\tau$ strictly between two adjacent order statistics, an $n$-seed ensemble cannot simultaneously certify a majority tail verdict with slack $\ge 1$ and read the median rung exactly at the recorded centre; the obstruction disappears at $n+1$. The key insight is Theorem 5.7: both objectives are quota statements about the same counting function, one at a fixed bar and one at a moving bar, and an even sample splits its mass into two equal halves that the two quotas pull in opposite directions. The case $n = 4$ is settled here (Corollary 7.3 and Theorem 7.4); the general statement needs the even/odd median bias profile extended from $n=4$ to all even $n$.

**C3. The tail bit is always the fragile bit.** In any seed ensemble whose tail count equals its quota, the verdict breakdown number is $1$ while the centre breakdown number is $\lceil n/2\rceil$; consequently, in the (centre robustness, tail-verdict robustness) plane, real experiments accumulate on the line "tail $=1$" until the tail population is deliberately oversampled. The key insight is Remark 4.4: verdict breakdown is a data-dependent slack while centre breakdown is a design quantity; slack must be bought with runs that land in the tail, and nothing in the sampling process guarantees them.

**C4. Bar placement is optimal at the midpoint.** Among all bars separating two adjacent recorded features, the midpoint maximises the minimum, over pre-registered outcomes, of the verdict slack — i.e. the midpoint bar is the minimax-robust separator. A counterexample would be an asymmetric outcome ladder on which an off-centre bar strictly dominates.

**C5. The grid-wide product law survives tail correction.** If the low tail is confirmed in several cells of the configuration grid, the corrected majority budgets should again be an integer multiple of a single product point, with the multiplier $\tfrac34$ rather than $1$ — that is, the tail is a rescaling of the product law rather than a breakdown of it. This is checkable as soon as two cells have five seeds each.

---

## 12. Conclusion

A single extra training run was proposed to settle whether an unusually cheap seed was a real feature of an attention-truncation configuration. The counting analysis of that proposal yields an unusually complete answer. The run can settle the question, in the exact sense that the tail verdict is a threshold functional of the new knee and both pre-registered verdicts are attainable. It cannot do anything else: both summaries of the centre are constant across the pre-registered outcomes, so no function of them reproduces the verdict, and the fourth seed improves neither the location nor the robustness of the centre. It cannot even do the one thing it does robustly: the verdict it produces has breakdown number $1$ either way. And it cannot confirm the tail without biasing the central reading by at least $P/16$ — confirmation and calibration are exclusive at four seeds, and jointly attainable at five.

The payoff of a confirmed tail is a majority attention speed-up of at least $32/3 \approx 10.7\times$ against the $8\times$ guaranteed for all seeds — worth having, and now with an exact statement of what it costs and what it does not buy. Beneath the specifics lies a simple organising principle: the centre and the tail are two quotas of one counting function, the experiment reads it at a fixed bar and the centre at a moving one, and the arithmetic of $\lceil n/2 \rceil$ decides in advance which questions a given number of runs can answer.
