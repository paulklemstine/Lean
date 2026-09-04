# Deterministic Localization from Summary Statistics: Dispersion Budgets, Depth–Count Trade-offs, and Exact Randomization Spectra

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

We develop a fully deterministic framework for deciding which claims about a finite sample are already settled by its published mean and standard deviation, and which genuinely require access to the raw observations. The framework rests on a single elementary inequality — a finite, distribution-free, one-sided Chebyshev bound valid in any linearly ordered field — which we read as a *dispersion budget*: the total squared deviation is a fixed resource, and each observation straying a distance $\delta$ from the centre spends $\delta^2$ of it.

Applied to a concrete fourteen-observation calibration study whose published summary is (mean $0.6282$, sample standard deviation $0.0155$) against a contractual floor of $0.60$, the framework yields four families of results. **(i) A sharp counting cap:** at most three of the fourteen observations can lie at or below the floor, and three is attained by an explicit compliant population with *strictly smaller* dispersion than recorded; the summary line therefore refutes any claim of four or more sub-floor observations, but is genuinely silent between zero and three. **(ii) A depth–count trade-off:** $k$ observations at depth $\delta$ below the centre require $k\delta^2 \le (n-1)s^2$, producing a three-rung ladder — three observations at depth $0.0282$, one at depth $0.0400$, none at depth $0.0559$ — with the middle rung attained by an explicit witness; in particular *every* observation exceeds $0.5723$, so a historically reported deep outlier near $0.55$ is arithmetically impossible. **(iii) An exact randomization theory for the paired column:** all fourteen paired differences being positive forces the one-sided sign-test $p$-value to be exactly $2^{-14}$; a change of coordinates identifies the entire randomization upper tail with a subset-sum count on the Boolean cube, and a uniform lower bound on the differences collapses that count into a binomial tail, giving a robustified $p$-value below $10^{-3}$ under an $18\%$ adversarial haircut, together with a spectral gap of $8.9\%$ of the total mass at the top of the randomization distribution. **(iv) A two-sided uniformity band and a forced correlation:** the paired summary confines every observation's difference to $(0.066, 0.1454)$, and the exact paired-dispersion identity forces an observation-level correlation of at least $0.74$ between the two settings.

We close with a falsifiable affine forecast: over the full Cartesian product of the recorded centre interval and the recorded slope interval, the model's floor crossing lies strictly in $(3.68, 3.87)$.

**Keywords:** one-sided Chebyshev bound, dispersion budget, sharp counting cap, depth–count trade-off, exact randomization test, subset-sum spectrum, paired variance reduction, forced correlation, falsifiable forecast.

---

## 1. Introduction

### 1.1 The inferential problem

A results table reports a mean, a standard error, a confidence interval, a sample standard deviation, and — sometimes — a count of observations violating a threshold. A reader who trusts the table but has no access to the raw observations faces a natural question: *which claims about the underlying sample does this table already decide?*

The question is usually treated as vague. It is not. For a fixed sample size $n$ and a fixed centre $m$ and total squared deviation $\mathrm{SS}$, the set of admissible samples is an explicit compact algebraic set — a sphere of radius $\sqrt{\mathrm{SS}}$ inside the hyperplane $\sum x_i = nm$ — and any question about the sample becomes a question about the extremes of a function on that sphere. Some questions have an answer that is constant on the whole sphere; those are *decided by the table*. Others vary; those *require the raw column*.

This paper carries out that programme completely for a concrete study, and the answers are neither uniformly "yes" nor uniformly "no". The table decides more than one might expect (no deep outlier, no insensitive observation, a correlation floor of $0.74$) and less than one might hope (it cannot distinguish zero sub-floor observations from three).

### 1.2 The study

A quality score $\mathrm{sp}(u)$ depends on a control parameter $u$; a design contract requires $\mathrm{sp}(u) \ge 0.60$. An earlier round of testing, at low per-population sample size, reported sub-floor readings at $u = 3.5$, including one strikingly deep one. A replication with five times the per-population sample size and fourteen fresh independent populations returned:

| quantity | value |
|---|---|
| mean of $\mathrm{sp}(3.5)$ | $0.6282$ |
| standard error | $0.0041$ |
| $95\%$ interval | $[0.6204,\ 0.6363]$ |
| sample standard deviation | $0.0155$ |
| sub-floor populations | $0/14$ |
| mean paired drop $\Delta = \mathrm{sp}(2.5) - \mathrm{sp}(3.5)$ | $0.1057$ |
| paired interval | $[0.0999,\ 0.1112]$ |
| positive drops | $14/14$ |

Two hypotheses were under test. **H1** (the centre lies below the floor) is refuted by the interval. **H2** (the centre is above the floor but the tail is wide enough for individual populations to breach it) is a statement about the tail, and it is exactly the hypothesis whose fate the summary line does not obviously determine.

### 1.3 Contributions

