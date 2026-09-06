# Moment Fingerprints of Spectral Spacing Laws: A Five-Regime Ladder Separated by a Single Statistic

**Author:** Aristotle
**Date:** 2026-09-06

---

## Abstract

We study the moment sequences ("fingerprints") of the canonical nearest-neighbour
level-spacing laws of spectral statistics: the rigid picket fence, the Wigner
surmise in each of the three classical symmetry classes $\beta \in \{1,2,4\}$,
and the exponential (Poisson) law. Working with the generalized surmise density
$a\,s^{\beta}e^{-b s^{2}}$ on $(0,\infty)$, we derive a closed Gamma form for
every moment and a universal two-term antiderivative recursion
$M_{k+2} = \frac{k+\beta+1}{2b}M_k$, which converts the normalization $M_0 = 1$
into all higher moments with no further integration. For the unitary class this
gives $M_{k+2} = \frac{(k+3)\pi}{8}M_k$ and the closed forms
$M_{2m} = (2m+1)!!(\pi/8)^m$, $M_{2m+1} = (m+1)!(\pi/4)^m$; we prove that this
recursion together with $M_0 = M_1 = 1$ *characterizes* the surmise fingerprint.

Our main structural results are:

1. **No higher moment coincidence.** The unitary surmise moments $M_k$ and the
   exponential moments $P_k = k!$ agree exactly at $k \in \{0,1\}$ and nowhere
   else; moreover $M_k/k! \le 2\cdot 2^{-\lfloor k/2\rfloor} \to 0$.
2. **Index-halving duality.** The genuine relation between the two sequences is
   $M_{2m+1}/P_{m+1} = (\pi/4)^m$ and $M_{2m}\,m! = P_{2m+1}(\pi/16)^m$; the two
   damping ratios $\pi/4$ and $\pi/16$ are both $< 1$, which is exactly the
   mechanism of the strict domination $M_k < k!$.
3. **The $\beta$-ladder.** The second moments satisfy
   $1 < 45\pi/128 < 3\pi/8 < 4/\pi < 2$, and the ordering propagates to every
   moment order $k \ge 2$: $1 < M_k^{(4)} < M_k^{(2)} < M_k^{(1)} < k!$.
4. **A classifier with a proved constant.** The minimal adjacent gap of the
   five-rung ladder is exactly $3\pi/128 \approx 0.0736$ (attained by the
   symplectic/unitary pair). A nearest-rung classifier on the empirical second
   moment is provably correct whenever the estimation error is below
   $3\pi/256$; under a $C n^{-1/2}$ fluctuation bound this holds for
   $n > (2C/(3\pi/128))^2$, i.e. $n \ge 738$ when $C = 1$ (and $n \ge 127$ for
   the coarser three-regime test, whose bottleneck is $3\pi/8 - 1$).
5. **Rigidity and positivity.** For mean-one data the empirical second moment
   equals the empirical variance, so $\widehat{M_2} = 1$ forces every spacing to
   be exactly $1$ and $\widehat{M_2} = 1+\varepsilon$ bounds the mean absolute
   deviation from the picket fence by $\sqrt{\varepsilon}$. Every Hankel form of
   the surmise fingerprint is positive semidefinite; the order-three Hankel
   determinant equals $\pi^2(9\pi-28)/256$, and its positivity is *equivalent*
   to $\pi > 28/9$.

All statements below are unconditional; the only transcendental inputs are
two-decimal and four-decimal enclosures of $\pi$.

**Keywords:** Wigner surmise, level spacing, moment sequence, Hankel
positivity, Dyson $\beta$-ensembles, spectral classification, Gamma function.

---

## 1. Introduction

### 1.1 The classification problem

Let $\lambda_1 < \lambda_2 < \cdots < \lambda_{n+1}$ be a finite spectrum
(energy levels, eigenvalues, resonance frequencies, or zeros of an $L$-function)
and let $s_i = \lambda_{i+1} - \lambda_i$ be the consecutive spacings, rescaled
so that $\frac{1}{n}\sum_i s_i = 1$. The empirical distribution of the $s_i$ is
one of the most robust diagnostics in mathematical physics. Three limiting
shapes recur across an extraordinary range of systems:

- **Rigid** (picket fence): all spacings equal, $s \equiv 1$, i.e. the Dirac
  mass $\delta_1$. This is what an integrable system with equally spaced levels
  — the harmonic oscillator — produces.
- **Wigner–Dyson**: the levels repel, and the spacing density vanishes like
  $s^{\beta}$ at the origin, where $\beta \in \{1,2,4\}$ is dictated by the
  antiunitary symmetries of the Hamiltonian.
- **Poisson**: the levels are statistically independent and the spacings are
  exponential with density $e^{-s}$; small spacings are the most likely.

The practical question is one of *inference*: given finitely many observed
spacings, decide which regime produced them, with a guarantee. This paper
supplies such a guarantee, built from an exact analysis of the moment sequences.

### 1.2 Method: fingerprints

We call the sequence $\big(M_k\big)_{k \ge 0}$, $M_k = \int_0^\infty s^k p(s)\,ds$,
the **moment fingerprint** of a spacing law $p$. Normalization pins the first
two entries: every law we consider has $M_0 = M_1 = 1$. All discriminating
information therefore lives from $k = 2$ onwards. The organizing device of the
whole paper is that each fingerprint we consider satisfies a **two-term
recursion**

$$M_{k+2} = c(k)\,M_k, \qquad M_0 = M_1 = 1,$$

with an explicit positive coefficient sequence $c(k)$, and that the entire
comparison theory reduces to comparing coefficient sequences. This turns
transcendental integral inequalities into elementary rational inequalities in
$\pi$.

### 1.3 Organization

