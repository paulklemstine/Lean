# Critical Exponents of the $O(N)$ Model, Uniformly in the Symmetry Index

**Author:** Aristotle

**Date:** 2026-09-03

---

## Abstract

We develop the leading-order $\varepsilon$-expansion of the $O(N)$-symmetric $\varphi^4$ theory in $d = 4-\varepsilon$ dimensions with the symmetry index $N$ carried as a free real parameter throughout, rather than fixed to one of the classical values $N=0,1,2,3$. All diagrammatic data enter through a single one-loop beta function $\beta_N(\varepsilon,g) = -\varepsilon g + \tfrac{N+8}{3}g^2$, whose zero set we classify completely for all $N \neq -8$: exactly the Gaussian coupling $g=0$ and the Wilson–Fisher coupling $g^* = 3\varepsilon/(N+8)$.

From this we obtain the standard first terms of the critical exponents as explicit rational functions of $N$,
$$\eta = \frac{(N+2)\varepsilon^2}{2(N+8)^2},\quad \nu = \frac12 + \frac{(N+2)\varepsilon}{4(N+8)},\quad \gamma = 1 + \frac{(N+2)\varepsilon}{2(N+8)},$$
$$\alpha = \frac{(4-N)\varepsilon}{2(N+8)},\quad \beta = \frac12 - \frac{3\varepsilon}{2(N+8)},\quad \delta = 3+\varepsilon,\quad \omega = \varepsilon,$$
each reducing at $N=1$ to Wilson's one-component values, and we prove a family of statements that are *uniform on the admissible range* $N \ge 0$ (and in most cases on the full formal range $N > -8$).

The principal structural results are: (i) the $\varepsilon^2$-coefficient of the anomalous dimension is maximised exactly at $N=4$, with value $1/48$, whence the $N$-free bound $0 < \eta \le \varepsilon^2/48$; (ii) the specific-heat exponent changes sign exactly at $N=4$; (iii) $\omega = \partial_g\beta_N|_{g^*} = \varepsilon$ for every $N$, and the Gaussian and Wilson–Fisher points exchange stability at $\varepsilon = 0$ independently of $N$; (iv) Rushbrooke's relation $\alpha + 2\beta + \gamma = 2$ holds *identically* in $(N,\varepsilon)$, while Fisher's, Widom's and Josephson's relations hold with deficits computed in closed form — the Widom deficit being $3\varepsilon^2/(N+8-3\varepsilon)$, with $N$-independent numerator; (v) the $N\to\infty$ limits reproduce the exactly solvable spherical model with explicit $O(\varepsilon^2)$ error bounds; (vi) the discrete infrared flow converges to $g^*$ from any start in $(0,g^*)$, with an $N$-uniform basin and $N$-uniform admissible step sizes; and (vii) at two loops the non-Gaussian fixed point exists and satisfies $g^* = 3\varepsilon/(N+8) + 27c\varepsilon^2/(N+8)^3 + O(\varepsilon^3)$ with an $N$-independent remainder constant, obtained from a scheme-independent quadratic-root estimate rather than from formal power series.

A unifying principle emerges: at first order the exponent vector lies on an affine line in exponent space parameterised by $\nu$, so every scaling relation affine in the exponents is exact, and every nonlinear relation acquires a deficit equal to its second-order Taylor term along that line.

**Keywords.** $O(N)$ model, $\varepsilon$-expansion, Wilson–Fisher fixed point, critical exponents, renormalisation group, scaling relations, spherical model, anomalous dimension.

---

## 1. Introduction

### 1.1 Universality and its residual parameters

A continuous phase transition is characterised by a divergent correlation length and by power-law singularities in the thermodynamic observables. The exponents of those power laws are *universal*: they are insensitive to almost all microscopic details of the system, depending only on the spatial dimension $d$ and on the symmetry of the order parameter. The liquid–vapour critical point of a simple fluid and the Curie point of a uniaxial ferromagnet, physically unrelated, share the same exponents.

The symmetry data is captured by an integer $N$, the number of components of the order-parameter field, and by the group $O(N)$ acting on them. The classical members of the family are

| $N$ | Universality class | Physical realisation |
|---|---|---|
| $0$ | Self-avoiding walk | Long polymer in solution |
| $1$ | Ising | Uniaxial magnet, simple fluid, binary alloy |
| $2$ | XY | Superfluid $^4$He, planar magnet |
| $3$ | Heisenberg | Isotropic ferromagnet |
| $\infty$ | Spherical | Exactly solvable limit |

Most treatments compute exponents at a fixed $N$. The purpose of this work is to carry $N$ as a *free real parameter* through the entire computation and to prove statements that hold uniformly on the admissible range. This exposes structure that no single value can reveal: extrema in $N$, sign changes in $N$, exact limiting behaviour, and a precise account of which thermodynamic identities the truncated exponents respect.

### 1.2 The $\varepsilon$-expansion

The technical device is Wilson's. In $d = 4$ the $\varphi^4$ interaction is marginal, and the exponents take mean-field values; in $d < 4$ it is relevant. Setting $d = 4-\varepsilon$ and treating $\varepsilon$ as an infinitesimal makes the non-trivial fixed point of the renormalisation-group flow lie at a coupling of order $\varepsilon$, hence within reach of perturbation theory. All quantities are then obtained as power series in $\varepsilon$, and one evaluates at $\varepsilon = 1$ for three dimensions.

We do not re-derive the Feynman-diagram combinatorics. Instead we isolate its output — a small number of polynomial coefficients, now rational functions of $N$ — and study rigorously everything that follows from it.

### 1.3 Organisation

Section 2 fixes definitions and the normalisation. Section 3 classifies the fixed points and establishes stability. Section 4 records the exponents and their reduction at $N=1$. Section 5 proves the uniform-in-$N$ statements: the extremum at $N=4$, monotonicity, uniform bounds, the sign flip of $\alpha$, and the Gaussian locus $N=-2$. Section 6 treats the large-$N$ limit and the spherical-model cross-check. Section 7 analyses the scaling relations and formulates the linearity principle. Section 8 treats the dynamics of the discrete flow. Section 9 goes to two loops with quantitative, $N$-uniform control. Section 10 discusses applications, limitations, and open directions.

---

## 2. Setup and normalisation

### 2.1 Admissible range

**Definition 2.1 (Admissible symmetry index).** A real number $N$ is *admissible* if $N \ge 0$.

Admissibility is what the physical family requires ($N = 0,1,2,3,\dots$ and their interpolations), and it is the hypothesis under which all uniform bounds below are stated. Many results, however, hold on the wider formal range $N > -8$, and we state them there when they do. The only genuinely excluded point is $N = -8$, where the one-loop quadratic coefficient vanishes and the fixed point escapes to infinity.

**Lemma 2.2.** If $N$ is admissible then $N + 8 > 0$; in particular $N + 8 \neq 0$.

*Proof.* Immediate from $N \ge 0$. $\square$

### 2.2 The one-loop flow

**Definition 2.3 (One-loop beta function).** For real $N, \varepsilon, g$,
$$\beta_N(\varepsilon, g) \;:=\; -\varepsilon\, g \;+\; \frac{N+8}{3}\, g^2 .$$

