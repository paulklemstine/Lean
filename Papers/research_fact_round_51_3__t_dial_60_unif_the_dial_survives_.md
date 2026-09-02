# Tie Ceilings of the Trailing-Zero Statistic: the $6/7$ Law, a Catalan Defect, and a Half-Weight Phase Boundary

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We study the maximal Spearman rank correlation attainable by a coarse integer statistic, as a function of the law generating its inputs. The statistic of interest is the trailing-zero count $T(x) = \nu_2(x)$ of a $b$-bit word — the $2$-adic valuation — used as a cheap predictive "dial". Because a rank statistic can never resolve within a tie class, the tie profile of $T$ imposes an exact arithmetic ceiling
$$\rho^2_{\max}(m) = 1 - \frac{\sum_j (m_j^3 - m_j)}{n^3 - n}$$
on any Spearman correlation the dial can achieve. We compute this ceiling exactly under two families of draw laws and determine the complete comparison between them.

Under a **uniform** draw on $b$ bits the tie profile of $T$ is dyadic and the ceiling equals $\frac{6}{7}\bigl(1 + \frac{1}{2^b(2^b+1)}\bigr)$, so it lies strictly above $6/7$ and converges to it at rate $4^{-b}$. Under a **fixed-weight** draw — uniform on the words of weight $w$ — the tie profile is a hockey stick of binomial coefficients $\binom{b-1-k}{w-1}$; we prove this identification exactly. For the balanced law $b = 2v+2$, $w = v+1$ the leading blocks are $m_0 = (2v+1)\mathrm{Cat}_v$ and $m_1 = (v+1)\mathrm{Cat}_v$, so the shortfall of the first step from exact halving is precisely the $v$-th Catalan number, $2m_1 - m_0 = \mathrm{Cat}_v$. We prove the unconditional two-sided bracket
$$\frac{6}{7} - \frac{1}{15(v+1)} \;<\; \rho^2_{\max}(\text{balanced}, 2v+2) \;<\; \frac{6}{7}\qquad (v \ge 2),$$
with equality to $6/7$ exactly at $v=1$; consequently $6/7$ is a *two-sided attractor* separating the two draw laws at every bit length.

Across the whole fixed-weight family we establish a sharp dichotomy: the ceiling is at most $6/7$ if and only if the weight is at least half the bit length, with the excess on the sparse side bounded below by $\frac{1}{7(2v+3)}$; the boundary is attained and is sharp one step away. The order principle behind every comparison is isolated: at fixed sample size the ceiling is strictly antitone in the cube sum, so a single Robin-Hood transfer between tie blocks strictly lowers it, and the flat split maximises it among two-block profiles. Finally we generalise the alphabet: over $q$ letters the universal constant is $\frac{3q}{q^2+q+1}$, strictly decreasing in $q$, of which $6/7$ is the binary instance; consequently the acceptance band $[0.55,0.85]$ used in a $60$-bit deployment study is binary-specific, since for $q \ge 3$ the ceiling never exceeds $7/10$.

We apply these results to a recorded $60$-bit measurement, $\rho(T,\text{rate}) = 0.669$ with interval $[0.634, 0.705]$ and advantage $+0.151$ over a popcount baseline: the entire acceptance band lies strictly below both ceilings, the dial is not saturated, and the advantage over popcount is shown to run against the tie-headroom ordering on uniform draws and to be structurally forced (the baseline has ceiling exactly $0$) on fixed-weight draws.

**Keywords:** Spearman rank correlation, tie correction, $2$-adic valuation, hockey-stick identity, Catalan numbers, phase boundary, majorization, geometric tie profiles.

---

## 1. Introduction

### 1.1 The question

A *dial* is a cheap statistic used to predict an expensive outcome. The dial studied here is the trailing-zero count of a machine word,
$$T(x) \;=\; \nu_2(x) \;=\; \max\{k : 2^k \mid x\},$$
the position of the lowest set bit. It costs a single instruction and, empirically, it correlates well with a downstream rate: a controlled study on uniformly drawn $60$-bit words recorded a Spearman rank correlation
$$\rho(T,\text{rate}) = 0.669, \qquad \text{CI } [0.634, 0.705],$$
inside a pre-registered acceptance band $[0.55, 0.85]$, together with an advantage of $+0.151$, CI $[0.107, 0.193]$, over a popcount (Hamming weight) baseline.

The methodological question is: *compared to what?* A rank correlation of $0.669$ is only interpretable against the maximum that the statistic could attain. For a coarse statistic that maximum is strictly below $1$ and depends on the input law. This paper computes it.

### 1.2 Contributions

1. **Exact ceilings for two draw laws.** The dyadic profile of a uniform draw yields the closed form $\frac{6}{7}(1+\frac{1}{N(N+1)})$, $N = 2^b$; the hockey-stick profile of a fixed-weight draw is identified exactly and its ceiling bracketed.
2. **The Catalan spine.** The deviation of the balanced law from the dyadic law is concentrated in a single step of the tie profile, and equals a Catalan number.
3. **A two-sided attractor.** $6/7$ separates the two laws at *every* bit length: balanced strictly below, uniform strictly above.
4. **A half-weight phase boundary.** Over the two-parameter family of fixed-weight laws, $\mathrm{sign}(\rho^2_{\max} - 6/7)$ depends only on the weight fraction and flips exactly at $2w = b$, with a quantitative gap on the sparse side.
5. **A transfer principle.** The ceiling is strictly antitone in the cube sum at fixed total; concentrating ties strictly lowers it.
6. **The radix law.** The universal constant is $3q/(q^2+q+1)$ for a $q$-letter alphabet, strictly decreasing in $q$; hence the acceptance band is binary-specific.
7. **Deployment consequences.** The entire acceptance band is admissible under both draw laws at bit length $60$, and under any weight fraction in $[1/2,3/5]$; the popcount baseline collapses to ceiling $0$ under any fixed-weight law.