Section 2 sets up the generalized surmise family and derives the closed Gamma
form and the universal recursion. Section 3 specializes to $\beta = 2$ and
develops the unitary fingerprint in full: closed forms, uniqueness, the absence
of higher coincidences, the index-halving duality and the generating-function
separation. Section 4 builds the five-rung $\beta$-ladder and proves the full
moment ordering. Section 5 is the classifier: separation constants, sharpness,
finite-sample thresholds, exact and quantitative rigidity, realizability.
Section 6 treats Hankel positivity. Section 7 gives numerical corroboration,
Section 8 algorithms, Section 9 discussion and open problems.

---

## 2. The generalized surmise family

### 2.1 Definition

**Definition 2.1 (Generalized surmise moment).**
For an integer $\beta \ge 0$ and reals $a \in \mathbb{R}$, $b > 0$, set

$$\mathcal{M}_k(\beta; a, b) \;=\; \int_0^\infty s^k \left(a\,s^{\beta} e^{-b s^{2}}\right) ds ,
\qquad k \in \mathbb{N}.$$

When $a$ and $b$ are chosen so that $\mathcal{M}_0 = \mathcal{M}_1 = 1$, the
integrand $a s^{\beta}e^{-bs^2}$ is a mean-one probability density on
$(0,\infty)$: the **Wigner surmise of index $\beta$**.

### 2.2 Closed form

**Theorem 2.2 (Gamma closed form).**
For every $\beta, k \in \mathbb{N}$, every $a \in \mathbb{R}$ and every $b > 0$,

$$\mathcal{M}_k(\beta;a,b) \;=\; \frac{a}{2}\; b^{-\frac{k+\beta+1}{2}}\;
\Gamma\!\left(\frac{k+\beta+1}{2}\right).$$

*Proof sketch.* Absorb $s^k \cdot s^{\beta} = s^{k+\beta}$ and substitute
$u = b s^{2}$. The standard Gaussian-type evaluation
$\int_0^\infty s^{q} e^{-b s^{2}} ds = \tfrac12 b^{-(q+1)/2}\Gamma\!\big(\tfrac{q+1}{2}\big)$,
valid for $q > -1$ and $b>0$, applies with $q = k+\beta \ge 0$; multiplying by
the constant $a$ gives the claim. Integrability is automatic from the Gaussian
tail. $\square$

### 2.3 The universal recursion

The single computational engine of the paper is the following, obtained from
Theorem 2.2 and the functional equation $\Gamma(t+1) = t\,\Gamma(t)$. It is the
integration-by-parts (antiderivative) relation for the Gaussian weight, applied
twice, and it holds for *both parities of $k$ simultaneously*.

**Theorem 2.3 (Antiderivative recursion).**
For every $\beta, k \in \mathbb{N}$, $a \in \mathbb{R}$, $b > 0$,

$$\mathcal{M}_{k+2}(\beta;a,b) \;=\; \frac{k+\beta+1}{2b}\;\mathcal{M}_k(\beta;a,b).$$

*Proof sketch.* Write $t = \frac{k+\beta+1}{2}$. By Theorem 2.2 the index
$k+2$ replaces $t$ by $t+1$ in the Gamma argument and subtracts $1$ from the
exponent of $b$:
$\mathcal{M}_{k+2} = \frac a2 b^{-t-1}\Gamma(t+1) = \frac a2 b^{-t}b^{-1}\,t\,\Gamma(t)
= \frac{t}{b}\mathcal{M}_k$, and $t/b = (k+\beta+1)/(2b)$. $\square$

**Corollary 2.4 (Second moments for free).** If the density is normalized so
that $\mathcal{M}_0 = 1$, then $\mathcal{M}_2 = \frac{\beta+1}{2b}$ — no
integration required.

### 2.4 The three symmetry classes

Normalizing $a$ and $b$ so that $\mathcal{M}_0 = \mathcal{M}_1 = 1$ produces the
three classical surmises:

**Definition 2.5.** The mean-one Wigner surmises are

$$p_1(s) = \frac{\pi}{2}\,s\,e^{-\pi s^{2}/4}
\quad(\beta=1,\ \text{GOE}),$$
$$p_2(s) = \frac{32}{\pi^{2}}\,s^{2}\,e^{-4s^{2}/\pi}
\quad(\beta=2,\ \text{GUE}),$$
$$p_4(s) = \frac{2^{18}}{3^{6}\pi^{3}}\,s^{4}\,e^{-64 s^{2}/(9\pi)}
\quad(\beta=4,\ \text{GSE}),$$

with fingerprints $M^{(1)}_k$, $M^{(2)}_k$, $M^{(4)}_k$ respectively. The rigid
fingerprint is $R_k \equiv 1$ (moments of $\delta_1$), and the Poisson
fingerprint is $P_k = \int_0^\infty s^k e^{-s}ds = k!$.

**Proposition 2.6 (Normalization and mean).** Each $p_\beta$ above satisfies
$M^{(\beta)}_0 = M^{(\beta)}_1 = 1$.

*Proof sketch.* Apply Theorem 2.2 with the stated $(a,b)$. For $\beta = 1$ one
needs $\Gamma(1) = 1$ and $\Gamma(3/2) = \sqrt{\pi}/2$ together with
$\sqrt{\pi/4} = \sqrt\pi/2$; for $\beta = 2$, $\Gamma(3/2)$ and $\Gamma(2) = 1$;
for $\beta = 4$, $\Gamma(5/2) = 3\sqrt\pi/4$ and $\Gamma(3) = 2$, together with
$\sqrt{64/(9\pi)} = 8/(3\sqrt\pi)$. Each reduces to an identity in
$\sqrt\pi$. $\square$

**Corollary 2.7 (The four recursion coefficients).** Writing each fingerprint's
recursion as $M_{k+2} = c(k)M_k$:

$$c_{\mathrm{GSE}}(k) = \frac{9\pi(k+5)}{128}, \qquad
c_{\mathrm{GUE}}(k) = \frac{\pi(k+3)}{8}, \qquad
c_{\mathrm{GOE}}(k) = \frac{2(k+2)}{\pi},$$

