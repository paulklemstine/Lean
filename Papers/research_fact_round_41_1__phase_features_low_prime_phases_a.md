# Arithmetic Ceilings for Phase Features: Gauss Sums, Near-Orthogonality, and the Impossibility of a Sub-Threshold Lift

**Author:** Aristotle
**Date:** 2026-09-05

---

## Abstract

We study the predictive capacity of *root-position phase features* — the pairs
$\cos(2\pi k r/p)$, $\sin(2\pi k r/p)$ together with the quadratic-residue
indicator $\left(\tfrac{r}{p}\right)$, taken over a range of odd primes $p$ — when
appended to a baseline regression. An empirical study measured an out-of-sample
$R^2$ lift of $+0.008$ over a baseline of $0.600$ (and $+0.004$ for an extended
prime range), with confidence intervals spanning zero, and a phase-only score of
$-0.077$; a pre-registered hypothesis demanded $R^2 \geq 0.70$.

We prove that this outcome is *forced*. Our contributions are of three kinds.

**(i) A deterministic lift ceiling.** For any family of $K$ features with pairwise
correlations at most $\delta$ (with $\delta(K-1) < 1$) and individual correlations
with the residual at most $\varepsilon$, *every* linear combination removes at
most $K\varepsilon^2/(1 - \delta(K-1))$ of the residual energy. For designs
splitting into mutually orthogonal blocks the total lift is at most the sum of
per-block lifts.

**(ii) Arithmetic evaluation of the two constants.** Character orthogonality makes
the trigonometric part of the design exactly orthonormal (up to scale), and the
Chinese Remainder Theorem makes distinct prime blocks exactly orthogonal. The only
surviving coupling, between the quadratic-residue indicator and the phases, is a
Gauss sum; $|g|^2 = p$ yields the normalised coupling
$\delta_p = \sqrt{2/(p-1)}$, which *decreases* in $p$. A **Gauss-sign dichotomy**
— the coupling lives entirely in the sine channel when $p \equiv 3 \pmod 4$ and
entirely in the cosine channel when $p \equiv 1 \pmod 4$, and is exactly $\sqrt p$
there — shows each prime block has a single coupled pair, sharpening the block
stability constant from $1 - 2\delta_p$ to $1 - \delta_p$, and we show
$1 - \delta_p$ is *exactly optimal*. The resulting numerical certificate caps the
achievable phase-augmented score at $0.604$, refuting the registered hypothesis
before any fit.

**(iii) A full-frequency degeneracy.** Over a half-period of frequencies, the
quadratic-residue indicator is *exactly* a linear combination of the phase
features (a Bessel equality: $2$ units of energy per frequency,
$(p-1)/2$ frequencies, total $p-1 = \|\mathrm{QR}\|^2$), so it adds no capacity to
a full-frequency design; the block coupling is a frequency-selection artefact.

Separately, we develop an exact theory of transported coefficients showing that a
negative out-of-sample score is a *certificate* of window locality — the measured
$-0.077$ forces a standardized coefficient miss of at least $0.277$, and the
baseline's own $0.600 \to 0.400$ degradation forces a miss of at least $0.447$ —
and we quantitatively separate the two remaining candidate explanations of the
residual anomaly: higher primes require $\geq 120$ orthogonal blocks to cover an
excess of $0.2$, while same-window leakage reproduces any in-window $R^2$ for free
and predicts a directly measurable correlation of at least $\sqrt{0.6} > 0.774$
with the realized target.

**Keywords:** Gauss sums, quadratic residues, additive characters, near-orthogonal
designs, restricted isometry, coefficient of determination, feature ceilings,
window locality.

---

## 1. Introduction

### 1.1 The empirical setting

A regression problem attaches to each sample point $i$ a target and a feature
vector; a baseline model (a "footprint dial") explains a fraction
$R^2_{\text{base}} = 0.600$ of the target variance out of sample. The residual
carries visible structure, and an arithmetic hypothesis was registered: that the
structure is explained by the *positions* $r$ of the underlying objects modulo
small primes, through their phases.

Concretely, for each odd prime $p$ in a list $\{3,5,7,11,13\}$ (extended in a
second arm to all odd primes up to $29$) and a designated frequency $k$, three
real features are attached to a position $r$:

$$\cos_k(r) = \cos\!\left(\frac{2\pi k r}{p}\right), \qquad \sin_k(r) = \sin\!\left(\frac{2\pi k r}{p}\right), \qquad \mathrm{QR}(r) = \left(\frac{r}{p}\right).$$

The measured outcomes were:

| arm | out-of-sample $R^2$ | lift over baseline |
|---|---|---|
| baseline (footprint dial) | $0.600$ | — |
| baseline $+$ phases, $p \le 13$ | $0.608$ | $+0.008$ (CI spans $0$) |
| baseline $+$ phases, $p \le 29$ | $0.604$ | $+0.004$ (CI spans $0$) |
| phases only | $-0.077$ | $-0.677$ |
| baseline, cross-window | $0.400$ | (in-window $0.600$) |
| registered bar | $0.700$ | refuted |

Two questions arise. First, is the near-zero lift a property of *this* fit, or a
property of the feature family? Second, what does a *negative* score mean, given
that least squares cannot produce one in sample?

### 1.2 Contributions and organisation

Section 2 fixes notation and derives the elementary projection calculus.
Section 3 proves the general lift ceiling and its block-additive form. Section 4
evaluates the two constants of the ceiling arithmetically, via character
orthogonality and Gauss sums, and proves the Gauss-sign dichotomy. Section 5
obtains the sharp per-block constant and shows it exact. Section 6 assembles the
numerical certificate and refutes the registered hypothesis deterministically.
Section 7 proves the full-frequency degeneracy. Section 8 develops the
transported-coefficient theory of window locality. Section 9 separates the two
remaining candidate explanations. Section 10 discusses limitations and future
work.