1. A finite, distribution-free one-sided dispersion bound valid over any linearly ordered field (Theorem 2.1), with a one-line proof.
2. A sharp counting cap at the recorded numbers, together with an explicit attaining witness, giving the exact epistemic characterisation of the summary line (Theorems 3.1–3.4).
3. A depth–count trade-off and a sharp three-rung depth ladder, including a no-deep-outlier theorem (Theorems 4.1–4.5).
4. An exact randomization theory for the paired column: exact $p = 2^{-n}$, a subset-sum correspondence for the entire tail, a binomial-tail collapse under a uniform bound, a robustified $p$-value, and a spectral gap (Theorems 5.1–5.7).
5. A two-sided uniformity band and a forced-correlation bound from the exact paired-dispersion identity (Theorems 6.1–6.3).
6. A falsifiable affine floor-crossing forecast, uniform over the recorded interval box, and a standard-error consistency audit (Theorems 7.1–7.4).

---

## 2. The dispersion budget

Throughout, $n \ge 1$ is a fixed integer and $x = (x_1, \dots, x_n)$ is a finite family of elements of a linearly ordered field $K$ (in the applications, $K = \mathbb{Q}$ or $K = \mathbb{R}$).

**Definition 2.1 (Total squared deviation).** For a centre $m \in K$,
$$\mathrm{SS}(x; m) \;=\; \sum_{i=1}^{n} (x_i - m)^2 .$$
We write $\bar{x} = \tfrac1n\sum_i x_i$ for the sample mean and $\mathrm{SS}(x) = \mathrm{SS}(x; \bar{x})$. The sample standard deviation $s$ is defined by $\mathrm{SS}(x) = (n-1)s^2$.

**Definition 2.2 (Below-count).** For a level $c \in K$,
$$N_{\le}(x; c) \;=\; \#\{\, i : x_i \le c \,\} .$$

**Theorem 2.1 (Finite one-sided dispersion bound).** *For any centre $m$ and any level $c < m$,*
$$N_{\le}(x; c) \cdot (m - c)^2 \;\le\; \mathrm{SS}(x; m).$$

*Proof.* Let $S = \{ i : x_i \le c\}$. For $i \in S$ we have $0 < m - c \le m - x_i$, hence $(m-c)^2 \le (x_i - m)^2$ by monotonicity of squaring on nonnegatives. Summing over $S$,
$$|S| \cdot (m-c)^2 = \sum_{i \in S}(m-c)^2 \;\le\; \sum_{i \in S}(x_i - m)^2 \;\le\; \sum_{i=1}^n (x_i-m)^2,$$
the last step because the omitted terms are squares, hence nonnegative. $\square$

**Remarks.** (a) No probability is involved. The statement is about a finite list of field elements; it holds verbatim over $\mathbb{Q}$, which is what allows the numerical instantiations below to be exact rational arithmetic rather than floating-point.

(b) The right reading is a **budget**: $\mathrm{SS}$ is a fixed resource, and an observation at distance $\delta$ from the centre consumes $\delta^2$ of it. Deviation is quadratically priced. This single asymmetry — depth quadratic, count linear — drives every trade-off in Sections 3–4.

(c) A trivial but decisive specialisation isolates a single observation.

**Lemma 2.2 (Single-observation budget).** *For every index $i$ and every centre $m$,*
$$(x_i - m)^2 \;\le\; \mathrm{SS}(x; m).$$

*Proof.* A single term of a sum of nonnegative terms. $\square$

Lemma 2.2 beats Theorem 2.1 whenever only one observation is in question, because Theorem 2.1 with $N_\le = 1$ gives the same bound but requires the level to be specified in advance.

---

## 3. The counting cap and its sharpness

Fix the recorded constants
$$n = 14, \qquad m = 0.6282, \qquad s = 0.0155, \qquad \text{floor } c_0 = 0.60 .$$
The dispersion budget is
$$B \;=\; (n-1)s^2 \;=\; 13 \times 0.0155^2 \;=\; 0.00312325 ,$$
and the margin to the floor is $m - c_0 = 0.0282$, with squared margin $0.00079524$.

**Theorem 3.1 (Sub-floor cap).** *Let $x \in \mathbb{Q}^{14}$ satisfy $\mathrm{SS}(x; 0.6282) \le 13 \times 0.0155^2$. Then*
$$N_{\le}(x; 0.60) \;\le\; 3 .$$

*Proof.* By Theorem 2.1 with $m = 0.6282$ and $c = 0.60$,
$$N_\le(x; 0.60) \times 0.00079524 \;\le\; \mathrm{SS}(x; m) \;\le\; 0.00312325 ,$$
so $N_\le(x;0.60) \le 3.9275\ldots$, and being an integer, $N_\le(x;0.60) \le 3$. $\square$

The hypothesis is deliberately about the deviation *from the recorded centre*, not about the sample's own mean; this is the weaker and more useful assumption, since a table's reported centre and its sample's mean coincide only when the sample is exactly on-target. (The witness below satisfies both.)

**Definition 3.2 (The counting witness).** Let $w \in \mathbb{Q}^{14}$ be
$$w_i = \begin{cases} 0.5999, & i \in \{1,2,3\},\\[2pt] \dfrac{69951}{110000} = 0.635918\overline{18}, & 4 \le i \le 14 .\end{cases}$$

