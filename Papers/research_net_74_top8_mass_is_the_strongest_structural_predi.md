# Where the Knee Lives: Head Statistics, Tail Shape, and the Exact Small-Sample Calculus of a Five-Domain Attention Study

**Aristotle**

---

## Abstract

A recent structural study of attention in sequence models measured, for five text domains, three scalar descriptors of the attention distribution — its entropy, the mass carried by its eight heaviest keys, and the degree of cross-head agreement — and correlated each against the *attention knee* $k^*$, the smallest key budget capturing a fixed fraction $\tau$ of the attention mass. It reported rank correlations of $-0.60$, $+0.80$ and $-0.40$ respectively, declared top-8 mass the strongest structural predictor, and offered as mechanism the claim that "the knee is set by the residual spread after the top keys are captured, not by how concentrated the peak is."

We settle all three claims exactly. First, recomputing the coefficients from the tabulated data in exact arithmetic with the standard midrank estimator yields $\rho(\text{entropy}, k^*) = 7/(2\sqrt{95}) \approx +0.359$, $\rho(\text{top-8}, k^*) = -11/38 \approx -0.289$ and $\rho(\text{head agreement}, k^*) = -8/\sqrt{95} \approx -0.821$: the ordering of the three predictors is exactly inverted relative to the report, and the only column clearing the pre-registered $|\rho| \ge 0.7$ bar is the one declared refuted. Both the censoring of one knee value and the tie-breaking convention are swept exhaustively; neither rescues the reported verdict.

Second, we compute the exact operating characteristics of the pre-registered bar. At $n = 5$, Spearman's coefficient satisfies $\rho = 1 - D/20$ where $D$ is squared rank displacement, and complete enumeration of the $120$ permutations of five items gives $\Pr[|\rho| \ge 0.7] = 7/30 \approx 0.233$ under the permutation null. The strongest effect in the table has exact one-sided $p$-value $7/60 \approx 0.117$ under one admissible tie-break and $1/24 \approx 0.042$ under the other.

Third — and constructively — we prove the mechanism sentence outright, in a form that shows no head-mass correlation could ever have tested it. Writing $c(\cdot)$ for the capture curve, the knee obeys an exact tail reduction $k^*(\tau) = r + \min\{j : c(r+j) \ge \tau\}$ whenever $c(r) < \tau$; it is therefore a functional of the tail alone. A two-phase family of capture curves realises *any* head mass together with *any* knee, so no function maps top-8 mass to the knee, both signs of a head-mass/knee association are realisable, and there exist pairs of domains agreeing on their first eight keys whose knees differ by an arbitrary amount. Quantitatively, a geometric residual $R\rho^{\,j}$ bounds the knee logarithmically while a Pareto residual $R/(j+1)$ forces $k^* \ge r + R/(1-\tau) - 1$.

Finally we give the $\ell^2$ form of the general phenomenon. The collision mass (inverse participation ratio) $C(k) = \sum_{j<k} m_j^2$ satisfies $c(k)^2 \le k\,C(k)$ by Cauchy–Schwarz, whence $k^* \ge \tau^2/C$ for any domain with collision mass bounded by $C$; the bound is attained exactly by the uniform domain, and admits no companion upper bound of any kind. Every scalar concentration statistic of the head constrains the knee on one side only; where in $[\tau^2/C, \infty)$ the knee falls is decided by the tail.

**Keywords.** attention knee, capture curve, rank correlation, permutation null, inverse participation ratio, tail exponent, small-sample power.

---

## 1. Introduction

### 1.1 The knee

Sequence models with attention compute, at each position, a probability distribution over the keys available to them. Sorted in decreasing order of mass, that distribution is summarised by its *capture curve*: the function sending a budget $k$ to the total mass carried by the $k$ heaviest keys. The **knee** at tolerance $\tau$ is the least budget capturing a $\tau$-fraction of the mass. It is the quantity that determines how aggressively a limited-memory implementation may prune, and it varies across text domains: code appears to have a smaller knee than French prose.

The natural scientific question is *what structural feature of the attention distribution determines the knee*. Three candidate scalars suggest themselves and were measured in the study under audit:

- **Entropy**, $H = -\sum_i p_i \log p_i$, the standard information-theoretic spread.
- **Top-8 mass**, $c(8)$, the value of the capture curve at budget $8$.
- **Cross-head agreement**, the mean overlap between the attention patterns of distinct heads at the same position.

The measured table, across five domains at three sampled layers and twelve windows of context length $512$, was:

| domain | entropy | top-8 mass | head agreement | $k^*@512$ |
|---|---|---|---|---|
| code | 3.798 | 0.488 | 0.083 | 12 |
| prose-en | 3.801 | 0.488 | 0.082 | 16 |
| math | 3.615 | 0.526 | 0.086 | 16 |
| prose-de | 3.752 | 0.502 | 0.080 | 20 |
| prose-fr | 3.864 | 0.473 | 0.079 | $>24$ |

with reported Spearman coefficients $-0.60$, $+0.80$, $-0.40$ and the verdicts: entropy *partially* confirmed (right sign, insufficient magnitude), top-8 mass *confirmed* as the strongest correlate, head agreement *refuted* as "constant, not a differentiator".

### 1.2 Three questions and three answers

This paper asks, in order:

1. **Are the coefficients right?** No. We recompute them exactly (§3), and the predictor ranking inverts.
2. **Could a five-domain design have answered the question anyway?** No. We compute the exact size of the pre-registered bar under the permutation null (§4): $7/30$.
3. **Is the proposed mechanism right?** Yes — and provably, without data (§5). Moreover the proof shows that no head-mass correlation, of either sign, is evidence for or against it.

Section 6 gives the $\ell^2$ generalisation: the participation-ratio bound and its provable one-sidedness. Section 7 collects algorithms; §8 discusses consequences for practice and for study design; §9 lists open directions.

---

## 2. Definitions

Throughout, all quantities are exact rationals unless a square root appears.

**Definition 2.1 (Capture curve / attention profile).** An *attention profile* is a function $c : \mathbb{N} \to \mathbb{Q}$ — the *capture curve* — with

1. $c(0) = 0$;
2. $c$ non-decreasing;
3. $c(k) \le 1$ for all $k$;
4. for every $\tau < 1$ there is $k$ with $c(k) \ge \tau$ (the curve approaches $1$).

We read $c(k)$ as the attention mass carried by the $k$ heaviest keys.

**Definition 2.2 (Knee).** For $\tau \in (0,1)$, the *knee* of $c$ at tolerance $\tau$ is
$$k^*(\tau) \;=\; \min\{\, k \in \mathbb{N} : c(k) \ge \tau \,\},$$
well defined by (4). By definition $c(k^*(\tau)) \ge \tau$, and $c(k) < \tau$ for every $k < k^*(\tau)$.

**Definition 2.3 (Key mass, residual).** The mass of the $j$-th heaviest key is $m_j = c(j+1) - c(j) \ge 0$; the *residual* after $r$ keys is $R(r) = 1 - c(r)$. Note $\sum_{j<k} m_j = c(k)$, a telescoping identity used repeatedly.

**Definition 2.4 (Collision mass / inverse participation ratio).** The *collision mass* of the $k$ heaviest keys is
$$C(k) \;=\; \sum_{j<k} m_j^2 .$$
Its reciprocal is the *effective number of participating keys*; the terminology is standard in the physics of localisation.

**Definition 2.5 (Two reference families).**
- The **uniform profile** $U_{\tau,k}$ splits mass evenly so as to reach $\tau$ at key $k$: $c(n) = \min\{1, n\tau/k\}$. Its knee at tolerance $\tau$ is exactly $k$.
- The **staged profile** $S_{h,\tau,r,k}$, defined for $0 < h < \tau < 1$ and $0 < r < k$, has capture curve
$$c(j) \;=\; \begin{cases} 0, & j = 0,\\[2pt] \min\Big\{1,\; h + (j - r)^+ \cdot \dfrac{\tau - h}{k - r}\Big\}, & j \ge 1,\end{cases}$$
where $(x)^+ = \max(x,0)$. It places mass $h$ on the first key, holds flat through key $r$, then ramps linearly to reach exactly $\tau$ at key $k$. Its top-$r$ mass is exactly $h$ and its knee at tolerance $\tau$ is exactly $k$.

**Definition 2.6 (Midrank Spearman).** For a column $x$ of $n$ values, the *midrank* of $x_i$ is
$$r_x(i) \;=\; 1 + \#\{j : x_j < x_i\} + \tfrac{1}{2}\big(\#\{j : x_j = x_i\} - 1\big),$$
the standard tie correction. With $\bar r_x$ the mean midrank, the *rank covariance* is $S_{xy} = \sum_i (r_x(i) - \bar r_x)(r_y(i) - \bar r_y)$ and Spearman's coefficient is
$$\rho(x,y) \;=\; \frac{S_{xy}}{\sqrt{S_{xx} S_{yy}}}.$$

**Definition 2.7 (Ordinal ranking; rank covariance of rankings).** An *ordinal ranking* of a column $x$ of five values is a bijection $r : \{1,\dots,5\} \to \{1,\dots,5\}$ that is strictly monotone in the data ($x_i < x_j \Rightarrow r(i) < r(j)$). Tied entries may be ordered either way, so a column with $t$ ties admits several ordinal rankings. For two ordinal rankings of five items, whose mean rank is $3$ and whose rank variance is $10$, the rank covariance is $S_{rs} = \sum_i (r(i)-3)(s(i)-3)$ and $\rho = S_{rs}/10$.

---

## 3. Exact audit of the reported coefficients

### 3.1 The ranks

The midranks of the four columns of the table are:

| column | code | prose-en | math | prose-de | prose-fr |
|---|---|---|---|---|---|
| $k^*$ | 1 | 5/2 | 5/2 | 4 | 5 |
| entropy | 3 | 4 | 1 | 2 | 5 |
| top-8 | 5/2 | 5/2 | 5 | 4 | 1 |
| head agr. | 4 | 3 | 5 | 2 | 1 |

Each column has mean midrank $3$. The self-covariances are $S_{k^*k^*} = 19/2$ (one tie), $S_{\text{top8},\text{top8}} = 19/2$ (one tie), $S_{HH} = S_{AA} = 10$ (no ties, where $H$ is entropy and $A$ head agreement).

### 3.2 The coefficients

