# Coarse-Response Ceilings for Rank Correlation Against a Geometric Tie Spectrum

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Let $T$ be a statistic whose tie profile on a sample of size $n$ is geometric with ratio $1/q$ — the canonical example being the trailing-zero count (the $q$-adic valuation) of a uniformly drawn integer. We develop a complete theory of the attainable Spearman rank correlation between such a $T$ and an arbitrary downstream response, resolved by the response's own granularity.

Four results organise the theory. First, a **coarse-response ceiling**: a two-valued response marking $K$ of $n$ items satisfies $\rho^2 \le nK(n-K)/(4\,\mathrm{SSB})$, where $\mathrm{SSB}$ is the between-block sum of squares of the midranks of $T$, with equality exactly when the marked set is a top segment of the $T$-order. On the dyadic profile this specialises to the **rate parabola** $\rho^2_{\max}(p) = \tfrac72 p(1-p)\,n^3/(n^3-1)$. Second, a **nested-ties identity**: for any response constant on groups of consecutive tie blocks, $\rho^2 = \mathrm{SSB}(\text{coarse})/\mathrm{SSB}(\text{fine})$ exactly — the squared correlation is the surviving fraction of between-block variance. This single identity subsumes both the classical $6/7$ tie-attenuation ceiling and the rate parabola. Third, a **bulk/tip asymmetry**: merging the bottom $1-2^{-t}$ of the $T$-scale caps $\rho^2$ at $(\tfrac72(2^t-1)2^t 8^{b-t} + 8^{b-t}-1)/(8^b-1)$, which is $\to 197/512 \approx 0.3848$ at $t=3$, whereas merging the *entire top* $2^{-t}$ leaves $\rho^2 = (8^b - 8^{b-t})/(8^b-1) > 7/8$ for every $t$. Fourth, a **shape-constant theorem**: for the ratio-$1/q$ spectrum, $\mathrm{SSB} = q(n^3-1)/(4(q^2+q+1))$ and the ceiling constant is $C(q) = q+1+1/q$, strictly increasing; the dyadic case $C(2) = 7/2$ is therefore the smallest, making the binary regime the most restrictive member of the family.

The theory is calibrated against a concrete measurement: rank correlations of $0.7192$, $0.7202$, $0.7198$ between the trailing-zero count and a downstream relation rate on uniform draws of exact bit-length $48$, at a mean relation rate of $12.5\%$. The ceilings exclude a two-valued response at that rate (cap $0.6187$), exclude every response blind inside the $87.5\%$ no-relation bulk (cap $\rho^2 = 0.3848$ against a measured $\rho^2 \approx 0.5172$), locate the blindness threshold sharply between depths $t = 2$ and $t = 3$, and permit total blindness on the top half of the scale. A uniform bound $|\rho^2_{\max}(p,b) - \tfrac72 p(1-p)| \le 2\cdot 8^{-b}$ explains, algebraically, the observed flatness of the measurement across bit-length scans.

**Keywords:** Spearman rank correlation, tie profile, $2$-adic valuation, midranks, between-group sum of squares, geometric tie spectrum, resolution ladder, coarse response.

---

## 1. Introduction

### 1.1 The measurement

Draw integers uniformly at random with exact bit-length $48$. For each draw record $T$, the number of trailing zero bits — equivalently, the $2$-adic valuation. Feed the draw into a downstream process which either produces a certain structural relation or does not; over the ensemble it produces one with mean rate $12.5\%$.

Across three independent seeds the Spearman rank correlation between $T$ and the relation rate is
$$\rho = 0.7192,\quad 0.7202,\quad 0.7198,$$
a spread of $0.001$, and $T$ outperforms a popcount ("number of $1$ bits") baseline by $+0.098$ to $+0.145$ throughout. The correlation is stable, strong, and unexplained.

### 1.2 The question this paper answers

The correlation is a single scalar; the mechanism producing the relation rate is unknown. What can one scalar establish about an unknown mechanism?

The answer turns out to be: a great deal, provided one exploits the **tie structure** of $T$. Because $T$ takes few values on a large sample, its ranked version is a step function with only $b+1$ levels, and its rank variance is a computable, highly structured quantity. Any response's correlation with $T$ is bounded by how much of that structure the response can resolve. Constraining the resolution of the response is thus equivalent to constraining the correlation — and this works in both directions.

Existing theory covers only the *refining* case. If the response ranks strictly more finely than $T$ (it sees everything $T$ sees, plus more), the classical tie-attenuation ceiling applies:
$$\rho^2 \;\le\; \frac{\mathrm{SSB}}{(n^3-n)/12} \;=\; \frac{6}{7}\Bigl(1 + \frac{1}{n(n+1)}\Bigr) \;\longrightarrow\; \frac67 ,$$
giving $\rho \le 0.9258$. The recorded $0.7192$ is well inside this, so the refining theory says nothing.

But a *rate* is not a refinement. A relation rate of $12.5\%$ is, in the simplest reading, a single indicator variable — the coarsest non-trivial object there is. This paper supplies the theory of coarse responses, then the theory of everything in between.

### 1.3 Contributions

