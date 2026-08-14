# The Noise-Floor Principle and the Capacity Frontier of Spectral Learning

**Author:** Aristotle
**Date:** 2026-08-13

## Abstract

We give a complete and exact theory of the irreducible excess risk of spectral
(diagonal) estimators. For a nonnegative signal spectrum $a = (a_i)_{i \in I}$
observed at per-mode noise level $b > 0$, the excess risk of the spectral filter
$t = (t_i)$ is $R_{a,b}(t) = \sum_i \big(a_i(1-t_i)^2 + b\,t_i^2\big)$. We prove
that
$$
\min_t R_{a,b}(t) \;=\; \mathcal{N}(a,b) \;:=\; b \, d_{\mathrm{eff}}(a,b), \qquad
d_{\mathrm{eff}}(a,b) := \sum_i \frac{a_i}{a_i+b},
$$
that the minimum is attained by the Wiener filter $t_i = a_i/(a_i+b)$ and by no
other filter, and that in matrix form $d_{\mathrm{eff}} = \operatorname{tr}\big(A(A+b\mathbb{1})^{-1}\big)$ for a
positive semidefinite covariance $A$ with spectrum $a$. The principal new
contribution is the **capacity frontier**: with the Gaussian channel capacity
$C(a,b) = \sum_i \log(1 + a_i/b) = \log\det(\mathbb{1} + b^{-1}A)$ we prove the
chain
$$
d_{\mathrm{eff}}(a,b) \;\le\; C(a,b) \;\le\; \frac{\operatorname{tr} A}{b},
\qquad\text{equivalently}\qquad
\mathcal{N} \;\le\; b\log\det(\mathbb{1}+b^{-1}A) \;\le\; \operatorname{tr} A,
$$
which strictly refines the classical trace bound $d_{\mathrm{eff}} \le \operatorname{tr} A / b$ by
inserting an information-theoretic quantity between a spectral one and a linear
one; strictness is witnessed at a single mode at the noise level, where the three
quantities are $1/2 < \log 2 < 1$. We complement the frontier with: a head/tail
sandwich $\tfrac12\sum_i \min(a_i,b) \le \mathcal{N} \le \sum_i \min(a_i,b)$ with
both constants sharp; the minimax value $Sbn/(S+nb)$ over spectra of prescribed
energy $S$ on $n$ modes, attained at the isotropic spectrum; a rigidity theorem
showing ridge regression attains the floor if and only if an exact isotropy
relation holds, with a sharp $4/3$ gap otherwise; a one-sided domination of
matched ridge by gradient-flow early stopping (factor $4$ in one direction,
unbounded in the other); and a derived — not assumed — log-corrected $1/N$
scaling law for geometric spectra.

**Keywords:** effective dimension, noise floor, spectral filter, Wiener filter,
ridge regression, early stopping, log-determinant, channel capacity, minimax
risk, scaling laws.

---

## 1. Introduction

### 1.1 The question

Linear estimation in a fixed design reduces, after diagonalization of the data
covariance, to a family of one-dimensional problems that interact only through a
shared noise level. Nearly every classical estimator — ridge/Tikhonov
regularization, principal-component (spectral cut-off) regression, gradient-flow
early stopping, kernel smoothing, James–Stein-type shrinkage in an orthogonal
basis — is a *spectral filter*: a vector of per-mode shrinkage coefficients
applied in the eigenbasis. Such methods are usually compared to one another
empirically, or asymptotically, or up to unspecified constants.

We ask instead for the exact value of the optimisation problem over the whole
family, and for a complete description of the geometry of that optimum. The
answer turns out to be closed-form, attained, unique, and expressible as a trace
functional of the covariance. Once this is in hand, a series of questions that
usually receive heuristic answers — *how much does a scalar regularizer lose? is
early stopping really ridge? which spectrum is hardest? where do scaling laws
come from?* — become computations.

### 1.2 Contributions

1. **The Noise-Floor Principle** (Theorem 3.2, Theorem 3.4): the exact minimum
   of the risk over all spectral filters, its unique minimizer, and its trace
   representation (Theorem 4.3).
2. **The capacity frontier** (Theorems 5.2, 5.3, 5.6, 5.7): a strict three-term
   chain placing the Gaussian channel capacity between the noise floor and the
   trace, in both scalar and matrix form, with strictness witnessed explicitly.
3. **Structural decomposition** (Theorem 6.1): the head/tail sandwich, with both
   constants sharp, and the two regime corollaries (no learning below the noise,
   linear saturation above it).
4. **Rigidity of ridge** (Theorem 7.1) and its sharp $4/3$ suboptimality
   (Theorem 7.2); **one-sided domination** of matched ridge by early stopping
   (Theorems 7.4, 7.5).
5. **Minimax spectrum** (Theorem 8.2): the isotropic spectrum is the hardest at
   fixed energy, with value $Sbn/(S+nb)$.
6. **A derived scaling law** (Theorem 9.3) for geometric spectra:
   $\mathcal{N} \asymp b\log(1/b) \asymp (\sigma^2/N)\log N$.

### 1.3 Notation

$I$ is a finite index set of modes, $|I| = n$. A *spectrum* is a map
$a : I \to \mathbb{R}$ with $a_i \ge 0$; $b > 0$ is the *noise level*. Matrices
are real $n \times n$; $A \succeq 0$ means positive semidefinite; $\mathbb{1}$ is
the identity; $\operatorname{tr}$ is the trace; $\log$ is the natural logarithm. For a
Hermitian (here: real symmetric) $A$ we write $\mu_1,\dots,\mu_n$ for its
eigenvalues.

---

## 2. The model

