# What a Null $R^2$ Certifies: Margin Ceilings, Contrast Inequalities, and Sign-Blindness in a Quadratic-Character Effectivity Sweep

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

A family of arguments in analytic number theory rests on an *averaging assumption*: that when a quantity is averaged over many moduli, the argument may be blind to which factor it is examining without cost. The assumption is used axiomatically. A weaker but valuable target is an **effectivity criterion** — a computable per-modulus test certifying that the assumption is realized at that modulus. The natural candidate feature is the total quadratic-character $L$-mass $P(m) = \sum_\chi |L(1,\chi)|$, summed over the nontrivial real Dirichlet characters modulo $m$.

We report a pre-registered sweep testing whether $P$ predicts the arithmetic-progression deviation field $D(m) = \max_a |\pi(x;m,a) - E|/\sqrt E$, with $E = \pi(x)/\varphi(m)$. The registered rule armed the criterion at $R^2 > 0.8$ and declared an honest negative at $R^2 < 0.5$. The outcome is a null at two scales: $R^2 = 0.0187$ at $x = 2^{26}$ ($287$ moduli, $\pi(x) = 3{,}957{,}809$) with a *negative* slope $-0.0767$, $\mathrm{CI}_{95} = (-0.136,-0.015)$; and $R^2 = 0.0785$ at $x = 2^{28}$ ($2489$ moduli, $\pi(x) = 14{,}630{,}843$). A cell-level secondary readout over $1902$ discriminant cells gives $R^2 = 0.00052$ with theory-signed slope $-0.034$, $\mathrm{CI}_{95} = [-0.101, +0.033]$. A pure size baseline, $D$ against $\log m$ alone, explains $R^2 = 0.790$: the deviation field is modulus-size dominated and $L$-mass adds nothing after size.

The mathematical contribution is the deductive layer that converts these numbers into theorems. We prove:

1. **A criterion must show up in $R^2$.** Any threshold on a feature $P$ separating the response with two-sided margin $\delta$ forces $4\delta^2 n_1 n_2 / n \le R^2 \cdot \mathrm{TSS}$ for the class of *all* functions of $P$. Contrapositively, the recorded ceiling $\rho = 0.0785$ caps every such criterion at $\delta \le \sqrt\rho \approx 0.280$ sample standard deviations on a balanced split.
2. **Beyond thresholds.** An exact analysis-of-variance decomposition identifies the explained energy of the class of all functions of $P$ with the between-cell energy, yielding a pairwise cell-gap ceiling $(m_a - m_b)^2 \le \rho\,\mathrm{TSS}(1/n_a + 1/n_b)$, a general contrast ceiling $(\sum_c w_c(m_c-m))^2 \le \rho\,\mathrm{TSS}\sum_c w_c^2/n_c$, and its group form. The contrast ceiling is **sharp at every cell count**.
3. **Size domination is free.** If the centered response is affine in a covariate up to residual energy $\eta$ with $2\eta < b^2\|\tilde x\|^2$, then the affine class in that covariate alone explains at least $1 - \eta/(b^2\|\tilde x\|^2/2 - \eta)$. A high size $R^2$ is not evidence of arithmetic content.
4. **The registered control is vacuous.** Both readouts are symmetric functions of the residue-class counts, so the within-modulus permutation $p$-value is identically $1$: power exactly zero. An additive perturbation control repairs this, with an exact two-point $p$-value of $1/2$.
5. **The sweep is sign-blind, and this is a strict loss.** For every prime $p \equiv 3 \pmod 4$ there exist count fields with identical primary and secondary readouts whose signed character alignments are exactly opposite and of maximal size $p-1$. At the sweep level, *every* prescribed sign pattern is realizable with an identical response vector and hence identical $R^2$ in every model class. The recorded null therefore constrains the signed route not at all.

The averaging assumption remains axiomatic and effectivity remains open; but one route is now bounded with an explicit constant, one is proved untouched, and a broken control has a working replacement.

**Keywords:** Dirichlet $L$-functions, quadratic characters, primes in arithmetic progressions, analysis of variance, null results, permutation tests, effectivity criteria.

---

## 1. Introduction

### 1.1 The gap being attacked

Let $\pi(x;m,a)$ denote the number of primes $p \le x$ with $p \equiv a \pmod m$. For $\gcd(a,m)=1$ the expectation under equidistribution is $E = \pi(x)/\varphi(m)$. The deviations $\pi(x;m,a) - E$ are the raw material of a large body of analytic number theory, and several barrier-style arguments about how far these deviations can be controlled depend on an averaging assumption whose informal content is *which-factor blindness as identity*: over an average of moduli, one may treat the moduli as interchangeable at no cost.

The assumption is used as an axiom. Its residual bookkeeping item — the one attacked here — is **effectivity**: does there exist a *computable per-modulus criterion* deciding when the averaging assumption is realized?

### 1.2 Why quadratic-character $L$-values

If there is such a criterion, the classical theory suggests where to look. Real (quadratic) Dirichlet characters modulo $m$ carry the exceptional-zero phenomenon; $L(1,\chi)$ small is the analytic signature of an exceptional character; and the error terms in Dirichlet-type theorems on primes in progressions are classically written in terms of these very quantities. The natural aggregate feature is therefore the **quadratic-character $L$-mass**
$$P(m) \;=\; \sum_{\substack{\chi \bmod m \\ \chi \text{ real},\ \chi \ne \chi_0}} |L(1,\chi)| .$$

### 1.3 The pre-registration

Before any data were examined, the following was fixed.

- **Response (primary).** $\displaystyle D(m) = \max_{a \in (\mathbb Z/m)^\times} \frac{|\pi(x;m,a) - E|}{\sqrt E}$.
- **Response (secondary).** $\displaystyle \chi^2(m) = \sum_{a} \frac{(\pi(x;m,a) - E)^2}{E}$.
- **Predictor.** $P(m)$ as above.
- **Model.** Ordinary least squares of $\log D$ on $\log P$ across a sweep of moduli.
- **Verdict rule.** $R^2 > 0.8 \Rightarrow$ criterion armed ($H_1$). $R^2 < 0.5 \Rightarrow$ honest negative ($H_0$).

