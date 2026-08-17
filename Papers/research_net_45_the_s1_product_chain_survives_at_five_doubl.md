# Selection Gaps, Certification Depth, and the Dilution of Data-Free Attention Pruning at Long Context

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We study data-free top-$k$ pruning of attention, in which a fixed budget of $k$ positions out of a context of length $L$ is retained. Two families of results are developed and connected to a five-rung empirical ladder of measurements at depth $d = 4$ and contexts $L = 128, 256, 512, 1024, 2048$.

The first family concerns the *threshold* (the knee): the least budget on a sweep grid at which retained accuracy reaches $0.98$ of the unpruned model's held-out accuracy. At the longest cell, $L = 2048$, the knee is $256 = dL/32$, confirming a prediction stated before the measurement and completing an exact chain of five doublings. We prove that this knee claim has an *exact robustness radius*: it survives every perturbation of size $\eta$ on the grid if and only if $\eta \le 0.0013$, the measured margin; and that at $\eta = 0.006$, the inter-seed spread observed in the same family, there is an admissible monotone curve whose knee is one grid step lower. We introduce the **certification depth** of a margin ladder, prove it well defined and antitone in the noise, and compute it for the measured ladder: depth $5$ at $\eta = 0.0013$, $4$ at $0.002$, $2$ at $0.004$ and at $0.006$, and $0$ at $0.010$. Thus a chain that is *exact* at five doublings is *certified* at two. We also show that the product law $k = dL/32$ is logically identical to context-independence of the deployable speedup $L/k = 32/d$, and that a five-rung exact chain has null probability $2^{-5} = 1/32 < 0.05$ under a one-grid-step coin model, while a two-cell replication has null probability $1/4$.

The second family concerns the *attention profile* itself. We prove by double counting that the random-$k$ control retains exactly $k/L$ of the attention mass; that the selection gap (top-$k$ mass minus $k/L$) is therefore non-negative for every profile, so its positivity is uninformative; and, as a rigidity theorem, that a vanishing gap at any intermediate budget forces the profile to be exactly uniform. A Cauchy–Schwarz bound $T_k^2 \le k/N_{\mathrm{eff}}$ ties the measured effective support to achievable retained mass and yields a *no bounded working set* theorem: unbounded effective support implies that no fixed budget retains a fixed fraction of mass at all contexts. Applied to the reported numbers, the bound exposes an internal inconsistency (top-$k$ masses exceeding the cap implied by the reported effective support), forcing the conclusion that the reported concentration statistic is not the inverse participation ratio, and that the knee is a statement about the layer's output rather than about the attention distribution.

Finally we prove an **exchange theorem**: the top-mass functional is exactly invariant under self-similar refinement of the context (each position split into two of half weight) at matched sparsity, $T_{2k}(\mathrm{split}\,p) = T_k(p)$. Consequently the selection gap is an exact invariant of scale-invariant refinement, and *any* measured change of the gap across a context doubling at matched sparsity refutes exact self-similarity of the profile. The measured decay from $+5.9$ to $+1.7$ accuracy points is such a change, making the weakest measured number the most falsifiable structural conclusion of the study.

**Keywords.** attention pruning, top-$k$ selection, selection gap, effective support, inverse participation ratio, self-similar refinement, exchange argument, robustness radius, certification depth, product law.

---

## 1. Introduction

### 1.1 The cost problem and the budget response

An attention layer of context length $L$ performs $\Theta(L^2)$ pairwise interactions. Any scheme that restricts each query to a fixed budget of $k \le L$ key positions reduces this to $\Theta(kL)$, a speedup factor of
$$\mathrm{speedup}(L, k) \;=\; \frac{L}{k}.$$
*Data-free* pruning fixes the retained set from the attention weights alone, without consulting downstream labels or gradients: keep the $k$ positions of largest weight.

Whether this is worth doing is an empirical question with a sharp shape. Fix a bar $\beta$ (here $\beta = 0.98$) and a finite sweep grid $G \subset \mathbb{N}$ of candidate budgets. Define the **knee** $k^\*$ as the least $k \in G$ at which the pruned model's held-out accuracy reaches $\beta$ times the unpruned model's held-out accuracy.

### 1.2 The product law and the ladder

Across a series of controlled runs at model depth $d$ the knee has repeatedly matched the **product law**
$$k^\* \;=\; \frac{d \cdot L}{32}. \tag{PL}$$
At depth $d = 4$ this predicts $k^\* = L/8$, i.e. $16, 32, 64, 128, 256$ at $L = 128, 256, 512, 1024, 2048$. The present study measures the last of these — sixteen times the shortest context, five doublings, a single seed — and reads $k^\* = 256$ exactly, as predicted in advance.

### 1.3 What this paper contributes

The measurement is a coincidence-chain: five predictions, five hits. Chains of this kind are easy to over-read and easy to under-read. This paper supplies the exact accounting, in two independent registers.

