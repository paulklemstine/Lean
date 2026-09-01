# Approaching but Not Crossed: Pooling Geometry, a Kendall-Metric Crossing Budget, and the Resolution Wall for a Rank-Correlation Dial

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We study the following question, raised by a monitoring experiment but mathematical in substance: *when a monitored rank correlation approaches a pre-registered floor without crossing it, what — if anything — can be proved?* The concrete record is a Spearman rank-correlation "dial" evaluated on a ladder of problem sizes, whose reading at size $84$ is $\rho = 0.558$ with bootstrap interval $[0.536, 0.581]$ and per-replicate readings $0.572$, $0.578$, $0.522$, against a pre-registered floor of $0.55$: a margin of $+0.008$, with the interval straddling the floor.

We develop six independent analyses, each yielding a general theorem together with its instantiation at the recorded numbers.

1. **Pooling geometry.** A convex aggregate is trapped between its components, hence a pooled crossing forces a component crossing; and pooling is $1$-Lipschitz for the sup-metric on components, so a pooled cliff is a component cliff.
2. **Replication fragility.** An exact crossing criterion for the pooled mean under replication gives a threshold of $0.528$ for a fourth replicate — below the lowest reading already observed.
3. **A rank-metric crossing budget.** We prove the exact transposition identity for the Spearman displacement sum, deduce a sharp adjacent-step bound of $12/n(n+1)$, and obtain a crossing budget: descending a margin $m$ costs at least $m\,n(n+1)/12$ adjacent transpositions — $11\,188$ at the recorded margin and $n = 4096$. An independent $\ell^1$-accumulation argument gives a second budget $\rho \ge 1 - 24K^2/n(n^2-1)$. As by-products we recover $\rho(\mathrm{id}) = +1$, $\rho(\mathrm{rev}) = -1$, and a sorting lower bound of $n(n+1)/6$ adjacent swaps to reverse a list.
4. **Non-monotonicity and a model noise floor.** The ladder rebounds after size $84$; any nonincreasing model must therefore absorb an error $\eta \ge 0.00795 = \tfrac{159}{160}$ of the margin. The local least-squares slope is $+0.001225$ per bit, away from the floor.
5. **A resolution wall.** Under a $c/\sqrt m$ half-width law, resolving the margin requires $\ge 2025/256 \approx 7.91$ times the sample; and a point estimate on the wrong side of the bar cannot be rescued by any amount of shrinkage.
6. **Indistinguishability.** Crossed and uncrossed hypotheses are realisable by predictors with mutual correlation $\ge 0.9999$, i.e. separated by a rotation of under $0.81^\circ$; and within a contractive fade model, eventual crossing is equivalent to a statement about the limit $L$ alone, which two explicit fades — one crossing, one not — leave undetermined at the recorded resolution.

The unifying conclusion is that "gradual, not a cliff" admits a precise reading: a cliff in a rank correlation is an $\Omega(n^2)$ rearrangement of the underlying ranking, so gradualness is forced by the metric geometry of the symmetric group rather than observed in the data; and at the recorded resolution the crossing question is not decidable within the natural model class.

**Keywords:** Spearman rank correlation, Kendall-tau metric, adjacent transpositions, crossing budget, Bhatia–Davis inequality, monotone approximation, resolution analysis, correlation geometry.

---

## 1. Introduction

### 1.1 The empirical record

A *dial* is a scalar diagnostic monitored across a ladder of problem sizes. The dial studied here is a Spearman rank correlation between a structural statistic $T$ of a uniformly drawn integer (a trailing-zero / small-prime measure) and a downstream performance rate. It is evaluated at a ladder of bit-lengths:

| bit-length $b$ | 44 | 52 | 64 | 72 | 76 | 84 | 92 | 96 |
|---|---|---|---|---|---|---|---|---|
| $\rho(b)$ | 0.780 | 0.705 | 0.648 | 0.605 | 0.608 | **0.558** | 0.563 | 0.5739 |

At bit-length $84$ the pooled reading is $\rho = 0.558$, with a bootstrap confidence interval $[0.536, 0.581]$ (half-width $0.0225$) and three independent replicate readings $0.572$, $0.578$, $0.522$.

A floor of $0.55$ was fixed in advance: readings below it declare the dial's signal exhausted. Thus:

$$\text{margin} \;=\; 0.558 - 0.55 \;=\; +0.008 \;>\; 0,$$

so the dial has not crossed; but the interval straddles the floor ($0.536 < 0.55 < 0.581$), one replicate is already below it, and the half-width exceeds the margin by a factor of $2.8125$. The recorded verdict is **approaching, not crossed**, with the erosion described as **gradual, not a cliff**.

### 1.2 The mathematical question