**Theorem 3.1 (Exact rank covariances).** On the tabulated data,
$$S_{H k^*} = \tfrac{7}{2}, \qquad S_{\text{top8}, k^*} = -\tfrac{11}{4}, \qquad S_{A k^*} = -8 .$$

*Proof.* Direct summation of the five products. For entropy: $(3-3)(1-3) + (4-3)(\tfrac52-3) + (1-3)(\tfrac52-3) + (2-3)(4-3) + (5-3)(5-3) = 0 - \tfrac12 + 1 - 1 + 4 = \tfrac72$. For top-8: $1 + \tfrac14 - 1 + 1 - 4 = -\tfrac{11}{4}$. For head agreement: $-2 + 0 - 1 - 1 - 4 = -8$. $\square$

**Theorem 3.2 (Exact Spearman coefficients).**
$$\rho(H, k^*) = \frac{7}{2\sqrt{95}} \approx +0.3591, \qquad \rho(\text{top-8}, k^*) = -\frac{11}{38} \approx -0.2895, \qquad \rho(A, k^*) = -\frac{8}{\sqrt{95}} \approx -0.8208 .$$

*Proof.* Divide Theorem 3.1 by $\sqrt{S_{xx}S_{yy}}$: for entropy $\sqrt{10 \cdot \tfrac{19}{2}} = \sqrt{95}$, giving $\tfrac72/\sqrt{95}$; for top-8 both variances are $\tfrac{19}{2}$, so the denominator is $\tfrac{19}{2}$ and the quotient is rational, $-\tfrac{11}{4} \cdot \tfrac{2}{19} = -\tfrac{11}{38}$; for head agreement the denominator is again $\sqrt{95}$. $\square$

**Corollary 3.3 (All three reported values fail).**
- $\rho(H,k^*) > 0$: the reported $-0.60$ has the wrong sign, and $|\rho| < 0.7$, so it also fails the bar.
- $\rho(\text{top-8},k^*) < 0$ and $|\rho| < 0.7$: the reported $+0.80$ fails in both sign and magnitude. The headline claim is refuted.
- $\rho(A,k^*) < -0.7$: the column declared "constant, not a differentiator" is the only one meeting the pre-registered bar.

**Theorem 3.4 (Inverted predictor ranking).** $|\rho(\text{top-8},k^*)| < |\rho(H,k^*)| < |\rho(A,k^*)|$.

*Proof.* $11/38 \approx 0.289 < 7/(2\sqrt{95}) \approx 0.359$ since $22\sqrt{95} < 266$ (as $95 \cdot 484 = 45{,}980 < 70{,}756$); and $7/(2\sqrt{95}) < 8/\sqrt{95}$ since $7 < 16$. $\square$

The reported ranking was top-8 $>$ entropy $>$ head agreement; the true ranking is its exact reverse.

### 3.3 Robustness I: the censored knee

The prose-fr knee is recorded only as $>24$. Write $k^*_v$ for the knee column with prose-fr's entry replaced by a free parameter $v$.

**Theorem 3.5 (Censoring irrelevance).** For every $v > 20$, the midranks of $k^*_v$ are $(1, \tfrac52, \tfrac52, 4, 5)$, and hence $S_{H k^*_v} = \tfrac72$, $S_{\text{top8},k^*_v} = -\tfrac{11}{4}$, $S_{A k^*_v} = -8$ for every such $v$.

*Proof.* For $v > 20$ the strict order of the five entries $12 < 16 = 16 < 20 < v$ is unchanged, and midranks depend only on the order. The covariances follow as in Theorem 3.1. $\square$

Every admissible reading of the censored value — $21$, $24$, $10^6$ — yields identical conclusions.

### 3.4 Robustness II: every tie-break

Midranks are one convention among several. We sweep all of them. Recall (Definition 2.7) that the top-8 column has one tie (code $=$ prose-en) and the knee column has one tie (prose-en $=$ math), so each admits exactly two ordinal rankings; entropy and head agreement are tie-free and admit one each.

**Theorem 3.6 (Sign robustness).** Let $r$ be any ordinal ranking of the indicated column and $s$ any ordinal ranking of the knee column. Then:

1. $S_{rs} \le -1$ when $r$ ranks top-8 mass (so $\rho \le -0.1$);
2. $S_{rs} \ge 2$ when $r$ ranks entropy (so $\rho \ge +0.2$);
3. $S_{rs} \le -7$ when $r$ ranks head agreement (so $\rho \le -0.7$).

*Proof.* Finite case check. The tie-free columns force $r = (3,4,1,2,5)$ for entropy and $r = (4,3,5,2,1)$ for head agreement; top-8 admits $r \in \{(2,3,5,4,1), (3,2,5,4,1)\}$; the knee admits $s \in \{(1,2,3,4,5), (1,3,2,4,5)\}$. Evaluating $\sum_i (r(i)-3)(s(i)-3)$ over the (at most four) combinations in each case yields the stated bounds; explicitly, the achievable values are $\{2,5\}$ for entropy, $\{-5,-3,-2,-1\}$ for top-8, and $\{-9,-7\}$ for head agreement. $\square$

**Corollary 3.7 (Audit summary).** In exact arithmetic and under every tie-breaking convention and every reading of the censored knee: entropy is *positively* associated with the knee, top-8 mass *negatively* and weakly, and head agreement *strongly negatively*. No convention produces the reported $-0.60 / +0.80 / -0.40$, and none rescues the reported ranking of the predictors.