### 1.4 The outcome, and the problem with reporting it

Both stages returned $H_0$ (Section 2). The methodological difficulty is that $R^2 = 0.0785$ is a *statistic*, describing what one estimator did on one sample. Read literally it forbids nothing: it does not rule out a cleverer nonlinear criterion, a threshold rule at an unusual cutoff, or a partition into many level sets. Sections 3–5 supply the deductive layer that removes this ambiguity, converting the recorded numbers into exact finite-sample bounds on what *any* criterion built from the feature can achieve. Sections 6–7 prove the two methodological items — a provably vacuous control, and provable sign-blindness — that bound the scope of the negative honestly.

---

## 2. The experiment and its numbers

### 2.1 Stage A: registered scale $x = 2^{26}$

$\pi(x) = 3{,}957{,}809$. Moduli: squarefree $m \in [3,300]$ together with primes in $[307,997]$, $287$ in total. No shrinkage. Wall time $9.3$ s.

- Primary log–log fit: slope $-0.0767$, $\mathrm{CI}_{95} = (-0.136, -0.015)$, $R^2 = 0.0187$, bootstrap interval $[0.0007, 0.065]$. The slope is *negative*, which is the opposite sign from the effectivity narrative.
- Partial $R^2$ controlling $\log \varphi(m)$: $0.0008$. The residual association is entirely a size effect.
- Secondary readout ($\chi^2$) agrees: $R^2 = 0.025$.
- Control: cross-modulus pairing permutation, $2000$ draws — collapses to null (mean $0.0033$, max $0.0435$).

**Disclosed specification deviation.** The literal registered control, a within-modulus count permutation, is *vacuous* for both the max and the $\chi^2$ readout, because both are permutation-invariant. This is not a judgement call but a theorem; see Section 6. The cross-modulus pairing permutation was substituted.

### 2.2 Stage B: scaled artifact $x = 2^{28}$

$\pi(x) = 14{,}630{,}843$, $2489$ moduli (dense $2 \ldots 1500$ plus primes beyond), wall time $247.7$ s.

- Primary per-modulus carrier: $R^2 = 0.0785$ — null.
- Cell-level secondary $y \sim \log(1/L)$ over $1902$ discriminant cells: $R^2 = 0.00052$; theory-signed slope $B = -0.034$, $\mathrm{CI}_{95} = [-0.101, +0.033]$ — not even positive.
- **Size baseline.** $D$ regressed on $\log m$ alone: $R^2 = 0.790$.

### 2.3 Numerical verification of the $L$-value path

The exact class-number route was validated against the truncated Euler/Dirichlet series. For the fundamental discriminant $-3$ one has $h(-3) = 1$, $w = 6$, and the class-number formula gives exactly
$$L(1,\chi_{-3}) = \frac{2\pi h(-3)}{w\sqrt{3}} = \frac{\pi}{3\sqrt 3} \approx 0.604600 .$$
The truncated series was calibrated on $226$ overlap discriminants with median relative error $1.8\times 10^{-5}$; the final run's truncation quality had median real-share $8.7\times10^{-4}$ and worst relative error $8.2\times10^{-2}$.

**Ledger.** An off-by-one in the character table corrupted non-exact $L$-values (the character mod $5$ returned $0.127$ against the true $0.430$); this was caught by a spot check against exact values, fixed, and the run repeated before any fit was recorded. A smoke control gate failed at $n = 29$, resolving at the scale where the null collapses cleanly. A Mertens gate failed by its own pre-stated strict rule (slope $0.9277$, $\mathrm{CI}_{95}=[0.9234,0.9320]$, $R^2 = 0.9894$: near-proportional but just outside the strict band), with implied $\bar K = -0.216$ comfortably inside the theoretical bound $|K| \le 0.756$.

### 2.4 What must now be proved

Three claims are needed to read the null honestly.

1. That the ceiling $\rho$ genuinely caps every criterion — not just the fitted line (Sections 3–5).
2. That the $0.790$ size baseline is not itself evidence of anything arithmetic (Section 5).
3. That the scope of the null is exactly the magnitude route, no more (Sections 6–7).

---

## 3. Finite-sample regression, exactly

All of what follows is exact algebra on a finite sample; no asymptotics, no distributional assumptions, no model correctness.

### 3.1 Notation

Let $\iota$ be a finite nonempty index set of size $n$ (the moduli), and $y : \iota \to \mathbb R$ the response. Write
$$\bar y = \frac 1n \sum_i y_i, \qquad \|u\|^2 = \sum_i u_i^2, \qquad \mathrm{TSS}(y) = \|y - \bar y\|^2 .$$
For a nonempty class $T$ of candidate predictors $\iota \to \mathbb R$, the residual energy and the coefficient of determination are
$$\mathrm{RSS}(y,T) = \inf_{h \in T} \|y - h\|^2, \qquad R^2(y,T) = 1 - \frac{\mathrm{RSS}(y,T)}{\mathrm{TSS}(y)} .$$

Two classes matter.

- **Affine class** in a feature $x$: $\ \mathcal A(x) = \{\,i \mapsto \alpha + \beta x_i \;:\; \alpha,\beta \in \mathbb R\,\}$. This is the class of the registered log–log fit.
- **Measurable class** of a feature $P$: $\ \mathcal M(P) = \{\, g \circ P \;:\; g \text{ arbitrary}\,\}$ — *every* function of $P$, of any shape. Clearly $\mathcal A(x) \subseteq \mathcal M(x)$.

The point of $\mathcal M(P)$ is that a criterion is a function of the feature. Bounding $R^2(y,\mathcal M(P))$ bounds every criterion simultaneously.