and, from $P_{k+2} = (k+2)(k+1)P_k$,
$c_{\mathrm{Poi}}(k) = (k+1)(k+2)$. The rigid coefficient is
$c_{\mathrm{rig}}(k) \equiv 1$.

*Proof sketch.* Substitute $(\beta, b)$ into Theorem 2.3:
$\beta=4$, $b = 64/(9\pi)$ gives $(k+5)\cdot 9\pi/128$; $\beta=2$, $b=4/\pi$
gives $(k+3)\pi/8$; $\beta=1$, $b=\pi/4$ gives $(k+2)\cdot 2/\pi$. The Poisson
case is $\Gamma$'s functional equation on integers. $\square$

By Corollary 2.4 the second moments are then

$$M^{(4)}_2 = \frac{45\pi}{128}, \qquad
M^{(2)}_2 = \frac{3\pi}{8}, \qquad
M^{(1)}_2 = \frac{4}{\pi}.$$

---

## 3. The unitary fingerprint in detail

Throughout this section $M_k := M^{(2)}_k$ denotes the GUE surmise moments and
$P_k = k!$ the Poisson moments.

### 3.1 Closed forms

**Theorem 3.1.** $M_{k+2} = \dfrac{(k+3)\pi}{8}M_k$ with $M_0 = M_1 = 1$, and
consequently, for all $m \ge 0$,

$$M_{2m} = (2m+1)!!\left(\frac{\pi}{8}\right)^{m},
\qquad
M_{2m+1} = (m+1)!\left(\frac{\pi}{4}\right)^{m},$$

where $(2m+1)!! = 1\cdot3\cdots(2m+1)$.

*Proof sketch.* The recursion is Corollary 2.7. Both closed forms follow by
induction on $m$: for the even branch, $(2(m+1)+1)!! = (2m+3)(2m+1)!!$ matches
the coefficient $c(2m) = (2m+3)\pi/8$; for the odd branch,
$(m+2)! = (m+2)(m+1)!$ matches $c(2m+1) = (2m+4)\pi/8 = (m+2)\pi/4$. $\square$

Explicitly $M_2 = 3\pi/8$, $M_3 = \pi/2$, $M_4 = 15\pi^2/64$,
$M_6 = 105(\pi/8)^3$, $M_8 = 945(\pi/8)^4$, $M_{10} = 10395(\pi/8)^5$.

### 3.2 The recursion is a characterization

**Theorem 3.2 (Rigidity of the recursion).** Let $(A_k)_{k\ge0}$ be any real
sequence with $A_0 = A_1 = 1$ and $A_{k+2} = \frac{(k+3)\pi}{8}A_k$ for all $k$.
Then $A_k = M_k$ for every $k$.

*Proof sketch.* Strong induction: the two base cases are the hypotheses, and the
inductive step compares the two recursions term by term. $\square$

Thus the pair (two seed values, one recursion) is a complete encoding of the
surmise: the fingerprint carries exactly the same information as the density.

### 3.3 Strict ordering and no higher coincidence

**Theorem 3.3 (Three-regime moment ordering).** For every $k \ge 2$,

$$R_k = 1 \;<\; M_k \;<\; P_k = k!.$$

*Proof sketch.* Both inequalities are proved by two-step induction, seeded at
$k = 2$ and $k = 3$ and propagated by the recursion.

*Lower bound.* $M_2 = 3\pi/8 > 1$ and $M_3 = \pi/2 > 1$ because $\pi > 3.14$.
For $k \ge 2$ the coefficient satisfies $c_{\mathrm{GUE}}(k) = (k+3)\pi/8 \ge
5\pi/8 > 1$, so $M_{k+2} = c(k)M_k > M_k > 1$.

*Upper bound.* $3\pi/8 < 2 = 2!$ and $\pi/2 < 6 = 3!$ because $\pi < 3.15$. For
the step, compare coefficients: $(k+3)\pi/8 < (k+1)(k+2)$ for all $k \ge 0$ (at
$k=0$: $3\pi/8 \approx 1.18 < 2$; the right side grows quadratically). Combined
with $M_k < P_k$ and positivity of both sequences, multiplying the two strict
inequalities gives $M_{k+2} < P_{k+2}$. $\square$

**Theorem 3.4 (No higher coincidence).** $M_k = k!$ if and only if $k \le 1$.

*Proof sketch.* Immediate from Theorem 3.3 for $k \ge 2$; and $M_0 = 0! = 1$,
$M_1 = 1! = 1$. $\square$

This refutes the natural speculation that the two fingerprints, being built from
double factorials and factorials respectively, must graze somewhere at higher
order. The powers of $\pi/8 < 1$ (respectively $\pi/4 < 1$) make the surmise
sequence permanently sub-factorial. Quantitatively:

**Theorem 3.5 (Geometric decay of the fingerprint ratio).** For $k \ge 2$,

$$\frac{M_k}{k!} \;\le\; 2\cdot\left(\frac12\right)^{\lfloor k/2\rfloor},
\qquad\text{hence}\qquad \lim_{k\to\infty}\frac{M_k}{k!} = 0.$$

*Proof sketch.* Induct in steps of two. The base cases are direct:
$M_2/2! = 3\pi/16 \approx 0.589 \le 1$ and $M_3/3! = \pi/12 \approx 0.262 \le 1$,
and $2\cdot 2^{-\lfloor k/2\rfloor} = 1$ for $k \in \{2,3\}$. For the step from
index $k$ to $k+2$ with $k \ge 2$, the ratio of recursion coefficients is
$$\frac{(k+3)\pi/8}{(k+1)(k+2)} \;\le\; \frac12 \qquad (k \ge 2),$$
since $(k+3)\pi \le 4(k+1)(k+2)$ already at $k = 2$ ($5\pi \approx 15.7 \le 48$)
and the right side grows quadratically. Hence each two-step advance at least
halves $M_k/k!$, while $\lfloor k/2\rfloor$ increases by exactly one. The limit
follows by squeezing between $0$ and the geometric bound. $\square$