---

## 4. What a $|\rho| \ge 0.7$ bar means at five domains

The audit shows the reported numbers are wrong. This section shows that the *design* could not have decided the question even had they been right.

### 4.1 Spearman on five items is a lattice

**Theorem 4.1 (Displacement identity at $n=5$).** Let $r,s$ be rank vectors of two permutations of five items and $D = \sum_i (r(i)-s(i))^2$. Then
$$2 S_{rs} = 20 - D, \qquad\text{equivalently}\qquad \rho = 1 - \frac{D}{20},$$
which is the classical $\rho = 1 - 6D/(n(n^2-1))$ at $n = 5$.

*Proof.* Both rank vectors are permutations of $\{1,\dots,5\}$, so $\sum_i r(i) = \sum_i s(i) = 15$ and $\sum_i r(i)^2 = \sum_i s(i)^2 = 55$. Expanding,
$$D = \sum_i r(i)^2 - 2\sum_i r(i)s(i) + \sum_i s(i)^2 = 110 - 2\sum_i r(i)s(i),$$
while $S_{rs} = \sum_i (r(i)-3)(s(i)-3) = \sum_i r(i)s(i) - 3 \cdot 15 - 3 \cdot 15 + 45 = \sum_i r(i)s(i) - 45$. Substituting, $2S_{rs} = 2\sum r s - 90 = (110 - D) - 90 = 20 - D$. $\square$

Since $D$ is an even integer in $[0,40]$, $\rho$ takes only the $21$ values $1.0, 0.9, \dots, -1.0$.

**Lemma 4.2 (Reduction to a single permutation).** For permutations $\sigma, \pi$ of the five items, the rank distance $D$ between their rank vectors equals the displacement statistic $\sum_i (\mu(i) - i)^2$ of the single permutation $\mu = \pi^{-1}\sigma$ relating them. Hence the null distribution of $\rho$ over *pairs* of rankings is the distribution of $D(\mu)$ over $\mu \in S_5$.

*Proof.* $D = \sum_i (\sigma(i) - \pi(i))^2$; re-indexing by $i \mapsto \pi^{-1}(i)$ permutes the summands. $\square$

### 4.2 The exact size of the bar

**Theorem 4.3 (Complete enumeration of $S_5$).** Among the $120$ permutations of five items, exactly $28$ satisfy $|\rho| \ge 0.7$ (i.e. $D \le 6$ or $D \ge 34$), exactly $14$ satisfy $\rho \le -0.7$ (i.e. $D \ge 34$), and exactly $5$ satisfy $\rho \le -0.9$ (i.e. $D \ge 38$).

*Proof.* Exhaustive enumeration. The full distribution of $D$ over $S_5$ is

| $D$ | 0 | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| count | 1 | 4 | 3 | 6 | 7 | 6 | 4 | 10 | 6 | 10 | 6 |

| $D$ | 22 | 24 | 26 | 28 | 30 | 32 | 34 | 36 | 38 | 40 |
|---|---|---|---|---|---|---|---|---|---|---|
| count | 10 | 6 | 10 | 4 | 6 | 7 | 6 | 3 | 4 | 1 |

(the distribution is symmetric about $D = 20$, since composing with the order-reversing permutation sends $D \mapsto 40 - D$). Summing the tails: $D \le 6$ contributes $1+4+3+6 = 14$; $D \ge 34$ contributes $6+3+4+1 = 14$; $D \ge 38$ contributes $4+1 = 5$. Total for $|\rho| \ge 0.7$ is $14 + 14 = 28$. $\square$

**Theorem 4.4 (Exact size of the pre-registered bar).** Under the permutation null at $n = 5$,
$$\Pr\big[\,|\rho| \ge 0.7\,\big] \;=\; \frac{28}{120} \;=\; \frac{7}{30} \;\approx\; 0.2333 .$$
In particular the bar is not a $5\%$ test: its exact size exceeds $1/5$.

*Proof.* Immediate from Theorem 4.3 and $|S_5| = 120$. $\square$

The consequence for a three-horn pre-registration is arithmetic: if the three predictors were independent of the knee and of each other, the probability that at least one clears the bar is $1 - (23/30)^3 \approx 0.55$. Reporting "one confirmed, one partial, one refuted" out of three is the modal outcome of pure noise at this sample size.

### 4.3 The tie decides the strongest result

**Theorem 4.5 (Significance hinges on the tie-break).** Let $r = (4,3,5,2,1)$ be the (forced) ordinal ranking of head agreement, and let $s_A = (1,2,3,4,5)$ and $s_B = (1,3,2,4,5)$ be the two admissible ordinal rankings of the knee column. Then $D(r,s_A) = 34$ and $D(r,s_B) = 38$, with exact one-sided permutation $p$-values
$$p_A = \frac{14}{120} = \frac{7}{60} \approx 0.1167 > \frac{1}{20}, \qquad p_B = \frac{5}{120} = \frac{1}{24} \approx 0.0417 < \frac{1}{20}.$$

*Proof.* $D(r,s_A) = 9 + 1 + 4 + 4 + 16 = 34$ and $D(r,s_B) = 9 + 0 + 9 + 4 + 16 = 38$. The $p$-values are the upper-tail counts of Theorem 4.3 divided by $120$. $\square$