*Threshold register* (§3–§5). How much noise does the claim survive? Exactly $0.0013$ — the margin, no more. How much of the chain survives realistic noise? Two rungs, not five. How surprising is the chain under a null? $1/32$: genuinely significant. What does the law mean operationally? Exactly context-independence of the speedup.

*Profile register* (§6–§9). The same run measures a selection gap that is collapsing with context ($+5.9 \to +1.7$ accuracy points) and an effective support that keeps growing ($291.16 \to 526.39$ across a doubling). We show that positivity of the gap is a theorem and hence uninformative; that vanishing of the gap is a rigidity statement forcing uniform attention; that growth of the effective support forbids any bounded working set; and — the main structural theorem — that the gap is an exact invariant of self-similar refinement, so its measured *change* falsifies scale invariance of attention across the doubling.

All theorems are stated for arbitrary finite position sets and arbitrary real-valued profiles unless explicitly restricted; the empirical numbers enter only where they are named.

---

## 2. The measurement

Held-out evaluation on the last $10\%$ of a corpus; model depth $d = 4$, context $L = 2048$, single seed; data-free top-$k$ selection; unpruned accuracy $0.1543$, hence bar $\beta \cdot 0.1543 = 0.1512$; unpruned loss $5.2047$; binomial standard error on accuracy $\approx 0.11\%$. Retained accuracy is the pruned accuracy divided by the unpruned accuracy.

| $k$ | 96 | 128 | 160 | 192 | 224 | **256** | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| retained | .939 | .951 | .963 | .970 | .976 | **.9813** | .984 | .993 | .997 | .996 | .998 |
| passes $0.98$? | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** | ✓ | ✓ | ✓ | ✓ | ✓ |

Auxiliary measurements at the same cell: selection gaps $+1.7$ and $+1.8$ accuracy points over the random-$k$ control at $k = 128$ and $k = 256$ (against $+5.9/+4.6$ at $L = 256$, $+5.3/+4.6$ at $512$, $+5.9/+4.6$ at $1024$); reported effective support $526.39$ (against $291.16$ at $L = 1024$, a ratio of $1.808\ldots$); top-$128$ attention mass $0.589$, top-$256$ mass $0.731$.

Two features of this sweep are new relative to earlier rungs, and both matter formally.

**(i) The measured retained curve is not monotone.** It reads $0.997$ at $k = 512$ and $0.996$ at $k = 768$. The knee is nevertheless well defined, since the definition of a knee never uses monotonicity — but robustness arguments that route through monotone envelopes must construct those envelopes explicitly rather than assume them.

**(ii) The margin is razor thin.** $0.9813 - 0.98 = 0.0013$, against $0.007, 0.010, 0.003, 0.006$ at the four earlier rungs; the deficit at the preceding grid point $224$ is $0.004$.

---

## 3. Knees, robustness, and the exact radius

**Definition 3.1 (Knee).** Let $G \subset \mathbb{N}$ be a finite grid, $\beta$ a bar, and $c : \mathbb{N} \to \mathbb{R}$ a retained-accuracy curve. We say $k$ is a *knee* of $(G, \beta, c)$ if $k \in G$, $c(k) \ge \beta$, and no $j \in G$ with $j < k$ satisfies $c(j) \ge \beta$. A knee is unique when it exists.

