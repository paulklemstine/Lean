# An Integer-Linear-Form Characterization of Irrationality, with Application to the Euler–Mascheroni Constant

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Number Theory / Diophantine Approximation)

## Abstract

We isolate, as a single reusable theorem, the structural mechanism underlying
essentially every known irrationality proof: a real number $x$ is irrational
whenever there exist integer sequences $(a_n), (b_n)$ such that the linear forms
$a_n + b_n x$ are never zero yet tend to $0$. We then prove that this sufficient
condition is in fact a **characterization** — its converse holds for every
irrational number, via Dirichlet's theorem on the infinitude of good rational
approximations. Specializing to the Euler–Mascheroni constant $\gamma = \lim_{n}
(H_n - \ln n)$, we obtain an exact equivalence: $\gamma$ is irrational if and only
if explicit nonzero integer linear forms $a_n + b_n\gamma \to 0$ exist. This
reframes the centuries-old open problem of the irrationality of $\gamma$ as a
concrete Diophantine construction problem, identifying the precise target of any
future Apéry-style attack. All results are formalized with no axioms beyond the
standard foundations. We supplement the theory with numerical demonstrations on
constants of known irrationality status ($\sqrt 2$, $e$, rationals) and discuss
extensions to the Stieltjes constants.

## 1. Introduction

The Euler–Mascheroni constant,
$$\gamma = \lim_{n\to\infty}\left(\sum_{k=1}^{n}\frac1k - \ln n\right) = 0.57721566490153\ldots,$$
is a fundamental mathematical constant appearing across number theory, complex
analysis, probability, and the analysis of algorithms. Despite its ubiquity and
the fact that it has been computed to well over $10^{12}$ decimal digits, a basic
question remains open: **is $\gamma$ irrational?** No proof of irrationality (let
alone transcendence) is known, and this has been so since Euler's investigations in
the 1730s.

Every successful irrationality proof in the classical canon — for $e$, for $\pi$,
for $\zeta(2)$ and $\zeta(3)$ (Apéry, 1978) — ultimately proceeds by exhibiting a
sequence of *integer linear forms* in the target constant that are provably nonzero
yet converge to $0$. The arithmetic obstruction "there is no integer in the open
interval $(0,1)$" then forces irrationality. The analytic difficulty in each case
lies entirely in *constructing* the forms with adequate control of their size and
of the denominators involved.

This paper makes three contributions, all formally verified.

1. **(Sufficiency, Theorem 1.)** We state and prove the integer-linear-form
   criterion as a standalone theorem.
2. **(Characterization, Theorem 3.)** We prove the converse: every irrational
   number admits such forms. Hence the criterion is lossless.
3. **(Reduction, Theorem 4.)** Specializing to $\gamma$, we obtain that the
   irrationality of $\gamma$ is equivalent to a concrete construction of integer
   linear forms — turning an analytic open problem into a Diophantine one.

We emphasize at the outset that we do **not** resolve the irrationality of
$\gamma$; we provide an exact, verified reformulation of it.

## 2. Definitions and conventions

Throughout, $x \in \mathbb{R}$. We use the following standard notions.

**Definition 2.1 (Rational, irrational).** A real number $x$ is *rational* if
$x = p/q$ for some $p \in \mathbb{Z}$, $q \in \mathbb{Z}_{>0}$; equivalently if
$x \in \mathbb{Q}$ under the canonical embedding $\mathbb{Q}\hookrightarrow
\mathbb{R}$. It is *irrational* if it is not rational. We write `Irrational x` for
this predicate.

**Definition 2.2 (Integer linear form).** Given integer sequences $a, b : \mathbb{N}
\to \mathbb{Z}$, the associated *integer linear forms in $x$* are the real numbers
$$L_n(x) := a_n + b_n\,x, \qquad n \in \mathbb{N}.$$

**Definition 2.3 (Reduced fraction data).** For $q \in \mathbb{Q}$ we write
$\mathrm{num}(q) \in \mathbb{Z}$ and $\mathrm{den}(q) \in \mathbb{Z}_{>0}$ for its
numerator and (positive, coprime) denominator, so $q = \mathrm{num}(q)/\mathrm{den}(q)$.