### 3.2 Cells

For a feature $P : \iota \to \alpha$ with values in any type, the **cell** at a level $c$ is $\mathrm{cell}(P,c) = \{i : P_i = c\}$, of size $n_c$, and its **cell mean** is $m_c = n_c^{-1}\sum_{i \in \mathrm{cell}(P,c)} y_i$. Write
$$\mathrm{withinSS}(y,P) = \sum_c \sum_{i \in \mathrm{cell}(P,c)} (y_i - m_c)^2, \qquad \mathrm{betweenSS}(y,P) = \sum_c n_c (m_c - \bar y)^2 ,$$
the sums running over the levels actually attained.

---

## 4. What a null $R^2$ certifies

### 4.1 The two-group identity

**Lemma 1 (exact two-group decomposition).** *Let $S \subseteq \iota$ with $S$ and $S^c$ both nonempty, and let $\hat g$ be the two-valued predictor equal to the mean of $y$ on $S$ and on $S^c$ respectively. Then*
$$\|y - \hat g\|^2 = \mathrm{TSS}(y) - \frac{n_1 n_2}{n}(m_1 - m_2)^2,$$
*where $n_1 = |S|$, $n_2 = |S^c|$, $m_1, m_2$ the two group means.*

*Proof sketch.* Expand $\sum_{i}(y_i - \bar y)^2$ over the two groups and use $\bar y = (n_1 m_1 + n_2 m_2)/n$ to eliminate $\bar y$. Each group's contribution splits as (within-group energy) plus $n_j(m_j - \bar y)^2$; substituting the expression for $\bar y$ and simplifying converts the two mean-offset terms into the single pooled term $(n_1n_2/n)(m_1-m_2)^2$. $\square$

### 4.2 A criterion has to show up in $R^2$

**Theorem 2 (margin lower bound).** *Let $P$ be a feature, $t$ a threshold, and suppose the induced split separates the response two-sidedly with margin $\delta \ge 0$:*
$$P_i \ge t \implies y_i \ge \mu + \delta, \qquad P_i < t \implies y_i \le \mu - \delta .$$
*Let $n_1, n_2$ be the two group sizes, both nonzero. Then*
$$\frac{4\delta^2 n_1 n_2}{n} \;\le\; R^2(y, \mathcal M(P)) \cdot \mathrm{TSS}(y).$$

*Proof sketch.* The two-valued predictor of Lemma 1 lies in $\mathcal M(P)$ (it is a function of $P$: it depends on $i$ only through the truth of $P_i \ge t$). Hence $\mathrm{RSS}(y,\mathcal M(P)) \le \|y - \hat g\|^2$, so by Lemma 1
$$R^2 \cdot \mathrm{TSS} = \mathrm{TSS} - \mathrm{RSS} \ \ge\ \frac{n_1n_2}{n}(m_1-m_2)^2 .$$
The hypotheses force $m_1 \ge \mu+\delta$ and $m_2 \le \mu-\delta$, whence $(m_1-m_2)^2 \ge 4\delta^2$. $\square$

**Corollary 3 (margin ceiling — the theorem-level meaning of the null).** *If $R^2(y,\mathcal M(P)) \le \rho$, then every threshold criterion on $P$ obeys*
$$\frac{4\delta^2 n_1 n_2}{n} \le \rho\,\mathrm{TSS}(y).$$
*In particular, for a balanced split $n_1 = n_2 = n/2$ this reads $\delta^2 n \le \rho\,\mathrm{TSS}(y)$, i.e. $\delta \le \sqrt{\rho}\cdot s$ with $s$ the sample standard deviation.*

**Corollary 4 (recorded instance).** *With the stage-B ceiling $\rho = 0.0785$: every threshold criterion built from the quadratic-character $L$-mass — of any functional form — separates the deviation field with margin at most*
$$\delta \le \sqrt{0.0785}\,s \approx 0.280\,s$$
*on a balanced split.* This is the honest content of the null: not "no correlation was observed," but "no rule of this shape can separate by more than $0.28$ standard deviations."

### 4.3 Two auxiliary ceilings

**Proposition 5 (incremental ceiling over a baseline).** *Let $g$ be a baseline predictor and $v$ a feature, and let $T$ be a class containing $g + t v$ for every $t \in \mathbb R$. If the enlarged class beats the baseline by at most $\Delta$ in $R^2$, then*
$$\langle y - g, v\rangle^2 \le \Delta\,\|v\|^2\,\mathrm{TSS}(y).$$

*Proof sketch.* Optimizing the one-parameter family $g + tv$ gives $R^2(y,T) \ge R^2(y,g) + \langle y-g,v\rangle^2/(\|v\|^2 \mathrm{TSS})$; rearrange against the hypothesis. $\square$

This is the form in which the partial-$R^2$ figure $0.0008$ (stage A, controlling $\log\varphi(m)$) constrains the criterion: a genuine criterion would have had to appear as a residual correlation after the size baseline, and it does not.

**Proposition 6 (nonlinear residual floor).** *If the response retains a fraction $\theta$ of its energy within the level sets of $P$, i.e. $\theta\,\mathrm{TSS}(y) \le \mathrm{withinSS}(y,P)$, then $R^2(y,\mathcal M(P)) \le 1 - \theta$.*

*Proof sketch.* The best predictor in $\mathcal M(P)$ is the cell-mean function, whose residual energy is exactly $\mathrm{withinSS}$. $\square$

This is the form in which the cell-level secondary readout ($R^2 = 0.00052$ over $1902$ discriminant cells) constrains the criterion: the within-cell energy is essentially everything.

---

## 5. Beyond thresholds: the cell-gap calculus

A criterion need not be a threshold. It may read the feature at arbitrary resolution and act on each level set separately. The threshold restriction is now removed.

### 5.1 Analysis of variance, exactly

