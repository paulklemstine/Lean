# Effective Representations of the Euler–Mascheroni Constant: Positive Series, Integral Form, Quantitative Bounds, the Stieltjes Anchor, and a Diophantine Irrationality Criterion

**Author:** Aristotle
**Date:** 2026-06-26

## Abstract

The Euler–Mascheroni constant $\gamma = \lim_{n\to\infty}(H_n - \ln n) = 0.5772156649\ldots$ is among the most ubiquitous constants in mathematics, yet whether it is irrational remains a famous open problem. We present a self-contained, rigorously verified development of several complementary representations of $\gamma$ together with explicit quantitative control. First, we establish a **positive-term series** $\gamma = \sum_{k\ge 0}\big(\tfrac{1}{k+1} - \ln\tfrac{k+2}{k+1}\big)$ whose $n$-th partial sum is *exactly* the lower approximant $H_n - \ln(n+1)$, yielding strict monotonic convergence and a genuine summability certificate. Second, we recast each term as a unit-interval integral, producing the classical **integral representation** $\gamma = \int_1^\infty\big(\tfrac{1}{\lfloor x\rfloor} - \tfrac1x\big)\,dx$. Third, we prove an **effective error bound**: for all $n\ge 1$, $0 < \gamma - (H_n - \ln(n+1)) < \ln(n+1)-\ln n < 1/n$, with a matching two-sided bracket. Fourth, we formalize the **Stieltjes constants** $\gamma_m$ and prove that the zeroth one equals $\gamma$, anchoring the entire hierarchy. Finally, we develop the abstract **Diophantine irrationality engine** — a real number is irrational iff it admits arbitrarily small nonzero integer linear forms — and specialize it to $\gamma$, making precise exactly what an irrationality proof must produce and diagnosing why the known logarithmic approximants do not suffice. All results have been mechanically verified.

## 1. Introduction

Euler introduced the constant now bearing his and Mascheroni's name in 1734, defining it as the limiting gap between the harmonic numbers and the natural logarithm:

$$\gamma := \lim_{n\to\infty}\left(H_n - \ln n\right), \qquad H_n = \sum_{k=1}^n \frac1k.$$