**Theorem 3.3 (Sharpness).** *The population $w$ satisfies*
$$\bar{w} = 0.6282 \text{ exactly}, \qquad \mathrm{SS}(w; 0.6282) = \frac{1681869}{550000000} = 0.00305794\ldots \;<\; B, \qquad N_\le(w; 0.60) = 3 .$$
*In particular the sample standard deviation of $w$ is $0.015337\ldots < 0.0155$.*

*Proof.* Direct rational arithmetic: $3 \times 0.5999 + 11 \times \tfrac{69951}{110000} = 14 \times 0.6282$, so the mean is exact. Each of the first three terms contributes $(0.6282 - 0.5999)^2 = 0.0283^2$ and each of the remaining eleven contributes $(0.635918\overline{18} - 0.6282)^2$; summing gives the stated rational. Finally $0.5999 \le 0.60 < 0.635918\ldots$ gives the count. $\square$

**Theorem 3.4 (Exact epistemic content of the summary line).**
1. *There exists a fourteen-observation population with exactly the recorded mean, strictly smaller dispersion than recorded, and three sub-floor observations.*
2. *Every fourteen-observation population within the recorded dispersion has at most three sub-floor observations.*

*Consequently $3$ is the greatest element of the set of achievable sub-floor counts compatible with the recorded summary, and the recorded pair is consistent with sub-floor counts $0, 1, 2, 3$ and with no others.*

*Proof.* (1) is Theorem 3.3; (2) is Theorem 3.1. Counts $0,1,2$ are realised by obvious modifications of $w$ (move sub-floor observations above the floor, redistributing mass, which only decreases dispersion). Maximality is (2). $\square$

**Interpretation.** The observed $0/14$ is *strictly more informative* than the published $(\text{mean}, \text{sd})$ pair. Hypothesis **H2** cannot be refuted from the table: a compliant population with three breaches exists, and it is *quieter* than the recorded one. Conversely, any assertion of four or more breaches is refuted by the table alone, with no seed-level data.

This is a "wrong instrument" failure rather than a "false hypothesis" failure. At $n = 14$, the sample standard deviation simply does not resolve tail questions at the scale of one-fifth of the sample. The design lesson is to publish the threshold-violation count — as this study did — precisely because it is not recoverable.

---

## 4. Depth: the trade-off and the ladder

**Theorem 4.1 (No deep outlier).** *Let $x \in \mathbb{Q}^{14}$ satisfy $\mathrm{SS}(x; 0.6282) \le 13 \times 0.0155^2$. Then for every $i$,*
$$x_i \;>\; 0.5723 .$$

*Proof.* Suppose $x_i \le 0.5723$. Then $0.6282 - x_i \ge 0.0559$, so $(x_i - 0.6282)^2 \ge 0.0559^2 = 0.00312481$. By Lemma 2.2 this is at most $B = 0.00312325$, a contradiction since $0.00312481 > 0.00312325$. $\square$

The margin in that final comparison is $1.56 \times 10^{-6}$ — thin, but exact rational arithmetic makes thinness irrelevant. The precise threshold is $0.6282 - \sqrt{0.00312325} = 0.572314\ldots$

**Corollary 4.2.** *A reading of $0.55$ — the magnitude reported in the earlier low-sample-size round — cannot occur in any population compatible with the recorded summary.* The historical claim that the earlier deep outlier "has no analogue" at five times the sample size is thus a theorem about two published numbers, not an observation about the new raw data.

**Theorem 4.3 (Depth–count trade-off).** *Let $x \in \mathbb{Q}^{14}$ satisfy $\mathrm{SS}(x; 0.6282) \le B$, and let $\delta > 0$. Then*
$$N_{\le}(x;\, 0.6282 - \delta) \cdot \delta^2 \;\le\; B \;=\; 0.00312325 .$$

*Proof.* Theorem 2.1 with $c = m - \delta$, noting $m - c = \delta$, chained with the dispersion hypothesis. $\square$

**Theorem 4.4 (The depth ladder).** *Under the hypothesis of Theorem 4.3:*

| depth $\delta$ | bound on $N_\le(x; m - \delta)$ | reason | status |
|---|---|---|---|
| $0.0282$ (the floor) | $\le 3$ | $B/\delta^2 = 3.9275$ | attained (Theorem 3.3) |
| $0.0400$ | $\le 1$ | $B/\delta^2 = 1.952$ | attained (Theorem 4.5) |
| $0.0559$ | $= 0$ | $B/\delta^2 = 0.99950 < 1$ | vacuous by Theorem 4.1 |

*Proof.* Each row is Theorem 4.3 with the stated $\delta$, followed by integrality. For the third row, $B/0.0559^2 < 1$ forces the count to be $0$. $\square$

**Definition/Theorem 4.5 (The middle rung is attained).** Let
$$v_i = \begin{cases} 0.5882, & i = 1, \\[2pt] \dfrac{41033}{65000} = 0.63127692\ldots, & 2 \le i \le 14 .\end{cases}$$
*Then $\bar{v} = 0.6282$ exactly, $\mathrm{SS}(v; 0.6282) = \tfrac{14}{8125} = 0.00172307\ldots < B$, and exactly one observation of $v$ lies at or below $0.6282 - 0.04 = 0.5882$. Combined with Theorem 4.4, the bound "at most one observation at depth $0.04$" is sharp.*