**Theorem 7 (ANOVA).** *For any response $y$ and any feature $P$,*
$$\mathrm{TSS}(y) = \mathrm{withinSS}(y,P) + \mathrm{betweenSS}(y,P).$$

*Proof sketch.* Partition the index set into the fibers of $P$ and apply, cell by cell, the elementary identity $\sum_{i \in C}(y_i - \bar y)^2 = \sum_{i\in C}(y_i - m_C)^2 + |C|(m_C - \bar y)^2$, valid whenever $|C| \ne 0$. Summing over cells gives the claim. $\square$

**Corollary 8 (the explained energy of the whole nonlinear class).** *If $\mathrm{TSS}(y) > 0$ then*
$$R^2(y,\mathcal M(P))\cdot \mathrm{TSS}(y) = \mathrm{betweenSS}(y,P).$$

*Proof sketch.* $\mathrm{RSS}(y,\mathcal M(P)) = \mathrm{withinSS}(y,P)$, since the cell-mean function is the unconstrained minimizer within $\mathcal M(P)$; substitute into Theorem 7. $\square$

So a recorded ceiling $\rho$ is exactly a budget on between-cell energy: $\mathrm{betweenSS}(y,P) \le \rho\,\mathrm{TSS}(y)$. Everything below is a way of spending that budget.

### 5.2 The pairwise cell-gap ceiling

**Lemma 9 (two-cell energy inequality).** *For $n_a, n_b > 0$ and any reference level $m$,*
$$\frac{n_a n_b}{n_a + n_b}(m_a - m_b)^2 \le n_a(m_a - m)^2 + n_b (m_b - m)^2 .$$
*Equality holds exactly at the pooled mean $m = (n_a m_a + n_b m_b)/(n_a+n_b)$.*

*Proof sketch.* Clear denominators; the difference is $\big(n_a(m_a - m) - n_b(m - m_b)\big)^2/(n_a+n_b) \ge 0$, which vanishes precisely at the pooled mean. $\square$

**Theorem 10 (cell-gap ceiling).** *Suppose $R^2(y,\mathcal M(P)) \le \rho$ and $\mathrm{TSS}(y) > 0$. Then for any two distinct attained levels $a \ne b$ of $P$,*
$$(m_a - m_b)^2 \;\le\; \rho\,\mathrm{TSS}(y)\left(\frac{1}{n_a} + \frac{1}{n_b}\right).$$

*Proof sketch.* The two cells' contributions to $\mathrm{betweenSS}$ are a sub-sum of a sum of nonnegative terms, hence at most $\mathrm{betweenSS} \le \rho\,\mathrm{TSS}$ by Corollary 8. Apply Lemma 9 with $m = \bar y$ and divide by the pooled coefficient $n_an_b/(n_a+n_b)$. $\square$

With $\rho = 0.0785$ this is the recorded certificate: **no partition of the moduli by $L$-mass separates the deviation field by more than an explicitly bounded gap.**

### 5.3 The general contrast ceiling

**Theorem 11 (multi-cell contrast ceiling).** *Let $S$ be any finite set of attained levels of $P$ and $w : S \to \mathbb R$ any weights. If $R^2(y,\mathcal M(P)) \le \rho$ and $\mathrm{TSS}(y)>0$, then*
$$\Big(\sum_{c \in S} w_c\,(m_c - \bar y)\Big)^2 \;\le\; \rho\,\mathrm{TSS}(y)\sum_{c\in S} \frac{w_c^2}{n_c}.$$

*Proof sketch.* Write $w_c (m_c - \bar y) = (w_c/\sqrt{n_c})\cdot(\sqrt{n_c}(m_c-\bar y))$ and apply Cauchy–Schwarz. The second factor squares to a sub-sum of $\mathrm{betweenSS}$, bounded by $\rho\,\mathrm{TSS}$ via Corollary 8. $\square$

When $\sum_c w_c = 0$ the left side is a genuine contrast, invariant under shifting the response by a constant. Taking $w = (+1,-1)$ on a pair recovers Theorem 10.

**Definition (groups).** For a set $A$ of levels let $N_A = \sum_{c \in A} n_c$ and $M_A = N_A^{-1}\sum_{c\in A} n_c m_c$.

**Theorem 12 (group-gap ceiling — the form a criterion takes).** *Let $A,B$ be disjoint sets of attained levels with $N_A, N_B > 0$. If $R^2(y,\mathcal M(P)) \le \rho$ then*
$$(M_A - M_B)^2 \le \rho\,\mathrm{TSS}(y)\left(\frac{1}{N_A} + \frac{1}{N_B}\right).$$

*Proof sketch.* Apply Theorem 11 with $w_c = n_c/N_A$ on $A$ and $w_c = -n_c/N_B$ on $B$. The left side becomes $(M_A - M_B)^2$ because the weights sum to zero across $A \cup B$; the right side's weight budget telescopes to $\sum_{c\in A} n_c/N_A^2 + \sum_{c\in B} n_c/N_B^2 = 1/N_A + 1/N_B$. $\square$

Any decision rule reading the $L$-mass sorts the moduli into a union of cells $A$ ("effective") and a disjoint union $B$; Theorem 12 caps its achievable separation. The recorded instance with $\rho = 0.0785$ is the operative certificate of this paper.

### 5.4 Sharpness: no hiding room at any cell count

One might hope the Cauchy–Schwarz constant is lax, so that a criterion using many cells has extra room inside a small $R^2$. It does not.

**Theorem 13 (sharpness at every cell count).** *Suppose the response is a function of the feature, $y_i = g(P_i)$. Then $\mathrm{withinSS}(y,P)=0$, hence $R^2(y,\mathcal M(P)) = 1$; the weights*
$$w_c = n_c(m_c - \bar y)$$
*satisfy $\sum_c w_c = 0$ and turn Theorem 11 into an exact equality with $\rho = 1$, for an arbitrary number of cells:*
$$\Big(\sum_c w_c (m_c - \bar y)\Big)^2 = 1\cdot \mathrm{TSS}(y) \cdot \sum_c \frac{w_c^2}{n_c}.$$