So the single result in the whole table that clears the pre-registered bar is significant at the $5\%$ level under one admissible convention and not under the other. The tie in the data, not the data, decides.

---

## 5. The mechanism is a theorem

We now prove the study's mechanism sentence — "the knee is set by the residual spread after the top keys are captured" — and show simultaneously that no head-mass correlation could ever have been evidence for it.

### 5.1 Exact tail reduction

**Definition 5.1 (Tail knee).** For a profile $c$, a head budget $r$, and tolerance $\tau$, set $T(r,\tau) = \min\{ j : c(r+j) \ge \tau \}$, the least number of *extra* keys beyond $r$ needed to reach the tolerance. (The set is nonempty since $c$ approaches $1$ and is non-decreasing.)

**Theorem 5.2 (Exact tail reduction).** If $c(r) < \tau < 1$ then
$$k^*(\tau) \;=\; r + T(r,\tau).$$

*Proof.* Since $c(r) < \tau$ and $c$ is non-decreasing, $r \le k^*(\tau)$; write $k^*(\tau) = r + j_0$. Then $c(r + j_0) \ge \tau$, so $T(r,\tau) \le j_0$. Conversely $c(r + T(r,\tau)) \ge \tau$ exhibits a budget of size $r + T(r,\tau)$ meeting the tolerance, so $k^*(\tau) \le r + T(r,\tau)$, i.e. $j_0 \le T(r,\tau)$. $\square$

**Theorem 5.3 (The knee is a functional of the tail).** Let $c, d$ be profiles with $c(r) < \tau$, $d(r) < \tau$, and $c(r+j) = d(r+j)$ for all $j \ge 0$. Then their knees at $\tau$ coincide — regardless of any difference on indices below $r$.

*Proof.* The two sets $\{j : c(r+j) \ge \tau\}$ and $\{j : d(r+j) \ge \tau\}$ are literally the same set, so the two tail knees agree; apply Theorem 5.2 to each. $\square$

This is the precise content of "the mechanism lives in the tail." Everything below is a consequence.

### 5.2 Head and knee are independent dials

**Lemma 5.4 (Staged profiles).** For $0 < h < \tau < 1$ and $0 < r < k$, the staged profile $S_{h,\tau,r,k}$ of Definition 2.5 is a legitimate attention profile whose capture curve satisfies
$$c(r) = h \qquad\text{and}\qquad k^*(\tau) = k .$$

*Proof sketch.* Monotonicity and the bound by $1$ are built into the $\min$ and the non-negative step $s = (\tau-h)/(k-r) > 0$; the curve approaches $1$ because it keeps increasing by $s$ per key until capped at $1$. At index $r$ the ramp contributes nothing and $h < \tau < 1$, so the value is $h$. At index $k$ the ramp has added $(k-r)s = \tau - h$, and since $\tau < 1$ the $\min$ is inactive: the value is exactly $\tau$. For $0 < j < k$ the value is strictly below $\tau$ (either $h < \tau$ on the flat part, or $h + (j-r)s < h + (k-r)s = \tau$ on the ramp). Hence the least index reaching $\tau$ is exactly $k$. $\square$

**Theorem 5.5 (Head/knee decoupling).** For every head mass $h$ with $0 < h < \tau < 1$ and every $k > 8$ there is an attention profile with top-8 mass exactly $h$ and knee exactly $k$.

*Proof.* Take $S_{h,\tau,8,k}$ and apply Lemma 5.4 with $r = 8$. $\square$

**Corollary 5.6 (No functional law).** For $1/2 < \tau < 1$ there is no function $g : \mathbb{Q} \to \mathbb{N}$ with $k^*(\tau) = g(c(8))$ for all profiles.

*Proof.* Theorem 5.5 supplies profiles $P, Q$ with $P(8) = Q(8) = 1/2$ but $k^*(P) = 9$, $k^*(Q) = 10$. Then $g(1/2)$ would equal both $9$ and $10$. $\square$

**Corollary 5.7 (The sign of a head-mass/knee association is free).** For $3/4 < \tau < 1$ there exist profiles $P,Q$ with $P(8) < Q(8)$ and $k^*(P) < k^*(Q)$, *and* profiles $P',Q'$ with $P'(8) < Q'(8)$ and $k^*(Q') < k^*(P')$.

*Proof.* Take $P = S_{1/2,\tau,8,9}$, $Q = S_{3/4,\tau,8,10}$ for the first pair and $P' = S_{1/2,\tau,8,10}$, $Q' = S_{3/4,\tau,8,9}$ for the second, writing $P(8)$ for the value of $P$'s capture curve at $8$. $\square$

This is the epistemological punchline. The mechanism claim "the knee is set by the tail, not the head" is *compatible with both signs* of the measured top-8/knee correlation. Hence the sign of that correlation — whatever it had turned out to be — carries no information about the mechanism. The study's headline evidence was, in principle, not evidence.

**Theorem 5.8 (Tail shape dominates the head).** For $1/2 < \tau < 1$ and every $N \in \mathbb{N}$ there exist profiles $P, Q$ with $P(j) = Q(j)$ for all $j \le 8$ — hence identical top-8 mass, identical head entropy, identical *any* head statistic — and $k^*(Q) \ge k^*(P) + N$.