**Definition 2.1 (Spectral filter and its risk).**
A *spectral filter* is a vector $t : I \to \mathbb{R}$. Its *excess risk*
against the spectrum $a$ at noise level $b$ is
$$
R_{a,b}(t) \;=\; \sum_{i \in I} \Big( a_i\,(1-t_i)^2 \;+\; b\,t_i^2 \Big).
$$

The first summand is the squared bias incurred by shrinking mode $i$ by the
factor $t_i$; the second is the variance transmitted from the observation noise.
In the standard fixed-design regression normalization with $N$ samples and noise
variance $\sigma^2$, one has $b = \sigma^2/N$ and $a_i = \theta_i^2 \mu_i$, where
$\theta$ is the target coefficient vector in the eigenbasis and $\mu$ the
covariance spectrum. The sample size enters only through $b$.

**Definition 2.2 (Named filters).**
- *Wiener filter:* $w_i = a_i/(a_i+b)$.
- *Ridge filter* with parameter $\lambda>0$ on covariance spectrum $\mu$:
  $r_i = \mu_i/(\mu_i+\lambda)$.
- *Gradient-flow (early stopping) filter* at time $\tau>0$:
  $g_i = 1 - e^{-\mu_i \tau}$.

**Definition 2.3 (Effective dimension and noise floor).**
$$
d_{\mathrm{eff}}(a,b) \;=\; \sum_{i} \frac{a_i}{a_i+b}, \qquad
\mathcal{N}(a,b) \;=\; b\, d_{\mathrm{eff}}(a,b) \;=\; \sum_i \frac{a_i b}{a_i+b}.
$$

Each summand of $d_{\mathrm{eff}}$ lies in $[0,1)$; it is close to $1$ when
$a_i \gg b$ and close to $0$ when $a_i \ll b$. Thus $d_{\mathrm{eff}}$ is a soft
count of the modes that protrude from the noise.

**Proposition 2.4 (Elementary properties of the effective dimension).**
For $a \ge 0$, $b>0$:
1. $0 \le d_{\mathrm{eff}}(a,b) \le \min\big(n, \ \sum_i a_i / b\big)$.
2. $d_{\mathrm{eff}}$ is nonincreasing in $b$ and nondecreasing in $a$
   (coordinatewise).
3. *Doubling:* $d_{\mathrm{eff}}(a, b/2) \le 2\, d_{\mathrm{eff}}(a,b)$ — halving
   the noise (i.e. doubling the data) at most doubles the effective dimension:
   there is no cliff.
4. *Joint scale invariance:* $d_{\mathrm{eff}}(ca, cb) = d_{\mathrm{eff}}(a,b)$
   for $c>0$.
5. *Concavity:* $a \mapsto d_{\mathrm{eff}}(a,b)$ is concave.
6. *Counting:* $\#\{i : a_i \ge b\} \le 2\,d_{\mathrm{eff}}(a,b)$.
7. *Additivity:* for two independent problems indexed by $I$ and $J$,
   $d_{\mathrm{eff}}(a \oplus a', b) = d_{\mathrm{eff}}(a,b) + d_{\mathrm{eff}}(a',b)$.

*Proof sketch.* All statements reduce to the scalar profile
$f_b(x) = x/(x+b) = 1 - b/(x+b)$ on $[0,\infty)$. It takes values in $[0,1)$,
is increasing and concave in $x$, decreasing in $b$, satisfies $f_b(x)\le x/b$,
and $f_{b/2}(x) = x/(x+b/2) \le 2x/(x+b) = 2f_b(x)$ because
$(x+b) \le 2(x + b/2)$. Homogeneity $f_{cb}(cx) = f_b(x)$ is immediate. For (6),
$a_i \ge b$ forces $f_b(a_i) \ge 1/2$. Additivity is the splitting of a sum over
a disjoint union. $\square$

---

## 3. The Noise-Floor Principle

**Lemma 3.1 (Exact per-mode gap identity).** For $x \ge 0$, $b>0$ and any
$t \in \mathbb{R}$,
$$
x(1-t)^2 + b t^2 \;=\; \frac{xb}{x+b} \;+\; \frac{\big((x+b)t - x\big)^2}{x+b}.
$$

*Proof.* Both sides are quadratics in $t$; multiply out and compare
coefficients. The coefficient of $t^2$ is $x + b$ on both sides; the coefficient
of $t$ is $-2x$ on both sides; the constant terms are $x$ and
$\frac{xb}{x+b} + \frac{x^2}{x+b} = \frac{x(b+x)}{x+b} = x$. $\square$

Everything in this section follows from Lemma 3.1.

**Theorem 3.2 (Noise-floor lower bound).** For every spectrum $a \ge 0$, every
$b > 0$ and every filter $t$,
$$
R_{a,b}(t) \;\ge\; \mathcal{N}(a,b).
$$

*Proof.* Apply Lemma 3.1 in each mode and discard the nonnegative remainder
$((a_i+b)t_i - a_i)^2/(a_i+b)$; sum. $\square$

**Theorem 3.3 (Attainment).** $R_{a,b}(w) = \mathcal{N}(a,b)$ for the Wiener
filter $w_i = a_i/(a_i+b)$.

*Proof.* The remainder in Lemma 3.1 vanishes precisely when
$(x+b)t = x$. $\square$

**Theorem 3.4 (The Noise-Floor Principle; minimum and uniqueness).**
$\mathcal{N}(a,b)$ is the least element of $\{R_{a,b}(t) : t : I \to \mathbb{R}\}$,
and $R_{a,b}(t) = \mathcal{N}(a,b)$ if and only if $t = w$.

*Proof.* Existence and the bound are Theorems 3.2–3.3. If
$R_{a,b}(t) = \mathcal{N}(a,b)$ then $\sum_i ((a_i+b)t_i - a_i)^2/(a_i+b) = 0$;
each summand is nonnegative and each denominator is positive, so each numerator
vanishes, giving $t_i = a_i/(a_i+b)$ for all $i$. $\square$

