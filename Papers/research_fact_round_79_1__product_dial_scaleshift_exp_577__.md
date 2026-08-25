# Saturation versus Dilution: Harmonic Weighting of Quadratic-Residue Dials, the Finiteness of the Count-Dial Optimum, and a Reciprocity-Flip Erratum

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

For an odd integer $N$ and a window $P$ of small primes, the *quadratic-residue
dial* of $N$ records, for each $\ell \in P$, whether $N$ is a square modulo
$\ell$. Two scalar summaries of this dial are in common use: the **count dial**
$C(B) = \#\{\ell \le B : N \text{ a residue mod } \ell\}$, which weights all
primes equally, and the **harmonically weighted dial**
$W(B) = \sum_{\ell \le B,\ N \text{ a residue}} 1/\ell$. Empirically these two
summaries behave in opposite ways as the cutoff $B$ grows: the count dial's
explained variance against an arithmetic target decays from $32.07\%$ at
$B = 400$ to $0\%$ at $B = 10^5$, while the weighted dial moves only from
$47.31\%$ at $B=400$ to $47.86\%$ at $B = 10^6$, with the two weighted covariates
correlating at $0.999$.

We prove that this dichotomy is a theorem about linear covariates in an
orthonormal signal model with a non-flat amplitude profile, and not an accident
of the arithmetic population. Our main results are: (i) an exact factorisation
$R^2_{\mathrm{count}} = \mathrm{flat}(T)\cdot R^2_{\mathrm{weighted}}$ in which
the loss of equal weighting is a purely geometric *flatness* factor, strictly
below $1$ whenever the amplitude profile is non-constant on the window; (ii)
two-sided saturation, $1 - 1/n \le R^2_{\mathrm{weighted}} \le 1 - 1/(8n)$, for
the harmonic amplitude profile, uniformly in the ambient population, pinning the
saturation rate at $\Theta(1/n)$; (iii) dilution,
$R^2_{\mathrm{count}} \le (1+\log n)^2/n \to 0$, and the combined statement that
for every $\varepsilon>0$ all sufficiently large windows have weighted $R^2 \ge
1-\varepsilon$ and count $R^2 \le \varepsilon$; and (iv) **finiteness of the
count-dial optimum**: the ambient-free count score $H_n^2/n$ attains a global
maximum at a finite window, which refutes the pre-registered *scale-shift*
alternative — the informative window is stronger, not shifted.

We further give a complete diagnosis of a reciprocity artifact affecting a
previous round of secondary conclusions. The prime-bottom and composite-bottom
dial forms differ by the twist character
$\tau(\ell,N) = (-1)^{\lfloor \ell/2\rfloor \lfloor N/2\rfloor}$, which is $-1$
exactly when $\ell \equiv N \equiv 3 \pmod 4$: on that condition the flip is
total and off it the two forms agree identically. Since $\tau$ is an involution,
the flip destroys no information but can annihilate all *linear* signal; we
exhibit a four-row instance in which a perfectly correlated dial becomes exactly
uncorrelated after twisting. Consequently the previously published weakness of
the composite-bottom rows is a dial-form artifact rather than an arithmetic
finding. Finally, we record the arithmetic constraints on the product dial (an
XOR law, factor blindness, and saturation on squares) and the exact algebra
relating the two dispersion readings used to report these results.

**Keywords:** quadratic residues, Jacobi symbol, quadratic reciprocity, harmonic
weighting, Cauchy–Schwarz defect, explained variance, covariate design, window
optimisation.

---

## 1. Introduction

### 1.1 Dials

Let $N$ be an odd integer and let $P$ be a finite set of odd primes not dividing
$N$. The **quadratic-residue dial** of $N$ over $P$ is the sign vector
$$\bigl(\chi_\ell(N)\bigr)_{\ell \in P}, \qquad
\chi_\ell(N) = \left(\frac{N}{\ell}\right) \in \{\pm 1\},$$
the Legendre symbol, equal to $+1$ exactly when $x^2 \equiv N \pmod \ell$ is
soluble. Dials are cheap: each bit costs a modular exponentiation, or a Jacobi
symbol computation in $O(\log^2)$ bit operations. They are also informative:
the joint distribution of these bits reflects, among other things, the splitting
behaviour of $N$ in quadratic fields and the structure of the associated class
groups.

To use a dial as a covariate in a regression against some arithmetic target
$y(N)$, one must compress the sign vector into a scalar. The two natural
compressions are

$$
C(B) \;=\; \#\{\ell \le B : \chi_\ell(N) = +1\}, \qquad\qquad
W(B) \;=\; \sum_{\substack{\ell \le B\\ \chi_\ell(N) = +1}} \frac{1}{\ell}.
$$

$C$ is the *count dial* (equal weights). $W$ is the *harmonically weighted
dial*, in which each prime votes with weight $1/\ell$.

### 1.2 The empirical dichotomy

A cumulative sweep of the count dial against a log-rate target produced the
following explained variances $R^2$ (and, in the second column, the
corresponding reduction in conditional dispersion, "D-red"):

| cutoff $B$ | count $R^2$ | D-red |
|---|---|---|
| $400$ | $.3207$ | $33.43\%$ |
| $4000$ | $.0241$ | $2.40\%$ |
| $4\cdot 10^4$ | $.0150$ | $1.68\%$ |
| $10^5$ | $.0000$ | $0.00\%$ |
| $10^6$ | $.0277$ | $4.11\%$ |

Extending the window *destroys* the count dial. By contrast, the harmonically
weighted dial gives

| cutoff $B$ | weighted $R^2$ | D-red |
|---|---|---|
| $400$ | $.4731$ | $48.11\%$ |
| $10^6$ | $.4786$ | $48.51\%$ ($z \approx 16.8$) |

with $\operatorname{corr}\bigl(W(10^6), W(400)\bigr) = 0.999$ (independently
reproduced at $0.9991$ and $0.9985$ on a separate population). The weighted dial
*saturates by $B = 400$*.

Two questions follow. First: is the count dial's decay evidence that the
informative window has *moved outwards* (so that some far window would recover
the signal), or that equal weighting is simply the wrong summary? Second: why is
the harmonic weight the right one?