1. **§3 — The coarse-response ceiling.** An exact, attained bound for two-valued responses, proved by a greedy-optimality argument requiring only two monotonicity inequalities and a counting identity (no rearrangement machinery). Specialised to the dyadic tie profile it yields the rate parabola $\tfrac72 p(1-p)\,n^3/(n^3-1)$.
2. **§4 — The nested-ties identity and the resolution ladder.** $\rho^2 = \mathrm{SSB}(\text{coarse})/\mathrm{SSB}(\text{fine})$ exactly, for every response constant on consecutive tie blocks; plus monotonicity of coarsening, which orders the entire ladder and caps it at $1$.
3. **§5 — Bottom-blindness exclusion and the resolution threshold.** Exact ceilings at every dyadic depth; a two-sided threshold at the recorded measurement.
4. **§6 — Tip-blindness admissibility and the bulk/tip asymmetry.** The tip merge costs exactly the tip's own sum of squares (no interaction term); the resulting ceiling exceeds $7/8$ at every depth.
5. **§7 — Bit-length invariance.** A uniform $2\cdot 8^{-b}$ bound turning empirical scan-flatness into an algebraic fact.
6. **§8 — The geometric-ratio family.** $\mathrm{SSB} = q(n^3-1)/(4(q^2+q+1))$; the ceiling constant $C(q) = q+1+1/q$ is strictly increasing; the dyadic regime is the hardest member, so every exclusion above is the strongest available in the family. In particular $7/2$ is a shape constant, not an arithmetic one.

---

## 2. Setup: tie profiles, midranks, and the between-block sum of squares

### 2.1 Tie profiles

**Definition 2.1 (Tie profile).** Let $T$ be a statistic on a sample of size $n$ taking finitely many values. Its **tie profile** is the list $L = [m_0, m_1, \ldots, m_r]$ of block sizes, indexed in increasing order of the $T$-value, so $\sum_j m_j = n$. Block $j$ occupies rank positions $C_j+1, \ldots, C_j + m_j$, where $C_j = m_0 + \cdots + m_{j-1}$ is the prefix sum.

**Definition 2.2 (Midrank).** The midrank of block $j$ is
$$r_j \;=\; C_j + \frac{m_j+1}{2},$$
the average rank position occupied by that block. The grand mean rank is $\mu = (n+1)/2$.

**Definition 2.3 (Dyadic profile).** For a sample consisting of all residues in $\{0, 1, \ldots, 2^b - 1\}$, the trailing-zero count $T$ has the profile
$$D_b \;=\; \bigl[\,2^{b-1},\; 2^{b-2},\; \ldots,\; 2,\; 1,\; 1\,\bigr],$$
with $b+1$ entries: $2^{b-1-j}$ integers have exactly $j$ trailing zeros for $j = 0, \ldots, b-1$, and the final singleton is $\{0\}$. Note $\sum D_b = 2^b$. Uniform draws of exact bit-length $48$ have their low $47$ bits uniform, so the relevant profile is $D_{47}$ with $n = 2^{47}$.

Throughout, "bottom" means low $T$ (the large blocks: half the sample is odd) and "tip" means high $T$ (the singletons).

### 2.2 Centred rank mass and the between-block sum of squares

**Definition 2.4 (Centred rank mass).** For a profile $L$ starting at rank offset $c$,
$$\mathrm{mass}_\mu(L, c) \;=\; \sum_j m_j\bigl(r_j - \mu\bigr).$$

**Lemma 2.5 (Closed form).** $\mathrm{mass}_\mu(L,c) = n\bigl(c + \tfrac{n+1}{2} - \mu\bigr)$, where $n = \sum L$. Consequently $\mathrm{mass}_\mu(L, 0) = 0$ when $\mu = (n+1)/2$.

*Proof sketch.* Induction on $L$. The midrank mass of a block equals the raw rank mass of its members, because the midrank is their arithmetic mean; summing telescopes to the rank mass of the whole segment. $\square$

**Definition 2.6 (Between-block sum of squares).** 
$$\mathrm{SSB}_\mu(L, c) \;=\; \sum_j m_j\bigl(r_j - \mu\bigr)^2 .$$
We abbreviate $\mathrm{SSB}(L) := \mathrm{SSB}_{(n+1)/2}(L, 0)$. This is precisely the variance of the midrank vector of $T$ (unnormalised), i.e. $\sum_i (R_i - \mu)^2$ where $R_i$ is observation $i$'s midrank.

Two structural facts are used repeatedly.

**Lemma 2.7 (Parallel-axis algebra).** $\mathrm{SSB}_\mu(L,c)$ depends on $(\mu, c)$ only through $\mu - c$, and is the quadratic
$$\mathrm{SSB}_\mu(L,c) \;=\; \mathrm{SSB}_0(L,c) \;-\; 2\mu\,\mathrm{mass}_0(L,c) \;+\; \mu^2 n .$$

**Lemma 2.8 (Additivity along concatenation).** $\mathrm{SSB}_\mu(L_1 \mathbin{+\!\!+} L_2, c) = \mathrm{SSB}_\mu(L_1, c) + \mathrm{SSB}_\mu(L_2, c + \textstyle\sum L_1)$.

Both are immediate inductions.

### 2.3 The dyadic sum of squares

**Theorem 2.9 (Dyadic sum of squares).** For $b \ge 1$ and $n = 2^b$,
$$\mathrm{SSB}(D_b) \;=\; \frac{n^3 - 1}{14}.$$

*Proof sketch.* Induction on $b$ using Lemmas 2.7–2.8. Writing $D_{b+1} = 2^{b} :: D_b$, the new leading block of size $2^{b}$ shifts the offset of the remainder by $2^{b}$ and moves the grand mean from $(2^{b}+1)/2$ to $(2^{b+1}+1)/2$; the parallel-axis cross term of the new block cancels against the recentring of the old ones, so level $k$ contributes exactly $8^{k}/2$. Summing the geometric series, $\tfrac12\sum_{k<b} 8^{k} = \tfrac12\cdot\frac{8^{b}-1}{7} = \frac{n^3-1}{14}$. $\square$