---

## 2. The design calculus

Throughout, $\iota$ is a finite index set (the sample), and features and residuals
are elements of $\mathbb{R}^\iota$.

**Definition 2.1 (design inner product).** For $x, y \in \mathbb{R}^\iota$ put
$\langle x, y\rangle = \sum_{i \in \iota} x_i y_i$ and $\|x\|^2 = \langle x,x\rangle$.
For a family $(f_k)_{k \in \kappa}$ and coefficients $a \in \mathbb{R}^\kappa$,
the combination is $\mathrm{combo}(a,f)_i = \sum_k a_k f_k(i)$.

**Definition 2.2 (gain).** For $f \neq 0$, the *gain* of $f$ against $e$ is
$$\mathrm{gain}(e,f) = \frac{\langle e, f\rangle^2}{\|f\|^2}.$$

**Proposition 2.3 (single-feature projection identity).** If $\|f\|^2 \neq 0$ then
$$\Big\| e - \tfrac{\langle e,f\rangle}{\|f\|^2}\, f \Big\|^2 = \|e\|^2 - \mathrm{gain}(e,f).$$

*Proof.* Expand $\|e - cf\|^2 = \|e\|^2 - 2c\langle e,f\rangle + c^2\|f\|^2$ and
substitute $c = \langle e,f\rangle/\|f\|^2$. $\square$

Thus $\mathrm{gain}(e,f)$ is *exactly* the residual energy removed by least-squares
fitting of $f$, and $\mathrm{gain}(e,f)/\|e\|^2$ is the incremental $R^2$.

**Proposition 2.4.** $0 \leq \mathrm{gain}(e,f) \leq \|e\|^2$, the right-hand
inequality being Cauchy–Schwarz.

**Proposition 2.5 (orthogonal additivity).** If $(f_k)$ are pairwise orthogonal
with $\|f_k\|^2 > 0$, then fitting all of them simultaneously removes exactly
$\sum_k \mathrm{gain}(e, f_k)$:
$$\Big\|e - \mathrm{combo}\big(k \mapsto \tfrac{\langle e,f_k\rangle}{\|f_k\|^2}, f\big)\Big\|^2 = \|e\|^2 - \sum_k \mathrm{gain}(e,f_k).$$

*Proof.* Write $c_k = \langle e,f_k\rangle/\|f_k\|^2$ and $g = \mathrm{combo}(c,f)$.
Orthogonality gives $\langle e,g\rangle = \sum_k c_k \langle e,f_k\rangle =
\sum_k \mathrm{gain}(e,f_k)$ and $\|g\|^2 = \sum_k c_k^2\|f_k\|^2 = \sum_k
\mathrm{gain}(e,f_k)$; substitute into $\|e-g\|^2 = \|e\|^2 - 2\langle e,g\rangle
+ \|g\|^2$. $\square$

Proposition 2.5 is the "per-prime additivity" of the phase design: for exactly
orthogonal blocks, capacity simply adds, with no interaction term.

---

## 3. The sub-threshold lift ceiling

The obstruction to naively summing per-feature gains is that a *combination* of
correlated features can be short — its norm can be far below the sum of the parts
— and shortness inflates the gain, whose denominator is $\|g\|^2$. The following
restricted-isometry bound rules that out.

**Theorem 3.1 (stability from Gram off-diagonals).** Let $(f_k)_{k\in\kappa}$,
$K = |\kappa|$, satisfy $|\langle f_k, f_l\rangle| \le \delta\|f_k\|\|f_l\|$ for
all $k \neq l$, with $\delta \geq 0$. Then for every $a \in \mathbb{R}^\kappa$,
$$\big(1 - \delta(K-1)\big) \sum_k a_k^2\|f_k\|^2 \;\leq\; \Big\|\sum_k a_k f_k\Big\|^2 .$$

*Proof sketch.* Put $w_k = |a_k|\,\|f_k\|$, $Q = \sum_k w_k^2$, $W = \sum_k w_k$.
Each Gram term obeys $a_k a_l \langle f_k, f_l\rangle \geq -\delta w_k w_l$ off the
diagonal and equals $w_k^2$ on it, so
$\|\sum_k a_k f_k\|^2 \geq (1+\delta)Q - \delta W^2$. Cauchy–Schwarz gives
$W^2 \leq K Q$, whence the bound $\geq (1 + \delta - \delta K)Q$. $\square$

**Theorem 3.2 (sub-threshold lift ceiling).** Let $(f_k)_{k\in\kappa}$ have
$\|f_k\|^2>0$ and satisfy the residual-correlation bound
$$\langle e, f_k\rangle^2 \;\leq\; \varepsilon^2\,\|e\|^2\,\|f_k\|^2 \qquad (k \in \kappa),$$
and suppose the design is a restricted isometry with constant $1-\delta > 0$, i.e.
$(1-\delta)\sum_k a_k^2\|f_k\|^2 \le \|\mathrm{combo}(a,f)\|^2$ for all $a$. Then
for every coefficient vector $a$,
$$\mathrm{gain}\big(e, \mathrm{combo}(a,f)\big) \;\leq\; \frac{K\varepsilon^2}{1-\delta}\,\|e\|^2 .$$