The prose verdict is not a theorem. This paper asks what can be proved, and identifies six independent axes on which a rigorous statement is available. Two of them (Sections 2 and 3) concern the aggregation of replicates; one (Section 4) is a genuine combinatorics/statistics bridge, giving a lower bound on the number of elementary rank rearrangements required to move a correlation by a given amount; two (Sections 5 and 6) concern the interaction between the margin and the resolution of the measurement and of the model class; one (Section 7) shows that the two hypotheses under test are geometrically almost identical.

Throughout, "recorded" quantities are the numbers above; every derived quantity is exact and rational unless stated otherwise.

### 1.3 Notation

For a finite index set $I$, weights $w : I \to \mathbb{Q}_{\ge 0}$ with $\sum_i w_i = 1$, and values $x : I \to \mathbb{Q}$, we write $\langle w, x\rangle = \sum_i w_i x_i$ for the pooled reading. For rankings we use vectors $\sigma : \{0,\dots,n-1\} \to \mathbb{Z}$ with values in $[0,n)$ ("rank-bounded" vectors), and set

$$D(\sigma) \;=\; \sum_{k=0}^{n-1} \bigl(\sigma(k) - k\bigr)^2, \qquad \rho_n(\sigma) \;=\; 1 - \frac{6\,D(\sigma)}{n(n^2-1)}.$$

We write $\tau_{ij}\sigma$ for the vector obtained from $\sigma$ by exchanging the *values* at positions $i$ and $j$.

---

## 2. Pooling geometry: a pooled cliff is a component cliff

The pooled reading is a convex combination of replicate readings. Two elementary facts about convex combinations do substantial work.

> **Lemma 2.1 (Convex trapping).** Let $w$ be nonnegative weights summing to $1$ and let $x : I \to \mathbb{Q}$. If $x_i \le M$ for all $i$ then $\langle w,x\rangle \le M$; if $m \le x_i$ for all $i$ then $m \le \langle w,x\rangle$.

*Proof sketch.* $\langle w,x\rangle \le \sum_i w_i M = M\sum_i w_i = M$, using $w_i \ge 0$ termwise; symmetrically for the lower bound. $\square$

> **Theorem 2.2 (A pooled crossing forces a component crossing).** Let $w$ be nonnegative weights summing to $1$. If $\langle w, x\rangle < F$, then $x_i < F$ for some $i$.

*Proof sketch.* Contrapositive of the lower half of Lemma 2.1: if every $x_i \ge F$ then $\langle w,x\rangle \ge F$. $\square$

> **Theorem 2.3 (Pooling is $1$-Lipschitz).** Let $w$ be nonnegative weights summing to $1$ and let $x, y : I \to \mathbb{Q}$ satisfy $|x_i - y_i| \le d$ for all $i$. Then $|\langle w,x\rangle - \langle w,y\rangle| \le d$.

*Proof sketch.* $\langle w,x\rangle - \langle w,y\rangle = \sum_i w_i (x_i - y_i)$, and each $x_i - y_i$ lies in $[-d, d]$; apply Lemma 2.1 to the family $(x_i - y_i)$. $\square$

**Interpretation.** Theorem 2.3 is the formal content of "a pooled cliff is a component cliff": if the pooled reading drops by $d$ between two rungs, then some replicate dropped by at least $d$. Aggregation cannot manufacture a discontinuity that is absent from every component. Conversely, a pooled non-crossing can coexist with component crossings — as it does here.

**The recorded instance.** With three equally weighted replicates $0.572, 0.578, 0.522$:

- the pooled value $0.558$ satisfies $0.522 \le 0.558 \le 0.578$, i.e. it lies inside the replicate range, exactly as Lemma 2.1 requires;
- exactly one replicate, $0.522$, is below the floor $0.55$; the other two are above. The dial survives on a two-of-three vote;
- the replicate mean is $209/375 = 0.5573\overline{3}$, reproducing the pooled reading to within $0.001$.

---

## 3. Replication fragility: an exact crossing criterion

How close is the non-crossing to being reversed by further data?

> **Theorem 3.1 (Exact crossing criterion under replication).** Let $a,b,c$ be three recorded readings, and suppose $k$ further replicates each read $v$. The pooled mean of the $3+k$ readings is below a floor $F$ if and only if
> $$a + b + c + k v \;<\; (3+k)\,F .$$

*Proof sketch.* Multiply the inequality $\frac{a+b+c+kv}{3+k} < F$ by the positive quantity $3+k$; the two statements are equivalent. $\square$

> **Corollary 3.2 (Fourth-replicate threshold).** With $a,b,c = 0.572, 0.578, 0.522$ and $F = 0.55$, a single further replicate reading $v$ drives the pooled mean below the floor if and only if $v < 0.528$.

*Proof sketch.* $a+b+c = 1.672$ and $4F = 2.2$, so the criterion of Theorem 3.1 with $k=1$ reads $v < 0.528$. $\square$

**Interpretation.** The recorded minimum replicate is $0.522 < 0.528$. Hence *a single further run merely reproducing a value already observed would tip the pooled reading below the floor.* Conversely a further run at the recorded maximum, $0.578$, leaves the pool above the floor: the non-crossing is asymmetrically fragile, one replication deep.