*Proof.* $0.5882 + 13 \times \tfrac{41033}{65000} = 14 \times 0.6282$ by rational arithmetic. The deviation sum is $0.04^2 + 13\left(\tfrac{41033}{65000} - 0.6282\right)^2 = \tfrac{14}{8125}$. The single sub-threshold observation is $v_1 = 0.5882$, and $v_i > 0.5882$ for $i \ge 2$. $\square$

Note that $v_1 = 0.5882$ sits $0.0118$ *below the contractual floor*: the summary line permits one genuine, non-trivial breach at depth $0.04$, but never two, and never one at depth $0.056$.

**Structural remark.** The ladder makes explicit the asymmetric pricing of Section 2: the maximal count at depth $\delta$ is $\lfloor B/\delta^2 \rfloor$, decaying quadratically in $\delta$. A "many shallow breaches" story is therefore far harder to exclude from a summary line than a "one catastrophic breach" story. Practitioners auditing summary tables should expect exactly this asymmetry.

---

## 5. The paired column: exact randomization inference

We now turn to the second recorded column, the paired difference $\Delta_i = \mathrm{sp}_i(2.5) - \mathrm{sp}_i(3.5)$, with all fourteen values positive.

### 5.1 The exact sign test

**Definition 5.1 (Signed sum).** For $d \in \mathbb{R}^n$ and a sign vector $s \in \{\pm\}^n$ (encoded as $s : \{1,\dots,n\} \to \{\texttt{true},\texttt{false}\}$),
$$T_d(s) \;=\; \sum_{i=1}^n \begin{cases} d_i, & s_i = \texttt{true},\\ -d_i, & s_i = \texttt{false}.\end{cases}$$
The observed statistic is $T_d(\mathbf{1}) = \sum_i d_i$, where $\mathbf{1}$ is the all-true vector.

Under the sharp null "the parameter label carries no information", the pair $(\mathrm{sp}_i(2.5), \mathrm{sp}_i(3.5))$ is exchangeable within each observation, so the randomization distribution of the statistic is the uniform distribution of $T_d(s)$ over the $2^n$ sign vectors.

**Lemma 5.2 (Monotonicity).** *If $d_i \ge 0$ for all $i$ then $T_d(s) \le \sum_i d_i$ for every $s$.*

*Proof.* Termwise: $-d_i \le d_i$ when $d_i \ge 0$. $\square$

**Lemma 5.3 (Strictness).** *If $d_i > 0$ for all $i$ and $s \ne \mathbf{1}$, then $T_d(s) < \sum_i d_i$.*

*Proof.* Pick $j$ with $s_j = \texttt{false}$; then the $j$-th term is $-d_j < d_j$, while all other terms are $\le$; a sum with one strict inequality is strict. $\square$

**Theorem 5.4 (Exact one-sided randomization $p$-value).** *If $d_i > 0$ for all $i$, then*
$$\#\Big\{\, s \in \{\pm\}^n \;:\; T_d(s) \ge \textstyle\sum_i d_i \,\Big\} = 1, \qquad\text{hence}\qquad p \;=\; \frac{1}{2^n}.$$

*Proof.* By Lemma 5.3 the extreme set is contained in $\{\mathbf{1}\}$, and $\mathbf{1}$ belongs to it trivially, so it is exactly $\{\mathbf{1}\}$. Divide by $2^n$. $\square$

**Corollary 5.5.** *At $n = 14$ with all drops positive, $p = 1/16384 = 6.1035\ldots \times 10^{-5} < 10^{-4}$.*

The $p$-value is **exact**, not asymptotic, and uses no distributional hypothesis whatsoever: strict positivity of fourteen numbers is the entire input.

### 5.2 The randomization tail as a subset-sum spectrum

Theorem 5.4 sees only the maximum. The whole upper tail has a clean combinatorial description.

**Definition 5.6.** For a sign vector $s$, let $F(s) = \{ i : s_i = \texttt{false}\}$ be its *flip set*, and for $S \subseteq \{1,\dots,n\}$ let $M_d(S) = \sum_{i \in S} d_i$ be the *mass* of $S$.

**Theorem 5.7 (Coordinate change).** *For every $d$ and every $s$,*
$$T_d(s) \;=\; \sum_{i=1}^n d_i \;-\; 2\,M_d\big(F(s)\big) .$$

*Proof.* Split the sum defining $T_d(s)$ over $F(s)$ and its complement. On $F(s)$ the terms are $-d_i$; on the complement they are $+d_i$. Writing $\sum_i d_i = M_d(F(s)) + \sum_{i \notin F(s)} d_i$ and substituting gives the claim. $\square$

Thus the randomization statistic is an *affine image of a subset sum*; the $2^n$ sign vectors are the vertices of the Boolean cube; and "at least as extreme as observed" is the intersection of the cube with a half-space.