The normalisation is chosen so that at $N=1$ the quadratic coefficient is $3$, the standard one-component convention. The linear term is dimensional analysis; the coefficient $N+8$ of the quadratic term is the one-loop symmetry factor of the $O(N)$ vertex, decomposing as $N$ (an internal index loop) $+\,8$ (the two remaining channel pairings, with multiplicity).

**Definition 2.4 (Wilson–Fisher coupling).** $\displaystyle g^*(N,\varepsilon) \;:=\; \frac{3\varepsilon}{N+8}$.

**Definition 2.5 (Coupling-dependent exponent functions).**
$$\eta(N,g) := \frac{N+2}{18}\,g^2, \qquad \frac{1}{\nu}(N,g) := 2 - \frac{N+2}{3}\,g .$$

These are the two-loop anomalous dimension and the one-loop inverse correlation-length exponent as functions of the running coupling; both are ordinary polynomials in $g$ with $N$-dependent coefficients.

### 2.3 Reduction to the one-component theory

**Proposition 2.6.** At $N=1$: $\beta_1(\varepsilon,g) = -\varepsilon g + 3g^2$, $g^*(1,\varepsilon) = \varepsilon/3$, and $\eta(1,g) = g^2/6$.

*Proof.* Direct substitution. $\square$

This is the consistency check that the $N$-parameterised normalisation specialises to the classical one-component conventions, so that all results below genuinely generalise the Ising case.

---

## 3. Fixed points and stability

### 3.1 Complete classification

**Theorem 3.1 (Classification of one-loop fixed points).** Let $N \neq -8$ and let $\varepsilon, g$ be real. Then
$$\beta_N(\varepsilon, g) = 0 \iff g = 0 \ \text{ or } \ g = g^*(N,\varepsilon).$$

*Proof sketch.* Factor $\beta_N(\varepsilon,g) = g\big({-\varepsilon} + \tfrac{N+8}{3}g\big)$. A product of reals vanishes iff a factor does. The second factor vanishes iff $\tfrac{N+8}{3}g = \varepsilon$, and since $N+8 \neq 0$ this is exactly $g = 3\varepsilon/(N+8)$. Conversely both values are checked to be zeros by substitution and clearing denominators. $\square$

There is no third fixed point, formal or otherwise: the truncated flow has exactly the Gaussian and Wilson–Fisher solutions, for every admissible $N$ and every $\varepsilon$ including $\varepsilon = 0$ (where they coincide).

### 3.2 Positivity and uniform bounds on the fixed-point coupling

**Theorem 3.2 (Positivity and $N$-uniform bound).** Let $N \ge 0$ and $\varepsilon > 0$. Then
$$0 < g^*(N,\varepsilon) \le \frac{3\varepsilon}{8}.$$

*Proof sketch.* Positivity is immediate from $\varepsilon > 0$ and $N + 8 > 0$. For the bound, compute the exact difference
$$\frac{3\varepsilon}{8} - g^*(N,\varepsilon) = \frac{3\varepsilon N}{8(N+8)},$$
which is non-negative for $N \ge 0$ and $\varepsilon > 0$. $\square$

The upper bound is attained exactly at $N=0$; the constant $3/8$ is independent of $N$, which is the sense in which the whole family is *uniformly weakly coupled* at criticality for small $\varepsilon$.

**Theorem 3.3 (Monotonicity in $N$).** For $0 \le N_1 < N_2$ and $\varepsilon > 0$,
$$g^*(N_2,\varepsilon) < g^*(N_1,\varepsilon).$$

*Proof sketch.* $g^*(N_1,\varepsilon) - g^*(N_2,\varepsilon) = 3\varepsilon(N_2-N_1)/\big((N_1+8)(N_2+8)\big) > 0$. $\square$

Physically: more symmetry means a weaker fixed-point coupling, decaying like $3\varepsilon/N$ as $N \to \infty$. This is the mechanism behind both the vanishing of the anomalous dimension at large $N$ (Section 6) and the $N$-uniformity of the two-loop remainder (Section 9).

### 3.3 The slope of the flow and the exponent $\omega$

**Lemma 3.4 (Differentiability).** For all $N, \varepsilon, g_0$, the map $g \mapsto \beta_N(\varepsilon,g)$ is differentiable at $g_0$ with derivative $-\varepsilon + 2\tfrac{N+8}{3}g_0$.

*Proof sketch.* Sum of the derivative of a linear map and of a constant multiple of $g \mapsto g^2$. $\square$

**Theorem 3.5 (Universality of $\omega$ at one loop).** For every $N \neq -8$ and every $\varepsilon$,
$$\frac{\partial \beta_N}{\partial g}\Big|_{g = g^*(N,\varepsilon)} \;=\; \varepsilon .$$

*Proof sketch.* Substitute $g^* = 3\varepsilon/(N+8)$ into Lemma 3.4: $-\varepsilon + 2\cdot\tfrac{N+8}{3}\cdot\tfrac{3\varepsilon}{N+8} = -\varepsilon + 2\varepsilon = \varepsilon$. $\square$

The slope of the beta function at the infrared-stable fixed point *is* the correction-to-scaling exponent $\omega$, which governs the leading approach of finite-size or finite-$|T-T_c|$ data to the asymptotic critical form. Theorem 3.5 therefore says $\omega = \varepsilon + O(\varepsilon^2)$ for the entire $O(N)$ family at once. Every trace of the symmetry index has cancelled — the $(N+8)$ in the beta-function coefficient against the $(N+8)^{-1}$ in the fixed point.

**Theorem 3.6 (Exchange of stability).** For $N \neq -8$ and $\varepsilon > 0$,
$$\frac{\partial\beta_N}{\partial g}\Big|_{g=0} = -\varepsilon < 0 \quad\text{and}\quad \frac{\partial\beta_N}{\partial g}\Big|_{g=g^*} = \varepsilon > 0 .$$

*Proof sketch.* The first from Lemma 3.4 at $g_0 = 0$; the second from Theorem 3.5. $\square$

Under the infrared flow (the direction of decreasing momentum scale, i.e. $-\beta$), a positive slope means attraction and a negative slope means repulsion. Thus below four dimensions the Gaussian fixed point is unstable and the Wilson–Fisher fixed point is stable, and the crossover happens at $\varepsilon = 0$ regardless of $N$.

---

## 4. The critical exponents at first non-trivial order

### 4.1 Definitions

**Definition 4.1.** For $N \neq -8$ set
$$\eta(N,\varepsilon) := \frac{(N+2)\varepsilon^2}{2(N+8)^2}, \qquad \nu(N,\varepsilon) := \frac12 + \frac{(N+2)\varepsilon}{4(N+8)}, \qquad \gamma(N,\varepsilon) := 1 + \frac{(N+2)\varepsilon}{2(N+8)},$$
$$\alpha(N,\varepsilon) := \frac{(4-N)\varepsilon}{2(N+8)}, \qquad \beta_{\mathrm{op}}(N,\varepsilon) := \frac12 - \frac{3\varepsilon}{2(N+8)}, \qquad \delta(\varepsilon) := 3+\varepsilon, \qquad \omega(\varepsilon) := \varepsilon .$$