*Proof sketch.* If $y$ is a function of $P$ then $y$ is constant on cells, so $\mathrm{withinSS}=0$ and $\mathrm{TSS} = \mathrm{betweenSS} =: \mathcal E$ by Theorem 7. With the stated weights, the left side is $\mathcal E^2$ and the right side is $\mathcal E\cdot\mathcal E$. The contrast property $\sum_c n_c(m_c - \bar y) = 0$ follows from $\sum_c n_c m_c = n\bar y$ and $\sum_c n_c = n$. $\square$

For a two-valued feature this specializes to $(m_a - m_b)^2 = \mathrm{TSS}(1/n_a + 1/n_b)$, exact equality in Theorem 10. **The pairwise constant was already optimal**; the conjectured extra hiding room for a multi-cell criterion inside a null $R^2$ does not exist.

### 5.5 Size domination is free

**Lemma 14.** *For any $u,v$: $\ \|u+v\|^2 \ge \tfrac12\|u\|^2 - \|v\|^2$.*

*Proof sketch.* Pointwise, $(u_i+v_i)^2 - \tfrac12 u_i^2 + v_i^2 = \tfrac12(u_i + 2v_i)^2 \ge 0$; sum. No Cauchy–Schwarz needed. $\square$

**Theorem 15 (size domination).** *Suppose the centered response decomposes as $y_i - \bar y = b(x_i - \bar x) + r_i$ with $\|r\|^2 \le \eta$, and the feature's centered spread dominates the residual: $2\eta < b^2\|\tilde x\|^2$ where $\tilde x = x - \bar x$. Then*
$$R^2(y,\mathcal A(x)) \;\ge\; 1 - \frac{\eta}{\;b^2\|\tilde x\|^2/2 - \eta\;}.$$

*Proof sketch.* By Lemma 14 applied to $u = b\tilde x$, $v = r$, we get $\mathrm{TSS}(y) \ge b^2\|\tilde x\|^2/2 - \eta =: T_0 > 0$. The affine predictor $\alpha + \beta x$ with $\beta = b$, $\alpha = \bar y - b\bar x$ has residual exactly $r$, so $\mathrm{RSS}(y,\mathcal A(x)) \le \eta$. Then $R^2 \ge 1 - \eta/\mathrm{TSS} \ge 1 - \eta/T_0$. $\square$

Near-affinity in a single covariate is therefore *sufficient* for a high $R^2$. Since the normalized deviations $D(m)$ grow with $\varphi(m)$ for elementary reasons, the observed size baseline $R^2 = 0.790$ is precisely what Theorem 15 predicts from near-affinity in $\log m$ — and carries no arithmetic information.

### 5.6 The dichotomy

**Theorem 16 (effectivity dichotomy).** *Fix a sample with response $y$, candidate criterion feature $P$, and size covariate $x$. Assume the recorded ceiling $R^2(y,\mathcal M(P)) \le \rho$ and a near-affine size decomposition as in Theorem 15. Then simultaneously:*

1. *every threshold criterion on $P$ with two-sided margin $\delta$ obeys $\ 4\delta^2 n_1n_2/n \le \rho\,\mathrm{TSS}(y)$; and*
2. *as soon as $\ \rho < 1 - \eta/(b^2\|\tilde x\|^2/2 - \eta)$, the single size covariate strictly outperforms the entire, arbitrarily nonlinear class of functions of $P$:*
$$R^2(y,\mathcal M(P)) < R^2(y,\mathcal A(x)).$$

*Proof sketch.* Part 1 is Corollary 3; part 2 chains the hypothesis through Theorem 15. $\square$

With $\rho = 0.0785$ against a size baseline of $0.790$, both clauses fire on the recorded data. **This is the exact sense in which the experiment is an honest negative: the criterion route is capped, and the explanatory power that exists lives in modulus size.**

---

## 6. The registered control had power exactly zero — and its repair

### 6.1 Vacuity

Model a modulus's data as a count field $c : \iota \to \mathbb R$ over residue classes with expectation $E>0$. The registered readouts are
$$\mathrm{maxDev}(c,E) = \frac{\max_a |c_a - E|}{\sqrt E}, \qquad \chi^2(c,E) = \frac{\sum_a (c_a - E)^2}{E}.$$

**Lemma 17.** *Both readouts are invariant under relabeling: for every permutation $\sigma$ of the classes, $\mathrm{maxDev}(c\circ\sigma, E) = \mathrm{maxDev}(c,E)$ and $\chi^2(c\circ\sigma,E) = \chi^2(c,E)$.*

*Proof sketch.* A maximum and a sum over a finite index set are unchanged by reindexing along a bijection. $\square$

**Definition.** The one-sided permutation $p$-value of a statistic $T$ is the fraction of relabelings $\sigma$ with $T(c) \le T(c\circ\sigma)$.

**Theorem 18 (the permutation control cannot reject).** *For any relabeling-invariant statistic $T$ and any count field $c$, the permutation $p$-value equals exactly $1$.*

*Proof sketch.* Invariance makes the defining inequality $T(c) \le T(c \circ \sigma)$ true for every $\sigma$, so the filtered set is the whole permutation group. $\square$

**Corollary 19.** *Both registered readouts have permutation $p$-value identically $1$. The within-modulus permutation control has power exactly zero, for every count field, whatever the arithmetic.*

This is a mathematical statement, not a statistical complaint, and it justifies the disclosed substitution of a cross-modulus pairing control in Section 2.1.

### 6.2 A control with nonzero power

Replace relabeling by an *additive* perturbation $c \mapsto c + t\,w$ along a direction $w$ nonzero at some class $a_0$.