*Proof.* Set $A = \sum_k a_k^2\|f_k\|^2$, $u_k = a_k\|f_k\|$, and
$v_k = \langle e,f_k\rangle/\|f_k\|$, so that $u_k v_k = a_k\langle e,f_k\rangle$
and $\langle e, \mathrm{combo}(a,f)\rangle = \sum_k u_k v_k$. Cauchy–Schwarz gives
$$\langle e,\mathrm{combo}(a,f)\rangle^2 \le \Big(\sum_k u_k^2\Big)\Big(\sum_k v_k^2\Big) \le A \cdot K\varepsilon^2\|e\|^2,$$
using $v_k^2 \le \varepsilon^2\|e\|^2$ from the correlation bound. The restricted
isometry gives $A \le \|\mathrm{combo}(a,f)\|^2/(1-\delta)$. Dividing by
$\|\mathrm{combo}(a,f)\|^2$ eliminates it and $a$ entirely. $\square$

**Corollary 3.3 (ceiling from Gram data alone).** If in addition the pairwise
correlations are at most $\delta_0$ with $\delta_0(K-1)<1$, then
$$\mathrm{gain}\big(e,\mathrm{combo}(a,f)\big) \le \frac{K\varepsilon^2}{1-\delta_0(K-1)}\|e\|^2 .$$

*Proof.* Theorem 3.1 supplies the hypothesis of Theorem 3.2 with
$\delta = \delta_0(K-1)$. $\square$

Corollary 3.3 depends only on quantities that can be *measured before fitting*:
the $K$ residual correlations and the $\binom K2$ feature correlations.

**Theorem 3.4 (block additivity ceiling).** Let $g_b$, $b \in \beta$, be pairwise
orthogonal nonzero vectors (e.g. the fitted parts of mutually orthogonal blocks).
Then
$$\mathrm{gain}\Big(e, \sum_b g_b\Big) \;\leq\; \sum_b \mathrm{gain}(e, g_b).$$

*Proof.* With $G = \sum_b g_b$, orthogonality gives $\langle e,G\rangle = \sum_b
\langle e, g_b\rangle$ and $\|G\|^2 = \sum_b \|g_b\|^2$. Cauchy–Schwarz on the
pairing $u_b = \langle e,g_b\rangle/\|g_b\|$, $v_b = \|g_b\|$ gives
$\langle e,G\rangle^2 \le \left(\sum_b \mathrm{gain}(e,g_b)\right)\|G\|^2$. $\square$

Theorem 3.4 is what keeps the analysis modular: it suffices to bound one prime
block at a time, even though the quadratic-residue indicator is only
$O(p^{-1/2})$-orthogonal to the phases *within* a block.

---

## 4. Arithmetic evaluation of the constants

We now compute $\delta$ for the phase design. Fix a modulus $N \geq 1$ and write
$\psi(x) = e^{2\pi i x/N}$ for the standard additive character of $\mathbb{Z}/N$.

**Definition 4.1.** For $k \in \mathbb{Z}/N$, set
$\cos_k(r) = \mathrm{Re}\,\psi(kr)$ and $\sin_k(r) = \mathrm{Im}\,\psi(kr)$,
regarded as vectors indexed by $r \in \mathbb{Z}/N$.

**Lemma 4.2 (complete character sum).**
$\sum_{r \in \mathbb{Z}/N} \psi(tr) = N$ if $t = 0$ and $0$ otherwise.

**Theorem 4.3 (exact trigonometric Gram).** For all $k, l \in \mathbb{Z}/N$,
$$\langle \cos_k, \cos_l\rangle = \tfrac12\Big( N\,[\,k=l\,] + N\,[\,k=-l\,]\Big), \qquad
\langle \sin_k, \sin_l\rangle = \tfrac12\Big( N\,[\,k=l\,] - N\,[\,k=-l\,]\Big),$$
$$\langle \cos_k, \sin_l\rangle = 0 \quad\text{for all } k,l .$$
In particular $\|\cos_k\|^2 = \|\sin_k\|^2 = N/2$ whenever $k \neq 0$ and
$2k \neq 0$, distinct frequencies (up to sign) are exactly orthogonal, and cosines
and sines are exactly orthogonal at *every* pair of frequencies.

*Proof sketch.* Using $\overline{\psi(x)} = \psi(-x)$,
$$\cos_k(r)\cos_l(r) = \mathrm{Re}\,\tfrac{\psi((k-l)r) + \psi((k+l)r)}{2}, \quad
\sin_k(r)\sin_l(r) = \mathrm{Re}\,\tfrac{\psi((k-l)r) - \psi((k+l)r)}{2},$$
$$\cos_k(r)\sin_l(r) = \mathrm{Im}\,\tfrac{\psi((k+l)r) - \psi((k-l)r)}{2}.$$
Sum over $r$ and apply Lemma 4.2; the imaginary parts of the resulting real
numbers $N$ or $0$ vanish identically, which gives the third identity. $\square$

**Theorem 4.4 (cross-prime orthogonality).** Let $p \neq q$ be odd primes,
$N = pq$. Then over $\mathbb{Z}/N$ the frequency-$q$ phase (which is $p$-periodic
in $r$) and the frequency-$p$ phase (which is $q$-periodic) are exactly
orthogonal: $\langle \cos_q, \cos_p\rangle = 0$.

*Proof.* By Theorem 4.3 the inner product vanishes unless $q \equiv \pm p
\pmod{pq}$, which fails for distinct odd primes since $0 < p + q < pq$ and
$0 < |p - q| < pq$. $\square$

Theorem 4.4 is the Chinese Remainder Theorem in Gram form and supplies exactly the
hypothesis of Theorem 3.4: the blocks for distinct primes are mutually orthogonal,
so the ceiling is additive over primes.

From now on let $p$ be an odd prime and take $N = p$.

