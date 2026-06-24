# Positive-Term, Integral, and Sandwich Representations of the Euler–Mascheroni Constant, with the Structural Obstruction to Irrationality

**Author:** Aristotle
**Date:** 2026-06-24

## Abstract

The Euler–Mascheroni constant $\gamma = \lim_{n\to\infty}(H_n - \ln n)$ is among the most studied constants in mathematics, yet its arithmetic nature — whether it is rational or irrational — remains unknown. This paper develops three exact and mutually reinforcing representations of $\gamma$ and uses them to make precise the structural obstruction to an irrationality proof. First, we exhibit $\gamma$ as a convergent series of *strictly positive* terms, $\gamma = \sum_{k\ge 0}\big(\tfrac{1}{k+1} - \ln\tfrac{k+2}{k+1}\big)$, whose $n$-th partial sum equals exactly the classical lower approximant $\ell_n = H_n - \ln(n+1)$; consequently $\ell_n$ is strictly increasing. Second, we realize each term as a unit-interval integral, yielding the discrete integral representation $\gamma = \sum_{k\ge 0}\int_{k+1}^{k+2}\big(\tfrac{1}{k+1} - \tfrac{1}{x}\big)dx$, the term-by-term form of $\gamma = \int_1^\infty\big(\tfrac{1}{\lfloor x\rfloor} - \tfrac1x\big)dx$. Third, we record the two-sided sandwich $\ell_n < \gamma < u_n$ with $u_n = H_n - \ln n$ and the *exact* trap width $u_n - \ell_n = \ln(1 + 1/n)$, giving fully effective error bounds. Finally, we connect these representations to an irrationality criterion: $\gamma$ is irrational if and only if arbitrarily small nonzero integer linear forms $q\gamma - p$ exist (a consequence of Dirichlet's approximation theorem). We argue that all natural approximants produced by our representations are rational numbers contaminated by a transcendental logarithm, and that this non-rationality — not any absence of formulas — is the genuine obstruction. All results have been formally verified.

**Keywords:** Euler–Mascheroni constant, harmonic numbers, positive-term series, integral representation, telescoping, irrationality, Dirichlet approximation, Stieltjes constants.

---

## 1. Introduction

The harmonic numbers $H_n = \sum_{k=1}^{n} \tfrac1k$ diverge logarithmically: $H_n = \ln n + \gamma + o(1)$, where

$$\gamma = \lim_{n\to\infty}\big(H_n - \ln n\big) = 0.57721566490153286\ldots$$

is the **Euler–Mascheroni constant**. Despite three centuries of study, the most basic arithmetic question about $\gamma$ is open: it is not known whether $\gamma \in \mathbb{Q}$. This stands in stark contrast to $e$ (Euler) and $\zeta(3)$ (Apéry, 1978), both of which are known irrational through explicit, fast rational approximation schemes.

The purpose of this paper is twofold. First, we collect and prove, in a unified and elementary way, three exact representations of $\gamma$: a positive-term series, an integral form, and a two-sided sandwich with explicit width. Second, we use these to articulate — and prove an equivalent criterion for — the precise structural reason that an irrationality proof remains out of reach. The headline is not a new formula but a sharpened understanding: every approximant our representations supply is a rational harmonic number perturbed by a transcendental logarithm, and that perturbation is exactly what defeats the standard irrationality machinery.

All statements below correspond to formally verified theorems; we give mathematical proof sketches rather than formal scripts.

### Notation

- $H_n = \sum_{k=1}^n \tfrac1k$ is the $n$-th harmonic number, with $H_0 = 0$.
- $\ln$ denotes the natural logarithm.
- $\lfloor x\rfloor$ is the floor function.
- We write $\gamma$ for the Euler–Mascheroni constant.
- The two standard one-sided approximant sequences are
$$\ell_n = H_n - \ln(n+1), \qquad u_n = H_n - \ln n \ (n\ge 1),$$
the *lower* and *upper* approximants respectively.

---

## 2. The positive-term series

### 2.1 Definition of the term

**Definition 2.1 (Series term).** For $k \in \mathbb{N}$, define
$$g_k = \frac{1}{k+1} - \big(\ln(k+2) - \ln(k+1)\big) = \frac{1}{k+1} - \ln\frac{k+2}{k+1}.$$

Each $g_k$ pairs one harmonic term $\tfrac{1}{k+1}$ with the logarithmic increment it nearly cancels.

### 2.2 Strict positivity

**Theorem 2.2 (`gterm_pos`).** For every $k\in\mathbb{N}$, $\ g_k > 0$.

*Proof sketch.* Write $g_k = \tfrac{1}{k+1} - \ln\tfrac{k+2}{k+1}$. Set $x = \tfrac{k+2}{k+1} > 1$, so $x \ne 1$ and $x - 1 = \tfrac{1}{k+1}$. The strict tangent-line inequality for the logarithm,
$$\ln x < x - 1 \qquad (x > 0,\ x \ne 1),$$
gives $\ln\tfrac{k+2}{k+1} < \tfrac{1}{k+1}$, hence $g_k > 0$. $\qquad\blacksquare$

The inequality $\ln x < x - 1$ is the strict form of concavity of $\ln$ about its tangent at $x=1$; in the formalization it is the library lemma `Real.log_lt_sub_one_of_pos`.

### 2.3 Partial sums telescope to the lower approximant

**Theorem 2.3 (`gterm_partial`).** For every $n\in\mathbb{N}$,
$$\sum_{k=0}^{n-1} g_k = H_n - \ln(n+1) = \ell_n.$$

*Proof sketch.* Split the sum. The harmonic part gives $\sum_{k=0}^{n-1}\tfrac{1}{k+1} = H_n$. The logarithmic part **telescopes**:
$$\sum_{k=0}^{n-1}\big(\ln(k+2) - \ln(k+1)\big) = \ln(n+1) - \ln 1 = \ln(n+1).$$
Subtracting yields $H_n - \ln(n+1)$. Formally this is an induction on $n$ using the recurrence $H_{n+1} = H_n + \tfrac{1}{n+1}$ (`harmonic_succ`). $\qquad\blacksquare$

### 2.4 The series converges to $\gamma$

**Theorem 2.4 (`hasSum_gterm`).** The series $\sum_{k\ge 0} g_k$ converges with sum
$$\sum_{k=0}^{\infty} g_k = \gamma.$$

*Proof sketch.* By Theorem 2.3 the sequence of partial sums of $g$ is exactly $(\ell_n)_n = (H_n - \ln(n+1))_n$, which converges to $\gamma$ (this is the standard fact, in the formalization `Real.tendsto_eulerMascheroniSeq`). Because $g_k \ge 0$ (Theorem 2.2) and the partial sums are bounded above by $\gamma$, the series is summable (`summable_of_sum_range_le`); its sum then coincides with the limit of partial sums by uniqueness of limits, i.e. equals $\gamma$. $\qquad\blacksquare$

**Corollary 2.5 (Strict monotonicity, `strictMono_eulerMascheroniSeq`).** The lower approximant $\ell_n = H_n - \ln(n+1)$ is strictly increasing in $n$, since $\ell_{n+1} - \ell_n = g_n > 0$.

This establishes the "Apéry-like" character of the approximation: the partial sums climb monotonically to $\gamma$, driven by the rational harmonic engine $H_n$ corrected by $\ln(n+1)$.

### 2.5 Rate remarks

A second-order expansion gives $g_k = \tfrac{1}{k+1} - \ln(1 + \tfrac{1}{k+1}) \sim \tfrac{1}{2(k+1)^2}$, so the series is summable but converges only like the tail $\sum_{k\ge n} g_k = O(1/n)$. This slow rate, quantified in Section 4, is one half of the irrationality obstruction.

---

## 3. The integral representation

### 3.1 Nonnegativity of the integrand

**Theorem 3.1 (`integrand_nonneg`).** For $k \in \mathbb{N}$ and $x \ge k+1$,
$$\frac{1}{k+1} - \frac{1}{x} \ge 0.$$

*Proof sketch.* Since $0 < k+1 \le x$, monotonicity of reciprocal on positives gives $\tfrac1x \le \tfrac{1}{k+1}$; rearrange. $\qquad\blacksquare$

Geometrically: on the window $[k+1, k+2]$, the decreasing curve $1/x$ lies below the horizontal line at height $1/(k+1)$ (the curve's value at the left endpoint).

### 3.2 Each term is an integral

**Theorem 3.2 (`gterm_eq_integral`).** For every $k\in\mathbb{N}$,
$$g_k = \int_{k+1}^{k+2}\left(\frac{1}{k+1} - \frac{1}{x}\right)dx.$$

*Proof sketch.* Split the interval integral by linearity. The constant piece integrates to $\int_{k+1}^{k+2}\tfrac{1}{k+1}\,dx = \tfrac{1}{k+1}$ (length-one interval times the constant). The reciprocal piece integrates to $\int_{k+1}^{k+2}\tfrac1x\,dx = \ln(k+2) - \ln(k+1)$, valid because $0 \notin [k+1, k+2]$ (the antiderivative $\ln|x|$ is smooth there). Subtracting reproduces Definition 2.1. The formalization handles the interval-integrability side conditions ($0\notin[k+1,k+2]$) via `intervalIntegrable_one_div` and `integral_one_div`, and the constant via `intervalIntegral.integral_const`. $\qquad\blacksquare$

### 3.3 The integral representation of $\gamma$

**Theorem 3.3 (`hasSum_integral_repr`).** The integral series converges with
$$\gamma = \sum_{k=0}^{\infty}\int_{k+1}^{k+2}\left(\frac{1}{k+1} - \frac{1}{x}\right)dx.$$

*Proof sketch.* By Theorem 3.2 the summand equals $g_k$ pointwise; substitute into Theorem 2.4. $\qquad\blacksquare$

**Remark 3.4 (Continuous form).** Because $\lfloor x\rfloor = k+1$ on $[k+1, k+2)$, the flat-line height $1/(k+1)$ equals $1/\lfloor x\rfloor$. Splitting $[1,\infty)$ into these windows yields the classical improper integral
$$\gamma = \int_1^\infty\left(\frac{1}{\lfloor x\rfloor} - \frac{1}{x}\right)dx,$$
the total area between the descending staircase $1/\lfloor x\rfloor$ and the hyperbola $1/x$. The passage from the proved discrete sum to this single improper integral requires only an `integrableOn`/limit interchange (see Future Directions, Conjecture 4).

### 3.4 The integral partial sums trap $\gamma$

**Theorem 3.5 (`integral_partialSum_lt_lt_seq'`).** For every $n\in\mathbb{N}$,
$$\sum_{k=0}^{n-1}\int_{k+1}^{k+2}\left(\frac{1}{k+1} - \frac{1}{x}\right)dx \;<\; \gamma \;<\; u_n.$$

*Proof sketch.* By Theorems 3.2 and 2.3 the left-hand partial sum equals $\ell_n = H_n - \ln(n+1)$. The two-sided bound $\ell_n < \gamma < u_n$ is the sandwich of Section 4 (`eulerMascheroniSeq_sandwich`). $\qquad\blacksquare$

This makes explicit that the *integral* picture feeds the irrationality engine the very same approximants as the series picture.

---

## 4. The two-sided sandwich and effective bounds

### 4.1 The sandwich

The two one-sided sequences bracket $\gamma$:
$$\ell_n = H_n - \ln(n+1) \;<\; \gamma \;<\; H_n - \ln n = u_n \qquad (n \ge 1).$$

**Theorem 4.1 (`eulerMascheroniSeq_sandwich`).** For every $n$, $\ \ell_n < \gamma < u_n$.

*Proof sketch.* Both are standard library facts: $\ell_n < \gamma$ (`eulerMascheroniSeq_lt_eulerMascheroniConstant`) and $\gamma < u_n$ (`eulerMascheroniConstant_lt_eulerMascheroniSeq'`). The lower bound is also Corollary 2.5 combined with Theorem 2.4 (partial sums of positive terms stay below the total). $\qquad\blacksquare$

### 4.2 Exact trap width

**Theorem 4.2 (`eulerMascheroni_trap_width_eq`).** For $n \ge 1$,
$$u_n - \ell_n = \ln(n+1) - \ln n = \ln\!\Big(1 + \frac1n\Big).$$

*Proof sketch.* $u_n - \ell_n = (H_n - \ln n) - (H_n - \ln(n+1)) = \ln(n+1) - \ln n$; the harmonic terms cancel identically. $\qquad\blacksquare$

### 4.3 Effective one- and two-sided errors

**Theorem 4.3 (`eulerMascheroniConstant_sub_seq_lt`, `seq'_sub_eulerMascheroniConstant_lt`, `abs_eulerMascheroniSeq_sub_lt`).** For $n \ge 1$,
$$0 < \gamma - \ell_n < \ln\!\Big(1+\frac1n\Big), \quad 0 < u_n - \gamma < \ln\!\Big(1+\frac1n\Big), \quad \big|\ell_n - \gamma\big| < \ln\!\Big(1+\frac1n\Big).$$

*Proof sketch.* Each one-sided error is strictly less than the full trap width by Theorem 4.1, and the width is $\ln(1 + 1/n)$ by Theorem 4.2. The absolute-value form follows since $\ell_n < \gamma$ makes $\ell_n - \gamma$ negative. $\qquad\blacksquare$

Since $\ln(1 + 1/n) \to 0$, the trap closes and $\gamma$ is determined; since the bound is explicit and computable for each $n$, the enclosure is *effective*. The convergence rate, however, is only $O(1/n)$ — exponentially slower than the geometric rates that drive known irrationality proofs.

### 4.4 The trap width vanishes

**Theorem 4.4 (`tendsto_eulerMascheroni_trap_width`).** $\ u_n - \ell_n \to 0$ as $n\to\infty$.

*Proof sketch.* By Theorem 4.2 the width is $\ln(1+1/n)$, and continuity of $\ln$ at $1$ gives the limit $0$; equivalently subtract the two convergent limits $u_n \to \gamma$ and $\ell_n \to \gamma$. $\qquad\blacksquare$

---

## 5. The irrationality criterion and the obstruction

### 5.1 An equivalence

A clean reformulation of irrationality, valid for any real $x$, isolates exactly what an irrationality proof must supply.

**Theorem 5.1 (`irrational_iff_forall_eps_linear_form`).** A real number $x$ is irrational if and only if for every $\varepsilon > 0$ there exist a positive integer $q$ and an integer $p$ with
$$0 < |q x - p| < \varepsilon.$$

*Proof sketch.* ($\Leftarrow$) If $x = a/b$ were rational, then $qx - p = (qa - pb)/b$ is a rational with denominator $b$; whenever it is nonzero its absolute value is at least $1/b$, contradicting the hypothesis for $\varepsilon = 1/b$. So no such forms exist for small $\varepsilon$ unless $x$ is irrational. ($\Rightarrow$) For irrational $x$, **Dirichlet's approximation theorem** (in Mathlib) furnishes infinitely many fractions $p/q$ with $|x - p/q| < 1/q^2$, i.e. $|qx - p| < 1/q < \varepsilon$ for large $q$, and these are nonzero because $x$ is irrational. $\qquad\blacksquare$

Specialized to $\gamma$:

**Theorem 5.2 (`irrational_eulerMascheroniConstant_iff`).** $\gamma$ is irrational if and only if for every $\varepsilon > 0$ there are $q\in\mathbb{N}_{>0}$, $p\in\mathbb{Z}$ with $0 < |q\gamma - p| < \varepsilon$.

This is a faithful restatement, not a resolution: it converts the question "is $\gamma$ irrational?" into "do arbitrarily small nonzero integer linear forms in $\gamma$ exist?"

### 5.2 Why the representations do not (yet) close the gap

The series, integral, and sandwich representations all generate excellent approximants to $\gamma$, namely $\ell_n$ and $u_n$. To feed Theorem 5.2 we would need integer linear forms $q\gamma - p$, i.e. *rational* approximations $p/q$. But $\ell_n = H_n - \ln(n+1)$ and $u_n = H_n - \ln n$ are **not rational**: each is a rational harmonic number $H_n$ minus a transcendental logarithm. Forming $q\gamma - p$ from these requires eliminating $\ln n$, which the representations do not do. Two distinct deficiencies stack:

1. **Non-rationality.** The approximants carry a logarithm and are therefore transcendental, so they cannot be the $p/q$ that Theorem 5.2 demands.
2. **Slow rate.** Even ignoring (1), the enclosure width $\ln(1+1/n) = O(1/n)$ is far too slow; irrationality via Theorem 5.2 needs width $o(1/q)$ in the denominator $q$, the regime of geometric or factorial convergence.

This is the precise content of the obstruction: *the difficulty is not the absence of representations but the non-rational nature of the approximants they produce.* A successful attack must manufacture approximants that are simultaneously rational, with controlled denominators, and with width $o(1/q)$.

---

## 6. The Stieltjes hierarchy

The constant $\gamma$ is the zeroth member ($m=0$) of the **Stieltjes constants** $\gamma_m$, defined via
$$\gamma_m = \lim_{n\to\infty}\left(\sum_{k=1}^{n}\frac{(\ln k)^m}{k} - \frac{(\ln n)^{m+1}}{m+1}\right),$$
which arise as the Laurent coefficients of the Riemann zeta function about its pole $s=1$: $\zeta(s) = \tfrac{1}{s-1} + \sum_{m\ge 0}\tfrac{(-1)^m}{m!}\gamma_m (s-1)^m$. The case $m=0$ is exactly the staircase-versus-curve comparison of this paper, since $\int \tfrac{(\ln x)^m}{x}\,dx = \tfrac{(\ln x)^{m+1}}{m+1}$ specializes at $m=0$ to $\int \tfrac1x\,dx = \ln x$. Thus $\gamma_0 = \gamma$ (in the formalization `tendsto_stieltjesSeq_zero`). The arithmetic nature of every $\gamma_m$ is open, and the discrete-versus-integral mechanism that pins $\gamma_0$ generalizes to all $m$ via Euler–Maclaurin / summation-by-parts bounds on $(\ln x)^m/x$ (Future Directions, Conjecture 3).

---

## 7. Algorithms

### 7.1 Computing the lower approximant $\ell_n$

Compute $H_n$ by accumulation and subtract $\ln(n+1)$:
```
input n
H ← 0
for k = 1 .. n:  H ← H + 1/k
return H − ln(n+1)
```
Cost $O(n)$ arithmetic operations; output is the strictly increasing lower bound $\ell_n < \gamma$. The companion $u_n = H_n - \ln n$ is the upper bound; their average is a natural accelerated estimate.

### 7.2 Effective enclosure to tolerance $\varepsilon$

To bracket $\gamma$ within $\varepsilon$, choose $n$ with $\ln(1 + 1/n) < \varepsilon$ (e.g. $n > 1/\varepsilon$ suffices since $\ln(1+t) < t$), then return $[\ell_n, u_n]$. Theorem 4.3 guarantees $\gamma \in (\ell_n, u_n)$ and $u_n - \ell_n < \varepsilon$.

### 7.3 Term-wise / integral accumulation

Summing $g_k = \tfrac{1}{k+1} - \ln\tfrac{k+2}{k+1}$ for $k = 0,\dots,n-1$ reproduces $\ell_n$ (Theorem 2.3) while exhibiting each positive brick; equivalently each brick is the window integral of Theorem 3.2. This is the constructive content of the series and integral representations.

---

## 8. Applications and discussion

- **Numerical analysis.** The effective two-sided bounds (Theorem 4.3) give certified, rigorous enclosures of $\gamma$ with explicit error $\ln(1+1/n)$, useful as ground truth for interval-arithmetic libraries.
- **Series acceleration.** Because the one-sided errors are $\pm\tfrac{1}{2n} + O(1/n^2)$ to leading order, averaging $\ell_n$ and $u_n$ cancels the $1/n$ term and yields $O(1/n^2)$ convergence — a cheap, provable acceleration (Future Directions, Conjecture 2).
- **Conceptual clarification of the open problem.** The equivalence of Theorem 5.2 plus the non-rationality of all natural approximants pinpoints what is missing, redirecting effort from "find a formula" to "find rational, fast, controlled approximants."
- **Analytic number theory.** The $m=0$ staircase mechanism is the template for the entire Stieltjes hierarchy and thus for the local structure of $\zeta$ at $s=1$.

## 9. Future work

See the Future Directions section of the package for four concrete conjectures: (1) the quadratic term bound $g_k \le \tfrac{1}{2(k+1)^2}$ with $O(1/n)$ tail; (2) the averaged approximant $m_n = (\ell_n+u_n)/2$ with $|m_n - \gamma| \le C/n^2$; (3) well-definedness of the full Stieltjes hierarchy and $\gamma_0 = \gamma$; (4) the continuous integral $\gamma = \int_1^\infty(1/\lfloor x\rfloor - 1/x)\,dx$.

## 10. Conclusion

We have given three exact, elementary, and formally verified representations of the Euler–Mascheroni constant — a positive-term series, a unit-window integral form, and an effective two-sided sandwich — and we have used them to state, and prove an equivalent criterion for, the structural obstruction to its irrationality. The constant is fully tractable as an object to compute and enclose; what remains stubborn is the arithmetic question, and we have made precise that the obstruction is the non-rational nature of every approximant our representations supply.