---

## 2. Tie profiles and the ceiling functional

### 2.1 Definitions

**Definition 2.1 (Tie profile).** Let $S$ be a statistic defined on a finite population $\Omega$ with $|\Omega| = n$. The *tie profile* of $S$ is the multiset of cardinalities of the level sets of $S$, written as a list $m = (m_0, m_1, \dots, m_k)$ with $\sum_j m_j = n$. We always list a profile in non-increasing order of block index, and write $n = |m| = \sum_j m_j$.

**Definition 2.2 (Tie correction).** For a profile $m$ put
$$\mathcal{T}(m) \;=\; \frac{1}{12}\sum_j \bigl(m_j^3 - m_j\bigr).$$
This is the classical Spearman tie-correction term: a block of size $m$ contributes $(m^3-m)/12$ to the variance deficit of its mid-ranks.

**Definition 2.3 (Ceiling functional).** For a profile $m$ with $n \ge 2$ define
$$\rho^2_{\max}(m) \;=\; 1 - \frac{12\,\mathcal{T}(m)}{n^3 - n} \;=\; 1 - \frac{\sum_j m_j^3 - n}{n^3-n}.$$

**Proposition 2.4 (Interpretation).** $\rho^2_{\max}(m)$ is the supremum of the squared tie-corrected Spearman correlation between a statistic with tie profile $m$ and any response, attained when the response ranks the population consistently with $S$ and resolves every tie. In particular $\rho^2_{\max}(m) \in [0,1]$; it equals $1$ iff all $m_j = 1$, and $0$ iff $m$ is the single block $(n)$.

*Proof sketch.* Assigning mid-ranks inside blocks, the rank vector of $S$ has variance $\frac{n^3-n}{12} - \mathcal{T}(m)$ instead of the untied $\frac{n^3-n}{12}$. Cauchy–Schwarz against an untied response gives the stated ratio of variances as the squared correlation bound, attained by any response that is strictly increasing across blocks. The two extremal cases are immediate from $\sum_j(m_j^3-m_j) = 0$ and $= n^3-n$ respectively. $\square$

Two elementary evaluations that will be used repeatedly:

- $\rho^2_{\max}(m) = 0$ for the one-block profile $m = (n)$;
- $\rho^2_{\max}(3,2,1) = 1 - \frac{36-6}{216-6} = 1 - \frac{1}{7} = \frac{6}{7}$;
- $\rho^2_{\max}(4,3,2,1) = 1 - \frac{100-10}{1000-10} = \frac{10}{11}$;
- $\rho^2_{\max}(2,1) = \frac34$.

### 2.2 The comparison lemma

Since $\rho^2_{\max}$ depends on the profile only through $n$ and the cube sum $C(m) = \sum_j m_j^3$, all comparisons at fixed $n$ reduce to comparisons of cube sums.