### 3.4 The index-halving duality

Although the raw sequences never coincide beyond $k=1$, they are related by an
exact structural identity — the honest content of the suspected "coincidence".

**Theorem 3.6 (Odd duality).** For all $m \ge 0$,

$$M_{2m+1} = P_{m+1}\left(\frac{\pi}{4}\right)^{m},
\qquad\text{equivalently}\qquad
\frac{M_{2m+1}}{P_{m+1}} = \left(\frac{\pi}{4}\right)^{m}.$$

*Proof sketch.* Both sides equal $(m+1)!(\pi/4)^m$ by Theorem 3.1 and
$P_{m+1} = (m+1)!$. $\square$

**Theorem 3.7 (Even duality).** For all $m \ge 0$,

$$M_{2m}\cdot m! = P_{2m+1}\left(\frac{\pi}{16}\right)^{m}.$$

*Proof sketch.* The double-factorial split
$(2m+1)!!\,(2m)!! = (2m+1)!$ together with $(2m)!! = 2^m m!$ gives
$(2m+1)!!\,2^m m! = (2m+1)!$. Then
$M_{2m}m! = (2m+1)!!(\pi/8)^m m!
= (2m+1)!!\,2^m m! \,(\pi/16)^m = (2m+1)!(\pi/16)^m$. $\square$

**Corollary 3.8.** The two damping ratios satisfy $\pi/4 < 1$ and $\pi/16 < 1$.
They are the sole obstruction to a coincidence of the fingerprints, and their
being $<1$ is the mechanism behind Theorem 3.3.

Interpretation: the odd surmise moments are the Poisson moments *at half the
index*, geometrically damped; the even surmise moments are the odd Poisson
moments divided by $m!$ and geometrically damped. The suspected relation between
the two laws is real, but it lives on a halved index scale.

### 3.5 Analytic separation by generating radii

**Theorem 3.9 (Convergence band).** For $0 \le t$ with $t^2 < 2$, the series
$\sum_{k\ge0} M_k t^k/k!$ converges absolutely. For $t \ge 1$, the series
$\sum_{k\ge0} P_k t^k/k! = \sum_k t^k$ diverges.

*Proof sketch.* By Theorem 3.5, $M_k/k! \le 2\cdot 2^{-\lfloor k/2\rfloor}$.
Splitting into even and odd indices, the even terms are bounded by
$2(t^2/2)^m$ and the odd ones by $2t(t^2/2)^m$, both geometric with ratio
$t^2/2 < 1$. The Poisson series is exactly geometric with ratio $t$. $\square$

**Corollary 3.10 (Analytic litmus test).** For every $t$ with
$1 \le t < \sqrt2$, the exponential generating function of the surmise
fingerprint converges while that of the exponential law diverges. The two
regimes are separated by a whole interval of generating radii, not merely by a
numerical inequality.

---

## 4. The $\beta$-ladder

### 4.1 Second moments

**Theorem 4.1 (The $\beta$-ladder).**

$$1 \;<\; \frac{45\pi}{128} \;<\; \frac{3\pi}{8} \;<\; \frac{4}{\pi} \;<\; 2 .$$

Numerically: $1 < 1.10447 < 1.17810 < 1.27324 < 2$.

*Proof sketch.* $45\pi/128 > 1 \iff \pi > 128/45 = 2.844$; true since
$\pi > 3.14$. $45\pi/128 < 3\pi/8 = 48\pi/128$ is immediate. $3\pi/8 < 4/\pi
\iff 3\pi^2 < 32 \iff \pi^2 < 10.667$, true since $\pi < 3.15$ gives
$\pi^2 < 9.9225$. Finally $4/\pi < 2 \iff \pi > 2$. $\square$

Thus a *single* statistic — the second moment of the normalized spacings —
strictly orders five regimes:

$$\text{rigid} \prec \text{GSE} \prec \text{GUE} \prec \text{GOE} \prec \text{Poisson}.$$

The physical reading is monotone: larger $\beta$ means stronger level repulsion,
a stiffer spectrum, and a second moment closer to the rigid value $1$.

**Definition 4.2 (Ladder values).** $L_0 = 1$, $L_1 = 45\pi/128$,
$L_2 = 3\pi/8$, $L_3 = 4/\pi$, $L_4 = 2$.

**Definition 4.3 (Ladder gap).** $g := \dfrac{3\pi}{128} \approx 0.0736311$.

**Theorem 4.4 (Minimality of the ladder gap).** $g$ is a lower bound for every
adjacent gap of the ladder and is attained exactly by the GSE/GUE pair:

$$g \le L_1 - L_0, \qquad g = L_2 - L_1, \qquad g \le L_3 - L_2,
\qquad g \le L_4 - L_3.$$

*Proof sketch.* $L_2 - L_1 = 3\pi/8 - 45\pi/128 = (48-45)\pi/128 = 3\pi/128 = g$,
an identity. For the other three: $L_1 - L_0 = 45\pi/128 - 1 \approx 0.10447$;
$L_3 - L_2 = 4/\pi - 3\pi/8 \approx 0.09514$, established from the enclosure
$1.269 < 4/\pi < 1.274$; and $L_4 - L_3 = 2 - 4/\pi \approx 0.72676$, from
$4/\pi < 1.28$. $\square$

### 4.2 The full moment ladder

The second-moment ordering is not an accident of $k = 2$: it holds at every
order. The mechanism is a general comparison principle for two-term recursions.

**Lemma 4.5 (Positivity).** If $A_0 = A_1 = 1$, $A_{k+2} = c(k)A_k$ and
$c(k) > 0$ for all $k$, then $A_k > 0$ for all $k$.

*Proof sketch.* Strong induction with two base cases. $\square$

**Lemma 4.6 (Comparison principle).** Let $A, B$ satisfy $A_0=A_1=B_0=B_1=1$,
$A_{k+2} = c_A(k)A_k$, $B_{k+2} = c_B(k)B_k$, with $c_A(k) > 0$ and
$c_A(k) < c_B(k)$ for all $k$. Then $A_k < B_k$ for all $k \ge 2$.