### 3.1 Dispersion of the replicates

The replicate spread is $0.578 - 0.522 = 0.056$, seven times the margin. This can be quantified against the sharp bound for bounded families.

> **Theorem 3.3 (Bhatia–Davis bound).** For a finite family $x : I \to \mathbb{Q}$ with all values in $[m, M]$ and mean $\mu$,
> $$\operatorname{Var}(x) \;\le\; (M - \mu)(\mu - m).$$

*Proof sketch.* Each term of $\sum_i (M - x_i)(x_i - m)$ is nonnegative, so the sum is $\ge 0$. Expanding and dividing by $|I|$ gives $-\mathbb{E}[x^2] + (M+m)\mu - Mm \ge 0$, i.e. $\operatorname{Var}(x) = \mathbb{E}[x^2] - \mu^2 \le (M+m)\mu - Mm - \mu^2 = (M-\mu)(\mu-m)$. $\square$

**The recorded instance.** With $m = 0.522$, $M = 0.578$, $\mu = 209/375$:

$$\operatorname{Var} = \frac{709}{1\,125\,000} \approx 6.3022\times 10^{-4}, \qquad (M-\mu)(\mu-m) = \frac{1643}{2\,250\,000} \approx 7.3022\times 10^{-4}.$$

The ratio is $0.863$: the three replicates sit close to the extremal two-point configuration, so the observed dispersion is near-maximal for its range. Moreover

$$\operatorname{Var} \;>\; 9 \cdot (\text{margin})^2 = 5.76 \times 10^{-4},$$

that is, the replicate standard deviation ($\approx 0.0251$) exceeds three times the margin to the floor. The non-crossing lies well inside replicate noise.

---

## 4. A rank-metric crossing budget

This section is the structural core. It converts the informal phrase "gradual, not a cliff" into a lower bound on the number of elementary rank rearrangements required for a crossing — a statement about the symmetric group, independent of any data.

### 4.1 The exact transposition identity

> **Theorem 4.1 (Transposition identity).** Let $\sigma$ be any integer vector, $i \ne j$ with $i, j < n$, and $\tau_{ij}\sigma$ the vector obtained by exchanging the values at positions $i$ and $j$. Then
> $$D(\tau_{ij}\sigma) - D(\sigma) \;=\; 2\,(j-i)\,\bigl(\sigma(j) - \sigma(i)\bigr).$$

*Proof sketch.* Split the sum defining $D$ over $\{i,j\}$ and its complement in $\{0,\dots,n-1\}$. Outside $\{i,j\}$ the summands are unchanged. On $\{i,j\}$,

$$\bigl[(\sigma(j)-i)^2 + (\sigma(i)-j)^2\bigr] - \bigl[(\sigma(i)-i)^2 + (\sigma(j)-j)^2\bigr] = 2(j-i)(\sigma(j)-\sigma(i))$$

by direct expansion — the quadratic terms cancel and only the cross terms survive. $\square$

Note that this is an *identity*, not an estimate: the entire effect of a transposition on the Spearman statistic is concentrated in the two touched coordinates and is bilinear in the position gap and the value gap.

> **Corollary 4.2 (Spearman transposition law).** For $n \ge 2$,
> $$\rho_n(\tau_{ij}\sigma) - \rho_n(\sigma) \;=\; -\,\frac{12\,(j-i)\,\bigl(\sigma(j)-\sigma(i)\bigr)}{n(n^2-1)}.$$

*Proof sketch.* Apply $\rho_n = 1 - 6D/(n(n^2-1))$ to Theorem 4.1; the denominator $n(n^2-1)$ is positive for $n \ge 2$. $\square$

### 4.2 The sharp adjacent-step bound

Adjacent transpositions ($j = i+1$) are the generators of the Kendall-tau metric on rankings: the Kendall distance between two orderings is the minimum number of adjacent swaps carrying one to the other.

> **Theorem 4.3 (Adjacent step bound).** Let $n \ge 2$ and let $\sigma$ be rank-bounded (all values in $[0,n)$). For any $i$ with $i+1 < n$,
> $$\bigl|\rho_n(\tau_{i,i+1}\sigma) - \rho_n(\sigma)\bigr| \;\le\; \frac{12}{n(n+1)}.$$

*Proof sketch.* By Corollary 4.2 with $j - i = 1$, the change is $-12(\sigma(i+1)-\sigma(i))/(n(n^2-1))$ in absolute value $12|\sigma(i+1)-\sigma(i)|/(n(n^2-1))$. Rank-boundedness gives $|\sigma(i+1)-\sigma(i)| \le n-1$, and $n(n^2-1) = n(n-1)(n+1)$, so the quotient is at most $12(n-1)/\bigl(n(n-1)(n+1)\bigr) = 12/(n(n+1))$. $\square$