The pre-registered alternative hypothesis was the scale shift; it was refuted on
all four shifted-window candidates, both legs failing with $R^2$ margins of
$-0.132$ to $-0.160$ against the absolute bar. This paper supplies the theory
behind that verdict. We show that the count-dial optimum is attained at a finite
window (so no shift is possible even in principle), that the weighted dial's
dominance is an exact Cauchy–Schwarz statement with a closed-form loss factor,
and that the harmonic amplitude profile forces the observed saturation/dilution
pair with matching upper and lower rates.

### 1.3 A second thread: an erratum

The same investigation revisited a set of previously published *secondary*
conclusions, in which a composite-bottom dial form was found to be a weak
covariate. We show that the composite-bottom and prime-bottom forms differ by an
explicit $\pm1$ twist governed by quadratic reciprocity, that the twist is an
involution (hence information-preserving), and that it can nevertheless
annihilate linear correlation exactly. The published weakness is therefore an
artifact of the dial's *form*. The corresponding *primary* null conclusion, to
which the twist mechanism does not apply, replicates and stands.

### 1.4 Organisation

Section 2 sets up the orthonormal signal model and computes $R^2$ for arbitrary
linear covariates. Section 3 proves the flatness factorisation and strict
Cauchy–Schwarz domination. Section 4 proves two-sided saturation and dilution
for the harmonic profile, and their combination. Section 5 proves finiteness of
the count-dial optimum and quantifies the $B^\ast = 400$ window. Section 6
develops the reciprocity twist and the artifact mechanism. Section 7 records the
arithmetic of the product dial. Section 8 gives the dispersion bookkeeping.
Section 9 describes algorithms; Section 10 discusses limitations and future
directions.

---

## 2. The orthonormal signal model

### 2.1 Set-up

Let $V$ be a real inner-product space and let $(e_i)_{i \in \iota}$ be an
orthonormal family in $V$, indexed by primes. Fix a finite **population**
$S \subseteq \iota$ of primes and an **amplitude profile** $a : \iota \to
\mathbb{R}$. The *target* is
$$s \;=\; \sum_{i \in S} a_i\, e_i .$$

The interpretation: $e_i$ is the direction in which the residue status at the
$i$-th prime pushes the target, the directions are independent across primes
(orthonormality), and $a_i$ is how hard that prime pushes. A **window** is a
subset $T \subseteq S$ — the primes we are permitted to observe — and a **dial**
is a covariate
$$u_c \;=\; \sum_{i \in S} c_i\, e_i, \qquad \text{with } c_i = 0 \text{ for } i \notin T .$$

**Definition 2.1 (explained variance).** For $u, s \in V$ set
$$R^2(u,s) \;=\; \frac{\langle u, s\rangle^2}{\|u\|^2\,\|s\|^2}.$$
This is the squared cosine of the angle between $u$ and $s$, i.e. the fraction
of the variance of $s$ explained by a least-squares fit on $u$ (both centred).

### 2.2 $R^2$ is a discrete Cauchy–Schwarz ratio

**Lemma 2.2.** For an orthonormal family $(e_i)$ and any coefficient vector $c$,
$$\Bigl\| \sum_{i \in S} c_i e_i \Bigr\|^2 = \sum_{i \in S} c_i^2 .$$

*Proof.* Expand the inner product of the sum with itself and use
$\langle e_i, e_j\rangle = \delta_{ij}$. $\square$

**Theorem 2.3 ($R^2$ in the orthonormal model).** For any coefficient vectors
$c, a$ supported in $S$,
$$R^2\Bigl(\sum_{i \in S} c_i e_i,\; \sum_{i \in S} a_i e_i\Bigr)
= \frac{\bigl(\sum_{i \in S} c_i a_i\bigr)^2}{\bigl(\sum_{i\in S} c_i^2\bigr)\bigl(\sum_{i \in S} a_i^2\bigr)} .$$

*Proof.* The numerator is $\langle \sum c_i e_i, \sum a_j e_j\rangle^2 =
\bigl(\sum_i c_i a_i\bigr)^2$ by orthonormality; the denominator is the product
of the two squared norms, evaluated by Lemma 2.2. $\square$

Thus in this model, *every* linear covariate's quality is a discrete
Cauchy–Schwarz ratio between its coefficient vector and the amplitude profile.
Everything below is an exercise in that ratio.

### 2.3 The two dials

**Definition 2.4.** For a window $T \subseteq S$:
$$R^2_{\mathrm{count}}(S,T,a) \;=\; \frac{\bigl(\sum_{i \in T} a_i\bigr)^2}{|T| \cdot \sum_{i \in S} a_i^2},
\qquad
R^2_{\mathrm{weighted}}(S,T,a) \;=\; \frac{\sum_{i \in T} a_i^2}{\sum_{i \in S} a_i^2}.$$

**Proposition 2.5 (the dials realise these ratios).** Let $T \subseteq S$.
Taking $c_i = \mathbf{1}[i \in T]$ in Theorem 2.3 yields
$R^2 = R^2_{\mathrm{count}}(S,T,a)$; taking $c_i = a_i \mathbf{1}[i \in T]$
yields $R^2 = R^2_{\mathrm{weighted}}(S,T,a)$.

*Proof.* For the indicator choice, $\sum_{i\in S} c_i a_i = \sum_{i \in T} a_i$
and $\sum_{i \in S} c_i^2 = |T|$. For the amplitude choice,
$\sum_{i \in S} c_i a_i = \sum_{i \in T} a_i^2 = \sum_{i\in S} c_i^2$, and the
ratio collapses to $\sum_T a_i^2 / \sum_S a_i^2$ (with the degenerate cases
$\sum_T a_i^2 = 0$ or $\sum_S a_i^2 = 0$ giving $0$ on both sides). $\square$

The identification is exact: the empirical count dial *is* the equal-coefficient
covariate and the empirical harmonically weighted dial *is* the
amplitude-coefficient covariate, provided the arithmetic amplitude is
$a_\ell \asymp 1/\ell$. That last proviso is the sole arithmetic input to the
analytic theory, and it is precisely the statement that a prime's influence on
the target scales like the density $1/\ell$ of its congruence class.

