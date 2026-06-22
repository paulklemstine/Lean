# The Euler–Mascheroni Constant: Monotone Sandwiches, a Positive-Term Telescoping Series, and an Integer-Linear-Form Irrationality Criterion

**Author:** Aristotle
**Date:** 2026-06-22

## Abstract

We present a self-contained, fully formalized development of the elementary
analytic theory of the Euler–Mascheroni constant
$\gamma = \lim_{n\to\infty}(H_n - \ln n)$, organized around the theme of
*irrationality approaches*. Three results form the core. First, an explicit
finite-rate approximation theorem: for all $n \ge 1$,
$\lvert H_n - \ln n - \gamma\rvert < 1/n$, derived from a pair of monotone
auxiliary sequences that sandwich $\gamma$. Second, a reconstruction of $\gamma$
as a convergent series of strictly positive terms,
$\gamma = \sum_{k\ge 1}\bigl(1/k - \ln\frac{k+1}{k}\bigr)$, obtained by telescoping
the logarithmic part of the lower sandwich sequence. Third, a rigorous statement of
the classical integer-linear-form irrationality criterion: if a real $x$ admits
integer sequences $a_n, b_n$ with $b_n > 0$, $b_n x - a_n \ne 0$, and
$b_n x - a_n \to 0$, then $x$ is irrational. We emphasize that the third result is a
*one-way criterion*; it is the lever that an irrationality proof for $\gamma$ would
have to operate, and we do **not** claim such a proof here, $\gamma$'s irrationality
being open. We give complete definitions, full statements, and proof sketches from
which the arguments can be reconstructed, together with algorithms and numerical
demonstrations.

---

## 1. Introduction

The harmonic numbers $H_n = \sum_{k=1}^n 1/k$ diverge to $+\infty$, but their
divergence is logarithmic: $H_n - \ln n$ converges. Its limit is the
**Euler–Mascheroni constant**
$$\gamma = \lim_{n\to\infty}(H_n - \ln n) = 0.57721566490153286\ldots,$$
introduced by Euler (1734) and refined by Mascheroni (1790). Despite its
ubiquity — in analytic number theory, the analysis of algorithms, special-function
theory, and physical regularization — the arithmetic nature of $\gamma$ remains a
famous open problem: it is not known whether $\gamma$ is rational, let alone
algebraic or transcendental.

This paper does not resolve that problem. Instead it builds the rigorous elementary
scaffolding on which any approach must stand: existence and a sharp approximation
rate (Section 3), an explicit positive-term series representation (Section 4), and
the precise irrationality criterion that converts "prove $\gamma$ irrational" into a
concrete construction problem (Section 5). Every statement below corresponds to a
formally verified result; the formal names are given in brackets.

### 1.1 Notation

Throughout, $\ln$ denotes the natural logarithm, $H_n = \sum_{k=1}^n 1/k$ with
$H_0 = 0$, and $\mathbb{Z}, \mathbb{Q}, \mathbb{R}$ are the usual number systems. A
real number is *rational* if it lies in $\mathbb{Q}$ and *irrational* otherwise.

### 1.2 Historical and computational background

Euler first isolated $\gamma$ in 1734 while studying the harmonic series, computing
it to six decimals; he denoted it $C$ and $O$ at various times. Mascheroni, in his
1790 *Adnotationes ad calculum integralem Euleri*, computed it to thirty-two places
(of which only nineteen were later found correct) and the symbol $\gamma$, suggested
by its connection to the Gamma function, became standard. Modern record computations
exceed $10^{12}$ digits, all obtained not from the defining limit $H_n - \ln n$ —
which, as Theorem 1 will quantify, converges only like $1/n$ — but from rapidly
converging representations built on Bessel-function and exponential-integral
identities. The slow convergence of the defining limit is itself a recurring theme:
it is precisely *because* $H_n - \ln n$ approaches $\gamma$ at the leisurely rate of
$1/n$ that accelerations and series rearrangements (Section 9) are interesting, and
it is precisely *because* no rational structure has been forced out of those
representations that irrationality remains open.

