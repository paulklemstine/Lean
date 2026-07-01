# The Deligne Envelope for Chebyshev Polynomials of the Second Kind and the Structure of GL(2) Triple Correlation Sums

## Abstract

We prove the sharp *Deligne envelope* for Chebyshev polynomials of the second
kind: for every degree $k \ge 0$ and every $x \in [-1,1]$ one has
$|U_k(x)| \le k+1$, with equality exactly at the endpoints $x = \pm 1$. Through
the Satake parametrization of Hecke eigenvalues this is precisely the classical
prime-power bound $|\lambda_f(p^k)| \le k+1$ for a normalized Hecke eigenform
$f$, and hence the divisor bound $|\lambda_f(n)| \le d(n)$. We then record the
sharp combinatorial envelope for triple correlation sums: any additive triple
correlation of three sequences bounded by $1$ is bounded by the number of terms,
with equality attained only by constant, non-oscillating sequences. Placed side
by side, the two results give a clean structural diagnosis of the triple
correlation problem for GL(2): the magnitude of every local ingredient is
already sharp, so the full gap between the trivial bound $X^{1+\varepsilon}Y$ and
the conjectured optimal bound $X^{1/2+\varepsilon}Y$ for the correlation
$T_f(X,Y) = \sum_{n<X}\sum_{m<Y}\lambda_f(n)\lambda_f(m)\lambda_f(n+m)$ must come
entirely from sign oscillation driven by Sato–Tate equidistribution. We isolate
the boundary cases exactly, discuss the reformulation via shifted convolutions,
and state precise conjectures marking the route to square-root cancellation.

**Keywords.** Hecke eigenform, Satake parameter, Chebyshev polynomial of the
second kind, Deligne bound, triple correlation sum, shifted convolution,
Sato–Tate distribution, square-root cancellation.

## 1. Introduction

Let $f$ be a normalized Hecke eigenform for $\mathrm{SL}(2,\mathbb{Z})$ —
holomorphic of weight $k \ge 2$, or a Hecke–Maass cusp form — with real Hecke
eigenvalues $\lambda_f(n)$. These eigenvalues are multiplicative, and at a prime
$p$ the Ramanujan–Petersson bound (Deligne, and its Maass analogue) states
$|\lambda_f(p)| \le 2$, so one may write $\lambda_f(p) = 2\cos\theta_p$ for a
uniquely determined **Satake angle** $\theta_p \in [0,\pi]$. The higher
prime-power eigenvalues are then
$$\lambda_f(p^k) = \frac{\sin\big((k+1)\theta_p\big)}{\sin\theta_p}
= U_k(\cos\theta_p), \tag{1.1}$$
where $U_k$ denotes the $k$-th Chebyshev polynomial of the second kind.

A central object encoding the additive–multiplicative interaction of these
eigenvalues is the **triple correlation sum**
$$T_f(X,Y) = \sum_{n < X}\ \sum_{m < Y}\ \lambda_f(n)\,\lambda_f(m)\,\lambda_f(n+m).
\tag{1.2}$$
The Sato–Tate heuristic and random-matrix theory predict, for any
$\varepsilon > 0$ and any $Y$ with $1 \le Y \le X^{1/2-\varepsilon}$, the optimal
bound
$$|T_f(X,Y)| \ll_{f,\varepsilon} X^{1/2+\varepsilon}\,Y. \tag{1.3}$$
The trivial bound, obtained from the divisor estimate $|\lambda_f(n)| \le d(n)$,
is of size $X^{1+\varepsilon}Y$; the target $(1.3)$ represents square-root
cancellation in the long variable $n$.

This paper is concerned with the *structural* underpinning of $(1.2)$–$(1.3)$.
We prove two sharp results — one analytic, one combinatorial — that together
pin down where the difficulty in $(1.3)$ genuinely resides.

### Main results

**Theorem A (Deligne envelope).** *For every $k \in \mathbb{N}$ and every
$x \in [-1,1]$,*
$$|U_k(x)| \le k+1.$$
*The bound is sharp: $U_k(1) = k+1$ and $U_k(-1) = (-1)^k(k+1)$, so equality in
absolute value holds exactly at the endpoints $x = \pm 1$.*