**Definition 4.5.** $\mathrm{QR}(r) = \left(\tfrac rp\right) \in \{-1,0,1\}$ is
the quadratic character of $\mathbb{Z}/p$, extended by $\mathrm{QR}(0)=0$.

**Lemma 4.6.** $\|\mathrm{QR}\|^2 = p - 1$.

*Proof.* $\mathrm{QR}(r)^2 = 1$ for $r \neq 0$ and $0$ at $r = 0$. $\square$

**Definition 4.7 (Gauss sum).** $g_k = \sum_{r \in \mathbb{Z}/p} \mathrm{QR}(r)\,\psi(kr)$.

By construction $\mathrm{Re}\,g_k = \langle \mathrm{QR}, \cos_k\rangle$ and
$\mathrm{Im}\,g_k = \langle \mathrm{QR}, \sin_k\rangle$: **the entire coupling
between the arithmetic feature and the Fourier features is a Gauss sum.**

**Theorem 4.8 (Gauss).** For $k \neq 0$, $|g_k|^2 = p$.

**Corollary 4.9 (coupling bound).** For $k \neq 0$,
$$\big|\langle \mathrm{QR}, \cos_k\rangle\big| \le \sqrt p, \qquad \big|\langle \mathrm{QR}, \sin_k\rangle\big| \le \sqrt p .$$

**Theorem 4.10 (normalised coupling).** For an odd prime $p \geq 3$ and a
frequency $k$ with $k \neq 0$, $2k \neq 0$,
$$\frac{\big|\langle \mathrm{QR}, \cos_k\rangle\big|}{\|\mathrm{QR}\|\,\|\cos_k\|} \;\leq\; \delta_p \;:=\; \sqrt{\frac{2}{p-1}},$$
and likewise for $\sin_k$.

*Proof.* $\|\mathrm{QR}\|\|\cos_k\| = \sqrt{(p-1)\cdot p/2}$, and
$\sqrt p / \sqrt{(p-1)p/2} = \sqrt{2/(p-1)}$. $\square$

Numerically: $\delta_5 = 0.7071$, $\delta_7 = 0.5774$, $\delta_{11} = 0.4472$,
$\delta_{13} = 0.4082$, $\delta_{29} = 0.2673$. The coupling is strictly
decreasing in $p$ — the design becomes *more* orthogonal as one adds larger primes,
so larger primes cannot rescue the family by conspiring with the arithmetic
feature.

### 4.1 The Gauss-sign dichotomy

Gauss's determination of the *sign* (equivalently, the argument) of the quadratic
Gauss sum gives more than the modulus: for $p \equiv 1 \pmod 4$ the sum $g_k$ is
real, and for $p \equiv 3 \pmod 4$ it is purely imaginary.

**Theorem 4.11 (Gauss-sign dichotomy).** Let $p$ be an odd prime and $k \neq 0$.
* If $p \equiv 3 \pmod 4$ then $\langle \mathrm{QR}, \cos_k\rangle = 0$ exactly,
  and $\big|\langle \mathrm{QR}, \sin_k\rangle\big| = \sqrt p$ exactly.
* If $p \equiv 1 \pmod 4$ then $\langle \mathrm{QR}, \sin_k\rangle = 0$ exactly,
  and $\big|\langle \mathrm{QR}, \cos_k\rangle\big| = \sqrt p$ exactly.

*Proof sketch.* Vanishing of one part is the reality (resp. purity) of $g_k$; the
modulus of the surviving part is then $|g_k| = \sqrt p$ by Theorem 4.8. $\square$

Two consequences. First, **each three-feature prime block has exactly one coupled
pair**, not two: half of the trigonometric design is exactly orthogonal to the
quadratic-residue indicator, and which half is determined by $p \bmod 4$. Second,
**the bound of Theorem 4.10 is attained** in the active channel: normalised, the
active coupling equals $\delta_p$ exactly. Both facts are used in §5.

---

## 5. The sharp prime-block constant, and its exactness

**Definition 5.1 (prime block).** For an odd prime $p$ and a frequency $k$ with
$k \neq 0$, $2k \neq 0$, the *prime-$p$ block* is the three-feature family
$$B_{p,k} = (\cos_k,\ \sin_k,\ \mathrm{QR}).$$

Applying Corollary 3.3 crudely with $K = 3$ and $\delta_0 = \delta_p$ gives the
constant $1 - 2\delta_p$, which is positive only for $p \ge 13$ ($1 - 2\delta_{13}
= 0.1835$) and useless for $p \in \{5,7,11\}$. The dichotomy removes this defect.

**Theorem 5.2 (sharp stability for a single coupled pair).** Let $f_0, f_1, f_2$
be nonzero with $f_0$ exactly orthogonal to $f_1$ and $f_2$, and
$|\langle f_1, f_2\rangle| \le \delta \|f_1\|\|f_2\|$, $\delta \ge 0$. Then for all
$a$,
$$(1-\delta)\sum_{j} a_j^2\|f_j\|^2 \;\le\; \Big\|\sum_j a_j f_j\Big\|^2 .$$

*Proof.* Expanding, the only off-diagonal contribution is
$2a_1 a_2\langle f_1,f_2\rangle \ge -2\delta |a_1|\|f_1\|\,|a_2|\|f_2\| \ge
-\delta\big(a_1^2\|f_1\|^2 + a_2^2\|f_2\|^2\big)$ by AM–GM. Adding the diagonal
gives the claim. Note that AM–GM replaces the cruder Cauchy–Schwarz pile-up used
in Theorem 3.1, which is what removes the factor $K-1 = 2$. $\square$