*Proof sketch.* Induct in steps of two. The bases $k=2,3$ read
$A_2 = c_A(0) < c_B(0) = B_2$ and $A_3 = c_A(1) < c_B(1) = B_3$. For the step,
$A_{k+2} = c_A(k)A_k < c_B(k)A_k < c_B(k)B_k = B_{k+2}$, using $A_k > 0$
(Lemma 4.5) for the first inequality and $c_B(k) > 0$, $A_k < B_k$ for the
second. $\square$

**Corollary 4.7.** Taking $A \equiv 1$ (constant coefficients $c_A \equiv 1$):
if $c(k) > 1$ for all $k$ then $A_k > 1$ for all $k \ge 2$.

**Theorem 4.8 (Full moment ladder).** For every $k \ge 2$,

$$1 \;<\; M^{(4)}_k \;<\; M^{(2)}_k \;<\; M^{(1)}_k \;<\; k! .$$

*Proof sketch.* By Lemma 4.6 it suffices to order the recursion coefficients of
Corollary 2.7 at every index $k \ge 0$:

- $1 < \frac{9\pi(k+5)}{128}$: at $k = 0$ this is $45\pi/128 > 1$, and the left
  side is increasing.
- $\frac{9\pi(k+5)}{128} < \frac{\pi(k+3)}{8} = \frac{16\pi(k+3)}{128}$
  $\iff 9k+45 < 16k+48$, true for all $k \ge 0$.
- $\frac{\pi(k+3)}{8} < \frac{2(k+2)}{\pi} \iff \pi^2(k+3) < 16(k+2)$. Using
  $\pi^2 < 9.9225$ it suffices that $9.9225(k+3) < 16(k+2)$, i.e.
  $29.7675 + 9.9225k < 32 + 16k$, true for all $k \ge 0$.
- $\frac{2(k+2)}{\pi} < (k+1)(k+2) \iff 2 < \pi(k+1)$, true since $\pi > 2$.

Applying Lemma 4.6 three times and Corollary 4.7 once yields the chain.
$\square$

So the five-fold ordering is a property of the entire fingerprint, and the
choice of the second moment as the classifying statistic is a matter of
convenience (smallest variance of the estimator, easiest to compute), not of
necessity.

---

## 5. Classification of finite spectra

### 5.1 The estimator and the classifier

**Definition 5.1 (Empirical second moment).** For spacings
$s_1,\dots,s_n \in \mathbb{R}$,
$\widehat{M_2}(s) := \frac1n \sum_{i=1}^n s_i^2$.

**Definition 5.2 (Five-regime classifier).** $\mathrm{cl}_5(x)$ returns the index
of the nearest ladder rung, implemented by the four midpoint thresholds:
$\mathrm{cl}_5(x) = 0$ if $x < \frac{L_0+L_1}{2}$; else $1$ if
$x < \frac{L_1+L_2}{2}$; else $2$ if $x < \frac{L_2+L_3}{2}$; else $3$ if
$x < \frac{L_3+L_4}{2}$; else $4$.

The coarse three-regime classifier $\mathrm{cl}_3$ is defined identically on the
rungs $\{1, 3\pi/8, 2\}$, with separation constant
$\sigma := 3\pi/8 - 1 \approx 0.178097$.

**Proposition 5.3.** $\sigma > 0$ and $\sigma \le 2 - 3\pi/8$: the lower gap is
the minimal one for the three-regime ladder, exactly as $g$ is for the
five-regime one.

*Proof sketch.* $\sigma > 0 \iff \pi > 8/3$; $\sigma \le 2 - 3\pi/8 \iff
3\pi/4 \le 3 \iff \pi \le 4$. $\square$

### 5.2 Separation theorems

**Theorem 5.4 (Five-regime separation).** Let $i \in \{0,1,2,3,4\}$ and
$x \in \mathbb{R}$ with $|x - L_i| < g/2 = 3\pi/256 \approx 0.0368155$. Then
$\mathrm{cl}_5(x) = i$.

*Proof sketch.* By Theorem 4.4 each adjacent gap is at least $g$, so the
interval $(L_i - g/2, L_i + g/2)$ lies strictly inside the Voronoi cell of $L_i$
determined by the midpoint thresholds. Explicit verification of the five cases
uses only the enclosures $3.14 < \pi < 3.15$ and $1.269 < 4/\pi < 1.274$.
$\square$

**Theorem 5.5 (Three-regime separation).** If $\mu \in \{1, 3\pi/8, 2\}$ and
$|x - \mu| < \sigma/2$, then $\mathrm{cl}_3(x) = \mathrm{cl}_3(\mu)$.

**Theorem 5.6 (Sharpness).** The constant $\sigma/2$ cannot be relaxed to a
non-strict inequality: at $x = \frac{1 + 3\pi/8}{2}$, which satisfies
$|x - 1| = \sigma/2$ exactly, one has $\mathrm{cl}_3(x) = 1 \ne 0 =
\mathrm{cl}_3(1)$.

*Proof sketch.* The midpoint between two rungs lies exactly at half-gap distance
from each, and the tie-breaking convention assigns it to the upper rung.
$\square$

### 5.3 Finite-sample guarantees

**Theorem 5.7 (Classification under $n^{-1/2}$ fluctuations).** Let $C \ge 0$,
let $s_1,\dots,s_n$ be observed spacings, let $i \le 4$, and suppose

$$\left|\widehat{M_2}(s) - L_i\right| \;\le\; \frac{C}{\sqrt n},
\qquad n \;>\; \left(\frac{2C}{g}\right)^{2}.$$

Then $\mathrm{cl}_5(\widehat{M_2}(s)) = i$.

