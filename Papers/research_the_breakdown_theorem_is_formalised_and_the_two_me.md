# The Finite-Sample Breakdown Theorem for the Median: Sharpness, Optimality, and a Coding-Theoretic Bridge

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We give a complete, self-contained, finite-sample account of the robustness of the sample median against adversarial replacement contamination, together with three independent proofs that its robustness threshold is exactly $\lceil n/2 \rceil$.

Working with datasets as length-$n$ vectors of rationals and with contamination measured by Hamming distance, we prove: (i) a **counting stability lemma** — the number of entries satisfying any predicate changes by at most the Hamming distance — from which the entire robustness half follows in two lines; (ii) the **breakdown half**: if $2k < n$, every median of every $k$-contamination is sandwiched between two uncontaminated observations, hence lies in any a priori interval containing the honest data; (iii) the **sharpness half**: if $k \le n \le 2k$, overwriting the first $k$ entries with any prescribed value $t$ makes $t$ a median. Together these give an exact criterion, `boundedness under budget $k$ $\iff$ $2k<n$`, and identify the breakdown number of the median as exactly $\lceil n/2\rceil$, against the mean's breakdown number of $1$.

We then prove three structural theorems that explain the threshold. A **Donoho–Huber equivariance shear** shows that $\lceil n/2\rceil$ is a *universal ceiling*: every translation-equivariant estimator becomes unbounded at budget $\lceil n/2\rceil$. The **lower sample median**, a genuine single-valued equivariant estimator, attains this ceiling. A complete computation of the **order-statistic breakdown profile** shows that the $j$-th order statistic has breakdown number exactly $\min(j+1,\,n-j)$, a concave tent whose unique maximiser (up to the even-$n$ tie) is the median index. Finally, a **coding-theoretic bridge** identifies the breakdown threshold with a unique-decoding radius: for $c \ne 0$ the two-word translation code $\{x, x+c\}$ has minimum Hamming distance $n$, and the median breaks down under budget $k$ if and only if that code fails unique decoding at radius $k$.

All results are instantiated on two measured normalised distributions arising from three-channel count triples: a $16$-sample run and an $8$-sample run, both with median $73/200 = 0.365$, with breakdown numbers exactly $8$ and $4$ and explicit worst-case intervals $[0.32, 0.41]$ and $[0.33, 0.40]$.

**Keywords:** breakdown point, sample median, adversarial contamination, Hamming distance, order statistics, translation equivariance, unique decoding, robust statistics.

---

## 1. Introduction

### 1.1 The question

A location estimator is a rule $T$ that condenses a dataset $x = (x_1,\dots,x_n)$ into a single number. The *finite-sample replacement breakdown number* of $T$ at $x$, introduced by Donoho and Huber, is the least number $k$ of entries an adversary must be allowed to overwrite — with arbitrary values, chosen with full knowledge of $x$ and of $T$ — in order to drive $T$ arbitrarily far from any preassigned bound. It is the crudest robustness measure available: it does not quantify *how much* an estimator moves under small perturbations, only *when it stops carrying any information at all*. Its crudeness is also its virtue, because it requires no probabilistic model whatsoever. The guarantees below are absolute, worst-case, and finite-sample; there are no asymptotics, no distributional assumptions, and no "with high probability".

Folklore says the mean has breakdown point $0$ and the median $1/2$. This paper proves both statements exactly, in the strong two-sided form (a robustness half *and* a matching sharpness half with no gap between them), and then asks the two natural follow-up questions: *can any estimator do better than the median?* (no) and *why is the answer a half?* (three different reasons, which turn out to be the same reason).

### 1.2 Contributions

1. **A minimal combinatorial core.** The counting stability lemma (Lemma 3.1) is the only nontrivial ingredient in the robustness half. It is an induction on list length and it makes no reference to order, sorting, or the real line.
2. **Two-sided exactness.** Theorem 5.1 is an if-and-only-if, so the threshold is not an artefact of a lossy argument.
3. **Universal optimality.** Theorem 6.2 shows $\lceil n/2 \rceil$ is a ceiling for *all* translation-equivariant estimators, and Theorem 7.4 exhibits a concrete single-valued estimator attaining it.
4. **The full quantile landscape.** Theorem 8.4 computes the breakdown number of every order statistic, exhibiting the median as the unique maximiser of a concave profile.
5. **A bridge to coding theory.** Theorem 9.4 identifies breakdown with failure of unique decoding for the translation orbit, showing that the two thresholds are literally the same combinatorial quantity.
6. **Instantiation on measured data.** Section 10 makes all of the above concrete on two measured normalised distributions.

### 1.3 Conventions

We work over $\mathbb{Q}$ throughout. This is not a restriction of substance — every argument is order-theoretic and combinatorial, and works verbatim over any linearly ordered abelian group — but it makes every statement in the paper a *finitely checkable* statement about exact arithmetic, with no rounding and no floating-point pathology. A **dataset** is a finite sequence $x = (x_1,\dots,x_n) \in \mathbb{Q}^n$; we write $|x| = n$ for its length. Cardinalities of index sets are written $\#\{\cdot\}$ and count with multiplicity over positions, not values.

---

## 2. The contamination model

**Definition 2.1 (Hamming distance).** For datasets $x, y$ of the same length $n$, set
$$d_H(x,y) \;=\; \#\{\, i \in \{1,\dots,n\} : x_i \ne y_i \,\}.$$