Three features deserve emphasis. First, the bound holds against *arbitrary real*
filters — no constraint $t_i \in [0,1]$, no parametric family. Second, it is an
identity, not an asymptotic. Third, the minimizer depends on the *signal*
spectrum $a$, which the statistician does not know; every practical method is a
guess at $w$, and the theory below measures the cost of the guess.

**Proposition 3.5 (Coarse bounds and monotonicity of the floor).**
$0 \le \mathcal{N}(a,b) \le \min\big(\sum_i a_i,\ n b\big)$; $\mathcal{N}$ is
nondecreasing in $b$ and in $a$; $\mathcal{N}(a, b/2) \le \mathcal{N}(a,b)$ with
$\mathcal{N}(a,b) \le 2\,\mathcal{N}(a,b/2)$; $\mathcal{N}$ is concave in $a$;
$\mathcal{N}$ is additive over independent problems; and
$\tfrac{b}{2}\#\{i : a_i \ge b\} \le \mathcal{N}(a,b)$.

*Proof sketch.* Multiply the corresponding statements of Proposition 2.4 by $b$,
handling the $b$-dependence in the monotonicity and doubling claims via
$\mathcal{N} = \sum_i a_i b/(a_i+b)$ and monotonicity of
$b \mapsto ab/(a+b)$. $\square$

**Theorem 3.6 (Sharp signal-to-noise threshold).** For a flat spectrum
$a_i \equiv \alpha \ge 0$ on $n$ modes, the floor is $n\,\alpha b/(\alpha+b)$, and
$$
\mathcal{N} \ \ge\ \frac{nb}{2} \iff \alpha \ge b .
$$

*Proof.* $\alpha b/(\alpha+b) \ge b/2 \iff 2\alpha \ge \alpha + b \iff \alpha
\ge b$. $\square$

Half of the saturation value $nb$ is reached exactly at unit signal-to-noise
ratio: the per-mode threshold $a_i = b$ that organizes the rest of the theory is
not a convention but a genuine transition point.

---

## 4. The trace-lemma frontier

We now identify $d_{\mathrm{eff}}$ with a matrix functional. Let $A$ be real
symmetric positive semidefinite with spectral decomposition $A = U D U^{*}$,
$D = \operatorname{diag}(\mu)$ and $U$ orthogonal.

**Lemma 4.1 (Resolvent diagonalization).** For $b>0$, $A + b\mathbb{1}$ is
invertible and
$$
(A + b\mathbb{1})^{-1} \;=\; U \operatorname{diag}\!\Big(\frac{1}{\mu_i+b}\Big) U^{*}.
$$

*Proof.* $A + b\mathbb{1} = U(D + b\mathbb{1})U^{*}$ since $UU^{*} = \mathbb{1}$;
$D + b\mathbb{1}$ is diagonal with entries $\mu_i + b > 0$ (as $\mu_i \ge 0$),
hence invertible with the stated diagonal inverse; conjugation by a unitary is
multiplicative, so the conjugated inverse is the inverse of the conjugate.
$\square$

**Lemma 4.2 (Trace of a conjugate).** $\operatorname{tr}(U M U^{*}) = \operatorname{tr} M$, by cyclicity
of the trace and $U^{*}U = \mathbb{1}$.

**Theorem 4.3 (Trace lemma).** For $A \succeq 0$ with eigenvalues $\mu$ and
$b>0$,
$$
\operatorname{tr}\big(A (A + b\mathbb{1})^{-1}\big) \;=\; \sum_i \frac{\mu_i}{\mu_i+b} \;=\; d_{\mathrm{eff}}(\mu,b).
$$

*Proof.* By Lemma 4.1, $A(A+b\mathbb{1})^{-1} = U D U^{*} \cdot
U\operatorname{diag}((\mu_i+b)^{-1})U^{*} = U \operatorname{diag}\big(\mu_i/(\mu_i+b)\big) U^{*}$;
apply Lemma 4.2. $\square$

**Corollary 4.4 (Variational form).** For $A \succeq 0$ and $b>0$, the minimum
excess risk of every spectral filter on data with covariance $A$ is exactly
$$
\min_t R_{\mu,b}(t) \;=\; b \operatorname{tr}\big(A(A+b\mathbb{1})^{-1}\big),
$$
and this quantity is at most $\min\big(\operatorname{tr} A, \ nb, \ b\operatorname{rank} A\big)$.

*Proof.* Combine Theorems 3.4 and 4.3. The three bounds follow from
Proposition 2.4(1) together with the observation that a zero eigenvalue
contributes $0$ to $d_{\mathrm{eff}}$, so $d_{\mathrm{eff}} \le \operatorname{rank} A$.
$\square$

The bound $d_{\mathrm{eff}} \le \operatorname{tr} A / b$ is the *trace bound*. It is the
weakest of the natural comparisons, because it replaces each saturating
contribution $\mu_i/(\mu_i+b) < 1$ by the unbounded linear $\mu_i/b$. The next
section repairs this.

---

## 5. The capacity frontier

**Definition 5.1 (Capacity).** For a spectrum $a \ge 0$ and $b > 0$,
$$
C(a,b) \;=\; \sum_i \log\!\Big(1 + \frac{a_i}{b}\Big).
$$

Up to the conventional factor $\tfrac12$, $C$ is the Shannon capacity in nats of
a bank of parallel Gaussian channels with per-mode signal powers $a_i$ and common
noise power $b$; equivalently it is (twice) the log-evidence of the Bayesian
linear model with independent priors of variance $a_i$; equivalently, as
Theorem 5.6 shows, it is the log-determinant of the regularized covariance.