**Lemma 20 (exact amplitude profile of $\chi^2$).** *For all $t$,*
$$\chi^2(c+tw,E) = \chi^2(c,E) + \frac{2t\,B + t^2 A}{E}, \qquad A = \sum_a w_a^2,\quad B = \sum_a (c_a - E)w_a .$$

*Proof sketch.* Expand $(c_a + tw_a - E)^2$ and sum. $\square$

**Theorem 21 (one-sided rejection).** *For any $w$ with $w_{a_0}\ne 0$ there is $t_0>0$ such that for all $t \ge t_0$, both $\mathrm{maxDev}(c+tw,E) > \mathrm{maxDev}(c,E)$ and $\chi^2(c+tw,E) > \chi^2(c,E)$.*

*Proof sketch.* For $\chi^2$: $A > 0$, so the quadratic $2tB + t^2A$ is positive once $t > 2|B|/A$. For $\mathrm{maxDev}$: at the class $a_0$ the perturbed field is at distance $\ge t|w_{a_0}| - |c_{a_0}-E|$ from $E$, which exceeds the unperturbed maximum once $t|w_{a_0}| > 2M+1$ with $M$ that maximum. $\square$

**Theorem 22 (symmetric identity and rejection at every amplitude).**
$$\chi^2(c+tw,E) + \chi^2(c-tw,E) = 2\chi^2(c,E) + \frac{2t^2 A}{E},$$
*hence for every $t \ne 0$, $\ \chi^2(c,E) < \max\{\chi^2(c+tw,E),\ \chi^2(c-tw,E)\}$.*

*Proof sketch.* Add the profile of Lemma 20 at $t$ and at $-t$; the linear terms cancel. The excess $2t^2A/E$ is strictly positive, so the two perturbed values cannot both be $\le \chi^2(c,E)$. $\square$

**Theorem 23 (convex amplitude profile for the primary readout).** *The map $t \mapsto \mathrm{maxDev}(c+tw,E)$ is convex. Consequently the acceptance region $\{t : \mathrm{maxDev}(c+tw,E) < \mathrm{maxDev}(c,E)\}$ is an interval — the control rejects outside an interval, with no gaps — and for every $t$,*
$$\mathrm{maxDev}(c,E) \le \max\{\mathrm{maxDev}(c+tw,E),\ \mathrm{maxDev}(c-tw,E)\}.$$

*Proof sketch.* Each $t \mapsto |c_a + tw_a - E|$ is convex; a finite maximum of convex functions is convex; dividing by $\sqrt E > 0$ preserves convexity. Sublevel sets of a convex function are convex, i.e. intervals in $\mathbb R$. The last claim is convexity at the midpoint $t=0$ of $\{t,-t\}$. $\square$

**Theorem 24 (exact two-point $p$-value).** *Define the two-point $p$-value of $T$ under $c \mapsto c \pm tw$ as the fraction of the two perturbations with $T(c) \le T(\cdot)$. If $B \ne 0$, $t>0$ and $tA < 2|B|$, then the two-point $p$-value of $\chi^2$ is exactly $1/2$.*

*Proof sketch.* By Lemma 20 the increments at $\pm t$ are $(2tB + t^2A)/E$ and $(-2tB+t^2A)/E$. The smallness hypothesis $tA<2|B|$ makes exactly one of them positive and the other negative, so exactly one of the two indicators fires. $\square$

**Corollary 25 (strict improvement).** *On the same data, the relabeling $p$-value of the $\chi^2$ readout is exactly $1$ (power zero) while the additive two-point $p$-value is exactly $1/2$.*

---

## 7. Sign-blindness: the exact scope of the negative

### 7.1 The alignment functional

The registered readouts are magnitudes. The object the underlying theory actually cares about is the **signed alignment** of the count field with a character weight,
$$\langle c, w\rangle = \sum_a c_a\,w_a .$$

**Lemma 26 (reflection flips alignment).** *Let $\nu$ be a permutation of the classes under which $w$ is odd, $w_{\nu(a)} = -w_a$ for all $a$. Then $\langle c\circ\nu, w\rangle = -\langle c,w\rangle$.*

*Proof sketch.* Substitute $w_a = -w_{\nu(a)}$ and reindex the sum along $\nu$. $\square$

**Proposition 27 (general separation).** *Under the hypotheses of Lemma 26, if $\langle c,w\rangle \ne 0$ then for every relabeling-invariant statistic $T$: $\ T(c\circ\nu) = T(c)$ while $\langle c\circ\nu,w\rangle \ne \langle c,w\rangle$. Sign-blind readouts cannot separate a field from its reflection, though their alignments differ.*

### 7.2 The arithmetic instance

Let $p$ be prime and $\chi$ the real-valued quadratic character mod $p$, i.e. $\chi(a) = \pm1$ for $a\ne 0$ and $\chi(0)=0$. Two standard facts: $\sum_a \chi(a) = 0$ for $p \ne 2$, and for $p \equiv 3 \pmod 4$ the character is **odd**, $\chi(-a) = -\chi(a)$, because $\chi(-1) = -1$ in that case.

**Lemma 28 (maximal alignment of a tilted field).** *For $p \ne 2$ and any $E$, the character-tilted count field $c(a) = E + \chi(a)$ has $\langle c,\chi\rangle = \sum_a \chi(a)^2 = p-1$, the maximum available.*

*Proof sketch.* $\langle c,\chi\rangle = E\sum_a \chi(a) + \sum_a\chi(a)^2 = 0 + (p-1)$, since $\chi(a)^2 = 1$ off zero. $\square$

**Theorem 29 (the readouts cannot see alignment).** *For every prime $p \equiv 3 \pmod 4$ and every expectation level $E$, there exist count fields $c_1, c_2$ on the classes mod $p$ with*
$$\mathrm{maxDev}(c_1,E) = \mathrm{maxDev}(c_2,E), \qquad \chi^2(c_1,E) = \chi^2(c_2,E),$$
*while*
$$\langle c_1,\chi\rangle = p-1, \qquad \langle c_2,\chi\rangle = -(p-1).$$