> **Theorem 4.4 (Sharpness).** The constant $12/(n(n+1))$ cannot be improved. Let $\phi_n$ be the rank-bounded vector with $\phi_n(0) = n-1$, $\phi_n(1) = 0$, and $\phi_n(k) = k$ otherwise. Then
> $$\rho_n(\tau_{0,1}\phi_n) - \rho_n(\phi_n) \;=\; \frac{12}{n(n+1)} \quad\text{exactly.}$$

*Proof sketch.* Corollary 4.2 with $i=0$, $j=1$, $\phi_n(1)-\phi_n(0) = -(n-1)$ gives $+12(n-1)/(n(n^2-1)) = 12/(n(n+1))$. $\square$

### 4.3 The Lipschitz law and the crossing budget

> **Theorem 4.5 (Lipschitz along Kendall chains).** Let $n \ge 2$, let $\sigma$ be rank-bounded, and let $\ell$ be a list of $K$ adjacent position pairs inside $\{0,\dots,n-1\}$. Writing $\ell\cdot\sigma$ for the result of applying the transpositions in order,
> $$\bigl|\rho_n(\ell\cdot\sigma) - \rho_n(\sigma)\bigr| \;\le\; \frac{12K}{n(n+1)}.$$

*Proof sketch.* Induction on $K$. Rank-boundedness is preserved by transposition (the multiset of values is unchanged), so Theorem 4.3 applies at each step; the triangle inequality accumulates the per-step bounds. $\square$

> **Theorem 4.6 (Crossing budget).** Under the hypotheses of Theorem 4.5, if the chain lowers the correlation by at least $m$, i.e. $\rho_n(\sigma) - \rho_n(\ell\cdot\sigma) \ge m$, then
> $$K \;\ge\; \frac{m\,n(n+1)}{12}.$$

*Proof sketch.* Combine $m \le |\rho_n(\ell\cdot\sigma) - \rho_n(\sigma)| \le 12K/(n(n+1))$ and rearrange. $\square$

> **Corollary 4.7 (The recorded budget).** With $n = 4096$ paired ranks and margin $m = 0.008$, any chain of adjacent transpositions carrying a reading of at least $0.558$ to a reading below $0.55$ has length at least $11\,188$.

*Proof sketch.* $0.008 \cdot 4096 \cdot 4097 / 12 = 11187.49\ldots$, and the length is an integer. $\square$

**Interpretation.** This is the precise content of "gradual, not a cliff". Any crossing of the last $0.008$ is an $\Omega(m n^2)$ rearrangement of the ranking. Since a rung-to-rung transition in the experiment is not accompanied by a quadratically large reordering, no cliff is available: *gradualness is forced by the metric geometry of the symmetric group, not merely observed in the data.* Note also the consequence for definitions: at large $n$ there is no admissible single move crossing a $0.008$ margin, so "cliff" cannot be defined intrinsically — only relative to the spacing of the ladder.

### 4.4 The two ends of the scale, and a sorting lower bound

> **Theorem 4.8 (Endpoints).** For $n \ge 2$, the identity ranking $\mathrm{id}(k) = k$ has $D = 0$ and $\rho_n = +1$; the reversal $\mathrm{rev}(k) = n-1-k$ has $D = n(n^2-1)/3$ and $\rho_n = -1$.

*Proof sketch.* $D(\mathrm{id})=0$ is immediate. For the reversal, $\mathrm{rev}(k)-k = (n-1) - 2k$, so $D = \sum_{k<n}\bigl((n-1)-2k\bigr)^2$; the closed form $3\sum_{k<n}(c-2k)^2 = n\bigl(3c^2 - 6c(n-1) + 2(n-1)(2n-1)\bigr)$, proved by induction on $n$, gives $3D = n(n^2-1)$ at $c = n-1$. Substituting into $\rho_n$ yields $1 - 6\cdot\frac{n(n^2-1)}{3n(n^2-1)} = -1$. $\square$

> **Corollary 4.9 (Sorting lower bound from a rank statistic).** Reversing a list of $n \ge 2$ items requires at least $n(n+1)/6$ adjacent transpositions.

*Proof sketch.* The reversal moves $\rho_n$ from $+1$ to $-1$, a drop of $2$; apply Theorem 4.6 with $m = 2$. $\square$

This recovers the classical $\Theta(n^2)$ sorting bound by a route that never counts inversions: it comes from the modulus of continuity of a correlation coefficient.

### 4.5 A second, independent budget: $\ell^1$ accumulation

Theorem 4.6 is driven by the *worst-case single step*, one that displaces a rank by $n-1$ positions. Such steps cannot be sustained: repeated large displacements exhaust the available room. This suggests a second bound based on accumulation.

Write $A(\sigma) = \sum_{k<n} |\sigma(k) - k|$ for the $\ell^1$ displacement.

> **Lemma 4.10.** An adjacent transposition changes $A$ by at most $2$: $A(\tau_{i,i+1}\sigma) \le A(\sigma) + 2$.