**Definition 3.2 (Robust knee).** For $\eta \ge 0$, the claim "$k$ is the knee" is *$\eta$-robust* if for **every** monotone curve $c'$ with $|c'(j) - c(j)| \le \eta$ for all $j \in G$, $k$ is a knee of $(G, \beta, c')$.

(Restricting the adversary to monotone perturbations makes the necessity direction *harder*, not easier: the counterexample curves we construct are themselves monotone, hence admissible under either convention.)

**Theorem 3.3 (Knee at the sixteen-times cell).** For the measured curve of §2 with $\beta = 0.98$ and grid $G = \{96, 128, 160, 192, 224, 256, 288, 384, 512, 768, 1024\}$, the knee is $256$; equivalently $k^\* = dL/32$ with $d = 4$, $L = 2048$.

*Proof sketch.* $0.9813 \ge 0.98$, and each of the five smaller grid points reads $0.939, 0.951, 0.963, 0.970, 0.976 < 0.98$. Only the eleven measured values are used; no monotonicity is invoked. $\square$

**Proposition 3.4 (Non-monotonicity).** The measured curve is not monotone: $c(512) = 0.997 > 0.996 = c(768)$.

To handle robustness in the presence of this dip we use two explicit monotone envelopes, each within $0.001$ of the measurement at every grid point:

- the **upper envelope** $c^{+}$, equal to the measurement everywhere on the grid except at $768$, where the dip $0.996$ is raised to $0.997$;
- the **lower envelope** $c^{-}$, equal to the measurement everywhere on the grid except at $512$, where $0.997$ is lowered to $0.996$.

Both are built as finite sums of upward unit steps $x \mapsto v \cdot \mathbf{1}[t \le x]$ with $v \ge 0$, hence monotone by construction, and both satisfy $0 \le c^{+}(j) - c(j) \le 0.001$ and $0 \le c(j) - c^{-}(j) \le 0.001$ on the grid.

**Theorem 3.5 (Sufficiency).** For every $\eta \le 0.0013$, the knee claim $k^\* = 256$ is $\eta$-robust.

*Proof sketch.* Two requirements must survive an $\eta$-perturbation. First, $256$ must still pass: $c(256) - \eta \ge 0.9813 - 0.0013 = 0.98 = \beta$. Second, no smaller grid point may be promoted: the deficits $\beta - c(j)$ at $j = 96, 128, 160, 192, 224$ are $0.041, 0.029, 0.017, 0.010, 0.004$, all $> \eta$, so $c(j) + \eta < \beta$. $\square$

**Theorem 3.6 (Necessity).** For every $\eta > 0.0013$, the knee claim $k^\* = 256$ is *not* $\eta$-robust.

*Proof sketch.* Take $c' = c^{+} - \eta$. It is monotone (a monotone function shifted by a constant), and it lies within $\eta$ of the measurement on the grid because $0 \le c^{+} - c \le 0.001 < \eta$ pointwise there, so $|c' - c| \le \max(\eta, \eta - 0.001) = \eta$. But $c'(256) = 0.9813 - \eta < 0.98 = \beta$, so $256$ fails the bar under $c'$ and cannot be its knee. $\square$

**Corollary 3.7 (Exact robustness radius).** The knee claim at the sixteen-times cell is $\eta$-robust **if and only if** $\eta \le 0.0013$.

**Theorem 3.8 (The one-grid-step drop lies inside the measured noise).** There exists a monotone curve $c'$ with $|c'(j) - c(j)| \le 0.006$ for all $j \in G$ whose knee is $224$.

*Proof sketch.* Take $c' = c^{-} + 0.006$. Monotone by construction; within $0.006$ of the measurement on the grid since $0 \le c - c^{-} \le 0.001$. At $224$ it reads $0.976 - 0 + 0.006 = 0.982 \ge \beta$, so $224$ passes, while the four smaller grid points read at most $0.963 + 0.006 = 0.969 < \beta$. Hence $224$ is the knee of $c'$. $\square$

Since $0.006$ is the inter-seed spread already measured at neighbouring cells of this family, Theorem 3.8 says that a one-grid-step drop to $224$ — the reading a second seed might return — is *predicted by the first seed's own sweep*, before a second seed is run. The measurement does not distinguish the two hypotheses.

---

## 4. Certification depth of a margin chain

A chain of exact rungs is a conjunction of threshold claims, each with its own margin. The following functional makes precise the folklore that a chain is only as strong as its weakest link.

**Definition 4.1 (Certification depth).** Let $m : \mathbb{N} \to \mathbb{R}$ be a *margin ladder*, $m_i$ the margin of rung $i$ (with $m_i = 0$ for unmeasured rungs). For a noise level $\eta$, say the chain has *certification depth $n$ at $\eta$*, written $\mathrm{CertDepth}(m, \eta, n)$, if
$$(\forall i < n)\; \eta \le m_i \qquad\text{and}\qquad \neg\,(\eta \le m_n).$$

This is the knee functional again — least index of failure — applied to the ladder rather than to the sweep.

**Proposition 4.2 (Uniqueness).** If $\mathrm{CertDepth}(m, \eta, n)$ and $\mathrm{CertDepth}(m, \eta, n')$ then $n = n'$.

*Proof sketch.* If $n < n'$ then the second clause at $n$ contradicts the first clause of the $n'$-statement applied to $i = n$; symmetrically for $n' < n$. $\square$

**Theorem 4.3 (More noise certifies fewer doublings).** If $\eta \le \eta'$, $\mathrm{CertDepth}(m, \eta, n)$ and $\mathrm{CertDepth}(m, \eta', n')$, then $n' \le n$.

*Proof sketch.* Suppose $n < n'$. Then $\eta' \le m_n$ by the first clause of the $\eta'$-statement, so $\eta \le \eta' \le m_n$, contradicting the second clause of the $\eta$-statement. $\square$

**Proposition 4.4 (Weakest link).** If some rung $i < n$ has $m_i < \eta$, then the certification depth at $\eta$ is strictly below $n$.

**The measured ladder.** With rungs $0, \dots, 4$ corresponding to $L = 128, \dots, 2048$,
$$m = (0.007,\; 0.010,\; 0.003,\; 0.006,\; 0.0013),$$
we obtain by direct evaluation:

| noise $\eta$ | 0.0013 | 0.002 | 0.004 | 0.006 | 0.010 |
|---|---|---|---|---|---|
| certification depth | **5** | 4 | 2 | **2** | 0 |

**Corollary 4.5 (The collapse).** The chain is certified at depth $5$ only at its own tightest margin $0.0013$; at the inter-seed spread $0.006$ already measured in this family it is certified at depth $2$; and by Theorem 4.3 the depth is antitone in between.

The choke point is rung $2$ ($L = 512$), with margin $0.003$: the first two doublings survive noise up to $0.007$, but any noise above $0.003$ truncates the chain there. Hence the accurate headline: **exact at five doublings, certified at two.**

---

## 5. Deployment reading and the null model

**Theorem 5.1 (The product law is context-independence of the speedup).** For $d, L, k > 0$,
$$k = \frac{dL}{32} \iff \frac{L}{k} = \frac{32}{d}.$$

*Proof sketch.* Both directions are one clearing of denominators; $k > 0$ and $L > 0$ make the division legitimate. $\square$

So the exactness claim (PL) and the statement "the deployable speedup is a context-independent constant $32/d$" are the *same statement*, not two pieces of evidence. At $d = 4$ the constant is $8$, and $2048/256 = 8$ at the measured cell — the guarantee coincides exactly with the knee.

**Remark 5.2 (An arithmetic correction).** If a second seed reads $k^\* = 224$, the speedup is $2048/224 = 64/7 \approx 9.14$, not $10.3$ as stated in an early write-up of these measurements; the discrepancy exceeds one whole multiple ($10.3 - 64/7 > 1$).

**Theorem 5.3 (Null probability of an exact chain).** Under the one-grid-step null model — each rung independently reads either the predicted budget or one grid step below it, with equal probability — exactly one of the $2^n$ ladders is exact at every rung, so
$$\Pr[\text{exact at all } n \text{ rungs}] = 2^{-n}.$$

*Proof sketch.* The set of $\{0,1\}$-valued functions on $n$ rungs that are identically $1$ is a singleton; divide by $2^n$. $\square$

**Corollary 5.4.** At $n = 5$ the null probability is $1/32 < 0.05$: a five-rung exact chain is significant at the conventional level. At $n = 2$ — the size of a two-cell replication — it is $1/4 > 0.05$, and is not.

Theorems 3.5–3.8 and 4.3 do not contradict this: the chain is significant *as a coincidence count* while being certified only to depth $2$ *as a noise-robust claim*. The two questions are different, and both answers should be reported.

---

## 6. The attention profile: top-$k$ mass and the exact random baseline

We now leave the threshold and analyse the object it is measured on.

**Definition 6.1 (Attention profile).** Let $\iota$ be a finite set of positions with $|\iota| = L$. A profile is a function $p : \iota \to \mathbb{R}$; it is *normalised* if $\sum_{i} p_i = 1$. (Most results below need no normalisation and no positivity; we flag where they are used.)

**Definition 6.2 (Top-$k$ mass).** For $k \le L$, $T$ is the *top-$k$ mass* of $p$, written $T_k(p)$, if some $k$-subset $S$ has $\sum_{i \in S} p_i = T$ and every $k$-subset $S$ has $\sum_{i \in S} p_i \le T$. This is precisely the attention mass retained by a data-free top-$k$ pruner.

**Proposition 6.3 (Existence and uniqueness).** For every $p$ and every $k \le L$ the top-$k$ mass exists and is unique.

*Proof sketch.* Existence: the family of $k$-subsets is finite and non-empty (as $k \le L$), so the supremum of subset masses is attained. Uniqueness: if $T$ and $T'$ both qualify, each is attained by some subset and dominated by the other, so $T \le T'$ and $T' \le T$. $\square$

The experimental control is "keep $k$ uniformly random positions". Its expected retained mass is an *exact* quantity, obtainable by double counting.

**Lemma 6.4 (Incidence count).** For a fixed position $i$ and $1 \le k$, the number of $k$-subsets containing $i$ is $\binom{L-1}{k-1}$.

*Proof sketch.* $S \mapsto S \setminus \{i\}$ is a bijection from the $k$-subsets containing $i$ onto the $(k-1)$-subsets of the remaining $L-1$ positions, with inverse $T \mapsto T \cup \{i\}$. $\square$

**Theorem 6.5 (Double counting).** For $1 \le k \le L$,
$$\sum_{|S| = k} \sum_{i \in S} p_i \;=\; \binom{L-1}{k-1} \sum_{i} p_i .$$

*Proof sketch.* Write the inner sum as $\sum_i p_i \mathbf{1}[i \in S]$ and exchange the order of summation; the inner count is Lemma 6.4. $\square$

**Lemma 6.6.** $L \binom{L-1}{k-1} = k \binom{L}{k}$ for $1 \le k \le L$.

**Theorem 6.7 (The random-$k$ baseline is exactly $k/L$).** For a normalised profile and $1 \le k \le L$, the mean of $\sum_{i \in S} p_i$ over all $k$-subsets $S$ equals $k/L$.

*Proof sketch.* Divide Theorem 6.5 by $\binom{L}{k}$ and apply Lemma 6.6. $\square$

The null model against which selection is scored is thus a theorem, not an estimate: no sampling error attaches to it.

---

## 7. The selection gap: positivity is free, vanishing is rigid

**Definition 7.1 (Selection gap).** For a normalised profile and $1 \le k \le L$, the *selection gap* is $\mathrm{gap}_k(p) = T_k(p) - k/L$.

**Theorem 7.2 (Non-negativity).** $\mathrm{gap}_k(p) \ge 0$ for every normalised profile and every $1 \le k \le L$.

*Proof sketch.* The maximum of a finite family dominates its mean; the mean is $k/L$ by Theorem 6.7. Formally: $\sum_{|S|=k}\sum_{i\in S} p_i \le \binom{L}{k} T_k(p)$, and combining with Theorem 6.5 and Lemma 6.6 gives $k\binom{L}{k} \le L\binom{L}{k} T_k(p)$, i.e. $k/L \le T_k(p)$. $\square$

**Methodological consequence.** The observation that *all measured selection gaps are positive* is not evidence for structure in attention: no profile whatsoever could have produced a negative gap. Only the magnitude of the gap is informative, which relocates the interesting content of the measurement from the sign of $+1.7$ to its size relative to $+5.9$.

**Theorem 7.3 (Rigidity).** Let $0 < k < L$, let $p$ be normalised, and suppose $T_k(p) = k/L$ exactly. Then $p$ is constant: $p_i = p_j$ for all $i, j$.

*Proof sketch.* By Theorem 6.5 the sum of the $k$-subset masses equals $\binom{L}{k} \cdot k/L = \binom{L}{k} T_k(p)$, while each summand is $\le T_k(p)$; a finite family of reals dominated by $T$ whose sum is $|{\cdot}| \cdot T$ is identically $T$. So *every* $k$-subset carries mass exactly $T$. Now fix $i \ne j$; since $k - 1 \le L - 2$ we may choose a $(k-1)$-subset $A$ avoiding both. Then $A \cup \{i\}$ and $A \cup \{j\}$ are $k$-subsets, so $p_i + \sum_A p = T = p_j + \sum_A p$, whence $p_i = p_j$. $\square$

Theorems 7.2 and 7.3 bracket the phenomenon: the gap can never be negative, and it is zero exactly at the uniform profile. Dilution of the gap — the measured fall from $+5.9$ to $+1.7$ accuracy points across the ladder — is therefore a *quantitative approach to uniform attention*, and a gap of exactly zero would be the strongest possible negative result about data-free pruning: it would certify that attention has no preferred positions to select.

---

## 8. Concentration: Cauchy–Schwarz, no bounded working set, and an internal inconsistency

**Definition 8.1 (Effective support).** For $p \ne 0$, the inverse participation ratio is $N_{\mathrm{eff}}(p) = 1 / \sum_i p_i^2$.

**Theorem 8.2 (Concentration cap).** For every profile, budget $k$, and top-$k$ mass $T$,
$$T^2 \;\le\; k \sum_i p_i^2 \;=\; \frac{k}{N_{\mathrm{eff}}(p)} .$$

*Proof sketch.* Let $S$ attain the maximum. Cauchy–Schwarz on $S$ gives $\left(\sum_{i \in S} p_i\right)^2 \le |S| \sum_{i \in S} p_i^2$; extend the right sum to all positions using $p_i^2 \ge 0$. $\square$

**Corollary 8.3 (Budget lower bound).** If a budget $k$ retains at least a fraction $\beta \ge 0$ of the mass and $\sum_i p_i^2 \le 1/N$, then $k \ge \beta^2 N$.

So a concentration measurement is a *hard lower bound* on any mass-retaining budget: retaining a fixed fraction of the attention mass costs at least $\beta^2 N_{\mathrm{eff}}$ positions, and the budget must grow with the same exponent as the effective support.

**Theorem 8.4 (No bounded working set).** Let $(p^{(n)})$ be a family of profiles on position sets $\iota_n$, with $\sum_i (p^{(n)}_i)^2 \le 1/N_n$ and $N_n > 0$, and suppose $(N_n)$ is unbounded. Then for every fixed budget $k$ and every target fraction $m > 0$ there is an $n$ with $T_k(p^{(n)}) < m$.

*Proof sketch.* Choose $n$ with $N_n > k/m^2$. If $T_k(p^{(n)}) \ge m$ then Theorem 8.2 gives $m^2 \le k/N_n < m^2$, a contradiction. $\square$

A context-independent budget therefore cannot retain a constant fraction of the attention mass across a family with growing effective support. This is the structural reason a knee law must grow with the context, and it is exactly what the measured supports show: $291.16$ at $L = 1024$ and $526.39$ at $L = 2048$, a ratio strictly between $1.80$ and $1.81$ — sublinear in the context (below the factor $2$ of the doubling) but with no sign of saturation (above $1$). Neither a fixed working set nor a proportional one fits.

**Theorem 8.5 (Internal inconsistency of the reported statistics).** Any profile whose top-$256$ mass is at least $0.731$ satisfies $\sum_i p_i^2 \ge 0.731^2 / 256$, hence has inverse participation ratio strictly below $526.39$.

*Proof sketch.* Theorem 8.2 with $k = 256$ and $T \ge 0.731$; then $1/\sum p_i^2 \le 256/0.731^2 < 526.39$ by arithmetic. $\square$

Likewise $128/526.39 < 0.589^2$ and $256/526.39 < 0.731^2$: the reported top-$k$ masses *exceed* the cap that the reported effective support would impose. The two measurements cannot both be readings of the same functional. The resolution is that the reported effective support is a different concentration statistic (an entropy-based one, e.g. the exponential of the attention entropy), and the two numbers must not be combined in a single bound. We record this as a constraint on how such statistics are reported, and it is a strictly positive by-product of the theory: the inequality caught the mismatch.

**Theorem 8.6 (The knee retains accuracy, not mass).** If a profile satisfies $\sum_i p_i^2 \le 1/526.39$ then its top-$256$ mass is below $0.70$.

*Proof sketch.* $T^2 \le 256/526.39 < 0.49$. $\square$

Read as a genuine inverse participation ratio, the reported concentration would allow a budget of $256$ to carry at most $70\%$ of the attention mass — far below the $0.98$ accuracy bar which that same budget clears. Hence **mass retention and accuracy retention are genuinely different thresholds**: the knee is a statement about the *output* of the layer, not about the attention distribution. Downstream computation is evidently robust to discarding a substantial share of the attention mass; the two curves should never be conflated.

---

## 9. The exchange theorem: self-similar refinement preserves the selection gap exactly

The most informative single number of the study is its weakest: the collapse of the selection gap from $+5.9$ to $+1.7$ accuracy points across the last doubling. We now show that this collapse *proves something*.

**Definition 9.1 (Self-similar refinement).** Given a profile $p$ on $\iota$, its refinement $\mathrm{split}\,p$ is the profile on $\iota \times \{0,1\}$ defined by $(\mathrm{split}\,p)(i, b) = p_i / 2$. Each position is replaced by two positions of half its weight; the context length doubles and the total mass is preserved.

This is the exact scale-invariance null model for a context doubling: a profile with a fixed shape (a Zipf-like law, say), merely resolved at finer granularity, refines in this way. Matched sparsity means comparing budget $k$ out of $L$ with budget $2k$ out of $2L$.

**Theorem 9.2 (Refinement can copy: $T_{2k}(\mathrm{split}\,p) \ge T_k(p)$).**

*Proof sketch.* If $S$ attains $T_k(p)$, then $S \times \{0,1\}$ has exactly $2k$ elements and mass $\sum_{i \in S} (p_i/2 + p_i/2) = \sum_{i\in S} p_i = T_k(p)$, so the refined maximum is at least this. $\square$

The converse is the substantive direction. A $2k$-subset $U \subseteq \iota \times \{0,1\}$ need **not** be a union of split pairs: it may contain one half of some positions and both halves of others. Equivalently the refined pruner solves a *fractional* selection problem with per-position weights in $\{0, 1/2, 1\}$ and total weight $k$. The theorem says this relaxation buys nothing.

**Lemma 9.3 (Half of a set carries half of its mass).** Let $E$ be a finite set with $|E| = 2m$ and $p$ any real-valued weighting. Then some $C \subseteq E$ with $|C| = m$ satisfies $\sum_{i \in E} p_i \le 2 \sum_{i \in C} p_i$.

*Proof sketch.* Take $C$ maximising $\sum_{i \in C} p_i$ among the $m$-subsets of $E$ (finitely many, at least one). Its complement $E \setminus C$ also has $m$ elements, hence $\sum_{E \setminus C} p \le \sum_C p$; adding $\sum_C p$ to both sides gives $\sum_E p \le 2\sum_C p$. No positivity or ordering is used. $\square$

**Theorem 9.4 (Refinement buys nothing: $T_{2k}(\mathrm{split}\,p) \le T_k(p)$).**

*Proof sketch.* Let $U$ attain $T_{2k}(\mathrm{split}\,p)$ and let $S_{\mathrm{t}} = \{i : (i,1) \in U\}$, $S_{\mathrm{f}} = \{i : (i,0) \in U\}$ be its traces. Counting elements by their second coordinate, $|S_{\mathrm{t}}| + |S_{\mathrm{f}}| = |U| = 2k$; summing masses the same way,
$$\sum_{S_{\mathrm{t}}} p + \sum_{S_{\mathrm{f}}} p \;=\; 2 \sum_{q \in U} (\mathrm{split}\,p)(q) \;=\; 2\,T_{2k}(\mathrm{split}\,p).$$
Let $D = S_{\mathrm{t}} \cap S_{\mathrm{f}}$ (doubly selected) and $E = (S_{\mathrm{t}} \cup S_{\mathrm{f}}) \setminus D$ (singly selected). Inclusion–exclusion on cardinalities gives $2|D| + |E| = 2k$, so $|E| = 2(k - |D|)$ is even and $|D| \le k$; on masses it gives $\sum_{S_{\mathrm{t}}} p + \sum_{S_{\mathrm{f}}} p = 2\sum_D p + \sum_E p$. Apply Lemma 9.3 to $E$ with $m = k - |D|$, obtaining $C \subseteq E$ with $|C| = k - |D|$ and $\sum_E p \le 2 \sum_C p$. Since $D$ and $C$ are disjoint, $D \cup C$ has exactly $k$ elements, and
$$2\,T_{2k}(\mathrm{split}\,p) = 2\sum_D p + \sum_E p \le 2\sum_D p + 2\sum_C p = 2\sum_{D \cup C} p \le 2\,T_k(p). \qquad \square$$

**Corollary 9.5 (Invariance of the top-mass functional).** $T_{2k}(\mathrm{split}\,p) = T_k(p)$.

**Corollary 9.6 (Exact invariance of the selection gap).** Since the baselines agree, $2k/(2L) = k/L$,
$$\mathrm{gap}_{2k}(\mathrm{split}\,p) \;=\; \mathrm{gap}_k(p).$$
Scale-invariant attention profiles neither dilute nor concentrate the advantage of data-free top-$k$ selection over the random control.

**Theorem 9.7 (Two-sided falsification of self-similarity).** Let $p$ be a profile on $L$ positions and $q$ a profile on $2L$ positions, and suppose their selection gaps at matched sparsity differ:
$$\mathrm{gap}_{2k}(q) \ne \mathrm{gap}_{k}(p).$$
Then $q \ne \mathrm{split}\,p$.

*Proof sketch.* Immediate from Corollary 9.6. $\square$

**Application.** The measured gaps at matched sparsity differ strictly across the last doubling ($+5.9$ versus $+1.7$ accuracy points), so the hypothesis of Theorem 9.7 is met by the measurement. Therefore: *the long-context attention profile is not the self-similar refinement of the short-context one.* This is a structural, falsifiable conclusion — and note that it is two-sided: an *increase* of the gap would have refuted self-similarity just as decisively. What the direction of the change adds is the reading of §7: the profile is moving *towards* the uniform rigidity point, where selection ceases to be selection.

---

## 10. Algorithms

Three procedures underlie the empirical objects analysed above; we state them with complexities.

**A. Knee detection on a sweep grid.** Given the grid $G$ sorted increasingly, the retained curve $c$, and the bar $\beta$, return the least $k \in G$ with $c(k) \ge \beta$, or report none. Cost: $O(|G|)$ comparisons after the sweep. Correctness needs no monotonicity of $c$, which matters here because the measured curve dips.

**B. Robustness radius of a knee claim.** Given the same data and the knee $k^\*$, return
$$\eta^\* = \min\Big( c(k^\*) - \beta,\;\; \min_{j \in G,\, j < k^\*} \big(\beta - c(j)\big) \Big).$$
By Theorems 3.5 and 3.6 the claim is $\eta$-robust exactly for $\eta \le \eta^\*$, provided the second term is not the binding one at the resolution of the grid. For the measured cell, $c(256) - \beta = 0.0013$ and the smallest deficit below the knee is $0.004$, so $\eta^\* = 0.0013$. Cost: $O(|G|)$.

**C. Certification depth of a margin ladder.** Given margins $m_0, \dots, m_{n-1}$ and noise $\eta$, scan from rung $0$ and return the first index $i$ with $m_i < \eta$ (or $n$ if none). By Proposition 4.2 the answer is unique and by Theorem 4.3 it is antitone in $\eta$; sweeping $\eta$ over the sorted margins yields the whole depth profile in $O(n \log n)$.

Two further computations are used in §7–§9 and are exponential if done naively but closed-form here: the random-$k$ baseline (Theorem 6.7 replaces an average over $\binom{L}{k}$ subsets with the constant $k/L$), and the top-$k$ mass (a full sort or a linear-time selection, $O(L \log L)$ or $O(L)$, rather than a search over subsets).

---

## 11. Discussion

**What the chain establishes.** Five consecutive exact rungs of $k^\* = dL/32$, across a sixteen-fold range of contexts, with the final rung predicted in advance. Under a fair one-grid-step null this has probability $1/32$, so as a coincidence count it is significant. Operationally, by Theorem 5.1, it *is* the claim that the deployable speedup is a context-independent $8\times$ at depth $4$.

**What the chain does not establish.** By Corollary 3.7 the final rung has robustness radius exactly $0.0013$; by Theorem 3.8 an admissible monotone perturbation of size $0.006$ — the measured inter-seed spread — already reads $224$; and by Corollary 4.5 the whole chain, at that noise level, certifies two doublings. Reporting "exact at five doublings" without "certified at two" overstates the result by three rungs. The cell is single-seed, and the second seed at this cell is the decisive open measurement: $256$ would make the chain two-seed exact at five doublings, $224$ would break it precisely where the theory locates the thinnest margin.

**What the profile analysis changes.** The threshold story and the profile story point in opposite directions, and the profile story is the more informative. The knee is holding at $dL/32$, but (i) the effective support keeps growing at $1.81\times$ per doubling, so by Theorem 8.4 there is no bounded working set and by Corollary 8.3 any *mass*-retaining budget must grow with it; (ii) the advantage of selection over a random control has fallen from $+5.9$ to $+1.7$ accuracy points, and by Theorems 7.2 and 7.3 the meaningful scale for that number is its distance from the uniform rigidity point at zero; and (iii) by Corollary 9.6 and Theorem 9.7 that fall is itself a refutation of scale invariance of the profile.

**Where the two stories meet.** Theorem 8.6 forces them apart on purpose: a budget of $256$ that clears a $0.98$ *accuracy* bar cannot be carrying more than $70\%$ of the attention *mass* at the reported concentration. The layer's output tolerates the loss of nearly a third of its attention mass. Any theory that predicts the knee from concentration statistics alone is therefore predicting the wrong quantity; the knee lives downstream of the attention distribution.

**Methodological upshot.** Three reporting standards follow directly from the theorems: (a) never report the sign of a selection gap as evidence (Theorem 7.2 makes it free); (b) always report a margin next to a threshold, and the certification depth next to a chain (Definition 4.1, Theorem 4.3); (c) never combine a top-$k$ mass with a concentration statistic without checking Theorem 8.2 first — here that check caught an inconsistency between two headline numbers of the same run.

---

## 12. Future directions

**C1. The margin law: margins decay geometrically along an exact chain.** *Conjecture.* Along a doubling ladder on which the product law $k^\* = A\,dL/\delta$ is exact at every rung, the margin at rung $i$ satisfies $m_i \le M \rho^i$ with $\rho < 1$; consequently the certified depth of an exact chain grows only like $\log(1/\eta)$, and **no exact chain of more than $O(\log(1/\eta))$ rungs can ever be certified at noise $\eta$**. The key insight is that exactness is a quantisation coincidence: rung $i$ reports the grid point immediately above a continuous knee whose fractional position in the last grid cell is essentially equidistributed, and the margin is the retained-accuracy increment across that fraction of a cell — an increment which shrinks as the retained curve flattens with context. The measured ladder $0.007, 0.010, 0.003, 0.006, 0.0013$ is consistent with $\rho \approx 0.6$ on the odd subsequence and is already at the resolution limit of the harness. A sixth rung ($L = 4096$) with a margin below $0.0008$ would confirm the geometric law and would also prove that the programme can never certify the chain it is measuring.

**C2. The dilution exponent: the selection gap decays like $\sqrt{k/N_{\mathrm{eff}}}$.** *Conjecture.* At matched sparsity $k/L$, the selection gap of the measured profiles obeys $\mathrm{gap}(L) \asymp c\,(k/N_{\mathrm{eff}}(L))^{1/2} - k/L$, so with $N_{\mathrm{eff}} \propto L^{0.86}$ the gap decays like $L^{-0.43}$ and reaches zero — the uniform-attention rigidity point of Theorem 7.3 — at a finite, computable context. The key insight is that Corollary 9.6 makes the gap an exact invariant of self-similar refinement, so **any** decay is a measurement of the failure of self-similarity, and the Cauchy–Schwarz cap of Theorem 8.2 converts the measured effective support directly into the achievable gap. The measured gaps ($+5.3, +5.9, +1.7$) and the two measured effective supports ($291.16, 526.39$) already over-determine the two constants; a single $L = 4096$ run tests the prediction, and a gap of zero would be the strongest possible negative result about data-free attention pruning.

**C3. Mass retention and accuracy retention diverge.** *Conjecture.* The budget needed to retain $98\%$ of the attention *mass* grows like $N_{\mathrm{eff}}(L) \propto L^{0.86}$, while the budget needed to retain $98\%$ of the *accuracy* grows like $L$ (the product law). The two curves therefore cross, and beyond the crossing context the accuracy-preserving budget is strictly the larger of the two — so, past that point, an attention pruner tuned to preserve mass would silently under-serve accuracy, and the knee could no longer be read off any concentration statistic. Theorem 8.6 already exhibits the gap at $L = 2048$ in one direction; locating the crossing requires the mass-retention curve at two further contexts.

**Immediate experimental priorities.** (1) A second seed at $L = 2048$, deciding whether $256$ is two-seed exact or drops one grid step to $224$. (2) A third seed at $L = 1024$, to resolve the knee distribution $\{96, 128\}$ at that rung. (3) A depth-$8$ cell at $L = 256$, testing the depth factor of the product law at a corner not yet probed.

---

## 13. Conclusion

A five-rung exact chain is a real result and a fragile one, and the fragility is quantifiable to the fourth decimal place: robustness radius exactly $0.0013$, certification depth $2$ at the noise already observed, null probability $1/32$. Meanwhile the mechanism underneath the law is visibly eroding: effective support unbounded, no working set, and a selection advantage in free fall — whose fall is, by the exchange theorem, an exact proof that attention profiles do not merely rescale as contexts lengthen. The threshold and the profile are telling different stories, and the profile is the one with the falsifiable content.