Compare with the tie-free total $\mathrm{SSB}_{\text{tot}}(n) = (n^3-n)/12$. Their ratio,
$$\frac{\mathrm{SSB}(D_b)}{\mathrm{SSB}_{\text{tot}}(n)} \;=\; \frac{12(n^3-1)}{14(n^3-n)} \;=\; \frac67\Bigl(1 + \frac{1}{n(n+1)}\Bigr),$$
is the classical tie-attenuation ceiling: $\rho \le \sqrt{6/7} = 0.9258\ldots$ for any response refining $T$.

---

## 3. Coarse responses: the binary ceiling and the rate parabola

### 3.1 Selections

**Definition 3.1 (Selection).** A **selection** on a profile $L = [m_0, \ldots, m_r]$ is a list $s = [s_0, \ldots, s_r]$ with $0 \le s_j \le m_j$. It encodes a binary response marking $s_j$ of the $m_j$ members of block $j$. *Which* members are marked is immaterial: midranks are constant on blocks. Write $K = \sum s_j$ for the marked count.

**Definition 3.2 (Selection mass).** $\mathrm{sel}_\mu(L, s, c) = \sum_j s_j (r_j - \mu)$.

Selection mass is additive along concatenations of aligned profile/selection pairs, and a selection plus its pointwise complement carries the full mass: $\mathrm{sel}_\mu(L, s, c) + \mathrm{sel}_\mu(L, m - s, c) = \mathrm{mass}_\mu(L, c)$.

### 3.2 Moments of a binary response

Let $n_1 = K$, $n_0 = n - K$. The response, ranked, has two levels: the marked items share midrank $n_0 + (n_1+1)/2$, the unmarked share $(n_0+1)/2$.

**Lemma 3.3 (Variance).** The centred sum of squares of the binary response's midranks is
$$\mathrm{Var} \;=\; \frac{n\,K\,(n-K)}{4}.$$

**Theorem 3.4 (Cross moment).** For any selection $s$ on $L$,
$$\mathrm{Cov} \;=\; \sum_i (R_i - \mu)(S_i - \mu) \;=\; \frac n2\,\mathrm{sel}_\mu(L,s,0).$$

*Proof sketch.* The response's two centred midranks are $n_0/2$ (marked) and $-n_1/2$ (unmarked), since $n_0 + \tfrac{n_1+1}{2} - \tfrac{n+1}{2} = \tfrac{n_0}{2}$ and $\tfrac{n_0+1}{2} - \tfrac{n+1}{2} = -\tfrac{n_1}{2}$. Writing $M = \mathrm{sel}_\mu(L,s,0)$ for the centred rank mass of the marked items, the unmarked items carry mass $-M$ because the total centred mass vanishes (Lemma 2.5). Hence $\mathrm{Cov} = \tfrac{n_0}{2}M + \bigl(-\tfrac{n_1}{2}\bigr)(-M) = \tfrac{n_0+n_1}{2}M = \tfrac n2 M$. $\square$

So the covariance depends on the response **only through its centred rank mass**, a *linear* functional of the selection, while the variance depends only on the *count*. This is the entire reason a greedy argument suffices.

### 3.3 Greedy optimality

**Theorem 3.5 (Top-filling is optimal).** Split $L = L_1 \mathbin{+\!\!+} L_2$ at a block boundary, and let $s = s_1 \mathbin{+\!\!+} s_2$ be any selection with total count $K' = \sum L_2$ (the marked count matching the boundary). Then
$$\mathrm{sel}_\mu(L, s, 0) \;\le\; \mathrm{mass}_\mu(L_2, \textstyle\sum L_1),$$
i.e. no selection of that count carries more centred mass than the one that marks precisely the top segment $L_2$.

*Proof sketch.* Let $W = \sum L_1$ be the boundary rank. Every block of $L_1$ finishes at or before $W$, so its centred midrank is at most $W - \mu$; hence $\mathrm{sel}(L_1, s_1) \le (\sum s_1)(W-\mu)$. Every block of $L_2$ starts at or after $W$, so its centred midrank is at least $W-\mu$; hence the *unselected* part of $L_2$ carries at least $(\sum L_2 - \sum s_2)(W-\mu)$. Since $\sum s_1 = \sum L_2 - \sum s_2$ by the count constraint, the excess mass placed below the boundary is dominated by the mass abandoned above it, and the inequality follows by adding the two bounds. $\square$

### 3.4 The coarse-response ceiling

**Definition 3.6.** $\displaystyle \rho^2_{\mathrm{bin}}(L,s) = \frac{\mathrm{Cov}^2}{\mathrm{SSB}(L)\cdot \mathrm{Var}}$ is the squared Spearman coefficient between $T$ (profile $L$) and the binary response $s$.

**Theorem 3.7 (Coarse-response ceiling).** Let $L = L_1 \mathbin{+\!\!+} L_2$ with $K = \sum L_1 > 0$ and $n - K = \sum L_2 > 0$, let $s$ be any selection of count $n-K$ with $\mathrm{Cov} \ge 0$, and suppose $\mathrm{SSB}(L) > 0$. Then
$$\rho^2_{\mathrm{bin}}(L,s) \;\le\; \frac{n\,K\,(n-K)}{4\,\mathrm{SSB}(L)} .$$

*Proof sketch.* By Theorem 3.4, $\mathrm{Cov} = \tfrac n2\,\mathrm{sel}$; by Theorem 3.5, $\mathrm{sel} \le \mathrm{mass}_\mu(L_2, K)$, which by Lemma 2.5 equals $(n-K)\bigl(K + \tfrac{n-K+1}{2} - \tfrac{n+1}{2}\bigr) = K(n-K)/2$. Hence $\mathrm{Cov} \le nK(n-K)/4$. Squaring (legitimate as $\mathrm{Cov} \ge 0$) and dividing by $\mathrm{SSB}\cdot\mathrm{Var}$ with $\mathrm{Var} = nK(n-K)/4$ gives the claim. $\square$

