# Asymptotic Expansions of Weighted Riesz Means: A Transfer Principle and Power–Logarithm Model Laws

## Abstract

We develop, from first principles, the analytic engine behind asymptotic expansions of *weighted Riesz means* of arithmetic sequences, in the regime governing the average behavior of arithmetic functions such as Hurwitz class numbers and the coefficients of half-integral weight Maass forms. The organizing principle is that a suitably weighted mean of an arithmetic function behaves like $C\,X^{\alpha}(\log X)^{k}$ as $X\to\infty$, where the power $\alpha$ and the logarithmic order $k$ are determined by the location and order of the dominant singularity of the associated Dirichlet series. We isolate and prove two clean model regimes that already exhibit both features — a pure power law and a pure logarithmic law — together with the mixed law that displays both exponents nontrivially. The centerpiece is a **Riesz-mean transfer principle**: partial summation preserves asymptotic equivalence, provided the reference sequence is eventually positive with divergent partial sums. Its proof rests on a Stolz–Cesàro theorem for the little-o relation. We show the transfer principle in action by deriving a genuine second-order Riesz mean, $\sum_{n<N}\sum_{m<n} m^{p} \sim N^{p+2}/((p+1)(p+2))$, from the first-order power law. We discuss algorithms for computing these means, numerical validation, and the path toward the Hurwitz / sesquiharmonic Maass-form target.

**Keywords.** Riesz mean, Cesàro mean, asymptotic equivalence, Stolz–Cesàro theorem, Euler–Maclaurin summation, power–logarithm asymptotics, Hurwitz class numbers, Dirichlet series.

---

## 1. Introduction

A recurring theme across analytic number theory is that an arithmetic function $a:\mathbb{N}\to\mathbb{R}$ may be highly irregular pointwise, while its summatory function

$$A(X) = \sum_{n \le X} a(n)$$

obeys a smooth asymptotic law. For an enormous class of naturally occurring sequences that law has the shape

$$A(X) \sim C\, X^{\alpha} (\log X)^{k}, \qquad X \to \infty, \tag{1.1}$$

where the constant $C>0$, the power $\alpha$, and the logarithmic order $k \in \mathbb{Z}_{\ge 0}$ are governed by the analytic behavior of the Dirichlet series $\sum_{n\ge1} a(n) n^{-s}$ near its rightmost singularity: $\alpha$ is the abscissa of the pole, and $k+1$ is (essentially) its order. Throughout, $f \sim g$ denotes asymptotic equivalence, i.e. $f(N)/g(N) \to 1$; and $f = o(g)$ (little-o) means $f(N)/g(N) \to 0$.

This paper isolates the *analytic core* of (1.1) — the part that is independent of any particular arithmetic input — and proves it rigorously. There are two distinct tasks:

1. **Model laws.** Establish (1.1) for the canonical building-block sequences $a(n) = n^p$ (pure power), $a(n) = \log n$ (pure logarithm), and $a(n) = n^p\log n$ (mixed), pinning down $\alpha$, $k$, and $C$ in each.
2. **A transfer principle.** Prove that (1.1) is *stable under summation*: if $a(n) \sim b(n)$ and $b$ has divergent partial sums, then $\sum_{n<N} a(n) \sim \sum_{n<N} b(n)$. This is what allows a growth law for raw counts to be transported to any smoothly weighted mean built on top of them, and it is what makes higher-order (iterated) Riesz means tractable.

The results are elementary in their hypotheses but structural in their consequences: together they form a reusable engine for producing asymptotic expansions of weighted averages.

### 1.1 Context: Riesz and Cesàro means

Given $a:\mathbb N\to\mathbb R$ and a real order $r\ge 0$, the **Riesz mean** of order $r$ is

$$R_r(X) = \frac{1}{X^{r}}\sum_{n\le X}\left(X-n\right)^{r} a(n),$$

a smoothed average that suppresses the oscillations present in the raw partial sums $\sum_{n\le X}a(n)$ (the case $r=0$). Riesz means of positive order converge under weaker hypotheses than ordinary partial sums and are the standard device for extracting main terms from delicate arithmetic sums. Iterated summation, $\sum_{n<N}\sum_{m<n}(\cdots)$, is the discrete analogue of an integer-order Riesz mean, and the transfer principle below is exactly the tool that propagates an asymptotic through one such layer of smoothing.