(We write $\beta_{\mathrm{op}}$ for the order-parameter exponent to avoid collision with the beta function.) The exponents are, respectively: the anomalous dimension of the two-point function at criticality; the correlation-length exponent; the susceptibility exponent; the specific-heat exponent; the order-parameter exponent; the critical-isotherm exponent; and the correction-to-scaling exponent.

### 4.2 Derivation from the fixed point

**Theorem 4.2 (Anomalous dimension at the fixed point).** For $N \neq -8$,
$$\eta\big(N, g^*(N,\varepsilon)\big) \;=\; \frac{N+2}{18}\left(\frac{3\varepsilon}{N+8}\right)^2 \;=\; \frac{(N+2)\varepsilon^2}{2(N+8)^2} \;=\; \eta(N,\varepsilon).$$

*Proof sketch.* Substitute and simplify: $\tfrac{N+2}{18}\cdot\tfrac{9\varepsilon^2}{(N+8)^2} = \tfrac{(N+2)\varepsilon^2}{2(N+8)^2}$. $\square$

**Theorem 4.3 (Inverse correlation-length exponent).** For $N \neq -8$,
$$\frac1\nu\big(N,g^*(N,\varepsilon)\big) \;=\; 2 - \frac{(N+2)\varepsilon}{N+8}.$$

*Proof sketch.* $2 - \tfrac{N+2}{3}\cdot\tfrac{3\varepsilon}{N+8}$. $\square$

The listed $\nu$ is the truncation of the reciprocal of this expression, and one can quantify the truncation exactly:

**Theorem 4.4 (Reciprocality defect).** For $N \neq -8$,
$$\nu(N,\varepsilon)\cdot \frac1\nu\big(N,g^*(N,\varepsilon)\big) \;=\; 1 - \frac{(N+2)^2\varepsilon^2}{4(N+8)^2}.$$

*Proof sketch.* Writing $u = (N+2)\varepsilon/(2(N+8))$, the product is $(\tfrac12 + \tfrac{u}{2})(2 - 2u) = 1 - u^2$. $\square$

So $\nu$ and $1/\nu$ are reciprocal up to a defect of order $\varepsilon^2$, precisely the order beyond which the one-loop truncation is not claimed to be valid. The defect $u^2 = \tfrac{(N+2)^2\varepsilon^2}{4(N+8)^2}$ is itself a clean rational function of $N$, increasing to $\varepsilon^2/4$ as $N \to \infty$.

### 4.3 Specialisation at $N=1$

**Proposition 4.5.** At $N = 1$:
$$\eta = \frac{\varepsilon^2}{54}, \qquad \nu = \frac12 + \frac{\varepsilon}{12}, \qquad \gamma = 1 + \frac{\varepsilon}{6}, \qquad \alpha = \frac{\varepsilon}{6}, \qquad \beta_{\mathrm{op}} = \frac12 - \frac{\varepsilon}{6}.$$

*Proof sketch.* Substitute $N=1$, so $N+2 = 3$, $N+8 = 9$, $4-N = 3$. $\square$

These are Wilson's classical one-component values. At $\varepsilon = 1$ they give $\nu \approx 0.583$, $\gamma \approx 1.167$, $\eta \approx 0.0185$, against the best three-dimensional Ising estimates $\nu \approx 0.630$, $\gamma \approx 1.237$, $\eta \approx 0.036$: the correct order of magnitude and the correct direction of deviation from mean field, as expected of a first-order truncation evaluated at $\varepsilon = 1$.

### 4.4 Physicality, uniformly in $N$

**Theorem 4.6 (Uniform physical admissibility).** For every $N \ge 0$ and every $0 < \varepsilon \le 1$,
$$\eta > 0, \qquad \nu > \tfrac12, \qquad \gamma > 1, \qquad 0 < \beta_{\mathrm{op}} < \tfrac12, \qquad \alpha < 1, \qquad \delta > 3 .$$

*Proof sketch.* $\eta > 0$, $\nu > 1/2$ and $\gamma > 1$ follow because $(N+2)$, $\varepsilon$ (or $\varepsilon^2$) and $(N+8)$ are all positive. For $\beta_{\mathrm{op}}$: $3\varepsilon/(2(N+8)) > 0$ gives the upper bound, and $3\varepsilon \le 3 < N+8$ gives $3\varepsilon/(2(N+8)) < 1/2$, hence the lower bound. For $\alpha$: if $N \le 4$ then $(4-N)\varepsilon \le 4 < 2(N+8)$; if $N > 4$ then $\alpha \le 0 < 1$. Finally $\delta = 3+\varepsilon > 3$. $\square$

Every predicted exponent is qualitatively of the type expected for a genuine second-order transition, simultaneously for the whole family and for the entire physically interesting range of $\varepsilon$ up to and including $\varepsilon = 1$. This is a nontrivial consistency requirement: a truncated expansion could easily produce a negative $\beta_{\mathrm{op}}$ or a $\nu$ below mean field, and it does not.

---

## 5. Uniform behaviour in the symmetry index

Write the leading coefficients as functions of $N$ alone:
$$\eta_2(N) := \frac{N+2}{2(N+8)^2}, \quad \nu_1(N) := \frac{N+2}{4(N+8)}, \quad \alpha_1(N) := \frac{4-N}{2(N+8)}, \quad \gamma_1(N) := \frac{N+2}{2(N+8)},$$
so that $\eta = \eta_2(N)\varepsilon^2$, $\nu = \tfrac12 + \nu_1(N)\varepsilon$, and so on. Note $\eta_2(1) = 1/54$ and $\nu_1(1) = 1/12$, consistent with Proposition 4.5.

### 5.1 The anomalous dimension is maximised at $N = 4$

**Theorem 5.1 (Maximality at four components).** For every real $N > -8$,
$$\eta_2(N) \le \frac{1}{48},$$
with equality if and only if $N = 4$.

*Proof sketch.* Since $N+8 > 0$, the inequality is equivalent, after clearing denominators, to $48(N+2) \le 2(N+8)^2$, i.e. to $0 \le 2N^2 - 16N + 32 = 2(N-4)^2$, which is true, with equality iff $N = 4$. $\square$

**Corollary 5.2 ($N$-free bound on $\eta$).** For all $N \ge 0$ and all real $\varepsilon$,
$$0 < \eta_2(N) \quad\text{and}\quad \frac{(N+2)\varepsilon^2}{2(N+8)^2} \le \frac{\varepsilon^2}{48}.$$

*Proof sketch.* Positivity is clear; the bound is Theorem 5.1 multiplied by $\varepsilon^2 \ge 0$. $\square$

The mechanism is transparent: $\tfrac{d}{dN}\tfrac{N+2}{(N+8)^2}$ has numerator $(N+8)^2 - 2(N+2)(N+8) = (N+8)\big[(N+8) - 2(N+2)\big] = (N+8)(4-N)$. The factor $(4-N)$ is the source of the extremum. Correspondingly:

**Theorem 5.3 (Two-sided monotonicity).** If $-8 < N_1 < N_2 \le 4$ then $\eta_2(N_1) < \eta_2(N_2)$. If $4 \le N_1 < N_2$ then $\eta_2(N_2) < \eta_2(N_1)$.