**Theorem 3.8 (Sharpness).** The top-filling response — marking exactly the blocks of $L_2$, i.e. $s = [0,\ldots,0] \mathbin{+\!\!+} L_2$ — attains the bound with equality.

Two structural remarks. (i) The bound has $\mathrm{SSB}$ in the *denominator*: it is **antitone** in the between-block variance of $T$. This is the reverse of the refining ceiling, in which $\mathrm{SSB}$ appears in the numerator. (ii) The bound is a product of a count factor and a variance factor, so it factorises cleanly into a rate parabola.

### 3.5 The rate parabola

**Theorem 3.9 (Rate parabola).** On the dyadic profile $D_b$ with $n = 2^b$, the coarse ceiling at the aligned dyadic rate $p = 2^{-t}$ ($0 \le t \le b$) is
$$\rho^2_{\max}(p) \;=\; \frac72\, p\,(1-p)\,\frac{n^3}{n^3-1}.$$

*Proof sketch.* The prefix sums of $D_b$ are the dyadic boundaries: $\sum(\text{first } t \text{ blocks}) = 2^b - 2^{b-t}$ and $\sum(\text{remaining}) = 2^{b-t}$. Substituting $K = n - pn$, $n - K = pn$ and $\mathrm{SSB} = (n^3-1)/14$ from Theorem 2.9 into Theorem 3.7:
$$\frac{n\cdot (1-p)n\cdot pn}{4(n^3-1)/14} = \frac{14\,p(1-p)n^3}{4(n^3-1)} = \frac72 p(1-p)\frac{n^3}{n^3-1}. \qquad\square$$

The dyadic rates are exactly the rates at which a *block boundary* exists, which is why the ceiling is attained there.

### 3.6 Consequences for the measurement

**Corollary 3.10 (Value at the recorded rate).** At $b = 47$, $p = 1/8$,
$$\rho^2_{\max} \;=\; \frac{49}{128}\Bigl(1 + \frac{1}{2^{141}-1}\Bigr) \;=\; 0.3828125\ldots, \qquad \rho_{\max} = \frac{7}{8\sqrt2} = 0.618718\ldots$$

**Theorem 3.11 (No binary response at the recorded rate).** Every two-valued response at exact bit-length $48$ whose marked count matches the recorded $12.5\%$ boundary satisfies $\rho^2 < 0.3829$, strictly below $0.7192^2 = 0.5172$, $0.7202^2$, and $0.7198^2$. In particular the relation rate cannot be a single-trial indicator; it must be a graded response.

**Theorem 3.12 (A binary model needs double the rate).** For every dyadic rate $2^{-t}$ with $t \ge 3$ the coarse ceiling is below $0.39 < 0.5172$; at rate $1/4$ the ceiling is $21/32 = 0.65625 > 0.5172$. Hence a two-valued response reproducing the measurement requires a relation rate of at least $25\%$ — double the recorded $12.5\%$.

**Theorem 3.13 (The $6/7$ ceiling is not universal).** For every $b \ge 3$, the balanced coarse ceiling exceeds the refining ceiling:
$$\frac67\Bigl(1+\frac{1}{n(n+1)}\Bigr) \;<\; \frac78\cdot\frac{n^3}{n^3-1}.$$
Coarsening the response can therefore *raise* the attainable dial: it shrinks the response's own variance faster than it shrinks the covariance. Numerically, $6/7 = 0.857143$ versus $7/8 = 0.875$.

**Theorem 3.14 (Headroom inversion reverses).** Let $B_b$ denote the popcount tie profile on $b$ bits (block sizes $\binom{b}{k}$). At $b = 47$ the popcount statistic has strictly *more* refining headroom than $T$: $\mathrm{SSB}(D_{47}) < \mathrm{SSB}(B_{47})$, so its refining ceiling is higher. Because the coarse ceiling is antitone in $\mathrm{SSB}$, at every aligned split $0 < K < n$,
$$\frac{nK(n-K)}{4\,\mathrm{SSB}(B_{47})} \;<\; \frac{nK(n-K)}{4\,\mathrm{SSB}(D_{47})},$$
i.e. the count baseline's coarse ceiling is strictly below $T$'s. The recorded advantage of $T$ over the count baseline ($+0.098$ to $+0.145$) is in the direction the coarse theory predicts and *against* the direction the refining theory suggests.

---

## 4. The resolution ladder: responses that are partly coarse

Theorem 3.11 leaves an objection open. A relation rate need not be two-valued; it may be flat across the $87.5\%$ of draws where no relation occurs while resolving the remaining $12.5\%$ arbitrarily finely. Such a response has many levels and is not covered by §3.

### 4.1 Nestings

**Definition 4.1 (Nesting / coarsening).** A **nesting** is a list of lists $\mathcal{L} = [G_1, \ldots, G_k]$ whose concatenation $\mathrm{flat}(\mathcal L)$ is the fine profile $L$ of $T$. It represents a response that is constant on each group $G_i$ of consecutive tie blocks — it may merge adjacent $T$-levels but never splits or reorders them. Its own tie profile is the **coarse profile** $\mathrm{coarse}(\mathcal L) = [\sum G_1, \ldots, \sum G_k]$.

### 4.2 The nested-ties identity

**Theorem 4.2 (Midrank collapse).** The centred cross moment between the fine midranks of $T$ and the coarse midranks of the response equals the coarse between-group sum of squares:
$$\mathrm{Cov} \;=\; \sum_i \bigl(c + \tfrac{\sum G_i + 1}{2} - \mu\bigr)\,\mathrm{mass}_\mu(G_i, c_i) \;=\; \mathrm{SSB}_\mu(\mathrm{coarse}(\mathcal L), 0).$$