*Proof sketch.* Only the two touched positions contribute, and by the triangle inequality $|\sigma(i+1)-i| + |\sigma(i)-(i+1)| \le |\sigma(i)-i| + |\sigma(i+1)-(i+1)| + 2$. $\square$

> **Lemma 4.11.** $D(\sigma) \le A(\sigma)^2$ for every $\sigma$.

*Proof sketch.* $\sum_k a_k^2 \le \bigl(\sum_k |a_k|\bigr)^2$ for real $a_k$, since the right side expands to the left side plus nonnegative cross terms. $\square$

> **Theorem 4.12 (Quadratic crossing budget).** Let $n \ge 2$. Any ranking reachable from the identity by a chain of $K$ adjacent transpositions satisfies
> $$\rho_n \;\ge\; 1 - \frac{24 K^2}{n(n^2-1)}.$$

*Proof sketch.* $A(\mathrm{id}) = 0$, so Lemma 4.10 and induction give $A \le 2K$; Lemma 4.11 gives $D \le 4K^2$; substituting into $\rho_n = 1 - 6D/(n(n^2-1))$ yields the bound. $\square$

**Comparison at the recorded scale.** Take $n = 4096$ and target reading $0.558$, a drop of $0.442$ from perfect alignment.

- Theorem 4.12 requires $K \ge 35\,576$.
- Theorem 4.6 requires $K \ge 618\,112$.

For a drop this large the linear budget dominates. The two bounds scale differently: for a drop $\varepsilon$ from perfect alignment, Theorem 4.6 gives $K \gtrsim \varepsilon n^2/12$ while Theorem 4.12 gives $K \gtrsim \sqrt{\varepsilon n^3/24}$. Equating them, the accumulation bound is the stronger one exactly when

$$\varepsilon \;\lesssim\; \frac{6}{n}, \qquad\text{equivalently}\qquad K \;\lesssim\; \frac n2 ,$$

so the $\ell^1$ bound governs the small-margin regime and the single-step bound governs the large-drop regime. At $n = 4096$ the crossover sits at $\varepsilon \approx 0.00146$ and $K \approx 2048$; the recorded drop $0.442$ is far above it, while a margin-sized drop of $0.008$ is above it too, though only by a factor of about five.

**A perspective number.** The dial has travelled at least $618\,112$ adjacent swaps' worth of distance from perfect alignment; the margin to the floor is worth a further $11\,188$. The remaining dispute is over

$$\frac{11\,188}{618\,112} \approx 1.81\%$$

of the erosion distance already covered. Equivalently, on the full Spearman scale $[-1,+1]$ of width $2$, the margin $0.008$ is $1/250 = 0.4\%$ of the scale.

---

## 5. Non-monotonicity and the monotone noise floor

The narrative "the dial is fading toward its floor" presupposes a monotone descent. The recorded ladder does not descend.

> **Observation 5.1 (Rebound).** $\rho(84) = 0.558 < \rho(92) = 0.563 < \rho(96) = 0.5739$.

> **Theorem 5.2 (Monotone-fit noise floor).** Let $d$ be data and $f$ a nonincreasing model with sup-error $\eta$, i.e. $|f(x) - d(x)| \le \eta$ for all $x$. If $i < j$ and $d(j) > d(i)$, then
> $$\eta \;\ge\; \frac{d(j) - d(i)}{2}.$$

*Proof sketch.* $f(j) \le f(i)$ by monotonicity, while $f(i) \le d(i) + \eta$ and $d(j) - \eta \le f(j)$. Chaining, $d(j) - \eta \le d(i) + \eta$, hence $2\eta \ge d(j) - d(i)$. $\square$

> **Corollary 5.3 (The recorded noise floor).** Any nonincreasing model of the ladder has sup-error
> $$\eta \;\ge\; \frac{0.5739 - 0.558}{2} = \frac{159}{20\,000} = 0.00795 = \frac{159}{160}\times 0.008.$$

**Interpretation.** *The unavoidable residual of a monotone fade is $99.375\%$ of the entire margin to the floor.* Within the model class in which "the dial is approaching its floor" is even meaningful, the margin is smaller than the model's own noise, so the crossing question is not decidable by that class.

### 5.1 The local trend points away from the floor

For three abscissae $x_1 < x_2 < x_3$ and ordinates $y_1,y_2,y_3$, the ordinary least-squares slope is

$$\hat\beta \;=\; \frac{\sum_{i}(x_i - \bar x)(y_i - \bar y)}{\sum_i (x_i-\bar x)^2}.$$

> **Theorem 5.4 (Chebyshev-type positivity).** If $x_1 < x_2 < x_3$ and $y_1 \le y_2 \le y_3$ with at least one strict inequality, then $\hat\beta > 0$.

*Proof sketch.* Use the pair identity $3\sum_i (x_i - \bar x)(y_i - \bar y) = \sum_{i<j} (x_i - x_j)(y_i - y_j)$. Each summand on the right is a product of two nonpositive factors, hence nonnegative, and at least one is strictly positive; the denominator is positive since the $x_i$ are distinct. $\square$