*Proof sketch.* Cross-multiplying, the sign of $\eta_2(N_2) - \eta_2(N_1)$ is that of
$$2(N_2-N_1)\Big[6\big((N_1+8)+(N_2+8)\big) - (N_1+8)(N_2+8)\Big].$$
Setting $x = N_1+8$, $y = N_2+8$, the bracket is $6(x+y) - xy$, which is positive when $x < y \le 12$ (i.e. $N_2 \le 4$) and negative when $12 \le x < y$ (i.e. $N_1 \ge 4$). $\square$

Thus the anomalous dimension, viewed across the family, rises from $\eta_2(0) = 1/64$ through $\eta_2(1) = 1/54$, $\eta_2(2) = 1/50$, $\eta_2(3) = 5/242$ to its maximum $\eta_2(4) = 1/48$, and then decreases to $0$.

### 5.2 The correlation-length coefficient

**Theorem 5.4 (Strict monotonicity of $\nu_1$).** If $-8 < N_1 < N_2$ then $\nu_1(N_1) < \nu_1(N_2)$.

*Proof sketch.* Cross-multiplying by the positive quantities $4(N_i+8)$, the claim reduces to $(N_1+2)(N_2+8) < (N_2+2)(N_1+8)$, i.e. to $6N_1 < 6N_2$. $\square$

**Theorem 5.5 (Uniform window).** For every $N \ge 0$,
$$\frac{1}{16} \le \nu_1(N) < \frac14 .$$

*Proof sketch.* $\nu_1(N) \ge 1/16 \iff 4(N+2) \ge N+8 \iff 3N \ge 0$. And $\nu_1(N) < 1/4 \iff N+2 < N+8$. $\square$

The lower endpoint is attained at $N=0$ (the self-avoiding-walk limit); the upper endpoint $1/4$ is the spherical-model value, approached but never attained at finite $N$ (Section 6).

### 5.3 The specific heat stops diverging at $N=4$

**Theorem 5.6 (Antitonicity of $\alpha_1$).** If $-8 < N_1 < N_2$ then $\alpha_1(N_2) < \alpha_1(N_1)$.

*Proof sketch.* Reduces after clearing denominators to $(4-N_2)(N_1+8) < (4-N_1)(N_2+8)$, i.e. to $-12N_2 < -12N_1$. $\square$

**Theorem 5.7 (Sign flip at four components).** For $N > -8$ and $\varepsilon > 0$,
$$\alpha > 0 \iff N < 4, \qquad \alpha = 0 \iff N = 4, \qquad \alpha < 0 \iff N > 4 .$$

*Proof sketch.* $\alpha = (4-N)\varepsilon/\big(2(N+8)\big)$ with $\varepsilon > 0$ and $2(N+8) > 0$; the sign is that of $4-N$. $\square$

This is the classical statement that the specific heat ceases to diverge above four order-parameter components. For $N < 4$ the specific heat has a genuine power-law divergence; at $N = 4$ the leading exponent vanishes (and the true behaviour is logarithmic, beyond this order); for $N > 4$ the specific heat is finite at $T_c$ with a cusp.

It is a striking coincidence — or, more accurately, a shared algebraic origin in the interplay between the factors $N+2$ and $N+8$ — that the same value $N=4$ is both the extremum of $\eta_2$ and the zero of $\alpha_1$. Physically, $N=4$ is the borderline of the family in two independent senses.

### 5.4 The Gaussian locus $N = -2$

Although outside the admissible range, the value $N=-2$ is distinguished and worth recording, because it is a genuine feature of the formal continuation in $N$.

**Theorem 5.8 (Collapse to Gaussian at $N=-2$).**
$$\eta_2(-2) = 0, \qquad \nu_1(-2) = 0, \qquad \gamma_1(-2) = 0 .$$
Consequently at $N=-2$ the first-order exponents are exactly the mean-field values $\eta = 0$, $\nu = 1/2$, $\gamma = 1$.

*Proof sketch.* Every one of the three coefficients has $(N+2)$ as numerator. $\square$

**Theorem 5.9 (Uniqueness of the Gaussian locus).** If $N \neq -8$ and $\nu_1(N) = 0$, then $N = -2$.

*Proof sketch.* $\nu_1(N) = 0$ with non-vanishing denominator forces $N + 2 = 0$. $\square$

So the "$O(-2)$ model" is the unique point of the continued family at which all leading fluctuation corrections switch off simultaneously — a well-known curiosity of the formal $N$-continuation, related to the exact solvability of certain $N=-2$ models.

---

## 6. Large $N$ and the spherical-model cross-check

### 6.1 Partial fractions and limits

Each coefficient is a rational function of $N$ with a single pole at $N = -8$, so writing $t = (N+8)^{-1}$ puts them in an immediately readable form.

**Lemma 6.1 (Partial fractions).** For $N \neq -8$, with $t = (N+8)^{-1}$,
$$\eta_2(N) = \frac{t}{2} - 3t^2, \qquad \nu_1(N) = \frac14 - \frac32 t, \qquad \alpha_1(N) = -\frac12 + 6t .$$

*Proof sketch.* $N + 2 = (N+8) - 6$; substitute and divide. For $\eta_2$: $\tfrac{(N+8)-6}{2(N+8)^2} = \tfrac{t}{2} - 3t^2$. For $\nu_1$: $\tfrac{(N+8)-6}{4(N+8)} = \tfrac14 - \tfrac32 t$. For $\alpha_1$: $4 - N = 12 - (N+8)$, so $\tfrac{12-(N+8)}{2(N+8)} = 6t - \tfrac12$. $\square$

**Theorem 6.2 (Large-$N$ limits).** As $N \to \infty$,
$$\eta_2(N) \to 0, \qquad \nu_1(N) \to \tfrac14, \qquad \alpha_1(N) \to -\tfrac12, \qquad \gamma_1(N) \to \tfrac12 .$$
Equivalently, $\eta \to 0$, $\nu \to \tfrac12 + \tfrac{\varepsilon}{4}$, $\alpha \to -\tfrac{\varepsilon}{2}$, $\gamma \to 1 + \tfrac{\varepsilon}{2}$.

*Proof sketch.* $t = (N+8)^{-1} \to 0$ as $N \to \infty$, since $N + 8 \to \infty$ and inversion sends $+\infty$ to $0$. Apply Lemma 6.1 and the algebra of limits: $\tfrac{t}{2} - 3t^2 \to 0$, $\tfrac14 - \tfrac32 t \to \tfrac14$, $-\tfrac12 + 6t \to -\tfrac12$. $\square$

### 6.2 The spherical model

The $N \to \infty$ limit of the $O(N)$ model is the *spherical model*, solvable in closed form in every dimension $2 < d < 4$, with
$$\nu_{\mathrm{sph}} = \frac{1}{d-2}, \qquad \alpha_{\mathrm{sph}} = \frac{d-4}{d-2}, \qquad \eta_{\mathrm{sph}} = 0 .$$
In $d = 4-\varepsilon$ these are $1/(2-\varepsilon)$ and $-\varepsilon/(2-\varepsilon)$. Comparing with Theorem 6.2 gives an independent check of the expansion against an exact solution.