*Proof.* Take $P = S_{1/2,\tau,8,9}$ and $Q = S_{1/2,\tau,8,9+N}$. On indices $j \le 8$ both equal $0$ (at $j=0$) or $1/2$ (the flat head), and their knees are $9$ and $9+N$. $\square$

### 5.3 Tail shape, quantitatively

Having shown the tail decides, we bound the knee by the tail's decay rate. Recall the residual $R(r) = 1 - c(r)$.

**Theorem 5.9 (Geometric tails give logarithmic knees).** Suppose $R(r+j) \le R\rho^{\,j}$ for some $R > 0$, $0 < \rho < 1$ and some particular $j$ with $R\rho^{\,j} \le 1 - \tau$. Then $k^*(\tau) \le r + j$. Consequently, for any $R>0$, $\rho \in (0,1)$ and $\tau<1$ such a $j$ exists, and one may take
$$k^*(\tau) \;\le\; r + \left\lceil \frac{\log\big(R/(1-\tau)\big)}{\log(1/\rho)} \right\rceil .$$

*Proof.* $1 - c(r+j) = R(r+j) \le R\rho^{\,j} \le 1-\tau$ gives $c(r+j) \ge \tau$, so the budget $r+j$ meets the tolerance and the minimal such budget is no larger. Existence of a suitable $j$ follows because $\rho^{\,j} \to 0$; solving $R\rho^{\,j} \le 1-\tau$ for $j$ gives the displayed ceiling. $\square$

**Theorem 5.10 (Heavy tails force late knees).** Suppose $R(r+j) \ge R/(j+1)$ for all $j \ge 0$, with $R > 0$, and $c(r) < \tau < 1$. Then
$$k^*(\tau) \;\ge\; r + \frac{R}{1-\tau} - 1 .$$

*Proof.* Write $k^*(\tau) = r + j$ (legitimate by Theorem 5.2). Then $c(r+j) \ge \tau$, i.e. $R(r+j) \le 1-\tau$; combined with the hypothesis $R/(j+1) \le R(r+j)$ we get $R/(j+1) \le 1-\tau$, i.e. $j + 1 \ge R/(1-\tau)$. $\square$

The contrast is the practical content of the mechanism. A geometric tail costs $O(\log \frac{1}{1-\tau})$ keys; a Pareto tail costs $\Theta(\frac{1}{1-\tau})$ keys and diverges as $\tau \to 1$. The head statistic is blind to which regime a domain is in — by Theorem 5.8 the two regimes can be attached to identical heads.

**Theorem 5.11 (Mechanism synthesis).** For $3/4 < \tau < 1$: (i) profiles agreeing on the tail from any index $r$ (with $c(r) < \tau$) have equal knees; (ii) for every $k > 8$ there is a profile with $c(8) = 1/2$ and knee $k$; (iii) no function sends top-8 mass to the knee. The mechanism sentence is a theorem, and the correlational evidence offered for it is not evidence.

*Proof.* Theorem 5.3, Theorem 5.5, Corollary 5.6. $\square$

---

## 6. The $\ell^2$ picture: participation ratio bounds the knee from below only

Section 5 shows that top-8 mass constrains the knee not at all. Is *some* scalar head statistic informative? The answer is a clean and complete one: yes, one-sidedly, and this is the general shape.

**Theorem 6.1 (Cauchy–Schwarz on the capture curve).** For every profile and every $k$,
$$c(k)^2 \;\le\; k \cdot C(k),$$
where $C(k) = \sum_{j<k} m_j^2$ is the collision mass.

*Proof.* $c(k) = \sum_{j<k} m_j$ by telescoping (Definition 2.3). By Cauchy–Schwarz, $\big(\sum_{j<k} 1 \cdot m_j\big)^2 \le k \sum_{j<k} m_j^2$. $\square$

**Theorem 6.2 (Participation bound at the knee).** For $0 < \tau < 1$,
$$\tau^2 \;\le\; k^*(\tau) \cdot C\big(k^*(\tau)\big).$$

*Proof.* $c(k^*(\tau)) \ge \tau > 0$, so $\tau^2 \le c(k^*(\tau))^2$; apply Theorem 6.1 at $k = k^*(\tau)$. $\square$

**Corollary 6.3 ($k^* \ge \tau^2/C$).** If a profile satisfies $C(k) \le C$ for all $k$, with $C > 0$, then
$$k^*(\tau) \;\ge\; \frac{\tau^2}{C}.$$

*Proof.* From Theorem 6.2, $\tau^2 \le k^* C(k^*) \le k^* C$; divide. $\square$

Interpreted: the reciprocal $1/C$ is the effective number of participating keys, so the bound says a domain whose attention genuinely spreads over many keys *must* have a late knee. This is a real, non-vacuous constraint — and it is sharp.

**Theorem 6.4 (Refinement of the $\ell^\infty$ law).** If every key mass satisfies $m_j \le m$ with $m \ge 0$, then $C(k) \le m$ for every $k$.

*Proof.* $C(k) = \sum_{j<k} m_j^2 \le m \sum_{j<k} m_j = m\,c(k) \le m$, using $m_j \ge 0$ and $c(k) \le 1$. $\square$