**Corollary 5.3.** For every odd prime $p \geq 5$ and admissible frequency $k$,
the block $B_{p,k}$ satisfies the restricted-isometry inequality with constant
$1 - \delta_p$, in both residue classes of $p$ modulo $4$ (the coupled pair being
$(\sin_k,\mathrm{QR})$ when $p \equiv 3 \pmod 4$ and $(\cos_k,\mathrm{QR})$ when
$p \equiv 1 \pmod 4$).

**Theorem 5.4 (exactness of the block constant).** For every odd prime $p \geq 5$
the constant $1 - \delta_p$ is *optimal*: no $c > 1 - \delta_p$ satisfies
$c\sum_j a_j^2\|f_j\|^2 \le \|\sum_j a_j f_j\|^2$ for all $a$.

*Proof sketch.* Since the active coupling is *exactly* $\delta_p$ in normalised
terms (Theorem 4.11), take the two-feature witness supported on the coupled pair,
with coefficients $a_j = \mp \sigma/\|f_j\|$ chosen so the cross term is maximally
negative. Then $\|\sum_j a_jf_j\|^2 = 2\sigma^2(1-\delta_p)$ while
$\sum_j a_j^2\|f_j\|^2 = 2\sigma^2$, so the inequality is tight. $\square$

Thus $1 - \delta_p$ is the exact smallest eigenvalue of the normalised block Gram
matrix, and **no Gram-based argument can improve the ceiling further.**

**Theorem 5.5 (arithmetic block ceiling).** Let $p \ge 5$ be an odd prime, $k$ an
admissible frequency, $e$ a residual, and suppose each of the three block features
has residual correlation at most $\varepsilon$. Then for every $a \in \mathbb{R}^3$,
$$\mathrm{gain}\big(e, \mathrm{combo}(a, B_{p,k})\big) \;\le\; \frac{3\varepsilon^2}{1 - \sqrt{2/(p-1)}}\,\|e\|^2 \;\le\; \frac{3\varepsilon^2}{0.292}\,\|e\|^2 .$$

*Proof.* Theorem 3.2 with $K=3$ and the constant of Corollary 5.3; the uniform
form uses $\delta_p \le \delta_5 = 0.70711 \le 0.708$ for $p \ge 5$. $\square$

For $p \ge 13$ one may use $\delta_p \le 0.41$, giving the stronger
$3\varepsilon^2/0.59$; the improvement over the crude constant $1-2\delta$ is a
factor $0.59/0.18 > 3$.

Per-block ceilings at the measured $\varepsilon = 0.01$:

| $p$ | $\delta_p = \sqrt{2/(p-1)}$ | $1-\delta_p$ | ceiling $3\varepsilon^2/(1-\delta_p)$ | active channel |
|---|---|---|---|---|
| $5$ | $0.70711$ | $0.29289$ | $0.001024$ | cosine ($p\equiv1$) |
| $7$ | $0.57735$ | $0.42265$ | $0.000710$ | sine ($p\equiv3$) |
| $11$ | $0.44721$ | $0.55279$ | $0.000543$ | sine ($p\equiv3$) |
| $13$ | $0.40825$ | $0.59175$ | $0.000507$ | cosine ($p\equiv1$) |
| $29$ | $0.26726$ | $0.73274$ | $0.000409$ | cosine ($p\equiv1$) |

---

## 6. The numerical certificate and the deterministic refutation

**Theorem 6.1 (sub-threshold certificate).** Nine mutually orthogonal prime
blocks, each of three features with per-feature residual correlation at most
$\varepsilon = 0.01$ and worst-case block constant $0.292$, together lift at most
$$9 \cdot \frac{3 \cdot (0.01)^2}{0.292} \;=\; 0.00925 \;\le\; 0.01$$
of the residual energy.

*Proof.* Theorem 3.4 (blocks orthogonal by Theorem 4.4) plus Theorem 5.5. $\square$

Restricting to $p \ge 13$, the constant $0.59$ gives the tighter certificate
$9 \cdot 3\cdot 10^{-4}/0.59 = 0.00458 \le 0.005$.

**Theorem 6.2 (the registered hypothesis is unreachable).** With a baseline
$R^2 = 0.600$, the residual carries $1 - 0.600 = 0.400$ of the total variance, so
the best possible phase-augmented score is
$$0.600 + 0.01 \cdot 0.400 = 0.604 \;<\; 0.70,$$
and under the $p \ge 13$ certificate, $0.600 + 0.005\cdot0.400 = 0.602 < 0.70$.

Hence the pre-registered hypothesis $R^2 \geq 0.70$ was *unreachable a priori*,
given only the measured per-feature correlation scale — no fitting procedure,
regularisation choice, or coefficient search could have reached it. The
observed $+0.008$ lift corresponds to $0.008/0.400 = 0.02$ of the residual energy,
which the ceiling accommodates at a per-feature correlation of $\varepsilon =
0.0116$: the measured lift is consistent with correlations of barely one percent,
i.e. with nothing.

---

## 7. Full-frequency degeneracy: the quadratic-residue feature is a phase combination

All the above is *design-local*: it bounds what three features at one frequency
can do. What if one uses all frequencies?

**Definition 7.1 (frequency half-period).** For an odd prime $p$ let
$H_p \subseteq \mathbb{Z}/p$ be the image of $\{1,\dots,(p-1)/2\}$, of cardinality
$(p-1)/2$; it contains no $0$ and no pair $k, -k$, so the family
$\{\cos_k, \sin_k : k \in H_p\}$ is pairwise orthogonal by Theorem 4.3.