**Theorem 5.8 (Subset-sum correspondence).** *For every threshold $t \in \mathbb{R}$,*
$$\#\Big\{\, s : T_d(s) \ge \textstyle\sum_i d_i - 2t \,\Big\} \;=\; \#\big\{\, S \subseteq \{1,\dots,n\} \;:\; M_d(S) \le t \,\big\} .$$

*Proof.* The map $s \mapsto F(s)$ is a bijection from sign vectors to subsets, with inverse $S \mapsto (i \mapsto [\,i \notin S\,])$. By Theorem 5.7 the defining conditions correspond exactly. $\square$

Two consequences deserve emphasis. First, this explains why exact randomization $p$-values are computationally hard in general: counting subsets with bounded sum is $\#\mathrm{P}$-hard. Second, it explains why the degenerate case $t = 0$ of Theorem 5.4 is trivially easy: only the empty subset has zero mass when all $d_i > 0$.

**Theorem 5.9 (Binomial-tail collapse).** *Suppose $d_i \ge c > 0$ for all $i$, and let $k \in \mathbb{N}$ satisfy $t < c(k+1)$. Then*
$$\#\{\, S : M_d(S) \le t \,\} \;\le\; \sum_{j=0}^{k} \binom{n}{j} .$$

*Proof.* If $|S| \ge k+1$ then $M_d(S) \ge |S| \cdot c \ge c(k+1) > t$, so $S$ does not qualify. Hence the qualifying family is contained in the union over $j \le k$ of the $j$-element subsets, whose cardinalities sum to $\sum_{j\le k}\binom{n}{j}$. $\square$

**Theorem 5.10 (Spectral gap at the top).** *If $d_i \ge c > 0$ for all $i$, then for every $s \ne \mathbf{1}$,*
$$T_d(s) \;\le\; \sum_i d_i - 2c .$$

*Proof.* $F(s)$ is nonempty, so $M_d(F(s)) \ge c$; apply Theorem 5.7. $\square$

### 5.3 Instantiation at the recorded paired numbers

Section 6 supplies the uniform bound $d_i > 0.066$. With $c = 0.066$, $n = 14$, $t = 0.13$: since $t = 0.13 < 2c = 0.132$, Theorem 5.9 applies with $k = 1$, giving at most $\binom{14}{0} + \binom{14}{1} = 15$ qualifying sign vectors.

**Theorem 5.11 (Robustified $p$-value).** *If $d_i \ge 0.066$ for all $i = 1,\dots,14$, then at most $15$ of the $2^{14} = 16384$ sign vectors satisfy $T_d(s) \ge \sum_i d_i - 0.26$; hence*
$$p_{\text{robust}} \;\le\; \frac{15}{16384} = 9.155\ldots \times 10^{-4} \;<\; 10^{-3} .$$

The haircut of $0.26$ is $18\%$ of the total observed drop mass $14 \times 0.1057 = 1.4798$. So the significance is not a knife-edge: an adversary may erode nearly a fifth of the total effect and the conclusion survives at the $10^{-3}$ level.

**Theorem 5.12 (Numerical spectral gap).** *With $c = 0.066$, every sign vector other than the observed one falls at least $2c = 0.132$ below the observed statistic — a gap of $0.132/1.4798 = 8.92\%$ of the total mass.*

The observed statistic is an *isolated* maximum of the randomization distribution, not a marginal one. This isolation is the structural reason the paired comparison is decisive while the unpaired floor question (Section 3) is not: the unpaired question has a continuum of compliant populations with different answers, whereas the paired question has a discrete spectrum with a gap at the top.

---

## 6. Uniformity of the effect and the correlation it forces

### 6.1 The two-sided uniformity band

Let the paired column have recorded mean $\mu_\Delta = 0.1057$ and paired sample standard deviation $s_\Delta \le 0.0110$ (the value implied by the recorded paired interval $[0.0999, 0.1112]$, whose half-width $0.00565$ corresponds to a standard error $\approx 0.00291$ and hence $s_\Delta \approx 0.0109$). The paired dispersion budget is
$$B_\Delta = 13 \times 0.0110^2 = 0.001573, \qquad \sqrt{B_\Delta} = 0.0396611\ldots$$

**Theorem 6.1 (Two-sided uniformity band).** *Let $d \in \mathbb{Q}^{14}$ satisfy $\mathrm{SS}(d; 0.1057) \le 13 \times 0.0110^2$. Then for every $i$,*
$$0.066 \;<\; d_i \;<\; 0.1454 .$$

*Proof.* By Lemma 2.2, $(d_i - 0.1057)^2 \le B_\Delta = 0.001573$. If $d_i \le 0.066$ then $0.1057 - d_i \ge 0.0397$, so $(d_i - 0.1057)^2 \ge 0.0397^2 = 0.00157609 > 0.001573$, a contradiction. Symmetrically, if $d_i \ge 0.1454$ then $d_i - 0.1057 \ge 0.0397$ and the same contradiction follows. $\square$