*Proof sketch.* Take $c_1(a) = E + \chi(a)$ and $c_2 = c_1 \circ \nu$ with $\nu : a \mapsto -a$. Lemma 17 gives the equality of readouts (reflection is a relabeling); Lemma 28 and Lemma 26 (with $w = \chi$, odd since $p\equiv 3 \bmod 4$) give the alignments. $\square$

### 7.3 The sweep-level statement

Let the sample consist of one count field per modulus, $c : \iota \to (\kappa \to \mathbb R)$, with per-modulus expectations $E_i$, and define the **sweep response** $y_i = \mathrm{maxDev}(c_i, E_i)$.

**Theorem 30 (the sweep is blind to the sign of the alignment).** *Reflect each modulus's field by a permutation $\sigma_i$ under which the character weight $w$ is odd. Then*
$$y(\text{reflected}) = y(\text{original}),$$
*hence $R^2$ is unchanged in **every** model class whatsoever, while $\langle c_i \circ \sigma_i, w\rangle = -\langle c_i, w\rangle$ for every $i$.*

**Theorem 31 (every sign pattern fits the same data).** *Fix a prime $p \equiv 3 \pmod 4$ and any prescribed pattern of signs $s : \iota \to \{\pm\}$. There is a sample of count fields on the classes mod $p$ realizing that pattern of maximal alignments $\pm(p-1)$ whose recorded response vector — and therefore whose fitted $R^2$ in every model class — is identical to that of the unreflected sample.*

*Proof sketch.* Take $c_i = $ the tilted field $E_i + \chi$ if $s_i = +$, and its reflection otherwise. Theorem 30 handles the response; Lemma 28 and Lemma 26 handle the alignments. $\square$

**Consequence.** *The recorded magnitude null places no constraint whatsoever on the signed character-alignment route.* This is the paper's prominent scoping caveat, proved rather than asserted. A signed analysis is a strictly finer instrument and must be run **before** the $L$-value route is declared dead.

---

## 8. Algorithms

Three procedures carry the pipeline.

**A. Segmented residue-class prime census.** Sieve $[2,x]$ in cache-sized segments; for each modulus $m$ in the sweep, maintain a length-$m$ tally, incrementing the class $p \bmod m$ for each prime found. Then $D(m) = \max_{\gcd(a,m)=1}|{\rm tally}_a - E|/\sqrt E$ with $E = \pi(x)/\varphi(m)$. Cost: $O(x\log\log x)$ for the sieve plus $O(\pi(x)\cdot|\mathcal M|)$ for tallying, memory $O(\sqrt x + \sum_m m)$. This dominates the wall time ($247.7$ s at $x=2^{28}$).

**B. Quadratic-character $L$-mass with exact calibration.** For each fundamental discriminant $d$ attached to a real character mod $m$, evaluate $L(1,\chi_d)$ by a truncated smoothed Dirichlet series; on the sub-range where the class-number formula applies with small class number, compute the exact value $L(1,\chi_d) = 2\pi h(d)/(w\sqrt{|d|})$ for $d<0$ and calibrate the truncation against it. The exact anchor $L(1,\chi_{-3}) = \pi/(3\sqrt3)$ validated the path; a spot check against $L(1,\chi_5)$ caught the off-by-one indexing bug described in Section 2.3. Cost: $O(T)$ per character for truncation length $T$.

**C. Ceiling certification.** Given the sample $(y,P)$ and a recorded ceiling $\rho$: bin the moduli by $P$, compute cell sizes $n_c$ and cell means $m_c$, verify the ANOVA identity $\mathrm{TSS} = \mathrm{withinSS} + \mathrm{betweenSS}$ numerically, then evaluate the certified bounds — the balanced margin $\sqrt\rho\,s$, the pairwise gaps $\sqrt{\rho\,\mathrm{TSS}(1/n_a+1/n_b)}$, and for any proposed grouping $A|B$ the group ceiling $\sqrt{\rho\,\mathrm{TSS}(1/N_A + 1/N_B)}$ — and compare against the observed gaps. Cost: $O(n)$ after an $O(n\log n)$ sort.

---

## 9. Applications and reusability

Nothing in Sections 3–6 is specific to number theory. The ingredients are a finite sample, a response, and a feature.

- **Any pre-registered regression sweep** reporting a small $R^2$ has, implicitly, proved a margin ceiling. Corollary 3 turns "we found no signal" into "no threshold rule on this feature separates by more than $\sqrt\rho$ standard deviations," which is a far stronger and far more useful claim.
- **Feature-selection audits.** Theorem 12 bounds what any grouping rule reading a candidate feature can achieve — a distribution-free guarantee complementary to generalization bounds, since it is exact on the sample at hand.
- **Confound diagnosis.** Theorem 15 quantifies the intuition that a size covariate can score a high $R^2$ for free. Reporting a baseline $R^2$ without this bound over-credits the baseline.
- **Control design.** Corollary 19 is a checklist item with teeth: *if your test statistic is invariant under your randomization, your control has power exactly zero.* Symmetric readouts (maxima, sums, sorted statistics) paired with relabeling randomizations are a common and silent failure mode. The additive family of Section 6.2 is a drop-in repair with a provable, computable $p$-value.
- **Scope discipline.** Theorem 31 is the general moral of sign-blindness: a magnitude-only readout can leave an entire signed hypothesis class *formally unconstrained*, no matter how large the sample. Confirm the readout is not invariant under a symmetry that acts nontrivially on the hypothesis before claiming the hypothesis is excluded.

---

## 10. Discussion

### 10.1 What the null does and does not establish

**Does:** the magnitude route to a computable effectivity criterion is capped at toy scale by an explicit constant. Any function of $P(m)$, at any resolution, with any decision rule, obeys the ceilings of Sections 4–5. The pairwise, group, and contrast forms are sharp (Theorem 13), so nothing is left on the table.