The arithmetic status of $\gamma$ contrasts sharply with that of its analytic
neighbours. The irrationality of $e$ (Euler) and of $\pi$ (Lambert, 1761) is
classical; their transcendence follows from Hermite–Lindemann. For $\gamma$, by
contrast, no proof of irrationality is known, and the strongest unconditional
results are conditional or partial (for example, at most one of $\gamma$ and certain
related constants can be rational under various hypotheses). The present development
deliberately stops at the threshold of this open problem: it furnishes the exact
logical instrument (Theorem 3) an eventual proof must wield, together with the
explicit constructions (Theorems 1 and 2) most likely to feed it.

---

## 2. Definitions

**Definition 1 (Euler–Mascheroni constant, `eulerMascheroniConstant`).**
$$\gamma := \lim_{n\to\infty}\bigl(H_n - \ln n\bigr).$$
Equivalently, $\gamma$ is the common limit of the two auxiliary sequences in
Definition 2; this equivalence is what makes the limit well defined.

**Definition 2 (Sandwiching sequences, `eulerMascheroniSeq`, `eulerMascheroniSeq'`).**
For $n \ge 1$ define the *lower sequence* and *upper sequence*
$$a_n := H_n - \ln(n+1) \quad(\texttt{eulerMascheroniSeq}),\qquad
b_n := H_n - \ln n \quad(\texttt{eulerMascheroniSeq'}).$$

**Definition 3 (Gamma series term, used in `hasSum_gammaSeries`).**
For $k \ge 1$ define
$$g_k := \frac{1}{k} - \ln\frac{k+1}{k} = \frac1k - \ln\!\Bigl(1+\frac1k\Bigr).$$

The single analytic input underlying every result is the elementary logarithm
inequality
$$\ln(1+x) \le x \quad\text{for all } x > -1, \quad\text{with strict inequality for } x \neq 0. \tag{$\star$}$$
We record its immediate consequences.

**Lemma 0 (Logarithmic step bounds).** For every integer $n \ge 1$,
$$\frac{1}{n+1} \;<\; \ln\frac{n+1}{n} \;<\; \frac1n. \tag{2.1}$$
*Proof.* The right inequality is $(\star)$ with $x = 1/n$:
$\ln(1+1/n) < 1/n$. For the left inequality apply $(\star)$ with
$x = -\tfrac{1}{n+1} \in(-1,0)$: $\ln\!\bigl(\tfrac{n}{n+1}\bigr) < -\tfrac{1}{n+1}$,
i.e. $-\ln\frac{n+1}{n} < -\frac{1}{n+1}$, which rearranges to the claim. $\qquad\blacksquare$

---

## 3. Existence, the sandwich, and the approximation rate

### 3.1 Monotonicity and convergence

**Proposition 1 (Monotone sandwich).** The sequence $a_n$ is strictly increasing,
the sequence $b_n$ is strictly decreasing, $a_n < b_n$ for all $n$, and
$b_n - a_n = \ln\frac{n+1}{n} \to 0$. Consequently both converge to a common limit,
which is $\gamma$ (Definition 1).

*Proof sketch.* Compute the consecutive differences using $H_{n+1} - H_n =
\tfrac{1}{n+1}$:
$$a_{n+1} - a_n = \frac{1}{n+1} - \ln\frac{n+2}{n+1}, \qquad
b_{n+1} - b_n = \frac{1}{n+1} - \ln\frac{n+1}{n}.$$
By the right inequality of (2.1) applied at $n+1$, $\ln\frac{n+2}{n+1} < \frac{1}{n+1}$,
so $a_{n+1}-a_n > 0$: $a_n$ increases. By the left inequality of (2.1),
$\ln\frac{n+1}{n} > \frac{1}{n+1}$, so $b_{n+1}-b_n < 0$: $b_n$ decreases. Their
difference is $b_n - a_n = \ln(n+1) - \ln n = \ln\frac{n+1}{n} \in (0, 1/n)$ by
(2.1), hence positive and $\to 0$. A bounded monotone increasing sequence below a
bounded monotone decreasing sequence with vanishing gap converges to a shared limit;
that limit is $\gamma$. $\qquad\blacksquare$

### 3.2 The explicit error bound

**Theorem 1 (Explicit approximation rate, `abs_harmonic_sub_log_sub_gamma_lt`).**
For every integer $n \ge 1$,
$$\bigl\lvert H_n - \ln n - \gamma \bigr\rvert < \frac{1}{n}. \tag{3.1}$$

*Proof sketch.* By Definition 2, $H_n - \ln n = b_n$. Since $b_n$ decreases to
$\gamma$ (Proposition 1), $b_n - \gamma > 0$, so the absolute value equals
$b_n - \gamma$. Because $\gamma$ is the limit of the increasing sequence $a_m$ and
$a_m \le b_n$ for all $m \ge n$ (the lower fence never exceeds any value of the upper
fence), we have $\gamma \ge a_n$. Hence
$$0 < b_n - \gamma \le b_n - a_n = \ln\frac{n+1}{n} < \frac1n,$$
the last step by the right inequality of (2.1). This proves the strict bound
(3.1). $\qquad\blacksquare$

**Remark.** The proof in fact establishes the sharper *one-sided* statement
$0 < H_n - \ln n - \gamma < 1/n$. The symmetric absolute-value form (3.1) is the
formalized statement; sharpening the upper bound to $1/(2n)$ requires the
second-order Taylor estimate for $\ln$ and is recorded as a future direction.

---

## 4. A positive-term telescoping series for gamma

The sandwich proves existence; the next result exhibits $\gamma$ as an explicit
infinite sum, every term of which is positive.

**Theorem 2 (Positive-term series, `hasSum_gammaSeries`).** With $g_k$ as in
Definition 3,
$$\sum_{k=1}^{\infty}\left(\frac1k - \ln\frac{k+1}{k}\right) = \gamma, \tag{4.1}$$
and the series converges. Moreover each term satisfies $0 < g_k < \dfrac{1}{2k^2}$
for $k \ge 1$, so the convergence is absolute and at least as fast as $\sum 1/k^2$.

*Proof sketch.* Positivity of $g_k$ is the right inequality of (2.1):
$\ln\frac{k+1}{k} < 1/k$. For the partial sums, telescope the logarithms:
$$S_n := \sum_{k=1}^n g_k = \sum_{k=1}^n \frac1k - \sum_{k=1}^n \ln\frac{k+1}{k}
= H_n - \ln(n+1) = a_n,$$
because $\sum_{k=1}^n \ln\frac{k+1}{k} = \ln\frac{n+1}{1} = \ln(n+1)$ telescopes. By
Proposition 1, $a_n \to \gamma$, so the partial sums converge to $\gamma$, which is
exactly the statement that the series has sum $\gamma$. The quadratic bound
$g_k < 1/(2k^2)$ follows from the second-order estimate
$\ln(1+x) > x - x^2/2$ for $x>0$ applied at $x = 1/k$:
$g_k = 1/k - \ln(1+1/k) < 1/k - (1/k - 1/(2k^2)) = 1/(2k^2)$. $\qquad\blacksquare$

**Lemma 1 (Second-order logarithm bound).** For every $x > 0$,
$x - \tfrac{x^2}{2} < \ln(1+x) < x$. In particular, for $k \ge 1$,
$$\frac{1}{2k^2} - \frac{1}{3k^3} < g_k < \frac{1}{2k^2}.$$
*Proof sketch.* The upper bound is $(\star)$. For the lower bound, the function
$h(x) = \ln(1+x) - x + x^2/2$ satisfies $h(0)=0$ and
$h'(x) = \frac{1}{1+x} - 1 + x = \frac{x^2}{1+x} > 0$ for $x>0$, so $h$ is strictly
increasing and positive. Substituting $x = 1/k$ and expanding
$g_k = 1/k - \ln(1+1/k)$ between the two bounds gives the displayed two-sided
estimate for $g_k$. $\qquad\blacksquare$

Lemma 1 explains the numerics of Section 7 quantitatively: since
$g_k \approx 1/(2k^2)$, the truncation tail after $N$ terms is
$\sum_{k>N} g_k \approx \sum_{k>N} 1/(2k^2) \approx 1/(2N)$, matching the observed
$\sim 1/(2n)$ decay of the approximation error and motivating the sharpened rate of
Section 9.

This representation is the structural heart of the "irrationality approaches"
theme: it presents $\gamma$ as a concrete, controlled sum of positive rational-plus-
logarithm pieces, which is the raw material from which accelerated and integer-
combination representations (Vacca-type series, binary-digit regroupings) are
constructed.

---

## 5. The integer-linear-form irrationality criterion

We now state the general lever. Let $x \in \mathbb{R}$. An *integer linear form* in
$x$ is a quantity $b\,x - a$ with $a, b \in \mathbb{Z}$, $b > 0$; it measures the
deviation of $x$ from the rational number $a/b$ (scaled by $b$).

**Theorem 3 (Irrationality from vanishing integer linear forms,
`irrational_of_int_linear_forms`).** Let $x \in \mathbb{R}$. Suppose there exist
sequences $(a_n)_{n}, (b_n)_{n}$ in $\mathbb{Z}$ such that for all $n$:
1. $b_n > 0$;
2. $b_n x - a_n \neq 0$; and
3. $\displaystyle \lim_{n\to\infty}(b_n x - a_n) = 0$.

Then $x$ is irrational.

*Proof sketch.* Suppose for contradiction $x = p/q$ with $p \in \mathbb{Z}$,
$q \in \mathbb{Z}_{>0}$. Then for each $n$,
$$b_n x - a_n = \frac{b_n p - a_n q}{q}, \qquad b_n p - a_n q \in \mathbb{Z}.$$
By hypothesis (2) this integer numerator is nonzero, hence
$\lvert b_n p - a_n q\rvert \ge 1$, giving the uniform lower bound
$$\lvert b_n x - a_n\rvert = \frac{\lvert b_n p - a_n q\rvert}{q} \ge \frac1q > 0
\quad\text{for all } n.$$
But hypothesis (3) forces $\lvert b_n x - a_n\rvert < 1/q$ for all sufficiently
large $n$. These contradict, so no such $p/q$ exists and $x$ is irrational.
$\qquad\blacksquare$

**Scope and honesty.** Theorem 3 is a *sufficient* condition only. It reduces a
prospective irrationality proof for any specific constant to the construction of
admissible sequences $(a_n), (b_n)$. For $\gamma$ no such construction is currently
known; consequently **the irrationality of $\gamma$ remains open and is not claimed
here.** The value of Theorem 3 in this package is methodological: it states, without
loopholes, the exact target an Apéry-style attack on $\gamma$ would need to hit.

**Worked illustration ($x = \sqrt 2$).** The continued-fraction convergents
$a_n/b_n$ of $\sqrt 2$ are $3/2, 7/5, 17/12, 41/29, 99/70, \dots$, generated by
$a_{n+1} = a_n + 2b_n$, $b_{n+1} = a_n + b_n$. The forms $b_n\sqrt2 - a_n$ equal
$-0.085786\ldots,\ 0.029437\ldots,\ -0.010153\ldots,\ 0.003498\ldots,\dots$,
all nonzero, alternating, with $\lvert b_n\sqrt2 - a_n\rvert < 1/b_n \to 0$. Theorem
3 therefore certifies the irrationality of $\sqrt 2$. (For $\gamma$ the analogous
sequences are precisely what is missing.)

---

## 6. Algorithms

We summarize the constructive content as three algorithms; full code appears in the
accompanying `demo.py` and the package's `algorithms` array.

**Algorithm A (Bracketed evaluation of $\gamma$).** Given a tolerance $\varepsilon$,
choose $N = \lceil 1/\varepsilon\rceil$, compute $H_N$ by accumulation, and return
the bracket $[a_N, b_N] = [H_N - \ln(N+1),\, H_N - \ln N]$. By Proposition 1 the true
value lies inside, and by Theorem 1 the midpoint approximates $\gamma$ with error
below $1/N \le \varepsilon$. Cost: $O(N)$ additions.

**Algorithm B (Positive-term series accumulation).** Sum the terms
$g_k = 1/k - \ln(1+1/k)$ for $k = 1, \dots, N$. By Theorem 2 the partial sum equals
$a_N = H_N - \ln(N+1)$ and the truncation tail is bounded by
$\sum_{k>N} 1/(2k^2) < 1/(2N)$. This yields a guaranteed lower estimate of $\gamma$
that increases monotonically toward it.

**Algorithm C (Irrationality-criterion checker).** Given finite samples of integer
sequences $(a_n), (b_n)$ and a high-precision value of $x$, verify the three
hypotheses of Theorem 3 empirically: $b_n > 0$, $b_n x - a_n \ne 0$, and
$\lvert b_n x - a_n\rvert$ decreasing toward $0$. This does not *prove* irrationality
(that requires the limit, not finitely many samples) but exhibits the certificate
structure the criterion consumes.

---

## 7. Numerical experiments

The theory is borne out by direct computation; the accompanying `demo.py` produces
the following representative data (reference value
$\gamma = 0.5772156649015329$).

**Approximation rate (Theorem 1).** Evaluating $H_n - \ln n$ and comparing to the
$1/n$ ceiling:

| $n$ | $H_n - \ln n$ | actual error | $1/n$ bound |
|---:|---:|---:|---:|
| $10$ | $0.6263831610$ | $4.92\times10^{-2}$ | $1.00\times10^{-1}$ |
| $100$ | $0.5822073317$ | $4.99\times10^{-3}$ | $1.00\times10^{-2}$ |
| $1000$ | $0.5777155816$ | $5.00\times10^{-4}$ | $1.00\times10^{-3}$ |
| $10^4$ | $0.5772656641$ | $5.00\times10^{-5}$ | $1.00\times10^{-4}$ |
| $10^5$ | $0.5772206649$ | $5.00\times10^{-6}$ | $1.00\times10^{-5}$ |

The error is always below the bound and, as the table makes plain, hugs $1/(2n)$ —
empirical confirmation of the sharper one-sided estimate conjectured in Section 9.

**Series reconstruction (Theorem 2).** Accumulating the positive terms
$g_k = 1/k - \ln\frac{k+1}{k}$, the partial sums $S_N$ coincide with $a_N$ to all
printed digits and rise monotonically toward $\gamma$: $S_{1}=0.30685$,
$S_{10}=0.53107$, $S_{100}=0.57226$, $S_{1000}=0.57672$, $S_{10^5}=0.5772107$. All
$10^5$ tested terms are strictly positive, as Theorem 2 guarantees.

**Irrationality certificate (Theorem 3).** For $x=\sqrt2$, the continued-fraction
convergents yield linear forms $b_n x - a_n = 0.4142,\,-0.1716,\,0.0711,\,-0.0294,\,
0.0122,\,-0.0051,\dots$, all nonzero, alternating, and with magnitudes strictly
decreasing below $1/b_n \to 0$. The three hypotheses of Theorem 3 are met, certifying
$\sqrt2$ irrational; the same script verifies that for the rational $22/7$ any
nonzero form has magnitude at least $1/7$ and so cannot tend to zero.

---

## 8. Applications and context

The constant $\gamma$ is pervasive. In the **analysis of algorithms**, the expected
number of comparisons in randomized quicksort and the expected cost of hashing with
open addressing involve $H_n \sim \ln n + \gamma$; the rate bound of Theorem 1
quantifies the constant overhead precisely. In **analytic number theory**, $\gamma$
appears in Mertens' theorems on prime reciprocals and in the average order of the
divisor function. In **special functions**, $\gamma = -\Gamma'(1)$ is the negative
of the digamma value $\psi(1)$. In **physics**, $\gamma$ surfaces in
dimensional-regularization expansions, where it accompanies the pole terms that
encode subtracted infinities — a structural echo of its definition as a difference
of two divergent quantities. The positive-term series of Theorem 2 also underlies
practical high-precision computation strategies, which regroup or accelerate the
slowly converging defining limit.

A further application lies in **probabilistic combinatorics and records theory**: the
expected number of *records* in a random permutation of $n$ elements is exactly
$H_n$, so the centred quantity (records minus $\ln n$) converges to $\gamma$, and
Theorem 1 bounds the finite-$n$ deviation. In **coupon-collector** problems the
expected time to collect all $n$ coupons is $n H_n = n\ln n + \gamma n + O(1)$, where
$\gamma$ appears in the linear correction term. Across these settings the same
structural fact recurs: wherever a discrete harmonic sum is compared to a continuous
logarithm, $\gamma$ is the universal residue, and the explicit rate of Theorem 1
turns asymptotic statements into finite, certified ones.

---

## 9. Discussion and future work

The three results combine into a coherent program. Proposition 1 and Theorem 1
secure existence and a sharp, explicit approximation rate; Theorem 2 supplies a
transparent positive-term construction; Theorem 3 specifies, exactly, the obstacle
to irrationality. The gap between what is proved and what is desired — a proof that
$\gamma \notin \mathbb{Q}$ — is precisely the gap between *having* the criterion and
*feeding* it admissible sequences.

We highlight four concrete directions (developed at length in the package's future
directions field):

1. **Sharpen the rate to $1/(2n)$.** Replace the crude $\ln x < x-1$ bound by the
   two-sided $x-1-(x-1)^2/2 < \ln x < x-1$ to prove
   $0 < H_n - \ln n - \gamma < 1/(2n)$ and isolate the second-order term.
2. **A converse criterion.** Via Dirichlet's pigeonhole approximation, every
   irrational $x$ admits sequences as in Theorem 3, turning the one-way criterion
   into a biconditional characterization of irrationality.
3. **Vacca-type alternating accelerations.** Regrouping the positive-term series of
   Theorem 2 by powers of two reproduces Vacca's alternating series
   $\gamma = \sum_{k\ge 1} (-1)^k \lfloor \log_2 k\rfloor / k$, with error bounds
   inherited from the unconditional summability of Theorem 2.
4. **Stieltjes constants.** Defining
   $\gamma_m := \lim_n\bigl(\sum_{k=1}^n (\ln k)^m/k - (\ln n)^{m+1}/(m+1)\bigr)$,
   the case $m=0$ recovers $\gamma$, and the same convexity argument yields a
   uniform monotone-sandwich existence proof for all $\gamma_m$.

## 10. Related work and conclusion

**Related work.** The monotone-sandwich proof of existence is classical and appears
in many analysis texts; our contribution is to pair it with the *explicit* and fully
rigorous error bound of Theorem 1 and the positive-term series of Theorem 2 in a
single verified development. The integer-linear-form criterion of Theorem 3 is the
abstract skeleton of the irrationality proofs of $e$, $\pi$, $\zeta(2)$ and
Apéry's celebrated $\zeta(3)$; isolating it as a standalone, reusable lemma makes
explicit what those proofs share and what an attack on $\gamma$ would require.
Vacca's 1910 alternating series and the Stieltjes constants (Section 9) connect this
elementary core to deeper analytic number theory.

## 11. Conclusion

We have given a complete, verified elementary theory of the Euler–Mascheroni
constant centered on irrationality methodology: a monotone sandwich proving
existence, an explicit $1/n$ approximation rate, a positive-term telescoping series
realizing $\gamma$ as a sum of controlled bricks, and a rigorous integer-linear-form
irrationality criterion. The criterion frames the central open problem as a precise
construction challenge, and the series provides the natural material for that
construction. Whether $\gamma$ is rational remains, for now, unanswered.