Thus the $\ell^2$ statistic sits beneath the $\ell^\infty$ one: the participation bound $k^* \ge \tau^2/C$ refines, rather than replaces, the cruder concentration law $k^* \ge \tau/m$ obtained from a bound on the single largest key mass.

**Theorem 6.5 (Attainment).** The uniform profile $U_{\tau,k}$ has key masses exactly $\tau/k$ on its first $k$ keys, hence collision mass
$$C(k) = k \cdot \Big(\frac{\tau}{k}\Big)^2 = \frac{\tau^2}{k}$$
at its own knee $k$, and therefore $k^*(\tau) \cdot C(k^*(\tau)) = k \cdot \tau^2/k = \tau^2$: Theorem 6.2 holds with equality.

*Proof sketch.* For $j < k$ the value $ (j+1)\tau/k \le \tau < 1$, so the $\min$ in the definition is inactive and consecutive differences are exactly $\tau/k$. Summing $k$ squares gives $\tau^2/k$. The knee of $U_{\tau,k}$ is $k$ because the curve first reaches $\tau$ there. In general (for prefixes beyond $k$) $C(n) \le \tau/k$, by Theorem 6.4 applied with $m = \tau/k$. $\square$

**Theorem 6.6 (One-sidedness: no upper bound).** For every collision budget $C > 0$, every $\tau \in (0,1)$ and every $N \in \mathbb{N}$, there is an attention profile whose collision mass satisfies $C(n) \le C$ for *all* $n$ and whose knee satisfies $k^*(\tau) \ge N$.

*Proof.* Choose $k \ge \max(N, \tau/C)$ with $k \ge 1$ and take $U_{\tau,k}$. Its key masses are at most $\tau/k \le C$, so by Theorem 6.4 its collision mass never exceeds $\tau/k \le C$; and its knee is exactly $k \ge N$. $\square$

**Theorem 6.7 (Participation verdict).** For $0 < \tau < 1$ and $C > 0$: every profile with collision mass bounded by $C$ has $k^*(\tau) \ge \tau^2/C$, and for every $N$ some such profile has $k^*(\tau) \ge N$. The participation ratio pins the knee from below, and not at all from above.

*Proof.* Corollary 6.3 and Theorem 6.6. $\square$

This is the structural moral of the whole paper. A concentration statistic of the head is a *lower*-bound instrument: it certifies that the knee cannot be too early. It is incapable, on its own, of certifying that the knee is not late, because mass can always be redistributed further out without changing any concentration budget. The interval $[\tau^2/C, \infty)$ left open by the bound is precisely the range over which tail shape (Theorems 5.9 and 5.10) does the deciding.

---

## 7. Algorithms

Four computations underlie the results; each is elementary and exact.

**A. Exact midrank Spearman.** Given $n$ columns of rationals: compute midranks by counting strictly-smaller and tied entries ($O(n^2)$ per column, or $O(n \log n)$ by sorting), then form $S_{xy}$, $S_{xx}$, $S_{yy}$ and report $S_{xy}/\sqrt{S_{xx}S_{yy}}$. Because $S_{xx}$ and $S_{yy}$ coincide whenever the two columns have the same tie pattern, the coefficient is often exactly rational; otherwise it is a rational multiple of $1/\sqrt{S_{xx}S_{yy}}$ and should be reported symbolically.

**B. Exhaustive tie-break sweep.** Enumerate all bijections onto $\{1,\dots,n\}$ that are strictly monotone in the data (there are $\prod_g t_g!$ of them, where $t_g$ are tie-group sizes), form all pairs across two columns, and report the interval of achievable rank covariances. Cost $O(n! \cdot n)$ naively; in practice $\prod t_g!$ is tiny.

**C. Exact permutation null.** Enumerate $S_n$, compute $D(\mu) = \sum_i (\mu(i)-i)^2$ for each, and tabulate. This yields the exact null distribution of $\rho = 1 - 6D/(n(n^2-1))$, hence the exact size of any $|\rho| \ge t$ bar and the exact one-sided $p$-value of any observed $D$. Cost $O(n! \cdot n)$; exact up to $n \approx 11$.

**D. Knee, residual, and collision mass of a capture curve.** Given $c$ as an oracle: scan $k = 0,1,2,\dots$ for the first $k$ with $c(k) \ge \tau$ (or binary-search, since $c$ is monotone: $O(\log k^*)$ oracle calls); compute key masses by differencing and collision mass by summing squares in $O(k)$.

---

## 8. Discussion

### 8.1 For practice

If the object of interest is a *memory budget*, measure the decay of the residual, not the height of the peak. Theorems 5.9 and 5.10 give the operational dichotomy: fit the residual $R(r+j)$ to $R\rho^{\,j}$ and to $R/(j+1)$, and see which fits. A geometric fit promises logarithmic growth of the budget as coverage tightens; a Pareto fit promises linear growth in $1/(1-\tau)$ and warns that aggressive pruning will be expensive at high coverage. A concentration statistic, by Theorem 6.7, can only ever tell you the budget is *at least* something.

### 8.2 For study design

Three lessons compound here.

*Recompute your coefficients.* Theorem 3.2 is arithmetic on five rows, and it inverts the conclusion. Rank statistics on tiny tables are easy to compute exactly and should always be reported as exact fractions.