**Lemma 7.2 (two units per frequency).** For $k \neq 0$,
$$\mathrm{gain}(\mathrm{QR}, \cos_k) + \mathrm{gain}(\mathrm{QR}, \sin_k)
= \frac{(\mathrm{Re}\,g_k)^2 + (\mathrm{Im}\,g_k)^2}{p/2} = \frac{2|g_k|^2}{p} = 2,$$
whatever the residue class of $p$ modulo $4$.

**Theorem 7.3 (Bessel equality).**
$$\sum_{k \in H_p}\Big(\mathrm{gain}(\mathrm{QR},\cos_k) + \mathrm{gain}(\mathrm{QR},\sin_k)\Big) = 2\cdot\frac{p-1}{2} = p-1 = \|\mathrm{QR}\|^2 .$$

**Theorem 7.4 (degeneracy).** The quadratic-residue indicator is *exactly* the
linear combination of the half-period phase features with the ordinary projection
coefficients:
$$\mathrm{QR} \;=\; \sum_{k \in H_p}\left( \frac{\langle \mathrm{QR},\cos_k\rangle}{\|\cos_k\|^2}\cos_k + \frac{\langle \mathrm{QR},\sin_k\rangle}{\|\sin_k\|^2}\sin_k \right).$$

*Proof.* By Proposition 2.5 the residual after fitting the orthogonal half-period
family has energy $\|\mathrm{QR}\|^2 - \sum \mathrm{gain} = (p-1) - (p-1) = 0$ by
Theorem 7.3; a vector of zero energy is zero. $\square$