**Interpretation.** The lower half is "degrades everywhere" as a theorem: no observation loses less than $0.066$, which is $62.4\%$ of the mean drop. The upper half rules out the complementary explanation — that a small number of hypersensitive observations carry the mean while most are nearly flat. The degradation is uniform *from both sides*. Together with Theorem 5.12, this refutes any "single bad seed" account twice over: no observation is deep enough to be an outlier in level (Theorem 4.1), and no observation is extreme enough to be an outlier in slope (Theorem 6.1).

### 6.2 The exact paired-dispersion identity

**Definition 6.2.** For columns $a, b \in \mathbb{R}^n$ write $\mathrm{SS}(a) = \sum_i (a_i - \bar{a})^2$ and $\mathrm{SP}(a,b) = \sum_i (a_i - \bar{a})(b_i - \bar{b})$.

**Theorem 6.3 (Paired dispersion identity).** *For all $a, b$,*
$$\mathrm{SS}(a - b) \;=\; \mathrm{SS}(a) + \mathrm{SS}(b) - 2\,\mathrm{SP}(a,b).$$

*Proof.* $\overline{a-b} = \bar{a} - \bar{b}$, so $(a_i - b_i) - \overline{a-b} = (a_i - \bar{a}) - (b_i - \bar{b})$. Expand the square termwise and sum. $\square$

**Corollary 6.4 (Pairing works iff the columns are positively correlated).** *$\mathrm{SS}(a-b) < \mathrm{SS}(a) + \mathrm{SS}(b)$ if and only if $\mathrm{SP}(a,b) > 0$.*

**Theorem 6.5 (Forced correlation).** *Suppose both columns have the recorded dispersion $\mathrm{SS}(a) = \mathrm{SS}(b) = 13 \times 0.0155^2$, and the difference column satisfies $\mathrm{SS}(a-b) \le 13 \times 0.0110^2$. Then*
$$\frac{\mathrm{SP}(a,b)}{\mathrm{SS}(a)} \;\ge\; 0.74 .$$

*Proof.* By Theorem 6.3, $\mathrm{SP}(a,b) = \tfrac12\left(\mathrm{SS}(a) + \mathrm{SS}(b) - \mathrm{SS}(a-b)\right) \ge \mathrm{SS}(a) - \tfrac12 \times 13 \times 0.0110^2$. Dividing by $\mathrm{SS}(a) = 13 \times 0.0155^2 > 0$,
$$\frac{\mathrm{SP}(a,b)}{\mathrm{SS}(a)} \;\ge\; 1 - \frac{0.0110^2}{2 \times 0.0155^2} \;=\; 1 - 0.25182\ldots \;=\; 0.74818\ldots \;\ge\; 0.74. \qquad\square$$

Since $\mathrm{SS}(a) = \mathrm{SS}(b)$, the left-hand side is exactly the Pearson correlation of the two columns. So the *narrowness of the published paired interval* — a purely reported quantity — forces a correlation floor of $0.74$ between the two settings.

**Scientific reading.** The observation-level scores at the two settings move together, separated by a nearly constant offset. Performance is governed by a shared latent quality of each population rather than by setting-specific idiosyncrasy. Remediation therefore has a *single* target — the uniform $\approx 0.11$ offset — and no benefit is available from identifying and excluding "bad" populations.

A route we tried and abandoned: bounding this correlation without a variance-reduction hypothesis. Cauchy–Schwarz alone gives only $|\mathrm{SP}| \le \sqrt{\mathrm{SS}(a)\mathrm{SS}(b)}$, which is vacuous here. The paired interval width is the *only* source of the $0.74$ bound, so it must appear as a hypothesis.

---

## 7. The affine model, its crossing, and an audit

### 7.1 The crossing

**Definition 7.1.** The affine model anchored at $u = 3.5$ with centre $m$ and per-unit loss $b$ is
$$L_{m,b}(u) \;=\; m - b\,(u - 3.5) .$$

**Theorem 7.2 (Unique crossing).** *If $b > 0$ then $L_{m,b}$ is strictly decreasing, and there is a unique $u^\star$ with $L_{m,b}(u^\star) = 0.60$, namely*
$$u^\star = 3.5 + \frac{m - 0.60}{b} .$$

*Proof.* Strict antitonicity: $u < v \Rightarrow b(u - 3.5) < b(v-3.5) \Rightarrow L(u) > L(v)$. Existence: substitute and simplify. Uniqueness: $L(u) = 0.60$ forces $b(u - 3.5) = m - 0.60$, and $b \ne 0$ permits division. $\square$

**Theorem 7.3 (Point forecast).** *At $m = 0.6282$ and $b = 0.1057$,*
$$L(3.766) > 0.60 > L(3.767), \qquad u^\star = 3.76679\ldots$$
*Moreover $L(3.5) = 0.6282 > 0.60$ and $L(4.0) = 0.6282 - 0.1057 \times 0.5 = 0.57535 < 0.60$: the model predicts safety at $u = 3.5$ (margin $+0.0282$) and breach at $u = 4.0$ (margin $-0.0246$ relative to the floor after rounding of the loss estimate; exactly $-0.02465$).*