---

## 2. Definitions and conventions

Throughout, all sequences are real-valued functions on $\mathbb N = \{0,1,2,\dots\}$, and all limits are taken along the filter of $N\to\infty$.

**Definition 2.1 (Little-o).** For $h,g:\mathbb N\to\mathbb R$ we write $h = o(g)$ if for every $\varepsilon>0$ there is $M$ with $|h(n)| \le \varepsilon\,|g(n)|$ for all $n\ge M$. When $g$ is eventually nonzero this is equivalent to $h(n)/g(n)\to 0$.

**Definition 2.2 (Asymptotic equivalence).** We write $f \sim g$ if $f - g = o(g)$. When $g$ is eventually nonzero this is equivalent to $f(N)/g(N) \to 1$.

**Definition 2.3 (Partial sums).** For a sequence $a$, its summatory sequence is $\displaystyle S_a(N) = \sum_{n < N} a(n) = \sum_{n=0}^{N-1} a(n)$.

**Definition 2.4 (Real powers).** For a real exponent $p$ and integer $n\ge 1$, $n^{p} := \exp(p\log n)$, with the convention $0^{p} = 0$ for $p>0$. This is the standard continuous power that makes $x\mapsto x^p$ smooth on $(0,\infty)$.

We use two standard facts freely: a sum of increasing terms is trapped between two integrals of the corresponding continuous function (the Euler–Maclaurin sandwich), and the fundamental theorem of calculus for the explicit antiderivatives below.

---

## 3. The transfer engine

### 3.1 Stolz–Cesàro for little-o

**Theorem 3.1 (Stolz–Cesàro for little-o).** Let $h,g:\mathbb N\to\mathbb R$. Suppose

- $h = o(g)$ as $n\to\infty$;
- $g(n) > 0$ for all sufficiently large $n$; and
- $S_g(N) = \sum_{n<N} g(n) \to +\infty$ as $N\to\infty$.

Then $S_h = o(S_g)$, i.e. $\displaystyle \sum_{n<N} h(n) = o\!\left(\sum_{n<N} g(n)\right).$

*Proof sketch.* Fix $\varepsilon>0$. By $h=o(g)$ and eventual positivity of $g$, choose $M$ so that $|h(n)| \le \tfrac{\varepsilon}{2} g(n)$ for all $n\ge M$. Split the partial sum at $M$:

$$\sum_{n<N} h(n) = \sum_{n<M} h(n) + \sum_{M\le n<N} h(n).$$

The tail is controlled termwise:

$$\left|\sum_{M\le n<N} h(n)\right| \le \sum_{M\le n<N} |h(n)| \le \frac{\varepsilon}{2}\sum_{M\le n<N} g(n) = \frac{\varepsilon}{2}\big(S_g(N) - S_g(M)\big).$$

Hence $\big|S_h(N)\big| \le |S_h(M)| + \tfrac{\varepsilon}{2}\big(S_g(N)-S_g(M)\big)$. The head $|S_h(M)| + \tfrac{\varepsilon}{2}|S_g(M)|$ is a fixed constant, while $S_g(N)\to+\infty$; so for $N$ large enough this constant is $\le \tfrac{\varepsilon}{2}S_g(N)$, giving $|S_h(N)| \le \varepsilon\, S_g(N)$. As $\varepsilon$ was arbitrary, $S_h = o(S_g)$. $\qquad\blacksquare$

### 3.2 The Riesz-mean transfer

**Theorem 3.2 (Riesz-mean transfer).** Let $f,g:\mathbb N\to\mathbb R$ with $f \sim g$. Suppose $g$ is eventually positive and $S_g(N)\to+\infty$. Then

$$\sum_{n<N} f(n) \ \sim\ \sum_{n<N} g(n).$$

*Proof sketch.* Apply Theorem 3.1 to $h := f - g$. Since $f\sim g$ means $f-g = o(g)$, we get $\sum_{n<N}(f-g)(n) = o\!\big(\sum_{n<N} g(n)\big)$. But $\sum_{n<N}(f-g)(n) = S_f(N) - S_g(N)$ by linearity, so $S_f - S_g = o(S_g)$, which is precisely $S_f \sim S_g$. $\qquad\blacksquare$