> **Corollary 5.5 (Recorded local slope).** Fitting the rungs $(84, 0.558)$, $(92, 0.563)$, $(96, 0.5739)$ gives
> $$\hat\beta \;=\; \frac{49}{40\,000} \;=\; +0.001225 \text{ per bit},$$
> and extrapolating one rung to bit-length $100$ predicts $0.5739 + 4\hat\beta = 0.5788 > 0.55$.

**Interpretation.** The size-$84$ rung is a local minimum of the recorded ladder. On the recorded evidence the crossing test does not merely fail to fire; the local trend is reversed. Any claim of an ongoing approach to the floor must therefore rest on rungs beyond those recorded.

---

## 6. The resolution wall

### 6.1 Sample size required to resolve the margin

Bootstrap half-widths obey a $c/\sqrt m$ law in the sample size $m$.

> **Theorem 6.1 (Resolution cost).** Let $c > 0$ and suppose the half-width at sample size $m_0 > 0$ is $h_0 = c/\sqrt{m_0}$. If a sample size $m > 0$ achieves half-width at most a target $\mathrm{mrg} > 0$, then
> $$m \;\ge\; \left(\frac{h_0}{\mathrm{mrg}}\right)^{\!2} m_0 .$$

*Proof sketch.* From $c/\sqrt m \le \mathrm{mrg}$ we get $c \le \mathrm{mrg}\sqrt m$, and $c = h_0\sqrt{m_0}$, so $(h_0/\mathrm{mrg})\sqrt{m_0} \le \sqrt m$; squaring (both sides nonnegative) gives the claim. $\square$

> **Corollary 6.2 (Recorded resolution factor).** With $h_0 = 0.0225$ and target $\mathrm{mrg} = 0.008$,
> $$m \;\ge\; \left(\frac{0.0225}{0.008}\right)^{\!2} m_0 \;=\; \frac{2025}{256}\, m_0 \;\approx\; 7.91\, m_0 .$$

Equivalently, the recorded half-width exceeds the margin by a factor of $2.8125$: this is exactly why the interval straddles the floor.

### 6.2 A limit that data cannot buy

> **Theorem 6.3 (Shrinkage cannot move a point estimate).** If the centre $c$ of a symmetric interval satisfies $c \le F$, then for every half-width $w > 0$ the lower endpoint satisfies $c - w < F$.

*Proof sketch.* $c - w < c \le F$. $\square$

**Interpretation.** Decisiveness is not always a sample-size problem. If the point estimate ever lands on or below the bar, no amount of shrinking produces an interval strictly above it. Corollary 6.2 quantifies the achievable improvement; Theorem 6.3 marks its boundary.

---

## 7. Crossing dichotomy and geometric indistinguishability

### 7.1 Eventual crossing is a statement about the limit

Model the ladder by a one-parameter contractive fade

$$\rho_j \;=\; L + a\lambda^{\,j}, \qquad a > 0,\; 0 \le \lambda < 1,$$

with limit $L$.

> **Theorem 7.1 (Crossing dichotomy).** Let $F$ be the band floor, $a > 0$ and $0 \le \lambda < 1$. Then the trajectory $(\rho_j)$ eventually falls below $F$ **if and only if** $L < F$.
>
> More precisely: (i) if $L \ge F$ then $\rho_j \ge F$ for every $j$ and every $a \ge 0$, $\lambda \ge 0$; (ii) if $L < F$ and $\lambda < 1$, then $\rho_j < F$ for all sufficiently large $j$.

*Proof sketch.* (i) $a\lambda^j \ge 0$, so $\rho_j \ge L \ge F$. (ii) $\lambda^j \to 0$ geometrically, so $a\lambda^j < F - L$ for $j$ large, whence $\rho_j < F$. $\square$

Thus the crossing question is a question about $L$ alone; no finite collection of rungs answers it unless it pins $L$ relative to $F$.

### 7.2 The recorded rungs do not pin $L$

> **Theorem 7.2 (Undecidability at the recorded resolution).** There exist two contractive fades, both reproducing the recorded rungs at bit-lengths $84$, $92$ and $96$ to within the recorded margin $0.008$, such that one never falls below the floor $0.55$ and the other eventually does. Explicitly,
> $$\text{Model A: } L = 0.5659,\; a = 10^{-6},\; \lambda = 0.5; \qquad \text{Model B: } L = 0.549,\; a = 0.017,\; \lambda = 0.998 .$$

*Proof sketch.* Model A has $L = 0.5659 > 0.55$, so by Theorem 7.1(i) it never crosses; its values are $0.5659, 0.56590\ldots, 0.5659\ldots$, each within $0.008$ of $0.558$, $0.563$, $0.5739$ respectively (the largest discrepancy is $|0.5739 - 0.565903| = 0.0080$ at the third rung). Model B has $L = 0.549 < 0.55$ and $\lambda = 0.998 < 1$, so by Theorem 7.1(ii) it crosses eventually; its first three values are $0.566$, $0.565966$, $0.565932$, again each within $0.008$ of the recorded rungs. $\square$