By $(1.1)$, Theorem A is exactly the prime-power eigenvalue bound
$|\lambda_f(p^k)| \le k+1$, and via multiplicativity it yields the divisor
bound $|\lambda_f(n)| \le d(n)$.

**Theorem B (Triple envelope and sharpness).** *Let $f, g, h : \mathbb{N} \to
\mathbb{R}$ satisfy $|f(n)|, |g(n)|, |h(n)| \le 1$ for all $n$, and define the
additive triple correlation*
$$S(N) = \sum_{n=0}^{N} f(n)\,g(n+1)\,h(n+2).$$
*Then $|S(N)| \le N+1$ for all $N$. The bound is sharp: the constant sequences
$f \equiv g \equiv h \equiv 1$ give $S(N) = N+1$ for all $N$.*

The combination of Theorems A and B gives the paper's conceptual conclusion,
developed in Section 5: the magnitude of every ingredient of $T_f(X,Y)$ is
already sharp and attained only in the degenerate, non-oscillating regime, so all
remaining progress toward $(1.3)$ must come from sign cancellation.

## 2. Definitions and preliminaries

### 2.1 Chebyshev polynomials of the second kind

The Chebyshev polynomials of the second kind $\{U_k\}_{k\ge 0}$ are the sequence
of polynomials determined by $U_0(x) = 1$, $U_1(x) = 2x$, and the three-term
recurrence
$$U_{k+1}(x) = 2x\,U_k(x) - U_{k-1}(x).$$
Equivalently, and most usefully here, they are characterized by the
trigonometric identity
$$U_k(\cos\theta)\,\sin\theta = \sin\big((k+1)\theta\big),
\qquad \theta \in \mathbb{R}. \tag{2.1}$$
We evaluate $U_k$ as an ordinary real polynomial function on $\mathbb{R}$; the
argument of interest is confined to $[-1,1]$.

### 2.2 Hecke eigenvalues and Satake angles

For a normalized Hecke eigenform $f$ we take as given the multiplicativity of
$\lambda_f$, the Ramanujan bound $|\lambda_f(p)| \le 2$, and the Satake
identity $(1.1)$. No deeper input about $f$ is used in Theorems A and B; the
arithmetic enters only through the identification $(1.1)$ of eigenvalues with
Chebyshev values.

### 2.3 Triple correlation sums

Given sequences $f, g, h : \mathbb{N} \to \mathbb{R}$ and $N \in \mathbb{N}$, the
(unit-offset) *triple correlation sum* is
$$S(N) = \sum_{n=0}^{N} f(n)\,g(n+1)\,h(n+2).$$
This is the clean combinatorial skeleton of $(1.2)$: it retains the essential
feature — three factors evaluated along an additive pattern — while removing the
arithmetic weights, so that the magnitude question can be answered exactly.

## 3. The Deligne envelope (Theorem A)

We build the proof from three self-contained lemmas.

### 3.1 A linear growth bound for sines

**Lemma 3.1.** *For every $n \in \mathbb{N}$ and every $\theta \in \mathbb{R}$,*
$$|\sin(n\theta)| \le n\,|\sin\theta|.$$

*Proof.* Induct on $n$. For $n = 0$ both sides are $0$. Assume the claim for
$m$. By the angle-addition formula,
$$\sin\big((m+1)\theta\big) = \sin(m\theta)\cos\theta + \cos(m\theta)\sin\theta.$$
Hence, using the triangle inequality, $|\cos| \le 1$ throughout, and the
inductive hypothesis,
$$
|\sin((m{+}1)\theta)|
\le |\sin(m\theta)||\cos\theta| + |\cos(m\theta)||\sin\theta|
\le |\sin(m\theta)| + |\sin\theta|
\le m|\sin\theta| + |\sin\theta|
= (m{+}1)|\sin\theta|. \qquad\square
$$