This is the abstract heart of the paper: asymptotic equivalence is *closed under summation* whenever the reference sequence accumulates without bound. The positivity and divergence hypotheses cannot be dropped — for oscillating or convergent $g$, cancellation and boundary effects can destroy the equivalence.

---

## 4. Model laws

### 4.1 The pure power law ($k = 0$)

**Theorem 4.1 (Power law).** For every real $p > 0$,

$$\sum_{n<N} n^{p} \ \sim\ \frac{N^{p+1}}{p+1}.$$

Here $\alpha = p+1$ and $k = 0$: pure power growth, no logarithm.

*Proof sketch.* The function $x\mapsto x^p$ is increasing on $[0,\infty)$, so for each integer $n$,

$$\int_{n-1}^{n} x^p\,dx \le n^{p} \le \int_{n}^{n+1} x^p\,dx.$$

Summing over $1\le n < N$ sandwiches the partial sum:

$$\int_{0}^{N-1} x^p\,dx \ \le\ \sum_{n<N} n^{p} \ \le\ \int_{0}^{N} x^p\,dx,$$

that is, $\dfrac{(N-1)^{p+1}}{p+1} \le \sum_{n<N} n^p \le \dfrac{N^{p+1}}{p+1}$. Dividing by $N^{p+1}/(p+1)$, both bounds tend to $1$ because $((N-1)/N)^{p+1}\to 1$. The squeeze theorem yields the claim. $\qquad\blacksquare$

**Theorem 4.2 (Divergence of power sums).** For every real $p>0$, $\displaystyle \sum_{n<N} n^{p} \to +\infty$.

*Proof sketch.* The series $\sum_{n\ge 1} n^{p}$ diverges (its terms $n^p\to\infty$ do not even tend to $0$), and its terms are nonnegative; hence its partial sums tend to $+\infty$. $\qquad\blacksquare$

Theorems 4.1–4.2 supply exactly the hypotheses needed to feed $g(n)=n^p$ into the transfer engine.

### 4.2 The pure logarithmic law ($k = 1$)