**Definition 2.2 ($k$-contamination).** Given a dataset $x$ of length $n$ and a budget $k \in \mathbb{N}$, a *$k$-contamination of $x$* is any dataset $y$ with $|y| = |x|$ and $d_H(x,y) \le k$.

The model is *replacement* contamination: the sample size is preserved and the adversary substitutes values in place. Nothing is assumed about which positions are corrupted or how the substituted values are chosen; in particular the adversary may see all of $x$ and may know the estimator being used.

**Lemma 2.3 (metric properties).** $d_H$ is symmetric, satisfies $d_H(x,x) = 0$, satisfies $d_H(x,y) \le n$, obeys the triangle inequality $d_H(x,z) \le d_H(x,y) + d_H(y,z)$ for datasets of equal length, and $d_H(x,y) = 0$ implies $x = y$.

*Proof sketch.* Each is a coordinatewise induction. For the triangle inequality, at each position the indicator inequality $[x_i \ne z_i] \le [x_i \ne y_i] + [y_i \ne z_i]$ holds by case analysis on whether $x_i = y_i$, and the induction hypothesis handles the tails. $\square$

**Lemma 2.4 (splitting).** If $|a| = |b|$, then $d_H(a \frown c,\; b \frown d) = d_H(a,b) + d_H(c,d)$, where $\frown$ denotes concatenation.

*Proof sketch.* Induction on $a$; the equal lengths guarantee the two concatenations align position by position. $\square$

Lemma 2.4 is the workhorse behind every explicit attack below: each attack modifies a *prefix* or *suffix* of the sample, and the splitting lemma prices it exactly.

---

## 3. The counting stability lemma

**Lemma 3.1 (Counting Stability).** Let $P$ be any predicate on $\mathbb{Q}$ and let $x,y$ be datasets of the same length. Then
$$\#\{\,i : P(y_i)\,\} \;\le\; \#\{\,i : P(x_i)\,\} \;+\; d_H(x,y).$$

*Proof sketch.* Induct on the length. For the empty dataset both sides are $0$. For a cons step $x = (x_1, x')$, $y = (y_1, y')$, the induction hypothesis gives the bound for the tails. If $x_1 = y_1$ the head contributes the same amount to both counts and $0$ to the distance. If $x_1 \ne y_1$ the head contributes at most $1$ to the left count and $1$ to the distance, so the inequality is preserved in all four sign patterns. $\square$

By symmetry of $d_H$ the reverse bound holds as well, so the two counts differ by at most $d_H(x,y)$. Lemma 3.1 is the entire mathematical content of the robustness half of the breakdown theorem: *replacing $d$ entries destroys at most $d$ witnesses of any property*.

---

## 4. Medians and the breakdown half

**Definition 4.1 (median).** A rational $m$ is a *median* of the dataset $x$ of length $n$, written $\mathrm{Med}(x,m)$, if
$$n \;\le\; 2\,\#\{i : x_i \le m\}
\qquad\text{and}\qquad
n \;\le\; 2\,\#\{i : m \le x_i\}.$$

This is the order-statistic-free definition. For odd $n$ it determines $m$ uniquely; for even $n$ it determines a closed interval, namely $[x_{(n/2)}, x_{(n/2+1)}]$ in terms of order statistics. We deliberately do **not** impose a tie-breaking convention: every theorem below quantifies over *all* medians of the contaminated sample, so no guarantee can be smuggled in by a choice of convention. The predicate is decidable, so all instances on explicit data are finite computations.

**Theorem 4.2 (Quantitative Robustness).** Let $x,y$ have the same length $n$, let $d = d_H(x,y)$, and let $m$ be any median of $y$. Then
$$n \;\le\; 2\,\#\{i : x_i \le m\} + 2d
\qquad\text{and}\qquad
n \;\le\; 2\,\#\{i : m \le x_i\} + 2d.$$

*Proof.* Apply Lemma 3.1 with $P(\cdot) = (\cdot \le m)$ to get $\#\{i : y_i \le m\} \le \#\{i : x_i \le m\} + d$, and combine with $n \le 2\#\{i : y_i \le m\}$ from Definition 4.1. The second inequality is identical with $P(\cdot) = (m \le \cdot)$. $\square$

**Theorem 4.3 (Breakdown Half — the two-sided sandwich).** Let $x, y$ have the same length $n$ with $2\,d_H(x,y) < n$, and let $m$ be any median of $y$. Then there exist indices $i, j$ with
$$x_i \;\le\; m \;\le\; x_j.$$

*Proof.* By Theorem 4.2, $2\#\{i : x_i \le m\} \ge n - 2d > 0$, so the set $\{i : x_i \le m\}$ is non-empty; pick $i$ in it. Symmetrically for $j$. $\square$

**Corollary 4.4 (Interval robustness).** If in addition every honest observation lies in $[a,b]$, then $a \le m \le b$.

*Proof.* $a \le x_i \le m \le x_j \le b$ by Theorem 4.3 and transitivity. $\square$

Corollary 4.4 is the form used in practice: it says the corrupted median cannot escape the *observed range of the clean data*, whatever the adversary does with strictly fewer than half the entries.

---

## 5. The sharpness half and the exact breakdown number