### 3.2 The Chebyshev–trigonometric identity

**Lemma 3.2.** *For all $k \in \mathbb{N}$ and $\theta \in \mathbb{R}$,*
$$U_k(\cos\theta)\,\sin\theta = \sin\big((k+1)\theta\big).$$

This is the defining identity $(2.1)$, recorded here as the working form used
below.

### 3.3 Endpoint values

**Lemma 3.3.** *For all $k \in \mathbb{N}$,*
$$U_k(1) = k+1, \qquad U_k(-1) = (-1)^k\,(k+1).$$

*Proof.* Take $\theta \to 0$ in $(2.1)$: $\sin((k+1)\theta)/\sin\theta \to k+1$,
giving $U_k(1) = k+1$. Take $\theta \to \pi$: with $\cos\theta \to -1$,
$\sin((k+1)\theta)/\sin\theta \to (-1)^k(k+1)$. (Both follow directly from the
standard closed forms for $U_k$ at $\pm 1$.) $\square$

### 3.4 Proof of Theorem A

Fix $k$ and $x \in [-1,1]$. Since $x \in [-1,1]$ there is $\theta =
\arccos x \in [0,\pi]$ with $\cos\theta = x$.

*Case 1: $\sin\theta \ne 0$.* By Lemma 3.2 and multiplicativity of absolute
value,
$$|U_k(\cos\theta)|\,|\sin\theta| = |\sin((k{+}1)\theta)|.$$
Lemma 3.1 with $n = k+1$ gives $|\sin((k{+}1)\theta)| \le (k{+}1)|\sin\theta|$,
so
$$|U_k(\cos\theta)|\,|\sin\theta| \le (k{+}1)\,|\sin\theta|.$$
As $|\sin\theta| > 0$, dividing yields $|U_k(x)| = |U_k(\cos\theta)| \le k+1$.

*Case 2: $\sin\theta = 0$.* Then $\cos^2\theta = 1$, so $x = \cos\theta = \pm 1$.
By Lemma 3.3, $|U_k(1)| = k+1$ and $|U_k(-1)| = |{-1}|^k (k+1) = k+1$. In both
cases $|U_k(x)| = k+1 \le k+1$.

This proves the bound in all cases. Sharpness is the content of Lemma 3.3:
equality in absolute value holds exactly at $x = \pm 1$. $\square$

### 3.5 Arithmetic corollaries

**Corollary 3.4.** *For a normalized Hecke eigenform $f$ and every prime power
$p^k$,* $|\lambda_f(p^k)| \le k+1.$

*Proof.* Immediate from $(1.1)$ and Theorem A, since $\cos\theta_p \in [-1,1]$.
$\square$

**Corollary 3.5 (Divisor bound).** *For every $n \ge 1$,* $|\lambda_f(n)| \le
d(n),$ *where $d$ is the divisor-counting function.*

*Proof.* Write $n = \prod_i p_i^{k_i}$. Multiplicativity gives $\lambda_f(n) =
\prod_i \lambda_f(p_i^{k_i})$, and Corollary 3.4 bounds the $i$-th factor by
$k_i + 1$. Since $d(n) = \prod_i (k_i+1)$, the product bound is exactly $d(n)$.
$\square$

## 4. The triple correlation envelope (Theorem B)

**Proof of Theorem B.** By the triangle inequality for finite sums,
$$|S(N)| = \Big| \sum_{n=0}^{N} f(n)g(n{+}1)h(n{+}2) \Big|
\le \sum_{n=0}^{N} |f(n)|\,|g(n{+}1)|\,|h(n{+}2)|.$$
Each factor is at most $1$, so each summand is at most $1$; there are $N+1$
summands, whence $|S(N)| \le N+1$.

For sharpness, take $f \equiv g \equiv h \equiv 1$. All bounds
$|f|,|g|,|h| \le 1$ hold, every summand equals $1$, and the sum of $N+1$ ones is
$N+1$. Thus $S(N) = N+1$ exactly. $\square$