*Proof sketch.* The hypothesis $n > (2C/g)^2$ gives $\sqrt n > 2C/g$, hence
$C/\sqrt n < g/2$; apply Theorem 5.4. (If $C < 0$ the fluctuation hypothesis is
vacuous, since the left side is nonnegative.) $\square$

**Corollary 5.8 (Explicit thresholds).** With $C = 1$:

- **Five regimes:** $n \ge 738$ spacings suffice. Indeed
  $g > 0.073628$ gives $(2/g)^2 < 738$.
- **Three regimes:** $n \ge 127$ spacings suffice, since
  $\sigma > 0.178$ gives $(2/\sigma)^2 < 127$.

These are the operational headline numbers: fewer than eight hundred spacings
give a *provably* correct five-way classification under a unit-constant
$n^{-1/2}$ error bound; fewer than one hundred and thirty give the coarse
three-way answer.

### 5.4 Exact and quantitative rigidity

The rigid rung is not a labelling convention but a characterization.

**Lemma 5.9 (Second moment = variance).** If $n \ge 1$ and
$\frac1n\sum_i s_i = 1$, then

$$\sum_{i=1}^n (s_i - 1)^2 \;=\; n\left(\widehat{M_2}(s) - 1\right).$$

*Proof sketch.* Expand $(s_i-1)^2 = s_i^2 - 2s_i + 1$ and sum, using
$\sum_i s_i = n$ and $\sum_i s_i^2 = n\widehat{M_2}$. $\square$

**Theorem 5.10 (Exact rigidity).** If $\frac1n\sum_i s_i = 1$ and
$\widehat{M_2}(s) = 1$, then $s_i = 1$ for every $i$.

*Proof sketch.* Lemma 5.9 gives $\sum_i (s_i-1)^2 = 0$; a sum of squares
vanishes only if each term does. $\square$

**Theorem 5.11 (Quantitative rigidity).** If $\frac1n\sum_i s_i = 1$, then

$$\frac1n\sum_{i=1}^n |s_i - 1| \;\le\; \sqrt{\widehat{M_2}(s) - 1}.$$

*Proof sketch.* Cauchy–Schwarz gives
$\big(\sum_i |s_i-1|\big)^2 \le n\sum_i (s_i-1)^2 = n^2(\widehat{M_2}-1)$ by
Lemma 5.9; take square roots and divide by $n$. (The right-hand side is
well-defined because Lemma 5.9 forces $\widehat{M_2} \ge 1$ for mean-one
data.) $\square$

So an observed second moment of $1 + \varepsilon$ certifies that the spectrum
lies within mean absolute deviation $\sqrt\varepsilon$ of the perfect picket
fence — a transport-type bound on the rigid end of the classifier.

**Example 5.12.** For an arithmetic spectrum $\lambda_i = a + i$ every spacing
is exactly $1$, so $\widehat{M_2} = 1$ and the classifier returns the rigid
regime.

### 5.5 Realizability

**Definition 5.13.** For $t \in [0,1]$ let $\mathbf{s}(t) = (1+t,\,1-t)$, a
nonnegative mean-one two-point spacing configuration.

**Theorem 5.14 (Every rung is attained).** $\widehat{M_2}(\mathbf{s}(t)) = 1+t^2$;
hence for every $\mu \in [1,2]$ the configuration
$\mathbf{s}(\sqrt{\mu-1})$ is a nonnegative mean-one finite spacing
configuration with empirical second moment exactly $\mu$. In particular each of
the five rungs $1$, $45\pi/128$, $3\pi/8$, $4/\pi$, $2$ is realized by an
explicit finite spectrum.

*Proof sketch.* $\frac12\big((1+t)^2 + (1-t)^2\big) = 1+t^2$. Given
$\mu \in [1,2]$, set $t = \sqrt{\mu-1} \in [0,1]$; nonnegativity of the entries
follows from $t \le 1$. $\square$

The classifier's range is therefore not a mathematical fiction: its buckets are
all nonempty on genuine data.

---

## 6. Hankel positivity of the surmise fingerprint

The variance gap and the ladder are shadows of a structural fact: the surmise
fingerprint is a *bona fide* moment sequence in the Hamburger sense.

**Theorem 6.1 (Integrability of polynomial weights).** For every $k \in
\mathbb{N}$, the function $s \mapsto s^k p_2(s)$ is integrable on $(0,\infty)$.

*Proof sketch.* $s^k p_2(s) = \frac{32}{\pi^2}s^{k+2}e^{-4s^2/\pi}$, and
$s^{q}e^{-bs^2}$ is integrable on $(0,\infty)$ for all $q > -1$, $b > 0$.
$\square$

**Theorem 6.2 (Hankel positive semidefiniteness).** For every $n \ge 1$ and all
$c_0,\dots,c_{n-1} \in \mathbb{R}$,

$$\sum_{i=0}^{n-1}\sum_{j=0}^{n-1} c_i c_j \,M_{i+j} \;\ge\; 0 .$$

*Proof sketch.* By Theorem 6.1 each term may be written as an integral, and the
finite double sum exchanges with the integral. Then
$$\sum_{i,j} c_ic_j\, s^{i+j} p_2(s) = \Big(\sum_i c_i s^i\Big)^2 p_2(s) \ge 0
\quad \text{pointwise},$$
because $p_2 \ge 0$; integrate. $\square$

**Corollary 6.3 (Order two: the variance gap as a determinant).**

$$M_0M_2 - M_1^2 = \frac{3\pi}{8} - 1 = \sigma .$$

**Definition 6.4 (Third Hankel determinant).** For a sequence $M$,
$$H_3(M) := \det\begin{pmatrix} M_0 & M_1 & M_2 \\ M_1 & M_2 & M_3 \\
M_2 & M_3 & M_4\end{pmatrix}
= M_0(M_2M_4 - M_3^2) - M_1(M_1M_4 - M_2M_3) + M_2(M_1M_3 - M_2^2).$$

**Theorem 6.5 (Hankel fingerprints of the three regimes).**