*Proof sketch.* Inside group $i$, the coarse midrank is a constant, so it factors out of the inner sum; the remaining factor is the group's own centred mass, which by Lemma 2.5 is $|G_i|$ times its centred midrank. The product is exactly the group's contribution to the coarse sum of squares. $\square$

**Theorem 4.3 (Nested-ties law).** For any nesting $\mathcal L$ with $\mathrm{SSB}(\mathrm{coarse}(\mathcal L)) > 0$,
$$\rho^2 \;=\; \frac{\mathrm{SSB}\bigl(\mathrm{coarse}(\mathcal L)\bigr)}{\mathrm{SSB}\bigl(\mathrm{flat}(\mathcal L)\bigr)}.$$

*Proof sketch.* $\rho^2 = \mathrm{Cov}^2/(\mathrm{SSB}(\text{fine})\cdot\mathrm{SSB}(\text{coarse}))$ by definition, and $\mathrm{Cov} = \mathrm{SSB}(\text{coarse})$ by Theorem 4.2; one factor cancels. $\square$

**This is an identity, not a bound.** The squared Spearman coefficient is *exactly* the fraction of the between-block variance of $T$ that survives the coarsening. It subsumes both earlier ceilings: taking the coarse side to be a two-group split recovers the rate parabola of §3, and taking the fine side to be the tie-free ranking recovers $6/7$.

### 4.3 Monotonicity of coarsening

**Theorem 4.4 (Coarsening loses variance).** For every nesting, $\mathrm{SSB}_\mu(\mathrm{coarse}(\mathcal L), c) \le \mathrm{SSB}_\mu(\mathrm{flat}(\mathcal L), c)$; consequently $\rho^2 \le 1$.