**Theorem 5.2 (Scalar capacity sandwich).** For $x \ge 0$ and $b>0$,
$$
\frac{x}{x+b} \;\le\; \log\!\Big(1 + \frac{x}{b}\Big) \;\le\; \frac{x}{b}.
$$

*Proof.* Both halves use $\log y \le y-1$ for $y>0$.
*Right:* take $y = 1 + x/b > 0$; then $\log(1+x/b) \le x/b$.
*Left:* take $y = (1+x/b)^{-1} > 0$; then $-\log(1+x/b) = \log y \le y - 1$, and
$$
y - 1 \;=\; \frac{1}{1+x/b} - 1 \;=\; \frac{b}{x+b} - 1 \;=\; -\frac{x}{x+b},
$$
so $-\log(1+x/b) \le -x/(x+b)$, i.e. $x/(x+b) \le \log(1+x/b)$. $\square$

Geometrically: $u \mapsto \log(1+u)$ lies below its tangent at $0$ (the linear
bound) and above the chord-like saturating profile $u/(1+u)$ (the harmonic
bound), with $u = x/b$. The three functions agree to first order at $u=0$ and
separate at second order — which is exactly why the frontier is strict but not
crude.

**Theorem 5.3 (Capacity frontier).** For $a \ge 0$ and $b>0$,
$$
d_{\mathrm{eff}}(a,b) \;\le\; C(a,b) \;\le\; \frac{1}{b}\sum_i a_i .
$$

*Proof.* Sum Theorem 5.2 over modes with $x = a_i$; for the right-hand
inequality note $\sum_i a_i/b = \big(\sum_i a_i\big)/b$. $\square$

**Corollary 5.4 (Risk form).** $\mathcal{N}(a,b) \le b\,C(a,b)$, by multiplying
the left inequality of Theorem 5.3 by $b>0$.

**Theorem 5.5 (Strictness).** With a single mode at the noise level,
$a = (1)$ and $b = 1$,
$$
d_{\mathrm{eff}} = \tfrac12, \qquad C = \log 2, \qquad \frac{\sum_i a_i}{b} = 1,
$$
and $\tfrac12 < \log 2 < 1$. Hence both inequalities of Theorem 5.3 are strict in
general, and the capacity frontier is a genuine refinement of the trace bound
rather than a restatement of it.

*Proof.* The three values are immediate. For $\log 2 < 1$: $2 < e$, and $\log$
is strictly increasing, so $\log 2 < \log e = 1$. For $\log 2 > 1/2$: $e < 4$
gives $e^{1/2} < 2$ (both sides positive, square), hence
$\tfrac12 = \log e^{1/2} < \log 2$. $\square$

We now pass to matrices.

**Theorem 5.6 (Capacity is a log-determinant).** Let $A \succeq 0$ be real
symmetric with eigenvalues $\mu$, and $b>0$. Then
$$
C(\mu, b) \;=\; \sum_i \log\!\Big(1 + \frac{\mu_i}{b}\Big) \;=\; \log \det\!\big(\mathbb{1} + b^{-1} A\big).
$$

*Proof.* Write $A = U D U^{*}$ with $U$ orthogonal and $D = \operatorname{diag}(\mu)$. Since
$U U^{*} = \mathbb{1}$,
$$
\mathbb{1} + b^{-1}A \;=\; U\big(\mathbb{1} + b^{-1} D\big)U^{*}
\;=\; U \operatorname{diag}\big(1 + b^{-1}\mu_i\big) U^{*}.
$$
Multiplicativity of the determinant gives
$\det(\mathbb{1}+b^{-1}A) = \det U \cdot \prod_i (1+b^{-1}\mu_i) \cdot \det U^{*}$,
and $\det U \cdot \det U^{*} = \det(UU^{*}) = 1$, so
$\det(\mathbb{1}+b^{-1}A) = \prod_i (1 + \mu_i/b)$. Each factor is strictly
positive because $\mu_i \ge 0$ and $b>0$, so the logarithm of the product is the
sum of the logarithms. $\square$

**Theorem 5.7 (Matrix capacity frontier).** For $A \succeq 0$ real symmetric and
$b>0$,
$$
\mathcal{N}(\mu, b) \;\le\; b\,\log\det\!\big(\mathbb{1} + b^{-1}A\big) \;\le\; \operatorname{tr} A .
$$

*Proof.* Substitute Theorem 5.6 into Corollary 5.4 for the left inequality,
using $\mu_i \ge 0$ (eigenvalues of a positive semidefinite matrix). For the
right inequality, multiply the right half of Theorem 5.3 by $b$ and use
$\operatorname{tr} A = \sum_i \mu_i$. $\square$

**Interpretation.** The chain places, from left to right: an *estimation-theoretic*
quantity (the minimal attainable mean squared error), an *information-theoretic*
quantity (the capacity of the Gaussian channel defined by the covariance), and a
*linear-algebraic* quantity (total signal power). The middle term is not an
interpolation invented for the purpose: it is the log-evidence of the Bayesian
model whose posterior mean is exactly the Wiener filter of Theorem 3.4. Thus the
frontier says that the same object which governs the *value* of the estimation
problem also governs the *information* it can carry, in the correct direction and
with no lost constants: the floor is dominated by the capacity, and the capacity
by the energy.

**Remark 5.8 (Asymptotic behaviour of the gaps).** For a mode with $a_i/b = u$
small, $u/(1+u) = u - u^2 + O(u^3)$, $\log(1+u) = u - u^2/2 + O(u^3)$, and the
linear bound is $u$. So in the low-SNR regime the three quantities differ only at
second order, and the capacity sits exactly halfway (in the $u^2$ coefficient)
between the other two. For $u$ large the separation is drastic: the floor
contribution tends to $1$, the capacity grows like $\log u$, and the trace bound
like $u$. The capacity frontier therefore buys an exponential improvement over
the trace bound in the high-SNR regime while remaining tight at low SNR.