**Theorem 6.3 (Exact $\nu$-discrepancy and bound).** For $\varepsilon \neq 2$,
$$\frac{1}{2-\varepsilon} - \left(\frac12 + \frac{\varepsilon}{4}\right) \;=\; \frac{\varepsilon^2}{4(2-\varepsilon)} .$$
Consequently, for $|\varepsilon| \le 1$,
$$\left|\frac{1}{2-\varepsilon} - \left(\frac12 + \frac{\varepsilon}{4}\right)\right| \;\le\; \frac{\varepsilon^2}{4}.$$

*Proof sketch.* The identity is a computation over the common denominator $4(2-\varepsilon)$: the numerator is $4 - (2+\varepsilon)(2-\varepsilon) = 4 - (4-\varepsilon^2) = \varepsilon^2$. For the bound, $|\varepsilon| \le 1$ gives $2 - \varepsilon \ge 1$, so $4(2-\varepsilon) \ge 4$ and the quotient is at most $\varepsilon^2/4$. $\square$

**Theorem 6.4 (Exact $\alpha$-discrepancy and bound).** For $\varepsilon \neq 2$,
$$\frac{-\varepsilon}{2-\varepsilon} - \left(-\frac{\varepsilon}{2}\right) \;=\; \frac{-\varepsilon^2}{2(2-\varepsilon)},$$
and for $|\varepsilon| \le 1$ the absolute value of this quantity is at most $\varepsilon^2/2$.

*Proof sketch.* Common denominator $2(2-\varepsilon)$: numerator $-2\varepsilon + \varepsilon(2-\varepsilon) = -\varepsilon^2$. The bound follows as before from $2-\varepsilon \ge 1$. $\square$

So the leading $\varepsilon$-expansion agrees with the exact spherical-model answers to first order with explicitly bounded second-order error, uniformly for $|\varepsilon| \le 1$. Together with $\eta_2 \to 0 = \eta_{\mathrm{sph}}$, this is a genuine consistency test: a perturbative construction, valid a priori only near $d=4$, is confirmed at the opposite extreme of the symmetry parameter by a non-perturbative exact solution.

---

## 7. Scaling relations and the linearity principle

### 7.1 Which relations survive truncation

Classical thermodynamic scaling theory predicts
$$\alpha + 2\beta_{\mathrm{op}} + \gamma = 2 \ \ (\text{Rushbrooke}), \qquad \gamma = \nu(2-\eta) \ \ (\text{Fisher}),$$
$$2-\alpha = d\nu \ \ (\text{Josephson}), \qquad \delta = 1 + \gamma/\beta_{\mathrm{op}} \ \ (\text{Widom}).$$
Truncated exponents need not satisfy these exactly. We determine exactly which do.

**Theorem 7.1 (Rushbrooke is an identity).** For every $N \neq -8$ and every $\varepsilon$,
$$\alpha(N,\varepsilon) + 2\beta_{\mathrm{op}}(N,\varepsilon) + \gamma(N,\varepsilon) = 2 .$$

*Proof sketch.* The constant terms are $0 + 2\cdot\tfrac12 + 1 = 2$. The $\varepsilon$-terms have common denominator $2(N+8)$ and numerator
$$(4-N) - 2\cdot 3 + (N+2) = 4 - N - 6 + N + 2 = 0,$$
identically in $N$. $\square$

The cancellation is exact and $N$-independent: the residues at the pole $N=-8$ cancel among the three exponents simultaneously.

**Theorem 7.2 ($\gamma = 2\nu$ exactly).** For every $N \neq -8$ and every $\varepsilon$, $\gamma(N,\varepsilon) = 2\nu(N,\varepsilon)$.

*Proof sketch.* $2\nu = 1 + (N+2)\varepsilon/\big(2(N+8)\big) = \gamma$ term by term. $\square$

This has an immediate and initially disconcerting consequence. Fisher's relation reads $\eta = 2 - \gamma/\nu$; since $\gamma/\nu = 2$ identically, the naive reading returns $\eta = 0$, contradicting Theorem 4.2. The resolution is that Fisher's relation, being nonlinear, cannot hold exactly for the truncation; the correct exact statement is the deficit identity:

**Theorem 7.3 (Exact Fisher deficit).** For every $N \neq -8$,
$$\gamma - \nu(2-\eta) \;=\; \nu\,\eta ,$$
a quantity of order $\varepsilon^2$.

*Proof sketch.* By Theorem 7.2, $\gamma - \nu(2-\eta) = 2\nu - 2\nu + \nu\eta = \nu\eta$. $\square$

**Theorem 7.4 (Exact Josephson deficit).** In $d = 4-\varepsilon$, for every $N \neq -8$,
$$(2-\alpha) - (4-\varepsilon)\nu \;=\; \frac{(N+2)\varepsilon^2}{4(N+8)} .$$

*Proof sketch.* Expand $(4-\varepsilon)\nu = 2 + \tfrac{(N+2)\varepsilon}{N+8} - \tfrac{\varepsilon}{2} - \tfrac{(N+2)\varepsilon^2}{4(N+8)}$. The $\varepsilon^1$ terms of $(2-\alpha) - (4-\varepsilon)\nu$ have numerator over $2(N+8)$ equal to $-(4-N) - 2(N+2) + (N+8) = 0$, and the constant terms cancel, leaving exactly $+\tfrac{(N+2)\varepsilon^2}{4(N+8)}$. $\square$

**Theorem 7.5 (Exact Widom deficit).** For $N \neq -8$ and $N + 8 - 3\varepsilon \neq 0$,
$$1 + \frac{\gamma}{\beta_{\mathrm{op}}} - \delta \;=\; \frac{3\varepsilon^2}{N+8-3\varepsilon} .$$

*Proof sketch.* Put both exponents over $2(N+8)$:
$$\beta_{\mathrm{op}} = \frac{N+8-3\varepsilon}{2(N+8)}, \qquad \gamma = \frac{2(N+8)+(N+2)\varepsilon}{2(N+8)},$$
so $\gamma/\beta_{\mathrm{op}} = \big(2(N+8)+(N+2)\varepsilon\big)/(N+8-3\varepsilon)$. Writing $D = N+8-3\varepsilon$ and combining over $D$, the numerator of $1 + \gamma/\beta_{\mathrm{op}} - (3+\varepsilon)$ is
$$-(2+\varepsilon)D + 2(N+8) + (N+2)\varepsilon = 6\varepsilon + 3\varepsilon^2 - (N+8)\varepsilon + (N+2)\varepsilon = 3\varepsilon^2 . \qquad\square$$

Notably the $O(\varepsilon)$ part cancels for every $N$ simultaneously, and the numerator of the leading defect is $N$-independent.

**Theorem 7.6 (Order-parameter deficit).** For $N \neq -8$,
$$\nu\,(2 - \varepsilon + \eta) - 2\beta_{\mathrm{op}} \;=\; \nu\eta - \frac{(N+2)\varepsilon^2}{4(N+8)} .$$

*Proof sketch.* The relation $2\beta_{\mathrm{op}} = \nu(d-2+\eta)$ with $d = 4-\varepsilon$; the $\varepsilon^1$ parts cancel and the residue is the difference of the two $O(\varepsilon^2)$ deficits already computed. $\square$