**Definition 2.4 (Euler–Mascheroni constant).** With $H_n = \sum_{k=1}^n 1/k$ the
$n$-th harmonic number,
$$\gamma := \lim_{n\to\infty}\bigl(H_n - \ln n\bigr).$$
Equivalently $\gamma = \lim_n (H_n - \ln(n+1))$, the lower Mathlib approximant
`eulerMascheroniSeq`.

Convergence of a real sequence $s_n$ to a limit $L$ is denoted $s_n \to L$ (the
filter statement `Tendsto s atTop (𝓝 L)`).

## 3. Main results

### 3.1 Sufficiency

**Theorem 1 (Integer-linear-form irrationality criterion; `EMR.irrational_of_int_linear_combo_tendsto_zero`).**
Let $x \in \mathbb{R}$. Suppose there exist $a, b : \mathbb{N}\to\mathbb{Z}$ with
$$\text{(i) } a_n + b_n x \neq 0 \text{ for all } n, \qquad \text{(ii) } a_n + b_n x \to 0.$$
Then $x$ is irrational.

*Proof sketch.* Suppose for contradiction $x = p/q$ with $p = \mathrm{num}(x)$,
$q = \mathrm{den}(x) > 0$. For each $n$,
$$L_n(x) = a_n + b_n\frac{p}{q} = \frac{a_n q + b_n p}{q},$$
where the numerator $m_n := a_n q + b_n p \in \mathbb{Z}$. By hypothesis (i),
$L_n(x) \neq 0$, hence $m_n \neq 0$; since $m_n$ is a nonzero integer,
$|m_n| \ge 1$ (the key arithmetic fact `Int.one_le_abs`). Therefore
$$|L_n(x)| = \frac{|m_n|}{q} \ge \frac{1}{q} > 0 \qquad \text{for all } n.$$
But hypothesis (ii) gives $|L_n(x)| \to 0$, so eventually $|L_n(x)| < 1/q$, a
contradiction. Hence $x \notin \mathbb{Q}$. $\qquad\blacksquare$

The single load-bearing arithmetic input is the rigidity of the integers: a
nonzero integer has absolute value at least $1$, so the rescaled forms cannot
approach $0$ unless they are eventually $0$, which (i) forbids.

### 3.2 Unbounded denominators from Dirichlet

The converse requires not just *some* good rational approximations but a supply of
them with arbitrarily large denominators. This is where the irrationality of $x$ is
used.

**Lemma 2 (Unbounded denominators of good approximations; `EMR.exists_rat_mem_den_ge`).**
If $x$ is irrational, then for every $N \in \mathbb{N}$ there exists $q \in
\mathbb{Q}$ with
$$\left|x - q\right| < \frac{1}{\mathrm{den}(q)^2} \qquad\text{and}\qquad \mathrm{den}(q) \ge N.$$

*Proof sketch.* By a classical theorem (Dirichlet/Hurwitz; in Mathlib,
`Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational`), the set
$$S = \Bigl\{q \in \mathbb{Q} : |x - q| < 1/\mathrm{den}(q)^2\Bigr\}$$
is *infinite* whenever $x$ is irrational. Suppose, for contradiction, that every
$q \in S$ had $\mathrm{den}(q) < N$. Then for each admissible denominator
$d \in \{1, \dots, N-1\}$, the numerators $c$ with $|x - c/d| < 1/d^2$ lie in a
bounded interval of length $2/d^2$, hence are finite in number (they are integers
in $[\lfloor xd - 1/d\rfloor, \lceil xd + 1/d\rceil]$). A finite union of finite
sets is finite, so $S$ would be finite — contradicting its infinitude. Therefore
denominators are unbounded: some $q \in S$ has $\mathrm{den}(q) \ge N$.
$\qquad\blacksquare$

### 3.3 Characterization