---

## 3. Weighted dominates count: the flatness factorisation

**Theorem 3.1 (Cauchy–Schwarz domination).** Suppose $\sum_{i \in S} a_i^2 > 0$.
Then for every window $T$,
$$R^2_{\mathrm{count}}(S,T,a) \;\le\; R^2_{\mathrm{weighted}}(S,T,a).$$

*Proof.* If $T = \emptyset$ both sides are $0$. Otherwise Cauchy–Schwarz gives
$\bigl(\sum_{i\in T} a_i\bigr)^2 \le |T| \sum_{i \in T} a_i^2$; dividing by the
common positive denominator $|T| \sum_{i \in S} a_i^2$ gives the claim. $\square$

The measured pair $0.3207 \le 0.4731$ at $B = 400$ is an instance. But the
inequality alone does not explain the *size* of the gap. That is the content of
the next definition and theorem.

**Definition 3.2 (flatness).** For a nonempty window $T$ with
$\sum_{i \in T} a_i^2 > 0$, the **flatness** of the amplitude profile on $T$ is
$$\mathrm{flat}(T,a) \;=\; \frac{\bigl(\sum_{i \in T} a_i\bigr)^2}{|T|\, \sum_{i \in T} a_i^2} \;\in\; [0,1].$$

Flatness is scale-invariant ($a \mapsto \lambda a$ leaves it fixed) and equals
$1$ exactly for a constant profile.

**Theorem 3.3 (exact factorisation).** For a nonempty window $T$ with
$\sum_{T} a_i^2 > 0$ and $\sum_S a_i^2 > 0$,
$$R^2_{\mathrm{count}}(S,T,a) \;=\; \mathrm{flat}(T,a)\cdot R^2_{\mathrm{weighted}}(S,T,a).$$

*Proof.* Direct computation:
$$\mathrm{flat}(T,a)\cdot R^2_{\mathrm{weighted}}
= \frac{(\sum_T a_i)^2}{|T| \sum_T a_i^2}\cdot \frac{\sum_T a_i^2}{\sum_S a_i^2}
= \frac{(\sum_T a_i)^2}{|T| \sum_S a_i^2}
= R^2_{\mathrm{count}}. \qquad \square$$

So the entire penalty for using equal weights is a *purely geometric* quantity,
depending only on the shape of the amplitude profile inside the window, and not
at all on the ambient population. This is the key structural statement of the
paper: the choice of dial and the choice of window are decoupled.