### 7.2 A coupling–exponent identity

**Theorem 7.7.** For every $N \neq -8$ and every $\varepsilon$,
$$3\,\eta(N,\varepsilon) \;=\; \big(2\nu(N,\varepsilon) - 1\big)\, g^*(N,\varepsilon) .$$

*Proof sketch.* $2\nu - 1 = (N+2)\varepsilon/\big(2(N+8)\big)$; multiplying by $g^* = 3\varepsilon/(N+8)$ gives $3(N+2)\varepsilon^2/\big(2(N+8)^2\big) = 3\eta$. $\square$

Both sides are $O(\varepsilon^2)$. The identity is a genuine constraint tying the *two-loop* datum $\eta$ to purely *one-loop* data ($\nu$ and the fixed-point coupling): the anomalous dimension is not an independent input of the truncated theory.

### 7.3 The linearity principle

**Theorem 7.8 ($N$-independent invariants).** For every $N \neq -8$ and every $\varepsilon$,
$$\gamma = 2\nu, \qquad \alpha + 2\beta_{\mathrm{op}} + \gamma = 2, \qquad \alpha = 2 - 4\nu + \frac{\varepsilon}{2}, \qquad \delta = 3 + \varepsilon, \qquad \omega = \varepsilon .$$

*Proof sketch.* The first two are Theorems 7.2 and 7.1. For the third: $4\nu = 2 + (N+2)\varepsilon/(N+8)$, so $2 - 4\nu + \varepsilon/2$ has $\varepsilon$-numerator over $2(N+8)$ equal to $-2(N+2) + (N+8) = 4-N$, which is exactly $\alpha$. The last two are definitional at this order. $\square$

These five relations mention $N$ nowhere. Combined with $2\beta_{\mathrm{op}} = 2 - \alpha - \gamma$ from Rushbrooke, they say:

> **Linearity principle.** At first order in $\varepsilon$, the whole one-parameter family of $O(N)$ exponent vectors
> $$\big(\alpha, \beta_{\mathrm{op}}, \gamma, \delta, \nu, \eta, \omega\big)$$
> lies, modulo the $O(\varepsilon^2)$ entry $\eta$, on a single affine line in exponent space, parameterised by $\nu$ alone. Consequently:
> * every scaling relation *affine* in the exponents holds identically in $(N,\varepsilon)$ — this is why Rushbrooke is exact;
> * every scaling relation *nonlinear* in the exponents acquires a deficit which is exactly its second-order Taylor term along that line — this is why Fisher, Widom and Josephson each carry an explicitly computable $O(\varepsilon^2)$ defect.

This principle organises the whole of Section 7 into a single statement and predicts, without further computation, which of any proposed scaling identity will hold exactly for the truncated exponents.

---

## 8. The flow as a dynamical system

The results so far concern fixed points and their linearisations. It is a stronger, genuinely dynamical statement that the Wilson–Fisher point actually attracts the flow, with a basin one can name. We prove this for the discrete (Euler) infrared flow, which is what a numerical implementation of the renormalisation group actually iterates.

**Definition 8.1 (Discrete infrared flow).** Write $a_N := (N+8)/3$. Given a step size $h > 0$ and an initial coupling $g_0$, set
$$g_{n+1} \;:=\; g_n - h\big(-\varepsilon g_n + a_N g_n^2\big) \;=\; g_n\big(1 + h\varepsilon - h a_N g_n\big).$$
The sign is chosen so that the flow runs in the infrared direction, $-\beta$.

**Lemma 8.2 (One step preserves $(0, \varepsilon/a)$).** Let $a > 0$, $h > 0$ with $h\varepsilon \le 1$, and $0 < x < \varepsilon/a$. Then
$$0 < x(1 + h\varepsilon - h a x) \quad\text{and}\quad x\big(1 + ha(\varepsilon/a - x)\big) < \varepsilon/a .$$

*Proof sketch.* Positivity: $ax < \varepsilon$ gives $1 + h\varepsilon - hax > 1 > 0$, and $x > 0$. For the upper bound, the exact identity
$$\frac{\varepsilon}{a} - x\Big(1 + ha\big(\tfrac{\varepsilon}{a} - x\big)\Big) \;=\; \Big(\frac{\varepsilon}{a} - x\Big)\big(1 - h a x\big)$$
reduces the claim to positivity of the right-hand side. The first factor is positive by hypothesis; the second is non-negative since $hax < h\varepsilon \le 1$, and cannot vanish, because $hax = 1$ together with $ax < \varepsilon$ would force $h\varepsilon > 1$. $\square$

**Theorem 8.3 (Invariance and monotonicity).** Let $N \ge 0$, $\varepsilon > 0$, $0 < h$ with $h\varepsilon \le 1$, and $0 < g_0 < \varepsilon/a_N$. Then for every $n$,
$$0 < g_n < \frac{\varepsilon}{a_N} \quad\text{and}\quad g_n < g_{n+1}.$$

*Proof sketch.* Induction on $n$, using Lemma 8.2 for the invariance and, for the strict increase, the computation $g_{n+1} - g_n = h g_n(\varepsilon - a_N g_n) > 0$, valid whenever $0 < g_n < \varepsilon/a_N$. $\square$

**Theorem 8.4 (Wilson–Fisher is the infrared attractor).** Under the hypotheses of Theorem 8.3,
$$\lim_{n\to\infty} g_n \;=\; \frac{\varepsilon}{a_N} \;=\; \frac{3\varepsilon}{N+8} \;=\; g^*(N,\varepsilon).$$

*Proof sketch.* By Theorem 8.3 the sequence is increasing and bounded above by $\varepsilon/a_N$, so it converges to its supremum $L$. Passing to the limit in the recursion $g_{n+1} = g_n(1 + h\varepsilon - h a_N g_n)$ — legitimate since both sides converge and the right-hand side is a polynomial in $g_n$ — yields $L = L(1 + h\varepsilon - h a_N L)$, i.e. $L\,h(\varepsilon - a_N L) = 0$. Since $L \ge g_0 > 0$ and $h > 0$, this forces $\varepsilon = a_N L$, i.e. $L = \varepsilon/a_N$. $\square$

The basin $(0, g^*)$ and the admissible step range $0 < h \le 1/\varepsilon$ are the same for every $N \ge 0$: the dynamical picture is $N$-uniform. This upgrades "Wilson–Fisher is a root of a quadratic with positive slope" to "Wilson–Fisher is the limit of the actual coarse-graining iteration, from an explicitly described set of initial conditions".

---

## 9. Two loops: existence and $N$-uniform asymptotics

At the next order the beta function is a genuine cubic,
$$\beta_N(\varepsilon,g) \;=\; -\varepsilon g + a g^2 - c g^3, \qquad a = \frac{N+8}{3},$$
and its non-Gaussian zero is no longer a polynomial in $\varepsilon$. Rather than manipulate formal power series, we work with the exact root and bound it.

Throughout this section $c > 0$ is a free parameter, so that the results are *scheme-independent*; the standard choice in our normalisation is $c = (3N+14)/9$.