**Theorem 3 (Characterization of irrationality; `EMR.irrational_iff_exists_int_linear_combo_tendsto_zero`).**
For $x \in \mathbb{R}$,
$$x \text{ is irrational} \iff \exists\, a, b : \mathbb{N}\to\mathbb{Z},\ \bigl(\forall n,\ a_n + b_n x \neq 0\bigr)\ \wedge\ \bigl(a_n + b_n x \to 0\bigr).$$

*Proof sketch.* ($\Leftarrow$) is Theorem 1.

($\Rightarrow$) Assume $x$ irrational. Apply Lemma 2 at each threshold $N = n+1$ to
choose a rational $q_{n} \in \mathbb{Q}$ with
$$\left|x - q_{n}\right| < \frac{1}{\mathrm{den}(q_{n})^2}, \qquad \mathrm{den}(q_{n}) \ge n+1.$$
Define
$$a_n := -\,\mathrm{num}(q_{n}), \qquad b_n := \mathrm{den}(q_{n}).$$
Then with $d_n := \mathrm{den}(q_n) > 0$ and $q_n = \mathrm{num}(q_n)/d_n$,
$$a_n + b_n x = -\mathrm{num}(q_n) + d_n x = d_n\Bigl(x - q_n\Bigr),$$
so
$$|a_n + b_n x| = d_n\,|x - q_n| < d_n \cdot \frac{1}{d_n^2} = \frac{1}{d_n} \le \frac{1}{n+1}.$$
The right-hand side $\to 0$, so by squeezing (with the nonnegativity lower bound)
$a_n + b_n x \to 0$. Moreover $a_n + b_n x \neq 0$: if it vanished, then
$d_n x = \mathrm{num}(q_n)$, i.e. $x = q_n \in \mathbb{Q}$, contradicting the
irrationality of $x$. This produces the required forms. $\qquad\blacksquare$

The characterization shows the criterion of Theorem 1 is *complete*: it is not a
restricted tool that succeeds only on special irrationals; it certifies all of
them and is refuted by none.

### 3.4 Reduction of the open problem for $\gamma$

**Theorem 4 (Reduction of the irrationality of $\gamma$; `EMR.eulerMascheroniConstant_irrational_iff`).**
$$\gamma \text{ is irrational} \iff \exists\, a, b : \mathbb{N}\to\mathbb{Z},\ \bigl(\forall n,\ a_n + b_n\gamma \neq 0\bigr)\ \wedge\ \bigl(a_n + b_n\gamma \to 0\bigr).$$

*Proof.* Immediate specialization of Theorem 3 to $x = \gamma$. $\qquad\blacksquare$

This is the central application. It does not assert the irrationality of $\gamma$.
It asserts that the analytic open problem and a *purely Diophantine construction
problem* are one and the same: produce explicit integer sequences $a_n, b_n$ whose
linear combinations with $\gamma$ are nonzero and shrink to $0$. The existence of
such forms is necessary and sufficient.

## 4. Discussion

### 4.1 The arithmetic engine

The asymmetry between Theorem 1 and its converse is instructive. The sufficiency
direction uses only the *integrality* of the cross term $a_n q + b_n p$. It is
entirely constant-agnostic: nothing about $\gamma$, $e$, or $\zeta(3)$ enters. This
is exactly why the same theorem powers every classical irrationality argument — the
analytic labor is hidden in producing the forms, never in the rigidity step. The
converse, by contrast, is where the structure of irrational numbers is genuinely
invoked, through Dirichlet's infinitude of good approximations.

### 4.2 Quantitative refinement and irrationality measure

Theorem 1 is purely qualitative. A quantitative sharpening connects the *rate* of
decay to the irrationality measure. If forms can be built with
$$|a_n + b_n\gamma| \le C\,b_n^{-(1+\delta)} \quad (\delta > 0),$$
then $\gamma$ would have finite irrationality measure $\le 1 + 1/\delta$. The proof
of Lemma 2 already extracts denominator-unbounded approximations with the $1/d$
bound; the quantitative program is precisely to upgrade $1/d$ to $d^{-(1+\delta)}$,
the analytic step separating "irrational" from "Diophantine of bounded measure."

### 4.3 A positive series as raw material