*Proof sketch.* Group by group, one must show $\bigl(\mathrm{mass}\bigr)^2/|G| \le \mathrm{SSB}(G)$, which is Cauchy–Schwarz (equivalently, the parallel-axis theorem: the group's own internal spread is discarded). Additivity (Lemma 2.8) then assembles the groups. $\square$

Thus the ladder is ordered: the finer the response, the higher the attainable dial, and every rung is capped at $1$.

---

## 5. Bottom-blindness is excluded

**Definition 5.1 (Bottom-blind profile).** At depth $t$, the bottom-blind response merges the lowest $t$ tie blocks of $T$ (a fraction $1 - 2^{-t}$ of the sample) into a single group and resolves everything above them fully:
$$\mathrm{BM}(b,t) \;=\; \Bigl[\textstyle\sum(\text{first } t \text{ blocks of } D_b)\Bigr] \mathbin{+\!\!+} D_{b-t}.$$
By Theorem 4.4 this is the *best* response blind on the bottom $t$ blocks: any further coarsening above the boundary can only lower $\rho^2$.

**Theorem 5.2 (Bottom-blind sum of squares).** For $t+1 \le b$,
$$\mathrm{SSB}\bigl(\mathrm{BM}(b,t)\bigr) \;=\; \frac{(2^t-1)2^t}{4}\,8^{\,b-t} \;+\; \frac{8^{\,b-t}-1}{14}.$$

*Proof sketch.* Write $N_1 = 2^b - 2^{b-t} = (2^t-1)2^{b-t}$ for the merged bulk. Its midrank is $(N_1+1)/2$, displaced from the grand mean $(2^b+1)/2$ by $-2^{\,b-t-1}$, so it contributes $N_1\,2^{2(b-t-1)} = (2^t-1)8^{\,b-t}/4$. The surviving tail is a translate of $D_{b-t}$ sitting at offset $N_1$; by Lemma 2.7 its contribution splits into an aggregate term $2^{\,b-t}(N_1/2)^2 = (2^t-1)^2 8^{\,b-t}/4$ and its own internal $\mathrm{SSB}(D_{b-t}) = (8^{\,b-t}-1)/14$ (Theorem 2.9). Adding the two aggregate terms, $\bigl[(2^t-1) + (2^t-1)^2\bigr]/4 = (2^t-1)2^t/4$. $\square$

**Theorem 5.3 (Bottom-blind ceiling).** For $t + 1 \le b$,
$$\rho^2 \;=\; \frac{\tfrac72 (2^t-1)2^t\,8^{\,b-t} \;+\; 8^{\,b-t}-1}{8^{\,b}-1}.$$

At $t = 3$ this is $(197 \cdot 8^{\,b-3} - 1)/(8^{\,b}-1) \to 197/512 = 0.384766\ldots$; at $t = 2$ it is $\to 43/64 = 0.671875$; at $t = 1$ it is $1$ (no merge has occurred).

**Theorem 5.4 (Blindness ceiling is small for $t \ge 3$).** For all $t \ge 3$ and $b \ge t+1$, the bottom-blind ceiling is $< 0.45$.

*Proof sketch.* Write $u = 2^t \ge 8$ and $y = 8^{b-t} \ge 8$; the ceiling is $(\tfrac72(u-1)uy + y - 1)/(u^3 y - 1)$, and $\tfrac72 u(u-1) + 1 \le \tfrac{45}{100} u^3$ for $u \ge 8$ (indeed $\tfrac72 \cdot 56 + 1 = 197 \le 0.45\cdot 512 = 230.4$), which suffices after clearing denominators. $\square$

**Theorem 5.5 (Bottom-blindness excluded, the payload).** At exact bit-length $48$, every response that fails to distinguish inside the bottom $t \ge 3$ tie blocks of $T$ — that is, flat on at least the $87.5\%$ no-relation bulk — satisfies $\rho^2 \le 0.3848 < 0.5172 = 0.7192^2$, however finely it resolves the remaining $12.5\%$.

**Theorem 5.6 (Resolution threshold — two-sided).** At $b = 47$:
* for every $t \ge 3$, the depth-$t$ bottom-blind ceiling is strictly below $0.7192^2$ (excluded);
* at $t = 2$, the ceiling is $\approx 0.6719 > 0.7192^2$ (not excluded).

So the measurement locates the required resolution sharply: blindness on the bottom $75\%$ is compatible with the data; blindness on the bottom $87.5\%$ is not.

**Interpretation.** The information certified by the measured correlation does not live on the relation events. It lives in the no-relation bulk. Whatever the downstream mechanism is, it must carry graded structure across the $87.5\%$ of draws where nothing is observed to happen.

---

## 6. Tip-blindness is admissible: a sharp asymmetry

**Definition 6.1 (Tip-blind profile).** $\mathrm{TM}(b,t) = (\text{first } t \text{ blocks of } D_b) \mathbin{+\!\!+} [\,2^{\,b-t}\,]$: full resolution on the bottom $t$ blocks, one single group for the entire top $2^{-t}$ fraction of the $T$-scale.

**Theorem 6.2 (The tip merge is free of interaction).** For $t \le b$ with $b - t \ge 1$,
$$\mathrm{SSB}\bigl(\mathrm{TM}(b,t)\bigr) \;=\; \mathrm{SSB}(D_b) \;-\; \frac{8^{\,b-t}-1}{14}.$$
That is, merging the tip costs *exactly* the merged part's own between-block sum of squares, with **no interaction term**.

*Proof sketch.* By additivity (Lemma 2.8) both profiles agree on the first $t$ blocks. On the tail, the merged group's parallel-axis contribution $|{\cdot}|\,(\bar r - \mu)^2$ coincides identically with the corresponding aggregate term of the fine tail, because the fine tail's centred mass about its own mean vanishes (Lemma 2.5). What remains is precisely the tail's internal sum of squares $\mathrm{SSB}(D_{b-t}) = (8^{b-t}-1)/14$. $\square$

**Theorem 6.3 (Tip-blind ceiling).** $\displaystyle \rho^2 \;=\; \frac{8^{\,b} - 8^{\,b-t}}{8^{\,b}-1}$.

**Theorem 6.4 (Tip blindness never binds).** For every $t \ge 1$ and $b \ge t+1$, the tip-blind ceiling exceeds $7/8$.

*Proof sketch.* $8^{\,b-t}\cdot 8 \le 8^{\,b}$ for $t \ge 1$, so $8^{\,b} - 8^{\,b-t} \ge \tfrac78 8^{\,b} > \tfrac78(8^{\,b}-1)$. $\square$

**Theorem 6.5 (Tip-blind responses are admissible).** At exact bit-length $48$, for every depth $t \ge 1$ there exists a response totally blind on the top $2^{-t}$ fraction of the $T$-scale — including $t = 1$, blind on the entire top half — whose squared Spearman coefficient exceeds $0.7192^2$.

**Theorem 6.6 (Bulk/tip asymmetry).** At $b = 47$,
$$\underbrace{\rho^2\bigl(\mathrm{BM}(47,3)\bigr) = 0.3848 \;<\; 0.7192^2}_{\text{merging the bottom } 87.5\% \text{ destroys the dial}} \qquad\text{and}\qquad \underbrace{0.7192^2 \;<\; \rho^2\bigl(\mathrm{TM}(47,1)\bigr) = 0.8750}_{\text{merging the top } 50\% \text{ does not}} .$$

**Interpretation.** The asymmetry is a direct consequence of where the between-block mass sits. In the geometric spectrum $\mathrm{SSB} = (n^3-1)/14$, the level-$k$ contribution is $8^k/2$: the mass is concentrated overwhelmingly on the *large, low-$T$* blocks. The tip blocks are extreme in rank but negligible in weight. Rank correlation is a mass-weighted average, and averages follow mass, not extremity.

---

## 7. Bit-length invariance

**Theorem 7.1 (Uniform bit-length bound).** For every $b \ge 1$ and every $p \in [0,1]$, with $n = 2^b$,
$$\Bigl|\;\frac72 p(1-p)\frac{n^3}{n^3-1} \;-\; \frac72 p(1-p)\;\Bigr| \;\le\; \frac{2}{n^3} \;=\; \frac{2}{8^{\,b}} .$$

*Proof sketch.* The difference is $\tfrac72 p(1-p)/(n^3-1)$; since $p(1-p) \le 1/4$ and $n^3 \ge 8$, this is at most $\tfrac78/(n^3-1) \le 2/n^3$. $\square$

At $b = 47$ the bound is $7\times10^{-43}$. Every ceiling in this paper therefore coincides with the limit parabola $\tfrac72 p(1-p)$ to exponential accuracy: the constraint landscape is *self-similar* in bit-length, because increasing $b$ by one adds a single new block at the mass-negligible tip. The empirically observed flatness of the measurement across bit-length scans is thus an algebraic fact about the tie spectrum, not a property of the sampler.

---

## 8. The geometric-ratio family: $7/2$ is a shape constant

Nothing in §§2–7 used the primality of $2$, divisibility, or any arithmetic property. Only the geometric *shape* of the tie profile was used. This section makes the observation precise and extracts a monotonicity that ranks the whole family.

**Definition 8.1 (Ratio-$1/q$ profile).** For a digit base $q \ge 2$, the trailing-zero-digit statistic on $\{0, \ldots, q^b-1\}$ has the tie profile
$$G_q(b) \;=\; \bigl[\,(q-1)q^{b-1},\; (q-1)q^{b-2},\; \ldots,\; (q-1),\; 1\,\bigr], \qquad \textstyle\sum G_q(b) = q^b .$$
At $q = 2$ this is exactly the dyadic profile $D_b$.

**Theorem 8.2 (Geometric-ratio sum of squares).** With $n = q^b$,
$$\mathrm{SSB}\bigl(G_q(b)\bigr) \;=\; \frac{q\,(n^3-1)}{4\,(q^2+q+1)} .$$

*Proof sketch.* Induction on $b$ with the parallel-axis identity, exactly as in Theorem 2.9. Prepending the block of size $(q-1)q^{b-1}$ shifts the offset of the old profile by that amount and moves the grand mean from $(q^b+1)/2$ to $(q^{b+1}+1)/2$; the cross term of the new block cancels against the recentring of the old ones, leaving an exact contribution of $q^{3k}\cdot q(q-1)/4$ at level $k$. Summing the geometric series $\tfrac{q(q-1)}{4}\sum_{k<b} q^{3k} = \tfrac{q(q-1)}{4}\cdot\frac{q^{3b}-1}{q^3-1} = \frac{q(n^3-1)}{4(q^2+q+1)}$, since $q^3-1 = (q-1)(q^2+q+1)$. $\square$

**Corollary 8.3 (Recovery of the dyadic law).** At $q = 2$: $\mathrm{SSB}(D_b) = 2(n^3-1)/(4\cdot 7) = (n^3-1)/14$, recovering Theorem 2.9.

*Sanity check.* At $q = 3$, $b = 1$: blocks $[2,1]$, midranks $1.5, 3$, mean $2$, giving $2(0.5)^2 + 1(1)^2 = 3/2$; the formula gives $3\cdot 26/(4\cdot 13) = 3/2$. ✓

**Theorem 8.4 (Geometric-ratio ceiling).** For a two-valued response at relation rate $p$ on the ratio-$1/q$ spectrum with $n = q^b$ and $b \ge 1$,
$$\rho^2_{\max}(p) \;=\; \frac{n\cdot pn\cdot (1-p)n}{4\,\mathrm{SSB}(G_q(b))} \;=\; C(q)\; p\,(1-p)\;\frac{n^3}{n^3-1}, \qquad C(q) := \frac{q^2+q+1}{q} .$$

**Theorem 8.5 (The ceiling constant is strictly increasing).** For $1 \le x < y$,
$$\frac{x^2+x+1}{x} \;<\; \frac{y^2+y+1}{y} .$$

*Proof sketch.* Cross-multiplying, the claim is $y(x^2+x+1) < x(y^2+y+1)$, i.e. $0 < (y-x)(xy-1)$, which holds since $y > x \ge 1$ forces $xy > 1$. Equivalently, $C(q) = q+1+1/q$ has derivative $1 - 1/q^2 > 0$ for $q > 1$. $\square$

**Theorem 8.6 (The dyadic regime is the hardest).** For every $q > 2$ and every $p \in (0,1)$,
$$\frac72\,p\,(1-p) \;<\; C(q)\,p\,(1-p).$$

**Interpretation.** The constant $7/2$ is a *shape* constant: it measures the geometric ratio of the tie spectrum, not the prime $2$. Written $C(q) = q + 1 + 1/q$, it is minimised over integer bases at $q = 2$, where $C = 7/2$. Coarser digit bases decay more slowly, spread the block mass less extremely, and make the dial *easier* to saturate at a given rate. Numerically: $C(2) = 3.5$, $C(3) = 4.33$, $C(4) = 5.25$, $C(8) = 9.125$; at $p = 1/8$ the limiting ceilings are $0.383$, $0.474$, $0.574$, $0.998$ respectively.

Consequently every exclusion in this paper — no two-valued response at rate $1/8$, no bulk-blind response, a binary model needing double the rate — is the **strongest statement available anywhere in the geometric family**. The recorded experiment sits at the most demanding point of a continuum, and its negative results are correspondingly sharpest. In particular, a base-$8$ analogue of the same experiment would *not* be able to exclude a binary indicator at rate $1/8$ at all, since $C(8)\cdot\tfrac18\cdot\tfrac78 = 0.998$.

---

## 9. Algorithms

All quantities in this paper are exactly computable in rational arithmetic. Three procedures suffice.

**Algorithm A — Between-block sum of squares.** Given a profile $L = [m_0,\ldots,m_r]$, sweep once maintaining the prefix sum $C$, emitting $r_j = C + (m_j+1)/2$ and accumulating $m_j(r_j-\mu)^2$ with $\mu = (n+1)/2$. Time $O(r)$ in exact rationals; the closed forms of Theorems 2.9 and 8.2 reduce this to $O(1)$ for the geometric profiles (up to the cost of a big-integer power).

**Algorithm B — Ceiling evaluator.** Given a nesting specified as a list of group boundaries, form the coarse profile by prefix-summing within each group, apply Algorithm A to both the coarse and the fine profile, and return their ratio. By Theorem 4.3 this returns the exact attainable $\rho^2$, not a bound. Time $O(r)$.

**Algorithm C — Exhaustive sharpness certificate.** For small $b$, enumerate all selections $s$ with $0 \le s_j \le m_j$ and $\sum s_j = K$, evaluate $\rho^2_{\mathrm{bin}}$ via $\mathrm{Cov} = \tfrac n2\sum_j s_j(r_j-\mu)$ and $\mathrm{Var} = nK(n-K)/4$, and compare the maximum against the closed-form ceiling. Complexity is $O\!\left(\prod_j (m_j+1)\right)$ in the worst case, so this is a small-$b$ certificate only; it confirms both the value of the ceiling and that the argmax is the top-filling selection. Executed at $(b,t) \in \{(3,1),(4,1),(4,2),(5,2)\}$ it reproduces $64/73$, $512/585$, $128/195$, $3072/4681$ exactly, in each case with the top-segment maximiser.

---

## 10. Discussion

### 10.1 What a single scalar buys

The methodological content of this paper is that a **single rank correlation, measured against a heavily-tied statistic, is a constraint on the resolution structure of an unobserved mechanism**. The mechanism is not identified; but Theorem 4.3 converts the scalar into an exact inequality about how much of the block variance the mechanism must preserve, and that inequality rules out named families of mechanisms permanently.

Ties are ordinarily regarded as a defect of the measurement, to be corrected by an attenuation factor. The results here invert that view: the tie spectrum is the *instrument*. Its block-mass distribution determines which parts of the scale a strong correlation certifies. For a geometric spectrum, mass concentrates at the low end, so a strong correlation certifies fine structure in the bulk and says almost nothing about the tail.

### 10.2 Why coarse and fine ceilings point opposite ways

The refining ceiling $\mathrm{SSB}/\mathrm{SSB}_{\text{tot}}$ is *monotone increasing* in $\mathrm{SSB}$; the coarse ceiling $nK(n-K)/(4\,\mathrm{SSB})$ is *monotone decreasing* in it. A statistic with heavy ties has low $\mathrm{SSB}$, hence a low refining ceiling but a high coarse ceiling. This is the mechanism behind Theorem 3.13 ($7/8 > 6/7$) and behind the baseline reversal of Theorem 3.14. Practically: when comparing candidate predictors against a coarse target, the ranking of predictors by "headroom" must be recomputed — it is not the one the refining theory gives.

### 10.3 Scope and limitations

* The greedy-optimality theorem (3.5) is stated for selections whose count matches a block boundary. For rates strictly between boundaries the same argument gives the bound at the nearest boundaries, with the parabola interpolating; the recorded rate $1/8 = 2^{-3}$ is exactly aligned, so no interpolation is needed here.
* The nested-ties identity requires the response to be constant on *consecutive* blocks. A response that merges non-adjacent levels or reverses order falls outside; its correlation is then bounded above by the corresponding consecutive coarsening, since reordering can only reduce the aligned covariance.
* All exclusions are exclusions of *response shapes*. They do not identify the mechanism; they delimit the set of mechanisms compatible with the measurement.
* The exclusions are stated against the recorded numeric values $0.7192/0.7202/0.7198$; the margins are large ($0.5172$ against a $0.3848$ cap), so they are robust to substantial revision of the measurement.

### 10.4 Numerical summary at exact bit-length $48$

| Response class | Exact ceiling $\rho^2$ | $\rho$ | Verdict against $0.7192$ |
|---|---|---|---|
| Arbitrary refinement of $T$ | $\tfrac67(1+\tfrac{1}{n(n+1)})$ | $0.9258$ | permitted |
| Binary, rate $1/2$ | $\tfrac78$ | $0.9354$ | permitted |
| Binary, rate $1/4$ | $\tfrac{21}{32}$ | $0.8101$ | permitted |
| **Binary, rate $1/8$ (recorded)** | $\tfrac{49}{128}$ | $0.6187$ | **excluded** |
| Binary, rate $1/16$ | $0.2051$ | $0.4529$ | excluded |
| Bulk-blind, depth $2$ ($75\%$) | $\tfrac{43}{64} = 0.6719$ | $0.8197$ | permitted |
| **Bulk-blind, depth $3$ ($87.5\%$)** | $\tfrac{197}{512} = 0.3848$ | $0.6203$ | **excluded** |
| Tip-blind, depth $1$ (top $50\%$) | $\tfrac78 = 0.8750$ | $0.9354$ | permitted |
| Tip-blind, depth $3$ (top $12.5\%$) | $0.9980$ | $0.9990$ | permitted |

---

## 11. Future directions

**Valuation-class resolution spectrum.** The bottom-blind and tip-blind families are the two extreme one-parameter slices of a much larger lattice: arbitrary consecutive coarsenings of the $b+1$ tie levels, ordered by refinement. By Theorem 4.3 each element has an exactly computable $\rho^2$, so the measurement induces a *cut* through this lattice, separating admissible from inadmissible resolution patterns. Characterising that cut combinatorially — which sets of merges a given correlation permits — would upgrade the two threshold results of §§5–6 into a complete classification. Because the level-$k$ block contributes $8^k/2$ to $(n^3-1)/14$, the cut ought to be describable by a weight condition on the merged index sets alone.

**Non-geometric spectra.** Theorem 8.2 covers ratio-$1/q$ spectra. The popcount profile $\binom{b}{k}$ is the natural non-geometric comparison (it appears in Theorem 3.14), and other natural statistics give polynomial or heavy-tailed profiles. A general formula for $\mathrm{SSB}$ in terms of the profile's generating function would place all of these in one frame and identify which shape constants are attainable.

**Interpolation between boundaries.** Extending the greedy-optimality theorem to non-aligned rates would yield the exact ceiling at arbitrary $p$, presumably a piecewise-quadratic interpolation of the dyadic parabola pinned at the boundaries.

**Two-sided design.** The ceilings are constructive: the top-filling response attains the coarse bound, and the maximally-fine-above-the-line response attains the bottom-blind bound. This makes them usable as *design* targets — given a resolution budget, they say exactly which merges to spend it on. For a geometric spectrum the answer is unambiguous: spend everything on the bulk.

**Lower-bound theory.** All results here are ceilings. A complementary theory of *floors* — the minimum correlation forced by a given resolution structure — would let a measured value pin a mechanism from both sides, converting exclusions into a genuine confidence region on the resolution profile.