$$H_3(R) = 0, \qquad
H_3(M) = \frac{\pi^{2}(9\pi - 28)}{256} \approx 0.0105764, \qquad
H_3(P) = 4,$$

and these are strictly ordered: $0 < \pi^2(9\pi-28)/256 < 4$.

*Proof sketch.* For the rigid sequence all entries are $1$, so the matrix has
rank one and determinant $0$ — the analytic reflection of the fact that a point
mass is supported on a single point. For the surmise, substitute
$M_0 = M_1 = 1$, $M_2 = 3\pi/8$, $M_3 = \pi/2$, $M_4 = 15\pi^2/64$ and expand;
the result simplifies to $\pi^2(9\pi-28)/256$. For Poisson, substitute
$1,1,2,6,24$ and compute $1(2\cdot24 - 36) - 1(24 - 12) + 2(6-4) = 12 - 12 + 4 =
4$. The orderings follow from $3.14 < \pi < 3.15$. $\square$

**Theorem 6.6 (A transcendence-free equivalence).**

$$H_3(M) > 0 \iff \pi > \frac{28}{9}.$$

*Proof sketch.* $H_3(M) = \pi^2(9\pi-28)/256$ and $\pi^2 > 0$, so the sign of
$H_3(M)$ is the sign of $9\pi - 28$. $\square$

Since $28/9 = 3.1\overline{1}$, the positivity of the third Hankel determinant
of the Wigner fingerprint — a structural statement about random-matrix spacing
statistics — reduces to the second decimal digit of $\pi$.

---

## 7. Numerical corroboration

Direct quadrature of $\int_0^\infty s^k p_2(s)\,ds$ on $[0,25]$ (trapezoid rule,
$2\times10^5$ nodes) against the closed forms of Theorem 3.1:

| $k$ | quadrature | closed form | $k!$ | $M_k/k!$ | bound $2\cdot2^{-\lfloor k/2\rfloor}$ |
|---|---|---|---|---|---|
| 0 | 1.000000 | $1$ | 1 | 1.000000 | 2 |
| 1 | 1.000000 | $1$ | 1 | 1.000000 | 2 |
| 2 | 1.178097 | $3\pi/8 = 1.178097$ | 2 | 0.589049 | 1 |
| 3 | 1.570796 | $\pi/2 = 1.570796$ | 6 | 0.261799 | 1 |
| 4 | 2.313189 | $15\pi^2/64 = 2.313189$ | 24 | 0.096383 | 0.5 |
| 6 | 6.358709 | $105(\pi/8)^3$ | 720 | 0.008832 | 0.25 |
| 8 | 22.473533 | $945(\pi/8)^4$ | 40320 | 0.000557 | 0.125 |
| 10 | 97.078693 | $10395(\pi/8)^5$ | 3628800 | 0.0000268 | 0.0625 |

The even coefficients $1,3,15,105,945$ are the double factorials; the odd
coefficients $1,2,6,24$ are factorials — exactly the two branches of
Theorem 3.1. A scan of $2 \le k \le 10^4$ found no $k$ with $M_k = k!$,
consistent with Theorem 3.4. The five ladder values evaluate to
$1$, $1.104466$, $1.178097$, $1.273240$, $2$, with adjacent gaps
$0.104466$, $0.0736311$, $0.0951423$, $0.726760$; the minimum is the second, equal
to $3\pi/128$, as Theorem 4.4 asserts.

---

## 8. Algorithms

### 8.1 Moment evaluation by recursion

Rather than evaluating Gamma functions, all moments of any regime are obtained
by iterating the two-term recursion from the seeds $M_0 = M_1 = 1$:

```
Input: regime coefficient function c(k), order K
M[0] ← 1;  M[1] ← 1
for k ← 0 to K-2:
    M[k+2] ← c(k) · M[k]
return M[0..K]
```

This costs $K$ multiplications and is exact up to floating-point rounding; it is
also the numerically stable route, since the closed forms involve products of
large factorials against small powers of $\pi/8$.

### 8.2 Second-moment classification

```
Input: raw levels λ_1 < ... < λ_{n+1}
1. s_i ← λ_{i+1} - λ_i                     (raw spacings)
2. s_i ← s_i / mean(s)                     (unfolding to mean one)
3. m2 ← mean(s_i²)                          (the statistic)
4. return argmin_{i ∈ {0..4}} |m2 - L_i|    (nearest rung)
```

with certificate: if $|m_2 - L_{i^*}| < 3\pi/256$, the answer is provably the
correct rung (Theorem 5.4); if the sample obeys a $C/\sqrt n$ error bound and
$n > (2C/g)^2$, no certificate check is needed (Theorem 5.7).

Complexity: $O(n)$ time, $O(1)$ additional space.

### 8.3 Hankel certificate

Given the first $2N-1$ moments, form $H_{ij} = M_{i+j}$ and compute the leading
principal minors. All being positive certifies (in the finite-order sense) that
the fingerprint is a genuine moment sequence; Theorem 6.2 guarantees this holds
at every order for the surmise. Complexity $O(N^3)$ by Cholesky.

---

## 9. Discussion and future directions

### 9.1 What has been established

The development turns a qualitative physical diagnostic into a quantitative
theorem with explicit constants:

- a single recursion, $M_{k+2} = \frac{k+\beta+1}{2b}M_k$, generates all moments
  of every symmetry class and characterizes each fingerprint;
- the five regimes are strictly ordered at *every* moment order $k \ge 2$;
- the second moment classifies with proved separation $3\pi/128$ (five regimes)
  or $3\pi/8 - 1$ (three regimes), sharp, with sample thresholds $738$ and $127$
  under a unit-constant $n^{-1/2}$ fluctuation bound;
- the rigid bucket is a characterization, with a $\sqrt{\varepsilon}$ stability
  estimate;
- the surmise fingerprint is Hankel positive semidefinite at every order.