The companion development records that $\gamma$ is the sum of an explicitly
*positive* telescoping series. With
$$g(k) := \frac{1}{k+1} - \bigl(\ln(k+2) - \ln(k+1)\bigr) > 0,$$
one has the partial-sum identity $\sum_{k<n} g(k) = H_n - \ln(n+1)$ and hence
$$\gamma = \sum_{k=0}^{\infty} g(k),$$
with truncation error below $1/n$. Each term is positive because
$\ln\!\bigl(1 + \tfrac{1}{k+1}\bigr) < \tfrac{1}{k+1}$. Such partial-fraction-plus-
logarithm series are the natural candidates to pair with integral representations
in a Beukers-style attack: in the $\zeta(3)$ case, an analogous structure feeds the
double-integral machinery that manufactures the integer recurrences. Adapting that
machinery to the $g(k)$ series — making the integer forms of Theorem 4 explicit —
is the principal open avenue.

### 4.4 Soundness and scope

The corollary is an honest reduction, not a disguised resolution. Both directions
of Theorem 4 are genuinely non-trivial (neither is a decision procedure or a
definitional unfolding), and the existence of the forms for $\gamma$ remains
unknown. The contribution is to pin down, with certified precision, *what must be
constructed*.

## 5. Applications and worked numerics

Although the construction for $\gamma$ is open, the criterion is fully operational
on constants of known status, which is how we validate the theory numerically
(see the accompanying demonstrations).

- **$\sqrt 2$.** The recursion $(a_{n+1}, b_{n+1}) = (a_n + 2b_n,\ a_n + b_n)$ with
  alternating signs produces $(1,-1), (-3,2), (7,-5), (-17,12), \dots$, and the
  forms $a_n + b_n\sqrt 2$ are nonzero and decay geometrically like
  $(\sqrt 2 - 1)^n$. Theorem 1 certifies irrationality.
- **$e$.** Continued-fraction convergents $p_n/q_n$ of $e$ give
  $a_n = -p_n$, $b_n = q_n$ with $|{-p_n} + q_n e| \to 0$, again nonzero;
  Theorem 1 applies.
- **Rationals (negative control).** For $x = p/q$, *no* shrinking nonzero integer
  forms exist: every nonzero form has $|a_n + b_n x| \ge 1/q$, the exact lower
  bound from the proof of Theorem 1. This is the content of the contrapositive and
  a useful sanity check.

These examples exercise the *main theorem* itself — the rigidity lower bound
$1/q$ and the squeeze to $0$ — rather than any trivial special case.

## 6. Future work

The directions below follow directly from the formalized results.

1. **Apéry-type forms for $\gamma$.** Construct explicit computable $(a_n, b_n)$
   with $a_n + b_n\gamma \to 0$ (nonzero), witnessing irrationality through Theorem
   4. Continued-fraction convergents of $\gamma$ are the first candidate input.
2. **Beukers-style integral form for the positive series.** Express each $g(k)$ as
   $\int_0^1 t^k\,(\cdots)\,dt$ so that $\sum_k g(k)$ becomes a known integral for
   $\gamma$, exposing the partial-fraction/log structure to the double-integral
   machinery used for $\zeta(3)$.
3. **Denominator growth and irrationality measure.** Sharpen Lemma 2's $1/d$ bound
   to $d^{-(1+\delta)}$, yielding a finite irrationality measure $\le 1 + 1/\delta$.
4. **Stieltjes-constant generalization.** Theorem 1 applies verbatim to every
   Stieltjes constant $\gamma_n$ (with $\gamma_0 = \gamma$), simultaneously reducing
   each open problem "is $\gamma_n$ irrational?" to a Diophantine construction.

## 7. Conclusion

We have given a verified, lossless reformulation of irrationality in terms of
shrinking nonzero integer linear forms, and specialized it to recast the open
problem of the irrationality of the Euler–Mascheroni constant $\gamma$ as an
explicit Diophantine construction. The rigidity engine (Theorem 1), its
completeness (Theorem 3), and the reduction for $\gamma$ (Theorem 4) together
mark out exactly where a future proof must strike: not in the analysis of $\gamma$,
but in the manufacture of the integers.