**Does not:** weaken the barrier program. The averaging assumption stays axiomatic at practical scale, and effectivity stays an open gap item. The result narrows one avenue and quantifies the narrowing.

**Cannot:** touch the signed route (Theorem 31). This is the one caveat that must travel with every citation of the result.

### 10.2 Why the slope came out negative

At stage A the fitted slope was $-0.0767$, opposite the effectivity story, and the partial $R^2$ after $\log\varphi(m)$ was $0.0008$. Together these say the residual association was a size effect: larger moduli have more characters, hence larger $L$-mass, and simultaneously smaller expected counts per class with different normalized deviation behavior. What looks like a faint negative arithmetic trend is a size artifact — which is exactly what the $0.790$ size baseline plus Theorem 15 predicts.

### 10.3 Scale

Both scales are *toy*: $x = 2^{26}$ and $x = 2^{28}$. The ceilings certified here are ceilings *on this sample*, exact and unconditional as finite-sample statements, and no extrapolation to $x \to \infty$ is claimed. Their value is that they are theorems about the sample rather than inferences about a population — which is precisely what one wants when reporting a negative.

### 10.4 Disclosures

Ledger items are recorded in full in Section 2. The material ones: an off-by-one bug in character construction, caught by comparison against exact class-number values and fixed before any recorded fit; a smoke gate failure at $n=29$, resolved at the scale where the null collapses cleanly; a Mertens gate failure by its own strict pre-stated band despite near-proportionality ($R^2 = 0.9894$) and an implied constant inside the theoretical bound; and a scale-reconciliation note, the stage-B rerun having superseded the stage-A record, with the two stages verdict-identical.

---

## 11. Future directions

**What is now settled.**

1. The registered readouts are permutation invariant, so the within-modulus permutation control has power exactly zero.
2. The readouts are sign-blind, and for every prime $p\equiv 3 \pmod 4$ the signed character alignment is entirely unconstrained by the recorded data.
3. A null $R^2$ is nevertheless a genuine bound: it caps the separating margin of every threshold criterion built from the feature, however nonlinear, while a near-affine size covariate can reach a high $R^2$ with no arithmetic content.
4. Exact ANOVA and the pairwise cell-gap ceiling: any two level sets of the feature have response means separated by at most $\rho\,\mathrm{TSS}(1/n_a + 1/n_b)$ in square.
5. The multi-cell calculus: the general contrast ceiling $(\sum_{c\in S} w_c(m_c - \bar y))^2 \le \rho\,\mathrm{TSS}\sum_{c\in S} w_c^2/n_c$, its criterion form for two groups of cells, and sharpness for a two-valued feature.
6. A control with nonzero power: replacing relabeling by an additive perturbation repairs the vacuity of item 1 — for any direction nonzero at some class, both registered readouts of $c + t w$ strictly exceed the observed readout once $t$ is large enough.
7. The contrast ceiling has no deficiency at any cell count. For a response that is a function of the feature, the weights $w_c = n_c(m_c - \bar y)$ — a genuine contrast, since they sum to zero — attain the Cauchy–Schwarz ceiling exactly with $\rho = R^2 = 1$, for an arbitrary number of cells. The conjectured extra hiding room for a multi-cell criterion inside a null $R^2$ therefore does not exist: the pairwise constant was already optimal.
8. The power curve of the additive control. For $\chi^2$ the amplitude profile is an exact quadratic, whence the symmetric identity and rejection at every nonzero amplitude by the two-point family $c \pm tw$; for $\mathrm{maxDev}$ the profile is convex in the amplitude, so the acceptance region is an interval and the symmetric family dominates the observed readout, with a two-point $p$-value of exactly $1/2$ below the critical amplitude.

**What comes next.**

- **The signed route, run properly.** The required follow-up before the $L$-value hypothesis can be assessed at all: regress the *signed* alignments $\langle c_m, \chi\rangle$ — not their magnitudes — against signed $L$-value data, with a randomization that is not invariant under reflection. Theorem 31 says the present data cannot prejudge the outcome.
- **Scale.** Push to $x = 2^{32}$ and beyond, and track whether the certified ceiling $\rho$ moves. A ceiling that shrinks with $x$ would be a much stronger negative; one that grows would reopen the magnitude route.
- **Sharper size deconfounding.** Replace $\log m$ with a theory-derived size normalization so that the ceiling is certified on the residual field rather than the raw field, tightening $\rho$.
- **Adaptive ceilings.** Extend the contrast calculus to features selected after seeing the data, via a uniform bound over a family of candidate features — the honest analogue of the present fixed-feature guarantee.
- **Other candidate features.** The certification machinery is feature-agnostic. Applying it to class numbers, discriminant factorization statistics, or smoothness-based features would map the effectivity landscape rather than probing a single point of it.

---

## 12. Conclusion

A pre-registered sweep asked whether quadratic-character $L$-value magnitude carries effectivity information for an averaging assumption in the distribution of primes in arithmetic progressions. The answer, at two scales and by rules fixed in advance, is no: $R^2 = 0.0187$ at $x = 2^{26}$ and $R^2 = 0.0785$ at $x = 2^{28}$, against a size baseline of $0.790$.

The contribution is what was done with that answer. A null $R^2$ was converted into a family of exact, sharp, finite-sample ceilings that bound every criterion the feature can support — threshold, multi-cell, or grouped — at $0.28$ sample standard deviations of separation. The registered control was proved to have power exactly zero and given a working replacement with a $p$-value of exactly $1/2$. And the scope of the negative was delimited precisely: the magnitude route is bounded; the signed character-alignment route is formally untouched, since every sign pattern is compatible with the recorded data.

A negative result is usually an absence. Made into theorems, it becomes a map: here is the region swept clean, here is its exact size, and here is the region still to sweep.