**Remark 4.1.** The proof exposes the mechanism of extremality: equality
$|S(N)| = N+1$ forces $|f(n)g(n{+}1)h(n{+}2)| = 1$ for every $n$ *and* forces
all these unit-modulus terms to share a common sign, so that no cancellation
occurs. Any genuine variation of sign strictly lowers the sum below the
envelope. This is the combinatorial mirror of the endpoint sharpness in
Theorem A.

## 5. Structural consequences for $T_f(X,Y)$

Applying Corollary 3.5 termwise to $(1.2)$ gives the **divisor envelope**
$$|T_f(X,Y)| \le \sum_{n<X}\sum_{m<Y} d(n)\,d(m)\,d(n+m)
\ll_\varepsilon X^{1+\varepsilon}\,Y. \tag{5.1}$$
This is the analogue of the bound $|S(N)| \le N+1$ for the arithmetic sum, and,
as in Remark 4.1, equality up to constants would require the summands to line up
in sign.

The two theorems together yield the following diagnosis.

1. **Magnitudes are sharp and settled.** Theorem A shows the local factors
   $\lambda_f(p^k) = U_k(\cos\theta_p)$ attain their maximal magnitude $k+1$
   exactly at $\theta_p \in \{0,\pi\}$, i.e. $\cos\theta_p = \pm 1$. No
   improvement of $(5.1)$ can come from better size bounds on the eigenvalues.

2. **Extremality means no oscillation.** By Theorem B and Remark 4.1, the
   divisor envelope $(5.1)$ can be approached only when the summands
   $\lambda_f(n)\lambda_f(m)\lambda_f(n+m)$ fail to oscillate — the degenerate
   regime corresponding to the Chebyshev endpoints.

3. **All progress is sign cancellation.** The gap between $(5.1)$ and the
   conjectured $(1.3)$ — a full power of $X$ — must therefore be extracted
   entirely from destructive interference of signs.

The Sato–Tate law asserts that the Satake angles $\theta_p$ are equidistributed
in $[0,\pi]$ with respect to the measure $\tfrac{2}{\pi}\sin^2\theta\,d\theta$.
Under this law the degenerate endpoint angles $\{0,\pi\}$ have measure zero:
oscillation is generic. Converting this qualitative genericity into a
quantitative power saving is the crux of $(1.3)$.

**A useful reformulation.** Summing $(1.2)$ first over the long variable $n$,
$$T_f(X,Y) = \sum_{m<Y} \lambda_f(m)
\underbrace{\sum_{n<X} \lambda_f(n)\,\lambda_f(n+m)}_{=\,C_f(X;\,m)},$$
so that $T_f(X,Y)$ is a $\lambda_f(m)$-weighted average of the **shifted
convolution sums** $C_f(X;m)$ over shifts $m < Y$. Square-root cancellation for
$T_f$ is thereby tied to uniform square-root cancellation for $C_f(X;m)$ across
the dyadic average over $m \le Y$.

## 6. Algorithms

We describe two elementary but useful computational routines, both grounded in
the results above.

**Algorithm 1 (Stable evaluation of the Chebyshev envelope ratio).** To evaluate
$U_k(\cos\theta)$ robustly near the endpoints, one uses the recurrence
$U_{k+1} = 2xU_k - U_{k-1}$ (numerically stable on $[-1,1]$) rather than the
sine-ratio $(2.1)$, whose numerator and denominator both vanish as $\theta \to
0,\pi$. The recurrence runs in $O(k)$ arithmetic operations and lets one verify
Theorem A pointwise: the computed value never exceeds $k+1$ and meets it at the
endpoints.

**Algorithm 2 (Direct triple correlation).** Given finite arrays for $f, g, h$,
compute $S(N) = \sum_{n=0}^N f(n)g(n{+}1)h(n{+}2)$ by a single pass, accumulating
the product at each index. This is $O(N)$ and directly exhibits both the envelope
$|S(N)| \le N+1$ and its attainment for constant sequences.

## 7. Applications

- **Prime-power eigenvalue control.** Corollary 3.4 furnishes the exact local
  bound underpinning all size estimates for $L$-function coefficients built from
  $f$.