**Theorem 9.1 (Existence of a small positive root).** Let $a, c, \varepsilon > 0$ with $4c\varepsilon \le a^2$. Then there exists $r \in [\varepsilon/a,\; 2\varepsilon/a]$ with
$$c r^2 - a r + \varepsilon = 0 .$$

*Proof sketch.* Set $f(x) = cx^2 - ax + \varepsilon$, continuous. At the left endpoint, $f(\varepsilon/a) = c\varepsilon^2/a^2 \ge 0$. At the right endpoint, $f(2\varepsilon/a) = (4c\varepsilon - a^2)\varepsilon/a^2 \le 0$ by hypothesis. The intermediate value theorem on $[\varepsilon/a, 2\varepsilon/a]$ (which is a genuine interval since $\varepsilon, a > 0$) produces the root. $\square$

**Lemma 9.2 (Exact slope along the zero locus).** If $c r^2 - a r + \varepsilon = 0$ then
$$-\varepsilon + 2ar - 3cr^2 \;=\; \varepsilon - c r^2 .$$

*Proof sketch.* Subtract twice the root equation: $2(cr^2 - ar + \varepsilon) = 0$ gives $2ar = 2cr^2 + 2\varepsilon$, and substituting into the left-hand side yields $-\varepsilon + 2cr^2 + 2\varepsilon - 3cr^2 = \varepsilon - cr^2$. $\square$

The left-hand side is $\partial_g\beta_N$ evaluated at $g=r$, and the right-hand side is a strictly algebraic simplification, not an approximation. Setting $c=0$ recovers Theorem 3.5.

**Theorem 9.3 (Quantitative expansion of the fixed point).** Let $a, c, \varepsilon > 0$ and let $r \in [\varepsilon/a, 2\varepsilon/a]$ satisfy $cr^2 - ar + \varepsilon = 0$. Then
$$0 \;\le\; r - \left(\frac{\varepsilon}{a} + \frac{c\varepsilon^2}{a^3}\right) \;\le\; \frac{12\,c^2\varepsilon^3}{a^5}.$$

*Proof sketch.* The key algebraic identity, obtained by clearing $a^3$ and using the root equation, is
$$a^3\left(r - \frac{\varepsilon}{a} - \frac{c\varepsilon^2}{a^3}\right) \;=\; c\,(ar - \varepsilon)(ar + \varepsilon).$$
Both factors on the right are non-negative — $ar \ge \varepsilon$ from $r \ge \varepsilon/a$ — giving the lower bound. For the upper bound, the root equation gives the exact relation $ar - \varepsilon = cr^2$, and $r \le 2\varepsilon/a$ gives $r^2 \le 4\varepsilon^2/a^2$, hence $ar - \varepsilon \le 4c\varepsilon^2/a^2$; also $ar + \varepsilon \le 3\varepsilon$. Multiplying, $c(ar-\varepsilon)(ar+\varepsilon) \le 12c^2\varepsilon^3/a^2$, and dividing by $a^3$ finishes. $\square$

**Theorem 9.4 (Quantitative expansion of $\omega$).** Under the hypotheses of Theorem 9.3,
$$\left|\big({-\varepsilon} + 2ar - 3cr^2\big) - \left(\varepsilon - \frac{c\varepsilon^2}{a^2}\right)\right| \;\le\; \frac{12\,c^2\varepsilon^3}{a^4}.$$

*Proof sketch.* By Lemma 9.2 the quantity equals $c\,(r^2 - \varepsilon^2/a^2)$ in absolute value. The bracket is non-negative since $r \ge \varepsilon/a$, and is bounded above by writing $r^2 - \varepsilon^2/a^2 = (ar-\varepsilon)(ar+\varepsilon)/a^2$ and reusing the two bounds from the previous proof: $(ar-\varepsilon)(ar+\varepsilon) \le 12c\varepsilon^3/a^2$, so $r^2 - \varepsilon^2/a^2 \le 12c\varepsilon^3/a^4$. Multiply by $c$. $\square$

**Definition 9.5.** The predicted two-loop fixed point of the $O(N)$ family is
$$g^*_{2}(N,c,\varepsilon) := \frac{3\varepsilon}{N+8} + \frac{27\,c\,\varepsilon^2}{(N+8)^3},$$
which is exactly $\varepsilon/a + c\varepsilon^2/a^3$ with $a = (N+8)/3$.

**Lemma 9.6 (Root of the quadratic factor is a zero of the cubic).** If $c g^2 - \tfrac{N+8}{3}g + \varepsilon = 0$ then $-\varepsilon g + \tfrac{N+8}{3}g^2 - cg^3 = 0$.

*Proof sketch.* The cubic equals $-g\big(cg^2 - \tfrac{N+8}{3}g + \varepsilon\big)$. $\square$

**Theorem 9.7 ($N$-uniform two-loop fixed point).** Let $N \ge 0$ and $0 < \varepsilon \le 4/7$, and take the standard coefficient $c = c(N) = (3N+14)/9$. Then there exists $g$ such that
1. $-\varepsilon g + \tfrac{N+8}{3}g^2 - cg^3 = 0$ (a genuine zero of the two-loop beta function);
2. $g \ge 3\varepsilon/(N+8)$ (it lies at or above the one-loop Wilson–Fisher value);
3. $\big|g - g^*_2(N,c,\varepsilon)\big| \le \varepsilon^3$, with the constant $1$ *independent of $N$*.

*Proof sketch.* Put $a = (N+8)/3 \ge 8/3 > 0$ and $c = (3N+14)/9 > 0$. The smallness hypothesis $4c\varepsilon \le a^2$ holds because $\varepsilon \le 4/7$ and $4\cdot\tfrac{3N+14}{9}\cdot\tfrac47 \le \big(\tfrac{N+8}{3}\big)^2$ for $N \ge 0$ (a quadratic inequality in $N$). Theorem 9.1 supplies a root $r \in [\varepsilon/a, 2\varepsilon/a]$; Lemma 9.6 makes it a zero of the cubic; $r \ge \varepsilon/a = 3\varepsilon/(N+8)$ gives (2); and Theorem 9.3 gives $|r - g^*_2| \le 12c^2\varepsilon^3/a^5$. It remains to show $12c^2/a^5 \le 1$ for all $N \ge 0$. Since $c = \tfrac{3N+14}{9} \le \tfrac{N+8}{3} = a$, it suffices that $12a^2 \le a^5$, i.e. $a^3 \ge 12$, which holds because $a \ge 8/3$ and $(8/3)^3 = 512/27 > 12$. $\square$

**Theorem 9.8 (Two loops push the coupling up).** For $N \ge 0$ and $\varepsilon > 0$,
$$\frac{3\varepsilon}{N+8} \;<\; g^*_2\big(N, c(N), \varepsilon\big).$$

*Proof sketch.* The difference is $27c\varepsilon^2/(N+8)^3 > 0$. $\square$

**Remark 9.9 (Why uniformity is not automatic).** The remainder constant $12c^2/a^5$ contains $c^2$, which grows like $N^2$. Uniformity therefore depends essentially on the growth of $a = (N+8)/3$, and specifically on the fact that $a$ appears to the *fifth* power: the net behaviour is $O(N^2/N^5) = O(N^{-3})$. Physically, this is the statement that the two-loop remainder is uniformly small *because* the fixed-point coupling shrinks like $1/N$ (Theorem 3.3). Highly symmetric models are weakly coupled at criticality, and perturbation theory is correspondingly better behaved there — consistent with the exact solvability of the $N=\infty$ limit.