**Definition 5.1 (prefix contamination).** For a dataset $x$, a budget $k \le n$, and a target $t \in \mathbb{Q}$, let
$$x^{(k,t)} \;=\; (\underbrace{t,\dots,t}_{k},\; x_{k+1},\dots,x_n).$$

**Lemma 5.2.** $|x^{(k,t)}| = n$ and $d_H(x, x^{(k,t)}) \le k$.

*Proof.* Both are immediate from Lemma 2.4 applied to the split of $x$ at position $k$: the suffix contributes distance $0$ and the prefix contributes at most its length $k$. $\square$

**Theorem 5.3 (Sharpness Half).** If $k \le n \le 2k$ then for every $t \in \mathbb{Q}$, the dataset $x^{(k,t)}$ is a $k$-contamination of $x$ and $t$ is a median of it.

*Proof.* Legality is Lemma 5.2. At least $k$ entries of $x^{(k,t)}$ equal $t$, hence
$$\#\{i : x^{(k,t)}_i \le t\} \ge k \quad\text{and}\quad \#\{i : t \le x^{(k,t)}_i\} \ge k .$$
Since $n \le 2k$, both median conditions of Definition 4.1 hold. $\square$

Note how little the attack needs: it does not look at the data, does not sort, and does not depend on $t$ being extreme. Once the adversary owns half the positions, *every* value is simultaneously a median.

**Definition 5.4 (bounded median under budget $k$).** Say the median of $x$ is *bounded under budget $k$* if there exists $B \in \mathbb{Q}$ such that for every $k$-contamination $y$ of $x$ and every median $m$ of $y$ one has $|m| \le B$.

**Theorem 5.5 (Breakdown Theorem — exact criterion).** For every non-empty dataset $x$ of length $n$ and every $k \in \mathbb{N}$:
$$\text{the median of } x \text{ is bounded under budget } k \iff 2k < n.$$

*Proof.* ($\Leftarrow$) All entries of $x$ lie in $[-B, B]$ for $B = \max_i |x_i|$; apply Corollary 4.4.