The initial speculation of a higher-order coincidence between the Wigner and
exponential moment sequences is false (Theorem 3.4), but the correct statement
is the index-halving duality of Theorems 3.6–3.7.

### 9.2 Conjecture 1 — $\beta$-monotonicity of the whole fingerprint

For the mean-one surmise family with density $\propto s^{\beta}e^{-b_\beta s^2}$,
one computes

$$M_k(\beta) \;=\;
\frac{\Gamma\!\big(\frac{k+\beta+1}{2}\big)\,
\Gamma\!\big(\frac{\beta+1}{2}\big)^{k-1}}
{\Gamma\!\big(\frac{\beta+2}{2}\big)^{k}} .$$

**Conjecture.** For every fixed $k \ge 2$, $\beta \mapsto M_k(\beta)$ is
*strictly decreasing* on $\beta > 0$. Consequently the spectral ladder is a
continuum indexed by $\beta$, not merely the three points $\beta \in \{1,2,4\}$.

The key insight is that the whole ladder is a statement about strict convexity
of $\log\Gamma$: the second moment is $\exp$ of a second difference of
$\log\Gamma$ evaluated on a half-integer lattice, so $\beta$-monotonicity is
exactly the monotone decrease of the trigamma function along half-steps. The
discrete instances $\beta \in \{1,2,4\}$ are established here (Theorem 4.8) by
the elementary coefficient-comparison principle of Lemma 4.6; the continuum
statement should follow from standard convexity and Bohr–Mollerup machinery for
the Gamma function.

### 9.3 Conjecture 2 — Carleman determinacy of the Wigner fingerprint

**Conjecture.** The Wigner surmise is *moment-determinate*: any probability
measure on $[0,\infty)$ whose moments are $(2m+1)!!(\pi/8)^m$ and
$(m+1)!(\pi/4)^m$ equals the surmise. More strongly, Carleman's condition
$\sum_k M_k^{-1/2k} = \infty$ holds.

The heuristic is immediate from the closed forms: $M_{2m}^{1/4m} \sim
\sqrt{m}\,\cdot$const, so $M_k^{-1/2k}$ decays like $k^{-1/2}$ and the series
diverges. Combined with Theorem 6.2 this would upgrade "the fingerprint is a
moment sequence" to "the fingerprint *is* the surmise", making the moment
classification lossless in principle.

### 9.4 Further directions

- **Beyond the second moment.** Theorem 4.8 shows every order $k \ge 2$
  separates the regimes. Which $k$ minimizes the sample complexity, trading a
  larger inter-regime gap against a larger estimator variance? A moment-ratio
  statistic such as $M_4/M_2^2$ may beat $M_2$ in practice.
- **From surmise to exact ensembles.** The Wigner surmise is the exact
  $2\times2$ result and an excellent approximation to the true Gaudin
  distribution of the large-$N$ ensembles. Quantifying the ladder gap for the
  exact spacing laws (whose second moments differ from the surmise values in the
  third decimal) would replace the surmise constants by the true ones without
  changing the architecture of the argument.
- **Unfolding error.** The $C/\sqrt n$ hypothesis absorbs both sampling noise
  and unfolding bias. A principled bound on $C$ for standard unfolding
  procedures would make the thresholds $738$ and $127$ fully turnkey.
- **Higher Hankel fingerprints.** $H_3$ already gives the ordering
  $0 < \pi^2(9\pi-28)/256 < 4$. Do all $H_N$ separate the regimes, and is the
  ordering monotone in $\beta$ as Conjecture 1 predicts for the moments?
- **Multivariate fingerprints.** Joint moments of consecutive spacings
  $(s_i, s_{i+1})$ capture correlations invisible to the marginal law and would
  distinguish, for instance, a genuine ensemble from an independent resampling
  of its spacing marginal.

---

## 10. Summary of principal results

| Result | Statement |
|---|---|
| Gamma closed form | $\mathcal{M}_k(\beta;a,b) = \frac a2 b^{-(k+\beta+1)/2}\Gamma\!\big(\frac{k+\beta+1}{2}\big)$ |
| Universal recursion | $\mathcal{M}_{k+2} = \frac{k+\beta+1}{2b}\mathcal{M}_k$ |
| GUE closed forms | $M_{2m} = (2m+1)!!(\pi/8)^m$, $M_{2m+1} = (m+1)!(\pi/4)^m$ |
| Uniqueness | $M_0=M_1=1$ plus the recursion determines the fingerprint |
| No coincidence | $M_k = k! \iff k \le 1$; $M_k/k! \le 2\cdot2^{-\lfloor k/2\rfloor}$ |
| Odd duality | $M_{2m+1}/P_{m+1} = (\pi/4)^m$ |
| Even duality | $M_{2m}\,m! = P_{2m+1}(\pi/16)^m$ |
| Generating radii | $\sum M_kt^k/k!$ converges for $t^2<2$; $\sum P_kt^k/k!$ diverges for $t\ge1$ |
| $\beta$-ladder | $1 < 45\pi/128 < 3\pi/8 < 4/\pi < 2$ |
| Minimal gap | $3\pi/128$, attained by the GSE/GUE pair |
| Full moment ladder | $1 < M^{(4)}_k < M^{(2)}_k < M^{(1)}_k < k!$ for all $k \ge 2$ |
| Separation | $|x - L_i| < 3\pi/256 \Rightarrow$ nearest-rung classifier returns $i$ |
| Sample threshold | $n \ge 738$ (five regimes), $n \ge 127$ (three regimes), $C=1$ |
| Exact rigidity | mean-one and $\widehat{M_2}=1$ $\Rightarrow$ all spacings $=1$ |
| Quantitative rigidity | $\frac1n\sum|s_i-1| \le \sqrt{\widehat{M_2}-1}$ |
| Hankel positivity | $\sum_{i,j}c_ic_jM_{i+j} \ge 0$ for all $n$, all $c$ |
| Third Hankel determinant | $\pi^2(9\pi-28)/256$; positive $\iff \pi > 28/9$ |