---

## 6. Anatomy of the floor: the head/tail sandwich

**Definition 6.1.** $\displaystyle m(a,b) = \sum_i \min(a_i, b)$.

**Lemma 6.2 (Per-mode min sandwich).** For $x \ge 0$, $b>0$,
$$
\tfrac12 \min(x,b) \;\le\; \frac{xb}{x+b} \;\le\; \min(x,b).
$$

*Proof.* By symmetry in $x \leftrightarrow b$ assume $x \le b$, so
$\min(x,b) = x$. Upper: $xb/(x+b) \le xb/b = x$. Lower: $x + b \le 2b$ gives
$xb/(x+b) \ge xb/(2b) = x/2$. $\square$

**Theorem 6.3 (Head/tail sandwich).** For $a \ge 0$ and $b>0$,
$$
\tfrac12\, m(a,b) \;\le\; \mathcal{N}(a,b) \;\le\; m(a,b),
$$
and, splitting the modes into the *head* $H = \{i : a_i \ge b\}$ and the *tail*
$T = \{i : a_i < b\}$,
$$
m(a,b) \;=\; b\,|H| \;+\; \sum_{i \in T} a_i .
$$

*Proof.* Sum Lemma 6.2. The decomposition of $m$ is the partition of the index
set into $H$ and $T$ together with $\min(a_i,b) = b$ on $H$ and
$\min(a_i,b) = a_i$ on $T$. $\square$

Thus: *the irreducible risk is, within a factor of two, one unit of noise per
resolvable mode plus the entire energy of the drowned modes.*

**Proposition 6.4 (Sharpness of both constants).**
The lower constant $1/2$ is attained: for a single mode with $a = (b)$ one has
$\mathcal{N} = b/2 = m/2$. The upper constant $1$ is approached: for a single
mode with $a = (\varepsilon)$, $0 \le \varepsilon \le b$, one has
$\mathcal{N} = m \cdot \frac{b}{\varepsilon + b} \to m$ as
$\varepsilon \downarrow 0$. Hence no argument that sees the spectrum only through
$\min(a_i, b)$ can improve either constant.

**Corollary 6.5 (No learning below the noise).** If $a_i \le b$ for all $i$, then
$$
\tfrac12 R_{a,b}(0) \;\le\; \mathcal{N}(a,b),
$$
where $R_{a,b}(0) = \sum_i a_i$ is the risk of the do-nothing estimator: the best
spectral filter in existence beats doing nothing by at most a factor of two.

*Proof.* Under the hypothesis $m(a,b) = \sum_i a_i = R_{a,b}(0)$; apply the lower
half of Theorem 6.3. $\square$

**Corollary 6.6 (Saturation above the noise).** If $a_i \ge b$ for all $i$, then
$\mathcal{N}(a,b) \ge nb/2$: the irreducible risk grows linearly in the ambient
dimension.

*Proof.* Here $m(a,b) = nb$. $\square$

---

## 7. Which methods reach the floor?

### 7.1 Rigidity of ridge

**Theorem 7.1 (Ridge attains the floor iff isotropy).** Let $a \ge 0$, $b>0$,
$\mu_i > 0$ and $\lambda>0$. The ridge filter $r_i = \mu_i/(\mu_i+\lambda)$
satisfies $R_{a,b}(r) = \mathcal{N}(a,b)$ if and only if
$$
a_i\,\lambda \;=\; \mu_i\, b \qquad \text{for every } i .
$$

*Proof.* By Theorem 3.4, equality holds iff $r = w$, i.e.
$\mu_i/(\mu_i+\lambda) = a_i/(a_i+b)$ for all $i$. Both denominators are
positive; cross-multiplying gives $\mu_i a_i + \mu_i b = a_i\mu_i + a_i\lambda$,
i.e. $\mu_i b = a_i \lambda$. $\square$

Writing $a_i = \theta_i^2\mu_i$, the condition reads $\theta_i^2 \equiv b/\lambda$:
*ridge is Bayes-optimal exactly for an isotropic (flat) prior*, and for no other
signal geometry.

**Theorem 7.2 (Sharp $4/3$ gap).** Consider two modes with signal spectrum
$a = (1,0)$, flat covariance $\mu = (1,1)$ and $b=1$. A flat covariance forces
every ridge filter to be constant, $t \equiv c$, and
$$
R_{a,b}(t) = (1-c)^2 + 2c^2, \qquad \mathcal{N}(a,b) = \tfrac12 .
$$
Then $R_{a,b}(t) \ge \tfrac43 \mathcal{N}(a,b)$ for every $c \in \mathbb{R}$, with
equality at $c = 1/3$. The Wiener optimum here is $w = (1/2, 0)$, which is not
constant.

*Proof.* $R = (1-c)^2 + 2c^2 = 3c^2 - 2c + 1 = \tfrac{(3c-1)^2}{3} + \tfrac23 \ge \tfrac23 = \tfrac43\cdot\tfrac12$,
with equality iff $c = 1/3$. The floor is
$\frac{1\cdot 1}{1+1} + \frac{0\cdot 1}{0+1} = \tfrac12$, and
$w_1 = 1/2 \ne 0 = w_2$. $\square$

A single scalar regularizer therefore loses a *sharp* 33% on a two-dimensional
problem — not asymptotically, not in a contrived limit.

### 7.2 Early stopping versus ridge

**Lemma 7.3 (Two exponential estimates).** For $u \ge 0$:
$e^{-u} \le \frac{1}{1+u}$ and $1 - e^{-u} \le \frac{2u}{1+u}$.

*Proof sketch.* The first is $e^{u} \ge 1+u$. For the second, if $u \le 1$ then
$1-e^{-u} \le u \le 2u/(1+u)$ since $1+u \le 2$; if $u \ge 1$ then
$1-e^{-u} < 1 \le 2u/(1+u)$ since $2u \ge 1+u$. $\square$