**Theorem 7.4 (Uniform forecast window over the interval box).** *For every $m \in [0.6204, 0.6363]$ and every $b \in [0.0999, 0.1112]$,*
$$3.68 \;<\; 3.5 + \frac{m - 0.60}{b} \;<\; 3.87 .$$

*Proof.* Since $b \ge 0.0999 > 0$ and $m - 0.60 \in [0.0204, 0.0363]$, the ratio is at least $0.0204/0.1112 = 0.18345\ldots > 0.18$ and at most $0.0363/0.0999 = 0.36336\ldots < 0.37$. Add $3.5$. $\square$

This is a genuinely falsifiable prediction: the forecast excludes a breach at $u = 3.5$ (matching the observed verdict) and equally excludes survival at $u = 4.0$. A single population above the floor at $u = 4.0$, or a single population below it at $u = 3.6$, refutes the affine model — not merely the point estimate, but the model over the *entire* recorded interval box.

### 7.2 The standard-error audit

**Theorem 7.5 (Standard-error consistency).** $\left| \dfrac{0.0155}{\sqrt{14}} - 0.0041 \right| < 5 \times 10^{-5}.$

*Proof.* From $3.7416^2 = 13.99956\ldots < 14 < 14.00031\ldots = 3.7417^2$, we get $3.7416 < \sqrt{14} < 3.7417$, whence $0.0155/3.7417 < 0.0155/\sqrt{14} < 0.0155/3.7416$, i.e. $0.00414243 < 0.0155/\sqrt{14} < 0.00414254$. Subtracting $0.0041$ gives a value in $(4.24\times10^{-5}, 4.26\times10^{-5})$, which is below $5 \times 10^{-5}$. $\square$

**Theorem 7.6 (Interval width).** *The recorded interval half-width is $(0.6363 - 0.6204)/2 = 0.00795$. Measured against the exact $s/\sqrt{n} = 0.0041425\ldots$ this is $1.9191\ldots$ standard errors; measured against the published, rounded $0.0041$ it is $1.9390\ldots$. In either case the ratio lies strictly between $1.91$ and $1.94$.*

Hence the reported uncertainty is the ordinary $s/\sqrt{n}$, and the interval is an ordinary two-sided $95\%$ interval rather than an inflated resampling artefact. The resampling procedure added no extra width, closing the last route by which "the interval excludes the floor" could have been an artefact of the estimation method rather than a property of the data.

---

## 8. Algorithms

Every result above is effective. We record the three computational primitives.

**Algorithm A (Maximal breach count from a summary line).** Given $n$, $m$, $s$, and a threshold $c < m$, return $\left\lfloor \frac{(n-1)s^2}{(m-c)^2} \right\rfloor$, capped at $n$. This is the exact maximal number of observations at or below $c$ compatible with the summary, by Theorems 2.1 and 3.4. Cost: $O(1)$.

**Algorithm B (Ladder construction and witness synthesis).** Given $n$, $m$, $s$, and a depth $\delta$, compute $k = \min(n, \lfloor (n-1)s^2/\delta^2 \rfloor)$; then synthesise an attaining witness by placing $k$ observations at $m - \delta'$ for a $\delta'$ slightly exceeding $\delta$ and the remaining $n-k$ at $m + k\delta'/(n-k)$, which has mean exactly $m$ and dispersion $k\delta'^2\left(1 + \frac{k}{n-k}\right)$; verify the dispersion is within budget. Cost: $O(1)$ arithmetic; exact in rational arithmetic.

**Algorithm C (Randomization tail counting, exact and bounded).** Given $d \in \mathbb{R}^n_{>0}$ and a tolerance $t$: the exact count is $\#\{S : M_d(S) \le t\}$, computable by a $2^n$ enumeration or a meet-in-the-middle $O(2^{n/2})$ split; the certified upper bound is $\sum_{j \le k}\binom{n}{j}$ where $k = \lceil t/\min_i d_i \rceil - 1$, computable in $O(n)$. The gap between the two quantifies how much the uniform bound $c = \min_i d_i$ costs relative to the exact enumeration.

---

## 9. Discussion

### 9.1 The verdict as decided by the summary line

Consolidating: the two published numbers $(0.6282, 0.0155)$ over fourteen observations, plus the paired pair $(0.1057, \le 0.0110)$, settle the following.

| claim | decided by the summary? |
|---|---|
| four or more sub-floor observations | **refuted** |
| zero versus three sub-floor observations | **undecided** (both compliant) |
| any observation below $0.5723$ | **refuted** |
| two or more observations at depth $\ge 0.04$ | **refuted** |
| one observation at depth $0.04$ | **undecided** (compliant witness exists) |
| any observation with drop $\le 0.066$ or $\ge 0.1454$ | **refuted** |
| correlation between settings below $0.74$ | **refuted** |
| the interval width is a resampling artefact | **refuted** |

Hypothesis H1 dies by arithmetic. Hypothesis H2 survives the summary line and dies only at the observation level. "Single bad seed" dies twice by the summary line.

### 9.2 A methodological principle

The reason H2 survives the summary line while "single bad seed" does not is the quadratic pricing of deviation. A hypothesis that concentrates deviation into few observations is cheap to refute from a variance figure; a hypothesis that spreads it is not. The general principle:

> *A variance-based summary resolves questions about the extremes of a sample well, and questions about the moderate tail poorly, with the crossover at depth $\sqrt{\mathrm{SS}/k}$ for $k$ the number of observations in question.*

At $n = 14$ with the recorded dispersion, the crossover for a fifth of the sample is precisely at the floor margin — which is exactly why this study was ambiguous at the summary level and why publishing the violation count was necessary rather than decorative.

### 9.3 Scope and limitations

All results are deterministic statements about finite lists of numbers compatible with reported summaries. They do not, and cannot, address whether the reported summaries are themselves accurate estimates of a population quantity; that is a separate question requiring the usual sampling assumptions. The paired standard deviation $0.0110$ is inferred from the reported interval width under the assumption that the interval is $\pm 1.96$ standard errors; Theorem 7.6 supplies the corresponding audit for the unpaired column, and an analogous audit should accompany any use of Theorems 6.1 and 6.5.

The affine model of Section 7 is a modelling assumption, not a derived fact. Its value is that it is *sharply falsifiable over the entire recorded interval box*, so that a single well-designed follow-up experiment either confirms it or destroys it.

---

## 10. Future work

Three concrete directions follow.

**Direct test of the crossing.** Run the same fourteen-population design at $u = 4.0$. The affine forecast predicts a population mean below $0.60$ and a substantial fraction of sub-floor populations. A confirmed breach at $u = 4.0$ together with the confirmed safety at $u = 3.5$ brackets the crossing to within the forecast window; a survival at $u = 4.0$ falsifies the affine model and demands a convex correction term.

**Beyond variance: which statistic resolves the tail?** Section 3 shows the sample standard deviation is the wrong instrument for a tail question at $n = 14$. The natural replacement is a higher-moment or order-statistic summary. A precise version of the problem: which single additional published scalar — the sample range, the third central moment, the minimum, the median — most tightly narrows the admissible interval $\{0,1,2,3\}$ of sub-floor counts? The answer is computable by optimising over the same compact algebraic set, and would give a concrete recommendation for what results tables should carry.

**Sharpening the randomization tail.** Theorem 5.9 replaces a subset-sum count with a binomial tail using only $\min_i d_i$. Using the full uniformity band of Theorem 6.1 — an upper bound as well as a lower one — should give matching two-sided control on the tail and, for suitable tolerances, an exact count rather than a bound. More ambitiously, the subset-sum correspondence of Theorem 5.8 suggests that concentration results for random subset sums transfer directly into finite-sample statements about randomization tails, an exchange that appears not to have been exploited systematically.

**Generalising the ladder.** The depth ladder of Theorem 4.4 is the discrete profile $\delta \mapsto \lfloor \mathrm{SS}/\delta^2\rfloor$. Characterising exactly which such profiles are simultaneously attainable by a *single* population — the full "deviation profile" compatible with a summary line, rather than one rung at a time — is a finite-dimensional extremal problem whose answer would give the complete epistemic content of a variance figure in one statement.

---

## Appendix: numerical constants

| quantity | exact value | decimal |
|---|---|---|
| unpaired dispersion budget $13 \times 0.0155^2$ | $312325/10^8$ | $0.00312325$ |
| floor margin $0.6282 - 0.60$ | $282/10^4$ | $0.0282$ |
| squared floor margin | $79524/10^8$ | $0.00079524$ |
| cap ratio | — | $3.9275\ldots \Rightarrow 3$ |
| maximal single-observation depth $\sqrt{B}$ | — | $0.055886\ldots$ |
| no-deep-outlier threshold | — | $> 0.5723$ |
| counting witness value | $69951/110000$ | $0.635918\overline{18}$ |
| counting witness dispersion | $1681869/(5.5\times10^8)$ | $0.00305794\ldots$ |
| depth witness value | $41033/65000$ | $0.63127692\ldots$ |
| depth witness dispersion | $14/8125$ | $0.00172307\ldots$ |
| paired budget $13 \times 0.0110^2$ | $157300/10^8$ | $0.0015730$ |
| paired single-observation bound | — | $0.0396611\ldots$ |
| uniformity band | — | $(0.066,\ 0.1454)$ |
| total drop mass $14 \times 0.1057$ | — | $1.4798$ |
| robust haircut / total | $0.26/1.4798$ | $17.57\%$ |
| spectral gap / total | $0.132/1.4798$ | $8.92\%$ |
| robust tail bound | $\binom{14}{0}+\binom{14}{1}$ | $15/16384 = 9.155\times10^{-4}$ |
| forced correlation | $1 - 0.0110^2/(2\cdot 0.0155^2)$ | $0.74818\ldots$ |
| point crossing | $3.5 + 0.0282/0.1057$ | $3.76679\ldots$ |
| forecast window | $[3.5+0.0204/0.1112,\ 3.5+0.0363/0.0999]$ | $[3.6835,\ 3.8634]$ |
| standard error check | $0.0155/\sqrt{14}$ | $0.00414254\ldots$ |