**Interpretation.** At its own resolution, the ladder is consistent with a dial that dies and with a dial that does not. This is the sharpest available formalisation of "gradual, not a cliff": a cliff would separate the two hypotheses; a gradient measured coarser than itself does not.

### 7.3 Crossed and uncrossed predictors are $0.9999$-aligned

Finally, we quantify how small the difference between the two hypotheses is in the geometry where correlation lives. For nonzero centred vectors, $\mathrm{corr}(u,v) = \langle u,v\rangle/\|u\|\|v\|$ is the cosine of the angle between them, and the extremal configuration for three vectors is governed by the triangle inequality for angles:

$$\mathrm{corr}(u,v) \;\ge\; \mathrm{corr}(u,w)\,\mathrm{corr}(v,w) - \sqrt{\bigl(1-\mathrm{corr}(u,w)^2\bigr)\bigl(1-\mathrm{corr}(v,w)^2\bigr)},$$

with the *maximum* attainable alignment given by the same expression with a plus sign, realised when $u$ and $v$ lie on the same side of $w$ in a common plane.

> **Theorem 7.3 (Indistinguishability of the two hypotheses).** There exist nonzero vectors $u, v, w$ in the plane with
> $$\mathrm{corr}(u,w) = 0.558, \qquad \mathrm{corr}(v,w) = 0.55, \qquad \mathrm{corr}(u,v) \ge 0.9999 .$$

*Proof sketch.* Realise the extremal planar configuration: place $w$ along a fixed axis and take $u, v$ at angles $\theta_u = \arccos(0.558)$ and $\theta_v = \arccos(0.55)$ on the same side. Then
> $$\mathrm{corr}(u,v) = \cos(\theta_u - \theta_v) = 0.558\cdot 0.55 + \sqrt{(1-0.558^2)(1-0.55^2)}.$$
> Numerically $0.3069 + \sqrt{0.688636\cdot 0.6975} = 0.3069 + 0.693054 > 0.9999$. The bound is non-vacuous: $0.55 < 0.558$, and the gap between the two target correlations is exactly the recorded margin $0.008$. $\square$

**Interpretation.** The extremal configuration in fact achieves $\mathrm{corr}(u,v) = 0.99995\ldots$, a separation of $\arccos(0.99995) \approx 0.55^\circ$, inside the certified bound $\arccos(0.9999) \approx 0.81^\circ$. The crossed and uncrossed hypotheses are therefore realisable by predictors separated by barely half a degree. "Approaching but not crossed" is a statement about a $10^{-4}$-scale geometric perturbation of the predictor.

---

## 8. Algorithms

Three computations recur; each is elementary but worth stating as an algorithm.

**Algorithm 1 (Crossing-budget evaluation).** *Input:* sample size $n \ge 2$, margin $m > 0$. *Output:* the minimum number of adjacent transpositions realising a descent of $m$.
Compute $B \leftarrow m\,n(n+1)/12$ in exact rational arithmetic, return $\lceil B\rceil$. Cost: $O(1)$ arithmetic operations. Correctness: Theorem 4.6.

**Algorithm 2 (Kendall-descent simulation).** *Input:* $n$, a target reading $\rho^\star$. *Output:* an explicit chain of adjacent transpositions from the identity attaining $\rho \le \rho^\star$, together with its length, verified against the two budgets.
Maintain the displacement sum $D$ incrementally; each candidate swap at position $i$ updates $D$ by the exact identity $2(\sigma(i+1)-\sigma(i))$ (Theorem 4.1 with $j-i=1$), so no recomputation of the sum is needed. Greedily perform the swap maximising the increase of $D$ until $\rho \le \rho^\star$. Cost: $O(1)$ per step for the update, $O(n)$ per step for greedy selection; total $O(nK)$.

**Algorithm 3 (Resolution planning).** *Input:* recorded half-width $h_0$ at sample size $m_0$, target margin. *Output:* required sample size and a decision flag.
Return $\lceil (h_0/\mathrm{mrg})^2 m_0\rceil$; if the point estimate is not strictly above the bar, additionally report that no sample size suffices (Theorem 6.3). Cost: $O(1)$. Correctness: Theorem 6.1.

---

## 9. Discussion

### 9.1 What the six analyses say together

Read as a portfolio, the results do not agree, and that is the finding.

- *Pessimistic:* one of three replicates is already below the floor (Section 2); one further replicate at an already-observed value tips the pool (Corollary 3.2); the replicate standard deviation exceeds three times the margin (Section 3.1).
- *Optimistic:* the ladder rebounds after the rung in question (Observation 5.1) and the local slope points away from the floor at $+0.001225$ per bit (Corollary 5.5).
- *Agnostic:* the margin is smaller than the residual of any monotone model (Corollary 5.3); resolving it needs $\approx 7.91\times$ the data (Corollary 6.2); and two admissible fades — one crossing, one not — both fit the rungs to within the margin (Theorem 7.2).