**Theorem 7.4 (Early stopping never loses much).** For $a \ge 0$, $b \ge 0$,
$\mu \ge 0$ and $\tau>0$, the gradient-flow filter $g_i = 1-e^{-\mu_i\tau}$ and
the matched ridge filter $r$ with $\lambda = 1/\tau$ satisfy
$$
R_{a,b}(g) \;\le\; 4\, R_{a,b}(r).
$$

*Proof sketch.* With $u = \mu_i \tau \ge 0$ the matched ridge coefficient is
$r_i = \mu_i/(\mu_i + 1/\tau) = u/(1+u)$. It therefore suffices to prove the
per-mode inequality
$$
x\,e^{-2u} + b\,(1-e^{-u})^2 \;\le\; 4\Big( x\,\tfrac{1}{(1+u)^2} + b\,\tfrac{u^2}{(1+u)^2}\Big)
$$
for all $x, b, u \ge 0$, which splits into the bias comparison
$e^{-2u} \le 4(1+u)^{-2}$ (indeed $\le (1+u)^{-2}$, from Lemma 7.3) and the
variance comparison $(1-e^{-u})^2 \le 4u^2/(1+u)^2$ (the square of Lemma 7.3's
second estimate). Summing over modes gives the claim. $\square$

**Theorem 7.5 (The converse fails, unboundedly).** On one mode with
$\mu = 1$, $b = 1$, signal power $a = e^{20}$, stopping time $\tau = 10$ and
matched $\lambda = 1/10$,
$$
100\, R_{a,b}(g) \;\le\; R_{a,b}(r) .
$$

*Proof sketch.* Early stopping pays $a e^{-20} + (1-e^{-10})^2 = 1 + (1-e^{-10})^2 \le 2$.
Matched ridge pays $a(1 - \tfrac{1}{1+1/10})^2 + (\tfrac{1}{1+1/10})^2 \ge e^{20}/121 > 200$,
using $e^{20} \ge 24200$. $\square$

Hence the folklore identification "early stopping $=$ ridge with
$\lambda = 1/\tau$" is genuinely one-sided: bounded by a universal factor $4$ in
one direction, unbounded in the other. The mechanism is visible in the filter
shapes: the exponential profile suppresses the bias of well-conditioned modes at
rate $e^{-\mu\tau}$, whereas the ridge profile suppresses it only at rate
$(1+\mu\tau)^{-1}$. Both, of course, obey Theorem 3.2 and cannot go below
$\mathcal{N}$.

---

## 8. The hardest spectrum: a minimax theorem

Fix $n$ modes, a noise level $b>0$ and a total signal energy $S \ge 0$. Which
distribution of energy across modes maximizes the irreducible risk?

**Lemma 8.1 (Tangent-line bound with exact remainder).** Let
$\varphi(x) = xb/(x+b)$ on $[0,\infty)$, $b>0$. For $x, c \ge 0$,
$$
\varphi(x) \;=\; \varphi(c) + \varphi'(c)\,(x-c) \;-\; \frac{b^2 (x-c)^2}{(c+b)^2 (x+b)},
\qquad \varphi'(c) = \frac{b^2}{(c+b)^2},
$$
and in particular $\varphi(x) \le \varphi(c) + \varphi'(c)(x-c)$.

*Proof.* Direct algebraic verification: bring the right-hand side over the
common denominator $(c+b)^2(x+b)$ and expand. The remainder is manifestly
nonpositive. $\square$

**Theorem 8.2 (Minimax spectrum).** For $b>0$, $S \ge 0$ and $n \ge 1$,
$$
\max\Big\{\mathcal{N}(a,b)\ :\ a \ge 0,\ \textstyle\sum_i a_i = S\Big\}
\;=\; \frac{S\,b\,n}{S + n b},
$$
and the maximum is attained by the isotropic spectrum $a_i \equiv S/n$.