**Theorem 2.5 (Antitonicity in the cube sum).** Let $m, m'$ be profiles with $|m| = |m'| = n \ge 2$. If $C(m) \le C(m')$ then $\rho^2_{\max}(m') \le \rho^2_{\max}(m)$, with strict inequality if $C(m) < C(m')$.

*Proof.* Immediate from Definition 2.3, since $n^3-n > 0$ and the map $C \mapsto 1 - \frac{C-n}{n^3-n}$ is strictly decreasing. $\square$

**Theorem 2.6 (Transfer principle).** Let $a+1 \le b$ and let $L$ be any profile. Then
$$C\bigl((a+1), b, L\bigr) < C\bigl(a, (b+1), L\bigr),$$
and consequently, whenever the common total is at least $2$,
$$\rho^2_{\max}\bigl(a, (b+1), L\bigr) \;<\; \rho^2_{\max}\bigl((a+1), b, L\bigr).$$
That is: moving one observation from a smaller tie block into a larger one strictly lowers the ceiling.

*Proof.* The cube sum changes by $\bigl[(b+1)^3 - b^3\bigr] - \bigl[(a+1)^3 - a^3\bigr] = (3b^2+3b+1) - (3a^2+3a+1) > 0$, since $x \mapsto 3x^2+3x+1$ is strictly increasing on $x \ge 0$ and $a < b$. Apply Theorem 2.5. $\square$

**Corollary 2.7 (Two blocks: the flat split is optimal).** For a two-block profile, $C(a,b) = (a+b)^3 - 3ab(a+b)$, so at fixed total the cube sum is a strictly decreasing function of the product $ab$. Hence if $a' \le a \le b \le b'$ with $a+b = a'+b'$ then $\rho^2_{\max}(a',b') \le \rho^2_{\max}(a,b)$, and for every split of $n \ge 2$,
$$\rho^2_{\max}(a,b) \;\le\; \rho^2_{\max}\bigl(\lfloor n/2\rfloor, \lceil n/2 \rceil\bigr).$$

Numerically at $n=12$: $\rho^2_{\max}(6,6) = 0.755245$, $(5,7) = 0.734266$, $(4,8) = 0.671329$, $(3,9) = 0.566434$, $(2,10) = 0.419580$, $(1,11) = 0.230769$ — strictly decreasing under successive transfers, as Theorem 2.6 requires.

The transfer principle is the rank-statistics form of a Robin-Hood/Schur-convexity argument: **concentration of ties destroys rank resolution.**

---

## 3. Uniform draws: the dyadic profile and the constant $6/7$

**Definition 3.1 (Dyadic profile).** For $b \ge 1$ let $D_b$ be the profile
$$D_b = \bigl(2^{b-1},\, 2^{b-2},\, \dots,\, 2,\, 1,\, 1\bigr),$$
of total $2^b$.

**Proposition 3.2.** $D_b$ is the tie profile of $T = \nu_2$ on the uniform distribution over $\{0,1,\dots,2^b-1\}$: exactly $2^{b-1-k}$ words have $\nu_2 = k$ for $0 \le k \le b-1$, and the single word $0$ forms its own class.

**Theorem 3.3 (Exact uniform ceiling).** For $b \ge 1$, with $N = 2^b$,
$$\rho^2_{\max}(D_b) \;=\; \frac{6}{7}\left(1 + \frac{1}{N(N+1)}\right).$$
In particular $\rho^2_{\max}(D_b) > 6/7$ for every $b$, and $\rho^2_{\max}(D_b) - \frac67 < 4^{-b}$.

*Proof sketch.* The cube sum telescopes as a geometric series: $C(D_b) = 1 + \sum_{k=0}^{b-1} 8^{\,b-1-k} = \frac{N^3-1}{7} + 1$. Hence
$$\rho^2_{\max}(D_b) = 1 - \frac{\frac{N^3-1}{7}+1-N}{N^3-N} = \frac{6(N^3-1)}{7N(N^2-1)} = \frac{6(N^2+N+1)}{7N(N+1)},$$
using $N^3 - 1 = (N-1)(N^2+N+1)$ and $N^3 - N = N(N-1)(N+1)$. Rewriting $\frac{N^2+N+1}{N(N+1)} = 1 + \frac{1}{N(N+1)}$ gives the claim. $\square$

The constant $6/7$ is the geometric limit: a profile with ratio $1/2$ has cube-sum ratio $1/8$, and $1 - \frac{1}{1+2+4} = \frac67$. Equivalently $7 = 3c^2+3c+1$ at $c = 1$, a form that recurs in §5 and §7.

At $b = 60$ the correction is $\approx 7\times 10^{-37}$: the uniform ceiling is $6/7$ for every practical purpose, but *strictly above* it for every finite $b$.

---

## 4. Fixed-weight draws: the hockey-stick profile

### 4.1 The arithmetic bridge

**Definition 4.1 (Fixed-weight population).** For $0 \le w \le b$ let $W(b,w)$ be the set of $w$-subsets of $\{0,1,\dots,b-1\}$, identified with the $b$-bit words of Hamming weight $w$; $|W(b,w)| = \binom{b}{w}$. The trailing-zero statistic on $S \in W(b,w)$ is $T(S) = \min S$.

**Theorem 4.2 (Block sizes).** For $k < b$ the number of $S \in W(b,w)$ with $\min S = k$ is exactly
$$\binom{b-1-k}{\,w-1\,}.$$

*Proof.* Such an $S$ contains $k$, contains no element below $k$, and its remaining $w-1$ elements are an arbitrary $(w-1)$-subset of the $b-1-k$ positions in $\{k+1,\dots,b-1\}$; the correspondence is a bijection. $\square$

**Definition 4.3 (Hockey-stick profile).** Parametrise $w = v+1$ and $b = v+1+r$ with $v, r \ge 0$. Define
$$H(v,r) \;=\; \left(\binom{v+r}{v},\, \binom{v+r-1}{v},\, \dots,\, \binom{v+1}{v},\, \binom{v}{v}\right),$$
i.e. $H(v,r)_k = \binom{v+r-k}{v} = \binom{b-1-k}{w-1}$ for $0 \le k \le r$.

**Proposition 4.4 (Hockey-stick identity).** $|H(v,r)| = \sum_{k=0}^{r}\binom{v+r-k}{v} = \binom{v+1+r}{v+1} = \binom{b}{w}$.

Thus $H(v,r)$ is a genuine tie profile of the fixed-weight population, by Theorem 4.2 and Proposition 4.4. We write
$$\theta = \frac{w}{b} = \frac{v+1}{v+1+r}$$
for the *weight fraction*; $r = v+1$ is $\theta = 1/2$ (balanced), $r \le v$ is $\theta > 1/2$ (dense), $r \ge v+2$ is $\theta < 1/2$ (sparse).

**Definition 4.5 (Balanced profile).** $B_v := H(v, v+1)$, the profile of the balanced law at even bit length $b = 2v+2$, weight $w = v+1$. Explicitly
$$B_v = \left(\binom{2v+1}{v},\, \binom{2v}{v},\, \binom{2v-1}{v},\, \dots,\, 1\right), \qquad |B_v| = \binom{2v+2}{v+1}.$$
For example $B_1 = (3,2,1)$, $B_2 = (10,6,3,1)$, $B_3 = (35,20,10,4,1)$, $B_4 = (126,70,35,15,5,1)$.

### 4.2 Step ratios and the decay law

**Lemma 4.6 (Exact step ratio).** For $0 \le j$, consecutive blocks of $H(v,\cdot)$ satisfy
$$\frac{\binom{v+j-1}{v}}{\binom{v+j}{v}} \;=\; \frac{j}{v+j}.$$

Thus the profile ratio *increases* with the block index $j$: the top of the profile is the flattest part, and the tail approaches a geometric profile of ratio $r/(v+r)$ from below. Two consequences:

**Lemma 4.7 (Halving below the top).** If $j \le v$ then $\frac{j}{v+j} \le \frac12$: below the top, the hockey-stick profile at least halves at every step. Consequently, for $r \le v$,
$$C\bigl(H(v,r)\bigr) \;\le\; \frac{8}{7}\,m_0^3, \qquad m_0 = \binom{v+r}{v}.$$

**Lemma 4.8 (Geometric envelope).** For all $v \ge 1$ and $r \ge 0$, with $m_0 = \binom{v+r}{v}$,
$$C\bigl(H(v,r)\bigr)\cdot\bigl((v+r)^3 - r^3\bigr) \;\le\; m_0^3\,(v+r)^3,$$
i.e. $C \le m_0^3 / (1 - q^3)$ with $q = r/(v+r)$ the largest step ratio.

*Proof sketch of 4.8.* By Lemma 4.6 every step ratio is at most $q$, so $m_k \le q^k m_0$; summing the geometric series of cubes gives $C \le m_0^3\sum_k q^{3k} \le m_0^3/(1-q^3)$. Clearing denominators yields the division-free form. $\square$

**Lemma 4.9 (Head-to-total ratio).** $|H(v,r)|\,(v+1) = m_0\,(v+r+1)$, i.e. the head occupies exactly the fraction $\frac{v+1}{v+r+1}$ of the sample. (Immediate from $\binom{v+1+r}{v+1}(v+1) = \binom{v+r}{v}(v+r+1)$.)

---

## 5. The Catalan spine and the balanced ceiling

### 5.1 A Catalan defect

Write $\mathrm{Cat}_v = \frac{1}{v+1}\binom{2v}{v}$.

**Theorem 5.1 (Catalan spine).** The two leading blocks of the balanced profile $B_v$ are
$$m_0 = \binom{2v+1}{v} = (2v+1)\,\mathrm{Cat}_v, \qquad m_1 = \binom{2v}{v} = (v+1)\,\mathrm{Cat}_v,$$
and therefore the shortfall of the first step from exact halving is exactly a Catalan number:
$$2m_1 - m_0 \;=\; \mathrm{Cat}_v .$$
Moreover $|B_v| = 2m_0 = 2(2v+1)\mathrm{Cat}_v$, and $m_1 = 2m_2$ exactly.

*Proof.* $\binom{2v}{v} = (v+1)\mathrm{Cat}_v$ is the definition of the Catalan number. The identity $(v+1)\binom{2v+1}{v} = (2v+1)\binom{2v}{v}$ (a one-line consequence of $\binom{2v+1}{v} = \frac{2v+1}{v+1}\binom{2v}{v}$) gives $m_0 = (2v+1)\mathrm{Cat}_v$; hence $2m_1 - m_0 = (2v+2 - 2v-1)\mathrm{Cat}_v = \mathrm{Cat}_v$. The relation $\binom{2u+2}{u+1} = 2\binom{2u+1}{u+1}$ is Pascal plus symmetry, giving $m_1 = 2m_2$ and $|B_v| = \binom{2v+2}{v+1} = 2\binom{2v+1}{v}$. $\square$

For $v = 1,2,3,4$: $(m_0,m_1,2m_1-m_0) = (3,2,1), (10,6,2), (35,20,5), (126,70,14)$ — the last column is $\mathrm{Cat}_v = 1,2,5,14$.

The structural content: **the balanced law differs from the dyadic law only in its first step, and the difference is a Catalan number**, of relative size $\mathrm{Cat}_v/m_0 = 1/(2v+1)$.

### 5.2 The bracket

**Theorem 5.2 (Lower bound; sharp form).** For all $v \ge 1$,
$$\rho^2_{\max}(B_v) \;>\; \frac{6}{7} - \frac{1}{15(v+1)}.$$
A cruder version, $\rho^2_{\max}(B_v) > \frac67 - \frac{1}{v+1}$, holds for all $v \ge 0$.

*Proof sketch.* Split $B_v = (m_0, B')$ where $B' = H(v,v)$ is the tail. By Lemma 4.7, $C(B') \le \frac{8}{7}m_1^3$, so $C(B_v) \le m_0^3 + \frac87 m_1^3$. The total is $n = 2m_0$ (Theorem 5.1). Substituting into Definition 2.3 and using the exact ratio $(v+1)m_0 = (2v+1)m_1$ of Theorem 5.1 reduces the claim to a polynomial inequality in $v$ and $m_0$ alone, namely
$$m_0^3 + \tfrac87 m_1^3 - 2m_0 \;<\; \bigl((2m_0)^3 - 2m_0\bigr)\Bigl(1 - \tfrac67 + \tfrac{1}{15(v+1)}\Bigr),$$
which after clearing $m_1 = \frac{v+1}{2v+1}m_0$ is a positivity statement for a polynomial with the required sign pattern, valid for $m_0 \ge 1$. $\square$

The measured deficit is $\frac67 - \rho^2_{\max}(B_v) \approx 0.0263/v$, so the constant $1/15 = 0.0667$ is within a factor $2.5$ of optimal.

**Theorem 5.3 (Upper bound, unconditional).** For every $v \ge 2$,
$$\rho^2_{\max}(B_v) \;<\; \frac67 .$$
At $v = 1$ (bit length $4$) equality holds: $\rho^2_{\max}(3,2,1) = 6/7$ exactly.

*Proof sketch and why it is delicate.* The geometric estimate of Lemma 4.7 is exactly tight against $6/7$, so no truncation argument with a fixed number of blocks can succeed uniformly: expanding the top $K$ blocks exactly and bounding the rest geometrically gains only $O(8^{-K})$, while the whole strict inequality is carried by the Catalan defect of relative size $1/(2v+1)$; hence a $K$-block argument covers only $v \lesssim 8^{K}$. (Concretely, using the three leading blocks $m_0, m_1 = 2m_2, m_2$ gives the bound exactly on the range where $63(v+1)^3 > 8(2v+1)^3$, i.e. $v \le 94$.)

The uniform argument never truncates. One proves, by induction *down the entire profile*, an accumulated-deficit invariant of the form
$$49(v+1)\bigl(8\,m^3\bigr) \;\le\; 49(v+1)\bigl(7\,C(\text{tail}) + 1\bigr) + 24\bigl(1 + 7(v-r)\bigr)m^3,$$
comparing the cube sum of each suffix with the geometric ideal $\frac87 m^3$. The coefficient $\frac{24(1+7(v-r))}{49(v+1)}$ is linear in the remaining depth and is exactly the fixed point of the recursion $e_{s-1} = (s-1) + e_s/8$, which is why the inductive step closes with equality rather than loss; the exponentially small tail is absorbed by the additive constant $1$. Feeding the invariant at full depth, together with the head ratio of Theorem 5.1 and the crude lower bound $m_0 \ge v(2v+1)$ (from $\binom{2v+1}{v} \ge \binom{2v+1}{2}$), into Definition 2.3 yields the strict inequality for all $v \ge 2$. $\square$

**Exact small values.**
$$\rho^2_{\max}(B_1) = \frac67, \quad \rho^2_{\max}(B_2) = \frac{563}{665} = 0.846616\ldots, \quad \rho^2_{\max}(B_3) = \frac{1386}{1633} = 0.848744\ldots$$
and $\rho^2_{\max}(B_4) = 0.850682\ldots$, $\rho^2_{\max}(B_{29}) = 0.856239\ldots$ (bit length $60$), $\rho^2_{\max}(B_{94}) = 0.856864\ldots$ (bit length $190$). The sequence increases to $6/7$ from below for $v \ge 2$.

### 5.3 The sandwich

**Theorem 5.4 (Two-sided attractor).** For every $v \ge 2$, at bit length $b = 2v+2$,
$$\rho^2_{\max}(B_v) \;<\; \frac67 \;<\; \rho^2_{\max}(D_{2v+2}).$$
Hence the balanced law has strictly less tie headroom than the uniform law at every bit length, and
$$0 \;<\; \rho^2_{\max}(D_{2v+2}) - \rho^2_{\max}(B_v) \;<\; \frac{1}{15(v+1)} + 4^{-(2v+2)}.$$

*Proof.* Combine Theorems 3.3, 5.2, 5.3. $\square$

So $6/7$ is not merely the common limit of the two laws: it *separates* them. The uniform law converges to it exponentially from above; the balanced law converges to it at rate $\Theta(1/v)$ from below, the rate being exactly the relative Catalan defect.

---

## 6. The weight axis: a single phase boundary at half weight

We now vary the weight fraction $\theta = \frac{v+1}{v+1+r}$.

### 6.1 The dense side

**Theorem 6.1 (Dense ceiling).** For $1 \le r \le v$ with $\binom{v+r}{v} \ge 3$,
$$\rho^2_{\max}\bigl(H(v,r)\bigr) \;<\; \frac{6}{7}.$$

*Proof sketch.* As in Theorem 5.3, feed the accumulated-deficit invariant and the head-to-total ratio of Lemma 4.9 into Definition 2.3. Writing $P = v+1$ and $D = v-r+1 \ge 1$, the resulting surplus polynomial is
$$N = 420DP^2 + 144P^2 - 294PD^2 + 49D^3,$$
which is positive because $10P \ge 7D$ (a restatement of $r \ge 1$), and it dominates the linear terms as soon as the head block has size at least $3$. $\square$

**Theorem 6.2 (Half-weight boundary).** Let $v \ge 1$, $1 \le r \le v+1$ — equivalently, weight at least half the bit length, $2w \ge b$. Then
$$\rho^2_{\max}\bigl(H(v,r)\bigr) \;\le\; \frac67,$$
with equality exactly at the balanced law of bit length $4$ ($v = r = 1$ gives $B_1 = (3,2,1)$).

*Proof.* For $r \le v$ this is Theorem 6.1, except at the single degenerate corner $v = r = 1$ where the head is $2 < 3$; there the profile is $(2,1)$ with ceiling $3/4 < 6/7$. For $r = v+1$ this is Theorem 5.3 for $v \ge 2$ and the exact evaluation $6/7$ for $v = 1$. $\square$

### 6.2 The sparse side and the closed window

**Theorem 6.3 (Sparse excess, quantitative).** For $v \ge 1$ and $r \ge v+2$ — weight strictly below half — 
$$\rho^2_{\max}\bigl(H(v,r)\bigr) \;>\; \frac67 + \frac{1}{7(2v+3)} \;>\; \frac67 .$$

*Proof sketch.* Insert the geometric envelope of Lemma 4.8 and the head-to-total ratio of Lemma 4.9 into Definition 2.3. The claim reduces to the degree-six polynomial inequality
$$7(v+1)^3 (v+r)^3 \;<\; (v+r+1)^3\bigl((v+r)^3 - r^3\bigr),$$
whose difference, after the substitution $v = a+1$, $r = a+3+s$ with $a,s \ge 0$, has strictly positive coefficients. $\square$

The rate is of the right order: along $r = v+2$ the exact values satisfy $v\bigl(\rho^2_{\max} - \frac67\bigr) \to \frac{54}{343} = 0.1574\ldots$, while the proved bound gives $v/(7(2v+3)) \to 1/14 = 0.0714\ldots$

**Theorem 6.4 (Dichotomy).** Let $v \ge 1$, $r \ge 1$. Then
$$\rho^2_{\max}\bigl(H(v,r)\bigr) > \frac67 \iff r \ge v+2 \iff 2w < b .$$
Equivalently: for every fixed-weight draw law the sign of $\rho^2_{\max} - \frac67$ is determined by the weight fraction alone, and the unique phase boundary sits exactly at half weight.

*Proof.* Theorem 6.2 gives $\le \frac67$ for $r \le v+1$; Theorem 6.3 gives $> \frac67$ for $r \ge v+2$. $\square$

**Theorem 6.5 (Sharpness).** The boundary cannot be moved: at $v=1$, $r=3$ (weight $2$, bit length $5$), one step below half weight, the profile is $(4,3,2,1)$ and
$$\rho^2_{\max} = \frac{10}{11} = 0.909\overline{09} \;>\; \frac67 .$$

**Why the threshold is at half weight.** Put $r = c\,v$ and let $v \to \infty$. The head fraction is $m_0/n = \frac{v+1}{v+r+1} \to \frac{1}{1+c}$ (Lemma 4.9) and the largest step ratio is $q = \frac{r}{v+r} \to \frac{c}{1+c}$, so by Lemma 4.8 the burnt fraction of the rank budget is
$$\frac{C}{n^3} \;\to\; \frac{1}{(1+c)^3}\cdot\frac{1}{1-q^3} \;=\; \frac{1}{(1+c)^3 - c^3}.$$
Since $\rho^2_{\max} \to 1 - C/n^3$, the ceiling exceeds $6/7$ exactly when the burnt fraction is below $1/7$, i.e. exactly when
$$(1+c)^3 - c^3 \;=\; 3c^2 + 3c + 1 \;>\; 7 \iff c > 1 .$$
The threshold $c = 1$ is the half-weight line. Thus the crude-looking geometric estimate is asymptotically exact at the boundary, and the $7$ of $6/7$ and the location of the phase transition are the same fact about cubes: $3\cdot 1^2 + 3\cdot 1 + 1 = 7$.

### 6.3 Imbalance robustness

**Theorem 6.6 (Lower guard on the dense band).** If $1 \le r \le v$ and $2(v+1) \le 3r$ — equivalently $\tfrac12 \le \theta \le \tfrac35$ — then
$$\rho^2_{\max}\bigl(H(v,r)\bigr) \;>\; \frac{73}{100}.$$

*Proof sketch.* The hypotheses force the head block to occupy at most $3/5$ of the sample: by Lemma 4.9, $5m_0 \le 3n$. Combining with the halving bound $C \le \frac87 m_0^3$ of Lemma 4.7 gives $C \le \frac{216}{875}n^3 < \frac{27}{100}(n^3-n) + n$, whence $\rho^2_{\max} > 1 - \frac{27}{100}$. $\square$

**Corollary 6.7 (Two-sided guard).** For every fixed-weight law with $\theta \in [\tfrac12,\tfrac35]$,
$$\frac{73}{100} \;<\; \rho^2_{\max} \;\le\; \frac{6}{7},$$
and consequently every $\rho \in [0.55, 0.85]$ satisfies $\rho^2 \le 0.7225 < \rho^2_{\max}$.

So the dial's tie geometry survives a mis-specified generator: up to a ten-percentage-point weight imbalance, the entire acceptance band remains admissible.

---

## 7. The alphabet: what $6/7$ is a function of

**Definition 7.1 ($q$-adic profile).** For an alphabet of $q \ge 2$ letters and length $b \ge 1$, let
$$R_{q,b} = \bigl((q-1)q^{b-1},\, (q-1)q^{b-2},\, \dots,\, (q-1),\, 1\bigr),$$
the tie profile of the trailing-zero statistic (base-$q$ valuation) on uniform strings of length $b$; total $q^b$. At $q=2$ this is $D_b$.

**Theorem 7.2 (Radix ceiling).** For $q \ge 2$, $b \ge 1$, with $N = q^b$,
$$\rho^2_{\max}(R_{q,b}) \;=\; \frac{3q}{q^2+q+1}\left(1 + \frac{1}{N(N+1)}\right).$$

*Proof sketch.* $C(R_{q,b}) = 1 + (q-1)^3\sum_{k=0}^{b-1} q^{3k} = 1 + \frac{(q-1)^3(N^3-1)}{q^3-1} = 1 + \frac{(q-1)^2(N^3-1)}{q^2+q+1}$. Substituting into Definition 2.3 and factoring $N^3-1$ and $N^3-N$ as in Theorem 3.3 gives the closed form, with universal constant $1 - \frac{(q-1)^2}{q^2+q+1} = \frac{3q}{q^2+q+1}$. $\square$

**Corollary 7.3.** $\rho^2_{\max}(R_{q,b}) > \frac{3q}{q^2+q+1}$ for every finite $b$, and the excess is at most $q^{-2b}$.

**Theorem 7.4 (Strict antitonicity in the alphabet size).** $q \mapsto \frac{3q}{q^2+q+1}$ is strictly decreasing for $q \ge 2$:
$$\frac67 \approx 0.857 \;(q=2), \quad \frac{9}{13} \approx 0.692 \;(q=3), \quad \frac{12}{21} \approx 0.571 \;(q=4), \dots$$
A richer alphabet produces fewer, larger-index ties at the top of the profile and hence *less* attainable rank correlation, not more.

**Theorem 7.5 (The band is binary-specific).** For $q \ge 3$ and $b \ge 2$,
$$\rho^2_{\max}(R_{q,b}) \;\le\; \frac{7}{10} \;<\; 0.85^2 .$$
Hence an acceptance band whose top end is $0.85$ is unattainable — and therefore unfalsifiable at its top end — over any non-binary alphabet.

*Proof sketch.* $\frac{3q}{q^2+q+1} \le \frac{9}{13}$ for $q \ge 3$, and the finite-length correction is at most $1 + \frac{1}{90}$ for $N = q^b \ge 9$; $\frac{9}{13}\cdot\frac{91}{90} = \frac{7}{10}$. $\square$

Note the recurrence of the same cubic: the denominator $q^2+q+1$ is $\frac{q^3-1}{q-1}$, and $3c^2+3c+1 = (1+c)^3 - c^3$ decided the phase boundary of §6 and the transfer gain of Theorem 2.6. **The three facts are one fact about cubes.**

---

## 8. Application: reading a 60-bit deployment measurement

The recorded study: uniform draws at bit length $60$, $\rho(T,\text{rate}) = 0.669$ with interval $[0.634,0.705]$, acceptance band $[0.55,0.85]$, advantage over popcount $+0.151$ with interval $[0.107,0.193]$; the implied popcount reading is $0.518$.

**Proposition 8.1 (Band admissibility).** Every $\rho \in [0.55,0.85]$ satisfies
$$\rho^2 \;<\; \rho^2_{\max}(B_{29}) \quad\text{and}\quad \rho^2 \;<\; \rho^2_{\max}(D_{60}),$$
where $\rho^2_{\max}(B_{29}) = 0.856239\ldots < \frac67 < \rho^2_{\max}(D_{60}) = \frac67 + 7\times 10^{-37}$.

*Proof.* $0.85^2 = 0.7225 < \frac67 - \frac{1}{15\cdot 30} = 0.8549\ldots$, and apply Theorems 5.2, 5.3, 3.3. $\square$

This is the precise content of the claim that the deployment envelope "covers balanced and uniform draws through bit length 60": *the entire band*, not merely the observed point, lies strictly below the ceiling under both laws. By Corollary 6.7 the same holds for every weight fraction in $[1/2,3/5]$ (e.g. weight $33$ on $60$ bits, whose exact ceiling is $0.81611\ldots$), and by Theorem 6.3 it holds a fortiori on the entire sparse side, where the ceiling exceeds $6/7$.

**Proposition 8.2 (No saturation).** The observed $\rho^2 = 0.4476$ uses only $52\%$ of the available ceiling $\rho^2_{\max} \approx 0.857$. The reading is not ceiling-limited; the residual gap is informational, not arithmetic.

**Theorem 8.3 (Popcount collapse under a fixed-weight law).** Under any fixed-weight draw law, the popcount statistic is constant on the population $W(b,w)$. Its tie profile is the single block $\bigl(\binom{b}{w}\bigr)$ and hence
$$\rho^2_{\max}(\text{popcount}, \text{fixed weight}) = 0,$$
while the trailing-zero dial retains $\rho^2_{\max} \ge 0.85$ at $b=60$, $w=30$. On the balanced half of the envelope the advantage of $T$ over popcount is therefore *structurally forced*, not merely observed.

**Theorem 8.4 (The advantage is not a headroom artefact on uniform draws).** At $b = 60$ the popcount tie profile is $\bigl(\binom{60}{k}\bigr)_{k=0}^{60}$, whose ceiling is $0.99391\ldots > \frac67 = \rho^2_{\max}(D_{60})$. The popcount baseline thus has strictly *more* tie headroom than $T$, and its own reading $0.518$ is well below its own ceiling. The measured advantage $+0.151$ in favour of $T$ therefore runs against the headroom ordering and cannot be produced by tie granularity.

Together, Theorems 8.3 and 8.4 close both audit directions: on fixed-weight draws the comparison is forced in $T$'s favour by the draw law; on uniform draws the comparison is unforced and still goes $T$'s way.

---

## 9. Algorithms

All quantities above are rational and can be computed exactly.

**Algorithm A (Exact ceiling of a profile).** Given a profile $m$, return the exact rational $\rho^2_{\max}(m) = 1 - \frac{\sum m_j^3 - n}{n^3-n}$. Cost: $O(k)$ big-integer cubes for $k$ blocks; the numbers have $O(b)$ digits for $b$-bit populations, so total cost is $O(k\,M(b))$ with $M$ the multiplication cost.

**Algorithm B (Profile construction).** Dyadic: $m_k = 2^{b-1-k}$ for $k<b$, plus the singleton class of the zero word. Hockey-stick: $m_k = \binom{b-1-k}{w-1}$, generated in $O(r)$ multiplications by the exact step recursion $m_{k+1} = m_k\,\frac{b-1-k-(w-1)}{b-1-k}$, equivalently $m_{j-1}/m_j = j/(v+j)$ in the $(v,j)$ parametrisation of Definition 4.3. Radix: $m_k = (q-1)q^{b-1-k}$ plus the singleton.

**Algorithm C (Phase-boundary certification).** For a given $v$, scan $r = 1,\dots,R$ computing $\rho^2_{\max}(H(v,r))$ exactly and record the sign of $\rho^2_{\max} - 6/7$. Theorem 6.4 predicts the sign flips exactly between $r = v+1$ and $r = v+2$; the scan certifies the prediction for that $v$ in $O(R^2)$ exact operations.

**Algorithm D (Transfer descent).** Starting from a profile $m$ at fixed total, repeatedly transfer one unit from a smaller block to a larger one. By Theorem 2.6 the ceiling strictly decreases at each step; the descent terminates at the one-block profile with ceiling $0$, and the reverse (Robin-Hood) ascent terminates at the flat profile, which maximises the ceiling. This gives a constructive proof of the extremal cases and a practical bracketing procedure for any profile of known total and block count.

---

## 10. Discussion

### 10.1 What is being measured

The results reframe the practice of validating a coarse predictor by a rank correlation. The number $1$ is the wrong reference point; the right one is $\rho^2_{\max}$, a computable function of the tie profile, hence of the *pair* (statistic, draw law). For trailing zeros the reference point is $6/7$ — approached from above by uniform draws, from below by fixed-weight draws at or above half weight, and exceeded strictly below half weight.

Three practical rules follow.

1. **Report the ceiling with the correlation.** A reading of $0.669$ against a ceiling of $0.926$ ($=\sqrt{6/7}$) is a different claim from the same reading against a ceiling of $0.7$.
2. **Ceilings move when the generator moves.** Changing from uniform to balanced draws moves the ceiling by only $\approx 9\times10^{-4}$ at $60$ bits — but moving to a sparse-weight generator moves it the other way across $6/7$, and moving to a non-binary alphabet moves it to below $0.7$, invalidating the band.
3. **Compare like with like.** A baseline can lose because it is genuinely less informative or because the draw law has annihilated it. Under a fixed-weight law, popcount is annihilated (Theorem 8.3); under a uniform law it is not, and it still loses (Theorem 8.4). Only the second is evidence about the world.

### 10.2 Structural summary

Everything in the paper is driven by one identity, $(x+1)^3 - x^3 = 3x^2+3x+1$:

- it makes the ceiling strictly antitone under transfers (Theorem 2.6);
- its value at $c=1$ is the $7$ in $6/7$ and in $\sum_{k\ge0}8^{-k} = 8/7$ (Theorem 3.3);
- the inequality $3c^2+3c+1 > 7$ locates the phase boundary at half weight (Theorem 6.4);
- the polynomial $q^2+q+1 = \frac{q^3-1}{q-1}$ is the denominator of the radix constant (Theorem 7.2).

The one place where a different kind of arithmetic enters is the Catalan spine (Theorem 5.1): the deviation of the balanced from the dyadic law is not a generic $O(1/v)$ perturbation but exactly a Dyck-path count, and that is why the deviation is *inward* (lowering the ceiling below $6/7$) rather than outward.

### 10.3 Limitations

- The ceiling is an upper bound on attainable correlation, not a prediction of the attained value; it certifies non-saturation but says nothing about whether a better statistic exists.
- The fixed-weight results are stated in the parametrisation $w = v+1$, $b = v+1+r$ with $v,r \ge 1$; the degenerate corners ($w \le 1$, $w = b$) are trivially one-block or singleton cases.
- Theorem 5.2's constant $1/15$ is not optimal; the true asymptotic deficit is $\approx 0.0263/v$, i.e. constant $\approx 1/38$.
- The empirical inputs (the observed correlation and its interval) are taken as data; the theorems concern what such numbers *can* mean, not whether the particular study was well designed.

---

## 11. Future directions

1. **The exact balanced constant.** Determine $\lim_{v\to\infty} v\bigl(\frac67 - \rho^2_{\max}(B_v)\bigr)$ in closed form. The numerics give $\approx 0.0263$; the Catalan spine suggests a closed form in terms of $\sum_k \bigl(\text{ratio deficits}\bigr)$, and a matching upper bound would replace the $1/15$ of Theorem 5.2.
2. **General strong-decay profiles.** Both the dyadic and hockey-stick profiles are instances of profiles whose step ratios are monotone. Conjecture: for any profile with step ratios increasing in the index and bounded by $q$, the ceiling is bracketed by the two geometric profiles with the extreme ratios — which would subsume Lemmas 4.7, 4.8, Theorem 6.1 and Theorem 6.3 in one statement.
3. **Majorization form.** Theorem 2.6 says $\rho^2_{\max}$ is Schur-concave on profiles at fixed total. Identify exactly which profile comparisons in this paper are majorization comparisons and which require the finer arithmetic of the hockey stick.
4. **Other valuations and other alphabets.** The radix law covers uniform strings; the analogue of the half-weight phase boundary over a $q$-letter alphabet (fixed-composition draws) is open, and the natural conjecture is a boundary at composition fraction $1/q$ with constant $3q/(q^2+q+1)$.
5. **Multi-statistic ceilings.** For a pair of coarse statistics used jointly, the relevant object is the tie profile of the joint level sets; for $T$ and popcount on uniform words this refines to a two-dimensional profile whose ceiling should interpolate between $6/7$ and the popcount ceiling $0.9939$.
6. **Design implications.** Given a target ceiling, which draw laws achieve it? Theorem 6.4 gives the answer for the fixed-weight family; the general inverse problem — characterise the set of achievable ceilings over a natural class of draw laws — is open.

---

## 12. Conclusion

For a coarse rank predictor, "how good is $0.669$?" is a question about ties, and it has an exact answer. The trailing-zero statistic has tie ceiling $\frac67\bigl(1+\frac{1}{2^b(2^b+1)}\bigr)$ under uniform $b$-bit draws and a hockey-stick ceiling under fixed-weight draws, the two being separated by $6/7$ at every bit length, with the separation created by a single Catalan-sized step of the balanced profile. Across the weight axis the ceiling crosses $6/7$ exactly at half weight, and across alphabets the constant is $3q/(q^2+q+1)$. All of these follow from one order principle — the ceiling is strictly antitone in the cube sum at fixed sample size — and from one cubic identity. Applied to the $60$-bit measurement, they show that the whole acceptance band is arithmetically admissible, that the reading is far from saturation, and that the advantage over the popcount baseline is real on uniform draws and forced on balanced ones.