($\Rightarrow$) Suppose $2k \ge n$ and a bound $B$ existed. Put $k' = \min(k, n)$, so $k' \le n \le 2k'$ (using $n \ge 1$ and $2k \ge n$). Take the target $t = |B| + 1$. By Theorem 5.3, $t$ is a median of the $k'$-contamination $x^{(k',t)}$, which is also a $k$-contamination since $k' \le k$. But $|t| = |B|+1 > B$, contradicting the bound. $\square$

**Definition 5.6 (breakdown number).** The *breakdown number* of an estimator at $x$ is the least budget $k$ at which it is not bounded — the least element of $\{k : \text{not bounded under budget } k\}$. (This set is upward closed, so a least element is a genuine threshold.)

**Corollary 5.7.** For every non-empty $x$ of length $n$, the breakdown number of the median is exactly
$$k^\star(n) \;=\; \Big\lfloor \tfrac{n+1}{2} \Big\rfloor \;=\; \Big\lceil \tfrac{n}{2} \Big\rceil .$$

*Proof.* By Theorem 5.5 the failure set is $\{k : 2k \ge n\}$, whose least element is $\lceil n/2\rceil$. $\square$

The *breakdown point* is $k^\star(n)/n \to 1/2$.

**Theorem 5.8 (The mean breaks at one).** Let $\bar{x} = \frac1n\sum_i x_i$. For every non-empty $x$ and every bound $B$ there is a $1$-contamination $y$ of $x$ with $|\bar y| > B$. Consequently the breakdown number of the mean is exactly $1$.

*Proof.* Replace $x_1$ by $c = n(|B|+1) - \sum_{i\ge 2} x_i$; then $\bar y = |B| + 1 > B$. The distance is at most $1$. Conversely, under budget $0$ the only contamination is $x$ itself (Lemma 2.3), so the mean is trivially bounded; hence the least failing budget is $1$. $\square$

---

## 6. The universal ceiling: no equivariant estimator beats the median

**Definition 6.1.** An estimator $T : \bigcup_n \mathbb{Q}^n \to \mathbb{Q}$ is *translation equivariant* if for every non-empty $x$ and every $c \in \mathbb{Q}$,
$$T(x_1 + c,\dots,x_n+c) \;=\; T(x) + c .$$
$T$ is *bounded on $x$ under budget $k$* if some $B$ satisfies $|T(y)| \le B$ for every $k$-contamination $y$ of $x$.

Equivariance is the defining property of a location estimator: the answer must not depend on the choice of origin. The mean, all order statistics, trimmed and Winsorised means, the midrange, and maximum-likelihood location estimates are all equivariant.

**Theorem 6.2 (Breakdown ceiling; Donoho–Huber shear).** Let $T$ be translation equivariant, $x$ non-empty of length $n$, and $k$ a budget with $2k \ge n$. Then $T$ is unbounded on $x$ under budget $k$.

*Proof.* Fix a candidate bound $B$ and set $c = 2|B| + 1$. Let $m = n - k$ and define
$$y \;=\; \big(x_1,\dots,x_m,\; x_{m+1}+c,\dots,x_n+c\big), \qquad
z \;=\; \big(x_1 - c,\dots,x_m - c,\; x_{m+1},\dots,x_n\big).$$
By Lemma 2.4, $d_H(x,y) \le n - m = k$ and $d_H(x,z) \le m = n-k \le k$, the latter using $2k \ge n$; so both are legal $k$-contaminations of $x$. But $y$ is obtained from $z$ by adding $c$ to *every* coordinate, so equivariance gives
$$T(y) \;=\; T(z) + c .$$
If $|T(y)| \le B$ and $|T(z)| \le B$ then $c = T(y) - T(z) \le 2B \le 2|B|$, contradicting $c = 2|B|+1$. $\square$

The hypothesis $2k \ge n$ enters at exactly one point: it is what makes both halves of the shear affordable out of a single budget $k$. That is the whole reason the constant is $1/2$ and not something else.

**Corollary 6.3.** Every translation-equivariant estimator has breakdown number at most $\lceil n/2 \rceil$ on every non-empty dataset of length $n$.

**Corollary 6.4 (Optimality of the median).** The median attains the ceiling: its breakdown number is $\lceil n/2\rceil$ (Corollary 5.7) and no translation-equivariant estimator exceeds $\lceil n/2\rceil$ (Corollary 6.3).

---

## 7. A concrete single-valued optimal estimator

Definition 4.1 makes the median a *set*. One may object that the ceiling of Corollary 6.4 is only interesting if a bona fide function attains it. It does.

**Definition 7.1 (lower sample median).** Let $x^{\uparrow}$ denote $x$ sorted non-decreasingly. Define
$$\mathrm{lmed}(x) \;=\; x^{\uparrow}_{\lfloor (n-1)/2 \rfloor} \qquad (0\text{-indexed}),$$
i.e. the $\lceil n/2\rceil$-th smallest observation.

Two facts about sorted samples do all the work; here $s = x^\uparrow$ and $s_j$ is $0$-indexed.

**Lemma 7.2 (sorted counting).** For $j < n$: $\;\#\{i : s_i \le s_j\} \ge j+1$ and $\#\{i : s_j \le s_i\} \ge n - j$.

*Proof sketch.* The first $j+1$ entries of $s$ are all $\le s_j$ and the last $n-j$ are all $\ge s_j$, by pairwise sortedness; counts over a prefix or suffix bound the count over the whole list. Sorting is a permutation, so counts computed on $s$ agree with counts on $x$. $\square$

**Theorem 7.3.** For non-empty $x$: (i) $\mathrm{lmed}(x)$ is a median of $x$ in the sense of Definition 4.1; (ii) $\mathrm{lmed}$ is translation equivariant.

*Proof sketch.* (i) Apply Lemma 7.2 at $j = \lfloor (n-1)/2\rfloor$: it gives $\#\{i : x_i \le \mathrm{lmed}(x)\} \ge \lfloor (n-1)/2\rfloor + 1 = \lceil n/2 \rceil$ and $\#\{i : \mathrm{lmed}(x) \le x_i\} \ge n - \lfloor (n-1)/2 \rfloor = \lceil (n+1)/2 \rceil$, and both are $\ge n/2$. (ii) Adding a constant is an order isomorphism, so $(x + c)^{\uparrow} = x^{\uparrow} + c$ by uniqueness of the sorted permutation; reading off position $\lfloor (n-1)/2\rfloor$ gives $\mathrm{lmed}(x+c) = \mathrm{lmed}(x)+c$. $\square$

**Theorem 7.4.** The breakdown number of $\mathrm{lmed}$ at any non-empty $x$ is exactly $\lceil n/2 \rceil$, so $\mathrm{lmed}$ attains the universal ceiling of Corollary 6.3.

*Proof sketch.* The upper bound is Corollary 6.3 via Theorem 7.3(ii). For the lower bound, if $2k < n$ then $\mathrm{lmed}(y)$ is a median of $y$ (Theorem 7.3(i)) for every $k$-contamination $y$, hence is trapped in the range of $x$ by Corollary 4.4. $\square$

---

## 8. The full order-statistic breakdown profile

Why the *middle* order statistic? The following computes the answer for all of them at once. Let $T_j(x) = x^{\uparrow}_j$, $0$-indexed, with the index clamped to $n-1$ so that $T_j$ is total and equivariant.

The engine is a pair of *converse* sandwich lemmas, which read a bound on an order statistic off a mere count. They are what makes the sharpness half constructive without ever exhibiting a sorted list.

**Lemma 8.1 (count $\Rightarrow$ upper bound).** If $j < n$ and $\#\{i : x_i \le t\} \ge j+1$, then $T_j(x) \le t$.

*Proof sketch.* Suppose $T_j(x) = s_j > t$. By sortedness every entry from position $j$ onward exceeds $t$, so all witnesses of "$\le t$" lie in the prefix $s_0,\dots,s_{j-1}$, giving $\#\{i : x_i \le t\} \le j$, a contradiction. $\square$

**Lemma 8.2 (count $\Rightarrow$ lower bound).** If $j < n$ and $\#\{i : t \le x_i\} \ge n-j$, then $t \le T_j(x)$.

*Proof sketch.* Dual: if $s_j < t$ then every entry in the prefix $s_0,\dots,s_j$ is $< t$, so all witnesses of "$\ge t$" lie in the suffix of length $n - j - 1$. $\square$

**Theorem 8.3 (robustness of $T_j$).** If $j < n$, $k \le j$ and $k < n - j$, then $T_j$ is bounded on $x$ under budget $k$; indeed $T_j(y)$ lies in $[\min_i x_i, \max_i x_i]$ for every $k$-contamination $y$.

*Proof sketch.* Let $m = T_j(y)$. Lemma 7.2 applied to $y$ gives $\#\{i : y_i \le m\} \ge j+1$ and $\#\{i : m \le y_i\} \ge n-j$. Transporting both counts back to $x$ by Lemma 3.1 costs $k$ each, leaving $\#\{i : x_i \le m\} \ge j+1-k > 0$ and $\#\{i : m \le x_i\} \ge n-j-k > 0$. So $m$ is sandwiched between honest observations. $\square$

**Theorem 8.4 (exact profile).** For $j < n$, the breakdown number of $T_j$ at any dataset of length $n$ is exactly
$$\beta(j) \;=\; \min\,(\,j+1,\; n-j\,).$$

*Proof sketch.* Boundedness for $k < \beta(j)$ is Theorem 8.3. For unboundedness at $k = \beta(j)$, take a candidate bound $B$ and split on which term achieves the minimum. If $j + 1 \le n - j$, flood the first $j+1$ positions with $t = -(|B|+1)$: the contaminated sample has $\#\{i : y_i \le t\} \ge j+1$, so Lemma 8.1 gives $T_j(y) \le t < -B$. If $n - j \le j+1$, flood the first $n-j$ positions with $t = |B|+1$: then $\#\{i : t \le y_i\} \ge n-j$, so Lemma 8.2 gives $T_j(y) \ge t > B$. Both attacks cost at most $\beta(j)$ by Lemma 5.2. $\square$

**Theorem 8.5 (the median index is the maximiser).** For all $j < n$, $\beta(j) \le \lceil n/2\rceil$, with equality at $j = \lfloor (n-1)/2 \rfloor$:
$$\max_{0 \le j < n} \min(j+1,\,n-j) \;=\; \Big\lceil \tfrac n2 \Big\rceil, \qquad
\min\Big(\big\lfloor \tfrac{n-1}{2}\big\rfloor + 1,\; n - \big\lfloor \tfrac{n-1}{2}\big\rfloor\Big) = \Big\lceil \tfrac n2 \Big\rceil .$$

*Proof.* Elementary integer arithmetic: $\min(a,b) \le \lceil (a+b)/2 \rceil$ applied to $a = j+1$, $b = n-j$ with $a+b = n+1$; substituting the median index makes the two arguments differ by at most one. $\square$

The profile $\beta$ is a discrete **tent**: $\beta(0) = \beta(n-1) = 1$ (the sample extremes are exactly as fragile as the mean), $\beta$ increases by one per step towards the centre, and peaks at the median index — uniquely, up to the two-way tie when $n$ is even. So the median is not merely a good quantile; it is the unique maximiser of a concave profile, and the value it attains coincides with the universal ceiling of Corollary 6.3. The two optimality statements are logically independent (one is *within* the order-statistic family, one is *across all* equivariant estimators) and they agree.

---

## 9. Breakdown as a unique-decoding radius

The number $n$ in the criterion $2k < n$ is not merely the sample size; it is a **minimum distance**.

**Definition 9.1 (translation code).** For a dataset $x$ of length $n$ and a shift $c \ne 0$, the *translation code* of $x$ is the two-word code $\mathcal{C}_c(x) = \{x,\; x+c\}$, where $x+c = (x_1+c,\dots,x_n+c)$.

**Lemma 9.2 (minimum distance).** For $c \ne 0$, $d_H(x,\, x+c) = n$.

*Proof.* $x_i \ne x_i + c$ for every $i$. $\square$

A global shift is the maximally "spread out" perturbation: it touches every coordinate, so the translation code has the largest possible minimum distance.

**Definition 9.3 (confusability).** $x$ and $x+c$ are *confusable at radius $k$* if some dataset $w$ of length $n$ satisfies $d_H(x,w) \le k$ and $d_H(x+c, w) \le k$ — i.e. some single observed dataset is consistent with both hypotheses under budget $k$.

**Theorem 9.4 (Unique-decoding criterion).** For $c \ne 0$ and any $k$:
$$x \text{ and } x+c \text{ are confusable at radius } k \iff n \le 2k .$$

*Proof.* ($\Rightarrow$) By Lemmas 2.3 and 9.2, $n = d_H(x, x+c) \le d_H(x,w) + d_H(w, x+c) \le 2k$.
($\Leftarrow$) Let $m = n-k$ and set $w = (x_1+c,\dots,x_m+c,\; x_{m+1},\dots,x_n)$. By Lemma 2.4, $d_H(x, w) \le m = n-k \le k$ (using $n \le 2k$) and $d_H(x+c, w) \le n - m = k$. $\square$

This is precisely the classical unique-decoding criterion $2k < d$ for a code of minimum distance $d$, specialised to $d = n$.

**Theorem 9.5 (Bridge Theorem).** For every non-empty $x$, every $c \ne 0$, and every $k$:
$$\text{the median of } x \text{ breaks down under budget } k
\iff
\mathcal{C}_c(x) \text{ fails unique decoding at radius } k .$$

*Proof.* Combine Theorem 5.5 ($\text{bounded} \iff 2k<n$) with Theorem 9.4 ($\text{confusable} \iff n \le 2k$); the two conditions are negations of one another. $\square$

The consequence is conceptual rather than merely formal. A statistician's breakdown point and a coding theorist's decoding radius are not analogues; on the translation code they are the *same integer computed by the same inequality*. Robust location estimation is decoding: the honest sample is the transmitted word, the adversary is the channel, translation equivariance is the ambiguity the code must resolve, and the median is a decoder achieving the channel's limit. Together with the order-statistic tent (Section 8) and the equivariance shear (Section 6), this is the third independent structure forcing the threshold to $2k = n$.

---

## 10. Two measured normalised distributions

We instantiate the theory on measured data. Each measurement is a triple of raw counts $(a,b,c)$ in three channels; the recorded statistic is the normalised first coordinate
$$r(a,b,c) \;=\; \frac{a}{a+b+c}.$$

**The 16-sample run** consists of the triples
$$\begin{aligned}
&(37,41,22),\,(35,43,22),\,(38,40,22),\,(36,42,22),\,(34,44,22),\,(39,39,22),\,(33,45,22),\,(40,38,22),\\
&(36,41,23),\,(37,40,23),\,(35,42,23),\,(38,39,23),\,(34,43,23),\,(39,38,23),\,(41,37,22),\,(32,46,22),
\end{aligned}$$
each summing to $100$, hence the normalised readings
$$R_{16} = (0.37,\,0.35,\,0.38,\,0.36,\,0.34,\,0.39,\,0.33,\,0.40,\,0.36,\,0.37,\,0.35,\,0.38,\,0.34,\,0.39,\,0.41,\,0.32).$$

**The 8-sample run** consists of the first eight triples, giving
$$R_{8} = (0.37,\,0.35,\,0.38,\,0.36,\,0.34,\,0.39,\,0.33,\,0.40).$$

**Proposition 10.1 (medians).** $73/200 = 0.365$ is a median of $R_{16}$ and a median of $R_8$.

*Proof.* Direct count. Sorted, $R_{16}$ is $0.32,0.33,0.34,0.34,0.35,0.35,0.36,0.36,0.37,0.37,0.38,0.38,0.39,0.39,0.40,0.41$, so exactly $8$ of the $16$ entries are $\le 0.365$ and exactly $8$ are $\ge 0.365$; both median inequalities hold with equality. Similarly $R_8$ sorted is $0.33,\dots,0.40$ with $4$ entries on each side. (In both cases the median *interval* is $[0.36, 0.37]$, of which $0.365$ is the midpoint.) $\square$

**Proposition 10.2 (ranges).** Every entry of $R_{16}$ lies in $[8/25,\, 41/100] = [0.32,\, 0.41]$, and every entry of $R_8$ lies in $[33/100,\, 2/5] = [0.33,\, 0.40]$.

**Theorem 10.3 (robustness, 16 samples).** Let $y$ have length $16$ with $d_H(R_{16}, y) \le 7$, and let $m$ be any median of $y$. Then $0.32 \le m \le 0.41$.

*Proof.* $2 \cdot 7 = 14 < 16$; apply Corollary 4.4 with Proposition 10.2. $\square$

**Theorem 10.4 (sharpness, 16 samples).** For every $t \in \mathbb{Q}$, the dataset $R_{16}^{(8,t)}$ has length $16$, satisfies $d_H(R_{16}, R_{16}^{(8,t)}) \le 8$, and has $t$ as a median.

*Proof.* Theorem 5.3 with $n = 16$, $k = 8$. $\square$

**Theorem 10.5 (robustness and sharpness, 8 samples).** If $d_H(R_8,y) \le 3$ and $m$ is any median of $y$ (with $|y| = 8$), then $0.33 \le m \le 0.40$. For every $t$, the dataset $R_8^{(4,t)}$ is a $4$-contamination of $R_8$ with median $t$.

**Corollary 10.6 (breakdown numbers).** The breakdown number of the median is exactly $8$ on $R_{16}$ and exactly $4$ on $R_8$; the breakdown point is $1/2$ in both cases.

**Corollary 10.7 (no alternative helps).** No translation-equivariant estimator is bounded on $R_{16}$ under budget $8$, nor on $R_8$ under budget $4$. The median's tolerance of $7$ (respectively $3$) corrupted measurements is maximal.

*Proof.* Theorem 6.2 with $2 \cdot 8 \ge 16$ and $2 \cdot 4 \ge 8$. $\square$

**Corollary 10.8 (the profile on the measured data).** On $R_{16}$ the $j$-th order statistic has breakdown number exactly $\min(j+1, 16-j)$, peaking at $8$ for $j = 7$; on $R_8$ it is $\min(j+1,8-j)$, peaking at $4$ for $j=3$. In particular on $R_{16}$ the sample minimum $0.32$ and the sample maximum $0.41$ have breakdown number $1$ — exactly as fragile as the mean.

**Corollary 10.9 (confusability thresholds).** For every $c \ne 0$: $R_{16}$ is confusable with $R_{16}+c$ at radius $8$ but not at radius $7$; $R_8$ is confusable with $R_8 + c$ at radius $4$ but not at radius $3$. These thresholds coincide with the breakdown numbers of Corollary 10.6.

Everything in this section is a *finite computation on the measured triples*; there is no estimation, no model, and no probabilistic caveat.

---

## 11. Algorithms

The theory is entirely constructive, and each theorem has a direct algorithmic counterpart. Throughout, $n$ is the sample size.

**Algorithm A (median verification).** Given $x$ and $m$, compute $\#\{i : x_i \le m\}$ and $\#\{i : m \le x_i\}$ in a single pass and test both inequalities of Definition 4.1. Cost: $O(n)$ comparisons, exact rational arithmetic, no sorting.

**Algorithm B (breakdown number).** By Corollary 5.7 the answer for the median is $\lceil n/2 \rceil$ — an $O(1)$ formula. The interest is in *certifying* it, which Algorithms C and D do.

**Algorithm C (robustness certificate).** Given $x$ and a budget $k$ with $2k < n$, output the interval $[\min_i x_i, \max_i x_i]$ together with the count-based witness of Theorem 4.2: for any purported contaminated median $m$, the pass computes $\#\{i : x_i \le m\}$ and checks $2\#\{i : x_i \le m\} + 2k \ge n$. Cost: $O(n)$.

**Algorithm D (optimal attack).** Given $x$, a budget $k$ with $2k \ge n$ and a target $t$, output $x^{(k,t)}$. This is the *witness* of Theorem 5.3 and runs in $O(n)$. For a general order statistic $T_j$ under budget $\beta(j)$, output the flood of $j+1$ copies of a large negative value if $j+1 \le n-j$, else the flood of $n-j$ copies of a large positive value (Theorem 8.4).

**Algorithm E (order-statistic profile).** Sort once ($O(n\log n)$) and then report, for each $j$, the pair $(x^\uparrow_j,\ \min(j+1, n-j))$. This is the complete robustness landscape of the sample in $O(n \log n)$ total.

**Algorithm F (confusing word).** Given $x$, $c \ne 0$ and $k$ with $n \le 2k$, output $w$ that shifts the first $n-k$ coordinates by $c$ and leaves the rest, as in Theorem 9.4. Then $d_H(x,w) \le k$ and $d_H(x+c,w) \le k$: an explicit certificate that the two hypotheses are indistinguishable. Cost: $O(n)$.

**Algorithm G (empirical breakdown search).** For a black-box equivariant estimator $T$ and a dataset $x$, evaluate $T$ on the shear pair $(y,z)$ of Theorem 6.2 for increasing $k$ and report the first $k$ where $|T(y) - T(z)|$ exceeds a chosen threshold. Theorem 6.2 guarantees this fires no later than $k = \lceil n/2\rceil$, so the search is an $O(n)$-step certified probe.

---

## 12. Discussion

### 12.1 What the model does and does not assume

The results are worst-case and finite-sample. The adversary is *omniscient* (may see $x$ and $T$), *unconstrained* (substituted values are arbitrary), and *positionally free*. There is no probability space anywhere in the development. The price for this strength is that breakdown is a coarse criterion: it detects total failure, not degradation. An estimator with breakdown point $1/2$ can still be badly biased by a single outlier of moderate size — the breakdown number is a statement about *boundedness*, not about *accuracy*. A finer analysis would use the maximum bias curve $\sup\{|T(y) - T(x)| : d_H(x,y)\le k\}$, whose value at $k = \lceil n/2 \rceil - 1$ is exactly what Corollary 4.4 bounds by the sample range.

### 12.2 Three proofs of the same constant

That the threshold is $1/2$ has three visibly different explanations here, and it is worth naming the shared skeleton. In each case the sample splits into two blocks of sizes $m$ and $n-m$, and the adversary needs to afford whichever block is smaller:

| Structure | Object being split | Threshold condition |
|---|---|---|
| Order-statistic tent (§8) | low tail of size $j+1$ vs high tail of size $n-j$ | $\beta(j) = \min(j+1, n-j) \le \lceil n/2\rceil$ |
| Equivariance shear (§6) | head of size $m$ vs tail of size $n-m$, translated apart | $\min(m, n-m) \le k$, i.e. $2k \ge n$ |
| Hamming distance (§9) | prefix corrupted towards $x$ vs suffix towards $x+c$ | $d_H(x,x+c) = n \le 2k$ |

In all three the binding constraint is $\min(m, n-m) \le k$, maximised over $m$ at $m = \lceil n/2 \rceil$. The threshold is thus a statement about the *pigeonhole geometry of splitting a finite set in two* — which is why it is a half, and why it is the same half every time.

### 12.3 Relation to distributional breakdown

Classically the breakdown point is often defined for $\varepsilon$-contamination neighbourhoods of a distribution. The finite-sample replacement version used here is the sharper and more elementary one: it yields exact integers rather than limiting fractions, it requires no measure theory, and its guarantees apply to the dataset actually in hand rather than to a hypothetical population. Corollary 5.7 recovers the classical value $1/2$ in the limit while giving the exact integer $\lceil n/2\rceil$ at every finite $n$ — including the parity phenomenon that an even sample of size $n$ and an odd sample of size $n-1$ have the same breakdown number.

### 12.4 Practical reading

The single most useful statement for a practitioner is Corollary 4.4: *if fewer than half the entries are corrupted, then every median of the corrupted data lies within the range of the clean data*. It requires knowing only a bound on the honest observations — often available a priori from physical constraints, as with the normalised ratios of Section 10, which are confined to $[0,1]$ by construction. The dual statement, Theorem 5.3, is equally useful as a warning: at exactly half, no amount of statistical sophistication rescues the estimate, because Theorem 6.2 rules out every equivariant alternative simultaneously.

This is the barrier that governs Byzantine-robust distributed learning (coordinate-wise median aggregation of gradient updates), robust sensor fusion, and consensus over reported numerical values. In each case the "half" is not a heuristic but the exact combinatorial threshold proved above.

---

## 13. Future directions

The threshold $2k = n$ was forced here by three independent structures — an order-statistic tent, an equivariance shear, and a Hamming minimum distance. The directions below are the conjectures that this triple coincidence suggests.

### D1. Concave breakdown profiles for L-estimators

**Conjecture.** For a weight vector $w = (w_0,\dots,w_{n-1})$ of non-negative rationals with $\sum_j w_j = 1$, the L-estimator $T_w(x) = \sum_j w_j\, T_j(x)$ has breakdown number exactly
$$\min\{\,j+1 : w_{j'} > 0 \text{ for some } j' \le j\,\} \ \wedge\ \min\{\,n-j : w_{j'} > 0 \text{ for some } j' \ge j\,\},$$
i.e. the tent profile $\beta$ evaluated at the extreme support points of $w$; the profile of an L-estimator is the pointwise minimum of the profiles of the order statistics it charges.

**Key insight.** The proven order-statistic profile $\min(j+1, n-j)$ (Theorem 8.4) is not an accident of the median but a *support functional*: contamination can only reach an L-estimator through the extremal order statistics its weights touch, so the profile of a mixture collapses to the minimum of the profiles of its atoms.

**Why now.** The two converse sandwich lemmas (Lemmas 8.1 and 8.2) read a bound on any order statistic off a *count* alone. Summing count-based bounds is exactly what a weighted average needs, so the L-estimator case is a finite-sum argument rather than a new sorting argument. If true, it immediately yields the breakdown numbers of the trimmed mean, the Winsorised mean, the midhinge, and the Tukey trimean as corollaries of a single theorem.

### D2. Minimum-distance duality for breakdown points

**Conjecture.** Let $G$ be a group acting coordinatewise on $\mathbb{Q}^n$ and let $T$ be $G$-equivariant. Then the breakdown number of $T$ at $x$ is at most $\lceil d_G(x)/2 \rceil$, where
$$d_G(x) = \min\{\, d_H(x,\, g\cdot x) : g \in G,\ g\cdot x \ne x \,\}$$
is the minimum Hamming distance of the $G$-orbit of $x$, with equality when $G$ acts by translations.

**Key insight.** Theorem 9.5 already identifies the median's breakdown threshold with the unique-decoding radius of the two-point code $\{x, x+c\}$; the translation group is the case in which every orbit element sits at full distance $n$, and a group with sparser orbits should cap robustness earlier and *more sharply*.

**Why now.** $d_H$ is established as a genuine Hamming metric (Lemma 2.3), and the confusability criterion (Theorem 9.4) is stated for an arbitrary shift. Replacing "shift by $c$" by "act by $g$" changes only the computation of $d_H(x, g\cdot x)$. A consequence would be a *scale*-equivariance ceiling for dispersion estimators such as the median absolute deviation and the interquartile range.

### D3. Block-median breakdown collapse

**Conjecture.** When a sample is partitioned into $b$ blocks and a median-of-medians is formed, the breakdown number is governed by the *product* structure of the partition rather than by $n$: the adversary need only capture a majority within a majority of blocks, so the effective threshold collapses from $\lceil n/2\rceil$ towards $\lceil b/2\rceil \cdot \lceil (n/b)/2 \rceil$, which is asymptotically $n/4$ rather than $n/2$. Making this exact — and identifying the block sizes that minimise the loss — would quantify the robustness cost of the hierarchical aggregation schemes used in distributed estimation.

---

## 14. Summary of results

| Statement | Content |
|---|---|
| Counting Stability (Lemma 3.1) | A predicate count changes by at most the Hamming distance |
| Quantitative Robustness (Thm 4.2) | $n \le 2\#\{x_i \le m\} + 2d$ for any median $m$ of a $d$-contamination |
| Breakdown Half (Thm 4.3, Cor 4.4) | $2k<n \Rightarrow$ contaminated median trapped in the clean data range |
| Sharpness Half (Thm 5.3) | $k \le n \le 2k \Rightarrow$ any prescribed value is installable as a median |
| Breakdown Theorem (Thm 5.5, Cor 5.7) | Bounded $\iff 2k < n$; breakdown number $=\lceil n/2\rceil$ |
| Mean (Thm 5.8) | Breakdown number $1$, for every sample size |
| Universal ceiling (Thm 6.2, Cor 6.3) | Every translation-equivariant estimator fails at $\lceil n/2 \rceil$ |
| Attainment (Thm 7.4) | The lower sample median is single-valued, equivariant, and optimal |
| Order-statistic profile (Thm 8.4, 8.5) | $\beta(j) = \min(j+1,n-j)$, maximised at the median index |
| Unique decoding (Thm 9.4, 9.5) | Breakdown $\iff$ failure of unique decoding for $\{x, x+c\}$ |
| Measured data (§10) | Breakdown numbers $8$ and $4$; ranges $[0.32,0.41]$ and $[0.33,0.40]$ |