The constant pervades analytic number theory (as the constant term in the Laurent expansion of $\zeta$ at $s=1$, and in Mertens' theorems), special-function theory (the digamma function satisfies $\psi(1) = -\gamma$), probability, physics, and the analysis of algorithms. Despite its centrality, the arithmetic nature of $\gamma$ is unknown: it is not known to be irrational, let alone transcendental.

This paper does not resolve that question. Instead it provides a clean, fully verified toolkit around $\gamma$ with three goals: (i) to convert the *limit* definition into honest convergent representations (a positive series and an integral) carrying constructive certificates; (ii) to make the convergence *effective* with explicit, monotone, two-sided rational-rate error bounds; and (iii) to situate $\gamma$ both within the Stieltjes hierarchy and within a precise Diophantine framework that states exactly what an irrationality proof of $\gamma$ must establish — and why the natural approximants fall short.

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$, $\ln$ is the natural logarithm with the convention $\ln 0 = 0$ used by the underlying library, $H_n$ is the $n$-th harmonic number with $H_0 = 0$, and $\lfloor\cdot\rfloor$ is the floor function.

### 1.1 Context and motivation

Three features make $\gamma$ unusually resistant to elementary analysis, and they motivate the structure of this paper.

First, $\gamma$ is defined as a *difference of two divergent quantities*. Both $H_n$ and $\ln n$ tend to $+\infty$; only their difference converges. Any computation or estimate must therefore manage a delicate cancellation, and a naive evaluation accumulates catastrophic round-off. Recasting $\gamma$ as a sum of manifestly positive terms (Section 3) or as a positive-integrand integral (Section 4) removes the cancellation entirely: each contribution is individually meaningful and nonnegative.

Second, the natural approximants converge *slowly*. As we make precise in Section 5, the lower approximant $\mathrm{seq}(n)$ approaches $\gamma$ at rate exactly $\Theta(1/n)$. This is in stark contrast to constants such as $e$, whose Taylor partial sums converge super-geometrically, or $\zeta(3)$, where Apéry's celebrated 1978 argument exploits approximants converging geometrically. Slow convergence is not merely an inconvenience: the rate of rational approximation is precisely the quantity that irrationality and transcendence proofs exploit.

Third, and most decisively, the known approximants are *not rational*. Both $\mathrm{seq}(n) = H_n - \ln(n+1)$ and $\mathrm{seq}'(n) = H_n - \ln n$ contain a transcendental logarithm. As Section 7 explains, an irrationality proof needs integer or rational data of a controlled denominator; the logarithmic approximants, however tightly they bracket $\gamma$, do not supply it. This is the structural heart of why $\gamma$'s irrationality is open while superficially similar constants have yielded.

The remainder of the paper systematically addresses these three points: positivity (Sections 3–4), effective rate (Section 5), placement within a richer family (Section 6), and the exact Diophantine obstruction (Section 7), closing with a worked numerical illustration (Section 8).

## 2. Preliminaries

We work with two standard one-sided approximants to $\gamma$:

$$\mathrm{seq}(n) := H_n - \ln(n+1), \qquad \mathrm{seq}'(n) := H_n - \ln n \ \ (n\ge 1).$$

We take as given the following classical facts (each available in the formalized real-analysis library and used as the foundation here):

- **(P1) Two-sided trapping:** for every $n$, $\ \mathrm{seq}(n) < \gamma < \mathrm{seq}'(n)$.
- **(P2) Convergence:** $\mathrm{seq}(n) \to \gamma$ and $\mathrm{seq}'(n) \to \gamma$ as $n\to\infty$.
- **(P3) Tangent-line bound:** for all $x>0$ with $x\ne 1$, $\ \ln x < x - 1$ (strict), and for all $x>0$, $\ln x \le x-1$.

Fact (P3) is the workhorse convexity inequality; (P1)–(P2) provide the analytic backbone we upgrade into effective and structural statements.

## 3. A positive-term series representation

We define the building block of the series.

**Definition 3.1 (Series term).** For $k\in\mathbb{N}$,
$$g_k := \frac{1}{k+1} - \big(\ln(k+2) - \ln(k+1)\big) = \frac{1}{k+1} - \ln\!\left(1+\frac{1}{k+1}\right).$$

**Lemma 3.2 (Strict positivity; `gterm_pos`).** For every $k\in\mathbb{N}$, $g_k > 0$.

*Proof sketch.* Write $g_k = \tfrac{1}{k+1} - \ln\frac{k+2}{k+1}$. Apply the strict tangent-line bound (P3) at $x = \frac{k+2}{k+1} > 0$, $x\ne 1$: $\ln\frac{k+2}{k+1} < \frac{k+2}{k+1} - 1 = \frac{1}{k+1}$. Rearranging gives $g_k > 0$. $\quad\square$

**Lemma 3.3 (Telescoping partial sum; `gterm_partial`).** For every $n\in\mathbb{N}$,
$$\sum_{k=0}^{n-1} g_k = H_n - \ln(n+1) = \mathrm{seq}(n).$$

*Proof sketch.* Induction on $n$. The base case $n=0$ is $0=0$. For the step, $\sum_{k=0}^{n} g_k = \mathrm{seq}(n) + g_n$; using $H_{n+1} = H_n + \tfrac{1}{n+1}$ and $\ln(n+2)-\ln(n+1)$ from $g_n$, the logarithms recombine to $\ln(n+2)$ and the reciprocals to $H_{n+1}$, giving $\mathrm{seq}(n+1)$. Equivalently, the logarithmic differences telescope: $\sum_{k=0}^{n-1}\big(\ln(k+2)-\ln(k+1)\big) = \ln(n+1)$. $\quad\square$

**Theorem 3.4 (Series representation; `hasSum_gterm`).** The series $\sum_k g_k$ converges to $\gamma$:
$$\sum_{k=0}^{\infty} g_k = \gamma, \qquad\text{equivalently}\qquad \gamma = \sum_{k=0}^\infty\left(\frac{1}{k+1} - \ln\frac{k+2}{k+1}\right).$$

*Proof sketch.* By Lemma 3.2 the terms are nonnegative, and by Lemma 3.3 every partial sum equals $\mathrm{seq}(n)$, which by (P1) is bounded above by $\gamma$. Hence the partial sums are nondecreasing and bounded, so $\sum_k g_k$ is **summable**. Its sum is the limit of its partial sums; but the partial sums equal $\mathrm{seq}(n)$, which by (P2) tends to $\gamma$. Uniqueness of limits identifies the sum as $\gamma$. $\quad\square$

Two immediate corollaries record structural consequences.

**Corollary 3.5 (Strict monotonicity; `strictMono_eulerMascheroniSeq`).** $\mathrm{seq}$ is strictly increasing: $\mathrm{seq}(n) < \mathrm{seq}(n+1)$ for all $n$.

*Proof sketch.* $\mathrm{seq}(n+1) - \mathrm{seq}(n) = g_n > 0$ by Lemmas 3.3 and 3.2. $\quad\square$

**Corollary 3.6 (Exact increment; `eulerMascheroniSeq_succ_sub`).** $\mathrm{seq}(n+1) - \mathrm{seq}(n) = g_n$.

These results convert the limit definition of $\gamma$ into a monotone, certified, positive-term series — the "Apéry-flavored" picture in which the rational engine is $H_n$ and the correction is a single logarithm.

## 4. Integral representation

We now recast each series term as an area, recovering the classical integral form.

**Lemma 4.1 (Integrand nonnegativity; `integrand_nonneg`).** For $k\in\mathbb{N}$ and $x \ge k+1$, $\ \tfrac{1}{k+1} - \tfrac1x \ge 0$.

*Proof sketch.* Since $0 < k+1 \le x$, monotonicity of $t\mapsto 1/t$ on positives gives $\tfrac1x \le \tfrac{1}{k+1}$. $\quad\square$

**Theorem 4.2 (Term as integral; `gterm_eq_integral`).** For every $k\in\mathbb{N}$,
$$g_k = \int_{k+1}^{\,k+2}\left(\frac{1}{k+1} - \frac1x\right)dx.$$

*Proof sketch.* The integrand splits into a constant and $-1/x$. On $[k+1,k+2]$ we have $0\notin[k+1,k+2]$, so $1/x$ is interval-integrable with $\int_{k+1}^{k+2}\tfrac1x\,dx = \ln(k+2)-\ln(k+1)$, while $\int_{k+1}^{k+2}\tfrac{1}{k+1}\,dx = \tfrac{1}{k+1}$. Subtracting gives exactly $g_k$. $\quad\square$

**Theorem 4.3 (Integral representation; `hasSum_integral_repr`).**
$$\gamma = \sum_{k=0}^{\infty}\int_{k+1}^{\,k+2}\left(\frac{1}{k+1}-\frac1x\right)dx = \int_{1}^{\infty}\left(\frac{1}{\lfloor x\rfloor}-\frac1x\right)dx.$$

*Proof sketch.* Substitute Theorem 4.2 termwise into Theorem 3.4. Each summand is the integral over the unit window $[k+1,k+2]$, where $\lfloor x\rfloor = k+1$, so the integrand coincides with $\tfrac{1}{\lfloor x\rfloor} - \tfrac1x$; concatenating the windows yields the improper integral over $[1,\infty)$. Nonnegativity of the integrand (Lemma 4.1) mirrors term positivity. $\quad\square$

**Proposition 4.4 (Integral partial sums bracket $\gamma$; `integral_partialSum_lt_lt_seq'`).** For every $n$,
$$\sum_{k=0}^{n-1}\int_{k+1}^{\,k+2}\left(\frac{1}{k+1}-\frac1x\right)dx \;<\; \gamma \;<\; \mathrm{seq}'(n).$$

*Proof sketch.* By Theorem 4.2 and Lemma 3.3 the left sum equals $\mathrm{seq}(n)$; apply the trapping (P1). $\quad\square$

Thus the discrete and continuous pictures agree term by term, and the integral partial sums furnish the same lower approximants used elsewhere.

## 5. Effective error bounds

We quantify the convergence rate explicitly.

**Lemma 5.1 (Bracket width; `eulerMascheroni_trap_width_eq`).** For $n\ge 1$,
$$\mathrm{seq}'(n) - \mathrm{seq}(n) = \ln(n+1) - \ln n.$$

*Proof sketch.* Direct computation: $(H_n - \ln n) - (H_n - \ln(n+1)) = \ln(n+1)-\ln n$ for $n\ge 1$ (where $\mathrm{seq}'$ uses its non-junk value). $\quad\square$

**Theorem 5.2 (Effective lower error; `eulerMascheroniConstant_sub_seq_lt`).** For $n\ge 1$,
$$0 < \gamma - \mathrm{seq}(n) < \ln(n+1) - \ln n.$$

*Proof sketch.* Positivity is the left half of (P1). For the upper bound, $\gamma - \mathrm{seq}(n) < \mathrm{seq}'(n) - \mathrm{seq}(n)$ by the right half of (P1), and the right side equals the width by Lemma 5.1. $\quad\square$

**Theorem 5.3 (Effective upper error; `seq'_sub_eulerMascheroniConstant_lt`).** For $n\ge 1$,
$$0 < \mathrm{seq}'(n) - \gamma < \ln(n+1) - \ln n.$$

*Proof sketch.* Symmetric to Theorem 5.2 using both halves of (P1) and Lemma 5.1. $\quad\square$

**Corollary 5.4 (Rational $1/n$ bound).** For $n\ge 1$,
$$0 < \gamma - \big(H_n - \ln(n+1)\big) < \frac1n, \qquad \big|\,\mathrm{seq}(n) - \gamma\,\big| < \frac1n.$$

*Proof sketch.* By the strict tangent-line bound (P3) at $x = \tfrac{n+1}{n}$, $\ \ln(n+1)-\ln n = \ln\tfrac{n+1}{n} < \tfrac{n+1}{n} - 1 = \tfrac1n$. Combine with Theorem 5.2. The absolute-value form is the companion statement `abs_eulerMascheroniSeq_sub_lt`. $\quad\square$

These bounds are *effective*: given $n$ one can compute $H_n$ and rational enclosures of the logarithm to bracket $\gamma$ to within $1/n$. The rate is only $O(1/n)$ — far slower than the geometric rates underlying irrationality proofs of $e$ or $\zeta(3)$ — but it is fully certified and monotone.

## 6. The Stieltjes anchor

The Stieltjes constants generalize the harmonic-minus-logarithm construction.

**Definition 6.1 (Stieltjes sequence; `stieltjesSeq`).** For $m,n\in\mathbb{N}$,
$$S_m(n) := \sum_{k=1}^{n}\frac{(\ln k)^m}{k} - \frac{(\ln n)^{m+1}}{m+1}.$$
The $m$-th Stieltjes constant is $\gamma_m := \lim_{n\to\infty} S_m(n)$.

These constants are the Laurent coefficients of the Riemann zeta function at its pole:
$$\zeta(s) = \frac{1}{s-1} + \sum_{m=0}^{\infty}\frac{(-1)^m}{m!}\,\gamma_m\,(s-1)^m.$$

**Lemma 6.2 (Collapse at $m=0$; `stieltjesSeq_zero_eq`).** For every $n$, $\ S_0(n) = H_n - \ln n$.

*Proof sketch.* With $m=0$, $(\ln k)^0 = 1$ so the sum is $\sum_{k=1}^n \tfrac1k = H_n$, and the correction term is $\tfrac{(\ln n)^1}{1} = \ln n$. $\quad\square$

**Lemma 6.3 (Agreement with upper approximant; `stieltjesSeq_zero_eq_seq'`).** For $n\ge 1$, $\ S_0(n) = \mathrm{seq}'(n)$.

*Proof sketch.* Immediate from Lemma 6.2 and the definition of $\mathrm{seq}'$ on $n\ge 1$. $\quad\square$

**Theorem 6.4 (Zeroth Stieltjes constant is $\gamma$; `tendsto_stieltjesSeq_zero`).**
$$\gamma_0 = \lim_{n\to\infty} S_0(n) = \gamma.$$

*Proof sketch.* By Lemma 6.3, $S_0$ and $\mathrm{seq}'$ agree for all $n\ge 1$, i.e. eventually. Since $\mathrm{seq}'\to\gamma$ by (P2), the eventually-equal sequence $S_0$ has the same limit. The only subtlety is the corner $n=0$ (where $\ln 0 = 0$ forces $S_0(0)=0$ while $\mathrm{seq}'(0)$ uses a junk value); eventual equality on $n\ge 1$ is exactly what is needed. $\quad\square$

**Proposition 6.5 (Upper bracketing; `eulerMascheroniConstant_lt_stieltjesSeq_zero`).** For $n\ge 1$, $\ \gamma < S_0(n)$.

This identifies $\gamma$ as the base of the Stieltjes hierarchy and provides a third family of approximants converging to it.

## 7. A Diophantine irrationality criterion for $\gamma$

We isolate the abstract mechanism behind irrationality proofs and specialize it.

**Theorem 7.1 (Irrationality engine, sufficient form; `irrational_of_forall_eps_linear_form`).** Let $x\in\mathbb{R}$. If for every $\varepsilon>0$ there exist $q\in\mathbb{N}$ with $q\ge 1$ and $p\in\mathbb{Z}$ such that
$$0 < |q x - p| < \varepsilon,$$
then $x$ is irrational.

*Proof sketch.* Contrapositive. If $x = a/b$ with $b\ge 1$, then for any integers $q,p$ the quantity $qx - p = (qa - pb)/b$ is a rational with denominator $b$; if nonzero, $|qx-p|\ge 1/b$. Choosing $\varepsilon = 1/b$ leaves no room for a nonzero form below $\varepsilon$, contradicting the hypothesis. A sequence form (`irrational_of_tendsto_linear_form`) states the same with integer forms $q_n x - p_n \ne 0$ tending to $0$ and $q_n \ge 1$. $\quad\square$

**Theorem 7.2 (Necessary form via Dirichlet; `forall_eps_linear_form_of_irrational`).** If $x$ is irrational, then for every $\varepsilon>0$ there exist $q\ge 1$ and $p\in\mathbb{Z}$ with $0 < |qx-p| < \varepsilon$.

*Proof sketch.* Dirichlet's approximation theorem yields $q\ge 1$ with $|qx - \mathrm{round}(qx)| < \varepsilon$; irrationality of $x$ guarantees this form is nonzero. $\quad\square$

**Theorem 7.3 (Characterization; `irrational_iff_forall_eps_linear_form`).** For every $x\in\mathbb{R}$,
$$x\ \text{is irrational}\iff \forall \varepsilon>0,\ \exists\, q\ge 1,\ p\in\mathbb{Z}:\ 0 < |qx-p| < \varepsilon.$$

**Theorem 7.4 (Specialization to $\gamma$; `irrational_eulerMascheroniConstant_iff`).**
$$\gamma\ \text{is irrational}\iff \forall \varepsilon>0,\ \exists\, q\ge 1,\ p\in\mathbb{Z}:\ 0 < |q\gamma - p| < \varepsilon.$$

We also record the elementary structural facts that any analysis of $\gamma$ may use: $0 < \gamma$ (`eulerMascheroniConstant_pos`), $\gamma < 1$ (`eulerMascheroniConstant_lt_one`), the combined sandwich $\mathrm{seq}(n) < \gamma < \mathrm{seq}'(n)$ (`eulerMascheroniSeq_sandwich`), and that the trapping interval width tends to $0$ (`tendsto_eulerMascheroni_trap_width`).

**The structural obstruction.** Theorem 7.4 states the exact Diophantine target. Yet the natural approximants from Sections 3–6 — $\mathrm{seq}(n) = H_n - \ln(n+1)$ and $\mathrm{seq}'(n) = H_n - \ln n$ — bracket $\gamma$ in an interval of width $\ln(1+1/n)\to 0$ whose **endpoints are transcendental** (they carry a logarithm), not rational. They therefore do not directly feed the engine of Theorem 7.4, which requires integer/rational data. This is a precise diagnosis of why $\gamma$'s irrationality is hard: the obstruction is not the convergence speed per se but the absence of approximants with controlled rational denominators and width $o(1/q)$.

## 8. Numerical illustration

We record concrete values that exhibit each theorem in action; all figures are consistent with the reference value $\gamma = 0.5772156649\ldots$

**Telescoping (Lemma 3.3).** The first five series terms are
$$g_0 \approx 0.306853,\quad g_1 \approx 0.094535,\quad g_2 \approx 0.045651,\quad g_3 \approx 0.026856,\quad g_4 \approx 0.017678,$$
all strictly positive and decreasing like $g_k \sim \tfrac{1}{2(k+1)^2}$. Their cumulative sums reproduce $\mathrm{seq}(n)$ exactly: $\sum_{k<10} g_k = \mathrm{seq}(10) = 0.531073\ldots$ and $\sum_{k<1000} g_k = \mathrm{seq}(1000) = 0.576716\ldots$

**Effective bracket (Section 5).** The table below shows the two-sided enclosure and the certified bound:

| $n$ | $\mathrm{seq}(n)$ | $\mathrm{seq}'(n)$ | $\gamma - \mathrm{seq}(n)$ | $1/n$ |
|---|---|---|---|---|
| $10$ | $0.531073$ | $0.626383$ | $4.61\times10^{-2}$ | $1.0\times10^{-1}$ |
| $100$ | $0.572257$ | $0.582207$ | $4.96\times10^{-3}$ | $1.0\times10^{-2}$ |
| $1000$ | $0.576716$ | $0.577716$ | $5.00\times10^{-4}$ | $1.0\times10^{-3}$ |
| $10000$ | $0.577166$ | $0.577266$ | $5.00\times10^{-5}$ | $1.0\times10^{-4}$ |

The error is consistently about half the bound $1/n$, reflecting the sharper asymptotic $\gamma - \mathrm{seq}(n) \sim \tfrac{1}{2n}$; the inequality $\gamma - \mathrm{seq}(n) < 1/n$ of Corollary 5.4 holds with room to spare, and $\mathrm{seq}(n) < \gamma < \mathrm{seq}'(n)$ holds at every row.

**Integral form (Theorem 4.3).** A composite midpoint rule applied windowwise to $\int_{k+1}^{k+2}(\tfrac{1}{k+1} - \tfrac1x)\,dx$ reproduces each $g_k$ to ten digits, and summing the first $5000$ windows yields $0.577116\ldots$, consistent with convergence to $\gamma$ at the expected $O(1/n)$ truncation rate.

**Stieltjes anchor (Theorem 6.4).** The sequence $S_0(n) = H_n - \ln n$ decreases to $\gamma$ from above: $S_0(100) = 0.582207$, $S_0(1000) = 0.577716$, $S_0(10000) = 0.577266$, with $S_0(n) - \gamma \approx \tfrac{1}{2n}$, confirming Proposition 6.5.

These computations are not proofs but consistency checks; the certified statements are Theorems 3.4, 4.3, 6.4 and Corollary 5.4.

## 9. Discussion

The development above accomplishes three things. (1) It upgrades the *limit* definition of $\gamma$ into two honest, certified representations — a positive monotone series (Theorem 3.4) and an integral over the floor-staircase (Theorem 4.3) — that agree term by term. (2) It makes the convergence quantitative and two-sided with a clean $1/n$ rational bound (Corollary 5.4). (3) It places $\gamma$ as the anchor $\gamma_0$ of the Stieltjes hierarchy (Theorem 6.4) and within an exact Diophantine framework (Theorem 7.4) that pinpoints what an irrationality proof must construct and why current approximants fall short.

None of these results settles the irrationality of $\gamma$, which remains open. Their value is in providing rigorous, reusable infrastructure — summability certificates, effective bounds, and a Diophantine criterion — on which sharper approximation schemes can be built and tested.

We also highlight the *complementarity* of the representations. The series (Section 3) is best for monotone lower bounds and for exhibiting summability; the integral (Section 4) is best for connecting $\gamma$ to the geometry of the floor-staircase and for analytic manipulation; the Stieltjes sequence (Section 6) embeds $\gamma$ in the spectral data of $\zeta$; and the Diophantine criterion (Section 7) reframes the open problem as a concrete existence statement about integer linear forms. Each viewpoint suggests a different attack, and a future advance may well combine them — for instance, using the integral form to engineer rational approximants whose denominators are controlled, thereby feeding the engine of Section 7.

Finally, we stress what is *not* claimed. We do not prove $\gamma$ irrational, nor do we improve the $O(1/n)$ convergence rate within the verified development; the midpoint acceleration of the next section is conjectural. The contribution is infrastructural: certified representations and bounds that are correct beyond doubt and reusable as building blocks.

## 10. Future work

Several concrete directions extend this development, each falsifiable in a formal setting:

- **Quadratic-rate acceleration.** Center the logarithm at the midpoint: conjecturally the shifted partial sums $H_n - \ln(n+\tfrac12)$ satisfy $|\gamma - (H_n - \ln(n+\tfrac12))| < \tfrac{1}{24n^2}$, an $O(1/n^2)$ improvement over Corollary 5.4 obtained by a midpoint-quadrature cancellation of the leading $O(1/n)$ error. The same tangent-line machinery (P3) applies directly.
- **Strictly interior term bounds.** Sharpen interval memberships of the soft-max / log-gap terms from closed to open, upgrading $\le$ to strict $<$ via the strict form of (P3).
- **Temperature-deformed $\gamma$.** Study a one-parameter family $\gamma(c) := \sum_{k\ge1}\big(\tfrac1k - \mathrm{softMax}_c(0,-\ln k)\big)$ interpolating between the analytic log-sum-exp ($c=1$, giving $\gamma$) and a hard-max tropical limit ($c\to\infty$), exhibiting $\gamma$ on a dequantization family.
- **Stieltjes telescoping certificates.** Extend the telescoping identity of Lemma 3.3 to $\gamma_1$: conjecturally $\gamma_1 = \sum_{k\ge1}\big(-\tfrac{\ln k}{k} + \tfrac{\ln^2(k+1)-\ln^2 k}{2}\big)$ with partial sums $\sum_{j\le n}\tfrac{\ln j}{j} - \tfrac{\ln^2(n+1)}{2}$ and an $O(\ln n / n)$ effective bound, using that $\tfrac{d}{dx}\tfrac{\ln^2 x}{2} = \tfrac{\ln x}{x}$.

## References

The constructions and statements above are self-contained. Standard background — the harmonic numbers, Dirichlet's approximation theorem, the tangent-line inequality $\ln x \le x-1$, interval integration of $1/x$, and the Laurent expansion of $\zeta$ at $s=1$ — is classical and reproduced inline where used.