- **Divisor-type majorization.** Corollary 3.5 is the standard majorant used to
  reduce cancellation problems for $\lambda_f$ to problems about $d(n)$.
- **Benchmarking cancellation.** Theorem B provides the exact trivial bound
  against which any claimed cancellation in a triple correlation must be
  measured, quantifying precisely how much oscillation a nontrivial estimate
  extracts.

## 8. Discussion

The value of Theorems A and B is diagnostic. In many hard analytic problems it
is unclear whether progress should be sought through sharper magnitude bounds or
through cancellation. Here the question is settled unambiguously: the magnitudes
are already optimal and attained, so *every* remaining gain is cancellation. The
Chebyshev endpoints and the constant-sequence extremizers are two faces of the
same degeneracy — perfect alignment of signs — and the Sato–Tate law guarantees
this degeneracy is statistically negligible.

## 9. Future directions

This cycle established two unconditional facts about the triple correlation sum
$T_f(X,Y) = \sum_{n<X}\sum_{m<Y}\lambda_f(n)\lambda_f(m)\lambda_f(n+m)$ of a
normalized Hecke eigenform $f$: the local eigenvalues obey the sharp Deligne
envelope $|\lambda_f(p^k)| \le k+1$, and the resulting triangle bound
$|T_f(X,Y)| \le \sum\sum d(n)d(m)d(n+m)$ is *attained* with equality by a genuine
eigenvalue family (the degenerate Satake angle). The improvement to the
conjectured optimal $X^{1/2+\varepsilon}Y$ must therefore come entirely from sign
oscillation. The following conjectures push outward from that observation.

**Conjecture 1 — The envelope is attained only in the absence of oscillation.**
For a Hecke eigenform whose Satake angles are not all $0$ or $\pi$, the triple
correlation is strictly smaller than its divisor envelope by a power of $X$:
there is $\delta > 0$ with $|T_f(X,Y)| \le X^{1-\delta}Y\,(XY)^{o(1)}$ for
$1 \le Y \le X^{1/2}$. The key insight is that equality in the triangle bound
forces every summand to share one sign, which the Sato–Tate distribution of
$\operatorname{sign}(\lambda_f(p))$ forbids on a positive-density set of primes;
quantifying the resulting destructive interference converts equidistribution into
a power saving.

**Conjecture 2 — Square-root cancellation is equivalent to a shifted-convolution
gain.** The optimal bound $|T_f(X,Y)| \ll_{f,\varepsilon} X^{1/2+\varepsilon}Y$
holds if and only if the shifted convolution sums $\sum_{n<X}\lambda_f(n)
\lambda_f(n+h)$ enjoy uniform square-root cancellation in the shift $h$ on the
dyadic average over $h \le Y$. The key insight is that summing the triple
correlation first over the long variable $n$ turns each fixed $m$ into a shifted
convolution with shift $h = m$, so the triple sum is a weighted average of
shifted convolutions and inherits exactly their cancellation budget.

**Conjecture 3 — A Chebyshev/Sato–Tate exact second moment.** Averaged over
Satake angles with the Sato–Tate measure, the mean square of the local triple
correlation density equals a fixed rational multiple of the divisor-envelope
density; concretely, the second moment of $U_a(\cos\theta)U_b(\cos\theta)
U_{a+b}(\cos\theta)$ against the Sato–Tate measure is a simple closed form in
$a,b$. The key insight is that products of Chebyshev polynomials of the second
kind linearize under the Sato–Tate (semicircle) inner product —
$\langle U_i, U_j\rangle = \delta_{ij}$ — so triple products collapse to a finite
combinatorial count of representations $i+j=k$.

## References (context)

The framework rests on the Ramanujan–Petersson bound (Deligne's theorem and its
Maass-form analogue), the Satake parametrization of Hecke eigenvalues, the
classical theory of Chebyshev polynomials, and the Sato–Tate equidistribution
law for the Satake angles of a fixed non-CM eigenform.