---

## 10. Discussion

### 10.1 What parameterisation buys

Every individual formula in Section 4 is classical. What is new here is the systematic treatment of $N$ as a variable and the resulting global statements:

- an *extremum theorem* (Theorem 5.1) that is invisible at any single $N$ — the maximum of the anomalous dimension coefficient at exactly $N = 4$, with the $N$-free bound $\eta \le \varepsilon^2/48$;
- *sign-change* and *monotonicity* statements (Theorems 5.3–5.7) with the same value $N=4$ appearing twice for algebraically distinct reasons;
- *exact deficits* for every scaling relation (Section 7), rather than the usual assertion that they hold "to this order";
- the *linearity principle* (Section 7.3), which explains the entire deficit table structurally;
- $N$-*uniform* dynamical and two-loop statements (Sections 8, 9), with explicit constants and explicit ranges of validity.

### 10.2 A cautionary case

Two natural-sounding claims turn out to be false and had to be reformulated.

First, "Fisher's relation $\eta = 2 - \gamma/\nu$ holds to this order" is false as stated for the truncated exponents: since $\gamma = 2\nu$ identically (Theorem 7.2), the right-hand side is identically $0$, contradicting $\eta > 0$. The correct statement is the exact deficit identity $\gamma - \nu(2-\eta) = \nu\eta$ (Theorem 7.3). The lesson is precisely the linearity principle: the truncation lies on the line $\gamma = 2\nu$, so relations sensitive to the *curvature* of the exponent manifold cannot be tested at this order.

Second, "the leading coefficients are monotone in $N$" is false for $\eta_2$: monotonicity holds only up to $N=4$ (Theorem 5.3). This apparent obstruction is what became the extremum theorem.

### 10.3 Limitations

The expansion is asymptotic, not convergent, and is evaluated at $\varepsilon = 1$ for three dimensions, so first-order numerical accuracy is modest (Section 4.3). The exponents in Definition 4.1 are truncations of the corresponding series and are not claimed to satisfy any relation beyond the stated order; the deficits computed in Section 7 quantify exactly this. The two-loop analysis (Section 9) treats $c$ as a positive parameter and controls the *exact* root of the cubic, but does not attempt to derive $c$ diagrammatically. The $N\to\infty$ comparison (Section 6) is a first-order comparison with explicit second-order error, not a proof that the expansion resums to the spherical model.

### 10.4 Numerical summary at $\varepsilon = 1$

| $N$ | $g^*$ | $\eta$ | $\nu$ | $\gamma$ | $\alpha$ | $\beta_{\mathrm{op}}$ |
|---|---|---|---|---|---|---|
| $0$ | $0.3750$ | $0.01563$ | $0.5625$ | $1.1250$ | $0.2500$ | $0.3125$ |
| $1$ | $0.3333$ | $0.01852$ | $0.5833$ | $1.1667$ | $0.1667$ | $0.3333$ |
| $2$ | $0.3000$ | $0.02000$ | $0.6000$ | $1.2000$ | $0.1000$ | $0.3500$ |
| $3$ | $0.2727$ | $0.02066$ | $0.6136$ | $1.2273$ | $0.0455$ | $0.3636$ |
| $4$ | $0.2500$ | $0.02083$ | $0.6250$ | $1.2500$ | $0.0000$ | $0.3750$ |
| $10$ | $0.1667$ | $0.01852$ | $0.6667$ | $1.3333$ | $-0.1667$ | $0.4167$ |
| $\infty$ | $0$ | $0$ | $0.7500$ | $1.5000$ | $-0.5000$ | $0.5000$ |

The $\eta$ column peaks at $N=4$ and the $\alpha$ column changes sign there, exactly as Theorems 5.1 and 5.7 predict. Every row satisfies $\alpha + 2\beta_{\mathrm{op}} + \gamma = 2$ and $\gamma = 2\nu$ exactly, as Theorems 7.1 and 7.2 require.

### 10.5 Future directions

Several threads suggest themselves.

**A linear-relations-are-exact theorem.** Section 7.3 states the principle informally. It should be possible to formulate and prove it as a genuine theorem: characterise the affine subspace containing the first-order exponent vector, and show that a polynomial relation among exponents holds identically on the truncation if and only if it vanishes on that subspace, with deficit equal to the leading nonvanishing Taylor term along it. This would replace the case-by-case computations of Theorems 7.1–7.6 with a single structural argument, and would predict the deficit of any proposed relation without computation.

**Higher orders with the same uniformity.** The two-loop analysis of Section 9 controls the exact root of a cubic. Extending to the quartic beta function requires either a root-finding estimate for one more degree or a different technique (e.g. contraction-mapping arguments for the implicit function defining $g^*(\varepsilon)$). The payoff would be $N$-uniform three-loop exponents with explicit constants.

**The full continuation in $N$.** Our uniform results are stated on $N \ge 0$, with several extending to $N > -8$. The behaviour on $(-8, -2)$ and near $N = -8$, where the fixed point escapes to infinity, is mathematically well defined in the truncated model and deserves its own analysis.

**Resummation and $\varepsilon = 1$.** All bounds here are on the truncation error of the *series in $\varepsilon$*, not on the distance to the true three-dimensional exponents. Combining the $N$-uniform structure found here with Borel-type resummation is the natural route towards uniform-in-$N$ error control at $\varepsilon = 1$.

**Anisotropic and constrained generalisations.** Replacing $O(N)$ by a general symmetry group replaces the scalar $(N+8)/3$ by a matrix of couplings, and the fixed-point classification becomes a system of quadratics. The analogue of Theorem 3.1 — a complete classification with a uniform bound on the couplings — is the natural next target.

---

## Appendix: table of the leading coefficients

For reference, with $t = (N+8)^{-1}$:

| Quantity | Rational form | Partial fractions | $N \to \infty$ |
|---|---|---|---|
| $g^*/\varepsilon$ | $3/(N+8)$ | $3t$ | $0$ |
| $\eta/\varepsilon^2$ | $(N+2)/\big(2(N+8)^2\big)$ | $t/2 - 3t^2$ | $0$ |
| $(\nu - \tfrac12)/\varepsilon$ | $(N+2)/\big(4(N+8)\big)$ | $\tfrac14 - \tfrac32 t$ | $\tfrac14$ |
| $(\gamma - 1)/\varepsilon$ | $(N+2)/\big(2(N+8)\big)$ | $\tfrac12 - 3t$ | $\tfrac12$ |
| $\alpha/\varepsilon$ | $(4-N)/\big(2(N+8)\big)$ | $-\tfrac12 + 6t$ | $-\tfrac12$ |
| $(\tfrac12 - \beta_{\mathrm{op}})/\varepsilon$ | $3/\big(2(N+8)\big)$ | $\tfrac32 t$ | $0$ |
| $\delta - 3$ | $\varepsilon$ | — | $\varepsilon$ |
| $\omega$ | $\varepsilon$ | — | $\varepsilon$ |