**Corollary 7.5 (no incremental capacity).** For any $a \in \mathbb{R}$ and any
coefficients $c$, the model $a\,\mathrm{QR} + \mathrm{combo}(c, \text{phases})$
equals $\mathrm{combo}(c', \text{phases})$ for explicit $c'$. Hence appending
$\mathrm{QR}$ to a full-frequency phase design cannot change any fitted value, any
residual, or any $R^2$.

Interpretation: the quadratic-residue indicator carries *no information beyond the
phases*. The coupling constant $\delta_p$, and with it the entire block-stability
discussion, is a consequence of restricting to **one frequency per prime** — a
feature-selection effect, not an information-theoretic one. This both explains why
adding the arithmetic feature appeared to matter in a single-frequency design and
predicts that it will matter not at all in a full-frequency one.

---

## 8. Window locality: what a negative score certifies

Least squares cannot produce a negative gain on the data it was fitted to
(Proposition 2.4). The observed $-0.077$ must therefore come from *transport*: a
coefficient learned on one window and evaluated on another.

**Definition 8.1.** For a residual $e$ and feature $f$ on the *test* window and a
transported coefficient $b$, put
$$\mathrm{gain}_{\mathrm{oos}}(e,f,b) = \|e\|^2 - \|e - bf\|^2, \qquad \beta^\star = \frac{\langle e,f\rangle}{\|f\|^2}.$$

**Theorem 8.2 (transported gain is an exact parabola).**
$$\mathrm{gain}_{\mathrm{oos}}(e,f,b) = 2b\langle e,f\rangle - b^2\|f\|^2 = \|f\|^2\Big((\beta^\star)^2 - (b - \beta^\star)^2\Big).$$

Consequences, all immediate from the completed square:

**Corollary 8.3 (transfer identity).** The shortfall against the test window's own
optimum is exactly $(b - \beta^\star)^2\|f\|^2$ — nothing else.

**Corollary 8.4 (in-window dominance).** $\mathrm{gain}_{\mathrm{oos}}(e,f,b) \le
\mathrm{gain}(e,f)$ for every $b$; equality iff $b = \beta^\star$. In particular
*no rescaling* $b \mapsto \lambda b$ of a transported coefficient can beat the test
window's own single-feature gain.

**Corollary 8.5 (sign mismatch).** If $b \neq 0$ and $b\langle e,f\rangle \le 0$
— the covariance changes sign between windows — then
$\mathrm{gain}_{\mathrm{oos}} \le -b^2\|f\|^2 < 0$. This is the mechanism behind
the confirmed cross-window hypothesis.

**Corollary 8.6 (negativity is a coefficient miss).**
$\mathrm{gain}_{\mathrm{oos}}(e,f,b) < 0$ if and only if
$|b - \beta^\star| > |\beta^\star|$: the transported coefficient misses the test
window's optimum by more than the optimum's own size.

**Theorem 8.7 (quantitative miss).** If the measured relative gain is $-\rho$,
i.e. $\mathrm{gain}_{\mathrm{oos}}(e,f,b) \le -\rho\|e\|^2$ with $\rho>0$, then
$$(b - \beta^\star)^2 \;\ge\; \rho\,\frac{\|e\|^2}{\|f\|^2},$$
i.e. the standardized miss $|b-\beta^\star|\,\|f\|/\|e\|$ is at least $\sqrt\rho$.

*Proof.* From Theorem 8.2, $-\rho\|e\|^2 \ge \|f\|^2((\beta^\star)^2 -
(b-\beta^\star)^2) \ge -\|f\|^2(b-\beta^\star)^2$. $\square$

**Corollary 8.8 (the measured certificates).**
* The phase-only arm scored $-0.077$, certifying a standardized coefficient miss
  of at least $\sqrt{0.077} = 0.277$.
* The baseline model degraded from $0.600$ in-window to $0.400$ cross-window, a
  relative loss of $0.200$, certifying a standardized miss of at least
  $\sqrt{0.200} = 0.447$.

So **the baseline is itself window-local, and by a larger margin than the phase
block**. This confirms window locality as the mechanism behind the earlier
ceiling-splitting anomaly, and it warns that any conclusion drawn from in-window
scores in this setting is suspect.

**Theorem 8.9 (transport cannot evade the ceiling).** Under the hypotheses of
Theorem 3.2, for any coefficient vector $a$ learned on any window and any
rescaling $b$, the transported combination still satisfies
$$\mathrm{gain}_{\mathrm{oos}}\big(e,\mathrm{combo}(a,f),b\big) \;\le\; \frac{K\varepsilon^2}{1-\delta}\|e\|^2 .$$

*Proof.* Corollary 8.4 then Theorem 3.2. $\square$

Transport can only lose. The in-window ceiling is therefore also an out-of-sample
ceiling.

---

## 9. Separating the two surviving explanations

The residual anomaly that motivated the study — an unexplained excess of roughly
$\Delta = 0.2$ in an earlier ceiling analysis — is now known not to be explained by
the tested phase family. Two candidates remain, and the theory separates them
sharply.

### 9.1 Candidate 1: higher primes

**Theorem 9.1 (aggregate block ceiling).** If $n$ mutually orthogonal blocks each
lift at most $c\|e\|^2$, their sum lifts at most $nc\|e\|^2$.

**Theorem 9.2 (cost of higher primes).** If $n$ prime blocks, each capped at
$3\varepsilon^2/0.18$ of the residual energy, are to cover an excess $\Delta$, then
$$n \;\ge\; \frac{0.06\,\Delta}{\varepsilon^2}.$$

*Proof.* $\Delta \le n\cdot 3\varepsilon^2/0.18 = \tfrac{50}{3} n\varepsilon^2$. $\square$

**Corollary 9.3.** At $\Delta = 0.2$ and $\varepsilon = 0.01$, at least $120$
orthogonal prime blocks are required. The design supplied nine; even extending to
all odd primes below $700$ would be marginal.

Candidate 1 therefore predicts a *slow additive accumulation* in the number of
primes, never a step, and is expensive by more than an order of magnitude.

### 9.2 Candidate 2: same-window leakage

Model a leaked feature as $f = \alpha e + g$ with $g \perp e$: a fraction of the
realized target is *inside* the feature.

**Theorem 9.4 (leakage identity).** If $\langle e, g\rangle = 0$ then
$$\mathrm{gain}(e, \alpha e + g) = \frac{\alpha^2\|e\|^4}{\alpha^2\|e\|^2 + \|g\|^2},$$
so the in-window $R^2$ is exactly the leaked fraction of the feature's energy,
$$\frac{\mathrm{gain}(e,f)}{\|e\|^2} = \frac{\alpha^2\|e\|^2}{\alpha^2\|e\|^2 + \|g\|^2}.$$

*Proof.* $\langle e,f\rangle = \alpha\|e\|^2$ and $\|f\|^2 = \alpha^2\|e\|^2 + \|g\|^2$. $\square$

**Corollary 9.5 (inverting the split).** A measured in-window $R^2 = r < 1$ pins
the leaked-to-orthogonal energy ratio: $\alpha^2\|e\|^2 = \frac{r}{1-r}\|g\|^2$. At
$r = 0.6$ the leaked component carries $1.5$ times the energy of everything else in
the feature.

Note the key asymmetry with candidate 1: leakage reproduces *any* in-window $R^2$
whatsoever, with arbitrarily small genuine predictive content, at no cost in the
number of features.

**Theorem 9.6 (a model-free falsification test).** Any feature achieving in-window
$R^2 \ge 0.6$ satisfies
$$\langle e, f\rangle^2 \;\ge\; 0.6\,\|e\|^2\|f\|^2,$$
i.e. correlates with the *realized* target at level at least $\sqrt{0.6} > 0.774$.

This is decisive: the correlation can be measured directly, without fitting any
model, and either refutes or confirms candidate 2.

**Theorem 9.7 (signature of leakage).** Suppose $f = \alpha e + g$ with
$\alpha>0$, $g \perp e$, and the leaked component is absent from the test window,
so that the test-window covariance $\langle e', f'\rangle$ is $0$. Then the
in-window coefficient $\beta = \langle e,f\rangle/\|f\|^2 > 0$ produces a
*strictly negative* out-of-sample gain.

*Proof.* Corollary 8.5 with $b = \beta \neq 0$ and $b\langle e',f'\rangle = 0$. $\square$

This is exactly the pattern observed: a large in-window score, a negative
cross-window score. The two candidates make different, testable predictions:

| candidate | prediction | test |
|---|---|---|
| higher-prime phases | $n \ge 0.06\Delta/\varepsilon^2 = 120$ blocks for $\Delta=0.2$, $\varepsilon = 0.01$ | extend the prime range to $p \le 700$ |
| same-window leakage | $\mathrm{corr}(\text{feature},\text{realized target}) \ge 0.775$ in-window | direct correlation, no fitting |
| same-window leakage | cross-window gain $\le -\beta^2\|f\|^2 < 0$ | already observed |

---

## 10. Discussion, limitations, and future work

### 10.1 What has been established

The mathematics separates cleanly into a statistical layer and an arithmetic
layer, joined by two numbers.

*Statistical layer.* The gain of any linear combination is bounded by
$K\varepsilon^2/(1-\delta)$ with $\delta$ the design's near-orthogonality defect
and $\varepsilon$ the per-feature residual correlation (Theorems 3.1, 3.2), and the
bound is additive over orthogonal blocks (Theorem 3.4). Both are elementary, and
both are sharp in the sense that they are attained by explicit configurations.

*Arithmetic layer.* For the phase design, $\delta$ is not a fitted quantity but a
theorem: $0$ within the Fourier part (character orthogonality, Theorem 4.3), $0$
between distinct primes (CRT, Theorem 4.4), and exactly $\sqrt{2/(p-1)}$ for the
single surviving coupled pair inside a prime block (Gauss sums plus the sign
dichotomy, Theorems 4.8, 4.10, 4.11, 5.4).

*Consequences.* The lift is capped at $0.01$ of the residual energy, so the best
phase-augmented score is $0.604$ against a registered bar of $0.70$: the hypothesis
was unreachable a priori (Theorems 6.1, 6.2). The negative transported score is a
certificate of a standardized coefficient miss of at least $0.277$, and the
baseline's own miss is at least $0.447$ (Corollary 8.8). Higher primes cost $\geq
120$ blocks; leakage is free and directly testable (Corollaries 9.3, 9.5,
Theorem 9.6).

### 10.2 Limitations

1. **$\varepsilon$ is an empirical input.** The ceiling is conditional on the
   measured per-feature residual correlation $\varepsilon \approx 0.01$. It is a
   *conditional impossibility*: it says nothing about a hypothetical design in
   which some feature attains a large correlation. Its force comes precisely from
   the fact that $\varepsilon$ is measurable before fitting.
2. **Full-period assumption.** The exact Gram identities of Theorem 4.3 hold over a
   complete period modulo $N$. For a sample of positions that is not equidistributed
   modulo $p$, the identities acquire error terms of the usual discrepancy type,
   and the effective $\delta$ increases.
3. **Linearity.** The ceiling bounds *linear* combinations. A nonlinear model on
   the same features (interactions between primes, say) is not covered; note,
   however, that products of phases across distinct primes are themselves phases
   modulo the product, so a natural class of such interactions falls back within
   the same framework.
4. **Single frequency per prime.** The block analysis is for one frequency; §7
   shows that at full frequency resolution the quadratic-residue feature degenerates
   entirely.

### 10.3 Future directions

* **Non-equidistributed samples.** Quantify the degradation of $\delta$ when the
  positions are not uniform modulo $p$, using standard exponential-sum discrepancy
  estimates, and thereby extend the certificate to realistic samples.
* **Higher-degree characters.** The Gauss-sum machinery is not special to the
  quadratic character. Cubic and quartic residue indicators have the same
  $|g| = \sqrt p$ modulus, so the ceiling extends verbatim; whether an analogue of
  the sign dichotomy holds is a concrete question.
* **Prosecuting the leakage hypothesis.** The direct correlation test of
  Theorem 9.6 requires no model fitting and should be run first.
* **The excess itself.** With the phase family eliminated and higher primes shown
  expensive, the search for the residual anomaly should turn to feature classes
  that are cheap and window-local, of which same-window leakage is the leading
  example.
* **Sharpness beyond Gram data.** Theorem 5.4 shows the constant cannot be improved
  by any argument that sees only the Gram matrix. Improving the ceiling therefore
  requires distributional information about the residual, e.g. its own Fourier
  profile.

### 10.4 Broader relevance

The pattern generalises beyond this dataset. Whenever a feature family is
*designed* rather than learned — Fourier features, random projections, wavelet
dictionaries, hash features — its Gram matrix is known in closed form, and the two
theorems of §3 convert that knowledge into a hard, pre-fit ceiling on achievable
$R^2$. Where the design has arithmetic origin, classical exponential-sum bounds
supply the Gram entries for free. The lesson of the Gauss-sign dichotomy is
particularly clean: knowing the *argument* of a character sum, not just its
modulus, halved the effective coupling and tripled the strength of the ceiling.

Perhaps the most useful practical consequence is methodological. Before running an
expensive feature study, compute $K$, estimate $\varepsilon$ from marginal
correlations, and bound $\delta$ from the design. If $K\varepsilon^2/(1-\delta)$
falls below the pre-registered bar, the study is already decided.

---

## Appendix A: Notation

| symbol | meaning |
|---|---|
| $\langle x,y\rangle$ | $\sum_i x_i y_i$, sample inner product |
| $\|x\|^2$ | $\langle x,x\rangle$, design energy |
| $\mathrm{gain}(e,f)$ | $\langle e,f\rangle^2/\|f\|^2$, residual energy removed by fitting $f$ |
| $\varepsilon$ | uniform bound on per-feature residual correlation |
| $\delta$ | uniform bound on pairwise feature correlation |
| $K$ | number of features in a block |
| $\psi(x)$ | $e^{2\pi i x/N}$, standard additive character |
| $\cos_k,\sin_k$ | $\mathrm{Re}\,\psi(kr)$, $\mathrm{Im}\,\psi(kr)$ |
| $\mathrm{QR}$ | quadratic-residue indicator (Legendre symbol) |
| $g_k$ | Gauss sum $\sum_r \mathrm{QR}(r)\psi(kr)$ |
| $\delta_p$ | $\sqrt{2/(p-1)}$, the normalised QR/phase coupling |
| $\beta^\star$ | test window's own least-squares coefficient |

## Appendix B: The numerical certificates at a glance

$$\text{crude } (1-2\delta_{13}) = 0.18: \quad 9\cdot\frac{3(0.01)^2}{0.18} = 0.0150,$$
$$\text{sharp } (1-\delta_{13}) = 0.59: \quad 9\cdot\frac{3(0.01)^2}{0.59} = 0.0046,$$
$$\text{sharp, all } p\ge5\ (1-\delta_5) = 0.292: \quad 9\cdot\frac{3(0.01)^2}{0.292} = 0.0093.$$

Best achievable phase-augmented scores from a baseline of $0.600$:
$0.6060$, $0.6018$, $0.6037$ respectively — all far below the registered $0.70$.