*Proof.* Apply Lemma 8.1 with $c = S/n$ in each mode and sum:
$$
\mathcal{N}(a,b) \le \sum_i \Big(\varphi(c) + \varphi'(c)(a_i - c)\Big)
= n\varphi(c) + \varphi'(c)\Big(\sum_i a_i - nc\Big) = n\varphi(c),
$$
because $\sum_i a_i = S = nc$. The value at the flat spectrum is
$n \varphi(S/n) = n \cdot \frac{(S/n) b}{S/n + b} = \frac{Sbn}{S+nb}$. $\square$

**Corollary 8.3 (Regimes).** $\dfrac{Sbn}{S+nb} \le \min(S, nb)$, with
$\approx S$ when $nb \gg S$ (nothing is learnable: the risk is the whole signal)
and $\approx nb$ when $nb \ll S$ (one unit of noise per mode). The crossover is at
$S = nb$, i.e. at per-mode signal-to-noise ratio $1$ — the same threshold as in
Theorem 3.6 and Theorem 6.3.

*Proof.* Cross-multiplying, $Sbn \le S(S+nb)$ reduces to $0 \le S^2$, and
$Sbn \le nb(S+nb)$ to $0 \le (nb)^2$. $\square$

The adversary's optimal move is therefore *not* to concentrate the signal — a
concentrated spectrum has small effective dimension and is easy — but to spread
it so thin that every mode hovers near the detection threshold, maximizing the
number of modes that are neither cleanly learnable nor cleanly ignorable.

---

## 9. A derived scaling law

Neural scaling laws assert that irreducible error decays like a power of the
data, sometimes with a logarithmic correction. Since $\mathcal{N}(a,b)$ *is* the
irreducible error and $b = \sigma^2/N$, such a law is now a computation with a
fixed spectrum rather than a modelling postulate. We carry it out for the
geometric spectrum $a_i = r^i$, $0 < r < 1$, $i = 0, \dots, n-1$, the generic
picture for analytic kernels and for empirical covariance spectra with
exponential decay.

**Lemma 9.1 (Geometric tail).** For $0<r<1$ and $k \le n$,
$\sum_{i=k}^{n-1} r^i \le \dfrac{r^{k}}{1-r}$.

**Theorem 9.2 (Two-sided bounds at an arbitrary cut).** For $0<r<1$, $b>0$,
$m+1 \le n$:
$$
\mathcal{N} \;\le\; b(m+1) + \frac{r^{m+1}}{1-r},
\qquad\text{and if } b \le r^m, \quad \mathcal{N} \;\ge\; \frac{b(m+1)}{2}.
$$

*Proof sketch.* Upper: by Theorem 6.3, $\mathcal{N} \le \sum_i \min(r^i, b)$;
bound the first $m+1$ terms by $b$ and the remaining ones by $r^i$, then apply
Lemma 9.1. Lower: by Theorem 6.3 again, $\mathcal{N} \ge \tfrac12 \sum_i \min(r^i,b)$;
for $i \le m$ we have $r^i \ge r^m \ge b$, so each of the first $m+1$ terms
equals $b$. $\square$

**Theorem 9.3 (Geometric scaling law).** Choose the natural cut $m$ with
$r^{m+1} \le b \le r^m$. Then
$$
\frac{b(m+1)}{2} \;\le\; \mathcal{N} \;\le\; b(m+1) + \frac{b}{1-r}.
$$
Since $m \asymp \log(1/b)/\log(1/r)$, this gives
$$
\mathcal{N} \;\asymp\; b \log(1/b) \;=\; \frac{\sigma^2}{N}\,\log\frac{N}{\sigma^2},
$$
the log-corrected $1/N$ law, with explicit constants on both sides.

*Proof.* Substitute $r^{m+1} \le b$ into the upper bound of Theorem 9.2 and
combine with the lower bound. $\square$

**Example 9.4.** For $r = 1/2$, $b = 1/10$ and $n = 10$ modes, the natural cut is
$m = 3$ (since $(1/2)^4 = 1/16 \le 1/10 \le 1/8 = (1/2)^3$), and the floor is
pinned between $0.2$ and $0.6$. (The true value is $\approx 0.390$.)

---

## 10. Algorithms

All quantities above are computable from a spectrum in $O(n)$ time and from a
covariance matrix in $O(n^3)$ time (one symmetric eigendecomposition, or one
Cholesky factorization for the log-determinant).

**Algorithm A (Noise floor and optimal filter).** Given $a \in \mathbb{R}_{\ge0}^n$
and $b>0$: return $w_i = a_i/(a_i+b)$, $d_{\mathrm{eff}} = \sum_i w_i$ and
$\mathcal{N} = b\,d_{\mathrm{eff}}$. Cost $O(n)$. Correctness: Theorem 3.4.

**Algorithm B (Capacity frontier certificate).** Given $a, b$: return the triple
$\big(\mathcal{N},\ bC,\ \sum_i a_i\big)$ with $C = \sum_i \log(1+a_i/b)$; by
Theorem 5.7 the triple is nondecreasing, which serves as a runtime certificate of
the frontier. Cost $O(n)$. For a matrix input $A$, compute
$\log\det(\mathbb{1} + b^{-1}A)$ stably as $2\sum_i \log L_{ii}$ from the Cholesky
factor $L$ of $\mathbb{1}+b^{-1}A$, avoiding overflow in the determinant; cost
$O(n^3)$.

**Algorithm C (Head/tail audit).** Given $a, b$: partition modes into
$H = \{a_i \ge b\}$ and $T = \{a_i < b\}$; return $|H|$, $\sum_T a_i$, and the
sandwich interval $\big[\tfrac12 m, m\big]$ with $m = b|H| + \sum_T a_i$. This
reports *why* the floor has the value it has: how much comes from resolvable
modes and how much from drowned energy. Cost $O(n)$.

**Algorithm D (Method audit).** Given $a$, $b$, covariance spectrum $\mu$ and a
candidate method (ridge $\lambda$, early stopping $\tau$, or spectral cut-off
$k$): compute the filter, its risk $R_{a,b}(t)$, and the *inefficiency ratio*
$R_{a,b}(t)/\mathcal{N}(a,b) \ge 1$. By Theorem 7.1 the ratio equals $1$ only
under exact isotropy; Theorem 7.2 shows it can be as large as $4/3$ for ridge on
a two-mode problem and, by Theorem 7.5, unboundedly large in general. Cost
$O(n)$.

---

## 11. Discussion

**What is new.** The exactness of $\mathcal{N}$ as a minimum over all spectral
filters, and the identity $d_{\mathrm{eff}} = \operatorname{tr}(A(A+b\mathbb{1})^{-1})$, put a
familiar heuristic on a rigorous footing. The genuinely new contribution here is
the capacity frontier of §5: the observation that the correct object mediating
between the *estimation* quantity $d_{\mathrm{eff}}$ and the *energy* quantity
$\operatorname{tr} A / b$ is the log-determinant $\log\det(\mathbb{1}+b^{-1}A)$ — the Gaussian
channel capacity of the data — together with the proof that the resulting
three-term chain is strict already for a single mode at threshold. The scalar
engine, $x/(x+b) \le \log(1+x/b) \le x/b$, is elementary; the point is that the
middle term is not an arbitrary interpolant but a quantity with independent
meaning in three theories at once (information, Bayesian evidence, matrix
analysis).

**Why the intermediate term matters.** In the high signal-to-noise regime the
trace bound is off by a factor $u/\log u$ per mode, which is unbounded; the
capacity bound is off only by $\log u$ against a floor contribution of $1$. In
practice this means: a certificate based on the trace of the covariance
overstates the irreducible risk badly for spectra with a few dominant
directions, whereas a certificate based on the log-determinant remains
informative. Since $\log\det(\mathbb{1}+b^{-1}A)$ can be computed by a Cholesky
factorization — with no eigendecomposition, and with stochastic
Hutchinson-type estimators available at large scale — the middle term is also
the practical one.

**Relation to standard notions of effective dimension.** The quantity
$\operatorname{tr}(A(A+b\mathbb{1})^{-1})$ appears throughout kernel learning and Gaussian
process theory as *the* effective degrees of freedom; the log-determinant appears
as the complexity penalty in the marginal likelihood. The frontier makes the
relation between the two precise and directional: degrees of freedom $\le$
log-evidence penalty $\le$ energy budget, with all three evaluated on the same
regularized covariance.

**Limitations.** The theory is exact for diagonal (spectral) estimators in the
fixed-design, known-spectrum setting. Three idealizations are worth naming.
(i) The optimizer $w$ depends on the unknown signal spectrum $a$; the results
quantify the cost of not knowing $a$ (Theorems 7.1, 7.2) but do not construct an
adaptive estimator. (ii) Non-diagonal estimators are outside the family; in the
Gaussian sequence model the diagonal restriction is not a loss for linear
estimators, but nonlinear thresholding can beat the linear floor for sparse
signals. (iii) Random-design and covariance-estimation effects are absorbed into
the single parameter $b$.

---

## 12. Future directions

Two concrete conjectures organize the next steps.

**Conjecture D1 (Loewner monotonicity of the noise floor).** For real positive
semidefinite $A \preceq B$ in the Loewner order and $b>0$,
$$
\operatorname{tr}\big(A(A+b\mathbb{1})^{-1}\big) \;\le\; \operatorname{tr}\big(B(B+b\mathbb{1})^{-1}\big).
$$
The key insight is that $x \mapsto x/(x+b) = 1 - b/(x+b)$ is operator monotone,
so the statement reduces to antitonicity of the matrix inverse on the positive
cone, $A \preceq B \Rightarrow (B+b\mathbb{1})^{-1} \preceq (A+b\mathbb{1})^{-1}$,
followed by taking traces — converting an analytic inequality into a
congruence-transformation argument via the positive square root. With D1 the
whole theory upgrades from "fixed spectrum" to "monotone in the data covariance":
*more data in the Loewner sense never lowers the effective dimension.* A
falsifier would be a pair $A \preceq B$ of $2\times2$ positive semidefinite
matrices with $\operatorname{tr}(A(A+b)^{-1}) > \operatorname{tr}(B(B+b)^{-1})$.

**Conjecture D2 (Sharp early-stopping constant).** The constant $4$ in
Theorem 7.4 can be replaced by
$$
\kappa^{*} \;=\; \sup_{u \ge 0} \frac{e^{-2u} + (1-e^{-u})^2}{(1+u)^{-2} + u^2(1+u)^{-2}} \;<\; 2,
$$
attained at a unique interior $u^{*} \approx 2.2$, and no constant below
$\kappa^{*}$ works for every signal-to-noise ratio. The key insight is that the
ratio of the two per-mode risks depends on the spectrum only through
$u = \mu_i \tau$, so the entire comparison collapses to a one-dimensional
extremal problem — a calculus-of-one-variable statement hidden inside a piece of
statistical folklore.

Beyond these: an analogous frontier for non-quadratic losses; a version of the
capacity frontier with the operator-norm rather than trace-norm normalization; an
adaptive estimator provably within a constant of $\mathcal{N}$ without knowledge
of $a$; and the extension of the geometric scaling law of §9 to polynomially
decaying spectra $a_i = i^{-\alpha}$, where the head/tail sandwich should produce
the power law $\mathcal{N} \asymp b^{1 - 1/\alpha}$.

---

## 13. Summary of main results

| Result | Statement |
|---|---|
| Noise-Floor Principle | $\min_t R_{a,b}(t) = \mathcal{N}(a,b) = \sum_i a_i b/(a_i+b)$, uniquely at $t_i = a_i/(a_i+b)$ |
| Trace lemma | $d_{\mathrm{eff}}(\mu,b) = \operatorname{tr}\big(A(A+b\mathbb{1})^{-1}\big)$ |
| Scalar capacity sandwich | $x/(x+b) \le \log(1+x/b) \le x/b$ |
| Capacity frontier | $d_{\mathrm{eff}} \le \sum_i \log(1+a_i/b) \le \sum_i a_i / b$ |
| Log-determinant identity | $\sum_i \log(1+\mu_i/b) = \log\det(\mathbb{1}+b^{-1}A)$ |
| Matrix frontier | $\mathcal{N} \le b\log\det(\mathbb{1}+b^{-1}A) \le \operatorname{tr} A$ |
| Strictness | at $a=b=1$, one mode: $1/2 < \log 2 < 1$ |
| Head/tail sandwich | $\tfrac12\sum_i \min(a_i,b) \le \mathcal{N} \le \sum_i \min(a_i,b)$, both sharp |
| Ridge rigidity | ridge optimal $\iff a_i\lambda = \mu_i b$ for all $i$ |
| Ridge gap | sharp factor $4/3$ on $a=(1,0)$, $b=1$ |
| Early stopping | $R(g) \le 4R(r_{1/\tau})$ always; converse false by a factor $>100$ |
| Minimax spectrum | $\max_{\sum a_i = S} \mathcal{N} = Sbn/(S+nb)$, at the flat spectrum |
| Scaling law | geometric spectrum: $b(m+1)/2 \le \mathcal{N} \le b(m+1) + b/(1-r)$, i.e. $\mathcal{N} \asymp b\log(1/b)$ |