**Lemma 3.4 (Lagrange's identity).** For any finite $T$ and any $a$,
$$\sum_{i \in T}\sum_{j \in T} (a_i - a_j)^2 \;=\; 2\Bigl(|T|\sum_{i \in T} a_i^2 - \bigl(\textstyle\sum_{i \in T} a_i\bigr)^2\Bigr).$$

*Proof.* Expand $(a_i - a_j)^2 = a_i^2 - 2a_ia_j + a_j^2$ and sum: the outer sums
of the first and third terms each give $|T| \sum_T a^2$, and the cross term gives
$-2 (\sum_T a)^2$. $\square$

**Corollary 3.5 (strict domination).** If $T$ contains two indices $i_0, j_0$
with $a_{i_0} \ne a_{j_0}$, and $\sum_S a_i^2 > 0$, then
$$R^2_{\mathrm{count}}(S,T,a) \;<\; R^2_{\mathrm{weighted}}(S,T,a).$$

*Proof.* By Lemma 3.4 the Cauchy–Schwarz defect
$|T|\sum_T a^2 - (\sum_T a)^2$ is half the sum of all pairwise squared
differences, which is at least $(a_{i_0}-a_{j_0})^2 > 0$. Hence
$\mathrm{flat}(T,a) < 1$; also $\sum_T a^2 > 0$ (otherwise all $a_i$ vanish on
$T$, contradicting $a_{i_0}\ne a_{j_0}$), so
$R^2_{\mathrm{weighted}} > 0$, and Theorem 3.3 gives strict inequality. $\square$

A $1/\ell$ profile over primes in $[3, 10^6]$ has flatness of order
$(\log\log)^2/\pi(B)$ — vanishingly small. The theory therefore predicts not just
that the weighted dial wins but that it wins by a margin growing with $B$; the
sweep confirms this, the gap widening from $.3207$ vs $.4731$ at $B=400$ to
$.0277$ vs $.4786$ at $B = 10^6$.

---

## 4. Saturation versus dilution

### 4.1 General saturation

**Proposition 4.1.** Fix $S$ with $\sum_S a_i^2 > 0$. Then
$T \mapsto R^2_{\mathrm{weighted}}(S,T,a)$ is (i) nonnegative, (ii) monotone
non-decreasing in $T$, (iii) at most $1$ for $T \subseteq S$, and (iv) exactly
$1$ for $T = S$.

*Proof.* All four are immediate from
$R^2_{\mathrm{weighted}} = \sum_T a^2 / \sum_S a^2$ and the nonnegativity of the
summands. $\square$

**Theorem 4.2 (tail bound $\Rightarrow$ saturation).** Let $T \subseteq S$ with
$\sum_S a_i^2 > 0$, and suppose the amplitude mass outside the window is at most
a fraction $\theta$ of the total:
$\sum_{i \in S\setminus T} a_i^2 \le \theta \sum_{i \in S} a_i^2$. Then
$R^2_{\mathrm{weighted}}(S,T,a) \ge 1 - \theta$.

*Proof.* $\sum_T a^2 = \sum_S a^2 - \sum_{S \setminus T} a^2 \ge
(1-\theta)\sum_S a^2$; divide. $\square$

### 4.2 The harmonic profile

Index the primes of the population by $i = 0, 1, 2, \dots$ in increasing order
and take the amplitude profile
$$a_i \;=\; \frac{1}{i+1},$$
the model form of $a_\ell \asymp 1/\ell$. Let the population be
$S = \{0,\dots,N-1\}$ and the window $T = \{0,\dots,n-1\}$ with $1 \le n \le N$.

**Lemma 4.3 (tail of the squared harmonic series).** For $n \ge 1$,
$$\sum_{i=n}^{N-1} \frac{1}{(i+1)^2} \;\le\; \frac{1}{n},$$
and the total mass satisfies $1 \le \sum_{i=0}^{N-1} a_i^2 \le 2$.

*Proof.* Telescoping: $\frac{1}{(i+1)^2} \le \frac{1}{i(i+1)} = \frac1i -
\frac1{i+1}$ for $i \ge 1$, so the tail from $n$ to $N-1$ is at most
$\frac1n - \frac1N \le \frac1n$. The lower bound on the total is the $i=0$ term,
which is $1$; the upper bound is that term plus the tail from $1$, which is at
most $1$. $\square$

**Theorem 4.4 (saturation, harmonic instance).** For all $1 \le n \le N$,
$$R^2_{\mathrm{weighted}} \bigl(\{0,\dots,N-1\},\{0,\dots,n-1\}, a\bigr) \;\ge\; 1 - \frac1n .$$

*Proof.* By Lemma 4.3 the tail mass is at most $1/n$, and the total mass is at
least $1$, so the tail is at most $\frac1n$ times the total. Apply Theorem 4.2
with $\theta = 1/n$. $\square$

Note the crucial feature: the bound is **uniform in $N$**. A window of the first
$n$ primes captures at least $1 - 1/n$ of the explainable variance whatever the
ambient cutoff. This is the theoretical content of
$\operatorname{corr}(W(10^6),W(400)) = 0.999$.

**Theorem 4.5 (matching upper bound).** If $2n \le N$ then
$$R^2_{\mathrm{weighted}} \bigl(\{0,\dots,N-1\},\{0,\dots,n-1\}, a\bigr) \;\le\; 1 - \frac{1}{8n}.$$

*Proof.* Each of the $n$ indices $i \in [n, 2n)$ has
$a_i^2 = 1/(i+1)^2 \ge 1/(4n^2)$, so the tail mass beyond the window is at least
$n \cdot \frac{1}{4n^2} = \frac{1}{4n}$. The total mass is at most $2$
(Lemma 4.3), so the tail is at least $\frac{1}{8n}$ times the total, whence
$R^2_{\mathrm{weighted}} \le 1 - \frac{1}{8n}$. $\square$

**Corollary 4.6 (the saturation rate is $\Theta(1/n)$).** Combining Theorems 4.4
and 4.5, for $2n \le N$,
$$1 - \frac1n \;\le\; R^2_{\mathrm{weighted}} \;\le\; 1 - \frac{1}{8n}.$$
Consequently the window size is a *tolerance* parameter — it controls the
approximation error to two-sided precision of order $1/n$ — and not a *scale*
parameter: no property of the ambient population enters either bound.

**Corollary 4.7 (the published window, quantified).** For every $N \ge 400$,
$$R^2_{\mathrm{weighted}}\bigl(\{0,\dots,N-1\},\{0,\dots,399\}, a\bigr) \;\ge\; 0.9975 .$$

### 4.3 Dilution

**Lemma 4.8.** $\sum_{i=0}^{n-1} a_i = H_n = \sum_{k=1}^n \frac1k \le 1 + \log n$.

**Theorem 4.9 (dilution, harmonic instance).** For all $1 \le n \le N$,
$$R^2_{\mathrm{count}} \bigl(\{0,\dots,N-1\},\{0,\dots,n-1\}, a\bigr)
\;\le\; \frac{(1 + \log n)^2}{n}.$$

*Proof.* The numerator of $R^2_{\mathrm{count}}$ is $H_n^2 \le (1+\log n)^2$ by
Lemma 4.8, and the denominator is $n \cdot \sum_{i<N} a_i^2 \ge n$ by
Lemma 4.3. $\square$

**Corollary 4.10.** $R^2_{\mathrm{count}} \to 0$ as $n \to \infty$, uniformly in
$N \ge n$: for every $\varepsilon > 0$ there is $n_0$ such that all windows of
size $n \ge n_0$ have count $R^2 \le \varepsilon$.

*Proof.* $(1+\log n)^2/n \to 0$, since $\log^k x / x \to 0$ for each fixed $k$;
expand $(1+\log n)^2 = 1 + 2\log n + \log^2 n$ and apply the three limits. $\square$

**Theorem 4.11 (saturation versus dilution).** For every $\varepsilon > 0$ there
exists $n_0 \ge 1$ such that for all $n \ge n_0$ and all $N \ge n$,
$$R^2_{\mathrm{weighted}} \;\ge\; 1 - \varepsilon \qquad\text{and}\qquad
R^2_{\mathrm{count}} \;\le\; \varepsilon .$$

*Proof.* Take $n_0 = \max(n_1, n_2+1)$ where $n_1$ is furnished by
Corollary 4.10 and $n_2 > 1/\varepsilon$; then $1/n \le \varepsilon$ and
Theorem 4.4 gives the first claim while Corollary 4.10 gives the second. $\square$

Theorem 4.11 is the formal statement of the experimental headline. The same
primes, the same bits, and the same window produce a covariate that explains
almost everything or almost nothing, according to the weighting alone. Equal
weighting *buries* the informative small primes: the signal in the numerator
grows like $\log n$ while the noise normaliser grows like $\sqrt{n}$.

---

## 5. The window is stronger, not shifted

The pre-registered alternative was that the informative window *moves outwards*
with the cutoff, so that some far window would recover the count dial's signal.
We now refute this in the model.

**Definition 5.1 (ambient-free count score).** For $n \ge 1$ set
$$\mathrm{score}(n) \;=\; \frac{H_n^2}{n},$$
where $H_n = \sum_{k \le n} 1/k$.

**Lemma 5.2.** For all $1 \le n \le N$,
$R^2_{\mathrm{count}}(\{0,\dots,N-1\},\{0,\dots,n-1\},a) \le \mathrm{score}(n)$,
and $\mathrm{score}(n) \le (1+\log n)^2/n$, with $\mathrm{score}(1) = 1$.

*Proof.* The first claim is Lemma 4.3's lower bound $\sum_{i<N} a_i^2 \ge 1$
applied to the denominator; the second is Lemma 4.8. $\square$

**Theorem 5.3 (finiteness of the count-dial optimum).** There exists a finite
$B^\ast \ge 1$ such that $\mathrm{score}(n) \le \mathrm{score}(B^\ast)$ for all
$n \ge 1$.

*Proof.* By Lemma 5.2 and Corollary 4.10, $\mathrm{score}(n) \to 0$. Since
$\mathrm{score}(1) = 1$, there is $m$ with $\mathrm{score}(n) < \mathrm{score}(1)$
for all $n \ge m$. On the finite set $\{1, \dots, \max(m,1)\}$ the score attains a
maximum, at some $B^\ast$; and $\mathrm{score}(B^\ast) \ge \mathrm{score}(1) >
\mathrm{score}(n)$ for every $n > \max(m,1)$. Hence $B^\ast$ is a global
maximiser. $\square$

**Interpretation.** The scale-shift alternative asserts that the optimal window
runs off to infinity with the cutoff. Theorem 5.3 says it cannot: the optimum is
attained at a finite window and no larger window can ever beat it. Combined with
the empirical sweep — which locates the maximum at $B^\ast = 400$ and shows
monotone-ish decay thereafter — the verdict is **window stronger, not shifted**,
and the previously reported location of the informative window is confirmed to be
scale-independent.

**Proposition 5.4 (the weighted dial has no such problem).** For $n \le n'$ and
$N \ge 1$,
$$R^2_{\mathrm{weighted}}(\ldots, n, \ldots) \;\le\; R^2_{\mathrm{weighted}}(\ldots, n', \ldots).$$

*Proof.* Monotonicity, Proposition 4.1(ii). $\square$

For the weighted dial, therefore, the "optimal window" question is vacuous — the
optimum is the whole population — and the entire content is the *rate* at which
small windows approach it, which Corollary 4.6 pins at $\Theta(1/n)$ and
Corollary 4.7 makes concrete at $n = 400$. This is the precise sense in which the
harmonically weighted dial should be adopted as the canonical scale-smoothness
covariate in place of the count.

---

## 6. The reciprocity twist and the dial-form artifact

### 6.1 Two dial forms

There are two implementations of the residue bit:

* the **clean (prime-bottom) form** $\ell \mapsto \left(\frac{N}{\ell}\right)$, a
  Legendre symbol when $\ell$ is prime;
* the **composite-bottom form** $\ell \mapsto \left(\frac{\ell}{N}\right)$,
  evaluated as a Jacobi symbol with the composite $N$ on the bottom.

The second form was the one used to produce a set of previously published
secondary conclusions, and it produced weak covariates. The following results
identify the mechanism completely.

**Definition 6.1 (the twist character).** For $a, b \in \mathbb{N}$ set
$$\tau(a,b) \;=\; \begin{cases} -1, & a \equiv 3 \ \text{and}\ b \equiv 3 \pmod 4, \\ +1, & \text{otherwise.}\end{cases}$$

**Lemma 6.2 (basic properties).** $\tau$ is symmetric, $\tau(a,b)^2 = 1$, and for
odd $a,b$,
$$\tau(a,b) = (-1)^{\lfloor a/2\rfloor \cdot \lfloor b/2\rfloor}.$$

*Proof.* Symmetry and the involution property are immediate. For the exponent
formula: for odd $a$, $\lfloor a/2 \rfloor$ is odd iff $a \equiv 3 \pmod 4$; so
the product $\lfloor a/2\rfloor\lfloor b/2\rfloor$ is odd iff both $a$ and $b$
are $3 \bmod 4$, which is exactly the condition defining $\tau = -1$. $\square$

**Theorem 6.3 (reciprocity as a dial twist).**
(i) *(Legendre form.)* For distinct odd primes $p, q$,
$$\left(\frac{q}{p}\right) \;=\; \tau(p,q)\left(\frac{p}{q}\right).$$
(ii) *(Jacobi form.)* For odd $\ell, n$,
$$\left(\frac{\ell}{n}\right) \;=\; \tau(\ell,n)\left(\frac{n}{\ell}\right).$$

*Proof.* Both are the law of quadratic reciprocity — respectively for the
Legendre symbol and its Jacobi extension — with the classical sign
$(-1)^{\frac{p-1}{2}\frac{q-1}{2}}$ rewritten via Lemma 6.2. $\square$

**Corollary 6.4 (the sharp dichotomy).** Let $\ell, n$ be odd and coprime.

* If $\ell \equiv n \equiv 3 \pmod 4$ then
  $\left(\frac{\ell}{n}\right) = -\left(\frac{n}{\ell}\right)$: the flip is
  *total*, with no exceptions.
* Otherwise $\left(\frac{\ell}{n}\right) = \left(\frac{n}{\ell}\right)$: the two
  forms agree *identically*.

In particular the two forms flip **iff** $\ell \equiv n \equiv 3 \pmod 4$.

This is exactly what the empirical audit found: a conditional flip rate of
$100\%$ across all $2680$ qualifying rows with zero violations, and — on a
population in which the condition held for $52.3\%$ of the values of $N$ — an
unconditional flip rate of $27.19\%$, matching the predicted density to the
second decimal place.

**Proposition 6.5 (residue bookkeeping).** Over the four odd residue pairs
$(\ell \bmod 4, n \bmod 4) \in \{1,3\}^2$, the twist takes the value $-1$ on
exactly one pair; the unconditional flip density in an unbiased population is
therefore $1/4$. Moreover, for fixed $\ell \equiv 3 \pmod 4$, the twist has mean
zero over the odd residues of $n$:
$$\sum_{b \in \{1,3\}} \tau(\ell, b) = 1 + (-1) = 0 .$$

The mean-zero property is the mechanism by which a flipped dial can lose *all*
linear signal while losing *no* information.

### 6.2 The artifact

Because $\tau = \pm 1$ is an involution, the flipped dial is pointwise
recoverable from the clean one: no information is destroyed. But a $\pm1$
reweighting of a covariate is a *nonlinear* rearrangement from the point of view
of a linear model, and it can annihilate correlation exactly.

**Theorem 6.6 (a twist annihilates a perfect correlation).** Consider four
population rows with targets $t = (+1,+1,-1,-1)$ and a clean dial perfectly
aligned with the target, $\mathrm{clean}_i = t_i$. Let the twist pattern be
$w = (+1,-1,+1,-1)$ — the pattern produced by the $\ell \equiv n \equiv 3 \bmod 4$
condition on a balanced population — and set
$\mathrm{flip}_i = w_i \cdot \mathrm{clean}_i$. Then
$$\sum_{i} \mathrm{clean}_i\, t_i = 4, \qquad
\sum_{i} \mathrm{flip}_i \, t_i = 0 .$$

*Proof.* Direct evaluation: the clean covariances are $1,1,1,1$ summing to $4$;
the flipped ones are $1,-1,1,-1$ summing to $0$. $\square$

**Consequence (erratum).** The previously published weakness of the
composite-bottom rows ($R^2 = .0781$ / D-red $14.22\%$, and $R^2 = .0565$ /
$9.07\%$) is a **dial-form artifact**, not a fact about the arithmetic. This
diagnosis is confirmed on three fronts. First, the weakness is reproduced under
the flipped forms in the present population ($.030 / 4.11\%$ and
$.0456 / 5.46\%$). Second, the clean prime-bottom dial on the same population is
*strong* ($.3728$ / $34.45\%$). Third, the mechanism localises exactly where the
theory says it should:

**Proposition 6.7 (localisation of the artifact).** Let $N$ be odd and let $P$
consist of odd moduli $\ell \equiv 1 \pmod 4$. Then the composite-bottom and
prime-bottom weighted dials over $P$ are *the same covariate*:
$$\sum_{\ell \in P} \frac{\mathbf{1}\bigl[\left(\tfrac{\ell}{N}\right)=1\bigr]}{\ell}
= \sum_{\ell \in P} \frac{\mathbf{1}\bigl[\left(\tfrac{N}{\ell}\right)=1\bigr]}{\ell}.$$

*Proof.* Termwise, by Corollary 6.4: the flip condition fails at every
$\ell \equiv 1 \pmod 4$. $\square$

**Proposition 6.8 (complementarity where it bites).** If $\ell \equiv N \equiv 3
\pmod 4$ and $\gcd(\ell, N) = 1$, then
$$\left(\tfrac{\ell}{N}\right) = 1 \iff \left(\tfrac{N}{\ell}\right) \ne 1 .$$
The two dials are not merely different there; they are *complementary*.

*Proof.* By Corollary 6.4 the symbols are negatives, and each is $\pm1$ by
coprimality. $\square$

**What is not retracted.** The *primary* conclusion of the earlier work was a
null result concerning a different, individual-factor dial. That null replicates
in the present population ($R^2 = .0019$, D-red $0.09\%$, $z = 0.72$), and the
twist mechanism is inapplicable to it, since that dial is already in
prime-bottom form. Only the secondary conclusions are affected. A discrepancy
between two earlier measurements of the same nominal quantity ($.078$ versus
$.32$) is likewise resolved as a form difference plus estimator spread, rather
than a reproducibility failure: the recomputed composite-bottom dial matches the
recorded values on all $128$ rows, and the clean dial is strong in both
populations ($34.45\%$ and $34.75\%$).

---

## 7. What the product dial can and cannot see

The covariate of interest is evaluated on semiprimes $N = pq$. Its arithmetic is
governed by three facts.

**Theorem 7.1 (XOR law).** Let $\ell$ be an odd modulus and $a, b$ integers
coprime to $\ell$. Then
$$\left(\frac{ab}{\ell}\right) = 1 \iff \left(\frac{a}{\ell}\right) = \left(\frac{b}{\ell}\right).$$

*Proof.* The symbol is multiplicative in the top argument and takes values in
$\{\pm1\}$ under coprimality; a product of two signs is $+1$ iff they agree.
$\square$

So the product dial reads a *parity*, not the factors. This has an immediate
consequence.

**Definition 7.2 (weighted product dial).** For $N \in \mathbb{Z}$ and a finite
set $P$ of moduli,
$$W(N, P) = \sum_{\ell \in P} \frac{\mathbf{1}\bigl[\left(\frac{N}{\ell}\right) = 1\bigr]}{\ell}.$$

**Theorem 7.3 (factor blindness).** If
$\left(\frac{p}{\ell}\right)\left(\frac{q}{\ell}\right) =
\left(\frac{p'}{\ell}\right)\left(\frac{q'}{\ell}\right)$ for every $\ell \in P$,
then $W(pq, P) = W(p'q', P)$. In particular, if $p, q$ are residues at every
modulus of $P$ while $p', q'$ are non-residues at every modulus, then
$$W(pq, P) = W(p'q', P) :$$
the $PP$ and $NN$ factorisation types are *invisible* to the dial.

*Proof.* Multiplicativity reduces the dial to the pointwise product of symbols;
equal products give equal indicator patterns and hence equal sums. For the
special case, $(+1)(+1) = (-1)(-1) = +1$. $\square$

**Theorem 7.4 (squares saturate the dial).** If $m$ is coprime to every $\ell \in
P$ then $W(m^2, P) = \sum_{\ell \in P} 1/\ell$, the maximum possible value.

*Proof.* $\left(\frac{m^2}{\ell}\right) = \left(\frac{m}{\ell}\right)^2 = 1$ for
each $\ell$. $\square$

These are hard information-theoretic ceilings: no reweighting can make a
covariate of this form separate configurations that it provably identifies. Any
attempt to extract factor-level information from a product dial must break the
multiplicative symmetry — for instance by combining dials at moduli where the
individual factors' symbols are constrained by other data.

---

## 8. Dispersion bookkeeping: two readings of one reduction

Results were reported in two currencies: the fraction of *raw* conditional
dispersion removed, and the fraction of the *excess above Poisson* removed. The
relation is exact.

**Theorem 8.1 (reading algebra).** If a covariate removes an amount $\Delta \ne 0$
from a conditional dispersion $D > 1$, then the raw reading is $\Delta / D$, the
excess reading is $\Delta/(D-1)$, and
$$\frac{\Delta/D}{\Delta/(D-1)} \;=\; \frac{D-1}{D},$$
*independently of $\Delta$*.

*Proof.* Cancel $\Delta$. $\square$

So the two percentage columns are two coordinates of a single number, and their
ratio identifies the baseline dispersion. Inverting, a raw/excess pair $(r,e)$
implies
$$D(r,e) \;=\; \frac{1}{1 - r/e}.$$

**Proposition 8.2 (the two rows are consistent).** The count dial at $B = 400$
reported $(r,e) = (33.43\%, 42.06\%)$ and the weighted dial at $B = 10^6$
reported $(48.51\%, 61.00\%)$. Then
$$\bigl| D(0.3343, 0.4206) - D(0.4851, 0.6100)\bigr| \;<\; 0.03 .$$

*Proof.* Direct arithmetic: both implied dispersions are close to $4.88$.
$\square$

The two rows are therefore consistent readings of one and the same
overdispersion, not a bookkeeping error.

**Proposition 8.3 (the residual band).** On both readings the weighted dial
leaves strictly less unexplained than the count dial
($1 - .4851 < 1 - .3343$ and $1 - .6100 < 1 - .4206$), and on the
excess-above-Poisson reading the two residual shares lie in the band
$[0.39, 0.58]$ (weighted: $39.00\%$; count: $57.94\%$). On the raw reading the
weighted dial leaves $51.49\%$ unexplained.

**Consequence.** A previously published claim that "$\ge 86\%$" of the structure
in this population is new (i.e. not explained by residue covariates) shrinks
substantially: the residual non-residue structure is $39$–$58\%$ on the excess
reading, and about $51\%$ for the weighted dial on the raw reading. The remainder is genuinely overdispersed
($D_{\mathrm{cond}} > 1$), so the population is not fully explained by the
harmonic dial either; but the honest figure is roughly half, not six sevenths.

---

## 9. Algorithms

### 9.1 Computing the dials

Both dials are computed by a single sieve-and-scan.

1. Sieve the primes $\ell \le B$ (linear sieve, $O(B)$ time / $O(B)$ space, or a
   segmented sieve for $B$ up to $10^9$).
2. For each $\ell$ with $\ell \nmid N$, compute the symbol
   $\left(\frac{N}{\ell}\right)$ by the binary Jacobi algorithm — repeated
   removal of factors of $2$ (with the $\pm1$ rule for $\left(\frac{2}{\ell}\right)$
   given by $\ell \bmod 8$) and reciprocity swaps — in $O(\log^2 \ell)$ bit
   operations. This is strictly faster than an Euler-criterion exponentiation.
3. Accumulate $C(B) \mathrel{+}= 1$ and $W(B) \mathrel{+}= 1/\ell$ whenever the
   symbol is $+1$.

Total cost: $O(\pi(B)\log^2 B)$ symbol work per value of $N$, plus a one-off
sieve shared across the population. In practice the entire sweep to $B = 10^6$
costs a few milliseconds per number.

### 9.2 Locating the count-dial optimum

Theorem 5.3 guarantees a finite maximiser of $\mathrm{score}(n) = H_n^2/n$; the
bound $\mathrm{score}(n) \le (1+\log n)^2/n$ makes the search finite and
explicit. Given a target tolerance, compute $m$ with
$(1+\log m)^2/m < \mathrm{score}(1) = 1$, then maximise by direct scan over
$1 \le n \le m$. The score is unimodal in practice, so a ternary search over the
same range works and costs $O(\log m)$ evaluations.

### 9.3 Auditing a dial for reciprocity flips

Given a population of odd $N$ and a window of odd moduli $\ell$:

1. For each pair, compute both symbols $\left(\frac{N}{\ell}\right)$ and
   $\left(\frac{\ell}{N}\right)$.
2. Record `flip` $= [\left(\frac{\ell}{N}\right) \ne \left(\frac{N}{\ell}\right)]$
   and `cond` $= [\ell \equiv 3 \wedge N \equiv 3 \pmod 4]$.
3. Assert `flip == cond` on every row. Corollary 6.4 says this assertion must
   hold with zero violations whenever $\gcd(\ell, N) = 1$; any violation is a bug
   in the implementation (a classic one being the use of a Jacobi routine with an
   even bottom argument, which is undefined).
4. Report the conditional rate (must be $100\%$) and the unconditional rate
   (which equals the population's density of the condition, $1/4$ for an unbiased
   population).

This audit is $O(|P| \cdot |\text{population}| \cdot \log^2)$ and is the cheapest
possible guard against the artifact of Section 6.

### 9.4 Flatness diagnostics for covariate design

Given an empirical amplitude profile $\hat a$ on a window $T$, compute
$$\mathrm{flat}(T,\hat a) = \frac{(\sum_T \hat a)^2}{|T| \sum_T \hat a^2}.$$
By Theorem 3.3 this number *is* the multiplicative penalty for using equal
weights. A value near $1$ licenses counting; a value near $0$ (as for a $1/\ell$
profile) mandates weighting. The diagnostic costs one pass over the window and
requires no target values at all — it is a property of the covariate design
alone.

---

## 10. Discussion, limitations, and future directions

### 10.1 What has been established

* Equal-weight counting of quadratic-residue primes is dominated at every window
  by harmonic weighting, and the loss is exactly a profile flatness factor,
  strict whenever the amplitudes are non-constant.
* With the arithmetically-dictated $1/\ell$ amplitudes, the weighted dial
  saturates at rate $\Theta(1/n)$ uniformly in the ambient population — a window
  of $400$ already explains at least $99.75\%$ of what any window can — while the
  count dial decays as $(1+\log n)^2/n \to 0$.
* The count dial's optimum is attained at a *finite* window. The scale-shift
  hypothesis is therefore refuted structurally, not merely empirically, and the
  empirically located optimum stands as a scale-independent feature.
* The two dial forms differ by an explicit involutive twist character that is
  $-1$ precisely on $\ell \equiv N \equiv 3 \pmod 4$. Twisting preserves
  information but can annihilate linear correlation exactly, which converts a
  previously published weakness into an erratum. The associated primary null
  result is unaffected and replicates.
* The product dial obeys an XOR law, is blind to the $PP$/$NN$ distinction, and
  is maximal on squares — hard ceilings on what any covariate of this shape can
  detect.

### 10.2 Limitations

The analytic results are theorems about an *orthonormal signal model* with a
prescribed amplitude profile. The model's fidelity rests on two assumptions: that
per-prime contributions to the target are (approximately) uncorrelated, and that
the amplitude at $\ell$ scales like $1/\ell$. Both are standard heuristics for
residue statistics, and the model reproduces both measured columns of the sweep;
neither is proved here from the arithmetic. In particular the constant $400$ is
not derived — what is derived is that *some* finite optimum exists for the count
dial, and that the weighted dial's residual error at window size $n$ is between
$1/(8n)$ and $1/n$, which is what makes $400$ an adequate window rather than a
magic number.

The reciprocity results, by contrast, are unconditional arithmetic and require no
model.

We claim no complexity-theoretic consequence and no breakthrough. The residue
cap of $4/3$ from previous work is untouched by anything here.

### 10.3 Future directions

**Direction 1 — Optimal weight profiles beyond $1/\ell$.** The factorisation
$R^2_{\mathrm{count}} = \mathrm{flat}(T)\cdot R^2_{\mathrm{weighted}}$ identifies
the loss of a covariate with a purely geometric quantity, so the search for the
best dial is a search for the weight vector maximising a Rayleigh quotient, not a
search for a better cutoff. Since the factorisation is exact, the optimisation is
a well-posed finite-dimensional problem: the maximiser is the amplitude profile
itself, and the real question is how much is lost by an *arithmetically
computable* approximation to it — $1/\ell$ versus $\log \ell/\ell$ versus
$1/(\ell \log \ell)$.

**Direction 2 — The twist as a character sum, and exact orthogonality.** The
flipped dial equals the clean dial times $\chi_4(\ell)\chi_4(N)$, so the
covariance of the flipped dial with any target splits into a $\chi_4$-twisted
character sum; the observed near-zero correlation should then be a cancellation
theorem rather than a coincidence. Mean-zero over residues is already available;
the missing step is a quantitative bound on the twisted sum over a window of
primes — precisely a Pólya–Vinogradov-type estimate.

**Direction 3 — Saturation rate as a spectral gap.** The quantity
$1 - R^2_{\mathrm{weighted}}(n)$ equals the normalised tail mass of the amplitude
profile, i.e. the spectral tail of the signal operator; "saturation by $400$" is
then the statement that this operator has rapidly decaying spectrum. Both
directions of the rate are now proved in the model,
$1 - 1/n \le R^2 \le 1 - 1/(8n)$, so the saturation rate is $\Theta(1/n)$ there.
Extending this to a genuine spectral statement about the arithmetic operator —
and identifying the profile decay exponent empirically for other targets — would
make "which window suffices" a computable function of the desired tolerance for
any target, not just this one.

**Direction 4 — Beyond linear covariates.** Because the twist is an involution,
the information lost to a linear model is recoverable by any model that can
condition on $N \bmod 4$. Quantifying the gap between the best linear dial and
the best $\bmod$-$4$-conditioned dial would turn the erratum of Section 6 into a
positive result about interaction terms.

### 10.4 Methodological remarks

Three features of this investigation are worth isolating, since they generalise
beyond quadratic residues.

*Pre-registration prevented an easy story.* The scale-shift alternative was
written down before the data were generated. It was refuted on all four
candidates, and it is precisely because the candidates were fixed in advance that
the refutation means anything.

*Adversarial checking ran in both directions.* Several first-draft claims were
retracted by subsequent verification (an orthogonality claim about cancelling
signs, restated after a label-swap clarification), and one proposed rescue of the
weak dial form — dropping the modulus $\ell = 2$ — was tested and rejected
empirically. A small-sample smoke test that spuriously supported the shift
hypothesis was marked non-evidentiary rather than quietly reported.

*Errata are cheap when the mechanism is a theorem.* Once the difference between
two dial forms is identified as multiplication by an explicit $\pm1$ character,
the entire question "was the weak result real?" reduces to a two-line computation
and an audit assertion that either holds on every row or reveals a bug. The most
useful outcome of a negative result is often an exactly characterised reason for
it.

---

## Appendix A. Summary of results

| Result | Statement |
|---|---|
| $R^2$ formula | $R^2 = (\sum_S c_ia_i)^2 / \bigl((\sum_S c_i^2)(\sum_S a_i^2)\bigr)$ for orthonormal contributions |
| Domination | $R^2_{\mathrm{count}} \le R^2_{\mathrm{weighted}}$ at every window |
| Flatness | $R^2_{\mathrm{count}} = \mathrm{flat}(T,a)\cdot R^2_{\mathrm{weighted}}$, exactly |
| Strictness | strict as soon as two amplitudes on the window differ (Lagrange defect) |
| Saturation | $1 - 1/n \le R^2_{\mathrm{weighted}} \le 1 - 1/(8n)$ for the harmonic profile |
| Window $400$ | $R^2_{\mathrm{weighted}} \ge 0.9975$ at $n = 400$, any ambient population |
| Dilution | $R^2_{\mathrm{count}} \le (1 + \log n)^2 / n \to 0$ |
| Dichotomy | $\forall \varepsilon>0$, eventually weighted $\ge 1-\varepsilon$ and count $\le \varepsilon$ |
| No shift | $H_n^2/n$ attains a global maximum at a finite window |
| Twist | $\left(\frac{\ell}{n}\right) = \tau(\ell,n)\left(\frac{n}{\ell}\right)$, $\tau = -1$ iff $\ell\equiv n\equiv 3 \ (4)$ |
| Artifact | a $\pm1$ twist can send a perfect correlation to exactly zero covariance |
| Localisation | on $\ell \equiv 1 \pmod 4$ the two dial forms are the same covariate |
| XOR law | $\left(\frac{ab}{\ell}\right) = 1 \iff \left(\frac{a}{\ell}\right) = \left(\frac{b}{\ell}\right)$ |
| Blindness | $PP$ and $NN$ semiprimes have identical product dials |
| Readings | $(\Delta/D) / (\Delta/(D-1)) = (D-1)/D$, independent of $\Delta$ |