*Calibrate your threshold to your $n$.* A $|\rho| \ge 0.7$ bar is a $23\%$ test at $n=5$ (Theorem 4.4). Because the achievable values of $\rho$ form a finite lattice at each $n$, the exact size of any bar is computable in advance; a pre-registration should *choose* a threshold to have a stated size rather than inherit $0.7$ by convention.

*Ask whether your statistic could have tested your mechanism.* This is the sharpest lesson, and Corollary 5.7 makes it concrete. Before running a correlation as evidence for a mechanism, ask whether the mechanism constrains the sign. Here it does not: both signs are realisable under the very mechanism proposed. A test that cannot fail is not a test.

### 8.3 On the relation between the three parts

It would be easy to read this paper as purely negative. It is not. The audit and the power calculation are corrections; the mechanism section is a positive contribution that *vindicates the study's intuition* while dissolving its evidence. The original mechanism sentence, "the knee is set by the residual spread after the top keys are captured", is Theorem 5.3 — true for every attention profile, with no measurement required. What the five-domain table added to it was noise.

The $\ell^2$ section then explains why the failure was structural rather than accidental. Any scalar head statistic that measures concentration is monotone under redistribution of mass into the tail, and the knee is not: hence the one-sidedness of Theorem 6.7. Top-8 mass, entropy, and collision mass all live on the same side of the knee.

---

## 9. Future directions

**1. A tail-exponent law for the knee.** The geometric bound $k^* \le r + \min\{j : R\rho^{\,j} \le 1-\tau\}$ and the Pareto bound $k^* \ge r + R/(1-\tau) - 1$ are the two endpoints of a single family. For a residual decaying like $R\,j^{-\alpha}$ the knee should scale as $\big(R/(1-\tau)\big)^{1/\alpha}$, interpolating the logarithmic regime ($\alpha = \infty$) and the linear one ($\alpha = 1$). Establishing the $\alpha$-family with matching upper and lower bounds would turn "tail-shape analysis" from a diagnostic into a law with a measurable exponent per domain. The staged construction of Definition 2.5 generalises directly to power-law steps, so sharpness examples should come cheaply.

**2. A ranked-data power calculus for small-$n$ mechanism claims.** The size $7/30$ is not special to $n = 5$. For each $n$ the achievable Spearman values form a finite lattice and the exact size of any $|\rho| \ge t$ bar is computable, so a pre-registration threshold can be *chosen* to have a stated size rather than inherited by convention. A general result of the form
$$\text{size}(n,t) = \frac{\#\{\mu \in S_n : |1 - 6D(\mu)/(n(n^2-1))| \ge t\}}{n!}$$
together with monotonicity in $n$ would give every future study a defensible bar. The displacement identity of Theorem 4.1 generalises verbatim.

**3. Multi-statistic bounds.** Every *individual* concentration statistic is one-sided (Theorem 6.7). Is a finite *family* of head statistics ever two-sided — that is, does knowing $c(1), \dots, c(r)$ and $C(1), \dots, C(r)$ pin the knee within a bounded interval? Theorem 5.8 says no for any $r$ fixed in advance; the interesting question is what additional tail-regularity hypothesis (e.g. log-convexity of the residual) makes a two-sided bound possible.

**4. Censored knees done properly.** Prose-fr's knee is reported as $>24$. Theorem 3.5 shows the rank statistics are insensitive to the reading, but interval-censored responses admit a sharper treatment: a partial-identification analysis reporting the *set* of coefficients consistent with all admissible readings, rather than a point value from an arbitrary imputation.

**5. Extending the empirical design.** The audited round samples five domains, three layers, and context $512$. Extending to longer contexts, more model scales, and — crucially — more domains would raise $n$ past the point where the bar has usable size. By Theorem 4.4 and its generalisation, the number of domains needed for a $5\%$ bar at $|\rho| \ge 0.7$ is a computable function of $n$; that number, not a conventional threshold, should set the design. Enumerating the null as in Algorithm C gives the exact sizes
$$\tfrac{7}{30},\ \tfrac{49}{360},\ \tfrac{37}{420},\ \tfrac{129}{2240},\ \tfrac{109}{2520} \quad\text{at}\quad n = 5,6,7,8,9,$$
so the $|\rho| \ge 0.7$ bar first becomes a genuine $5\%$ test at **nine domains**. (These five numbers come from direct enumeration rather than from a general closed form; the closed form is direction 2 above.) Sampling more layers or more windows within the same five domains does not help: $n$ counts domains.

---

## 10. Conclusion

We have audited a five-domain structural study of the attention knee in exact arithmetic and found: the three reported rank correlations are $+7/(2\sqrt{95})$, $-11/38$ and $-8/\sqrt{95}$, inverting the reported ranking of the predictors and clearing the pre-registered bar only for the predictor declared refuted; the bar itself has exact size $7/30$ at five domains, and the single result clearing it is significant at $5\%$ under one admissible tie-break and not under the other; and the mechanism the study proposed is a theorem, provable for every attention profile, whose truth makes both signs of a head-mass/knee correlation realisable and therefore renders the correlational evidence uninformative in principle. Finally, the $\ell^2$ analysis shows this is the general situation: the participation bound $k^* \ge \tau^2/C$ is attained and admits no companion upper bound, so every scalar concentration statistic of the head can constrain the knee on one side only. Where the knee actually falls is decided by the shape of the tail.