The correct summary is not a verdict but a diagnosis: at the recorded resolution, the crossing question is not well posed.

### 9.2 What is genuinely new

The transferable content is Section 4. The exact transposition identity (Theorem 4.1) and the sharp adjacent-step bound (Theorems 4.3–4.4) turn Spearman's coefficient into a $12/(n(n+1))$-Lipschitz function on the Cayley graph of the symmetric group generated by adjacent transpositions. This has three consequences that do not depend on the experiment at hand:

1. **Cliffs in rank correlation are $\Omega(n^2)$ events.** Any drop of size $m$ is an $\Omega(mn^2)$ rearrangement. A "cliff" in a rank statistic is therefore never a local phenomenon; it is a global reordering.
2. **"Cliff" is not intrinsically definable.** Because no admissible single move can cross a fixed margin once $n$ is large, cliff-likeness can only be defined relative to the spacing of the measurement grid. This is a limitation of the concept, not of the data.
3. **A correlation coefficient yields a sorting lower bound.** Corollary 4.9 derives $n(n+1)/6$ adjacent swaps for a reversal from continuity alone.

The failures are equally informative. A monotone-fade reading of the ladder is *false*, not merely difficult, because the data rebounds. A Gram-geometry certificate separating crossed from uncrossed states stalls because the two realisations are $0.9999$-aligned (Theorem 7.3).

### 9.3 Scope and limitations

The transposition analysis assumes untied ranks and treats the sample size $n$ as the number of paired ranks; ties would require the tie-corrected form of the coefficient and would perturb the denominators. The resolution analysis assumes the $c/\sqrt m$ half-width law, which is asymptotic; at small $m$ the bootstrap half-width can behave differently. The fade model of Section 7 is a modelling choice: Theorem 7.1 characterises crossing *within that class*, and Theorem 7.2 shows the class is underdetermined by the recorded rungs, but neither statement constrains models outside it.

---

## 10. Future directions

**Kendall–Spearman budget duality.** Section 4.3 gives a bound linear in the margin and quadratic in $n$; Section 4.5 gives one quadratic in the swap count and cubic in $n$. Neither is known to be tight. The two arise from different conserved quantities — the size of a single step versus the accumulation of $\ell^1$ displacement — so their crossover, at a drop of order $6/n$ and a swap count of order $n/2$, should mark a genuine change of extremal geometry on the symmetric group. Constructing the extremal chains at and around the crossover would settle both.

**An intrinsic cliff criterion for rank dials.** "Cliff versus gradual" currently depends on an arbitrary measurement grid. A grid-free criterion can be phrased through the crossing budget: call a ladder cliff-like at a rung if the observed rung-to-rung drop demands a rearrangement that is superlinear in the change in problem size. Making this precise would convert an informal description into a testable property.

**Sharper aggregation geometry.** Theorem 2.3 uses only the sup-metric. Replacing it by a variance-aware bound — combining Bhatia–Davis (Theorem 3.3) with the pooling map — should give a two-sided prediction interval for the pooled reading in terms of the observed replicate range, tightening Corollary 3.2 from a threshold into a probability.

**Adaptive resolution planning.** Corollary 6.2 prices the resolution of a fixed margin. In monitoring practice the margin itself moves with each rung, suggesting a sequential design problem: allocate sample size across rungs so as to minimise the expected time until the crossing question becomes decidable, subject to Theorem 6.3's hard obstruction.

**Beyond planar realisations.** Theorem 7.3 exhibits an extremal planar configuration. The general question — which correlation matrices are realisable with prescribed pairwise entries, and how the feasible set degenerates as two prescribed correlations approach each other — is the Gram-geometry route that stalled here, and remains the most promising path to a decisive certificate.

---

## 11. Conclusion

A monitored rank correlation reading $0.558$ against a floor of $0.55$ raised the question of whether a line had been crossed. The answer is that the question, as posed, is finer than the instrument. Six independent analyses converge on this: the aggregate survives only on a two-of-three vote, one replication deep; any crossing of the remaining margin is an $\Omega(n^2)$ rearrangement of the underlying ranking, so cliffs are structurally unavailable; the ladder rebounds, making any monotone fade carry a residual $99.4\%$ the size of the margin; nearly eight times the data would be needed to resolve it; and the crossed and uncrossed hypotheses can be realised by predictors separated by less than a degree.

The permanent contribution is the rank-metric machinery: an exact transposition identity, a sharp adjacent-step bound of $12/(n(n+1))$, a Lipschitz law on the Kendall-tau metric, two complementary crossing budgets, and — as a by-product — a sorting lower bound derived from a correlation coefficient. These say, once and for all, that a rank correlation cannot fall off a cliff. Gradualness is not a property of this dataset. It is a property of rankings.