**Theorem 4.3 (Logarithmic law — Stirling's leading term).**

$$\sum_{n<N} \log n \ \sim\ N \log N.$$

Here $\alpha = 1$ and $k = 1$: the logarithm appears in its purest form.

*Proof sketch.* Again by monotonicity of $\log$ on $[1,\infty)$, an integral sandwich gives

$$\int_{1}^{N} \log x\,dx \le \sum_{n<N}\log n \le \int_{1}^{N}\log x\,dx + \log N,$$

and $\int_1^N \log x\,dx = N\log N - N + 1$. Dividing by $N\log N$, the dominant term is $\dfrac{N\log N}{N\log N}=1$, while $\dfrac{-N+1}{N\log N}\to 0$ and $\dfrac{\log N}{N\log N}\to 0$. The squeeze gives $\sum_{n<N}\log n / (N\log N) \to 1$. $\qquad\blacksquare$

Since $\sum_{n<N}\log n = \log((N-1)!)$, Theorem 4.3 is precisely the leading term of Stirling's approximation, recast as an averaging statement.

### 4.3 The mixed power–logarithm law ($\alpha>1$, $k=1$)

**Theorem 4.4 (Mixed law).** For every real $p>0$,

$$\sum_{n<N} n^{p}\log n \ \sim\ \frac{N^{p+1}\log N}{p+1}.$$

Both exponents are nontrivial: $\alpha = p+1 > 1$ and $k = 1$. This is the smallest model realizing the full shape $C\,X^{\alpha}(\log X)^k$.

*Proof sketch.* The integrand $x\mapsto x^p\log x$ is increasing for $x\ge 1$, so the same one-step integral comparison holds:

$$\int_{n-1}^{n} x^p\log x\,dx \le n^p\log n \le \int_{n}^{n+1} x^p\log x\,dx \qquad (n\ge 2).$$

Summing over $2\le n<N$ yields

$$\int_{1}^{N-1} x^p\log x\,dx \ \le\ \sum_{2\le n<N} n^p\log n \ \le\ \int_{2}^{N} x^p\log x\,dx.$$

The explicit antiderivative

$$\int x^p \log x\,dx = \frac{x^{p+1}\log x}{p+1} - \frac{x^{p+1}}{(p+1)^2}$$

shows each integral equals $\dfrac{N^{p+1}\log N}{p+1}\big(1 + o(1)\big)$: the leading term is $\dfrac{x^{p+1}\log x}{p+1}$, and the correction $-\dfrac{x^{p+1}}{(p+1)^2}$ is of lower order (it lacks the $\log$ factor), as is the discrepancy between the two integration ranges. Dividing by $N^{p+1}\log N/(p+1)$ and squeezing gives the result. $\qquad\blacksquare$

---

## 5. Iterated Riesz means: the transfer principle in action

**Theorem 5.1 (Second-order power mean).** For every real $p>0$,

$$\sum_{n<N}\ \sum_{m<n} m^{p} \ \sim\ \frac{N^{p+2}}{(p+1)(p+2)}.$$

*Proof sketch.* Let $b(n) = \sum_{m<n} m^p$. By Theorem 4.1, $b(n) \sim n^{p+1}/(p+1)$. The reference sequence $g(n) = n^{p+1}/(p+1)$ is eventually positive, and by Theorem 4.2 (applied with exponent $p+1$) its partial sums diverge. Theorem 3.2 (transfer) therefore gives

$$\sum_{n<N} b(n) \ \sim\ \sum_{n<N} \frac{n^{p+1}}{p+1} \ =\ \frac{1}{p+1}\sum_{n<N} n^{p+1}.$$

Applying Theorem 4.1 once more with exponent $p+1$, $\sum_{n<N} n^{p+1} \sim N^{p+2}/(p+2)$. Chaining the two equivalences yields $\sum_{n<N} b(n) \sim \dfrac{N^{p+2}}{(p+1)(p+2)}$. $\qquad\blacksquare$

The pattern is transparent: each layer of summation raises the exponent by one and multiplies the constant by the reciprocal of the new exponent. Iterating $r$ times produces the order-$r$ mean

$$\underbrace{\sum \cdots \sum}_{r+1} m^{p} \ \sim\ \frac{N^{p+r+1}}{(p+1)(p+2)\cdots(p+r+1)} = \frac{\Gamma(p+1)}{\Gamma(p+r+2)}\,N^{p+r+1},$$

the discrete analogue of the Beta-function normalization $B(\alpha,r+1)$ that appears in continuous Riesz means.

---

## 6. Algorithms

We record three algorithms implied by the theory: exact and asymptotic evaluation of the model sums, and the transfer-based computation of iterated means.

**Algorithm A (Direct power–log summation).** Given $N$ and parameters $p,k$, compute $\sum_{n<N} n^p (\log n)^k$ exactly by accumulation in $O(N)$ arithmetic operations, and compare against the closed-form main term. This validates the model laws numerically.

**Algorithm B (Asymptotic main term).** Given $X$ and the singularity data $(C,\alpha,k)$, return $C\,X^{\alpha}(\log X)^k$ in $O(1)$ time. For the model laws, $(C,\alpha,k)$ is read directly off Theorems 4.1, 4.3, 4.4.

**Algorithm C (Iterated Riesz mean via transfer).** To compute an order-$r$ mean, apply Algorithm A once to the innermost sum and then propagate through $r$ prefix-sum passes, each $O(N)$; the transfer principle guarantees the accumulated result matches the closed form $N^{p+r+1}\Gamma(p+1)/\Gamma(p+r+2)$ up to a $1+o(1)$ factor.

---

## 7. Numerical validation

For $p = 1.5$ and $N = 10^{6}$, the ratio $\big(\sum_{n<N} n^p\big)\big/\big(N^{p+1}/(p+1)\big)$ agrees with $1$ to within a relative error of order $N^{-1}$, consistent with the sandwich bounds. The mixed law is verified similarly: $\big(\sum_{n<N} n^p\log n\big)\big/\big(N^{p+1}\log N/(p+1)\big) \to 1$, with the convergence visibly slower than the pure power case because the lower-order term carries no $\log$ and thus decays only like $1/\log N$ relative to the main term. The logarithmic law reproduces Stirling's leading term to the expected accuracy, and the second-order mean matches $N^{p+2}/((p+1)(p+2))$. These experiments are carried out in the accompanying demonstration code.

---

## 8. Applications and discussion

The engine assembled here is domain-agnostic, and that is its point. Any arithmetic function whose Dirichlet series has a single dominant singularity of the model type inherits a summatory asymptotic of the shape (1.1), with $(\alpha,k)$ read off the singularity and $C$ from the residue. The transfer principle then extends this from raw partial sums to any smoothly weighted mean:

$$\sum_{n\le X} a(n)\,w(n),$$

whenever the weight $w$ is slowly varying, by pairing Theorem 3.2 with Abel summation. The model laws of Section 4 are the calibration standards against which finer results are measured, and Section 5 shows how arbitrary-order smoothing is generated by a single reusable step.

The motivating target is the family of **Hurwitz class numbers** $H(n)$, which weight the $\mathrm{SL}_2(\mathbb Z)$-classes of positive-definite integral binary quadratic forms of discriminant $-n$ by the reciprocal of the order of their automorphism group. The $H(n)$ are pointwise irregular, but their averages are smooth, and weighted averages $\sum_{n\le X} H(n)\,w(n)$ with weights arising from weight-$1/2$ (sesqui)harmonic Maass forms of moderate growth exhibit precisely the power–logarithm behavior (1.1), with $(\alpha,k)$ encoding the spectral parameters of the underlying form. The results here isolate the transfer and model-law layer of that program; the remaining, deeper layer is an asymptotic for the raw average of $H(n)$ itself, to which the engine then applies.

---

## 9. Future directions

This project formalizes the analytic engine behind asymptotic expansions of weighted Riesz means, in the model regimes that already exhibit both the power-law factor $X^\alpha$ and the logarithmic factor $(\log X)^k$ appearing in the target shape $C\cdot X^\alpha (\log X)^k$.

**Immediate extensions.**

1. *General log-powers $(\log X)^k$.* Prove $\sum_{n<N}(\log n)^k/n \sim (\log N)^{k+1}/(k+1)$ by the same integral sandwich with antiderivative $(\log x)^{k+1}/(k+1)$, giving the pure $\alpha=0$, arbitrary-$k$ regime. The $k=1$ mixed case $\sum_{n<N} n^p\log n \sim N^{p+1}\log N/(p+1)$ is established here; the natural next step is the general $\sum_{n<N} n^p(\log n)^k \sim N^{p+1}(\log N)^k/(p+1)$ via $k$-fold integration by parts on the same antiderivative recursion.

2. *Weighted Riesz means of order $r$.* Iterate the transfer principle $r$ times to obtain $\sum\cdots\sum n^p \sim N^{p+r}\,p!/(p+r)!$-type constants, and reformulate as the Riesz mean $(1/X^r)\sum_{n\le X}(X-n)^r a(n)$ with the Beta-function constant $B(\alpha,r+1)$.

3. *Abel / partial-summation bridge.* Package the transfer principle together with an Abel-summation lemma so that an asymptotic for $\sum a(n)$ transfers to any smoothly weighted mean $\sum a(n)w(n)$ with $w$ slowly varying.

**Toward the Hurwitz / sesquiharmonic Maass-form target.** The mission concerns $\sum_{n\le X} H(n)\,w(n)$ for Hurwitz class numbers $H(n)$ and weights coming from weight-$1/2$ sesquiharmonic Maass forms. The natural path, building on this engine, is to first establish an average of the Hurwitz class numbers themselves, then transport it through the transfer and Abel-summation machinery to the weighted mean, reading off $(\alpha,k)$ from the spectral data of the form.

---

## References (selected, classical)

- L. Euler and C. Maclaurin, summation-by-integration comparison (Euler–Maclaurin formula).
- O. Stolz and E. Cesàro, discrete l'Hôpital / Stolz–Cesàro theorem.
- D. Zagier, *Nombres de classes et formes modulaires de poids 3/2* (1975), on the generating function of Hurwitz class numbers.
- W. Duke, Ö. Imamoğlu, Á. Tóth, work on harmonic and sesquiharmonic Maass forms and class-number averages (circa 2019).
